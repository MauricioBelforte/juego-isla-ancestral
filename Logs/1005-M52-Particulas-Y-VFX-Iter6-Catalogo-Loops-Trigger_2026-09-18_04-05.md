# Log 1005: M52 Partículas y VFX — iter. 6: catálogo completo, schema verificable, loops y trigger

**Fecha:** 2026-09-18
**Hora:** 04:05
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Reserva:** 1005 (liberada al cerrar)
**Módulo:** M52-Particulas-Y-VFX

## Resumen

Iteración 6 de M52. Se cierran **49 ítems** del `05-Checklist.md` atacando los tres huecos que
la iter. 5 había dejado abiertos y que estaban **en mi zona de encaje** (datos estructurados,
tooling, validación headless):

1. **Catálogo 8 → 31 entradas**, cubriendo **24/24** nombres del plan maestro, con **20 campos**
   por efecto.
2. **Reglas del plan verificables por código**: `vfx_schema.gd` pasa de 6 validaciones a las
   reglas RF3/RF4/RF6/RF7/RF11/RF14/RF16, con **16 mutaciones probadas por inyección**.
3. **Dos sistemas nuevos**: `vfx_loops.gd` (culling por radio, LOD 25%, fase fija, una zona =
   un emisor) y `vfx_trigger.gd` (punto único evento → VFX).

**Resultado: 88/148 → 137/148.** Totales reales medidos: **137 [x] · 10 [ ] · 1 [?]**.

El módulo **no sube a ✅**: el **QA cruzado §21.8 de la iter. 6 sigue pendiente** (verificador ≠
autor). El sello §21.8 que tiene la fila global es el de la **iter. 5** (Log 886, hy3).

## Punto de partida

M52 estaba en **88 [x] · 52 [ ] · 8 [?]**. La iter. 5 (Log 882) había cerrado el pooling, el
determinismo por semilla, los límites y el log `VFX-SKIP`, pero dejaba:

- el catálogo en **8 de los 25** efectos del plan,
- **5 `[?]`** que eran `[?]` por un hueco **mío** (no de otro módulo): "auditoría iter. 5: sin
  entrada en `vfx_catalog.json`",
- `vfx_loops`, el LOD y `vfx_trigger` sin implementar.

Ese es el punto clave de la curación: los `[?]` de la iter. 5 no tenían dueño externo. Los
**10 `[ ]` que quedan** sí son de otro (preset M90, timelines M48, UI M53, Reduce Motion M58,
calibración visual, QA §21.8).

## 1. Catálogo: 8 → 31 entradas

`game/isla-ancestral/data/vfx/vfx_catalog.json`, `version: 2`, **17039 bytes**, LF, sin BOM.

| Métrica | Valor |
|---|---|
| Entradas | **31** (24 del plan + 2 extras preexistentes + 5 derivadas) |
| Nombres del plan cubiertos | **24/24** |
| Loops | 12 |
| Con `bus` real (EventBus) | 21 |
| Con `dueno_evento` (RF6 pendiente) | 10 |
| Tipos distintos | 24 |
| Categorías | 6 (`ambiental`, `clima`, `estacional`, `impacto`, `magia`, `ui`) |

**Discrepancia reportada, no resuelta por mí:** el checklist RF1 pide "listar los **25** efectos
del plan maestro", pero `plan-inicial/04-Codigo.md:149` enumera **24** nombres. Cubrí los 24 y
**reporto** el desajuste; no inventé un 25º efecto para cuadrar el número.

`vfx_polen` (el único id referenciado por otros archivos) conserva `cantidad 150`, `tipo
flotante` y `color #F4E04D`, así que los contratos previos siguen válidos.

### Corrección de la taxonomía

La iter. 5 usaba `atmosferico` como **categoría** además de como **tipo**, agrupando cosas
distintas con la misma etiqueta. Se separaron los ejes: `tipo` (forma del efecto) y `categoria`
(dónde se usa) son conjuntos cerrados **distintos**. `magia` y `ui` aparecen legítimamente en
los dos — son ejes ortogonales, no una duplicación.

## 2. `vfx_schema.gd`: reglas verificables

| Regla | Qué exige | Ítem |
|---|---|---|
| RF3 | `presupuesto >= cantidad` | — |
| RF4 | loop con `fase` en `[0,1)` | L61/L146 |
| RF6 | sin `bus` ⇒ hace falta `dueno_evento` | L135 |
| RF7 | `luz_por_particula == false` | L82/L134/L194 |
| RF11 | `parpadeo_hz <= 10` | L110 |
| RF14 | loop ⇒ `radio > 0`; no-loop ⇒ `radio == 0` | L125 |
| RF16 | id `vfx_<snake_case>` (M108) | L132/L140 |
| RF1 | los 24 nombres del plan cubiertos | L25/L190 |

Los conjuntos cerrados están **duplicados a propósito** en el generador: uno valida al escribir,
el otro al leer. Si divergen, uno de los dos falla.

## 3. `vfx_loops.gd` y `vfx_trigger.gd`

**`VfxLoops`** (lógica pura, sin nodos): `registrar()` con **una zona = un emisor** (RF9: no uno
por chunk; registrar dos veces la misma zona devuelve `false` en vez de reemplazar en silencio),
`activos()` con culling por distancia, `factor_lod()` (**1.0** dentro del 50% del radio,
**0.25** fuera — RF14), `cantidad_efectiva()`, y `fase_en_t()` que es una **función pura**
(`fposmod(fase + t/periodo, 1)`, sin `randf()` → determinista, RF4).

**`VfxTrigger`**: punto único de traducción evento → VFX. Deriva el mapa `bus → [ids]` del
catálogo (agregar un efecto con `bus` lo conecta **sin tocar código**), resuelve los namespaces
reales del EventBus y **devuelve `{conectados, faltantes}`** nombrando lo que no pudo resolver.

## 4. `tools/vfx/gen_vfx_catalog.py` — generador validante

El catálogo es un **dataset**: su fuente de verdad es la tabla `E` del generador. Regenerarlo es
determinista (mismo `E` → mismos bytes) y `--check` lo verifica, así que **editar el JSON a mano
se detecta** (cableado en `quality.yml`). Valida **antes** de escribir: ids únicos, naming,
conjuntos cerrados, rangos, presupuesto, RF7/RF11/RF14/RF6 y cobertura del plan.

Un detalle de diseño que vale registrar: el generador primero exigía `categoria != tipo`, y esa
guarda **falló** sobre `vfx_magia` (`categoria == tipo == "magia"`). La guarda estaba mal, no el
dato: `magia` y `ui` son legítimamente las dos cosas. La protección real es que la lista de
categorías sea **cerrada y honesta** (si declarás una categoría y no la usás, la constante
miente) → se reemplazó por esa aserción.

## 5. Tests y totales

Medido ejecutando cada suite (nunca copiado):

| Suite | Checks | Corridas |
|---|---|---|
| `test_vfx_m52_iter6.gd` (**nueva**) | **76 · 0 fallos** | **3/3** |
| `test_vfx_pool_m52.gd` (iter. 5) | 89 · 0 fallos | 1 |
| `test_vfx_factory_headless.gd` | 8 · 0 fallos | 1 |
| `test_vfx_catalog_headless.gd` | 4 · 0 fallos | 1 |
| `test_vfx_director_headless.gd` | 4 · 0 fallos | 1 |

**Total M52: 181 checks · 0 fallos · 0 `SCRIPT ERROR`.**

### El guardián anti-falso-verde, probado por inyección

Se copió la suite, se inyectó un `return` justo después de cerrar el bloque B, y se corrió el
**proceso real**:

```
exit code del PROCESO: 2
=== Resumen M52 iter. 6: 26 checks, 0 fallos ===
bloques ejecutados: 2/6 ["A", "B"]
BLOQUES QUE NO CORRIERON: ["C", "D", "E", "F"]
piso de checks: 60 (medidos 26)
=== RESULTADO: INVALIDO (bloques faltantes o bajo el piso) ===
```

Un aborto silencioso **no** produce un verde.

**Y esa prueba destapó un defecto del propio guardián:** con `_summary()` sólo al final de
`_run`, el aborto temprano dejaba el proceso **colgado** — nunca se llamaba a `quit()`, no había
exit code, y la corrida moría por **timeout a los 300 s**. Un cuelgue no es un diagnóstico. Fix:
`_summary()` se encola también desde `_init()` (la cola de `call_deferred` garantiza el orden) y
es idempotente vía `_resumen_hecho`.

## 6. Regresiones encontradas y resueltas

Al pasar el catálogo de 8 a 31 entradas, **2 suites previas quedaron rojas**:

| Suite | Aserción obsoleta | Valor medido |
|---|---|---|
| `test_vfx_director_headless.gd` | "8 eventos del catálogo" | **30** eventos distintos |
| `test_vfx_pool_m52.gd` | "director conoce 8 eventos" | **30** eventos distintos |

No eran regresiones de código sino aserciones **fijadas a la iter. 5**; se actualizaron a los
valores medidos (trampa 49: contar, no copiar). Ambas verdes después.

## 7. Hallazgo: `vfx_director.gd` nunca disparó un VFX por un evento real

`_ready()` hace `EventBus.has_signal("evento_generico")` y conecta si existe. **Esa señal no
existe en ningún archivo del repo** (`scripts/core/event_bus.gd` no la declara): `has_signal()`
devuelve `false`, el director queda **mudo**, y **ningún VFX se disparaba por un evento real de
juego**. El EventBus del proyecto es **namespaced** (`world.block_placed`, `quest.prereq_met`,
`weather.clima_cambio`, …), no plano.

Lo verifiqué al revés: los **13** buses que declara el catálogo **sí existen** como `signal` en
`event_bus.gd` (bloque F de la suite los busca por texto en el archivo). Es decir: el catálogo
estaba bien y el enganche estaba muerto.

**No reescribí el director**: cambiar su modelo de eventos en el mismo ciclo que el catálogo
mezcla dos cambios. Se le agregó un bloque de comentario que documenta el `evento_generico`
muerto y apunta a `VfxTrigger`; **la migración queda pendiente** y anotada.

## 8. Hallazgo: el protocolo de números v3 tiene dos modos de fallo

Perdí **dos** números antes de quedarme con el **1005**.

**(1) 1001 — doble asignador.** `Logs/reservas/1001-hy3-M53.txt` (hy3, 03:37) existía cuando tomé
el 1001 de `NUMEROS_DISPONIBLES.txt` (03:38): `reservar_log.py` y la lista v3 eran **dos
asignadores independientes**. `--reservar` asignaba por `max+1` y **no tocaba el pool**.
→ **Corregido**: `--reservar` ahora **consume del pool** (y cae a `max+1` si no hay pool), y
`--estado` **detecta el doble asignador** (número que sigue en el pool y ya tiene log o reserva).
Probado por inyección en sonda aislada: **19/19 checks**, y la guarda es de dos lados (dispara
con la colisión inyectada, calla con el estado limpio).

**(2) 1002 — carrera de lectura-modificación-escritura.** Otro agente ya había escrito **y
commiteado** `Logs/1002-Avance-modulos-M154-M84-M53_2026-09-17.md` (commit `5f4e003`, 03:40:14)
sin borrar el 1002 del pool → los dos leímos "primera línea = 1002" a la vez. El pool **no puede**
prevenirlo, y **tampoco detectarlo después** (yo ya había borrado la línea cuando el otro
escribió): `--estado` no lo ve.

→ Cedí el 1002 a su autor y tomé el **1005** por el camino **race-safe**:
`python scripts/reservar_log.py --reservar`, que consume el pool **y** crea el archivo de reserva.
**La creación exclusiva del `.txt` es el paso ATÓMICO, no el borrado de la línea.**

**Recomendación para el repo:** en v3, reclamá con `--reservar`, no borrando una línea a mano.
`AGENTS.md` §6.1.a debería decirlo así.

## 9. Hallazgos menores, reportados sin tocar

- **`\r\r\n` (doble CR) en 4 archivos rastreados.** Lo introduje **yo** en mi `BACKLOG-MASTER.md`
  (4 líneas) y lo normalicé. Los otros son **ajenos**:
  `DOCUMENTACION/14-Inventario/plan-actual/05-Checklist.md` (**306** ocurrencias — puede afectar
  al parser de `verificar_checklist.py`) y `DOCUMENTACION/158-.../plan-inicial/05-Checklist.md`
  (1). No los toqué: son de otro dueño.
- **Checklist personal desincronizada:** la de M52 tiene **138 ítems** y el módulo **148**.
  Sincronicé los **49 marcadores** in-place (por eso pasa a 127/10/1) y **reporté** los 10 ítems
  faltantes en su cabecera. No la regeneré: `gen_checklist_personal.py` **borra las notas de
  evidencia** de otros agentes.
- **`quality.yml`**: las suites de M52 están cableadas con `|| true`, igual que el resto del
  archivo → **un fallo de test no rompe el CI**. Es la familia de la trampa 75 (el verde lo
  produce la tubería, no el programa). No lo cambié: afecta a todas las suites del repo y es una
  decisión del dueño del CI. Agregué la suite nueva y el `--check` del generador **con el mismo
  estilo**, y lo dejo reportado.
- **13 inconsistencias de conteo** en `verificar_checklist.py`, todas de **otros módulos**
  (131/150/153/155/160/168/30/49/53/61/71/72/84). **M52 quedó en 0 inconsistencias.**

## 10. Estado del módulo y qué queda

**137/148** (`[x]=137 · [ ]=10 · [?]=1`). Los 10 `[ ]` y el `[?]` restantes tienen dueño:

- Presupuesto por preset (M90), triggers en timelines (M48), partículas 2D de UI (M53),
  Reduce Motion (M58), guía de amplitudes + review visual, escena pivote con fps (M61).
- Los 10 efectos con `dueno_evento` externo (M49/M32/M13/M16/M51/M86): el **VFX** está definido,
  el **evento** lo emite otro módulo.
- Migrar `vfx_director.gd` a `VfxTrigger`.
- **QA cruzado §21.8 de la iter. 6** (verificador ≠ autor).

## Archivos tocados

- **Nuevos:** `game/isla-ancestral/scripts/particles/vfx_loops.gd`,
  `.../vfx_trigger.gd`, `.../test_vfx_m52_iter6.gd`,
  `tools/vfx/gen_vfx_catalog.py`.
- **Modificados:** `.../vfx_schema.gd` (reescrito), `.../vfx_director.gd` (comentario del
  hallazgo), `.../data/vfx/vfx_catalog.json` (regenerado),
  `.../test_vfx_catalog_headless.gd`, `.../test_vfx_factory_headless.gd`,
  `.../test_vfx_director_headless.gd`, `.../test_vfx_pool_m52.gd`,
  `DOCUMENTACION/52-Particulas-Y-VFX/plan-actual/{04,05,06,07}*`,
  `.github/workflows/quality.yml`, `CHECKLIST-GLOBAL.md`,
  `Mensajes entre modelos/ESTADO-PARALELO.md`,
  `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/{BACKLOG-MASTER.md,52-*/checklist.md}`,
  `scripts/reservar_log.py` (pool v3 + doble asignador), `Logs/NUMEROS_DISPONIBLES.txt`.
