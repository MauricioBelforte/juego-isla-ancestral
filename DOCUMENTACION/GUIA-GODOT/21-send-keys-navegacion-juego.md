# 21 — send_keys: envío de teclas al juego Godot (Win32 API)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-11-04
**Estado:** Vigente — verificado en juego "isla-ancestral (DEBUG)"

## Propósito

Permite enviar secuencias de teclas al juego Godot en ejecución para navegar por menús, entrar a módulos, hacer QA visual y probar controles. Complementa **V4 (godot-mcp)**, que lanza y controla el juego pero **no expone tool para enviar teclas**.

## Script

Ubicación: `scripts-reutilizables/send_keys_to_window.py`

Usa **ctypes** (stdlib Windows, sin dependencias externas) con `PostMessage` (WM_KEYDOWN/WM_KEYUP) y `SendInput` como fallback.

### Uso

```
python send_keys_to_window.py "<título parcial de la ventana>" "<tecla1> <tecla2> ..." [título exacto]
```

**Ejemplo:**
```
python send_keys_to_window.py "isla-ancestral" ESC DOWN DOWN ENTER "isla-ancestral (DEBUG)"
python send_keys_to_window.py "Configuracion" ALT F4
```

### Teclas soportadas

| Tecla | VK |
|-------|-----|
| ESC | 0x1B |
| ENTER | 0x0D |
| SPACE | 0x20 |
| TAB | 0x09 |
| BACKSPACE | 0x08 |
| DELETE | 0x2E |
| UP | 0x26 |
| DOWN | 0x28 |
| LEFT | 0x25 |
| RIGHT | 0x27 |
| HOME | 0x24 |
| END | 0x23 |
| PAGEUP | 0x21 |
| PAGEDOWN | 0x22 |
| F1–F12 | 0x70–0x7B |
| A–Z | 0x41–0x5A |
| 0–9 | 0x30–0x39 |

**Combinaciones modificadoras:** `CTRL+C`, `ALT+F4`, `SHIFT+TAB` (formato `MOD+TECLA`).

## Flujo recomendado para QA visual (B-9 / B-10)

Para evitar loops y tener evidencia visual, usar **capturas entre cada paso**:

1. `godot_run_project` vía MCP Godot → inicia el juego en ventana separada
2. `screen.capture_window("isla-ancestral")` → captura de estado inicial
3. `send_keys_to_window.py "isla-ancestral (DEBUG)" ESC` → abre menú de pausa
4. `screen.capture_window("isla-ancestral")` → verifica menú abierto
5. `send_keys_to_window.py "isla-ancestral (DEBUG)" DOWN DOWN DOWN ENTER` → navega y selecciona
6. `screen.capture_window("isla-ancestral")` → verifica resultado (módulo abierto)
7. Repetir hasta entrar al módulo objetivo y capturar defectos visuales

### Módulos objetivo para B-9 (visión post-flip)
M85, M22, M14, M34, M11, M67, M74

### Módulos objetivo para B-10 (assets 3D pendientes)
M33, M65, M54, M50

## Limitaciones conocidas

| Limitación | Detalle |
|------------|---------|
| Ventana visible | La ventana de Godot debe estar visible (no minimizada) para recibir input |
| Título variable | Puede ser "isla-ancestral (DEBUG)" al correr, distinto al editar |
| Esquema de controles | Las flechas pueden no mover el cursor si el juego usa W/S; verificar con capturas entre cada tecla |
| Un agente a la vez | No tocar módulos 🔵/🔴 ni colas de otros agentes (anti-duplicado) |

## Verificación empírica (2026-11-04)

- ✅ ESC abre/ciende menú de pausa en "isla-ancestral (DEBUG)"
- ✅ DOWN/UP/LEFT/RIGHT navegan menús (verificado con capturas entre cada tecla)
- ✅ ENTER selecciona opción del menú
- ✅ W/A/S/D mueven al personaje en juego
- ✅ `send_keys_to_window.py` enviado a HWND=3146422 con título "isla-ancestral (DEBUG)"
- ✅ `screen.capture_window("isla-ancestral")` captura el juego en ejecución

## Relación con otras vías

| Vía | Qué hace | Relación con send_keys |
|-----|----------|------------------------|
| V4 (godot-mcp) | Lanza, controla, lee logs del juego Godot | No envía teclas; send_keys complementa |
| V2 (screen-mcp) | Captura pantalla/ventana | Usada junto con send_keys para verificar después de cada tecla |
| V1 (capturas en chat) | Usuario pega screenshots | Alternativa si V2/V4 no están disponibles |

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-11-04
