# Log 815: M13 iter 4 — persistencia hotbar M59 + cableado M13→M15

**Fecha:** 2026-09-10
**Hora:** 00:58 (2026-09-11)
**Modelo:** GLM-5.3
**Plataforma:** Kilo Code

## Resumen

Iteración 4 del módulo **M13-Herramientas** (segunda tarea del backlog personal, elegida porque su tarea estrella cerraba además el `[?]` bloqueador que dejé en M15 iter 4 — integración entre sistemas, mi perfil §16.4). Se implementaron dos funcionalidades: (1) **T-019: persistencia del hotbar de herramientas en M59** vía nuevo `ToolsSaveProvider`, y (2) **el cableado M13→M15**: el golpe E del jugador ahora detecta `ResourceNode`s de M15 y deriva a `ResourceManager.recibir_golpe_en_nodo()` — el jugador ya puede talar el árbol de `madera_roble` con el hacha y recibir drops reales en el inventario M14.

## Cambios Realizados

1. **`tools_save_provider.gd` (NUEVO):** clase `ToolsSaveProvider` (RefCounted, duck-typing M59) con sección "herramientas_m13". Serializa el hotbar completo (`ToolData.serializar()`: tipo/nivel/durabilidad/mejoras) + índice activo, formato versionado `{"version": 1}`. Restore vía `ToolData.deserializar()` + callbacks al player. Slots null preservados; datos vacíos NO pisan el hotbar por defecto.
2. **`tool_data.gd`:** nuevo `nombre_id() -> StringName` + constante `IDS` (pico/hacha/pala/azada/regadera/cana/martillo/tijeras/lupa) — puente de contrato con `ResourceDefinition.herramienta_requerida` de M15 (verificado: `&"pico"`, `&"hacha"` coinciden).
3. **`tool_controller.gd`:** `try_extract()` ahora intenta primero `_intentar_golpe_recurso_m15()` — lookup de ResourceNode activo ≤1.5 m del punto de mira (hit del voxel o posición del controller) vía `spawner.obtener_nodos()` → `ResourceManager.recibir_golpe_en_nodo(nodo, herramienta.nombre_id())`. Regla cozy: herramienta equivocada → `golpe_fallido` SIN caer al voxel de detrás; nodo AGOTADO excluido del lookup.
4. **`player.gd`:** `_registrar_provider_herramientas()` registra el provider en SaveManager con accessors duck-typing (`_get_hotbar_index`, `_set_hotbar_index`, `_restaurar_hotbar`). Flujo existente intacto (§15: flujo separado).
5. **`test_herramientas_iter4.gd` (NUEVO):** 3 tests, 24 checks — provider round-trip (PICO HIERRO dur 137+afilada, MARTILLO infinita, slot null, índice 2 → restore campo a campo), contrato nombre_id↔M15 (hacha→madera OK, pico→piedra OK, hacha→piedra RECHAZADA), cableado end-to-end (pico agota nodo M15 en 2 golpes → drops inventario M14 → respawn programado).
6. **M15 actualizado en cascada:** el `[?]` "Cableado M13→M15" de 05-Checklist M15 (sección P.2) pasa a `[x]` con referencia a este log; nota en 04-Codigo M15.
7. **Saneamiento §28:** BOM preexistente removido de `tool_controller.gd` (re-testeado 0 fallos tras el cambio).

## Verificación (QA numérico)

| Test | Resultado |
|---|---|
| test_herramientas_iter4.gd (nuevo) | **0 fallos** (24 checks) |
| test_herramientas.gd (Fase 3, 36 combos) | 0 fallos |
| test_recursos_spawner_runtime.gd (M15 iter 4) | 0 fallos |
| test_recursos_persistencia.gd (M15 iter 3) | 0 fallos |
| test_mineria.gd (M35) | 0 fallos |
| test_nivel_herramienta.gd (M71/M13) | 0 fallos |
| test_autosave_m59.gd (SaveManager) | 0 fallos |

Godot 4.7.2.stable headless. UTF-8 sin BOM verificado en los 5 archivos GDScript tocados.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/tools/tools_save_provider.gd` (nuevo)
- `game/isla-ancestral/scripts/tools/tool_controller.gd` (cableado M15 + saneamiento BOM)
- `game/isla-ancestral/scripts/tools/tool_data.gd` (nombre_id + IDS)
- `game/isla-ancestral/scripts/tools/test_herramientas_iter4.gd` (nuevo)
- `game/isla-ancestral/scripts/player/player.gd` (registro provider + accessors)
- `DOCUMENTACION/13-Herramientas/plan-actual/05-Checklist.md` (sección J iter 4 + D.12 cerrado + firma)
- `DOCUMENTACION/13-Herramientas/plan-actual/04-Codigo.md` (Notas del Agente iter 4)
- `DOCUMENTACION/15-Recursos/plan-actual/05-Checklist.md` ([?] cableado → [x] + nota D.71)
- `DOCUMENTACION/15-Recursos/plan-actual/04-Codigo.md` (actualización post-Log 813)
- `CHECKLIST-GLOBAL.md` (fila M13 → 🟡 84/120)
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (M13 liberado)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (M13 liberado)
- `DOCUMENTACION/TAREAS-POR-MODELO/glm-5.3/13-Herramientas/checklist.md` (T-019 → [x])

## Pendientes que quedan ([?] honestos)

1. **Verificación in-game V1 del usuario:** el test headless valida la cadena lógica, pero el "feel" de golpear un árbol visible con E necesita la mano del usuario (soy solo-texto).
2. **Puntería fina:** el lookup usa el hit del voxel como punto de mira; recurso flotante sin voxel detrás usaría la posición del controller. Refinamiento [?] J.2.

## Lección aprendida (para GUIA-GODOT)

- Al testear agotamiento de recursos M15: usar `nodo.golpes_restantes` como límite del bucle de golpes, no un golpe fijo — 1er intento del test falló porque piedra_caliza requiere 2 golpes.

## Notas

- Reserva 815 (protocolo v2) consumida por este log.
- M13: 84 [x] / 34 [ ] / 2 [?] de 120 tras iter 4.
- M15 en cascada: el [?] bloqueador está cerrado; quedan 3 [?] (meshes M45, área 3×3 M13, estacion_cambio).
- Ambos módulos liberados a 🟡, listos para QA cruzado §21.8 (Hy3 por regla).
