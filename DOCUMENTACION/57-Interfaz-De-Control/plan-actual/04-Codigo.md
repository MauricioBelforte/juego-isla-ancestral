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

---

## Notas del Agente — Iteración 2 migración gameplay (historial, no borra las anteriores)

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 19:35:00
**Estado:** Parcial (migración gameplay a ControlInput implementada y verificada; módulo liberado 🟡)

### Lo que hice
- player.gd: cierre del inventario migrado de Input directo a ControlInput (helper `_accion_justa_m57(accion)` con fallback grácil si el autoload no existe — headless/test). Ya no hay `Input.is_action_just_pressed("ui_cancel")` en el gameplay.
- simple_walk.gd (prototipo de movimiento): migrado a ControlInput — movimiento via `vector_movimiento()` (dead zone RF4 aplicada) y salto via acción nueva **`saltar`** (InputMap: Espacio + botón A de mando).
- **FIX del núcleo (Log 254)**: `vector_movimiento()` tenía los ejes invertidos — `get_vector("mover_este", "mover_oeste", "mover_sur", "mover_norte")` ponía este/sur como negativos; corregido a la firma de Godot `(negativo_x, positivo_x, negativo_y, positivo_y)` = (oeste, este, norte, sur). El bug no se había detectado porque no había consumidor real del vector.
- InputMap: acción `saltar` agregada a project.godot (faltaba en el catálogo RF5).
- Test test_migracion_m57.gd: InputMap completo (10 acciones), vector con dead zone sin input real, player migrado (helper presente, sin Input directo), simple_walk migrado (camino principal ControlInput, fallback solo headless), acción saltar → **0 fallos**.
- Regresión: test_control_input (núcleo Deepseek) 0 fallos.
- Checklist: 2 ítems [x] adicionales (integración M06/M11 gameplay + InputMap saltar). Progreso 86→88/119.

### Lo que NO pude hacer (honestidad obligatoria)
- PromptButton/PromptDB con iconos por dispositivo (M46 arte): con dueño.
- Menú de remapeo con spinner (M46/M58): UI con dueño.
- Navegación focus (Tab/Enter/D-pad) en todos los menús: M53 con dueño.
- Steam Deck (M115), vibración global M91, M34 via InputLayer: con dueños.
- El Input directo queda como FALLBACK explícito solo cuando ControlInput no está disponible (headless/test) — el camino de gameplay es ControlInput.

### Recomendaciones para el próximo agente
- M13: al migrar el tool_controller, usar el mismo helper pattern (`_accion_justa_m57`) o inyectar ControlInput por grupo.
- M46: el menú de opciones debe listar ControlInput.ACCIONES_CATALOGO (ya existe la constante).
- M34: leer ejes via `ControlInput.eje("...")` para heredar dead zones configurables.
