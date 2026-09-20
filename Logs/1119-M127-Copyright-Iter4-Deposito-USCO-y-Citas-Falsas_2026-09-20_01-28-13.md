# Log 1119 — M127 Copyright del Juego — iter. 4: empaquetado del depósito USCO y reparación de 2 citas falsas

- **Fecha:** 2026-09-20 01:28
- **Agente:** DeepSeek-V4.1-Flash (WorkBuddy)
- **Módulo:** M127 Copyright del Juego (F0/transversal, legal)
- **Tipo:** iteración de implementación + reparación documental + hallazgos cruzados
- **Número de log:** 1119 (reservado del pool v3, `--reservar`)
- **Commit:** selectivo (ver §9)
- **§21.8:** **pendiente** — esta iteración reabre el delta, así que el sello de la
  iter. 3 (Log 1022, atria-dawn) **no cubre** lo de acá.

---

## 1. Contexto y objetivo

Al cerrar M62 iter. 4 (Log 1112) se retomó el backlog. Los `[ ]` de M127 eran 25 y
casi todos legales/documentales (USCO, DMCA, *fair use*, cesiones), **fuera de mi
especialidad**. Pero uno es explícitamente **tooling**:

> *Automatizar el empaquetado de código y muestras visuales según formatos y
> límites USCO* — con la nota *"Deferred a tooling iteracion"* y la cita
> *"especificaciones USCO documentadas en 03-Diseno.md §4.2"*.

Antes de implementar se verificó **la cita**, y ahí apareció el hallazgo del ciclo.

---

## 2. Hallazgo principal: dos citas a secciones que NO existen

`03-Diseno.md` de M127 tiene **§1, §2 y §3** (69 líneas). Los encabezados `## 1/2/3`
que aparecen en las líneas 37/44/51 son un **ejemplo embebido dentro de un bloque de
código** (`legal/copyright_register.md`), no secciones del documento.

| Línea de `05-Checklist.md` | Cita | Realidad |
|---|---|---|
| 71 | *"estructura de proyectos DAW en `03-Diseno.md §2.3`"* | **§2.3 no existe** |
| 137 | *"especificaciones USCO documentadas en `03-Diseno.md §4.2`"* | **§4.2 no existe** (§4 no existía) |

Es **el mismo defecto** que provocó la reversión del 2026-09-14 (agnes-2.5-flash
cerró el módulo citando `2.3/3.1/3.2/4.2/4.3`), y la propia nota de la iter. 2 de
esta checklist **afirma haberlo corregido** — pero dejó dos citas vivas, ambas
usadas precisamente para **justificar un `[ ]` como "KnownIssue no bloqueante"**.

**Consecuencia:** el "KnownIssue" del ítem de empaquetado se apoyaba en una sección
inexistente. No era un cierre falso (`[ ]` es honesto), pero la **justificación** sí
lo era.

**Acción:** se escribe `03-Diseno.md §4` con la especificación **real** (citando la
norma, no inventándola) y se corrigen las dos citas, anotando qué decían.

---

## 3. Qué se implementó

### 3.1 `03-Diseno.md §4` (nueva) — la especificación que faltaba

Fuente normativa: **37 CFR § 202.20(c)(2)(vii)** (verificada, no de memoria).

- **§4.1** Código: `≤ 50` páginas → todo el fuente; `> 50` → primeras 25 + últimas
  25 + la página del aviso. Unidad equivalente = **50 líneas/página**, declarada.
- **§4.2** Secretos comerciales: 4 opciones; invariante de admisibilidad
  `tachado < visible` **y** `visible > 0`; *rule of doubt* para código objeto.
- **§4.3** Muestras visuales: **3×3 a 9×12 pulgadas** (límite **físico** → el DPI
  es obligatorio); dimensiones leídas de la **cabecera real** (PNG `IHDR`, JPEG `SOF`).
- **§4.4** El metadata no debe engordar el paquete (límite 10 %).
- **§4.5** La herramienta y su contrato de salida (`0`/`1`/**`3`**).

### 3.2 `tools/legal/empaquetar_deposito_usco.py`

CLI: `--plan`, `--emitir <dir>`, `--check`, `--json`, `--selftest`.
Techo de deuda en `tools/legal/deposito_usco_scope.json` con `clave`/`motivo`/`dueño`.

### 3.3 `tools/legal/test_empaquetar_deposito_usco.py` + gate en `quality.yml`

Suite nueva cableada en el job `legal-tools` y **paso de gate propio**
(`Verify USCO deposit gate (M127 iter. 4)`), con `FAIL=0` / `|| FAIL=1` / `exit $FAIL`.

---

## 4. Medición sobre el repo real

| Métrica | Valor medido |
|---|---|
| Fuentes en alcance | **891** (`game/isla-ancestral`, excluyendo `addons/` de terceros) |
| Líneas del flujo | **122 468** |
| Páginas (50 líneas/página) | **2 450** |
| Regla aplicada (§4.1) | `> 50` → **primeras + últimas** |
| Página del aviso de copyright | **1109** |
| Unidades depositadas | **51** (1..25 + 1109 + 2426..2450) |
| Metadata del paquete | **0,6 %** del total (límite 10 %) |

La muestra visual candidata (captura de render de 768×768 px, pipeline M166) a 300
dpi mide **2,56 × 2,56 pulgadas** → **por debajo del mínimo de 3×3**. Se declara como
**deuda con dueño (usuario / M46)**, no se oculta ni se "arregla" eligiendo un DPI
que la haga pasar.

---

## 5. Pruebas

| Prueba | Resultado |
|---|---|
| `empaquetar_deposito_usco.py --selftest` | **45/45 OK**, exit 0 |
| `test_empaquetar_deposito_usco.py` | **38/38 OK**, exit 0 |
| `--check` sobre el repo real | exit 0, 0 violaciones nuevas, 1 deuda declarada |
| `--emitir` | `deposito_codigo.txt` 94 602 B + `fuentes.txt` 49 833 B + `manifiesto.json` 1 130 B |

**El gate probado EN ROJO** (no solo en verde):

| Inyección | Resultado medido |
|---|---|
| `secretos.activo=true`, `tachado 900 > visible 100` | `VIOLA: 4.2|secretos -> lo tachado (900) no es proporcionalmente menor que lo restante (100)` → **exit 1** |
| `codigo.incluir = ["no/existe/esta/ruta"]` | `DETECTOR CIEGO (exit 3): no se resolvio ninguna fuente de codigo en el alcance` → **exit 3** |
| Alcance restaurado | `conforme: 0 violaciones nuevas (1 deuda declarada)` → **exit 0** |

Pisos `CHECKS_MINIMOS`: **45** y **38**, ambos **medidos en verde**.

---

## 6. Defectos que encontró la propia suite (no el autor)

1. **`--json` no era JSON puro.** Además del JSON imprimía las líneas del techo de
   deuda → el consumidor recibía `Extra data: line 949` y no parseaba. Ahora `--json`
   imprime **solo** JSON e incluye la clasificación de violaciones.
2. **El manifiesto inflaba el paquete al 37,6 %** (medido) porque incluía las **891
   rutas** de fuentes: violaba la regla **4.4 que el propio script comprueba**. La
   lista pasa a `fuentes.txt` (material depositado) y el manifiesto guarda **conteo +
   SHA-256** → **0,6 %**.
3. `analizar()` no exponía la `deuda`, así que un consumidor no podía clasificar
   violaciones sin releer el alcance.
4. **Aserción con el número escrito de memoria:** la suite fijaba `"42/42 OK"` y el
   selftest pasó a **45/45** → rojo. Ahora la suite **lee** el conteo del resumen.
   (Mismo patrón que la trampa de "no escribas la cifra antes de medirla".)

---

## 7. Hallazgo transversal 1: el worktree de `quality.yml` quedó SIN mi gate

Al verificar el estado antes de empezar apareció algo más serio que el trabajo de M127.

En el commit `1582ac2` (M62 iter. 4) se commiteó `quality.yml` con la técnica de bytes
(`hash-object -w` + `update-index --cacheinfo`), que escribe **solo el índice**.

**Medido después:**

| Comprobación | Resultado |
|---|---|
| `grep -c architecture-guard` en el **worktree** | **0** |
| `grep -c architecture-guard` en **HEAD** | 4 líneas / 5 apariciones |
| `git diff --numstat HEAD -- quality.yml` | **+43 / −42** |

Es decir: el worktree tenía `HEAD + lo ajeno` **sin lo mío**. **Un `git add` ajeno
habría borrado el job `architecture-guard` y el gate `test_m62_liberacion` en
silencio.**

**Lo grave:** la §5 de `07-Resultados-Testings.md` de **este mismo módulo** (iter. 3)
ya lo tenía escrito, textualmente:

> *"El árbol de trabajo restaurado sin mi cambio → Técnica de bytes: si se restaura
> sin lo mío, el próximo commit ajeno revierte el cambio en silencio → Se escribe
> `árbol_actual + lo mío`, no `HEAD + lo ajeno`."*

**La lección estaba documentada y no se aplicó.** Se reparó re-aplicando mis 5 hunks
de forma **aditiva**, con un script que afirma: 5 hunks aplicados, `architecture-guard`
= 5 apariciones, `test_m62_liberacion` = 1, y los **3 marcadores ajenos intactos**
(`gen_colector_sintaxis`, `test_ia_npc_m64_iterN`, `test_player_m11`). Diff residual
tras la reparación: **+41 / −6**, y las 6 eliminaciones pertenecen **todas** al fix
BUG-051 de atria-dawn.

> **Aserción propia que también estaba mal:** el script afirmaba
> `architecture-guard == 4`. El valor real es **5**: la línea del `echo` contiene el
> nombre **dos veces**. `grep -c` cuenta **líneas** (4), no apariciones (5).

**Regla afinada para la próxima:**

- **Editar el worktree directamente** siempre (así el archivo queda consistente).
- Para el **commit**, el blob es `HEAD + solo mis hunks` — porque `árbol_actual + lo
  mío` arrastraría el trabajo ajeno sin commitear (trampa 87).
- Ambas cosas a la vez: worktree = `HEAD + ajeno + lo mío`; blob = `HEAD + lo mío`.

**Riesgo que sigue abierto (no es mío):** el fix BUG-051 de atria-dawn referencia
`tools/quality/gen_colector_sintaxis.py`, que **existe en disco (3 278 B) pero NO está
versionado**. Si alguien commitea ese hunk, el job `godot-lint` **rompe en un checkout
limpio**. Por eso ese hunk **no** se commiteó ni acá ni en el Log 1094.

---

## 8. Hallazgo transversal 2: colisión de número `BUG-068`

| Dónde | Qué hay en `BUG-068` |
|---|---|
| **HEAD** (commiteado, Log 1112) | `hardware` y `HardwareManager` = el mismo script en dos autoloads |
| **worktree** (sin commitear, atria-dawn) | Patrón sistémico de over-marks "KnownIssue no bloqueante" (🔴 Crítico) |

También se midió: **HEAD salta `BUG-063..066`** (los tiene el worktree sin commitear) y
el worktree **no tiene** mis `BUG-068`/`BUG-069`.

**No se tocó la entrada ajena** (regla del proyecto para colisiones ajenas: reportar,
no tocar). Se reporta en `ESTADO-PARALELO.md` con la propuesta: como la mía ya está
**commiteada** en `1582ac2` y la ajena sigue **sin commitear**, lo más barato es que
la ajena renumere a **BUG-070** (069 ya está tomado por mí). Si el dueño prefiere lo
contrario, se renumera la mía con **fe de erratas** en el Log 1112.

Por esto **no se reparó el worktree de `11-BUGS.md`**: escribir mi `BUG-068` al lado
del suyo crearía el duplicado en disco, que es justamente lo que hay que evitar.

---

## 9. Commit selectivo

| Archivo | Cómo |
|---|---|
| `DOCUMENTACION/127-Copyright-Del-Juego/plan-actual/03-Diseno.md` | edición directa (sin diff ajeno) |
| `.../05-Checklist.md` | edición directa |
| `.../04-Codigo.md`, `06-Plan-Testings.md`, `07-Resultados-Testings.md` | edición directa |
| `tools/legal/empaquetar_deposito_usco.py` | nuevo |
| `tools/legal/test_empaquetar_deposito_usco.py` | nuevo |
| `tools/legal/deposito_usco_scope.json` | nuevo |
| `.github/workflows/quality.yml` | **blob = `HEAD` + solo mis hunks** (el worktree trae 2 hunks ajenos sin commitear) |
| `Logs/1119-*.md` | nuevo |

**No se commitea:** `CHECKLIST-GLOBAL.md` ni `ESTADO-PARALELO.md` (compartidos, con
cambios ajenos; se anexan en el worktree), ni la entrada `BUG-068` ajena.

---

## 10. Estado y pendientes

- **Checklist M127: 52 [x] · 25 [?] · 24 [ ]** (era 51/25/25; **un** ítem cambió de
  estado, con artefacto). Línea de Totales actualizada con conteo **medido**.
- **`§21.8` de la iter. 4: pendiente** (verificador ≠ autor). El sello del Log 1022
  cubría la iter. 3 y **no** cubre este delta.
- **Reportado, no arreglado (no es mío):**
  - `tools/quality/gen_colector_sintaxis.py` **sin versionar** → el hunk BUG-051 rompe CI.
  - Colisión `BUG-068` (ver §8).
  - Worktree de `11-BUGS.md` divergente de HEAD (mis 2 secciones no están en él).
- **Sin resolver, con dueño:** 25 `[?]` legales (usuario / M46 / M118 / M108…).
- **Deuda declarada:** 1 (muestra visual < 3 pulgadas a 300 dpi) — dueño usuario / M46.
