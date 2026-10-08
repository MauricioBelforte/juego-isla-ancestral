# -*- coding: utf-8 -*-
"""Indice de canales: detecta mensajes nuevos en 'Mensajes entre modelos/'.

Mantiene:
  - indice_canales.json  (estado: ultimo archivo visto por carpeta)
  - INDICE-CANALES.md    (tabla legible)

Uso:
  python indice_canales.py            # solo reporta novedades (no escribe)
  python indice_canales.py --update   # actualiza el estado tras procesar todo
"""
import json
import os
import sys
from datetime import datetime

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
BASE = os.path.join(ROOT, "Mensajes entre modelos")
STATE = os.path.join(ROOT, "DOCUMENTACION", "TAREAS-POR-MODELO", "atria-dawn", "indice_canales.json")
INDEX_MD = os.path.join(ROOT, "DOCUMENTACION", "TAREAS-POR-MODELO", "atria-dawn", "INDICE-CANALES.md")

# carpetas de tema antiguo (modo tema, no canales vivos)
EXCLUIR_PREFIJOS = ("01-", "04-", "05-", "06-")


def escanear():
    canales = {}
    if not os.path.isdir(BASE):
        return canales
    for nombre in sorted(os.listdir(BASE)):
        ruta = os.path.join(BASE, nombre)
        if not os.path.isdir(ruta):
            continue
        if nombre.startswith(EXCLUIR_PREFIJOS):
            continue
        if nombre in ("RESUELTOS",):
            continue
        archivos = sorted(
            f for f in os.listdir(ruta)
            if f.endswith(".md") and os.path.isfile(os.path.join(ruta, f))
        )
        if not archivos:
            continue
        canales[nombre] = archivos
    return canales


def cargar_estado():
    if os.path.isfile(STATE):
        try:
            with open(STATE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            pass
    return {}


def main():
    actualizar = "--update" in sys.argv
    canales = escanear()
    estado = cargar_estado()

    lineas = []
    novedades = []
    for nombre, archivos in canales.items():
        n = len(archivos)
        ultimo = archivos[-1]
        visto = estado.get(nombre, {}).get("ultimo", None)
        nuevos = [a for a in archivos if visto is None or a > visto]
        if nuevos:
            novedades.append((nombre, len(nuevos), nuevos))
        marca = "  <-- NUEVO" if nuevos else ""
        lineas.append("| %s | %d | %s | %d |%s" % (nombre, n, ultimo, len(nuevos), marca))

    ts = datetime.now().strftime("%Y-%m-%d %H:%M")
    if novedades:
        print("NOVEDADES (%d canales):" % len(novedades))
        for nombre, cuantos, lista in novedades:
            print("  %-26s +%d  %s" % (nombre, cuantos, lista[-1]))
    else:
        print("SIN NOVEDADES en los %d canales" % len(canales))

    # escribir el .md legible
    cuerpo = [
        "# Indice de Canales — Mensajes entre modelos",
        "",
        "> Generado por `indice_canales.py`. Escanea las carpetas de canales y compara contra",
        "> el ultimo archivo visto. **'Pendientes' = archivos que el coordinador todavia no",
        "> proceso.** Actualizar con `python indice_canales.py --update` despues de responder.",
        "",
        "**Ultimo escaneo:** %s" % ts,
        "",
        "| Canal | Archivos | Ultimo | Pendientes |",
        "|---|---|---|---|",
    ] + lineas + ["", ]
    if novedades:
        cuerpo.append("## Pendientes de procesar (%d)" % len(novedades))
        cuerpo.append("")
        for nombre, cuantos, lista in novedades:
            cuerpo.append("**%s** — %d nuevo(s):" % (nombre, cuantos))
            for a in lista:
                cuerpo.append("- `%s`" % a)
            cuerpo.append("")
    else:
        cuerpo.append("**Todo al dia.**")
        cuerpo.append("")

    with open(INDEX_MD, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(cuerpo))

    if actualizar:
        nuevo_estado = {}
        for nombre, archivos in canales.items():
            nuevo_estado[nombre] = {"ultimo": archivos[-1], "n": len(archivos)}
        with open(STATE, "w", encoding="utf-8") as f:
            json.dump(nuevo_estado, f, ensure_ascii=False, indent=1, sort_keys=True)
        print("ESTADO ACTUALIZADO (%d canales)" % len(nuevo_estado))
    else:
        print("(sin --update: el estado no se modifico; correr con --update tras responder)")


if __name__ == "__main__":
    main()
