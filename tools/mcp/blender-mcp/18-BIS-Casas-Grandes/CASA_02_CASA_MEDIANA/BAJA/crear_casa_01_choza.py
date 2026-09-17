# ================================================================
# CASA 01 — CHOZA AMPLIADA
# Blender 4.2+ | bpy
#
# ALTA: 14 meshes + Empty
# MEDIA y BAJA: derivados independientes del ALTA.
#
# Produce:
#   ALTA/*.blend + *.glb
#   MEDIA/*.blend + *.glb
#   BAJA/*.blend + *.glb
#   6 JPG exteriores ALTA, quality 90
#   6 JPG de inspeccion interior opcionales
#   INFORME_CASA_01.json
#
# ATENCION: limpia los objetos de la sesion.
# ================================================================

import bpy
import bmesh
import math
import json
import random
import traceback

from pathlib import Path
from datetime import datetime
from mathutils import Vector, Matrix


# ---------------- CONFIGURACION ----------------

SALIDA = Path.home() / "CASAS_EXPORT" / "CASA_01_CHOZA"

RENDER_EXTERIOR = True
RENDER_INTERIOR = True
RESOLUCION = 1024

GENERAR_LODS = True

SEMILLA = 21
rng = random.Random(SEMILLA)

LARGO = 5.0
ANCHO = 4.0
GROSOR_PARED = 0.12

Z_MIN = 0.045
PISO = 0.245
ALERO_Z = PISO + 2.60
CUMBRERA_Z = PISO + 3.20

ESPESOR_TECHO = 0.12
ALERO = 0.30

NOMBRE_RAIZ = "SM_CASA_01_CHOZA"

# Hueco de chimenea en la cubierta.
CH_X0, CH_X1 = 2.97, 3.43
CH_Y0, CH_Y1 = 0.25, 0.75

PALETA = {
    "MADERA": (180, 140, 90),
    "OSCURA": (90, 65, 40),
    "PAJA": (210, 180, 120),
    "PIEDRA": (130, 125, 120),
    "TELA": (200, 190, 170),
    "MUSGO": (110, 120, 100),
    "CORTINA": (200, 190, 170),
    "METAL": (91, 83, 72),
}

MATERIAL_CONFIG = [
    ("MAT_MaderaClara", "MADERA", 0.85, 0.0, 1.0),
    ("MAT_MaderaOscura", "OSCURA", 0.90, 0.0, 1.0),
    ("MAT_PajaClara", "PAJA", 0.95, 0.0, 1.0),
    ("MAT_Piedra", "PIEDRA", 0.95, 0.0, 1.0),
    ("MAT_TelaCrudo", "TELA", 0.80, 0.0, 1.0),
    ("MAT_PiedraMoss", "MUSGO", 0.95, 0.0, 1.0),
    ("MAT_CortinaCrudo", "CORTINA", 0.80, 0.0, 0.70),
    ("MAT_MetalForjado", "METAL", 0.65, 0.65, 1.0),
]

MADERA, OSCURA, PAJA, PIEDRA, TELA, MUSGO, CORTINA, METAL = range(8)


# ---------------- COLOR ----------------

def rgba_lineal(rgb):
    def convertir(v):
        v = max(0.0, min(255.0, v)) / 255.0
        return (
            v / 12.92
            if v <= 0.04045
            else ((v + 0.055) / 1.055) ** 2.4
        )
    return tuple(convertir(v) for v in rgb) + (1.0,)


def tono(slot, variacion=1.0):
    clave = MATERIAL_CONFIG[slot][1]
    return rgba_lineal([
        c * variacion for c in PALETA[clave]
    ])


# ---------------- GEOMETRIA ----------------

class Pieza:
    def __init__(self, nombre):
        self.nombre = nombre
        self.vertices = []
        self.caras = []
        self.slots = []
        self.colores = []

    def agregar(self, vertices, caras, slot, variacion=1.0):
        offset = len(self.vertices)
        self.vertices.extend(Vector(v) for v in vertices)
        self.caras.extend(
            tuple(offset + i for i in f) for f in caras
        )
        self.slots.extend([slot] * len(caras))
        self.colores.extend([tono(slot, variacion)] * len(caras))

    def caja(self, centro, medidas, slot, variacion=1.0, radio=0.0):
        """
        Prisma con esquinas achaflanadas en planta si radio > 0.
        No usa Subdivision Surface.
        """
        cx, cy, cz = centro
        sx, sy, sz = medidas
        hx, hy = sx / 2, sy / 2

        if radio > 0:
            r = min(radio, hx * 0.45, hy * 0.45)
            planta = [
                (-hx+r, -hy), (hx-r, -hy),
                (hx, -hy+r), (hx, hy-r),
                (hx-r, hy), (-hx+r, hy),
                (-hx, hy-r), (-hx, -hy+r),
            ]
        else:
            planta = [
                (-hx,-hy), (hx,-hy), (hx,hy), (-hx,hy)
            ]

        n = len(planta)
        verts = [
            (cx+x, cy+y, cz+z)
            for z in (-sz/2, sz/2)
            for x, y in planta
        ]
        caras = [
            tuple(reversed(range(n))),
            tuple(range(n, 2*n)),
        ]
        caras += [
            (j, (j+1) % n, (j+1) % n+n, j+n)
            for j in range(n)
        ]

        self.agregar(verts, caras, slot, variacion)

    def tubo(self, a, b, radio, slot, segmentos=8, variacion=1.0):
        a, b = Vector(a), Vector(b)
        eje = (b-a).normalized()
        ref = Vector((1,0,0))

        if abs(ref.dot(eje)) > 0.9:
            ref = Vector((0,1,0))

        u = (ref-eje*ref.dot(eje)).normalized()
        v = eje.cross(u).normalized()

        verts = []
        for c in (a,b):
            for i in range(segmentos):
                t = 2*math.pi*i/segmentos
                verts.append(c + radio*(
                    u*math.cos(t)+v*math.sin(t)
                ))

        caras = [
            tuple(reversed(range(segmentos))),
            tuple(range(segmentos, segmentos*2)),
        ]
        caras += [
            (i, (i+1)%segmentos,
             (i+1)%segmentos+segmentos, i+segmentos)
            for i in range(segmentos)
        ]
        self.agregar(verts, caras, slot, variacion)


NOMBRES = [
    "SM_Cimiento_Piedra",
    "SM_Pared_Norte",
    "SM_Pared_Sur",
    "SM_Pared_Este",
    "SM_Pared_Oeste",
    "SM_Techo_Izq",
    "SM_Techo_Der",
    "SM_Cumbrera",
    "SM_Suelo",
    "SM_Cama",
    "SM_Mesa",
    "SM_Estanteria",
    "SM_Hogar",
    "SM_Silla",
]

P = {n: Pieza(n) for n in NOMBRES}


def caja(nombre, centro, medidas, slot, var=1.0, radio=0.0):
    P[nombre].caja(centro, medidas, slot, var, radio)


# ---------------- CIMIENTO ----------------

cimiento = P["SM_Cimiento_Piedra"]

# Piedras contenidas dentro de la huella 5x4.
# Bases a Z_MIN exacto; variacion solo horizontal.
for y in (0.15, ANCHO-0.15):
    n = 10
    for i in range(n):
        ancho = LARGO/n
        cimiento.caja(
            ((i+0.5)*ancho, y, Z_MIN+0.10),
            (ancho, 0.30, 0.20),
            MUSGO if i % 5 == 0 else PIEDRA,
            rng.uniform(0.90,1.08),
            radio=0.045
        )

for x in (0.15, LARGO-0.15):
    n = 8
    longitud = ANCHO-0.60
    for i in range(n):
        paso = longitud/n
        cimiento.caja(
            (x, 0.30+(i+0.5)*paso, Z_MIN+0.10),
            (0.30, paso, 0.20),
            PIEDRA, rng.uniform(0.90,1.08),
            radio=0.04
        )


# ---------------- SUELO ----------------

# Cinco tablas largas paralelas a X.
for i in range(5):
    paso = (ANCHO-0.24)/5
    caja(
        "SM_Suelo",
        (2.5, 0.12+(i+0.5)*paso, PISO-0.035),
        (4.76, paso, 0.07),
        MADERA, 0.96+0.025*(i % 3)
    )


# ---------------- PAREDES CON HUECOS REALES ----------------

def pared(nombre, eje, fijo, longitud, huecos):
    """
    huecos: (inicio horizontal, final, z inferior, z superior).
    Se construye alrededor de ellos, sin booleanos.
    """
    cortes = {0.0, longitud}

    pasos = math.ceil(longitud/0.22)
    cortes.update(longitud*i/pasos for i in range(pasos+1))

    for h0,h1,z0,z1 in huecos:
        cortes.update((h0,h1))

    cortes = sorted(cortes)

    for a,b in zip(cortes[:-1],cortes[1:]):
        medio = (a+b)/2
        tramos = [(PISO,ALERO_Z)]

        for h0,h1,z0,z1 in huecos:
            if h0 <= medio <= h1:
                nuevos = []
                for t0,t1 in tramos:
                    if z0 > t0:
                        nuevos.append((t0,min(z0,t1)))
                    if z1 < t1:
                        nuevos.append((max(z1,t0),t1))
                tramos = [(u,v) for u,v in nuevos if v-u > 1e-5]

        for z0,z1 in tramos:
            if eje == "X":
                centro = (medio,fijo,(z0+z1)/2)
                tam = (b-a,GROSOR_PARED,z1-z0)
            else:
                centro = (fijo,medio,(z0+z1)/2)
                tam = (GROSOR_PARED,b-a,z1-z0)

            caja(nombre,centro,tam,MADERA,rng.uniform(0.93,1.06))


puerta = (2.0,3.0,PISO,PISO+2.10)
ventana = (2.60,3.20,PISO+1.10,PISO+1.70)

pared("SM_Pared_Sur","X",3.94,5.0,[puerta])
pared("SM_Pared_Norte","X",0.06,5.0,[])
pared("SM_Pared_Este","Y",4.94,4.0,[ventana])
pared("SM_Pared_Oeste","Y",0.06,4.0,[ventana])

# Cuatro postes, incorporados a las paredes frontal/trasera.
for nombre,y in [
    ("SM_Pared_Norte",0.06),
    ("SM_Pared_Sur",3.94)
]:
    for x in (0.06,4.94):
        caja(
            nombre,(x,y,PISO+1.30),
            (0.10,0.10,2.60),OSCURA
        )

# Marco por fuera del hueco: conserva 1.00 x 2.10 libres.
for x in (1.955,3.045):
    caja(
        "SM_Pared_Sur",(x,3.93,PISO+1.05),
        (0.09,0.14,2.10),OSCURA
    )

caja(
    "SM_Pared_Sur",(2.5,3.93,PISO+2.145),
    (1.18,0.14,0.09),OSCURA
)

# Ventanas: marcos y paneles de tela con leve ondulacion.
for nombre,x in [
    ("SM_Pared_Este",4.94),
    ("SM_Pared_Oeste",0.06)
]:
    for y in (2.565,3.235):
        caja(
            nombre,(x,y,PISO+1.40),
            (0.15,0.07,0.74),OSCURA
        )

    for z in (PISO+1.065,PISO+1.735):
        caja(
            nombre,(x,2.90,z),
            (0.15,0.60,0.07),OSCURA
        )

    verts = []
    for z in (PISO+1.10,PISO+1.70):
        for i in range(9):
            y = 2.60+0.60*i/8
            xx = x+0.014*math.sin(i*math.pi/2)
            verts.append((xx,y,z))

    caras = [
        (i,i+1,i+10,i+9) for i in range(8)
    ]
    P[nombre].agregar(verts,caras,CORTINA)


# ---------------- TESTEROS TRIANGULARES ----------------

for nombre,ya,yb in [
    ("SM_Pared_Norte",0.0,0.12),
    ("SM_Pared_Sur",3.88,4.0)
]:
    verts = [
        (0,ya,ALERO_Z),(5,ya,ALERO_Z),(2.5,ya,CUMBRERA_Z),
        (0,yb,ALERO_Z),(5,yb,ALERO_Z),(2.5,yb,CUMBRERA_Z),
    ]
    caras = [
        (0,2,1),(3,4,5),
        (0,1,4,3),(1,2,5,4),(2,0,3,5)
    ]
    P[nombre].agregar(verts,caras,MADERA,0.96)


# ---------------- TECHO EN CUATRO CAPAS ----------------

def z_techo(x):
    return CUMBRERA_Z-(CUMBRERA_Z-ALERO_Z)*abs(x-2.5)/2.5


def panel_cubierta(nombre,x0,x1,y0,y1,variacion):
    verts = [
        (x0,y0,z_techo(x0)),(x1,y0,z_techo(x1)),
        (x1,y1,z_techo(x1)),(x0,y1,z_techo(x0)),
        (x0,y0,z_techo(x0)+ESPESOR_TECHO),
        (x1,y0,z_techo(x1)+ESPESOR_TECHO),
        (x1,y1,z_techo(x1)+ESPESOR_TECHO),
        (x0,y1,z_techo(x0)+ESPESOR_TECHO),
    ]
    caras = [
        (0,3,2,1),(4,5,6,7),
        (0,1,5,4),(1,2,6,5),
        (2,3,7,6),(3,0,4,7)
    ]
    P[nombre].agregar(verts,caras,PAJA,variacion)


for nombre,a,b in [
    ("SM_Techo_Izq",-0.30,2.50),
    ("SM_Techo_Der",2.50,5.30)
]:
    bandas = [a+(b-a)*i/4 for i in range(5)]
    xs = sorted(set(bandas + [
        x for x in (CH_X0,CH_X1) if a < x < b
    ]))
    ys = [-0.30,CH_Y0,CH_Y1,4.30]

    for x0,x1 in zip(xs[:-1],xs[1:]):
        for y0,y1 in zip(ys[:-1],ys[1:]):
            mx,my = (x0+x1)/2,(y0+y1)/2

            if CH_X0 < mx < CH_X1 and CH_Y0 < my < CH_Y1:
                continue

            banda = min(3,int((mx-a)/(b-a)*4))
            panel_cubierta(
                nombre,x0,x1,y0,y1,
                [1.02,0.95,1.00,0.91][banda]
            )

    # Bordes de capas: lineas geometricas suaves y economicas.
    for x in bandas[1:-1]:
        segmentos_y = [(-0.30,4.30)]
        if CH_X0 < x < CH_X1:
            segmentos_y = [(-0.30,CH_Y0),(CH_Y1,4.30)]

        for y0,y1 in segmentos_y:
            P[nombre].tubo(
                (x,y0,z_techo(x)+ESPESOR_TECHO),
                (x,y1,z_techo(x)+ESPESOR_TECHO),
                0.018,PAJA,6,0.93
            )

P["SM_Cumbrera"].tubo(
    (2.5,-0.30,CUMBRERA_Z+0.08),
    (2.5,4.30,CUMBRERA_Z+0.08),
    0.07,OSCURA,10
)


# ---------------- CAMA 2.00 x 0.90 ----------------

cx,cy = 0.80,1.47

for x in (cx-0.36,cx+0.36):
    for y in (cy-0.89,cy+0.89):
        caja(
            "SM_Cama",(x,y,PISO+0.215),
            (0.075,0.075,0.43),OSCURA,radio=0.012
        )

caja(
    "SM_Cama",(cx,cy,PISO+0.415),
    (0.90,2.00,0.07),MADERA,radio=0.03
)
caja(
    "SM_Cama",(cx,cy,PISO+0.505),
    (0.86,1.96,0.11),PAJA,radio=0.045
)
caja(
    "SM_Cama",(cx,cy+0.22,PISO+0.57),
    (0.87,1.43,0.025),TELA,radio=0.025
)
caja(
    "SM_Cama",(cx,cy-0.70,PISO+0.595),
    (0.57,0.32,0.09),TELA,1.05,radio=0.06
)

# Cabecero bajo.
caja(
    "SM_Cama",(cx,cy-0.97,PISO+0.52),
    (0.90,0.065,0.35),OSCURA,radio=0.025
)


# ---------------- MESA 1.20 x 0.60 ----------------

# Lado largo paralelo a Y, contra el lateral derecho.
mx,my = 4.35,2.05

caja(
    "SM_Mesa",(mx,my,PISO+0.765),
    (0.60,1.20,0.07),MADERA,radio=0.04
)
for x in (mx-0.235,mx+0.235):
    for y in (my-0.50,my+0.50):
        caja(
            "SM_Mesa",(x,y,PISO+0.365),
            (0.08,0.08,0.73),OSCURA,radio=0.012
        )


# ---------------- SILLA ----------------

sx,sy = 3.45,2.05

caja(
    "SM_Silla",(sx,sy,PISO+0.42),
    (0.43,0.43,0.06),MADERA,radio=0.035
)

for x in (sx-0.16,sx+0.16):
    for y in (sy-0.16,sy+0.16):
        caja(
            "SM_Silla",(x,y,PISO+0.195),
            (0.055,0.055,0.39),OSCURA,radio=0.01
        )

# Respaldo al oeste: la silla mira hacia la mesa (+X).
for y in (sy-0.16,sy+0.16):
    caja(
        "SM_Silla",(sx-0.18,y,PISO+0.65),
        (0.045,0.045,0.50),OSCURA
    )

for z in (PISO+0.70,PISO+0.86):
    caja(
        "SM_Silla",(sx-0.18,sy,z),
        (0.045,0.40,0.08),MADERA,radio=0.012
    )


# ---------------- ESTANTERIA ----------------

for z in (PISO+1.10,PISO+1.62):
    caja(
        "SM_Estanteria",(4.68,1.22,z),
        (0.36,1.10,0.045),MADERA,radio=0.015
    )

for y in (0.75,1.68):
    caja(
        "SM_Estanteria",(4.79,y,PISO+1.35),
        (0.10,0.05,0.72),OSCURA
    )

# Libros simplificados y frascos opacos.
for i in range(5):
    caja(
        "SM_Estanteria",
        (4.63,0.84+i*0.075,PISO+1.20),
        (0.18,0.05,0.16),
        TELA if i%2 else OSCURA,
        0.92+0.025*i
    )

for y in (1.32,1.55):
    P["SM_Estanteria"].tubo(
        (4.65,y,PISO+1.645),
        (4.65,y,PISO+1.81),
        0.065,PIEDRA,8
    )
    P["SM_Estanteria"].tubo(
        (4.65,y,PISO+1.81),
        (4.65,y,PISO+1.85),
        0.034,OSCURA,8
    )


# ---------------- HOGAR Y CHIMENEA ----------------

hx,hy = 3.20,0.51

caja(
    "SM_Hogar",(hx,hy,PISO+0.055),
    (0.90,0.74,0.11),PIEDRA,radio=0.08
)

# Laterales y fondo de hogar abierto hacia +Y.
for x in (hx-0.34,hx+0.34):
    caja(
        "SM_Hogar",(x,hy,PISO+0.35),
        (0.13,0.58,0.48),PIEDRA,0.92,radio=0.025
    )

caja(
    "SM_Hogar",(hx,hy-0.25,PISO+0.35),
    (0.60,0.13,0.48),PIEDRA,radio=0.025
)

# Brasero oscuro y leña. Sin fuego ni luz.
caja(
    "SM_Hogar",(hx,hy+0.05,PISO+0.14),
    (0.49,0.36,0.07),METAL,radio=0.035
)

for dx in (-0.11,0.10):
    P["SM_Hogar"].tubo(
        (hx+dx,hy-0.07,PISO+0.205),
        (hx+dx,hy+0.21,PISO+0.205),
        0.038,OSCURA,8
    )

# Campana: tronco de piramide, unido al tubo.
verts = [
    (hx-0.42,hy-0.31,PISO+0.58),
    (hx+0.42,hy-0.31,PISO+0.58),
    (hx+0.42,hy+0.31,PISO+0.58),
    (hx-0.42,hy+0.31,PISO+0.58),
    (hx-0.18,hy-0.18,PISO+1.02),
    (hx+0.18,hy-0.18,PISO+1.02),
    (hx+0.18,hy+0.18,PISO+1.02),
    (hx-0.18,hy+0.18,PISO+1.02),
]
P["SM_Hogar"].agregar(
    verts,
    [(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)],
    PIEDRA
)

chimenea_top = CUMBRERA_Z+0.48
z0 = PISO+1.02

# Tubo hueco de cuatro paredes.
for x in (hx-0.155,hx+0.155):
    caja(
        "SM_Hogar",(x,hy,(z0+chimenea_top)/2),
        (0.07,0.38,chimenea_top-z0),PIEDRA,0.94
    )
for y in (hy-0.155,hy+0.155):
    caja(
        "SM_Hogar",(hx,y,(z0+chimenea_top)/2),
        (0.24,0.07,chimenea_top-z0),PIEDRA
    )


# ---------------- CREAR ESCENA ----------------

if bpy.context.object and bpy.context.object.mode != "OBJECT":
    bpy.ops.object.mode_set(mode="OBJECT")

for obj in list(bpy.data.objects):
    bpy.data.objects.remove(obj,do_unlink=True)

for col in list(bpy.data.collections):
    bpy.data.collections.remove(col)

for grupo in (bpy.data.meshes,bpy.data.materials):
    for bloque in list(grupo):
        if bloque.users == 0:
            grupo.remove(bloque)

scene = bpy.context.scene
scene.unit_settings.system = "METRIC"
scene.unit_settings.scale_length = 1.0

col = bpy.data.collections.new("COL_CASA_01")
scene.collection.children.link(col)

raiz = bpy.data.objects.new(NOMBRE_RAIZ,None)
raiz.empty_display_type = "PLAIN_AXES"
raiz.empty_display_size = 0.40
col.objects.link(raiz)


def crear_material(nombre,roughness,metallic,alpha):
    mat = bpy.data.materials.new(nombre)
    mat.use_nodes = True
    mat.use_backface_culling = False

    nt = mat.node_tree
    nt.nodes.clear()

    attr = nt.nodes.new("ShaderNodeVertexColor")
    attr.layer_name = "COLOR_0"

    bsdf = nt.nodes.new("ShaderNodeBsdfPrincipled")
    bsdf.inputs["Base Color"].default_value = (1,1,1,1)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Alpha"].default_value = alpha

    salida = nt.nodes.new("ShaderNodeOutputMaterial")
    nt.links.new(attr.outputs["Color"],bsdf.inputs["Base Color"])
    nt.links.new(bsdf.outputs["BSDF"],salida.inputs["Surface"])

    if alpha < 1:
        if hasattr(mat,"surface_render_method"):
            mat.surface_render_method = "DITHERED"
        elif hasattr(mat,"blend_method"):
            mat.blend_method = "BLEND"

    mat["ALPHA_PREVISTO"] = alpha
    return mat


materiales = [
    crear_material(n,r,m,a)
    for n,c,r,m,a in MATERIAL_CONFIG
]

objetos = []

for nombre,pieza in P.items():
    me = bpy.data.meshes.new(nombre+"_MESH")
    me.from_pydata(pieza.vertices,[],pieza.caras)
    me.update()

    usados = sorted(set(pieza.slots))
    indices = {slot:i for i,slot in enumerate(usados)}

    for slot in usados:
        me.materials.append(materiales[slot])

    attr = me.color_attributes.new(
        name="COLOR_0",type="FLOAT_COLOR",domain="CORNER"
    )
    me.color_attributes.active_color = attr
    me.color_attributes.render_color_index = 0

    for poly,slot,rgba in zip(
        me.polygons,pieza.slots,pieza.colores
    ):
        poly.material_index = indices[slot]
        # Normales planas para conservar tablones y planos limpios.
        poly.use_smooth = False
        for li in poly.loop_indices:
            attr.data[li].color = rgba

    bm = bmesh.new()
    bm.from_mesh(me)
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
    bm.to_mesh(me)
    bm.free()

    obj = bpy.data.objects.new(nombre,me)
    col.objects.link(obj)
    obj.parent = raiz
    objetos.append(obj)

# Metadatos de interaccion: no crean colliders automaticamente.
for obj in objetos:
    obj["INTERACTIVO"] = obj.name in {
        "SM_Cama","SM_Mesa","SM_Silla","SM_Estanteria"
    }

raiz["TIPO"] = "CASA_STANDALONE"
raiz["FRENTE"] = "+Y"
raiz["PISO_TERMINADO_Z"] = PISO
raiz["PUERTA_ANCHO_LIBRE"] = 1.0
raiz["PUERTA_ALTO_LIBRE"] = 2.1
raiz["PASILLO_CENTRAL_ANCHO"] = 0.9

bpy.context.view_layer.update()


# ---------------- MEDICION ----------------

def activar(obj):
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj


def limites(lista):
    pts = [
        obj.matrix_world@v.co
        for obj in lista for v in obj.data.vertices
    ]
    mn = Vector(tuple(min(p[i] for p in pts) for i in range(3)))
    mx = Vector(tuple(max(p[i] for p in pts) for i in range(3)))
    return mn,mx


def tris(obj):
    obj.data.calc_loop_triangles()
    return len(obj.data.loop_triangles)


def informe_geometria(lista):
    mn,mx = limites(lista)
    mats = {
        obj.data.materials[p.material_index]
        for obj in lista for p in obj.data.polygons
    }
    return {
        "triangulos":sum(tris(o) for o in lista),
        "meshes":len(lista),
        "objetos_con_empty":len(lista)+1,
        "materiales":len(mats),
        "z_min":mn.z,
        "dimensiones_exteriores":list(mx-mn),
        "por_mesh":{o.name:tris(o) for o in lista},
    }


informe = {
    "casa":"CHOZA_AMPLIADA",
    "version":1,
    "niveles":{},
    "capturas":[],
    "errores":[],
    "validacion_visual":"PENDIENTE",
    "colisiones":"NO_GENERADAS",
    "notas":[
        "Alturas interiores medidas desde el piso terminado.",
        "Puerta abierta, sin hoja.",
        "Techo desmontable por objetos para inspeccion.",
        "La chimenea tiene abertura real en la cubierta.",
        "No se certifican intersecciones mediante este informe.",
        "LOD lejanos requieren revision visual de muebles y marcos.",
    ]
}

alta = informe_geometria(objetos)
assert alta["triangulos"] <= 6000, alta
assert alta["meshes"] == 14
assert alta["materiales"] <= 8
assert abs(alta["z_min"]-Z_MIN) < 1e-6

informe["niveles"]["ALTA"] = alta

SALIDA.mkdir(parents=True,exist_ok=True)


# ---------------- EXPORTACION ----------------

def exportar(lista,ruta):
    bpy.ops.object.select_all(action="DESELECT")
    raiz.select_set(True)
    for obj in lista:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = lista[0]

    opciones = {
        "filepath":str(ruta),
        "export_format":"GLB",
        "use_selection":True,
        "export_yup":True,
        "export_apply":True,
        "export_animations":False,
        "export_materials":"EXPORT",
    }

    props = {
        p.identifier
        for p in bpy.ops.export_scene.gltf.get_rna_type().properties
    }
    if "export_all_vertex_colors" in props:
        opciones["export_all_vertex_colors"] = True

    bpy.ops.export_scene.gltf(**opciones)


def guardar_nivel(nivel,lista):
    carpeta = SALIDA/nivel
    carpeta.mkdir(exist_ok=True)

    nombre = f"{NOMBRE_RAIZ}_{nivel}"
    exportar(lista,carpeta/f"{nombre}.glb")
    bpy.ops.wm.save_as_mainfile(
        filepath=str(carpeta/f"{nombre}.blend")
    )


# ---------------- CAPTURAS ----------------

def orientar(obj,punto):
    obj.rotation_euler = (
        Vector(punto)-obj.location
    ).to_track_quat("-Z","Y").to_euler()


def renderizar():
    preview = bpy.data.collections.new("COL_PREVIEW_TEMP")
    scene.collection.children.link(preview)

    objetivo = Vector((2.5,2.0,1.60))
    mn,mx = limites(objetos)
    escala = (mx-mn).length*1.12

    for nombre,pos,energia in [
        ("SM_LUZ_PRINCIPAL",(2,7,9),1500),
        ("SM_LUZ_RELLENO",(-4,1,6),800),
        ("SM_LUZ_TRASERA",(6,-3,7),1000),
    ]:
        data = bpy.data.lights.new(nombre,"AREA")
        data.energy = energia
        data.size = 6
        obj = bpy.data.objects.new(nombre,data)
        preview.objects.link(obj)
        obj.location = pos
        orientar(obj,objetivo)

    data = bpy.data.cameras.new("SM_CAMARA_CAPTURA")
    cam = bpy.data.objects.new("SM_CAMARA_CAPTURA",data)
    preview.objects.link(cam)
    scene.camera = cam
    data.type = "ORTHO"
    data.ortho_scale = escala

    mundo = bpy.data.worlds.new("WORLD_CASA_PREVIEW")
    mundo.use_nodes = True
    scene.world = mundo

    # Fondo #808080 con Standard y conversion sRGB->lineal.
    bg = mundo.node_tree.nodes.get("Background")
    bg.inputs["Color"].default_value = rgba_lineal((128,128,128))
    bg.inputs["Strength"].default_value = 1.0

    scene.view_settings.view_transform = "Standard"
    scene.view_settings.exposure = 0
    scene.view_settings.gamma = 1

    scene.render.engine = "BLENDER_EEVEE_NEXT"
    scene.render.resolution_x = RESOLUCION
    scene.render.resolution_y = RESOLUCION
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "JPEG"
    scene.render.image_settings.color_mode = "RGB"
    scene.render.image_settings.quality = 90
    scene.render.film_transparent = False
    scene.render.use_compositing = False
    scene.render.use_sequencer = False

    carpeta = SALIDA/"CAPTURAS"
    carpeta.mkdir(exist_ok=True)
    fecha = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")

    ocultables = {
        "SM_Techo_Izq","SM_Techo_Der","SM_Cumbrera",
        "SM_Pared_Sur",
    }

    modos = []
    if RENDER_EXTERIOR:
        modos.append("EXTERIOR")
    if RENDER_INTERIOR:
        modos.append("INTERIOR_INSPECCION")

    for modo in modos:
        for obj in objetos:
            obj.hide_render = (
                modo == "INTERIOR_INSPECCION"
                and obj.name in ocultables
            )

        for i in range(6):
            angulo = math.radians(i*60)
            # Elevacion 45 grados: radio horizontal = altura relativa.
            cam.location = objetivo+Vector((
                10*math.sin(angulo),
                10*math.cos(angulo),
                10
            ))
            orientar(cam,objetivo)

            ruta = carpeta/f"CASA01_{modo}_{fecha}_{i*60:03d}.jpg"
            scene.render.filepath = str(ruta)
            bpy.ops.render.render(write_still=True)
            informe["capturas"].append(str(ruta))

    for obj in objetos:
        obj.hide_render = False

    scene.camera = None

    for obj in list(preview.objects):
        bpy.data.objects.remove(obj,do_unlink=True)
    bpy.data.collections.remove(preview)

    for grupo in (bpy.data.cameras,bpy.data.lights):
        for bloque in list(grupo):
            if bloque.users == 0:
                grupo.remove(bloque)


if RENDER_EXTERIOR or RENDER_INTERIOR:
    renderizar()

guardar_nivel("ALTA",objetos)


# ---------------- SNAPSHOT PARA LOD INDEPENDIENTES ----------------

plantillas = []

for obj in objetos:
    me = obj.data.copy()
    me.use_fake_user = True
    plantillas.append((obj.name,me,dict(obj.items())))


def restaurar_alta():
    for obj in list(col.objects):
        if obj.type == "MESH":
            bpy.data.objects.remove(obj,do_unlink=True)

    nuevos = []

    for nombre,me,props in plantillas:
        obj = bpy.data.objects.new(nombre,me.copy())
        col.objects.link(obj)
        obj.parent = raiz

        for k,v in props.items():
            obj[k] = v

        nuevos.append(obj)

    bpy.context.view_layer.update()
    return nuevos


def materiales_lod(lista,nivel):
    if nivel == "MEDIA":
        # 8 -> 6: musgo usa piedra; oscuro usa madera.
        mapa = {
            0:"MADERA",1:"MADERA",2:"PAJA",
            3:"PIEDRA",4:"TELA",5:"PIEDRA",
            6:"CORTINA",7:"METAL",
        }
        config = {
            "MADERA":(0.86,0.0,1.0),
            "PAJA":(0.95,0.0,1.0),
            "PIEDRA":(0.95,0.0,1.0),
            "TELA":(0.80,0.0,1.0),
            "CORTINA":(0.80,0.0,0.70),
            "METAL":(0.65,0.65,1.0),
        }
    else:
        # Mantener cortina separada para no transparentar paredes.
        mapa = {
            0:"ORGANICO",1:"ORGANICO",2:"ORGANICO",
            3:"MINERAL",4:"TELA",5:"MINERAL",
            6:"CORTINA",7:"MINERAL",
        }
        config = {
            "ORGANICO":(0.88,0.0,1.0),
            "MINERAL":(0.90,0.0,1.0),
            "TELA":(0.80,0.0,1.0),
            "CORTINA":(0.80,0.0,0.70),
        }

    destino = {
        clave:crear_material(
            f"MAT_CHOZA_{nivel}_{clave}",*valores
        )
        for clave,valores in config.items()
    }

    indices_originales = {
        mat.name:i for i,mat in enumerate(materiales)
    }

    for obj in lista:
        asignaciones = []
        for p in obj.data.polygons:
            mat = obj.data.materials[p.material_index]
            indice = indices_originales[mat.name]
            asignaciones.append(destino[mapa[indice]])

        usados = list(dict.fromkeys(asignaciones))
        obj.data.materials.clear()
        for mat in usados:
            obj.data.materials.append(mat)

        indices = {mat:i for i,mat in enumerate(usados)}
        for p,mat in zip(obj.data.polygons,asignaciones):
            p.material_index = indices[mat]


def reducir(lista,presupuesto):
    for obj in lista:
        activar(obj)
        mod = obj.modifiers.new("TRIANGULAR","TRIANGULATE")
        bpy.ops.object.modifier_apply(modifier=mod.name)

    for intento in range(10):
        total = sum(tris(o) for o in lista)
        if total <= presupuesto:
            return

        ratio = max(0.02,min(0.95,presupuesto*0.96/total))

        for obj in lista:
            if tris(obj) <= 12:
                continue

            activar(obj)
            mod = obj.modifiers.new("REDUCIR","DECIMATE")
            mod.decimate_type = "COLLAPSE"
            mod.ratio = ratio
            mod.use_collapse_triangulate = True
            bpy.ops.object.modifier_apply(modifier=mod.name)

        nuevo = sum(tris(o) for o in lista)
        if nuevo >= total:
            break

    raise RuntimeError(
        f"No se alcanzo el presupuesto de {presupuesto} tris."
    )


if GENERAR_LODS:
    for nivel,presupuesto,max_mats in [
        ("MEDIA",1500,6),("BAJA",700,4)
    ]:
        try:
            lista = restaurar_alta()
            materiales_lod(lista,nivel)
            reducir(lista,presupuesto)

            # Decimate puede retirar vertices inferiores.
            # Solo corregir una diferencia pequena, no escalar la casa.
            mn,mx = limites(lista)
            diferencia = mn.z-Z_MIN

            if abs(diferencia) > 0.01:
                raise RuntimeError(
                    "El LOD altero demasiado el apoyo del cimiento."
                )

            for obj in lista:
                for v in obj.data.vertices:
                    v.co.z -= diferencia

                if obj.data.color_attributes.get("COLOR_0") is None:
                    raise RuntimeError(f"COLOR_0 perdido: {obj.name}")

            datos = informe_geometria(lista)
            assert datos["triangulos"] <= presupuesto
            assert datos["materiales"] <= max_mats
            assert abs(datos["z_min"]-Z_MIN) < 1e-5

            datos["aprobacion_visual"] = "PENDIENTE"
            datos["ajuste_vertical"] = diferencia

            informe["niveles"][nivel] = datos
            guardar_nivel(nivel,lista)

        except Exception as error:
            traceback.print_exc()
            informe["errores"].append({
                "nivel":nivel,
                "error":str(error),
            })


with open(
    SALIDA/"INFORME_CASA_01.json","w",encoding="utf-8"
) as archivo:
    json.dump(informe,archivo,ensure_ascii=False,indent=2)

print("\n========== CASA 01 ==========")
print(json.dumps(informe,ensure_ascii=False,indent=2))
print("Carpeta:",SALIDA)