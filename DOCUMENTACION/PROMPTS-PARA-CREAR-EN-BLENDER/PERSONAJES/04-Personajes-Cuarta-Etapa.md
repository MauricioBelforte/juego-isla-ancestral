Seguimos con la **segunda pasada artística de Isla Raíz: accesorios y detalles de profesión para sus 12 NPCs**.

Esta vez no añadimos más personajes ni hacemos otra reducción automática. Trabajamos sobre los **ALTA originales**, completando detalles visibles y guardando una revisión separada.

**No puedo ejecutar Blender ni revisar tus capturas desde aquí.** El script siguiente añade geometría y genera nuevas vistas para aprobación; no certifica que todos los accesorios estén libres de intersecciones.

## Qué añade esta revisión

| NPC | Detalles añadidos |
|---|---|
| **Luna** | Pequeñas manchas adicionales en la paleta y remates del bolsillo |
| **Rocky** | Cinta métrica de cinturón y lápiz detrás de la oreja |
| **Coral** | Colgante de concha y bolsillo frontal del salvavidas |
| **Chef** | Bolsillo del delantal, costuras y manchas de comida |
| **Fin** | Cubo pequeño en la mano izquierda y anzuelos decorativos romos |
| **Flora** | Cesta de semillas en la cadera, semillas y manchas de tierra en el mandil |
| **Sage** | Broche plateado y botones del chaleco |
| **Merc** | Collar de conchas y pendientes pequeños |
| **Nana** | Ramito de hierbas secas y bolsillo del mandil |
| **Carp** | Cinta métrica y herramientas pequeñas en el bolsillo |
| **Melodía** | Decoración del cencerro y remates dorados del chaleco |
| **Roca** | Silbato y refuerzos frontales de las botas |

Los detalles se incorporan a los meshes existentes, manteniendo **8 meshes + Empty** y sin crear materiales nuevos.

> Esta pasada no completa todavía todos los detalles del documento: por ejemplo, las rayas de Fin, las costuras específicas de cada prenda y la revisión de agarres siguen pendientes.

---

# Script: `revision_artistica_raiz.py`

Es **autónomo**. Lee los `.blend` ALTA generados anteriormente.

### Ejecución

```bash
blender --background --factory-startup --python revision_artistica_raiz.py
```

**Usa una instancia dedicada:** el script limpia la sesión entre personajes.

```python
# ================================================================
# ISLA RAIZ — REVISION ARTISTICA 02
# Blender 4.2+
#
# Entrada:
# NPC_EXPORT/01_RAIZ/NN_NOMBRE/SM_NPC_NOMBRE.blend
#
# Salida:
# NPC_EXPORT/01_RAIZ/NN_NOMBRE/REVISION_02/
#   SM_NPC_NOMBRE.blend
#   SM_NPC_NOMBRE.glb
#   REVISION_02.json
#   6 capturas opcionales
#
# Conserva los originales.
# Los detalles se incorporan a meshes existentes.
# No crea nuevos materiales.
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

BASE = Path.home() / "NPC_EXPORT" / "01_RAIZ"

GENERAR_CAPTURAS = True
RESOLUCION = 768

# None = los 12.
# Ejemplo: {"ROCKY", "FIN", "FLORA"}
SOLO_NOMBRES = None

LIMITE_TRIS = 6000

NPCS = [
    "LUNA", "ROCKY", "CORAL", "CHEF",
    "FIN", "FLORA", "SAGE", "MERC",
    "NANA", "CARP", "MELODIA", "ROCA",
]

COLORES = {
    "CUERO": "#825D43",
    "MADERA": "#A9825D",
    "CREMA": "#E9DDC5",
    "CREMA_OSC": "#CABEAA",
    "PLATA": "#B8BCB6",
    "HIERRO": "#899194",
    "ORO": "#BD9F59",
    "ROSA": "#BC8984",
    "VERDE": "#758565",
    "HIERBA": "#93906A",
    "TIERRA": "#806449",
    "AZUL": "#728F96",
    "TERRACOTA": "#A7664E",
    "CARBON": "#465057",
    "NEGRO": "#302E2C",
}

IMPLEMENTADO = {
    "LUNA": ["Remates de bolsillo", "Pintura adicional en paleta"],
    "ROCKY": ["Cinta metrica", "Lapiz"],
    "CORAL": ["Colgante concha", "Bolsillo salvavidas"],
    "CHEF": ["Bolsillo delantal", "Manchas de comida"],
    "FIN": ["Cubo con asa", "Anzuelos decorativos romos"],
    "FLORA": ["Cesta de semillas", "Semillas", "Tierra en mandil"],
    "SAGE": ["Broche plateado", "Botones"],
    "MERC": ["Conchas del collar", "Pendientes"],
    "NANA": ["Hierbas secas", "Bolsillo mandil"],
    "CARP": ["Cinta metrica", "Herramientas de bolsillo"],
    "MELODIA": ["Decoracion de cencerro", "Remates de chaleco"],
    "ROCA": ["Silbato", "Refuerzos de botas"],
}


# ---------------- UTILIDADES ----------------

def guardar_json(ruta, datos):
    ruta.parent.mkdir(parents=True, exist_ok=True)
    with open(ruta, "w", encoding="utf-8") as f:
        json.dump(datos, f, ensure_ascii=False, indent=2)


def color_lineal(nombre):
    hexadecimal = COLORES.get(nombre, nombre).lstrip("#")
    rgb = [int(hexadecimal[i:i+2], 16) / 255 for i in (0, 2, 4)]

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
        raise RuntimeError("No se encontro la raiz esperada.")

    partes = {
        obj.name[len(raiz_nombre)+1:]: obj
        for obj in col.objects
        if obj.type == "MESH"
    }

    esperadas = {
        "BODY", "HEAD", "HAIR", "EYES",
        "ARM_L", "ARM_R", "LEG_L", "LEG_R"
    }

    if set(partes) != esperadas:
        raise RuntimeError(
            f"Jerarquia inesperada: {sorted(partes)}"
        )

    if any(obj.parent != raiz for obj in partes.values()):
        raise RuntimeError("Se esperaba jerarquia plana bajo el Empty.")

    bpy.context.view_layer.update()

    if any(obj.modifiers for obj in partes.values()):
        raise RuntimeError(
            "Esta revision espera los ALTA con modificadores horneados."
        )

    for obj in partes.values():
        if obj.data.color_attributes.get("COLOR_0") is None:
            raise RuntimeError(f"Falta COLOR_0 en {obj.name}")

    return raiz, partes, col


def tris(obj):
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
        if mat and mat.name.endswith(sufijo)
    }

    if len(candidatos) != 1:
        raise RuntimeError(
            f"No se pudo identificar el material {familia}."
        )

    return next(iter(candidatos))


# ---------------- ACUMULADOR DE DETALLES ----------------

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
        self.caras.extend(
            tuple(offset + i for i in cara) for cara in caras
        )
        self.materiales.extend([material] * len(caras))
        self.colores.extend([color_lineal(tono)] * len(caras))

    def caja(self, centro, tamano, material, tono):
        c = Vector(centro)
        x, y, z = [s / 2 for s in tamano]

        vertices = [
            c + Vector(p) for p in (
                (-x,-y,-z), (x,-y,-z), (x,y,-z), (-x,y,-z),
                (-x,-y,z), (x,-y,z), (x,y,z), (-x,y,z)
            )
        ]

        caras = [
            (0,3,2,1), (4,5,6,7),
            (0,1,5,4), (1,2,6,5),
            (2,3,7,6), (3,0,4,7)
        ]
        self.agregar(vertices, caras, material, tono)

    def tubo(self, puntos, radios, material, tono,
             segmentos=6, cerrar=True):
        puntos = [Vector(p) for p in puntos]
        vertices = []
        caras = []

        for i, p in enumerate(puntos):
            tangente = (
                puntos[min(i+1, len(puntos)-1)]
                - puntos[max(0, i-1)]
            ).normalized()

            ref = Vector((1,0,0))
            if abs(ref.dot(tangente)) > 0.94:
                ref = Vector((0,1,0))

            u = (ref - tangente * ref.dot(tangente)).normalized()
            v = tangente.cross(u).normalized()

            for j in range(segmentos):
                a = 2 * math.pi * j / segmentos
                vertices.append(
                    p + radios[i] * (
                        u * math.cos(a) + v * math.sin(a)
                    )
                )

        for i in range(len(puntos)-1):
            for j in range(segmentos):
                q = (j+1) % segmentos
                a = i * segmentos
                b = a + segmentos
                caras.append((a+j, a+q, b+q, b+j))

        if cerrar:
            caras.append(tuple(reversed(range(segmentos))))
            base = (len(puntos)-1) * segmentos
            caras.append(tuple(base+j for j in range(segmentos)))

        self.agregar(vertices, caras, material, tono)

    def esfera(self, centro, radios, material, tono,
               segmentos=8, latitudes=5):
        c = Vector(centro)
        rx, ry, rz = radios
        vertices = [c + Vector((0,0,rz))]
        caras = []

        for k in range(1, latitudes):
            ph = math.pi * k / latitudes
            for j in range(segmentos):
                a = 2 * math.pi * j / segmentos
                vertices.append(c + Vector((
                    rx * math.sin(ph) * math.cos(a),
                    ry * math.sin(ph) * math.sin(a),
                    rz * math.cos(ph)
                )))

        inferior = len(vertices)
        vertices.append(c - Vector((0,0,rz)))

        for j in range(segmentos):
            caras.append((0, 1+j, 1+(j+1) % segmentos))

        for k in range(latitudes-2):
            a = 1 + k * segmentos
            b = a + segmentos
            for j in range(segmentos):
                q = (j+1) % segmentos
                caras.append((a+j, b+j, b+q, a+q))

        base = 1 + (latitudes-2) * segmentos
        for j in range(segmentos):
            caras.append((
                inferior, base+(j+1) % segmentos, base+j
            ))

        self.agregar(vertices, caras, material, tono)

    def mancha(self, centro, radio, material, tono):
        c = Vector(centro)
        vertices = [c]
        for j in range(9):
            a = 2 * math.pi * j / 9
            r = radio * (0.82 + 0.16 * math.sin(j * 2.4))
            vertices.append(c + Vector((
                r * math.cos(a), 0, r * math.sin(a)
            )))

        caras = [
            (0, 1+j, 1+(j+1) % 9) for j in range(9)
        ]
        self.agregar(vertices, caras, material, tono)

    def recipiente(self, centro, rx, ry, alto, material, tono):
        """
        Recipiente abierto con pared y fondo.
        Sin tapa falsa en la boca.
        """
        c = Vector(centro)
        n = 12
        grosor = 0.004

        specs = [
            (rx*0.80, ry*0.80, 0),
            (rx, ry, alto),
            (rx-grosor, ry-grosor, alto),
            (rx*0.80-grosor, ry*0.80-grosor, grosor),
        ]

        vertices = []
        for ax, ay, z in specs:
            for j in range(n):
                a = 2 * math.pi * j / n
                vertices.append(c + Vector((
                    ax*math.cos(a), ay*math.sin(a), z
                )))

        caras = []
        for k in range(3):
            for j in range(n):
                q = (j+1) % n
                caras.append((
                    k*n+j, k*n+q, (k+1)*n+q, (k+1)*n+j
                ))

        caras.append(tuple(reversed(range(n))))
        caras.append(tuple(3*n+j for j in range(n)))
        self.agregar(vertices, caras, material, tono)

    def aplicar(self, coleccion):
        if not self.caras:
            return

        nombre_temp = "TMP_DETALLES"
        me = bpy.data.meshes.new(nombre_temp)

        # Los vertices estan en coordenadas mundiales.
        me.from_pydata(self.vertices, [], self.caras)
        me.update()

        usados = list(dict.fromkeys(self.materiales))
        indices = {mat: i for i, mat in enumerate(usados)}

        for mat in usados:
            me.materials.append(mat)

        atributo = me.color_attributes.new(
            name="COLOR_0", type="FLOAT_COLOR", domain="CORNER"
        )
        me.color_attributes.active_color = atributo
        me.color_attributes.render_color_index = 0

        for p, mat, rgba in zip(
            me.polygons, self.materiales, self.colores
        ):
            p.material_index = indices[mat]
            p.use_smooth = True
            for li in p.loop_indices:
                atributo.data[li].color = rgba

        bm = bmesh.new()
        bm.from_mesh(me)
        bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
        bm.to_mesh(me)
        bm.free()

        temp = bpy.data.objects.new(nombre_temp, me)
        coleccion.objects.link(temp)

        bpy.ops.object.select_all(action="DESELECT")
        temp.select_set(True)
        self.objetivo.select_set(True)
        bpy.context.view_layer.objects.active = self.objetivo

        # Join conserva el origen del objeto activo.
        bpy.ops.object.join()


# ---------------- DETALLES POR PERSONAJE ----------------

def decorar(nombre, partes, coleccion):
    mat_ropa = buscar_material(partes, "CAMISA")
    mat_duro = buscar_material(partes, "BOTAS")
    mat_pelo = buscar_material(partes, "PELO")

    # Cabeza base del generador:
    # centro Z=1.385 + radio Z=0.155 = 1.540.
    head = partes["HEAD"]
    alto_cabeza = max(
        (head.matrix_world @ v.co).z for v in head.data.vertices
    )
    factor = alto_cabeza / 1.540

    anciano = nombre in {"SAGE", "NANA"}

    def transformar(v):
        if anciano:
            t = max(0, min(1, (v.z-0.85)/0.65))
            v.y += 0.040*t*t
        return v * factor

    D = {
        parte: Detalles(obj, transformar)
        for parte, obj in partes.items()
    }

    body = D["BODY"]
    cabeza = D["HEAD"]

    def bolsillo(x, z, y, col="CREMA_OSC"):
        body.caja(
            (x,y,z), (0.072,0.007,0.074), mat_ropa, col
        )
        body.tubo(
            [(x-0.036,y+0.005,z+0.037),
             (x+0.036,y+0.005,z+0.037)],
            [0.002]*2, mat_ropa, "CREMA", 5
        )

    def cinta_metrica():
        body.esfera(
            (-0.143,0.068,0.918),
            (0.028,0.017,0.028),
            mat_duro,"CUERO",10,6
        )
        body.caja(
            (-0.143,0.087,0.889),
            (0.017,0.005,0.049),mat_duro,"CREMA"
        )
        for z in (0.872,0.884,0.896):
            body.caja(
                (-0.143,0.090,z),
                (0.010,0.002,0.002),mat_duro,"CARBON"
            )

    def concha(det, centro, escala=1.0):
        c = Vector(centro)
        det.esfera(
            c, (0.014*escala,0.005*escala,0.017*escala),
            mat_duro,"CREMA",8,5
        )
        for dx in (-0.007,0,0.007):
            det.tubo(
                [c+Vector((0,0.005,-0.012))*escala,
                 c+Vector((dx,0.006,0.010))*escala],
                [0.0013*escala]*2,mat_duro,"ROSA",5
            )

    if nombre == "LUNA":
        body.tubo(
            [(0.002,0.160,0.747),(0.068,0.160,0.747)],
            [0.0015]*2,mat_ropa,"CREMA",5
        )
        mano = Vector((-0.210,0.129,0.900))
        for dx,dy,tono in [
            (-0.050,0.020,"ROSA"),
            (0.034,0.040,"VERDE")
        ]:
            D["ARM_L"].esfera(
                mano+Vector((dx,0.060+dy,-0.003)),
                (0.007,0.007,0.002),
                mat_ropa,tono,6,4
            )

    elif nombre == "ROCKY":
        cinta_metrica()
        cabeza.tubo(
            [(0.116,-0.014,1.376),(0.119,-0.013,1.472)],
            [0.0035,0.0035],mat_duro,"MADERA",6
        )
        cabeza.tubo(
            [(0.119,-0.013,1.472),(0.119,-0.013,1.483)],
            [0.0035,0.0008],mat_duro,"CARBON",6
        )

    elif nombre == "CORAL":
        concha(body,(0,0.136,1.183),1.1)
        body.caja(
            (0.085,0.132,1.047),
            (0.061,0.007,0.057),mat_ropa,"TERRACOTA"
        )
        body.tubo(
            [(0.055,0.137,1.075),(0.115,0.137,1.075)],
            [0.002]*2,mat_ropa,"CREMA",5
        )

    elif nombre == "CHEF":
        bolsillo(-0.032,0.727,0.164,"TERRACOTA")
        for centro,radio,tono in [
            ((0.065,0.168,0.690),0.015,"TIERRA"),
            ((-0.053,0.151,0.838),0.011,"VERDE"),
            ((0.055,0.174,0.593),0.017,"TERRACOTA"),
        ]:
            body.mancha(centro,radio,mat_ropa,tono)

    elif nombre == "FIN":
        brazo = D["ARM_L"]
        c = Vector((-0.210,0.169,0.711))

        brazo.recipiente(
            c,0.058,0.048,0.100,mat_duro,"HIERRO"
        )

        puntos = [
            c+Vector((
                0.058*math.cos(math.pi*i/8),
                0,
                0.100+0.080*math.sin(math.pi*i/8)
            ))
            for i in range(9)
        ]
        brazo.tubo(
            puntos,[0.0035]*9,mat_duro,"HIERRO",6
        )

        # Anzuelos pequenos, sin punta afilada.
        for x in (-0.036,0,0.036):
            body.tubo(
                [(x,0.135,1.187),
                 (x,0.135,1.166),
                 (x+0.006,0.135,1.160),
                 (x+0.011,0.135,1.167)],
                [0.0017]*4,mat_duro,"PLATA",5
            )

    elif nombre == "FLORA":
        c = Vector((-0.180,0.010,0.790))
        body.recipiente(
            c,0.055,0.045,0.075,mat_duro,"MADERA"
        )

        body.tubo(
            [(-0.155,0.030,0.938),
             (-0.181,0.020,0.882),
             (-0.180,0.010,0.865)],
            [0.007]*3,mat_duro,"CUERO",6
        )

        for dx,dy in [
            (-0.024,0), (0.020,0.012),
            (0,-0.018), (0.005,0.025)
        ]:
            body.esfera(
                c+Vector((dx,dy,0.054)),
                (0.009,0.006,0.005),
                mat_ropa,"CREMA",6,4
            )

        body.mancha(
            (0.064,0.171,0.630),0.016,mat_ropa,"TIERRA"
        )
        body.mancha(
            (-0.071,0.162,0.742),0.012,mat_ropa,"TIERRA"
        )

    elif nombre == "SAGE":
        body.esfera(
            (0,0.125,1.214),(0.015,0.006,0.018),
            mat_duro,"PLATA",10,6
        )
        for z in (1.128,1.078,1.028):
            body.esfera(
                (0.035,0.129,z),(0.005,0.004,0.005),
                mat_duro,"PLATA",6,4
            )

    elif nombre == "MERC":
        for x,z in [
            (-0.034,1.205),(-0.017,1.193),
            (0.017,1.193),(0.034,1.205)
        ]:
            concha(body,(x,0.128,z),0.65)

        for sg in (-1,1):
            cabeza.esfera(
                (sg*0.118,0.003,1.356),
                (0.006,0.004,0.008),
                mat_duro,"ORO",8,5
            )

    elif nombre == "NANA":
        for i in range(3):
            x=(i-1)*0.008
            body.tubo(
                [(0,0.135,1.196),(x,0.138,1.157)],
                [0.0015]*2,mat_duro,"MADERA",5
            )
            body.esfera(
                (x,0.140,1.163),
                (0.007,0.003,0.015),
                mat_ropa,"HIERBA",6,4
            )
        bolsillo(0.036,0.728,0.165,"VERDE")

    elif nombre == "CARP":
        cinta_metrica()
        for x,z,tono in [
            (0.046,0.865,"MADERA"),
            (0.067,0.875,"HIERRO")
        ]:
            body.tubo(
                [(x,0.182,0.790),(x,0.182,z)],
                [0.004]*2,mat_duro,tono,6
            )

    elif nombre == "MELODIA":
        brazo = D["ARM_R"]
        c = Vector((0.210,0.165,0.875))

        for x in (-0.023,0,0.023):
            brazo.esfera(
                c+Vector((x,0.035,-0.014)),
                (0.0035,0.0025,0.0035),
                mat_duro,"ROSA",6,4
            )

        for sg in (-1,1):
            body.tubo(
                [(sg*0.039,0.128,1.176),
                 (sg*0.030,0.132,1.105)],
                [0.002]*2,mat_duro,"ORO",5
            )

    elif nombre == "ROCA":
        body.caja(
            (0,0.138,1.183),
            (0.017,0.020,0.035),mat_duro,"PLATA"
        )
        body.caja(
            (0,0.150,1.194),
            (0.010,0.008,0.007),mat_duro,"CARBON"
        )

        for sg,parte in [(-1,"LEG_L"),(1,"LEG_R")]:
            x = sg*0.079*1.12
            D[parte].caja(
                (x,0.062,0.137),
                (0.070,0.009,0.079),mat_duro,"HIERRO"
            )

    for det in D.values():
        det.aplicar(coleccion)

    return factor


# ---------------- CAPTURAS ----------------

def limites(partes):
    puntos = [
        obj.matrix_world @ v.co
        for obj in partes.values()
        for v in obj.data.vertices
    ]
    minimo = Vector(tuple(min(p[i] for p in puntos) for i in range(3)))
    maximo = Vector(tuple(max(p[i] for p in puntos) for i in range(3)))
    return minimo,maximo


def orientar(obj,objetivo):
    obj.rotation_euler = (
        Vector(objetivo)-obj.location
    ).to_track_quat("-Z","Y").to_euler()


def renderizar(nombre,partes,carpeta):
    scene=bpy.context.scene
    col=bpy.data.collections.new("COL_PREVIEW_TEMP")
    scene.collection.children.link(col)

    minimo,maximo=limites(partes)
    centro=(minimo+maximo)*0.5

    for etiqueta,posicion,energia in [
        ("KEY",(3,4,4.2),450),
        ("FILL",(-3,1.5,2.7),250),
        ("RIM",(0,-3,3.3),400)
    ]:
        data=bpy.data.lights.new(etiqueta,"AREA")
        data.energy=energia
        data.size=4
        obj=bpy.data.objects.new(etiqueta,data)
        col.objects.link(obj)
        obj.location=posicion
        orientar(obj,centro)

    data=bpy.data.cameras.new("PREVIEW_CAMERA")
    cam=bpy.data.objects.new("PREVIEW_CAMERA",data)
    col.objects.link(cam)
    data.type="ORTHO"
    data.ortho_scale=(maximo-minimo).length*1.2
    scene.camera=cam

    if scene.world is None:
        scene.world=bpy.data.worlds.new("WORLD_PREVIEW")

    scene.world.use_nodes=True
    fondo=scene.world.node_tree.nodes.get("Background")
    fondo.inputs["Color"].default_value=(0.16,0.14,0.12,1)
    fondo.inputs["Strength"].default_value=0.5

    scene.render.engine="BLENDER_EEVEE_NEXT"
    scene.render.resolution_x=RESOLUCION
    scene.render.resolution_y=RESOLUCION
    scene.render.resolution_percentage=100
    scene.render.image_settings.file_format="PNG"
    scene.render.film_transparent=False
    scene.view_settings.view_transform="AgX"

    fecha=datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    rutas=[]

    for i in range(6):
        a=math.radians(30+i*60)
        cam.location=centro+Vector((
            3.5*math.sin(a),3.5*math.cos(a),0.95
        ))
        orientar(cam,centro)

        ruta=carpeta/f"cap_NPC_{nombre}_v2_{fecha}_{i}.png"
        scene.render.filepath=str(ruta)
        bpy.ops.render.render(write_still=True)
        rutas.append(str(ruta))

    scene.camera=None
    for obj in list(col.objects):
        bpy.data.objects.remove(obj,do_unlink=True)
    bpy.data.collections.remove(col)

    for grupo in (bpy.data.cameras,bpy.data.lights):
        for bloque in list(grupo):
            if bloque.users==0:
                grupo.remove(bloque)

    return rutas


# ---------------- EXPORTACION ----------------

def exportar(raiz,partes,ruta):
    bpy.ops.object.select_all(action="DESELECT")
    raiz.select_set(True)

    for obj in partes.values():
        obj.select_set(True)

    bpy.context.view_layer.objects.active=partes["BODY"]

    opciones={
        "filepath":str(ruta),
        "export_format":"GLB",
        "use_selection":True,
        "export_yup":True,
        "export_apply":True,
        "export_animations":False,
        "export_materials":"EXPORT",
    }

    propiedades={
        p.identifier
        for p in bpy.ops.export_scene.gltf.get_rna_type().properties
    }
    if "export_all_vertex_colors" in propiedades:
        opciones["export_all_vertex_colors"]=True

    bpy.ops.export_scene.gltf(**opciones)


# ---------------- LOTE ----------------

BASE.mkdir(parents=True,exist_ok=True)

catalogo={
    "revision":2,
    "estado":"PENDIENTE_APROBACION_VISUAL",
    "correctos":[],
    "errores":[],
}

for nombre in NPCS:
    if SOLO_NOMBRES is not None and nombre not in SOLO_NOMBRES:
        continue

    # Solo originales en carpetas inmediatas NN_NOMBRE.
    # No se buscan revisiones ni LOD recursivamente.
    candidatos=sorted(BASE.glob(f"*/SM_NPC_{nombre}.blend"))

    if len(candidatos)!=1:
        catalogo["errores"].append({
            "npc":nombre,
            "error":f"Se esperaba un original; encontrados: {len(candidatos)}"
        })
        continue

    ruta=candidatos[0]
    carpeta=ruta.parent/"REVISION_02"
    carpeta.mkdir(parents=True,exist_ok=True)

    try:
        raiz,partes,col=cargar(ruta,nombre)

        tris_antes=sum(tris(obj) for obj in partes.values())
        mats_antes=materiales_usados(partes)
        minimo_antes,maximo_antes=limites(partes)

        factor=decorar(nombre,partes,col)
        bpy.context.view_layer.update()

        tris_despues=sum(tris(obj) for obj in partes.values())
        mats_despues=materiales_usados(partes)

        if tris_despues>LIMITE_TRIS:
            raise RuntimeError(
                f"Revision fuera de presupuesto: "
                f"{tris_despues} > {LIMITE_TRIS}. "
                "No se exporta ni se reduce automaticamente."
            )

        if mats_despues!=mats_antes or len(mats_despues)>6:
            raise RuntimeError("La revision altero el presupuesto de materiales.")

        if len([o for o in col.objects if o.type=="MESH"])!=8:
            raise RuntimeError("La escena ya no tiene ocho meshes.")

        for obj in partes.values():
            if obj.data.color_attributes.get("COLOR_0") is None:
                raise RuntimeError(f"COLOR_0 perdido en {obj.name}")
            if (obj.scale-Vector((1,1,1))).length>1e-6:
                raise RuntimeError(f"Escala inesperada en {obj.name}")

        minimo,maximo=limites(partes)
        if abs(minimo.z)>0.001:
            raise RuntimeError(f"Contacto con suelo incorrecto: {minimo.z}")

        raiz["REVISION_ARTISTICA"]=2
        raiz["APROBACION_VISUAL"]="PENDIENTE"

        informe={
            "npc":nombre,
            "revision":2,
            "origen":str(ruta),
            "detalles_anadidos":IMPLEMENTADO[nombre],
            "triangulos_antes":tris_antes,
            "triangulos_despues":tris_despues,
            "triangulos_anadidos":tris_despues-tris_antes,
            "meshes":8,
            "objetos_con_empty":9,
            "materiales":len(mats_despues),
            "factor_referencia":factor,
            "dimensiones_antes_m":list(maximo_antes-minimo_antes),
            "dimensiones_despues_m":list(maximo-minimo),
            "intersecciones":"NO_COMPROBADAS",
            "agarres":"PENDIENTES_REVISION",
            "aprobacion_visual":"PENDIENTE",
            "capturas":[],
        }

        exportar(
            raiz,partes,carpeta/f"SM_NPC_{nombre}.glb"
        )

        if GENERAR_CAPTURAS:
            informe["capturas"]=renderizar(nombre,partes,carpeta)

        for grupo in (bpy.data.meshes,bpy.data.materials):
            for bloque in list(grupo):
                if bloque.users==0:
                    grupo.remove(bloque)

        bpy.ops.wm.save_as_mainfile(
            filepath=str(carpeta/f"SM_NPC_{nombre}.blend")
        )
        guardar_json(carpeta/"REVISION_02.json",informe)

        catalogo["correctos"].append({
            "npc":nombre,
            "triangulos":tris_despues,
            "carpeta":str(carpeta),
        })

    except Exception as error:
        traceback.print_exc()
        datos={
            "npc":nombre,
            "error":str(error),
            "traceback":traceback.format_exc(),
        }
        catalogo["errores"].append(datos)
        guardar_json(carpeta/"ERROR_REVISION_02.json",datos)

    finally:
        guardar_json(BASE/"REVISION_02_CATALOGO.json",catalogo)

guardar_json(BASE/"REVISION_02_CATALOGO.json",catalogo)

print("\n========== REVISION ARTISTICA RAIZ ==========")
print(f'Completados: {len(catalogo["correctos"])}')
print(f'Errores: {len(catalogo["errores"])}')
print(f'Informe: {BASE/"REVISION_02_CATALOGO.json"}')
```

---

## Cómo queda cada personaje

```text
02_ROCKY/
├── SM_NPC_ROCKY.blend          ← original, intacto
├── SM_NPC_ROCKY.glb
├── LODS/                      ← LOD de la versión anterior
└── REVISION_02/
    ├── SM_NPC_ROCKY.blend
    ├── SM_NPC_ROCKY.glb
    ├── REVISION_02.json
    └── cap_NPC_ROCKY_v2_...png
```

La reejecución parte siempre del **original**, por lo que no acumula lápices, bolsillos o accesorios duplicados. Los archivos de revisión se reemplazan y las capturas fechadas permanecen como historial.

## Importante: actualización de los LOD

Los LOD generados anteriormente **no incluyen estos accesorios nuevos**.

Además, el buscador recursivo del script de LOD anterior encontraría tanto originales como revisiones. Para procesar **solo esta revisión**, cambia su configuración a:

```python
CARPETA_CATALOGO = Path.home() / "NPC_EXPORT" / "01_RAIZ"
```

Y sustituye su bloque de búsqueda de archivos por:

```python
archivos = sorted(
    CARPETA_CATALOGO.glob(
        "*/REVISION_02/SM_NPC_*.blend"
    )
)
```

Así los nuevos LOD se guardarán dentro de cada `REVISION_02/LODS/`, sin mezclar versiones.

## Revisión visual recomendada

Antes de regenerar los LOD, revisa especialmente:

1. **Rocky:** que el lápiz no atraviese de forma visible la oreja.
2. **Fin:** que la mano alcance el asa del cubo y que este no choque con la pierna.
3. **Flora:** que la cesta no quede demasiado embebida en la cadera.
4. **Sage y Nana:** que los accesorios sigan correctamente la postura encorvada.
5. **Roca:** que las placas de las botas no floten delante del calzado.

**Si un NPC supera 6.000 tris, esta pasada se detiene para ese personaje:** no degrada automáticamente el rostro ni las herramientas para hacer sitio. El informe identifica el caso y conserva intacto su ALTA original.

