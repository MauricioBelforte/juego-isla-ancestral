# Reporte de análisis — Progresión, experiencia y niveles (M71)

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-08 04:30 (UTC, contexto de ejecución)  
**Alcance solicitado:** `game/isla-ancestral/scripts/` (progresión / XP / niveles / habilidades)  
**Ruta del reporte:** `Mensajes entre modelos/Glyph Cluster/REPORTES-Prueba-Paralela/reporte_glyph_cluster_progresion_2026-11-08.md`

## 1) Archivos analizados

| Archivo | Rol |
|---|---|
| `game/isla-ancestral/scripts/progresion/progression_manager.gd` | Núcleo M71 (autoload `ProgressionManager`): catálogo `hitos.json`, evaluación de condiciones, reevaluación por evento, recompensas (`info`/`unlock`/`titulo`), caché, validación, persistencia. |
| `game/isla-ancestral/scripts/progresion/player_profile.gd` | Perfil/estadísticas acumuladas y diarias (`_totales`, `_dia`), primeras veces, contribución/reputación, serialización consumida por M71. |
| `game/isla-ancestral/data/progresion/hitos.json` | Catálogo data-driven de hitos (26 hitos, `schema_version: 1`): condiciones `stat_min`, `riqueza_acumulada`, `primera_vez`, `dias_jugados`, `compuesta`, `hito_previo`, `coleccion_completa`, `sello_historia`, etc. |
| `game/isla-ancestral/scripts/progresion/test_progresion.gd` | Suite principal de M71 (83 checks mínimos declarados): catálogo, dirty reevaluación, idempotencia, tipos de condición, persistencia, títulos RF12, rendimiento, etc. |
| `game/isla-ancestral/scripts/progresion/test_flujo_xp_recompensa_m71_hy3.gd` | Test headless independiente de flujo XP/recompensa (eventos → stats → hitos → recompensas → persistencia). |
| `game/isla-ancestral/scripts/progresion/test_nivel_herramienta.gd` | Puente M13→M71 para `nivel_modulo`/herramientas (`herramienta_equipada` → `nivel_herramienta_cambio` → stat monotónica `nivel_*`). |
| `game/isla-ancestral/scripts/progresion/test_bug_reevaluar_m71_hy3.gd` | Reproducción aislada del defecto F1 en `_reevaluar()` (marca hitos sin validar umbral). |
| `game/isla-ancestral/project.godot` (línea 79) | Autoload: `ProgressionManager="*res://scripts/progresion/progression_manager.gd"`. |

Búsqueda en `game/isla-ancestral/scripts/**/*.gd`: no se encontraron carpetas `xp/`, `nivel/`, `habilidad/`/`skill/` dedicadas al jugador fuera de `scripts/progresion/` y puentes relacionados (M13 herramientas, M158 tiers). El sistema de “experiencia/niveles” implementado hoy es **progresión por hitos/estadísticas/condiciones**, no un XP numérico con level-up clásico del jugador.

## 2) ¿Cómo se gestiona la experiencia y subida de nivel?

### 2.1 Modelo real (hitos + estadísticas)
- **Catálogo JSON:** `progression_manager.gd:115-139` carga `res://data/progresion/hitos.json` (`RUTA_CATALOGO`, línea 24). Cada hito tiene `id`, `nombre`, `dominio`, `condicion` y `recompensas` (`hitos.json:1`).
- **Registro como autoload:** `project.godot:79` expone `ProgressionManager`.
- **Evento → estadística (“XP” del dominio) → reevaluación:** conexiones de dominio en `_conectar_eventos()` (`progression_manager.gd:176-239`). Ejemplos:
  - `inventory.item_added` → `items_recolectados` (`186-187`).
  - `economy.purchase_done` → `monedas_gastadas` (`188-189`).
  - `quest.quest_completed` → `misiones_completadas` (`197-198`).
  - `npc.friendship_level_up` → `amistades_subidas` (`199-200`).
  - `travel.travel_started` → `viajes_realizados` (`201-202`).
  - `day_started` (M29) → `profile.reset_dia()` (`204-208`).
  - M38 `transaccion_registrada`/`trueque_exitoso` → `monedas_ganadas`/`trueques_realizados` (`209-218`, handlers `255-269`).
  - M13 `herramienta_equipada` → `nivel_herramienta_cambio` + stat monotónica `nivel_*` (`219-253`).
- **Incremento de stats:** `_stat()` llama `profile.incrementar()` y luego `_reevaluar(stat_id)` (`272-276`). `PlayerProfile.incrementar()` suma a `_totales` y `_dia`, marca dirty y acumula contribución si `monedas_ganadas` (`player_profile.gd:28-34`).
- **Índice sucio (O(1) por evento, intención de diseño):** `_indexar_condicion()` construye `_condiciones_por_hito[stat_id] -> [hito_id]` (`142-160`). `_reevaluar()` itera solo hitos indexados para esa stat (`279-285`).
- **Evaluación de condiciones (11 tipos documentados):** `evaluar_condicion()` soporta `stat_min`, `dias_jugados`, `sello_historia`, `capitulo_historia`, `riqueza_acumulada`, `primera_vez`, `hito_previo`, `coleccion_completa`, `nivel_modulo`, `compuesta` (AND/OR/NOT) (`643-694`). `evaluar_pura()` ofrece predicado puro con estado inyectable (`288-342`).
- **Subida/logro de hito (equivalente a “level up” de progreso):** `marcar_hito()` es idempotente, registra en `_hitos_alcanzados`, emite `progreso_hito_alcanzado`, procesa recompensas `unlock` y `titulo` (`793-812`). Señales: `progreso_hito_alcanzado`, `progreso_desbloqueado`, `progreso_primera_vez`, `progreso_resumen_cargado`, `progreso_titulo_obtenido` (`18-22`).
- **Persistencia:** `get_save_data()/restore_save_data()` serializan versión, hitos, desbloqueos, stats, primeras veces, contribución y títulos; **no re-emiten señales de hitos restaurados** (`896-937`).

### 2.2 “Niveles” en el sistema
- **No hay nivel global del jugador** (sin XP total → nivel N con umbral). `PlayerProfile` no define nivel; `ProgressionManager` no calcula nivel.
- **Sí hay niveles de módulos externos evaluables por condición:** `nivel_modulo` consulta `ToolController.obtener_nivel_herramienta()` o `CasaManager.obtener_nivel_casa()` vía duck-typing; fallback `false` si no existen (`697-718`, `317-342`). El puente M13 mantiene stats monotónicas `nivel_pico/azada/...` (`241-253`), probado en `test_nivel_herramienta.gd`.

## 3) Validación de experiencia/valores negativos o desbordamiento

### 3.1 Controles existentes
- **Catálogo (estático):** `validar_catalogo()` y helpers detectan IDs duplicados, refs/stat desconocidas (`_stats_validos_conocidos()`), umbrales negativos en `stat_min/riqueza_acumulada/dias_jugados/nivel_modulo`, campos faltantes, tipos desconocidos, ciclos simples de `hito_previo` (max depth 10), hitos con recompensas sin condición (`533-637`). `_validar_catalogo_en_ruta()` loguea warnings al cargar (`622-630`).
- **Monedas ganadas (M38):** solo depósitos/trueque ingreso con `monto > 0` suman `monedas_ganadas`; retiros no suman (`257-262`).
- **Nivel de herramienta monotónico:** solo sube si `nivel > prev` (`250-253`).
- **Reputación acotada:** `clampf(..., 0, 1)` y escalado a porcentaje (`player_profile.gd:80-90`).
- **Caché acotada:** `_evaluate_cache_set()` limita a `CACHE_MAX_SIZE=64` con descarte simple del más viejo (`380-394`); evita crecimiento infinito.
- **Progreso parcial acotado al tipo:** `progreso_parcial()` devuelve `logrado/requerido` solo para `stat_min` (`868-878`).

### 3.2 Riesgos / ausencias de validación

| # | Hallazgo | Evidencia | Impacto |
|---|---|---|---|
| V1 | **`PlayerProfile.incrementar()` no valida signo/tipo/NaN/Inf.** Acepta `cantidad` negativa y cualquier magnitud; suma a `_totales/_dia` y marca dirty. | `player_profile.gd:28-34` (`float(cantidad)` sin `max/abs/is_finite`). | Un evento o caller erróneo puede reducir stats (“anti-XP”), romper coherencia con hitos ya alcanzados (no se revocan) o introducir valores extremos. `contribucion` solo crece en `monedas_ganadas` (`33-34`), pero otras stats sí pueden bajar. |
| V2 | **`_stat()` confía en `cantidad` de eventos sin sanitizar.** | `progression_manager.gd:272-276`, emisores `186-218`. | Propaga V1 desde EventBus/M38/Barter. |
| V3 | **`progreso_parcial()` para `stat_min` devuelve valores sin clamp a `[0, requerido]`.** | `progression_manager.gd:874-877`. | UI puede mostrar progreso > 100% o valores raros si la stat se corrompe/crece mucho. No rompe lógica de logro, pero sí presentación. |
| V4 | **Sin tope explícito de magnitud/desbordamiento numérico.** `float` en GDScript/Variant evita overflow entero clásico, pero permite valores enormes, `INF` o pérdida de precisión; no hay `is_finite`. | `player_profile.gd:29-31,62-78,99-101`, `progression_manager.gd:871-877`. | Casos extremos (bug de acumulación, save corrupto, valor externo) pueden degradar comparaciones/UI/serialización sin diagnóstico claro. |
| V5 | **Restauración de save confía en contenido sin saneamiento fuerte.** `PlayerProfile.cargar()` vuelca dicts tal cual; `restore_save_data()` limpia hitos desconocidos pero no valida rangos/tipos de stats/desbloqueos/títulos. | `player_profile.gd:103-118`, `progression_manager.gd:911-937`. | Un save manipulado/corrupto puede inyectar stats negativas, no finitas o estructuras inesperadas. |
| V6 | **Validación de catálogo detecta umbrales negativos, pero no valida límites superiores razonables ni consistencia semántica de recompensas/campos numéricos.** | `progression_manager.gd:533-621`, `640-641`. | Cobertura parcial: útil, pero no evita catálogos “legales” con umbrales absurdos o datos incoherentes. |

## 4) Problemas de cálculo de niveles o umbrales

| # | Problema | Evidencia | Severidad | Estado |
|---|---|---|---|---|
| C1 | **Defecto F1 (conocido, reproducido): `_reevaluar()` marca hitos indexados sin revalidar la condición/umbral.** Al ensuciar una stat, toma todos los `hito_id` de `_condiciones_por_hito[stat_id]` no alcanzados y llama `marcar_hito()` directamente (`279-285`). `marcar_hito()` solo verifica alcanzado/existencia, **no** `evaluar_condicion()` (`793-812`). Con `items_recolectados`, alcanzar `hito_items_10` (umbral 10) puede marcar también `hito_items_50` (umbral 50) y encadenar `hito_explorador_completo`. | `progression_manager.gd:279-285,793-812`; índices por stat raíz `142-160`; `hitos.json` entradas `hito_items_10`/`hito_items_50`/`hito_explorador_completo`. **Repro aislada:** `test_bug_reevaluar_m71_hy3.gd:59-75` exige integridad de umbral y documenta que debe fallar hasta corregir. `test_flujo_xp_recompensa_m71_hy3.gd:100-107` también lo nota (`F1`). | **Alta** (otorga hitos/recompensas/títulos antes de tiempo por camino de eventos). | **Abierto según tests/F1**. Requiere fix en producción. |
| C2 | **`evaluar_condicion_id()` cachea resultado sin invalidación por cambio de estado.** Guarda en `_evaluacion_cache` (`367-378`) con LRU simple a 64 entradas (`380-394`), pero no se limpia al cambiar stats, al día nuevo, al restaurar save ni al reevaluar. `reevaluar_sucias()` recalcula con `evaluar_condicion()` directo (`397-405`), evitando el bug en ese camino, pero cualquier consumidor de `evaluar_condicion_id()` puede leer un `false` obsoleto hasta evicción/restauración. | `progression_manager.gd:367-405`; `restore_save_data()` no limpia caché `911-937`. | **Media** (stale cache; puede bloquear lógica/UI que use el API cacheado). | Riesgo latente. |
| C3 | **“Subida de nivel” clásica no existe; `dias_jugados` depende de `GameTime.dia_absoluto()` con fallback 0.** Si `GameTime` falta, `stat_min/dias_jugados` se evalúan contra 0 (`658-661`, `294-316`), lo que puede retrasar hitos legítimos sin error duro. | `progression_manager.gd:658-661,294-316`. | **Baja/Media** (degradación silenciosa en entornos incompletos). | Diseño tolerante, pero opaco para debugging. |
| C4 | **No se detectó desbordamiento/negativo explotado en el cálculo de umbrales actual**, porque los tipos de condición comparan `float(cond.umbral)` contra valores obtenidos; el problema principal es la **falta de validación de entrada** (V1-V5) y **F1** (C1), no un overflow aritmético visible. | `progression_manager.gd:643-694`, `288-342`. | Informativo. | N/A. |

## 5) Dos mejoras sugeridas

### Mejora 1 — Corregir F1 y hacer la reevaluación “threshold-safe”
- **Cambio:** en `_reevaluar(stat_id)` (`progression_manager.gd:279-285`), antes de marcar, validar la condición real:
  - opción simple/segura: `if not hito_alcanzado(hid) and evaluar_condicion(_hitost[hid].get("condicion", {})): marcar_hito(hid)`.
  - opción optimizada: evaluar solo si el hito depende exclusivamente de la stat sucia o si es compuesto; invalidar caché relevante.
- **Además:** invalidar `_evaluacion_cache` al cambiar stats relevantes, en `restore_save_data()`, y opcionalmente al `day_started` si se cachean condiciones temporales.
- **Validación:** ejecutar `test_bug_reevaluar_m71_hy3.gd` (debe pasar) y `test_progresion.gd`/`test_flujo_xp_recompensa_m71_hy3.gd` completos. Añadir caso compuesto donde una stat cumple un hijo pero la condición global no.
- **Beneficio:** elimina otorgamiento prematuro de hitos/recompensas/títulos (bug de progresión).

### Mejora 2 — Endurecer entradas numéricas y datos persistidos
- **Cambio en `PlayerProfile.incrementar/stat/save/load` (`player_profile.gd`):**
  - rechazar/normalizar `NaN` e `INF` (`is_finite`).
  - política explícita para negativos: o `max(0, ...)` en stats que no deben bajar, o API separada `decrementar()` con clamp a 0; documentar excepciones.
  - opcional: clamp de progreso parcial en `progreso_parcial()` para UI (`clampf(logrado, 0, requerido)` cuando `requerido > 0`).
- **Cambio en `restore_save_data()` (`progression_manager.gd:911-937`):** sanear tipos/rangos de `estadisticas_totales/dia`, `contribucion >= 0`, contenedores esperados; ignorar valores inválidos con warning.
- **Validación:** tests de regresión con cantidades negativas, `INF`, save corrupto y stats enormes; verificar que hitos no se vuelven inconsistentes.
- **Beneficio:** protege la “experiencia”/progresión ante bugs de integración, eventos malformados y saves corruptos, sin romper el diseño cozy data-driven.

## Conclusión final

El subsistema relevante en `game/isla-ancestral/scripts/progresion/` implementa **progresión por hitos y estadísticas** (M71) con `ProgressionManager` + `PlayerProfile`, catálogo `hitos.json`, señales, validación de catálogo, puentes a economía/M13/M22/M29/M37/M38/M59 y persistencia. **No existe un sistema clásico de XP numérica + subida de nivel del jugador**; los “niveles” presentes son de módulos (`nivel_modulo`/herramientas/casa) evaluados por condición.

Hay controles parciales útiles (umbrales negativos en catálogo, monotonicidad de nivel de herramienta, clamps de reputación, ignorar retiros como ganancia), pero **faltan validaciones defensivas** en `PlayerProfile.incrementar/cargar` y en el saneamiento de saves ante negativos, no finitos o corrupción. El problema funcional más importante es **C1/F1**: `_reevaluar()` puede otorgar hitos sin cumplir umbral por el camino de eventos (defecto ya documentado y reproducido por tests Hy3). Se recomienda priorizar el fix threshold-safe + invalidación de caché, y luego endurecer la validación numérica/persistencia.
