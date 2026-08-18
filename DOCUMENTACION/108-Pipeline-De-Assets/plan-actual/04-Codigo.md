**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 108: Pipeline de Assets

## 1. Archivos previstos (Pendiente de implementación)

Todos los archivos de este módulo están **pendientes de implementación**: el presente documento es el diseño del pipeline, no su código. El agente delegado los creará junto con la primera tanda de assets de M45.

| Archivo previsto | Ubicación | Rol | Depende de |
|---|---|---|---|
| `ASSET-PIPELINE.md` | `assets/` | Guía rectora: formatos permitidos/prohibidos, convenciones de nombres, presets de importación, flujo completo, plantilla de ficha | — |
| `asset_validator.gd` | `tools/asset_pipeline/` | EditorScript: recorre `assets/`, valida reglas y emite `_reporte_validacion.md`; headless-compatible | guía de reglas |
| `apply_import_presets.gd` | `tools/asset_pipeline/` | EditorScript: reimporta assets con presets fijos por tipo y corrige desviaciones | presets definidos en la guía |
| `promote_asset.gd` | `tools/asset_pipeline/` | Mueve `staging` → `final/` tras aprobación, actualiza el índice `_APROBADAS.md` | validador |
| `atlas_builder.gd` | `tools/asset_pipeline/` | Empaca texturas del mismo set en atlas ≤ 4096² con margen anti-bleeding | — |
| `retire_asset.gd` | `tools/asset_pipeline/` | Discontinúa un asset: mueve a `archive/`, registra id retirado, avisa dependencias | — |
| `asset_memory_reporter.gd` | `tools/asset_pipeline/` | Estima VRAM/RAM por asset según import settings y totaliza contra M62 | presupuestos M62 |
| `asset_preview.tscn` | `tools/asset_review/` | Escena de prueba con caja de referencia de 1 m, luces estándar y cámara orbitante para review | — |
| `_APROBADAS.md` | `assets/fichas/` | Índice generado de assets aprobados (id, tipo, ruta, fecha) | promote_asset |
| Fichas por asset | `assets/fichas/{asset_id}.md` | Ficha markdown por asset (fuente de verdad del estado y licencia) | plantilla de ficha |
| `_reporte_validacion.md` | `assets/staging/` | Reporte generado por el validador con errores por asset | asset_validator |

### 1.1 Pseudocódigo del validador (referencia de implementación)

```gdscript
# tools/asset_pipeline/asset_validator.gd
# (EditorScript — pendiente de implementación)
extends EditorScript

const REGLAS := {
    "nombre":      { "regex": r"^(mdl|tex|mat|aud|anim|fnt|ui|vox)_[a-z0-9_]{1,59}$" },
    "extensiones": { "glb": ["mdl"], "gltf": ["mdl"], "obj": ["mdl"],
                     "png": ["tex", "ui", "vox"], "webp": ["tex", "ui"],
                     "ogg": ["aud"], "wav": ["aud"], "ttf": ["fnt"], "otf": ["fnt"] },
}


func _run() -> void:
    var errores: Array[String] = []
    var aprobados: int = 0
    for archivo in _recorrer_assets():
        if not _cumple_nombre(archivo):
            errores.append("NOMBRE: %s" % archivo)
        elif not _extension_permitida(archivo):
            errores.append("FORMATO: %s" % archivo)
        if _es_textura(archivo) and not _cumple_png_webp(archivo):
            errores.append("TEXTURA: %s (solo PNG/WebP, potencias de 2)" % archivo)
        if _es_audio(archivo) and not _cumple_ogg_wav(archivo):
            errores.append("AUDIO: %s (solo OGG, WAV ≤ 5 s)" % archivo)
        if not _existe_ficha(archivo):
            errores.append("FICHA: %s (falta licencia/origen)" % archivo)
        if not _referencia_final_solo(archivo):
            errores.append("REF: %s (las escenas solo referencian assets/final)" % archivo)
        if _sin_errores(errores, archivo):
            aprobados += 1
    _escribir_reporte(errores, aprobados)
```

Comportamiento clave a implementar:
- La textura sin compresión VRAM (import en modo `Looped`/`RGB8` sin `VRAM Compressed`) se reporta como error con la ruta del `.import` a tocar.
- La ficha sin campo `Licencia:` o sin atribución falla contra la regla legal (M78).
- El reporte es markdown legible y con salida JSON sencilla para CI (M118).
- Corre en editor y headless (`godot --headless --script`), con `exit_code != 0` si hay errores.

## 2. Presets de importación (referencia, se materializan en `apply_import_presets.gd`)

| Tipo | Import settings obligatorios |
|---|---|
| Textura 3D | `CompressedTexture2D`, mipmaps on, VRAM Compressed, high_quality on, filter on, repeat off, fix_alpha_border on |
| Textura UI | `CompressedTexture2D`, mipmaps off (evita shimmer en UI), VRAM Compressed, filter off (pixel-perfect opcional en atlas) |
| Paleta voxel | `CompressedTexture2D`, mipmaps off, filter off, repeat off (anti-bleeding M08) |
| Mesh glb | `import_as=Mesh`, LODs auto ×3, shadow mesh on, vertex compression on, ensure tangents on (si normal maps), skip anims en props |
| Audio OGG | `AudioStreamOggVorbis`, calidad según preset, loop según ficha |
| Audio WAV (loop UI) | `AudioStreamWAV`, normalize on, trim on, loop forward con bounds |
| Fuente TTF | `FontFile`, MSDF on, antialiasing on, subsetting on, fallbacks definidos |

## 3. Logs relacionados del pipeline

- `Logs/NN-ASSET-<asset_id>-AAAA-MM-DD_HH-MM-SS.md` por entrada/aprobación/retiro (numeración según `Logs/ULTIMO_NUMERO.txt`).
- `assets/staging/_reporte_validacion.md` regenerado en cada corrida del validador.
- Trazabilidad de decisiones en este plan-actual (estado del módulo según CHECKLIST-GLOBAL).

## 4. Criterios de implementación para el agente delegado

1. Usar únicamente GDScript (M05) y API nativa de Godot 4.x (≥ 4.4.1 por Voxel Tools); sin plugins de terceros para el pipeline.
2. Verificar que el validador haga *exit code* distinto de cero ante errores y que CI (M118) pueda correrlo headless.
3. Probar el flujo completo con 20 assets de prueba (edge cases incluidos) antes de declarar el módulo `✅`.
4. Firma de DoD: código + testings (06/07 del plan-actual) + log + checklist actualizado.

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa, DELEGABLE PARA IMPLEMENTAR

### Lo que hice
- Creé la documentación completa del módulo 108 (5 archivos en plan-inicial y 5 en plan-actual, byte a byte idénticos): requerimientos (RF1-RF12 + RN), análisis de formatos por tipo para Godot 4.x (glTF/glb, PNG/WebP, OGG/WAV), convenciones de nombres, compresión por plataforma, import settings, batching/atlasing, alternativas y decisiones, diseño del pipeline (carpetas, flujo staging → validación → import → review → aprobación, herramientas de batch, plantilla de ficha y review) y el esqueleto del validador.
- Referencié las dependencias 45 (Arte 3D, sin documentar todavía) y 78 (Legal PI, documentada), y las integraciones 08, 47, 48, 61, 62, 63, 86, 107, 111, 112 y 118.
- Alineé el checklist (05) con las secciones del protocolo: problema/objetivos, RF (formatos, nombres, import, optimización, review), RN, análisis, diseño, integraciones, edge cases, optimización, documentación y testings.
- Mantuve el principio rector del proyecto: optimización obligatoria (AGENTS.md 21.4.8 / M152) como criterio de entrada del pipeline, no como parche posterior.

### Lo que NO pude hacer (honestidad obligatoria)
- No implementé ningún script: `asset_validator.gd`, `apply_import_presets.gd`, `promote_asset.gd`, `atlas_builder.gd`, `retire_asset.gd` y `asset_memory_reporter.gd` quedan pendientes (marcados como "Pendiente de implementación" en 04-Codigo.md) para el agente delegado.
- No pude contrastar los límites numéricos (tris por tipo, distancias de LOD, resoluciones máximas) con M61 porque el módulo 61 está en curso por GPT-5 y aún no tiene presupuestos finos publicados: los valores del documento son estimaciones razonables a calibrar.
- No verifiqué con un editor Godot real la lista exacta de flags de import (el documento usa la nomenclatura de Godot 4.x; el agente delegado debe validar contra el importador real).
- No toqué la fila del módulo 108 en CHECKLIST-GLOBAL.md (permanece `⬜ Sin iniciar`) ni modificué ningún archivo fuera de `DOCUMENTACION/108-Pipeline-De-Assets/`.

### Recomendaciones para el próximo agente
- Al implementar, confirmar las opciones exactas del importador Godot 4.x (nombres de flags de `import` para mipmaps, `VRAM Compressed`, LODs y vertex compression) contra la documentación oficial del motor y la versión instalada (≥ 4.4.1).
- Revisar los presupuestos de M61 una vez publicados y ajustar los límites de tris, distancias de LOD y resoluciones de textura en la guía y en el validador.
- Crear los primeros 20 assets de prueba con M45 (una vez documentado) o con proxies temporales para validar el flujo completo y los edge cases antes de declarar el módulo `✅`.
- Probar el validador en headless (`godot --headless --script`) y conectarlo a CI (M118) para que las fichas sin licencia rompan el build.
- Verificar que los assets licenciados tengan ficha con licencia SPDX y atribución (M78) antes de permitir `promote_asset`.
- Actualizar esta fila en CHECKLIST-GLOBAL.md y ESTADO-PARALELO.md cuando el módulo sea reclamado.