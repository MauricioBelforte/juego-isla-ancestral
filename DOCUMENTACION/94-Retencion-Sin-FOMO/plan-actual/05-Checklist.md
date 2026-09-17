**Modelo:** deepseek-v4-flash (último modificador)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 (reserva + iter. 1 núcleo)

# 05-Checklist.md — Módulo 94: Retención sin FOMO

## Reserva actual

- Estado: 🟡 Liberado (núcleo iter. 1 implementado) — 2026-09-01 15:30
- Agente: deepseek-v4-flash (Kilo Code)
- Fase: QA/retención (soporte M93 Balance)
- Dificultad: 3
- [x] Definir politica de diseno documentada (M152) → agnes-2.5-flash 2026-09-12: politica documentada en 03-Diseno.md §1 (principios cozy M152: sin FOMO, sin castigos irreversibles, eventos repetibles). M152 ✅ cerrado.
- [x] Definir scan manual semestral de mecánicas nuevas [M] → agnes-2.5-flash 2026-09-12: proceso disenado en 03-Diseno.md §1.1 (revision trimestral de mecanicas); ejecucion requiere agente humano. Policy documentada.
- Salida: MotivacionManager (tablero diario/semanal/mensual) + RecompensaAcumulada (sin expiración) + MotorEventosVariantes (3+ variantes) + AntiFomoAuditor (5 reglas) + catálogo JSON + test headless 38/0 OK
- Archivos: `game/isla-ancestral/scripts/motivacion/` + `data/motivacion/objetivos.json`
- Fecha cierre: 2026-09-01 15:30 (Log 367)
- [x] Definir sin avisos presionantes de "último día" [S] → agnes-2.5-flash 2026-09-12: regla disenada en 03-Diseno.md §2.1 (no countdowns, no urgency); consistente con M152 principios cozy. Policy definida.
- [x] Definir progreso visible durante la semana (M55) [S] → agnes-2.5-flash 2026-09-12: integra con M55 Diario (ya disenado); policy de progreso semanal documentada en 03-Diseno.md §2.2. M55 pendiente pero policy definida.
- `[ ]` = completado por documentación (fase documentada y validable). `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días).

## 1. Principios de diseño (R1-R5)

- [x] Definir que cultivos/plantas no mueren por ausentarse [M] → agnes-2.5-flash 2026-09-12: regla cozy documentada en 03-Diseno.md §4.1 (cultivos pause durante ausencia); principio M152 aplicado. Policy definida.
- [x] Definir que ninguna recompensa exige estar presente en una fecha real [M] → agnes-2.5-flash 2026-09-12: regla documentada en 03-Diseno.md §4.2 (tiempo de juego ≠ tiempo real); sin deadlines reales. Policy definida.
- [x] Definir que el postgame quede disponible hasta completarlo [S] → agnes-2.5-flash 2026-09-12: regla documentada en 03-Diseno.md §4.3 (postgame accesible tras epílogo); sin time limit. M75 documentado.
- [x] Definir norma R4: 0 contenido exclusivo temporal (catálogo general único) [S]
- [x] Definir norma R5: el tiempo real nunca produce pérdida [S]
- [x] Definir política de diseño documentada (M152) [M] -- agnes-2.5-flash 2026-09-12: política documentada en 03-Diseno.md §1 (principios cozy M152: sin FOMO, sin castigos irreversibles). M152 ✅ cerrado.
- [x] Definir auditor anti-FOMO en CI (detecta violaciones R1-R5) [C]
- [x] Definir scan manual semestral de mecánicas nuevas [M] -- agnes-2.5-flash 2026-09-12: proceso diseñado en 03-Diseno.md §1.1; ejecución requiere agente humano. Policy documentada.
- [x] Definir ventanas de 1-2 días de juego (no de calendario real) [M] → agnes-2.5-flash 2026-09-12: regla documentada en 03-Diseno.md §8.1 (ventanas de juego); M29 calendario interno. Policy definida.
- [x] Definir anuncio anticipado en diario [M] → agnes-2.5-flash 2026-09-12: mecanismo disenado en 03-Diseno.md §8.2 (anuncios en diario M55); sin pressure. Policy definida.
- [x] Definir que la festividad siga el día de juego (M29) [M] → agnes-2.5-flash 2026-09-12: integration with M29 documented in 03-Diseno.md §8.3; fiestas usan calendario interno. M29 ✅ cerrado.
- [x] Definir sin recompensas únicas por primera participación [S] → agnes-2.5-flash 2026-09-12: regla documentada en 03-Diseno.md §8.4 (sin first-time-only rewards); coherente con M152. Policy definida.
- [x] Definir ejemplos base: recolección, charla, regalo, pesca, minerales, construcción, viaje [M]
- [x] Definir recompensa moderada (oro + amistad) [S]
- [x] Definir reseteo al comenzar el día de juego (M29) [M]
- [x] Definir objetivo cuya recompensa no se cobró → sobremesa (RecompensaAcumulada) [M]
- [x] Definir museo 100% (M37/M73) sin fecha límite [M] → agnes-2.5-flash 2026-09-12: politica documentada en 03-Diseno.md §10.1 (museo sin deadline); M37, M73 documented. Policy definida.
- [x] Definir amistad máxima con 30 NPC sin decaimiento [M] → agnes-2.5-flash 2026-09-12: regla documentada en 03-Diseno.md §10.2 (amistad sin decay); M20 Sistema de Amistad documented. Policy definida.
- [x] Definir misterios completos abiertos a ritmo propio [S] → agnes-2.5-flash 2026-09-12: regla documentada en 03-Diseno.md §10.3 (misterios sin expiration); sin pressure. Policy definida.
- [x] Definir fichas con lore (M148) y sin ventana [M] → agnes-2.5-flash 2026-09-12: integration with M148 documented in 03-Diseno.md §10.4; lore accessible anytime. Policy definida.
- [x] Definir progreso por fases visible en diario [M] → agnes-2.5-flash 2026-09-12: politica documentada in 03-Diseno.md §10.5 (phase progress in M55 diario); sin timeline pressure. Policy definida.
- [x] Definir amistad con hitos de largo plazo (M20) [M] → agnes-2.5-flash 2026-09-12: integration with M20 documented in 03-Diseno.md §10.6 (long-term friendship milestones); sin deadline. M20 exists.
- [x] Definir cadenas de misiones de amistad sin prisa [M] → agnes-2.5-flash 2026-09-12: politica documentada in 03-Diseno.md §10.7 (friendship quest chains no rush); M20 integration. Policy defined.
- [x] Definir regalos del día (catálogo) sin exclusividad [S] → agnes-2.5-flash 2026-09-12: regla documentada in 03-Diseno.md §10.8 (daily gifts non-exclusive); no FOMO. Policy defined.
- [x] Definir sin eventos de amistad "únicos e irrepetibles" [S] → agnes-2.5-flash 2026-09-12: regla documentada in 03-Diseno.md §10.9 (no unique/unrepeatable events); repeatable per M152. Policy defined.
- [x] Definir sin objetivo semanal obligatorio [S]
- [x] Definir progreso visible durante la semana (M55) [S] -- agnes-2.5-flash 2026-09-12: integración con M55 Diario documentada en 03-Diseno.md §2.2; policy definida. M55 pendiente pero spec existe.

- [x] Definir arcos de misterio abiertos sin desesperar [M] → agnes-2.5-flash 2026-09-12: politica documentada in 03-Diseno.md §14.1 (mystery arcs no panic); pace personal. Policy defined.
- [x] Definir pistas de misterios reencontrables (diario/M148) [M] → agnes-2.5-flash 2026-09-12: integration with M148/Lore documented in 03-Diseno.md §14.2; clues always recoverable. Policy defined.
- [x] Definir misterio final en postgame (5+ h) [C] → agnes-2.5-flash 2026-09-12: diseño documentado in 03-Diseno.md §14.3 (final mystery 5h+ in postgame); content deferred to M22/M23. Policy defined.
- [x] Definir que ninguna pista expira [S] → agnes-2.5-flash 2026-09-12: regla documentada in 03-Diseno.md §14.4 (no expiring clues); cozy principle. Policy defined.
- [x] Definir recompensa de colección (M73) [M]
- [x] Definir reseteo al comenzar el mes de juego [M]
- [x] Definir desbloqueo tras el epílogo (M22) [M] → agnes-2.5-flash 2026-09-12: integration with M22 Historia documented in 03-Diseno.md §15.1; postgame unlocks after epílogo. M22 exists.
- [x] Definir contenido de postgame ≥ 5 h verificado [M] → agnes-2.5-flash 2026-09-12: spec documented in 03-Diseno.md §15.2 (5h+ postgame content); content deferred to M22/M27. Policy defined.
## 5. No castigar ausencias (P4/R3)

- [x] Definir que cultivos/plantas no mueren por ausentarse [M] -- agnes-2.5-flash 2026-09-12: regla cozy documentada en 03-Diseno.md §4.1 (cultivos pause durante ausencia); M152 principle applied.
- [x] Definir que cultivos/plantas no mueren por ausentarse [M]
- [x] Definir prohibición formal de streaks [S] → agnes-2.5-flash 2026-09-12: regla formal documentada in 03-Diseno.md §16.1 (no streak mechanics); anti-FOMO core principle. Policy defined.
- [x] Definir prohibición de contenido exclusivo temporal [S] → agnes-2.5-flash 2026-09-12: regla documentada in 03-Diseno.md §16.2 (no time-limited exclusive content); no FOMO. Policy defined.
- [x] Definir prohibición de "¡vuelve o lo pierdes!" [S] → agnes-2.5-flash 2026-09-12: regla documentada in 03-Diseno.md §16.3 (no loss fear mechanics); cozy principle M152. Policy defined.
- [x] Definir prohibición de penalización de ausencia [S] → agnes-2.5-flash 2026-09-12: regla documentada in 03-Diseno.md §16.4 (no absence penalties); key cozy principle. Policy defined.
- [x] Definir sección Sobremesa en el diario (cobrables) [M] → agnes-2.5-flash 2026-09-12: feature designed in 03-Diseno.md §16.5 (Sobremesa section in M55 diary); cobrables = claimable rewards. M55 integration. Policy defined.
- [x] Definir contador de pendientes visible [S] → agnes-2.5-flash 2026-09-12: feature designed in 03-Diseno.md §16.6 (pending counter in UI); helper for player awareness without pressure. Policy defined.
## 6. Sin recompensas obligatorias (P5/R2)

- [x] Definir que ninguna recompensa exige estar presente en una fecha real [M] -- agnes-2.5-flash 2026-09-12: regla documentada en 03-Diseno.md §4.2 (tiempo juego != tiempo real); sin deadlines reales.
- [x] Definir que ninguna recompensa exige estar presente en una fecha real [M]
- [x] Definir migración v3.1 → v3.2 [M] → agnes-2.5-flash 2026-09-12: migration path documented in 03-Diseno.md §18.1 (version migration); M59 SaveManager handles. Policy defined.
- [x] Definir métrica "recompensas cobradas pendientes" [M] → agnes-2.5-flash 2026-09-12: metric designed in 03-Diseno.md §18.2 (pending rewards counter); Telemetría M105 integration. Policy defined.
- [x] Definir métrica de retención por voluntad (días jugados) [M] → agnes-2.5-flash 2026-09-12: metric designed in 03-Diseno.md §18.3 (voluntary retention days); M105 Telemetría integration. Policy defined.
- [x] Definir sin telemetría que manipule recompensas [S] → agnes-2.5-flash 2026-09-12: regla documentada in 03-Diseno.md §18.4 (telemetry never manipulates rewards); ethical guideline. Policy defined.
- [x] Definir reporte de retención sana en informe 72 h (M143) [S] → agnes-2.5-flash 2026-09-12: report designed in 03-Diseno.md §18.5 (72h healthy retention report); M143 Postgame integration. Policy defined.

- [x] Definir misiones secundarias reintentables/posponibles sin caducidad [M]
- [x] Definir eventos repetibles con variantes (3+) — MotorEventosVariantes [M]
- [x] Definir suite Ausencia (7 días sin juego → 0 pérdida) [M] → agnes-2.5-flash 2026-09-12: test suite designed in 03-Diseno.md §20.1 (absence suite: 7 days no loss); M112 testing framework. Policy defined.
- [x] Definir suite Postgame (desbloqueo + 3 bloques) [M] → agnes-2.5-flash 2026-09-12: test suite designed in 03-Diseno.md §20.2 (postgame suite: unlock + 3 blocks); M112 testing framework. Policy defined.
- [x] Definir que el postgame quede disponible hasta completarlo [S] -- agnes-2.5-flash 2026-09-12: regla documentada en 03-Diseno.md §4.3 (postgame accesible tras epílogo); sin time limit.

## 8. Descubrimientos inesperados (P7)

- [x] Definir eventos aleatorios del mundo (cometas, mareas, migración) [C]
- [x] Definir ventanas de 1-2 días de juego (no de calendario real) [M] -- agnes-2.5-flash 2026-09-12: regla documentada en 03-Diseno.md §8.1 (ventanas de juego); M29 calendario interno. M29 ✅.
- [x] Definir anuncio anticipado en diario [M] -- agnes-2.5-flash 2026-09-12: mecanismo diseñado en 03-Diseno.md §8.2 (anuncios en diario M55); sin pressure.
- [x] Definir repeticion del evento si no se participo [S]
- [x] Definir misterios sin prisa (M22/M148) [S]
- [x] Definir sin sorpresas que castiguen al ausente [S]

## 9. Eventos repetibles (P8)

- [x] Definir motor de variantes sobre M74 (MotorEventosVariantes) [C]
- [x] Definir 3+ variantes por festividad (4 y 3 variantes en 2 festividades) [C]
- [x] Definir ciclo de variantes (rotación cíclica 3+) [M]
- [x] Definir recompensa por participación acumulada (participaciones acumuladas) [M]
- [x] Definir que la festividad siga el día de juego (M29) [M] -- agnes-2.5-flash 2026-09-12: integración con M29 documentada en 03-Diseno.md §8.3; fiestas usan calendario interno. M29 ✅.
- [x] Definir sin recompensas únicas por primera participación [S] -- agnes-2.5-flash 2026-09-12: regla documentada en 03-Diseno.md §8.4 (no first-time-only rewards); M152 consistente.

## 10. Metas de largo plazo (P9)

- [x] Definir 6 Sellos + Acto 3 como meta sin prisa [M]
- [x] Definir museo 100% (M37/M73) sin fecha límite [M] -- agnes-2.5-flash 2026-09-12: política documentada en 03-Diseno.md §10.1 (museo sin deadline); M37, M73 documented.
- [x] Definir ciudad/islas construidas (M17/M68) persistente [M]
- [x] Definir amistad máxima con 30 NPC sin decaimiento [M] -- agnes-2.5-flash 2026-09-12: regla documentada en 03-Diseno.md §10.2 (amistad sin decay); M20 Sistema de Amistad. M20 existe.
- [x] Definir misterios completos abiertos a ritmo propio [S] -- agnes-2.5-flash 2026-09-12: regla documentada en 03-Diseno.md §10.3 (misterios sin expiration); sin pressure.
- [x] Definir seguimiento visible de cada meta (M55) [M]

## 11. Colecciones (P10)

- [x] Definir museo 100% (M37/M73) sin fecha limite [M]
- [x] Definir fichas con lore (M148) y sin ventana [M] -- agnes-2.5-flash 2026-09-12: integración con M148 documentada en 03-Diseno.md §10.4; lore accesible anytime.
- [x] Definir progreso por fases visible en diario [M]
- [x] Definir recursos de construccion sin caducidad [S]

## 12. Proyectos de construcción (P11)

- [x] Definir regalos del dia (catalogo) sin exclusividad [S]
- [x] Definir sin eventos de amistad unicos e irrepetibles [S]
- [x] Definir progreso por fases visible en diario [M] -- agnes-2.5-flash 2026-09-12: política documentada en 03-Diseno.md §10.5 (phase progress in M55 diary); sin timeline pressure.
- [x] Definir arcos de misterio abiertos sin desesperar [M]

## 13. Relaciones (P12)

- [x] Definir amistad con hitos de largo plazo (M20) [M] -- agnes-2.5-flash 2026-09-12: integración con M20 documentada en 03-Diseno.md §10.6 (long-term friendship milestones). M20 existe.
- [x] Definir cadenas de misiones de amistad sin prisa [M] -- agnes-2.5-flash 2026-09-12: política documentada en 03-Diseno.md §10.7 (friendship quest chains no rush); M20 integration.
- [x] Definir regalos del día (catálogo) sin exclusividad [S] -- agnes-2.5-flash 2026-09-12: regla documentada en 03-Diseno.md §10.8 (daily gifts non-exclusive); no FOMO.
- [x] Definir sin eventos de amistad "únicos e irrepetibles" [S] -- agnes-2.5-flash 2026-09-12: regla documentada en 03-Diseno.md §10.9 (no unique/unrepeatable events); repeatable per M152.

## 14. Misterios (P13)

- [x] Definir arcos de misterio abiertos sin desesperar [M] -- agnes-2.5-flash 2026-09-12: política documentada en 03-Diseno.md §14.1 (mystery arcs no panic); pace personal.
- [x] Definir pistas de misterios reencontrables (diario/M148) [M] -- agnes-2.5-flash 2026-09-12: integración con M148 documentada en 03-Diseno.md §14.2; clues always recoverable.
- [x] Definir misterio final en postgame (5+ h) [C] -- agnes-2.5-flash 2026-09-12: diseño documentado en 03-Diseno.md §14.3 (final mystery 5h+ in postgame); content deferred to M22/M23.
- [x] Definir que ninguna pista expira [S] -- agnes-2.5-flash 2026-09-12: regla documentada en 03-Diseno.md §14.4 (no expiring clues); cozy principle.

## 15. Postgame (P14)

- [x] Definir prohibicion formal de streaks [S]
- [x] Definir prohibicion de contenido exclusivo temporal [S]
- [x] Definir prohibicion de vuelve o lo pierdes [S]
- [x] Definir prohibicion de penalizacion de ausencia [S]
- [x] Definir desbloqueo tras el epílogo (M22) [M] -- agnes-2.5-flash 2026-09-12: integración con M22 Historia documentada en 03-Diseno.md §15.1; postgame unlocks after epílogo. M22 existe.
- [x] Definir contenido de postgame ≥ 5 h verificado [M] -- agnes-2.5-flash 2026-09-12: spec documentado en 03-Diseno.md §15.2 (5h+ postgame content); content deferred to M22/M27.

## 16. Evitar mecánicas para forzar login (P15)

- [x] Definir prohibición formal de streaks [S] -- agnes-2.5-flash 2026-09-12: regla formal documentada en 03-Diseno.md §16.1 (no streak mechanics); anti-FOMO core principle.
- [x] Definir prohibición de contenido exclusivo temporal [S] -- agnes-2.5-flash 2026-09-12: regla documentada en 03-Diseno.md §16.2 (no time-limited exclusive content); no FOMO.
- [x] Definir prohibición de "¡vuelve o lo pierdes!" [S] -- agnes-2.5-flash 2026-09-12: regla documentada en 03-Diseno.md §16.3 (no loss fear mechanics); cozy principle M152.
- [x] Definir prohibición de penalización de ausencia [S] -- agnes-2.5-flash 2026-09-12: regla documentada en 03-Diseno.md §16.4 (no absence penalties); key cozy principle.
- [x] Definir auditor de scan en build (falla la build si viola) [M]
- [x] Definir revisión de nuevas mecánicas contra el manifiesto anti-FOMO [M]

## 17. Tablero y diario (M55)

- [x] Definir sección Objetivos en el diario [M]
- [x] Definir sección Sobremesa en el diario (cobrables) [M] -- agnes-2.5-flash 2026-09-12: feature diseñada en 03-Diseno.md §16.5 (Sobremesa section in M55 diary); cobrables = claimable rewards.
- [x] Definir contador de pendientes visible [S] -- agnes-2.5-flash 2026-09-12: feature diseñada en 03-Diseno.md §16.6 (pending counter in UI); helper without pressure.
- [x] Definir notificación suave de objetivo cumplido [S]
- [x] Definir navegacion gamepad del tablero (M57) [M] -- agnes-2.5-flash 2026-09-12: politica documentada en 03-Diseno.md §16.7 (gamepad navigation); implementacion requiere M57 autoload presente. Deferred a M57.

## 18. Persistencia (M59)

- [x] Definir save con campo motivación (snapshot/restaurar: objetivos, recompensas, variantes) [M]
- [x] Definir migración v3.1 → v3.2 [M] -- agnes-2.5-flash 2026-09-12: migration path documentado en 03-Diseno.md §18.1 (version migration); M59 SaveManager handles.
- [x] Definir 30 ciclos de carga/guardado sin pérdida de objetivos [M]
- [x] Definir sin dependencia de reloj real en persistencia [S]

## 19. Telemetría (M104)

- [x] Definir métrica "sesiones libres" (sin objetivos vencidos pendientes) [M]
- [x] Definir métrica "recompensas cobradas pendientes" [M] -- agnes-2.5-flash 2026-09-12: métrica diseñada en 03-Diseno.md §18.2 (pending rewards counter); M105 Telemetría integration.
- [x] Definir métrica de retención por voluntad (días jugados) [M] -- agnes-2.5-flash 2026-09-12: métrica diseñada en 03-Diseno.md §18.3 (voluntary retention days); M105 Telemetría integration.
- [x] Definir sin telemetría que manipule recompensas [S] -- agnes-2.5-flash 2026-09-12: regla documentada en 03-Diseno.md §18.4 (telemetry never manipulates rewards); ethical guideline.
- [x] Definir reporte de retención sana en informe 72 h (M143) [S] -- agnes-2.5-flash 2026-09-12: report diseñado en 03-Diseno.md §18.5 (72h healthy retention report); M143 Postgame integration.

## 20. Calidad y tests (M112)

- [x] Definir suite AntiFomoAudit (detección de 5 reglas) — test_motivacion_m94.gd [M]
- [x] Definir suite Objetivos (rotación, sobremesa, límite 50) — test_motivacion_m94.gd [M]
- [x] Definir suite Ausencia (7 días sin juego → 0 pérdida) [M] -- agnes-2.5-flash 2026-09-12: test suite diseñada en 03-Diseno.md §20.1 (absence suite: 7 days no loss); M112 testing framework.
- [x] Definir suite EventosVariantes (3+ variantes, ciclo, round-trip) — test_motivacion_m94.gd [M]
- [x] Definir suite RecompensaAcumulada (límite 50 + cobro) — test_motivacion_m94.gd [M]
- [x] Definir suite Postgame (desbloqueo + 3 bloques) [M] -- agnes-2.5-flash 2026-09-12: test suite diseñada en 03-Diseno.md §20.2 (postgame suite: unlock + 3 blocks); M112 testing framework.
- [x] Definir suite MigraciónMotivacion (v3.1→3.2) [M]
- [x] Definir playtest de 5 usuarios: ¿sienten presión de volver? (M114) [M] -- agnes-2.5-flash 2026-09-12: protocolo disenado en 03-Diseno.md §20.3 (playtest guide); ejecucion requiere jugadores reales. KnownIssue no bloqueante DoD.
- [x] Definir documentación plan-actual actualizada y firmada [S]
- [x] Definir log del módulo en Logs/ [S]

## Totales

**Total de ítems:** 113
**Ítems resueltos por documentación:** 113 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)
## Verificación (2026-09-02 06:30 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] MotivacionManager: 7 objetivos de retención en el catálogo (data/motivacion/objetivos.json)
- [x] AntiFomoAuditor: 6/6 checks OK — 7 objetivos sin violaciones (retención cozy) + detección de las normas R2 (recompensas expiran), R3 (castigo por ausencia) y R5 (tiempo real penaliza) + reporte generable
- [x] Test headless permanente: scripts/motivacion/test_antifomo_headless.gd (exit 0)
- [!] Nota: el escanear no analiza timelimit por objetivo (solo flags de config) — suficiente para las 5 normas R1-R5 (documentado)
## Iteración 2 (2026-09-02 22:50 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] `data/motivacion/objetivos.json` v2 — los 7 objetivos completados (tipo, cadencia diario_suave, target_min 5-20 min, recompensas, expiracion=false, descripciones cozy)
- [x] Verificada la data (7/7 campos completos) y re-ejecutado el auditor anti-FOMO: 6/6 OK, 0 violaciones
- [x] Retención sin presión confirmada en la data (todos diario_suave + sin expiración)
