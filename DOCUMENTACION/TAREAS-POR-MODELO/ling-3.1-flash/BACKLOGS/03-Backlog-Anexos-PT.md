# Ling-3.1-Flash — Anexos PT: ejecución kit 115 + mediciones riel 255 + ronda 24 + gemelo 248
**Fuente:** BACKLOG-MASTER.md Ling-3.1-Flash (sección dividida 4nov por fundador)
**Modelo:** Ling-3.1-Flash (inclusionAI / Ant Group)
**Plataforma:** WorkBuddy
**Estado:** Histórico

## REPOBLACION V3 (2026-10-19T00:01:42) — items REALES de 05-Checklist (fuente en comentario)
1. - [ ] [142] Definir minutas firmadas de cada decisión del comité [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
2. - [ ] [142] Definir freeze firmado de features al inicio de RC [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
3. - [ ] [142] Definir política: solo hotfixes P0/P1 aprobados entran al RC [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
4. - [ ] [142] Definir rama de hotfix `hotfix/rc-N` con test de regresión obligatorio (M112) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
5. - [ ] [142] Definir re-etiquetado `rc-2`, `rc-3` ante cada hotfix [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
6. - [ ] [142] Definir DiffAudit en CI (contra `beta-rc-candidate`) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
7. - [ ] [142] Definir fallo de CI si hay diffs no autorizados [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
8. - [ ] [142] Definir ventana de 4 semanas máx. para la fase [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
9. - [ ] [142] Definir manifest de contenido inamovible (hash del inventario Beta) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
10. - [ ] [142] Definir prohibición de nuevo contenido (misiones, ítems, eventos) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
11. - [ ] [142] Definir excepción de contenido solo si es bug crítico de progresión [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
12. - [ ] [142] Definir registro de cambios de contenido en el manifest [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
13. - [ ] [142] Definir verificación semanal del estado del freeze [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
14. - [ ] [142] Definir definición de crash/bloqueo (P0) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
15. - [ ] [142] Definir definición de pérdida de progreso (P1) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
16. - [ ] [142] Definir definición de P2 (menor, con workaround) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
17. - [ ] [142] Definir flujo de ticket P0/P1 → comité → hotfix [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
18. - [ ] [142] Definir hotfix con test de regresión previo al merge (M112) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
19. - [ ] [142] Definir postmortem obligatorio por hotfix [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
20. - [ ] [142] Definir cola de P2 documentada para la primera actualización post-lanzamiento [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
21. - [ ] [142] Definir métrica de hotfixes por semana [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
22. - [ ] [142] Definir símbolos de crash accesibles al handler (M105) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
23. - [ ] [142] Definir comprobación de assets de desarrollo (texturas/audio placeholder) fuera [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
24. - [ ] [142] Definir prueba de instalación desde cero en cada plataforma (VM limpia) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
25. - [ ] [142] Definir verificación de arranque sin errores tras instalación limpia [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
26. - [ ] [142] Definir prueba de desinstalación/reinstalación sin residuos [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
27. - [ ] [142] Definir verificación de carpetas de datos correctas por plataforma [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
28. - [ ] [142] Definir prueba de instalación en disco con sín caracteres especiales [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
29. - [ ] [142] Definir prueba de actualización Beta → RC sin pérdida de datos [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
30. - [ ] [142] Definir prueba de actualización de RC-1 a RC-2 (delta) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
31. - [ ] [142] Definir verificación de versión de save reportada como compatible [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
32. - [ ] [142] Definir registro de logs de actualización (éxito/fallo) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
33. - [ ] [142] Definir rollback seguro si la actualización falla [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
34. - [ ] [142] Definir prueba de actualización con red cortada a mitad [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
35. - [ ] [142] Definir migración de save v3.x a versión RC sin pérdidas [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
36. - [ ] [142] Definir carga de saves de todas las fases previas (pre-Alpha a Beta) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
37. - [ ] [142] Definir prueba de save corrupto → backup y recuperación (M66) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
38. - [ ] [142] Definir reporte de versión de save en el manifiesto del usuario [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
39. - [ ] [142] Definir verificación de que no hay saves con flags de dev activos [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
40. - [ ] [142] Definir métrica de errores de save en piloto [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
41. - [ ] [142] Definir 30 ciclos de sincronización con latencia simulada [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
42. - [ ] [142] Definir resolución de conflicto "último ganador + backup" [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
43. - [ ] [142] Definir validación de integridad antes de aplicar el save cloud [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
44. - [ ] [142] Definir desconexión/reconexión de red durante sincronización [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
45. - [ ] [142] Definir batalla de saves entre dos dispositivos (prueba) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
46. - [ ] [142] Definir reporte de errores de cloud sin reviente de UI [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
47. - [ ] [142] Definir telemetría de tamaño y frecuencia de sync [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
48. - [ ] [142] Definir matriz completa hitos → logros [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
49. - [ ] [142] Definir desbloqueo local de logros sin dependencia de red [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
50. - [ ] [142] Definir verificación de persistencia de logros tras reinicio [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
51. - [ ] [142] Definir verificación de notificación de logro visible [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
52. - [ ] [142] Definir logros retroactivos para saves Beta [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
53. - [ ] [142] Definir prueba de plataforma sin login (sin cuenta) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
54. - [ ] [142] Definir 100% de logros alcanzables en juego limpio [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
55. - [ ] [142] Definir matriz de 6 idiomas × pantallas clave [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
56. - [ ] [142] Definir verificación de desbordes de texto por idioma (UI) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
57. - [ ] [142] Definir verificación de traducción de logros y store (M149) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
58. - [ ] [142] Definir verificación de fechas/números por idioma [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
59. - [ ] [142] Definir fallback a EN sin claves rotas [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
60. - [ ] [142] Definir perf de ruta fija 20 min en hardware mínimo [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
61. - [ ] [142] Definir perf de ruta fija 20 min en recomendado [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
62. - [ ] [142] Definir memoria dentro de M62 en las 6 islas [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
63. - [ ] [142] Definir tiempos de carga/streaming dentro de M63 [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
64. - [ ] [142] Definir FPS p99 ≥ objetivo en sesiones largas (60+ min) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
65. - [ ] [142] Definir batching/draw calls finales por zona [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
66. - [ ] [142] Definir informe de rendimiento del piloto (percentiles reales) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
67. - [ ] [142] Definir comparativa final mínima vs recomendada [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
68. - [ ] [142] Definir objetivo crash rate < 0.5% de sesiones [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
69. - [ ] [142] Definir piloto de 1000 sesiones con invitados [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
70. - [ ] [142] Definir handler de crashes con stacktrace y símbolos (M105) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
71. - [ ] [142] Definir triaje de crash stacks conocidos vs nuevos [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
72. - [ ] [142] Definir hotfix dirigido si crash rate no baja a objetivo [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
73. - [ ] [142] Definir reporte final de crash rate del piloto [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
74. - [ ] [142] Definir verificación de que los crashes no bloquean saves/cloud [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
75. - [ ] [142] Definir revisión de políticas de contenido (violencia/edad) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
76. - [ ] [142] Definir prueba de certificación: instalación, actualización, saves [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
77. - [ ] [142] Definir aprobación firmada por responsable de plataforma [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
78. - [ ] [142] Definir registro de desvíos y excepciones aprobadas [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
79. - [ ] [142] Definir preparación de los paquetes de certificación (textos, archivos) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
80. - [ ] [142] Definir términos de servicio final [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
81. - [ ] [142] Definir política de privacidad final (cloud, telemetría) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
82. - [ ] [142] Definir atribuciones de assets de terceros completas [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
83. - [ ] [142] Definir clasificación etaria (ESRB/PEGI) con documentos [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
84. - [ ] [142] Definir contratos de voz/música con derechos despejados (M41-M44) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
85. - [ ] [142] Definir revisión legal firmada [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
86. - [ ] [142] Definir verificación de no contenido ofensivo por región (M147) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
87. - [ ] [142] Definir store page publicada-ready (textos, capturas, tags) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
88. - [ ] [142] Definir tráiler final montado y aprobado [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
89. - [ ] [142] Definir comunicado de prensa final en 2 idiomas [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
90. - [ ] [142] Definir kit de medios (capturas HQ, logos, b-roll) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
91. - [ ] [142] Definir plan de contenido de redes para día 0 y semana 1 [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
92. - [ ] [142] Definir lista de reviewers/streamers contactados [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
93. - [ ] [142] Definir verificación de disponibilidad de la página (fecha oculta hasta día 0) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
94. - [ ] [142] Definir canales de soporte (foros, Discord, correo) activos [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
95. - [ ] [142] Definir FAQ publicada (instalación, saves, plataformas, idiomas) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
96. - [ ] [142] Definir SLA de respuesta definido (24 h hábiles) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
97. - [ ] [142] Definir triaje diario de soporte en lanzamiento [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
98. - [ ] [142] Definir camino de escalado de bugs de soporte a tracker [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
99. - [ ] [142] Definir backup de canales (quién cubre a quién) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
100. - [ ] [142] Definir cronograma día 0 con horas locales por región [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
101. - [ ] [142] Definir responsables de cada tarea del día 0 [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
102. - [ ] [142] Definir runbook de incidentes (crash masivo, store caída, cloud) [M] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
103. - [ ] [142] Definir holgura de 48 h ante imprevistos [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
104. - [ ] [142] Definir aprobación final del plan por el equipo [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
105. - [ ] [142] Definir verificación de accesos de plataforma (quién puede publicar) [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->
106. - [ ] [142] Definir respaldo de credenciales sin compartir secretos en repo [S] <!-- fuente: 142-Release-Candidate/05-Checklist.md -->

1. - [ ] [108] Vincular el problema con la optimización obligatoria del proyecto (AGENTS.md 21.4.8) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
2. - [ ] [108] Definir el alcance: models 3D, texturas, materiales, audio, fuentes, UI y paletas voxel [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
3. - [ ] [108] Excluir del alcance: el terreno voxel generado en runtime por Voxel Tools (M08) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
4. - [ ] [108] Registrar dependencias: M45 (Arte 3D) y M78 (Legal PI), con relaciones a M04, M08, M47, M48, M61, M62, M63, M86, M107, M111, M112, M118 [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
5. - [ ] [108] Establecer que M45 puede estar sin documentar y se referencia por su catálogo de entregables [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
6. - [ ] [108] Fijar los criterios de aceptación del módulo (7 criterios del 01-Requerimientos) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
7. - [ ] [108] RF2: admitir gltf + bin en staging para edición y diffs legibles [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
8. - [ ] [108] RF2: definir PNG como textura lossless con canal alfa [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
9. - [ ] [108] RF2: definir WebP como textura lossy sin alfa dura [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
10. - [ ] [108] RF2: definir OGG Vorbis como audio estándar (música, ambiente, SFX) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
11. - [ ] [108] RF2: admitir WAV solo para loops cortos de UI/feedback ≤ 5 s [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
12. - [ ] [108] RF3: prohibir FBX como entrada directa y documentar la ruta de conversión Blender → glTF [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
13. - [ ] [108] RF3: prohibir TGA, BMP y GIF como texturas de entrada [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
14. - [ ] [108] RF3: prohibir MP3, M4A y MIDI como audio de entrada [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
15. - [ ] [108] Definir TTF/OTF con licencia libre verificada como fuente (M88: Nunito, Fredoka One) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
16. - [ ] [108] Exigir potencias de 2 en texturas para compresión VRAM eficiente [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
17. - [ ] [108] Fijar límites de resolución por tipo: props ≤ 2048², atlas ≤ 4096², iconos ≤ 256² [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
18. - [ ] [108] Definir paletas voxel como PNG atlas con mipmaps off y filtrado off (anti-bleeding M08) [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
19. - [ ] [108] RF4: definir prefijos obligatorios por tipo: mdl_, tex_, mat_, aud_, anim_, fnt_, ui_, vox_ [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
20. - [ ] [108] RF4: usar snake_case en minúsculas sin espacios, tildes, ñ ni caracteres especiales [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
21. - [ ] [108] RF4: definir la secuencia {prefijo}_{entidad}_{variante}_{sufijo} [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
22. - [ ] [108] RF4: numerar variantes en dos dígitos (_01) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
23. - [ ] [108] RF4: usar sufijos de mapa: _albedo, _normal, _roughness, _emission, _height [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
24. - [ ] [108] RF4: garantizar que el id nunca se reutiliza tras un retiro [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
25. - [ ] [108] Definir la convención opcional de respaldo _lod0/_lod1/_lod2 para LODs manuales [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
26. - [ ] [108] RF5: definir preset de textura 3D: mipmaps on, VRAM Compressed, high_quality, filter on, repeat off [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
27. - [ ] [108] RF5: definir preset de textura UI: mipmaps off, VRAM Compressed, filter off según caso [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
28. - [ ] [108] RF5: definir preset de paleta voxel: mipmaps off, filter off, repeat off [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
29. - [ ] [108] RF5: definir preset de audio OGG con calidad por uso (música alta, SFX media) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
30. - [ ] [108] RF5: definir preset de audio WAV loop con normalize, trim y bounds de loop [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
31. - [ ] [108] RF5: definir preset de fuente TTF con MSDF on, antialiasing on y subsetting [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
32. - [ ] [108] RF6: activar mipmaps en todas las texturas de runtime [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
33. - [ ] [108] RF6: usar compresión VRAM BPTC/S3TC en PC vía Godot [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
34. - [ ] [108] RF6: generar shadow mesh en meshes para sombras baratas [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
35. - [ ] [108] RF6: definir presupuesto por tipo: props ≤ 1.5k tris, NPCs ≤ 6k, fauna ≤ 4k, mobiliario ≤ 2.5k [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
36. - [ ] [108] RF6: instanciar props repetidos con MultiMesh o VoxelInstancer (M08) [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
37. - [ ] [108] RF6: usar un solo mesh con N transforms para vegetación y piedras decorativas [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
38. - [ ] [108] Usar atlas ≤ 4096² con margen de 4 px anti-bleeding para props compartidos [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
39. - [ ] [108] Preparar los presets para poder cambiar a ETC2/ASTC si hubiera mobile (M96) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
40. - [ ] [108] Verificar en review ausencia de popping visible en transición de LODs [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
41. - [ ] [108] RF9: revisar escala correcta en grilla de 1 m del mundo (M08) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
42. - [ ] [108] RF9: revisar origen y pivote del modelo en posición correcta [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
43. - [ ] [108] RF9: revisar UVs sin superposición accidental y normal maps consistentes [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
44. - [ ] [108] RF9: revisar alfa sin bordes blancos (fix_alpha_border) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
45. - [ ] [108] RF9: revisar mipmaps y filtrado visualmente sin saltos [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
46. - [ ] [108] RF9: revisar LODs a las distancias de uso y sombras sin artefactos [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
47. - [ ] [108] RF9: revisar look dev cozy coherente con la dirección de arte [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
48. - [ ] [108] RF9: revisar peso estimado en memoria contra la tabla por tipo [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
49. - [ ] [108] RF9: revisar que la ficha esté completa, incluida la licencia (M78) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
50. - [ ] [108] RN: calidad visual cozy sin texturas 4K indiscriminadas; atlas y MultiMesh para draw calls bajos [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
51. - [ ] [108] RN: binarios grandes gestionados con Git LFS (M06/M107) [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
52. - [ ] [108] Justificar WebP sobre JPG: sin artefactos de bloque en arte flat cozy [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
53. - [ ] [108] Justificar PNG sobre TGA: soporte universal y canal alfa [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
54. - [ ] [108] Justificar OGG sobre MP3: sin licencias de códec y streaming nativo [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
55. - [ ] [108] Analizar la compresión por plataforma: BPTC/S3TC PC, ETC2/ASTC futuro mobile [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
56. - [ ] [108] Analizar batching y atlasing por categorías visuales del proyecto [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
57. - [ ] [108] Documentar el riesgo de bleeding de atlas y su mitigación (margen + mipmaps off) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
58. - [ ] [108] Definir que staging/ es la única puerta de entrada (RF1) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
59. - [ ] [108] Definir que archive/ conserva retirados sin cargarse [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
60. - [ ] [108] Definir el flujo de estados: staging → validado → en_review → aprobado → retirado [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
61. - [ ] [108] M45: modelar props y NPCs respetando la metría de 1 m del mundo voxel [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
62. - [ ] [108] M47: respetar los sufijos de mapas (albedo/normal/roughness/emission) definidos en Texturas y Materiales [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
63. - [ ] [108] M48: animaciones embebidas en glb; anim_ solo para clips excepcionales [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
64. - [ ] [108] M63: ids estables = rutas estables para el caché LRU y el streaming de texturas [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
65. - [ ] [108] M08: paletas voxel en voxel_palettes/ con filtrado off y mipmaps off [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
66. - [ ] [108] M08: props del mundo instanciados con VoxelInstancer/MultiMesh compartido [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
67. - [ ] [108] M61: ejecutar los presupuestos finos de Rendimiento cuando estén publicados (en curso) [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
68. - [ ] [108] Atlas que excede 4096²: rechazo con sugerencia de dividir por categorías [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
69. - [ ] [108] Audio WAV de más de 5 s: rechazo con sugerencia de conversión a OGG [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
70. - [ ] [108] Reportes markdown con resumen ejecutivo (aprobados, errores, pendientes) [S] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
71. - [ ] [108] El apilado de atlas se hace una sola vez por categoría y se cache a su resultado [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
72. - [ ] [108] El índice _APROBADAS.md se regenera incrementalmente, no de cero [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
73. - [ ] [108] Probar el edge case de textura sin comprimir y su corrección con presets [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
74. - [ ] [108] Probar la generación de LODs y shadow meshes en un glb de referencia [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
75. - [ ] [108] Probar el promote/retiro dejando el índice _APROBADAS.md correcto [M] <!-- fuente: 108-Pipeline-De-Assets/05-Checklist.md -->
76. - [ ] [91] Sonidos de interfaz — nota (2026-10-02, mimo-v2.6-flash-free 2026-10-02 (opencode)): sus hijos L110-L114 y L116 siguen en [ ] a propósito y 03-Diseno  <!-- fuente: 91-Configuracion-De-Audio/05-Checklist.md -->
77. - [ ] [91] Pruebas con auriculares — nota (2026-10-02, mimo-v2.6-flash-free 2026-10-02 (opencode)): el DISEÑO está completo (L150 [x], L152 [x], L157 [x]) y L151 <!-- fuente: 91-Configuracion-De-Audio/05-Checklist.md -->
78. - [ ] [91] Pruebas con altavoces — nota (2026-10-02, mimo-v2.6-flash-free 2026-10-02 (opencode)): el DISEÑO está completo (L160, L161, L162, L163 y L167 todos [x <!-- fuente: 91-Configuracion-De-Audio/05-Checklist.md -->
79. - [ ] [91] Definir accesibilidad (M58) para ajustes de tamaño y contraste <!-- fuente: 91-Configuracion-De-Audio/05-Checklist.md -->
80. - [ ] [91] Definir toggle de sonidos de interfaz (on/off) <!-- fuente: 91-Configuracion-De-Audio/05-Checklist.md -->
81. - [ ] [91] Definir sonidos de hover (cursor sobre botón) <!-- fuente: 91-Configuracion-De-Audio/05-Checklist.md -->
82. - [ ] [91] Definir sonidos de click (click en botón) <!-- fuente: 91-Configuracion-De-Audio/05-Checklist.md -->
83. - [ ] [91] Definir sonidos de notificaciones (notificaciones de logros, misiones) <!-- fuente: 91-Configuracion-De-Audio/05-Checklist.md -->
84. - [ ] [91] Definir sonidos de errores (error en acción) <!-- fuente: 91-Configuracion-De-Audio/05-Checklist.md -->
85. - [ ] [91] Definir eventos de UI para trigger de sonidos <!-- fuente: 91-Configuracion-De-Audio/05-Checklist.md -->
86. - [ ] [91] Definir espacial 3D (HRTF) — nota (2026-10-02, mimo-v2.6-flash-free 2026-10-02 (opencode)): Godot 4.7.2 NO expone HRTF (sondeo T-107; ver 03-Diseno §5 <!-- fuente: 91-Configuracion-De-Audio/05-Checklist.md -->
87. - [ ] [91] Diseñar alto contraste (toggle) <!-- fuente: 91-Configuracion-De-Audio/05-Checklist.md -->
88. - [ ] [91] Diseñar subtítulos en diferentes idiomas (español, portugués, francés, alemán, italiano, ruso) <!-- fuente: 91-Configuracion-De-Audio/05-Checklist.md -->
89. - [ ] [91] Diseñar localización de nombres de dispositivos de salida <!-- fuente: 91-Configuracion-De-Audio/05-Checklist.md -->
90. - [ ] [91] Diseñar controles para sonidos de interfaz (toggle) <!-- fuente: 91-Configuracion-De-Audio/05-Checklist.md -->
91. - [ ] [91] Diseñar botones de prueba (auriculares, altavoces) <!-- fuente: 91-Configuracion-De-Audio/05-Checklist.md -->
92. - [ ] [91] Diseñar método play_hover_sound() <!-- fuente: 91-Configuracion-De-Audio/05-Checklist.md -->
93. - [ ] [91] Diseñar método play_click_sound() <!-- fuente: 91-Configuracion-De-Audio/05-Checklist.md -->
94. - [ ] [91] Diseñar método play_notification_sound() <!-- fuente: 91-Configuracion-De-Audio/05-Checklist.md -->
95. - [ ] [91] Diseñar método play_error_sound() <!-- fuente: 91-Configuracion-De-Audio/05-Checklist.md -->
- **BACKLOG-LING.md** - cola investigada por capacidades (ver GUIA-BACKLOGS-POR-MODELO.md)

---

## ANEXO EJECUCION PT (censo medido 2026-10-24 17:30 local / 20:30Z — informe 246)

Preparacion medida para ejecucion en UNA vuelta ante GO del fundador (consulta #4, volumenes adoptados por director 245). **NO crea pt.po ni toca runtime** (standby 23oct 20:42 + director 245 'regla 244'). Texto fuente = es.po (paridad P1); PT reutilizable = strings_pt.json 'cadenas' (159/274). Ninguna traduccion nueva generada aqui — el GO autoriza la generacion.

### A. Volumen (medido en disco)
- es.po: **274 entradas** + cabecera. pt.po objetivo: **274** (paridad P1 — 0 faltantes, 0 huérfanas).
- Reutilizables desde strings_pt.json 'cadenas' (170 claves): **159**. Traduccion nueva: **115**.
- Plurales: **4** (R14 exige msgstr[0] Y msgstr[1], nplurals=2).
- Marcadores `#. no-traducir:` en es.po: **15** (replicar textual en pt.po).

### B. Censo de las 115 claves nuevas por dominio
**M68 (63):**
```
M68.EVENT.DIRIGIBLE_LUNA
M68.EVENT.DIRIGIBLE_LUNA.SENAL
M68.EVENT.FESTIVAL_CATALINA
M68.EVENT.FESTIVAL_CATALINA.SENAL
M68.EVENT.LLEGADA_FINNEAS
M68.EVENT.LLEGADA_FINNEAS.SENAL
M68.EVENT.MUELLE_MATEO
M68.EVENT.MUELLE_MATEO.SENAL
M68.EVENT.PUERTO_BRUNO
M68.EVENT.PUERTO_BRUNO.SENAL
M68.NARR.C4.01
M68.NARR.C4.02
M68.NARR.C4_BRIS
M68.NARR.C7.01
M68.NARR.C7.02
M68.NARR.C7.03
M68.NARR.C7_CAMARA
M68.NARR.FINAL_SECRETO
M68.NARR.SECRETO.01
M68.ROUTE.r_aurora_brisa
M68.ROUTE.r_aurora_espejo
M68.ROUTE.r_aurora_estacion
M68.ROUTE.r_aurora_este
M68.ROUTE.r_aurora_muelle
M68.ROUTE.r_aurora_plataforma
M68.ROUTE.r_aurora_sur
M68.ROUTE.r_estacion_aurora
M68.ROUTE.r_este_aurora
M68.ROUTE.r_este_muelle
M68.ROUTE.r_festival_muelle
M68.ROUTE.r_muelle_aurora
M68.ROUTE.r_muelle_este
M68.ROUTE.r_muelle_festival
M68.ROUTE.r_muelle_sur
M68.ROUTE.r_norte_plataforma
M68.ROUTE.r_plataforma_aurora
M68.ROUTE.r_plataforma_norte
M68.ROUTE.r_sur_aurora
M68.ROUTE.r_sur_muelle
M68.SPECIAL.FESTIVAL_INVIERNO
M68.SPECIAL.FESTIVAL_INVIERNO_DESC
M68.SPECIAL.FESTIVAL_LUCES
M68.SPECIAL.FESTIVAL_LUCES_DESC
M68.SPECIAL.FESTIVAL_OTONO
M68.SPECIAL.FESTIVAL_OTONO_DESC
M68.SPECIAL.FESTIVAL_PRIMAVERA
M68.SPECIAL.FESTIVAL_PRIMAVERA_DESC
M68.SPECIAL.FESTIVAL_VERANO
M68.SPECIAL.FESTIVAL_VERANO_DESC
M68.SPECIAL.LUNA_LLENA
M68.SPECIAL.LUNA_LLENA_DESC
M68.SPECIAL.TOUR_DIRIGIBLE
M68.SPECIAL.TOUR_DIRIGIBLE_DESC
M68.STOP.estacion_central
M68.STOP.muelle_raiz_sur
M68.STOP.plataforma_norte
M68.STOP.puerto_aurora
M68.STOP.puerto_brisa
M68.STOP.puerto_espejo
M68.STOP.puerto_este
M68.STOP.puerto_festival
M68.STOP.puerto_norte
M68.STOP.puerto_sur
```
**M68.TRIP (15):**
```
M68.TRIP.ARRIVED_AT
M68.TRIP.CURRENCY
M68.TRIP.DURATION
M68.TRIP.HORAS_MINUTOS
M68.TRIP.LOADING
M68.TRIP.LOCKED
M68.TRIP.NO_MONEY
M68.TRIP.OUT_OF_SCHEDULE
M68.TRIP.PRICE
M68.TRIP.SCHEDULE
M68.TRIP.SPECIAL_ONLY
M68.TRIP.TRAVELING_TO
M68.TRIP.HORAS
M68.TRIP.MINUTOS
M68.TRIP.SEGUNDOS
```
**DIARY (14):**
```
DIARY.ENTRADAS
DIARY.CAT_PERSONAJES
DIARY.CAT_CRIATURAS
DIARY.CAT_PLANTAS
DIARY.CAT_MINERALES
DIARY.CAT_RECETAS
DIARY.CAT_PISTAS
DIARY.CAT_SELLOS
DIARY.CAT_RUINAS
DIARY.CAT_CARTAS
DIARY.CAT_DESCUBRIMIENTOS
DIARY.CAT_MISIONES
DIARY.CAT_EVENTOS
DIARY.CAT_FOTOGRAFIAS
```
**M68.SIGN (11):**
```
M68.SIGN.GENERICO
M68.SIGN.estacion_central
M68.SIGN.muelle_raiz_sur
M68.SIGN.plataforma_norte
M68.SIGN.puerto_aurora
M68.SIGN.puerto_brisa
M68.SIGN.puerto_espejo
M68.SIGN.puerto_este
M68.SIGN.puerto_festival
M68.SIGN.puerto_norte
M68.SIGN.puerto_sur
```
**CLOCK (4):**
```
CLOCK.ESTACIONES.0
CLOCK.ESTACIONES.1
CLOCK.ESTACIONES.2
CLOCK.ESTACIONES.3
```
**ITEMS (2):**
```
ITEMS.MADERA
ITEMS.MADERA_DESC
```
**MAIN_MENU (1):**
```
MAIN_MENU.OPTIONS
```
**HUD (1):**
```
HUD.VIDA
```
**SETTINGS (1):**
```
SETTINGS.IDIOMA
```
**DIALOGOS (1):**
```
DIALOGOS.VECINO_SALUDO
```
**npc (1):**
```
npc.catalina
```
**UI (1):**
```
UI.INTERACTUAR
```
Nota: `npc.catalina` es nombre propio — const NO_TRADUCIBLES del validador (P5 exento, msgstr PT = 'Catalina'). `UI.INTERACTUAR` existe en es.po L668 (interact_prompt.gd L91).

### C. Plurales (base ES/EN para traducir — R14/R15)
- **ITEMS.SE_OFRECEN** (msgid_plural: ITEMS.SE_OFRECEN)
  - ES: [0] 'Se ofrece {n} objeto' / [1] 'Se ofrecen {n} objetos'
  - EN: [0] 'Offering {n} item' / [1] 'Offering {n} items'
- **M68.TRIP.HORAS** (msgid_plural: M68.TRIP.HORAS)
  - ES: [0] '{n} hora' / [1] '{n} horas'
  - EN: [0] '{n} hour' / [1] '{n} hours'
- **M68.TRIP.MINUTOS** (msgid_plural: M68.TRIP.MINUTOS)
  - ES: [0] '{n} minuto' / [1] '{n} minutos'
  - EN: [0] '{n} minute' / [1] '{n} minutes'
- **M68.TRIP.SEGUNDOS** (msgid_plural: M68.TRIP.SEGUNDOS)
  - ES: [0] '{n} segundo' / [1] '{n} segundos'
  - EN: [0] '{n} second' / [1] '{n} seconds'
ITEMS.SE_OFRECEN tiene PT simple en JSON ('Oferecendo {n} item') — expandir a msgstr[0]/[1] ('Oferecendo {n} item' / 'Oferecendo {n} items'). M68.TRIP.HORAS/MINUTOS/SEGUNDOS: nuevas (PT: '{n} hora/horas', '{n} minuto/minutos', '{n} segundo/segundos' — misma forma ES).

### D. Marcadores no-traducir (15) — replicar textual con su marker
- `M68.SIGN.GENERICO` => '→ {destino} · {metros} m'
- `M68.SIGN.estacion_central` => '→ {destino} · {metros} m'
- `M68.SIGN.muelle_raiz_sur` => '→ {destino} · {metros} m'
- `M68.SIGN.plataforma_norte` => '→ {destino} · {metros} m'
- `M68.SIGN.puerto_aurora` => '→ {destino} · {metros} m'
- `M68.SIGN.puerto_brisa` => '→ {destino} · {metros} m'
- `M68.SIGN.puerto_espejo` => '→ {destino} · {metros} m'
- `M68.SIGN.puerto_este` => '→ {destino} · {metros} m'
- `M68.SIGN.puerto_festival` => '→ {destino} · {metros} m'
- `M68.SIGN.puerto_norte` => '→ {destino} · {metros} m'
- `M68.SIGN.puerto_sur` => '→ {destino} · {metros} m'
- `M68.TRIP.CURRENCY` => 'AO'
- `M68.TRIP.HORAS_MINUTOS` => '{h} h {m} min'
- `EQUIP.EQUIPADO` => '{tipo}: {item}'
- `DIARY.BLOQUEADO` => '???'

### E. Plantilla cabecera pt.po (R4)
```
msgid ""
msgstr ""
"Content-Type: text/plain; charset=UTF-8\n"
"Language: pt\n"
"Plural-Forms: nplurals=2; plural=(n > 1);\n"
```

### F. Checklist de aceptacion (ValidadorPO — quien firma el QA al ejecutar)
- Bytes: R1 sin BOM, R2 LF, R3 UTF-8 valido. Cabecera R4: Content-Type + Language: pt + Plural-Forms nplurals=2.
- Estructura: R5 sin basura, R6 msgstr no vacios, R7 sin msgid duplicado, R8/R13 plurales con msgstr[0], R10 UPPER_SNAKE (excepcion npc.catalina), R11 sin espacios en clave, **R14 plurales completos 0..1 contiguos**, R15 mismos placeholders en todas las formas, R12 no mezclar {llave} con printf.
- Par: **P1 paridad total 274/274**, P2 0 huérfanas, **P3 placeholders {x}/%s/%d identicos ES<->PT**, P5 15 no-traducir + const NO_TRADUCIBLES (npc.catalina, SETTINGS.SLOTS).
- QA final: `ValidadorPO.validar_par(res://locales/es.po, res://locales/pt.po)` 0 errores + `test_validador_po_m87.gd` headless rc=0 + doc M87 04-Codigo sec 8b + LOCALES_SOPORTADOS += 'pt' (localization_manager.gd:15).


## RONDA 2026-10-24 21:00Z (informe 248) — PT-runtime CLASIFICADO por el fundador como DEUDA TECNICA + base verificada LIMPIA

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Regimen:** STANDBY i18n vigente (pt.po NO creado; localization_manager.gd intacto) — cron reactivado wku_16f98b331001hOQSlGHaH9v86K (0 * * * *, proximo 22:00Z)

### A) HALLAZGO (PASO 0, estado_director.json): PT-runtime es DEUDA TECNICA DEL FUNDADOR
- `consultas_fundador_23oct.clasificacion_24oct` (textual): el fundador (24oct 08:13, 'ahora no tengo decidido eso, como deuda tecnica') dejo 4 decisiones pendientes SUYAS: (1) frente-de-codigo a alpha, (2) bloque-0 M106 GCP/Drive/OAuth con SU cuenta, (3) marca M01, (4) PT-runtime (volumen medido 274/159/115).
- Regla institucional del registro: 'NO bloqueantes: la flota corre con lo asignado; el sucesor NO las implementa unilateralmente — solo las mantiene visibles en cada reporte de estado'.
- Impacto en mi riel: la consulta #4 pasa de marco 'GO pendiente' a 'DEUDA DEL FUNDADOR'. Regimen operativo SIN cambio (standby absoluto verificado en disco). Obligacion nueva cumplida: deuda visible en el informe 248 y en la linea ESTADO del backlog.
- Director 247 (su 00:39 local): ratifica 246, ADOPTA el censo por dominios en la consulta #4, adopta los 4 plurales + 15 markers + cabecera plural_pt, confirma el cron reactivado. Radar M23 ruteado a Step-5 (su 203) — no es mi riel.

### B) Verificacion read-only de la base PT (preparacion lista — 1 vuelta al GO)
- Watchdog `scripts/validar_i18n_integridad.py`: LIMPIO (estructura íntegra; 5 avisos informativos). JSON ES/EN/PT 170/170/170; 0 discrepancias de placeholders; cruzado JSON<->.po: comunes 159 / solo-JSON 11 (huérfanas legado M60 — NO van al .po runtime) / solo-.po 115 => CONFIRMA la medicion 274 = 159 + 115.
- es.po = en.po = 274 entradas; paridad SECUENCIAL de msgids EXACTA (sin deriva desde la medicion 08:00Z); 4 msgid_plural (ITEMS.SE_OFRECEN, M68.TRIP.HORAS/MINUTOS/SEGUNDOS); 15 markers '#. no-traducir'.
- pt.po: NO existe (standby correcto). localization_manager.gd:15 LOCALES_SOPORTADOS = ['es','en'] (sin 'pt').
- config.cfg runtime (user://): CRC embebido == CRC calculado del payload (MATCH); idioma persistido = 'es'.
- validador_po.gd citas exactas (verificadas textualmente): L43 `const NO_TRADUCIBLES: Array[String] = ['npc.catalina', 'SETTINGS.SLOTS']`; L30 `const EXCEPCIONES_CLAVE = ['npc.catalina']`; L55 `const MARCADOR_NO_TRADUCIBLE := 'no-traducir'`; L356 el marker viaja en el comentario de traductor (cruce R5/P5). Nota honesta: mi grep quick-check inicial no encontro la const por regex simple — verificada por grep de contenido, la const EXISTE.
- 4 avisos informativos del watchdog sobre PT-JSON (SETTINGS.HORAS_1/HORAS_H/MIN_1/MIN_M 'copia ES'): cognatos legitimos ('1 hora', '%d horas' son identicos en ES y PT) — NO son deuda de traduccion.

### C) Escritos de la vuelta (write real)
- Backlog: linea ESTADO ampliada con bloque 21:00Z; tarea 59 anotada con la clasificacion_24oct; este bloque de ronda.
- Canal: informe 248 (ACK 247 + deuda visible + evidencias). Pool: 248 consumido.


## NOTA 2026-10-24 18:15Z (local) — RELEVO DE DIRECCION + GEMELO 248/248 (informe 249)

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code

### A) Relevo (msg 248 de agnes-3-flash, 18:10:04 local)
- agnes-3-flash asume el rol de DIRECTORA por orden del fundador (relevo de GLM-5.3 Flash-Director, baja por creditos).
- Mi canal y rutometro se mantienen igual; los mensajes al 'director' los atiende agnes.
- Confirmaciones de agnes: STANDBY hasta GO del fundador; PT-runtime i18n (plan 243: pt.po + LOCALES_SOPORTADOS + QA) queda como MI UNICA tarea pendiente — ella no lo asume ni reasigna sin orden del fundador; las 4 decisiones pendientes del fundador (frente-codigo / M106 GCP / marca M01 / PT-runtime) quedan visibles y SIN implementar unilateralmente.
- Mi postura: ACK dado en informe 249 del canal. Deuda PT mantenida visible (cumplo clasificacion_24oct). Preparacion lista en ANEXO EJECUCION PT — 1 vuelta al GO.

### B) Gemelo 248/248 en este canal (reportado a la direccion para saneo)
- 248-2026-10-24_18-05-00-de-ling-3-1-flash-a-glm-5-3-flash-director-ack-247-deuda-pt-clasificada-base-verificada.md — MIO, numero 248 consumido legimitamente del pool del canal via proximo_numero.py --consume.
- 248-2026-10-24_18-10-04-agnes-3-flash-a-ling-3-1-flash-relevo-directora.md — de agnes, escrito SIN consumir del pool del canal (gemelo).
- Accion: NO renombro mensajes ajenos; reporte textual a la nueva directora. Saneo disponible via scripts/renumerar_canal.py cuando la direccion lo disponga (GUIA-NUMERACION-CANALES).

### C) Estado operativo
- Cron ACTIVO: wku_16f98b331001hOQSlGHaH9v86K (0 * * * *, proximo 22:00Z).
- Standby i18n absoluto: pt.po NO existe; LOCALES_SOPORTADOS=['es','en']; config.cfg CRC MATCH idioma='es'.
- Base PT verificada LIMPIA (watchdog 170/170/170; cruzado 159/11/115; paridad es/en 274/274 exacta) — ver bloque RONDA 21:00Z.


## ANEXO EJECUCION PT - KIT DE LAS 115 (pre-validado 2026-10-24 19:05 local / 22:05Z, informe 251)

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Proposito:** al GO del fundador, la ejecucion es mecanica: 159 reutilizables de strings_pt.json 'cadenas' + estas 115 traducciones PT sobre las fuentes ES ya volcadas aca.

### A) Pre-validacion con logica REAL de ValidadorPO (validador_po.gd:22/30/233-238/336-339)
- REGEX_CLAVE = `^[A-Z][A-Z0-9_]*(\.[A-Z0-9_]+)+$` (L22); EXCEPCIONES_CLAVE = ['npc.catalina'] (L30); R10 = AVISO, no error (L336-337 _avs).
- Resultado sobre las 115: **R6 msgstr base no vacio: 115/115** | **R11 espacios en clave: 0** | R10: 75 cumplen UPPER_SNAKE, 40 aviso heredado del catalogo ES (M68.ROUTE.r_aurora_brisa, M68.ROUTE.r_aurora_espejo, M68.ROUTE.r_aurora_estacion, M68.ROUTE.r_aurora_este, M68.ROUTE.r_aurora_muelle, M68.ROUTE.r_aurora_plataforma, M68.ROUTE.r_aurora_sur, M68.ROUTE.r_estacion_aurora, M68.ROUTE.r_este_aurora, M68.ROUTE.r_este_muelle, M68.ROUTE.r_festival_muelle, M68.ROUTE.r_muelle_aurora, M68.ROUTE.r_muelle_este, M68.ROUTE.r_muelle_festival, M68.ROUTE.r_muelle_sur, M68.ROUTE.r_norte_plataforma, M68.ROUTE.r_plataforma_aurora, M68.ROUTE.r_plataforma_norte, M68.ROUTE.r_sur_aurora, M68.ROUTE.r_sur_muelle, M68.SIGN.estacion_central, M68.SIGN.muelle_raiz_sur, M68.SIGN.plataforma_norte, M68.SIGN.puerto_aurora, M68.SIGN.puerto_brisa, M68.SIGN.puerto_espejo, M68.SIGN.puerto_este, M68.SIGN.puerto_festival, M68.SIGN.puerto_norte, M68.SIGN.puerto_sur, M68.STOP.estacion_central, M68.STOP.muelle_raiz_sur, M68.STOP.plataforma_norte, M68.STOP.puerto_aurora, M68.STOP.puerto_brisa, M68.STOP.puerto_espejo, M68.STOP.puerto_este, M68.STOP.puerto_festival, M68.STOP.puerto_norte, M68.STOP.puerto_sur) — patron VIGENTE en es.po: se replica textual en pt.po, NO renombrar (renombrar rompe paridad P1/P2 y el lookup runtime).
- Plurales base de las 115: M68.TRIP.HORAS/MINUTOS/SEGUNDOS tienen msgstr[0]+[1] en ES (R14 base ok). ITEMS.SE_OFRECEN (plural #4) esta entre las 159 solapadas — su JSON PT es forma simple; al llevarla al .po hay que expandirla a msgstr[0]+[1] (atencion documentada).
- Censo de placeholders en las 115 fuentes: {destino} x13, {duracion} x1, {evento} x1, {horario} x2, {h} x1, {metros} x11, {m} x1, {n} x3, {precio} x2. Regla P3: la traduccion PT debe conservar los mismos tokens.
- Dominios: CLOCK 4, DIALOGOS 1, DIARY 14, HUD 1, ITEMS 2, M68 63, M68.SIGN 11, M68.TRIP 15, MAIN_MENU 1, SETTINGS 1, UI 1, npc 1.

### B) Kit (clave | placeholders | fuente ES) — 115 entradas
- `MAIN_MENU.OPTIONS` | ph: - | ES: Opciones
- `HUD.VIDA` | ph: - | ES: Vida
- `ITEMS.MADERA` | ph: - | ES: Madera
- `ITEMS.MADERA_DESC` | ph: - | ES: Madera sólida de la isla Aurora.
- `SETTINGS.IDIOMA` | ph: - | ES: Idioma
- `DIALOGOS.VECINO_SALUDO` | ph: - | ES: ¡Hola, vecino!
- `npc.catalina` | ph: - | ES: Catalina
- `CLOCK.ESTACIONES.0` | ph: - | ES: Primavera
- `CLOCK.ESTACIONES.1` | ph: - | ES: Verano
- `CLOCK.ESTACIONES.2` | ph: - | ES: Otoño
- `CLOCK.ESTACIONES.3` | ph: - | ES: Invierno
- `DIARY.ENTRADAS` | ph: - | ES: Entradas
- `DIARY.CAT_PERSONAJES` | ph: - | ES: Personajes
- `DIARY.CAT_CRIATURAS` | ph: - | ES: Criaturas
- `DIARY.CAT_PLANTAS` | ph: - | ES: Plantas
- `DIARY.CAT_MINERALES` | ph: - | ES: Minerales
- `DIARY.CAT_RECETAS` | ph: - | ES: Recetas
- `DIARY.CAT_PISTAS` | ph: - | ES: Pistas
- `DIARY.CAT_SELLOS` | ph: - | ES: Sellos
- `DIARY.CAT_RUINAS` | ph: - | ES: Ruinas
- `DIARY.CAT_CARTAS` | ph: - | ES: Cartas
- `DIARY.CAT_DESCUBRIMIENTOS` | ph: - | ES: Descubrimientos
- `DIARY.CAT_MISIONES` | ph: - | ES: Misiones
- `DIARY.CAT_EVENTOS` | ph: - | ES: Eventos
- `DIARY.CAT_FOTOGRAFIAS` | ph: - | ES: Fotografías
- `M68.EVENT.DIRIGIBLE_LUNA` | ph: - | ES: Luna sube contigo
- `M68.EVENT.DIRIGIBLE_LUNA.SENAL` | ph: - | ES: Luna señala las islas desde el aire.
- `M68.EVENT.FESTIVAL_CATALINA` | ph: - | ES: Catalina en el festival
- `M68.EVENT.FESTIVAL_CATALINA.SENAL` | ph: - | ES: Catalina te llama entre los faroles.
- `M68.EVENT.LLEGADA_FINNEAS` | ph: - | ES: Finneas te espera
- `M68.EVENT.LLEGADA_FINNEAS.SENAL` | ph: - | ES: Finneas levanta la mano al verte llegar.
- `M68.EVENT.MUELLE_MATEO` | ph: - | ES: Mateo charla en el muelle
- `M68.EVENT.MUELLE_MATEO.SENAL` | ph: - | ES: Ves a Mateo saludando desde el muelle.
- `M68.EVENT.PUERTO_BRUNO` | ph: - | ES: Bruno te despide
- `M68.EVENT.PUERTO_BRUNO.SENAL` | ph: - | ES: Bruno te grita un consejo desde el pantalán.
- `M68.NARR.C4.01` | ph: - | ES: El viento cambia al salir del puerto.
- `M68.NARR.C4.02` | ph: - | ES: Finneas señala el templo en el horizonte.
- `M68.NARR.C4_BRIS` | ph: - | ES: Travesía al Templo de la Brisa
- `M68.NARR.C7.01` | ph: - | ES: El mar está demasiado quieto.
- `M68.NARR.C7.02` | ph: - | ES: Los siete sellos pesan en la mochila.
- `M68.NARR.C7.03` | ph: - | ES: La Cámara espera bajo el templo.
- `M68.NARR.C7_CAMARA` | ph: - | ES: Travesía a la Cámara del Sello
- `M68.NARR.FINAL_SECRETO` | ph: - | ES: Travesía al secreto del Espejo
- `M68.NARR.SECRETO.01` | ph: - | ES: Las pistas pagadas por fin encajan.
- `M68.ROUTE.r_aurora_brisa` | ph: - | ES: Puerto de Aurora → Puerto de la Isla Brisa
- `M68.ROUTE.r_aurora_espejo` | ph: - | ES: Puerto de Aurora → Puerto de la Isla Espejo
- `M68.ROUTE.r_aurora_estacion` | ph: - | ES: Puerto de Aurora → Estación Central
- `M68.ROUTE.r_aurora_este` | ph: - | ES: Puerto de Aurora → Puerto de la Isla del Este
- `M68.ROUTE.r_aurora_muelle` | ph: - | ES: Puerto de Aurora → Muelle Sur de Aurora
- `M68.ROUTE.r_aurora_plataforma` | ph: - | ES: Puerto de Aurora → Plataforma del Norte
- `M68.ROUTE.r_aurora_sur` | ph: - | ES: Puerto de Aurora → Puerto de la Isla del Sur
- `M68.ROUTE.r_estacion_aurora` | ph: - | ES: Estación Central → Puerto de Aurora
- `M68.ROUTE.r_este_aurora` | ph: - | ES: Puerto de la Isla del Este → Puerto de Aurora
- `M68.ROUTE.r_este_muelle` | ph: - | ES: Puerto de la Isla del Este → Muelle Sur de Aurora
- `M68.ROUTE.r_festival_muelle` | ph: - | ES: Puerto del Festival → Muelle Sur de Aurora
- `M68.ROUTE.r_muelle_aurora` | ph: - | ES: Muelle Sur de Aurora → Puerto de Aurora
- `M68.ROUTE.r_muelle_este` | ph: - | ES: Muelle Sur de Aurora → Puerto de la Isla del Este
- `M68.ROUTE.r_muelle_festival` | ph: - | ES: Muelle Sur de Aurora → Puerto del Festival
- `M68.ROUTE.r_muelle_sur` | ph: - | ES: Muelle Sur de Aurora → Puerto de la Isla del Sur
- `M68.ROUTE.r_norte_plataforma` | ph: - | ES: Puerto de la Isla del Norte → Plataforma del Norte
- `M68.ROUTE.r_plataforma_aurora` | ph: - | ES: Plataforma del Norte → Puerto de Aurora
- `M68.ROUTE.r_plataforma_norte` | ph: - | ES: Plataforma del Norte → Puerto de la Isla del Norte
- `M68.ROUTE.r_sur_aurora` | ph: - | ES: Puerto de la Isla del Sur → Puerto de Aurora
- `M68.ROUTE.r_sur_muelle` | ph: - | ES: Puerto de la Isla del Sur → Muelle Sur de Aurora
- `M68.SIGN.GENERICO` | ph: {destino},{metros} | ES: → {destino} · {metros} m
- `M68.SIGN.estacion_central` | ph: {destino},{metros} | ES: → {destino} · {metros} m
- `M68.SIGN.muelle_raiz_sur` | ph: {destino},{metros} | ES: → {destino} · {metros} m
- `M68.SIGN.plataforma_norte` | ph: {destino},{metros} | ES: → {destino} · {metros} m
- `M68.SIGN.puerto_aurora` | ph: {destino},{metros} | ES: → {destino} · {metros} m
- `M68.SIGN.puerto_brisa` | ph: {destino},{metros} | ES: → {destino} · {metros} m
- `M68.SIGN.puerto_espejo` | ph: {destino},{metros} | ES: → {destino} · {metros} m
- `M68.SIGN.puerto_este` | ph: {destino},{metros} | ES: → {destino} · {metros} m
- `M68.SIGN.puerto_festival` | ph: {destino},{metros} | ES: → {destino} · {metros} m
- `M68.SIGN.puerto_norte` | ph: {destino},{metros} | ES: → {destino} · {metros} m
- `M68.SIGN.puerto_sur` | ph: {destino},{metros} | ES: → {destino} · {metros} m
- `M68.SPECIAL.FESTIVAL_INVIERNO` | ph: - | ES: Viaje al Festival de Invierno
- `M68.SPECIAL.FESTIVAL_INVIERNO_DESC` | ph: - | ES: Parada temporal en el Puerto del Festival.
- `M68.SPECIAL.FESTIVAL_LUCES` | ph: - | ES: Viaje al Festival de las Luces
- `M68.SPECIAL.FESTIVAL_LUCES_DESC` | ph: - | ES: Travesía nocturna a los faroles.
- `M68.SPECIAL.FESTIVAL_OTONO` | ph: - | ES: Viaje al Festival de Otoño
- `M68.SPECIAL.FESTIVAL_OTONO_DESC` | ph: - | ES: Parada temporal en el Puerto del Festival.
- `M68.SPECIAL.FESTIVAL_PRIMAVERA` | ph: - | ES: Viaje al Festival de Primavera
- `M68.SPECIAL.FESTIVAL_PRIMAVERA_DESC` | ph: - | ES: Parada temporal en el Puerto del Festival.
- `M68.SPECIAL.FESTIVAL_VERANO` | ph: - | ES: Viaje al Festival de Verano
- `M68.SPECIAL.FESTIVAL_VERANO_DESC` | ph: - | ES: Parada temporal en el Puerto del Festival.
- `M68.SPECIAL.LUNA_LLENA` | ph: - | ES: Tour de luna llena
- `M68.SPECIAL.LUNA_LLENA_DESC` | ph: - | ES: Travesía nocturna a la Isla Espejo, con recargo.
- `M68.SPECIAL.TOUR_DIRIGIBLE` | ph: - | ES: Tour panorámico en dirigible
- `M68.SPECIAL.TOUR_DIRIGIBLE_DESC` | ph: - | ES: Vuelo de fin de semana sobre la Isla del Norte.
- `M68.STOP.estacion_central` | ph: - | ES: Estación Central
- `M68.STOP.muelle_raiz_sur` | ph: - | ES: Muelle Sur de Aurora
- `M68.STOP.plataforma_norte` | ph: - | ES: Plataforma del Norte
- `M68.STOP.puerto_aurora` | ph: - | ES: Puerto de Aurora
- `M68.STOP.puerto_brisa` | ph: - | ES: Puerto de la Isla Brisa
- `M68.STOP.puerto_espejo` | ph: - | ES: Puerto de la Isla Espejo
- `M68.STOP.puerto_este` | ph: - | ES: Puerto de la Isla del Este
- `M68.STOP.puerto_festival` | ph: - | ES: Puerto del Festival
- `M68.STOP.puerto_norte` | ph: - | ES: Puerto de la Isla del Norte
- `M68.STOP.puerto_sur` | ph: - | ES: Puerto de la Isla del Sur
- `M68.TRIP.ARRIVED_AT` | ph: {destino} | ES: Has llegado a {destino}.
- `M68.TRIP.CURRENCY` | ph: - | ES: AO
- `M68.TRIP.DURATION` | ph: {duracion} | ES: Duración: {duracion}
- `M68.TRIP.HORAS_MINUTOS` | ph: {h},{m} | ES: {h} h {m} min
- `M68.TRIP.LOADING` | ph: - | ES: Preparando el viaje...
- `M68.TRIP.LOCKED` | ph: - | ES: Destino bloqueado
- `M68.TRIP.NO_MONEY` | ph: {precio} | ES: Te faltan monedas: cuesta {precio}
- `M68.TRIP.OUT_OF_SCHEDULE` | ph: {horario} | ES: Fuera de horario ({horario}). ¿Esperar?
- `M68.TRIP.PRICE` | ph: {precio} | ES: Precio: {precio}
- `M68.TRIP.SCHEDULE` | ph: {horario} | ES: Horario: {horario}
- `M68.TRIP.SPECIAL_ONLY` | ph: {evento} | ES: Sólo disponible durante {evento}
- `M68.TRIP.TRAVELING_TO` | ph: {destino} | ES: Viajando a {destino}...
- `M68.TRIP.HORAS` | ph: {n} | ES: {n} hora / {n} horas
- `M68.TRIP.MINUTOS` | ph: {n} | ES: {n} minuto / {n} minutos
- `M68.TRIP.SEGUNDOS` | ph: {n} | ES: {n} segundo / {n} segundos
- `UI.INTERACTUAR` | ph: - | ES: Interactuar


## ANEXO MEDICIONES RIEL 255 (agnes msg 255, 2026-10-24) — evidencia de las mediciones en disco

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-24 22:36 local (2026-10-25 01:36Z)
**Log:** 2175 · **Canal:** msg 256

### M09 — Terreno (03 III ###16-20, inicia L132)
- Escala: CENTRO Vector2(2560,2560) mundo_raiz.gd L16; RADIO_ISLA 1800 L18; SPAWN Vector3(3860,0,3860) L26.
- Altura: max_height=40, height_boost=1.0 (island_generator.gd L14/L17); techo absoluto 80 (test_generacion_m10_atria.gd L199).
- Chunks: CHUNK_SIZE=32 (game_constants.gd L9); VERTS_PER_CHUNK_MAX=2000, OVERDRAW_MAX=1.5, REFLECTION_PROBES_MAX=2 (validate_water.gd L13-15, check L59); view_distance prod 1024 (main_island.gd L161).
- Biomas (island_generator.gd L203-234; FIX BUG-043 snow antes de mountain): beach h<=3 SAND; snow h>32 SNOW; mountain h>26 STONE; wetland h<=8 y humedad>0.45 MUD; forest humedad>0 GRASS; grassland else GRASS. 6 biomas verificados (test L145-146/L158).
- Sub-superficie L185-200; bedrock y<=0 L162-164.
- Impostor (terreno_horizonte.gd): PASO 64 L21; RADIO_CUBIERTO 2700 L25; FACTOR_ALTURA 0.85 L27; MONT_EXAG 4.0/1.0 L32-33; RADIO_EXAG 0/2100 L34-35; H_MIN 4 L37; DISCO_BASE_Y 4.3 L39; DISCO_R 1800 L42; ANILLO 1800-3000 L46-47; ANILLO_OCULTAR 150 L51; TAMANO_TILE 640 L57; TILE_OCULTAR 400 L60; FILAS_POR_FRAME 6 L66; INTENTOS_MAX 12 L74; n=ceil(2*2700/640)=9 L167; print runtime L234; disco base r<=2100 y=0.2 L238-240.
- Vertex colors (0 texturas de terreno): block_catalog.gd L69-95 _color_canonico; world_manager.gd L30-31 vertex_color_use_as_albedo. Assets proyecto: 848 archivos / 3.01 MB. 7 .tres en resources/terrain/. GUIA-GODOT/08 L15-41 receta de capas.
- DEUDA: tiempos de generacion sin medir (propuesta de instrumentacion en 03 III ###20).

### M112 — Testing (03 III ###20-23, inicia L190)
- Censo: 481 archivos test_*.gd (scripts 429 / tests 51 / tools 1); 222 con funciones; 1240 funciones test; 14037 _check() en 434 archivos.
- Distribucion: 74 archivos >50 checks (TECHO VIOLADO; max 468 test_historias.gd); 356 en 5-50; 4 en 1-4. Top: historias 468, islas_m27_iter2 239, transporte_m68_iter2 178, transporte_m68 178, islas_m27 174, crash_m122_offline 169, datos_m60_iter4 155.
- Suites: runner 38 suites / 1728 tests / 0 fallos (05 L315, Log 2078); GdUnit4 7 archivos / 21 cases / 95.1s; SceneTree 470; tiempos 620.1s -> 897.0s -> 545.3s (presupuesto 600s CUMPLIDO).
- Flakes: 0 medidos; SIN contador persistente (deuda instrumentacion).
- Reconciliacion: GLOBAL dice "475 test en disco" vs 481 reales (delta +6); 1529 .gd totales.

### M114 — Playtest (03 III ###26-29, inicia L243)
- Sesion 80 min (docs/playtest/README.md L17); 3-5 testers/round (L15); historico 3-8 (plan-inicial/01 L58); GO fundador 23oct 20:25: 30 sesiones/tester (03 L237 PAQ-5, supersedes 8-12 L209).
- Fixes: max 5/ronda (README L19); 2-8h/fix; 10-40h/ronda.
- TonoCozy=(Q4+Q5+Q6)/3-(Q1+Q2+Q3)/3; rango -4..+4; metas +0.5/+1.0 (README L21-23); SLA 48h/<=72h.
- USD: 0/mes (134-Presupuesto/operativa/budget-breakdown.md L17); unico desembolso USD 100 Steam Direct Fee (L19); roles USD 0 (L68-69).
- DRIFT: cita "muestra 30 de M105/06" ROTA — M105 no tiene 06-Plan-Testings.md (solo 01-05; grep "muestra" 0 hits).

### M116 — Instalador (03 III ###31-34, inicia L465)
- Payload medido (M117, Log 1888): Win 125.98 MB (exe 120.80 + DLL 5.18); Linux/SteamOS 96.58 MB (bin 86.8 + SO 9.78) — M117 05 L101/L233-236. DRIFT vs "base 5 GB -> instalador 1.5 GB" (03 capa I #1 L417/L431).
- Disco: DISCO_MINIMO_MB=5120 (system_requirements.iss L7); GetSpaceOnDisk64 L29; Libre>=5GB L31; msg L71; setup_windows.ps1 L70 AvailableFreeSpace.
- Instalador: IslaAncestral.iss L31 localappdata; L41 PrivilegesRequired=lowest; L44 x64; L71-72 HKCU. Shortcuts 2 OS (setup_windows.ps1 L210-211/L225; -NoShortcuts L22/L228).
- Fotos: user://fotos/ (photo_service.gd L28; photo_gallery.gd L13); index.json L49; MAX_MINIATURAS_CARGADAS=24 (gallery L15); miniatura 160x90 (L14); captura <50ms (photo_service L47 item 133; validate_photo.gd L32). Saveset: 50x1MB=50MB=1% de 5GB (diseno; sin medicion real).
- Tiempos de install NO medidos (smoke: setup 9 acciones/uninstall 1, RC=0 x3, Validador 61 checks, test_instalador 15x3, test_build_m117 14).
- Retencion saves: %APPDATA%\Godot\app_userdata\isla-ancestral (07 L62-66). Existen rollback.iss/repair.iss/update.iss.

### M118 — CI-CD (03 III ###34-37, inicia L140)
- 6 workflows / 29 jobs (backup 1, bug_metrics 1, dev-build 4, quality 13, release-build 7, testing 3); runs-on ubuntu-latest x29.
- Crones: 2 semanales (backup '0 2 * * 1' L17 con comentario PAQ-6; bug_metrics '0 9 * * 1' L5). DRIFT: PAQ-6 asume nightly 3/sem — en disco 0 nightly.
- Concurrency cancel-in-progress x3 (testing L9-11; quality L9-11; dev-build L21-23).
- Retentions: dev-build 7/3/7 (L69/L100/L122); release-build 14/30 (L140/L168) — DRIFT vs doc "90 dias"; backup 7 (L69).
- Timeouts: testing 15/10 (L17/L89); quality 15/15/20/10/5/10x5 (L17/L117/L160/L661/L745/L783/L854/L885/L928/L990); dev-build 15/15/10; release-build 20/10 (L35/L56).
- Free tier: 21.5 GB/mes artefactos (Beam H26) vs 10 GB; minutos recalculados ~600-1063/mes < 2000 (sin nightly).

### ACK nudge 256 (agnes 22:41) — respondido en msg 257 (22:44 local)
- Su nudge cruzo con mi informe 256 (22:36, ya en el canal): lote 1 cerrado, tabla hecho=13 skip=0 fail=0, per-modulo con L# del 03 III y [x], 5 drifts, PT sin GO.
- Ninguno de los 5 modulos estaba 🔵; el riel no quedo corto (13/13). Ofrecido barrido de otros modulos con capa-II degradada si amplia el riel.
- Gemelo 256/256 reportado para saneo (no renombre su mensaje; precedente 248/248). Pool del canal: 257 consumido (cabeza 258).

### ANEXO MEDICIONES RIEL 258 — lote 2 M72/M105/M107/M119 (2026-10-24 23:30 local; informe 259; Log 2177)
- **M72 Logros** (03 III ###4-6 L319; 0 cierres — L383-385 ya [x] SIN placeholder; 3 [?] deuda externa M59/M87/M117-118): achievement_service.gd 552L, autoload Achievements (project.godot L80); logros.json 17 logros schema_version=2 SIN campo recompensa (Beam 312 ###2 no materializado; vigentes = hitos M71, progression_manager.gd L20/794-798). DRIFT triple umbrales amistad: friendship.json 30/70/120/150/260 (balance_service L32) vs amistad_config.tres [0,20,40,70,100,140,190,250,320,400,500] (amistad_config.gd L10 fallback; friendship_service L143-146 inyecta runtime; test_amistad_rf48_m20 L45 espera serie .tres). Colección 99% NO existe: 100% estricto (coleccionables_manager L201-204; collection_registry L134-141; logro flora via progression_manager L316-322; recompensa exposición idempotente collection_registry L108-111 + donation_service L57-60). stat_ids duplicados: regalos_dados ×5 (logros.json L78/185/201/216/232); dias_en_aurora L252-265 usa viajes_realizados umbral 30.
- **M105 Telemetría** (03 III ###7-9 L153; cierres L387-389): telemetry_director.gd 533L, autoload TelemetryDirector (project.godot L29); 19 EVT L101-121; 6 métricas L124-129; opt-in GDPR default false (user://settings/telemetry.cfg); delega 100% a AnalyticsDirector L342-351; timers 1s polling L282-297; SIN limitador por-frame ni buffer propio → batching real en M104: batch_interval_min=30.0 (analytics_director L36, umbral L63 = 30 MIN) + flush on exit L68-71 (DRIFT vs diseño flush 30s/100, 03 L122). 0 hits schema_version en scripts/telemetry+|analytics/ (no versiona payload; semver vive en M119 + logros.json schema_version=2). Cross-ref M144 (144-Despues-Del-Lanzamiento 03 L6-17): 7/9 métricas con fuente M105 medidas — plenas tutorial/dificultad/contenido; insumos onboarding (5 time_to_first + tutorial) y retención (session×2 + duration, agregado M104 L154); economía NO (telemetry_bridge L54-56 purchase_done 0 emisores producción; única fila quest.prereq_met→track_seal_first_obtained L57-65, emisor story_manager L187; 13 track_* sin llamadores pre-bridge L9-14). Refina flag H21. DRIFT CI: iter8 + test_telemetry_bridge_m105 no cableados (quality.yml L487-490 solo 4/6 suites; pisos CHECKS_MINIMOS L480-486).
- **M107 Backups** (03 III #9-10 L705; cierres L408-409): backup_manager.gd 407L, autoload BackupManager (project.godot L119); DIR user://backups/ L14; _max_copias default 5 L48-49; verificar_integridad L213-224 "checksum\npayload" + Validador.crc32_hex L224; gate restore L254. backup_policy.json: dias_maximos 30, max_copias_por_categoria 5, SIN campo algoritmo (corrección Lote B precisa). backup_categories.json 84L: 7 cats retencion 365/90/180/365/90/180/180 (L10-65), frecuencias continuo×4/post_release×1/semanal×2, GFS 30/52/60 + permanentes L68-73, algoritmo CRC32 L76, zip nivel 6 L79-83. Dual integridad CONFIRMADO: CRC32 runtime + SHA-256 scripts/backup/verify_backups.ps1 L78 (checksums.txt hex64 L53, mensual/ L70, verify.log L93-95, exit 0/1/2). DRIFTS: _limpiar_existentes_cat hardcode max_dias=30 L315 (ignora retencion_dias); limpieza raíz max global L302-312 vs por-cat L314-335; frecuencias no automatizadas (bajo demanda; ejecutor externo backup_local.ps1); SHA-256 mensual MANUAL (0 scheduler, CI no cablea verify).
- **M119 Actualizaciones** (03 III ###11-12 L398; cierres L212-213): update_manager.gd 92L, autoload UpdateManager (project.godot L112); versions.json 3 canales (estable 1.0.0 / beta 1.1.0-beta.1 / dev 1.1.0-dev.3) + politica min_versiones_atras 2/aviso_previa/requiere_reinicio; 0 hits Timer/_process/cron → 100% pasivo (hotfix<72h/patch 30d/<48h = proceso M144 03 L19-25, no runtime); comparar_versiones L45 ignora pre-release (L56 split('-')[0]; test L52 lo espera). 0 hits canary/rollout/circuit/fail_rate; RollbackManager citado 03 L365 INEXISTENTE (scripts/updates/ = 2 archivos); mecanismo real = promoción entre canales + min_versiones_atras 2. DRIFT CI: test_updates_m119.gd (73L) NO cableado en quality.yml (M72 L523-528 / M105 L487-490 / M107 L358-362 sí).
- **Autoloads verificados (project.godot)**: AnalyticsDirector L28, TelemetryDirector L29, Achievements L80, UpdateManager L112, BackupManager L119.
- **Numeración**: msg 259 consumido del pool del canal (helper saneó 258 de agnes ya usado en hilo; gemelo reportado). Log 2177 consumido del pool de Logs (2176 = Step-5/M23).
- **LECCIONES quickcheck 05:00Z (msg 265):** (1) walks recursivos en el repo enganchan `.kilo/worktrees/phase-judge/` (worktrees de Kilo con copias viejas de los mismos scripts, ordenados antes que game/) — usar PATHS CANONICOS explicitos o excluir .kilo/DOCUMENTACION/Obsoletos/.git; (2) GDScript declara con `:=` — pattern de asignacion debe ser `\s*[:]?=`; (3) cierres del riel tienen 2 variantes textuales: "degradado 997" (19) y "COMPLETADO sin formula Beam" (1, M114 L259 — item USD/disciplina sin marcador [?]) — contar con ambos patterns.

### HOJA DE EJECUCION PT-RUNTIME — 1 VUELTA ANTE GO #4 DEL FUNDADOR (prep 2026-10-25 06:00Z, msg 267)
Base fresh verificada esta vuelta: validador LIMPIO exit 0 (170/170/170; paridad 0/0/0; cruzado 159/11/115; 4 flags unidades legitimos ES≈PT); mtimes base i18n estables durante standby (es/en.po 2026-10-21, strings_pt.json 2026-10-20, localization_manager.gd 2026-09-15, validador 2026-10-17). Base canonica: `game/isla-ancestral/data/localizacion/strings_pt.json` (159 cadenas reutilizables) + `locales/es.po`+`en.po`.
- **PASO 1 — pt.po:** crear `game/isla-ancestral/locales/pt.po` desde es.po: 274 entradas (159 reutilizables de strings_pt.json + 115 nuevas de es.po + 4 plurales con msgstr[0]+[1]; replicar 15 marcadores '#. no-traducir' de es.po). VERIF: count msgid=274, header plural pt.
- **PASO 2 — runtime:** `game/isla-ancestral/scripts/localization/localization_manager.gd` L15: LOCALES_SOPORTADOS += "pt" (["es","en"] -> ["es","en","pt"]). VERIF: grep L15.
- **PASO 3 — QA:** ValidadorPO.validar_par (R1-R15/P1-P5) sobre pt.po. VERIF: exit 0, paridad 274/274, 0 discrepancias placeholders.
- **PASO 4 — doc:** plan-actual M87 actualizado con base PT (274 = 159+115+4). VERIF: seccion nueva citada en disco.
- **PASO 5 — reporte:** canal agnes + director; QA cruzada 21.8 por agnes/Hy3 (NUNCA auto-selle).
- **REGLAS:** 0 push; NO tocar es.po/en.po/strings_*.json; un solo modulo (M87) a la vez; SIN GO #4 DEL FUNDADOR NADA DE ESTO SE EJECUTA.

### PRE-PASO 1 — CORPUS PT MEDIDO EN DISCO (2026-10-25 07:00Z, msg 269)
- es.po: 274 entradas (parser canonico `parse_po` de scripts/validar_i18n_integridad.py — NO re-inventado).
- Cruzado strings_pt.json (170 claves bajo "cadenas") <-> es.po (274): **159 comunes** (copiar msgstr de strings_pt.json) + **115 nuevas** (traducir) + 11 solo-JSON (deuda conciliacion msg 153, NO del riel PT).
- 115 nuevas por dominio: M68=89 (signos/trip — 77% del trabajo, prioritario), DIARY=14, CLOCK=4, ITEMS=2, DIALOGOS=1, HUD=1, MAIN_MENU=1, SETTINGS=1, UI=1, npc=1.
- 15 '#. no-traducir': M68.SIGN.* x11 (plantillas flecha+distancia+unidad), M68.TRIP.CURRENCY (codigo divisa AO), M68.TRIP.HORAS_MINUTOS (unidades h/min), EQUIP.EQUIPADO (plantilla item), DIARY.BLOQUEADO (lore §3.2, "???" intencional en todos los idiomas).
- 4 plurales: ITEMS.SE_OFRECEN, M68.TRIP.HORAS, M68.TRIP.MINUTOS, M68.TRIP.SEGUNDOS (msgstr[0]+[1]; en es.po msgid_plural == msgid, formato simplificado).
- Header es.po: Content-Type UTF-8 + Language + "Plural-Forms: nplurals=2; plural=(n != 1);\n". pt.po: Language: pt + Plural-Forms: nplurals=2; plural=(n > 1).
- **LECCION (2 bugs de parseo propios en 1a pasada):** (1) walker JSON camino la raiz y pego prefijo 'cadenas.' a las 170 claves -> cruzado 0 fantasma; (2) header Plural-Forms va entre comillas dentro del msgstr del header -> startswith('Plural-Forms') dio falso negativo. Resuelto reusando V.parse_po / V.claves_recursivo canonicos. Regla: medir con parsers canonicos del proyecto, no parsers ad-hoc.

### ENSAYO EN SECO pt.po (Temp, 2026-10-25 08:00Z, msg 271) — estructura del PASO 1 verificada construible
- Draft en `C:\Users\MAURY-~1\AppData\Local\Temp\kilo\pt_po_draft.po` (16.7KB, Fuera del repo): header PT (Language: pt, Plural-Forms nplurals=2; plural=(n > 1)) + 274 entradas (159 msgstr copiadas de strings_pt.json + 115 msgstr vacias + 4 plurales con msgstr[0/1] + 15 comentarios no-traducir replicados).
- Validado con parser canonico: parse_po(draft) = 274 msgids ✓. Conteo msgstr: 158 no-vacias planas + 113 vacias planas + 1 plural comun (ITEMS.SE_OFRECEN, en JSON PT) + 3 plurales nuevos (M68.TRIP.*) = 274 ✓ (el descuadre aparente 158/113 se explica: los plurales usan msgstr[0]/[1], no msgstr plano).
- **Detalles de ejecucion del PASO 1 (nuevos, para la vuelta de GO):** (1) ITEMS.SE_OFRECEN esta en strings_pt.json pero el JSON tiene 1 cadena vs 2 formas plurales PT -> construir msgstr[0]/msgstr[1] ("Se ofrece 1 objeto"/"Se ofrecen N objetos" -> PT "1 objeto"/"N objetos" o similar), NO copia directa; (2) M68.TRIP.HORAS/MINUTOS/SEGUNDOS (3 de las 115 nuevas) son plurales -> 6 msgstr[0/1] a traducir (M68-heavy: 89 nuevas de M68, 3 de ellas plurales); (3) las 15 no-traducir -> msgstr = msgid (plantillas/codigos/lore).
- Sondas pre-GO: pt.po NO existe en locales/ ✓; localization_manager.gd L15 LOCALES_SOPORTADOS=["es","en"] intacto ✓ (nadien activo PT unilateralmente).
- Drift-check deuda D1-D17: 0 actividad de duenos en 05 de los 9 modulos del riel (los 5 hits con fecha 2026-10-25 son notas de riel lote 2 mias + cierre M114 L259) -> 17 drifts SIN MOVIMIENTO, deuda de duenos intacta.

### QA PREVIO DE LAS 159 COPIABLES + ValidadorPO (2026-10-25 09:00Z, msg 273)
- QA de las 159 traducciones PT copiables (strings_pt.json ∩ es.po): **0 anomalias** — 0 vacias, 0 U+FFFD, 0 discrepancias de placeholders. Las 159 estan limpias para copiar a pt.po en el PASO 1.
- **ValidadorPO EXISTE canonicamente**: `game/isla-ancestral/scripts/localization/validador_po.gd` (class_name ValidadorPO; L15 uso: ValidadorPO.validar_par("res://locales/es.po","res://locales/en.po"); L99: static func validar_par(ruta_fuente, ruta_traduccion) -> Dictionary; reglas R1-R15 + P1-P5; Logs M87 874/920/2050/2063). Invocacion para la vuelta de GO: `ValidadorPO.validar_par("res://locales/es.po", "res://locales/pt.po")`.
- ITEMS.SE_OFRECEN en JSON PT = 'Oferecendo {n} item' (singular) -> en el GO construir plural 'Oferecendo {n} itens' (msgstr[1]). M68.TRIP.HORAS/MINUTOS/SEGUNDOS ausentes del JSON PT (3 de las 115 nuevas, plurales, 6 msgstr).
- M87 plan-actual sin toques de conciliacion JSON<->.po — deuda msg 153 intacta (fuera del riel PT; las 11 solo-JSON no entran a pt.po desde es.po).

### QA TERMINOLOGICO 159 COPIABLES + CANON PT (2026-10-25 20:00Z, msg 275)
- Analisis completo de las 159 cadenas ES->PT copiables (listado clave|ES|PT en script Temp termino_pt.py): **consistencia interna VERIFICADA** — equivalencias canonicas observadas: guardar->salvar (SETTINGS.GUARDAR/CONFIRMA/EXITO/FALLO/TITULO/ULTIMO/SAVE_*), objeto->item (DESCARTAR_TITULO/SIN_ITEMS/SELECCIONA/INVENTARIO_HINT/SE_OFRECEN), prenda->peca (EQUIP.*), tienda->loja (TIENDAS.*), borrar->excluir (BORRAR_* x4), diario->diario (DIARY.*), isla->ilha (LOADING.TITULO/SETTINGS.TITULO), categoria->categoria (sin tilde, correcto pt-BR), completado->concluido, nuevo->novo.
- Registro: pt-BR uniforme — 'voce' + imperativo formal (Selecione/Clique/Libre/Tente/Escolha/Use/Volte); 0 marcadores pt-PT (tu/te); 6 cadenas con 'voce'. Sin mezcla de registro.
- 34 PT==ES exactos = cognatos/neutrales legítimos (validador clasificó 31 cognatos + 4 unidades HORAS/MIN; SETTINGS.ADVANCED 'Enter para continuar' neutro).
- **CANON PT para las 115 nuevas (GO #4):** salvar / item / peça / loja / diário / excluir / ilha / ânimo(AO) / registro você-imperativo formal. M68-heavy (89): signo->sinal(segun contexto sinalización), tripulación->tripulação, transporte->transporte.
- ITEMS.SE_OFRECEN: singular existente 'Oferecendo {n} item' -> plural msgstr[1] = 'Oferecendo {n} itens'.
- Estabilidad post-gap 11h: mtimes base i18n sin cambios (nadie tocó es/en.po, strings_pt.json, validador_po.gd, localization_manager.gd).

### LOTE-115 FORMATEADO (clave | ES | flags) — insumo PASO 1 del GO (2026-10-25 21:00Z, msg 276)
Extracción cruda de es.po (msgid=clave, msgstr=texto ES) vs strings_pt.json. Desglose: M68=89, DIARY=14, CLOCK=4, ITEMS=2, MAIN_MENU/HUD/SETTINGS/DIALOGOS/npc/UI=1 c/u.

**M68.EVENT (6):** DIRIGIBLE_LUNA "Luna sube contigo" / .SENAL "Luna señala las islas desde el aire." | FESTIVAL_CATALINA "Catalina en el festival" / .SENAL "Catalina te llama entre los faroles." | LLEGADA_FINNEAS "Finneas te espera" / .SENAL "Finneas levanta la mano al verte llegar." | MUELLE_MATEO "Mateo charla en el muelle" / .SENAL "Ves a Mateo saludando desde el muelle." | PUERTO_BRUNO "Bruno te despide" / .SENAL "Bruno te grita un consejo desde el pantalán."
**M68.NARR (8):** C4.01 "El viento cambia al salir del puerto." | C4.02 "Finneas señala el templo en el horizonte." | C4_BRIS "Travesía al Templo de la Brisa" | C7.01 "El mar está demasiado quieto." | C7.02 "Los siete sellos pesan en la mochila." | C7.03 "La Cámara espera bajo el templo." | C7_CAMARA "Travesía a la Cámara del Sello" | FINAL_SECRETO "Travesía al secreto del Espejo" | SECRETO.01 "Las pistas pagadas por fin encajan."
**M68.ROUTE (20, con →):** r_aurora_brisa "Puerto de Aurora → Puerto de la Isla Brisa" | r_aurora_espejo "→ Puerto de la Isla Espejo" | r_aurora_estacion "→ Estación Central" | r_aurora_este "→ Puerto de la Isla del Este" | r_aurora_muelle "→ Muelle Sur de Aurora" | r_aurora_plataforma "→ Plataforma del Norte" | r_aurora_sur "→ Puerto de la Isla del Sur" | r_estacion_aurora "Estación Central → Puerto de Aurora" | r_este_aurora "Puerto de la Isla del Este → Puerto de Aurora" | r_este_muelle "→ Muelle Sur de Aurora" | r_festival_muelle "Puerto del Festival → Muelle Sur de Aurora" | r_muelle_aurora "Muelle Sur de Aurora → Puerto de Aurora" | r_muelle_este "→ Puerto de la Isla del Este" | r_muelle_festival "→ Puerto del Festival" | r_muelle_sur "→ Puerto de la Isla del Sur" | r_norte_plataforma "Puerto de la Isla del Norte → Plataforma del Norte" | r_plataforma_aurora "Plataforma del Norte → Puerto de Aurora" | r_plataforma_norte "→ Puerto de la Isla del Norte" | r_sur_aurora "Puerto de la Isla del Sur → Puerto de Aurora" | r_sur_muelle "→ Muelle Sur de Aurora"
**M68.SIGN (11) [NO-TRADUCIR: plantilla "→ {destino} · {metros} m"]:** GENERICO, estacion_central, muelle_raiz_sur, plataforma_norte, puerto_aurora, puerto_brisa, puerto_espejo, puerto_este, puerto_festival, puerto_norte, puerto_sur.
**M68.SPECIAL (12):** FESTIVAL_INVIERNO "Viaje al Festival de Invierno" / _DESC "Parada temporal en el Puerto del Festival." | FESTIVAL_LUCES "Viaje al Festival de las Luces" / _DESC "Travesía nocturna a los faroles." | FESTIVAL_OTONO "Viaje al Festival de Otoño" / _DESC "Parada temporal en el Puerto del Festival." | FESTIVAL_PRIMAVERA "Viaje al Festival de Primavera" / _DESC ídem | FESTIVAL_VERANO "Viaje al Festival de Verano" / _DESC ídem | LUNA_LLENA "Tour de luna llena" / _DESC "Travesía nocturna a la Isla Espejo, con recargo." | TOUR_DIRIGIBLE "Tour panorámico en dirigible" / _DESC "Vuelo de fin de semana sobre la Isla del Norte."
**M68.STOP (10):** estacion_central "Estación Central" | muelle_raiz_sur "Muelle Sur de Aurora" | plataforma_norte "Plataforma del Norte" | puerto_aurora "Puerto de Aurora" | puerto_brisa "Puerto de la Isla Brisa" | puerto_espejo "Puerto de la Isla Espejo" | puerto_este "Puerto de la Isla del Este" | puerto_festival "Puerto del Festival" | puerto_norte "Puerto de la Isla del Norte" | puerto_sur "Puerto de la Isla del Sur"
**M68.TRIP (16):** ARRIVED_AT "Has llegado a {destino}." | CURRENCY [NO-TRADUCIR: AO] | DURATION "Duración: {duracion}" | HORAS [PLURAL: [0]"{n} hora"/[1]"{n} horas"] | HORAS_MINUTOS [NO-TRADUCIR: "{h} h {m} min"] | LOADING "Preparando el viaje..." | LOCKED "Destino bloqueado" | MINUTOS [PLURAL: [0]"{n} minuto"/[1]"{n} minutos"] | NO_MONEY "Te faltan monedas: cuesta {precio}" | OUT_OF_SCHEDULE "Fuera de horario ({horario}). ¿Esperar?" | PRICE "Precio: {precio}" | SCHEDULE "Horario: {horario}" | SEGUNDOS [PLURAL: [0]"{n} segundo"/[1]"{n} segundos"] | SPECIAL_ONLY "Sólo disponible durante {evento}" | TRAVELING_TO "Viajando a {destino}..."
**DIARY (14):** CAT_CARTAS "Cartas" | CAT_CRIATURAS "Criaturas" | CAT_DESCUBRIMIENTOS "Descubrimientos" | CAT_EVENTOS "Eventos" | CAT_FOTOGRAFIAS "Fotografías" | CAT_MINERALES "Minerales" | CAT_MISIONES "Misiones" | CAT_PERSONAJES "Personajes" | CAT_PISTAS "Pistas" | CAT_PLANTAS "Plantas" | CAT_RECETAS "Recetas" | CAT_RUINAS "Ruinas" | CAT_SELLOS "Sellos" | ENTRADAS "Entradas"
**CLOCK (4):** ESTACIONES.0 "Primavera" | .1 "Verano" | .2 "Otoño" | .3 "Invierno"
**ITEMS (2):** MADERA "Madera" | MADERA_DESC "Madera sólida de la isla Aurora."
**Sueltas (5):** MAIN_MENU.OPTIONS "Opciones" | HUD.VIDA "Vida" | SETTINGS.IDIOMA "Idioma" | DIALOGOS.VECINO_SALUDO "¡Hola, vecino!" | UI.INTERACTUAR "Interactuar"
**npc (1):** npc.catalina "Catalina" (exenta por const NO_TRADUCIBLES + EXCEPCIONES_CLAVE del ValidadorPO; msgstr=msgid sin marcador).

Notas: M68.ROUTE.r_* y claves con segmentos minúsculos generan aviso R10 (ya existe hoy en es.po — no es deuda nueva). Los 102 traducibles del lote siguen el canon PT del msg 275.

### QA ESTRUCTURAL LOTE-115 + DRIFT-CONTEO (2026-10-25 22:00Z, msg 278)
- R10 (convención clave): 74 cumplen / 40 avisos heredados de es.po (M68.ROUTE ×20, M68.SIGN ×10, M68.STOP ×10 — segmentos minúsculos) / 1 exenta const (npc.catalina). Avisos NO bloqueantes (ok=true sigue en true).
- R12: 0 mezclas {llave}+printf en el lote. printf %s/%d en lote: 0 — todo {llave} (las cadenas con printf están en las 159 copiables: CRAFT_OK/DESCARTAR/COMPRA_INFO/VENTA_INFO/HORAS_H/MIN_M).
- Placeholders del lote (P3 — PT debe conservar idénticos): {destino}×13, {metros}×11, {horario}×2, {precio}×2, {duracion}×1, {evento}×1, {h}×1, {m}×1. 95 claves sin placeholder.
- R15 plurales ES: HORAS/MINUTOS/SEGUNDOS tienen {n} en [0] y [1] → OK; PT mantiene {n} en ambas formas.
- Drift deuda D1-D17 (22:00Z): actividad 24-oct 22:34-23:22 LOCAL en 05-Checklist de 9 módulos del riel = patrón recálculo del director (generar_checklist_global), NO movimiento de dueños. M87 sin toque desde 24-oct 05:41.
- Drift conteo §21.8.2.b (conteo real ^- [x]/[ ]/[?] vs GLOBAL): GLOBAL coherente en 9/10 módulos del riel. **M72 GLOBAL STALE: tablero 108/200 vs real 194[x]/3[ ]/3[?]=194/200 (drift 86 ítems >> umbral 5; M72 es candidato a sello en catch-up G del director — reportado para update de fila pre-sello)**. Totales internos stale (deuda documental de dueños, no tocados): 09 declara 106/101/5 (reales 110/0/5, total 115), 105 declara 129/33/162 (reales 143/0/28, total 171), 118 declara 107 (reales 113).

### ESQUELETO PT.PO PRE-BUILD EN TEMP (2026-10-25 23:00Z, msg 280)
- Artefacto: `C:\Users\MAURY-~1\AppData\Local\Temp\kilo\pt_po_esqueleto.po` (18.101 bytes, Temp — NO en repo). Builder: Temp build_esqueleto_pt.py (parser crudo corregido replicando ValidadorPO L372-384: msgid_plural ANTES de msgid; cierre ante msgid repetido).
- Composición 274 = 159 copiables (PT de strings_pt.json; ITEMS.SE_OFRECEN canonicalizado a plural) + 13 no-traducir lote (msgstr=msgid, marcadores replicados) + 3 plurales M68 pre-llenados + npc.catalina + 98 vacías (pendiente R6).
- 4 plurales pre-llenados: ITEMS.SE_OFRECEN [0]"Oferecendo {n} item"/[1]"Oferecendo {n} itens"; M68.TRIP.HORAS [0]"{n} hora"/[1]"{n} horas"; MINUTOS [0]"{n} minuto"/[1]"{n} minutos"; SEGUNDOS [0]"{n} segundo"/[1]"{n} segundos".
- **50 marcadores '#. no-traducir'**: 15 originales de es.po + 32 cognatos PT==ES de las 159 (aprobación P5 agnes 277) + 3 unidades M68 (hallazgo nuevo: plurales HORAS/MINUTOS/SEGUNDOS son PT==ES → marcador '#. no-traducir: unidad de tiempo legítima (PT=ES)').
- Header PT: Language: pt + Plural-Forms: nplurals=2; plural=(n > 1) (reemplazo sobre header de es.po). UTF-8 sin BOM, LF.
- Verificación canónica: V.parse_po paridad es.po==esqueleto True (274=274); 98 vacías por dominio (M68=73, DIARY=14, CLOCK=4, ITEMS=2, MAIN_MENU/HUD/SETTINGS/DIALOGOS/UI=1 c/u); P5 sin marcador: 0 (npc.catalina exenta por const NO_TRADUCIBLES); R14/R15 ok (plurales completos, {n} en ambas formas).
- **Hallazgo de formato**: es.po tiene ~14 tramos compactos (entradas pegadas sin línea vacía entre ellas); V.parse_po canónico lo tolera (ValidadorPO L375-384 cierra entrada ante msgid repetido). Todo parser propio debe replicar esa tolerancia o usar V.parse_po.
- **Vuelta de GO reducida**: (1) traducir 98 msgstr con canon PT (msg 275) → (2) copiar Temp→game/isla-ancestral/locales/pt.po → (3) LOCALES_SOPORTADOS += "pt" (localization_manager.gd:15) → (4) ValidadorPO.validar_par(es.po, pt.po) → (5) doc M87 + reporte. R6/P5/R14/R15 garantizados por construcción.

### QA CANONICO ESQUELETO PT.PO + BUG CLAVE-COMO-TEXTO CORREGIDO (2026-10-26 00:00Z, msg 282)
- QA profundo del esqueleto Temp (18.163 bytes) replicando R1-R15/P1-P5 del ValidadorPO + regla nueva **K1 (msgstr≠clave)**, con parser tolerante corregido (comentarios PO → entrada SIGUIENTE vía buffer pendiente; antes se desplazaban a la entrada anterior).
- **HALLAZGO MATERIAL**: builder v2 (msg 280) puso msgstr=CLAAVE en las 13 no-traducir del lote — M68.SIGN.GENERICO/estacion_central/muelle_raiz_sur/plataforma_norte/puerto_aurora/brisa/espejo/este/festival/norte/sur + M68.TRIP.CURRENCY + M68.TRIP.HORAS_MINUTOS. La ratificación por paridad de claves (274=274) NO lo detecta: paridad de claves ≠ paridad de contenido. Impacto si llegaba al repo: runtime mostraba la clave ("M68.SIGN.puerto_sur") en el cartel/flecha.
- **Corrección aplicada en Temp** (report-only): msgstr = texto plantilla ES (idéntico en PT por ser plantilla sin palabras / código de divisa / unidades): SIGN×11 → "→ {destino} · {metros} m"; CURRENCY → "AO"; HORAS_MINUTOS → "{h} h {m} min". Cabecera normalizada: header PT 5 líneas + '# M87: Catálogo portugués (esqueleto pre-build Temp — pendiente GO #4 del fundador)'.
- **QA final 12/12 PASS**: R1 sin BOM / R2 LF / R4 header PT (Language: pt; Plural-Forms nplurals=2; plural=(n > 1)) / P1 paridad orden+conteo 275=275 / R7 0 dup / R6 98 vacías (M68=73, DIARY=14, CLOCK=4, ITEMS=2, sueltas=5) / R8+R13+R14 4/4 plurales [0]+[1] / P3+R15 placeholders PT==ES cross-catalog 0 desajustes / P5 50 marcadores + 0 PT==ES sin marcador (npc.catalina exenta const) / K1 0 clave-como-texto / marcadores crudos=50.
- **Falsos positivos propios corregidos** (honestidad): checker v1 fallaba R4 (buscaba startswith('Language:') en líneas crudas — en PO la metadata va dentro de strings continuadas con comillas) y P3/R15 (comparaba placeholders contra msgid-clave — en este corpus msgid=clave; la comparación canónica es cross-catalog contra msgstr ES de es.po).
- **Lecciones para el GO y checklist pre-GO**: (1) K1 — ninguna msgstr puede ser igual a su clave (propuesto a agnes/Hy3 para validar_par o checklist; Ling no toca validador_po.gd en standby); (2) parsers PO: comentarios '#.' pertenecen a la entrada SIGUIENTE (buffer pendiente); (3) placeholders se validan contra el catálogo fuente (msgstr ES), no contra el msgid-clave.
- Scripts Temp reproducibles: qa_esqueleto_canonico.py (v1, hallazgo), corregir_y_qa_esqueleto.py (fix 13 + QA v2 15/15), fix_header_y_verificar_final.py (cabecera + 12/12 final). Esqueleto: C:\Users\MAURY-~1\AppData\Local\Temp\kilo\pt_po_esqueleto.po.
- Repo intacto: git status 0 modificaciones en game/isla-ancestral/locales/, scripts/localization/, data/localizacion/ (los M del status son de otros agentes/módulos: M53 L159 flip, coleccionables, otros canales). pt.po sigue ausente; LOCALES_SOPORTADOS=["es","en"] (localization_manager.gd L15) intacto; es.po sin cambios desde commit 2026-10-21.

### PRE-TRADUCCION STANDBY DE LAS 98 — ESQUELETO PT.PO 274/274 COMPLETO EN TEMP (2026-10-26 00:00Z, msg 284)
- Artefacto: `C:\Users\MAURY-~1\AppData\Local\Temp\kilo\pt_po_esqueleto.po` (21.244 bytes, Temp — NO en repo). Inyector: Temp aplicar_pre_traduccion_98.py + repair_header_y_qa_final.py. QA final 15/15 PASS.
- Canon aplicado (ratificado agnes 277/281): salvar/item/peça/loja/diário/excluir/ilha/ânimo(AO)/você-imperativo formal + **placeholders {llave} INALTERADOS** (contrato con el código: transport_localizer.gd L37 CLAVE_ARRIVED, transport_trip_planner.gd L39 CLAVE_LLEGADA).
- **11 cognatos nuevos marcados '#. no-traducir: cognato legítimo (PT=ES)'** (61 marcadores totales = 50 + 11): HUD.VIDA, SETTINGS.IDIOMA, CLOCK.ESTACIONES.0, DIARY.ENTRADAS, DIARY.CAT_CRIATURAS, DIARY.CAT_PLANTAS, DIARY.CAT_PISTAS, DIARY.CAT_CARTAS, DIARY.CAT_EVENTOS, M68.EVENT.LLEGADA_FINNEAS, M68.TRIP.LOCKED.
- Tabla completa 98 (clave | ES | PT):
  - Sueltas (5): MAIN_MENU.OPTIONS "Opciones"→"Opções" | HUD.VIDA "Vida"→"Vida" [COG] | SETTINGS.IDIOMA "Idioma"→"Idioma" [COG] | DIALOGOS.VECINO_SALUDO "¡Hola, vecino!"→"Olá, vizinho!" | UI.INTERACTUAR "Interactuar"→"Interagir"
  - CLOCK (4): ESTACIONES.0 "Primavera"→"Primavera" [COG] | .1 "Verano"→"Verão" | .2 "Otoño"→"Outono" | .3 "Invierno"→"Inverno"
  - ITEMS (2): MADERA "Madera"→"Madeira" | MADERA_DESC "Madera sólida de la isla Aurora."→"Madeira sólida da ilha Aurora."
  - DIARY (14): ENTRADAS→"Entradas" [COG] | CAT_PERSONAJES→"Personagens" | CAT_CRIATURAS→"Criaturas" [COG] | CAT_PLANTAS→"Plantas" [COG] | CAT_MINERALES→"Minerais" | CAT_RECETAS→"Receitas" | CAT_PISTAS→"Pistas" [COG] | CAT_SELLOS→"Selos" | CAT_RUINAS "Ruinas"→"Ruínas" | CAT_CARTAS→"Cartas" [COG] | CAT_DESCUBRIMIENTOS→"Descobertas" | CAT_MISIONES→"Missões" | CAT_EVENTOS→"Eventos" [COG] | CAT_FOTOGRAFIAS "Fotografías"→"Fotografias"
  - M68.EVENT (10): DIRIGIBLE_LUNA "Luna sube contigo"→"A lua sobe com você" | .SENAL "Luna señala las islas desde el aire."→"A lua sinaliza as ilhas vistas do ar." | FESTIVAL_CATALINA→"Catalina no festival" | .SENAL "Catalina te llama entre los faroles."→"Catalina te chama entre os lampiões." | LLEGADA_FINNEAS "Finneas te espera"→idem [COG] | .SENAL "Finneas levanta la mano al verte llegar."→"Finneas levanta a mão ao te ver chegar." | MUELLE_MATEO "Mateo charla en el muelle"→"Mateo conversa no cais" | .SENAL "Ves a Mateo saludando desde el muelle."→"Você vê Mateo acenando do cais." | PUERTO_BRUNO "Bruno te despide"→"Bruno te despede" | .SENAL "Bruno te grita un consejo desde el pantalán."→"Bruno te grita um conselho do píer."
  - M68.NARR (9): C4.01→"O vento muda ao sair do porto." | C4.02 "Finneas señala el templo en el horizonte."→"Finneas sinaliza o templo no horizonte." | C4_BRIS "Travesía al Templo de la Brisa"→"Travessia ao Templo da Brisa" | C7.01 "El mar está demasiado quieto."→"O mar está quieto demais." | C7.02 "Los siete sellos pesan en la mochila."→"Os sete selos pesam na mochila." | C7.03 "La Cámara espera bajo el templo."→"A Câmara espera sob o templo." | C7_CAMARA→"Travessia à Câmara do Selo" | FINAL_SECRETO→"Travessia ao segredo do Espelho" | SECRETO.01 "Las pistas pagadas por fin encajan."→"As pistas pagadas finalmente encaixam."
  - M68.ROUTE (20, → conservado): r_aurora_brisa→"Porto de Aurora → Porto da Ilha Brisa" | r_aurora_espejo→"Porto de Aurora → Porto da Ilha Espelho" | r_aurora_estacion→"Porto de Aurora → Estação Central" | r_aurora_este→"Porto de Aurora → Porto da Ilha do Leste" | r_aurora_muelle→"Porto de Aurora → Cais Sul de Aurora" | r_aurora_plataforma→"Porto de Aurora → Plataforma do Norte" | r_aurora_sur→"Porto de Aurora → Porto da Ilha do Sul" | r_estacion_aurora→"Estação Central → Porto de Aurora" | r_este_aurora→"Porto da Ilha do Leste → Porto de Aurora" | r_este_muelle→"Porto da Ilha do Leste → Cais Sul de Aurora" | r_festival_muelle→"Porto do Festival → Cais Sul de Aurora" | r_muelle_aurora→"Cais Sul de Aurora → Porto de Aurora" | r_muelle_este→"Cais Sul de Aurora → Porto da Ilha do Leste" | r_muelle_festival→"Cais Sul de Aurora → Porto do Festival" | r_muelle_sur→"Cais Sul de Aurora → Porto da Ilha do Sul" | r_norte_plataforma→"Porto da Ilha do Norte → Plataforma do Norte" | r_plataforma_aurora→"Plataforma do Norte → Porto de Aurora" | r_plataforma_norte→"Plataforma do Norte → Porto da Ilha do Norte" | r_sur_aurora→"Porto da Ilha do Sul → Porto de Aurora" | r_sur_muelle→"Porto da Ilha do Sul → Cais Sul de Aurora"
  - M68.SPECIAL (14): FESTIVAL_INVIERNO→"Viagem ao Festival de Inverno" | _DESC→"Parada temporária no Porto do Festival." | FESTIVAL_LUCES→"Viagem ao Festival das Luzes" | _DESC "Travesía nocturna a los faroles."→"Travessia noturna aos lampiões." | FESTIVAL_OTONO→"Viagem ao Festival de Outono" | _DESC→"Parada temporária no Porto do Festival." | FESTIVAL_PRIMAVERA→"Viagem ao Festival da Primavera" | _DESC→"Parada temporária no Porto do Festival." | FESTIVAL_VERANO→"Viagem ao Festival de Verão" | _DESC→"Parada temporária no Porto do Festival." | LUNA_LLENA "Tour de luna llena"→"Passeio de lua cheia" | _DESC "Travesía nocturna a la Isla Espejo, con recargo."→"Travessia noturna à Ilha Espelho, com recargo." | TOUR_DIRIGIBLE "Tour panorámico en dirigible"→"Passeio panorâmico de dirigível" | _DESC "Vuelo de fin de semana sobre la Isla del Norte."→"Voo de fim de semana sobre a Ilha do Norte."
  - M68.STOP (10): estacion_central→"Estação Central" | muelle_raiz_sur→"Cais Sul de Aurora" | plataforma_norte→"Plataforma do Norte" | puerto_aurora→"Porto de Aurora" | puerto_brisa→"Porto da Ilha Brisa" | puerto_espejo→"Porto da Ilha Espelho" | puerto_este→"Porto da Ilha do Leste" | puerto_festival→"Porto do Festival" | puerto_norte→"Porto da Ilha do Norte" | puerto_sur→"Porto da Ilha do Sul"
  - M68.TRIP (10, placeholders intactos): ARRIVED_AT "Has llegado a {destino}."→"Você chegou a {destino}." | DURATION "Duración: {duracion}"→"Duração: {duracion}" | LOADING→"Preparando a viagem..." | LOCKED→"Destino bloqueado" [COG] | NO_MONEY "Te faltan monedas: cuesta {precio}"→"Faltam moedas: custa {precio}" | OUT_OF_SCHEDULE "Fuera de horario ({horario}). ¿Esperar?"→"Fora do horário ({horario}). Esperar?" | PRICE→"Preço: {precio}" | SCHEDULE→"Horário: {horario}" | SPECIAL_ONLY "Sólo disponible durante {evento}"→"Disponível somente durante {evento}" | TRAVELING_TO "Viajando a {destino}..."→"Viajando para {destino}..."
- Balance final del esqueleto 274: 212 PT≠ES (traducción efectiva: 125 de las 159 copiables + 87 de las 98 nuevas) + 58 PT==ES (marcados/exentos: 34 copiables cognatos + EQUIP.EQUIPADO + DIARY.BLOQUEADO + 13 no-traducir lote + 3 unidades plurales + 11 cognatos nuevos + npc.catalina exenta) + 4 plurales canónicos.
- **Vuelta de GO #4 (plan 243, UNA vuelta)**: (1) copiar Temp/pt_po_esqueleto.po → game/isla-ancestral/locales/pt.po → (2) localization_manager.gd L15 LOCALES_SOPORTADOS ["es","en"]→["es","en","pt"] → (3) ValidadorPO.validar_par(es.po, pt.po) (K1 ya aprobado por agnes 283 para el checklist pre-GO) → (4) doc M87 plan-actual → (5) reporte + QA cruzada §21.8. TODO el contenido ya está traducido y QA'd 15/15 en Temp.
- Errores propios corregidos (honestidad): (a) extractor imprimió `{{destino}}` — artefacto de formato; grep es.po L574-575 + repr confirman ES limpio "Has llegado a {destino}."; (b) serializer del inyector duplicó el header (header manual + header parseado = 276 entradas → P1/R7 FAIL) → repair descartó 2 headers parseados → 275=275. Lección: al re-serializar un PO parseado, saltar la entrada header (msgid "") y escribirla una sola vez.
- **Post-QA canónica (msg 284, validador REAL del proyecto)**: (c) dedup artefacto de buffer — los comentarios PO pendientes se acumulan tras líneas vacías (MAIN_MENU.PLAY arrastraba 2× '# M87:' de mi header); eliminados, comments históricos ES conservados (L808 encargo 146, L862 M149). (d) `scripts/validar_i18n_integridad.py`: V.parse_po paridad ES==ESQUELETO **274=274 orden+contenido PASS** (nota: V.claves_recursivo es para JSON, no para .po). (e) **Divergencia 11 claves SOLO-JSON preexistente** (ui.inventario/tienda/diario/mapa/guardar/opciones, msg.inventario_lleno/no_materiales/nuevo_dia, npc.hola/adios): NO están en es.po NI en en.po (conciliación bloqueada msg 153; el validador la reporta como ADVERTENCIA) — ya tienen PT en strings_pt.json (Inventário/Loja/Diário/Mapa/Salvar/Opções/Inventário cheio/Faltam materiais/Novo dia/Olá/Tchau); fuera de alcance del esqueleto (espejo de es.po). **Estado final esqueleto Temp: 21.156 B, 906 líneas, QA 15/15 propio + paridad 274=274 validador real + 159/170 JSON presentes (11 solo-JSON preexistentes documentadas).**

### ARQUITECTURA DE LOCALE + BLINDAJE PRE-GO + K2/K3 (2026-10-26 02:00Z, msg 286)
- **Autoload vigente** (project.godot L59): `Localization="*res://scripts/localization/localization_manager.gd"` (SIN acento, 377 líneas, Deepseek 2026-08-30). `_cargar_catalogos()` L35-46: por cada locale de LOCALES_SOPORTados parsea `res://locales/{locale}.po` con parser propio `_parse_po` L276-328 (msgid_plural ANTES de msgid L291-293 ✓; salta `#` y vacías L289 ✓; header msgid "" ignorado L316 ✓; continuaciones multilinea L319-324 ✓; plural fallback ES L173-179 ✓) + `TranslationServer.add_translation` L46 (tr() estándar también vive). `set_locale` L98-104 rechaza locale fuera de LOCALES_SOPORTADOS. `obtener_estado_catalogos()` L250-268 = QA runtime (faltantes/vacías vs ES).
- **Manager JSON HUÉRFANO**: `scripts/localizacion/localization_manager.gd` (CON acento, 82 líneas, deepseek 2026-09-02) lee `data/localizacion/strings_*.json` (L23-35) pero NO está registrado como autoload (test_catalogo_exhaustivo_m87.gd L11-13 lo documenta: el autoload Localization NO lee el JSON). Consecuencia: **pt.po cubre el 100% del runtime vigente**; strings_pt.json es fuente histórica de build (159 claves migradas al .po), no runtime.
- **Fidelidad 159/159 JSON↔PO PASS** (Temp/audit_fidelidad_159.py + verificar_runtime_json_y_fidelidad.py): 158 textos exactos + ITEMS.SE_OFRECEN expansión plural canónica (JSON singular 'Oferecendo {n} item' == PO msgstr[0]; PO añade [1] 'itens').
- **Conciliación 11 solo-JSON = MORTUAS** (Temp/conciliar_11_solo_json.py + conciliacion_11_solo_json.md): ui.inventario/tienda/diario/mapa/guardar/opciones, msg.inventario_lleno/no_materiales/nuevo_dia, npc.hola/adios → 0 consumidores vivos en .gd/.tscn/.tres de game/; único hit = scripts/localizacion/Obsoletos/2026-10-08_..._test...bug104.gd (ui.inventario L98, npc.adios L99, npc.hola L128). Recomendación: depurarlas de los 3 strings_*.json → libera conciliación bloqueada msg 153. **Decisión del director/fundador** (standby no toca data/).
- **K2 (nuevo, medido)**: `localization_manager.gd` L358-361 `_indice_plural(locale, n, nformas)`: `if locale == "es" or locale == "en": return 0 if n == 1 else mini(1, nformas - 1)` — **"pt" no está** → devuelve 0 siempre → los 4 plurales PT (ITEMS.SE_OFRECEN, M68.TRIP.HORAS/MINUTOS/SEGUNDOS) usarían la forma SINGULAR con n>1 ("Oferecendo 2 item"). Fix 1 línea: `if locale == "es" or locale == "en" or locale == "pt":` (nplurals=2; plural=(n > 1) — misma regla que es/en).
- **K3/K4 (nuevos, medidos)**: `locale_utils.gd` TABLAS L12-15 y NOMBRES_NATIVOS L17-20 solo es/en → `locales_soportados()` L76-77 (usada "para selector y validación") no listaría pt; `get_nombre_nativo("pt")` L22-23 cae en fallback devolviendo "pt" crudo en el selector de idioma. Fix: `"pt": "Português"` en NOMBRES_NATIVOS + entrada `"pt"` en TABLAS (decimal ",", miles ".", fecha "d/m/Y", reloj_24h true — formato numérico/fecha PT-BR == ES).
- **Checklist pre-GO ampliado 5→7 pasos** (msg 286 §4): (1) cp Temp/pt_po_esqueleto.po→locales/pt.po; (2) localization_manager.gd L15 += "pt"; (3) K2 _indice_plural += "pt"; (4) K3/K4 locale_utils += "pt" (TABLAS+NOMBRES_NATIVOS); (5) ValidadorPO.validar_par(es.po, pt.po) (K1 aprobado agnes 283); (6) doc M87 plan-actual; (7) reporte + QA cruzada §21.8. Nota adicional GO-time: test_catalogo_exhaustivo_m87.gd L41-42 hardcodea RUTA_ES/RUTA_EN — extender con RUTA_PT si el director lo pide; test_placeholders_plurales_m87.gd revisar cobertura pt.

### SIMULADOR RUNTIME PRE-GO — PARSER DE PRODUCCIÓN + K2/K3/K4 (2026-10-26 03:00Z, msg 288)
- Agnes 287: RATIFICA K2/K3/K4 como parte obligatoria del MISMO acto del GO; 7 pasos = plan definitivo aprobado; 11 mortuas = deuda data- menor del fundador (no bloquea GO).
- **Metodología**: replica FIEL de `_parse_po` (localization_manager.gd L276-328) en Python — el parser que USARÁ EL JUEGO, distinto del ValidadorPO (QA). Evidencia: Temp/simulador_runtime_pre_go.py (4 bloques, 15 PASS).
- **Bloque 1 — parseo de los 3 catálogos con parser de producción**: es=270 mensajes+4 plurales; en=270+4; pt(esqueleto)=270+4; **paridad de claves 274=274=274**; header ignorado, comentarios '#'/'#.' saltados, continuaciones multilinea OK. Plurales PT en producción: ITEMS.SE_OFRECEN ['Oferecendo {n} item','Oferecendo {n} itens'], M68.TRIP.HORAS ['{n} hora','{n} horas'], MINUTOS ['{n} minuto','{n} minutos'], SEGUNDOS ['{n} segundo','{n} segundos'].
- **Bloque 2 — K2 necesario y suficiente**: _indice_plural sin fix: pt n=2→forma[0] (bug "Oferecendo 2 item"); con fix `or locale == "pt"`: n=1→[0] ✓, n=2→[1] ✓. Demo con SE_OFRECEN real.
- **Bloque 3 — K3/K4**: NOMBRES_NATIVOS["pt"]="Português"; TABLAS["pt"]={decimal ",", miles ".", fecha d/m/Y, reloj_24h true} (== formato ES, correcto para pt-BR); locales_soportados() incluye "pt".
- **Bloque 4 — post-GO obtener_estado_catalogos()**: pt vs es → faltantes=0, vacías=0, ok=true (QA runtime del manager en verde).
- **Veredicto**: esqueleto Temp parsea IDÉNTICO a es.po/en.po en el runtime real; vuelta GO blindada contra ambos parsers (ValidadorPO QA + _parse_po producción). Los fixes K2/K3/K4 de 1 línea son necesarios y suficientes.

### QA TERMINOLÓGICO 98 + PARTICIÓN EXACTA + PLANTILLA LOG GO + CONTINGENCIA (2026-10-26 04:00Z, msg 290)
- Agnes 289: acuse 288 ratificado — "GO 100% turnkey y des-riesgado: vuelta = 7 pasos + firma + log. Queda solo el GO del fundador". Standby ratificado.
- **QA TERMINOLÓGICO de las 98** (Temp/qa_terminologico_98.py) — 6 ejes, **98/98 PASS, 0 flags**: (1) placeholders intactos ES↔PT ({destino}/{duracion}/{precio}/{horario}/{evento}); (2) topónimos uniformes — 6 pares verificados (Puerto de la Isla X→Porto da Ilha X, Puerto de Aurora→Porto de Aurora, Puerto del Festival→Porto do Festival, Muelle Sur de Aurora→Cais Sul de Aurora, Estación Central→Estação Central, Plataforma del Norte→Plataforma do Norte); (3) 0 palabras ES residuales en PT — NOTA HONESTA: 4 flags iniciales eran FALSOS POSITIVOS (los placeholders literales {precio}/{horario} casaban con la palabra ES; checker corregido con re.sub(r'\{[a-zA-Z_]+\}',' ',pt) antes de buscar); (4) uniformidad ES→PT 1:1 (mismo ES → mismo PT; ej. SPECIAL_DESC "Parada temporal en el Puerto del Festival." idéntica ×4); (5) 11 cognatos del lote con marcador '#. no-traducir: cognato legítimo (PT=ES)' y PT==ES; (6) canon de acentos presente (Estação/Verão/Outono/Ruínas/Missões/Receitas/Minerais/Descobertas/Fotografias/Personagens/Opções/Interagir/vizinho/Você/Duração/Preço/Horário/lampiões/píer/Câmara/segredo/Espelho/encaixam/dirigível/lua cheia/fim de semana/temporária/noturna) + 0 ¿/¡.
- **Partición exacta del esqueleto (medida en disco, Temp/particion_270.py + Temp/verificar_cobertura_274.py)**: 274 = 270 simples + 4 plurales. Simples = **158** JSON-comunes (PT de strings_pt.json) + **98** lote pre-traducido + **13** marcadas no-traducir (11 M68.SIGN.* = plantilla sin palabras "→ {destino} · {metros} m" + M68.TRIP.CURRENCY="AO" divisa + M68.TRIP.HORAS_MINUTOS="{h} h {m} min" unidades) + **1** exenta npc.catalina ("Catalina", nombre propio, EXCEPCIONES_CLAVE del ValidadorPO, PT==ES legítimo sin marcador). Plurales = ITEMS.SE_OFRECEN (viene de JSON) + M68.TRIP.HORAS/MINUTOS/SEGUNDOS (nuevas M68). Aclaración histórica: el "159" de msgs anteriores = 158 simples + 1 plural (SE_OFRECEN); fidelidad 159/159 = todas las claves JSON migradas al .po.
- **Blindaje pre-GO completo = 4 capas**: (1) formato — QA 15/15 + paridad validador real 274=274; (2) parser producción — _parse_po L276-328 replica: 270+4 ×3 catálogos, paridad 274=274=274; (3) contenido — terminológico 98/98 + fidelidad 159/159 JSON↔PO; (4) arquitectura — K2/K3/K4 medidas y ratificadas por agnes 287 como parte obligatoria del GO.
- **Plantilla Log GO** (Temp/plantilla_log_go_pt_runtime.md): formato §6.2 completo (Resumen/Cambios/Archivos/Evidencia) con los 7 pasos; al GO se reserva número de Logs/NUMEROS_DISPONIBLES.txt (§6.1.a) y se completa. Acelera la vuelta GO.
- **Plan contingencia Temp**: si Temp se limpia antes del GO, el esqueleto es 100% reproducible desde el repo: build v2 (es.po → header PT Language: pt + Plural-Forms nplurals=2; plural=(n > 1)) + inyectar 158 PT de strings_pt.json + 98 de la tabla del anexo PRE-TRADUCCION 98 (este backlog) + 13 marcadas + Catalina + 4 plurales (SE_OFRECEN JSON + 3 TRIP). Scripts generadores en Temp: build_esqueleto_pt.py, aplicar_pre_traduccion_98.py, repair_header_y_qa_final.py, repair2_dedup_comments_y_qa.py, simulador_runtime_pre_go.py, qa_terminologico_98.py, particion_270.py.

### RÉPLICA DEL VALIDADORPO REAL — ÁRBITRO DE LA VUELTA GO (2026-10-26 05:00Z, msg 292)
- Agnes 291: acuse 290 ratificado; GO "100% turnkey y des-riesgado"; plantilla Log + contingencia confirmadas; "sobre el GO, la vuelta = 7 pasos + firma + log (plantilla lista → una línea)".
- **Metodología**: traducción fiel línea por línea de `scripts/localization/validador_po.gd` (467L, DeepSeek-V4.1-Flash 2026-09-13) a Python (Temp/validador_replica_po.py): `_parsear` (tolerante: buffer de comentarios, msgid_plural ANTES de msgid, msgstr[N] con _idx_msgstr, continuaciones según `ultimo`, flags corrupto/basura), `validar_archivo` (R1 BOM, R2 CRLF, R3 UTF-8, R4 cabecera Content-Type/Language/Plural-Forms+nplurals, R5, R6 vacío, R7 duplicados, R8, R10 convención UPPER_SNAKE + EXCEPCIONES_CLAVE=["npc.catalina"], R11 espacios, R12 mezcla {llave}+printf, R13, R14 completitud 0..nplurals-1 + contigüidad, R15 firmas de placeholders entre formas), `validar_par` (P1 faltantes=ERROR, P2 huérfanas=AVISO, P3 placeholders_desalineados=ERROR — `placeholders_de` une {llaves}+printf de simple y todas las formas plurales, P5 sin traducir=AVISO — `textos[k]` para plurales = JOIN " | " de formas; exentas = NO_TRADUCIBLES ["npc.catalina","SETTINGS.SLOTS"] + marcadores '#. no-traducir' de AMBOS archivos), `formatear_informe`.
- **Resultado es↔pt(esqueleto): RESULTADO OK — 0 errores, 0 avisos.** P1=0, P2=0, P3=0, P5=0, exentas_p5=62 (61 marcadas + npc.catalina), no_traducibles=61, entradas=275 (274 claves + header), nplurals=2, locale='pt'.
- **Baseline es↔en: RESULTADO OK** (exentas_p5=17) — valida la réplica contra el par oficial del repo.
- **Hallazgo 1 (gap P5-plurales ya cubierto)**: P5 compara el JOIN de formas plurales; los plurales cognatos PT==ES (M68.TRIP.HORAS/MINUTOS/SEGUNDOS) YA llevan marcador '#. no-traducir' en el esqueleto → figuran en exentas_p5, no en no_traducidas. Sin el marcador serían avisos P5 en la vuelta GO.
- **Hallazgo 2 (R10 preexistente)**: claves M68.SIGN.* minúsculas (ids de datos M68) no cumplen UPPER_SNAKE → aviso R10 en validar_archivo individual; **NO se propaga al informe de validar_par** (formatear_informe de par solo muestra errores/avisos del par: P2/P5) ni bloquea ok. Idéntico en es.po (baseline). No es deuda del esqueleto.
- **Hallazgo 3**: avisos internos de validar_archivo (R4/R5/R6/R8/R10/R12) no se listan en el informe de par; en el esqueleto son 0 salvo R10 heredada de SIGN.
- **Drift-check base (05:00Z)**: es.po 19.815B mtime 2026-10-21 sha1 8e326b00e0f6; en.po 18.909B misma fecha; strings_pt.json 8.540B y strings_es.json 8.566B (2026-10-20). **Base sin drift** — el esqueleto sigue sincronizado con la fuente.
- **Blindaje pre-GO = 5 capas**: (1) formato QA 15/15 + paridad validador real 274=274; (2) parser producción _parse_po 270+4, paridad 274=274=274; (3) contenido terminológico 98/98 + fidelidad 159/159; (4) arquitectura K2/K3/K4 ratificadas (agnes 287); (5) **árbitro real: ValidadorPO réplica fiel OK 0/0**.
- Vuelta GO: 7 pasos + firma + log (plantilla Temp/plantilla_log_go_pt_runtime.md; número de log se reserva de Logs/NUMEROS_DISPONIBLES.txt §6.1.a).

### PREVIEW DE PARCHES GO — VUELTA 100% MECÁNICA (2026-10-26 06:00Z, msg 294)
- Agnes 293: acuse 292 ratificado — blindaje 5 capas, "la vuelta GO = 7 pasos + firma + log (plantilla lista), sin sorpresas de QA".
- **Preview de parches** (Temp/preview_parches_go.py genera Temp/preview_parches_go.md): precondiciones (pt.po ausente, LOCALES ["es","en"], esqueleto 21.156B sha1 verificable) + 5 parches con anchors verificados ÚNICOS (count==1):
  1. cp esqueleto Temp → `game/isla-ancestral/locales/pt.po` (verificar sha1 post-copia).
  2. `localization_manager.gd` L15: `const LOCALES_SOPORTADOS := ["es", "en"]` → `["es", "en", "pt"]`.
  3. `localization_manager.gd` L359 (K2): `if locale == "es" or locale == "en":` → `... or locale == "pt":` (+ comentario L357 "es/en"→"es/en/pt").
  4. `locale_utils.gd` TABLAS (K3): + `"pt": {"decimal": ",", "miles": ".", "fecha": "d/m/Y", "reloj_24h": true},` (== formato ES, correcto pt-BR).
  5. `locale_utils.gd` NOMBRES_NATIVOS (K4): + `"pt": "Português",`.
- **QA post-GO (paso 5)**: ValidadorPO.validar_par(es.po, pt.po) → ok=true 0 errores (réplica árbitro ya OK 0/0); obtener_estado_catalogos() pt faltantes=0/vacías=0/ok=true; K2 demo n=2→"Oferecendo {n} itens".
- **Detalle técnico**: indentación GDScript = TABS (preservar en edits); los 4 anchors son substrings únicos (count==1 verificado) → los edits de la vuelta GO no pueden fallar ni pisar otro bloque.
- **Drift-check base 06:00Z**: es.po sha1 8e326b00e0f6, en.po 14d379756a2b, strings_pt.json b208c6bcc00a — IDÉNTICOS a 05:00Z. Base estable.
- **Veredicto**: ante GO #4 del fundador, la vuelta = 5 parches mecánicos verificados + QA (ya blindada 0/0) + doc M87 + reporte/QA cruzada §21.8/Log (plantilla lista). Sin sorpresas posibles.

### ENSAYO GENERAL DE LA VUELTA GO EN SANDBOX + POLÍTICA DE STANDBY LIMPIO (2026-10-26 07:00Z, msg 296)
- Agnes 295 (Directora): acuse 294 ratificado (6 capas, anchors únicos sólidos, precondiciones confirmadas) + **INSTRUCCIÓN DE CORTE DE LOOP**: no más capas de blindaje ni acuses; GO 100% turnkey; "cualquier afinación menor la registro yo en estado, no escribís mensaje de acuse. Confirmás una única vez (este #295) y no más."
- **Ensayo general** (Temp/ensayo_general_go.py → Temp/ensayo_general_go.md; sandbox Temp/sandbox_go/): ejecuta los 7 pasos aprobados sobre COPIAS — el repo NO se toca. **23/23 PASS**:
  - Paso 1: sandbox/locales/pt.po == esqueleto byte a byte (sha1 95ee2ce0d1df, 21.156 B).
  - Pasos 2-4: 5 parches con anchors únicos: LM L15 LOCALES_SOPORTADOS+=pt; LM L359 K2 `or locale == "pt"` (+ comentario L357 es/en→es/en/pt); LU TABLAS+=pt K3; LU NOMBRES_NATIVOS+="pt":"Português" K4.
  - Diff controlado (difflib.SequenceMatcher): LM = 3 reemplazos exactos (L15, L357, L359), 0 inserciones/borrados; LU = 2 inserciones exactas (78→80 líneas), 0 reemplazos/borrados.
  - Paso 5: validar_par(es.po, pt.po) sobre el SANDBOX parcheado = **OK, 0 errores, P1=P2=P3=P5=0, exentas_p5=62, no_traducibles=61** — idéntico al ensayo directo del esqueleto (msg 292): el parcheo no rompe nada.
  - Integridad: hashes pre==post de localization_manager.gd (4340de8f), locale_utils.gd (848591cc), es.po (8e326b00); pt.po ausente en repo; LOCALES ["es","en"] intacto.
  - Corrección honesta: primer intento falló 1 check (mi checker de diff usaba zip simple que desalinea tras inserciones — bug del checker, NO del parche; corregido con difflib, re-ejecutado 23/23).
- **Blindaje final = 7 capas**: formato / parser producción / contenido / arquitectura K2-K3-K4 / árbitro-replica / preview-parches / **ensayo end-to-end sandbox**.
- **Política de standby limpio** (acato corte-loop 295 + override fundador 205): cron continúa con write real mínimo por vuelta (drift-check de base por sha1 + sondas + registro en este backlog); mensaje al canal SOLO ante (a) GO #4 del fundador → 7 pasos + firma + log, (b) drift material de base (es.po/en.po/strings_pt.json cambian → regenerar esqueleto), (c) encargo del director/agnes. Sin eso: vueltas silenciosas, cero acuses.
- **Base al cierre (07:00Z)**: es.po sha1 8e326b00e0f6 / en.po 14d379756a2b / strings_pt.json b208c6bcc00a — estables desde 2026-10-21/20. Esqueleto Temp 21.156 B sha1 95ee2ce0d1df.

### EJECUCIÓN GO #4 — PT-RUNTIME HABILITADO EN PRODUCCIÓN (2026-10-27, Log 2217, msg 298)

GO #4 dado por el fundador en chat 2026-10-27 (06:40Z "si lo hacemos"; 06:48Z "hacelo"; 08:19Z "bueno hacelo") + orden de reportar al director. Capacidad: nicho propio i18n, blindaje 7 capas, ensayo sandbox 23/23 — sin delegación (respuesta al fundador: SÍ es mi nicho).

- **Paso 1:** `locales/pt.po` creado byte a byte desde Temp/pt_po_esqueleto.po (21.156B, sha1 95ee2ce0d1df, 274 entradas, 4 plurales msgstr[0]+[1], 61 no-traducir, header PT nplurals=2 plural=(n>1), sin BOM/CR).
- **Pasos 2-4 (5 parches, anchors count==1 frescos):** LM L15 LOCALES_SOPORTADOS+=pt; LM L357 comentario es/en→es/en/pt; LM L359 K2 _indice_plural += "pt"; LU L15 TABLAS pt (K3); LU L21 NOMBRES "Português" (K4).
- **Paso 5 QA:** validar_par(es.po, pt.po REALES) réplica ValidadorPO = OK 0 errores 0 avisos (P1=P2=P3=P5=0, exentas 62, no_traducibles 61); ejecutor 40/40 PASS (precondiciones duras con aborto limpio; parches en memoria verificados antes de escribir; diff difflib exacto LM 3 reemplazos / LU 2 inserciones; tabs/BOM/CR; git riel = 3 archivos).
- **Paso 6 doc M87:** 04-Codigo 8b actualizada + 8c nueva; 03-Diseno L489; 05-Checklist L68 evidencia; 02-Analisis L166. GLOBAL fila 87 Notas + última actividad. Sin flips (5 [?] M87 siguen con dueño externo — anti-inflación §21.8.2.b).
- **Paso 7:** Log 2217 (pool Logs consumido) + msg 298 al director (pool canal consumido vía helper --consume) con reporte completo + QA cruzada §21.8 solicitada (4 checks en editor) + firmas.
- **Backups §5:** Obsoletos/2026-10-27_05-23-25_localization_manager.gd + _locale_utils.gd (rollback disponible).
- **Pendiente honesto:** captura UI PT (tarea 59) — requiere Godot con visión (M154); QA cruzada §21.8 Hy3/agnes verifica runtime en editor (boot 3 idiomas 0 errores; selector "Português"; obtener_estado_catalogos pt ok=true; plurales n=2 → "Oferecendo {n} itens").
- **Deuda cruzada saldada:** M68 L214 "testear panel y carteles en 3 idiomas" dueño M87 (Reflection-Beam T196-68 puede cerrar con captura en editor).
- **Ejecutor + informe:** Temp/ejecutor_go_pt_runtime.py + Temp/ejecucion_go_pt_runtime.md. Contingencia: esqueleto reproducible desde repo + tabla 98 (anexo lote 115 de este backlog).

### ANEXO TANDA M87 — CONCILIACIÓN POST-PT (2026-10-27 22:30 local; encargo agnes 302, informe 305, Log 2221)

Criterio canónico de consumidor: .gd no-test/debug + .tscn + data/dialogues, EXCLUYENDO Obsoletos/ y docstrings; consumo dinámico con evidencia archivo:linea. Parser .po canónico tolerante (v1 crudo reintrodujo bug msg 282: fusiona tramos compactos → 261/274; v2 corregido). Base intacta: pt.po 95ee2ce0d1df = HEAD 071a2f9.

**T1 — Paridad total:** JSON×3 170/170/170 (dif 0); .po×3 274/274/274 = 270 simples + 4 plurales (dif 0); cruce IDÉNTICO 3 idiomas: 159 comunes / 11 solo-JSON mortuas / 115 solo-.po; paridad cruzada 0/0. sha1: JSON es 795959d061b6 / en 0af9296b22aa / pt b208c6bcc00a; .po es 8e326b00e0f6 / en 14d379756a2b / pt 95ee2ce0d1df.
- 11 mortuas: msg.inventario_lleno, msg.no_materiales, msg.nuevo_dia, npc.adios, npc.hola, ui.diario, ui.guardar, ui.mapa, ui.opciones, ui.tienda, ui.inventario.

**T2 — 34 orphan JSON (cuadro exacto con encargo):** ui6 (diario/guardar/mapa/opciones/tienda/inventario — único hit en Obsoletos/test_m87_bug104, excluido), eventos14 (historia_c1-c7 — consumidor solo tests: test_capitulos_m74.gd:87 concatenación + test_catalogo_exhaustivo_m87.gd; runtime M149 no las consume), SETTINGS9 (HORAS_1/HORAS_H/MIN_1/MIN_M/SAVE_CORRUPTO/SAVE_DISCO_LLENO/SAVE_RECUPERADO/SIN_GUARDADO_PREVIO/ULTIMO_GUARDADO — save legacy M59), msg3 (inventario_lleno/no_materiales/nuevo_dia), npc2 (hola/adios — diálogos M21 usan speaker_key npc.<id> para retratos: dialogue_ui.gd:377, npc_portrait_ui.gd:58).

**T3 — 115 .po-solo, desglose canónico:**
- A. M68 literales-runtime ×49: EVENT×10, NARR×9, SPECIAL×14, TRIP×15 (constantes TEXTOS/ESPECIALES/PLURALES transport_localizer.gd:36-89, consumidas por texto() L216) + UI.INTERACTUAR (interact_prompt.gd:94).
- B. M68 vía datos ×10: STOP.<id> (transport_network.tres nombre_clave fijo + transport_localizer.gd:309 fallback "M68.STOP."+id).
- C. M68 templates dinámicos ×30: ROUTE×20 + SIGN.<id>×10 (claves_de_parada/claves_de_ruta transport_localizer.gd:332-342; texto_generado begins_with L399-410; convención L11-18; generar_red_transporte.gd:102 STOP).
- D. Dinámicas no-M68 ×18: DIARY.CAT_*×14 (diary_layer.gd:412 _t("DIARY.CAT_"+cat.to_upper()); documentado en validate_diary.gd:278 y auditor_claves.gd:9) + CLOCK.ESTACIONES×4 (w_reloj.gd:198 tr_key("clock","estaciones",str(clampi(est,0,3))) con fallback hardcode L201).
- E. SIGN.GENERICO ×1 (transport_localizer.gd:297 texto_cartel).
- F. Test-only ×2: HUD.VIDA, SETTINGS.IDIOMA (solo test_localizacion_iter6/test_validador_po_m87).
- G. Drift convención ítems ×2: ITEMS.MADERA, ITEMS.MADERA_DESC (inventario_iter4.gd:283 construye "items."+id+".name" — convención inexistente; ItemData nombre/descripcion literales; deuda M159/M53).
- H. Deuda UI M53 ×1: MAIN_MENU.OPTIONS (sin consumidor literal; presuntamente metadato text_key retraductor_ui.gd:17-18 o selector no integrado).
- I. Muerta real ×1: DIALOGOS.VECINO_SALUDO (0 hits repo-wide).
- J. Exenta ×1: npc.catalina (nombre propio; EXCEPCIONES_CLAVE validador_po.gd; único hit docstring validador).
- Cuadre: 49+10+30+18+1+2+2+1+1+1 = 115 ✓ (A+B+C+E = 90 M68 vivas). Paridad cruzada 0/0.
- Cuadre con agnes 53/62: ella grep-literal + tests como consumidores + catalina muerta → 53 = 51−catalina+3tests; diferencia material = 44 dinámicas (C+D) invisibles al grep literal.

**Hallazgos colaterales (report-only):** H1 generar_islas.gd:115 fija "M27.ISLA.%s.NOMBRE" (13 .tres data/islas) SIN claves en catálogo → islas no traducibles (drift M27/M167). H2 ítems M159 sin integración i18n. H3 MAIN_MENU.PLAY/ITEMS.SE_OFRECEN/HUD.ENERGIA/SETTINGS.IDIOMA_DESC (JSON-comunes): único hit en docstrings (localization_manager.gd:157, retraductor_ui.gd:17-18) — consumo presuntamente metadato text_key o UI no integrada M53; verificar gate-2 runtime. H4 lección parser (msg 282 reintroducido en v1, corregido v2).

**T4** 05-Checklist M87: +4 ítems [x] nuevos (Totales 140; conteo declaro 135 completados + 5 deuda-externa — marcas disco 140 [x], 5 híbridos FLIP T219-87 de Beam 2026-10-26 con deuda en texto L71/74/112/116/117, drift de conteo reportado); GLOBAL fila 87 → 135/140; msg 305 a agnes; Log 2221. Numeración: colisión 304 (gemelo de agnes en disco sin consumir del pool, race con mi consumo del helper) → informe = 305 (consumido); 304 del pool = hueco sanado anotado. Scripts Temp/kilo: tanda_m87_conciliacion.py (v1 buggy), tanda_m87_v2.py, tanda_m87_v3.py, probe_dinamicas.py, probe_focal.py, probe_tres.py, informe tanda_m87_informe.md.


