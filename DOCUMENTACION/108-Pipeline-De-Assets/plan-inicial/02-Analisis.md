**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 108: Pipeline de Assets

## 1. Análisis del Dominio

### 1.1 Formatos por tipo de asset (Godot 4.x)

**Modelos 3D:**
- **glTF 2.0 (`.glb` binario)** — formato recomendado para runtime: soporte nativo de Godot 4, recuento de materiales, normales, UVs, huesos y animaciones en un solo archivo, e importador estable con generación automática de LOD (Godot 4.3+). Se elige como estándar de salida.
- **`.gltf` + `.bin` (JSON)** — para edición y diffs legibles en Git; se usa en staging y para assets que requieren inspección, no en runtime.
- **OBJ** — geometría simple sin materiales ni animaciones; aceptado solo para piezas triviales (planos de prueba, cajas colisionadoras) y como formato intermedio de edición.
- **FBX** — **prohibido** como formato de entrada directa: conversión obligatoria vía Blender/exporter a glTF. Motivo: importador histórico de Godot con estados inconsistentes, y el ecosistema de surtido comercial entrega casi todo en FBX, que debe pasar a formato propio.

**Mallas del mundo voxel:** los chunks del terreno (M08) no se importan como assets: son generados por Voxel Tools en runtime y se materializan con la paleta de Voxel Mesher (VoxelMesherBlocky). Los assets 3D del módulo cubren props, NPCs, fauna, muebles y ruinas colocados sobre el mundo voxel, que usan `MeshInstance3D` + `VoxelInstancer` o `MultiMesh` (RF6/M08). La metría de todos los props debe respetar la grilla de 1 m del mundo (M08).

**Texturas:**
- **PNG** — lossless, con canal alfa; estándar para arte 2D, atlas, iconos y texturas con transparencia. En runtime Godot las vuelve a comprimir a VRAM según el preset (`VRAM Compressed`, S3TC/BPTC en PC).
- **WebP** — lossy con buen ratio para texturas sin alfa dura (paredes, materiales), fondos de UI y contenido con muchas fotografías; requiere revisión de calidad por artefactos.
- **Dimensiones:** potencias de 2 (2^n) exigidas para compresión VRAM eficiente; límites por tipo: props ≤ 2048², atlas ≤ 4096², iconos UI ≤ 256² (M53), normal maps ≤ 1024² salvo excepción documentada.
- **Prohibidos en entrada:** TGA, BMP, GIF (formato de animación con paleta limitada), JPG (artefactos de bloque inaceptables para arte flat cozy).
- **Formato de salida de paletas voxel:** PNG de atlas `voxel_palette` con grilla transparente, importado con filtrado off y mipmaps off para evitar bleeding entre bloques (M08).

**Audio:**
- **OGG Vorbis** — formato estándar de música y efectos: calidad suficiente, streaming nativo de Godot, buena relación peso/duración. Todo el audio del proyecto (M41 música, M42 ambiente, M43 SFX) entra como OGG 44.1 kHz / 16 bit.
- **WAV** — solo para loops cortos de UI/feedback (M44) que requieren loop perfecto sin códec; límite: 5 s a 22 kHz para no inflar la RAM; de ahí en más, OGG.
- **Prohibidos:** MP3 (licencias de códec heredadas), M4A/AAC, MIDI, formatos con DRM.

**Fuentes:** TTF/OTF con licencia libre verificada (M88, ej: Nunito, Fredoka One, ambas SIL OFL 1.1); Godot compila a `.fontdata` con subsetting. Prohibidas fuentes con licencias restrictivas.

### 1.2 Convenciones de nombres

- **Prefijo por tipo obligatorio:** `mdl_` (modelo), `tex_` (textura), `mat_` (material), `aud_` (audio), `anim_` (animación), `fnt_` (fuente), `ui_` (asset de UI), `vox_` (paleta/pieza voxel). El prefijo evita colisiones entre tipos y habilita el filtrado por tipo en el editor y en el validador.
- **snake_case** en minúsculas, sin espacios, sin tildes ni `ñ`, sin caracteres especiales: `mdl_cofre_roble_a.glb`, `tex_cofre_roble_albedo.webp`, `aud_pesca_caer_01.ogg`.
- **Secuencia:** `{prefijo}_{entidad}_{variante}_{sufijo opcional}`. Variantes numeradas en dos dígitos (`_01`). Sufijos por mapa: `_albedo`, `_normal`, `_roughness`, `_emission`, `_height`.
- **Máximo 64 caracteres** (límite práctico de rutas y sistemas de archivos cruzados).
- **Id estable:** el `id` del asset se deriva del nombre de archivo y se usa como clave en fichas, ItemData (M15), catálogos y guardados (M59). Un id nunca se reutiliza tras un retiro.
- **Identificador de uso:** sufijo `_lod0/_lod1/_lod2` cuando los LODs se manejan como archivos separados (recomendado: LODs automáticos de Godot; esta convención es opcional de respaldo).

### 1.3 Compresión por plataforma

- **PC Windows/Linux (objetivo principal):** texturas VRAM comprimidas BPTC (BC7) — mejor calidad que DXTC en transparencias; Godot lo selecciona con `VRAM Compressed`. S3TC (BC1/BC3) automático para texturas sin alfa.
- **Steam Deck / Linux:** mismas rutas de Vulkan; BPTC disponible; verificar drivers en Deck (todas las variantes `bptc` soportadas).
- **Mobile (revisión futura, M96):** ETC2/ASTC; no se optimiza hoy pero los presets se diseñan para poder cambiar de compress mode sin reexportar arte.
- **Audio:** OGG ~112 kbps de música, ~96 kbps SFX; WAV para loops cortos (≤ 5 s).
- **Meshes:** verificación de vertex count y LOD automático; se documenta el presupuesto por tipo (props ≤ 1.5k tris en LOD0, NPCs ≤ 6k, fauna ≤ 4k, mobiliario ≤ 2.5k) sujeto al frame budget de M61.

### 1.4 Import settings de Godot (importers)

**Texturas (`import_as=CompressedTexture2D`):**
- `mipmaps/generate=true` (obligatorio en runtime para filtrado y rendimiento)
- `compress/mode=VRAM Compressed`
- `compress/high_quality=true` (BPTC en plataformas que lo soporten)
- `detect_3d=true` (reducción de tamaño en 3D)
- `filter=true`, `repeat=disabled` para assets 3D; `repeat=enabled` solo para atlas procedurales
- `fix_alpha_border=true` cuando hay alfa con bordes blancos
- Edición: `import_as=File` se prohíbe salvo texturas de staging; `SVG` solo para vectores de UI.

**Meshes (`import_as=Mesh`, glTF):**
- `meshes/lods=true` y `meshes/lod_count` (3) con simplificación automática
- `meshes/generate_shadow_mesh=true` (sombra barata, rendimiento)
- `meshes/ensure_tangents=true` para normal mapping
- `meshes/use_compression=true` (vertex compression: posiciones 16 bit, normales 8 bit)
- `animations/import=true` solo si el asset las trae; `skip_animation=1` para props estáticos
- `root_type=MeshInstance3D` (no Skeleton3D salvo NPCs animados)

**Audio (`import_as=AudioStreamOggVorbis` / `AudioStreamWAV`):**
- OGG: `loop_off` salvo piezas loop; calidad por preset (música alta, SFX media)
- WAV: `loop_mode=forward` en loops de UI, `edit/trim=true`, `edit/normalize=true`, `edit/loop_begin`/`loop_end` explícitos

**Fuentes:** `import_as=FontFile`, `multichannel_signed_distance_field=true` para escalar sin pérdida (estilo cozy requiere textos a varios tamaños), `fallbacks=[]` definidos, `antialiasing=on`, `subpixel_positioning=auto`.

### 1.5 Batching y atlasing

- **Atlas de texturas por categoría:** muebles/props comparten atlas por paleta visual (madera, piedra, elementos ancestrales) para reducir búsquedas de material y draw calls (M08/M61). Regla: atlas ≤ 4096², con `mipmaps=on`, sin `repeat`, packing con margen de 4 px para evitar bleeding.
- **MultiMesh instanceado:** vegetación, piedras decorativas, luciérnagas y props repetidos se instancian con `MultiMeshInstance3D` (o `VoxelInstancer` de Voxel Tools para el mundo) — un solo mesh con N transforms.
- **Material sharing:** los materiales con los mismos mapas comparten `Material` (evitar duplicados por copia); los `ShaderMaterial` se reutilizan con parámetros por instancia.
- **LODs:** mallas con simplificación automática (Godot 4.3+); en el importador glTF se configuran 3 niveles; distancia de cambio por tamaño del asset (props 8/20/40 m estimados, calibrar en M61).
- **Culling:** `visibility_range` (AABB, OBB, frustum) y `occlusion_culling` activados por escena (M61); el pipeline exige AABB correctos tras importar.

## 2. Alternativas y Decisiones

| Tema | Alternativa descartada | Decisión | Razón |
|---|---|---|---|
| Formato 3D | FBX como entrada | glTF 2.0 (glb) como estándar | Importador estable, LODs automáticos, sin dependencias de exportadores |
| Textura lossy | JPG | WebP | Sin artefactos de bloque en arte flat; ratio superior |
| Textura lossless | TGA | PNG | Soporte universal, canal alfa, comprimible a VRAM |
| Audio | MP3 | OGG Vorbis (WAV para loops) | Sin problemas de licencia de códec; streaming nativo |
| Compresión PC | Sin compresión | VRAM BPTC/S3TC vía Godot | Mismo presupuesto de M62 sin tocar arte |
| LODs | Hacerlos a mano | Automáticos del importador + respaldo manual `_lodN` | Menos fricción; control manual solo cuando el automático falle |
| Proceso | Importar directo al árbol | Staging → validación → import → review → aprobación | Evita basura en el árbol y asegura review previa |
| Nombres | Convención libre | Prefijos + snake_case + id estable | Colisiones evitadas; validación máquina-legible |
| Origen | Decidir por asset | Etiquetado obligatorio (propio M45 / licenciado M78) con ficha | Requisito legal M78 y trazabilidad |
| IA generativa | Usar sin control | Permitida solo con revisión y etiquetado (M86) | Legal e identidad del arte |

## 3. Riesgos y Mitigaciones

- **FBX heredado del surtidor:** → conversión Blender → glTF en staging, checklist de conversión.
- **Texturas 4K fuera de presupuesto:** → límites por tipo documentados y chequeados por el validador.
- **Bleeding de atlas voxel:** → mipmaps off + filtrado off + margen de packing; verificación visual en review.
- **Asset licenciado sin atribución:** → el validador falla si la ficha no tiene licencia+atribución (M78).
- **Import no determinista entre máquinas:** → lock de versión de Godot (≥ 4.4.1), presets en repo, `.import` versionado.
- **Nombre conflictivo tras retirar un asset:** → ids nunca reutilizados; alias de renombrado con migración guiada.

## 4. Conclusión de Análisis

El stack Godot 4.x permite cubrir el pipeline completo con **GDScript puro sin dependencias externas**: EditorScripts para batch y validación, presets de importación versionables y formatos abiertos. La optimización queda garantizada en la **entrada** (validación automática) y en la **importación** (presets), no como parche posterior. El flujo staging → import → review → aprobación es simple, verificable por CI (M118) y escalable a cientos de assets.