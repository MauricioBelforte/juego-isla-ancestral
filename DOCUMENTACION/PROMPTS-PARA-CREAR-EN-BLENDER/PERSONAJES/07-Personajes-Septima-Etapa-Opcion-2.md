Continuamos con el **rigging: esqueleto, pesos automáticos y poses de validación para los 35 NPCs**.

Es el paso para el que se diseñaron los pivotes (cuello, hombros, caderas) desde la primera versión de Luna. El script construye un esqueleto humanoide por NPC a partir de las posiciones reales de los meshes, asigna pesos por posición geométrica, genera **8 capturas de validación** (4 poses × 2 ángulos) y exporta el GLB con esqueleto.

**Límites claros de esta pasada:** los pesos son automáticos y por posición, no pintados a mano; las faldas y capas quedan rígidas al hueso Hips; y las herramientas largas (bastón, lanza, caña, báculo) se doblarán con el brazo porque siguen fusionadas al mesh. Todo ello queda registrado en el informe. No he ejecutado nada: las capturas hay que revisarlas en tu equipo.

## Decisiones técnicas

| Decisión | Motivo |
|---|---|
| 20 huesos con nombres del perfil humanoide de Godot (`Hips`, `Spine`, `Chest`, `Neck`, `Head`, `LeftUpperArm`…) | Facilita el retargeting futuro y las animaciones compartidas |
| Articulaciones leídas de los orígenes de objeto + bandas de centroides | Funciona con las tres alturas (1,7/1,8/1,9), el ensanchamiento de guardias y la inclinación de ancianos sin constantes frágiles |
| Pesos por distancia a segmento de hueso, con doble peso (0,5/0,5) cerca de las fronteras | Evita grietas en codos, rodillas y cintura sin pintado manual |
| Poses aplicadas rotando matrices en espacio de mundo | Evita la ambigüedad de roll en huesos verticales: los signos son deterministas |
| Cascos y sombreros van en el mesh HAIR → hueso Head | El sombrero acompaña a la cabeza, que es lo correcto |

## Script: `riggear_npcs.py`

```bash
blender --background --factory-startup --python riggear_npcs.py
```

Limpia la sesión entre personajes; usa una instancia dedicada.

```python
# ================================================================
# RIG PROCEDURAL DE NPCS — ESQUELETO + PESOS + POSES DE VALIDACION
# Blender 4.2+
#
# Entrada (segun USAR_REVISION_02):
#   NPC_EXPORT/<ISLA>/NN_NOMBRE/SM_NPC_NOMBRE.blend
#   NPC_EXPORT/<ISLA>/NN_NOMBRE/REVISION_02/SM_NPC_NOMBRE.blend
#
# Salida:
#   .../NN_NOMBRE/RIG/
#       SM_NPC_NOMBRE.blend     (esqueleto + pesos)
#       SM_NPC_NOMBRE.glb
#       RIG.json
#       8 capturas: 4 poses x 2 angulos
#
# Limitaciones conocidas y registradas en RIG.json:
#   - Pesos automaticos por posicion, no pintados a mano.
#   - Faldas y capas fijas al hueso Hips.
#   - Herramientas fusionadas al brazo: se doblan con el.
# ================================================================

import bpy
import math
import json
import traceback

from pathlib import Path
from datetime import datetime
from mathutils import Vector, Matrix


# ---------------- CONFIGURACION ----------------

BASE = Path.home() / "NPC_EXPORT"

# False = originales ALTA. True = revisiones con accesorios.
# Usa True solo con revisiones ya inspeccionadas.
USAR_REVISION_02 = False

GENERAR_CAPTURAS = True
RESOLUCION = 768

# None = todos. Ejemplo: {"LUNA", "FIN", "ROCA", "HIELO"}
SOLO_NOMBRES = None

DETENER_EN_ERROR = False

EJE_X = Vector((1, 0, 0))
EJE_Z = Vector((0, 0, 1))

# Poses de validacion: rotacion en espacio de MUNDO alrededor
# de la cabeza del hueso. Signos: +X adelanta el miembro.
POSES = [
    ("REPOSO", []),
    ("BRAZOS", [
        ("LeftUpperArm", EJE_X, 65), ("RightUpperArm", EJE_X, 65),
        ("LeftLowerArm", EJE_X, 35), ("RightLowerArm", EJE_X, 35),
    ]),
    ("SENTADO", [
        ("LeftUpperLeg", EJE_X, 65), ("RightUpperLeg", EJE_X, 65),
        ("LeftLowerLeg", EJE_X, -75), ("RightLowerLeg", EJE_X, -75),
        ("LeftUpperArm", EJE_X, 55), ("RightUpperArm", EJE_X, 55),
        ("LeftLowerArm", EJE_X, 45), ("RightLowerArm", EJE_X, 45),
    ]),
    ("CABEZA", [
        ("Head", EJE_Z, 32), ("Neck", EJE_Z, 12),
    ]),
]

ANGULOS_CAMARA = [30, 100]


# ---------------- UTILIDADES ----------------

def guardar_json(ruta, datos):
    ruta.parent.mkdir(parents=True, exist_ok=True)
    with open(ruta, "w", encoding="utf-8") as f:
        json.dump(datos, f, ensure_ascii=False, indent=2)


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
        obj.name[len(raiz_nombre) + 1:]: obj
        for obj in col.objects
        if obj.type == "MESH"
    }

    esperadas = {
        "BODY", "HEAD", "HAIR", "EYES",
        "ARM_L", "ARM_R", "LEG_L", "LEG_R"
    }
    if set(partes) != esperadas:
        raise RuntimeError(f"Jerarquia inesperada: {sorted(partes)}")

    if any(obj.parent != raiz for obj in partes.values()):
        raise RuntimeError("Se esperaba jerarquia plana bajo el Empty.")

    bpy.context.view_layer.update()

    if any(obj.modifiers for obj in partes.values()):
        raise RuntimeError("Se esperaban meshes sin modificadores.")

    return raiz, partes, col


def mundo(obj):
    return [obj.matrix_world @ v.co for v in obj.data.vertices]


def promedio(puntos):
    if not puntos:
        return None
    c = Vector((0, 0, 0))
    for p in puntos:
        c += p
    return c / len(puntos)


def distancia_segmento(p, a, b):
    ab = b - a
    if ab.length_squared < 1e-12:
        return (p - a).length, 0.0
    t = max(0.0, min(1.0, (p - a).dot(ab) / ab.length_squared))
    q = a + ab * t
    return (p - q).length, t


def limites(partes):
    puntos = [p for obj in partes.values() for p in mundo(obj)]
    mn = Vector(tuple(min(p[i] for p in puntos) for i in range(3)))
    mx = Vector(tuple(max(p[i] for p in puntos) for i in range(3)))
    return mn, mx


def triangulos(obj):
    obj.data.calc_loop_triangles()
    return len(obj.data.loop_triangles)


# ---------------- ARTICULACIONES ----------------

def articulaciones(partes):
    loc = lambda o: o.matrix_world.translation.copy()

    cuello = loc(partes["HEAD"])
    f = cuello.z / 1.29  # factor horneado real del NPC

    cadL, cadR = loc(partes["LEG_L"]), loc(partes["LEG_R"])
    cadera = (cadL + cadR) * 0.5

    verts_cabeza = mundo(partes["HEAD"])
    top = max(v.z for v in verts_cabeza)
    punta_cabeza = promedio(
        [v for v in verts_cabeza if v.z > top - 0.03]
    )

    J = {"cadera": cadera, "cuello": cuello, "f": f,
         "cabeza": punta_cabeza}

    # Brazos: codo y muneca por bandas de centroides,
    # ignorando vertices lejanos al eje (herramientas).
    for lado in ("L", "R"):
        h = loc(partes["ARM_" + lado])
        verts = mundo(partes["ARM_" + lado])
        fondo = h.z - 0.34 * f
        a, b = h.copy(), Vector((h.x, h.y, fondo))

        def cerca(p, a=a, b=b):
            return distancia_segmento(p, a, b)[0] < 0.10 * f

        ze = h.z + (fondo - h.z) * 0.456
        zw = h.z + (fondo - h.z) * 0.847

        ce = promedio(
            [p for p in verts
             if abs(p.z - ze) < 0.05 * f and cerca(p)]
        ) or Vector((h.x, h.y + 0.02 * f, ze))
        cw = promedio(
            [p for p in verts
             if abs(p.z - zw) < 0.05 * f and cerca(p)]
        ) or Vector((h.x, h.y + 0.04 * f, zw))

        J[lado] = {
            "hombro": h,
            "codo": Vector((ce.x, ce.y, ze)),
            "muneca": Vector((cw.x, cw.y, zw)),
            "punta": Vector((cw.x, cw.y, zw)) + Vector((0, 0.03 * f, -0.05 * f)),
        }

    # Piernas: rodilla y tobillo por bandas.
    for lado in ("L", "R"):
        c = cadL if lado == "L" else cadR
        verts = mundo(partes["LEG_" + lado])
        zr = c.z * 0.56
        zt = c.z * 0.18

        cr = promedio([p for p in verts if abs(p.z - zr) < 0.05 * f])
        ct = promedio([p for p in verts if abs(p.z - zt) < 0.04 * f])

        rodilla = cr or Vector((c.x, c.y, zr))
        tobillo = ct or Vector((c.x, c.y, zt))

        J[lado].update({
            "cadera_lado": c,
            "rodilla": Vector((rodilla.x, rodilla.y, zr)),
            "tobillo": Vector((tobillo.x, tobillo.y, zt)),
            "pie": Vector((tobillo.x, tobillo.y + 0.085 * f, 0.02)),
        })

    return J


# ---------------- ESQUELETO ----------------

def crear_esqueleto(partes, J, col, nombre):
    datos = bpy.data.armatures.new("RIG_" + nombre)
    arm = bpy.data.objects.new("RIG_" + nombre, datos)
    col.objects.link(arm)

    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode="EDIT")
    eb = datos.edit_bones

    cadera, cuello, cabeza = J["cadera"], J["cuello"], J["cabeza"]
    f = J["f"]

    s1 = cadera.lerp(cuello, 0.33)
    s2 = cadera.lerp(cuello, 0.66)
    nuca = cuello.lerp(cabeza, 0.25)

    def hueso(n, head, tail, padre=None):
        b = eb.new(n)
        b.head = head
        b.tail = tail
        b.use_connect = False
        if padre:
            b.parent = eb[padre]
        return b

    hueso("Root", Vector((0, 0, 0)), cadera.copy())
    hueso("Hips", cadera.copy(), s1, "Root")
    hueso("Spine", s1, s2, "Hips")
    hueso("Chest", s2, cuello.copy(), "Spine")
    hueso("Neck", cuello.copy(), nuca, "Chest")
    hueso("Head", nuca, cabeza, "Neck")

    for lado, prefijo in (("L", "Left"), ("R", "Right")):
        j = J[lado]

        clav = Vector((
            j["hombro"].x * 0.25,
            cadera.y + 0.75 * (cuello.y - cadera.y),
            cadera.z + 0.70 * (cuello.z - cadera.z),
        ))
        hueso(prefijo + "Shoulder", clav, j["hombro"], "Chest")
        hueso(prefijo + "UpperArm", j["hombro"], j["codo"], prefijo + "Shoulder")
        hueso(prefijo + "LowerArm", j["codo"], j["muneca"], prefijo + "UpperArm")
        hueso(prefijo + "Hand", j["muneca"], j["punta"], prefijo + "LowerArm")

        hueso(prefijo + "UpperLeg", j["cadera_lado"], j["rodilla"], "Hips")
        hueso(prefijo + "LowerLeg", j["rodilla"], j["tobillo"], prefijo + "UpperLeg")
        hueso(prefijo + "Foot", j["tobillo"], j["pie"], prefijo + "LowerLeg")

    # Roll determinista donde la API este disponible.
    for b in eb:
        if any(k in b.name for k in ("Arm", "Leg", "Foot", "Hand")):
            try:
                b.align_roll(EJE_X)
            except Exception:
                pass

    bpy.ops.object.mode_set(mode="OBJECT")
    return arm


# ---------------- ASIGNACION DE PESOS ----------------

def pesos_por_segmentos(obj, segs, umbral_doble):
    """
    segs: [(nombre_hueso, punto_a, punto_b), ...]
    Asigna cada vertice al segmento mas cercano.
    Doble peso 0.5/0.5 si el segundo esta a menos de umbral_doble.
    Devuelve: {hueso: (indices_1.0, indices_0.5)}, distancia_min_por_vertice.
    """
    resultado = {n: ([], []) for n, _, _ in segs}
    dist_min = []

    for i, v in enumerate(obj.data.vertices):
        p = obj.matrix_world @ v.co
        dists = sorted(
            (distancia_segmento(p, a, b)[0], n)
            for n, a, b in segs
        )
        d1, n1 = dists[0]
        dist_min.append(d1)

        if len(dists) > 1 and dists[1][0] < d1 + umbral_doble:
            resultado[n1][1].append(i)
            resultado[dists[1][1]][1].append(i)
        else:
            resultado[n1][0].append(i)

    return resultado, dist_min


def pesos_por_bandas(obj, fronteras, umbral):
    """
    fronteras: [(z, hueso_arriba, hueso_abajo), ...] ordenadas.
    Doble peso cerca de cada frontera.
    """
    resultado = {}
    for _, ha, hb in fronteras:
        resultado.setdefault(ha, ([], []))
        resultado.setdefault(hb, ([], []))

    def banda(z):
        for k, (zf, _, _) in enumerate(fronteras):
            if z >= zf:
                return fronteras[k]
        return fronteras[-1]

    for i, v in enumerate(obj.data.vertices):
        z = (obj.matrix_world @ v.co).z

        cerca = None
        for zf, ha, hb in fronteras:
            if abs(z - zf) < umbral:
                cerca = (ha, hb)
                break

        if cerca:
            resultado[cerca[0]][1].append(i)
            resultado[cerca[1]][1].append(i)
        else:
            _, ha, _ = banda(z)
            resultado.setdefault(ha, ([], []))[0].append(i)

    return resultado


def aplicar_grupos(obj, distribucion):
    for hueso_n, (completos, medios) in distribucion.items():
        if not completos and not medios:
            continue
        vg = obj.vertex_groups.new(name=hueso_n)
        if completos:
            vg.add(completos, 1.0, "REPLACE")
        if medios:
            vg.add(medios, 0.5, "ADD")


def emparentar(obj, arm):
    mw = obj.matrix_world.copy()
    obj.parent = arm
    obj.matrix_parent_inverse = arm.matrix_world.inverted() @ mw
    mod = obj.modifiers.new("RIG_ARMATURE", "ARMATURE")
    mod.object = arm


def skinning(partes, arm, J):
    f = J["f"]
    informe = {}

    # Torso: bandas por altura.
    cadera, cuello = J["cadera"], J["cuello"]
    s1, s2 = cadera.z + 0.33 * (cuello.z - cadera.z), cadera.z + 0.66 * (cuello.z - cadera.z)
    dist = pesos_por_bandas(
        partes["BODY"],
        [(cuello.z - 0.03, "Neck", "Chest"),
         (s2, "Chest", "Spine"),
         (s1, "Spine", "Hips")],
        0.025 * f,
    )
    aplicar_grupos(partes["BODY"], dist)
    informe["BODY"] = {k: len(v[0]) + len(v[1]) for k, v in dist.items()}

    # Cabeza, pelo/sombreros y ojos: hueso Head.
    for nombre in ("HEAD", "HAIR", "EYES"):
        obj = partes[nombre]
        vg = obj.vertex_groups.new(name="Head")
        vg.add(list(range(len(obj.data.vertices))), 1.0, "REPLACE")
        informe[nombre] = {"Head": len(obj.data.vertices)}

    avisos = []

    # Brazos y piernas: distancia a segmentos.
    for lado, prefijo in (("L", "Left"), ("R", "Right")):
        j = J[lado]

        segs_brazo = [
            (prefijo + "UpperArm", j["hombro"], j["codo"]),
            (prefijo + "LowerArm", j["codo"], j["muneca"]),
            (prefijo + "Hand", j["muneca"], j["punta"]),
        ]
        dist, dmin = pesos_por_segmentos(partes["ARM_" + lado], segs_brazo, 0.02 * f)
        aplicar_grupos(partes["ARM_" + lado], dist)
        informe["ARM_" + lado] = {k: len(v[0]) + len(v[1]) for k, v in dist.items()}

        lejos = sum(1 for d in dmin if d > 0.10 * f)
        if lejos:
            avisos.append(
                f"ARM_{lado}: {lejos} vertices lejos del eje del brazo "
                "(herramienta): se deformaran con el hueso mas cercano."
            )

        segs_pierna = [
            (prefijo + "UpperLeg", j["cadera_lado"], j["rodilla"]),
            (prefijo + "LowerLeg", j["rodilla"], j["tobillo"]),
            (prefijo + "Foot", j["tobillo"], j["pie"]),
        ]
        dist, _ = pesos_por_segmentos(partes["LEG_" + lado], segs_pierna, 0.02 * f)
        aplicar_grupos(partes["LEG_" + lado], dist)
        informe["LEG_" + lado] = {k: len(v[0]) + len(v[1]) for k, v in dist.items()}

    falda = sum(
        1 for p in mundo(partes["BODY"]) if p.z < s1
    )
    if falda > 50:
        avisos.append(
            f"BODY: {falda} vertices bajos (falda/capa) fijos a Hips: "
            "las piernas deslizarian por debajo al caminar."
        )

    return informe, avisos


# ---------------- POSES Y CAPTURAS ----------------

def guardar_resto(arm):
    return {pb.name: pb.matrix.copy() for pb in arm.pose.bones}


def aplicar_pose(arm, ajustes):
    for nombre, eje, grados in ajustes:
        pb = arm.pose.bones.get(nombre)
        if pb is None:
            continue
        m = pb.matrix.copy()
        piv = m.translation.copy()
        R = Matrix.Rotation(math.radians(grados), 4, eje)
        pb.matrix = Matrix.Translation(piv) @ R @ Matrix.Translation(-piv) @ m


def restaurar(arm, resto):
    for nombre, m in resto.items():
        arm.pose.bones[nombre].matrix = m


def orientar(obj, objetivo):
    obj.rotation_euler = (
        Vector(objetivo) - obj.location
    ).to_track_quat("-Z", "Y").to_euler()


def validar_poses(arm, partes, carpeta, nombre):
    scene = bpy.context.scene
    col = bpy.data.collections.new("COL_PREVIEW_TEMP")
    scene.collection.children.link(col)

    mn, mx = limites(partes)
    centro = (mn + mx) * 0.5

    for etiqueta, pos, ener in [
        ("KEY", (3, 4, 4.2), 450),
        ("FILL", (-3, 1.5, 2.7), 250),
        ("RIM", (0, -3, 3.3), 400),
    ]:
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
    camd.ortho_scale = (mx - mn).length * 1.25
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
    scene.view_settings.view_transform = "AgX"

    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode="POSE")
    resto = guardar_resto(arm)

    fecha = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    rutas = []

    for etiqueta, ajustes in POSES:
        restaurar(arm, resto)
        aplicar_pose(arm, ajustes)
        bpy.context.view_layer.update()

        for k, ang in enumerate(ANGULOS_CAMARA):
            a = math.radians(ang)
            cam.location = centro + Vector((
                3.5 * math.sin(a), 3.5 * math.cos(a), 0.95
            ))
            orientar(cam, centro)

            ruta = carpeta / f"cap_NPC_{nombre}_rig_{etiqueta}_{fecha}_{k}.png"
            scene.render.filepath = str(ruta)
            bpy.ops.render.render(write_still=True)
            rutas.append({"pose": etiqueta, "angulo": ang, "archivo": str(ruta)})

    restaurar(arm, resto)
    bpy.ops.object.mode_set(mode="OBJECT")

    scene.camera = None
    for o in list(col.objects):
        bpy.data.objects.remove(o, do_unlink=True)
    bpy.data.collections.remove(col)
    for g in (bpy.data.cameras, bpy.data.lights):
        for b in list(g):
            if b.users == 0:
                g.remove(b)

    return rutas


# ---------------- EXPORTACION ----------------

def exportar_glb(raiz, arm, partes, ruta):
    bpy.ops.object.select_all(action="DESELECT")
    raiz.select_set(True)
    arm.select_set(True)
    for obj in partes.values():
        obj.select_set(True)
    bpy.context.view_layer.objects.active = arm

    opciones = {
        "filepath": str(ruta),
        "export_format": "GLB",
        "use_selection": True,
        "export_yup": True,
        "export_apply": True,
        "export_animations": False,
        "export_materials": "EXPORT",
    }
    props = {
        p.identifier
        for p in bpy.ops.export_scene.gltf.get_rna_type().properties
    }
    if "export_all_vertex_colors" in props:
        opciones["export_all_vertex_colors"] = True

    bpy.ops.export_scene.gltf(**opciones)


# ---------------- CATALOGO ----------------

if USAR_REVISION_02:
    archivos = sorted(BASE.glob("*/*/REVISION_02/SM_NPC_*.blend"))
else:
    archivos = [
        p for p in sorted(BASE.glob("*/*/SM_NPC_*.blend"))
        if not any(x in p.parts for x in ("LODS", "REVISION_02", "RIG"))
    ]

if SOLO_NOMBRES is not None:
    archivos = [
        p for p in archivos
        if p.stem.removeprefix("SM_NPC_") in SOLO_NOMBRES
    ]

if not archivos:
    raise RuntimeError(f"No se encontraron NPCs en {BASE}.")

catalogo = {
    "fuente": "REVISION_02" if USAR_REVISION_02 else "ALTA",
    "huesos": 20,
    "correctos": [],
    "errores": [],
}

for ruta in archivos:
    nombre = ruta.stem.removeprefix("SM_NPC_")
    print(f"\n===== RIG: {nombre} =====")

    carpeta = ruta.parent / "RIG"
    carpeta.mkdir(parents=True, exist_ok=True)

    try:
        raiz, partes, col = cargar(ruta, nombre)
        J = articulaciones(partes)
        arm = crear_esqueleto(partes, J, col, nombre)

        for obj in partes.values():
            emparentar(obj, arm)

        distribucion, avisos = skinning(partes, arm, J)
        bpy.context.view_layer.update()

        # Comprobaciones: todo vertice con grupo, grupos = huesos.
        huesos = {b.name for b in arm.data.bones}
        for obj in partes.values():
            sin_grupo = [
                v.index for v in obj.data.vertices
                if not any(g.index in [
                    vg.index for vg in obj.vertex_groups
                ] for g in [])
            ]
            # Comprobacion directa:
            asignados = set()
            for vg in obj.vertex_groups:
                asignados.add(vg.name)
            if not asignados.issubset(huesos):
                raise RuntimeError(
                    f"{obj.name}: grupos que no son huesos: "
                    f"{asignados - huesos}"
                )
            for v in obj.data.vertices:
                if not any(
                    vg.weight(v.index) > 0
                    for vg in obj.vertex_groups
                ):
                    raise RuntimeError(
                        f"{obj.name}: vertice {v.index} sin pesos."
                    )

        tris_total = sum(triangulos(o) for o in partes.values())

        raiz["RIG"] = "PROCEDURAL_V1"
        raiz["APROBACION_RIG"] = "PENDIENTE"

        informe = {
            "npc": nombre,
            "origen": str(ruta),
            "huesos": [
                {
                    "nombre": b.name,
                    "padre": b.parent.name if b.parent else None,
                    "cabeza": list(b.head_local),
                    "cola": list(b.tail_local),
                }
                for b in arm.data.bones
            ],
            "triangulos": tris_total,
            "distribucion_pesos": distribucion,
            "avisos": avisos,
            "limitaciones": [
                "Pesos automaticos por posicion: revisar y pintar "
                "a mano para primeros planos.",
                "Faldas y capas fijas a Hips.",
                "Herramientas fusionadas al brazo.",
                "Sin animaciones: solo esqueleto y pieles.",
            ],
            "aprobacion_poses": "PENDIENTE",
            "capturas": [],
        }

        exportar_glb(raiz, arm, partes, carpeta / f"SM_NPC_{nombre}.glb")

        if GENERAR_CAPTURAS:
            informe["capturas"] = validar_poses(
                arm, partes, carpeta, nombre
            )

        for g in (bpy.data.meshes, bpy.data.materials):
            for b in list(g):
                if b.users == 0:
                    g.remove(b)

        bpy.ops.wm.save_as_mainfile(
            filepath=str(carpeta / f"SM_NPC_{nombre}.blend")
        )
        guardar_json(carpeta / "RIG.json", informe)

        catalogo["correctos"].append({
            "npc": nombre,
            "huesos": len(arm.data.bones),
            "triangulos": tris_total,
            "avisos": len(avisos),
            "carpeta": str(carpeta),
        })

    except Exception as e:
        traceback.print_exc()
        catalogo["errores"].append({
            "npc": nombre,
            "error": str(e),
            "traceback": traceback.format_exc(),
        })
        if DETENER_EN_ERROR:
            raise

    finally:
        guardar_json(BASE / "RIG_CATALOGO.json", catalogo)

print("\n========== RIG PROCEDURAL ==========")
print(f"Completados: {len(catalogo['correctos'])}")
print(f"Errores:     {len(catalogo['errores'])}")
```

## Resultado por NPC

```text
NN_NOMBRE/
├── SM_NPC_NOMBRE.blend        ← original intacto
├── RIG/
│   ├── SM_NPC_NOMBRE.blend    ← esqueleto + pieles
│   ├── SM_NPC_NOMBRE.glb
│   ├── RIG.json
│   └── cap_NPC_NOMBRE_rig_{REPOSO|BRAZOS|SENTADO|CABEZA}_<fecha>_{0|1}.png
```

Las 8 capturas por personaje evalúan: reposo (referencia), brazos al frente (pesos de hombro/codo/muñeca y comportamiento de herramientas), sentado (cadera/rodilla/tobillo y falda), giro de cabeza (cuello, pelo y sombreros).

## Qué revisar en las capturas

| Prueba | Fallo típico que detecta |
|---|---|
| REPOSO vs original | Vértices desplazados: articulaciones mal leídas |
| BRAZOS, vista lateral | Herramientas doblándose en el codo; mangas cortadas |
| SENTADO | Muslos que no siguen; botas que se estiran; falda atravesada por piernas |
| CABEZA | Sombreros que se quedan quietos; barba/pendientes en hueso equivocado |
| Todas | Pinchazos o grietas en fronteras de doble peso |

Empieza por **Luna, Roca, Obsidiana, Perla y Estrella Fugaz**: cubren falda, guardia ancho, anciano con bastón largo, turbante y capucha.

## En Godot

- El GLB llega como `Node3D` raíz con un `Skeleton3D` de 20 huesos y los 8 `MeshInstance3D` con sus pieles. Escala `(1,1,1)`, mira a −Z.
- Los nombres de huesos coinciden con el perfil humanoide de Godot: cuando lleguemos a animaciones compartidas, el retarget con `BoneMap` será directo.
- Aún no hay `AnimationPlayer` ni clips: el esqueleto llega en reposo.

## Estado del pipeline

| Tarea | Estado |
|---|---|
| ALTA + revisiones de accesorios + LOD | Entregados, pendientes de aprobación visual |
| Esqueleto y pesos automáticos | **Entregado aquí** |
| Poses de validación | 8 capturas por NPC, pendientes de revisión |
| Animaciones (idle, caminar, saludar) | Pendiente: siguiente paso lógico |
| Pesos pintados a mano / huesos de falda | Pendiente tras revisar capturas |
| Herramientas como objetos separados anclados a Hand | Pendiente |
| Rig de LOD MEDIA/BAJA | Pendiente: mismo enfoque por distancias, sobre los meshes agrupados |
| Prueba de importación en Godot 4.7.2 | Pendiente en tu equipo |

**Siguiente paso recomendado:** revisa las capturas de la muestra de cinco NPC. Si las poses se leen bien, seguimos con el set de animaciones comunes (idle, caminar, saludar) sobre este esqueleto. Si hay fallos sistemáticos (herramientas que se doblan, faldas atravesadas), conviene corregirlos antes de animar.