#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Detector de scripts duplicados del repo Isla Ancestral (item 35 de la COLA ACTIVA).

Responde tres preguntas distintas, con tres metodos distintos, porque son tres
defectos distintos:

  1. DUPLICADO EXACTO   -> sha256 del archivo. Es el mismo archivo con otro nombre.
  2. DUPLICADO NORMAL   -> huella estructural del AST (Python) o texto normalizado
                           (.ps1). Mismo codigo con distinto formato/comentarios.
  3. FUNCION DUPLICADA  -> misma funcion (nombre + cuerpo normalizado) en >= 2 archivos.
                           Es la duplicacion que no se ve mirando archivos enteros.

Uso:
  python scripts/detectar_duplicados.py                 informe legible
  python scripts/detectar_duplicados.py --json          SOLO JSON (puro)
  python scripts/detectar_duplicados.py --check         exit 1 si hay duplicados EXACTOS
  python scripts/detectar_duplicados.py --check --baseline  compara contra el baseline
  python scripts/detectar_duplicados.py --selftest      fixtures sinteticos

Codigos de salida (convencion del repo, ver skill isla-ancestral-ciclo-modulo):
  0 = limpio / 1 = hallazgos / 2 = uso invalido / 3 = DETECTOR CIEGO

El exit 3 existe porque un detector que no leyo ningun archivo y uno que leyo todo
y no encontro nada imprimen lo mismo: "0 duplicados". Sin la guarda de ceguera el
informe es indistinguible de un aprobado (trampa 91 del skill).
"""

from __future__ import annotations

import argparse
import ast
import hashlib
import io
import json
import os
import re
import sys
import tokenize
import warnings

# `ast.parse` emite SyntaxWarning por escapes invalidos en archivos ajenos y eso
# ensucia el informe (y un `2>&1` lo mete en el medio del texto). No es un
# hallazgo: es ruido del parser sobre codigo que no estamos arreglando.
warnings.filterwarnings("ignore", category=SyntaxWarning)

# --------------------------------------------------------------------------
# Configuracion
# --------------------------------------------------------------------------

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Carpetas que NO se auditan: copias congeladas, respaldos, basura de build y
# dependencias VENDORIZADAS. `.venv`/`site-packages` es lo que separa "duplicados
# del proyecto" de "duplicados de pip": medido el 2026-10-22, incluirlos daba 57
# grupos exactos de los cuales 40 eran `pip/_vendor/rich` copiado por pip mismo.
EXCLUIDOS = (
    ".git",
    ".godot",
    ".kilo",
    ".claude",
    ".venv",
    "venv",
    "site-packages",
    "node_modules",
    ".mypy_cache",
    ".pytest_cache",
    "PAPELERA",
    "Obsoletos",
    "__pycache__",
    "addons",
    "build",
    "out",
    "Logs",
    "DOCUMENTACION",
    "Mensajes entre modelos",
    "game",
    "installer",
    "legal",
    "docs",
    "assets",
)

EXTENSIONES = (".py", ".ps1")

# Un cuerpo de funcion menor a esto no cuenta como duplicacion accionable:
# `return True` aparece 200 veces y no es deuda.
MIN_LINEAS_FUNCION = 8

# Umbral de similitud para el informe de "casi duplicados" (no entra en --check).
UMBRAL_SIMILITUD = 0.90


# --------------------------------------------------------------------------
# Lectura y normalizacion
# --------------------------------------------------------------------------

def es_excluido(ruta_rel: str) -> bool:
    partes = re.split(r"[\\/]", ruta_rel)
    return any(p in EXCLUIDOS for p in partes)


def listar_scripts(raiz: str) -> list[str]:
    """Rutas relativas (con /) de todo .py/.ps1 auditables, ordenadas."""
    encontrados: list[str] = []
    for actual, dirs, archivos in os.walk(raiz):
        dirs[:] = [d for d in dirs if d not in EXCLUIDOS]
        for nombre in archivos:
            if not nombre.endswith(EXTENSIONES):
                continue
            absoluta = os.path.join(actual, nombre)
            relativa = os.path.relpath(absoluta, raiz).replace("\\", "/")
            if es_excluido(relativa):
                continue
            encontrados.append(relativa)
    return sorted(encontrados)


def sha256_bytes(datos: bytes) -> str:
    return hashlib.sha256(datos).hexdigest()


def normalizar_texto(texto: str) -> str:
    """Normalizacion para .ps1 y para el fallback de .py con error de sintaxis.

    Quita comentarios de linea completa, colapsa blancos y baja a minusculas.
    Deliberadamente conservador: NO reordena ni reformatea, porque un falso
    positivo de duplicado cuesta mas que uno que se escapa.
    """
    lineas = []
    for linea in texto.splitlines():
        limpia = linea.strip()
        if not limpia:
            continue
        if limpia.startswith("#"):
            continue
        lineas.append(re.sub(r"\s+", " ", limpia).lower())
    return "\n".join(lineas)


def huella_ast(texto: str) -> tuple[str | None, str]:
    """(huella, motivo). huella None = no se pudo parsear."""
    try:
        arbol = ast.parse(texto)
    except SyntaxError as exc:
        return None, "syntax_error:%s" % exc.msg
    # El dump del AST ignora comentarios, blancos y formato: es la huella
    # estructural. include_attributes=False evita que los numeros de linea
    # entren en el hash (serian duplicados distintos por estar en otra linea).
    volcado = ast.dump(arbol, include_attributes=False)
    return sha256_bytes(volcado.encode("utf-8")), "ast"


def cuerpo_normalizado(nodo: ast.AST) -> str:
    """Huella del cuerpo de una funcion, sin su nombre ni su firma.

    Dos funciones con el mismo cuerpo y distinto nombre SON duplicacion: el
    nombre es lo que cambia, la logica es lo que se repite.
    """
    copia = ast.Module(body=list(getattr(nodo, "body", [])), type_ignores=[])
    return hashlib.sha256(
        ast.dump(copia, include_attributes=False).encode("utf-8")
    ).hexdigest()


def lineas_de(nodo: ast.AST) -> int:
    fin = getattr(nodo, "end_lineno", None)
    ini = getattr(nodo, "lineno", None)
    if fin is None or ini is None:
        return 0
    return fin - ini + 1


# --------------------------------------------------------------------------
# Analisis
# --------------------------------------------------------------------------

def analizar(raiz: str) -> dict:
    rutas = listar_scripts(raiz)
    archivos: dict[str, dict] = {}
    errores_lectura: list[str] = []

    for rel in rutas:
        absoluta = os.path.join(raiz, rel)
        try:
            with open(absoluta, "rb") as fh:
                crudo = fh.read()
        except OSError as exc:
            errores_lectura.append("%s (%s)" % (rel, exc))
            continue
        texto = crudo.decode("utf-8", errors="replace")
        info: dict = {
            "ruta": rel,
            "bytes": len(crudo),
            "sha256": sha256_bytes(crudo),
            "extension": os.path.splitext(rel)[1],
            "huella_normal": None,
            "metodo_normal": None,
            "motivo_fallback": None,
        }
        if info["extension"] == ".py":
            huella, motivo = huella_ast(texto)
            info["huella_normal"] = huella
            info["metodo_normal"] = motivo
            if huella is None:
                # `motivo` es "syntax_error:<msg>": el MOTIVO va aparte para que
                # `metodo_normal` siga siendo un valor cerrado ("ast" | "texto")
                # y el consumidor no tenga que parsear un string compuesto.
                info["motivo_fallback"] = motivo
        if info["huella_normal"] is None:
            normal = normalizar_texto(texto)
            info["huella_normal"] = sha256_bytes(normal.encode("utf-8"))
            info["metodo_normal"] = "texto"
        archivos[rel] = info

    # ---- grupos exactos -------------------------------------------------
    por_sha: dict[str, list[str]] = {}
    for rel, info in archivos.items():
        por_sha.setdefault(info["sha256"], []).append(rel)
    exactos = [
        {"sha256": sha, "rutas": sorted(rs), "bytes": archivos[rs[0]]["bytes"]}
        for sha, rs in por_sha.items()
        if len(rs) > 1
    ]
    exactos.sort(key=lambda g: (-g["bytes"], g["rutas"]))

    # ---- grupos normalizados -------------------------------------------
    por_norm: dict[str, list[str]] = {}
    for rel, info in archivos.items():
        por_norm.setdefault(info["huella_normal"], []).append(rel)
    normalizados = []
    for huella, rs in por_norm.items():
        if len(rs) < 2:
            continue
        # Un grupo cuyos miembros son TODOS byte-identicos ya esta en `exactos`:
        # reportarlo dos veces infla el conteo y no agrega informacion.
        if len({archivos[r]["sha256"] for r in rs}) == 1:
            continue
        normalizados.append(
            {
                "huella": huella,
                "rutas": sorted(rs),
                "metodo": archivos[rs[0]]["metodo_normal"],
            }
        )
    normalizados.sort(key=lambda g: g["rutas"])

    # ---- funciones duplicadas ------------------------------------------
    defs: dict[str, list[dict]] = {}
    sin_parsear: list[str] = []
    for rel, info in archivos.items():
        if info["extension"] != ".py":
            continue
        if info["metodo_normal"] != "ast":
            sin_parsear.append(rel)
            continue
        try:
            with open(os.path.join(raiz, rel), "r", encoding="utf-8", errors="replace") as fh:
                arbol = ast.parse(fh.read())
        except (OSError, SyntaxError):
            sin_parsear.append(rel)
            continue
        for nodo in ast.walk(arbol):
            if not isinstance(nodo, (ast.FunctionDef, ast.AsyncFunctionDef)):
                continue
            largo = lineas_de(nodo)
            if largo < MIN_LINEAS_FUNCION:
                continue
            defs.setdefault(cuerpo_normalizado(nodo), []).append(
                {"ruta": rel, "nombre": nodo.name, "lineas": largo}
            )
    funciones = []
    for huella, apariciones in defs.items():
        if len({a["ruta"] for a in apariciones}) < 2:
            continue
        funciones.append(
            {
                "huella": huella,
                "apariciones": sorted(apariciones, key=lambda a: (a["ruta"], a["linea"] if "linea" in a else 0)),
                "archivos": sorted({a["ruta"] for a in apariciones}),
                "lineas": max(a["lineas"] for a in apariciones),
            }
        )
    funciones.sort(key=lambda g: (-g["lineas"], g["archivos"]))

    # ---- nombres de archivo repetidos ----------------------------------
    por_nombre: dict[str, list[str]] = {}
    for rel in archivos:
        por_nombre.setdefault(os.path.basename(rel).lower(), []).append(rel)
    nombres = [
        {"nombre": n, "rutas": sorted(rs)}
        for n, rs in por_nombre.items()
        if len(rs) > 1
    ]
    nombres.sort(key=lambda g: g["nombre"])

    return {
        "raiz": raiz,
        "archivos_auditados": len(archivos),
        "errores_lectura": errores_lectura,
        "sin_parsear": sorted(sin_parsear),
        "exactos": exactos,
        "normalizados": normalizados,
        "funciones": funciones,
        "nombres_repetidos": nombres,
        "archivos": archivos,
    }


def ceguera(inf: dict) -> list[str]:
    """Motivos por los que el detector NO midio nada (exit 3)."""
    motivos = []
    if inf["archivos_auditados"] == 0:
        motivos.append("no se leyo ningun script .py/.ps1")
    if inf["archivos_auditados"] > 0 and not inf["archivos"]:
        motivos.append("el mapa de archivos quedo vacio")
    # Un .py que no parsea es un script que el detector no puede comparar
    # estructuralmente: si NINGUNO parsea, el metodo 2 y el 3 son ciegos.
    py = [r for r, i in inf["archivos"].items() if i["extension"] == ".py"]
    if py and all(i["metodo_normal"] != "ast" for i in inf["archivos"].values()):
        motivos.append("ningun .py se pudo parsear: metodos 2 y 3 ciegos")
    return motivos


# --------------------------------------------------------------------------
# Salida
# --------------------------------------------------------------------------

def informe_texto(inf: dict) -> str:
    out = io.StringIO()
    w = out.write
    w("=== DETECTOR DE DUPLICADOS ===\n")
    w("raiz: %s\n" % inf["raiz"])
    w("archivos auditados: %d\n" % inf["archivos_auditados"])
    if inf["errores_lectura"]:
        w("ERRORES DE LECTURA: %d\n" % len(inf["errores_lectura"]))
        for e in inf["errores_lectura"]:
            w("  ! %s\n" % e)
    if inf["sin_parsear"]:
        w("sin parsear (metodo texto): %d -> %s\n" % (
            len(inf["sin_parsear"]), ", ".join(inf["sin_parsear"][:8])))
    w("\n-- 1. DUPLICADOS EXACTOS (sha256): %d grupo(s)\n" % len(inf["exactos"]))
    for g in inf["exactos"]:
        w("  [%d B] %s\n" % (g["bytes"], g["sha256"][:12]))
        for r in g["rutas"]:
            w("      %s\n" % r)
    w("\n-- 2. DUPLICADOS NORMALIZADOS (mismo codigo, distinto formato): %d grupo(s)\n"
      % len(inf["normalizados"]))
    for g in inf["normalizados"]:
        w("  [%s] %s\n" % (g["metodo"], g["huella"][:12]))
        for r in g["rutas"]:
            w("      %s\n" % r)
    w("\n-- 3. FUNCIONES DUPLICADAS (mismo cuerpo, >= %d lineas, >= 2 archivos): %d grupo(s)\n"
      % (MIN_LINEAS_FUNCION, len(inf["funciones"])))
    for g in inf["funciones"]:
        w("  [%d lineas] %s\n" % (g["lineas"], ", ".join(a["nombre"] for a in g["apariciones"])))
        for a in g["apariciones"]:
            w("      %s :: %s\n" % (a["ruta"], a["nombre"]))
    w("\n-- 4. NOMBRES DE ARCHIVO REPETIDOS: %d\n" % len(inf["nombres_repetidos"]))
    for g in inf["nombres_repetidos"]:
        w("  %s\n" % g["nombre"])
        for r in g["rutas"]:
            w("      %s\n" % r)
    w("\n=== TOTALES: %d exactos | %d normalizados | %d funciones | %d nombres ===\n" % (
        len(inf["exactos"]), len(inf["normalizados"]), len(inf["funciones"]),
        len(inf["nombres_repetidos"])))
    return out.getvalue()


def salida_json(inf: dict) -> str:
    """JSON PURO: nada mas que el objeto (un `--json` que imprime avisos extra
    rompe a cualquier consumidor con `Extra data`)."""
    publico = {k: v for k, v in inf.items() if k != "archivos"}
    publico["firmas"] = firmas(inf)
    return json.dumps(publico, ensure_ascii=False, indent=2, sort_keys=True)


def firmas(inf: dict) -> list[str]:
    """Firmas estables de los duplicados EXACTOS: es lo unico que gatea."""
    return sorted(
        "%s|%d" % (" + ".join(g["rutas"]), g["bytes"]) for g in inf["exactos"]
    )


# --------------------------------------------------------------------------
# Selftest (fixtures sinteticos, sin tocar el repo)
# --------------------------------------------------------------------------

def selftest() -> int:
    import tempfile

    ok = 0
    total = 0

    def chequear(cond, nombre):
        nonlocal ok, total
        total += 1
        if cond:
            ok += 1
        else:
            print("[FALLO] %s" % nombre)

    with tempfile.TemporaryDirectory() as tmp:
        def escribir(rel, contenido):
            destino = os.path.join(tmp, rel)
            os.makedirs(os.path.dirname(destino), exist_ok=True)
            with open(destino, "w", encoding="utf-8", newline="\n") as fh:
                fh.write(contenido)

        # A) dos archivos byte-identicos -> exacto
        cuerpo = "def suma(a, b):\n    total = a + b\n    return total\n"
        escribir("dup_a.py", cuerpo)
        escribir("dup_b.py", cuerpo)

        # B) mismo codigo, distinto formato y comentarios -> normalizado, NO exacto
        escribir("fmt_a.py", "def resta(a, b):\n    return a - b\n")
        escribir("fmt_b.py", "# comentario distinto\n\ndef resta(a,b):\n\n    return a - b\n")

        # C) dos funciones con el mismo cuerpo en archivos distintos -> funcion duplicada
        largo = (
            "def calcular_total(items):\n"
            "    total = 0\n"
            "    for it in items:\n"
            "        precio = it.get('precio', 0)\n"
            "        cant = it.get('cantidad', 1)\n"
            "        total += precio * cant\n"
            "    total = round(total, 2)\n"
            "    return total\n"
        )
        escribir("fn_a.py", largo + "\n\ndef otro():\n    return 1\n")
        escribir("fn_b.py", largo.replace("calcular_total", "sumar_todo") + "\n")

        # D) control negativo: dos funciones CORTAS iguales NO cuentan
        corto = "def f(x):\n    return x + 1\n"
        escribir("corto_a.py", corto)
        escribir("corto_b.py", corto)

        # E) control negativo: funcion con el mismo NOMBRE pero cuerpo distinto
        escribir("nom_a.py", "def procesar(d):\n    return d.get('a')\n")
        escribir("nom_b.py", "def procesar(d):\n    return d.get('b')\n")

        # F) un .py con error de sintaxis cae a metodo texto, no rompe el barrido
        escribir("roto.py", "def yet_otro(:\n")

        # G) carpeta excluida no se audita
        escribir("PAPELERA/dup_a.py", cuerpo)

        inf = analizar(tmp)
        rutas = set(inf["archivos"])

        chequear(inf["archivos_auditados"] > 0, "leyo archivos")
        chequear("dup_a.py" in rutas and "dup_b.py" in rutas, "indexo dup_a/dup_b")
        chequear("PAPELERA/dup_a.py" not in rutas, "excluyo PAPELERA")

        exactos = [g for g in inf["exactos"] if "dup_a.py" in g["rutas"]]
        chequear(len(exactos) == 1, "detecto 1 grupo exacto dup_a/dup_b")
        chequear(
            exactos and exactos[0]["rutas"] == ["dup_a.py", "dup_b.py"],
            "el grupo exacto tiene las 2 rutas",
        )

        normales = [g for g in inf["normalizados"] if "fmt_a.py" in g["rutas"]]
        chequear(len(normales) == 1, "detecto fmt_a/fmt_b como normalizado")
        chequear(
            normales and normales[0]["rutas"] == ["fmt_a.py", "fmt_b.py"],
            "el grupo normalizado tiene las 2 rutas",
        )
        chequear(
            not any("fmt_a.py" in g["rutas"] for g in inf["exactos"]),
            "fmt_a/fmt_b NO son exactos (distinto sha)",
        )

        funcs = [g for g in inf["funciones"] if "fn_a.py" in g["archivos"]]
        chequear(len(funcs) == 1, "detecto 1 cuerpo de funcion duplicado fn_a/fn_b")
        chequear(
            funcs and funcs[0]["archivos"] == ["fn_a.py", "fn_b.py"],
            "la funcion duplicada esta en fn_a y fn_b",
        )
        chequear(
            funcs and {a["nombre"] for a in funcs[0]["apariciones"]}
            == {"calcular_total", "sumar_todo"},
            "reconoce el mismo cuerpo con OTRO nombre",
        )

        chequear(
            not any("corto_a.py" in g["archivos"] for g in inf["funciones"]),
            "control negativo: funcion corta no cuenta como duplicada",
        )
        chequear(
            not any("nom_a.py" in g["archivos"] for g in inf["funciones"]),
            "control negativo: mismo nombre, distinto cuerpo, no es duplicado",
        )

        roto = inf["archivos"].get("roto.py")
        chequear(roto is not None, "indexo el archivo con error de sintaxis")
        chequear(
            roto is not None and roto["metodo_normal"] == "texto",
            "el .py ilegible cae a metodo texto",
        )
        chequear("roto.py" in inf["sin_parsear"], "reporta roto.py como no parseado")

        chequear(ceguera(inf) == [], "sin motivos de ceguera con archivos leidos")

        # H) guarda de ceguera: carpeta vacia -> exit 3
        with tempfile.TemporaryDirectory() as vacia:
            chequear(ceguera(analizar(vacia)) != [], "carpeta vacia dispara ceguera")

        # I) --json es PURO: parseable tal cual
        crudo = salida_json(inf)
        try:
            cargado = json.loads(crudo)
            parsea = True
        except ValueError:
            cargado = {}
            parsea = False
        chequear(parsea, "--json es JSON puro (parseable entero)")
        chequear("firmas" in cargado, "--json incluye las firmas")
        chequear("archivos" not in cargado, "--json no vuelca el mapa interno")

        # J) la firma es estable entre corridas
        chequear(firmas(inf) == firmas(analizar(tmp)), "las firmas son estables")

        # K) una copia extra del mismo archivo aparece como firma NUEVA
        escribir("dup_c.py", cuerpo)
        inf2 = analizar(tmp)
        chequear(
            firmas(inf2) != firmas(inf),
            "agregar una 3a copia cambia la firma (el gate la veria)",
        )

    print("=== selftest: %d/%d OK ===" % (ok, total))
    return 0 if ok == total else 1


# --------------------------------------------------------------------------
# CLI
# --------------------------------------------------------------------------

def leer_baseline(ruta: str) -> dict[str, str]:
    """Devuelve {firma: motivo}. Acepta el formato viejo (lista) por compatibilidad.

    El motivo es obligatorio: una firma aceptada sin justificacion es deuda que
    nadie puede revisar (misma regla que `DEUDA_CONOCIDA` de `metricas_bugs.py`).
    """
    with open(ruta, "r", encoding="utf-8") as fh:
        datos = json.load(fh)
    crudo = datos.get("firmas", {})
    if isinstance(crudo, list):
        return {str(f): "" for f in crudo}
    return {str(k): str(v) for k, v in crudo.items()}


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(description="Detector de scripts duplicados")
    ap.add_argument("--raiz", default=RAIZ, help="raiz a auditar")
    ap.add_argument("--json", action="store_true", help="salida JSON pura")
    ap.add_argument("--check", action="store_true", help="exit 1 si hay duplicados exactos")
    ap.add_argument("--baseline", help="archivo JSON con firmas aceptadas y su motivo")
    ap.add_argument("--escribir-baseline", help="guarda las firmas actuales en ese archivo")
    ap.add_argument("--selftest", action="store_true", help="fixtures sinteticos")
    args = ap.parse_args(argv)

    if args.selftest:
        return selftest()

    if not os.path.isdir(args.raiz):
        print("uso invalido: no existe la raiz %s" % args.raiz, file=sys.stderr)
        return 2

    inf = analizar(args.raiz)

    motivos = ceguera(inf)
    if motivos:
        print("DETECTOR CIEGO (exit 3):", file=sys.stderr)
        for m in motivos:
            print("  - %s" % m, file=sys.stderr)
        return 3

    if args.escribir_baseline:
        # Conserva los motivos ya escritos: re-generar el baseline no debe borrar
        # las justificaciones (el gate volveria a nacer mudo).
        previos: dict[str, str] = {}
        if os.path.isfile(args.escribir_baseline):
            try:
                previos = leer_baseline(args.escribir_baseline)
            except (ValueError, OSError):
                previos = {}
        nuevas = {f: previos.get(f, "") for f in firmas(inf)}
        with open(args.escribir_baseline, "w", encoding="utf-8", newline="\n") as fh:
            json.dump({"firmas": nuevas}, fh, ensure_ascii=False, indent=2, sort_keys=True)
            fh.write("\n")
        sin_motivo = [f for f, m in nuevas.items() if not m]
        print("baseline escrito: %s (%d firmas, %d sin motivo)" % (
            args.escribir_baseline, len(nuevas), len(sin_motivo)))
        for f in sin_motivo:
            print("  ? %s" % f)
        return 0

    if args.json:
        print(salida_json(inf))
        return 0

    print(informe_texto(inf))

    if not args.check:
        return 0

    actuales = set(firmas(inf))
    aceptadas = leer_baseline(args.baseline) if args.baseline and os.path.isfile(args.baseline) else {}

    nuevas = sorted(actuales - set(aceptadas))
    obsoletas = sorted(set(aceptadas) - actuales)
    problemas = 0

    if nuevas:
        problemas += len(nuevas)
        print("\n[FALLO] %d duplicado(s) exacto(s) NO declarados en el baseline:" % len(nuevas))
        for f in nuevas:
            print("  + %s" % f)
    if obsoletas:
        # Una deuda que ya no existe deja el baseline podrido: si no se reporta,
        # en tres meses nadie sabe cuales de las firmas siguen siendo reales.
        problemas += len(obsoletas)
        print("\n[FALLO] %d firma(s) del baseline ya NO son duplicados (baseline obsoleto):" % len(obsoletas))
        for f in obsoletas:
            print("  - %s" % f)
    if problemas:
        return 1

    print("\n[OK] sin duplicados exactos nuevos ni firmas obsoletas (%d declarados)" % len(aceptadas))
    return 0


def _correr(argv: list[str]) -> tuple[int, str]:
    """Corre `main()` capturando stdout y el codigo de salida.

    Existe para que la suite pueda asertar sobre el EFECTO (codigo + texto) y no
    sobre el texto solo: un gate que imprime "FALLO" y sale 0 se ve igual que uno
    que falla de verdad si solo miras el texto.
    """
    import contextlib

    buf = io.StringIO()
    codigo = 0
    with contextlib.redirect_stdout(buf), contextlib.redirect_stderr(io.StringIO()):
        try:
            codigo = main(argv)
        except SystemExit as exc:  # argparse
            codigo = int(exc.code or 0)
    return codigo, buf.getvalue()


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
