**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 57: Interfaz de Control

## 1. Arquitectura

```
        Dispositivos físicos (teclado, ratón, gamepads)
                      │
                      ▼
        InputLayer.gd (autoload, envoltura de InputMap Godot 4)
        ├── acciones nombradas (mover, saltar, interactuar...)
        ├── detección de dispositivo activo (señal dispositivo_cambiado)
        ├── remapeo en caliente (rebind de InputMap + persistencia)
        └── ajustes: sensibilidad x2 ejes, inversión x2, dead zones, vibración
                      │
        ┌─────────────┴──────────────┐
        ▼                           ▼
   Gameplay (M34, M13...)     UI (M45/M46)
   leen: InputLayer.ejex()     prompts: PromptLayer (iconos por dispositivo)
   vibración eventos           navegación: focus system fijo
                      │
                      ▼
        Persistencia: user://settings/controls.cfg (JSON atómico + backup)
```

## 2. Capa de acciones (catálogo mínimo)

| Acción | Teclado | Xbox | PlayStation | Genérico |
|---|---|---|---|---|
| mover_adelante/izquierda/atras/derecha | WASD | palanca izq | palanca izq | palanca izq |
| camara (ejes) | ratón | palanca der | palanca der | palanca der |
| saltar | Espacio | A | ✕ | botón sur |
| interactuar | E | X | □ | botón este |
| cancelar | Esc/click der | B | ○ | botón oeste |
| inventario | I | Y | △ | botón norte |
| diario | J | Back | SELECT/Share | ver atrás |
| mapa | M | View/Select | OPTIONS/Share | ver adelante |
| barra rápida 1-9 | 1-9 | — (D-pad?) | — | — |
| pausa | Esc | Start/Menu | OPTIONS | start |
| descartar/deseleccionar | click der / R | B | ○ | botón oeste |

## 3. Detección de dispositivo activo

- `_unhandled_input(event)`: si `event is InputEventKey` → modo teclado; `InputEventMouseButton/Motion` → modo ratón; `InputEventJoypadButton/Motion` → ID del pad → vendor → PlayStation (Sony) / Xbox (Microsoft/SDL XInput) / genérico.
- Señal `dispositivo_cambiado(modo)` notifica a la UI; los prompts se actualizan al instante.
- Reconexión: al conectar un pad, primera entrada lo vuelve activo (prompts cambian solos).

## 4. Prompts dinámicos (PromptLayer)

- `PromptDB` (data): tabla `accion × dispositivo → textura/etiqueta` (Xbox A/B/X/Y, PS ✕○□△, genérico sur/este/oeste/norte, teclado nombre de tecla).
- Widget `PromptButton` en UI: muestra el icono del dispositivo actual; se refresca con `dispositivo_cambiado`.
- Sin tocar el resto del layout: el icón se intercambia en runtime.

## 5. Remapeo

1. El usuario elige acción en el menú (M46) → spinner "presioná la tecla/botón".
2. Captura la primera entrada limpia (`event-pressed && !echo`, sin modificadores no deseados salvo los elegidos).
3. Verifica conflictos → si la tecla ya está asignada: aviso + sugerencia de tecla libre (recorre el catálogo no usado).
4. Aplica `InputMap.action_add_event` + guarda en configuration.
5. "Restablecer valores" → defaults + limpieza del archivo.

## 6. Dead zones y vibración

- Palanca izq: 0.15 radial; palanca der: 0.20 radial; gatillos: 0.10.
- Vibración: `start_joy_vibration(id, 0.6, 0.2, 0.25)` máx, eventos: pesca (tiron), daño leve, logro, construcción completada; configuración: intensidad 0-100% + OFF; nunca en diálogos.

## 7. Steam Deck y táctil

- **Deck:** el mando Deck se detecta como gamepad SDL; perfil por defecto (palancas, botones sur/este/oeste/norte); el focus system y los prompts salen con iconos de mando.
- **Táctil:** NO se implementa en esta fase (build PC/Deck); se deja la capa de acciones lista para una posible capa de botones táctiles en un futuro build móvil (decisión documentada).

## 8. Persistencia

- `user://settings/controls.cfg` — JSON: `{ "action": [ {device, inputs[]} ] , "sensibilidad": {...}, "inversion": {...}, "deadzones": {...}, "vibracion": {...} }`.
- Escritura atómica: guardar `controls.tmp` → reintentos → rename → `controls.cfg`; backup `.bak` previo; recovery al boot.
- Carga al boot: si el JSON es inválido → defaults + log de advertencia; el usuario puede "Restablecer" desde el menú.

## 9. QA

- Test M112: remapear acción, recargar partida → persiste; conflictos bloqueados; prompts cambian al alternar teclado/mando; dead zones efectivas; vibración OFF silencia.
- Recorrido M114: sesión completa solo teclado, solo mando, y mezclando — sin bloqueos de foco ni prompts incorrectos.