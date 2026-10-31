# LOG 2262 - DeepSeek-V4.1-Flash - RAMA 2 (COLA ACTIVA agotada)

Fecha: 2026-10-30 03:04:58
Agente: DeepSeek-V4.1-Flash (WorkBuddy)
Modulo ancla: M14 (herramienta transversal: scripts/muestreo_p100.py)
Entrada: sin mensaje nuevo del director (tracker 461 = ultimo NN del director; 462 es salida propia).
Rama: RAMA 2. COLA ACTIVA agotada -> trabajo sobre herramienta propia con defecto MEDIDO.

---

## 1. PUNTO DE PARTIDA

Al re-medir el batch 3 con el muestreador P-100 salieron dos falsos positivos:

- M14 L163: el item cita `slot.tscn` para decir que NO existe ("el claim citaba
  `slot.tscn`, que NO existe"). La herramienta lo contaba como PATH FALTA y tiraba
  el item a PARCIAL. Falso hueco fabricado por la propia herramienta.
- M14 L183: `_input_event` GREP 0. Este SI es verdadero: el metodo real es
  `_unhandled_input` (inventory_layer.gd:415). No es defecto de la herramienta.

Y un falso VERDE, que es peor: M22 salia "VEREDICTO: OK" mientras la revision manual
encontraba citas de seccion inexistentes. M85 salia sin diagnostico y tiene 19 items
[x] cuya propia nota dice que los artefactos citados NO existen.

## 2. LINEA BASE MEDIDA (antes de tocar codigo)

- Suite `scripts/test_muestreo_p100.py`: 71 checks / 0 fallos / EXIT 0 / piso 71.
- M14: fallas=2 (L163 falso, L183 verdadero) -> CAVEAT.
- M34: fallas=0 -> OK.
- M22: fallas=0 -> OK.
- M85: no medido antes del fix.

## 3. CAMBIO 1 - CITAS NEGATIVAS (corrige el falso hueco)

`extraer_artefactos_ex()` devuelve un tercer valor: `negadas`. Una ruta citada como
INEXISTENTE no es un hueco, es una aclaracion del item.

Deteccion ANCLADA y a proposito CONSERVADORA:
- `RX_NEG_POST`: la negacion arranca justo tras el cierre del backtick, admitiendo
  solo puntuacion y "que"/"el cual" de por medio.
- `RX_NEG_PRE`: la negacion termina justo antes del backtick.
- Las ventanas se cortan en el backtick vecino, asi la negacion no se contagia a la
  cita de al lado.

Por que conservadora: el error residual tiene que ser un hueco FALSO (retrasa un
sello) y nunca un OK falso (concederia un sello sobre un artefacto ausente).

Semantica del veredicto: si un item cita SOLO artefactos que el declara inexistentes,
el resultado es HUECO, no RESUELTO ni INDETERMINADO. Una ausencia declarada no avala
nada. Medido en M85: 32 citas de este tipo.

## 4. CAMBIO 2 - IDENTIFICADOR PEGADO A UN .gd CITADO (corrige el falso verde)

Patron: "`inventory_layer.gd` _crear_slots". El nombre del metodo NO va entre
backticks, asi que el muestreo avalaba un item que cita una funcion inexistente
(el real es `_construir_slots`, inventory_layer.gd:183).

`RX_IDENT_PEGADO`: solo snake_case con >= 1 underscore, para no capturar prosa.

PRECISION MEDIDA ANTES DE CABLEARLA: 5 ocurrencias en 23.069 items [x] del repo;
4 resuelven (GREP > 0) y la unica GREP 0 es un defecto REAL. Ruido nulo.

## 5. MEDICION RECHAZADA - VERIFICACION DE SECCIONES (no se cablea)

Se evaluo verificar citas a nivel de seccion (trampa 95, cita fantasma), que es lo
que cazaria los 14 items de M22. Medido sobre el repo completo:

- 689 citas con seccion nombrada: 553 resuelven (80,3%), 136 NO (19,7%).
- Restringido a secciones con nombre alfabetico (113 citas): 71 resuelven (62,8%),
  42 NO (37,2%).

Los 42 fallos son mayormente REFERENCIAS INFORMALES, no citas fantasma: `sec.cielo`,
`sec.dependencias`, `sec.Changelog`, `sec.Modulos`, `sec.encabezado`. El contenido
existe en prosa, no como heading. Cablearlo fabricaria 42 huecos falsos en 113 citas.

VEREDICTO: RECHAZADO por medicion. El matcher de headings no distingue una cita
fantasma de una referencia informal. Resultado negativo reportado con numeros.

## 6. EVIDENCIA DEL CAMBIO

- Suite: 90 checks / 0 fallos / EXIT 0 x3. Piso `CHECKS_MINIMOS` subido 71 -> 89 -> 90
  (MEDIDO en verde, no estimado). 16 bloques cerrados.
- Bloques nuevos: `test_citas_negativas` (17 checks) y `test_ident_pegado` (4 checks).
- 3 SONDAS EN ROJO, restauracion byte-exacta por sha256
  (modulo 8899fa9b915799e2cbb40ed1eb51e9120aee02ee3a7ee8efca0ee5a22e322674,
   suite 23315f2f8c494b66539fdd7d8635d2ecb65fcc8db06b7b6cb276bfba85bd32b8):
  - S1 piso 999: EXIT 1, nombra "minimo 999", 0 fallos -> demuestra que la guarda
    anti falso-verde corta aunque no haya ni un check en rojo.
  - S2 `_es_cita_negativa` -> False: EXIT 1, 7 fallos, nombra "PATH FALTA slot.tscn".
  - S3 `RX_IDENT_PEGADO` anulado: EXIT 1, 4 fallos, nombra "_crear_slots".
  - Control verde tras restaurar: 90/0/EXIT 0, sha256 OK en los dos archivos.
- Diff: 247 inserciones / 22 borrados en 2 archivos. 0 commits / 0 push.

## 7. HUELLA AGREGADA DEL CAMBIO (medida, no estimada)

Sobre los 23.069 items [x] del repo:
- 54 items con cita NEGATIVA (56 citas). Ninguno pasa a hueco falso.
- 5 items con identificador pegado (5 idents).

## 8. RE-MEDICION DE LOS MODULOS

- M14 Inventario: CAVEAT. fallas=2, ambas VERDADERAS (`_crear_slots`, `_input_event`),
  negadas=1 (`slot.tscn`, ahora visible como PATH NEGADO). Marcas 140/0/0.
- M34 Pesca: OK. fallas=0. Marcas 145/0/8 = 153 (NO es 145/0/0 como decia la TANDA 4).
- M22 Historia: OK sobre la muestra, pero el muestreo NO ve las citas de seccion.
  Re-medido a mano: 91 [x] / 0 / 0.
  - 14 [x] citan `m22_spec.md` con una seccion que ese spec NO tiene
    (sec.Misterio x4, sec.Anti-exposicion x4, sec.Integracion x6).
  - CORRECCION IMPORTANTE de mi informe 462: de esas 14, 10 citan mal el DOCUMENTO,
    no inventan la seccion: sec.Anti-exposicion y sec.Integracion SI existen en
    03-Diseno.md. Solo sec.Misterio (4 items) no existe en ningun doc de M22.
  - 49 [x] apoyan solo en m22_spec.md. Desglose por verbo: 36 son "Definir/Documentar"
    (el spec ES el entregable, legitimo), 7 son implementacion (L90-L95 "Integrar con"
    + L127 "Crear 07-Resultados-Testings.md", que no existe), 6 son mantenimiento.
  - 2 [x] citan 06-Plan-Testings.md / 07-Resultados-Testings.md, inexistentes.
  - Inflacion clara: 7 items (L90-L95 + L127). No 25. Mi informe 462 sobre-degrado.
- M85 Modelos-3D-Legal: DISCREPANCIA (hallazgo NUEVO, no estaba en la tanda).
  - 99 [x] / 1 [ ] / 0 [?] = 100 en disco Y en HEAD.
  - 19 items [x] tienen en su propia nota: "los artefactos citados NO existen".
  - Los 5 artefactos citados dan 0 archivos en disco (model_legal_manager.gd,
    model_license_validator.gd, model_license.gd, model_credit.gd, build_script.gd).
  - Su linea `**Totales:**` dice "Completados: 73 - Pendientes: 25 - No resueltos: 2"
    y documenta una degradacion de 20 [x] -> [ ] del 2026-10-09 (atria-dawn, BUG-070).
    Esa degradacion NUNCA se aplico: el drift es +26 [x].
  - La linea se introdujo el 2026-10-11 (commit 531f597) y el archivo lleva 99 [x]
    desde entonces, commiteado. No es un artefacto de worktree.

## 9. LIMITE CONOCIDO QUE QUEDA ABIERTO

El muestreo P-100 toma max(5, 5%) de los [x]. Con 91 [x] son 5 items: si el defecto
esta CONCENTRADO (M22: 14 items de 91 = 15%), la muestra puede no tocarlo y el
veredicto sale OK. Es un limite de potencia del metodo, no del fix. Propuesto a la
directora: chequeo de CONCENTRACION (si un solo documento sostiene > 40% de los [x],
avisar que la muestra no es independiente). No implementado en esta vuelta.

## 10. CIERRE

- 0 commits / 0 push / 0 flips de marca / 0 auto-sellos 21.8.
- No se toco CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot ni ningun
  05-Checklist.
- Sondas y backups en .workbuddy-ai/tmp/ (scratch, no versionado).
- Pool de log: cabeza 2262, max en disco 2261 -> consistente. Reservado 2262.
- Canal: 463 = max(archivos) + 1.
---

# ANEXO - RAMA 1 SOBREVENIDA: mensaje 463 de la directora (llegado a las 03:03)

A mitad de la vuelta aparecio el mensaje **463** (respuesta a mi 462). RAMA 1 manda, asi
que se ejecuto en esta misma vuelta. Autoriza 4 frentes con GO explicito.

## 11. BUG-152 - PARCHE + GUARDIAN (msg 463 punto 6, GO explicito)

Archivo: `game/isla-ancestral/scripts/ui/qa_dirty_item4.gd` (v2 -> v3).

- **Parche:** `pausita._actualizar_dirty()` -> `pausita._refrescar_guardar_dirty()`.
  El metodo real esta en `pause_layer.gd:161` (`_boton_guardar.disabled = not sm.is_dirty()`).
- **Guardian de 3 capas** (el defecto estructural que lo volvia invisible):
  1. contador `_checks` + piso `CHECKS_MINIMOS = 6` MEDIDO en verde;
  2. `_fin()` por bloque (A/B/C/D) para que el resumen NOMBRE cual no se ejecuto;
  3. `_arrancar -> await _correr -> _summary` + watchdog de 30 s. Antes el `quit()`
     estaba SOLO al final: cualquier aborto de runtime dejaba la suite colgada.
- **Verde:** 6 checks / 0 fallos / 4/4 bloques / EXIT 0 x3, ~38 s por corrida.
- **Sondas EN ROJO** (restauracion byte-exacta, sha256
  `294eb5f58bddddb96a92aa5b6387026f4f284285d403288730db3b55de1554f2`):
  - S1 reinyectar el bug (`_actualizar_dirty`): **EXIT 1 en 37,6 s**, nombra
    `bloques NO ejecutados: ["B","C","D"]` + `solo 2 checks ejecutados (minimo 6)`.
    Antes de este parche el mismo defecto daba **EXIT 124 (cuelgue)**.
    Esto es la prueba de que el guardian convierte un cuelgue en un fallo nombrado.
  - S2 piso 999: EXIT 1, nombra `minimo medido 999`.
  - S3 asercion del bloque B invertida: EXIT 1, nombra el check.
- **Bug colateral corregido en la nota:** el item original decia que la capa usa
  `_input_event`; el metodo real es `_unhandled_input` (`inventory_layer.gd:415`).

## 12. M14 INVENTARIO - RE-BASELINE (msg 463 punto 3)

`DOCUMENTACION/14-Inventario/plan-actual/05-Checklist.md`
- L163: cita corregida `_crear_slots` -> `_construir_slots()` (real:
  `inventory_layer.gd:183`, `Button.new()` en L192).
- L183: `[x]` -> `[?]` con nota medida (gamepad inexistente; la "spec" citada por el
  FLIP anterior es `03-Diseno.md` L133 y **transcribe el claim FALSO**: cita
  autocontradictoria, no evidencia).
- Totales: 136/0/4 -> **139/0/1 = 140**.
- Medido antes: 140/0/0 real vs Totales 136/0/4. Despues: 139/0/1, drift 0.
- M14 queda **CAVEAT** y fuera de la cola de sellos (decision de la directora).

## 13. M34 PESCA - RE-BASELINE (msg 463 punto 5)

`DOCUMENTACION/34-Pesca/plan-actual/05-Checklist.md`
- Real medido: **145 [x] / 0 [ ] / 8 [?] = 153** (los 8 [?]: L15, L71, L75, L129,
  L141, L142, L143, L146; duenos M01/M136, M51, M52, M53, M42).
- Son **3 lineas `**Totales:**` + 4 blockquotes** (7 en total), no 4+4 como decia mi
  informe 462: L203 99/54, L204 99/54, L205 104/49, y blockquotes 99/54, 96/57,
  86/67, 84/69.
- Las 7 pasaron a **145 [x] / 8 [?] / 0 [ ] = 153**, con nota de re-baseline.
- Drift tras el cambio: 0. `verificar_checklist.py` NO reporta inconsistencia para
  M34 (la fila del GLOBAL ya coincidia).
- **Trampa aplicada:** el `grep -cE "^\s*- \[?\]"` daba 0 porque `?` cuantifica el
  `\[`. Conteo correcto por script: 8.

## 14. M22 HISTORIA - DEGRADACION + CORRECCION DE MI PROPIO HALLAZGO

`DOCUMENTACION/22-Historia-Principal/plan-actual/05-Checklist.md`
- Antes: 91/0/0. Despues: **78 [x] / 9 [ ] / 4 [?] = 91**, drift 0.

**CORRECCION IMPORTANTE de mi informe 462.** Dije "14 citas fantasma". Re-medido:
de esas 14, **10 NO son fantasma sino MAL ATRIBUIDAS**: `sec.Anti-exposicion` y
`sec.Integracion` SI existen como headings en `03-Diseno.md`; los items las citaban
como `m22_spec.md`. Solo **4** (`sec.Misterio`, L74-L77) no existen en NINGUN doc de M22.

Aplicado, por tanto:
- **4** L74-L77 -> `[?]` (seccion inexistente en todo M22; el tema esta bajo
  "Giros, pistas y foreshadowing" y "Revelaciones", pero la cita no es verificable).
- **10** L82-L84, L90-L95, L121: se **corrige la atribucion** a `03-Diseno.md`.
  En L82-L84 y L121 el `[x]` se **mantiene** (regla adoptada msg 371: una cita mal
  atribuida no degrada por si sola; el artefacto existe).
- **7** "Integrar con" (L89-L95) -> `[ ]`: `scripts/historia/` tiene 3 archivos y
  **0 llamadas `.connect()`**; no hay integracion cableada. (Mi informe 462 decia 9;
  el conteo real es 7.)
- **2** L126/L127 -> `[ ]`: citan `06-Plan-Testings.md` y `07-Resultados-Testings.md`,
  que no existen en `plan-actual/`.
- Totales: 91/91/0 "CERRADO [OK]" -> **78/9/4 "NO CERRADO"** con la explicacion.

## 15. HALLAZGO NUEVO: M85 MODELOS-3D-LEGAL (no estaba en la tanda)

Surgio al corregir la herramienta, no de una tarea pedida. Se reporta sin tocar el archivo.
- Estado: **99 [x] / 1 [ ] / 0 [?] = 100**, identico en disco y en HEAD.
- **19 items [x]** tienen en su propia nota: "los artefactos citados NO existen".
- Los 5 artefactos citados dan **0 archivos** en disco (`model_legal_manager.gd`,
  `model_license_validator.gd`, `model_license.gd`, `model_credit.gd`, `build_script.gd`).
- Su linea `**Totales:**` dice "Completados: 73 - Pendientes: 25 - No resueltos: 2" y
  documenta una degradacion de 20 `[x]` -> `[ ]` del 2026-10-09 (atria-dawn, BUG-070).
  **Esa degradacion nunca se aplico:** drift +26 `[x]`.
- La linea se introdujo el 2026-10-11 (commit 531f597) y el archivo lleva 99 `[x]` desde
  entonces, commiteado. No es un artefacto de worktree.
- `verificar_checklist.py` ya lo detecta: "GLOBAL dice 73/100 pero el 05 tiene 99/100".

## 16. VERIFICACION FINAL DE LA VUELTA

- `scripts/test_muestreo_p100.py`: **93 checks / 0 fallos / EXIT 0 x3**, piso 93 MEDIDO,
  16 bloques, 3 sondas en rojo con restauracion exacta.
- `qa_dirty_item4.gd`: 6/0/EXIT 0 x3, 4/4 bloques, 3 sondas en rojo.
- P-100 drift 0 en M14, M22, M34.
- `verificar_checklist.py`: EXIT 1 con **69 inconsistencias**, todas AJENAS salvo 3
  (fila 14: 136/140 vs 139/140; fila 22: 91/91 vs 78/91 + estado "Completado" con 9
  pendientes y 4 [?]). **No toco CHECKLIST-GLOBAL.md** (limite duro): se pide a la
  directora.
- 0 commits / 0 push / 0 auto-sellos 21.8.
