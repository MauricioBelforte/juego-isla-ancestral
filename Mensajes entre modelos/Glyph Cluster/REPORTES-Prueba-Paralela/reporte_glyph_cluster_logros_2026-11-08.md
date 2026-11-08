# Reporte — Sistema de Logros / Achievements

**Modelo:** Glyph Cluster  
**Fecha:** 2026-11-08  
**Alcance analizado:** `game/isla-ancestral/scripts/logros/`, `game/isla-ancestral/data/logros/logros.json`, `game/isla-ancestral/project.godot`, integraciones visibles en `scripts/audio/*`, `scripts/postgame/*`, `scripts/progresion/*` y tests de `scripts/logros/*`.

## Archivos relevantes

| Archivo | Rol observado | Líneas clave |
|---|---|---|
| `game/isla-ancestral/scripts/logros/achievement_service.gd` | Núcleo del sistema (autoload `Achievements`). Carga catálogo, valida condiciones, evalúa, desbloquea, persiste, notifica. | `5-30` diseño; `33-102` carga/validación; `111-158` conexiones event-driven; `213-265` evaluación/desbloqueo; `321-338` progreso; `343-437` API/UI; `439-579` validación de catálogo; `584-622` persistencia M59. |
| `game/isla-ancestral/data/logros/logros.json` | Catálogo data-driven de 18 logros (`schema_version: 2`). Define id, i18n, icono, categoría, orden, condición, oculto y dependencias. | `1-285` catálogo completo; dependencias en `33-35` y `280-282`; oculto en `98-110`; progresos parciales en `52-66`, `143-157`, `159-173`, `190-204`, `221-235`, `252-266`. |
| `game/isla-ancestral/project.godot` | Registra el servicio como autoload global. | `80` → `Achievements="*res://scripts/logros/achievement_service.gd"`. |
| `game/isla-ancestral/scripts/logros/test_logros.gd` | Suite principal endurecida (72 checks mínimos, 20 bloques). Cubre catálogo, RF14, evento, idempotencia, fechas, API, progreso, porcentaje, ocultos, amistad, pesca, persistencia, migración, retroactividad, toasts RN7, doble desbloqueo, compuesta, cache, guardado RF9 y panel RF7. | `1-399`; checks mínimos en `20-31,92-95`. |
| `game/isla-ancestral/scripts/logros/test_logros_depende_de_m72.gd` | Verifica gate `depende_de` (RF2): no desbloquea sin dependencia, desbloquea con dependencia cumplida, idempotencia. | `1-55`; casos clave `37-52`. |
| `game/isla-ancestral/scripts/logros/test_logros_rf10_m72.gd` | Verifica API de consulta RF10: `is_unlocked`, `get_definicion`, `get_todos`, `get_estado`. | `1-104`; contrato id inexistente → dict vacío en `50-59`. |
| `game/isla-ancestral/scripts/logros/test_logros_rf13_m72.gd` | Verifica trazabilidad RF13: desbloqueo registra evento en `AnalyticsDirector` (M104). | `1-44`; aserción en `34-41`. |
| `game/isla-ancestral/scripts/logros/test_logros_m72_statids.gd` | Test adicional de stat IDs (presente en carpeta). No leído en detalle por límite de foco; existe como evidencia de cobertura específica de stats. | Archivo detectado. |
| `game/isla-ancestral/scripts/logros/test_logros_rf1_e.gd` | Test adicional RF1. No leído en detalle. | Archivo detectado. |
| `game/isla-ancestral/scripts/audio/sfx_manager.gd` | Integración de feedback sonoro: escucha `Achievements.logro_desbloqueado`. | `239` conexión; `255-256` handler. |
| `game/isla-ancestral/scripts/audio/test_sfx_m43.gd` | Verifica conexión SFX ↔ logro desbloqueado. | `297`, `314`. |
| `game/isla-ancestral/scripts/postgame/test_postgame.gd` | Consume definiciones de logros para validar contenido postgame (usa `get_definicion`/`get_todos`). | `74`, `334`, `340`, `352`. |
| `game/isla-ancestral/scripts/progresion/progression_manager.gd` | Fuente delegada de evaluación de condiciones (`evaluar_condicion`) y stats de progresión. M72 depende de este contrato M71. | Conexiones de stats `149-175`; `dias_jugados` soportado `278,449,570,688,711,861`; `evaluar_condicion` `702-730`; `progreso_parcial` `874-885`. |

## 1) ¿Cómo se gestionan los logros?

**Arquitectura:** el sistema está centralizado en un autoload `Achievements` (`project.godot:80`) implementado por `achievement_service.gd`. No hay `class_name` porque es autoload (`achievement_service.gd:30-31`).

**Catálogo data-driven:** los logros se cargan desde `res://data/logros/logros.json` (`achievement_service.gd:33,61-102`; `logros.json:1-285`). Cada entrada incluye metadatos de presentación (`nombre_i18n`, `descripcion_i18n`, `icono`, `categoria`, `orden`, `oculto`), condición evaluable y dependencias (`depende_de`). El servicio conserva el `id` dentro de la definición para evitar el residuo histórico donde `get_definicion()` no lo incluía (`achievement_service.gd:74-96`).

**Modelo de estado:** mantiene `_logros` (definiciones), `_desbloqueados` (orden de consecución) y `_fechas` por logro (`achievement_service.gd:41-46`). La fecha es determinista usando `GameTime.dia_absoluto()`/`get_hora()` y evita reloj real (`achievement_service.gd:268-277`). Esto soporta persistencia estable y retroactividad.

**Evaluación:** es **event-driven**, nunca por frame (`achievement_service.gd:111-158`). Se conecta a `ProgressionManager` (`progreso_hito_alcanzado`, `progreso_desbloqueado`) y a señales de dominio vía `EventBus` (`inventory.item_added`, `economy.purchase_done`, `npc.gift_given`, `quest.quest_completed`, `npc.friendship_level_up`), además de `Fishing.captura_exitosa` y `coleccionables.categoria_completed`. Ante eventos relevantes llama `evaluar_todos()`.

**Desbloqueo:** `desbloquear()` es idempotente (`achievement_service.gd:239-265`). Comprueba existencia, estado previo y dependencias (`depende_de`, `242-246`). Al desbloquear: agrega id, registra fecha, emite `logro_desbloqueado`, loguea `[DOM-LOGRO]`, hace write-through con `SaveManager.mark_dirty()`, registra analytics en `AnalyticsDirector` (RF13), registra log en `GameLogger` y emite toast no bloqueante por `EventBus.ui.notify` (RF6) + `panel_solicitado` (RF7).

**Progreso/UI:** expone `progreso_de()`, `get_progreso_humano()` (“X de Y”), `porcentaje_real()`, `get_todos()`, `get_estado()`, `get_desbloqueados()`, `get_en_progreso()`, `listado_para_ui()` (`achievement_service.gd:321-437`). Los logros ocultos no desbloqueados se muestran como `???` (`397-401`).

**Persistencia M59:** implementa `get_section_name/get_save_data/restore_save_data` con sección `"achievements"` y versión 2 (`achievement_service.gd:584-622`). Guarda solo JSON-safe. Migra formato v1 (array sin fechas) a v2 (`601-607`). Tras restaurar no re-emite señales de logros ya restaurados y lanza `re_evaluar_todo()` diferido para retroactividad RF5 (`620-622`).

## 2) ¿Hay validación de condiciones para desbloquear logros?

**Sí, hay validación en dos niveles:**

1. **Validación de catálogo al arrancar (`validar_catalogo`, RF14):** se ejecuta tras cargar `logros.json` (`achievement_service.gd:99-102,458-579`). Detecta problemas accionables:
   - id vacío (`467-471`).
   - id duplicado (`472-475`).
   - icono vacío (`476-479`).
   - categoría fuera del vocabulario cerrado (`480-485`, vocabulario en `451-455`).
   - `logro_steam_id` duplicado (`486-493`).
   - condición vacía (`494-498`).
   - tipo de condición desconocido frente a vocabulario M71 (`441-446,566-572`).
   - `stat_min` sin `stat_id` (`573-575`).
   - validación recursiva de condiciones compuestas (`576-578`).

2. **Validación/delegación de evaluación en runtime:** la condición de cada logro se evalúa delegando a `ProgressionManager.evaluar_condicion()` (`achievement_service.gd:10-12,213-223,321-332`). `ProgressionManager` soporta tipos como `stat_min`, `dias_jugados`, `sello_historia`, `capitulo_historia`, `riqueza_acumulada`, `primera_vez`, `hito_previo`, `coleccion_completa`, `nivel_modulo`, `compuesta` (`progression_manager.gd:702-730`, también validaciones en otras zonas del archivo). M72 no duplica lógica de evaluación.

**Validación adicional de dependencias:** `desbloquear()` aplica gate `depende_de` antes de otorgar (`achievement_service.gd:242-246`), cubierto por `test_logros_depende_de_m72.gd:37-52`.

**Deuda/dependencias externas reportadas (no error de forma):** `iconos_ausentes()` y `claves_i18n_ausentes()` miden recursos faltantes fuera del formato del catálogo (`achievement_service.gd:503-563`). Esto es útil, pero no bloquea por sí mismo salvo que el flujo consumidor lo trate como error.

## 3) ¿Hay logros que no se pueden conseguir?

**No encontré evidencia de un bloqueo absoluto en el núcleo de desbloqueo**, pero sí hay **riesgos fuertes de inconsistencia de catálogo/estado** que pueden hacer que varios logros no se obtengan en condiciones normales o no representen lo que su texto promete.

### Hallazgos concretos

1. **Catálogo usa `stat_id` no alimentados por el progreso estándar para agricultura/minería/días.**
   - `logro_primer_cultivo` y `logro_cosecha_diez` usan `stat_min` sobre `regalos_dados` (`logros.json:175-203`), aunque sus descripciones hablan de plantar/cosechar (`178-179,194`). `regalos_dados` sí se incrementa con `npc.gift_given` (`progression_manager.gd:156-157`), por lo que estos logros **se desbloquearían por regalar**, no por cosechar.
   - `logro_primer_mineral` y `logro_minero_veterano` usan `regalos_dados` (`logros.json:206-234`), aunque describen extraer minerales (`210,225`).
   - `logro_dias_en_aurora` usa `stat_min` sobre `viajes_realizados` con umbral 30 (`logros.json:252-265`), mientras su descripción dice “30 días en Aurora” (`256`). El evaluador M71 sí soporta `dias_jugados` (`progression_manager.gd:278-281,711-714`), pero el catálogo **no lo usa** aquí.
   - **Impacto:** estos logros pueden ser **obtenibles por la stat equivocada** o **difíciles/imposibles según el sentido narrativo**. Desde diseño funcional, son candidatos a “logros mal cableados”; desde código, dependen de que alguien produzca `regalos_dados`/`viajes_realizados`, no de agricultura/minería/días.

2. **Todos los iconos declarados faltan en disco.**
   - Comprobación sobre `logros.json`: los 18 PNG declarados bajo `res://assets/ui/logros/*.png` no existen (`assets/ui/logros/` no existe). `achievement_service.iconos_ausentes()`/arranque lo reportan como deuda (`achievement_service.gd:503-530`), pero no impide desbloquear. Aun así, afecta visibilidad/UI y puede romper presentación si la UI asume textura válida.

3. **Dependencia externa de claves i18n.**
   - El catálogo declara `LOGROS.*.NOMBRE/DESC` para todos los logros (`logros.json:6-7`, etc.). `claves_i18n_ausentes()` revisa `res://locales/es.po` (`achievement_service.gd:532-563`). No verifiqué exhaustivamente cada clave en `.po`; si faltan, la UI puede mostrar claves crudas o fallback, sin impedir desbloqueo.

4. **Cobertura de integración limitada fuera del núcleo.**
   - Encontré integración de audio con `logro_desbloqueado` (`sfx_manager.gd:239,255-256`; tests SFX) y uso en postgame/tests. No encontré referencias externas a `Achievements/listado_para_ui/get_todos/panel_solicitado` fuera de `scripts/logros`, `scripts/audio`, `scripts/postgame` y `project.godot` en la búsqueda realizada. Esto **no prueba imposibilidad de obtención**, pero sugiere que la presentación/UI de logros puede estar incompleta o desacoplada; un logro desbloqueado podría no ser visible al jugador si no hay panel consumidor.

5. **El validador RF14 no detecta incoherencias semánticas de stats.**
   - RF14 valida forma (id, icono declarado, categoría, tipo, `stat_min` con `stat_id`) pero no valida que el `stat_id` sea uno efectivamente emitido por gameplay/progression para ese logro (`achievement_service.gd:458-579`). Por eso los casos de agricultura/minería/días pueden pasar validación formal y aun así estar semánticamente mal conectados.

**Conclusión sobre imposibilidad:** no hay un logro con condición vacía o tipo inválido en el catálogo actual según RF14; el gate `depende_de` es correcto y testeado. Sin embargo, **5 logros** (`logro_primer_cultivo`, `logro_cosecha_diez`, `logro_primer_mineral`, `logro_minero_veterano`, `logro_dias_en_aurora`) presentan **mapeo de stats inconsistente con su descripción/objetivo** y deben considerarse **de alto riesgo de no ser conseguibles como se espera** hasta alinear catálogo y fuentes de stats.

## 4) Dos mejoras sugeridas

### Mejora 1 — Validación semántica de `stat_id` y coherencia catálogo↔progresión
**Problema:** RF14 valida forma, pero no que `stat_min.stat_id` corresponda a una estadística real/esperada para el dominio del logro (`achievement_service.gd:573-575` no cruza con stats disponibles). Esto permitió casos como cultivos/minería usando `regalos_dados` y “30 días” usando `viajes_realizados` (`logros.json:175-266`).

**Mejora propuesta:**
- Añadir en `validar_catalogo()` una lista/blanco de `stat_id` conocidos (o consultar a `ProgressionManager`/registro de stats si existe) y emitir warning accionable cuando un `stat_id` no sea reconocido.
- Añadir regla semántica opcional por categoría: `agricultura` debería usar stats de cultivo/cosecha, `mineria` de extracción/mineral, `progresion` temporal debería considerar `dias_jugados` cuando la descripción hable de días.
- Corregir el catálogo: crear/conectar stats reales (`cultivos_cosechados`, `minerales_extraidos`, `dias_jugados`/`dias_en_aurora`) y cambiar las condiciones de los 5 logros afectados.
- Añadir test de regresión que falle si un logro usa `regalos_dados`/`viajes_realizados` en categorías donde esa stat no tiene sentido.

**Beneficio:** evita logros “falsos positivos” o imposibles por cableado incorrecto, sin debilitar la validación actual.

### Mejora 2 — Exponer deuda de assets/i18n como reporte estructurado y gate opcional de QA
**Problema:** los iconos y claves i18n faltantes se detectan/reportan (`achievement_service.gd:503-563`), pero no hay salida estructurada consumible por herramientas/QA ni política clara de severidad. Actualmente faltan los 18 iconos declarados, lo que puede degradar la UI.

**Mejora propuesta:**
- Hacer que `validar_catalogo()` devuelva o exponga un `Dictionary` detallado: `{problemas_forma, iconos_ausentes, claves_i18n_ausentes, ids_afectados}` además del conteo entero (manteniendo compatibilidad con el retorno actual si se necesita).
- Añadir un modo estricto para CI/headless (`validar_catalogo(estricto_assets=false/true)`) donde assets/i18n faltantes puedan contar como fallo en entornos de release, pero no en prototipo.
- Integrar con el pipeline de M154/UI: test que verifique que cada logro visible tenga icono resoluble y claves traducibles antes de sellar el módulo.
- Registrar evidencia en logs/QA con ids afectados para facilitar corrección artística.

**Beneficio:** convierte deuda invisible en deuda medible y accionable, reduce sorpresas en UI y mejora la confiabilidad del módulo sin romper el flujo actual de desarrollo.

## Conclusión final

El sistema de logros está **bien estructurado para V0/V1**: autoload `Achievements` registrado (`project.godot:80`), catálogo data-driven (`logros.json`), evaluación event-driven delegada a M71, desbloqueo idempotente con dependencias, fechas deterministas, persistencia M59 con migración v1→v2, retroactividad, toasts/accesibilidad, trazabilidad analytics/log y una batería de tests amplia en `scripts/logros/`.

No observé un fallo obvio que impida desbloquear **todos** los logros por diseño del núcleo; las dependencias testeadas y la validación formal funcionan. Sin embargo, el estado actual presenta **riesgo funcional alto** en 5 logros cuyo `stat_id` no coincide con la intención descrita (`cultivo/minería/días` mapeados a `regalos_dados`/`viajes_realizados`) y **deuda de presentación** total en iconos (18/18 ausentes). Recomendación: priorizar la alineación semántica catálogo↔stats antes de considerar el sistema de logros confiable para gameplay y QA visual.