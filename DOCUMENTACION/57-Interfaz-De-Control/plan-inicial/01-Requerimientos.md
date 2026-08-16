**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 57: Interfaz de Control

## ID del Módulo
- **Código:** M57 (plan maestro: sección 56 — Interfaz de Control)
- **Carpeta:** `DOCUMENTACION/57-Interfaz-De-Control/`
- **Dependencias:** M04 (Game Engine/Input de Godot), M34 (movimiento), M45/M46 (UI). Relaciones: M58 (accesibilidad), M91 (config de audio/opciones)
- **Delegable desde:** hoy (diseño completo; implementación sobre el Input System de Godot 4)

## 1. Problema

Unificar TODOS los esquemas de control del juego (teclado+ratón, gamepad Xbox/PlayStation/genérico, Steam Deck, táctil si aplica) bajo una sola capa de acciones remapeables, con ayudas dinámicas de botones, dead zones, vibración y persistencia de configuración.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Dispositivos | Teclado, ratón, gamepad Xbox/PlayStation/genérico (Godot joypad) |
| RF2 | Capa de acciones | Toda acción de juego se maneja por nombre (`mover`, `saltar`, `interactuar`...) — nunca por scancode directo |
| RF3 | Remapeo | Botones y teclas remapeables desde el menú de opciones (M45/M46) |
| RF4 | Ajustes analógicos | Sensibilidad de cámara, dead zones y vibración configurables |
| RF5 | Atajos | Atajos de inventario/barra rápida por defecto y configurable |
| RF6 | Navegación UI | Navegación completa de menús con teclado y con mando (focus system) |
| RF7 | Ayudas dinámicas | Prompts de botones cambian según el dispositivo activo (X → A, ⬆ → W) |
| RF8 | Persistencia | Guardar y recuperar la configuración (JSON en user://) |
| RF9 | Plataformas | Steam Deck (mando + rendimiento) y táctil "si corresponde" (diseño de decisión) |

## 3. Requisitos No Funcionales

- **Cozy:** controles simples de aprender; latencia de entrada < 16 ms (1 frame); sin conflicto entre acciones.
- **Rendimiento:** lectura de input solo en `_unhandled_input`/`_physics_process`; sin polling en `_process` innecesario (M61).
- **Accesibilidad (M58):** remapeo completo, inversión de ejes, sensibilidad por eje, opción "vibración" para deshabilitar.
- Persistencia con GameClock/M29 intacta (el guardado no pausa el juego).
- Detección de dispositivo: al conectar/desconectar mandos, los prompts se actualizan al instante.

## 4. Criterios de Aceptación

1. Los 22 puntos de la sección 56 resueltos.
2. Capa de acciones y remapeo completo con persistencia definidos.
3. Prompts dinámicos por dispositivo con detección automática.
4. Dead zones/sensibilidad/inversión/vibración especificados.
5. Delegable para implementación.