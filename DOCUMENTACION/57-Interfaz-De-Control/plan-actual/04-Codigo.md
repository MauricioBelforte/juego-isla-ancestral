**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 57: Interfaz de Control

## 1. Archivos involucrados (previstos)

| Archivo | Tipo | Rol |
|---|---|---|
| `res://src/input/input_layer.gd` | Autoload | Envoltura de InputMap; acciones, remapeo, ajustes |
| `res://src/input/prompt_layer.gd` | Autoload | Detección de dispositivo + distribución de prompts |
| `res://src/ui/prompt_button.gd` | Widget | Icono dinámico por dispositivo |
| `res://src/ui/remap_menu.gd` | Pantalla | Menú de remapeo (M46) |
| `res://data/input/prompt_db.tres` | Data | Mapa acción×dispositivo → icono/etiqueta |
| `res://data/input/default_bindings.tres` | Data | Bindings por defecto |
| `res://src/input/controls_persistence.gd` | Util | JSON atómico + backup + recovery |
| `res://icons/input/...` | Assets | Iconografía Xbox/PS/genérico/teclado |

## 2. API pública

```
InputLayer (autoload/único):
  accion_presionada(accion: String) -> bool
  eje(accion: String) -> float                # con dead zone aplicada
  ejes_camara() -> Vector2                    # sensibilidad + inversión aplicadas
  remapear(accion: String, evento: InputEvent) -> bool   # false = conflicto
  hay_conflicto(accion, evento) -> bool
  restaurar_defaults()
  config: sensibilidad_x/y, inversion_x/y, deadzones, vibracion(on, intensidad)
  guardar() / cargar()                        # controls.cfg
PromptLayer (autoload/único):
  dispositivo_activo() -> String              # "teclado"|"raton"|"xbox"|"playstation"|"generico"
  señal dispositivo_cambiado(modo)
  icono(accion) -> Texture2D
Vibración (InputLayer):
  vibrar(intensidad: float, duracion: float)  # respeta config
```

## 3. Suscripciones e integración

- M34: lee `InputLayer.eje("mover")`, `ejes_camara()` y `accion_presionada("saltar")`.
- M46: el menú de opciones muestra Remapeo, Sensibilidad, Inversión, Vibración, Dead Zones.
- M13/M17: "interactuar"/"usar herramienta" por acciones.
- M58: accesibilidad usa remapeo completo (RF del módulo).
- M91: opción de vibración también global (parte del mismo JSON).

## 4. Pendientes de implementación (dueño: AGENTE DELEGADO)

| Pendiente | Nota |
|---|---|
| InputLayer + PromptLayer + PromptButton | Sobre Godot 4 InputMap |
| Iconografía Xbox/PS/genérico/teclado | Assets del equipo de arte |
| Menú de remapeo (M46) | Necesita UI de opciones base |
| Persistencia atómica + recovery | Con M29 (boot) y M61 (sin bloqueo de hilo) |
| Tests M112 y QA M114 | Cambio de dispositivo, persistencia, conflictos |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 23:30:00
**Estado:** Documentación de diseño completa (módulo delegable)

### Lo que hice
- 22/22 puntos de la sección 56 resueltos.
- Capa de acciones única + remapeo con detección de conflictos + persistencia atómica.
- Prompts dinámicos por detección de dispositivo; dead zones, vibración y Steam Deck.
- Decisión táctil documentada (no aparece en fase PC/Deck, capa lista para futuro).

### Lo que NO hice (honestidad obligatoria)
- Implementar: depende de M46 (menú de opciones) y del sistema de input de Godot. Dueño: AGENTE DELEGADO.
- Iconografía de botones: assets del equipo de arte (spec de nombres en prompt_db).

### Recomendaciones para el próximo agente
- No leer scancodes en gameplay: usar siempre InputLayer (remapeo y prompts dependen de ello).
- El spinner de remapeo debe ignorar eventos de repetición y modificadores por defecto.
- Probar alternancia teclado↔mando durante el juego real: los prompts deben cambiar sin recargar la escena.

---

## Iteración 1 — Implementación real (2026-08-30, Deepseek V4 Flash / Kilo)

### Archivos runtime vigentes (NO las rutas plan-inicial `res://src/...`)

```
res://scripts/controls/
├── control_input.gd        # Autoload "ControlInput" (capa de acciones M57)
└── test_control_input.gd   # Test headless (0 fallos)
```

Registrado en `project.godot` como autoload `ControlInput`. Envuelve el `InputMap` de Godot 4
(M04) y las acciones ya definidas en `[input]` del proyecto. No reemplaza el input del gameplay
existente (M06/M13 siguen usando `Input.is_action_*`); agrega la capa única de consulta, el
remapeo, la detección de dispositivo y la persistencia.

### API pública implementada

- `accion_presionada/accion_justa(accion)` → consulta por nombre (RF2)
- `eje(accion)` → fuerza con dead zone; `vector_movimiento()` → WASD/palanca con dead zone radial
- `ejes_camara(delta)` → sensibilidad X/Y + inversión X/Y (RF4)
- `dispositivo_activo()` + señal `dispositivo_cambiado(modo)` (RF7)
- `etiqueta_accion(accion)` → texto del botón actual según dispositivo (teclado "E", "Btn3", etc.)
- `remapear(accion, evento)` + `hay_conflicto(accion, evento)` → remapeo en caliente (RF3/RF5)
- `restaurar_defaults()` → limpia remapeos y ajustes
- `vibrar(intensidad, duracion)` → respeta `vibracion_on` (RF4)
- Persistencia: `_guardar_config()` / `_cargar_config()` → `user://settings/controls.cfg`
  (JSON atómico: tmp → backup .bak → rename), recovery a defaults ante JSON inválido (RF8)

### Lo que hice

- Autoload completo con catálogo de acciones (20 acciones), detección por vendor
  (Xbox/PS/genérico/teclado/ratón), remapeo con conflictos, dead zones configurables,
  sensibilidad/inversión por eje, vibración con OFF, persistencia atómica.
- Test `test_control_input.gd`: acciones básicas, remapeo + conflicto bloqueado,
  sensibilidad/inversión, serialización. 0 fallos.

### Lo que NO hice (honestidad)

- Iconografía (assets del equipo de arte) y PromptButton visual: requieren M53/arte (V1-V2).
- Menú de remapeo (M46): requiere la UI de opciones base.
- Steam Deck nativo: sin hardware para validar; detección genérica cubre el mando Deck.
- Integración M34/M13/M17 a través de ControlInput: no se migró el gameplay existente
  (evita regresiones; queda como tarea de integración posterior).
- Vibración "nunca en diálogos" (cozy): sin hook de diálogo aún.

### Recomendaciones para el próximo agente

- Migrar progresivamente el gameplay a `ControlInput.accion_presionada(...)` y
  `ControlInput.ejes_camara(...)` para que el remapeo tenga efecto real.
- Conectar la señal `dispositivo_cambiado` con la UI de prompts (M53) para actualizar iconos
  sin recargar.
- Documentar un descubrimiento de GDScript en 07-GUIA-GODOT: `b.button_index = int(...)`
  dispara "Integer used when an enum value is expected" → usar cast `as JoyButton`/`MouseButton`/`JoyAxis`.