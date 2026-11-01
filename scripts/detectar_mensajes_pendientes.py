#!/usr/bin/env python3
# scripts/detectar_mensajes_pendientes.py
# Detecta mensajes de agnes-3-flash en el canal de Nemotron-3.5-Super-VL que no hayan sido respondidos.
# Estrategia: si el último mensaje del canal es de agnes y no hay un mensaje de nemotron posterior, hay algo pendiente.
# Uso: python scripts/detectar_mensajes_pendientes.py

import os
import re
import sys

CANAL = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\Mensajes entre modelos\Nemotron-3.5-Super-VL"

def extraer_numero(nombre_archivo):
    m = re.match(r"(\d{3})-", nombre_archivo)
    return int(m.group(1)) if m else None

def es_de_agnes(nombre_archivo):
    return "agnes-3-flash-a-nemotron" in nombre_archivo.lower()

def es_de_nemotron(nombre_archivo):
    return "nemotron-3-5-super-vl-a-agnes" in nombre_archivo.lower()

def main():
    if not os.path.isdir(CANAL):
        print(f"ERROR: No existe el canal: {CANAL}")
        sys.exit(1)

    archivos = [f for f in os.listdir(CANAL) if f.endswith(".md")]

    # Extraer número y emisor para cada archivo
    mensajes = []
    for nombre in archivos:
        n = extraer_numero(nombre)
        if n is None:
            continue
        emisor = "agnes" if es_de_agnes(nombre) else ("nemotron" if es_de_nemotron(nombre) else "otro")
        mensajes.append((n, nombre, emisor))

    if not mensajes:
        print("Canal vacío. Sin mensajes pendientes.")
        sys.exit(0)

    # Ordenar por número
    mensajes.sort(key=lambda x: x[0])

    # El último mensaje del canal
    ultimo_numero, ultimo_nombre, ultimo_emisor = mensajes[-1]

    if ultimo_emisor == "agnes":
        # El último mensaje es de agnes y no hay respuesta de nemotron después
        print(f"MENSAJE PENDIENTE: #{ultimo_numero:03d} ({ultimo_nombre}) es de agnes y no tiene respuesta de nemotron.")
        print("Debes responderlo antes de continuar con cualquier otra tarea.")
        sys.exit(1)
    else:
        print(f"Canal al día. Último mensaje: #{ultimo_numero:03d} ({ultimo_nombre}, {ultimo_emisor}).")
        sys.exit(0)

if __name__ == "__main__":
    main()
