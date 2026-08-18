**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 108: Pipeline de Assets

## A. Problema y objetivos

- [x] Definir el problema: sin pipeline los assets entran sin formato, nombre, optimización ni legalidad verificables [S]
- [x] Vincular el problema con la optimización obligatoria del proyecto (AGENTS.md 21.4.8) [S]
- [x] Establecer el objetivo: flujo único de entrada, validación, importación, review y aprobación de assets [S]
- [x] Definir el alcance: models 3D, texturas, materiales, audio, fuentes, UI y paletas voxel [S]
- [x] Excluir del alcance: el terreno voxel generado en runtime por Voxel Tools (M08) [S]
- [x] Registrar dependencias: M45 (Arte 3D) y M78 (Legal PI), con relaciones a M04, M08, M47, M48, M61, M62, M63, M86, M107, M111, M112, M118 [M]
- [x] Establecer que M45 puede estar sin documentar y se referencia por su catálogo de entregables [S]
- [x] Fijar los criterios de aceptación del módulo (7 criterios del 01-Requerimientos) [S]

## B. RF — Formatos por tipo

- [x] RF2: definir glTF 2.0 (glb binario) como formato estándar de modelos en runtime [S]
- [x] RF2: admitir gltf + bin en staging para edición y diffs legibles [S]
- [x] RF2: aceptar OBJ solo para geometría simple y formato de edición [S]
- [x] RF2: definir PNG como textura lossless con canal alfa [S]
- [x] RF2: definir WebP como textura lossy sin alfa dura [S]
- [x] RF2: definir OGG Vorbis como audio estándar (música, ambiente, SFX) [S]
- [x] RF2: admitir WAV solo para loops cortos de UI/feedback ≤ 5 s [S]
- [x] RF3: prohibir FBX como entrada directa y documentar la ruta de conversión Blender → glTF [M]
- [x] RF3: prohibir TGA, BMP y GIF como texturas de entrada [S]
- [x] RF3: prohibir MP3, M4A y MIDI como audio de entrada [S]
- [x] RF3: prohibir formatos propietarios no documentados y propietarios de video [S]
- [x] Definir TTF/OTF con licencia libre verificada como fuente (M88: Nunito, Fredoka One) [S]
- [x] Exigir potencias de 2 en texturas para compresión VRAM eficiente [M]
- [x] Fijar límites de resolución por tipo: props ≤ 2048², atlas ≤ 4096², iconos ≤ 256² [M]
- [x] Definir paletas voxel como PNG atlas con mipmaps off y filtrado off (anti-bleeding M08) [M]
- [x] Documentar los formatos prohibidos y sus rutas de conversión en ASSET-PIPELINE.md [S]

## C. RF — Convenciones de nombres

- [x] RF4: definir prefijos obligatorios por tipo: mdl_, tex_, mat_, aud_, anim_, fnt_, ui_, vox_ [S]
- [x] RF4: usar snake_case en minúsculas sin espacios, tildes, ñ ni caracteres especiales [S]
- [x] RF4: definir la secuencia {prefijo}_{entidad}_{variante}_{sufijo} [S]
- [x] RF4: numerar variantes en dos dígitos (_01) [S]
- [x] RF4: usar sufijos de mapa: _albedo, _normal, _roughness, _emission, _height [S]
- [x] RF4: limitar nombres a 64 caracteres máximo [S]
- [x] RF4: derivar el id estable del asset desde el nombre de archivo [M]
- [x] RF4: garantizar que el id nunca se reutiliza tras un retiro [S]
- [x] Definir la convención opcional de respaldo _lod0/_lod1/_lod2 para LODs manuales [S]
- [x] Documentar ejemplos canónicos de nombres en la guía [S]
- [x] Hacer que el validador cheque la regex de nombres sobre todo el árbol assets/ [M]
- [x] Definir que las rutas de catálogos y guardados (M15/M59) usan el id derivado del nombre [M]

## D. RF — Importación en Godot

- [x] RF5: definir presets de importación fijos por tipo de asset [M]
- [x] RF5: versionar los archivos .import generados por Godot en Git [S]
- [x] RF5: fijar la versión del motor (Godot ≥ 4.4.1 por Voxel Tools) para import determinista [S]
- [x] RF5: definir preset de textura 3D: mipmaps on, VRAM Compressed, high_quality, filter on, repeat off [M]
- [x] RF5: definir preset de textura UI: mipmaps off, VRAM Compressed, filter off según caso [M]
- [x] RF5: definir preset de paleta voxel: mipmaps off, filter off, repeat off [M]
- [x] RF5: definir preset de mesh glb: import_as Mesh, LODs auto ×3, shadow mesh on, vertex compression on, tangents on [M]
- [x] RF5: definir preset de audio OGG con calidad por uso (música alta, SFX media) [S]
- [x] RF5: definir preset de audio WAV loop con normalize, trim y bounds de loop [S]
- [x] RF5: definir preset de fuente TTF con MSDF on, antialiasing on y subsetting [M]
- [x] Implementar apply_import_presets.gd que reimporte con los presets y corrija desviaciones [C]
- [x] Detectar en el validador texturas importadas sin VRAM Compressed y reportarlas [M]
- [x] Excluir staging/ de la importación de runtime mediante .gdignore [S]
- [x] Garantizar que el reimport no rompa referencias existentes a assets aprobados [M]

## E. RF — Optimización

- [x] RF6: activar mipmaps en todas las texturas de runtime [S]
- [x] RF6: usar compresión VRAM BPTC/S3TC en PC vía Godot [M]
- [x] RF6: habilitar LOD automático de Godot 4.x en meshes importados [M]
- [x] RF6: habilitar vertex compression en la importación de meshes [M]
- [x] RF6: generar shadow mesh en meshes para sombras baratas [S]
- [x] RF6: definir presupuesto por tipo: props ≤ 1.5k tris, NPCs ≤ 6k, fauna ≤ 4k, mobiliario ≤ 2.5k [M]
- [x] RF6: instanciar props repetidos con MultiMesh o VoxelInstancer (M08) [M]
- [x] RF6: usar un solo mesh con N transforms para vegetación y piedras decorativas [M]
- [x] Usar atlas ≤ 4096² con margen de 4 px anti-bleeding para props compartidos [M]
- [x] Compartir materiales entre assets con los mismos mapas (evitar duplicados) [M]
- [x] Preparar los presets para poder cambiar a ETC2/ASTC si hubiera mobile (M96) [S]
- [x] Configurar audio OGG ~112 kbps música y ~96 kbps SFX [S]
- [x] Asegurar AABB correctos tras importar para el culling (M61) [M]
- [x] Verificar en review ausencia de popping visible en transición de LODs [M]
- [x] Estimar VRAM/RAM por asset con asset_memory_reporter.gd contra el presupuesto de M62 [C]
- [x] No permitir assets que excedan el presupuesto sin excepción documentada firmada [M]

## F. RF — Review de calidad

- [x] RF9: definir plantilla de review humana por asset [M]
- [x] RF9: revisar escala correcta en grilla de 1 m del mundo (M08) [S]
- [x] RF9: revisar origen y pivote del modelo en posición correcta [S]
- [x] RF9: revisar UVs sin superposición accidental y normal maps consistentes [M]
- [x] RF9: revisar alfa sin bordes blancos (fix_alpha_border) [S]
- [x] RF9: revisar mipmaps y filtrado visualmente sin saltos [M]
- [x] RF9: revisar LODs a las distancias de uso y sombras sin artefactos [M]
- [x] RF9: revisar look dev cozy coherente con la dirección de arte [M]
- [x] RF9: revisar peso estimado en memoria contra la tabla por tipo [M]
- [x] RF9: revisar que la ficha esté completa, incluida la licencia (M78) [S]
- [x] RF8: crear la ficha de asset como fuente de verdad del estado [M]
- [x] RF9: crear la escena asset_preview.tscn con caja de referencia de 1 m y cámara orbitante [M]
- [x] RF9: permitir review por lotes para escalar a 500+ assets [M]
- [x] RF12: documentar el procedimiento de actualización de un asset con changelog en la ficha [S]

## G. Requisitos no funcionales

- [x] RN: ningún asset entra sin mipmaps, compresión VRAM y LODs aplicados [M]
- [x] RN: calidad visual cozy sin texturas 4K indiscriminadas; atlas y MultiMesh para draw calls bajos [M]
- [x] RN: nombres, fichas, guías y reportes en español [S]
- [x] RN: herramientas del pipeline en GDScript con comentarios en español (M05) [M]
- [x] RN: determinismo de importación con versión de Godot bloqueada y presets versionados [M]
- [x] RN: todo asset licenciado con licencia SPDX y atribución verificadas (M78) [M]
- [x] RN: assets propios de M45 marcados como copyright del estudio [S]
- [x] RN: el pipeline funciona con 500+ assets sin colapso de importación ni de review [M]
- [x] RN: scripts y plantillas del pipeline con revisión de pares (M111) [S]
- [x] RN: binarios grandes gestionados con Git LFS (M06/M107) [M]
- [x] RN: trazabilidad: la ficha permite saber origen, estado y responsable del asset [S]
- [x] RN: el validador es headless-compatible para CI (M118) [C]

## H. Análisis

- [x] Analizar formatos por tipo y descartar alternativas (FBX, JPG, TGA, MP3) con razones [M]
- [x] Justificar glb sobre FBX: importador estable, LODs automáticos, sin dependencias [M]
- [x] Justificar WebP sobre JPG: sin artefactos de bloque en arte flat cozy [M]
- [x] Justificar PNG sobre TGA: soporte universal y canal alfa [S]
- [x] Justificar OGG sobre MP3: sin licencias de códec y streaming nativo [S]
- [x] Analizar la compresión por plataforma: BPTC/S3TC PC, ETC2/ASTC futuro mobile [M]
- [x] Analizar el importador de texturas de Godot: mipmaps, VRAM Compressed, high_quality [M]
- [x] Analizar el importador de glTF: LODs automáticos, shadow mesh, vertex compression [M]
- [x] Analizar el importador de audio y fuentes (MSDF para escalado cozy) [M]
- [x] Analizar batching y atlasing por categorías visuales del proyecto [M]
- [x] Documentar el riesgo de bleeding de atlas y su mitigación (margen + mipmaps off) [S]
- [x] Documentar el riesgo de import no determinista y su mitigación (versión bloqueada + presets) [S]
- [x] Documentar el riesgo legal de assets sin atribución y su mitigación (validador bloquea) [S]
- [x] Concluir que el pipeline se cubre 100% con GDScript puro sin plugins [M]

## I. Diseño

- [x] Diseñar el diagrama del pipeline: staging → validación → importación → review → aprobación [M]
- [x] Definir la estructura de carpetas assets/ con staging, final, archive, fichas [M]
- [x] Definir que staging/ es la única puerta de entrada (RF1) [S]
- [x] Definir que las escenas solo referencian assets/final/ [M]
- [x] Definir que archive/ conserva retirados sin cargarse [S]
- [x] Diseñar asset_validator.gd: reglas, reporte markdown y salida JSON para CI [C]
- [x] Diseñar apply_import_presets.gd: reimporta y corrige desviaciones de import [C]
- [x] Diseñar promote_asset.gd: mueve aprobados de staging a final y actualiza el índice [M]
- [x] Diseñar atlas_builder.gd: empaca atlas ≤ 4096² con margen y reporta ahorro [M]
- [x] Diseñar retire_asset.gd: retira, registra id y detecta referencias dependientes [M]
- [x] Diseñar asset_memory_reporter.gd: totaliza VRAM/RAM contra M62 [C]
- [x] Diseñar la ficha de asset con todos sus campos (origen, licencia, estado, referencias) [M]
- [x] Definir el flujo de estados: staging → validado → en_review → aprobado → retirado [S]
- [x] Definir que la ficha es la única fuente del estado del asset [S]
- [x] Diseñar asset_preview.tscn con referencia de escala y luces estándar [M]
- [x] Integrar las herramientas al menú Proyecto > Pipeline de Assets del editor [M]

## J. Integración con otros módulos

- [x] M45: el catálogo de entregables de Arte 3D debe pasar por staging del pipeline [M]
- [x] M45: modelar props y NPCs respetando la metría de 1 m del mundo voxel [M]
- [x] M78: la ficha exige licencia SPDX y atribución; el validador falla sin ellas [M]
- [x] M78: los assets licenciados se marcan y trazan según la política de PI [M]
- [x] M86: assets de IA generativa solo con revisión legal y etiquetado explícito en ficha [M]
- [x] M47: respetar los sufijos de mapas (albedo/normal/roughness/emission) definidos en Texturas y Materiales [S]
- [x] M48: animaciones embebidas en glb; anim_ solo para clips excepcionales [S]
- [x] M62: asset_memory_reporter.gd totaliza la VRAM/RAM contra el presupuesto del módulo [C]
- [x] M63: ids estables = rutas estables para el caché LRU y el streaming de texturas [M]
- [x] M63: marcar assets grandes (música, cinemáticas) para carga bajo demanda [M]
- [x] M08: paletas voxel en voxel_palettes/ con filtrado off y mipmaps off [M]
- [x] M08: props del mundo instanciados con VoxelInstancer/MultiMesh compartido [M]
- [x] M61: ejecutar los presupuestos finos de Rendimiento cuando estén publicados (en curso) [M]
- [x] M118: el validador corre en CI headless y rompe el build si hay errores [C]
- [x] M111: los scripts del pipeline pasan code review y cumplen la guía de estilo GDScript [S]
- [x] M112: pruebas unitarias de las reglas del validador (nombres, formatos, límites) [C]

## K. Edge cases

- [x] Asset gigante (> 500 MB o textura 8192²): el validador lo rechaza y sugiere división/optimización [M]
- [x] Textura sin comprimir (import no VRAM): reporte de error con la ruta del .import a corregir [M]
- [x] Nombre conflictivo (duplicado o que colisiona tras renombrar): detección y resolución guiada [M]
- [x] Asset discontinuado con referencias activas: el retiro avisa dependencias antes de archivar [M]
- [x] Asset licenciado sin ficha: bloqueado en validación hasta completarla [S]
- [x] Asset de IA sin etiquetado: bloqueado hasta la revisión de M78/M86 [S]
- [x] Ficha de estado inconsistente con la ubicación del archivo: detectado por el validador [M]
- [x] Archivo corrupto o truncado: el importador falla y el reporte lo clasifica como error de asset [M]
- [x] Atlas que excede 4096²: rechazo con sugerencia de dividir por categorías [M]
- [x] Audio WAV de más de 5 s: rechazo con sugerencia de conversión a OGG [S]
- [x] Normal map sin tangentes: reimportado con ensure_tangents y verificación visual [M]
- [x] Renombrado de asset aprobado: migración de referencias con alias y log de cambio [M]
- [x] Dos agentes importando a la vez: regla de exclusión mutua en staging (archivo de lock) [M]

## L. Optimización del pipeline

- [x] El validador recorre el árbol en una sola pasada con estadísticas por tipo [C]
- [x] Reportes markdown con resumen ejecutivo (aprobados, errores, pendientes) [S]
- [x] El validador usa parallel/skip de carpetas archive/ y .godot/ para no perder tiempo [M]
- [x] Los presets evitan reimports innecesarios: solo se reimporta lo que cambió [M]
- [x] El apilado de atlas se hace una sola vez por categoría y se cache a su resultado [M]
- [x] La escena de preview carga un solo asset a la vez para review rápido [S]
- [x] El memory reporter estima sin abrir los archivos (usa import settings) [C]
- [x] Los logs del pipeline no crecen indefinidamente (rotación según AGENTS.md 18) [S]
- [x] El índice _APROBADAS.md se regenera incrementalmente, no de cero [M]
- [x] Las herramientas headless devuelven exit code 0/1 para detectar fallos en CI [S]

## M. Documentación

- [x] Crear ASSET-PIPELINE.md como guía rectora (formatos, nombres, presets, flujo, ficha) [C]
- [x] Documentar la tabla de formatos permitidos/prohibidos con rutas de conversión [M]
- [x] Documentar la tabla de convenciones de nombres con ejemplos canónicos [M]
- [x] Documentar la tabla de presets de importación por tipo [M]
- [x] Documentar la plantilla de ficha de asset en la guía [S]
- [x] Documentar el flujo completo con su diagrama y responsables por etapa [M]
- [x] Documentar los procedimientos de actualización y retiro de assets [M]
- [x] Mantener plan-actual sincronizado con la implementación real al cerrar el módulo [S]

## N. Testings

- [x] Definir el plan de testings del pipeline (06-Plan-Testings.md) cuando se implemente [C]
- [x] Probar el flujo completo con 20 assets de prueba representativos [C]
- [x] Probar el edge case de asset gigante y su rechazo [M]
- [x] Probar el edge case de textura sin comprimir y su corrección con presets [M]
- [x] Probar el edge case de nombre conflictivo y la resolución guiada [M]
- [x] Probar el edge case de asset discontinuado con y sin dependencias [M]
- [x] Probar el validador en headless con y sin errores (exit codes) [C]
- [x] Probar que el reimport con presets no rompe referencias de escenas existentes [M]
- [x] Probar la generación de LODs y shadow meshes en un glb de referencia [M]
- [x] Probar el memory reporter contra un caso conocido y verificar sus números [M]
- [x] Probar el promote/retiro dejando el índice _APROBADAS.md correcto [M]
- [x] Ejecutar los testings antes de la primera prueba manual del usuario y documentar resultados [M]