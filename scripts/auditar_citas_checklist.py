#!/usr/bin/env python3
"""Auditor de citas de las checklists (05-Checklist.md) contra el disco.

Motivo: la trampa recurrente del proyecto es la CITA FANTASMA -- un item que se
marca [x] citando un archivo, seccion o linea que no existe.  Medir eso a mano
en 167 checklists es inviable, asi que esta herramienta lo hace de una pasada.

Que mide:
  * cita_archivo    : token con forma de archivo (extension conocida) que no
                      resuelve en NINGUNA base razonable -> DEFECTO.
  * cita_directorio : token que termina en '/' y no resuelve a ningun dir.
  * linea_fuera     : cita `archivo` L<a>-<b> donde <b> supera las lineas reales
                      del archivo citado -> DEFECTO (cita fantasma de linea).
  * glob_roto       : patron con * ? {a,b} que no casa con nada.

Lo que NO cuenta como defecto (se clasifica y se informa aparte):
  extension suelta (`.tres`), pseudo-codigo (`fijar("vsync", 0/1/2)`),
  fraccion (`163/222`), comando de shell (`cp a b`), esquema `user://`,
  ref de git (`origin/main`), miembro de API (`Clase.metodo/otro`),
  carpeta excluida a proposito (`.godot/`, `.git/`).

Uso:
  python scripts/auditar_citas_checklist.py --todas
  python scripts/auditar_citas_checklist.py --modulo M90
  python scripts/auditar_citas_checklist.py --todas --json
  python scripts/auditar_citas_checklist.py --todas --check
  python scripts/auditar_citas_checklist.py --todas --deuda
  python scripts/auditar_citas_checklist.py --selftest

Codigos de salida:
  0 = sin defectos (o sin defectos NUEVOS si se usa --check con baseline)
  1 = hay defectos (o defectos nuevos respecto del baseline)
  2 = error de uso
  3 = DETECTOR CIEGO: no leyo checklists o no encontro citas (nunca 0 por ceguera)

Este script NO modifica ningun archivo.  Solo lee.
"""

from __future__ import annotations

import argparse
import collections
import fnmatch
import glob
import itertools
import json
import os
import re
import sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Carpetas que no forman parte del universo auditable.  `.godot` se excluye a
# proposito: es cache regenerable y citarla no es un defecto.
EXCLUIDOS = (
    ".git", ".godot", ".kilo", ".claude", ".venv", "venv", "site-packages",
    "node_modules", ".mypy_cache", ".pytest_cache", "PAPELERA", "Obsoletos",
    "__pycache__", "build", "out",
)

# Extensiones que consideramos "forma de archivo".  Si un token termina en una
# de estas, se audita como cita de archivo.
EXTENSIONES = (
    ".gd", ".gdshader", ".py", ".json", ".tscn", ".tres", ".md", ".po",
    ".cfg", ".sh", ".ps1", ".blend", ".blend1", ".glb", ".gltf", ".import",
    ".png", ".jpg", ".jpeg", ".svg", ".webp", ".cs", ".yml", ".yaml", ".txt",
    ".uid", ".godot", ".iss", ".ogg", ".wav", ".mp3", ".ttf", ".otf",
)

# Un token de hasta 160 caracteres entre backticks es candidato.
RE_SPAN = re.compile(r"`([^`\n]{2,160})`")
RE_EXT_SUELTA = re.compile(r"^\.[a-z0-9]{1,8}$", re.IGNORECASE)
RE_ESQUEMA = re.compile(r"^(res|user)://")
RE_GIT = re.compile(r"^(origin|upstream|refs)/")
RE_SUFIJO_LINEA = re.compile(r":L?\d+(?:\s*-\s*L?\d+)?$")
RE_FRACCION = re.compile(r"^\d+\s*/\s*\d+$")
RE_COMANDO = re.compile(
    r"^(cp|mv|rm|git|cd|ls|python|python3|pip|godot|bash|sh|powershell|pwsh|"
    r"echo|set|export|node|npm|npx|curl|wget|chmod|mkdir|touch|grep|find)\b",
    re.IGNORECASE,
)
# Lista de extensiones sueltas: `.ogg/.wav/.mp3` no es una cita de archivo.
RE_LISTA_EXT = re.compile(r"^(?:\.[a-z0-9]{1,8}/)+$", re.IGNORECASE)
# Nombre-plantilla: `NN-Nombre.md`, `{NN}-desc.md`, `YYYY-MM-DD.md`.  Cita una
# CONVENCION de nombre, no un archivo; no es defecto que no exista.
RE_PLANTILLA = re.compile(r"^(NN|XX|X{2,}|YYYY|AAAA|M##|\{NN\})", re.IGNORECASE)
# Referencia de linea pegada a la cita: `archivo` L42-44  /  `archivo` L210
RE_REF_LINEA = re.compile(r"`([^`\n]{2,160})`\s*:?\s*(L\d+(?:\s*-\s*L?\d+)?)")


def _norm(ruta: str) -> str:
    return ruta.replace(os.sep, "/")


def indexar(raiz: str) -> tuple[set[str], set[str], dict[str, list[str]]]:
    """Devuelve (archivos, directorios, indice por basename)."""
    archivos: set[str] = set()
    directorios: set[str] = set()
    for actual, subdirs, ficheros in os.walk(raiz):
        subdirs[:] = [d for d in subdirs if d not in EXCLUIDOS]
        rel = _norm(os.path.relpath(actual, raiz))
        if rel != ".":
            directorios.add(rel)
        for f in ficheros:
            archivos.add(_norm(os.path.relpath(os.path.join(actual, f), raiz)))
    por_base: dict[str, list[str]] = collections.defaultdict(list)
    for a in archivos:
        por_base[a.split("/")[-1]].append(a)
    return archivos, directorios, por_base


def clasificar(token: str) -> str:
    """Clasifica un token entre backticks.  Conjunto cerrado de etiquetas."""
    if RE_EXT_SUELTA.match(token):
        return "extension_suelta"
    if RE_GIT.match(token):
        return "git_ref"
    if token.startswith("user://"):
        return "runtime"
    if RE_FRACCION.match(token):
        return "fraccion"
    if RE_LISTA_EXT.match(token):
        return "lista_extensiones"
    if re.search(r"[()\[\]=<>{}]", token) and not _tiene_extension(token):
        return "pseudo_codigo"
    if re.search(r"\s", token):
        return "con_espacios"
    if RE_COMANDO.match(token):
        return "comando"
    if "*" in token or "?" in token or "{" in token:
        return "glob"
    if RE_ESQUEMA.match(token):
        return "esquema"
    if token.endswith("/"):
        return "directorio"
    if _tiene_extension(token):
        base = token.rstrip("/").split("/")[-1]
        if RE_PLANTILLA.match(base):
            return "plantilla"
        return "archivo"
    if "/" in token:
        # Sin extension y con barra: puede ser un directorio sin barra final o un
        # par de API (`profundidad_min/max`).  Se audita, pero NUNCA como defecto:
        # solo se informa.  Regla de precision: un defecto exige extension real.
        return "ruta_sin_extension"
    return "otro"


def _tiene_extension(token: str) -> bool:
    bajo = token.lower()
    return any(bajo.endswith(e) for e in EXTENSIONES)


def limpiar(token: str) -> str:
    s = RE_ESQUEMA.sub("", token)
    s = RE_SUFIJO_LINEA.sub("", s)
    return s.replace("\\", "/").strip()


def bases_para(checklist: str, raiz: str) -> list[str]:
    """Bases de resolucion: raiz del repo, proyecto Godot y carpeta del modulo.

    Muchas citas son relativas al modulo (`03-Diseno.md`) o al proyecto Godot
    (`scripts/settings/...`), asi que se prueban todas antes de declarar rotura.
    """
    rel = _norm(os.path.relpath(checklist, raiz))
    mod = os.path.dirname(os.path.dirname(rel))
    return ["", "game/isla-ancestral/", mod + "/", mod + "/plan-actual/",
            "game/isla-ancestral/scripts/"]


def resolver(token: str, bases: list[str], es_dir: bool,
             archivos: set[str], directorios: set[str],
             por_base: dict[str, list[str]]) -> tuple[str, str]:
    """Devuelve (estado, ruta).  estado en {exacto,basename,ambiguo,ausente,excluido,vacio}."""
    s = token.rstrip("/")
    if not s:
        return "vacio", ""
    if s.split("/")[0] in EXCLUIDOS:
        return "excluido", ""
    universo = directorios if es_dir else archivos
    for base in bases:
        cand = (base + s).rstrip("/")
        if cand in universo:
            return "exacto", cand
    if not es_dir:
        bn = s.split("/")[-1]
        lista = por_base.get(bn, [])
        if len(lista) == 1:
            return "basename", lista[0]
        if len(lista) > 1:
            return "ambiguo", ""
    return "ausente", ""


def expandir_globs(patron: str) -> list[str]:
    """Expande {a,b} en varios patrones (una sola llave, suficiente aqui)."""
    m = re.search(r"\{([^{}]+)\}", patron)
    if not m:
        return [patron]
    salida: list[str] = []
    for alt in m.group(1).split(","):
        salida.extend(expandir_globs(patron[:m.start()] + alt.strip() + patron[m.end():]))
    return salida


def contar_lineas(ruta: str) -> int:
    try:
        with open(ruta, "rb") as fh:
            return sum(1 for _ in fh)
    except OSError:
        return -1


def auditar_checklist(checklist: str, raiz: str, archivos: set[str],
                      directorios: set[str], por_base: dict[str, list[str]]) -> dict:
    with open(checklist, "r", encoding="utf-8", errors="replace") as fh:
        texto = fh.read()
    bases = bases_para(checklist, raiz)
    rel = _norm(os.path.relpath(checklist, raiz))
    modulo = os.path.basename(os.path.dirname(os.path.dirname(rel)))

    clases: collections.Counter = collections.Counter()
    estados: collections.Counter = collections.Counter()
    rotas_archivo: list[dict] = []
    rotas_dir: list[dict] = []
    globs_rotos: list[dict] = []
    informativos: list[dict] = []
    lineas_fuera: list[dict] = []
    refs_linea = 0

    # 1) Referencias de linea pegadas a una cita.
    for m in RE_REF_LINEA.finditer(texto):
        token = m.group(1).strip()
        if clasificar(token) not in ("archivo", "esquema"):
            continue
        refs_linea += 1
        estado, ruta = resolver(limpiar(token), bases, False, archivos, directorios, por_base)
        if estado not in ("exacto", "basename"):
            continue
        total = contar_lineas(os.path.join(raiz, ruta))
        if total < 0:
            continue
        ref = re.search(r"L(\d+)(?:\s*-\s*L?(\d+))?", m.group(2))
        alto = int(ref.group(2) or ref.group(1))
        if alto > total:
            lineas_fuera.append({
                "archivo_citado": token, "resuelto": ruta,
                "referencia": m.group(2).strip(), "lineas_reales": total,
                "firma": "%s|linea|%s|%s" % (modulo, token, m.group(2).strip()),
            })

    # 2) Citas sueltas.
    for token in RE_SPAN.findall(texto):
        token = token.strip()
        if not token:
            continue
        clase = clasificar(token)
        clases[clase] += 1
        if clase == "directorio":
            estado, _ = resolver(limpiar(token), bases, True, archivos, directorios, por_base)
            estados["dir_" + estado] += 1
            if estado == "ausente":
                rotas_dir.append({
                    "cita": token,
                    "firma": "%s|directorio|%s" % (modulo, token),
                })
        elif clase in ("archivo", "esquema"):
            # `res://algo/` es un DIRECTORIO del proyecto Godot, no un archivo.
            es_dir = token.rstrip().endswith("/")
            estado, _ = resolver(limpiar(token), bases, es_dir, archivos, directorios, por_base)
            estados[("dir_" if es_dir else "") + estado] += 1
            if estado == "ausente":
                destino = rotas_dir if es_dir else rotas_archivo
                destino.append({
                    "cita": token,
                    "firma": "%s|%s|%s" % (modulo, "directorio" if es_dir else "archivo", token),
                })
        elif clase == "ruta_sin_extension":
            # Informativo: se resuelve como dir o como archivo, pero no es defecto.
            estado, _ = resolver(limpiar(token), bases, True, archivos, directorios, por_base)
            if estado == "ausente":
                estado, _ = resolver(limpiar(token), bases, False, archivos, directorios, por_base)
            estados["sin_ext_" + estado] += 1
            if estado == "ausente":
                informativos.append({
                    "cita": token,
                    "firma": "%s|sin_extension|%s" % (modulo, token),
                })
        elif clase == "glob":
            ok = False
            for patron in expandir_globs(limpiar(token)):
                if any(fnmatch.fnmatch(x, patron) or fnmatch.fnmatch(x, "*/" + patron)
                       for x in itertools.chain(archivos, directorios)):
                    ok = True
                    break
            estados["glob_ok" if ok else "glob_ausente"] += 1
            if not ok:
                globs_rotos.append({
                    "cita": token,
                    "firma": "%s|glob|%s" % (modulo, token),
                })

    return {
        "checklist": rel,
        "modulo": modulo,
        "citas": sum(clases.values()),
        "clases": dict(clases),
        "estados": dict(estados),
        "refs_linea": refs_linea,
        "rotas_archivo": rotas_archivo,
        "rotas_dir": rotas_dir,
        "globs_rotos": globs_rotos,
        "informativos": informativos,
        "lineas_fuera": lineas_fuera,
        "defectos": len(rotas_archivo) + len(lineas_fuera),
    }


def listar_checklists(raiz: str, modulo: str | None) -> list[str]:
    patron = os.path.join(raiz, "DOCUMENTACION", "*", "plan-actual", "05-Checklist.md")
    todos = sorted(glob.glob(patron))
    if modulo is None:
        return todos
    prefijo = modulo.strip().lower()
    return [c for c in todos
            if os.path.basename(os.path.dirname(os.path.dirname(c))).lower().startswith(prefijo)]


def leer_baseline(ruta: str) -> dict[str, str]:
    if not os.path.isfile(ruta):
        return {}
    with open(ruta, "r", encoding="utf-8") as fh:
        datos = json.load(fh)
    crudo = datos.get("firmas", {})
    if isinstance(crudo, list):
        return {str(f): "" for f in crudo}
    return {str(k): str(v) for k, v in crudo.items()}


def firmas_de(informe: dict) -> list[str]:
    salida: list[str] = []
    for c in informe["checklists"]:
        for grupo in ("rotas_archivo", "lineas_fuera", "globs_rotos", "rotas_dir"):
            for d in c[grupo]:
                salida.append(d["firma"])
    return salida


def ceguera(informes: list[dict]) -> list[str]:
    """Motivos por los que el detector no vio nada.  Nunca 0 por ceguera."""
    motivos: list[str] = []
    if not informes:
        motivos.append("no se leyo ninguna checklist (patron vacio o ruta mal)")
        return motivos
    if sum(i["citas"] for i in informes) == 0:
        motivos.append("se leyeron %d checklists pero se extrajeron 0 citas" % len(informes))
    auditables = sum(1 for i in informes
                     if (i["estados"].get("exacto", 0) + i["estados"].get("basename", 0)) > 0)
    if auditables == 0:
        motivos.append("ninguna cita resolvio a un archivo real: la resolucion esta rota")
    return motivos


def imprimir(informes: list[dict], max_lista: int, detalle: bool) -> None:
    total_arch = 0
    total_linea = 0
    total_dir = 0
    total_glob = 0
    print("=== AUDITORIA DE CITAS (05-Checklist.md contra disco) ===")
    print("%-46s %7s %6s %6s %6s %6s" % ("modulo", "citas", "rotas", "linea", "dir", "glob"))
    for i in informes:
        total_arch += len(i["rotas_archivo"])
        total_linea += len(i["lineas_fuera"])
        total_dir += len(i["rotas_dir"])
        total_glob += len(i["globs_rotos"])
        if i["defectos"] or i["rotas_dir"] or i["globs_rotos"]:
            print("%-46s %7d %6d %6d %6d %6d" % (
                i["modulo"][:46], i["citas"], len(i["rotas_archivo"]),
                len(i["lineas_fuera"]), len(i["rotas_dir"]), len(i["globs_rotos"])))
    print("")
    print("checklists leidas: %d | citas: %d" % (len(informes), sum(i["citas"] for i in informes)))
    print("DEFECTOS: %d citas de archivo rotas + %d refs de linea fuera de rango = %d" % (
        total_arch, total_linea, total_arch + total_linea))
    print("INFORMATIVO: %d citas de directorio ausentes, %d globs sin coincidencia" % (
        total_dir, total_glob))
    if detalle:
        print("")
        print("--- citas de archivo rotas (defecto) ---")
        vistos: collections.Counter = collections.Counter()
        for i in informes:
            for d in i["rotas_archivo"]:
                vistos["%s  [%s]" % (d["cita"], i["modulo"])] += 1
        for k, v in vistos.most_common(max_lista):
            print("  %s" % k)
        if total_linea:
            print("--- refs de linea fuera de rango (defecto) ---")
            for i in informes:
                for d in i["lineas_fuera"]:
                    print("  %s %s -> %s tiene %d lineas" % (
                        d["archivo_citado"], d["referencia"], d["resuelto"], d["lineas_reales"]))


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="Audita las citas de las checklists contra disco.")
    ap.add_argument("--raiz", default=RAIZ, help="raiz del repo (por defecto la del script)")
    ap.add_argument("--modulo", default=None, help="prefijo de modulo, p.ej. M90 o 90")
    ap.add_argument("--todas", action="store_true", help="audita todas las checklists")
    ap.add_argument("--json", action="store_true", help="salida JSON pura")
    ap.add_argument("--check", action="store_true",
                    help="falla solo con defectos NUEVOS respecto del baseline")
    ap.add_argument("--baseline", default=None, help="ruta del baseline JSON")
    ap.add_argument("--deuda", action="store_true", help="emite el baseline de la deuda actual")
    ap.add_argument("--max-lista", type=int, default=60, help="maximo de filas en el detalle")
    ap.add_argument("--selftest", action="store_true", help="corre las pruebas internas")
    args = ap.parse_args(argv)

    if args.selftest:
        return _selftest(args.raiz)

    raiz = os.path.abspath(args.raiz)
    if not args.todas and not args.modulo:
        print("ERROR: indica --todas o --modulo M##", file=sys.stderr)
        return 2

    checklists = listar_checklists(raiz, args.modulo)
    archivos, directorios, por_base = indexar(raiz)
    informes = [auditar_checklist(c, raiz, archivos, directorios, por_base) for c in checklists]

    motivos = ceguera(informes)
    if motivos:
        print("DETECTOR CIEGO:", file=sys.stderr)
        for m in motivos:
            print("  - %s" % m, file=sys.stderr)
        return 3

    if args.json:
        print(json.dumps({
            "checklists": len(informes),
            "citas": sum(i["citas"] for i in informes),
            "defectos": sum(i["defectos"] for i in informes),
            "informes": informes,
        }, indent=2, ensure_ascii=False))
        return 0

    if args.deuda:
        firmas = sorted(set(firmas_de({"checklists": informes})))
        print(json.dumps({"firmas": {f: "" for f in firmas}}, indent=2, ensure_ascii=False))
        return 0

    if args.check:
        ruta_base = args.baseline or os.path.join(raiz, "scripts", "citas_baseline.json")
        baseline = leer_baseline(ruta_base)
        actuales = firmas_de({"checklists": informes})
        nuevas = [f for f in actuales if f not in baseline]
        obsoletas = [f for f in baseline if f not in set(actuales)]
        print("=== GATE DE CITAS (--check) ===")
        print("baseline: %d firmas | actuales: %d" % (len(baseline), len(actuales)))
        for f in nuevas:
            print("  NUEVA: %s" % f)
        for f in obsoletas:
            print("  OBSOLETA (ya no ocurre, quitala del baseline): %s" % f)
        if nuevas:
            print("RESULTADO: FAIL (%d citas rotas nuevas)" % len(nuevas))
            return 1
        print("RESULTADO: PASS (0 citas rotas nuevas)")
        return 0

    imprimir(informes, args.max_lista, detalle=True)
    defectos = sum(i["defectos"] for i in informes)
    if defectos:
        print("")
        print("RESULTADO: %d defectos de cita" % defectos)
        return 1
    print("")
    print("RESULTADO: 0 defectos de cita")
    return 0


def _selftest(raiz: str) -> int:
    """Autoprueba del clasificador y del resolutor (sin tocar el disco real)."""
    checks = 0
    fallos = 0

    def ok(cond: bool, msg: str) -> None:
        nonlocal checks, fallos
        checks += 1
        if not cond:
            fallos += 1
            print("  FALLO: %s" % msg)

    casos = [
        (".tres", "extension_suelta"),
        ("origin/main", "git_ref"),
        ("user://fotos/", "runtime"),
        ("163/222", "fraccion"),
        ('fijar("vsync", 0/1/2)', "pseudo_codigo"),
        ("cp operativa/x .git/hooks/y", "con_espacios"),
        ("git grep -lP", "con_espacios"),
        ("installer/*.iss", "glob"),
        ("res://scripts/ci/", "esquema"),
        ("scripts/settings/", "directorio"),
        ("scripts/settings/graphics_config.gd", "archivo"),
        ("perf_base.json", "archivo"),
        (".ogg/.wav/.mp3", "lista_extensiones"),
        ("NN-Nombre.md", "plantilla"),
        ("profundidad_min/max", "ruta_sin_extension"),
        ("data/biomes", "ruta_sin_extension"),
    ]
    for token, esperado in casos:
        obtenido = clasificar(token)
        ok(obtenido == esperado, "clasificar(%r) = %r, esperaba %r" % (token, obtenido, esperado))

    ok(limpiar("res://a/b.gd:L42") == "a/b.gd", "limpiar quita esquema y sufijo de linea")
    ok(expandir_globs("data/{a,b}.json") == ["data/a.json", "data/b.json"],
       "expandir_globs expande llaves")

    # resolucion con un universo sintetico
    arch = {"game/isla-ancestral/scripts/x.gd", "a/unico.json"}
    dirs = {"game/isla-ancestral/scripts"}
    pbase: dict[str, list[str]] = collections.defaultdict(list)
    for a in arch:
        pbase[a.split("/")[-1]].append(a)
    ok(resolver("scripts/x.gd", ["game/isla-ancestral/"], False, arch, dirs, pbase)[0] == "exacto",
       "resolver encuentra por base")
    ok(resolver("unico.json", [""], False, arch, dirs, pbase)[0] == "basename",
       "resolver encuentra por basename unico")
    ok(resolver("nada.gd", [""], False, arch, dirs, pbase)[0] == "ausente",
       "resolver declara ausente lo que no existe")
    ok(resolver(".godot/x", [""], False, arch, dirs, pbase)[0] == "excluido",
       "resolver no audita carpetas excluidas")
    ok(resolver("scripts", ["game/isla-ancestral/"], True, arch, dirs, pbase)[0] == "exacto",
       "resolver encuentra directorios")

    # ceguera
    ok(ceguera([]) != [], "ceguera detecta 0 checklists")
    ok(ceguera([{"citas": 0, "estados": {}}]) != [], "ceguera detecta 0 citas")
    ok(ceguera([{"citas": 5, "estados": {"exacto": 5}}]) == [], "ceguera no grita con datos sanos")

    print("=== SELFTEST: %d checks, %d fallos ===" % (checks, fallos))
    return 0 if fallos == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
