# METODOLOGIA V2 (directiva del fundador 2026-10-17) — COMO USAR ESTE ARCHIVO

**Modelo mantenimiento:** GLM-5.3-Flash-Director (GLM-5.3-Flash) / Kilo Code
**Fecha de alta:** 2026-10-17

Este archivo es TU backlog de tareas, y lo mantiene ACTUALIZADO el DIRECTOR (GLM-5.3-Flash-Director) en TU carpeta de canal. Ya no resides en DOCUMENTACION/TAREAS-POR-MODELO/GLM-5.3-Flash-Director/.

## Tu ciclo como agente (en este orden):

1. **PRIMERA INSTANCIA:** lee si el director te escribio un mensaje en tu canal (Mensajes entre modelos/Hy3/). Si hay mensaje dirigido a ti, RESPONDELO primero (numeracion de hilo: ultimo + 1; borra SOLO ese numero del pool NUMEROS_DISPONIBLES.txt de tu carpeta — pools NO se commitean).
2. **SEGUNDA INSTANCIA:** si NO hay mensajes del director, toma el proximo item [ ] de ESTE backlog que puedas hacer segun tu nicho (GUIA-COMPARATIVA DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md). Trabaja una TANDA de tareas (las que elijas).
3. **CIERRE DE TANDA:** al terminar tu tanda, escribe un REPORTE en tu canal al director: que tasks cerraste (ids), evidencia (archivos/tenets/tests), y actualiza las marcas [ ]->[x] de las que completaste (marca solo lo verificable en disco, honestidad del protocolo).
4. El director actualizara este backlog, llevara la fila de CHECKLIST-GLOBAL.md y te respondera.

## Reglas que NO cambian:

- Reserva de modulo (§21.3 azules) en CHECKLIST-GLOBAL + ESTADO-PARALELO + 05-Checklist antes de tocar modulos.
- Numeracion de mensajes por hilo (ultimo + 1) con pool por canal. Pools gitignoreados.
- UTF-8 estricto (apendice 28), firmas de documento, logs de cierre en Logs/ (tareas de cierre formal).
- Independencia de modelo en QA (§21.8/21.23).
- NO delegues ni edites el backlog de OTRO modelo ni la carpeta de OTRO agente.

---

# BACKLOG 100+ TAREAS PARA HY3 (WorkBuddy) — Investigación previa por GLM-5.3-Flash

**Modelo:** GLM-5.3-Flash (encargo del fundador 2026-10-16)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-16 00:00
**Nicho del modelo** (GUIA-COMPARATIVA §5.D + nota 2026-09-04): **QA cruzado §21.8** (regla del proyecto: Hy3 siempre debe verificar), validación entre modelos, diálogos/narrativa (M21 DialogGraphValidator), y **verificación en runtime de fixes de lógica** (Godot headless `--script` instanciando managers; no QA visual).
**Autoridad:** CANDIDATOS para el director/fundador — nada se arranca sin encargo o reclamo §21.3. Conteos estimados a validar contra `05-Checklist.md` al reclamar.

## Reglas del reparto

- QA §21.8: verificador ≠ autor del módulo (§21.23: nunca verificar módulos cerrados por DeepSeek V4.1-Flash ↔ De-Director V4.1, misma familia de modelo).
- Muestreo obligatorio §21.8.2.b: mín. 5 `[x]` por verbos de creación, grep contra disco, coincidencia de conteos (checklist ↔ Totales ↔ GLOBAL).
- Un módulo por agente a la vez; 3 lugares al cerrar + reporte al director.

## LAS 100+ TAREAS

### Registro de delegaciones (mantenido por GLM-5.3-Flash — ultima pasada 2026-10-16 02:25)

- **M09-Terreno → DELEGADO por el director (canal Hy3 msg 223, 2026-10-15 23:00: M164 b3.2 + H148 bajan, siguiente M09).** Tarea 1 en vuelo de Hy3 — no re-clamar.
- **M164-Combate-Endgame (tarea 102) → cierres b3.2 confirmados por el director (mismo msg 223).**

### Bloque A — QA cruzado de módulos ✅ con sello viejo o pendiente (prioridad §21.8)

1. M09-Terreno (100/105): QA cruzado completo (último sello atria 2026-09-18; muestreo 5+) — 10 [M]
2. M10-Generación (88/106): QA de degradaciones 2026-10-15 (L26/L52) y del BUG-043 snow — 10 [M]
3. M103-Logging (173/179): QA del estado 🟡 (6 [?], suites 131/0) — 8 [M]
4. M105-Telemetría (129/162): QA del estado 🟡 tras corrección del director (33 [?]) — 10 [M]
5. M104-Analytics (107/119): QA de los 26 flips de agnes A3 — 8 [M]
6. M62-Memoria (113/150): QA de delta iter.6 (L98, pureza_save 58/0) — 8 [M]
7. M108-Pipeline (127/205): QA de los lotes cerrados — 10 [M]
8. M107-Backups (167/176): QA de cierre — 8 [M]
9. M112-Testing (211/225): QA de los 211 [x] — 10 [M]
10. M118-CI/CD (105/106): QA del pipeline quality.yml (4 suites cableadas) — 6 [M]
11. M117-Build (92/110): QA del sistema de builds — 8 [M]
12. M110-Debug (150/225): QA del lote de paneles — 8 [M]
13. M91-Config-Audio (212/239): QA de los avances de step-5-kilocode (232 archivos) — 10 [M]
14. M90-Config-Grafica (149/249): QA del estado — 8 [M]
15. M40-Infraestructura (175/211): QA del lote cerrado — 8 [M]
16. M64-IA-NPC (102/119): QA runtime del pathfinding actual — 8 [M]
17. M74-Eventos (227/285): QA del scheduler — 8 [M]
18. M71-Progresión (168/213): QA de lotes XP — 8 [M]
19. M66-Anti-Softlock (110/117): QA del sistema (7 pendientes) — 8 [M]
20. M72-Logros (77/185): QA de lo hecho — 8 [M]
21. M87-Localización (131/136): QA de claves y de la deuda i18n de Ling (112 claves) — 8 [M]
22. M97-Steam (195/195): QA de refresco — 6 [S]
23. M98-Trailer (102/102): QA de refresco — 4 [S]
24. M100-Community (220/220): QA de faq.json/reglas — 6 [S]
25. M152-Principios (202/202): QA de refresco — 4 [S]
26. M167-Isla-Raiz (113/114): QA de la configuración fija (CENTRO 2560, radio, spawn) — 6 [M]
27. M168-Plantilla (104/104): QA de la plantilla — 6 [S]
28. M166-Perf variedades (112/112): QA — 6 [S]
29. M85-Modelos-3D-Legal (95/0): verificación de conteo anómalo 95/0 — 4 [S]
30. M86-IA-Generativa (129/129): QA de refresco — 4 [S]
31. M84-Legal-Audio (99/99) — QA — 4 [S]
32. M78/M79/M80/M81/M82/M83 (legal, ✅ o 1-2 pendientes): QA rotativo — 10 [S]

### Bloque B — Diálogos y narrativa (nicho fuerte)

33. M21-Dialogos (82/143): 61 pendientes → lote 1 (graph/nodos DialogGraphValidator) — 10 [C]
34. M21 b2: continuar (aur_00XX adicionales) — 10 [C]
35. M21 b3: cierre con tests de selección/contexto — 8 [C]
36. M162-Diálogos-Contextuales-NPCs (81/120): 39 pendientes → ContextualDialogueManager — 10 [C]
37. M162 b2: reglas contextuales día/noche/lluvia — 10 [C]
38. M162 b3: cierre headless — 8 [C]
39. M20-Amistad (50/148): 98 pendientes → lote de lógica de amistad — 10 [C]
40. M20 b2: reglas de regalo/consideración — 10 [C]
41. M20 b3: cierre — 8 [C]
42. M23-Historias-Secundarias (24/104): 80 pendientes → diseño de 5 historias + triggers — 10 [C]
43. M23 b2: implementación de 5 historias (instanciar quest managers) — 10 [C]
44. M23 b3: cierre con tests — 8 [C]
45. M22-Historia-Principal (✅): QA de integración con M31/M162 — 4 [S]
46. M147-World-Building (65/134): 69 pendientes → lore factible con texto — 10 [M]
47. M147 b2: continuación + coherencia con M148 — 10 [M]
48. M143-La01 Lore (148, 115/117): 2 pendientes — 3 [S]
49. M162×M19: QA de coherencia diálogos ↔ vecinos — 8 [M]
50. M65/M36 (✅): QA de integración fauna/animales — 4 [S]

### Bloque C — Verificación runtime headless (especialidad única de Hy3)

51. Suite de smoke de managers core (bootstrap/eventbus/registries) — 10 [C]
52. Runtime test de M59-Guardado: guardar/cargar ciclo con datos reales — 10 [C]
53. Runtime test de M60-Datos: serialización round-trip completa — 10 [C]
54. Runtime test de M74: disparo de eventos programados — 10 [C]
55. Runtime test de M71: flujo XP/recompensa — 10 [C]
56. Runtime test de M20: ciclo completo de amistad (levels/regalos) — 10 [C]
57. Runtime test de M21/M162: selección contextual por hora/clima — 10 [C]
58. Runtime test de M16-Crafting: recetas end-to-end — 10 [C]
59. Runtime test de M33-Agricultura: plantar/crecer/cosechar (ciclo de días) — 10 [C]
60. Runtime test de M34-Pesca: fase de captura sintética — 10 [C]
61. Runtime test de M35-Minería: nodo/corazón/drops — 10 [C]
62. Runtime test de M28-Viajes: ruta/fast-travel gating — 10 [C]
63. Runtime test de M29/M30/M31: reloj → calendario → ciclo día/noche encadenados — 10 [C]
64. Runtime test del IMPUESTOR de M09 (elige cota por AABB) — 8 [C]
65. Runtime test de regeneración de chunks M10 (AABB invalidation) — 10 [C]
66. Runtime test de M66: escenarios anti-softlock seeded — 10 [C]
67. Runtime test de M64: navegación NPC obstáculos — 10 [C]
68. Runtime test de persistencia de M73 (coleccionables) — 8 [C]
69. Runtime test de M72 (logros unlock) — 8 [C]
70. Consolidación de un suite maestro de smoke (quality.yml wiring) — 10 [C]

### Bloque D — Verificaciones cruzadas pedidas por el director (cola)

71-80. Lotes de QA §21.8.X a módulo único (10 módulos a elegir por el director de la lista 🔵→✅ del día) — 10 [M]
81-88. Verificaciones de flips dudas (cualquier agente que reporte flips → re-verificación Hy3) — 10 [M]
89. Auditoría de l Logging de la flota (logs nuevos del día: presencia de evidencia) — 8 [M]
90. Verificación backlogs vs. checklists (`scripts/verificar_backlogs.py` semanal) — 6 [M]
91. Verificación de los 5 BACKLOG archivos de glm (coherencia con GLOBAL) — 6 [S]
92. Verificación de PATRÓN D en reportes de Step 5 (conteos y muestreos) — 8 [M]
93. Verificación de reportes de agnes cuando hay flips en disputa (lección de msg 2027) — 8 [M]
94. Verificación de s-*-canal (mensajes sin cuerpo a los 5 min) — 4 [S]
95. Verificación de scripts/ nuevos de terceros (test_scripts.py antes de producción) — 6 [M]
96. Re-QA de M100/M97/M98 rotativo mensual — 8 [M]
97. M151-Control-Final (94/167): QA de la sección de control de calidad — 8 [M]
98. M153-Objetivo-Final (123/130): QA del cierre — 6 [M]
99. M154-Vision (149/155): QA del estado de las vías V1-V5 — 6 [M]
100. M160-Ubicaciones (145/155): QA de las 155 — 6 [M]
101. M163-Encantamientos (98/120): QA de lo hecho — 8 [M]
102. M164-Combate-Endgame (125/129): QA — 6 [M]
103. M155-Vestimenta (105/108): QA — 4 [S]
104. M158-Desbloqueos (53/140): QA del lote — 6 [M]
105. Diagnóstico del archivo de mensajes nuevo del canal (módulos citados sin evidencia) — 4 [S]

---
**Total: 105 ítems.** Mantenimiento continuo por GLM-5.3-Flash (cron 5 min).

**Firma:** GLM-5.3-Flash / Kilo Code — 2026-10-16

======================================================================
### Bloque W — Repo 2026-10-16 noche (+12 verificación runtime por módulo)
1. QA §21.8 de las iteraciones del theme D102 (el ahorro del dark — la fila de los 8 colores).
2. Verificación runtime de los 22 eventos de M74 (los festival_*_nombre del boot).
3. Verificación runtime del canon M147 (6 personajes, 8 lugares — WorldBible 1.0.0).
4. Verificación runtime de M160 (39 catálogos, 48 ubicaciones, 13 islas).
5. Verificación runtime de M75 (7 actividades postgame, activo=false).
6. Verificación runtime de M95 (3 ediciones, 2 DLC).
7. Verificación runtime de M129 (10 productos merch).
8. Verificación runtime de M73 (15 items 4 categorías).
9. Verificación runtime de M158 (4 tiers 6 gates 4 forjas 4 cursos).
10. Verificación runtime de M156 (7 terrenos).
11. Verificación runtime de M64 (7 especies fauna, 13 individuos).
12. QA §21.8 de las iteraciones M29/M30/M32 de DS-Opencode (fam. distinta — puede auditarte).

**Estado:** repo de la jornada 2026-10-16 noche (la rama 3b del cron: «agregar nuevas, 100+ siempre»).

**Firma:** GLM-5.3 Flash-Director (GLM-5.3-Flash) / Kilo Code — 2026-10-16 noche

======================================================================
### Bloque W2 — Repo 21:59 (+2 para superar 100 items)
1. QA §21.8 del pack_atlas.gd de agnes (scripts/arte2d — el front del M46 lote final).
2. QA §21.8 del strings_pt.json de Ling (144 cadenas — el estándar de integridad del 142/147).

**Estado:** el re-base de 21:59 del 2026-10-16 (orden del fundador: «el de ling lo tenes que ahora esta activo» + «mantener todos los backlogs con 100 tareas disponibles para delegar») — estos ítems son ADICIONALES a los originales y al repuesto noche.

**Firma:** GLM-5.3 Flash-Director (GLM-5.3-Flash) / Kilo Code — 2026-10-16 21:59