# Log 1483: Barrido de suites muertas - pasada completa de inventario (335 suites)

**Fecha:** 2026-10-08
**Hora:** 19:05
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Tipo:** Auditoria / barrido (encargo del director, mensaje 93 seccion 6)
**Alcance:** TODAS las suites del repo: `tests/**/*.gd` (menos `helpers/` y `Obsoletos/`)
y `scripts/**/test_*.gd`. Binario: Godot 4.7.2-stable headless (`--script`).

## 1. Encargo

El director (msg 93 sec.6) pidio correr TODAS las suites del repo con Godot 4.7.2 headless,
una por una, y clasificar: OK / NO CARGA-NO CORRE / FALSO VERDE / MUERTA. Orden: inventario
completo primero (tabla suite -> estado -> dueno del SUT), despues fixes agrupados.
Sin tocar `quality.yml`. Log propio por entrega.

## 2. Metodologia (medido, no estimado)

- Inventario: recorrido de `tests/` y `scripts/**/test_*.gd` -> **335** rutas unicas.
- Cada suite se corrio como **subproceso independiente**:
  `Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral --script res://<ruta>`
  con timeout de 120 s. Salida cruda guardada en `.workbuddy-ai/tmp/barrido_suites/out/<suite>.out`.
- Clasificacion por lectura de la SALIDA CRUDA + el codigo de salida REAL del proceso
  (`subprocess.returncode`), NO por el texto. Se distinguen:
  * resumen con **conteo de checks** y de fallos (evidencia fuerte) -> OK si fallos=0;
  * resumen con solo `0 fallo(s)` **sin conteo** -> SIN-EVIDENCIA (no se puede distinguir
    'todo paso' de 'no corrio nada');
  * `SCRIPT ERROR` durante la corrida -> marca de falso-verde / camino no ejercitado;
  * `TIMEOUT` o WATCHDOG propio -> CUELGA.
- Dueno del SUT: `modulo_agente_map.txt` (PISTA con drift off-by-one conocido, trampa 116).
  Se marca como pista, no como prueba.

## 3. Resultado: 335 suites, 9 clases

| Clase | N |
|---|---|
| CUELGA | 1 |
| CUELGA-WATCHDOG | 2 |
| GDUNIT4/NO-EJEC | 10 |
| ROJA | 7 |
| FALSO-VERDE-CON-ERRORES | 4 |
| SIN-EVIDENCIA-SIN-CONTADOR | 96 |
| OK+SCRIPTERR | 11 |
| OK | 204 |
| **TOTAL** | **335** |

Glosario de clases:

- **OK (204):** corre, reporta `N checks, M fallos` con N>0 y M=0, sin `SCRIPT ERROR`.
- **OK+SCRIPTERR (11):** reporta `N checks / 0 fallos` PERO emite >=1 `SCRIPT ERROR` en la
  corrida (camino no ejercitado). Es un falso-verde potencial: el error no incrementa fallos.
- **SIN-EVIDENCIA-SIN-CONTADOR (96):** imprime `=== TEST Mxx: 0 fallo(s) ===` SIN conteo de
  checks y sin contador `_checks` en el fuente. No distingue 'paso todo' de 'no corrio nada'.
  Es la familia latente de BUG-100 (verde sin evidencia).
- **FALSO-VERDE-CON-ERRORES (4):** `0 fallos` + `SCRIPT ERROR` real -> patron BUG-100 consumado.
- **ROJA (7):** `rc=1` con fallos explicitos (la suite SI discrimina).
- **GDUNIT4/NO-EJEC (10):** 4 suites `GdUnitTestSuite` reales (no corren con `--script`)
  + 6 archivos mal nombrados `test_*` que NO extienden SceneTree (2 son HELPERS de test).
- **CUELGA (1):** no termina en 120 s.
- **CUELGA-WATCHDOG (2):** el WATCHDOG propio de la suite la aborta a los 60 s (`rc=1`, sin resumen).

## 4. Evidencia clave

### 4.1 FALSO VERDE consumado (4) - `0 fallos` con `SCRIPT ERROR` real

- `test_collectible_category.gd` (M73) - screrr, fall=0
- `test_logros.gd` (M72) - screrr, fall=0
- `test_nivel_herramienta.gd` (M13) - screrr, fall=0
- `test_viajes.gd` (M28) - screrr, fall=0

### 4.2 Falso verde ESTRUCTURAL probado (SUT inexistente) - `test_ambient_m42.gd`, `test_musica_m41.gd`

Ambas reportan `0 fallos` y salen EXIT 0, pero llaman METODOS Y PROPIEDADES QUE NO EXISTEN en
su SUT (`ambient_director.gd` / `music_director.gd`): `set_ducking`, `esta_pausado`, `play_flow`,
`set_leitmotif`, propiedad `sting_reproducido`. Un `SCRIPT ERROR` de runtime aborta la funcion
en silencio -> los checks que no corren NO fallan. (Mismo patron que el caso M62/trampa 85.)

### 4.3 SIN-EVIDENCIA-SIN-CONTADOR (96) - el mayor hueco

Imprimen un resumen tipo `=== TEST M93 BALANCE: 0 fallo(s) ===` SIN el numero de checks.
Un aborto por `SCRIPT ERROR` (que salta checks) daria exactamente el mismo `0 fallo(s)` + EXIT 0.
Son candidatas directas a la receta de 3 capas (contador + piso CHECKS_MINIMOS medido +
`call_deferred` del resumen). No las clasifico como muertas: no hay evidencia de que lo esten,
pero tampoco de lo contrario.

### 4.4 Falsos positivos del barrido (descartados, NO son problemas)

- `test_m66_handler.gd` y `test_m66_inv_ruta.gd` (M66): son **HELPERS de test** (comentario
  'test helper, agnes-3-flash 2026-10-08'), no suites. Mal nombrados con prefijo `test_`.
  `test_m66_handler.gd` = `class_name M66HandlerRegistro extends IRecoverable`;
  `test_m66_inv_ruta.gd` = `class_name M66InvRuta extends InvariantBase`.
- `test_validador_autoloads.gd`: su `Parse Error` es **intencional** (crea un `.gd` roto a
  proposito para probar el validador). Su resumen real es `21 checks / 0 fallos` -> cuenta como OK.

## 5. Causa raiz de las 2 CUELGA-WATCHDOG (probada por sonda)

`test_npc_visual_database.gd` (M161) y `test_equipment_manager.gd` (M155) cuelgan en el bloque A
(`..._ready`) y el WATCHDOG las aborta a los 60 s (rc=1, sin resumen). Ambas son **mi** output de
la conversion gdUnit4 -> headless (`convertir.py`, sub-frente BUG-093). Patron comun en todos los
bloques:

```gdscript
var db = DB_SCRIPT.new()
root.add_child(db)
await db.ready            # <-- CUELGA
```

**Sonda aislada medida** (Node vacio, 8 s de watchdog): tras `add_child(n)`,
`n.is_node_ready()` es **true** de inmediato; `await n.ready` **NO resuelve** (TIMEOUT).
Causa: `add_child` propaga `ready` de forma SINCRONA, asi que el `await` posterior espera una
re-emision que nunca llega. Confirmado que las **5** suites del repo que usan este patron estan
todas rotas (2 CUELGA-WATCHDOG + 3 gdUnit4 con TIMEOUT). Fix esperado: quitar el `await`
(el nodo YA esta listo) + fijar `CHECKS_MINIMOS` al conteo real medido (hoy esta en 0 = sin piso).

## 6. Delegacion (dueno del SUT = pista del mapa)

Las suites problematicas cuyo SUT NO es de M103/M105/M122/M62 se delegan a su dueno.
El mapa tiene drift off-by-one (trampa 116): verificar antes de tocar.

### 6.1 ROJA (7) - la suite discrimina; falta el fix del SUT/expectativa

- `test_pergaminos_tienda.gd` (M39) - dueno pista: glm-5.3-flash
- `test_monetizacion.gd` (M95) - dueno pista: deepseek-v4-flash-vision-exp
- `test_memoria_agenda.gd` (M19) - dueno pista: -
- `test_equipment_m155.gd` (M155) - dueno pista: -
- `test_tiendas.gd` (M39) - dueno pista: glm-5.3-flash
- `test_tiendas_iter_glm.gd` (M39) - dueno pista: glm-5.3-flash
- `test_generacion_m10_atria.gd` (M10) - dueno pista: -

### 6.2 FALSO-VERDE-CON-ERRORES (4)

- `test_collectible_category.gd` (M73) - dueno pista: agnes-2.5-flash
- `test_logros.gd` (M72) - dueno pista: -
- `test_nivel_herramienta.gd` (M13) - dueno pista: -
- `test_viajes.gd` (M28) - dueno pista: GLM-5.3 Flash

### 6.3 CUELGA / CUELGA-WATCHDOG / GDUNIT4 (13)

- [CUELGA] `test_event_manager_headless.gd` (M74) - dueno pista: -
- [CUELGA-WATCHDOG] `test_npc_visual_database.gd` (M161) - dueno pista: Hy4
- [CUELGA-WATCHDOG] `test_equipment_manager.gd` (M155) - dueno pista: -
- [GDUNIT4/NO-EJEC] `test_m66_handler.gd` (M66) - dueno pista: -
- [GDUNIT4/NO-EJEC] `test_m66_inv_ruta.gd` (M66) - dueno pista: -
- [GDUNIT4/NO-EJEC] `test_mock_interactable.gd` (M70) - dueno pista: minimax-m3-free
- [GDUNIT4/NO-EJEC] `test_anillo_arena.gd` (M-) - dueno pista: -
- [GDUNIT4/NO-EJEC] `test_arquitectura.gd` (M-) - dueno pista: -
- [GDUNIT4/NO-EJEC] `test_terrain.gd` (M-) - dueno pista: -
- [GDUNIT4/NO-EJEC] `test_debug_menu.gd` (M110) - dueno pista: -
- [GDUNIT4/NO-EJEC] `test_photo_service.gd` (M56) - dueno pista: Hy4
- [GDUNIT4/NO-EJEC] `test_inventory_slot.gd` (M14) - dueno pista: -
- [GDUNIT4/NO-EJEC] `test_equipment_layer.gd` (M155) - dueno pista: -

## 7. Dominio propio (M103/M105/M122/M62) - sin fixes pendientes

Las suites de mis modulos ya tienen las 3 capas (contador + piso medido + resumen diferido):
`scripts/logging/test_*.gd` (M103), `scripts/telemetry/test_*.gd` (M105),
`scripts/crash/test_*.gd` (M122), `scripts/rendimiento/memoria/test_*.gd` (M62).
Unica observacion: `test_enforcement_m62.gd` conserva 1 `_check(true)` (asercion infalsable)
heredada; se reporta, no bloquea.

## 8. Pendiente / siguiente entrega

- Fix de las 2 CUELGA-WATCHDOG (mi output): quitar el `await X.ready` + piso medido. Log propio.
- Barrido de pisos para las 96 SIN-EVIDENCIA (agrupado por dueno; requiere autorizacion).
- Las 7 ROJA: delegar el fix del SUT/expectativa a su dueno.

## 9. Artefactos

- Inventario crudo: `.workbuddy-ai/tmp/barrido_suites/resultado.json` (335 registros, salida cruda).
- Clasificacion: `clasificado.json` / `final.json` + `clasif.txt`.
- Tabla completa (suite -> clase -> modulo -> dueno): `tabla.md`.
- Salida cruda por suite: `out/<suite>.out`.

## 10. Notas de numeracion

`reservar_log.py --estado` reporta 2 COLISIONES ajenas conocidas: 1290 (M112+TH2) y 1468
(M17 + push-catchup). El director ya las reconocio (msg 93 sec.5). **No se tocan.**
