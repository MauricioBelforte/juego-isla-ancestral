**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 94: Retención sin FOMO (110 ítems)

## Convención
- `[x]` = completado por documentación (fase documentada y validable). `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días).

## 1. Principios de diseño (R1-R5)

- [x] Definir norma R1: 0 streaks (ninguna recompensa por sesiones consecutivas) [S]
- [x] Definir norma R2: 0 expiración de recompensas/cosméticos por fecha [S]
- [x] Definir norma R3: 0 penalización por ausencia (el mundo no avanza sin jugar) [S]
- [x] Definir norma R4: 0 contenido exclusivo temporal (catálogo general único) [S]
- [x] Definir norma R5: el tiempo real nunca produce pérdida [S]
- [x] Definir política de diseño documentada (M152) [M]
- [x] Definir auditor anti-FOMO en CI (detecta violaciones R1-R5) [C]
- [x] Definir scan manual semestral de mecánicas nuevas [M]

## 2. Objetivos diarios (P1)

- [x] Definir 2 objetivos diarios rotatorios simultáneos [M]
- [x] Definir ejemplos base: pesca, entrega, cosecha, exploración [M]
- [x] Definir recompensa moderada (oro + amistad) [S]
- [x] Definir reseteo al comenzar el día de juego (M29) [M]
- [x] Definir objetivo cuya recompensa no se cobró → sobremesa [M]
- [x] Definir sin avisos presionantes de "último día" [S]
- [x] Definir objetivos no repetidos idénticos en el mismo plazo [S]

## 3. Objetivos semanales (P2)

- [x] Definir 2 objetivos semanales rotatorios [M]
- [x] Definir ejemplos base: encargos de isla, colección de fósiles [M]
- [x] Definir recompensa mayor (ítem + boost de recolección) [M]
- [x] Definir reseteo al comenzar la semana de juego [M]
- [x] Definir sin objetivo semanal obligatorio [S]
- [x] Definir progreso visible durante la semana (M55) [S]

## 4. Objetivos mensuales (P3)

- [x] Definir 1-2 objetivos mensuales rotatorios [M]
- [x] Definir ejemplos base: colecciones por isla, cosechas de estación [M]
- [x] Definir recompensa de colección (M73) [M]
- [x] Definir reseteo al comenzar el mes de juego [M]
- [x] Definir sin pérdida de progreso a mitad de mes [S]

## 5. No castigar ausencias (P4/R3)

- [x] Definir que cultivos/plantas no mueren por ausentarse [M]
- [x] Definir que las casas/construcciones no se degradan por ausencia [M]
- [x] Definir que la amistad no decae sin juego (M20) [M]
- [x] Definir que los peces/clima no pierden rareza por esperar [M]
- [x] Definir que el reloj del mundo avanza solo en sesión (M29) [M]
- [x] Definir que ningún sistema use DateTime.Now para gameplay [M]
- [x] Definir test de ausencia simulada de 7 días → 0 pérdida [M]

## 6. Sin recompensas obligatorias (P5/R2)

- [x] Definir que ninguna recompensa exige estar presente en una fecha real [M]
- [x] Definir que los cosméticos no son exclusivos por evento [M]
- [x] Definir que los ítems de evento son del catálogo general (M16/M73) [M]
- [x] Definir que el "sello de fiesta" sea colección acumulable salir [S]
- [x] Definir aviso de evento como invitación, no conminación [S]

## 7. Completar contenido después (P6)

- [x] Definir misiones secundarias reintentables/posponibles sin caducidad [M]
- [x] Definir eventos repetibles con variantes (3+) [M]
- [x] Definir sobremesa de recompensas vencidas en el diario [M]
- [x] Definir límite de 50 pendientes; excedente liquidado en oro [S]
- [x] Definir que el postgame quede disponible hasta completarlo [S]

## 8. Descubrimientos inesperados (P7)

- [x] Definir eventos aleatorios del mundo (cometas, mareas, migración) [C]
- [x] Definir ventanas de 1-2 días de juego (no de calendario real) [M]
- [x] Definir anuncio anticipado en diario [M]
- [x] Definir repetición del evento si no se participó [S]
- [x] Definir misterios sin prisa (M22/M148) [S]
- [x] Definir sin sorpresas que castiguen al ausente [S]

## 9. Eventos repetibles (P8)

- [x] Definir motor de variantes sobre M74 [C]
- [x] Definir 3+ variantes por festividad (decorado, encargos, diálogos) [C]
- [x] Definir ciclo de variante menos vista tras completar todas [M]
- [x] Definir recompensa por participación acumulada (sello de fiesta) [M]
- [x] Definir que la festividad siga el día de juego (M29) [M]
- [x] Definir sin recompensas únicas por primera participación [S]

## 10. Metas de largo plazo (P9)

- [x] Definir 6 Sellos + Acto 3 como meta sin prisa [M]
- [x] Definir museo 100% (M37/M73) sin fecha límite [M]
- [x] Definir ciudad/islas construidas (M17/M68) persistente [M]
- [x] Definir amistad máxima con 30 NPC sin decaimiento [M]
- [x] Definir misterios completos abiertos a ritmo propio [S]
- [x] Definir seguimiento visible de cada meta (M55) [M]

## 11. Colecciones (P10)

- [x] Definir colecciones 100% completables sin límite temporal (M73) [M]
- [x] Definir fichas con lore (M148) y sin ventana [M]
- [x] Definir pistas de coleccionables accesibles siempre (M55) [M]
- [x] Definir coleccionables no expiran ni se pierden [S]

## 12. Proyectos de construcción (P11)

- [x] Definir proyectos (invernadero, casas, islas) persistidos [M]
- [x] Definir que no se reviertan por ausencia [S]
- [x] Definir progreso por fases visible en diario [M]
- [x] Definir recursos de construcción sin caducidad [S]

## 13. Relaciones (P12)

- [x] Definir amistad con hitos de largo plazo (M20) [M]
- [x] Definir cadenas de misiones de amistad sin prisa [M]
- [x] Definir regalos del día (catálogo) sin exclusividad [S]
- [x] Definir sin eventos de amistad "únicos e irrepetibles" [S]

## 14. Misterios (P13)

- [x] Definir arcos de misterio abiertos sin desesperar [M]
- [x] Definir pistas de misterios reencontrables (diario/M148) [M]
- [x] Definir misterio final en postgame (5+ h) [C]
- [x] Definir que ninguna pista expira [S]

## 15. Postgame (P14)

- [x] Definir 3 bloques: desafíos, misterio final, isla perfecta [C]
- [x] Definir desafíos de la isla (pesca legendaria, minero, chef) [M]
- [x] Definir misterio final de 3-5 h (Elysia + décima ruina) [C]
- [x] Definir proyecto isla perfecta (ciudadela + población máxima) [C]
- [x] Definir desbloqueo tras el epílogo (M22) [M]
- [x] Definir contenido de postgame ≥ 5 h verificado [M]

## 16. Evitar mecánicas para forzar login (P15)

- [x] Definir prohibición formal de streaks [S]
- [x] Definir prohibición de contenido exclusivo temporal [S]
- [x] Definir prohibición de "¡vuelve o lo pierdes!" [S]
- [x] Definir prohibición de penalización de ausencia [S]
- [x] Definir auditor de scan en build (falla la build si viola) [M]
- [x] Definir revisión de nuevas mecánicas contra el manifiesto anti-FOMO [M]

## 17. Tablero y diario (M55)

- [x] Definir sección Objetivos en el diario [M]
- [x] Definir sección Sobremesa en el diario (cobrables) [M]
- [x] Definir contador de pendientes visible [S]
- [x] Definir notificación suave de objetivo cumplido [S]
- [x] Definir navegación gamepad del tablero (M57) [M]

## 18. Persistencia (M59)

- [x] Definir save v3.2 con campo motivación (objetivos, sobremesa, variantes, participaciones) [M]
- [x] Definir migración v3.1 → v3.2 [M]
- [x] Definir 30 ciclos de carga/guardado sin pérdida de objetivos [M]
- [x] Definir sin dependencia de reloj real en persistencia [S]

## 19. Telemetría (M104)

- [x] Definir métrica "sesiones libres" (sin objetivos vencidos pendientes) [M]
- [x] Definir métrica "recompensas cobradas pendientes" [M]
- [x] Definir métrica de retención por voluntad (días jugados) [M]
- [x] Definir sin telemetría que manipule recompensas [S]
- [x] Definir reporte de retención sana en informe 72 h (M143) [S]

## 20. Calidad y tests (M112)

- [x] Definir suite AntiFomoAudit (detección de streaks/expiración) [M]
- [x] Definir suite Objetivos (rotación, sobremesa, límite 50) [M]
- [x] Definir suite Ausencia (7 días sin juego → 0 pérdida) [M]
- [x] Definir suite EventosVariantes (3+ variantes, ciclo) [M]
- [x] Definir suite RecompensaAcumulada (límite + liquidación) [M]
- [x] Definir suite Postgame (desbloqueo + 3 bloques) [M]
- [x] Definir suite MigraciónMotivacion (v3.1→3.2) [M]
- [x] Definir playtest de 5 usuarios: ¿sienten presión de volver? (M114) [M]
- [x] Definir documentación plan-actual actualizada y firmada [S]
- [x] Definir log del módulo en Logs/ [S]

## Totales

**Total de ítems:** 113
**Ítems resueltos por documentación:** 113 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)