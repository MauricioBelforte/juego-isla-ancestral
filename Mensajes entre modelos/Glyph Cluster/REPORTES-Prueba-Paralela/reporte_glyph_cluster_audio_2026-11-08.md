# Reporte de análisis: sistema de audio (scripts + configuración)
**Modelo:** Glyph Cluster  
**Fecha:** 2026-11-08  
**Alcance revisado:** `game/isla-ancestral/scripts/**/*.gd` (búsqueda dirigida a audio/sonido/SFX/buses) + `game/isla-ancestral/project.godot` + recursos de audio en `game/isla-ancestral/` (assets `.wav/.ogg/.mp3`).  
**Método:** inspección estática por `glob/grep/read` (PowerShell `Select-String`/`Get-Content`). No se ejecutó Godot runtime/MCP en esta sesión.

## 1) Archivos relacionados con audio (scripts)

**Directorio principal (`scripts/audio/`, 17 `.gd`):**
- `scripts/audio/audio_config_service.gd` — autoload `AudioConfig` (M91): buses, volúmenes/mute, persistencia, opciones de rango dinámico/compresión/dispositivo.
- `scripts/audio/sfx_manager.gd` — autoload `SFXManager` (M43): pool lógico de 24 voces, prioridades, límites por categoría/tipo, ducking de diálogo, suscripciones a autoloads.
- `scripts/audio/music_director.gd` — autoload `MusicDirector` (M41): selección de tema por contexto, señal `tema_cambio`, shuffle de variaciones.
- `scripts/audio/ambient_director.gd` — autoload `AmbientDirector` (M42): selección de ambiente por bioma/clima/fase, señal `ambiente_cambiado`.
- `scripts/audio/feedback_director.gd` — autoload `FeedbackDirector` (M44): recetas por acción, blacklist, señal `feedback_aplicado`.
- `scripts/audio/narrative_sound.gd` — autoload `NarrativeSound` (M150): momentos/leitmotifs narrativos, triggers por `EventBus`/`TravelService`.
- `scripts/audio/dynamic_range_manager.gd` — `class_name DynamicRangeManager`: presets de compresión sobre bus (stateless, deriva de `AudioServer`).
- `scripts/audio/compression_manager.gd` — `class_name CompressionManager`: limiter de picos (stateless).
- `scripts/audio/output_device_manager.gd` — `class_name OutputDeviceManager`: dispositivos reales/categorías de salida.
- `scripts/audio/shuffle_sampler.gd` — `class_name ShuffleSampler`: barajado sin repetición consecutiva (PRNG).
- Tests: `test_audio_config.gd`, `test_sfx_m43.gd`, `test_musica_m41.gd`, `test_ambient_m42.gd`, `test_feedback_m44.gd`, `test_narrative_m150.gd`, `test_audio_effects_m91.gd`.

**Uso de audio fuera de `scripts/audio/` (hallazgos relevantes):**
- `scripts/crafting/crafting_feedback.gd:21-24,37,42,47,52,108,111` — crea 4 `AudioStreamPlayer` (éxito, descarte, ancestral, secundario), genera `AudioStreamWAV` procedural (`_beep`) y llama `.play()`. Enruta a bus `SFX` (`:38,43,48,53`).
- `scripts/enchantment/shaman_ui.gd:12,81,281` — crea 1 `AudioStreamPlayer`, asigna `stream` y hace `.play()` al encantar.
- `scripts/tools/tool_feedback.gd:15,38,108` — pool de 8 `AudioStreamPlayer` para feedback de herramientas, `.play()`.
- `scripts/templos/puzzle_sonido.gd:11,17` — **modelo puro de datos**; explícitamente no toca `AudioServer`/nodos de audio.
- `scripts/legal/credits_manager.gd:325` — chequea `AudioServer.get_bus_count()` (solo presencia).
- Tests/QA: `scripts/crafting/test_crafting.gd:215`, `scripts/ui/test_m53_no_redundancia.gd:8,39,53`, `scripts/ui/test_feedback_accion_m53.gd:146` verifican que ciertos flujos UI (toasts/feedback acción) **no** creen `AudioStreamPlayer`.

## 2) ¿Cómo se gestiona el audio (SFX, música, ambiente)?

### Configuración central y buses (M91)
- Autoload registrado: `project.godot:88` → `AudioConfig="*res://scripts/audio/audio_config_service.gd"`.
- `AudioConfig` define 7 buses lógicos: `Master` + hijos `Music,SFX,Ambient,Voice,UI,Cinematic` (`audio_config_service.gd:23-24`).
- Los buses se **crean en runtime** si no existen y se enrutan a `Master` (`audio_config_service.gd:57-71`, `AudioServer.add_bus/set_bus_name/set_bus_send`).
- Volumen lineal 0–1 → `linear_to_db`, mute por bus, defaults por bus (`:26-34,99-114,116-185`). API extra 0–100% para sliders (`:148-185`).
- Persistencia vía `DataStore.cargar_config()/guardar_config()` en sección `audio` (volúmenes, `mutes`, `opciones`) y proveedor de guardado con `SaveManager` (`:74-97,268-307`).
- Opciones persistidas: `rango_dinamico`, `compresion`, `dispositivo_salida` aplicadas a managers stateless (`:36-266`).

### SFX (M43)
- Autoload: `project.godot:103` → `SFXManager`.
- `SFXManager` es un **gestor lógico** (no reproduce assets reales desde disco en el código leído): mantiene pool preasignado de 24 “voces” como metadatos (`tipo, prioridad, categoria, tiempo_ms, pos`) con limpieza por antigüedad (>5s) y límites (`sfx_manager.gd:41-43,52-83,349-384,386-391`). No instancia `AudioStreamPlayer`/`AudioStreamPlayer3D` para reproducir sonidos en este script.
- Catálogos data-driven JSON: `sfx_surfaces.json`, `sfx_tones.json`, `sfx_catalog.json` (`:44-46,72-155`). Selección de variaciones por superficie/catálogo; PRNG cacheado (`:157-166`).
- API: `reproducir()`, `reproducir_localizado()`, `reproducir_superficie()`, `catalogo*`, `pausar()/reanudar()`, `ducking_dialogo()` (`:168-344`).
- Ducking: baja `SFX` -6 dB durante diálogo, recalculando base desde `AudioConfig` para no pisar sliders (`:249-278`). Se suscribe a `DialogueManager.dialogue_started/ended` sin modificar M21 (`:228-244`).
- Suscripciones defensivas (`has_signal` + `is_connected`) a autoloads: `Achievements`, `Crafting`, `ShopManager` (`:246-327`).

### Música (M41)
- Autoload: `project.godot:101` → `MusicDirector`.
- Selecciona tema por `entorno/hora/clima` desde `music_context_matrix.json` y emite `tema_cambio(tema, capas)` (`music_director.gd:13,15,24-74`). `sting()` es stub (`:76-78`). No crea `AudioStreamPlayer` ni carga streams en el script leído.
- Variaciones con `ShuffleSampler` (PRNG, sin repetición consecutiva) (`:86-95`, `shuffle_sampler.gd`).

### Ambiente (M42)
- Autoload: `project.godot:102` → `AmbientDirector`.
- Banco por bioma desde `ambient_biome_bank.json`; emite `ambiente_cambiado(bioma, capas)` según bioma/clima/fase (`ambient_director.gd:12,14,25-66`). Sin reproducción real de audio en el script leído.

### Feedback/ASMR (M44) y Narrativa (M150)
- `FeedbackDirector` (`project.godot:104`) aplica recetas JSON + blacklist + contexto y emite `feedback_aplicado` (`feedback_director.gd:16,23-67`). Sin players.
- `NarrativeSound` (`project.godot:105`) gestiona momentos/leitmotifs JSON, emite `leitmotif_started/ended/momento_played/silencio_started` (`narrative_sound.gd:22-25,100-185`). Conecta triggers a `EventBus` (`quest.prereq_met`, `travel.island_loaded`) y `TravelService.travel_arrived` si existe (`:45-69`). Comentario explícito: “La reproducción real depende de M41 (Música)… aquí solo emitimos señales” (`:113-115`).

### Patrón observado
- La **capa de dominio/dirección** (M41-M44, M150, parte de M43) está mayormente **data-driven + señales/eventos**, pero en los directores no se observan `AudioStreamPlayer` que consuman esas señales.
- La **reproducción real** encontrada en gameplay usa `AudioStreamPlayer` locales/procedurales en `crafting_feedback.gd`, `shaman_ui.gd`, `tool_feedback.gd` (no los autoloads directores).

## 3) ¿Hay AudioMixer o bus de audio configurado?

- **No se encontró `default_bus_layout.tres` / `*audiobus*`** en `game/isla-ancestral/` (búsqueda recursiva). `project.godot` no muestra `audio/buses/default_bus_layout` (solo autoloads audio en `:88,101-105`).
- **Sí hay gestión de buses por código**: `AudioConfig` crea/configura 7 buses en `AudioServer` al arrancar (`audio_config_service.gd:57-114`). Esto funciona como “layout programático”, pero depende de ejecución del autoload.
- **Efectos de bus por código (M91):**
  - `DynamicRangeManager` añade/quita `AudioEffectCompressor` según preset (`dynamic_range_manager.gd:45-63,94-101`).
  - `CompressionManager` añade/quita `AudioEffectLimiter` (`compression_manager.gd:37-43,76-94`).
  - Ambos derivan estado consultando `AudioServer` (stateless).
- **Conclusión:** existe infraestructura de buses/efectos vía `AudioServer`, pero **no hay `AudioBusLayout` asset versionado** visible; la topología/efectos base no quedan declarados en un `.tres` de editor.

## 4) ¿Hay problemas de sonido duplicado o no detenido?

### Hallazgos (riesgos / áreas a vigilar)
1. **Directores sin consumidores reales evidentes (riesgo de “audio no suena” o integración incompleta, no duplicado):** `MusicDirector/AmbientDirector/FeedbackDirector/NarrativeSound` emiten señales (`tema_cambio`, `ambiente_cambiado`, `feedback_aplicado`, `leitmotif_started/momento_played`) pero la búsqueda no mostró listeners fuera de tests/audio (`grep` de señales: solo definiciones/emits + tests `test_ambient_m42.gd`, `test_musica_m41.gd`, `test_feedback_m44.gd`). Esto sugiere que la capa de reproducción conectada a esas señales puede faltar o estar en otro punto no detectado.
2. **`SFXManager` es pool lógico, no detiene/reproduce streams reales:** `_reproducir()` rechaza por pausa/límites/prioridad y expira voces por tiempo (`sfx_manager.gd:349-384`), pero no llama `.stop()` sobre `AudioStreamPlayer` porque no los gestiona. Si en el futuro se conectan players reales, faltaría el bridge “voz lógica ↔ player real” con stop/liberación.
3. **Creación de players locales sin liberación explícita en algunos casos:**
   - `crafting_feedback.gd:37-55` crea 4 `AudioStreamPlayer` persistentes y reutiliza `.play()` (`:108-112`) — **no duplica** players por evento; correcto en patrón (streams procedurales se reasignan).
   - `shaman_ui.gd:81-85,279-282` crea 1 player persistente y llama `.play()` al encantar — reutilización; sin `.stop()` previo, pero `play()` reinicia el stream (comportamiento Godot). Riesgo menor de solapamiento solo si el diseño quisiera cortar sonidos previos.
   - `tool_feedback.gd:15,36-41,96-109` usa pool fijo de 8 players; selecciona el primero **no** `playing` y si todos ocupados toma índice 0 (`:101-107`) — puede **cortar/reiniciar** un sonido en curso bajo saturación (decisión de diseño), no fuga de nodos.
4. **Ducking SFX idempotente pero acoplado a estado global:** `_aplicar_ganancia_sfx` recalcula base desde `AudioConfig` (`sfx_manager.gd:269-278`), lo cual evita acumulación por doble activación (`_ducking` guard). Bien. Riesgo: si otros sistemas modifican volumen de `SFX` directamente sin pasar por `AudioConfig`, la restauración puede no reflejar su intención.
5. **NarrativeSound crea timers de silencio con `await create_timer()`** (`narrative_sound.gd:180-185`): en cambios rápidos/escenas puede quedar un await huérfano si el nodo se libera; no es duplicación de audio, pero es un punto de robustez.

**No se detectaron** llamadas masivas `.play()` en bucles por frame ni creación de `AudioStreamPlayer` dentro de `_process/_physics_process` en los archivos de audio/gameplay inspeccionados. Los `.play()` encontrados están en handlers/eventos (`crafting_feedback._tocar`, `shaman_ui._on_btn_encantar`, `tool_feedback.disparar`).

## 5) ¿Hay validación de assets de audio?

- **Datos/config JSON:** buena validación defensiva en general: `FileAccess.file_exists`, `JSON.parse_string`, chequeos `typeof(...) == TYPE_DICTIONARY/ARRAY`, `push_warning` ante faltantes (`audio_config_service.gd` vía `DataStore`; `music_director.gd:25-32`; `ambient_director.gd:25-32`; `feedback_director.gd:23-37`; `narrative_sound.gd:73-81`; `sfx_manager.gd:72-100`).
- **Buses/efectos:** validan índices y tipos (`AudioServer.get_bus_index() == -1`, casts `is AudioEffectCompressor/Limiter`) antes de operar (`audio_config_service.gd:60-71,102-114`; managers M91).
- **Assets de audio reales (`.wav/.ogg/.mp3`)**: **no se encontraron archivos de audio** bajo `game/isla-ancestral/` por nombre de extensión (búsqueda recursiva). Tampoco se observaron `load/preload` de streams de audio en `scripts/audio/*.gd`. Los sonidos reproducidos hoy son mayormente **procedurales** (`AudioStreamWAV` generado en `crafting_feedback.gd:57-105`; UI/tool feedback también usa players locales) o **declarativos sin stream** (señales/catálogos).
- **Hueco:** no hay una capa de validación tipo “manifest de streams requeridos” (existencia/importación/formato/loop settings) para futuros assets de música/ambiente/SFX. Los directores asumen que alguien más reproducirá lo que ellos señalan.

## 6) Dos mejoras sugeridas

### Mejora 1 — Conectar la capa de dirección a reproducción real (bridge señal → `AudioStreamPlayer`)
**Problema:** `MusicDirector`, `AmbientDirector`, `FeedbackDirector` y `NarrativeSound` emiten señales/estado pero no hay evidencia de consumidores que reproduzcan audio; `SFXManager` gestiona voces lógicas sin players.  
**Propuesta:**
- Crear un componente “AudioRuntime/Playback” (autoload o nodos en escena de juego) que escuche: `MusicDirector.tema_cambio`, `AmbientDirector.ambiente_cambiado`, `NarrativeSound.leitmotif_started/ended/momento_played`, y que instancie/reutilice `AudioStreamPlayer`/`AudioStreamPlayer2D/3D` con `bus` correcto (`Music/Ambient/SFX/Voice/UI/Cinematic`).
- Definir un contrato mínimo: `tema/capas/leitmotif/momento` → `res://audio/...` (o IDs resolubles), con fallback silencioso + `push_warning` si falta el stream.
- Añadir validación de existencia de streams al cargar catálogos/matriz (o en un test de integridad de assets).

### Mejora 2 — Formalizar bus layout y pruebas de integración audio
**Problema:** no hay `default_bus_layout.tres` versionado; la topología se crea en runtime por `AudioConfig`. Esto dificulta revisar efectos/ruteo en el editor y puede divergir entre escenas/tests si el autoload no corre o corre en orden inesperado.  
**Propuesta:**
- Añadir `res://default_bus_layout.tres` con los 7 buses y ruteos base; configurar `project.godot` (`audio/buses/default_bus_layout`) para que el editor y runtime compartan layout. Mantener `AudioConfig` como capa de **aplicación de valores** (volumen/mute/opciones) y verificación defensiva (crear bus solo si falta).
- Agregar test de integración headless que verifique: buses existen, `SFX`/`Voice` rutean a `Master`, ducking restaura volumen base tras `DialogueManager` start/end (caso M43), y no se acumulan efectos duplicados al re-aplicar presets M91.
- Opcional: registrar métricas simples en `SFXManager` (descartes por límite/prioridad, cortes por saturación) para detectar “sonidos perdidos” durante QA.

## 7) Conclusión
- El proyecto tiene una **base de audio bien modularizada por dominios** (M91 config/buses, M41 música, M42 ambiente, M43 SFX lógico, M44 feedback, M150 narrativa) y la mayoría son **autoloads data-driven** con señales, defensas de carga JSON y persistencia de configuración.
- La **gestión de buses** existe en runtime vía `AudioServer` (7 buses, volúmenes, mute, efectos de compresión/limiter), pero **falta un `AudioBusLayout` asset** versionado.
- **SFX/feedback real** hoy se apoya en `AudioStreamPlayer` locales procedurales en algunos sistemas de gameplay; los directores principales parecen **emitir eventos** sin una cadena de reproducción real claramente conectada en los scripts inspeccionados. No se hallaron assets `.wav/.ogg/.mp3` en el árbol del juego.
- No se observaron patrones claros de duplicación por frame/instanciación continua; los riesgos principales son de **integración incompleta (señales sin playback)**, **posible corte bajo saturación** en pools locales y **robustez** (timers/await, dependencia de orden de autoloads).

**Líneas/archivos clave (referencia rápida):** `project.godot:88,101-105`; `audio/audio_config_service.gd:23-34,57-114,116-266,268-307`; `audio/sfx_manager.gd:41-83,168-344,349-391`; `audio/music_director.gd:13,41-74`; `audio/ambient_director.gd:12,39-66`; `audio/feedback_director.gd:16,50-67`; `audio/narrative_sound.gd:22-25,45-69,100-185`; `audio/dynamic_range_manager.gd`; `audio/compression_manager.gd`; `audio/output_device_manager.gd`; `crafting/crafting_feedback.gd:21-55,108-112`; `enchantment/shaman_ui.gd:12,81,281`; `tools/tool_feedback.gd:15,36-41,96-109`.

*Reporte generado por inspección estática; verificar en runtime (Godot/MCP V4) para confirmar comportamiento real de reproducción, ruteo y solapamiento.*
