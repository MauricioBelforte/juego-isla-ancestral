# METODOLOGIA V2 (directiva del fundador 2026-10-17) — COMO USAR ESTE ARCHIVO

**Modelo mantenimiento:** GLM-5.3-Flash-Director (GLM-5.3-Flash) / Kilo Code
**Fecha de alta:** 2026-10-17

Este archivo es TU backlog de tareas, y lo mantiene ACTUALIZADO el DIRECTOR (GLM-5.3-Flash-Director) en TU carpeta de canal. Ya no resides en DOCUMENTACION/TAREAS-POR-MODELO/GLM-5.3-Flash-Director/.

## Tu ciclo como agente (en este orden):

1. **PRIMERA INSTANCIA:** lee si el director te escribio un mensaje en tu canal (Mensajes entre modelos/DeepSeek-V4.1-Flash/). Si hay mensaje dirigido a ti, RESPONDELO primero (numeracion de hilo: ultimo + 1; borra SOLO ese numero del pool NUMEROS_DISPONIBLES.txt de tu carpeta — pools NO se commitean).
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

# BACKLOG 100+ TAREAS PARA DEEPSEEK-V4.1-FLASH (WorkBuddy) — Investigación previa por GLM-5.3-Flash

**Modelo:** GLM-5.3-Flash (encargo del fundador 2026-10-16)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-16 00:00
**Nicho del modelo** (GUIA-COMPARATIVA §5.B3 — TB 2.1 90.6 #1, DeepSWE 74.2, coding agentic/terminal + visión nativa, 1M contexto): coding agentic largo, infraestructura, CI/CD, telemetría, logging, serialización, herramientas, i18n, integración multi-sistema. ⚠️ No confundir con el director `De-Director V4.1` (mismo modelo, rol distinto — §31 AGENTS; ninguno verifica/sella módulos del otro).
**Autoridad:** CANDIDATOS para el director/fundador — nada se arranca sin encargo o reclamo §21.3 en los 4 registros. Conteos estimados a validar contra `05-Checklist.md` al reclamar.

## Reglas del reparto (anti-pisado §17/§21.4)

- Confirmar en CHECKLIST-GLOBAL + ESTADO-PARALELO que el módulo no esté 🔵/🔴 de otro.
- Un módulo por agente a la vez; cerrar marcando 3 lugares + reporte al director (REGLA CERO).

## LAS 100+ TAREAS

### Registro de delegaciones (mantenido por GLM-5.3 Flash-Director — ultima pasada 2026-10-16 05:05)

> ⚠️ **División de frentes DeepSeek (directiva del fundador: aprovechar ambos):** este backlog lo usa `DeepSeek-V4.1-Flash` (WorkBuddy). El nuevo **`DS-V4.1-Flash-Opencode`** (OpenCode) tiene canal propio y su encargo inicial: **M117-Build-System + poblado de su backlog** (msg 02 de su canal, 2026-10-16 02:08). Al reclamar tareas de este banco, marcar cuál frente la lleva.

- **M118-CI-CD → DELEGADO por el director (canal DeepSeek-V4.1-Flash msg 264, 2026-10-15 23:00: 12 flips M64 aprobados + commit ok, siguiente M118).** Tarea 20 en vuelo de DeepSeek — no re-clamar. **ACTUALIZACIÓN 2026-10-16 (msg 267): M118 commit HECHO por DeepSeek — pendiente QA §21.8 externa.**
- **M64-IA-De-NPC → QA/flips cerrados por el director (msg 264: 12 flips aprobados).** Tarea 93 queda como refresco/continuación si el director la re-abre.
- **M26-Templo-Subterraneo → DELEGADO formalmente (encargo mens 269, 2026-10-16 02:02): pedido por el propio DeepSeek (su 267), validado por el director (🟡 117/129, complejidad 4, F6).** En vuelo — no re-clamar. QA §21.8 → se deriva a Hy3/agnes al recibir su reporte.

### Bloque A — Su módulo ancla M01 y deuda fundacional

1. M01-Fundamentos (26/152): diagnóstico Patrón D de los 126 restantes y mapa de lotes — 10 [M]
2. M01 b1: resolver bloque dependencias/documentales factibles headless — 10 [M]
3. M01 b2: continuar (docs del 05-Checklist con cita de archivo) — 10 [M]
4. M01 b3: cierre de lo factible; [?] honestos para el resto — 8 [M]
5. M03-Documentación (130/133): 3 pendientes heredados (L67/L68/L69) — 4 [S]
6. M04/M05: deuda residual (hitos M1) documentada o desdoblada — 4 [S]

### Bloque B — Infraestructura de juego (Recom DeepSeek)

7. M40-Infraestructura (175/211): 36 pendientes → lote 1 con tests headless — 10 [C]
8. M40 b2: continuar — 10 [C]
9. M40 b3: cierre (integración GamedFlowManager/SceneManager) — 8 [M]
10. M62-Memoria (113/150): 37 `[ ]` NO-headless → convertir los posibles a suites reproducibles — 10 [C]
11. M62 b2: iteración 7 (integraciones M08/M41-M44/M63/M09) — 10 [C]
12. M60-Datos (189/196): 7 pendientes — 6 [S]
13. M59-Guardado (60/130): diagnóstico de los 70 y plan de 3 iteraciones — 10 [C]
14. M59 b1: implementar lote 1 (save slots) con suite headless — 10 [C]
15. M63-Cargas (67/101): 34 pendientes → streaming/prioridad — 10 [C]
16. M110-Debug-Menu (150/225): 75 pendientes → lotes de 10 (paneles de debug) — 10 [C]
17. M110 b2: continuar (integración con telemetría M105) — 10 [C]
18. M112-Testing (211/225): 14 pendientes — 10 [M]
19. M117-Build (92/110): 18 pendientes — 10 [M]
20. M118-CI/CD (105/106): cerrar el 1 Pendiente + pulir quality.yml — 3 [S]
21. M123-Modding (106/108): 2 pendientes — 3 [S]
22. M124-CGU (83/108): 25 pendientes → sandbox/validación de mods — 8 [M]
23. M64-IA-De-NPC (102/119): 17 pendientes — 8 [M]
24. M69-Fast-Travel (98/145): 47 pendientes → lote infra (waypoints) — 10 [C]
25. M67-Vehiculos (19/131): plan de iteraciones y lote 1 (física/controles) — 10 [C]
26. M68-Transporte (99/131): 32 pendientes — 8 [C]

### Bloque C — Telemetría, logging y QA de sus sistemas (inf³ propia)

27. M105-Telemetría (129/162): resolver/degradar los 45 [?] con justificación o fix — 10 [C]
28. M105 b2: re-sello §21.8.2.b luego de resolver [?] (muestreo 5+) — 6 [M]
29. M103-Logging (173/179): 6 [?] (SB-02 etc.) → resolver los factibles y justificar el resto — 8 [M]
30. M101-QA-General: refresco de plantillas con casos nuevos de la flota — 6 [M]
31. M102-Bug-Tracking: unificar métricas con 11-BUGS.md (reporte automático) — 8 [C]
32. M104-Analytics (107/119): 12 pendientes (catálogo de eventos vs. telemetría) — 8 [M]
33. M107-Backups (167/176): 9 pendientes — 8 [M]
34. M113 (si aplica): hooks de debug con el MCP de Godot — 6 [M]
35. Refactor de scripts-* duplicados (detección y unificación con evidencia) — 10 [C]

### Bloque D — Config y UX técnica

36. M90-Configuración-Grafica (149/249): 100 pendientes → lote 1 (presets) — 10 [C]
37. M90 b2: continuar (escala de resolución/VSync) — 10 [C]
38. M90 b3: cierre con export de settings a M60 — 8 [C]
39. M91-Configuración-De-Audio (212/239): 27 pendientes (trabajo en vuelo de step-5-kilocode) — 10 [C]
40. M91 b2: cierre + regresión completa de buses — 8 [C]
41. M57-Interfaz-De-Control (91/119): 28 pendientes (remapeo) — 8 [M]
42. M58-Accesibilidad (154/183): 29 pendientes → lote técnico (subtítulos, daltonismo) — 10 [M]
43. M58 b2: cierre con test de contraste — 8 [M]
44. M53-UI (144/165): 21 pendientes técnicas (no visuales globales) — 8 [M]

### Bloque E — i18n y localización (deuda conocida de Ling M87.5)

45. M87-Localización (131/136): cerrar 5 pendientes — 6 [M]
46. i18n clave-exhaust: aspirar las 112 claves externas documentadas por Ling (canal) — 10 [C]
47. i18n b2: validación de placeholders y pluralización — 10 [C]
48. i18n b3: migración de fuentes tipográficas si faltan glifos (M88) — 8 [M]
49. M88-Fuentes (174/185): 11 pendientes — 8 [M]

### Bloque F — Datos, clock, calendario, eventos técnicos

50. M29-Tiempo (192/195): 3 pendientes — 4 [S]
51. M30-Reloj (119/120): 1 pendiente — 2 [S]
52. M31-Ciclo-Día/Noche (120/169): 49 pendientes → lote técnico (skybox/luz) — 10 [C]
53. M32-Clima (119/121): 2 pendientes — 3 [S]
54. M74-Eventos (227/285): 58 pendientes → lote técnico de scheduler — 10 [C]
55. M74 b2: continuar eventos (hooks con M22/M23) — 10 [C]
56. M71-Progresión (168/213): 45 pendientes → lote XP/niveles — 10 [C]
57. M72-Logros (77/185): diagnóstico completo + lote 1 de logros técnicos — 10 [C]
58. M73-Coleccionables (26/135): lote técnico de tracking y persistencia — 10 [C]
59. M75-Postgame (17/130): lote técnico de gating postgame — 10 [C]

### Bloque G — Mundo técnico (Recom compartido)

60. M09-Terreno (100/105): 5 pendientes (recetas/pipeline glb) — 8 [C]
61. M10-Generación (88/106): BUG-043 snow + capas faltantes (cuevas/estructuras) — 10 [C]
62. M10 b2: knobs/config del generador (autoload, retry de chunks) — 10 [C]
63. M11-Personaje (75/123): 48 pendientes → lote de control/animación — 10 [C]
64. M11 b2: continuar (movimiento de voxel + cámara) — 10 [C]
65. M12-Cámara (57/102): 45 pendientes → lote zoom/colisión de cámara — 10 [C]
66. M14-Inventario (136/140): 4 pendientes — 4 [S]
67. M16-Crafting (157/203): 46 pendientes técnicas — 10 [C]
68. M33-Agricultura (106/153): 47 pendientes → lote técnico de crecimiento/ciclos — 10 [C]
69. M34-Pesca (99/153): 54 pendientes → lote técnico (cañas/estanques) — 10 [C]
70. M35-Minería (101/142): 41 pendientes — 10 [C]

### Bloque H — Social y económico (integración)

71. M20-Amistad (50/148): lote técnico (puntos/regalos) — 10 [C]
72. M21-Dialogos (82/143): 61 pendientes → lote técnico de graph/nodos — 10 [C]
73. M23-Historias (24/104): lote técnico de triggers/notas — 10 [C]
74. M472-Relaciones? N/A — reemplazo: M22-Historia-Principal (✅ 91/91): refresco de hooks con M31/M74 — 4 [S]
75. M37-Museos (96/148): lote técnico (exposiciones) — 10 [C]
76. M38/M39 (✅): refrescos de integración con M16/M159 — 6 [S]
77. M54-Mapa (133/177): 44 pendientes técnicas (markers/fog) — 10 [C]
78. M55-Diario (37/131): lote técnico de UI de diario — 10 [C]
79. M56-Fotografía (26/137): lote técnico (cámara de foto, export) — 10 [C]

### Bloque I — Legal/marketing técnico (cero-riesgo)

80. M80-Privacidad (142/144): 2 pendientes — 3 [S]
81. M81-Menores (135/137): 2 pendientes — 3 [S]
82. M82-Clasificación (95/100): 5 pendientes — 4 [S]
83. M83-Licencias (98/100): 2 pendientes — 3 [S]
84. M87×M126 (Marketing-Legal, 100/101): 1 pendiente — 2 [S]
85. M126-Marketing-Legal: cierre — 3 [S]
86. M127-Copyright (76/100): 24 pendientes de atribución por archivo (pipeline glb) — 8 [M]
87. M128-Identidad (60/100): lote técnico de paleta/logo assets export — 8 [M]
88. M129-Merchandising (101/108): 7 pendientes — 6 [S]
89. M131-Créditos (86/95): 9 pendientes — 6 [S]
90. M96-Plataformas (105/106): 1 pendiente — 2 [S]
91. M99-Marketing (155/169): 14 pendientes técnicas (embeds, metas) — 8 [M]

### Bloque J — Mundo/NPC avanzado + QA técnica cruzada

92. M19/M65 (✅): refrescos de runtime verificable — 4 [S]
93. M64 b2 (IA-NPC): pathfinding — 10 [C]
94. M84-Economía/Precios: refresco headless de shops/test_loop_economico (14/1 pendiente) — 6 [M]
95. M93-Balance (131/134): 3 pendientes — 4 [S]
96. M94-Retención (87/138): lote técnico de metrics/FOMO-off — 8 [M]
97. M92-Tutorial (132/185): 53 pendientes técnicas — 10 [C]
98. M51-Agua (140/166): 26 técnicous pendientes — 8 [C]
99. M50-Vegetación (129/142): 13 pendientes técnicas — 6 [M]
100. M52-Partículas (147/148): 1 pendiente — 2 [S]
101. M66-Anti-Softlock (110/117): 7 pendientes — 6 [M]
102. M61-Rendimiento (53/148): lote técnico de perfil/culling (tarea suya del nicho CI) — 10 [C]
103. Re-contado global honesto: corrida de `scripts/verificar_checklist.py` y reporte — 6 [M]
104. Barrido de módulos ✅ sin verificación reciente: muestreo §21.8.2.b pedido por director — 10 [C]
105. Preparación de specs para módulos ✅→🟡 por [?]. — 8 [M]

---
**Total: 105 ítems.** Mantenimiento continuo por GLM-5.3-Flash (cron 5 min).

**Firma:** GLM-5.3-Flash / Kilo Code — 2026-10-16

======================================================================
### Bloque W — Repo 2026-10-16 noche (+12 del CI/lint que creamos)
1. CI: revisar el nuevo run post-D102 (el ed110e1 13 paneles dark — el gate de format/lint puede fallar).
2. CI: barrido de los 60+ WARNINGs de GDScript (signals unused del event_bus — prefix underscore).
3. M118: limpiar los WARNING de event_bus (las 40 señales never-used).
4. M01: limpiar los WARNING de terms_manager (_terms_file unused).
5. M113: limpiar los WARNING de logger/log_rotator (dir/min_level shadowing).
6. M129: limpiar los WARNING de merch/dlc/collection (exp shadow, narrowing).
7. M66: limpiar los WARNING de fauna (individuos/avistamiento unused).
8. M62: limpiar los WARNING de memoria (limite shadowing x3, narrowing, ahora_ms).
9. M95: limpiar el dlc_descargado signal unused.
10. M40: limpiar el min_ratio unused de theme_ux ensure_contrast.
11. M107: limpiar el integer division warning de backup_manager.
12. M76: limpiar los WARNING nuevos post-lote (los signals/memoria del multi).

**Estado:** repo de la jornada 2026-10-16 noche (la rama 3b del cron: «agregar nuevas, 100+ siempre»).

**Firma:** GLM-5.3 Flash-Director (GLM-5.3-Flash) / Kilo Code — 2026-10-16 noche