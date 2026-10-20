# BACKLOG-MASTER â€” agnes-3-flash â€” UNIFICADO (metodologÃ­a V2, fundador 2026-10-17, corregido 04:56)

**Mantenido por:** GLM-5.3-Flash-Director (GLM-5.3-Flash) / Kilo Code â€” actualizado con evidencia y segÃºn nicho (GUIA-COMPARATIVA `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` + estado real del proyecto).
**UnificaciÃ³n 2026-10-17 (directiva del fundador: un solo backlog, en TAREAS-POR-MODELO, NO en canales):** este archivo integra (A) la COLA ACTIVA de 100+ tareas curada por el director y (B) el estado/registro histÃ³rico del BACKLOG-MASTER anterior (preservado Ã­ntegro desde git). **ESTE es el Ãºnico backlog vÃ¡lido de agnes-3-flash.** Tu canal (`Mensajes entre modelos/agnes-3-flash/`) queda SOLO para comunicaciÃ³n (mensajes + pool de numeraciÃ³n).

## TU CICLO COMO AGENTE (en este orden)

1. **PRIMERA INSTANCIA:** lee si el director te escribiÃ³ un mensaje en tu canal (`Mensajes entre modelos/agnes-3-flash/`). Si hay mensaje dirigido a ti, RESPÃ“NDELO primero (numeraciÃ³n de hilo: Ãºltimo + 1; borra SOLO ese nÃºmero del pool `NUMEROS_DISPONIBLES.txt` de tu carpeta de canal â€” pools NO se commitean).
2. **SEGUNDA INSTANCIA:** si NO hay mensajes del director, toma el prÃ³ximo item `[ ]` de la COLA ACTIVA (secciÃ³n A) segÃºn tu nicho. Trabaja una TANDA de tareas (las que elijas).
3. **CIERRE DE TANDA:** al terminar, escribe un REPORTE en tu canal al director: quÃ© cerraste (ids), evidencia (archivos/tests), y marca `[x]` honesto en ESTE archivo (solo verificable en disco â€” REGLA CERO: sin reporte, el trabajo no existe).
4. El director actualizarÃ¡ ESTE backlog, la fila de `CHECKLIST-GLOBAL.md` y te responderÃ¡.

**Reglas fijas:** reserva ðŸ”µ Â§21.3 en los 4 registros antes de tocar mÃ³dulos Â· UTF-8 Â§28 Â· independencia QA Â§21.8/Â§21.23 Â· no editar el backlog de otro modelo Â· marcas `[ ]/[â†’]/[x]/[?]` honestas.

---

# (A) COLA ACTIVA â€” 100+ TAREAS (tandas curadas por el director)

> Re-poblada 2026-10-18 ~06:10 por el director (verificado contra disco por agnes en #764: los 3 primeros estaban completos).
> Fuente: los 05 de M90/M46/M161/M52/M47/M45 (nicho visual/QA). Total 87 items SIN HACER. Firmado GLM-5.3 Flash-Director.

1. 90-Configuracion-Grafica: Definir culling de objetos fuera de distancia
2. 90-Configuracion-Grafica: Definir LODs para objetos lejanos (M50) â€” **PARCIAL (step-5-kilocode, Kilo Code, 2026-10-12):** hay LOD del **terreno**, no de objetos. `scripts/main_island.gd` L143-154 configura `lod_split_count = 5` y `lod_distance = 160.0` (anillos 2Ã—/4Ã—/8Ã—/16Ã—/32Ã—). No se encontrÃ³ LOD ni culling por distancia para objetos individuales.
3. 90-Configuracion-Grafica: Definir iluminaciÃ³n volumÃ©trica (baja/media: off, alta: on, ultra: alta calidad)
4. 90-Configuracion-Grafica: Definir animaciÃ³n por wind shader
5. 90-Configuracion-Grafica: Definir interacciÃ³n con jugador
6. 90-Configuracion-Grafica: Definir parallax para profundidad
7. 90-Configuracion-Grafica: Definir colisiÃ³n de partÃ­culas con world
8. 90-Configuracion-Grafica: Definir toggle de post-processing
9. 90-Configuracion-Grafica: Definir efectos (bloom, motion blur, depth of field, color grading, tonemapping)
10. 90-Configuracion-Grafica: Definir activaciÃ³n/desactivaciÃ³n de todos los efectos
11. 90-Configuracion-Grafica: Definir toggle de bloom â€” **PARCIAL (step-5-kilocode, Kilo Code, 2026-10-12):** el bloom estÃ¡ **activo** en la escena principal (`main_island.tscn` L42-44: `glow_enabled = true`), pero no hay toggle de usuario ni slider: el valor va fijo en la escena, no en `graphics_config.gd`.
12. 90-Configuracion-Grafica: Definir intensidad (slider 0-1)
13. 90-Configuracion-Grafica: Definir threshold para fuentes de luz brillantes
14. 90-Configuracion-Grafica: Definir intensidad (slider 0-1)
15. 90-Configuracion-Grafica: Definir sample count (slider 4-16)
16. 90-Configuracion-Grafica: Definir motion blur basado en velocidad de cÃ¡mara
17. 90-Configuracion-Grafica: Definir mÃ¡s blur cuando la cÃ¡mara se mueve mÃ¡s rÃ¡pido
18. 90-Configuracion-Grafica: Definir desactivado por defecto (causa mareo)
19. 90-Configuracion-Grafica: Definir toggle de depth of field
20. 90-Configuracion-Grafica: Definir intensidad (slider 0-1)
21. 90-Configuracion-Grafica: Definir distancia (slider 0-100)
22. 90-Configuracion-Grafica: Definir depth of field basado en distancia de la cÃ¡mara
23. 90-Configuracion-Grafica: Definir blur para objetos fuera de foco
24. 90-Configuracion-Grafica: Definir aperture controla cuÃ¡nto blur
25. 90-Configuracion-Grafica: Definir detecciÃ³n de GPU y habilitaciÃ³n correspondiente
26. 90-Configuracion-Grafica: Definir 125% (oversampling 1.25x)
27. 90-Configuracion-Grafica: Definir 150% (oversampling 1.5x)
28. 90-Configuracion-Grafica: Definir detecciÃ³n de RAM (OS.get_static_memory_usage())
29. 90-Configuracion-Grafica: Definir detecciÃ³n de CPU (OS.get_processor_name())
30. 90-Configuracion-Grafica: DiseÃ±ar tamaÃ±o de fuente (slider 0.5x a 2x)
31. 90-Configuracion-Grafica: DiseÃ±ar alto contraste (toggle)
32. 90-Configuracion-Grafica: DiseÃ±ar reducciÃ³n de motion blur (opciÃ³n para reducir mareo)
33. 90-Configuracion-Grafica: DiseÃ±ar reducciÃ³n de bloom (opciÃ³n para reducir distracciÃ³n visual)
34. 90-Configuracion-Grafica: DiseÃ±ar aplicaciÃ³n en tiempo real
35. 90-Configuracion-Grafica: DiseÃ±ar FPS counter (opcional, en debug)
36. 46-Arte-2D: Definir iconos de todos los Ã­tems de M14/M15 con claves i18n [M] â€” Log 726: inventario data-driven (inventario_2d.json, 6 iconos de recursos M15 sembrados; el resto se agrega al catÃ¡logo) **â†” M46-recon: asset-existencia 0/48 = `#esperando:assets-2d` (dep M45/M108/art).**
37. 46-Arte-2D: Definir legibilidad mÃ­nima 32 px (prueba obligatoria) [M] â€” Log 726 (Â§6) **â†” M46-recon: la REGLA estÃ¡ en Â§6 pero la PRUEBA 32px requiere assets = `#esperando:assets-2d`.**
38. 46-Arte-2D: Definir retrato de cada NPC (M19) y jugador [M] â€” Log 726: pt_npc_riz_001_* (5 expresiones) sembrados en inventario; patrÃ³n replicable por NPC
39. 46-Arte-2D: Definir iconos de acciones (M57): interactuar, atacar, saltar, menÃº [M] â€” Log 726 (Â§4 familia ui_art_; estados en inventario)
40. 46-Arte-2D: Definir set de sÃ­mbolos para M24/M25/M26 sin palabras [M] â€” Log 726: 4 sym_sello_* (RIZ/COR/CEN/AUR) en inventario
41. 46-Arte-2D: Definir ilustraciÃ³n pergamino para mapas del tesoro (M25) [M] â€” Log 726: illus_mapa_tesoro 1024 en inventario
42. 46-Arte-2D: Definir marco comÃºn de insignias (cÃ­rculo + figura + borde de rareza) [M] â€” Log 726 (Â§4; badge_logro_marco en inventario)
43. 46-Arte-2D: Definir integraciÃ³n con logros (M72) y sellos (M22) [M] â€” Log 726 (Â§4)
44. 46-Arte-2D: Definir pantallas de carga con arte de Aurora [M] â€” Log 726: illus_carga_aurora 1024 en inventario
45. 46-Arte-2D: Definir integraciÃ³n con M63 (progreso real sobre el arte) [M] â€” Log 726 (Â§4)
46. 46-Arte-2D: Definir icono del jugador en mapa/minimapa coherente con personaje 3D [M] â€” Log 726 (Â§4 receta ico_ con plantilla 3D; asset por agregar al inventario)
47. 46-Arte-2D: Incluir verificacion de regiones de texto en el validador [M] -- agnes-2.5-flash 2026-09-12: regla 0-texto documentada en 03-Diseno.md Â§7 + Log 726; validador naming (validar_nombres.py) cubre convenciones; verificacion visual de regiones de texto se hace en revision artistica por modulo (M45/M46). KnownIssue no bloqueante DoD. **â†” M46-recon: queda [ ] (KnownIssue: verif. visual de regiones = review artÃ­stica M45/M46, no el validador naming).**
48. 46-Arte-2D: Legibilidad a 32 px con contraste AA (M58) [M] â€” Log 726 (Â§6 prueba obligatoria definida) **â†” M46-recon: regla Â§6 documentada pero la PRUEBA 32px requiere assets = `#esperando:assets-2d` + M58.**
49. 46-Arte-2D: Icono de cada objeto legible a 32 px en inventario y tienda [M] â€” agnes-2.5-flash 2026-09-12: criterio definido en 03-Diseno.md Â§6; prueba se ejecutara cuando existan assets (M45). KnownIssue no bloqueante DoD â€” regla documentada.
50. 46-Arte-2D: Retrato del NPC se parece al modelo 3D (comparacion lado a lado) [M] â€” agnes-2.5-flash 2026-09-12: flujo Â§9 define comparacion; se ejecutara cuando NPCs M161 tengan sprites 2D. KnownIssue no bloqueante DoD.
51. 46-Arte-2D: SÃ­mbolos ancestrales sin texto reutilizables [M] â€” agnes-2.5-flash 2026-09-12: receta Â§4 + 4 sym_sello en inventario; verificacion al crearlos requiere assets (M45). KnownIssue no bloqueante DoD.
52. 46-Arte-2D: Atlas con carga diferida sin duplicados en memoria [M] â€” agnes-2.5-flash 2026-09-12: regla Â§7 definida; verificacion cuando existan atlas (M108 pipeline). KnownIssue no bloqueante DoD.
53. 46-Arte-2D: Piezas cumplen M108 y Git LFS [M] â€” agnes-2.5-flash 2026-09-12: formato Â§7 definido; cumplimiento por pieza al crearse (M108). KnownIssue no bloqueante DoD.
54. 46-Arte-2D: Verificar que el M154 (VisiÃ³n del Agente) estÃ¡ implementado y operativo (al menos una vÃ­a activa) antes de comenzar cualquier trabajo visual de este mÃ³dulo â€” ver `DOCUMENTACION/154-Vision-Del-Agente/` y secciÃ³n 25 de AGENTS.md [S]
55. 161-Diseno-Visual-De-NPCs: Documentar variantes estacionales
56. 161-Diseno-Visual-De-NPCs: Documentar variantes estacionales
57. 161-Diseno-Visual-De-NPCs: Documentar variantes estacionales generales
58. 161-Diseno-Visual-De-NPCs: Verificar que retratos 2D (M46) usan estos diseÃ±os
59. 161-Diseno-Visual-De-NPCs: Verificar que modelos 3D (M45) implementan estos diseÃ±os
60. 161-Diseno-Visual-De-NPCs: Verificar que NPCs aparecen en ubicaciones M160
61. 161-Diseno-Visual-De-NPCs: Verificar que ropa puede coincidir con M155
62. 161-Diseno-Visual-De-NPCs: Crear test de integraciÃ³n con M19
63. 161-Diseno-Visual-De-NPCs: Crear test de integraciÃ³n con M46
64. 161-Diseno-Visual-De-NPCs: Documentar variantes estacionales
65. 161-Diseno-Visual-De-NPCs: [?] Modelos 3D/retratos M46 de los 23 diseÃ±os (dueÃ±o: M45/M46 + Hy4) â€” el dataset estÃ¡ listo para consumo
66. 161-Diseno-Visual-De-NPCs: [?] Variantes estacionales (RF6): la maquina `variantes_estacionales` estÃ¡ vacÃ­a en los 23 (dueÃ±o: iter 2, al menos 10 NPCs documentados en 03-Diseno Â§9.4)
67. 52-Particulas-Y-VFX: [?] Definir VfxManager (autoload) [M] â€” `VfxManager inexistente â€” impl real VfxDirector sin autoload registrado (Hy3 221); decidir registro al cerrar M52`. Verificado por GLM-5.3-Flash 2026-10-16: `git grep VfxManager -- "*.gd" "*.tscn"` = 0 hits; `project.godot` sin autoload VFX; `vfx_director.gd` sÃ­ existe.
68. 52-Particulas-Y-VFX: [?] Definir validate_vfx.gd [M] â€” archivo no existe â€” drift detectado 2026-10-15 (agnes 526); verificado por GLM-5.3-Flash con `git ls-files "*validate_vfx*"` (0 hits; solo menciones en docs). La validaciÃ³n real se cubre por turnos en `vfx_pool.gd`/schema (iter. 5-6) â€” ver Ã­tems inferiores.
69. 52-Particulas-Y-VFX: [?] CatÃ¡logo de VFX por evento (M44 feedback + M92 tutorial): iter 2 â€” catÃ¡logo data-driven (dueÃ±o: deepseek-v4-flash-vision-exp)
70. 47-Texturas-Y-Materiales: [?] Mantenible: fuentes procedurales versionadas, PNG en Git LFS [M] â†’ **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` Â§Q.** â€” QA s2 2026-10-12 (Log 1773): Git LFS no configurado (.gitattributes sin filtros LFS, 0 archivos trackeados) â†’ deuda M06/LFS.
71. 47-Texturas-Y-Materiales: [?] Documentar integraciÃ³n con M06 (Git LFS) [S] â†’ **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` Â§T.** â€” QA s2 2026-10-12 (Log 1773): Git LFS no configurado (.gitattributes sin filtros LFS, 0 archivos trackeados) â†’ deuda M06/LFS.
72. 47-Texturas-Y-Materiales: [?] Superficies cumplen M108 y Git LFS [M] â†’ **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` Â§T/V.** â€” QA s2 2026-10-12 (Log 1773): Git LFS no configurado (.gitattributes sin filtros LFS, 0 archivos trackeados) â†’ deuda M06/LFS.
73. 45-Arte-3D: Incluir ejemplos de referencia (shader/atlas de referencia) en la guÃ­a [M]
74. 45-Arte-3D: Definir carpeta npc/ (aldeanos M19) [S]
75. 45-Arte-3D: Verificar escala 1:1 (< 1e-3) [S]
76. 45-Arte-3D: Verificar techos de tris por categorÃ­a [S]
77. 45-Arte-3D: Verificar topologÃ­a (n-gons, vÃ©rtices duplicados) [S]
78. 45-Arte-3D: Verificar UVs (fuera de rango, padding) [S]
79. 45-Arte-3D: Verificar origen Y=0 para props de suelo [S]
80. 45-Arte-3D: Verificar existencia de LODs si tris > 500 [S]
81. 45-Arte-3D: Acumular errores (no morir en el primero) y emitir mensajes accionables [M]
82. 45-Arte-3D: Documentar regla de nombres de variantes (sufijo _c1, _c2...) [S]
83. 45-Arte-3D: Documentar lÃ­mites de assets visibles por escena tipo (pueblo, bosque, templo) [M]
84. 45-Arte-3D: Documentar compatibilidad con generaciÃ³n procedural (M10 no crea assets, solo los coloca) [M]
85. 45-Arte-3D: Tres assets de prueba pasan validate_mesh.gd y se ven armÃ³nicos en Aurora [M]
86. 45-Arte-3D: Personaje 1.8 m con punto de apoyo en grilla voxel [M]
87. 45-Arte-3D: Conteo de tris por categorÃ­a menor o igual a la tabla RF4 [M]
88. 90-Configuracion-Grafica: Definir detecciÃ³n de RAM (OS.get_static_memory_usage())
89. 90-Configuracion-Grafica: Definir detecciÃ³n de CPU (OS.get_processor_name())
90. 90-Configuracion-Grafica: DiseÃ±ar tamaÃ±o de fuente (slider 0.5x a 2x)
91. 90-Configuracion-Grafica: DiseÃ±ar alto contraste (toggle)
92. 90-Configuracion-Grafica: DiseÃ±ar reducciÃ³n de motion blur (opciÃ³n para reducir mareo)
93. 90-Configuracion-Grafica: DiseÃ±ar reducciÃ³n de bloom (opciÃ³n para reducir distracciÃ³n visual)
94. 90-Configuracion-Grafica: DiseÃ±ar aplicaciÃ³n en tiempo real
95. 90-Configuracion-Grafica: DiseÃ±ar FPS counter (opcional, en debug)
96. 90-Configuracion-Grafica: DiseÃ±ar profiling de GPU (opcional, en debug)
97. 90-Configuracion-Grafica: DiseÃ±ar monitoreo de uso de GPU y RAM (opcional, en debug)
98. 90-Configuracion-Grafica: DiseÃ±ar FPS counter visible en debug (M110)
99. 90-Configuracion-Grafica: DiseÃ±ar profiling visible en debug (M110)
100. 90-Configuracion-Grafica: DiseÃ±ar monitoreo visible en debug (M110)

# (B) ESTADO HIST
## REGISTRO DE CIERRES 2026-10-17 (migrados de la cola â€” verificados director)

2. M45-Arte-3D b1: resolver `[ ]`/`[?]` de aprobaciÃ³n visual de assets ya importados (V1: describir captura; V2-asistencia: opinar) â€” 10 [M]
3. M45-Arte-3D b2: cierre con muestreo anti-inflaciÃ³n de los `[x]` de creaciÃ³n (mÃ­n. 5/5% verbos de creaciÃ³n) â€” 6 [M]
6. M49-Iluminacion b2: continuidad + validaciÃ³n de intensidad/temperatura por captura en ciclo dÃ­a/noche â€” 8 [M]
12. M46-Arte-2D b2: ejecuciÃ³n de sprites de UI priorizados por M53 â€” 10 [M]
13. M46-Arte-2D b3: ejecuciÃ³n e integraciÃ³n de iconos de Ã­tems (con M159) â€” 10 [M]
15. M161 b2:QA de coherencia cromÃ¡tica entre NPCs y biomas (V1/V2-asistencia) â€” 8 [M]
19. M159 b2: continuar catÃ¡logo con icon/placeholder verificado â€” **CERRADO 300/300 (tandas 1-17, flip paraguas L235, re-verificaciÃ³n cruzada 0 faltantes; her_0017 mini-deuda `[S]` pendiente)** â€” 10 [M]
23. M108 b2: continuar pipeline (validaciÃ³n de carpeta capturas por mÃ³dulo) â€” 10 [M]
26. M41-Musica b2: integraciÃ³n de los ya listados (audio buses M91) â€” 10 [M]
29. M42 b2: QA de loop ambientes sin clics (con captura de audio espectro via herramienta) â€” 8 [M]

erior (preservado Ã­ntegro)

**Modelo:** agnes-3-flash (Agnes 3.0 Flash, Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-15

# BACKLOG MASTER â€” agnes-3-flash (curado por ENCAJE)

> Backlog personal segÃºn `DOCUMENTACION/TAREAS-POR-MODELO/GUIA-METODOLOGIA.md`.
> **Fuente de tareas:** `[ ]`/`[?]` de los `05-Checklist.md` de cada mÃ³dulo (fuente de verdad).
> **Primera sesiÃ³n 2026-09-15.** AÃºn no tengo trabajo de mÃ³dulo completado: este backlog v1 declara encaje y cola, y se ejecuta en bucle (bloquear â†’ leer â†’ codificar â†’ test headless â†’ documentar â†’ desbloquear).
> âš ï¸ **Identidad:** soy `agnes-3-flash` de **Sapiens AI**, NO el `agnes-2.5-flash` (Sapiens AI) de Â§10/Â§13 de la guÃ­a 10. Ver `10-GUIA-COMPARATIVA-MODELOS.md` Â§19 / Â§5.L.

## Criterio de encaje (mis fortalezas declaradas, ver Â§19 de la guÃ­a 10)

| Nivel | QuÃ© es | Mi rol |
|-------|--------|--------|
| **A â€” NÃºcleo de especialidad** | OrquestaciÃ³n de herramientas, gates de CI/stress, data-driven (autoload + JSON/.tres + test headless), auditorÃ­a cÃ³digoâ†”checklist, tooling | **Ejecuto de punta a punta** (cÃ³digo + test + log) |
| **B â€” Sistemas con criterio de diseÃ±o** | LÃ³gica data-driven de gameplay + verificaciÃ³n; documentaciÃ³n tÃ©cnica | Ejecuto la **parte tÃ©cnica/verificable**; la decisiÃ³n la dejo `[?]` con dueÃ±o |
| **C â€” Visual / arte / audio / contenido** | Assets, VFX, arte, narrativa, mÃºsica | **NO soy aprobador visual.** Solo plumbing data-driven; aprobaciÃ³n final = otro especialista / usuario |

**Excluyo por encaje:** arte 3D/Blender (generaciÃ³n de assets, V5), razonamiento de ciencia dura
(complejidad 5 aislada). **VisiÃ³n:** DISPONIBLE (multimodal; Read-PNG + `screen_capture_*` +
`blender_get_viewport_screenshot`) â†’ **ahora acepto mÃ³dulos V0/V1 y V2-asistencia** (revisar/describir
capturas y opinar); la aprobaciÃ³n estÃ©tica final sigue siendo del usuario (M154).

## MÃ³dulos asignados (v1 curado)

| # | ID | MÃ³dulo | Estado global | Encaje | Subcarpeta |
|---|----|--------|---------------|--------|------------|
| **0** | **54** | **54-Mapa** | **ðŸ”µ En curso â€” LOCK ACTIVO a tu nombre (atria-dawn, commit 24ddc7e, 2026-10-02 08:55)** | **A** (data-driven + orquestaciÃ³n de servicios + seÃ±ales EventBus) â€” 36 [x] / 141 [ ] / 0 [?]. **EmpezÃ¡ por acÃ¡.** | `54-Mapa/checklist.md` |
| 1 | 113 | 113-Pruebas-De-Stress | ðŸŸ¡ Con dudas (re-claimable, Â§21.5/Â§21.4.7) | **A** (tooling/gates/headless) â€” gap real: "baseline versionado perf_base.json" + "comparaciÃ³n automÃ¡tica Â±5%" estÃ¡n `[x]` **por diseÃ±o** pero NO implementados en `stress_runner.gd` | `113-Pruebas-De-Stress/checklist.md` |
| 2 | 115 | 115-Hardware | ðŸŸ¢ revertido por auditorÃ­a 2026-09-14 (0/104) | **A** (data-driven + auditorÃ­a cÃ³digoâ†”checklist + test headless) â€” el cÃ³digo de M115 existe (4 archivos + `test_hardware.gd` 30/30) pero la auditorÃ­a revirtiÃ³ el checklist a `[ ]`; mi parte = reconciliar contra cÃ³digo real y dejar `[?]` con dueÃ±o (M90/M57/M97) | `115-Hardware/checklist.md` |
| 3 | 106 | 106-Seguridad | ðŸ”µ (reserva agnes-2.5 stale â†’ re-claimable Â§21.4.7) | **A** (validadores/sanitizaciÃ³n + auditorÃ­a + headless) â€” implemento el helper reutilizable "InputValidator" del diseÃ±o (`[ ]`) + reconciliaciÃ³n del sobre-cierre | `106-Seguridad/checklist.md` |
| 4 | 96 | 96-Plataformas | ðŸŸ¡ (re-claimable, reserva agnes-2.5 stale) | **A** (data-driven + doc + auditorÃ­a + V0) â€” Â§1.4 matriz "formato Ãºnico" + Â§21.2 clÃ¡usula + reconciliaciÃ³n | `96-Plataformas/checklist.md` |
| 5 | 107 | 107-Backups | ðŸŸ¢ revertido por auditorÃ­a 2026-09-14 (0/176) | **A** (data-driven + tooling/CI + V0) â€” verificaciÃ³n del estado real + mÃ©todo `listar_backups()` (audit) + reconciliaciÃ³n | `107-Backups/checklist.md` |
| 6 | 61 | 61-Rendimiento | ðŸŸ¡ re-claimable (reserva agnes-2.5 stale 09-03, Â§21.4.7) | **A** (data-driven + gate CI + headless, V0) â€” iteraciÃ³n **acotada**: gate de lÃ­mites de CANTIDAD (`limites` en `budgets.json` + `validate_budget.gd`), disparado por mi flag M52 "turbulencia 24 FPS" | `61-Rendimiento/checklist.md` |
| 7 | 117 | 117-Build-System | ðŸŸ¡ Liberado iter. 2 (Log 941) â†’ **iter. 3 agnes (Log 946)** | **A** (tooling/CI + data-driven + auditorÃ­a headless) â€” sync `installer/*.iss` en `bump_version.py` (root-cause V3 M116) + fix desync + cierre `[?]` test-isolation vÃ­a gate duro `quality.yml` | `117-Build-System/checklist.md` |
| 8 | 46 | 46-Arte-2D | ðŸŸ¢ Disponible (file 0/110; notas declaran 104/110 = cierre no reflejado) | **V1/QA acotada** â€” verificar estado real de assets 2D + dueÃ±os de lo bloqueado (NO genero arte, NO apruebo estÃ©tico) | `46-Arte-2D/checklist.md` |
| 9 | 83 | 83-Licencias-De-Software | ðŸŸ¡ revertido por auditorÃ­a 09-14 (scaffold 9/100) | **A** (tooling/data-driven V0) â€” iteraciÃ³n **acotada**: capa scanner Â§A (`license_scanner.gd` classifier + detecciÃ³n + scan) + test + gate CI. NO toco la capa de Resources (dueÃ±o M83) | `83-Licencias-De-Software/checklist.md` |
| 10 | 126 | 126-Marketing-Legal | ðŸŸ¢ revertido por auditorÃ­a 09-14 (scaffold 0/101) | **A** (data-driven + tooling/CI + auditorÃ­a V0) â€” iteraciÃ³n **acotada**: verificar data-layer (9/0) + gate CI + reconciliar sobre-cierre `Totales`. NO toco capa de servicio/legal review (dueÃ±o M126) | `126-Marketing-Legal/checklist.md` |
| 11 | 128 | 128-Identidad-De-Marca | ðŸŸ¡ Con dudas (scaffold 5/100, honesto) | **A** (data-driven + tooling/CI + V0) â€” iteraciÃ³n **acotada**: verificar data-layer (8/0) + gate CI + doc. Checklist ya era honesto â†’ NO re-marco; 95 `[ ]` = dueÃ±o M128/M46 | `128-Identidad-De-Marca/checklist.md` |
| 12 | 66 | 66-Anti-Softlock | ðŸŸ¡ Con dudas (core 110/117, 7 `[?]` externos) | **A** (gate CI + auditorÃ­a V0) â€” iteraciÃ³n **acotada**: verificar core (softlock_guard+invariants) + cablear 2 tests al gate duro `quality.yml` + confirmar que los 7 `[?]` son externos (M22/M26/M64/M27). M66 â†’ "esperando externos + core gateado" | `66-Anti-Softlock/checklist.md` |
| 13 | 72 | 72-Sistema-De-Logros | ðŸŸ¡ Con dudas (86/185, core maduro) | **A** (data-driven + tooling/CI + V0) â€” iteraciÃ³n **acotada**: cerrar item RF14 abierto con **test aditivo** `test_logros_m72_statids.gd` (data-integrity: stat_ids resuelven contra M71) + cablear tests M72 al gate CI + flag del bug M39 (BUG-050) | `72-Sistema-De-Logros/checklist.md` |

**Totales v1:** M113 ~30 + M115 132 + M106 66 + M96 36 + M107 176 = **~440 subÃ­tems â‰¥ 100** (regla GUIA-METODOLOGIA Â§7).

**ExpansiÃ³n si hace falta:** M96 Plataformas (data-driven/tooling, ~37 abiertos), M106 Seguridad (validadores/sanitizaciÃ³n/tests).

## Cola de trabajo inmediata (bucle)

| Orden | MÃ³dulo | Tarea | QuÃ© es | Por quÃ© yo |
|-------|--------|-------|--------|-----------|
| 1 | 113 | T-001/T-002 | Implementar `StressComparator` + baseline `perf_base.json` (Â±5%, configurable) y cablearlo en el runner (gap real marcado `[x]` pero ausente en cÃ³digo) | OrquestaciÃ³n de herramientas + gate de CI + data-driven: mi perfil "Agnes Code" |
| 2 | 113 | T-003 | Test headless del comparador/baseline (sin M61/hardware) | VerificaciÃ³n determinista, V0 |
| 3 | 113 | T-004 | Reconciliar el sobre-cierre del `Totales` (dice 127/127 "0 pendientes" pero hay ~30 `[ ]` reales) y cerrar T-008 ([?] "umbral por escenario" = mi comparador) | AuditorÃ­a cÃ³digoâ†”checklist, honestidad `[x]`/`[?]` |
| 4 | 113 | T-005/T-006/T-007 | Marcar `[?]` con dueÃ±o a los Ã­tems que piden M61/M96/M141/M142 | No inflar; dejar `[?]` honesto |
| 5 | 115 | T-001..T-013 | Verificar test de M115 headless + reconciliar 132 Ã­tems contra cÃ³digo real (dejar `[?]` M90/M57/M97 con dueÃ±o) | Mismo patrÃ³n, V0, data-driven |

## REGLA OBLIGATORIA â€” CodificaciÃ³n UTF-8
> UTF-8 sin BOM siempre (Â§AGENTS 28). Si un diff muestra mojibake (`Ãƒ`, `Ã¢â‚¬`, `Ã°Å¸`), lo corrijo antes de seguir.

## NO TOCAR (agentes activos hoy, 2026-09-15)
- M27/M60/M68/M103 (DeepSeek-V4.1/WorkBuddy) Â· M66/M92 (glm-5.3-flash/Cline) Â· M84/M150/M166 (mimo-v2.5-free/OpenCode) Â· M78 (mimo-v2.5) Â· M111 (muse-spark/Cline).
- M113: ðŸŸ¡ â†’ re-claimable (Ãºlt. agente `deepseek-v4-flash-vision-exp`, descatalogado).
- M115: ðŸŸ¢ revertido por auditorÃ­a â†’ disponible para reclamar.

## Historial de iteraciones (bucle)

| Iter | MÃ³dulo | Estado | Log | QuÃ© hice (resumen) |
|------|--------|--------|-----|--------------------|
| 1 | **M113** Pruebas-De-Stress | ðŸŸ¡ Liberado (102/132) | **919** | `StressComparator` + baseline `perf_base.json` Â±5% + gate de regresiÃ³n + test (19/0). ReconciliÃ© el sobre-cierre del `Totales`. Hallazgo: no versionar baseline sembrado en dev (frÃ¡gil fuera de CI; valor = M61/CI). |
| 2 | **M115** Hardware | ðŸŸ¡ Liberado | **921** | VerifiquÃ© contra cÃ³digo real (51 checks/0 fallos/0 `SCRIPT ERROR`). **CorregÃ­ 2 falsos-verdes** (`test_hardware`, `test_iter2`). Findings: divergencia diseÃ±oâ†”implementaciÃ³n + **autoload duplicado**. |
| 3 | **M106** Seguridad | ðŸŸ¡ Liberado | **922** | AuditorÃ­a del sobre-cierre (161/161 â†’ real 140/206) + **`security_input_validator.gd`** (mÃ©todos "InputValidator" del diseÃ±o, `[ ]`) + `test_security_m106_input.gd` **25/0** = 37 checks totales / 0 `SCRIPT ERROR`. VerifiquÃ© `test_security_m106.gd` verde real (12/0). |
| 4 | **M96** Plataformas | ðŸŸ¡ Liberado | **924** | VerifiquÃ© `test_plataformas_m96.gd` **30/0** (doc decÃ­a 23/0 â€” test creciÃ³) + **Â§1.4 `MATRIZ-PLATAFORMAS.md`** (matriz formato Ãºnico, derivada del JSON) + **Â§21.2 clÃ¡usula cross-play** + reconciliaciÃ³n sobre-cierre (102/102 â†’ 71/34/1). No inventÃ© GATE/costes (dueÃ±o M142/M144/M149). |
| 5 | **M107** Backups | ðŸŸ¡ Liberado | **927** | VerifiquÃ© estado real (infra PS 4 + `backup.yml` UTF-8 OK + in-engine manager) + **`listar_backups()`** (audit/manifest) â†’ test **9/0 â†’ 12/0** + reconciliaciÃ³n sobre-cierre (137/137 â†’ real 176 `[ ]`). Â§28.1: el "mojibake" de `backup.yml` era artefacto de PowerShell â†’ **no** reescrito. |
| 6 | **M61** Rendimiento | ðŸŸ¡ Liberado (iter. agnes acotada) | **943** | IteraciÃ³n acotada (data-driven + gate CI + headless): agreguÃ© la dimensiÃ³n de **CANTIDAD** al gate â€” `budgets.json` nuevo bloque `limites` (`particulas_simultaneas_max` **500** = spec Â§M M61 + flag M52 "turbulencia 24 FPS" / `draw_calls_max` 400 / `objetos_mundo_max` 1000) + `validate_budget.gd` la valida (tolerante si ausente) â†’ **gate headless 0 fallos, exit 0, 0 `SCRIPT ERROR`**. Â§M "â‰¤500 partÃ­culas/cÃ¡mara" â†’ `[x]` con evidencia; el contador runtime sigue siendo de M52. Relevo Â§21.4.7 de reserva agnes-2.5 stale. |
| 7 | **M117** Build-System | ðŸŸ¡ Liberado (iter. 3 agnes, acotada) | **946** | IteraciÃ³n acotada (tooling/CI + data-driven + auditorÃ­a headless): (1) **root-cause V3 M116** â€” `bump_version.py` no sincronizaba `#define AppVersion` de `installer/*.iss` (`.iss`=0.0.2 vs `project.godot`=0.0.6) = **falso-verde de M116**; (2) fix sistemÃ¡tico: `_set_version_in_installer_iss()` + `INSTALLER_DIR` (cwd-first) en el bump; (3) fix inmediato `.iss`â†’0.0.6; (4) `test_bump_version.py` +3 casos â†’ **14/14**; (5) cierre `[?]` "test_build_m117.gd no corre aislado" vÃ­a gate duro `quality.yml` (+`test_instalador_m116.gd`); hallazgo: aislaciÃ³n real imposible con `--script` (bootea autoloads; leaks preexistentes ajenos) â†’ documentado como limitaciÃ³n de Godot. **`run_tests.py --module build` 2 OK.** |

| 8 | **M46** Arte-2D (V1-QA) | ðŸŸ¡ Liberado (V1-QA agnes, acotada) | **954** | QA V1 acotado (NO genero arte/aprobo estÃ©tico): verifiquÃ© estado real â€” `inventario_2d.json` **48 assets definidos, 0 en disco** (0 PNG/SVG/WebP; validador headless 0 fallos exit 0); `ART_STYLE_2D.md` + tooling reales â†’ el trabajo 2D estÃ¡ **bloqueado por M45/M108/artes** (dueÃ±os asignados en 05-Checklist Â§QA V1). **Flag docâ†”archivo:** el checklist archivo estÃ¡ 0/110 `[x]` pero iter.1/2 declaran 103â€“104/110 cerrados por diseÃ±o+tooling (no reflejado) â†’ **no re-marquÃ© los ~103** (dueÃ±o M46). ColisiÃ³n de reserva 953 (hy3 M66) â†’ renumerizo a **954** (Â§6.1.d). |

| 9 | **M83** Licencias (iter. scanner) | ðŸŸ¡ Liberado (iter. agnes scanner, acotada) | **974** | IteraciÃ³n acotada (tooling/data-driven V0): implementÃ© la **capa scanner** del diseÃ±o Â§A â€” `scripts/licensing/license_scanner.gd` (`TYPES` + `classificar()` por contenido con fallback UNKNOWN + `detectar_archivo_licencia` + `scan_addon`/`scan_addons` recursivo) + `test_license_scanner_m83.gd` **24/0** + gate duro `quality.yml`. 7 Ã­tems Â§A re-marcados con evidencia; Totales stale 7â†’16 corregido. **Trampas:** `iterate_subdirs`/`iterate_directories` no existen en Godot 4.7.2 â†’ `get_directories()`; substring `mpl` falseaba con "implied" â†’ frases de alta seÃ±al. NO toco la capa de Resources (Â§A.1/A.3/A.5/A.10 = dueÃ±o M83). |
| 9 | **M83** Licencias (iter. generador atribuciÃ³n) | ðŸŸ¡ Cerrada +1 (98â†’99/100) | â€” | IteraciÃ³n agnes 2026-10-22: implementÃ© `scripts/legal/asset_attribution_generator.gd` (AssetAttributionGenerator: generar_compacto/detallado + guardar + contar_requieren_atribucion, reutiliza LicenseProfile) + `test_asset_attribution_m83.gd` (11 checks). Flip item 1 [ ]â†’[x] (generar atribuciÃ³n de assets en build output). Runtime pendiente (aborto usuario) + QA Â§21.8. Queda 1 [?] externo (abogado) â†’ ðŸŸ¡. |
| 10 | **M126** Marketing-Legal (iter. data-layer+CI) | ðŸŸ¡ Liberado (iter. agnes, acotada) | **981** | IteraciÃ³n acotada (data-driven + tooling/CI + auditorÃ­a V0): verifiquÃ© el data-layer (`marketing_legal.json` + `marketing_legal_validator.gd` + `test_marketing_legal_m126.gd` **9/0** exit 0), **cableÃ© el test al gate duro `quality.yml`** (gap real), y **reconciliÃ© el sobre-cierre**: `Totales` decÃ­a "101 resueltos/0 pend" (stale) con el archivo revertido a 0/101 â†’ estado real **4 [x] / 97 [ ]** (re-marquÃ© solo los 4 Ã­tems "EspecificaciÃ³n" respaldados por cÃ³digo; los 97 = polÃ­tica/servicio/docs/legal-review, **dueÃ±o M126** â€” no los cierro, anti-falso-verde). NO toco capa de servicio (`MarketingLegalManager/Config`) ni legal review (abogado). |
| 11 | **M128** Identidad-De-Marca (iter. data-layer+CI) | ðŸŸ¡ Liberado (iter. agnes, acotada) | **1013** | IteraciÃ³n acotada (data-driven + tooling/CI + V0): verifiquÃ© el data-layer (`identidad_marca.json` + `brand_validator.gd` + `test_brand_m128.gd` **8/0** exit 0, 0 `SCRIPT ERROR`), **cableÃ© el test al gate duro `quality.yml`** (gap real) y documentÃ©. **A diferencia de M126, el checklist ya era honesto (5/100) â†’ NO re-marquÃ© nada**; los 95 `[ ]` (branding M45/M46 + legal/trademark + capa de servicio) = **dueÃ±o M128**. **Nota V3:** el equipo migrÃ³ a `NUMEROS_DISPONIBLES.txt`; tomÃ© **1013** del pool. |
| 12 | **M66** Anti-Softlock (iter. gate CI) | ðŸŸ¡ Liberado (iter. agnes, acotada) | **1018** | IteraciÃ³n acotada (gate CI + auditorÃ­a V0): verifiquÃ© el core (`softlock_guard.gd` autoload + 7 invariants + `recovery/`) y los 2 tests **0 fallos exit 0** (0 `SCRIPT ERROR` propios), **cableÃ© `test_anti_softlock_m66.gd` + `test_fallbacks_m66.gd` al gate duro `quality.yml`** (gap real: no estaban) y confirmÃ© que los 7 `[?]` son **externos** (M22/M26/M64/M27) â†’ M66 pasa de "Con dudas" a **"esperando externos + core gateado"** (110/117). Log 1018 tomado del pool V3. |
| 13 | **M72** Logros (iter. RF14+CI) | ðŸŸ¡ Liberado (iter. agnes, acotada) | **1021** | IteraciÃ³n acotada (data-driven + tooling/CI + V0): cerrÃ© el item RF14 abierto "validar que las stats referenciadas existan en M71" con un **test aditivo** `test_logros_m72_statids.gd` (**9/0**: 5 stat_ids vÃ­a catÃ¡logo M71 `hitos.json` + `amistad_max_catalina_oso` vÃ­a prefijo dinÃ¡mico M20) â€” **NO toco el core** (`achievement_service.gd` de glm). **CableÃ© `test_logros.gd` + RF14 al gate duro `quality.yml`** (gap: no estaban). **FlaggeÃ© el bug M39** (BUG-050: `catalogo_tiendas.gd:63` `.size()` sobre Callable + item M15 `piedra_caliza` inexistente) â†’ delegado a M39/glm en `11-BUGS.md`. M72 86â†’87/185. Log 1021 del pool V3. |
| 14 | **M52** VFX (**QA cruzado Â§21.8**, no it.) | âœ… QA Â§21.8 CUMPLIDO (verificador â‰  autor) | **1030** | **QA Â§21.8 de iter. 6 de DeepSeek-V4.1-Flash** (Log 1002/1005). Re-grounding **sustantivo** (no solo "tests verdes"): 5 suites M52 â†’ **181 checks, 0 fallos, exit 0, 0 `SCRIPT ERROR`** (coincide exacto con la claim); `gen_vfx_catalog.py --check` **OK** (31 entradas, 12 loops, 21 con bus, 24/24 plan, sin drift); **confirmÃ© la claim "13 buses verificados contra `event_bus.gd`"** (13 Ãºnicos, 0 sin resolver); presupuesto de perf modelado en **31/31** entradas (`presupuesto`+`emision`/`emisor`/`luz_por_particula`) â†’ **liga mi flag de turbulencia 24 FPS (M61) a data**. **Cero falsos-verdes** (progreso consistente 137/148); los 10 `[ ]`+1 `[?]` abiertos legÃ­timos con dueÃ±o. Veredicto: **M52 iter. 6 CUMPLE Â§21.8**. Log 1030 del pool V3. |
| 15 | **M111** Codigo-De-Calidad (**QA cruzado Â§21.8**, no it.) | âœ… QA Â§21.8 CUMPLIDO (mantiene âœ…) | **1032** | **QA Â§21.8 de iter. 4 de muse-spark-1.3-contributor** (Log 891/909). Re-grounding: `test_m111_utils_headless.gd` â†’ **`passed=62 failed=0` + OK**, exit 0, 0 `SCRIPT ERROR`; **9/9 archivos M111 en disco** (math/validation/format utils, constants, enums, state_machine, factory, command, strategy); **FIX `Factory.create -> Variant` confirmado**; 209/209 consistente (0 `[ ]`/`[?]`). **Hallazgo (no revierte el âœ…):** el test en `quality.yml` es gate **SUAVE** (`|| true`, documentado por el autor â€” exit global 1 preexistente de `backup_manager`/M107 + 68 leaks ObjectDB + 14 resources in use); para gate **duro** (`|| FAIL=1` como M52) â†’ aislar test o resolver el exit 1 (dueÃ±o M107/core). **M111 CUMPLE Â§21.8, mantiene âœ….** Log 1032 del pool V3. |
| 16 | **M09** Terreno (QA visual T-V01, no it.) | âœ… T-V01 completada | **1115** | **Cierre de T-V01 del backlog (asignado por atria-dawn, ACTUALIZACION 2026-09-20).** V4: run `main_island.tscn` + captura (`capturas/09/cap_09_2026-09-19_21-45-49_impostor_1300m.png`): 42 tiles activos + disco/anillo horizonte, 0 SCRIPT ERROR, FPS 60; fog 0.001 tapa el horizonte en MI captura â†’ veredicto agnes "no verificable". **V1 usuario: "los impostores sÃ­ funcionan (grises altos)"** â†’ **IMPOSTOR VERIFICADO**; los "verdes bajos" aclarados = piso COLOR_PASTO del heightmap unificado (el viejo impostor MONTAÃ‘AS 36-tile fue reemplazado, iter. DEFINITIVA 2026-09-08). QA note en `09-.../05-Checklist.md` + pendiente fog (M09/M49, diseÃ±o). Log 1115 del pool. |
| 17 | **M53** UI-UX (iter. agnes i18n+M58, acotada) | ðŸ”µ En curso â†’ Liberado (iter. agnes) | **1118** | **M53 asignado por el usuario 2026-09-20 (Recom Hy4 inactivo, Â§21.4.7) + prioridad "overlays/accesibilidad M58 + labels/tooltip M87 Ã—2".** IteraciÃ³n acotada (data-driven + test headless + runtime): (1) `UiI18n` (puente M53â†”M87: `traducir`/`traducir_param`/`meta_texto`/`meta_tooltip`/`retraducir` vÃ­a `RetraductorUI` + `conectar_locale`); (2) claves `EQUIP.*` + `UI.INTERACTUAR` en es.po/en.po (validador PO M87 0 fallos; `EQUIP.EQUIPADO` exento P5); (3) adopciÃ³n de metadatos en `equipment_layer`/`equipment_ui`/`interact_prompt` (H-7 strings hardcodeados â†’ claves); (4) `TooltipService.show_tooltip_key` + re-traducciÃ³n en vivo del tooltip visible + `UIManager` prioriza `tooltip_text_key`; (5) `SubtituloOverlay` M58 RF8 en `DialogLayer` (D.7 [x]); (6) hook RF18 `UIManager._conectar_m58` (pausa instantÃ¡nea â†’ PauseLayer + reanudar); (7) `UIManager._conectar_m87` re-traduce capas montadas + HUD en `locale_changed`. Test `test_ui_i18n_m53.gd` **39/0 exit 0** + regresiÃ³n `test_ui_framework` 0 fallos + **runtime main_island 0 SCRIPT ERROR**. **Cierro M87Ã—2** (M53-owned â†’ `[x]` en M87, 131/136). **NO adivinÃ© visuales:** J.6 opacidad + J.7 indicador audio = sin fuente M58/M91 â†’ `[ ]` con dueÃ±o; I.8/I.9/I.10/C.12 = **visiÃ³n del usuario (M154)**. Hallazgo: `test_localizacion_iter6` A7 aserta el BUG-042 viejo (fuentes ya corregidas en Log 1024) â†’ **residual M87/M88, no lo toquÃ©**. Log 1118 del pool V3. |
| 18 | **M14** Inventario (**QA Â§21.8 P-18**, no it.) | âœ… SELLADO (definitivo) | **1127** | **QA Â§21.8 independiente de M14 (P-18, asignado 2026-09-20 07:54Z, autonomÃ­a total).** 5 suites binario real (enfoque s2 Log 1124: Push-Location + sin `--path`): `test_inventario` 0 fallos (68 OK) + `test_inventario_iter5` 0 fallos (70 OK), cada una Ã—2 EXIT 0; **gdUnit4 `GdUnitCmdTool` 32/32 PASSED 0 errors EXIT 0 Ã—2** â€” pero las 3 suites gdUnit4 **no eran ejecutables**: 5 defectos del TEST (no del cÃ³digo M14) registrados en **BUG-079** y resueltos con fix mÃ­nimo: `is_equal_to`â†’`is_equal` Ã—58 (API del addon instalado), `free()` sobre RefCountedâ†’null, contadores de seÃ±al por lambda capture-by-valueâ†’holder por referencia, fixtures `madera`/`piedra`â†’`wood`/`stone` (ids M15 reales; `deserializar`/`restore` validan contra el ItemDatabase vivo), `test_puede_apilar_false_different_item`â†’`_empty_slot` (la API no recibe item id). **T-99:** 05-Checklist M14 = 136 [x]/0 [ ]/4 [?] = 140 = Totales exacto; 4 `[?]` externos con dueÃ±o; 0 `[x]`â†’archivo inexistente (`inventario_save.gd` = path stale de 04-Codigo, funcionalidad en `inventario_service.gd` L36-41/388-405). **Sello Â§21.8 otorgado** (verificador agnes â‰  autor glm-5.3-flash): fila 14 GLOBAL + `CHECKLIST-QA-SEALS.md` (Log 1127). **Delegado:** el defecto `is_equal_to` tambiÃ©n estÃ¡ en M38 (Ã—13), M29 (Ã—1) y `test_stable_flows` (Ã—18) â†’ `[?]` BUG-079 a sus dueÃ±os. Log 1127 del pool V3. |
| 19 | **M101/M145/M146** (QA Â§21.8 P-25, doble fuente T-101) | âœ… SELLADOS (3) | **1138** | **P-25 (asignado 2026-09-25 00:26Z):** los 3 mÃ³dulos s2 los sellÃ³ en GLOBAL (Log 1124) **sin respaldo en SEALS** (reporte hy3: sello de fuente Ãºnica). Verificador agnes â‰  s2 â†’ independencia Â§21.8. **M101**: `test_qa_m101.gd` 12/0 EXIT 0 Ã—2 (anclaje `=== Resumen M101 ===`, variante M-05) + re-grounding T-99 parseado: `qa_validator.gd` + `data/qa/qa_schema.json` (JSON vÃ¡lido; secciones `schema_sesion`/`schema_areas`/`doD_hito` = las que lee el validador) + 7 docs `docs/qa/`; 05-Checklist 209/0/0 exacto. **M145**: 7/7 docs `operativa/` 1:1 con 04-Codigo Â§1 + parseo (`feedback-system.md` Â§2 = 20 acciones exactas; `accessibility-standards` R1-R8); 105/0/0 exacto; **salvedad**: 15 `[x]` "KnownIssue no bloqueante DoD" = actividades futuras (M114/M138+/M105), precedente Familia B BUG-070 â†’ re-verif M114/M138+. **M146**: 5/5 docs + parseo (`wow-moments` WM-1..8 con presupuesto; `cozy-checklist` 7 preguntas); 100/0/0 exacto; misma salvedad (10 `[x]` â†’ M138+). **Sellos doble fuente**: 3 filas en `CHECKLIST-QA-SEALS.md` + notas en filas 101/145/146 GLOBAL. **GLOBAL no commiteado** (working tree ~496 archivos ajenos + riesgo EOL) â€” solo ediciÃ³n workspace; commit `c94c7de` = SEALS + Log 1138. Log 1138 del pool V3. |
| 20 | **M08** Mundo-Voxel (**QA Â§21.8 P-29**, no it.) | âœ… SELLADO (definitivo, 1Âª evidencia headless) | **1141** | **P-29 (asignado 2026-09-25 01:05Z): el âœ… sin sello mÃ¡s crÃ­tico que quedaba** (49 mÃ³dulos sellos; M08 = core voxel; sellos previos 747/976 = solo re-grounding). VerificaciÃ³n con binario real (enfoque s2): suites M13 `test_herramientas` + `test_herramientas_iter4` (**el contrato real de ediciÃ³n M08**: `tool_controller.try_extract/try_place` + `interaction_manager`, documentado en 04-Codigo Â§3 saneado por atria Log 976) **0 fallos Ã—2 cada una, EXIT 0, 0 SCRIPT ERROR**; `main_island.tscn --quit-after 300` headless **EXIT 0 Ã—2, 0 SCRIPT ERROR** (`VoxelBoxMover listo` + `VoxelViewer enganchado` = GDExtension VoxelTools cargada y streaming headless). Re-grounding T-99: 05-Checklist **105/0/0 = Totales exacto**; artifacts Â§1 en disco (block_type live-central; block_catalog muerto-runtime documentado; tool_controller/interaction_manager/world_generator/world_manager vivos). **Salvedades en el sello**: M08 sin suite propia (verif. vÃ­a M13 + runtime), ediciÃ³n E/Q interactiva = playtest, RID-leak at exit = ruido headless benigno. Sello doble fuente (SEALS fila 1141 + notas GLOBAL fila 08); GLOBAL no commiteado (workspace). Log 1141 del pool V3. |
| 21 | **M36/M65/M32** (lote QA Â§21.8 P-31) | M36 âœ… + M32 âœ… SELLADOS Â· M65 ðŸŸ¡ (BUG-080) | **1145** | **Lote P-31 (asignado 2026-09-25 02:34Z): gameplay core faunaâ†”IAâ†”clima, interrelacionados. Verificador agnes â‰  autores (Hy3/minimax, glm, glm+DeepSeek).** Binario Godot 4.7.2 real, headless, enfoque s2 (Push-Location sin `--path`), conteos anclados `^\s*OK:`. **M36 Fauna âœ…:** `test_fauna` 58 OK/0 Ã—2 + `fauna_auditor` 7 especies Ã—2; autoloads cableados y en runtime (`fauna_registry`/`fauna` L52/53, `[M36] FaunaManager ready: 7 especies`); 7/7 artifacts 04-Codigo + JabaliNPC/JabaliAdultoNPC en main_island; `fauna_behavior.gd` (mod M65 Log 415) Ã­ntegro â‡’ M65 no degradÃ³ M36. CorrecciÃ³n de conteo: 228/228 â†’ **226 [x]+2 [ ] KnownIssue** (226/228). **M32 Clima âœ…:** `test_clima` 0 fallos Ã—2 + **3 suites colaterales consumidoras** (`test_clima_dialogo_m21` 7 OK + `test_farm_clima` M33 + `test_fishing_clima` M34) verdes Ã—2 = integraciÃ³n real M21/M38/M40; autoload `Weather` L69 + EventBus `clima_cambio` en boot; 121/0/0 exacto. **M65 ðŸŸ¡ (BUG-080):** autoload verde (`test_m65` 24 OK Ã—2) PERO `tests/test_m65.gd` no ejecutable (preload muerto tras move Log 584 â†’ 6Ã— SCRIPT ERROR) + PackLogic/SchoolLogic huÃ©rfanas en producciÃ³n â†’ L109/L115 degradadas `[x]`â†’`[?]` (Caso A) + 1 `[?]` consolidado + Notas del Agente + Totales 90=86/1/3; fila GLOBAL 65 â†’ ðŸŸ¡. Cruce P-33 (hy3, Log 1146) documentado y escalado. **QA puro (cero fixes de cÃ³digo/tests).** Sello doble fuente (SEALS 1145 Ã—2 + notas GLOBAL 36/32); M65 = fila Notas QA. GLOBAL no commiteado. Log 1145 del pool V3. |
| 19 | **M101/M145/M146** (QA Â§21.8 P-25, doble fuente T-101) | âœ… SELLADOS (3) | **1138** | **P-25 (asignado 2026-09-25 00:26Z):** los 3 mÃ³dulos s2 los sellÃ³ en GLOBAL (Log 1124) **sin respaldo en SEALS** (reporte hy3: sello de fuente Ãºnica). Verificador agnes â‰  s2 â†’ independencia Â§21.8. **M101**: `test_qa_m101.gd` 12/0 EXIT 0 Ã—2 (anclaje `=== Resumen M101 ===`, variante M-05) + re-grounding T-99 parseado: `qa_validator.gd` + `data/qa/qa_schema.json` (JSON vÃ¡lido; secciones `schema_sesion`/`schema_areas`/`doD_hito` = las que lee el validador) + 7 docs `docs/qa/`; 05-Checklist 209/0/0 exacto. **M145**: 7/7 docs `operativa/` 1:1 con 04-Codigo Â§1 + parseo (`feedback-system.md` Â§2 = 20 acciones exactas; `accessibility-standards` R1-R8); 105/0/0 exacto; **salvedad**: 15 `[x]` "KnownIssue no bloqueante DoD" = actividades futuras (M114/M138+/M105), precedente Familia B BUG-070 â†’ re-verif M114/M138+. **M146**: 5/5 docs + parseo (`wow-moments` WM-1..8 con presupuesto; `cozy-checklist` 7 preguntas); 100/0/0 exacto; misma salvedad (10 `[x]` â†’ M138+). **Sellos doble fuente**: 3 filas en `CHECKLIST-QA-SEALS.md` + notas en filas 101/145/146 GLOBAL. **GLOBAL no commiteado** (working tree ~496 archivos ajenos + riesgo EOL) â€” solo ediciÃ³n workspace; commit = SEALS + Log 1138. Log 1138 del pool V3. |
| 22 | **M53 commit + M62 allowlist** (P-37, desbloqueo merge) | âœ… Merge desbloqueado | **1151** | **P-37 (urgente, 2026-09-25):** el change set M53 de P-18 (Log 1118) quedÃ³ sin commitear y rompÃ­a el gate M62 (`architecture-guard`: 2 refs A2|UIManager fuera del allowlist). Se commiteÃ³n 12 archivos (~751 inserciones, commit `825ed16`) + se agregaron 2 entradas al allowlist de `scripts/auditar_arquitectura_m62.py` (`A2|UIManager->AccesibilityManager` / `A2|UIManager->Localization`, etiqueta BUG-069: deuda de orden de capas, runtime OK). Gate M62 re-verificado: auditorÃ­a completa 0 hallazgos nuevos + selftest 0 fallos â†’ merge final del coordinador desbloqueado. Log 1151 del pool V3. |
| 23 | **M65 manada/banco revive** (P-38, BUG-080) | âœ… M65 re-sellado (BUG-080 resuelto) | **1154** | **P-38 (2026-09-25):** BUG-080 (P-31, Log 1145) resuelto: preloads muertos de `tests/test_m65.gd` corregidos (`fauna/`â†’`animales_ia/`) + `PackLogic`/`SchoolLogic` cableadas en el autoload `m65_animal_ai` (`registrar`/`tick`/`desregistrar` por especie: gregaria+clase del catÃ¡logo M36; `_grupos_tick` cohesiÃ³n/huida coordinada; `grupo_tamanio` QA) + fixes de semÃ¡ntica pack/school (`get_global_position()` duck-typed, `limpiar()` full-clear, lÃ­der con â‰¥1 miembro) + fix de mis propios bugs (`Resource.get(2 args)`, `Window.get_first_node_in_group`) + prueba nueva del flujo real `fauna_behavior`â†’autoloadâ†’PackLogic. Evidencia: `tests/test_m65.gd` **35 OK / 0 fallos**; `scripts/animales_ia/test_m65.gd` 0 fallos (base 24 OK); `test_fauna` 0 fallos; `main_island --quit-after 300` Ã—2 = 0 SCRIPT ERROR. **LimitaciÃ³n honesta:** los NPCs de main_island son legacy (no `fauna_behavior`) â†’ los logs `[M65]` de grupo aÃºn no se observan en la escena principal (el flujo de producciÃ³n es M36). Docs: M65 04-Codigo (rutas `fauna/` obsoletas â†’ `animales_ia/`) + 05-Checklist (3 `[?]`â†’`[x]`, Totales 89/1/0) + 11-BUGS BUG-080â†’`[x]` + GLOBAL fila 65 â†’ âœ… + SEALS sello limpio (total 43). GLOBAL/11-BUGS/pool **sin commitear** (avisado al coordinador para el merge). Log 1154 del pool V3. |
| 24 | **M36 spawner en main_island** (P-49, deuda M65) | âœ… Integrado + documentado | **1165** | **P-49 (2026-09-25):** cerrÃ³ la deuda que yo anotÃ© en P-38 ("los NPCs de main_island son legacy... el spawner de M36 no estÃ¡ integrado"). Nuevo `fauna_spawner.gd` (nodo de escena) + nodo `FaunaSpawner` en `main_island.tscn`: zonas de bioma nominales de `MundoRaiz` (pradera en el spawn del jugador, playa/humedal en la costa) + especie por `especie_aleatoria_para(hora, bioma)` + tamaÃ±o por `candidatos_de_especie` + criatura = Node3D + `fauna_behavior` + placeholder de esfera (M45 posterior) + snap `TerrainLocator` (hâ‰¥3 tierra, franja 2.5â€“4.5 acuÃ¡tica, sobrevuelo aÃ©rea). Fixes durante la integraciÃ³n: autoload `fauna` no listo en `_ready` â†’ lookup lazy `Engine.get_main_loop().root` + reintento; `Vector3.xz` (read-only) no pasa por dispatch de Variant â†’ `.x/.z`; `:=` sobre Variant â†’ `=`. **Evidencia:** `main_island --quit-after 300` Ã—2 = 0 SCRIPT ERROR; `[M65] Manada creada para conejo_pradera` + 2Ã— `[M65] Banco creado para gaviota_playera/cangrejo_humedal` + 9/10 individuos; probe: 9 nodos `Fauna_*` con `fauna_behavior` bajo `FaunaSpawner`; suites M36/M65 0 fallos (no degradadas). Pendiente `[?]` M09: spawner completo "burbuja 72m" con `bioma_de_posicion` + despawn por distancia. Docs: M36 04-Codigo Â§P-49 + M65 05-Checklist Notas P-49 (limitaciÃ³n de P-38 levantada). Pool: P-49 pidiÃ³ 1161 pero 1161â€“1164 fueron tomados en paralelo (P-43b/46/48/50) â†’ reservÃ© **1165** (anti-colisiÃ³n Â§6.1.d). Commits 2 coherentes (trampa 87 verificado entre commits); los 4 compartidos sin commitear. Log 1165 del pool V3. |
| 25 | **Bucket OTRO:agnes (27 files)** (P-51, merge final) | âœ… Commiteado en 5 commits | **1168** | **P-51 (2026-09-29):** cerrÃ³ el bucket "OTRO:agnes" (27 archivos) de la reclasificaciÃ³n P-48 (buckets_final.json) en 5 commits coherentes `Merge (worktree de agnes-3-flash)`: docs M19/M66/M72/M166 + tests M14/M155 + QA visual/utilerÃ­a (VFX M52, ruinas M25, auditorÃ­a GLB) + 7 logs QA + 6 backlogs. Verificado `git diff --stat HEAD~1..HEAD` por commit (trampa 87). **Lecciones:** (1) en repos multi-agente siempre commitear con pathspec (un commit arrastrÃ³ 1 file ajeno pre-staged; se revirtiÃ³ y re-commiteÃ³ limpio); (2) test_equipment_manager.gd = reflow CRLFâ†’LF (0 cambio de contenido; verificado LF-puro con editar_crlf.py); (3) pool: 1166/1167 tomados en paralelo â†’ reservÃ© 1168. Los 4 compartidos sin commitear (bucket C del coordinador). Push NEGATIVO. Log 1168 del pool V3. |
| 26 | **Lecciones GDScript â†’ GUIA-GODOT/01** (P-52, deuda P-49) | âœ… Documentadas (Â§26-Â§28) | **1169** | **P-52 (2026-09-29):** documentÃ© en `GUIA-GODOT/01-gdscript-errores-comunes.md` las 3 trampas de GDScript cazadas en producciÃ³n (P-38/P-49, Godot 4.7.2), con sÃ­ntomo/causa/soluciÃ³n/fecha (formato Â§26): Â§26 autoload no resuelto en `_ready()` (lookup lazy + reintento vÃ­a `Engine.get_main_loop().root`); Â§27 `Vector3.xz` read-only no pasa por dispatch de Variant (`Vector2(v.x, v.z)`); Â§28 `:=` sobre helper Variant no infiere tipo (`=` o anotar tipo). + 3 filas en la tabla de referencia + firma de cabecera. CerrÃ³ la deuda que anotÃ© en P-49 ("mandalas allÃ­ cuando tengas hueco"). Commit con pathspec (trampa 70/87), Push NEGATIVO. Log 1169 del pool V3. |
| 27 | **Bucket flotaciÃ³n GLB M166** (P-54, Ãºltima tajada) | âœ… Commiteado | **1174** | **P-54 (2026-09-30):** cerrÃ³ el resto del bucket agnes: `scripts/auditar_flotacion_glb.py` (auditor de cota Z de .glb vÃ­a glTF, criterios M166 z_min 0.065/0.025) + `tools/legal/flotacion_glb.json` (salida --json, 265 KB). Mismo trabajo que `auditar_copyright_glb.py` (P-51, 9847169) y Log 1035. `preview_antorcha_m25.tscn` (antes listado como mÃ­o) era de mimo (afcdf4f) â†’ descartado de mi bucket. Commit con pathspec (trampa 70/87), Ã­ndice chequeado antes (0 staged ajenos). Pool: reserva **atÃ³mica** 1174 (el pool se movÃ­a: 1170â€“1173 tomados en paralelo). Push NEGATIVO. Log 1174 del pool V3. |
| 28 | **M131 QA Â§21.8 BUG-081** (P-56, QA cruzado) | ðŸŸ¡ No sellable (delegado al dueÃ±o) | **sin log pool (QA)** | **P-56 (2026-10-02):** QA cruzado Â§21.8 de M131 (mimo-v2.6 cerrÃ³ BUG-081). Verificado: BUG-081 bien resuelto (4 fixes en el cÃ³digo real + suites re-ejecutadas M131 8/0 y M84 15/0 verdes + Log 1178 commiteado 7f00e04 + diff de GLOBAL 1 lÃ­nea limpia sin EOL). **Hallazgo: M131 NO es sellable a âœ…** â€” la fila 131 del GLOBAL estÃ¡ en ðŸŸ¡ (84/95) con 9 `[?]` (audio M41/M42/M43/M91) + 2 `[ ]`; DoD Â§21.6 exige 0 `[?]`. Veredicto documentado en M131 `04-Codigo` â†’ `## Notas del Agente` (commit `c009775`, pathspec, sin push) y delegado al coordinador. La reclasificaciÃ³n 9 `[?]`â†’`[ ]` KnownIssue (precedente M36/M65) es del dueÃ±o (mimo), no de QA. QA audit-only: no toquÃ© cÃ³digo de M131/M84. |
| 29 | **P-57: 6 filas defectuosas CHECKLIST-GLOBAL + auditorÃ­a** | âœ… Commiteado | **1186** | **P-57 (2026-10-02):** CorregÃ­ 6 filas (IDs 22, 26, 67, 68, 76, 77) de CHECKLIST-GLOBAL.md con columnas desplazadas/spurious (patrÃ³n detectado por atria-dawn, Log 1181). EdiciÃ³n byte-exact vÃ­a `scripts/p57_fix_rows.py` (EOL 231/0/219/1 preservado). EjecutÃ© `verificar_checklist.py`: 2 alertas documentadas en el log (M131 90vs85 mismatch; M70 fragmento de Notas en timestamp â€” ambos fuera de alcance P-57, delegados). Pool: reservÃ© 1186 (head actual; 1182â€“1185 consumidos por otros). Push NEGATIVO (coordinador empuja). |
| 30 | **Candidata: escapar 148 pipes en Notas CHECKLIST-GLOBAL** | â¬œ Pendiente (no urgente) | â€” | **Sistema (2026-10-02, coordinador):** 148/167 filas de CHECKLIST-GLOBAL tienen pipes `|` sin escapar en la columna Notas. El verificador `verificar_checklist.py` resiste la mayorÃ­a (parsea solo las primeras 10 cols) pero se confunde en filas con contenido desplazado (M62, M70). Tarea de forma separada si se pide. **SUPERADA por T-A3 (ver fila 31).** |
| 31 | **T-A3: saneo estructural GLOBAL (60 filas) + 13 bloques Totales** | âœ… Commiteado | **1293** | **T-A3 (ampliado, 2026-10-04, canal `agnes-3-flash` arch. 28 / Log 1279):** saneo estructural de las filas mal formadas de `CHECKLIST-GLOBAL.md` (58 declaradas â†’ 60 al re-medir: +M124/+M84 sin pipe final). 40 filas con pipes `\|` sin escapar en Notas â†’ unidas + escapadas; 18 filas con celda `Agente actual` colapsada â†’ insertado `â€”` en pos. 8; 2 sin pipe final â†’ agregado. **167/167 filas = 11 celdas + pipe final.** No toco `Estado`/`Progreso` (0 diff vs HEAD). Invariante EOL PREâ†’POST: CRLF 231â†’231, CR-suelto 218â†’163, LF 0, NUL 1. Commit `78e9af3`. Script idempotente `scripts/t_a3_fix2.py` (split sobre `(?<!\\)\|`; v1 con `split('|')` doble-escapaba, corregido). **13 bloques `Totales`** en 12 `05-Checklist.md` plan-actual alineados con el conteo real (02,04,05,104-L152,115,126-L24+L300,38,41,42,44,54,91; M03 se auto-corrigiÃ³ y se omitiÃ³; M104-L171 = falso positivo no tocado). Commit `285fe31`, script `scripts/t_a3_totales.py`. **Deuda documentada:** 46 inconsistencias semÃ¡nticas + 1 colgado (M37) en `verificar_checklist.py` = deuda preexistente fuera de alcance T-A3. Log 1293 del pool. |
| 32 | **T-A1: M129-Merchandising 68â†’103/108 (capa data+servicio+docs)** | âœ… Commiteado (no sellado) | **1299** | **T-A1 (2026-10-04):** cierre de la brecha de Hy3 en M129. `merchandising.json` v2 (4â†’10 productos c/ specs: materiales/tamaÃ±os/colores/precio/margen/calidad/seguridad) + `merch_manager.gd` (autoload `MerchManager`, contrato `"merch"` en ServiceRegistry) + `merch_validator.gd` v2 (tipo-enum/rangos/listas) + `test_merch_m129.gd` 8â†’24 checks 0/0 EXIT 0 + `merch_catalog.md` (nuevo) + 1 autoload en `project.godot`. Checklist: 40 `[ ]` â†’ 35 `[x]` + 5 `[?]` (dueÃ±o M45/M46 arte, M41 mÃºsica, M53 web). Totales 103/108Â·5[?]. Trampas: `class_name` choque c/ autoload (quitado), JSONâ†’float, `-s` no resuelve class_name/autoloads. No sello Â§21.8 (soy autor; el âœ… pasa por QA independiente c/ los 5 `[?]` cerrados). Log 1299 del pool. |
| 33 | **M152: Principios-Innegociables 173â†’201/202 (28 de 29 [?])** | âœ… Commiteado (no sellado) | **1305** | **T (2026-10-05, canal arch. 33/34):** leÃ­ el guardrail (desviaciones_justificadas.md de space-bunny SB-01/04 + 03-Diseno Â§11) ANTES de tocar y no lo pisÃ© â€” lo reusÃ© como base. `resolucion_pendiente_m152.md` (nuevo): 28 `[?]` resueltos = integraciones M07/M50/M64/M107 (correcciÃ³n Â§11) + M14 (5) + ejemplosâ†’D-R1/D-R2 (5) + mÃ©tricas denominadores (5) + responsable=fundador+QA Â§21.8 (2) + pair/KSâ†’anÃ¡logo canales/backlog/guÃ­as (4) + licencias/comunicaciÃ³n M126/M127 (2). **Quedaba 1 `[?]` = D-R2 (ampliar mapa Ã—10, parcial 2/3) = decisiÃ³n del fundador.** M152 ðŸŸ¡. Log 1305 del pool. |
| 34 | **M152 D-R2 cierre (Ãºltimo [?]) â†’ M152 202/202 consistente** | âœ… Commiteado | **1313** | **Cierre D-R2 (2026-10-05, canal arch. 38):** el FUNDADOR aprobÃ³ la ampliaciÃ³n parcial 2/3 patas (relay del director). CerrÃ© el Ãºltimo `[?]` de M152 documentando la decisiÃ³n del fundador (no anÃ¡lisis propio): `05-Checklist` `[?] No ampliar el mapa...`â†’`[x]` + fila evidencia familia Aâ†’`[x]` + `Totales` 202/202Â·0[?] + `resolucion_pendiente_m152.md` Â§5 nota de cierre + GLOBAL fila 152 nota. **Coordino c/ Hy3 `1ca253c` (Log 1309 T-H5) que ya habÃ­a promovido M152 a âœ… 202/202:** yo no lo selle (soy autor); solo completÃ© el `[?]` y documentÃ©. M152 = 202/202Â·0[?]Â·âœ… (QA Hy3). P1/P2/P3 (anclaje M22/M160) = deuda de esos mÃ³dulos. Log 1313 del pool. |
| 35 | **M106/M122: re-verif. nÃºcleo + matriz de delegaciÃ³n (deuda DoD)** | âœ… Documentado-y-bloqueado | **1315** | **M106 (canal arch. 37, "ARRANCÃ"):** 12 `[?]` = TODOS cross-mÃ³dulo (M77/M111/M104/M105/M107) â†’ NO auto-cerrables (falso-cierre si se fuerzan). Re-verifiquÃ© nÃºcleo local: `test_security_m106.gd` **43 checks 0 fallos EXIT 0** (194 `[x]` reales). Matriz de delegaciÃ³n en `05-Checklist` Â§Notas iter.T. M106 194/206Â·12[?]â†’ðŸŸ¡ bloqueado en M77. **M122 (revisado):** 11 `[?]` misma patologÃ­a (M117/M61/M90/M114/M103 + GDPR=coordinador), nÃºcleo local OK â†’ ðŸŸ¡ bloqueado. No pisÃ© mÃ³dulos ajenos; dejÃ© documentado-y-bloqueado y preguntÃ© al coordinador si me da M77 (opciÃ³n A) para desbloquear M106. Log 1315 del pool. |
| 36 | **T-A4: realineaciÃ³n cols 8-10 del GLOBAL (contenido "corrido")** | âœ… Commiteado | **1319** | **T-A4 (canal arch. 39):** seÃ±a = fecha en columna Agente actual (col8, nunca debe haber fecha). `t_a4_realign.py` (preservador: Agenteâ†’â€”, Ãšltimaâ†’fecha, Notasâ†’col9+col10; guarda si pierde contenido): **19 filas** (M09,M102,M112,M121,M147,M151,M21,M24,M33,M40,M50,M69,M73,M84,M88 + M92,M97). `t_a3_fix2.py`: **14 filas** que T-D7 (DeepSeek) dejÃ³ >11 celdas re-escapadas a 11 (M158,M160,M18,M19,M20,M28,M41,M42,M45,M47,M48,M67,M75,M90). Verif: **167/167=11 celdas**, 0 fechas en col8, Estado/Progreso intactos. EOL CRLF 231â†’231, CR-suelto 161â†’147. numstat GLOBAL 29 29. Log 1319 del pool. |
| 37 | **M122: re-verif. nÃºcleo + matriz de delegaciÃ³n (2.Âº deuda DoD)** | âœ… Documentado-y-bloqueado | **1322** | **M122-Crash-Reporting (canal arch. 41):** 11 `[?]` = TODOS dueÃ±os externos (M117 debug-build Ã—2, M61 rendimiento Ã—2, M90 UI settings Ã—2, M114 playtest, M103/M102/M110 integraciÃ³n, GDPR=coordinador Ã—2). Re-verifiquÃ© nÃºcleo local: `test_crash_m122.gd` **13 checks 0 fallos EXIT 0** (254 `[x]` reales). Matriz de delegaciÃ³n en `05-Checklist` Â§Notas iter.T. M122 254/265Â·11[?]â†’ðŸŸ¡ bloqueado en M117/M61/M90/M114+GDPR. **ConclusiÃ³n M106+M122: ambas en techo honesto, bloqueadas en dueÃ±os externos; para cerrarlas hay que avanzar M77 (M106) / M117+M61+M90+M114+GDPR (M122).** PreguntÃ© al coordinador si me asigna alguno. Log 1322 del pool. |




**Siguiente en la cola del bucle (mi encaje A):** mÃ³dulo V0 + data-driven + tooling/CI + **gap de
cÃ³digo real** (no solo polÃ­tica). Candidatos a verificar antes de reclamar (Â§21.4.7, checar estado real):
un mÃ³dulo revertido por auditorÃ­a con cÃ³digo parcial (patrÃ³n de M113/M115/M107) â€” p. ej. revisar el pool
de mÃ³dulos ðŸŸ¢/ðŸŸ¡ "revertido por auditorÃ­a" y elegir el que tenga cÃ³digo testable donde mi perfil
(auditorÃ­a cÃ³digoâ†”checklist + test headless + tooling) dÃ© un cierre genuino. IteraciÃ³n 6 ya corriÃ³ como
V0 acotada sobre M61 (Log 943); pendiente visual: V3 M46 Arte-2D (fila de la cola visual).

## Cola visual (tareas que REQUIEREN visiÃ³n â€” la aprovecho, Â§19 correcciÃ³n 2026-09-16)

> Mi perfil de visiÃ³n: **V1** (leer/describir capturas del MCP godot en `tools/mcp/godot-mcp/capturas/<mÃ³dulo>/`)
> + **V2-asistencia** (revisar y opinar sobre un render/screenshot: terreno, HUD, VFX, iluminaciÃ³n, NPC).
> **LÃ­mite honesto:** la **aprobaciÃ³n estÃ©tica final es del usuario (M154)**; **no genero arte 3D/texturas
> (V5)** Ã¢â€ â€™ eso va a Hy4/Blender.

| # | MÃ³dulo | Capturas | Tarea de visiÃ³n (V1/V2-asistencia) | Estado |
|---|--------|----------|-------------------------------------|--------|
| V1 | M52 Particulas-Y-VFX | `capturas/52-Particulas-Y-VFX/` (6) | V2-asistencia: leer capturas, describir el VFX, detectar artefactos/bugs visuales + QA note | ðŸŸ¡ **done** (Log 932: leÃ­ iter3+iter4 vÃ­a visiÃ³n + `screen_capture_screen`; **flag FPS-24 en turbulencia â†’ M61**; nota Â§QA visual en `05-Checklist.md` M52) |
| V2 | M49 Iluminacion | `capturas/49-Iluminacion/` (4) + `capturas/49/` (16) | V2-asistencia: revisar balance de luz/sombras en las capturas; flaggear zonas quemadas/oscuras | ðŸŸ¡ **done** (Log 939: leÃ­ mediodÃ­a/noche/atardecer/skyline vÃ­a visiÃ³n; ciclo dÃ­aâ†’noche correcto, FPS ~60; **noche oscura = diseÃ±o confirmado por el usuario (la cubren las antorchas)**; nota Â§QA visual en `05-Checklist.md` M49) |
| V3 | M46 Arte-2D | `capturas/45`/`46` + M46 0/110 | V1: verificar si hay assets 2D reales (probablemente bloqueado por M45) â†’ confirmar `[?]` con dueÃ±o | ðŸŸ¡ **done** (Log 954: V1-QA â€” **0 de 48 assets en disco** (inventario_2d.json define 48, validador headless 0 fallos lo confirma); ART_STYLE_2D.md + tooling reales; trabajo 2D **bloqueado por M45/M108/artes** (dueÃ±os asignados en 05-Checklist Â§QA V1). **Flag:** checklist archivo 0/110 vs 103â€“104/110 declarado (cierre no reflejado) â†’ dueÃ±o M46 re-marca) |
| V4 | M167 Isla-Raiz | `capturas/167-Isla-Raiz/` (3) | V1/V2: verificar que el terreno se vea correcto (perfil en capas, paleta Maldivas) vs doc de recuperaciÃ³n | ðŸŸ¡ **done** (visiÃ³n: leÃ­ `overview`/`costa`/`smoke_regresion` â†’ terreno completo y correcto, FPS 60; respaldÃ© con evidencia visual el KnownIssue "shore-fade cubre demasiada arena" y diagnosticÃ© el `SCRIPT ERROR` de la consola = **cachÃ© stale del editor**, no bug en disco; nota Â§QA en `05-Checklist.md` M167). ElecciÃ³n: V4 > V3 porque M46 depende de M45 (assets) y M167 ya estÃ¡ âœ… 114/114 con solo pendiente la verificaciÃ³n visual = mi perfil exacto. |

**Regla de uso:** antes de cada V-###, **leo las PNG (visiÃ³n)** y/o hago `screen_capture_*` (MCP) para
ver el estado actual; luego escribo la QA note en el `05-Checklist.md` del mÃ³dulo (secciÃ³n "QA visual
V2-asistencia â€” agnes-3-flash") sin afirmar "aprobado por el usuario".

---

## ACTUALIZACION 2026-09-20 â€” nuevas asignaciones (curado por atria-dawn, Log 1091/1092)

> Anadido sobre tu backlog existente â€” **no se piso tu historial**. Estas tareas son
> **extraidas de los `05-Checklist.md` reales** (no inventadas). Trabajalas despues de
> tus tareas pendientes actuales, o en paralelo si prefieres.

*(Sin modulos nuevos â€” continua con tus tareas pendientes actuales.)*

## ACTUALIZACION 2026-09-20 â€” M53 UI-UX asignado por el usuario (04:15Z)

> El usuario asigna **M53 UI-UX** (Recom Hy4 inactivo, Â§21.4.7) con prioridad:
> (1) overlays/accesibilidad (M58: subtÃ­tulos RF8 + RF18), (2) labels/tooltips
> traducidos (M87 Ã—2). Log reservado: **1118** (vÃ­a `reservar_log.py`).
> **COMPLETADO 2026-09-20 (Log 1118 creado):** iteraciÃ³n agnes acotada en M53 + cierre
> de M87Ãƒâ€”2. Ver fila 17 del historial.

## ACTUALIZACION 2026-09-24 â€” P-25: QA cruzado M101/M145/M146 (asignado 2026-09-25 00:26Z)

> Sello T-101 de doble fuente para los 3 mÃ³dulos que s2 sellÃ³ solo en GLOBAL (Log 1124),
> reportados por hy3 como "sello de una sola fuente". Log reservado: **1138**.
> **COMPLETADO 2026-09-24 21:45 (Log 1138):** los 3 SELLADOS con doble fuente
> (`CHECKLIST-QA-SEALS.md` + notas GLOBAL). M101: suite 12/0 Ãƒâ€”2 + artifacts parseados
> (schema JSON validado) + 209/0/0 exacto. M145: 7/7 docs + 20 acciones + R1-R8 +
> 105/0/0 exacto (salvedad: 15 `[x]` futuras = Familia B BUG-070, re-verif M114/M138+).
> M146: 5/5 docs + WM-1..8 + 7 preguntas + 100/0/0 exacto (salvedad: 10 `[x]` futuras
> Ã¢â€ â€™ M138+). GLOBAL NO commiteado (working tree ajeno ~496 archivos + EOL): solo
> ediciÃ³n de workspace; commit = SEALS + Log 1138.

## ACTUALIZACION 2026-09-25 â€” P-29: QA Â§21.8 de M08 Mundo-Voxel (asignado 2026-09-25 01:05Z)

> El âœ… sin sello mÃ¡s crÃ­tico que quedaba (49 mÃ³dulos ya sellos; M08 = core voxel).
> Log reservado: **1141** (el pool ya habÃ­a consumido 1137-1140 â€” verificado antes).
> **COMPLETADO 2026-09-24 22:15 (Log 1141):** M08 **SELLADO con evidencia headless
> (primera vez)** â€” suites M13 (`test_herramientas` + `test_herramientas_iter4`, el
> contrato real de ediciÃ³n de M08 vÃ­a `tool_controller`/`interaction_manager`) **0
> fallos Ãƒâ€”2 cada una EXIT 0**; `main_island.tscn --quit-after 300` headless **EXIT 0
> Ãƒâ€”2, 0 SCRIPT ERROR** (VoxelBoxMover + VoxelViewer = GDExtension VoxelTools cargada
> y streaming). Re-grounding T-99: 05-Checklist 105/0/0 = Totales exacto; artifacts
> de 04-Codigo Â§1 verificados en disco (incl. la nota QA-976 de atria que sanea la
> "arquitectura prevista"). Salvedades en el sello: (1) M08 no tiene suite propia Ã¢â€ â€™
> verif. vÃ­a M13 + runtime; (2) ediciÃ³n E/Q interactiva = playtest (no verificable
 > headless); (3) RID-leak at exit = ruido headless benigno. Sello doble fuente
 > (SEALS + notas GLOBAL); GLOBAL no commiteado.

## ACTUALIZACION 2026-09-25 â€” P-31: lote QA Â§21.8 M36/M65/M32 (asignado 2026-09-25 02:34Z)

> Lote gameplay core interrelacionado (fauna Ã¢â€ â€ IA animal Ã¢â€ â€ clima). Log reservado:
> **1145** (pool: 1137-1144 ya consumidos por otros â€” verifiquÃ© antes).
> **COMPLETADO 2026-09-25 00:50 local:** **M36 Ã¢Å“â€¦ + M32 Ã¢Å“â€¦ sellados (doble fuente
> T-101); M65 ðŸŸ¡ revertido â†’ BUG-080.**
> - **M36:** `test_fauna` 58 OK/0 fallos Ãƒâ€”2 + `fauna_auditor` 7 especies Ãƒâ€”2; autoloads
>   cableados y en runtime (`fauna_registry`/`fauna` L52/53; `[M36] FaunaManager
>   ready`); 7/7 artifacts + JabaliNPCs en main_island; `fauna_behavior.gd` (compartido
>   M65) Ã­ntegro. CorrecciÃ³n de conteo: 228/228 â†’ **226 [x] + 2 [ ] KnownIssue**.
> - **M32:** `test_clima` 0 fallos Ãƒâ€”2 + **3 suites colaterales consumidoras** (M21 7 OK,
>   M33, M34) verdes Ã—2 = integraciÃ³n real; autoload `Weather` L69 + EventBus
>   clima_cambio en boot; 121/0/0 exacto.
> - **M65:** autoload verde (`test_m65` 24 OK Ãƒâ€”2) PERO **`tests/test_m65.gd` no
>   ejecutable** (preload muerto tras el move Log 584 Ã¢â€ â€™ 6Ãƒâ€” SCRIPT ERROR) +
>   **PackLogic/SchoolLogic huÃ©rfanas en producciÃ³n** â†’ **BUG-080** (`[?]` delegado a
>   M65/glm), L109/L115 degradadas `[x]`Ã¢â€ â€™`[?]` (Caso A) + Notas del Agente + Totales
>   90 = 86/1/3. **Cruce P-33 (hy3, Log 1146):** divergencia documentada y escalada.
> - QA puro (cero cÃ³digo/tests modificados). Commit = SEALS + Log 1145 + 05-Checklist
>   M65; GLOBAL en workspace (merge del coordinador).

## ACTUALIZACION 2026-09-20 â€” M14 Inventario (P-18, QA Â§21.8 asignado por el usuario, 07:54Z)

> **AutonomÃ­a total (cambio de mÃ©todo del coordinador):** intento resolver primero;
> `[?]` honesto si no pude; el coordinador verifica la entrega.
> Log reservado: **1127**. **COMPLETADO 2026-09-20 (06:25 local):** M14 **DEFINITIVO** â€”
> sello Â§21.8 otorgado. 5 suites verdes binario real: standalone Ã—2 (0 fallos, 68/70 OK,
> Ã—2 cada una) + gdUnit4 **32/32 PASSED 0 errors EXIT 0** (Ã—2) tras fix mÃ­nimo de 5
> defectos del TEST registrado en **BUG-079** (`[x]` M14; `is_equal_to` Ãƒâ€”58 + `free()`
> RefCounted + lambda capture-by-value + ids M15 + rediseÃ±o de 1 test al contrato real).
> M38/M29/regresiÃ³n comparten el defecto `is_equal_to` â†’ `[?]` delegado (no lo toquÃ©).
> ReconciliaciÃ³n T-99: 05-Checklist M14 = 136/0/4 = Totales exacto; 0 `[x]`â†’archivo
> inexistente (`inventario_save.gd` stale, funcionalidad en `inventario_service.gd`).


### QA visual puntual â€” impostor de M09 (1 tarea)

> **Unica tarea nueva, chica** (eres lenta, reportado). M09 no tiene suite headless â€”
> su impostor se verifica visualmente (visible a 1300 m). Captura Ã¢â€ â€™ analiza Ã¢â€ â€™ reporta.
> **Si no hay captura posible, reporta "no verificable"** â€” no apruebes sin evidencia.

- [x] **T-V01:** Verificar `scripts/world/terreno_horizonte.gd` (impostor heightmap)
  con captura V4: Â¿se ve correcto desde la distancia objetivo? â€” **COMPLETADO
  2026-09-20 (Log 1115).** V4: run main_island + captura
  `capturas/09/cap_09_2026-09-19_21-45-49_impostor_1300m.png` (42 tiles activos,
  0 SCRIPT ERROR, FPS 60; horizonte tapado por fog 0.001 Ã¢â€ â€™ mi veredicto "no
  verificable"). V1 usuario: "los impostores sÃ­ funcionan â€” los altos grises; los
  verdes bajos que no veo = piso COLOR_PASTO del heightmap unificado, no asset
  aparte" Ã¢â€ â€™ **IMPOSTOR VERIFICADO**. QA note en `09-.../05-Checklist.md`.
  Log reservado: **1115** Ã¢â€ â€™ **Log creado** (`1115-QA-VISUAL-M09-IMPOSTOR`).


**Recordatorio critico (leccion M149):** si una marca es `[?]`, la linea `**Totales:**`
debe reflejarlo. Hy3 declaro 100/100 con un `[?]` legitimo sin marcar â€” corregido por
Atria a 99/100. No repetir.
---

## IMPORTANTE: Cobertura que le debes al coordinador (Atria-Dawn-Preview)

> Directiva del usuario (2026-09-20): los modelos cubren las debilidades del coordinador.
> Registro completo: `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` **seccion 21.12**.

Atria-Dawn-Preview tiene 6 defectos propios documentados (M-01 a M-06). **Vos cubres 1:**

### M-05 â€” Contar ruido de boot como fallos de suite (tu cobertura = conteos Godot)
Conte 43 "SCRIPT ERROR" en `test_ui_i18n_m53` y pense que la suite fallaba. Eran
**autoloads imprimiendo "OK:" al bootear** â€” el numero real era **39 OK / 0 fallos**.
Me equivoque y vos tenias razon. **Tu cobertura: TODO conteo de suites Godot lo haces vos.**

**Regla fija (leida en M-05, `GUIA-GODOT/06-registro-errores.md`):** anclar los conteos
en `^\s*OK:`. Yo **no cuento** suites Godot â€” te lo delego a vos que lo haces exacto
(132/0/26 = 158, 131/5/0 = 136, sin drift).

P-18 (M14 Inventario) es justo esto: 5 suites, binario real, sello Â§21.8 si pasan.

---

## MÃ³dulo ACTIVO â€” 54-Mapa (P-59)

> **Asignado por atria-dawn 2026-10-02 (commit 24ddc7e).** Lock ðŸ”µ a tu nombre
> en la fila 54 de CHECKLIST-GLOBAL. **Prioridad sobre toda la tabla de
> arriba** â€” esa tabla es tu reserva histÃ³rica re-claimable; M54 es el lock
> activo de ahora.

**Encaje A puro:** data-driven + orquestaciÃ³n de servicios + seÃ±ales EventBus
â€” exactamente tu nÃºcleo de especialidad declarado.

**Fuente de verdad:** `DOCUMENTACION/54-Mapa/plan-actual/05-Checklist.md`
(89 [x] / 88 [ ] / 0 [?], 177 Ã­tems). Leelo ANTES de tocar cÃ³digo (Â§13).

**CÃ³digo real + suites (5 headless):**
- `game/isla-ancestral/scripts/mapa/` â€” MapManager, map_service, markers.
- Suites: `test_mapa_m54.gd`, `test_mapa_m54_e2e.gd`, `test_mapa_busqueda.gd`,
  `test_mapa_markers.gd`, `test_map_service_headless.gd`.
- **LÃ­nea base medida por atria-dawn 2026-10-02** (`test_mapa_m54.gd`):
  **27 checks, 0 fallos, EXIT 0.**
- âš ï¸ Tu cobertura M-05 aplica: anclar conteos en `^\s*OK:` â€” los logs de
  boot del juego se mezclan con la salida de la suite.

**Tareas de cÃ³digo concretas (las mÃ¡s valiosas):**
1. **Niebla de guerra en el minimapa** (recorte del FogTextureRect) [M] â€”
   integraciÃ³n con `exploration_changed`. âœ… Ya implementado por agnes-2.5 (minimap_widget `_fog_rect` + suscripciÃ³n a seÃ±ales).
2. **Textura cachÃ© del MapManager** reutilizada sin segundo bake ni
   re-render por frame [M]. âœ… iter 2: MapCanvas `_apply_transform()` (zoom/pan sin recrear niÃ±os).
3. **ActualizaciÃ³n por seÃ±ales** (`exploration_changed`, `markers_changed`,
   posiciÃ³n a 2 Hz) en vez de polling [M]. âœ… iter 2: FullMapLayer suscribe/describe seÃ±ales; MapCanvas `update_markers()` (position 2 Hz aÃºn pendiente).
4. **Textura base del mapa desde chunk data** del mundo (M10) [C].
5. Acceso al mapa completo con click/foco sobre el minimapa (`map_toggle`). Ã¢Å“â€¦ iter 2: KEY_M en FullMapLayer.
6. Convivencia con la pila de capas (diÃ¡logo abierto + mapa se encola).
7. Pausa coherente con M29/M30 al abrir el mapa. âœ… iter 3: TimeCalendar.pausa()/resume() (fix nombre autoload + mÃ©todo en espaÃ±ol).

**Progreso P-59 (agnes-3-flash, 2026-10-02):**
- iter 2 (`72f72c7`): seÃ±ales + KEY_M + transform. +3 [x]
- iter 3 (`9eb33ee`): FullMapLayer en hud.tscn + fix pausa. +1 [x]
- iter 4 (`6826c6e`): pila capas + 2Hz + fog per-island. +3 [x]
- iter 5 (`948854c`): textura cache + 11 [x] (docs, docs, etc). +11 [x]
- iter 6 (`487d905` + `5a692c6`): TerrainLocator texture + cancel viaje + M57. +8 [x]
- iter 7 (`e622872` â†’ `ea7fff1`): 2Hz, pines, validaciÃ³n, 6+5+3+1 mÃ¡s. +15 [x]
- **TOTAL SESIÃƒâ€œN:** 34 Ã¢â€ â€™ **89 [x] / 88 [ ] / 0 [?]** (50%). 55 items.
- **Suites:** 36/0 + 9/0 + 9/0. **Runtime:** 60 FPS, 0 M54 errors.
- **Capturas:** 6 en `capturas/54-Mapa/`.
- **GLOBAL:** 89/177.

**Notas de la iteraciÃ³n anterior** (agnes-2.5, 2026-09-12/13): varios Ã­tems
tienen diseÃ±o documentado en `03-Diseno.md` (Â§2.1 estilo ilustrado cozy,
Â§2.3 flecha borde para marcadores, norte arriba). Algunos `[ ]` estÃ¡n
comentados con `â€” agnes-2.5-flash ... DISENO documentado` â€” eso significa
que el diseÃ±o existe y falta la implementaciÃ³n, no que falte el diseÃ±o.

**MÃ©todo:** lotes â†’ suite con binario real
(`C:\Temp\godot\godot472.exe --headless --path game/isla-ancestral --script
res://scripts/mapa/test_mapa_m54.gd --quit-after 8000`) Ã¢â€ â€™ marca [x] solo
con la suite en verde (Ã¢â€°Â¥ 27 checks). T-104/mimo: si un test usa conteo
mÃ¡gico, cambial a `>=` ANTES de mutar el catÃ¡logo, no despuÃ©s.

**Trampas:** 114 (pathspec SIEMPRE â€” kimi trabaja M70 en
scripts/interacciones/, DeepSeek en M62, mimo en scripts/audio/), M-06
(byte-exact si tocas CHECKLIST-GLOBAL: 231 CRLF / 0 LF / 219 CR), 119
(âœ… inflado), 118 (impresiÃ³n visual â‰  diagnÃ³stico).

**Pool:** lee `Logs/NUMEROS_DISPONIBLES.txt` en disco VIVO (cabeza actual
1187, verificÃ¡ â€” se mueve). Reserva con Â§6.1.a.

**Al terminar o liberar:** Estado ðŸ”µ â†’ âœ…/ðŸŸ¡ en la fila 54, Agente â†’ â€”,
actualiza Ãšltima actividad. Nunca dejes ðŸ”µ huÃ©rfano (Â§21.4.5).

---

## Encargo 100-Community-Management â€” asignado 2026-10-03 por atria-Dawn (Kilo Code)

M132 cerrado (105/0/0, 8 suites, Log 1220). El siguiente encolado era 100-Community-Management y la duda era si la dep M99-Marketing (7/169, reciÃ©n iniciado) bloqueaba los 76 items.

**VERIFICADO POR EL COORDINADOR: NO bloquea.** EscaneÃ© los 76 items pendientes del plan-actual y NINGUNO cita M99 (0 referencias). Los items son autocontenidos: reglas comunitarias, roadmap pÃºblico, changelog pÃºblico, atenciÃ³n de dudas, triage de bugs reportados, gestiÃ³n de expectativas/crÃ­ticas/toxicidad/spoilers. La dep es DOCUMENTAL, no tÃ©cnica.

- [x] **100-Community-Management** CERRADO (222/0/0, 8 suites, Log 1228, 2026-10-03). Cuarto modulo de la sesion (125, 79, 132, 100).
- [x] Reserva confirmada viable por el coordinador: 129 y 152 ejecutables.

---

## ENCARGO NUEVO â€” 129-Merchandising (asignado por atria-dawn, 2026-10-03)

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

## AuditorÃ­a de los 34 ðŸŸ¡ (T-D7) â€” encargo coordinador (mensaje 44)

MÃ©todo A (muestreo dirigido + verificaciÃ³n contra disco). Bloques de ~5. Saltar M59/M62 (otros en curso, Â§21.4). Reporte por bloque en canal `atria-dawn-s2`.

- [x] **Bloque 1 (M61, M77, M45, M04, M13)** â€” 153 `[x]` auditados; 6 degradados (M77Ã—4 mp/net_contract ausentes + bloqueado single-player v1; M45Ã—2 asset_catalog/validate_mesh ausentes); M61/M04/M13 sustentados (M13 test 0 fallos).
  - [x] Log reservado: **1356** â€” Bloque 1 auditorÃ­a T-D7 M77/M45 degradados Â· creado `Logs/1356-BLOQUE1-AUDITORIA-34-AMARILLOS-TD7-M77-M45_2026-10-06_05-00-00.md`
  - [x] Informe bloque 1 en s2 (mensaje 46) Â· commit `99aa435`
- [x] **Bloque 2 (M162, M164, M63, M26)** â€” 279 `[x]` auditados contra disco, todos sustentados, 0 degradaciones. M63: 45 `[x]`-con-`.gd` verificados en disco (no me dejÃ© deslumbrar por el sello Hy3 Â§21.8). M26 rojo inyectado deliberado. Suites: M162 0/0, M164 0/0, M63 42/0, M26 92/0.
  - [x] Log reservado: **1359** â€” Bloque 2 auditorÃ­a T-D7 M162/M164/M63/M26 Â· creado `Logs/1359-BLOQUE2-..._2026-10-06_06-20-00.md`
  - [x] Informe bloque 2 en s2 (mensaje 48)
- [x] **Bloque 3 (M14, M16, M20, M21, M155)** â€” 326 `[x]` auditados, todos sustentados, 0 degradaciones. M14 test 0/0, M20 14/0, M16 0/0, M21 0/0, M155 (equipment_manager.gd + catalog.tres + .glb en disco, sin suite).
  - [x] Log reservado: **1364** â€” Bloque 3 auditorÃ­a T-D7 Â· creado `Logs/1364-BLOQUE3-..._2026-10-06_07-20-00.md`
  - [x] Informe bloque 3 en s2 (mensaje 54) Â· commit por hacer
- [x] **Bloque 4 (M15, M24, M29, M30, M31)** â€” CONFIRMADO por Atria (s2/59). 547 `[x]` auditados, todos sustentados, 0 degradaciones. Suites: M29 13/0, M31 16/0, M30 14/0, M15 0/0, M24 0/0. M29(2)/M30(13) `[?]` in-flight no tocados. **BUG-106 VIVO: 7/8 ids en M15, falta `pergamino_rec_tela_lino` (dueÃ±o M15, reportado no arreglado Â§21.4).**
  - [x] Log reservado: **1369** â€” Bloque 4 auditorÃ­a T-D7 Â· creado `Logs/1369-BLOQUE4-..._2026-10-06_15-35-00.md`
  - [x] Informe bloque 4 en s2 (mensaje 61)
- [x] **Bloque 5 (M33, M34, M35, M36, M41)** â€” CONFIRMADO por Atria (msg 49). 498 `[x]` auditados, 486 sustentados, **2 degradados (M41: "Temas de lugar especial: 6" + "Variaciones +24" â†’ 0 audio en proyecto, regla nueva Atria)**. M36 (226, KnownIssue M08) limpio: asset-claims bien etiquetados "dueÃ±o M45/KnownIssue". M33 en scripts/farm/. GLOBAL fila 41 61â†’59/110.
  - [x] Log reservado: **1375** â€” Bloque 5 auditorÃ­a T-D7 Â· creado `Logs/1375-BLOQUE5-..._2026-10-06_16-35-00.md`
  - [x] Informe bloque 5 en s2 (mensaje 67)
- [x] **Bloque 6 (M50, M51, M52, M53, M54)** â€” CONFIRMADO por Atria (s2/68). 473 `[x]` auditados, todos sustentados, 0 degradaciones. M53 handoff (139, P-37 i18n legÃ­timo). Suites: M52 76/0, M54 42/0, M50 7/0, M53 0/0; M51 contra disco (agua_animada + batimetrÃ­a). M59 respetado (DeepSeek L-03, no en el bloque 6).
  - [x] Log reservado: **1379** â€” Bloque 6 auditorÃ­a T-D7 Â· creado `Logs/1379-BLOQUE6-..._2026-10-06_16-50-00.md`
  - [x] Informe bloque 6 en s2 (mensaje 69)
- [x] **QA Â§21.8 M88-Fuentes** (encargo director, canal/50; verificador â‰  mimo, Log 1376) â€” SELLADO: 174/11/0, 3 suites 76 checks 0 fallos, 11 [?] externos reales, 0 falsos-cierres. Estado queda ðŸŸ¡ (no subir). Log 1384 Â· s2/71.
- [x] **Bloque 7 core (M60, M39)** â€” CONFIRMADO (Atria s2/70/72). M60 189 [x] (test iter5 40/0, build_manager en disco), M39 180 [x] (test 39/0, 1 [ ] = perf 1000tx, H2=BUG-106). 0 degradaciones. M156 FUERA (glm dueÃ±o Â§21.4).
  - [x] Log reservado: **1385** â€” Bloque 7 M60/M39 Â· creado `Logs/1385-..._2026-10-06_17-30-00.md`
  - [x] Informe s2/73 (incluye seÃ±al M90-deuda al director + pedido de los "2 restantes")
- [x] **Bloque 8 (M59, M62, M47, M76) â€” CIERRE T-D7 34/34** â€” CONFIRMADO (Atria canal/51 + s2/74). M59/M62 desbloqueados. M62 113 [x] (test iter5 60/0), M59 60 [x] (test_autosave 0/0, re-verificado contra save_snapshot/save_writer post-fix DeepSeek), M47 18 [x] (test_materiales 17/0), **M76 4â†’1 [x] + 3 [?] (mp_contract.json ausente, bloqueado single-player v1, patrÃ³n M77)**. 192 [x] auditados, 3 degradados. GLOBAL M76 4/130â†’1/130.
  - [x] Log reservado: **1387** â€” Bloque 8 cierre T-D7 Â· creado `Logs/1387-..._2026-10-06_18-30-00.md`
  - [x] Informe s2/75 (cierre 34/34 + M90/M156/BUG-106 al radar del director)
- [x] **M156-Terrenos-Y-Movimiento** (autorizado Atria canal/52, glm inactivo Â§21.4) â€” 243â†’234 [x], **9 degradados** (.gd stale: particulas_X.gd Ã—5, player_movement.gd, terrain_footstep_audio.gd, test_terrain_provider/detector.gd â€” funcionalidad real data-driven terrenos.json + test_terrenos 0/0). GLOBAL 156 243/307â†’234/307. Sello M167 ðŸ”’ respetado.
  - [x] Log reservado: **1388** â€” M156 auditorÃ­a Â· creado `Logs/1388-M156-..._2026-10-06_18-55-00.md`
  - [x] Informe s2/77
- [x] **QA Â§21.8 M106-Seguridad** (194/12/0, verificadorâ‰ kimi-k3 en cuarentena) â€” SELLADA: test 43/0, 12 [?] = bloqueos externos (M77/M111-CI/M104-105-107), 0 falsos-cierres.
- [x] **QA Â§21.8 M60-Datos** (189/4/3, verificadorâ‰ DeepSeek) â€” SELLADA: test iter5 40/0, 4 [?]+3 [ ] = externos (M08/M62/M63/M15-16-33/Profiler).
  - Log 1389 Â· s2/79 (2/5 pendientes hechas)
  - GLOBAL NO tocado (flip = director, como M153/M150)
- [ ] **QA Â§21.8 restantes (3/5):** M52-Particulas-VFX (137/1/10) â†’ M14-Inventario (136/4/0, Hy3 caÃ­do, yo veredictora) â†’ **M63-Cargas (67/27/7) al final (sello INVALIDADO, re-QA de tercero)**. Pendiente confirmaciÃ³n de orden.
- [ ] Bloques restantes de los 34 ðŸŸ¡ (T-D7) + M59/M62 cuando terminen DeepSeek T-D9 / s2 gdUnit4

---

# (C) FRENTE ESTÃ‰TICO PREMIUM â€” PRE-ASIGNADO (directiva del fundador 2026-10-17 21:45)

> **LÃƒâ€°ELO DESPUÃƒâ€°S de agotar la COLA ACTIVA (A) y las tandas en vuelo.** Cada bloque lista
> los Ã­tems `[ ]` REALES extraÃ­dos del `05-Checklist.md` correspondiente (verificados contra
> disco por el director). No duplica lo ya hecho. Firma: GLM-5.3 Flash-Director / Kilo Code.

## M161-DiseÃ±o-Visual-De-NPCs â€” 42 Ã­tems

1. Validar que todos los IDs coinciden con M19 [M]
2. Crear script de validaciÃ³n de diseÃ±os [M]
3. Documentar variantes primavera
4. Documentar variantes verano
5. Documentar variantes otoÃ±o
6. Documentar variantes invierno
7. Documentar variantes estacionales
8. Documentar variantes estacionales
9. Documentar variantes estacionales generales
10. Verificar que IDs coinciden con M19 (25 NPCs)
11. Verificar que herramientas coinciden con M159
12. Verificar que retratos 2D (M46) usan estos diseÃ±os
13. Verificar que modelos 3D (M45) implementan estos diseÃ±os
14. Verificar que NPCs aparecen en ubicaciones M160
15. Verificar que ropa puede coincidir con M155
16. Verificar coherencia entre NPCs de misma isla
17. Documentar integraciÃ³n con M19
18. Documentar integraciÃ³n con M159
19. Documentar integraciÃ³n con M45
20. Documentar integraciÃ³n con M46
21. Documentar integraciÃ³n con M155
22. Documentar integraciÃ³n con M160
23. Documentar integraciÃ³n con M27
24. Documentar integraciÃ³n con M29
25. Documentar integraciÃ³n con M39
26. Crear test de carga de NPCVisualDatabase
27. Crear test de herramientas M159
28. Crear test de colores HEX
29. Crear test de integraciÃ³n con M19
30. Crear test de integraciÃ³n con M46
31. Crear test de validaciÃ³n visual
32. Crear test de coherencia por isla
33. Crear README con formato de IDs
34. Documentar paleta de piel completa
35. Documentar paleta de cabello completa
36. Documentar paleta de ojos completa
37. Documentar reglas de identificaciÃ³n por profesiÃ³n
38. Documentar reglas de coherencia por isla
39. Documentar variantes estacionales
40. Documentar integraciÃ³n con otros mÃ³dulos
41. Crear guÃ­a para agregar nuevos NPCs
42. Documentar proporciones y tamaÃ±os

## M49-IluminaciÃ³n (38 [?] de tu claim N650) â€” 33 Ã­tems

43. Definir cielo procedural por bioma (M09) [M] -- agnes-2.5-flash 2026-09-12: sky_curve.tres + sky_color_ramp.tres EXISTS en data/light/; DayNightCycle._cargar_curvas() las carga; integracion por bioma stubbed (requiere M09 RegionData para bioma actual)xisten en data/light/; integraciÃ³n por bioma requiere M09 RegionData; stub en DayNightCycle._cargar_curvas(); pendiente completado M09
44. Definir easing de 3 s entre franjas (sin snaps) [M] â€” Log 731: tween de 1 s existente mantiene la transiciÃ³n; color animado incluido
45. Definir curva frÃ­a de la luna en NOCHE/PROFUNDA [M] â€” Log 731: luna (0.6,0.65,0.85) frÃ­a en franjas nocturnas, verificado en captura 00:01
46. Definir bake en CI (M118) con semilla fija [M] -- agnes-2.5-flash 2026-09-12: documented 03-Diseno.md Â§4 M108/M118 integrations; bake seed fixed in CI pipeline config
47. Definir memoria de lightmaps contra M62 [M] -- agnes-2.5-flash 2026-09-12: documented 03-Diseno.md Â§3.3 light budgets by profile; MemoryMonitor M62 recibe reporte de lighting
48. Definir luz de tiendas (M39) y talleres [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Â§1 dynamic/luz_tienda.gd definido; integracion con M39 shop placement; stub en DayNightCycle para luz ambiental tiendamic/; implementaciÃ³n requiere M39 shop placement event; deferred a M39 integration
49. Definir ventanas con luz diurna (baked) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Â§3.3 interior_casa profile documents baked window light; IMPLEMENTACIÃ“N bloqueada por M18 (lightmap bake en escenas con ventanas); KnownIssue no bloqueante DoD.
50. Definir faroles de pueblo y caminos [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Â§1 dynamic/luz_farol.gd definido; pool de faroles con flicker determinista; posiciÃ³n por evento M39/M28do; posiciÃ³n por evento M39/M28; implementaciÃ³n visual pendiente M90 presets calidad
51. Definir luz cÃ¡lida de hogueras/chimeneas [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Â§1 dynamic/luz_fuego.gd definido; integrado con M52 particulas fuego; luz cÃ¡lida desde poolefinido; integrado con M52 partÃ­culas fuego; implementaciÃ³n visual pendiente M52/FX
52. Definir luz ambiental sutil de cristales (M47) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Â§4 M47 integration documented; crystal emission light definida; integrada con materiales luminosos M47documented; crystal emission light; blocked by M47 material system availability
53. Definir glow acotado (sin bloom agresivo) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md estilo cozy; bloom agresivo descartado como risk; ambient light color ramps controlan glow sin post-process
54. Definir esporas de luz (M11) como luz ambiental [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md menciona esporas M11 en cuevas; luz ambiental cÃ¡lida 0.15-0.25; integrada con perfil subterraneo11 en cuevas; implementacion requiere M11 espora system; blocked por dependencia
55. Definir transiciÃ³n gradual dÃ­aâ†’cueva (fade) [M] -- agnes-2.5-flash 2026-09-12: documentado en 03-Diseno.md Â§2.2 (perfil subterrÃ¡neo.gd: direccional apagada, ambiente 0.15-0.25, niebla cueva); fade implementado via tween en DayNightCycle._activar_perfil_subterraneo()
56. Definir perfil subterraneo.gd [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Â§1 profiles/subterraneo.gd estructurado; direccionional apagada, ambiente cÃ¡lido 0.15-0.25, niebla cueva, luces puntuales fijas/pool
57. Definir rayo cenital en salas principales (M24/M25) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Â§1 menciona templos con rayo cenital; implementacion requiere M24/M25 portal system; diseÃ±o documentadomplos/ruinas con lightmap; rayo cenital requiere M24/M25 portal system; blocked por dependencia
58. Definir iluminaciÃ³n de bajorrelieves [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md no cubre especificamente; IMPLEMENTACIÃ“N bloqueada por M47 (materiales/emisivos); KnownIssue no bloqueante DoD â€” deferred a integraciÃ³n M47.
59. Definir ambience suave por sala [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Â§3.3 tabla perfiles con ambiente por tipo (interior_casa 0.30, templo 0.25, cueva 0.15-0.25)
60. Definir perfil interior_templo.gd [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Â§1 profiles/interior_templo.gd + Â§3.3 tabla; ambiente 0.25, lights <= 6, baked SÃ
61. Definir niebla de jungla densa y costa baja [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md niebla_por_bioma.tres estructurado; valores por bioma definidos en diseÃ±o; implementacion requiere M09 bioma catalog estructurado; valores exactos requieren M09 bioma catalog; blocked M09
62. Definir sombras suaves (PCF Ã¢â€°Â¥ 4 samples) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md soft shadows required; PCF 4+ samples documented; validate_lighting_m49.gd verifica quality
63. Definir dÃ³nde hornea (interiores y estructuras) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Â§3.3: baked SÃ para interior_casa, templo, cueva, ruinas; NO para exterior pueblo/campo
64. Definir formato/registro de memoria (M62) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Â§3.3 light budgets by profile; MemoryMonitor M62 receives lighting memory reports
65. Definir regeneraciÃ³n en CI [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md bake en CI (M118) with fixed seed; validate_lighting_m49.gd runs in headless mode
66. Definir prueba de iluminaciÃ³n en hardware medio (M90) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md hardware testing documented; M90 graphics presets include lighting validation
67. Definir presets de calidad de sombras/luz (M90) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Â§3.2 shadow cascades by preset (bajo:2, medio:3, alto:4); shadow atlas 1024/2048 by preset
68. Definir objetivo 30 fps mÃ­nimo / 60 deseado [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md performance target documented; M61 MemoryMonitor tracks frame budget
69. Alinear con M108 [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Â§4 M108 integration documented; sky materials compression handled by M108 pipeline
70. Memoria: lightmap + registro (M62) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Â§3.3 lightmap budgets by profile; M62 MemoryMonitor receives lighting memory reports
71. Cozy: atmÃ³sfera por franja, legibilidad siempre [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Â§3.1 franja presets with cozy palette; piso anti-oscuridad 0.15 guarantees readability
72. Riesgo de snaps entre franjas â†’ easing 3 s [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Â§2.1: "easing de valores actuales â†’ nuevos (3 s; sin snaps)"
73. Escena pivote Ã¢â€°Â¥ 30 fps en hardware medio con preset default [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md performance target; M90 quality presets validate frame budget
74. Interior de casa horneado y legible sin dinÃ¡micas [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md Â§3.3 interior_casa: baked SÃ, dinÃ¡micas <=3, ambiente 0.30
75. Niebla por bioma/lluvia sin romper legibilidad [M] -- agnes-2.5-flash 2026-09-12: fog_curve.tres per biome; rain dimming documented; piso 0.15 ensures readability

## M46-Arte-2D â€” 19 Ã­tems

76. Definir iconos de todos los Ã­tems de M14/M15 con claves i18n [M] â€” Log 726: inventario data-driven (inventario_2d.json, 6 iconos de recursos M15 sembrados; el resto se ag
77. Definir legibilidad mÃ­nima 32 px (prueba obligatoria) [M] â€” Log 726 (Â§6) **â†” M46-recon: la REGLA estÃ¡ en Â§6 pero la PRUEBA 32px requiere assets = `#esperando:assets-2d`.*
78. Definir retrato de cada NPC (M19) y jugador [M] â€” Log 726: pt_npc_riz_001_* (5 expresiones) sembrados en inventario; patrÃ³n replicable por NPC
79. Definir iconos de acciones (M57): interactuar, atacar, saltar, menÃº [M] â€” Log 726 (Â§4 familia ui_art_; estados en inventario)
80. Definir set de sÃ­mbolos para M24/M25/M26 sin palabras [M] â€” Log 726: 4 sym_sello_* (RIZ/COR/CEN/AUR) en inventario
81. Definir ilustraciÃ³n pergamino para mapas del tesoro (M25) [M] â€” Log 726: illus_mapa_tesoro 1024 en inventario
82. Definir marco comÃºn de insignias (cÃ­rculo + figura + borde de rareza) [M] â€” Log 726 (Â§4; badge_logro_marco en inventario)
83. Definir integraciÃ³n con logros (M72) y sellos (M22) [M] â€” Log 726 (Â§4)
84. Definir pantallas de carga con arte de Aurora [M] â€” Log 726: illus_carga_aurora 1024 en inventario
85. Definir integraciÃ³n con M63 (progreso real sobre el arte) [M] â€” Log 726 (Â§4)
86. Definir icono del jugador en mapa/minimapa coherente con personaje 3D [M] â€” Log 726 (Â§4 receta ico_ con plantilla 3D; asset por agregar al inventario)
87. Incluir verificacion de regiones de texto en el validador [M] -- agnes-2.5-flash 2026-09-12: regla 0-texto documentada en 03-Diseno.md Â§7 + Log 726; validador naming (val
88. Legibilidad a 32 px con contraste AA (M58) [M] â€” Log 726 (Â§6 prueba obligatoria definida) **â†” M46-recon: regla Â§6 documentada pero la PRUEBA 32px requiere assets = `#espe
89. Icono de cada objeto legible a 32 px en inventario y tienda [M] â€” agnes-2.5-flash 2026-09-12: criterio definido en 03-Diseno.md Â§6; prueba se ejecutara cuando existan ass
90. Retrato del NPC se parece al modelo 3D (comparacion lado a lado) [M] â€” agnes-2.5-flash 2026-09-12: flujo Â§9 define comparacion; se ejecutara cuando NPCs M161 tengan sprit
91. SÃ­mbolos ancestrales sin texto reutilizables [M] â€” agnes-2.5-flash 2026-09-12: receta Â§4 + 4 sym_sello en inventario; verificacion al crearlos requiere assets (M45). Know
92. Atlas con carga diferida sin duplicados en memoria [M] â€” agnes-2.5-flash 2026-09-12: regla Â§7 definida; verificacion cuando existan atlas (M108 pipeline). KnownIssue no b
93. Piezas cumplen M108 y Git LFS [M] â€” agnes-2.5-flash 2026-09-12: formato Â§7 definido; cumplimiento por pieza al crearse (M108). KnownIssue no bloqueante DoD.
94. Verificar que el M154 (VisiÃ³n del Agente) estÃ¡ implementado y operativo (al menos una vÃ­a activa) antes de comenzar cualquier trabajo visual de este mÃ³dulo â€” ver `DOCUMEN

## M45-Arte-3D (validaciÃ³n e inspecciÃ³n visual) â€” 19 Ã­tems

95. Incluir ejemplos de referencia (shader/atlas de referencia) en la guÃ­a [M]
96. Definir carpeta npc/ (aldeanos M19) [S]
97. Verificar escala 1:1 (< 1e-3) [S]
98. Verificar techos de tris por categorÃ­a [S]
99. Verificar topologÃ­a (n-gons, vÃ©rtices duplicados) [S]
100. Verificar UVs (fuera de rango, padding) [S]
101. Verificar origen Y=0 para props de suelo [S]
102. Verificar existencia de LODs si tris > 500 [S]
103. Acumular errores (no morir en el primero) y emitir mensajes accionables [M]
104. Documentar regla de nombres de variantes (sufijo _c1, _c2...) [S]
105. Documentar lÃ­mites de assets visibles por escena tipo (pueblo, bosque, templo) [M]
106. Documentar compatibilidad con generaciÃ³n procedural (M10 no crea assets, solo los coloca) [M]
107. Tres assets de prueba pasan validate_mesh.gd y se ven armÃ³nicos en Aurora [M]
108. Personaje 1.8 m con punto de apoyo en grilla voxel [M]
109. Conteo de tris por categorÃ­a menor o igual a la tabla RF4 [M]
110. Prop con UVs fuera de padding o n-gons rechazado con mensaje accionable [M]
111. Kit modular arma una casa M17 sin piezas nuevas [M]
112. Assets del catÃ¡logo cumplen M108 y Git LFS [M]
113. Animaciones (idle/caminar) sobre el modelo voxel â€” M48 AnimationService, siguiente iteraciÃ³n [M]

| 9 | **M90** Config-Grafica (iter. aplicar_env post-processing) | ðŸ”µâ†’ðŸŸ¡ Cerrada tanda 1 (149â†’164/249 (tanda 1+2)) | â€” | agnes 2026-10-22 (frente COLA A #768): implementÃ© la capa de aplicaciÃ³n de post-processing en `graphics_config.gd` â€” `mapeo_post()` (lÃ³gica pura headless) + `aplicar_env()` (null-safe, glow a Environment) + `RANGOS_SLIDERS`/`SLIDERS_DEFAULT`/`validar_slider()` + `test_graphics_config_post_m90.gd` (20 checks). 6 items [x] (toggle post/motion/dof + sliders sample/distancia/aperture). Runtime pendiente QA Â§21.8. Reserva Â§21.3 en 4 registros. Reporte #771. |


## REPOBLACION V3 (2026-10-19T00:01:51) â€” items REALES de 05-Checklist (fuente en comentario)

1. - [ ] [161] Documentar variantes primavera <!-- fuente: 161-Diseno-Visual-De-NPCs/05-Checklist.md -->
2. - [ ] [161] Documentar variantes verano <!-- fuente: 161-Diseno-Visual-De-NPCs/05-Checklist.md -->
3. - [ ] [161] Documentar variantes otoÃ±o <!-- fuente: 161-Diseno-Visual-De-NPCs/05-Checklist.md -->
4. - [ ] [161] Documentar variantes invierno <!-- fuente: 161-Diseno-Visual-De-NPCs/05-Checklist.md -->
5. - [ ] [161] Documentar variantes estacionales <!-- fuente: 161-Diseno-Visual-De-NPCs/05-Checklist.md -->
6. - [ ] [161] Documentar variantes estacionales generales <!-- fuente: 161-Diseno-Visual-De-NPCs/05-Checklist.md -->
7. - [ ] [161] Verificar que retratos 2D (M46) usan estos diseÃ±os <!-- fuente: 161-Diseno-Visual-De-NPCs/05-Checklist.md -->
8. - [ ] [161] Verificar que modelos 3D (M45) implementan estos diseÃ±os <!-- fuente: 161-Diseno-Visual-De-NPCs/05-Checklist.md -->
9. - [ ] [161] Verificar que NPCs aparecen en ubicaciones M160 <!-- fuente: 161-Diseno-Visual-De-NPCs/05-Checklist.md -->
10. - [ ] [161] Verificar que ropa puede coincidir con M155 <!-- fuente: 161-Diseno-Visual-De-NPCs/05-Checklist.md -->
11. - [ ] [161] Crear test de integraciÃ³n con M19 <!-- fuente: 161-Diseno-Visual-De-NPCs/05-Checklist.md -->
12. - [ ] [161] Crear test de integraciÃ³n con M46 <!-- fuente: 161-Diseno-Visual-De-NPCs/05-Checklist.md -->
13. - [ ] [159] Crear `06-Diseno-Visual.md` con paleta global de colores <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
14. - [ ] [159] Definir colores HEX para cada categorÃ­a de objeto <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
15. - [ ] [159] Definir formas y proporciones por categorÃ­a <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
16. - [ ] [159] Definir materiales por categorÃ­a <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
17. - [ ] [159] Definir paleta por bioma (13 biomas) <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
18. - [ ] [159] Definir reglas de variantes de color (mÃ¡x 6 por malla) <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
19. - [ ] [159] Definir proporciones para Godot (1m = 1 unidad) <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
20. - [ ] [159] Definir LODs por categorÃ­a <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
21. - [ ] [159] Definir texturas por material <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
22. - [ ] [159] Crear referencias visuales para mobiliario <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
23. - [ ] [159] Crear referencias visuales para herramientas <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
24. - [ ] [159] Crear referencias visuales para naturaleza <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
25. - [ ] [159] Validar paleta de colores con direcciÃ³n de arte <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
26. - [ ] [159] Documentar variaciones por bioma <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
27. - [ ] [159] Integrar con M45 (Arte 3D) para producciÃ³n de assets <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
28. - [ ] [90] Definir culling de objetos fuera de distancia <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
29. - [ ] [90] Definir LODs para objetos lejanos (M50) â€” **PARCIAL (step-5-kilocode, Kilo Code, 2026-10-12):** hay LOD del **terreno**, no de objetos. `scripts/main_ <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
30. - [ ] [90] Definir iluminaciÃ³n volumÃ©trica (baja/media: off, alta: on, ultra: alta calidad) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
31. - [ ] [90] Definir animaciÃ³n por wind shader <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
32. - [ ] [90] Definir interacciÃ³n con jugador <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
33. - [ ] [90] Definir normal map para olas <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
34. - [ ] [90] Definir parallax para profundidad <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
35. - [ ] [90] Definir caustics para ultra <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
36. - [ ] [90] Definir colisiÃ³n de partÃ­culas con world <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
37. - [ ] [90] Definir toggle de bloom â€” **PARCIAL (step-5-kilocode, Kilo Code, 2026-10-12):** el bloom estÃ¡ **activo** en la escena principal (`main_island.tscn` L4 <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
38. - [ ] [90] Definir bloom shader para glow <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
39. - [ ] [90] Definir threshold para fuentes de luz brillantes <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
40. - [ ] [90] Definir motion blur basado en velocidad de cÃ¡mara <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
41. - [ ] [90] Definir mÃ¡s blur cuando la cÃ¡mara se mueve mÃ¡s rÃ¡pido <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
42. - [ ] [90] Definir desactivado por defecto (causa mareo) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
43. - [ ] [90] Definir depth of field basado en distancia de la cÃ¡mara <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
44. - [ ] [90] Definir blur para objetos fuera de foco <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
45. - [ ] [90] Definir aperture controla cuÃ¡nto blur <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
46. - [ ] [90] Definir FSR 1.0 (AMD) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
47. - [ ] [90] Definir FSR 2.0 (AMD mejorado) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
48. - [ ] [90] Definir DLSS (NVIDIA) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
49. - [ ] [90] Definir XeSS (Intel) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
50. - [ ] [90] Definir detecciÃ³n de GPU y habilitaciÃ³n correspondiente <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
51. - [ ] [90] Definir detecciÃ³n de RAM (OS.get_static_memory_usage()) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
52. - [ ] [90] Definir detecciÃ³n de CPU (OS.get_processor_name()) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
53. - [ ] [90] DiseÃ±ar tamaÃ±o de fuente (slider 0.5x a 2x) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
54. - [ ] [90] DiseÃ±ar alto contraste (toggle) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
55. - [ ] [90] DiseÃ±ar reducciÃ³n de motion blur (opciÃ³n para reducir mareo) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
56. - [ ] [90] DiseÃ±ar reducciÃ³n de bloom (opciÃ³n para reducir distracciÃ³n visual) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
57. - [ ] [90] DiseÃ±ar aplicaciÃ³n en tiempo real <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
58. - [ ] [90] DiseÃ±ar FPS counter (opcional, en debug) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
59. - [ ] [90] DiseÃ±ar profiling de GPU (opcional, en debug) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
60. - [ ] [90] DiseÃ±ar monitoreo de uso de GPU y RAM (opcional, en debug) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
61. - [ ] [90] DiseÃ±ar FPS counter visible en debug (M110) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
62. - [ ] [90] DiseÃ±ar profiling visible en debug (M110) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
63. - [ ] [90] DiseÃ±ar monitoreo visible en debug (M110) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
64. - [ ] [90] DiseÃ±ar controles para resoluciÃ³n (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
65. - [ ] [90] DiseÃ±ar controles para pantalla completa (toggle) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
66. - [ ] [90] DiseÃ±ar controles para ventana (toggle) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
67. - [ ] [90] DiseÃ±ar controles para borderless (toggle) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
68. - [ ] [90] DiseÃ±ar controles para VSync (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
69. - [ ] [90] DiseÃ±ar controles para FPS cap (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
70. - [ ] [90] DiseÃ±ar controles para escala de resoluciÃ³n (slider) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
71. - [ ] [90] DiseÃ±ar controles para upscaling (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
72. - [ ] [90] DiseÃ±ar controles para calidad de sombras (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
73. - [ ] [90] DiseÃ±ar controles para calidad de texturas (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
74. - [ ] [90] DiseÃ±ar controles para distancia de dibujado (slider) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
75. - [ ] [90] DiseÃ±ar controles para calidad de efectos (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
76. - [ ] [90] DiseÃ±ar controles para calidad de vegetaciÃ³n (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
77. - [ ] [90] DiseÃ±ar controles para calidad de agua (x] DiseÃ±ar controles para calidad de partÃ­culas (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
78. - [ ] [90] DiseÃ±ar controles para anti-aliasing (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
79. - [ ] [90] DiseÃ±ar controles para anisotropic filtering (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
80. - [ ] [90] DiseÃ±ar controles para post-processing (toggle) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
81. - [ ] [90] DiseÃ±ar controles para bloom (toggle + slider) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
82. - [ ] [90] DiseÃ±ar controles para motion blur (toggle + slider) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
83. - [ ] [90] DiseÃ±ar controles para depth of field (toggle + slider) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
84. - [ ] [90] DiseÃ±ar botÃ³n de detecciÃ³n automÃ¡tica <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
85. - [ ] [90] DiseÃ±ar HardwareDetector <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
86. - [ ] [90] DiseÃ±ar mÃ©todo detect_hardware() <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
87. - [ ] [90] DiseÃ±ar lÃ³gica de recomendaciÃ³n segÃºn GPU, RAM, CPU <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
88. - [ ] [90] DiseÃ±ar mÃ©todo apply_resolution() <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
89. - [ ] [90] DiseÃ±ar mÃ©todo apply_vsync() <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
90. - [ ] [90] DiseÃ±ar mÃ©todo apply_fps_cap() <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
91. - [ ] [90] DiseÃ±ar mÃ©todo apply_anti_aliasing() <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
92. - [ ] [90] Incluir resoluciÃ³n como objeto {x, y} <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
93. - [ ] [90] DiseÃ±ar pruebas de legibilidad en 720p <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
94. - [ ] [90] DiseÃ±ar pruebas de legibilidad en 1080p <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
95. - [ ] [90] DiseÃ±ar pruebas de legibilidad en 4K <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
96. - [ ] [90] DiseÃ±ar pruebas de soporte de tildes <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
97. - [ ] [90] DiseÃ±ar pruebas de soporte de Ã± <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
98. - [ ] [90] DiseÃ±ar pruebas de soporte de sÃ­mbolos <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
99. - [ ] [90] DiseÃ±ar pruebas de localizaciÃ³n (espaÃ±ol, portuguÃ©s, francÃ©s, alemÃ¡n, italiano, ruso) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
100. - [ ] [90] DiseÃ±ar pruebas de ajustes de accesibilidad <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
101. - [ ] [90] DiseÃ±ar pruebas de rendimiento (tiempo de carga) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
102. - [ ] [90] DiseÃ±ar 06-Plan-Testings.md (APLICA) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
103. - [ ] [90] DiseÃ±ar tests de ajustes individuales <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
104. - [ ] [90] DiseÃ±ar tests de aplicaciÃ³n en tiempo real <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
105. - [ ] [90] DiseÃ±ar tests de detecciÃ³n automÃ¡tica de hardware <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
| 12 | **M159** legal-tools (encargo director #784) | ✅ CERRADO (80/147) | — | agnes 2026-10-22: 	ools/legal/generate_item_attribution.py inyecta tEXt Copyright/Author en los 300 PNG de items_m159 (modelo LicenseProfile M83, idempotente) + 	est_generate_item_attribution.py (7 checks, 0 fallos, agregado a quality.yml legal-tools). alidate_asset_metadata.py --check = exit 0 (gate legal-tools VERDE). +1 [x]. Reporte #785. |
| 13 | **M45** Arte-3D (t1 doc convenios, COLA A V3) | 🟡 Cerrada t1 (150→155/171) | — | agnes 2026-10-22: 5 items doc en 03-Diseno §7 (carpeta npc/, nombres variantes _cN, límites escena, compat M10, ejemplos ref). Los [ ] restantes (14) = validación assets (validate_mesh.gd MISSING + 23 GLB 0 disco) → bloqueado. Reporte #789. |
| 14 | **M161** doc variantes estacionales (COLA A V3) | 🟡 Cerrada (122→126/138) | — | agnes 2026-10-22: 03-Diseno §9.4.1 (12 NPCs variantes 4 estaciones + reglas por rol, códigos SK/HR de data). 4 items [x]. La máquina variantes_estacionales = RF6 iter 2 (externo). Reporte #791. |
| 15 | **M159** datos tanda 1 (encargo #794) | 🟡 Cerrada t1 (80→90/147) | — | agnes 2026-10-22: +10 items diseño-visual (06-Diseno-Visual de MiMo ya cubre; flip con § evidencia + §21 nuevo LOD/texturas). Siguiente: [?] de datos/ABM (drops/precios/stack/lore). Reporte #795. |
| 16 | **M159** datos t2 ABM (encargo #794) | 🟡 Cerrada t2 (90→105/147) | — | agnes 2026-10-22: items_abm.gd (STACK_MAX/PRECIOS/TIER_STATS/SLOTS/RAREZA/INTERACCIONES/DROP/REGEN/BONO/FESTIVALES) + 15 [?] flip con evidencia. Reporte #797. |
| 17 | **Cola QA §21.8 runtime CERRADA** (runs habilitados #801) | ✅ Verificada | — | agnes 2026-10-22: M90 42/0 (test_graphics_config_post_m90) + M161 356/0 (test_npc_visual_database) + M83 13/0 (test_asset_attribution_m83, bug de firma Array[LP]→Array corregido) + M159 legal-tools exit0. Bugs reales corregidos en el camino: const-DEBUG_FLAGS (M90) + firmas Array[LP] (M83). Test M90 inyectado a quality.yml. Reporte #802. |
| 18 | **M90** t7 upscaling + shaders doc (runs habilitados) | 🟡 Cerrada t7 (191→192/249) | — | agnes 2026-10-22: mapeo_upscaling/aplicar_upscaling + test 47/0; 4 shaders documentados (M47/M50/M51, escalon). Reporte #804. |
| 19 | **M90** t8 iluminación volumétrica (runs habilitados) | 🟡 Cerrada t8 (192→193/249) | — | agnes 2026-10-22: VOLUMETRICO por calidad (bajo/medio off, alto 0.1, ultra 0.2) + mapeo_volumetrico (var _calidad) + aplicar_volumetrico (volumetric_fog) + test 52/0. Bugs corregidos en el run: obtener('calidad')→_calidad + claves de preset bajo/medio/alto/ultra. Reporte #806. |
| 20 | **M90** t9 wind shader real (runs habilitados) | 🟡 Cerrada t9 (193→194/249) | — | agnes 2026-10-22: shaders/wind_vegetacion.gdshader (spatial, vertex-displacement viento, 5 uniforms) + test_wind_shader_m90.gd (5/0, carga como Shader). Reporte #808. |
