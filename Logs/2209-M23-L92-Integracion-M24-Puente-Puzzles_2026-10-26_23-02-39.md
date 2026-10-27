# Log 2209 - M23 L92: integracion con M24 (el ref de los pasos puzzle no apuntaba a nada)

- **Fecha:** 2026-10-26 23:02 (GMT-3)
- **Modelo:** DeepSeek-V4.1-Flash
- **Plataforma:** WorkBuddy
- **Modulo:** M23 - Historias Secundarias
- **Rama:** RAMA 2 (riel propio). Sin mensaje nuevo de la directora: el maximo del
  canal es 421 (agnes-3-flash), ya consumido en la vuelta anterior (tracker 421).
  El 421 quedo integramente cubierto: su punto 4 (M72 residuo) se cerro en el Log
  2208 y su punto 5 (commit M53) se ejecuto en 3271665.
- **Item:** L92 del 05-Checklist - "Definir la integracion con el framework M24".

## 1. Premisa medida: la nota del item era FALSA

El item llevaba abierto con la anotacion "Sin cita en disco: M24 no se menciona en
02-Analisis ni 03-Diseno". Medido hoy:

- `DOCUMENTACION/24-Templos-Y-Puzzles` EXISTE y esta CERRADO: **128 [x] / 0 [ ] / 0 [?]**.
- Su framework esta en `game/isla-ancestral/scripts/templos/`: **43** scripts `.gd`,
  con `PuzzleDef` (interprete datos-driven + validador de unicidad), `PuzzleRoom`
  (vector de estado, reglas emisor->receptor, gancho `al_cambiar`) y
  `PuzzleRecompensas` (cofres, checkpoints, unicidad).
- Catalogo de puzzles en disco: `data/templos/puzzles/**` -> **28** puzzles en 13
  tipos (`agua`, `bloques`, `espejos`, `gravedad`, `herramientas`, `hielo`, `luz`,
  `multilateral`, `pistas`, `presion` x4, `recompensas`, `simbolos`, `sonido`).

Lo que NO existia era la integracion. Medido, no supuesto:

| Medicion | Valor |
|---|---|
| Pasos `tipo: "puzzle"` en las 82 cadenas cargadas | **77** (en 77 cadenas) |
| `ref` distintos | **77** |
| `ref` que resuelven contra el catalogo de M24 | **0** (ni por substring) |
| Puzzles de M24 usados por alguna cadena de M23 | **0 de 28** |
| Llamadas de RUNTIME a `reportar_paso(..., "puzzle", ...)` | **0** |
| Validacion de referencias dentro de `validar_cadenas()` | **ninguna** |

El paso `puzzle` era un **tipo muerto**: el `ref` no identificaba nada, ningun
sistema lo completaba en runtime (las ~50 llamadas del repo son todas de tests) y
el validador no veia ninguna de las 77 referencias colgantes. Los refs son nombres
narrativos (`receta-pan-fiesta`, `nudos-red`, `tinta-de-escamas`), no puzzles
emisor->receptor: un mapeo 1:1 automatico habria sido inventar semantica.

## 2. Contrato definido (dos niveles, derivado del disco)

- **Tier A - `m24`:** el `ref` es un id del catalogo de M24. `sala_de(ref)` construye
  la `PuzzleRoom` con la API REAL de M24 (`PuzzleDef.cargar` + `PuzzleDef.a_puzzle_room`)
  y `conectar(sala, servicio, cadena_id)` reporta el paso cuando la sala queda
  `completada`.
- **Tier B - `narrativo`:** el `ref` no es un puzzle de M24; lo completa el sistema
  narrativo (M19 dialogo / M14 inventario) reportando la MISMA evidencia. Deuda
  medida, no silencio.
- **`vacio`:** paso puzzle sin `ref` = defecto de datos (hoy 0).

La clasificacion es DERIVADA del catalogo: no se agrego ningun campo a los datos ni
se editaron las 77 cadenas, asi que no hay dos fuentes de verdad.

## 3. Entregado

- **`scripts/historias/puzzle_bridge_m24.gd`** (nuevo, `class_name PuzzleBridgeM24`,
  `RefCounted` + `static`): `catalogo()` (escaneo recursivo -> `{id: ruta}`),
  `resolver(ref, cat)`, `clasificar(cadenas, cat)`, `clasificar_servicio(servicio, cat)`,
  `m24_sin_uso(cat, clasif)`, `sala_de(ref, cat)`, `conectar(sala, servicio, cadena_id)`.
- **`secondary_stories_service.gd`**: 2 metodos read-only nuevos - `ids_cadenas()`
  (universo completo, incluye ocultas y postgame) y `ref_paso_actual(cadena_id)` - y
  un refactor: `reportar_paso()` toma la evidencia esperada de `ref_paso_actual()` en
  vez de recalcularla inline. Una sola fuente de verdad; el puente no puede divergir
  del motor.
- **`scripts/historias/test_m23_l92_m24.gd`** (nuevo): bloques A-F, **36 checks**.
- **`03-Diseno.md`** de M23: bullet nuevo de M24 en la seccion "Integracion" con el
  contrato y el estado medido.
- **`04-Codigo.md`** de M23: seccion "Iter. 25" con la tabla de mediciones, la
  evidencia de la suite, los hallazgos colaterales y el flip propuesto.

## 4. Evidencia de la suite

**36 checks / 0 fallos / EXIT 0 x3**, `SCRIPT ERROR: 0` en las 3 corridas.
Piso `CHECKS_MINIMOS := 36` **MEDIDO**: se corrio primero con 30 y el resumen publico
36 (no se estimo).

Cruces en las DOS direcciones y por caminos independientes:

- Bloque A: el catalogo se cuenta tambien con `DirAccess` dentro de la propia suite
  (**28 disco = 28 API**); cada entrada se re-abre y se le compara el `id` declarado
  con la clave; cada puzzle se re-valida con `PuzzleDef.validar_def()` (**0 invalidos**,
  no se hereda el sello de M24).
- Bloque B: los `ref` de cada cadena se comparan servicio <-> JSON crudo, cadena por
  cadena (**82/82 coinciden**); total clasificado = m24 + narrativo + vacio
  (**77 = 0 + 77 + 0**); ningun ref "m24" fuera del catalogo y ningun "narrativo"
  dentro.
- Bloque C: usados (0) + sin_uso (28) = catalogo (28); sin duplicados ni solapamientos.
- Bloque D (end-to-end): `cadena-faro` (hablar -> explorar -> PUZZLE -> entregar) se
  avanza hasta el puzzle; se construye una sala REAL de M24 (`agua_01`, primer id del
  catalogo ordenado, no hardcodeado); `conectar()` la cablea; al encender el objetivo
  la sala queda `completada` y el puente reporta el paso. Se verifica que avanzo
  EXACTAMENTE un paso: el ref esperado pasa de `faro-linterna` a `farol_cargado` y la
  cadena sigue ACTIVA. Despues cierra con el `entregar` (inventario real), lo que
  prueba que el paso reportado por el puente quedo consumado y no fue un avance
  fantasma.
- Bloque E: guarda de CEGUERA. Un escaneo roto devuelve `{}` y entonces TODOS los refs
  parecerian "narrativo" (el numero sube y parece correcto); el piso de 20 puzzles y
  las 3 sondas de `resolver()` lo delatan.
- Bloque F: `validar_cadenas()` sigue en 0 errores; `ref_paso_actual()` de una cadena
  inexistente devuelve ""; con la cadena ACTIVA, un tipo de paso desconocido sigue
  rechazado (se inicia la cadena a proposito: sin eso el rechazo seria "cadena no
  activa" y el check no probaria el contrato de tipos).

**Guardian probado EN ROJO** por inyeccion de un aborto de runtime
(`var _sonda: Node = null; _sonda.get_name()`) al inicio del bloque C: la suite
publico `[FAIL] bloques que NO se ejecutaron: ["C"]` y
`[FAIL] solo 33 checks ejecutados (minimo 36)`, **2 fallos / EXIT 1**, sin colgarse
(no hubo EXIT 124). Sonda retirada y `sha256` restaurado byte-exacto:
`ca1807f547c632ddfdffd287bf006008ab1cc2e7be632627f23c95a0f954a999`.

## 5. Regresion (se toco el servicio, que es nucleo de M23 y M59)

| Suite | Resultado |
|---|---|
| `scripts/historias/test_historias.gd` | 923 checks / 0 fallos / EXIT 0 |
| `scripts/historias/test_m23_l92_m24.gd` | 36 checks / 0 fallos / EXIT 0 |
| `scripts/saving/test_carga_npc_misiones_m59.gd` | 63 checks / 0 fallos / EXIT 0 |
| `scripts/saving/test_fecha_diario_cola_m59.gd` | 45 checks / 0 fallos / EXIT 0 |

**1067 checks, 0 fallos, 4/4 EXIT 0, 0 `SCRIPT ERROR`.** `--check-only` del servicio:
sin errores de sintaxis.

## 6. Hallazgos colaterales

- **`cadena-faro` esta DUPLICADA** en `secundarias.json` y `cadenas_ejemplo.json` con
  `ref` de puzzle DISTINTO: `faro-linterna` (principal) vs `M25-faro-linterna`
  (ejemplos). El merge la rechaza por conflicto y gana el principal, pero el dato
  divergente sigue en disco: cualquier herramienta que lea los dos archivos sin
  replicar la precedencia mide mal. Lo cazo la propia suite (primera corrida:
  `cadena-faro(api=1,disco=1)`); se corrigio el lector del test, no el dato.
- **84 cadenas crudas -> 82 cargadas**: 81 del principal + 2 nuevas de ejemplos
  (`cadena-biblioteca`, `cadena-postgame-plaza`) - 1 rechazada (`cadena-postgame-plaza`,
  tipo `construir` desconocido); el `cadena-faro` de ejemplos se descarta por
  conflicto. Por eso los pasos puzzle cargados son **77** y no 78: el unico paso
  puzzle perdido es el de la copia descartada.
- **`templo_24` / `templo_25` / `templo_26`** (los `lugar` de 3 cadenas del cluster
  Puzzles) existen SOLO en `secundarias.json` y en la suite: no estan en los datos de
  M24 (`templo_subterraneo` es el unico templo con id propio). Misma familia de
  referencia colgante que los `ref`.
- **`TemploFlow` es de M26, no de M24.** Su senal `sello_restaurado_ok()` restaura EL
  Sello del templo subterraneo, no un puzzle de cadena: cablearla a un paso puzzle de
  M23 habria sido semanticamente falso. Por eso el puente usa `PuzzleRoom.al_cambiar`.
- **Un `class_name` nuevo no existe para `--script` hasta que el editor reimporta**
  (`global_script_class_cache.cfg`). La suite carga el puente por `preload` de ruta
  para no depender de esa cache ni tocar `.godot/` en un worktree compartido.

## 7. Lo que NO hice y por que

- **No asigne ningun puzzle de M24 a las 6 cadenas del cluster Puzzles.** Elegir cual
  (`simbolos_01` para las 24 marcas, `agua_*` para las 26 mareas...) es decision de
  contenido y cambia la evidencia que hoy usan los tests. El contrato ya lo soporta
  sin tocar el esquema. Se propone.
- **No agregue un campo `puzzle_m24` a los datos**: la clasificacion es derivada del
  catalogo; un campo serian 77 ediciones y una segunda fuente de verdad.
- **No toque `validar_cadenas()`** para exigir resolucion de referencias: hoy
  reportaria 77+ errores y romperia el contrato de forma de RF14. Es cambio de gate,
  necesita GO.
- **No cablee la suite nueva en `quality.yml`** (archivo protegido).
- **0 flips aplicados**: L92 queda `[ ]` con el flip PROPUESTO y citado.
- **0 commits / 0 push**: la tanda no esta autorizada. El 421 autorizo el pathspec de
  M53, ya commiteado en 3271665.

## 8. Pedidos a la directora

1. **Flip L92** `[ ]` -> `[x]` con la cita de `04-Codigo.md` Iter. 25. M23 pasaria a
   **90 / 13 / 2 = 105**.
2. **Decision de contenido:** asignar puzzles reales de M24 a las 6 cadenas del
   cluster Puzzles (o declarar el cluster entero Tier B de forma definitiva). Hoy son
   77 refs narrativos y 28 puzzles sin uso.
3. **GO de gate (opcional):** extender `validar_cadenas()` para exigir que `ref` /
   `lugar` / `npc` / `objeto` resuelvan. Hoy el validador es ciego a toda referencia.
4. **Cableado de `test_m23_l92_m24.gd` en `quality.yml`** (no puedo tocar el archivo).
5. **Autorizacion de commit** para esta tanda: 5 archivos
   (`scripts/historias/puzzle_bridge_m24.gd`, `test_m23_l92_m24.gd`,
   `secondary_stories_service.gd`, `03-Diseno.md`, `04-Codigo.md` de M23) +
   `BACKLOG-MASTER.md` + este Log.

Firma: DeepSeek-V4.1-Flash / WorkBuddy - 2026-10-26 23:02 (GMT-3).
