#!/usr/bin/env python3
"""Audita autocontradicciones en los 05-Checklist.md: item marcado [x] cuya nota
dice, con sus propias palabras, que el artefacto NO existe / esta inflado / sigue pendiente.

Motivo (TANDA 7, msg 467 de agnes-3-flash): el caso M85 (26 items [x] con nota
"INFLADO"/"los artefactos NO existen") se detecto a mano. Este auditor barre los
168 checklists de plan-actual y clasifica cada candidato.

Reglas (se aplican SOLO a la NOTA del item, no a la descripcion: la descripcion
puede decir "sin implementar" porque es el enunciado del requisito).

  A1 INFLADO            inflad[oa]s?
  A2 NO_EXISTE_DISCO    "no existe(n) en disco"
  A3 ARTEFACTO_NO_EXISTE (artefacto|archivo|script|modulo|funcion|metodo|suite|carpeta|
                          interfaz|autoload) ... no exist / inexistente
  A4 INEXISTENTE        inexistente
  A5 SIN_CODIGO_DISCO   "sin codigo en disco"
  A6 PENDIENTE_REAL     "pendiente real"
  A7 DEGRADADO          degradad[oa]s?   (si la nota dice degradado y la marca sigue [x])

Clasificacion:
  AUTOCONTRADICCION  veredicto negativo y NINGUNA marca de restauracion/cierre posterior
  MIXTO              veredicto negativo + marca positiva posterior (flip/restaurado/corregido):
                     puede ser legitimo, hay que leerlo
  LIMPIO             sin veredicto negativo

Codigos de salida: 0 sin hallazgos | 1 hallazgos | 2 uso | 3 DETECTOR CIEGO.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
import unicodedata
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
GLOB = "DOCUMENTACION/*/plan-actual/05-Checklist.md"

RE_ITEM = re.compile(r"^(\s*)- \[([x ?])\] (.*)$")
SEPARADORES = [" \u2014 ", " | ", " \u2192 ", " -- ", " - "]

REGLAS = [
    ("A1", "INFLADO", r"inflad[oa]s?", "A"),
    ("A2", "NO_EXISTE_DISCO", r"no exist\w* en disco", "A"),
    # OJO: el "hueco" entre el sustantivo y el verbo no puede cruzar fin de frase (". ")
    # pero SI tiene que aceptar nombres de archivo con punto ("el archivo `x.gd` no existe").
    ("A3", "ARTEFACTO_NO_EXISTE",
     r"(?:artefact\w*|archivo\w*|script\w*|modulo\w*|funcion\w*|metodo\w*|suite\w*|"
     r"carpeta\w*|interfaz\w*|autoload\w*)s?(?:(?!\. )[^;]){0,60}?(?:no exist|inexist)", "A"),
    ("A5", "SIN_CODIGO_DISCO", r"sin c[oó]digo en disco", "A"),
    ("A6", "PENDIENTE_REAL", r"pendiente real", "A"),
    ("A7", "DEGRADADO", r"\bdegradad[oa]s?\b", "A"),
    ("A8", "PENDIENTE_EJECUCION", r"pendiente de ejecucion", "A"),
    # sola, "inexistente" es demasiado ambigua: describe comportamiento, validaciones y
    # fallbacks legitimos ("rechazo por sello inexistente", "prueba stats inexistentes").
    ("B1", "INEXISTENTE", r"\binexistente", "B"),
]

# Frases que contienen el lexema pero NO son un veredicto sobre el artefacto del item
# (falso positivo medido: M95 L139/L193 "sin precio inflado para rebajas" es el REQUISITO;
#  M140 "No inflado." es la negacion explicita de la inflacion).
LIMPIAR = [
    (re.compile(r"des-?inflad\w*"), " "),
    (re.compile(r"sin (?:precios? )?inflad\w*"), " "),
    (re.compile(r"precios? inflad\w*"), " "),
    (re.compile(r"anti-?inflad\w*"), " "),
    (re.compile(r"no inflad\w*"), " "),
]

# Contexto que delata una DESCRIPCION de comportamiento en vez de un veredicto (B1 y A3).
RE_COMPORTAMIENTO = re.compile(
    # La flecha excluye notas de DERIVACION ("-> agnes-2.5-flash ..."), pero la misma
    # flecha aparece en los FLIPS ("`[?]`->`[x]`"). Sin el lookahead, un item con flip
    # quedaba excluido y la autocontradiccion se perdia (falso NEGATIVO medido 2026-10-30).
    r"rechazo|valid\w|prueba|test|cubre|si |cuando |delegad|fallback|edge|"
    r"(?:->|\u2192)(?!\s*`?\[x\])|maneja"
)

# "degradada" tambien describe TEXTURAS/mallas (falso positivo medido: M62 L219
# "la textura degradada mide la mitad"), no la marca del item.
RE_DEGRADACION_TECNICA = re.compile(r"textura|malla|calidad|rendimiento|resolucion|mipmap|shader")

# Nota de lote: habla de las correcciones de OTROS items ("LOTE B integral del director
# (msg 235): #6 M40 SIN-DATOS degradado"). El veredicto no es sobre este item.
RE_NOTA_DE_LOTE = re.compile(r"lote\s+\w+\s+integral|\(#\d")

# Marcas de que el veredicto negativo fue CERRADO despues (flip, restauracion, fix medido).
RE_POSITIVO = re.compile(
    r"flip|\brevert|revertid|restaurad|reverificad|corregid|cerrad|completad|aprobad|"
    r"(?<!no )implementad|se mantiene|"
    # El cierre puede venir con backticks o asteriscos entre corchetes y flecha:
    # "Marcado `[?]`→`[x]`" (M65 L115) no casaba con la version estricta y el item
    # se reportaba como autocontradiccion. Medido 2026-10-30.
    r"\[\?\]`?\s*(?:->|\u2192)\s*`?\[x\]|\[\s\]`?\s*(?:->|\u2192)\s*`?\[x\]|"
    r"normalizad\w* a \[x\]|resuelto|sanead|"
    # "· evidencia: <ruta> creado/creada (Reflection-Beam ...)": el artefacto se creo
    # DESPUES del veredicto negativo, que queda como historico. Solo cuenta si dice
    # "creado/a"; "evidencia: documentado en plan-actual" NO cierra nada (spec-only).
    r"evidencia:[^\u00b7]{0,160}?\bcread[oa]s?\b"
)


def sin_acento(texto: str) -> str:
    return "".join(
        c for c in unicodedata.normalize("NFD", texto)
        if unicodedata.category(c) != "Mn"
    ).lower()


def partir_nota(texto: str) -> str:
    """Devuelve la nota (desde el primer separador) o '' si no hay separador."""
    cortes = [texto.find(s) for s in SEPARADORES if texto.find(s) != -1]
    return texto[min(cortes):] if cortes else ""


def items_de(ruta: Path):
    """(linea, marca, texto) agrupando las lineas de continuacion de cada item."""
    lineas = ruta.read_text(encoding="utf-8", errors="replace").split("\n")
    salida, actual = [], None
    for i, linea in enumerate(lineas, 1):
        m = RE_ITEM.match(linea)
        if m:
            if actual:
                salida.append(actual)
            actual = [i, m.group(2), m.group(3)]
        elif actual is not None:
            s = linea.strip()
            if s.startswith("#") or s.startswith("|") or s == "":
                salida.append(actual)
                actual = None
            else:
                actual[2] += " " + s
    if actual:
        salida.append(actual)
    return salida


def clasificar(nota: str):
    """Devuelve (clase, [ids de regla], fragmento).

    AUTOCONTRADICCION: regla de tier A (veredicto sobre el propio artefacto) sin cierre posterior.
    SOSPECHOSO:        solo reglas de tier B (ambiguas) sin cierre posterior.
    MIXTO:             veredicto negativo + marca de cierre posterior (leer, puede ser legitimo).
    """
    n = sin_acento(nota)
    for pat, rep in LIMPIAR:
        n = pat.sub(rep, n)
    ids_a = []
    for rid, _, pat, tier in REGLAS:
        if tier != "A" or not re.search(pat, n):
            continue
        if rid == "A7" and RE_DEGRADACION_TECNICA.search(n):
            continue
        if rid == "A3" and RE_COMPORTAMIENTO.search(n):
            continue
        if rid == "A7" and RE_NOTA_DE_LOTE.search(n):
            continue
        ids_a.append(rid)
    ids_b = [rid for rid, _, pat, tier in REGLAS
             if tier == "B" and re.search(pat, n) and not RE_COMPORTAMIENTO.search(n)]
    ids = ids_a + ids_b
    if not ids:
        return None, [], ""
    if RE_POSITIVO.search(n):
        clase = "MIXTO"
    elif ids_a:
        clase = "AUTOCONTRADICCION"
    else:
        clase = "SOSPECHOSO"
    return clase, ids, nota.strip()[:220]


def auditar(raiz: Path):
    archivos = sorted(raiz.glob(GLOB))
    hallazgos = []
    total_items = 0
    total_x = 0
    for f in archivos:
        modulo = f.parts[-3].split("-")[0]
        for linea, marca, texto in items_de(f):
            total_items += 1
            if marca != "x":
                continue
            total_x += 1
            clase, ids, frag = clasificar(partir_nota(texto))
            if clase:
                hallazgos.append({
                    "modulo": modulo,
                    "archivo": str(f.as_posix()),
                    "linea": linea,
                    "clase": clase,
                    "reglas": ids,
                    "nota": frag,
                    "descripcion": texto.split(" " + "\u2014" + " ")[0][:120],
                })
    return {
        "archivos": len(archivos),
        "items": total_items,
        "items_x": total_x,
        "hallazgos": hallazgos,
    }


def evaluar_ceguera(datos) -> list:
    motivos = []
    if datos["archivos"] == 0:
        motivos.append("no se encontro ningun 05-Checklist.md en plan-actual/")
    if datos["items"] == 0:
        motivos.append("se leyeron 0 items (parser roto o archivos vacios)")
    if datos["archivos"] and datos["items_x"] == 0:
        motivos.append("0 items con marca [x]: el detector no ve las marcas")
    return motivos


def main() -> int:
    ap = argparse.ArgumentParser(description="Audita [x] autocontradictorios en los 05-Checklist.md")
    ap.add_argument("--json", action="store_true", help="salida JSON pura")
    ap.add_argument("--selftest", action="store_true", help="prueba del detector con fixtures")
    ap.add_argument("--raiz", default=str(RAIZ), help="raiz del repo")
    ap.add_argument("--solo-clase", default="", help="filtrar por clase")
    args = ap.parse_args()

    if args.selftest:
        return selftest()

    datos = auditar(Path(args.raiz))
    ciegos = evaluar_ceguera(datos)
    if ciegos:
        if args.json:
            print(json.dumps({"ciego": ciegos}, ensure_ascii=False))
        else:
            for m in ciegos:
                print("DETECTOR CIEGO:", m)
        return 3

    hallazgos = datos["hallazgos"]
    if args.solo_clase:
        hallazgos = [h for h in hallazgos if h["clase"] == args.solo_clase]

    auto = [h for h in hallazgos if h["clase"] == "AUTOCONTRADICCION"]
    mixto = [h for h in hallazgos if h["clase"] == "MIXTO"]
    sospechoso = [h for h in hallazgos if h["clase"] == "SOSPECHOSO"]

    if args.json:
        print(json.dumps({
            "archivos": datos["archivos"],
            "items": datos["items"],
            "items_x": datos["items_x"],
            "autocontradiccion": len(auto),
            "mixto": len(mixto),
            "sospechoso": len(sospechoso),
            "hallazgos": hallazgos,
        }, ensure_ascii=False, indent=2))
        return 1 if hallazgos else 0

    print(f"checklists leidos      : {datos['archivos']}")
    print(f"items totales          : {datos['items']}")
    print(f"items [x]              : {datos['items_x']}")
    print(f"AUTOCONTRADICCION      : {len(auto)}")
    print(f"MIXTO (leer)           : {len(mixto)}")
    print(f"SOSPECHOSO (ambiguo)   : {len(sospechoso)}")
    print()
    for h in auto + mixto + sospechoso:
        print(f"[{h['clase'][:4]}] M{h['modulo']} L{h['linea']} {','.join(h['reglas'])}")
        print(f"        {h['nota']}")
    return 1 if hallazgos else 0


# ---------------------------------------------------------------- selftest

FIXTURE_SUCIO = """# Checklist fixture
- [x] Item con nota inflada [S] \u2014 INFLADO: el archivo no existe
- [x] Item con artefacto ausente [M] \u2014 los artefactos pasivos no existen (verificado)
- [x] Item degradado sin cierre [S] \u2014 DEGRADADO 2026-10-14: 0 hits
- [x] Item con nota partida [S] \u2014 PENDIENTE REAL 2026-10-14: verificado contra disco
  y el autoload `Almanaque` no existe en scripts/
- [x] Item con flip documentado [M] \u2014 estaba INFLADO; FLIP 2026-10-26: artefacto creado
- [ ] Item pendiente con la misma nota \u2014 INFLADO: no existe
- [?] Item dudoso \u2014 INFLADO: no existe
"""

FIXTURE_LIMPIO = """# Checklist fixture
- [x] Item correcto [S] \u2014 verificado en disco: scripts/x.gd L12
- [x] Item con flip documentado [S] \u2014 estaba INFLADO; FLIP 2026-10-26: artefacto creado
- [x] Requisito que menciona inexistente en la DESCRIPCION sin implementar [S] \u2014 hecho
- [x] Item con nota "sin precio inflado para rebajas" [S] \u2014 evidencia: 02-Analisis D5
"""


FIXTURE_AMBIGUO = """# Checklist fixture
- [x] Item con sello [S] \u2014 rechazo por sello inexistente, validado en test
- [x] Item con archivo [S] \u2014 el archivo `x.gd` no existe en el arbol
"""


# Fixture de los DOS patrones de cierre que el detector no veia (medido 2026-10-30
# sobre M137 L11/L13/L15/L17 y M65 L115: 5 falsos positivos reales).
FIXTURE_CIERRE = """# Checklist fixture
- [x] Item creado despues del veredicto [S] \u2014 PENDIENTE REAL: no existe `x.gd` \u00b7 evidencia: scripts/prototipo/x.gd creado (Reflection-Beam-1.0, T49, 2026-10-22)
- [x] Item con flip entre backticks [S] \u2014 degradado [x]->[?] por BUG-080. Marcado `[?]`\u2192`[x]` al re-verificar.
- [x] Item con evidencia documental, NO artefacto [S] \u2014 PENDIENTE REAL: no existe en disco \u00b7 evidencia: documentado en plan-actual
"""


def selftest() -> int:
    import tempfile

    checks = 0
    fallos = 0

    def chk(cond, msg):
        nonlocal checks, fallos
        checks += 1
        if not cond:
            fallos += 1
            print("  [FALLO]", msg)

    with tempfile.TemporaryDirectory() as tmp:
        base = Path(tmp)
        for nombre, contenido in (("sucia", FIXTURE_SUCIO), ("limpia", FIXTURE_LIMPIO),
                                  ("ambigua", FIXTURE_AMBIGUO),
                                  ("cierre", FIXTURE_CIERRE)):
            d = base / nombre / "DOCUMENTACION" / "99-Fixture" / "plan-actual"
            d.mkdir(parents=True)
            (d / "05-Checklist.md").write_text(contenido, encoding="utf-8")

        datos = auditar(base / "sucia")
        auto = [h for h in datos["hallazgos"] if h["clase"] == "AUTOCONTRADICCION"]
        mixto = [h for h in datos["hallazgos"] if h["clase"] == "MIXTO"]
        chk(datos["archivos"] == 1, "lee 1 checklist del fixture sucio")
        chk(datos["items"] == 7, f"cuenta 7 items (leyo {datos['items']})")
        chk(datos["items_x"] == 5, f"cuenta 5 items [x] (leyo {datos['items_x']})")
        chk(len(auto) == 4, f"detecta 4 autocontradicciones (detecto {len(auto)})")
        chk(len(mixto) == 1, f"clasifica 1 MIXTO (clasifico {len(mixto)})")
        lineas = sorted(h["linea"] for h in auto)
        chk(lineas == [2, 3, 4, 5], f"lineas exactas [2,3,4,5] (midio {lineas})")
        # la nota partida en 2 lineas (L5-6) debe entrar como 1 sola
        chk(any(h["linea"] == 5 and "Almanaque" in h["nota"] for h in auto),
            "la nota partida en dos lineas se une y se detecta")
        chk(mixto and mixto[0]["linea"] == 7, "el MIXTO es la linea 7 (nota con FLIP)")
        # [ ] y [?] NO cuentan
        chk(all(h["linea"] not in (8, 9) for h in auto + mixto),
            "las marcas [ ] y [?] no se reportan")

        datos = auditar(base / "limpia")
        chk(datos["archivos"] == 1, "lee 1 checklist del fixture limpio")
        # el unico hit es el item con FLIP documentado: se clasifica MIXTO (para leer),
        # NUNCA como autocontradiccion. Es el control de falsos positivos.
        chk(len(datos["hallazgos"]) == 1,
            f"fixture limpio da 1 hallazgo MIXTO (dio {len(datos['hallazgos'])})")
        chk(all(h["clase"] == "MIXTO" for h in datos["hallazgos"]),
            "el item con FLIP documentado NO se clasifica como autocontradiccion")

        # control negativo del vocabulario: "sin precio inflado" (requisito) no dispara
        chk(clasificar(" \u2014 evidencia: 02-Analisis D5 (sin precio inflado)")[0] is None,
            "la frase 'sin precio inflado' no dispara A1")
        # "No inflado." es la negacion de la inflacion, no un veredicto negativo
        chk(clasificar(" \u2014 deuda real documentada. No inflado.")[0] is None,
            "la frase 'No inflado.' no dispara A1")

        datos = auditar(base / "ambigua")
        chk(len(datos["hallazgos"]) == 1,
            f"fixture ambiguo da 1 hallazgo (dio {len(datos['hallazgos'])})")
        chk(all(h["clase"] == "AUTOCONTRADICCION" for h in datos["hallazgos"]),
            "el veredicto sobre un archivo entra como AUTOCONTRADICCION")
        chk(bool(datos["hallazgos"]) and datos["hallazgos"][0]["linea"] == 3,
            "el hit es la linea 3: el 'inexistente' de comportamiento (L2) queda fuera")

        # ---- fixture de los patrones de cierre (5 FP reales medidos 2026-10-30)
        datos = auditar(base / "cierre")
        auto_c = [h for h in datos["hallazgos"] if h["clase"] == "AUTOCONTRADICCION"]
        chk(len(auto_c) == 1,
            f"fixture cierre da 1 sola autocontradiccion (dio {len(auto_c)})")
        chk(auto_c and auto_c[0]["linea"] == 4,
            "la unica autocontradiccion es la L4 ('evidencia: documentado' no cierra nada)")
        chk(any(h["linea"] == 2 for h in datos["hallazgos"]),
            "L2 ('evidencia: ... creado') se ve, pero NO como autocontradiccion")
        chk(any(h["linea"] == 3 for h in datos["hallazgos"]),
            "L3 (flip entre backticks) se ve, pero NO como autocontradiccion")
        chk(clasificar(" \u2014 el archivo `x.gd` no existe. \u00b7 evidencia: scripts/x.gd creado (Beam)")[0]
            == "MIXTO",
            "el cierre 'evidencia: <ruta> creado' cuenta como MIXTO")
        chk(clasificar(" \u2014 el archivo `x.gd` no existe. \u00b7 evidencia: documentado en plan-actual")[0]
            == "AUTOCONTRADICCION",
            "'evidencia: documentado en plan-actual' NO cierra: sigue siendo autocontradiccion")
        chk(clasificar(" \u2014 el artefacto no existe. Marcado `[?]`\u2192`[x]` al re-verificar")[0]
            == "MIXTO",
            "el flip entre backticks cuenta como MIXTO")

        # guarda de ceguera: directorio sin checklists
        vacio = base / "vacio"
        vacio.mkdir()
        chk(evaluar_ceguera(auditar(vacio)) != [], "directorio vacio -> DETECTOR CIEGO")

        # ceguera por archivo vacio
        d = base / "enblanco" / "DOCUMENTACION" / "98-Vacio" / "plan-actual"
        d.mkdir(parents=True)
        (d / "05-Checklist.md").write_text("", encoding="utf-8")
        chk(evaluar_ceguera(auditar(base / "enblanco")) != [], "checklist de 0 bytes -> DETECTOR CIEGO")

        # ceguera: archivo con items pero sin ninguna marca [x]
        d2 = base / "sinx" / "DOCUMENTACION" / "97-SinX" / "plan-actual"
        d2.mkdir(parents=True)
        (d2 / "05-Checklist.md").write_text("- [ ] a\n- [ ] b\n", encoding="utf-8")
        chk(evaluar_ceguera(auditar(base / "sinx")) != [], "0 items [x] -> DETECTOR CIEGO")

    print(f"selftest: {checks - fallos}/{checks} OK")
    return 0 if fallos == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
