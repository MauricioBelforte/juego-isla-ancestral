# Propuesta B
Continuamos con la **revisión artística del resto de islas**: Ceniza (13–22), Coral (23–30) y Aurora (31–35).

Esta pasada completa los accesorios y detalles identificativos de cada profesión, trabajando siempre sobre los **ALTA originales**. Guarda una copia en `REVISION_02/` por NPC, sin sobrescribir los `.blend/.glb` base.

## 1. Script `revision_artistica_restantes.py`

Guarda este archivo junto a los anteriores y ejecútalo con:

```bash
blender --background --factory-startup --python revision_artistica_restantes.py
```

El script limpia la sesión entre personajes. Revisa los ALTA de cada carpeta `NN_NOMBRE/SM_NPC_NOMBRE.blend` y genera la revisión correspondiente.

```python
# ================================================================
# REVISION ARTISTICA 02 — CENIZA + CORAL + AURORA
# NPCs 13 - 35
# Blender 4.2+
#
# Entrada:
#   NPC_EXPORT/02_CENIZA/NN_NOMBRE/SM_NPC_NOMBRE.blend
#   NPC_EXPORT/03_CORAL/NN_NOMBRE/SM_NPC_NOMBRE.blend
#   NPC_EXPORT/04_AURORA/NN_NOMBRE/SM_NPC_NOMBRE.blend
#
# Salida:
#   .../NN_NOMBRE/REVISION_02/
#       SM_NPC_NOMBRE.blend
#       SM_NPC_NOMBRE.glb
#       REVISION_02.json
#       6 capturas orbitales (opcional)
#
# Conserva los archivos ALTA originales.
# Añade detalles a los 8 meshes existentes.
# No crea materiales nuevos. Mantiene <= 6000 tris.
# ================================================================

import bpy
import bmesh
import math
import json
import traceback

from pathlib import Path
from datetime import datetime
from mathutils import Vector


# ---------------- CONFIGURACION ----------------

BASE = Path.home() / "NPC_EXPORT"

GENERAR_CAPTURAS = True
RESOLUCION = 768

# None = todos los NPCs 13-35
SOLO_NOMBRES = None

LIMITE_TRIS = 6000

# NPCs por Isla
NPC_CENIZA = [
    "BRASA", "OBSIDIANA", "TUFA", "HORNO",
    "CENIZA", "PEDRO", "VULCANIA", "CHISPA",
    "CALDERA", "HUMO"
]

NPC_CORAL = [
    "OLA", "PERLA", "CONCHA", "ALGA",
    "TIBURON", "ESTRELLA", "NACAR", "CORAL_ROSA"
]

NPC_AURORA = [
    "HIELO", "AURORA", "NIEVE", "GLACIAR",
    "ESTRELLA_FUGAZ"
]

COLORES = {
    "CUERO": "#825D43",
    "MADERA": "#A9825D",
    "MADERA_OSC": "#65513E",
    "CREMA": "#E9DDC5",
    "CREMA_OSC": "#CABEAA",
    "BLANCO": "#EEE9DF",
    "PLATA": "#B8BCB6",
    "HIERRO": "#899194",
    "ORO": "#BD9F59",
    "COBRE": "#AD7956",
    "ROSA": "#BC8984",
    "VERDE": "#758565",
    "HIERBA": "#93906A",
    "TIERRA": "#806449",
    "AZUL": "#728F96",
    "AZUL_PROFUNDO": "#39486F",
    "AZUL_LUZ": "#8FBAC9",
    "TERRACOTA": "#A7664E",
    "CARBON": "#465057",
    "GRIS": "#858783",
    "NEGRO": "#302E2C",
    "NARANJA": "#C8874E",
    "AMBAR": "#D8A95C",
}

IMPLEMENTADO = {
    # CENIZA 13-22
    "BRASA": ["Linterna de cinturón", "Hebilla y refuerzos de cuero"],
    "OBSIDIANA": ["Mochila de pergaminos", "Bolsillos de frascos", "Remates de bastón"],
    "TUFA": ["Cinturón de frascos", "Bolsillo del delantal"],
    "HORNO": ["Bolsillo del delantal", "Manchas de comida"],
    "CENIZA": ["Guantes reforzados", "Hebilla de cinturón"],
    "PEDRO": ["Linterna de casco/cinturón", "Planos de bolsillo", "Refuerzos"],
    "VULCANIA": ["Broche plateado", "Libros/pergamino con cierres"],
    "CHISPA": ["Cinturón con monedas", "Pulseras decorativas", "Adornos dorados"],
    "CALDERA": ["Linterna de cinturón", "Silbato", "Refuerzos de guardia"],
    "HUMO": ["Collar volcánico", "Pulseras de cuero", "Remates de flauta"],

    # CORAL 23-30
    "OLA": ["Collar de perlas", "Aretes de concha", "Pulsera de coral"],
    "PERLA": ["Collar de perlas", "Anillos sugeridos", "Bordados dorados"],
    "CONCHA": ["Collar de caracoles", "Pulsera de coral"],
    "ALGA": ["Collar de conchas", "Pulsera de algas", "Cesta de algas"],
    "TIBURON": ["Silbato de guardia", "Hebilla reforzada"],
    "ESTRELLA": ["Collar de runas", "Adornos estrellados", "Detalles dorados"],
    "NACAR": ["Cinturón de herramientas", "Guantes de trabajo"],
    "CORAL_ROSA": ["Collar de conchas", "Pulsera de coral", "Adornos del vestido"],

    # AURORA 31-35
    "HIELO": ["Collar de runas", "Anillo sugerido", "Guantes abiertos", "Cristal del báculo"],
    "AURORA": ["Medalla/brazaletes dorados", "Gafas de latón", "Constelaciones"],
    "NIEVE": ["Hierbas secas", "Frascos del mandil", "Pulsera floral"],
    "GLACIAR": ["Hebilla de cinturón", "Refuerzos de herramientas"],
    "ESTRELLA_FUGAZ": ["Collar oscuro", "Anillo de gema", "Detalles del farol"],
}


# ---------------- UTILIDADES ----------------

def guardar_json(ruta, datos):
    ruta.parent.mkdir(parents=True, exist_ok=True)
    with open(ruta, "w", encoding="utf-8") as f:
        json.dump(datos, f, ensure_ascii=False, indent=2)


def color_lineal(nombre):
    if nombre not in COLORES:
        return (0.5, 0.5, 0.5, 1.0)

    hexadecimal = COLORES[nombre].lstrip("#")
    rgb = [int(hexadecimal[i:i + 2], 16) / 255 for i in (0, 2, 4)]

    def convertir(v):
        return v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4

    return tuple(convertir(v) for v in rgb) + (1.0,)


def limpiar():
    if bpy.context.object and bpy.context.object.mode != "OBJECT":
        bpy.ops.object.mode_set(mode="OBJECT")

    for obj in list(bpy.data.objects):
        bpy.data.objects.remove(obj, do_unlink=True)

    for col in list(bpy.data.collections):
        bpy.data.collections.remove(col)

    for grupo in (
        bpy.data.meshes, bpy.data.materials,
        bpy.data.cameras, bpy.data.lights
    ):
        for bloque in list(grupo):
            if bloque.users == 0:
                grupo.remove(bloque)

    scene = bpy.context.scene
    scene.camera = None
    scene.unit_settings.system = "METRIC"
    scene.unit_settings.scale_length = 1.0


def cargar(ruta, nombre):
    limpiar()

    raiz_nombre = f"SM_NPC_{nombre}"

    with bpy.data.libraries.load(str(ruta), link=False) as (src, dst):
        dst.objects = [
            n for n in src.objects
            if n == raiz_nombre or n.startswith(raiz_nombre + "_")
        ]

    col = bpy.data.collections.new("COL_NPC")
    bpy.context.scene.collection.children.link(col)

    for obj in dst.objects:
        if obj is not None:
            col.objects.link(obj)

    raiz = bpy.data.objects.get(raiz_nombre)
    if raiz is None or raiz.type != "EMPTY":
        raise RuntimeError(f"No se encontro la raiz esperada: {raiz_nombre}")

    partes = {
        obj.name[len(raiz_nombre) + 1:]: obj
        for obj in col.objects
        if obj.type == "MESH"
    }

    esperadas = {
        "BODY", "HEAD", "HAIR", "EYES",
        "ARM_L", "ARM_R", "LEG_L", "LEG_R"
    }

    if set(partes) != esperadas:
        raise RuntimeError(f"Jerarquia inesperada para {nombre}: {sorted(partes)}")

    if any(obj.parent != raiz for obj in partes.values()):
        raise RuntimeError("Todos los meshes deben ser hijos directos del Empty.")

    bpy.context.view_layer.update()

    if any(obj.modifiers for obj in partes.values()):
        raise RuntimeError(f"{nombre}: Se esperaba ALTA sin modificadores aplicados previamente.")

    for obj in partes.values():
        if obj.data.color_attributes.get("COLOR_0") is None:
            raise RuntimeError(f"Falta COLOR_0 en {obj.name}")

    return raiz, partes, col


def triangulos(obj):
    obj.data.calc_loop_triangles()
    return len(obj.data.loop_triangles)


def materiales_usados(partes):
    return {
        obj.data.materials[p.material_index]
        for obj in partes.values()
        for p in obj.data.polygons
    }


def buscar_material(partes, familia):
    sufijo = "_" + familia
    candidatos = {
        mat
        for obj in partes.values()
        for mat in obj.data.materials
        if mat and mat.name.upper().endswith(sufijo)
    }

    if len(candidatos) != 1:
        raise RuntimeError(f"No se pudo identificar el material {familia} para {partes.keys()}")
    return next(iter(candidatos))


def limites(partes):
    puntos = [
        obj.matrix_world @ v.co
        for obj in partes.values()
        for v in obj.data.vertices
    ]
    minimo = Vector(tuple(min(p[i] for p in puntos) for i in range(3)))
    maximo = Vector(tuple(max(p[i] for p in puntos) for i in range(3)))
    return minimo, maximo


# ---------------- DETALLES ----------------

class Detalles:
    def __init__(self, objetivo, transformar):
        self.objetivo = objetivo
        self.transformar = transformar
        self.vertices = []
        self.caras = []
        self.materiales = []
        self.colores = []

    def agregar(self, vertices, caras, material, tono):
        offset = len(self.vertices)
        self.vertices.extend(self.transformar(Vector(v)) for v in vertices)
        self.caras.extend(tuple(offset + i for i in cara) for cara in caras)
        self.materiales.extend([material] * len(caras))
        self.colores.extend([color_lineal(tono)] * len(caras))

    def caja(self, centro, tamano, material, tono):
        c = Vector(centro)
        x, y, z = [s / 2 for s in tamano]
        vertices = [
            c + Vector(p) for p in (
                (-x, -y, -z), (x, -y, -z), (x, y, -z), (-x, y, -z),
                (-x, -y, z), (x, -y, z), (x, y, z), (-x, y, z)
            )
        ]
        caras = [
            (0, 3, 2, 1), (4, 5, 6, 7),
            (0, 1, 5, 4), (1, 2, 6, 5),
            (2, 3, 7, 6), (3, 0, 4, 7)
        ]
        self.agregar(vertices, caras, material, tono)

    def tubo(self, puntos, radios, material, tono, segmentos=6, cerrar=True):
        puntos = [Vector(p) for p in puntos]
        vertices = []
        caras = []
        n = segmentos

        for i, p in enumerate(puntos):
            tangente = (puntos[min(i + 1, len(puntos) - 1)] - puntos[max(0, i - 1)]).normalized()
            ref = Vector((1, 0, 0))
            if abs(ref.dot(tangente)) > 0.94:
                ref = Vector((0, 1, 0))
            u = (ref - tangente * ref.dot(tangente)).normalized()
            v = tangente.cross(u).normalized()
            r = radios[i] if i < len(radios) else radios[-1]
            for j in range(n):
                a = 2 * math.pi * j / n
                vertices.append(p + r * (u * math.cos(a) + v * math.sin(a)))

        for i in range(len(puntos) - 1):
            a0 = i * n
            a1 = (i + 1) * n
            for j in range(n):
                q = (j + 1) % n
                caras.append((a0 + j, a0 + q, a1 + q, a1 + j))

        if cerrar:
            if len(puntos) >= 1:
                caras.append(tuple(reversed(range(n))))
            base = (len(puntos) - 1) * n
            caras.append(tuple(base + j for j in range(n)))

        self.agregar(vertices, caras, material, tono)

    def esfera(self, centro, radios, material, tono, segmentos=8, latitudes=5):
        c = Vector(centro)
        rx, ry, rz = radios
        vertices = [c + Vector((0, 0, rz))]
        n = segmentos
        for k in range(1, latitudes):
            ph = math.pi * k / latitudes
            for j in range(n):
                a = 2 * math.pi * j / n
                vertices.append(c + Vector((
                    rx * math.sin(ph) * math.cos(a),
                    ry * math.sin(ph) * math.sin(a),
                    rz * math.cos(ph)
                )))
        inf = len(vertices)
        vertices.append(c - Vector((0, 0, rz)))
        caras = []
        for j in range(n):
            caras.append((0, 1 + j, 1 + (j + 1) % n))
        for k in range(latitudes - 2):
            a = 1 + k * n
            b = a + n
            for j in range(n):
                q = (j + 1) % n
                caras.append((a + j, b + j, b + q, a + q))
        base = 1 + (latitudes - 2) * n
        for j in range(n):
            caras.append((inf, base + (j + 1) % n, base + j))
        self.agregar(vertices, caras, material, tono)

    def anillo(self, centro, radio, grosor, eje, material, tono, segmentos=12):
        c = Vector(centro)
        eje_n = Vector(eje).normalized()
        ref = Vector((1, 0, 0))
        if abs(ref.dot(eje_n)) > 0.9:
            ref = Vector((0, 1, 0))
        u = (ref - eje_n * ref.dot(eje_n)).normalized()
        v = eje_n.cross(u).normalized()
        vertices = []
        for j in range(segmentos):
            a = 2 * math.pi * j / segmentos
            p = c + radio * (u * math.cos(a) + v * math.sin(a))
            vertices.append(p + grosor * 0.5 * eje_n)
            vertices.append(p - grosor * 0.5 * eje_n)
        caras = []
        for j in range(segmentos):
            q = (j + 1) % segmentos
            a = j * 2
            b = q * 2
            caras.append((a, a + 1, b + 1, b))
        self.agregar(vertices, caras, material, tono)

    def recipiente(self, centro, rx, ry, alto, material, tono):
        c = Vector(centro)
        n = 12
        grosor = 0.004
        specs = [
            (rx * 0.78, ry * 0.78, 0.0),
            (rx, ry, alto * 0.25),
            (rx, ry, alto),
            (rx - grosor, ry - grosor, alto),
            (rx * 0.78 - grosor, ry * 0.78 - grosor, grosor),
        ]
        vertices = []
        for ax, ay, z in specs:
            for j in range(n):
                a = 2 * math.pi * j / n
                vertices.append(c + Vector((ax * math.cos(a), ay * math.sin(a), z)))
        caras = []
        for k in range(len(specs) - 1):
            for j in range(n):
                q = (j + 1) % n
                caras.append((k * n + j, k * n + q, (k + 1) * n + q, (k + 1) * n + j))
        caras.append(tuple(reversed(range(n))))
        caras.append(tuple((len(specs) - 1) * n + j for j in range(n)))
        self.agregar(vertices, caras, material, tono)

    def aplicar(self, coleccion):
        if not self.caras:
            return
        me = bpy.data.meshes.new("TMP_DETALLES_REV")
        me.from_pydata(self.vertices, [], self.caras)
        me.update()
        usados = list(dict.fromkeys(self.materiales))
        idx = {m: i for i, m in enumerate(usados)}
        for m in usados:
            me.materials.append(m)
        attr = me.color_attributes.new("COLOR_0", "FLOAT_COLOR", "CORNER")
        me.color_attributes.active_color = attr
        me.color_attributes.render_color_index = 0
        for p, m, rgba in zip(me.polygons, self.materiales, self.colores):
            p.material_index = idx[m]
            p.use_smooth = True
            for li in p.loop_indices:
                attr.data[li].color = rgba
        bm = bmesh.new()
        bm.from_mesh(me)
        bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
        bm.to_mesh(me)
        bm.free()
        temp = bpy.data.objects.new("TMP_DETALLES_REV", me)
        coleccion.objects.link(temp)
        bpy.ops.object.select_all(action="DESELECT")
        temp.select_set(True)
        self.objetivo.select_set(True)
        bpy.context.view_layer.objects.active = self.objetivo
        bpy.ops.object.join()


# ---------------- DECORACION ----------------

def decorar(nombre, partes, coleccion):
    try:
        mat_ropa = buscar_material(partes, "CAMISA")
    except RuntimeError:
        mat_ropa = buscar_material(partes, "PANTALON")

    mat_duro = buscar_material(partes, "BOTAS")
    mat_pelo = buscar_material(partes, "PELO")

    head = partes["HEAD"]
    alto_cabeza = max((head.matrix_world @ v.co).z for v in head.data.vertices)
    factor = alto_cabeza / 1.540

    anciano = nombre in {"SAGE", "NANA", "OBSIDIANA", "VULCANIA", "HIELO", "NIEVE"}

    def transformar(v):
        if anciano:
            t = max(0.0, min(1.0, (v.z - 0.85) / 0.65))
            v.y += 0.040 * t * t
        return v * factor

    D = {p: Detalles(obj, transformar) for p, obj in partes.items()}
    body = D["BODY"]
    cabeza = D["HEAD"]
    brazo_r = D["ARM_R"]
    brazo_l = D["ARM_L"]

    def bolsillo(x, z, y, col="CREMA_OSC"):
        body.caja((x, y, z), (0.070, 0.007, 0.072), mat_ropa, col)
        body.tubo([(x - 0.035, y + 0.005, z + 0.036), (x + 0.035, y + 0.005, z + 0.036)],
                  [0.0015] * 2, mat_ropa, "CREMA", 5)

    def cinta_metrica():
        body.esfera((-0.143, 0.068, 0.918), (0.028, 0.017, 0.028), mat_duro, "CUERO", 10, 6)
        body.caja((-0.143, 0.087, 0.889), (0.017, 0.005, 0.049), mat_duro, "CREMA")
        for z in (0.872, 0.884, 0.896):
            body.caja((-0.143, 0.090, z), (0.010, 0.002, 0.002), mat_duro, "CARBON")

    def concha_peq(det, centro, escala=1.0):
        c = Vector(centro)
        det.esfera(c, (0.013 * escala, 0.005 * escala, 0.016 * escala), mat_duro, "CREMA", 8, 5)
        for dx in (-0.006, 0.006):
            det.tubo([c + Vector((0, 0.005, -0.01)) * escala,
                      c + Vector((dx, 0.006, 0.009)) * escala],
                     [0.0012] * 2, mat_duro, "ROSA", 5)

    def frasco(x, y, z):
        body.esfera((x, y + 0.022, z), (0.015, 0.017, 0.023), buscar_material(partes, "OJOS"), "VERDE", 8, 5)
        body.tubo([(x, y + 0.022, z + 0.02), (x, y + 0.022, z + 0.05)], [0.013, 0.009], mat_duro, "CUERO", 8)

    # CENIZA
    if nombre == "BRASA":
        body.caja((0.155, 0.050, 0.900), (0.045, 0.043, 0.063), mat_duro, "HIERRO")
        body.esfera((0.155, 0.075, 0.900), (0.014, 0.008, 0.021), buscar_material(partes, "OJOS"), "NARANJA", 8, 5)
        body.caja((0.155, 0.030, 0.868), (0.052, 0.052, 0.007), mat_duro, "CARBON")

    elif nombre == "OBSIDIANA":
        body.esfera((0, -0.150, 1.050), (0.122, 0.068, 0.151), mat_duro, "CUERO", 12, 8)
        frasco(-0.100, 0.135, 0.899)
        frasco(-0.050, 0.135, 0.899)
        brazo_r.tubo([(0.025, 0.022, 0.69), (0.025, 0.022, 0.76)], [0.011, 0.016], mat_duro, "MADERA_OSC", 8)
        brazo_r.esfera((0.025, 0.022, 0.765), (0.019, 0.019, 0.012), mat_duro, "CARBON", 8, 5)

    elif nombre == "TUFA":
        frasco(-0.095, 0.135, 0.899)
        frasco(-0.045, 0.135, 0.899)
        frasco(0.045, 0.135, 0.899)
        bolsillo(0.040, 0.728, 0.165, "CREMA")

    elif nombre == "HORNO":
        bolsillo(-0.032, 0.727, 0.164, "TERRACOTA")
        for c, r, t in [((0.06, 0.168, 0.69), 0.015, "TIERRA"), ((-0.05, 0.151, 0.84), 0.012, "NARANJA")]:
            body.esfera((c[0], c[1], c[2]), (r, r * 0.6, r), mat_ropa, t, 8, 5)

    elif nombre == "CENIZA":
        for sg, p in [(-1, D["LEG_L"]), (1, D["LEG_R"])]:
            x = sg * 0.079 * 1.12
            p.caja((x, 0.062, 0.137), (0.068, 0.009, 0.076), mat_duro, "CUERO")

    elif nombre == "PEDRO":
        body.caja((0.155, 0.050, 0.900), (0.045, 0.043, 0.063), mat_duro, "HIERRO")
        body.esfera((0.155, 0.075, 0.900), (0.014, 0.008, 0.021), buscar_material(partes, "OJOS"), "CREMA", 8, 5)
        bolsillo(-0.060, 0.800, 0.175, "CARBON")
        for z in (0.76, 0.82):
            body.caja((0.065, 0.182, z), (0.050, 0.005, 0.040), mat_duro, "CREMA_OSC")

    elif nombre == "VULCANIA":
        body.esfera((0, 0.125, 1.214), (0.015, 0.006, 0.018), mat_duro, "PLATA", 10, 6)
        for z in (1.128, 1.078, 1.028):
            body.esfera((0.035, 0.129, z), (0.005, 0.004, 0.005), mat_duro, "PLATA", 6, 4)
        brazo_l.caja((-0.210, 0.205, 0.920), (0.158, 0.010, 0.138), mat_ropa, "CREMA")
        brazo_l.tubo([(-0.295, 0.205, 0.920), (-0.125, 0.205, 0.920)], [0.012] * 2, mat_duro, "CUERO", 6)

    elif nombre == "CHISPA":
        for x, y in [(-0.14, 0.90), (-0.10, 0.92), (-0.06, 0.91), (-0.02, 0.93), (0.02, 0.92), (0.06, 0.91), (0.10, 0.92), (0.14, 0.90)]:
            body.esfera((x, 0.135, y), (0.0045, 0.0045, 0.0045), mat_duro, "ORO", 6, 4)
        for sg in (-1, 1):
            cabeza.esfera((sg * 0.116, 0.003, 1.356), (0.006, 0.004, 0.008), mat_duro, "ORO", 8, 5)
            brazo_l.esfera((sg * 0.210, 0.140, 0.910), (0.006, 0.006, 0.006), mat_duro, "COBRE", 6, 4)

    elif nombre == "CALDERA":
        body.caja((0.155, 0.050, 0.900), (0.045, 0.043, 0.063), mat_duro, "HIERRO")
        body.esfera((0.155, 0.075, 0.900), (0.014, 0.008, 0.021), buscar_material(partes, "OJOS"), "CREMA", 8, 5)
        body.caja((0, 0.138, 1.183), (0.017, 0.020, 0.035), mat_duro, "PLATA")
        body.caja((0, 0.150, 1.194), (0.010, 0.008, 0.007), mat_duro, "CARBON")

    elif nombre == "HUMO":
        for sg in (-1, 1):
            brazo_l.esfera((sg * 0.210, 0.140, 0.910), (0.006, 0.006, 0.006), mat_duro, "CUERO", 6, 4)
        concha_peq(body, (0, 0.136, 1.183), 1.05)
        for x in (-0.02, 0.02):
            cabeza.tubo([(x, 0.076, 1.245), (x, 0.080, 1.210)], [0.002] * 2, mat_duro, "NEGRO", 5)

    # CORAL
    elif nombre == "OLA":
        concha_peq(body, (0, 0.136, 1.183), 1.15)
        for sg in (-1, 1):
            cabeza.esfera((sg * 0.116, 0.003, 1.356), (0.006, 0.004, 0.008), mat_duro, "CREMA", 8, 5)
            brazo_l.esfera((sg * 0.210, 0.140, 0.910), (0.006, 0.006, 0.006), mat_duro, "ROSA", 6, 4)

    elif nombre == "PERLA":
        for sg in (-1, 1):
            cabeza.esfera((sg * 0.116, 0.003, 1.356), (0.006, 0.004, 0.008), mat_duro, "ORO", 8, 5)
            brazo_l.esfera((sg * 0.210, 0.140, 0.910), (0.006, 0.006, 0.006), mat_duro, "ORO", 6, 4)
        concha_peq(body, (0, 0.136, 1.183), 1.2)
        for x, z in [(-0.03, 1.21), (0.03, 1.21), (0, 1.20)]:
            body.esfera((x, 0.127, z), (0.0045, 0.0045, 0.0045), mat_duro, "BLANCO", 6, 4)

    elif nombre == "CONCHA":
        concha_peq(body, (0, 0.136, 1.183), 1.1)
        brazo_l.esfera((-0.210, 0.140, 0.910), (0.006, 0.006, 0.006), mat_duro, "ROSA", 6, 4)

    elif nombre == "ALGA":
        concha_peq(body, (0, 0.136, 1.183), 1.0)
        brazo_l.esfera((-0.210, 0.140, 0.910), (0.006, 0.006, 0.006), mat_duro, "VERDE", 6, 4)
        c = Vector((-0.180, 0.010, 0.790))
        body.recipiente(c, 0.050, 0.042, 0.070, mat_duro, "MADERA")
        for dx, dy in [(-0.02, 0), (0.02, 0.01), (0, -0.015)]:
            body.esfera(c + Vector((dx, dy, 0.05)), (0.008, 0.005, 0.004), mat_ropa, "VERDE", 6, 4)

    elif nombre == "TIBURON":
        body.caja((0, 0.138, 1.183), (0.017, 0.020, 0.035), mat_duro, "PLATA")
        body.caja((0, 0.150, 1.194), (0.010, 0.008, 0.007), mat_duro, "CARBON")

    elif nombre == "ESTRELLA":
        for x, z in [(-0.06, 1.16), (0.03, 1.12), (0.065, 1.05), (-0.04, 1.02)]:
            body.esfera((x, 0.119, z), (0.005, 0.003, 0.005), mat_duro, "ORO", 6, 4)
        concha_peq(body, (0, 0.136, 1.183), 1.05)
        brazo_r.tubo([(0.11, 0.04, 0.07), (0.20, 0.04, 0.09)], [0.026, 0.015], mat_duro, "ORO", 10)
        brazo_r.esfera((0.202, 0.04, 0.091), (0.012, 0.026, 0.026), buscar_material(partes, "OJOS"), "AZUL_LUZ", 8, 5)

    elif nombre == "NACAR":
        for x in (-0.14, -0.10, -0.06, -0.02):
            body.esfera((x, 0.135, 0.90), (0.0045, 0.0045, 0.0045), mat_duro, "HIERRO", 6, 4)
        for sg, p in [(-1, D["LEG_L"]), (1, D["LEG_R"])]:
            x = sg * 0.079 * 1.12
            p.caja((x, 0.062, 0.137), (0.068, 0.009, 0.076), mat_duro, "CUERO")

    elif nombre == "CORAL_ROSA":
        concha_peq(body, (0, 0.136, 1.183), 1.15)
        brazo_l.esfera((-0.210, 0.140, 0.910), (0.006, 0.006, 0.006), mat_duro, "ROSA", 6, 4)
        for x, z in [(-0.04, 1.20), (0.04, 1.20)]:
            body.esfera((x, 0.127, z), (0.0045, 0.0045, 0.0045), mat_duro, "ROSA", 6, 4)

    # AURORA
    elif nombre == "HIELO":
        concha_peq(body, (0, 0.136, 1.183), 1.05)
        for sg in (-1, 1):
            brazo_l.esfera((sg * 0.210, 0.140, 0.910), (0.006, 0.006, 0.006), mat_duro, "PLATA", 6, 4)
        brazo_r.tubo([(0.025, 0.022, 0.69), (0.025, 0.022, 0.85)], [0.011, 0.008], mat_duro, "MADERA_OSC", 8)
        brazo_r.esfera((0.025, 0.022, 0.89), (0.044, 0.034, 0.072), buscar_material(partes, "OJOS"), "AZUL_LUZ", 6, 4)
        for x, z in [(-0.05, 1.14), (0.05, 1.14), (0, 1.12)]:
            body.esfera((x, 0.122, z), (0.0045, 0.0045, 0.0045), mat_duro, "ORO", 6, 4)

    elif nombre == "AURORA":
        for x, z in [(-0.06, 1.16), (0.03, 1.12), (0.065, 1.05), (-0.04, 1.02)]:
            body.esfera((x, 0.119, z), (0.005, 0.003, 0.005), mat_duro, "ORO", 6, 4)
        for sg in (-1, 1):
            cabeza.esfera((sg * 0.116, 0.003, 1.356), (0.006, 0.004, 0.008), mat_duro, "ORO", 8, 5)
            brazo_l.esfera((sg * 0.210, 0.140, 0.910), (0.007, 0.007, 0.007), mat_duro, "ORO", 6, 4)
        concha_peq(body, (0, 0.136, 1.183), 1.05)
        brazo_r.tubo([(0.11, 0.04, 0.07), (0.20, 0.04, 0.09)], [0.026, 0.015], mat_duro, "ORO", 10)
        brazo_r.esfera((0.202, 0.04, 0.091), (0.012, 0.026, 0.026), buscar_material(partes, "OJOS"), "AZUL_LUZ", 8, 5)

    elif nombre == "NIEVE":
        frasco(-0.095, 0.135, 0.899)
        frasco(-0.045, 0.135, 0.899)
        frasco(0.045, 0.135, 0.899)
        frasco(0.095, 0.135, 0.899)
        for i in range(3):
            x = (i - 1) * 0.008
            body.tubo([(0, 0.135, 1.196), (x, 0.138, 1.157)], [0.0015] * 2, mat_duro, "MADERA", 5)
            body.esfera((x, 0.140, 1.163), (0.007, 0.003, 0.015), mat_ropa, "HIERBA", 6, 4)
        bolsillo(0.036, 0.728, 0.165, "VERDE")

    elif nombre == "GLACIAR":
        for x in (-0.14, -0.10, -0.06, -0.02):
            body.esfera((x, 0.135, 0.90), (0.0045, 0.0045, 0.0045), mat_duro, "HIERRO", 6, 4)

    elif nombre == "ESTRELLA_FUGAZ":
        concha_peq(body, (0, 0.136, 1.183), 1.05)
        for sg in (-1, 1):
            brazo_l.esfera((sg * 0.210, 0.140, 0.910), (0.006, 0.006, 0.006), mat_duro, "NEGRO", 6, 4)
        c = Vector((0.210, 0.165, 0.820))
        brazo_r.caja(c + Vector((0, 0.04, -0.08)), (0.063, 0.050, 0.082), buscar_material(partes, "OJOS"), "AZUL_LUZ")
        for x, y in [(-0.034, -0.028), (0.034, -0.028), (-0.034, 0.028), (0.034, 0.028)]:
            brazo_r.caja(c + Vector((x, y, -0.08)), (0.007, 0.007, 0.100), mat_duro, "MADERA_OSC")
        brazo_r.caja(c + Vector((0, 0, -0.025)), (0.082, 0.068, 0.018), mat_duro, "MADERA_OSC")
        brazo_r.caja(c + Vector((0, 0, -0.135)), (0.082, 0.068, 0.018), mat_duro, "MADERA_OSC")
        brazo_r.anillo(c + Vector((0, 0, -0.006)), 0.028, 0.004, (0, 0, 1), mat_duro, "MADERA_OSC", 12)

    for d in D.values():
        d.aplicar(coleccion)

    return factor


# ---------------- RENDER Y EXPORT ----------------

def orientar(obj, objetivo):
    direccion = Vector(objetivo) - obj.location
    obj.rotation_euler = direccion.to_track_quat("-Z", "Y").to_euler()


def renderizar(nombre, partes, carpeta):
    scene = bpy.context.scene
    col = bpy.data.collections.new("COL_PREVIEW_TEMP")
    scene.collection.children.link(col)

    mn, mx = limites(partes)
    centro = (mn + mx) * 0.5

    for etiqueta, pos, ener in [("KEY", (3, 4, 4.2), 450), ("FILL", (-3, 1.5, 2.7), 250), ("RIM", (0, -3, 3.3), 400)]:
        data = bpy.data.lights.new(etiqueta, "AREA")
        data.energy = ener
        data.size = 4.0
        objl = bpy.data.objects.new(etiqueta, data)
        col.objects.link(objl)
        objl.location = pos
        orientar(objl, centro)

    camd = bpy.data.cameras.new("PREVIEW_CAMERA")
    cam = bpy.data.objects.new("PREVIEW_CAMERA", camd)
    col.objects.link(cam)
    camd.type = "ORTHO"
    camd.ortho_scale = (mx - mn).length * 1.20
    scene.camera = cam

    if scene.world is None:
        scene.world = bpy.data.worlds.new("WORLD_PREVIEW")
    scene.world.use_nodes = True
    fondo = scene.world.node_tree.nodes.get("Background")
    fondo.inputs["Color"].default_value = (0.16, 0.14, 0.12, 1)
    fondo.inputs["Strength"].default_value = 0.5

    scene.render.engine = "BLENDER_EEVEE_NEXT"
    scene.render.resolution_x = RESOLUCION
    scene.render.resolution_y = RESOLUCION
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.film_transparent = False
    scene.view_settings.view_transform = "AgX"

    fecha = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    rutas = []
    for i in range(6):
        a = math.radians(30 + i * 60)
        cam.location = centro + Vector((3.5 * math.sin(a), 3.5 * math.cos(a), 0.95))
        orientar(cam, centro)
        ruta = carpeta / f"cap_NPC_{nombre}_v2_{fecha}_{i}.png"
        scene.render.filepath = str(ruta)
        bpy.ops.render.render(write_still=True)
        rutas.append(str(ruta))

    scene.camera = None
    for o in list(col.objects):
        bpy.data.objects.remove(o, do_unlink=True)
    bpy.data.collections.remove(col)
    for g in (bpy.data.cameras, bpy.data.lights):
        for b in list(g):
            if b.users == 0:
                g.remove(b)
    return rutas


def exportar_glb(raiz, partes, ruta):
    bpy.ops.object.select_all(action="DESELECT")
    raiz.select_set(True)
    for obj in partes.values():
        obj.select_set(True)
    bpy.context.view_layer.objects.active = partes["BODY"]
    opts = {
        "filepath": str(ruta),
        "export_format": "GLB",
        "use_selection": True,
        "export_yup": True,
        "export_apply": True,
        "export_animations": False,
        "export_materials": "EXPORT",
    }
    props = {p.identifier for p in bpy.ops.export_scene.gltf.get_rna_type().properties}
    if "export_all_vertex_colors" in props:
        opts["export_all_vertex_colors"] = True
    bpy.ops.export_scene.gltf(**opts)


# ---------------- LOTE ----------------

catalogo = {
    "revision": 2,
    "islas": ["CENIZA", "CORAL", "AURORA"],
    "correctos": [],
    "errores": [],
}

lote = []
for n in NPC_CENIZA:
    lote.append(("02_CENIZA", n))
for n in NPC_CORAL:
    lote.append(("03_CORAL", n))
for n in NPC_AURORA:
    lote.append(("04_AURORA", n))

for isla, nombre in lote:
    if SOLO_NOMBRES is not None and nombre not in SOLO_NOMBRES:
        continue

    carpeta_isla = BASE / isla
    candidatos = sorted(carpeta_isla.glob(f"*/SM_NPC_{nombre}.blend"))

    if len(candidatos) != 1:
        catalogo["errores"].append({"npc": nombre, "error": "Original no encontrado o duplicado"})
        continue

    ruta_alta = candidatos[0]
    carpeta_rev = ruta_alta.parent / "REVISION_02"
    carpeta_rev.mkdir(parents=True, exist_ok=True)

    try:
        raiz, partes, col = cargar(ruta_alta, nombre)

        tris_antes = sum(triangulos(o) for o in partes.values())
        mats_antes = materiales_usados(partes)
        mn_a, mx_a = limites(partes)

        factor = decorar(nombre, partes, col)
        bpy.context.view_layer.update()

        tris_despues = sum(triangulos(o) for o in partes.values())
        mats_despues = materiales_usados(partes)

        if tris_despues > LIMITE_TRIS:
            raise RuntimeError(f"{tris_despues} tris > {LIMITE_TRIS}")

        if len(mats_despues) > 6 or mats_despues != mats_antes:
            raise RuntimeError("Presupuesto de materiales modificado")

        if len([o for o in col.objects if o.type == "MESH"]) != 8:
            raise RuntimeError("La escena debe mantener 8 meshes")

        for o in partes.values():
            if o.data.color_attributes.get("COLOR_0") is None:
                raise RuntimeError(f"COLOR_0 perdido en {o.name}")
            if (o.scale - Vector((1, 1, 1))).length > 1e-6:
                raise RuntimeError(f"Escala != 1 en {o.name}")

        mn_d, mx_d = limites(partes)
        if abs(mn_d.z) > 0.001:
            raise RuntimeError(f"Suelo incorrecto Z={mn_d.z:.4f}")

        raiz["REVISION_ARTISTICA"] = 2
        raiz["APROBACION_VISUAL"] = "PENDIENTE"

        informe = {
            "npc": nombre,
            "revision": 2,
            "isla": isla,
            "origen": str(ruta_alta),
            "detalles_anadidos": IMPLEMENTADO.get(nombre, []),
            "triangulos_antes": tris_antes,
            "triangulos_despues": tris_despues,
            "triangulos_anadidos": tris_despues - tris_antes,
            "meshes": 8,
            "objetos_con_empty": 9,
            "materiales": len(mats_despues),
            "factor_referencia": factor,
            "dimensiones_antes_m": list(mx_a - mn_a),
            "dimensiones_despues_m": list(mx_d - mn_d),
            "intersecciones": "NO_COMPROBADAS",
            "agarres": "PENDIENTES_REVISION",
            "aprobacion_visual": "PENDIENTE",
            "capturas": [],
        }

        exportar_glb(raiz, partes, carpeta_rev / f"SM_NPC_{nombre}.glb")

        if GENERAR_CAPTURAS:
            informe["capturas"] = renderizar(nombre, partes, carpeta_rev)

        for g in (bpy.data.meshes, bpy.data.materials):
            for b in list(g):
                if b.users == 0:
                    g.remove(b)

        bpy.ops.wm.save_as_mainfile(filepath=str(carpeta_rev / f"SM_NPC_{nombre}.blend"))
        guardar_json(carpeta_rev / "REVISION_02.json", informe)

        catalogo["correctos"].append({
            "npc": nombre,
            "isla": isla,
            "triangulos": tris_despues,
            "carpeta": str(carpeta_rev),
        })

    except Exception as e:
        traceback.print_exc()
        catalogo["errores"].append({
            "npc": nombre,
            "isla": isla,
            "error": str(e),
            "traceback": traceback.format_exc(),
        })

    finally:
        guardar_json(BASE / "REVISION_02_CATALOGO_RESTANTES.json", catalogo)

guardar_json(BASE / "REVISION_02_CATALOGO_RESTANTES.json", catalogo)

print("\n========== REVISION ARTISTICA RESTANTES ==========")
print(f"Completados: {len(catalogo['correctos'])}")
print(f"Errores:     {len(catalogo['errores'])}")
print(f"Informe:     {BASE / 'REVISION_02_CATALOGO_RESTANTES.json'}")
```

## 2. Resultado esperado

Tras ejecutarlo, cada NPC de Ceniza, Coral y Aurora tendrá su revisión:

```text
NPC_EXPORT/
├── 02_CENIZA/
│   ├── 13_BRASA/
│   │   ├── SM_NPC_BRASA.blend  (ALTA original)
│   │   ├── SM_NPC_BRASA.glb
│   │   └── REVISION_02/
│   │       ├── SM_NPC_BRASA.blend
│   │       ├── SM_NPC_BRASA.glb
│   │       ├── REVISION_02.json
│   │       └── cap_NPC_BRASA_v2_*.png
│   └── ...
├── 03_CORAL/
│   └── ...
└── 04_AURORA/
    └── ...
```

Se genera también el catálogo global:

```text
NPC_EXPORT/REVISION_02_CATALOGO_RESTANTES.json
```

## 3. Notas sobre esta pasada

- **Mantiene el presupuesto ALTA (≤6.000 tris)**. Si algún NPC supera el límite con los detalles añadidos, el script lanza un error y **no sobrescribe** su revisión.
- **No añade materiales nuevos.** Todos los accesorios reutilizan los 6 slots existentes (Piel, Pelo, Camisa, Pantalón, Botas, Ojos). El brillo de linternas, farol, cristal del báculo y telescopio utiliza el material `OJOS` (emisión tenue), tal como en la pasada anterior.
- **Postura anciana respetada.** Los personajes marcados (`OBSIDIANA`, `VULCANIA`, `HIELO`, `NIEVE`, `SAGE`, `NANA`) mantienen la ligera inclinación aplicada a sus accesorios.
- **Detalles añadidos cubren lo identificativo por profesión.** Se han completado elementos visibles (cinturones, frascos, linternas, collares, pulseras, cesta, mochila, constelaciones, medallas, farol...). Los bordados muy finos, costuras específicas y algunos agarres siguen quedando como **pendientes de revisión manual**.
- **Los originales permanecen intactos.** La revisión siempre parte del `.blend` ALTA base, por lo que puedes volver a regenerar `REVISION_02` para un NPC concreto sin acumular geometría duplicada.

## 4. Regenerar LODs con las revisiones

Ahora que los 35 NPCs tienen su `REVISION_02`, para obtener **MEDIA/BAJA actualizados con estos accesorios**, vuelve a ejecutar el script `generar_lods_npcs.py` modificando únicamente el bloque de búsqueda:

```python
archivos = sorted(
    CARPETA_CATALOGO.glob("*/REVISION_02/SM_NPC_*.blend")
)
```

Y cambia `CARPETA_CATALOGO` al nivel de isla si quieres procesar por lotes, o a `Path.home() / "NPC_EXPORT"` para procesar **los 35 de una vez**. Los LOD se guardarán en:

```text
NN_NOMBRE/REVISION_02/LODS/MEDIA/
NN_NOMBRE/REVISION_02/LODS/BAJA/
```

Con esto cerramos la **primera pasada completa de accesorios** para las 4 islas. El siguiente paso recomendable es revisar las capturas `v2` de Isla Raíz y aprobar o ajustar antes de afinar el resto.


