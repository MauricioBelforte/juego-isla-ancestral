#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Prueba el guardian por INYECCION: muta reservar_log.py para que vuelva a
crear el archivo de reserva retirado y comprueba que la sonda FALLA.

Un guardian que no falla ante una regresion real es un falso verde. Aqui se
inyecta exactamente el comportamiento que el commit 2ac8b4b elimino.
"""
import hashlib
import shutil
import subprocess
import sys
import os
import tempfile

PY = sys.executable
REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
OBJETIVO = os.path.join(REPO, 'scripts', 'reservar_log.py')
BACKUP = os.path.join(tempfile.gettempdir(), 'backup_reservar_log.py')
SONDA = os.path.join(REPO, 'tools', 'logs', 'test_reservar_log_pool.py')

ANCLA = "    if saltados:\n"
MUTACION = (
    "    os.makedirs(RESERVAS, exist_ok=True)\n"
    "    with open(os.path.join(RESERVAS, '%d-inyectado.txt' % num), 'w') as _f:\n"
    "        _f.write('inyectado\\n')\n"
    "    if saltados:\n"
)


def sha(p):
    with open(p, 'rb') as f:
        return hashlib.sha256(f.read()).hexdigest()


def main():
    original = sha(OBJETIVO)
    print('sha original: %s' % original[:16])
    shutil.copy2(OBJETIVO, BACKUP)
    try:
        with open(OBJETIVO, 'r', encoding='utf-8') as f:
            texto = f.read()
        assert ANCLA in texto, 'ancla no encontrada: %r' % ANCLA
        with open(OBJETIVO, 'w', encoding='utf-8', newline='') as f:
            f.write(texto.replace(ANCLA, MUTACION, 1))
        print('mutacion aplicada (recrea Logs/reservas/NNN-inyectado.txt)')

        r = subprocess.run([PY, SONDA], capture_output=True, text=True, cwd=REPO)
        salida = r.stdout + r.stderr
        fallos = [l.strip() for l in salida.splitlines() if '[FALLO]' in l]
        print('--- salida de la sonda (resumen) ---')
        for l in salida.splitlines():
            if any(k in l for k in ('checks', 'fallos', 'RESULTADO', 'bloques ejecutados')):
                print('   %s' % l)
        print('fallos detectados: %d' % len(fallos))
        for l in fallos:
            print('   %s' % l)

        if r.returncode == 1 and fallos:
            print('\nGUARDIAN OK: la sonda FALLA ante la regresion inyectada (no es falso verde)')
            return 0
        print('\nGUARDIAN ROTO: la sonda devolvio %d y %d fallos -> falso verde'
              % (r.returncode, len(fallos)))
        return 1
    finally:
        shutil.copy2(BACKUP, OBJETIVO)
        restaurado = sha(OBJETIVO)
        print('\nsha restaurado: %s -> %s' % (restaurado[:16],
                                             'IDENTICO' if restaurado == original else 'DISTINTO!'))
        os.remove(BACKUP)
        if restaurado != original:
            print('ABORTAR: el archivo no se restauro igual')
            return 2
    return 0


if __name__ == '__main__':
    sys.exit(main())
