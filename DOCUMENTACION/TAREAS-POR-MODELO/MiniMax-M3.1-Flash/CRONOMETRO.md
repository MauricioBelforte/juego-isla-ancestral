# CRONOMETRO DE MiniMax-M3.1-Flash — copia exacta para reactivacion rapida

**Modelo:** minimax-m3-1-flash · **Plataforma:** MiniMax API (Kilo Code) · **Actualizado:** 2026-10-27 21:55

Este archivo es la **copia exacta** del prompt del cronometro de este agente. Cuando el fundador (o el
director) pida "activa tu cronometro", no hay que reconstruirlo: se pega el bloque de abajo, tal cual, en
la herramienta `cron_create` y listo.

## Datos fijos

| Campo | Valor |
|---|---|
| Herramienta | `cron_create` (la del harness de Kilo Code) |
| Schedule | `0 * * * *` (cada 60 minutos) |
| Ultimo id creado | `wku_17fcb57f5001ibrgRaZ2c68TLo` (reactivado 2026-10-27 23:55, 60 min por orden del usuario) |
| Id vigente | `wku_17fcb57f5001ibrgRaZ2c68TLo` — **VIGENTE 2026-10-27 23:55 (cadencia 60 min)** |
| Cancelar | `cron_delete` con el id (el `cron_list` muestra el id vigente) |
| Repo | `D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral` |
| Canal de reportes | `Mensajes entre modelos/MiniMax-M3.1-Flash/` |
| Backlog | `DOCUMENTACION/TAREAS-POR-MODELO/MiniMax-M3.1-Flash/BACKLOGS/BACKLOG-MASTER.md` |
| Pools de numeros | `Logs/NUMEROS_DISPONIBLES.txt` (logs) y `Mensajes entre modelos/MiniMax-M3.1-Flash/NUMEROS_DISPONIBLES.txt` (mensajes) |

## Helper

`python scripts/activar_cron_minimax.py` imprime el schedule y el prompt EXACTOS listos para pegar en
`cron_create` (sin buscar el texto en este archivo).

> **ESTADO 2026-10-27 21:55 (GMT-3): CRONOMETRO VIGENTE a 60 MINUTOS.** El fundador pidio "actualiza tu
> cronometro para lanzarlo cada 60 minutos" (2026-10-27 23:54). Cadencia anterior `*/30 * * * *` (30 min),
> apagada a las 20:15 por orden del fundador y reactivada ahora. Cron creado:
> `wku_17fcb57f5001ibrgRaZ2c68TLo`, schedule `0 * * * *`, primer disparo 2026-10-28T00:00Z.
> El `SCHEDULE` del helper `scripts/activar_cron_minimax.py` se actualizo a `0 * * * *` en la misma vuelta.
> Aviso al canal: mensaje propio (numeracion ultimo+1 via `scripts/proximo_numero.py MiniMax-M3.1-Flash --consume`).

## Procedimiento de reactivacion (2 pasos)

1. `cron_list` -> si hay un cron de este agente, `cron_delete` con su id (dejar **uno solo** activo).
2. `cron_create` con `schedule = 0 * * * *` y `prompt` = el bloque de abajo, verbatim.
3. Avisar en el canal (mensaje propio, numeracion ultimo+1 via `scripts/proximo_numero.py MiniMax-M3.1-Flash --consume`).

## Prompt exacto (verbatim — NO editar sin actualizar la copia de arriba)

```text
=== PASO 0 — CONTEXTO PERSISTENTE (SIEMPRE primero, antes que cualquier otra cosa) ===

LEER tu contexto persistente del director antes de decidir qué hacer en esta vuelta:

python -X utf8 -c "import json; e=json.load(open('Logs/estado_director.json',encoding='utf-8')); print(json.dumps(e,indent=2,ensure_ascii=False))"

Sin esto estás ciego: no sabes qué agente dijo qué, qué frentes están agotados, qué trampas registró el director y qué derivaciones están pendientes. La lectura de este archivo NO sustituye tu propio trabajo: solo te da el mapa.

Si el archivo no existe o es ilegible:
- NO inventes contenido: seguí tu cronómetro normal sin el contexto, y avisa en tu mensaje al director ("estado_director.json ilegible o ausente") para que lo repare.

Después de leer, procedé con tus pasos normales. Y AL CERRAR la vuelta: si el director te dio una orden o cerraste algo material, así deben quedar los 3 lugares sincronizados:
1) tu mensaje en tu canal (firma + acuse, que es lo que el director detecta por lag),
2) el 05-Checklist del módulo que tocaste (flips con cita en disco),
3) la fila de CHECKLIST-GLOBAL.md (solo si el módulo es tuyo y el cambio es material).

=== BUCLE DEL AGENTE MiniMax-M3.1-Flash (cada 60 min; 3 pasos EN ORDEN) ===
[PASO 1] LEER TU CANAL PRIMERO: escanear "Mensajes entre modelos/MiniMax-M3.1-Flash/" — el ÚLTIMO archivo es lo nuevo del director. Si tiene instrucciones o preguntas → RESPONDER PRIMERO creando TU mensaje propio (numeración último+1 SIEMPRE via scripts/proximo_numero.py MiniMax-M3.1-Flash --consume; nunca a mano; pools gitignoreados). Leer el CUERPO COMPLETO de cada mensaje (pueden ser varios nuevos).
[PASO 2] SIN MENSAJES NUEVOS → TU BACKLOG: abrir "DOCUMENTACION/TAREAS-POR-MODELO/MiniMax-M3.1-Flash/BACKLOGS/BACKLOG-MASTER.md", elegir la próxima tarea [ ] (la COLA ACTIVA; agotada, la sección (C) FRENTE ESTÉTICO PREMIUM) y trabajar una TANDA.
[PASO 3] REPORTE AL DIRECTOR EN CADA VUELTA: escribir en tu canal qué hiciste (tarea(s), estado, evidencia — aunque no cierres todo) + marca [x] honesta en el BACKLOG (solo verificable en disco) + fila de CHECKLIST-GLOBAL si el módulo aplica.

REGLAS PERMANENTES (vigentes sin excepción):
- UTF-8 sin BOM, LF: escribir SIEMPRE con Python (NUNCA PowerShell Set-Content ni >).
- Numeración SOLO del pool NUMEROS_DISPONIBLES.txt de la carpeta destino (borras el número al escribirlo).
- Firma: tu modelo + plataforma + fecha; español.
- Independencia §21.8: quien hizo el trabajo no se auto-verifica ni auto-sella.
- NUNCA push.

REGLAS FIJAS (del prompt de arranque):
- UTF-8 sin BOM SIEMPRE (escribir con Python io, NUNCA PowerShell Set-Content — las tildes y el símbolo del proyecto se corrompen con cp1252).
- Firma en todo: MiniMax-M3.1-Flash (Modelo/Plataforma).
- Numeración de mensajes y logs: último+1 SIEMPRE via scripts/proximo_numero.py MiniMax-M3.1-Flash --consume (nunca a mano).
- No editar mensajes ajenos; no tocar módulos 🔵 de otros; un módulo por vez.
- Independencia §21.8/§21.23: tu QA lo hacen Hy3 o agnes-3-flash — NUNCA te auto-selles.
- Reporte al director (GLM-5.3 Flash-Director) EN CADA VUELTA en tu canal "Mensajes entre modelos/MiniMax-M3.1-Flash/": qué hiciste, estado, evidencia.
- Cuando el fundador te diga "apaga tu cronómetro": elimina el wakeup (cron_delete), avisa al director en tu canal y queda a la espera de reactivación.

TRAMPAS REGISTRADAS POR EL DIRECTOR (aplican a este bucle):
- Si un replace() de fila en CHECKLIST-GLOBAL.md falla en silencio, NO lo des por aplicado: verificá con grep del acuse y con el conteo real del 05-Checklist.
- Normalizá SIEMPRE los Totales al conteo REAL medido por prefijo (puede fallar dos veces seguidas).
- Flippear SOLO el texto exacto del [ ] vivo (items duplicados con textos distintos).
- Detectar Pythonismos bool (True/False) en GDScript antes de commitear código ajeno (3 SCRIPT ERROR de parse al boot).
- NUNCA uses globs amplias para limpiar archivos: `_sonda*.gd` me borró `tests/_sonda_bug119.gd` (de otro agente, trackeado) y tuve que restaurarlo con `git restore`. Listá primero, borrá solo lo tuyo.
- Al flipear un item, cambiá TAMBIEN el marcador (`- [?]` -> `- [x]`): una cita pegada al texto NO cambia el conteo. Me pasó en M112 y lo detecté recontando.
- El POOL de mensajes NO es atomico entre el director y yo: los dos tomamos 021, 022 y 025. Si renumeras un fichero, que sea SOLO el tuyo (el del director tiene "glm-5.3-flash-director" en el nombre).
- En Windows, `OS.execute()` NO captura la salida de un hijo consola: usar el patron del runner (cmd.exe /V:ON /C + redirect a archivo + create_process + polling).
- Al reconstruir una fila del CHECKLIST-GLOBAL.md, NO perder los bloques de notas de otros agentes: respaldar la fila del indice de git antes de reescribirla, y restaurarlos despues.

CONTEXTO DE ESTA SESION (2026-10-27 21:55, minimax-m3-1-flash / MiniMax API / Kilo Code): tanda completada M20 + M17, cronometro sigue VIGENTE a 60 min (proximo disparo 2026-10-28T01:00Z / 22:00 GMT-3).

RIELES ACTIVOS (los 2 🔵 mios, sin EN CURSO ajeno):
- **M20** (102/150) 🔵 — BUG M20 corregido (limite diario + validacion texto_id) + suite nueva `test_m20_limite_regalo.gd` (19 checks) + flips 05-Checklist + GLOBAL + quality.yml (Log 2219, acuse 059). **COMPLETADO**.
- **M17** (135/175) 🔵 — +5 items cerrados con checks nombrados contra catalogo real: G137 (puerta exige pared contigua), G138 (ventana exige pared contigua de 1 celda), G141 (camino solo sobre terreno), G145 (ruina/parcela NPC no colocables ni demolidas), F121 (re-validacion con cada rotacion). Suite `test_m17_reglas_pieza.gd` (40 checks, 0 fallos, EXIT 0) + cableo en quality.yml (Log 2220).
- **M112 (CI)**: fix aplicado del timeout flake del pool (suite con TIMEOUT en el pool se re-mide EN SERIE; no tolera fallos reales). PENDIENTE: el tiempo total del CI quedo en ~875 s > 600 s de presupuesto (lane voxel = 6 suites x ~72 s) → dueño a definir, NO es de M20.

PENDIENTE CONCRETO (proxima vuelta, lo primero): seguir con **M17 (P3)** 🔵 — items pendientes headless-verificables en el checklist (seccion G/H/I/J/K/L/M/N/O): P16 ("el validador no tiene regla de alturas"), P23 (rango 1-4 no verificado en tests), G139 (escalera circulación), H (zonas y permisos), I (piezas funcionales), etc. Buscar los que sean headless-verificables (mi nicho) y cerrarlos con checks nombrados, como en esta tanda.

CROSS-MODULE YA REPORTADO AL DIRECTOR (no lo toques sin coordinar): escala `amistad_<npc_id>` (M20 entrega el NIVEL 1..11; el registry de M162 exige >= 60 / >= 90 -> esas variantes nunca se disparan) · deriva de umbrales entre `data/balance/friendship.json` y `data/amistad/amistad_config.tres` (la .tres es la real en runtime) · bug M20: `regalar()` consume el limite diario "regalo" antes de validar el inventario (YA CORREGIDO 2026-10-27 20:25).
```

## Notas del agente (fuera del prompt)

- **COLA STALE:** NO tocar la cola `[73-Coleccionables]` del BACKLOG (M73 ya esta sellado ✅). El trabajo
  vivo = M20 + M17. Si se agotan, avisar al director para que te apile otro riel (M127 🟡 estaba disponible
  el 27oct).
- **Cadencia:** 60 min (antes 30 min). Si el fundador pide otra cadencia, `cron_delete` del id vigente +
  `cron_create` con el nuevo schedule + actualizar este archivo y `scripts/activar_cron_minimax.py`.