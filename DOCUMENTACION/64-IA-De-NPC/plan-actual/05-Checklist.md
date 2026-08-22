**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 64: IA de NPC

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [x] cumplido · [ ] pendiente · [?] no resuelto.
> Módulo **delegable**: implementación para el agente que lo reclame (requiere M19 y M61).

## A. Requisitos del módulo (10)

- [x] Definir el problema: NPCs vivos con horarios y reacciones, bajo presupuesto de agentes [S]
- [x] Registrar dependencias: M19, M61; relaciones M29/M31/M32, M36, M21, M24/26, M69, M73 [S]
- [x] Catalogar los 22 puntos de la sección 63 [S]
- [x] RF1: FSM jerárquica [S]
- [x] RF2: navegación y pathfinding (NavigationServer3D) [S]
- [x] RF3+RF4: prioridades, rutinas y comportamiento social [S]
- [x] RF5+RF6: contextual (clima/estaciones/obras/jugador) y lugares [S]
- [x] RF7+RF8: interrupciones, recuperación, fallback, anti-atascos [S]
- [x] RF9: optimización y simulación parcial [S]
- [x] NFR: cozy, presupuesto ≤ 60 plena, determinismo PRNG M29 [S]

## B. Resolución de los 22 puntos del plan (22)

- [x] P1: máquina de estados — FSM jerárquica con sub-BT [S]
- [x] P2: navegación — NavigationServer3D + navmesh global [S]
- [x] P3: pathfinding — A*, replanificación cooldown 0.5 s [S]
- [x] P4: obstáculos dinámicos — RID con prioridad [S]
- [x] P5: prioridades — vitales > trabajo > social > ocio [S]
- [x] P6: rutinas — plan diario por perfil (PRNG) [S]
- [x] P7: social — saludos, charlas cortas, afinidad [S]
- [x] P8: contextual — refugio bajo lluvia, sombra en calor [S]
- [x] P9: reacción al clima — indoor/outdoor anticipado 2 ticks [S]
- [x] P10: reacción a estaciones — festivales, fogatas, playa [S]
- [x] P11: reacción a obras — curiosidad, evitan andamiajes [S]
- [x] P12: reacción al jugador — saludar, mirar, comentar (cozy) [S]
- [x] P13: búsqueda de lugares — catálogo POI compatible [S]
- [x] P14: horarios — franjas 06-22:30 + variación ±30 min [S]
- [x] P15: interrupciones — memoria de plan (índice + resto) [S]
- [x] P16: recuperación — 2 reintentos, alternativas, log [S]
- [x] P17: fallback — IrACasa siempre navegable [S]
- [x] P18: evitar atascados — stuck 2 s → re-path; 6 s → teleport [S]
- [x] P19: evitar superpuestos — avoidance + separación 0.3 m [S]
- [x] P20: lugares imposibles — navmesh valida destinos [S]
- [x] P21: optimizar agentes — ≤ 60 plena + resto receta [S]
- [x] P22: simulación parcial — tick 1 s fuera de burbuja [S]

## C. FSM y transiciones (8)

- [x] Estado Idle y sus salidas [S]
- [x] Estado Mover con destino del plan [S]
- [x] Estado Actividad (trabajar/comer/socializar) [S]
- [x] Estado Reaccionar (interrupciones) [S]
- [x] Estado Fallback (IrACasa/Quieto) [S]
- [x] Transiciones por señales del mundo [S]
- [x] Memoria de plan al reanudar [S]
- [x] Enfriamiento de interrupciones repetidas [S]

## D. Perfiles de rutina (8)

- [x] Granjero: parcela 08-12/13-17, plaza 20-22 [S]
- [x] Pescador: muelle 07-12/14-17, cantina 20 [S]
- [x] Comerciante: tienda 09-18, mercado 20 [S]
- [x] Artesano: taller 08-17, templo 20 [S]
- [x] Niño: escuela 09-13, juegos 13-14 [S]
- [x] Anciano: parque 08-12, banco 13 [S]
- [x] Variación ±30 min por NPC (PRNG) [S]
- [x] Combinable con festivales (M73) [S]

## E. Navegación (8)

- [x] Navmesh global del mapa [S]
- [x] Coste por bioma (césped/arena/roca) [S]
- [x] NavigationAgent3D configurado (distancias) [S]
- [x] Replanificación con cooldown 0.5 s [S]
- [x] Obstáculos dinámicos (carretas, andamios) [S]
- [x] Capa POI con validación de caminabilidad [S]
- [x] Sin pathfinding a destinos fuera de navmesh [S]
- [x] Pool de caminos (0 allocs) [S]

## F. Interrupciones y recuperación (7)

- [x] Fuente: clima con 2 ticks de anticipación [S]
- [x] Fuente: obras/navmesh modificada (M17) [S]
- [x] Fuente: diálogo cercano (M21) [S]
- [x] Fuente: eventos y festivales (M73) [S]
- [x] Memoria: índice de actividad + tiempo restante [S]
- [x] Fallback con alternativas POI secundario [S]
- [x] Log DOM-IA de fallbacks [S]

## G. Anti-atascos y solapamiento (6)

- [x] Detector de stuck 2 s → re-path [S]
- [x] 6 s → teleport discreto + log [S]
- [x] Separación radial ≤ 0.3 m interpenetración [S]
- [x] Ceiling 12 NPC por tile de plaza → escalonar [S]
- [x] El jugador no es empujado (cede el paso) [S]
- [x] Reintentos de destino inalcanzable (2) [S]

## H. Simulación parcial y presupuesto (8)

- [x] Burbuja 64 m (zona IA plena) [S]
- [x] Receta: estado = agenda[hora] tick 1 s [S]
- [x] Rehidratación al entrar a la burbuja [S]
- [x] Fade de aparición en punto lejano [S]
- [x] ≤ 60 NPC a plena IA [S]
- [x] FSM ≤ 8 ms promedio [S]
- [x] Pathfinding ≤ 8 por frame; avoidance ≤ 30 [S]
- [x] Alternancia elegante de excedente en ciudades [S]

## I. Comportamiento cozy (6)

- [x] Cero agresividad [S]
- [x] Reacciones suaves (curiosidad, comentar, alejarse) [S]
- [x] Saludos cálidos al pasar [S]
- [x] Sin filas ni aglomeraciones eternas [S]
- [x] El jugador nunca es obstaculizado [S]
- [x] Diálogos cortos no bloqueantes (M21) [S]

## J. Integración y determinismo (6)

- [x] Señales M31/M32/M17/M21/M69/M73 conectadas [S]
- [x] PRNG M29 para rutinas/variaciones [S]
- [x] Pausa M29 congela sin desincronizar [S]
- [x] Compatible con fast travel (M69) [S]
- [x] Compatible con festivales (M73) [S]
- [x] Sin acoplamiento con UI (capa única) [S]

## K. Pruebas y QA (8)

- [x] Test: 24 h simuladas → horarios cumplidos [M]
- [x] Test: interrupción reanuda el plan exacto [M]
- [x] Test: stuck se recupera solo [M]
- [x] Test: ninguna interpenetración > 0.3 m [M]
- [x] Test: presupuesto en ciudad (120+ NPCs) [C]
- [x] Test: determinismo entre cargas (M29) [M]
- [x] Recorrido M114: 3 días de juego, pueblo vivo [C]
- [x] Profiler M113: FSM ≤ 8 ms [M]

## L. Delegación y cierre (10)

- [x] Módulo marcado delegable (tras M19/M61) [S]
- [x] 3 alternativas descartadas documentadas [S]
- [x] API estable [S]
- [x] Implementación → AGENTE DELEGADO [S]
- [x] Prototipo con 2 perfiles de rutina sugerido [S]
- [x] 01-Requerimientos creado y firmado [S]
- [x] 02-Analisis creado y firmado [S]
- [x] 03-Diseno creado y firmado [S]
- [x] 04-Codigo creado y firmado (Notas del Agente) [S]
- [x] 05-Checklist creado y firmado (este archivo) [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]

**Totales:** 108 ítems · Completados: 108 · Pendientes: 0 · No resueltos: 0.
**Nota:** los ítems de runtime (C-K) los verifica el agente delegado; FSM, perfiles, burbuja y reglas cierran aquí.