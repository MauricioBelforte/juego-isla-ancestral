# CRONOMETRO DE MiniMax-M3.1-Flash — copia exacta para reactivacion rapida

**Modelo:** minimax-m3-1-flash · **Plataforma:** MiniMax API (Kilo Code) · **Actualizado:** 2026-07-22 00:40

Este archivo es la **copia exacta** del prompt del cronometro de este agente. Cuando el fundador (o el
director) pida "activa tu cronometro", no hay que reconstruirlo: se pega el bloque de abajo, tal cual, en
la herramienta `cron_create` y listo.

## Datos fijos

| Campo | Valor |
|---|---|
| Herramienta | `cron_create` (la del harness de Kilo Code) |
| Schedule | `*/30 * * * *` (cada 30 minutos) |
| Ultimo id creado | `wku_161acbe8a0015RnIIMeMF6uzac` |
| Cancelar | `cron_delete` con el id (el `cron_list` muestra el id vigente) |
| Repo | `D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral` |
| Canal de reportes | `Mensajes entre modelos/MiniMax-M3.1-Flash/` |
| Backlog | `DOCUMENTACION/TAREAS-POR-MODELO/MiniMax-M3.1-Flash/BACKLOG-MASTER.md` |
| Pools de numeros | `Logs/NUMEROS_DISPONIBLES.txt` (logs) y `Mensajes entre modelos/MiniMax-M3.1-Flash/NUMEROS_DISPONIBLES.txt` (mensajes) |

## Helper

`python scripts/activar_cron_minimax.py` imprime el schedule y el prompt EXACTOS listos para pegar en
`cron_create` (sin buscar el texto en este archivo).

## Procedimiento de reactivacion (2 pasos)

1. `cron_list` -> si hay un cron de este agente, `cron_delete` con su id (dejar **uno solo** activo).
2. `cron_create` con `schedule = */30 * * * *` y `prompt` = el bloque de abajo, verbatim.
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

=== BUCLE DEL AGENTE MiniMax-M3.1-Flash (cada 30 min; 3 pasos EN ORDEN) ===
[PASO 1] LEER TU CANAL PRIMERO: escanear "Mensajes entre modelos/MiniMax-M3.1-Flash/" — el ÚLTIMO archivo es lo nuevo del director. Si tiene instrucciones o preguntas → RESPONDER PRIMERO creando TU mensaje propio (numeración último+1 SIEMPRE via scripts/proximo_numero.py MiniMax-M3.1-Flash --consume; nunca a mano; pools gitignoreados). Leer el CUERPO COMPLETO de cada mensaje (pueden ser varios nuevos).
[PASO 2] SIN MENSAJES NUEVOS → TU BACKLOG: abrir "DOCUMENTACION/TAREAS-POR-MODELO/MiniMax-M3.1-Flash/BACKLOG-MASTER.md", elegir la próxima tarea [ ] (la COLA ACTIVA; agotada, la sección (C) FRENTE ESTÉTICO PREMIUM) y trabajar una TANDA.
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

CONTEXTO DE ESTA SESION (2026-07-22 00:35, minimax-m3-1-flash / MiniMax API / Kilo Code): cronometro recreado a 30 min (el fundador lo pide de 60 -> 30).

ENTREGADO Y SELLADO POR EL DIRECTOR:
- **P1 (M112)**: suite 897.0 s -> 545.3 s; con la **lane voxel serial** bajo a **530.6 s y el CI quedo 49/49 VERDE, 0 timeouts** (Log 2102, acuses 016/029).
- **P2 (QA de M90)**: SELLO VALIDO (13/13 a nivel de VALOR + suites 85/0 y 57/0) — el director lo sello (msg 019); mi muestreo quedo como ejemplo canonico.
- **P3 (M17)**: 3 tandas selladas (94/175): suite nueva 44 checks, `iter6`/`iter7` arreglados AGREGANDO checks, wrapper `test_m17_suites_integracion.gd` (498 checks de M17 en el CI) ratificado (msg 026).
- **CENSO ratificado como hallazgo mayor de la flota** (msg 025): 471 suites, solo 49 las descubria el runner; 422 nunca corrieron en CI. Medidas: 387 verdes / 13 rojos / 22 timeouts. Herramienta: `scripts/auditar_suites_fuera.py`.
- **Lane de modulos (opt-in)**: el runner descubre `scripts/<modulo>/test_*.gd`; delta medido 435 suites, 12.284 tests (4.9x), 1787.2 s (29.79 min, EXCEDE 3x el presupuesto) y 13 rojos visibles. Sigue **opt-in** (`M112_INCLUIR_MODULOS=1` o `--incluir-modulos`) para no romper el presupuesto medido.
- **Lane SERIE EXPLICITA** (Log 2103): las 2 suites frame-heavy que colgaban en el pool salen a serie (pool 355 -> 353).
- **CI DESBLOQUEADO** (Log 2104): `scripts/foto/photo_service.gd` estaba COMMITEADO roto (2 errores de parseo) y el error salia en CADA corrida; fixes quirurgicos hechos, la suite `test_m56_tomar_foto` pasa 26/0. La logica del modulo sigue siendo de su dueno.

PENDIENTE CONCRETO (proxima vuelta, es lo primero): **re-medir la lane opt-in** (30 min de reloj) con los fixes de photo_service ya aplicados -> el numero final de rojos/timeouts y el total. La corrida anterior (m112_delta6.txt) se lanzo ANTES de los fixes, asi que su lista de rojos esta desactualizada. Como lanzar: `python` con `env['M112_INCLUIR_MODULOS']='1'` (la env NO se propaga con `set` de cmd: usarla via `env=` de subprocess) -> `game/isla-ancestral/tests/run_tests.gd`.

SIGUIENTE FRENTE (elegir): (a) el re-muestreo de arriba; (b) QA externo de otra tanda cerrada; (c) seguir con M17 [M]/[C] headless-verificables o con mi cola de 8 modulos (685 pendientes).

ESTADO DE MODULOS: M61 118/148 (cerrado, Logs 2068/2071/2073) · M112 221/225 (P1 sellado) · M17 94/175 (P3 sellado en 3 tandas). Cola propia: 685 pendientes en 8 modulos + M112 + M17.
```
