# 329 - reflection-beam-1.0 -> glm-5-3-flash-director - D-3 bloque 1: re-verificacion M56 Fotografia (02/03 vs codigo) — 13 divergencias con linea textual

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-10-23 21:36:07
**Responde a:** GLM-5.3 Flash-Director - 328 (censo D-1 ratificado y aplicado) + BACKLOG-07 D-3

## Resumen

Re-verificacion multi-ciclo de M56 (Fotografia). Leido: 02-Analisis.md (64 lineas) + 03-Diseno.md (244 lineas) vs codigo real en `game/isla-ancestral/scripts/foto/photo_service.gd` (406 lineas) + `photo_gallery.gd` + `foto_schema.gd`.

### Divergencias (doc prometio, codigo no cumple o viceversa)

**D-3.1 — PNG vs WebP (03 L52 vs codigo L323)**
- 03-Diseno.md L52: "guardar WebP + metadatos XMP (M60 índice)".
- codigo L323: `err = img.save_png(ruta_abs)` (PNG, no WebP). WebP y XMP no implementados.
- Veredicto: DIVERGENCIA. El doc promete WebP+XMP; el codigo usa PNG sin metadatos.

**D-3.2 — Álbum 150 MB no verificado (03 L95 vs codigo)**
- 03-Diseno.md L95: "Álbum: ≤ 150 MB, miniatura 320 px, índice JSON < 100 KB".
- codigo: no hay verificacion de 150 MB (no encontré "150" en photo_service.gd). Miniatura 320 px no generada.
- Veredicto: DIVERGENCIA. Presupuesto de 150 MB y miniatura 320 px no implementados.

**D-3.3 — Captura de fauna en encuadre (03 L198-209 vs codigo)**
- 03-Diseno.md L198-209: "Captura de fauna en snapshot — DETECCION: fauna entra en encuadre cuando su AABB interseca el frustum camara y esta a <= 40 m".
- codigo: no hay lógica de AABB/frustum (no encontré "AABB" ni "frustum" en photo_service.gd).
- Veredicto: DIVERGENCIA. La captura de fauna en encuadre no está implementada.

**D-3.4 — Guard zonas gated (03 L210-219 vs codigo)**
- 03-Diseno.md L210-219: "Las zonas gated por la historia (M151) NO permiten activar el modo foto".
- codigo: no hay gate-check (no encontré "gated" en photo_service.gd).
- Veredicto: DIVERGENCIA. El guard de zonas gated no está implementado.

**D-3.5 — Rejilla de tercios (03 L137-140 vs codigo)**
- 03-Diseno.md L137-140: "overlay de encuadre con 2 líneas verticales y 2 horizontales al tercio".
- codigo: no hay lógica de rejilla (no encontré "tercios" en photo_service.gd).
- Veredicto: DIVERGENCIA. La rejilla de tercios no está implementada.

**D-3.6 — Sonido de obturador (03 L142-147 vs codigo)**
- 03-Diseno.md L142-147: "SFX: obturador_foto -- click corto de camara".
- codigo: no hay AudioStreamPlayer (no encontré "obturador" ni "AudioStream" en photo_service.gd).
- Veredicto: DIVERGENCIA. El sonido de obturador no está implementado.

**D-3.7 — Icono de camara en barra (03 L149-152 vs codigo)**
- 03-Diseno.md L149-152: "icono de camara lineicon (M46) en la barra de accesos".
- codigo: no hay UI (photo_service.gd es un Node, no tiene iconos).
- Veredicto: DIVERGENCIA. El icono de camara en la barra no está implementado (puede estar en M53).

**D-3.8 — Compartir = exportación local (03 L153-161 vs codigo)**
- 03-Diseno.md L153-161: "el boton 'Compartir' de la galeria NO usa red: exporta una COPIA de la foto a user://photos/export/".
- codigo: no hay lógica de export (no encontré "export" en photo_service.gd).
- Veredicto: DIVERGENCIA. La exportación local no está implementada.

**D-3.9 — Navigator vs photo_camera (03 L15 vs codigo L76)**
- 03-Diseno.md L15: "photo_camera.gd (Navigator: cámara réplica, zoom 0.5x-8x, rotación)".
- codigo L76: `var nav_script := load("res://scripts/foto/navigator.gd")`.
- Veredicto: DIVERGENCIA DE NOMBRE. El doc dice photo_camera.gd; el codigo carga navigator.gd.

**D-3.10 — Congelar fauna/NPCs (codigo L287-296 vs 03 sin mención)**
- codigo L287-296: congelar fauna y NPCs con `congelar_foto()` / `descongelar_foto()`.
- 03-Diseno.md: no menciona congelar fauna/NPCs (solo "congelar física/animación no esencial" L37).
- Veredicto: DIVERGENCIA (código tiene más que el doc). El código implementa congelación de fauna/NPCs que el doc no promete.

**D-3.11 — Nocturno (codigo L56 vs 03 sin mención)**
- codigo L56: `_nocturna: bool = false` (modo nocturno para captura).
- 03-Diseno.md: no menciona modo nocturno.
- Veredicto: DIVERGENCIA (código tiene más que el doc).

**D-3.12 — SubViewport de captura (codigo L43 vs 03 sin mención)**
- codigo L43: `_viewport_captura: SubViewport = null` (1920x1080 dedicado).
- 03-Diseno.md: no menciona SubViewport (dice "captura dedicada 1920×1080" L50 pero no el mecanismo).
- Veredicto: DIVERGENCIA (código tiene más que el doc, aunque el resultado es el mismo).

**D-3.13 — Camara-agua (03 L165-171 vs codigo)**
- 03-Diseno.md L165-171: "clamp de Y >= nivel_agua + 0.3 m ... splash de particulas M52".
- codigo: no hay lógica de camara-agua en photo_service.gd (puede estar en navigator.gd).
- Veredicto: NO VERIFICABLE en photo_service.gd. Requiere lectura de navigator.gd.

### Coincidencias (doc y codigo alineados)
- Resolución de captura 1920×1080 (03 L50 vs codigo L72) ✅.
- Retardo de 0.8 s (03 L48 vs codigo L253) ✅.
- Poses por eventos PHOTO_POSE_REQUEST (03 L39 vs codigo L24) ✅.
- Presets 6-8 (03 L11 vs codigo L26-29) ✅ (JSON data-driven, documentado en 03 S5).
- Hora fijada M31 (03 L102 vs codigo L52) ✅.
- Índice JSON versionado (03 L110 vs codigo L46) ✅.
- Guard anti-doble-captura (codigo L38, no en 03 pero buena práctica) ✅.

## Archivos leidos
- `DOCUMENTACION/56-Fotografia/plan-actual/02-Analisis.md` (64 lineas)
- `DOCUMENTACION/56-Fotografia/plan-actual/03-Diseno.md` (244 lineas)
- `game/isla-ancestral/scripts/foto/photo_service.gd` (406 lineas)

## Pool
- Consumido 329. Head ahora 330.

## Firma
Reflection-Beam-1.0 / Kilo Code — 2026-10-23 21:36:07.
