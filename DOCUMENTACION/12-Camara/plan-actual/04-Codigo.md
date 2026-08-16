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