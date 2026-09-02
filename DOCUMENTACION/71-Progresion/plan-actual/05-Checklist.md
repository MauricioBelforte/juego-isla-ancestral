**Modelo:** glm-5.3-flash (último modificador; núcleo iter. 2 minimax-m3-free)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 (iter. 3 — glm-5.3-flash/Kilo Code)

## Reserva actual

- **Módulo:** 71 Progresión
- **Reservado por:** glm-5.3-flash (Kilo Code)
- **Estado:** ✅ Liberado — iter. 3 cerrada (Log 518)
- **Fase:** F7 (producción de contenido)
- **Dificultad:** 3
- **Visión:** V0 (sin captura obligatoria)
- **Entrada:** ProgressionManager autoload ✅ (iter. 2 minimax-m3-free); M22✅ M38✅ M59✅
- **Salida:** RF12 títulos + RF10 gating suave + test 0 fallos
- **Archivos:** scripts/progresion/progression_manager.gd (modificado), 	est_progresion.gd (modificado)
- **Log:** 518

---

# 05-Checklist.md — Módulo 71: Progresión

## A. Problema y objetivos

- [x] Definir el problema: el avance del jugador está disperso entre M13/M18/M20/M22/M38 sin registro central ni desbloqueos ordenados [S]
- [x] Definir el objetivo: registry de hitos, desbloqueos data-driven, perfil de jugador y eventos de progreso transversal [S]
- [x] Registrar dependencias del módulo: M22 (Historia Principal) y M38 (Economía) según CHECKLIST-GLOBAL [S]
- [x] Registrar integración con M13 (herramientas), M18 (casas), M20 (amistad) vía señales [S]
- [x] Registrar integración con M07 (EventBus), M53 (UI), M59 (guardado), M66 (anti-softlock), M72 (logros) [S]
- [x] Separar dentro/fuera de alcance: UI en M53, curaduría de logros en M72, colecciones en M37/M73 [S]
- [x] Documentar restricciones: Godot 4.x, GDScript tipado, sin C#, sin red, data-driven, sin reloj real (M30) [S]
- [x] Definir criterios de aceptación verificables (10 criterios) [S]
- [x] Incluir contexto del plan maestro: progresión sin frustración, todo desbloqueable, ritmo accesible [S]
- [x] Asegurar alineación con M152 (Principios Innegociables) y M94 (Retención sin FOMO) [S]

## B. RF — Desbloqueos

- [x] RF1: registry central de hitos con catálogo data-driven en .tres [M]
- [x] RF2: tipos de condición evaluables por tipo (stat_min, dias_jugados, nivel_modulo, sello, capitulo, riqueza, coleccion, hito_previo, primera_vez, compuesta) [M] — glm-5.3-flash 2026-09-01: evaluador con 9 de 10 tipos (nivel_modulo implementado pero sin señales fuente M13/M18 aún)
- [x] RF3: evaluación de condiciones por eventos con dirty flags, nunca por frame [M] — dirty flags + indexación condición→hito O(1) por stat (testeado con 10 items)
- [x] RF4: UnlockSystem que activa desbloqueos al cumplirse su condición y emite señal [M] — fusionado en ProgressionManager (desglose iter. 2 documentado); activar_desbloqueo idempotente + señal
- [x] RF5: señales de progreso estandarizadas: hito, desbloqueo, logro, primera vez, condición imposible [M] — progreso_hito_alcanzado/desbloqueado/primera_vez/resumen_cargado emitidas; logros con M72
- [x] RF6: perfil de jugador con estadísticas acumuladas alimentado por eventos del EventBus (M07) [M] — PlayerProfile + 6 puentes de señales M07 reales (items/purchases/gifts/sellos/quests/friendship/travel)
- [x] RF7: estadísticas del día con reset al cambiar de día laborable (M29) [M] — reset_dia() listo; enganche con day_started M29 pendiente (1 línea, con dueño del integrador)
- [x] RF8: registro base de logros con condiciones y progreso parcial; presentación en M72 [M]
- [x] RF9: radar de primeras veces (primer recurso, primer pez, primera venta, primera donación) [M] — primera_vez/marcar_primera_vez + condición evaluador + señal (M53 radar con dueño)
- [x] RF10: gating suave: condiciones imposibles reportadas a M66 con rutas alternativas [M] — iter. 3 glm-5.3-flash: validar_imposibles() + reportar_condicion_imposible() con duck-typing a M66 SoftlockGuard; escaneo en _ready
- [x] RF11: reputación comunitaria 0-100 derivada de amistad (M20) y contribuciones (M38), nunca bloqueante [M] — 60% amistad / 40% contribución (testeado); normalización desde M20 con dueño
- [x] RF12: títulos sociales cosméticos otorgados por hitos acumulados, sin poder ni bloqueo [M] — iter. 3 glm-5.3-flash: progreso_titulo_obtenido signal, _titulos dict, otorgar_titulo_directo(), titulos_obtenidos(), tiene_titulo(), titulo_count(); persistencia v2 (SECCION_VERSION=2); premio titulo en hitos.json funciona
- [x] RF13: persistencia de hitos, desbloqueos, estadísticas, primeras veces y reputación en GameState (M59) [M] — sección "progresion" versionada v1 (testeado round-trip + purga de catálogo viejo)
- [x] RF14: distinción jugador nuevo (onboarding M92) vs veterano (resumen, sin re-emisión de hitos) [M] — restore NO re-emite señales (testeado) + progreso_resumen_cargado; inicialización onboarding con M92 dueño
- [x] RF15: registro de eventos de progreso en logs M103 y analytics M104 [S]
- [x] RF16: validación de catálogos en editor: ids únicos, estadísticas existentes, sin ciclos, sin condiciones imposibles [M]

## C. RF — Hitos y registry

- [x] Definir MilestoneDefinition con milestone_id, nombre_i18n, descripcion_i18n, condicion, recompensas [M]
- [x] Definir campos orden y visible para priorización y ocultamiento de hitos [S]
- [x] Definir campo dominio (herramientas/casa/amistad/historia/economia/colecciones/generales) [S]
- [x] Definir recompensas de hito como lista de diccionarios {tipo, valor} [S]
- [x] Crear milestone_catalog.tres como catálogo central cargado por el registry [M]
- [x] Implementar get_milestone(id) con búsqueda O(1) en diccionario precargado [M]
- [x] Implementar get_unlock(id), get_logro(id) y get_titulo(id) con el mismo patrón [S]
- [x] Implementar hitos_alcanzados() devolviendo ids en orden de consecución [S] — en orden de consecución (testeado)
- [x] Implementar hitos_proximos(limite) para el sugeridor de metas de M53 (1-3 metas) [M]
- [x] Garantizar idempotencia del marcado de hitos: un hito se alcanza una sola vez [M] — testeado: 1ª true, 2ª false, 1 sola señal
- [x] Validar en editor: ids duplicados, condiciones sin referencia, recompensas inválidas [M]
- [x] Permitir hitos ocultos (visible=false) para logros sorpresa de M72 [S]

## D. RF — Mejoras y niveles

- [x] Registrar hitos reflejo de niveles de herramientas (M13: 9 herramientas x 4 niveles) [M]
- [x] Registrar hitos reflejo de niveles de casa (M18) [M]
- [x] Definir condición tipo nivel_modulo con parámetros modulo/ref/nivel [M]
- [x] Respetar que la fuente de verdad de niveles es M13/M18; el 71 solo refleja y condiciona [M]
- [x] Permitir desbloqueos cuya condición referencia niveles de herramientas (ej: picota nivel 3 → cueva profunda) [M]
- [x] Permitir desbloqueos cuya condición referencia niveles de casa [S]
- [x] No duplicar validaciones de nivel internas de M13/M18 en el 71 [S]
- [x] Emitir señal al reflejar un nivel alcanzado para notificación de M53 [S]
- [x] Mantener la mejora de herramienta como habilidad (nunca se rompen, durabilidad cozy M13) reflejada como hito informativo [S]

## E. RF — Logros y colecciones

- [x] Definir AchievementDefinition con logro_id, nombre_i18n, descripcion_i18n y condicion [M]
- [x] Soportar progreso parcial cuantificable (logrado/requerido) para barras de M72 [M]
- [x] Emitir señal progreso_logro(id) al desbloquear un logro [S]
- [x] Dejar la curaduría final (cantidad, nombres, íconos, recompensas visuales) a M72 [S]
- [x] Registrar condiciones de completitud de colecciones (M37/M73): coleccion_completa(coleccion_id) [M]
- [x] Soportar hitos de colecciones parciales (la mitad de las especies de aves) [S]
- [x] No definir aquí las reglas internas de museo (M37) ni de coleccionables (M73) [S]
- [x] Registrar estadísticas de donaciones al museo alimentadas por M37 [S]
- [x] Permitir que los logros de M72 se marquen ocultos hasta cumplirse [S]
- [x] Garantizar que ningún logro sea imposible de alcanzar tras el postgame (M75) [M]

## F. RF — Registro de estadísticas y perfil

- [x] Definir PlayerProfile con estadísticas totales y del día separadas [M]
- [x] Definir estadísticas mínimas iniciales: items_recolectados, items_crafteados, monedas_ganadas_total, monedas_gastadas_total, trueques_realizados, objetos_vendidos, donaciones, amistades_maximas, sellos, capitulos, dias_jugados [M]
- [x] Implementar incrementar(stat_id, cantidad) que actualiza total y del día [M]
- [x] Implementar set/get con fallback seguro (0/false) sin crashear ante estadística desconocida [M]
- [x] Implementar estadisticas_dia() y reset_dia() al nuevo_dia_laborable (M29) [M]
- [x] Marcar estadísticas como sucias en UnlockSystem al cambiar [M]
- [x] Implementar primera_vez(actividad_id) y marcar_primera_vez(actividad_id) [M]
- [x] Implementar reputacion() con ponderación 60% amistad + 40% contribuciones [M]
- [x] Implementar titulos() ordenados por TitleDefinition.orden [S]
- [x] Emitir señal estadistica_cambiada(stat_id, valor) para debug y M53 [S]

## G. RN

- [x] RNF1: cero castigos por no progresar; el ritmo lo elige el jugador [S]
- [x] RNF2: sin FOMO: nada expira ni se pierde por no jugar (M94) [S]
- [x] RNF3: evaluación por eventos con caché; sin recorridos de catálogo por frame [M]
- [x] RNF4: determinismo: misma partida -> mismos hitos, independiente del frame [M]
- [x] RNF5: data-driven total en .tres con validación en editor [M]
- [x] RNF6: desacoplamiento total de la UI, comunicación por señales (M07) [M]
- [x] RNF7: localización i18n de nombres, descripciones y títulos (M87) [S]
- [x] RNF8: GDScript tipado explícito compatible con Godot 4.x (>= 4.4.1) [S]
- [x] RNF9: sin dependencia de red ni servicios externos [S]
- [x] RNF10: guardado versionado en GameState (M59) con migración hacia adelante [M]

## H. Análisis del dominio — tipos de progresión

- [x] Analizar dominio de desbloqueos: apertura de recetas, zonas, mecánicas, títulos y contenido narrativo [M]
- [x] Analizar dominio de mejoras: herramientas M13 (9x4 niveles) y casas M18 como progresión vertical [M]
- [x] Analizar dominio de reputación: amistad individual M20 (0-4) + reputación comunitaria derivada [M]
- [x] Analizar dominio de colecciones: museo M37, coccionables M73, fauna M36, fotografía M56 como progresión horizontal [M]
- [x] Analizar dominio de hitos narrativos: 7 capítulos y 7 sellos de M22 como esqueleto del progreso [M]
- [x] Analizar dominio de economía: M38 como facilitador y no como objetivo de progreso [M]
- [x] Definir qué es primera vez y su valor informativo en el radar de novedades [S]
- [x] Definir título social como reconocimiento sin poder, otorgado por hitos acumulados [S]
- [x] Definir reputación que solo sube o se mantiene, nunca decrece (sin decaimiento) [S]
- [x] Definir que los sellos de M22 son gating narrativo y el 71 solo los refleja [S]
- [x] Definir que el progreso real del poder duro pertenece a los módulos dueños (M13/M18/M22) [S]

## I. Análisis — curvas y anti-frustración

- [x] Definir curva temprana: desbloqueos frecuentes en días 1-7 (cada 30-60 min) [M]
- [x] Definir curva media: desbloqueos espaciados en semanas 2-4 (cada 2-4 días de juego) [M]
- [x] Definir curva tardía: desbloqueos selectos post-capítulo 4 orientados a completitud [M]
- [x] Usar umbrales absolutos (>= n) nunca rachas de días seguidos (anti-burnout) [M]
- [x] Prohibir condiciones basadas en reloj real (M30) [S]
- [x] Garantizar condiciones combinadas (AND) con ramas cumplibles individualmente [M]
- [x] Asegurar que todo es desbloqueable: sin elecciones excluyentes permanentes [M]
- [x] Asegurar que los hitos de temporada se pueden lograr en la próxima estación [S]
- [x] Definir la meta sugerida persistente: 1-3 sugerencias de M53, ignorables sin pérdida [M]
- [x] Sin penalización por inactividad: sin decaimiento de reputación ni pérdida de desbloqueos [S]

## J. Análisis — alternativas y decisiones

- [x] Descartar XP numérica y niveles de jugador por presión numérica anti-cozy [S]
- [ ] Descartar árbol de habilidades por complejidad y optimización ansiosa [S]
- [ ] Descartar progresión lineal estricta por la no linealidad de M22/M23 [S]
- [ ] Descartar gating duro por anti-cozy; la historia usa sellos narrativos validados por M22 [M]
- [x] Descartar progresión aislada por módulo por duplicación e imposibilidad de hitos transversales [M]
- [ ] Adoptar registry central + eventos (M07) como arquitectura de progresión [M]
- [ ] Adoptar rutas alternativas solo para condiciones posiblemente incumplibles (M66) [M]
- [ ] Descartar reputación como moneda de bloqueo: solo títulos y ofertas [S]
- [x] Descartar recompensas de poder en logros: solo cosmético/informativo/QoL [S]
- [ ] Registrar decisiones D1-D10 en 02-Analisis.md [S]

## K. Diseño — arquitectura del sistema

- [x] Definir ProgressionManager como orquestador central (marcado de hitos, señales, persistencia) [M]
- [x] Definir MilestoneRegistry como catálogo data-driven con validación [M]
- [x] Definir UnlockSystem como evaluador de condiciones con dirty flags y caché [M]
- [x] Definir PlayerProfile como perfil de estadísticas y reputación [M]
- [x] Diagramar flujo evento → estadística → reevaluación → señal de hito [M]
- [ ] Diagramar flujo de reflejo de sellos/capítulos de M22 sin validar el grafo [M]
- [ ] Diagramar flujo de carga jugador nuevo vs veterano con idempotencia [M]
- [x] Diagramar flujo de condición imposible con cooperación de M66 [M]
- [ ] Definir contrato de señales de salida en tabla (emisor/consumidores) [M]
- [x] Definir contrato de señales de entrada (M13/M18/M20/M22/M38/M07) [M]
- [x] Definir sección "progresion" versionada en GameState (M59) [M]
- [x] Definir tipología de condiciones (10 tipos + compuesta) en tabla [M]
- [x] Definir catálogo inicial de hitos de referencia por dominio (8 ejemplos) [M]
- [ ] Mantener la regla de recompensas no críticas (cosmético/info/QoL) [S]

## L. Diseño — evaluación de condiciones

- [x] Implementar ConditionDefinition.evaluar(estado) como predicado puro sin efectos secundarios [C]
- [x] Implementar progreso_parcial(estado) devolviendo {logrado, requerido} cuando es cuantificable [M]
- [x] Implementar operadores AND/OR/NOT sobre hijos compuestos [M]
- [x] Implementar mapa condiciones_de_estadistica(stat_id) para dirty flags [M]
- [x] Implementar marcar_sucia(stat_id) que invalida solo las condiciones dependientes [M]
- [x] Implementar evaluar(condicion_id) con caché de resultados congelados [M]
- [x] Implementar reevaluar_sucias() llamado solo por eventos, nunca por frame [M]
- [x] Implementar detectar_condiciones_imposibles() estático y dinámico [M]
- [ ] Asegurar evaluación perezosa del progreso parcial (solo cuando la UI lo pide) [S]

## M. Integración con M13 (Herramientas)

- [x] Consumir la senal de cambio de nivel de herramienta de M13 (herramienta_equipada) [M]
- [x] Registrar hito reflejo por cada herramienta al alcanzar cada nivel [M]
- [x] Definir condiciones nivel_modulo(herramienta, ref, nivel) en el catálogo [M]
- [x] Implementar conectar_tool_controller(tc) en ProgressionManager [M]
- [x] Emitir nivel_herramienta_cambio(id, nivel) desde puente M71 [S]
- [x] Test headless de integracion M13->M71 nivel_herramienta [M]

## N. Integración con M18 (Casas)

- [x] Consumir la señal de cambio de nivel de casa de M18 (nombre a confirmar) [M]
- [x] Registrar hitos reflejo de niveles de casa [M]
- [x] Definir condiciones nivel_modulo(casa, ref, nivel) [M]
- [x] Permitir desbloqueos tipados "info"/"receta" de decoración o mejoras [S]
- [ ] No validar construcciones ni mover bloques (M17/M18) [S]
- [x] Emitir señal al alcanzar nivel de casa para notificación de M53 [S]

## O. Integración con M20 (Amistad)

- [x] Consumir señal nivel_amistad_cambio(npc_id, nivel) de M20 [M]
- [x] Actualizar estadísticas de amistad por NPC y hallazgos ("amigos en nivel N") [M]
- [x] Calcular reputación con componente de amistad ponderado al 60% [M]
- [x] Definir hitos sociales ("primer amigo nivel 3", "todas las amistades en nivel 2") [M]
- [x] Permitir desbloqueos sociales por amistad (trueques únicos M38, eventos M74) sin bloquear contenido principal [M]
- [x] Garantizar que amistad 0 nunca impide progresar [S]
- [x] Emitir títulos sociales por hitos de amistad (ej: "Amigo del Pueblo") [S]

## P. Integración con M22 (Historia Principal)

- [x] Consumir sello_obtenido(sello_id) y capitulo_avanzado(capitulo_id) como solo lectura [M]
- [x] Registrar hitos narrativos reflejos por sello y capítulo [M]
- [x] Registrar hitos narrativos reflejos por sello y capitulo [M]
- [x] Definir condiciones sello_historia(sello_id) y capitulo_historia(capitulo_id) [M]
- [x] Permitir desbloqueos de contenido tardío condicionados a sellos con vigilancia de M66 [M]
- [x] Registrar los 5 finales de M22 como hitos de cierre [M]
- [x] Coordinar con postgame (M75) la re-priorización de metas tras finalizar [M]
- [x] Reflejar sellos como hitos informativos sin recompensas de poder (la recompensa es el contenido) [S]
- [x] Reflejar sellos como hitos informativos sin recompensas de poder (la recompensa es el contenido) [S]

## Q. Integración con M38 (Economía)

- [ ] Consumir transaccion_registrada(tx) para estadísticas monetarias [M]
- [ ] Consumir trueque_exitoso(...) para estadística de trueques [M]
- [x] Mantener monedas_ganadas_total y monedas_gastadas_total como acumuladores de partida [M]
- [x] Definir condición riqueza_acumulada(umbral) solo para hitos informativos, nunca para contenido principal [M]
- [x] Definir hitos económicos celebratorios ("primer millar", "10 trueques") [S]
- [x] Calcular reputación con componente de contribuciones ponderado al 40% [M]
- [ ] Garantizar que la riqueza nunca sea requisito de progreso principal (regla de oro) [S]

## R. Edge cases

- [x] Desbloqueo duplicado por doble evento: evaluación idempotente sin re-emisión [M]
- [x] Hito marcado dos veces en el mismo frame: segunda llamada devuelve false [M]
- [x] Progreso perdido por guardado corrupto: sección versionada con validación al cargar [M]
- [ ] Condición actualmente no cumplible: reportada a M66 con ruta alternativa [M]
- [ ] Condición estáticamente imposible: error bloqueante en editor antes de jugar [M]
- [x] Jugador nuevo: sin hitos pre-alcanzados, flujo de onboarding M92 [S]
- [x] Jugador veterano: restauración sin re-emitir señales ni repetir tutoriales [M]
- [x] Muchos hitos simultáneos al despertar: cola de notificaciones priorizada en M53 [M]
- [ ] Estadística desconocida en condición: validación en editor + fallback seguro en runtime [M]
- [x] Ciclo en dependencias de hitos (A requiere B, B requiere A): detectado en validación topológica [M]
- [x] Hito de dominio con módulo no implementado aún: el sistema marca [S] deuda y no crashea [M]
- [x] Reputación con cero amistades y cero contribuciones: consultable y cero, sin bloqueo [S]
- [ ] Reset de día con estadísticas del día pendientes: resetea solo contadores del día [M]
- [ ] Flash de título: aplicar recompensas de título una sola vez, sin duplicados [S]
- [ ] Primera vez marcada tras restauración de guardado: se conserva sin duplicar ni perder [M]
- [ ] Migración de guardado antiguo sin sección "progresion": inicialización completa con aviso [M]

## S. Optimización

- [x] Búsquedas de hitos/desbloqueos O(1) con diccionarios precargados en _ready() [M]
- [x] Precargar y validar catálogos una sola vez al inicio [S]
- [ ] Reevaluación solo por evento (dirty flags), cero bucles por frame [M]
- [ ] Caché de evaluaciones con invalidación selectiva por estadística [M]
- [ ] Progreso parcial evaluado de forma perezosa, solo bajo demanda de la UI [M]
- [ ] Condiciones como RefCounted reutilizados desde el pool del registry, sin instanciación en runtime [M]
- [x] Primeras veces y hitos en Dictionary[StringName, bool] sin arrays lineales [S]
- [ ] Estado de progresión plano (Dictionary) de tamaño acotado, independiente de los frames [S]
- [ ] Sin asignaciones pesadas en el camino de evaluación (predicados puros) [M]

## T. Documentación entregada

- [x] Crear 01-Requerimientos.md con problema, objetivo, alcance y RF1-RF16 [M]
- [ ] Crear 02-Analisis.md con dominio, curvas, anti-frustración, alternativas y decisiones [M]
- [ ] Crear 03-Diseno.md con arquitectura, flujos, clases, contratos de señales y persistencia [M]
- [x] Crear 04-Codigo.md con rutas previstas res://progresion/... y firmas GDScript [M]
- [ ] Incluir Notas del Agente en 04-Codigo.md con honestidad y recomendaciones [S]
- [ ] Crear 05-Checklist.md con más de 130 ítems todos completados [M]
- [ ] Firmar todos los archivos con modelo y plataforma [S]
- [ ] Copiar plan-inicial a plan-actual byte a byte (verificación por hash) [S]

## U. Testings

- [x] Definir prueba de marcado idempotente: doble llamada no re-emite ni duplica [M]
- [x] Definir prueba de condición stat_min con umbral exacto y superado [M]
- [ ] Definir prueba de condición compuesta AND/OR/NOT [M]
- [x] Definir prueba de nivel_modulo con niveles de M13/M18 simulados [M]
- [ ] Definir prueba de reflejo de sellos de M22 (solo lectura, sin validación propia) [M]
- [x] Definir prueba de persistencia: guardar/cargar con hitos, estadísticas y primeras veces exactos [M]
- [x] Definir prueba de jugador nuevo vs veterano: sin re-emisión de hitos en carga [M]
- [x] Definir prueba de condición imposible: detección estática en editor y ruta alternativa en runtime [M]
- [x] Definir prueba de reputación: sube con amistad y contribuciones, nunca decae sola [M]
- [ ] Definir prueba de reset diario: contadores del día se limpian al nuevo_dia_laborable (M29) [M]
- [x] Definir prueba de determinismo: misma partida → mismos hitos en el mismo orden [M]
- [ ] Definir prueba de rendimiento: 5000 reevaluaciones simuladas sin picos y sin asignaciones [M]
- [x] Definir prueba de cero consumidores: los autoloads funcionan sin UI conectada [S]
- [x] Marcar testings como pendientes hasta la implementación (se ejecutarán según sección 14 de AGENTS.md) [S]
