# Log 2232 - M61 Rendimiento - Medicion de runtime y clasificador de medibilidad

**Agente:** DeepSeek-V4.1-Flash (WorkBuddy)
**Modulo:** M61-Rendimiento
**Rama:** RAMA 2 (sin mensaje nuevo del director; acuse 438 procesado)
**Fecha:** 2026-10-28 03:02 (GMT-3)
**Log:** 2232 (reservado con scripts/reservar_log.py, cabeza previa 2232)
**Canal:** mensaje 439

---

## 1. Premisa medida ANTES de escribir (regla de flota)

| Fuente | Dice | Realidad medida en disco |
|---|---|---|
| COLA ACTIVA item 102 | M61 (53/148), "lote tecnico de perfil/culling" | **146 [x] / 1 [ ] / 1 [?] = 148** |
| Fila 61 del CHECKLIST-GLOBAL | 118/148, "quedan 8 [ ] + 22 [?]" | idem 146/1/1 |
| `05-Checklist.md` L332 `**Totales:**` | 148 items - 118 completados - 8 pendientes - 22 no resueltos | **146 / 1 / 1** |

Los "8 [ ] + 22 [?]" son una foto del 2026-10-21. Desde entonces **21 items `[?]` -> `[x]`**
entraron en el commit de preservacion `a7a3a6b` (2026-10-26, "Se preservo la jornada 26oct"),
firmados "FLIP 2026-10-26 (Reflection-Beam-1.0, T189-61)". Medido con diff de marcadores:

```
git show a7a3a6b^:05-Checklist.md  -> 125 [x] / 1 [ ] / 22 [?]
HEAD:05-Checklist.md              -> 146 [x] / 1 [ ] /  1 [?]
transiciones en a7a3a6b           -> 21 "+[x]" / 21 "-[?]"
de las 21 lineas +, con cita      -> 21 / 21  (0 sin cita)
```

**Conclusion honesta:** los 21 flips SI estan citados (no es el patron de M01 con 90 flips
sin cita). El defecto es solo de **`Totales`**: la linea quedo congelada en 118/8/22 y ya
estaba stale por 7 antes de ese commit (el cuerpo tenia 125/1/22). El `05-Checklist.md` de
un modulo es NO TOCAR sin orden -> **no se toco**; se pide al director.

El item que queda abierto es **L289** "Usar meshes combinados por chunk (M07) [S]":
implementacion del dueno M07, no mia (15). El `[?]` que queda es **L221** "Validar
festival (M74) sin picos [C] -> no medible en headless".

## 2. Hueco real que se cerro

`scripts/performance/validate_budget.gd` sabe validar una `medicion` contra
`data/performance/budgets.json`, pero **no existia ningun productor de esa medicion en el
repo**: el unico llamador era el propio validador, con un diccionario escrito a mano
(L60-64). Y la afirmacion "no medible en headless" nunca se habia probado metrica por metrica.

Medido ademas: `BudgetProfile.begin_section()` tiene **0 llamadores** fuera de
`scripts/performance/` (solo `bench_recorder.gd`, que es una escena de banco, y su test) y
`BudgetProfile` **no figura en `project.godot`** como autoload. O sea: en una corrida real
las 7 categorias de ms valen **0 por construccion**. Un productor naif que las reportara
habria dado un "0 ms en todo" que `_validar_medicion` **aprueba** -> falso verde perfecto.

## 3. Entregado (2 archivos nuevos + 1 artefacto de medicion)

### `game/isla-ancestral/scripts/performance/medicion_runtime_m61.gd` (NUEVO, 8.792 B)
Logica pura (`RefCounted`, **sin `class_name`** por trampa 123; se carga por `preload`).
Separa **tres** estados, que es lo que faltaba:

- `MEDIBLE`: contador del engine vivo en headless (`objetos_mundo`, `nodos`,
  `particulas_simultaneas`).
- `CIEGO_HEADLESS`: el contador existe pero el renderer dummy lo deja en 0 (`draw_calls`,
  `primitivas`, `vram_mb`, `overdraw`, `gpu_ms`, `frame_ms`).
- `CIEGO_SIN_INSTRUMENTAR`: no hay instrumentacion en produccion (las 7 categorias de ms).

Reglas duras implementadas:
- clave **desconocida** -> `CIEGO_SIN_INSTRUMENTAR` (fail-closed; nunca MEDIBLE);
- `es_medicion_vacia()`: dict vacio, todo ceros, o solo claves ciegas -> el veredicto es
  **3 (CIEGO)**, nunca 0;
- `comparar()` compara **solo** las medibles, con la misma convencion `<clave>_max` de
  `validate_budget._medicion_dentro_limites`; las ciegas **nunca** cuentan como "dentro";
- `motivo(clave)` con motivos especificos donde el generico mentiria.

### `game/isla-ancestral/scripts/performance/medir_runtime_m61.gd` (NUEVO, 9.626 B)
Sonda `SceneTree`: arranca `res://scenes/main_island.tscn`, muestrea 90 frames con
**watchdog de reloj de 30 s**, y produce la medicion. Incluye **calibracion propia**: lee
los contadores antes y despues de agregar la escena, de modo que si el conteo de nodos
crecio y `draw_calls` siguio en 0, queda **probado en esa corrida** que el contador de
render esta muerto headless (se declara CIEGO en lugar de reportar un 0 que parece limpio).

Exit: 0 = subconjunto medible dentro de limites (cobertura informada) - 1 = una clave
medible excede su limite - 3 = CIEGO (nada medido / escena no arranco).

### `game/isla-ancestral/out/medicion_m61.json` (artefacto, 804 B)
Evidencia volcada por la corrida real (ver 4).

### `game/isla-ancestral/tests/test_m61_medicion_runtime.gd` (NUEVO, 14.470 B)
Suite de 8 bloques (A-H) con **guarda de 3 capas**: `_fin(nombre)` al FINAL del cuerpo de
cada bloque (no en el runner), `_verificar_marcadores()` que nombra los bloques que no
cerraron, `CHECKS_MINIMOS` **medido** y `_summary()` diferido en un `call_deferred`
separado. Se agrego ademas un **watchdog de 90 s**: si un SCRIPT ERROR aborta `_correr()`
antes del `call_deferred` final, el arbol quedaria vivo y la suite colgaria (EXIT 124, que
parece verde). El watchdog garantiza resumen y exit != 0.

## 4. Evidencia medida

### Sonda de runtime (corrida real, `out/m61_probe_run2.log`)
```
[PROBE] frames=90 muestras=90 | nodos: 142 -> 2419 (delta 2277) | nodos3d en escena: 541
[PROBE] draw_calls: 0 -> 0 | primitivas: 0
[PROBE] calibracion: contador de draw_calls VIVO en headless = NO (renderer dummy)
[PROBE] proxy declarado: objetos_mundo = Node3D del arbol de la escena (541);
        nodos = OBJECT_NODE_COUNT del engine (2419, incluye UI y autoloads)
[PROBE] emisores de particulas: 8 detectados, 0 emitiendo, 0 particulas
[PROBE] OK PARCIAL: el subconjunto MEDIBLE esta dentro de limites (cobertura 12%; NO cierra el gate M61)
=== FIN PROBE M61: exit 0 ===
```

Lectura:
- `objetos_mundo` = **541** Node3D <= 1000 (`objetos_mundo_max`) -> dentro.
- `particulas_simultaneas` = **0**, pero con **8 emisores detectados y 0 emitiendo** -> el
  0 es interpretable (no hay emisores activos en boot), no un contador ciego.
- `draw_calls` = **0 con 541 Node3D y 2419 nodos** -> contador **CIEGO** headless, probado
  en la propia corrida.
- Cobertura: **12%** del mapa (2 de 17 claves con valor != 0). El probe NO cierra el gate
  M61 y lo dice.

### Suite (`out/m61_suite_v3_{1,2,3}.log`)
**59 checks / 0 fallos / EXIT 0 x3**, 0 SCRIPT ERROR, `CHECKS_MINIMOS = 59` **MEDIDO**.

### Regresion M61 (hermanas, todas EXIT 0)
| Suite | Resultado |
|---|---|
| `tests/test_m61_normas_performance.gd` | 88 checks / 0 fallos |
| `tests/test_m61_allocations_hotloop.gd` | 8 checks / 0 fallos |
| `scripts/performance/test_budget_profile.gd` | 0 fallos |
| `scripts/performance/validate_budget.gd` | 0 fallos |

Total M61: 59 + 88 + 8 = **155 checks / 0 fallos**.

### Guardian probado EN ROJO (4 sondas, restauracion byte-exacta por sha256)
| Sonda | Inyeccion | Resultado | Restaurado |
|---|---|---|---|
| S1 | `es_medicion_vacia()` -> `return false` | EXIT 1, **7 fallos** (C + F) | sha `5108bfba0d2a` OK |
| S2 | `clasificar()` -> `MEDIBLE` para desconocidas | EXIT 1, **6 fallos** (A + B + C) | sha `5108bfba0d2a` OK |
| S3 | `CHECKS_MINIMOS = 999` | EXIT 1, "solo 59 checks ejecutados (minimo 999)" | sha `1f3b3a0374b9` OK |
| S4 | aborto de runtime al inicio del bloque E | EXIT 1, nombra **E, F, G, H** + watchdog + piso | sha `1f3b3a0374b9` OK |

## 5. Defecto propio encontrado y corregido en la misma vuelta

La **1.a** corrida del probe dio **`VIOLA objetos_mundo=2417 > 1000`**. Era un **falso
positivo mio**: habia mapeado `objetos_mundo` a `Performance.OBJECT_NODE_COUNT`, que cuenta
**todos** los nodos del engine (UI, autoloads incluidos). `objetos_mundo_max` es un limite
de **objetos del mundo**, y el arbol de la escena tiene **541** Node3D. Se corrigio el mapeo
a `Node3D del arbol de la escena`, se dejo `nodos` como metrica separada (sin limite
declarado -> se informa como AVISO) y el proxy quedo **declarado en el informe y en el JSON**.
Regla que refuerza: un limite sin definicion escrita (`objetos_mundo` no esta definido en
`03-Diseno.md` ni en `04-Codigo.md`, solo el numero 1000) invita a comparar peras con manzanas.

Segundo defecto propio: el `motivo` generico de `CIEGO_HEADLESS` decia "el renderer dummy
deja el contador en 0", pero `frame_ms` **no da 0** (medido: pico de **772,9 ms** en el
frame de boot, dominado por generacion de mundo). Se agrego `motivo(clave)` con motivos
especificos y una asercion que impide que el motivo de `frame_ms` vuelva a mentir.

## 6. Hallazgos para el director (no tocados)

1. **`Totales` de M61 stale**: dice 118/8/22, el cuerpo tiene **146/1/1**. Es el **tercer**
   caso del mismo patron (M01 `dd6fb70`, M01 linea de totales, M61 `a7a3a6b`): commits de
   preservacion que flipean items sin re-sincronizar la linea de totales. El verificador
   `verificar_checklist.py` **no lo ve** porque compara contra su propio diccionario.
2. **Fila 61 del GLOBAL** dice 118/148 (mismo stale). Archivo protegido -> pedido.
3. **`objetos_mundo_max` (1000) no tiene definicion escrita**: no esta en `03-Diseno.md` ni
   en `04-Codigo.md`, solo el numero en `budgets.json`. Sin definicion, cualquier medicion
   es discutible. Pedido: fijar la definicion (Node3D del mundo? instancias de contenido?).
4. **Las 7 categorias de ms son inmedibles hoy por falta de instrumentacion**, no por
   limitacion de headless. `BudgetProfile` existe y funciona, pero no es autoload y nadie
   llama `begin_section()` en produccion. Cablearlo (o declarar que el gate de categorias
   queda sin efecto) es decision del director: **cambia la semantica del gate de M61**.
5. **`draw_calls` y todo el bloque GPU/VRAM no son medibles en `--headless`** (renderer
   dummy). Cualquier gate de RF5/RF6 necesita corrida con ventana o hardware: declararlo.
6. **El item L221 (festival M74)** puede ahora medirse **por cantidad** (`particulas_simultaneas`
   contra 500) aunque el frame time siga siendo ciego: el conteo ya es posible con esta
   sonda. Requiere que M74 exponga un disparador del festival en headless.

## 7. Limites de esta vuelta

- **0 flips aplicados** (2 propuestos: L221 -> `[?]` con justificacion medida y nota de que
  la cantidad SI es medible; y `Totales` 118/8/22 -> 146/1/1). Los aplica el director.
- **0 commits / 0 push.** Archivos nuevos sin trackear: 3 `.gd` + `out/medicion_m61.json`.
- **No se toco** `05-Checklist.md` de M61, `CHECKLIST-GLOBAL.md`, `quality.yml`,
  `AGENTS.md`, `project.godot`, ni codigo de otros duenos (M07/M74).
- Numeracion: log **2232** (pool), canal **439** = max(archivos)+1. El head del pool del
  canal sigue en **423** (desincronizado por 4.a vuelta consecutiva; no se toca).
- Encoding verificado por bytes: los 3 `.gd` y el `.json` son **UTF-8 sin BOM, LF puro,
  0 CR, 0 NUL, 0 U+FFFD**. Los no-ASCII son solo `-` y `-` (mismo estilo que
  `validate_budget.gd`).
