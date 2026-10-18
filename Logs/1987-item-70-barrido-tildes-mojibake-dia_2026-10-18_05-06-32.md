# Log 1987 - Item 70 - Barrido de tildes/mojibake en archivos nuevos del dia (28 diagnostico)

**Agente:** Step-5-WorkBuddy
**Modulo:** M28 (diagnostico de higiene 28; no toca modulo de codigo)
**Fecha:** 2026-10-18 05:06 (GMT-3)
**Vuelta:** RAMA 2 - sin mensajes nuevos del director (tracker 70, ultimo = 070)
**Tarea:** item 70 de la seccion A del BACKLOG-MASTER de Step-5-WorkBuddy

## Universo medido
- 232 archivos de texto creados/modificados hoy (mtime >= 2026-10-18 00:00) en
  DOCUMENTACION/, Logs/, Mensajes entre modelos/, scripts/, scripts-prueba-temp/,
  scripts-reutilizables/, Obsoletos/, PAPELERA/, out/, .workbuddy-ai/,
  game/isla-ancestral/scripts y legal/ (extensiones .md .gd .py .txt .json .tres).
- 0 archivos vacios. 232/232 decodifican como UTF-8 estricto (0 invalidos).
- Metodo: barrido propio por bytes (BOM, U+FFFD, marcadores clasicos de mojibake,
  triplet del BOM leido como cp1252, bytes de control, NUL, EOL) + los gates del repo.

## Mojibake real: 0
4 archivos con hallazgos del barrido propio, ninguno mojibake real:
- DOCUMENTACION/TAREAS-POR-MODELO/agnes-3-flash/BACKLOG-MASTER.md (92.439 B): 1 marca
  del patron emoji-leido-como-latin1 -> es CITA del patron (el archivo explica 'si un
  diff muestra mojibake, lo corrijo'). Falso positivo de mi lista de marcadores
  (familia PAT_LINEA_DOC). Ajeno, NO tocado.
- DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md (292.449 B):
  marcas 'o-con-tilde-roto' y del patron emoji -> misma situacion (cita del patron en
  un bloque de advertencia). Ajeno, NO tocado.
- .workbuddy-ai/memory/automations/1d934e73-457c-470a-a03f-b5c00b0ad229/memory.md
  (235.478 B): 2 bytes de control 0x08 (offsets 220631 y 220635) -> documentacion
  DELIBERADA de la trampa 'un 0x08 antes y despues de hud no matchea hud_request'.
  Ajeno, NO tocado. Efecto colateral medido: el byte de control hace que grep trate
  el archivo como binario y no muestre su contenido.
- .workbuddy-ai/tmp/barrido_2026_10_18.py: falso positivo propio (contiene los
  marcadores como literales del script).

## Gates del repo medidos hoy: los dos en verde
- scripts/diagnosticar_mojibake.py -> EXIT 0. SUCIO 0 / IRREVERSIBLE 0 / EXCLUIDO 365.
  'LIMPIO: no queda mojibake reparable'.
- --selftest del mismo detector -> 28/28 casos OK -> el detector no esta ciego, el
  veredicto LIMPIO es creible (no es un auditor ciego que dice 0 por no mirar).
- scripts/verificar_bom.py -> EXIT 0. 'Sin BOM: ningun archivo empieza con EF BB BF'.
- Contexto: en la vuelta del 2026-10-17 19:47 ambos estaban ROJOS por archivos ajenos
  (13 SUCIO en canales historicos + 1 tracker de agnes-3-flash con BOM). Medido HOY
  en verde: los limpio otro agente entre esas 19:47 y ahora. NO se hereda el OK: se
  corrio el proceso hoy (exit codes leidos del proceso, no de la tuberia).

## HALLAZGO PRINCIPAL del dia: 17 logs violan la convencion ASCII PURO + CRLF
- Convencion (AGENTS.md): Logs = ASCII PURO (por bytes) + CRLF + sin BOM.
- De los 23 logs escritos hoy, 17 tienen bytes no-ASCII: 221 en total. Todos son de la
  serie 'Tanda-NN' y su cabecera **Modelo:** dice DeepSeek-V4.1-Flash (autor medido
  por cabecera, no por nombre de archivo). Caracteres: U+2014 (guion largo) domina,
  mas U+00A7 (seccion), U+00ED (i con tilde), U+00FC (u con dieresis), U+00AB/U+00BB
  (comillas latinas), U+2705 (emoji check). Los 17 estan ademas en LF puro, no CRLF.
- Numeros: 1965, 1967, 1969, 1970, 1971, 1973, 1974, 1975, 1976, 1977, 1978, 1979,
  1981, 1982, 1983, 1984, 1985.
- NO son mojibake (UTF-8 valido), pero violan 'ASCII puro' de Logs/. 3 verificados con
  git ls-files: TRACKEADOS -> la violacion ya quedo en la historia commiteada.
  Reportado al director (mensaje 77); NO tocados (son ajenos).
- Mis logs del dia (1968, 1980) verificados ASCII PURO + CRLF + sin BOM. Mis mensajes
  de canal 73-76 verificados UTF-8 sin BOM + LF puro + FFFD 0.

## Por que nadie lo vio: el gate excluye Logs
- scripts/diagnosticar_mojibake.py linea 105: EXCLUIDOS_DIR incluye './Logs' -> el gate
  anti-mojibake NUNCA escanea Logs/ (y aunque lo hiciera, busca mojibake, no ASCII
  puro). Los 17 logs con guion largo pasarian igual: confirmado por lectura de codigo
  y por la medicion. Es la familia 'el guard que no guarda' (convencion manual sin
  gate).
- Pedido al director: (a) trasladar la convencion a DeepSeek-V4.1-Flash; (b) evaluar un
  gate de ASCII para Logs/ (hoy no existe).

## Artefactos, verificaciones y limites
- Artefactos: este Log 1987 + mensaje 77 al director + informe
  TAREAS-POR-MODELO/step-5-workbuddy/item-70-barrido-tildes-mojibake-2026-10-18.md +
  BACKLOG-MASTER item 70 -> [x] + pool de canal 77 consumido (head sigue stale en 62).
- LogASCII verificado: 0 bytes > 127 en este archivo (verificado por bytes).
- Limites: 0 commits / 0 push / 0 archivos ajenos modificados / 0 ediciones a
  CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot.
