**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-19 (Log 1094)

# 07-Resultados-Testings.md — Módulo 62: Memoria

> Iter. 3 (Log 1094). Todas las cifras de este documento salen de una corrida real, no de una
> estimación. Donde algo no se probó, se dice.

## 1. Estado final de las suites

| Suite | Checks | Fallos | Salida | Determinismo (×3) |
|---|---|---|---|---|
| `test_memoria_m62.gd` | 27 | 0 | 0 | idénticas |
| `test_enforcement_m62.gd` | 47 | 0 | 0 | idénticas |
| `test_pool_iter2.gd` | 25 | 0 | 0 | idénticas |
| `test_memoria_m62_iter3.gd` | 133 | 0 | 0 | idénticas |
| `test_m62_liberacion.gd` (iter. 4) | 15 | 0 | 0 | idénticas (×5) |
| `test_memoria_m62_iter5.gd` (iter. 5) | 60 | 0 | 0 | idénticas (×3) |
| `generar_budgets.gd -- --check` | 20 | 0 | 0 | sha256 `872f9321bc61ab21` en 2 escrituras |

**Total: 307 checks de código, 0 fallos.** El conteo se compara sobre la secuencia de líneas
`[OK]`/`[FAIL]` **normalizada**, no sobre la salida cruda: la salida cruda trae timestamps de sesión y
duraciones, y compararla entera daría «0 idénticas» con la suite perfectamente determinista.

`CHECKS_MINIMOS` de cada suite se fijó con la salida real de estas corridas (133, 60, 47, 27, 25), no
con una estimación.

## 2. La primera corrida de `test_memoria_m62_iter3.gd` encontró 2 defectos reales

La suite se escribió y se corrió **antes** de darla por buena. Resultado de esa primera corrida:

- **705** `SCRIPT ERROR: Out of bounds set index '0' (on base: 'PackedFloat32Array')`
- **7** `ERROR: Can't use get_node() with absolute paths from outside the active scene tree.`
- **4** `[FAIL]` — todos en el bloque D (ventana circular)

Ambos eran defectos **del código de producción**, no del test:

1. `_registrar_muestra()` escribía en `_muestras` dando por hecho que `_ready()` había corrido el
   `resize()`. Un monitor instanciado suelto (`load(...).new()`, que es como lo hacen los runs
   `--script`) nunca dispara `_ready()` → array vacío → el `SCRIPT ERROR` **abortaba la función** y
   `_muestras_n` quedaba en 0. Arreglado con dimensionado **perezoso** (`_asegurar_ventana()`), que
   además sólo toca el array una vez, así que sigue sin haber allocs por frame.
2. `_log_m62()` y `_registrar_servicio()` resolvían `/root/GameLogger` y `/root/ServiceRegistry` con
   ruta absoluta desde un nodo **fuera del árbol** → error de Godot. Arreglado con guarda
   `is_inside_tree()`.

## 3. Hallazgo grave: una suite entera muerta que reportaba verde

`test_enforcement_m62.gd` (iter. 2) **no verificaba nada y salía con código 0**.

Medido, no inferido:

```
SCRIPT ERROR: Trying to assign value of type 'RefCounted' to a variable of type 'Node'.
   at: _test_registros (res://scripts/rendimiento/memoria/test_enforcement_m62.gd:29)
   at: _test_enforcement_niveles (res://scripts/rendimiento/memoria/test_enforcement_m62.gd:46)
=== TEST M62 ENFORCEMENT: 0 fallo(s) ===   → salida 0
```

Causa: `var budget: Node = load("…/budget_registry.gd").new()` cuando los registries son `RefCounted`.
La asignación tipada abortaba las **dos** funciones de verificación (0 checks ejecutados). La tercera
función sí corría, pero sus 3 aserciones eran `_check(true, "…sin crash")` → **infalsificables**.
Sumado a que el resumen sólo contaba fallos (sin contador de checks, sin piso y sin watchdog), la
suite llevaba desde el 2026-09-01 diciendo verde sin comprobar nada. Además llamaba a
`monitor._muestrear()` (renombrado a `muestrear_ahora()`) y a `_enforcement()` con 1 argumento
(ahora recibe 2).

**Reescrita**: 47 checks con aserciones que pueden fallar. Para poder asertar la alarma de pico se le
agregó un contador observable (`alarmas_pico()`): antes sólo hacía `push_warning` y era imposible
verificar desde un test.

También se corrigieron **2 aserciones infalsificables** en `test_pool_iter2.gd`
(`a.is_processing() == true or true` y `conns_antes >= 0`) y se reemplazó `emisor.free()` de un nodo
que seguía **dentro del pool** por un drenado real.

## 4. Hallazgo de datos: el test consagraba el bug

`data/rendimiento/budgets.json` había divergido del diseño §2 en **los 8 sistemas de los 3 presets**.
Las sumas reales eran **1664 / 2112 / 2560** contra las declaradas **1500 / 2000 / 2500**.

El gate nuevo `generar_budgets.gd -- --check` lo detectó **antes** de regenerar, con la lista exacta
de discrepancias (p. ej. `"texturas: disco=384 diseño=250"`) y salida 1. Ese es el requisito para
confiar en un gate: que **discrimine**.

Peor que la divergencia: `test_memoria_m62.gd` **asertaba el valor divergente**.

```
- _check("tope media voxel = 640", b.tope_de("voxel") == 640, …)   # HEAD tenía 640
+ _check("tope media voxel = 650", b.tope_de("voxel") == 650, …)   # diseño §2
```

El dataset estaba mal **y** el test afirmaba el valor malo: dos errores que se cancelaban y daban
verde. Se corrigió la aserción y se agregó una guarda contra la divergencia silenciosa (la suma de
topes debe dar el total declarado del preset).

## 5. Guardián probado POR INYECCIÓN (4 de 4 suites)

En cada suite se insertó una falla temporal (índice fuera de rango en un `PackedFloat32Array`) que
produce `SCRIPT ERROR` y aborta la función. La copia se borró después.

| Suite | Dónde se inyectó | Checks | Fallos | Salida | ¿Nombró el bloque? |
|---|---|---|---|---|---|
| `test_memoria_m62_iter3.gd` | bloque H | 133 → **114** | 2 | 1 | sí: «el bloque H NO se ejecutó» |
| `test_memoria_m62_iter3.gd` | `_run()` (tras el bloque A) | 133 → **21** | 10 | 1 | sí: nombró B, C, D, E, F, G, H, I, J |
| `test_enforcement_m62.gd` | bloque C | 47 → **36** | 2 | 1 | sí: «el bloque C NO se ejecutó» |
| `test_memoria_m62.gd` | `_run()` (tras el bloque budget) | 27 → **11** | 4 | 1 | sí: nombró pool, unload, monitor |
| `test_pool_iter2.gd` | bloque C | 25 → **22** | 2 | 1 | sí: «el bloque C NO se ejecutó» |

Las 3 capas quedaron probadas: el bloque ausente se **nombra**, el conteo **cae bajo el piso** y
`_summary()` **corre igual** cuando `_run()` muere entero (caso 2 y 4). Un guardián probado sólo en
verde no prueba nada.

## 6. Gate de CI

`quality.yml` → job `test-suite`, con el patrón `FAIL=0` + `|| FAIL=1` + `exit $FAIL` (**sin `|| true`**):

```
godot --headless --script scripts/rendimiento/memoria/test_memoria_m62.gd 2>&1 || FAIL=1
godot --headless --script scripts/rendimiento/memoria/test_enforcement_m62.gd 2>&1 || FAIL=1
godot --headless --script scripts/rendimiento/memoria/test_pool_iter2.gd 2>&1 || FAIL=1
godot --headless --script scripts/rendimiento/memoria/test_memoria_m62_iter3.gd 2>&1 || FAIL=1
godot --headless --script scripts/rendimiento/memoria/generar_budgets.gd -- --check 2>&1 || FAIL=1
```

Antes de iter. 3 **ninguna suite de M62 estaba en el CI**: se verificó por búsqueda y las 3 suites
existentes daban 0 coincidencias. El módulo no tenía gate.

Los 5 comandos se corrieron **con el mismo directorio de trabajo que usa el CI**
(`cd game/isla-ancestral`, sin `--path`) y los 5 dieron salida 0. El YAML se validó con un parser
(10 jobs) y el bloque de M62 no aporta ningún `|| true`.

**Deuda reportada, no corregida:** el archivo tiene **12 `|| true`** pre-existentes que silencian
tests de otros módulos (líneas 130-142, 202, 212, 291). Es un falso verde heredado, ajeno a M62.

## 7. Lo que NO se probó (honestidad obligatoria)

- **Play Mode** (checklist §N): sesión de 30 min con drift ≤ 5 %, teleport extremo ×10, 500 bloques
  excavados y regenerados, cambio de bioma de audio, preset Baja con 4 GB de RAM.
- **Baselines de memoria** (§L): menú < 600 MB, spawn < 1600 MB, horizonte < 2200 MB, subterráneo
  < 2000 MB, tormenta ≤ 2500 MB.
- **Integración real con M08/M09/M41-M44/M63**: los contadores por sistema están implementados pero
  nadie reporta todavía, así que `total_consumo_mb()` sigue en 0 fuera de los tests.
- **QA cruzado §21.8**: pendiente, y **no puede hacerlo el autor**.

## 8. Iteración 4 (Log 1112): presupuesto de liberación y auditor de arquitectura

### 8.1 `test_m62_liberacion.gd` — 15 checks, 0 fallos, ×5 idénticas

Metodología anti-trampa-78: **rondas intercaladas** (se miden las 2 variantes en cada ronda) y
**mínimo por variante**; luego se corre la suite 5 veces y se comprueba que el signo no cambia.

| Variante | Objetos | Payload | Pico por objeto (L191, límite 3 ms) | Lote completo (RN2, límite 50 ms) |
|---|---|---|---|---|
| ligera | 2048 | 4 KB (8 MB) | 0,279 – 0,492 ms | 2,1 – 3,4 ms |
| pesada | 256 | 256 KB (64 MB) | 0,414 – 0,448 ms | 3,9 – 5,8 ms |

RN6 se satisface con margen: el pico de **una** operación (≤ 0,492 ms) está muy por debajo de un
frame a 60 FPS (16,67 ms). **Huérfanos**: base 0, estable en 5 muestras consecutivas, 128 nodos sin
padre contados (0 → 128) y liberados (128 → 0, sin leak).

### 8.2 Tres correcciones que hizo la medición (no la revisión)

1. **La hipótesis sobre A2 era falsa.** Se creía que una referencia a un autoload declarado después
   devolvía null desde `_ready()`. Banco de pruebas propio (2 autoloads, Godot 4.7.2 headless):
   desde `_init()` → null + `ERROR` fuerte; desde `_ready()` → **encontrado**. Godot ya instanció
   todos los autoloads antes del primer `_ready()`. Se documenta para que nadie «arregle» un crash
   inexistente; ver BUG-069.
2. **El auditor tenía 4 defectos propios**, cazados por su selftest en rojo.
3. **Una aserción de la suite era una suposición**: «2048 objetos chicos cuestan más en total que 256
   grandes» → medido **al revés** (2346 µs vs 4270 µs). Y comparar **picos** es inestable (corrida 3:
   492 µs > 448 µs); la señal estable es el **total**.

### 8.3 Guardián probado POR INYECCIÓN (5.ª suite)

Inyección: `var _x: Node = load("res://.../unload_policy.gd").new()` al principio de `_run()`
(asignar un `RefCounted` a un `Node` aborta la función). Resultado:

```
SCRIPT ERROR: Trying to assign value of type 'RefCounted' to a variable of type 'Node'.
   at: _run (.../_tmp_inject_m62.gd:109)
  [FALLO] los 4 bloques se completaron — no terminaron: ["A", "B", "C", "D"]
  [FALLO] solo 1 checks ejecutados (minimo 15)
-- checks por bloque: {  }
=== Resumen M62 liberacion: 1 checks, 2 fallos ===
RC=1
```

Las 3 capas funcionan: el `SCRIPT ERROR` **aborta la función** (por eso sus checks no corren y no
fallan), `_summary()` **nombra** los 4 bloques que no terminaron, y el **piso** salta. Además
**termina con exit 1 sin colgarse**, que es lo que se quería verificar del `call_deferred` separado.
El archivo inyectado y su `.uid` se borraron al terminar.

### 8.4 Auditor estático: 17 checks de selftest, y 0 hallazgos en carga síncrona

- **Grupo B (carga síncrona): 0 hallazgos** en **800 archivos `.gd`** y **79 callbacks por frame**.
- **Grupo A:** 111 autoloads, 213 referencias explícitas, **2 componentes cíclicas**, **9 referencias
  fuera de orden**, **1 autoload duplicado**. Escalados como **BUG-068** (duplicado, defecto real
  medido) y **BUG-069** (ciclos + orden, deuda arquitectónica sin fallo de runtime medido).

### 8.5 Reproducir

```bash
# auditor (herramienta de repo; se prueba en rojo primero)
python scripts/auditar_arquitectura_m62.py --selftest
python scripts/auditar_arquitectura_m62.py
# suite headless
"<godot_console>" --headless --path game/isla-ancestral \
  --script res://scripts/rendimiento/memoria/test_m62_liberacion.gd
```

## 9. Iteración 5 (Log 1187): handshake con M63 y edge cases de §K

### 9.1 `test_memoria_m62_iter5.gd` — 60 checks, 0 fallos, ×3 idénticas

7 bloques (A–G), 0 SCRIPT ERROR propio:

- **A. Handshake con M63 (L157/L160):** un recurso marcado «en carga» por el 63 **no se descarga**;
  el veto se cuenta en `diferidos_ultimo_lote()` y el candidato **no sale de la cola**. Al terminar
  la carga del 63, el 62 sí lo descarga.
- **B. Enforcement respeta el handshake:** el nivel 3 (duro) descarga el libre pero **deja en cola**
  el que el 63 está cargando.
- **C. Cola de transición (L172/L173):** el 2.º cambio de escena **encola** (no descarga dos veces);
  al terminar arranca el encolado; `cancelar()` **drena** la cola y cuenta la cancelación.
- **D. Región rápida (L168):** con candidatos pendientes, el cambio de región **fuerza** la
  liberación y cuenta en `liberaciones_forzadas()`.
- **E. Audio diferido (L171):** un banco pedido **durante** una descarga se difiere y se reproduce al
  terminar; otro banco no se ve afectado.
- **F. Atlas LRU con log (L167):** evicta por uso más antiguo, respeta el tope y no toca la reciente.
- **G. Determinismo (RN9/L113):** dos monitores con la misma entrada → mismo nivel y **mismo orden**
  de descarga.

### 9.2 La 1.ª corrida falló — y el guardián lo dijo

Escribí `mm.descastes_por_carga()` (transposición) cuando el método real es `descartes_por_carga()`.
El `SCRIPT ERROR` **abortó el bloque B** y el resumen imprimió
`[FAIL] el bloque B NO se ejecutó (posible SCRIPT ERROR que abortó la función)` → `58 checks, 1 fallos`,
EXIT 1. Corregido el typo: **60 checks, 0 fallos**. No hubo «0 fallos» falso: la capa 1 (bloques
nombrados) hizo su trabajo.

### 9.3 Guardián probado EN ROJO: 5 de 5 sondas

| Sonda | Inyección | Medido |
|---|---|---|
| A | aserción falsa | `61 checks, 1 fallos` → EXIT 1 |
| B | `return` al inicio de `_run()` | `7 checks, 8 fallos` → EXIT 1 (**exit real del proceso verificado = 1**) |
| C | piso +1 (61) | `60 checks, 1 fallos` → EXIT 1 |
| D | `return` al inicio del bloque C | `46 checks, 2 fallos` → EXIT 1 |
| E | `_fin("A")` suprimido | `61 checks, 1 fallos` → EXIT 1 |
| — | control sin mutar | `60 checks, 0 fallos` → **EXIT 0** |

### 9.4 Regresión y auditoría

- 5 suites previas tras tocar `memory_monitor.gd`/`unload_policy.gd`: `27+47+25+133+15 = 247`, 0 fallos, ×3.
- `auditar_arquitectura_m62.py`: **0 hallazgos nuevos**, **0 violaciones B1/B2/B3** en el código nuevo;
  `--selftest` en verde.
- `validar_workflows.py` cazó la suite nueva como **no versionada** (trampa 98: verde en disco, rojo en
  CI) — resuelto al commitearla. Quedan 5 `DEUDA_CONOCIDA` obsoletas **ajenas** (dueño M64), reportadas
  y **no tocadas**.

### 9.5 Reproducir

```bash
"<godot_console>" --headless --path game/isla-ancestral \
  --script res://scripts/rendimiento/memoria/test_memoria_m62_iter5.gd
```
