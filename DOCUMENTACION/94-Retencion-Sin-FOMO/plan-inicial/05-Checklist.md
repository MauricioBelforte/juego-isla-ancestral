**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 94: Retención sin FOMO (110 ítems)

## Convención
- `[ ]` = completado por documentación (fase documentada y validable). `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días).

## 1. Principios de diseño (R1-R5)

- [ ] Definir norma R1: 0 streaks (ninguna recompensa por sesiones consecutivas) [S]
- [ ] Definir norma R2: 0 expiración de recompensas/cosméticos por fecha [S]
- [ ] Definir norma R3: 0 penalización por ausencia (el mundo no avanza sin jugar) [S]
- [ ] Definir norma R4: 0 contenido exclusivo temporal (catálogo general único) [S]
- [ ] Definir norma R5: el tiempo real nunca produce pérdida [S]
- [ ] Definir política de diseño documentada (M152) [M]
- [ ] Definir auditor anti-FOMO en CI (detecta violaciones R1-R5) [C]
- [ ] Definir scan manual semestral de mecánicas nuevas [M]

## 2. Objetivos diarios (P1)

- [ ] Definir 2 objetivos diarios rotatorios simultáneos [M]
- [ ] Definir ejemplos base: pesca, entrega, cosecha, exploración [M]
- [ ] Definir recompensa moderada (oro + amistad) [S]
- [ ] Definir reseteo al comenzar el día de juego (M29) [M]
- [ ] Definir objetivo cuya recompensa no se cobró → sobremesa [M]
- [ ] Definir sin avisos presionantes de "último día" [S]
- [ ] Definir objetivos no repetidos idénticos en el mismo plazo [S]

## 3. Objetivos semanales (P2)

- [ ] Definir 2 objetivos semanales rotatorios [M]
- [ ] Definir ejemplos base: encargos de isla, colección de fósiles [M]
- [ ] Definir recompensa mayor (ítem + boost de recolección) [M]
- [ ] Definir reseteo al comenzar la semana de juego [M]
- [ ] Definir sin objetivo semanal obligatorio [S]
- [ ] Definir progreso visible durante la semana (M55) [S]

## 4. Objetivos mensuales (P3)

- [ ] Definir 1-2 objetivos mensuales rotatorios [M]
- [ ] Definir ejemplos base: colecciones por isla, cosechas de estación [M]
- [ ] Definir recompensa de colección (M73) [M]
- [ ] Definir reseteo al comenzar el mes de juego [M]
- [ ] Definir sin pérdida de progreso a mitad de mes [S]

## 5. No castigar ausencias (P4/R3)

- [ ] Definir que cultivos/plantas no mueren por ausentarse [M]
- [ ] Definir que las casas/construcciones no se degradan por ausencia [M]
- [ ] Definir que la amistad no decae sin juego (M20) [M]
- [ ] Definir que los peces/clima no pierden rareza por esperar [M]
- [ ] Definir que el reloj del mundo avanza solo en sesión (M29) [M]
- [ ] Definir que ningún sistema use DateTime.Now para gameplay [M]
- [ ] Definir test de ausencia simulada de 7 días → 0 pérdida [M]

## 6. Sin recompensas obligatorias (P5/R2)

- [ ] Definir que ninguna recompensa exige estar presente en una fecha real [M]
- [ ] Definir que los cosméticos no son exclusivos por evento [M]
- [ ] Definir que los ítems de evento son del catálogo general (M16/M73) [M]
- [ ] Definir que el "sello de fiesta" sea colección acumulable salir [S]
- [ ] Definir aviso de evento como invitación, no conminación [S]

## 7. Completar contenido después (P6)

- [ ] Definir misiones secundarias reintentables/posponibles sin caducidad [M]
- [ ] Definir eventos repetibles con variantes (3+) [M]
- [ ] Definir sobremesa de recompensas vencidas en el diario [M]
- [ ] Definir límite de 50 pendientes; excedente liquidado en oro [S]
- [ ] Definir que el postgame quede disponible hasta completarlo [S]

## 8. Descubrimientos inesperados (P7)

- [ ] Definir eventos aleatorios del mundo (cometas, mareas, migración) [C]
- [ ] Definir ventanas de 1-2 días de juego (no de calendario real) [M]
- [ ] Definir anuncio anticipado en diario [M]
- [ ] Definir repetición del evento si no se participó [S]
- [ ] Definir misterios sin prisa (M22/M148) [S]
- [ ] Definir sin sorpresas que castiguen al ausente [S]

## 9. Eventos repetibles (P8)

- [ ] Definir motor de variantes sobre M74 [C]
- [ ] Definir 3+ variantes por festividad (decorado, encargos, diálogos) [C]
- [ ] Definir ciclo de variante menos vista tras completar todas [M]
- [ ] Definir recompensa por participación acumulada (sello de fiesta) [M]
- [ ] Definir que la festividad siga el día de juego (M29) [M]
- [ ] Definir sin recompensas únicas por primera participación [S]

## 10. Metas de largo plazo (P9)

- [ ] Definir 6 Sellos + Acto 3 como meta sin prisa [M]
- [ ] Definir museo 100% (M37/M73) sin fecha límite [M]
- [ ] Definir ciudad/islas construidas (M17/M68) persistente [M]
- [ ] Definir amistad máxima con 30 NPC sin decaimiento [M]
- [ ] Definir misterios completos abiertos a ritmo propio [S]
- [ ] Definir seguimiento visible de cada meta (M55) [M]

## 11. Colecciones (P10)

- [ ] Definir colecciones 100% completables sin límite temporal (M73) [M]
- [ ] Definir fichas con lore (M148) y sin ventana [M]
- [ ] Definir pistas de coleccionables accesibles siempre (M55) [M]
- [ ] Definir coleccionables no expiran ni se pierden [S]

## 12. Proyectos de construcción (P11)

- [ ] Definir proyectos (invernadero, casas, islas) persistidos [M]
- [ ] Definir que no se reviertan por ausencia [S]
- [ ] Definir progreso por fases visible en diario [M]
- [ ] Definir recursos de construcción sin caducidad [S]

## 13. Relaciones (P12)

- [ ] Definir amistad con hitos de largo plazo (M20) [M]
- [ ] Definir cadenas de misiones de amistad sin prisa [M]
- [ ] Definir regalos del día (catálogo) sin exclusividad [S]
- [ ] Definir sin eventos de amistad "únicos e irrepetibles" [S]

## 14. Misterios (P13)

- [ ] Definir arcos de misterio abiertos sin desesperar [M]
- [ ] Definir pistas de misterios reencontrables (diario/M148) [M]
- [ ] Definir misterio final en postgame (5+ h) [C]
- [ ] Definir que ninguna pista expira [S]

## 15. Postgame (P14)

- [ ] Definir 3 bloques: desafíos, misterio final, isla perfecta [C]
- [ ] Definir desafíos de la isla (pesca legendaria, minero, chef) [M]
- [ ] Definir misterio final de 3-5 h (Elysia + décima ruina) [C]
- [ ] Definir proyecto isla perfecta (ciudadela + población máxima) [C]
- [ ] Definir desbloqueo tras el epílogo (M22) [M]
- [ ] Definir contenido de postgame ≥ 5 h verificado [M]

## 16. Evitar mecánicas para forzar login (P15)

- [ ] Definir prohibición formal de streaks [S]
- [ ] Definir prohibición de contenido exclusivo temporal [S]
- [ ] Definir prohibición de "¡vuelve o lo pierdes!" [S]
- [ ] Definir prohibición de penalización de ausencia [S]
- [ ] Definir auditor de scan en build (falla la build si viola) [M]
- [ ] Definir revisión de nuevas mecánicas contra el manifiesto anti-FOMO [M]

## 17. Tablero y diario (M55)

- [ ] Definir sección Objetivos en el diario [M]
- [ ] Definir sección Sobremesa en el diario (cobrables) [M]
- [ ] Definir contador de pendientes visible [S]
- [ ] Definir notificación suave de objetivo cumplido [S]
- [ ] Definir navegación gamepad del tablero (M57) [M]

## 18. Persistencia (M59)

- [ ] Definir save v3.2 con campo motivación (objetivos, sobremesa, variantes, participaciones) [M]
- [ ] Definir migración v3.1 → v3.2 [M]
- [ ] Definir 30 ciclos de carga/guardado sin pérdida de objetivos [M]
- [ ] Definir sin dependencia de reloj real en persistencia [S]

## 19. Telemetría (M104)

- [ ] Definir métrica "sesiones libres" (sin objetivos vencidos pendientes) [M]
- [ ] Definir métrica "recompensas cobradas pendientes" [M]
- [ ] Definir métrica de retención por voluntad (días jugados) [M]
- [ ] Definir sin telemetría que manipule recompensas [S]
- [ ] Definir reporte de retención sana en informe 72 h (M143) [S]

## 20. Calidad y tests (M112)

- [ ] Definir suite AntiFomoAudit (detección de streaks/expiración) [M]
- [ ] Definir suite Objetivos (rotación, sobremesa, límite 50) [M]
- [ ] Definir suite Ausencia (7 días sin juego → 0 pérdida) [M]
- [ ] Definir suite EventosVariantes (3+ variantes, ciclo) [M]
- [ ] Definir suite RecompensaAcumulada (límite + liquidación) [M]
- [ ] Definir suite Postgame (desbloqueo + 3 bloques) [M]
- [ ] Definir suite MigraciónMotivacion (v3.1→3.2) [M]
- [ ] Definir playtest de 5 usuarios: ¿sienten presión de volver? (M114) [M]
- [ ] Definir documentación plan-actual actualizada y firmada [S]
- [ ] Definir log del módulo en Logs/ [S]

## Totales

**Total de ítems:** 113
**Ítems resueltos por documentación:** 113 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)