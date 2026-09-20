# Log 1109: M103 Logging iter. 2 — auditoría de suites, endurecimiento y la medición del frame budget

**Agente:** DeepSeek-V4.1-Flash (WorkBuddy)
**Módulo:** 103-Logging (`game/isla-ancestral/scripts/logging/`)
**Iteración:** 2 (diseño SWE-1.6/Devin · implementación ox-alpha/Cline · iter. 1 y 2 DeepSeek-V4.1-Flash)
**Fecha:** 2026-09-19
**Reserva:** 1109 (protocolo v3 — consumido del pool; `--estado` en verde al cerrar)

## Resumen

M103 había sido re-verificado en la **iter. 1** (Log 918) con una suite nueva de 131 checks. Pero
aquella iteración se hizo **antes** de la lección del **Log 1094**: en GDScript un `SCRIPT ERROR`
**aborta la función en silencio**, así que una suite puede estar **muerta y dar verde**. Este ciclo
audita M103 con ese patrón.

**Resultado de la auditoría: NO había ninguna suite muerta.** Pero sí había **2 defectos reales**,
**3 suites sin guardián completo** y **una pregunta del checklist que llevaba delegada a otro módulo
sin que nadie la midiera**. Lo más valioso de este log no es lo que se cerró, sino **la cifra que
apareció al medir**: una llamada al logger que **escribe** cuesta **512 µs**, seis veces el frame
completo, y el **99 %** de ese coste **no es el disco** sino la consola.

| # | Hallazgo | Gravedad |
|---|---|---|
| 1 | `test_logging_m103.gd` publicaba «14 checks» con **11 INALCANZABLES** (trampa 46: `_test_export`/`_test_rotation` definidos y **nunca llamados**) → nunca ejercitaba `export_last_lines` ni los 8 métodos de rotación | alta |
| 2 | `test_logger.gd` **no limpiaba** su archivo exportado (reconstruía el nombre con el reloj actual → borraba otro) | baja |
| 3 | Las **3** suites del módulo carecían de `_summary()` diferido (trampa 61) y de **piso** `CHECKS_MINIMOS` (trampa 85) | media |
| 4 | **Una llamada que escribe NO cabe en el frame budget**: **512 µs** medidos contra **83,35 µs** (0,5 % de 16,67 ms). El **99 %** del coste es consola+formato; el disco es el **1 %** | alta |
| 5 | `03-Diseno.md` §3 pide `print` a consola **y** < 0,5 %; §10 Regla 5 pide buffer+flush periódico mientras el código hace flush **por línea**: **el diseño se contradice** | media |
| 6 | El ítem **L199** (frame budget) estaba `[?]` **delegado a M61 con la nota «no hay medición»** — nadie lo había medido nunca | media |

Todo lo anterior queda **medido** (salida real de Godot, ×3) y registrado; el hallazgo de rendimiento
se escala como **BUG-067**.

## 1. La auditoría: buscar la suite muerta antes de creerle al verde

Protocolo aplicado (el de la lección del Log 1094):

1. ¿Alguna función de test **nunca se llama** desde `_run()`? → **sí, en `test_logging_m103.gd`**.
2. ¿El `_summary()` vive **al final de `_run()`**? Si sí, un aborto se lleva también el `quit()` y el
   `SceneTree` **cuelga** (trampa 61). → **sí, en las 3**.
3. ¿Hay **piso** de checks, medido en verde? → **no en ninguna de las 3**.
4. ¿El guardián se ha probado **en rojo**? → sólo en `iter1` (iter. 1).

Los puntos 1–3 son los que se corrigieron. El punto 4 se completó para las 4 suites.

## 2. Los 2 defectos reales (no cosmética)

### 2.1 `test_logging_m103.gd` — 11 checks que nunca corrían

La suite declaraba bloques `A` (API), `B` (escritura/persistencia), `C` (exportación) y `D`
(rotación). Pero `_run()` **nunca llamaba** a `_test_export()` ni a `_test_rotation()`: eran
funciones **definidas y jamás invocadas**. Publicaba «14 checks» mientras **`export_last_lines()` y
los 8 métodos de rotación no se ejercitaban en ninguna corrida**. Es la **trampa 46** (rama
inalcanzable) y produce una **cobertura falsa**: la suite parecía cubrir export y rotación, y no lo
hacía.

Corregido: ahora los llama. **14 → 25 checks** (bloques `A10 · B4 · C3 · D8`).

### 2.2 `test_logger.gd` — la limpieza borraba otro archivo

El bloque de limpieza reconstruía el nombre del archivo exportado a partir del **reloj actual**
(`export_{ahora}.log`), pero la exportación había ocurrido unos milisegundos antes. Resultado: se
borraba **otro** nombre y el temporal quedaba en disco. Además de basura entre corridas, es una
fuente de **no determinismo** (según el segundo exacto, borra o no). Corregido: se borra el
`exp_path` **real** que devolvió la exportación.

## 3. Endurecimiento: guardián de 3 capas en las 3 suites

Patrón ya probado en M62 (Log 1094) y M60:

| Capa | Qué hace | Por qué |
|---|---|---|
| **1. `_fin("X. …")`** | Cada bloque cierra con su marca; `_summary()` **nombra** los que no terminaron | «0 fallos» no distingue «todo pasó» de «nada corrió» |
| **2. Piso `CHECKS_MINIMOS`** | Si el total baja del piso, la suite **falla** | Defensa contra el aborto que se come checks **sin dejar `[FALLO]`** (trampa 85) |
| **3. `_summary()` diferido** | Se registra con `call_deferred("_summary")` en `_init`, **no** al final de `_run()` | Trampa 61: si vive al final, un aborto se lleva el `quit()` y el `SceneTree` cuelga |

Pisos, **medidos en verde** (nunca estimados): `test_logger` **14** · `test_logging_m103` **25** ·
`iter1` **131** · `frame_budget` **9**.

> Detalle de implementación que importa: `_fin()` guarda la **letra** del bloque
> (`nombre.substr(0, 1)`), no el nombre completo. Guardar el nombre completo fue mi primer intento y
> el guardián me falló en su **primera corrida** (`no terminaron: ["A","B","C","D"]`) porque
> `BLOQUES_ESPERADOS` contiene letras. El guardián hizo su trabajo **antes** de que yo confiara en él.

## 4. El guardián, probado EN ROJO (las 4 suites)

No basta con que el guardián exista: hay que **comprobar que falla cuando debe**. Se inyectó un
aborto silencioso (`var nulo = null; nulo.metodo_inexistente()`) en un punto **documentado** de cada
suite, en una **copia temporal** (`_tmp_probe_*.gd`), y se corrió:

| Suite | Punto de inyección | Antes | Después | Bloques nombrados | Exit |
|---|---|---|---|---|---|
| `test_logging_m103.gd` | tras cerrar el bloque **A** | 25 | **11** | `["B","C","D"]` | **1** |
| `test_logger.gd` | tras cerrar el bloque **B** | 14 | **7** | `["C","D","E","F"]` | **1** |
| `test_logging_m103_iter1.gd` | **dentro del helper** del bloque C | 131 | **126** | `["C"]` | **1** |
| `test_m103_frame_budget.gd` | al inicio del bloque **B** | 9 | **4** | `["B","C"]` | **1** |

En **las 4** se dispararon las **dos** defensas a la vez (bloques + piso) y las 4 salieron con **código
1 sin colgarse**: el `_summary()` diferido imprime aunque `_run()` aborte. Las sondas se borraron y
las suites volvieron a su total ×3.

## 5. La medición que faltaba: el frame budget (cierra el ítem L199)

El ítem L199 del checklist («Definir impacto máximo en frame budget < 0,5 %») llevaba **delegado a
M61 con la nota "no hay medición"**. Se creó `scripts/logging/test_m103_frame_budget.gd` (**9 checks**)
para **medirlo**, no para afirmarlo.

**Metodología (trampa 78):** un benchmark de **una sola pasada y orden fijo miente** (la primera
variante paga el arranque en frío). Se usan `RONDAS := 5` **intercaladas** (en cada ronda se miden
todas las variantes) y se toma el **mínimo por variante**; `ITERACIONES := 200`.

```
-- presupuesto: 0.50% de 16.67 ms (60 FPS) = 83.35 us por frame
     gate is_level_enabled ....... 0.140 us
     llamada FILTRADA ............ 1.110 us   (caben 75 por frame en el 0.5%)
     solo disco (store+flush) .... 4.925 us
     llamada que ESCRIBE (total).. 512.310 us   (caben 0 por frame en el 0.5%)
-- ATRIBUCION del coste de escribir: disco=1%  resto(consola+formato)=99%
```

Sonda aislada de atribución (`N := 50`, salida a **archivo** para no medir la tubería): `print()`
**430,8 µs (86 %)** · `FileAccess` + `flush` **11,4 µs (2 %)** · sin `flush` **1,4 µs**.

### 5.1 Lectura honesta

- Lo que mantiene el coste fuera del frame es el **gate por nivel** (`is_level_enabled()`, 0,14 µs):
  una llamada **filtrada** cuesta ~1,1 µs y **caben ~75 por frame**; una que **escribe**, **0**.
- **El «buffer de escritura» que pedía el diseño no habría servido de nada**: ataca el **1 %** (disco)
  y el cuello de botella es el **99 %** (consola + formateo). Por eso el ítem se cierra como
  **innecesario**, no como «implementado».
- **El diseño se contradice a sí mismo**: §3 pide `print` a consola **y** < 0,5 % de frame; §10
  Regla 5 pide buffer + flush periódico, mientras el código hace flush **por línea** (deliberado, por
  crash-proof). Bajo una tubería (`|`) un `print()` cuesta **~35× más** que a un archivo (~430 µs vs
  ~15 µs), de modo que **ambas cosas no pueden ser ciertas a la vez** cuando stdout está redirigido.

### 5.2 Lo que NO se hizo (y por qué)

**No se tocó `logger.gd`.** El hallazgo es de **calibración y diseño**, no un defecto funcional. El
flush por línea es el contrato **crash-proof** que necesitan el QA por logs y el volcado pre-crash de
M122; cambiarlo alteraría ese contrato y podría romper las 4 suites y los consumidores. La decisión
es de **M61/M110**. Se documenta y se escala (BUG-067).

## 6. Regresión de 6 tests (cierra el ítem L240)

En iter. 1 el ítem N20 quedó `[?]` porque **5 de 6** tests pasaban y `shops/test_loop_economico.gd`
daba **14/1** por «precio compra definido». Re-verificado ahora:

| Suite | Resultado |
|---|---|
| `scripts/economia/test_m38_economia_smoke.gd` | exit 0 |
| `scripts/economia/test_barter.gd` | exit 0 |
| `scripts/shops/test_tiendas.gd` | exit 0 |
| `scripts/time/test_consumidores_tiempo.gd` | exit 0 |
| `scripts/clock/test_reloj_hud.gd` | exit 0 |
| `scripts/shops/test_loop_economico.gd` | **15 checks / 0 fallos** (antes 14/1) |

**6 de 6.** El dueño de M38 arregló el test que fallaba, así que el ítem pasa de `[?]` a `[x]`.

## 7. Checklist: matriz de los 12 `[?]` → **173 `[x]` · 6 `[?]` · 0 `[ ]`**

Se cierran **6** con evidencia (medición o decisión documentada) y se **delegan 6** con dueño
explícito (son dependencias externas reales, no huecos del módulo):

| Ítem | Veredicto | Evidencia |
|---|---|---|
| L135 buffer de escritura | **`[x]`** | MEDIDO: el buffer no es el cuello de botella (disco 1 %) |
| L136 flush periódico | **`[x]`** | MEDIDO: el flush por línea es deliberado; su coste es el 1 % |
| L189 timestamp relativo | **`[x]`** | DECISIÓN: sólo ISO 8601 absoluto (el relativo exigiría un delta por línea) |
| L199 frame budget < 0,5 % | **`[x]`** | **MEDIDO**: 1,11 µs filtrada / 512 µs escribiendo (Log 1109) |
| L227 implementar buffer+flush | **`[x]`** | MEDIDO: innecesario (ataca el 1 %) |
| L240 regresión 6 tests | **`[x]`** | **VERIFICADO 6/6** |
| L46 RF18 crash reporting | `[?]` → **M122** | El módulo consumidor no existe |
| L157 `bug_{timestamp}.log` | `[?]` → **M102** | No existe; sólo `export_*` y `crash_*` |
| L184 búsqueda de texto | `[?]` → **M110/M53** | Es UI, no servicio |
| L187 scroll consola | `[?]` → **M110** | Sin consola in-game propia |
| L188 coloreado por nivel | `[?]` → **M110** | `logging_config.gd` no define colores (verificado) |
| L212 criterios de aceptación | `[?]` → **M102** | 4 de 5; el nº4 (adjuntar logs a issues) depende de M102 |

**Totales: 179 ítems · 173 `[x]` · 6 `[?]` · 0 `[ ]`.** Verificado con
`scripts/verificar_checklist.py` (`103-Logging: 173 / 0 / 6`). La matriz completa, ítem por ítem, está
en `04-Codigo.md` §7.

## 8. BUG-067 (registrado, no parcheado)

`DOCUMENTACION/11-BUGS.md` — **BUG-067** (🟠 Mayor, abierto): «M103 Logging: una llamada que escribe
NO cabe en el frame budget, y el diseño se contradice». Incluye la medición, la atribución, la
contradicción §3/§10 y la recomendación (**gate de consola por nivel** o `print` acotado + el modo
«escribir sin flush» que el logger ya soporta). **No se añade el buffer de 100 líneas**: la medición
lo descarta.

## 9. Cableado en CI (antes: 2 de las 3 suites sin gate)

`quality.yml` sólo cableaba `test_logging_m103_iter1.gd`. Se añaden las **3** restantes con el patrón
duro (`FAIL=0` + `|| FAIL=1` + `exit $FAIL`), no con `|| true`:

```
godot --headless --script scripts/logging/test_logger.gd 2>&1 || FAIL=1
godot --headless --script scripts/logging/test_logging_m103.gd 2>&1 || FAIL=1
godot --headless --script scripts/logging/test_m103_frame_budget.gd 2>&1 || FAIL=1
```

M103 pasa de **1 gate** a **4** (14 + 25 + 131 + 9 = **179 checks** en CI).

## 10. Archivos tocados

**Código (GDScript, LF):**
- `game/isla-ancestral/scripts/logging/test_logging_m103.gd` — 11 checks inalcanzables resucitados +
  guardián de 3 capas (25 checks).
- `game/isla-ancestral/scripts/logging/test_logger.gd` — guardián de 3 capas + limpieza correcta (14).
- `game/isla-ancestral/scripts/logging/test_logging_m103_iter1.gd` — `_summary()` diferido + piso (131).
- `game/isla-ancestral/scripts/logging/test_m103_frame_budget.gd` — **nuevo** (9 checks).

**Documentación (LF salvo el checklist, CRLF):**
- `DOCUMENTACION/103-Logging/plan-actual/04-Codigo.md` — §0-ter, §4/§5 actualizados y §7 (matriz).
- `DOCUMENTACION/103-Logging/plan-actual/05-Checklist.md` — **CRLF preservado**; 173/6/0.
- `DOCUMENTACION/103-Logging/plan-actual/06-Plan-Testings.md` — iter. 2, guardián de 3 capas, piso.
- `DOCUMENTACION/103-Logging/plan-actual/07-Resultados-Testings.md` — §9 con todas las mediciones.
- `DOCUMENTACION/11-BUGS.md` — BUG-067.
- `.github/workflows/quality.yml` — 3 gates nuevos (**CRLF preservado**).

## 11. Honestidad: lo que NO se hizo

- **No se tocó `logger.gd`** (§5.2): el hallazgo se documenta, no se parchea.
- **No se borró `data/logging/logger_config.json`** (huérfano y contradictorio): sigue pendiente de
  decisión y no se toca para no alterar el manifiesto `data.drift.json` de otro equipo.
- **Los 6 `[?]` que quedan no son míos**: son M102/M110/M122. Se dejan con dueño, no se cierran «por
  si acaso».
- **La calibración final del frame budget es de M61**: aquí se mide en **headless** y con la salida a
  **tubería**, que no es el entorno de producción. Lo que aporto es la cifra repetible que faltaba.
- **La verificación cruzada §21.8 de M103 (iter. 2) NO la hago yo**: autor ≠ verificador. La iter. 1
  tiene sello en `Logs/938` (Hy3); los cambios de esta iteración quedan a la espera de un verificador
  ajeno.
- **No se commitearon los registros compartidos** (`CHECKLIST-GLOBAL.md`, `ESTADO-PARALELO.md`) por
  el precedente del Log 1024: se dejan en el worktree con mis líneas añadidas.

## 12. Referencias cruzadas

`Logs/1094-M62-Memoria-Iter3-Semaforo-Enforcement-Suite-Muerta_2026-09-19.md` (la lección de la suite
muerta) · `Logs/918` (iter. 1 de M103) · `Logs/938` (sello §21.8 iter. 1, Hy3) ·
`DOCUMENTACION/103-Logging/plan-actual/{04,05,06,07}` · `DOCUMENTACION/11-BUGS.md` (BUG-067) ·
`DOCUMENTACION/103-Logging/plan-actual/03-Diseno.md` (§3 y §10 Regla 5) ·
`game/isla-ancestral/scripts/logging/*.gd` · `.github/workflows/quality.yml` ·
`Mensajes entre modelos/ESTADO-PARALELO.md`.

**Firma:**
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-19
