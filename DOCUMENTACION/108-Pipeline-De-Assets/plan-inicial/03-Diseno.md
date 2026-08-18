**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 108: Pipeline de Assets

## 1. Arquitectura del Pipeline

```
┌────────────────────────────────────────────────────────────────────┐
│                     ENTRADA (fuentes de origines)                  │
│   M45 Arte 3D (propio)   ·   Licenciado (M78)   ·   IA (M86)      │
└──────────────────────────────┬─────────────────────────────────────┘
                               ▼
┌────────────────────────────────────────────────────────────────────┐
│  assets/staging/   (zona de cuarentena: sin .import válido)        │
│  - Cumplir formato permitido (RF2) y nombres (RF4)                 │
│  - Ficha de origen y licencia adjunta (RF8)                        │
└──────────────────────────────┬─────────────────────────────────────┘
                               ▼
┌────────────────────────────────────────────────────────────────────┐
│  1. VALIDACIÓN AUTOMÁTICA   asset_validator.gd (EditorScript)      │
│  formato · nombre · tamaño · dimensiones · mipmaps · licencia      │
│  → reporte de errores; el asset NO avanza si falla                 │
└──────────────────────────────┬─────────────────────────────────────┘
                               ▼
┌────────────────────────────────────────────────────────────────────┐
│  2. IMPORTACIÓN GODOT   (presets fijos por tipo, RF5)              │
│  PNG/WebP → CompressedTexture2D (mipmaps + VRAM comprimida)        │
│  glb    → Mesh (LODs auto + vertex compression + shadow mesh)      │
│  OGG    → AudioStreamOggVorbis   ·   TTF → FontFile (MSDF)         │
│  se versiona el .import generado                                   │
└──────────────────────────────┬─────────────────────────────────────┘
                               ▼
┌────────────────────────────────────────────────────────────────────┐
│  3. REVIEW DE CALIDAD (humana, por lotes)                          │
│  revisión contra ASSET-PIPELINE.md + plantilla de review           │
│  look dev cozy · UVs · escala/metría 1 m (M08) · LODs · memory     │
└──────────────────────────────┬─────────────────────────────────────┘
                               ▼
┌────────────────────────────────────────────────────────────────────┐
│  4. APROBACIÓN / ALTA                                         │
│  ficha marcada aprobada → asset pasa a assets/{tipo}/final/         │
│  queda disponible para escenas, catálogos (M15) y meshes M08      │
└────────────────────────────────────────────────────────────────────┘
```

### 1.1 Carpetas de Assets (libro de ruta Godot)

```
assets/
├── ASSET-PIPELINE.md              ← Guía rectora del pipeline (ver 04-Codigo.md)
├── staging/                       ← Cuarentena: assets entrantes sin validar
│   ├── models/
│   ├── textures/
│   ├── audio/
│   └── fonts/
├── models/
│   ├── final/                     ← aprobados y referenciados por escenas
│   └── archive/                   ← retirados/discontinuados (no se cargan)
├── textures/                      ← igual esquema final/archive
│   ├── final/
│   └── archive/
├── audio/
│   ├── final/
│   └── archive/
├── fonts/
├── materials/                     ← solo materiales compartidos/reutilizables
├── ui/                            ← atlas, iconos, vectores SVG (M53)
├── voxel_palettes/                ← atlas de paleta de bloques (M08)
├── anims/                         ← solo si no van embebidas en glb
└── fichas/                        ← fichas markdown por asset (RF8)
    ├── {asset_id}.md
    └── _APROBADAS.md              ← índice de aprobadas (generado)
```

Reglas de la carpeta:
- `staging/` es la **única** puerta de entrada (RF1); Godot la excluye de la importación de runtime (`.gdignore` en staging) para que un asset a medio limpiar no consuma memoria.
- `final/` solo contiene assets aprobados; escenas y scripts referencian exclusivamente `final/` (convención chequeada por el validador).
- `archive/` conserva el historial de retirados sin cargarse (RF12); los ids no se reutilizan.
- Los `.import` se versionan; los binarios grandes con Git LFS (M06/M107).

### 1.2 Flujo de importación detallado

1. **Entrada:** el artista (M45) o el gestor de licencias (M78) deposita el archivo + ficha en `staging/{tipo}/`.
2. **Validación automática:** `asset_validator.gd` corre con `EditorScript` (menú `Proyecto > Herramientas > Validar Assets` o desde terminal `godot --headless --script`) y genera `_reporte_validacion.md`.
   - Si falla → el asset no avanza; el reporte indica el motivo exacto y la regla violada.
   - Si pasa → se emite un `aprobación_automatica` (no reemplaza la review humana).
3. **Importación Godot:** se reimporta con el preset del tipo (fuerza `import_defaults` o `.import` versionado), se regeneran mipmaps/LODs/compresión.
4. **Review humana:** revisor abre la escena de prueba `res://tools/asset_review/asset_preview.tscn` con el asset, completa la plantilla de review (`06`), verifica look dev, escala (caja 1 m de referencia), LODs y comportamiento de sombras.
5. **Aprobación:** la ficha pasa a `aprobado`; el asset se mueve a `{tipo}/final/`; el índice `_APROBADAS.md` se regenera; se dispara el log del pipeline (formato NN-ASSET-... en `Logs/`, sección 6 de AGENTS.md).
6. **Publicación:** catálogos (M15), spawners (M08) y escenas referencian el id del asset aprobado.

### 1.3 Herramientas de batch (GDScript, EditorScripts)

| Herramienta | Archivo previsto | Función |
|---|---|---|
| Validador | `tools/asset_pipeline/asset_validator.gd` | Recorre `assets/`, valida reglas (nombre, formato, tamaño, mipmaps, licencia, referencia a `final/`), emite reporte markdown con estado por asset |
| Aplicador de presets | `tools/asset_pipeline/apply_import_presets.gd` | Reimporta con los presets definidos por tipo; corrige `import` desviados (ej: textura sin compresión VRAM) |
| Movedor staging→final | `tools/asset_pipeline/promote_asset.gd` | Mueve asset+ficha aprobados de staging a final, actualiza el índice `_APROBADAS.md` y genera log |
| Regenerador de atlas | `tools/asset_pipeline/atlas_builder.gd` | Empaca texturas del mismo set en atlas ≤ 4096² con margen y reporta ahorro de draw calls |
| Retirador | `tools/asset_pipeline/retire_asset.gd` | Marca discontinuado, mueve a `archive/`, registra id retirado (no reutilizable) y avisa dependencias (grep de referencias) |
| Analizador de memoria | `tools/asset_pipeline/asset_memory_reporter.gd` | Estima VRAM/RAM por asset según import settings y totaliza contra el presupuesto de M62 |

Todas corren en editor (EditorScript) y son headless-compatibles para CI (M118). Se integran al menú `Proyecto > Pipeline de Assets`.

### 1.4 Review de calidad (plantilla de asset / ficha)

La **ficha de asset** `assets/fichas/{asset_id}.md` es la fuente de verdad de cada asset:

```markdown
# Ficha: {asset_id}
- **Tipo:** mdl | tex | aud | mat | anim | fnt | ui | vox
- **Entidad:** {entidad}          **Variante:** {variante}
- **Origen:** propio (M45) | licenciado (M78) | IA revisada (M86)
- **Licencia:** {SPDX}            **Atribución:** {texto}
- **Fecha entrada:** YYYY-MM-DD   **Fecha aprobación:** YYYY-MM-DD
- **Formato:** glb | png | webp | ogg | wav | ttf
- **Dimensiones/tamaño:** {WxH px o MB}   **Tris (si mdl):** {n}
- **LODs:** auto(3) | manual(_lod0..2) | n/a      **Mipmaps:** sí | no
- **Compresión VRAM:** bptc | s3tc | etc2 | n/a
- **Estado:** staging | validado | en_review | aprobado | retirado
- **Referenciado por:** {escenas/catálogos}   **Revisor:** {nombre}
- **Cambios:** {fechas y descripciones breves}
```

El **checklist de review** (plantilla `09-Plantilla-Review.md` prevista) incluye: escala correcta en grilla de 1 m (M08), origen correcto (0,0,0 en el pivote), rotación sin sesgos, UVs sin superposición accidental, alfa sin bordes blancos, mipmaps visibles sin saltos, LODs sin popping a distancias de uso, sombras sin artefactos, peso en memoria conforme a tabla por tipo, look dev cozy aprobado, y ficha completa (licencia obligatoria para los licenciados).

### 1.5 Optimización integrada (resumen ejecutivo)

- Texturas: VRAM comprimida (BPTC/S3TC), mipmaps, potencias de 2, límites por tipo (01-Requerimientos RF6 / 02-Analisis 1.1).
- Meshes: LOD automático ×3 + shadow mesh + vertex compression; MultiMesh/VoxelInstancer para instancias (M08).
- Atlas por categoría visual (madera, piedra, ancestral, vegetación) para prop compartido.
- Audio: OGG con calidad por preset; WAV solo loops ≤ 5 s.
- Culling: AABB/visibility_range por escena; chequeado en review (M61 en curso define los números finos).
- Presupuestos referenciados: memoria M62 (VRAM sensible a resoluciones) y frame budget M61.

## 2. Interacción con otros módulos

- **M45 (Arte 3D):** provee el catálogo de entregables (props, NPCs, fauna, mobiliario, ruinas) en el estándar de este pipeline; el validador exige que todo lo que declare M45 pase por staging.
- **M47 (Texturas y Materiales):** define los mapas (albedo, normal, roughness, emission) cuyos sufijos de nombre y presets de import se respetan aquí.
- **M48 (Animación):** las animaciones vienen embebidas en glb de NPCs/fauna; `anim_` solo para clips sueltos excepcionales.
- **M78 (Legal PI):** la ficha exige licencia y atribución; el validador falla sin ellas; assets IA (M86) etiquetados en ficha.
- **M62 (Memoria):** `asset_memory_reporter.gd` totaliza VRAM/RAM por asset contra el presupuesto.
- **M63 (Cargas y Streaming):** nombres estables = rutas estables para el caché LRU y texturas a demanda; assets grandes (música, cinemáticas) marcados com load/stream.
- **M08 (Mundo Voxel):** paletas bloque en `voxel_palettes/` con filtrado off; props instanciados vía VoxelInstancer/MultiMesh respetan la grilla de 1 m.
- **M61 (Rendimiento):** define los números finos (distancias de LOD, culling); el pipeline ejecuta sus presets y el validador chequea conformidad.
- **M118 (CI/CD):** validador y reimportador corren headless en CI con la versión de Godotbloqueada.
- **M86 (IA Generativa):** assets IA solo con revisión y etiquetado, vía M78.
- **M107 (Backups):** los assets propios de M45 respaldados por la política 3-2-1; los binarios grandes con LFS.

## 3. Uso de señales/estados (contrato mínimo)

- Estado de asset: `staging` → `validado` → `en_review` → `aprobado` → (`retirado`).
- La ficha es la única fuente del estado; mover archivos sin actualizar la ficha es error de pipeline (el validador lo detecta).
- Transiciones: `promote_asset.gd` solo mueve si estado == `aprobado`; `retire_asset.gd` solo si no tiene referencias abiertas (grep de `{asset_id}` en escenas y catálogos) o registra el plan de migración.