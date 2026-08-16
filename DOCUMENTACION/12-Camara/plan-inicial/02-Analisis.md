**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 12: Cámara

## 1. Análisis de los puntos del plan maestro (sección 11)

| # | Punto | Resolución |
|---|---|---|
| 1 | Cámara 3ª persona | ✅ Sí: tras el hombro derecho, fija (sin orbit libre) |
| 2 | Seguimiento del jugador | ✅ Spring-arm sobre el pivot de M11 (posición + suavizado 0.15 s) |
| 3 | Ángulos | ✅ Yaw = dirección del jugador; Pitch fija 30° (ligera variación al subir/bajar ±10°) |
| 4 | Distancia | ✅ 5 m estándar; zoom 2.5 / 5 / 8 m |
| 5 | Colisión | ✅ Raycast de la cámara al pivot; colisión con bloques → acercar a 0.8 m del muro (nunca dentro del bloque) |
| 6 | Interpolación | ✅ Lerp angular 10°/s y posicional 0.15 s (sin rebote) |
| 7 | Zoom | ✅ Rueda del mouse / atajos teclado (3 niveles + settings) |
| 8 | Cámara de construcción | ✅ Modo Construcción: cámara aérea 45°, distancia 12 m, sin zoom < 4 m; desbloquea al equipar modo (M17) |
| 9 | Cámara de diálogo | ✅ Encuadre de escena (Over-the-shoulder 2 jugadores / plano medio a NPC); sin control libre |
| 10 | Cutscenes | ✅ Mecánica de eventos/diálogos (M22/M26) usan planos fijos con fade — sin cinemáticas complejas |
| 11 | Minimapa | ✅ Supervisor 2D top-down 128×128 (no renderiza el mundo: usa texturas de chunk del generador M10) |
| 12 | Shake | ✅ Screenshake gaussiano (amplitud ≤ 0.15 m, frecuencia 8 Hz, ≤ 0.5 s) SOLO eventos narrativos |
| 13 | FOV | ✅ 70° estándar; sin fov dinámico (anti-mareo) |
| 14 | Sensibilidad | ✅ Settings: 1-10 (base 5) |
| 15 | Cámara lenta | ✅ Sin slow-mo de cámara (solo feedbacks de UI) |
| 16 | Viveza | ✅ Sin motion blur; antialiasing MSAA 4x; sin DOF (voxel) |
| 17 | Transiciones escena | ✅ Fade negro 0.3 s + lerp 0.2 s; nunca teleport visual |
| 18 | Cámara puerta/mazmorra? | ✅ Interior: distancia baja 2.2 m automática (paredes cercanas por arriba) |
| 19 | Cámara montaje | ✅ Solo para puntos de interés (bandera de descubrimiento, M71): zoom-out 0.8 s en punto de vista |
| 20 | Backend | ✅ ModoCamara enum (Explore, Build, Dialog, Cutscene, Minimap) en EventBus.ui.camera_mode |

## 2. Alternativas descartadas

- **Orbit libre (ratón gira 360°):** descartado — mareo y menos coherencia; la dirección de la cámara = dirección del personaje.
- **Primera persona:** descartado (coherencia cozy, ver M11).
- **Cinemáticas complejas (Timeline):** descartado en v1.0 — fade + planos fijos para eventos; las cinemáticas lleguen con las 4 expansiones (roadmap).
- **Minimapa renderizado (MiniatureCamera):** descartado — texturas del generador (M10) bastan: 0 coste de render.
- **DOF/motion blur:** descartados por presupuesto y anti-mareo.