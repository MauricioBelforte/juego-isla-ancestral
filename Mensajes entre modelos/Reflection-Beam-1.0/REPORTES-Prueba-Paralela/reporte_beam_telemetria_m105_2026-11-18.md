# Auditoría de Consistencia de Contadores — M105 Telemetría de Gameplay

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-11-18
**Alcance:** `game/isla-ancestral/scripts/telemetry/telemetry_director.gd`, `telemetry_bridge.gd`, consumidores cruzados (`analytics_director.gd`), verificador `scripts/verificar_hooks_m105.py`, checklist `DOCUMENTACION/105-.../plan-actual/05-Checklist.md` y fila `CHECKLIST-GLOBAL.md`.

## 1. Verificación de contadores / conteos

- `CHECKLIST-GLOBAL.md` fila 105: `143/171` → coincide con conteo real del `05-Checklist.md`: `143 [x] / 0 [ ] / 28 [?] = 171`. Sin drift entre tabla global y archivo.
- `verificar_hooks_m105.py` (ejecutado): H3 = 0 consumidores de gameplay en 1245 `.gd` escaneados; H1, H2, H8 conectados. Los contadores `track_*` de M105 son efectivamente muertos en producción (solo sesiones se emiten). Confirmado por grep independiente: 0 llamadas a `TelemetryDirector.*` fuera de `telemetry/`.
- `_tracked` (Dictionary) se limpia en `_iniciar_sesion()` (telemetry_director.gd:301-313); `_zona_ignorada_reportada`, `_zona_duracion`, `_puzzle_inicio` también. No se detecta drift entre sesiones en la limpieza. OK.
- `_sesion_cerrada` idempotente (telemetry_director.gd:314-322) y reseteado en `_iniciar_sesion()` (línea 303). OK.

## 2. Hallazgos (archivo:línea, severidad, accionable)

### Crítico / Alto

1. `telemetry_director.gd:378-421` — **6 de 13 trackers no registran `METRIC_TIME_TO_FIRST_DISCOVERY`** (`track_travel_first_completed` solo registra travel; `track_museum_first_visited`, `track_festival_first_participated`, `track_community_project_first_completed` no registran ninguna métrica). Si la primera "discovery" del jugador es viaje/museo/festival/proyecto, `time_to_first_discovery` nunca se emite → el contador de discovery queda en 0 aunque exista evento `*_first_*`. **Severidad: Alto.** Accionable: añadir `_registrar_metrica_hasta(&"discovery", METRIC_TIME_TO_FIRST_DISCOVERY)` a travel y decidir (documentar) si museo/festival/comunidad cuentan como discovery.

2. `telemetry_director.gd:434-441` — `track_difficulty_perceived` no valida `rating` (1-5), no deduplica por `puzzle_id`, bypassa `_track_first` y `_registrar_metrica`, y emite `evento_rastreado` aunque `ads == null`. La UI puede spamear el mismo puzzle. **Severidad: Medio-Alto.** Accionable: validar/clampear rating, dedup por puzzle_id, rutear por `enviar_evento`.

3. `telemetry_director.gd:463-479` — `complete_puzzle` emite `PUZZLE_FIRST_COMPLETED` en cada completado (no solo el primero) mientras la métrica `METRIC_TIME_TO_FIRST_PUZZLE` sí se deduplica. El contador de eventos "first" se infla vs. la métrica. Documentado como decisión de diseño, pero las semánticas difieren. **Severidad: Medio.** Accionable: renombrar a `puzzle_completed` o documentar la regla de agregación.

4. `telemetry_director.gd:405-408` — `track_travel_first_completed` registra solo `METRIC_TIME_TO_FIRST_TRAVEL`, omitiendo discovery (ver hallazgo 1). **Severidad: Alto.** Accionable: añadir discovery.

### Medio

5. `telemetry_director.gd:490-496` — `start_puzzle` sobrescribe `_puzzle_inicio[puzzle_id]` si se llama dos veces sin completar, perdiendo el tiempo transcurrido y reiniciando la ventana de abandono. **Severidad: Medio.** Accionable: `if _puzzle_inicio.has(puzzle_id): return`.

6. `telemetry_director.gd:507-512` — `enter_zone` mismo patrón de sobrescritura en `_zona_entrada`. **Severidad: Medio.** Accionable: guard de reentrada.

7. `telemetry_bridge.gd:120-180` / `_despachar` (líneas ~182-195) — `_despachos` se incrementa en cada despacho aunque `track_*` no emita nada (opt-out o dedup); `_descartes` solo cuenta null/inválido/método ausente. Drift entre "despachos" y eventos realmente aceptados. **Severidad: Medio.** Accionable: renombrar a "intentos" o incrementar solo si `track_*` devuelve true (requiere cambio de contrato).

8. `analytics_director.gd:80-85` — `_agregados[tipo]` se incrementa en cada `registrar_evento`, pero cuando el buffer supera `max_buffer` (500) se hace `pop_front()` sin decrementar `_agregados`. Totales agregados > eventos retenidos → drift entre buffer y agregado. **Severidad: Medio.** Accionable: decrementar `_agregados` al descartar o trackear "descartados".

9. `analytics_director.gd:133-138` + `telemetry_director.gd:334-337` — `_duracion_sesion()` de Analytics usa `_inicio_sesion_ms` propio (seteado en `AnalyticsDirector._ready`), mientras Telemetry usa `_inicio_sesion_ms` propio (seteado en `_iniciar_sesion`). Diferencia de ms a segundos → `session_duration` de Telemetry y `duracion_seg` de Analytics pueden diferir. **Severidad: Bajo-Medio.** Accionable: unificar fuente de tiempo o aceptar diferencia documentada.

### Bajo

10. `telemetry_director.gd:525-540` — `_evaluar_zona_ignorada` trunca a `int` por visita; la suma de truncados puede subcontar segundos cerca del umbral de 60. **Severidad: Bajo.**

11. `telemetry_director.gd:483-489` — `_on_puzzle_check` usa `>= 300.0` con float y reporta `tiempo_seg = int(transcurrido_seg)`; puede reportar 300 para un abandono de ~301s. **Severidad: Bajo.**

12. `telemetry_director.gd:198-205` — `_conectar_bridge` falla en silencio si el script no carga; `bridge` queda null y `bridge_cobertura` reporta motivo, pero no hay log. **Severidad: Bajo.**

13. `telemetry_director.gd:413-421` — `track_museum/festival/community` no registran métrica ni discovery (ver 1). **Severidad: Bajo** (subsumido por 1).

## 3. Veredicto

Los contadores de M105 son internamente consistentes en la limpieza por sesión y el guardián anti-falso-verde está presente, pero existen **inconsistencias de registro de métricas** (discovery no se registra para travel/museo/festival/comunidad) y **drift entre contadores de dispatch y eventos aceptados** (bridge) y entre agregados y buffer (analytics). La entrada no se valida (rating, ids vacíos, reentradas).

## 4. Dos mejoras de diseño concretas

1. **Registro atómico de métricas en `_track_first`**: extender `_track_first(key, evento, datos, metricas: Array[String] = [])` para que, al primer éxito, registre todas las métricas asociadas en una sola operación (incluyendo `METRIC_TIME_TO_FIRST_DISCOVERY` por defecto salvo exclusión explícita). Elimina la dispersión actual donde cada tracker decide a mano qué métrica registrar, y garantiza que todo evento "first" tenga su `time_to_first_*` correspondiente.

2. **Capa de validación de entrada + reconciliación**: añadir `_validar_id(id) -> bool` (no vacío/trim) en `start_puzzle`, `enter_zone`, `track_*`; clampear `rating` a [1,5] en `track_difficulty_perceived` con dedup por puzzle; guards de reentrada en `start_puzzle`/`enter_zone`; y un método `verificar_consistencia() -> Dictionary` en TelemetryDirector que compare keys de `_tracked` vs métricas registradas y reporte drift (consumible por tests y por `verificar_hooks_m105.py`).

**No se modificó código del juego.** Solo supervisión y validación.