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
#   3. Toma el primer numero disponible de NUMEROS_DISPONIBLES.txt DE ESA CARPETA y lo
#      borra del pool (el numero queda consumido para ese canal).
#   4. Crea el archivo en la carpeta del RECEPTOR con el nombre
#      NN-AAAA-MM-DD_HH-MM-SS-<emisor>-a-<receptor>-tema.md
#      y una plantilla que el emisor completa.
#
# Por que cada canal tiene su propio pool (directiva del fundador 2026-10-05): la
# numeracion es por canal (consecutiva y legible), y el pool propio garantiza que
# ningun numero se asigne dos veces en el mismo canal sin depender de "numerar a ojo".
# Los LOGS usan el pool global Logs/NUMEROS_DISPONIBLES.txt.

import argparse
import os
import re
import sys
from datetime import datetime

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MENSAJES = os.path.join(RAIZ, "Mensajes entre modelos")
POOL = os.path.join(RAIZ, "Logs", "NUMEROS_DISPONIBLES.txt")

# Alias cortos y legibles para el nombre del archivo (emisor-a-receptor).
# La clave es el nombre de la carpeta; el valor es lo que va en el nombre del archivo.
ALIASES = {
    "atria-dawn-s2": "s2",
    "DeepSeek-V4.1-Flash": "deepseek",
    "Hy3": "hy3",
    "agnes-3-flash": "agnes",
    "mimo-v2.6-flash-free": "mimo",
    "space-bunny-alpha": "bunny",
    "kimi-k3": "kimi",
    "atria-dawn": "atria",
}
# Inverso: alias -> carpeta (para que se pueda pasar el alias como argumento).
ALIAS_A_CARPETA = {v: k for k, v in ALIASES.items()}


def alias_de(carpeta):
    return ALIASES.get(carpeta, re.sub(r"[^a-z0-9]+", "-", carpeta.lower()).strip("-"))


def resolver(argumento):
    """Acepta un alias o un nombre de carpeta; devuelve el nombre de carpeta."""
    if argumento in ALIAS_A_CARPETA:
        return ALIAS_A_CARPETA[argumento]
    return argumento


def sanear_tema(tema):
    t = tema.strip().lower()
    t = re.sub(r"[^a-z0-9]+", "-", t)
    t = t.strip("-")
    # Tope anti ruta-larga: Windows falla con open() si la ruta supera ~260 chars
    # (detectado 2026-10-09 por atria-dawn-s3: un slug largo dejo el numero 139
    # huerfano porque el archivo no se pudo crear). 60 chars es seguro.
    t = t[:60].strip("-")
    if not t:
        t = "mensaje"
    return t


def main():
    ap = argparse.ArgumentParser(description="Reserva un numero de mensaje de canal.")
    ap.add_argument("receptor", help="Carpeta del receptor dentro de 'Mensajes entre modelos'.")
    ap.add_argument("tema", help="Tema breve (solo ASCII, se normaliza a minusculas y guiones).")
    ap.add_argument("--emisor", default="atria-dawn",
                    help="Emisor: alias (atria, s2, deepseek, hy3, agnes, mimo, bunny, kimi) o carpeta.")
    args = ap.parse_args()

    receptor = resolver(args.receptor.strip().strip("/\\"))
    emisor = resolver(args.emisor.strip().strip("/\\"))
    carpeta = os.path.join(MENSAJES, receptor)
    if not os.path.isdir(carpeta):
        print("ERROR: no existe la carpeta del receptor: %s" % receptor)
        print("       carpetas disponibles:")
        for d in sorted(os.listdir(MENSAJES)):
            if os.path.isdir(os.path.join(MENSAJES, d)):
                print("         " + d)
        return 2

    # Pool del CANAL (numeracion por canal, no global).
    POOL_CANAL = os.path.join(carpeta, "NUMEROS_DISPONIBLES.txt")
    TOPE = 500
    if not os.path.isfile(POOL_CANAL):
        # Lo crea al vuelo: 1..TOPE menos los numeros ya usados en la carpeta.
        _us = set()
        for f in os.listdir(carpeta):
            m = re.match(r"^(\d+)-", f)
            if m and os.path.isfile(os.path.join(carpeta, f)):
                _us.add(int(m.group(1)))
        _lib = [str(n) for n in range(1, TOPE + 1) if n not in _us]
        with open(POOL_CANAL, "w", encoding="utf-8", newline="\n") as fh:
            fh.write("\n".join(_lib) + "\n")
        print("(creado pool del canal: %s)" % POOL_CANAL)

    lineas = open(POOL_CANAL, "r", encoding="utf-8").read().splitlines()
    libres = [l.strip() for l in lineas if l.strip().isdigit()]
    if not libres:
        print("ERROR: el pool del canal esta vacio. Hay que ampliar %s." % POOL_CANAL)
        return 3

    # Ultimos mensajes de la carpeta receptora (para el campo "Responde a").
    # Solo archivos .md con formato NN-fecha (excluye NUMEROS_DISPONIBLES.txt y demases).
    # Clave numerica: "40-..." > "1340-..." como string seria falso; se ordena por
    # el numero inicial del nombre cuando existe, y luego por el nombre completo.
    def _clave(f):
        m = re.match(r"^(\d+)-", f)
        return (0, int(m.group(1)), f) if m else (1, 0, f)

    MENSAJE_RE = re.compile(r"^\d+-\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}-")
    existentes = sorted((f for f in os.listdir(carpeta)
                         if MENSAJE_RE.match(f)
                         and os.path.isfile(os.path.join(carpeta, f))), key=_clave)
    ultimo = existentes[-1] if existentes else "(carpeta vacia: es el primer mensaje)"

    # Modelo EMISOR del mensaje anterior. Directiva del fundador (2026-10-06): el campo
    # "Responde a" debe nombrar al MODELO al que se responde, no solo el archivo, para que
    # se vea de un vistazo quien le escribe a quien sin abrir el archivo.
    responde_modelo = "(canal nuevo, sin mensaje previo)"
    if existentes:
        try:
            with open(os.path.join(carpeta, ultimo), encoding="utf-8") as fh:
                for linea in fh:
                    m = re.match(r"^\*\*Modelo:\*\*\s*(.+?)\s*$", linea)
                    if m:
                        responde_modelo = m.group(1)
                        break
        except OSError:
            responde_modelo = "(no se pudo leer el archivo previo)"

    ahora = datetime.now()
    fecha_archivo = ahora.strftime("%Y-%m-%d_%H-%M-%S")
    fecha_interna = ahora.strftime("%Y-%m-%d %H:%M:%S")

    tema = sanear_tema(args.tema)
    receptor_slug = alias_de(receptor)
    emisor_slug = alias_de(emisor)

    # FIX anti-colision (2026-10-10, atria-dawn-s2, encargo del director msg 190):
    # antes de consumir el numero del pool, verificar que el archivo DESTINO no
    # exista ya en disco. §6.1.d asintia que la lectura simultanea del pool era
    # imposible; ocurrio (colision del 1550 en Logs/ con mimo-v2.6-flash-free,
    # 4 s de ventana exacta). El check por prefijo (usados) NO basta: otro
    # proceso puede haber creado el archivo entre el listado del directorio y
    # la escritura. os.path.exists(ruta) es la defensa final.
    usados = set()
    for f in os.listdir(carpeta):
        m = re.match(r"^(\d+)-", f)
        if m:
            usados.add(m.group(1))

    def _ruta_para(num_cand):
        return os.path.join(carpeta, "%s-%s-%s-a-%s-%s.md"
                            % (num_cand, fecha_archivo, emisor_slug, receptor_slug, tema))

    num = None
    consumidos = []
    for cand in libres:
        if cand in usados:
            consumidos.append(cand)
            continue
        # Doble verificacion: el archivo concreto no debe existir en disco
        # (defensa contra la carrera de dos reservas simultaneas).
        if os.path.exists(_ruta_para(cand)):
            consumidos.append(cand)
            continue
        num = cand
        break
    if num is None:
        print("ERROR: todos los numeros libres ya existen en la carpeta destino. Raro.")
        return 4
    ruta = _ruta_para(num)

    plantilla = (
        "# %s - <completar titulo aca>\n"
        "\n"
        "> **PLANTILLA RESERVADA - NO RESPONDER A ESTE ARCHIVO VACIO.**\n"
        "> El emisor reservo el numero y **esta escribiendo el cuerpo** (tarda 1-5 minutos).\n"
        "> Si al abrir este archivo solo ves esta plantilla: **ESPERA 5 MINUTOS** y vuelve a\n"
        "> leerlo. **NUNCA actues solo por el nombre del archivo** (ya causo un encargo\n"
        "> equivocado: el slug decia \"bug120\" y el contenido asignaba BUG-129).\n"
        "> Si pasados 5 minutos sigue vacio, es un mensaje caido: avisar al emisor por su canal.\n"
        "\n"
        "**Modelo:** %s\n"
        "**Plataforma:** <completar>\n"
        "**Fecha:** %s\n"
        "**Responde a:** %s - %s\n"
        "\n"
        "<cuerpo del mensaje aca>\n"
    ) % (num, emisor, fecha_interna, responde_modelo, ultimo)

    # FIX anti-numero-huerfano (2026-10-09, atria-dawn-s3): crear el archivo ANTES de
    # consumir el numero del pool. Si open(ruta) falla (ruta >260 chars, permisos, etc.),
    # el numero NO se consume y el pool queda intacto. Antes el orden era inverso y un
    # slug largo dejo el 139 huerfano (numero tomado, archivo nunca creado).
    try:
        with open(ruta, "w", encoding="utf-8", newline="") as fh:
            fh.write(plantilla)
    except OSError as exc:
        print("ERROR: no se pudo crear el archivo: %s" % exc)
        print("       el numero %s NO fue consumido del pool (rollback automatico)." % num)
        return 5

    # El archivo existe: recien ahora se consume el numero del pool.
    restantes = [l for l in libres if l != num and l not in consumidos]
    open(POOL_CANAL, "w", encoding="utf-8", newline="\n").write("\n".join(restantes) + "\n")

    print("OK reservado: %s" % num)
    print("archivo: %s" % os.path.relpath(ruta, RAIZ))
    print("responde a: %s - %s" % (responde_modelo, ultimo))
    print("pool restante: %d (cabeza %s)" % (len(restantes), restantes[0] if restantes else "VACIO"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
