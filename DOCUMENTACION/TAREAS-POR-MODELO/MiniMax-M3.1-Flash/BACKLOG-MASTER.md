# BACKLOG-MASTER — MiniMax M3.1 Flash

**Modelo:** MiniMax-M3.1-Flash
**Plataforma:** MiniMax API (confirmar al integrar)
**Creado:** 2026-10-21 por GLM-5.3 Flash-Director (Kilo Code)
**Capacidades:** Coding DeepSWE 73.7%, Cybersecurity CyberGym 82%, Computer Use OSWorld 61.7%, Agentic tasks (AutomationBench top), Precio $0.15/$0.60/1M, 200+ TPS

## COLA ACTIVA

- [x] [20-Amistad] Suite de cobertura headless para los items `[ ]` de M20 (`game/isla-ancestral/tests/test_m20_amistad_cobertura.gd`, 15 checks, 0 fallos) — 2026-10-27
- [x] [20-Amistad] Cerrar 19 items verificados de M20 (81 → 100 `[x]`, pendientes 68 → 49) con evidencia por check nombrado o archivo citado — 2026-10-27
- [x] [20-Amistad] Catálogo de los 26 puntos de la sección 19 del plan maestro (`01-Requerimientos.md` §6, nuevo) — 2026-10-27
- [x] [20-Amistad] Deuda real mapeada con motivo y referencia de código (`04-Codigo.md` §7.3) — 2026-10-27
- [x] [112-Testing] Reintento EN SERIE tras TIMEOUT del pool en el runner central (flake de contención, no fallo de suite) — 2026-10-27
- [x] [20-Amistad] Log reservado: **2215** — tanda 4 M20/M112 (suite de cobertura + cierre de 19 items + fix del CI)
- [x] [20-Amistad] BUG M20 (limite diario quemado cuando falla el regalo) corregido + validacion de `texto_id` en `enviar_carta()` — 2026-10-27 (Log 2219)
- [x] [20-Amistad] Suite de regresion del bug: `game/isla-ancestral/tests/test_m20_limite_regalo.gd` (19 checks, 0 fallos, EXIT 0; prueba ROJO: sin fix = 6 fallos, sin validacion de texto = 5 fallos) — 2026-10-27 (Log 2219)
- [x] [20-Amistad] Log reservado: **2219** — tanda 5 M20 (fix del bug + suite de regresion + cableo en quality.yml)
- [x] [17-Construccion] Suite de reglas declarativas por pieza contra el CATALOGO REAL: `game/isla-ancestral/tests/test_m17_reglas_pieza.gd` (40 checks, 0 fallos, EXIT 0) — 2026-10-27 (Log 2220)
- [x] [17-Construccion] +5 [x] en M17 (126 -> 135 de 175): G137 (puerta exige pared contigua), G138 (ventana exige pared contigua de 1 celda), G141 (camino solo sobre terreno), G145 (ruina/parcela NPC no colocables ni demolidas), F121 (re-validacion con cada rotacion) — 2026-10-27 (Log 2220)
- [x] [17-Construccion] Log reservado: **2220** — tanda P3-3 M17 (suite de reglas contra catalogo real + 5 flips + cableo en quality.yml)
- [x] [112-Testing] Suite M17 nueva + suite M20 nueva cableadas en `quality.yml` (M118) — 2026-10-27 (Logs 2219/2220)
- [x] [Canal] Mensaje 062 de cierre de tanda (M20 bug + M17 suite) reportado a la directora en `Mensajes entre modelos/MiniMax-M3.1-Flash/` — 2026-10-27 21:50
- [x] [Cronometro] Cadencia actualizada de 30 min a **60 min** (`0 * * * *`, id `wku_17fcb57f5001ibrgRaZ2c68TLo`) + `CRONOMETRO.md` y `scripts/activar_cron_minimax.py` actualizados — 2026-10-27 23:55
- [ ] [112-Testing] Bajar el tiempo total del CI (~875 s > presupuesto 600 s; lane voxel = 6 suites × ~72 s) — dueño a definir
- [ ] [20-Amistad] Cerrar con el dueño de M20 la deuda vigente (QUEDAN: `FriendshipEvent` + 5 tipos convocables, nombres de nivel, `schema_version` en el save, UI de M53) — **RESUELTO en esta tanda: validación de `texto_id` en cartas + limite diario quemado cuando falla el regalo (Log 2219, suite 19 checks, 0 fallos)**
- [ ] [20-Amistad/M162] Decidir la escala de `amistad_<npc_id>` (hoy devuelve el NIVEL 1..11; el registry de M162 exige `>= 60` / `>= 90` → esas variantes nunca se disparan) — decisión de contrato M20/M162/M21


## REPOBLACION V3 (2026-10-21T07:58:00)

1. - [ ] [73-Coleccionables] Validar ids unicos con validate_collectibles.gd [M] (revertido: artefacto inexistente, BUG-070 Familia A, Ling 3.1 Flash msg 50, atria-dawn 2026-10-08 <!-- fuente: 73-Coleccionables/05-Checklist.md -->
2. - [ ] [73-Coleccionables] Registrar reliquias de ruinas (M25) y templos (M26) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
3. - [ ] [73-Coleccionables] Icono por reliquia (M46) [S] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
4. - [ ] [73-Coleccionables] Recompensa de colección definida [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
5. - [ ] [73-Coleccionables] Testear reliquias duplicadas (idempotente) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
6. - [ ] [73-Coleccionables] Registrar fragmentos de reliquias rotas (M25) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
7. - [ ] [73-Coleccionables] Descripción que narra la reliquia original [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
8. - [ ] [73-Coleccionables] Registrar al excavar [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
9. - [ ] [73-Coleccionables] Testear fragmentos de la misma reliquia (dedupe) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
10. - [ ] [73-Coleccionables] Registrar conchas de la playa (M51) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
11. - [ ] [73-Coleccionables] Conchas de eventos de playa (M74) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
12. - [ ] [73-Coleccionables] Variedad visual por playa (M46) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
13. - [ ] [73-Coleccionables] Recompensa de colección (dinero M38) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
14. - [ ] [73-Coleccionables] Testear conchas en 3 playas distintas [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
15. - [ ] [73-Coleccionables] Registrar minerales minados (M35) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
16. - [ ] [73-Coleccionables] Gema rara como ítem especial [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
17. - [ ] [73-Coleccionables] Recompensa de colección (gema M35) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
18. - [ ] [73-Coleccionables] Testear minerales por región [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
19. - [ ] [73-Coleccionables] Registrar peces pescados (M34) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
20. - [ ] [73-Coleccionables] Peces de temporada (M29) y hora (M31) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
21. - [ ] [73-Coleccionables] Trofeo de pesca como recompensa (M18) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
22. - [ ] [73-Coleccionables] Registrar al atrapar (FISH_CAUGHT) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
23. - [ ] [73-Coleccionables] Testear peces raros (solo lluvia M32) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
24. - [ ] [73-Coleccionables] Registrar plantas cosechadas (M33) y forrajeadas (M50) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
25. - [ ] [73-Coleccionables] Semillas de temporada [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
26. - [ ] [73-Coleccionables] Recompensa de colección (semilla rara M33) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
27. - [ ] [73-Coleccionables] Registrar con CROP_HARVESTED [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
28. - [ ] [73-Coleccionables] Testear plantas de las 4 estaciones (M29) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
29. - [ ] [73-Coleccionables] Insectos nocturnos y diurnos (M31) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
30. - [ ] [73-Coleccionables] Jaula decorativa como recompensa (M18) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
31. - [ ] [73-Coleccionables] Registrar al capturar [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
32. - [ ] [73-Coleccionables] Testear insectos en biomas distintos [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
33. - [ ] [73-Coleccionables] Registrar fósiles excavados (M25) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
34. - [ ] [73-Coleccionables] Esqueleto completo como recompensa (M37) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
35. - [ ] [73-Coleccionables] Excavación con huevos (2 bloques) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
36. - [ ] [73-Coleccionables] Registrar con FOSSIL_DUG [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
37. - [ ] [73-Coleccionables] Testear fósiles en ruinas y montañas [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
38. - [ ] [73-Coleccionables] Registrar cartas de festival (M74) y correo [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
39. - [ ] [73-Coleccionables] Cartas de NPC (M19) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
40. - [ ] [73-Coleccionables] Sobre de regalo como recompensa (M20) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
41. - [ ] [73-Coleccionables] Registrar al recibir (CARTA_RECIBIDA) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
42. - [ ] [73-Coleccionables] Testear cartas de temporada [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
43. - [ ] [73-Coleccionables] Registrar fotografías tomadas (M56) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
44. - [ ] [73-Coleccionables] Fotos de criaturas y lugares [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
45. - [ ] [73-Coleccionables] Álbum premium como recompensa (M55) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
46. - [ ] [73-Coleccionables] Registrar con PHOTO_TAKEN [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
47. - [ ] [73-Coleccionables] Testear fotos especiales (festival M74) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
48. - [ ] [73-Coleccionables] Registrar muebles comprados (M39) y regalados (M20) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
49. - [ ] [73-Coleccionables] Muebles de evento (M74) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
50. - [ ] [73-Coleccionables] Mueble exclusivo como recompensa (M18) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
51. - [ ] [73-Coleccionables] Registrar al colocar en la casa (M18) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
52. - [ ] [73-Coleccionables] Testear muebles de tienda rotativa [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
53. - [ ] [73-Coleccionables] Registrar ropa comprada (M39) y de evento (M74) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
54. - [ ] [73-Coleccionables] Atuendos de NPC (M20) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
55. - [ ] [73-Coleccionables] Atuendo exclusivo como recompensa (M46) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
56. - [ ] [73-Coleccionables] Registrar al usar (vestuario) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
57. - [ ] [73-Coleccionables] Testear ropa de las 4 estaciones [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
58. - [ ] [73-Coleccionables] Registrar herramientas de misiones (M22/M23) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
59. - [ ] [73-Coleccionables] Herramientas de crafting avanzado (M16) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
60. - [ ] [73-Coleccionables] Mejora de herramienta como recompensa [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
61. - [ ] [73-Coleccionables] Registrar al fabricar [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
62. - [ ] [73-Coleccionables] Testear herramientas únicas (1 por partida) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
63. - [ ] [73-Coleccionables] Registrar documentos de lore (M22) y ruinas (M25) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
64. - [ ] [73-Coleccionables] Documentos de la biblioteca [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
65. - [ ] [73-Coleccionables] Lore desbloqueado como recompensa (M55) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
66. - [ ] [73-Coleccionables] Registrar al leer (M21/M70) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
67. - [ ] [73-Coleccionables] Testear documentos sin spoilers (orden de lectura) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
68. - [ ] [73-Coleccionables] Registrar mapas de tesoro (M54/M71) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
69. - [ ] [73-Coleccionables] Mapas de exploración [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
70. - [ ] [73-Coleccionables] Tesoro oculto como recompensa (M71) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
71. - [ ] [73-Coleccionables] Registrar al encontrar [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
72. - [ ] [73-Coleccionables] Testear mapas con coordenadas correctas [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
73. - [ ] [73-Coleccionables] Registrar símbolos de puzzles (M24) y templos (M26) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
74. - [ ] [73-Coleccionables] Símbolos de runas [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
75. - [ ] [73-Coleccionables] Pista de puzzle como recompensa (M24) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
76. - [ ] [73-Coleccionables] Registrar al resolver [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
77. - [ ] [73-Coleccionables] Testear símbolos de los 7 anillos (M26) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
78. - [ ] [73-Coleccionables] Registrar mensajes en botellas y NPC (M21) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
79. - [ ] [73-Coleccionables] Mensajes de correo [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
80. - [ ] [73-Coleccionables] Historia de NPC como recompensa (M20) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
81. - [ ] [73-Coleccionables] Registrar al leer [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
82. - [ ] [73-Coleccionables] Testear mensajes repetidos (dedupe) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
83. - [ ] [73-Coleccionables] Registrar secretos de acciones ocultas (M71) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
84. - [ ] [73-Coleccionables] Secretos de exploración [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
85. - [ ] [73-Coleccionables] Contenido oculto como recompensa (M55) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
86. - [ ] [73-Coleccionables] Registrar objetos de la historia principal (M22) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
87. - [ ] [73-Coleccionables] Objetos por capítulo [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
88. - [ ] [73-Coleccionables] Final alterno como recompensa (M22) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
89. - [ ] [73-Coleccionables] Registrar con MISION_CAMBIADA [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
90. - [ ] [73-Coleccionables] Testear objetos de los 7 capítulos [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
91. - [ ] [73-Coleccionables] Otorgar recompensa definida (M14/M38) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
92. - [ ] [73-Coleccionables] Notificación especial al completar (M44) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
93. - [ ] [73-Coleccionables] Confeti sutil por evento (M52) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
94. - [ ] [73-Coleccionables] Desbloquear progresión (M71: receta M16, área, atajo M69) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
95. - [ ] [73-Coleccionables] Progreso por categoría en el diario (M55) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
96. - [ ] [73-Coleccionables] % sobre lo descubierto (anti-spoiler) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
97. - [ ] [73-Coleccionables] Registrar logros de colección (M72) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
98. - [ ] [73-Coleccionables] Migración de saves antiguos [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
99. - [ ] [73-Coleccionables] Recolectar con inventario lleno (M14) o durante diálogo (M21, bloqueado) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
100. - [ ] [73-Coleccionables] Recolectar en evento (M74) e ítem de fuente borrada (fallback) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
101. - [ ] [73-Coleccionables] Catálogo estático sin consultas por frame (M61) y sin GC pesado (M62) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
102. - [ ] [73-Coleccionables] Probar 500 ítems de estado sin lag y con profiler (M116) [C] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
103. - [ ] [73-Coleccionables] Probar 22 categorías en estado inicial y colección con 1 faltante [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
104. - [ ] [73-Coleccionables] Crear validate_collectibles.gd (ids únicos, totales, recompensas, i18n) [C] (revertido: artefacto inexistente, BUG-070 Familia A, Ling 3.1 Flash msg 5 <!-- fuente: 73-Coleccionables/05-Checklist.md -->
105. - [ ] [73-Coleccionables] Probar ciclo completo: recolectar → registrar → ver en diario → completar → recompensa [C] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
106. - [ ] [73-Coleccionables] Probar ciclo de guardado: recolectar → guardar → cargar → conservar [C] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
107. - [ ] [72-Sistema-De-Logros] Registrar dependencias del módulo: M71 (Progresión), M37 (Museos y Colecciones), M97 (Steam Store Page) según CHECKLIST-GLOBAL [S] — M71 ✅ (evaluador  <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
108. - [ ] [72-Sistema-De-Logros] Registrar integraciones adicionales: M20, M22, M33, M34, M38, M53, M58, M60, M66, M103, M104, M112 [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
109. - [ ] [72-Sistema-De-Logros] Separar dentro/fuera de alcance: UI core en M53/M58, reglas de colecciones en M37, página de Steam en M97 [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
110. - [ ] [72-Sistema-De-Logros] Definir criterios de aceptación verificables (10 criterios) [S] — agnes-2026-09-06: criterios definidos en 01-Requerimientos (RF1-RF14, RN1-RN12); ver <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
111. - [ ] [72-Sistema-De-Logros] Definir criterios de aceptación verificables (10 criterios) [S] -- agnes-2026-09-06: criterios RF1-RF14 en 01-Requerimientos; verificación con test_lo <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
112. - [ ] [72-Sistema-De-Logros] CAT: crear catálogo base .tres por categoría con logros cozy (primeras veces, hitos, colecciones) [C] — data/logros/logros.json con 7 logros cozy (JSO <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
113. - [ ] [72-Sistema-De-Logros] CAT: garantizar que ningún logro del catálogo exija números abusivos o contrarreloj [M] — condiciones cozy (sellos/colecciones/primeras veces), sin co <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
114. - [ ] [72-Sistema-De-Logros] RF2: declarar en cada condición depende_de(tipo_evento) para el índice de dirty flags [M] — iter. 3-4: el índice vive en las suscripciones event-drive <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
115. - [ ] [72-Sistema-De-Logros] RF13: registrar cada desbloqueo en logs (M103) y analytics (M104) con id, fecha y origen [S] — [DOM-LOGRO] id+nombre+día (fecha M29); M104 con dueño ( <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
116. - [ ] [72-Sistema-De-Logros] RF6: resumir en un único toast "N nuevos logros desbloqueados" si la cola supera 5 [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
117. - [ ] [72-Sistema-De-Logros] RF6: permitir click en el toast para abrir el panel en ese logro [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
118. - [ ] [72-Sistema-De-Logros] RF6: espaciar toasts con delay regenerativo de 0.8 s [S] — cola de M53 con desplazamiento vertical automático (heredado; ajuste fino visual dueño M53) <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
119. - [ ] [72-Sistema-De-Logros] RF6: registrar en logs si la cola se desborda (prevención de pérdida de avisos) [S] — emisión 1:1 sin cola intermedia en M72 (cola dueño M53); M72 no  <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
120. - [ ] [72-Sistema-De-Logros] RF9: integrar el estado en el guardado global de M60/M59 [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
121. - [ ] [72-Sistema-De-Logros] RF9: conservar el progreso parcial acumulado de logros en progreso [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
122. - [ ] [72-Sistema-De-Logros] RF11: no borrar logros de Steam automáticamente al borrar partida local [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
123. - [ ] [72-Sistema-De-Logros] RN2: verificar que el write-through no bloquee el frame principal (escritura diferida segura) [S] -- agnes-2026-09-06: achievement_service.gd usa Save <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
124. - [ ] [72-Sistema-De-Logros] RF7: implementar PanelLogrosUI como vista de consulta de logros [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
125. - [ ] [72-Sistema-De-Logros] RF7: agrupar logros por categoría en el panel [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
126. - [ ] [72-Sistema-De-Logros] RF7: mostrar logros obtenidos con su fecha de desbloqueo [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
127. - [ ] [72-Sistema-De-Logros] RF7: mostrar logros en progreso con contador "X de Y" y barra de progreso [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
128. - [ ] [72-Sistema-De-Logros] RF7: mostrar logros ocultos no revelados como misterio "???" [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
129. - [ ] [72-Sistema-De-Logros] RF7: revelar el texto e ícono de un logro oculto solo cuando se desbloquea [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
130. - [ ] [72-Sistema-De-Logros] RF10: implementar is_unlocked(id) [S] — iter. 3 (testeado) <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
131. - [ ] [72-Sistema-De-Logros] RF10: implementar get_definicion(id) [S] — iter. 3 (testeado) <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
132. - [ ] [72-Sistema-De-Logros] RF10: implementar get_todos() ordenado por orden y categoría [S] — iter. 3: por orden de catálogo (orden/categoría con dueño al llegar el campo al JSO <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
133. - [ ] [72-Sistema-De-Logros] RF10: implementar get_estado(id) con {desbloqueado, fecha, progreso, extra} [S] — iter. 3: {id,nombre,descripcion,desbloqueado,oculto,dia,hora,progres <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
134. - [ ] [72-Sistema-De-Logros] RF7: permitir abrir el panel desde el toast y desde la UI de progreso de M53/M71 [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
135. - [ ] [72-Sistema-De-Logros] RN1: presupuesto de evaluación < 1 ms por evento con 200 logros definidos [C] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
136. - [ ] [72-Sistema-De-Logros] RN3: módulo compila y funciona 100% sin SDK de Steam [C] — sin capa Steam; test headless 0 fallos sin Steam <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
137. - [ ] [72-Sistema-De-Logros] RN3: SteamSync se carga en runtime solo si la plataforma lo provee (M97) [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
138. - [ ] [72-Sistema-De-Logros] RN6: compatible con Godot 4.x >= 4.4.1 y GDScript tipado explícito [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
139. - [ ] [72-Sistema-De-Logros] RN7: notificaciones no modales, no bloqueantes y desactivables (M58) [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
140. - [ ] [72-Sistema-De-Logros] RN8: estado en guardado de partida (M60), coherente con PRNG (M29) y M71 [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
141. - [ ] [72-Sistema-De-Logros] RN9: agregar un logro nuevo = crear un .tres y registrarlo, sin tocar código [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
142. - [ ] [72-Sistema-De-Logros] RN10: AchievementManager testeable con partidas sintéticas sin UI ni Steam [M] — test_logros.gd 13 secciones, 0 fallos headless <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
143. - [ ] [72-Sistema-De-Logros] RN11: cero logros por tiempo real (M30) y cero presión social con porcentajes de jugadores [S] — iter. 3: fechas de JUEGO (M29), sin porcentajes de ot <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
144. - [ ] [72-Sistema-De-Logros] RN11: todo logro alcanzable jugando con calma, sin contrarreloj ni FOMO [S] — catálogo cozy (umbral máx 7 sellos / 3 viajes) <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
145. - [ ] [72-Sistema-De-Logros] RN12: estado serializado compacto mediante diccionarios planos sin redundancia [M] — iter. 3: {id: {dia,hora}} (3 ints por logro) <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
146. - [ ] [72-Sistema-De-Logros] Diseñar arquitectura por capas: motor desacoplado + adaptadores UI/Steam [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
147. - [ ] [72-Sistema-De-Logros] Diseñar AchievementManager como autoload "logros" registrado en project.godot [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
148. - [ ] [72-Sistema-De-Logros] Diseñar índice de dirty flags: tipo_evento -> ids de logros dependientes [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
149. - [ ] [72-Sistema-De-Logros] Diseñar diagrama de arquitectura con emisores, manager, UI y SteamSync [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
150. - [ ] [72-Sistema-De-Logros] Diseñar flujo de desbloqueo: evento -> evaluación -> marca -> señal -> persistencia -> notificación -> Steam [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
151. - [ ] [72-Sistema-De-Logros] Diseñar flujo de carga con retroactividad y reconciliación Steam [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
152. - [ ] [72-Sistema-De-Logros] Diseñar flujo de reset de partida con limpieza local y reconciliación posterior [M] -- agnes-2.5-flash 2026-09-12: disenado 03-Diseno.md §3.4; restore <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
153. - [ ] [72-Sistema-De-Logros] Diseñar contrato de señales públicas del autoload (5 señales) [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
154. - [ ] [72-Sistema-De-Logros] Diseñar API de consulta pública completa (13 funciones) [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
155. - [ ] [72-Sistema-De-Logros] Diseñar estructura de carpetas res://logros/ con subcarpetas condiciones, ui, steam, datos [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
156. - [ ] [72-Sistema-De-Logros] Diseñar fechas tomadas una única vez por desbloqueo y persistidas [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
157. - [ ] [72-Sistema-De-Logros] Diseñar extensión futura: nuevos tipos de condición sin tocar el manager (polimorfismo) [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
158. - [ ] [72-Sistema-De-Logros] Diseñar convivencia de notificaciones con pausas del juego y menús abiertos [M] -- agnes-2.5-flash 2026-09-12: RF6 hereda cola/pool de M53; EventBus.n <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
159. - [ ] [72-Sistema-De-Logros] No duplicar el registro de hitos de M71: logros comparten ids de hitos sin re-implementarlos [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
160. - [ ] [72-Sistema-De-Logros] Consumir señales de donación de M37 para CondicionColeccion [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
161. - [ ] [72-Sistema-De-Logros] Usar ids de colecciones reales de M37 en las definiciones .tres [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
162. - [ ] [72-Sistema-De-Logros] Crear logros de colección completada coherentes con los criterios de M37 [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
163. - [ ] [72-Sistema-De-Logros] Diseñar SteamSync desacoplado que escuche logro_desbloqueado sin modificar el manager [C] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
164. - [ ] [72-Sistema-De-Logros] Sincronizar local -> Steam con SetAchievement + StoreStats al desbloquear [C] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
165. - [ ] [72-Sistema-De-Logros] Sincronizar Steam -> local con GetAchievement al cargar partida [C] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
166. - [ ] [72-Sistema-De-Logros] Reconciliar discrepancias en ambos sentidos ganando el estado desbloqueado [M] -- agnes-2.5-flash 2026-09-12: DISEÑO en 03-Diseno.md §3.2 paso 4 (loca <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
167. - [ ] [72-Sistema-De-Logros] Mapear logro_steam_id 1:1 con el catálogo declarado en la página de Steam (M97) [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
168. - [ ] [72-Sistema-De-Logros] Validar en editor que el mapeo Steam sea consistente y sin duplicados [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
169. - [ ] [72-Sistema-De-Logros] Garantizar que la capa Steam nunca bloquee ni retrase el gameplay local [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
170. - [ ] [72-Sistema-De-Logros] Logro instalado después de que el jugador ya cumplió la condición: otorgado retroactivamente al cargar [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
171. - [ ] [72-Sistema-De-Logros] Desbloqueo con Steam desactivado: funciona idéntico y la próxima sesión con Steam reconcilia [M] — iter. 1-4: sin capa Steam; desbloqueo local complet <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
172. - [ ] [72-Sistema-De-Logros] Desbloqueo con Steam activado fallido por red: no reintentar indefinidamente, reintentar en carga [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
173. - [ ] [72-Sistema-De-Logros] Cierre abrupto del juego justo después de desbloquear: logro persistido por write-through [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
174. - [ ] [72-Sistema-De-Logros] Guardado corrupto con ids de logros desconocidos: descartar sin romper la partida [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
175. - [ ] [72-Sistema-De-Logros] Partida vieja sin diccionario de logros (migración): crear estado vacío y evaluar retroactivo [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
176. - [ ] [72-Sistema-De-Logros] Borrar la partida con logros en Steam: no borrar Steam; reconciliar en la próxima sesión [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
177. - [ ] [72-Sistema-De-Logros] 20 logros desbloqueados a la vez en una migración: cola con resumen "N nuevos logros" [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
178. - [ ] [72-Sistema-De-Logros] Logro oculto consultado antes de desbloquearse: mostrar misterio sin filtrar datos [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
179. - [ ] [72-Sistema-De-Logros] Condición compuesta con subcondición de estadística inexistente: validación en editor la detecta [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
180. - [ ] [72-Sistema-De-Logros] Notificación durante pantalla de carga o cinemática: encolar y mostrar al recuperar control [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
181. - [ ] [72-Sistema-De-Logros] Partidas con PRNG distinto (M29) evaluando condiciones: sin aleatoriedad en condiciones, determinismo completo [S] — agnes-2026-09-06: _test_condicion <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
182. - [ ] [72-Sistema-De-Logros] Logro cuyo texto i18n falta: fallback al texto base español sin error en pantalla [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
183. - [ ] [72-Sistema-De-Logros] Índice de dirty flags por tipo de evento: re-evaluar solo logros afectados [C] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
184. - [ ] [72-Sistema-De-Logros] Evitar allocaciones pesadas en el hot path de notify_event [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
185. - [ ] [72-Sistema-De-Logros] Memorizar progreso de condiciones compuestas durante una misma evaluación [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
186. - [ ] [72-Sistema-De-Logros] No evaluar logros ya desbloqueados (corte temprano por _desbloqueados) [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
187. - [ ] [72-Sistema-De-Logros] No reconstruir diccionarios del estado en cada consulta (caché de lectura) [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
188. - [ ] [72-Sistema-De-Logros] Persistencia diferida agrupada: write-through inmediato pero sin escrituras por frame [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
189. - [ ] [72-Sistema-De-Logros] Cargar el catálogo .tres con ResourceLoader al inicio, sin cargas perezosas en runtime [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
190. - [ ] [72-Sistema-De-Logros] Pooling de toasts UI (preinstanciar y reutilizar nodos) [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
191. - [ ] [72-Sistema-De-Logros] Panel de logros: construir los items solo al abrir y reciclarlos al filtrar [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
192. - [ ] [72-Sistema-De-Logros] Maduras: verificar en Profiler que notify_event con 200 logros < 1 ms [C] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
193. - [ ] [72-Sistema-De-Logros] Maduras: verificar 0.5 ms máx extra por frame en eventos de progreso (sin GC spikes) [C] — agnes-2026-09-06: evaluación event-driven (no frame), _comp <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
194. - [ ] [72-Sistema-De-Logros] Crear 04-Codigo.md (archivos previstos, firmas GDScript, notas de implementación) [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
195. - [ ] [72-Sistema-De-Logros] Redactar README interno res://logros/README.md con guía "cómo agregar un logro" [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
196. - [ ] [72-Sistema-De-Logros] Documentar las reglas cozy del catálogo en el README (sin grind, sin contrarreloj) [S] — agnes-2026-09-05: rules cozy documentadas en 01-Requerimiento <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
197. - [ ] [72-Sistema-De-Logros] Documentar la integración con M97 en plan-actual cuando exista la capa Steam real [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
198. - [ ] [72-Sistema-De-Logros] Generar log en Logs/ al completar la implementación, con el formato estándar NN-descripcion_fecha.md [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
199. - [ ] [72-Sistema-De-Logros] Planear tests unitarios del AchievementManager con partidas sintéticas (M112) [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
200. - [ ] [72-Sistema-De-Logros] Test unidad: notify_event desbloquea logro cuando la condición cumple [M] — _test_desbloqueo_por_evento <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
201. - [ ] [72-Sistema-De-Logros] Test unidad: notify_event no desbloquea cuando la condición no cumple [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
202. - [ ] [72-Sistema-De-Logros] Test unidad: doble notify_event no genera doble desbloqueo ni doble señal [M] — _test_idempotente <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
203. - [ ] [72-Sistema-De-Logros] Test unidad: deserialización de estado corrupto no rompe la carga [M] — round-trip + logro_viejo purgado <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
204. - [ ] [72-Sistema-De-Logros] Test unidad: condiciones compuestas AND/OR/NOT con casos de borde [M] — agnes-2026-09-05: _test_condicion_compuesta_edge_cases() prueba compuesta con  <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
205. - [ ] [72-Sistema-De-Logros] Test integración: evento de M71 desbloquea logro de progresión de punta a punta [C] — Historia.marcar_sello → prereq_met → M71 → M72 (testeado) <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
206. - [ ] [72-Sistema-De-Logros] Test integración: donación de M37 completa logro de colección [C] — coleccion_completa flora vía evaluador M71 (testeado iter. 1-2 vía flujo M37) <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
207. - [ ] [72-Sistema-De-Logros] Test manual: 20 desbloqueos simultáneos muestran resumen encolado sin spam [M] -- agnes-2.5-flash 2026-09-12: lógica listada_para_ui()+cola M53 IMPLEM <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
208. - [ ] [72-Sistema-De-Logros] Test manual: notificaciones desactivadas por accesibilidad no se muestran pero sí se registran [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
209. - [ ] [72-Sistema-De-Logros] Test manual: borrar partida limpia logros locales y la sesión Steam reconcilia [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
210. - [ ] [72-Sistema-De-Logros] Test manual: ciclo cosechar-primera vez muestra el toast "Primera cosecha" [M] -- agnes-2.5-flash 2026-09-12: toast emitido por _emitir_toast() con ti <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
211. - [ ] [72-Sistema-De-Logros] Test rendimiento: Profiler con 200 logros y evento de progreso < 1 ms [C] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
212. - [ ] [17-Construccion] Definir el problema: construcción cozy sobre mundo voxel con rejilla de 1 m alineada a M08 [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
213. - [ ] [17-Construccion] Registrar dependencias: M08 (Mundo Voxel), M14 (Inventario) y relaciones M18, M25, M64, M58, M31, M32, M73, M92, M93, M71 [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
214. - [ ] [17-Construccion] RF1: modo construcción y modo decoración con entrada/salida rápida [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
215. - [ ] [17-Construccion] RF2: rejilla voxel de 1 m alineada al mundo con snapping de 90° [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
216. - [ ] [17-Construccion] RF3: previsualización fantasma con estado válido/inválido [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
217. - [ ] [17-Construccion] RF4: rotación de piezas en pasos de 90° [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
218. - [ ] [17-Construccion] RF5: elevación por plantas con revalidación en cada nivel [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
219. - [ ] [17-Construccion] RF6: permisos de zona (edificable, protegida, narrativa, agua) [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
220. - [ ] [17-Construccion] RF7: costo de recursos con verificación y descuento en M14 [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
221. - [ ] [17-Construccion] RF8: validación de ocupación, soporte y reglas por pieza [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
222. - [ ] [17-Construccion] RF9-RF11: colocación con undo, copiar/mover/almacenar, demolición con devolución [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
223. - [ ] [17-Construccion] RF12-RF14: catálogo de 12 familias de piezas, integración M18/M25/M64 y persistencia M58 [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
224. - [ ] [17-Construccion] P3: grid — rejilla voxel de 1 m alineada al origen global de M08 [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
225. - [ ] [17-Construccion] P4: snapping — ajuste de posición y rotación (90°) a la celda más cercana [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
226. - [ ] [17-Construccion] P6: elevación — planta base y subir/bajar con altura máxima por zona [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
227. - [ ] [17-Construccion] P7: copia — tomar pieza existente como plantilla del fantasma [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
228. - [ ] [17-Construccion] P9: recolocar — redondeo a rejilla y undo que devuelve la pieza a su celda [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
229. - [ ] [17-Construccion] P10: almacenamiento — devolver piezas al inventario M14 sin pérdidas [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
230. - [ ] [17-Construccion] P11: demolición — confirmación suave y retiro de la pieza del mundo [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
231. - [ ] [17-Construccion] P14: objetos inválidos — toda regla fallida bloquea la colocación con motivo [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
232. - [ ] [17-Construccion] P15: colisiones — piezas con colisión estática real; puertas con hueco navegable [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
233. - [ ] [17-Construccion] P16: restricciones — reglas por pieza, topes por zona, alturas y parcelas ajenas [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
234. - [ ] [17-Construccion] P21: ventanas — 1x1 en pared, transparentes a la luz (M48) [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
235. - [ ] [17-Construccion] P22: escaleras — bloque inclinado que exige apoyo y conecta plantas [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
236. - [ ] [17-Construccion] P23: puentes — losa 1-4 celdas solo sobre agua dentro de zona permitida [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
237. - [ ] [17-Construccion] P26: iluminación — faroles con SpotLight/OmniLight ligados al ciclo M31 [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
238. - [ ] [17-Construccion] P27: muebles — camas, mesas, sillas y estanterías con interacción M18 [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
239. - [ ] [17-Construccion] Abrir modo con herramienta de construcción (M13) o tecla asignada [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
240. - [ ] [17-Construccion] Cerrar modo con la misma acción sin confirmación agresiva [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
241. - [ ] [17-Construccion] HUD de modo con categorías del catálogo y costo de la pieza activa [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
242. - [ ] [17-Construccion] El movimiento del jugador se suspende solo durante la colocación [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
243. - [ ] [17-Construccion] El mundo continúa activo (NPC, clima, tiempo) mientras se construye [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
244. - [ ] [17-Construccion] Selección de pieza por categorías: estructura, mobiliario, iluminación, decoración [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
245. - [ ] [17-Construccion] Desbloqueos de piezas visibles en el catálogo (M70/M93) [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
246. - [ ] [17-Construccion] Tutorial de construcción integrado y repetible (plan maestro línea 2549) [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
247. - [ ] [17-Construccion] Indicador de celda destino resaltado sobre el mundo [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
248. - [ ] [17-Construccion] Cero clicks rápidos duplicados: cooldown de confirmación de 150 ms [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
249. - [ ] [17-Construccion] Paso de rejilla fijo de 1 m derivado del tamaño de voxel de M08 [C] <!-- fuente: 17-Construccion/05-Checklist.md -->
250. - [ ] [17-Construccion] Origen de la rejilla idéntico al origen global del mundo voxel [C] <!-- fuente: 17-Construccion/05-Checklist.md -->
251. - [ ] [17-Construccion] Las piezas de NxN celdas ocupan exactamente su área completa en la rejilla [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
252. - [ ] [17-Construccion] Altura de planta: 1 m por nivel de bloque; habitaciones de 3 m en M18 [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
253. - [ ] [17-Construccion] Límites de mundo: la colocación se rechaza fuera del AABB jugable de M08 [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
254. - [ ] [17-Construccion] La rejilla solo se calcula sobre terreno cargado (nunca sobre chunks vacíos) [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
255. - [ ] [17-Construccion] La rejilla es coherente tras guardar y cargar (misma celda ↔ misma posición) [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
256. - [ ] [17-Construccion] Rotar la pieza en 4 pasos de 90° con la tecla dedicada [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
257. - [ ] [17-Construccion] La validación se re-ejecuta con cada rotación (celdas afectadas cambian) [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
258. - [ ] [17-Construccion] Subir/bajar la pieza una planta por pulsación con límite de altura [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
259. - [ ] [17-Construccion] El fantasma muestra la pieza en el nivel elevado sin flotar visualmente mal [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
260. - [ ] [17-Construccion] Mover una pieza desocupa las celdas originales solo al confirmar [C] <!-- fuente: 17-Construccion/05-Checklist.md -->
261. - [ ] [17-Construccion] Al mover, los recursos no se re-cobran (solo se reubican) [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
262. - [ ] [17-Construccion] Almacenar requiere inventario con espacio libre (M14) [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
263. - [ ] [17-Construccion] Demolición con ventana de confirmación y preview de lo que se devuelve [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
264. - [ ] [17-Construccion] Puerta exige pared contigua en la celda de instalación [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
265. - [ ] [17-Construccion] Ventana exige pared contigua de al menos 1 celda [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
266. - [ ] [17-Construccion] Escalera exige apoyo en piso o pared y no bloquea la circulación [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
267. - [ ] [17-Construccion] Puente solo sobre agua (laguna/mar interior) y dentro de alcance de zona [C] <!-- fuente: 17-Construccion/05-Checklist.md -->
268. - [ ] [17-Construccion] Camino solo sobre césped/arena (nunca sobre roca o pendiente fuerte) [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
269. - [ ] [17-Construccion] Ninguna celda de la pieza puede solapar un NPC activo (consulta M64) [C] <!-- fuente: 17-Construccion/05-Checklist.md -->
270. - [ ] [17-Construccion] Las piezas no pueden bloquear la única salida de la zona de construcción [C] <!-- fuente: 17-Construccion/05-Checklist.md -->
271. - [ ] [17-Construccion] Las piezas de ruina M25 y parcelas de NPC son siempre no colocables ni demolidas [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
272. - [ ] [17-Construccion] Aviso claro con motivo al intentar colocar fuera de zona (fantasma rojo + texto) [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
273. - [ ] [17-Construccion] Las zonas se serializan en M58 y se restauran antes de las piezas [C] <!-- fuente: 17-Construccion/05-Checklist.md -->
274. - [ ] [17-Construccion] Cambios de zona emiten señal a M64 (navmesh) y a M93 (proyectos) [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
275. - [ ] [17-Construccion] El almacenamiento convierte la pieza en ítem del inventario sin perder receta [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
276. - [ ] [17-Construccion] Los stacks de M14 se agrupan al devolver materiales sobrantes [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
277. - [ ] [17-Construccion] Balance inicial de costos delegado a M92 con tabla de referencia en las recetas [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
278. - [ ] [17-Construccion] M08: los datos de pieza viven en capa voxel separada del terreno generado [C] <!-- fuente: 17-Construccion/05-Checklist.md -->
279. - [ ] [17-Construccion] M18: las ampliaciones de la casa usan proyectos de piezas de este módulo [C] <!-- fuente: 17-Construccion/05-Checklist.md -->
280. - [ ] [17-Construccion] M25: ruinas como contenido solo visual (deconstruible = false) [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
281. - [ ] [17-Construccion] M73: recetas de festival temporales en el catálogo (devolucion = 0) [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
282. - [ ] [17-Construccion] M31: faroles y luces conectados al ciclo día/noche [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
283. - [ ] [17-Construccion] M93: proyectos de construcción de meta larga cuentan piezas colocadas [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
284. - [ ] [17-Construccion] Raycast de colocación limitado a 1 por frame con cache de celda [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
285. - [ ] [17-Construccion] Materiales de pieza compartidos entre instancias (static batching de Godot) [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
286. - [ ] [17-Construccion] Presupuesto medido con profiler: preview <= 1 ms por frame (M113) [C] <!-- fuente: 17-Construccion/05-Checklist.md -->
287. - [ ] [17-Construccion] 01-Requerimientos.md creado con problema, RF, NFR y criterios de aceptación [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
288. - [ ] [17-Construccion] 02-Analisis.md creado con resolución de los 28 puntos y decisiones justificadas [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
289. - [ ] [17-Construccion] 03-Diseno.md creado con arquitectura, flujos, contratos API e integraciones [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
290. - [ ] [17-Construccion] 05-Checklist.md creado con 110+ ítems firmados (este archivo) [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
291. - [ ] [17-Construccion] Copias idénticas de los 5 archivos en plan-actual/ para seguimiento futuro [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
292. - [ ] [17-Construccion] Animación de colocación: transición breve fantasma → pieza real (escala/hammer) [C] <!-- fuente: 17-Construccion/05-Checklist.md -->
293. - [ ] [17-Construccion] Partículas de polvo al colocar y demoler (M51: VFX de construcción) [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
294. - [ ] [17-Construccion] Sonido de colocación y de demolición que varía con el material (M43) [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
295. - [ ] [17-Construccion] Sonido ambiental de obras: martilleo suave mientras el modo está activo [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
296. - [ ] [17-Construccion] Aura de validación: destello suave verde al confirmar válido [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
297. - [ ] [17-Construccion] Aviso amable (no punitivo) con vibración sutil al fallar la colocación [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
298. - [ ] [17-Construccion] Los NPC cercanos miran la obra con curiosidad y comentan (M64 reacción cozy) [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
299. - [ ] [17-Construccion] El jugador puede admirar sus construcciones desde la cámara sin salir del modo [S] <!-- fuente: 17-Construccion/05-Checklist.md -->
300. - [ ] [17-Construccion] Tests de integración: colocar → guardar → cargar → restaurar idéntico (M58) [C] <!-- fuente: 17-Construccion/05-Checklist.md -->
301. - [ ] [17-Construccion] Tests de integración: la navmesh se actualiza con puertas y obras (M64) [C] <!-- fuente: 17-Construccion/05-Checklist.md -->
302. - [ ] [17-Construccion] Playtest de construcción (M113) con teclado y mando: flujo completo sin fricción [C] <!-- fuente: 17-Construccion/05-Checklist.md -->
303. - [ ] [17-Construccion] Recorrido M114: construir y decorar la casa del jugador (M18) sin errores de consola [C] <!-- fuente: 17-Construccion/05-Checklist.md -->
304. - [ ] [17-Construccion] QA final: 0 errores en Play Mode, 0 excepciones al entrar/salir del modo repetidamente [M] <!-- fuente: 17-Construccion/05-Checklist.md -->
305. - [x] [61-Rendimiento] Documentar objetivo por preset de calidad (M91) [M] — LOG 2068 (M61 tanda 1): cerrado con dato data-driven en `data/performance/budgets.json` + gate `validate_budget.gd` + suite `tests/test_m61_normas_performance.gd` (39 checks, 0 fallos, EXIT=0) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
306. - [x] [61-Rendimiento] Definir draw calls por escena objetivo [M] — LOG 2068 (M61 tanda 1): cerrado con dato data-driven en `data/performance/budgets.json` + gate `validate_budget.gd` + suite `tests/test_m61_normas_performance.gd` (39 checks, 0 fallos, EXIT=0) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
307. - [x] [61-Rendimiento] Definir control de overdraw (vegetación/sombras) [M] — LOG 2068 (M61 tanda 1): cerrado con dato data-driven en `data/performance/budgets.json` + gate `validate_budget.gd` + suite `tests/test_m61_normas_performance.gd` (39 checks, 0 fallos, EXIT=0) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
308. - [x] [61-Rendimiento] Documentar coste de shaders por material [M] — LOG 2068 (M61 tanda 1): cerrado con dato data-driven en `data/performance/budgets.json` + gate `validate_budget.gd` + suite `tests/test_m61_normas_performance.gd` (39 checks, 0 fallos, EXIT=0) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
309. - [x] [61-Rendimiento] Definir límite de draw calls por chunk [M] — LOG 2068 (M61 tanda 1): cerrado con dato data-driven en `data/performance/budgets.json` + gate `validate_budget.gd` + suite `tests/test_m61_normas_performance.gd` (39 checks, 0 fallos, EXIT=0) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
310. - [x] [61-Rendimiento] Coordinar pausas de GC con M62 [M] — LOG 2068 (M61 tanda 1): cerrado con dato data-driven en `data/performance/budgets.json` + gate `validate_budget.gd` + suite `tests/test_m61_normas_performance.gd` (39 checks, 0 fallos, EXIT=0) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
311. - [x] [61-Rendimiento] Documentar presupuesto de VRAM en bench [M] — LOG 2068 (M61 tanda 1): cerrado con dato data-driven en `data/performance/budgets.json` + gate `validate_budget.gd` + suite `tests/test_m61_normas_performance.gd` (39 checks, 0 fallos, EXIT=0) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
312. - [x] [61-Rendimiento] Definir texturas 4K comprimidas máx (M47) [M] — LOG 2068 (M61 tanda 1): cerrado con dato data-driven en `data/performance/budgets.json` + gate `validate_budget.gd` + suite `tests/test_m61_normas_performance.gd` (39 checks, 0 fallos, EXIT=0) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
313. - [x] [61-Rendimiento] Definir presupuesto de VRAM por escena [M] — LOG 2068 (M61 tanda 1): cerrado con dato data-driven en `data/performance/budgets.json` + gate `validate_budget.gd` + suite `tests/test_m61_normas_performance.gd` (39 checks, 0 fallos, EXIT=0) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
314. - [x] [61-Rendimiento] Definir atlas de UI (M53) [M] — LOG 2068 (M61 tanda 1): cerrado con dato data-driven en `data/performance/budgets.json` + gate `validate_budget.gd` + suite `tests/test_m61_normas_performance.gd` (39 checks, 0 fallos, EXIT=0) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
315. - [x] [61-Rendimiento] Documentar compresión BC/ASTC por plataforma [M] — LOG 2068 (M61 tanda 1): cerrado con dato data-driven en `data/performance/budgets.json` + gate `validate_budget.gd` + suite `tests/test_m61_normas_performance.gd` (39 checks, 0 fallos, EXIT=0) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
316. - [?] [61-Rendimiento] Validar VRAM < presupuesto en GPU mínima [C] — LOG 2068 (M61 tanda 1): degradado a [?] HONESTO — no medible en headless (exige renderer + GPU real / bench scene); ver el motivo por item en `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md` <!-- fuente: 61-Rendimiento/05-Checklist.md -->
317. - [x] [61-Rendimiento] Documentar tamaño máximo de paquete de datos [M] — LOG 2068 (M61 tanda 1): cerrado con dato data-driven en `data/performance/budgets.json` + gate `validate_budget.gd` + suite `tests/test_m61_normas_performance.gd` (39 checks, 0 fallos, EXIT=0) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
318. - [x] [61-Rendimiento] Definir carga asíncrona obligatoria (M63) [S] — LOG 2071 (M61 tanda 2): cerrado con dato data-driven (`carga`/`chunks`/`destruccion`) + gate + suite (58 checks, 0 fallos, EXIT=0), con grounding en las constantes reales de M63 <!-- fuente: 61-Rendimiento/05-Checklist.md -->
319. - [x] [61-Rendimiento] Definir progreso real con mensajes de estado (AGENTS §8) [S] — LOG 2071 (M61 tanda 2): cerrado con dato data-driven (`carga`/`chunks`/`destruccion`) + gate + suite (58 checks, 0 fallos, EXIT=0), con grounding en las constantes reales de M63 <!-- fuente: 61-Rendimiento/05-Checklist.md -->
320. - [x] [61-Rendimiento] Definir bloqueo cero del hilo principal [M] — LOG 2071 (M61 tanda 2): cerrado con dato data-driven (`carga`/`chunks`/`destruccion`) + gate + suite (58 checks, 0 fallos, EXIT=0), con grounding en las constantes reales de M63 <!-- fuente: 61-Rendimiento/05-Checklist.md -->
321. - [x] [61-Rendimiento] Documentar precarga de escena siguiente [M] — LOG 2071 (M61 tanda 2): cerrado con dato data-driven (`carga`/`chunks`/`destruccion`) + gate + suite (58 checks, 0 fallos, EXIT=0), con grounding en las constantes reales de M63 <!-- fuente: 61-Rendimiento/05-Checklist.md -->
322. - [?] [61-Rendimiento] Validar pantalla de carga sin frames congelados [C] — LOG 2068 (M61 tanda 1): degradado a [?] HONESTO — no medible en headless (exige renderer + GPU real / bench scene); ver el motivo por item en `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md` <!-- fuente: 61-Rendimiento/05-Checklist.md -->
323. - [x] [61-Rendimiento] Definir generación en background thread (M07) [M] — LOG 2071 (M61 tanda 2): cerrado con dato data-driven (`carga`/`chunks`/`destruccion`) + gate + suite (58 checks, 0 fallos, EXIT=0), con grounding en las constantes reales de M63 <!-- fuente: 61-Rendimiento/05-Checklist.md -->
324. - [x] [61-Rendimiento] Definir <5 ms/frame consumido por generación [M] — LOG 2071 (M61 tanda 2): cerrado con dato data-driven (`carga`/`chunks`/`destruccion`) + gate + suite (58 checks, 0 fallos, EXIT=0), con grounding en las constantes reales de M63 <!-- fuente: 61-Rendimiento/05-Checklist.md -->
325. - [x] [61-Rendimiento] Definir sin trabajo voxel en main thread [S] — LOG 2071 (M61 tanda 2): cerrado con dato data-driven (`carga`/`chunks`/`destruccion`) + gate + suite (58 checks, 0 fallos, EXIT=0), con grounding en las constantes reales de M63 <!-- fuente: 61-Rendimiento/05-Checklist.md -->
326. - [x] [61-Rendimiento] Documentar cola de chunks con prioridad [M] — LOG 2071 (M61 tanda 2): cerrado con dato data-driven (`carga`/`chunks`/`destruccion`) + gate + suite (58 checks, 0 fallos, EXIT=0), con grounding en las constantes reales de M63 <!-- fuente: 61-Rendimiento/05-Checklist.md -->
327. - [?] [61-Rendimiento] Validar generación con stream continuo (M63) [C] — LOG 2068 (M61 tanda 1): degradado a [?] HONESTO — no medible en headless (exige renderer + GPU real / bench scene); ver el motivo por item en `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md` <!-- fuente: 61-Rendimiento/05-Checklist.md -->
328. - [x] [61-Rendimiento] Definir sin GC en el bucle de interacción [M] — LOG 2071 (M61 tanda 2): cerrado con dato data-driven (`carga`/`chunks`/`destruccion`) + gate + suite (58 checks, 0 fallos, EXIT=0), con grounding en las constantes reales de M63 <!-- fuente: 61-Rendimiento/05-Checklist.md -->
329. - [x] [61-Rendimiento] Definir pooling de buffers de mesh [M] — LOG 2071 (M61 tanda 2): cerrado con dato data-driven (`carga`/`chunks`/`destruccion`) + gate + suite (58 checks, 0 fallos, EXIT=0), con grounding en las constantes reales de M63 <!-- fuente: 61-Rendimiento/05-Checklist.md -->
330. - [x] [61-Rendimiento] Documentar remesh en background (M07) [S] — LOG 2071 (M61 tanda 2): cerrado con dato data-driven (`carga`/`chunks`/`destruccion`) + gate + suite (58 checks, 0 fallos, EXIT=0), con grounding en las constantes reales de M63 <!-- fuente: 61-Rendimiento/05-Checklist.md -->
331. - [?] [61-Rendimiento] Validar destrucción masiva sin picos [C] — LOG 2068 (M61 tanda 1): degradado a [?] HONESTO — no medible en headless (exige renderer + GPU real / bench scene); ver el motivo por item en `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md` <!-- fuente: 61-Rendimiento/05-Checklist.md -->
332. - [x] [61-Rendimiento] Definir LOD de actualización por distancia (M19/M64) [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
333. - [x] [61-Rendimiento] Documentar pooling de instancias NPC [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
334. - [?] [61-Rendimiento] Validar pueblo completo 60 FPS [C] — LOG 2068 (M61 tanda 1): degradado a [?] HONESTO — no medible en headless (exige renderer + GPU real / bench scene); ver el motivo por item en `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md` <!-- fuente: 61-Rendimiento/05-Checklist.md -->
335. - [x] [61-Rendimiento] Definir pooling de partículas (M52) [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
336. - [x] [61-Rendimiento] Definir GPUParticles para larga vida (fuego/lava) [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
337. - [x] [61-Rendimiento] Documentar límite por evento [S] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
338. - [?] [61-Rendimiento] Validar festival (M74) sin picos [C] — LOG 2068 (M61 tanda 1): degradado a [?] HONESTO — no medible en headless (exige renderer + GPU real / bench scene); ver el motivo por item en `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md` <!-- fuente: 61-Rendimiento/05-Checklist.md -->
339. - [x] [61-Rendimiento] Definir sombras dinámicas solo personajes y objetos clave [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
340. - [x] [61-Rendimiento] Definir sombras blended para estáticos [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
341. - [x] [61-Rendimiento] Definir rango de cascada limitado [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
342. - [x] [61-Rendimiento] Documentar costo de sombras por material [S] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
343. - [?] [61-Rendimiento] Validar noche con faroles (M49) 60 FPS [C] — LOG 2068 (M61 tanda 1): degradado a [?] HONESTO — no medible en headless (exige renderer + GPU real / bench scene); ver el motivo por item en `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md` <!-- fuente: 61-Rendimiento/05-Checklist.md -->
344. - [x] [61-Rendimiento] Definir GI suave sin bounce caro (M49) [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
345. - [x] [61-Rendimiento] Definir luz horaria barata (1 directional + sky) [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
346. - [x] [61-Rendimiento] Definir luces real-time minimizadas [S] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
347. - [x] [61-Rendimiento] Documentar lightmap/baked para interiores (M17) [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
348. - [?] [61-Rendimiento] Validar ciclo día/noche sin drop [C] — LOG 2068 (M61 tanda 1): degradado a [?] HONESTO — no medible en headless (exige renderer + GPU real / bench scene); ver el motivo por item en `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md` <!-- fuente: 61-Rendimiento/05-Checklist.md -->
349. - [x] [61-Rendimiento] Definir plano único de agua (M51) [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
350. - [x] [61-Rendimiento] Definir normales animadas en shader (no CPU) [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
351. - [x] [61-Rendimiento] Definir reflejos solo superficie [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
352. - [x] [61-Rendimiento] Documentar transparencia ordenada [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
353. - [?] [61-Rendimiento] Validar mar visible sin overdraw [C] — LOG 2068 (M61 tanda 1): degradado a [?] HONESTO — no medible en headless (exige renderer + GPU real / bench scene); ver el motivo por item en `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md` <!-- fuente: 61-Rendimiento/05-Checklist.md -->
354. - [x] [61-Rendimiento] Definir GPU instancing obligatorio (M50) [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
355. - [x] [61-Rendimiento] Definir viento en vertex shader (no CPU) [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
356. - [x] [61-Rendimiento] Definir culling de vegetación por viento oclusivo [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
357. - [x] [61-Rendimiento] Documentar presupuesto de instancias por chunk [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
358. - [?] [61-Rendimiento] Validar bosque denso 60 FPS [C] — LOG 2068 (M61 tanda 1): degradado a [?] HONESTO — no medible en headless (exige renderer + GPU real / bench scene); ver el motivo por item en `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md` <!-- fuente: 61-Rendimiento/05-Checklist.md -->
359. - [x] [61-Rendimiento] Definir LOD escalonado por distancia [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
360. - [x] [61-Rendimiento] Definir que el mar siempre se ve (cozy) [S] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
361. - [x] [61-Rendimiento] Documentar memoria de chunks por distancia (M62) [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
362. - [?] [61-Rendimiento] Validar preset mínimo 30 FPS [C] — LOG 2068 (M61 tanda 1): degradado a [?] HONESTO — no medible en headless (exige renderer + GPU real / bench scene); ver el motivo por item en `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md` <!-- fuente: 61-Rendimiento/05-Checklist.md -->
363. - [x] [61-Rendimiento] Usar frustum del engine por defecto [S] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
364. - [x] [61-Rendimiento] Definir culling por chunks (M07) [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
365. - [x] [61-Rendimiento] Definir culling de NPC/objetos por distancia [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
366. - [x] [61-Rendimiento] Documentar culling de partículas [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
367. - [?] [61-Rendimiento] Validar culling eficaz en bench [C] — LOG 2068 (M61 tanda 1): degradado a [?] HONESTO — no medible en headless (exige renderer + GPU real / bench scene); ver el motivo por item en `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md` <!-- fuente: 61-Rendimiento/05-Checklist.md -->
368. - [x] [61-Rendimiento] Definir occlusion por celdas de chunks [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
369. - [x] [61-Rendimiento] Aplicar solo en cuevas y templos (M24/M25) [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
370. - [x] [61-Rendimiento] Descartar occlusion global en terreno abierto [S] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
371. - [x] [61-Rendimiento] Documentar coste de GPU queries acotado [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
372. - [?] [61-Rendimiento] Validar templo subterráneo (M25) 60 FPS [C] — LOG 2068 (M61 tanda 1): degradado a [?] HONESTO — no medible en headless (exige renderer + GPU real / bench scene); ver el motivo por item en `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md` <!-- fuente: 61-Rendimiento/05-Checklist.md -->
373. - [x] [61-Rendimiento] Definir impostor lejano (malla simpl. + textura) [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
374. - [x] [61-Rendimiento] Definir LOD de NPC/fauna por distancia [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
375. - [?] [61-Rendimiento] Validar ausencia de pop en cámara principal [C] — LOG 2068 (M61 tanda 1): degradado a [?] HONESTO — no medible en headless (exige renderer + GPU real / bench scene); ver el motivo por item en `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md` <!-- fuente: 61-Rendimiento/05-Checklist.md -->
376. - [ ] [61-Rendimiento] Usar meshes combinados por chunk (M07) [S] <!-- fuente: 61-Rendimiento/05-Checklist.md -->
377. - [x] [61-Rendimiento] Definir batching de estáticos por bioma [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
378. - [x] [61-Rendimiento] Definir límite de materiales por batch [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
379. - [x] [61-Rendimiento] Documentar batching de UI (M53) [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
380. - [?] [61-Rendimiento] Validar draw calls dentro de presupuesto [C] — LOG 2068 (M61 tanda 1): degradado a [?] HONESTO — no medible en headless (exige renderer + GPU real / bench scene); ver el motivo por item en `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md` <!-- fuente: 61-Rendimiento/05-Checklist.md -->
381. - [ ] [61-Rendimiento] Aplicar a vegetación (M50) [M] <!-- fuente: 61-Rendimiento/05-Checklist.md -->
382. - [ ] [61-Rendimiento] Aplicar a rocas y fragmentos (M08) [M] <!-- fuente: 61-Rendimiento/05-Checklist.md -->
383. - [ ] [61-Rendimiento] Aplicar a partículas de larga vida [M] <!-- fuente: 61-Rendimiento/05-Checklist.md -->
384. - [x] [61-Rendimiento] Documentar instancing de peces (M34) [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
385. - [?] [61-Rendimiento] Validar instancing con multimesh de Voxel Tools [C] — LOG 2068 (M61 tanda 1): degradado a [?] HONESTO — no medible en headless (exige renderer + GPU real / bench scene); ver el motivo por item en `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md` <!-- fuente: 61-Rendimiento/05-Checklist.md -->
386. - [ ] [61-Rendimiento] Pooling de partículas (M52) [M] <!-- fuente: 61-Rendimiento/05-Checklist.md -->
387. - [ ] [61-Rendimiento] Pooling de fauna y peces (M35/M34) [M] <!-- fuente: 61-Rendimiento/05-Checklist.md -->
388. - [ ] [61-Rendimiento] Pooling de efectos de herramientas [M] <!-- fuente: 61-Rendimiento/05-Checklist.md -->
389. - [ ] [61-Rendimiento] Pooling de buffers de remesh [M] <!-- fuente: 61-Rendimiento/05-Checklist.md -->
390. - [x] [61-Rendimiento] Validar cero allocations en lazo caliente [C] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
391. - [x] [61-Rendimiento] Definir reuso de Arrays/Variants [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
392. - [x] [61-Rendimiento] Definir GC en pausas seguras (transiciones M63) [M] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
393. - [x] [61-Rendimiento] Verificar con verificar_checklist.py (sin alertas nuevas) [S] — LOG 2073 (M61 tanda 3): cerrado con dato data-driven (13 bloques de tecnicas, RF12..RF26) + gate `_validar_tecnicas()` + suite `test_m61_normas_performance.gd` (88 checks, 0 fallos, EXIT=0); para X390, probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) <!-- fuente: 61-Rendimiento/05-Checklist.md -->
394. - [ ] [70-Interacciones] Registrar dependencias del módulo: M11, M13, M08 [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
395. - [ ] [70-Interacciones] Registrar consumidores del módulo: M19, M21, M33, M35, M36, M65, M18, M14, M17, M22/M24/M26 [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
396. - [ ] [70-Interacciones] Definir el objetivo: una única tecla de interacción con indicador visual y prioridad determinística [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
397. - [ ] [70-Interacciones] Definir fuera de alcance: mecánicas concretas de los consumidores, inventario, diálogos, IA [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
398. - [ ] [70-Interacciones] Establecer restricción cozy: tecla E sin objetivo nunca genera error ni castigo [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
399. - [ ] [70-Interacciones] Establecer restricción de rendimiento: presupuesto de detección < 0.5 ms por frame [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
400. - [ ] [70-Interacciones] RF1: desregistro automático al salir del mundo activo (`_exit_tree`, M63 streaming) [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
401. - [ ] [70-Interacciones] RF2: enumerar las 8 categorías de interacción con prioridad base [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
402. - [ ] [70-Interacciones] RF2: cada categoría define ícono, sonido y etiqueta por defecto [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
403. - [ ] [70-Interacciones] RF3: respetar el rango base del personaje de M11 (4 m) sin excederlo por defecto [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
404. - [ ] [70-Interacciones] RF4: espaciado del raycast de visión (1 por ventana de N=4 frames) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
405. - [ ] [70-Interacciones] RF5: desempate por desviación angular frente del jugador (menor gana) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
406. - [ ] [70-Interacciones] RF5: cambio de objetivo con fade (0.08-0.12 s), nunca salto brusco [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
407. - [ ] [70-Interacciones] RF5: excluir de la selección a los atenuados si hay al menos un objetivo válido [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
408. - [ ] [70-Interacciones] RF13: re-selección inmediata al girar el jugador si la desviación angular cambia el orden [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
409. - [ ] [70-Interacciones] RF19: ordenamiento con k candidatos típico < 8 (k log k barato) [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
410. - [ ] [70-Interacciones] RF6: indicador "E + ícono de categoría" world-space sobre el objetivo [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
411. - [ ] [70-Interacciones] RF6: el indicador flota sobre `obtener_posicion_interaccion()` con suavizado de posición [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
412. - [ ] [70-Interacciones] RF6: línea de contexto en HUD con nombre localizado del objetivo ("Hablar con Mira") [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
413. - [ ] [70-Interacciones] RF20: ícono de tecla según dispositivo activo (teclado E / gamepad A o B, M57) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
414. - [ ] [70-Interacciones] RF6: línea de contexto oculta durante la micro-animación de interacción [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
415. - [ ] [70-Interacciones] RF15: chirrido de interacción por categoría (base de sonido M11/M44) [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
416. - [ ] [70-Interacciones] RF15: partículas opcionales provistas por el consumidor vía señal previa [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
417. - [ ] [70-Interacciones] RF15: feedback diferenciado de éxito (campana suave) y fallo (tono bajo, sin castigo) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
418. - [ ] [70-Interacciones] RF17: validación de herramienta en mano (M13) dentro de `requisitos_cumplidos` [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
419. - [ ] [70-Interacciones] RF17: validación de item seleccionado en inventario (M14) para regalos [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
420. - [ ] [70-Interacciones] RF17: validación de hora/día (M29/M31) para puertas y cosechas de temporada [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
421. - [ ] [70-Interacciones] RF17: validación de nivel de amistad (M20) para interacciones sociales [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
422. - [ ] [70-Interacciones] RF25: pausa de procesamiento al pausar el juego (ProcessMode correcto) [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
423. - [ ] [70-Interacciones] RF25: gestión de la señal de modal abierto (M53/M57) -> estado DORMIDO [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
424. - [ ] [70-Interacciones] RF12: log M103 si el consumidor no responde a la cancelación [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
425. - [ ] [70-Interacciones] RF13: cambio de objetivo por reorden de prioridad sin parpadeo (histéresis) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
426. - [ ] [70-Interacciones] RF14: re-evaluar automáticamente al cerrar la UI en el siguiente frame [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
427. - [ ] [70-Interacciones] RF23: cancelación de zona de trigger si el jugador sale antes de activar [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
428. - [ ] [70-Interacciones] RF12: verificar que no queden señales colgadas (objetivo_perdido) tras cancelar [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
429. - [ ] [70-Interacciones] RF15: feedback sonoro unificado por categoría (chirrido de madera/metal/animal) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
430. - [ ] [70-Interacciones] RF15: las partículas del consumidor se reproducen vía señal, no las dibuja el gestor [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
431. - [ ] [70-Interacciones] RF15: sonido de "nadie cerca" mínimo y amable (opcional, bajo volumen) [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
432. - [ ] [70-Interacciones] RF15: textos de feedback 100% localizables con `tr()` [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
433. - [ ] [70-Interacciones] RN-rendimiento: raycast de visión espaciado (N=4) y acotado por categoría [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
434. - [ ] [70-Interacciones] RN-localización: todo texto visible pasa por `tr()` [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
435. - [ ] [70-Interacciones] RN-persistencia: `GameState.M70` con esquema acotado y escritura diferida [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
436. - [ ] [70-Interacciones] RN-voxel: línea de visión compatible con Voxel Tools (VoxelTool de M08) [C] <!-- fuente: 70-Interacciones/05-Checklist.md -->
437. - [ ] [70-Interacciones] Diseñar las 6 señales de salida del módulo [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
438. - [ ] [70-Interacciones] M11: leer posición, frente y estado FSM del jugador (inyección) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
439. - [ ] [70-Interacciones] M11: pasar a DORMIDO si el jugador está ocupado (dormir, cutscene, minijuego) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
440. - [ ] [70-Interacciones] M11: respetar el rango base de interacción de 4 m del personaje [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
441. - [ ] [70-Interacciones] M08: integrar VoxelTool para la línea de visión (bloqueo por voxel sólido) [C] <!-- fuente: 70-Interacciones/05-Checklist.md -->
442. - [ ] [70-Interacciones] M13: validar requisitos de herramienta dentro de `requisitos_cumplidos` [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
443. - [ ] [70-Interacciones] M19: `set_ocupado(true)` -> NO_DISPONIBLE con razón ("Duerme", "Ocupado") [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
444. - [ ] [70-Interacciones] M19: migrar la burbuja world-space de vecinos al indicador del 70 (sin duplicados) [C] <!-- fuente: 70-Interacciones/05-Checklist.md -->
445. - [ ] [70-Interacciones] M21: apertura de diálogo al E sin UI propia en el 70 [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
446. - [ ] [70-Interacciones] M20: regalo al E con item seleccionado de M14 y validación de amistad [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
447. - [ ] [70-Interacciones] M33: recoger cosechas maduras al E [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
448. - [ ] [70-Interacciones] M14: abrir cofres con estado persistente (abierto) en GameState.M70 [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
449. - [ ] [70-Interacciones] M18: abrir/cerrar puertas al E; bloqueo por llave con razón [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
450. - [ ] [70-Interacciones] M65: acariciar/alimentar animales al E con factor de ánimo [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
451. - [ ] [70-Interacciones] M35/M46: recoger recursos cosechables al E (objeto) [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
452. - [ ] [70-Interacciones] M22/M24/M26: activar triggers/cutscenes al E o por zona [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
453. - [ ] [70-Interacciones] M103: logging estructurado de errores de contrato, degradaciones y timeouts [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
454. - [ ] [70-Interacciones] Varios objetos juntos a la misma distancia: gana prioridad de categoría [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
455. - [ ] [70-Interacciones] Dos objetos idénticos superpuestos: se ordena por registro y nunca alterna [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
456. - [ ] [70-Interacciones] Jugador se aleja durante una interacción en curso: cancelación suave [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
457. - [ ] [70-Interacciones] Jugador gira 180 grados con dos objetos equidistantes: cambia por desviación angular [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
458. - [ ] [70-Interacciones] Pausa a mitad de interacción: DORMIDO, al reanudar continúa sin glitches [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
459. - [ ] [70-Interacciones] Cooldown de puerta y tecla E en auto-repeat: no se re-abre fuera de cooldown [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
460. - [ ] [70-Interacciones] Filtro de distancia con producto punto al cuadrado, sin sqrt en el paso rápido [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
461. - [ ] [70-Interacciones] Espaciado del raycast de línea de visión (N=4 frames) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
462. - [ ] [70-Interacciones] Pool del indicador world-space (sin instancias/destrucciones por frame) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
463. - [ ] [70-Interacciones] Evitar allocaciones de Arrays en el hot path (reuso de buffers) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
464. - [ ] [70-Interacciones] Ordenamiento solo sobre candidatos pre-filtrados (k < 8) [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
465. - [ ] [70-Interacciones] Escritura de persistencia diferida y por lote (cada 0.5 s como máximo) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
466. - [ ] [70-Interacciones] Verificación del presupuesto < 0.5 ms/frame con el profiler en escena densa [C] <!-- fuente: 70-Interacciones/05-Checklist.md -->
467. - [ ] [70-Interacciones] Documentar métricas de referencia para LOD de detección en zonas muy pobladas [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
468. - [ ] [70-Interacciones] Crear 01-Requerimientos.md con problema, objetivos, alcance, restricciones, RF y RN [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
469. - [ ] [70-Interacciones] Crear 02-Analisis.md con análisis del dominio, categorías, alternativas y decisiones D1-D7 [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
470. - [ ] [70-Interacciones] Crear 03-Diseno.md con arquitectura, nodos, contrato, flujos y rendimiento [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
471. - [ ] [70-Interacciones] Crear 05-Checklist.md con 130+ ítems verificables [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
472. - [ ] [70-Interacciones] Documentar la integración con M11/M13/M19 y demás consumidores en 03-Diseno.md [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
473. - [ ] [70-Interacciones] Documentar la regla de unificación de tecla (E vs F histórica) como pendiente para M57 [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
474. - [ ] [70-Interacciones] Definir escenario "esquina": objetivo tras pared voxel con categoría de visión [C] <!-- fuente: 70-Interacciones/05-Checklist.md -->
475. - [ ] [70-Interacciones] Definir escenario "cosecha": 30 plantas maduras en fila sin parpadeo [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
476. - [ ] [70-Interacciones] Definir escenario "puerta bloqueante": E repetida durante interacción en curso [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
477. - [ ] [70-Interacciones] Definir escenario "streaming": alta/baja de zona con M63 sin referencias colgadas [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
478. - [ ] [70-Interacciones] Plan de tests de determinismo: misma entrada -> misma selección (assert en Edit Mode) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
479. - [ ] [70-Interacciones] Plan de tests de persistencia: cofre abierto, puerta y animal acariciado sobreviven sesión [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
480. - [ ] [70-Interacciones] Plan de pruebas de cancelación: distancia, UI, pausa y cambio de objetivo [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
481. - [ ] [70-Interacciones] Plan de pruebas de input: teclado E, gamepad A/B, remapeo y auto-repeat [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
482. - [ ] [70-Interacciones] Plan de pruebas de localización: nombres y razones traducibles sin cortes de layout [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
483. - [ ] [20-Sistema-De-Amistad] Definir el problema: relaciones significativas con vecinos sin castigo por ausencia [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
484. - [ ] [20-Sistema-De-Amistad] Registrar dependencias: M19, M14, M29; relaciones M21, M23, M26, M31, M32, M73 [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
485. - [ ] [20-Sistema-De-Amistad] Catalogar los 26 puntos de la seccion 19 del plan maestro [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
486. - [ ] [20-Sistema-De-Amistad] RF1: niveles de amistad 0-10 con umbrales [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
487. - [ ] [20-Sistema-De-Amistad] RF2: puntos de amistad acumulativos sin fuente de decaimiento [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
488. - [ ] [20-Sistema-De-Amistad] RF3: limite de un regalo efectivo por vecino y dia [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
489. - [ ] [20-Sistema-De-Amistad] RF4-RF8: preferencias, charlas, cartas, recompensas y eventos definidos [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
490. - [ ] [20-Sistema-De-Amistad] Curva de umbrales por nivel definida (20, 40, 70, 100, 140, 190, 250, 320, 400, 500) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
491. - [ ] [20-Sistema-De-Amistad] Regalo amado 20 puntos [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
492. - [ ] [20-Sistema-De-Amistad] Regalo que gusta 10 puntos [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
493. - [ ] [20-Sistema-De-Amistad] Regalo neutral 5 puntos [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
494. - [ ] [20-Sistema-De-Amistad] Regalo duplicado 2 puntos (cortesia, nunca 0) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
495. - [ ] [20-Sistema-De-Amistad] Charla diaria 5 + 1 por nivel (max +10) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
496. - [ ] [20-Sistema-De-Amistad] Carta respondida 8 puntos [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
497. - [ ] [20-Sistema-De-Amistad] Evento como participante 15 puntos [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
498. - [ ] [20-Sistema-De-Amistad] Capacidad para definir nombres de nivel: Conocido, Amigo, Confidente, Mejor amigo [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
499. - [ ] [20-Sistema-De-Amistad] Acceso a eventos por nivel minimo [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
500. - [ ] [20-Sistema-De-Amistad] Desbloqueo de historias de amistad al nivel requerido (M23) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
501. - [ ] [20-Sistema-De-Amistad] Excedente de puntos conservado al subir de nivel [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
502. - [ ] [20-Sistema-De-Amistad] Bandeja de recompensas pendientes sin expiracion [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
503. - [ ] [20-Sistema-De-Amistad] Recompensas reclamables en cualquier momento posterior (sin FOMO) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
504. - [ ] [20-Sistema-De-Amistad] Progress visible: barra de progreso dentro del nivel actual [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
505. - [ ] [20-Sistema-De-Amistad] Feedback de nivel subido con animacion y lista de desbloqueos [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
506. - [ ] [20-Sistema-De-Amistad] Coste de evaluacion menor a 1 ms por regalo [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
507. - [ ] [20-Sistema-De-Amistad] Registro de 1 charla efectiva por vecino y dia [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
508. - [x] [20-Sistema-De-Amistad] Puntos base + bonus por nivel de confianza [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md --> — LOG 2118: cerrado con checks nombrados (charla nivel1 = 5 pts / nivel5 = 5+4) + codigo (friendship_service.gd L542: puntos := 5 + mini(nivel-1, 10))
509. - [ ] [20-Sistema-De-Amistad] El vecino menciona recuerdos (primer regalo, cumpleanos celebrado) [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
510. - [ ] [20-Sistema-De-Amistad] Charla no consume regalo diario (independiente) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
511. - [ ] [20-Sistema-De-Amistad] Sin charla repetida con los mismos puntos en el mismo dia [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
512. - [ ] [20-Sistema-De-Amistad] Mensaje discreto de UI cuando la charla del dia ya se realizo [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
513. - [ ] [20-Sistema-De-Amistad] Textos de cartas y respuestas por vecino en data [C] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
514. - [ ] [20-Sistema-De-Amistad] FriendshipEvent como Resource: tipo, nivel minimo, dia, hora, lugar, puntos [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
515. - [ ] [20-Sistema-De-Amistad] Tipos soportados: visita, picnic, reunion, cumpleanos, festival (M73) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
516. - [ ] [20-Sistema-De-Amistad] Requisito de nivel minimo verificado antes de convocar [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
517. - [ ] [20-Sistema-De-Amistad] Franja horaria validada contra el reloj M29 [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
518. - [ ] [20-Sistema-De-Amistad] Lugar validado contra POI del mundo (M19/M08) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
519. - [ ] [20-Sistema-De-Amistad] Puntos otorgados a todos los participantes [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
520. - [ ] [20-Sistema-De-Amistad] Registro del evento en la memoria del vecino (recuerdo) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
521. - [ ] [20-Sistema-De-Amistad] Eventos sin obligacion: el jugador puede declinar sin penalizacion [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
522. - [ ] [20-Sistema-De-Amistad] Decision documentada: Alternativa B (acumulativa) en 02-Analisis.md [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
523. - [ ] [20-Sistema-De-Amistad] Los vecinos no registrados no existen en el servicio [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
524. - [ ] [20-Sistema-De-Amistad] Alta desregistro de vecino: al mudarse se conserva el historial para futuro reencuentro [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
525. - [x] [20-Sistema-De-Amistad] Memoria del vecino alimentada por interacciones destacadas [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md --> — LOG 2120: cerrado con checks nombrados
526. - [ ] [20-Sistema-De-Amistad] Rutinas y horarios de M19 intactos (M20 no modifica IA) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
527. - [ ] [20-Sistema-De-Amistad] Cambios de rutina sociales (visitar al mejor amigo) habilitados por data [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
528. - [ ] [20-Sistema-De-Amistad] Sin acoplamiento con componentes de navegacion ni FSM [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
529. - [ ] [20-Sistema-De-Amistad] Metadatos de item consultados sin modificar M14 [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
530. - [ ] [20-Sistema-De-Amistad] Extraccion del item al regalar integrada [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
531. - [ ] [20-Sistema-De-Amistad] Insercion de objetos de recompensa al reclamar [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
532. - [ ] [20-Sistema-De-Amistad] Recetas desbloqueadas por nivel van a la tabla de crafting [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
533. - [ ] [20-Sistema-De-Amistad] Adjuntos de carta usados y recibidos correctamente [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
534. - [ ] [20-Sistema-De-Amistad] Items decorativos de recompensa marcados como regalo valido [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
535. - [ ] [20-Sistema-De-Amistad] Misiones de amistad consultan nivel minimo [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
536. - [ ] [20-Sistema-De-Amistad] Misiones consultan memoria del vecino (recuerdos) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
537. - [ ] [20-Sistema-De-Amistad] Bonus de puntos al completar historia secundaria [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
538. - [ ] [20-Sistema-De-Amistad] Recompensas exclusivas por historia [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
539. - [ ] [20-Sistema-De-Amistad] Cierre de historia crea recuerdo permanente [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
540. - [ ] [20-Sistema-De-Amistad] Sin bucles: amistad 10 no bloquea historias pendientes [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
541. - [ ] [20-Sistema-De-Amistad] Schema versionado y migracion al cargar (M26) [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
542. - [ ] [20-Sistema-De-Amistad] Vecinos nuevos agregados al schema sin romper guardados previos [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
543. - [ ] [20-Sistema-De-Amistad] Regalo duplicado con puntos minimos y mensaje amable [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
544. - [ ] [20-Sistema-De-Amistad] Vecino ausente de la isla (viaje, M69): regalo rechazado con aviso [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
545. - [ ] [20-Sistema-De-Amistad] Vecino que se muda: historial archivado, sistema no falla [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
546. - [ ] [20-Sistema-De-Amistad] Inventario vacio: opcion regalar deshabilitada con tooltip [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
547. - [ ] [20-Sistema-De-Amistad] Carta sin texto seleccionado: validacion [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
548. - [ ] [20-Sistema-De-Amistad] Evento convocado con participante ausente: se omite con aviso [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
549. - [x] [20-Sistema-De-Amistad] Doble click en reclamar recompensa: idempotente [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md --> — LOG 3001: check "reclamar_recompensa: inserta y marca reclamada"
550. - [ ] [20-Sistema-De-Amistad] Dia cambiado a mitad de accion (medianoche M29): limites recien recalculados [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
551. - [ ] [20-Sistema-De-Amistad] Guardado corrupto del modulo: fallback a estado vacio sin crash [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
552. - [ ] [20-Sistema-De-Amistad] Evaluador sin allocations relevantes (diccionarios reutilizados) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
553. - [ ] [20-Sistema-De-Amistad] Indice de vecinos por id para consultas O(1) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
554. - [ ] [20-Sistema-De-Amistad] Bandeja de recompensas bajo demanda (no refresco continuo) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
555. - [ ] [20-Sistema-De-Amistad] Logs de debug desactivados en release (conditional symbols) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
556. - [ ] [20-Sistema-De-Amistad] Panel de vecino con nivel, puntos y barra de progreso [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
557. - [ ] [20-Sistema-De-Amistad] HUD de limite diario (regalo, charla, carta) [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
558. - [ ] [20-Sistema-De-Amistad] Popup de reaccion del vecino al regalo [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
559. - [ ] [20-Sistema-De-Amistad] Bandeja de correo y recompensas con contador no intrusivo [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
560. - [ ] [20-Sistema-De-Amistad] Animacion de nivel subido con desbloqueos listados [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
561. - [ ] [20-Sistema-De-Amistad] Tooltips en items de regalo con pista de gustos descubiertos [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
562. - [ ] [20-Sistema-De-Amistad] Accesibilidad: textos legibles, contraste, opcion de texto lento [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
563. - [ ] [20-Sistema-De-Amistad] Frases de despedida segun nivel ("hasta manana, amigo") [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
564. - [ ] [20-Sistema-De-Amistad] Recuerdos hablados: el vecino comenta el primer regalo [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
565. - [ ] [20-Sistema-De-Amistad] Pequenos regalos de retorno del vecino por correo [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
566. - [ ] [20-Sistema-De-Amistad] Reacciones suaves y nunca hostiles por parte del vecino [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
567. - [ ] [20-Sistema-De-Amistad] Coherencia de tono: el NPC nunca rechaza con dureza [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
568. - [ ] [20-Sistema-De-Amistad] Eventos con ambiente acogedor (sonido ambiente, luz calida) [C] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
569. - [ ] [20-Sistema-De-Amistad] Test: regalo amado/gusta/neutral/duplicado devuelve puntos esperados [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
570. - [x] [20-Sistema-De-Amistad] Test: limite diario respetado para regalo, charla y carta [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md --> — LOG 2120: cerrado con checks nombrados
571. - [ ] [20-Sistema-De-Amistad] Test: excedente conservado al subir de nivel [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
572. - [ ] [20-Sistema-De-Amistad] Test: ausencia de 30 dias no reduce puntos (sin FOMO) [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
573. - [x] [20-Sistema-De-Amistad] Test: guardar/cargar a mitad de nivel restaura exacto [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md --> — LOG 2120: cerrado con checks nombrados
574. - [x] [20-Sistema-De-Amistad] Test: reclamar recompensa idempotente [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md --> — LOG 3001: check "reclamar_recompensa: inserta y marca reclamada"
575. - [ ] [20-Sistema-De-Amistad] Recorrido M114: 10 vecinos a nivel 5+ en sesiones simuladas sin fallos [C] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
576. - [ ] [20-Sistema-De-Amistad] 01-Requerimientos creado y firmado [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
577. - [ ] [20-Sistema-De-Amistad] 02-Analisis creado y firmado (alternativas y decision) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
578. - [ ] [20-Sistema-De-Amistad] 03-Diseno creado y firmado (arquitectura y contratos) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
579. - [ ] [20-Sistema-De-Amistad] 04-Codigo creado y firmado (rutas, firmas, Notas del Agente) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
580. - [ ] [20-Sistema-De-Amistad] 05-Checklist creado y firmado (este archivo) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
581. - [ ] [142-Release-Candidate] Definir minutas firmadas de cada decisión del comité [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
582. - [ ] [142-Release-Candidate] Definir freeze firmado de features al inicio de RC [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
583. - [ ] [142-Release-Candidate] Definir política: solo hotfixes P0/P1 aprobados entran al RC [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
584. - [ ] [142-Release-Candidate] Definir rama de hotfix `hotfix/rc-N` con test de regresión obligatorio (M112) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
585. - [ ] [142-Release-Candidate] Definir re-etiquetado `rc-2`, `rc-3` ante cada hotfix [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
586. - [ ] [142-Release-Candidate] Definir DiffAudit en CI (contra `beta-rc-candidate`) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
587. - [ ] [142-Release-Candidate] Definir fallo de CI si hay diffs no autorizados [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
588. - [ ] [142-Release-Candidate] Definir ventana de 4 semanas máx. para la fase [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
589. - [ ] [142-Release-Candidate] Definir manifest de contenido inamovible (hash del inventario Beta) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
590. - [ ] [142-Release-Candidate] Definir prohibición de nuevo contenido (misiones, ítems, eventos) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
591. - [ ] [142-Release-Candidate] Definir excepción de contenido solo si es bug crítico de progresión [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
592. - [ ] [142-Release-Candidate] Definir registro de cambios de contenido en el manifest [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
593. - [ ] [142-Release-Candidate] Definir verificación semanal del estado del freeze [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
594. - [ ] [142-Release-Candidate] Definir definición de crash/bloqueo (P0) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
595. - [ ] [142-Release-Candidate] Definir definición de pérdida de progreso (P1) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
596. - [ ] [142-Release-Candidate] Definir definición de P2 (menor, con workaround) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
597. - [ ] [142-Release-Candidate] Definir flujo de ticket P0/P1 → comité → hotfix [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
598. - [ ] [142-Release-Candidate] Definir hotfix con test de regresión previo al merge (M112) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
599. - [ ] [142-Release-Candidate] Definir postmortem obligatorio por hotfix [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
600. - [ ] [142-Release-Candidate] Definir cola de P2 documentada para la primera actualización post-lanzamiento [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
601. - [ ] [142-Release-Candidate] Definir métrica de hotfixes por semana [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
602. - [ ] [142-Release-Candidate] Definir símbolos de crash accesibles al handler (M105) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
603. - [ ] [142-Release-Candidate] Definir comprobación de assets de desarrollo (texturas/audio placeholder) fuera [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
604. - [ ] [142-Release-Candidate] Definir prueba de instalación desde cero en cada plataforma (VM limpia) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
605. - [ ] [142-Release-Candidate] Definir verificación de arranque sin errores tras instalación limpia [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
606. - [ ] [142-Release-Candidate] Definir prueba de desinstalación/reinstalación sin residuos [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
607. - [ ] [142-Release-Candidate] Definir verificación de carpetas de datos correctas por plataforma [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
608. - [ ] [142-Release-Candidate] Definir prueba de instalación en disco con sín caracteres especiales [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
609. - [ ] [142-Release-Candidate] Definir prueba de actualización Beta → RC sin pérdida de datos [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
610. - [ ] [142-Release-Candidate] Definir prueba de actualización de RC-1 a RC-2 (delta) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
611. - [ ] [142-Release-Candidate] Definir verificación de versión de save reportada como compatible [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
612. - [ ] [142-Release-Candidate] Definir registro de logs de actualización (éxito/fallo) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
613. - [ ] [142-Release-Candidate] Definir rollback seguro si la actualización falla [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
614. - [ ] [142-Release-Candidate] Definir prueba de actualización con red cortada a mitad [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
615. - [ ] [142-Release-Candidate] Definir migración de save v3.x a versión RC sin pérdidas [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
616. - [ ] [142-Release-Candidate] Definir carga de saves de todas las fases previas (pre-Alpha a Beta) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
617. - [ ] [142-Release-Candidate] Definir prueba de save corrupto → backup y recuperación (M66) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
618. - [ ] [142-Release-Candidate] Definir reporte de versión de save en el manifiesto del usuario [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
619. - [ ] [142-Release-Candidate] Definir verificación de que no hay saves con flags de dev activos [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
620. - [ ] [142-Release-Candidate] Definir métrica de errores de save en piloto [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
621. - [ ] [142-Release-Candidate] Definir 30 ciclos de sincronización con latencia simulada [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
622. - [ ] [142-Release-Candidate] Definir resolución de conflicto "último ganador + backup" [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
623. - [ ] [142-Release-Candidate] Definir validación de integridad antes de aplicar el save cloud [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
624. - [ ] [142-Release-Candidate] Definir desconexión/reconexión de red durante sincronización [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
625. - [ ] [142-Release-Candidate] Definir batalla de saves entre dos dispositivos (prueba) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
626. - [ ] [142-Release-Candidate] Definir reporte de errores de cloud sin reviente de UI [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
627. - [ ] [142-Release-Candidate] Definir telemetría de tamaño y frecuencia de sync [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
628. - [ ] [142-Release-Candidate] Definir matriz completa hitos → logros [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
629. - [ ] [142-Release-Candidate] Definir desbloqueo local de logros sin dependencia de red [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
630. - [ ] [142-Release-Candidate] Definir verificación de persistencia de logros tras reinicio [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
631. - [ ] [142-Release-Candidate] Definir verificación de notificación de logro visible [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
632. - [ ] [142-Release-Candidate] Definir logros retroactivos para saves Beta [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
633. - [ ] [142-Release-Candidate] Definir prueba de plataforma sin login (sin cuenta) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
634. - [ ] [142-Release-Candidate] Definir 100% de logros alcanzables en juego limpio [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
635. - [ ] [142-Release-Candidate] Definir matriz de 6 idiomas × pantallas clave [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
636. - [ ] [142-Release-Candidate] Definir verificación de desbordes de texto por idioma (UI) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
637. - [ ] [142-Release-Candidate] Definir verificación de traducción de logros y store (M149) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
638. - [ ] [142-Release-Candidate] Definir verificación de fechas/números por idioma [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
639. - [ ] [142-Release-Candidate] Definir fallback a EN sin claves rotas [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
640. - [ ] [142-Release-Candidate] Definir perf de ruta fija 20 min en hardware mínimo [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
641. - [ ] [142-Release-Candidate] Definir perf de ruta fija 20 min en recomendado [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
642. - [ ] [142-Release-Candidate] Definir memoria dentro de M62 en las 6 islas [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
643. - [ ] [142-Release-Candidate] Definir tiempos de carga/streaming dentro de M63 [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
644. - [ ] [142-Release-Candidate] Definir FPS p99 ≥ objetivo en sesiones largas (60+ min) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
645. - [ ] [142-Release-Candidate] Definir batching/draw calls finales por zona [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
646. - [ ] [142-Release-Candidate] Definir informe de rendimiento del piloto (percentiles reales) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
647. - [ ] [142-Release-Candidate] Definir comparativa final mínima vs recomendada [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
648. - [ ] [142-Release-Candidate] Definir objetivo crash rate < 0.5% de sesiones [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
649. - [ ] [142-Release-Candidate] Definir piloto de 1000 sesiones con invitados [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
650. - [ ] [142-Release-Candidate] Definir handler de crashes con stacktrace y símbolos (M105) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
651. - [ ] [142-Release-Candidate] Definir triaje de crash stacks conocidos vs nuevos [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
652. - [ ] [142-Release-Candidate] Definir hotfix dirigido si crash rate no baja a objetivo [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
653. - [ ] [142-Release-Candidate] Definir reporte final de crash rate del piloto [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
654. - [ ] [142-Release-Candidate] Definir verificación de que los crashes no bloquean saves/cloud [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
655. - [ ] [142-Release-Candidate] Definir revisión de políticas de contenido (violencia/edad) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
656. - [ ] [142-Release-Candidate] Definir prueba de certificación: instalación, actualización, saves [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
657. - [ ] [142-Release-Candidate] Definir aprobación firmada por responsable de plataforma [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
658. - [ ] [142-Release-Candidate] Definir registro de desvíos y excepciones aprobadas [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
659. - [ ] [142-Release-Candidate] Definir preparación de los paquetes de certificación (textos, archivos) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
660. - [ ] [142-Release-Candidate] Definir términos de servicio final [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
661. - [ ] [142-Release-Candidate] Definir política de privacidad final (cloud, telemetría) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
662. - [ ] [142-Release-Candidate] Definir atribuciones de assets de terceros completas [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
663. - [ ] [142-Release-Candidate] Definir clasificación etaria (ESRB/PEGI) con documentos [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
664. - [ ] [142-Release-Candidate] Definir contratos de voz/música con derechos despejados (M41-M44) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
665. - [ ] [142-Release-Candidate] Definir revisión legal firmada [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
666. - [ ] [142-Release-Candidate] Definir verificación de no contenido ofensivo por región (M147) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
667. - [ ] [142-Release-Candidate] Definir store page publicada-ready (textos, capturas, tags) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
668. - [ ] [142-Release-Candidate] Definir tráiler final montado y aprobado [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
669. - [ ] [142-Release-Candidate] Definir comunicado de prensa final en 2 idiomas [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
670. - [ ] [142-Release-Candidate] Definir kit de medios (capturas HQ, logos, b-roll) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
671. - [ ] [142-Release-Candidate] Definir plan de contenido de redes para día 0 y semana 1 [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
672. - [ ] [142-Release-Candidate] Definir lista de reviewers/streamers contactados [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
673. - [ ] [142-Release-Candidate] Definir verificación de disponibilidad de la página (fecha oculta hasta día 0) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
674. - [ ] [142-Release-Candidate] Definir canales de soporte (foros, Discord, correo) activos [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
675. - [ ] [142-Release-Candidate] Definir FAQ publicada (instalación, saves, plataformas, idiomas) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
676. - [ ] [142-Release-Candidate] Definir SLA de respuesta definido (24 h hábiles) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
677. - [ ] [142-Release-Candidate] Definir triaje diario de soporte en lanzamiento [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
678. - [ ] [142-Release-Candidate] Definir camino de escalado de bugs de soporte a tracker [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
679. - [ ] [142-Release-Candidate] Definir backup de canales (quién cubre a quién) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
680. - [ ] [142-Release-Candidate] Definir cronograma día 0 con horas locales por región [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
681. - [ ] [142-Release-Candidate] Definir responsables de cada tarea del día 0 [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
682. - [ ] [142-Release-Candidate] Definir runbook de incidentes (crash masivo, store caída, cloud) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
683. - [ ] [142-Release-Candidate] Definir holgura de 48 h ante imprevistos [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
684. - [ ] [142-Release-Candidate] Definir aprobación final del plan por el equipo [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
685. - [ ] [142-Release-Candidate] Definir verificación de accesos de plataforma (quién puede publicar) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
686. - [ ] [142-Release-Candidate] Definir respaldo de credenciales sin compartir secretos en repo [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
687. - [ ] [28-Viajes] Definir el problema: desplazamiento cozy entre islas con el Gran Vapor [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
688. - [ ] [28-Viajes] Catalogar los 25 puntos de la sección 27 del plan maestro [S] <!-- fuente: 28-Viajes/05-Checklist.md -->
689. - [ ] [28-Viajes] RF1: boleto y reserva con capacidad del vapor [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
690. - [ ] [28-Viajes] RF3: travesía visible entre 20 y 60 segundos [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
691. - [ ] [28-Viajes] RF4: llegada con atraque automático y desembarque suave [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
692. - [ ] [28-Viajes] RF5: viaje rápido costoso vía M69 [S] <!-- fuente: 28-Viajes/05-Checklist.md -->
693. - [ ] [28-Viajes] NFR: cozy, sin soft-locks, accesibilidad, guardado M58 [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
694. - [ ] [28-Viajes] P2: diseño del barco — Gran Vapor con cubierta navegable y chimenea [C] <!-- fuente: 28-Viajes/05-Checklist.md -->
695. - [ ] [28-Viajes] P3: diseño del dirigible — vehículo opcional de contenido tardío, no bloqueante [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
696. - [ ] [28-Viajes] P4: diseño del submarino — vehículo opcional de expediciones, no bloqueante [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
697. - [ ] [28-Viajes] P5: diseño del boleto — objeto comprado en M38, consumible por viaje [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
698. - [ ] [28-Viajes] P10: diseño de la transición — fade de 0.5 s al desembarcar y al viaje rápido [S] <!-- fuente: 28-Viajes/05-Checklist.md -->
699. - [ ] [28-Viajes] P11: diseño de la llegada — atraque, pasarela y aparición en el muelle [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
700. - [ ] [28-Viajes] P12: diseño de efectos de clima — olas, balanceo, lluvia y niebla en travesía [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
701. - [ ] [28-Viajes] P13: diseño del calendario — ventanas de salida del vapor según M29 [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
702. - [ ] [28-Viajes] P16: diseño de viajes nocturnos — ambientación con faroles y cielo estrellado [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
703. - [ ] [28-Viajes] P17: diseño de viajes estacionales — decorados y música por estación [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
704. - [ ] [28-Viajes] P18: diseño de eventos en el trayecto — umbrales de progreso con NPC y diálogos [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
705. - [ ] [28-Viajes] P19: diseño de objetos coleccionables del viaje — ítems visibles junto a la ruta [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
706. - [ ] [28-Viajes] P20: diseño de NPC viajeros — pasajeros con rutinas breves a cubierta [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
707. - [ ] [28-Viajes] P21: diseño de transporte de recursos — almacén del vapor con capacidad limitada [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
708. - [ ] [28-Viajes] P22: diseño de almacenamiento — inventario del barco separado del jugador [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
709. - [ ] [28-Viajes] P23: definición de restricciones — un viaje activo, destinos desbloqueados, horarios [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
710. - [ ] [28-Viajes] P24: definición de costes — boleto, viaje rápido y devoluciones en M38 [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
711. - [ ] [28-Viajes] P25: definición de desbloqueos — rutas progresivas ligadas a M22 y M70 [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
712. - [ ] [28-Viajes] Balanceo y cabeceo suaves según weather_factor [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
713. - [ ] [28-Viajes] Estela de partículas (WakeFX) activa solo en SAILING [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
714. - [ ] [28-Viajes] Humo de chimenea con puffs periódicos (M51) [S] <!-- fuente: 28-Viajes/05-Checklist.md -->
715. - [ ] [28-Viajes] Silbato del vapor al zarpar y al atracar (M42) [S] <!-- fuente: 28-Viajes/05-Checklist.md -->
716. - [ ] [28-Viajes] Teleport a punto de curva para restaurar guardado (M58) [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
717. - [ ] [28-Viajes] Curva Curve3D baked para trayectoria estable por el mar [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
718. - [ ] [28-Viajes] sample_position(t) con interpolación sobre longitud baked [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
719. - [ ] [28-Viajes] compute_duration_with_weather con tope máximo de 90 segundos [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
720. - [ ] [28-Viajes] Bandera is_secret y is_night_line para líneas especiales [S] <!-- fuente: 28-Viajes/05-Checklist.md -->
721. - [ ] [28-Viajes] Reserva temprana del dock de destino al zarpar [M] — pendiente integración M27 (islas reales con Harbour) <!-- fuente: 28-Viajes/05-Checklist.md -->
722. - [ ] [28-Viajes] Fallback de restore: ruta desconocida devuelve al muelle de origen [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
723. - [ ] [28-Viajes] Botón de cancelar visible hasta zarpar [S] — dueño M53 <!-- fuente: 28-Viajes/05-Checklist.md -->
724. - [ ] [28-Viajes] Confirmación explícita del coste del viaje rápido (M69) [S] — dueño M69 <!-- fuente: 28-Viajes/05-Checklist.md -->
725. - [ ] [28-Viajes] Notificación de devolución tras cancelar [S] — iter. 2: show_refund_notice(coins) con auto-cerrar 2s <!-- fuente: 28-Viajes/05-Checklist.md -->
726. - [ ] [28-Viajes] set_interactive(false) durante transiciones (sección 8 AGENTS.md) [S] — iter. 2: _set_interactivo disponible; M53 consumirá <!-- fuente: 28-Viajes/05-Checklist.md -->
727. - [ ] [28-Viajes] Flujo completo: embarque, travesía y llegada de punta a punta [C] <!-- fuente: 28-Viajes/05-Checklist.md -->
728. - [ ] [28-Viajes] Flujo de llegada con muelle libre y atraque directo [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
729. - [ ] [28-Viajes] Flujo de llegada con muelle ocupado: espera animada de hasta 10 s [C] <!-- fuente: 28-Viajes/05-Checklist.md -->
730. - [ ] [28-Viajes] Flujo de cancelación antes del embarque con devolución del 100 % [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
731. - [ ] [28-Viajes] Flujo de cancelación en cubierta con devolución del 50 % [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
732. - [ ] [28-Viajes] Flujo de clima adverso: retraso visible, zarpe garantizado [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
733. - [ ] [28-Viajes] Flujo nocturno con ambientación y faroles activos [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
734. - [ ] [28-Viajes] Flujo de expedición secreta con ruta is_secret [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
735. - [ ] [28-Viajes] M32: consulta del estado del clima para calcular retraso sin bloqueo [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
736. - [ ] [28-Viajes] M69: viaje rápido con puntos desbloqueados, coste alto y visita previa [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
737. - [ ] [28-Viajes] M63: precarga de la isla destino al confirmar el boleto [C] <!-- fuente: 28-Viajes/05-Checklist.md -->
738. - [ ] [28-Viajes] M63: liberación de la isla origen al zarpar [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
739. - [ ] [28-Viajes] M29: ventanas de salida y líneas nocturnas según el reloj [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
740. - [ ] [28-Viajes] M38: pago de boleto, viaje rápido y devoluciones [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
741. - [ ] [28-Viajes] M58: guardado y restauración a mitad de travesía [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
742. - [ ] [28-Viajes] M50: estela y boyantez sobre agua decorativa sin colisiones [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
743. - [ ] [28-Viajes] Llegada con muelle ocupado: espera visible, nunca soft-lock [C] <!-- fuente: 28-Viajes/05-Checklist.md -->
744. - [ ] [28-Viajes] Cancelación con boleto consumido: devolución calculada correcta [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
745. - [ ] [28-Viajes] Clima extremo: retraso máximo aplicado y zarpe garantizado [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
746. - [ ] [28-Viajes] Doble pulsación de abordar: exclusividad de estado lo descarta [S] <!-- fuente: 28-Viajes/05-Checklist.md -->
747. - [ ] [28-Viajes] Reserva duplicada del mismo destino: segundo intento rechazado [S] <!-- fuente: 28-Viajes/05-Checklist.md -->
748. - [ ] [28-Viajes] Insuficiencia de monedas: aviso sin cobro parcial [S] <!-- fuente: 28-Viajes/05-Checklist.md -->
749. - [ ] [28-Viajes] Fallo de streaming del destino (M63): espera en cubierta con mensaje [C] <!-- fuente: 28-Viajes/05-Checklist.md -->
750. - [ ] [28-Viajes] Guardado durante SAILING: restaura en el punto medio de la curva [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
751. - [ ] [28-Viajes] Jugador fuera del barco al zarpar: reubicación automática a cubierta [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
752. - [ ] [28-Viajes] Precarga de la escena destino durante la travesía (M63) [C] <!-- fuente: 28-Viajes/05-Checklist.md -->
753. - [ ] [28-Viajes] Travesía con tope de 90 s para limitar tiempo de streaming [S] <!-- fuente: 28-Viajes/05-Checklist.md -->
754. - [ ] [28-Viajes] Pool de partículas de estela y humo sin instancias dinámicas [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
755. - [ ] [28-Viajes] Culling de la isla origen al alejarse de su puerto [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
756. - [ ] [28-Viajes] Cache de nodos en _ready, sin get_node en bucles [S] <!-- fuente: 28-Viajes/05-Checklist.md -->
757. - [ ] [28-Viajes] Budget de frame menor o igual a 16 ms durante la travesía [C] <!-- fuente: 28-Viajes/05-Checklist.md -->
758. - [ ] [28-Viajes] Sin alocaciones en el bucle de progreso de la ruta [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
759. - [ ] [28-Viajes] Opción de accesibilidad: travesía acelerada a la mitad del tiempo [S] <!-- fuente: 28-Viajes/05-Checklist.md -->
760. - [ ] [28-Viajes] Sonido de olas según weather_factor (M41) [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
761. - [ ] [28-Viajes] Silbato del vapor al zarpar y atracar (M42) [S] <!-- fuente: 28-Viajes/05-Checklist.md -->
762. - [ ] [28-Viajes] Gaviotas y ambiente de puerto en el muelle [S] <!-- fuente: 28-Viajes/05-Checklist.md -->
763. - [ ] [28-Viajes] Lluvia y nieve en cubierta con partículas (M51) [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
764. - [ ] [28-Viajes] Faroles y luces cálidas en línea nocturna [M] <!-- fuente: 28-Viajes/05-Checklist.md -->
765. - [ ] [28-Viajes] Confirmación visual de llegada con banner del nombre de la isla [S] <!-- fuente: 28-Viajes/05-Checklist.md -->
766. - [ ] [28-Viajes] Diálogo amable del capitán al retrasar por clima [S] <!-- fuente: 28-Viajes/05-Checklist.md -->

## Progreso (actualizado 2026-10-21 05:20 — minimax-m3-1-flash)

| Modulo | Pendientes antes | Hechos ([x]) | Degradados ([?]) | Pendientes ahora |
|---|---|---|---|---|
| 73-Coleccionables | 106 | 0 | 0 | 106 |
| 142-Release-Candidate | 106 | 0 | 0 | 106 |
| 72-Sistema-De-Logros | 105 | 0 | 0 | 105 |
| 20-Sistema-De-Amistad | 98 | 0 | 0 | 98 |
| 17-Construccion | 93 | 0 | 0 | 93 |
| 61-Rendimiento | 89 | **65** | **16** | 8 |
| 70-Interacciones | 89 | 0 | 0 | 89 |
| 28-Viajes | 80 | 0 | 0 | 80 |
| **TOTAL** | **766** | **65** | **16** | **685** |

**Tandas 1-3 (Logs 2068 / 2071 / 2073, 2026-10-21 05:20-06:40) — M61 Rendimiento:** 12 items cerrados con dato data-driven
(`gpu` / `memoria` / `normas.objetivo_por_preset` en `data/performance/budgets.json`), 5 validadores
nuevos en `validate_budget.gd` y suite nueva `tests/test_m61_normas_performance.gd` (**39 checks, 0
fallos, EXIT=0**, con prueba en ROJO que detecta la deriva contra M90). Los 16 items `[C] Validar
... 60 FPS / sin picos` quedaron degradados a `[?]` con motivo explicito (no son medibles en headless).
Conteo del modulo: 76 [x] / 50 [ ] / 22 [?] = 148 (total canonico del modulo, sin cambio).
**Tanda 2 (Log 2071):** bloques `carga` (RF9) / `chunks` (RF10) / `destruccion` (RF11) con grounding en
las constantes reales de M63 (`PISO_PROGRESO` 0.02, `TOPE_PROGRESO` 0.98, `PRESUPUESTO_MS` 40,
`PESOS` 7 tipos, `MAX_CHUNKS_DEFAULT` 4096, `FRAMES_ENVEJECIDO` 2) + 3 validadores del gate + suite
**39 -> 58 checks** (0 fallos, EXIT=0) + 11 flips.

**Tanda 3 (Log 2073):** 13 bloques de norma nuevos (64 umbrales) para las secciones L..Y (RF12..RF26) con grounding en las constantes reales de M52/M49/M64/M51/M50/M90/M63/M62/M09; gate `_validar_tecnicas()` + tabla canonica que congela los 64 umbrales; suite 58 -> **88 checks** (0 fallos, EXIT=0) + probe propio `test_m61_allocations_hotloop.gd` (8 checks, 0 fallos) para el item de allocations en el lazo caliente. **42 flips.** M61 queda en **118/148** (65 [x] hechos, 16 [?] degradados honestos, 8 [ ] que son implementacion de otros modulos: M07/M50/M08/M52/M35/M34).

## M112-Testing-Automatico (encargo directo del director, msg 6 del canal — 2026-10-21)

- [x] Testear patrones de M111 (state machine, observer, factory) [M] — LOG 2078: suite `tests/test_m111_patrones_cobertura.gd` (14 checks, 0 fallos) + guarda de cobertura
- [x] Testear biome y terreno con seed fijo [C] — LOG 2078: suite `tests/test_terrain_biome_seed_fijo.gd` (14 checks, 0 fallos)
- [x] Testear que fallbacks de M122 responden ante datos invalidos [M] — LOG 2078: suite `tests/test_m122_fallbacks_datos_invalidos.gd` (56 checks, 0 fallos)
- [?] Cumplir tiempo total de suite <= 10 minutos [C] — LOG 2078: MEDIDO 897.0 s vs 600 s; 5 suites esperan ~60 s en headless; fix propuesto (topes headless-aware + paralelizar GdUnit4)

**M112: 216/225 -> 221/225.** Los 6 [?] restantes: 3 de cobertura (sin runner headless en GdUnit4 6.2.1 — deuda de tooling), 2 de tiempo de suite (1 aqui + el item espejo), 1 de maquina limpia (CI real, dueno M118).

**DIAGNOSTICO P1 (2026-10-21 21:20, Log 2086):** el costo de las 5 suites lentas de M112 NO son las esperas de frames sino la SALIDA FINAL DEL MOTOR (2.8 s sin escena vs 101.9 s con escena; el script termina en 1.3 s). Causa: el guardado asincrono incluye el mundo voxel en binario (DataStore._guardar_voxel_binario) y al salir se hace wait_to_finish() -> ~60 s. Es bug de producto (cerrar el juego con el mundo voxel cargado tarda ~1 min). Fix: no guardar el mundo voxel en tests (o flag --no-save) + paralelizar las 4 carpetas GdUnit4 -> 897 s -> ~300 s. El fix 'topes 30 frames' aprobado queda documentado como NO recuperador de tiempo.
**P1 CERRADO (Log 2090, 2026-10-21 22:55):** pool paralelo de 6 workers + **aislamiento de `user://` por worker** en `tests/run_tests.gd` -> tiempo total de suite **897.0 s -> 545.3 s (9.09 min)**, presupuesto 600 s CUMPLE; cobertura sin perdida (2441 -> 2462 tests) y contrato de salida del runner intacto (CI sin tocar). Hallazgo: el rojo de `integration/test_crafting_inventory.gd` (3 checks) era contaminacion del `user://` compartido, no un bug de crafting (con aislamiento la suite pasa); el unico rojo que queda es `tests/test_iconos_m159.gd` (TIMEOUT, preexistente, riel M159).
**P2 (QA de M90, Log 2091, 2026-10-21 23:35):** verificador EXTERNO. Muestreo 13/13 items respaldados contra disco (verificacion a nivel de VALOR: cascadas=1, res=512, escala=0.5, mipmap=0, aniso 2/4/8/16, FPS 30/60/120/0, VSync 0/1/2, 720p=1280x720, 4k=3840x2160) + 2 suites en VERDE (85/0 y 57/0) -> **VEREDICTO: SELLO VALIDO** (0 fallas materiales; el sello es del director, yo no me auto-sello). 1 NOTA para el dueno de M90: el item L82-L84 cita distancias pre-rework 10x (50/100 m) y la implementacion vigente es DISTANCIA por calidad 300/600/1200/2500 m -> deriva de TEXTO, no de codigo. Leccion propia: 2 corridas de mi checker dieron falsos positivos (buscaba comillas en numeros y `:=` en consts tipados) -> un verificador debe re-verificar sus propias fallas contra el artefacto.

## M17-Construccion (encargo directo del director msg 8/13/17 — frente P3, 2026-10-21)

**Fuente:** `DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md` (93 [ ] accionables, sin dueno habilitado; solo lo headless-verificable, assets/3D fuera de alcance).

- [x] RF2: rejilla voxel de 1 m alineada al mundo con snapping de 90 grados [S] — LOG 2092: suite `tests/test_m17_construccion_validacion.gd`
- [x] RF8: validacion de ocupacion, soporte y reglas por pieza [S] — LOG 2092: las 8 reglas del validador con su motivo
- [x] P3: grid — rejilla voxel de 1 m alineada al origen global de M08 [S] — LOG 2092: celda (0,0,0) -> (0.5,0.5,0.5)
- [x] P4: snapping — ajuste de posicion y rotacion (90) a la celda mas cercana [S] — LOG 2092: floor + 4 rotaciones
- [x] P14: objetos invalidos — toda regla fallida bloquea la colocacion con motivo [S] — LOG 2092: ok=false + motivos[]
- [x] Las piezas de NxN celdas ocupan exactamente su area completa en la rejilla [M] — LOG 2092: pieza 2x2 = 4 celdas
- [x] Limites de mundo: la colocacion se rechaza fuera del AABB jugable de M08 [M] — LOG 2092: FUERA_DEL_MUNDO

**Tanda P3 (Log 2092):** suite nueva en el runner central (**44 checks, 0 fallos**) + fix del suite rojo de M17 (piso 24 vs 22 -> se agregan 2 checks reales). M17 pasa de 81/175 a 88/175. Pendientes: 86 [ ] (los que exigen mundo, assets/3D o UI con viewport quedan fuera de mi alcance headless).

**Tanda P3-2 (Log 2093):** auditoria de las 8 suites de M17 (496 checks): 7 verdes + 1 roja arreglada AGREGANDO 2 checks (piso 22 vs 20). 6 items [x] con cita:
- [x] RF3 [S] — LOG 2093: checks nombrados de las suites de M17 (iter2: "el fantasma arranca oculto" / "tras aplicar, el fantasma esta )
- [x] RF4 [S] — LOG 2093: checks nombrados de las suites de M17 ("3x1 en rot 0 -> 3 celdas hacia +x" / "3x1 en rot 90 -> 3 celdas hacia)
- [x] RF6 [S] — LOG 2093: checks nombrados de las suites de M17 (los 4 permisos con control positivo y negativo: "sin zonas -> EDIFICAB)
- [x] RF7 [S] — LOG 2093: checks nombrados de las suites de M17 ("costo descontado: 10-2=8 (dio 8)" (el descuento real en M14) + iter2 )
- [x] RF12-RF14 [S] — LOG 2093: checks nombrados de las suites de M17 (iter2 "las 12 familias estan presentes (dio 12)" + "FAMILIAS tiene 12 )
- [x] P9 [S] — LOG 2093: checks nombrados de las suites de M17 ("recolocar en la misma celda -> rechazado" + "undo_ultimo devuelve la )
**M17: 94/175.** Pendiente: llevar las 8 suites de M17 al runner central (no corren en CI).

**CENSO (Log 2096, 2026-10-21 21:10):** extendi el descubrimiento de M17 a TODO el proyecto: de 471 suites, solo **49** las descubre el runner central (`res://tests/`); las **422** restantes nunca corrieron en CI. Ejecutadas una por una (6 workers, APPDATA aislado, timeout 45 s): **387 verdes · 13 EN ROJO · 22 TIMEOUT**. Las 13 rojas invisibles estan listadas en el log y en mi acuse 024 (derivan a sus duenos; 2 son el patron "piso > checks" de M17 y se arreglan AGREGANDO checks). Herramienta reejecutable en `scripts/auditar_suites_fuera.py`. Proximo paso: que el runner central tambien ejecute `scripts/<modulo>/test_*.gd` (con la deteccion estatica conservadora del pool).

**M17 en el circuito central (Log 2097):** wrapper `tests/test_m17_suites_integracion.gd` (NUEVO, en res://tests/ -> el runner lo descubre solo) que ejecuta las 7 suites de `scripts/construccion/` y agrega su resultado: **17 checks, 0 fallos, 498 checks de M17 verificados**. Pendiente: re-medir el tiempo total de la suite central con el wrapper dentro (si pasa de 600 s, paralelizar los 7 hijos dentro del wrapper).

**Runner descubre suites de modulo (Log 2101):** `tests/run_tests.gd` ahora descubre `scripts/<modulo>/test_*.gd` (SceneTree) con la deteccion estatica conservadora (pool si no escribe `user://` ni lanza `OS.execute`; serie si no). Delta: 434 suites descubiertas (antes 47), 237 OK / 7 rojos / 0 timeouts — **los rojos invisibles ahora se ven en el CI**. **LANE OPT-IN (00:58):** la lane de suites de modulo queda APAGADA por defecto (env `M112_INCLUIR_MODULOS=1` o flag `--incluir-modulos` la activan) para no romper el presupuesto de 600 s ya medido (545.3 s); verificado: default 42 suites en el pool, con la env 374. Pendiente: medir el tiempo total con la lane activa (o correrla como paso aparte del CI).

**Lane voxel serial (Log 2102):** el runner clasifica en 3 lanes (POOL / LANE VOXEL en serie / SERIE) con deteccion estatica por fuente (VoxelTerrain/VoxelViewer/main_island). **El CI paso de 46/47 (1 timeout) a 49/49 en VERDE y MAS RAPIDO: 545.3 s -> 530.6 s (8.84 min)** — la lane voxel serial resolvio el ultimo rojo (`test_iconos_m159.gd`) porque en serie deja de competir por los hilos del GDExtension. Delta medido de la lane de modulos (opt-in): 435 suites, **12.284 tests (4.9x)**, 1787.2 s (29.79 min) y **13 rojos visibles**.

**Lane serie explicita (Log 2103):** las 2 suites que dangaban TIMEOUT en la lane opt-in (`scripts/vehiculos/test_vehiculos.gd` y `tests/unit/ui/test_inventory_unificado.gd`) salen del POOL a una lane SERIE explicita: no son voxel (no pagan el deinit) sino **frame-heavy** (`for i in range(N): await process_frame`); con 6 workers la tasa de frames se desploma y el tope de 300 s se agota. Pool: 355 -> 353. Lista **medida**, no heuristica.

**CI desbloqueado (Log 2104):** `scripts/foto/photo_service.gd` estaba COMMITEADO roto (2 errores de parseo: `env` duplicado en `tomar_foto()` y `ms` usado antes de declararse) -> el error salia en CADA corrida del CI y `test_m56_tomar_foto` fallaba. Fixes quirurgicos (el parseo; la logica es del dueno del modulo): parsea OK y la suite pasa **26 checks / 0 fallos**. El lane serie explicita de las 2 suites frame-heavy quedo implementado en el runner (pool 355 -> 353).

**Re-medida lane opt-in (Log 2108):** los **2 timeouts CAEN** (test_vehiculos, test_inventory_unificado: ya no fallan) y **m56 tambien cae** (fix de parseo). Pero el lane opt-in resulto **FLAKY**: 3 timeouts nuevos que aislados pasan en ~3 s, y la composicion de los 13 fallos **cambia entre corridas** -> con 6 workers el pool satura la maquina. El lane opt-in queda como **radar, no gate**; el gate sigue siendo la lane por defecto (49/49 verde, 530.6 s). Bug real detectado: `test_fixtures_smoke.gd` -> **ACCESS VIOLATION (crash nativo, rc=-1073741795)**, derivado a su dueno.

**M17 tanda 4 (Log 2109):** P7 (copia) y P11 (demolicion) cerradas con checks NOMBRADOS de las 7 suites de M17 (496 checks auditables). M17 97/175 -> 99/175. En 04-Codigo queda el mapa de lo que sigue abierto con el motivo exacto (P6/P16 sin regla de alturas; P10 el codigo devuelve el 50% y el item dice "sin perdidas"; P23 sin catalogo en la ruta citada; P15 el validator es logico; P22 sin suite; P21/P27 de otros modulos).

**QA de M16 (Log 2110):** verificador EXTERNO de M16-Crafting (no soy la implementadora): muestra de 12 items por verbos de creacion (minimo 9), verificados a nivel de VALOR contra disco -> **11 de 12 respaldados**; **11/11 suites de M16 verdes**; **VEREDICTO: SELLO VALIDO con 1 item inflado** (L44 "animacion de entrega": 0 hits en todo el ambito M16) -> derivado al dueno. Ademas: `test_crafting_inventory.gd` figuraba entre los 13 rojos de la lane opt-in pero **aislada pasa 21/0** -> no es bug de M16, es el artefacto de carga (dato corregido).

**QA de M10 (Log 2112):** verificador EXTERNO de M10-Generacion-Del-Mundo: muestra de 6 items (minimo 5) verificados contra disco -> **1 falla material: L66 (boton debug "Regenerar mundo" NO tiene implementacion)**; ademas la **suite esta ROJA (rc=1)** por el bioma `beach` con **0 muestras** en el muestreo determinista (no es flapping: el generador si define `beach` pero las posiciones muestreadas no lo alcanzan) -> coherente con los `[?]` que el propio modulo ya declara (L43, L120) -> la suite es mas estricta que el contrato adjudicado. Ademas `AnimationService` ya no existe en Godot 4.7.

**Falsos positivos del opt-in (Log 2113):** los 3 timeouts de la lane opt-in (`test_player_cableado_m11`, `test_playtest_m114`, `test_time_calendar`) **aislados pasan** (rc=0) -> son artefactos de carga, no bugs: junto con `test_crafting_inventory` (21/0) son **4 de los 13 "rojos" del radar que no existen**. Derivado a sus duenos para que no gasten tiempo. Confirma (4o caso) que la lane opt-in es RADAR, nunca gate.

**Cierre del frente opt-in (Log 2116):** las 13 suites rojas del radar opt-in, **aisladas**: **12 artefactos de carga** (rc=0 en 3-4 s) + **1 bug real determinista** (`test_generacion_m10_atria`: bioma `beach` = 0 muestras). El AV de `fixtures_smoke` **no se reproduce aislado** (71 s verde) -> BUG-144 solo se manifiesta con la maquina saturada. Los duenos de M117/M21/M74/M94/VFX/M11/M114/M06/M89/tiempo **no tienen nada que arreglar**. Frente opt-in CERRADO.

**M20 tanda 4 (Log 2124):** con el criterio estricto (todas las palabras del claim en UN check nombrado), de los 68 pendientes de M20 **0 items califican** -> los 68 **no estan cubiertos por los 77 checks existentes**. No los cierro a la fuerza (seria la inflacion prohibida). Propuesta al director: **escribir los tests que faltan** (mi nicho) y de paso llevar las suites de M20 a `res://tests/` para que entren al CI central (hoy viven en `scripts/friendship/`, fuera del circuito).

**M20 entra al CI central (Log 2126):** wrapper nuevo `tests/test_m20_amistad_suites.gd`: las 3 suites de M20 (79 checks) pasan a correr en el runner central (antes vivian en `scripts/friendship/`, fuera de `res://tests/`, y no se ejecutaban en ningun gate). Verificado: 8 checks, 0 fallos, rc=0. Con esto la propuesta de "escribir los tests que faltan" para los 68 pendientes de M20 se puede hacer entrando directo al CI.
