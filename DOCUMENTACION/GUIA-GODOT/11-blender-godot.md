# Blender → Godot — Flujo de Assets

> **Modelo:** MiMo V2.5
> **Plataforma:** OpenCode
> **Fecha:** 2026-09-09
> **Fuente:** OBSOLETOS/07-GUIA-GODOT.md §11
> **Validado en:** Isla Ancestral — Godot 4.7.2

---

## 1. Objetos animados en Blender

### Escena en Blender

- Usar **Actions** para animaciones (caminar, idle, atacar).
- Cada Action = un Clip de Animation en Godot.
- Asignar **solo el'action relevante** al objeto que se exporta.
- Si hay más de un Action por objeto, Godot exporta todos como AnimationLibrary.

### Exportación

```python
# En Blender
bpy.ops.export_scene.gltf(
    filepath="output/model.glb",
    export_animations=True,
    export_nla_strips=True,  # Exportar Actions como clips
    export_skins=True,
)
```

### Importación en Godot

- Godot importa `.glb` como escena AnimationPlayer con AnimationLibrary.
- Cada Action de Blender se convierte en un Animation en la librería.

---

## 2. Animación procedural desde GDScript

### Estructura de nodos

```
Armature
├── Body (MeshInstance3D)
│   ├── Head (BoneAttachment3D)
│   ├── LeftArm (BoneAttachment3D)
│   └── RightArm (BoneAttachment3D)
└── AnimationPlayer
```

### Ejemplo: rotar brazos desde script

```gdscript
extends Node3D

@onready var left_arm: BoneAttachment3D = $Body/LeftArm
@onready var right_arm: BoneAttachment3D = $Body/RightArm
var _time: float = 0.0

func _process(delta: float) -> void:
    _time += delta
    # Rotar brazos con seno para movimiento suave
    left_arm.rotation.z = sin(_time * 2.0) * 0.3
    right_arm.rotation.z = -sin(_time * 2.0) * 0.3
```

### Notas importantes

- `BoneAttachment3D` es un nodo que se bindea a un hueso del Armature.
- Las rotaciones son locales al hueso padre.
- Para animaciones complejas, usar AnimationPlayer en vez de procedural.

---

## 3. Optimización de assets

### Blender

- Mantener polycount bajo (< 5000 triángulos por modelo de gameplay).
- Usar LODs si el modelo es detallado.
- Comprimir texturas (BC7/ASTC).
- Un solo material por modelo si es posible.

### Godot

- Importar con preset `game` si está disponible.
- Asignar materials en el editor para reutilizar.
- Usar `MultiMeshInstance3D` para objetos repetidos (árboles, rocas).
- Habilitar frustum culling y occlusion culling.

---

## 4. Naming conventions

| Elemento | Convención | Ejemplo |
|---|---|---|
| Modelo | `SM_Nombre` | `SM_Player.glb` |
| Material | `MAT_Nombre` | `MAT_Trees_Bark.tres` |
| Textura | `T_Nombre_Type` | `T_Player_Diffuse.png` |
| Animación | `anim_nombre` | `anim_walk.tres` |

---

## 5. Troubleshooting

| Problema | Solución |
|---|---|
| Modelo aparece en el origen | Verificar pivote en Blender (Origin to Geometry) |
| Modelo muy grande/muy pequeño | Ajustar escala en Blender (1 unidad = 1 metro) |
| Animaciones no importan | Verificar que Action esté asignada al objeto |
| Materiales no aparecen | Asignar materials en Godot, no en Blender |
| Modelo roto al importar | Verificar normales en Blender (recalculate outside) |
