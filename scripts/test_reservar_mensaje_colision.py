#!/usr/bin/env python3
"""Tests del fix anti-colision de reservar_mensaje.py (encargo del director msg 190).

Simula exactamente la carrera que provoco la colision del log 1550 con
mimo-v2.6-flash-free: dos sesiones leen el mismo pool a la vez y la primera
crea el archivo antes de que la segunda consuma el numero.

Ejecucion:  python scripts/test_reservar_mensaje_colision.py
Salida:     N PASS, M FAIL  (exit 0 solo si todo pasa)
"""

import os
import re
import shutil
import subprocess
import sys
import tempfile

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MENSAJES = os.path.join(RAIZ, "Mensajes entre modelos")
SCRIPT = os.path.join(RAIZ, "scripts", "reservar_mensaje.py")

CANAL_TEST = "_test-colision"

_passed = 0
_failed = 0


def ok(nombre, condicion, detalle=""):
    global _passed, _failed
    if condicion:
        _passed += 1
        print("  PASS: %s" % nombre)
    else:
        _failed += 1
        print("  FAIL: %s %s" % (nombre, detalle))


def reset_canal(pool_numeros):
    """Crea el canal de prueba fresco con el pool dado."""
    carpeta = os.path.join(MENSAJES, CANAL_TEST)
    if os.path.exists(carpeta):
        shutil.rmtree(carpeta)
    os.makedirs(carpeta)
    with open(os.path.join(carpeta, "NUMEROS_DISPONIBLES.txt"),
              "w", encoding="utf-8", newline="\n") as fh:
        fh.write("\n".join(str(n) for n in pool_numeros) + "\n")
    return carpeta


def reservar(tema, emisor="s2"):
    """Ejecuta reservar_mensaje.py contra el canal de prueba."""
    proc = subprocess.run(
        [sys.executable, SCRIPT, CANAL_TEST, tema, "--emisor", emisor],
        capture_output=True, text=True, cwd=RAIZ)
    return proc.returncode, proc.stdout + proc.stderr


def archivos(carpeta):
    return [f for f in os.listdir(carpeta)
            if f != "NUMEROS_DISPONIBLES.txt" and not f.endswith(".uid")]


def pool_restante(carpeta):
    with open(os.path.join(carpeta, "NUMEROS_DISPONIBLES.txt"),
              encoding="utf-8") as fh:
        return [l.strip() for l in fh if l.strip().isdigit()]


def test_reserva_normal():
    """Caso base: pool sano, sin archivos previos -> reserva el 1."""
    carpeta = reset_canal([1, 2, 3])
    rc, out = reservar("tema-normal")
    ok("reserva normal retorna 0", rc == 0, out)
    creados = archivos(carpeta)
    ok("reserva normal crea 1 archivo", len(creados) == 1, str(creados))
    ok("reserva normal usa el numero 1",
       any(f.startswith("1-") for f in creados), str(creados))
    pool = pool_restante(carpeta)
    ok("reserva normal consume el 1 del pool", "1" not in pool, str(pool))


def test_colision_archivo_preexistente():
    """LA carrera real: el archivo con el numero 1 YA existe en disco
    (creado por otra sesion) pero el pool aun lo ofrece. Debe saltar al 2."""
    carpeta = reset_canal([1, 2, 3])
    # Simula la otra sesion: crea el archivo 1 con el mismo nombre que
    # generaria este script (mismo tema, emisor, segundo de ventana).
    nombre = "1-2026-10-10_01-00-00-s2-a-_test-colision-tema-carrera.md"
    with open(os.path.join(carpeta, nombre), "w", encoding="utf-8") as fh:
        fh.write("# 1 - mensaje ajeno\n")
    rc, out = reservar("tema-carrera")
    ok("colision retorna 0 (encontro otro numero)", rc == 0, out)
    ok("colision NO pisa el archivo del numero 1",
       os.path.exists(os.path.join(carpeta, nombre)))
    creados = [f for f in archivos(carpeta) if f != nombre]
    ok("colision reserva exactamente 1 archivo nuevo",
       len(creados) == 1, str(creados))
    ok("colision salta al numero 2",
       any(f.startswith("2-") for f in creados), str(creados))
    pool = pool_restante(carpeta)
    ok("colision consume el 2 del pool", "2" not in pool, str(pool))
    ok("colision NO deja el 1 en el pool (esta en disco)",
       "1" not in pool, str(pool))


def test_colision_prefijo_sin_fecha():
    """Un archivo existente con prefijo numerico pero SIN formato de fecha
    (como Logs/1550-m64-fix-bug129_...). El check antiguo (regex de fecha)
    no lo detectaba; el fix nuevo cuenta cualquier prefijo NN-."""
    carpeta = reset_canal([1, 2])
    # Archivo ajeno sin formato de fecha: el regex MENSAJE_RE no lo matchea.
    with open(os.path.join(carpeta, "1-m64-fix-bug129-notas.md"),
              "w", encoding="utf-8") as fh:
        fh.write("# notas sueltas\n")
    rc, out = reservar("tema-notas")
    ok("prefijo sin fecha retorna 0", rc == 0, out)
    creados = [f for f in archivos(carpeta) if not f.startswith("1-")]
    ok("prefijo sin fecha reserva el numero 2",
       any(f.startswith("2-") for f in creados), str(creados))


def test_pool_vacio():
    carpeta = reset_canal([])
    rc, out = reservar("tema-imposible")
    ok("pool vacio retorna 3", rc == 3, out)


def main():
    print("=== test_reservar_mensaje_colision.py ===")
    try:
        test_reserva_normal()
        test_colision_archivo_preexistente()
        test_colision_prefijo_sin_fecha()
        test_pool_vacio()
    finally:
        carpeta = os.path.join(MENSAJES, CANAL_TEST)
        if os.path.exists(carpeta):
            shutil.rmtree(carpeta)
    print("========================================")
    print("RESULTADO: %d PASS, %d FAIL" % (_passed, _failed))
    if _failed:
        print("HAY FALLOS - no usar reservar_mensaje.py hasta corregir")
        return 1
    print("TODOS LOS TESTS PASARON")
    return 0


if __name__ == "__main__":
    sys.exit(main())
