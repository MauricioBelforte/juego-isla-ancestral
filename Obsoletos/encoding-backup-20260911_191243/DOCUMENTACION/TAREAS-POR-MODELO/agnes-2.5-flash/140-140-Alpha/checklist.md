# Tareas módulo 140 140-Alpha

**Estado:** ðŸŸ¢ Disponible

**Items pendientes:** 110

[ ] T-140-001: Definir la secuencia de 6 Sellos como esqueleto narrativo de Alpha
[ ] T-140-002: Definir los 3 actos: descubrimiento, crisis, resolución
[ ] T-140-003: Definir prerequisitos de cada Sello (S1 libre, S2 amistades, S3 templo+coleccionables, S4 agricultura+museo, S5 viajes+eventos, S6 todos+sellos)
[ ] T-140-004: Modelar prerequisitos con `ICondicionDeSello` persistida en save v3
[ ] T-140-005: Definir pistas suaves en el diario sin romper misterio (M153)
[ ] T-140-006: Definir el epílogo en el faro tras el Sello 6
[ ] T-140-007: Asegurar 3 rutas de orden de sellos sin bloqueos (M66)
[ ] T-140-008: Definir retorno seguro si el jugador vende/desecha ítems clave (anti-softlock)
[ ] T-140-009: Definir el personaje de Elysia con presencia en Sello 2 y Acto 3
[ ] T-140-010: Definir coherencia con biblia M147 (canon de eventos de sellos)
[ ] T-140-011: Definir los diálogos de hitos de sellos (10+ líneas, M21)
[ ] T-140-012: Definir la música de cada acto (M41)
[ ] T-140-013: Definir 30+ misiones secundarias, con cadenas de amistad completas (M23/M20)
[ ] T-140-014: Definir el registro de estado de historia en el diario (M55)
[ ] T-140-015: Verificar presencia de agricultura completa (estaciones, riego, heladas) (M33)
[ ] T-140-016: Verificar presencia de pesca completa (spots, clima, rarezas) (M34)
[ ] T-140-017: Verificar presencia de minería completa (vetas, profundidad, mejoras) (M35)
[ ] T-140-018: Verificar presencia de crafting y cocina completos (60+ recetas) (M16)
[ ] T-140-019: Verificar presencia de construcción ampliada (piezas de islas, invernadero) (M17)
[ ] T-140-020: Verificar presencia de amistad avanzada (niveles 1-10, regalos, eventos) (M20)
[ ] T-140-021: Verificar presencia de viajes entre islas (M28)
[ ] T-140-022: Verificar presencia de templos con puzzles complejos (M26/M24)
[ ] T-140-023: Verificar presencia de artefactos 6 pasivos (M13/M71)
[ ] T-140-024: Verificar herramientas 5 niveles (M13)
[ ] T-140-025: Verificar habilidades con XP y ventajas (M71)
[ ] T-140-026: Definir el menú de progresión con estados visibles (M53/M71)
[ ] T-140-027: Verificar que el 100% de M71 está presente en alguna forma en Alpha
[ ] T-140-028: Definir integración amistad→economía (5-10% precio)
[ ] T-140-029: Definir integración clima→cultivos (lluvia 20%, helada)
[ ] T-140-030: Definir integración calendario→rutinas NPC (fiestas)
[ ] T-140-031: Definir integración construcción→amistad (regalos fabricados +25%)
[ ] T-140-032: Definir integración viajes→estación vegetal por isla
[ ] T-140-033: Definir integración templos→artefactos→progresión
[ ] T-140-034: Definir integración economía global→tiendas por isla
[ ] T-140-035: Definir integración clima→audio ambiental (M32/M42)
[ ] T-140-036: Definir integración eventos→diario (M74/M55)
[ ] T-140-037: Definir el servicio `Almanaque` como única fuente de tiempo/clima/eventos
[ ] T-140-038: Asegurar que `HistoriaMaster` no acopla misiones individuales
[ ] T-140-039: Definir pruebas de integración por cadena (M112)
[ ] T-140-040: Definir curvas Alpha para: precios, drops, XP, amistad, dificultad de puzzles, cultivos
[ ] T-140-041: Definir la simulación M93 en CI con escenarios: productivo, completista, administrador
[ ] T-140-042: Definir umbral: 40 h simuladas sin alertas críticas
[ ] T-140-043: Definir playtest dirigido mensual con data de oro/hora
[ ] T-140-044: Definir feature freeze de balance 2 semanas antes del GONOGO
[ ] T-140-045: Definir márgenes por categoría (55-70%)
[ ] T-140-046: Definir anti-grind y anti-exploit en los nuevos flujos (M93)
[ ] T-140-047: Definir balance de regalos de amistad por afinidad (M20/M93)
[ ] T-140-048: Definir balance de recetas por isla (M16/M93)
[ ] T-140-049: Definir balance de temporada (precios estacionales de cultivos)
[ ] T-140-050: Definir reporte de balance semanal al team (M104)
[ ] T-140-051: Definir las 4 islas jugables de Alpha (Aurora, Coral, Ceniza, Flora)
[ ] T-140-052: Definir los 2 templos nuevos (Profundidades, Ceniza)
[ ] T-140-053: Definir 24-30 NPC con rutinas en las 4 islas
[ ] T-140-054: Definir 80 coleccionables de 100 (M73)
[ ] T-140-055: Definir museo con las categorías completas (M37)
[ ] T-140-056: Definir 4 eventos estacionales base (M74)
[ ] T-140-057: Definir el recetario de 60+ con ítems de todas las islas (M16)
[ ] T-140-058: Definir flora y fauna por isla (M50/M36)
[ ] T-140-059: Definir audio por zona completo (M41-M44)
[ ] T-140-060: Definir la meta de partida completa 60-100 h
[ ] T-140-061: Definir el método de verificación de horas (telemetría de sesión)
[ ] T-140-062: Definir reutilización de assets vía pipeline M108 para el contenido
[ ] T-140-063: Definir dashboard: FPS/p99, memoria, tiempos de carga, draw calls
[ ] T-140-064: Definir gate CI de presupuestos por zona (M61)
[ ] T-140-065: Definir presupuesto de memoria global Alpha (M62)
[ ] T-140-066: Definir presupuesto de tiempos de carga/streaming (M63)
[ ] T-140-067: Definir reporte semanal de rendimiento con tendencia
[ ] T-140-068: Definir plan de acción ante regresiones (rollback de zona)
[ ] T-140-069: Definir el sprint final de QA de 3-4 semanas
[ ] T-140-070: Definir triaje diario con severidades P0-P2
[ ] T-140-071: Definir la política de duplicados en el backlog
[ ] T-140-072: Definir fix con test de regresión adjunto (M112)
[ ] T-140-073: Definir encuesta de diversión y confusión (M152/M114)
[ ] T-140-074: Definir métricas de bugs por semana (abiertos/cerrados/regresión)
[ ] T-140-075: Definir cierre con 0 bugs P0/P1 y P2 documentados
[ ] T-140-076: Definir la auditoría de severidad duplicada
[ ] T-140-077: Definir la integración de QA con el tracking (M101/M102)
[ ] T-140-078: Definir sprint de deuda de 2 semanas
[ ] T-140-079: Definir objetivo: 0 TODO/FIXME al cierre
[ ] T-140-080: Definir eliminación de código muerto de fases previas
[ ] T-140-081: Definir refactor de hot spots de rendimiento detectados
[ ] T-140-082: Definir objetivo de reducción ≥ 50%
[ ] T-140-083: Definir informe de deuda post-sprint
[ ] T-140-084: Definir registro de qué deuda queda deliberadamente (con dueño y plazo)
[ ] T-140-085: Definir enlace M135↔M111 (deuda visible en calidad de código)
[ ] T-140-086: Definir los 10 hits H1-H10 del GONOGO
[ ] T-140-087: Definir backlog priorizado de Beta por riesgo
[ ] T-140-088: Definir la lista de localización pendiente para Beta (M87)
[ ] T-140-089: Definir la lista de plataformas objetivo para Beta
[ ] T-140-090: Definir el pulido de UI pendiente de Beta
[ ] T-140-091: Definir la segunda pasada de accesibilidad (M58)
[ ] T-140-092: Definir el documento GONOGO-BETA firmado con fecha
[ ] T-140-093: Extender save v3 a todo el mundo (todas las islas)
[ ] T-140-094: Definir migración versionada v3→v3.1 (sellos, colecciones, almanaque)
[ ] T-140-095: Definir flags globales de historia y artefactos
[ ] T-140-096: Definir 30 ciclos de guardar/cargar sin pérdidas
[ ] T-140-097: Definir recuperación de save corrupto con copia (M66)
[ ] T-140-098: Definir telemetría de tamaño de save por zona
[ ] T-140-099: Definir modos de color para puzzles de espejos/sombras (M58)
[ ] T-140-100: Definir navegación del diario con gamepad (M57)
[ ] T-140-101: Definir estados vacíos de colecciones con texto claro (M53)
[ ] T-140-102: Definir feedback de audio completo en nuevas interacciones (M44)
[ ] T-140-103: Definir tamaño mínimo de texto al 150% (M58)
[ ] T-140-104: Definir el checklist de verificación DoD antes de declarar Alpha cerrada
[ ] T-140-105: Definir flujo completo verificado en Play Mode en las 4 islas
[ ] T-140-106: Definir el registro de learning de la fase (qué se corrigió)
[ ] T-140-107: Definir la evaluación de fechas reales vs plan (roadmap M136)
[ ] T-140-108: Definir el inventario de bugs conocidos para Beta (M101)
[ ] T-140-109: Definir la firma del GONOGO-BETA con fecha y resultado
[ ] T-140-110: Definir la mano derecha de continuidad para M141 (qué se entrega)
