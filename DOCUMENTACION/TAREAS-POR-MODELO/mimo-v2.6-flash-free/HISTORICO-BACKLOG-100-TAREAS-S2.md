# BACKLOG 100 TAREAS PARA ATRIA-DAWN-S2 — Investigación para mañana

**Modelo:** atria-dawn-s3 (estratega del director)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-13 15:44:00
**Origen:** orden del fundador (15:37): *"planea de antemano 100 tareas para cada modelo ... ling y
kimi no"* (relegados)

## Perfil de ATRIA-DAWN-S2 (§30.1, §21.21)

**VERIFICADOR FINAL** — última verificación antes de que el director (mimo) selle. Cadena canónica:
**Step 5 ejecuta → s2 verifica → el director sella** (§30.2 regla 6). Su firma: Lotes de QA con
muestreo anti-inflación §21.8.2.b, sin inflación detectada en los suyos (Lotes 351/352:
M29/M52/M34/M45/M105/M04/M39, Logs 1804/1808). Dueño de `tools/mcp`.

## Estructura del backlog

s2 no implementa: **verifica lo que otros ejecutan**. Sus 100 tareas son verificaciones encadenadas
a los backlogs de los 4 ejecutores + contra-verificación independiente de las propuestas de QA de
Hy3 (anti-colusión §21.8: Hy3 propone, s2 contra-verifica una muestra antes del sello del director).

## LAS 100 TAREAS

### Lote 353 pendiente + verificación cola WorkBuddy (1-10)

1. Lote 353 (propuesto msg 182, aún sin asignar) — verificar cola actual y ejecutar
2. Verif. M28-Viajes cuando WorkBuddy cierre (80 `[ ]`) — muestreo 5 `[x]`
3. Verif. M158-Herramientas-Y-Desbloqueo-De-Zonas (87 `[ ]`)
4. Verif. M108-Pipeline-De-Assets (83 `[ ]`)
5. Verif. M147-World-Building (69 `[ ]`)
6. Verif. M21-Dialogos (61 `[ ]`)
7. Verif. M33-Agricultura (47 `[ ]`)
8. Verif. M18-Casas (35 `[ ]`)
9. Verif. M13-Herramientas (36 `[ ]`)
10. Verif. M40-Infraestructura (36 `[ ]`)

### Verificación de cierres de agnes (11-25)

11. Verif. M49-Iluminacion b1-2 (38 `[?]`) — evidencia de shaders/materiales
12. Verif. M49-Iluminacion b3-4 (cierre)
13. Verif. M50-Vegetacion (15) — assets en disco
14. Verif. M148-Lore-Ambiental b1-3 (51 `[ ]`)
15. Verif. M148-Lore b4-5 (cierre)
16. Verif. M46-Arte-2D b1-3 [C-WB]
17. Verif. M46-Arte-2D b4-6 [C-WB]
18. Verif. M46-Arte-2D b7-9 [C-WB]
19. Verif. M46-Arte-2D b10-11 (cierre) [C-WB]
20. Verif. M56-Fotografia b1-4 [C-WB]
21. Verif. M56-Fotografia b5-8 [C-WB]
22. Verif. M56-Fotografia b9-11 (cierre) [C-WB]
23. Verif. M37-Museos + M41-Musica + M42-Sonido-Ambiental (lote audio/museo) [C-WB]
24. Verif. M91-Configuracion-Audio + M51-Agua + M161-Diseno-Visual-NPCs [C-WB]
25. Verif. M54-Mapa + M85-Modelos-3D-Legal + M68-Transporte + M55-Diario [C-WB]

### Verificación de cierres de DeepSeek (26-40)

26. Verif. M02-Vision-Y-Concepto (21, exclusivo DeepSeek) — cita real
27. Verif. M01-Fundamentos b1-3 (131 `[ ]`)
28. Verif. M01-Fundamentos b4-6
29. Verif. M01-Fundamentos b7-9
30. Verif. M01-Fundamentos b10-13 (cierre)
31. Verif. M05-Lenguaje-Y-Programacion b1-5 (99 `[ ]`)
32. Verif. M05-Lenguaje b6-10 (cierre)
33. Verif. M20-Sistema-De-Amistad (98 `[ ]`)
34. Verif. M95-Monetizacion (94 `[ ]`)
35. Verif. M73-Coleccionables b1-5 (109 `[ ]`)
36. Verif. M73-Coleccionables b6-10 (cierre)
37. Verif. M72-Sistema-De-Logros b1-5 (108 `[ ]`)
38. Verif. M72-Logros b6-10 (cierre)
39. Verif. M109-Herramientas-Internas b1-5 (111 `[ ]`)
40. Verif. M67-Vehiculos + M75-Postgame (225 `[ ]` combinados, muestreo 5+5)

### Verificación de cierres de step-5-kilocode (41-60)

41. Verif. M27-Islas-Del-Mundo b1-2 (66 `[?]`)
42. Verif. M27-Islas b3-4
43. Verif. M27-Islas b5-7 (cierre)
44. Verif. M74-Eventos b1-3 (59 `[?]`)
45. Verif. M74-Eventos b4-6 (cierre)
46. Verif. M34-Pesca b1-3 (54 `[?]`)
47. Verif. M34-Pesca b4-5 (cierre)
48. Verif. M11-Personaje-Del-Jugador b1-3 (51 `[?]`)
49. Verif. M11-Personaje b4-5 (cierre)
50. Verif. M94-Retencion-Sin-FOMO b1-3 (51 `[?]`, 48 duplicados)
51. Verif. M94-Retencion b4-5 (cierre)
52. Verif. M31-Ciclo-Dia-Noche (49 `[?]`)
53. Verif. M12-Camara (45 `[?]`)
54. Verif. M71-Progresion (45 `[?]`)
55. Verif. M162-Dialogos-Contextuales-De-NPCs (40 `[?]`)
56. Verif. M105-Telemetria + M115-Hardware (59 combinados)
57. Verif. M124-UGC + M127-Copyright (49 combinados)
58. Verif. M117-Build-System + M64-IA-De-NPC + M25-Ruinas + M10-Generacion (67 combinados)
59. Verif. M45-Arte-3D (19 `[ ]` remanentes) + M145-Diseno-Experiencia (15 `[?]`)
60. Verif. lote cierres rápidos Kilo (M122, M119, M131, M107, M146, M129, M153, M03, M103, M154)

### Contra-verificación independiente de QA de Hy3 (61-85)

Hy3 auditará 70+ módulos ✅ sin sello (ver su backlog). s2 **contra-verifica una muestra** de las
propuestas de Hy3 antes de que el director selle — anti-colusión §21.8 (Hy3 propone, s2 verifica):

61. Contra-verif. drift M45/M105/M117 (Hy3 tareas 1-3) — confirmar ✅→🟡 con propio conteo regex
62. Contra-verif. M126-Marketing-Legal (Hy3 tarea 4) — Test-Path del archivo en disputa
63. Contra-verif. M167-Isla-Raiz (Hy3 tarea 5) — grep 0 hardcodes de centro viejo
64. Contra-verif. QA Hy3 M04/M05/M06/M07/M08 (muestra 3 de 5)
65. Contra-verif. QA Hy3 M09/M10/M62/M101/M102 (muestra 3 de 5)
66. Contra-verif. QA Hy3 M103/M106/M110/M111/M113 (muestra 3 de 5)
67. Contra-verif. QA Hy3 M116/M118/M119/M120/M121 (muestra 3 de 5)
68. Contra-verif. QA Hy3 M122/M123/M124/M125/M128 (muestra 3 de 5)
69. Contra-verif. QA Hy3 M130/M132/M133/M134/M135 (muestra 3 de 5)
70. Contra-verif. QA Hy3 M136/M14/M15/M152/M165 (muestra 3 de 5)
71. Contra-verif. QA Hy3 M166/M168/M24/M29/M30 (muestra 3 de 5)
72. Contra-verif. QA Hy3 M32/M34/M36/M38/M39 (muestra 3 de 5)
73. Contra-verif. QA Hy3 M43/M44/M54/M56/M59 (muestra 3 de 5)
74. Contra-verif. QA Hy3 M60/M63/M64/M65/M70 (muestra 3 de 5)
75. Contra-verif. QA Hy3 M78/M79/M80/M81/M82 (muestra 3 de 5)
76. Contra-verif. QA Hy3 M84/M85/M86/M88/M89 (muestra 3 de 5)
77. Contra-verif. QA Hy3 M91/M93/M97/M98/M99 (muestra 3 de 5)
78. Contra-verif. auditoría deuda Hy3 M159/M63/M112 (muestra de sus propuestas de promoción)
79. Contra-verif. auditoría deuda Hy3 M163/M35/M16/M26 (muestra)
80. Contra-verif. auditoría deuda Hy3 M61/M151/M104/M66/M154 (muestra)
81. Contra-verif. barrido anti-inflación final Hy3 (tarea 100) — reproducir el re-conteo global
82. Verif. Lote 354 (cualquier cierre nuevo que llegue durante el día)
83. Verif. Lote 355 (cierre nuevo)
84. Verif. Lote 356 (cierre nuevo)
85. Verif. Lote 357 (cierre nuevo)

### Verificación de deep work de atria + cierre (86-100)

86. Verif. M164-Isla-De-Combate-Endgame (deep work atria, 4 `[?]`)
87. Verif. M9-Terreno-Y-Geografia (5 `[?]`) — si atria lo toma
88. Verif. M156 (deep work atria, pendiente de su sesión)
89. Verif. M24-Templos-Y-Puzzles (DoD revocado — verificar las 2 unidades antes de cualquier sello)
90. Verif. commit M45+M105 (ruteado a atria, msg 256) — diff review antes de push
91. Verif. renombre de identidad step-5-kilocode (en curso) — consistencia de firmas
92. Verif. 12 colisiones de numeración (2 no borrables restantes, msg 275)
93. Verif. pools de numeración: `python scripts/verificar_pool_numeros.py`
94. Verif. sincronización backlogs: `python scripts/verificar_backlogs.py`
95. Verif. consistencia global: `python scripts/verificar_checklist.py`
96. Verif. salud encoding: `python scripts/diagnosticar_mojibake.py` (debe salir 0)
97. Verif. suite de scripts: `python scripts/test_scripts.py` (8 PASS, 0 FAIL)
98. Verif. Godot headless: 0 errores en `get_debug_output` tras los cierres del día
99. Verif. final del día: re-conteo regex global completo + reporte de drift al director
100. Reporte de cierre del día al director (todos los sellos otorgados/denegados, en su canal)

## Reglas para s2

1. **Independencia absoluta:** no verificar módulos que él completó (M45/M105/M04/M39 fueron
   sellados por él en Lotes 352 — si vuelven a abrirse por drift, Hy3 los audita).
2. **Evidencia en cada veredicto:** comando + salida literal + antes/después, como en Log 1808.
3. **Nunca sellar:** el sello es del director. s2 da veredicto fundamentado y el director decide.
4. **Anti-colusión Hy3:** la contra-verificación (tareas 61-81) es su aporte único — sin ella, el
   QA de Hy3 sería autocertificación.

## Entrega al director

10 mensajes de 10, **alineados con las entregas de los ejecutores** (s2 verifica después de que
cada uno cierre). Msg 1: Lote 353 + cola WorkBuddy. Msg 2-3: agnes. Msg 4-5: DeepSeek. Msg 6-8:
Kilo. Msg 9: contra-verificación Hy3. Msg 10: deep work atria + salud del proyecto.

**Firma:** atria-dawn-s3 (Atria-Dawn-Preview / Kilo Code) — 2026-10-13 15:44:00
