# Log 2154 - M59-Guardado: tanda "save slots + autoguardado" (Step-5-WorkBuddy)

**Fecha:** 2026-10-23 (GMT-3) - **Agente:** Step-5-WorkBuddy - **Modulo:** M59
**Ciclo:** V2 - RAMA 2 (sin mensajes nuevos del director; tracker 183) - item 35 de la
cola activa del BACKLOG-MASTER. Numero reservado con head medido JUSTO antes (2154).

## 1. Contexto medido antes de la tanda

- 05-Checklist M59: 102 [x] / 26 [ ] / 2 [?] = 130 (prefijo de linea; LF puro 365, sin
  BOM). La linea Totales coincidia (102/26/2, resync del director 00:15 de hoy).
  El item 35 del BACKLOG decia "60/130" (stale).
- Autoloads relevantes verificados en project.godot: SaveManager, DataStore, Inventario,
  Construccion (build_manager.gd), HouseManager, ItemDatabase, EventBus.
- Baselines previas corridas HOY con el binario real: test_slots_m59.gd 22/0 EXIT 0;
  qa_m59_profile_id.gd OK (11 checks).

## 2. Probe previo (comportamiento MEDIDO, no supuesto)

Probe temporal (_probe_ro_m59.gd, borrado al cerrar) para fijar la aseveracion de
solo-lectura antes de escribir la suite final:
- attrib +R sobre slot_1.save NO se puede aplicar pasando "+R" como argumento directo a
  attrib desde OS.execute (mangling medido: "Formato de parametros incorrectos"). Si
  funciona via un .bat generado al vuelo con el flag fijo.
- R1 MEDIDO: con el .save en solo-lectura, request_save() COMPLETA el guardado (Windows
  permite rotar el archivo read-only a .bak; el .save nuevo es fresco y verifica).
- R2 MEDIDO: con un DIRECTORIO en la ruta del .tmp, la escritura falla (save_failed),
  el .save previo queda en .bak y load_slot devuelve RECOVERED (3).

## 3. Suite A - test_slots_perfiles_m59.gd (NUEVA)

41 checks / 0 fallos / EXIT 0 x3 (binario real, 0 SCRIPT ERROR). Piso
CHECKS_MINIMOS = 41 MEDIDO en verde. 4 bloques:
1. 3 perfiles sin mezcla (L51): sello meta.profile_id por slot; cada carga solo trae
   los contenidos de su perfil.
2. Cambio de slot en plena sesion (L51): current_slot + perfil activo + bolsillo.
3. Sin cruzamiento (L166): PROFILE_MISMATCH sin restaurar nada.
4. Solo lectura (L167): R1 (save read-only -> completa) y R2 (destino bloqueado ->
   fallo graceful + RECOVERED + limpieza del directorio bloqueante).

Guardian probado EN ROJO por inyeccion 2 veces (aborto runtime en bloque 2, antes y
despues del _abrir): EXIT 1 con "BLOQUES QUE NO CERRARON: [2]" y "PISO NO CUMPLIDO:
32 < 41". Archivo restaurado byte-exacto (sha256 88b78f92e40ab82d...).

## 4. Suite B - test_carga_idempotente_m59.gd (NUEVA)

28 checks / 0 fallos / EXIT 0 x3. Piso 28 MEDIDO. 5 bloques:
1. Round-trip e2e sin duplicar (L95/L105): cargar 2 y 3 veces = mismas cantidades.
2. Limites de cantidad (L105): herramienta_basica 5 -> 1 (stack_max=1), baya_roja
   200 -> 99, n=0 y negativos ignorados; item inexistente ignorado (L116 inventario).
3. Construcciones idempotentes (L95): doble carga de la misma lista deja 2, no 4.
4. Casas parciales (L115): planta=1 y planta=3 preservadas; sin duplicar.
5. Muebles inexistentes (L116): tipo desconocido no crashea; fallback medido =
   estructura conservada con el tipo crudo.

Guardian EN ROJO por inyeccion (aborto en bloque 3): EXIT 1 con "[3]" nombrado y piso
23 < 28. Restaurado byte-exacto (sha256 4f51b8d59a5727d0...).

## 5. Trampa nueva (propia, corregida y documentada)

En una suite con await, el _summary() en call_deferred dispara en el PRIMER frame y su
quit() mataba el proceso a mitad de corrida: falso "1 check, suite incompleta" con la
suite realmente verde (medido en la 1ra corrida de la Suite A). Fix: bandera
_run_terminado que _summary() espera (hasta 3000 frames) antes de reportar.

## 6. Flips aplicados al 05-Checklist (7, con cita de suite)

L51, L166, L167 (Suite A) y L95, L105, L116, L115 (Suite B) ->
M59 = 109 [x] / 19 [ ] / 2 [?] = 130. Linea Totales sincronizada (109/19/2).
Ofrecidos a revertir. Los 19 [ ] restantes son de dueno externo (M74 eventos, M37/M36
colecciones, M56 fotos) o de testeo con dueno propio pendiente (L128 NPC/regalos,
L135/L136 misiones a medias - candidatos del proximo lote).

## 7. Regresiones medidas (binario real)

test_slots_m59 22/0 - qa_m59_profile_id OK - test_autosave_m59 0 fallos -
qa_m59_bloqueo_manual 5/0 - M55 test_diario_perf_m55 26/0 - M55 persistencia 0 -
M71 test_progresion 83/0. Todas EXIT 0.

## 8. Limites

0 commits / 0 push / 0 auto-sellos 21.8 / 0 protegidos tocados (CHECKLIST-GLOBAL.md,
quality.yml, AGENTS.md, project.godot intactos). Las 2 suites son archivos NUEVOS; no
se toco logica de produccion. user://saves quedo como scratch de prueba (los .save de
test se restauran/rotan segun el patron de las suites previas del modulo).
