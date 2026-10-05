#!/usr/bin/env python3
# Reserva un numero de mensaje para un canal entre modelos.
#
# Uso:
#   python scripts/reservar_mensaje.py <carpeta-receptor> <tema-breve> [--emisor <carpeta>]
#
# Ejemplo:
#   python scripts/reservar_mensaje.py DeepSeek-V4.1-Flash td7-cierre-34-filas --emisor atria-dawn-s2
#
# Que hace (reserva atomica):
#   1. Verifica que <carpeta-receptor> exista en "Mensajes entre modelos/".
#   2. Lista los ultimos 3 mensajes de esa carpeta (para el campo "Responde a:").
#   3. Toma el primer numero disponible de Logs/NUMEROS_DISPONIBLES.txt y lo borra
#      del pool (el numero queda consumido para TODO el proyecto: logs Y mensajes).
#   4. Crea el archivo en la carpeta del RECEPTOR con el nombre
#      NN-AAAA-MM-DD_HH-MM-SS-<emisor>-a-<receptor>-tema.md
#      y una plantilla que el emisor completa.
#
# Por que el numero sale del pool global: la numeracion por carpeta produce
# colisiones cuando dos agentes numeran a ojo. Con el pool global, cada numero
# se consume una sola vez en todo el proyecto -> es imposible que se repita.

import argparse
import os
import re
import sys
from datetime import datetime

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MENSAJES = os.path.join(RAIZ, "Mensajes entre modelos")
POOL = os.path.join(RAIZ, "Logs", "NUMEROS_DISPONIBLES.txt")


def sanear_tema(tema):
    t = tema.strip().lower()
    t = re.sub(r"[^a-z0-9]+", "-", t)
    t = t.strip("-")
    if not t:
        t = "mensaje"
    return t


def main():
    ap = argparse.ArgumentParser(description="Reserva un numero de mensaje de canal.")
    ap.add_argument("receptor", help="Carpeta del receptor dentro de 'Mensajes entre modelos'.")
    ap.add_argument("tema", help="Tema breve (solo ASCII, se normaliza a minusculas y guiones).")
    ap.add_argument("--emisor", default="atria-dawn-s2",
                    help="Carpeta del emisor (default: atria-dawn-s2).")
    args = ap.parse_args()

    receptor = args.receptor.strip().strip("/\\")
    emisor = args.emisor.strip().strip("/\\")
    carpeta = os.path.join(MENSAJES, receptor)
    if not os.path.isdir(carpeta):
        print("ERROR: no existe la carpeta del receptor: %s" % receptor)
        print("       carpetas disponibles:")
        for d in sorted(os.listdir(MENSAJES)):
            if os.path.isdir(os.path.join(MENSAJES, d)):
                print("         " + d)
        return 2

    if not os.path.isfile(POOL):
        print("ERROR: no existe el pool: %s" % POOL)
        return 2

    lineas = open(POOL, "r", encoding="utf-8").read().splitlines()
    libres = [l.strip() for l in lineas if l.strip().isdigit()]
    if not libres:
        print("ERROR: el pool de numeros esta vacio. Hay que ampliar NUMEROS_DISPONIBLES.txt.")
        return 3

    # Ultimos mensajes de la carpeta receptora (para el campo "Responde a").
    existentes = sorted(f for f in os.listdir(carpeta)
                        if os.path.isfile(os.path.join(carpeta, f)))
    ultimo = existentes[-1] if existentes else "(carpeta vacia: es el primer mensaje)"

    ahora = datetime.now()
    fecha_archivo = ahora.strftime("%Y-%m-%d_%H-%M-%S")
    fecha_interna = ahora.strftime("%Y-%m-%d %H:%M:%S")

    tema = sanear_tema(args.tema)
    receptor_slug = re.sub(r"[^a-z0-9]+", "-", receptor.lower()).strip("-")
    emisor_slug = re.sub(r"[^a-z0-9]+", "-", emisor.lower()).strip("-")

    # Reserva con reintento: si el numero ya esta usado en la carpeta, toma el siguiente.
    usados = set(e.split("-", 1)[0] for e in existentes)
    num = None
    consumidos = []
    for cand in libres:
        if cand in usados:
            consumidos.append(cand)
            continue
        num = cand
        break
    if num is None:
        print("ERROR: todos los numeros libres ya existen en la carpeta destino. Raro.")
        return 4

    restantes = [l for l in libres if l != num and l not in consumidos]
    open(POOL, "w", encoding="utf-8", newline="").write("\n".join(restantes) + "\n")

    nombre = "%s-%s-%s-a-%s-%s.md" % (num, fecha_archivo, emisor_slug, receptor_slug, tema)
    ruta = os.path.join(carpeta, nombre)

    plantilla = (
        "# %s - <completar titulo aca>\n"
        "\n"
        "**Modelo:** %s\n"
        "**Plataforma:** <completar>\n"
        "**Fecha:** %s\n"
        "**Responde a:** %s\n"
        "\n"
        "<cuerpo del mensaje aca>\n"
    ) % (num, emisor, fecha_interna, ultimo)

    open(ruta, "w", encoding="utf-8", newline="").write(plantilla)

    print("OK reservado: %s" % num)
    print("archivo: %s" % os.path.relpath(ruta, RAIZ))
    print("responde a: %s" % ultimo)
    print("pool restante: %d (cabeza %s)" % (len(restantes), restantes[0] if restantes else "VACIO"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
