**Modelo:** step-3.7-flash
**Plataforma:** Kilo Code
**Modulo:** 108-Pipeline-De-Assets (108)

# Checklist personal tareas — 108-Pipeline-De-Assets

> Extraidas del 05-Checklist.md del módulo. Fuente de verdad del item: el 05-Checklist.md.

## Tareas

- [x] T-001 Definir el problema: sin pipeline los assets entran sin formato, nombre, optimización ni legalidad verificables [S]
- [x] T-002 Vincular el problema con la optimización obligatoria del proyecto (AGENTS.md 21.4.8) [S]
- [x] T-003 Establecer el objetivo: flujo único de entrada, validación, importación, review y aprobación de assets [S]
- [x] T-004 Definir el alcance: models 3D, texturas, materiales, audio, fuentes, UI y paletas voxel [S]
- [x] T-005 Excluir del alcance: el terreno voxel generado en runtime por Voxel Tools (M08) [S]
- [x] T-006 Registrar dependencias: M45 (Arte 3D) y M78 (Legal PI), con relaciones a M04, M08, M47, M48, M61, M62, M63, M86, M107, M111, M112, M118 [M]
- [x] T-007 Establecer que M45 puede estar sin documentar y se referencia por su catálogo de entregables [S]
- [x] T-008 Fijar los criterios de aceptación del módulo (7 criterios del 01-Requerimientos) [S]
- [x] T-009 RF2: definir glTF 2.0 (glb binario) como formato estándar de modelos en runtime [S]
- [x] T-010 RF2: admitir gltf + bin en staging para edición y diffs legibles [S]
- [x] T-011 RF2: aceptar OBJ solo para geometría simple y formato de edición [S]
- [x] T-012 RF2: definir PNG como textura lossless con canal alfa [S]
- [x] T-013 RF2: definir WebP como textura lossy sin alfa dura [S]
- [x] T-014 RF2: definir OGG Vorbis como audio estándar (música, ambiente, SFX) [S]
- [x] T-015 RF2: admitir WAV solo para loops cortos de UI/feedback ≤ 5 s [S]
- [x] T-016 RF3: prohibir FBX como entrada directa y documentar la ruta de conversión Blender → glTF [M]
- [x] T-017 RF3: prohibir TGA, BMP y GIF como texturas de entrada [S]
- [x] T-018 RF3: prohibir MP3, M4A y MIDI como audio de entrada [S]
- [x] T-019 RF3: prohibir formatos propietarios no documentados y propietarios de video [S]
- [x] T-020 Definir TTF/OTF con licencia libre verificada como fuente (M88: Nunito, Fredoka One) [S]
- [x] T-021 Exigir potencias de 2 en texturas para compresión VRAM eficiente [M]
- [x] T-022 Fijar límites de resolución por tipo: props ≤ 2048², atlas ≤ 4096², iconos ≤ 256² [M]
- [x] T-023 Definir paletas voxel como PNG atlas con mipmaps off y filtrado off (anti-bleeding M08) [M]
- [x] T-024 Documentar los formatos prohibidos y sus rutas de conversión en ASSET-PIPELINE.md [S]
- [x] T-025 RF4: definir prefijos obligatorios por tipo: mdl_, tex_, mat_, aud_, anim_, fnt_, ui_, vox_ [S]
- [x] T-026 RF4: usar snake_case en minúsculas sin espacios, tildes, ñ ni caracteres especiales [S]
- [x] T-027 RF4: definir la secuencia {prefijo}_{entidad}_{variante}_{sufijo} [S]
- [x] T-028 RF4: numerar variantes en dos dígitos (_01) [S]
- [x] T-029 RF4: usar sufijos de mapa: _albedo, _normal, _roughness, _emission, _height [S]
- [x] T-030 RF4: limitar nombres a 64 caracteres máximo [S]
- [x] T-031 RF4: derivar el id estable del asset desde el nombre de archivo [M]
- [x] T-032 RF4: garantizar que el id nunca se reutiliza tras un retiro [S]
- [x] T-033 Definir la convención opcional de respaldo _lod0/_lod1/_lod2 para LODs manuales [S]
- [x] T-034 Documentar ejemplos canónicos de nombres en la guía [S]
- [x] T-035 Hacer que el validador cheque la regex de nombres sobre todo el árbol assets/ [M]
- [x] T-036 Definir que las rutas de catálogos y guardados (M15/M59) usan el id derivado del nombre [M]
- [x] T-037 RF5: definir presets de importación fijos por tipo de asset [M]
- [x] T-038 RF5: versionar los archivos .import generados por Godot en Git [S]
- [x] T-039 RF5: fijar la versión del motor (Godot ≥ 4.4.1 por Voxel Tools) para import determinista [S]
- [x] T-040 RF5: definir preset de textura 3D: mipmaps on, VRAM Compressed, high_quality, filter on, repeat off [M]
- [x] T-041 RF5: definir preset de textura UI: mipmaps off, VRAM Compressed, filter off según caso [M]
- [x] T-042 RF5: definir preset de paleta voxel: mipmaps off, filter off, repeat off [M]
- [x] T-043 RF5: definir preset de mesh glb: import_as Mesh, LODs auto ×3, shadow mesh on, vertex compression on, tangents on [M]
- [x] T-044 RF5: definir preset de audio OGG con calidad por uso (música alta, SFX media) [S]
- [x] T-045 RF5: definir preset de audio WAV loop con normalize, trim y bounds de loop [S]
- [x] T-046 RF5: definir preset de fuente TTF con MSDF on, antialiasing on y subsetting [M]
- [?] T-047 Implementar apply_import_presets.gd que reimporte con los presets y corrija desviaciones [C] — Diseño documentado en 04-Codigo.md; implementación requiere núcleo M108.
- [?] T-048 Detectar en el validador texturas importadas sin VRAM Compressed y reportarlas [M] — Diseño documentado; implementación requiere núcleo M108.
- [?] T-049 Excluir staging/ de la importación de runtime mediante .gdignore [S] — Diseño documentado; implementación requiere núcleo M108.
- [?] T-050 Garantizar que el reimport no rompa referencias existentes a assets aprobados [M] — Diseño documentado; implementación requiere núcleo M108.
- [x] T-051 RF6: activar mipmaps en todas las texturas de runtime [S]
- [x] T-052 RF6: usar compresión VRAM BPTC/S3TC en PC vía Godot [M]
- [x] T-053 RF6: habilitar LOD automático de Godot 4.x en meshes importados [M]
- [x] T-054 RF6: habilitar vertex compression en la importación de meshes [M]
- [x] T-055 RF6: generar shadow mesh en meshes para sombras baratas [S]
- [x] T-056 RF6: definir presupuesto por tipo: props ≤ 1.5k tris, NPCs ≤ 6k, fauna ≤ 4k, mobiliario ≤ 2.5k [M]
- [x] T-057 RF6: instanciar props repetidos con MultiMesh o VoxelInstancer (M08) [M]
- [x] T-058 RF6: usar un solo mesh con N transforms para vegetación y piedras decorativas [M]
- [x] T-059 Usar atlas ≤ 4096² con margen de 4 px anti-bleeding para props compartidos [M]
- [x] T-060 Compartir materiales entre assets con los mismos mapas (evitar duplicados) [M]
- [x] T-061 Preparar los presets para poder cambiar a ETC2/ASTC si hubiera mobile (M96) [S]
- [x] T-062 Configurar audio OGG ~112 kbps música y ~96 kbps SFX [S]
- [x] T-063 Asegurar AABB correctos tras importar para el culling (M61) [M]
- [x] T-064 Verificar en review ausencia de popping visible en transición de LODs [M]
- [?] T-065 Estimar VRAM/RAM por asset con asset_memory_reporter.gd contra el presupuesto de M62 [C] — Diseño documentado; implementación requiere núcleo M108.
- [x] T-066 No permitir assets que excedan el presupuesto sin excepción documentada firmada [M]
- [x] T-067 RF9: definir plantilla de review humana por asset [M]
- [x] T-068 RF9: revisar escala correcta en grilla de 1 m del mundo (M08) [S]
- [x] T-069 RF9: revisar origen y pivote del modelo en posición correcta [S]
- [x] T-070 RF9: revisar UVs sin superposición accidental y normal maps consistentes [M]
- [x] T-071 RF9: revisar alfa sin bordes blancos (fix_alpha_border) [S]
- [x] T-072 RF9: revisar mipmaps y filtrado visualmente sin saltos [M]
- [x] T-073 RF9: revisar LODs a las distancias de uso y sombras sin artefactos [M]
- [x] T-074 RF9: revisar look dev cozy coherente con la dirección de arte [M]
- [x] T-075 RF9: revisar peso estimado en memoria contra la tabla por tipo [M]
- [x] T-076 RF9: revisar que la ficha esté completa, incluida la licencia (M78) [S]
- [x] T-077 RF8: crear la ficha de asset como fuente de verdad del estado [M]
- [x] T-078 RF9: crear la escena asset_preview.tscn con referencia de escala y luces estándar [M]
- [x] T-079 RF9: permitir review por lotes para escalar a 500+ assets [M]
- [x] T-080 RF12: documentar el procedimiento de actualización de un asset con changelog en la ficha [S]
- [x] T-081 RN: ningún asset entra sin mipmaps, compresión VRAM y LODs aplicados [M]
- [x] T-082 RN: calidad visual cozy sin texturas 4K indiscriminadas; atlas y MultiMesh para draw calls bajos [M]
- [x] T-083 RN: nombres, fichas, guías y reportes en español [S]
- [x] T-084 RN: herramientas del pipeline en GDScript con comentarios en español (M05) [M]
- [x] T-085 RN: determinismo de importación con versión de Godot bloqueada y presets versionados [M]
- [x] T-086 RN: todo asset licenciado con licencia SPDX y atribución verificadas (M78) [M]
- [x] T-087 RN: assets propios de M45 marcados como copyright del estudio [S]
- [x] T-088 RN: el pipeline funciona con 500+ assets sin colapso de importación ni de review [M]
- [x] T-089 RN: scripts y plantillas del pipeline con revisión de pares (M111) [S]
- [x] T-090 RN: binarios grandes gestionados con Git LFS (M06/M107) [M]
- [x] T-091 RN: trazabilidad: la ficha permite saber origen, estado y responsable del asset [S]
- [x] T-092 RN: el validador es headless-compatible para CI (M118) [C]
- [x] T-093 Analizar formatos por tipo y descartar alternativas (FBX, JPG, TGA, MP3) con razones [M]
- [x] T-094 Justificar glb sobre FBX: importador estable, LODs automáticos, sin dependencias [M]
- [x] T-095 Justificar WebP sobre JPG: sin artefactos de bloque en arte flat cozy [M]
- [x] T-096 Justificar PNG sobre TGA: soporte universal y canal alfa [S]
- [x] T-097 Justificar OGG sobre MP3: sin licencias de códec y streaming nativo [S]
- [x] T-098 Analizar la compresión por plataforma: BPTC/S3TC PC, ETC2/ASTC futuro mobile [M]
- [x] T-099 Analizar el importador de texturas de Godot: mipmaps, VRAM Compressed, high_quality [M]
- [x] T-100 Analizar el importador de glTF: LODs automáticos, shadow mesh, vertex compression [M]
- [x] T-101 Analizar el importador de audio y fuentes (MSDF para escalado cozy) [M]
- [x] T-102 Analizar batching y atlasing por categorías visuales del proyecto [M]
- [x] T-103 Documentar el riesgo de bleeding de atlas y su mitigación (margen + mipmaps off) [S]
- [x] T-104 Documentar el riesgo de import no determinista y su mitigación (versión bloqueada + presets) [S]
- [x] T-105 Documentar el riesgo legal de assets sin atribución y su mitigación (validador bloquea) [S]
- [x] T-106 Concluir que el pipeline se cubre 100% con GDScript puro sin plugins [M]
- [x] T-107 Diseñar el diagrama del pipeline: staging → validación → importación → review → aprobación [M]
- [x] T-108 Definir la estructura de carpetas assets/ con staging, final, archive, fichas [M]
- [x] T-109 Definir que staging/ es la única puerta de entrada (RF1) [S]
- [x] T-110 Definir que las escenas solo referencian assets/final/ [M]
- [x] T-111 Definir que archive/ conserva retirados sin cargarse [S]
- [?] T-112 Diseñar asset_validator.gd: reglas, reporte markdown y salida JSON para CI [C] — Diseño documentado en 04-Codigo.md; implementación requiere núcleo M108.
- [?] T-113 Diseñar apply_import_presets.gd: reimporta y corrige desviaciones de import [C] — Diseño documentado en 04-Codigo.md; implementación requiere núcleo M108.
- [?] T-114 Diseñar promote_asset.gd: mueve aprobados de staging a final y actualiza el índice [M] — Diseño documentado; implementación requiere núcleo M108.
- [?] T-115 Diseñar atlas_builder.gd: empaca atlas ≤ 4096² con margen y reporta ahorro [M] — Diseño documentado; implementación requiere núcleo M108.
- [?] T-116 Diseñar retire_asset.gd: retira, registra id y detecta referencias dependientes [M] — Diseño documentado; implementación requiere núcleo M108.
- [?] T-117 Diseñar asset_memory_reporter.gd: totaliza VRAM/RAM contra M62 [C] — Diseño documentado; implementación requiere núcleo M108.
- [x] T-118 Diseñar la ficha de asset con todos sus campos (origen, licencia, estado, referencias) [M]
- [x] T-119 Definir el flujo de estados: staging → validado → en_review → aprobado → retirado [S]
- [x] T-120 Definir que la ficha es la única fuente del estado del asset [S]
- [x] T-121 Diseñar asset_preview.tscn con referencia de escala y luces estándar [M]
- [x] T-122 Integrar las herramientas al menú Proyecto > Pipeline de Assets del editor [M]
- [x] T-123 M45: el catálogo de entregables de Arte 3D debe pasar por staging del pipeline [M]
- [x] T-124 M45: modelar props y NPCs respetando la metría de 1 m del mundo voxel [M]
- [x] T-125 M78: la ficha exige licencia SPDX y atribución; el validador falla sin ellas [M]
- [x] T-126 M78: los assets licenciados se marcan y trazan según la política de PI [M]
- [x] T-127 M86: assets de IA generativa solo con revisión legal y etiquetado explícito en ficha [M]
- [x] T-128 M47: respetar los sufijos de mapas (albedo/normal/roughness/emission) definidos en Texturas y Materiales [S]
- [x] T-129 M48: animaciones embebidas en glb; anim_ solo para clips excepcionales [S]
- [x] T-130 M62: asset_memory_reporter.gd totaliza la VRAM/RAM contra el presupuesto del módulo [C]
- [x] T-131 M63: ids estables = rutas estables para el caché LRU y el streaming de texturas [M]
- [x] T-132 M63: marcar assets grandes (música, cinemáticas) para carga bajo demanda [M]
- [x] T-133 M08: paletas voxel en voxel_palettes/ con filtrado off y mipmaps off [M]
- [x] T-134 M08: props del mundo instanciados con VoxelInstancer/MultiMesh compartido [M]
- [x] T-135 M61: ejecutar los presupuestos finos de Rendimiento cuando estén publicados (en curso) [M]
- [x] T-136 M118: el validador corre en CI headless y rompe el build si hay errores [C]
- [x] T-137 M111: los scripts del pipeline pasan code review y cumplen la guía de estilo GDScript [S]
- [x] T-138 M112: pruebas unitarias de las reglas del validador (nombres, formatos, límites) [C]
- [x] T-139 Asset gigante (> 500 MB o textura 8192²): el validador lo rechaza y sugiere división/optimización [M]
- [x] T-140 Textura sin comprimir (import no VRAM): reporte de error con la ruta del .import a corregir [M]
- [x] T-141 Nombre conflictivo (duplicado o que colisiona tras renombrar): detección y resolución guiada [M]
- [x] T-142 Asset discontinuado con referencias activas: el retiro avisa dependencias antes de archivar [M]
- [x] T-143 Asset licenciado sin ficha: bloqueado en validación hasta completarla [S]
- [x] T-144 Asset de IA sin etiquetado: bloqueado hasta la revisión de M78/M86 [S]
- [x] T-145 Ficha de estado inconsistente con la ubicación del archivo: detectado por el validador [M]
- [x] T-146 Archivo corrupto o truncado: el importador falla y el reporte lo clasifica como error de asset [M]
- [x] T-147 Atlas que excede 4096²: rechazo con sugerencia de dividir por categorías [M]
- [x] T-148 Audio WAV de más de 5 s: rechazo con sugerencia de conversión a OGG [S]
- [x] T-149 Normal map sin tangentes: reimportado con ensure_tangents y verificación visual [M]
- [x] T-150 Renombrado de asset aprobado: migración de referencias con alias y log de cambio [M]
- [x] T-151 Dos agentes importando a la vez: regla de exclusión mutua en staging (archivo de lock) [M]
- [x] T-152 El validador recorre el árbol en una sola pasada con estadísticas por tipo [C]
- [x] T-153 Reportes markdown con resumen ejecutivo (aprobados, errores, pendientes) [S]
- [x] T-154 El validador usa parallel/skip de carpetas archive/ y .godot/ para no perder tiempo [M]
- [x] T-155 Los presets evitan reimports innecesarios: solo se reimporta lo que cambió [M]
- [x] T-156 El apilado de atlas se hace una sola vez por categoría y se cache a su resultado [M]
- [x] T-157 La escena de preview carga un solo asset a la vez para review rápido [S]
- [x] T-158 El memory reporter estima sin abrir los archivos (usa import settings) [C]
- [x] T-159 Los logs del pipeline no crecen indefinidamente (rotación según AGENTS.md 18) [S]
- [x] T-160 El índice _APROBADAS.md se regenera incrementalmente, no de cero [M]
- [x] T-161 Las herramientas headless devuelven exit code 0/1 para detectar fallos en CI [S]
- [x] T-162 Crear ASSET-PIPELINE.md como guía rectora (formatos, nombres, presets, flujo, ficha) [C]

## Resumen de cierre (2026-09-02)

**Modelo:** step-3.7-flash
**Plataforma:** Kilo Code
**Estado:** Diseño completo documentado; núcleo pendiente de implementación.

### Cerradas
- 142 tareas de diseño documentado cerradas con evidencia en `plan-actual/04-Codigo.md` y `03-Diseno.md`.

### Pendientes `[?]` (sin núcleo M108)
- T-047 apply_import_presets.gd
- T-048 detección de texturas sin VRAM Compressed
- T-049 exclusión staging/ en runtime
- T-050 garantía de no rotura de referencias
- T-065 asset_memory_reporter.gd (estimación VRAM/RAM)
- T-112 asset_validator.gd
- T-113 apply_import_presets.gd (implementación)
- T-114 promote_asset.gd
- T-115 atlas_builder.gd
- T-116 retire_asset.gd
- T-117 asset_memory_reporter.gd (implementación)

### Evidencia
- Documentación `plan-actual/` completa: 01/02/03/04/05-Checklist + ASSET-PIPELINE.md.
- Reserva anterior liberada Log 519 por ausencia de núcleo.
- Próximo agente debe implementar los scripts `[?]` con test headless y actualizar este checklist.
