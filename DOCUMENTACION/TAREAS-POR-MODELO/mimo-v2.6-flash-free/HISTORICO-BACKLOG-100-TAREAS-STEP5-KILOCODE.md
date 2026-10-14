# BACKLOG 100 TAREAS PARA STEP-5-KILOCODE — Investigación para mañana

**Modelo:** atria-dawn-s3 (estratega del director)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-13 15:38:00
**Origen:** orden del fundador (15:37): *"planea de antemano 100 tareas para cada modelo ... evitamos
el colapso ... anotalas en tu carpeta por modelos. ling y kimi no"* (relegados)

## Perfil de Step-5-KILOCODE (§21.21)

Ejecución técnica impecable, el más rápido de la flota. Demostró auditoría honesta (Log 1807:
M139, 2 inflados degradados de 92 `[x]` revisados). Su nicho: **módulos técnicos con `[?]` que
requieren verificación con grep + evidencia en disco**, y cierres velocos.

## Reparto (disjunto con los otros 6 backlogs)

Módulos asignados a Kilo: técnicos con deuda `[?]` + técnicos puros que WorkBuddy no cubre +
cierres rápidos. **Sin solapamiento** con WorkBuddy (81 módulos propios de él), agnes (visuales),
DeepSeek (documentales), Hy3 (auditoría narrativa), s2 (QA), atria (deep work).

## LAS 100 TAREAS

Bloques de 5-10 ítems (su ritmo: cierra módulos pequeños en minutos, auditó 7 hitos en una tanda):

### 🔵 EN CURSO (asignado por el director, msg 499/498)

**M139-Pre-Alpha** (🟡, Alta, complejidad 5, dep. 138 — antes de Hy4, 🟡 huérfano). **10/142 → 13/142.**

- **Lote 1 CERRADO (22:06, commit `a7b72e6`, aceptado msg 498 del director):** sección 1
  Aritectura. 3 promovidos con artefactos reales — interfaces `scripts/interfaces/i_tienda.gd`,
  `i_templo.gd`, `i_viajable.gd` (patrón default neutro de `IInteractable` v2); flujo de sesión
  doc. sección 7.3 de `04-Codigo.md`; modo degradación si un servicio falla (M66) sección 7.4.
  **1 ítem quedó `[ ]` honesto:** `SesionMaster` (`scripts/core/sesion_master.gd`) creado con la
  máquina de estados completa, pero su activación como autoload queda pendiente de validación
  runtime (hoy arranca con `main_island.tscn` + ~20 autoloads, no hay master activo).
- **Lote 2 CERRADO (23:20, msg 289): sección 2 — Primer bioma Aurora (M10/M09/M27). 10 → 22/142.**
  Aceptado por el director (msg 290). Depende de la arquitectura del lote 1.
- **Lote 3 CERRADO (23:07, msg 303): sección 3 — Enclave de Coral. 22 → 28/142** (commit `6d0d896`).
  3 promovidos con respaldo documental (03-Diseno §2.2) + **3 con contenido nuevo que escribió**:
  NPC Bram el enano vidriero (11 líneas de diálogo, §2.3.1), stock de la tienda glasswork (6 items,
  enclave = fuente única, M39), hit H11 "Coral completado".
- **Autocrítica valiosa (msg 303):** su primer commit `5b17836` absorbió trabajo staged ajeno (9
  archivos: BACKLOG de WorkBuddy, Log 1831, mensajes, rename de atria-dawn) — `git commit` sin
  pathspec comitea todo el index. Corregido con `git reset --soft HEAD~1` + recommit con pathspec.
  **Lección del repo: NUNCA commitear sin pathspec en el `commit` (no solo en el `add`), y verificar
  `git status` antes.**
- **Lote 4 CERRADO (23:16, msg 305): sección 4 — Primeros NPC (M19/M64). 28 → 43/142 (+15).**
- **Lote 5 CERRADO (23:25, msg 307): sección 5. 43 → 53/142 (+10).**
- **Lote 6 CERRADO (23:34, msg 309): sección 6. 53 → 65/142 (+12).**
- **Lote 7 CERRADO (23:42, msg 310): sección 7. 65 → 78/142 (+13).**
- **Lote 9 CERRADO (00:05, msg 315): sección 9. 88 → 98/142 (+10).**
- **Lote 10 CERRADO (00:14, msg 316): sección 10. 98 → 109/142 (+11).** Aceptado (msg 317).
- **ERROR DEL DIRECTOR DETECTADO (01:32, msg 322):** le pidió "sección 12 (ciclo día/noche + clima,
  M31/M32/M29)" pero **esa sección no existe** — la 12 real es "Métricas y rendimiento"
  (M61/M62/M63/M104/M105, 9 `[ ]`); el ciclo día/noche y el clima son ítems de la sección 2 **ya
  trabajados**. step-5 propuso A (sección 12 real, 9 ítems) → B (sección 13 Cierre de fase GONOGO,
  10 ítems) = las 2 secciones que faltan para 142/142. **Quedó IDLE esperando la decisión** — le
  mandé recordatorio al director (msg 210, recomiendo A+B). Es el 2do error de asignación de
  sección que step-5 le detecta; el propone que le indiques el **número de sección del checklist**
  y él verifica antes de arrancar.
- **✅ M139 CERRADO (02:21, msg 327): 10 → 133/142, 12 secciones.** Director (msg 328): "✅ Completado
  por step-5-kilocode — no definitivo hasta QA cruzado (§21.8)". Los 7 `[ ]` restantes son deuda real
  documentada (ninguno inflado); los 2 `[?]` preexistentes correctamente degradados. **QA pendiente
  — mi candidato: s2 (verificador final, sin trabajo desde las 20:10).**
- **DECISIÓN DEL DIRECTOR (02:01, msg 326): "autorizo A y B"** — mi recomendación del msg 210
  seguida. step-5 cerró M139: sección A (Métricas y rendimiento) + B (Cierre de fase GONOGO).
- **Informes recreados (msgs 291-294, 23:40-00:00):** los 4 informes de cierre borrados en la
  corrección de numeración fueron **recreados desde los Logs 1819/1821/1823/1824** con numeración
  291-294 y nota de recreación. Aceptados por el director (msg 496: "4 informes OK, seguir M139").
  Mi recomendación del msg 202 punto 2 → **COMPLETADO**.
- ~~**Cola del director: M05-Lenguaje**~~ — **M05 YA NO ES DE STEP-5**: el director se lo reasignó a
  DeepSeek (msg 500, 22:42). (Avisé al director en msg 206.)
- **NUEVA ASIGNACIÓN DEL DIRECTOR (02:39, msg 330): M140-Alpha.** Continuación directa de M139
  (Fase 9, antes Hy4 — uno de los 6 módulos finales huérfanos). **14/124**, sección por sección,
  respaldo en disco → flip → commit con pathspec. step-5 lleva el contexto fresco (6 riesgos
  residuales + 2 verificaciones Play Mode de M139).
- **M140 sección 1 CERRADA (02:46, msg 331): 14 → 26/124 (+12).** Ritmo: 12 ítems en 7 min.
- **M140 sección 2 CERRADA (02:54, msg 332): 26 → 35/124 (+9).** Aceptada (msg 333).
- **M140 sección 3 CERRADA (03:04, msg 334): 35 → 43/124 (+8).** Aceptada (msg 335).
- **M140 sección 4 CERRADA (03:14, msg 336): 43 → 53/124 (+10).**
- **M140 sección 5 CERRADA (03:27, msg 338): 53 → 58/124 (+5).**
- **M140 sección 7 CERRADA (03:51, msg 341): 64 → 73/124 (+9).**
- **M140 sección 8 CERRADA (04:03, msg 343): 73 → 77/124 (+4).**
- **M140 sección 9 CERRADA (04:14, msg 345): 77 → 81/124 (+4).**
- **M140 sección 10 CERRADA (04:23, msg 347): 81 → 88/124 (+7).**
- **M140 sección 11 CERRADA (04:35, msg 349): 88 → 92/124 (+4).**
- **M140 CERRADO (04:56, msg 351): 14 → 100/124 (+86).** 13 secciones, respaldo real, 24 [ ] = deuda documentada ( contenido no construido ). Aceptado por el director (msg 352).
- **M137-Prototipo ASIGNADO por el director (msg 352, 04:59)** — 10/131. ⚠️ Hy3 tiene diseño/doc en M137 (Patrón D): step-5 solo implementación/verificación.
- **M137 sección A AUDITADA (05:06, msg 353): 1 [x] inflado degradado; 0/5 con respaldo real.**
- **M137 BARRIDO COMPLETO (05:26, msg 355): mapa de 26 secciones A-Z, 9 [x] auditables (0 más inflados), 122 [ ] = implementación que no existe.** Hy3 confirma (msg 206): Patrón D, 0 promovibles, Totales corregido 9/122.
- **DECISIÓN DEL DIRECTOR (05:28, msg 356): M137 = documentación de referencia (NO construir; competiría con M141-Beta).** step-5 degrada 2 [x] inflados y busca módulo nuevo de su backlog.

### ⏸ EN ESPERA — ronda 2 pre-armada (msg 196) — NO reenviar hasta que M139/M05 se despejen

M31-Ciclo-Dia-Noche (49 `[?]`) · M12-Camara (45) · M71-Progresion (45) · M162-Dialogos (40).
**Superada por la asignación de M139** (mi msg 202 llegó tarde — corrección enviada en msg 203).

### ✅ M27-Islas-Del-Mundo — COMPLETADO por Kilo (17:19, Log 1819)

**Cerrado:** 127 `[x]` / 0 `[ ]` / 65 `[?]` = 192 ítems. **1 promoción** (isla flotante sin
océano, respaldo sólido en `island_definition.gd` L74 + test dedicado), 65 anotados con evidencia
(archivo + línea + grep en cada uno). Commits `337b5f2` + `f9e7d2a`. Auto-corrección de un
desplazamiento en el bloque 4 detectada y arreglada ANTES de commitear. Pendiente el flip del
director en GLOBAL (127/192, 65 `[?]`).

⚠️ **INSIGHT DE COORDINACIÓN (importante para futuros encargos):** M27 es un módulo de DEFINICIÓN
con deuda de INTEGRACIÓN. Los 65 `[?]` no son inflación — son **contratos delegados** a otros
módulos donde el dato existe en M27 pero el consumidor no: M10 (anclas/regen), M28 (viaje/UI),
M29 (calendario), M32 (clima), M36 (fauna), M41 (música), M50 (vegetación), M54 (mapa), M59
(persistencia), M61 (presupuesto), M63 (streaming). Además hay **cables con un solo extremo**:
`marcar_visitada()` (0 llamadores), `descubrir()` (0 consumidores en producción), `esta_desbloqueada()`
(el viaje no la consulta al atracar). **Cuando WorkBuddy/agnes/DeepSeek trabajen esos módulos,
podrán resolver deuda de M27** — vale la pena cruzar este aviso en sus encargos.
### ✅ M74-Eventos — COMPLETADO por Kilo (17:32, Log 1821)

**Cerrado:** 227 `[x]` / 0 `[ ]` / 58 `[?]` = 285 ítems. 1 promoción (M154-Visión del Agente, V2
operativa), 58 anotados con evidencia. Commit `b9ba71e`. Pendiente flip del director en GLOBAL
(227/285, 58 `[?]`).

⚠️ **Hallazgo de integración — recompensas ROTAS en producción** (mismo patrón que M27):
`recompensa_def.gd` entrega por duck-typing contra `/root` pero los 3 destinos solo existen en
tests: **M20** `fs.sumar_puntos()` (cae a warning, no entrega), **M71**
`registrar_progreso_evento()` (hook dormido), **M37** `museo.registrar_recuerdo()` (hook dormido).
**Cruce:** M20 es de DeepSeek, M71/M37 de Kilo/agnes — al trabajarlos, crear las API faltantes
saldra la deuda de M74 de paso.
10. M74-Eventos b3 — 10
11. M74-Eventos b4 — 10
12. M74-Eventos b5 — 10
13. M74-Eventos b6 (cierre) — 9
### ✅ M34-Pesca — COMPLETADO por Kilo (17:43, Log 1823)

**Cerrado:** 99 `[x]` / 0 `[ ]` / 54 `[?]` = 153. **0 promociones** (los 54 `[?]` tienen dueño
externo), 54 anotados con evidencia. Commit `fdea098`. Kilo corrigió la línea Totales (decía 84/69,
residuo de iter 2 → 99/54 real). Pendiente flip del director (99/153, 54 `[?]`).

**3 stubs REALES de M34** (deuda propia, accionable — implementable, no depende de otros):
`es_agua_pescable()` retorna `true` siempre (falta voxel AGUA / aire / orilla BFS);
`spot_apunta_desde()` ignora `_rango`/`_direccion`; marcador visual sin ondulaciones. **Candidatos
para cola de implementación de WorkBuddy o atria.**
### ✅ M11-Personaje — COMPLETADO por Kilo (17:53, Log 1824) — CIERRA el encargo 185

72 `[x]` / 0 `[ ]` / 51 `[?]` = 123. 0 promociones, 51 anotados. Commit `89de8d8`. Flagueó 3 ítems
desactualizados del checklist (correr 6.5 m/s SÍ en `player_core_m11.gd` L50; InteractionService
4 m existe vía M70 `DEFAULT_RANGO=2.5`+1.5 testeado).

**ACTUALIZACIÓN encargo 197 (21:01, msg 201 + 285):** Kilo cerró las 3 tareas del director —
(1) mojibake en `houses/` reparado (2 archivos, 6+3 marcadores, 0 restantes) commit `ebd13ba`;
(2) los 3 ítems desactualizados de M11 **reescritos con cita y promovidos a `[x]`** → **M11 72→75/123**
commit `0e0f521`; (3) deuda duck-typing de M74 documentada en `04-Codigo.md` sección 5 con dueños
(M20/M71/M37) commit `863fb5b`.

### ✅✅ BALANCE FINAL DEL ENCARGO 185 (45 min): 230 `[?]` auditados, 2 promos, 5 commits

M27 127/192 (65[?]) · M74 227/285 (58[?]) · M34 99/153 (54[?]) · M11 **75/123 (48[?])** — 3 promos
extra del encargo 197. **4 flips pendientes del director.** Lección: re-verificar el canal de Kilo antes de cada reenvío (cierra
módulos en ~10 min; las correcciones 189 y 195 llegaron obsoletas por minutos).

24. M94-Retencion-Sin-FOMO b1 (51 `[?]` — 48 duplicados detectados) — 10
25. M94-Retencion-Sin-FOMO b2 — 10
26. M94-Retencion-Sin-FOMO b3 — 10
27. M94-Retencion-Sin-FOMO b4 — 10
28. M94-Retencion-Sin-FOMO b5 (cierre) — 11
29. M31-Ciclo-Dia-Noche b1 (49 `[?]`) — 10
30. M31-Ciclo-Dia-Noche b2 — 10
31. M31-Ciclo-Dia-Noche b3 — 10
32. M31-Ciclo-Dia-Noche b4 — 10
33. M31-Ciclo-Dia-Noche b5 (cierre) — 9
34. M12-Camara b1 (45 `[?]`) — 10
35. M12-Camara b2 — 10
36. M12-Camara b3 — 10
37. M12-Camara b4 (cierre) — 15
38. M71-Progresion b1 (45 `[?]`) — 10
39. M71-Progresion b2 — 10
40. M71-Progresion b3 — 10
41. M71-Progresion b4 (cierre) — 15
42. M162-Dialogos-Contextuales-De-NPCs b1 (40 `[?]`) — 10
43. M162-Dialogos-Contextuales-De-NPCs b2 — 10
44. M162-Dialogos-Contextuales-De-NPCs b3 — 10
45. M162-Dialogos-Contextuales-De-NPCs b4 (cierre) — 10
46. M105-Telemetria-De-Gameplay b1 (33 `[?]`) — 10
47. M105-Telemetria-De-Gameplay b2 — 10
48. M105-Telemetria-De-Gameplay b3 (cierre) — 13
49. M115-Hardware b1 (26 `[?]`) — 13
50. M115-Hardware b2 (cierre) — 13
51. M124-Contenido-Generado-Por-Usuarios (25 `[?]`) — 13
52. M124-UGC b2 (cierre) — 12
53. M127-Copyright-Del-Juego b1 (24 `[?]`) — 12
54. M127-Copyright b2 (cierre) — 12
55. M117-Build-System (18 `[?]`) — 9
56. M117-Build-System b2 (cierre) — 9
57. M64-IA-De-NPC (17 `[?]`) — 9
58. M64-IA-De-NPC b2 (cierre) — 8
59. M25-Ruinas (16 `[?]`) — 8
60. M25-Ruinas b2 (cierre) — 8
61. M10-Generacion-Del-Mundo (16 `[?]`) — 8
62. M10-Generacion b2 (cierre) — 8
63. M45-Arte-3D b1 (19 `[ ]` restantes tras los 130 flips aceptados) — 10
64. M45-Arte-3D b2 (cierre) — 9
65. M145-Diseno-De-Experiencia (15 `[?]`) — 15
66. M99-Marketing (14 `[ ]`) — 14
67. M106-Seguridad (12 `[?]`) — 12
68. M104-Analytics (4 `[ ]` + 8 `[?]`) — 12
69. M88-Fuentes-Tipograficas (11 `[?]`) — 11
70. M160-Diseno-De-Ubicaciones (3 `[ ]` + 7 `[?]`) — 10
71. M122-Crash-Reporting (10 `[?]`) — 10
72. M119-Actualizaciones (9 `[ ]`) — 9
73. M131-Creditos (9 `[ ]`) — 9
74. M107-Backups (9 `[?]`) — 9
75. M146-Diseno-Emocional (9 `[?]`) — 9
76. M129-Merchandising (7 `[?]`) — 7
77. M153-Objetivo-Final (7 `[ ]`) — 7
78. M03-Documentacion-Del-Proyecto (7 `[?]`) — 7
79. M103-Logging (6 `[?]`) — 6
80. M154-Vision-Del-Agente (3 `[ ]` + 3 `[?]`) — 6
81. M09-Terreno-Y-Geografia (5 `[?]`) — 5
82. M82-Clasificacion-Por-Edades (5 `[?]`) — 5
83. M44-ASMR-Y-Feedback (5 `[?]`) — 5
84. M87-Localizacion (5 `[?]`) — 5
85. M14-Inventario (4 `[?]`) — 4
86. M150-Diseno-Sonoro-Narrativo (4 `[?]`) — 4
87. M164-Isla-De-Combate-Endgame (4 `[?]`) — 4
88. M155-Vestimenta-Y-Accesorios (3 `[?]`) — 3
89. M29-Tiempo-Y-Calendario (3 `[?]`) — 3
90. M47-Texturas-Y-Materiales (3 `[?]`) — 3
91. M24-Templos-Y-Puzzles (1 `[ ]` + 1 `[?]` — DoD revocado, cuidado) — 2
92. M83-Licencias-De-Software (1 `[ ]` + 1 `[?]`) — 2
93. M80-Legal-Privacidad (2 `[?]`) — 2
94. M81-Legal-Menores (2 `[?]`) — 2
95. M123-Modding (2 `[?]`) — 2
96. M118-CI-CD (1 `[ ]`) — 1
97. M06-Control-De-Versiones (1 `[ ]`) — 1
98. M65-Animales-IA (1 `[ ]`) — 1
99. M36-Fauna (2 `[ ]`) — 2
100. M167-Isla-Raiz (1 `[ ]` — ⚠️ leer `DOCUMENTACION/167-Isla-Raiz/` antes) — 1

## Reglas para Kilo

1. Su especialidad: verificar `[?]` con **grep + artifact en disco** antes de promover. Si no hay
   evidencia, dejar `[?]` con explicación (como hizo en Log 1807).
2. **Nunca promover `[?]`→`[x]` sin cita real** (regla Patrón D que también aplica a él).
3. **M45 ya fue flipeado por el director** (✅→🟡, 16:52 — drift real confirmado). Los 19 `[ ]`
   restantes son deuda abierta: promover SOLO con evidencia nueva. **M105/M117 son deuda
   legítima** (ya 🟡, con dueño: s2 Log 1502 / hy3 Log 947) — no son drift, auditarlos como deuda
   normal.
4. M27/M74/M34/M11/M94/M31/M12/M71/M162 son puros `[?]` — auditar en bloques de 10, reportar
   conteo regex antes/después.

## Entrega al director

10 mensajes de 10 tareas. Mensaje 1-7: los bloques grandes (M27, M74, M34, M11, M94). Mensaje 8-9:
M31, M12, M71, M162, M105, M115. Mensaje 10: cierres rápidos (tareas 66-100).

**Firma:** atria-dawn-s3 (Atria-Dawn-Preview / Kilo Code) — 2026-10-13 15:38:00
