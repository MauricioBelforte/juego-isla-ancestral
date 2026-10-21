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

## 18. Tanda 66 (2026-10-19, DS-Opencode, Log 2012): L143 — al mover el anillo (M12/M63) se descargan los chunks del borde antes de cargar nuevos

- **Objetivo:** cerrar por medición el ítem `[ ]` L143 del checklist: "Al mover el anillo (M12/M63) se descargan los chunks del borde antes de cargar nuevos".
- **Contrato pinneado (sin cambio de producción):** el mecanismo §4 del `stream_manager.gd` (M63): borde = `distancia > r_max + 1.0` **estricto**; gracia de 2 frames (`marcar_envejecidos` ×2 antes de que `liberar_envejecidos` suelte); el contador de envejecimiento **se resetea** si el chunk vuelve al rango; liberar es idempotente y suma a `descargas_total`.
- **Suite nueva:** `test_m62_anillo_borde.gd` (**24 checks**) con los autoloads REALES `MemoryMonitor` + `StreamManager` vía `--headless --script` (2 checks de base):
  - **A (6):** semántica del anillo: 7 chunks (4 interior + 3 borde); 1 marca no libera (gracia); 2 marcas liberan exactamente el borde (3); frontera estricta (101.0 == r_max+1 queda, 101.5 sale); interior intacto; idempotencia; `descargas_total` +3.
  - **B (6):** la invariante del ítem: anillo A (5 interior + 4 borde con `Resource`) + cola del 62 (9) → drena 9 → move r100→60 → libera exactamente el borde (4) → **0/4 vivos del borde y 5/5 del interior** → recién entonces cargan los 4 nuevos (9 activos, sin borde viejo activo, 4 vivos nuevos) → balance ≤ base+9 (sin convivencia).
  - **C (3):** control anti-falso-verde: gracia (1 marca = 0); frontera estricta (61.0 queda, 61.5 sale); el chunk que sale del anillo y VUELVE no se descarga (reset §4).
  - **D (4):** vía real 63→62 con `Resource`: activo+candidato → el 62 drena → move → el 63 cierra su libro (1) y el payload muere (0/1 vivos) → estado final limpio (0 activos, balance ≤ base).
  - **E (3):** ciclo completo de 2 movimientos (r200→r100): cada movimiento descarga su borde (2 y 2, incluido el chunk recién cargado que quedó fuera); final 3 activos = 3 vivos (balance ≤ base+3).
- **Resultado:** 24 checks, 0 fallos, **×3 corridas idénticas** (corridas 3/4/5, exit 0, logs normalizados idénticos). Evidencia: `out/tanda66/suite_corrida{1..5}.log` (corrida 1 de iteración halló el defecto de harness: los WeakRef wrappers cuentan en `objetos_vivos` — B faltaba drenar 13 wrappers, D 1, E 7 → `clear()` antes del balance). Diagnósticos: A `lib=3 interior=4` / B `lib=4 vivos_borde=0` / C `gracia=0 frontera=1` / D `lib=1 vivos=0` / E `lib1=2 lib2=2 final=3`.
- **Guardián de 3 capas probado EN ROJO:** piso artificial 999 → `[FALL] solo 24 checks ejecutados (mínimo medido en verde: 999)` + exit 1 (`out/tanda66/guardian_rojo.log`); suite restaurada byte-idéntica (sha256 `19200978…`).
- **Regresión:** 13 suites M62 (las 11 del set T65 + la suite T65 + la nueva) + `generar_budgets.gd -- --check` → todas verdes (47/39/21/16/60/33/27/133/60/25/33/24/24 checks + budgets; `out/tanda66/reg_*.log`).
- **Alcance (lo que NO prueba):** el caller de producción del movimiento del anillo (M12 zoom → M63 aplicar r_max) todavía no está cableado en el repo. Esta suite pina el mecanismo del borde del 62/63 + la secuencia canónica (marcar×2 → liberar → recién cargar nuevos).
- **Reproducir:**

```bash
"<godot_console>" --headless --path game/isla-ancestral \
  --script res://scripts/rendimiento/memoria/test_m62_anillo_borde.gd
```

## 19. Tanda 67 (2026-10-19, DS-Opencode, Log 2013): L149 — bancos de audio por bioma (M42) cargados al entrar y descargados al salir de la región

- **Objetivo:** cerrar por medición el ítem `[ ]` L149 del checklist: "Bancos de audio por bioma (M42) cargados al entrar y descargados al salir de la región".
- **Contrato pinneado (sin cambio de producción):** el ciclo de vida del banco con las APIs reales del `memory_monitor.gd`: `pedir_banco_audio` (entrar), `registrar_candidato_descarga` + `avisar_cambio_region` (salir fuerza el drenaje), veto del handshake `avisar_carga_iniciada/terminada` (un banco en carga no se descarga), y orden de drenaje por lejanía del `unload_policy.gd`.
- **Suite nueva:** `test_m62_audio_bioma.gd` (**45 checks**) con el autoload REAL `MemoryMonitor` vía `--headless --script` (1 check de base):
  - **A (7):** entrar al bioma: cola drenada; el aviso de región sin pendientes no fuerza; región registrada; el banco ENTRA reproducible (`pedir_banco_audio` == "reproducir"); sin descarga declarada; sin bancos diferidos; sin candidatos.
  - **B (8):** salir de la región: el banco viejo queda encolado como candidato; el banco del bioma nuevo se reproduce; el cambio de región FUERZA la descarga; cola vacía; forzada y cambio contados; **WeakRef: el banco del bioma viejo NO sobrevive** (0 vivos); `objetos_vivos` fin ≤ base.
  - **C (11):** banco EN CARGA: declarado en carga; encolado; el cambio de región NO lo descarga (veto) y el veto suma a `descartes_por_carga`; el candidato sigue en cola (no se pierde); el cambio se cuenta igual; terminada la carga el siguiente cambio SÍ lo descarga; cola vacía; forzada contada; WeakRef 0 vivos.
  - **D (9):** ciclo entrar/salir ×3 (viajes entre 4 regiones): las 3 entradas reproducen, los 3 viajes fuerzan la descarga del banco anterior, cola 0, forzadas +3, cambios +4, el banco de la región actual sigue reproducible, **ningún banco de los viajes sobrevive** (WeakRef 0), `objetos_vivos` fin ≤ base.
  - **E (9):** orden por lejanía (5,3,1) y peso en el lote: 3 bancos encolados → `previsualizar_orden` = [5,3,1] → el cambio drena los 3 en UN lote (`resumen_ultimo_lote` empieza por el de 48 MB) → UNA sola forzada por el cambio → WeakRef 0 → balance final fin ≤ base.
- **Resultado:** 45 checks, 0 fallos, **×3 corridas idénticas** (corridas 3/4/5, exit 0, logs normalizados idénticos de 399 líneas). Evidencia: `out/tanda67/suite_corrida{1..5}.log` (corrida 1 de iteración halló los defectos de harness: snapshot `_camb_a` pre-A y refs locales retenidas por los WeakRef → soltarlas con `null`/`clear()` antes de contar).
- **Guardián de 3 capas probado EN ROJO:** piso artificial 999 → `[FALL] solo 45 checks ejecutados (mínimo medido en verde: 999)` + exit 1 (`out/tanda67/guardian_rojo.log`); suite restaurada byte-idéntica (sha256 `e24b72b0…`).
- **Regresión:** 14 suites M62 (las 13 del set T66 + la nueva) + `generar_budgets.gd -- --check` → todas verdes (47/39/21/16/60/33/27/133/60/25/33/24/24/45 checks + budgets; `out/tanda67/reg_*.log`).
- **Alcance (lo que NO prueba):** el llamador de producción (M42 avisando entrar/salir de bioma desde `set_bioma`/`ambiente_cambiado` y encolando el banco que sale) todavía no está cableado en el repo. Esta suite pina el mecanismo del 62 y el ciclo canónico que lo cumple.
- **Reproducir:**

```bash
"<godot_console>" --headless --path game/isla-ancestral \
  --script res://scripts/rendimiento/memoria/test_m62_audio_bioma.gd
```

## 20. Tanda 68 (2026-10-20, DS-Opencode, Log 2027): L150 — pistas largas (M41/M44) por streaming, no en RAM completa

- **Objetivo:** cerrar por medición el ítem `[ ]` L150 del checklist: "Pistas largas (música M41, ASMR M44) reproducidas por streaming, no en RAM completa".
- **Contrato pinneado (sin cambio de producción):** el ciclo de streaming del `memory_monitor.gd`: `iniciar_descarga_audio` (pista estacionada) → `pedir_banco_audio` == "diferido" (no se reproduce a medias, idempotente por nombre) → `terminar_descarga_audio` → "reproducir"; la pista larga (60 MB) se encola como candidata y el cambio de región la descarga con WeakRef 0 vivos, sin retención en el lote (`_ultimo_lote` = solo {peso,dist,edad}).
- **Suite nueva:** `test_m62_pistas_streaming.gd` (**57 checks**) con el autoload REAL `MemoryMonitor` vía `--headless --script` (1 check de base):
  - **A (10):** streaming de una pista larga: queda en descarga; pedirla se difiere y se registra; pedirla de nuevo sigue diferido y NO duplica; al terminar se reproduce; una pista sin descarga se reproduce directo.
  - **B (10):** no en RAM completa: 60 MB encolados con peso/distancia; el cambio de región fuerza; lote único; resumen "60 MB"; forzada y cambio contados; WeakRef 0 vivos con el lote reportado; `objetos_vivos` ≤ base.
  - **C (17):** música (M41) + ASMR (M44) simultáneas: ambas en descarga y diferidas; terminar música la vuelve reproducible SIN tocar ASMR (que sigue diferida); terminar ASMR la vuelve reproducible; ambas candidatas (60+24 MB) → un solo lote, 60 MB primero, una forzada, WeakRef 0.
  - **D (10):** ciclo ×3 de regiones: 3 pistas diferidas, 3 reproducidas, 3 viajes fuerzan; cola 0; +3 forzadas; +3 cambios; el registro de diferidos suma 3 nombres (strings, no recursos); pista actual reproducible; WeakRef 0; `objetos_vivos` ≤ base.
  - **E (9):** orden por lejanía (9,5,2) con pesos 60/12/24 MB; un lote de 3; resumen 60 MB primero; una forzada por cambio; WeakRef 0; balance final fin ≤ base.
- **Resultado:** 57 checks, 0 fallos, **×3 corridas idénticas** (corridas 2/3/4, exit 0, logs normalizados idénticos de 410 líneas). La corrida 1 de medición dio verde a la primera (sin iteración de harness). Evidencia: `out/tanda68/suite_corrida{1..4}.log`.
- **Guardián de 3 capas probado EN ROJO:** piso artificial 999 → `[FALL] solo 57 checks ejecutados (mínimo medido en verde: 999)` + exit 1 (`out/tanda68/guardian_rojo.log`); suite restaurada byte-idéntica (sha256 `43a73a43…`).
- **Regresión:** 15 suites M62 (las 14 del set T67 + la nueva) + `generar_budgets.gd -- --check` → todas verdes (47/39/21/16/60/33/27/133/60/25/33/24/24/45/57 checks + budgets; `out/tanda68/reg_*.log`).
- **Alcance (lo que NO prueba):** M41 (`music_director.gd`) y M44 (`feedback_director.gd`) son directores de lógica sin reproductores propios ni llamadas al handshake del 62; el cableado de producción (estacionar la pista al cambiar de tema y avisar entrar/salir) pertenece a M41/M44. La suite pina el mecanismo del 62 y el ciclo canónico que lo cumple.
- **Reproducir:**

```bash
"<godot_console>" --headless --path game/isla-ancestral \
  --script res://scripts/rendimiento/memoria/test_m62_pistas_streaming.gd
```

## 21. Tanda 69 (2026-10-20, DS-Opencode, Log 2029): L152 — streams liberados de caché cuando ningún reproductor los usa

- **Objetivo:** cerrar por medición el ítem `[ ]` L152 del checklist: "Streams `.ogg` liberados de caché cuando ningún reproductor los usa".
- **Contrato pinneado (sin cambio de producción):** con reproductor, el stream en uso NO se descarga al cambiar de región y muere al soltar la última referencia + drenar; sin reproductor, la cola lo retiene mientras está encolado y `ejecutar_descarga` lo libera (WeakRef 0, lote sin refs); ciclo ×3 sin acumulación; lote mixto discrimina por uso; `PoolFactory` `audio_voz` no retiene media.
- **Suite nueva:** `test_m62_ogg_cache.gd` (**46 checks**) con el autoload REAL `MemoryMonitor` vía `--headless --script` (1 check de base):
  - **A (10):** stream con reproductor: sobrevive al cambio de región (en uso), sigue vivo tras drenar el lote, muere al soltar la última referencia del player y drenar; contadores forzadas/cambios.
  - **B (10):** stream sin reproductor: encolado vivo (la cola lo retiene), no asignado a ningún player, tras `ejecutar_descarga` muere; lote y resumen de peso correctos; `objetos_vivos` ≤ base + tol.
  - **C (8):** ciclo ×3 usar/soltar/drenar: 3 muertos, cola 0 en cada frontera, lote único, forzadas +3, cambios +3, sin acumulación.
  - **D (10):** lote mixto (uno en uso + uno libre): ambos encolados, el libre muere y el usado sobrevive; al soltar el usado muere; contadores.
  - **E (7):** PoolFactory `audio_voz`: el player nace estacionado SIN stream, con stream vive, `_estacionar()` lo deja sin stream, reciclar/free libera el stream.
- **Resultado:** 46 checks, 0 fallos, **×3 corridas idénticas** (corridas 3/4/5, exit 0, logs normalizados idénticos de 399 líneas). Corridas 1-2 fueron construcción del harness (defectos detectados y corregidos: asertos antes del drenaje, ruido de `objetos_vivos`, `weakref` inferido). Evidencia: `out/tanda69/suite_corrida{1..5}.log`.
- **Guardián de 3 capas probado EN ROJO:** piso artificial 999 → `[FALL] solo 46 checks ejecutados (mínimo medido en verde: 999)` + exit 1 (`out/tanda69/guardian_rojo.log`); suite restaurada byte-idéntica (sha256 `526bb017…`).
- **Regresión:** 16 suites M62 (las 15 del set T68 + la nueva) + `generar_budgets.gd -- --check` → todas verdes (47/39/21/16/60/33/27/133/60/25/33/24/24/45/57/46 checks + budgets; `out/tanda69/reg_*.log`).
- **Alcance (lo que NO prueba):** el repo no tiene assets de audio (0 `.ogg/.wav/.mp3`), así que no se construye un `AudioStreamOggVorbis` real; se usa `AudioStreamWAV` como stand-in DECLARADO (misma semántica RefCounted y propiedad `stream`). Se mide la liberación, no el decoder ogg.
- **Reproducir:**

```bash
"<godot_console>" --headless --path game/isla-ancestral \
  --script res://scripts/rendimiento/memoria/test_m62_ogg_cache.gd
```

## 22. Tanda 70 (2026-10-20, DS-Opencode, Log 2031): L153 — los buses (M91) no retienen streams detenidos

- **Objetivo:** cerrar por medición el ítem `[ ]` L153 del checklist: "Los buses (M91) no retienen streams detenidos".
- **Contrato pinneado (sin cambio de producción):** topología M91 intacta (7 buses, los 6 no-Master a Master); un stream reproducido en un bus y detenido (stop + stream=null) NO queda retenido por el bus (WeakRef muere tras el frame del playback); el ciclo ×3 no acumula; un bus con efectos (compressor de Master) tampoco retiene el stream; free() del reproductor libera el stream y no deja reproductores colgados.
- **Suite nueva:** `test_m62_buses_m91.gd` (**40 checks**) con el AudioServer REAL vía `--headless --script`:
  - **A (14):** topología M91: los 7 buses existen, bus_count == 7, los 6 no-Master enrutados a Master.
  - **B (11):** stream detenido en Music: player en el bus, reproducción, stop, stream=null, WeakRef muere, bus_count 7, efectos sin cambios.
  - **C (5):** ciclo ×3 en Music/SFX/Ambient: 3 streams muertos, bus_count constante, buses siguen existiendo.
  - **D (6):** bus con efectos (compressor de Master): el stream detenido igual muere y el efecto sigue montado.
  - **E (3):** free() del player reproduciendo: stream muere, bus_count 7, sin reproductores colgados en el árbol.
  - **Base (1):** AudioServer disponible.
- **Resultado:** 40 checks, 0 fallos, **×3 corridas idénticas** (corridas 5/6/7, exit 0, 57 líneas de test normalizadas idénticas; se filtra el ruido no determinista del arranque del mundo). Corridas 1-4 fueron construcción del harness (argumentos invertidos, espera del playback del AudioServer, OBJECT_COUNT global reemplazado por conteo local del árbol). Evidencia: `out/tanda70/suite_corrida{1..7}.log`.
- **Guardián de 3 capas probado EN ROJO:** piso artificial 999 → `[FALL] solo 40 checks ejecutados (mínimo medido en verde: 999)` + exit 1 (`out/tanda70/guardian_rojo.log`); suite restaurada byte-idéntica (sha256 `dad6998a…`).
- **Regresión:** 17 suites M62 (las 16 del set T69 + la nueva) + `generar_budgets.gd -- --check` → todas verdes (47/39/21/16/60/33/27/133/60/25/33/24/24/45/57/46/40 checks + budgets; `out/tanda70/reg_*.log`).
- **Alcance (lo que NO prueba):** sin assets de audio en el repo se usa `AudioStreamWAV` como stand-in DECLARADO (AudioStream real del engine, misma semántica RefCounted); se mide la retención por el bus, no el decoder.
- **Reproducir:**

```bash
"<godot_console>" --headless --path game/isla-ancestral \
  --script res://scripts/rendimiento/memoria/test_m62_buses_m91.gd
```

## 23. Tanda 71 (2026-10-20, DS-Opencode, Log 2035): L154 — cambio de bioma con descarga diferida 1 frame

- **Objetivo:** cerrar por medición el ítem `[ ]` L154: "Cambio de bioma: descarga del banco anterior diferida 1 frame (no corta transiciones)".
- **Cambio de producción (`memory_monitor.gd`):** `avisar_cambio_bioma_audio(banco_nuevo: RefCounted) -> bool` deja el banco anterior PENDIENTE y el nuevo ACTUAL; `_procesar_liberacion_audio()` suelta el pendiente con un frame completo de margen; mismo banco = no-op; dos cambios en el mismo frame sueltan el intermedio YA; getters de medición. Acepta `RefCounted` puro.
- **Suite nueva:** `test_m62_bioma_audio_diferido.gd` (**47 checks**) con el autoload REAL `MemoryMonitor` vía `--headless --script`:
  - **Base (1):** autoload disponible.
  - **A (6):** primer banco: ACTUAL, sin PENDIENTE, sin liberaciones ni último liberado.
  - **B (13):** cambio a→b: anterior PENDIENTE y VIVO en el frame; con el margen muere (WeakRef), se cuenta 1 y el ACTUAL es b.
  - **C (3):** mismo banco = no-op; sin pendiente ni liberación espuria.
  - **D (13):** dos cambios en el mismo frame: el intermedio se suelta YA (2), el segundo queda PENDIENTE y muere con el margen (3).
  - **E (11):** `RefCounted` puro: mismo ciclo sin acumulación (4 y 5 liberaciones).
- **Resultado:** 47 checks, 0 fallos, **×3 corridas idénticas** (corridas 1/2/3 del archivo final, exit 0, 58 líneas de test normalizadas idénticas; se filtra el ruido no determinista del arranque del mundo). La corrida de calibración inicial también midió 47 checks pero con piso 46; se elevó el piso a 47 y se repitieron las 3. Evidencia: `out/tanda71/suite_corrida{1..3}.log`.
- **Guardián de 3 capas probado EN ROJO:** piso artificial 999 → `[FALL] solo 47 checks ejecutados (mínimo medido en verde: 999)` + exit 1 (`out/tanda71/guardian_rojo.log`); suite restaurada byte-idéntica (sha256 `fbe56577…`).
- **Regresión:** 18 suites M62 (las 17 del set T70 + la nueva) + `generar_budgets.gd -- --check` → todas verdes (47/39/21/16/60/33/27/133/60/25/33/24/24/45/57/46/40/47 checks + budgets; `out/tanda71/reg_*.log`).
- **Alcance (lo que NO prueba):** M42 (`ambient_director.gd`) sigue read-only; el cableado `set_bioma() -> avisar_cambio_bioma_audio()` queda como deuda declarada de M42 (§12). Sin assets de audio se usan bancos `Resource`/`RefCounted` sintéticos: se mide el contrato del mecanismo, no el decoder.
- **Reproducir:**

```bash
"<godot_console>" --headless --path game/isla-ancestral \
  --script res://scripts/rendimiento/memoria/test_m62_bioma_audio_diferido.gd
```

## 24. Tanda 72 (2026-10-20, DS-Opencode, Log 2039): 30 min de clima cambiante con banco de audio sintético

- **Objetivo:** cerrar por medición el ítem `[ ]` L155: "Prueba: 30 min con clima cambiante (M32) sin crecimiento de memoria de audio".
- **Harness:** `sesion_m62_clima_30min.gd` (sha256 `c2237f6802ddfe3bc1145d28918889b2c6f59e66b9484e88077990d4717cf136`; sin cambio de producción) se extendió con `M62_AUDIO_BANCO_MB`. En cada `clima_cambio` crea un `AudioStreamWAV` REAL de 3 MB (PCM 16 bits, 22050 Hz, mono; stand-in declarado porque el repo tiene 0 assets), lo entrega a `MemoryMonitor.avisar_cambio_bioma_audio()` (mecanismo L154) y verifica por `WeakRef` que el banco anterior muere. `M62_AUDIO_FUGA=1` retiene los bancos como sonda ROJA.
- **Corrida real (30 min de reloj de pared):** 2026-10-20 02:32:16 → 03:02:16.
  - 359 muestras (mínimo 300), 299 con baseline; baseline **178.2 MB** (incluye el banco ACTUAL).
  - Drift final **+0.1%**, máximo absoluto **0.1%** (t=600 s); `drift_check() = true`.
  - **10 cambios pedidos / 10 efectivos / 10 eventos `clima_cambio`**, 4 climas distintos: NUBLADO, SOLEADO, TORMENTA, LLUVIA.
  - **10 bancos creados, 1 vivo (el ACTUAL), PENDIENTE = null**, control positivo **+3 MB**, pico 181.6 MB.
  - Buses **7 → 7**, reproductores **9 → 9**, huérfanos **0**, viajes **0**.
  - **0 `SCRIPT ERROR`**, EXIT 0. (1 `ERROR` de engine: `AnimationService` singleton ausente, ruido preexistente del boot headless, ajeno a M62.)
- **Sonda ROJA:** `M62_AUDIO_FUGA=1` retuvo **7 bancos vivos**, memoria **+21 MB** (196.4 MB), y el gate falló con `[FALLO] audio sintetico: 7 bancos vivos (se espera solo el actual)` + `[FALLO] audio sintetico: quedo un banco PENDIENTE sin liberar`; EXIT 1. Prueba que el detector de fuga de audio no es decorativo.
- **Calibración:** 5 smokes cortos con baseline forzada para validar el banco y el cierre (el drift de esos smokes no es válido: la baseline forzada al boot queda 50 MB por debajo del mundo ya cargado). El run real NO usa `M62_BASELINE_FORZAR`.
- **Alcance (lo que NO prueba):** el banco es sintético (`AudioStreamWAV`), no un asset real ni el decoder; M42 (`ambient_director.gd`) sigue con **0 llamadores** de `set_estado_clima()`, así que el clima de M32 no selecciona el banco de audio de M42. Esa deuda es de M42 y queda declarada. No cubre VRAM (headless sin renderer) ni input de jugador.
- **Evidencia:** `out/tanda72/sesion_audio_30min.log` (sha256 `534998dc250f325df2d890d8234d6897329b3f18a8ee2250e0601d3183ca685e`), `out/tanda72/sesion_audio_30min.csv` (359 filas, sha256 `e4909a6bb14ba69cb655e3c026f559a4350fc6991736fc947ed1f6e2eed3f202`), `out/tanda72/guardian_audio_rojo.log` (sha256 `7f5867259c6eaeb89ba3e9a5d86a97c3a7fd040969ada75b8ca812e92cb7deee`).
- **Reproducir:**

```bash
M62_AUDIO_BANCO_MB=3 <godot_console> --headless --path game/isla-ancestral \
  --script res://scripts/rendimiento/memoria/sesion_m62_clima_30min.gd
```

**Firma:** DeepSeek-V4.1-Flash / OpenCode — Tanda 72.

## 25. Tanda 74 (2026-10-20, DS-Opencode, Log 2042): L163 — sin doble carga M63/ResourceCache

- **Objetivo:** cerrar por medición el ítem `[ ]` L163 ("Sin doble carga del mismo recurso:
  ResourceCache + cola M63 con un solo dueño").
- **Bug reproducido EN ROJO:** `StreamManager.encolar()` aceptaba una 2.ª operación con la misma
  `ruta_recurso` mientras la 1.ª seguía en vuelo. Resultado: `ok2=true`, cola 0→2, dos callbacks
  (`doble_1`, `doble_2`). `_encolar_precarga()` sí filtraba; la API pública no.
- **Fix:** guard en `encolar()` antes de `load_threaded_request`:
  `ruta_recurso != "" and esta_cargando_ruta(ruta_recurso) → false`. Cambio acotado a
  `scripts/stream/stream_manager.gd` (M63; sha256 `8e4188595e01…`); M62 sin cambios de producción.
- **Suite nueva:** `test_m62_doble_carga_m63.gd` (**20 checks**, piso 18), autoloads REALES
  `StreamManager` + `MemoryMonitor`, fixture `.tres` real:
  - **A (1):** cola y rutas drenadas.
  - **B (4):** 1.ª carga aceptada, ruta en vuelo, cola +1, una sola ruta.
  - **C (5):** 2.ª carga de la misma ruta RECHAZADA, cola no crece, una ruta, `_encolar_precarga` 0,
    cola sigue estable.
  - **D (10):** un callback, una sola operación completada, ruta cerrada, cola a la base, M62 sin
    cargas, MISMA instancia de `ResourceLoader`, 0 duplicados en `LeakGuard`, control positivo
    `CACHE_MODE_IGNORE`.
- **Rojo → verde:** `out/tanda74/red.log` 20 checks / **4 fallos** / EXIT 1 (sha256 `732b3e52…`);
  `out/tanda74/green.log` 20 checks / **0 fallos** / EXIT 0 (sha256 `fcfcaf71…`).
- **Regresión:** `test_rf2_threaded` 7/0, `test_stream_m63_iter5` 51/0, `test_stream_m63_iter6`
  42/0, `test_m62_hilos_cola_mallas` 33/0 = **133 checks, 0 fallos, EXIT 0**. Logs en
  `out/tanda74/` (sha256 `3a4650ef…`, `6478d9db…`, `daf922dd…`, `29842d42…`).
- **Alcance:** no cubre el streaming C++ de `VoxelTerrain` (llamador real M08/M63); pina el contrato
  de la cola/caché. No se tocó `quality.yml`.
- **Reproducir:**

```bash
"<godot_console>" --headless --path game/isla-ancestral \
  --script res://scripts/rendimiento/memoria/test_m62_doble_carga_m63.gd
```

**Firma:** DeepSeek-V4.1-Flash / OpenCode — Tanda 74.

## 26. Tanda 75 (2026-10-20, DS-Opencode, Log 2044): L166 — drift-check post-viaje (herencia)

- **Objetivo:** cerrar el ítem `[ ]` L166 verificando el cableado existente, sin duplicar la
  implementación de DeepSeek-V4.1-Flash (Log 2021).
- **Punto de llamada real:** `TravelService._atracar()` → `_verificar_drift_post_viaje(ruta)`
  después de aterrizar y antes de `travel_arrived`. Umbral `UMBRAL_VIAJE_LARGO_S = 45.0`
  (rutas 20/30/45/60 s; “largo” = 45 y 60).
- **Gate:** `test_m62_drift_post_viaje.gd` — **12 checks, 0 fallos, EXIT 0**:
  A corto (20 s) no chequea; B largo (60 s) chequea 1 con 0 fallos; C baseline inyectada a la mitad
  (drift 100%) → 1 fallo y `drift_check()=false`; D sin monitor → 1 NO MEDIBLE y checks no sube;
  4 llegadas emitidas; umbral 45 s. Evidencia `out/tanda75/drift_post_viaje.log`
  (sha256 `025a6ea61c34ac0369655d4944f65cb03f6851ab15d6fb478c7f5ea3acb268b6`).
- **Regresión M28:** `test_viajes.gd` → 0 fallos, EXIT 0
  (`out/tanda75/test_viajes.log`, sha256 `bfec4aa0c5afd136186ac44b1126af67fa85f144b87cd78d82fc58fd13773221`).
- **Alcance:** M69 no ejecuta el teleport (emite `viaje_solicitado`; el caller M28/M59 ejecuta).
  La suite pina el punto de llamada de M28 y el contrato fail-closed; no mide el RSS de un viaje
  real con mundo cargado (Play Mode).
- **Reproducir:**

```bash
"<godot_console>" --headless --path game/isla-ancestral \
  --script res://scripts/rendimiento/memoria/test_m62_drift_post_viaje.gd
```

**Firma:** DeepSeek-V4.1-Flash / OpenCode — Tanda 75.

## 27. Tanda 76 (2026-10-20, DS-Opencode, Log 2045): L180 — Preset Baja en isla pequeña (M27)

- **Objetivo:** cerrar `[ ]` L180 verificando el mecanismo existente (DeepSeek Log 2021), sin
  duplicar la implementación.
- **Gate:** `test_m62_preset_baja_m27.gd` — **13 checks, 0 fallos, EXIT 0**:
  A `baja=1`, `media=2`, desconocido cae a media; B 3 cargadas → descarga 1 viajera, deja actual +
  principal, progreso `descubierta/visitada` intacto, no queda viajera; C media con 2 cargadas no
  descarga; D precarga por cercanía (1 en baja; presupuesto explícito 2 → 2 en orden).
  Evidencia `out/tanda76/preset_baja_m27.log` (sha256
  `8d105bfd8442460025d6157efdf4d56ee77f7026660da20f5a48f00e05d3f754`).
- **Regresiones M27:** `test_islas_m27.gd` **171 checks, 0 fallos**, EXIT 0
  (`out/tanda76/test_islas_m27.log`, sha256 `f0c6e682…`); `test_islas_m27_iter2.gd` **238 checks,
  0 fallos**, EXIT 0 (`out/tanda76/test_islas_m27_iter2.log`, sha256 `3f33bd22…`).
- **Deuda declarada:** `IslandTravelGuard` no se instancia en producción; preset y descarga no se
  disparan en un viaje real. Es feed runtime de M27, no del mecanismo M62. Mismo criterio que L132.
- **Reproducir:**

```bash
"<godot_console>" --headless --path game/isla-ancestral \
  --script res://scripts/rendimiento/memoria/test_m62_preset_baja_m27.gd
```

**Firma:** DeepSeek-V4.1-Flash / OpenCode — Tanda 76.

## 28. Tanda 77 (2026-10-20, DS-Opencode, Log 2046): L185 — memoria al límite en tormenta

- **Objetivo:** cerrar `[ ]` L185 verificando el arnés existente (DeepSeek Log 2033), sin duplicar.
- **Gate:** `sesion_m62_limite.gd` — **14 checks, 0 fallos, EXIT 0**. TORMENTA real de M32 en 3 días
  (`clima=3`); presupuesto forzado 146/135/128 MB → niveles 1/2/3; `semaforo_cambiado` 3 veces;
  enforcement duro (`_ultimo_enforcement=3`); sin crash; Player movible; restauración exacta a
  2032 MB y nivel 0. Evidencia `out/tanda77/limite_tormenta.log` (sha256 `0563a543…`).
- **Regresión M32:** `test_clima.gd` **29 checks, 0 fallos**, EXIT 0
  (`out/tanda77/test_clima.log`, sha256 `641eee03…`).
- **Alcance:** headless no itera a 60 Hz; “sigue jugable” se mide como escena/Player vivos, no fps.
  No hay assets de audio (0): la parte “banco de audio completo” del ítem 127 queda fuera.
- **Reproducir:**

```bash
"<godot_console>" --headless --path game/isla-ancestral \
  --script res://scripts/rendimiento/memoria/sesion_m62_limite.gd
```

**Firma:** DeepSeek-V4.1-Flash / OpenCode — Tanda 77.

## 29. Tanda 78 (2026-10-20, DS-Opencode, Log 2047): L189 — baseline menú principal (NO MEDIBLE)

- **Resultado:** `[?]` NO MEDIBLE. No existe escena de menú principal: `run/main_scene` apunta a
  `res://scenes/main_island.tscn`; los 4 candidatos de Log 2033 siguen ausentes; el único
  `*menu*.tscn` es `scenes/debug/debug_menu.tscn`.
- **Decisión:** no se mide la isla como menú (falso verde). No se modifica `project.godot` ni se crea
  un menú postizo. El ítem queda para el dueño de la escena de menú.
- **Evidencia:** `project.godot` L15 + glob de `*.tscn` (0 menús principales) + Log 2033 item 18.
- **Sin gate nuevo:** no hay nada que medir todavía; un “baseline” inventado sería peor que `[?]`.

**Firma:** DeepSeek-V4.1-Flash / OpenCode — Tanda 78.

## 30. Tanda 79 (2026-10-20, DS-Opencode, Log 2048): L190 — baseline spawn con renderer real

- **Objetivo:** < 1600 MB.
- **Arnés de producción, sin headless:** `sesion_m62_baselines.gd`, `M62_ESCENARIO=spawn`,
  `M62_ASENTAR_S=15`, `--rendering-driver opengl3`: **149.7 MB static**, 7307 objetos,
  0 huérfanos, **7 checks / 0 fallos / EXIT 0**.
- **VRAM:** `RENDER_VIDEO_MEM_USED` 44.3 MB; texturas 12.2 MB; buffers 32.1 MB; static 145.6 MB;
  **total estimado 189.9 MB**; 7288 objetos.
- **Resultado:** **189.9 MB << 1600 MB** (11.9%). Cierra L190.
- **Límite:** boot automatizado con renderer real y 12–15 s de asentamiento; no sesión manual ni
  banco de audio completo. La medición de VRAM es del renderer, no una estimación externa.

**Firma:** DeepSeek-V4.1-Flash / OpenCode — Tanda 79.

## 31. Tanda 80 (2026-10-20, DS-Opencode, Log 2051): L191 — baseline horizonte con renderer real

- **Objetivo:** < 2200 MB.
- **Arnés, sin headless:** `M62_ESCENARIO=horizonte`, `M62_ASENTAR_S=20`, renderer OpenGL 3.3:
  **151.7 MB static**, 7384 objetos, 0 huérfanos, **9/0 EXIT 0**, cámara a **20.00 m**.
- **VRAM:** 44.4 MB; static 148.0 MB; **total estimado 192.4 MB** (8.7% del objetivo); 7293 objetos.
- **Fix de arnés:** espera de 1 s para que `follow_camera._ready` resuelva `_target`; modo EXPLORE;
  2 s de `_physics_process` tras el scroll para que la posición converja. Solo test.
- **Regresión:** spawn 144.1 MB, 7/0.
- **Resultado:** cierra L191.

## 32. Tanda 81 (2026-10-20, DS-Opencode, Log 2052): L192 — subterráneo del templo (NO MEDIBLE)

- **Objetivo:** < 2000 MB.
- **Bloqueo:** 0 escenas `*templo*`/`*subterr*`/`*cueva*`; no hay entrada/API de producción al templo.
- **Corrida con renderer real:** el arnés baja 40 m en el spawn (Y 6.0 → -34.0); VoxelTerrain 1,
  **0 bloques actualizados**, 8 checks / 1 fallo, EXIT 3 (detector ciego). 155.9 MB static no es un
  baseline del templo y no se usa.
- **Resultado:** `[?]` hasta que exista la escena/entrada de producción.

**Firma:** DeepSeek-V4.1-Flash / OpenCode — Tandas 80-81.

## 33. Tanda 82 (2026-10-20, DS-Opencode, Log 2053): L193 — tormenta + audio (memoria medida, banco completo NO MEDIBLE)

- **Objetivo:** ≤ 2500 MB.
- **Tormenta real, renderer OpenGL 3.3:** clima 3 tras 3 días; **157.9 MB static**, 7412 objetos,
  0 huérfanos, 8/0 EXIT 0; 7 buses y 9 reproductores.
- **Banco sintético:** 3 MB `AudioStreamWAV`; memoria 151.9 → 157.9 MB.
- **VRAM:** 44.7 MB; static 152.0; **total 196.7 MB** (7.9% del objetivo); 7322 objetos.
- **Bloqueo:** 0 assets de audio y M42 `set_estado_clima()` con 0 llamadores; el banco completo no
  existe. El sintético es un stand-in y no prueba assets/decoder.
- **Resultado:** `[?]` hasta que exista el banco real.

**Firma:** DeepSeek-V4.1-Flash / OpenCode — Tanda 82.

## 34. Tanda 83 (2026-10-20, DS-Opencode, Log 2054): L213 — 30 min sin teleport (herencia T72)

- **Item:** drift-check de 30 min sin teleport, drift ≤ 5%.
- **Corrida T72:** 30 min reales, 359 muestras, baseline 178.2 MB, **drift +0.1% (máx 0.1%)**,
  `drift_check()=true`, **0 viajes/teleports**, 0 huérfanos, 10 climas, EXIT 0.
- **Evidencia:** `out/tanda72/sesion_audio_30min.log` y `.csv`.
- **Alcance:** `SceneTree --script`, no editor Play Mode; sin input. La corrida incluye clima
  cambiante (estrés extra) y no usa teleport.
- **Resultado:** `[x]` por herencia; no se re-ejecutan 30 min.

**Firma:** DeepSeek-V4.1-Flash / OpenCode — Tanda 83.

## 35. Tanda 84 (2026-10-20, DS-Opencode, Log 2055): L215 — audio por bioma sin crecimiento

- **Suite:** `test_m62_audio_bioma.gd`, autoload real, **45 checks / 0 fallos / EXIT 0**.
- **Ciclos:** entrar, salir, banco en carga (veto), 3 viajes y drenaje final en un lote.
- **Retención:** **0 bancos sobrevivientes (WeakRef)**; `objetos_vivos()` **4477 → 4477 (delta 0)**;
  cola vacía en cada cierre.
- **Memoria 30 min (T72):** 10 bancos, 1 vivo, 178.2 → 178.4 MB, drift +0.1%, EXIT 0.
- **Evidencia:** `out/tanda84/audio_bioma.log` sha256 `E54AB45D…`.
- **Alcance:** `SceneTree --script`, no editor Play Mode; bancos sintéticos; M42 sin llamadores.

**Firma:** DeepSeek-V4.1-Flash / OpenCode — Tanda 84.

## 36. Tanda 85 (2026-10-20, DS-Opencode, Log 2056): L216 — 500 bloques sin leaks

- **Verde:** 9 checks / 0 fallos / EXIT 0; 500/500 excavadas y 500/500 regeneradas; 5 buffers / 0 vivos;
  memoria 137.3 → 137.3 MB (+0.0%); objetos 7408 → 7413 (+5); 0 huérfanos.
- **Rojo:** `M62_RETENER_BUFFERS=1` → 5 buffers vivos, `[FALLO]`, EXIT 1.
- **Evidencia:** `out/tanda85/voxel_500.log`, `out/tanda85/voxel_500_rojo.log`.
- **Alcance:** VoxelBuffer real, no VoxelTerrain renderizado; headless reporta 0 bloques actualizados.
  No es el Play Mode del editor.

**Firma:** DeepSeek-V4.1-Flash / OpenCode — Tanda 85.

## 37. Tanda 86 (2026-10-20, DS-Opencode, Log 2057): L217 — chunks vs presupuesto voxel

- **Verde:** 6 checks / 0 fallos / EXIT 0; budget real media 650 MB; coste 8.4 KB/chunk; máximos
  60.952/79.238/97.523; tope StreamManager 4.096 chunks = 34 MB; 20.100 → 20.000; 20.008 liberados;
  0 vivos (WeakRef); 0 huérfanos.
- **Rojo:** `M62_SIN_TOPE=1` → 20.100 activos, `[FALLO] el LRU deja exactamente el tope`, EXIT 1.
- **Evidencia:** `out/tanda86/chunks_presupuesto.log` sha256 `28480231…`; rojo `AFFFA5EB…`.
- **Alcance:** coste de datos (VoxelBuffer 16³), no mallas/colliders; headless sin streaming real.
  No es el Play Mode del editor.

**Firma:** DeepSeek-V4.1-Flash / OpenCode — Tanda 86.

## 38. Tanda 87 (2026-10-20, DS-Opencode, Log 2059): L221 — Baja 4 GB, NO MEDIBLE

- **Parcial medido:** preset Baja 1.500 MB; `test_m62_preset_baja_m27.gd` **13/0**; T72 30 min con pico
  **178.2 MB static (T72) y 44.7 MB VRAM (probe T82, corrida separada)**; 0 OOM.
- **No medible:** no hay hardware de 4 GB ni límite de proceso; headless no impone OOM y no itera a 60 Hz
  (8 physics frames en 10 s); “jugable” requiere input/Play Mode real.
- **Falta:** playtest del usuario en 4 GB o Job Object `ProcessMemoryLimit=4GB` + input.
- **Resultado:** `[?]` honesto; no se marca `[x]`.
- **Evidencia parcial:** `out/tanda72/sesion_audio_30min.log`, `out/tanda76/preset_baja_m27.log`.

**Firma:** DeepSeek-V4.1-Flash / OpenCode — Tanda 87.
