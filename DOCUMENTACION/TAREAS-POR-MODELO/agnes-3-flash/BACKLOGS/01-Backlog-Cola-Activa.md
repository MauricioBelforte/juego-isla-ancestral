# agnes-3-flash — Cola activa 100+ tareas (tandas del director)
**Fuente:** BACKLOG-MASTER.md agnes-3-flash (sección dividida 5nov por fundador)
**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Rol:** DIRECTORA
**Estado:** [→] Activo

# (A) COLA ACTIVA — 100+ TAREAS (tandas curadas por el director)

> Re-poblada 2026-10-18 ~06:10 por el director (verificado contra disco por agnes en #764: los 3 primeros estaban completos).
> Fuente: los 05 de M90/M46/M161/M52/M47/M45 (nicho visual/QA). Total 87 items SIN HACER. Firmado GLM-5.3 Flash-Director.

1. 90-Configuracion-Grafica: Definir culling de objetos fuera de distancia
2. 90-Configuracion-Grafica: Definir LODs para objetos lejanos (M50) — **PARCIAL (step-5-kilocode, Kilo Code, 2026-10-12):** hay LOD del **terreno**, no de objetos. `scripts/main_island.gd` L143-154 configura `lod_split_count = 5` y `lod_distance = 160.0` (anillos 2×/4×/8×/16×/32×). No se encontró LOD ni culling por distancia para objetos individuales.
3. 90-Configuracion-Grafica: Definir iluminación volumétrica (baja/media: off, alta: on, ultra: alta calidad)
4. 90-Configuracion-Grafica: Definir animación por wind shader
5. 90-Configuracion-Grafica: Definir interacción con jugador
6. 90-Configuracion-Grafica: Definir parallax para profundidad
7. 90-Configuracion-Grafica: Definir colisión de partículas con world
8. 90-Configuracion-Grafica: Definir toggle de post-processing
9. 90-Configuracion-Grafica: Definir efectos (bloom, motion blur, depth of field, color grading, tonemapping)
10. 90-Configuracion-Grafica: Definir activación/desactivación de todos los efectos
11. 90-Configuracion-Grafica: Definir toggle de bloom — **PARCIAL (step-5-kilocode, Kilo Code, 2026-10-12):** el bloom está **activo** en la escena principal (`main_island.tscn` L42-44: `glow_enabled = true`), pero no hay toggle de usuario ni slider: el valor va fijo en la escena, no en `graphics_config.gd`.
12. 90-Configuracion-Grafica: Definir intensidad (slider 0-1)
13. 90-Configuracion-Grafica: Definir threshold para fuentes de luz brillantes
14. 90-Configuracion-Grafica: Definir intensidad (slider 0-1)
15. 90-Configuracion-Grafica: Definir sample count (slider 4-16)
16. 90-Configuracion-Grafica: Definir motion blur basado en velocidad de cámara
17. 90-Configuracion-Grafica: Definir más blur cuando la cámara se mueve más rápido
18. 90-Configuracion-Grafica: Definir desactivado por defecto (causa mareo)
19. 90-Configuracion-Grafica: Definir toggle de depth of field
20. 90-Configuracion-Grafica: Definir intensidad (slider 0-1)
21. 90-Configuracion-Grafica: Definir distancia (slider 0-100)
22. 90-Configuracion-Grafica: Definir depth of field basado en distancia de la cámara
23. 90-Configuracion-Grafica: Definir blur para objetos fuera de foco
24. 90-Configuracion-Grafica: Definir aperture controla cuánto blur
25. 90-Configuracion-Grafica: Definir detección de GPU y habilitación correspondiente
26. 90-Configuracion-Grafica: Definir 125% (oversampling 1.25x)
27. 90-Configuracion-Grafica: Definir 150% (oversampling 1.5x)
28. 90-Configuracion-Grafica: Definir detección de RAM (OS.get_static_memory_usage())
29. 90-Configuracion-Grafica: Definir detección de CPU (OS.get_processor_name())
30. 90-Configuracion-Grafica: Diseñar tamaño de fuente (slider 0.5x a 2x)
31. 90-Configuracion-Grafica: Diseñar alto contraste (toggle)
32. 90-Configuracion-Grafica: Diseñar reducción de motion blur (opción para reducir mareo)
33. 90-Configuracion-Grafica: Diseñar reducción de bloom (opción para reducir distracción visual)
34. 90-Configuracion-Grafica: Diseñar aplicación en tiempo real
35. 90-Configuracion-Grafica: Diseñar FPS counter (opcional, en debug)
36. 46-Arte-2D: Definir iconos de todos los ítems de M14/M15 con claves i18n [M] — Log 726: inventario data-driven (inventario_2d.json, 6 iconos de recursos M15 sembrados; el resto se agrega al catálogo) **↔ M46-recon: asset-existencia 0/48 = `#esperando:assets-2d` (dep M45/M108/art).**
37. 46-Arte-2D: Definir legibilidad mínima 32 px (prueba obligatoria) [M] — Log 726 (§6) **↔ M46-recon: la REGLA está en §6 pero la PRUEBA 32px requiere assets = `#esperando:assets-2d`.**
38. 46-Arte-2D: Definir retrato de cada NPC (M19) y jugador [M] — Log 726: pt_npc_riz_001_* (5 expresiones) sembrados en inventario; patrón replicable por NPC
39. 46-Arte-2D: Definir iconos de acciones (M57): interactuar, atacar, saltar, menú [M] — Log 726 (§4 familia ui_art_; estados en inventario)
40. 46-Arte-2D: Definir set de símbolos para M24/M25/M26 sin palabras [M] — Log 726: 4 sym_sello_* (RIZ/COR/CEN/AUR) en inventario
41. 46-Arte-2D: Definir ilustración pergamino para mapas del tesoro (M25) [M] — Log 726: illus_mapa_tesoro 1024 en inventario
42. 46-Arte-2D: Definir marco común de insignias (círculo + figura + borde de rareza) [M] — Log 726 (§4; badge_logro_marco en inventario)
43. 46-Arte-2D: Definir integración con logros (M72) y sellos (M22) [M] — Log 726 (§4)
44. 46-Arte-2D: Definir pantallas de carga con arte de Aurora [M] — Log 726: illus_carga_aurora 1024 en inventario
45. 46-Arte-2D: Definir integración con M63 (progreso real sobre el arte) [M] — Log 726 (§4)
46. 46-Arte-2D: Definir icono del jugador en mapa/minimapa coherente con personaje 3D [M] — Log 726 (§4 receta ico_ con plantilla 3D; asset por agregar al inventario)
47. 46-Arte-2D: Incluir verificacion de regiones de texto en el validador [M] -- agnes-2.5-flash 2026-09-12: regla 0-texto documentada en 03-Diseno.md §7 + Log 726; validador naming (validar_nombres.py) cubre convenciones; verificacion visual de regiones de texto se hace en revision artistica por modulo (M45/M46). KnownIssue no bloqueante DoD. **↔ M46-recon: queda [ ] (KnownIssue: verif. visual de regiones = review artística M45/M46, no el validador naming).**
48. 46-Arte-2D: Legibilidad a 32 px con contraste AA (M58) [M] — Log 726 (§6 prueba obligatoria definida) **↔ M46-recon: regla §6 documentada pero la PRUEBA 32px requiere assets = `#esperando:assets-2d` + M58.**
49. 46-Arte-2D: Icono de cada objeto legible a 32 px en inventario y tienda [M] — agnes-2.5-flash 2026-09-12: criterio definido en 03-Diseno.md §6; prueba se ejecutara cuando existan assets (M45). KnownIssue no bloqueante DoD — regla documentada.
50. 46-Arte-2D: Retrato del NPC se parece al modelo 3D (comparacion lado a lado) [M] — agnes-2.5-flash 2026-09-12: flujo §9 define comparacion; se ejecutara cuando NPCs M161 tengan sprites 2D. KnownIssue no bloqueante DoD.
51. 46-Arte-2D: Símbolos ancestrales sin texto reutilizables [M] — agnes-2.5-flash 2026-09-12: receta §4 + 4 sym_sello en inventario; verificacion al crearlos requiere assets (M45). KnownIssue no bloqueante DoD.
52. 46-Arte-2D: Atlas con carga diferida sin duplicados en memoria [M] — agnes-2.5-flash 2026-09-12: regla §7 definida; verificacion cuando existan atlas (M108 pipeline). KnownIssue no bloqueante DoD.
53. 46-Arte-2D: Piezas cumplen M108 y Git LFS [M] — agnes-2.5-flash 2026-09-12: formato §7 definido; cumplimiento por pieza al crearse (M108). KnownIssue no bloqueante DoD.
54. 46-Arte-2D: Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
55. 161-Diseno-Visual-De-NPCs: Documentar variantes estacionales
56. 161-Diseno-Visual-De-NPCs: Documentar variantes estacionales
57. 161-Diseno-Visual-De-NPCs: Documentar variantes estacionales generales
58. 161-Diseno-Visual-De-NPCs: Verificar que retratos 2D (M46) usan estos diseños
59. 161-Diseno-Visual-De-NPCs: Verificar que modelos 3D (M45) implementan estos diseños
60. 161-Diseno-Visual-De-NPCs: Verificar que NPCs aparecen en ubicaciones M160
61. 161-Diseno-Visual-De-NPCs: Verificar que ropa puede coincidir con M155
62. 161-Diseno-Visual-De-NPCs: Crear test de integración con M19
63. 161-Diseno-Visual-De-NPCs: Crear test de integración con M46
64. 161-Diseno-Visual-De-NPCs: Documentar variantes estacionales
65. 161-Diseno-Visual-De-NPCs: [?] Modelos 3D/retratos M46 de los 23 diseños (dueño: M45/M46 + Hy4) — el dataset está listo para consumo
66. 161-Diseno-Visual-De-NPCs: [?] Variantes estacionales (RF6): la maquina `variantes_estacionales` está vacía en los 23 (dueño: iter 2, al menos 10 NPCs documentados en 03-Diseno §9.4)
67. 52-Particulas-Y-VFX: [?] Definir VfxManager (autoload) [M] — `VfxManager inexistente — impl real VfxDirector sin autoload registrado (Hy3 221); decidir registro al cerrar M52`. Verificado por GLM-5.3-Flash 2026-10-16: `git grep VfxManager -- "*.gd" "*.tscn"` = 0 hits; `project.godot` sin autoload VFX; `vfx_director.gd` sí existe.
68. 52-Particulas-Y-VFX: [?] Definir validate_vfx.gd [M] — archivo no existe — drift detectado 2026-10-15 (agnes 526); verificado por GLM-5.3-Flash con `git ls-files "*validate_vfx*"` (0 hits; solo menciones en docs). La validación real se cubre por turnos en `vfx_pool.gd`/schema (iter. 5-6) — ver ítems inferiores.
69. 52-Particulas-Y-VFX: [?] Catálogo de VFX por evento (M44 feedback + M92 tutorial): iter 2 — catálogo data-driven (dueño: deepseek-v4-flash-vision-exp)
70. 47-Texturas-Y-Materiales: [?] Mantenible: fuentes procedurales versionadas, PNG en Git LFS [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §Q.** — QA s2 2026-10-12 (Log 1773): Git LFS no configurado (.gitattributes sin filtros LFS, 0 archivos trackeados) → deuda M06/LFS.
71. 47-Texturas-Y-Materiales: [?] Documentar integración con M06 (Git LFS) [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §T.** — QA s2 2026-10-12 (Log 1773): Git LFS no configurado (.gitattributes sin filtros LFS, 0 archivos trackeados) → deuda M06/LFS.
72. 47-Texturas-Y-Materiales: [?] Superficies cumplen M108 y Git LFS [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §T/V.** — QA s2 2026-10-12 (Log 1773): Git LFS no configurado (.gitattributes sin filtros LFS, 0 archivos trackeados) → deuda M06/LFS.
73. 45-Arte-3D: Incluir ejemplos de referencia (shader/atlas de referencia) en la guía [M]
74. 45-Arte-3D: Definir carpeta npc/ (aldeanos M19) [S]
75. 45-Arte-3D: Verificar escala 1:1 (< 1e-3) [S]
76. 45-Arte-3D: Verificar techos de tris por categoría [S]
77. 45-Arte-3D: Verificar topología (n-gons, vértices duplicados) [S]
78. 45-Arte-3D: Verificar UVs (fuera de rango, padding) [S]
79. 45-Arte-3D: Verificar origen Y=0 para props de suelo [S]
80. 45-Arte-3D: Verificar existencia de LODs si tris > 500 [S]
81. 45-Arte-3D: Acumular errores (no morir en el primero) y emitir mensajes accionables [M]
82. 45-Arte-3D: Documentar regla de nombres de variantes (sufijo _c1, _c2...) [S]
83. 45-Arte-3D: Documentar límites de assets visibles por escena tipo (pueblo, bosque, templo) [M]
84. 45-Arte-3D: Documentar compatibilidad con generación procedural (M10 no crea assets, solo los coloca) [M]
85. 45-Arte-3D: Tres assets de prueba pasan validate_mesh.gd y se ven armónicos en Aurora [M]
86. 45-Arte-3D: Personaje 1.8 m con punto de apoyo en grilla voxel [M]
87. 45-Arte-3D: Conteo de tris por categoría menor o igual a la tabla RF4 [M]
88. 90-Configuracion-Grafica: Definir detección de RAM (OS.get_static_memory_usage())
89. 90-Configuracion-Grafica: Definir detección de CPU (OS.get_processor_name())
90. 90-Configuracion-Grafica: Diseñar tamaño de fuente (slider 0.5x a 2x)
91. 90-Configuracion-Grafica: Diseñar alto contraste (toggle)
92. 90-Configuracion-Grafica: Diseñar reducción de motion blur (opción para reducir mareo)
93. 90-Configuracion-Grafica: Diseñar reducción de bloom (opción para reducir distracción visual)
94. 90-Configuracion-Grafica: Diseñar aplicación en tiempo real
95. 90-Configuracion-Grafica: Diseñar FPS counter (opcional, en debug)
96. 90-Configuracion-Grafica: Diseñar profiling de GPU (opcional, en debug)
97. 90-Configuracion-Grafica: Diseñar monitoreo de uso de GPU y RAM (opcional, en debug)
98. 90-Configuracion-Grafica: Diseñar FPS counter visible en debug (M110)
99. 90-Configuracion-Grafica: Diseñar profiling visible en debug (M110)
100. 90-Configuracion-Grafica: Diseñar monitoreo visible en debug (M110)

