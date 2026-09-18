#!/usr/bin/env python3
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
# Este archivo es parte de "Isla Ancestral". Ver LICENSE en la raiz.

# -*- coding: utf-8 -*-
"""M127 iter. 3 -- Protocolo de cabeceras de copyright en fuentes (.gd / .cs / .py).

Inserta o actualiza una cabecera de copyright **idempotente** en los archivos
declarados por `tools/legal/headers_scope.json`, preservando los bytes:

  * NO agrega BOM (AGENTS.md seccion 28: UTF-8 sin BOM).
  * NO cambia los finales de linea del archivo.

Por que la preservacion de EOL no es un detalle teorico (medido 2026-09-18):
`game/isla-ancestral/scripts/legal/` tiene 43 `.gd`; **42 son LF y 1
(`license_validator.gd`) es CRLF**. Un script que normalice a LF o a CRLF
reescribe el archivo ENTERO en el diff y destruye la trazabilidad del cambio.

Uso:
    python tools/legal/insert_copyright_headers.py --check     # exit 1 si falta
    python tools/legal/insert_copyright_headers.py --apply     # escribe
    python tools/legal/insert_copyright_headers.py --list      # alcance declarado
    python tools/legal/insert_copyright_headers.py --check --json

Exit: 0 = todo OK / 1 = falta alguna cabecera (o hubo un error de lectura).
"""

import argparse
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.normpath(os.path.join(HERE, "..", ".."))
ALCANCE = os.path.join(HERE, "headers_scope.json")
COPYRIGHT_JSON = os.path.join(RAIZ, "game", "isla-ancestral", "data", "legal", "copyright.json")

MARCADOR = "SPDX-License-Identifier:"
SPDX = "LicenseRef-Propietaria"

# Prefijo de comentario por extension
COMENTARIO = {".gd": "#", ".cs": "//", ".py": "#"}

# Lineas que NO deben quedar debajo de la cabecera (van primero)
PREVIAS = ("#!", "@tool", "@icon")

EOL_DEFECTO = {
    "lf": "\n",
    "crlf": "\r\n",
}


def cargar_alcance(ruta=ALCANCE):
    """Lee el manifiesto de alcance. Devuelve (extensiones, incluir, excluir)."""
    with open(ruta, "r", encoding="utf-8") as f:
        data = json.load(f)
    ext = [e.lower() for e in data.get("extensiones", [".gd", ".cs", ".py"])]
    incluir = list(data.get("incluir", []))
    excluir = list(data.get("excluir", []))
    return ext, incluir, excluir


def titular_y_year(ruta=COPYRIGHT_JSON):
    """Titular y ano desde el catalogo real del modulo (fallback si no existe)."""
    try:
        with open(ruta, "r", encoding="utf-8") as f:
            data = json.load(f)
        elementos = data.get("elementos") or []
        titular = elementos[0].get("titular") if elementos else None
        year = elementos[0].get("year") if elementos else None
        return (titular or "Isla Ancestral Team", int(year) if year else 2026)
    except (OSError, ValueError, json.JSONDecodeError):
        return ("Isla Ancestral Team", 2026)


def _normalizar(p):
    return p.replace("\\", "/")


def es_excluido(rel, excluir):
    rel = _normalizar(rel)
    for pat in excluir:
        pat = _normalizar(pat).rstrip("/")
        if not pat:
            continue
        if rel == pat or rel.startswith(pat + "/") or pat in rel.split("/"):
            return True
    return False


def archivos_en_alcance(ext, incluir, excluir):
    """Lista ordenada de rutas relativas a la raiz que entran en el alcance."""
    encontrados = []
    for item in incluir:
        abs_item = os.path.join(RAIZ, item.replace("/", os.sep))
        if os.path.isfile(abs_item):
            encontrados.append(_normalizar(item))
            continue
        if not os.path.isdir(abs_item):
            continue
        for base, dirs, files in os.walk(abs_item):
            dirs[:] = sorted(d for d in dirs if d not in ("__pycache__", ".git"))
            for nombre in sorted(files):
                if os.path.splitext(nombre)[1].lower() not in ext:
                    continue
                rel = _normalizar(os.path.relpath(os.path.join(base, nombre), RAIZ))
                if not es_excluido(rel, excluir):
                    encontrados.append(rel)
    # dedup preservando orden
    vistos, salida = set(), []
    for r in encontrados:
        if r not in vistos:
            vistos.add(r)
            salida.append(r)
    return salida


def partir_lineas(texto):
    """[(cuerpo, eol)] preservando el terminador de CADA linea.

    La ultima linea puede NO tener terminador (archivo sin newline final): en ese
    caso el eol es la cadena vacia, nunca None (si fuera None, rearmar reventaria).
    """
    return [(m.group(1), m.group(2) or "")
            for m in re.finditer(r"([^\r\n]*)(\r\n|\r|\n)?", texto)
            if m.group(1) or m.group(2)]


def eol_dominante(texto):
    """'\r\n' / '\n' / None si no hay lineas. Un archivo MIXTO devuelve None."""
    crlf = texto.count("\r\n")
    lf = texto.count("\n") - crlf
    cr = texto.count("\r") - crlf
    if crlf and not lf and not cr:
        return "\r\n"
    if lf and not crlf and not cr:
        return "\n"
    if not crlf and not lf and not cr:
        return "\n"  # archivo de una sola linea sin terminador
    return None  # MIXTO -> no lo tocamos


def cabecera(comentario, titular, year):
    return [
        "%s Copyright (c) %d %s. Todos los derechos reservados." % (comentario, year, titular),
        "%s %s %s" % (comentario, MARCADOR, SPDX),
        "%s Este archivo es parte de \"Isla Ancestral\". Ver LICENSE en la raiz." % comentario,
    ]


def _es_previa(cuerpo):
    limpio = cuerpo.strip()
    return any(limpio.startswith(p) for p in PREVIAS)


def indice_insercion(lineas):
    """Primer indice de linea que NO sea shebang ni anotacion (@tool / @icon)."""
    i = 0
    while i < len(lineas) and _es_previa(lineas[i][0]):
        i += 1
    return i


def _es_linea_cabecera(cuerpo, comentario):
    """True si la linea es parte de NUESTRA cabecera (no de cualquier comentario).

    Se compara por FORMA, no por texto exacto: asi una cabecera con otro ano se
    reconoce como cabecera y se actualiza en vez de duplicarse.
    """
    if not cuerpo.startswith(comentario):
        return False
    return ("Copyright (c)" in cuerpo
            or MARCADOR in cuerpo
            or "Este archivo es parte de" in cuerpo)


def rango_cabecera(lineas, ini, fin, comentario):
    """[j, k) de las lineas de cabecera contiguas dentro del bloque, o None.

    Delimitar la cabecera por forma (y no tomar el bloque de comentarios entero)
    evita el bug de truncar lineas vecinas legitimas, p. ej. `# -*- coding: utf-8 -*-`.
    """
    j = None
    for i in range(ini, fin):
        if _es_linea_cabecera(lineas[i][0], comentario):
            j = i
            break
    if j is None:
        return None
    k = j
    while k < fin and _es_linea_cabecera(lineas[k][0], comentario):
        k += 1
    return (j, k)


def procesar(texto, ext):
    """Devuelve (nuevo_texto, accion) con accion en {'ok', 'insertada',
    'actualizada', 'sin-eol', 'mixto'}."""
    comentario = COMENTARIO.get(ext)
    if comentario is None:
        return texto, "ok"
    eol = eol_dominante(texto)
    if eol is None:
        return texto, "mixto"
    lineas = partir_lineas(texto)
    ini = indice_insercion(lineas)

    # Bloque contiguo de comentarios justo en el punto de insercion
    fin = ini
    while fin < len(lineas) and lineas[fin][0].startswith(comentario):
        fin += 1

    titular, year = procesar.titular_year
    nuevas = cabecera(comentario, titular, year)

    rango = rango_cabecera(lineas, ini, fin, comentario)
    if rango is not None:
        j, k = rango
        actual = [lineas[i][0] for i in range(j, k)]
        if actual == nuevas:
            return texto, "ok"
        # Reemplaza SOLO las lineas de cabecera; el resto del bloque queda intacto.
        salida = lineas[:j] + [(c, eol) for c in nuevas] + lineas[k:]
        return _rearmar(salida), "actualizada"

    # No hay cabecera: insertar el bloque (y una linea en blanco de separacion)
    reemplazo = [(c, eol) for c in nuevas] + [("", eol)]
    salida = lineas[:ini] + reemplazo + lineas[ini:]
    return _rearmar(salida), "insertada"


def _rearmar(lineas):
    return "".join(cuerpo + eol for cuerpo, eol in lineas)


def leer(ruta_abs):
    with open(ruta_abs, "rb") as f:
        crudo = f.read()
    return crudo


def decodificar(crudo):
    """UTF-8 sin BOM. Un BOM se reporta aparte (no lo escribimos nosotros)."""
    bom = crudo.startswith(b"\xef\xbb\xbf")
    return crudo.decode("utf-8"), bom


def main():
    p = argparse.ArgumentParser(description="Cabeceras de copyright en fuentes (.gd/.cs/.py)")
    p.add_argument("--check", action="store_true", help="exit 1 si falta alguna cabecera")
    p.add_argument("--apply", action="store_true", help="escribe las cabeceras faltantes")
    p.add_argument("--list", action="store_true", help="lista el alcance declarado")
    p.add_argument("--json", action="store_true", help="salida en JSON")
    p.add_argument("--year", type=int, default=None, help="forzar el ano (default: copyright.json)")
    a = p.parse_args()

    ext, incluir, excluir = cargar_alcance()
    titular, year = titular_y_year()
    if a.year:
        year = a.year
    procesar.titular_year = (titular, year)

    archivos = archivos_en_alcance(ext, incluir, excluir)

    if a.list:
        for r in archivos:
            print(r)
        print("Total: %d archivo(s) en alcance" % len(archivos))
        return 0

    faltantes, actualizadas, errores, con_bom, mixtos = [], [], [], [], []
    for rel in archivos:
        abs_p = os.path.join(RAIZ, rel.replace("/", os.sep))
        try:
            crudo = leer(abs_p)
            texto, bom = decodificar(crudo)
        except (OSError, UnicodeDecodeError) as e:
            errores.append("%s: %s" % (rel, e))
            continue
        if bom:
            con_bom.append(rel)
        nuevo, accion = procesar(texto, os.path.splitext(rel)[1].lower())
        if accion == "mixto":
            mixtos.append(rel)
            continue
        if accion == "insertada":
            faltantes.append(rel)
            if a.apply:
                with open(abs_p, "wb") as f:
                    f.write(nuevo.encode("utf-8"))
        elif accion == "actualizada":
            actualizadas.append(rel)
            if a.apply:
                with open(abs_p, "wb") as f:
                    f.write(nuevo.encode("utf-8"))

    if a.json:
        print(json.dumps({
            "titular": titular,
            "year": year,
            "en_alcance": len(archivos),
            "faltantes": faltantes,
            "actualizadas": actualizadas,
            "con_bom": con_bom,
            "eol_mixto": mixtos,
            "errores": errores,
        }, indent=2, ensure_ascii=False))
    else:
        modo = "APPLY" if a.apply else "CHECK"
        print("[cabeceras:%s] alcance=%d archivos  titular=%s  year=%d"
              % (modo, len(archivos), titular, year))
        for r in faltantes:
            print("  [%s] %s" % ("ESCRITA" if a.apply else "FALTA", r))
        for r in actualizadas:
            print("  [%s] %s" % ("ACTUALIZADA" if a.apply else "DESACTUALIZADA", r))
        for r in con_bom:
            print("  [BOM] %s  (AGENTS.md seccion 28: UTF-8 sin BOM)" % r)
        for r in mixtos:
            print("  [EOL-MIXTO] %s  (no se toca: normalizar reescribiria el archivo)" % r)
        for e in errores:
            print("  [ERROR] %s" % e)
        print("  faltantes=%d actualizadas=%d bom=%d eol_mixto=%d errores=%d"
              % (len(faltantes), len(actualizadas), len(con_bom), len(mixtos), len(errores)))

    if errores:
        return 1
    if not a.apply and (faltantes or actualizadas):
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
