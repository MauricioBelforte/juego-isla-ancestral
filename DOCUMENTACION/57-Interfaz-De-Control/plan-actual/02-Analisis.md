**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 57: Interfaz de Control

## 1. Resolución de los 22 puntos del plan maestro

| # | Punto | Resolución |
|---|---|---|
| 1 | Soporte teclado | Mapeo completo QWERTY + pilares: WASD mover, Espacio saltar, E interactuar, I inventario (atajos M57-RF5) |
| 2 | Soporte ratón | Cámara por ratón (sensibilidad configurable), clique acciones, hover en UI (M46), click derecho cancelar |
| 3 | Soporte gamepad | Capa Godot Joypad: palanca izq mover, palanca der cámara, A saltar, B cancelar, X interactuar, Y inventario |
| 4 | Mando Xbox | Iconografía de botones Xbox (A/B/X/Y) con texturas propias; joystick con dead zone circular estándar |
| 5 | Mando PlayStation | Iconografía PS (✕/○/□/△) y nombres alternativos en remapeo; detección por vendor del pad |
| 6 | Mando genérico | Mapeo universal de gamepad (Godot `joypad`): ejes y botones normalizados; soporte de layouts DusBot genéricos |
| 7 | Remapeo de botones | Menú de remapeo (M46): cada acción es assignable; captura la primera tecla/botón no asignada; spinner para selección |
| 8 | Sensibilidad | Sensibilidad de cámara por eje (ratón X/Y y palanca); slider 0.1-3.0 (default 1.0) con inversión por eje |
| 9 | Vibración | `Input.start_joy_vibration(id, mag_i, mag_f, duración)`: eventos clave (daño leve, pesca, logros); intensidad configurable + OFF |
| 10 | Dead zones | Palanca izq 0.15, palanca der 0.20 (radial); gatillos lineales en zona muerta 0.10; configurables |
| 11 | Inversión | Inversión de eje Y cámara (ratón y palanca) e inversión opcional del eje X; persistida en configuración |
| 12 | Atajos | Atajos por defecto: barra rápida 1-9, inventario I, diario J, mapa M, minimapa Tab, pausa Esc/Start, screenshot F12 |
| 13 | Atajos configurables | Cada atajo editable en el menú de remapeo; conflictos detectados y bloqueados (aviso + sugerencia de tecla libre) |
| 14 | Navegación con teclado | Focus system de Godot: Tab/Shift+Tab cicla, Enter confirma, Esc cancela — en TODOS los menús |
| 15 | Navegación con mando | D-pad/palanca mueven el foco, A confirma, B cancela; `gui_focus_neighbor` configurado en cada pantalla |
| 16 | Indicadores dinámicos | Detección automática del dispositivo activo de entrada; los prompts de la UI siempre coinciden con el dispositivo |
| 17 | Prompt dinámico de botones | Mapa icono→acción por dispositivo (Xbox/PS/genérico/teclado): texturas intercambiables en runtime, sin recargar UI |
| 18 | Mouse hover | Hover sobre elementos con `mouse_entered/exited`: resaltado, tooltip con atajo mostrado (M46) |
| 19 | Soporte táctil si corresponde | DECISIÓN: NO en PC/Deck (criterio playful: cozy no se optimiza para táctil); si hay build móvil futura → capa de botones táctiles reutilizando acciones (M57-RF2) |
| 20 | Soporte Steam Deck si corresponde | Soporte nativo de mando Deck (SDL reconocido como gamepad); perfiles Godot `input_map` para Deck; sin overlays táctiles en PC |
| 21 | Guardar configuración | JSON en `user://settings/controls.cfg` con checksum ligero; escritura atomica (tmp + rename); backup previo |
| 22 | Recuperar configuración | Carga al boot: si falta/corrompe → defaults + aviso discreto; restauración "reset to defaults" en menú |

## 2. Decisiones clave

1. **Capa de acciones única** (action map nombrado, nunca scancodes): mobile/remapeo/prompts compartirán la misma fuente de verdad — requisito para remapeo y prompts dinámicos.
2. **Detección de dispositivo por evento reciente**: la UI escucha `input_event` y el último dispositivo usado define los prompts — instantáneo al cambiar de teclado a mando.
3. **Persistencia con escritura atómica**: evita corrupción de controles a mitad de guardado; el resto del guardado (M29) queda intacto.
4. **Táctil NO en esta fase**: se diseña la capa (reutiliza acciones) pero no se implementa (build objetivo es PC/Deck).
5. **Vibración cónsona al cozy**: eventos suaves y cortos; con OFF accesible — nuca vibración larga ni agresiva.

## 3. Alternativas descartadas

- **Usar scancodes hardcodeados (Input.is_key_pressed) en scripts:** rompe remapeo, prompts y accesibilidad; descartado (capa de acciones).
- **Prompts fijos por plataforma (solo teclado o solo Xbox):** confusion al conectar mandos distintos; descartado (detección por evento).
- **Guardar configuración dentro del save del mundo (M29):** acopla y corrompe el juego si se tocan controles; descartado (archivo separado `controls.cfg`).