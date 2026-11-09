# Reporte: Progresión / Experiencia / Niveles / Habilidades
**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-09 06:00 (UTC)  
**Alcance analizado:** `game/isla-ancestral/scripts/progresion/`, `game/isla-ancestral/scripts/stream/progress_calculator.gd`, `game/isla-ancestral/data/progresion/hitos.json`

## Archivos revisados
- `game/isla-ancestral/scripts/progresion/progression_manager.gd` (autoload M71, 959 líneas)
- `game/isla-ancestral/scripts/progresion/player_profile.gd` (autoload, 117 líneas)
- `game/isla-ancestral/scripts/stream/progress_calculator.gd` (M63, 35 líneas) — *progreso de carga/streaming, no progresión del jugador; se distingue para evitar ambigüedad*
- `game/isla-ancestral/data/progresion/hitos.json` (458 líneas, catálogo data-driven)
- Tests de referencia: `test_progresion.gd`, `test_flujo_xp_recompensa_m71_hy3.gd`, `test_nivel_herramienta.gd`

## 1) ¿Cómo se gestiona la experiencia y la subida de nivel?
- **No existe un sistema clásico de XP numérica con niveles del jugador.** La progresión global (M71) es un sistema de **hitos/milestones** basado en estadísticas acumuladas y condiciones declarativas.
- **Acumulación de “experiencia”/progreso:** `PlayerProfile.incrementar(stat_id, cantidad)` (`player_profile.gd:31-36`) actualiza `_totales`, `_dia`, marca `_sucias` y suma `_contribucion` cuando `stat_id == "monedas_ganadas"`. `get_stat` (`:44-45`) devuelve el valor acumulado.
- **Evaluación y otorgamiento:** `ProgressionManager` carga el catálogo desde `res://data/progresion/hitos.json` (`progression_manager.gd:87-105`), indexa dependencias por estadística (`:109-124`) y se conecta a eventos de dominio vía `EventBus`/autoloads (`:147-190`, `_on_transaccion_registrada` `:226-232`, `_on_trueque_exitoso` `:236-238`, `_on_herramienta_equipada` `:202-221`).
- **Hitos:** `marcar_hito` (`:791-808`) es idempotente, emite `progreso_hito_alcanzado`, registra `DOM-PROG-HITO`, entrega recompensas `unlock`/`titulo` y activa desbloqueos (`:887-892`). Títulos RF12 se gestionan en `:813-839`.
- **Condiciones:** evaluador con 11+ tipos (`:702-750`) incluyendo `stat_min`, `dias_jugados`, `sello_historia`, `capitulo_historia`, `riqueza_acumulada`, `primera_vez`, `hito_previo`, `coleccion_completa`, `nivel_modulo`, `compuesta` (AND/OR/NOT). Existe predicado puro `evaluar_pura` (`:260-328`) y caché `evaluar_condicion_id` (`:380-405`).
- **Persistencia:** proveedor de `SaveManager` (`:908-958`), versión de sección, round-trip de hitos/desbloqueos/estadísticas/títulos; hitos desconocidos del catálogo antiguo se ignoran (`:934-940`) y no se re-emiten señales al restaurar (`:959`).
- **“Subida de nivel” en otros dominios (no XP de jugador):** aparecen señales/lógicas de nivel en amistad (`friendship_level_up`), herramientas (`nivel_herramienta_cambio` puente M13→M71, `:183-221`), y vehículos (`subir_nivel()` en `vehicle_preset.gd`/tests). Son dominios separados del sistema M71.

## 2) ¿Hay validación de valores de experiencia negativos o desbordamiento?
- **Negativos en estadísticas:** `PlayerProfile.incrementar` (`:31-36`) acepta `cantidad: int = 1` y suma `float(cantidad)` **sin rechazar valores negativos**. Un caller puede decrementar `_totales/_dia` o reducir `_contribucion` (esta última solo se toca si `stat_id == "monedas_ganadas"`), lo que puede invalidar la semántica de estadísticas acumuladas/monótonas y afectar hitos ya alcanzados conceptualmente (los hitos son idempotentes una vez marcados, pero el progreso parcial/UI y reevaluaciones futuras pueden quedar inconsistentes).
- **Desbordamiento/NaN/Inf:** no hay clamps ni validación de rangos en `incrementar`/`set_stat`/`cargar`. En GDScript los enteros/floats tienen límites prácticos; no se observa sanitización de `inf`, `nan` o valores extremos al restaurar save (`:104-116` en profile, `:933-956` en manager).
- **Lados positivos:** `ProgressCalculator.progreso` (streaming) usa `clampf(..., 0.0, 1.0)` y retorna `1.0` si `peso_total <= 0` (`progress_calculator.gd:20-23`). `marcar_hito`/`activar_desbloqueo`/títulos son idempotentes. `_evaluar_nivel_modulo_puro` y el puente de herramienta usan lógica **monótona** para `nivel_pico/...` (`:217-221`).
- **Catálogo:** `validar_catalogo` rechaza umbrales negativos para varios tipos (`:564-572`, `:587-588`, `:685-691`), pero eso es validación estática del JSON; no protege contra datos corruptos en runtime o saves manipulados.

## 3) ¿Hay problemas de cálculo de niveles o umbrales?
- **Hallazgo relevante (ya señalado por tests, confirmado en código):** `_reevaluar(stat_id)` (`:248-253`) marca hitos dependientes de una estadística sucia **sin evaluar la condición**: si el hito no está alcanzado llama `marcar_hito(String(hito_id))`. `marcar_hito` (`:791-793`) solo comprueba `hito_alcanzado || !_hitost.has(...)`; **no valida `evaluar_condicion`**. En contraste, `reevaluar_sucias()` (`:408-416`) sí evalúa antes de marcar. Esto puede otorgar hitos/recompensas antes de cumplir el umbral real cuando se dispara el camino por evento sucio (consistente con la nota F1 en `test_flujo_xp_recompensa_m71_hy3.gd:116-120`).
- **Umbrales:** las comparaciones usan `>= umbral` (`:277,285,305,710,714,720,...`), correcto para condiciones mínimas. `dias_jugados`/`capitulo_historia` dependen de autoloads externos; si faltan, retornan valores conservadores (`0`/falso) salvo casos ya contemplados.
- **Cache:** `evaluar_condicion_id` cachea por `condicion_id` (`:380-389`, `_evaluate_cache_set :392-405`) sin invalidación visible cuando cambian estadísticas/autoloads; puede devolver resultados obsoletos si se usa como fuente de verdad tras cambios de estado (el flujo principal usa `_reevaluar`/`reevaluar_sucias`/`evaluar_condicion` directo en varios casos).
- **Progreso parcial:** `progreso_parcial` (`:874-882`) solo calcula detalle para `stat_min`; otros tipos retornan `{logrado: int(hito_alcanzado), requerido: 1}`, lo cual limita la UI pero no es un error de umbral.
- **Sugeridor:** `hitos_proximos` (`:852-870`) filtra tipos cuantificables y recorre el diccionario `_hitost` sin orden estable garantizado más allá del orden de iteración; puede priorizar hitos arbitrarios.

## 4) ¿Hay validación de entrada en los cálculos de progresión?
- **Defensiva parcial con defaults:** uso extendido de `cond.get(..., default)`, `String(...)`, `int(...)`, `float(...)` y comprobaciones de `has_method`/`has_signal`/nulos reduce crashes ante datos incompletos.
- **Catálogo:** validación estática `validar_catalogo` (`:530-655`) y bloqueante `validar_catalogo_bloqueante` (`:663-697`) cubren IDs duplicados, stats desconocidas, umbrales negativos, ciclos `hito_previo` (profundidad limitada), tipos inválidos y condiciones vacías con recompensas. `_validar_catalogo_en_ruta` (`:646-654`) loguea warnings al cargar.
- **Faltantes:**
  - `incrementar`/`set_stat` no validan `stat_id` vacío, tipo de `cantidad/valor`, negativos, `NaN`/`Inf`.
  - `evaluar_condicion`/`evaluar_pura` no validan estructura completa del diccionario (tipos de hijos, operador inválido retorna `false` silenciosamente en `:348`).
  - `restore_save_data`/`cargar` confían en la forma de los datos; no sanitizan valores numéricos extremos ni tipos inesperados dentro de arrays/dicts.
  - `_stats_validos_conocidos()` (`:518-525`) es una lista fija; stats nuevas válidas podrían ser tratadas como desconocidas por validadores estáticos.
  - `_evaluate_cache_set` usa una estrategia LRU simplificada (toma la primera clave iterada como “más vieja”, `:396-404`), que no es un LRU real y puede evictar entradas no óptimas.

## 5) Sugerencias de mejora (2)
1. **Corregir el camino sucio para respetar umbrales y endurecer invariantes de estadísticas**
   - En `_reevaluar(stat_id)` (`progression_manager.gd:248-253`), evaluar la condición antes de marcar: `if not hito_alcanzado(hid) and evaluar_condicion(_hitost[hid].get("condicion", {})): marcar_hito(hid)`. Alternativamente, hacer que `marcar_hito` acepte/verifique una condición ya evaluada o evalúe internamente cuando corresponda (cuidando idempotencia y costos).
   - En `PlayerProfile.incrementar` (`player_profile.gd:31-36`), validar entrada: ignorar/rechazar `cantidad` negativa para stats acumuladas monótonas (o exponer `decrementar` explícito solo para stats permitidas), normalizar `NaN/Inf`, y opcionalmente advertir si `stat_id` está vacío. Mantener `_contribucion` coherente con la política elegida.

2. **Invalidación de caché + validación runtime de saves/catálogo dinámico**
   - Invalidar `_evaluacion_cache` cuando cambie el estado relevante: al incrementar stats, reset diario, restaurar save, alcanzar hitos previos, o cambios de autoloads que afecten condiciones (`dias_jugados`, `sello_historia`, etc.). Esto evita falsos positivos/negativos si `evaluar_condicion_id` se usa fuera del flujo controlado.
   - Al cargar/restaurar, sanitizar datos (`restore_save_data`/`PlayerProfile.cargar`): coerción segura, clamp de rangos razonables, descarte de valores no numéricos donde aplique, y registro de anomalías. Considerar derivar/actualizar `stats válidas` desde el catálogo o configuración para que validadores no queden desfasados.

## Conclusión final
El subsistema M71 implementa una progresión **basada en hitos y estadísticas** (no XP/niveles clásicos del jugador), con buena base: catálogo data-driven, evaluador declarativo, idempotencia, persistencia versionada, integración por eventos y pruebas headless. Los riesgos principales son: **(1)** el camino `_reevaluar` puede marcar hitos sin verificar el umbral (consistente con F1 ya detectado en tests), **(2)** ausencia de validación contra cantidades negativas/valores inválidos en estadísticas y restauración, lo que permite corrupción lógica o saves inconsistentes, y **(3)** caché de evaluación sin invalidación clara ante cambios de estado. Priorizar la corrección del umbral en reevaluación sucia y el endurecimiento de entrada/persistencia mejorará la confiabilidad del sistema de progresión.
