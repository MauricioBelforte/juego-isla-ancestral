import bpy
import bmesh
import math
import json
import traceback

from pathlib import Path
from datetime import datetime
from mathutils import Vector


# ---------------- CONFIGURACION ----------------

CARPETA_CATALOGO = Path(r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\NPC_EXPORT")

# None = todos los NPCs encontrados.
# Ejemplo: {"ROCKY", "SAGE", "ROCA", "HIELO"}
SOLO_NOMBRES = None

GENERAR_CAPTURAS = False
RESOLUCION = 768

# Capturas activadas para 35 NPCs y 2 LOD = 420 renders.
# Empieza con False y revisa primero los informes.

DETENER_EN_ERROR = False

NIVELES = {
    "MEDIA": {
        "tris": 1500,
        "meshes": 4,
        "materiales": 4,
    },
    "BAJA": {
        "tris": 700,
        "meshes": 3,
        "materiales": 3,
    },
}


# ---------------- UTILIDADES ----------------

def guardar_json(ruta, datos):
    ruta.parent.mkdir(parents=True, exist_ok=True)
    with open(ruta, "w", encoding="utf-8") as archivo:
        json.dump(datos, archivo, ensure_ascii=False, indent=2)


def activar(obj):
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj


def limpiar_sesion():
    if bpy.context.object and bpy.context.object.mode != "OBJECT":
        bpy.ops.object.mode_set(mode="OBJECT")

    for obj in list(bpy.data.objects):
        bpy.data.objects.remove(obj, do_unlink=True)

    for col in list(bpy.data.collections):
        bpy.data.collections.remove(col)

    # Solo bloques sin usuarios. No se usa un borrado global
    # de materiales que aun esten asignados.
    for grupo in (
        bpy.data.meshes,
        bpy.data.materials,
        bpy.data.cameras,
        bpy.data.lights,
    ):
        for bloque in list(grupo):
            if bloque.users == 0:
                grupo.remove(bloque)

    scene = bpy.context.scene
    scene.camera = None
    scene.unit_settings.system = "METRIC"
    scene.unit_settings.scale_length = 1.0


def triangulos(obj):
    obj.data.calc_loop_triangles()
    return len(obj.data.loop_triangles)


def limites(objetos):
    puntos = [
        obj.matrix_world @ v.co
        for obj in objetos
        for v in obj.data.vertices
    ]

    if not puntos:
        raise RuntimeError("No hay vertices para medir.")

    minimo = Vector(tuple(
        min(p[i] for p in puntos) for i in range(3)
    ))
    maximo = Vector(tuple(
        max(p[i] for p in puntos) for i in range(3)
    ))
    return minimo, maximo


def materiales_usados(objetos):
    usados = set()
    for obj in objetos:
        for p in obj.data.polygons:
            if p.material_index < len(obj.data.materials):
                mat = obj.data.materials[p.material_index]
                if mat:
                    usados.add(mat)
    return usados


# ---------------- CARGAR SOLO EL PERSONAJE ----------------

def cargar_alta(ruta):
    limpiar_sesion()

    nombre_raiz = ruta.stem

    with bpy.data.libraries.load(
        str(ruta), link=False
    ) as (origen, destino):
        destino.objects = [
            nombre for nombre in origen.objects
            if nombre == nombre_raiz
            or nombre.startswith(nombre_raiz + "_")
        ]

    col = bpy.data.collections.new("COL_NPC")
    bpy.context.scene.collection.children.link(col)

    cargados = [obj for obj in destino.objects if obj is not None]
    for obj in cargados:
        col.objects.link(obj)

    raices = [
        obj for obj in cargados
        if obj.type == "EMPTY" and obj.name == nombre_raiz
    ]
    meshes = [obj for obj in cargados if obj.type == "MESH"]

    if len(raices) != 1:
        raise RuntimeError(
            f"{ruta.name}: se esperaba un Empty {nombre_raiz}."
        )
    if not meshes:
        raise RuntimeError(f"{ruta.name}: no contiene meshes.")

    raiz = raices[0]
    bpy.context.view_layer.update()

    # Los archivos de esta receta deben tener jerarquia plana.
    if any(obj.parent != raiz for obj in meshes):
        raise RuntimeError(
            "Jerarquia distinta de la esperada: "
            "todos los meshes deben ser hijos directos del Empty."
        )

    # COLOR_0 es necesario para que el material consolidado
    # conserve los colores particulares.
    for obj in meshes:
        if obj.data.color_attributes.get("COLOR_0") is None:
            raise RuntimeError(
                f"{obj.name}: falta el atributo COLOR_0."
            )

        # Preparar geometria evaluada antes de medir/reducir.
        activar(obj)
        for mod in list(obj.modifiers):
            bpy.ops.object.modifier_apply(modifier=mod.name)

    return raiz, meshes


# ---------------- INFORME GEOMETRICO ----------------

def inspeccionar(raiz, meshes, nivel, limites_budget):
    bpy.context.view_layer.update()
    minimo, maximo = limites(meshes)

    detalles = []
    avisos = []

    for obj in meshes:
        bm = bmesh.new()
        bm.from_mesh(obj.data)

        fronteras = sum(e.is_boundary for e in bm.edges)
        no_manifold_multiple = sum(
            len(e.link_faces) > 2 for e in bm.edges
        )
        sueltos = sum(not v.link_edges for v in bm.verts)
        degeneradas = sum(
            f.calc_area() < 1e-12 for f in bm.faces
        )

        detalles.append({
            "nombre": obj.name,
            "triangulos": triangulos(obj),
            "vertices": len(obj.data.vertices),
            "slots_material": len(obj.data.materials),
            "aristas_frontera": fronteras,
            "aristas_con_mas_de_2_caras": no_manifold_multiple,
            "vertices_sueltos": sueltos,
            "caras_area_casi_cero": degeneradas,
            "color_0": (
                obj.data.color_attributes.get("COLOR_0") is not None
            ),
            "escala": list(obj.scale),
            "rotacion": list(obj.rotation_euler),
            "pivote": list(obj.location),
        })
        bm.free()

        if fronteras:
            avisos.append(
                f"{obj.name}: {fronteras} aristas de frontera; "
                "pueden corresponder a prendas abiertas."
            )
        if no_manifold_multiple or sueltos or degeneradas:
            avisos.append(
                f"{obj.name}: revisar la topologia indicada en detalles."
            )

    tris = sum(d["triangulos"] for d in detalles)
    materiales = materiales_usados(meshes)

    escala_ok = all(
        (obj.scale - Vector((1, 1, 1))).length < 1e-6
        for obj in meshes
    )
    rotacion_ok = all(
        Vector(obj.rotation_euler).length < 1e-6
        for obj in meshes
    )

    comprobaciones = {
        "triangulos": tris <= limites_budget["tris"],
        "meshes": len(meshes) <= limites_budget["meshes"],
        "materiales": len(materiales) <= limites_budget["materiales"],
        "escala_uno": escala_ok,
        "rotacion_cero": rotacion_ok,
        "suelo_z_cero": abs(minimo.z) < 0.001,
        "color_0": all(d["color_0"] for d in detalles),
    }

    return {
        "npc": raiz.name,
        "nivel": nivel,
        "triangulos": tris,
        "objetos_mesh": len(meshes),
        "objetos_con_empty": len(meshes) + 1,
        "materiales_usados": len(materiales),
        "nombres_materiales": sorted(m.name for m in materiales),
        "dimensiones_con_accesorios_m": list(maximo - minimo),
        "z_minimo_m": minimo.z,
        "presupuesto": limites_budget,
        "comprobaciones": comprobaciones,
        "cumple_comprobaciones_automaticas": all(
            comprobaciones.values()
        ),
        "aprobacion_visual": "PENDIENTE",
        "importacion_godot": "PENDIENTE",
        "intersecciones": "NO_COMPROBADAS",
        "normales_exteriores": (
            "RECALCULADAS; NO CERTIFICA ORIENTACION "
            "DE SUPERFICIES ABIERTAS"
        ),
        "advertencias": avisos,
        "meshes": detalles,
    }


# ---------------- UNIFICACION DE MATERIALES ----------------

def familia(nombre):
    nombre = nombre.upper()

    for etiqueta in ("PIEL", "PELO", "OJOS"):
        if nombre.endswith("_" + etiqueta):
            return etiqueta

    if nombre.endswith(("_CAMISA", "_PANTALON", "_BOTAS")):
        return "ROPA"

    raise RuntimeError(
        f"Material no reconocido por esta receta: {nombre}"
    )


def consolidar_materiales(meshes, nivel, nombre_npc):
    materiales = materiales_usados(meshes)
    originales = {}

    for mat in materiales:
        originales.setdefault(familia(mat.name), mat)

    destinos = {}

    for etiqueta, original in originales.items():
        grupo = (
            "GENERAL"
            if nivel == "BAJA" and etiqueta in ("PELO", "ROPA")
            else etiqueta
        )

        if grupo in destinos:
            continue

        nuevo = original.copy()
        nuevo.name = f"MAT_NPC_{nombre_npc}_{nivel}_{grupo}"
        nuevo.use_backface_culling = False

        bsdf = next(
            (n for n in nuevo.node_tree.nodes
             if n.type == "BSDF_PRINCIPLED"),
            None
        )
        if bsdf is None:
            raise RuntimeError(
                f"{original.name}: no contiene Principled BSDF."
            )

        roughness = {
            "PIEL": 0.56,
            "PELO": 0.72,
            "ROPA": 0.80,
            "GENERAL": 0.78,
            "OJOS": 0.20,
        }[grupo]
        bsdf.inputs["Roughness"].default_value = roughness

        destinos[grupo] = nuevo

    for obj in meshes:
        asignaciones = []

        for p in obj.data.polygons:
            original = obj.data.materials[p.material_index]
            etiqueta = familia(original.name)

            grupo = (
                "GENERAL"
                if nivel == "BAJA" and etiqueta in ("PELO", "ROPA")
                else etiqueta
            )
            asignaciones.append(destinos[grupo])

        usados = list(dict.fromkeys(asignaciones))
        obj.data.materials.clear()

        for mat in usados:
            obj.data.materials.append(mat)

        indices = {mat: i for i, mat in enumerate(usados)}

        for p, mat in zip(obj.data.polygons, asignaciones):
            p.material_index = indices[mat]


# ---------------- AGRUPAR MESHES ----------------

def agrupar(raiz, meshes, nivel):
    por_parte = {}

    for obj in meshes:
        sufijo = obj.name[len(raiz.name) + 1:]
        por_parte[sufijo] = obj

    requeridos = {
        "BODY", "HEAD", "HAIR", "EYES",
        "ARM_L", "ARM_R", "LEG_L", "LEG_R"
    }
    if set(por_parte) != requeridos:
        raise RuntimeError(
            "Se esperaban las ocho partes de la receta base. "
            f"Encontradas: {sorted(por_parte)}"
        )

    grupos = [
        ("BODY", ["BODY", "LEG_L", "LEG_R"]),
        ("HEAD", ["HEAD", "HAIR", "EYES"]),
    ]

    if nivel == "MEDIA":
        grupos += [
            ("ARM_L", ["ARM_L"]),
            ("ARM_R", ["ARM_R"]),
        ]
    else:
        grupos.append(("ARMS", ["ARM_L", "ARM_R"]))

    resultado = []

    for nombre, partes in grupos:
        objetos = [por_parte[p] for p in partes]
        activo = objetos[0]

        bpy.ops.object.select_all(action="DESELECT")
        for obj in objetos:
            obj.select_set(True)
        bpy.context.view_layer.objects.active = activo

        if len(objetos) > 1:
            bpy.ops.object.join()

        activo.name = f"{raiz.name}_{nombre}"
        activo.data.name = activo.name + "_MESH"
        activo.parent = raiz
        resultado.append(activo)

    # El grupo de ambos brazos usa origen en la base del NPC.
    # Los vertices conservan su posicion mundial.
    if nivel == "BAJA":
        brazos = next(
            obj for obj in resultado if obj.name.endswith("_ARMS")
        )
        mundo = [
            brazos.matrix_world @ v.co for v in brazos.data.vertices
        ]

        brazos.location = (0, 0, 0)
        brazos.rotation_euler = (0, 0, 0)
        brazos.scale = (1, 1, 1)

        bpy.context.view_layer.update()
        inversa = brazos.matrix_world.inverted()

        for v, p in zip(brazos.data.vertices, mundo):
            v.co = inversa @ p

    return resultado


# ---------------- DECIMATE CONTROLADO ----------------

def recalcular_normales(obj):
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
    bm.to_mesh(obj.data)
    bm.free()
    obj.data.update()


def reducir(meshes, max_tris):
    # Se triangula antes de reducir para medir el mismo tipo de
    # primitivas que se exportaran a glTF.
    for obj in meshes:
        activar(obj)
        mod = obj.modifiers.new("LOD_TRIANGULATE", "TRIANGULATE")
        bpy.ops.object.modifier_apply(modifier=mod.name)

    historial = []

    # Ratio recalculado a partir de la geometria real.
    # No se supone que ratio 0.35 produzca exactamente 1500 tris.
    for pasada in range(8):
        total = sum(triangulos(obj) for obj in meshes)
        historial.append(total)

        if total <= max_tris:
            break

        ratio = min(0.97, max(0.03, max_tris * 0.97 / total))

        for obj in meshes:
            if triangulos(obj) <= 12:
                continue

            activar(obj)
            mod = obj.modifiers.new("LOD_DECIMATE", "DECIMATE")
            mod.decimate_type = "COLLAPSE"
            mod.ratio = ratio
            mod.use_collapse_triangulate = True

            bpy.ops.object.modifier_apply(modifier=mod.name)

        nuevo_total = sum(triangulos(obj) for obj in meshes)
        if nuevo_total >= total:
            raise RuntimeError(
                "Decimate no puede reducir mas esta geometria "
                "con la configuracion actual."
            )

    total = sum(triangulos(obj) for obj in meshes)

    if total > max_tris:
        raise RuntimeError(
            f"No se alcanzo el presupuesto: {total} > {max_tris}."
        )

    for obj in meshes:
        recalcular_normales(obj)

        if obj.data.color_attributes.get("COLOR_0") is None:
            raise RuntimeError(
                f"{obj.name}: COLOR_0 se perdio durante la reduccion."
            )

    return historial


# ---------------- AJUSTAR CONTACTO CON SUELO ----------------

def ajustar_suelo(meshes):
    bpy.context.view_layer.update()
    minimo, _ = limites(meshes)
    desplazamiento = minimo.z

    # Decimate puede eliminar vertices de la suela.
    # Corregimos solo la traslacion vertical residual del modelo,
    # sin volver a escalarlo.
    if abs(desplazamiento) > 0.02:
        raise RuntimeError(
            "La reduccion cambio el contacto con el suelo "
            f"en {desplazamiento:.4f} m. Requiere revision."
        )

    if abs(desplazamiento) < 1e-8:
        return 0.0

    for obj in meshes:
        inversa = obj.matrix_world.inverted()
        puntos = [
            obj.matrix_world @ v.co for v in obj.data.vertices
        ]
        for v, p in zip(obj.data.vertices, puntos):
            p.z -= desplazamiento
            v.co = inversa @ p

    return desplazamiento


# ---------------- EXPORTAR ----------------

def exportar_glb(raiz, meshes, ruta):
    bpy.ops.object.select_all(action="DESELECT")
    raiz.select_set(True)

    for obj in meshes:
        obj.select_set(True)

    bpy.context.view_layer.objects.active = meshes[0]

    opciones = {
        "filepath": str(ruta),
        "export_format": "GLB",
        "use_selection": True,
        "export_yup": True,
        "export_apply": True,
        "export_animations": False,
        "export_materials": "EXPORT",
    }

    propiedades = {
        p.identifier
        for p in bpy.ops.export_scene.gltf.get_rna_type().properties
    }

    if "export_all_vertex_colors" in propiedades:
        opciones["export_all_vertex_colors"] = True

    bpy.ops.export_scene.gltf(**opciones)


# ---------------- CAPTURAS OPCIONALES ----------------

def orientar(obj, objetivo):
    direccion = Vector(objetivo) - obj.location
    obj.rotation_euler = direccion.to_track_quat("-Z", "Y").to_euler()


def capturas(raiz, meshes, carpeta, nivel):
    scene = bpy.context.scene

    col = bpy.data.collections.new("COL_PREVIEW_TEMP")
    scene.collection.children.link(col)

    minimo, maximo = limites(meshes)
    centro = (minimo + maximo) * 0.5

    for nombre, posicion, energia in [
        ("KEY", (3, 4, 4.2), 450),
        ("FILL", (-3, 1.5, 2.7), 250),
        ("RIM", (0, -3, 3.3), 400),
    ]:
        data = bpy.data.lights.new(nombre, "AREA")
        data.energy = energia
        data.shape = "DISK"
        data.size = 4.0

        obj = bpy.data.objects.new(nombre, data)
        col.objects.link(obj)
        obj.location = posicion
        orientar(obj, centro)

    cam_data = bpy.data.cameras.new("PREVIEW_CAMERA")
    cam = bpy.data.objects.new("PREVIEW_CAMERA", cam_data)
    col.objects.link(cam)

    cam_data.type = "ORTHO"
    cam_data.ortho_scale = (maximo - minimo).length * 1.20
    scene.camera = cam

    if scene.world is None:
        scene.world = bpy.data.worlds.new("WORLD_NPC")

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
    nombre = raiz.name.removeprefix("SM_NPC_")
    rutas = []

    for i in range(6):
        angulo = math.radians(30 + i * 60)
        cam.location = centro + Vector((
            3.5 * math.sin(angulo),
            3.5 * math.cos(angulo),
            0.95,
        ))
        orientar(cam, centro)

        ruta = carpeta / (
            f"cap_NPC_{nombre}_{nivel}_v1_{fecha}_{i}.png"
        )
        scene.render.filepath = str(ruta)
        bpy.ops.render.render(write_still=True)
        rutas.append(str(ruta))

    scene.camera = None

    for obj in list(col.objects):
        bpy.data.objects.remove(obj, do_unlink=True)
    bpy.data.collections.remove(col)

    for grupo in (bpy.data.cameras, bpy.data.lights):
        for bloque in list(grupo):
            if bloque.users == 0:
                grupo.remove(bloque)

    return rutas


# ---------------- CATALOGO ----------------

archivos = sorted(
    ruta
    for ruta in CARPETA_CATALOGO.rglob("SM_NPC_*.blend")
    if "LODS" not in ruta.parts
    and not ruta.stem.endswith(("_MEDIA", "_BAJA"))
)

if SOLO_NOMBRES is not None:
    archivos = [
        ruta for ruta in archivos
        if ruta.stem.removeprefix("SM_NPC_") in SOLO_NOMBRES
    ]

if not archivos:
    raise RuntimeError(
        f"No se encontraron NPCs ALTA en {CARPETA_CATALOGO}."
    )

catalogo = {
    "blender": bpy.app.version_string,
    "estado": "GENERACION_LOD_PENDIENTE_APROBACION_VISUAL",
    "archivos_alta_encontrados": len(archivos),
    "correctos": [],
    "errores": [],
}

ruta_catalogo = CARPETA_CATALOGO / "CATALOGO_LODS_RESUMEN.json"

for ruta_alta in archivos:
    for nivel, presupuesto in NIVELES.items():
        print(f"\n===== {ruta_alta.stem} / {nivel} =====")

        carpeta = ruta_alta.parent / "LODS" / nivel
        carpeta.mkdir(parents=True, exist_ok=True)

        try:
            # Cada nivel parte del ALTA original.
            # BAJA no se obtiene reduciendo MEDIA otra vez.
            raiz, meshes = cargar_alta(ruta_alta)

            informe_alta = inspeccionar(
                raiz,
                meshes,
                "ALTA",
                {"tris": 6000, "meshes": 8, "materiales": 6}
            )

            guardar_json(
                ruta_alta.parent / "VALIDACION_ALTA_PIPELINE.json",
                informe_alta
            )

            if not informe_alta["cumple_comprobaciones_automaticas"]:
                raise RuntimeError(
                    "El ALTA no supera las comprobaciones iniciales. "
                    "Consulta VALIDACION_ALTA_PIPELINE.json."
                )

            nombre_npc = raiz.name.removeprefix("SM_NPC_")

            consolidar_materiales(meshes, nivel, nombre_npc)
            meshes = agrupar(raiz, meshes, nivel)

            historial = reducir(meshes, presupuesto["tris"])
            ajuste = ajustar_suelo(meshes)

            informe = inspeccionar(
                raiz, meshes, nivel, presupuesto
            )
            informe["archivo_origen"] = str(ruta_alta)
            informe["historial_triangulos"] = historial
            informe["ajuste_vertical_m"] = ajuste
            informe["capturas"] = []

            # Comparacion de envolventes; no es una medida
            # completa de fidelidad de silueta.
            antes = Vector(
                informe_alta["dimensiones_con_accesorios_m"]
            )
            despues = Vector(
                informe["dimensiones_con_accesorios_m"]
            )
            cambios = [
                abs(despues[i] - antes[i]) / max(antes[i], 1e-6)
                for i in range(3)
            ]
            informe["variacion_relativa_dimensiones"] = cambios

            if max(cambios) > 0.03:
                informe["advertencias"].append(
                    "La envolvente cambio mas de un 3% en algun eje. "
                    "Revisar silueta, sombreros y herramientas."
                )

            if not informe["cumple_comprobaciones_automaticas"]:
                guardar_json(carpeta / "RESUMEN.json", informe)
                raise RuntimeError(
                    "LOD fuera de especificacion. Consulta RESUMEN.json."
                )

            raiz["LOD"] = nivel
            raiz["APROBACION_VISUAL"] = "PENDIENTE"
            raiz["ORIGEN_ALTA"] = ruta_alta.name

            nombre_archivo = f"{raiz.name}_{nivel}"

            ruta_glb = carpeta / f"{nombre_archivo}.glb"
            exportar_glb(raiz, meshes, ruta_glb)

            if GENERAR_CAPTURAS:
                informe["capturas"] = capturas(
                    raiz, meshes, carpeta, nivel
                )

            # Limpiar datablocks sin usuarios antes de guardar.
            for grupo in (bpy.data.meshes, bpy.data.materials):
                for bloque in list(grupo):
                    if bloque.users == 0:
                        grupo.remove(bloque)

            ruta_blend = carpeta / f"{nombre_archivo}.blend"
            bpy.ops.wm.save_as_mainfile(filepath=str(ruta_blend))

            informe["archivo_blend"] = str(ruta_blend)
            informe["archivo_glb"] = str(ruta_glb)
            guardar_json(carpeta / "RESUMEN.json", informe)

            catalogo["correctos"].append({
                "npc": nombre_npc,
                "nivel": nivel,
                "triangulos": informe["triangulos"],
                "meshes": informe["objetos_mesh"],
                "materiales": informe["materiales_usados"],
                "carpeta": str(carpeta),
                "aprobacion_visual": "PENDIENTE",
            })

        except Exception as error:
            traceback.print_exc()

            datos_error = {
                "archivo": str(ruta_alta),
                "nivel": nivel,
                "error": str(error),
                "traceback": traceback.format_exc(),
            }
            catalogo["errores"].append(datos_error)
            guardar_json(carpeta / "ERROR.json", datos_error)

            if DETENER_EN_ERROR:
                raise

        finally:
            guardar_json(ruta_catalogo, catalogo)


print("\n================ RESULTADO ================")
print(f'LOD generados: {len(catalogo["correctos"])}')
print(f'Errores: {len(catalogo["errores"])}')
print(f'Informe: {ruta_catalogo}')