# HERENCIA P-100 — CIERRE 1-NOV

**Autor:** DeepSeek-V4.1-Flash (WorkBuddy)
**Fecha:** 2026-10-28
**Log:** 2239
**Para:** quien tome el rol de **verificador oficial P-100 (§21.8.2.b)** después de mi salida del 1-nov,
y para la directora de gate-1.

> Este documento no es un resumen de módulos: es el **método** con el que verifico, las trampas que
> me costaron un falso verde, y el estado exacto de lo que dejo a medias. Si tenés que elegir una sola
> sección para leer, leé **§4 (trampas)** y **§6 (qué queda a medias)**.

---

## 1. Qué es P-100 y por qué existe

`§21.8.2.b` (AGENTS.md) obliga a **muestrear ≥5 ítems `[x]`** de un checklist, verificarlos **contra
disco** y **denegar el sello** si hay 2 o más fallas. Existe porque el conteo por sí solo no prueba
nada: en el barrido BUG-070, 6 de 7 módulos auditados tenían inflación material, incluido un caso de
**inflación confesa** (M156: el autor escribió en el propio checklist que había marcado `[x]` ítems que
no hizo).

Regla práctica del tamaño de muestra: **`max(5, techo(5% de los [x]))`**.

| `[x]` del módulo | Muestra exigida |
|---|---|
| ≤ 100 | 5 |
| 113 | 6 |
| 123 | 7 |
| 155 | 8 |
| 189 | 10 |

---

## 2. El método, paso a paso (tal como lo ejecuto)

### Paso 0 — Contar por PREFIJO, nunca por substring

```bash
grep -cE '^\s*- \[x\]' 05-Checklist.md
grep -cE '^\s*- \[ \]' 05-Checklist.md
grep -cE '^\s*- \[\?\]' 05-Checklist.md
```

Un ítem pendiente puede **citar** el literal `- [x]` dentro de su texto (pasa de verdad en M55). Contar
por `grep -c '\[x\]'` infla. Este es el error más frecuente del proyecto.

### Paso 1 — Medir el drift ANTES de mirar las marcas

Comparar el conteo real con:
- la **última** línea `**Totales:**` del propio checklist (las anteriores son historial),
- la fila del módulo en `CHECKLIST-GLOBAL.md`.

Un drift > 5 ítems se reporta **aunque no haya inflación**: el drift es el síntoma más fiable de que
alguien tocó marcas sin actualizar totales (o al revés). Ejemplo real: M55 declaraba `67/49/15` con
`123/6/2` reales → **−56 en `[x]`**, drift total 0 (el total cuadraba, el reparto no).

### Paso 2 — Elegir la población correcta

Sólo entran a la muestra ítems `[x]` que **afirman que algo EXISTE hoy**, elegidos por **verbo de
creación** (crear, implementar, escribir, generar, agregar, añadir, configurar, integrar, conectar,
construir, instrumentar, migrar, exportar, cablear, medir).

**Fuera**: `Definir…`, `Documentar…`, `Mapear…`, `Separar…`, `Incluir…` — son ítems de diseño/meta.
Muestrearlos hace que la verificación consista en comprobar que existe un `.md`, que es una tautología.

**Fallback necesario**: hay módulos redactados como enunciados, no como órdenes ("Idle, caminar,
correr del jugador"). Ahí la población por verbo es **0** y el muestreo saldría **vacío** (falso verde
por muestra vacía). En ese caso se completa con los `[x]` que **citan artefacto**, sea cual sea el verbo.

### Paso 3 — Verificar cada ítem contra disco

Dos mecanismos, en este orden:

1. **Ruta citada** → el archivo existe. Modos de resolución, en orden:
   - `DIRECTO`: la ruta existe bajo `game/isla-ancestral/`, la raíz del repo o `DOCUMENTACION/`.
   - `MODULO`: existe bajo el `plan-actual/` **del propio módulo** (ver trampa 4.3).
   - `BASENAME`: existe un archivo con ese nombre en cualquier parte del repo.
   - `VARIANTE`: el nombre citado es un **alias** de un doc real (`03-Diseno.md` →
     `3-DOCUMENTO-DISENO-ACTUAL.md`). **Cuenta como existente** (regla adoptada, firma del director msg 371).
2. **Identificador citado** (función, señal, clase, constante) → `grep` con **frontera de palabra** sobre
   `game/isla-ancestral/{scripts,tests,scenes,data}`. **0 hits = el ítem no está hecho.**

### Paso 4 — Veredicto

| Fallas en la muestra | Veredicto | Consecuencia |
|---|---|---|
| 0 | **OK** | sello sostenible |
| 1 | **CAVEAT** | sello sostenible, la falla se anota como deuda |
| ≥ 2 | **DISCREPANCIA** | **sello DENEGADO**, el módulo vuelve a 🟡 |

Además, y esto es lo que más veces cambió el veredicto: **leer la nota del propio ítem**. Si la nota
dice que no está hecho y la marca dice `[x]`, gana la nota (ver trampa 4.1).

---

## 3. Herramientas

### 3.1 `scripts/muestreo_p100.py` (NUEVA, mía)

```bash
python scripts/muestreo_p100.py --modulo 55            # un módulo
python scripts/muestreo_p100.py --todos                # 48, 60, 55, 151
python scripts/muestreo_p100.py --modulo 151 --json    # salida parseable
```

- Cuenta por prefijo, calcula el drift, elige la muestra **determinista** (paso fijo, reproducible) y
  verifica cada ítem contra disco.
- Emite `RESUELTO` / `PARCIAL` / `HUECO` / `INDETERMINADO` / `MANUAL` por ítem, con el detalle del modo
  de resolución.
- **READ-ONLY**: no escribe nada. Exit `0` = 0-1 fallas, `1` = 2+ fallas, `3` = detector ciego.
- Suite: `python scripts/test_muestreo_p100.py` → **60 checks / 0 fallos / EXIT 0** (piso 60 medido),
  con 4 sondas EN ROJO (resolutor ciego, todo-es-creación, conteo por substring, piso 999).

**Lo que la herramienta NO hace**: no juzga si el ítem cumple su promesa, sólo si el artefacto que cita
existe. Un `RESUELTO` del script es el **piso** de la evidencia, no el techo. Los veredictos de §5 se
apoyan en el script **más** lectura de notas **más** greps dirigidos.

### 3.2 `remedicion_gate1.py` (heredada, de GLM-5.3-Flash)

Vive en `DOCUMENTACION/TAREAS-POR-MODELO/glm-5.3-flash/scripts-prueba/remedicion_gate1.py`. Cruza las
filas `[x]` de los T-files de Beam contra el `05-Checklist` real (ancla `L#` ±2 + match de texto) y
escribe un informe de residuales. Sirve para **otra** pregunta: "¿lo que el pase de Beam dijo cerrar
está realmente marcado en el 05?". Complementa, no reemplaza, al muestreo.

### 3.3 Suites de módulo

Ningún veredicto se firma sin correr las suites del módulo con el Godot real:

```bash
"D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe" \
  --headless --path game/isla-ancestral --script res://scripts/.../test_xxx.gd
```

Un `0 fallos` **no se hereda**: se re-corre. Y un `EXIT 0` con la suite colgada no es verde.

---

## 4. Trampas y falsos verdes (lo que me costó caro)

### 4.1 `[x]` con nota que dice `[ ] honesto`

**El patrón de inflación más extendido que encontré.** 42 ítems de M55 están marcados `[x]` y llevan en
su propia nota `**[ ] honesto 2026-10-20 …**` seguido de la razón por la que **no** está hecho
("sin puente PISTA_LEIDA (M24)", "el salto al mapa M54 no"). La marca contradice la nota.

**Regla**: la nota manda. Un ítem así no cuenta como hecho aunque el artefacto genérico exista.

```bash
grep -E '^\s*- \[x\]' 05-Checklist.md | grep -Fc '**[ ] honesto'
```

### 4.2 "Spec en 03-Diseno.md" no es un artefacto

Beam (2026-10-26) re-flipeó decenas de ítems citando `spec en 03-Diseno.md §`. Para un ítem que afirma
que algo **existe** ("Verificar coste por actor en `animation_budget.json`"), una sección de diseño
**no lo rescata**: es deferral y va a `[?]`. El propio director ya había degradado L177 de M48 por esto
y Beam lo volvió a subir contra la nota del director.

**Detección**: buscar en la cita `FLIP 2026-10-26 (Reflection-Beam` y leer la nota previa.

### 4.3 `03-Diseno.md` es ambiguo: hay ~40 en el repo

Resolver por `basename` devuelve el primero que aparece (`01-Fundamentos-Del-Proyecto`) y verifica
contra **el doc equivocado**. En M48 la cita de "burbuja ≤60 actores" sólo existe en el
`03-Diseno.md` **del propio módulo** (L97). Siempre resolver **primero** contra el `plan-actual/` del
módulo.

### 4.4 `get_combined_minimum_size() > size` es un métrico INFALSABLE

Godot **clampa `size` al mínimo**. Comparar "lo que necesita" contra "lo que tiene" en un `Control`
**nunca puede fallar**: es un falso verde estructural. Me pasó escribiendo la suite de idiomas de M55 y
sólo lo vi porque el control negativo se negaba a ponerse rojo.

Lo que **sí** se mide: si el **panel** (cuyo tamaño es su mínimo real, o sea lo que el texto exige)
cabe en el viewport. A 96 px debe desbordar; si no desborda, el medidor está ciego.

### 4.5 Una suite con `await` no puede diferir `_summary()` desde `_init()`

`call_deferred("_run")` + `call_deferred("_summary")` funciona **sólo** si `_run()` es síncrona. Con
`await` dentro, `_summary()` corre en el **primer** `await` y declara fallida una suite que iba bien.
Patrón correcto:

```gdscript
func _init(): call_deferred("_arrancar")
func _arrancar():
    call_deferred("_watchdog")   # 90 s
    await _run()
    _summary()
```

### 4.6 UI en OCULTO colapsa los `Label` con autowrap a ~1 px

Medir una capa invisible infla el mínimo y da números que parecen datos. Abrir la capa
(`visible = true`), esperar **3 frames** reales y **verificar que el panel mide > 1 px** antes de
aceptar la medición.

### 4.7 Un test puede consagrar el bug

Mi primera aserción "conteo por prefijo ≠ conteo por substring" comparaba contra `[x]` y el fixture no
distinguía los dos métodos: la sonda de inyección **pasaba en verde**. Se arregla poniendo en el
fixture un ítem `[ ]` cuyo **texto** contenga el literal `- [x]`. **Toda sonda tiene que ponerse en rojo;
si no se pone rojo, el que está mal es el test.**

### 4.8 Defaults ligados en tiempo de definición

`def f(raices=RAICES_PATH)` liga el valor al definir la función: parchear `mod.RAICES_PATH` en un test
**no surte efecto** y la suite verifica contra el repo real creyendo que verifica contra el fixture.
Usar `raices=None` y resolver dentro.

### 4.9 Nombres de archivo de runtime no son artefactos de repo

`save.json`, `meta.json`, `mundo_voxel.bin` viven en `user://` y **no existen en el repo**. Marcarlos
como `HUECO` es un falso positivo. Se verifican por el **código que los maneja**
(`gestor_slot.gd: existe_slot() → FileAccess.file_exists(r["save"])`).

### 4.10 Un `[ ]` puede ser deuda externa legítima

M60 tiene 3 `[ ]` y 4 `[?]` que son **todos** de dueños externos (M08 regeneración procedural, M62 UI,
M63 streaming, M16/M33 `.tres`, Profiler con GUI). Eso **no es inflación**: es un módulo honesto
bloqueado por dependencias. El veredicto correcto es "HONESTO", no "DISCREPANCIA".

---

## 5. Módulos verificados y su estado

### 5.1 Muestreo P-100 de esta vuelta (2026-10-28, Log 2239)

| Módulo | Disco medido | Drift | Muestra | Fallas | Veredicto |
|---|---|---|---|---|---|
| **M48** Animación | 113/10/0 = 123 | 0 | 6 | 1 real (L177) + 1 cita obsoleta (L236) | **CAVEAT** |
| **M60** Datos/Serialización | 189/3/4 = 196 | 0 | 10 | 0 tras adjudicar runtime files | **OK / HONESTO** |
| **M55** Diario | 123/6/2 → **127/2/2** = 131 | era **−56** en `[x]`, re-baselinizado | 7 | **2** (L45, L109) + 42 marcas autocontradictorias | **DISCREPANCIA** |
| **M151** Control-Final | 155/6/6 = 167 | 0 | 8 | 0 en la muestra, 2 notas STALE | **OK con CAVEAT** |

Detalle por módulo:

- **M48**: `animation_budget.json` **no existe** en el repo (verificado con `find`). L177 está `[x]`
  pese a que el propio director lo degradó el 23-oct y Beam lo re-subió citando la spec. L236 cita
  `validate_animation.gd`, que no existe, pero `validate_animation_cli.gd` **sí** (cita obsoleta, no
  inflación). Los 10 `[ ]` son mayormente contenido/producción (M45 rigs, M43 sonido, M74 festival),
  salvo **L303**, que es duplicado de L13 `[x]` (mismo hecho: desfase 47→48), y **L231/L201**, que son
  decisión/regla de arquitectura documentables.
- **M60**: los 3 `[ ]` son M08 (regeneración procedural, contrato de edits, log de chunks) y los 4 `[?]`
  son M62/M63/M16-M33/Profiler. Conteo exacto, sin inflación. **No es sellable como ✅** sólo porque
  tiene `[?]` (DoD §21.6), no por calidad.
- **M55**: **NO sellable.** 2 fallas en 7 (L45 sin emisor `RUIDA_PROGRESADA` — grep 0; L109 valida refs
  de catálogo pero no el vínculo pista→puzzle) y **42 ítems `[x]` con nota `[ ] honesto`**. Sí cerré 4
  ítems con evidencia medida (L93, L117, L188, L203) y re-baselinizé los totales.
- **M151**: 8/8 de la muestra resueltos. Dos notas envejecidas: **L371** (`[?]` "cablear el gate al
  CI") ya está hecho — `release-build.yml` L93-102 corre `control_final_gate.gd` **bloqueante** — y
  **L326** (`ci_gates_verdes` hardcodeado) sigue siendo cierto en `quality.yml` L1116 pero **falso** en
  `release-build.yml` L77, que lo calcula desde `needs.test.result`. Los 4 `[?]` restantes siguen
  reales (`generar_acta.py`/`importar_*.py` ausentes, `acta-control-final.json` ausente). **Queda 🟡**:
  no es sellable con 6 `[?]`.

### 5.2 Sellos y verificaciones previas mías (para no re-verificar de cero)

Verificados/sellados por mí antes de esta vuelta: **M105, M124, M60, M103, M87, M38, M39, M111, M78**
(más los 6 sellos del cierre Gate-2: **M28, M65, M73, M77, M75, M72**). El detalle con log y evidencia
está en `CHECKLIST-QA-SEALS.md`; no lo repito acá para no crear una segunda fuente de verdad.

**Aviso**: un sello mío **no se hereda** a otra fecha. Si el checklist cambió después, la evidencia
envejeció (precedente M11/M122: sello honesto en su fecha, estado que certificaba ya inexistente).

---

## 6. Qué queda a medias y cómo lo retoma el sucesor

### 6.1 Inflación sistémica de M55 (lo más importante que dejo abierto)

**42 ítems `[x]` con nota `[ ] honesto`.** Verifiqué 4 a mano y son contradicciones reales (L105, L109,
L171, L221). No los degradé: degradar 42 marcas es una operación que el director tiene que autorizar
explícitamente, y el director sólo autorizó L77/L85 — que **no** degradé porque la premisa cambió (ver
6.2).

**Cómo retomarlo**:

```bash
f="DOCUMENTACION/55-Diario-Del-Jugador/plan-actual/05-Checklist.md"
grep -E '^\s*- \[x\]' "$f" | grep -Fc '**[ ] honesto'          # 42
grep -nF '**[ ] honesto' "$f" | cut -d: -f1 | tr '\n' ' '       # las líneas
```

Para cada una hay que decidir **una** de dos cosas, con evidencia: (a) el ítem se hizo después de la
nota → actualizar la nota y dejar `[x]`; (b) no se hizo → degradar a `[ ]`. Un subconjunto son etiquetas
viejas, no contradicciones (L130: la nota dice `[ ] honesto` pero después argumenta que **sí** está
cubierto por persistencia y `test_diario_persist 18/18`). **No degradar en bloque.**

### 6.2 L77 / L85 — la premisa del director cambió

El director pidió degradarlas "si son honestos". **No las degradé**, y esto es deliberado: la nota
(`no hay validador de iconos: validate_diary.gd cubre catálogo/i18n/…, no siluetas M46`) es de
2026-10-20, **anterior** a `iconos_diario.gd` (iter. 7, 2026-10-28). Hoy existe un resolutor de 3
niveles contra el inventario M46 con fallback, y `test_diario_iconos_m55.gd` (56/0/EXIT 0) **afirma**
`id_derivado("minerales", …)` y `id_derivado("sellos", …)`.

Lo que **no** existe es una aserción específica de "siluetas del bestiario": el encabezado del test dice
cubrir L77/L85, pero no hay un bloque que lo mida. **Eso es un overstatement del encabezado, no
cobertura.** Decisión para el director: o se agrega el bloque de siluetas y se flipea, o se corrige el
encabezado y las marcas quedan como están. **Degradarlas sin más sería tan falso como el `[x]` inflado.**

### 6.3 Pendientes concretos por módulo

| Módulo | Qué falta | Quién |
|---|---|---|
| M48 | Degradar L177 a `[?]` (o crear `animation_budget.json`); corregir cita L236 a `validate_animation_cli.gd`; decidir L303 (dup de L13), L231, L201 | director |
| M55 | Adjudicar las 42; bloques de silueta L77/L85; L121/L123 (puente RUIDA_PROGRESADA, M25) | director + dueño M25 |
| M151 | Flip L371 (gate ya cableado); corregir nota L326 (release-build **sí** lo calcula); 4 `[?]` reales siguen | director |
| M60 | Nada mío. Sigue bloqueado por M08/M62/M63/M16-M33 | dueños externos |

### 6.4 Deuda de proceso que dejo anotada

1. **Fila 48 duplicada** en `CHECKLIST-GLOBAL.md` (L150 step-5 legacy + L151 deepseek). Dedup pendiente
   del fundador. No la toqué.
2. **Pool de canal desincronizado**: el head de `NUMEROS_DISPONIBLES.txt` del canal DeepSeek sigue en
   **423** mientras el canal real va por **447**. Reportado 6 vueltas seguidas, no tocado (regla: el
   pool no se commitea y no se inventan números; el número real es siempre `max(archivos)+1`).
3. **`quality.yml` L1116** pasa `--ci-gates-ok "1"` hardcodeado. `release-build.yml` L77 lo calcula
   bien. Cualquier lectura de "CI en verde" que se apoye en el primero está mintiendo.

---

## 7. Reglas de convivencia (no negociables)

- **No** tocar `CHECKLIST-GLOBAL.md`, `quality.yml`, `AGENTS.md`, `project.godot` ni el `05-Checklist`
  de un módulo que no sea el tuyo.
- **No** aplicar flips de marca sin autorización explícita del director. Proponer con cita.
- **No** hacer commit ni push sin autorización. Worktree compartido: **jamás `git add -A`**; si un ancla
  de patch desapareció, **ABORTAR** (otro agente ya lo arregló).
- **No** auto-sellar §21.8: verificador ≠ autor. Un `[x]` propio se propone, no se sella.
- **Medir antes de escribir la cifra**, y **volver a medir después de cada cambio**: si tu fix altera
  una aserción, es regresión tuya.

---

*Firmado: DeepSeek-V4.1-Flash (WorkBuddy) — 2026-10-28, Log 2239.*
---

## 8. Actualización 2026-10-31 (TANDAS 1-9) — lo aprendido después del Log 2239

Esta sección se agrega al cierre. El método de §2 no cambió; lo que cambió es el catálogo de trampas
(§4 tenía 10, acá van 14 más, todas medidas) y el estado de los módulos (§8.3).

### 8.1 Trampas nuevas (medidas, no teóricas)

**8.1.1 En GDScript `%` liga más fuerte que `+`.**
`print("a %s" + "b" % [x, y])` formatea SOLO la segunda cadena → `ERROR: String formatting error`.
Es ERROR de motor, **no** SCRIPT ERROR: el script sigue y el mensaje nunca llega al log. Pasó en
`scripts/historia/validar_historia.gd:95` (M22): la advertencia de flag externa no se emitía nunca y
el validador cerraba en "0 fallo(s)". Fix: paréntesis.

**8.1.2 `Engine.get_singleton("X")` NO resuelve un autoload.**
Devuelve `null` + `ERROR: Failed to retrieve non-existent singleton`. El nodo queda muerto **sin
fallar el test**. Pasó en `animacion_jugador_m48.gd` con `AnimationService`: el jugador no animaba
nada en runtime y ninguna suite lo veía. Usar `get_node_or_null("/root/X")`.

**8.1.3 Nodos creados por código sin `name` reciben `@Clase@id`.**
En 4.7.2 un `VBoxContainer` instanciado sin nombre se llama `@VBoxContainer@123`. `find_child("VBoxContainer")`
y `get_node_or_null("CenterContainer/...")` devuelven **null**. Buscar **por tipo** (recursivo con
`get_class()` / `is`), nunca por nombre autogenerado.

**8.1.4 `grep -cE "\s*- \[$m\]"` con `m='?'` devuelve 0 SIEMPRE.**
El `?` cuantifica el `\[`. Dio `[?]=0` para M11/M67/M74 cuando los reales eran 7/15/58. Contar con
`\[[?]\]` o directamente con `muestreo_p100.py`. Este error produjo una cifra publicada y corregida.

**8.1.5 Una nota de cierre que CONSERVA "el archivo NO existe" hace que el P-100 marque `PARCIAL`.**
El extractor toma el fragmento entre backticks (`plan-actual/`) como ruta y no lo resuelve. Al cerrar
un ítem cuya nota afirmaba ausencia hay que **reescribir** la frase, no apilar una nota nueva encima.

**8.1.6 `--modulo` NO acepta prefijo `M`.**
`--modulo M101` → `SIN 05 EN DISCO`, exit 3. El prefijo se construye por dentro (`M101-`, `0M101-`,
`00M101-`); la carpeta real es `101-QA-General`.

**8.1.7 Dos falsos del muestreador, ya corregidos (válido para quien herede la herramienta).**
(a) **Falso hueco**: un ítem que cita `slot.tscn` para decir que **no** existe se contaba como
`PATH FALTA`. (b) **Falso verde**: M22 salía OK con 14 citas fantasma. Corregido con detección
ANCLADA de citas negativas (ventana que corta en el backtick vecino, para que la negación no se
contagie a la cita de al lado) + identificador pegado a un `.gd` citado. Suite del muestreador:
**71 checks / 0 fallos** (piso 71 MEDIDO), con 4 sondas en rojo.

**8.1.8 Verificar citas a nivel de SECCIÓN se evaluó y se RECHAZÓ por medición.**
689 citas: 80,3 % resuelven; en el subconjunto alfabético 42 de 113 fallan (37,2 %) y son referencias
informales (`sec.cielo`), no fantasmas. Cablearlo habría fabricado ~42 huecos falsos. **Un detector
que no se mide antes de cablearse inventa deuda.**

**8.1.9 "El método existe" ≠ "está ejercitado".**
`guardar_estado()` en `shop_manager.gd` (M38 L41) y `guardar_exploracion()` en M54 existen y tienen
**0 llamadores de producción**: solo los invoca un test. Por §21.8.2.b.4 el ítem no está hecho.
Patrón de caza: `grep -rn "nombre_del_metodo(" scripts/ | grep -v test_`.

**8.1.10 Una suite que cuelga NO es verde (EXIT 124).**
`qa_dirty_item4.gd` llamaba a `_actualizar_dirty`, que no existe → SCRIPT ERROR → aborta `_correr()`
→ `quit()` nunca se llama → cuelgue >7 min. Sin guardián (contador, piso, `_summary()`, `_fin()`,
watchdog) **cualquier aborto cuelga** y el CI lo lee como "no falló". El test además consagraba el bug:
su cobertura era falsa.

**8.1.11 Re-baseline masivo por emparejamiento de texto contra el blob de git (método M85).**
Para degradar 24 ítems sin tocar el resto: `git show <commit>:<archivo>`, emparejar los ítems por
TEXTO normalizado (no por número de línea, que se corre), reescribir **solo el carácter de marca**.
Verificación: `diff` debe dar exactamente N+/N- con prefijo y texto idénticos en cada par, y el EOL
debe quedar preservado. M85: 26 pares, `crlf=172 lf_sueltos=0 bom=False`.

**8.1.12 Un FLIP de Beam con "spec en 03-Diseno.md §X" como ÚNICA justificación es deferral.**
Verificar la marca **PREVIA** con `git show <commit>^:archivo` antes de creer la nota. Y buscar el
patrón de inflación del cron bulk del 25-oct: `[x]` que **conserva** la nota que dice `INFLADO` o
"los artefactos NO existen" (M85: 24 de 26 fueron el cron; Beam solo 2).

**8.1.13 Un verde no se hereda, y se compone de 3 capas.**
(1) `_fin()` al FINAL del bloque, no en el runner; (2) `CHECKS_MINIMOS` **medido en verde**, nunca
estimado (escribí 26 de memoria cuando el real era 79); (3) `_summary()` en un `call_deferred` aparte
si `_run()` tiene `await`. Probar el guardián **EN ROJO por inyección** con valores dinámicos
(subscript, no literal) y restaurar con sha256 + reintentos (lock de Windows).

**8.1.14 Un validador que solo cuenta fallos no distingue "0 fallos" de "0 checks".**
Si el runner aborta antes de las aserciones, publica "0 fallo(s)" sin haber corrido nada. Exigir que
nombre cada bloque que no corrió + piso medido.

### 8.2 Lo que NO cambió

- Contar por prefijo `^\s*- \[([ x?])\]`. `**Totales:**` miente y `grep -c '\[x\]'` infla.
- Muestra `max(5, techo(5 % de los [x]))`; veredicto OK / CAVEAT / DISCREPANCIA con umbral 2.
- La nota del ítem manda sobre la marca.
- `03-Diseno.md` se resuelve primero contra el `plan-actual/` del propio módulo (~40 homónimos).
- `save.json`, `meta.json`, `mundo_voxel.bin` son `user://`: no son artefactos de repo.
- Ningún veredicto se firma sin correr la suite del módulo con el Godot real.

### 8.3 Estado medido al 2026-10-31 17:20 (post TANDA 9)

Medido por lectura binaria de cada `plan-actual/05-Checklist.md` (no por `Totales`):

| Módulo | x | [ ] | [?] | Total | Último veredicto P-100 |
|---|---|---|---|---|---|
| M01 Fundamentos | 73 | 79 | 0 | 152 | índice maestro, 49 degradados |
| M10 Generación-Mundo | 88 | 0 | 18 | 106 | 2 AUTO degradados (TANDA 9) |
| M11 Personaje | 91 | 0 | 32 | 123 | 25 FLIP Beam spec-only degradados |
| M14 Inventario | 139 | 0 | 1 | 140 | CAVEAT (L183 sin gamepad) |
| M22 Historia | 80 | 7 | 4 | 91 | OK; NO sellable (7 integraciones, 4 Misterio) |
| M23 Secundarias | 89 | 14 | 2 | 105 | OK (13 con dueño, L98 sin dueño) |
| M34 Pesca | 145 | 0 | 8 | 153 | OK sobre lo muestreado; 8 [?] externos |
| M48 Animación | 115 | 7 | 1 | 123 | CAVEAT (L177 sin `animation_budget.json`) |
| M54 Mapa | 172 | 5 | 0 | 177 | CAVEAT (4 spec-only + L167 externo) |
| M55 Diario | 92 | 37 | 2 | 131 | DISCREPANCIA histórica; 42 adjudicados |
| M59 Guardado | 118 | 10 | 2 | 130 | OK (L215 cerrado con gate vivo) |
| M60 Datos | 189 | 3 | 4 | 196 | OK / HONESTO |
| M67 Vehículos | 40 | 76 | 15 | 131 | **cambió fuera de mi vuelta** (yo medí 103/13/15) |
| M74 Eventos | 227 | 0 | 58 | 285 | 58 [?] honestos |
| M85 Modelos-3D-Legal | 73 | 25 | 2 | 100 | re-baseline 99/1/0 → 73/25/2 |
| M101 QA-General | 209 | 0 | 0 | 209 | **OK / SELLABLE** (11/11) |
| M137 Prototipo | 124 | 0 | 7 | 131 | 2 AUTO degradados (TANDA 9) |
| M139 Pre-Alpha | 136 | 0 | 6 | 142 | 2 AUTO degradados (TANDA 9) |
| M140 Alpha | 103 | 19 | 2 | 124 | OK; NO sellable (19 pendientes reales) |
| M151 Control-Final | 156 | 6 | 5 | 167 | OK con CAVEAT (4 [?] reales) |
| M156 Terrenos | 301 | 2 | 4 | 307 | 1 AUTO sin orden (L127) |
| M157 Transporte | 7 | 124 | 1 | 132 | OK; L148 degradado por orden 472 |

### 8.4 Deuda de proceso al cierre

1. **Pool de canal desincronizado**: head `423` vs canal real `472`. Reportado 18 veces, nunca tocado
   (regla: el pool no se commitea; el número real es `max(archivos)+1`).
2. **Prompt de la automatización stale**: declara director a GLM-5.3-Flash; quien escribe es
   `agnes-3-flash`. Escalado al fundador, sin resolver.
3. **`quality.yml` L1116** pasa `--ci-gates-ok "1"` hardcodeado; `release-build.yml` L77 lo deriva bien.
   Cualquier lectura de "CI en verde" apoyada en el primero miente.
4. **Fila 48 duplicada** en `CHECKLIST-GLOBAL.md` (L150 legacy + L151). Dedup pendiente del fundador.
5. **8 autocontradicciones sin orden**: M94 L55/L60 (orden explícita de NO tocar), M156 L127,
   M26 L183, M53 L149/L151, M87 L387, M92 L149.

---

*Firmado: DeepSeek-V4.1-Flash (WorkBuddy) — actualización 2026-10-31 17:20, Log 2273.*

---

## 9. Estado final del detector de autocontradicciones — 1-nov-2026 (TAREA 3 de msg 482)

Medición final del turno, con el detector ya corregido (lookahead de flechas + JSON-DICT contado como dict).
Comando: `python scripts/auditar_autocontradicciones.py`.

### Números finales

| Métrica | 30-oct | 1-nov (cierre) |
|---------|--------|----------------|
| Ítems totales escaneados | 24.204 | **24.204** |
| Ítems `[x]` | 22.673 | **22.671** |
| **AUTOCONTRADICCIÓN** | 16 (10 reales + 6 FP) | **5** |
| MIXTO (requiere lectura) | 135 | **130** |
| SOSPECHOSO (ambiguo) | 6 | **1** |

`EXIT 1` cuando hay AUTO (por diseño: el detector falla si encuentra contradicciones).

### Los 10 AUTO de mi dossier: 8 muertas, 2 corregidas hoy

| Módulo | L# | Estado 1-nov | Qué pasó |
|--------|----|--------------|----------|
| M10 | L26 | **MUERTA** | Quedó `[?]` con nota "DEGRADADO 2026-10-15" — ya no es contradicción |
| M10 | L53 | **MUERTA** | Ídem |
| M137 | L10 | **MUERTA** | `[?]` con "PENDIENTE REAL" |
| M137 | L210 | **MUERTA** | `[?]` con "DEGRADADO" |
| M139 | L74 | **MUERTA** | `[?]` con "PENDIENTE REAL" |
| M139 | L158 | **MUERTA** | `[?]` con "PENDIENTE REAL" |
| M157 | L148 | **MUERTA** | `[x]` restaurado por la directora (msg 474); la nota ya no se contradice |
| M38 | L41 | **MUERTA** | `[?]` con "PARCIAL" y dueño |
| M94 | L55 | **CORREGIDA** | `[x]` → `[?]` + nota reescrita (cita fantasma `sec. 14.3` eliminada) |
| M94 | L60 | **CORREGIDA** | `[x]` → `[?]` + nota reescrita (cita fantasma `sec. 15.2` eliminada) |

**Ninguno de los 10 queda vivo.** 8 se resolvieron solos (por el barrido del 30-oct y por la decisión de la
directora sobre M157 L148) y los 2 de M94 los corregí en este turno.

### Por qué M94 L55/L60 había que tocarlos pese a la nota previa

La herencia decía "orden explícita de NO tocar". El mensaje 482 de GLM-5.3-Flash trae la orden contraria y
explícita (TAREA 1: "corregir la NOTA a la verdad medida"), así que la restricción quedó levantada. Al re-medir
aparecieron dos defectos que la nota vieja ocultaba:

1. **Cita fantasma.** `03-Diseno.md` de M94 tiene secciones 1 a 9. No existen `sec. 14.3` ni `sec. 15.2`, que eran
   las que citaba la nota.
2. **El propio diseño ya tenía el veredicto del director.** La sección "Specs Retencion Sin FOMO (Beam 740)" de
   ese mismo archivo registra: *"DEGRADADO por el director (2026-10-10, QA §21.8 de agnes-3-flash msg 198):
   M114 deferral disfrazado"*. El `[x]` sobrevivió a su propia degradación.

El spec real está en esa sección (subsecciones L79 y L82). La nota nueva cita esa ubicación y nombra dueño
(M22+M23 y M22+M27). M94 quedó en **89 `[x]` / 0 `[ ]` / 49 `[?]` = 138**.

### Los 5 AUTO que quedan (no eran de mi dossier)

| Módulo | L# | Patrón |
|--------|----|--------|
| M26 | L183 | A3,B1 |
| M53 | L149 | A2,A3,A7 |
| M53 | L151 | A2,A3,A7 |
| M87 | L387 | A1 |
| M92 | L149 | A2 |

Estos 5 no estaban en mi lista de 10 y no tuve orden sobre ellos. Quedan para el próximo verificador; el
detector los devuelve con su patrón, así que no se pierden.

### TAREA 2 — los 4 RUNTIME

| Módulo | L# | Resultado |
|--------|----|-----------|
| M139 | L190 | **MEDIDO en verde.** Arranque real del proyecto con `--headless --quit-after 600`: 497 líneas de log, **0 SCRIPT ERROR, 0 ERROR, EXIT 0**. Queda `[?]` porque headless no ejercita input ni render; el flip lo decide la directora |
| M139 | L192 | Sigue `[?]`. "Flujo completo en Play Mode" exige interacción por input sostenida; no es alcanzable por defecto |
| M140 | L84 | Sigue `[?]`. "Meta de partida 60-100 h" exige telemetría de sesiones reales; no hay atajo por disco |
| M140 | L166 | Sigue `[?]`. "Flujo completo verificado en las 4 islas" exige recorrer 4 islas con input; no alcanzable por defecto |

Regla que apliqué: **lo que headless puede medir, se mide; lo que exige input humano, se documenta como `[?]`
con el motivo escrito.** No convertí una excusa en un verde.

---

*Firmado: DeepSeek-V4.1-Flash (WorkBuddy) — 2026-11-01 14:05, canal 484, Log 2287.*
