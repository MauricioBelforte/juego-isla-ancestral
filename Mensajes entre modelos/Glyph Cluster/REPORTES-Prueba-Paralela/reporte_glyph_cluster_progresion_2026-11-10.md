# Reporte de Análisis — Sistema de Progresión (M71)

**Modelo:** Glyph Cluster  
**Plataforma:** Vercel AI Gateway (stealth, early access)  
**Fecha:** 2026-11-10  
**Alcance:** `game/isla-ancestral/scripts/progresion/` y `game/isla-ancestral/data/progresion/hitos.json`

---

## 1. Archivos analizados

| Archivo | Rol | Líneas aprox. |
|---|---|---|
| `game/isla-ancestral/scripts/progresion/player_profile.gd` | Autoload `PlayerProfile`: estadísticas acumuladas/día, primeras veces, contribución/reputación, dirty flags, serialización de perfil | ~120 |
| `game/isla-ancestral/scripts/progresion/progression_manager.gd` | Autoload `ProgressionManager`: catálogo de hitos, evaluación de condiciones, reevaluación por eventos, recompensas (unlock/título), persistencia de sección `progresion` | ~900+ |
| `game/isla-ancestral/data/progresion/hitos.json` | Catálogo data-driven de 26 hitos (condiciones, recompensas, dominios) | 1 (JSON compacto) |
| `game/isla-ancestral/scripts/progresion/test_progresion.gd` | Suite de tests headless del módulo M71 | ~500+ |
| `game/isla-ancestral/scripts/progresion/test_flujo_xp_recompensa_m71_hy3.gd` | Test de flujo XP/recompensa (Hy3) | ~250+ |
| `game/isla-ancestral/scripts/progresion/test_bug_reevaluar_m71_hy3.gd` | Reproducción aislada del defecto F1 en `_reevaluar` | ~90 |
| `game/isla-ancestral/scripts/progresion/test_nivel_herramienta.gd` | Test de puente `nivel_herramienta_cambio` M13/M71 | ~70 |
| `game/isla-ancestral/scripts/progresion/debug_tc.gd` | Script auxiliar de debug (ToolController) | — |

**Búsqueda complementaria:** no se hallaron directorios `scripts/nivel/`, `scripts/xp/` ni archivos `.gd` con `class_name`/sistema dedicado de "experiencia" o "subida de nivel" de personaje fuera de `scripts/progresion/`. Las referencias a `nivel_herramienta` y `nivel_modulo` corresponden a niveles de módulos externos (M13 herramientas, M18 casa) evaluados como condiciones de hitos.

---

## 2. ¿Cómo se gestiona la experiencia y la subida de nivel?

### 2.1 Modelo general (hitos/estadísticas, no XP clásica)

El sistema M71 implementa progresión basada en **estadísticas acumuladas** y **hitos (milestones)** data-driven, no una barra de experiencia con niveles de personaje:

- **`PlayerProfile`** (`player_profile.gd:28-36`) mantiene:
  - `_totales: Dictionary` — acumulados por `stat_id` (`player_profile.gd:29`)
  - `_dia: Dictionary` — acumulados del día (`player_profile.gd:31`)
  - `_primeras_veces`, `_contribucion`, `_sucias` (dirty flags) (`player_profile.gd:33-37`)
- **`incrementar(stat_id, cantidad)`** (`player_profile.gd:40-45`) suma al total y al día, marca la estadística como sucia y, si `stat_id == "monedas_ganadas"`, acumula `_contribucion`.
- **`ProgressionManager`** (`progression_manager.gd`) carga el catálogo desde `res://data/progresion/hitos.json` (`progression_manager.gd:33,67-91`), indexa condiciones por estadística raíz para reevaluación dirigida (`_indexar_condicion`, `progression_manager.gd:94-109`) y conecta eventos de dominio vía `EventBus`/autoloads (`_conectar_eventos`, `progression_manager.gd:172-226`).
- Los eventos traducen acciones a estadísticas ("XP-like"): p. ej. `item_added` → `items_recolectados` (`progression_manager.gd:189-190`), `quest_completed` → `misiones_completadas` (`progression_manager.gd:199-200`), `transaccion_registrada` depósito/trueque → `monedas_ganadas` (`progression_manager.gd:262-269`), `trueque_exitoso` → `trueques_realizados` (`progression_manager.gd:274-277`).
- Al cambiar una estadística, `_stat` llama `profile.incrementar` y `_reevaluar(stat_id)` (`progression_manager.gd:280-284`), que intenta marcar los hitos dependientes de esa stat (`progression_manager.gd:287-294`).

### 2.2 Evaluación de condiciones y desbloqueo de hitos

- `evaluar_condicion` soporta 11 tipos: `stat_min`, `dias_jugados`, `sello_historia`, `capitulo_historia`, `riqueza_acumulada`, `primera_vez`, `hito_previo`, `coleccion_completa`, `nivel_modulo`, `compuesta` (AND/OR/NOT) y fallback `false` (`progression_manager.gd:713-765`).
- `marcar_hito` es idempotente: si ya alcanzado o no existe, retorna `false`; si no, registra, emite `progreso_hito_alcanzado`, entrega recompensas (`unlock`, `titulo`) (`progression_manager.gd:813-834`).
- `progreso_parcial` expone avance para UI (lazy-eval) pero solo calcula detalle para `stat_min`; otros tipos devuelven `{logrado: 0|1, requerido: 1}` (`progression_manager.gd:892-901`).

### 2.3 "Niveles" existentes (módulos externos, no nivel de personaje)

- **Herramientas (M13):** `conectar_tool_controller` + `_on_herramienta_equipada` traducen `herramienta_equipada` a `EventBus.progresion.nivel_herramienta_cambio` y actualizan estadísticas `nivel_<tool>` de forma **monótona** (solo sube si el nuevo nivel > previo) (`progression_manager.gd:229-259`). Condición `nivel_modulo` con `modulo="herramienta"` consulta `ToolController.obtener_nivel_herramienta` (`progression_manager.gd:767-790`, variante pura `progression_manager.gd:365-388`).
- **Casa (M18):** condición `nivel_modulo` con `modulo="casa"` consulta `CasaManager.obtener_nivel_casa` (`progression_manager.gd:783-789`, `377-383`).
- No hay fórmula de XP→nivel de jugador, tabla de experiencia ni curva de subida de nivel de personaje en estos scripts.

### 2.4 Persistencia

- `get_save_data` / `restore_save_data` versionan la sección `progresion` (`SECCION_VERSION = 1`), persistiendo hitos, desbloqueos, estadísticas, primeras veces, contribución y títulos; al restaurar purga hitos desconocidos del catálogo y **no re-emite** señales de hitos restaurados (idempotencia/carga) (`progression_manager.gd:930-975`).

---

## 3. ¿Hay validación de valores de experiencia negativos o desbordamiento?

### 3.1 Valores negativos

**No hay validación/clampeo de negativos en la ingesta de estadísticas:**

- `PlayerProfile.incrementar(stat_id, cantidad: int = 1)` suma directamente `float(cantidad)` a `_totales`, `_dia` y (si aplica) `_contribucion` sin comprobar `cantidad < 0` (`player_profile.gd:40-45`). Una cantidad negativa decrementa el acumulado y puede dejar la contribución en negativo.
- `PlayerProfile.set_stat(stat_id, valor)` asigna cualquier `Variant` sin validación (`player_profile.gd:48-50`).
- `reputacion()` clampea los **componentes** de cálculo a `[0,1]` (`clampf(amistad_normalizada, 0,1)` y `clampf(_contribucion/CONTRIBUCION_META, 0,1)`), por lo que una contribución negativa no produce reputación negativa en el resultado, pero el **estado interno** `_contribucion` permanece negativo y puede distorsionar lógica futura (`player_profile.gd:74-83`).
- En `ProgressionManager`, `_stat` delega en `incrementar` sin sanitizar (`progression_manager.gd:280-283`); `_on_transaccion_registrada` filtra `monto > 0` para depósitos/trueques-ingreso (`progression_manager.gd:262-269`), lo cual mitiga un caso específico pero no es una política global de no-negatividad.

### 3.2 Desbordamiento y límites

- **Sin límites superiores** en estadísticas, contribución o contadores de día: no hay `clamp` a máximo ni techo configurable.
- **Enteros/floats en GDScript 4:** los enteros son de 64 bits (riesgo práctico de overflow bajo), pero valores extremos pueden provocar pérdida de precisión en `float` (usado en totales, contribución y comparaciones) o resultados inesperados en UI/cálculos.
- **Caché acotada:** `_evaluacion_cache` tiene `CACHE_MAX_SIZE = 64` con política de evicción simple al insertar (`progression_manager.gd:53-56,348-361`), lo que evita crecimiento ilimitado de memoria en ese punto.
- **Catálogo/arrays:** `_hitos_alcanzados` crece con hitos alcanzados (acotado por tamaño del catálogo); no se observa protección contra datos de save corruptos con tamaños anómalos más allá de la purga de IDs desconocidos.

**Conclusión del punto 3:** protección parcial (clampeo en cálculo de reputación, filtro de montos positivos en un flujo económico, caché limitada) pero **no existe validación sistemática de entradas negativas ni estrategia explícita de límites/desbordamiento** para estadísticas y contribución.

---

## 4. ¿Hay problemas de cálculo de niveles o umbrales?

### 4.1 Defecto crítico confirmado: reevaluación sin validar condición (F1)

- **Ubicación:** `ProgressionManager._reevaluar(stat_id)` (`progression_manager.gd:287-294`).
- **Comportamiento actual:** para cada hito indexado por la estadística sucia y no alcanzado, llama `marcar_hito(hito_id)` directamente **sin evaluar** `evaluar_condicion`/`evaluar_pura` ni comprobar umbral.
- **Impacto:** un evento que satisface el umbral de un hito de esa stat puede marcar **otros hitos de la misma stat con umbrales mayores** (y potencialmente cadenas compuestas dependientes). Ejemplo documentado en tests: con 10 `items_recolectados` se alcanza `hito_items_10` pero también se marca indebidamente `hito_items_50` (umbral 50) y `hito_explorador_completo`.
- **Evidencia en repo:** `test_bug_reevaluar_m71_hy3.gd` reproduce el fallo como prueba de integridad de umbral (espera fallo mientras el bug exista, líneas de checks de integridad ~57-71 del test); `test_flujo_xp_recompensa_m71_hy3.gd` lo reconoce como `[NOTA] F1` en el flujo de eventos (`test_flujo_xp_recompensa_m71_hy3.gd`, bloque `_test_flujo_evento_items`).
- **Severidad:** alta — rompe la semántica de umbrales y puede otorgar recompensas/títulos/desbloqueos prematuramente.

> Nota: `reevaluar_sucias()` (`progression_manager.gd:388-396`) sí evalúa la condición antes de marcar; la inconsistencia está en el camino caliente `_reevaluar` disparado por `_stat`.

### 4.2 Caché de evaluación sin invalidación por cambio de estado

- **Ubicación:** `evaluar_condicion_id` / `_evaluate_cache_set` (`progression_manager.gd:336-361`).
- **Problema:** cachea el resultado booleano por `condicion_id` (ID de hito) y lo devuelve en llamadas posteriores sin considerar que las estadísticas/estado hayan cambiado. Si una condición se evaluó `false` y luego pasa a ser `true`, `evaluar_condicion_id` puede seguir devolviendo `false` hasta evicción FIFO por llenado de caché (64 entradas).
- **Riesgo:** resultados obsoletos si algún consumidor confía en esta API para decisiones de progresión/UI. No es el mismo camino que `_reevaluar` (que hoy ni evalúa), pero es una fuente potencial de cálculos incorrectos de umbral/estado.

### 4.3 Heurística agresiva en detección dinámica de imposibles

- **Ubicación:** `_es_imposible_dinamico` (`progression_manager.gd:477-503`), regla `umbral > actual * 10 + 100` (y `*10 + 1000` para `riqueza_acumulada`).
- **Problema:** puede clasificar como "imposible" hitos perfectamente alcanzables a medio/largo plazo (falsos positivos), sesgando diagnósticos; no es un cálculo de alcanzabilidad real.

### 4.4 Cobertura limitada de `progreso_parcial`

- **Ubicación:** `progression_manager.gd:892-901`.
- **Problema:** solo `stat_min` reporta progreso granular; `riqueza_acumulada`, `dias_jugados`, `nivel_modulo`, `coleccion_completa`, `compuesta`, etc., caen a binario 0/1. No es un error aritmético de umbral, pero degrada la precisión de cálculo/visualización de progreso para la mayoría de tipos.

### 4.5 Observación menor (detección de ciclos)

- `_detectar_ciclos_hito_previo` / `_seguir_hito_previo` (`progression_manager.gd:639-671`) comparte y muta `visitadas` en un recorrido que puede no cubrir todos los casos de grafos de dependencias de forma robusta; podría omitir ciclos en configuraciones complejas del catálogo. Impacto bajo con el catálogo actual, pero relevante para escalado.

---

## 5. Dos mejoras sugeridas

### Mejora 1 (crítica, corrección de lógica): validar condición antes de marcar en la reevaluación sucia

- **Problema que resuelve:** F1 — `_reevaluar` marca hitos sin comprobar umbral (`progression_manager.gd:287-294`).
- **Cambio propuesto:**
  1. En `_reevaluar(stat_id)`, reemplazar el marcado directo por: obtener `cond` del hito y llamar a `evaluar_condicion(cond)` (o `evaluar_pura` con estado actual) antes de `marcar_hito`.
  2. Alternativamente, unificar con `reevaluar_sucias` o hacer que `_reevaluar` invoque una rutina común `try_mark_if_met(hito_id)` que sea la única puerta de marcado.
  3. Invalidar/evitar caché obsoleta en el camino de otorgamiento (o no usar `evaluar_condicion_id` cacheado para decisiones de "puede marcarse ahora").
- **Beneficio:** restablece la integridad de umbrales, evita recompensas prematuras y alinea el camino por eventos con el contrato de condiciones.
- **Validación:** `test_bug_reevaluar_m71_hy3.gd` debe pasar a verde; regresión completa con `test_progresion.gd` y `test_flujo_xp_recompensa_m71_hy3.gd`.

### Mejora 2 (robustez de datos): saneamiento y límites en estadísticas/contribución

- **Problema que resuelve:** ausencia de validación de negativos y de límites en `incrementar`/`set_stat`/`cargar` (`player_profile.gd:40-50,101-115`).
- **Cambio propuesto:**
  1. En `incrementar`, aplicar política explícita: o bien rechazar/clampear `cantidad < 0` para stats que deben ser monótonas, o registrar decrementos solo en stats permitidas con `max(0, nuevo_valor)` según diseño.
  2. Clampear `_contribucion = max(0.0, _contribucion)` tras modificaciones y en `cargar` (hoy `cargar` acepta `contribucion` tal cual, `player_profile.gd:114`).
  3. En `cargar`, sanear tipos/rangos (ignorar o normalizar valores no numéricos/NaN/inf, forzar no-negativos donde corresponda) y opcionalmente definir techos razonables para evitar estados corruptos.
  4. Centralizar helpers `add_stat_clamped` / `set_stat_clamped` y usarlos desde `ProgressionManager._stat`.
- **Beneficio:** previene corrupción silenciosa del perfil por eventos erróneos, saves manipulados o bugs de integraciones; hace determinista la reputación y los umbrales dependientes de acumulados.

---

## 6. Conclusión final

El subsistema de progresión analizado (`PlayerProfile` + `ProgressionManager` + `hitos.json`, M71) implementa un modelo **de hitos y estadísticas** (acumulación por eventos de dominio, condiciones data-driven, recompensas y persistencia versionada) en lugar de un sistema clásico de **experiencia/nivel de personaje**; los "niveles" presentes son de módulos externos (herramienta/casa) evaluados como condiciones.

**Hallazgos principales:**
1. **Gestión funcional de progreso por umbrales** con buen soporte de idempotencia al marcar/restaurar, indexación por stat sucia y catálogo extensible.
2. **Validación insuficiente de entradas:** no se rechazan ni normalizan sistemáticamente incrementos/valores negativos ni se imponen límites superiores; `_contribucion` puede persistir negativa aunque la reputación se clampee al calcular.
3. **Problema crítico de cálculo de umbrales (F1):** `_reevaluar` otorga hitos sin revalidar la condición, pudiendo desbloquear hitos de umbral superior prematuramente. Adicionalmente, la caché de `evaluar_condicion_id` puede devolver resultados obsoletos y la detección dinámica de imposibles usa heurísticas propensas a falsos positivos.

**Recomendación:** priorizar la corrección de F1 (validación antes de `marcar_hito` en el camino por eventos y coherencia de caché) y añadir saneamiento/clampeo de estadísticas y contribución en perfil y carga de guardado. Con estas correcciones, el sistema ganaría consistencia fuerte entre eventos, umbrales y persistencia.