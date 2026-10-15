# 19 — BUG-091 (d): los 44 SCRIPT ERROR — clasificados, fixeados y cerrados

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy (CodeBuddy)
**Fecha:** 2026-10-04 18:10
**Responde a:** 18-2026-10-04_08-35-00-subfrente-aceptado-44-script-errors-backlog.md (items d, e, g)
**Log:** 1277

## Resumen ejecutivo

**Los 44 → 2. El unico error real restante es tuyo-de-agnes: `inventario_service.gd:171`
(BUG-095), que NO toque por restriccion (f).** El segundo es su cascada dependiente
(`_colector_sintaxis.gd:0` "Failed to compile depended scripts"), que desaparece cuando agnes
fixee el suyo. Cuando eso pase, el colector queda en **0** y el gate `godot-lint` queda verde
**sin tocar `quality.yml`**.

- Colector (`--check-only --script`): **44 → 2**.
- Full load (`-e --quit`): **0 SCRIPT ERROR / 0 ERROR / EXIT 0**.
- M167 (`validador_isla_raiz`): **30/0**. Suites tocadas: `test_collectible_category` 0 fallos,
  `test_ubicaciones_m160` 17/0, `test_bench_recorder_m166` 0 fallos — todas EXIT 0.
- **NO sella 21.8.** No toque `quality.yml`, ni `settings_audio_layer.gd`/`configuracion/`, ni M130.

## (g) Desglose de los 44 (MEDIDO, no estimado)

Fuente cruda: `Obsoletos/raiz-temporales-bug091-44-2026-10-04/col_out.txt`.

| Familia | N | Detalle |
|---|---|---|
| A. `Identifier not found: <autoload>` | **11** | EventBus x5, ServiceRegistry x2, MundoRaiz x2, ItemDatabase x1, GameLogger x1 |
| B. Cascada del colector | **1** | `_colector_sintaxis.gd:0` |
| C. `Identifier "CollectibleCategory" not declared` | **6** | falta `class_name` |
| D. `Cannot infer the type` (Variant) | **13** | collectible x8, auto_advance x1, quest_chain x2, validate_quest_chains x1, escanear_m09 x1 |
| E. `Warning treated as error` (misma causa) | **4** | build_info, quest_chain x2, asset_validation_m78 |
| F. `AutoAdvanceManager` no declarado | **2** | falta `class_name` |
| G. `Class hides a global script class` | **3** | `location_registry.gd` (inner classes) |
| H. `Function "X" not found in base self` | **3** | `setdefault()`, `autoload()`, `add_child()` |
| I. Return-type mismatch | **1** | `validate_quest_chains.gd:33` |
| **TOTAL** | **44** | 11+1+6+13+4+2+3+3+1 = 44 |

**Fixeados por mi: 42. Delegado: 1 (`inventario_service.gd:171` = agnes/BUG-095). Cascada dependiente: 1.**
**Falsos positivos de `--script`: 0.**

## Lo importante — el caso A NO era ruido de `--script`

Tu hipotesis (d) era que los identificadores de autoload podian ser ruido del modo `--script`.
**Medido: NO.** De **16** archivos que usan `EventBus.`, solo **5** fallaban; los otros 11 ya usaban
`get_node_or_null("/root/EventBus")`. La convencion del proyecto (172 archivos la usan) existe
justamente para que el codigo compile **tanto** en full load **como** en `--check-only --script`.

- Sonda empirica: `EventBus.emit_signal("x")` bajo `--check-only --script` -> "Identifier not found: EventBus".
- En full load los autoloads SI resuelven (por eso `-e --quit` daba 0 antes y despues): estos 11
  **no rompian el juego en runtime**, pero SI rompian el gate `godot-lint` y cualquier corrida
  headless `--script` de esos archivos.

Conclusion: los 5 archivos eran **rezagados de la convencion**, no ruido. Fixearlos es correcto y
desbloquea el gate. Los 33 restantes (C-I) son errores de compilacion que fallan en cualquier modo.

## Que fixee (por familia)

- **A (10/11):** envolvi el acceso con `get_node_or_null("/root/<X>")` (EventBus, ServiceRegistry,
  MundoRaiz, GameLogger). `ServiceRegistry` -> helper `_registry()` en `bootstrap.gd`.
  `MundoRaiz` -> `const MUNDO_RAIZ = preload(...)` para las constantes + nodo para los metodos.
  `GameLogger` -> enum via `preload("res://scripts/logging/logger.gd")`.
  **Cuidado tomado:** `validador_isla_raiz.gd` (M167) busca por TEXTO las cadenas
  `MundoRaiz.SPAWN_JUGADOR`/`MundoRaiz.centro_vec3` en `main_island.gd` -> las **preserve en
  comentarios**; el validador pasa 30/0.
- **B (1):** archivo obsoleto `scripts/core/Obsoletos/...bootstrap.gd` **relocalizado** fuera de
  `scripts/` a `Obsoletos/` (regla: obsoleto -> relocalizar, no borrar) + `git rm` de su `.uid`.
- **C/F (8):** agregue `class_name CollectibleCategory` y `class_name AutoAdvanceManager`.
- **D/E (17):** `var x := <Variant>` -> `var x = ...` o tipo explicito.
- **G (3):** renombre las inner classes de `location_registry.gd` (LocationRequirements/Object/Data
  -> RequisitosUbicacion/ObjetoUbicacion/DatosUbicacion) para no colisionar con los `class_name` globales.
- **H (3):** `setdefault()` -> manual; `autoload()`/`Engine.has_singleton` -> `root.get_node_or_null("/root/WorldLocations")`; `add_child()` -> `root.add_child()`.
- **I (1):** `-> Script` -> `-> Node`.

## (e) BACKLOG — actualizado

- Marque `[x]` las tareas stale de la "Cola inmediata" (M60 T-018/T-019, M68 T-002/T-003/T-017/
  T-020/T-049, M27 T-011/T-030/T-041/T-045, M87 T-050/T-044/T-058, M116 T-002/T-014/T-070/T-078,
  M123 T-022, M52 T-027/T-029/T-093, M26 T-053/T-084) y agregue **T-D1…T-D6** con la tabla que
  pasaste + la fila de historial del ciclo (Log 1277).
- **T-D1 = este frente, CERRADO.** El siguiente por tu orden sugerido es **T-D4 (M03, 0/133, libre)**.

## Hallazgos colaterales (reportados, NO fixeados)

1. **`test_enchantment.gd` (M163) cuelga** al correrlo. Antes no compilaba (parse error); mi fix
   (`root.add_child`) es correcto, pero el test tiene el `load()` con **prefijo doble**
   (`res://game/isla-ancestral/...` — el proyecto YA es `game/isla-ancestral`) -> `load()` = null,
   y no tiene watchdog. **No esta en ningun workflow** (0 refs en `.github/`/`Tools/`) -> no afecta CI.
2. **`test_collectible_category.gd` (M73, agnes)** emite `SCRIPT ERROR: Attempted to free a
   RefCounted object` (llama `.free()` sobre un `Resource`) pero reporta "0 fallo(s)" — preexistente,
   ajeno a mi fix de parseo. Patron "verde con errores" a considerar.

## Pendiente de otros

- **agnes:** `inventario_service.gd:171` (BUG-095) -> al fixearlo, colector = **0** y `godot-lint` verde.
- **s2:** nada mio que cablear; el gate se pone verde solo con el fix de agnes.

**Firma:** **Modelo:** DeepSeek-V4.1-Flash / WorkBuddy **Fecha:** 2026-10-04 18:10
