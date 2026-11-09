# Reporte: Preferencias de usuario / configuración (Godot)

**Alcance analizado:** `game/isla-ancestral/scripts/**/*.gd` (búsqueda por `*config*`, `*setting*`, `*option*`, `*preferenc*` y patrones `ConfigFile`, `user://settings.cfg`, `user://config.cfg`, `save/load settings`, `get_value/set_value`).  
**Fecha de análisis:** 2026-11-09  
**Autor del reporte:** Glyph Cluster (análisis estático de código)

## Archivos clave revisados

| Archivo | Rol en preferencias/configuración | Líneas relevantes |
|---|---|---|
| `game/isla-ancestral/scripts/core/game_settings.gd` | Singleton/autoload `GameSettings`; guarda preferencias de controles y vídeo en `user://settings.cfg`; contiene campos de audio deprecados. | L3-L81 |
| `game/isla-ancestral/scripts/datos/gestor_config.gd` | Capa estática M60; carga/guarda `user://config.cfg` con `ConfigFile` + wrapper atómico crudo; define defaults por sección (`graficos`, `audio`, `accesibilidad`, `general`). | L10-L78 |
| `game/isla-ancestral/scripts/datos/data_store.gd` | Autoload `DataStore`; fachada para `guardar_config/cargar_config`, cache `_config_estatica`, señales `config_lista/config_guardada`. | L59, L418-L435 |
| `game/isla-ancestral/scripts/audio/audio_config_service.gd` | Autoload `AudioConfig`; fuente de verdad de audio en runtime (volúmenes por bus, mutes, opciones). Persiste en sección `audio` de `DataStore/GestorConfig`; aplica al `AudioServer` y managers. | L10-L309 |
| `game/isla-ancestral/scripts/settings/graphics_config.gd` | Núcleo puro de configuración gráfica M90: presets, validación parcial (`fijar`, `validar_slider`), serialización `to_dict/from_dict/from_json`, detección/recomendación, mapeos lógicos. **No persiste por sí mismo ni aplica pantalla/render real salvo utilidades puntuales.** | L1-L575 |
| `game/isla-ancestral/scripts/ui/layers/settings_audio_layer.gd` | UI de Ajustes > Audio; conecta sliders/mutes/opciones con `AudioConfig`; debounce de commit; feedback visual ante fallo de opción; sincronización inversa por señales. | L5-L499 |
| `game/isla-ancestral/scripts/ui/test_settings_audio_roundtrip.gd` | Test headless del round-trip UI<->AudioConfig<->config; restaura snapshot al final. | L5-L247 |
| `game/isla-ancestral/scripts/settings/test_graphics_config.gd` | Test headless del núcleo gráfico (pantalla/calidad/presets/detección/persistencia lógica). | L1-L217 |
| `game/isla-ancestral/project.godot` | Registro de autoloads relevantes: `GameSettings`, `AudioConfig`, `DataStore`. No se observó autoload específico de `GraphicsConfig` en la búsqueda. | L25, L88-L89 |
| `game/isla-ancestral/scripts/follow_camera.gd` | Consumidor de preferencias de control de `GameSettings` (`mouse_sensitivity`, `invert_y`). | L92-L93 |

## 1) ¿Cómo se gestionan las preferencias de usuario?

Existen **varios subsistemas**, con separación parcial pero no completamente unificada:

- **Controles/vídeo “legacy/M46” (`GameSettings`)**: singleton con estado en memoria (`mouse_sensitivity`, `invert_y`, `fullscreen`, `resolution_index`, `game_settings.gd:10-27`). Carga en `_ready()` (`:32`), guarda/carga con `ConfigFile` a `user://settings.cfg` (`:29,34-69`) y emite `settings_changed` (`:7,50,69`). `reset_defaults()` restablece y persiste (`:71-81`). La cámara consume `mouse_sensitivity`/`invert_y` (`follow_camera.gd:92-93`).
- **Configuración estructurada por secciones (`GestorConfig`/`DataStore`)**: `GestorConfig` define defaults base para `graficos/audio/accesibilidad/general` (`gestor_config.gd:20-42`) y persiste `user://config.cfg` mediante `ConfigFile.encode_to_text()` + `WriterAtomico.escribir_atomicamente_crudo()` (`:67-78`). `cargar_config()` parsea el documento crudo, hace merge de defaults por sección y conserva claves presentes en archivo (`:48-65`). `DataStore` expone `guardar_config/cargar_config/config_actual` y cachea `_config_estatica` (`data_store.gd:418-435`).
- **Audio como fuente de verdad (`AudioConfigService`)**: crea buses hijo, carga config, aplica volúmenes/opciones y registra proveedor de guardado (`audio_config_service.gd:52-56,59-72,74-97`). Expone API de dominio: `set_volumen/get_volumen/set_mute` (`:118-179`), API de porcentaje 0-100 para UI (`:138-166`) y `set_opcion/get_opcion` para `rango_dinamico/compresion/dispositivo_salida` (`:193-214`). Persiste bajo `config["audio"]` en `DataStore` incluyendo subdiccionarios `mutes` y `opciones` (`:266-279`), y también participa en `get_save_data/restore_save_data` (`:282-309`).
- **UI de audio (`SettingsAudioLayer`)**: construye controles, sincroniza estado real desde `AudioConfig`, usa debounce para commits de slider (`DEBOUNCE_COMMIT=0.25`, `:41,151-157,270-285,326-348`), aplica opciones con feedback visual y reversión si falla (`:310-322,431-439`), y escucha señales inversas `volumen_cambiado/mute_cambiado/opcion_cambiada` para evitar bucles usando `set_value_no_signal/set_pressed_no_signal/select` donde corresponde (`:358-389,466-485`).
- **Gráficos (`GraphicsConfig`)**: núcleo puro en memoria con presets completos, getters/setters controlados (`obtener/fijar`), serialización (`to_dict/from_dict/from_json`) y utilidades de mapeo/aplicación lógica (`graphics_config.gd:167-575`). Sin embargo, en el alcance de scripts analizados **no se encontró un consumidor runtime/UI claro que lo persista en `DataStore` ni que aplique sus valores al motor/viewport/window de forma integral** (la búsqueda mostró principalmente el propio módulo y sus tests `settings/test_graphics_config*.gd`).

## 2) ¿Hay validación de valores de preferencia antes de guardar?

**Sí, pero desigual según subsistema.**

- **`AudioConfigService` (buena validación de dominio):** valida bus existente al setear volumen (`has` + clamp 0..1, `:118-127`); clamp al cargar (`:85,298`); conversiones porcentaje<->lineal con clamp (`:138-156`); valida claves de opción contra `OPCIONES_VALIDAS` (`:193-196,211-214`); valida valores por tipo/catálogo (`rango_dinamico` en presets, `compresion` bool, `dispositivo_salida` en dispositivos disponibles, `:216-227`); aplica al motor y solo persiste si la aplicación confirma estado (`:198-203,231-248`).
- **`GraphicsConfig` (validación parcial, núcleo):** `fijar()` solo acepta claves presentes en el preset base `medio` (`:196-201`) — no valida el **tipo/rango/enum** del valor recibido. `validar_slider()` sí clampea rangos conocidos (`:362-367`) y se usa en algunos caminos (`:419,526,559`), pero **no en `fijar()` ni en `aplicar_preset()` ni como barrera general antes de `to_dict()`**. `from_dict()` migra con defaults del preset medio pero ignora claves desconocidas y **no valida valores cargados** (`:307-313`); `from_json()` solo valida que sea `Dictionary` (`:315-321`). `resolucion_vec2()` cae a 1080p para resoluciones desconocidas (`:456-463`) — comportamiento defensivo puntual.
- **`GestorConfig` (merge defensivo, sin validación fuerte):** ante archivo corrupto/formato antiguo usa defaults completos (`:52-56`); mergea por secciones conocidas (`SECCIONES`) y conserva claves presentes sin validar tipo/rango/enum (`:59-64`). `guardar_config()` escribe lo que recibe para secciones válidas sin validación semántica (`:69-78`). El parámetro `defaults` de `cargar_config()` es público, pero el resultado siempre parte de `DEFAULTS_BASE` por sección (`:48-51`) — detalle menor de API, no validación de datos externos.
- **`GameSettings` (validación débil):** usa `ConfigFile.get_value()` con fallback al valor actual, pero **no clampa** `mouse_sensitivity` (documentada como 0.001..0.1 en comentario `:9`) ni valida `resolution_index`, booleanos/tipos inesperados (`:57-67`). `save_settings()` persiste el estado tal cual (`:34-50`). `reset_defaults()` sí restablece valores seguros (`:71-81`).
- **`SettingsAudioLayer` (validación defensiva en UI):** valida índices de `OptionButton` (`:293-308`) y delega la validación real a `AudioConfig`; ante fallo revierte widgets al estado real (`:315-322`).

## 3) ¿Hay preferencias que no se persisten correctamente?

Se observan **riesgos concretos** y un caso de inconsistencia de diseño:

1. **`GameSettings` (controles/vídeo) puede persistir valores fuera de rango o de tipo inesperado sin saneamiento.**  
   - Evidencia: `load_settings()` asigna directamente desde `get_value(..., default)` (`game_settings.gd:57-58,66-67`); no hay `clampf` para `mouse_sensitivity` ni validación de `resolution_index`.  
   - Impacto: si `user://settings.cfg` se edita manualmente, se corrompe parcialmente o proviene de una versión antigua con valores inválidos, el juego puede cargar sensibilidad extrema/negativa o un índice de resolución no soportado. La persistencia “funciona” técnicamente, pero el valor persistido/cargado puede ser **inválido**.

2. **`GestorConfig` mezcla defaults pero no elimina valores inválidos/obsoletos.**  
   - Evidencia: al cargar conserva cualquier clave presente en el archivo para secciones conocidas (`gestor_config.gd:59-64`) y al guardar reescribe el diccionario recibido (`:69-77`).  
   - Impacto: claves obsoletas o valores fuera de dominio pueden permanecer en `user://config.cfg` indefinidamente. No es pérdida de persistencia, pero sí **persistencia de basura/estado inválido** y posible fricción en migraciones futuras.

3. **Preferencias gráficas (`GraphicsConfig`) tienen serialización lógica, pero no hay persistencia runtime integrada evidente.**  
   - Evidencia: `graphics_config.gd` implementa `to_dict/from_dict/from_json` (`:302-321`) y el test valida round-trip lógico (`settings/test_graphics_config.gd:199-217`), pero no define `class_name`, no aparece como autoload (`project.godot` sin entrada encontrada), y no se hallaron llamadas runtime de UI/core/datos que guarden/carguen esos datos en `DataStore/GestorConfig`.  
   - Impacto: **alto riesgo funcional** de que cambios gráficos realizados con este núcleo no sobrevivan reinicio de sesión si la UI real usa `GraphicsConfig` sin una capa de persistencia externa. (Conclusión basada en evidencia estática del árbol `scripts/`; se recomienda confirmar con la escena/UI de ajustes gráficos si existe fuera de este alcance.)

4. **Audio UI depende de commit/debounce: comportamiento correcto, pero sensible a cierres abruptos.**  
   - Evidencia: el slider marca `_sucios` y difiere escritura con `Timer` (`settings_audio_layer.gd:270-285`); `commit_pendiente()`/`drag_ended`/`close` fuerzan commit (`:279-285,326-348,351-354,454-461`).  
   - Impacto: si la app termina abruptamente durante el arrastre antes de timeout/commit (crash, kill, cierre forzado), el último movimiento puede no persistir. Es un trade-off razonable por §21.4 (evitar I/O por frame), pero conviene documentarlo o mitigar con flush en puntos de ciclo de vida.

## 4) ¿Hay conflictos entre preferencias por defecto y guardadas?

**Sí, hay conflictos/doble fuente potencial en audio y esquemas separados de persistencia.**

1. **Doble almacenamiento de audio: `user://settings.cfg` (GameSettings) vs `user://config.cfg`/sección `audio` (GestorConfig/DataStore/AudioConfig).**  
   - Evidencia: `GameSettings` todavía guarda/carga `master_volume/music_volume/sfx_volume` y los marca como DEPRECATED/compatibilidad, indicando explícitamente que **no controlan buses** (`game_settings.gd:13-23,40-44,60-64,74-78`). `GestorConfig.DEFAULTS_BASE["audio"]` usa claves distintas (`volumen_maestro`, `volumen_musica`, `volumen_sfx`, `volumen_ambiente`, `volumen_voz`, `:26-33`). `AudioConfig` persiste por nombre de bus (`Master/Music/SFX/Ambient/Voice/UI/Cinematic`) bajo `config["audio"]` (`audio_config_service.gd:23-31,266-279`) y aplica al `AudioServer`.  
   - Conflicto: **mismo dominio (audio), tres esquemas/archivos distintos**. No hay sincronización visible entre `GameSettings` y `AudioConfig`. Un desarrollador o UI antigua podría leer/escribir los campos deprecados creyendo que afectan el audio real. Los defaults también difieren en semántica/nombres (p. ej. SFX 1.0 en `GameSettings` vs 0.8 en `AudioConfig/DEFAULTS`), lo que puede confundir depuración.

2. **Conflicto de autoridad para controles/vídeo no resuelto a nivel de servicio único.**  
   - Evidencia: `GameSettings` persiste controles/vídeo en `user://settings.cfg` (`:29,36-47`), mientras `GestorConfig` tiene secciones `graficos/general` en `user://config.cfg` (`gestor_config.gd:16-42`) con claves no alineadas (`calidad/vsync/resolucion_escala` vs `fullscreen/resolution_index`).  
   - Conflicto: **dos modelos de preferencias visuales/controles** coexisten. Si en el futuro una UI escribe en `config.cfg.graficos` y otra lee de `GameSettings.video`, habrá divergencia entre lo guardado y lo aplicado.

3. **Merge de defaults en `GestorConfig` es aditivo, no normalizador.**  
   - Evidencia: `cargar_config()` parte de defaults y sobreescribe con valores del archivo (`gestor_config.gd:48-65`), pero no elimina claves desconocidas ni corrige tipos/rangos.  
   - Conflicto potencial: defaults nuevos pueden coexistir con valores guardados incompatibles o residuos de versiones antiguas. Esto no pisa defaults sanos, pero puede impedir que una migración “limpia” el estado efectivo.

4. **`AudioConfig` trata bien defaults y persistencia, pero el orden/alcance de `mutes/opciones` tiene matices.**  
   - Evidencia: carga defaults, mergea volúmenes conocidos, restaura `mutes`/`opciones` desde subdiccionarios (`audio_config_service.gd:74-97`), y reaplica opciones persistidas (`:250-256`).  
   - Conflicto menor: si `config.cfg` contiene mutes/opciones de buses/claves ya no válidas, se ignoran o se conservan parcialmente según caso; es defensivo, pero el archivo puede retener estado huérfano. No se observó conflicto directo que invalide defaults activos.

## 5) Sugerencias de mejora (2)

1. **Unificar el contrato de preferencias (fuente de verdad + esquema + migración).**  
   - Definir un **único repositorio lógico** para preferencias de usuario (p. ej. `DataStore/GestorConfig`) con secciones/versionado explícito: `controls`, `video/graphics`, `audio`, `accessibility`, `general`.  
   - Migrar/encapsular `GameSettings` para que deje de persistir audio deprecado y, si se mantiene por compatibilidad, solo actúe como adaptador temporal.  
   - Alinear nombres de claves de audio (o documentar mapping) entre `GestorConfig.DEFAULTS_BASE["audio"]` y el formato real usado por `AudioConfig` (`Master/Music/...` + `mutes/opciones`) para evitar defaults contradictorios.  
   - Agregar un migrador de `user://settings.cfg` -> `user://config.cfg` con backup y marca de versión.

2. **Agregar validación/saneamiento centralizado antes de guardar y después de cargar.**  
   - **GameSettings:** clampear `mouse_sensitivity` al rango soportado, validar `resolution_index` contra resoluciones disponibles, normalizar tipos bool/int/float al cargar; ignorar o registrar valores inválidos.  
   - **GestorConfig:** introducir validadores por sección/clave (tipo, rango, enum, forma de subdiccionarios) y una política de migración: conservar claves conocidas válidas, descartar/registrar inválidas, completar faltantes con defaults.  
   - **GraphicsConfig:** validar en `fijar()` y `from_dict()` (tipo + pertenencia a enums/rangos para claves críticas como `resolucion`, `modo`, `aa`, `upscaling`, `vsync`, `fps`, `escala`, calidades); reutilizar `validar_slider()`/tablas de opciones. Además, implementar integración real de persistencia/aplicación (autoload/servicio + UI) si el módulo va a ser usado en runtime.  
   - **Audio UI:** mantener debounce, pero añadir flush defensivo en `NOTIFICATION_WM_CLOSE_REQUEST`/`_exit_tree` o equivalente cuando aplique, para reducir pérdida ante cierre abrupto.

## Conclusión final

La base del proyecto **ya tiene piezas sólidas** para audio: `AudioConfigService` actúa como fuente de verdad, valida volúmenes/opciones, aplica al motor, persiste en `config.cfg` vía `DataStore/GestorConfig` y la UI `SettingsAudioLayer` implementa un flujo robusto (debounce, commit, reversión ante fallo y sincronización por señales). También hay tests de integración útiles (`test_settings_audio_roundtrip.gd`, `test_graphics_config.gd`).

Sin embargo, la gestión global de preferencias **no está completamente unificada**: coexisten `GameSettings` (`user://settings.cfg`, con campos de audio deprecados y baja validación), `GestorConfig/DataStore` (`user://config.cfg`) y un `GraphicsConfig` bien diseñado como núcleo pero sin persistencia/runtime wiring evidente en los scripts analizados. Los principales riesgos son **validación insuficiente en GameSettings/GraphicsConfig.from_dict/fijar**, **estado inválido u obsoleto persistido por merge aditivo**, **posible no persistencia efectiva de ajustes gráficos en runtime**, y **conflictos de esquema/autoridad entre archivos y dominios**.

**Prioridad recomendada:** 1) unificar contrato/fuente de verdad y migrar `settings.cfg`; 2) agregar saneamiento/validación transversal antes de guardar y después de cargar, con especial foco en `GameSettings` y la integración real de `GraphicsConfig`.
