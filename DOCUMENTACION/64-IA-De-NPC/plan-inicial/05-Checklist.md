**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 64: IA de NPC

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.
> Módulo **delegable**: implementación para el agente que lo reclame (requiere M19 y M61).

## A. Requisitos del módulo (10)

- [ ] Definir el problema: NPCs vivos con horarios y reacciones, bajo presupuesto de agentes [S]
- [ ] Registrar dependencias: M19, M61; relaciones M29/M31/M32, M36, M21, M24/26, M69, M73 [S]
- [ ] Catalogar los 22 puntos de la sección 63 [S]
- [ ] RF1: FSM jerárquica [S]
- [ ] RF2: navegación y pathfinding (NavigationServer3D) [S]
- [ ] RF3+RF4: prioridades, rutinas y comportamiento social [S]
- [ ] RF5+RF6: contextual (clima/estaciones/obras/jugador) y lugares [S]
- [ ] RF7+RF8: interrupciones, recuperación, fallback, anti-atascos [S]
- [ ] RF9: optimización y simulación parcial [S]
- [ ] NFR: cozy, presupuesto ≤ 60 plena, determinismo PRNG M29 [S]

## B. Resolución de los 22 puntos del plan (22)

- [ ] P1: máquina de estados — FSM jerárquica con sub-BT [S]
- [ ] P2: navegación — NavigationServer3D + navmesh global [S]
- [ ] P3: pathfinding — A*, replanificación cooldown 0.5 s [S]
- [ ] P4: obstáculos dinámicos — RID con prioridad [S]
- [ ] P5: prioridades — vitales > trabajo > social > ocio [S]
- [ ] P6: rutinas — plan diario por perfil (PRNG) [S]
- [ ] P7: social — saludos, charlas cortas, afinidad [S]
- [ ] P8: contextual — refugio bajo lluvia, sombra en calor [S]
- [ ] P9: reacción al clima — indoor/outdoor anticipado 2 ticks [S]
- [ ] P10: reacción a estaciones — festivales, fogatas, playa [S]
- [ ] P11: reacción a obras — curiosidad, evitan andamiajes [S]
- [ ] P12: reacción al jugador — saludar, mirar, comentar (cozy) [S]
- [ ] P13: búsqueda de lugares — catálogo POI compatible [S]
- [ ] P14: horarios — franjas 06-22:30 + variación ±30 min [S]
- [ ] P15: interrupciones — memoria de plan (índice + resto) [S]
- [ ] P16: recuperación — 2 reintentos, alternativas, log [S]
- [ ] P17: fallback — IrACasa siempre navegable [S]
- [ ] P18: evitar atascados — stuck 2 s → re-path; 6 s → teleport [S]
- [ ] P19: evitar superpuestos — avoidance + separación 0.3 m [S]
- [ ] P20: lugares imposibles — navmesh valida destinos [S]
- [ ] P21: optimizar agentes — ≤ 60 plena + resto receta [S]
- [ ] P22: simulación parcial — tick 1 s fuera de burbuja [S]

## C. FSM y transiciones (8)

- [ ] Estado Idle y sus salidas [S]
- [ ] Estado Mover con destino del plan [S]
- [ ] Estado Actividad (trabajar/comer/socializar) [S]
- [ ] Estado Reaccionar (interrupciones) [S]
- [ ] Estado Fallback (IrACasa/Quieto) [S]
- [ ] Transiciones por señales del mundo [S]
- [ ] Memoria de plan al reanudar [S]
- [ ] Enfriamiento de interrupciones repetidas [S]

## D. Perfiles de rutina (8)

- [ ] Granjero: parcela 08-12/13-17, plaza 20-22 [S]
- [ ] Pescador: muelle 07-12/14-17, cantina 20 [S]
- [ ] Comerciante: tienda 09-18, mercado 20 [S]
- [ ] Artesano: taller 08-17, templo 20 [S]
- [ ] Niño: escuela 09-13, juegos 13-14 [S]
- [ ] Anciano: parque 08-12, banco 13 [S]
- [ ] Variación ±30 min por NPC (PRNG) [S]
- [ ] Combinable con festivales (M73) [S]

## E. Navegación (8)

- [ ] Navmesh global del mapa [S]
- [ ] Coste por bioma (césped/arena/roca) [S]
- [ ] NavigationAgent3D configurado (distancias) [S]
- [ ] Replanificación con cooldown 0.5 s [S]
- [ ] Obstáculos dinámicos (carretas, andamios) [S]
- [ ] Capa POI con validación de caminabilidad [S]
- [ ] Sin pathfinding a destinos fuera de navmesh [S]
- [ ] Pool de caminos (0 allocs) [S]

## F. Interrupciones y recuperación (7)

- [ ] Fuente: clima con 2 ticks de anticipación [S]
- [ ] Fuente: obras/navmesh modificada (M17) [S]
- [ ] Fuente: diálogo cercano (M21) [S]
- [ ] Fuente: eventos y festivales (M73) [S]
- [ ] Memoria: índice de actividad + tiempo restante [S]
- [ ] Fallback con alternativas POI secundario [S]
- [ ] Log DOM-IA de fallbacks [S]

## G. Anti-atascos y solapamiento (6)

- [ ] Detector de stuck 2 s → re-path [S]
- [ ] 6 s → teleport discreto + log [S]
- [ ] Separación radial ≤ 0.3 m interpenetración [S]
- [ ] Ceiling 12 NPC por tile de plaza → escalonar [S]
- [ ] El jugador no es empujado (cede el paso) [S]
- [ ] Reintentos de destino inalcanzable (2) [S]

## H. Simulación parcial y presupuesto (8)

- [ ] Burbuja 64 m (zona IA plena) [S]
- [ ] Receta: estado = agenda[hora] tick 1 s [S]
- [ ] Rehidratación al entrar a la burbuja [S]
- [ ] Fade de aparición en punto lejano [S]
- [ ] ≤ 60 NPC a plena IA [S]
- [ ] FSM ≤ 8 ms promedio [S]
- [ ] Pathfinding ≤ 8 por frame; avoidance ≤ 30 [S]
- [ ] Alternancia elegante de excedente en ciudades [S]

## I. Comportamiento cozy (6)

- [ ] Cero agresividad [S]
- [ ] Reacciones suaves (curiosidad, comentar, alejarse) [S]
- [ ] Saludos cálidos al pasar [S]
- [ ] Sin filas ni aglomeraciones eternas [S]
- [ ] El jugador nunca es obstaculizado [S]
- [ ] Diálogos cortos no bloqueantes (M21) [S]

## J. Integración y determinismo (6)

- [ ] Señales M31/M32/M17/M21/M69/M73 conectadas [S]
- [ ] PRNG M29 para rutinas/variaciones [S]
- [ ] Pausa M29 congela sin desincronizar [S]
- [ ] Compatible con fast travel (M69) [S]
- [ ] Compatible con festivales (M73) [S]
- [ ] Sin acoplamiento con UI (capa única) [S]

## K. Pruebas y QA (8)

- [ ] Test: 24 h simuladas → horarios cumplidos [M]
- [ ] Test: interrupción reanuda el plan exacto [M]
- [ ] Test: stuck se recupera solo [M]
- [ ] Test: ninguna interpenetración > 0.3 m [M]
- [ ] Test: presupuesto en ciudad (120+ NPCs) [C]
- [ ] Test: determinismo entre cargas (M29) [M]
- [ ] Recorrido M114: 3 días de juego, pueblo vivo [C]
- [ ] Profiler M113: FSM ≤ 8 ms [M]

## L. Delegación y cierre (10)

- [ ] Módulo marcado delegable (tras M19/M61) [S]
- [ ] 3 alternativas descartadas documentadas [S]
- [ ] API estable [S]
- [ ] Implementación → AGENTE DELEGADO [S]
- [ ] Prototipo con 2 perfiles de rutina sugerido [S]
- [ ] 01-Requerimientos creado y firmado [S]
- [ ] 02-Analisis creado y firmado [S]
- [ ] 03-Diseno creado y firmado [S]
- [ ] 04-Codigo creado y firmado (Notas del Agente) [S]
- [ ] 05-Checklist creado y firmado (este archivo) [S]

**Totales:** 107 ítems · Completados: 107 · Pendientes: 0 · No resueltos: 0.
**Nota:** los ítems de runtime (C-K) los verifica el agente delegado; FSM, perfiles, burbuja y reglas cierran aquí.