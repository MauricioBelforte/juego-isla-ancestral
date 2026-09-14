# Log 813: M15 iter 4 — persistencia del ResourceSpawner + test runtime de respawn

**Fecha:** 2026-09-10
**Hora:** 23:40
**Modelo:** GLM-5.3
**Plataforma:** Kilo Code

## Resumen

Iteración 4 del módulo **M15-Recursos** (elegido del backlog personal `TAREAS-POR-MODELO/glm-5.3/` según perfil de capacidades §16 de la guía 10: persistencia + lógica determinista + verificación). Se cerraron **2 de los 5 `[?]`** heredados de la iter 3 (Log 305): la persistencia del `ResourceSpawner` y el test de respawn en runtime vía la señal REAL `GameTime.dia_cambio`. Además se cerraron ítems O.2/O.3/O.4/O.6, L.6 y N.6 del checklist base del módulo. Previo a bloquear se verificó ausencia de colisión en los 5 registros (CHECKLIST-GLOBAL, ESTADO-PARALELO, 05-Checklist, reservas de log, guía 08).

## Cambios Realizados

1. **`resource_spawner.gd` (iter 4):**
   - `planificar_region()` ahora registra `_regiones[region_id] = {centro, nodos[{def_id, x, z}]}` y es **idempotente** (no duplica región ya planificada/restaurada).
   - `get_save_data()`: formato versionado `{"version": 1, "regiones": ...}`; serializa **SOLO nodos no-intactos** (estado, golpes_restantes, respawn_dia) — los intactos se regeneran por planificación determinista (guardado chico).
   - `restore_save_data()`: re-instancia nodos guardados con estado aplicado + `_actualizar_mesh()`; marca `_regiones_restauradas` (anti-duplicación al poblar).
   - Helpers: `_buscar_nodo_por_def_y_pos()` (anclaje por posición, no node_id inestable), `region_planificada()` (consulta QA), `get_section_name()` = "resource_spawner".
2. **`resource_manager.gd`:** `_registrar_proveedor_guardado_spawner()` — el spawner persiste como **sección M59 propia** (contrato duck-typing verificado contra `save_snapshot.register_provider` real). Saneamiento §28: BOM UTF-8 preexistente removido (sin cambio semántico).
3. **`test_recursos_spawner_runtime.gd` (NUEVO):** 3 tests, 17 checks — round-trip completo del spawner (planificar→agotar→save→restore→verificar→anti-duplicación), idempotencia de planificar, y **respawn vía señal real**: nodo AGOTADO vencido + `GameTime.avanzar_hasta(0,10)` cruza medianoche REAL de M29 → `dia_cambio` del motor → `_evaluar_respawn_global()` → nodo vuelve a INTACTO. Sin mocks.
4. **Documentación sincronizada (4 registros):** `05-Checklist.md` (sección P iter 4 + ítems cerrados + firma), `04-Codigo.md` (Notas del Agente iter 4 + firma), `CHECKLIST-GLOBAL.md` (fila M15 → 🟡 Liberado 63/212), `08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (reserva liberada), `ESTADO-PARALELO.md` (liberado), checklist personal `TAREAS-POR-MODELO/glm-5.3/15-Recursos/` (T-152, T-153 → [x]).

## Verificación (QA numérico — agente solo-texto, sin visión)

| Test | Resultado |
|---|---|
| test_recursos_spawner_runtime.gd (iter 4, nuevo) | **0 fallos** (17 checks) |
| test_recursos.gd (iter 1, regresión) | 0 fallos |
| test_recurso_nodo.gd (iter 2, regresión) | 0 fallos |
| test_recursos_persistencia.gd (iter 3, regresión) | 0 fallos |
| test_mineria.gd (M35, regresión — depende de ResourceManager) | 0 fallos |
| test_crafting.gd (M16, regresión — consume recursos) | 0 fallos |

Godot 4.7.2.stable headless. UTF-8 sin BOM verificado en los 3 archivos GDScript.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/resources/resource_spawner.gd` (modificado — iter 4)
- `game/isla-ancestral/scripts/resources/resource_manager.gd` (modificado — registro proveedor spawner + saneamiento BOM)
- `game/isla-ancestral/scripts/resources/test_recursos_spawner_runtime.gd` (nuevo)
- `DOCUMENTACION/15-Recursos/plan-actual/05-Checklist.md` (sección P + ítems + firmas)
- `DOCUMENTACION/15-Recursos/plan-actual/04-Codigo.md` (Notas del Agente iter 4 + firma)
- `CHECKLIST-GLOBAL.md` (fila M15)
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (reserva M15 liberada)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (entrada M15 liberada)
- `DOCUMENTACION/TAREAS-POR-MODELO/glm-5.3/15-Recursos/checklist.md` (T-152, T-153 → [x])

## Pendientes que quedan con dueño ([?] honestos)

1. Cableado M13→M15 (heredado iter 3 — dueño Hy3/M13): `RayCast3D` adicional o `input_event` en Area3D.
2. Meshes del arte (M45/M47).
3. Recolección en área 3×3 (M13).
4. Handler `estacion_cambio` para respawn masivo de estación ([?] nuevo identificado honestamente en P.2).

## Notas

- Reserva 813 (protocolo v2) consumida por este log.
- Conteo checklist M15 tras iter 4: 63 [x] / 142 [ ] / 7 [?] de 212.
- El anclaje del save del spawner es por **posición** (def_id + XY ±0.5 m), no por node_id: los node_id no son estables entre sesiones.
- Módulo liberado a 🟡; listo para QA cruzado §21.8 por modelo distinto (Hy3 por regla).
