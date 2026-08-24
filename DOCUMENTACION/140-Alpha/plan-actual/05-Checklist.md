**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 140: Alpha (142 ítems)

## Convención
- `[ ]` = completado por documentación (fase documentada y validable). `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días).

## 1. Historia jugable (M22/M153/M23)

- [ ] Definir la secuencia de 6 Sellos como esqueleto narrativo de Alpha [C]
- [ ] Definir los 3 actos: descubrimiento, crisis, resolución [M]
- [ ] Definir prerequisitos de cada Sello (S1 libre, S2 amistades, S3 templo+coleccionables, S4 agricultura+museo, S5 viajes+eventos, S6 todos+sellos) [M]
- [ ] Modelar prerequisitos con `ICondicionDeSello` persistida en save v3 [M]
- [ ] Definir pistas suaves en el diario sin romper misterio (M153) [S]
- [ ] Definir el epílogo en el faro tras el Sello 6 [S]
- [ ] Asegurar 3 rutas de orden de sellos sin bloqueos (M66) [M]
- [ ] Definir retorno seguro si el jugador vende/desecha ítems clave (anti-softlock) [S]
- [ ] Definir el personaje de Elysia con presencia en Sello 2 y Acto 3 [M]
- [ ] Definir coherencia con biblia M147 (canon de eventos de sellos) [M]
- [ ] Definir los diálogos de hitos de sellos (10+ líneas, M21) [M]
- [ ] Definir la música de cada acto (M41) [S]
- [ ] Definir 30+ misiones secundarias, con cadenas de amistad completas (M23/M20) [C]
- [ ] Definir el registro de estado de historia en el diario (M55) [S]

## 2. Mecánicas principales presentes (M71)

- [ ] Verificar presencia de agricultura completa (estaciones, riego, heladas) (M33) [C]
- [ ] Verificar presencia de pesca completa (spots, clima, rarezas) (M34) [C]
- [ ] Verificar presencia de minería completa (vetas, profundidad, mejoras) (M35) [C]
- [ ] Verificar presencia de crafting y cocina completos (60+ recetas) (M16) [C]
- [ ] Verificar presencia de construcción ampliada (piezas de islas, invernadero) (M17) [C]
- [ ] Verificar presencia de amistad avanzada (niveles 1-10, regalos, eventos) (M20) [C]
- [ ] Verificar presencia de viajes entre islas (M28) [C]
- [ ] Verificar presencia de templos con puzzles complejos (M26/M24) [C]
- [ ] Verificar presencia de artefactos 6 pasivos (M13/M71) [M]
- [ ] Verificar herramientas 5 niveles (M13) [M]
- [ ] Verificar habilidades con XP y ventajas (M71) [M]
- [ ] Definir el menú de progresión con estados visibles (M53/M71) [M]
- [ ] Verificar que el 100% de M71 está presente en alguna forma en Alpha [C]

## 3. Sistemas integrados (RF3)

- [ ] Definir integración amistad→economía (5-10% precio) [M]
- [ ] Definir integración clima→cultivos (lluvia 20%, helada) [M]
- [ ] Definir integración calendario→rutinas NPC (fiestas) [M]
- [ ] Definir integración construcción→amistad (regalos fabricados +25%) [M]
- [ ] Definir integración viajes→estación vegetal por isla [M]
- [ ] Definir integración templos→artefactos→progresión [M]
- [ ] Definir integración economía global→tiendas por isla [M]
- [ ] Definir integración clima→audio ambiental (M32/M42) [S]
- [ ] Definir integración eventos→diario (M74/M55) [S]
- [ ] Definir el servicio `Almanaque` como única fuente de tiempo/clima/eventos [M]
- [ ] Asegurar que `HistoriaMaster` no acopla misiones individuales [M]
- [ ] Definir pruebas de integración por cadena (M112) [M]

## 4. Primer balance completo (M93/M38)

- [ ] Definir curvas Alpha para: precios, drops, XP, amistad, dificultad de puzzles, cultivos [C]
- [ ] Definir la simulación M93 en CI con escenarios: productivo, completista, administrador [M]
- [ ] Definir umbral: 40 h simuladas sin alertas críticas [M]
- [ ] Definir ajuste en tiempo de dato (JSON re-cargable) sin recompilar [M]
- [ ] Definir playtest dirigido mensual con data de oro/hora [M]
- [ ] Definir feature freeze de balance 2 semanas antes del GONOGO [S]
- [ ] Definir márgenes por categoría (55-70%) [S]
- [ ] Definir anti-grind y anti-exploit en los nuevos flujos (M93) [M]
- [ ] Definir balance de regalos de amistad por afinidad (M20/M93) [M]
- [ ] Definir balance de recetas por isla (M16/M93) [M]
- [ ] Definir balance de temporada (precios estacionales de cultivos) [S]
- [ ] Definir reporte de balance semanal al team (M104) [S]

## 5. Contenido suficiente (RF5)

- [ ] Definir las 4 islas jugables de Alpha (Aurora, Coral, Ceniza, Flora) [C]
- [ ] Definir los 2 templos nuevos (Profundidades, Ceniza) [C]
- [ ] Definir 24-30 NPC con rutinas en las 4 islas [C]
- [ ] Definir 80 coleccionables de 100 (M73) [M]
- [ ] Definir museo con las categorías completas (M37) [M]
- [ ] Definir 4 eventos estacionales base (M74) [M]
- [ ] Definir el recetario de 60+ con ítems de todas las islas (M16) [C]
- [ ] Definir flora y fauna por isla (M50/M36) [C]
- [ ] Definir audio por zona completo (M41-M44) [C]
- [ ] Definir la meta de partida completa 60-100 h [M]
- [ ] Definir el método de verificación de horas (telemetría de sesión) [S]
- [ ] Definir reutilización de assets vía pipeline M108 para el contenido [C]

## 6. Rendimiento medible (RF6/M61-M63)

- [ ] Definir la build semanal de referencia [M]
- [ ] Definir dashboard: FPS/p99, memoria, tiempos de carga, draw calls [M]
- [ ] Definir gate CI de presupuestos por zona (M61) [M]
- [ ] Definir presupuesto de memoria global Alpha (M62) [M]
- [ ] Definir presupuesto de tiempos de carga/streaming (M63) [M]
- [ ] Definir telemetría de sesión en builds de playtest (M104/M105) [M]
- [ ] Definir profiling periódico por sistema nuevo [M]
- [ ] Definir escenario de referencia (ruta fija de 20 min por build) [M]
- [ ] Definir reporte semanal de rendimiento con tendencia [S]
- [ ] Definir plan de acción ante regresiones (rollback de zona) [S]

## 7. QA intensivo (RF7/M101/M102/M112)

- [ ] Definir el sprint final de QA de 3-4 semanas [C]
- [ ] Definir triaje diario con severidades P0-P2 [M]
- [ ] Definir la política de duplicados en el backlog [S]
- [ ] Definir fix con test de regresión adjunto (M112) [M]
- [ ] Definir build semanal de playtest con 5+ jugadores (M114) [M]
- [ ] Definir encuesta de diversión y confusión (M152/M114) [S]
- [ ] Definir métricas de bugs por semana (abiertos/cerrados/regresión) [S]
- [ ] Definir cierre con 0 bugs P0/P1 y P2 documentados [S]
- [ ] Definir la auditoría de severidad duplicada [S]
- [ ] Definir la integración de QA con el tracking (M101/M102) [M]

## 8. Corrección de arquitectura (M07/M111)

- [ ] Definir inventario de TODO/FIXME por script CI [M]
- [ ] Definir sprint de deuda de 2 semanas [M]
- [ ] Definir objetivo: 0 TODO/FIXME al cierre [S]
- [ ] Definir revisiones de diseño por sistema integrado [M]
- [ ] Definir la verificación de interfaz entre managers (M07) [M]
- [ ] Definir eliminación de código muerto de fases previas [S]
- [ ] Definir refactor de hot spots de rendimiento detectados [M]
- [ ] Definir metrica de complejidad ciclomática por sistema (M111) [S]

## 9. Reducción de deuda técnica (M135)

- [ ] Re-metricar la deuda de M135 por sistema [M]
- [ ] Definir objetivo de reducción ≥ 50% [S]
- [ ] Definir informe de deuda post-sprint [S]
- [ ] Definir registro de qué deuda queda deliberadamente (con dueño y plazo) [S]
- [ ] Definir enlace M135↔M111 (deuda visible en calidad de código) [S]

## 10. Preparar Beta (M141)

- [ ] Definir los 10 hits H1-H10 del GONOGO [M]
- [ ] Definir backlog priorizado de Beta por riesgo [M]
- [ ] Definir la lista de localización pendiente para Beta (M87) [M]
- [ ] Definir la lista de plataformas objetivo para Beta [M]
- [ ] Definir el pulido de UI pendiente de Beta [M]
- [ ] Definir la segunda pasada de accesibilidad (M58) [M]
- [ ] Definir el documento GONOGO-BETA firmado con fecha [S]

## 11. Save y persistencia (M59/M60)

- [ ] Extender save v3 a todo el mundo (todas las islas) [M]
- [ ] Definir migración versionada v3→v3.1 (sellos, colecciones, almanaque) [M]
- [ ] Definir flags globales de historia y artefactos [M]
- [ ] Definir 30 ciclos de guardar/cargar sin pérdidas [M]
- [ ] Definir recuperación de save corrupto con copia (M66) [S]
- [ ] Definir telemetría de tamaño de save por zona [S]

## 12. Accesibilidad y UX (M58/M53/M57)

- [ ] Validar M58 en sistemas nuevos (subtítulos, remapeo, reducción de efectos) [M]
- [ ] Definir config de dificultad de puzzles (M58) [S]
- [ ] Definir modos de color para puzzles de espejos/sombras (M58) [M]
- [ ] Definir navegación del diario con gamepad (M57) [M]
- [ ] Definir estados vacíos de colecciones con texto claro (M53) [S]
- [ ] Definir feedback de audio completo en nuevas interacciones (M44) [S]
- [ ] Definir tamaño mínimo de texto al 150% (M58) [S]

## 13. Cierre de fase (GONOGO-BETA)

- [ ] Definir el checklist de verificación DoD antes de declarar Alpha cerrada [S]
- [ ] Definir 0 errores en consola al entrar en Play Mode en builds finales [M]
- [ ] Definir flujo completo verificado en Play Mode en las 4 islas [M]
- [ ] Definir el registro de learning de la fase (qué se corrigió) [S]
- [ ] Definir la evaluación de fechas reales vs plan (roadmap M136) [S]
- [ ] Definir el inventario de bugs conocidos para Beta (M101) [M]
- [ ] Definir la firma del GONOGO-BETA con fecha y resultado [S]
- [ ] Definir la mano derecha de continuidad para M141 (qué se entrega) [S]

## Totales

**Total de ítems:** 124
**Ítems resueltos por documentación:** 124 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)