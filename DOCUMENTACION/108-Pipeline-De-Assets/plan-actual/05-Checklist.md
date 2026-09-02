**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 108: Pipeline de Assets

## Bloque `Reserva actual`

| Campo | Valor |
|---|---|
| Módulo | M108 — Pipeline de Assets |
| Fase | 8 (Arte y calidad final) |
| Dificultad | 3 |
| Visión | V1 |
| Agente | deepseek-v4-flash-vision-exp (Kilo Code) |
| Fecha reserva | 2026-09-01 12:40 |
| Estado | 🔵 En curso — iter 1 núcleo |
| Entrada | Doc completa (tanda 6) + 153 GLB reales en assets/3d/{media,baja} (M166/M18) |
| Salida | Validador `asset_validator.gd` + guía ASSET-PIPELINE.md + plantilla de ficha + 20 fichas + reporte de auditoría |
| Archivos | `game/isla-ancestral/tools/asset_validator.gd` (nuevo) + `DOCUMENTACION/108-Pipeline-De-Assets/plan-actual/*` + `game/isla-ancestral/assets/fichas/*.md` |

## A. Problema y objetivos

- [ ] Definir el problema: sin pipeline los assets entran sin formato, nombre, optimización ni legalidad verificables [S]
- [ ] Vincular el problema con la optimización obligatoria del proyecto (AGENTS.md 21.4.8) [S]
- [ ] Establecer el objetivo: flujo único de entrada, validación, importación, review y aprobación de assets [S]
- [ ] Definir el alcance: models 3D, texturas, materiales, audio, fuentes, UI y paletas voxel [S]
- [ ] Excluir del alcance: el terreno voxel generado en runtime por Voxel Tools (M08) [S]
- [ ] Registrar dependencias: M45 (Arte 3D) y M78 (Legal PI), con relaciones a M04, M08, M47, M48, M61, M62, M63, M86, M107, M111, M112, M118 [M]
- [ ] Establecer que M45 puede estar sin documentar y se referencia por su catálogo de entregables [S]
- [ ] Fijar los criterios de aceptación del módulo (7 criterios del 01-Requerimientos) [S]

## B. RF — Formatos por tipo

- [ ] RF2: definir glTF 2.0 (glb binario) como formato estándar de modelos en runtime [S]
- [ ] RF2: admitir gltf + bin en staging para edición y diffs legibles [S]
- [ ] RF2: aceptar OBJ solo para geometría simple y formato de edición [S]
- [ ] RF2: definir PNG como textura lossless con canal alfa [S]
- [ ] RF2: definir WebP como textura lossy sin alfa dura [S]
- [ ] RF2: definir OGG Vorbis como audio estándar (música, ambiente, SFX) [S]
- [ ] RF2: admitir WAV solo para loops cortos de UI/feedback ≤ 5 s [S]
- [ ] RF3: prohibir FBX como entrada directa y documentar la ruta de conversión Blender → glTF [M]
- [ ] RF3: prohibir TGA, BMP y GIF como texturas de entrada [S]
- [ ] RF3: prohibir MP3, M4A y MIDI como audio de entrada [S]
- [ ] RF3: prohibir formatos propietarios no documentados y propietarios de video [S]
- [ ] Definir TTF/OTF con licencia libre verificada como fuente (M88: Nunito, Fredoka One) [S]
- [ ] Exigir potencias de 2 en texturas para compresión VRAM eficiente [M]
- [ ] Fijar límites de resolución por tipo: props ≤ 2048², atlas ≤ 4096², iconos ≤ 256² [M]
- [ ] Definir paletas voxel como PNG atlas con mipmaps off y filtrado off (anti-bleeding M08) [M]
- [ ] Documentar los formatos prohibidos y sus rutas de conversión en ASSET-PIPELINE.md [S]

## C. RF — Convenciones de nombres

- [ ] RF4: definir prefijos obligatorios por tipo: mdl_, tex_, mat_, aud_, anim_, fnt_, ui_, vox_ [S]
- [ ] RF4: usar snake_case en minúsculas sin espacios, tildes, ñ ni caracteres especiales [S]
- [ ] RF4: definir la secuencia {prefijo}_{entidad}_{variante}_{sufijo} [S]
- [ ] RF4: numerar variantes en dos dígitos (_01) [S]
- [ ] RF4: usar sufijos de mapa: _albedo, _normal, _roughness, _emission, _height [S]
- [ ] RF4: limitar nombres a 64 caracteres máximo [S]
- [ ] RF4: derivar el id estable del asset desde el nombre de archivo [M]
- [ ] RF4: garantizar que el id nunca se reutiliza tras un retiro [S]
- [ ] Definir la convención opcional de respaldo _lod0/_lod1/_lod2 para LODs manuales [S]
- [ ] Documentar ejemplos canónicos de nombres en la guía [S]
- [ ] Hacer que el validador cheque la regex de nombres sobre todo el árbol assets/ [M]
- [ ] Definir que las rutas de catálogos y guardados (M15/M59) usan el id derivado del nombre [M]

## D. RF — Importación en Godot

- [ ] RF5: definir presets de importación fijos por tipo de asset [M]
- [ ] RF5: versionar los archivos .import generados por Godot en Git [S]
- [ ] RF5: fijar la versión del motor (Godot ≥ 4.4.1 por Voxel Tools) para import determinista [S]
- [ ] RF5: definir preset de textura 3D: mipmaps on, VRAM Compressed, high_quality, filter on, repeat off [M]
- [ ] RF5: definir preset de textura UI: mipmaps off, VRAM Compressed, filter off según caso [M]
- [ ] RF5: definir preset de paleta voxel: mipmaps off, filter off, repeat off [M]
- [ ] RF5: definir preset de mesh glb: import_as Mesh, LODs auto ×3, shadow mesh on, vertex compression on, tangents on [M]
- [ ] RF5: definir preset de audio OGG con calidad por uso (música alta, SFX media) [S]
- [ ] RF5: definir preset de audio WAV loop con normalize, trim y bounds de loop [S]
- [ ] RF5: definir preset de fuente TTF con MSDF on, antialiasing on y subsetting [M]
- [ ] Implementar apply_import_presets.gd que reimporte con los presets y corrija desviaciones [C]
- [ ] Detectar en el validador texturas importadas sin VRAM Compressed y reportarlas [M]
- [ ] Excluir staging/ de la importación de runtime mediante .gdignore [S]
- [ ] Garantizar que el reimport no rompa referencias existentes a assets aprobados [M]

## E. RF — Optimización

- [ ] RF6: activar mipmaps en todas las texturas de runtime [S]
- [ ] RF6: usar compresión VRAM BPTC/S3TC en PC vía Godot [M]
- [ ] RF6: habilitar LOD automático de Godot 4.x en meshes importados [M]
- [ ] RF6: habilitar vertex compression en la importación de meshes [M]
- [ ] RF6: generar shadow mesh en meshes para sombras baratas [S]
- [ ] RF6: definir presupuesto por tipo: props ≤ 1.5k tris, NPCs ≤ 6k, fauna ≤ 4k, mobiliario ≤ 2.5k [M]
- [ ] RF6: instanciar props repetidos con MultiMesh o VoxelInstancer (M08) [M]
- [ ] RF6: usar un solo mesh con N transforms para vegetación y piedras decorativas [M]
- [ ] Usar atlas ≤ 4096² con margen de 4 px anti-bleeding para props compartidos [M]
- [ ] Compartir materiales entre assets con los mismos mapas (evitar duplicados) [M]
- [ ] Preparar los presets para poder cambiar a ETC2/ASTC si hubiera mobile (M96) [S]
- [ ] Configurar audio OGG ~112 kbps música y ~96 kbps SFX [S]
- [ ] Asegurar AABB correctos tras importar para el culling (M61) [M]
- [ ] Verificar en review ausencia de popping visible en transición de LODs [M]
- [ ] Estimar VRAM/RAM por asset con asset_memory_reporter.gd contra el presupuesto de M62 [C]
- [ ] No permitir assets que excedan el presupuesto sin excepción documentada firmada [M]

## F. RF — Review de calidad

- [ ] RF9: definir plantilla de review humana por asset [M]
- [ ] RF9: revisar escala correcta en grilla de 1 m del mundo (M08) [S]
- [ ] RF9: revisar origen y pivote del modelo en posición correcta [S]
- [ ] RF9: revisar UVs sin superposición accidental y normal maps consistentes [M]
- [ ] RF9: revisar alfa sin bordes blancos (fix_alpha_border) [S]
- [ ] RF9: revisar mipmaps y filtrado visualmente sin saltos [M]
- [ ] RF9: revisar LODs a las distancias de uso y sombras sin artefactos [M]
- [ ] RF9: revisar look dev cozy coherente con la dirección de arte [M]
- [ ] RF9: revisar peso estimado en memoria contra la tabla por tipo [M]
- [ ] RF9: revisar que la ficha esté completa, incluida la licencia (M78) [S]
- [ ] RF8: crear la ficha de asset como fuente de verdad del estado [M]
- [ ] RF9: crear la escena asset_preview.tscn con caja de referencia de 1 m y cámara orbitante [M]
- [ ] RF9: permitir review por lotes para escalar a 500+ assets [M]
- [ ] RF12: documentar el procedimiento de actualización de un asset con changelog en la ficha [S]

## G. Requisitos no funcionales

- [ ] RN: ningún asset entra sin mipmaps, compresión VRAM y LODs aplicados [M]
- [ ] RN: calidad visual cozy sin texturas 4K indiscriminadas; atlas y MultiMesh para draw calls bajos [M]
- [ ] RN: nombres, fichas, guías y reportes en español [S]
- [ ] RN: herramientas del pipeline en GDScript con comentarios en español (M05) [M]
- [ ] RN: determinismo de importación con versión de Godot bloqueada y presets versionados [M]
- [ ] RN: todo asset licenciado con licencia SPDX y atribución verificadas (M78) [M]
- [ ] RN: assets propios de M45 marcados como copyright del estudio [S]
- [ ] RN: el pipeline funciona con 500+ assets sin colapso de importación ni de review [M]
- [ ] RN: scripts y plantillas del pipeline con revisión de pares (M111) [S]
- [ ] RN: binarios grandes gestionados con Git LFS (M06/M107) [M]
- [ ] RN: trazabilidad: la ficha permite saber origen, estado y responsable del asset [S]
- [ ] RN: el validador es headless-compatible para CI (M118) [C]

## H. Análisis

- [ ] Analizar formatos por tipo y descartar alternativas (FBX, JPG, TGA, MP3) con razones [M]
- [ ] Justificar glb sobre FBX: importador estable, LODs automáticos, sin dependencias [M]
- [ ] Justificar WebP sobre JPG: sin artefactos de bloque en arte flat cozy [M]
- [ ] Justificar PNG sobre TGA: soporte universal y canal alfa [S]
- [ ] Justificar OGG sobre MP3: sin licencias de códec y streaming nativo [S]
- [ ] Analizar la compresión por plataforma: BPTC/S3TC PC, ETC2/ASTC futuro mobile [M]
- [ ] Analizar el importador de texturas de Godot: mipmaps, VRAM Compressed, high_quality [M]
- [ ] Analizar el importador de glTF: LODs automáticos, shadow mesh, vertex compression [M]
- [ ] Analizar el importador de audio y fuentes (MSDF para escalado cozy) [M]
- [ ] Analizar batching y atlasing por categorías visuales del proyecto [M]
- [ ] Documentar el riesgo de bleeding de atlas y su mitigación (margen + mipmaps off) [S]
- [ ] Documentar el riesgo de import no determinista y su mitigación (versión bloqueada + presets) [S]
- [ ] Documentar el riesgo legal de assets sin atribución y su mitigación (validador bloquea) [S]
- [ ] Concluir que el pipeline se cubre 100% con GDScript puro sin plugins [M]

## I. Diseño

- [ ] Diseñar el diagrama del pipeline: staging → validación → importación → review → aprobación [M]
- [ ] Definir la estructura de carpetas assets/ con staging, final, archive, fichas [M]
- [ ] Definir que staging/ es la única puerta de entrada (RF1) [S]
- [ ] Definir que las escenas solo referencian assets/final/ [M]
- [ ] Definir que archive/ conserva retirados sin cargarse [S]
- [ ] Diseñar asset_validator.gd: reglas, reporte markdown y salida JSON para CI [C]
- [ ] Diseñar apply_import_presets.gd: reimporta y corrige desviaciones de import [C]
- [ ] Diseñar promote_asset.gd: mueve aprobados de staging a final y actualiza el índice [M]
- [ ] Diseñar atlas_builder.gd: empaca atlas ≤ 4096² con margen y reporta ahorro [M]
- [ ] Diseñar retire_asset.gd: retira, registra id y detecta referencias dependientes [M]
- [ ] Diseñar asset_memory_reporter.gd: totaliza VRAM/RAM contra M62 [C]
- [ ] Diseñar la ficha de asset con todos sus campos (origen, licencia, estado, referencias) [M]
- [ ] Definir el flujo de estados: staging → validado → en_review → aprobado → retirado [S]
- [ ] Definir que la ficha es la única fuente del estado del asset [S]
- [ ] Diseñar asset_preview.tscn con referencia de escala y luces estándar [M]
- [ ] Integrar las herramientas al menú Proyecto > Pipeline de Assets del editor [M]

## J. Integración con otros módulos

- [ ] M45: el catálogo de entregables de Arte 3D debe pasar por staging del pipeline [M]
- [ ] M45: modelar props y NPCs respetando la metría de 1 m del mundo voxel [M]
- [ ] M78: la ficha exige licencia SPDX y atribución; el validador falla sin ellas [M]
- [ ] M78: los assets licenciados se marcan y trazan según la política de PI [M]
- [ ] M86: assets de IA generativa solo con revisión legal y etiquetado explícito en ficha [M]
- [ ] M47: respetar los sufijos de mapas (albedo/normal/roughness/emission) definidos en Texturas y Materiales [S]
- [ ] M48: animaciones embebidas en glb; anim_ solo para clips excepcionales [S]
- [ ] M62: asset_memory_reporter.gd totaliza la VRAM/RAM contra el presupuesto del módulo [C]
- [ ] M63: ids estables = rutas estables para el caché LRU y el streaming de texturas [M]
- [ ] M63: marcar assets grandes (música, cinemáticas) para carga bajo demanda [M]
- [ ] M08: paletas voxel en voxel_palettes/ con filtrado off y mipmaps off [M]
- [ ] M08: props del mundo instanciados con VoxelInstancer/MultiMesh compartido [M]
- [ ] M61: ejecutar los presupuestos finos de Rendimiento cuando estén publicados (en curso) [M]
- [ ] M118: el validador corre en CI headless y rompe el build si hay errores [C]
- [ ] M111: los scripts del pipeline pasan code review y cumplen la guía de estilo GDScript [S]
- [ ] M112: pruebas unitarias de las reglas del validador (nombres, formatos, límites) [C]

## K. Edge cases

- [ ] Asset gigante (> 500 MB o textura 8192²): el validador lo rechaza y sugiere división/optimización [M]
- [ ] Textura sin comprimir (import no VRAM): reporte de error con la ruta del .import a corregir [M]
- [ ] Nombre conflictivo (duplicado o que colisiona tras renombrar): detección y resolución guiada [M]
- [ ] Asset discontinuado con referencias activas: el retiro avisa dependencias antes de archivar [M]
- [ ] Asset licenciado sin ficha: bloqueado en validación hasta completarla [S]
- [ ] Asset de IA sin etiquetado: bloqueado hasta la revisión de M78/M86 [S]
- [ ] Ficha de estado inconsistente con la ubicación del archivo: detectado por el validador [M]
- [ ] Archivo corrupto o truncado: el importador falla y el reporte lo clasifica como error de asset [M]
- [ ] Atlas que excede 4096²: rechazo con sugerencia de dividir por categorías [M]
- [ ] Audio WAV de más de 5 s: rechazo con sugerencia de conversión a OGG [S]
- [ ] Normal map sin tangentes: reimportado con ensure_tangents y verificación visual [M]
- [ ] Renombrado de asset aprobado: migración de referencias con alias y log de cambio [M]
- [ ] Dos agentes importando a la vez: regla de exclusión mutua en staging (archivo de lock) [M]

## L. Optimización del pipeline

- [ ] El validador recorre el árbol en una sola pasada con estadísticas por tipo [C]
- [ ] Reportes markdown con resumen ejecutivo (aprobados, errores, pendientes) [S]
- [ ] El validador usa parallel/skip de carpetas archive/ y .godot/ para no perder tiempo [M]
- [ ] Los presets evitan reimports innecesarios: solo se reimporta lo que cambió [M]
- [ ] El apilado de atlas se hace una sola vez por categoría y se cache a su resultado [M]
- [ ] La escena de preview carga un solo asset a la vez para review rápido [S]
- [ ] El memory reporter estima sin abrir los archivos (usa import settings) [C]
- [ ] Los logs del pipeline no crecen indefinidamente (rotación según AGENTS.md 18) [S]
- [ ] El índice _APROBADAS.md se regenera incrementalmente, no de cero [M]
- [ ] Las herramientas headless devuelven exit code 0/1 para detectar fallos en CI [S]

## M. Documentación

- [ ] Crear ASSET-PIPELINE.md como guía rectora (formatos, nombres, presets, flujo, ficha) [C]
- [ ] Documentar la tabla de formatos permitidos/prohibidos con rutas de conversión [M]
- [ ] Documentar la tabla de convenciones de nombres con ejemplos canónicos [M]
- [ ] Documentar la tabla de presets de importación por tipo [M]
- [ ] Documentar la plantilla de ficha de asset en la guía [S]
- [ ] Documentar el flujo completo con su diagrama y responsables por etapa [M]
- [ ] Documentar los procedimientos de actualización y retiro de assets [M]
- [ ] Mantener plan-actual sincronizado con la implementación real al cerrar el módulo [S]

## N. Testings

- [ ] Definir el plan de testings del pipeline (06-Plan-Testings.md) cuando se implemente [C]
- [ ] Probar el flujo completo con 20 assets de prueba representativos [C]

## Iteración 1 cerrada (2026-09-01) — deepseek-v4-flash-vision-exp / Kilo Code

- [x] CREAR ASSET-PIPELINE.md (guía rectora) — en `plan-actual/ASSET-PIPELINE.md` (formatos RF2/RF3, convención de nombres adoptada §3, ficha RF8, review RF9, optimización RF6, IA RF10, auditoría RF11, retiro RF12) [C]
- [x] Auditor total del árbol: `tools/asset_validator.gd` — **198 assets GLB, 198 OK, 0 errores, exit 0** (re-ejecutado 2 veces: 138 errores antes de fichas → 0 después) [C]
- [x] 66 fichas de asset creadas en `assets/fichas/*.md` (66 IDs únicos de assets/3d/{media,baja,alta}; estado APROBADO por barrido E-13 de M166) [M]
- [x] RF11 reporte generado en `tools/reportes/asset_validation.txt` consumible por humanos y CI [M]
- [x] RF9 review visual de muestra: `scenes/preview_assets.tscn` + `scripts/assets/preview_assets.gd` — 3 assets (casa_completa_ejemplo, totem_isla, palmera) verificados en runtime (captura `tools/mcp/godot-mcp/capturas/108-Pipeline-De-Assets/`): siluetas/correctas, escala, sin artefactos [M]
- [x] RF4 convención de nombres adoptada y documentada: `{NN}-{Modulo}_{snake_case}[_variante].glb` (coherente con M166; NO se renombra la tanda existente) [M]
- [x] RF12 reglas de actualización/retiro documentadas en la guía [S]

### Pendientes de esta iteración (honestidad)

- [?] Presets de importación por tipo (RF5): pendiente — requiere definir import settings por tipo (textura/audio/fuente) cuando M46/M47/M41 entren en producción (dueño: M45/M108 iter 2). Los glb ya importados se importan con defaults de Godot.
- [?] Reglas de tamaño/compresión VRAM auditables (RF6 completo): el validador audita tamaño; mipmaps/compresión se auditarán con texturas reales (M47).
- [?] Flujo `assets/staging/` → aprobación (RF1): carpeta creada en caliente por la guía; el proceso de mover/importar será usado en la primera tanda M45 (dueño: M45/108 iter 2).
- [x] Presupuesto de memoria/frame tras entrada de assets (M61/M62) — CERRADO 2026-09-01 (Log 386): bench real FPS 59.35 / draw calls 374.0 (≤400) / frame 16.35 ms sobre la isla completa; el terreno voxel queda dentro del presupuesto con margen para content.

**Firma:** deepseek-v4-flash-vision-exp / Kilo Code — 2026-09-01
- [ ] Probar el edge case de asset gigante y su rechazo [M]
- [ ] Probar el edge case de textura sin comprimir y su corrección con presets [M]
- [ ] Probar el edge case de nombre conflictivo y la resolución guiada [M]
- [ ] Probar el edge case de asset discontinuado con y sin dependencias [M]
- [ ] Probar el validador en headless con y sin errores (exit codes) [C]
- [ ] Probar que el reimport con presets no rompe referencias de escenas existentes [M]
- [ ] Probar la generación de LODs y shadow meshes en un glb de referencia [M]
- [ ] Probar el memory reporter contra un caso conocido y verificar sus números [M]
- [ ] Probar el promote/retiro dejando el índice _APROBADAS.md correcto [M]
- [ ] Ejecutar los testings antes de la primera prueba manual del usuario y documentar resultados [M]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]

## Evidencia M108 (2026-09-02) — step-3.7-flash / Kilo Code

- [x] Diseño completo documentado en `plan-actual/03-Diseno.md` y `04-Codigo.md` [M]
- [x] 142 tareas de diseño cerradas en checklist personal con referencia a documentación existente [S]
- [x] ASSET-PIPELINE.md guía rectora presente en `plan-actual/` [S]
- [x] Núcleo V0 iniciado: `asset_validator_logic.gd` + wrapper `asset_validator.gd` + runner `run_m108_test.gd` + escena `scenes/tests/test_m108.tscn` creados [M]
- [x] `apply_import_presets_logic.gd` + wrapper `apply_import_presets.gd` creados (lógica V0 headless-compatible) [M]
- [x] `promote_asset_logic.gd` + wrapper `promote_asset.gd` creados (promoción staging → final + índice _APROBADAS.md) [M]
- [ ] Test headless M108 ejecutado y verde 0 fallos — `[?]` (Log 529 previsto; escena de prueba se cerró sin output en intentos automáticos) [C]
- [ ] Validator/presets/promote_asset/atlas_builder/retire_asset/memory_reporter operativos — `[?]` (dueño M108 núcleo) [M]
- [ ] Flujo staging → final con CI headless y exit code — `[?]` (dueño M108/M118) [C]
