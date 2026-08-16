**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 05: Lenguaje y Programación

## 1. Convenciones de código (guía verificable)

### GDScript (Godot 4)
| Elemento | Regla | Ejemplo |
|---|---|---|
| Clases | PascalCase + `class_name` | `class_name PlayerController` |
| Archivos | snake_case del nombre de clase | `player_controller.gd` |
| Nodos/escenas | snake_case | `camera_rig.tscn` |
| Variables | snake_case; privadas con `_` | `_inventory_slots` |
| Constantes | `UPPER_SNAKE` | `const MAX_STACK = 99` |
| Métodos | snake_case | `func use_tool() -> void:` |
| Señales | snake_case con `_signal` opcional | `signal tool_used(tool)` |
| Enums | `UPPER_SNAKE` con nombre contextual | `enum ToolState { IDLE, ACTIVE }` |
| Tipado | Tipado explícito en firmas (obligatorio) | `func dig(pos: Vector3i) -> bool` |
| Exports | `@export` con rango/descripción | `@export_range(0, 100) var damage: int` |

### Reglas de estilo
1. 4 espacios; líneas ≤ 120 chars; una responsabilidad por archivo.
2. Comentarios solo con propósito/por-qué (nunca obvios).
3. Idiomas de comentarios: español (equipo) — las UI strings van por separado (M53).
4. Nada de `print()` de debug en producción: usar `Logger` con nivel.
5. `@warning_ignore` solo con justificación escrita.
6. Cada script > 400 líneas debe justificarse (señal de romper en módulos).

## 2. Arquitectura de carpetas de código (en `res://`)

```
res://
├── scenes/          (tscn por sistema)
├── scripts/
│   ├── core/        (autoloads: EventBus, GameClock, Settings, Logger, ErrorHandler)
│   ├── gameplay/    (jugador, herramientas, crafting, construcción)
│   ├── ai/          (NPC, rutinas, emociones)
│   ├── world/       (voxel, chunks, generación, biomas)
│   ├── ui/          (HUD, inventario, diálogo)
│   ├── data/        (resources: recetas, diálogos, biomas)
│   └── utils/       (helpers extensiones)
├── resources/       (archivos .tres de datos)
└── data/            (seeds, configs serializadas)
```

## 3. Patrones transversales diseñados

| Sistema | Diseño | Detalle |
|---|---|---|
| EventBus | Singleton autoload | Señales tipadas por dominio (mundo, economía, historia) |
| GameClock | Autoload | Fecha/estación/hora; entidades lo escuchan (observer) |
| Settings | Autoload | Config usuario con persistencia `.cfg` (input, cámara, audio) |
| Logger | Autoload | Niveles, rotación (AGENTS §18), archivo fuera de `res://` |
| ErrorHandler | Autoload | Centro de fallos: log + fallback + (en dev) pausa |
| SceneManager | Autoload | Carga de islas con pantalla diegética (Gran Vapor) |
| PoolService | Autoload | Pool genérico para props/partículas |
| GameState | Data struct | Serializable+versionado (detalle en M59) |
| QuestManager | Autoload | Pre-requisitos (sellos→boletos) para progresión |

## 4. Sistema de eventos (diseño)

- Todas las señales que cruzan sistemas van por `EventBus` (tipadas).
- Señales locales (dentro de un nodo) quedan en el nodo.
- Regla: ningún sistema llama APIs de otro directamente si hay señal definida.
- Los eventos llevan payload tipado (objetos de dominio, no diccionarios abiertos) para edición segura.

## 5. Sistema de estados (diseño)

- State machines por entidad: jugador (idle/move/jump/swim/climb/use), NPC (rutina/emoción), herramienta (idle/charge/use).
- Estados implementados como nodos/scripts separados o enums+match (elegir en M11 según complejidad).
- Transiciones explícitas; un estado no puede editar otro directamente (excepto el controlador).

## 6. Reglas de calidad por script ("done")

1. Tipado completo y sin warns en el editor.
2. Sin strings mágicos (enums/constantes centrales).
3. Logs para entradas/salidas de sistemas críticos (Logger).
4. Sin llamadas a UI desde gameplay (señales/eventos).
5. Sin acceso a `GameState` fuera de módulos de datos (regla de capas).