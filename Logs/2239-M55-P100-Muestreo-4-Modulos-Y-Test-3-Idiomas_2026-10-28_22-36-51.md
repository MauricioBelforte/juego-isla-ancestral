# Log 2239 - P-100: muestreo de 4 modulos + M55 3 idiomas

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-28 22:36
**Modulo:** M55 (Diario) + verificacion P-100 de M48, M60, M151
**Entrada:** mensaje 446 (agnes-3-flash, tanda larga cierre-1nov)
**Responde a:** agnes-3-flash (446)

## 1. Que se hizo

Tanda larga pedida por la directora antes de mi salida del 1-nov, en 3 bloques: P-100 de los 4
candidatos a sello, items cerrables de M55, y documento de herencia.

## 2. Herramienta NUEVA: muestreador P-100 scriptable

`scripts/muestreo_p100.py` (READ-ONLY, exit 0/1/3) + `scripts/test_muestreo_p100.py`.

- Cuenta marcas por PREFIJO de linea (no substring), calcula drift contra la ultima linea
  `**Totales:**`, elige muestra DETERMINISTA de tamano max(5, techo(5% de [x])) y verifica cada
  item contra disco (ruta directa / del propio modulo / basename / alias de doc) o por grep de
  identificador con frontera de palabra.
- Suite: 60 checks / 0 fallos / EXIT 0 x3, piso 60 MEDIDO (empezo en 47 estimado y se corrigio al
  valor medido).
- 4 sondas EN ROJO sobre el archivo REAL con restauracion por sha256 (20 reintentos):
  A resolutor ciego -> 10 fallos EXIT 1; B todo-es-creacion -> 5 fallos EXIT 1;
  C conteo por substring -> 5 fallos EXIT 1; D piso 999 -> EXIT 1.
- Defectos propios corregidos durante el desarrollo (los detecto la propia suite):
  1. `def f(raices=RAICES_PATH)` liga el default al DEFINIR la funcion: parchear el modulo en el
     test no surte efecto y la suite verifica el repo real creyendo usar el fixture. Corregido a
     `raices=None` resuelto dentro.
  2. Matching de verbos por SUBSTRING: "Documentar integracion" entraba como creacion por
     "integra"; "esto es creacion" por "crea". Corregido a primera palabra completa.
  3. Poblacion vacia = falso verde: en M48 los [x] son enunciados ("Idle, caminar, correr del
     jugador"), la poblacion por verbo daba 0 y el muestreo salia VACIO. Se agrego fallback por
     artefacto citado.
  4. `03-Diseno.md` existe en ~40 modulos: resolver por basename verificaba contra el doc de OTRO
     modulo. Se agrego preferencia por el plan-actual del propio modulo (modo MODULO).
  5. La sonda C pasaba en VERDE: el fixture no distinguia prefijo de substring. Se agrego al
     fixture un item [ ] cuyo TEXTO contiene el literal `- [x]`. El test consagraba el bug.

## 3. BLOQUE 1 - muestreo P-100 de los 4 candidatos

Marcas medidas por prefijo, drift y veredicto:

| Modulo | Disco | Drift | Muestra | Fallas | Veredicto |
|---|---|---|---|---|---|
| M48 | 113/10/0 = 123 | 0 | 6 | 1 real + 1 cita obsoleta | CAVEAT |
| M60 | 189/3/4 = 196 | 0 | 10 | 0 (tras adjudicar runtime) | OK / HONESTO |
| M55 | 123/6/2 = 131 | -56 en [x] | 7 | 2 + 42 autocontradicciones | DISCREPANCIA |
| M151 | 155/6/6 = 167 | 0 | 8 | 0 en muestra, 2 notas STALE | OK con CAVEAT |

### M48 (Animacion)

- `animation_budget.json` NO EXISTE en el repo (find = 0). L177 [x] es INFLADO: el propio director
  lo degrado el 23-oct y Beam lo re-subio citando la spec de 03-Diseno. Una spec no es un artefacto
  (21.8.2.b punto 4).
- L236 cita `validate_animation.gd` (no existe) pero `validate_animation_cli.gd` SI existe: cita
  obsoleta, no inflacion.
- Los 10 [ ]: contenido/produccion (M45 rigs, M43 sonido, M74 festival) salvo L303 (duplicado de
  L13 [x]: mismo hecho 47->48), L231 (descarte documentable) y L201 (regla de arquitectura).

### M60 (Datos/Serializacion)

- 3 [ ] = M08 (regeneracion procedural, contrato de edits, log de chunks), confirmados.
- 4 [?] = M62 UI, M63 streaming, M16/M33 .tres, Profiler GUI, confirmados.
- `save.json` y `meta.json` son archivos de RUNTIME (user://), no artefactos de repo: mi detector
  los marcaba HUECO. Verificado por codigo: `gestor_slot.gd: existe_slot()` ->
  `FileAccess.file_exists(r["save"])` (L57-59). No es inflacion: es deuda externa honesta.

### M55 (Diario) - DISCREPANCIA

- 2 fallas reales en la muestra de 7: L45 (RUIDA_PROGRESADA sin emisor, grep = 0 en scripts/) y L109
  (valida refs de catalogo pero NO el vinculo pista->puzzle, lo dice su propia nota).
- HALLAZGO MAYOR: 42 items [x] llevan en su propia nota `**[ ] honesto ...**` con la razon de por que
  NO estan hechos (L105 "sin puente PISTA_LEIDA (M24)", L171 "el salto al mapa M54 no"). 4
  verificados a mano, todos contradiccion real.
- Drift de totales: declaraba 67/49/15 con 123/6/2 reales (-56 en [x], total cuadrado).

### M151 (Control-Final)

- 8/8 de la muestra RESUELTOS (release-build.yml, estado_release.json, regenerar_estado_release.py).
- L371 [?] "cablear el gate al CI" esta STALE: release-build.yml L93-102 corre
  control_final_gate.gd BLOQUEANTE. Candidato a flip.
- L326 [?] "ci_gates_verdes hardcodeado": cierto en quality.yml L1116 (`--ci-gates-ok "1"`), FALSO
  en release-build.yml L77 (lo calcula desde needs.test.result). Nota a corregir.
- 4 [?] restantes siguen reales (generar_acta.py / importar_*.py / acta-control-final.json
  ausentes). M151 queda AMARILLO: no es sellable con 6 [?] (DoD 21.6).

## 4. BLOQUE 2 - M55

### Suite NUEVA: 3 idiomas sin desborde de UI (L188)

`game/isla-ancestral/scripts/diario/test_diario_idiomas_m55.gd`

- 51 checks / 0 fallos / EXIT 0 x3 (piso 51 MEDIDO).
- 3 idiomas (es/en/pt) x 3 tamanos (12/16/24 px) sobre la capa REAL abierta en 1280x720: 0
  desbordes del panel, 0 textos sin wrap fuera del area util.
- Expansion POR CLAVE (no promedio): en/es max 1.289x (DIARY.CAT_SELLOS) <= umbral 1.30; pt/es
  1.176x (sin umbral documentado, se reporta).
- Control negativo: a 96 px el panel DESBORDA (prueba de que el medidor no es ciego).
- Guardian probado EN ROJO: aborto de runtime inyectado -> nombra bloques B-E, dispara piso, EXIT 1.
  Restaurado con sha256 identico.

TRAMPA NUEVA MEDIDA: `get_combined_minimum_size() > size` es INFALSABLE en Godot (size se clampea
al minimo). La primera version media eso y el control negativo se negaba a fallar. Se reemplazo por
panel-vs-viewport.

TRAMPA NUEVA MEDIDA 2: `_run()` con `await` no puede diferir `_summary()` desde `_init()` (corre en
el primer await y declara fallida una suite que iba bien). Patron correcto: `_arrancar()` ->
`await _run()` -> `_summary()`, con watchdog de 90 s.

### Flips aplicados (autorizados por 446 + evidencia medida)

- L93 (iconos de gemas): `id_derivado("minerales", ...)` asertado, suite iconos 56/0.
- L117 (iconografia de Sellos): `id_derivado("sellos", ...)` asertado, suite iconos 56/0.
- L188 (3 idiomas): suite nueva 51/0.
- L203 (icono faltante fallback): nivel 3 del resolutor, bloque B de la suite 56/0.
- M55: 123/6/2 -> **127/2/2 = 131**, re-baseline de `**Totales:**` con la linea previa conservada
  como historial.
- En las 4 lineas flipeadas, la nota vieja `**[ ] honesto 2026-10-20` quedo marcada como
  `**[NOTA VIEJA 2026-10-20, superada por la cita final]`: dejarla tal cual hacia que la marca [x]
  contradijera su propia nota, que es exactamente el defecto que esta vuelta denuncia.
  Recuento posterior: **42** items [x] siguen con nota `**[ ] honesto` (los 4 cerrados ya no).

### L77/L85 - NO degradados (premisa vencida)

La directora pidio degradarlas "si son honestos". La nota que las declara sin validador es del
2026-10-20, ANTERIOR a `iconos_diario.gd` (iter. 7, 2026-10-28). Hoy hay resolutor de 3 niveles
contra el inventario M46 con fallback. Lo que NO hay es una asercion especifica de siluetas del
bestiario: el encabezado del test dice cubrir L77/L85 pero ningun bloque lo mide (overstatement del
encabezado, no cobertura). Degradarlas seria tan falso como el [x] inflado -> decision del director.

## 5. BLOQUE 3 - herencia

`DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/HERENCIA-P100-CIERRE-1NOV.md`: metodo 21.8.2.b
paso a paso, las 10 trampas con la medicion que las prueba, estado de los 4 modulos, deuda abierta
(42 de M55, L77/L85, L371/L326 de M151, fila 48 duplicada, pool de canal desincronizado en 423) y
como retomarlo con `muestreo_p100.py` + `remedicion_gate1.py`.

## 6. Limites respetados

0 commits, 0 push, 0 auto-sellos 21.8, 0 cambios en CHECKLIST-GLOBAL.md / quality.yml / AGENTS.md /
project.godot / 05-Checklist ajenos. Flips aplicados: solo los 4 de M55 con autorizacion y evidencia.
Pool de canal NO tocado.

## 7. Pedidos a la directora

1. Autorizar (o no) la degradacion en bloque de los 42 items de M55 con nota `[ ] honesto` (no la
   aplique: 42 marcas no se mueven sin orden explicita).
2. Decidir L77/L85: agregar bloque de siluetas y flipar, o corregir el encabezado del test.
3. Flip L371 de M151 (gate ya cableado y bloqueante) y corregir la nota de L326.
4. Degradar L177 de M48 a [?] o crear `animation_budget.json`.
5. Decidir L303 de M48 (duplicado de L13) y L231/L201.
6. Actualizar la fila 55 de CHECKLIST-GLOBAL.md a 127/131 (yo no puedo tocar ese archivo).
7. Cablear `test_diario_idiomas_m55.gd` y `test_muestreo_p100.py` en quality.yml (pendiente GOs).
8. Reposicion de la COLA ACTIVA del BACKLOG-MASTER.

## 8. Evidencia

- `python scripts/test_muestreo_p100.py` -> 60 checks / 0 fallos / EXIT 0 x3.
- `python scripts/muestreo_p100.py --todos` -> EXIT 0, 4 modulos medidos.
- Godot headless `test_diario_idiomas_m55.gd` -> 51/0/EXIT 0 x3.
- Godot headless `test_diario_iconos_m55.gd` -> 56/0/EXIT 0.
- Godot headless `test_diario_lore_m55.gd` -> 67/0/EXIT 0.
- 4 sondas en rojo del muestreador + 1 sonda en rojo de la suite de idiomas, todas con restauracion
  verificada por sha256.
