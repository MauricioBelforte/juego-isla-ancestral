**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 140: Alpha (142 ítems)

## Convención
- `[x]` = completado por documentación (fase documentada y validable). `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días).

## 1. Historia jugable (M22/M153/M23)

- [x] Definir la secuencia de 6 Sellos como esqueleto narrativo de Alpha [C]
- [x] Definir los 3 actos: descubrimiento, crisis, resolución [M]
- [x] Definir prerequisitos de cada Sello (S1 libre, S2 amistades, S3 templo+coleccionables, S4 agricultura+museo, S5 viajes+eventos, S6 todos+sellos) [M]
- [x] Modelar prerequisitos con `ICondicionDeSello` persistida en save v3 [M]
- [x] Definir pistas suaves en el diario sin romper misterio (M153) [S]
- [x] Definir el epílogo en el faro tras el Sello 6 [S]
- [x] Asegurar 3 rutas de orden de sellos sin bloqueos (M66) [M]
- [x] Definir retorno seguro si el jugador vende/desecha ítems clave (anti-softlock) [S]
- [x] Definir el personaje de Elysia con presencia en Sello 2 y Acto 3 [M]
- [x] Definir coherencia con biblia M147 (canon de eventos de sellos) [M]
- [x] Definir los diálogos de hitos de sellos (10+ líneas, M21) [M]
- [x] Definir la música de cada acto (M41) [S]
- [x] Definir 30+ misiones secundarias, con cadenas de amistad completas (M23/M20) [C]
- [x] Definir el registro de estado de historia en el diario (M55) [S]

## 2. Mecánicas principales presentes (M71)

- [x] Verificar presencia de agricultura completa (estaciones, riego, heladas) (M33) [C]
- [x] Verificar presencia de pesca completa (spots, clima, rarezas) (M34) [C]
- [x] Verificar presencia de minería completa (vetas, profundidad, mejoras) (M35) [C]
- [x] Verificar presencia de crafting y cocina completos (60+ recetas) (M16) [C]
- [x] Verificar presencia de construcción ampliada (piezas de islas, invernadero) (M17) [C]
- [x] Verificar presencia de amistad avanzada (niveles 1-10, regalos, eventos) (M20) [C]
- [x] Verificar presencia de viajes entre islas (M28) [C]
- [x] Verificar presencia de templos con puzzles complejos (M26/M24) [C]
- [x] Verificar presencia de artefactos 6 pasivos (M13/M71) [M]
- [x] Verificar herramientas 5 niveles (M13) [M]
- [x] Verificar habilidades con XP y ventajas (M71) [M]
- [x] Definir el menú de progresión con estados visibles (M53/M71) [M]
- [x] Verificar que el 100% de M71 está presente en alguna forma en Alpha [C]

## 3. Sistemas integrados (RF3)

- [x] Definir integración amistad→economía (5-10% precio) [M]
- [x] Definir integración clima→cultivos (lluvia 20%, helada) [M]
- [x] Definir integración calendario→rutinas NPC (fiestas) [M]
- [x] Definir integración construcción→amistad (regalos fabricados +25%) [M]
- [x] Definir integración viajes→estación vegetal por isla [M]
- [x] Definir integración templos→artefactos→progresión [M]
- [x] Definir integración economía global→tiendas por isla [M]
- [x] Definir integración clima→audio ambiental (M32/M42) [S]
- [x] Definir integración eventos→diario (M74/M55) [S]
- [x] Definir el servicio `Almanaque` como única fuente de tiempo/clima/eventos [M]
- [x] Asegurar que `HistoriaMaster` no acopla misiones individuales [M]
- [x] Definir pruebas de integración por cadena (M112) [M]

## 4. Primer balance completo (M93/M38)

- [x] Definir curvas Alpha para: precios, drops, XP, amistad, dificultad de puzzles, cultivos [C]
- [x] Definir la simulación M93 en CI con escenarios: productivo, completista, administrador [M]
- [x] Definir umbral: 40 h simuladas sin alertas críticas [M]
- [x] Definir ajuste en tiempo de dato (JSON re-cargable) sin recompilar [M]
- [x] Definir playtest dirigido mensual con data de oro/hora [M]
- [x] Definir feature freeze de balance 2 semanas antes del GONOGO [S]
- [x] Definir márgenes por categoría (55-70%) [S]
- [x] Definir anti-grind y anti-exploit en los nuevos flujos (M93) [M]
- [x] Definir balance de regalos de amistad por afinidad (M20/M93) [M]
- [x] Definir balance de recetas por isla (M16/M93) [M]
- [x] Definir balance de temporada (precios estacionales de cultivos) [S]
- [x] Definir reporte de balance semanal al team (M104) [S]

## 5. Contenido suficiente (RF5)

- [x] Definir las 4 islas jugables de Alpha (Aurora, Coral, Ceniza, Flora) [C]
- [x] Definir los 2 templos nuevos (Profundidades, Ceniza) [C]
- [x] Definir 24-30 NPC con rutinas en las 4 islas [C]
- [x] Definir 80 coleccionables de 100 (M73) [M]
- [x] Definir museo con las categorías completas (M37) [M]
- [x] Definir 4 eventos estacionales base (M74) [M]
- [x] Definir el recetario de 60+ con ítems de todas las islas (M16) [C]
- [x] Definir flora y fauna por isla (M50/M36) [C]
- [x] Definir audio por zona completo (M41-M44) [C]
- [x] Definir la meta de partida completa 60-100 h [M]
- [x] Definir el método de verificación de horas (telemetría de sesión) [S]
- [x] Definir reutilización de assets vía pipeline M108 para el contenido [C]

## 6. Rendimiento medible (RF6/M61-M63)

- [x] Definir la build semanal de referencia [M]
- [x] Definir dashboard: FPS/p99, memoria, tiempos de carga, draw calls [M]
- [x] Definir gate CI de presupuestos por zona (M61) [M]
- [x] Definir presupuesto de memoria global Alpha (M62) [M]
- [x] Definir presupuesto de tiempos de carga/streaming (M63) [M]
- [x] Definir telemetría de sesión en builds de playtest (M104/M105) [M]
- [x] Definir profiling periódico por sistema nuevo [M]
- [x] Definir escenario de referencia (ruta fija de 20 min por build) [M]
- [x] Definir reporte semanal de rendimiento con tendencia [S]
- [x] Definir plan de acción ante regresiones (rollback de zona) [S]

## 7. QA intensivo (RF7/M101/M102/M112)

- [x] Definir el sprint final de QA de 3-4 semanas [C]
- [x] Definir triaje diario con severidades P0-P2 [M]
- [x] Definir la política de duplicados en el backlog [S]
- [x] Definir fix con test de regresión adjunto (M112) [M]
- [x] Definir build semanal de playtest con 5+ jugadores (M114) [M]
- [x] Definir encuesta de diversión y confusión (M152/M114) [S]
- [x] Definir métricas de bugs por semana (abiertos/cerrados/regresión) [S]
- [x] Definir cierre con 0 bugs P0/P1 y P2 documentados [S]
- [x] Definir la auditoría de severidad duplicada [S]
- [x] Definir la integración de QA con el tracking (M101/M102) [M]

## 8. Corrección de arquitectura (M07/M111)

- [x] Definir inventario de TODO/FIXME por script CI [M]
- [x] Definir sprint de deuda de 2 semanas [M]
- [x] Definir objetivo: 0 TODO/FIXME al cierre [S]
- [x] Definir revisiones de diseño por sistema integrado [M]
- [x] Definir la verificación de interfaz entre managers (M07) [M]
- [x] Definir eliminación de código muerto de fases previas [S]
- [x] Definir refactor de hot spots de rendimiento detectados [M]
- [x] Definir metrica de complejidad ciclomática por sistema (M111) [S]

## 9. Reducción de deuda técnica (M135)

- [x] Re-metricar la deuda de M135 por sistema [M]
- [x] Definir objetivo de reducción ≥ 50% [S]
- [x] Definir informe de deuda post-sprint [S]
- [x] Definir registro de qué deuda queda deliberadamente (con dueño y plazo) [S]
- [x] Definir enlace M135↔M111 (deuda visible en calidad de código) [S]

## 10. Preparar Beta (M141)

- [x] Definir los 10 hits H1-H10 del GONOGO [M]
- [x] Definir backlog priorizado de Beta por riesgo [M]
- [x] Definir la lista de localización pendiente para Beta (M87) [M]
- [x] Definir la lista de plataformas objetivo para Beta [M]
- [x] Definir el pulido de UI pendiente de Beta [M]
- [x] Definir la segunda pasada de accesibilidad (M58) [M]
- [x] Definir el documento GONOGO-BETA firmado con fecha [S]

## 11. Save y persistencia (M59/M60)

- [x] Extender save v3 a todo el mundo (todas las islas) [M]
- [x] Definir migración versionada v3→v3.1 (sellos, colecciones, almanaque) [M]
- [x] Definir flags globales de historia y artefactos [M]
- [x] Definir 30 ciclos de guardar/cargar sin pérdidas [M]
- [x] Definir recuperación de save corrupto con copia (M66) [S]
- [x] Definir telemetría de tamaño de save por zona [S]

## 12. Accesibilidad y UX (M58/M53/M57)

- [x] Validar M58 en sistemas nuevos (subtítulos, remapeo, reducción de efectos) [M]
- [x] Definir config de dificultad de puzzles (M58) [S]
- [x] Definir modos de color para puzzles de espejos/sombras (M58) [M]
- [x] Definir navegación del diario con gamepad (M57) [M]
- [x] Definir estados vacíos de colecciones con texto claro (M53) [S]
- [x] Definir feedback de audio completo en nuevas interacciones (M44) [S]
- [x] Definir tamaño mínimo de texto al 150% (M58) [S]

## 13. Cierre de fase (GONOGO-BETA)

- [x] Definir el checklist de verificación DoD antes de declarar Alpha cerrada [S]
- [x] Definir 0 errores en consola al entrar en Play Mode en builds finales [M]
- [x] Definir flujo completo verificado en Play Mode en las 4 islas [M]
- [x] Definir el registro de learning de la fase (qué se corrigió) [S]
- [x] Definir la evaluación de fechas reales vs plan (roadmap M136) [S]
- [x] Definir el inventario de bugs conocidos para Beta (M101) [M]
- [x] Definir la firma del GONOGO-BETA con fecha y resultado [S]
- [x] Definir la mano derecha de continuidad para M141 (qué se entrega) [S]

## Totales

**Total de ítems:** 124
**Ítems resueltos por documentación:** 124 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)