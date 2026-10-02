**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-19 (Log 1094)

# 06-Plan-Testings.md — Módulo 62: Memoria

> **Iter. 3 (Log 1094).** Este documento **no existía**: el módulo se cerró en iter. 1 sin plan de
> testings y en iter. 2 se agregaron suites sin declarar cómo se probarían. Se crea ahora.

## 1. Objetivo y alcance

Convertir en **checks ejecutables** lo que estaba afirmado en documentos, y —sobre todo— dejar de
depender de que un test "se vea verde". En este módulo ya se comprobó que **una suite entera puede
estar muerta y reportar 0 fallos** (ver `07-Resultados-Testings.md` §3).

**Alcance:** `scripts/rendimiento/memoria/` (8 scripts) + `data/rendimiento/budgets.json` + el
generador validante `generar_budgets.gd`.

**Fuera de alcance (con dueño):** `chunk_memory.gd` (M08), `audio_memory.gd` (M41-M44),
`scene_memory.gd` (M63), `memory_debug_panel.gd` (M110), los presupuestos definitivos de M61 y los
tests Play Mode del checklist §N (necesitan mundo real y hardware objetivo).

## 2. Herramienta

Godot 4.7.2 headless (el ejecutable es un **directorio** en este entorno):

```
"D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe" \
  --headless --path game/isla-ancestral \
  --script res://scripts/rendimiento/memoria/<suite>.gd
```

`--check-only --script` se usa para detectar errores de parseo sin ejecutar. Ojo: los runs `--script`
levantan **todos los autoloads**, así que la salida propia se separa por marcadores
(`^=== `, `^--- `, `^  \[OK\]`, `^  \[FAIL\]`) en vez de leerla entera.

## 3. Suites del módulo

| Suite | Checks | Cobertura | Guardián de 3 capas |
|---|---|---|---|
| `test_memoria_m62.gd` (núcleo, ox-alpha) | 27 | BudgetRegistry, GlobalPool, UnloadPolicy, getters del monitor | ✅ (agregado en iter. 3) |
| `test_enforcement_m62.gd` (iter. 2) | 47 | registry, escalonamiento por preset, enforcement niveles 1/2/3, alarma de pico | ✅ (reescrita en iter. 3) |
| `test_pool_iter2.gd` (iter. 2) | 25 | API única, auditoría de señales, fallback honesto, drenado | ✅ (agregado en iter. 3) |
| `test_memoria_m62_iter3.gd` (iter. 3) | 133 | dataset/presets, semáforo, enforcement, muestreo, drift, POI, pool, LeakGuard, texturas, descargas | ✅ (nueva) |
| `test_m62_liberacion.gd` (iter. 4) | 15 | presupuesto de liberación por refcount (pico por objeto, delta de lote), hilo principal, huérfanos en reposo | ✅ (nueva) |
| `test_memoria_m62_iter5.gd` (iter. 5) | 60 | handshake con M63 (el 62 no descarga lo que el 63 carga), cola de transición de escena, región rápida → fuerza liberación, audio diferido, atlas LRU con log, determinismo (RN9) | ✅ (nueva, probada con 5 sondas) |
| `generar_budgets.gd -- --check` | 20 | dataset vs diseño §2 (no es test de código: es **gate de datos**) | aborta sin escribir |

**Total de checks de código: 307.**

Además, **fuera de GDScript**, la iter. 4 agrega un auditor estático con su propio selftest:

| Herramienta | Checks | Cobertura | Anti-falso-verde |
|---|---|---|---|
| `scripts/auditar_arquitectura_m62.py` | 17 | componentes cíclicas, referencias fuera de orden, autoload duplicado, carga síncrona por frame | `--selftest` + guarda de ceguera (exit 3) |

## 4. Estrategia anti-falso-verde

En GDScript un `SCRIPT ERROR` **aborta la función en silencio**: el resto de sus checks no corre, y
una suite sin contador sigue diciendo «0 fallos». Defensa de 3 capas, implementada en las 4 suites:

1. **`_fin(nombre)` por bloque.** `_summary()` recorre la lista de bloques esperados y **nombra** el
   que no se ejecutó. Sin esto, un aborto se ve igual que "todo bien".
2. **Piso de checks `CHECKS_MINIMOS`, MEDIDO en verde.** No se copia una estimación: se corre la
   suite, se lee el conteo real y **ese** es el piso. Si un bloque aborta, sus checks desaparecen y
   el conteo cae por debajo del piso aunque no quede ningún `[FAIL]`. (En iter. 3 esto importó: un
   piso estimado en 60 contra 133 reales habría dejado pasar la pérdida de 73 checks.)
3. **`_summary()` en un `call_deferred` SEPARADO.** Un resumen que vive al final de `_run()` muere con
   `_run()`. Al estar en su propio `call_deferred` corre igual y cierra con `quit(1)`.

**Regla adicional:** `|| true` está prohibido en el gate de CI. El patrón es
`FAIL=0` + `|| FAIL=1` + `exit $FAIL`.

## 5. Prueba del guardián POR INYECCIÓN

Un guardián que nunca se probó en rojo no es un guardián. Para cada suite con las 3 capas se hizo una
**copia temporal** con una falla inyectada (un índice fuera de rango en un `PackedFloat32Array`, que
produce `SCRIPT ERROR` y aborta la función), se corrió y se exigió:

- que la suite **falle** (salida 1),
- que el bloque afectado **aparezca nombrado** en el resumen,
- que el conteo **caiga por debajo del piso**,
- y que los bloques posteriores sigan corriendo (el aborto es de la función, no del proceso).

Las copias se borraron después (si no, quedan como UNTRACKED).

## 6. Qué NO se prueba acá

- **Comportamiento en Play Mode** (checklist §N): sesión de 30 min con drift ≤ 5 %, teleport extremo
  ×10, 500 bloques excavados y regenerados, cambio de bioma de audio, preset Baja con 4 GB de RAM.
  Requieren el mundo real (M08/M09) y hardware objetivo.
- **Mediciones de baseline** (checklist §L): menú < 600 MB, spawn < 1600 MB, horizonte < 2200 MB,
  subterráneo < 2000 MB, tormenta ≤ 2500 MB. Requieren el juego corriendo.
- **El QA cruzado §21.8**, que por regla **no puede hacer el autor** del módulo.

## 7. La iter. 4 añade una capa que no es de runtime: el auditor estático

Las reglas de arquitectura de servicios y de carga síncrona son **propiedades estáticas del árbol de
archivos**: se deciden sin abrir el juego. Un test de runtime solo las detectaría cuando ya ocurren,
y una de ellas (una referencia fuera de orden) no «ocurre» de forma visible.

El auditor vive fuera de `res://` (`scripts/auditar_arquitectura_m62.py`, junto a
`verificar_binarios.py`) porque es herramienta de repo, no código del juego.

**Cómo se prueba a sí mismo.** `--selftest` construye proyectos Godot sintéticos y exige que las 4
reglas detecten defectos conocidos (componente cíclica, referencia fuera de orden, autoload
duplicado, `load()` en `_process`), más 3 casos de **ceguera** y un control positivo. En su primera
corrida el selftest **cazó 4 defectos del propio auditor**: `x.instantiate()` y `d.duplicate()` eran
indetectables (un lookbehind prohibía el punto delante, y esas dos son siempre llamadas a método), y
dos aserciones estaban mal escritas.

**Guarda de ceguera (exit 3).** Si el auditor no resuelve autoloads, o el grafo de servicios queda
con 0 aristas, o no encuentra ningún callback por frame, **no devuelve 0**: devuelve 3. Motivo
concreto: el 2026-09-20 el mismo detector reportó «0 ciclos» **dos veces siendo ciego** (primero por
resolver mal las rutas de los autoloads, después por no encontrar callbacks). Un «0» que no se puede
distinguir de «no miré» no es un aprobado.

**Lista de permitidos, visible.** Los hallazgos conocidos (BUG-068/BUG-069) están en `PERMITIDOS` con
su ID de bug, se imprimen en **cada** corrida y la clave es el hallazgo **exacto** (la componente por
sus miembros ordenados, la arista por par origen→destino): así un hallazgo NUEVO dentro de un archivo
ya permitido sigue tumbando la puerta. Si un arreglo deja una entrada obsoleta, el auditor lo avisa.

## 8. La iter. 5: guardián probado con 5 sondas y piso medido (no copiado)

`test_memoria_m62_iter5.gd` cubre lo que el handshake con M63 y los edge cases de §K necesitaban, en
**7 bloques (A–G) / 60 checks**. El piso `CHECKS_MINIMOS` arrancó como **placeholder (44)** y se fijó
en **60 tras la 1.ª corrida verde** — la regla es que el piso se **mide**, no se estima.

**Las 5 sondas (skill §4).** Copia temporal → inyección → correr → borrar. Cada sonda debe dar
**EXIT 1**; el control sin mutar, **EXIT 0**:

| Sonda | Inyección | Resultado medido |
|---|---|---|
| A | aserción falsa (`_check("...", 1 == 2)`) | `61 checks, 1 fallos` → EXIT 1 |
| B | `return` al inicio de `_run()` (ningún bloque corre) | `7 checks, 8 fallos` → EXIT 1 (capa 3 nombra los 7 bloques) |
| C | piso +1 (`CHECKS_MINIMOS := 61`) | `60 checks, 1 fallos` → EXIT 1 |
| D | `return` al inicio del bloque C (C–G sin cerrar) | `46 checks, 2 fallos` → EXIT 1 |
| E | suprimir un solo `_fin("A")` | `61 checks, 1 fallos` → EXIT 1 |

De la sonda B se verificó además el **exit code REAL del proceso** (no sólo el texto): `EXIT REAL = 1`,
con los 7 `[FAIL] el bloque X NO se ejecutó` impresos por la **capa 3** — la que corre en su propio
`call_deferred` aunque `_run()` haya abortado.

**Regresión.** Las 5 suites previas siguen verdes tras tocar `memory_monitor.gd`/`unload_policy.gd`:
`27 + 47 + 25 + 133 + 15 = 247` checks, 0 fallos, ×3 cada una.
