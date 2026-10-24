# Log 2161 - M59 - Guardado: fecha de carga, diario 500+ y cola sin GC

**Modelo:** DeepSeek-V4.1-Flash (WorkBuddy / Step-5-WorkBuddy)
**Modulo:** 59-Guardado
**Fecha:** 2026-10-23 21:45
**Rama:** 2 (director 190, sin GO nuevo -> COLA del BACKLOG-MASTER, siguientes [ ] de M59)
**Log:** 2161 (reservado del pool; cabeza medida justo antes = 2161; head actual del pool = 2162)

---

## 1. Que se hizo

Tanda sobre el riel de guardado M59 (modulo con fila GLOBAL ya sincronizada por el
director en 112/130). Sin GO nuevo del director (msg 190: "el proximo lote tuyo sera
segun tu claustro"), se tomaron los siguientes items `[ ]` de M59:

- **L143** "Testear carga en una fecha distinta a la del guardado" [C] -> FLIP a `[x]`.
- **L152** "Testear diario 500+ entradas y fotos faltantes (fallback)" [C] -> FLIP a `[x]`.
- **L175** "Sin GC pesado ni hitching al encolar" [M] -> FLIP a `[x]`.
- **L199** "Verificar la restauracion desde la nube" [C] -> solo MEDICION, queda `[ ]`.

Entregables:

1. `game/isla-ancestral/scripts/saving/test_fecha_diario_cola_m59.gd` - suite NUEVA
   (no toca logica de produccion), 45 checks / 0 fallos / EXIT 0 x3, guarda
   anti-falso-verde de 3 capas con piso `CHECKS_MINIMOS = 45` MEDIDO en verde.
2. `DOCUMENTACION/59-Guardado/plan-actual/05-Checklist.md` - 3 flips + nota medida de
   L199 + linea Totales sincronizada (115/13/2 = 130).
3. `DOCUMENTACION/59-Guardado/plan-actual/04-Codigo.md` - seccion "Notas del Agente"
   de la tanda (LF preservado, verificado por bytes).
4. `DOCUMENTACION/TAREAS-POR-MODELO/step-5-workbuddy/BACKLOG-MASTER.md` - items
   cerrados con cita + registro de corrida (CRLF preservado, verificado por bytes).
5. `game/isla-ancestral/scripts/saving/test_slots_perfiles_m59.gd` - defecto PROPIO
   corregido (ver seccion 5).

## 2. La suite: scripts/saving/test_fecha_diario_cola_m59.gd

45 checks / 0 fallos / EXIT 0 x3 (binario real
`Godot_v4.7.2-stable_win64_console.exe --headless`). 3 bloques, payloads construidos
sobre `snapshot.collect()` REAL (no se mockean proveedores ni dialectos).

### Bloque 1 - L143, carga en fecha distinta

- Payload real con `meta.last_saved = "2026-09-15 08:30:00"` (FECHA VIEJA) y
  `time.dia/day = 42`; `SaveWriter.write_atomic(SLOT_A, base)` y `sm.load_slot` -> OK.
- Cadena-faro activa tras la carga: `paso_actual = 1` y el paso siguiente se puede
  reportar (objetivo coherente, sin reset).
- `last_saved` NO se reescribe al cargar: `slot_metadata` sigue mostrando la fecha
  vieja con `day = 42` (la carga no sella nada; solo `request_save` sella la fecha
  del sistema, verificado aparte).
- Variante con fecha futura: carga OK.

### Bloque 2 - L152, diario 500+ y fotos faltantes

- Roundtrip real de las 44 entradas del catalogo (`Diary.registrar()` + favorito +
  `set_ui_prefs` e2e) -> guardar y cargar devuelve el mismo estado.
- Payload sintetico con 44 validas + **456 huerfanas** -> carga OK y quedan 44
  (las huerfanas se IGNORAN con print: fallback medido, no revienta).
- **300 ids de foto inexistentes** -> carga OK y se preservan (ids = referencias,
  no bytes; el save no embebe imagenes).
- Documento en disco: **24619 B < 120 KB** (limite del item).

### Bloque 3 - L175, sin GC pesado ni hitching al encolar

- White-box: `sm._writing = true` (la cola acepta pero no dispara guardados) y
  1000 x `sm.request_save(SLOT_A, "test_cola_s5")` en el mismo frame.
- Medido con `Performance.OBJECT_COUNT`, `Performance.MEMORY_STATIC` y
  `Time.get_ticks_usec()`:
  - cola **+1000 exactos** (0 perdidas);
  - **0 Objects** creados;
  - **761 us** totales (< 16670 us = 1 frame a 60 FPS);
  - memoria estatica **< 1 MB**;
  - **0 guardados disparados** (la cola no escupe nada mientras `_writing`).

## 3. Guarda anti-falso-verde

- `_abrir`/`_fin(bloque)` por bloque: un SCRIPT ERROR aborta la funcion y la suite
  publicaria "0 fallos"; el guardian nombra el bloque que no corrio.
- `CHECKS_MINIMOS = 45` MEDIDO en verde (primera corrida lo tenia estimado en 52:
  la trampa de siempre, corregida ANTES de escribir la cifra en los documentos).
- `_summary()` en `call_deferred` con bandera `_run_terminado`.
- Guardian probado **EN ROJO por inyeccion 2 veces** (aborto runtime dentro del
  bloque): EXIT 1 nombrando el bloque + piso no cumplido.

## 4. Medicion de L199 (restauracion desde la nube) - queda [ ]

- `grep -rln "nube|cloud"` sobre `scripts/saving/*.gd` = **0**.
- `grep -rln "restaurar_desde_nube|cloud_restore|steam"` sobre el mismo arbol = **0**.
- No existe mecanismo de restauracion en la nube en el riel de guardado. Dueno del
  mecanismo: **M97** (`97-Steam-Store-Page` / `M97-Marketing`). Item `[ ]` honesto.

## 5. Defecto PROPIO encontrado y corregido (test_slots_perfiles_m59.gd)

Hallado en la regresion de esta tanda (no en la logica de produccion):

- L129: `if bool(_slot_previo.get(slot, false)):` - el dict guarda el CONTENIDO
  String del save previo; `bool(String)` NO existe en GDScript 4.7.2 ->
  "Nonexistent 'bool' constructor" que ABORTA `_restore()` en runtime, justo cuando
  habia save previo que restaurar. El cleanup moria en silencio y colgaba el SceneTree.
- L136: mismo patron sobre un valor que ya es bool.
- Fix: `if _slot_previo.has(slot):` y quitar el `bool()` de L136.
- Verificado: **41 checks / 0 fallos / EXIT 0 x2, 0 SCRIPT ERROR**.
- Mecanismo confirmado con 2 sondas desechables (borradas; git status limpio):
  sonda 1 (bool sobre valores bool) = OK; sonda 2 (`bool(String)`) = cuelga.

## 6. Regresiones medidas (binario real, EXIT 0)

- `test_slots_m59.gd` 22/0
- `test_slots_perfiles_m59.gd` 41/0 x2 (tras el fix)
- `test_autosave_m59.gd` 0 fallos
- `qa_m59_profile_id.gd` OK
- `qa_m59_bloqueo_manual.gd` OK

## 7. Estado medido de M59 tras la tanda

- Conteo por PREFIJO de linea sobre `05-Checklist.md`:
  **115 [x] / 13 [ ] / 2 [?] = 130** (antes 112/16/2). Totales sincronizados.
- EOL verificados por bytes: 05-Checklist LF puro sin BOM; 04-Codigo LF puro sin BOM;
  BACKLOG-MASTER CRLF puro sin BOM.

## 8. Limites respetados

0 commits / 0 push / 0 auto-sellos 21.8 / 0 protegidos tocados
(CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot intactos).

## 9. Pedidos al director (msg 192)

1. Ronda de commit de los paths de la tanda (suite nueva, 05-Checklist, 04-Codigo,
   BACKLOG-MASTER, Log 2161, test_slots_perfiles_m59.gd corregido, msjs 191/192).
2. Sync fila 59 del GLOBAL a 115/130.
3. Visto bueno de los 3 flips (ofrecidos a revertir).
4. Nota del defecto propio corregido en `test_slots_perfiles_m59.gd` (era mio, de la
   tanda del Log 2154; la correccion no cambia ninguna asercion, solo el cleanup).
