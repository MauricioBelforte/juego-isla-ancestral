# Log 1130: M11 Personaje-Del-Jugador (P-14) + P-13 (exit 3 y cableado al CI) + BUG-076/077/078

**Fecha:** 2026-09-20
**Hora:** 05:19
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

## Resumen

Sesion larga con dos frentes delegados por el coordinador (P-13 y P-14) y tres bugs
registrados. Lo mas importante **no** es lo que implemente, sino **tres hallazgos que
corregian afirmaciones previas del proyecto** — incluida una mia:

1. **BUG-078 (Nuevo, Critico):** el CI ejecutaba **8 scripts que no existen en el
   repositorio**. El origen es ironico: el commit que arreglo BUG-051 (`11ac4d9`) los
   introdujo. Tercera ocurrencia de la misma trampa en este repo (BUG-051, BUG-071,
   BUG-078) -> se agrego un **gate** que la hace imposible, no un parche puntual.
2. **El "drift interno" de M11 no existia.** El cuerpo del checklist decia 55/2/78 y
   los totales 50/0/73, pero ninguno de los dos era el conteo real: eran **conteos por
   substring** (`grep -o '\[x\]'`) que incluyen leyendas y prosa. El conteo real es
   **123 items = 53 [x] / 0 [ ] / 70 [?]**.
3. **La suite del gate de M11 estaba muerta y verde** (untracked + sin guardian de
   bloque faltante). Se probo **en rojo** antes de creerle.

Ademas: **P-13 verificado de forma independiente por atria-dawn (Log 1131)** — exit 3
no colapsa con exit 1, el cableado al CI sirve.

## P-13 — exit 3 (detector ciego) + job de CI

Orden pedido por el coordinador: **primero exit 3, despues el job**. Commits:

| Commit | Que hizo |
|--------|----------|
| `61cd31c` | `fix(BUG-075)`: `verificar_checklist.py` sale con **exit 3**, no con 1, cuando no puede leer (archivo inexistente / 0 bytes / sin tabla) |
| `f1142e6` | `fix(BUG-077)`: `quality.yml` era **YAML invalido** -> el CI entero estaba apagado |
| `8f7d90f` | `feat(P-13)`: cablea el orquestador + `scripts/validar_workflows.py` al CI |

**Verificacion independiente (Log 1131, atria-dawn-preview):** inyecto los 3 casos por
`--checklist <ruta>` y midio exit **3** en los tres, exit **1** con el archivo real
(85 alertas), y reviso el paso "Verificar el orquestador (gate de ceguera)": exit 3 ->
`exit 1` del job + `::error::`; exit 1 -> `::warning::` sin bloqueo. **El punto critico
esta cubierto: exit 3 y exit 1 no colapsan.** No re-verifique mi propio trabajo.

## P-14 — M11 Personaje-Del-Jugador

### 1. El "drift interno" era un artefacto de medicion, no un drift

El coordinador reporto: *"el cuerpo dice 55 [x] / 2 [ ] / 78 [?] pero **Totales:**
declara 50/0/73"*. Correcto que no coincidian — pero **ninguno de los dos era el conteo
de items**. `grep -o '\[x\]'` cuenta **ocurrencias del substring**, no items de
checklist (lineas que empiezan con `- [x]`). Las 2 ocurrencias extra de `[x]` salen de
la leyenda (linea 6) y de glifos al final de F.110/F.111; las de `[?]` de 5 lineas de
prosa (15/174/184/225/231).

**Medicion por items:** **123 = 53 [x] / 0 [ ] / 70 [?]**. No habia drift que
reconciliar; habia un **instrumento de medicion equivocado** en los dos lados.

### 2. Correcciones al `05-Checklist.md`

| Que | Antes | Ahora | Por que |
|-----|-------|-------|---------|
| Encabezados de seccion D / E / F / H | 12 / 12 / 10 / 10 | **14 / 14 / 12 / 11** | Los encabezados no contaban los items que la seccion contiene |
| F.110, F.111 | `[?]` | `[x]` | Verificado contra codigo, no contra la prosa |
| D.72 | `[?]` | `[x]` | **`IInteractable` SI existe** (la afirmacion contraria era falsa) |
| D.68, C.60 | "manager no existe / rango 4 m" | reescritos | El manager existe; el rango real es **2,5 m**; `inyectar_jugador()` **nunca se llama** (eso si es deuda real) |
| Item huerfano | suelto | movido a **H** | Estaba fuera de toda seccion |
| `**Totales:**` | 50 · 0 · 73 | **123 · 53 · 0 · 70** | El numero medido |
| **Seccion L** (nueva) | — | agregada | Que NO cambio, defectos reparados, decision de alcance, bloqueos con dueno, resultado del cross-check |

### 3. Decision de alcance: NO reescribir B-F como spec

Se evaluo reescribir los 73 `[?]` como "spec honesta". **Se rechazo** por la misma razon
por la que un test puede consagrar un bug: reescribir la redaccion de 68 items los
convertiria en "entregados" **cambiando el texto, no el hecho**. En su lugar se
documentaron **6 bloqueos con dueno** en la seccion L. Un `[?]` con dueno es informacion;
un `[x]` por reescritura es una mentira.

### 4. Cross-check M12 / M13 / M14 — ninguno espera un evento inexistente

El coordinador sospecho que M12/M13/M14 podian estar esperando eventos de M11 que nunca
se publicaron. **Revisado: cero ocurrencias** de cualquier evento de la §3 de M11 en sus
`plan-actual/`. Sus dependencias reales estan vivas: M12 usa `get_camera_forward_xz`
(`player.gd:385-387`) y M13 usa la hotbar.

### 5. `04-Codigo.md`: HEAD afirmaba codigo inexistente

HEAD lista `player_fsm.gd`, `interaction_service.gd`, `light_collector.gd`,
`player_energy.gd`, `character_selector.gd` + 3 `.tres` como implementados. **Ninguno
existe.** Se agrego la tabla de correccion ("no existe en `scripts/player/` != no
existe" — hay que buscar en todo el arbol), el aviso del `--quit` y una **seccion 8**
nueva con la auditoria de la suite y del gate.

### 6. Documentos de testings que faltaban

Creados (la metodologia los exige y **no existian**): `06-Plan-Testings.md` (3 569 B) y
`07-Resultados-Testings.md` (3 372 B).

### 7. `CHECKLIST-GLOBAL.md` — fila 11

Actualizada a `🟡 Con dudas (Log 1130 ✅)` con `53/123`. Commit **`d609b7e`**, blob
construido con `--cacheinfo` (`79648af…`), `git diff --cached --numstat` = **1/1**.

> ⚠️ **Hallazgo ajeno, NO tocado:** la fila 11 tiene **10 celdas de datos** contra las
> **11** del encabezado — falta la columna `Complejidad`. Es un defecto estructural de la
> tabla, no de mi fila; lo reporto y no lo toco.

## Auditoria de la suite `test_player_m11.gd` (trampas 85 / 61 / 62 / 63)

**Estado inicial:** el archivo estaba **untracked** (era BUG-078 sin saberlo) y sin
guardian de bloque faltante.

**Reproduccion:** **30 checks / 0 fallos, ×3 identicas**. No acepte el verde:

| Sonda | Que midio |
|-------|-----------|
| Aborto inyectado al inicio de un helper | `[FALLO] Bloque faltante: C` y **26 checks** (no 30) -> el guardian **nombra el faltante** |
| Cuelgue sin `--quit` | **EXIT 124 a los 60 s**, sin veredicto |
| `--quit` con aborto | **EXIT 0 y SIN resumen** -> el peor falso verde posible |
| Despues del fix | **EXIT 1 en 4,6 s** con el veredicto completo |

**Resultado negativo reportado honestamente:** la sonda de la **trampa 63** (helper
anidado) **NO reproduce** en este caso — 30/0 sin cambios. No la infle para que diera
"bonito".

**Endurecimiento aplicado** (`5ce3aa9`, 278 lineas, LF, sin BOM):

- `CHECKS_MINIMOS := 30` — **medido en verde**, no estimado.
- `_terminado` + `_resumen_seguro()` + `call_deferred("_resumen_seguro")` en `_init()`
  (la trampa 61: con `quit()` al final del runner, un abort nunca llega a `quit()`).
- Eliminados `_error_en_curso`, `_process` (muertos) y `_esperar_autoloads()` (no-op
  llamado **sin `await`** en 5 sitios: daba falsa sensacion de espera).
- **B6-B9 marcados `[INVERTIBLE]`**: asertan la *ausencia* de sistemas (FSM, stamina,
  nado, sprint) -> si alguien los implementa, el test se pone rojo **por hacer lo
  correcto**. Queda escrito para que el proximo agente no los "arregle" al reves.
- Header con los 3 guardianes documentados.

## BUG-078 — el CI ejecutaba 8 scripts que no existen (Nuevo, Critico)

**Sintoma:** de **68 citas `--script`** en los 6 workflows, **9 no estaban versionadas**:
1 legitima (generada en CI, `scripts/editor/_colector_sintaxis.gd`) + **8 reales**
(M11, 5×M64, M116, M117).

**Efecto medido (no supuesto):** `godot --headless --script <inexistente>` -> **EXIT 1**
(`File not found`). En un **checkout limpio** el job `godot-lint` va **rojo**, y el
**primer** archivo faltante **oculta** los otros 7 (el runner aborta).

**Origen (tabla del bug):** `0fb0141` (2026-09-17, M116/M117) y **`11ac4d9`**
(2026-09-20 02:50, M64 ×5 + M11) — **el commit que arreglo BUG-051**. Es la **tercera**
ocurrencia de la trampa 98 en este repo (BUG-051, BUG-071, BUG-078): *una cita a un
archivo que existe en el disco del autor pero no en el repositorio*. `ls` no la detecta;
`git cat-file -e HEAD:<ruta>` si.

**Arreglado para M11** (`5ce3aa9`). **Gate agregado para el resto**
(`scripts/validar_workflows.py`):

- Crecio ~240 -> **407 lineas** (17 545 B, LF, sin BOM).
- **Regla 5 (nueva):** toda cita `--script` debe estar versionada. Se resuelve por
  `_resolver_git()` + `git cat-file -e`; si no se puede saber (`None`), **no se marca**
  (no se inventan hallazgos).
- `CITAS_PERMITIDAS` (la generada en CI, con motivo escrito) y `DEUDA_CONOCIDA`
  (7 entradas ajenas) reportadas como `~ AVISO` — y **una entrada de deuda ya resuelta se
  reporta como problema**, para que la lista no se pudra.
- `_scripts_citados()` recorre `jobs.*.steps[*].run` (no el texto crudo, para que un
  comentario no cuente como cita).
- 2 fixtures nuevos. **Selftest 6/6.** Corrida real: **6 workflows validos + 7 avisos,
  EXIT 0**.
- `main()` ahora sale **3** (detector ciego) si git no esta disponible.

Commit **`ad449cd`** (+76 lineas en `11-BUGS.md`).

## BUG-076 / BUG-077 registrados (commit `b21618d`)

- **BUG-076:** **21 `|| true`** en `quality.yml` + **2 jobs infalsables** en
  `summary.needs` (`$?` siempre 0). Precedente citado: `:310`, Log 1014 ("GATE DURO - se
  quito `|| true`"). **Dueño: M83/M111 — NO TOCADO**, por instruccion explicita del
  coordinador.
- **BUG-077:** `quality.yml` era **YAML invalido** -> el CI entero estuvo apagado ~3 h.

Ambos commits **preservaron ediciones ajenas del worktree** (tecnica de bytes: blob =
`HEAD` + solo mis lineas + `git commit` sin pathspec).

## Commits de la sesion

| Commit | Contenido |
|--------|-----------|
| `f1142e6` | `fix(BUG-077)`: `quality.yml` era YAML invalido |
| `61cd31c` | `fix(BUG-075)`: detector ciego -> exit 3 |
| `8f7d90f` | `feat(P-13)`: cablea orquestador + validador de workflows al CI |
| `b21618d` | `docs(BUG-076/077)`: YAML invalido + 2 jobs infalsables |
| `5ce3aa9` | `fix(M11/BUG-078)`: suite no versionada + 3 guardianes anti-falso-verde |
| `d609b7e` | M11 (P-14, Log 1130): fila global al conteo real 53/123 |
| `4c56603` | `docs(M11/P-14)`: correcciones del checklist + 2 docs de testings |
| `ad449cd` | `docs(BUG-078)`: el CI ejecutaba 8 scripts no versionados |

## Nota sobre el aviso de CRLF (premisa vencida)

El coordinador pidio **no romper "los 211 CRLF + 10 LF" de `CHECKLIST-GLOBAL.md`** y usar
`newline=''` al leer + `'wb'` al escribir. **La premisa estaba vencida:** otro agente
convirtio el archivo a **LF puro** (0 CRLF / 231 LF) y le dejo **1 byte NUL** (offset
151 495, pre-existente en HEAD). Use igual la tecnica pedida (`newline=''` + `'wb'` +
`--cacheinfo`), asi que **no introduje ni un CR**: verificado con `git diff --cached
--numstat` = 1/1.

## Hallazgos ajenos reportados, NO tocados

1. **`Mensajes entre modelos/ESTADO-PARALELO.md`: 2 bytes NUL** (offsets 205 296 y
   205 710, ~lineas 2505 y 2511) donde deberia ir un backtick: el texto es
   `` (`03-Diseno.md) `` y quedo `` (\x003-Diseno.md) ``. Esta en la entrada de los
   over-marks de M118 (ajena), **solo en el worktree** (HEAD tiene 96 641 B, el worktree
   218 635 B: los 122 KB son trabajo ajeno sin commitear). **No lo toco** — reporto.
   Ademas ese archivo es **CRLF** en el worktree mientras HEAD es LF; mi entrada se
   anexo con **CRLF** para no dejar EOL mixto.
2. **`CHECKLIST-GLOBAL.md`:** fila 11 con 10 celdas vs 11 del encabezado (falta
   `Complejidad`); el byte NUL pre-existente sigue ahi (es lo que hace que git lo trate
   como binario).
3. **`CHECKLIST-QA-SEALS.md`** con 1 linea de diferencia ajena (no revisada a fondo, no
   es mi archivo).

## Pendientes y traspasos

- **§21.8 de M62 iter. 4 y de M103 iter. 2** siguen asignados a **hy3** (verificador !=
  autor).
- **BUG-076** (21 `|| true`): dueño **M83/M111**.
- **7 citas `--script` sin versionar** (5×M64, M116, M117): reportadas como `~ AVISO` por
  el gate; dueños respectivos. M11 ya arreglado.
- **`11-Personaje-Del-Jugador/`** no existe aun bajo mi carpeta personal
  `TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/` (existe el modulo, no la copia personal de
  checklist). No es bloqueante: el registro autoritativo es este log.

## Archivos Modificados/Creados

- `Logs/1130-M11-P14-Reconciliacion-Suite-BUG078-Gate-Citas-Versionadas_2026-09-20_05-19-07.md` (este archivo, creado)
- `DOCUMENTACION/11-Personaje-Del-Jugador/plan-actual/05-Checklist.md`
- `DOCUMENTACION/11-Personaje-Del-Jugador/plan-actual/04-Codigo.md`
- `DOCUMENTACION/11-Personaje-Del-Jugador/plan-actual/06-Plan-Testings.md` (creado)
- `DOCUMENTACION/11-Personaje-Del-Jugador/plan-actual/07-Resultados-Testings.md` (creado)
- `game/isla-ancestral/scripts/player/test_player_m11.gd`
- `scripts/validar_workflows.py`
- `scripts/verificar_checklist.py`
- `.github/workflows/quality.yml`
- `DOCUMENTACION/11-BUGS.md`
- `CHECKLIST-GLOBAL.md` (fila 11)
- `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md`
- `Mensajes entre modelos/ESTADO-PARALELO.md` (anexado, **sin commitear** por cambios ajenos)

---

**Firma:** DeepSeek-V4.1-Flash / WorkBuddy
