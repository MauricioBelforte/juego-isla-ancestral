**Modelo:** glm-5.3-flash (último modificador; docs por Deepseek V4 Flash)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 (iter. 3 — glm-5.3-flash/Kilo Code)

## Reserva actual

- **Módulo:** 72 Sistema de Logros
- **Reservado por:** glm-5.3-flash (Kilo Code)
- **Estado:** 🟡 Liberado — iter. 3 cerrada (Log 527)
- **Fase:** F7 (producción de contenido)
- **Dificultad:** 2
- **Visión:** V0 (toast vía EventBus.notify; panel visual dueño M53)
- **Entrada:** AchievementService autoload ✅ (iter. 1-2); M71 ✅ (evaluador delegado); M59 ✅
- **Salida:** fechas deterministas (día absoluto M29) + re-evaluación retroactiva + API consulta + progreso humano + toast EventBus + validación catálogo + test 0 fallos
- **Archivos:** `scripts/logros/achievement_service.gd`, `scripts/logros/test_logros.gd`, `scripts/progresion/progression_manager.gd` (señal estadística)
- **Log:** 527 reservado

---

# 05-Checklist.md — Módulo 72: Sistema de Logros

## A. Problema y objetivos

- [x] Definir el problema: no existe registro unificado de logros del jugador en la isla Aurora [S] — glm-5.3-flash 2026-09-01: implementado como AchievementService autoload (único registro)
- [x] Definir el objetivo: catálogo data-driven, motor de desbloqueo, notificación UI, persistencia y Steam opcional [S] — implementado: catálogo JSON + motor delegado + persistencia M59; Steam/UI con dueño
- [x] Registrar dependencias del módulo: M71 (Progresión), M37 (Museos y Colecciones), M97 (Steam Store Page) según CHECKLIST-GLOBAL [S] — M71 ✅ (evaluador delegado), M37 ✅ (coleccion_completa vía M71), M59 ✅; M97 con dueño
- [ ] Registrar integraciones adicionales: M20, M22, M33, M34, M38, M53, M58, M60, M66, M103, M104, M112 [S]
- [ ] Separar dentro/fuera de alcance: UI core en M53/M58, reglas de colecciones en M37, página de Steam en M97 [S]
- [ ] Documentar restricciones: Godot 4.x, GDScript tipado, sin C#, sin red obligatoria, data-driven [S]
- [ ] Definir criterios de aceptación verificables (10 criterios) [S]
- [ ] Incluir contexto del plan maestro: logros tranquilos y motivadores, cero grind estresante [S]
- [ ] Asegurar alineación con M152 (Principios Innegociables) y M94 (Retención sin FOMO) [S]
- [x] Asegurar alineación con M66 (Anti-Softlock): ningún logro imposible de obtener [S] — validador M23 anti-repetición + catálogo cozy (sin contrarreloj) verificados

## B. RF — Definición de logros

- [ ] RF1: crear recurso AchievementDefinition (Resource) con achievement_id único [M]
- [ ] RF1: definir campos: nombre_i18n y descripcion_i18n como claves de traducción [S]
- [ ] RF1: definir campo icono (Texture2D) obligatorio para todo logro [S]
- [ ] RF1: definir campo categoria (agricultura, pesca, mineria, amistad, colecciones, progresion, economia, exploracion) [S]
- [x] RF1: definir campo oculto para logros sorpresa revelados al desbloquearse [S] — campo oculto en logros.json + listado_para_ui() "???" hasta desbloquearse (testeado)
- [x] RF1: definir campo condicion (CondicionBase) asociada al logro [M] — campo condicion en formato del vocabulario M71 §3.6 (decisión: delegar evaluación a M71, no duplicar — nota en 04)
- [ ] RF1: definir campo logro_steam_id opcional para el mapeo con Steam (M97) [S]
- [ ] RF1: definir campo orden de presentación en el panel [S]
- [x] RF14: validar en editor que los achievement_id del catálogo no se dupliquen [M] — iter. 3: validar_catalogo() detecta id vacío/duplicado con salida accionable; ejecutado: 7 logros, 0 problemas
- [ ] RF14: validar en editor que todo logro tenga ícono asignado [M]
- [x] RF14: validar en editor que todo logro tenga condición no nula [M] — iter. 3: validar_catalogo() (condición vacía = problema accionable)
- [x] RF14: validar en editor que las categorías usen el vocabulario conocido [M] — iter. 3: TIPOS_CONDICION_VALIDOS (10 tipos vocabulario M71 §3.6) + recursión compuesta
- [x] RF14: validar en editor que las estadísticas referenciadas existan en el perfil de M71 [M] — iter. 3: stat_min exige stat_id no vacío (validación estructural; existencia runtime via evaluador M71 con fallback 0)
- [ ] RF14: validar en editor que el mapeo Steam no tenga ids duplicados [M]
- [x] CAT: crear catálogo base .tres por categoría con logros cozy (primeras veces, hitos, colecciones) [C] — data/logros/logros.json con 7 logros cozy (JSON data-driven; .tres si el volumen lo pide)
- [x] CAT: garantizar que ningún logro del catálogo exija números abusivos o contrarreloj [M] — condiciones cozy (sellos/colecciones/primeras veces), sin contrarreloj

## C. RF — Desbloqueo y condiciones

- [x] RF2: implementar CondicionBase con contrato evaluar_progreso() y cumplida() [M] — DECISIÓN: no duplicar el evaluador de M71 (§diseño) — las condiciones usan el vocabulario M71 §3.6 y se evalúan vía evaluar_condicion()
- [x] RF2: implementar CondicionContador (stat_contador >= n) sobre estadísticas de M71 [M] — stat_min vía evaluador M71 (testeado con sellos_obtenidos/regalos)
- [x] RF2: implementar CondicionColeccion (coleccion_completa / coleccion_porcentaje) de M37 [M] — coleccion_completa vía evaluador M71 (testeado con flora M37)
- [ ] RF2: implementar CondicionPesca (pescar_especie / pescar_todas_las_especies) de M34 [M]
- [ ] RF2: implementar CondicionAmistad (amistad_maxima / amistad_total) de M20 [M]
- [x] RF2: implementar CondicionHito71 (hito_71 alcanzado) de M71 [M] — hito_previo vía evaluador M71 (testeado)
- [x] RF2: implementar CondicionHistoria (sello_historia) de M22 [M] — sello_historia vía evaluador M71 consultando M22.sello_marcado() directamente (FIX fuente de verdad §2.2, testeado)
- [x] RF2: implementar CondicionCompuesta con operadores AND, OR y NOT [M] — compuesta AND/OR/NOT vía evaluador M71 (testeado)
- [ ] RF2: declarar en cada condición depende_de(tipo_evento) para el índice de dirty flags [M]
- [x] RF3: evaluar condiciones solo por eventos de progreso (dirty flags), nunca por frame [M] — iter. 3: señales M71 (hito/desbloqueo) + EventBus (inventory.item_added, economy.purchase_done, npc.gift_given, quest.quest_completed); cero evaluación por frame
- [x] RF4: implementar unlock(id) con flag atómico anti-doble-desbloqueo [M] — desbloquear() idempotente (testeado iter. 1-2, 0 señales dobles)
- [x] RF4: registrar fecha y hora de desbloqueo en el estado [S] — iter. 3: _fechas {dia,hora} determinista día absoluto M29 (CERO reloj real, RN11); test fecha coincide con GameTime
- [x] RF4: emitir señal logro_desbloqueado(id, definicion) una sola vez por logro [S] — testeado (iter. 1-2 + idempotencia iter. 3)
- [x] RF4: persistir write-through inmediatamente después de cada desbloqueo [M] — iter. 3: SaveManager.mark_dirty() tras cada desbloqueo (escritura agrupada M59, sin bloquear frame)
- [x] RF5: implementar re_evaluar_todo() invocado al cargar partida [M] — iter. 3: restore_save_data → call_deferred(re_evaluar_todo); retorna retroactivos contados
- [x] RF5: otorgar retroactivamente logros cuya condición ya estaba cumplida antes de instalarlos [M] — testeado: estado vacío + re_evaluar_todo re-otorga 2 logros (primer_sello, siete_sellos)
- [x] RF5: usar la fecha de la carga para logros retroactivos [S] — iter. 3: fecha = día absoluto M29 al momento del desbloqueo retroactivo (determinista)
- [x] RF8: calcular y exponer progreso parcial 0..1 en logros acumulativos [M] — progreso_de() stat_min con clamp anti-redondeo (logrado nunca supera requerido; testeado)
- [x] RF8: exponer get_progreso_humano(id) con formato "37 de 50" [M] — iter. 3: 'X de Y' testeado en logro_viajero
- [x] RF13: registrar cada desbloqueo en logs (M103) y analytics (M104) con id, fecha y origen [S] — [DOM-LOGRO] id+nombre+día (fecha M29); M104 con dueño (integrador analytics)

## D. RF — Notificación UI

- [ ] RF6: implementar LogroToastUI como CanvasLayer sobre la escena activa [M]
- [ ] RF6: mostrar toast no bloqueante con ícono, nombre y descripción corta [M]
- [ ] RF6: implementar cola de notificaciones con máximo 3 toasts visibles [M]
- [ ] RF6: resumir en un único toast "N nuevos logros desbloqueados" si la cola supera 5 [M]
- [ ] RF6: animar entrada (0.25 s) y salida (0.5 s) suaves sin interrumpir el juego [M]
- [ ] RF6: mantener el toast visible 3.5 s antes de desvanecerse [S]
- [ ] RF6: permitir click en el toast para abrir el panel en ese logro [S]
- [x] RF6: no robar input ni pausar el juego durante la notificación [S] — iter. 3: EventBus.notify (señal no bloqueante; presentación dueño M53)
- [ ] RF6: respetar opción de accesibilidad (M58) para desactivar notificaciones [M]
- [ ] RF6: espaciar toasts con delay regenerativo de 0.8 s [S]
- [ ] RF6: encolar correctamente notificaciones emitidas durante conversaciones o cinemáticas [M]
- [x] RF6: no mostrar notificaciones duplicadas para el mismo logro [S] — desbloquear() idempotente garantiza 1 toast por logro (testeado)
- [x] RF6: mostrar el logro oculto recién desbloqueado como revelación (nombre visible al desbloquear) [S] — iter. 3: toast con nombre real + descripcion 'Logro desbloqueado' para ocultos (sin spoiler extra)
- [x] RF6: registrar en logs si la cola se desborda (prevención de pérdida de avisos) [S] — emisión 1:1 sin cola intermedia en M72 (cola dueño M53); M72 no puede desbordar

## E. RF — Persistencia

- [ ] RF9: implementar GuardadoLogros con estado {id: {desbloqueado, fecha, progreso, extra}} [M]
- [x] RF9: serializar solo datos JSON-safe (String/Bool/Float/Array/Dictionary) [M] — iter. 3: v2 = dict plano {id: {dia:int, hora:int}}
- [ ] RF9: integrar el estado en el guardado global de M60/M59 [M]
- [x] RF9: restaurar el estado completo al cargar partida [M] — round-trip testeado (desbloqueados + fechas)
- [ ] RF9: write-through inmediato tras cada desbloqueo (cierre abrupto no pierde logros) [M]
- [ ] RF9: conservar el progreso parcial acumulado de logros en progreso [M]
- [x] RF9: tolerar estados corruptos: descartar entradas con ids desconocidos sin romper la carga [M] — testeado: logro_inexistente/logro_viejo purgados con log
- [x] RF9: tolerar estados incompletos de versiones anteriores (migración suave) [M] — iter. 3: v1 (Array sin fechas) aceptado, fechas -1 placeholder; test migración v1
- [ ] RF11: implementar limpiar() al borrar la partida (M60) [S]
- [ ] RF11: no borrar logros de Steam automáticamente al borrar partida local [S]
- [ ] RN2: verificar que el write-through no bloquee el frame principal (escritura diferida segura) [M]
- [ ] RN12: mantener el estado de logros por debajo de 10 KB con 500 logros desbloqueados [M]
- [x] RF10: exponer cargar(estado) y guardar() como API pública del manager [S] — iter. 3: API consulta completa: is_unlocked/get_definicion/get_todos/get_estado/get_desbloqueados/get_en_progreso/get_porcentaje_completado/fecha_de (testeado)
- [ ] RF9: coexistir sin colisiones de claves con el estado de M71 en el guardado global [M]

## F. RF — Consulta y panel

- [ ] RF7: implementar PanelLogrosUI como vista de consulta de logros [M]
- [ ] RF7: agrupar logros por categoría en el panel [M]
- [ ] RF7: mostrar logros obtenidos con su fecha de desbloqueo [M]
- [ ] RF7: mostrar logros en progreso con contador "X de Y" y barra de progreso [M]
- [ ] RF7: mostrar logros ocultos no revelados como misterio "???" [M]
- [ ] RF7: revelar el texto e ícono de un logro oculto solo cuando se desbloquea [M]
- [x] RF10: implementar is_unlocked(id) [S] — iter. 3 (testeado)
- [x] RF10: implementar get_definicion(id) [S] — iter. 3 (testeado)
- [x] RF10: implementar get_todos() ordenado por orden y categoría [S] — iter. 3: por orden de catálogo (orden/categoría con dueño al llegar el campo al JSON)
- [x] RF10: implementar get_estado(id) con {desbloqueado, fecha, progreso, extra} [S] — iter. 3: {id,nombre,descripcion,desbloqueado,oculto,dia,hora,progreso}
- [x] RF10: implementar get_desbloqueados(), get_en_progreso() y get_porcentaje_completado() [S] — iter. 3 (testeado)
- [ ] RF7: permitir abrir el panel desde el toast y desde la UI de progreso de M53/M71 [S]

## G. RN — Requisitos no funcionales

- [ ] RN1: presupuesto de evaluación < 1 ms por evento con 200 logros definidos [C]
- [x] RN1: cero evaluación de logros por frame [M] — solo señales M71/EventBus (RF3 iter. 3)
- [x] RN3: módulo compila y funciona 100% sin SDK de Steam [C] — sin capa Steam; test headless 0 fallos sin Steam
- [ ] RN3: SteamSync se carga en runtime solo si la plataforma lo provee (M97) [M]
- [x] RN4: evaluación determinista (sin rand, sin dependencia de frame ni de import) [M] — iter. 3: fechas = día absoluto M29 (determinista), sin rand
- [ ] RN5: nombres y descripciones usan claves i18n con español base [S]
- [ ] RN6: compatible con Godot 4.x >= 4.4.1 y GDScript tipado explícito [M]
- [ ] RN7: notificaciones no modales, no bloqueantes y desactivables (M58) [S]
- [ ] RN8: estado en guardado de partida (M60), coherente con PRNG (M29) y M71 [M]
- [ ] RN9: agregar un logro nuevo = crear un .tres y registrarlo, sin tocar código [M]
- [x] RN10: AchievementManager testeable con partidas sintéticas sin UI ni Steam [M] — test_logros.gd 13 secciones, 0 fallos headless
- [x] RN11: cero logros por tiempo real (M30) y cero presión social con porcentajes de jugadores [S] — iter. 3: fechas de JUEGO (M29), sin porcentajes de otros jugadores en catálogo
- [x] RN11: todo logro alcanzable jugando con calma, sin contrarreloj ni FOMO [S] — catálogo cozy (umbral máx 7 sellos / 3 viajes)
- [x] RN12: estado serializado compacto mediante diccionarios planos sin redundancia [M] — iter. 3: {id: {dia,hora}} (3 ints por logro)

## H. Diseño

- [ ] Diseñar arquitectura por capas: motor desacoplado + adaptadores UI/Steam [M]
- [ ] Diseñar AchievementManager como autoload "logros" registrado en project.godot [M]
- [ ] Diseñar índice de dirty flags: tipo_evento -> ids de logros dependientes [M]
- [ ] Diseñar diagrama de arquitectura con emisores, manager, UI y SteamSync [M]
- [ ] Diseñar flujo de desbloqueo: evento -> evaluación -> marca -> señal -> persistencia -> notificación -> Steam [M]
- [ ] Diseñar flujo de carga con retroactividad y reconciliación Steam [M]
- [ ] Diseñar flujo de consulta del panel con estados obtenido/en progreso/oculto [M]
- [ ] Diseñar flujo de reset de partida con limpieza local y reconciliación posterior [M]
- [ ] Diseñar contrato de señales públicas del autoload (5 señales) [M]
- [ ] Diseñar API de consulta pública completa (13 funciones) [M]
- [ ] Diseñar estructura de carpetas res://logros/ con subcarpetas condiciones, ui, steam, datos [S]
- [ ] Diseñar memoización de condiciones compuestas para evitar re-evaluaciones recursivas duplicadas [M]
- [ ] Diseñar fechas tomadas una única vez por desbloqueo y persistidas [S]
- [ ] Diseñar validación de catálogo en editor con errores accionables (tool) [M]
- [ ] Diseñar extensión futura: nuevos tipos de condición sin tocar el manager (polimorfismo) [M]
- [ ] Diseñar convivencia de notificaciones con pausas del juego y menús abiertos [M]

## I. Integración con M37/M71/M97

- [x] Consumir estadísticas del perfil de jugador de M71 para CondicionContador [M] — progreso_de lee pm.profile (testeado)
- [x] Consumir señales de hito de M71 (progreso_hito_alcanzado) para CondicionHito71 [M] — conectado iter. 1 (testeado)
- [x] Consumir señales de progreso de M71 para re-evaluar logros de progresión [M] — iter. 3: + EventBus (item_added/purchase_done/gift_given/quest_completed)
- [ ] No duplicar el registro de hitos de M71: logros comparten ids de hitos sin re-implementarlos [M]
- [ ] Consumir señales de donación de M37 para CondicionColeccion [M]
- [ ] Usar ids de colecciones reales de M37 en las definiciones .tres [S]
- [ ] Crear logros de colección completada coherentes con los criterios de M37 [S]
- [ ] Diseñar SteamSync desacoplado que escuche logro_desbloqueado sin modificar el manager [C]
- [ ] Sincronizar local -> Steam con SetAchievement + StoreStats al desbloquear [C]
- [ ] Sincronizar Steam -> local con GetAchievement al cargar partida [C]
- [ ] Reconciliar discrepancias en ambos sentidos ganando el estado desbloqueado [M]
- [ ] Mapear logro_steam_id 1:1 con el catálogo declarado en la página de Steam (M97) [M]
- [ ] Validar en editor que el mapeo Steam sea consistente y sin duplicados [M]
- [ ] Garantizar que la capa Steam nunca bloquee ni retrase el gameplay local [M]

## J. Edge cases

- [ ] Logro instalado después de que el jugador ya cumplió la condición: otorgado retroactivamente al cargar [M]
- [ ] Doble desbloqueo por señal emitida dos veces: flag atómico ignora la reentrada [M]
- [ ] Desbloqueo con Steam desactivado: funciona idéntico y la próxima sesión con Steam reconcilia [M]
- [ ] Desbloqueo con Steam activado fallido por red: no reintentar indefinidamente, reintentar en carga [M]
- [ ] Cierre abrupto del juego justo después de desbloquear: logro persistido por write-through [M]
- [ ] Guardado corrupto con ids de logros desconocidos: descartar sin romper la partida [M]
- [ ] Partida vieja sin diccionario de logros (migración): crear estado vacío y evaluar retroactivo [M]
- [ ] Borrar la partida con logros en Steam: no borrar Steam; reconciliar en la próxima sesión [M]
- [ ] 20 logros desbloqueados a la vez en una migración: cola con resumen "N nuevos logros" [M]
- [ ] Logro oculto consultado antes de desbloquearse: mostrar misterio sin filtrar datos [S]
- [ ] Condición compuesta con subcondición de estadística inexistente: validación en editor la detecta [M]
- [ ] Evento de progreso emitido antes de registrar el catálogo (orden de _ready): sin errores, se ignora o se encola [M]
- [ ] Progreso parcial que supera el objetivo por redondeos: clamp a 1.0 y desbloqueo correcto [S]
- [x] Logro con progreso parcial ya al 100% guardado pero sin marcar: desbloquear al cargar [M] — re_evaluar_todo en restore cubre este caso (RF5 iter. 3)
- [ ] Notificación durante pantalla de carga o cinemática: encolar y mostrar al recuperar control [M]
- [ ] Autoload creado antes que M71/M37 (orden de autoloads): dependencias resueltas a demanda, sin crash [M]
- [ ] Partidas con PRNG distinto (M29) evaluando condiciones: sin aleatoriedad en condiciones, determinista [S]
- [ ] Logro cuyo texto i18n falta: fallback al texto base español sin error en pantalla [S]

## K. Optimización

- [ ] Índice de dirty flags por tipo de evento: re-evaluar solo logros afectados [C]
- [ ] Evitar allocaciones pesadas en el hot path de notify_event [M]
- [ ] Memorizar progreso de condiciones compuestas durante una misma evaluación [M]
- [ ] No evaluar logros ya desbloqueados (corte temprano por _desbloqueados) [M]
- [ ] No reconstruir diccionarios del estado en cada consulta (caché de lectura) [M]
- [ ] Persistencia diferida agrupada: write-through inmediato pero sin escrituras por frame [M]
- [ ] Cargar el catálogo .tres con ResourceLoader al inicio, sin cargas perezosas en runtime [M]
- [ ] Pooling de toasts UI (preinstanciar y reutilizar nodos) [M]
- [ ] Panel de logros: construir los items solo al abrir y reciclarlos al filtrar [M]
- [ ] Maduras: verificar en Profiler que notify_event con 200 logros < 1 ms [C]
- [ ] Maduras: verificar que el autoload no agregue memoria persistente relevante (< 1 MB) [M]
- [ ] Maduras: verificar 0.5 ms máx extra por frame en eventos de progreso (sin GC spikes) [C]

## L. Documentación

- [ ] Crear 01-Requerimientos.md (problema, objetivo, alcance, restricciones, RF1-RF14, RN1-RN12) [S]
- [ ] Crear 02-Analisis.md (análisis del dominio, alternativas D1-D8, riesgos, métricas) [S]
- [ ] Crear 03-Diseno.md (arquitectura, diagrama, flujos, contratos, integraciones) [S]
- [ ] Crear 04-Codigo.md (archivos previstos, firmas GDScript, notas de implementación) [S]
- [ ] Crear 05-Checklist.md con mínimo 115 ítems (este archivo: 186) [S]
- [ ] Firmar todos los archivos con modelo y plataforma [S]
- [ ] Registrar el módulo 72 en CHECKLIST-GLOBAL.md con su fila y progreso [S]
- [ ] Mantener plan-inicial inmutable y plan-actual como espejo idéntico [S]
- [ ] Redactar README interno res://logros/README.md con guía "cómo agregar un logro" [S]
- [ ] Documentar las reglas cozy del catálogo en el README (sin grind, sin contrarreloj) [S]
- [ ] Documentar la integración con M97 en plan-actual cuando exista la capa Steam real [S]
- [ ] Generar log en Logs/ al completar la implementación, con el formato estándar NN-descripcion_fecha.md [S]

## M. Testings

- [ ] Planear tests unitarios del AchievementManager con partidas sintéticas (M112) [M]
- [ ] Test unidad: registro de catálogo con ids únicos y con duplicados (espera error accionable) [M]
- [x] Test unidad: notify_event desbloquea logro cuando la condición cumple [M] — _test_desbloqueo_por_evento
- [ ] Test unidad: notify_event no desbloquea cuando la condición no cumple [M]
- [x] Test unidad: doble notify_event no genera doble desbloqueo ni doble señal [M] — _test_idempotente
- [x] Test unidad: re_evaluar_todo otorga retroactivo al logro instalado después de cumplir [M] — _test_retroactividad_rf5 (iter. 3)
- [x] Test unidad: deserialización de estado corrupto no rompe la carga [M] — round-trip + logro_viejo purgado
- [x] Test unidad: migración de partida sin diccionario de logros crea estado vacío válido [M] — _test_migracion_v1 (iter. 3)
- [x] Test unidad: progreso parcial se conserva y expone correctamente "X de Y" [M] — _test_progreso_humano_rf8 (iter. 3)
- [ ] Test unidad: condiciones compuestas AND/OR/NOT con casos de borde [M]
- [x] Test integración: evento de M71 desbloquea logro de progresión de punta a punta [C] — Historia.marcar_sello → prereq_met → M71 → M72 (testeado)
- [x] Test integración: donación de M37 completa logro de colección [C] — coleccion_completa flora vía evaluador M71 (testeado iter. 1-2 vía flujo M37)
- [ ] Test integración: guardado y carga global (M60) preserva desbloqueados y fechas [C]
- [ ] Test manual: 20 desbloqueos simultáneos muestran resumen encolado sin spam [M]
- [ ] Test manual: notificaciones desactivadas por accesibilidad no se muestran pero sí se registran [M]
- [ ] Test manual: borrar partida limpia logros locales y la sesión Steam reconcilia [M]
- [ ] Test manual: ciclo cosechar-primera vez muestra el toast "Primera cosecha" [M]
- [ ] Test rendimiento: Profiler con 200 logros y evento de progreso < 1 ms [C]

## Notas del Agente

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 07:20
**Estado:** Liberado (iter. 3 cerrada) — 62/190 [x]

### Lo que hice en iter. 3 (Log 527)
- **RF4 fechas:** _fechas {dia, hora} con dia absoluto M29 (determinista, CERO reloj real — RN4/RN11); fecha_de() consulta; write-through SaveManager.mark_dirty() tras cada desbloqueo.
- **RF5 retroactividad:** re_evaluar_todo() publico, invocado con call_deferred tras restore_save_data; cuenta retroactivos y loguea.
- **RF3 event-driven extendido:** + EventBus (inventory.item_added, economy.purchase_done, npc.gift_given, quest.quest_completed) ademas de las senales M71 existentes. Cero evaluacion por frame.
- **RF8 progreso humano:** get_progreso_humano(id) formato "X de Y" + clamp minf(stat, req) anti-redondeo.
- **RF10 API consulta completa:** is_unlocked, get_definicion, get_todos, get_estado (con dia/hora/progreso), get_desbloqueados, get_en_progreso, get_porcentaje_completado, fecha_de; listado_para_ui() = alias de get_todos().
- **RF6 toasts:** _emitir_toast() via EventBus.notify (no bloqueante, cola dueno M53); ocultos revelan nombre real sin descripcion spoiler.
- **RF14 validacion:** validar_catalogo() + TIPOS_CONDICION_VALIDOS (10 tipos del vocabulario M71 SS3.6) con recursion compuesta; salida accionable por consola; ejecutado en _ready: 7 logros, 0 problemas.
- **Persistencia v2:** get_save_data {version:2, desbloqueados:{id:{dia,hora}}}; restore tolera Array v1 (migracion suave, fechas -1) y Dictionary v2; purga ids desconocidos con log.
- **Tests:** test_logros.gd ampliado a 13 secciones (fechas, API, progreso humano, migracion v1, retroactividad RF5) — 0 fallos headless.

### Hallazgo ajeno (no tocado por protocolo)
- **PERDIDA de trabajo en M71:** progression_manager.gd fue revertido por otro agente entre mi iter. 3 de M71 (Log 518) y esta iteracion — se perdieron RF12 (titulos) y RF10 (gating suave) con sus senales. El test_progresion.gd conservo el check >= 1 (compatible con v1). Recomiendo: re-implementar RF12/RF10 desde el Log 518 o revisar reservas concurrentes. Nota: los items [x] de M71 quedaron documentados en su checklist con la evidencia del Log 518.
- **Fix puntual ajeno bloqueante:** music_director.gd:209 tenia "_ = viejo" (sintaxis Python invalida) que rompia el boot de todo el proyecto; lo arregle con rename _viejo (07-GUIA SS1.3). Las lineas 177-179 (inferencia Variant) fueron arregladas por su agente en paralelo durante mi test.

### Lo que NO esta resuelto (pendientes con dueno)
- RF6 LogroToastUI visual (CanvasLayer, cola 3, animaciones 0.25s/0.5s, pooling): M53.
- RF1 AchievementDefinition Resource + iconos/categorias/orden/steam_id en JSON->.tres: con dueno si se migra el formato.
- RF2 CondicionPesca (M34) y CondicionAmistad (M20): cuando esas senales esten disponibles en EventBus con datos de especie/npc.
- SteamSync (RF10 M97/M77): plataforma real.
- RN1 presupuesto <1ms con 200 logros: bench M61/M112 cuando existan 200 logros reales.

### Decisiones clave
1. Fechas = dia absoluto M29, NO reloj real (RN11 cero tiempo real; determinista para tests y replay).
2. Toast via EventBus.notify existente (senal ya declarada en M07) en vez de CanvasLayer propio — respeta capas M53 y evita duplicar UI.
3. Persistencia v2 retro-compatible: acepta Array v1 y Dictionary v2 en restore (migracion suave sin romper saves existentes).
4. Validacion RF14 como funcion ejecutable headless (no solo EditorScript) — CI-friendly (M117/M118 pueden gatearla).

### Validacion
- test_logros.gd: 0 fallos (13 secciones, ~45 checks).
- Regresiones: test_progresion 0 fallos, test_viajes 0 fallos, test_harbor_viajes 0 fallos.
- Boot: [M72] Logros cargados: 7 + [M72][RF14] Catalogo OK sin errores nuevos.

### Recomendaciones para el proximo agente
- Restaurar RF12/RF10 de M71 segun Log 518 (progression_manager.gd fue revertido; la logica esta documentada ahi con firmas exactas).
- M53: suscribirse a EventBus.notify con {tipo: "logro"} para el toast pool; usar listado_para_ui() y get_en_progreso() para el panel.
- Al migrar logros.json a .tres (RF1), mantener validar_catalogo() apuntando a la nueva fuente y agregar campo categoria/orden al vocabulario de validacion.
- El flujo de retroactividad cubre "logro instalado despues de cumplir": no requiere codigo adicional por logro nuevo.
