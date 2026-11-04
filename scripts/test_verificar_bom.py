#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Regression end-to-end de scripts/verificar_bom.py (AGENTS.md 28).

No prueba funciones sueltas: ejecuta el CLI REAL por subprocess sobre un repo
temporal con un AGENTS.md marcador (raiz_repo() lo encuentra al subir desde
scripts/), inyecta BOM/UTF-16/U+FEFF y mide el exit code.

Diseno por las reglas del proyecto:
  - guardia probada EN ROJO (BOM inyectado -> rc 1) y EN VERDE (rc 0);
  - control negativo (archivo limpio NO se reporta) para detectar un scanner
    que "ve todo" y por eso nunca falla;
  - inyeccion de fallo de git para probar el fail-closed de --fix;
  - CHECKS_MINIMOS medido en verde, nunca estimado;
  - muestra vacia / suite que no corrio -> CIEGO, exit 3 (no falso verde).

Salidas: 0 = todos los checks, 1 = fallo(s), 3 = CIEGO.
"""
import hashlib
import os
import shutil
import subprocess
import sys
import tempfile

ORIGEN = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                      'verificar_bom.py')
BOM = b'\xef\xbb\xbf'
CHECKS_MINIMOS = 26  # MEDIDO en verde el 2026-11-04 (26 checks / 0 fallos)
CHECKS = 0
FALLOS = 0
ROOTS = []


def check(cond, msg):
    global CHECKS, FALLOS
    CHECKS += 1
    if cond:
        print('  [OK]   %s' % msg)
    else:
        FALLOS += 1
        print('  [FAIL] %s' % msg)


def escribir(ruta, datos):
    d = os.path.dirname(ruta)
    if d and not os.path.isdir(d):
        os.makedirs(d)
    with open(ruta, 'wb') as fh:
        fh.write(datos)


def leer(ruta):
    with open(ruta, 'rb') as fh:
        return fh.read()


def sha(ruta):
    return hashlib.sha256(leer(ruta)).hexdigest()


def nuevo_root():
    tmp = tempfile.mkdtemp(prefix='bomgate_')
    ROOTS.append(tmp)
    escribir(os.path.join(tmp, 'AGENTS.md'), b'# marcador de raiz\n')
    os.makedirs(os.path.join(tmp, 'scripts'))
    shutil.copyfile(ORIGEN, os.path.join(tmp, 'scripts', 'verificar_bom.py'))
    subprocess.run(['git', 'init', '-q'], cwd=tmp, check=True,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return tmp


def correr(tmp, *args):
    p = subprocess.run(
        [sys.executable, os.path.join(tmp, 'scripts', 'verificar_bom.py')]
        + list(args), cwd=tmp, stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT)
    return p.returncode, p.stdout.decode('utf-8', 'replace')


def escenario_deteccion():
    print('A. Deteccion por ruta real (guardia EN ROJO por inyeccion)')
    tmp = nuevo_root()
    fixtures = [
        ('limpio.md', b'sin bom\n'),
        ('con_bom.md', BOM + b'con bom\n'),
        ('utf16.md', b'\xff\xfe' + 'hola'.encode('utf-16-le')),
        ('embebido.md', b'a' + BOM + b'b\n'),
        ('.github/workflow.yml', BOM + b'name: x\n'),
        ('.oculto/oculto.md', BOM + b'x\n'),
        ('Obsoletos/backup.md', BOM + b'x\n'),
        ('Godot/user.md', BOM + b'x\n'),
        ('no_texto.bin', BOM + b'x\n'),
    ]
    for r, datos in fixtures:
        escribir(os.path.join(tmp, *r.split('/')), datos)
    check(len(fixtures) == 9, 'muestra de 9 fixtures inyectados (no vacia)')
    rc, out = correr(tmp)
    check(rc == 1, 'gate falla con BOM inyectado (rc=%d)' % rc)
    check('Archivos con BOM: 3' in out,
          'cuenta 3 bloqueantes (BOM + UTF-16 + .github)')
    check('UTF-16 detectado' in out, 'UTF-16 se reporta como fallo duro')
    check('U+FEFF EMBEBIDO' in out, 'U+FEFF embebido se reporta como aviso')
    check('.github/workflow.yml' in out, '.github NO se salta')
    check('oculto.md' not in out, 'directorio oculto se salta')
    check('backup.md' not in out, 'Obsoletos/ se salta')
    check('user.md' not in out, 'Godot/ (user://) se salta')
    check('no_texto.bin' not in out, 'extension no textual se salta')
    check('limpio.md' not in out,
          'archivo limpio NO se reporta (control negativo)')
    return tmp


def escenario_verde(tmp):
    print('B. Verde (sin bloqueantes, persiste el aviso U+FEFF)')
    for r in ('con_bom.md', 'utf16.md', '.github/workflow.yml'):
        os.remove(os.path.join(tmp, *r.split('/')))
    rc, out = correr(tmp)
    check(rc == 0, 'gate verde tras quitar los 3 bloqueantes (rc=%d)' % rc)
    check('U+FEFF EMBEBIDO' in out, 'el aviso U+FEFF sigue visible en verde')
    rc2, _ = correr(tmp, '--estricto')
    check(rc2 == 1, '--estricto convierte U+FEFF en fallo (rc=%d)' % rc2)


def escenario_fix():
    print('C. --fix: respeta .gitignore y falla CERRADO si git no responde')
    tmp = nuevo_root()
    escribir(os.path.join(tmp, '.gitignore'), b'ignorado.md\n')
    v = BOM + b'contenido versionado\n'
    i = BOM + b'contenido ignorado\n'
    escribir(os.path.join(tmp, 'versionado.md'), v)
    escribir(os.path.join(tmp, 'ignorado.md'), i)
    escribir(os.path.join(tmp, 'limpio.md'), b'limpio\n')
    sha_i = sha(os.path.join(tmp, 'ignorado.md'))
    sha_l = sha(os.path.join(tmp, 'limpio.md'))

    rc, out = correr(tmp, '--fix')
    check(rc == 0, '--fix termina verde (rc=%d)' % rc)
    check(leer(os.path.join(tmp, 'versionado.md')) == v[3:],
          'versionado: solo se quitaron 3 bytes, resto byte-exacto')
    check(leer(os.path.join(tmp, 'ignorado.md')) == i,
          'ignorado: NO mutado por el guardia .gitignore')
    check(sha(os.path.join(tmp, 'ignorado.md')) == sha_i,
          'ignorado: sha256 sin cambios')
    check(sha(os.path.join(tmp, 'limpio.md')) == sha_l,
          'limpio: sha256 sin cambios')
    check('Omitidos 1 archivo' in out,
          'informa el archivo omitido, no lo calla')
    check(not os.path.exists(os.path.join(tmp, 'versionado.md.bomfix.tmp')),
          'no quedan temporales .bomfix.tmp (escritura atomica)')

    # INYECCION EN ROJO del guardia: sin repo git, check-ignore falla.
    # Un fix que adivinaria aca mutaria archivos que no puede clasificar.
    shutil.rmtree(os.path.join(tmp, '.git'))
    escribir(os.path.join(tmp, 'versionado.md'), v)
    rc2, out2 = correr(tmp, '--fix')
    check(rc2 == 1, 'sin git: --fix aborta (rc=%d)' % rc2)
    check('ABORTADO' in out2, 'sin git: aborta de forma ruidosa')
    check(leer(os.path.join(tmp, 'versionado.md')) == v,
          'sin git: fallo cerrado, NINGUN archivo mutado')


def escenario_ceguera():
    print('D. Control de ceguera: arbol sin fixtures de texto')
    tmp = nuevo_root()
    rc, out = correr(tmp)
    check(rc == 0, 'arbol sin texto da verde (rc=%d)' % rc)
    check('Sin BOM' in out,
          'arbol vacio informa explicitamente, no es un verde mudo')


def main():
    try:
        a = escenario_deteccion()
        escenario_verde(a)
        escenario_fix()
        escenario_ceguera()
    finally:
        for r in ROOTS:
            shutil.rmtree(r, ignore_errors=True)
    print('')
    print('checks=%d fallos=%d minimo=%d' % (CHECKS, FALLOS, CHECKS_MINIMOS))
    if CHECKS == 0 or CHECKS < CHECKS_MINIMOS:
        print('CIEGO: la suite no corrio todos sus bloques')
        return 3
    return 1 if FALLOS else 0


if __name__ == '__main__':
    sys.exit(main())
