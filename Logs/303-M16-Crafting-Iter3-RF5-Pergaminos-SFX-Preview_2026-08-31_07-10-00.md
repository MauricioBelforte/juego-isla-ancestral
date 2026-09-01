# Log 303: M16 Crafting — Iteración 3 (RF5 estacional, pergaminos M14, SFX/VFX procedural, preview RF9)

**Fecha:** 2026-08-31
**Hora:** 07:10
**Modelo:** GLM (Kilo)
**Plataforma:** Kilo
**Tarea:** Resolución de los 4 pendientes de M16 (Crafting) reportados en iter 2 por Deepseek V4 Flash (Kilo).

## Resumen
Se cierran los 4 pendientes del módulo M16. RF5 estacional implementado con integración real a M29 (GameTime), RF14 pergaminos M14 con helper `usar_pergamino` + señal `pergamino_consumido`, RF12 feedback procedural (beep AudioStreamWAV + partículas doradas CPUParticles2D + notificación) desacoplado en `CraftingFeedback`, RF9 preview V1 (swatch hash + label del resultado) en la UI. Test headless 0 fallos. Regresión M31 ciclo día/noche 12/0 OK. Módulo sigue 🔵 (8 [?] con dueño).

## Cambios realizados

- `game/isla-ancestral/data/balance/crafting.json`: añadido campo `temporadas` a `rec_ensalada_bayas` (["primavera","verano"]) y `rec_talisman_ancestral` (["otono","invierno"]).
- `game/isla-ancestral/scripts/crafting/crafting_recipe.gd`: nuevo `@export var temporadas: Array[String]`, `ESTACIONES_ANYO_TEXTO` const (mapeo texto→enum M29), `es_fabricable_ahora(estacion: int) -> bool`, `etiquetas_temporadas()`.
- `game/isla-ancestral/scripts/crafting/crafting_service.gd`:
  - Cache de estación: `_gt` (GameTime), `_estacion_actual`, `_refrescar_estacion_actual()`, conexión a `estacion_cambio`.
  - `_recipe_desde_datos` plumbed de `temporadas`.
  - `recetas_por_estacion` filtra por `es_fabricable_ahora`; nueva `recetas_conocidas_estacion` (todas, incluso bloqueadas) y `receta_bloqueada(rec_id)`.
  - `max_craftable`/`puede_craft`/`craft` respetan temporada; `craft` emite `receta_bloqueada_estacion` y `crafting_failed` con motivo `temporada_cerrada` (sin consumo, RF11).
  - Nueva señal `pergamino_consumido(rec_id, aprendido)`.
  - Helper `usar_pergamino(item_id: String) -> Dictionary` (prefijo `pergamino_rec_`).
  - `CraftingFeedback` instanciado como hijo del servicio en `_ready` vía `load().new()`.
- `game/isla-ancestral/scripts/crafting/crafting_feedback.gd` (nuevo, 145 líneas): SFX procedural con `AudioStreamWAV` (seno 660Hz/880Hz, envolvente attack/release anti-click, 16-bit 22050Hz mono), VFX `CPUParticles2D` dorado en `CanvasLayer` propia, notificación cozy vía `NotificationService` con fallback a `print`.
- `game/isla-ancestral/scripts/crafting/crafting_ui.gd`: preview V1 — `_preview_box` (HBoxContainer) con `_preview_icon` (ColorRect 28×28, color hash determinista del `resultado_id`) y `_preview_label` (`→ {resultado_id}`). Aviso `FUERA_TEMPORADA` en ámbar cuando la receta está bloqueada.
- `game/isla-ancestral/scripts/crafting/test_crafting.gd`:
  - 3 tests nuevos: `_test_estacional_rf5` (RF5, 11 checks), `_test_pergamino_m14` (RF14, 4 checks), `_test_feedback_cargado` (RF12, 3 checks).
  - `_test_coste_ao` actualizado para forzar `_gt._mes=9` (otoño) ya que el talismán ahora es estacional.

## Decisiones

- **GameTime vía `get_node_or_null`:** aplicado el patrón documentado en 07-GUIA-GODOT §9.51 (descubierto en M31). Cero errores de parse.
- **CraftingFeedback como hijo del servicio (autoload):** evita modificar `project.godot` y mantiene la cohesión: el feedback se conecta automáticamente a las señales del servicio en `_ready`.
- **SFX procedural en memoria:** `AudioStreamWAV` con datos PCM generados. No requiere archivos de audio externos, funciona offline y en headless. El `AudioStreamPlayer` reproduce si hay bus de audio; en headless no suena pero no errora.
- **SFX con ataque/release:** evita el click inicial/final típico de ondas senoidales cortas.
- **Preview V1 (swatch + label):** honesto y testeable. El preview 3D real requiere M45 (🟢 sin núcleo). Se documenta el hash determinista para reproducibilidad.
- **RF5 oculta sin borrar conocimiento:** las recetas conocidas pero fuera de temporada NO aparecen en `recetas_por_estacion` (lista fabricable ahora) pero SÍ en `recetas_conocidas_estacion` (para mostrar aviso). El conocimiento persiste (invariante §1.3.4 del diseño).

## Verificación

- `godot --headless --path game/isla-ancestral --script res://scripts/crafting/test_crafting.gd` → `=== TEST M16 CRAFTING: 0 fallo(s) ===`. 23 checks totales (15 previos + 8 nuevos de iter 3).
- `godot --headless --script res://scripts/world/test_ciclo_dia_noche.gd` → `=== Resumen: 12 checks, 0 fallos ===` (regresión M31 OK).
- Sin SCRIPT ERROR de mis archivos. El SCRIPT ERROR `_verificar_integridad_dominios` que aparece al inicio es preexisting (otro autoload), no afecta los tests.

## Hallazgos / errores documentados

- **`Signal.is_valid()` no existe en Godot 4** (descubierto en iter 3). Candidato a agregar a 07-GUIA-GODOT §9 (revisión pendiente para iter futura). Solución: conectar directo sin guarda previa.
- **Talismán estacional rompe test previo:** al añadir `temporadas` al talismán, el test `_test_coste_ao` que corre en primavera (estación por defecto) ahora falla correctamente por RF5. Actualizado el test para forzar otoño — comportamiento esperado.

## Archivos modificados/creados
- `game/isla-ancestral/data/balance/crafting.json` (temporadas)
- `game/isla-ancestral/scripts/crafting/crafting_recipe.gd` (RF5)
- `game/isla-ancestral/scripts/crafting/crafting_service.gd` (RF5 + pergaminos + feedback)
- `game/isla-ancestral/scripts/crafting/crafting_feedback.gd` (nuevo)
- `game/isla-ancestral/scripts/crafting/crafting_ui.gd` (RF9 preview)
- `game/isla-ancestral/scripts/crafting/test_crafting.gd` (3 tests + ajuste coste_ao)
- `Logs/ULTIMO_NUMERO.txt` → 303
- `CHECKLIST-GLOBAL.md` (M16 nota iter 3, M31 liberado)
- `DOCUMENTACION/16-Crafting/plan-actual/05-Checklist.md` (sección M)
- `DOCUMENTACION/16-Crafting/plan-actual/04-Codigo.md` (Notas del Agente iter 3)
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (sección 17: M31 liberado, M16 🔵)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (M31 liberado, M16 claim iter 3)

## Pendientes honestos (siguientes iteraciones)
- M14 use_item → `Crafting.usar_pergamino` (integración M14, 🟡).
- Preview 3D real con `ItemData.preview_mesh` (M45 🟢 sin núcleo).
- SFX master bus + librería (M91 🟢 sin núcleo).
- VFX avanzados GPU (M52 🟢 sin núcleo).
- Tiendas venden pergaminos (M38 🟡).
- Tests de cambio de temporada en runtime.
- Migración `coste_recursos` → `materiales` (alinear JSON con diseño §1.2).
- Distinguir feedback dorada en recetas secretas vs ancestrales (RF3).
