# Tareas módulo 138 138-Vertical-Slice

**Estado:** ðŸŸ¢ Disponible

**Items pendientes:** 120

[ ] T-138-001: Definir esquina de Aurora como zona del slice
[ ] T-138-002: Definir geografía: playa, bosque, prado, costa
[ ] T-138-003: Definir 3-5 puntos de interés (casa, ruina, muelle roto, arboleda, altar)
[ ] T-138-004: Definir vegetación con MultiMesh (M50, sin rebalsar draw calls)
[ ] T-138-005: Definir iluminación de la zona dentro del budget render (M49/M61)
[ ] T-138-006: Definir madera como recurso clave del slice
[ ] T-138-007: Definir árbol con 5 bloques de madera
[ ] T-138-008: Definir Hacha con 15 usos de durabilidad
[ ] T-138-009: Definir animación de swing del Hacha (M48)
[ ] T-138-010: Definir SFX de impacto y VFX de virutas (M43/M52)
[ ] T-138-011: Definir NPC Finneas con rutina de día por waypoints
[ ] T-138-012: Definir 6+ líneas de diálogo con rama de misión (M21)
[ ] T-138-013: Definir consumo de canon M147 para nombre e histórico
[ ] T-138-014: Definir regalo de bienvenida conceptual (M20 futuro)
[ ] T-138-015: Definir que Finneas no atraviese paredes en sus waypoints
[ ] T-138-016: Definir misión de 3 pasos (madera → hacha en ruina → entrega)
[ ] T-138-017: Definir recompensa: 20 AO + semilla de jardín
[ ] T-138-018: Definir margen de recompensa según M93 (5-15%)
[ ] T-138-019: Definir UX de misión: indicador de objetivo (M53)
[ ] T-138-020: Definir test: la misión no se rompe si se entrega la madera antes del diálogo
[ ] T-138-021: Definir ruina de 3 salas
[ ] T-138-022: Definir puzzle de 2 palancas + alineación de símbolos (M24)
[ ] T-138-023: Definir símbolos del canon M147 (sello_brisa)
[ ] T-138-024: Definir recompensa: Hacha de Finneas + mensaje cozy
[ ] T-138-025: Definir test de combinatoria de palancas (todas las secuencias)
[ ] T-138-026: Definir casa con entrada, cama y mesa
[ ] T-138-027: Definir dormir: fade a negro + pasar el día
[ ] T-138-028: Definir autosave al dormir
[ ] T-138-029: Definir autosave en hitos (entrega, puzzle resuelto)
[ ] T-138-030: Definir save v2 con schema_version (M60)
[ ] T-138-031: Definir tema diurno y nocturno de Aurora (2 stems)
[ ] T-138-032: Definir transición suave al dormir
[ ] T-138-033: Definir que la música use AudioStreamPlayer separado (M41)
[ ] T-138-034: Definir volumen equilibrado con SFX (M44)
[ ] T-138-035: Definir música sin copyright conflictivo (M84 Chequeado)
[ ] T-138-036: Definir SFX de extracción y colocación
[ ] T-138-037: Definir SFX de swing y moneda
[ ] T-138-038: Definir SFX de puerta y puzzle
[ ] T-138-039: Definir ambiente: viento, mar, pájaros (M42)
[ ] T-138-040: Definir mezcla con AudioMixer y buses (M42)
[ ] T-138-041: Definir IV inventario (1 fila visible)
[ ] T-138-042: Definir caja de diálogo tipográfica (M88)
[ ] T-138-043: Definir indicador de interactivo sobre el objetivo
[ ] T-138-044: Definir menú de pausa básico (continuar, salir, ajustes mínimos)
[ ] T-138-045: Definir UI sin acoplar gameplay (M07)
[ ] T-138-046: Definir VFX de extracción (fragmentos)
[ ] T-138-047: Definir VFX de colocación (polvo)
[ ] T-138-048: Definir VFX de recompensa (chispas nobles)
[ ] T-138-049: Definir VFX de dormir (humo suave)
[ ] T-138-050: Definir VFX dentro del budget partículas (M61: 1.0ms)
[ ] T-138-051: Definir animación de caminar del jugador
[ ] T-138-052: Definir animación de uso del Hacha
[ ] T-138-053: Definir animación idle/hablar de Finneas
[ ] T-138-054: Definir animación de puertas
[ ] T-138-055: Definir blend entre animaciones sin snap (M48)
[ ] T-138-056: Definir guiado visual sin texto (flechas + resaltado)
[ ] T-138-057: Definir resaltado del faro y del NPC al inicio
[ ] T-138-058: Definir ocultamiento del guiado tras la primera acción
[ ] T-138-059: Definir opción de desactivar el guiado (accesibilidad M58)
[ ] T-138-060: Definir test: tester nuevo completa el slice sin instrucciones
[ ] T-138-061: Definir serialización completa de la zona (chunks modificados)
[ ] T-138-062: Definir serialización de NPC (posición + estado de misión)
[ ] T-138-063: Definir serialización de puzzle (flags)
[ ] T-138-064: Definir validación de schema_version con migración futura
[ ] T-138-065: Definir test de 10 ciclos guardar→cargar con 0 pérdidas
[ ] T-138-066: Definir perfil M61: gameplay 2.5 / voxel 4.0 / IA 2.0 / partículas 1.0 / culling 0.5 / render 5.0 / UI 1.5
[ ] T-138-067: Definir medición P99 (máximo frame) además de FPS medio
[ ] T-138-068: Definir muestreo con VSYNC off
[ ] T-138-069: Definir punto denso de prueba (bosque + lluvia + Finneas)
[ ] T-138-070: Definir reporte `REPORTE-FPS.md` generado por `bench_slice.gd`
[ ] T-138-071: Definir loop de 20-30 min de principio a fin
[ ] T-138-072: Definir créditos de demo al final del slice
[ ] T-138-073: Definir encuesta post-slice (5+ testers)
[ ] T-138-074: Definir que el 90% de testers termine el slice
[ ] T-138-075: Definir que el 90% identifique el juego como "cozy/hechizante"
[ ] T-138-076: Definir mínimo 5 testers (3 nuevos al juego)
[ ] T-138-077: Definir sesión de 40 min máx por tester
[ ] T-138-078: Definir observación de momentos de aburrimiento/frustración
[ ] T-138-079: Definir registro de bugs por tester
[ ] T-138-080: Definir análisis de encuesta en `PLAYTEST.md`
[ ] T-138-081: Definir GONOGO con 7 criterios (completo, identificación, diversión, FPS, guardado, deuda, alcance)
[ ] T-138-082: Definir umbral de diversión ≥ 7,5/10
[ ] T-138-083: Definir umbral de FPS ≥ 60 y P99 ≤ 40 ms
[ ] T-138-084: Definir umbral de guardado: 0 pérdidas
[ ] T-138-085: Definir que el GONOGO lo firme el usuario (dueño del proyecto)
[ ] T-138-086: Definir `IDEAS-DESCARTADAS.md` para lo que no entra
[ ] T-138-087: Definir regla: nada nuevo sin pasar por el documento
[ ] T-138-088: Definir revisión semanal de alcance contra RF1-RF17
[ ] T-138-089: Definir que el creep de scope bloquee el GONOGO
[ ] T-138-090: Definir que el alcance del slice sea 100% reproducible
[ ] T-138-091: Definir integración jugador+voxel desde el prototipo (M137)
[ ] T-138-092: Definir integración NPC+diálogo+misón
[ ] T-138-093: Definir integración audio+acción (SFX en eventos)
[ ] T-138-094: Definir integración VFX+acción
[ ] T-138-095: Definir integración autosave en todos los hitos
[ ] T-138-096: Definir convenciones de nombres (`*_vs.gd`, `vslice_*`)
[ ] T-138-097: Definir que la deuda técnica se registre sin silenciarla
[ ] T-138-098: Definir que los modelos del slice pasen el pipeline estándar
[ ] T-138-099: Definir texturas con los tamaños del preset (M47)
[ ] T-138-100: Definir animaciones importadas con el formato del proyecto
[ ] T-138-101: Definir audio importado con compresión del proyecto
[ ] T-138-102: Definir que los VFX usen el pool de materiales (M47)
[ ] T-138-103: Definir guía de feedback para testers externos
[ ] T-138-104: Definir registro de primeras reacciones (video)
[ ] T-138-105: Definir recolectar métricas opcionales de la demo (M105 esbozo)
[ ] T-138-106: Definir que el feedback externo alimente GONOGO-M139
[ ] T-138-107: Definir tester que nunca jugó voxel (¿el guiado basta?)
[ ] T-138-108: Definir save con zona a medio modificar
[ ] T-138-109: Definir dormir con el puzzle sin resolver (flags)
[ ] T-138-110: Definir Finneas repetiendo líneas tras la misión (flags M21)
[ ] T-138-111: Definir recompensa que no rompe la economía de prueba (M93)
[ ] T-138-112: Definir const/export para valores repetidos
[ ] T-138-113: Definir `docs/vslice/` con PLAYTEST, REPORTE-FPS, GONOGO-M139, IDEAS-DESCARTADAS
[ ] T-138-114: Definir actualización de CHECKLIST-GLOBAL al cerrar
[ ] T-138-115: Definir log de cierre del hito en Logs/
[ ] T-138-116: Definir firma de cierre por todos los agentes que intervinieron
[ ] T-138-117: Definir tag git `vslice-v1`
[ ] T-138-118: Definir empaquetado de la demo (M116/M117)
[ ] T-138-119: Definir actualización del presupuesto con datos reales (M134)
[ ] T-138-120: Definir comunicar al usuario la decisión y próximo hito
