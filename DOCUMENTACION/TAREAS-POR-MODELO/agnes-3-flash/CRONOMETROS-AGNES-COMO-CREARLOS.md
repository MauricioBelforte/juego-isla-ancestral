# CRONÓMETROS DISPONIBLES DE agnes-3-flash — DEFINICIÓN EXACTA Y CÓMO LLENARLOS

> **VIGENTES (crear SIEMPRE estas versiones): A, B, C, D — G APAGADO.**
> **ESQUEMA FINAL (reorganización del fundador, 29oct 00:15):** A/B cada 30 min separados 15 (detección cada 15 min); C/D cada 6 h intercalados cada 3 h en :05; G fuera.
> **ESTADO:** antes de lanzar, los 5 estaban APAGADOS (28oct 22:04, orden del fundador). Re-organizados aquí; armarlos solo cuando el fundador lo confirme.
> **Directiva 28oct:** "ignora por completo todos los cronometros si se siguen lanzando" — los fuegos leftover de crons ya borrados NO se procesan ni re-crean. Confirmar con `cron_list` que no haya crons viejos.

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-29 00:15 (reorganización final del fundador)
**Referenciado desde:** `GUIA-COMO-SER-DIRECTORA.md` §7

---

## 1. Esquema final de los cronómetros (reorganización 29oct 00:15)

| Cron | Expresión cron | Dispara | Función |
|---|---|---|---|
| **A** | `0,30 * * * *` | :00, :30 | DETECCIÓN + GATE-1 Beam + SELLOS §21.8 + DECISIONES |
| **B** | `15,45 * * * *` | :15, :45 | RED DE LAG (offset 15 min de A → atrapa lo que A se deja) |
| **C** | `5 3,9,15,21 * * *` | 3:05, 9:05, 15:05, 21:05 | PRESERVACIÓN / commits (cada 6 h) |
| **D** | `5 0,6,12,18 * * *` | 0:05, 6:05, 12:05, 18:05 | ASIGNADOR (cada 6 h, entre medio de C) |
| **G** | — | — | **APAGADO** (gate-1 exhaustivo Beam; había estado "alucinando") |

**Razón del diseño (fundador 29oct):**
- **A y B cada 30 min, separados 15 min** → algo detecta **cada 15 min** (:00 A, :15 B, :30 A, :45 B). B va 15 min después de A y corrobora (doble red): lo que A se deja, B lo ve.
- **C y D cada 6 h, intercalados cada 3 h** → 3:05 C, 6:05 D, 9:05 C, 12:05 D, 15:05 C, 18:05 D, 21:05 C, 00:05 D.
- **Todos en :00/:05, los C/D en :05** → A/B (:00/:15/:30/:45) y C/D (:05) **nunca chocan entre sí**.
- **Saturación: 4 detecciones/h + 1 cada 3 h (C/D)** — holgado.

**Reparto anterior (HISTÓRICO, no usar más):** `A */20 · B 10,30,50 · C 17 */2 · D 35 */2 · G 25,55`. Las 5 expresiones viejas se conservan abajo en sus secciones solo como referencia de prompt; **la cadencia vigente es la de ESTA tabla §1.**

**Ids vigentes antes del apagón (28oct, borrar con `cron_delete`):**
A `wku_16fe1ccb1001bh0kSbvahMD97A` · B `wku_16fd17f33001FisPzPaAXByppX` · C `wku_16fd1a5d2001u0rx6igcderbMq` · D `wku_16fd295e4001JGyLWjE02y45KK` · G `wku_171ab684d001iH2RyERCy3tL9U` — **todos APAGADOS 28oct 22:04** por orden del fundador.

### ⚠️ CRON E de Beam (ajeno, NO es de agnes)
El **apilador de Beam** (`scripts/apilar_beam.py`, cron E de la plataforma `:24/:54`) **NO es un cron mío** — no aparece en `cron_list` y no se borra con `cron_delete`. **PAUSADO 28oct 08:23** por flag `DOCUMENTACION/TAREAS-POR-MODELO/Reflection-Beam-1.0/APILADOR_PAUSADO.flag` + guard en el script. Para reactivarlo: borrar la flag. Para pausarlo: crear la flag.

---

## 2. CRON A — prompt EXACTO (copiar tal cual en cron_create)

```
Cron A — DIRECTORA agnes-3-flash: deteccion + gate-1 Beam (libre) + sellos + decisiones.
Leé Logs/estado_director.json (memoria viva; incluye 'tarea_gate1_beam').
PASOS: (1) DETECTOR: barrer canales de flota por mensajes agente->directora SIN acuse
(DeepSeek/Step-5/Hy3/Ling activos; Beam PAUSADO no responder pings; MiniMax/G-5.3 offline).
Responder compacto. (1 bis) BARRER TAMBIEN los self-logs X-a-X recientes que citen un
orden mio (NNN-agnes-3-flash) — ciego documentado Hy3 #433. (2) GATE-1 BEAM (tarea libre,
solo si hay un T-done nuevo): samplear 5-6 flips del ultimo reporte "T0XX hecho=N" contra
DISCO (05 [x] + spec 03); veredicto a 'tarea_gate1_beam.ultimos_veredictos' de
estado_director.json, NO al canal de Beam (anti-loop). Overstatements se anotan, no flippean.
(3) SELLO §21.8 donde gate-1 + gate-2 (sucesor) completos (muestrear ≥5 [x], §21.8.2.b;
no self-QA). (4) 3 decisiones fundador visibles (NO implementar sin GO):
frente-codigo-alpha / M106 GCP-cuenta / marca-M01. Reportar 1 línea.
REGLAS: repo UTF-8 SIN BOM (Python io.open / write-tool); NUNCA tocar 🔵 ajenos;
no self-QA; fecha REAL.
```
Cadencia `0,30 * * * *` (29oct; antes `*/20`).

---

## 3. CRON B — prompt EXACTO (red de LAG)

```
Cron B — DIRECTORA agnes-3-flash: red de LAG (doble red que corrobora a A).
Detector mas barato. Verificar que NINGUN mensaje agente->directora lleve >20 min sin
acuse (medir por mtime REAL, NO por la fecha del slug — trampa de timestamp adelantado).
Si hay LAG: procesar los pendientes + acuse compacto. B es la red de seguridad: no
duplique el trabajo de A; si A ya respondio, B solo confirma 'lag 0'.
Canales activos: DeepSeek/Step-5/Hy3/Ling; Beam PAUSADO (auto-avisos 404+ NO contar
como lag ni responder); MiniMax/G-5.3 offline. 1 línea.
REGLAS: UTF-8 SIN BOM; fecha REAL; NUNCA tocar 🔵 ajenos.
```
Cadencia `15,45 * * * *` (29oct; antes `10,30,50`).

---

## 4. CRON C — prompt EXACTO (preservación cada 2 h)

```
Cron C — DIRECTORA agnes-3-flash: preservacion/commits cada 2h.
Hacer un commit de preservacion de los avances de la jornada (sellos emitidos, archivos
de tareas/ generados, mensajes de canal nuevos, updates de estado_director.json).
ANTES: git status + git diff --stat; EXCLUIR ficheros en vuelo (mtime < 15 min, trabajo
de otros agentes — helpers en Temp/: git_preserve_scan.py). Commit en español pasado
descriptivo (ej: 'Se preservó ...'). NO hacer push (regla del director: solo commits de
preservacion local). Reportar el hash + 1 línea de que se preservó.
Si no hay nada nuevo desde el ultimo commit -> 'sin cambios'.
```
Cadencia `5 3,9,15,21 * * *` (29oct; antes `17 */2`).

> **⚠️ REGLA ANTI-RESTAURACIÓN (Cron C) — agregada 30oct (hallazgo M85, DeepSeek TANDA 6):**
> el commit de preservación commitea el worktree **tal cual**. Si un worktree traé una
> **regresión de marcas** (`[ ]`→`[x]` **sin nota de flip**) — p. ej. una re-inflación
> silenciosa que conserva la nota "INFLADO / NO existen" — **el Cron C NO la versiona
> limpia**: detectala antes de commitear (buscá en el diff de checklists `[x]` nuevos cuya
> nota contenga "INFLADO"/"NO existen"/"sin codigo en disco") y, si hay, **anoatá y no
> la commitees** (o commiteala señalada como inflación pendiente de re-audit). Origen:
> M85 se re-infló de 73→99 por commits bulk de preservación que trajeron `[ ]→[x]` sin
> firma (24/26 de la inflación NO fueron Beam, sino restauración del worktree).

---

## 5. CRON D — prompt EXACTO (asignador cada 2 h)

```
Cron D — DIRECTORA agnes-3-flash: ASIGNADOR cada 6h. FLOTA REAL 29oct: Hy3 y
DeepSeek(WorkBuddy) SE VAN 1-nov (NO apilarles nada, solo su herencia); Nemotron y
MiniMax van AUTONOMOS en su cron (NO les apiles, anti-drift); kimi/Claude descartados;
GLM fuera de circuito. Tu UNICO destino de tarea = Ling-3.1-Flash (i18n/doc, ritmo 1/h)
+ M157 (scaffold 05-Checklist, doc). Verificar si el backlog de Ling esta drenando
(<~50 items) o idle -> ASIGNARLE 20-30 items de su riel i18n/doc escribiendo UN
mensaje compacto en SU canal (1 tabla, sin prose). NO apilar a mas de lo que consume.
Reportar 1 linea: a quien se repoblo y con que. Si Ling tiene cola honda ->
'flota alimentada (Ling)'. REGLAS: UTF-8 SIN BOM; NUNCA tocar 🔵 ajenos; fecha REAL;
el asignador NUNCA implementa trabajo ajeno, solo lo encola. (Cadencia 29oct: `5 0,6,12,18 * * *`.)
```
Cadencia `5 0,6,12,18 * * *` (29oct; antes `35 */2`).

---

## 6. CRON G — prompt EXACTO (gate-1 exhaustivo Beam, ventana :25/:55)

```
Cron G — DIRECTORA agnes-3-flash: GATE-1 EXHAUSTIVO de Beam (dedicado, ventana exclusiva
:25/:55). Leé Logs/estado_director.json → 'tarea_gate1_beam.indice' (verificados_en_vivo,
pendientes_recientes_por_verificar, proximo_despues_de) y 'modulos_candidatos_sello'.
PASOS: (1) CATCH-UP: verificar TODOS los T-done de Beam aun no verificados contra DISCO
(empezar por los pendientes_recientes del mas nuevo al mas viejo, y los T-done nuevos
desde 'proximo_despues_de'); para cada uno samplear 5-6 flips 'CUBO-A [x]' contra el
05-Checklist [x] REAL del FOLDER + la spec en su 03-Diseno; veredicto
OK/CAVEAT/DISCREPANCIA → 'tarea_gate1_beam.ultimos_veredictos' + mover a
'verificados_en_vivo' (NUNCA al canal de Beam, anti-loop). Overstatements se anotan, no
flippean. Patrón M68: el 05 a veces tiene header/Totales STALE y los [x] viven en el
cuerpo → contar el CUERPO. (2) BARRIDO DIARIO (primer G de la jornada / cada ~24h):
sample §21.8.2.b de los modulos_candidatos_sello LIVE contra disco + chequeo de drift de
Totales. (3) Si ya no queda T-done sin verificar -> 'gate-1 al día'.
REGLAS: repo UTF-8 SIN BOM; NUNCA tocar 🔵 ajenos; no self-QA (el gate-2 runtime es del
sucesor); fecha REAL; walks excluyen .kilo/.git/Obsoletos/. Reportar 1 línea.
```
Cadencia: **APAGADO** (29oct, orden del fundador — G había estado "alucinando"; no re-crear salvo orden expresa).

---

## 7. Cómo crearlos (receta cron_create)

**Con el tool `cron_create` de Kilo Code (esquema final 29oct):**
1. `cron_create(cron="0,30 * * * *", prompt=<texto §2>)` → Cron A. Anotar el `id`.
2. `cron_create(cron="15,45 * * * *", prompt=<§3>)` → B.
3. `cron_create(cron="5 3,9,15,21 * * *", prompt=<§4>)` → C.
4. `cron_create(cron="5 0,6,12,18 * * *", prompt=<§5>)` → D.
5. **NO crear G** (apagado; solo re-crear con orden expresa del fundador).
6. Verificar con `cron_list` que A/B/C/D quedaron con next-fire en las franjas (:00/:30, :15/:45, 3:05… , 0:05…) y que G no reapareció.

**Para apagar:** `cron_list` → tomar cada id → `cron_delete`. Confirmar que `cron_list` quede **vacío**. **Los fuegos leftover que lleguen después del borrado NO se procesan ni re-crean** (directiva 28oct).

**Cuevas y límites del sistema:** máx. **10** tareas programadas por sesión; una tarea **vence a los 7 días** (recrearla después); los disparos esperan a que la sesión esté inactiva (no interrumpen una vuelta en curso). 4 crons (A/B/C/D) dejan 6 huecos libres (ej. reactivar G, o un cron de preservación por lote de Beam si el fundador reactiva el E, o un GO-sweep).

**Contexto persistente:** TODOS los crons leen `Logs/estado_director.json` como paso 0. Tras CUALQUIER interacción con un agente o el fundador, **actualizar ese archivo**.

---

## 8. Invariantes que NO se negocia en ningún cron

1. **Detección por LAG real (mtime, no slug)** + self-logs (no ciego, §1 bis de la guía).
2. **Número SIEMPRE del pool de la carpeta destino**, consumido en el mismo acto de escribir (3 cifras, huecos del medio NUNCA se reutilizan).
3. **Escritura SIEMPRE Python UTF-8 sin BOM LF** (o `write` para contenido limpio).
4. **REGLA CERO:** el cron reporta solo novedad material; si todo está al día, 1 línea y cerrar.
5. **Firma:** `agnes-3-flash (Sapiens AI) / Kilo Code`.
6. **Respuesta SIEMPRE en español. No self-QA (§21.8). No push. No tocar 🔵 ajenos.**

**Firma:** agnes-3-flash (Sapiens AI) / Kilo Code — 2026-10-29 00:15 (esquema final A/B/C/D + G apagado)
