**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 162: Diálogos Contextuales de NPCs

## Total de ítems: 120

---

## A. Estructura y Diseño (20 ítems)

- [ ] 1. Definir estructura de datos para diálogos contextuales
- [ ] 2. Definir formato JSON para diálogos por NPC
- [ ] 3. Definir sistema de condiciones (capítulo, amistad, estación, hora, ubicación)
- [ ] 4. Definir sistema de prioridad para resolución de conflictos
- [ ] 5. Definir fallback cuando no hay diálogo válido
- [ ] 6. Crear Resource GDScript para diálogos (DialogueResource)
- [ ] 7. Crear gestor de diálogos (DialogueManager)
- [ ] 8. Crear evaluador de condiciones (DialogueConditions)
- [ ] 9. Definir namespace de Variables de Estado (M21 compatible)
- [ ] 10. Definir convención de IDs: DLG-[ISLA]-[NPC]-[CAP]-[TIPO]
- [ ] 11. Crear template de JSON vacío para NPCs nuevos
- [ ] 12. Definir tipos de diálogo válidos: SALUDO, HISTORIA, MISION, AMBIENTE, AMISTAD, ESTACIONAL, HORA
- [ ] 13. Definir rango de capítulos: 0-7
- [ ] 14. Definir niveles de amistad: desconocido (0-29), conocido (30-69), amigo (70-100)
- [ ] 15. Definir franjas horarias: mañana (6-12), tarde (12-20), noche (20-6)
- [ ] 16. Definir estaciones: PRIMAVERA, VERANO, OTONIO, INVIERNO
- [ ] 17. Verificar integración con sistema de nodos de M21
- [ ] 18. Verificar integración con variables de M22
- [ ] 19. Verificar integración con sistema de amistad de M20
- [ ] 20. Verificar integración con sistema de tiempo de M29

---

## B. Isla Raíz (RIZ) — 8 NPCs (32 ítems)

- [ ] 21. Documentar diálogos del Mayor del Pueblo (NPC-RIZ-001) — 8 capítulos
- [ ] 22. Documentar diálogos del Carpintero (NPC-RIZ-002) — 8 capítulos
- [ ] 23. Documentar diálogos de la Vendedora de la Tienda General (NPC-RIZ-003) — 8 capítulos
- [ ] 24. Documentar diálogos del Viejo Sabio (NPC-RIZ-004) — 8 capítulos
- [ ] 25. Documentar diálogos del Pescador del Puerto (NPC-RIZ-005) — 8 capítulos
- [ ] 26. Documentar diálogos de la Agricultora (NPC-RIZ-006) — 8 capítulos
- [ ] 27. Documentar diálogos de la Niña del Pueblo (NPC-RIZ-007) — 8 capítulos
- [ ] 28. Documentar diálogos del Animador de la Plaza (NPC-RIZ-008) — 8 capítulos
- [ ] 29. Verificar coherencia del Mayor con eventos de M22 por capítulo
- [ ] 30. Verificar coherencia del Viejo Sabio con misterios de M22
- [ ] 31. Verificar que el Carpintero refleje progresión de herramientas T1
- [ ] 32. Verificar que la Vendedora refleje cambios económicos por capítulo
- [ ] 33. Verificar que el Pescador refleje cambios en el mar por capítulo
- [ ] 34. Verificar que la Agricultora refleje impacto de cenizas en cultivos
- [ ] 35. Verificar que la Niña tenga diálogos innocent-appropriate
- [ ] 36. Verificar que el Animador mencione eventos/festivales relevantes
- [ ] 37. Crear JSON del Mayor (NPC-RIZ-001)
- [ ] 38. Crear JSON del Carpintero (NPC-RIZ-002)
- [ ] 39. Crear JSON de la Vendedora (NPC-RIZ-003)
- [ ] 40. Crear JSON del Viejo Sabio (NPC-RIZ-004)
- [ ] 41. Crear JSON del Pescador (NPC-RIZ-005)
- [ ] 42. Crear JSON de la Agricultora (NPC-RIZ-006)
- [ ] 43. Crear JSON de la Niña (NPC-RIZ-007)
- [ ] 44. Crear JSON del Animador (NPC-RIZ-008)
- [ ] 45. Verificar que ningún diálogo de RIZ revele información de capítulos futuros
- [ ] 46. Verificar que los saludos del Mayor sean consistentes entre capítulos
- [ ] 47. Verificar que las misiones del Carpintero sean completables
- [ ] 48. Verificar que los secretos del Sabio se revelen gradualmente
- [ ] 49. Verificar que la Agricultora tenga remedios por estación
- [ ] 50. Verificar que el Animador mencione festivales de M29
- [ ] 51. Verificar que la Vendedora tenga stock coherente con capítulo
- [ ] 52. Verificar que el Pescador mencione peces de M160

---

## C. Isla Coral (COR) — 5 NPCs (20 ítems)

- [ ] 53. Documentar diálogos del Herrero de Coral (NPC-COR-001) — 8 capítulos
- [ ] 54. Documentar diálogos de la Pescadora de Coral (NPC-COR-002) — 8 capítulos
- [ ] 55. Documentar diálogos del Comerciante Viajero (NPC-COR-003) — 8 capítulos
- [ ] 56. Documentar diálogos del Guardia del Puerto (NPC-COR-004) — 8 capítulos
- [ ] 57. Documentar diálogos de la Niña de la Playa (NPC-COR-005) — 8 capítulos
- [ ] 58. Verificar coherencia del Herrero con sistema de forja de M158
- [ ] 59. Verificar que la Pescadora mencione arrecifes de M160
- [ ] 60. Verificar que el Comerciante refleje precios progresivos de M38
- [ ] 61. Verificar que el Guardia mencione rutas de M160
- [ ] 62. Verificar que la Niña de la Playa tenga diálogos innocent-appropriate
- [ ] 63. Crear JSON del Herrero (NPC-COR-001)
- [ ] 64. Crear JSON de la Pescadora (NPC-COR-002)
- [ ] 65. Crear JSON del Comerciante (NPC-COR-003)
- [ ] 66. Crear JSON del Guardia (NPC-COR-004)
- [ ] 67. Crear JSON de la Niña de la Playa (NPC-COR-005)
- [ ] 68. Verificar que el Herrero mencione cobre de Coral
- [ ] 69. Verificar que el Comerciante tenga items exclusivos de Coral
- [ ] 70. Verificar que el Guardia mencione peligros del arrecife
- [ ] 71. Verificar que la Pescadora tenga tips de pesca por capítulo
- [ ] 72. Verificar coherencia de COR con eventos de M22

---

## D. Isla Ceniza (CEN) — 5 NPCs (20 ítems)

- [ ] 73. Documentar diálogos del Herrero Avanzado (NPC-CEN-001) — 8 capítulos
- [ ] 74. Documentar diálogos del Minero (NPC-CEN-002) — 8 capítulos
- [ ] 75. Documentar diálogos de la Cocinera del Pueblo (NPC-CEN-003) — 8 capítulos
- [ ] 76. Documentar diálogos del Bibliotecario (NPC-CEN-004) — 8 capítulos
- [ ] 77. Documentar diálogos del Guardia de la Mina (NPC-CEN-005) — 8 capítulos
- [ ] 78. Verificar coherencia del Herrero Avanzado con sistema de hierro de M158
- [ ] 79. Verificar que el Minero mencione minerales de M160
- [ ] 80. Verificar que la Cocinera tenga recetas por capítulo
- [ ] 81. Verificar que el Bibliotecario revele lore gradual de M22
- [ ] 82. Verificar que el Guardia mencione la mina de M160
- [ ] 83. Crear JSON del Herrero Avanzado (NPC-CEN-001)
- [ ] 84. Crear JSON del Minero (NPC-CEN-002)
- [ ] 85. Crear JSON de la Cocinera (NPC-CEN-003)
- [ ] 86. Crear JSON del Bibliotecario (NPC-CEN-004)
- [ ] 87. Crear JSON del Guardia de la Mina (NPC-CEN-005)
- [ ] 88. Verificar que el Bibliotecario mencione cenizas de biblioteca antigua
- [ ] 89. Verificar que el Herrero tenga hierro de Ceniza
- [ ] 90. Verificar que la Cocinera mencione ingredientes de CEN
- [ ] 91. Verificar que el Minero tenga misiones de exploración
- [ ] 92. Verificar coherencia de CEN con eventos de M22

---

## E. Isla Aurora (AUR) — 5 NPCs (20 ítems)

- [ ] 93. Documentar diálogos del Encantador (NPC-AUR-001) — 8 capítulos
- [ ] 94. Documentar diálogos de la Sanadora del Pueblo (NPC-AUR-002) — 8 capítulos
- [ ] 95. Documentar diálogos del Guardia Ancestral (NPC-AUR-003) — 8 capítulos
- [ ] 96. Documentar diálogos del Artista del Pueblo (NPC-AUR-004) — 8 capítulos
- [ ] 97. Documentar diálogos del Viajero Misterioso (NPC-AUR-005) — 8 capítulos
- [ ] 98. Verificar coherencia del Encantador con sistema de encantamientos de M158
- [ ] 99. Verificar que la Sanadora tenga pociones por capítulo
- [ ] 100. Verificar que el Guardia Ancestral mencione el templo de M160
- [ ] 101. Verificar que el Artista mencione ubicaciones de M160
- [ ] 102. Verificar que el Viajero Misterioso tenga arco narrativo propio
- [ ] 103. Crear JSON del Encantador (NPC-AUR-001)
- [ ] 104. Crear JSON de la Sanadora (NPC-AUR-002)
- [ ] 105. Crear JSON del Guardia Ancestral (NPC-AUR-003)
- [ ] 106. Crear JSON del Artista (NPC-AUR-004)
- [ ] 107. Crear JSON del Viajero Misterioso (NPC-AUR-005)
- [ ] 108. Verificar que el Viajero Misterioso revele identidad gradualmente
- [ ] 109. Verificar que el Encantador mencione magia de AUR
- [ ] 110. Verificar que la Sanadora tenga remedios de hierbas de AUR
- [ ] 111. Verificar coherencia de AUR con eventos de M22
- [ ] 112. Verificar que el Guardia Ancestral proteja templo consistentemente

---

## F. Integración y Testing (8 ítems)

- [ ] 113. Verificar que DialogueManager.get_dialogue() retorna diálogo válido para cada NPC en cada capítulo
- [ ] 114. Verificar que las condiciones de amistad filtran correctamente (0-29, 30-69, 70-100)
- [ ] 115. Verificar que las estaciones generan diálogos diferentes
- [ ] 116. Verificar que las franjas horarias generan diálogos diferentes
- [ ] 117. Verificar que el fallback funciona cuando no hay diálogo válido
- [ ] 118. Verificar que ningún diálogo contradice la historia de M22
- [ ] 119. Verificar que los 23 JSONs tienen formato consistente
- [ ] 120. Verificar que el sistema no genera errores en runtime (null checks, validación)
