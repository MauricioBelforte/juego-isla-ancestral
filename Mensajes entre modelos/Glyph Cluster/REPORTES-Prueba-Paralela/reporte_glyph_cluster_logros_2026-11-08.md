# Reporte: Sistema de Logros / Achievements / Medallas / Desbloqueables
**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code (glyph-cluster)  
**Fecha:** 2026-11-08  
**Alcance analizado:** `game/isla-ancestral/scripts/` (`.gd`) y datos relacionados de logros.

## Archivos relevantes encontrados

| Archivo | Rol | Líneas clave |
|---|---|---|
| `game/isla-ancestral/scripts/logros/achievement_service.gd` | Núcleo del sistema M72 (`AchievementService`, autoload `Achievements`). Carga catálogo, evalúa condiciones, desbloquea, persiste, notifica. | L5-622 (completo). Catálogo: L61-103. Evaluación: L130-234. Desbloqueo: L236-265. Progreso: L322-338. API/UI: L359-437. Validación catálogo: L439-579. Persistencia M59: L582-622. |
| `game/isla-ancestral/data/logros/logros.json` | Catálogo data-driven de logros (schema v2). | L1-285. 18 logros declarados (ids `logro_primer_sello` … `logro_ruina_restaurada`). |
| `game/isla-ancestral/project.godot` | Registro del autoload. | L80: `Achievements="*res://scripts/logros/achievement_service.gd"` |
| `game/isla-ancestral/scripts/logros/test_logros.gd` | Test principal M72 (catalogo, RF14, evento, idempotencia, fechas, API, progreso, %, ocultos, amistad, pesca, persistencia, migración v1, retroactividad, toasts, edge cases, panel). | L1-399 |
| `game/isla-ancestral/scripts/logros/test_logros_rf10_m72.gd` | Test RF10 (API consulta). | Referenciado en grep (usa autoload `Achievements`). |
| `game/isla-ancestral/scripts/logros/test_logros_rf13_m72.gd` | Test RF13 (trazabilidad: analytics/log al desbloquear). | L1-44 (grep). Verifica `AnalyticsDirector.registrar_evento("logro_desbloqueado")`. |
| `game/isla-ancestral/scripts/logros/test_m72_rf6_m72.gd` | Test RF6 (agrupación de toasts). | L1-71 (grep). |
| `game/isla-ancestral/scripts/logros/test_logros_depende_de_m72.gd` | Test de dependencias `depende_de`. | L1+ (grep). |
| `game/isla-ancestral/scripts/logros/test_logros_m72_statids.gd` | Test aditivo de stat IDs (no modifica core). | L11 (grep). |
| `game/isla-ancestral/scripts/logros/test_logros_rf1_e.gd` | Test RF1 (campos catálogo/UI). | L21,43-44 (grep). |
| `game/isla-ancestral/scripts/logros/test_m72_deuda_assets.gd` | Test de deuda de assets (iconos/i18n ausentes). | L28-29 (grep). |
| `game/isla-ancestral/scripts/audio/sfx_manager.gd` | Integración SFX: escucha desbloqueo de logros. | L239: conecta `Achievements.logro_desbloqueado`; L254-256: handler reproduce `"logro"`. |
| `game/isla-ancestral/scripts/audio/test_sfx_m43.gd` | Verifica conexión SFX↔logros. | L297, L314, L365-369 (grep). |
| `game/isla-ancestral/scripts/postgame/test_postgame.gd` | Referencia al autoload `Achievements` en postgame. | L74, L334 (grep). |
| `game/isla-ancestral/scripts/editor/_colector_sintaxis.gd` | Preload del servicio para recolección de sintaxis/editor. | L565 (grep): `preload("res://scripts/logros/achievement_service.gd")`. |

**Búsquedas realizadas:** `**/logro*.gd` (solo tests), `**/achievement*.gd` (encontrado `achievement_service.gd`), `**/medalla*.gd` (sin resultados), grep `logro|achievement|medalla|desbloque` en `scripts/` (100+ matches; se priorizó el dominio de logros M72). No se encontró un sistema paralelo de “medallas” en scripts; las menciones a “desbloqueo” fuera de M72 corresponden a otros sistemas (zonas de combate, gates de herramientas, fast travel, debug, etc.).

## 1) ¿Cómo se gestionan los logros?

- **Arquitectura:** `AchievementService` es un **autoload** global `Achievements` (`project.godot:80`, `achievement_service.gd:5,31,106-109`). No usa `class_name` (nota de pitfall Godot 4 en L30).
- **Catálogo data-driven:** los logros se cargan desde `res://data/logros/logros.json` (`achievement_service.gd:33,61-103`; `logros.json:1-285`, `schema_version: 2`, 18 entradas). Cada entrada define `id`, nombre/desc + claves i18n, `icono`, `categoria`, `orden`, `condicion`, opcionales `oculto`, `progreso_parcial`, `depende_de`, `logro_steam_id`.
- **Modelo en memoria:** `_logros` (definiciones por id), `_desbloqueados` (`Array[String]` en orden de consecución), `_fechas` (`logro_id -> {dia,hora}`), buffer de toasts (`achievement_service.gd:41-52,114-116`).
- **Evaluación event-driven (no por frame):** conecta señales de `ProgressionManager` y de `EventBus` (inventory, economy, npc gift/amistad, quest), además de `Fishing.captura_exitosa` y colecciones; cada evento dispara `evaluar_todos()` (`achievement_service.gd:111-159,182-210`).
- **Notificación/UI:** emite `logro_desbloqueado(logro_id,nombre)`, `logro_progreso`, `panel_solicitado`; envía toast no bloqueante vía `EventBus.ui.notify` con agrupación en frame (`achievement_service.gd:36-39,250,280-315`). `SfxManager` escucha el desbloqueo para reproducir SFX (`sfx_manager.gd:239,254-256`).
- **Trazabilidad:** al desbloquear registra evento en `AnalyticsDirector` (`logro_desbloqueado`) y log en `GameLogger` si existen (`achievement_service.gd:256-262`; verificado por `test_logros_rf13_m72.gd:34-41`).
- **API de consulta:** `evaluar_todos`, `re_evaluar_todo`, `desbloquear`, `esta_desbloqueado/is_unlocked`, `progreso_de`, `get_progreso_humano`, `porcentaje_real/get_porcentaje_completado`, `get_todos/get_estado/get_definicion/get_desbloqueados/get_en_progreso/listado_para_ui`, `fecha_de`, `validar_catalogo` (`achievement_service.gd:212-437,458-579`).

## 2) ¿Hay validación de condiciones para desbloquear logros?

Sí, con validación estructural y evaluación delegada:

- **Delegación de evaluación (sin duplicar lógica):** las condiciones usan el mismo vocabulario/contrato de M71; `AchievementService` delega a `ProgressionManager.evaluar_condicion(cond)` (`achievement_service.gd:7-12,214-223,322-332`). Para progreso `stat_min` consulta `pm.profile.get_stat(...)` (`achievement_service.gd:327-331`).
- **Validación de catálogo al arrancar:** `_cargar_catalogo()` llama `validar_catalogo()` y emite `push_warning` si hay problemas (`achievement_service.gd:98-103`). `validar_catalogo()` revisa: `id` vacío, ids duplicados, `icono` vacío, categoría fuera de vocabulario, `logro_steam_id` duplicado, condición vacía, tipo de condición desconocido, `stat_min` sin `stat_id`, y valida recursivamente hijos de `compuesta` (`achievement_service.gd:439-579`). Los tipos válidos están listados en `TIPOS_CONDICION_VALIDOS` (L442-446) y categorías en `CATEGORIAS_VALIDAS` (L451-455).
- **Condiciones observadas en el catálogo:** `sello_historia`, `stat_min`, `coleccion_completa`, `hito_previo` (`logros.json:13-15,29-31,47-48,77-79,108-109,277-278`, etc.).
- **Gate de dependencias:** antes de desbloquear, verifica que todos los `depende_de` estén desbloqueados (`achievement_service.gd:242-246`; `logros.json:33-35,280-282`). El test dedicado `test_logros_depende_de_m72.gd` existe (grep).
- **Limitación de validación:** `validar_catalogo()` valida **forma/estructura** y tipos conocidos, pero **no prueba alcanzabilidad semántica** de las condiciones (si un `stat_id` se incrementa en runtime, si un `milestone_id/coleccion_id` existe, si el umbral es coherente). Por eso la validación estructural puede pasar con logros difíciles/imposibles de obtener por datos o por falta de productor de stat.

## 3) ¿Hay logros que no se pueden conseguir?

**Evidencia de riesgo alto (potencialmente imposibles o mal mapeados) en el catálogo actual:**

1. **Reuso del mismo `stat_id` (`regalos_dados`) para logros de dominios distintos**, lo que hace que el progreso/desbloqueo no represente la acción descrita:
   - `logro_vecino` (amistad, “un vecino se mudó…”, umbral 1) usa `regalos_dados` (`logros.json:68-80`).
   - `logro_primer_cultivo` (agricultura, “plantaste y cosechaste tu primera semilla”) usa `regalos_dados` umbral 1 (`logros.json:175-187`).
   - `logro_cosecha_diez` (agricultura, 10 cultivos) usa `regalos_dados` umbral 10 (`logros.json:190-203`).
   - `logro_primer_mineral` (minería) usa `regalos_dados` umbral 1 (`logros.json:206-218`).
   - `logro_minero_veterano` (minería, 25 minerales) usa `regalos_dados` umbral 25 (`logros.json:221-234`).
   **Impacto:** no son necesariamente “imposibles” si `regalos_dados` se incrementa, pero **se desbloquearían por dar regalos**, no por cultivar/minar. Además `logro_vecino` y `logro_primer_cultivo` comparten la misma condición, por lo que se obtienen juntos al alcanzar `regalos_dados >= 1`; esto contradice la semántica del logro y puede romper diseño/progresión.

2. **`logro_dias_en_aurora` (“30 días en Aurora”) usa `viajes_realizados` umbral 30** (`logros.json:252-265`), no un stat de días. **Impacto:** se comporta como “30 viajes”, no como “30 días”. Podría ser alcanzable o no según cuántos viajes haga el jugador, pero **no cumple la condición descrita**.

3. **Dependencia de productores de stats externos no validada por RF14:** logros como `logro_coleccionista` (`coleccion_completa`, `flora`, L38-49), `logro_viajero/primera_isla/dias_en_aurora` (`viajes_realizados`, L52-65,237-249,252-265), `logro_amigo_cercano/alma_de_la_isla` (`amistad_max_catalina_oso`, L113-140), `logro_pescador_principiante/mar_adentro_10` (`peces_capturados`, L143-172), etc., dependen de que M71/Progression/Profile y los sistemas productores (pesca, colecciones, navegación, amistad, historia) emitan/incrementen exactamente esos ids. `AchievementService` sí alimenta algunos casos (amistad/pesca, `achievement_service.gd:148-210`), pero **RF14 no verifica existencia/producción de stats, hitos o colecciones**; por tanto, un logro puede quedar inalcanzable si el productor no existe o usa otro id.

4. **No se detectó en este análisis un caso probado como “imposible por código de AchievementService”** (el servicio desbloquea cuando `evaluar_condicion` devuelve true y dependencias OK). La imposibilidad/riesgo proviene principalmente de **mapeo semántico de datos** y de **dependencias externas**.

## 4) ¿Hay persistencia de logros desbloqueados?

Sí, integrada con el sistema de guardado M59:

- **Proveedor de guardado:** `AchievementService` se registra en `SaveManager` (`achievement_service.gd:105-109`) y expone `get_section_name() = "achievements"`, `get_save_data()`, `restore_save_data()` (`achievement_service.gd:584-622`).
- **Formato v2 (actual):** guarda `version: 2` y `desbloqueados` como diccionario `logro_id -> {dia, hora}` (JSON-safe). La fecha es determinista (día/hora de `GameTime` M29, sin reloj real) (`achievement_service.gd:34,236-278,587-594`).
- **Migración v1:** si `desbloqueados` llega como `Array` (formato viejo sin fechas), migra a v2 usando fecha placeholder `{-1,-1}` (`achievement_service.gd:597-609`; test `test_logros.gd:280-287`).
- **Restauración segura:** ignora/purga logros desconocidos del catálogo viejo, limpia estado antes de restaurar, **no re-emite señales** de logros restaurados, y dispara `re_evaluar_todo()` diferido para retroactividad (`achievement_service.gd:597-622`; tests `test_logros.gd:262-296`).
- **Write-through:** tras cada desbloqueo llama `SaveManager.mark_dirty()` si existe (`achievement_service.gd:252-255`).
- **Cobertura de tests:** round-trip, restore vacío, purga de ids viejos, migración v1, fechas persistidas, retroactividad RF5 (`test_logros.gd:262-296,364-383`).

## 5) Sugerencias de mejora (2)

1. **Auditoría y corrección de mapeo `stat_id`/condiciones del catálogo (alta prioridad).** Corregir logros cuyo stat no corresponde a la acción descrita, especialmente los que usan `regalos_dados` para agricultura/minería y `viajes_realizados` para “30 días”. Definir o reutilizar stats específicos (`cultivos_cosechados`, `minerales_extraidos`, `dias_jugados`/stat equivalente) y asegurar que los sistemas productores los incrementen. Agregar un test de contrato que falle si un logro de categoría `agricultura/mineria/progresion` usa un `stat_id` semánticamente incompatible (lista blanca por categoría o por logro). Esto evita logros engañosos o percibidos como imposibles.

2. **Extender `validar_catalogo()` (RF14) con validación de alcanzabilidad referencial en modo diagnóstico.** Manteniendo la validación estructural actual, añadir checks opcionales/no bloqueantes al arranque o en tests: existencia de `stat_id` conocidos en el perfil/progresión, existencia de `milestone_id`/`coleccion_id` referenciados (cuando los catálogos estén disponibles), y detección de condiciones duplicadas entre logros distintos. Reportar como `[M72][RF14][WARN]` con acción sugerida. Complementar con el test de deuda de assets ya existente (`test_m72_deuda_assets.gd`) y una verificación de que los PNG de `icono` realmente existen en disco (el servicio ya expone `iconos_ausentes()`, `achievement_service.gd:520-530`), para que los logros no queden “desbloqueables” pero invisibles/rotos en UI.

## Conclusión final

El proyecto **sí cuenta con un sistema de logros centralizado y bastante maduro** (M72, autoload `Achievements`) en `game/isla-ancestral/scripts/logros/achievement_service.gd`, con catálogo JSON, evaluación event-driven delegada a M71, dependencias, soporte de logros ocultos/progreso parcial, toasts accesibles, trazabilidad, API completa y **persistencia robusta** (M59 v2 + migración v1 + retroactividad). No se halló un subsistema separado de “medallas” en scripts. La principal debilidad observada no está en el motor de desbloqueo, sino en el **catálogo de datos**: varios logros usan `stat_id` que no coinciden con su descripción (agricultura/minería y “30 días” mapeados a `regalos_dados`/`viajes_realizados`), lo que puede producir desbloqueos incorrectos o experiencias percibidas como logros imposibles/engañosos. Además, RF14 valida forma pero no alcanzabilidad referencial de stats/hitos/colecciones. Priorizar la corrección del mapeo de condiciones y una validación referencial diagnóstica reduciría significativamente el riesgo funcional del sistema.
