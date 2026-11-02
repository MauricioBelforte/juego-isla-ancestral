# Log 2296 - M40 - muestreador P-100: Totales ilegible, --todos falso y 6 [x] sin escena

- **Fecha:** 2026-11-01 19:18:20
- **Modelo:** DeepSeek-V4.1-Flash (WorkBuddy)
- **Modulo:** M40-Infraestructura (tarea 8 de la COLA ACTIVA: "M40 b2: continuar")
- **Rama:** 2 (sin mensaje nuevo del director: max NN del canal = 494, propio; tracker 492)
- **Numeracion:** log 2296 (reservado con reservar_log.py); mensaje 495 (pool de canal roto:
  head 423 vs ultimo 494 -> max+1, pool NO tocado)
- **Commits:** 0. **Push:** 0. **Auto-sellos 21.8:** 0.

## 0. Premisa medida ANTES de aceptar la tarea

El BACKLOG-MASTER dice "M40-Infraestructura (175/211): 36 pendientes". **Vencida.**

Medido por prefijo en DOCUMENTACION/40-Infraestructura/plan-actual/05-Checklist.md:
**210 [x] / 1 [ ] / 0 [?] = 211**. El unico pendiente (L261) ya esta declarado invalido por
diseno. Es decir: la tarea "continuar" no tenia trabajo de implementacion pendiente.

Verificada la premisa de L261 (plan-inicial vs plan-actual): 02-Analisis identico; 01-Requerimientos
12449 vs 13068, 03-Diseno 14707 vs 23933, 04-Codigo 11716 vs 16607, 05-Checklist 17969 vs 44378.
Los tres primeros DEBEN diferir (AGENTS.md 3: plan-actual es lo vigente que se ACTUALIZA). El item
sigue `[ ]` sin flip: es invalido por diseno, no un pendiente.

## 1. Hallazgo 1: el muestreador no leia la linea `**Totales:**` de 9 modulos

Al medir M40 con `scripts/muestreo_p100.py --modulo 40`, la salida decia:

    Totales: SIN LINEA **Totales:** EN DISCO

...y la linea EXISTE en L299. Causa: `RX_TOTALES` exigia la unidad `items|items-acentuado`
y M40 escribe **"211 lineas-item"**. Un segundo defecto, del mismo tipo: "no hay linea" y
"hay linea que no entiendo" emitian **el mismo mensaje**, asi que un parser ciego era
indistinguible de un checklist sin Totales (familia trampa 91).

Alcance medido sobre los 168 modulos con 05-Checklist en disco: con el parser original,
**9 de 168** tenian linea de Totales que NO se leia (5 por unidad "lineas-item": M40, M59,
M68, M70, M90; 4 mas por orden invertido / parentesis con digitos / sin negrita).

### Fix aplicado (scripts/muestreo_p100.py)

1. Parseo **por ETIQUETA**, no posicional: cada numero se busca por su nombre
   (Completados / Pendientes / No resueltos) en cualquier orden, con o sin `**`,
   con cualquier unidad y con parentesis que contengan digitos.
2. Alias `[?]:` para "No resueltos" (vocabulario de M157).
3. `estado_totales()` con tres estados: **OK / AUSENTE / NO_PARSEA**. NO_PARSEA conserva
   la linea cruda y se imprime distinto: "LINEA PRESENTE PERO NO PARSEA (revisar formato)".
   Una ceguera de medicion ya no se disfraza de ausencia.

Medido despues: **167/168 OK, 0 NO_PARSEA, 1 AUSENTE** (M71, que realmente no tiene la linea).
Recuperados 9 modulos.

## 2. Hallazgo 2: `--todos` estaba hardcodeado a 4 modulos

    if a.todos:
        mods = ["48", "60", "55", "151"]

Un flag que promete "todos" escaneaba cuatro. Medido: `--todos` imprimia **4 modulos**; con
`modulos_en_disco()` (enumera DOCUMENTACION/*/plan-actual/05-Checklist.md) imprime **168**.
Costo: 107 s.

Barrido global medido (168 modulos):
- veredictos: **99 OK / 49 CAVEAT / 17 DISCREPANCIA / 3 CIEGO** (M01, M79, M143).
- suma de huecos: **78**.
- cruce de Totales: **167 OK / 1 AUSENTE**.
- drift de completados (`delta_x != 0`): **84 modulos**; de esos, solo **2** tienen tambien
  el TOTAL mal: M50 (declara 142, real 141) y M53 (declara 165, real 164).
- exit 3 por los 3 modulos CIEGO (correcto: 3 = detector ciego, no 1).

## 3. Hallazgo 3 (falso positivo propio): citas relativas a la raiz del modulo

`resolver_path` recibia `prefer = <modulo>/plan-actual` y hacia `join(prefer, "plan-actual/")`
= `plan-actual/plan-actual` -> PATH FALTA sobre un directorio que EXISTE. Medido en M40
L260 y L253. Fix: base adicional **MODULO_RAIZ** (el padre de plan-actual). Medido: los
huecos de M40 bajan de 7 a 6 y los RESUELTO suben de 82 a 84; los 6 restantes son reales.

Un falso hueco es tan grave como un falso verde: contamina el veredicto con deuda inexistente.

## 4. M40: auditoria de los 210 [x] (no solo la muestra del 5 %)

La muestra 21.8.2.b de 11 items dio 1 hueco. Se auditaron **los 210** con las funciones del
propio muestreador: **84 RESUELTO / 114 INDETERMINADO / 6 HUECO / 6 PARCIAL**.
Los 6 HUECO son el mismo defecto de fondo, medido uno por uno:

| Linea | Item | Artefacto citado | Medido |
|---|---|---|---|
| L69 | RF2: transicion a ESTADO_MENU y carga de main_menu.tscn | main_menu.tscn | NO existe en ninguna base |
| L75 | RF7: boot.tscn siempre la primera escena | boot.tscn | NO existe; main_scene = main_island.tscn |
| L110 | RF7: boot.tscn con sanity visual y log de arranque | boot.tscn | NO existe; 0 referencias en codigo |
| L118 | error.tscn con motivo i18n y boton reintentar | error.tscn | NO existe |
| L119 | mundo (world.tscn) en modo CARGANDO -> ESTADO_MUNDO | world.tscn | NO existe |
| L212 | M53: el HUD se monta dentro de world.tscn | world.tscn | NO existe |

Mediciones que sostienen el veredicto (no impresion):
- `find . -name "*boot*.tscn"` = **0** (incluye Obsoletos/). Idem menu/error/world:
  los unicos hits son `addons/gdUnit4/.../GdUnitInspectorContextMenu.tscn` y
  `scenes/debug/debug_menu.tscn`, ninguno es una escena raiz del flujo.
- `grep -rn "boot.tscn"` fuera de .kilo: **solo** 01-Requerimientos, 02-Analisis y 03-Diseno
  de M40 (especificacion). **0** en .gd, .tscn o project.godot.
- `project.godot:15 run/main_scene="res://scenes/main_island.tscn"`.
- `scene_manager.gd` (63 lineas) expone `cambiar_escena(ruta)` generico y **no cita ninguna
  escena** por nombre: la transicion existe como funcion, las escenas raiz no existen.

Clasificacion honesta con el criterio ratificado (msg 448) y la regla adoptada (msg 371):
(a) el artefacto no existe en NINGUNA base ni variante -> si; (b) no es user://, plantilla,
clave de catalogo ni API externa -> si; (c) el item no documenta correccion ni sustituto -> si.
=> Los 6 son candidatos a degradacion. **NO se aplico ningun flip** (los aplica el director).

Propuesta: L75 / L110 / L118 / L119 -> `[ ]` (deuda propia de M40: crear las escenas).
L69 y L212 citan M53 (menu / HUD en world.tscn) -> `[?]` con dueno M53.

Los 6 PARCIAL y los 114 INDETERMINADO **no** son hallazgos: 114 no citan artefacto (no
verificables por script) y los PARCIAL incluyen falsos positivos del extractor de rutas
(`/root/EconomyManager`, `infra.carga.iniciada/completada` = nombre de senal, no archivo).

## 5. Drift de Totales de M40 (declarado, NO editado)

La linea L299 declara **211 lineas-item - Completados: 180 - Pendientes: 27 - No resueltos: 4**.
El disco mide **210 / 1 / 0**. delta_total = 0 (el total coincide) y **delta_x = -30**: la
declaracion va 30 completados por DEBAJO de la realidad (envejecio la celda de completados,
igual que las 7 filas del GLOBAL medidas en el informe 494).

No se edito: `05-Checklist.md` de un modulo esta en la lista de no tocar sin orden.

## 6. Suite del muestreador: 93 -> 119 checks, 4 sondas EN ROJO

Piso re-MEDIDO en verde en cada paso (93 -> 107 -> 115 -> 117 -> 119), nunca estimado.

Bloques nuevos (20 en total ahora):
- "Totales: variantes de unidad (M40 escribe 'lineas-item')": 12 checks, incluidos 3
  controles negativos (sin "Completados" -> None; etiquetas sueltas sin "Totales:" -> None;
  prosa que menciona la palabra no es una declaracion).
- "Totales: AUSENTE vs NO_PARSEA (ceguera != ausencia)": 5 checks.
- "imprimir distingue NO_PARSEA de AUSENTE": 3 checks sobre la salida real capturada.
- "--todos enumera el DISCO (no una lista hardcodeada)": 5 checks, **incluido el CABLEADO**
  (ejerce `main(["--todos","--json"])`, no solo la funcion).
- 2 checks nuevos en "resolucion de rutas" para MODULO_RAIZ + control negativo.

Sondas EN ROJO (todas con sha256 restaurado y verificado, 1 intento cada una):

| Sonda | Resultado |
|---|---|
| Restaurar la unidad fija `items` en el parser | **5 fallos, EXIT 1**, nombra M40/total/x-vacio-q |
| Restaurar `mods = ["48","60","55","151"]` | **2 fallos, EXIT 1** (los 2 del cableado) |
| Quitar la base MODULO_RAIZ | **1 fallo, EXIT 1** ("'plan-actual/' -> MODULO_RAIZ (None)") |
| Piso subido +1 (120) | **EXIT 1** ("solo 119 checks, minimo 120") |

**Sonda que NO se puso roja y obligo a rehacer el test:** la primera version del bloque de
`--todos` probaba `modulos_en_disco()` directamente, asi que con `main()` hardcodeado la suite
seguia en verde (115/0). Es la trampa "el gate no esta cableado": se agrego la llamada real a
`main(["--todos","--json"])` y recien entonces la sonda dio rojo.

Verde final x3: **119 checks / 0 fallos / EXIT 0**, `RESULTADO: PASS (119 checks, minimo 119)`.

## 7. Higiene de bytes

    scripts/muestreo_p100.py       CRLF 0  LF_solos 713  BOM False  NUL 0  FFFD 0
    scripts/test_muestreo_p100.py  CRLF 0  LF_solos 623  BOM False  NUL 0  FFFD 0

`--json` verificado PURO (parsea con json.load; la clasificacion va dentro del JSON).

## 8. Numeracion

- Log 2296: consumido del pool con la herramienta (protocolo v3).
- Mensaje 495: pool de canal roto (head 423 vs ultimo real 494) -> max+1, pool NO tocado,
  no commiteado. 22.a vuelta del mismo sintoma.
- `reservar_log.py --estado` reporta **13 problemas de numeracion AJENOS** (colisiones 1888,
  2120 y 11 mas, mas DOBLE ASIGNADOR 2295). No se toco ninguno.

## 9. Trampas nuevas para el skill

1. **Un regex posicional convierte un formato valido en "no hay linea".** La unidad
   ("items" / "lineas-item") y el ORDEN de las etiquetas son decorativos; parsear por
   etiqueta, no por posicion.
2. **"No hay linea" y "hay linea que no entiendo" deben ser estados DISTINTOS.** Si comparten
   mensaje, un parser ciego y un checklist sin Totales son indistinguibles.
3. **Un flag llamado `--todos` puede tener una lista fija de 4.** Medir cuantos modulos
   devuelve, no confiar en el nombre.
4. **Probar la funcion no prueba el cableado.** La sonda en rojo del `--todos` dio VERDE con
   el `main()` hardcodeado: hay que ejercer la ruta real de entrada.
5. **Una cita relativa a la raiz del modulo (`plan-actual/`) se resuelve contra la raiz del
   modulo, no contra el directorio donde vive el checklist.** Con `prefer = plan-actual` el
   join produce `plan-actual/plan-actual` y fabrica un hueco.

## 10. Pedidos al director

1. GO para aplicar los 6 flips propuestos de M40 (4 a `[ ]`, 2 a `[?]` con dueno M53).
2. Decision sobre el drift de Totales de M40 (180/27/4 declarado vs 210/1/0 real): no edito
   el 05-Checklist sin orden.
3. Si quiere preservar el trabajo del muestreador (2 archivos), orden de commit.
4. Nota: el prompt de la automatizacion sigue diciendo GLM-5.3-Flash mientras la firma que
   escribe es agnes-3-flash. Reportado como en las 22 vueltas anteriores.

## 11. Archivos tocados (4)

- `scripts/muestreo_p100.py` (parser por etiqueta, estado_totales, modulos_en_disco, MODULO_RAIZ)
- `scripts/test_muestreo_p100.py` (4 bloques nuevos, 26 checks, piso 93 -> 119)
- `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md` (marca de la tarea 8)
- este log

**0 commits / 0 push / 0 flips / 0 auto-sellos 21.8.**
