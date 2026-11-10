# Reporte de análisis: Progresión, experiencia, niveles y habilidades

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code (Vercel AI Gateway)  
**Fecha:** 2026-11-09  
**Alcance solicitado:** `game/isla-ancestral/scripts/` — archivos `.gd` relacionados con progresión/experiencia/niveles/habilidades.

## Archivos analizados

| Archivo | Rol |
|---|---|
| `game/isla-ancestral/scripts/progresion/progression_manager.gd` | Autoload `ProgressionManager`: catálogo de hitos, evaluación de condiciones, dirty-flag/re-evaluación, desbloqueos, títulos, persistencia (M71). |
| `game/isla-ancestral/scripts/progresion/player_profile.gd` | Autoload `PlayerProfile`: estadísticas acumuladas/diarias, primeras veces, contribución y reputación. |
| `game/isla-ancestral/data/progresion/hitos.json` | Catálogo data-driven de hitos (25+ entradas), condiciones y recompensas. |
| `game/isla-ancestral/scripts/progresion/test_progresion.gd` | Suite de tests M71 (agnes). |
| `game/isla-ancestral/scripts/progresion/test_nivel_herramienta.gd` | Test del puente `herramienta_equipada` → `nivel_herramienta_cambio`/stats monotónicas (M13/M71). |
| `game/isla-ancestral/scripts/progresion/test_flujo_xp_recompensa_m71_hy3.gd` | Test de flujo XP/recompensa e idempotencia (Hy3); documenta el defecto F1. |
| `game/isla-ancestral/project.godot` (líneas relevantes) | Registro de autoloads `PlayerProfile` y `ProgressionManager`. |

**Nota:** No se encontraron módulos dedicados `scripts/xp/`, `scripts/nivel/` ni `scripts/habilidades/`/skills de gameplay en el proyecto (los `skill_tree`/`exp_progression` hallados pertenecen a `.claude/skills/`, no al runtime del juego). La “experiencia/subida de nivel” se modela principalmente como **estadísticas acumuladas + hitos/milestones** (M71) y **niveles de herramienta/casa** (`nivel_modulo`, M13/M18).

## 1) ¿Cómo se gestiona la experiencia y la subida de nivel?

- **Acumulación tipo XP/estadísticas:** `PlayerProfile.incrementar(stat_id, cantidad)` suma al total y al contador diario (`_totales`, `_dia`) y marca la estadística como sucia (`_sucias`). Casos especiales: `monedas_ganadas` incrementa también `_contribucion` (`player_profile.gd`, L31-L37).
- **Ingesta por eventos de dominio:** `ProgressionManager._conectar_eventos()` conecta señales del `EventBus` y autoloads (inventario `item_added` → `items_recolectados`, compras → `monedas_gastadas`, regalos, misiones, amistad, viajes, calendario `day_started` → `reset_dia`, economía `transaccion_registrada` → `monedas_ganadas` en depósitos/trueque_ingreso, `Barter.trueque_exitoso` → `trueques_realizados`) (`progression_manager.gd`, L147-L182, L224-L238). Cada evento llama `_stat()` que incrementa el perfil y dispara `_reevaluar(stat_id)` (L241-L244).
- **“Subida de nivel” por hitos:** Los hitos se definen en `hitos.json` con condiciones (`stat_min`, `riqueza_acumulada`, `dias_jugados`, `sello_historia`, `coleccion_completa`, `hito_previo`, `primera_vez`, `compuesta`, `nivel_modulo`, etc.). Al cumplirse (vía evaluación/marcado), `marcar_hito()` es idempotente, emite `progreso_hito_alcanzado`, entrega recompensas (`info`/`unlock`/`titulo`) y activa desbloqueos/títulos (`progression_manager.gd`, L791-L838). Ejemplos en `hitos.json`: umbrales como `items_recolectados >= 10/50`, `misiones_completadas >= 1/5/10`, `monedas_ganadas >= 500/2000`, días jugados, etc.
- **Niveles de módulo/herramienta:** El tipo `nivel_modulo` consulta `ToolController.obtener_nivel_herramienta` o `CasaManager.obtener_nivel_casa` (`progression_manager.gd`, L729-L730, L753-L773, L351-L375). El puente M13/M71 escucha `herramienta_equipada`, emite `EventBus.progresion.nivel_herramienta_cambio(tool_id, nivel)` y mantiene estadísticas monotónicas `nivel_<tool>` (solo suben si el nivel es mayor) (`progression_manager.gd`, L192-L222). `test_nivel_herramienta.gd` valida el comportamiento monotónico (L51-L58).
- **Reputación (no un “nivel” clásico):** `PlayerProfile.reputacion()` combina 60% amistad + 40% contribución normalizada (`CONTRIBUCION_META = 2000`) con clamp a 0..1 (`player_profile.gd`, L16-L21, L70-L76).
- **Persistencia:** `ProgressionManager` registra proveedor de guardado (M59), serializa/restaura hitos, desbloqueos, stats del perfil, contribución y títulos; purga hitos de catálogos antiguos al restaurar y **no re-emite señales** de hitos restaurados (`progression_manager.gd`, L908-L959).

## 2) ¿Hay validación de valores de experiencia negativos o desbordamiento?

**Validación de negativos: insuficiente / ausente en la capa de estadísticas.**
- `PlayerProfile.incrementar()` acepta `cantidad: int = 1` y aplica `+ float(cantidad)` sin `max(0, ...)` ni rechazo de negativos (`player_profile.gd`, L31-L37). Un valor negativo reduce `_totales`/`_dia`; para `monedas_ganadas` también reduce `_contribucion` (L35-L36). Esto permite corrupción lógica (stats/hitos “deshechos” en la contabilidad interna) si algún emisor envía montos negativos o por bug/exploit de integración.
- `PlayerProfile.set_stat()` asigna cualquier `Variant` sin validación de tipo/rango (`player_profile.gd`, L39-L41).
- `PlayerProfile.cargar()` restaura valores tal cual desde `data` (`player_profile.gd`, L104-L116), sin sanear negativos/NaN/tipos inesperados.
- **Mitigación parcial:** `reputacion()` clampea componentes normalizados a `[0,1]` (`player_profile.gd`, L71-L76), por lo que la UI de reputación no se desborda; pero el dato base (`_contribucion`, stats) puede quedar inconsistente.

**Desbordamiento (overflow): no hay guardas explícitas.**
- No se observan comprobaciones de límites máximos (`INT_MAX`/saturación) en incrementos o en el catálogo (umbrales llegan a 2000+; razonables). GDScript maneja enteros de 64 bits y `float` de 64 bits, por lo que el riesgo práctico de overflow numérico es bajo en gameplay normal, pero no existe política de saturación/validación defensiva ante valores extremos o datos corruptos de guardado.

**Validaciones existentes (parciales, no de XP negativa):** `ProgressionManager.validar_catalogo()` detecta umbrales negativos en `stat_min`/`riqueza_acumulada`/`dias_jugados`/`nivel_modulo` (`progression_manager.gd`, L564-L572, L587-L588, L680-L691) — buena defensa del **catálogo**, pero no protege los **valores runtime** del perfil.

## 3) ¿Hay problemas de cálculo de niveles o umbrales?

Sí, se identifican problemas relevantes:

1. **Defecto F1 — reevaluación por evento marca hitos sin verificar umbral (alto impacto en lógica de “subida”).**  
   - `_reevaluar(stat_id)` recorre los hitos dependientes y, si no están alcanzados, llama `marcar_hito(hito_id)` **sin evaluar la condición** (`progression_manager.gd`, L247-L253). `marcar_hito()` solo comprueba idempotencia/existencia y otorga el hito (L791-L808).  
   - En contraste, `reevaluar_sucias()` sí evalúa `evaluar_condicion(cond)` antes de marcar (L408-L416), y `evaluar_condicion()` implementa correctamente los umbrales (L702-L750).  
   - **Consecuencia:** cualquier evento que toque una estadística “sucia” asociada puede otorgar hitos ligados a esa stat aunque no se cumpla el umbral (hitos marcados prematuramente). Esto está reconocido en el runtime test: `test_flujo_xp_recompensa_m71_hy3.gd` imprime `[NOTA] F1: hito_items_50 marcado prematuramente (defecto _reevaluar)` (L116-L120). Afecta la corrección de progresión/niveles por milestones.

2. **Caché de evaluación sin invalidación ante cambios de estado (riesgo de umbrales obsoletos).**  
   - `evaluar_condicion_id()` devuelve un resultado cacheado por clave si existe (`progression_manager.gd`, L380-L389) y `_evaluate_cache_set()` lo almacena con evicción simple al superar `CACHE_MAX_SIZE = 64` (L392-L405).  
   - No se observa invalidación del caché cuando cambian stats, día, sellos, colecciones, etc. Si una condición pasa a ser verdadera más tarde, el caché puede seguir devolviendo `false` (o viceversa según uso), produciendo decisiones desactualizadas. `reevaluar_sucias()` no limpia el caché.

3. **Heurística “imposible dinámico” demasiado agresiva (falsos positivos).**  
   - `_es_imposible_dinamico()` marca `stat_min` como imposible si `umbral > actual * 10 + 100` (y regla similar para riqueza) (`progression_manager.gd`, L489-L512). Esto depende del valor actual (p. ej. actual=0 → umbrales >100 se consideran imposibles), lo que puede clasificar erróneamente hitos legítimos de progresión temprana como imposibles. Útil solo como señal aproximada; no debería usarse como verdad bloqueante.

4. **`_detectar_ciclos_hito_previo()` recorre dependencias de forma limitada.**  
   - Solo sigue `hito_previo` cuando aparece dentro de condiciones `compuesta` (L630-L641); un `hito_previo` como condición raíz directa no se recorre en esa función. Además `return false` al agotar profundidad (L621-L622) puede ocultar ciclos profundos. Impacto acotado al tamaño actual del catálogo, pero es una fragilidad del validador.

5. **Limpieza de caché LRU simplificada.**  
   - `_evaluate_cache_set()` borra siempre la “primera” clave iterada al exceder capacidad (L396-L404), no una LRU real basada en acceso; comportamiento de eviction subóptimo (no afecta corrección funcional inmediata, sí predictibilidad).

## 4) Dos mejoras sugeridas

1. **Corregir F1 y sanear entradas de XP/stats (correctitud + robustez).**  
   - En `ProgressionManager._reevaluar(stat_id)`, evaluar la condición antes de marcar: p. ej. obtener `cond` del hito y llamar `marcar_hito()` solo si `evaluar_condicion(cond)` es `true`, o delegar en `evaluar_condicion_id()` **con caché invalidado** para ese hito/stat. Añadir un test que reproduzca el caso (incrementos parciales no deben disparar hitos de umbral mayor). (`progression_manager.gd`, L247-L253).  
   - En `PlayerProfile.incrementar()`, rechazar o clampear `cantidad < 0` según la semántica deseada (p. ej. `cantidad = maxi(cantidad, 0)` para stats acumulativas) y evitar que `_contribucion` baje de 0; validar tipos en `set_stat()`/`cargar()`. (`player_profile.gd`, L31-L41, L104-L116). Esto cierra el hueco de “XP negativa” en runtime.

2. **Invalidación explícita del caché de condiciones y endurecimiento de validación dinámica.**  
   - Implementar `invalidar_cache()` (total o por `stat_id`/hitos dependientes usando `_condiciones_por_hito`) y llamarlo desde `_stat()`, `restore_save_data()`, `reset_dia` y tras eventos que afectan sellos/colecciones/capítulos. Alternativamente, no cachear condiciones dependientes de estado volátil o versionar el caché con un contador de “dirty global”. (`progression_manager.gd`, L43-L45, L241-L245, L378-L405, L933-L959).  
   - Ajustar `_es_imposible_dinamico()` para no declarar imposibles por comparación relativa cuando `actual` es muy bajo; usar límites absolutos configurables o marcar como “heurístico/no concluyente” en vez de “imposible”, evitando falsos positivos en progresión temprana. (`progression_manager.gd`, L489-L512).

## Conclusión final

El proyecto **no implementa un sistema clásico de XP con barra de nivel del jugador** en `scripts/progresion/`; gestiona la progresión mediante `PlayerProfile` (estadísticas acumuladas/diarias, primeras veces, contribución/reputación) y `ProgressionManager` (hitos data-driven en `hitos.json`, evaluación de 11 tipos de condición, recompensas/desbloqueos/títulos, puente de niveles de herramienta/casa y persistencia M59). 

**Fortalezas:** diseño event-driven con dirty flags, idempotencia de hitos, no re-emisión al restaurar, catálogo JSON versionable y validadores estáticos/bloqueantes parciales. 

**Riesgos principales:** (1) **F1** — `_reevaluar()` otorga hitos sin verificar umbral, pudiendo marcar progresión prematura (confirmado por test Hy3); (2) **sin validación de XP/estadísticas negativas** en `PlayerProfile.incrementar`/`set_stat`/carga, con posible corrupción de stats/contribución; (3) **caché de condiciones sin invalidación**, que puede devolver resultados obsoletos; (4) overflow sin guardas explícitas (riesgo práctico bajo, pero sin defensa). Las dos mejoras propuestas (arreglar F1 + saneamiento de inputs; invalidación de caché + validación dinámica más segura) abordan los problemas de mayor impacto en la corrección de niveles/umbrales y la integridad de la progresión.
