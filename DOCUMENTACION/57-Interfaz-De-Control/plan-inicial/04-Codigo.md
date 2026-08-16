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