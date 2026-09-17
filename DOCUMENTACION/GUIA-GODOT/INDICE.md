# GUIA GODOT — ÍNDICE DE TEMAS

> **Modelo:** glm-5.3-flash
> **Plataforma:** Kilo Code
> **Fecha:** 2026-09-11
>
> Esta carpeta contiene la guía de Godot dividida en archivos temáticos.
> La guía original completa se conserva en `../OBSOLETOS/07-GUIA-GODOT.md`
> como respaldo histórico.

---

## Archivos temáticos

### Fundamentales (01-12)

| # | Archivo | Contenido | Estado |
|---|---|---|---|
| 01 | [`01-gdscript-errores-comunes.md`](01-gdscript-errores-comunes.md) | Errores comunes de GDScript: signals, static func, type inference, Variant, lambdas | ✅ |
| 02 | [`02-voxel-tools.md`](02-voxel-tools.md) | Voxel Tools: propiedades, VoxelViewer, VoxelBlockyLibrary, VoxelTool, terrain layers | ✅ |
| 03 | [`03-escenas-tscn.md`](03-escenas-tscn.md) | Escenas .tscn: RayCast3D, load_steps, UIDs, reutilización de recursos | ✅ |
| 04 | [`04-arquitectura-proyecto.md`](04-arquitectura-proyecto.md) | Estructura de carpetas, naming conventions, class_name, errores Godot 4.x | ✅ |
| 05 | [`05-checklist-referencias.md`](05-checklist-referencias.md) | Checklist al escribir código + referencias rápidas (Godot, Voxel, Jolt) | ✅ |
| 06 | [`06-registro-errores.md`](06-registro-errores.md) | Registro de errores E-11 a E-19 con síntoma, causa, solución y firma | ✅ |
| 07 | [`07-camera-input.md`](07-camera-input.md) | Cámara, input y movimiento: look_at colineal, right vector, tank controls | ✅ |
| 08 | [`08-terreno-voxel.md`](08-terreno-voxel.md) | Terreno voxel: receta por capas, agua clara/profunda, TerrainLocator, paleta | ✅ |
| 09 | [`09-godot4-migracion.md`](09-godot4-migracion.md) | Godot 4.x: Variant, type inference, add_child busy, class_name colisiones | ✅ |
| 10 | [`10-ui-hud.md`](10-ui-hud.md) | UI/HUD: CanvasLayer, show() override, widget verification, font loading | ✅ |
| 11 | [`11-blender-godot.md`](11-blender-godot.md) | Blender → Godot: animaciones, BoneAttachment3D, naming, optimización | ✅ |
| 12 | [`12-animales-bimodo.md`](12-animales-bimodo.md) | Animales bimodo: estado dual, Quaternion piernas, ground snapping | ✅ |

### Avanzados / Específicos del juego (16-19)

| # | Archivo | Contenido | Estado |
|---|---|---|---|
| 16 | [`16-zoom-camara-personaje.md`](16-zoom-camara-personaje.md) | Zoom de cámara correcto: scroll, minimapa, cámara tercera persona | ✅ |
| 17 | [`17-disco-plano-verde.md`](17-disco-plano-verde.md) | Disco plano sólido con SurfaceTool (el "plato verde" sobre el agua) | ✅ |
| 18 | [`18-impostores-terreno.md`](18-impostores-terreno.md) | Impostores del terreno: heightmap completo + anti-tildes + anti-caída + horizonte | ✅ |
| 19 | [`19-diagnostico-tildes.md`](19-diagnostico-tildes.md) | Diagnóstico y solución de tildes (freeze): protocolo paso a paso, causas C-01 a C-11, checklist | ✅ |

---

## Reglas de esta carpeta

1. Cada archivo es **autocontenido**: explica el tema de punta a punta con
   código de ejemplo probado.
2. Todo código de ejemplo **debe estar validado en juego** — no teoría.
3. Cada archivo registra **los errores cometidos** y cómo evitarlos (la parte
   más valiosa de la guía).
4. La guía original completa se conserva en `../OBSOLETOS/07-GUIA-GODOT.md`
   como respaldo histórico con las lecciones E-01 a E-19.
5. Cuando un tema de la guía original se migre acá, se actualiza esta
   referencia (el archivo original se mueve a OBSOLETOS/).

---

## Mapeo de secciones de la guía original → archivos

| Sección original | Archivo(s) en GUIA-GODOT/ |
|---|---|
| §1 — GDScript errores comunes | `01-gdscript-errores-comunes.md` |
| §2 — Voxel Tools errores comunes | `02-voxel-tools.md` |
| §3 — Escenas (.tscn) errores comunes | `03-escenas-tscn.md` |
| §4 — Arquitectura del proyecto | `04-arquitectura-proyecto.md` |
| §5 — Errores de Godot 4.x | `04-arquitectura-proyecto.md` |
| §6 — Checklist al escribir código | `05-checklist-referencias.md` |
| §7 — Referencias rápidas | `05-checklist-referencias.md` |
| §8 — Registro de errores (E-11 a E-19) | `06-registro-errores.md` |
| §9.1 — Vector up colineal | `07-camera-input.md` |
| §9.2 — VoxelTerrain materials | `02-voxel-tools.md` |
| §9.3 — Funciones estáticas | `01-gdscript-errores-comunes.md` |
| §9.4 — Signals snake_case | `01-gdscript-errores-comunes.md` |
| §9.5 — Input Godot 4 | `07-camera-input.md` |
| §9.6 — RayCast3D Vector3 | `03-escenas-tscn.md` |
| §9.7 — VoxelBlockyModelCube | `02-voxel-tools.md` |
| §9.8 — Variant inference | `01-gdscript-errores-comunes.md` |
| §9.9 — VoxelTerrain hijo directo | `02-voxel-tools.md` |
| §9.10 — Camera3D transform | `02-voxel-tools.md` |
| §9.11-9.15 — Migración Godot 4 | `09-godot4-migracion.md` |
| §9.16 — CameraMode | `07-camera-input.md` |
| §9.17 — class_name autoload | `09-godot4-migracion.md` |
| §9.18 — Node.get() override | `09-godot4-migracion.md` |
| §9.19 — type reservada | `09-godot4-migracion.md` |
| §9.20 — change_scene busy | `09-godot4-migracion.md` |
| §9.21 — Resource._ready() | `02-voxel-tools.md` |
| §9.22 — _generate_block firma | `02-voxel-tools.md` |
| §9.23 — Camera forward | `07-camera-input.md` |
| §9.24 — Variant null | `01-gdscript-errores-comunes.md` |
| §9.25 — Camera + edición | `07-camera-input.md` |
| §9.26 — CanvasLayer show() | `10-ui-hud.md` |
| §9.27 — UI element | `10-ui-hud.md` |
| §9.28 — Migración | `09-godot4-migracion.md` |
| §9.29 — Camera input conflict | `07-camera-input.md` |
| §9.30 — Movimiento relativo | `07-camera-input.md` |
| §9.31 — VoxelBoxMover | `02-voxel-tools.md` |
| §9.32 — Right vector | `07-camera-input.md` |
| §9.33 — show() CanvasLayer | `10-ui-hud.md` |
| §9.34 — (inherited) | — |
| §9.35 — VoxelTool Variant | `02-voxel-tools.md` |
| §9.36 — add_child busy | `09-godot4-migracion.md` |
| §9.37 — Camera smoothing | `07-camera-input.md` |
| §9.38 — Variant pop_front | `01-gdscript-errores-comunes.md` |
| §9.39 — CanvasLayer show() | `10-ui-hud.md` |
| §9.40 — VoxelTerrain.get_voxel | `02-voxel-tools.md` |
| §9.41 — class_name nativo | `09-godot4-migracion.md` |
| §9.42 — String.compress | `09-godot4-migracion.md` |
| §9.43 — Variant override | `01-gdscript-errores-comunes.md` |
| §9.44 — VoxelTool raycast chunks | `02-voxel-tools.md` |
| §9.45 — Offset NPC | `08-terreno-voxel.md` |
| §9.46 — Tooltip duplicado | `10-ui-hud.md` |
| §9.47 — Verificar widget | `10-ui-hud.md` |
| §9.48 — FontFile loading | `10-ui-hud.md` |
| §9.49 — Object.has() | `10-ui-hud.md` |
| §9.50 — class_name headless | `09-godot4-migracion.md` |
| §9.51 — Autoload --script | `10-ui-hud.md` |
| §9.52 — class_name + const | `09-godot4-migracion.md` |
| §9.54 — Resource.new() args | `09-godot4-migracion.md` |
| §9.55 — Resource.hidden | `09-godot4-migracion.md` |
| §9.56 — Lambda capture | `01-gdscript-errores-comunes.md` |
| §9.57 — Inner class scope | `09-godot4-migracion.md` |
| §9.58 — ResourceLoader headless | `09-godot4-migracion.md` |
| §9.60 — Mix tabs/spaces | `09-godot4-migracion.md` |
| §9.61 — Curve.add_point dominio | `09-godot4-migracion.md` |
| §9.62 — print() format | `01-gdscript-errores-comunes.md` |
| §9.63 — full_load_distance | `02-voxel-tools.md` |
| §10 — Mundo voxel completo | `08-terreno-voxel.md` |
| §11 — Blender → Godot | `11-blender-godot.md` |
| §12 — Animales bimodo | `12-animales-bimodo.md` |
| §13 — Horizonte/Impostores | `18-impostores-terreno.md` |
