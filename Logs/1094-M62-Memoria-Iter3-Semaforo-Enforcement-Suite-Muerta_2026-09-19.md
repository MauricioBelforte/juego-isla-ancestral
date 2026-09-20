# Log 1094: M62 Memoria iter. 3 — el semáforo mudo, la suite muerta y el test que consagraba el bug

**Agente:** DeepSeek-V4.1-Flash (WorkBuddy)
**Módulo:** 62-Memoria (`game/isla-ancestral/scripts/rendimiento/memoria/`)
**Iteración:** 3 (núcleo iter. 1 deepseek-v4-flash · enforcement/pool iter. 2 glm-5.3-flash)
**Fecha:** 2026-09-19
**Reserva:** 1094 (protocolo v3 — consumido del pool)

## Resumen

M62 estaba **🟢 Disponible y sin agente** en `CHECKLIST-GLOBAL.md` (fila 168), con 59/150 en el
checklist. Tomado del backlog propio. El ciclo arrancó buscando cerrar ítems y terminó encontrando
**6 defectos reales** —uno de ellos de datos— más un **hallazgo grave que invalida un sello de QA
previo**. Lo más importante de este log no son los 34 ítems cerrados, sino las tres cosas que
aparecieron al **correr** las suites en vez de confiar en ellas.

| # | Hallazgo | Gravedad |
|---|---|---|
| 1 | El semáforo comparaba contra el consumo **reportado** (0 si nadie reporta), no contra el **presupuesto** → quedaba **mudo** | alta |
| 2 | Por el mismo motivo el **enforcement nunca corría** | alta |
| 3 | `_process` muestreaba **cada frame** con `append()`+`pop_front` (alloc deliberado por frame, prohibido) | media |
| 4 | El drift se medía sobre ~10 s, no contra una baseline a los 5 min; `drift_check()` **no existía** | media |
| 5 | Faltaba el **pico por punto de interés** | baja |
| 6 | `budgets.json` divergía del diseño §2 en **los 8 sistemas de los 3 presets** | alta |
| 7 | **`test_enforcement_m62.gd` estaba MUERTA Y DABA VERDE** → invalida el §21.8 de Log 856 | **crítica** |

## 1. Los 5 defectos del monitor (medidos, no inferidos)

El diseño §3 fija 80 % / 90 % / 95 % sobre el **presupuesto**. El código comparaba contra
`total_consumo_mb()` —el consumo *reportado por los sistemas*— con umbrales 0.9/1.3/1.5. Como al
arrancar **nadie reporta**, el total daba `0`, `0/total` daba 0 y el semáforo **nunca cambiaba**.
El mismo denominador alimentaba `_enforcement()`, así que `total <= 0` cortaba la ejecución antes de
empezar: **las dos mitigaciones de RN2/RN3 eran código muerto**.

El tercero: `_process` muestreaba en cada frame y hacía `_muestras.append()` + `pop_front`. Eso es un
**alloc deliberado por frame**, exactamente lo que el checklist §L prohíbe. El diseño §3 pide 5 s en
calma y 1 s con movimiento de cámara.

El cuarto: `drift_porciento()` comparaba el primer y el último elemento de una ventana de 600 frames
(~10 s). RN3 habla de una sesión de 30 min contra una baseline **estabilizada a los 5 minutos**. Y
`drift_check()` —que la API del diseño §2 promete— **no existía**.

El quinto: sólo había pico de sesión; el checklist §B pide pico por punto de interés (spawn,
teleport, escena).

**Correcciones:** `nivel_para(actual_mb)` pasa a ser la **única fuente de verdad** y alimenta semáforo
y enforcement; `total_topes_mb()` (la suma de topes) es el denominador; muestreo por tiempo con
ventana circular `PackedFloat32Array` de 600 dimensionada de forma perezosa; baseline a los 300 s;
`drift_check()`; `marcar_punto_de_interes()`; `alarmas_pico()`; y `_log_m62()` contra
`/root/GameLogger` (categoría SYSTEM).

## 2. El defecto de datos y el test que lo consagraba

`data/rendimiento/budgets.json` había divergido del diseño §2 en **los 8 sistemas de los 3 presets**:

| Preset | Suma real (disco) | Suma declarada |
|---|---|---|
| Baja | 1664 | 1500 |
| Media | 2112 | 2000 |
| Alta | 2560 | 2500 |

El generador validante nuevo (`generar_budgets.gd -- --check`) lo detectó **antes** de regenerar, con
la lista exacta de discrepancias (`"texturas: disco=384 diseño=250"`, …) y salida 1. Eso es lo que
hace confiable a un gate: **discrimina**.

Pero lo peor no era el dataset. Era esto:

```
- _check("tope media voxel = 640", b.tope_de("voxel") == 640, "voxel=%d" % …)   # HEAD tenía 640
```

El dataset estaba mal **y la suite afirmaba el valor malo**: dos errores que se cancelaban y daban
verde. Corregido a 650 (diseño §2) y se agregó una guarda contra la divergencia silenciosa (la suma
de topes debe dar el total declarado del preset).

## 3. El hallazgo grave: una suite muerta que reportaba verde

`test_enforcement_m62.gd` (iter. 2) **no verificaba nada y salía con código 0**:

```
SCRIPT ERROR: Trying to assign value of type 'RefCounted' to a variable of type 'Node'.
   at: _test_registros (res://scripts/rendimiento/memoria/test_enforcement_m62.gd:29)
   at: _test_enforcement_niveles (res://scripts/rendimiento/memoria/test_enforcement_m62.gd:46)
=== TEST M62 ENFORCEMENT: 0 fallo(s) ===   → salida 0
```

`var budget: Node = load("…/budget_registry.gd").new()` sobre un `RefCounted`: la asignación tipada
abortaba **las dos** funciones de verificación (0 checks ejecutados). La tercera función sí corría,
pero sus 3 aserciones eran `_check(true, "…sin crash")` → **infalsificables**. Sin contador de
checks, sin piso y sin watchdog, el resumen decía `0 fallo(s)` y salía 0. Además llamaba a
`monitor._muestrear()` (renombrado a `muestrear_ahora()`) y a `_enforcement()` con 1 argumento
(ahora recibe 2).

**Consecuencia directa:** el sello **§21.8 de M62 (Log 856, Hy3/WorkBuddy)** se apoyó en «0 fallos
(EXIT 0)» de esa suite. El sello **queda invalidado** y **M62 necesita un §21.8 nuevo**. No es un
error de Hy3: es lo que pasa cuando el veredicto de un QA se apoya en el exit code de una suite que
no puede fallar.

Se reescribió con tipos correctos y 47 aserciones que pueden fallar. Para poder asertar la alarma de
pico se le agregó un contador observable (`alarmas_pico()`): antes sólo hacía `push_warning` y era
imposible verificarla desde un test.

También se corrigieron **2 aserciones infalsificables** en `test_pool_iter2.gd`
(`a.is_processing() == true or true` y `conns_antes >= 0`) y un `emisor.free()` de un nodo que seguía
**dentro del pool**.

## 4. La primera corrida de la suite nueva encontró 2 defectos de producción

`test_memoria_m62_iter3.gd` se escribió y se corrió **antes** de darla por buena. Esa primera corrida
devolvió:

- **705** `SCRIPT ERROR: Out of bounds set index '0' (on base: 'PackedFloat32Array')`
- **7** `ERROR: Can't use get_node() with absolute paths from outside the active scene tree.`
- **4** `[FAIL]` (todos del bloque D, ventana circular)

Los dos eran defectos **del código de producción**:

1. `_registrar_muestra()` daba por hecho que `_ready()` había corrido el `resize()`. Un monitor
   instanciado suelto (`load(...).new()`, que es como lo hacen los runs `--script`) **nunca dispara
   `_ready()`** → array vacío → el `SCRIPT ERROR` **abortaba la función** y `_muestras_n` quedaba en 0.
   Arreglado con dimensionado perezoso (`_asegurar_ventana()`), que sólo toca el array una vez y por
   lo tanto sigue sin allocs por frame.
2. `_log_m62()` y `_registrar_servicio()` resolvían rutas absolutas desde un nodo **fuera del árbol**.
   Arreglado con guarda `is_inside_tree()`.

## 5. Suites: 232 checks, guardián de 3 capas probado por inyección

| Suite | Checks | Antes |
|---|---|---|
| `test_memoria_m62.gd` | 27 | 27, pero sin piso ni watchdog |
| `test_enforcement_m62.gd` | 47 | **muerta: 0 checks reales** |
| `test_pool_iter2.gd` | 25 | 14 con 2 aserciones infalsificables |
| `test_memoria_m62_iter3.gd` | 133 | nueva |

**Total 232 checks, 0 fallos, ×3 idénticas.** El conteo se compara sobre la secuencia
`[OK]`/`[FAIL]` **normalizada** (la salida cruda trae timestamps y duraciones; compararla entera daría
«0 idénticas» con la suite perfectamente determinista).

Guardián de 3 capas: (1) cada bloque se marca con `_fin()` y `_summary()` **nombra** el que no
corrió; (2) piso `CHECKS_MINIMOS` **medido en verde** (133/47/27/25), no copiado; (3) `_summary()` en
un `call_deferred` **separado**, porque un `SCRIPT ERROR` aborta la función y un resumen que vive
dentro de `_run()` se muere con ella.

**Probado por inyección en las 4** (copia temporal con un índice fuera de rango, borrada después):

| Suite | Inyección | Checks | Salida | ¿Nombró el bloque? |
|---|---|---|---|---|
| iter3 | bloque H | 133 → **114** | 1 | sí |
| iter3 | `_run()` tras A | 133 → **21** | 1 | sí, B→J |
| enforcement | bloque C | 47 → **36** | 1 | sí |
| núcleo | `_run()` tras budget | 27 → **11** | 1 | sí, pool/unload/monitor |
| pool_iter2 | bloque C | 25 → **22** | 1 | sí |

El piso importó de verdad: un piso estimado en 60 contra 133 reales habría dejado pasar la pérdida
de 73 checks.

## 6. Gate de CI

M62 **no tenía ningún gate**: se buscaron las 3 suites existentes en `quality.yml` y daban **0
coincidencias**. Se agregó un bloque en el job `test-suite` con el patrón duro `FAIL=0` +
`|| FAIL=1` + `exit $FAIL`, **sin `|| true`**, con 5 comandos (las 4 suites + `generar_budgets.gd --
--check`). Los 5 se corrieron **con el mismo directorio de trabajo que usa el CI** (`cd
game/isla-ancestral`, sin `--path`) y dieron salida 0; el YAML se validó con un parser (10 jobs).

## 7. Registros y documentación

- **Checklist del módulo: 59/150 → 93/150** (34 ítems, cada uno citando su artefacto).
- `04-Codigo.md`: corregidas las rutas de la tabla del diseño (decía `res://rendimiento/…` y
  `budgets.tres`; la realidad es `res://scripts/rendimiento/…` y `budgets.json`), corregidas las
  constantes falsas del §2 (`PERFORMANCE_OBJECT_COUNT` no existe en Godot 4), y agregada la sección
  **Iteración 3** con los 7 hallazgos, los edge cases y lo que NO se hizo.
- `06-Plan-Testings.md` y `07-Resultados-Testings.md`: **no existían**, creados.
- `05-Checklist.md`: cabecera y bloque de reserva actualizados (decían «iter. 1» desde el 2026-09-01);
  se corrigieron **5 anotaciones falsas** ya marcadas `[x]` — entre ellas «MemoryMonitor con
  GameLogger integrado (iter. 1)», que era **falso** (`grep` no encontraba ni una referencia) y
  llevaba 18 días marcado sin código que lo respaldara.
- `BACKLOG-MASTER.md` propio: 34 ítems marcados (91 → 57 pendientes) + entrada del log.
- `CHECKLIST-GLOBAL.md` fila 168: estado → 🔵 En curso, progreso 93/150, agente DeepSeek-V4.1-Flash.
- `Mensajes entre modelos/ESTADO-PARALELO.md`: sección del ciclo anexada al tope.

## 8. Estado del pool al cerrar

```
NUMEROS_DISPONIBLES: 400 libres (primero=1101)
Logs/*.md          : 1048 numeros
  !! COLISION 1097: ['1097-drift-totales-lote2_2026-09-19_22-42-38.md',
                      '1097-hy3-QA-CRUZADO-10-MODULOS_2026-09-19_22-46-31.md']
```

**La colisión 1097 es ajena** (nex-n2.5 vs hy3) y **no la toqué**: reportarla es la regla, resolverla
es de sus dueños. Mi 1094 no aparece como colisión.

## 9. Reportado y NO tocado (ajeno)

- **12 `|| true`** en `quality.yml` (líneas 130-142, 202, 212, 291) que silencian tests de otros
  módulos: falso verde heredado. No los toco porque activarlos puede poner el CI en rojo por fallos
  de otros y es decisión de sus dueños.
- **Byte NUL** en `CHECKLIST-GLOBAL.md` (offset 165941, **ya estaba en HEAD**): es lo que hace que git
  trate el archivo como **binario** y sus diffs sean invisibles. Tampoco toqué el `\x08` de la línea
  contigua.
- **Mojibake** pre-existente en `CHECKLIST-GLOBAL.md` (el emoji 🟢 está doble-codificado en 56 filas).
- `project.godot` línea 11: `"ï»¿config_version"` — un BOM doble-codificado como *nombre de clave*.
- **51 filas** de `CHECKLIST-GLOBAL.md` con número de celdas distinto de 13 (ajenas).

## 10. Lo que NO hice (honestidad obligatoria)

- **No cerré el módulo.** Falta el **QA cruzado §21.8**, que por regla **no puede hacer el autor**.
  Y ahora es más necesario que antes: el sello previo quedó invalidado por el hallazgo del §3.
- **No ejecuté los tests Play Mode** (§N: 30 min de sesión, teleport ×10, 500 bloques excavados,
  preset Baja con 4 GB) ni las **baselines** (§L): requieren mundo real y hardware objetivo.
- **No instrumenté contadores reales por sistema**: `BudgetRegistry.reportar_consumo()` ya existe,
  pero tienen que llamarlo M08/M43/M09.
- **No cablé el log del evento de evicción de atlas** (§K «atlas lleno»): la política devuelve qué
  evictó, el enganche al log lo tiene que hacer el llamador. Por eso ese ítem queda **sin marcar**.
- **No commiteé** `CHECKLIST-GLOBAL.md` ni `ESTADO-PARALELO.md`: el worktree acumulaba cambios ajenos
  sin commitear (**94 filas** en el global —una reescritura con mojibake distinto al de HEAD— y
  **1050 líneas** en el paralelo de 9+ agentes). Mis entradas quedaron anexadas en el worktree; el
  registro **autoritativo y commiteado** es este log. Misma decisión que en el Log 1024.

## 11. Recomendaciones para el próximo agente

- **Antes de creer un `[x]`, contar las casillas y abrir el artefacto que cita.** En este módulo hubo
  un `[x]` falso durante 18 días y una suite entera muerta dando verde.
- **Antes de firmar un §21.8, mirar que la suite pueda fallar.** Un `0 fallos (EXIT 0)` sobre una
  suite con `_check(true, …)` o con funciones abortadas por `SCRIPT ERROR` no es evidencia.
- **M90:** los presets ya existen y están validados; sólo hay que llamar `set_preset(nombre)`.
- **M08/M13/M32:** al crear recursos descargables, llamar `monitor.registrar_candidato_descarga()`;
  el enforcement ya se dispara solo desde `nivel_para()`.
