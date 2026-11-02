# Log 2297 - M40 b3: integracion GameFlowManager <-> SceneManager

- Fecha: 2026-11-01
- Agente: DeepSeek-V4.1-Flash (WorkBuddy)
- Rama: 2 (no habia mensaje nuevo del director: tracker 492 = max NN del canal, 493/494/495 son propios)
- Modulo: 40-Infraestructura
- Item: 9 de la COLA ACTIVA - "M40 b3: cierre (integracion GamedFlowManager/SceneManager)"
- Numeros: log 2297 (pool 2297 -> 2298); mensaje 496 = max(archivos) 495 + 1

## 1. Premisa medida ANTES de escribir

- M40 en disco: 210 [x] / 1 [ ] / 0 [?] = 211. El unico [ ] (L261) es el item invalido por
  diseno ya declarado (copiar plan-inicial byte a byte contradice AGENTS.md 3). No habia
  implementacion pendiente MARCADA, asi que el trabajo era medir si la integracion existe.
- SceneManager.cambiar_escena(): 0 llamadores de produccion. Los 6 hits son de las 2 suites.
  Bootstrap._load_main_scene() usaba get_tree().change_scene_to_file() directo.
- Senales locales del SceneManager (cambio_iniciado / cambio_completado / cambio_fallido):
  0 consumidores en todo game/isla-ancestral.
- GameFlowManager.cambiar_estado(Estado.ERROR): 0 llamadores de produccion (solo suites).
  Estado.CARGANDO si tiene llamadores (ui_root.gd:157 y :222, M89/M53) pero NADIE lo saca de
  ahi: tras "Jugar"/"Continuar" el flujo queda varado en CARGANDO.
- infra.boot_completado: declarada en event_bus.gd:171, 0 emisores (solo 2 suites comprueban
  que la senal EXISTA).
- escena_actual(): exigido por 03-Diseno.md 5.5, 0 apariciones en scripts/core/.
- bootstrap.gd llevaba el flujo a MUNDO con un 3 literal.

Conclusion: la "integracion" era NOMINAL. Dos APIs correctas y ninguna en una ruta de
produccion. Es el mismo falso verde del track_* de M105: la API existe, el consumidor no.

## 2. Implementado

1) scene_manager.gd (+89/-4):
   - const MODO_SIN_FLUJO = -1 y var _modo_pendiente.
   - cambiar_escena(ruta, modo): durante la carga -> CARGANDO; al completar -> modo; si falla
     -> ERROR (solo con modo pedido, ver D40-3).
   - estado_flujo(nombre): resuelve el enum del GameFlowManager POR NOMBRE via get("Estado"),
     fail-closed a -1. Cero numeros magicos.
   - sincronizar_flujo(nuevo): idempotente (mismo estado -> true sin emitir evento), avisa
     nombrando ambos estados, nunca rompe la carga de escena.
   - _sincronizar_error(modo), escena_actual(), verificar() (auditoria que no muta estado).
2) bootstrap.gd (+48/-9): el flujo se lleva a MUNDO por nombre A TRAVES de SceneManager
   (fallback al enum del GFM); se elimino el 3 magico. Se emite infra.boot_completado al
   final de la secuencia de arranque con flag de idempotencia.
3) test_infraestructura_m40.gd (iter. 3): bloque nuevo integracion_flujo (14 checks),
   aserciones de flujo dentro de scene_manager, piso medido y capa de nombres.

## 3. Defecto propio encontrado en la MISMA suite (y corregido)

_test_scene_manager es una CORRUTINA (await process_frame) y se llamaba SIN await desde
_run. Consecuencia medida en la corrida previa al cambio: _summary() corria antes de que la
corrutina despertara y quit(0) cerraba el arbol. La suite publicaba:

    28 checks, 0 fallos / "TEST M40 OK - todos los checks pasaron"

y los 2 ultimos checks (carga_iniciada, carga_completada) NUNCA se ejecutaban; el print
"[M40] Escena cargada: ..." aparecia DESPUES del resumen, delatando el orden real.
Es un falso verde por corrutina no esperada. Ademas se reemplazo una asercion INFALSIFICABLE
(gfm.has_method("transiciones_permitidas")) por el contrato real: mutar la copia que devuelve
transiciones_permitidas() no debe tocar TRANSICIONES.

## 4. Evidencia medida (Godot 4.7.2 headless, binario real)

- Suite: 60 checks / 0 fallos / 7 bloques / EXIT 0 x3, 0 SCRIPT ERROR.
  Piso CHECKS_MINIMOS = 60 MEDIDO en verde (no estimado ni copiado).
- Arranque real: "[M40] Flujo: 0 -> 3", "[Bootstrap] GameFlowManager -> MUNDO (via
  SceneManager)", "[Bootstrap] infra.boot_completado emitido", 0 SCRIPT ERROR.
- EOL: scene_manager.gd y la suite son LF puro (0 CR); bootstrap.gd quedo CRLF puro
  (223 CRLF, 0 LF sueltos) porque se parcheo por bytes; los 2 docs de M40 CRLF puro
  (04: 379 CRLF / 0 sueltos; 03: 352 CRLF / 0 sueltos). Sin BOM en los 5 archivos.

## 5. Sondas EN ROJO (restauracion byte-exacta por sha256 verificada)

- S1: sincronizar_flujo neutralizado (no llama al GameFlowManager) -> EXIT 1, 60 checks,
  6 fallos nombrados: "el flujo quedo en MUNDO estado=0", "transicion prohibida MUNDO->BOOT
  rechazada", "el flujo no muto tras el rechazo", "carga fallida con modo -> flujo en ERROR
  estado=0", "durante la carga el flujo es CARGANDO estado=0", "tras la carga el flujo es
  MUNDO estado=0".
- S2: aborto de RUNTIME al inicio del bloque integracion_flujo -> EXIT 1,
  '[FAIL] bloques que NO se ejecutaron: ["integracion_flujo"]' + '[FAIL] solo 37 checks
  ejecutados (minimo 60)'. La capa de nombres NO es ciega.
- S3: piso subido a 999 -> EXIT 1 ("solo 60 checks ejecutados (minimo 999)").
- Verde final tras restaurar: 60/0/EXIT 0, sha256 identicos a los previos
  (scene_manager f4e4e6b31f3fc0ae..., suite 1062fe6840195243...).

## 6. Divergencias declaradas (NO aplicadas a las marcas)

- D40-1: `modo` = estado objetivo AL COMPLETAR la carga (no "modo de transicion"). Es la
  unica lectura que generaliza: cargar un menu debe terminar en MENU, no en MUNDO. Con
  MODO_SIN_FLUJO (-1, default) el flujo no se toca: contrato previo conservado.
- D40-2: 03-Diseno 4 declara TRANSICION y el enum no lo tiene. estado_flujo("TRANSICION")
  devuelve -1 a proposito (fail-closed, no se inventa un estado) y la suite lo fija como
  contrato. Coherente con la degradacion L81 ya registrada.
- D40-3: una carga fallida deriva a ERROR SOLO si el llamador pidio flujo (modo != -1). Una
  ruta mala de un llamador legado no debe mandar el juego entero a ERROR.

## 7. Lo que NO hice

- 0 flips de marca: el 05-Checklist de M40 es NO TOCAR para este agente. Propuestas abajo.
- No toque ui_root.gd (M89/M53): el flujo varado en CARGANDO tras "Jugar" sigue ahi; el
  camino de vuelta ya existe (sincronizar_flujo) pero el llamador es de otro dueno.
- No toque CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md ni project.godot.
- 0 commits, 0 push.

## 8. Flips PROPUESTOS (los aplica el director)

- L111 "RF7: transicion boot -> menu -> mundo solo via SceneManager" esta [x] y la premisa
  medida dice que el arranque real NO pasa por SceneManager: project.godot apunta
  main_island.tscn como run/main_scene y _load_main_scene() retorna temprano ("ya activa: se
  omite recarga"). Hoy la relacion flujo<->escena SI pasa por SceneManager (b3), pero la
  carga de escena en el arranque no. Candidato a [x] con nota o a [ ] segun criterio.
- L213 "M63: SceneManager consume el contrato de carga con progreso de M63" [x]: el progreso
  visual sigue siendo de M63 y no se toco.
- Ninguna degradacion propuesta por mi cuenta: solo el hallazgo de RF7 para que decida.

## 9. Trampas nuevas

- T-A: una suite puede publicar N checks y no ejecutar los ultimos si un bloque es CORRUTINA
  y se llama sin await. El sintoma es "0 fallos" + prints del motor DESPUES del resumen.
  Verificar SIEMPRE el orden: el ultimo print de la suite debe ser el resumen.
- T-B: _fin() en el LLAMADOR no protege de un aborto de runtime (el llamador retoma y marca
  el bloque como visto). _fin() va al FINAL DEL CUERPO del bloque. Lo implemente mal primero
  y lo corregi antes de medir; la sonda S2 lo confirma.
- T-C: get("Estado") sobre una instancia GDScript SI devuelve el Dictionary del enum
  (medido: {BOOT:0, MENU:1, CARGANDO:2, MUNDO:3, PAUSA:4, ERROR:5}). Permite cablear por
  NOMBRE sin numeros magicos ni reflexion fragil.
- T-D: un modo `-1` como "no tocar" es la unica forma de agregar orquestacion a una API con
  llamadores previos sin cambiarles el comportamiento; cualquier otro default rompe en
  silencio a los llamadores que no se pueden editar.
