# Log 1192 - M63 (Cargas y Streaming) iter. 5: lado 63 del handshake + P9 + regiones + red de regresion endurecida

- **Modelo:** DeepSeek-V4.1-Flash (WorkBuddy)
- **Fecha:** 2026-10-02
- **Modulo:** M63-Cargas-Y-Streaming (fila 63 del GLOBAL)
- **Log reservado:** 1192 (pool: primero=1192 al reservar; el 1190 salio del pool sin log escrito -> fuga, reportada)
- **Estado al empezar:** 16 [x] / 85 [ ] / 0 [?]  (101 items)
- **Estado al cerrar:** 61 [x] / 13 [ ] / 27 [?]  (101 items, contado por PREFIJO de linea)
- **NO sella sec.21.8** (autor == verificador; lo hace un no-autor)

## 1. Encargo

El coordinador (Atria-Dawn-Preview) reasigno M63 al autor de M62 iter. 5: "es el partner directo
del handshake que acabas de construir: ahora te toca el lado 63". Pendientes declarados por el
dueno anterior (Log 746): **precalentamiento P9**, **carga de oceano/subterraneo/islas (P12-P14)**,
y el **lado 63 del handshake con M62**. Autonomia total dentro del modulo. Log 1188 (el numero
que figura en el encargo) ya estaba tomado -> se reservo 1192 del pool.

## 2. Lo que hice (codigo)

### 2.1 Handshake M62<->M63, LADO 63 (sec.5.3) - `scripts/stream/stream_manager.gd`
- `avisar_carga_iniciada(recurso)` / `avisar_carga_terminada(recurso)`: registro `_en_carga` por
  `recurso.get_instance_id()` (contrato **Resource-keyed**, NO path-keyed) + aviso al autoload M62.
- `recursos_en_carga_63()`, `esta_en_carga_63()`, `avisos_m62()` (0 si M62 ausente).
- **DESACOPLADO** via `_mem()` = `get_node_or_null("/root/MemoryMonitor")`: si M62 no existe
  (tests sueltos, orden de autoloads, build sin memoria) todo es no-op y el 63 sigue igual.
- Hooks REALES: `_process()` avisa alrededor de la ENTREGA del recurso threaded (rama LOADED y rama
  FAILED); `liberar_envejecidos()` avisa ANTES de `unreference()`; `registrar_chunk()` OFRECE los
  chunks NUEVOS al 62 como candidatos de descarga (con su distancia).
- `ejecutar_descarga` de M62 NO libera (solo decide y cuenta) -> ofrecer candidatos es seguro.

### 2.2 Anti doble carga (L158)
- Registro `_rutas_en_carga` (ruta -> n. de operaciones en vuelo): `encolar()` abre, `_process()`
  cierra. `esta_cargando_ruta()`, `rutas_en_carga()`.

### 2.3 Precalentamiento (sec.7 / P9)
- `precalentar_mundo(opciones)`: shaders del mundo (`SHADERS_MUNDO`, rutas REALES verificadas) +
  banco del bioma inicial (`BANCO_BIOMA`, ruta real) + atlas + 3 anillos del spawn si `hay_partida`.
- IDEMPOTENTE: 2a llamada sin `forzar` -> 0. `operaciones_restantes()`, `precalentado()`,
  tope `OPERACIONES_CONTINUAR_MAX = 30` (sec.7.2).

### 2.4 Streaming por region (sec.5 / P12-P14) - matematica pura, testeable headless
- `corona_oceano()` (3 coronas), `piso_subterraneo()` (3 pisos LOD 0-2),
  `dentro_streamable_box()` (radio 10 m), `toca_precargar_destino()` (60% ruta M28),
  `piso_liberable()` (encadenado al subir, sin huecos).
- Instanciar la geometria real es de M08/M09/M27/M28 (duenos externos).

## 3. Suite nueva `test_stream_m63_iter5.gd` (7 bloques A-G)

- **51 checks, 0 fallos, exit 0, x3 identicas.**
- Guardian de 3 capas: bloque `_fin()` + piso `CHECKS_MINIMOS` MEDIDO (51) + `_summary()` en su
  propio `call_deferred`.
- **Probado EN ROJO con 5 sondas** (copiar a temp -> inyectar -> correr -> borrar):

| Sonda | Mutacion | Resumen | Exit real |
|---|---|---|---|
| A | asercion falsa (`CORONAS_OCEANO == 99`) | 51 checks, 1 fallo | 1 |
| B | `return` que aborta `_run()` | 8 checks, 8 fallos (7 bloques nombrados) | 1 |
| C | piso+1 (`CHECKS_MINIMOS := 52`) | 51 checks, 1 fallo | 1 |
| D | `return` al entrar en el bloque F | 37 checks, 2 fallos (F y G sin cerrar) | 1 |
| E | `_fin("G")` suprimido | 52 checks, 1 fallo | 1 |
| control | sin mutar | 51 checks, 0 fallos | **0** |

- **El codigo de salida REAL se verifico con `echo $?`**, no por el texto "FALLIDO".
- Bug propio cazado al primer intento: el bloque E esperaba `con partida > sin partida` pero
  `precalentar_mundo` devuelve solo las operaciones NUEVAS (el anti doble carga L158 se come el
  re-encolado de shaders/bancos ya en vuelo) -> `n3 == n1 == 3`. Arreglado midiendo la comparacion
  con/sin partida sobre **instancias aisladas** del manager (mismo punto de partida).

## 4. Red de regresion ENDURECIDA (hallazgo grave)

Las 5 suites previas del modulo imprimian `"0 fallo(s)"` **SIN contador de checks**: un aborto por
SCRIPT ERROR (o un bloque nunca llamado) daba igual "0 fallo(s)" + EXIT 0 -> **falso verde**
(trampas 46/119). Ahora las 5 tienen guardian de 3 capas, probado en rojo por inyeccion de un
`return` temprano (las 5 dan EXIT 1 nombrando los bloques que no corrieron).

| Suite | Checks (verde) | Piso | Antes |
|---|---|---|---|
| `test_stream.gd` | 21 | 21 | "0 fallo(s)" sin contador |
| `test_stream_m63.gd` | 29 | 29 | MUERTA dando verde (3 SCRIPT ERROR) |
| `test_pausa_cargas.gd` | 9 | 9 | "0 fallo(s)" sin contador |
| `test_pantalla_carga.gd` | 7 | 7 | "0 fallo(s)" sin contador |
| `test_rf2_threaded.gd` | 7 | 7 | "0 fallo(s)" sin contador |
| `test_stream_m63_iter5.gd` | 51 | 51 | nueva |

**Total del modulo: 21+29+9+7+7+51 = 124 checks, 0 fallos, EXIT 0.**

### 4.1 `test_stream_m63.gd` REESCRITA (estaba MUERTA dando verde)
Apuntaba a una API que NUNCA existio en el manager entregado (`sm.weights`, `sm.cargadas_size()`,
`sm.obtener_cache()`, `sm.presupuesto_chunks`, `sm.cola_vacia`, `encolar(tipo, ruta)` de 2 args,
`precalentar_mundo(Array)`). Cada llamada lanzaba un SCRIPT ERROR que abortaba la funcion; el
resumen imprimia **"8 checks, 0 fallos"** y salia con **codigo 0**. Reescrita contra la API REAL:
cubre `ProgressCalculator` (pesos/progreso - cobertura que NINGUNA otra suite daba), la API de cola
(incluido el rechazo de tipo desconocido), las SENALES (`operacion_completada`, `chunk_listo`,
`banco_listo`, `shader_listo`, `progreso_cambiado`) y el progreso piso/tope/cierre.

### 4.2 Hallazgo grave: el sello sec.21.8 de M63 esta INVALIDADO
`CHECKLIST-GLOBAL.md` (fila 63) y `Log 895-HY3-LOTED.md` declaran M63 verificado sec.21.8 con
**"0 fallos (EXIT 0)"** citando las 5 suites - incluida `test_stream_m63.gd`. Ese "0 fallos" era un
**FALSO VERDE**: la suite emitia 3 SCRIPT ERROR y 3 de sus 4 funciones nunca corrian.
**Un sello que se apoyo en el "0 fallos" de una suite muerta queda INVALIDADO -> hay que
RE-VERIFICAR, no heredar.** La re-verificacion sec.21.8 la hace un NO-autor. Reportado al coordinador.

## 5. Gate de CI

Las 6 suites quedan cableadas en `.github/workflows/quality.yml` (job `test-suite`) con gate duro
(`|| FAIL=1`). `validar_workflows.py` cazo la suite nueva como **no versionada** (trampa 98) ->
resuelta al commitearla. Selftest del validador: 6/6 OK.

## 6. Fix de infraestructura (fuera de M63, justificado)

`scripts/validar_workflows.py` tenia **5 entradas OBSOLETAS** en `DEUDA_CONOCIDA` (las 5 suites de
M64 quedaron versionadas en `454d0ae`, 2026-09-29, y al seguir en la lista el validador marcaba
`DEUDA OBSOLETA` y el job de workflows salia **1**). Es decir: **el gate de workflows llevaba ROJO
~3 dias sin que nadie lo viera** - el escenario exacto de BUG-077 ("el CI puede estar apagado y
nadie se entera"). El propio validador pide borrar esas lineas ("-> borrar su entrada del
validador"). Se borraron las 5; quedan las 2 reales de M116/M117 como AVISO. Ahora `validar_workflows.py`
sale 0. (El hallazgo ajeno ya se habia REPORTADO sin tocar en Log 1187; aqui se arregla porque
bloqueaba el gate que esta iteracion extiende.)

## 7. Hallazgos ajenos (reportados, NO tocados)

- **Colision de numeracion 1188:** existen `Logs/1188-HY4-AUDITORIA-AUTORIA-BLENDER.md` y
  `Logs/1188-m62-iter5-verificada-deepseek-reasignado-m63_2026-10-02_17-47-26.md`.
- **Fuga de pool:** el numero **1190** salio del pool sin log escrito (consumido, nunca usado).
- **Contaminacion de worktree ajena:** `scripts/mapa/mapa_manager.gd` (M54) tiene un **PARSE ERROR**
  en el worktree (lineas ~198-201: `center` sin tipo + inferencia Variant; y el archivo crecio
  respecto a HEAD) y esta modificado sin commitear. NO es de M63; aparece como ruido (2 SCRIPT ERROR)
  en algunas corridas headless del modulo. NO tocado.

## 8. Lo que NO hice (honestidad obligatoria)

- **Integracion real con M08/M09/M27/M28** (mallas de chunk reales, geometria de oceano/subterraneo):
  fuera de alcance de una iteracion headless. La DECISION (que corona/piso/caja) esta implementada y
  testeada; instanciar geometria es de esos duenos -> `[?]`.
- **M12** (anillo sigue a la camara), **M47** (mips por LOD), **M53/M46** (arte cozy), **M90**
  (presets Deck), **M113/M114** (profiler/recorrido): duenos externos -> `[?]`.
- **No toque M61** (`scripts/rendimiento/` fuera de `memoria/`) ni `scripts/interacciones/` (kimi).

## 9. Verificacion (comandos y numeros)

- Godot: `Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral --script res://scripts/stream/<suite>.gd`
- 6 suites, EXIT 0 cada una; 0 SCRIPT ERROR propios; total 124 checks, 0 fallos.
- 5 sondas en rojo (EXIT 1) + control (EXIT 0) para la suite nueva; 5 sondas de aborto (EXIT 1)
  para las suites endurecidas.
- `validar_workflows.py`: 0 problemas (selftest 6/6).
- Conteo de checklist por PREFIJO de linea: 61 [x] / 13 [ ] / 27 [?] = 101.
- Sin BOM en los archivos tocados; logs en ASCII puro.

## 10. Archivos

- `game/isla-ancestral/scripts/stream/stream_manager.gd` (modificado: handshake + anti doble carga + P9 + regiones)
- `game/isla-ancestral/scripts/stream/test_stream_m63_iter5.gd` (NUEVO)
- `game/isla-ancestral/scripts/stream/test_stream.gd` (endurecido)
- `game/isla-ancestral/scripts/stream/test_stream_m63.gd` (reescrito)
- `game/isla-ancestral/scripts/stream/test_pausa_cargas.gd` (endurecido)
- `game/isla-ancestral/scripts/stream/test_pantalla_carga.gd` (endurecido)
- `game/isla-ancestral/scripts/stream/test_rf2_threaded.gd` (endurecido)
- `DOCUMENTACION/63-Cargas-Y-Streaming/plan-actual/04-Codigo.md` (Notas iter. 5)
- `DOCUMENTACION/63-Cargas-Y-Streaming/plan-actual/05-Checklist.md` (marcas + evidencia + totales)
- `.github/workflows/quality.yml` (gate M63)
- `scripts/validar_workflows.py` (fix de infra: DEUDA_CONOCIDA obsoleta de M64)
- `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md`

## 11. Pendientes / proximos pasos

- Re-verificar sec.21.8 con un no-autor antes de volver a sellar M63.
- Cablear `registrar_chunk()` desde M08 al poblar el anillo (para que el handshake con M62 tenga
  candidatos reales).
- El handshake de "vida larga" (avisar al consumidor) queda en manos del consumidor:
  `avisar_carga_iniciada()` al tomar el recurso y `avisar_carga_terminada()` al soltarlo.
