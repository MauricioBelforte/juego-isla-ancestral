# PROPUESTA A

Siguiente paso: **revisión artística de Ceniza, Coral y Aurora (NPCs 13–35)** sobre los ALTA originales, con la misma receta que Isla Raíz.

No regenero LOD aquí. Cuando apruebes estas revisiones, usa el script de LOD apuntando a `REVISION_02`.

---

# Script: `revision_artistica_resto.py`

Autónomo. Lee `NPC_EXPORT/02_CENIZA`, `03_CORAL` y `04_AURORA`.

```bash
blender --background --factory-startup --python revision_artistica_resto.py
```

Instancia dedicada: limpia la escena entre personajes.

```python
# ================================================================
# CENIZA / CORAL / AURORA — REVISION ARTISTICA 02
# Blender 4.2+
#
# Entrada:
#   NPC_EXPORT/0N_ISLA/NN_NOMBRE/SM_NPC_NOMBRE.blend
#
# Salida:
#   .../REVISION_02/  (blend, glb, json, capturas)
#
# No toca originales ni LOD previos.
# Detalles en meshes existentes. Sin materiales nuevos.
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

RAIZ_EXPORT = Path.home() / "NPC_EXPORT"

GENERAR_CAPTURAS = True
RESOLUCION = 768
LIMITE_TRIS = 6000

# None = 13-35. Ejemplo: {"BRASA", "HIELO"}
SOLO_NOMBRES = None

ISLAS = {
    "CENIZA": RAIZ_EXPORT / "02_CENIZA",
    "CORAL":  RAIZ_EXPORT / "03_CORAL",
    "AURORA": RAIZ_EXPORT / "04_AURORA",
}

NPCS = [
    # isla, slug de archivo, anciano, extras de postura
    ("CENIZA", "BRASA", False),
    ("CENIZA", "OBSIDIANA", True),
    ("CENIZA", "TUFA", False),
    ("CENIZA", "HORNO", False),
    ("CENIZA", "CENIZA", False),
    ("CENIZA", "PEDRO", False),
    ("CENIZA", "VULCANIA", False),
    ("CENIZA", "CHISPA", False),
    ("CENIZA", "CALDERA", False),
    ("CENIZA", "HUMO", False),
    ("CORAL", "OLA", False),
    ("CORAL", "PERLA", False),
    ("CORAL", "CONCHA", False),
    ("CORAL", "ALGA", True),
    ("CORAL", "TIBURON", False),
    ("CORAL", "ESTRELLA", False),
    ("CORAL", "NACAR", False),
    ("CORAL", "CORAL_ROSA", False),
    ("AURORA", "HIELO", True),
    ("AURORA", "AURORA", False),
    ("AURORA", "NIEVE", True),
    ("AURORA", "GLACIAR", False),
    ("AURORA", "ESTRELLA_FUGAZ", False),
]

COLORES = {
    "CUERO": "#825D43",
    "MADERA": "#A9825D",
    "CREMA": "#E9DDC5",
    "CREMA_OSC": "#CABEAA",
    "PLATA": "#B8BCB6",
    "HIERRO": "#899194",
    "ORO": "#BD9F59",
    "COBRE": "#AD7956",
    "ROSA": "#BC8984",
    "VERDE": "#758565",
    "HIERBA": "#93906A",
    "TIERRA": "#806449",
    "AZUL": "#728F96",
    "AZUL_PROF": "#39486F",
    "AZUL_LUZ": "#8FBAC9",
    "TERRACOTA": "#A7664E",
    "CARBON": "#465057",
    "NEGRO": "#302E2C",
    "CORAL": "#C07A6A",
    "PERLA": "#E8E2D6",
}

IMPLEMENTADO = {
    "BRASA": ["Manchas de carbon", "Linterna de cinto (refuerzo)", "Bolsillo"],
    "OBSIDIANA": ["Pergaminos en mochila", "Parches de tunica", "Frascos de cinto"],
    "TUFA": ["Frascos extra", "Pulsera de flores"],
    "HORNO": ["Manchas picantes", "Bolsillo de delantal"],
    "CENIZA": ["Mapa enrollado en cinto", "Hebilla"],
    "PEDRO": ["Planos en bolsillo", "Visera extra"],
    "VULCANIA": ["Broche", "Botones de chaleco"],
    "CHISPA": ["Monedas de cinto", "Pulseras"],
    "CALDERA": ["Silbato", "Placas de chaleco"],
    "HUMO": ["Collar de piedras", "Pulseras de cuero"],
    "OLA": ["Concha en sombrero", "Pulsera coral", "Anzuelos de cinto"],
    "PERLA": ["Collar de perlas", "Pulseras"],
    "CONCHA": ["Collar de caracoles", "Pulsera coral"],
    "ALGA": ["Pulsera de algas", "Cinturon con hebilla"],
    "TIBURON": ["Silbato", "Llaves de cinto"],
    "ESTRELLA": ["Collar de runas", "Anillo con gema"],
    "NACAR": ["Clavos en cinto", "Bolsillo de herramientas"],
    "CORAL_ROSA": ["Cinturon dorado", "Pulsera coral"],
    "HIELO": ["Runas de cinto", "Anillo", "Estrellas en tunica"],
    "AURORA": ["Medalla", "Brazaletes"],
    "NIEVE": ["Hierbas", "Frascos extra"],
    "GLACIAR": ["Herramientas de cinto", "Hebilla"],
    "ESTRELLA_FUGAZ": ["Collar de cuentas oscuras", "Anillo oscuro"],
}


# ---------------- UTILIDADES (igual que Raiz) ----------------

def guardar_json(ruta, datos):
    ruta.parent.mkdir(parents=True, exist_ok=True)
    with open(ruta, "w", encoding="utf-8") as f:
        json.dump(datos, f, ensure_ascii=False, indent=2)


def color_lineal(nombre):
    h = COLORES.get(nombre, nombre).lstrip("#")
    rgb = [int(h[i:i+2], 16) / 255 for i in (0, 2, 4)]

    def lin(v):
        return v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4

    return tuple(lin(v) for v in rgb) + (1.0,)


def limpiar():
    if bpy.context.object and bpy.context.object.mode != "OBJECT":
        bpy.ops.object.mode_set(mode="OBJECT")
    for obj in list(bpy.data.objects):
        bpy.data.objects.remove(obj, do_unlink=True)
    for col in list(bpy.data.collections):
        bpy.data.collections.remove(col)
    for grupo in (bpy.data.meshes, bpy.data.materials, bpy.data.cameras, bpy.data.lights):
        for b in list(grupo):
            if b.users == 0:
                grupo.remove(b)
    s = bpy.context.scene
    s.camera = None
    s.unit_settings.system = "METRIC"
    s.unit_settings.scale_length = 1.0


def cargar(ruta, nombre):
    limpiar()
    raiz_n = f"SM_NPC_{nombre}"
    with bpy.data.libraries.load(str(ruta), link=False) as (src, dst):
        dst.objects = [n for n in src.objects if n == raiz_n or n.startswith(raiz_n + "_")]
    col = bpy.data.collections.new("COL_NPC")
    bpy.context.scene.collection.children.link(col)
    for obj in dst.objects:
        if obj is not None:
            col.objects.link(obj)
    raiz = bpy.data.objects.get(raiz_n)
    if raiz is None or raiz.type != "EMPTY":
        raise RuntimeError("Raiz no encontrada.")
    partes = {obj.name[len(raiz_n)+1:]: obj for obj in col.objects if obj.type == "MESH"}
    esperadas = {"BODY", "HEAD", "HAIR", "EYES", "ARM_L", "ARM_R", "LEG_L", "LEG_R"}
    if set(partes) != esperadas:
        raise RuntimeError(f"Jerarquia inesperada: {sorted(partes)}")
    if any(o.parent != raiz for o in partes.values()):
        raise RuntimeError("Jerarquia no plana.")
    bpy.context.view_layer.update()
    if any(o.modifiers for o in partes.values()):
        raise RuntimeError("ALTA con modificadores sin hornear.")
    for o in partes.values():
        if o.data.color_attributes.get("COLOR_0") is None:
            raise RuntimeError(f"Falta COLOR_0 en {o.name}")
    return raiz, partes, col


def tris(obj):
    obj.data.calc_loop_triangles()
    return len(obj.data.loop_triangles)


def materiales_usados(partes):
    return {o.data.materials[p.material_index] for o in partes.values() for p in o.data.polygons}


def buscar_material(partes, familia):
    suf = "_" + familia
    cands = {m for o in partes.values() for m in o.data.materials if m and m.name.endswith(suf)}
    if len(cands) != 1:
        raise RuntimeError(f"Material {familia} ambiguo o ausente.")
    return next(iter(cands))


class Detalles:
    def __init__(self, objetivo, transformar):
        self.objetivo = objetivo
        self.transformar = transformar
        self.vertices, self.caras, self.materiales, self.colores = [], [], [], []

    def agregar(self, vertices, caras, material, tono):
        off = len(self.vertices)
        self.vertices.extend(self.transformar(Vector(v)) for v in vertices)
        self.caras.extend(tuple(off + i for i in c) for c in caras)
        self.materiales.extend([material] * len(caras))
        self.colores.extend([color_lineal(tono)] * len(caras))

    def caja(self, centro, tam, mat, tono):
        c = Vector(centro)
        x, y, z = [s / 2 for s in tam]
        v = [c + Vector(p) for p in (
            (-x,-y,-z),(x,-y,-z),(x,y,-z),(-x,y,-z),
            (-x,-y,z),(x,-y,z),(x,y,z),(-x,y,z))]
        f = [(0,3,2,1),(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)]
        self.agregar(v, f, mat, tono)

    def tubo(self, puntos, radios, mat, tono, seg=6, cerrar=True):
        puntos = [Vector(p) for p in puntos]
        verts, caras = [], []
        for i, p in enumerate(puntos):
            t = (puntos[min(i+1, len(puntos)-1)] - puntos[max(0, i-1)]).normalized()
            ref = Vector((1, 0, 0))
            if abs(ref.dot(t)) > 0.94:
                ref = Vector((0, 1, 0))
            u = (ref - t * ref.dot(t)).normalized()
            v = t.cross(u).normalized()
            for j in range(seg):
                a = 2 * math.pi * j / seg
                verts.append(p + radios[i] * (u * math.cos(a) + v * math.sin(a)))
        for i in range(len(puntos) - 1):
            for j in range(seg):
                q = (j + 1) % seg
                a, b = i * seg, (i + 1) * seg
                caras.append((a+j, a+q, b+q, b+j))
        if cerrar:
            caras.append(tuple(reversed(range(seg))))
            base = (len(puntos) - 1) * seg
            caras.append(tuple(base + j for j in range(seg)))
        self.agregar(verts, caras, mat, tono)

    def esfera(self, centro, radios, mat, tono, seg=8, lat=5):
        c = Vector(centro)
        rx, ry, rz = radios
        verts = [c + Vector((0, 0, rz))]
        caras = []
        for k in range(1, lat):
            ph = math.pi * k / lat
            for j in range(seg):
                a = 2 * math.pi * j / seg
                verts.append(c + Vector((
                    rx * math.sin(ph) * math.cos(a),
                    ry * math.sin(ph) * math.sin(a),
                    rz * math.cos(ph))))
        inf = len(verts)
        verts.append(c - Vector((0, 0, rz)))
        for j in range(seg):
            caras.append((0, 1+j, 1+(j+1) % seg))
        for k in range(lat - 2):
            a = 1 + k * seg
            b = a + seg
            for j in range(seg):
                q = (j + 1) % seg
                caras.append((a+j, b+j, b+q, a+q))
        base = 1 + (lat - 2) * seg
        for j in range(seg):
            caras.append((inf, base+(j+1) % seg, base+j))
        self.agregar(verts, caras, mat, tono)

    def mancha(self, centro, radio, mat, tono):
        c = Vector(centro)
        verts = [c]
        for j in range(9):
            a = 2 * math.pi * j / 9
            r = radio * (0.82 + 0.16 * math.sin(j * 2.4))
            verts.append(c + Vector((r * math.cos(a), 0, r * math.sin(a))))
        self.agregar(verts, [(0, 1+j, 1+(j+1) % 9) for j in range(9)], mat, tono)

    def aplicar(self, coleccion):
        if not self.caras:
            return
        me = bpy.data.meshes.new("TMP_DETALLES")
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
        temp = bpy.data.objects.new("TMP_DETALLES", me)
        coleccion.objects.link(temp)
        bpy.ops.object.select_all(action="DESELECT")
        temp.select_set(True)
        self.objetivo.select_set(True)
        bpy.context.view_layer.objects.active = self.objetivo
        bpy.ops.object.join()


# ---------------- DETALLES ----------------

def decorar(nombre, partes, coleccion, anciano):
    mat_ropa = buscar_material(partes, "CAMISA")
    mat_duro = buscar_material(partes, "BOTAS")
    head = partes["HEAD"]
    alto = max((head.matrix_world @ v.co).z for v in head.data.vertices)
    factor = alto / 1.540

    def transformar(v):
        if anciano:
            t = max(0, min(1, (v.z - 0.85) / 0.65))
            v.y += 0.040 * t * t
        return v * factor

    D = {p: Detalles(o, transformar) for p, o in partes.items()}
    body, cabeza = D["BODY"], D["HEAD"]
    pelo = D["HAIR"]
    izq, der = D["ARM_L"], D["ARM_R"]

    def bolsillo(x, z, y, col="CREMA_OSC"):
        body.caja((x, y, z), (0.070, 0.007, 0.072), mat_ropa, col)
        body.tubo([(x-0.035, y+0.005, z+0.036), (x+0.035, y+0.005, z+0.036)],
                  [0.002]*2, mat_ropa, "CREMA", 5)

    def perla(det, c, s=1.0, tono="PERLA"):
        det.esfera(c, (0.008*s, 0.007*s, 0.008*s), mat_duro, tono, 6, 4)

    def pulsera(brazo_det, sg, tono="COBRE"):
        z = 0.955
        x = sg * 0.214
        brazo_det.tubo(
            [(x, 0.080, z), (sg*0.218, 0.095, z-0.01), (sg*0.210, 0.110, z-0.02)],
            [0.006]*3, mat_duro, tono, 6, False)

    def silbato():
        body.caja((0, 0.138, 1.183), (0.017, 0.020, 0.035), mat_duro, "PLATA")
        body.caja((0, 0.150, 1.194), (0.010, 0.008, 0.007), mat_duro, "CARBON")

    def anillo(brazo, sg, tono="ORO"):
        c = Vector((sg * 0.210, 0.129, 0.900)) + Vector((-sg * 0.026, 0.017, 0.012))
        brazo.tubo(
            [c + Vector((0.010*math.cos(a), 0.010*math.sin(a), 0))
             for a in [i*0.785 for i in range(9)]],
            [0.002]*9, mat_duro, tono, 5, False)

    if nombre == "BRASA":
        for c, r in [((0.06, 0.12, 1.05), 0.018), ((-0.07, 0.10, 0.98), 0.014),
                     ((0.02, 0.13, 0.88), 0.012)]:
            body.mancha(c, r, mat_ropa, "CARBON")
        bolsillo(0.070, 0.800, 0.175, "CARBON")

    elif nombre == "OBSIDIANA":
        body.caja((0.04, -0.20, 1.08), (0.04, 0.02, 0.12), mat_duro, "CREMA")
        body.caja((-0.04, -0.20, 1.05), (0.035, 0.018, 0.10), mat_duro, "CREMA_OSC")
        body.caja((0.11, 0.08, 0.92), (0.04, 0.03, 0.06), mat_ropa, "CARBON")
        body.caja((-0.10, 0.09, 0.90), (0.035, 0.025, 0.05), mat_ropa, "TIERRA")
        for x in (-0.08, 0.08):
            body.esfera((x, 0.14, 0.90), (0.016, 0.018, 0.028), mat_ropa, "VERDE", 8, 5)

    elif nombre == "TUFA":
        for x in (-0.12, -0.06, 0.06, 0.12):
            body.esfera((x, 0.14, 0.90), (0.015, 0.017, 0.026), mat_ropa, "VERDE", 8, 5)
        pulsera(izq, -1, "ROSA")
        izq.esfera((-0.22, 0.10, 0.96), (0.008, 0.006, 0.010), mat_ropa, "HIERBA", 6, 4)

    elif nombre == "HORNO":
        bolsillo(-0.03, 0.73, 0.164, "TERRACOTA")
        for c, r, t in [((0.06, 0.17, 0.68), 0.016, "TERRACOTA"),
                        ((-0.05, 0.15, 0.84), 0.012, "TIERRA")]:
            body.mancha(c, r, mat_ropa, t)

    elif nombre == "CENIZA":
        body.tubo([(0.14, 0.08, 0.93), (0.16, 0.10, 0.93)], [0.018]*2, mat_ropa, "CREMA", 8)
        body.caja((0.00, 0.14, 0.93), (0.04, 0.012, 0.03), mat_duro, "HIERRO")

    elif nombre == "PEDRO":
        body.caja((0.075, 0.175, 0.80), (0.08, 0.01, 0.06), mat_ropa, "CREMA")
        pelo.caja((0, 0.14, 1.49), (0.16, 0.04, 0.012), mat_duro, "HIERRO")

    elif nombre == "VULCANIA":
        body.esfera((0, 0.125, 1.214), (0.015, 0.006, 0.018), mat_duro, "PLATA", 10, 6)
        for z in (1.13, 1.08, 1.03):
            body.esfera((0.035, 0.129, z), (0.005, 0.004, 0.005), mat_duro, "PLATA", 6, 4)

    elif nombre == "CHISPA":
        for x in (-0.06, -0.02, 0.02, 0.06):
            body.esfera((x, 0.14, 0.92), (0.008, 0.004, 0.008), mat_duro, "ORO", 6, 4)
        pulsera(der, 1, "ORO")
        pulsera(izq, -1, "COBRE")

    elif nombre == "CALDERA":
        silbato()
        for sg in (-1, 1):
            body.caja((sg*0.09, 0.12, 1.05), (0.06, 0.02, 0.08), mat_duro, "HIERRO")

    elif nombre == "HUMO":
        for i, tono in enumerate(["CARBON", "TERRACOTA", "NEGRO"]):
            body.esfera((0.02*i - 0.02, 0.13, 1.19 - i*0.012),
                        (0.010, 0.008, 0.010), mat_duro, tono, 6, 4)
        pulsera(der, 1, "CUERO")
        pulsera(izq, -1, "CUERO")

    elif nombre == "OLA":
        pelo.esfera((0.12, 0.08, 1.53), (0.018, 0.012, 0.016), mat_duro, "CREMA", 8, 5)
        pulsera(izq, -1, "CORAL")
        for x in (-0.05, 0, 0.05):
            body.tubo([(x, 0.14, 0.94), (x, 0.14, 0.91), (x+0.008, 0.14, 0.905)],
                      [0.002]*3, mat_duro, "PLATA", 5)

    elif nombre == "PERLA":
        for i in range(5):
            a = -0.5 + i * 0.25
            perla(body, (0.05*math.sin(a), 0.12+0.02*math.cos(a), 1.20 - 0.02*i), 1.0)
        pulsera(der, 1, "ORO")
        pulsera(izq, -1, "ORO")

    elif nombre == "CONCHA":
        for x, z in [(-0.03, 1.20), (0, 1.185), (0.03, 1.20)]:
            body.esfera((x, 0.13, z), (0.012, 0.008, 0.014), mat_duro, "CREMA", 8, 5)
        pulsera(izq, -1, "CORAL")

    elif nombre == "ALGA":
        pulsera(izq, -1, "HIERBA")
        body.caja((0, 0.14, 0.93), (0.04, 0.012, 0.028), mat_duro, "CUERO")

    elif nombre == "TIBURON":
        silbato()
        body.tubo([(0.12, 0.10, 0.92), (0.12, 0.10, 0.86)], [0.003]*2, mat_duro, "HIERRO", 5)
        body.esfera((0.12, 0.10, 0.85), (0.008, 0.006, 0.012), mat_duro, "ORO", 6, 4)

    elif nombre == "ESTRELLA":
        for i in range(4):
            body.caja((0.03*math.sin(i), 0.13, 1.20 - i*0.015),
                      (0.012, 0.006, 0.016), mat_duro, "ORO")
        anillo(der, 1, "ORO")
        der.esfera((0.185, 0.145, 0.915), (0.006, 0.006, 0.007), mat_ropa, "AZUL_LUZ", 6, 4)

    elif nombre == "NACAR":
        for x in (-0.04, 0, 0.04):
            body.tubo([(x, 0.16, 0.94), (x, 0.16, 0.90)], [0.003]*2, mat_duro, "HIERRO", 5)
        bolsillo(0.07, 0.80, 0.175, "CUERO")

    elif nombre == "CORAL_ROSA":
        body.caja((0, 0.12, 0.94), (0.18, 0.03, 0.025), mat_duro, "ORO")
        pulsera(izq, -1, "CORAL")

    elif nombre == "HIELO":
        for i, z in enumerate((0.94, 0.93, 0.92)):
            body.caja((0.04*i - 0.04, 0.14, z), (0.014, 0.008, 0.018), mat_duro, "ORO")
        anillo(der, 1, "ORO")
        for x, z in [(-0.05, 1.14), (0.04, 1.08), (0.00, 1.00)]:
            body.esfera((x, 0.12, z), (0.006, 0.004, 0.006), mat_duro, "ORO", 6, 4)

    elif nombre == "AURORA":
        body.esfera((0, 0.13, 1.20), (0.018, 0.008, 0.022), mat_duro, "ORO", 8, 5)
        pulsera(der, 1, "ORO")
        pulsera(izq, -1, "ORO")

    elif nombre == "NIEVE":
        for i in range(3):
            x = (i - 1) * 0.008
            body.tubo([(0, 0.135, 1.196), (x, 0.138, 1.157)], [0.0015]*2, mat_duro, "MADERA", 5)
            body.esfera((x, 0.140, 1.163), (0.007, 0.003, 0.015), mat_ropa, "HIERBA", 6, 4)
        for x in (-0.10, 0.10):
            body.esfera((x, 0.14, 0.90), (0.015, 0.017, 0.026), mat_ropa, "VERDE", 8, 5)

    elif nombre == "GLACIAR":
        body.tubo([(0.14, 0.16, 0.94), (0.14, 0.16, 0.86)], [0.005]*2, mat_duro, "HIERRO", 6)
        body.caja((0, 0.14, 0.93), (0.04, 0.012, 0.028), mat_duro, "HIERRO")

    elif nombre == "ESTRELLA_FUGAZ":
        for i in range(5):
            body.esfera((0.02*math.sin(i), 0.12, 1.20 - i*0.012),
                        (0.007, 0.006, 0.007), mat_duro, "NEGRO", 6, 4)
        anillo(der, 1, "NEGRO")

    else:
        raise ValueError(nombre)

    for d in D.values():
        d.aplicar(coleccion)
    return factor


def limites(partes):
    pts = [o.matrix_world @ v.co for o in partes.values() for v in o.data.vertices]
    mn = Vector(tuple(min(p[i] for p in pts) for i in range(3)))
    mx = Vector(tuple(max(p[i] for p in pts) for i in range(3)))
    return mn, mx


def orientar(obj, objetivo):
    obj.rotation_euler = (Vector(objetivo) - obj.location).to_track_quat("-Z", "Y").to_euler()


def renderizar(nombre, partes, carpeta):
    scene = bpy.context.scene
    col = bpy.data.collections.new("COL_PREVIEW_TEMP")
    scene.collection.children.link(col)
    mn, mx = limites(partes)
    centro = (mn + mx) * 0.5
    for et, pos, en in [("KEY", (3, 4, 4.2), 450), ("FILL", (-3, 1.5, 2.7), 250), ("RIM", (0, -3, 3.3), 400)]:
        data = bpy.data.lights.new(et, "AREA")
        data.energy = en
        data.size = 4
        o = bpy.data.objects.new(et, data)
        col.objects.link(o)
        o.location = pos
        orientar(o, centro)
    data = bpy.data.cameras.new("PREVIEW_CAMERA")
    cam = bpy.data.objects.new("PREVIEW_CAMERA", data)
    col.objects.link(cam)
    data.type = "ORTHO"
    data.ortho_scale = (mx - mn).length * 1.2
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
    scene.render.image_settings.file_format = "PNG"
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
    return rutas


def exportar(raiz, partes, ruta):
    bpy.ops.object.select_all(action="DESELECT")
    raiz.select_set(True)
    for o in partes.values():
        o.select_set(True)
    bpy.context.view_layer.objects.active = partes["BODY"]
    op = dict(filepath=str(ruta), export_format="GLB", use_selection=True,
              export_yup=True, export_apply=True, export_animations=False,
              export_materials="EXPORT")
    props = {p.identifier for p in bpy.ops.export_scene.gltf.get_rna_type().properties}
    if "export_all_vertex_colors" in props:
        op["export_all_vertex_colors"] = True
    bpy.ops.export_scene.gltf(**op)


# ---------------- LOTE ----------------

catalogo = {"revision": 2, "islas": ["CENIZA", "CORAL", "AURORA"],
            "estado": "PENDIENTE_APROBACION_VISUAL", "correctos": [], "errores": []}
informe_global = RAIZ_EXPORT / "REVISION_02_RESTO_CATALOGO.json"

for isla, nombre, anciano in NPCS:
    if SOLO_NOMBRES is not None and nombre not in SOLO_NOMBRES:
        continue
    base = ISLAS[isla]
    cands = sorted(base.glob(f"*/SM_NPC_{nombre}.blend"))
    # Solo originales: carpeta inmediata NN_NOMBRE, no REVISION ni LODS
    cands = [p for p in cands if "REVISION" not in p.parts and "LODS" not in p.parts]
    if len(cands) != 1:
        catalogo["errores"].append({"npc": nombre, "error": f"originales={len(cands)}"})
        continue
    ruta = cands[0]
    carpeta = ruta.parent / "REVISION_02"
    carpeta.mkdir(parents=True, exist_ok=True)
    try:
        raiz, partes, col = cargar(ruta, nombre)
        t0 = sum(tris(o) for o in partes.values())
        mats0 = materiales_usados(partes)
        mn0, mx0 = limites(partes)
        factor = decorar(nombre, partes, col, anciano)
        bpy.context.view_layer.update()
        t1 = sum(tris(o) for o in partes.values())
        mats1 = materiales_usados(partes)
        if t1 > LIMITE_TRIS:
            raise RuntimeError(f"{t1} tris > {LIMITE_TRIS}")
        if mats1 != mats0 or len(mats1) > 6:
            raise RuntimeError("Materiales alterados.")
        if len([o for o in col.objects if o.type == "MESH"]) != 8:
            raise RuntimeError("Ya no hay 8 meshes.")
        for o in partes.values():
            if o.data.color_attributes.get("COLOR_0") is None:
                raise RuntimeError(f"COLOR_0 perdido {o.name}")
            if (o.scale - Vector((1, 1, 1))).length > 1e-6:
                raise RuntimeError("Escala no 1")
        mn, mx = limites(partes)
        if abs(mn.z) > 0.001:
            raise RuntimeError(f"Suelo {mn.z}")
        raiz["REVISION_ARTISTICA"] = 2
        raiz["APROBACION_VISUAL"] = "PENDIENTE"
        inf = {
            "npc": nombre, "isla": isla, "revision": 2, "origen": str(ruta),
            "detalles_anadidos": IMPLEMENTADO[nombre],
            "triangulos_antes": t0, "triangulos_despues": t1,
            "meshes": 8, "materiales": len(mats1), "factor_referencia": factor,
            "dimensiones_despues_m": list(mx - mn),
            "intersecciones": "NO_COMPROBADAS",
            "aprobacion_visual": "PENDIENTE", "capturas": [],
        }
        exportar(raiz, partes, carpeta / f"SM_NPC_{nombre}.glb")
        if GENERAR_CAPTURAS:
            inf["capturas"] = renderizar(nombre, partes, carpeta)
        bpy.ops.wm.save_as_mainfile(filepath=str(carpeta / f"SM_NPC_{nombre}.blend"))
        guardar_json(carpeta / "REVISION_02.json", inf)
        catalogo["correctos"].append({"npc": nombre, "isla": isla, "tris": t1, "carpeta": str(carpeta)})
    except Exception as e:
        traceback.print_exc()
        err = {"npc": nombre, "error": str(e), "traceback": traceback.format_exc()}
        catalogo["errores"].append(err)
        guardar_json(carpeta / "ERROR_REVISION_02.json", err)
    finally:
        guardar_json(informe_global, catalogo)

print("\n========== REVISION RESTO ==========")
print(f'OK: {len(catalogo["correctos"])}  ERR: {len(catalogo["errores"])}')
print(informe_global)
```

---

## LOD de las revisiones (cuando apruebes)

En `generar_lods_npcs.py`:

```python
CARPETA_CATALOGO = Path.home() / "NPC_EXPORT"
archivos = sorted(CARPETA_CATALOGO.glob("*/**/REVISION_02/SM_NPC_*.blend"))
archivos = [p for p in archivos if "LODS" not in p.parts]
```

Así los LOD salen en `REVISION_02/LODS/` y no mezclan con ALTA v1.

## Pendiente real

| Hecho (scripts) | No hecho |
|---|---|
| ALTA procedural 35 | Aprobación visual |
| LOD MEDIA/BAJA | Importación Godot 4.7.2 |
| Revisión Raíz + resto | Rayas de Fin, bordados, agarres |
| 6 capturas por revisión | Rig / animación |
| Tope 6k tris por NPC | Soldadura topológica |

Si un NPC supera 6.000 tris, **no se exporta ni se recorta la cara**. El error queda en `ERROR_REVISION_02.json`.