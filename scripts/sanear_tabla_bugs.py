#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Saneamiento mecanico de DOCUMENTACION/11-BUGS.md: filas que FALTAN en la tabla resumen.

Problema que resuelve (residuo del item 31 / M102): el registro tiene entradas de
detalle (secciones 6, 7 y 8) que nunca se reflejaron en la tabla resumen de la
seccion 5. El medidor `scripts/metricas_bugs.py` las declara como
`entrada_sin_fila`. Escribir 45 filas a mano es donde se cuelan los errores, asi
que se generan por transcripcion y se validan antes de tocar el archivo.

Reglas de diseno (no negociables):

1. **No reimplementa el parser.** Importa `metricas_bugs` y usa
   `leer_registro()` como unica fuente de verdad de QUE falta, y
   `normalizar_estado()` / `normalizar_severidad()` / `_celdas()` para validar
   cada celda generada. Un segundo parser se desincroniza del primero.
2. **Transcribe, no inventa.** Cada celda sale de una etiqueta explicita de la
   entrada (`**Severidad:**`, `**Estado:**`, ...). Si la etiqueta no esta, la
   celda queda vacia o la entrada se OMITE y se reporta. Nunca se deduce el
   estado de la seccion donde vive la entrada.
3. **Diff puramente ADITIVO.** Inserta un bloque nuevo al final de la seccion 5.
   No reescribe, no reordena y no borra ninguna linea existente: si el diff no
   es aditivo, el invariante no vale.
4. **Se mide a si mismo.** Antes de escribir, aplica el cambio en memoria, corre
   el medidor sobre el resultado y ABORTA si aparece una firma de defecto NUEVA
   (arreglar `entrada_sin_fila` y crear `estado_desconocido` seria un retroceso).
5. **Idempotente.** Correrlo dos veces no agrega nada la segunda vez.

Uso:
  python scripts/sanear_tabla_bugs.py              # dry-run: que haria
  python scripts/sanear_tabla_bugs.py --aplicar     # escribe (con validacion previa)
  python scripts/sanear_tabla_bugs.py --check       # exit 1 si queda trabajo aplicable
  python scripts/sanear_tabla_bugs.py --selftest    # pruebas con fixtures
"""

import argparse
import collections
import io
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import metricas_bugs as mb  # noqa: E402

RUTA_POR_DEFECTO = mb.RUTA_POR_DEFECTO
RUTA_DASHBOARD = mb.RUTA_DASHBOARD

# Ancla de fin de la seccion 5. Si desaparece, el patch se ABORTA (regla de
# worktree compartido: un ancla perdida la arreglo otro agente, no yo).
ANCLA = "## 6. Bugs Abiertos (pendientes)"

# `### BUG-024 — Titulo` / `## BUG-044: Titulo` / `### BUG-099 - Titulo`
RE_TITULO = re.compile(r"^#{2,3}\s+(BUG-\d+)\s*(?:[\u2014\u2013:.\-]+\s*)?(.*)$")

RE_CAMPO_MODULO = re.compile(r"\*\*M[oó]dulo[^*]*afectado[^*]*\*\*:?\s*(.*)", re.I)
RE_CAMPO_SEVERIDAD = re.compile(r"\*\*Severidad\s*:?\*\*:?\s*(.*)", re.I)
RE_CAMPO_ESTADO = re.compile(r"\*\*Estado\s*:?\*\*:?\s*(.*)", re.I)
RE_CAMPO_REPORTER = re.compile(r"\*\*Reportado por\s*:?\*\*:?\s*(.*)", re.I)
RE_CAMPO_FECHA = re.compile(r"\*\*Fecha de reporte\s*:?\*\*:?\s*(.*)", re.I)

# Continuacion de una lista de modulos: 'M118, M119, M145 (17 modulos)'
RE_CONT_MODULO = re.compile(r"^\s*,?\s*M\d{1,3}\b")

RE_FECHA = re.compile(r"(\d{4}-\d{2}-\d{2})(?:\s+(\d{2}:\d{2}))?")

# Etiqueta canonica por emoji. Debe coincidir EXACTAMENTE con lo que devuelve
# `normalizar_severidad()` para no crear `etiqueta_severidad_inconsistente`:
# el registro usa 'Critica' (femenino), no 'Critico'.
ETIQUETA_SEV = {
    "\U0001F534": "Cr\u00edtica",   # circulo rojo
    "\U0001F7E0": "Mayor",          # circulo naranja
    "\U0001F7E1": "Menor",          # circulo amarillo
    "\U0001F7E2": "Baja",           # circulo verde
    "\u26AA": "Trivial",            # circulo blanco
}
SEV_POR_PALABRA = (
    ("critic", "Cr\u00edtica"),
    ("mayor", "Mayor"),
    ("menor", "Menor"),
    ("trivial", "Trivial"),
    ("baja", "Baja"),
)

MAX_TITULO = 180
MAX_ESTADO = 110

NOTA_BLOQUE = (
    "> **Bloque consolidado de la tabla resumen** (saneamiento M102, "
    "`scripts/sanear_tabla_bugs.py`): las filas de abajo corresponden a entradas "
    "de las secciones 6-8 que nunca se habian reflejado aca. Se generaron por "
    "transcripcion de las etiquetas explicitas de cada entrada (`**Severidad:**`, "
    "`**Estado:**`, `**Modulo(s) afectado(s):**`, `**Fecha de reporte:**`); las "
    "celdas que la entrada no declara quedan vacias en vez de deducirse. "
    "El bloque es idempotente: re-ejecutar la herramienta no lo duplica."
)

CABECERA_BLOQUE = (
    "| ID | T\u00edtulo | M\u00f3dulo | Severidad | Estado | Reportado por | Fecha |",
    "|----|--------|--------|-----------|--------|---------------|-------|",
)


# --- lectura de la estructura ---------------------------------------------

def lineas_de(texto):
    return texto.split("\n")


def entradas_con_cuerpo(lineas):
    """[(id, indice_0based_del_encabezado, [lineas del cuerpo])] en orden."""
    heads = [(i, m.group(1)) for i, l in enumerate(lineas)
             for m in [mb.RE_ENTRADA.match(l)] if m]
    out = []
    for n, (i, bid) in enumerate(heads):
        fin = heads[n + 1][0] if n + 1 < len(heads) else len(lineas)
        out.append((bid, i, lineas[i:fin]))
    return out


def _valor_campo(cuerpo, patron, continuacion=None):
    """Valor de una etiqueta explicita. Cadena vacia si la etiqueta no esta."""
    for n, linea in enumerate(cuerpo):
        m = patron.search(linea)
        if not m:
            continue
        partes = [m.group(1)]
        if continuacion is not None:
            for sig in cuerpo[n + 1:]:
                if not continuacion.match(sig):
                    break
                partes.append(sig)
        return " ".join(p.strip() for p in partes if p.strip()).strip()
    return ""


def _celda(texto, limite=None):
    """Normaliza una celda: sin enfasis, sin saltos, con los pipes escapados."""
    limpio = mb._limpiar_markdown(texto or "")
    limpio = re.sub(r"\s+", " ", limpio).strip()
    if limite and len(limpio) > limite:
        # Cortar en el ultimo espacio util: un corte a mitad de palabra deja
        # celdas como 'max_heig...' que no se pueden leer ni buscar.
        corte = limpio.rfind(" ", 0, limite - 1)
        limpio = limpio[:corte if corte > limite // 2 else limite - 1].rstrip(" ,;:-")
        limpio += "\u2026"
    return limpio.replace("|", "\\|")


def _modulos(valor, titulo):
    """['M019','M009'] desde la etiqueta; si no hay, desde el titulo."""
    mods = []
    for crudo in (valor, titulo):
        encontrados = mb.RE_MODULO.findall(crudo or "")
        if encontrados:
            mods = ["M%03d" % int(x) for x in encontrados]
            break
    vistos = []
    for m in mods:
        if m not in vistos:
            vistos.append(m)
    return "/".join(vistos)


def _severidad(valor):
    """Celda de severidad con la etiqueta canonica del registro."""
    if not valor:
        return ""
    for emoji, etiqueta in ETIQUETA_SEV.items():
        if emoji in valor:
            return "%s %s" % (emoji, etiqueta)
    bajo = valor.lower()
    for palabra, etiqueta in SEV_POR_PALABRA:
        if palabra in bajo:
            emoji = next(e for e, l in ETIQUETA_SEV.items() if l == etiqueta)
            return "%s %s" % (emoji, etiqueta)
    return ""


def _estado(valor):
    """Celda de estado con marca [x]/[ ]/[?]/[->]. None si no es transcribible.

    Un `[x]` en la tabla sin marca en la entrada produce `estado_sin_marca`, y
    una celda vacia produce `estado_desconocido`: los dos son retrocesos. Si la
    entrada no declara la marca, se devuelve None y el llamador OMITE la fila.
    """
    if not valor:
        return None
    limpio = mb._limpiar_markdown(valor)
    m = mb.RE_ESTADO.search(limpio)
    if m:
        marca = "[%s]" % m.group(1)
    elif "\u2705" in valor and "resuelt" in valor.lower():
        # '✅ Resuelto (2026-09-14 ...)' es una declaracion explicita de cierre
        # sin marca; se transcribe como [x]. No se aplica a ningun otro texto.
        marca = "[x]"
    else:
        return None
    resto = mb.RE_ESTADO.sub(" ", limpio)
    # Algunas entradas siguen la linea de Estado con metadatos separados por
    # ' | ' (Módulo:, Severidad:). Eso ya tiene su columna: se corta ahi.
    resto = re.split(r"\s+\|\s+", resto)[0]
    resto = re.sub(r"\s+", " ", resto).strip(" -\u2014\u00b7")
    celda = ("%s %s" % (marca, resto)).strip()
    return _celda(celda, MAX_ESTADO)


def _fecha(valor):
    m = RE_FECHA.search(valor or "")
    if not m:
        return ""
    return m.group(1) + (" " + m.group(2) if m.group(2) else "")


def _reporter(valor):
    if not valor:
        return ""
    # 'atria-dawn (QA M38, Log 982) · **Resuelto por:** agnes...' -> solo el 1o
    partes = re.split(r"\s*[·|]\s*", valor)
    return _celda(partes[0], 60)


def fila_para(bid, titulo, campos):
    """Las 7 celdas de la fila, o None si no es transcribible."""
    estado = _estado(campos["estado"])
    if estado is None:
        return None
    titulo_celda = _celda(titulo, MAX_TITULO)
    if not titulo_celda:
        return None
    return [
        bid,
        titulo_celda,
        _modulos(campos["modulo"], titulo),
        _severidad(campos["severidad"]),
        estado,
        _reporter(campos["reporter"]),
        _fecha(campos["fecha"]),
    ]


def extraer_campos(cuerpo):
    return {
        "modulo": _valor_campo(cuerpo, RE_CAMPO_MODULO, RE_CONT_MODULO),
        "severidad": _valor_campo(cuerpo, RE_CAMPO_SEVERIDAD),
        "estado": _valor_campo(cuerpo, RE_CAMPO_ESTADO),
        "reporter": _valor_campo(cuerpo, RE_CAMPO_REPORTER),
        "fecha": _valor_campo(cuerpo, RE_CAMPO_FECHA),
    }


# --- generacion del bloque -------------------------------------------------

def plan(texto, datos):
    """Devuelve (filas, omitidas). No modifica nada.

    `filas` = [(id, [7 celdas])] en orden ascendente de id.
    `omitidas` = [(id, motivo)] de entradas que NO se pueden transcribir.
    """
    if datos is None:
        raise ValueError("plan() necesita el resultado de leer_registro()")
    lineas = lineas_de(texto)

    faltantes = sorted({d["firma"].split(":", 1)[1]
                        for d in datos["defectos"]
                        if d["tipo"] == "entrada_sin_fila"})

    cuerpos = {}
    for bid, _i, cuerpo in entradas_con_cuerpo(lineas):
        # Si hay varias entradas con el mismo id, manda la primera: la
        # duplicacion se reporta aparte y no se resuelve aca.
        cuerpos.setdefault(bid, cuerpo)

    filas, omitidas = [], []
    for bid in faltantes:
        cuerpo = cuerpos.get(bid)
        if cuerpo is None:
            omitidas.append((bid, "sin cuerpo de entrada localizable"))
            continue
        m = RE_TITULO.match(cuerpo[0])
        titulo = m.group(2) if m else ""
        campos = extraer_campos(cuerpo)
        if not campos["estado"]:
            omitidas.append((bid, "la entrada no declara **Estado:**"))
            continue
        celdas = fila_para(bid, titulo, campos)
        if celdas is None:
            omitidas.append((bid, "estado no transcribible a [x]/[ ]/[?]/[->]"))
            continue
        filas.append((bid, celdas))
    return filas, omitidas


def bloque_markdown(filas):
    """Las lineas del bloque a insertar (sin la linea vacia de separacion)."""
    out = [NOTA_BLOQUE, ""]
    out.extend(CABECERA_BLOQUE)
    for _bid, celdas in filas:
        out.append("| " + " | ".join(celdas) + " |")
    return out


def insertar(texto, filas):
    """Inserta el bloque justo antes del ancla. Diff puramente ADITIVO."""
    lineas = lineas_de(texto)
    try:
        pos = lineas.index(ANCLA)
    except ValueError:
        raise SystemExit("ABORTADO: no se encontro el ancla %r" % ANCLA)
    nuevo = bloque_markdown(filas)
    return "\n".join(lineas[:pos] + nuevo + [""] + lineas[pos:])


# --- validacion antes de escribir -----------------------------------------

def _firmas(datos):
    return collections.Counter(d["firma"] for d in datos["defectos"])


def validar(texto_antes, texto_despues, tmp_ruta, ruta_antes=RUTA_POR_DEFECTO):
    """Corre el medidor sobre el resultado y devuelve (ok, mensajes).

    Invariante: NINGUNA firma de defecto puede aumentar. Bajar es el objetivo;
    subir (o estrenar una) es un retroceso del saneamiento.
    """
    antes = _firmas(mb.leer_registro(ruta_antes, None))
    with io.open(tmp_ruta, "wb") as f:
        f.write(texto_despues.encode("utf-8"))
    despues = _firmas(mb.leer_registro(tmp_ruta, None))

    msgs, ok = [], True
    for firma, n in sorted(despues.items()):
        if n > antes.get(firma, 0):
            ok = False
            msgs.append("RETROCESO: la firma %r sube de %d a %d"
                        % (firma, antes.get(firma, 0), n))
    for firma, n in sorted(antes.items()):
        if n > despues.get(firma, 0):
            msgs.append("mejora: %r baja de %d a %d"
                        % (firma, n, despues.get(firma, 0)))
    if texto_despues.startswith("\ufeff"):
        ok = False
        msgs.append("RETROCESO: BOM al inicio")
    if "\r\n" in texto_despues:
        ok = False
        msgs.append("RETROCESO: CRLF introducido (el registro es LF)")
    return ok, msgs


def _leer(ruta=RUTA_POR_DEFECTO):
    return io.open(ruta, "rb").read().decode("utf-8")


def _escribir(ruta, texto):
    # Bytes, sin normalizar EOL: `open('w')` en Windows mete CRLF.
    with io.open(ruta, "wb") as f:
        f.write(texto.encode("utf-8"))


# --- CLI -------------------------------------------------------------------

def main(argv=None):
    ap = argparse.ArgumentParser(
        description="Saneamiento mecanico de la tabla resumen de 11-BUGS.md")
    ap.add_argument("--archivo", default=RUTA_POR_DEFECTO)
    ap.add_argument("--aplicar", action="store_true", help="escribe el bloque")
    ap.add_argument("--check", action="store_true",
                    help="exit 1 si queda trabajo aplicable (para CI)")
    ap.add_argument("--selftest", action="store_true")
    try:
        args = ap.parse_args(argv)
    except SystemExit as e:
        return 0 if not e.code else 2

    if args.selftest:
        import test_sanear_tabla_bugs
        return test_sanear_tabla_bugs.main()

    if not os.path.isfile(args.archivo):
        sys.stderr.write("DETECTOR CIEGO (exit 3): no existe %s\n" % args.archivo)
        return 3

    try:
        texto = _leer(args.archivo)
        datos = mb.leer_registro(args.archivo, None)
    except (IOError, OSError, UnicodeDecodeError) as e:
        sys.stderr.write("DETECTOR CIEGO (exit 3): %s\n" % e)
        return 3
    if datos.get("ciego"):
        sys.stderr.write("DETECTOR CIEGO (exit 3): %s\n" % datos["ciego"])
        return 3

    filas, omitidas = plan(texto, datos)

    print("=" * 70)
    print("SANEAMIENTO DE LA TABLA RESUMEN — %s" % args.archivo)
    print("=" * 70)
    print("Entradas sin fila (medido) : %d"
          % len([d for d in datos["defectos"] if d["tipo"] == "entrada_sin_fila"]))
    print("Filas transcribibles       : %d" % len(filas))
    print("Omitidas (requieren juicio): %d" % len(omitidas))
    for bid, motivo in omitidas:
        print("  - %s: %s" % (bid, motivo))
    if filas:
        print("\nFilas que se agregarian (id + estado):")
        for bid, celdas in filas:
            print("  %s  %-14s %-22s %s" % (bid, celdas[3], celdas[4], celdas[2]))

    if not filas:
        print("\nNADA POR HACER: la tabla ya tiene fila para toda entrada "
              "transcribible.")
        # --check queda VERDE: lo que resta son omisiones que necesitan
        # decision humana, y castigarlas dejaria el gate rojo para siempre.
        return 0

    nuevo = insertar(texto, filas)

    tmp = args.archivo + ".saneando.tmp"
    ok, msgs = validar(texto, nuevo, tmp, args.archivo)
    try:
        os.remove(tmp)
    except OSError:
        pass
    print("\nAutovalidacion del resultado:")
    for m in msgs[:12]:
        print("  " + m)
    if not ok:
        print("\nABORTADO: el cambio introduciria un retroceso (ver arriba).")
        return 1

    if args.check:
        print("\nCHECK ROJO: quedan %d fila(s) aplicables." % len(filas))
        return 1

    if args.aplicar:
        _escribir(args.archivo, nuevo)
        print("\nAPLICADO: %d fila(s) agregadas a %s" % (len(filas), args.archivo))
        return 0

    print("\nDRY-RUN: no se escribio nada. Usar --aplicar.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
