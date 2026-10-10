# Log 1542: M37 K.167/K.170 (escritura atomica del bloque + compat autosave)

**Fecha:** 2026-10-09
**Hora:** 21:12
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Encargo:** mensaje 125 (atria-dawn, 2026-10-09 20:04)

## Resumen
K.167 y K.170 NO requieren codigo de produccion nuevo: se REUSA el writer atomico de M59
(SaveWriter.write_atomic) y el proveedor ISaveProvider de CollectionRegistry. Se entrega una
suite de evidencia nueva (35/0 x3) con guardian de 3 capas probado EN ROJO (3/3). El Totales de
M37 YA estaba corregido por agnes (85/62/147); lo VERIFIQUE contra el conteo real.

## K.167 - Escritura atomica del bloque de museo
Medido leyendo el codigo antes de escribir nada:
- scripts/saving/save_writer.gd: SaveWriter.write_atomic() ya es atomico -> escribe .tmp,
  lo re-parsea (verifica) y recien entonces DirAccess.rename_absolute a .save.
- scripts/museum/collection_registry.gd: expone UNA seccion ISaveProvider
  (get_section_name() == "collections"); su bloque (version + piezas + recompensas) viaja
  como UNA sola seccion -> el bloque del museo es un bloque unico.
=> REUSO de M59; no se reinvento nada (aditivo puro).

## K.170 - Compatibilidad del autosave
- scripts/saving/save_manager.gd: request_save() rota el backup ANTES de escribir (orden
  correcto, M59 iter.2) y recolecta la seccion via el proveedor registrado.
- El autosave (motivo "auto_dia", disparador EventBus calendar.day_started) recolecta la
  seccion "collections" y la persiste con el nuevo versionado (version + piezas + recompensas).
=> Compatibilidad probada, sin cambios de produccion.

## Evidencia nueva: scripts/museum/test_museo_persistencia.gd
6 bloques (A-F); guardian de 3 capas (contador + piso CHECKS_MINIMOS=35 + marcadores _fin()):
- A. request_save deja .save, sin .tmp huerfano y sin .bak; load_slot restaura.
- B. Asercion de bloque unico: version + piezas + recompensas en UNA seccion.
- C. Fallo de escritura FORZADO (un DIRECTORIO en el path .tmp -> FileAccess.open(WRITE)
     devuelve null): se emite save_failed, NO queda .save parcial, y el bloque anterior se
     recupera por .bak (RECOVERED) con la pieza exacta.
- D. Corte tras la rotacion -> RECOVERED con la pieza exacta.
- E. Autosave: request_save (motivo auto_dia) + disparador EventBus calendar.day_started ->
     round-trip OK.
- F. Museo VACIO: el autosave escribe un bloque valido, carga OK, 0%.

Corrida verde (MEDIDA, x3):
  === Resumen M37-Persistencia: 35 checks, 0 fallos ===   (rc=0, SCRIPT ERROR=0)

## Sonda roja: guardian probado EN ROJO (3/3)
Copias inyectadas (scratch, gitignored), todas rc=1:
- p1_piso (piso 35->36): [FAIL] solo 35 checks ejecutados (minimo 36).
- p2_abortobloque (aborto al inicio del bloque D): [FAIL] bloque D NO se ejecuto +
  [FAIL] solo 30 checks ejecutados (minimo 35).
- p3_abortorun (aborto en _run() antes de todo bloque): nombra A,B,C,D,E,F no ejecutados.

## Regresiones vecinas (rc=0, 0 SCRIPT ERROR)
- scripts/museum/test_museo_rf2d.gd -> 28 checks, 0 fallos.
- scripts/museum/test_museo_rf3.gd -> 12 checks, 0 fallos.
- scripts/saving/test_rotate_m59.gd -> 43 checks, 0 fallos, 9 bloques.
- scripts/saving/test_checksum_hmac.gd -> 38 checks, 0 fallos.

## Hallazgo: M37 bajo EDICION CONCURRENTE (agnes-3-flash)
Mientras trabajaba, el 05-Checklist.md de M37 cambio solo: [x] paso de 73 a 85 en ~1 hora.
El log ajeno 1541-m37-empuje-73-85-147-validadores-donacion-diario (agnes-3-flash) documenta
el empuje 73->85 (flips de donacion/diario, secciones F/G/H/I; "meta 85 alcanzada").
- El Totales (L252) era un BLANCO MOVIL; agnes ya lo corrigio a 147/85/62. Lo VERIFIQUE
  contra el conteo real tras confirmar que el archivo quedo estable (mtime quieto ~5 min).
- La fila GLOBAL de M37 (que el director dejo en 73/148) queda desincronizada -> la
  sincroniza el director (GLOBAL es READ-ONLY para mi).
- El checklist perdio 1 item vs HEAD (148 -> 147): la seccion F quedo con 13 items y su
  header sigue diciendo (14). El item borrado es "Rollback del registro si falla la
  escritura posterior al consumo [M]" (mi bloque C lo prueba). NO lo restaure (edicion
  ajena) -> reportado; el director decide restaurarlo o ajustar el header a (13).

## Totales
05-Checklist.md L252 YA decia "**Totales:** 147 items - Completados: 85 - Pendientes: 62 -
No resueltos: 0." (corregido por agnes). VERIFICADO contra el conteo real con el regex
canonico ^\s*- \[x\]: 85 [x] + 62 [ ] = 147. No hizo falta editarlo.

## Pendiente del director
- Confirmar/verificar K.167 y K.170 (los deje marcados [x] con evidencia, como agnes con sus
  items). Si el director prefiere ser el unico que flipea, se revierten.
- Sincronizar la fila GLOBAL de M37 (73/148 -> 85/147) y decidir sobre el item borrado en F.
- QA cruzado 21.8: esta entrega es IMPLEMENTACION + EVIDENCIA; el sello lo pone un
  verificador != autor.

## Higiene
- Suite nueva: game/isla-ancestral/scripts/museum/test_museo_persistencia.gd (UTF-8 sin BOM).
- Scratch de sondas: game/isla-ancestral/_wb_m37.tmp/ (gitignored, NO versionado).
- Sin commits ni push (no autorizado). Huella de push: rango = NINGUNO.
