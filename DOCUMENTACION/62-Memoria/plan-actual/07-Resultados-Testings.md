**Modelo:** DeepSeek-V4.1-Flash — DS-V4.1-Flash-Opencode (último modificador)
**Plataforma:** OpenCode
**Fecha:** 2026-10-18 (Tanda 60 — sección 12; Log 1998)

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
| `test_m62_pureza_save.gd` (iter. 6) | 59 | 0 | 0 | idénticas (×2) |
| `test_m62_leaks_teleport.gd` (iter. 7, T-D9) | 21 | 0 | 0 | idénticas (×3) |
| `generar_budgets.gd -- --check` | 20 | 0 | 0 | sha256 `872f9321bc61ab21` en 2 escrituras |

**Total: 387 checks de código, 0 fallos** (366 de las 7 suites previas + 21 de la suite nueva de T-D9). El conteo se compara sobre la secuencia de líneas
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

## 10. Iteración 7 (T-D9, Log 1325): test de leaks con teleport ×10

### 10.1 `test_m62_leaks_teleport.gd` — 21 checks, 0 fallos, ×3 idénticas

Cierra **L105** y **L143**. Headless, sin mundo: cada "teleport" deja atrás los chunks del borde como
**candidatos a descarga** en la `UnloadPolicy`. Si la política los **retiene** después de
`ejecutar_descarga()`, los `Resource` quedan vivos → fuga.

| Bloque | Qué prueba | Checks |
|---|---|---|
| A | **Sonda del medidor** (control positivo): crear 64 nodos sube el contador de huérfanos; crear 256 `Resource` sube `objetos_vivos()`. Sin esto, la igualdad antes/después sería vacua. | 6 |
| B | **Teleport ×10**: 10 ciclos × 24 chunks = 240 `Resource`. Tras `ejecutar_descarga()`: **0 retenidos** (WeakRef) y `objetos_vivos` **delta 0**. | 7 |
| C | **Pool**: `liberar_todo()` libera de verdad (los 16 nodos quedan **encolados** para `queue_free`). Caza la regresión del defecto "solo vaciaba los arrays". | 6 |
| D | **Guardián EN ROJO por inyección**: se deja una fuga a propósito (candidatos nunca descargados) y se exige que el detector la VEA (8 retenidos → 0 tras descargar). | 2 |

### 10.2 Medición

```
10 ciclos de teleport x 24 chunks = 240 Resource
objetos_vivos: base=3618  fin=3618  delta=0
retenidos por la politica tras ejecutar_descarga(): 0
cola maxima observada: 24 candidatos (== CHUNKS_POR_TELEPORT)
```

`queue_free()` es **diferido** (medido: el holder sigue con 16 hijos en el mismo frame) → el bloque C
comprueba que están **encolados**, no que ya desaparecieron. Afirmar "holder sin hijos" ahí sería medir
el frame equivocado. (Esa fue la 1.ª corrida en rojo: `21 checks, 1 fallo`.)

### 10.3 Guardián probado EN ROJO (2 inyecciones)

| # | Inyección | Resultado |
|---|---|---|
| 1 | Omitir los bloques C y D | `15 checks, 3 fallos` → EXIT 1 (nombra C y D + piso 21→15) |
| 2 | Error de **runtime** en el bloque B (llamada sobre instancia nula) | `SCRIPT ERROR` aborta B; el resumen diferido **igual corre**, nombra B, `15 checks, 2 fallos` → EXIT 1 |
| — | control sin mutar | `21 checks, 0 fallos` → **EXIT 0** |

### 10.4 Regresión

- 7 suites previas: `27+47+25+133+15+60+59 = 366`, 0 fallos. + la nueva = **387 / 0**.
- `auditar_arquitectura_m62.py`: **0 hallazgos nuevos** (874 → 875 `.gd` revisados), `--selftest` en verde.
- `generar_budgets.gd -- --check`: 20/0.
- **NO cableada a `quality.yml`** (no lo toqué: es de s2/director). Queda **pendiente de wiring**.

### 10.5 Alcance (lo que este test NO prueba)

- El teleport con **mundo real** (M08/M63) y el frame con render: sigue siendo **Play Mode** (**L213 no se cierra**).
- El RSS real del proceso: se mide el **conteo de objetos** y la **retención de recursos**, no
  `OS.get_static_memory_usage()` bajo carga de mundo.

### 10.6 Reproducir

```bash
"<godot_console>" --headless --path game/isla-ancestral \
  --script res://scripts/rendimiento/memoria/test_m62_leaks_teleport.gd
```

## 11. Tanda 59 (2026-10-18, DS-Opencode, Log 1997): L100 — texturas de región se liberan al salir

- **Objetivo:** cerrar por medición el ítem `[ ]` L100 del checklist ("Texturas de región se liberan al salir de la misma (con M63 y M09)"), señalado como pendiente de cableado en la auditoría de 2026-10-15.
- **Suite nueva:** `test_m62_texturas_region.gd` (**33 checks**) con los autoloads REALES `StreamManager` + `MemoryMonitor` vía `--headless --script`:
  - **A (14):** región en uso — 3 texturas encoladas por el contrato real M63→M62 (`registrar_chunk`), veto por carga (`avisar_cambio_region` no libera en uso), sin envejecido dentro del radio.
  - **B (11):** salir de la región — `marcar_envejecidos` ×2 → el LRU de M63 libera, `avisar_cambio_region` fuerza el drenaje, cola M62 vacía, **0/3 texturas sobreviven (WeakRef)** y `objetos_vivos` delta 0 (4477→4477).
  - **C (7):** `evictar_atlas` elige la región vieja por LRU (75 MB → 2; hasta 40 → 1; max_entradas manda; 0 = no-op) + señal `recurso_descargado` ×3 (atlas, 75/40/40).
- **Resultado:** 33 checks, 0 fallos, **×3 corridas idénticas** (exit 0). Evidencia: `out/tanda59/suite_run{1,2,3}.log`.
- **Guardián de 3 capas probado EN ROJO (2 inyecciones):** subir el piso → `[FALL] solo 33 (mínimo 40)` + exit 1; abortar B con un SCRIPT ERROR real → el resumen nombra **B** + piso + exit 1 (C corre igual: resumen diferido). Evidencia: `out/tanda59/suite_rojo_piso.log`, `suite_rojo_aborto.log`.
- **Prelación empírica:** sonda `probe_unreference.gd` (out/tanda59/probe1.log): `unreference()` sin `reference()` previo (`stream_manager.gd` L350) es SEGURO en ambos órdenes — nunca antes ejercitado (las suites viejas registran chunks sin recurso).
- **Alcance (lo que NO prueba):** el llamador de gameplay (M09/M27) no existe: el cableado de la salida de región sigue siendo deuda de esos módulos. No cubre Play Mode con mundo real.
- **Reproducir:**

```bash
"<godot_console>" --headless --path game/isla-ancestral \
  --script res://scripts/rendimiento/memoria/test_m62_texturas_region.gd
```

## 12. Tanda 60 (2026-10-18, DS-Opencode, Log 1998): L132 — descarga dura al 95% (atlas fuera de pantalla + bancos viajeros)

- **Objetivo:** cerrar por medición el ítem `[ ]` L132 del checklist ("Descarga dura al 95%: atlas fuera de pantalla y bancos de biomas viajeros"), la pata del diseño §3 que faltaba: nivel 3 "sin excepción" con viajeros y atlas.
- **Suite nueva:** `test_m62_duro95.gd` (**39 checks**) con el autoload REAL `MemoryMonitor` vía `--headless --script`:
  - **A (14):** umbrales 80/90/95 **derivados del presupuesto vivo** (hoy 2032 = 2000 del preset + 32 de `ia_npc` registrado en runtime): `nivel_para` exacto en el umbral y un MB debajo; nivel 1 no ejecuta; nivel 2 drena el tope del preset media (12) e idempotente; nivel 3 **re-aplica** y vacía la cola.
  - **B (11):** 3 bancos viajeros (60/50/40 MB; dist 60/50/40) + 3 locales + 1 vetado por el handshake M63: orden por distancia desc [60,50,40,10,7,6,5]; el duro drena los 6 libres (168 MB) y el vetado queda contado; al `avisar_carga_terminada`, el próximo duro lo drena (100 MB).
  - **C (7):** `evictar_atlas` LRU: `fuera_1/2/3` (uso viejo) evictadas en orden (60 MB ≥ 50; señal `atlas`), `pantalla_90` (90 MB, uso reciente) intacta (el tamaño no decide); `hasta_mb=0` es no-op; `max_entradas=1` manda; entradas originales sin mutar.
  - **D (7):** audio viajero: banco pedido en descarga = `diferido` (y listado), tras `terminar_descarga_audio` = `reproducir`; determinismo del duro (mismos 6 objetos / 168 MB).
- **Resultado:** 39 checks, 0 fallos, **×4 corridas idénticas** (exit 0). Evidencia: `out/tanda60/suite_run{2,3,4,5}.log`.
- **Iteración capturada:** `suite_run1.log` (4 fallos) = pin con umbral hardcodeado 2000 vs presupuesto vivo 2032 → derivación con `ceil`.
- **Guardán de 3 capas probado EN ROJO:** piso artificial 999 → `[FALL] solo 39 checks ejecutados (mínimo medido en verde: 999)` + exit 1 (`out/tanda60/guardian_rojo.log`); suite restaurada byte-idéntica (sha256 `9f2cb1e4c2362daf471eef5d8743095824acf75b09027e15a23df6f24ea632ab`).
- **Alcance (lo que NO prueba):** los feeds de producción (tabla de atlas M09/M63; registro de bancos al viajar M42) no existen aún — deuda de esos dueños (en el backlog: ítem 112). No cubre Play Mode con mundo real.
- **Reproducir:**

```bash
"<godot_console>" --headless --path game/isla-ancestral \
  --script res://scripts/rendimiento/memoria/test_m62_duro95.gd
```

## 13. Tanda 61 (2026-10-18, DS-Opencode, Log 2001): L137 — buffers de VoxelTools por chunk se liberan al descargar

- **Objetivo:** cerrar por medición el ítem `[ ]` L137 del checklist ("Buffers de VoxelTools por chunk se liberan al descargar (sin acumulación)"), de la sección H (integración M08).
- **Prelación empírica (específica del payload):** sonda `probe_voxelbuffer_t61{,b}.gd` (out/tanda61/probe{1,2}.log): `VoxelBuffer` (voxel-tools) es **RefCounted** (NO Resource), `create(64,64,64)` OK, WeakRef muere al soltar la última referencia y `objetos_vivos()` (OBJECT_COUNT) lo cuenta exacto (4478 → 4486 → 4478 con 8 buffers de prueba).
- **Cambio de producción (ensanche):** las firmas de M62 tipadas `Resource` pasaron a `RefCounted` para admitir el payload real: `unload_policy.gd marcar_candidato()`; `memory_monitor.gd esta_en_carga() / _puede_descargar() / registrar_candidato_descarga()` (notas T61 en headers). Retrocompatible; M63 intacto (`registrar_chunk` sigue `Resource`; `avisar_carga_iniciada/terminada` quedan `Resource`).
- **Suite nueva:** `test_m62_voxel_buffers.gd` (**19 checks**) con los autoloads REALES `MemoryMonitor` + `StreamManager` vía `--headless --script`:
  - **A (5):** sonda del medidor (control positivo anti-vacuo) — 8 `VoxelBuffer` 64³ reales contados por `objetos_vivos` (+8), mueren al soltar (0/8), base restaurada.
  - **B (5):** 12 buffers registrados por el contrato M62 (peso 1 = `chunk_lod0`) → drenaje (12 MB) → cola vacía → **0/12 sobreviven (WeakRef)** → sin crecimiento de `objetos_vivos`.
  - **C (3):** 5 ciclos x 10 buffers → 0/50 retenidos; `objetos_fin=4477` constante en los 5 ciclos; delta global 0 (sin acumulación).
  - **D (4):** mezcla con la vía real M63: `registrar_chunk` (Resource) + buffer directo en la misma cola → drenaje 2/2, `liberar_envejecidos` suelta el Resource → **0/2 vivos** (regresión del ensanche).
- **Resultado:** 19 checks, 0 fallos, **×3 corridas idénticas** (exit 0). Evidencia: `out/tanda61/suite_run{1,2,3}.log`.
- **Guardián de 3 capas probado EN ROJO:** piso artificial 999 → `[FALL] solo 19 checks ejecutados (mínimo medido en verde: 999)` + exit 1 (`out/tanda61/guardian_rojo.log`); suite restaurada byte-idéntica (sha256 `c9632f6e…`; sha actual tras el P.D.: `03b2c6ef…`).
- **Regresión del ensanche:** las 10 suites M62 previas + `generar_budgets.gd -- --check` → todas verdes (27/47/25/133/16/60/60/21/33/39 checks + 20 budgets; `out/tanda61/reg_*.log`).
- **Alcance (lo que NO prueba):** el cableado de M08 (crear los buffers por chunk y registrarlos vía `registrar_candidato_descarga`, junto con L134-139) sigue siendo deuda de ese módulo — `chunk_memory.gd` de M08 aparece aún como planificado (04-Codigo). El VoxelTerrain real gestiona sus buffers internos en C++ y no los expone por chunk en GDScript. Esta suite pina el contrato del 62.
- **Reproducir:**

```bash
"<godot_console>" --headless --path game/isla-ancestral \
  --script res://scripts/rendimiento/memoria/test_m62_voxel_buffers.gd
```



**P.D. (corrección de referencias de Log, misma sesión):** los headers de `unload_policy.gd`, `memory_monitor.gd` y `test_m62_voxel_buffers.gd` citaban «Log 1999» — que es el log real de Step-5-WorkBuddy (barrido de pools). El log correcto de esta tanda es **Log 2001**. El fix es de comentarios (sin cambio de código): la suite se re-corrió tras el fix → 19/0 (out/tanda61/suite_run4_postfix.log) y su sha256 pasó de `c9632f6e…` (guardián/cierre) a `03b2c6ef…` (actual). Es el único delta.

## 14. Tanda 62 (2026-10-18, DS-Opencode, Log 2004): L139 — colliders estáticos de chunks se liberan junto con la mesh

- **Objetivo:** cerrar por medición el ítem `[ ]` L139 del checklist ("Colliders estáticos de chunks descargados se liberan junto con la mesh"), de la sección H (integración M08).
- **Prelación empírica (específica del payload):** sonda `probe_collider_t62.gd` (out/tanda62/probe1.log): el collider real de chunk (`Mesh.create_trimesh_shape()`) es **ConcavePolygonShape3D** (is Resource = true, is RefCounted = true), WeakRef determinista y `objetos_vivos()` (OBJECT_COUNT) lo cuenta exacto (4480 → 4488 → 4480 con 8 formas); el combo NODO StaticBody3D + CollisionShape3D suma +8 huérfanos y `free()` los limpia.
- **Sin cambio de producción:** el payload ya viaja por la cola M62 como RefCounted desde el ensanche T61; esta tanda solo pina el contrato (no hubo edición de `unload_policy.gd` / `memory_monitor.gd`).
- **Suite nueva:** `test_m62_colliders_chunk.gd` (**21 checks**) con los autoloads REALES `MemoryMonitor` + `StreamManager` vía `--headless --script`:
  - **A (5):** sonda del medidor (control positivo anti-vacuo) — 8 `ConcavePolygonShape3D` reales (trimesh con caras) contadas por `objetos_vivos` (+8), mueren al soltar (0/8), base restaurada.
  - **B (5):** 12 pares {BoxMesh + su trimesh} registrados por el contrato M62 (peso 4 + 1 = `malla_region` + `chunk_lod0`) → drenaje (60 MB) → cola vacía → **0/24 sobreviven (WeakRef de malla y collider)** → sin crecimiento de `objetos_vivos`.
  - **C (3):** 5 ciclos x 10 pares → 0/100 retenidos; delta global 0 (sin acumulación).
  - **D (6):** evento de descarga único: mesh del chunk por la vía real M63 (`registrar_chunk`) + collider directo en la misma cola → drenaje 2/2, `liberar_envejecidos` suelta el mesh → **0/2 vivos (mueren JUNTO con la mesh)**; además, la forma NODO (StaticBody3D + CollisionShape3D) se cuenta como huérfano (+2) y `free()` del cuerpo vuelve a la base.
- **Resultado:** 21 checks, 0 fallos, **×3 corridas idénticas** (exit 0). Evidencia: `out/tanda62/suite_run{1,2,3}.log`.
- **Guardián de 3 capas probado EN ROJO:** piso artificial 999 → `[FALL] solo 21 checks ejecutados (mínimo medido en verde: 999)` + exit 1 (`out/tanda62/guardian_rojo.log`); suite restaurada byte-idéntica (sha256 `90baf14e…`).
- **Regresión:** las 10 suites M62 previas + `generar_budgets.gd -- --check` → todas verdes (47/39/21/16/60/33/27/133/60/25 checks + 20 budgets; `out/tanda62/reg_*.log`).
- **Alcance (lo que NO prueba):** el cableado de M08 (crear el collider por chunk y registrarlo vía `registrar_candidato_descarga`, junto con L134-139) sigue siendo deuda de ese módulo — `chunk_memory.gd` de M08 aparece aún como planificado (04-Codigo). El VoxelTerrain real gestiona sus colliders internos en C++ y no los expone por chunk en GDScript. Esta suite pina el contrato del 62.
- **Reproducir:**

```bash
"<godot_console>" --headless --path game/isla-ancestral \
  --script res://scripts/rendimiento/memoria/test_m62_colliders_chunk.gd
```

## 15. Tanda 63 (2026-10-18, DS-Opencode, Log 2006): L140 — sin duplicación de meshes entre M63 (streaming) y el 62 (descarga)

- **Objetivo:** cerrar por medición el ítem `[ ]` L140 del checklist (sección H, integración M08), origen RF5 de 01-Requerimientos (L54): "LRU + pool de meshes: liberar buffers voxel y colliders de chunks lejanos sin duplicar con M63".
- **Contrato pinneado (sin cambio de producción):** `stream_manager.gd registrar_chunk` ofrece el recurso UNA vez por chunk (gate `es_nuevo`, peso `chunk_lod0` = 1.0); el re-registro por frame NO re-ofrece ni infla la cola; swap bajo el mismo `chunk_id` resuelve solo la oferta vieja al drenar (el nuevo no se re-ofrece); `ejecutar_descarga` del 62 cuenta MB pero NO libera — el drop real es del dueño (`liberar_envejecidos` del M63 con `unreference`); veto de handshake §5.3: `avisar_carga_iniciada/terminada` + filtro `_puede_descargar` (opt-in; producción siempre lo pasa).
- **Suite nueva:** `test_m62_sin_duplicacion.gd` (**33 checks**) con los autoloads REALES `MemoryMonitor` + `StreamManager` vía `--headless --script`:
  - **A (7):** identidad y oferta única — 1 chunk = 1 activo + 1 oferta (MISMA instancia, sin copias: `objetos_vivos` estable); 30 re-registros → cola sigue en 1 y 1 activo.
  - **B (7):** swap — 1 activa + 1 oferta (la vieja); ventana transitoria 2/2; tras drenar el viejo muere (la oferta era su último ref) y el nuevo sigue vivo/activo; solo 1 malla viva; liberar cierra a base.
  - **C (6):** drenaje del 62 NO libera — 1 candidato; el drenaje cuenta MB y vacía la cola; el recurso sigue vivo; el 63 mantiene su entrada activa; el drop del dueño lo mata recién ahí; ciclo a base.
  - **D (6):** veto — carga declarada en ambos lados; oferta durante la carga; drenaje CON el filtro de producción `_puede_descargar` → 0 MB, diferido 1, cola intacta (log `DESCARTADA`); al terminar la carga el registro queda limpio y el drenaje consume normal; cierre limpio. Hallazgo: sin filtro el veto NO aplica (opt-in) — mismo camino que usa producción (`_enforcement`, `avisar_cambio_region`).
  - **E (5):** conservación global — 5 ciclos × 8 chunks (triple registro): 40 WeakRefs 0 retenidas; cola 0 y 0 activos; delta `objetos_vivos` 0; descargas contadas 44 ≥ 40.
- **Resultado:** 33 checks, 0 fallos, **×3 corridas idénticas** (exit 0). Evidencia: `out/tanda63/suite_run{1,2,3}.log`.
- **Guardián de 3 capas probado EN ROJO:** piso artificial 999 → `[FALL] solo 33 checks ejecutados (mínimo medido en verde: 999)` + exit 1 (`out/tanda63/guardian_rojo.log`); suite restaurada byte-idéntica (sha256 `60df8436…`).
- **Regresión:** las 10 suites M62 previas + `generar_budgets.gd -- --check` → todas verdes (47/39/21/16/60/33/27/133/60/25 checks + 20 budgets; `out/tanda63/reg_*.log`).
- **Alcance (lo que NO prueba):** el cableado de M08 (generar mallas en hilos y registrarlas por chunk, L141) sigue siendo deuda de ese módulo. Esta suite pina el contrato del 62 (idempotencia de oferta + no-duplicación + veto).
- **Reproducir:**

```bash
"<godot_console>" --headless --path game/isla-ancestral \
  --script res://scripts/rendimiento/memoria/test_m62_sin_duplicacion.gd
```

## 16. Tanda 64 (2026-10-19, DS-Opencode, Log 2007): L141 — generación de mallas en hilos (M08): resultados por cola sin copias extra

- **Objetivo:** cerrar por medición el ítem `[ ]` L141 del checklist (sección H, integración M08): "Generación de mallas en hilos (M08): resultados por cola sin copias extra".
- **Contrato pinneado (sin cambio de producción):** `encolar` con `ruta_recurso` usa `load_threaded_request`/`load_threaded_get` (hilo real, `esta_cargando` activo); la entrega es **la MISMA instancia del cache** (identidad + ruta); la ruta se cierra tras la entrega (anti-doble L158 sin residuo); peso reclamado exactamente 1 vez (delta 4.0); en la ventana de entrega el recurso va declarado (63) y registrado (62) con el veto de producción activo (`_puede_descargar = false`); `_encolar_precarga` rechaza la segunda llamada inmediata (1 sola ruta en vuelo).
- **Hallazgo del engine (documentado como E-32 en GUIA-GODOT/06-registro-errores.md):** con la descarga del 62 activa (3 patas juntas) el engine **reclama** la instancia descargada; la siguiente carga entrega una instancia **nueva limpia**; racy, pero la reclamación SIEMPRE precede a la entrega → invariante "jamás dos vivas a la vez".
- **Suite nueva:** `test_m62_hilos_cola_mallas.gd` (**33 checks**) con los autoloads REALES `MemoryMonitor` + `StreamManager` vía `--headless --script`:
  - **A (7):** cola drenada inicial; encolar malla por la cola real (en vuelo con hilo, peso 4.0 una vez); bombeo drena; UNA entrega con Mesh real; SIN COPIAS: MISMA instancia del cache (identidad + ruta); ruta cerrada; peso reclamado 1 vez y progreso 1.0.
  - **B (5):** ventana de entrega — declarado (63) + registrado (62); veto de producción activo; handshake cerrado tras la entrega; segunda entrega = MISMA instancia del ancla (sin copia); aviso al 62 contado.
  - **C (6):** instrumentación (`operacion_completada`); `_encolar_precarga` encola la 1ª y abre la ruta; 2ª inmediata RECHAZADA; 1 sola ruta en vuelo; bombeo cierra; delta == 1.
  - **D (5):** encolada (cola 1, delta 4.0); progreso < 1.0 con operación pendiente; cada bombeo conserva el delta (sin re-claim); tras drenar cola 0 + peso 4.0 + progreso 1.0; ruta cerrada.
  - **E (7):** ancla viva → MISMA instancia (sin recarga aún); 5 ciclos entregaron, descargaron y liberaron limpio; 0 nulas, 0 duplicados y todas clasificadas; cola 62 final 0 + 0 chunks; delta `objetos_vivos` ≤ 0 y sin rutas en vuelo; descargas del 63 +5; control positivo (2 `CACHE_MODE_IGNORE` → el detector las ve).
- **Resultado:** 33 checks, 0 fallos, **×3 corridas idénticas** (runs 8/9/10, exit 0, logs normalizados idénticos). Evidencia: `out/tanda64/suite_run{1..10}.log` (7 corridas de iteración encontraron y documentaron 3 defectos de harness: premisa falsa "ids==1", contador de recargas sin bandera `hubo_prev`, control positivo dependiente de `prev`).
- **Guardián de 3 capas probado EN ROJO:** piso artificial 999 → `[FALL] solo 33 checks ejecutados (mínimo medido en verde: 999)` + exit 1 (`out/tanda64/guardian_rojo.log`); suite restaurada byte-idéntica (sha256 `4666e207…`).
- **Regresión:** las 10 suites M62 previas + `generar_budgets.gd -- --check` → todas verdes (47/39/21/16/60/33/27/133/60/25 checks + 20 budgets; `out/tanda64/reg_*.log`).
- **Alcance (lo que NO prueba):** el cableado de producción de M08 (`chunk_memory.gd` generando y registrando mallas en hilos por chunk) sigue siendo deuda de ese módulo. Esta suite pina el contrato de la cola/loader del 62/63.
- **Reproducir:**

```bash
"<godot_console>" --headless --path game/isla-ancestral \
  --script res://scripts/rendimiento/memoria/test_m62_hilos_cola_mallas.gd
```

## 17. Tanda 65 (2026-10-19, DS-Opencode, Log 2010): L142 — diffs y ediciones del jugador (M08) sin historial infinito en RAM

- **Objetivo:** cerrar por medición el ítem `[ ]` L142 del checklist (sección H, integración M08): "Los diffs y ediciones del jugador (M08) no retienen historial infinito en RAM".
- **Contrato pinneado (sin cambio de producción):** el camino real de edición (`tool_controller.gd`) escribe con `do_point` — **1 escritura por acción** — y en la fuente NO existen estructuras de historial/op-log (0/8 patrones: `_historial`, `historial_ediciones`, `edit_log`, `log_ediciones`, `op_log`, `undo_stack`, `redo_stack`, `diff_store`), ni `do_sphere`/`do_box`. Los payloads por-chunk editados en burst (8 `set_voxel` c/u) se registran y drenan por la cola del 62 sin residuo.
- **Suite nueva:** `test_m62_diffs_ediciones.gd` (**24 checks**) con los autoloads REALES `MemoryMonitor` + `StreamManager` vía `--headless --script` (2 checks de base de autoloads):
  - **A (5):** sonda anti-vacuo + edición real sobre payload (3 `VoxelBuffer` con 8 `set_voxel` c/u; lecturas de vuelta correctas; `objetos_vivos` acotado; WeakRef); medidor de ediciones del camino real.
  - **B (5):** contrato de fuente de `tool_controller.gd`: existe, >1000 chars, `do_point(` ≥ 2 usos, sin `do_sphere(`/`do_box(`, 0/8 patrones de historial → nada acumula por diseño.
  - **C (3):** 5 ciclos × 10 chunks editados y registrados por la cola 62 + drenado: 50 WeakRefs, **0 retenidas**, delta `objetos_vivos` 0 (× ciclo impecable).
  - **D (5):** vía mixta real 62+63: payload editado por la cola del 62 + `Resource` declarado por `registrar_chunk` del 63; drena 2, `liberar_envejecidos`=1, 0/2 vivos, colas finales 0.
  - **E (4):** control positivo autocontenido (2 payloads retenidos por vars propias → el detector DEBE verlos: 2) + balance global final sin fugas (delta ≤ 0; 4477 objetos base).
- **Resultado:** 24 checks, 0 fallos, **×3 corridas idénticas** (runs 3/4/5, exit 0, logs normalizados idénticos). Evidencia: `out/tanda65/suite_run{1..5}.log` (runs 1-2 de iteración encontraron 2 defectos de harness: `registrar_chunk` exige `Resource` — VoxelBuffer es RefCounted; WeakRefs contadas en el balance antes de `clear()`). Diagnósticos: A `edits_ok=2 medidor=3` / B `do_point=2 historial=0` / C `ciclos_ok=5/5 vivos_acum=0` / D `libsm=1 vivos=0` / E `control=2 global=4477`.
- **Guardián de 3 capas probado EN ROJO:** piso artificial 999 → `[FALL] solo 24 checks ejecutados (mínimo medido en verde: 999)` + exit 1 (`out/tanda65/guardian_rojo.log`); suite restaurada byte-idéntica (sha256 `0689b07d…`).
- **Regresión:** 11 suites M62 (las 10 del set T64 + la suite T64) + `generar_budgets.gd -- --check` → todas verdes (47/39/21/16/60/33/27/133/60/25/33 checks + 20 budgets; `out/tanda65/reg_*.log`).
- **Hallazgo de herramienta (recogido en GUIA-GODOT/02-voxel-tools.md §20):** `VoxelToolBuffer` no es instanciable desde GDScript en este build (can_instantiate=false; constructor no bindeado; sin `set_buffer`); para editar sin terreno real usar `VoxelBuffer.set_voxel`.
- **Alcance (lo que NO prueba):** el cableado de producción de M08 (`chunk_memory.gd` acumulando diffs por chunk) sigue siendo deuda de ese módulo. Esta suite pina el contrato del camino real de edición + la liberación por las colas del 62/63.
- **Reproducir:**

```bash
"<godot_console>" --headless --path game/isla-ancestral \
  --script res://scripts/rendimiento/memoria/test_m62_diffs_ediciones.gd
```
