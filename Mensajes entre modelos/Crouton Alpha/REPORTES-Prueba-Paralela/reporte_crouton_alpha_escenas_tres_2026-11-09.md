# Reporte — Auditoría de escenas .tscn y recursos .tres
**Proyecto:** `game/isla-ancestral/scenes/` y `game/isla-ancestral/scripts/` (ámbito ampliado a `game/isla-ancestral/`)
**Alcance real auditado:** 53 escenas del proyecto (sin `addons/gdUnit4`), +16 escenas del addon gdUnit4 (excluidas del análisis), 479 archivos `.tres`, 1 586 archivos `.gd`
**Fecha:** 2026-11-09
**Modelo:** Crouton Alpha
**Método:** parseo estático de texto (regex sobre `[ext_resource]`, `[sub_resource]`, `[node … parent=…]`, `ExtResource()` / `SubResource()`), verificación de existencia en disco de cada ruta `res://`, construcción del grafo de instanciación `PackedScene → PackedScene` y del grafo `script_class → class_name` en `.gd`. Sin apertura de Godot.

---

## 1. ¿Hay escenas .tscn con rutas rotas a recursos que no existen?

**Respuesta: NO.**

- Total de `ext_resource` en las 53 escenas del proyecto: **81** (Script: 73, PackedScene: 6, Resource: 1, AnimationLibrary: 1).
- Rutas rotas: **0**. Toda ruta `res://…` de cada `[ext_resource …]` resuelve a un archivo existente bajo `game/isla-ancestral/`.
- Tampoco hay referencias `uid://` sin resolver ni rutas relativas fuera de `res://` en los `.tscn` del proyecto.

Evidencia de la verificación manual de las 3 escenas clave:

| Escena | `ext_resource` (línea) | Tipo | Destino | Estado |
|---|---|---|---|---|
| `game/isla-ancestral/scenes/player/Player.tscn:3` | `res://scripts/player/player.gd` | Script | existe | OK |
| `game/isla-ancestral/scenes/player/Player.tscn:4` | `res://assets/3d/media/45-Arte3D_jugador_voxel.glb` | PackedScene | existe | OK |
| `game/isla-ancestral/scenes/player/Player.tscn:7` | `res://scripts/animacion/libraries/jugador_lib.tres` | AnimationLibrary | existe | OK |
| `game/isla-ancestral/scenes/main_island.tscn:9` | `res://scenes/player/Player.tscn` | PackedScene | existe | OK |
| `game/isla-ancestral/scenes/main_island.tscn:12` | `res://data/villagers/catalina_oso.tres` | Resource | existe | OK |
| `game/isla-ancestral/scenes/ui/hud.tscn:3-12` | 10 scripts `res://scripts/ui/…` | Script | existen | OK |

Grafo de instanciación `PackedScene` completo (únicas 6 dependencias entre escenas):

- `game/isla-ancestral/scenes/main.tscn` → `scenes/player/Player.tscn`
- `game/isla-ancestral/scenes/main_island.tscn` → `scenes/player/Player.tscn`
- `game/isla-ancestral/scenes/main_simple.tscn` → `scenes/player/Player.tscn`
- `game/isla-ancestral/scenes/main_test.tscn` → `scenes/player/Player.tscn`
- `game/isla-ancestral/scenes/main_test2.tscn` → `scenes/player/Player.tscn`
- `game/isla-ancestral/scenes/player/Player.tscn` → `assets/3d/media/45-Arte3D_jugador_voxel.glb`

Sin excepción: ningún `ext_resource` apunta a un archivo movido o borrado.

## 2. ¿Hay nodos huérfanos o sin padre?

**Respuesta: NO (con las salvedades de forma estándar de Godot y 2 sub-recursos sin usar).**

- Las 53 escenas tienen **exactamente 1 nodo raíz** (el primer `[node …]` sin atributo `parent=`), que es el comportamiento estándar y correcto de `.tscn`. Ejemplo: `game/isla-ancestral/scenes/player/Player.tscn:16` → `[node name="Player" type="CharacterBody3D"]`.
- Ningún nodo hijo (`parent="."` o `parent="TopLeft"`, etc.) tiene padre roto: cada `parent="…"` es el nombre o prefijo de ruta de un nodo anterior definido en el mismo archivo. La auditoría no encontró padres inexistentes en ninguna de las 53 escenas.
- Los nodos con `parent="."` (hijos directos de la raíz) son normales, no huérfanos: `[node name="ModeloVoxel" parent="." instance=ExtResource("2_voxel")]` en `Player.tscn:23` cuelga de la raíz `Player`.

**Hallazgo menor (sub-recursos definidos y nunca referenciados):**

1. `game/isla-ancestral/scenes/main_island.tscn:55` → `[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_controls_d102"]` definido pero sin ningún `theme_override_styles/… = SubResource("StyleBoxFlat_controls_d102")` que lo use. La cadena aparece **1 vez** en el archivo (su propia definición). No rompe nada; es código muerto de UI.
2. `game/isla-ancestral/scenes/npc/npc_agent.tscn:4` → `[sub_resource type="CapsuleMesh" id="1_capsule"]` definido pero sin uso: `CollisionShape3D` usa `SubResource("1_shape")` (línea 16), y ningún `MeshInstance3D` referencia `1_capsule`. Aparece **1 vez** (su definición). La cápsula visual no se instancia.

Ambos son inofensivos en runtime, pero indican edición incompleta.

**Hallazgo menor de formato:** 4 escenas sin `load_steps=` en el header `[gd_scene …]` (Godot lo recalcula al guardar, no es error, pero delata edición manual):

- `game/isla-ancestral/scenes/CameraRig.tscn:1` → `[gd_scene format=3 uid="uid://y7owcvev8t76"]`
- `game/isla-ancestral/scenes/main_island.tscn:1` → `[gd_scene format=3]`
- `game/isla-ancestral/scenes/preview_particles.tscn:1` → `[gd_scene format=3 uid="uid://c4ewhaonnk2g8"]`
- `game/isla-ancestral/scenes/simple_walk.tscn:1` → `[gd_scene format=3]`

## 3. ¿Hay dependencias circulares de instanciación entre escenas?

**Respuesta: NO.**

- Grafo: 53 nodos, 6 aristas (ver §1). No hay ningún ciclo `A → B → A`, ni de longitud >2.
- La única cadena de profundidad 2 es `main*.tscn → Player.tscn → 45-Arte3D_jugador_voxel.glb`, que termina en un `.glb` (no es escena).
- `Player.tscn` es instanciado por 5 escenas `main*`, pero `Player.tscn` no instancia a ninguna de ellas: es un árbol (DAG), no un ciclo.

## 4. ¿Hay archivos .tres con rutas rotas o scripts .gd inexistentes?

**Respuesta: NO.**

- Total de `ext_resource` en los 479 `.tres`: **536**, todos de tipo `Script`, **0 rotos**. Cada `res://scripts/… .gd` existe en disco.
- Total de `script_class` declarados en `.tres`: todos resuelven a un `class_name` definido en algún `.gd` (634 clases registradas). El único falso positivo inicial (`CatalogoCategorias`, en `game/isla-ancestral/data/interacciones/categorias_interaccion.tres`) se resolvió: la clase existe en `game/isla-ancestral/scripts/interacciones/catalogo_categorias.gd:14` (`class_name CatalogoCategorias`).
- Ejemplo representativo: `game/isla-ancestral/data/interacciones/categorias_interaccion.tres:1` declara `script_class="CatalogoCategorias"` y carga `res://scripts/interacciones/categoria_interaccion.gd` + `res://scripts/interacciones/catalogo_categorias.gd`; ambos existen y los 8 sub-recursos `Resource_mv5qm…Resource_jvl1g` son referenciados.
- Los `.tres` de `data/items/item_obj_*.tres` (~250), `data/construccion/piezas/*.tres` (~48), `data/villagers/*.tres`, `data/islas/definiciones/*.tres` y `resources/terrain/terrain_*.tres` comparten el mismo patrón sano: 1 `ext_resource Script` válido + `script_class` válido.

Tampoco se detectan `.tres` que referencien escenas `.tscn` inexistentes, porque ningún `.tres` instancia escenas: solo scripts.

## 5. Acciones de verificación sugeridas (2)

1. **Apertura headless de las 3 escenas clave en Godot 4.x** (`main_island.tscn`, `Player.tscn`, `hud.tscn`) capturando el log: confirmar 0 `Parse Error`, 0 `ExtResource … not found` y 0 `Failed loading script`. Si a futuro aparece una ruta rota, Godot la señala ahí aunque el parseo estático la haya pasado por alto (p. ej. recursos generados por imports `.import`).
2. **Chequeo de clases registradas en editor**: abrir `data/interacciones/categorias_interaccion.tres` y cualquier `data/items/item_obj_anal_*.tres` en el Inspector y verificar que el campo `script_class` no muestre la advertencia *"Script class not found"* (señal de que la clase se movió o su `class_name` cambió sin actualizar el `.tres`). Es la comprobación que este parseo estático no puede hacer al 100% porque depende del registro global del editor.

## Conclusión final

**El estado de escenas y recursos es SANO.** 53 escenas del proyecto con 81 dependencias externas, todas válidas; 479 recursos `.tres` con 536 referencias a scripts, todas válidas; 0 nodos sin padre válido; 0 ciclos de instanciación; 634 `class_name` cubriendo todos los `script_class` usados. Solo hay deuda cosmética — 2 sub-recursos sin usar (`StyleBoxFlat_controls_d102` en `main_island.tscn:55`, `CapsuleMesh 1_capsule` en `npc_agent.tscn:4`) y 4 headers sin `load_steps=` — que no afectan la ejecución pero conviene limpiar en una pasada de mantenimiento.

---
**Archivo y líneas citados como evidencia completa:** el detalle línea por línea de `Player.tscn:1-51`, `main_island.tscn:1-194` y `hud.tscn:1-149` se revisó en la auditoría; los greps de `ext_resource`, `sub_resource` sin uso y `script_class` sin `class_name` dieron los resultados reportados arriba.
