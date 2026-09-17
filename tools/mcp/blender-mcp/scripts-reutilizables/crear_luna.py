# ================================================================
# LUNA — NPC 01/35 — ISLA RAIZ
# Blender 4.2+ | bpy | Sin Subdivision Surface
#
# Genera:
#   SM_NPC_LUNA.blend
#   SM_NPC_LUNA.glb
#   6 capturas orbitales PNG
#   SM_NPC_LUNA_RESUMEN.json
#
# ATENCION: elimina los objetos de la sesion actual.
# Ejecutar preferentemente con --background --factory-startup.
# ================================================================

import bpy
import bmesh
import math
import json
from pathlib import Path
from datetime import datetime
from mathutils import Vector

# ---------------- CONFIGURACION ----------------

OUTPUT_DIR = Path.home() / "NPC_EXPORT" / "01_RAIZ" / "01_LUNA"
RENDER_CAPTURAS = True
RESOLUCION = 768

NOMBRE = "LUNA"
ALTURA_OBJETIVO = 1.80

# True: escala los pivotes originales junto con la anatomia.
# False: conserva las coordenadas literales pedidas, pero los
# origenes dejan de coincidir con las articulaciones escaladas.
ESCALAR_PIVOTES = True

PIVOTES_REF = {
    "BODY":   (0.0, 0.0, 0.82),
    "HEAD":   (0.0, 0.0, 1.29),
    "HAIR":   (0.0, 0.0, 1.29),
    "ARM_L":  (-0.19, 0.0, 1.20),
    "ARM_R":  ( 0.19, 0.0, 1.20),
    "LEG_L":  (-0.088, 0.0, 0.82),
    "LEG_R":  ( 0.088, 0.0, 0.82),
    "EYES":   (0.0, 0.0, 1.29),
}

# SK-02 es exacto.
# HR-02 y EY-02 son propuestas porque no se proporcionaron
# sus codigos hexadecimales oficiales de M161.
C = {
    "PIEL":       "#D4A882",
    "PELO":       "#98704E",
    "VERDE_OJO":  "#637653",
    "PUPILA":     "#201B16",
    "CREMA":      "#E9DDC5",
    "CREMA_OSC":  "#CABEAA",
    "DELANTAL":   "#D6C5A7",
    "ROSA":       "#BC8984",
    "BOTAS":      "#785B45",
    "SUELA":      "#514439",
    "MADERA":     "#AA8058",
    "METAL":      "#AAA49A",
    "CERDAS":     "#715644",
    "BOCA":       "#8C6253",
    "PINT_AZUL":  "#728F96",
    "PINT_VERDE": "#7F8C66",
    "PINT_OCRE":  "#BE995D",
    "PINT_ROSA":  "#B87873",
}

# Seis materiales, no seis materiales nuevos por accesorio.
PIEL, PELO, CAMISA, PANTALON, BOTAS, OJOS = range(6)

# ---------------- COLOR ----------------

def rgba_lineal(hex_color):
    s = hex_color.lstrip("#")
    rgb = [int(s[i:i + 2], 16) / 255 for i in (0, 2, 4)]

    def linear(v):
        return v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4

    return tuple(linear(v) for v in rgb) + (1.0,)


def color(nombre):
    return rgba_lineal(C.get(nombre, nombre))


# ---------------- ACUMULADOR DE GEOMETRIA ----------------

class Pieza:
    def __init__(self, nombre):
        self.nombre = nombre
        self.vertices = []
        self.caras = []
        self.slots = []
        self.colores = []

    def agregar(self, vertices, caras, slot, tono):
        offset = len(self.vertices)
        self.vertices.extend(Vector(v) for v in vertices)
        self.caras.extend(
            tuple(offset + i for i in cara) for cara in caras
        )
        self.slots.extend([slot] * len(caras))
        self.colores.extend([color(tono)] * len(caras))


PARTES = {
    nombre: Pieza(nombre)
    for nombre in (
        "BODY", "HEAD", "HAIR",
        "ARM_L", "ARM_R",
        "LEG_L", "LEG_R", "EYES"
    )
}


# ---------------- PRIMITIVAS CONTROLADAS ----------------

def conectar_anillos(pieza, anillos, slot, tono,
                      cerrar_inicio=False, cerrar_final=False):
    """Anillos del mismo numero de vertices, unidos con quads."""
    n = len(anillos[0])
    vertices = [Vector(v) for anillo in anillos for v in anillo]
    caras = []

    for k in range(len(anillos) - 1):
        for j in range(n):
            q = (j + 1) % n
            caras.append((
                k * n + j,
                k * n + q,
                (k + 1) * n + q,
                (k + 1) * n + j,
            ))

    if cerrar_inicio:
        centro = sum(
            (Vector(v) for v in anillos[0]), Vector()
        ) / n
        idx = len(vertices)
        vertices.append(centro)
        for j in range(n):
            caras.append((idx, (j + 1) % n, j))

    if cerrar_final:
        centro = sum(
            (Vector(v) for v in anillos[-1]), Vector()
        ) / n
        idx = len(vertices)
        vertices.append(centro)
        base = (len(anillos) - 1) * n
        for j in range(n):
            caras.append((idx, base + j, base + (j + 1) % n))

    pieza.agregar(vertices, caras, slot, tono)


def anillo_z(x, y, z, rx, ry, segmentos=16):
    return [
        (
            x + rx * math.cos(2 * math.pi * j / segmentos),
            y + ry * math.sin(2 * math.pi * j / segmentos),
            z,
        )
        for j in range(segmentos)
    ]


def elipsoide(pieza, centro, radios, slot, tono,
              segmentos=12, latitudes=8):
    centro = Vector(centro)
    rx, ry, rz = radios
    vertices = [centro + Vector((0, 0, rz))]

    for k in range(1, latitudes):
        ph = math.pi * k / latitudes
        for j in range(segmentos):
            a = 2 * math.pi * j / segmentos
            vertices.append(centro + Vector((
                rx * math.sin(ph) * math.cos(a),
                ry * math.sin(ph) * math.sin(a),
                rz * math.cos(ph),
            )))

    inferior = len(vertices)
    vertices.append(centro - Vector((0, 0, rz)))
    caras = []

    for j in range(segmentos):
        caras.append((0, 1 + j, 1 + (j + 1) % segmentos))

    for k in range(latitudes - 2):
        a = 1 + k * segmentos
        b = a + segmentos
        for j in range(segmentos):
            q = (j + 1) % segmentos
            caras.append((a + j, b + j, b + q, a + q))

    base = 1 + (latitudes - 2) * segmentos
    for j in range(segmentos):
        caras.append((
            inferior, base + (j + 1) % segmentos, base + j
        ))

    pieza.agregar(vertices, caras, slot, tono)


def tubo(pieza, puntos, radios, slot, tono,
         segmentos=8, cerrar=True):
    puntos = [Vector(p) for p in puntos]
    anillos = []

    for i, p in enumerate(puntos):
        anterior = puntos[max(0, i - 1)]
        siguiente = puntos[min(len(puntos) - 1, i + 1)]
        tangente = (siguiente - anterior).normalized()

        ref = Vector((1, 0, 0))
        if abs(tangente.dot(ref)) > 0.94:
            ref = Vector((0, 1, 0))

        u = (ref - tangente * ref.dot(tangente)).normalized()
        v = tangente.cross(u).normalized()

        r = radios[i]
        rx, ry = (r, r) if isinstance(r, (int, float)) else r

        anillos.append([
            p + u * rx * math.cos(2 * math.pi * j / segmentos)
              + v * ry * math.sin(2 * math.pi * j / segmentos)
            for j in range(segmentos)
        ])

    conectar_anillos(
        pieza, anillos, slot, tono,
        cerrar_inicio=cerrar, cerrar_final=cerrar
    )


def caja(pieza, centro, tamano, slot, tono):
    c = Vector(centro)
    x, y, z = [v / 2 for v in tamano]
    vertices = [
        c + Vector(p) for p in (
            (-x, -y, -z), (x, -y, -z),
            (x, y, -z), (-x, y, -z),
            (-x, -y, z), (x, -y, z),
            (x, y, z), (-x, y, z),
        )
    ]
    caras = [
        (0, 3, 2, 1), (4, 5, 6, 7),
        (0, 1, 5, 4), (1, 2, 6, 5),
        (2, 3, 7, 6), (3, 0, 4, 7),
    ]
    pieza.agregar(vertices, caras, slot, tono)


# ---------------- BODY: TORSO + CUELLO ----------------

body = PARTES["BODY"]

# Doce anillos de torso.
TORSO = [
    (0.760, 0.148, 0.101),
    (0.800, 0.154, 0.105),
    (0.850, 0.159, 0.109),
    (0.890, 0.151, 0.105),
    (0.930, 0.137, 0.096),
    (0.970, 0.139, 0.099),
    (1.020, 0.146, 0.105),
    (1.070, 0.156, 0.110),
    (1.120, 0.166, 0.112),
    (1.170, 0.181, 0.109),
    (1.210, 0.188, 0.101),
    (1.245, 0.086, 0.071),
]

conectar_anillos(
    body,
    [anillo_z(0, 0, z, rx, ry) for z, rx, ry in TORSO],
    CAMISA, "CREMA",
    cerrar_inicio=True, cerrar_final=True
)

# Tres anillos de cuello, solapados con torso y cabeza.
conectar_anillos(
    body,
    [
        anillo_z(0, 0, 1.235, 0.057, 0.055, 12),
        anillo_z(0, 0, 1.280, 0.054, 0.052, 12),
        anillo_z(0, 0, 1.330, 0.059, 0.056, 12),
    ],
    PIEL, "PIEL"
)

# Falda: volumen acampanado con 12 pliegues suaves.
anillos_falda = []
for z, rx, ry, profundidad in [
    (0.925, 0.145, 0.105, 0.003),
    (0.830, 0.168, 0.119, 0.008),
    (0.710, 0.184, 0.132, 0.010),
    (0.590, 0.195, 0.141, 0.011),
    (0.490, 0.202, 0.147, 0.012),
]:
    anillo = []
    for j in range(48):
        a = 2 * math.pi * j / 48
        pliegue = profundidad * math.cos(12 * a)
        anillo.append((
            (rx + pliegue) * math.cos(a),
            (ry + pliegue) * math.sin(a),
            z
        ))
    anillos_falda.append(anillo)

conectar_anillos(
    body, anillos_falda, PANTALON, "CREMA"
)

# Cintura y lazo posterior del delantal.
conectar_anillos(
    body,
    [
        anillo_z(0, 0, 0.911, 0.150, 0.113, 20),
        anillo_z(0, 0, 0.934, 0.150, 0.113, 20),
    ],
    CAMISA, "DELANTAL"
)

for sg in (-1, 1):
    elipsoide(
        body, (sg * 0.030, -0.119, 0.922),
        (0.038, 0.011, 0.017),
        CAMISA, "DELANTAL", 8, 4
    )

# Paneles curvos del delantal. Son superficies abiertas,
# intencionadamente de doble cara.
def panel_delantal(z0, z1, ancho0, ancho1, y0, y1, filas=5):
    vertices = []
    caras = []
    columnas = 10

    for i in range(filas + 1):
        t = i / filas
        z = z0 + (z1 - z0) * t
        ancho = ancho0 + (ancho1 - ancho0) * t
        yc = y0 + (y1 - y0) * t

        for j in range(columnas + 1):
            u = -1 + 2 * j / columnas
            vertices.append((
                ancho * u, yc - 0.015 * u * u, z
            ))

    for i in range(filas):
        for j in range(columnas):
            a = i * (columnas + 1) + j
            caras.append((
                a, a + 1, a + columnas + 2, a + columnas + 1
            ))

    body.agregar(vertices, caras, CAMISA, "DELANTAL")


panel_delantal(0.540, 0.925, 0.135, 0.105, 0.169, 0.128)
panel_delantal(0.925, 1.140, 0.078, 0.063, 0.128, 0.127, 3)

for sg in (-1, 1):
    tubo(
        body,
        [(sg * 0.056, 0.129, 1.135),
         (sg * 0.065, 0.088, 1.218),
         (sg * 0.062, -0.040, 1.232)],
        [(0.009, 0.003)] * 3,
        CAMISA, "DELANTAL", 6
    )

# Bolsillo frontal.
caja(
    body, (0.035, 0.154, 0.786),
    (0.096, 0.008, 0.083),
    CAMISA, "CREMA_OSC"
)

# Manchas de pintura como islas planas pegadas al delantal.
def mancha(x, z, radio, tono, semilla):
    # Altura del panel inferior en esta posicion.
    t = (z - 0.540) / (0.925 - 0.540)
    ancho = 0.135 + (0.105 - 0.135) * t
    yc = 0.169 + (0.128 - 0.169) * t
    y = yc - 0.015 * (x / ancho) ** 2 + 0.002

    vertices = [(x, y, z)]
    for j in range(9):
        a = 2 * math.pi * j / 9
        r = radio * (0.78 + 0.20 * math.sin(j * 2.1 + semilla))
        vertices.append((
            x + r * math.cos(a),
            y + 0.0003,
            z + r * math.sin(a)
        ))

    body.agregar(
        vertices,
        [(0, 1 + j, 1 + (j + 1) % 9) for j in range(9)],
        CAMISA, tono
    )


for datos in [
    (-0.062, 0.845, 0.016, "PINT_AZUL", 1),
    (-0.073, 0.721, 0.023, "PINT_OCRE", 2),
    ( 0.073, 0.628, 0.020, "PINT_VERDE", 3),
    (-0.018, 0.582, 0.012, "PINT_ROSA", 4),
]:
    mancha(*datos)


# ---------------- CABEZA ----------------

head = PARTES["HEAD"]
CENTRO_CABEZA = Vector((0, 0, 1.385))
RADIOS_CABEZA = (0.119, 0.113, 0.155)

elipsoide(
    head, CENTRO_CABEZA, RADIOS_CABEZA,
    PIEL, "PIEL", 20, 12
)

elipsoide(
    head, (0, 0.111, 1.375),
    (0.017, 0.022, 0.017),
    PIEL, "PIEL", 8, 5
)

for sg in (-1, 1):
    elipsoide(
        head, (sg * 0.116, -0.006, 1.384),
        (0.016, 0.023, 0.031),
        PIEL, "PIEL", 8, 5
    )

# Sonrisa curvada siguiendo la superficie de la cara.
tubo(
    head,
    [
        (-0.027, 0.101, 1.350),
        (-0.014, 0.106, 1.344),
        ( 0.000, 0.108, 1.342),
        ( 0.014, 0.106, 1.344),
        ( 0.027, 0.101, 1.350),
    ],
    [0.0022] * 5,
    PIEL, "BOCA", 6
)

# Cejas pequenas, sin expresion agresiva.
for sg in (-1, 1):
    tubo(
        head,
        [
            (sg * 0.030, 0.105, 1.427),
            (sg * 0.044, 0.100, 1.431),
            (sg * 0.057, 0.094, 1.427),
        ],
        [0.003] * 3,
        PELO, "PELO", 6
    )


# ---------------- OJOS ----------------

eyes = PARTES["EYES"]

for sg in (-1, 1):
    elipsoide(
        eyes, (sg * 0.043, 0.104, 1.406),
        (0.0125, 0.0085, 0.014),
        OJOS, "VERDE_OJO", 10, 6
    )
    elipsoide(
        eyes, (sg * 0.043, 0.111, 1.406),
        (0.006, 0.003, 0.008),
        OJOS, "PUPILA", 8, 4
    )


# ---------------- PELO: CASQUETE + MONO + CINTA ----------------

hair = PARTES["HAIR"]
rx, ry, rz = (0.124, 0.121, 0.166)

anillos_pelo = []
for k in range(1, 9):
    anillo = []
    for j in range(24):
        a = 2 * math.pi * j / 24
        # Frente alto, nuca baja. +Y es la cara.
        limite = math.radians(
            102 - 31 * math.sin(a) + 4 * math.cos(3 * a)
        )
        ph = limite * k / 8
        anillo.append(CENTRO_CABEZA + Vector((
            rx * math.sin(ph) * math.cos(a),
            ry * math.sin(ph) * math.sin(a),
            rz * math.cos(ph)
        )))
    anillos_pelo.append(anillo)

# Anillo diminuto superior, soldado en limpieza.
corona = CENTRO_CABEZA + Vector((0, 0, rz))
anillos_pelo.insert(0, [corona.copy() for _ in range(24)])

conectar_anillos(hair, anillos_pelo, PELO, "PELO")

elipsoide(
    hair, (0, -0.124, 1.411),
    (0.068, 0.057, 0.065),
    PELO, "PELO", 12, 8
)

# Cinta anudada alrededor del mono.
for sg in (-1, 1):
    elipsoide(
        hair, (sg * 0.035, -0.171, 1.442),
        (0.042, 0.013, 0.020),
        CAMISA, "ROSA", 8, 4
    )

elipsoide(
    hair, (0, -0.181, 1.443),
    (0.013, 0.011, 0.013),
    CAMISA, "ROSA", 8, 4
)

for sg in (-1, 1):
    tubo(
        hair,
        [(sg * 0.011, -0.174, 1.435),
         (sg * 0.024, -0.174, 1.404),
         (sg * 0.039, -0.166, 1.380)],
        [(0.009, 0.002)] * 3,
        CAMISA, "ROSA", 6
    )


# ---------------- BRAZOS ----------------

MANOS = {}

for sg, nombre in [(-1, "ARM_L"), (1, "ARM_R")]:
    pieza = PARTES[nombre]

    # Polilinea hombro -> codo -> muneca, con anillos intermedios.
    puntos = [
        (sg * 0.190, 0.000, 1.200),
        (sg * 0.207, 0.014, 1.125),
        (sg * 0.215, 0.025, 1.045),
        (sg * 0.217, 0.052, 0.987),
        (sg * 0.214, 0.080, 0.950),
    ]

    tubo(
        pieza, puntos,
        [0.045, 0.044, 0.042, 0.040, 0.038],
        CAMISA, "CREMA", 12
    )

    # Punio doblado de manga.
    tubo(
        pieza,
        [(sg * 0.214, 0.075, 0.963),
         (sg * 0.214, 0.087, 0.943)],
        [0.041, 0.041],
        CAMISA, "CREMA_OSC", 12
    )

    tubo(
        pieza,
        [(sg * 0.214, 0.083, 0.954),
         (sg * 0.210, 0.110, 0.912)],
        [0.031, 0.028],
        PIEL, "PIEL", 10
    )

    mano = Vector((sg * 0.210, 0.129, 0.900))
    MANOS[nombre] = mano

    elipsoide(
        pieza, mano, (0.033, 0.039, 0.040),
        PIEL, "PIEL", 10, 6
    )
    elipsoide(
        pieza, mano + Vector((-sg * 0.026, 0.017, 0.012)),
        (0.012, 0.017, 0.022),
        PIEL, "PIEL", 8, 4
    )


# ---------------- PIERNAS: CINCO ANILLOS + SUELA PLANA ----------------

for sg, nombre in [(-1, "LEG_L"), (1, "LEG_R")]:
    pieza = PARTES[nombre]
    x = sg * 0.079

    conectar_anillos(
        pieza,
        [
            anillo_z(x, 0.000, 0.810, 0.067, 0.071, 12),
            anillo_z(x, 0.007, 0.645, 0.062, 0.065, 12),
            anillo_z(x, 0.016, 0.450, 0.054, 0.057, 12),
            anillo_z(x, 0.008, 0.290, 0.047, 0.050, 12),
            anillo_z(x, 0.003, 0.170, 0.043, 0.047, 12),
        ],
        PIEL, "PIEL"
    )

    # Bota cerrada: el anillo inferior y su tapa son planos.
    conectar_anillos(
        pieza,
        [
            anillo_z(x, 0.047, 0.000, 0.057, 0.094, 12),
            anillo_z(x, 0.047, 0.020, 0.059, 0.096, 12),
        ],
        BOTAS, "SUELA", True, True
    )

    conectar_anillos(
        pieza,
        [
            anillo_z(x, 0.047, 0.018, 0.059, 0.096, 12),
            anillo_z(x, 0.045, 0.065, 0.060, 0.092, 12),
            anillo_z(x, 0.020, 0.109, 0.052, 0.064, 12),
            anillo_z(x, 0.005, 0.150, 0.048, 0.052, 12),
            anillo_z(x, 0.003, 0.205, 0.049, 0.052, 12),
        ],
        BOTAS, "BOTAS", False, True
    )


# ---------------- PINCEL: INTEGRADO EN ARM_R ----------------

derecha = PARTES["ARM_R"]
m = MANOS["ARM_R"]

tubo(
    derecha,
    [m + Vector((0, 0.015, -0.060)),
     m + Vector((0, 0.023, 0.050)),
     m + Vector((0, 0.030, 0.170))],
    [0.006, 0.006, 0.005],
    BOTAS, "MADERA", 8
)

tubo(
    derecha,
    [m + Vector((0, 0.030, 0.165)),
     m + Vector((0, 0.032, 0.197))],
    [0.009, 0.009],
    BOTAS, "METAL", 8
)

tubo(
    derecha,
    [m + Vector((0, 0.032, 0.195)),
     m + Vector((0, 0.034, 0.225)),
     m + Vector((0, 0.035, 0.238))],
    [(0.010, 0.006), (0.009, 0.005), (0.004, 0.003)],
    PELO, "CERDAS", 8
)

elipsoide(
    derecha, m + Vector((0, 0.035, 0.233)),
    (0.006, 0.004, 0.007),
    CAMISA, "PINT_AZUL", 8, 4
)


# ---------------- PALETA: INTEGRADA EN ARM_L ----------------

izquierda = PARTES["ARM_L"]
m = MANOS["ARM_L"]
centro_paleta = m + Vector((-0.005, 0.060, -0.014))

elipsoide(
    izquierda, centro_paleta,
    (0.075, 0.072, 0.009),
    BOTAS, "MADERA", 16, 6
)

for dx, dy, tono in [
    (-0.040, 0.025, "PINT_ROSA"),
    (-0.015, 0.047, "PINT_OCRE"),
    ( 0.018, 0.045, "PINT_VERDE"),
    ( 0.043, 0.022, "PINT_AZUL"),
]:
    elipsoide(
        izquierda,
        centro_paleta + Vector((dx, dy, 0.010)),
        (0.011, 0.011, 0.0025),
        CAMISA, tono, 8, 4
    )


# ---------------- LIMPIEZA DE SESION ----------------

if bpy.context.object and bpy.context.object.mode != "OBJECT":
    bpy.ops.object.mode_set(mode="OBJECT")

for obj in list(bpy.data.objects):
    bpy.data.objects.remove(obj, do_unlink=True)

for coleccion in list(bpy.data.collections):
    bpy.data.collections.remove(coleccion)

for grupo in (
    bpy.data.meshes, bpy.data.materials,
    bpy.data.cameras, bpy.data.lights
):
    for bloque in list(grupo):
        if bloque.users == 0:
            grupo.remove(bloque)

scene = bpy.context.scene
scene.unit_settings.system = "METRIC"
scene.unit_settings.scale_length = 1.0

col_npc = bpy.data.collections.new("COL_NPC")
scene.collection.children.link(col_npc)

raiz = bpy.data.objects.new("SM_NPC_LUNA", None)
raiz.empty_display_type = "PLAIN_AXES"
raiz.empty_display_size = 0.18
col_npc.objects.link(raiz)

raiz["NPC_ID"] = "01"
raiz["ISLA"] = "RAIZ"
raiz["PROFESION"] = "PINTORA"
raiz["TIPO"] = "HUMANO"
raiz["RIG"] = "NO"
raiz["FRENTE_BLENDER"] = "+Y"


# ---------------- SEIS MATERIALES PBR ----------------

def crear_material(nombre, roughness, emision=False):
    mat = bpy.data.materials.new(nombre)
    mat.use_nodes = True
    mat.use_backface_culling = False

    nt = mat.node_tree
    nt.nodes.clear()

    salida = nt.nodes.new("ShaderNodeOutputMaterial")
    bsdf = nt.nodes.new("ShaderNodeBsdfPrincipled")
    attr = nt.nodes.new("ShaderNodeVertexColor")
    attr.layer_name = "COLOR_0"

    attr.location = (-300, 80)
    bsdf.location = (0, 80)
    salida.location = (320, 80)

    # Colores absolutos en atributo; no multiplicacion procedural.
    bsdf.inputs["Base Color"].default_value = (1, 1, 1, 1)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = 0.0

    nt.links.new(attr.outputs["Color"], bsdf.inputs["Base Color"])
    nt.links.new(bsdf.outputs["BSDF"], salida.inputs["Surface"])

    if emision:
        bsdf.inputs["Emission Color"].default_value = (
            1.0, 0.78, 0.52, 1.0
        )
        bsdf.inputs["Emission Strength"].default_value = 0.06

    return mat


materiales = [
    crear_material("MAT_NPC_LUNA_PIEL", 0.56),
    crear_material("MAT_NPC_LUNA_PELO", 0.72),
    crear_material("MAT_NPC_LUNA_CAMISA", 0.82),
    crear_material("MAT_NPC_LUNA_PANTALON", 0.82),
    crear_material("MAT_NPC_LUNA_BOTAS", 0.72),
    crear_material("MAT_NPC_LUNA_OJOS", 0.20, True),
]


# ---------------- ESCALA HORNEADA Y MESHES ----------------

# La altura se mide sobre la anatomia + pelo, sin herramientas.
altura_ref = max(
    v.z
    for nombre in ("BODY", "HEAD", "HAIR", "LEG_L", "LEG_R")
    for v in PARTES[nombre].vertices
)

factor = ALTURA_OBJETIVO / altura_ref
objetos = []

for nombre, pieza in PARTES.items():
    pivote = Vector(PIVOTES_REF[nombre])
    if ESCALAR_PIVOTES:
        pivote *= factor

    vertices = [v * factor - pivote for v in pieza.vertices]
    me = bpy.data.meshes.new(f"SM_NPC_LUNA_{nombre}_MESH")
    me.from_pydata(vertices, [], pieza.caras)
    me.update()

    # Cada mesh guarda solo los materiales que realmente utiliza.
    usados = sorted(set(pieza.slots))
    local = {slot: i for i, slot in enumerate(usados)}

    for slot in usados:
        me.materials.append(materiales[slot])

    atributo = me.color_attributes.new(
        name="COLOR_0", type="FLOAT_COLOR", domain="CORNER"
    )
    me.color_attributes.active_color = atributo
    me.color_attributes.render_color_index = 0

    for poligono, slot, rgba in zip(
        me.polygons, pieza.slots, pieza.colores
    ):
        poligono.material_index = local[slot]
        poligono.use_smooth = nombre not in ("LEG_L", "LEG_R")
        for li in poligono.loop_indices:
            atributo.data[li].color = rgba

    # Limpieza dentro de cada objeto. No es una union booleana
    # entre prendas, anatomia y accesorios.
    bm = bmesh.new()
    bm.from_mesh(me)

    bmesh.ops.remove_doubles(
        bm, verts=list(bm.verts), dist=0.000001
    )
    bmesh.ops.dissolve_degenerate(
        bm, edges=list(bm.edges), dist=0.000001
    )

    sueltos = [v for v in bm.verts if not v.link_edges]
    if sueltos:
        bmesh.ops.delete(bm, geom=sueltos, context="VERTS")

    bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
    bm.to_mesh(me)
    bm.free()
    me.update()

    obj = bpy.data.objects.new(f"SM_NPC_LUNA_{nombre}", me)
    col_npc.objects.link(obj)

    obj.parent = raiz
    obj.location = pivote
    obj.rotation_euler = (0, 0, 0)
    obj.scale = (1, 1, 1)

    obj["PIVOTE_REFERENCIA"] = list(PIVOTES_REF[nombre])
    objetos.append(obj)

bpy.context.view_layer.update()


# ---------------- VALIDACION Y RESUMEN ----------------

def puntos_mundo(lista):
    return [
        obj.matrix_world @ vert.co
        for obj in lista
        for vert in obj.data.vertices
    ]


def limites(lista):
    pts = puntos_mundo(lista)
    minimo = Vector(tuple(min(p[i] for p in pts) for i in range(3)))
    maximo = Vector(tuple(max(p[i] for p in pts) for i in range(3)))
    return minimo, maximo


detalles = []
tris_total = 0

for obj in objetos:
    obj.data.calc_loop_triangles()
    tris = len(obj.data.loop_triangles)
    tris_total += tris

    bm = bmesh.new()
    bm.from_mesh(obj.data)

    detalles.append({
        "mesh": obj.name,
        "triangulos": tris,
        "vertices": len(obj.data.vertices),
        "superficies_material": len(obj.data.materials),
        "aristas_frontera": sum(e.is_boundary for e in bm.edges),
        "aristas_con_mas_de_2_caras": sum(
            len(e.link_faces) > 2 for e in bm.edges
        ),
        "vertices_sueltos": sum(not v.link_edges for v in bm.verts),
        "pivote_metros": list(obj.location),
    })
    bm.free()

minimo, maximo = limites(objetos)
dimensiones = maximo - minimo

assert tris_total <= 6000, f"Presupuesto excedido: {tris_total} tris"
assert len(objetos) == 8
assert len(materiales) == 6
assert abs(minimo.z) < 0.00001, f"Suelo incorrecto: {minimo.z}"
assert all(
    (obj.scale - Vector((1, 1, 1))).length < 0.000001
    for obj in objetos
)

anatomia = [
    obj for obj in objetos
    if obj.name.endswith((
        "_BODY", "_HEAD", "_HAIR", "_LEG_L", "_LEG_R"
    ))
]
amin, amax = limites(anatomia)
assert abs((amax.z - amin.z) - ALTURA_OBJETIVO) < 0.001

resumen = {
    "npc": NOMBRE,
    "isla": "RAIZ",
    "version": 1,
    "triangulos_total": tris_total,
    "objetos_mesh": len(objetos),
    "objetos_incluyendo_empty": len(objetos) + 1,
    "materiales_unicos": len(materiales),
    "altura_anatomia_m": amax.z - amin.z,
    "dimensiones_con_herramientas_m": list(dimensiones),
    "factor_horneado": factor,
    "pivotes_escalados": ESCALAR_PIVOTES,
    "doble_cara": True,
    "animaciones": False,
    "rig": False,
    "validacion_visual_manual": "PENDIENTE",
    "prueba_importacion_godot": "PENDIENTE",
    "notas_topologia": [
        "Anatomia, ropa y accesorios contienen islas superpuestas.",
        "Falda, delantal y casquete tienen fronteras abiertas.",
        "Recalcular normales no demuestra ausencia de intersecciones.",
    ],
    "meshes": detalles,
}

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


# ---------------- EXPORTACION GLB ----------------

bpy.ops.object.select_all(action="DESELECT")
raiz.select_set(True)

for obj in objetos:
    obj.select_set(True)

bpy.context.view_layer.objects.active = objetos[0]

ruta_glb = OUTPUT_DIR / "SM_NPC_LUNA.glb"

opciones = {
    "filepath": str(ruta_glb),
    "export_format": "GLB",
    "use_selection": True,
    "export_yup": True,
    "export_apply": True,
    "export_animations": False,
    "export_materials": "EXPORT",
}

# Compatibilidad entre revisiones del exportador glTF.
propiedades = {
    p.identifier
    for p in bpy.ops.export_scene.gltf.get_rna_type().properties
}
if "export_all_vertex_colors" in propiedades:
    opciones["export_all_vertex_colors"] = True

bpy.ops.export_scene.gltf(**opciones)


# ---------------- SEIS CAPTURAS ORBITALES ----------------

marca = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
rutas_capturas = []

def orientar(obj, objetivo):
    direccion = Vector(objetivo) - obj.location
    obj.rotation_euler = direccion.to_track_quat("-Z", "Y").to_euler()


if RENDER_CAPTURAS:
    col_preview = bpy.data.collections.new("COL_PREVIEW_TEMP")
    scene.collection.children.link(col_preview)

    def luz(nombre, posicion, energia, tamano):
        data = bpy.data.lights.new(nombre, "AREA")
        data.energy = energia
        data.shape = "DISK"
        data.size = tamano

        obj = bpy.data.objects.new(nombre, data)
        col_preview.objects.link(obj)
        obj.location = posicion
        orientar(obj, (0, 0, 0.95))
        return obj

    luz("PREVIEW_KEY",  ( 3.0,  4.0, 4.2), 450, 4.0)
    luz("PREVIEW_FILL", (-3.0,  1.5, 2.7), 250, 3.5)
    luz("PREVIEW_RIM",  ( 0.0, -3.0, 3.3), 400, 3.0)

    mundo = bpy.data.worlds.new("WORLD_NPC_PREVIEW")
    mundo.use_nodes = True
    fondo = mundo.node_tree.nodes.get("Background")
    fondo.inputs["Color"].default_value = (0.16, 0.14, 0.12, 1)
    fondo.inputs["Strength"].default_value = 0.5
    scene.world = mundo

    cam_data = bpy.data.cameras.new("PREVIEW_CAMERA")
    cam = bpy.data.objects.new("PREVIEW_CAMERA", cam_data)
    col_preview.objects.link(cam)
    scene.camera = cam

    cam_data.type = "ORTHO"

    # Encuadre conservador para incluir herramienta y paleta
    # en los seis angulos.
    centro = (minimo + maximo) * 0.5
    cam_data.ortho_scale = dimensiones.length * 1.20

    scene.render.engine = "BLENDER_EEVEE_NEXT"
    scene.render.resolution_x = RESOLUCION
    scene.render.resolution_y = RESOLUCION
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.film_transparent = False
    scene.view_settings.view_transform = "AgX"

    for i in range(6):
        # Primera vista: 3/4 frontal. Incrementos exactos de 60°.
        angulo = math.radians(30 + i * 60)
        cam.location = centro + Vector((
            3.5 * math.sin(angulo),
            3.5 * math.cos(angulo),
            0.95,
        ))
        orientar(cam, centro)

        ruta = OUTPUT_DIR / (
            f"cap_NPC_LUNA_v1_{marca}_{i}.png"
        )
        scene.render.filepath = str(ruta)
        bpy.ops.render.render(write_still=True)
        rutas_capturas.append(str(ruta))

    # El .blend final conserva solo NPC + Empty.
    scene.camera = None
    for obj in list(col_preview.objects):
        bpy.data.objects.remove(obj, do_unlink=True)
    bpy.data.collections.remove(col_preview)

    for grupo in (bpy.data.cameras, bpy.data.lights):
        for bloque in list(grupo):
            if bloque.users == 0:
                grupo.remove(bloque)


# ---------------- GUARDAR BLEND E INFORME ----------------

resumen["capturas"] = rutas_capturas
resumen["archivo_glb"] = str(ruta_glb)

ruta_blend = OUTPUT_DIR / "SM_NPC_LUNA.blend"
resumen["archivo_blend"] = str(ruta_blend)

bpy.ops.wm.save_as_mainfile(filepath=str(ruta_blend))

with open(
    OUTPUT_DIR / "SM_NPC_LUNA_RESUMEN.json",
    "w", encoding="utf-8"
) as archivo:
    json.dump(resumen, archivo, ensure_ascii=False, indent=2)

print("\n========== LUNA: GENERACION COMPLETADA ==========")
print(json.dumps(resumen, ensure_ascii=False, indent=2))

