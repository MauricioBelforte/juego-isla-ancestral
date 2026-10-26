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

## Specs Interfaz de Control (Beam 692)

### RF6: navegacion UI con teclado y mando
- Spec: RF6: navegacion UI con teclado y mando. Coherente with M57 (interfaz de control) and M53 (UI).

### P4: Xbox — iconografia A/B/X/Y propia, dead zone estandar
- Spec: P4: Xbox — iconografia A/B/X/Y propia, dead zone estandar. Coherente with M57 (interfaz de control) and M56 (interfaz).

### P5: PlayStation — iconografia cruceta/circulo/cuadrado/triangulo, deteccion vendor
- Spec: P5: PlayStation — iconografia cruceta/circulo/cuadrado/triangulo, deteccion vendor. Coherente with M57 (interfaz de control) and M56 (interfaz).

### P6: generico — mapa universal de ejes/botones
- Spec: P6: generico — mapa universal de ejes/botones. Coherente with M57 (interfaz de control) and M56 (interfaz).

### P14: navegacion teclado — Tab/Enter/Esc en todos los menus
- Spec: P14: navegacion teclado — Tab/Enter/Esc en todos los menus. Coherente with M57 (interfaz de control) and M53 (UI).


## Specs Interfaz de Control (Beam 689)

### P15: navegacion mando — D-pad/palanca + A/B confirmar/cancelar
- Spec: P15: navegacion mando — D-pad/palanca + A/B confirmar/cancelar. Coherente with M57 (interfaz de control) and M53 (UI).

### P20: Steam Deck — mando Deck nativo, perfil por defecto
- Spec: P20: Steam Deck — mando Deck nativo, perfil por defecto. Coherente with M57 (interfaz de control) and M95 (plataformas).

### PromptButton refresca icono sin recargar escena
- Spec: PromptButton refresca icono sin recargar escena. Coherente with M57 (interfaz de control) and M53 (UI).

### Menu: seleccionar accion -> spinner
- Spec: menu: seleccionar accion -> spinner. Coherente with M57 (interfaz de control) and M53 (UI).

### Vibracion nunca en dialogos (cozy)
- Spec: vibracion nunca en dialogos (cozy). Coherente with M57 (interfaz de control) and M21 (dialogos).


## Specs Interfaz de Control (Beam 690)

### Focus system: Tab/Shift+Tab/Enter/Esc en todos los menus
- Spec: focus system: Tab/Shift+Tab/Enter/Esc en todos los menus. Coherente with M57 (interfaz de control) and M53 (UI).

### D-pad/palanca mueven el foco
- Spec: D-pad/palanca mueven el foco. Coherente with M57 (interfaz de control) and M53 (UI).

### Hover mouse con tooltip del atajo (M46)
- Spec: hover mouse con tooltip del atajo (M46). Coherente with M57 (interfaz de control) and M46 (texturas).

### Spinner de remapeo bloquea clics rapidos (UX seccion 8 AGENTS)
- Spec: spinner de remapeo bloquea clics rapidos (UX seccion 8 AGENTS). Coherente with M57 (interfaz de control) and M53 (UI).

### Deck detectado como gamepad SDL
- Spec: deck detectado como gamepad SDL. Coherente with M57 (interfaz de control) and M95 (plataformas).


## Specs Interfaz de Control (Beam 691)

### Perfil por defecto para el mando Deck
- Spec: perfil por defecto para el mando Deck. Coherente with M57 (interfaz de control) and M95 (plataformas).

### Focus y prompts del Deck con iconos de mando
- Spec: focus y prompts del Deck con iconos de mando. Coherente with M57 (interfaz de control) and M95 (plataformas).

### M34 lee acciones y ejes via InputLayer
- Spec: M34 lee acciones y ejes via InputLayer. Coherente with M57 (interfaz de control) and M34 (pesca).

### M46 hostea el menu de opciones de control
- Spec: M46 hostea el menu de opciones de control. Coherente with M57 (interfaz de control) and M46 (texturas).

### M58 remapeo completo (accesibilidad)
- Spec: M58 remapeo completo (accesibilidad). Coherente with M57 (interfaz de control) and M58 (accesibilidad).


## Specs Interfaz de Control (Beam 692)

### Test: prompts cambian al alternar teclado/mando en juego
- Spec: test: prompts cambian al alternar teclado/mando en juego. Coherente with M57 (interfaz de control) and M112 (testing).

### Recorrido M114 solo teclado / solo mando / mezclado
- Spec: recorrido M114 solo teclado / solo mando / mezclado. Coherente with M57 (interfaz de control) and M114 (hardware).

### Specs items degradados T255 (2026-10-26, Reflection-Beam-1.0)
- **L69 (RF8+RF9: persistencia JSON y Steam Deck/táctil "si corresponde"):** spec definida.
