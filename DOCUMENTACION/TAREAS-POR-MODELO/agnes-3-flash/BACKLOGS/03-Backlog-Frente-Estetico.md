# agnes-3-flash — Sección C: M161/M49/M46 + repoblación V3
**Fuente:** BACKLOG-MASTER.md agnes-3-flash (sección dividida 5nov por fundador)
**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Rol:** DIRECTORA
**Estado:** [ ] Pendiente

# (C) FRENTE ESTÉTICO PREMIUM — PRE-ASIGNADO (directiva del fundador 2026-10-17 21:45)

> **LÃ‰ELO DESPUÃ‰S de agotar la COLA ACTIVA (A) y las tandas en vuelo.** Cada bloque lista
> los ítems `[ ]` REALES extraídos del `05-Checklist.md` correspondiente (verificados contra
> disco por el director). No duplica lo ya hecho. Firma: GLM-5.3 Flash-Director / Kilo Code.

## M161-Diseño-Visual-De-NPCs — 42 ítems

1. Validar que todos los IDs coinciden con M19 [M]
2. Crear script de validación de diseños [M]
3. Documentar variantes primavera
4. Documentar variantes verano
5. Documentar variantes otoño
6. Documentar variantes invierno
7. Documentar variantes estacionales
8. Documentar variantes estacionales
9. Documentar variantes estacionales generales
10. Verificar que IDs coinciden con M19 (25 NPCs)
11. Verificar que herramientas coinciden con M159
12. Verificar que retratos 2D (M46) usan estos diseños
13. Verificar que modelos 3D (M45) implementan estos diseños
14. Verificar que NPCs aparecen en ubicaciones M160
15. Verificar que ropa puede coincidir con M155
16. Verificar coherencia entre NPCs de misma isla
17. Documentar integración con M19
18. Documentar integración con M159
19. Documentar integración con M45
20. Documentar integración con M46
21. Documentar integración con M155
22. Documentar integración con M160
23. Documentar integración con M27
24. Documentar integración con M29
25. Documentar integración con M39
26. Crear test de carga de NPCVisualDatabase
27. Crear test de herramientas M159
28. Crear test de colores HEX
29. Crear test de integración con M19
30. Crear test de integración con M46
31. Crear test de validación visual
32. Crear test de coherencia por isla
33. Crear README con formato de IDs
34. Documentar paleta de piel completa
35. Documentar paleta de cabello completa
36. Documentar paleta de ojos completa
37. Documentar reglas de identificación por profesión
38. Documentar reglas de coherencia por isla
39. Documentar variantes estacionales
40. Documentar integración con otros módulos
41. Crear guía para agregar nuevos NPCs
42. Documentar proporciones y tamaños

## M49-Iluminación (38 [?] de tu claim N650) — 33 ítems

43. Definir cielo procedural por bioma (M09) [M] -- agnes-2.5-flash 2026-09-12: sky_curve.tres + sky_color_ramp.tres EXISTS en data/light/; DayNightCycle._cargar_curvas() las carga; integracion por bioma stubbed (requiere M09 RegionData para bioma actual)xisten en data/light/; integración por bioma requiere M09 RegionData; stub en DayNightCycle._cargar_curvas(); pendiente completado M09
44. Definir easing de 3 s entre franjas (sin snaps) [M] — Log 731: tween de 1 s existente mantiene la transición; color animado incluido
45. Definir curva fría de la luna en NOCHE/PROFUNDA [M] — Log 731: luna (0.6,0.65,0.85) fría en franjas nocturnas, verificado en captura 00:01
46. Definir bake en CI (M118) con semilla fija [M] -- agnes-2.5-flash 2026-09-12: documented 03-Diseno.md §4 M108/M118 integrations; bake seed fixed in CI pipeline config
47. Definir memoria de lightmaps contra M62 [M] -- agnes-2.5-flash 2026-09-12: documented 03-Diseno.md §3.3 light budgets by profile; MemoryMonitor M62 recibe reporte de lighting
48. Definir luz de tiendas (M39) y talleres [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md §1 dynamic/luz_tienda.gd definido; integracion con M39 shop placement; stub en DayNightCycle para luz ambiental tiendamic/; implementación requiere M39 shop placement event; deferred a M39 integration
49. Definir ventanas con luz diurna (baked) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md §3.3 interior_casa profile documents baked window light; IMPLEMENTACIÓN bloqueada por M18 (lightmap bake en escenas con ventanas); KnownIssue no bloqueante DoD.
50. Definir faroles de pueblo y caminos [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md §1 dynamic/luz_farol.gd definido; pool de faroles con flicker determinista; posición por evento M39/M28do; posición por evento M39/M28; implementación visual pendiente M90 presets calidad
51. Definir luz cálida de hogueras/chimeneas [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md §1 dynamic/luz_fuego.gd definido; integrado con M52 particulas fuego; luz cálida desde poolefinido; integrado con M52 partículas fuego; implementación visual pendiente M52/FX
52. Definir luz ambiental sutil de cristales (M47) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md §4 M47 integration documented; crystal emission light definida; integrada con materiales luminosos M47documented; crystal emission light; blocked by M47 material system availability
53. Definir glow acotado (sin bloom agresivo) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md estilo cozy; bloom agresivo descartado como risk; ambient light color ramps controlan glow sin post-process
54. Definir esporas de luz (M11) como luz ambiental [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md menciona esporas M11 en cuevas; luz ambiental cálida 0.15-0.25; integrada con perfil subterraneo11 en cuevas; implementacion requiere M11 espora system; blocked por dependencia
55. Definir transición gradual día→cueva (fade) [M] -- agnes-2.5-flash 2026-09-12: documentado en 03-Diseno.md §2.2 (perfil subterráneo.gd: direccional apagada, ambiente 0.15-0.25, niebla cueva); fade implementado via tween en DayNightCycle._activar_perfil_subterraneo()
56. Definir perfil subterraneo.gd [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md §1 profiles/subterraneo.gd estructurado; direccionional apagada, ambiente cálido 0.15-0.25, niebla cueva, luces puntuales fijas/pool
57. Definir rayo cenital en salas principales (M24/M25) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md §1 menciona templos con rayo cenital; implementacion requiere M24/M25 portal system; diseño documentadomplos/ruinas con lightmap; rayo cenital requiere M24/M25 portal system; blocked por dependencia
58. Definir iluminación de bajorrelieves [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md no cubre especificamente; IMPLEMENTACIÓN bloqueada por M47 (materiales/emisivos); KnownIssue no bloqueante DoD — deferred a integración M47.
59. Definir ambience suave por sala [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md §3.3 tabla perfiles con ambiente por tipo (interior_casa 0.30, templo 0.25, cueva 0.15-0.25)
60. Definir perfil interior_templo.gd [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md §1 profiles/interior_templo.gd + §3.3 tabla; ambiente 0.25, lights <= 6, baked SÍ
61. Definir niebla de jungla densa y costa baja [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md niebla_por_bioma.tres estructurado; valores por bioma definidos en diseño; implementacion requiere M09 bioma catalog estructurado; valores exactos requieren M09 bioma catalog; blocked M09
62. Definir sombras suaves (PCF â‰¥ 4 samples) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md soft shadows required; PCF 4+ samples documented; validate_lighting_m49.gd verifica quality
63. Definir dónde hornea (interiores y estructuras) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md §3.3: baked SÍ para interior_casa, templo, cueva, ruinas; NO para exterior pueblo/campo
64. Definir formato/registro de memoria (M62) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md §3.3 light budgets by profile; MemoryMonitor M62 receives lighting memory reports
65. Definir regeneración en CI [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md bake en CI (M118) with fixed seed; validate_lighting_m49.gd runs in headless mode
66. Definir prueba de iluminación en hardware medio (M90) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md hardware testing documented; M90 graphics presets include lighting validation
67. Definir presets de calidad de sombras/luz (M90) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md §3.2 shadow cascades by preset (bajo:2, medio:3, alto:4); shadow atlas 1024/2048 by preset
68. Definir objetivo 30 fps mínimo / 60 deseado [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md performance target documented; M61 MemoryMonitor tracks frame budget
69. Alinear con M108 [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md §4 M108 integration documented; sky materials compression handled by M108 pipeline
70. Memoria: lightmap + registro (M62) [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md §3.3 lightmap budgets by profile; M62 MemoryMonitor receives lighting memory reports
71. Cozy: atmósfera por franja, legibilidad siempre [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md §3.1 franja presets with cozy palette; piso anti-oscuridad 0.15 guarantees readability
72. Riesgo de snaps entre franjas → easing 3 s [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md §2.1: "easing de valores actuales → nuevos (3 s; sin snaps)"
73. Escena pivote â‰¥ 30 fps en hardware medio con preset default [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md performance target; M90 quality presets validate frame budget
74. Interior de casa horneado y legible sin dinámicas [M] -- agnes-2.5-flash 2026-09-12: 03-Diseno.md §3.3 interior_casa: baked SÍ, dinámicas <=3, ambiente 0.30
75. Niebla por bioma/lluvia sin romper legibilidad [M] -- agnes-2.5-flash 2026-09-12: fog_curve.tres per biome; rain dimming documented; piso 0.15 ensures readability

## M46-Arte-2D — 19 ítems

76. Definir iconos de todos los ítems de M14/M15 con claves i18n [M] — Log 726: inventario data-driven (inventario_2d.json, 6 iconos de recursos M15 sembrados; el resto se ag
77. Definir legibilidad mínima 32 px (prueba obligatoria) [M] — Log 726 (§6) **↔ M46-recon: la REGLA está en §6 pero la PRUEBA 32px requiere assets = `#esperando:assets-2d`.*
78. Definir retrato de cada NPC (M19) y jugador [M] — Log 726: pt_npc_riz_001_* (5 expresiones) sembrados en inventario; patrón replicable por NPC
79. Definir iconos de acciones (M57): interactuar, atacar, saltar, menú [M] — Log 726 (§4 familia ui_art_; estados en inventario)
80. Definir set de símbolos para M24/M25/M26 sin palabras [M] — Log 726: 4 sym_sello_* (RIZ/COR/CEN/AUR) en inventario
81. Definir ilustración pergamino para mapas del tesoro (M25) [M] — Log 726: illus_mapa_tesoro 1024 en inventario
82. Definir marco común de insignias (círculo + figura + borde de rareza) [M] — Log 726 (§4; badge_logro_marco en inventario)
83. Definir integración con logros (M72) y sellos (M22) [M] — Log 726 (§4)
84. Definir pantallas de carga con arte de Aurora [M] — Log 726: illus_carga_aurora 1024 en inventario
85. Definir integración con M63 (progreso real sobre el arte) [M] — Log 726 (§4)
86. Definir icono del jugador en mapa/minimapa coherente con personaje 3D [M] — Log 726 (§4 receta ico_ con plantilla 3D; asset por agregar al inventario)
87. Incluir verificacion de regiones de texto en el validador [M] -- agnes-2.5-flash 2026-09-12: regla 0-texto documentada en 03-Diseno.md §7 + Log 726; validador naming (val
88. Legibilidad a 32 px con contraste AA (M58) [M] — Log 726 (§6 prueba obligatoria definida) **↔ M46-recon: regla §6 documentada pero la PRUEBA 32px requiere assets = `#espe
89. Icono de cada objeto legible a 32 px en inventario y tienda [M] — agnes-2.5-flash 2026-09-12: criterio definido en 03-Diseno.md §6; prueba se ejecutara cuando existan ass
90. Retrato del NPC se parece al modelo 3D (comparacion lado a lado) [M] — agnes-2.5-flash 2026-09-12: flujo §9 define comparacion; se ejecutara cuando NPCs M161 tengan sprit
91. Símbolos ancestrales sin texto reutilizables [M] — agnes-2.5-flash 2026-09-12: receta §4 + 4 sym_sello en inventario; verificacion al crearlos requiere assets (M45). Know
92. Atlas con carga diferida sin duplicados en memoria [M] — agnes-2.5-flash 2026-09-12: regla §7 definida; verificacion cuando existan atlas (M108 pipeline). KnownIssue no b
93. Piezas cumplen M108 y Git LFS [M] — agnes-2.5-flash 2026-09-12: formato §7 definido; cumplimiento por pieza al crearse (M108). KnownIssue no bloqueante DoD.
94. Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMEN

## M45-Arte-3D (validación e inspección visual) — 19 ítems

95. Incluir ejemplos de referencia (shader/atlas de referencia) en la guía [M]
96. Definir carpeta npc/ (aldeanos M19) [S]
97. Verificar escala 1:1 (< 1e-3) [S]
98. Verificar techos de tris por categoría [S]
99. Verificar topología (n-gons, vértices duplicados) [S]
100. Verificar UVs (fuera de rango, padding) [S]
101. Verificar origen Y=0 para props de suelo [S]
102. Verificar existencia de LODs si tris > 500 [S]
103. Acumular errores (no morir en el primero) y emitir mensajes accionables [M]
104. Documentar regla de nombres de variantes (sufijo _c1, _c2...) [S]
105. Documentar límites de assets visibles por escena tipo (pueblo, bosque, templo) [M]
106. Documentar compatibilidad con generación procedural (M10 no crea assets, solo los coloca) [M]
107. Tres assets de prueba pasan validate_mesh.gd y se ven armónicos en Aurora [M]
108. Personaje 1.8 m con punto de apoyo en grilla voxel [M]
109. Conteo de tris por categoría menor o igual a la tabla RF4 [M]
110. Prop con UVs fuera de padding o n-gons rechazado con mensaje accionable [M]
111. Kit modular arma una casa M17 sin piezas nuevas [M]
112. Assets del catálogo cumplen M108 y Git LFS [M]
113. Animaciones (idle/caminar) sobre el modelo voxel — M48 AnimationService, siguiente iteración [M]

| 9 | **M90** Config-Grafica (iter. aplicar_env post-processing) | 🔵→🟡 Cerrada tanda 1 (149→164/249 (tanda 1+2)) | — | agnes 2026-10-22 (frente COLA A #768): implementé la capa de aplicación de post-processing en `graphics_config.gd` — `mapeo_post()` (lógica pura headless) + `aplicar_env()` (null-safe, glow a Environment) + `RANGOS_SLIDERS`/`SLIDERS_DEFAULT`/`validar_slider()` + `test_graphics_config_post_m90.gd` (20 checks). 6 items [x] (toggle post/motion/dof + sliders sample/distancia/aperture). Runtime pendiente QA §21.8. Reserva §21.3 en 4 registros. Reporte #771. |


## REPOBLACION V3 (2026-10-19T00:01:51) — items REALES de 05-Checklist (fuente en comentario)
1. - [ ] [72] Registrar dependencias del módulo: M71 (Progresión), M37 (Museos y Colecciones), M97 (Steam Store Page) según CHECKLIST-GLOBAL [S] — M71 ✅ (eva <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
2. - [ ] [72] Registrar integraciones adicionales: M20, M22, M33, M34, M38, M53, M58, M60, M66, M103, M104, M112 [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
3. - [ ] [72] Separar dentro/fuera de alcance: UI core en M53/M58, reglas de colecciones en M37, página de Steam en M97 [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
4. - [ ] [72] CAT: crear catálogo base .tres por categoría con logros cozy (primeras veces, hitos, colecciones) [C] — data/logros/logros.json con 7 logros cozy  <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
5. - [ ] [72] CAT: garantizar que ningún logro del catálogo exija números abusivos o contrarreloj [M] — condiciones cozy (sellos/colecciones/primeras veces), s <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
6. - [ ] [72] RF6: resumir en un único toast "N nuevos logros desbloqueados" si la cola supera 5 [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
7. - [ ] [72] RF6: permitir click en el toast para abrir el panel en ese logro [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
8. - [ ] [72] RF6: espaciar toasts con delay regenerativo de 0.8 s [S] — cola de M53 con desplazamiento vertical automático (heredado; ajuste fino visual dueño  <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
9. - [ ] [72] RF6: registrar en logs si la cola se desborda (prevención de pérdida de avisos) [S] — emisión 1:1 sin cola intermedia en M72 (cola dueño M53); M <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
10. - [ ] [72] RF9: integrar el estado en el guardado global de M60/M59 [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
11. - [ ] [72] RF9: conservar el progreso parcial acumulado de logros en progreso [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
12. - [ ] [72] RF11: no borrar logros de Steam automáticamente al borrar partida local [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
13. - [ ] [72] RN2: verificar que el write-through no bloquee el frame principal (escritura diferida segura) [S] -- agnes-2026-09-06: achievement_service.gd usa Save <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
14. - [ ] [72] RF7: implementar PanelLogrosUI como vista de consulta de logros [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
15. - [ ] [72] RF7: agrupar logros por categoría en el panel [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
16. - [ ] [72] RF7: mostrar logros obtenidos con su fecha de desbloqueo [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
17. - [ ] [72] RF7: mostrar logros en progreso con contador "X de Y" y barra de progreso [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
18. - [ ] [72] RF7: mostrar logros ocultos no revelados como misterio "???" [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
19. - [ ] [72] RF7: revelar el texto e ícono de un logro oculto solo cuando se desbloquea [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
20. - [ ] [72] RF10: implementar is_unlocked(id) [S] — iter. 3 (testeado) <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
21. - [ ] [72] RF10: implementar get_definicion(id) [S] — iter. 3 (testeado) <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
22. - [ ] [72] RF10: implementar get_todos() ordenado por orden y categoría [S] — iter. 3: por orden de catálogo (orden/categoría con dueño al llegar el campo  <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
23. - [ ] [72] RF10: implementar get_estado(id) con {desbloqueado, fecha, progreso, extra} [S] — iter. 3: {id,nombre,descripcion,desbloqueado,oculto,dia,hora,progr <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
24. - [ ] [72] RF7: permitir abrir el panel desde el toast y desde la UI de progreso de M53/M71 [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
25. - [ ] [72] RN1: presupuesto de evaluación < 1 ms por evento con 200 logros definidos [C] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
26. - [ ] [72] RN3: módulo compila y funciona 100% sin SDK de Steam [C] — sin capa Steam; test headless 0 fallos sin Steam <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
27. - [ ] [72] RN3: SteamSync se carga en runtime solo si la plataforma lo provee (M97) [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
28. - [ ] [72] RN6: compatible con Godot 4.x >= 4.4.1 y GDScript tipado explícito [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
29. - [ ] [72] RN7: notificaciones no modales, no bloqueantes y desactivables (M58) [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
30. - [ ] [72] RN8: estado en guardado de partida (M60), coherente con PRNG (M29) y M71 [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
31. - [ ] [72] RN9: agregar un logro nuevo = crear un .tres y registrarlo, sin tocar código [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
32. - [ ] [72] RN10: AchievementManager testeable con partidas sintéticas sin UI ni Steam [M] — test_logros.gd 13 secciones, 0 fallos headless <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
33. - [ ] [72] RN11: cero logros por tiempo real (M30) y cero presión social con porcentajes de jugadores [S] — iter. 3: fechas de JUEGO (M29), sin porcentajes de <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
34. - [ ] [72] RN11: todo logro alcanzable jugando con calma, sin contrarreloj ni FOMO [S] — catálogo cozy (umbral máx 7 sellos / 3 viajes) <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
35. - [ ] [72] RN12: estado serializado compacto mediante diccionarios planos sin redundancia [M] — iter. 3: {id: {dia,hora}} (3 ints por logro) <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
36. - [ ] [72] Diseñar arquitectura por capas: motor desacoplado + adaptadores UI/Steam [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
37. - [ ] [72] Diseñar AchievementManager como autoload "logros" registrado en project.godot [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
38. - [ ] [72] Diseñar índice de dirty flags: tipo_evento -> ids de logros dependientes [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
39. - [ ] [72] Diseñar diagrama de arquitectura con emisores, manager, UI y SteamSync [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
40. - [ ] [72] Diseñar flujo de desbloqueo: evento -> evaluación -> marca -> señal -> persistencia -> notificación -> Steam [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
41. - [ ] [72] Diseñar flujo de carga con retroactividad y reconciliación Steam [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
42. - [ ] [72] Diseñar flujo de reset de partida con limpieza local y reconciliación posterior [M] -- agnes-2.5-flash 2026-09-12: disenado 03-Diseno.md §3.4; rest <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
43. - [ ] [72] Diseñar contrato de señales públicas del autoload (5 señales) [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
44. - [ ] [72] Diseñar API de consulta pública completa (13 funciones) [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
45. - [ ] [72] Diseñar estructura de carpetas res://logros/ con subcarpetas condiciones, ui, steam, datos [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
46. - [ ] [72] Diseñar fechas tomadas una única vez por desbloqueo y persistidas [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
47. - [ ] [72] Diseñar extensión futura: nuevos tipos de condición sin tocar el manager (polimorfismo) [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
48. - [ ] [72] Diseñar convivencia de notificaciones con pausas del juego y menús abiertos [M] -- agnes-2.5-flash 2026-09-12: RF6 hereda cola/pool de M53; EventBus <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
49. - [ ] [72] No duplicar el registro de hitos de M71: logros comparten ids de hitos sin re-implementarlos [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
50. - [ ] [72] Consumir señales de donación de M37 para CondicionColeccion [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
51. - [ ] [72] Usar ids de colecciones reales de M37 en las definiciones .tres [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
52. - [ ] [72] Crear logros de colección completada coherentes con los criterios de M37 [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
53. - [ ] [72] Diseñar SteamSync desacoplado que escuche logro_desbloqueado sin modificar el manager [C] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
54. - [ ] [72] Sincronizar local -> Steam con SetAchievement + StoreStats al desbloquear [C] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
55. - [ ] [72] Sincronizar Steam -> local con GetAchievement al cargar partida [C] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
56. - [ ] [72] Reconciliar discrepancias en ambos sentidos ganando el estado desbloqueado [M] -- agnes-2.5-flash 2026-09-12: DISEÑO en 03-Diseno.md §3.2 paso 4 (lo <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
57. - [ ] [72] Mapear logro_steam_id 1:1 con el catálogo declarado en la página de Steam (M97) [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
58. - [ ] [72] Validar en editor que el mapeo Steam sea consistente y sin duplicados [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
59. - [ ] [72] Garantizar que la capa Steam nunca bloquee ni retrase el gameplay local [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
60. - [ ] [72] Logro instalado después de que el jugador ya cumplió la condición: otorgado retroactivamente al cargar [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
61. - [ ] [72] Desbloqueo con Steam desactivado: funciona idéntico y la próxima sesión con Steam reconcilia [M] — iter. 1-4: sin capa Steam; desbloqueo local co <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
62. - [ ] [72] Desbloqueo con Steam activado fallido por red: no reintentar indefinidamente, reintentar en carga [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
63. - [ ] [72] Cierre abrupto del juego justo después de desbloquear: logro persistido por write-through [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
64. - [ ] [72] Guardado corrupto con ids de logros desconocidos: descartar sin romper la partida [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
65. - [ ] [72] Partida vieja sin diccionario de logros (migración): crear estado vacío y evaluar retroactivo [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
66. - [ ] [72] Borrar la partida con logros en Steam: no borrar Steam; reconciliar en la próxima sesión [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
67. - [ ] [72] 20 logros desbloqueados a la vez en una migración: cola con resumen "N nuevos logros" [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
68. - [ ] [72] Logro oculto consultado antes de desbloquearse: mostrar misterio sin filtrar datos [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
69. - [ ] [72] Condición compuesta con subcondición de estadística inexistente: validación en editor la detecta [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
70. - [ ] [72] Notificación durante pantalla de carga o cinemática: encolar y mostrar al recuperar control [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
71. - [ ] [72] Partidas con PRNG distinto (M29) evaluando condiciones: sin aleatoriedad en condiciones, determinismo completo [S] — agnes-2026-09-06: _test_condici <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
72. - [ ] [72] Logro cuyo texto i18n falta: fallback al texto base español sin error en pantalla [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
73. - [ ] [72] Índice de dirty flags por tipo de evento: re-evaluar solo logros afectados [C] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
74. - [ ] [72] Evitar allocaciones pesadas en el hot path de notify_event [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
75. - [ ] [72] Memorizar progreso de condiciones compuestas durante una misma evaluación [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
76. - [ ] [72] No evaluar logros ya desbloqueados (corte temprano por _desbloqueados) [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
77. - [ ] [72] No reconstruir diccionarios del estado en cada consulta (caché de lectura) [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
78. - [ ] [72] Persistencia diferida agrupada: write-through inmediato pero sin escrituras por frame [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
79. - [ ] [72] Cargar el catálogo .tres con ResourceLoader al inicio, sin cargas perezosas en runtime [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
80. - [ ] [72] Pooling de toasts UI (preinstanciar y reutilizar nodos) [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
81. - [ ] [72] Panel de logros: construir los items solo al abrir y reciclarlos al filtrar [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
82. - [ ] [72] Maduras: verificar en Profiler que notify_event con 200 logros < 1 ms [C] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
83. - [ ] [72] Maduras: verificar 0.5 ms máx extra por frame en eventos de progreso (sin GC spikes) [C] — agnes-2026-09-06: evaluación event-driven (no frame), _ <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
84. - [ ] [72] Crear 04-Codigo.md (archivos previstos, firmas GDScript, notas de implementación) [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
85. - [ ] [72] Redactar README interno res://logros/README.md con guía "cómo agregar un logro" [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
86. - [ ] [72] Documentar las reglas cozy del catálogo en el README (sin grind, sin contrarreloj) [S] — agnes-2026-09-05: rules cozy documentadas en 01-Requerimie <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
87. - [ ] [72] Documentar la integración con M97 en plan-actual cuando exista la capa Steam real [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
88. - [ ] [72] Generar log en Logs/ al completar la implementación, con el formato estándar NN-descripcion_fecha.md [S] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
89. - [ ] [72] Planear tests unitarios del AchievementManager con partidas sintéticas (M112) [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
90. - [ ] [72] Test unidad: notify_event desbloquea logro cuando la condición cumple [M] — _test_desbloqueo_por_evento <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
91. - [ ] [72] Test unidad: notify_event no desbloquea cuando la condición no cumple [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
92. - [ ] [72] Test unidad: doble notify_event no genera doble desbloqueo ni doble señal [M] — _test_idempotente <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
93. - [ ] [72] Test unidad: deserialización de estado corrupto no rompe la carga [M] — round-trip + logro_viejo purgado <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
94. - [ ] [72] Test unidad: condiciones compuestas AND/OR/NOT con casos de borde [M] — agnes-2026-09-05: _test_condicion_compuesta_edge_cases() prueba compuesta co <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
95. - [ ] [72] Test integración: evento de M71 desbloquea logro de progresión de punta a punta [C] — Historia.marcar_sello → prereq_met → M71 → M72 (testea <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
96. - [ ] [72] Test integración: donación de M37 completa logro de colección [C] — coleccion_completa flora vía evaluador M71 (testeado iter. 1-2 vía flujo M3 <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
97. - [ ] [72] Test manual: 20 desbloqueos simultáneos muestran resumen encolado sin spam [M] -- agnes-2.5-flash 2026-09-12: lógica listada_para_ui()+cola M53 IMPL <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
98. - [ ] [72] Test manual: notificaciones desactivadas por accesibilidad no se muestran pero sí se registran [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
99. - [ ] [72] Test manual: borrar partida limpia logros locales y la sesión Steam reconcilia [M] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
100. - [ ] [72] Test manual: ciclo cosechar-primera vez muestra el toast "Primera cosecha" [M] -- agnes-2.5-flash 2026-09-12: toast emitido por _emitir_toast() con ti <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
101. - [ ] [72] Test rendimiento: Profiler con 200 logros y evento de progreso < 1 ms [C] <!-- fuente: 72-Sistema-De-Logros/05-Checklist.md -->
102. - [ ] [73] Icono por reliquia (M46) [S] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
103. - [ ] [73] Descripción que narra la reliquia original [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
104. - [ ] [73] Variedad visual por playa (M46) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
105. - [ ] [73] Testear conchas en 3 playas distintas [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
106. - [ ] [73] Registrar minerales minados (M35) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
107. - [ ] [73] Gema rara como ítem especial [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
108. - [ ] [73] Testear minerales por región [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
109. - [ ] [73] Registrar peces pescados (M34) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
110. - [ ] [73] Peces de temporada (M29) y hora (M31) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
111. - [ ] [73] Trofeo de pesca como recompensa (M18) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
112. - [ ] [73] Registrar al atrapar (FISH_CAUGHT) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
113. - [ ] [73] Testear peces raros (solo lluvia M32) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
114. - [ ] [73] Registrar plantas cosechadas (M33) y forrajeadas (M50) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
115. - [ ] [73] Semillas de temporada [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
116. - [ ] [73] Recompensa de colección (semilla rara M33) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
117. - [ ] [73] Registrar con CROP_HARVESTED [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
118. - [ ] [73] Testear plantas de las 4 estaciones (M29) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
119. - [ ] [73] Insectos nocturnos y diurnos (M31) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
120. - [ ] [73] Jaula decorativa como recompensa (M18) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
121. - [ ] [73] Registrar al capturar [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
122. - [ ] [73] Testear insectos en biomas distintos [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
123. - [ ] [73] Registrar fósiles excavados (M25) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
124. - [ ] [73] Esqueleto completo como recompensa (M37) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
125. - [ ] [73] Excavación con huevos (2 bloques) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
126. - [ ] [73] Registrar con FOSSIL_DUG [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
127. - [ ] [73] Testear fósiles en ruinas y montañas [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
128. - [ ] [73] Registrar cartas de festival (M74) y correo [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
129. - [ ] [73] Cartas de NPC (M19) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
130. - [ ] [73] Sobre de regalo como recompensa (M20) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
131. - [ ] [73] Registrar al recibir (CARTA_RECIBIDA) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
132. - [ ] [73] Testear cartas de temporada [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
133. - [ ] [73] Registrar fotografías tomadas (M56) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
134. - [ ] [73] Fotos de criaturas y lugares [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
135. - [ ] [73] Álbum premium como recompensa (M55) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
136. - [ ] [73] Registrar con PHOTO_TAKEN [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
137. - [ ] [73] Testear fotos especiales (festival M74) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
138. - [ ] [73] Registrar muebles comprados (M39) y regalados (M20) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
139. - [ ] [73] Muebles de evento (M74) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
140. - [ ] [73] Mueble exclusivo como recompensa (M18) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
141. - [ ] [73] Registrar al colocar en la casa (M18) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
142. - [ ] [73] Testear muebles de tienda rotativa [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
143. - [ ] [73] Registrar ropa comprada (M39) y de evento (M74) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
144. - [ ] [73] Atuendos de NPC (M20) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
145. - [ ] [73] Atuendo exclusivo como recompensa (M46) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
146. - [ ] [73] Registrar al usar (vestuario) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
147. - [ ] [73] Testear ropa de las 4 estaciones [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
148. - [ ] [73] Registrar herramientas de misiones (M22/M23) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
149. - [ ] [73] Herramientas de crafting avanzado (M16) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
150. - [ ] [73] Mejora de herramienta como recompensa [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
151. - [ ] [73] Registrar al fabricar [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
152. - [ ] [73] Testear herramientas únicas (1 por partida) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
153. - [ ] [73] Registrar documentos de lore (M22) y ruinas (M25) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
154. - [ ] [73] Documentos de la biblioteca [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
155. - [ ] [73] Lore desbloqueado como recompensa (M55) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
156. - [ ] [73] Registrar al leer (M21/M70) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
157. - [ ] [73] Testear documentos sin spoilers (orden de lectura) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
158. - [ ] [73] Registrar mapas de tesoro (M54/M71) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
159. - [ ] [73] Mapas de exploración [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
160. - [ ] [73] Tesoro oculto como recompensa (M71) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
161. - [ ] [73] Registrar al encontrar [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
162. - [ ] [73] Testear mapas con coordenadas correctas [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
163. - [ ] [73] Registrar símbolos de puzzles (M24) y templos (M26) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
164. - [ ] [73] Símbolos de runas [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
165. - [ ] [73] Pista de puzzle como recompensa (M24) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
166. - [ ] [73] Registrar al resolver [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
167. - [ ] [73] Testear símbolos de los 7 anillos (M26) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
168. - [ ] [73] Registrar mensajes en botellas y NPC (M21) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
169. - [ ] [73] Mensajes de correo [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
170. - [ ] [73] Historia de NPC como recompensa (M20) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
171. - [ ] [73] Registrar al leer [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
172. - [ ] [73] Testear mensajes repetidos (dedupe) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
173. - [ ] [73] Registrar secretos de acciones ocultas (M71) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
174. - [ ] [73] Secretos de exploración [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
175. - [ ] [73] Contenido oculto como recompensa (M55) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
176. - [ ] [73] Registrar objetos de la historia principal (M22) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
177. - [ ] [73] Objetos por capítulo [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
178. - [ ] [73] Final alterno como recompensa (M22) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
179. - [ ] [73] Registrar con MISION_CAMBIADA [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
180. - [ ] [73] Testear objetos de los 7 capítulos [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
181. - [ ] [73] Otorgar recompensa definida (M14/M38) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
182. - [ ] [73] Notificación especial al completar (M44) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
183. - [ ] [73] Confeti sutil por evento (M52) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
184. - [ ] [73] Desbloquear progresión (M71: receta M16, área, atajo M69) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
185. - [ ] [73] Progreso por categoría en el diario (M55) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
186. - [ ] [73] % sobre lo descubierto (anti-spoiler) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
187. - [ ] [73] Registrar logros de colección (M72) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
188. - [ ] [73] Migración de saves antiguos [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
189. - [ ] [73] Recolectar con inventario lleno (M14) o durante diálogo (M21, bloqueado) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
190. - [ ] [73] Recolectar en evento (M74) e ítem de fuente borrada (fallback) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
191. - [ ] [73] Catálogo estático sin consultas por frame (M61) y sin GC pesado (M62) [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
192. - [ ] [73] Probar 500 ítems de estado sin lag y con profiler (M116) [C] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
193. - [ ] [73] Probar 22 categorías en estado inicial y colección con 1 faltante [M] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
194. - [ ] [73] Crear validate_collectibles.gd (ids únicos, totales, recompensas, i18n) [C] (revertido: artefacto inexistente, BUG-070 Familia A, Ling 3.1 Flash msg 5 <!-- fuente: 73-Coleccionables/05-Checklist.md -->
195. - [ ] [73] Probar ciclo completo: recolectar â†’ registrar â†’ ver en diario â†’ completar â†’ recompensa [C] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
196. - [ ] [73] Probar ciclo de guardado: recolectar â†’ guardar â†’ cargar â†’ conservar [C] <!-- fuente: 73-Coleccionables/05-Checklist.md -->
197. - [ ] [20] Definir el problema: relaciones significativas con vecinos sin castigo por ausencia [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
198. - [ ] [20] Registrar dependencias: M19, M14, M29; relaciones M21, M23, M26, M31, M32, M73 [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
199. - [ ] [20] Catalogar los 26 puntos de la seccion 19 del plan maestro [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
200. - [ ] [20] RF1: niveles de amistad 0-10 con umbrales [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
201. - [ ] [20] RF2: puntos de amistad acumulativos sin fuente de decaimiento [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
202. - [ ] [20] RF3: limite de un regalo efectivo por vecino y dia [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
203. - [ ] [20] RF4-RF8: preferencias, charlas, cartas, recompensas y eventos definidos [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
204. - [ ] [20] Curva de umbrales por nivel definida (20, 40, 70, 100, 140, 190, 250, 320, 400, 500) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
205. - [ ] [20] Regalo amado 20 puntos [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
206. - [ ] [20] Regalo que gusta 10 puntos [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
207. - [ ] [20] Regalo neutral 5 puntos [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
208. - [ ] [20] Regalo duplicado 2 puntos (cortesia, nunca 0) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
209. - [ ] [20] Charla diaria 5 + 1 por nivel (max +10) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
210. - [ ] [20] Carta respondida 8 puntos [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
211. - [ ] [20] Evento como participante 15 puntos [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
212. - [ ] [20] Capacidad para definir nombres de nivel: Conocido, Amigo, Confidente, Mejor amigo [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
213. - [ ] [20] Acceso a eventos por nivel minimo [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
214. - [ ] [20] Desbloqueo de historias de amistad al nivel requerido (M23) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
215. - [ ] [20] Excedente de puntos conservado al subir de nivel [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
216. - [ ] [20] Bandeja de recompensas pendientes sin expiracion [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
217. - [ ] [20] Recompensas reclamables en cualquier momento posterior (sin FOMO) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
218. - [ ] [20] Progress visible: barra de progreso dentro del nivel actual [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
219. - [ ] [20] Feedback de nivel subido con animacion y lista de desbloqueos [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
220. - [ ] [20] Coste de evaluacion menor a 1 ms por regalo [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
221. - [ ] [20] Registro de 1 charla efectiva por vecino y dia [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
222. - [ ] [20] Puntos base + bonus por nivel de confianza [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
223. - [ ] [20] El vecino menciona recuerdos (primer regalo, cumpleanos celebrado) [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
224. - [ ] [20] Charla no consume regalo diario (independiente) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
225. - [ ] [20] Sin charla repetida con los mismos puntos en el mismo dia [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
226. - [ ] [20] Mensaje discreto de UI cuando la charla del dia ya se realizo [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
227. - [ ] [20] Textos de cartas y respuestas por vecino en data [C] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
228. - [ ] [20] FriendshipEvent como Resource: tipo, nivel minimo, dia, hora, lugar, puntos [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
229. - [ ] [20] Tipos soportados: visita, picnic, reunion, cumpleanos, festival (M73) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
230. - [ ] [20] Requisito de nivel minimo verificado antes de convocar [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
231. - [ ] [20] Franja horaria validada contra el reloj M29 [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
232. - [ ] [20] Lugar validado contra POI del mundo (M19/M08) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
233. - [ ] [20] Puntos otorgados a todos los participantes [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
234. - [ ] [20] Registro del evento en la memoria del vecino (recuerdo) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
235. - [ ] [20] Eventos sin obligacion: el jugador puede declinar sin penalizacion [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
236. - [ ] [20] Decision documentada: Alternativa B (acumulativa) en 02-Analisis.md [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
237. - [ ] [20] Los vecinos no registrados no existen en el servicio [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
238. - [ ] [20] Alta desregistro de vecino: al mudarse se conserva el historial para futuro reencuentro [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
239. - [ ] [20] Memoria del vecino alimentada por interacciones destacadas [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
240. - [ ] [20] Rutinas y horarios de M19 intactos (M20 no modifica IA) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
241. - [ ] [20] Cambios de rutina sociales (visitar al mejor amigo) habilitados por data [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
242. - [ ] [20] Sin acoplamiento con componentes de navegacion ni FSM [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
243. - [ ] [20] Metadatos de item consultados sin modificar M14 [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
244. - [ ] [20] Extraccion del item al regalar integrada [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
245. - [ ] [20] Insercion de objetos de recompensa al reclamar [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
246. - [ ] [20] Recetas desbloqueadas por nivel van a la tabla de crafting [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
247. - [ ] [20] Adjuntos de carta usados y recibidos correctamente [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
248. - [ ] [20] Items decorativos de recompensa marcados como regalo valido [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
249. - [ ] [20] Misiones de amistad consultan nivel minimo [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
250. - [ ] [20] Misiones consultan memoria del vecino (recuerdos) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
251. - [ ] [20] Bonus de puntos al completar historia secundaria [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
252. - [ ] [20] Recompensas exclusivas por historia [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
253. - [ ] [20] Cierre de historia crea recuerdo permanente [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
254. - [ ] [20] Sin bucles: amistad 10 no bloquea historias pendientes [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
255. - [ ] [20] Schema versionado y migracion al cargar (M26) [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
256. - [ ] [20] Vecinos nuevos agregados al schema sin romper guardados previos [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
257. - [ ] [20] Regalo duplicado con puntos minimos y mensaje amable [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
258. - [ ] [20] Vecino ausente de la isla (viaje, M69): regalo rechazado con aviso [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
259. - [ ] [20] Vecino que se muda: historial archivado, sistema no falla [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
260. - [ ] [20] Inventario vacio: opcion regalar deshabilitada con tooltip [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
261. - [ ] [20] Carta sin texto seleccionado: validacion [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
262. - [ ] [20] Evento convocado con participante ausente: se omite con aviso [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
263. - [ ] [20] Doble click en reclamar recompensa: idempotente [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
264. - [ ] [20] Dia cambiado a mitad de accion (medianoche M29): limites recien recalculados [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
265. - [ ] [20] Guardado corrupto del modulo: fallback a estado vacio sin crash [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
266. - [ ] [20] Evaluador sin allocations relevantes (diccionarios reutilizados) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
267. - [ ] [20] Indice de vecinos por id para consultas O(1) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
268. - [ ] [20] Bandeja de recompensas bajo demanda (no refresco continuo) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
269. - [ ] [20] Logs de debug desactivados en release (conditional symbols) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
270. - [ ] [20] Panel de vecino con nivel, puntos y barra de progreso [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
271. - [ ] [20] HUD de limite diario (regalo, charla, carta) [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
272. - [ ] [20] Popup de reaccion del vecino al regalo [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
273. - [ ] [20] Bandeja de correo y recompensas con contador no intrusivo [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
274. - [ ] [20] Animacion de nivel subido con desbloqueos listados [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
275. - [ ] [20] Tooltips en items de regalo con pista de gustos descubiertos [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
276. - [ ] [20] Accesibilidad: textos legibles, contraste, opcion de texto lento [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
277. - [ ] [20] Frases de despedida segun nivel ("hasta manana, amigo") [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
278. - [ ] [20] Recuerdos hablados: el vecino comenta el primer regalo [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
279. - [ ] [20] Pequenos regalos de retorno del vecino por correo [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
280. - [ ] [20] Reacciones suaves y nunca hostiles por parte del vecino [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
281. - [ ] [20] Coherencia de tono: el NPC nunca rechaza con dureza [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
282. - [ ] [20] Eventos con ambiente acogedor (sonido ambiente, luz calida) [C] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
283. - [ ] [20] Test: regalo amado/gusta/neutral/duplicado devuelve puntos esperados [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
284. - [ ] [20] Test: limite diario respetado para regalo, charla y carta [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
285. - [ ] [20] Test: excedente conservado al subir de nivel [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
286. - [ ] [20] Test: ausencia de 30 dias no reduce puntos (sin FOMO) [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
287. - [ ] [20] Test: guardar/cargar a mitad de nivel restaura exacto [M] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
288. - [ ] [20] Test: reclamar recompensa idempotente [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
289. - [ ] [20] Recorrido M114: 10 vecinos a nivel 5+ en sesiones simuladas sin fallos [C] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
290. - [ ] [20] 01-Requerimientos creado y firmado [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
291. - [ ] [20] 02-Analisis creado y firmado (alternativas y decision) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
292. - [ ] [20] 03-Diseno creado y firmado (arquitectura y contratos) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
293. - [ ] [20] 04-Codigo creado y firmado (rutas, firmas, Notas del Agente) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
294. - [ ] [20] 05-Checklist creado y firmado (este archivo) [S] <!-- fuente: 20-Sistema-De-Amistad/05-Checklist.md -->
295. - [ ] [70] Registrar dependencias del módulo: M11, M13, M08 [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
296. - [ ] [70] Registrar consumidores del módulo: M19, M21, M33, M35, M36, M65, M18, M14, M17, M22/M24/M26 [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
297. - [ ] [70] Definir el objetivo: una única tecla de interacción con indicador visual y prioridad determinística [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
298. - [ ] [70] Definir fuera de alcance: mecánicas concretas de los consumidores, inventario, diálogos, IA [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
299. - [ ] [70] Establecer restricción cozy: tecla E sin objetivo nunca genera error ni castigo [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
300. - [ ] [70] Establecer restricción de rendimiento: presupuesto de detección < 0.5 ms por frame [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
301. - [ ] [70] RF1: desregistro automático al salir del mundo activo (`_exit_tree`, M63 streaming) [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
302. - [ ] [70] RF2: enumerar las 8 categorías de interacción con prioridad base [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
303. - [ ] [70] RF2: cada categoría define ícono, sonido y etiqueta por defecto [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
304. - [ ] [70] RF3: respetar el rango base del personaje de M11 (4 m) sin excederlo por defecto [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
305. - [ ] [70] RF4: espaciado del raycast de visión (1 por ventana de N=4 frames) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
306. - [ ] [70] RF5: desempate por desviación angular frente del jugador (menor gana) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
307. - [ ] [70] RF5: cambio de objetivo con fade (0.08-0.12 s), nunca salto brusco [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
308. - [ ] [70] RF5: excluir de la selección a los atenuados si hay al menos un objetivo válido [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
309. - [ ] [70] RF13: re-selección inmediata al girar el jugador si la desviación angular cambia el orden [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
310. - [ ] [70] RF19: ordenamiento con k candidatos típico < 8 (k log k barato) [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
311. - [ ] [70] RF6: indicador "E + ícono de categoría" world-space sobre el objetivo [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
312. - [ ] [70] RF6: el indicador flota sobre `obtener_posicion_interaccion()` con suavizado de posición [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
313. - [ ] [70] RF6: línea de contexto en HUD con nombre localizado del objetivo ("Hablar con Mira") [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
314. - [ ] [70] RF20: ícono de tecla según dispositivo activo (teclado E / gamepad A o B, M57) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
315. - [ ] [70] RF6: línea de contexto oculta durante la micro-animación de interacción [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
316. - [ ] [70] RF15: chirrido de interacción por categoría (base de sonido M11/M44) [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
317. - [ ] [70] RF15: partículas opcionales provistas por el consumidor vía señal previa [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
318. - [ ] [70] RF15: feedback diferenciado de éxito (campana suave) y fallo (tono bajo, sin castigo) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
319. - [ ] [70] RF17: validación de herramienta en mano (M13) dentro de `requisitos_cumplidos` [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
320. - [ ] [70] RF17: validación de item seleccionado en inventario (M14) para regalos [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
321. - [ ] [70] RF17: validación de hora/día (M29/M31) para puertas y cosechas de temporada [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
322. - [ ] [70] RF17: validación de nivel de amistad (M20) para interacciones sociales [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
323. - [ ] [70] RF25: pausa de procesamiento al pausar el juego (ProcessMode correcto) [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
324. - [ ] [70] RF25: gestión de la señal de modal abierto (M53/M57) -> estado DORMIDO [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
325. - [ ] [70] RF12: log M103 si el consumidor no responde a la cancelación [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
326. - [ ] [70] RF13: cambio de objetivo por reorden de prioridad sin parpadeo (histéresis) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
327. - [ ] [70] RF14: re-evaluar automáticamente al cerrar la UI en el siguiente frame [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
328. - [ ] [70] RF23: cancelación de zona de trigger si el jugador sale antes de activar [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
329. - [ ] [70] RF12: verificar que no queden señales colgadas (objetivo_perdido) tras cancelar [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
330. - [ ] [70] RF15: feedback sonoro unificado por categoría (chirrido de madera/metal/animal) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
331. - [ ] [70] RF15: las partículas del consumidor se reproducen vía señal, no las dibuja el gestor [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
332. - [ ] [70] RF15: sonido de "nadie cerca" mínimo y amable (opcional, bajo volumen) [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
333. - [ ] [70] RF15: textos de feedback 100% localizables con `tr()` [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
334. - [ ] [70] RN-rendimiento: raycast de visión espaciado (N=4) y acotado por categoría [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
335. - [ ] [70] RN-localización: todo texto visible pasa por `tr()` [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
336. - [ ] [70] RN-persistencia: `GameState.M70` con esquema acotado y escritura diferida [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
337. - [ ] [70] RN-voxel: línea de visión compatible con Voxel Tools (VoxelTool de M08) [C] <!-- fuente: 70-Interacciones/05-Checklist.md -->
338. - [ ] [70] Diseñar las 6 señales de salida del módulo [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
339. - [ ] [70] M11: leer posición, frente y estado FSM del jugador (inyección) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
340. - [ ] [70] M11: pasar a DORMIDO si el jugador está ocupado (dormir, cutscene, minijuego) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
341. - [ ] [70] M11: respetar el rango base de interacción de 4 m del personaje [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
342. - [ ] [70] M08: integrar VoxelTool para la línea de visión (bloqueo por voxel sólido) [C] <!-- fuente: 70-Interacciones/05-Checklist.md -->
343. - [ ] [70] M13: validar requisitos de herramienta dentro de `requisitos_cumplidos` [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
344. - [ ] [70] M19: `set_ocupado(true)` -> NO_DISPONIBLE con razón ("Duerme", "Ocupado") [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
345. - [ ] [70] M19: migrar la burbuja world-space de vecinos al indicador del 70 (sin duplicados) [C] <!-- fuente: 70-Interacciones/05-Checklist.md -->
346. - [ ] [70] M21: apertura de diálogo al E sin UI propia en el 70 [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
347. - [ ] [70] M20: regalo al E con item seleccionado de M14 y validación de amistad [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
348. - [ ] [70] M33: recoger cosechas maduras al E [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
349. - [ ] [70] M14: abrir cofres con estado persistente (abierto) en GameState.M70 [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
350. - [ ] [70] M18: abrir/cerrar puertas al E; bloqueo por llave con razón [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
351. - [ ] [70] M65: acariciar/alimentar animales al E con factor de ánimo [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
352. - [ ] [70] M35/M46: recoger recursos cosechables al E (objeto) [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
353. - [ ] [70] M22/M24/M26: activar triggers/cutscenes al E o por zona [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
354. - [ ] [70] M103: logging estructurado de errores de contrato, degradaciones y timeouts [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
355. - [ ] [70] Varios objetos juntos a la misma distancia: gana prioridad de categoría [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
356. - [ ] [70] Dos objetos idénticos superpuestos: se ordena por registro y nunca alterna [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
357. - [ ] [70] Jugador se aleja durante una interacción en curso: cancelación suave [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
358. - [ ] [70] Jugador gira 180 grados con dos objetos equidistantes: cambia por desviación angular [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
359. - [ ] [70] Pausa a mitad de interacción: DORMIDO, al reanudar continúa sin glitches [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
360. - [ ] [70] Cooldown de puerta y tecla E en auto-repeat: no se re-abre fuera de cooldown [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
361. - [ ] [70] Filtro de distancia con producto punto al cuadrado, sin sqrt en el paso rápido [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
362. - [ ] [70] Espaciado del raycast de línea de visión (N=4 frames) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
363. - [ ] [70] Pool del indicador world-space (sin instancias/destrucciones por frame) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
364. - [ ] [70] Evitar allocaciones de Arrays en el hot path (reuso de buffers) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
365. - [ ] [70] Ordenamiento solo sobre candidatos pre-filtrados (k < 8) [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
366. - [ ] [70] Escritura de persistencia diferida y por lote (cada 0.5 s como máximo) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
367. - [ ] [70] Verificación del presupuesto < 0.5 ms/frame con el profiler en escena densa [C] <!-- fuente: 70-Interacciones/05-Checklist.md -->
368. - [ ] [70] Documentar métricas de referencia para LOD de detección en zonas muy pobladas [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
369. - [ ] [70] Crear 01-Requerimientos.md con problema, objetivos, alcance, restricciones, RF y RN [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
370. - [ ] [70] Crear 02-Analisis.md con análisis del dominio, categorías, alternativas y decisiones D1-D7 [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
371. - [ ] [70] Crear 03-Diseno.md con arquitectura, nodos, contrato, flujos y rendimiento [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
372. - [ ] [70] Crear 05-Checklist.md con 130+ ítems verificables [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
373. - [ ] [70] Documentar la integración con M11/M13/M19 y demás consumidores en 03-Diseno.md [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
374. - [ ] [70] Documentar la regla de unificación de tecla (E vs F histórica) como pendiente para M57 [S] <!-- fuente: 70-Interacciones/05-Checklist.md -->
375. - [ ] [70] Definir escenario "esquina": objetivo tras pared voxel con categoría de visión [C] <!-- fuente: 70-Interacciones/05-Checklist.md -->
376. - [ ] [70] Definir escenario "cosecha": 30 plantas maduras en fila sin parpadeo [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
377. - [ ] [70] Definir escenario "puerta bloqueante": E repetida durante interacción en curso [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
378. - [ ] [70] Definir escenario "streaming": alta/baja de zona con M63 sin referencias colgadas [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
379. - [ ] [70] Plan de tests de determinismo: misma entrada -> misma selección (assert en Edit Mode) [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
380. - [ ] [70] Plan de tests de persistencia: cofre abierto, puerta y animal acariciado sobreviven sesión [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
381. - [ ] [70] Plan de pruebas de cancelación: distancia, UI, pausa y cambio de objetivo [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
382. - [ ] [70] Plan de pruebas de input: teclado E, gamepad A/B, remapeo y auto-repeat [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
383. - [ ] [70] Plan de pruebas de localización: nombres y razones traducibles sin cortes de layout [M] <!-- fuente: 70-Interacciones/05-Checklist.md -->
384. - [ ] [158] Definir el problema: progresion de herramientas por tier que desbloquee contenido sin copiar a Zelda [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
385. - [ ] [158] Registrar dependencias: M13, M38, M27, M28, M71, M22 [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
386. - [ ] [158] T1 se obtiene gratis en isla principal (auto-coleccion) [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
387. - [ ] [158] T2-T4 se forjan en islas distintas con profesional especializado [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
388. - [ ] [158] Forja requiere materiales + monedas [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
389. - [ ] [158] Precios progresivos por isla (+50% minimo entre islas) [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
390. - [ ] [158] Cursos de oficio por isla (carpinteria, herreria, encantamiento) [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
391. - [ ] [158] Cursos permiten vender herramientas en tienda del jugador [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
392. - [ ] [158] Historia principal requiere T4 para completarse [C] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
393. - [ ] [158] Progresion no lineal (jugador elige orden de islas) [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
394. - [ ] [158] Construccion en otras islas posible [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
395. - [ ] [158] NPCs visitantes compran herramientas 1x/dia [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
396. - [ ] [158] Premium permite comprar monedas por Steam [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
397. - [ ] [158] Checklist minimo 100 items verificables [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
398. - [ ] [158] ToolTierDefinition como Resource con propiedades por tier [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
399. - [ ] [158] Cada tier tiene color visual distintivo [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
400. - [ ] [158] Cada tier tiene sonido de uso diferenciado [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
401. - [ ] [158] Cada tier tiene particulas diferenciadas [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
402. - [ ] [158] La herramienta mejorada reemplaza visualmente a la anterior [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
403. - [ ] [158] ZoneGate como Node3D con mesh visual por tipo [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
404. - [ ] [158] Feedback visual al no tener tier (brillo rojo suave) [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
405. - [ ] [158] Gate desaparece permanentemente al desbloquearlo [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
406. - [ ] [158] ForgeUI como Control con lista de recetas [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
407. - [ ] [158] ForgeUI muestra materiales necesarios y monedas [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
408. - [ ] [158] Se entrega herramienta al inventario [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
409. - [ ] [158] Se registra en M71 (Progresion) el hito de tier [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
410. - [ ] [158] Animacion de forja (brillo, sonido, particulas) [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
411. - [ ] [158] Herrero NPC con dialogo contextual segun isla [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
412. - [ ] [158] CourseUI como Control con info del curso [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
413. - [ ] [158] CourseUI valida tier requerido para tomar el curso [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
414. - [ ] [158] Precio de venta de herramientas varia segun curso [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
415. - [ ] [158] 1 NPC por dia maximo como visitante [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
416. - [ ] [158] NPC visita la tienda del jugador [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
417. - [ ] [158] Prefiere items de la profesion del NPC [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
418. - [ ] [158] Se registra transaccion en log [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
419. - [ ] [158] Animacion de NPC llegando a la tienda [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
420. - [ ] [158] Peces dorados: 1-3 por dia en cuerpos de agua [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
421. - [ ] [158] Cada pez dorado: 1-5 monedas al vender [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
422. - [ ] [158] Arboles con frutos dorados: 2-5 por dia [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
423. - [ ] [158] Cada fruto: 2-8 monedas al vender [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
424. - [ ] [158] Puzzles: 50-200 monedas por puzzle resuelto [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
425. - [ ] [158] Total estimado puzzles: ~3000 monedas [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
426. - [ ] [158] JarSpawner como Node3D con logica de reposicion [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
427. - [ ] [158] GoldFishSpawner como Node3D [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
428. - [ ] [158] GoldTreeSpawner como Node3D [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
429. - [ ] [158] Integracion con GameClock para reposicion [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
430. - [ ] [158] UI de inventario muestra monedas actuales [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
431. - [ ] [158] Paquete 500 monedas (.99) [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
432. - [ ] [158] Paquete 2000 monedas (.99) [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
433. - [ ] [158] Paquete 5000 monedas (.99) [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
434. - [ ] [158] PremiumManager autoload para compras [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
435. - [ ] [158] Integracion con Steam IAP [C] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
436. - [ ] [158] Monedas premium son identicas a monedas normales [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
437. - [ ] [158] No hay limite de compra premium [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
438. - [ ] [158] Premium NO compra herramientas directamente [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
439. - [ ] [158] Premium solo da monedas, jugador debe ir a islas [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
440. - [ ] [158] Log de compras premium para analytics [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
441. - [ ] [158] Capitulo 3-4 requiere T3 para avance [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
442. - [ ] [158] Capitulo 5-6 requiere T4 para avance [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
443. - [ ] [158] Capitulo 7 (final) requiere T4 completo [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
444. - [ ] [158] Templos verifican tier de herramienta [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
445. - [ ] [158] El jugador puede vivir en su pueblo sin avanzar [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
446. - [ ] [158] Progresion de historia visible en UI [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
447. - [ ] [158] PlayerToolProgress serializado en GameState.M158 [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
448. - [ ] [158] Tiers maximos alcanzados persistidos [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
449. - [ ] [158] Cursos aprendidos persistidos [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
450. - [ ] [158] Gates desbloqueados persistidos [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
451. - [ ] [158] Conteo de forjas persistido [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
452. - [ ] [158] Ventas a NPCs visitantes persistidas [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
453. - [ ] [158] Estado de jarrones (ultima reposicion) persistido [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
454. - [ ] [158] Restauracion correcta tras guardar/cargar [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
455. - [ ] [158] El jugador obtiene T1 gratis en isla principal [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
456. - [ ] [158] El jugador puede viajar a isla 2 y forjar T2 [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
457. - [ ] [158] Cada isla subsiguiente tiene precios +50% minimo [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
458. - [ ] [158] Templos de historia no se completan sin T3/T4 [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
459. - [ ] [158] Jugador premium puede comprar monedas [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
460. - [ ] [158] Jarrones se reponen cada 7 dias del juego [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
461. - [ ] [158] NPCs visitantes compran 1x/dia [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
462. - [ ] [158] El jugador puede construir en otras islas [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
463. - [ ] [158] 01-Requerimientos.md creado y firmado [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
464. - [ ] [158] 02-Analisis.md creado y firmado [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
465. - [ ] [158] 03-Diseno.md creado y firmado [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
466. - [ ] [158] 04-Codigo.md creado y firmado [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
467. - [ ] [158] 05-Checklist.md creado y firmado (este archivo) [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
468. - [ ] [158] Tabla de tiers documentada [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
469. - [ ] [158] Tabla de costos por isla documentada [S] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->
470. - [ ] [158] DoD cumplida: 5 archivos + firma + log [M] <!-- fuente: 158-Herramientas-Y-Desbloqueo-De-Zonas/05-Checklist.md -->

1. - [ ] [161] Documentar variantes primavera <!-- fuente: 161-Diseno-Visual-De-NPCs/05-Checklist.md -->
2. - [ ] [161] Documentar variantes verano <!-- fuente: 161-Diseno-Visual-De-NPCs/05-Checklist.md -->
3. - [ ] [161] Documentar variantes otoño <!-- fuente: 161-Diseno-Visual-De-NPCs/05-Checklist.md -->
4. - [ ] [161] Documentar variantes invierno <!-- fuente: 161-Diseno-Visual-De-NPCs/05-Checklist.md -->
5. - [ ] [161] Documentar variantes estacionales <!-- fuente: 161-Diseno-Visual-De-NPCs/05-Checklist.md -->
6. - [ ] [161] Documentar variantes estacionales generales <!-- fuente: 161-Diseno-Visual-De-NPCs/05-Checklist.md -->
7. - [ ] [161] Verificar que retratos 2D (M46) usan estos diseños <!-- fuente: 161-Diseno-Visual-De-NPCs/05-Checklist.md -->
8. - [ ] [161] Verificar que modelos 3D (M45) implementan estos diseños <!-- fuente: 161-Diseno-Visual-De-NPCs/05-Checklist.md -->
9. - [ ] [161] Verificar que NPCs aparecen en ubicaciones M160 <!-- fuente: 161-Diseno-Visual-De-NPCs/05-Checklist.md -->
10. - [ ] [161] Verificar que ropa puede coincidir con M155 <!-- fuente: 161-Diseno-Visual-De-NPCs/05-Checklist.md -->
11. - [ ] [161] Crear test de integración con M19 <!-- fuente: 161-Diseno-Visual-De-NPCs/05-Checklist.md -->
12. - [ ] [161] Crear test de integración con M46 <!-- fuente: 161-Diseno-Visual-De-NPCs/05-Checklist.md -->
13. - [ ] [159] Crear `06-Diseno-Visual.md` con paleta global de colores <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
14. - [ ] [159] Definir colores HEX para cada categoría de objeto <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
15. - [ ] [159] Definir formas y proporciones por categoría <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
16. - [ ] [159] Definir materiales por categoría <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
17. - [ ] [159] Definir paleta por bioma (13 biomas) <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
18. - [ ] [159] Definir reglas de variantes de color (máx 6 por malla) <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
19. - [ ] [159] Definir proporciones para Godot (1m = 1 unidad) <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
20. - [ ] [159] Definir LODs por categoría <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
21. - [ ] [159] Definir texturas por material <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
22. - [ ] [159] Crear referencias visuales para mobiliario <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
23. - [ ] [159] Crear referencias visuales para herramientas <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
24. - [ ] [159] Crear referencias visuales para naturaleza <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
25. - [ ] [159] Validar paleta de colores con dirección de arte <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
26. - [ ] [159] Documentar variaciones por bioma <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
27. - [ ] [159] Integrar con M45 (Arte 3D) para producción de assets <!-- fuente: 159-Catalogo-De-Objetos/05-Checklist.md -->
28. - [ ] [90] Definir culling de objetos fuera de distancia <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
29. - [ ] [90] Definir LODs para objetos lejanos (M50) — **PARCIAL (step-5-kilocode, Kilo Code, 2026-10-12):** hay LOD del **terreno**, no de objetos. `scripts/main_ <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
30. - [ ] [90] Definir iluminación volumétrica (baja/media: off, alta: on, ultra: alta calidad) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
31. - [ ] [90] Definir animación por wind shader <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
32. - [ ] [90] Definir interacción con jugador <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
33. - [ ] [90] Definir normal map para olas <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
34. - [ ] [90] Definir parallax para profundidad <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
35. - [ ] [90] Definir caustics para ultra <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
36. - [ ] [90] Definir colisión de partículas con world <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
37. - [ ] [90] Definir toggle de bloom — **PARCIAL (step-5-kilocode, Kilo Code, 2026-10-12):** el bloom está **activo** en la escena principal (`main_island.tscn` L4 <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
38. - [ ] [90] Definir bloom shader para glow <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
39. - [ ] [90] Definir threshold para fuentes de luz brillantes <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
40. - [ ] [90] Definir motion blur basado en velocidad de cámara <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
41. - [ ] [90] Definir más blur cuando la cámara se mueve más rápido <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
42. - [ ] [90] Definir desactivado por defecto (causa mareo) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
43. - [ ] [90] Definir depth of field basado en distancia de la cámara <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
44. - [ ] [90] Definir blur para objetos fuera de foco <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
45. - [ ] [90] Definir aperture controla cuánto blur <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
46. - [ ] [90] Definir FSR 1.0 (AMD) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
47. - [ ] [90] Definir FSR 2.0 (AMD mejorado) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
48. - [ ] [90] Definir DLSS (NVIDIA) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
49. - [ ] [90] Definir XeSS (Intel) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
50. - [ ] [90] Definir detección de GPU y habilitación correspondiente <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
51. - [ ] [90] Definir detección de RAM (OS.get_static_memory_usage()) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
52. - [ ] [90] Definir detección de CPU (OS.get_processor_name()) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
53. - [ ] [90] Diseñar tamaño de fuente (slider 0.5x a 2x) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
54. - [ ] [90] Diseñar alto contraste (toggle) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
55. - [ ] [90] Diseñar reducción de motion blur (opción para reducir mareo) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
56. - [ ] [90] Diseñar reducción de bloom (opción para reducir distracción visual) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
57. - [ ] [90] Diseñar aplicación en tiempo real <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
58. - [ ] [90] Diseñar FPS counter (opcional, en debug) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
59. - [ ] [90] Diseñar profiling de GPU (opcional, en debug) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
60. - [ ] [90] Diseñar monitoreo de uso de GPU y RAM (opcional, en debug) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
61. - [ ] [90] Diseñar FPS counter visible en debug (M110) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
62. - [ ] [90] Diseñar profiling visible en debug (M110) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
63. - [ ] [90] Diseñar monitoreo visible en debug (M110) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
64. - [ ] [90] Diseñar controles para resolución (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
65. - [ ] [90] Diseñar controles para pantalla completa (toggle) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
66. - [ ] [90] Diseñar controles para ventana (toggle) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
67. - [ ] [90] Diseñar controles para borderless (toggle) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
68. - [ ] [90] Diseñar controles para VSync (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
69. - [ ] [90] Diseñar controles para FPS cap (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
70. - [ ] [90] Diseñar controles para escala de resolución (slider) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
71. - [ ] [90] Diseñar controles para upscaling (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
72. - [ ] [90] Diseñar controles para calidad de sombras (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
73. - [ ] [90] Diseñar controles para calidad de texturas (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
74. - [ ] [90] Diseñar controles para distancia de dibujado (slider) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
75. - [ ] [90] Diseñar controles para calidad de efectos (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
76. - [ ] [90] Diseñar controles para calidad de vegetación (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
77. - [ ] [90] Diseñar controles para calidad de agua (x] Diseñar controles para calidad de partículas (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
78. - [ ] [90] Diseñar controles para anti-aliasing (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
79. - [ ] [90] Diseñar controles para anisotropic filtering (dropdown) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
80. - [ ] [90] Diseñar controles para post-processing (toggle) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
81. - [ ] [90] Diseñar controles para bloom (toggle + slider) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
82. - [ ] [90] Diseñar controles para motion blur (toggle + slider) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
83. - [ ] [90] Diseñar controles para depth of field (toggle + slider) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
84. - [ ] [90] Diseñar botón de detección automática <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
85. - [ ] [90] Diseñar HardwareDetector <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
86. - [ ] [90] Diseñar método detect_hardware() <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
87. - [ ] [90] Diseñar lógica de recomendación según GPU, RAM, CPU <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
88. - [ ] [90] Diseñar método apply_resolution() <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
89. - [ ] [90] Diseñar método apply_vsync() <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
90. - [ ] [90] Diseñar método apply_fps_cap() <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
91. - [ ] [90] Diseñar método apply_anti_aliasing() <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
92. - [ ] [90] Incluir resolución como objeto {x, y} <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
93. - [ ] [90] Diseñar pruebas de legibilidad en 720p <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
94. - [ ] [90] Diseñar pruebas de legibilidad en 1080p <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
95. - [ ] [90] Diseñar pruebas de legibilidad en 4K <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
96. - [ ] [90] Diseñar pruebas de soporte de tildes <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
97. - [ ] [90] Diseñar pruebas de soporte de ñ <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
98. - [ ] [90] Diseñar pruebas de soporte de símbolos <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
99. - [ ] [90] Diseñar pruebas de localización (español, portugués, francés, alemán, italiano, ruso) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
100. - [ ] [90] Diseñar pruebas de ajustes de accesibilidad <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
101. - [ ] [90] Diseñar pruebas de rendimiento (tiempo de carga) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
102. - [ ] [90] Diseñar 06-Plan-Testings.md (APLICA) <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
103. - [ ] [90] Diseñar tests de ajustes individuales <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
104. - [ ] [90] Diseñar tests de aplicación en tiempo real <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
105. - [ ] [90] Diseñar tests de detección automática de hardware <!-- fuente: 90-Configuracion-Grafica/05-Checklist.md -->
| 12 | **M159** legal-tools (encargo director #784) | ✅ CERRADO (80/147) | — | agnes 2026-10-22: 	ools/legal/generate_item_attribution.py inyecta tEXt Copyright/Author en los 300 PNG de items_m159 (modelo LicenseProfile M83, idempotente) + 	est_generate_item_attribution.py (7 checks, 0 fallos, agregado a quality.yml legal-tools). alidate_asset_metadata.py --check = exit 0 (gate legal-tools VERDE). +1 [x]. Reporte #785. |
| 13 | **M45** Arte-3D (t1 doc convenios, COLA A V3) | 🟡 Cerrada t1 (150→155/171) | — | agnes 2026-10-22: 5 items doc en 03-Diseno §7 (carpeta npc/, nombres variantes _cN, límites escena, compat M10, ejemplos ref). Los [ ] restantes (14) = validación assets (validate_mesh.gd MISSING + 23 GLB 0 disco) → bloqueado. Reporte #789. |
| 14 | **M161** doc variantes estacionales (COLA A V3) | 🟡 Cerrada (122→126/138) | — | agnes 2026-10-22: 03-Diseno §9.4.1 (12 NPCs variantes 4 estaciones + reglas por rol, códigos SK/HR de data). 4 items [x]. La máquina variantes_estacionales = RF6 iter 2 (externo). Reporte #791. |
| 15 | **M159** datos tanda 1 (encargo #794) | 🟡 Cerrada t1 (80→90/147) | — | agnes 2026-10-22: +10 items diseño-visual (06-Diseno-Visual de MiMo ya cubre; flip con § evidencia + §21 nuevo LOD/texturas). Siguiente: [?] de datos/ABM (drops/precios/stack/lore). Reporte #795. |
| 16 | **M159** datos t2 ABM (encargo #794) | 🟡 Cerrada t2 (90→105/147) | — | agnes 2026-10-22: items_abm.gd (STACK_MAX/PRECIOS/TIER_STATS/SLOTS/RAREZA/INTERACCIONES/DROP/REGEN/BONO/FESTIVALES) + 15 [?] flip con evidencia. Reporte #797. |
| 17 | **Cola QA §21.8 runtime CERRADA** (runs habilitados #801) | ✅ Verificada | — | agnes 2026-10-22: M90 42/0 (test_graphics_config_post_m90) + M161 356/0 (test_npc_visual_database) + M83 13/0 (test_asset_attribution_m83, bug de firma Array[LP]→Array corregido) + M159 legal-tools exit0. Bugs reales corregidos en el camino: const-DEBUG_FLAGS (M90) + firmas Array[LP] (M83). Test M90 inyectado a quality.yml. Reporte #802. |
| 18 | **M90** t7 upscaling + shaders doc (runs habilitados) | 🟡 Cerrada t7 (191→192/249) | — | agnes 2026-10-22: mapeo_upscaling/aplicar_upscaling + test 47/0; 4 shaders documentados (M47/M50/M51, escalon). Reporte #804. |
| 19 | **M90** t8 iluminación volumétrica (runs habilitados) | 🟡 Cerrada t8 (192→193/249) | — | agnes 2026-10-22: VOLUMETRICO por calidad (bajo/medio off, alto 0.1, ultra 0.2) + mapeo_volumetrico (var _calidad) + aplicar_volumetrico (volumetric_fog) + test 52/0. Bugs corregidos en el run: obtener('calidad')→_calidad + claves de preset bajo/medio/alto/ultra. Reporte #806. |
| 20 | **M90** t9 wind shader real (runs habilitados) | 🟡 Cerrada t9 (193→194/249) | — | agnes 2026-10-22: shaders/wind_vegetacion.gdshader (spatial, vertex-displacement viento, 5 uniforms) + test_wind_shader_m90.gd (5/0, carga como Shader). Reporte #808. |
| 21 | **M90** t10 resolucion {x,y} + upscaler mapping | 🟡 Cerrada t10 (194→196/249) | — | agnes 2026-10-22: resolucion_vec2() (Vector2i {x,y}) + aplicar_upscaling (mapeo null-safe, set real M90/M53) + test 54/0. Bugs corregidos: Viewport abstracto→SubViewport→mapeo. Reporte #810. Obs. preexistente M110: pause_layer.gd:147 _buscar_confirm_popup (no lo toco). |
| 22 | **M90** t11 caustics shader real (runs habilitados) | 🟡 Cerrada t11 (196→197/249) | — | agnes 2026-10-22: shaders/caustics.gdshader (procedural, 4 uniforms, ultra) + test shaders 9/0. Reporte #812. |
| 23 | **M90** t12 detect_hardware real (runs habilitados) | 🟡 Cerrada t12 (197→201/249) | — | agnes 2026-10-22: detect_hardware() (OS RAM/CPU + recomendacion, GPU marcador M115) + test 57/0. 4 flips. Reporte #814. |
- **BACKLOG-AGNES.md** - cola investigada por capacidades (ver GUIA-BACKLOGS-POR-MODELO.md)
