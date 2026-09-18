#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Sonda aislada: protocolo v3 en scripts/reservar_log.py (BUG-049, 2a parte).

Contrato que se verifica (alineado con la consolidacion del dueño, commit 2ac8b4b,
y AGENTS.md 6.1 / 6.1.a / 6.1.d):
  1. `--reservar` CONSUME la primera linea de Logs/NUMEROS_DISPONIBLES.txt.
  2. `--reservar` NO crea NINGUN archivo: ni Logs/reservas/NNN-*.txt ni
     Logs/ULTIMO_NUMERO.txt. El numero es el unico "claim".
  3. `--estado` sigue detectando conflictos REALES (reserva doble, colision,
     numero reservado y ademas escrito, doble asignador) pero NO falla solo
     porque existan reservas heredadas del mecanismo retirado.
  4. Un BOM al inicio del pool no puede ocultar el primer numero.

Todo sobre un arbol temporal: no toca el repo. Cada bloque se cierra con _fin();
una excepcion se registra como FALLO y los bloques siguientes SIGUEN corriendo
(un crash no puede esconder el resto). Al final _summary() nombra los bloques que
no corrieron.
"""
import importlib.util
import io
import os
import shutil
import sys
import tempfile
from contextlib import contextmanager, redirect_stdout

AQUI = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(AQUI, '..', '..'))
RUTA = os.path.join(REPO, 'scripts', 'reservar_log.py')

CHECKS_MINIMOS = 22
ESPERADOS = ['A', 'B', 'C', 'D', 'E', 'F', 'G']
BOM = b'\xef\xbb\xbf'
_ejecutados = []
_fallos = []
_total = 0


def _ok(bloque, cond, msg):
    global _total
    _total += 1
    if cond:
        print('  [ok]   %s' % msg)
    else:
        print('  [FALLO] %s' % msg)
        _fallos.append('%s: %s' % (bloque, msg))


@contextmanager
def bloque(nombre):
    print('%s) %s' % (nombre[0], nombre[1]))
    try:
        yield
    except Exception as e:  # noqa: BLE001 - la sonda debe sobrevivir y reportar
        print('  [FALLO] excepcion no controlada: %r' % e)
        _fallos.append('%s: excepcion %r' % (nombre[0], e))
    finally:
        _ejecutados.append(nombre[0])
        print('  -- bloque %s cerrado --' % nombre[0])


def cargar_modulo(tmp):
    """Importa reservar_log.py apuntando a un arbol temporal (no toca el repo)."""
    spec = importlib.util.spec_from_file_location('reservar_log_probe', RUTA)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    logs = os.path.join(tmp, 'Logs')
    os.makedirs(logs, exist_ok=True)
    mod.RAIZ = tmp  # evita relpath entre unidades distintas en Windows
    mod.LOGS = logs
    mod.RESERVAS = os.path.join(logs, 'reservas')
    mod.DISPONIBLES = os.path.join(logs, 'NUMEROS_DISPONIBLES.txt')
    return mod


def escribir_pool(mod, numeros, eol=b'\r\n', con_bom=False):
    datos = eol.join(str(n).encode('ascii') for n in numeros) + eol
    if con_bom:
        datos = BOM + datos
    with open(mod.DISPONIBLES, 'wb') as f:
        f.write(datos)


def crear_reserva(mod, nombre):
    os.makedirs(mod.RESERVAS, exist_ok=True)
    with open(os.path.join(mod.RESERVAS, nombre), 'w', encoding='utf-8') as f:
        f.write('Reserva de Log\n')


def limpiar_reservas(mod):
    if os.path.isdir(mod.RESERVAS):
        for f in os.listdir(mod.RESERVAS):
            os.remove(os.path.join(mod.RESERVAS, f))


def leer_pool(mod):
    with open(mod.DISPONIBLES, 'rb') as f:
        return f.read()


def capturar(fn, *a):
    buf = io.StringIO()
    with redirect_stdout(buf):
        rc = fn(*a)
    return rc, buf.getvalue()


def main():
    tmp = tempfile.mkdtemp(prefix='probe_reservar_')
    try:
        # --- A: consumir_primero_del_pool -----------------------------------
        with bloque(('A', 'consumir_primero_del_pool')):
            mod = cargar_modulo(tmp)
            escribir_pool(mod, [1005, 1006, 1007])
            num = mod.consumir_primero_del_pool()
            _ok('A', num == 1005, 'devuelve el primero (1005), no el ultimo: %r' % num)
            nums, _, _ = mod.numeros_disponibles()
            _ok('A', nums == [1006, 1007], 'el pool pierde solo la primera linea: %s' % nums)
            raw = leer_pool(mod)
            crlf = raw.count(b'\r\n')
            sueltos = raw.count(b'\n') - crlf
            _ok('A', crlf == 2 and sueltos == 0,
                'preserva CRLF sin LF sueltos (trampa 69): crlf=%d sueltos=%d' % (crlf, sueltos))
            _ok('A', not raw.startswith(BOM), 'sin BOM (seccion 28)')

        # --- B: cmd_reservar NO crea archivos (nucleo del cambio) -----------
        with bloque(('B', 'cmd_reservar consume el pool y NO crea archivos')):
            mod = cargar_modulo(tmp)
            escribir_pool(mod, [1010, 1011])
            rc, out = capturar(mod.cmd_reservar, 'probe', 'M99')
            _ok('B', rc == 0, 'exit 0: %r' % rc)
            _ok('B', '1010' in out, 'toma el 1010 (primero del pool)')
            _ok('B', 'v3' in out, 'declara el origen v3 en la salida')
            _ok('B', not os.path.isdir(mod.RESERVAS),
                'NO crea Logs/reservas/ (mecanismo retirado en 2ac8b4b)')
            _ok('B', not os.path.exists(os.path.join(mod.LOGS, 'ULTIMO_NUMERO.txt')),
                'NO escribe ULTIMO_NUMERO.txt')
            _ok('B', not hasattr(mod, 'ULTIMO'),
                'el modulo ya no define la constante ULTIMO (mecanismo retirado)')
            nums, _, _ = mod.numeros_disponibles()
            _ok('B', nums == [1011], 'el 1010 sale del pool: %s' % nums)

        # --- C: sin pool -> modo legado -------------------------------------
        with bloque(('C', 'sin pool cae a modo legado')):
            mod = cargar_modulo(tmp)
            if os.path.exists(mod.DISPONIBLES):
                os.remove(mod.DISPONIBLES)
            with open(os.path.join(mod.LOGS, '1020-algo.md'), 'w', encoding='utf-8') as f:
                f.write('x\n')
            rc, out = capturar(mod.cmd_reservar, 'probe', 'M99')
            _ok('C', rc == 0 and 'legado' in out, 'usa max+1 y lo declara: %r' % rc)
            _ok('C', '1021' in out, 'asigna 1021 (max 1020 + 1)')

        # --- D: INYECCION - doble asignador detectado -----------------------
        with bloque(('D', 'inyeccion: doble asignador')):
            mod = cargar_modulo(tmp)
            limpiar_reservas(mod)
            crear_reserva(mod, '1030-hy3-M53.txt')
            # el 1030 SIGUE en el pool: es exactamente el estado que produjo la
            # colision del 1001 (hy3 reservo por la herramienta y DeepSeek lo
            # tomo de la lista).
            escribir_pool(mod, [1030, 1031])
            rc, out = capturar(mod.cmd_estado)
            _ok('D', rc == 1, 'exit 1 ante el doble asignador: %r' % rc)
            _ok('D', 'DOBLE ASIGNADOR 1030' in out, 'nombra el numero culpable')
            _ok('D', '1030-hy3-M53.txt' in out, 'nombra la reserva culpable')

        # --- E: reserva heredada suelta NO es conflicto ---------------------
        with bloque(('E', 'reserva heredada sola: aviso, no conflicto')):
            mod = cargar_modulo(tmp)
            limpiar_reservas(mod)
            # 1040 reservado y YA sacado del pool (que arranca en 1041): el
            # archivo heredado sobra, pero no duplica nada -> no debe fallar.
            crear_reserva(mod, '1040-x-M1.txt')
            escribir_pool(mod, [1041])
            rc, out = capturar(mod.cmd_estado)
            _ok('E', rc == 0, 'exit 0 con reserva heredada que no duplica: %r' % rc)
            _ok('E', 'AVISO' in out and '1040-x-M1.txt' in out,
                'la reporta como AVISO con el nombre del archivo')
            _ok('E', 'DOBLE ASIGNADOR' not in out, 'no inventa hallazgos')

        # --- F: guardas previas intactas ------------------------------------
        with bloque(('F', 'no regresion de las guardas previas')):
            mod = cargar_modulo(tmp)
            limpiar_reservas(mod)
            crear_reserva(mod, '1050-a-M1.txt')
            crear_reserva(mod, '1050-b-M2.txt')
            escribir_pool(mod, [1051])
            rc, out = capturar(mod.cmd_estado)
            _ok('F', rc == 1 and 'RESERVA DOBLE 1050' in out, 'detecta reserva doble (BUG-049)')
            rc, _ = capturar(mod.cmd_check, 1051)
            _ok('F', rc == 0, '--check 1051 -> libre (exit 0)')
            rc, _ = capturar(mod.cmd_check, 1050)
            _ok('F', rc == 1, '--check 1050 -> reservado (exit 1)')

        # --- G: BOM no puede ocultar el primer numero -----------------------
        with bloque(('G', 'inyeccion: BOM en el pool')):
            mod = cargar_modulo(tmp)
            limpiar_reservas(mod)
            escribir_pool(mod, [1060, 1061], con_bom=True)
            nums, _, _ = mod.numeros_disponibles()
            _ok('G', nums == [1060, 1061],
                'con BOM sigue viendo el primero (1060), no 495 de 496: %s' % nums)
            num = mod.consumir_primero_del_pool()
            _ok('G', num == 1060, 'lo consume igualmente: %r' % num)
            _ok('G', not leer_pool(mod).startswith(BOM),
                'consumir deja el pool sin BOM (se autocura)')
            escribir_pool(mod, [1062, 1063], con_bom=True)
            rc, out = capturar(mod.cmd_estado)
            _ok('G', rc == 1 and 'BOM' in out, '--estado denuncia el BOM (exit 1): %r' % rc)

    finally:
        shutil.rmtree(tmp, ignore_errors=True)

    # --- resumen (nombra lo que falto) --------------------------------------
    print('\n' + '=' * 62)
    faltan = [b for b in ESPERADOS if b not in _ejecutados]
    print('bloques ejecutados : %d/%d %s' % (len(_ejecutados), len(ESPERADOS), _ejecutados))
    if faltan:
        print('BLOQUES QUE NO CORRIERON: %s' % faltan)
    print('checks             : %d (piso %d)' % (_total, CHECKS_MINIMOS))
    print('fallos             : %d' % len(_fallos))
    for f in _fallos:
        print('   - %s' % f)
    if faltan or _total < CHECKS_MINIMOS:
        print('RESULTADO: INVALIDO (bloques faltantes o bajo el piso de checks)')
        return 2
    if _fallos:
        print('RESULTADO: FALLO')
        return 1
    print('RESULTADO: OK')
    return 0


if __name__ == '__main__':
    sys.exit(main())
