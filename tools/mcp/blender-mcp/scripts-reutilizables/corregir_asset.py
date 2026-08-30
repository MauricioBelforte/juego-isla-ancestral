#!/usr/bin/env python3
# corregir_asset.py — Aplica correcciones geometricas (escala, rotacion, asentado)
# a TODAS las variantes de un asset (source, _media, _baja) y guarda cada blend.
#
# Motivacion: el QA visual 230 encontro assets tumbados, flotando o enterrados que
# el test numerico de grupo (z_min) no detectaba, porque el z_min del GRUPO lo
# logra un objeto chico mientras el cuerpo principal queda levantado.
#
# Uso:
#   python corregir_asset.py <modulo> <asset_lowpoly> [opciones] [asset2...]
#
# Opciones (se aplican en este orden: escala -> rotacion -> asentado):
#   --escalar F        escala todo el grupo por F alrededor de su centro
#   --escalar-z F      escala solo el eje Z (se multiplica con --escalar).
#                      Util para assets planos como estrella_mar: 4 cm de
#                      espesor para 47 cm de ancho no se distingue en camara.
#   --rotar EJE GRAD   rota todo el grupo alrededor de su centro (EJE = X|Y|Z)
#   --asentar Z        mueve el grupo para que el z_min del GRUPO sea Z (def. 0.045)
#   --mover-obj PATRON Z   mueve SOLO los objetos que matchean para que su z_min
#                          sea Z (no arrastra al resto del grupo). Para piezas que
#                          cuelgan debajo del cuerpo y quedan enterradas al asentar.
#   --asentar-obj PATRON Z
#                      mueve el grupo para que el z_min de los objetos cuyo nombre
#                      contenga PATRON sea Z. Usar cuando el cuerpo principal es el
#                      que debe tocar, no el objeto mas bajo del grupo.
#   --variantes a,b,c  por defecto source,media,baja
#   --dry              no guarda, solo informa que haria
#
# Ejemplos:
#   # antorcha acostada en X -> ponerla vertical
#   python corregir_asset.py 13-Herramientas antorcha_mano_lowpoly --rotar Y 90 --asentar 0.045
#   # la roca de veta_hierro flota; los cristales no deben definir el apoyo
#   python corregir_asset.py 15-Recursos veta_hierro_lowpoly --asentar-obj Roca_Hierro 0.045
import sys
import os
import json

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bpy_cliente import blender_command

RAIZ = os.path.abspath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
DIR_BLEND = os.path.join(RAIZ, 'tools', 'mcp', 'blender-mcp')

Z_DEFECTO = 0.045

PLANTILLA = """
import bpy
from mathutils import Vector, Matrix
import math

bpy.ops.wm.open_mainfile(filepath="@@RUTA@@")
bpy.context.view_layer.update()

obs = [o for o in bpy.context.scene.objects
       if o.type == 'MESH' and o.name.startswith('SM_')]
if not obs:
    print('SIN_SM')
    raise SystemExit

def pts_de(objs):
    p = []
    for o in objs:
        for c in o.bound_box:
            p.append(o.matrix_world @ Vector(c))
    return p

def zmin_de(objs):
    return min((q.z for q in pts_de(objs)))

def centro_de(objs):
    p = pts_de(objs)
    mn = [min(q[i] for q in p) for i in range(3)]
    mx = [max(q[i] for q in p) for i in range(3)]
    return Vector([(mn[i] + mx[i]) / 2.0 for i in range(3)])

def dims_de(objs):
    p = pts_de(objs)
    return [max(q[i] for q in p) - min(q[i] for q in p) for i in range(3)]

antes = dims_de(obs)
z_antes = zmin_de(obs)

# --- ESCALA -----------------------------------------------------------------
ESCALA = @@ESCALA@@
ESCALA_Z = @@ESCALAZ@@
if abs(ESCALA - 1.0) > 1e-9 or abs(ESCALA_Z - 1.0) > 1e-9:
    sx = sy = ESCALA
    sz = ESCALA * ESCALA_Z
    c = centro_de(obs)
    M = (Matrix.Translation(c) @ Matrix.Diagonal((sx, sy, sz, 1.0))
         @ Matrix.Translation(-c))
    for o in obs:
        o.matrix_world = M @ o.matrix_world
    bpy.context.view_layer.update()

# --- ROTACION ---------------------------------------------------------------
EJE = '@@EJE@@'
GRAD = @@GRAD@@
if EJE and abs(GRAD) > 1e-9:
    c = centro_de(obs)
    R = Matrix.Rotation(math.radians(GRAD), 4, EJE)
    M = Matrix.Translation(c) @ R @ Matrix.Translation(-c)
    for o in obs:
        o.matrix_world = M @ o.matrix_world
    bpy.context.view_layer.update()

# --- DECIMATE ---------------------------------------------------------------
# E-22: bpy.ops.object.modifier_apply falla por socket ("context is incorrect").
# Se aplica evaluando el depsgraph y reemplazando el mesh data a mano.
RATIO = @@RATIO@@
def tris_de(objs):
    t = 0
    for o in objs:
        o.data.calc_loop_triangles()
        t += len(o.data.loop_triangles)
    return t

tris_antes = tris_de(obs)
if RATIO < 1.0:
    for o in obs:
        for m in [m for m in o.modifiers if m.type == 'DECIMATE']:
            o.modifiers.remove(m)
        md = o.modifiers.new('DeciM166', 'DECIMATE')
        md.ratio = RATIO
        md.use_collapse_triangulate = True
    bpy.context.view_layer.update()
    dg = bpy.context.evaluated_depsgraph_get()
    for o in obs:
        nuevo = bpy.data.meshes.new_from_object(o.evaluated_get(dg))
        viejo = o.data
        o.data = nuevo
        for m in list(o.modifiers):
            o.modifiers.remove(m)
        if viejo.users <= 1:
            bpy.data.meshes.remove(viejo)
    bpy.context.view_layer.update()

# --- ASENTADO ---------------------------------------------------------------
PATRON = '@@PATRON@@'
Z_OBJ = @@ZOBJ@@
MODO = '@@MODO@@'          # 'grupo' | 'objeto' | 'mover' | 'ninguno'
delta = 0.0
base_usada = 'grupo(%d)' % len(obs)
if MODO == 'objeto':
    base = [o for o in obs if PATRON.lower() in o.name.lower()]
    if not base:
        print('AVISO: ningun objeto matchea "%s"; se asenta el grupo' % PATRON)
        base = obs
        base_usada = 'grupo(fallback)'
    else:
        base_usada = ','.join(sorted(o.name for o in base)[:3])
    z0 = zmin_de(base)
    delta = Z_OBJ - z0
    for o in obs:
        o.location.z += delta
    bpy.context.view_layer.update()
elif MODO == 'grupo':
    z0 = zmin_de(obs)
    delta = Z_OBJ - z0
    for o in obs:
        o.location.z += delta
    bpy.context.view_layer.update()
elif MODO == 'mover':
    # mueve SOLAMENTE los objetos que matchean, sin arrastrar al resto.
    # Para piezas que cuelgan por debajo del cuerpo y quedan enterradas.
    sel = [o for o in obs if PATRON.lower() in o.name.lower()]
    if not sel:
        print('AVISO: nada matchea "%s"' % PATRON)
    else:
        z0 = zmin_de(sel)
        d = Z_OBJ - z0
        for o in sel:
            o.location.z += d
        bpy.context.view_layer.update()
        delta = d
        base_usada = ','.join(sorted(o.name for o in sel)[:2])

despues = dims_de(obs)
z_desp = zmin_de(obs)

# --- VEREDICTO --------------------------------------------------------------
tris_desp = tris_de(obs)
aviso = 'OK'
if z_desp > 0.065:
    aviso = 'ATENCION sigue alto (z_min=%.4f)' % z_desp
elif z_desp < 0.025:
    aviso = 'ATENCION hundido (z_min=%.4f)' % z_desp

# presupuesto M166 segun el sufijo del archivo
nomb = bpy.path.basename(bpy.data.filepath).lower()
if nomb.endswith('_baja.blend'):
    techo = 700; perfil = 'BAJA'
elif nomb.endswith('_media.blend'):
    techo = 1500; perfil = 'MEDIA'
else:
    techo = 6000; perfil = 'ALTA/src'
cumple = 'OK' if tris_desp <= techo else 'PASA %d tris de %s' % (tris_desp - techo, perfil)

print('RES|%s|dim %.3fx%.3fx%.3f -> %.3fx%.3fx%.3f|z %.4f -> %.4f|d=%+.4f|tris %d -> %d|%s|%s'
      % (bpy.path.basename(bpy.data.filepath),
         antes[0], antes[1], antes[2], despues[0], despues[1], despues[2],
         z_antes, z_desp, delta, tris_antes, tris_desp, cumple, aviso))

@@GUARDAR@@
"""


def corregir(modulo, asset, escala, escala_z, eje, grad, ratio, modo, patron,
             zobj, variantes, dry):
    for variante in variantes:
        suf = '' if variante == 'source' else '_' + variante
        nombre = asset + suf
        ruta = os.path.join(DIR_BLEND, modulo, nombre + '.blend')
        if not os.path.exists(ruta):
            print('  %-34s (no existe, salteado)' % nombre)
            continue
        rf = ruta.replace('\\', '/')
        guardar = '' if dry else 'bpy.ops.wm.save_mainfile(filepath="%s")' % rf
        guardar = guardar + "\nprint('GUARDADO')" if guardar else "print('DRY')"
        code = (PLANTILLA
                .replace('@@RUTA@@', rf)
                .replace('@@ESCALA@@', repr(float(escala)))
                .replace('@@ESCALAZ@@', repr(float(escala_z)))
                .replace('@@RATIO@@', repr(float(ratio)))
                .replace('@@EJE@@', eje or '')
                .replace('@@GRAD@@', repr(float(grad)))
                .replace('@@PATRON@@', patron or '')
                .replace('@@ZOBJ@@', repr(float(zobj)))
                .replace('@@MODO@@', modo)
                .replace('@@GUARDAR@@', guardar))
        r = blender_command('execute_code', {'code': code}, timeout=90)
        if r.get('status') != 'success':
            print('  %-34s ERROR: %s' % (nombre, json.dumps(r, ensure_ascii=False)[:200]))
            continue
        salida = r.get('result', {}).get('result', '') or ''
        res = [l for l in salida.splitlines() if l.startswith('RES|')]
        if res:
            p = res[0].split('|')
            print('  %-32s %s' % (p[1], p[2]))
            print('  %-32s %s | %s | %s | %s' % ('', p[3], p[5], p[6], p[7]))
        else:
            print('  %-34s (sin RES: %s)' % (nombre, salida[:120]))


def parse_args(argv):
    """Devuelve (modulo, [assets], opciones)."""
    escala, escala_z, eje, grad, ratio = 1.0, 1.0, None, 0.0, 1.0
    modo, patron, zobj = 'ninguno', None, Z_DEFECTO
    variantes = ['source', 'media', 'baja']
    dry = False
    pos = []
    i = 0
    while i < len(argv):
        a = argv[i]
        if a == '--escalar':
            escala = float(argv[i + 1]); i += 2; continue
        if a == '--escalar-z':
            escala_z = float(argv[i + 1]); i += 2; continue
        if a == '--rotar':
            eje = argv[i + 1].upper(); grad = float(argv[i + 2]); i += 3; continue
        if a == '--decimar':
            ratio = float(argv[i + 1]); i += 2; continue
        if a == '--asentar':
            modo = 'grupo'; zobj = float(argv[i + 1]); i += 2; continue
        if a == '--mover-obj':
            modo = 'mover'; patron = argv[i + 1]; zobj = float(argv[i + 2]); i += 3; continue
        if a == '--asentar-obj':
            modo = 'objeto'; patron = argv[i + 1]; zobj = float(argv[i + 2]); i += 3; continue
        if a == '--variantes':
            variantes = argv[i + 1].split(','); i += 2; continue
        if a == '--dry':
            dry = True; i += 1; continue
        pos.append(a); i += 1
    if len(pos) < 2:
        print(__doc__)
        sys.exit(1)
    return pos[0], pos[1:], dict(escala=escala, escala_z=escala_z, eje=eje,
                                 grad=grad, ratio=ratio, modo=modo, patron=patron,
                                 zobj=zobj, variantes=variantes, dry=dry)


def main():
    modulo, assets, op = parse_args(sys.argv[1:])
    if op['dry']:
        print('*** MODO DRY: no se guarda nada ***')
    for a in assets:
        print('%s / %s' % (modulo, a))
        corregir(modulo, a, op['escala'], op['escala_z'], op['eje'], op['grad'],
                 op['ratio'], op['modo'], op['patron'], op['zobj'],
                 op['variantes'], op['dry'])


if __name__ == '__main__':
    main()
