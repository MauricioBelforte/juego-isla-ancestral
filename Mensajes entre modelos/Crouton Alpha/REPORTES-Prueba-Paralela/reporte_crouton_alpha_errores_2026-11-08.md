# Reporte — Manejo de errores en Isla Ancestral (GDScript)

**Modelo:** Crouton Alpha
**Plataforma:** Kilo Code
**Fecha:** 2026-11-08
**Alcance:** `game/isla-ancestral/scripts/` — 1.260 archivos `.gd`

## 1. Resumen ejecutivo y métricas

| Patrón | Conteo | Archivo ejemplo |
|--------|--------|-----------------|
| `push_error(` | 123 | `historia/story_manager.gd:84`, `saving/save_writer.gd:65`, `core/bootstrap.gd:167,201` |
| `push_warning(` | 308 | `audio/sfx_manager.gd:86,94,103`, `clima/weather_service.gd:58` |
| `printerr(` | 34 | `saving/save_writer.gd:191,200,207,213,219`, `dialogos/test_*.gd` |
| `assert(false, …)` | 3 | `saving/save_provider.gd:23,29,34` |
| `try/catch` real | 0 | `inventario/inventario_iter4.gd:189` — “Godot 4 no tiene try/catch real; usamos push_error y log” |

Cobertura defensiva: 540 archivos usan `get_node_or_null` (null-check), 124 usan `FileAccess.open` (verifican `== null` en su mayoría), 211 usan `JSON.parse_*`.

Patrón dominante: **fail-soft con aviso en consola** — el juego nunca aborta por un módulo roto; registra `push_warning`/`push_error` y continúa con defaults/placeholders. Consecuencia: robustez alta, pero errores graves pueden quedar invisibles para el jugador.

## 2. (1) ¿Cómo se gestionan los errores?

### 2.1 Capa central: `Registro`
`core/registro.gd:25-38` envuelve `push_warning`/`push_error` con contadores (`errores`, `avisos`) para que los tests detecten fallos sin abortar:

```gdscript
static func error(modulo, mensaje): errores += 1; push_error("[%s] %s" % [modulo, mensaje])
static func verificar(cond, modulo, mensaje): if not cond: error(...)
```

### 2.2 Logging estructurado: `Logger` (M103)
`logging/logger.gd:148-210` — niveles DEBUG/INFO/WARNING/ERROR/CRITICAL, categorías, rotación por tamaño, JSON opcional, sanitización de datos sensibles. En `logger.gd:146`:

```gdscript
if _file == null:
    push_warning("Logger: no se pudo abrir archivo de log %s" % _log_path)
```

Si el log no abre, el juego sigue **sin persistencia de logs** y solo lo sabe quien lee la consola.

### 2.3 Crash reporting: `CrashReporter` (M122)
`crash/crash_reporter.gd:36-55` — `reportar_crash(tipo, mensaje, stack)` escribe `user://crash/crash_*.json`. En `:49`:

```gdscript
push_error("[M122] No se pudo escribir crash dump")
```

Pero es **manual**: nadie le conecta signal de crash del motor/sistema en el código revisado; hay que llamar `reportar_crash()` explícitamente. El envío es stub aludido en `:59-68` (`print("[M122] Dump enviado …")`, comentario “en producción, subir a Crashlytics/Sentry”).

### 2.4 Guardado (el mejor tratado): `SaveManager` / `SaveWriter`
- `saving/save_manager.gd:139` — `push_warning` si cierra durante escritura en curso (omite guardado de cierre).
- `saving/save_manager.gd:149` — `push_error("[SAVE] Guardado de cierre FALLÓ slot %d")`.
- `saving/save_manager.gd:237` — `push_warning` si `SaveBackup.rotate()` falla, pero **escribe igual** (deliberado: “perder el save es peor que un backup desactualizado”).
- `saving/save_manager.gd:246` — `push_error("[SAVE] Error guardando slot %d (%s)")` + `emit_signal("save_failed", …)`.
- `saving/save_snapshot.gd:60` — `push_error("[SAVE] Proveedor '%s' no devolvió Dictionary … sección omitida, el resto se guarda")`.
- `datos/writer_atomico.gd:41,46,52,59,63` — cadena completa de errores de escritura atómica (abrir, escribir, verificar, rename, restaurar `.bak`).

### 2.5 Servicios: `ServiceRegistry` / `Bootstrap`
- `core/service_registry.gd:24` — `push_warning("[M40] DOM-INF-REGISTRO: contrato duplicado '%s' — segundo registro rechazado")`, contador `_duplicados_rechazados`.
- `core/service_registry.gd:37` — `push_warning("[M40] DOM-INF-ACCESO-TEMPRANO: consulta de '%s' antes de registrarse")` (una sola vez por contrato para no spamear).
- `core/bootstrap.gd:167` — `push_error("Bootstrap: servicios obligatorios faltantes: %s")`.
- `core/bootstrap.gd:201` — `push_error("Bootstrap: escena principal no encontrada: %s")` y `return` (no carga escena → “pantalla negra silenciosa” si no se lee consola).
- `core/bootstrap.gd:151` — solo `push_warning("Bootstrap: EventBus no encontrado como autoload")`.

### 2.6 Config/datos JSON: patrón repetido
La inmensa mayoría de módulos repite el molde “archivo ausente/inválido → warning + defaults”:

- `balance/balance_service.gd:53,57` — `push_warning("[M93] No se pudo abrir balance: " + nombre)` / `JSON invalido`.
- `audio/music_director.gd:29` — `push_warning("[M41] music_context_matrix.json no encontrado")`.
- `audio/sfx_manager.gd:86,94,103` — `sfx_surfaces/tones/catalog.json no encontrado`.
- `clima/weather_service.gd:48` — `push_error("[Weather] clima_config.tres inválido o ausente; SOLEADO permanente")`; `:58` `push_warning("[Weather] GameTime no encontrado; clima estático")`.
- `world/day_night_cycle.gd:89,91,93,95,121,131,135,143,147` — 9 warnings en cadena y sigue con fallbacks (“niebla con base fija”, “modulación neutra (1.0)”).
- `localization/localization_manager.gd:198` — `push_warning("[M87] Clave sin traducción: " + clave)` (documentado en `:192-198` como coste ~16 ms con backtrace en ruta caliente; tiene deduplicación en `:23`).
- `animacion/animation_service.gd:118,125` — `push_warning("[M48] ANIM-MISSING: actor '%s' sin AnimationPlayer")`.

### 2.7 Validación temprana (moodle `.tres`/JSON)
`historia/story_manager.gd:46,54,58,74,77,84` — 7 `push_error` de validación de grafo (“nodo apunta a siguiente inexistente”, “retroceso de capítulo”, “falta el nodo 'prologo'”, “final in-alcanzable”, “finales en grafo (%d) != declarados (%d)”, “historia_principal.json inválido; grafo vacío”). Es validación de contenido, no de runtime: comunica el problema pero deja el grafo vacío sin UI. Mismo patrón en `dialogos/dialogue_manager.gd:134,174,176` con `[VAL-DGV]`/`[VAL-DGT]`.

### 2.8 Asserts (solo contratos)
Únicos `assert(false, …)` en `saving/save_provider.gd:23,29,34` — contrato `ISaveProvider.get_save_data/restore_save_data/get_section_name`. Solo útiles en debug; en release se ignoran y devuelven `{}`/`""` silenciosamente.

## 3. (2) ¿Hay errores no capturados o silenciados?

Sí, varios casos donde el juego sigue sin que nadie (jugador ni telemetría) se entere:

1. **Logger sin archivo** (`logging/logger.gd:146`): si `FileAccess.open` falla, solo `push_warning`. De ahí en adelante **cero persistencia** de logs; el fallo queda solo en stdout del editor, invisible en release.
2. **Integridad de dominios degradada a `print`** (`core/bootstrap.gd:181`): `print("[Bootstrap] DOM-INF-FALTANTE …")` — ni siquiera `push_warning`. Builds parciales pasan desapercibidos.
3. **GameFlowManager ausente** (`core/bootstrap.gd:93,105,115`): tres `print` (“no montado”, “enum sin MUNDO”, “MUNDO no aplicado”) sin `push_error`. El juego arranca sin flujo sincronizado.
4. **CrashReporter sin hook real** (`crash/crash_reporter.gd:36-55`): el código nunca escucha un crash del motor; si el sistema falla por acceso inválido, no hay dump. Y si falla el propio `FileAccess.open` del dump (`:49`), el error de perdida del reporte es solo `push_error`.
5. **Señal `save_failed` sin consumidor confirmado** (`saving/save_manager.gd:16,245-246`): se emite y se hace `push_error`, pero en los archivos revisados no hay UI que lo muestre; el jugador pierde progreso sin aviso (mismo patrón en `saving/save_writer.gd:65` cap de documento y `:191-219` `printerr` de escritura).
6. **Fallos de datos degradados en silencio**: `economia/economy_price_catalog.gd:34` (“sin overrides, precios base de ItemData”), `inventario/inventario_service.gd:420,423,427` (secciones inválidas “ignorada”), `inventario/inventario_contenedor.gd:133,136,143` (ítems/cantidades ignoradas/acotadas). Correcto como fail-soft, pero cantidades recortadas o secciones perdidas no generan ningún evento a UI.
7. **Duplicidad `printerr` vs `push_error`** (`saving/save_writer.gd:191,200,207,213,219` vs `datos/writer_atomico.gd:41-63`): el mismo fallo se reporta por dos canales distintos en dos capas; no hay consolidación ni conteo.
8. **Sin `try/catch`** — GDScript no tiene excepciones reales (reconocido en `inventario/inventario_iter4.gd:189`). Errores de runtime (acceso a índice inexistente, llamada a método de nodo nulo) abortan la función sin pasar por ningún `push_error`.

## 4. (3) ¿Hay funciones críticas sin manejo de excepciones?

GDScript no admite `try/catch`, así que “sin manejo” significa: función crítica que confía ciegamente en precondiciones sin validar.

1. **`SaveManager._notification` / `_process_queue`** (`saving/save_manager.gd:129-149,211-249`): maneja bien error de escritura/rotación, pero `_payload_para_slot` llama `snapshot.collect()` sin cota de tamaño; `SaveWriter.write_atomic` evita por cap (`save_writer.gd:65`), sin embargo si `collect()` devuelve estructura mutli-GB el bucle gasta memoria antes de llegar al cap.
2. **`Bootstrap._load_main_scene`** (`core/bootstrap.gd:187-211`): si `ResourceLoader.exists` pasa pero `change_scene_to_file()` falla (p. ej. escena corrupta), no hay comprobación de retorno; el error solo sale en consola del motor.
3. **`ServiceRegistry.get_service`** (`core/service_registry.gd:33-38`): devuelve `null` silenciosamente tras el primer warning; decenas de consumidores hacen `if svc == null: return` y degradan funcionalidad sin telemetría (`farm/farm_service.gd:53,72`, `crafting/crafting_service.gd:89` — “EventBus/BalanceService no disponible; … desactivado”).
4. **`ISaveProvider` (`saving/save_provider.gd`)**: `restore_save_data` acepta cualquier `Dictionary` sin esquema; los consumidores validan ad-hoc (`eventos/event_manager.gd:763,768` — “save corrupto: 'eventos' no es diccionario, se descarta”, con `push_warning` pero descartando todo el progreso del subsistema).
5. **`Logger._log`** (`logging/logger.gd:207-210`): asume que `_file.store_line` nunca falla tras la apertura; si el disco se llena a mitad de sesión, las líneas se pierden sin nuevo aviso (solo se avisó al abrir).
6. **Escenas/recursos cargados con `load()` directo**: `world/validate_lighting_m49.gd:39` valida `PackedScene` nulo (bien), pero `localization/localization_manager.gd:281` y `mineria/mining_vein_catalog.gd:29-37` se limitan a abrir JSON sin validar estructura interna completa.

## 5. (4) ¿Hay push_warning sin acción posterior?

Sí — es el patrón mayoritario (308 casos). La mayoría son “config ausente → defaults + warning”, sin retry, sin evento a UI, y sin reintento posterior. Muestra representativa:

- `dev/dev_tools.gd:26` — `dev_tools.json no encontrado`.
- `debug/debug_menu.gd:80` — `debug_menu_config.json no encontrado`.
- `backup/backup_manager.gd:27,35,89,100,200` — políticas/categorías/orígenes ausentes (5 warnings, todos sin centro de corrección).
- `audio/narrative_sound.gd:50,75,104,108,138,205` — EventBus ausente, JSON ausente, leitmotif/momento no encontrados (6 casos).
- `fauna/tortuga_npc.gd:85,90` / `fauna/gaviota_npc.gd:119,123` / `fauna/jabali_npc.gd:88,92` / `fauna/cangrejo_npc.gd:64,68` — GLB no encontrado o `load()` null; Tortuga crea placeholder, los otros “sin modelo” y dejan un NPC invisible (nunca se reintenta).
- `ia_npc/plan_stack.gd:40` — profundidad máxima, descarta el plan más viejo (una sola línea, sin evento).
- `animales_ia/m65_animal_ai.gd:72` — presupuesto máximo alcanzado, ignora instancia (funciona, pero sin backpressure visible).
- `main_island.gd:374` — `Chunk del spawn no materializó tras 60s — liberando física igualmente` (decisión tomada, sin reintento ni log persistente).
- `enchantment/incense_spawner.gd:90` / `enchantment/shaman_npc.gd:47` — timeouts de terreno con warning y fallback estático (jugador ve spawns en el sitio equivocado sin saberlo).
- `viajes/travel_service.gd:316,325` — viaje largo sin MemoryMonitor, drift fuera de límite; solo warnings.
- `eventos/recompensa_def.gd:98,109,118` — recompensas AMISTAD/PROGRESO/COLECCION sin destino (tres interfaces ausentes, se pierde la recompensa en silencio).

En casi todos el aviso es terminal: el código continúa y nunca vuelve a intentar ni marca el sistema como “degradado” para la UI.

## 6. (5) Dos mejoras sugeridas

### Mejora 1 — Puente `push_error/warning` → `Logger` + `CrashReporter` + evento de telemetría (coste bajo, impacto alto)
Centralizar: `Registro.error/aviso` (`core/registro.gd:25-32`) ya cuenta; falta que también haga `GameLogger.error/warning` (con categoría) y, para errores, `CrashReporter.reportar_crash` (con backtrace vía `get_stack()`). Añadir una señal `error_reportado(severidad, modulo, mensaje)` en EventBus para que la UI pueda mostrar un banner no bloqueante (“falló X, se cargó modo degradado”). Eso elimina los casos 1-4 de la sección 3 (Logger sin archivo, bootstrap con `print`, crash sin hook, `save_failed` huérfano) sin tocar 431 sitios: se reemplaza el cuerpo de `Registro` una vez.

### Mejora 2 — Auditoría de integridade al arrancar + reintento de assets (coste medio, cierra la “silenciosidad”)
a) Convertir los `print` de `core/bootstrap.gd:93,105,115,181` en `push_warning`/`push_error` reales y emitir un `bootstrap_integrity_report` (faltantes, duplicados de `ServiceRegistry`, contratos tempranos) que `CrashReporter` persista como primer dump de sesión.
b) Para `push_warning` de catálogos/GLB (`fauna/*_npc.gd`, `audio/*`, `balance_service.gd`), agruparlos por módulo con contador y, tras N reintentos con backoff (p. ej. 3), marcar el módulo como `degradado` en `ServiceRegistry` y publicar un evento para HUD (“audio desactivado: falta sfx_catalog.json”). La deduplicación ya existe en `localization/localization_manager.gd:23` y en `service_registry.gd:13`; extenderla al resto cuesta una función helper en `Registro`.

## 7. Conclusión final

El proyecto gestiona errores con un paradigma **cozy fail-soft**: ningún `push_error` aborta, todo hay múltiples warnings con fallbacks, y dos piezas centrales (`Registro` + `Logger`) existen pero están parcialmente conectadas. Resiliencia alta, visibilidad baja: 431 avisos en consola de desarrollo, 0 canales visibles para el jugador y varios caminos donde un error (log no persistido, bootstrap parcial, dump de crash no generado, recompensa sin destino) se pierde en silencio.

Las dos mejoras propuestas (puente centralizado de errores → logger/telemetría/UI y auditoría de arranque con reintento/degradación visible) requieren tocar pocos archivos (`core/registro.gd`, `core/bootstrap.gd`, `logging/logger.gd` y un helper de agrupación de warnings) y elevarían la trazabilidad del 100 % de los `push_error` sin cambiar el carácter fail-soft del juego.

---
*Teams: análisis estático sobre 1.260 archivos `.gd` (conteo por grep). No ejecuté el juego ni cargué escenas en runtime; las afirmaciones “silenciado” se basan en ausencia de señales/UI verificable en el código revisado.*
