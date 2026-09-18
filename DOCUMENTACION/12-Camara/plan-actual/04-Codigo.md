**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 12: Cámara

## 1. Carácter del Componente

Módulo que **especifica el sistema de cámara** para implementarse en el prototipo del hito M1. No crea scripts todavía. Sin 06/07 por ahora (tests de cámara entran en el playtest de M1: colisión, modos, transiciones).

## 2. Archivos involucrados (implementación prevista)

```
scripts/camera/camera_mode.gd          → enum ModoCamara + máquina de modos
scripts/camera/camera_spring.gd        → spring-arm con colisión
scripts/camera/camera_fade.gd          → transiciones/fade centralizado
scripts/camera/camera_shake.gd         → shake gaussiano
scripts/camera/minimap_view.gd         → supervisor 2D (texturas M10)
data/camera/camera_settings.tres       → sensibilidad, distancias, fov
```

## 3. Contratos de integración

- **Entrada:** eventos `EventBus.ui.camera_mode` (cambios de modo), `EventBus.ui.shake_requested`.
- **Salida:** `camera_state` (posición, modo, fade) sincronizado con GameState.M12; input bloqueado internamente por modo.
- **Consume:** pivot del jugador M11, mapa de biomas M10 (minimapa), marcadores POI M71.
- **Publica:** `camera_mode_changed(mode)` (HUD lo consume para esconderse en Cutscene/Dialog).

## 4. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Calibración de sensibilidad/ángulos con sensación real | Playtest M1 |
| Encuadres de diálogo por escena (definir planos por NPC) | M21 (contenido) |
| Zooms de cutscene por evento | M22/M26 (contenido) |
| Texturas del minimapa por isla (generador) | M10 + M27 |

## 5. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 04:50:00
**Estado:** Completado (especificación; implementación en M1)

### Lo que hice
- Resolví los 20 puntos de la sección 11 del plan maestro.
- 5 modos de cámara con reglas de activación y enum en EventBus.ui.
- Spring-arm con colisión (raycast bloques, 0.8 m de separación, lerp 0.15 s).
- Minimapa con texto de generador (0 coste de render) y marcadores.
- Anti-mareo: FOV fijo 70°, sin motion blur, limitador de rotación, shake solo narrativo.
- Settings y persistencia en GameState.M12.

### Lo que NO pude hacer (honestidad obligatoria)
- Calibrar sensación real → playtest M1.
- Encuadres por NPC/diálogo → contenido M21.
- Cinemáticas con Timeline → post-v1.0 (4 expansiones).
- Texturas por isla → M10/M27.

### Recomendaciones para el próximo agente
- La cámara NUNCA atraviesa bloques (hash de colisión siempre).
- La dirección de cámara = dirección del personaje (reducir orbitas libres).
- Minimapa (M) y tercera persona, jamás FPS: mantener coherencia cozy.

## Notas del Agente (2026-08-29 — Hy3/Kilo): viewer y camara

- El VoxelViewer ahora SIGUE al jugador (main_island._process) — sin esto el borde del
  mundo se ve CUADRADO (10.1 de la guia Godot). La camara no cambio.


## Notas del Agente (2026-09-18 - atria-dawn / Kilo Code, QA cruzado, Log 955)

**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code
**Estado:** QA ejecutado - modulo bajado de OK a DUDAS (53 flips en 05-Checklist.md)

### Divergencia critica entre este documento y el codigo real

La seccion 2 de este archivo dice "implementacion prevista" y la seccion 1 dice "No crea scripts
todavia". Sin embargo el `05-Checklist.md` firme 102/102 items como cumplidos, muchos de ellos
afirmando comportamiento en runtime (modos, fade, shake, minimapa, zoom de 3 niveles). Esa es la
inconsistencia que el QA revirtio.

### Estado real de los 6 archivos previstos

| Archivo | Estado |
|---|---|
| `scripts/camera/camera_mode.gd` | EXISTE - enum ModoCamara, ZOOM_LEVELS, PITCH_ANGLES, helpers estaticos |
| `scripts/camera/camera_spring.gd` | EXISTE - cableado solo en main.tscn (escena muerta) |
| `scripts/camera/camera_fade.gd` | NO EXISTE - 0 menciones de fade_screen/transition_finished en el proyecto |
| `scripts/camera/camera_shake.gd` | NO EXISTE - trigger_shake se mergeo dentro de camera_rig.gd (linea 201) |
| `scripts/camera/minimap_view.gd` | NO EXISTE - MINIMAP es solo un valor del enum |
| `data/camera/camera_settings.tres` | NO EXISTE - la carpeta data/camera/ no existe; la config real vive en el autoload GameSettings |

### Archivo no previsto que es el nucleo real

`scripts/camera/camera_rig.gd` (267 lineas, class_name CameraRig) implementa los 5 modos, zoom por
niveles, shake y pivot - **pero jamas se instancia en la escena principal del juego**
(`run/main_scene = res://scenes/main_island.tscn`). Solo vive en `scenes/main.tscn` +
`scripts/main.gd`, que no es la escena principal y no tiene ninguna referencia entrante. Es codigo
muerto.

La camara que realmente corre el juego es `scripts/follow_camera.gd` (109 lineas), instanciada en
`main_island.tscn:70-73`. No tiene modos, ni niveles de zoom (continuo 4-20 m), ni shake, ni fade,
ni minimapa; su yaw es orbit libre del mouse (contradicen la recomendacion "direccion de camara =
direccion del personaje" de este mismo archivo). SI implementa colision por voxel raycast,
seguimiento suave, y consumo del autoload GameSettings (mouse_sensitivity, invert_y, persistido).

### Contratos de la seccion 3

`EventBus.ui.camera_mode`, `EventBus.ui.shake_requested`, `camera_mode_changed`, `camera_state` en
GameState.M12: **0 menciones en todo el codigo del proyecto**. Ningun consumidor existe. La
senal `mode_changed` que camera_rig.gd declara (linea 7) tampoco tiene conexiones.

### Bug registrado

- **BUG-044**: dos sistemas de camara paralelos; el documentado (camera_rig.gd) es codigo muerto.
  Requiere decision del usuario antes de cualquier cambio: integrar el rig en main_island.tscn, o
  reescribir la documentacion para describir follow_camera.gd.

### Recomendaciones para el proximo agente

1. No tocar follow_camera.gd hasta resolver BUG-044: es la unica camara que el juego usa.
2. La seccion 2 y 3 de este archivo deben reescribirse una vez resuelto BUG-044.
3. Si se integra camera_rig.gd: conectar `set_player_pivot`, cablear modos desde M17/M21/M22, e
   implementar fade y minimapa (ambos ausentes por completo).
4. `camera_spring.gd` y el raycast de follow_camera.gd duplican la misma responsabilidad
   (colision de camara contra terreno): unificar al integrar.
