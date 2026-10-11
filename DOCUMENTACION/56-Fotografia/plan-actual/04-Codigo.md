**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 56: Fotografía

## 1. Archivos Involucrados

| Archivo | Ruta | Rol |
|---|---|---|
| `photo_presets.tres` | `Assets/_Project/Photography/data/` | 6-8 presets (ColorGrade, DOF, EV, contraste, viñeta) |
| `photo_shot.gd` | `Assets/_Project/Photography/data/` | Modelo: ruta, metadatos, miniatura, timestamp |
| `photo_mode.gd` | `Assets/_Project/Photography/service/` | Autoload PhotoMode: Fotostate, congelado de mundo (M31), atajos (M57) |
| `photo_camera.gd` | `Assets/_Project/Photography/service/` | Navigator: cámara réplica, zoom 0.5x-8x, rotación orbital |
| `photo_capture.gd` | `Assets/_Project/Photography/service/` | Captura dedicada 1920×1080, WebP, XMP, índice JSON (M60) |
| `photo_album.gd` | `Assets/_Project/Photography/service/` | Álbum: listar, borrar, presupuesto 150 MB, miniaturas |
| `photo_hud.gd` | `Assets/_Project/Photography/ui/` | Menú del modo foto (M53): filtros, ajustes, botón captura |
| `photo_album_view.gd` | `Assets/_Project/Photography/ui/` | Galería del álbum + integración al diario (M55) |
| `validate_photo.gd` | `Assets/_Project/Photography/validators/` | Validador: modo foto, ajustes, guardado, rendimiento |

## 2. Funciones Clave y Logs Relacionados

### 2.1 `photo_mode.gd` (Fotostate)
```gdscript
func enter() -> void:
    _saved_camera = Global.camera.get_transform()  # restaurar al salir
    _saved_hud_visible = Global.hud.visible
    NewsState.enter_photo()  # M31: fijar hora/clima, congelar física/animación
    Navigator.enable(); PhotoHud.show()
    EventBus.emit(EventBus.PHOTO_POSE_REQUEST)
    LOGS.photo("PHOTO-ENTER", {})

func exit() -> void:
    NewsState.exit_photo()   # restaurar mundo y hora (M31)
    Global.camera.set_transform(_saved_camera)  # vuelve la cámara exacta
    Global.hud.visible = _saved_hud_visible
    Navigator.disable(); PhotoHud.hide()
    LOGS.photo("PHOTO-EXIT", {})
```
**Logs:** `PHOTO-ENTER` (entrada al modo foto), `PHOTO-EXIT` (salida), `PHOTO-SHOT` (captura guardada), `PHOTO-SHARE` (compartición local), `PHOTO-WARN` (presupuesto de álbum cerca del límite).

### 2.2 `photo_camera.gd` (Navigator)
```gdscript
func _process(delta: float) -> void:
    # Traslación libre con colisión suave (raycast hacia el objetivo)
    var vel := _input_move() * MOVE_SPEED * delta
    _pos += vel; _pos = _clamp_to_world(_pos)
    # Órbita con límites de inclinación y zoom por FOV (M49)
    _yaw += _input_yaw(); _pitch = clamp(_pitch + _input_pitch(), -60.0, 60.0)
    _fov = clamp(_fov / _zoom, MIN_ZOOM_FOV, MAX_ZOOM_FOV)
    _apply()

func _apply() -> void:
    # Réplica: se mueve la cámara real (un solo render)
    Global.camera.global_position = _pos
    Global.camera.global_rotation = Vector3(_pitch, _yaw, 0)
    Global.camera.fov = _fov
```

### 2.3 `photo_capture.gd` (captura y guardado)
```gdscript
func capture() -> void:
    await get_tree().create_timer(0.8).timeout  # espera la pose (M48)
    var image := _render_dedicated(Vector2i(1920, 1080))  # no pantalla
    _apply_preset(image, PhotoHud.current_preset)  # ColorGrade/DOF/EV/viñeta
    var path := _write_webp(image, _shot_metadata())  # XMP: hora M31, preset, lugar M54
    PhotoAlbum.add(path, _make_thumbnail(image))
    LOGS.photo("PHOTO-SHOT", {"path": path, "preset": PhotoHud.current_preset})

## 3. Contratos de Integración (Eventos del EventBus M07)

| Evento | Emisor | → Fotografía |
|---|---|---|
| `PHOTO_POSE_REQUEST` | PhotoMode | NPC (M19) y animales (M36) posan 0.5 s |
| `PHOTO_TAKEN` | photo_capture | Diario (M55) registra la foto; logros (M72) de coleccionista |
| `FOTO_ASOCIADA` | photo_album | Diario (M55) vincula la fotografía a su entrada |

## 4. Logs Relacionados (Sistema de Logs del Proyecto)

El módulo usa el sistema central de logs de consola (M118): prefijo `[PHOTO]` en desarrollo y canal depurado en builds (sección 18 de AGENTS.md); rotación automática fuera de `Assets/`.

## 5. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Parcial (con dudas)

### Lo que hice
- Documenté el módulo 56 completo (diseño técnico de Godot 4): Fotostate con congelado de mundo (M31), cámara réplica (Navigator) con zoom y órbita, presets artísticos, captura dedicada a resolución fija, álbum persistente con presupuesto de disco, compartición local con confirmación de privacidad y validación.

### Lo que NO pude hacer (honestidad obligatoria)
- `[?]` Verificar en runtime: no hay editor Godot ni build en este entorno; los `.gd` de esta documentación son prototipos de diseño que se escribirán en la fase de implementación.
- `[?]` Validar el rendimiento real de la captura dedicada (el proyecto aún no define el pipeline de render para capturas; el presupuesto de < 50 ms se validará en implementación con M61/M116).

### Intentos fallidos / decisiones
- Decidí la cámara "réplica de Navigator" (mover la cámara real) en lugar de una cámara duplicada con render extra: evita duplicar costo de render (M61).
- Decidí la captura dedicada a 1920×1080 en lugar de screencapture de pantalla: consistente entre monitores y resoluciones.
- Decidí poses por evento (PHOTO_POSE_REQUEST) con retardo de 0.8 s: la animación de pose (M48) tarda ~0.5 s en asentarse.

### Recomendaciones para el próximo agente
- Al implementar: revisar el contrato de eventos del EventBus (M07) y el render pipeline para capturas (M116).
- Testear a fondo: entrada/salida con cámara en movimiento (que no haya "teleport" raro), poses de animales con IA activa (M36), DOF en plataformas de baja gama (M90).
- Revisar el presupuesto del álbum (150 MB) con fotos 4K futuras (salida de fotos de pantalla completa).

---

## 6. Notas del Agente — iter. 3 (foto del jugador, encargo msg 88)

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-09 22:15
**Estado:** Completado

### Lo que hice (código real, a diferencia de los prototipos §2.x)
- **`scripts/foto/photo_service.gd`** (autoload PhotoService, ya existente desde iter. 1/2) —
  se EXTENDIÓ, no se creó archivo nuevo:
  - `signal foto_tomada(ruta: String, resultado: Dictionary)` — emisor real de PHOTO_TAKEN
    (antes solo figuraba en la tabla §3; ahora existe). Suscriptores pendientes: M55/M72.
  - `const CARPETA_FOTOS := "user://fotos/"` — el encargo del director pidió PNG en
    `user://fotos/` (§2.3 proponía WebP en `user://photos/` — decisión del director, queda
    pendiente de unificación con L104).
  - `var _en_captura: bool` — guard anti-doble captura.
  - `func _unhandled_input(event)` — consume la acción `tomar_foto` (P) sin pisar UI.
  - `func tomar_foto() -> Dictionary` (async): oculta HUD vía `UIManager.set_hud_visible(false)`
    → `await process_frame` ×2 (lag de 1 frame de `get_texture()`) → `get_viewport()
    .get_texture().get_image().save_png(ruta_abs)` → restaura HUD exacto → emite
    `foto_tomada`. En `--headless` `get_image()` devuelve null → `ok=false`,
    `motivo="sin_textura_render"` (sin archivo falso).
  - `func _ruta_foto_unica() -> String` — timestamp + sufijo `_N` + fallback ticks (1970/vacío).
  - `_entrar_modo_foto()`/`_salir_modo_foto()` — ahora ocultan/restauran el HUD
    (`_hud_visible_antes_modo`), cerrando "Restaurar HUD al salir del modo foto".
- **`project.godot`**: acción `tomar_foto` (tecla P, `physical_keycode:80` verificada libre).
- **`tests/test_m56_tomar_foto.gd`** (nuevo, SceneTree): T1 flujo directo, T2 input real P
  (pipeline + fallback directo), T3 doble pulsación (guard). Adaptativa al renderer.

### Hallazgos técnicos (lecciones nuevas para la guía 06)
- Godot 4.7: llamar corutina externa sin `await` → `SCRIPT ERROR: Trying to call an async
  function without await` que aborta al caller (incluso con asignación). El auto-call
  interno descartado dentro de `_unhandled_input` NO falla. Tests: usar dispatch por
  `_unhandled_input`, no llamada directa a `tomar_foto()`.
- Headless: `get_texture().get_image()` → NULL (dummy renderer; `ERROR: Parameter "t" is
  null` 2 veces, inofensivo). El PNG solo existe con render.

### Lo que NO hice
- `photo_capture.gd` del §2.3 NO se implementó: la captura real vive en `photo_service.gd`
  (menos archivos, un solo administrador). Resolución fija 1920×1080 (L96), filtros en frame
  (L98), pose 0.8 s (L99), WebP+XMP (L104) siguen pendientes con dueño M49/M57.
- K92 (< 50 ms): medido 100-219 ms con render (captura+IO) — queda [ ] honesto.

### Recomendaciones para el próximo agente
- Suscribir `foto_tomada` desde M55 (diario) y M72 (logros de coleccionista).
- Si se unifica a WebP/XMP o `user://photos/`, migrar `CARPETA_FOTOS` + renombrar los PNG
  existentes de `user://fotos/`.
- Optimizar K92: candidatos = guardar vía `save_png_to_buffer` + write async, o capturar a
  escala menor y reescalar.