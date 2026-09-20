# Log 1112 — M62 Memoria, iteración 4: gates estáticos de arquitectura + presupuesto de liberación

- **Fecha:** 2026-09-20 01:12
- **Modelo:** DeepSeek-V4.1-Flash
- **Plataforma:** WorkBuddy
- **Módulo:** 62-Memoria (soporte de M61 Rendimiento)
- **Tipo:** iteración de cierre por medición + auditoría de arquitectura
- **Reserva:** **1112** (`scripts/reservar_log.py --reservar`; al reservar, `primero=1112`)
- **Checklist:** **93/150 → 98/150** (5 ítems cerrados, cada uno con medición) · 0 `[?]` · 52 `[ ]`
- **Bugs nuevos:** BUG-068, BUG-069
- **QA cruzado §21.8:** ⏳ **pendiente** (verificador ≠ autor)

---

## 1. Qué se hizo

| Artefacto | Qué es | Ubicación |
|---|---|---|
| `auditar_arquitectura_m62.py` | Auditor estático de arquitectura (servicios + carga síncrona), con `--selftest` y guarda de ceguera | `scripts/` (herramienta de repo, **fuera** de `res://`) |
| `test_m62_liberacion.gd` | Suite headless: presupuesto de liberación por refcount + huérfanos | `game/isla-ancestral/scripts/rendimiento/memoria/` |
| Job `architecture-guard` | Gate de CI nuevo (selftest + auditor), registrado en `summary` | `.github/workflows/quality.yml` |
| Gate de la suite | `test_m62_liberacion.gd` dentro del job `test-suite` | `.github/workflows/quality.yml` |

Los 5 ítems cerrados del checklist: **L190** (carga síncrona en gameplay), **L191** (pico de liberación
por refcount < 3 ms), **F/RN2** (deltas < 50 ms), **F/RN6** (nada bloquea el hilo principal),
**N** (nodos huérfanos estables en reposo).

---

## 2. Lo más importante del ciclo: medir cambió la conclusión TRES veces

### 2.1 La hipótesis de partida era falsa (y habría sido un BUG falso)

La idea inicial: «si un autoload hace `get_node_or_null("/root/X")` desde su `_ready()` y X se
declara **después**, la búsqueda devuelve **null**, `get_node_or_null` no avisa, y la rama se saltea
en silencio». Encaja con la regla de `service_registry.gd` («un servicio NO puede depender de otro de
nivel superior») y con el caso `SaveManager` (#8) → `Fishing` (#45), delta +37.

**Se midió antes de reportarlo.** Banco de pruebas propio (2 autoloads, `Alfa` #0 y `Beta` #1),
Godot 4.7.2 headless:

```
Alfa (indice 0) -> /root/Beta (indice 1) desde _init()    -> <Object#null>
   + ERROR: Can't use get_node() with absolute paths from outside the active scene tree.
Alfa (indice 0) -> /root/Beta (indice 1) desde _ready()   -> Beta:<Node#27011319242>
Alfa (indice 0) -> /root/Beta (indice 1) DIFERIDO 2 frames -> Beta:<Node#27011319242>
```

Conclusión: en `_ready()` Godot **ya instanció todos los autoloads**, así que la búsqueda **acierta**
aunque el destino se declare después. Y la falla desde `_init()` **no depende del orden**: `/root/...`
no resuelve ahí para **ningún** destino. Por tanto la regla A2 es **violación de capas + fragilidad
de mantenibilidad**, no un fallo de runtime. Queda escrito en el auditor y en BUG-069 **para que nadie
«arregle» un crash que no existe**.

### 2.2 El auditor nuevo tenía 4 defectos propios

El `--selftest` los cazó en su **primera** corrida, antes de que el gate llegara a CI:

1. `x.instantiate()` y `d.duplicate()` eran **indetectables**: el lookbehind prohibía un `.` previo
   (puesto para no marcar `ResourceLoader.load()`), pero esas dos son **siempre** llamadas a método.
2. El selftest esperaba que `_ready` fuera un callback por frame (**no lo es**): el analizador estaba
   bien y la aserción mal.
3. El fixture ponía `preload(...)` e `.instantiate()` en la **misma línea**, así que el control
   negativo de `preload` era ambiguo.

### 2.3 Una aserción de la suite era una suposición

`«liberar 2048 objetos chicos cuesta más en total que 256 grandes»` → **medido al revés**:
`ligero=2346 µs` vs `pesado=4270 µs`. Liberar bloques grandes es más caro por objeto. Y comparar los
**picos** por objeto resultó **inestable** (corrida 3: `pico_ligero=492 µs > pico_pesado=448 µs`), así
que la comparación se movió al **total**, que fue estable en las 3 corridas.

---

## 3. El auditor: reglas y anti-falso-verde

**Grupo A — grafo de servicios** (111 autoloads, 213 referencias explícitas `get_node*("/root/X")`):

- **A1** componentes fuertemente conexas (Tarjan). Se reporta la **SCC**, no cada ciclo: una componente
  de 7 nodos contiene decenas de ciclos y enumerarlos vuelve inestable cualquier lista de permitidos.
- **A2** referencias a un autoload declarado **después**, alcanzables desde `_ready()` (recorrido de
  llamadas intra-archivo, profundidad 4).
- **A3** el **mismo script** registrado como dos autoloads.

**Grupo B — carga síncrona**: `load()`, `ResourceLoader.load()`, `instantiate()`, `duplicate()` dentro
de `_process` / `_physics_process` / `_input` / `_unhandled_input` / `_unhandled_key_input` /
`_integrate_forces`.

**Guarda de ceguera (exit 3).** Si no resuelve autoloads, o el grafo queda con **0 aristas**, o no
encuentra **0 callbacks por frame**, el auditor **no devuelve 0**: devuelve 3. Motivo concreto y
medido: el **2026-09-20 el mismo detector reportó «0 ciclos» dos veces siendo ciego** — la primera
porque resolvía mal las rutas de los autoloads (los 111 quedaban «sin archivo») y la segunda porque
no encontraba callbacks por frame. Un «0» indistinguible de «no miré» no es un aprobado.

**Lista de permitidos visible.** Los hallazgos conocidos viven en `PERMITIDOS` con su ID de bug, se
**imprimen en cada corrida**, y la clave es el hallazgo **exacto** (la componente por sus miembros
ordenados; la arista por par origen→destino): así un hallazgo **nuevo** dentro de un archivo ya
permitido sigue tumbando la puerta. Si un arreglo deja una entrada obsoleta, el auditor lo avisa.

---

## 4. Resultados medidos

### 4.1 Auditor — 17 checks de selftest, 0 fallos

```
fixture: se leen los 3 autoloads declarados
A1 detecta la componente ciclica {Alfa, Beta}
A3 detecta que Alfa y AlfaAlias son el MISMO archivo
A3 NO inventa un ciclo Alfa <-> AlfaAlias (mismo archivo, no es dependencia)
A2 detecta Alfa -> Beta (Beta se declara DESPUES)
A2 lo marca como alcanzable desde _ready via llamada
A2 NO reporta Beta -> Alfa (Alfa se declara ANTES: es legal)
B1 detecta load() en _process
B2 detecta instantiate() en _process (llamada a metodo, con punto delante)
B3 detecta duplicate() en _process (llamada a metodo, con punto delante)
control negativo: el load() de _ready NO se marca (la regla es solo callbacks por frame)
control negativo: preload() NO se marca (es constante de compilacion, no carga)
B cuenta los archivos y los callbacks por frame del fixture (3 archivos, 1 callback)
ceguera 1: proyecto sin autoloads -> se declara CIEGO
ceguera 2: autoload declarado sin archivo -> CIEGO
ceguera 3: grafo con 0 aristas -> CIEGO (0 ciclos no es lo mismo que 'no mire')
ceguera 4: el fixture con defectos NO se declara ciego (control positivo)
=== Selftest: 0 fallos ===
```

Auditoría real (estricta): **exit 0**, 0 hallazgos nuevos, 12 permitidos.

```
-- Grupo A: grafo de servicios
   autoloads declarados ....... 111
   aristas explicitas ......... 213
   AUTOLOAD DUPLICADO ......... HardwareManager, hardware -> scripts/hardware/hardware_manager.gd [permitido BUG-068]
   componentes con ciclo ...... 2
   refs fuera de orden ........ 9  (regla de capas; medido: en _ready no falla)
     componente de 7: CollectionRegistry, Fishing, GameTime, Inventario, SaveManager, TimeCalendar, Weather
     componente de 2: ThemeService, UIManager
     orden: SaveManager   (#8 ) -> Fishing          (#45) delta=+37
     orden: Localization  (#37) -> DataStore        (#71) delta=+34
     orden: Friendship    (#15) -> VillagerManager  (#23) delta=+8
     orden: WorldState    (#1 ) -> SaveManager      (#8 ) delta=+7
     orden: TimeCalendar  (#9 ) -> GameTime         (#16) delta=+7
     orden: AudioConfig   (#64) -> DataStore        (#71) delta=+7
     orden: UIManager     (#19) -> ControlInput     (#24) delta=+5  DIRECTO en _ready
     orden: ShopManager   (#13) -> GameTime         (#16) delta=+3
     orden: Friendship    (#15) -> GameTime         (#16) delta=+1

-- Grupo B: carga sincrona en callbacks por frame
   archivos .gd revisados ..... 800
   funciones por frame ........ 79
   hallazgos .................. 0
```

### 4.2 Suite de liberación — 15 checks, 0 fallos, ×5 idénticas

Metodología anti-trampa-78: **rondas intercaladas** (las 2 variantes en cada ronda) y **mínimo por
variante**; después 5 corridas para comprobar que el signo no cambia.

| Variante | Objetos | Payload | Pico por objeto (límite 3 ms) | Lote completo (límite 50 ms) |
|---|---|---|---|---|
| ligera | 2048 | 4 KB (8 MB) | 0,279 – 0,492 ms | 2,1 – 3,4 ms |
| pesada | 256 | 256 KB (64 MB) | 0,414 – 0,448 ms | 3,9 – 5,8 ms |

RN6 se cumple con margen: el pico de **una** operación (≤ 0,492 ms) está muy por debajo de un frame a
60 FPS (16,67 ms). **Huérfanos**: base 0, estable en 5 muestras, 128 nodos sin padre contados
(0 → 128) y liberados (128 → 0, sin leak).

### 4.3 Guardián probado POR INYECCIÓN

Inyección: `var _x: Node = load("res://.../unload_policy.gd").new()` al principio de `_run()`
(asignar un `RefCounted` a un `Node` aborta la función).

```
SCRIPT ERROR: Trying to assign value of type 'RefCounted' to a variable of type 'Node'.
   at: _run (.../_tmp_inject_m62.gd:109)
  [FALLO] los 4 bloques se completaron — no terminaron: ["A", "B", "C", "D"]
  [FALLO] solo 1 checks ejecutados (minimo 15)
-- checks por bloque: {  }
=== Resumen M62 liberacion: 1 checks, 2 fallos ===
RC=1
```

Las 3 capas funcionan: el `SCRIPT ERROR` **aborta la función** (por eso sus checks no corren y nunca
fallan — trampa 85), `_summary()` **nombra** los 4 bloques que no terminaron, y el **piso** salta.
Además **termina con exit 1 sin colgarse**, que es lo que verifica el `call_deferred` separado
(trampa 61). El archivo inyectado y su `.uid` se borraron al terminar.

---

## 5. Hallazgos escalados (no son míos para arreglar)

### BUG-068 — `hardware` y `HardwareManager`: el mismo script como dos autoloads

`project.godot` registra `scripts/hardware/hardware_manager.gd` **dos veces** (nombres `hardware` y
`HardwareManager`). Godot crea **una instancia por entrada** — medido con banco de pruebas propio:

```
Gamma    instance_id=27363640780  contador=42
GammaDos instance_id=27430749646  contador=42
son el MISMO objeto? false
```

Impacto: el arranque parsea `hardware_profiles.json` dos veces y llama a `_registrar_servicio()` dos
veces (la segunda dispara el `push_warning` de `ServiceRegistry.register()`). Y **ninguno de los dos
nombres se usa** (`grep '"/root/hardware"'` → 0; `grep '"/root/HardwareManager"'` → 0): peso muerto
duplicado más una trampa latente si alguien empieza a usar los dos. **Fix de 1 línea:** borrar una de
las dos entradas de `[autoload]`.

### BUG-069 — Grafo de servicios: 2 componentes cíclicas y 9 referencias fuera de orden

Deuda arquitectónica. **Sin fallo de runtime medido** (§2.1). El ítem del checklist que cubre esto
(ciclos entre servicios) **queda abierto a propósito**: los ciclos existen, así que marcarlo sería un
`[x]` falso. El gate los tiene en lista de permitidos para que **ningún ciclo nuevo** entre.

---

## 6. Verificación

- Auditor: `--selftest` **17/17**, exit 0 · auditoría estricta exit 0 (0 hallazgos nuevos).
- Suite: **15 checks / 0 fallos / ×5 corridas idénticas**, exit 0.
- Inyección: 1 check / 2 fallos / exit 1 / sin colgarse.
- Gates de CI: **2 nuevos** (job `architecture-guard` + la suite en `test-suite`).
- `quality.yml` tenía **2 hunks ajenos** en el worktree (BUG-051 de atria-dawn; gates de M64/M11), así
  que el commit se construyó como **`HEAD` + solo mis líneas** (`hash-object -w` +
  `update-index --cacheinfo`). Verificado en el blob staged: `BUG-051` → **0**, `test_ia_npc_m64_iterN`
  → **0**. Igual con `11-BUGS.md` (327 líneas ajenas en el worktree: `BUG-063/064/065/066` → **0** en
  el blob).
- `CHECKLIST-GLOBAL.md` y `ESTADO-PARALELO.md` **NO se commitearon**: el worktree tiene cambios ajenos
  y en `CHECKLIST-GLOBAL.md` la fila 62 ya estaba reescrita por atria-dawn con la reasignación, así que
  commitear desde `HEAD` habría **revertido su trabajo**. Mis entradas quedan anexadas en el worktree.

---

## 7. Qué NO hice (honestidad obligatoria)

- **No marqué el ítem de ciclos** (E97): los ciclos existen.
- **No arreglé los ciclos ni el autoload duplicado**: son archivos de otros módulos (M115, M59,
  M41-M44, M91). Reporto con evidencia y fix propuesto.
- **No medí el frame completo con render** (eso es M61), ni las baselines de §L, ni la integración real
  con M08/M09/M41-M44/M63: siguen dependiendo de mundo real y de que otros módulos reporten consumo.
  Los ~52 `[ ]` que quedan son casi todos de ese tipo.
- **QA cruzado §21.8 sigue pendiente** y no puede hacerlo el autor.

---

## 8. Para el siguiente agente

- El auditor tiene **guarda de ceguera** (exit 3). Si lo tocás, corré `--selftest` **antes** de confiar
  en él: en su primera corrida se encontró 4 defectos propios.
- Los `PERMITIDOS` de `auditar_arquitectura_m62.py` citan BUG-068/BUG-069. Al arreglar uno, borrá su
  entrada: el auditor avisa cuáles quedaron obsoletas.
- **`get_node_or_null` desde `_ready()` no falla por orden de declaración** (medido). No abras un bug
  por eso. Lo que sí falla es `/root/...` desde `_init()` — y falla para cualquier destino.
