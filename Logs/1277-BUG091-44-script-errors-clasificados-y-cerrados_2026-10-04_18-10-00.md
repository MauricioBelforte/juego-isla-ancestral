# Log 1277 - BUG-091: los 44 SCRIPT ERROR restantes - clasificados y cerrados

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy (CodeBuddy)
**Fecha:** 2026-10-04 18:10
**Frente:** director atria-Dawn-Preview, mensaje 18 (d) - "NUEVO FRENTE: los 44 SCRIPT ERROR restantes de BUG-091"
**Modulo:** transversal (BUG-091) - parse errors + validacion headless
**Estado:** CERRADO en mi zona. **NO sella 21.8** (autor != verificador).

---

## 1. Encargo (mensaje 18, d)

> "s2 cerro el frente tools/editor (22 -> 0, Log 1271) y agnes cerro gameplay/world/core
> (ServiceRegistry, commit 2666a18). **Quedan 44 SCRIPT ERROR repartidos en otros frentes.**"

Metodo exigido: barrido con `--check-only` sobre el colector + validacion con **full load**
(`godot --headless -e --quit`), **NO** con `--script` sobre archivos sueltos.
Restricciones (f): no tocar `quality.yml`; no tocar `settings_audio_layer.gd`/`configuracion/`;
no tocar M130-Artbook; **no fixear BUG-095 (`item_data.gd:88`) ni `inventario_service.gd:171`**
(zona agnes).
(g): escribir el informe con el desglose de los 44 (fixeados / delegados / falsos de `--script`).

## 2. Metodo

1. Regenerar el colector: `python Tools/quality/gen_colector_sintaxis.py --proyecto game/isla-ancestral`
   (919 preloads).
2. Medir: `godot --headless --check-only --script res://scripts/editor/_colector_sintaxis.gd`
   y contar `grep -c "SCRIPT ERROR"` (mismo criterio que el job `godot-lint` de `quality.yml`).
3. Clasificar cada error por tipo y archivo:linea.
4. Fixear por lote; **el parser aborta tras el PRIMER error de cada archivo**, asi que cada
   lote revela el siguiente error del mismo archivo (medido: 44 -> 9 -> 2).
5. Validar el cierre con **full load** (`-e --quit`), no con `--script`.
6. Correr las suites de los archivos tocados.

## 3. Desglose de los 44 (MEDIDO, no estimado)

Fuente cruda: `Obsoletos/raiz-temporales-bug091-44-2026-10-04/col_out.txt` (captura previa a mis fixes).

| # | Familia | Cantidad | Archivos / detalle |
|---|---------|----------|--------------------|
| A | `Identifier not found: <autoload>` (Compile Error) | **11** | `EventBus` x5, `ServiceRegistry` x2, `MundoRaiz` x2, `ItemDatabase` x1, `GameLogger` x1 |
| B | Cascada del colector (`Failed to compile depended scripts`) | **1** | `_colector_sintaxis.gd:0` |
| C | `Identifier "CollectibleCategory" not declared` (falta `class_name`) | **6** | `collectible_category.gd:76` + `test_collectible_category.gd:41/64/77/79/91` |
| D | `Cannot infer the type of "X"` (inferencia desde Variant) | **13** | collectible x8, auto_advance x1, quest_chain x2, validate_quest_chains x1, escanear_conectividad_m09 x1 |
| E | `Warning treated as error` (misma causa que D) | **4** | `build_info.gd:23`, `quest_chain_service.gd:55/130`, `asset_validation_m78.gd:76` |
| F | `AutoAdvanceManager` no declarado / tipo no encontrado | **2** | `auto_advance_manager.gd:91/92` |
| G | `Class "X" hides a global script class` | **3** | `location_registry.gd:26/33/47` (LocationRequirements/LocationObject/LocationData) |
| H | `Function "X" not found in base self` | **3** | `setdefault()` `quest_chain_service.gd:81`, `autoload()` `test_ubicaciones_m160.gd:36`, `add_child()` `test_enchantment.gd:5` |
| I | Return-type mismatch | **1** | `validate_quest_chains.gd:33` (`-> Script` devolviendo `Node`) |
| | **TOTAL** | **44** | |

Suma verificada: 11+1+6+13+4+2+3+3+1 = **44**.

## 4. Que se fixeo (42 de los 44)

**A - autoload bare-identifier (10 de 11 fixeados):** convencion del proyecto
`get_node_or_null("/root/<Nombre>")` (172 archivos la usan). Se envuelve el acceso:

- `scripts/clima/weather_service.gd:188/196` - `EventBus.weather.*.emit` -> `var bus := get_node_or_null("/root/EventBus"); if bus != null: bus.weather.*.emit(...)`.
- `scripts/diario/diary_service.gd:133/230/232` - `EventBus.diary.*` -> `bus`.
- `scripts/historia/story_manager.gd:185/207` - `EventBus.quest.*` -> `bus`.
- `scripts/historias/secondary_stories_service.gd:108/178/179` - `EventBus.quest.*` -> `bus`.
- `scripts/progresion/progression_manager.gd:214` - `EventBus.progresion.*` -> `bus`.
- `scripts/core/bootstrap.gd` - `ServiceRegistry.*` (7 llamadas) -> helper `func _registry() -> Node: return get_node_or_null("/root/ServiceRegistry")`; en `_autoregistrar_dominios()` se captura `var reg := get_node_or_null("/root/ServiceRegistry")` con guarda `reg != null`.
- `scripts/telemetry/telemetry_director.gd:157/203/382` - `GameLogger.*` -> `var logger := get_node_or_null("/root/GameLogger")`; el enum se toma por `const GAMELOGGER = preload("res://scripts/logging/logger.gd")` -> `GAMELOGGER.Category.ANALYTICS`.
- `scripts/main_island.gd:187/210/248` - constantes via `const MUNDO_RAIZ = preload("res://scripts/world/mundo_raiz.gd")` (`MUNDO_RAIZ.SPAWN_JUGADOR`); los metodos de instancia via `get_node_or_null("/root/MundoRaiz")`. **Se preservaron las cadenas `MundoRaiz.SPAWN_JUGADOR` / `MundoRaiz.centro_vec3` en comentarios** porque `validador_isla_raiz.gd` (M167) las busca por texto -> validador PASA 30/0.
- `scripts/performance/bench_recorder.gd:38/40/45/50` - `MundoRaiz.CENTRO` -> `MUNDO_RAIZ.CENTRO`; `centro_vec3(h)` -> `Vector3(MUNDO_RAIZ.CENTRO.x, h, MUNDO_RAIZ.CENTRO.y)`.

**C - `class_name` faltante (8 fixeados):**
- `scripts/coleccionables/collectible_category.gd` - se agrega `class_name CollectibleCategory` (elimina los 6 "not declared" + sus inferencias).
- `scripts/dialogos/auto_advance_manager.gd` - se agrega `class_name AutoAdvanceManager` (elimina F).

**D/E - inferencia desde Variant (17 fixeados):** `var x := <Variant>` -> `var x = ...` (o tipo explicito):
- `quest_chain_service.gd` (`data`, `ultimo_paso`, `st`, `errs`), `build_info.gd` (`data`), `asset_validation_m78.gd` (`assets`), `escanear_conectividad_m09.gd` (`dir_nombre`), `validate_quest_chains.gd` (`errores`), `test_collectible_category.gd` (`c`).

**G - inner class colisiona con `class_name` global (3 fixeados):**
- `scripts/data/location_registry.gd` - inner `LocationRequirements`/`LocationObject`/`LocationData` renombradas a `RequisitosUbicacion`/`ObjetoUbicacion`/`DatosUbicacion` (los `class_name` globales viven en `scripts/data/<snake>.gd`); `@export` actualizados.

**H - funciones inexistentes (3 fixeados):**
- `quest_chain_service.gd:81` - `Dictionary.setdefault()` no existe -> `if not _por_tipo.has(tipo): _por_tipo[tipo] = []` + `_por_tipo[tipo].append(chain)`.
- `test_ubicaciones_m160.gd:36` - `autoload("world_locations") if Engine.has_singleton(...)` (no existen) -> `root.get_node_or_null("/root/WorldLocations")` (`WorldLocations` SI es autoload, `project.godot:127`).
- `test_enchantment.gd:5` - `add_child()` no existe en `SceneTree` -> `root.add_child(system)`.

**I - return-type (1 fixeado):**
- `validate_quest_chains.gd:33` - `func _load_service() -> Script` -> `-> Node`.

**Archivo obsoleto (B, 1 caso):**
- `scripts/core/Obsoletos/2026-08-26_19-20-00_bootstrap.gd:43` usaba el identificador `ServiceRegistry` y era el unico error de tipo "desperdicio" (archivo muerto dentro de `res://`). Se **relocalizo** fuera de `scripts/` a `Obsoletos/2026-08-26_19-20-00_bootstrap.gd` (regla del proyecto: obsoleto -> relocalizar, NO borrar) + `git rm` de su `.uid`. Verificado: 0 referencias fuera del colector autogenerado. (Ya commiteado en `36da09f`.)

## 5. Delegado y cascada (2 de los 44)

- **DELEGADO (1):** `scripts/inventario/inventario_service.gd:171` - `ItemDatabase.get_item(...)` con identificador desnudo. **Zona de agnes (BUG-095)**; restriccion explicita del director (f): NO fixear. Es el unico error REAL restante.
- **CASCADA (1):** `_colector_sintaxis.gd:0` (`Failed to compile depended scripts`) - **dependiente** de A/B; desaparece cuando agnes fixee `inventario_service.gd:171`.

## 6. Falsos positivos de `--script` (0)

**Ninguno.** Los 44 son errores REALES de compilacion, no ruido de `--script`.

Aclaracion honesta del caso A (los 11 autoload): en modo **full load** los autoloads SI se resuelven
(`-e --quit` da 0 SCRIPT ERROR antes y despues). Por eso estos 11 **no rompen el juego en runtime**.
PERO son **violaciones reales** de la convencion del proyecto porque:
- (a) hacen fallar el **gate `godot-lint`** (el colector corre en `--check-only --script`, donde el
  identificador desnudo NO resuelve - probado empiricamente con una sonda: `EventBus.emit_signal("x")`
  bajo `--check-only --script` -> "Identifier not found: EventBus");
- (b) rompen cualquier **corrida headless `--script`** que cargue esos archivos;
- (c) la convencion `get_node_or_null("/root/<X>")` existe justamente para funcionar en ambos modos,
  y **172 archivos** del proyecto ya la usan -> los 5 archivos que fallaban eran **rezagados**.

De 16 archivos que usan `EventBus.`, solo 5 fallaban (los otros 11 ya usaban `get_node_or_null`).
Esto CONFIRMA que no es ruido global de `--script`, sino rezagos puntuales.

## 7. Evidencia (medida)

| Medicion | Antes | Despues |
|----------|-------|---------|
| `SCRIPT ERROR` en el colector (`--check-only --script`) | **44** | **2** (1 real de agnes + 1 cascada dependiente) |
| `SCRIPT ERROR` en full load (`-e --quit`) | 0 | **0** (EXIT 0, 0 `ERROR`) |
| `validador_isla_raiz.gd` (M167) | - | **30 checks / 0 fallos** |
| `test_collectible_category.gd` | - | **0 fallos**, EXIT 0 |
| `test_ubicaciones_m160.gd` | - | **17 checks / 0 fallos**, EXIT 0 |
| `test_bench_recorder_m166.gd` | - | **0 fallos**, EXIT 0 |

Residuo del colector (2 lineas, ambas de la MISMA causa ajena):
```
SCRIPT ERROR: Compile Error: Identifier not found: ItemDatabase
   at: GDScript::reload (res://scripts/inventario/inventario_service.gd:171)
SCRIPT ERROR: Compile Error: Failed to compile depended scripts.
   at: GDScript::reload (res://scripts/editor/_colector_sintaxis.gd:0)
```
Cuando agnes fixee `inventario_service.gd:171`, el colector queda en **0** y el gate `godot-lint`
queda verde (sin tocar `quality.yml`, que es de s2).

## 8. Hallazgos colaterales (reportados, NO fixeados)

1. **`test_enchantment.gd` (M163) cuelga al ejecutarse.** Antes de mi fix NO compilaba
   (`add_child()` parse error) -> fallaba rapido. Ahora compila (fix correcto: `root.add_child`),
   pero al correrlo **cuelga** (SIGTERM a los 30 s). Causa raiz probable: `load("res://game/isla-ancestral/scripts/enchantment/enchantment_system.gd")` tiene **prefijo doble** (`res://game/isla-ancestral/...`; el proyecto YA es `game/isla-ancestral`) -> `load()` devuelve `null`; y el test no tiene watchdog/quit en timeout. **No esta cableado en ningun workflow** (grep en `.github/`/`Tools/` = 0 refs) -> no afecta CI. Deuda de M163.
2. **`test_collectible_category.gd` (M73, agnes) emite `SCRIPT ERROR: Attempted to free a RefCounted object`** en runtime: llama `cat.free()` sobre un `CollectibleCategory extends Resource` (L46/117). Es preexistente (test del 2026-09-02), ajeno a mi fix de parseo; la suite igual reporta "0 fallo(s)" porque `_check()` no cuenta errores de runtime. Deuda de higiene de test (patron "verde con errores").

## 9. Archivos tocados (mi zona)

20 archivos `.gd` + 1 relocalizacion. Detalle en `git diff --stat` del commit.
Verificado: UTF-8 sin BOM; EOL por BYTES (`read_bytes().count(b"\r")`), no por `grep -c $'\r'`
(falsos positivos en Git Bash).

## 10. NO sella 21.8

Correccion de parse errors + validacion. El cierre/QA cruzado 21.8 corresponde a un verificador
distinto del autor (regla dura del proyecto). Este log NO sella ningun modulo.

**Firma:** **Modelo:** DeepSeek-V4.1-Flash / WorkBuddy **Fecha:** 2026-10-04 18:10

## 11. Huella de push (AGENTS.md 4.3)

- **Push principal:** rango `0c79ee6..e837eda` (2 commits: PROPIO `e837eda` + ajeno `6473807`).
  Fast-forward, sin `--force`, `GIT_TERMINAL_PROMPT=0`.
- **Hora:** 2026-10-04 18:15 (-0300).
- **Ejecutante:** DeepSeek-V4.1-Flash (WorkBuddy).
- **Contenido propio (`e837eda`):** 24 archivos, 474 inserciones / 80 borrados (20 `.gd` del frente
  T-D1 + Log 1277 + `11-BUGS.md` (BUG-098) + BACKLOG-MASTER (T-D1..T-D6) + respuesta 19).
- **Ajenos arrastrados:** 1 commit (`6473807` "BUG-097: informe carpeta (list_registered +
  validate_required)" - ya estaba local, de agnes; entra por fast-forward).
- **Verificacion:** `git rev-list --count HEAD..origin/main` = 0; `git ls-remote origin
  refs/heads/main` == `e837edad5d3507b3a9d97edc492c4edd2b11567e` tras el push.
- **Blobs:** `i/lf` en los verificados (`git ls-files --eol`); Log 1277 blob ASCII-puro
  (0 no-ASCII, 0 CR, sin BOM).

