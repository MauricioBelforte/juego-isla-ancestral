# Log 347: M15 Recursos — Iteración 3 (persistencia ISaveProvider + respawn M29 + helper golpe)

**Fecha:** 2026-08-31
**Hora:** 08:25
**Modelo:** GLM (Kilo)
**Plataforma:** Kilo
**Tarea:** Implementar los pendientes de M15 Recursos (persistencia de nodos, respawn con M29, integración de golpe con M13).

## Resumen
M15 iter 3 implementada y validada. Persistencia ISaveProvider M59 con save/restore round-trip de estado de nodos (def_id, posición, estado, golpes restantes, día de respawn). Respawn basado en M29: `evaluar_respawn(dia_actual, estacion_actual)` con filtro de temporada por recurso. Helper `recibir_golpe_en_nodo(nodo, herramienta)` que valida herramienta, aplica golpe, al agotar programa respawn + entrega drops a M14 + emite `recurso_agotado`. Conexión a `GameTime.dia_cambio` para evaluar respawn global. Test headless 0 fallos. Módulo liberado a 🟡 con 5 [?] honestos.

## Cambios realizados

- `game/isla-ancestral/scripts/resources/resource_node.gd`: nuevos campos `respawn_dia_absoluto: int` y `respawn_estacion: int`. Nuevos métodos `programar_respawn(dia)`, `esta_listo_para_respawn() -> bool`, `evaluar_respawn(dia_actual, estacion_actual) -> bool` (vuelve a INTACTO si dia>=respawn y temporada coincide). `configurar()` setea `respawn_estacion` desde la def.
- `game/isla-ancestral/scripts/resources/resource_definition.gd`: nuevo `@export var dias_para_respawn: int = 2`. Nuevo `get_respawn_estacion_int() -> int` (mapeo "primavera"/"verano"/"otono"/"invierno" → 0..3, "todas"/"" → -1).
- `game/isla-ancestral/scripts/resources/resource_manager.gd`:
  - `_registrar_proveedor_guardado()` ahora también conecta `_on_dia_cambio_m29` a `GameTime.dia_cambio` (una vez, guard `_gt_dia_cambio_conectado`).
  - `_on_dia_cambio_m29(info)` llama `_evaluar_respawn_global()`.
  - `_evaluar_respawn_global()` itera `_nodos_activos` y llama `nodo.evaluar_respawn(dia_absoluto, estacion)`.
  - `get_save_data()` v2: array de nodos con `def_id, pos, estado, golpes_restantes, respawn_dia`.
  - `restore_save_data(data)` valida `version >= 2` y setea `_estado_guardado_pendiente`.
  - `consumir_estado_guardado_para(def_id, pos) -> Dictionary` (match por distancia <0.5m, consume una vez).
  - `registrar_nodo(nodo)` / `desregistrar_nodo(nodo)`.
  - `recibir_golpe_en_nodo(nodo, herramienta) -> bool` (valida `def.es_accesible_con(herramienta, true)`, aplica golpe, al agotar programa respawn con `gt.dia_absoluto() + def.dias_para_respawn`, entrega drops con `entregar_drops`, emite `recurso_agotado`).
- `game/isla-ancestral/scripts/resources/resource_spawner.gd`: `instanciar_nodo()` ahora aplica el estado guardado vía `consumir_estado_guardado_para` (match por pos) y registra el nodo en el manager.
- `game/isla-ancestral/scripts/resources/test_recursos_persistencia.gd` (nuevo, 109 líneas): 4 tests — persistencia round-trip, respawn con día+estación, helper golpe+drops, registro/lista de nodos. Helper `_crear_nodo_registrado` que ancla al root (necesario para `global_position` en headless).

## Decisiones

- **`global_position` requiere nodo en el árbol:** en Godot 4, `Node3D.global_position` en un nodo NO dentro del SceneTree emite `ERR_FAIL_COND_V_MSG` y devuelve `(0,0,0)`. El test usa `root.add_child(nodo)` para que `global_position` funcione. Documentado como gotcha.
- **Sin cableado M13→M15 directo:** M13 `tool_controller.gd` usa `VoxelTool.raycast` (terreno voxel) y NO detecta `ResourceNode` (Node3D con Area3D). El helper `recibir_golpe_en_nodo` está listo y testeado; el cableado real (un RayCast3D adicional en M13, o `input_event` en el Area3D del ResourceNode) es un [?] con dueño. NO toqué M13 (es de Hy3).
- **Conexión a `GameTime.dia_cambio`:** el manager se conecta una vez y reacciona a cada cambio de día evaluando respawns. Guard `_gt_dia_cambio_conectado` para evitar doble conexión.
- **Persistencia aplicada en el spawner:** el spawner, al instanciar, consulta el estado guardado (por def_id + pos cercana) y aplica estado/golpes/respawn_dia. Así save/load funciona sin reescribir el spawner.

## Verificación

- `godot --headless --script res://scripts/resources/test_recursos_persistencia.gd` → `=== TEST M15 ITER3: 0 fallo(s) ===` (13 checks).
- Regresión M16 Crafting: 0 fallos.
- Regresión M31 Ciclo Día/Noche: 12/0 OK.
- Regresión M15 iter 2 (`test_recurso_nodo.gd`): 0 fallos.
- Sin SCRIPT ERROR de mis archivos.

## Hallazgos / errores documentados

- **`Node3D.global_position` requiere estar en el árbol (Godot 4):** los tests deben `root.add_child(nodo)` antes de setear/leer `global_position`. Candidato a 07-GUIA-GODOT §9 (pendiente para iter futura).
- **M13 no detecta ResourceNode:** M13 usa `VoxelTool.raycast` que opera sobre el buffer voxel (chunks), no sobre nodos Node3D. El Area3D del ResourceNode no se intercepta. Para cableado M13→M15 hay dos opciones: (a) añadir un `RayCast3D` físico en M13 que también detecte colisionadores Node3D; (b) que el Area3D del ResourceNode use `input_event` cuando el jugador está cerca. Documentado como [?] con dueño.

## Archivos modificados/creados
- `game/isla-ancestral/scripts/resources/resource_node.gd` (respawn fields + methods)
- `game/isla-ancestral/scripts/resources/resource_definition.gd` (dias_para_respawn + get_respawn_estacion_int)
- `game/isla-ancestral/scripts/resources/resource_manager.gd` (ISaveProvider real + respawn + helper golpe)
- `game/isla-ancestral/scripts/resources/resource_spawner.gd` (aplica estado guardado + registra nodo)
- `game/isla-ancestral/scripts/resources/test_recursos_persistencia.gd` (nuevo)
- `DOCUMENTACION/15-Recursos/plan-actual/05-Checklist.md` (sección N)
- `DOCUMENTACION/15-Recursos/plan-actual/04-Codigo.md` (Notas + Historial)
- `CHECKLIST-GLOBAL.md` (M15 🟡 Liberado)
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (§17 M15 🟡)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (M15 🟡 Liberado)
- `Logs/ULTIMO_NUMERO.txt` → 305

## Pendientes honestos (5 [?] con dueño)
1. **Cableado M13→M15** (Hy3/M13) — el helper existe; falta el trigger desde el input del jugador o el raycast de M13.
2. **Meshes del arte** (M45) — placeholders funcionales ahora.
3. **Recolección en área 3×3** (M13/M15) — actualmente 1×1.
4. **Persistencia de ResourceSpawner** (regiones + presupuesto) — solo los nodos individuales persisten.
5. **Test de `dia_cambio` en runtime** que dispare respawn vía la señal real de M29.
