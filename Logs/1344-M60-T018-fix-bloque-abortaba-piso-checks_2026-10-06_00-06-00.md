# Log 1344: M60 T-018 - el bloque del test FALLABA y ABORTABA; fix del test + piso de checks

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-06 00:06:00 (UTC)  [local -0300: 2026-10-05 21:06]
**Modulo:** M60 (Datos y Serializacion) - bloque T-018 (BuildingsSaveProvider)
**Tarea:** corregir los 6 fallos de M60 en CI (asignada por el director, msg 1340)
**Estado:** CERRADO - test verde en disco, sin cambios de produccion

## 1. Encargo

El director (msg 1340) reporto que M112 bajo de 26 a 11 fallos y que **6 de esos 11 son de M60**:
`test_datos_m60_iter3.gd`, bloque T-018, que se escribio asumiendo que M17 no estaba implementado.
Diagnostico del director: el test restaura un `{"id":"x"}` en el `BuildManager` global y los checks
siguientes ven la "x" residual. Alcance: aislar el estado del BuildManager o mockear la fuente.

## 2. Diagnostico MEDIDO (no supuesto)

Corrida real: `godot --headless --script scripts/datos/test_datos_m60_iter3.gd`.

```
=== Resumen M60 iter. 3: 130 checks, 6 fallos ===   EXIT 1
```

Los 6 fallos, todos en el bloque `BuildingsSaveProvider`: L252, L255, L256, L257, L258, L259.

Causa doble:

1. **El test media el autoload, no su fuente.** `BuildingsSaveProvider.fuente()` recorre
   `root.get_children()` y devuelve el PRIMER hijo con `obtener_estructuras()`. El bloque se
   escribio cuando M17 no existia; ahora **M17 SI existe** (`scripts/construccion/build_manager.gd`,
   autoload `Construccion`, `project.godot:134`) y **gana la carrera** contra el `FuenteFake` que el
   test agrega despues. => `get_save_data()`/`restore_save_data()` operaban sobre el autoload real
   (5 checks en rojo). El restore de la "x" iba al autoload persistente, como dijo el director.
2. **Aborto silencioso (hallazgo nuevo).** Con `fake.restauradas` vacio,
   `fake.restaurradas[0]["pos"]` disparaba:
   `SCRIPT ERROR: Out of bounds get index '0' (on base: 'Array')`
   => **el helper MORIA y perdia sus 2 ultimos checks sin contarlos como fallo**. Por eso el resumen
   decia **130** y no 132 (el conteo documentado en las docs de M60).

**El punto 2 importa mas que el 1:** el bloque no solo fallaba, **abortaba**. Un aborto que no
produce fallos = falso verde (la leccion del proyecto).

## 3. Fix (SOLO el test; produccion intacta)

Archivo: `game/isla-ancestral/scripts/datos/test_datos_m60_iter3.gd` (+52 / -1).

- **`class ProviderInyectable extends BuildingsSaveProvider`**: override de `fuente()` para
  **inyectar** la fuente. El bloque queda determinista sin tocar produccion (opcion "mockear la
  fuente" del director).
- **Check nuevo (2):** documenta el wiring REAL -> M17 (autoload `Construccion`) es la fuente por
  duck-typing y expone `obtener_estructuras()` + `restaurar_estructuras()`.
- **Piso medido `CHECKS_MINIMOS := 134`** + guardia en `_summary()`: si un helper aborta y se pierden
  checks, el resumen pasa a ROJO en vez de reportar "0 fallos".

## 4. Verificacion

### 4.1 Guardian probado EN ROJO (inyeccion de aborto, corridas reales)

| # | Estado | Resultado | Exit |
|---|---|---|---|
| 1 | Aborto inyectado + piso presente | `120 checks, 0 fallos` -> `FALLIDO - solo 120 checks (piso 134): un bloque aborto en silencio` | **1** |
| 2 | Aborto inyectado + piso RETIRADO (contrafactual) | `120 checks, 0 fallos` -> `TEST OK - todos los checks pasaron` | **0 (FALSO VERDE demostrado)** |
| 3 | Aborto retirado | `134 checks, 0 fallos` | **0** |

El caso 2 es la prueba de que el piso no es decorativo: sin el, el aborto produce un **falso verde**.

### 4.2 Determinismo y regresion

- `test_datos_m60_iter3.gd`: **134 checks, 0 fallos, 0 SCRIPT ERROR, exit 0** en **x3** corridas.
- Regresion M60: `test_datos_m60.gd` **94/0** - `iter3` **134/0** - `iter4` **152/0** = **380/0**.

### 4.3 Docs actualizadas (conteos de referencia)

- `07-Resultados-Testings.md`: tabla sec.1 (132 -> 134, TOTAL 378 -> 380) + **sec.1-bis nuevo** con el
  diagnostico, el fix, la tabla del guardian en rojo y la medicion x3.
- `04-Codigo.md`: 5 lineas de referencia (arbol de archivos, invocacion, narrativa, "Tests:" x2).
- `06-Plan-Testings.md`: fila de la tabla del suite.
- **NO se tocaron** los registros historicos fechados (`05-Checklist.md` lineas 1/17/21/33, que
  describen el estado del 2026-09-15 / Log 916).

## 5. Alcance / lo que NO se hizo

- **Produccion intacta**: `buildings_save_provider.gd` y `build_manager.gd` sin cambios. El provider
  "esta funcionando bien" (lo confirma el check nuevo).
- **No se cableo nada a CI**: el test ya estaba en `quality.yml:297`; solo se corrigio su contenido.
- **No se sello 21.8**: la verificacion independiente es de otro agente.

## 6. Efecto esperado en M112

Los 6 fallos de M60 deberian desaparecer del job M112 (26 -> ~5). No lo puedo medir localmente (M112
es un job de CI); queda anotado para el director.

## 7. Hallazgo lateral: el pool del worktree estaba corrupto (BOM + CRLF)

Al reservar, `reservar_log.py --estado` reporto `BOM en NUMEROS_DISPONIBLES.txt: el primer numero
(1342) queda invisible al asignador`. Medido por bytes:

```
HEAD:     31 33 34 31 0a            ("1341\n", LF, SIN BOM)
worktree: ef bb bf 31 33 34 32 0d   (BOM + "1342\r", CRLF)
```

Residuo del restore de agnes (truncado + restaurado desde HEAD). Consecuencia: **1342 invisible**
-> el asignador lo salta. Al reservar con `reservar_mensaje.py`, el script consumio **1343** y
reescribio el pool **limpio (LF, sin BOM)**; el 1342 se perdio como numero (era invisible). **NO se
toco el pool a proposito** (es del coordinador y no se commitea). Reportado al director en el canal
1343.

## 8. Numeracion / pool

- Mensaje al director: **1343**. Log: **1344**. Cabeza tras mis reservas: **1345**.
- El pool NO se commitea.

## 9. Huella de push (AGENTS sec.4.3)

- **Push principal:** `<pendiente de medir>` -> `main` (fast-forward, sin `--force`).
  Fecha/hora: 2026-10-06 ~00:10 UTC. Ejecutante: DeepSeek-V4.1-Flash.
- Commits propios: el fix del test + docs M60 + el canal 1343 + este Log.
- Commits ajenos en el rango: **por medir** en la salida del push.
