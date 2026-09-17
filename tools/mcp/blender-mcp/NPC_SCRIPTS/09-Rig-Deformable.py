import bpy
import math
import json
import traceback

from pathlib import Path
from mathutils import Vector, Matrix


# ---------------- CONFIGURACION ----------------

BASE = Path(r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\NPC_EXPORT")

USAR_REVISION_02 = False

# None = todos los originales encontrados.
# Para prueba: {"LUNA", "ROCKY", "HIELO"}
SOLO_NOMBRES = None

FPS = 30
CREAR_CAMINAR = True

# "L" o "R". Elegir segun herramienta.
LADO_SALUDO = "L"

# Una herramienta muy larga requiere un gesto especifico.
SIN_SALUDO = {
    "FIN", "ROCA", "CALDERA", "TIBURON",
    "HIELO", "ESTRELLA_FUGAZ",
}

LIMITE_TRIS = 6000


# ---------------- UTILIDADES ----------------

def guardar_json(ruta, datos):
    with open(ruta, "w", encoding="utf-8") as archivo:
        json.dump(datos, archivo, ensure_ascii=False, indent=2)


def activar(obj):
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj


def limpiar():
    if bpy.context.object and bpy.context.object.mode != "OBJECT":
        bpy.ops.object.mode_set(mode="OBJECT")

    for obj in list(bpy.data.objects):
        bpy.data.objects.remove(obj, do_unlink=True)

    for col in list(bpy.data.collections):
        bpy.data.collections.remove(col)

    for grupo in (
        bpy.data.meshes, bpy.data.materials,
        bpy.data.armatures, bpy.data.actions,
    ):
        for bloque in list(grupo):
            if bloque.users == 0:
                grupo.remove(bloque)

    scene = bpy.context.scene
    scene.camera = None
    scene.unit_settings.system = "METRIC"
    scene.unit_settings.scale_length = 1.0
    scene.render.fps = FPS
    scene.frame_set(1)


def cargar(ruta):
    limpiar()
    nombre_raiz = ruta.stem

    with bpy.data.libraries.load(str(ruta), link=False) as (src, dst):
        dst.objects = [
            n for n in src.objects
            if n == nombre_raiz or n.startswith(nombre_raiz + "_")
        ]

    col = bpy.data.collections.new("COL_NPC")
    bpy.context.scene.collection.children.link(col)

    for obj in dst.objects:
        if obj:
            col.objects.link(obj)

    raiz = bpy.data.objects.get(nombre_raiz)
    if raiz is None or raiz.type != "EMPTY":
        raise RuntimeError("No se encontro la raiz esperada.")

    partes = {
        obj.name[len(nombre_raiz) + 1:]: obj
        for obj in col.objects if obj.type == "MESH"
    }

    requeridas = {
        "BODY", "HEAD", "HAIR", "EYES",
        "ARM_L", "ARM_R", "LEG_L", "LEG_R"
    }
    if set(partes) != requeridas:
        raise RuntimeError("Se requieren las ocho partes del ALTA.")

    bpy.context.view_layer.update()

    # Conservar geometria mundial y hornear transformaciones.
    # El rig y la raiz quedaran con transform identidad.
    for obj in partes.values():
        if obj.modifiers:
            raise RuntimeError(
                f"{obj.name}: se esperaba geometria sin modificadores."
            )
        if obj.data.color_attributes.get("COLOR_0") is None:
            raise RuntimeError(f"{obj.name}: falta COLOR_0.")

        mundo = obj.matrix_world.copy()
        obj.data.transform(mundo)

        obj.parent = None
        obj.matrix_parent_inverse = Matrix.Identity(4)
        obj.matrix_basis = Matrix.Identity(4)

    raiz.matrix_basis = Matrix.Identity(4)

    for obj in partes.values():
        obj.parent = raiz
        obj.matrix_parent_inverse = Matrix.Identity(4)

    bpy.context.view_layer.update()
    return raiz, partes, col


def smoothstep(t):
    t = max(0.0, min(1.0, t))
    return t * t * (3.0 - 2.0 * t)


def componentes(mesh):
    """Islas conectadas por aristas."""
    adyacencia = [[] for _ in mesh.vertices]

    for edge in mesh.edges:
        a, b = edge.vertices
        adyacencia[a].append(b)
        adyacencia[b].append(a)

    pendientes = set(range(len(mesh.vertices)))
    resultado = []

    while pendientes:
        inicio = pendientes.pop()
        pila = [inicio]
        isla = [inicio]

        while pila:
            actual = pila.pop()
            for vecino in adyacencia[actual]:
                if vecino in pendientes:
                    pendientes.remove(vecino)
                    pila.append(vecino)
                    isla.append(vecino)

        resultado.append(isla)

    return sorted(resultado, key=len, reverse=True)


def parametro_cadena(p, cadena):
    """
    Distancia acumulada de la proyeccion mas cercana sobre
    una polilinea. Se utiliza para mezclar pesos longitudinales.
    """
    mejor = None
    acumulada = 0.0

    for a, b in zip(cadena[:-1], cadena[1:]):
        ab = b - a
        longitud = ab.length
        if longitud < 1e-8:
            continue

        t = max(0.0, min(1.0, (p - a).dot(ab) / ab.length_squared))
        q = a + ab * t
        distancia = (p - q).length_squared
        s = acumulada + t * longitud

        if mejor is None or distancia < mejor[0]:
            mejor = (distancia, s)

        acumulada += longitud

    return mejor[1] if mejor else 0.0


# ---------------- ESQUELETO ----------------

def crear_rig(raiz, partes, col, nombre):
    # Altura del cráneo, sin sombrero.
    factor = max(v.co.z for v in partes["HEAD"].data.vertices) / 1.540

    guardia = nombre in {"ROCA", "CALDERA", "TIBURON"}
    anciano = nombre in {"SAGE", "NANA", "OBSIDIANA", "ALGA", "HIELO", "NIEVE"}

    ancho = 1.12 if guardia else (0.98 if anciano else 1.0)

    def P(x, y, z):
        # Misma curva de postura que el generador base.
        if anciano:
            t = max(0.0, min(1.0, (z - 0.85) / 0.65))
            y += 0.040 * t * t
        return Vector((x, y, z)) * factor

    definiciones = {
        "ROOT": (P(0, 0, 0), P(0, 0, 0.10), None),
        "HIPS": (P(0, 0, 0.82), P(0, 0, 1.00), "ROOT"),
        "CHEST": (P(0, 0, 1.00), P(0, 0, 1.29), "HIPS"),
        "HEAD": (P(0, 0, 1.29), P(0, 0, 1.54), "CHEST"),
    }

    cadenas = {}

    for lado, signo in (("L", -1), ("R", 1)):
        hombro = P(signo * 0.190 * ancho, 0, 1.200)
        codo = P(signo * 0.215 * ancho, 0.025, 1.045)
        muneca = P(signo * 0.210 * ancho, 0.110, 0.912)
        mano = P(signo * 0.210 * ancho, 0.170, 0.875)

        cadera = P(signo * 0.079 * ancho, 0, 0.820)
        rodilla = P(signo * 0.079 * ancho, 0.016, 0.450)
        tobillo = P(signo * 0.079 * ancho, 0.003, 0.150)
        pie = P(signo * 0.079 * ancho, 0.120, 0.045)

        definiciones.update({
            f"UPPER_ARM.{lado}": (hombro, codo, "CHEST"),
            f"FOREARM.{lado}": (codo, muneca, f"UPPER_ARM.{lado}"),
            f"HAND.{lado}": (muneca, mano, f"FOREARM.{lado}"),
            f"THIGH.{lado}": (cadera, rodilla, "HIPS"),
            f"SHIN.{lado}": (rodilla, tobillo, f"THIGH.{lado}"),
            f"FOOT.{lado}": (tobillo, pie, f"SHIN.{lado}"),
        })

        cadenas[f"ARM_{lado}"] = [hombro, codo, muneca, mano]
        cadenas[f"LEG_{lado}"] = [cadera, rodilla, tobillo, pie]

    data = bpy.data.armatures.new(f"{raiz.name}_SKELETON")
    arm = bpy.data.objects.new(f"{raiz.name}_ARM", data)
    col.objects.link(arm)
    arm.parent = raiz
    arm.show_in_front = True

    activar(arm)
    bpy.ops.object.mode_set(mode="EDIT")

    for bn, (head, tail, _) in definiciones.items():
        bone = data.edit_bones.new(bn)
        bone.head = head
        bone.tail = tail

        # Roll consistente: eje local Z cerca del Z mundial.
        bone.align_roll(Vector((0, 0, 1)))
        bone.use_deform = bn != "ROOT"

    for bn, (_, _, parent) in definiciones.items():
        if parent:
            data.edit_bones[bn].parent = data.edit_bones[parent]
            data.edit_bones[bn].use_connect = False

    bpy.ops.object.mode_set(mode="OBJECT")

    for pb in arm.pose.bones:
        pb.rotation_mode = "QUATERNION"

    return arm, factor, cadenas


# ---------------- PESOS ----------------

def asignar_pesos(partes, arm, factor, cadenas):
    estadisticas = {}

    for nombre, obj in partes.items():
        obj.vertex_groups.clear()

        grupos = {
            bone.name: obj.vertex_groups.new(name=bone.name)
            for bone in arm.data.bones if bone.use_deform
        }

        def asignar(indices, pesos):
            total = sum(pesos.values())
            if total <= 0:
                raise RuntimeError("Pesos vacios.")

            for hueso, peso in pesos.items():
                if peso > 0.00001:
                    grupos[hueso].add(
                        list(indices), peso / total, "REPLACE"
                    )

        islas = componentes(obj.data)

        if nombre in {"HEAD", "HAIR", "EYES"}:
            asignar(range(len(obj.data.vertices)), {"HEAD": 1.0})

        elif nombre == "BODY":
            # Aproximacion estable para torso, falda y accesorios.
            # La falda no se engancha a las piernas en esta pasada.
            for v in obj.data.vertices:
                z = v.co.z / factor
                pecho = smoothstep((z - 0.93) / 0.20)
                asignar([v.index], {
                    "HIPS": 1.0 - pecho,
                    "CHEST": pecho,
                })

        else:
            lado = nombre[-1]
            brazo = nombre.startswith("ARM")
            cadena = cadenas[nombre]

            huesos = (
                [f"UPPER_ARM.{lado}", f"FOREARM.{lado}", f"HAND.{lado}"]
                if brazo else
                [f"THIGH.{lado}", f"SHIN.{lado}", f"FOOT.{lado}"]
            )

            l0 = (cadena[1] - cadena[0]).length
            l1 = (cadena[2] - cadena[1]).length
            union_1 = l0
            union_2 = l0 + l1

            ancho_1 = (0.035 if brazo else 0.055) * factor
            ancho_2 = (0.022 if brazo else 0.035) * factor

            # En brazos, la isla mayor suele ser la manga.
            # Otras islas altas: punio / piel del antebrazo.
            # Manopla, pulgar y herramienta: mano rigida.
            principal = set(islas[0]) if islas else set()

            for isla in islas:
                centro = sum(
                    (obj.data.vertices[i].co for i in isla), Vector()
                ) / len(isla)

                rigida = False
                hueso_rigido = huesos[2]

                if brazo and not any(i in principal for i in isla):
                    cerca_antebrazo = (
                        abs(centro.x) < 0.26 * factor
                        and centro.z > 0.93 * factor
                        and centro.y < 0.12 * factor
                    )
                    rigida = not cerca_antebrazo

                if not brazo:
                    # Suela y cuerpo de bota como piezas rigidas.
                    altura_max = max(
                        obj.data.vertices[i].co.z for i in isla
                    )
                    rigida = altura_max < 0.27 * factor

                if rigida:
                    asignar(isla, {hueso_rigido: 1.0})
                    continue

                for indice in isla:
                    p = obj.data.vertices[indice].co
                    s = parametro_cadena(p, cadena)

                    if s < union_1 - ancho_1:
                        pesos = {huesos[0]: 1.0}
                    elif s < union_1 + ancho_1:
                        t = smoothstep(
                            (s - union_1 + ancho_1) / (2 * ancho_1)
                        )
                        pesos = {huesos[0]: 1-t, huesos[1]: t}
                    elif s < union_2 - ancho_2:
                        pesos = {huesos[1]: 1.0}
                    elif s < union_2 + ancho_2:
                        t = smoothstep(
                            (s - union_2 + ancho_2) / (2 * ancho_2)
                        )
                        pesos = {huesos[1]: 1-t, huesos[2]: t}
                    else:
                        pesos = {huesos[2]: 1.0}

                    asignar([indice], pesos)

        mod = obj.modifiers.new("NPC_SKIN", "ARMATURE")
        mod.object = arm

        # Linear blend skinning, mas cercano al glTF estandar.
        mod.use_deform_preserve_volume = False

        sin_peso = 0
        error_maximo = 0.0
        influencias_maximas = 0

        for v in obj.data.vertices:
            suma = sum(g.weight for g in v.groups)
            sin_peso += suma <= 0.00001
            error_maximo = max(error_maximo, abs(suma - 1.0))
            influencias_maximas = max(influencias_maximas, len(v.groups))

        if sin_peso or error_maximo > 0.001:
            raise RuntimeError(f"Pesos invalidos en {obj.name}")

        estadisticas[nombre] = {
            "islas": len(islas),
            "vertices_sin_peso": sin_peso,
            "error_maximo_normalizacion": error_maximo,
            "influencias_maximas": influencias_maximas,
        }

    return estadisticas


# ---------------- ANIMACIONES ----------------

def pose_neutra(arm):
    for pb in arm.pose.bones:
        pb.location = (0, 0, 0)
        pb.rotation_quaternion = (1, 0, 0, 0)
        pb.scale = (1, 1, 1)


def rotacion_eje_mundial(arm, nombre, eje, angulo):
    """
    Expresa un eje de espacio del armature en coordenadas
    locales del hueso para evitar asumir el roll de cada extremidad.
    """
    from mathutils import Quaternion

    pb = arm.pose.bones[nombre]
    eje_local = (
        pb.bone.matrix_local.to_3x3().inverted() @ Vector(eje)
    ).normalized()
    pb.rotation_quaternion = Quaternion(eje_local, angulo)


def crear_clip(arm, nombre, frames, funcion_pose):
    arm.animation_data_create()
    arm.animation_data.action = None
    pose_neutra(arm)

    for frame in frames:
        bpy.context.scene.frame_set(frame)
        pose_neutra(arm)
        funcion_pose(frame)

        # Todos los huesos reciben claves de rotacion.
        # Evita que un clip herede una rotacion del anterior.
        for pb in arm.pose.bones:
            pb.keyframe_insert(
                data_path="rotation_quaternion",
                frame=frame,
                group=pb.name,
            )

    action = arm.animation_data.action
    action.name = nombre
    action.use_fake_user = True

    # En versiones con slots, la asignacion se conserva al
    # crear la tira desde el action activo.
    slot = getattr(arm.animation_data, "action_slot", None)

    track = arm.animation_data.nla_tracks.new()
    track.name = nombre
    strip = track.strips.new(nombre, 1, action)
    strip.extrapolation = "NOTHING"

    if slot is not None and hasattr(strip, "action_slot"):
        strip.action_slot = slot

    arm.animation_data.action = None
    track.mute = True

    return action, track


def animaciones(arm, nombre):
    resultados = []

    def idle(frame):
        fase = 2 * math.pi * (frame - 1) / 60
        respiracion = 0.012 * math.sin(fase)

        rotacion_eje_mundial(arm, "CHEST", (1,0,0), respiracion)
        rotacion_eje_mundial(arm, "HEAD", (0,0,1), 0.018 * math.sin(fase))
        for lado, signo in (("L", 1), ("R", -1)):
            rotacion_eje_mundial(
                arm, f"UPPER_ARM.{lado}", (1,0,0),
                signo * 0.020 * math.sin(fase)
            )

    resultados.append(crear_clip(
        arm, "IDLE", range(1, 62, 5), idle
    ))

    if CREAR_CAMINAR:
        def caminar(frame):
            fase = 2 * math.pi * (frame - 1) / 30

            for lado, desfase in (("L", 0), ("R", math.pi)):
                p = fase + desfase

                rotacion_eje_mundial(
                    arm, f"THIGH.{lado}", (1,0,0),
                    0.24 * math.sin(p)
                )
                rotacion_eje_mundial(
                    arm, f"SHIN.{lado}", (1,0,0),
                    -0.38 * max(0.0, -math.sin(p))
                )
                rotacion_eje_mundial(
                    arm, f"FOOT.{lado}", (1,0,0),
                    0.10 * max(0.0, -math.sin(p))
                )
                rotacion_eje_mundial(
                    arm, f"UPPER_ARM.{lado}", (1,0,0),
                    -0.13 * math.sin(p)
                )

            rotacion_eje_mundial(
                arm, "CHEST", (0,0,1),
                0.025 * math.sin(fase)
            )

        resultados.append(crear_clip(
            arm, "CAMINAR", range(1, 32, 3), caminar
        ))

    if nombre not in SIN_SALUDO:
        lado = LADO_SALUDO
        signo = 1 if lado == "L" else -1

        def saludo(frame):
            subir = smoothstep((frame - 1) / 15)
            bajar = 1.0 - smoothstep((frame - 40) / 20)
            intensidad = subir * bajar

            rotacion_eje_mundial(
                arm, f"UPPER_ARM.{lado}", (0,1,0),
                signo * 0.85 * intensidad
            )
            rotacion_eje_mundial(
                arm, f"FOREARM.{lado}", (0,1,0),
                signo * 1.20 * intensidad
            )
            rotacion_eje_mundial(
                arm, f"HAND.{lado}", (0,1,0),
                0.22 * math.sin((frame - 16) * math.pi / 9) * intensidad
            )
            rotacion_eje_mundial(
                arm, "HEAD", (0,0,1),
                signo * 0.055 * intensidad
            )

        resultados.append(crear_clip(
            arm, "SALUDO", range(1, 62, 3), saludo
        ))

    bpy.context.scene.frame_set(1)
    pose_neutra(arm)
    bpy.context.view_layer.update()

    return resultados


# ---------------- EXPORTACION ----------------

def exportar(raiz, partes, arm, clips, ruta):
    bpy.ops.object.select_all(action="DESELECT")
    raiz.select_set(True)
    arm.select_set(True)
    for obj in partes.values():
        obj.select_set(True)

    bpy.context.view_layer.objects.active = arm

    props = {
        p.identifier: p
        for p in bpy.ops.export_scene.gltf.get_rna_type().properties
    }

    opciones = {
        "filepath": str(ruta),
        "export_format": "GLB",
        "use_selection": True,
        "export_yup": True,
        "export_apply": True,
        "export_animations": True,
        "export_materials": "EXPORT",
    }

    if "export_all_vertex_colors" in props:
        opciones["export_all_vertex_colors"] = True

    # Exportar una animacion por pista, no mezclar los tres clips.
    if "export_animation_mode" in props:
        modos = {
            item.identifier
            for item in props["export_animation_mode"].enum_items
        }
        if "NLA_TRACKS" not in modos:
            raise RuntimeError(
                "Este exportador no ofrece NLA_TRACKS. "
                "Exporta manualmente por pistas NLA."
            )
        opciones["export_animation_mode"] = "NLA_TRACKS"
    else:
        raise RuntimeError(
            "Version de exportador no compatible con este lote."
        )

    if "export_force_sampling" in props:
        opciones["export_force_sampling"] = True

    if "export_nla_strips" in props:
        opciones["export_nla_strips"] = True

    if "export_frame_range" in props:
        opciones["export_frame_range"] = False

    # Las pistas estan superpuestas temporalmente porque cada
    # una representa un clip independiente.
    for _, track in clips:
        track.mute = False

    try:
        bpy.ops.export_scene.gltf(**opciones)
    finally:
        # El .blend se guarda neutro, sin mezclar los clips.
        for _, track in clips:
            track.mute = True

        arm.animation_data.action = None
        bpy.context.scene.frame_set(1)
        pose_neutra(arm)


# ---------------- LOTE ----------------

originales = sorted(BASE.glob("*/*/SM_NPC_*.blend"))
catalogo = {"correctos": [], "errores": []}
BASE.mkdir(parents=True, exist_ok=True)

for original in originales:
    nombre = original.stem.removeprefix("SM_NPC_")

    if SOLO_NOMBRES is not None and nombre not in SOLO_NOMBRES:
        continue

    origen = original
    if USAR_REVISION_02:
        origen = original.parent / "REVISION_02" / original.name
        if not origen.exists():
            catalogo["errores"].append({
                "npc": nombre,
                "error": "Falta la REVISION_02 solicitada."
            })
            continue

    salida = original.parent / "RIG_DEFORMABLE"
    salida.mkdir(parents=True, exist_ok=True)

    try:
        raiz, partes, col = cargar(origen)

        total = 0
        for obj in partes.values():
            obj.data.calc_loop_triangles()
            total += len(obj.data.loop_triangles)

        if total > LIMITE_TRIS:
            raise RuntimeError(f"Presupuesto excedido: {total} tris.")

        arm, factor, cadenas = crear_rig(
            raiz, partes, col, nombre
        )
        pesos = asignar_pesos(partes, arm, factor, cadenas)
        clips = animaciones(arm, nombre)

        raiz["RIG"] = "DEFORMABLE_PROCEDURAL_V1"
        raiz["APROBACION_VISUAL"] = "PENDIENTE"

        ruta_glb = salida / f"SM_NPC_{nombre}_RIG.glb"
        exportar(raiz, partes, arm, clips, ruta_glb)

        bpy.context.scene.frame_start = 1
        bpy.context.scene.frame_end = 61

        ruta_blend = salida / f"SM_NPC_{nombre}_RIG.blend"
        bpy.ops.wm.save_as_mainfile(filepath=str(ruta_blend))

        informe = {
            "npc": nombre,
            "origen": str(origen),
            "triangulos": total,
            "meshes": len(partes),
            "huesos": len(arm.data.bones),
            "objetos_con_raiz_y_armature": len(partes) + 2,
            "factor_anatomico": factor,
            "clips": [action.name for action, _ in clips],
            "pesos": pesos,
            "root_motion": False,
            "ik_pies": False,
            "falda_deformacion_especifica": False,
            "herramientas_pesos": "HEURISTICA_POR_ISLAS",
            "aprobacion_visual": "PENDIENTE",
            "prueba_godot": "PENDIENTE",
        }

        guardar_json(salida / "RIG_DEFORMABLE.json", informe)
        catalogo["correctos"].append(informe)

    except Exception as error:
        traceback.print_exc()
        fallo = {
            "npc": nombre,
            "error": str(error),
            "traceback": traceback.format_exc(),
        }
        catalogo["errores"].append(fallo)
        guardar_json(salida / "ERROR.json", fallo)

    finally:
        guardar_json(BASE / "RIG_DEFORMABLE_CATALOGO.json", catalogo)

guardar_json(BASE / "RIG_DEFORMABLE_CATALOGO.json", catalogo)

print("\n=== RIG DEFORMABLE ===")
print("Correctos:", len(catalogo["correctos"]))
print("Errores:", len(catalogo["errores"]))