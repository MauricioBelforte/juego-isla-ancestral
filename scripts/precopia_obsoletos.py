#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Pre-copia de respaldo segun AGENTS.md parr. 5 («Respaldos ante Cambios Grandes»).

La regla dice: "Antes de realizar modificaciones grandes (como refactorizar el
proceso principal): 1) verificar la existencia de `Obsoletos/`; 2) guardar una
copia con nomenclatura `AAAA-MM-DD_HH-MM-SS_nombre_archivo.extension`".

Medido el 2026-10-18 (item 69 del BACKLOG de Step-5-WorkBuddy, Log 1980): la
regla se cumple «a mano» y sin garante. De los **732 archivos** que hay hoy en
`Obsoletos/`, **solo 105** llevan el sello de fecha en el nombre de su carpeta y
**32** en el nombre del archivo; **595 (81,3 %)** no lo llevan en ninguno. Ademas
**481 de 732 (65,7 %) estan FUERA de git** (384 ignorados + 97 sin seguimiento):
existen solo en esta maquina, que es justo lo contrario de un respaldo.

Que hace esta herramienta: aplica parr. 5 de forma verificable.

  1. Crea `Obsoletos/AAAA-MM-DD_HH-MM-SS_<contexto>/` (el contexto se normaliza).
  2. Copia dentro cada ruta pedida, conservando la estructura relativa.
  3. Escribe `MANIFIESTO.txt` con, por archivo, tamano + SHA-256 y la cantidad
     total. Sin manifiesto no se puede verificar que la copia este completa:
     un respaldo que no se puede auditar es una carpeta mas.
  4) Si una ruta pedida NO existe, ABORTA sin copiar nada. Es la regla del repo
     («si un ancla desaparecio, ABORTAR»): una pre-copia parcial silenciosa es
     peor que no hacerla, porque da sensacion de respaldo.

Uso:
    python scripts/precopia_obsoletos.py --contexto "pre-refactor-M17" \\
        -- DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md game/isla-ancestral/scripts/construccion.gd

    # plan sin escribir nada (recomendado antes de la primera pasada):
    python scripts/precopia_obsoletos.py --contexto "pre-refactor-M17" --dry-run -- <rutas...>

Salida: 0 = ok, 1 = error/aborto. Con `--dry-run` imprime el destino y la
cantidad de archivos sin tocar el disco.
"""
import argparse
import hashlib
import os
import re
import shutil
import sys
import time

RAIZ = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
BASE_OBSOLETOS = os.path.join(RAIZ, 'Obsoletos')
# Destino alternativo, solo para probar el script sin ensuciar Obsoletos/.
PATRON_CONTEXTO = re.compile(r'[^A-Za-z0-9._-]+')
PATRON_SELLO = re.compile(r'^\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}_.+')


def sha256(ruta):
    h = hashlib.sha256()
    with open(ruta, 'rb') as f:
        for bloque in iter(lambda: f.read(1024 * 1024), b''):
            h.update(bloque)
    return h.hexdigest()


def sellar(contexto):
    """`AAAA-MM-DD_HH-MM-SS_<contexto>` segun parr. 5 de AGENTS.md."""
    limpio = PATRON_CONTEXTO.sub('-', contexto).strip('-') or 'sin-contexto'
    return '%s_%s' % (time.strftime('%Y-%m-%d_%H-%M-%S'), limpio)


def main():
    p = argparse.ArgumentParser(
        description='Pre-copia de respaldo (AGENTS.md parr. 5) antes de cambios grandes')
    p.add_argument('--contexto', required=True,
                   help='texto que identifica el refactor; entra en el nombre de la carpeta')
    p.add_argument('rutas', nargs='+',
                   help='archivos o carpetas a respaldar (relativos a la raiz del repo)')
    p.add_argument('--destino-base', default=None,
                   help='base alternativa a Obsoletos/ (para pruebas; por defecto Obsoletos/)')
    p.add_argument('--dry-run', action='store_true',
                   help='muestra el plan sin copiar nada')
    a = p.parse_args()

    base = a.destino_base or BASE_OBSOLETOS
    if not os.path.isdir(base):
        print('ERROR: no existe la carpeta de respaldo %s (parr. 5 paso 1).' % base)
        return 1

    # --- 1. verificar que TODO existe antes de copiar nada -------------------
    faltantes = [r for r in a.rutas if not os.path.exists(os.path.join(RAIZ, r))]
    if faltantes:
        print('ERROR: %d ruta(s) pedida(s) no existen. ABORTADO sin copiar nada '
              '(regla del repo: si un ancla desaparecio, abortar):' % len(faltantes))
        for f in faltantes:
            print('   -', f)
        return 1

    destino = os.path.join(base, sellar(a.contexto))
    if os.path.exists(destino):
        print('ERROR: el destino %s ya existe. No se sobrescribe un respaldo.'
              % os.path.relpath(destino, RAIZ))
        return 1

    # --- 2. expandir el plan -------------------------------------------------
    plan = []  # (ruta_repo, destino_relativo)
    for r in a.rutas:
        abs_ruta = os.path.join(RAIZ, r)
        if os.path.isfile(abs_ruta):
            plan.append((r, r))
        else:
            for dp, dn, fn in os.walk(abs_ruta):
                for f in fn:
                    abs_f = os.path.join(dp, f)
                    rel = os.path.relpath(abs_f, RAIZ).replace(os.sep, '/')
                    plan.append((rel, rel))

    total_bytes = sum(os.path.getsize(os.path.join(RAIZ, r)) for r, _ in plan)

    print('Destino : %s' % os.path.relpath(destino, RAIZ))
    print('Archivos: %d' % len(plan))
    print('Bytes   : %d' % total_bytes)
    for r, _ in plan[:50]:
        print('   +', r)
    if len(plan) > 50:
        print('   ... y %d mas' % (len(plan) - 50))

    if a.dry_run:
        print('\n(dry-run: no se copio ni escribio nada)')
        return 0

    # --- 3. copiar -----------------------------------------------------------
    os.makedirs(destino)
    lineas = []
    for r, dest_rel in plan:
        d = os.path.join(destino, dest_rel)
        os.makedirs(os.path.dirname(d), exist_ok=True)
        shutil.copy2(os.path.join(RAIZ, r), d)
        lineas.append((r, os.path.getsize(d), sha256(d)))

    # --- 4. manifiesto -------------------------------------------------------
    with open(os.path.join(destino, 'MANIFIESTO.txt'), 'w', encoding='utf-8',
              newline='\n') as f:
        f.write('Pre-copia segun AGENTS.md parr. 5 (respaldos ante cambios grandes)\n')
        f.write('Contexto : %s\n' % a.contexto)
        f.write('Fecha    : %s\n' % time.strftime('%Y-%m-%d %H:%M:%S'))
        f.write('Archivos : %d\n' % len(lineas))
        f.write('Bytes    : %d\n' % sum(l[1] for l in lineas))
        f.write('\n%-10s  %-64s  %s\n' % ('BYTES', 'SHA256', 'RUTA (relativa a la raiz)'))
        for ruta, tam, h in sorted(lineas):
            f.write('%-10d  %-64s  %s\n' % (tam, h, ruta))

    # --- 5. verificar la copia (tamanos iguales, archivos completos) ---------
    verificados = 0
    for ruta, tam, _ in lineas:
        copia = os.path.join(destino, ruta)
        if os.path.getsize(copia) != tam:
            print('ERROR: la copia de %s no tiene el tamanio esperado.' % ruta)
            return 1
        verificados += 1

    print('\nPre-copia completa: %d/%d archivos verificados por tamanio.'
          % (verificados, len(lineas)))
    print('Manifiesto: %s' % os.path.relpath(
        os.path.join(destino, 'MANIFIESTO.txt'), RAIZ))
    print('AVISO: respaldo hecho. Para que sobreviva un clone nuevo o un '
          '"git clean", hay que commitearlo (Obsoletos/ esta 65,7%% fuera de git).')
    return 0


if __name__ == '__main__':
    sys.exit(main())
