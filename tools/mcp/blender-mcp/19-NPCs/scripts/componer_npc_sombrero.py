# componer_npc_sombrero.py — M19 · Escena de VERIFICACION (no es fuente de export)
#
# PROPOSITO
# ---------
# El usuario pregunto: "me gustaba el sombrero del anterior lo podes recuperar?
# o diseñaste 2 npcs?". La respuesta es que es UN SOLO NPC: el sombrero de
# paja es un asset INDEPENDIENTE (M19 `sombrero_paja_lowpoly.blend`) que en
# Godot se instancia como hijo de la cabeza. Por eso las capturas de
# `npc_base` lo muestran sin sombrero.
#
# Este script compone ambos en una escena para VERIFICAR EL ENCAJE y poder
# capturar el NPC completo. No genera GLB: la composicion vive solo en la
# carpeta de capturas.
#
# E-79: el origen local del sombrero ES el punto de montaje, no el centro
# geometrico. Por eso basta con trasladar el grupo a (X_CABEZA, Y_MONTAR,
# Z_REF) = (-0.023, -0.020, 1.548). Las piezas ya traen GIRAR aplicado a los
# VERTICES (no a rotation_euler), asi que su transformada de objeto es
# identidad y moverlas no las deforma.
#
# Verificacion del mapeo (del generador del sombrero):
#   maniqui cabeza local = (0, YL(-0.006), L(1.440)) = (0, 0.014, -0.108)
#   + origen montaje      (-0.023, -0.020, 1.548)
#   = mundo               (-0.023, -0.006, 1.440)   <-- centro cabeza NPC v5
# Coincide exacto: la cabeza v5 NO se modificado (secciones 4/5/6 intactas).

import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'scripts-reutilizables'))
import bpy
from mathutils import Vector

# E-82: el script vive en <modulo>/scripts/, asi que el modulo es UN nivel
# arriba. Construir RAIZ con N veces '..' y volver a concatenar 'tools/mcp/...'
# duplica el ultimo tramo (bug real: ...\tools\tools\mcp\...) porque los '..'
# se cuentan desde el DIRECTORIO DEL SCRIPT, no desde la raiz del repo.
DIR_SCRIPTS = os.path.dirname(os.path.abspath(__file__))
DIR_MOD = os.path.abspath(os.path.join(DIR_SCRIPTS, '..'))      # -> 19-NPCs
DIR_REUTIL = os.path.abspath(os.path.join(DIR_SCRIPTS, '..', '..',
                                          'scripts-reutilizables'))
RAIZ = os.path.abspath(os.path.join(DIR_MOD, '..', '..', '..'))
assert os.path.basename(DIR_MOD) == '19-NPCs', 'DIR_MOD mal resuelto: %s' % DIR_MOD
NPC = os.path.join(DIR_MOD, 'npc_base_lowpoly.blend')
SOMB = os.path.join(DIR_MOD, 'sombrero_paja_lowpoly.blend')

# Punto de montaje (copiado de crear_sombrero_paja_lowpoly.py)
Z_REF = 1.548
X_CABEZA = -0.023
Y_MONTAR = -0.020

PIEZAS_SOMBRERO = ['SM_NPC_Sombrero_Ala', 'SM_NPC_Sombrero_Dobladillo',
                   'SM_NPC_Sombrero_Copa', 'SM_NPC_Sombrero_Cima',
                   'SM_NPC_Sombrero_Cinta', 'SM_NPC_Sombrero_Lazo']

# ---------------------------------------------------------------------------
# 1) Abrir el NPC base v5
# ---------------------------------------------------------------------------
bpy.ops.wm.read_factory_settings()
bpy.ops.wm.open_mainfile(filepath=NPC)
print('NPC base cargado: %d objetos' % len(bpy.data.objects))

# ---------------------------------------------------------------------------
# 2) Append de las piezas del sombrero (solo las SM_ del sombrero: el .blend
#    tambien tiene un maniqui de referencia y un Empty _MONTADO que NO
#    queremos traer).
# ---------------------------------------------------------------------------
bpy.ops.wm.append(directory=os.path.join(SOMB, 'Object') + os.sep,
                  files=[{'name': n} for n in PIEZAS_SOMBRERO],
                  link=False, autoselect=False)
print('Append: %d piezas pedidas' % len(PIEZAS_SOMBRERO))

traidas = [o for o in bpy.data.objects if o.name.startswith('SM_NPC_Sombrero_')]
print('Traidas: %d -> %s' % (len(traidas), sorted(o.name for o in traidas)))
assert len(traidas) == len(PIEZAS_SOMBRERO), \
    'Faltan piezas del sombrero: %d de %d' % (len(traidas), len(PIEZAS_SOMBRERO))

# ---------------------------------------------------------------------------
# 3) Montar: trasladar al punto de montaje. E-79.
# ---------------------------------------------------------------------------
for o in traidas:
    o.location = (X_CABEZA, Y_MONTAR, Z_REF)
    o.rotation_euler = (0.0, 0.0, 0.0)
    o.scale = (1.0, 1.0, 1.0)

bpy.context.view_layer.update()

# ---------------------------------------------------------------------------
# 4) Guard de encaje sobre el NPC REAL (no el maniqui)
# ---------------------------------------------------------------------------
# Centro y radios de la cabeza del NPC base v5 (seccion 4, intacta).
CAB = Vector((-0.023, -0.006, 1.440))
RCAB = (0.132, 0.118, 0.160)
# Anillos del pelo v4/v5 (seccion 5, intacta) -> anillo superior en z=1.612
Z_PELO_CIMA = 1.612


def verts_mundo(o):
    return [o.matrix_world @ v.co for v in o.data.vertices]


print('--- GUARD DE ENCAJE (sobre el NPC v5 real) ---')

# (a) La copa contiene la cima del pelo?
copa = bpy.data.objects['SM_NPC_Sombrero_Copa']
cima = bpy.data.objects['SM_NPC_Sombrero_Cima']
vs_copa = verts_mundo(copa)
z_copa_min = min(v.z for v in vs_copa)
print('  copa z_min = %.3f   cima pelo = %.3f   -> %s'
      % (z_copa_min, Z_PELO_CIMA,
         'PELO CONTENIDO' if z_copa_min <= Z_PELO_CIMA else 'PELO ASOMA'))

# (b) El ala NO tapa los ojos (ojos en z=1.445, y=0.108)
ala = bpy.data.objects['SM_NPC_Sombrero_Ala']
vs_ala = verts_mundo(ala)
# vertice mas bajo del ala en el sector FRONTAL (y > 0.05)
frontal = [v for v in vs_ala if v.y > 0.05]
z_ala_frontal_min = min(v.z for v in frontal) if frontal else None
print('  ala frontal z_min = %s   ojos z = 1.445   -> %s'
      % ('%.3f' % z_ala_frontal_min if z_ala_frontal_min else 'n/a',
         'CARA LIBRE' if z_ala_frontal_min and z_ala_frontal_min > 1.445
         else 'TAPA LA CARA'))

# (c) No flota: la copa toca el craneo (distancia al elipsoide de la cabeza)
def dentro_cabeza(p, margen=0.0):
    d = (((p.x - CAB.x) / (RCAB[0] + margen)) ** 2
         + ((p.y - CAB.y) / (RCAB[1] + margen)) ** 2
         + ((p.z - CAB.z) / (RCAB[2] + margen)) ** 2)
    return d <= 1.0


tocan = sum(1 for v in vs_copa if dentro_cabeza(v, 0.02))
print('  verts de la copa dentro del craneo (+2cm) = %d  -> %s'
      % (tocan, 'APOYADA' if tocan >= 4 else 'FLOTA'))

# (d) No es sombrilla: diametro del ala
xs = [v.x for v in vs_ala]
ys = [v.y for v in vs_ala]
print('  diametro ala = %.3f x %.3f m' % (max(xs) - min(xs), max(ys) - min(ys)))

# (e) No atraviesa las orejas (orejas en x = X_CABEZA +- 0.132, z=1.375)
z_oreja = 1.375
cerca = [v for v in vs_ala if abs(v.z - z_oreja) < 0.03]
if cerca:
    print('  ala a altura de oreja: %d verts, |x-oreja| min = %.3f'
          % (len(cerca), min(abs(abs(v.x - X_CABEZA) - 0.132) for v in cerca)))
print('--- FIN GUARD ---')

# ---------------------------------------------------------------------------
# 5) Guardar escena de verificacion
#    El nombre NO termina en _alta/_lowpoly/_media/_baja, asi que
#    exportar_godot.py la ignora (E-63: solo stems con esos sufijos).
# ---------------------------------------------------------------------------
salida = os.path.join(DIR_MOD, 'capturas', 'npc_con_sombrero_VERIF.blend')
os.makedirs(os.path.dirname(salida), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=salida)
print('OK composicion guardada:', salida)
print('   objetos escena: %d  (SM_: %d)'
      % (len(bpy.data.objects),
         sum(1 for o in bpy.data.objects if o.name.startswith('SM_'))))
