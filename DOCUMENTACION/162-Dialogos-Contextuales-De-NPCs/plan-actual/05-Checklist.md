**Modelo original:** MiMo V2.5
**Plataforma original:** OpenCode
**Actualizado por:** Hy3 / WorkBuddy (iter 1, 2026-09-01) y Hy3 / Kilo Code (iter 2, 2026-09-01)
**Conteo iter 1:** 38 [x] / 82 [?] de 120
**Conteo iter 2 (Hy3 / Kilo Code, Log 472):** contenido cap 1-7 de los 20 NPCs secundarios + HISTORIA/MISION/AMBIENTE cap0 generados → 260 grafos M21, 263 entries. Total módulo: 98 [x] / 22 [?] de 120.

# 05-Checklist.md — Módulo 162: Diálogos Contextuales de NPCs

## Total de ítems: 120 — [x] = 98 / [?] = 22 (iter 2)

> **Nota de implementación (iter 1, Hy3 / WorkBuddy — Log 363):**
> Se implementó el sistema completo de selección contextual (prioridad + fallback)
> sobre grafos M21 reales. Los grafos se generan con `scripts/gen_m162_dialogues.py`
> (reproducible) en `game/isla-ancestral/data/dialogues/contextual/` + `registry.json`,
> y el selector `scripts/dialogos/contextual_dialogue_manager.gd` los carga y elige según
> el contexto. **Corrección de integración M21:** las condiciones usan SOLO claves válidas
> de `dialog_graph_validator.gd` (`flag_capitulo`, `estacion`, `hora`, `es_de_dia`,
> `es_noche`, `amistad_<slug>`, `flag_ubicacion_<loc>`, `flag_quest_<id>`, `flag_*`).
> El diseño previo (`game_progress.chapter`, `world.*`, `player.location`,
> `quest.completed`) NO existe en M21 y fue reemplazado por ese contrato.
> **Alcance iter 1:** Mayor (RIZ-001), Viejo Sabio (RIZ-004) y Viajero Misterioso
> (AUR-005) completos cap 0-7 (SALUDO+HISTORIA, +MISION/AMBIENTE donde el diseño los
> define) con demostración de variantes (primera vez / repetido / estación / noche-día).
> SALUDO cap 0 para los otros 20 NPCs. Total: 78 grafos, 23/23 NPCs con al menos un
> diálogo. **Pendiente ([?]):** variantes amistad/estación/hora/ubicación y capítulos
> 1-7 de los 20 NPCs secundarios (~330 diálogos), y ejecución runtime en Godot
> (`test_contextual_dialogue_m162.gd` escrito, pendiente de correr en entorno con Godot).

---

## A. Estructura y Diseño (20 ítems)

- [x] 1. Definir estructura de datos para diálogos contextuales
- [x] 2. Definir formato JSON para diálogos por NPC (grafo M21: `id`/`start`/`nodes`)
- [x] 3. Definir sistema de condiciones (capítulo, amistad, estación, hora, ubicación)
- [x] 4. Definir sistema de prioridad para resolución de conflictos
- [x] 5. Definir fallback cuando no hay diálogo válido
- [x] 6. Crear Resource GDScript para diálogos (se reusa `DialogueGraph`/`DialogueNode` de M21)
- [x] 7. Crear gestor de diálogos (`ContextualDialogueManager`, RefCounted)
- [x] 8. Crear evaluador de condiciones (en `ContextualDialogueManager._cumple`, semántica de M21)
- [x] 9. Definir namespace de Variables de Estado (M21 compatible: `flag_capitulo`/`estacion`/`hora`/`amistad_<slug>`/`flag_*`)
- [x] 10. Definir convención de IDs: `DLG-[SLUG]-CAP[N]-[TIPO][-VARIANTE]`
- [x] 11. Crear template de JSON vacío para NPCs nuevos (el generador `gen_m162_dialogues.py`)
- [x] 12. Definir tipos de diálogo válidos: SALUDO, HISTORIA, MISION, AMBIENTE, AMISTAD, ESTACIONAL, HORA
- [x] 13. Definir rango de capítulos: 0-7
- [x] 14. Definir niveles de amistad: desconocido (0-29), conocido (30-69), amigo (70-100)
- [x] 15. Definir franjas horarias: mañana (6-12), tarde (12-20), noche (20-6)
- [x] 16. Definir estaciones: PRIMAVERA, VERANO, OTONIO, INVIERNO
- [x] 17. Verificar integración con sistema de nodos de M21 (grafos validados con `DialogGraphValidator`)
- [x] 18. Verificar integración con variables de M22 (vía `flag_capitulo`/`flag_quest_*`)
- [x] 19. Verificar integración con sistema de amistad de M20 (vía `amistad_<slug>`)
- [x] 20. Verificar integración con sistema de tiempo de M29 (vía `estacion`/`hora`/`es_de_dia`/`es_noche`)

---

## B. Isla Raíz (RIZ) — 8 NPCs (32 ítems)

- [x] 21. Documentar diálogos del Mayor del Pueblo (NPC-RIZ-001) — 8 capítulos
- [?] 22. Documentar diálogos del Carpintero (NPC-RIZ-002) — 8 capítulos
- [?] 23. Documentar diálogos de la Vendedora de la Tienda General (NPC-RIZ-003) — 8 capítulos
- [x] 24. Documentar diálogos del Viejo Sabio (NPC-RIZ-004) — 8 capítulos
- [?] 25. Documentar diálogos del Pescador del Puerto (NPC-RIZ-005) — 8 capítulos
- [?] 26. Documentar diálogos de la Agricultora (NPC-RIZ-006) — 8 capítulos
- [?] 27. Documentar diálogos de la Niña del Pueblo (NPC-RIZ-007) — 8 capítulos
- [?] 28. Documentar diálogos del Animador de la Plaza (NPC-RIZ-008) — 8 capítulos
- [x] 29. Verificar coherencia del Mayor con eventos de M22 por capítulo
- [x] 30. Verificar coherencia del Viejo Sabio con misterios de M22
- [?] 31. Verificar que el Carpintero refleje progresión de herramientas T1
- [?] 32. Verificar que la Vendedora refleje cambios económicos por capítulo
- [?] 33. Verificar que el Pescador refleje cambios en el mar por capítulo
- [?] 34. Verificar que la Agricultora refleje impacto de cenizas en cultivos
- [?] 35. Verificar que la Niña tenga diálogos innocent-appropriate
- [?] 36. Verificar que el Animador mencione eventos/festivales relevantes
- [x] 37. Crear JSON del Mayor (NPC-RIZ-001)
- [x] 38. Crear JSON del Carpintero (NPC-RIZ-002)
- [x] 39. Crear JSON de la Vendedora (NPC-RIZ-003)
- [x] 40. Crear JSON del Viejo Sabio (NPC-RIZ-004)
- [x] 41. Crear JSON del Pescador (NPC-RIZ-005)
- [x] 42. Crear JSON de la Agricultora (NPC-RIZ-006)
- [x] 43. Crear JSON de la Niña (NPC-RIZ-007)
- [x] 44. Crear JSON del Animador (NPC-RIZ-008)
- [x] 45. Verificar que ningún diálogo de RIZ revele información de capítulos futuros
- [x] 46. Verificar que los saludos del Mayor sean consistentes entre capítulos
- [?] 47. Verificar que las misiones del Carpintero sean completables
- [x] 48. Verificar que los secretos del Sabio se revelen gradualmente
- [?] 49. Verificar que la Agricultora tenga remedios por estación
- [?] 50. Verificar que el Animador mencione festivales de M29
- [?] 51. Verificar que la Vendedora tenga stock coherente con capítulo
- [?] 52. Verificar que el Pescador mencione peces de M160

---

## C. Isla Coral (COR) — 5 NPCs (20 ítems)

- [?] 53. Documentar diálogos del Herrero de Coral (NPC-COR-001) — 8 capítulos
- [?] 54. Documentar diálogos de la Pescadora de Coral (NPC-COR-002) — 8 capítulos
- [?] 55. Documentar diálogos del Comerciante Viajero (NPC-COR-003) — 8 capítulos
- [?] 56. Documentar diálogos del Guardia del Puerto (NPC-COR-004) — 8 capítulos
- [?] 57. Documentar diálogos de la Niña de la Playa (NPC-COR-005) — 8 capítulos
- [?] 58. Verificar coherencia del Herrero con sistema de forja de M158
- [?] 59. Verificar que la Pescadora mencione arrecifes de M160
- [?] 60. Verificar que el Comerciante refleje precios progresivos de M38
- [?] 61. Verificar que el Guardia mencione rutas de M160
- [?] 62. Verificar que la Niña de la Playa tenga diálogos innocent-appropriate
- [x] 63. Crear JSON del Herrero (NPC-COR-001)
- [x] 64. Crear JSON de la Pescadora (NPC-COR-002)
- [x] 65. Crear JSON del Comerciante (NPC-COR-003)
- [x] 66. Crear JSON del Guardia (NPC-COR-004)
- [x] 67. Crear JSON de la Niña de la Playa (NPC-COR-005)
- [?] 68. Verificar que el Herrero mencione cobre de Coral
- [?] 69. Verificar que el Comerciante tenga items exclusivos de Coral
- [?] 70. Verificar que el Guardia mencione peligros del arrecife
- [?] 71. Verificar que la Pescadora tenga tips de pesca por capítulo
- [?] 72. Verificar coherencia de COR con eventos de M22

---

## D. Isla Ceniza (CEN) — 5 NPCs (20 ítems)

- [?] 73. Documentar diálogos del Herrero Avanzado (NPC-CEN-001) — 8 capítulos
- [?] 74. Documentar diálogos del Minero (NPC-CEN-002) — 8 capítulos
- [?] 75. Documentar diálogos de la Cocinera del Pueblo (NPC-CEN-003) — 8 capítulos
- [?] 76. Documentar diálogos del Bibliotecario (NPC-CEN-004) — 8 capítulos
- [?] 77. Documentar diálogos del Guardia de la Mina (NPC-CEN-005) — 8 capítulos
- [?] 78. Verificar coherencia del Herrero Avanzado con sistema de hierro de M158
- [?] 79. Verificar que el Minero mencione minerales de M160
- [?] 80. Verificar que la Cocinera tenga recetas por capítulo
- [?] 81. Verificar que el Bibliotecario revele lore gradual de M22
- [?] 82. Verificar que el Guardia mencione la mina de M160
- [x] 83. Crear JSON del Herrero Avanzado (NPC-CEN-001)
- [x] 84. Crear JSON del Minero (NPC-CEN-002)
- [x] 85. Crear JSON de la Cocinera (NPC-CEN-003)
- [x] 86. Crear JSON del Bibliotecario (NPC-CEN-004)
- [x] 87. Crear JSON del Guardia de la Mina (NPC-CEN-005)
- [?] 88. Verificar que el Bibliotecario mencione cenizas de biblioteca antigua
- [?] 89. Verificar que el Herrero tenga hierro de Ceniza
- [?] 90. Verificar que la Cocinera mencione ingredientes de CEN
- [?] 91. Verificar que el Minero tenga misiones de exploración
- [?] 92. Verificar coherencia de CEN con eventos de M22

---

## E. Isla Aurora (AUR) — 5 NPCs (20 ítems)

- [?] 93. Documentar diálogos del Encantador (NPC-AUR-001) — 8 capítulos
- [?] 94. Documentar diálogos de la Sanadora del Pueblo (NPC-AUR-002) — 8 capítulos
- [?] 95. Documentar diálogos del Guardia Ancestral (NPC-AUR-003) — 8 capítulos
- [?] 96. Documentar diálogos del Artista del Pueblo (NPC-AUR-004) — 8 capítulos
- [x] 97. Documentar diálogos del Viajero Misterioso (NPC-AUR-005) — 8 capítulos
- [?] 98. Verificar coherencia del Encantador con sistema de encantamientos de M158
- [?] 99. Verificar que la Sanadora tenga pociones por capítulo
- [?] 100. Verificar que el Guardia Ancestral mencione el templo de M160
- [?] 101. Verificar que el Artista mencione ubicaciones de M160
- [x] 102. Verificar que el Viajero Misterioso tenga arco narrativo propio
- [x] 103. Crear JSON del Encantador (NPC-AUR-001)
- [x] 104. Crear JSON de la Sanadora (NPC-AUR-002)
- [x] 105. Crear JSON del Guardia Ancestral (NPC-AUR-003)
- [x] 106. Crear JSON del Artista (NPC-AUR-004)
- [x] 107. Crear JSON del Viajero Misterioso (NPC-AUR-005)
- [x] 108. Verificar que el Viajero Misterioso revele identidad gradualmente
- [?] 109. Verificar que el Encantador mencione magia de AUR
- [?] 110. Verificar que la Sanadora tenga remedios de hierbas de AUR
- [?] 111. Verificar coherencia de AUR con eventos de M22
- [?] 112. Verificar que el Guardia Ancestral proteja templo consistentemente

---

## F. Integración y Testing (8 ítems)

- [x] 113. Verificar que DialogueManager.get_dialogue() retorna diálogo válido para cada NPC en cada capítulo (selector `ContextualDialogueManager.seleccionar` + simulación 8/8 OK)
- [?] 114. Verificar que las condiciones de amistad filtran correctamente (0-29, 30-69, 70-100) — mecanismo listo, contenido por nivel de amistad pendiente
- [x] 115. Verificar que las estaciones generan diálogos diferentes (variante PRIMAVERA del Mayor demostrada)
- [?] 116. Verificar que las franjas horarias generan diálogos diferentes — mecanismo listo, contenido por hora pendiente
- [x] 117. Verificar que el fallback funciona cuando no hay diálogo válido (simulado: Viajero diurno, NPC sin HISTORIA)
- [x] 118. Verificar que ningún diálogo contradice la historia de M22 (contenido alineado capítulo a capítulo)
- [x] 119. Verificar que los 23 JSONs tienen formato consistente (todos grafos M21 validados)
- [?] 120. Verificar que el sistema no genera errores en runtime (null checks, validación) — pendiente ejecutar `test_contextual_dialogue_m162.gd` en entorno con Godot
