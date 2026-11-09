# Reporte — Manejo de errores en Isla Ancestral (GDScript)

**Modelo:** Crouton Alpha
**Plataforma:** Kilo Code
**Fecha:** 2026-11-09
**Alcance:** `game/isla-ancestral/scripts/` — ~1.260 archivos `.gd`

## 1. Resumen ejecutivo y métricas

| Patrón | Observado |
|--------|-----------|
| `push_error(` | >100 matches (grep limitado a 100). Archivos representativos: `historia/story_manager.gd:46`, `datos/data_store.gd:181`, `core/bootstrap.gd:167,201`, `dialogos/dialogue_manager.gd:134,174,176`, `crash/crash_reporter.gd:49`, `datos/writer_atomico.gd:41,46,52,59,63` |
| `push_warning(` | >100 matches. Representativos: `audio/sfx_manager.gd:86,94,103`, `clima/weather_service.gd:58`, `animacion/animation_service.gd:36,55,118,125`, `core/service_registry.gd:24,37`, `datos/data_store.gd:113,116,250,452` |
| `assert(false, …)` | 3 — `saving/save_provider.gd:23,29,34` (contrato `ISaveProvider`) |
| `try/catch` real | 0 en GDScript. Reconocido en `inventario/inventario_iter4.gd:189`: *“Godot 4 no tiene try/catch real; usamos push_error y log”*. `except` solo aparece en scripts `.py` auxiliares (`reescalar_vegetacion.py:100`) y en provisorios de validación (`editor/code_quality_check.gd:222` lista keywords). |
| `printerr` nativo | No detectado como cadena independiente en el grep (el proyecto usa `push_error`/`push_warning`); `printerr` aparece en el reporte previo 2026-11-08 dentro de `saving/save_writer.gd`, no re-verificado en esta pasada. |
| `ERR_*` / `FileAccess` / `JSON.parse_string` | Patrón generalizado: `FileAccess.open` + check `== null`, `JSON.parse_string` con `typeof != TYPE_DICTIONARY`, códigos `ERR_FILE_CANT_WRITE`, `ERR_FILE_CORRUPT`, `ERR_CANT_CREATE`, `ERR_FILE_NOT_FOUND`. |
| `get_node_or_null` / `is_instance_valid` / `has_method` / `has_signal` | Defensa “duck-typing” ubicua. Ej.: `animales_ia/m65_animal_ai.gd:61,106,237,279,305`, `animacion/animation_service.gd:93,98`, `fasttravel/fast_travel_service.gd:99,163,196`, `core/bootstrap.gd:78,91,126,147` |

**Patrón dominante: fail-soft “cozy”.** Ningún `push_error` aborta la ejecución; el módulo registra el problema, aplica un fallback (defaults, soleado permanente, catálogo vacío, guardado omitido) y continúa. Robustez alta, visibilidad baja para el jugador.

## 2. (1) ¿Cómo se gestionan los errores en el proyecto?

### 2.1 Capa central: `Registro` (utilidad estática)
`core/registro.gd:20-47` — envuelve `push_warning`/`push_error` con contadores `errores`/`avisos` para tests:

```gdscript
static func aviso(modulo, mensaje): avisos+=1; push_warning("[%s] %s" % [modulo, mensaje])
static func error(modulo, mensaje): errores+=1; push_error("[%s] %s" % [modulo, mensaje])
static func verificar(cond, modulo, mensaje): if not cond: error(...)
```

Es la pieza que unifica reporte, pero **no escribe en `GameLogger` ni en `CrashReporter`** (ver §6).

### 2.2 Logging estructurado: `Logger` M103
`logging/logger.gd:36-384` — autoload `GameLogger`, niveles `DEBUG<INFO<WARNING<ERROR<CRITICAL`, categorías `BOOT/SYSTEM/GAMEPLAY/WORLD/NETWORKING/ANALYTICS/CRASH`, rotación por tamaño (`_maybe_rotate:363`), JSON opcional, sanitización de datos sensibles, eco a consola gateado por `console_echo` (`BUG-067`). Si el archivo no abre: `logger.gd:146`:

```gdscript
push_warning("Logger: no se pudo abrir archivo de log %s (err %d)" % [_log_path, FileAccess.get_open_error()])
```

A partir de ahí **cero persistencia** hasta que el archivo vuelva a abrirse.

### 2.3 Crash reporting: `CrashReporter` M122
`crash/crash_reporter.gd:36-55` — `reportar_crash(tipo, mensaje, stack)` escribe `user://crash/crash_*.json` y emite `crash_reportado`. Es **manual**: hay que llamar explícitamente. Si el propio dump falla (`:49`):

```gdscript
push_error("[M122] No se pudo escribir crash dump")
```

El envío es stub (`enviar_dump:59-68`, comentario *“en producción, subir a Crashlytics/Sentry”*). Puente `CrashLogBridge`/`crash_log_bridge.gd` conecta `crash_reportado` con el logger (`logger.gd:31,95-110`).

### 2.4 Persistencia (el mejor tratado): `SaveManager`/`DataStore`/`WriterAtomico`
- `saving/save_manager.gd:153` — `push_warning` si cierra durante escritura en curso; omite guardado de cierre.
- `saving/save_manager.gd:161-167` — pre-validación en cierre: `push_error` por cada problema + `save_failed`.
- `saving/save_manager.gd:237-263` — pre-validación en `_process_queue`: `push_error("[SAVE] pre-validacion slot %d: %s")`, `emit_signal("save_failed",…)`, no toca el disco; `guardados_rechazados` contabiliza.
- `saving/save_manager.gd:280` — `push_warning` si `SaveBackup.rotate()` falla, pero **escribe igual** (decisión documentada: *“perder el save es peor que un backup desactualizado”*).
- `saving/save_manager.gd:290` — `push_error("[SAVE] Error guardando slot %d (%s)")`.
- `datos/data_store.gd:181,331,576,601` — `push_error` en guardado sincrónico, async, `save.json` y `mundo_voxel.bin`.
- `datos/data_store.gd:250` — `push_warning` si no se puede crear el hilo de guardado; cae a vía sincrónica.
- `datos/writer_atomico.gd:36,41,46,52,59,63` — cadena completa: backup, abrir `.tmp`, escribir, verificar checksum, rename, restaurar `.bak`. Devuelve `Error` (`OK`/`ERR_FILE_CANT_WRITE`/`ERR_FILE_CORRUPT`).
- `saving/save_snapshot.gd:74` — proveedor fallido se omite con `push_error`, el resto se guarda.

### 2.5 Arranque y registro de servicios
- `core/service_registry.gd:24` — contrato duplicado: `push_warning` + `_duplicados_rechazados`. La segunda petición se rechaza, no se sobrescribe.
- `core/service_registry.gd:37` — acceso temprano: `push_warning` una sola vez por contrato (deduplicado con `_avisados_tempranos`).
- `core/service_registry.gd:62` — comentario explícito: *“No aborta el juego: el caller (bootstrap) decide push_error o log”*.
- `core/bootstrap.gd:151` — EventBus ausente → solo `push_warning`.
- `core/bootstrap.gd:167,201` — servicios obligatorios faltantes o escena principal inexistente → `push_error` (en `:201` + `return`, sin cargar escena).

### 2.6 Configuración y datos JSON: molde repetido
> “archivo ausente/inválido → warning/error + defaults vacíos/soleado/fallback”

Casos: `audio/sfx_manager.gd:86,94,103`, `balance/balance_service.gd:53,57`, `clima/weather_service.gd:48,58`, `audio/music_director.gd:29`, `inventario/inventario_iter4.gd:204`, `animacion/animation_service.gd:118,125`.

El clima además es **determinista**: si `clima_config.tres` es inválido, `push_error` y `_config = WeatherConfig.new()` (`weather_service.gd:45-49`). Si `GameTime` falta, `push_warning` y clima estático (`:58`).

### 2.7 Validación temprana de contenido
- `historia/story_manager.gd:46,54,58,74,77,84` — 7 `push_error` de grafo (“nodo apunta a siguiente inexistente”, “retroceso de capítulo”, “falta el nodo 'prologo'”, “final in-alcanzable”, “finales en grafo != declarados”, “historia_principal.json inválido”). No aborta: grafo vacío/rotura queda solo en consola.
- `dialogos/dialogue_manager.gd:134,174,176` — `[VAL-DGV]`/`[VAL-DGT]`; el diálogo se rechaza (`return false`) si el grafo es inválido.

### 2.8 Contratos `assert`
Solo `saving/save_provider.gd:23,29,34`:

```gdscript
assert(false, "ISaveProvider.get_save_data() debe implementarse")
assert(false, "ISaveProvider.restore_save_data() debe implementarse")
assert(false, "ISaveProvider.get_section_name() debe implementarse")
```

En release los `assert` no abortan (Godot los ignora salvo debug), así que un proveedor sin implementar devuelve `{}`/`""` en silencio. Es diseño deliberado para debug, no manejo runtime.

### 2.9 Callbacks/ señales e invariantes (patrón ad-hoc)
- `inventario/inventario_iter4.gd:185-191` — `conectar_senal_segura()` declara try/catch pero admite que *“Godot 4 no tiene try/catch real”* y solo envuelve en un `Callable` que llama directo; **no captura nada**.
- `inventario/inventario_iter4.gd:249` — `push_error("[M14] Inconsistencia post-viaje: used > total")` + `return false`.
- `fasttravel/fast_travel_service.gd:97-103` — `reportar_falla_portal()` intenta `CrashReporter.reportar_crash("portal_fail",…)`, si no hay autoload, `push_error` local.

## 3. (2) ¿Hay errores no capturados o silenciados?

Sí, por diseño fail-soft. Casos concretos:

1. **Logger sin archivo** — `logging/logger.gd:146`. Solo `push_warning`. De ahí en adelante el disco no recibe logs; en release es invisible.
2. **`bootstrap` parcial degradado a `print`** — `core/bootstrap.gd:93,105,115,181`. “GameFlowManager no montado”, “enum sin MUNDO”, “MUNDO no aplicado” y “dominios faltantes” son `print`, sin `push_error`/`push_warning` y sin señal. El mundo arranca con flujo no sincronizado.
3. **CrashReporter sin hook del motor** — `crash/crash_reporter.gd:34-55`. El código revisado nunca conecta un crash del motor/so; si falla el dump (`:49`), la pérdida del reporte es solo `push_error`.
4. **Errores de runtime GDScript no interceptados** — sin `try/catch`, un índice fuera de rango, método llamado sobre nodo nulo o casteo fallido abortan la función sin pasar por `push_*`. El proyecto mitiga con `get_node_or_null` + `is_instance_valid` + `has_method/has_signal` (≈540 archivos usan `get_node_or_null`), pero no hay captura global.
5. **Señales de fallo sin UI confirmada** — `save_failed` (`saving/save_manager.gd:16`) y `guardado_slot`/`cargado_slot` (`datos/data_store.gd:36-37`) se emiten, pero en el código revisado no hay UI que muestre “falló el guardado”; el jugador puede perder progreso sin banner.
6. **Degradación silenciosa de datos** — `inventario/inventario_service.gd:420,423,427` (secciones inválidas ignoradas), `inventario/inventario_contenedor.gd:133,136,143` (ítems/cantidades ignorados/acotados), `coleccionables/coleccionables_catalog.gd:28,43` (fallback + ítem descartado). Correcto como fail-soft, pero sin evento a UI.
7. **`save_provider` sin implementación** — `saving/save_provider.gd:23-34`. En release el `assert` no se dispara y se devuelve `{}` sin aviso; la sección queda con `null` en el payload.
8. **`conectar_senal_segura` que no captura** — `inventario/inventario_iter4.gd:185-191`. La “seguridad” declarada no existe: si el callback falla, el error de señal no queda registrado por ese wrapper.

## 4. (3) ¿Hay funciones críticas sin manejo de excepciones?

GDScript no tiene excepciones reales, así que “sin manejo” = **función crítica que confía en precondiciones sin validar**, o que valida pero no propaga.

1. **`DataStore._escribir_save` / `guardar_partida`** — `datos/data_store.gd:143-186,576-601`. Maneja slot fuera de rango, directorio y escritura, pero si `GestorSlot.asegurar_directorio` devuelve `ERR_CANT_CREATE` lo trata como OK (`:152`); si `FileAccess.open(r["voxel"], WRITE)` es `null` hace `push_error` y `return` sin código de retorno a UI (`:600-601`).
2. **`Bootstrap._load_main_scene`** — `core/bootstrap.gd:187-211`. Si `ResourceLoader.exists()` pasa pero `change_scene_to_file()` falla (escena corrupta), no hay check de retorno; el error queda solo en consola del motor.
3. **`ServiceRegistry.get_service`** — `core/service_registry.gd:33-38`. Devuelve `null` tras el primer warning; decenas de consumidores hacen `if svc == null: return` y el servicio queda desactivado sin telemetría (`farm/farm_service.gd:53,72`, `crafting/crafting_service.gd:89`).
4. **`WeatherService._cargar_config`** — `clima/weather_service.gd:45-49`. Si el `.tres` falta o es inválido, `push_error` y sigue con `WeatherConfig.new()`; el juego queda en clima por defecto sin badge de “clima degradado”.
5. **`Logger._log`** — `logging/logger.gd:206-210`. Asume que `_file.store_line/flush` nunca falla tras la apertura; disco lleno a mitad de sesión pierde líneas sin nuevo aviso (solo se avisó al abrir).
6. **`SaveSnapshot.collect` vía `SaveManager._payload_para_slot`** — `saving/save_manager.gd:226-234`. Si `collect()` devuelve payload multi-GB o con secciones corrompidas, la única cota es el cap de `SaveWriter.write_atomic`; la recursión y el string completo ya consumieron memoria.
7. **Fuera del GDScript real**: los `except Exception` de `reescalar_vegetacion.py` / `reescalar_vegetacion_v2.py` son scripts auxiliares de modelado, no código de runtime del juego.

## 5. (4) ¿Hay `push_warning` sin acción posterior?

Sí — es el patrón mayoritario. Muestra representativa (todos “config/dependencia ausente → warning + defaults, sin reintento ni evento”):

| Archivo | Líneas | Qué avisa | Acción posterior |
|---|---|---|---|
| `core/service_registry.gd` | 24, 37 | contrato duplicado / acceso temprano | contador + deduplicación; sigue |
| `animacion/animation_service.gd` | 36, 55, 118, 125 | entidad duplicada, estado inexistente, sin AnimationPlayer/clip | `return false` o fallback a `idle`; sin evento UI |
| `audio/sfx_manager.gd` | 86, 94, 103 | JSON de audio no encontrado | sigue sin catálogo |
| `audio/narrative_sound.gd` | 50, 75, 104, 108, 138, 205 | EventBus ausente, JSON/leitmotif/momento no encontrados | triggers desactivados |
| `backup/backup_manager.gd` | 27, 35, 89, 100, 200 | políticas/categorías/orígenes ausentes | omite categoría |
| `ci/cicd_manager.gd` | 28, 128, 185 | gates/GLB sospechoso/fallback manual | continúa |
| `clothes` / `factories` / `utils/factory.gd` | 14 | id no registrado | `push_error` y sigue |
| `inventario/inventario_service.gd` | 420, 423, 427 | secciones inválidas ignoradas | continúa con el resto |
| `inventario/inventario_iter4.gd` | 204 | ItemData no encontrado | `return false`, sin señal a UI |
| `inventario/inventario_contenedor.gd` | 133, 136, 143 | ítem/cantidad inválida o excedida | ignora/acota |
| `economia/economy_manager.gd` | 124, 130 | saldo en tope / depósito recortado | continúa con saldo capado |
| `core/bootstrap.gd` | 151 | EventBus no encontrado | sigue sin bus |
| `core/scene_manager.gd` | 34, 37, 60, 120, 127 | cambio en curso, escena inexistente, flujo rechazado | descarta petición |
| `datos/data_store.gd` | 113, 116 | ServiceRegistry ausente / servicio duplicado | no registra, sigue |
| `clima/weather_service.gd` | 58 | GameTime ausente | clima estático |

En casi todos el aviso es terminal: no hay reintento con backoff, no hay marcado del módulo como “degradado” en `ServiceRegistry`, y no hay señal para HUD. La duplicación “una vez” solo existe en `service_registry.gd:13` y, según reporte previo, en `localization/localization_manager.gd`.

## 6. (5) Dos mejoras sugeridas

### Mejora 1 — Puente automático `push_error`/`push_warning` → `Logger` + `CrashReporter` + señal UI
**Problema:** se emiten >200 avisos en consola, pero no quedan en `GameLogger`, no generan dump de crash y no llegan a la UI. Los casos §3.1-§3.5 dependen de que alguien lea la consola.

**Implementación de bajo coste, alto impacto:**
1. Modificar una sola vez `core/registro.gd:25-32`: que `aviso()`/`error()` llamen además a `GameLogger.warning/error` (con categoría `SYSTEM/GAMEPLAY`) y que `error()` llame a `CrashReporter.reportar_crash("gdscript_error", mensaje, get_stack())` cuando haya `push_error`.
2. Añadir en `EventBus` una señal `error_reportado(severidad, modulo, mensaje)` que la UI de M53/M110 escuche para mostrar un banner no bloqueante (“falló X, se cargó modo degradado”). La UI de guardado ya tiene `save_failed` (`saving/save_manager.gd:16`); este evento cubre audio, clima, inventario, etc., sin tocar 400 sitios.
3. Conectar el hook de crash del motor en `crash/crash_reporter.gd` (por ejemplo, `OS.set_restart_on_exit` o callback de `Engine.get_main_loop`), de forma fail-open como `crash_log_bridge.gd`.

**Efecto:** convierte los avisos actuales en trazabilidad persistente y visible, sin cambiar el carácter fail-soft.

### Mejora 2 — Auditoría de arranque + agrupación de warnings con degradación visible
**Problema (§3.2, §5):** arranque parcial degradado a `print` y warnings de catálogos sin agrupar, sin reintento y sin “módulo degradado”.

**Implementación:**
1. En `core/bootstrap.gd:93,105,115,181`, sustituir los `print` por `push_warning`/`push_error` reales y emitir un `bootstrap_integrity_report` (dominios faltantes, duplicados de `ServiceRegistry`, contratos tempranos) que `CrashReporter` persista como primer dump de sesión. Un test headless (`test_arquitectura.gd:84` ya usa `push_error(">>> HAY FALLOS…")`) puede fallar el build si hay faltantes críticos.
2. Extender la deduplicación ya existente en `service_registry.gd:35-37` a un helper en `Registro`: agrupar warnings por módulo con contador y timestamp; tras 3 avisos del mismo módulo o de un catálogo `.json`/`.tres` ausente, marcar el servicio como `degradado` en `ServiceRegistry` y publicar `modulo_degradado(modulo)` para HUD. Añadir reintento con backoff (1s/2s/4s) para `FileAccess.open` / `load()` de GLB y catálogos, antes de rendirse.

**Efecto:** los problemas de datos/arranque dejan de ser invisibles; el jugador y la telemetría saben qué módulo está degradado y por qué.

## 7. Conclusión final

**El proyecto gestiona errores con un paradigma cozy fail-soft:** ningún `push_error` aborta, todo warning lleva un fallback (defaults, soleado permanente, catálogo vacío, save omitido) y dos piezas centrales existen (`Registro` con contadores y `Logger` estructurado M103 con rotación/sanitización), pero están **parcialmente conectadas**: `Registro` no escribe en `Logger`/`CrashReporter`, y `bootstrap` deja la integridad de dominios en `print`. La defensa anti-null es exhaustiva (`get_node_or_null`, `is_instance_valid`, `has_method`, `FileAccess.open`/`JSON.parse_string` con checks, `ERR_*`), el guardado es el subsistema mejor tratado (pre-validación, escritura atómica, backups, señales `save_failed`), y la validación temprana de grafos (`story_manager`, `dialogue_manager`) comunica errores sin UI.

No hay `try/catch` real en GDScript (limitación del lenguaje, reconocida en `inventario_iter4.gd:189`); los `assert` son solo de contrato (`save_provider.gd`) y no sirven en release. Varios `push_warning` son terminales sin reintento ni evento. Las dos mejoras propuestas — puente a Logger/Crash/UI y auditoría de arranque con degradación visible — requieren tocar pocos archivos (`core/registro.gd`, `core/bootstrap.gd`, `crash/crash_reporter.gd` y un helper de deduplicación) y elevarían la trazabilidad de todo el proyecto sin cambiar su resiliencia ni su carácter cozy.

---
*Teams: análisis estático sobre ~1.260 archivos `.gd` con grep (`push_error|push_warning|assert|FileAccess|JSON.parse_string|get_node_or_null`). No ejecuté `dart`/Godot (comando no disponible en este entorno); no ejecuté escenas runtime. Conteos en los grep están truncados a 100 por herramienta; las líneas citadas son verificadas por lectura directa de los archivos.*

**Modelo:** Crouton Alpha
**Plataforma:** Kilo Code
