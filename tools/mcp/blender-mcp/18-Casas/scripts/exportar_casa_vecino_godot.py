#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Export a Godot de `casa_vecino` (CASA_05 de 18-BIS, autoria de MiMo).

Por que un script dedicado y NO `scripts-reutilizables/exportar_godot.py`:
  * `exportar_godot.py::planificar()` solo lista `.blend` en la RAIZ de cada
    modulo de la whitelist MODULOS. `18-BIS-Casas-Grandes` no esta en MODULOS
    y sus `.blend` viven en `CASA_05_CASA_VECINO/<LOD>/` (E-63 no aplica:
    aqui el GLB YA esta exportado, lo que falta es llevarlo al juego).
  * No se re-exporta desde Blender: eso cambiaria la geometria ya medida por
    MiMo (INFORME.json) con otra version del motor. Se COPIA el GLB canonico
    y se verifica sha256 origen == destino.

Garantias:
  * Nunca sobrescribe un destino existente.
  * Valida los 12 checks positivos de `verificar_casa_vecino.analizar()`
    ANTES y DESPUES de la copia, en cada LOD.
  * Toma baseline sha256 de TODOS los GLB existentes en assets/3d y exige
    que ninguno cambie (worktree compartido: no mutar trabajo ajeno).
  * `--dry` planea sin escribir.

Uso:
    python exportar_casa_vecino_godot.py --dry
    python exportar_casa_vecino_godot.py
"""

import hashlib
import os
import shutil
import sys

_AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, _AQUI)
import verificar_casa_vecino as guarda  # noqa: E402

RAIZ = os.path.abspath(os.path.join(_AQUI, '..', '..', '..', '..', '..'))
SRC = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp',
                   '18-BIS-Casas-Grandes', 'CASA_05_CASA_VECINO')
DST_ROOT = os.path.join(RAIZ, 'game', 'isla-ancestral', 'assets', '3d')
NOMBRE_DESTINO = '18-Casas_casa_vecino.glb'

LODS = (
    ('ALTA', 'alta'),
    ('MEDIA', 'media'),
    ('BAJA', 'baja'),
)


def sha(path):
    with open(path, 'rb') as f:
        return hashlib.sha256(f.read()).hexdigest()


def baseline(root):
    """sha256 de todos los GLB ya presentes en el arbol de destino."""
    out = {}
    for carpeta, _, archivos in os.walk(root):
        for nombre in archivos:
            if nombre.endswith('.glb'):
                p = os.path.join(carpeta, nombre)
                out[p] = sha(p)
    return out


def validar(path, lod):
    checks, datos = guarda.analizar(path, lod)
    malos = [(n, d) for n, ok, d in checks if not ok]
    if malos:
        raise AssertionError('%s no pasa la guardia: %s' % (path, malos))
    if len(checks) != 12:
        raise AssertionError('%s: %d checks, se esperaban 12' % (path, len(checks)))
    return datos


def main(argv):
    dry = '--dry' in argv
    pares = []
    for origen_dir, lod in LODS:
        src = os.path.join(SRC, origen_dir,
                           'SM_CASA_05_CASA_VECINO_%s.glb' % origen_dir)
        dst = os.path.join(DST_ROOT, lod, NOMBRE_DESTINO)
        if not os.path.isfile(src):
            raise AssertionError('fuente ausente: %s' % src)
        if os.path.exists(dst):
            raise AssertionError('destino YA EXISTE (no se sobrescribe): %s' % dst)
        pares.append((lod, src, dst))

    antes = baseline(DST_ROOT)
    print('BASELINE: %d GLB existentes en assets/3d' % len(antes))

    # Verificacion POSITIVA de las fuentes antes de tocar el juego.
    for lod, src, _ in pares:
        d = validar(src, lod)
        print('FUENTE %-5s OK 12/12  %7d B  y=[%.4f, %.4f] verts=%-5d mats=%d sha=%s' %
              (lod, d['bytes'], d['y_min'], d['y_max'], d['vertices'],
               d['materiales'], sha(src)[:12]))

    if dry:
        print('DRY: 3 destinos planeados, 0 escritos')
        for lod, _, dst in pares:
            print('   %-5s -> %s' % (lod, dst))
        return 0

    for lod, src, dst in pares:
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.copyfile(src, dst)
        if sha(src) != sha(dst):
            raise AssertionError('sha256 origen != destino en %s' % dst)
        d = validar(dst, lod)
        print('DESTINO %-5s OK 12/12 %7d B  y=[%.4f, %.4f] sha=%s' %
              (lod, d['bytes'], d['y_min'], d['y_max'], sha(dst)[:12]))

    despues = baseline(DST_ROOT)
    mutados = [p for p, h in antes.items() if despues.get(p) != h]
    if mutados:
        raise AssertionError('GLB preexistentes MUTADOS: %s' % mutados)
    nuevos = sorted(set(despues) - set(antes))
    print('INTEGRIDAD: %d GLB preexistentes INTACTOS, %d nuevos' %
          (len(antes), len(nuevos)))
    for p in nuevos:
        print('   NUEVO %s (%d B)' % (p, os.path.getsize(p)))
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main(sys.argv[1:]))
    except AssertionError as e:
        print('ABORTADO: %s' % e)
        sys.exit(1)
