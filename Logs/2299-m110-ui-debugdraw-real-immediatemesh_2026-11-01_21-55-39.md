# Log 2299 - M110-UI: capa visual de debug REAL (Depurador3D sobre ImmediateMesh)

- **Fecha:** 2026-11-01 21:55
- **Agente:** DeepSeek-V4.1-Flash (WorkBuddy)
- **Modulo:** M110-Debug-Menu (seccion M110-UI)
- **Rama:** 2 (no habia mensaje nuevo del director: tracker 492 = max NN del canal)
- **Tarea:** item 17 de la COLA ACTIVA ("M110 b2: continuar"), cluster pendiente de la capa visual.

## 1. Premisa medida antes de escribir

Medido sobre `DOCUMENTACION/110-Debug-Menu/plan-actual/05-Checklist.md`:

- marcas: **179 [x] / 46 [ ] / 0 [?] = 225** (coincide con la nota de la tanda del 2026-10-27).
- La cola activa del BACKLOG-MASTER tiene **0 items `[ ]`** y **5 `[->]`**; el unico con
  trabajo abierto propio es el 17 (M110-UI, 46 pendientes). Los otros 4 estan bloqueados
  por decision del director, por `NO TOCAR` (M90) o por dueno externo.

## 2. Hallazgo: la capa visual anterior era DECORATIVA y la spec pide una API inexistente

`03-Diseno.md` seccion 4 (Debug Visualizer) escribe pseudocodigo sobre
`DebugDraw.draw_shape_3d`, `DebugDraw.draw_box_3d`, `DebugDraw.draw_line_3d` y
`DebugDraw.draw_text_3d`.

MEDIDO en Godot 4.7.2-stable (sonda headless, borrada despues):

    Engine.has_singleton("DebugDraw")     -> false
    ClassDB.class_exists("DebugDraw")     -> false
    ClassDB.class_exists("ImmediateMesh") -> true

`DebugDraw` es un addon de terceros, NO una API del motor. Implementar la seccion 4 al pie
de la letra es imposible.

Y los criterios de enumeracion de la misma seccion tampoco existen en el repo:

    add_to_group("colliders")  -> 0 ocurrencias
    add_to_group("entities")   -> 0 ocurrencias
    add_to_group("npcs")       -> 1 (solo en un script de QA, qa_m21_puente_m64.gd)
    add_to_group("player")     -> 7
    func get_ai_state / get_hitbox -> 0 funciones

Conclusion: 3 de las 5 capas habrian enumerado **0 nodos** y el visualizador se veria
"terminado". Ese es el falso verde de esta tarea.

La version anterior de `debug_visualizer.gd` (agnes-3-flash, 2026-10-09) confirmaba el
riesgo: creaba 5 `BoxMesh` fijos y los posaba al lado del jugador con tamanos literales
(`MAX_CHUNKS_RADIO * 8.0`). No enumeraba ni un nodo del mundo.

## 3. Entregado

### `scripts/debug/depurador_3d.gd` (NUEVO)

Constructor de lineas 3D inmediatas: el equivalente NATIVO de `DebugDraw` en Godot 4.

- `linea(a, b, color)`, `caja(aabb)`, `caja_transformada(tf, aabb)`, `esfera(centro, r)`,
  `camino(PackedVector3Array)`, `limpiar()`, `cerrar()`.
- Contadores medibles: `segmentos()`, `vertices()`, `superficies()`, `rechazados()`.
- **Guardia de finitud:** `ImmediateMesh.surface_add_vertex()` acepta `Vector3(NAN,0,0)`
  EN SILENCIO (medido). Un solo NaN envenena el mesh sin error. Toda coordenada no finita
  se rechaza y se cuenta.

### `scripts/debug/debug_visualizer.gd` (REESCRITO, +432/-67)

Enumera artefactos REALES, no grupos inexistentes:

| capa | que enumera (real) | como dibuja |
|---|---|---|
| colliders | nodos `CollisionShape3D` por CLASE | caja o esfera de la forma real |
| chunks | nodos `VoxelTerrain` presentes | AABB del nodo (granularidad declarada) |
| navigation | `NavigationAgent3D` | `get_current_navigation_path()` real |
| hitboxes | nodos `Area3D` | AABB de sus `CollisionShape3D` hijos |
| ai_states | nodos con `get_state_machine()` | marcador + estado REAL leido |

- Formas no dibujables como alambre (capsula, cilindro) se **cuentan** en `no_dibujables()`,
  no se inventan.
- Gate L268: con Debug Menu presente el menu es la UNICA fuente de verdad
  (`visualizacion_activa()`, `debug_menu.gd:514`); sin menu, toggle local + visibilidad.
  Sin menu -> no se dibuja nada (fail-closed).
- `capa_ciega(tipo)` distingue "no hay nada que dibujar" de "el visualizador esta roto".
- L274: `_registrar_servicio()` / `_desregistrar_servicio()` publican y liberan el contrato
  `debug_visualizer` en el ServiceRegistry (mismo patron que `debug_menu.gd`).

### `scripts/debug/test_debug_visualizer_real_m110.gd` (NUEVO)

8 bloques A-H. **66 checks / 0 fallos / EXIT 0 x3**, piso `CHECKS_MINIMOS = 66` MEDIDO.

## 4. Evidencia

- Suite nueva: **66 / 0 / EXIT 0 x3** (piso 66 medido, no estimado).
- Regresion M110 (9 suites): **326 checks / 0 fallos / EXIT 0** en todas.
  - test_m110_ui 17, test_m110_ui2 14, test_m110_ui3 17, test_debug_m110 18,
    test_m110_iter_atria 27.
  - test_debug_menu_headless 22, test_debug_menu_config_m110 75,
    test_debug_menu_control_m110 75, test_debug_menu_entorno_m110 61.
- **3 sondas EN ROJO**, con sha256 restaurado byte-exacto en las 3:
  - S1 aborto de RUNTIME dentro del bloque C -> EXIT 1, nombra el bloque C, dispara el piso
    (62 < 66) y D/E/F/G/H retoman sin colgarse.
  - S2 piso 99 -> EXIT 1 ("solo 66 checks ejecutados, minimo medido 99").
  - S3 gate L268 eliminado -> 5 fallos nombrados (B1, B3, B4, B7, H9), EXIT 1.

## 5. Defectos PROPIOS corregidos en la misma vuelta

1. `free()` sobre `Depurador3D` (es `RefCounted`): lanzaba SCRIPT ERROR y abortaba el bloque
   ANTES de `_fin(bloque)`, asi que el bloque se reportaba como "NO se ejecuto". Es
   exactamente la razon por la que `_fin()` va al final del CUERPO y no en el runner.
2. `NavigationAgent3D` **extiende Node, no Node3D**: no tiene `global_position`. Acceder
   lanzaba SCRIPT ERROR. La posicion sale del padre `Node3D` que lo hospeda.
3. Doble compuerta (`_activo` local Y toggle del menu): con menu real las dos condiciones
   podian discrepar y la capa no dibujaba aunque el checkbox estuviera encendido. Ahora el
   menu es la unica fuente de verdad y `configurar_manual()` empuja el cambio a su
   `toggle_<tipo>()`.
4. El cache de clases globales NO resuelve `Depurador3D` bajo `--headless --script`
   (`Parse Error: Could not find type`). Se resolvio con `preload()` por ruta.

## 6. Marcas

**0 flips aplicados** (el `05-Checklist.md` de M110 lo toca la directora). Propuestos:

- L126 `DebugDraw para visualizaciones` -> `[x]` (existe `depurador_3d.gd`).
- L172 `Integracion DebugDraw de Godot` -> `[x]` con la nota de que `DebugDraw` no existe
  en 4.7.2 y se usa el equivalente nativo `ImmediateMesh`.
- L268 `Visualizaciones solo si visible` -> `[x]` (gate implementado y probado B1-B7).
- L274 `Registrar DebugVisualizer` -> `[x]` (`_registrar_servicio()` + H14).

Con los 4: **183 [x] / 42 [ ] = 225**.

## 7. Pendiente / pedidos al director

1. Aplicar los 4 flips propuestos y actualizar la fila 110 del CHECKLIST-GLOBAL.
2. Cablear `test_debug_visualizer_real_m110.gd` en `quality.yml` (NO TOCAR para mi).
3. La granularidad de `chunks` es "nodo VoxelTerrain", no bloque: cerrar el pendiente
   requiere que el addon exponga AABB por bloque (o que M07 lo publique).
4. `Totales` del 05 de M110: verificar contra 179/46/0 medido (drift preexistente).
5. Reposicion de la COLA ACTIVA: **0 items pendientes** (11.a vuelta que lo reporto).

## 8. Limites respetados

**0 commits / 0 push / 0 flips / 0 auto-sellos 21.8.** No toque `CHECKLIST-GLOBAL.md`,
`quality.yml`, `AGENTS.md`, `project.godot` ni el `05-Checklist` de ningun modulo.
Sondas de exploracion borradas. Pool de canal NO tocado (sigue roto: head 423 vs 496).
