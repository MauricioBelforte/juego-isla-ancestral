Continuamos igual: **rig base + animaciones mínimas + prueba en Godot**. Es lo que falta para que los 35 NPCs pasen de estatuas a personajes.

**Estado real:** tienes generadores ALTA, LODs y revisiones, pero no 35 modelos aprobados ni probados en Godot desde aquí. Este paso trabaja sobre `REVISION_02` —o sobre el ALTA si la revisión no está aprobada— y no sobrescribe nada. Crea una variante `_RIG` separada.

La decisión técnica es **parentesco a hueso, sin pesos**. Cada mesh sigue siendo rígido y sigue a un hueso. Es lo más estable para low-poly con 8 objetos, conserva LODs y evita weight painting en 35 personajes. La deformación suave de codos/rodillas queda explícitamente fuera de este paso.

## 1. Script `rig_base_npcs.py`

Guárdalo junto a los anteriores y ejecútalo en instancia dedicada:

```bash
blender --background --factory-startup --python rig_base_npcs.py
```

```python
# ================================================================
# NPC COZY — RIG BASE + 2 ANIMACIONES
# Blender 4.2+
# Entrada: .../NN_NOMBRE/REVISION_02/SM_NPC_NOMBRE.blend
#          si no existe, usa .../NN_NOMBRE/SM_NPC_NOMBRE.blend
# Salida:  .../NN_NOMBRE/RIG/
#   SM_NPC_NOMBRE_RIG.blend
#   SM_NPC_NOMBRE_RIG.glb  (con animaciones)
#   RIG.json
#   3-4 capturas de poses
# No modifica el original. No crea materiales. <=6000 tris.
# ================================================================

import bpy
import bmesh
import math
import json
import traceback
from pathlib import Path
from datetime import datetime
from mathutils import Vector

BASE = Path.home() / "NPC_EXPORT"
SOLO_NOMBRES = None  # ej: {"LUNA","FIN","ROCA","PERLA","HIELO","ESTRELLA_FUGAZ"}
GENERAR_CAPTURAS = True
RESOLUCION = 768
CREAR_ANIMACIONES = True
LIMITE_TRIS = 6000
FPS = 30

# Huesos en referencia 1.8m. Se escalan por factor.
# head, tail, parent
HUESOS = {
    "ROOT":        ((0,0,0), (0,0,0.10), None),
    "HIPS":        ((0,0,0.95), (0,0,1.05), "ROOT"),
    "SPINE":       ((0,0,1.05), (0,0,1.20), "HIPS"),
    "CHEST":       ((0,0,1.20), (0,0,1.29), "SPINE"),
    "NECK":        ((0,0,1.29), (0,0,1.36), "CHEST"),
    "HEAD":        ((0,0,1.36), (0,0,1.56), "NECK"),
    "UPPER_ARM.L": ((-0.19,0,1.20), (-0.215,0.025,1.045), "CHEST"),
    "FOREARM.L":   ((-0.215,0.025,1.045), (-0.21,0.11,0.912), "UPPER_ARM.L"),
    "HAND.L":      ((-0.21,0.11,0.912), (-0.21,0.16,0.87), "FOREARM.L"),
    "UPPER_ARM.R": ((0.19,0,1.20), (0.215,0.025,1.045), "CHEST"),
    "FOREARM.R":   ((0.215,0.025,1.045), (0.21,0.11,0.912), "UPPER_ARM.R"),
    "HAND.R":      ((0.21,0.11,0.912), (0.21,0.16,0.87), "FOREARM.R"),
    "THIGH.L":     ((-0.088,0,0.82), (-0.079,0.016,0.45), "HIPS"),
    "SHIN.L":      ((-0.079,0.016,0.45), (-0.079,0.003,0.15), "THIGH.L"),
    "FOOT.L":      ((-0.079,0.003,0.15), (-0.079,0.12,0.02), "SHIN.L"),
    "THIGH.R":     ((0.088,0,0.82), (0.079,0.016,0.45), "HIPS"),
    "SHIN.R":      ((0.079,0.016,0.45), (0.079,0.003,0.15), "THIGH.R"),
    "FOOT.R":      ((0.079,0.003,0.15), (0.079,0.12,0.02), "SHIN.R"),
}

PARENTESCO = {
    "BODY": "CHEST",
    "HEAD": "HEAD",
    "HAIR": "HEAD",
    "EYES": "HEAD",
    "ARM_L": "UPPER_ARM.L",
    "ARM_R": "UPPER_ARM.R",
    "LEG_L": "THIGH.L",
    "LEG_R": "THIGH.R",
}

def guardar_json(ruta, datos):
    ruta.parent.mkdir(parents=True, exist_ok=True)
    with open(ruta, "w", encoding="utf-8") as f:
        json.dump(datos, f, ensure_ascii=False, indent=2)

def limpiar():
    if bpy.context.object and bpy.context.object.mode != "OBJECT":
        bpy.ops.object.mode_set(mode="OBJECT")
    for o in list(bpy.data.objects):
        bpy.data.objects.remove(o, do_unlink=True)
    for c in list(bpy.data.collections):
        bpy.data.collections.remove(c)
    for g in (bpy.data.meshes, bpy.data.materials, bpy.data.armatures, bpy.data.actions):
        for b in list(g):
            if b.users == 0:
                g.remove(b)
    bpy.context.scene.camera = None
    bpy.context.scene.unit_settings.system = "METRIC"

def buscar_origen(nombre):
    # Prefiere REVISION_02, si no ALTA
    rev = sorted(BASE.rglob(f"*/{nombre}/REVISION_02/SM_NPC_{nombre}.blend"))
    # patrón alternativo NN_NOMBRE
    if not rev:
        rev = sorted(BASE.rglob(f"REVISION_02/SM_NPC_{nombre}.blend"))
    if rev:
        return rev[0]
    alta = sorted([p for p in BASE.rglob(f"SM_NPC_{nombre}.blend") if "LODS" not in p.parts and "RIG" not in p.parts and "REVISION_02" not in p.parts])
    return alta[0] if alta else None

def cargar(ruta, nombre):
    limpiar()
    raiz_nombre = f"SM_NPC_{nombre}"
    with bpy.data.libraries.load(str(ruta), link=False) as (src, dst):
        dst.objects = [n for n in src.objects if n == raiz_nombre or n.startswith(raiz_nombre+"_")]
    col = bpy.data.collections.new("COL_NPC")
    bpy.context.scene.collection.children.link(col)
    for o in dst.objects:
        if o is not None:
            col.objects.link(o)
    raiz = bpy.data.objects.get(raiz_nombre)
    partes = {o.name[len(raiz_nombre)+1:]: o for o in col.objects if o.type == "MESH"}
    if set(partes) != {"BODY","HEAD","HAIR","EYES","ARM_L","ARM_R","LEG_L","LEG_R"}:
        raise RuntimeError(f"Jerarquía inesperada en {nombre}: {sorted(partes)}")
    bpy.context.view_layer.update()
    return raiz, partes, col

def tris(obj):
    obj.data.calc_loop_triangles()
    return len(obj.data.loop_triangles)

def crear_armature(nombre_raiz, factor):
    data = bpy.data.armatures.new(f"{nombre_raiz}_RIG")
    data.display_type = "STICK"
    arm = bpy.data.objects.new(f"{nombre_raiz}_ARM", data)
    bpy.context.scene.collection.objects.link(arm)
    arm.show_in_front = True
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode="EDIT")
    ebs = {}
    for bn, (h, t, _) in HUESOS.items():
        eb = data.edit_bones.new(bn)
        eb.head = Vector(h)*factor
        eb.tail = Vector(t)*factor
        eb.roll = 0
        eb.use_deform = False if bn in {"ROOT"} else True
        ebs[bn] = eb
    for bn, (_, _, parent) in HUESOS.items():
        if parent:
            ebs[bn].parent = ebs[parent]
    bpy.ops.object.mode_set(mode="OBJECT")
    # Hips y pies no deben heredar escala rara: todo escala 1
    arm.location = (0,0,0)
    for pb in arm.pose.bones:
        pb.rotation_mode = "XYZ"
    return arm

def emparentar(arm, raiz, partes):
    # Parentesco a hueso con keep_transform vía operador
    bpy.ops.object.select_all(action="DESELECT")
    for sufijo, hueso in PARENTESCO.items():
        obj = partes[sufijo]
        # activa hueso
        bpy.context.view_layer.objects.active = arm
        bpy.ops.object.mode_set(mode="POSE")
        for pb in arm.pose.bones:
            pb.bone.select = False
        arm.data.bones[hueso].select = True
        arm.data.bones.active = arm.data.bones[hueso]
        bpy.ops.object.mode_set(mode="OBJECT")
        obj.select_set(True)
        arm.select_set(True)
        bpy.context.view_layer.objects.active = arm
        bpy.ops.object.parent_set(type="BONE", keep_transform=True)
        bpy.ops.object.select_all(action="DESELECT")
    # Armature bajo la raíz del NPC para conservar pivote en suelo
    arm.parent = raiz
    arm.matrix_parent_inverse.identity()

def curva(accion, hueso, indice, claves):
    # claves: [(frame, valor)]
    fc = accion.fcurves.new(data_path=f'pose.bones["{hueso}"].rotation_euler', index=indice)
    fc.keyframe_points.add(len(claves))
    for i, (fr, val) in enumerate(claves):
        fc.keyframe_points[i].co = (fr, val)
        fc.keyframe_points[i].interpolation = "BEZIER"

def crear_animaciones(arm):
    if arm.animation_data is None:
        arm.animation_data_create()
    # Limpia NLA previa
    for tr in list(arm.animation_data.nla_tracks):
        arm.animation_data.nla_tracks.remove(tr)

    # IDLE 60 frames: respiración + balanceo leve
    idle = bpy.data.actions.new(f"{arm.name}_IDLE")
    # chest respira en X muy leve, brazos balanceo
    curva(idle, "CHEST", 0, [(1,0),(30,0.03),(60,0)])
    curva(idle, "HEAD", 0, [(1,0),(30,0.02),(60,0)])
    curva(idle, "UPPER_ARM.L", 0, [(1,0),(30,0.04),(60,0)])
    curva(idle, "UPPER_ARM.R", 0, [(1,0),(30,-0.04),(60,0)])
    # SALUDO 45 frames: brazo R levanta y rota
    sal = bpy.data.actions.new(f"{arm.name}_SALUDO")
    # UPPER_ARM.R: X levanta ~ -2.2 rad, Z saluda
    curva(sal, "UPPER_ARM.R", 0, [(1,0),(15,-2.1),(30,-2.1),(45,0)])
    curva(sal, "UPPER_ARM.R", 1, [(1,0),(15,0),(22,0.25),(30,-0.25),(38,0.15),(45,0)])
    curva(sal, "FOREARM.R", 0, [(1,0),(15,-0.3),(45,0)])
    curva(sal, "HEAD", 1, [(1,0),(15,0.08),(30,0.08),(45,0)])

    for act in (idle, sal):
        act.use_fake_user = True

    # A NLA para que glTF exporte ambas
    arm.animation_data.action = None
    for act, start in ((idle, 0), (sal, 70)):
        tr = arm.animation_data.nla_tracks.new()
        tr.name = act.name
        st = tr.strips.new(act.name, int(start), act)
        st.blend_type = "REPLACE"
    arm.animation_data.use_nla = True
    return [idle.name, sal.name]

def poner_pose(arm, preset):
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode="POSE")
    for pb in arm.pose.bones:
        pb.rotation_euler = (0,0,0)
    if preset == "SALUDO":
        arm.pose.bones["UPPER_ARM.R"].rotation_euler = (-2.1, 0, 0.2)
        arm.pose.bones["FOREARM.R"].rotation_euler = (-0.3, 0, 0)
        arm.pose.bones["HEAD"].rotation_euler = (0, 0.08, 0)
    elif preset == "REVERENCIA":
        arm.pose.bones["SPINE"].rotation_euler = (0.35, 0, 0)
        arm.pose.bones["CHEST"].rotation_euler = (0.25, 0, 0)
        arm.pose.bones["HEAD"].rotation_euler = (-0.15, 0, 0)
        arm.pose.bones["UPPER_ARM.L"].rotation_euler = (0.2, 0, 0)
        arm.pose.bones["UPPER_ARM.R"].rotation_euler = (0.2, 0, 0)
    bpy.ops.object.mode_set(mode="OBJECT")
    bpy.context.view_layer.update()

def limites(objs):
    pts = [o.matrix_world @ v.co for o in objs for v in o.data.vertices]
    mn = Vector(tuple(min(p[i] for p in pts) for i in range(3)))
    mx = Vector(tuple(max(p[i] for p in pts) for i in range(3)))
    return mn, mx

def orientar(o, tgt):
    o.rotation_euler = (Vector(tgt)-o.location).to_track_quat("-Z","Y").to_euler()

def capturas(arm, meshes, carpeta, nombre):
    scene = bpy.context.scene
    col = bpy.data.collections.new("COL_PREVIEW_TEMP")
    scene.collection.children.link(col)
    mn, mx = limites(meshes)
    centro = (mn+mx)*0.5
    for tag, pos, ene in [("KEY",(3,4,4.2),450),("FILL",(-3,1.5,2.7),250),("RIM",(0,-3,3.3),400)]:
        d = bpy.data.lights.new(tag,"AREA"); d.energy=ene; d.size=4
        o = bpy.data.objects.new(tag,d); col.objects.link(o); o.location=pos; orientar(o,centro)
    cd = bpy.data.cameras.new("PREVCAM")
    cam = bpy.data.objects.new("PREVCAM",cd); col.objects.link(cam)
    cd.type="ORTHO"; cd.ortho_scale=(mx-mn).length*1.2
    scene.camera=cam
    if scene.world is None:
        scene.world=bpy.data.worlds.new("WORLD_PREV")
    scene.world.use_nodes=True
    bg=scene.world.node_tree.nodes.get("Background")
    bg.inputs["Color"].default_value=(0.16,0.14,0.12,1)
    bg.inputs["Strength"].default_value=0.5
    scene.render.engine="BLENDER_EEVEE_NEXT"
    scene.render.resolution_x=RESOLUCION; scene.render.resolution_y=RESOLUCION
    scene.render.image_settings.file_format="PNG"
    scene.view_settings.view_transform="AgX"
    fecha=datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    rutas=[]
    for preset, ang in [("NEUTRO",30),("SALUDO",30),("REVERENCIA",210),("NEUTRO",210)]:
        poner_pose(arm, preset if preset!="NEUTRO" else "NEUTRO")
        a=math.radians(ang)
        cam.location=centro+Vector((3.5*math.sin(a),3.5*math.cos(a),0.95))
        orientar(cam,centro)
        r=carpeta/f"cap_NPC_{nombre}_RIG_{preset}_{fecha}_{ang}.png"
        scene.render.filepath=str(r)
        bpy.ops.render.render(write_still=True)
        rutas.append(str(r))
    poner_pose(arm,"NEUTRO")
    scene.camera=None
    for o in list(col.objects):
        bpy.data.objects.remove(o,do_unlink=True)
    bpy.data.collections.remove(col)
    return rutas

def exportar_glb(raiz, meshes, arm, ruta, con_anim):
    bpy.ops.object.select_all(action="DESELECT")
    raiz.select_set(True)
    for o in meshes: o.select_set(True)
    arm.select_set(True)
    bpy.context.view_layer.objects.active = arm
    opts={
        "filepath":str(ruta),
        "export_format":"GLB",
        "use_selection":True,
        "export_yup":True,
        "export_apply":True,
        "export_animations":con_anim,
        "export_materials":"EXPORT",
    }
    props={p.identifier for p in bpy.ops.export_scene.gltf.get_rna_type().properties}
    if "export_all_vertex_colors" in props:
        opts["export_all_vertex_colors"]=True
    bpy.ops.export_scene.gltf(**opts)

# ---- LOTE ----
todos = sorted({p.stem.removeprefix("SM_NPC_") for p in BASE.rglob("SM_NPC_*.blend") if "LODS" not in p.parts and "RIG" not in p.parts and p.stem.count("_")==2})
# filtra solo 35 esperados (excluye MEDIA/BAJA que tienen 3 partes)
todos = [n for n in todos if "_" not in n or n in {"CORAL_ROSA","ESTRELLA_FUGAZ"}]
# corrección: nombres con guion bajo doble se perdieron; re-busca por carpetas
import re
todos = []
for p in BASE.glob("*/*/SM_NPC_*.blend"):
    if "LODS" in p.parts or "RIG" in p.parts or "REVISION" in str(p.parent):
        continue
    todos.append(p.stem.removeprefix("SM_NPC_"))
todos = sorted(set(todos))
if SOLO_NOMBRES is not None:
    todos=[n for n in todos if n in SOLO_NOMBRES]

catalogo={"rig":"BASE_OBJETO","correctos":[],"errores":[]}
for nombre in todos:
    print(f"\n===== RIG {nombre} =====")
    ruta_origen=buscar_origen(nombre)
    if ruta_origen is None:
        catalogo["errores"].append({"npc":nombre,"error":"origen no encontrado"})
        continue
    carpeta_rig=ruta_origen.parent/("REVISION_02/RIG" if "REVISION_02" in str(ruta_origen) else "RIG")
    # si origen es REVISION_02, RIG va dentro de REVISION_02; si es ALTA, al lado
    if "REVISION_02" not in str(ruta_origen):
        carpeta_rig=ruta_origen.parent/"RIG"
    else:
        carpeta_rig=ruta_origen.parent/"RIG"
    carpeta_rig.mkdir(parents=True,exist_ok=True)
    try:
        raiz, partes, col = cargar(ruta_origen, nombre)
        meshes=list(partes.values())
        t=sum(tris(o) for o in meshes)
        if t>LIMITE_TRIS:
            raise RuntimeError(f"Origen fuera de presupuesto: {t}")
        # factor por cabeza (evita que sombreros inflen el rig)
        cabeza_altura=max((partes["HEAD"].matrix_world @ v.co).z for v in partes["HEAD"].data.vertices)
        factor=cabeza_altura/1.54
        anciano = cabeza_altura < 1.50  # aprox 1.7m
        arm=crear_armature(raiz.name, factor)
        col.objects.link(arm) if arm.name not in col.objects else None
        # asegura que arm esté en COL_NPC
        try: col.objects.link(arm)
        except: pass
        emparentar(arm, raiz, partes)
        bpy.context.view_layer.update()
        nombres_anim=[]
        if CREAR_ANIMACIONES:
            nombres_anim=crear_animaciones(arm)
        # validaciones
        for o in meshes:
            if o.data.color_attributes.get("COLOR_0") is None:
                raise RuntimeError(f"COLOR_0 perdido en {o.name}")
        mn,mx=limites(meshes)
        if abs(mn.z)>0.01:
            raise RuntimeError(f"Suelo alterado por rig: {mn.z:.4f}")
        raiz["RIG"]="BASE_OBJETO"
        raiz["ANIMACIONES"]=json.dumps(nombres_anim)
        informe={
            "npc":nombre,"origen":str(ruta_origen),
            "triangulos":t,"meshes":8,"huesos":len(HUESOS),
            "factor":factor,"anciano_aprox":anciano,
            "animaciones":nombres_anim,
            "parentesco":PARENTESCO,
            "nota":"Parentesco rígido a hueso. Sin pesos. Herramientas siguen a la mano.",
            "intersecciones":"NO_COMPROBADAS",
            "aprobacion_visual":"PENDIENTE",
            "capturas":[],
        }
        exportar_glb(raiz, meshes, arm, carpeta_rig/f"SM_NPC_{nombre}_RIG.glb", CREAR_ANIMACIONES)
        if GENERAR_CAPTURAS:
            informe["capturas"]=capturas(arm, meshes, carpeta_rig, nombre)
        for g in (bpy.data.meshes,bpy.data.materials):
            for b in list(g):
                if b.users==0: g.remove(b)
        bpy.ops.wm.save_as_mainfile(filepath=str(carpeta_rig/f"SM_NPC_{nombre}_RIG.blend"))
        guardar_json(carpeta_rig/"RIG.json",informe)
        catalogo["correctos"].append({"npc":nombre,"triangulos":t,"carpeta":str(carpeta_rig)})
    except Exception as e:
        traceback.print_exc()
        err={"npc":nombre,"error":str(e),"traceback":traceback.format_exc()}
        catalogo["errores"].append(err)
        guardar_json(carpeta_rig/"ERROR_RIG.json",err)
    finally:
        guardar_json(BASE/"RIG_CATALOGO.json",catalogo)

guardar_json(BASE/"RIG_CATALOGO.json",catalogo)
print(f'\nCompletados: {len(catalogo["correctos"])} Errores: {len(catalogo["errores"])}')
```

### Qué obtienes por NPC

```text
02_ROCKY/REVISION_02/RIG/
  SM_NPC_ROCKY_RIG.blend
  SM_NPC_ROCKY_RIG.glb   # con IDLE + SALUDO
  RIG.json
  cap_NPC_ROCKY_RIG_NEUTRO_..._30.png
  cap_NPC_ROCKY_RIG_SALUDO_..._30.png
  ...
```

18 huesos, 8 meshes, 6 materiales. Las herramientas al estar dentro de `ARM_R/L` siguen a la mano sin constraints extra.

> Ancianos (Sage, Nana, Obsidiana, Hielo, Nieve...): el rig es recto y la malla está encorvada. Funciona para saludo/idle, pero la reverencia exagera la inclinación. Márcalos para revisión de columna en la pasada de animación.

## 2. Uso en Godot 4.7.2

Importa `SM_NPC_*_RIG.glb` como escena. Llegará como:

```text
SM_NPC_LUNA (Node3D)
├── ARM (Skeleton3D)
├── SM_NPC_LUNA_BODY (MeshInstance3D + Skeleton3D? -> Skinned)
├── ...
└── AnimationPlayer (IDLE, SALUDO)
```

Guarda este controlador como `res://npc/scripts/npc_animado.gd`. Reutiliza tu `NPCVisualLOD` para distancia y añade animación solo al LOD HIGH:

```gdscript
class_name NPCAnimado
extends NPCVisualLOD

@export var idle_anim: StringName = &"SM_NPC_LUNA_ARM_IDLE"
@export var wave_anim: StringName = &"SM_NPC_LUNA_ARM_SALUDO"
@export var crossfade: float = 0.25

var _player: AnimationPlayer = null
var _waving: bool = false

func _ready() -> void:
	super._ready()
	lod_changed.connect(_on_lod_changed)
	_cache_player()
	_play_idle()

func _cache_player() -> void:
	# El player vive dentro del visual HIGH
	if _visuals.is_empty():
		return
	_player = _visuals[0].find_child("AnimationPlayer", true, false) as AnimationPlayer

func _on_lod_changed(_prev: int, _curr: int) -> void:
	# Solo HIGH tiene esqueleto; MEDIUM/LOW son estáticos
	if get_current_lod() == Level.HIGH and _player:
		_play_idle()

func _play_idle() -> void:
	if _player and _player.has_animation(idle_anim):
		_player.play(idle_anim)
		_waving = false

func saludar() -> void:
	if get_current_lod() != Level.HIGH:
		return # lejos: no malgastar animación
	if _player and _player.has_animation(wave_anim):
		_waving = true
		_player.play(wave_anim)
		await _player.animation_finished
		if _waving:
			_play_idle()
```

**Nombres reales:** Godot nombra las animaciones como `ARM|IDLE`. Abre el GLB importado, copia los nombres exactos del `AnimationPlayer` y pégalos en `idle_anim / wave_anim`. No asumas el nombre del script.

En tu escena de prueba:

- `high_scene = SM_NPC_*_RIG.glb` (riggeado)
- `medium_scene / low_scene = MEDIA/BAJA estáticas` (sin esqueleto)
- Llama a `saludar()` desde un `Area3D` de proximidad o input para probar.

Prueba de aceptación:

1. En HIGH se reproduce IDLE en bucle sin desplazar pies.
2. `saludar()` levanta el brazo correcto sin atravesar sombrero.
3. Al alejar a >9m cambia a MEDIA sin salto de altura.
4. Al volver, retoma IDLE.
5. Colores y doble cara iguales que en ALTA.

## 3. Límites y siguiente paso

- Este rig **no deforma malla**: codos y rodillas no doblan, rotan rígidos. Suficiente para idle/saludo/reverencia cozy, insuficiente para caminar convincente.
- No se generan LODs riggeados: MEDIUM/BAJA siguen estáticas a propósito para ahorrar skinning. Si quieres multitud con animación lejana, habrá que riggear MEDIA con el mismo esqueleto.
- Caminar, sentarse y remarcar agarres (Fin/cubo, Flora/cesta, Roca/placas) siguen pendientes de revisión manual con las capturas `RIG_*`.
- No regeneres LODs desde el `_RIG.blend`: el buscador de LODs debe seguir apuntando a `REVISION_02/SM_NPC_*.blend`, no a `RIG/`.

**Orden recomendado:** prueba el rig en `{"LUNA","ROCA","HIELO"}`. Si el saludo no choca con sombrero/capucha y el IDLE no levanta pies, extiende al resto de Raíz antes de tocar Ceniza/Coral/Aurora.