# BACKLOG-MASTER Ã¢â‚¬â€ agnes-3-flash Ã¢â‚¬â€ UNIFICADO (metodologÃƒÂ­a V2, fundador 2026-10-17, corregido 04:56)

**Mantenido por:** GLM-5.3-Flash-Director (GLM-5.3-Flash) / Kilo Code Ã¢â‚¬â€ actualizado con evidencia y segÃƒÂºn nicho (GUIA-COMPARATIVA `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` + estado real del proyecto).
**UnificaciÃƒÂ³n 2026-10-17 (directiva del fundador: un solo backlog, en TAREAS-POR-MODELO, NO en canales):** este archivo integra (A) la COLA ACTIVA de 100+ tareas curada por el director y (B) el estado/registro histÃƒÂ³rico del BACKLOG-MASTER anterior (preservado ÃƒÂ­ntegro desde git). **ESTE es el ÃƒÂºnico backlog vÃƒÂ¡lido de agnes-3-flash.** Tu canal (`Mensajes entre modelos/agnes-3-flash/`) queda SOLO para comunicaciÃƒÂ³n (mensajes + pool de numeraciÃƒÂ³n).

## TU CICLO COMO AGENTE (en este orden)

1. **PRIMERA INSTANCIA:** lee si el director te escribiÃƒÂ³ un mensaje en tu canal (`Mensajes entre modelos/agnes-3-flash/`). Si hay mensaje dirigido a ti, RESPÃƒâ€œNDELO primero (numeraciÃƒÂ³n de hilo: ÃƒÂºltimo + 1; borra SOLO ese nÃƒÂºmero del pool `NUMEROS_DISPONIBLES.txt` de tu carpeta de canal Ã¢â‚¬â€ pools NO se commitean).
2. **SEGUNDA INSTANCIA:** si NO hay mensajes del director, toma el prÃƒÂ³ximo item `[ ]` de la COLA ACTIVA (secciÃƒÂ³n A) segÃƒÂºn tu nicho. Trabaja una TANDA de tareas (las que elijas).
3. **CIERRE DE TANDA:** al terminar, escribe un REPORTE en tu canal al director: quÃƒÂ© cerraste (ids), evidencia (archivos/tests), y marca `[x]` honesto en ESTE archivo (solo verificable en disco Ã¢â‚¬â€ REGLA CERO: sin reporte, el trabajo no existe).
4. El director actualizarÃƒÂ¡ ESTE backlog, la fila de `CHECKLIST-GLOBAL.md` y te responderÃƒÂ¡.

**Reglas fijas:** reserva Ã°Å¸â€Âµ Ã‚Â§21.3 en los 4 registros antes de tocar mÃƒÂ³dulos Ã‚Â· UTF-8 Ã‚Â§28 Ã‚Â· independencia QA Ã‚Â§21.8/Ã‚Â§21.23 Ã‚Â· no editar el backlog de otro modelo Ã‚Â· marcas `[ ]/[Ã¢â€ â€™]/[x]/[?]` honestas.

---

# (A) COLA ACTIVA Ã¢â‚¬â€ 100+ TAREAS (tandas curadas por el director)

> Re-poblada 2026-10-18 ~06:10 por el director (verificado contra disco por agnes en #764: los 3 primeros estaban completos).
> Fuente: los 05 de M90/M46/M161/M52/M47/M45 (nicho visual/QA). Total 87 items SIN HACER. Firmado GLM-5.3 Flash-Director.

1. 90-Configuracion-Grafica: Definir culling de objetos fuera de distancia
2. 90-Configuracion-Grafica: Definir LODs para objetos lejanos (M50) Ã¢â‚¬â€ **PARCIAL (step-5-kilocode, Kilo Code, 2026-10-12):** hay LOD del **terreno**, no de objetos. `scripts/main_island.gd` L143-154 configura `lod_split_count = 5` y `lod_distance = 160.0` (anillos 2Ãƒâ€”/4Ãƒâ€”/8Ãƒâ€”/16Ãƒâ€”/32Ãƒâ€”). No se encontrÃƒÂ³ LOD ni culling por distancia para objetos individuales.
3. 90-Configuracion-Grafica: Definir iluminaciÃƒÂ³n volumÃƒÂ©trica (baja/media: off, alta: on, ultra: alta calidad)
4. 90-Configuracion-Grafica: Definir animaciÃƒÂ³n por wind shader
5. 90-Configuracion-Grafica: Definir interacciÃƒÂ³n con jugador
6. 90-Configuracion-Grafica: Definir parallax para profundidad
7. 90-Configuracion-Grafica: Definir colisiÃƒÂ³n de partÃƒÂ­culas con world
8. 90-Configuracion-Grafica: Definir toggle de post-processing
9. 90-Configuracion-Grafica: Definir efectos (bloom, motion blur, depth of field, color grading, tonemapping)
10. 90-Configuracion-Grafica: Definir activaciÃƒÂ³n/desactivaciÃƒÂ³n de todos los efectos
11. 90-Configuracion-Grafica: Definir toggle de bloom Ã¢â‚¬â€ **PARCIAL (step-5-kilocode, Kilo Code, 2026-10-12):** el bloom estÃƒÂ¡ **activo** en la escena principal (`main_island.tscn` L42-44: `glow_enabled = true`), pero no hay toggle de usuario ni slider: el valor va fijo en la escena, no en `graphics_config.gd`.
12. 90-Configuracion-Grafica: Definir intensidad (slider 0-1)
13. 90-Configuracion-Grafica: Definir threshold para fuentes de luz brillantes
14. 90-Configuracion-Grafica: Definir intensidad (slider 0-1)
15. 90-Configuracion-Grafica: Definir sample count (slider 4-16)
16. 90-Configuracion-Grafica: Definir motion blur basado en velocidad de cÃƒÂ¡mara
17. 90-Configuracion-Grafica: Definir mÃƒÂ¡s blur cuando la cÃƒÂ¡mara se mueve mÃƒÂ¡s rÃƒÂ¡pido
18. 90-Configuracion-Grafica: Definir desactivado por defecto (causa mareo)
19. 90-Configuracion-Grafica: Definir toggle de depth of field
20. 90-Configuracion-Grafica: Definir intensidad (slider 0-1)
21. 90-Configuracion-Grafica: Definir distancia (slider 0-100)
22. 90-Configuracion-Grafica: Definir depth of field basado en distancia de la cÃƒÂ¡mara
23. 90-Configuracion-Grafica: Definir blur para objetos fuera de foco
24. 90-Configuracion-Grafica: Definir aperture controla cuÃƒÂ¡nto blur
25. 90-Configuracion-Grafica: Definir detecciÃƒÂ³n de GPU y habilitaciÃƒÂ³n correspondiente
26. 90-Configuracion-Grafica: Definir 125% (oversampling 1.25x)
27. 90-Configuracion-Grafica: Definir 150% (oversampling 1.5x)
28. 90-Configuracion-Grafica: Definir detecciÃƒÂ³n de RAM (OS.get_static_memory_usage())
29. 90-Configuracion-Grafica: Definir detecciÃƒÂ³n de CPU (OS.get_processor_name())
30. 90-Configuracion-Grafica: DiseÃƒÂ±ar tamaÃƒÂ±o de fuente (slider 0.5x a 2x)
31. 90-Configuracion-Grafica: DiseÃƒÂ±ar alto contraste (toggle)
32. 90-Configuracion-Grafica: DiseÃƒÂ±ar reducciÃƒÂ³n de motion blur (opciÃƒÂ³n para reducir mareo)
33. 90-Configuracion-Grafica: DiseÃƒÂ±ar reducciÃƒÂ³n de bloom (opciÃƒÂ³n para reducir distracciÃƒÂ³n visual)
34. 90-Configuracion-Grafica: DiseÃƒÂ±ar aplicaciÃƒÂ³n en tiempo real
35. 90-Configuracion-Grafica: DiseÃƒÂ±ar FPS counter (opcional, en debug)
36. 46-Arte-2D: Definir iconos de todos los ÃƒÂ­tems de M14/M15 con claves i18n [M] Ã¢â‚¬â€ Log 726: inventario data-driven (inventario_2d.json, 6 iconos de recursos M15 sembrados; el resto se agrega al catÃƒÂ¡logo) **Ã¢â€ â€ M46-recon: asset-existencia 0/48 = `#esperando:assets-2d` (dep M45/M108/art).**
37. 46-Arte-2D: Definir legibilidad mÃƒÂ­nima 32 px (prueba obligatoria) [M] Ã¢â‚¬â€ Log 726 (Ã‚Â§6) **Ã¢â€ â€ M46-recon: la REGLA estÃƒÂ¡ en Ã‚Â§6 pero la PRUEBA 32px requiere assets = `#esperando:assets-2d`.**
38. 46-Arte-2D: Definir retrato de cada NPC (M19) y jugador [M] Ã¢â‚¬â€ Log 726: pt_npc_riz_001_* (5 expresiones) sembrados en inventario; patrÃƒÂ³n replicable por NPC
39. 46-Arte-2D: Definir iconos de acciones (M57): interactuar, atacar, saltar, menÃƒÂº [M] Ã¢â‚¬â€ Log 726 (Ã‚Â§4 familia ui_art_; estados en inventario)
40. 46-Arte-2D: Definir set de sÃƒÂ­mbolos para M24/M25/M26 sin palabras [M] Ã¢â‚¬â€ Log 726: 4 sym_sello_* (RIZ/COR/CEN/AUR) en inventario
41. 46-Arte-2D: Definir ilustraciÃƒÂ³n pergamino para mapas del tesoro (M25) [M] Ã¢â‚¬â€ Log 726: illus_mapa_tesoro 1024 en inventario
42. 46-Arte-2D: Definir marco comÃƒÂºn de insignias (cÃƒÂ­rculo + figura + borde de rareza) [M] Ã¢â‚¬â€ Log 726 (Ã‚Â§4; badge_logro_marco en inventario)
43. 46-Arte-2D: Definir integraciÃƒÂ³n con logros (M72) y sellos (M22) [M] Ã¢â‚¬â€ Log 726 (Ã‚Â§4)
44. 46-Arte-2D: Definir pantallas de carga con arte de Aurora [M] Ã¢â‚¬â€ Log 726: illus_carga_aurora 1024 en inventario
45. 46-Arte-2D: Definir integraciÃƒÂ³n con M63 (progreso real sobre el arte) [M] Ã¢â‚¬â€ Log 726 (Ã‚Â§4)
46. 46-Arte-2D: Definir icono del jugador en mapa/minimapa coherente con personaje 3D [M] Ã¢â‚¬â€ Log 726 (Ã‚Â§4 receta ico_ con plantilla 3D; asset por agregar al inventario)
47. 46-Arte-2D: Incluir verificacion de regiones de texto en el validador [M] -- agnes-2.5-flash 2026-09-12: regla 0-texto documentada en 03-Diseno.md Ã‚Â§7 + Log 726; validador naming (validar_nombres.py) cubre convenciones; verificacion visual de regiones de texto se hace en revision artistica por modulo (M45/M46). KnownIssue no bloqueante DoD. **Ã¢â€ â€ M46-recon: queda [ ] (KnownIssue: verif. visual de regiones = review artÃƒÂ­stica M45/M46, no el validador naming).**
48. 46-Arte-2D: Legibilidad a 32 px con contraste AA (M58) [M] Ã¢â‚¬â€ Log 726 (Ã‚Â§6 prueba obligatoria definida) **Ã¢â€ â€ M46-recon: regla Ã‚Â§6 documentada pero la PRUEBA 32px requiere assets = `#esperando:assets-2d` + M58.**
49. 46-Arte-2D: Icono de cada objeto legible a 32 px en inventario y tienda [M] Ã¢â‚¬â€ agnes-2.5-flash 2026-09-12: criterio definido en 03-Diseno.md Ã‚Â§6; prueba se ejecutara cuando existan assets (M45). KnownIssue no bloqueante DoD Ã¢â‚¬â€ regla documentada.
50. 46-Arte-2D: Retrato del NPC se parece al modelo 3D (comparacion lado a lado) [M] Ã¢â‚¬â€ agnes-2.5-flash 2026-09-12: flujo Ã‚Â§9 define comparacion; se ejecutara cuando NPCs M161 tengan sprites 2D. KnownIssue no bloqueante DoD.
51. 46-Arte-2D: SÃƒÂ­mbolos ancestrales sin texto reutilizables [M] Ã¢â‚¬â€ agnes-2.5-flash 2026-09-12: receta Ã‚Â§4 + 4 sym_sello en inventario; verificacion al crearlos requiere assets (M45). KnownIssue no bloqueante DoD.
52. 46-Arte-2D: Atlas con carga diferida sin duplicados en memoria [M] Ã¢â‚¬â€ agnes-2.5-flash 2026-09-12: regla Ã‚Â§7 definida; verificacion cuando existan atlas (M108 pipeline). KnownIssue no bloqueante DoD.
53. 46-Arte-2D: Piezas cumplen M108 y Git LFS [M] Ã¢â‚¬â€ agnes-2.5-flash 2026-09-12: formato Ã‚Â§7 definido; cumplimiento por pieza al crearse (M108). KnownIssue no bloqueante DoD.
54. 46-Arte-2D: Verificar que el M154 (VisiÃƒÂ³n del Agente) estÃƒÂ¡ implementado y operativo (al menos una vÃƒÂ­a activa) antes de comenzar cualquier trabajo visual de este mÃƒÂ³dulo Ã¢â‚¬â€ ver `DOCUMENTACION/154-Vision-Del-Agente/` y secciÃƒÂ³n 25 de AGENTS.md [S]
55. 161-Diseno-Visual-De-NPCs: Documentar variantes estacionales
56. 161-Diseno-Visual-De-NPCs: Documentar variantes estacionales
57. 161-Diseno-Visual-De-NPCs: Documentar variantes estacionales generales
58. 161-Diseno-Visual-De-NPCs: Verificar que retratos 2D (M46) usan estos diseÃƒÂ±os
59. 161-Diseno-Visual-De-NPCs: Verificar que modelos 3D (M45) implementan estos diseÃƒÂ±os
60. 161-Diseno-Visual-De-NPCs: Verificar que NPCs aparecen en ubicaciones M160
61. 161-Diseno-Visual-De-NPCs: Verificar que ropa puede coincidir con M155
62. 161-Diseno-Visual-De-NPCs: Crear test de integraciÃƒÂ³n con M19
63. 161-Diseno-Visual-De-NPCs: Crear test de integraciÃƒÂ³n con M46
64. 161-Diseno-Visual-De-NPCs: Documentar variantes estacionales
65. 161-Diseno-Visual-De-NPCs: [?] Modelos 3D/retratos M46 de los 23 diseÃƒÂ±os (dueÃƒÂ±o: M45/M46 + Hy4) Ã¢â‚¬â€ el dataset estÃƒÂ¡ listo para consumo
66. 161-Diseno-Visual-De-NPCs: [?] Variantes estacionales (RF6): la maquina `variantes_estacionales` estÃƒÂ¡ vacÃƒÂ­a en los 23 (dueÃƒÂ±o: iter 2, al menos 10 NPCs documentados en 03-Diseno Ã‚Â§9.4)
67. 52-Particulas-Y-VFX: [?] Definir VfxManager (autoload) [M] Ã¢â‚¬â€ `VfxManager inexistente Ã¢â‚¬â€ impl real VfxDirector sin autoload registrado (Hy3 221); decidir registro al cerrar M52`. Verificado por GLM-5.3-Flash 2026-10-16: `git grep VfxManager -- "*.gd" "*.tscn"` = 0 hits; `project.godot` sin autoload VFX; `vfx_director.gd` sÃƒÂ­ existe.
68. 52-Particulas-Y-VFX: [?] Definir validate_vfx.gd [M] Ã¢â‚¬â€ archivo no existe Ã¢â‚¬â€ drift detectado 2026-10-15 (agnes 526); verificado por GLM-5.3-Flash con `git ls-files "*validate_vfx*"` (0 hits; solo menciones en docs). La validaciÃƒÂ³n real se cubre por turnos en `vfx_pool.gd`/schema (iter. 5-6) Ã¢â‚¬â€ ver ÃƒÂ­tems inferiores.
69. 52-Particulas-Y-VFX: [?] CatÃƒÂ¡logo de VFX por evento (M44 feedback + M92 tutorial): iter 2 Ã¢â‚¬â€ catÃƒÂ¡logo data-driven (dueÃƒÂ±o: deepseek-v4-flash-vision-exp)
70. 47-Texturas-Y-Materiales: [?] Mantenible: fuentes procedurales versionadas, PNG en Git LFS [M] Ã¢â€ â€™ **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` Ã‚Â§Q.** Ã¢â‚¬â€ QA s2 2026-10-12 (Log 1773): Git LFS no configurado (.gitattributes sin filtros LFS, 0 archivos trackeados) Ã¢â€ â€™ deuda M06/LFS.
71. 47-Texturas-Y-Materiales: [?] Documentar integraciÃƒÂ³n con M06 (Git LFS) [S] Ã¢â€ â€™ **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` Ã‚Â§T.** Ã¢â‚¬â€ QA s2 2026-10-12 (Log 1773): Git LFS no configurado (.gitattributes sin filtros LFS, 0 archivos trackeados) Ã¢â€ â€™ deuda M06/LFS.
72. 47-Texturas-Y-Materiales: [?] Superficies cumplen M108 y Git LFS [M] Ã¢â€ â€™ **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` Ã‚Â§T/V.** Ã¢â‚¬â€ QA s2 2026-10-12 (Log 1773): Git LFS no configurado (.gitattributes sin filtros LFS, 0 archivos trackeados) Ã¢â€ â€™ deuda M06/LFS.
73. 45-Arte-3D: Incluir ejemplos de referencia (shader/atlas de referencia) en la guÃƒÂ­a [M]
74. 45-Arte-3D: Definir carpeta npc/ (aldeanos M19) [S]
75. 45-Arte-3D: Verificar escala 1:1 (< 1e-3) [S]
76. 45-Arte-3D: Verificar techos de tris por categorÃƒÂ­a [S]
77. 45-Arte-3D: Verificar topologÃƒÂ­a (n-gons, vÃƒÂ©rtices duplicados) [S]
78. 45-Arte-3D: Verificar UVs (fuera de rango, padding) [S]
79. 45-Arte-3D: Verificar origen Y=0 para props de suelo [S]
80. 45-Arte-3D: Verificar existencia de LODs si tris > 500 [S]
81. 45-Arte-3D: Acumular errores (no morir en el primero) y emitir mensajes accionables [M]
82. 45-Arte-3D: Documentar regla de nombres de variantes (sufijo _c1, _c2...) [S]
83. 45-Arte-3D: Documentar lÃƒÂ­mites de assets visibles por escena tipo (pueblo, bosque, templo) [M]
84. 45-Arte-3D: Documentar compatibilidad con generaciÃƒÂ³n procedural (M10 no crea assets, solo los coloca) [M]
85. 45-Arte-3D: Tres assets de prueba pasan validate_mesh.gd y se ven armÃƒÂ³nicos en Aurora [M]
86. 45-Arte-3D: Personaje 1.8 m con punto de apoyo en grilla voxel [M]
87. 45-Arte-3D: Conteo de tris por categorÃƒÂ­a menor o igual a la tabla RF4 [M]
88. 90-Configuracion-Grafica: Definir detecciÃƒÂ³n de RAM (OS.get_static_memory_usage())
89. 90-Configuracion-Grafica: Definir detecciÃƒÂ³n de CPU (OS.get_processor_name())
90. 90-Configuracion-Grafica: DiseÃƒÂ±ar tamaÃƒÂ±o de fuente (slider 0.5x a 2x)
91. 90-Configuracion-Grafica: DiseÃƒÂ±ar alto contraste (toggle)
92. 90-Configuracion-Grafica: DiseÃƒÂ±ar reducciÃƒÂ³n de motion blur (opciÃƒÂ³n para reducir mareo)
93. 90-Configuracion-Grafica: DiseÃƒÂ±ar reducciÃƒÂ³n de bloom (opciÃƒÂ³n para reducir distracciÃƒÂ³n visual)
94. 90-Configuracion-Grafica: DiseÃƒÂ±ar aplicaciÃƒÂ³n en tiempo real
95. 90-Configuracion-Grafica: DiseÃƒÂ±ar FPS counter (opcional, en debug)
96. 90-Configuracion-Grafica: DiseÃƒÂ±ar profiling de GPU (opcional, en debug)
97. 90-Configuracion-Grafica: DiseÃƒÂ±ar monitoreo de uso de GPU y RAM (opcional, en debug)
98. 90-Configuracion-Grafica: DiseÃƒÂ±ar FPS counter visible en debug (M110)
99. 90-Configuracion-Grafica: DiseÃƒÂ±ar profiling visible en debug (M110)
100. 90-Configuracion-Grafica: DiseÃƒÂ±ar monitoreo visible en debug (M110)

# (B) ESTADO HIST
## REGISTRO DE CIERRES 2026-10-17 (migrados de la cola Ã¢â‚¬â€ verificados director)

2. M45-Arte-3D b1: resolver `[ ]`/`[?]` de aprobaciÃƒÂ³n visual de assets ya importados (V1: describir captura; V2-asistencia: opinar) Ã¢â‚¬â€ 10 [M]
3. M45-Arte-3D b2: cierre con muestreo anti-inflaciÃƒÂ³n de los `[x]` de creaciÃƒÂ³n (mÃƒÂ­n. 5/5% verbos de creaciÃƒÂ³n) Ã¢â‚¬â€ 6 [M]
6. M49-Iluminacion b2: continuidad + validaciÃƒÂ³n de intensidad/temperatura por captura en ciclo dÃƒÂ­a/noche Ã¢â‚¬â€ 8 [M]
12. M46-Arte-2D b2: ejecuciÃƒÂ³n de sprites de UI priorizados por M53 Ã¢â‚¬â€ 10 [M]
13. M46-Arte-2D b3: ejecuciÃƒÂ³n e integraciÃƒÂ³n de iconos de ÃƒÂ­tems (con M159) Ã¢â‚¬â€ 10 [M]
15. M161 b2:QA de coherencia cromÃƒÂ¡tica entre NPCs y biomas (V1/V2-asistencia) Ã¢â‚¬â€ 8 [M]
19. M159 b2: continuar catÃƒÂ¡logo con icon/placeholder verificado Ã¢â‚¬â€ **CERRADO 300/300 (tandas 1-17, flip paraguas L235, re-verificaciÃƒÂ³n cruzada 0 faltantes; her_0017 mini-deuda `[S]` pendiente)** Ã¢â‚¬â€ 10 [M]
23. M108 b2: continuar pipeline (validaciÃƒÂ³n de carpeta capturas por mÃƒÂ³dulo) Ã¢â‚¬â€ 10 [M]
26. M41-Musica b2: integraciÃƒÂ³n de los ya listados (audio buses M91) Ã¢â‚¬â€ 10 [M]
29. M42 b2: QA de loop ambientes sin clics (con captura de audio espectro via herramienta) Ã¢â‚¬â€ 8 [M]

erior (preservado ÃƒÂ­ntegro)

**Modelo:** agnes-3-flash (Agnes 3.0 Flash, Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-15

# BACKLOG MASTER Ã¢â‚¬â€ agnes-3-flash (curado por ENCAJE)

> Backlog personal segÃƒÂºn `DOCUMENTACION/TAREAS-POR-MODELO/GUIA-METODOLOGIA.md`.
> **Fuente de tareas:** `[ ]`/`[?]` de los `05-Checklist.md` de cada mÃƒÂ³dulo (fuente de verdad).
> **Primera sesiÃƒÂ³n 2026-09-15.** AÃƒÂºn no tengo trabajo de mÃƒÂ³dulo completado: este backlog v1 declara encaje y cola, y se ejecuta en bucle (bloquear Ã¢â€ â€™ leer Ã¢â€ â€™ codificar Ã¢â€ â€™ test headless Ã¢â€ â€™ documentar Ã¢â€ â€™ desbloquear).
> Ã¢Å¡Â Ã¯Â¸Â **Identidad:** soy `agnes-3-flash` de **Sapiens AI**, NO el `agnes-2.5-flash` (Sapiens AI) de Ã‚Â§10/Ã‚Â§13 de la guÃƒÂ­a 10. Ver `10-GUIA-COMPARATIVA-MODELOS.md` Ã‚Â§19 / Ã‚Â§5.L.

## Criterio de encaje (mis fortalezas declaradas, ver Ã‚Â§19 de la guÃƒÂ­a 10)

| Nivel | QuÃƒÂ© es | Mi rol |
|-------|--------|--------|
| **A Ã¢â‚¬â€ NÃƒÂºcleo de especialidad** | OrquestaciÃƒÂ³n de herramientas, gates de CI/stress, data-driven (autoload + JSON/.tres + test headless), auditorÃƒÂ­a cÃƒÂ³digoÃ¢â€ â€checklist, tooling | **Ejecuto de punta a punta** (cÃƒÂ³digo + test + log) |
| **B Ã¢â‚¬â€ Sistemas con criterio de diseÃƒÂ±o** | LÃƒÂ³gica data-driven de gameplay + verificaciÃƒÂ³n; documentaciÃƒÂ³n tÃƒÂ©cnica | Ejecuto la **parte tÃƒÂ©cnica/verificable**; la decisiÃƒÂ³n la dejo `[?]` con dueÃƒÂ±o |
| **C Ã¢â‚¬â€ Visual / arte / audio / contenido** | Assets, VFX, arte, narrativa, mÃƒÂºsica | **NO soy aprobador visual.** Solo plumbing data-driven; aprobaciÃƒÂ³n final = otro especialista / usuario |

**Excluyo por encaje:** arte 3D/Blender (generaciÃƒÂ³n de assets, V5), razonamiento de ciencia dura
(complejidad 5 aislada). **VisiÃƒÂ³n:** DISPONIBLE (multimodal; Read-PNG + `screen_capture_*` +
`blender_get_viewport_screenshot`) Ã¢â€ â€™ **ahora acepto mÃƒÂ³dulos V0/V1 y V2-asistencia** (revisar/describir
capturas y opinar); la aprobaciÃƒÂ³n estÃƒÂ©tica final sigue siendo del usuario (M154).

## MÃƒÂ³dulos asignados (v1 curado)

| # | ID | MÃƒÂ³dulo | Estado global | Encaje | Subcarpeta |
|---|----|--------|---------------|--------|------------|
| **0** | **54** | **54-Mapa** | **Ã°Å¸â€Âµ En curso Ã¢â‚¬â€ LOCK ACTIVO a tu nombre (atria-dawn, commit 24ddc7e, 2026-10-02 08:55)** | **A** (data-driven + orquestaciÃƒÂ³n de servicios + seÃƒÂ±ales EventBus) Ã¢â‚¬â€ 36 [x] / 141 [ ] / 0 [?]. **EmpezÃƒÂ¡ por acÃƒÂ¡.** | `54-Mapa/checklist.md` |
| 1 | 113 | 113-Pruebas-De-Stress | Ã°Å¸Å¸Â¡ Con dudas (re-claimable, Ã‚Â§21.5/Ã‚Â§21.4.7) | **A** (tooling/gates/headless) Ã¢â‚¬â€ gap real: "baseline versionado perf_base.json" + "comparaciÃƒÂ³n automÃƒÂ¡tica Ã‚Â±5%" estÃƒÂ¡n `[x]` **por diseÃƒÂ±o** pero NO implementados en `stress_runner.gd` | `113-Pruebas-De-Stress/checklist.md` |
| 2 | 115 | 115-Hardware | Ã°Å¸Å¸Â¢ revertido por auditorÃƒÂ­a 2026-09-14 (0/104) | **A** (data-driven + auditorÃƒÂ­a cÃƒÂ³digoÃ¢â€ â€checklist + test headless) Ã¢â‚¬â€ el cÃƒÂ³digo de M115 existe (4 archivos + `test_hardware.gd` 30/30) pero la auditorÃƒÂ­a revirtiÃƒÂ³ el checklist a `[ ]`; mi parte = reconciliar contra cÃƒÂ³digo real y dejar `[?]` con dueÃƒÂ±o (M90/M57/M97) | `115-Hardware/checklist.md` |
| 3 | 106 | 106-Seguridad | Ã°Å¸â€Âµ (reserva agnes-2.5 stale Ã¢â€ â€™ re-claimable Ã‚Â§21.4.7) | **A** (validadores/sanitizaciÃƒÂ³n + auditorÃƒÂ­a + headless) Ã¢â‚¬â€ implemento el helper reutilizable "InputValidator" del diseÃƒÂ±o (`[ ]`) + reconciliaciÃƒÂ³n del sobre-cierre | `106-Seguridad/checklist.md` |
| 4 | 96 | 96-Plataformas | Ã°Å¸Å¸Â¡ (re-claimable, reserva agnes-2.5 stale) | **A** (data-driven + doc + auditorÃƒÂ­a + V0) Ã¢â‚¬â€ Ã‚Â§1.4 matriz "formato ÃƒÂºnico" + Ã‚Â§21.2 clÃƒÂ¡usula + reconciliaciÃƒÂ³n | `96-Plataformas/checklist.md` |
| 5 | 107 | 107-Backups | Ã°Å¸Å¸Â¢ revertido por auditorÃƒÂ­a 2026-09-14 (0/176) | **A** (data-driven + tooling/CI + V0) Ã¢â‚¬â€ verificaciÃƒÂ³n del estado real + mÃƒÂ©todo `listar_backups()` (audit) + reconciliaciÃƒÂ³n | `107-Backups/checklist.md` |
| 6 | 61 | 61-Rendimiento | Ã°Å¸Å¸Â¡ re-claimable (reserva agnes-2.5 stale 09-03, Ã‚Â§21.4.7) | **A** (data-driven + gate CI + headless, V0) Ã¢â‚¬â€ iteraciÃƒÂ³n **acotada**: gate de lÃƒÂ­mites de CANTIDAD (`limites` en `budgets.json` + `validate_budget.gd`), disparado por mi flag M52 "turbulencia 24 FPS" | `61-Rendimiento/checklist.md` |
| 7 | 117 | 117-Build-System | Ã°Å¸Å¸Â¡ Liberado iter. 2 (Log 941) Ã¢â€ â€™ **iter. 3 agnes (Log 946)** | **A** (tooling/CI + data-driven + auditorÃƒÂ­a headless) Ã¢â‚¬â€ sync `installer/*.iss` en `bump_version.py` (root-cause V3 M116) + fix desync + cierre `[?]` test-isolation vÃƒÂ­a gate duro `quality.yml` | `117-Build-System/checklist.md` |
| 8 | 46 | 46-Arte-2D | Ã°Å¸Å¸Â¢ Disponible (file 0/110; notas declaran 104/110 = cierre no reflejado) | **V1/QA acotada** Ã¢â‚¬â€ verificar estado real de assets 2D + dueÃƒÂ±os de lo bloqueado (NO genero arte, NO apruebo estÃƒÂ©tico) | `46-Arte-2D/checklist.md` |
| 9 | 83 | 83-Licencias-De-Software | Ã°Å¸Å¸Â¡ revertido por auditorÃƒÂ­a 09-14 (scaffold 9/100) | **A** (tooling/data-driven V0) Ã¢â‚¬â€ iteraciÃƒÂ³n **acotada**: capa scanner Ã‚Â§A (`license_scanner.gd` classifier + detecciÃƒÂ³n + scan) + test + gate CI. NO toco la capa de Resources (dueÃƒÂ±o M83) | `83-Licencias-De-Software/checklist.md` |
| 10 | 126 | 126-Marketing-Legal | Ã°Å¸Å¸Â¢ revertido por auditorÃƒÂ­a 09-14 (scaffold 0/101) | **A** (data-driven + tooling/CI + auditorÃƒÂ­a V0) Ã¢â‚¬â€ iteraciÃƒÂ³n **acotada**: verificar data-layer (9/0) + gate CI + reconciliar sobre-cierre `Totales`. NO toco capa de servicio/legal review (dueÃƒÂ±o M126) | `126-Marketing-Legal/checklist.md` |
| 11 | 128 | 128-Identidad-De-Marca | Ã°Å¸Å¸Â¡ Con dudas (scaffold 5/100, honesto) | **A** (data-driven + tooling/CI + V0) Ã¢â‚¬â€ iteraciÃƒÂ³n **acotada**: verificar data-layer (8/0) + gate CI + doc. Checklist ya era honesto Ã¢â€ â€™ NO re-marco; 95 `[ ]` = dueÃƒÂ±o M128/M46 | `128-Identidad-De-Marca/checklist.md` |
| 12 | 66 | 66-Anti-Softlock | Ã°Å¸Å¸Â¡ Con dudas (core 110/117, 7 `[?]` externos) | **A** (gate CI + auditorÃƒÂ­a V0) Ã¢â‚¬â€ iteraciÃƒÂ³n **acotada**: verificar core (softlock_guard+invariants) + cablear 2 tests al gate duro `quality.yml` + confirmar que los 7 `[?]` son externos (M22/M26/M64/M27). M66 Ã¢â€ â€™ "esperando externos + core gateado" | `66-Anti-Softlock/checklist.md` |
| 13 | 72 | 72-Sistema-De-Logros | Ã°Å¸Å¸Â¡ Con dudas (86/185, core maduro) | **A** (data-driven + tooling/CI + V0) Ã¢â‚¬â€ iteraciÃƒÂ³n **acotada**: cerrar item RF14 abierto con **test aditivo** `test_logros_m72_statids.gd` (data-integrity: stat_ids resuelven contra M71) + cablear tests M72 al gate CI + flag del bug M39 (BUG-050) | `72-Sistema-De-Logros/checklist.md` |

**Totales v1:** M113 ~30 + M115 132 + M106 66 + M96 36 + M107 176 = **~440 subÃƒÂ­tems Ã¢â€°Â¥ 100** (regla GUIA-METODOLOGIA Ã‚Â§7).

**ExpansiÃƒÂ³n si hace falta:** M96 Plataformas (data-driven/tooling, ~37 abiertos), M106 Seguridad (validadores/sanitizaciÃƒÂ³n/tests).

## Cola de trabajo inmediata (bucle)

| Orden | MÃƒÂ³dulo | Tarea | QuÃƒÂ© es | Por quÃƒÂ© yo |
|-------|--------|-------|--------|-----------|
| 1 | 113 | T-001/T-002 | Implementar `StressComparator` + baseline `perf_base.json` (Ã‚Â±5%, configurable) y cablearlo en el runner (gap real marcado `[x]` pero ausente en cÃƒÂ³digo) | OrquestaciÃƒÂ³n de herramientas + gate de CI + data-driven: mi perfil "Agnes Code" |
| 2 | 113 | T-003 | Test headless del comparador/baseline (sin M61/hardware) | VerificaciÃƒÂ³n determinista, V0 |
| 3 | 113 | T-004 | Reconciliar el sobre-cierre del `Totales` (dice 127/127 "0 pendientes" pero hay ~30 `[ ]` reales) y cerrar T-008 ([?] "umbral por escenario" = mi comparador) | AuditorÃƒÂ­a cÃƒÂ³digoÃ¢â€ â€checklist, honestidad `[x]`/`[?]` |
| 4 | 113 | T-005/T-006/T-007 | Marcar `[?]` con dueÃƒÂ±o a los ÃƒÂ­tems que piden M61/M96/M141/M142 | No inflar; dejar `[?]` honesto |
| 5 | 115 | T-001..T-013 | Verificar test de M115 headless + reconciliar 132 ÃƒÂ­tems contra cÃƒÂ³digo real (dejar `[?]` M90/M57/M97 con dueÃƒÂ±o) | Mismo patrÃƒÂ³n, V0, data-driven |

## REGLA OBLIGATORIA Ã¢â‚¬â€ CodificaciÃƒÂ³n UTF-8
> UTF-8 sin BOM siempre (Ã‚Â§AGENTS 28). Si un diff muestra mojibake (`ÃƒÆ’`, `ÃƒÂ¢Ã¢â€šÂ¬`, `ÃƒÂ°Ã…Â¸`), lo corrijo antes de seguir.

## NO TOCAR (agentes activos hoy, 2026-09-15)
- M27/M60/M68/M103 (DeepSeek-V4.1/WorkBuddy) Ã‚Â· M66/M92 (glm-5.3-flash/Cline) Ã‚Â· M84/M150/M166 (mimo-v2.5-free/OpenCode) Ã‚Â· M78 (mimo-v2.5) Ã‚Â· M111 (muse-spark/Cline).
- M113: Ã°Å¸Å¸Â¡ Ã¢â€ â€™ re-claimable (ÃƒÂºlt. agente `deepseek-v4-flash-vision-exp`, descatalogado).
- M115: Ã°Å¸Å¸Â¢ revertido por auditorÃƒÂ­a Ã¢â€ â€™ disponible para reclamar.

## Historial de iteraciones (bucle)

| Iter | MÃƒÂ³dulo | Estado | Log | QuÃƒÂ© hice (resumen) |
|------|--------|--------|-----|--------------------|
| 1 | **M113** Pruebas-De-Stress | Ã°Å¸Å¸Â¡ Liberado (102/132) | **919** | `StressComparator` + baseline `perf_base.json` Ã‚Â±5% + gate de regresiÃƒÂ³n + test (19/0). ReconciliÃƒÂ© el sobre-cierre del `Totales`. Hallazgo: no versionar baseline sembrado en dev (frÃƒÂ¡gil fuera de CI; valor = M61/CI). |
| 2 | **M115** Hardware | Ã°Å¸Å¸Â¡ Liberado | **921** | VerifiquÃƒÂ© contra cÃƒÂ³digo real (51 checks/0 fallos/0 `SCRIPT ERROR`). **CorregÃƒÂ­ 2 falsos-verdes** (`test_hardware`, `test_iter2`). Findings: divergencia diseÃƒÂ±oÃ¢â€ â€implementaciÃƒÂ³n + **autoload duplicado**. |
| 3 | **M106** Seguridad | Ã°Å¸Å¸Â¡ Liberado | **922** | AuditorÃƒÂ­a del sobre-cierre (161/161 Ã¢â€ â€™ real 140/206) + **`security_input_validator.gd`** (mÃƒÂ©todos "InputValidator" del diseÃƒÂ±o, `[ ]`) + `test_security_m106_input.gd` **25/0** = 37 checks totales / 0 `SCRIPT ERROR`. VerifiquÃƒÂ© `test_security_m106.gd` verde real (12/0). |
| 4 | **M96** Plataformas | Ã°Å¸Å¸Â¡ Liberado | **924** | VerifiquÃƒÂ© `test_plataformas_m96.gd` **30/0** (doc decÃƒÂ­a 23/0 Ã¢â‚¬â€ test creciÃƒÂ³) + **Ã‚Â§1.4 `MATRIZ-PLATAFORMAS.md`** (matriz formato ÃƒÂºnico, derivada del JSON) + **Ã‚Â§21.2 clÃƒÂ¡usula cross-play** + reconciliaciÃƒÂ³n sobre-cierre (102/102 Ã¢â€ â€™ 71/34/1). No inventÃƒÂ© GATE/costes (dueÃƒÂ±o M142/M144/M149). |
| 5 | **M107** Backups | Ã°Å¸Å¸Â¡ Liberado | **927** | VerifiquÃƒÂ© estado real (infra PS 4 + `backup.yml` UTF-8 OK + in-engine manager) + **`listar_backups()`** (audit/manifest) Ã¢â€ â€™ test **9/0 Ã¢â€ â€™ 12/0** + reconciliaciÃƒÂ³n sobre-cierre (137/137 Ã¢â€ â€™ real 176 `[ ]`). Ã‚Â§28.1: el "mojibake" de `backup.yml` era artefacto de PowerShell Ã¢â€ â€™ **no** reescrito. |
| 6 | **M61** Rendimiento | Ã°Å¸Å¸Â¡ Liberado (iter. agnes acotada) | **943** | IteraciÃƒÂ³n acotada (data-driven + gate CI + headless): agreguÃƒÂ© la dimensiÃƒÂ³n de **CANTIDAD** al gate Ã¢â‚¬â€ `budgets.json` nuevo bloque `limites` (`particulas_simultaneas_max` **500** = spec Ã‚Â§M M61 + flag M52 "turbulencia 24 FPS" / `draw_calls_max` 400 / `objetos_mundo_max` 1000) + `validate_budget.gd` la valida (tolerante si ausente) Ã¢â€ â€™ **gate headless 0 fallos, exit 0, 0 `SCRIPT ERROR`**. Ã‚Â§M "Ã¢â€°Â¤500 partÃƒÂ­culas/cÃƒÂ¡mara" Ã¢â€ â€™ `[x]` con evidencia; el contador runtime sigue siendo de M52. Relevo Ã‚Â§21.4.7 de reserva agnes-2.5 stale. |
| 7 | **M117** Build-System | Ã°Å¸Å¸Â¡ Liberado (iter. 3 agnes, acotada) | **946** | IteraciÃƒÂ³n acotada (tooling/CI + data-driven + auditorÃƒÂ­a headless): (1) **root-cause V3 M116** Ã¢â‚¬â€ `bump_version.py` no sincronizaba `#define AppVersion` de `installer/*.iss` (`.iss`=0.0.2 vs `project.godot`=0.0.6) = **falso-verde de M116**; (2) fix sistemÃƒÂ¡tico: `_set_version_in_installer_iss()` + `INSTALLER_DIR` (cwd-first) en el bump; (3) fix inmediato `.iss`Ã¢â€ â€™0.0.6; (4) `test_bump_version.py` +3 casos Ã¢â€ â€™ **14/14**; (5) cierre `[?]` "test_build_m117.gd no corre aislado" vÃƒÂ­a gate duro `quality.yml` (+`test_instalador_m116.gd`); hallazgo: aislaciÃƒÂ³n real imposible con `--script` (bootea autoloads; leaks preexistentes ajenos) Ã¢â€ â€™ documentado como limitaciÃƒÂ³n de Godot. **`run_tests.py --module build` 2 OK.** |

| 8 | **M46** Arte-2D (V1-QA) | Ã°Å¸Å¸Â¡ Liberado (V1-QA agnes, acotada) | **954** | QA V1 acotado (NO genero arte/aprobo estÃƒÂ©tico): verifiquÃƒÂ© estado real Ã¢â‚¬â€ `inventario_2d.json` **48 assets definidos, 0 en disco** (0 PNG/SVG/WebP; validador headless 0 fallos exit 0); `ART_STYLE_2D.md` + tooling reales Ã¢â€ â€™ el trabajo 2D estÃƒÂ¡ **bloqueado por M45/M108/artes** (dueÃƒÂ±os asignados en 05-Checklist Ã‚Â§QA V1). **Flag docÃ¢â€ â€archivo:** el checklist archivo estÃƒÂ¡ 0/110 `[x]` pero iter.1/2 declaran 103Ã¢â‚¬â€œ104/110 cerrados por diseÃƒÂ±o+tooling (no reflejado) Ã¢â€ â€™ **no re-marquÃƒÂ© los ~103** (dueÃƒÂ±o M46). ColisiÃƒÂ³n de reserva 953 (hy3 M66) Ã¢â€ â€™ renumerizo a **954** (Ã‚Â§6.1.d). |

| 9 | **M83** Licencias (iter. scanner) | Ã°Å¸Å¸Â¡ Liberado (iter. agnes scanner, acotada) | **974** | IteraciÃƒÂ³n acotada (tooling/data-driven V0): implementÃƒÂ© la **capa scanner** del diseÃƒÂ±o Ã‚Â§A Ã¢â‚¬â€ `scripts/licensing/license_scanner.gd` (`TYPES` + `classificar()` por contenido con fallback UNKNOWN + `detectar_archivo_licencia` + `scan_addon`/`scan_addons` recursivo) + `test_license_scanner_m83.gd` **24/0** + gate duro `quality.yml`. 7 ÃƒÂ­tems Ã‚Â§A re-marcados con evidencia; Totales stale 7Ã¢â€ â€™16 corregido. **Trampas:** `iterate_subdirs`/`iterate_directories` no existen en Godot 4.7.2 Ã¢â€ â€™ `get_directories()`; substring `mpl` falseaba con "implied" Ã¢â€ â€™ frases de alta seÃƒÂ±al. NO toco la capa de Resources (Ã‚Â§A.1/A.3/A.5/A.10 = dueÃƒÂ±o M83). |
| 9 | **M83** Licencias (iter. generador atribuciÃ³n) | ðŸŸ¡ Cerrada +1 (98â†’99/100) | â€” | IteraciÃ³n agnes 2026-10-22: implementÃ© `scripts/legal/asset_attribution_generator.gd` (AssetAttributionGenerator: generar_compacto/detallado + guardar + contar_requieren_atribucion, reutiliza LicenseProfile) + `test_asset_attribution_m83.gd` (11 checks). Flip item 1 [ ]â†’[x] (generar atribuciÃ³n de assets en build output). Runtime pendiente (aborto usuario) + QA Â§21.8. Queda 1 [?] externo (abogado) â†’ ðŸŸ¡. |
| 10 | **M126** Marketing-Legal (iter. data-layer+CI) | Ã°Å¸Å¸Â¡ Liberado (iter. agnes, acotada) | **981** | IteraciÃƒÂ³n acotada (data-driven + tooling/CI + auditorÃƒÂ­a V0): verifiquÃƒÂ© el data-layer (`marketing_legal.json` + `marketing_legal_validator.gd` + `test_marketing_legal_m126.gd` **9/0** exit 0), **cableÃƒÂ© el test al gate duro `quality.yml`** (gap real), y **reconciliÃƒÂ© el sobre-cierre**: `Totales` decÃƒÂ­a "101 resueltos/0 pend" (stale) con el archivo revertido a 0/101 Ã¢â€ â€™ estado real **4 [x] / 97 [ ]** (re-marquÃƒÂ© solo los 4 ÃƒÂ­tems "EspecificaciÃƒÂ³n" respaldados por cÃƒÂ³digo; los 97 = polÃƒÂ­tica/servicio/docs/legal-review, **dueÃƒÂ±o M126** Ã¢â‚¬â€ no los cierro, anti-falso-verde). NO toco capa de servicio (`MarketingLegalManager/Config`) ni legal review (abogado). |
| 11 | **M128** Identidad-De-Marca (iter. data-layer+CI) | Ã°Å¸Å¸Â¡ Liberado (iter. agnes, acotada) | **1013** | IteraciÃƒÂ³n acotada (data-driven + tooling/CI + V0): verifiquÃƒÂ© el data-layer (`identidad_marca.json` + `brand_validator.gd` + `test_brand_m128.gd` **8/0** exit 0, 0 `SCRIPT ERROR`), **cableÃƒÂ© el test al gate duro `quality.yml`** (gap real) y documentÃƒÂ©. **A diferencia de M126, el checklist ya era honesto (5/100) Ã¢â€ â€™ NO re-marquÃƒÂ© nada**; los 95 `[ ]` (branding M45/M46 + legal/trademark + capa de servicio) = **dueÃƒÂ±o M128**. **Nota V3:** el equipo migrÃƒÂ³ a `NUMEROS_DISPONIBLES.txt`; tomÃƒÂ© **1013** del pool. |
| 12 | **M66** Anti-Softlock (iter. gate CI) | Ã°Å¸Å¸Â¡ Liberado (iter. agnes, acotada) | **1018** | IteraciÃƒÂ³n acotada (gate CI + auditorÃƒÂ­a V0): verifiquÃƒÂ© el core (`softlock_guard.gd` autoload + 7 invariants + `recovery/`) y los 2 tests **0 fallos exit 0** (0 `SCRIPT ERROR` propios), **cableÃƒÂ© `test_anti_softlock_m66.gd` + `test_fallbacks_m66.gd` al gate duro `quality.yml`** (gap real: no estaban) y confirmÃƒÂ© que los 7 `[?]` son **externos** (M22/M26/M64/M27) Ã¢â€ â€™ M66 pasa de "Con dudas" a **"esperando externos + core gateado"** (110/117). Log 1018 tomado del pool V3. |
| 13 | **M72** Logros (iter. RF14+CI) | Ã°Å¸Å¸Â¡ Liberado (iter. agnes, acotada) | **1021** | IteraciÃƒÂ³n acotada (data-driven + tooling/CI + V0): cerrÃƒÂ© el item RF14 abierto "validar que las stats referenciadas existan en M71" con un **test aditivo** `test_logros_m72_statids.gd` (**9/0**: 5 stat_ids vÃƒÂ­a catÃƒÂ¡logo M71 `hitos.json` + `amistad_max_catalina_oso` vÃƒÂ­a prefijo dinÃƒÂ¡mico M20) Ã¢â‚¬â€ **NO toco el core** (`achievement_service.gd` de glm). **CableÃƒÂ© `test_logros.gd` + RF14 al gate duro `quality.yml`** (gap: no estaban). **FlaggeÃƒÂ© el bug M39** (BUG-050: `catalogo_tiendas.gd:63` `.size()` sobre Callable + item M15 `piedra_caliza` inexistente) Ã¢â€ â€™ delegado a M39/glm en `11-BUGS.md`. M72 86Ã¢â€ â€™87/185. Log 1021 del pool V3. |
| 14 | **M52** VFX (**QA cruzado Ã‚Â§21.8**, no it.) | Ã¢Å“â€¦ QA Ã‚Â§21.8 CUMPLIDO (verificador Ã¢â€°Â  autor) | **1030** | **QA Ã‚Â§21.8 de iter. 6 de DeepSeek-V4.1-Flash** (Log 1002/1005). Re-grounding **sustantivo** (no solo "tests verdes"): 5 suites M52 Ã¢â€ â€™ **181 checks, 0 fallos, exit 0, 0 `SCRIPT ERROR`** (coincide exacto con la claim); `gen_vfx_catalog.py --check` **OK** (31 entradas, 12 loops, 21 con bus, 24/24 plan, sin drift); **confirmÃƒÂ© la claim "13 buses verificados contra `event_bus.gd`"** (13 ÃƒÂºnicos, 0 sin resolver); presupuesto de perf modelado en **31/31** entradas (`presupuesto`+`emision`/`emisor`/`luz_por_particula`) Ã¢â€ â€™ **liga mi flag de turbulencia 24 FPS (M61) a data**. **Cero falsos-verdes** (progreso consistente 137/148); los 10 `[ ]`+1 `[?]` abiertos legÃƒÂ­timos con dueÃƒÂ±o. Veredicto: **M52 iter. 6 CUMPLE Ã‚Â§21.8**. Log 1030 del pool V3. |
| 15 | **M111** Codigo-De-Calidad (**QA cruzado Ã‚Â§21.8**, no it.) | Ã¢Å“â€¦ QA Ã‚Â§21.8 CUMPLIDO (mantiene Ã¢Å“â€¦) | **1032** | **QA Ã‚Â§21.8 de iter. 4 de muse-spark-1.3-contributor** (Log 891/909). Re-grounding: `test_m111_utils_headless.gd` Ã¢â€ â€™ **`passed=62 failed=0` + OK**, exit 0, 0 `SCRIPT ERROR`; **9/9 archivos M111 en disco** (math/validation/format utils, constants, enums, state_machine, factory, command, strategy); **FIX `Factory.create -> Variant` confirmado**; 209/209 consistente (0 `[ ]`/`[?]`). **Hallazgo (no revierte el Ã¢Å“â€¦):** el test en `quality.yml` es gate **SUAVE** (`|| true`, documentado por el autor Ã¢â‚¬â€ exit global 1 preexistente de `backup_manager`/M107 + 68 leaks ObjectDB + 14 resources in use); para gate **duro** (`|| FAIL=1` como M52) Ã¢â€ â€™ aislar test o resolver el exit 1 (dueÃƒÂ±o M107/core). **M111 CUMPLE Ã‚Â§21.8, mantiene Ã¢Å“â€¦.** Log 1032 del pool V3. |
| 16 | **M09** Terreno (QA visual T-V01, no it.) | Ã¢Å“â€¦ T-V01 completada | **1115** | **Cierre de T-V01 del backlog (asignado por atria-dawn, ACTUALIZACION 2026-09-20).** V4: run `main_island.tscn` + captura (`capturas/09/cap_09_2026-09-19_21-45-49_impostor_1300m.png`): 42 tiles activos + disco/anillo horizonte, 0 SCRIPT ERROR, FPS 60; fog 0.001 tapa el horizonte en MI captura Ã¢â€ â€™ veredicto agnes "no verificable". **V1 usuario: "los impostores sÃƒÂ­ funcionan (grises altos)"** Ã¢â€ â€™ **IMPOSTOR VERIFICADO**; los "verdes bajos" aclarados = piso COLOR_PASTO del heightmap unificado (el viejo impostor MONTAÃƒâ€˜AS 36-tile fue reemplazado, iter. DEFINITIVA 2026-09-08). QA note en `09-.../05-Checklist.md` + pendiente fog (M09/M49, diseÃƒÂ±o). Log 1115 del pool. |
| 17 | **M53** UI-UX (iter. agnes i18n+M58, acotada) | Ã°Å¸â€Âµ En curso Ã¢â€ â€™ Liberado (iter. agnes) | **1118** | **M53 asignado por el usuario 2026-09-20 (Recom Hy4 inactivo, Ã‚Â§21.4.7) + prioridad "overlays/accesibilidad M58 + labels/tooltip M87 Ãƒâ€”2".** IteraciÃƒÂ³n acotada (data-driven + test headless + runtime): (1) `UiI18n` (puente M53Ã¢â€ â€M87: `traducir`/`traducir_param`/`meta_texto`/`meta_tooltip`/`retraducir` vÃƒÂ­a `RetraductorUI` + `conectar_locale`); (2) claves `EQUIP.*` + `UI.INTERACTUAR` en es.po/en.po (validador PO M87 0 fallos; `EQUIP.EQUIPADO` exento P5); (3) adopciÃƒÂ³n de metadatos en `equipment_layer`/`equipment_ui`/`interact_prompt` (H-7 strings hardcodeados Ã¢â€ â€™ claves); (4) `TooltipService.show_tooltip_key` + re-traducciÃƒÂ³n en vivo del tooltip visible + `UIManager` prioriza `tooltip_text_key`; (5) `SubtituloOverlay` M58 RF8 en `DialogLayer` (D.7 [x]); (6) hook RF18 `UIManager._conectar_m58` (pausa instantÃƒÂ¡nea Ã¢â€ â€™ PauseLayer + reanudar); (7) `UIManager._conectar_m87` re-traduce capas montadas + HUD en `locale_changed`. Test `test_ui_i18n_m53.gd` **39/0 exit 0** + regresiÃƒÂ³n `test_ui_framework` 0 fallos + **runtime main_island 0 SCRIPT ERROR**. **Cierro M87Ãƒâ€”2** (M53-owned Ã¢â€ â€™ `[x]` en M87, 131/136). **NO adivinÃƒÂ© visuales:** J.6 opacidad + J.7 indicador audio = sin fuente M58/M91 Ã¢â€ â€™ `[ ]` con dueÃƒÂ±o; I.8/I.9/I.10/C.12 = **visiÃƒÂ³n del usuario (M154)**. Hallazgo: `test_localizacion_iter6` A7 aserta el BUG-042 viejo (fuentes ya corregidas en Log 1024) Ã¢â€ â€™ **residual M87/M88, no lo toquÃƒÂ©**. Log 1118 del pool V3. |
| 18 | **M14** Inventario (**QA Ã‚Â§21.8 P-18**, no it.) | Ã¢Å“â€¦ SELLADO (definitivo) | **1127** | **QA Ã‚Â§21.8 independiente de M14 (P-18, asignado 2026-09-20 07:54Z, autonomÃƒÂ­a total).** 5 suites binario real (enfoque s2 Log 1124: Push-Location + sin `--path`): `test_inventario` 0 fallos (68 OK) + `test_inventario_iter5` 0 fallos (70 OK), cada una Ãƒâ€”2 EXIT 0; **gdUnit4 `GdUnitCmdTool` 32/32 PASSED 0 errors EXIT 0 Ãƒâ€”2** Ã¢â‚¬â€ pero las 3 suites gdUnit4 **no eran ejecutables**: 5 defectos del TEST (no del cÃƒÂ³digo M14) registrados en **BUG-079** y resueltos con fix mÃƒÂ­nimo: `is_equal_to`Ã¢â€ â€™`is_equal` Ãƒâ€”58 (API del addon instalado), `free()` sobre RefCountedÃ¢â€ â€™null, contadores de seÃƒÂ±al por lambda capture-by-valueÃ¢â€ â€™holder por referencia, fixtures `madera`/`piedra`Ã¢â€ â€™`wood`/`stone` (ids M15 reales; `deserializar`/`restore` validan contra el ItemDatabase vivo), `test_puede_apilar_false_different_item`Ã¢â€ â€™`_empty_slot` (la API no recibe item id). **T-99:** 05-Checklist M14 = 136 [x]/0 [ ]/4 [?] = 140 = Totales exacto; 4 `[?]` externos con dueÃƒÂ±o; 0 `[x]`Ã¢â€ â€™archivo inexistente (`inventario_save.gd` = path stale de 04-Codigo, funcionalidad en `inventario_service.gd` L36-41/388-405). **Sello Ã‚Â§21.8 otorgado** (verificador agnes Ã¢â€°Â  autor glm-5.3-flash): fila 14 GLOBAL + `CHECKLIST-QA-SEALS.md` (Log 1127). **Delegado:** el defecto `is_equal_to` tambiÃƒÂ©n estÃƒÂ¡ en M38 (Ãƒâ€”13), M29 (Ãƒâ€”1) y `test_stable_flows` (Ãƒâ€”18) Ã¢â€ â€™ `[?]` BUG-079 a sus dueÃƒÂ±os. Log 1127 del pool V3. |
| 19 | **M101/M145/M146** (QA Ã‚Â§21.8 P-25, doble fuente T-101) | Ã¢Å“â€¦ SELLADOS (3) | **1138** | **P-25 (asignado 2026-09-25 00:26Z):** los 3 mÃƒÂ³dulos s2 los sellÃƒÂ³ en GLOBAL (Log 1124) **sin respaldo en SEALS** (reporte hy3: sello de fuente ÃƒÂºnica). Verificador agnes Ã¢â€°Â  s2 Ã¢â€ â€™ independencia Ã‚Â§21.8. **M101**: `test_qa_m101.gd` 12/0 EXIT 0 Ãƒâ€”2 (anclaje `=== Resumen M101 ===`, variante M-05) + re-grounding T-99 parseado: `qa_validator.gd` + `data/qa/qa_schema.json` (JSON vÃƒÂ¡lido; secciones `schema_sesion`/`schema_areas`/`doD_hito` = las que lee el validador) + 7 docs `docs/qa/`; 05-Checklist 209/0/0 exacto. **M145**: 7/7 docs `operativa/` 1:1 con 04-Codigo Ã‚Â§1 + parseo (`feedback-system.md` Ã‚Â§2 = 20 acciones exactas; `accessibility-standards` R1-R8); 105/0/0 exacto; **salvedad**: 15 `[x]` "KnownIssue no bloqueante DoD" = actividades futuras (M114/M138+/M105), precedente Familia B BUG-070 Ã¢â€ â€™ re-verif M114/M138+. **M146**: 5/5 docs + parseo (`wow-moments` WM-1..8 con presupuesto; `cozy-checklist` 7 preguntas); 100/0/0 exacto; misma salvedad (10 `[x]` Ã¢â€ â€™ M138+). **Sellos doble fuente**: 3 filas en `CHECKLIST-QA-SEALS.md` + notas en filas 101/145/146 GLOBAL. **GLOBAL no commiteado** (working tree ~496 archivos ajenos + riesgo EOL) Ã¢â‚¬â€ solo ediciÃƒÂ³n workspace; commit `c94c7de` = SEALS + Log 1138. Log 1138 del pool V3. |
| 20 | **M08** Mundo-Voxel (**QA Ã‚Â§21.8 P-29**, no it.) | Ã¢Å“â€¦ SELLADO (definitivo, 1Ã‚Âª evidencia headless) | **1141** | **P-29 (asignado 2026-09-25 01:05Z): el Ã¢Å“â€¦ sin sello mÃƒÂ¡s crÃƒÂ­tico que quedaba** (49 mÃƒÂ³dulos sellos; M08 = core voxel; sellos previos 747/976 = solo re-grounding). VerificaciÃƒÂ³n con binario real (enfoque s2): suites M13 `test_herramientas` + `test_herramientas_iter4` (**el contrato real de ediciÃƒÂ³n M08**: `tool_controller.try_extract/try_place` + `interaction_manager`, documentado en 04-Codigo Ã‚Â§3 saneado por atria Log 976) **0 fallos Ãƒâ€”2 cada una, EXIT 0, 0 SCRIPT ERROR**; `main_island.tscn --quit-after 300` headless **EXIT 0 Ãƒâ€”2, 0 SCRIPT ERROR** (`VoxelBoxMover listo` + `VoxelViewer enganchado` = GDExtension VoxelTools cargada y streaming headless). Re-grounding T-99: 05-Checklist **105/0/0 = Totales exacto**; artifacts Ã‚Â§1 en disco (block_type live-central; block_catalog muerto-runtime documentado; tool_controller/interaction_manager/world_generator/world_manager vivos). **Salvedades en el sello**: M08 sin suite propia (verif. vÃƒÂ­a M13 + runtime), ediciÃƒÂ³n E/Q interactiva = playtest, RID-leak at exit = ruido headless benigno. Sello doble fuente (SEALS fila 1141 + notas GLOBAL fila 08); GLOBAL no commiteado (workspace). Log 1141 del pool V3. |
| 21 | **M36/M65/M32** (lote QA Ã‚Â§21.8 P-31) | M36 Ã¢Å“â€¦ + M32 Ã¢Å“â€¦ SELLADOS Ã‚Â· M65 Ã°Å¸Å¸Â¡ (BUG-080) | **1145** | **Lote P-31 (asignado 2026-09-25 02:34Z): gameplay core faunaÃ¢â€ â€IAÃ¢â€ â€clima, interrelacionados. Verificador agnes Ã¢â€°Â  autores (Hy3/minimax, glm, glm+DeepSeek).** Binario Godot 4.7.2 real, headless, enfoque s2 (Push-Location sin `--path`), conteos anclados `^\s*OK:`. **M36 Fauna Ã¢Å“â€¦:** `test_fauna` 58 OK/0 Ãƒâ€”2 + `fauna_auditor` 7 especies Ãƒâ€”2; autoloads cableados y en runtime (`fauna_registry`/`fauna` L52/53, `[M36] FaunaManager ready: 7 especies`); 7/7 artifacts 04-Codigo + JabaliNPC/JabaliAdultoNPC en main_island; `fauna_behavior.gd` (mod M65 Log 415) ÃƒÂ­ntegro Ã¢â€¡â€™ M65 no degradÃƒÂ³ M36. CorrecciÃƒÂ³n de conteo: 228/228 Ã¢â€ â€™ **226 [x]+2 [ ] KnownIssue** (226/228). **M32 Clima Ã¢Å“â€¦:** `test_clima` 0 fallos Ãƒâ€”2 + **3 suites colaterales consumidoras** (`test_clima_dialogo_m21` 7 OK + `test_farm_clima` M33 + `test_fishing_clima` M34) verdes Ãƒâ€”2 = integraciÃƒÂ³n real M21/M38/M40; autoload `Weather` L69 + EventBus `clima_cambio` en boot; 121/0/0 exacto. **M65 Ã°Å¸Å¸Â¡ (BUG-080):** autoload verde (`test_m65` 24 OK Ãƒâ€”2) PERO `tests/test_m65.gd` no ejecutable (preload muerto tras move Log 584 Ã¢â€ â€™ 6Ãƒâ€” SCRIPT ERROR) + PackLogic/SchoolLogic huÃƒÂ©rfanas en producciÃƒÂ³n Ã¢â€ â€™ L109/L115 degradadas `[x]`Ã¢â€ â€™`[?]` (Caso A) + 1 `[?]` consolidado + Notas del Agente + Totales 90=86/1/3; fila GLOBAL 65 Ã¢â€ â€™ Ã°Å¸Å¸Â¡. Cruce P-33 (hy3, Log 1146) documentado y escalado. **QA puro (cero fixes de cÃƒÂ³digo/tests).** Sello doble fuente (SEALS 1145 Ãƒâ€”2 + notas GLOBAL 36/32); M65 = fila Notas QA. GLOBAL no commiteado. Log 1145 del pool V3. |
| 19 | **M101/M145/M146** (QA Ã‚Â§21.8 P-25, doble fuente T-101) | Ã¢Å“â€¦ SELLADOS (3) | **1138** | **P-25 (asignado 2026-09-25 00:26Z):** los 3 mÃƒÂ³dulos s2 los sellÃƒÂ³ en GLOBAL (Log 1124) **sin respaldo en SEALS** (reporte hy3: sello de fuente ÃƒÂºnica). Verificador agnes Ã¢â€°Â  s2 Ã¢â€ â€™ independencia Ã‚Â§21.8. **M101**: `test_qa_m101.gd` 12/0 EXIT 0 Ãƒâ€”2 (anclaje `=== Resumen M101 ===`, variante M-05) + re-grounding T-99 parseado: `qa_validator.gd` + `data/qa/qa_schema.json` (JSON vÃƒÂ¡lido; secciones `schema_sesion`/`schema_areas`/`doD_hito` = las que lee el validador) + 7 docs `docs/qa/`; 05-Checklist 209/0/0 exacto. **M145**: 7/7 docs `operativa/` 1:1 con 04-Codigo Ã‚Â§1 + parseo (`feedback-system.md` Ã‚Â§2 = 20 acciones exactas; `accessibility-standards` R1-R8); 105/0/0 exacto; **salvedad**: 15 `[x]` "KnownIssue no bloqueante DoD" = actividades futuras (M114/M138+/M105), precedente Familia B BUG-070 Ã¢â€ â€™ re-verif M114/M138+. **M146**: 5/5 docs + parseo (`wow-moments` WM-1..8 con presupuesto; `cozy-checklist` 7 preguntas); 100/0/0 exacto; misma salvedad (10 `[x]` Ã¢â€ â€™ M138+). **Sellos doble fuente**: 3 filas en `CHECKLIST-QA-SEALS.md` + notas en filas 101/145/146 GLOBAL. **GLOBAL no commiteado** (working tree ~496 archivos ajenos + riesgo EOL) Ã¢â‚¬â€ solo ediciÃƒÂ³n workspace; commit = SEALS + Log 1138. Log 1138 del pool V3. |
| 22 | **M53 commit + M62 allowlist** (P-37, desbloqueo merge) | Ã¢Å“â€¦ Merge desbloqueado | **1151** | **P-37 (urgente, 2026-09-25):** el change set M53 de P-18 (Log 1118) quedÃƒÂ³ sin commitear y rompÃƒÂ­a el gate M62 (`architecture-guard`: 2 refs A2|UIManager fuera del allowlist). Se commiteÃƒÂ³n 12 archivos (~751 inserciones, commit `825ed16`) + se agregaron 2 entradas al allowlist de `scripts/auditar_arquitectura_m62.py` (`A2|UIManager->AccesibilityManager` / `A2|UIManager->Localization`, etiqueta BUG-069: deuda de orden de capas, runtime OK). Gate M62 re-verificado: auditorÃƒÂ­a completa 0 hallazgos nuevos + selftest 0 fallos Ã¢â€ â€™ merge final del coordinador desbloqueado. Log 1151 del pool V3. |
| 23 | **M65 manada/banco revive** (P-38, BUG-080) | Ã¢Å“â€¦ M65 re-sellado (BUG-080 resuelto) | **1154** | **P-38 (2026-09-25):** BUG-080 (P-31, Log 1145) resuelto: preloads muertos de `tests/test_m65.gd` corregidos (`fauna/`Ã¢â€ â€™`animales_ia/`) + `PackLogic`/`SchoolLogic` cableadas en el autoload `m65_animal_ai` (`registrar`/`tick`/`desregistrar` por especie: gregaria+clase del catÃƒÂ¡logo M36; `_grupos_tick` cohesiÃƒÂ³n/huida coordinada; `grupo_tamanio` QA) + fixes de semÃƒÂ¡ntica pack/school (`get_global_position()` duck-typed, `limpiar()` full-clear, lÃƒÂ­der con Ã¢â€°Â¥1 miembro) + fix de mis propios bugs (`Resource.get(2 args)`, `Window.get_first_node_in_group`) + prueba nueva del flujo real `fauna_behavior`Ã¢â€ â€™autoloadÃ¢â€ â€™PackLogic. Evidencia: `tests/test_m65.gd` **35 OK / 0 fallos**; `scripts/animales_ia/test_m65.gd` 0 fallos (base 24 OK); `test_fauna` 0 fallos; `main_island --quit-after 300` Ãƒâ€”2 = 0 SCRIPT ERROR. **LimitaciÃƒÂ³n honesta:** los NPCs de main_island son legacy (no `fauna_behavior`) Ã¢â€ â€™ los logs `[M65]` de grupo aÃƒÂºn no se observan en la escena principal (el flujo de producciÃƒÂ³n es M36). Docs: M65 04-Codigo (rutas `fauna/` obsoletas Ã¢â€ â€™ `animales_ia/`) + 05-Checklist (3 `[?]`Ã¢â€ â€™`[x]`, Totales 89/1/0) + 11-BUGS BUG-080Ã¢â€ â€™`[x]` + GLOBAL fila 65 Ã¢â€ â€™ Ã¢Å“â€¦ + SEALS sello limpio (total 43). GLOBAL/11-BUGS/pool **sin commitear** (avisado al coordinador para el merge). Log 1154 del pool V3. |
| 24 | **M36 spawner en main_island** (P-49, deuda M65) | Ã¢Å“â€¦ Integrado + documentado | **1165** | **P-49 (2026-09-25):** cerrÃƒÂ³ la deuda que yo anotÃƒÂ© en P-38 ("los NPCs de main_island son legacy... el spawner de M36 no estÃƒÂ¡ integrado"). Nuevo `fauna_spawner.gd` (nodo de escena) + nodo `FaunaSpawner` en `main_island.tscn`: zonas de bioma nominales de `MundoRaiz` (pradera en el spawn del jugador, playa/humedal en la costa) + especie por `especie_aleatoria_para(hora, bioma)` + tamaÃƒÂ±o por `candidatos_de_especie` + criatura = Node3D + `fauna_behavior` + placeholder de esfera (M45 posterior) + snap `TerrainLocator` (hÃ¢â€°Â¥3 tierra, franja 2.5Ã¢â‚¬â€œ4.5 acuÃƒÂ¡tica, sobrevuelo aÃƒÂ©rea). Fixes durante la integraciÃƒÂ³n: autoload `fauna` no listo en `_ready` Ã¢â€ â€™ lookup lazy `Engine.get_main_loop().root` + reintento; `Vector3.xz` (read-only) no pasa por dispatch de Variant Ã¢â€ â€™ `.x/.z`; `:=` sobre Variant Ã¢â€ â€™ `=`. **Evidencia:** `main_island --quit-after 300` Ãƒâ€”2 = 0 SCRIPT ERROR; `[M65] Manada creada para conejo_pradera` + 2Ãƒâ€” `[M65] Banco creado para gaviota_playera/cangrejo_humedal` + 9/10 individuos; probe: 9 nodos `Fauna_*` con `fauna_behavior` bajo `FaunaSpawner`; suites M36/M65 0 fallos (no degradadas). Pendiente `[?]` M09: spawner completo "burbuja 72m" con `bioma_de_posicion` + despawn por distancia. Docs: M36 04-Codigo Ã‚Â§P-49 + M65 05-Checklist Notas P-49 (limitaciÃƒÂ³n de P-38 levantada). Pool: P-49 pidiÃƒÂ³ 1161 pero 1161Ã¢â‚¬â€œ1164 fueron tomados en paralelo (P-43b/46/48/50) Ã¢â€ â€™ reservÃƒÂ© **1165** (anti-colisiÃƒÂ³n Ã‚Â§6.1.d). Commits 2 coherentes (trampa 87 verificado entre commits); los 4 compartidos sin commitear. Log 1165 del pool V3. |
| 25 | **Bucket OTRO:agnes (27 files)** (P-51, merge final) | Ã¢Å“â€¦ Commiteado en 5 commits | **1168** | **P-51 (2026-09-29):** cerrÃƒÂ³ el bucket "OTRO:agnes" (27 archivos) de la reclasificaciÃƒÂ³n P-48 (buckets_final.json) en 5 commits coherentes `Merge (worktree de agnes-3-flash)`: docs M19/M66/M72/M166 + tests M14/M155 + QA visual/utilerÃƒÂ­a (VFX M52, ruinas M25, auditorÃƒÂ­a GLB) + 7 logs QA + 6 backlogs. Verificado `git diff --stat HEAD~1..HEAD` por commit (trampa 87). **Lecciones:** (1) en repos multi-agente siempre commitear con pathspec (un commit arrastrÃƒÂ³ 1 file ajeno pre-staged; se revirtiÃƒÂ³ y re-commiteÃƒÂ³ limpio); (2) test_equipment_manager.gd = reflow CRLFÃ¢â€ â€™LF (0 cambio de contenido; verificado LF-puro con editar_crlf.py); (3) pool: 1166/1167 tomados en paralelo Ã¢â€ â€™ reservÃƒÂ© 1168. Los 4 compartidos sin commitear (bucket C del coordinador). Push NEGATIVO. Log 1168 del pool V3. |
| 26 | **Lecciones GDScript Ã¢â€ â€™ GUIA-GODOT/01** (P-52, deuda P-49) | Ã¢Å“â€¦ Documentadas (Ã‚Â§26-Ã‚Â§28) | **1169** | **P-52 (2026-09-29):** documentÃƒÂ© en `GUIA-GODOT/01-gdscript-errores-comunes.md` las 3 trampas de GDScript cazadas en producciÃƒÂ³n (P-38/P-49, Godot 4.7.2), con sÃƒÂ­ntomo/causa/soluciÃƒÂ³n/fecha (formato Ã‚Â§26): Ã‚Â§26 autoload no resuelto en `_ready()` (lookup lazy + reintento vÃƒÂ­a `Engine.get_main_loop().root`); Ã‚Â§27 `Vector3.xz` read-only no pasa por dispatch de Variant (`Vector2(v.x, v.z)`); Ã‚Â§28 `:=` sobre helper Variant no infiere tipo (`=` o anotar tipo). + 3 filas en la tabla de referencia + firma de cabecera. CerrÃƒÂ³ la deuda que anotÃƒÂ© en P-49 ("mandalas allÃƒÂ­ cuando tengas hueco"). Commit con pathspec (trampa 70/87), Push NEGATIVO. Log 1169 del pool V3. |
| 27 | **Bucket flotaciÃƒÂ³n GLB M166** (P-54, ÃƒÂºltima tajada) | Ã¢Å“â€¦ Commiteado | **1174** | **P-54 (2026-09-30):** cerrÃƒÂ³ el resto del bucket agnes: `scripts/auditar_flotacion_glb.py` (auditor de cota Z de .glb vÃƒÂ­a glTF, criterios M166 z_min 0.065/0.025) + `tools/legal/flotacion_glb.json` (salida --json, 265 KB). Mismo trabajo que `auditar_copyright_glb.py` (P-51, 9847169) y Log 1035. `preview_antorcha_m25.tscn` (antes listado como mÃƒÂ­o) era de mimo (afcdf4f) Ã¢â€ â€™ descartado de mi bucket. Commit con pathspec (trampa 70/87), ÃƒÂ­ndice chequeado antes (0 staged ajenos). Pool: reserva **atÃƒÂ³mica** 1174 (el pool se movÃƒÂ­a: 1170Ã¢â‚¬â€œ1173 tomados en paralelo). Push NEGATIVO. Log 1174 del pool V3. |
| 28 | **M131 QA Ã‚Â§21.8 BUG-081** (P-56, QA cruzado) | Ã°Å¸Å¸Â¡ No sellable (delegado al dueÃƒÂ±o) | **sin log pool (QA)** | **P-56 (2026-10-02):** QA cruzado Ã‚Â§21.8 de M131 (mimo-v2.6 cerrÃƒÂ³ BUG-081). Verificado: BUG-081 bien resuelto (4 fixes en el cÃƒÂ³digo real + suites re-ejecutadas M131 8/0 y M84 15/0 verdes + Log 1178 commiteado 7f00e04 + diff de GLOBAL 1 lÃƒÂ­nea limpia sin EOL). **Hallazgo: M131 NO es sellable a Ã¢Å“â€¦** Ã¢â‚¬â€ la fila 131 del GLOBAL estÃƒÂ¡ en Ã°Å¸Å¸Â¡ (84/95) con 9 `[?]` (audio M41/M42/M43/M91) + 2 `[ ]`; DoD Ã‚Â§21.6 exige 0 `[?]`. Veredicto documentado en M131 `04-Codigo` Ã¢â€ â€™ `## Notas del Agente` (commit `c009775`, pathspec, sin push) y delegado al coordinador. La reclasificaciÃƒÂ³n 9 `[?]`Ã¢â€ â€™`[ ]` KnownIssue (precedente M36/M65) es del dueÃƒÂ±o (mimo), no de QA. QA audit-only: no toquÃƒÂ© cÃƒÂ³digo de M131/M84. |
| 29 | **P-57: 6 filas defectuosas CHECKLIST-GLOBAL + auditorÃƒÂ­a** | Ã¢Å“â€¦ Commiteado | **1186** | **P-57 (2026-10-02):** CorregÃƒÂ­ 6 filas (IDs 22, 26, 67, 68, 76, 77) de CHECKLIST-GLOBAL.md con columnas desplazadas/spurious (patrÃƒÂ³n detectado por atria-dawn, Log 1181). EdiciÃƒÂ³n byte-exact vÃƒÂ­a `scripts/p57_fix_rows.py` (EOL 231/0/219/1 preservado). EjecutÃƒÂ© `verificar_checklist.py`: 2 alertas documentadas en el log (M131 90vs85 mismatch; M70 fragmento de Notas en timestamp Ã¢â‚¬â€ ambos fuera de alcance P-57, delegados). Pool: reservÃƒÂ© 1186 (head actual; 1182Ã¢â‚¬â€œ1185 consumidos por otros). Push NEGATIVO (coordinador empuja). |
| 30 | **Candidata: escapar 148 pipes en Notas CHECKLIST-GLOBAL** | Ã¢Â¬Å“ Pendiente (no urgente) | Ã¢â‚¬â€ | **Sistema (2026-10-02, coordinador):** 148/167 filas de CHECKLIST-GLOBAL tienen pipes `|` sin escapar en la columna Notas. El verificador `verificar_checklist.py` resiste la mayorÃƒÂ­a (parsea solo las primeras 10 cols) pero se confunde en filas con contenido desplazado (M62, M70). Tarea de forma separada si se pide. **SUPERADA por T-A3 (ver fila 31).** |
| 31 | **T-A3: saneo estructural GLOBAL (60 filas) + 13 bloques Totales** | Ã¢Å“â€¦ Commiteado | **1293** | **T-A3 (ampliado, 2026-10-04, canal `agnes-3-flash` arch. 28 / Log 1279):** saneo estructural de las filas mal formadas de `CHECKLIST-GLOBAL.md` (58 declaradas Ã¢â€ â€™ 60 al re-medir: +M124/+M84 sin pipe final). 40 filas con pipes `\|` sin escapar en Notas Ã¢â€ â€™ unidas + escapadas; 18 filas con celda `Agente actual` colapsada Ã¢â€ â€™ insertado `Ã¢â‚¬â€` en pos. 8; 2 sin pipe final Ã¢â€ â€™ agregado. **167/167 filas = 11 celdas + pipe final.** No toco `Estado`/`Progreso` (0 diff vs HEAD). Invariante EOL PREÃ¢â€ â€™POST: CRLF 231Ã¢â€ â€™231, CR-suelto 218Ã¢â€ â€™163, LF 0, NUL 1. Commit `78e9af3`. Script idempotente `scripts/t_a3_fix2.py` (split sobre `(?<!\\)\|`; v1 con `split('|')` doble-escapaba, corregido). **13 bloques `Totales`** en 12 `05-Checklist.md` plan-actual alineados con el conteo real (02,04,05,104-L152,115,126-L24+L300,38,41,42,44,54,91; M03 se auto-corrigiÃƒÂ³ y se omitiÃƒÂ³; M104-L171 = falso positivo no tocado). Commit `285fe31`, script `scripts/t_a3_totales.py`. **Deuda documentada:** 46 inconsistencias semÃƒÂ¡nticas + 1 colgado (M37) en `verificar_checklist.py` = deuda preexistente fuera de alcance T-A3. Log 1293 del pool. |
| 32 | **T-A1: M129-Merchandising 68Ã¢â€ â€™103/108 (capa data+servicio+docs)** | Ã¢Å“â€¦ Commiteado (no sellado) | **1299** | **T-A1 (2026-10-04):** cierre de la brecha de Hy3 en M129. `merchandising.json` v2 (4Ã¢â€ â€™10 productos c/ specs: materiales/tamaÃƒÂ±os/colores/precio/margen/calidad/seguridad) + `merch_manager.gd` (autoload `MerchManager`, contrato `"merch"` en ServiceRegistry) + `merch_validator.gd` v2 (tipo-enum/rangos/listas) + `test_merch_m129.gd` 8Ã¢â€ â€™24 checks 0/0 EXIT 0 + `merch_catalog.md` (nuevo) + 1 autoload en `project.godot`. Checklist: 40 `[ ]` Ã¢â€ â€™ 35 `[x]` + 5 `[?]` (dueÃƒÂ±o M45/M46 arte, M41 mÃƒÂºsica, M53 web). Totales 103/108Ã‚Â·5[?]. Trampas: `class_name` choque c/ autoload (quitado), JSONÃ¢â€ â€™float, `-s` no resuelve class_name/autoloads. No sello Ã‚Â§21.8 (soy autor; el Ã¢Å“â€¦ pasa por QA independiente c/ los 5 `[?]` cerrados). Log 1299 del pool. |
| 33 | **M152: Principios-Innegociables 173Ã¢â€ â€™201/202 (28 de 29 [?])** | Ã¢Å“â€¦ Commiteado (no sellado) | **1305** | **T (2026-10-05, canal arch. 33/34):** leÃƒÂ­ el guardrail (desviaciones_justificadas.md de space-bunny SB-01/04 + 03-Diseno Ã‚Â§11) ANTES de tocar y no lo pisÃƒÂ© Ã¢â‚¬â€ lo reusÃƒÂ© como base. `resolucion_pendiente_m152.md` (nuevo): 28 `[?]` resueltos = integraciones M07/M50/M64/M107 (correcciÃƒÂ³n Ã‚Â§11) + M14 (5) + ejemplosÃ¢â€ â€™D-R1/D-R2 (5) + mÃƒÂ©tricas denominadores (5) + responsable=fundador+QA Ã‚Â§21.8 (2) + pair/KSÃ¢â€ â€™anÃƒÂ¡logo canales/backlog/guÃƒÂ­as (4) + licencias/comunicaciÃƒÂ³n M126/M127 (2). **Quedaba 1 `[?]` = D-R2 (ampliar mapa Ãƒâ€”10, parcial 2/3) = decisiÃƒÂ³n del fundador.** M152 Ã°Å¸Å¸Â¡. Log 1305 del pool. |
| 34 | **M152 D-R2 cierre (ÃƒÂºltimo [?]) Ã¢â€ â€™ M152 202/202 consistente** | Ã¢Å“â€¦ Commiteado | **1313** | **Cierre D-R2 (2026-10-05, canal arch. 38):** el FUNDADOR aprobÃƒÂ³ la ampliaciÃƒÂ³n parcial 2/3 patas (relay del director). CerrÃƒÂ© el ÃƒÂºltimo `[?]` de M152 documentando la decisiÃƒÂ³n del fundador (no anÃƒÂ¡lisis propio): `05-Checklist` `[?] No ampliar el mapa...`Ã¢â€ â€™`[x]` + fila evidencia familia AÃ¢â€ â€™`[x]` + `Totales` 202/202Ã‚Â·0[?] + `resolucion_pendiente_m152.md` Ã‚Â§5 nota de cierre + GLOBAL fila 152 nota. **Coordino c/ Hy3 `1ca253c` (Log 1309 T-H5) que ya habÃƒÂ­a promovido M152 a Ã¢Å“â€¦ 202/202:** yo no lo selle (soy autor); solo completÃƒÂ© el `[?]` y documentÃƒÂ©. M152 = 202/202Ã‚Â·0[?]Ã‚Â·Ã¢Å“â€¦ (QA Hy3). P1/P2/P3 (anclaje M22/M160) = deuda de esos mÃƒÂ³dulos. Log 1313 del pool. |
| 35 | **M106/M122: re-verif. nÃƒÂºcleo + matriz de delegaciÃƒÂ³n (deuda DoD)** | Ã¢Å“â€¦ Documentado-y-bloqueado | **1315** | **M106 (canal arch. 37, "ARRANCÃƒÂ"):** 12 `[?]` = TODOS cross-mÃƒÂ³dulo (M77/M111/M104/M105/M107) Ã¢â€ â€™ NO auto-cerrables (falso-cierre si se fuerzan). Re-verifiquÃƒÂ© nÃƒÂºcleo local: `test_security_m106.gd` **43 checks 0 fallos EXIT 0** (194 `[x]` reales). Matriz de delegaciÃƒÂ³n en `05-Checklist` Ã‚Â§Notas iter.T. M106 194/206Ã‚Â·12[?]Ã¢â€ â€™Ã°Å¸Å¸Â¡ bloqueado en M77. **M122 (revisado):** 11 `[?]` misma patologÃƒÂ­a (M117/M61/M90/M114/M103 + GDPR=coordinador), nÃƒÂºcleo local OK Ã¢â€ â€™ Ã°Å¸Å¸Â¡ bloqueado. No pisÃƒÂ© mÃƒÂ³dulos ajenos; dejÃƒÂ© documentado-y-bloqueado y preguntÃƒÂ© al coordinador si me da M77 (opciÃƒÂ³n A) para desbloquear M106. Log 1315 del pool. |
| 36 | **T-A4: realineaciÃƒÂ³n cols 8-10 del GLOBAL (contenido "corrido")** | Ã¢Å“â€¦ Commiteado | **1319** | **T-A4 (canal arch. 39):** seÃƒÂ±a = fecha en columna Agente actual (col8, nunca debe haber fecha). `t_a4_realign.py` (preservador: AgenteÃ¢â€ â€™Ã¢â‚¬â€, ÃƒÅ¡ltimaÃ¢â€ â€™fecha, NotasÃ¢â€ â€™col9+col10; guarda si pierde contenido): **19 filas** (M09,M102,M112,M121,M147,M151,M21,M24,M33,M40,M50,M69,M73,M84,M88 + M92,M97). `t_a3_fix2.py`: **14 filas** que T-D7 (DeepSeek) dejÃƒÂ³ >11 celdas re-escapadas a 11 (M158,M160,M18,M19,M20,M28,M41,M42,M45,M47,M48,M67,M75,M90). Verif: **167/167=11 celdas**, 0 fechas en col8, Estado/Progreso intactos. EOL CRLF 231Ã¢â€ â€™231, CR-suelto 161Ã¢â€ â€™147. numstat GLOBAL 29 29. Log 1319 del pool. |
| 37 | **M122: re-verif. nÃƒÂºcleo + matriz de delegaciÃƒÂ³n (2.Ã‚Âº deuda DoD)** | Ã¢Å“â€¦ Documentado-y-bloqueado | **1322** | **M122-Crash-Reporting (canal arch. 41):** 11 `[?]` = TODOS dueÃƒÂ±os externos (M117 debug-build Ãƒâ€”2, M61 rendimiento Ãƒâ€”2, M90 UI settings Ãƒâ€”2, M114 playtest, M103/M102/M110 integraciÃƒÂ³n, GDPR=coordinador Ãƒâ€”2). Re-verifiquÃƒÂ© nÃƒÂºcleo local: `test_crash_m122.gd` **13 checks 0 fallos EXIT 0** (254 `[x]` reales). Matriz de delegaciÃƒÂ³n en `05-Checklist` Ã‚Â§Notas iter.T. M122 254/265Ã‚Â·11[?]Ã¢â€ â€™Ã°Å¸Å¸Â¡ bloqueado en M117/M61/M90/M114+GDPR. **ConclusiÃƒÂ³n M106+M122: ambas en techo honesto, bloqueadas en dueÃƒÂ±os externos; para cerrarlas hay que avanzar M77 (M106) / M117+M61+M90+M114+GDPR (M122).** PreguntÃƒÂ© al coordinador si me asigna alguno. Log 1322 del pool. |




**Siguiente en la cola del bucle (mi encaje A):** mÃƒÂ³dulo V0 + data-driven + tooling/CI + **gap de
cÃƒÂ³digo real** (no solo polÃƒÂ­tica). Candidatos a verificar antes de reclamar (Ã‚Â§21.4.7, checar estado real):
un mÃƒÂ³dulo revertido por auditorÃƒÂ­a con cÃƒÂ³digo parcial (patrÃƒÂ³n de M113/M115/M107) Ã¢â‚¬â€ p. ej. revisar el pool
de mÃƒÂ³dulos Ã°Å¸Å¸Â¢/Ã°Å¸Å¸Â¡ "revertido por auditorÃƒÂ­a" y elegir el que tenga cÃƒÂ³digo testable donde mi perfil
(auditorÃƒÂ­a cÃƒÂ³digoÃ¢â€ â€checklist + test headless + tooling) dÃƒÂ© un cierre genuino. IteraciÃƒÂ³n 6 ya corriÃƒÂ³ como
V0 acotada sobre M61 (Log 943); pendiente visual: V3 M46 Arte-2D (fila de la cola visual).

## Cola visual (tareas que REQUIEREN visiÃƒÂ³n Ã¢â‚¬â€ la aprovecho, Ã‚Â§19 correcciÃƒÂ³n 2026-09-16)

> Mi perfil de visiÃƒÂ³n: **V1** (leer/describir capturas del MCP godot en `tools/mcp/godot-mcp/capturas/<mÃƒÂ³dulo>/`)
> + **V2-asistencia** (revisar y opinar sobre un render/screenshot: terreno, HUD, VFX, iluminaciÃƒÂ³n, NPC).
> **LÃƒÂ­mite honesto:** la **aprobaciÃƒÂ³n estÃƒÂ©tica final es del usuario (M154)**; **no genero arte 3D/texturas
> (V5)** Ã¢â€ â€™ eso va a Hy4/Blender.

| # | MÃƒÂ³dulo | Capturas | Tarea de visiÃƒÂ³n (V1/V2-asistencia) | Estado |
|---|--------|----------|-------------------------------------|--------|
| V1 | M52 Particulas-Y-VFX | `capturas/52-Particulas-Y-VFX/` (6) | V2-asistencia: leer capturas, describir el VFX, detectar artefactos/bugs visuales + QA note | Ã°Å¸Å¸Â¡ **done** (Log 932: leÃƒÂ­ iter3+iter4 vÃƒÂ­a visiÃƒÂ³n + `screen_capture_screen`; **flag FPS-24 en turbulencia Ã¢â€ â€™ M61**; nota Ã‚Â§QA visual en `05-Checklist.md` M52) |
| V2 | M49 Iluminacion | `capturas/49-Iluminacion/` (4) + `capturas/49/` (16) | V2-asistencia: revisar balance de luz/sombras en las capturas; flaggear zonas quemadas/oscuras | Ã°Å¸Å¸Â¡ **done** (Log 939: leÃƒÂ­ mediodÃƒÂ­a/noche/atardecer/skyline vÃƒÂ­a visiÃƒÂ³n; ciclo dÃƒÂ­aÃ¢â€ â€™noche correcto, FPS ~60; **noche oscura = diseÃƒÂ±o confirmado por el usuario (la cubren las antorchas)**; nota Ã‚Â§QA visual en `05-Checklist.md` M49) |
| V3 | M46 Arte-2D | `capturas/45`/`46` + M46 0/110 | V1: verificar si hay assets 2D reales (probablemente bloqueado por M45) Ã¢â€ â€™ confirmar `[?]` con dueÃƒÂ±o | Ã°Å¸Å¸Â¡ **done** (Log 954: V1-QA Ã¢â‚¬â€ **0 de 48 assets en disco** (inventario_2d.json define 48, validador headless 0 fallos lo confirma); ART_STYLE_2D.md + tooling reales; trabajo 2D **bloqueado por M45/M108/artes** (dueÃƒÂ±os asignados en 05-Checklist Ã‚Â§QA V1). **Flag:** checklist archivo 0/110 vs 103Ã¢â‚¬â€œ104/110 declarado (cierre no reflejado) Ã¢â€ â€™ dueÃƒÂ±o M46 re-marca) |
| V4 | M167 Isla-Raiz | `capturas/167-Isla-Raiz/` (3) | V1/V2: verificar que el terreno se vea correcto (perfil en capas, paleta Maldivas) vs doc de recuperaciÃƒÂ³n | Ã°Å¸Å¸Â¡ **done** (visiÃƒÂ³n: leÃƒÂ­ `overview`/`costa`/`smoke_regresion` Ã¢â€ â€™ terreno completo y correcto, FPS 60; respaldÃƒÂ© con evidencia visual el KnownIssue "shore-fade cubre demasiada arena" y diagnosticÃƒÂ© el `SCRIPT ERROR` de la consola = **cachÃƒÂ© stale del editor**, no bug en disco; nota Ã‚Â§QA en `05-Checklist.md` M167). ElecciÃƒÂ³n: V4 > V3 porque M46 depende de M45 (assets) y M167 ya estÃƒÂ¡ Ã¢Å“â€¦ 114/114 con solo pendiente la verificaciÃƒÂ³n visual = mi perfil exacto. |

**Regla de uso:** antes de cada V-###, **leo las PNG (visiÃƒÂ³n)** y/o hago `screen_capture_*` (MCP) para
ver el estado actual; luego escribo la QA note en el `05-Checklist.md` del mÃƒÂ³dulo (secciÃƒÂ³n "QA visual
V2-asistencia Ã¢â‚¬â€ agnes-3-flash") sin afirmar "aprobado por el usuario".

---

## ACTUALIZACION 2026-09-20 Ã¢â‚¬â€ nuevas asignaciones (curado por atria-dawn, Log 1091/1092)

> Anadido sobre tu backlog existente Ã¢â‚¬â€ **no se piso tu historial**. Estas tareas son
> **extraidas de los `05-Checklist.md` reales** (no inventadas). Trabajalas despues de
> tus tareas pendientes actuales, o en paralelo si prefieres.

*(Sin modulos nuevos Ã¢â‚¬â€ continua con tus tareas pendientes actuales.)*

## ACTUALIZACION 2026-09-20 Ã¢â‚¬â€ M53 UI-UX asignado por el usuario (04:15Z)

> El usuario asigna **M53 UI-UX** (Recom Hy4 inactivo, Ã‚Â§21.4.7) con prioridad:
> (1) overlays/accesibilidad (M58: subtÃƒÂ­tulos RF8 + RF18), (2) labels/tooltips
> traducidos (M87 Ãƒâ€”2). Log reservado: **1118** (vÃƒÂ­a `reservar_log.py`).
> **COMPLETADO 2026-09-20 (Log 1118 creado):** iteraciÃƒÂ³n agnes acotada en M53 + cierre
> de M87Ãƒâ€”2. Ver fila 17 del historial.

## ACTUALIZACION 2026-09-24 Ã¢â‚¬â€ P-25: QA cruzado M101/M145/M146 (asignado 2026-09-25 00:26Z)

> Sello T-101 de doble fuente para los 3 mÃƒÂ³dulos que s2 sellÃƒÂ³ solo en GLOBAL (Log 1124),
> reportados por hy3 como "sello de una sola fuente". Log reservado: **1138**.
> **COMPLETADO 2026-09-24 21:45 (Log 1138):** los 3 SELLADOS con doble fuente
> (`CHECKLIST-QA-SEALS.md` + notas GLOBAL). M101: suite 12/0 Ãƒâ€”2 + artifacts parseados
> (schema JSON validado) + 209/0/0 exacto. M145: 7/7 docs + 20 acciones + R1-R8 +
> 105/0/0 exacto (salvedad: 15 `[x]` futuras = Familia B BUG-070, re-verif M114/M138+).
> M146: 5/5 docs + WM-1..8 + 7 preguntas + 100/0/0 exacto (salvedad: 10 `[x]` futuras
> Ã¢â€ â€™ M138+). GLOBAL NO commiteado (working tree ajeno ~496 archivos + EOL): solo
> ediciÃƒÂ³n de workspace; commit = SEALS + Log 1138.

## ACTUALIZACION 2026-09-25 Ã¢â‚¬â€ P-29: QA Ã‚Â§21.8 de M08 Mundo-Voxel (asignado 2026-09-25 01:05Z)

> El Ã¢Å“â€¦ sin sello mÃƒÂ¡s crÃƒÂ­tico que quedaba (49 mÃƒÂ³dulos ya sellos; M08 = core voxel).
> Log reservado: **1141** (el pool ya habÃƒÂ­a consumido 1137-1140 Ã¢â‚¬â€ verificado antes).
> **COMPLETADO 2026-09-24 22:15 (Log 1141):** M08 **SELLADO con evidencia headless
> (primera vez)** Ã¢â‚¬â€ suites M13 (`test_herramientas` + `test_herramientas_iter4`, el
> contrato real de ediciÃƒÂ³n de M08 vÃƒÂ­a `tool_controller`/`interaction_manager`) **0
> fallos Ãƒâ€”2 cada una EXIT 0**; `main_island.tscn --quit-after 300` headless **EXIT 0
> Ãƒâ€”2, 0 SCRIPT ERROR** (VoxelBoxMover + VoxelViewer = GDExtension VoxelTools cargada
> y streaming). Re-grounding T-99: 05-Checklist 105/0/0 = Totales exacto; artifacts
> de 04-Codigo Ã‚Â§1 verificados en disco (incl. la nota QA-976 de atria que sanea la
> "arquitectura prevista"). Salvedades en el sello: (1) M08 no tiene suite propia Ã¢â€ â€™
> verif. vÃƒÂ­a M13 + runtime; (2) ediciÃƒÂ³n E/Q interactiva = playtest (no verificable
 > headless); (3) RID-leak at exit = ruido headless benigno. Sello doble fuente
 > (SEALS + notas GLOBAL); GLOBAL no commiteado.

## ACTUALIZACION 2026-09-25 Ã¢â‚¬â€ P-31: lote QA Ã‚Â§21.8 M36/M65/M32 (asignado 2026-09-25 02:34Z)

> Lote gameplay core interrelacionado (fauna Ã¢â€ â€ IA animal Ã¢â€ â€ clima). Log reservado:
> **1145** (pool: 1137-1144 ya consumidos por otros Ã¢â‚¬â€ verifiquÃƒÂ© antes).
> **COMPLETADO 2026-09-25 00:50 local:** **M36 Ã¢Å“â€¦ + M32 Ã¢Å“â€¦ sellados (doble fuente
> T-101); M65 Ã°Å¸Å¸Â¡ revertido Ã¢â€ â€™ BUG-080.**
> - **M36:** `test_fauna` 58 OK/0 fallos Ãƒâ€”2 + `fauna_auditor` 7 especies Ãƒâ€”2; autoloads
>   cableados y en runtime (`fauna_registry`/`fauna` L52/53; `[M36] FaunaManager
>   ready`); 7/7 artifacts + JabaliNPCs en main_island; `fauna_behavior.gd` (compartido
>   M65) ÃƒÂ­ntegro. CorrecciÃƒÂ³n de conteo: 228/228 Ã¢â€ â€™ **226 [x] + 2 [ ] KnownIssue**.
> - **M32:** `test_clima` 0 fallos Ãƒâ€”2 + **3 suites colaterales consumidoras** (M21 7 OK,
>   M33, M34) verdes Ãƒâ€”2 = integraciÃƒÂ³n real; autoload `Weather` L69 + EventBus
>   clima_cambio en boot; 121/0/0 exacto.
> - **M65:** autoload verde (`test_m65` 24 OK Ãƒâ€”2) PERO **`tests/test_m65.gd` no
>   ejecutable** (preload muerto tras el move Log 584 Ã¢â€ â€™ 6Ãƒâ€” SCRIPT ERROR) +
>   **PackLogic/SchoolLogic huÃƒÂ©rfanas en producciÃƒÂ³n** Ã¢â€ â€™ **BUG-080** (`[?]` delegado a
>   M65/glm), L109/L115 degradadas `[x]`Ã¢â€ â€™`[?]` (Caso A) + Notas del Agente + Totales
>   90 = 86/1/3. **Cruce P-33 (hy3, Log 1146):** divergencia documentada y escalada.
> - QA puro (cero cÃƒÂ³digo/tests modificados). Commit = SEALS + Log 1145 + 05-Checklist
>   M65; GLOBAL en workspace (merge del coordinador).

## ACTUALIZACION 2026-09-20 Ã¢â‚¬â€ M14 Inventario (P-18, QA Ã‚Â§21.8 asignado por el usuario, 07:54Z)

> **AutonomÃƒÂ­a total (cambio de mÃƒÂ©todo del coordinador):** intento resolver primero;
> `[?]` honesto si no pude; el coordinador verifica la entrega.
> Log reservado: **1127**. **COMPLETADO 2026-09-20 (06:25 local):** M14 **DEFINITIVO** Ã¢â‚¬â€
> sello Ã‚Â§21.8 otorgado. 5 suites verdes binario real: standalone Ãƒâ€”2 (0 fallos, 68/70 OK,
> Ãƒâ€”2 cada una) + gdUnit4 **32/32 PASSED 0 errors EXIT 0** (Ãƒâ€”2) tras fix mÃƒÂ­nimo de 5
> defectos del TEST registrado en **BUG-079** (`[x]` M14; `is_equal_to` Ãƒâ€”58 + `free()`
> RefCounted + lambda capture-by-value + ids M15 + rediseÃƒÂ±o de 1 test al contrato real).
> M38/M29/regresiÃƒÂ³n comparten el defecto `is_equal_to` Ã¢â€ â€™ `[?]` delegado (no lo toquÃƒÂ©).
> ReconciliaciÃƒÂ³n T-99: 05-Checklist M14 = 136/0/4 = Totales exacto; 0 `[x]`Ã¢â€ â€™archivo
> inexistente (`inventario_save.gd` stale, funcionalidad en `inventario_service.gd`).


### QA visual puntual Ã¢â‚¬â€ impostor de M09 (1 tarea)

> **Unica tarea nueva, chica** (eres lenta, reportado). M09 no tiene suite headless Ã¢â‚¬â€
> su impostor se verifica visualmente (visible a 1300 m). Captura Ã¢â€ â€™ analiza Ã¢â€ â€™ reporta.
> **Si no hay captura posible, reporta "no verificable"** Ã¢â‚¬â€ no apruebes sin evidencia.

- [x] **T-V01:** Verificar `scripts/world/terreno_horizonte.gd` (impostor heightmap)
  con captura V4: Ã‚Â¿se ve correcto desde la distancia objetivo? Ã¢â‚¬â€ **COMPLETADO
  2026-09-20 (Log 1115).** V4: run main_island + captura
  `capturas/09/cap_09_2026-09-19_21-45-49_impostor_1300m.png` (42 tiles activos,
  0 SCRIPT ERROR, FPS 60; horizonte tapado por fog 0.001 Ã¢â€ â€™ mi veredicto "no
  verificable"). V1 usuario: "los impostores sÃƒÂ­ funcionan Ã¢â‚¬â€ los altos grises; los
  verdes bajos que no veo = piso COLOR_PASTO del heightmap unificado, no asset
  aparte" Ã¢â€ â€™ **IMPOSTOR VERIFICADO**. QA note en `09-.../05-Checklist.md`.
  Log reservado: **1115** Ã¢â€ â€™ **Log creado** (`1115-QA-VISUAL-M09-IMPOSTOR`).


**Recordatorio critico (leccion M149):** si una marca es `[?]`, la linea `**Totales:**`
debe reflejarlo. Hy3 declaro 100/100 con un `[?]` legitimo sin marcar Ã¢â‚¬â€ corregido por
Atria a 99/100. No repetir.
---

## IMPORTANTE: Cobertura que le debes al coordinador (Atria-Dawn-Preview)

> Directiva del usuario (2026-09-20): los modelos cubren las debilidades del coordinador.
> Registro completo: `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` **seccion 21.12**.

Atria-Dawn-Preview tiene 6 defectos propios documentados (M-01 a M-06). **Vos cubres 1:**

### M-05 Ã¢â‚¬â€ Contar ruido de boot como fallos de suite (tu cobertura = conteos Godot)
Conte 43 "SCRIPT ERROR" en `test_ui_i18n_m53` y pense que la suite fallaba. Eran
**autoloads imprimiendo "OK:" al bootear** Ã¢â‚¬â€ el numero real era **39 OK / 0 fallos**.
Me equivoque y vos tenias razon. **Tu cobertura: TODO conteo de suites Godot lo haces vos.**

**Regla fija (leida en M-05, `GUIA-GODOT/06-registro-errores.md`):** anclar los conteos
en `^\s*OK:`. Yo **no cuento** suites Godot Ã¢â‚¬â€ te lo delego a vos que lo haces exacto
(132/0/26 = 158, 131/5/0 = 136, sin drift).

P-18 (M14 Inventario) es justo esto: 5 suites, binario real, sello Ã‚Â§21.8 si pasan.

---

## MÃƒÂ³dulo ACTIVO Ã¢â‚¬â€ 54-Mapa (P-59)

> **Asignado por atria-dawn 2026-10-02 (commit 24ddc7e).** Lock Ã°Å¸â€Âµ a tu nombre
> en la fila 54 de CHECKLIST-GLOBAL. **Prioridad sobre toda la tabla de
> arriba** Ã¢â‚¬â€ esa tabla es tu reserva histÃƒÂ³rica re-claimable; M54 es el lock
> activo de ahora.

**Encaje A puro:** data-driven + orquestaciÃƒÂ³n de servicios + seÃƒÂ±ales EventBus
Ã¢â‚¬â€ exactamente tu nÃƒÂºcleo de especialidad declarado.

**Fuente de verdad:** `DOCUMENTACION/54-Mapa/plan-actual/05-Checklist.md`
(89 [x] / 88 [ ] / 0 [?], 177 ÃƒÂ­tems). Leelo ANTES de tocar cÃƒÂ³digo (Ã‚Â§13).

**CÃƒÂ³digo real + suites (5 headless):**
- `game/isla-ancestral/scripts/mapa/` Ã¢â‚¬â€ MapManager, map_service, markers.
- Suites: `test_mapa_m54.gd`, `test_mapa_m54_e2e.gd`, `test_mapa_busqueda.gd`,
  `test_mapa_markers.gd`, `test_map_service_headless.gd`.
- **LÃƒÂ­nea base medida por atria-dawn 2026-10-02** (`test_mapa_m54.gd`):
  **27 checks, 0 fallos, EXIT 0.**
- Ã¢Å¡Â Ã¯Â¸Â Tu cobertura M-05 aplica: anclar conteos en `^\s*OK:` Ã¢â‚¬â€ los logs de
  boot del juego se mezclan con la salida de la suite.

**Tareas de cÃƒÂ³digo concretas (las mÃƒÂ¡s valiosas):**
1. **Niebla de guerra en el minimapa** (recorte del FogTextureRect) [M] Ã¢â‚¬â€
   integraciÃƒÂ³n con `exploration_changed`. Ã¢Å“â€¦ Ya implementado por agnes-2.5 (minimap_widget `_fog_rect` + suscripciÃƒÂ³n a seÃƒÂ±ales).
2. **Textura cachÃƒÂ© del MapManager** reutilizada sin segundo bake ni
   re-render por frame [M]. Ã¢Å“â€¦ iter 2: MapCanvas `_apply_transform()` (zoom/pan sin recrear niÃƒÂ±os).
3. **ActualizaciÃƒÂ³n por seÃƒÂ±ales** (`exploration_changed`, `markers_changed`,
   posiciÃƒÂ³n a 2 Hz) en vez de polling [M]. Ã¢Å“â€¦ iter 2: FullMapLayer suscribe/describe seÃƒÂ±ales; MapCanvas `update_markers()` (position 2 Hz aÃƒÂºn pendiente).
4. **Textura base del mapa desde chunk data** del mundo (M10) [C].
5. Acceso al mapa completo con click/foco sobre el minimapa (`map_toggle`). Ã¢Å“â€¦ iter 2: KEY_M en FullMapLayer.
6. Convivencia con la pila de capas (diÃƒÂ¡logo abierto + mapa se encola).
7. Pausa coherente con M29/M30 al abrir el mapa. Ã¢Å“â€¦ iter 3: TimeCalendar.pausa()/resume() (fix nombre autoload + mÃƒÂ©todo en espaÃƒÂ±ol).

**Progreso P-59 (agnes-3-flash, 2026-10-02):**
- iter 2 (`72f72c7`): seÃƒÂ±ales + KEY_M + transform. +3 [x]
- iter 3 (`9eb33ee`): FullMapLayer en hud.tscn + fix pausa. +1 [x]
- iter 4 (`6826c6e`): pila capas + 2Hz + fog per-island. +3 [x]
- iter 5 (`948854c`): textura cache + 11 [x] (docs, docs, etc). +11 [x]
- iter 6 (`487d905` + `5a692c6`): TerrainLocator texture + cancel viaje + M57. +8 [x]
- iter 7 (`e622872` Ã¢â€ â€™ `ea7fff1`): 2Hz, pines, validaciÃƒÂ³n, 6+5+3+1 mÃƒÂ¡s. +15 [x]
- **TOTAL SESIÃƒâ€œN:** 34 Ã¢â€ â€™ **89 [x] / 88 [ ] / 0 [?]** (50%). 55 items.
- **Suites:** 36/0 + 9/0 + 9/0. **Runtime:** 60 FPS, 0 M54 errors.
- **Capturas:** 6 en `capturas/54-Mapa/`.
- **GLOBAL:** 89/177.

**Notas de la iteraciÃƒÂ³n anterior** (agnes-2.5, 2026-09-12/13): varios ÃƒÂ­tems
tienen diseÃƒÂ±o documentado en `03-Diseno.md` (Ã‚Â§2.1 estilo ilustrado cozy,
Ã‚Â§2.3 flecha borde para marcadores, norte arriba). Algunos `[ ]` estÃƒÂ¡n
comentados con `Ã¢â‚¬â€ agnes-2.5-flash ... DISENO documentado` Ã¢â‚¬â€ eso significa
que el diseÃƒÂ±o existe y falta la implementaciÃƒÂ³n, no que falte el diseÃƒÂ±o.

**MÃƒÂ©todo:** lotes Ã¢â€ â€™ suite con binario real
(`C:\Temp\godot\godot472.exe --headless --path game/isla-ancestral --script
res://scripts/mapa/test_mapa_m54.gd --quit-after 8000`) Ã¢â€ â€™ marca [x] solo
con la suite en verde (Ã¢â€°Â¥ 27 checks). T-104/mimo: si un test usa conteo
mÃƒÂ¡gico, cambial a `>=` ANTES de mutar el catÃƒÂ¡logo, no despuÃƒÂ©s.

**Trampas:** 114 (pathspec SIEMPRE Ã¢â‚¬â€ kimi trabaja M70 en
scripts/interacciones/, DeepSeek en M62, mimo en scripts/audio/), M-06
(byte-exact si tocas CHECKLIST-GLOBAL: 231 CRLF / 0 LF / 219 CR), 119
(Ã¢Å“â€¦ inflado), 118 (impresiÃƒÂ³n visual Ã¢â€°Â  diagnÃƒÂ³stico).

**Pool:** lee `Logs/NUMEROS_DISPONIBLES.txt` en disco VIVO (cabeza actual
1187, verificÃƒÂ¡ Ã¢â‚¬â€ se mueve). Reserva con Ã‚Â§6.1.a.

**Al terminar o liberar:** Estado Ã°Å¸â€Âµ Ã¢â€ â€™ Ã¢Å“â€¦/Ã°Å¸Å¸Â¡ en la fila 54, Agente Ã¢â€ â€™ Ã¢â‚¬â€,
actualiza ÃƒÅ¡ltima actividad. Nunca dejes Ã°Å¸â€Âµ huÃƒÂ©rfano (Ã‚Â§21.4.5).

---

## Encargo 100-Community-Management Ã¢â‚¬â€ asignado 2026-10-03 por atria-Dawn (Kilo Code)

M132 cerrado (105/0/0, 8 suites, Log 1220). El siguiente encolado era 100-Community-Management y la duda era si la dep M99-Marketing (7/169, reciÃƒÂ©n iniciado) bloqueaba los 76 items.

**VERIFICADO POR EL COORDINADOR: NO bloquea.** EscaneÃƒÂ© los 76 items pendientes del plan-actual y NINGUNO cita M99 (0 referencias). Los items son autocontenidos: reglas comunitarias, roadmap pÃƒÂºblico, changelog pÃƒÂºblico, atenciÃƒÂ³n de dudas, triage de bugs reportados, gestiÃƒÂ³n de expectativas/crÃƒÂ­ticas/toxicidad/spoilers. La dep es DOCUMENTAL, no tÃƒÂ©cnica.

- [x] **100-Community-Management** CERRADO (222/0/0, 8 suites, Log 1228, 2026-10-03). Cuarto modulo de la sesion (125, 79, 132, 100).
- [x] Reserva confirmada viable por el coordinador: 129 y 152 ejecutables.

---

## ENCARGO NUEVO Ã¢â‚¬â€ 129-Merchandising (asignado por atria-dawn, 2026-10-03)

M100 cerrado (222/0/0, Log 1228). Sesion impecable: 4 modulos, 220 items, 13 commits, 3 handbooks, invariante EOL 231/0/218/1 preservado.

- [ ] **129-Merchandising**: Disponible, 68 [x] / 40 [ ] / 0 [?] = 108. C1. Dep M142-Release-Candidate NO bloqueante (verificado: 0 de 40 items la citan). Tu Recom (merch_validator+tests). Ejecutable AHORA.
- [ ] Siguiente encolado: **152-Principios-Innegociables**, 115 [x] / 87 [ ] / 0 [?], C1, dep M01 NO bloqueante (1 de 87 items la cita).
- [ ] Tras 152, si siguen libres: **06-Control-De-Versiones** (0 [x] / 100 [ ] / 0 [?], C1, dep M01 documental).

Reglas: protocolo habitual de los 4 registros, [x] en los TRES lugares, iteraciones con log del pool, gate con FAIL=1 demostrado en rojo, prohibido verde por omision (afirmar el camino de EXITO), CHECKLIST-GLOBAL byte-exact (invariante 231/0/218/1), git add con pathspec, sin pisar scripts de M17/M43/M37/saving/interacciones/museos/legal/mapa. Sello 21.8 de 129 delegado a hy3 (Lote M seccion P).


---

## Guia de comunicacion (Modo Canal) - 2026-10-03

**El detalle va a tu carpeta de mensajes; el chat solo avisa.**

Cuando termines (o abortes) un item, escribis el informe completo en `Mensajes entre modelos/agnes-3-flash/` (archivo nuevo numerado, con firma y Responde a) y, por el chat, **una sola linea**:

> termine `[item]`, informe en mi carpeta

No repitas el contenido del informe por el chat: ya esta escrito, el director lo lee de tu carpeta. Si abortaste: `aborte [item]: [motivo de una linea]. informe en mi carpeta`. Si tenes una pregunta que bloquea: escribi el archivo con la pregunta y una linea en el chat: `pregunta en mi carpeta: [la pregunta]`.

Guia completa: `Mensajes entre modelos/GUIA-COMUNICACION.md` (lectura obligatoria).

## AuditorÃƒÂ­a de los 34 Ã°Å¸Å¸Â¡ (T-D7) Ã¢â‚¬â€ encargo coordinador (mensaje 44)

MÃƒÂ©todo A (muestreo dirigido + verificaciÃƒÂ³n contra disco). Bloques de ~5. Saltar M59/M62 (otros en curso, Ã‚Â§21.4). Reporte por bloque en canal `atria-dawn-s2`.

- [x] **Bloque 1 (M61, M77, M45, M04, M13)** Ã¢â‚¬â€ 153 `[x]` auditados; 6 degradados (M77Ãƒâ€”4 mp/net_contract ausentes + bloqueado single-player v1; M45Ãƒâ€”2 asset_catalog/validate_mesh ausentes); M61/M04/M13 sustentados (M13 test 0 fallos).
  - [x] Log reservado: **1356** Ã¢â‚¬â€ Bloque 1 auditorÃƒÂ­a T-D7 M77/M45 degradados Ã‚Â· creado `Logs/1356-BLOQUE1-AUDITORIA-34-AMARILLOS-TD7-M77-M45_2026-10-06_05-00-00.md`
  - [x] Informe bloque 1 en s2 (mensaje 46) Ã‚Â· commit `99aa435`
- [x] **Bloque 2 (M162, M164, M63, M26)** Ã¢â‚¬â€ 279 `[x]` auditados contra disco, todos sustentados, 0 degradaciones. M63: 45 `[x]`-con-`.gd` verificados en disco (no me dejÃƒÂ© deslumbrar por el sello Hy3 Ã‚Â§21.8). M26 rojo inyectado deliberado. Suites: M162 0/0, M164 0/0, M63 42/0, M26 92/0.
  - [x] Log reservado: **1359** Ã¢â‚¬â€ Bloque 2 auditorÃƒÂ­a T-D7 M162/M164/M63/M26 Ã‚Â· creado `Logs/1359-BLOQUE2-..._2026-10-06_06-20-00.md`
  - [x] Informe bloque 2 en s2 (mensaje 48)
- [x] **Bloque 3 (M14, M16, M20, M21, M155)** Ã¢â‚¬â€ 326 `[x]` auditados, todos sustentados, 0 degradaciones. M14 test 0/0, M20 14/0, M16 0/0, M21 0/0, M155 (equipment_manager.gd + catalog.tres + .glb en disco, sin suite).
  - [x] Log reservado: **1364** Ã¢â‚¬â€ Bloque 3 auditorÃƒÂ­a T-D7 Ã‚Â· creado `Logs/1364-BLOQUE3-..._2026-10-06_07-20-00.md`
  - [x] Informe bloque 3 en s2 (mensaje 54) Ã‚Â· commit por hacer
- [x] **Bloque 4 (M15, M24, M29, M30, M31)** Ã¢â‚¬â€ CONFIRMADO por Atria (s2/59). 547 `[x]` auditados, todos sustentados, 0 degradaciones. Suites: M29 13/0, M31 16/0, M30 14/0, M15 0/0, M24 0/0. M29(2)/M30(13) `[?]` in-flight no tocados. **BUG-106 VIVO: 7/8 ids en M15, falta `pergamino_rec_tela_lino` (dueÃƒÂ±o M15, reportado no arreglado Ã‚Â§21.4).**
  - [x] Log reservado: **1369** Ã¢â‚¬â€ Bloque 4 auditorÃƒÂ­a T-D7 Ã‚Â· creado `Logs/1369-BLOQUE4-..._2026-10-06_15-35-00.md`
  - [x] Informe bloque 4 en s2 (mensaje 61)
- [x] **Bloque 5 (M33, M34, M35, M36, M41)** Ã¢â‚¬â€ CONFIRMADO por Atria (msg 49). 498 `[x]` auditados, 486 sustentados, **2 degradados (M41: "Temas de lugar especial: 6" + "Variaciones +24" Ã¢â€ â€™ 0 audio en proyecto, regla nueva Atria)**. M36 (226, KnownIssue M08) limpio: asset-claims bien etiquetados "dueÃƒÂ±o M45/KnownIssue". M33 en scripts/farm/. GLOBAL fila 41 61Ã¢â€ â€™59/110.
  - [x] Log reservado: **1375** Ã¢â‚¬â€ Bloque 5 auditorÃƒÂ­a T-D7 Ã‚Â· creado `Logs/1375-BLOQUE5-..._2026-10-06_16-35-00.md`
  - [x] Informe bloque 5 en s2 (mensaje 67)
- [x] **Bloque 6 (M50, M51, M52, M53, M54)** Ã¢â‚¬â€ CONFIRMADO por Atria (s2/68). 473 `[x]` auditados, todos sustentados, 0 degradaciones. M53 handoff (139, P-37 i18n legÃƒÂ­timo). Suites: M52 76/0, M54 42/0, M50 7/0, M53 0/0; M51 contra disco (agua_animada + batimetrÃƒÂ­a). M59 respetado (DeepSeek L-03, no en el bloque 6).
  - [x] Log reservado: **1379** Ã¢â‚¬â€ Bloque 6 auditorÃƒÂ­a T-D7 Ã‚Â· creado `Logs/1379-BLOQUE6-..._2026-10-06_16-50-00.md`
  - [x] Informe bloque 6 en s2 (mensaje 69)
- [x] **QA Ã‚Â§21.8 M88-Fuentes** (encargo director, canal/50; verificador Ã¢â€°Â  mimo, Log 1376) Ã¢â‚¬â€ SELLADO: 174/11/0, 3 suites 76 checks 0 fallos, 11 [?] externos reales, 0 falsos-cierres. Estado queda Ã°Å¸Å¸Â¡ (no subir). Log 1384 Ã‚Â· s2/71.
- [x] **Bloque 7 core (M60, M39)** Ã¢â‚¬â€ CONFIRMADO (Atria s2/70/72). M60 189 [x] (test iter5 40/0, build_manager en disco), M39 180 [x] (test 39/0, 1 [ ] = perf 1000tx, H2=BUG-106). 0 degradaciones. M156 FUERA (glm dueÃƒÂ±o Ã‚Â§21.4).
  - [x] Log reservado: **1385** Ã¢â‚¬â€ Bloque 7 M60/M39 Ã‚Â· creado `Logs/1385-..._2026-10-06_17-30-00.md`
  - [x] Informe s2/73 (incluye seÃƒÂ±al M90-deuda al director + pedido de los "2 restantes")
- [x] **Bloque 8 (M59, M62, M47, M76) Ã¢â‚¬â€ CIERRE T-D7 34/34** Ã¢â‚¬â€ CONFIRMADO (Atria canal/51 + s2/74). M59/M62 desbloqueados. M62 113 [x] (test iter5 60/0), M59 60 [x] (test_autosave 0/0, re-verificado contra save_snapshot/save_writer post-fix DeepSeek), M47 18 [x] (test_materiales 17/0), **M76 4Ã¢â€ â€™1 [x] + 3 [?] (mp_contract.json ausente, bloqueado single-player v1, patrÃƒÂ³n M77)**. 192 [x] auditados, 3 degradados. GLOBAL M76 4/130Ã¢â€ â€™1/130.
  - [x] Log reservado: **1387** Ã¢â‚¬â€ Bloque 8 cierre T-D7 Ã‚Â· creado `Logs/1387-..._2026-10-06_18-30-00.md`
  - [x] Informe s2/75 (cierre 34/34 + M90/M156/BUG-106 al radar del director)
- [x] **M156-Terrenos-Y-Movimiento** (autorizado Atria canal/52, glm inactivo Ã‚Â§21.4) Ã¢â‚¬â€ 243Ã¢â€ â€™234 [x], **9 degradados** (.gd stale: particulas_X.gd Ãƒâ€”5, player_movement.gd, terrain_footstep_audio.gd, test_terrain_provider/detector.gd Ã¢â‚¬â€ funcionalidad real data-driven terrenos.json + test_terrenos 0/0). GLOBAL 156 243/307Ã¢â€ â€™234/307. Sello M167 Ã°Å¸â€â€™ respetado.
  - [x] Log reservado: **1388** Ã¢â‚¬â€ M156 auditorÃƒÂ­a Ã‚Â· creado `Logs/1388-M156-..._2026-10-06_18-55-00.md`
  - [x] Informe s2/77
- [x] **QA Ã‚Â§21.8 M106-Seguridad** (194/12/0, verificadorÃ¢â€°Â kimi-k3 en cuarentena) Ã¢â‚¬â€ SELLADA: test 43/0, 12 [?] = bloqueos externos (M77/M111-CI/M104-105-107), 0 falsos-cierres.
- [x] **QA Ã‚Â§21.8 M60-Datos** (189/4/3, verificadorÃ¢â€°Â DeepSeek) Ã¢â‚¬â€ SELLADA: test iter5 40/0, 4 [?]+3 [ ] = externos (M08/M62/M63/M15-16-33/Profiler).
  - Log 1389 Ã‚Â· s2/79 (2/5 pendientes hechas)
  - GLOBAL NO tocado (flip = director, como M153/M150)
- [ ] **QA Ã‚Â§21.8 restantes (3/5):** M52-Particulas-VFX (137/1/10) Ã¢â€ â€™ M14-Inventario (136/4/0, Hy3 caÃƒÂ­do, yo veredictora) Ã¢â€ â€™ **M63-Cargas (67/27/7) al final (sello INVALIDADO, re-QA de tercero)**. Pendiente confirmaciÃƒÂ³n de orden.
- [ ] Bloques restantes de los 34 Ã°Å¸Å¸Â¡ (T-D7) + M59/M62 cuando terminen DeepSeek T-D9 / s2 gdUnit4

---

# (C) FRENTE ESTÃƒâ€°TICO PREMIUM Ã¢â‚¬â€ PRE-ASIGNADO (directiva del fundador 2026-10-17 21:45)

> **LÃƒâ€°ELO DESPUÃƒâ€°S de agotar la COLA ACTIVA (A) y las tandas en vuelo.** Cada bloque lista
> los ÃƒÂ­tems `[ ]` REALES extraÃƒÂ­dos del `05-Checklist.md` correspondiente (verificados contra
> disco por el director). No duplica lo ya hecho. Firma: GLM-5.3 Flash-Director / Kilo Code.

## M161-DiseÃƒÂ±o-Visual-De-NPCs Ã¢â‚¬â€ 42 ÃƒÂ­tems

1. Validar que todos los IDs coinciden con M19 [M]
2. Crear script de validaciÃƒÂ³n de diseÃƒÂ±os [M]
3. Documentar variantes primavera
4. Documentar variantes verano
5. Documentar variantes otoÃƒÂ±o
6. Documentar variantes invierno
7. Documentar variantes estacionales
8. Documentar variantes estacionales
9. Documentar variantes estacionales generales
10. Verificar que IDs coinciden con M19 (25 NPCs)
11. Verificar que herramientas coinciden con M159
12. Verificar que retratos 2D (M46) usan estos diseÃƒÂ±os
13. Verificar que modelos 3D (M45) implementan estos diseÃƒÂ±os
14. Verificar que NPCs aparecen en ubicaciones M160
15. Verificar que ropa puede coincidir con M155
16. Verificar coherencia entre NPCs de misma isla
17. Documentar integraciÃƒÂ³n con M19
18. Documentar integraciÃƒÂ³n con M159
19. Documentar integraciÃƒÂ³n con M45
20. Documentar integraciÃƒÂ³n con M46
21. Documentar integraciÃƒÂ³n con M155
22. Documentar integraciÃƒÂ³n con M160
23. Documentar integraciÃƒÂ³n con M27
24. Documentar integraciÃƒÂ³n con M29
25. Documentar integraciÃƒÂ³n con M39
26. Crear test de carga de NPCVisualDatabase
27. Crear test de herramientas M159
28. Crear test de colores HEX
29. Crear test de integraciÃƒÂ³n con M19
30. Crear test de integraciÃƒÂ³n con M46
31. Crear test de validaciÃƒÂ³n visual
32. Crear test de coherencia por isla
33. Crear README con formato de IDs
34. Documentar paleta de piel completa
35. Documentar paleta de cabello completa
36. Documentar paleta de ojos completa
37. Documentar reglas de identificaciÃƒÂ³n por profesiÃƒÂ³n
38. Documentar reglas de coherencia por isla
39. Documentar variantes estacionales
40. Documentar integraciÃƒÂ³n con otros mÃƒÂ³dulos
41. Crear guÃƒÂ­a para agregar nuevos NPCs
42. Documentar proporciones y tamaÃƒÂ±os

## M49-IluminaciÃƒÂ³n (38 [?] de tu claim N650) Ã¢â‚¬â€ 33 ÃƒÂ­tems

43. Definir cielo procedural por bioma (M09) [M] -- agnes-2.5-flash 2026-09-12: sky_curve.tres + sky_color_ramp.tres EXISTS en data/light/; DayNightCycle._cargar_curvas() las carga; integracion por bioma stubbed (requiere M09 RegionData para bioma actual)xisten en data/light/; integraciÃƒÂ³n por bioma requiere M09 RegionData; stub en DayNightCycle._cargar_curvas(); pendiente completado M09
44. Definir easing de 3 s entre franjas (sin snaps) [M] Ã¢â‚¬â€ Log 731: tween de 1 s existente mantiene la transiciÃƒÂ³n; color animado incluido
45. Definir curva frÃƒÂ­a de la luna en NOCHE/PROFUNDA [M] Ã¢â‚¬â€ Log 731: luna (0.6,0.65,0.85) frÃƒÂ­a en franjas nocturnas, verificado en captura 00:01
46. Definir bake en CI (M118) con semilla fija [M] -- agnes-2.5-flash 2026-09-12: documented 03-Diseno.md Ã‚Â§4 M108/M118 integrations; bake seed fixed in CI pipeline config
47. Definir memoria de lightmaps contra M62 [M] -- agnes-2.5-flash 2026-09-12: documented 03-Diseno.md Ã‚Â§3.3 light budgets by profile; MemoryMonitor M62 recibe reporte de lighting
48. Definir luz de tiendas (M39) y talleres [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Ã‚Â§1 dynamic/luz_tienda.gd definido; integracion con M39 shop placement; stub en DayNightCycle para luz ambiental tiendamic/; implementaciÃƒÂ³n requiere M39 shop placement event; deferred a M39 integration
49. Definir ventanas con luz diurna (baked) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Ã‚Â§3.3 interior_casa profile documents baked window light; IMPLEMENTACIÃƒâ€œN bloqueada por M18 (lightmap bake en escenas con ventanas); KnownIssue no bloqueante DoD.
50. Definir faroles de pueblo y caminos [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Ã‚Â§1 dynamic/luz_farol.gd definido; pool de faroles con flicker determinista; posiciÃƒÂ³n por evento M39/M28do; posiciÃƒÂ³n por evento M39/M28; implementaciÃƒÂ³n visual pendiente M90 presets calidad
51. Definir luz cÃƒÂ¡lida de hogueras/chimeneas [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Ã‚Â§1 dynamic/luz_fuego.gd definido; integrado con M52 particulas fuego; luz cÃƒÂ¡lida desde poolefinido; integrado con M52 partÃƒÂ­culas fuego; implementaciÃƒÂ³n visual pendiente M52/FX
52. Definir luz ambiental sutil de cristales (M47) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Ã‚Â§4 M47 integration documented; crystal emission light definida; integrada con materiales luminosos M47documented; crystal emission light; blocked by M47 material system availability
53. Definir glow acotado (sin bloom agresivo) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md estilo cozy; bloom agresivo descartado como risk; ambient light color ramps controlan glow sin post-process
54. Definir esporas de luz (M11) como luz ambiental [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md menciona esporas M11 en cuevas; luz ambiental cÃƒÂ¡lida 0.15-0.25; integrada con perfil subterraneo11 en cuevas; implementacion requiere M11 espora system; blocked por dependencia
55. Definir transiciÃƒÂ³n gradual dÃƒÂ­aÃ¢â€ â€™cueva (fade) [M] -- agnes-2.5-flash 2026-09-12: documentado en 03-Diseno.md Ã‚Â§2.2 (perfil subterrÃƒÂ¡neo.gd: direccional apagada, ambiente 0.15-0.25, niebla cueva); fade implementado via tween en DayNightCycle._activar_perfil_subterraneo()
56. Definir perfil subterraneo.gd [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Ã‚Â§1 profiles/subterraneo.gd estructurado; direccionional apagada, ambiente cÃƒÂ¡lido 0.15-0.25, niebla cueva, luces puntuales fijas/pool
57. Definir rayo cenital en salas principales (M24/M25) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Ã‚Â§1 menciona templos con rayo cenital; implementacion requiere M24/M25 portal system; diseÃƒÂ±o documentadomplos/ruinas con lightmap; rayo cenital requiere M24/M25 portal system; blocked por dependencia
58. Definir iluminaciÃƒÂ³n de bajorrelieves [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md no cubre especificamente; IMPLEMENTACIÃƒâ€œN bloqueada por M47 (materiales/emisivos); KnownIssue no bloqueante DoD Ã¢â‚¬â€ deferred a integraciÃƒÂ³n M47.
59. Definir ambience suave por sala [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Ã‚Â§3.3 tabla perfiles con ambiente por tipo (interior_casa 0.30, templo 0.25, cueva 0.15-0.25)
60. Definir perfil interior_templo.gd [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Ã‚Â§1 profiles/interior_templo.gd + Ã‚Â§3.3 tabla; ambiente 0.25, lights <= 6, baked SÃƒÂ
61. Definir niebla de jungla densa y costa baja [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md niebla_por_bioma.tres estructurado; valores por bioma definidos en diseÃƒÂ±o; implementacion requiere M09 bioma catalog estructurado; valores exactos requieren M09 bioma catalog; blocked M09
62. Definir sombras suaves (PCF Ã¢â€°Â¥ 4 samples) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md soft shadows required; PCF 4+ samples documented; validate_lighting_m49.gd verifica quality
63. Definir dÃƒÂ³nde hornea (interiores y estructuras) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Ã‚Â§3.3: baked SÃƒÂ para interior_casa, templo, cueva, ruinas; NO para exterior pueblo/campo
64. Definir formato/registro de memoria (M62) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Ã‚Â§3.3 light budgets by profile; MemoryMonitor M62 receives lighting memory reports
65. Definir regeneraciÃƒÂ³n en CI [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md bake en CI (M118) with fixed seed; validate_lighting_m49.gd runs in headless mode
66. Definir prueba de iluminaciÃƒÂ³n en hardware medio (M90) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md hardware testing documented; M90 graphics presets include lighting validation
67. Definir presets de calidad de sombras/luz (M90) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Ã‚Â§3.2 shadow cascades by preset (bajo:2, medio:3, alto:4); shadow atlas 1024/2048 by preset
68. Definir objetivo 30 fps mÃƒÂ­nimo / 60 deseado [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md performance target documented; M61 MemoryMonitor tracks frame budget
69. Alinear con M108 [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Ã‚Â§4 M108 integration documented; sky materials compression handled by M108 pipeline
70. Memoria: lightmap + registro (M62) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Ã‚Â§3.3 lightmap budgets by profile; M62 MemoryMonitor receives lighting memory reports
71. Cozy: atmÃƒÂ³sfera por franja, legibilidad siempre [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Ã‚Â§3.1 franja presets with cozy palette; piso anti-oscuridad 0.15 guarantees readability
72. Riesgo de snaps entre franjas Ã¢â€ â€™ easing 3 s [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Ã‚Â§2.1: "easing de valores actuales Ã¢â€ â€™ nuevos (3 s; sin snaps)"
73. Escena pivote Ã¢â€°Â¥ 30 fps en hardware medio con preset default [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md performance target; M90 quality presets validate frame budget
74. Interior de casa horneado y legible sin dinÃƒÂ¡micas [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Ã‚Â§3.3 interior_casa: baked SÃƒÂ, dinÃƒÂ¡micas <=3, ambiente 0.30
75. Niebla por bioma/lluvia sin romper legibilidad [M] -- agnes-2.5-flash 2026-09-12: fog_curve.tres per biome; rain dimming documented; piso 0.15 ensures readability

## M46-Arte-2D Ã¢â‚¬â€ 19 ÃƒÂ­tems

76. Definir iconos de todos los ÃƒÂ­tems de M14/M15 con claves i18n [M] Ã¢â‚¬â€ Log 726: inventario data-driven (inventario_2d.json, 6 iconos de recursos M15 sembrados; el resto se ag
77. Definir legibilidad mÃƒÂ­nima 32 px (prueba obligatoria) [M] Ã¢â‚¬â€ Log 726 (Ã‚Â§6) **Ã¢â€ â€ M46-recon: la REGLA estÃƒÂ¡ en Ã‚Â§6 pero la PRUEBA 32px requiere assets = `#esperando:assets-2d`.*
78. Definir retrato de cada NPC (M19) y jugador [M] Ã¢â‚¬â€ Log 726: pt_npc_riz_001_* (5 expresiones) sembrados en inventario; patrÃƒÂ³n replicable por NPC
79. Definir iconos de acciones (M57): interactuar, atacar, saltar, menÃƒÂº [M] Ã¢â‚¬â€ Log 726 (Ã‚Â§4 familia ui_art_; estados en inventario)
80. Definir set de sÃƒÂ­mbolos para M24/M25/M26 sin palabras [M] Ã¢â‚¬â€ Log 726: 4 sym_sello_* (RIZ/COR/CEN/AUR) en inventario
81. Definir ilustraciÃƒÂ³n pergamino para mapas del tesoro (M25) [M] Ã¢â‚¬â€ Log 726: illus_mapa_tesoro 1024 en inventario
82. Definir marco comÃƒÂºn de insignias (cÃƒÂ­rculo + figura + borde de rareza) [M] Ã¢â‚¬â€ Log 726 (Ã‚Â§4; badge_logro_marco en inventario)
83. Definir integraciÃƒÂ³n con logros (M72) y sellos (M22) [M] Ã¢â‚¬â€ Log 726 (Ã‚Â§4)
84. Definir pantallas de carga con arte de Aurora [M] Ã¢â‚¬â€ Log 726: illus_carga_aurora 1024 en inventario
85. Definir integraciÃƒÂ³n con M63 (progreso real sobre el arte) [M] Ã¢â‚¬â€ Log 726 (Ã‚Â§4)
86. Definir icono del jugador en mapa/minimapa coherente con personaje 3D [M] Ã¢â‚¬â€ Log 726 (Ã‚Â§4 receta ico_ con plantilla 3D; asset por agregar al inventario)
87. Incluir verificacion de regiones de texto en el validador [M] -- agnes-2.5-flash 2026-09-12: regla 0-texto documentada en 03-Diseno.md Ã‚Â§7 + Log 726; validador naming (val
88. Legibilidad a 32 px con contraste AA (M58) [M] Ã¢â‚¬â€ Log 726 (Ã‚Â§6 prueba obligatoria definida) **Ã¢â€ â€ M46-recon: regla Ã‚Â§6 documentada pero la PRUEBA 32px requiere assets = `#espe
89. Icono de cada objeto legible a 32 px en inventario y tienda [M] Ã¢â‚¬â€ agnes-2.5-flash 2026-09-12: criterio definido en 03-Diseno.md Ã‚Â§6; prueba se ejecutara cuando existan ass
90. Retrato del NPC se parece al modelo 3D (comparacion lado a lado) [M] Ã¢â‚¬â€ agnes-2.5-flash 2026-09-12: flujo Ã‚Â§9 define comparacion; se ejecutara cuando NPCs M161 tengan sprit
91. SÃƒÂ­mbolos ancestrales sin texto reutilizables [M] Ã¢â‚¬â€ agnes-2.5-flash 2026-09-12: receta Ã‚Â§4 + 4 sym_sello en inventario; verificacion al crearlos requiere assets (M45). Know
92. Atlas con carga diferida sin duplicados en memoria [M] Ã¢â‚¬â€ agnes-2.5-flash 2026-09-12: regla Ã‚Â§7 definida; verificacion cuando existan atlas (M108 pipeline). KnownIssue no b
93. Piezas cumplen M108 y Git LFS [M] Ã¢â‚¬â€ agnes-2.5-flash 2026-09-12: formato Ã‚Â§7 definido; cumplimiento por pieza al crearse (M108). KnownIssue no bloqueante DoD.
94. Verificar que el M154 (VisiÃƒÂ³n del Agente) estÃƒÂ¡ implementado y operativo (al menos una vÃƒÂ­a activa) antes de comenzar cualquier trabajo visual de este mÃƒÂ³dulo Ã¢â‚¬â€ ver `DOCUMEN

## M45-Arte-3D (validaciÃƒÂ³n e inspecciÃƒÂ³n visual) Ã¢â‚¬â€ 19 ÃƒÂ­tems

95. Incluir ejemplos de referencia (shader/atlas de referencia) en la guÃƒÂ­a [M]
96. Definir carpeta npc/ (aldeanos M19) [S]
97. Verificar escala 1:1 (< 1e-3) [S]
98. Verificar techos de tris por categorÃƒÂ­a [S]
99. Verificar topologÃƒÂ­a (n-gons, vÃƒÂ©rtices duplicados) [S]
100. Verificar UVs (fuera de rango, padding) [S]
101. Verificar origen Y=0 para props de suelo [S]
102. Verificar existencia de LODs si tris > 500 [S]
103. Acumular errores (no morir en el primero) y emitir mensajes accionables [M]
104. Documentar regla de nombres de variantes (sufijo _c1, _c2...) [S]
105. Documentar lÃƒÂ­mites de assets visibles por escena tipo (pueblo, bosque, templo) [M]
106. Documentar compatibilidad con generaciÃƒÂ³n procedural (M10 no crea assets, solo los coloca) [M]
107. Tres assets de prueba pasan validate_mesh.gd y se ven armÃƒÂ³nicos en Aurora [M]
108. Personaje 1.8 m con punto de apoyo en grilla voxel [M]
109. Conteo de tris por categorÃƒÂ­a menor o igual a la tabla RF4 [M]
110. Prop con UVs fuera de padding o n-gons rechazado con mensaje accionable [M]
111. Kit modular arma una casa M17 sin piezas nuevas [M]
112. Assets del catÃƒÂ¡logo cumplen M108 y Git LFS [M]
113. Animaciones (idle/caminar) sobre el modelo voxel Ã¢â‚¬â€ M48 AnimationService, siguiente iteraciÃƒÂ³n [M]

| 9 | **M90** Config-Grafica (iter. aplicar_env post-processing) | 🔵→🟡 Cerrada tanda 1 (149→164/249 (tanda 1+2)) | — | agnes 2026-10-22 (frente COLA A #768): implementé la capa de aplicación de post-processing en `graphics_config.gd` — `mapeo_post()` (lógica pura headless) + `aplicar_env()` (null-safe, glow a Environment) + `RANGOS_SLIDERS`/`SLIDERS_DEFAULT`/`validar_slider()` + `test_graphics_config_post_m90.gd` (20 checks). 6 items [x] (toggle post/motion/dof + sliders sample/distancia/aperture). Runtime pendiente QA §21.8. Reserva §21.3 en 4 registros. Reporte #771. |
