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
## 7. Anti-patrones adicionales (E8-E10)

Complementa la tabla de anti-patrones de `02-Analisis` sección 3 (7 entradas). Los tres
siguientes se documentan acá porque su mitigación es una **regla de diseño**, no un patrón
transversal.

### 7.1 E8 — No mutar el árbol ni las conexiones del engine en el momento equivocado (usar `deferred`)

**Anti-patrón:** llamar `add_child()`, `remove_child()` o `change_scene_to_file()` **dentro de
`_ready()`** (o de cualquier callback con el que el engine esté construyendo/desmontando el
árbol). Godot aborta la operación con `Parent node is busy setting up children` /
`Parent node is busy adding/removing children`.

**Mitigación (regla):** toda mutación del árbol que ocurra en `_ready()` o en un callback de
señal del engine se difiere con `call_deferred()`.

- Referencia: `GUIA-GODOT/01-gdscript-errores-comunes.md` §13 (add_child en `_ready`) y §14
  (`change_scene_to_file()` en `_ready`).
- Aplicado en el proyecto (medido 2026-10-14): `scripts/core/bootstrap.gd` difiere las 4
  operaciones de arranque (`_verificar_game_flow`, `_autoregistrar_dominios`,
  `verificar_integridad_dominios`, `_load_main_scene` — líneas 47-50);
  `scripts/core/scene_manager.gd:33` difiere `_do_cambio(ruta)`.

### 7.2 E9 — No procesar todo en `_process` (timers/eventos primero)

**Anti-patrón:** resolver por polling en `_process` lo que un timer, una señal o un `await`
resuelven mejor (input, temporizadores, esperas). Coste por frame desperdiciado, orden de
ejecución no determinista y acoplamiento temporal.

**Mitigación (regla):**
- Input: `_unhandled_input()` / `_input()`. **NUNCA** `Input.is_action_just_pressed()` dentro
  de `_process` (GUIA-GODOT/01 §4).
- Tiempo/calendario: escuchar `GameTime` (observer) o usar `GameClock`/`Timer`; no acumular
  deltas a mano.
- Esperas: `await` sobre una señal o un `Timer`, no un contador de frames.
- Un `_process` que sí haga falta (p. ej. un lookup perezoso con reintento) debe **acotar** su
  trabajo con un tope de frames y una guarda de estado (patrón de GUIA-GODOT/01 §26).

> Contexto medido (2026-10-14): **58** scripts de `game/isla-ancestral/scripts/` definen
> `func _process`. No todos son anti-patrón (movimiento, cámara y UI lo usan legítimamente),
> pero es el universo a auditar cuando M61 pida presupuesto de frame.

### 7.3 E10 — No duplicar lógica entre módulos (reutilizar `utils`/servicios)

**Anti-patrón:** copiar la misma función (validaciones, conversiones, formateo, matemática de
dominio) en dos módulos. Duplica los bugs y obliga a corregir en N lugares.

**Mitigación (regla):**
- Helper puro y sin dependencias de escena → `scripts/utils/` (§2).
- Regla de reuso: si un **tercer** módulo necesita la misma lógica, se **extrae** a `utils` o a
  un servicio autoload, y los tres la consumen.
- La duplicación suele nacer de un archivo que creció de más: > 400 líneas obliga a justificar
  o a romper en módulos (§1, Reglas de estilo 6).

## 8. Edge cases del lenguaje (H1-H6)

Casos de borde que no son anti-patrones de arquitectura sino **trampas del lenguaje/engine**.
Cada uno trae la regla y una referencia real del repo o de la GUIA-GODOT.

### 8.1 H1 — Migración GDScript 2 (Godot 3.x) → GDScript 4 (scripts legacy)

El proyecto es **Godot 4.7.2** (`project.godot` `config/features = PackedStringArray("4.7",
"Forward Plus")`, línea 16) y no arrastra scripts de Godot 3. La regla cubre el caso de
incorporar código legacy (assets, snippets, freelancers):

- **No hay migración automática fiable.** Un script de Godot 3 se **reescribe**, no se parchea:
  `yield` → `await`, `export` → `@export`, `onready` → `@onready`, `instance()` →
  `instantiate()`, `PoolStringArray` → `PackedStringArray`, `OS.get_ticks_msec()` (se mantiene).
- **Verificar SIEMPRE que compila antes de darlo por bueno.** Los dos métodos "obvios" mienten
  (GUIA-GODOT/01 §31): `GDScript.new()` + `source_code` da falsos positivos sobre `class_name`
  ya registrados, y `ResourceLoader.load()` solo **NO** detecta un error de sintaxis. El método
  correcto es `load()` + `reload()` sobre el recurso (ruta `res://`).
- Referencia de migración: `GUIA-GODOT/09-godot4-migracion.md`.

### 8.2 H2 — Señales emitidas antes de `_ready()` (timing y `deferred`)

Dos caras del mismo problema de **orden de inicialización**:

- **Emitir** una señal antes de que el receptor haya corrido su `_ready()`/`connect()` pierde el
  evento (una señal no se re-emite). Regla: el emisor no emite en `_init()`; como mínimo, diferir
  la primera emisión con `call_deferred()`.
- **Resolver** un autoload desde el `_ready()` de un nodo de escena puede devolver `null` aunque
  el autoload exista (es *timing*, no ausencia): lookup perezoso + reintento con tope vía
  `Engine.get_main_loop().root.get_node_or_null(...)` (GUIA-GODOT/01 §26).
- En modo `--script` un autoload **no** es identificador global: usar
  `root.get_node_or_null("/root/<Nombre>")` (GUIA-GODOT/01 §24).

### 8.3 H3 — Resources mutables compartidos (duplicarlos)

Godot **cachea los `Resource` por ruta**: `ResourceLoader.load()` sobre un `.tres` ya cargado
devuelve **la misma instancia**. Mutar esa instancia (o sus variables de script no exportadas)
contamina a todos los consumidores y sobrevive a un "reload".

- **Regla:** un `.tres` que se lee es **inmutable**; si hay que modificarlo, `.duplicate()`.
- Aplicado en el proyecto: `scripts/accesibilidad/accesibilidad_manager.gd:207` duplica el
  perfil antes de mutarlo (`PERFILES[nombre].duplicate()`) y `:266` devuelve una copia.
- Referencia: `DOCUMENTACION/27-Islas-Del-Mundo/plan-actual/04-Codigo.md` §8 trampa 2 (el
  `cargar_definiciones()` tuvo que resetear a mano `ancla`/`semilla_isla` porque la instancia
  cacheada sobrevivía al reload).

### 8.4 H4 — Rutas `res://` vs `user://` (guardados)

- `res://` = recursos del proyecto, **solo lectura en build exportado** (dentro del `.pck`).
  Todo lo que se escribe en runtime va a `user://`.
- `user://` en este proyecto resuelve a `game/isla-ancestral/Godot/app_userdata/isla-ancestral/`
  (medido: contiene `saves/`, `backups/`, `checkpoints/`, `logs/`, `config.cfg`). **Ese
  directorio ES el `user://` real: nunca borrarlo entero.**
- `DirAccess.open("user://...")` puede devolver `null` en headless con `--path` relativo, y
  `ProjectSettings.globalize_path("user://...")` devuelve una ruta **relativa**
  (`./Godot/app_userdata/...`). Solución: recomponer con `globalize_path("res://")` + la parte
  relativa (helper `_abrir_dir()`), o usar la API estática (`DirAccess.dir_exists_absolute`).
  `FileAccess.open("user://...", WRITE)` sí funciona.
- Guardado: `scripts/saving/save_schema.gd:17` fija `SAVE_DIR = "user://saves"` y
  `scripts/saving/save_writer.gd:49` pone la clave de integridad en la **raíz** de `user://`
  (no dentro de `saves/`, que las suites vacían).
- Referencia: `DOCUMENTACION/27-Islas-Del-Mundo/plan-actual/04-Codigo.md` §8 trampa 1.

### 8.5 H5 — Floats y determinismo (generación procedural)

- **La generación debe ser reproducible a partir de una semilla explícita.** Todo
  `RandomNumberGenerator`/`FastNoiseLite` recibe una semilla derivada del mundo o del día, nunca
  del reloj del sistema.
- Aplicado: `scripts/world/island_generator.gd` fija semillas derivadas por capa (`seed_value`,
  `+1000`, `+2000`, `+3000` — líneas 47/54/61/68); `scripts/time/game_clock.gd:203` expone
  `rng_diario(ns)` = `RandomNumberGenerator` con semilla **hasheada por namespace + día**.
- **Comparar floats con tolerancia, no con `==`** (salvo valor exacto por construcción). Ojo:
  `JSON.parse_string()` devuelve **todo número como `float`** → `[0,4,7]` llega como
  `[0.0,4.0,7.0]` y el `==` de `Array` es exacto por elemento (GUIA-GODOT/01 §29). Regla: en
  tests de datos, normalizar a `int` antes de comparar (no aflojar la aserción).

### 8.6 H6 — Threads y nodos (`call_deferred` obligatorio)

- **El árbol de escena NO es thread-safe.** Un hilo de trabajo no puede tocar nodos: al terminar,
  devuelve el resultado al hilo principal con `call_deferred()` (o `WorkerThreadPool` +
  `call_deferred`), y recién ahí muta la escena.
- Regla: la lógica pesada que corre en un hilo opera sobre **datos puros** (arrays/diccionarios),
  nunca sobre `Node`/`Resource` vivos; la aplicación a la escena se difiere.
- Mismo principio que E8: la mutación del árbol va diferida (GUIA-GODOT/01 §13-§14).

## 9. Proceso de código (F9-F10)

Reglas de proceso que aplican a TODO módulo de código. Se documentan en M05 porque este módulo
fija el lenguaje y las convenciones del proyecto; las fuentes normativas son `AGENTS.md` (§6 logs,
§21 protocolo multiagente) y el índice maestro de módulos.

### 9.1 F9 — Actualización de checklists al crear módulos nuevos

Al **crear** un módulo `M##` (o añadir un componente al proyecto) se actualizan **dos** índices, y
ninguno se regenera a mano item por item:

1. **Índice maestro de módulos** — `DOCUMENTACION/01-Fundamentos-Del-Proyecto/plan-actual/05-Checklist.md`
   (152 items). Cada item `**M##**` apunta a la carpeta `DOCUMENTACION/{##+1:03d}-{Nombre}`
   (medido: `**M04** Lenguaje y Programación` -> `05-Lenguaje-Y-Programacion`). Un módulo nuevo
   agrega su item `**M##**` con el conteo medido de su `05-Checklist.md`.
2. **Fila del módulo en `CHECKLIST-GLOBAL.md`** (raíz; 1 fila = 1 módulo). Su celda `Progreso` debe
   coincidir con el `**Totales:**` del `05-Checklist.md` del módulo: `scripts/verificar_checklist.py`
   lo cruza y sale con exit 1 si difieren.

Regla dura: el módulo nace con su propio `05-Checklist.md` (secciones + `**Totales:**`), y **ese
checklist es la fuente de verdad de sus subitems**; el índice maestro y la fila GLOBAL solo
**resumen** (AGENTS.md §21.1). El item del índice maestro y la fila GLOBAL los aplica su dueño
(el director), no el módulo que se está cerrando.

### 9.2 F10 — Registro de cada decisión de código en Logs

Toda decisión de código (fix, refactor, elección de patrón, cambio de dataset) se registra en un log
en `Logs/` según **AGENTS.md §6**:

- **Numeración (protocolo v3, §6.1):** el número se **consume** tomando la **primera línea** de
  `Logs/NUMEROS_DISPONIBLES.txt` con `scripts/reservar_log.py --reservar` (un número = un archivo; no
  hay archivo de reserva). El número se anota en el backlog personal
  (`TAREAS-POR-MODELO/<MODELO>/BACKLOG-MASTER.md`) antes de escribir el log.
- **Formato (§6.2):** `Logs/{N}-DESC_AAAA-MM-DD_HH-MM-SS.md`, con header `# Log {N}: ...`, fecha/hora
  reales, modelo, plataforma, resumen, cambios y archivos modificados.
- **Higiene:** el log es **ASCII puro** (`LC_ALL=C grep -c '[^ -~]'` == 0). `ULTIMO_NUMERO.txt` y
  `Logs/reservas/` están **retirados** desde el protocolo v3 (commits `2ac8b4b`/`b65c30b`).
- La DoD (AGENTS.md §21.6) exige el log generado para marcar `[x]` un subitem.
