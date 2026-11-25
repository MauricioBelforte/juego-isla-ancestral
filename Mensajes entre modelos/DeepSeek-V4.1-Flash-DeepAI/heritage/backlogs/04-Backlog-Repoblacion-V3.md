# DS-V4.1-Flash-Opencode — REPOBLACION V3: items reales de 05-Checklist (M62/M15/M147/M158)
**Fuente:** BACKLOG-MASTER.md DS-V4.1-Flash-Opencode (sección dividida 4nov por fundador)
**Modelo:** DS-V4.1-Flash-Opencode (DeepSeek V4.1 Flash / OpenCode)
**Plataforma:** OpenCode
**Estado:** Mixto

## REPOBLACION V3 (2026-10-19T00:02:03) — items REALES de 05-Checklist (fuente en comentario)

1. - [ ] [62] Ciclos entre servicios evitados con weakref o getters directos (sin referencias circulares) [C] — **iter. 4 (Log 1112): SIGUE ABIERTO, y ahora hay evi <!-- fuente: 62-Memoria/05-Checklist.md -->
2. - [ ] [62] Sesión de referencia: 30 min de juego sin drift > 5% sobre la línea base [C] <!-- fuente: 62-Memoria/05-Checklist.md -->
3. - [ ] [62] RN3: memoria estable: sesión de 30 min con drift < 5% sobre baseline [C] <!-- fuente: 62-Memoria/05-Checklist.md -->
4. - [ ] [62] Generación de mallas en hilos (M08): resultados por cola sin copias extra [C] <!-- fuente: 62-Memoria/05-Checklist.md -->
5. - [ ] [62] Los diffs y ediciones del jugador (M08) no retienen historial infinito en RAM [M] <!-- fuente: 62-Memoria/05-Checklist.md -->
6. - [ ] [62] Al mover el anillo (M12/M63) se descargan los chunks del borde antes de cargar nuevos [M] <!-- fuente: 62-Memoria/05-Checklist.md -->
7. - [ ] [62] Bancos de audio por bioma (M42) cargados al entrar y descargados al salir de la región [M] <!-- fuente: 62-Memoria/05-Checklist.md -->
8. - [ ] [62] Pistas largas (música M41, ASMR M44) reproducidas por streaming, no en RAM completa [C] <!-- fuente: 62-Memoria/05-Checklist.md -->
9. - [ ] [62] Streams `.ogg` liberados de caché cuando ningún reproductor los usa [M] <!-- fuente: 62-Memoria/05-Checklist.md -->
10. - [ ] [62] Los buses (M91) no retienen streams detenidos [S] <!-- fuente: 62-Memoria/05-Checklist.md -->
11. - [ ] [62] Cambio de bioma: descarga del banco anterior diferida 1 frame (no corta transiciones) [M] <!-- fuente: 62-Memoria/05-Checklist.md -->
12. - [ ] [62] Prueba: 30 min con clima cambiante (M32) sin crecimiento de memoria de audio [C] <!-- fuente: 62-Memoria/05-Checklist.md -->
13. - [ ] [62] Leer los presupuestos definitivos de M61 antes de fijar los topes duros del 62 [S] <!-- fuente: 62-Memoria/05-Checklist.md -->
14. - [ ] [62] Sin doble carga del mismo recurso (ResourceCache + cola M63 con un solo dueño) [M] <!-- fuente: 62-Memoria/05-Checklist.md -->
15. - [ ] [62] Teleport (M69/M28): drift-check obligatorio tras cada viaje largo [M] <!-- fuente: 62-Memoria/05-Checklist.md -->
16. - [x] [62] Preset Baja en isla pequeña (M27): carga priorizada y descarga agresiva de viajeros [M] — **duplicado de 121, cerrado en Tanda 76 (2026-10-20, DS-Opencode)**: mecanismo ya implementado por DeepSeek Log 2021, gate 13/0 + M27 171/0/238/0; deuda de feed runtime M27 declarada. <!-- fuente: 62-Memoria/05-Checklist.md -->
17. - [x] [62] Memoria al límite durante tormenta máxima: degrada con aviso y el juego sigue jugable [M] — **duplicado de 122, cerrado en Tanda 77 (2026-10-20, DS-Opencode)**: arnés de DeepSeek Log 2033 14/0; TORMENTA real, semáforo 1→2→3, enforcement 3, Player movible; deuda 60 fps/assets declarada. <!-- fuente: 62-Memoria/05-Checklist.md -->
18. - [?] [62] Baseline menú principal: objetivo < 600 MB [S] — **duplicado de 123, Tanda 78 (2026-10-20, DS-Opencode): NO MEDIBLE**, no existe escena de menú (main_scene=main_island.tscn; 0/4 candidatos). No se inventa baseline. <!-- fuente: 62-Memoria/05-Checklist.md -->
19. - [x] [62] Baseline spawn de Aurora: objetivo < 1.600 MB [S] — **duplicado de 124, Tanda 79 (2026-10-20, DS-Opencode): 189.9 MB total estimado con renderer real** (static 145.6 + VRAM 44.3), 0 huérfanos; 11.9% del objetivo. <!-- fuente: 62-Memoria/05-Checklist.md -->
20. - [x] [62] Baseline horizonte terrestre oteado: objetivo < 2.200 MB [S] — **duplicado de 125, Tanda 80 (2026-10-20, DS-Opencode): 192.4 MB total estimado con renderer real**, cámara 20 m, 0 huérfanos; 8.7% del objetivo. <!-- fuente: 62-Memoria/05-Checklist.md -->
21. - [?] [62] Baseline subterráneo del templo (M26): objetivo < 2.000 MB [S] — **duplicado de 126, Tanda 81 (2026-10-20, DS-Opencode): NO MEDIBLE**, no hay templo/API; VoxelTerrain 0 bloques; 155.9 MB no es baseline. <!-- fuente: 62-Memoria/05-Checklist.md -->
22. - [?] [62] Baseline tormenta máxima (M32) + banco de audio completo: ≤ 2.500 MB (Alta) [S] — **duplicado de 127, Tanda 82 (2026-10-20, DS-Opencode): memoria 196.7 MB total estimado (7.9% de 2500), banco sintético 3 MB; banco real NO existe (0 assets/M42)**. <!-- fuente: 62-Memoria/05-Checklist.md -->
23. - [x] [62] Test Play Mode: drift-check de 30 min sin teleport con drift ≤ 5% [C] — **duplicado de 128, Tanda 83 (2026-10-20, DS-Opencode): T72 30 min, 359 muestras, drift +0.1%, 0 teleports, EXIT 0.** <!-- fuente: 62-Memoria/05-Checklist.md -->
24. - [x] [62] Test Play Mode: cambio de bioma de audio sin crecimiento de memoria [M] — **duplicado de 129, Tanda 84 (2026-10-20, DS-Opencode): 45 checks/0 fallos, 0 bancos vivos, objetos 4477→4477, T72 memoria plana; Log 2055.** <!-- fuente: 62-Memoria/05-Checklist.md -->
25. - [x] [62] Test Play Mode: excavar y regenerar 500 bloques sin leaks de buffers voxel [C] — **duplicado de 130, Tanda 85 (2026-10-20, DS-Opencode): 500/500 ops, 0 buffers vivos, +0.0% memoria, sonda roja EXIT 1; Log 2056.** <!-- fuente: 62-Memoria/05-Checklist.md -->
26. - [x] [62] Test Play Mode: máximo de chunks cargados sin superar el presupuesto voxel [M] — **duplicado de 131, Tanda 86 (2026-10-20, DS-Opencode): 6/0, budget 650 MB, 8.4 KB/chunk, tope 4.096, sonda roja EXIT 1; Log 2057.** <!-- fuente: 62-Memoria/05-Checklist.md -->
27. - [?] [62] Test en preset Baja con 4 GB de RAM: sesión completa sin OOM y jugable [C] — **duplicado de 132, Tanda 87 (2026-10-20, DS-Opencode): NO MEDIBLE (sin hardware 4 GB ni simulador OOM; headless no prueba jugabilidad); parcial: Baja 1.500 MB, 13/0, T72 178.2 MB; Log 2059.** <!-- fuente: 62-Memoria/05-Checklist.md -->
28. - [ ] [15] Catálogo con def_id duplicado: error claro en editor [S] <!-- fuente: 15-Recursos/05-Checklist.md -->
29. - [ ] [15] Pooling de partículas de recolección (una ráfaga por evento) [M] <!-- fuente: 15-Recursos/05-Checklist.md -->
30. - [ ] [15] Métricas de draw calls y RigidBody en zonas densas (M61) [C] <!-- fuente: 15-Recursos/05-Checklist.md -->
31. - [ ] [15] Frame budget de `_aplicar_presupuesto` en tramos (no todo en 1 frame) [C] <!-- fuente: 15-Recursos/05-Checklist.md -->
32. - [ ] [15] Sin dependencia de orden de carga entre módulos (M29 primero) [M] <!-- fuente: 15-Recursos/05-Checklist.md -->
33. - [ ] [15] Texto/popup suave de cantidad obtenida al recolectar [M] <!-- fuente: 15-Recursos/05-Checklist.md -->
34. - [ ] [15] Indicador visual de herramienta requerida al acercarse al nodo [M] <!-- fuente: 15-Recursos/05-Checklist.md -->
35. - [ ] [15] Reloj/calendario muestra "en <estación> vuelven los <recurso>" [M] <!-- fuente: 15-Recursos/05-Checklist.md -->
36. - [ ] [15] Test: recolectar cada tipo con herramienta correcta e incorrecta [M] <!-- fuente: 15-Recursos/05-Checklist.md -->
37. - [ ] [15] Test: los 6 tipos producen drops correctos y cantidades en rango [M] <!-- fuente: 15-Recursos/05-Checklist.md -->
38. - [ ] [15] Test: agotar 50 árboles y verificar respawn estacional [M] <!-- fuente: 15-Recursos/05-Checklist.md -->
39. - [ ] [15] Test: suelo saturado genera bolsa y no pierde nada [M] <!-- fuente: 15-Recursos/05-Checklist.md -->
40. - [ ] [15] Test: determinismo entre dos cargas con mismo seed [M] <!-- fuente: 15-Recursos/05-Checklist.md -->
41. - [ ] [15] Test: presupuesto con región densa (200+ candidatos) [C] <!-- fuente: 15-Recursos/05-Checklist.md -->
42. - [ ] [15] Test: cobertura de edge cases de la sección M [M] <!-- fuente: 15-Recursos/05-Checklist.md -->
43. - [ ] [15] Recorrido M114: 3 días de juego, el jugador siempre tiene material [C] <!-- fuente: 15-Recursos/05-Checklist.md -->
44. - [ ] [15] Test de onboarding: primer recurso recolectado en los primeros 5 minutos [M] <!-- fuente: 15-Recursos/05-Checklist.md -->
45. - [ ] [15] Profiler M113: picos de frames con 60 drops y 30 partículas simultáneos [C] <!-- fuente: 15-Recursos/05-Checklist.md -->
46. - [ ] [15] Módulo marcado delegable (tras M08/M13) [S] <!-- fuente: 15-Recursos/05-Checklist.md -->
47. - [ ] [147] Definir reglas de formato de datos `## DATA { }` [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
48. - [ ] [147] Definir origen de Aurora y su nombre previo [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
49. - [ ] [147] Definir qué sabe el jugador nuevo de Aurora (capa 0-1) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
50. - [ ] [147] Definir historia de la Isla Verde (cultivos, jardineros) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
51. - [ ] [147] Definir historia de la Isla de las Cenizas (catástrofe) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
52. - [ ] [147] Definir origen de los Arquitectos [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
53. - [ ] [147] Definir tecnología que construyó templos y Sellos [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
54. - [ ] [147] Definir legado jugable: templos (M24/M26), drones, herramientas únicas (M13) [C] <!-- fuente: 147-World-Building/05-Checklist.md -->
55. - [ ] [147] Definir origen de los Jardineros [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
56. - [ ] [147] Definir el "idioma del viento" (pistas ambientales, M148) [C] <!-- fuente: 147-World-Building/05-Checklist.md -->
57. - [ ] [147] Definir su dispersión (no murieron: se dispersaron) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
58. - [ ] [147] Definir legado jugable: semillas sagradas, festivales de siembra [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
59. - [ ] [147] Definir conexión con el terreno voxel y sismos (M09/M12) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
60. - [ ] [147] Definir conexión con las herramientas únicas (M13/M26) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
61. - [ ] [147] Definir conexión con los Sellos (M153) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
62. - [ ] [147] Definir la verdad de Elysia (capa 4) sin spoilers tempranos [C] <!-- fuente: 147-World-Building/05-Checklist.md -->
63. - [ ] [147] Definir su rol en la Era del Alba (post-final) [C] <!-- fuente: 147-World-Building/05-Checklist.md -->
64. - [ ] [147] Definir biografía de Finneas (guía, capa 1) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
65. - [ ] [147] Definir biografía de Bruno (arco, capa 2) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
66. - [ ] [147] Definir biografía de Nilo (arco, capa 2) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
67. - [ ] [147] Definir biografía de Vera (arco, capa 2) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
68. - [ ] [147] Definir regla 1-5-25 de detalle por personaje [S] <!-- fuente: 147-World-Building/05-Checklist.md -->
69. - [ ] [147] Definir secundarios con misión (M23) con 5 párrafos [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
70. - [ ] [147] Definir niños NPC con capa 0 (nunca spoilers) [S] <!-- fuente: 147-World-Building/05-Checklist.md -->
71. - [ ] [147] Definir estado actual de las religiones (restos, festivales) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
72. - [ ] [147] Definir símbolos religiosos reutilizados en puzzles (M24) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
73. - [ ] [147] Definir que ninguna religión sea siniestra (cozy, M152) [S] <!-- fuente: 147-World-Building/05-Checklist.md -->
74. - [ ] [147] Definir festivales anuales con origen histórico (M74) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
75. - [ ] [147] Definir costumbres de saludo/despedida (diálogos M21) [S] <!-- fuente: 147-World-Building/05-Checklist.md -->
76. - [ ] [147] Definir detalles arquitectónicos que narran (M148) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
77. - [ ] [147] Definir estilo de Elysia (distinto, capa 4) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
78. - [ ] [147] Definir un símbolo por Sello (M153) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
79. - [ ] [147] Definir símbolos en reliquias y murales (M73/M148) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
80. - [ ] [147] Definir que los símbolos se decodifiquen por progresión, no por texto [C] <!-- fuente: 147-World-Building/05-Checklist.md -->
81. - [ ] [147] Definir glosario mínimo del lenguaje antiguo [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
82. - [ ] [147] Definir frases cortas de uso en puzzles (M24) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
83. - [ ] [147] Definir regla: el jugador nunca traduce el idioma completo [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
84. - [ ] [147] Definir nombres derivados del lenguaje antiguo (para M149) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
85. - [ ] [147] Definir numerales antiguos (relojes/reliquias) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
86. - [ ] [147] Definir tecnologías de los Jardineros (orgánicas) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
87. - [ ] [147] Definir drones/máquinas residuales operativas (M26) [C] <!-- fuente: 147-World-Building/05-Checklist.md -->
88. - [ ] [147] Definir pérdida de tecnología (por qué no se repara todo) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
89. - [ ] [147] Definir límite: nada anacrónico en manos del jugador [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
90. - [ ] [147] Definir intercambio en la era antigua (trueque + AO origen) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
91. - [ ] [147] Definir qué valoraban los Arquitectos vs. los Jardineros [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
92. - [ ] [147] Definir ruinas de mercados antiguos como lugares (M25) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
93. - [ ] [147] Definir mapas con rutas de islas ya hundidas [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
94. - [ ] [147] Definir mapas como pistas de puzzles (M24) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
95. - [ ] [147] Definir estilo visual de mapas antiguos (M46/M47) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
96. - [ ] [147] Definir que los mapas marquen lugares de la capa 4 sin revelarla [C] <!-- fuente: 147-World-Building/05-Checklist.md -->
97. - [ ] [147] Definir la Gran Quietud (catástrofe central) [C] <!-- fuente: 147-World-Building/05-Checklist.md -->
98. - [ ] [147] Definir catástrofes menores por isla (Cenizas, hundimientos) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
99. - [ ] [147] Definir efecto visible de la Gran Quietud en el mundo (M08/M09) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
100. - [ ] [147] Definir ruinas como resultado de catástrofes (M25) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
101. - [ ] [147] Definir que las catástrofes nunca sean "castigos divinos" (cozy) [S] <!-- fuente: 147-World-Building/05-Checklist.md -->
102. - [ ] [147] Definir por qué existen los asentamientos actuales [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
103. - [ ] [147] Definir llegada del Gran Vapor y su rol (M28) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
104. - [ ] [147] Definir leyenda del Viento que Canta [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
105. - [ ] [147] Definir leyenda del Corazón de la Isla [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
106. - [ ] [147] Definir regla: toda leyenda es 70% verdad distorsionada [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
107. - [ ] [147] Definir vehículo: libros, murales, cuentos de NPC (M148/M21) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
108. - [ ] [147] Definir consumo por M25 (ruinas) y M24/M26 (templos) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
109. [x] - [ ] [147] Definir consumo por M27 (islas) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
110. [x] - [ ] [147] Definir consumo por M150 (sonido narrativo) al quedar definido [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
111. [x] - [ ] [147] Definir que el jugador no lector pierda máx 10% de la historia [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
112. [x] - [ ] [147] Definir que los NPC conozcan solo sus capas (M64) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
113. - [ ] [147] Definir trazabilidad bloque de lore → módulos consumidores [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
114. - [ ] [147] Definir revisión contra M153 (contrato O1-O19) [M] <!-- fuente: 147-World-Building/05-Checklist.md -->
115. - [ ] [158] Definir el problema: progresion de herramientas por tier que desbloquee contenido sin copiar a Zelda [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
116. - [ ] [158] Registrar dependencias: M13, M38, M27, M28, M71, M22 [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
117. [x] - [ ] [158] T1 se obtiene gratis en isla principal (auto-coleccion) [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
118. - [ ] [158] T2-T4 se forjan en islas distintas con profesional especializado [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
119. - [ ] [158] Forja requiere materiales + monedas [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
120. - [ ] [158] Precios progresivos por isla (+50% minimo entre islas) [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
121. - [ ] [158] Cursos de oficio por isla (carpinteria, herreria, encantamiento) [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
122. - [ ] [158] Cursos permiten vender herramientas en tienda del jugador [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
123. - [ ] [158] Historia principal requiere T4 para completarse [C] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
124. - [ ] [158] Progresion no lineal (jugador elige orden de islas) [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
125. - [ ] [158] Construccion en otras islas posible [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
126. - [ ] [158] NPCs visitantes compran herramientas 1x/dia [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
127. - [ ] [158] Premium permite comprar monedas por Steam [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
128. - [ ] [158] Checklist minimo 100 items verificables [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
129. - [ ] [158] ToolTierDefinition como Resource con propiedades por tier [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
130. - [ ] [158] Cada tier tiene color visual distintivo [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
131. - [ ] [158] Cada tier tiene sonido de uso diferenciado [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
132. - [ ] [158] Cada tier tiene particulas diferenciadas [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
133. - [ ] [158] La herramienta mejorada reemplaza visualmente a la anterior [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
134. - [ ] [158] ZoneGate como Node3D con mesh visual por tipo [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
135. - [ ] [158] Feedback visual al no tener tier (brillo rojo suave) [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
136. - [ ] [158] Gate desaparece permanentemente al desbloquearlo [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
137. - [ ] [158] ForgeUI como Control con lista de recetas [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
138. - [ ] [158] ForgeUI muestra materiales necesarios y monedas [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
139. - [ ] [158] Se entrega herramienta al inventario [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
140. - [ ] [158] Se registra en M71 (Progresion) el hito de tier [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
141. - [ ] [158] Animacion de forja (brillo, sonido, particulas) [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
142. - [ ] [158] Herrero NPC con dialogo contextual segun isla [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
143. - [ ] [158] CourseUI como Control con info del curso [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
144. - [ ] [158] CourseUI valida tier requerido para tomar el curso [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
145. - [ ] [158] Precio de venta de herramientas varia segun curso [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
146. - [ ] [158] 1 NPC por dia maximo como visitante [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
147. - [ ] [158] NPC visita la tienda del jugador [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
148. - [ ] [158] Prefiere items de la profesion del NPC [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
149. - [ ] [158] Se registra transaccion en log [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
150. - [ ] [158] Animacion de NPC llegando a la tienda [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
151. - [ ] [158] Peces dorados: 1-3 por dia en cuerpos de agua [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
152. - [ ] [158] Cada pez dorado: 1-5 monedas al vender [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
153. - [ ] [158] Arboles con frutos dorados: 2-5 por dia [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
154. - [ ] [158] Cada fruto: 2-8 monedas al vender [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
155. - [ ] [158] Puzzles: 50-200 monedas por puzzle resuelto [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
156. - [ ] [158] Total estimado puzzles: ~3000 monedas [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
157. - [ ] [158] JarSpawner como Node3D con logica de reposicion [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
158. - [ ] [158] GoldFishSpawner como Node3D [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
159. - [ ] [158] GoldTreeSpawner como Node3D [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
160. - [ ] [158] Integracion con GameClock para reposicion [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
161. - [ ] [158] UI de inventario muestra monedas actuales [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
162. - [ ] [158] Paquete 500 monedas (.99) [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
163. - [ ] [158] Paquete 2000 monedas (.99) [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
164. - [ ] [158] Paquete 5000 monedas (.99) [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
165. - [ ] [158] PremiumManager autoload para compras [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
166. - [ ] [158] Integracion con Steam IAP [C] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
167. - [ ] [158] Monedas premium son identicas a monedas normales [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
168. - [ ] [158] No hay limite de compra premium [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
169. - [ ] [158] Premium NO compra herramientas directamente [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
170. - [ ] [158] Premium solo da monedas, jugador debe ir a islas [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
171. - [ ] [158] Log de compras premium para analytics [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
172. - [ ] [158] Capitulo 3-4 requiere T3 para avance [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
173. - [ ] [158] Capitulo 5-6 requiere T4 para avance [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
174. - [ ] [158] Capitulo 7 (final) requiere T4 completo [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
175. - [ ] [158] Templos verifican tier de herramienta [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
176. - [ ] [158] El jugador puede vivir en su pueblo sin avanzar [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
177. - [ ] [158] Progresion de historia visible en UI [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
178. - [ ] [158] PlayerToolProgress serializado en GameState.M158 [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
179. - [ ] [158] Tiers maximos alcanzados persistidos [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
180. - [ ] [158] Cursos aprendidos persistidos [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
181. - [ ] [158] Gates desbloqueados persistidos [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
182. - [ ] [158] Conteo de forjas persistido [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
183. - [ ] [158] Ventas a NPCs visitantes persistidas [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
184. - [ ] [158] Estado de jarrones (ultima reposicion) persistido [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
185. - [ ] [158] Restauracion correcta tras guardar/cargar [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
186. - [ ] [158] El jugador obtiene T1 gratis en isla principal [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
187. - [ ] [158] El jugador puede viajar a isla 2 y forjar T2 [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
188. - [ ] [158] Cada isla subsiguiente tiene precios +50% minimo [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
189. - [ ] [158] Templos de historia no se completan sin T3/T4 [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
190. - [ ] [158] Jugador premium puede comprar monedas [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
191. - [ ] [158] Jarrones se reponen cada 7 dias del juego [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
192. - [ ] [158] NPCs visitantes compran 1x/dia [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
193. - [ ] [158] El jugador puede construir en otras islas [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
194. - [ ] [158] 01-Requerimientos.md creado y firmado [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
195. - [ ] [158] 02-Analisis.md creado y firmado [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
196. - [ ] [158] 03-Diseno.md creado y firmado [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
197. - [ ] [158] 04-Codigo.md creado y firmado [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
198. - [ ] [158] 05-Checklist.md creado y firmado (este archivo) [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
199. - [ ] [158] Tabla de tiers documentada [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
200. - [ ] [158] Tabla de costos por isla documentada [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
201. - [ ] [158] DoD cumplida: 5 archivos + firma + log [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
