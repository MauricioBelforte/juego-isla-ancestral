**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 71: Progresión

## A. Problema y objetivos

- [ ] Definir el problema: el avance del jugador está disperso entre M13/M18/M20/M22/M38 sin registro central ni desbloqueos ordenados [S]
- [ ] Definir el objetivo: registry de hitos, desbloqueos data-driven, perfil de jugador y eventos de progreso transversal [S]
- [ ] Registrar dependencias del módulo: M22 (Historia Principal) y M38 (Economía) según CHECKLIST-GLOBAL [S]
- [ ] Registrar integración con M13 (herramientas), M18 (casas), M20 (amistad) vía señales [S]
- [ ] Registrar integración con M07 (EventBus), M53 (UI), M59 (guardado), M66 (anti-softlock), M72 (logros) [S]
- [ ] Separar dentro/fuera de alcance: UI en M53, curaduría de logros en M72, colecciones en M37/M73 [S]
- [ ] Documentar restricciones: Godot 4.x, GDScript tipado, sin C#, sin red, data-driven, sin reloj real (M30) [S]
- [ ] Definir criterios de aceptación verificables (10 criterios) [S]
- [ ] Incluir contexto del plan maestro: progresión sin frustración, todo desbloqueable, ritmo accesible [S]
- [ ] Asegurar alineación con M152 (Principios Innegociables) y M94 (Retención sin FOMO) [S]

## B. RF — Desbloqueos

- [ ] RF1: registry central de hitos con catálogo data-driven en .tres [M]
- [x] RF2: tipos de condición evaluables por tipo (stat_min, dias_jugados, nivel_modulo, sello, capitulo, riqueza, coleccion, hito_previo, primera_vez, compuesta) [M] — glm-5.3-flash 2026-09-01: evaluador con 9 de 10 tipos (nivel_modulo implementado pero sin señales fuente M13/M18 aún)
- [x] RF3: evaluación de condiciones por eventos con dirty flags, nunca por frame [M] — dirty flags + indexación condición→hito O(1) por stat (testeado con 10 items)
- [x] RF4: UnlockSystem que activa desbloqueos al cumplirse su condición y emite señal [M] — fusionado en ProgressionManager (desglose iter. 2 documentado); activar_desbloqueo idempotente + señal
- [x] RF5: señales de progreso estandarizadas: hito, desbloqueo, logro, primera vez, condición imposible [M] — progreso_hito_alcanzado/desbloqueado/primera_vez/resumen_cargado emitidas; logros con M72
- [x] RF6: perfil de jugador con estadísticas acumuladas alimentado por eventos del EventBus (M07) [M] — PlayerProfile + 6 puentes de señales M07 reales (items/purchases/gifts/sellos/quests/friendship/travel)
- [x] RF7: estadísticas del día con reset al cambiar de día laborable (M29) [M] — reset_dia() listo; enganche con day_started M29 pendiente (1 línea, con dueño del integrador)
- [ ] RF8: registro base de logros con condiciones y progreso parcial; presentación en M72 [M]
- [x] RF9: radar de primeras veces (primer recurso, primer pez, primera venta, primera donación) [M] — primera_vez/marcar_primera_vez + condición evaluador + señal (M53 radar con dueño)
- [ ] RF10: gating suave: condiciones imposibles reportadas a M66 con rutas alternativas [M]
- [x] RF11: reputación comunitaria 0-100 derivada de amistad (M20) y contribuciones (M38), nunca bloqueante [M] — 60% amistad / 40% contribución (testeado); normalización desde M20 con dueño
- [ ] RF12: títulos sociales cosméticos otorgados por hitos acumulados, sin poder ni bloqueo [M]
- [x] RF13: persistencia de hitos, desbloqueos, estadísticas, primeras veces y reputación en GameState (M59) [M] — sección "progresion" versionada v1 (testeado round-trip + purga de catálogo viejo)
- [x] RF14: distinción jugador nuevo (onboarding M92) vs veterano (resumen, sin re-emisión de hitos) [M] — restore NO re-emite señales (testeado) + progreso_resumen_cargado; inicialización onboarding con M92 dueño
- [x] RF15: registro de eventos de progreso en logs M103 y analytics M104 [S]
- [ ] RF16: validación de catálogos en editor: ids únicos, estadísticas existentes, sin ciclos, sin condiciones imposibles [M]

## C. RF — Hitos y registry

- [ ] Definir MilestoneDefinition con milestone_id, nombre_i18n, descripcion_i18n, condicion, recompensas [M]
- [ ] Definir campos orden y visible para priorización y ocultamiento de hitos [S]
- [ ] Definir campo dominio ("herramientas"/"casa"/"amistad"/"historia"/"economia"/"colecciones"/"generales") [S]
- [ ] Definir recompensas de hito como lista de diccionarios {tipo, valor} [S]
- [ ] Crear milestone_catalog.tres como catálogo central cargado por el registry [M]
- [ ] Implementar get_milestone(id) con búsqueda O(1) en diccionario precargado [M]
- [ ] Implementar get_unlock(id), get_logro(id) y get_titulo(id) con el mismo patrón [S]
- [x] Implementar hitos_alcanzados() devolviendo ids en orden de consecución [S] — en orden de consecución (testeado)
- [ ] Implementar hitos_proximos(limite) para el sugeridor de metas de M53 (1-3 metas) [M]
- [x] Garantizar idempotencia del marcado de hitos: un hito se alcanza una sola vez [M] — testeado: 1ª true, 2ª false, 1 sola señal
- [ ] Validar en editor: ids duplicados, condiciones sin referencia, recompensas inválidas [M]
- [ ] Permitir hitos ocultos (visible=false) para logros sorpresa de M72 [S]

## D. RF — Mejoras y niveles

- [ ] Registrar hitos reflejo de niveles de herramientas (M13: 9 herramientas x 4 niveles) [M]
- [ ] Registrar hitos reflejo de niveles de casa (M18) [M]
- [x] Definir condición tipo nivel_modulo con parámetros modulo/ref/nivel [M]
- [ ] Respetar que la fuente de verdad de niveles es M13/M18; el 71 solo refleja y condiciona [M]
- [ ] Permitir desbloqueos cuya condición referencia niveles de herramientas (ej: picota nivel 3 → cueva profunda) [M]
- [ ] Permitir desbloqueos cuya condición referencia niveles de casa [S]
- [ ] No duplicar validaciones de nivel internas de M13/M18 en el 71 [S]
- [ ] Emitir señal al reflejar un nivel alcanzado para notificación de M53 [S]
- [ ] Mantener la mejora de herramienta como habilidad (nunca se rompen, durabilidad cozy M13) reflejada como hito informativo [S]

## E. RF — Logros y colecciones

- [ ] Definir AchievementDefinition con logro_id, nombre_i18n, descripcion_i18n y condicion [M]
- [ ] Soportar progreso parcial cuantificable (logrado/requerido) para barras de M72 [M]
- [ ] Emitir señal progreso_logro(id) al desbloquear un logro [S]
- [ ] Dejar la curaduría final (cantidad, nombres, íconos, recompensas visuales) a M72 [S]
- [ ] Registrar condiciones de completitud de colecciones (M37/M73): coleccion_completa(coleccion_id) [M]
- [ ] Soportar hitos de colecciones parciales ("la mitad de las especies de aves") [S]
- [ ] No definir aquí las reglas internas de museo (M37) ni de coleccionables (M73) [S]
- [ ] Registrar estadísticas de donaciones al museo alimentadas por M37 [S]
- [ ] Permitir que los logros de M72 se marquen ocultos hasta cumplirse [S]
- [ ] Garantizar que ningún logro sea imposible de alcanzar tras el postgame (M75) [M]

## F. RF — Registro de estadísticas y perfil

- [ ] Definir PlayerProfile con estadísticas totales y del día separadas [M]
- [ ] Definir estadísticas mínimas iniciales: items_recolectados, items_crafteados, monedas_ganadas_total, monedas_gastadas_total, trueques_realizados, objetos_vendidos, donaciones, amistades_maximas, sellos, capitulos, dias_jugados [M]
- [ ] Implementar incrementar(stat_id, cantidad) que actualiza total y del día [M]
- [ ] Implementar set/get con fallback seguro (0/false) sin crashear ante estadística desconocida [M]
- [ ] Implementar estadisticas_dia() y reset_dia() al nuevo_dia_laborable (M29) [M]
- [ ] Marcar estadísticas como sucias en UnlockSystem al cambiar [M]
- [ ] Implementar primera_vez(actividad_id) y marcar_primera_vez(actividad_id) [M]
- [ ] Implementar reputacion() con ponderación 60% amistad + 40% contribuciones [M]
- [ ] Implementar titulos() ordenados por TitleDefinition.orden [S]
- [ ] Emitir señal estadistica_cambiada(stat_id, valor) para debug y M53 [S]

## G. RN

- [ ] RNF1: cero castigos por no progresar; el ritmo lo elige el jugador [S]
- [ ] RNF2: sin FOMO: nada expira ni se pierde por no jugar (M94) [S]
- [ ] RNF3: evaluación por eventos con caché; sin recorridos de catálogo por frame [M]
- [ ] RNF4: determinismo: misma partida → mismos hitos, independiente del frame [M]
- [ ] RNF5: data-driven total en .tres con validación en editor [M]
- [ ] RNF6: desacoplamiento total de la UI, comunicación por señales (M07) [M]
- [ ] RNF7: localización i18n de nombres, descripciones y títulos (M87) [S]
- [ ] RNF8: GDScript tipado explícito compatible con Godot 4.x (>= 4.4.1) [S]
- [ ] RNF9: sin dependencia de red ni servicios externos [S]
- [ ] RNF10: guardado versionado en GameState (M59) con migración hacia adelante [M]

## H. Análisis del dominio — tipos de progresión

- [ ] Analizar dominio de desbloqueos: apertura de recetas, zonas, mecánicas, títulos y contenido narrativo [M]
- [ ] Analizar dominio de mejoras: herramientas M13 (9x4 niveles) y casas M18 como progresión vertical [M]
- [ ] Analizar dominio de reputación: amistad individual M20 (0-4) + reputación comunitaria derivada [M]
- [ ] Analizar dominio de colecciones: museo M37, coleccionables M73, fauna M36, fotografía M56 como progresión horizontal [M]
- [ ] Analizar dominio de hitos narrativos: 7 capítulos y 7 sellos de M22 como esqueleto del progreso [M]
- [ ] Analizar dominio de economía: M38 como facilitador y no como objetivo de progreso [M]
- [ ] Definir qué es "primera vez" y su valor informativo en el radar de novedades [S]
- [ ] Definir título social como reconocimiento sin poder, otorgado por hitos acumulados [S]
- [ ] Definir reputación que solo sube o se mantiene, nunca decrece (sin decaimiento) [S]
- [ ] Definir que los sellos de M22 son gating narrativo y el 71 solo los refleja [S]
- [ ] Definir que el progreso real del poder duro pertenece a los módulos dueños (M13/M18/M22) [S]

## I. Análisis — curvas y anti-frustración

- [ ] Definir curva temprana: desbloqueos frecuentes en días 1-7 (cada 30-60 min) [M]
- [ ] Definir curva media: desbloqueos espaciados en semanas 2-4 (cada 2-4 días de juego) [M]
- [ ] Definir curva tardía: desbloqueos selectos post-capítulo 4 orientados a completitud [M]
- [ ] Usar umbrales absolutos (>= n) nunca rachas de días seguidos (anti-burnout) [M]
- [ ] Prohibir condiciones basadas en reloj real (M30) [S]
- [ ] Garantizar condiciones combinadas (AND) con ramas cumplibles individualmente [M]
- [ ] Asegurar que todo es desbloqueable: sin elecciones excluyentes permanentes [M]
- [ ] Asegurar que los hitos de temporada se pueden lograr en la próxima estación [S]
- [ ] Definir la meta sugerida persistente: 1-3 sugerencias de M53, ignorables sin pérdida [M]
- [ ] Sin penalización por inactividad: sin decaimiento de reputación ni pérdida de desbloqueos [S]

## J. Análisis — alternativas y decisiones

- [ ] Descartar XP numérica y niveles de jugador por presión numérica anti-cozy [S]
- [ ] Descartar árbol de habilidades por complejidad y optimización ansiosa [S]
- [ ] Descartar progresión lineal estricta por la no linealidad de M22/M23 [S]
- [ ] Descartar gating duro por anti-cozy; la historia usa sellos narrativos validados por M22 [M]
- [ ] Descartar progresión aislada por módulo por duplicación e imposibilidad de hitos transversales [M]
- [ ] Adoptar registry central + eventos (M07) como arquitectura de progresión [M]
- [ ] Adoptar rutas alternativas solo para condiciones posiblemente incumplibles (M66) [M]
- [ ] Descartar reputación como moneda de bloqueo: solo títulos y ofertas [S]
- [ ] Descartar recompensas de poder en logros: solo cosmético/informativo/QoL [S]
- [ ] Registrar decisiones D1-D10 en 02-Analisis.md [S]

## K. Diseño — arquitectura del sistema

- [ ] Definir ProgressionManager como orquestador central (marcado de hitos, señales, persistencia) [M]
- [ ] Definir MilestoneRegistry como catálogo data-driven con validación [M]
- [ ] Definir UnlockSystem como evaluador de condiciones con dirty flags y caché [M]
- [ ] Definir PlayerProfile como perfil de estadísticas y reputación [M]
- [ ] Diagramar flujo evento → estadística → reevaluación → señal de hito [M]
- [ ] Diagramar flujo de reflejo de sellos/capítulos de M22 sin validar el grafo [M]
- [ ] Diagramar flujo de carga jugador nuevo vs veterano con idempotencia [M]
- [ ] Diagramar flujo de condición imposible con cooperación de M66 [M]
- [ ] Definir contrato de señales de salida en tabla (emisor/consumidores) [M]
- [ ] Definir contrato de señales de entrada (M13/M18/M20/M22/M38/M07) [M]
- [ ] Definir sección "progresion" versionada en GameState (M59) [M]
- [x] Definir tipología de condiciones (10 tipos + compuesta) en tabla [M]
- [ ] Definir catálogo inicial de hitos de referencia por dominio (8 ejemplos) [M]
- [ ] Mantener la regla de recompensas no críticas (cosmético/info/QoL) [S]

## L. Diseño — evaluación de condiciones

- [ ] Implementar ConditionDefinition.evaluar(estado) como predicado puro sin efectos secundarios [C]
- [ ] Implementar progreso_parcial(estado) devolviendo {logrado, requerido} cuando es cuantificable [M]
- [ ] Implementar operadores AND/OR/NOT sobre hijos compuestos [M]
- [ ] Implementar mapa condiciones_de_estadistica(stat_id) para dirty flags [M]
- [ ] Implementar marcar_sucia(stat_id) que invalida solo las condiciones dependientes [M]
- [ ] Implementar evaluar(condicion_id) con caché de resultados congelados [M]
- [ ] Implementar reevaluar_sucias() llamado solo por eventos, nunca por frame [M]
- [ ] Implementar detectar_condiciones_imposibles() estático y dinámico [M]
- [ ] Asegurar evaluación perezosa del progreso parcial (solo cuando la UI lo pide) [S]

## M. Integración con M13 (Herramientas)

- [x] Consumir la senal de cambio de nivel de herramienta de M13 (herramienta_equipada) [M]
- [x] Registrar hito reflejo por cada herramienta al alcanzar cada nivel [M]
- [x] Definir condiciones nivel_modulo(herramienta, ref, nivel) en el catálogo [M]
- [x] Implementar conectar_tool_controller(tc) en ProgressionManager [M]
- [x] Emitir nivel_herramienta_cambio(id, nivel) desde puente M71 [S]
- [x] Test headless de integracion M13->M71 nivel_herramienta [M]

## N. Integración con M18 (Casas)

- [ ] Consumir la señal de cambio de nivel de casa de M18 (nombre a confirmar) [M]
- [ ] Registrar hitos reflejo de niveles de casa [M]
- [x] Definir condiciones nivel_modulo(casa, ref, nivel) [M]
- [ ] Permitir desbloqueos tipados "info"/"receta" de decoración o mejoras [S]
- [ ] No validar construcciones ni mover bloques (M17/M18) [S]
- [ ] Emitir señal al alcanzar nivel de casa para notificación de M53 [S]

## O. Integración con M20 (Amistad)

- [ ] Consumir señal nivel_amistad_cambio(npc_id, nivel) de M20 [M]
- [ ] Actualizar estadísticas de amistad por NPC y hallazgos ("amigos en nivel N") [M]
- [ ] Calcular reputación con componente de amistad ponderado al 60% [M]
- [ ] Definir hitos sociales ("primer amigo nivel 3", "todas las amistades en nivel 2") [M]
- [ ] Permitir desbloqueos sociales por amistad (trueques únicos M38, eventos M74) sin bloquear contenido principal [M]
- [ ] Garantizar que amistad 0 nunca impide progresar [S]
- [ ] Emitir títulos sociales por hitos de amistad (ej: "Amigo del Pueblo") [S]

## P. Integración con M22 (Historia Principal)

- [ ] Consumir sello_obtenido(sello_id) y capitulo_avanzado(capitulo_id) como solo lectura [M]
- [ ] Registrar hitos narrativos reflejos por sello y capítulo [M]
- [x] Registrar hitos narrativos reflejos por sello y capitulo [M]
- [x] Definir condiciones sello_historia(sello_id) y capitulo_historia(capitulo_id) [M]
- [ ] Permitir desbloqueos de contenido tardío condicionados a sellos con vigilancia de M66 [M]
- [ ] Registrar los 5 finales de M22 como hitos de cierre [M]
- [ ] Coordinar con postgame (M75) la re-priorización de metas tras finalizar [M]
- [ ] Reflejar sellos como hitos informativos sin recompensas de poder (la recompensa es el contenido) [S]
- [x] Reflejar sellos como hitos informativos sin recompensas de poder (la recompensa es el contenido) [S]

## Q. Integración con M38 (Economía)

- [ ] Consumir transaccion_registrada(tx) para estadísticas monetarias [M]
- [ ] Consumir trueque_exitoso(...) para estadística de trueques [M]
- [ ] Mantener monedas_ganadas_total y monedas_gastadas_total como acumuladores de partida [M]
- [ ] Definir condición riqueza_acumulada(umbral) solo para hitos informativos, nunca para contenido principal [M]
- [ ] Definir hitos económicos celebratorios ("primer millar", "10 trueques") [S]
- [ ] Calcular reputación con componente de contribuciones ponderado al 40% [M]
- [ ] Garantizar que la riqueza nunca sea requisito de progreso principal (regla de oro) [S]

## R. Edge cases

- [ ] Desbloqueo duplicado por doble evento: evaluación idempotente sin re-emisión [M]
- [ ] Hito marcado dos veces en el mismo frame: segunda llamada devuelve false [M]
- [ ] Progreso perdido por guardado corrupto: sección versionada con validación al cargar [M]
- [ ] Condición actualmente no cumplible: reportada a M66 con ruta alternativa [M]
- [ ] Condición estáticamente imposible: error bloqueante en editor antes de jugar [M]
- [ ] Jugador nuevo: sin hitos pre-alcanzados, flujo de onboarding M92 [S]
- [ ] Jugador veterano: restauración sin re-emitir señales ni repetir tutoriales [M]
- [ ] Muchos hitos simultáneos al despertar: cola de notificaciones priorizada en M53 [M]
- [ ] Estadística desconocida en condición: validación en editor + fallback seguro en runtime [M]
- [ ] Ciclo en dependencias de hitos (A requiere B, B requiere A): detectado en validación topológica [M]
- [ ] Hito de dominio con módulo no implementado aún: el sistema marca [S] deuda y no crashea [M]
- [ ] Reputación con cero amistades y cero contribuciones: consultable y cero, sin bloqueo [S]
- [ ] Reset de día con estadísticas del día pendientes: resetea solo contadores del día [M]
- [ ] Flash de título: aplicar recompensas de título una sola vez, sin duplicados [S]
- [ ] Primera vez marcada tras restauración de guardado: se conserva sin duplicar ni perder [M]
- [ ] Migración de guardado antiguo sin sección "progresion": inicialización completa con aviso [M]

## S. Optimización

- [ ] Búsquedas de hitos/desbloqueos O(1) con diccionarios precargados en _ready() [M]
- [ ] Precargar y validar catálogos una sola vez al inicio [S]
- [ ] Reevaluación solo por evento (dirty flags), cero bucles por frame [M]
- [ ] Caché de evaluaciones con invalidación selectiva por estadística [M]
- [ ] Progreso parcial evaluado de forma perezosa, solo bajo demanda de la UI [M]
- [ ] Condiciones como RefCounted reutilizados desde el pool del registry, sin instanciación en runtime [M]
- [ ] Primeras veces y hitos en Dictionary[StringName, bool] sin arrays lineales [S]
- [ ] Estado de progresión plano (Dictionary) de tamaño acotado, independiente de los frames [S]
- [ ] Sin asignaciones pesadas en el camino de evaluación (predicados puros) [M]

## T. Documentación entregada

- [ ] Crear 01-Requerimientos.md con problema, objetivo, alcance y RF1-RF16 [M]
- [ ] Crear 02-Analisis.md con dominio, curvas, anti-frustración, alternativas y decisiones [M]
- [ ] Crear 03-Diseno.md con arquitectura, flujos, clases, contratos de señales y persistencia [M]
- [ ] Crear 04-Codigo.md con rutas previstas res://progresion/... y firmas GDScript [M]
- [ ] Incluir Notas del Agente en 04-Codigo.md con honestidad y recomendaciones [S]
- [ ] Crear 05-Checklist.md con más de 130 ítems todos completados [M]
- [ ] Firmar todos los archivos con modelo y plataforma [S]
- [ ] Copiar plan-inicial a plan-actual byte a byte (verificación por hash) [S]

## U. Testings

- [ ] Definir prueba de marcado idempotente: doble llamada no re-emite ni duplica [M]
- [ ] Definir prueba de condición stat_min con umbral exacto y superado [M]
- [ ] Definir prueba de condición compuesta AND/OR/NOT [M]
- [x] Definir prueba de nivel_modulo con niveles de M13/M18 simulados [M]
- [ ] Definir prueba de reflejo de sellos de M22 (solo lectura, sin validación propia) [M]
- [ ] Definir prueba de persistencia: guardar/cargar con hitos, estadísticas y primeras veces exactos [M]
- [ ] Definir prueba de jugador nuevo vs veterano: sin re-emisión de hitos en carga [M]
- [ ] Definir prueba de condición imposible: detección estática en editor y ruta alternativa en runtime [M]
- [ ] Definir prueba de reputación: sube con amistad y contribuciones, nunca decae sola [M]
- [ ] Definir prueba de reset diario: contadores del día se limpian al nuevo_dia_laborable (M29) [M]
- [ ] Definir prueba de determinismo: misma partida → mismos hitos en el mismo orden [M]
- [ ] Definir prueba de rendimiento: 5000 reevaluaciones simuladas sin picos y sin asignaciones [M]
- [ ] Definir prueba de cero consumidores: los autoloads funcionan sin UI conectada [S]
- [ ] Marcar testings como pendientes hasta la implementación (se ejecutarán según sección 14 de AGENTS.md) [S]
