# Log 2163 - M23 - Consecuencias con respaldo en disco + sincronizacion de la cola

**Modelo:** Step-5-WorkBuddy (WorkBuddy)
**Modulo:** 23-Historias-Secundarias
**Fecha:** 2026-10-23 23:40
**Rama:** 2 (director 194 = acuse de mi 193, sin trabajo nuevo -> COLA ACTIVA del BACKLOG-MASTER)
**Log:** 2163 (reservado del pool; cabeza medida justo antes = 2163; head actual del pool = 2164)
**Canal:** 195 (acuse 194 + tanda declarada) y 196 (tanda cerrada); tracker 192 -> 194

---

## 1. Que se hizo

Tanda M23 iter. 14. Entrada: la COLA ACTIVA del BACKLOG-MASTER estaba
DESINCRONIZADA con el modulo, y la seccion de consecuencias del 05-Checklist tenia
items `[ ]` cuyo respaldo ya existia en disco.

- **Des sincronizacion de la cola (medida):** los items "Crear las historias de 3
  comerciantes" y "Documentar historias de familias y comerciantes" figuraban `[ ]`
  en la COLA ACTIVA pero son `[x]` en 23-Historias-Secundarias/05-Checklist (L47/L48)
  desde la iter. 12 (Log 2135). En disco: cadena-ruta-del-mercader,
  cadena-cargamento-de-telas y cadena-secreto-del-yunque en
  data/historias/secundarias.json con NPC REALES (mercedes_lince mercader,
  olivia_nutria, ramon_tejon). Se sincronizo la cola (mi archivo), NO el modulo.
- **Cobertura de las 12 consecuencias (03-Diseno L53)** medida sobre los DOS
  catalogos reales (secundarias.json + cadenas_ejemplo.json, este ultimo mergeado y
  vivo desde iter. 3): 8 con respaldo (faro_encendido, jardin_florecido,
  plaza_decorada, puente_cruzable, cofradia_activa, molino_funcionando,
  estacion_reparada, biblioteca_iluminada) y 4 sin respaldo (taller_abierto,
  kiosko_abierto, camino_al_faro_despejado, puerto_ampliado).
- **2 flips con cita:** L108 "jardin florecido" y L111 "cofradia activa" `[ ]` ->
  `[x]`. El respaldo no es el nombre en el diseno: es el flag aplicado por una
  cadena a WorldState (M21) via secondary_stories_service.gd L232-236
  (`ws.set_flag(String(flag), bool(consec[flag]))` al completar la cadena),
  verificado end-to-end en el bloque S nuevo.
- **L109 "taller abierto"** queda `[ ]` honesto: 0 cadenas aplican el flag en
  ninguno de los dos catalogos y 0 hits del token en res://data. El bloque S lo
  guarda: si algun dia el flag aparece, el check falla.
- **Lineas de totales sincronizadas:** M23 = 71 [x] / 32 [ ] / 2 [?] = 105 por
  prefijo de linea. L170 arrastraba 63/40/2 (valor de la iter. 11) y ni la iter. 13
  ni esta se habian volcado ahi; L201 ya estaba al dia desde la iter. 13.

## 2. Entregables

1. `game/isla-ancestral/scripts/historias/test_historias.gd` - bloque S NUEVO
   `_test_consecuencias()` (21 checks) al final de `_run()`, helper
   `_token_en_arbol(token, raiz)`, BLOQUES A-S, piso 456 -> **477 checks / 0 fallos /
   EXIT 0 x2** (binario real Godot 4.7.2 console headless, 0 SCRIPT ERROR).
2. `DOCUMENTACION/23-Historias-Secundarias/plan-actual/05-Checklist.md` - 2 flips +
   nota medida de L109 + Estado a iter. 14 + las 2 lineas de totales sincronizadas.
3. `DOCUMENTACION/23-Historias-Secundarias/plan-actual/04-Codigo.md` - seccion
   Iter. 14.
4. `DOCUMENTACION/23-Historias-Secundarias/plan-actual/06-Plan-Testings.md` - bloque S
   + piso 477.
5. `DOCUMENTACION/23-Historias-Secundarias/plan-actual/07-Resultados-Testings.md` -
   seccion 10 con la corrida 1 en rojo y sus dos causas.
6. `DOCUMENTACION/TAREAS-POR-MODELO/step-5-workbuddy/BACKLOG-MASTER.md` - 2 items de
   la COLA ACTIVA `[ ]` -> `[x]` con cita (cola: 13 [x] / 103 [ ] = 116) + registro
   de la vuelta.
7. `Logs/2163-...md` (este archivo) y msjs 195/196.

## 3. Evidencia medida (binario real)

- Suite: **477 checks / 0 fallos / EXIT 0 x2**, 0 SCRIPT ERROR. `CHECKS_MINIMOS = 477`
  MEDIDO en verde (no estimado).
- Guardian EN ROJO por inyeccion de runtime Variant -> Dictionary tipado al inicio
  del bloque S: EXIT 1 con "el bloque S NO se ejecuto (posible SCRIPT ERROR que
  aborto la funcion)" + "solo 457 checks ejecutados (minimo 477)" (2 fallos).
- **Corrida 1 en ROJO (3 fallos, EXIT 1), causas mias, no del codigo:**
  (a) checks 1 y 2 fallaron con 8/4 en lugar de 7/5: mi medicion previa de cobertura
  usaba UN solo catalogo (secundarias.json) e ignoraba el de ejemplos, donde
  cadena-biblioteca aplica biblioteca_iluminada;
  (b) el negativo de `taller_abierto` fallo con 1 hit:
  `res://scripts/historias/test_historias.gd` - el guardian se AUTO-PISABA porque su
  propio archivo nombra el token en la lista de las 12. Ademas una mencion en un
  script no es respaldo de la consecuencia. Acotado a res://data con alcance
  declarado en el comentario y en el mensaje del check.
- Sonda: primera version con asignacion directa Node -> Dictionary = error de
  PARSE (el archivo entero no compilaba: falso rojo que no prueba nada). La
  inyeccion valida pasa por un Variant intermedio. Sonda borrada; 0 archivos
  `*sonda*` en scripts/historias/.
- Regresiones: la tanda no cambia codigo de produccion (0 .gd de produccion
  editados), solo el archivo de test y documentacion.
- Invariantes de EOL verificadas por bytes: los 4 archivos del plan-actual en LF
  puro sin BOM; BACKLOG-MASTER en CRLF puro sin BOM (1788/1788).

## 4. Limites y pedidos

- 0 commits / 0 push / 0 auto-sellos 21.8 / 0 protegidos tocados
  (CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot intactos).
- Pedidos al director (msg 196): ronda de commit de los paths; sync fila 23 del
  GLOBAL a **71/105**; visto bueno de los 2 flips (ofrecidos a revertir); reposicion
  de COLA ACTIVA si se agota.
- Proxima: NN > 194; sin mensaje -> cluster Exploracion (crear 8 misiones de
  exploracion + documentar cadenas y misiones de exploracion).
