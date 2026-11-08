# Reporte de audio — Isla Ancestral

**Modelo:** Crouton Alpha
**Fecha:** 2026-11-08
**Alcance:** `game/isla-ancestral/scripts/audio/` + datos `game/isla-ancestral/data/audio/`

## 1. ¿Cómo se gestiona el audio (SFX, música, ambiente)?

Arquitectura: 5 directores autoload (sin `class_name`, por decisión pitfall §9.17/§9.41) + 1 servicio de configuración. Todos son **data-driven** (JSON) y **solo emiten señales / ocupan slots lógicos**; ninguno instancia un `AudioStreamPlayer`.

### SFX — `scripts/audio/sfx_manager.gd` (M43, 400 líneas)

- Pool fijo preallocado de 24 voces: `MAX_VOCES := 24`, `_voces.resize(MAX_VOCES)` (líneas 43, 67, 74).
- Categorías con prioridad invertida (mayor gana): ui=10, mundo=7, bloque=5, paso=1 (líneas 54-59). Límites: `MAX_MISMO_TIPO := 6` (línea 62), UI máx 2 simultáneos (línea 55).
- `_reproducir()` (líneas 350-383): purga voces >5 s (líneas 354-358), rechaza si mismo tipo ≥6 (360-361) o categoría UI llena (364-366), busca slot libre (368-371) y, si el pool está lleno, corta la voz de menor prioridad solo si la nueva es mayor (372-383).
- API pública: `reproducir()` (líneas 189-190), `reproducir_localizado()` (195-201), `reproducir_superficie()` (177-183), `tono()` (394-396), `catalogo()` (110-111).
- Datos: `sfx_surfaces.json` (9 superficies), `sfx_tones.json` (familia tonal §4), `sfx_catalog.json` (12 filas). Carga con `push_warning` si falta (líneas 84-107).
- Ducking de diálogo: `ducking_dialogo()` baja SFX −6 dB (líneas 285-289), suscripción a `DialogueManager` en `_conectar_dialogos()` (220-227).
- Pausa: `pausar()`/`reanudar()` (322-340) con purga de vencidas y desplazamiento de `tiempo_ms` (335-340).

### Música — `scripts/audio/music_director.gd` (M41, 101 líneas)

- Selección por contexto: `play_contexto(entorno, hora, estación, clima)` (líneas 44-51): noche si hora <6 o ≥21, lluvia si clima==2, si no tema base por entorno (`_tema_base_entorno`, 53-58).
- `_cambiar_tema()` (65-74): valida contra `music_context_matrix.json`, evita re-emitir si es el mismo tema (69-70), emite señal `tema_cambio(tema, capas)` (línea 73).
- Variaciones: `siguiente_variacion()` (87-95) con `ShuffleSampler` sin repetición consecutiva.
- Stubs sin implementar: `sting()` es `pass` (77-78); `pausar()`/`reanudar()` solo flipan `_pausado` (80-84). **No hay crossfade A/B ni players instanciados** pese a anunciarlo en el header (líneas 5-8).

### Ambiente — `scripts/audio/ambient_director.gd` (M42, 72 líneas)

- Banco por bioma desde `ambient_biome_bank.json`; `set_bioma()` (41-46), `set_estado_clima()` (48-50), `set_fase()` (52-54) → `_emitir_ambiente()` (56-66): duplicación de capas + capa de clima, emite `ambiente_cambiado(bioma, capas)`.
- `pausar()`/`reanudar()` (68-72): `pass` total. Sin players ni capas reales.

### Feedback / ASMR — `scripts/audio/feedback_director.gd` (M44, 83 líneas)

- `sensacion(accion)` (53-67): consulta `feedback_recetas.json`, blacklist `feedback_blacklist.json` (anti-agresión: devuelve `[]`), agrega capa interior si `_contexto["interior"]`, emite `feedback_aplicado`. Sin reproducción.
- `key_sync()` (75-77) y pausa (79-83): `pass`.

### Narrativo — `scripts/audio/narrative_sound.gd` (M150, 243 líneas)

- Estado + señales únicamente. `play_leitmotif()` (102-114): setea `current_leitmotif`, emite `leitmotif_started`; **el comentario admite que "la reproducción real depende de M41"** (líneas 113-114).
- `stop_leitmotif()` (117-122): limpia estado y emite `leitmotif_ended`. No detiene ningún stream.
- `play_narrative_silence()` (167-173): `stop_leitmotif()` + timer; "el MusicDirector debe silenciar su salida" (línea 172).
- Integración por EventBus (líneas 47-71): `quest.prereq_met` → `trigger_sello()` (203-210), `travel.island_loaded` / `TravelService.travel_arrived` → `on_cambio_isla()` (230-243) con fade-out (stop antes de play). Normaliza 3 nomenclaturas de isla (187-199).

### Soporte

- `audio_config_service.gd` (M91, 309 líneas): ver §2.
- `dynamic_range_manager.gd` (132 líneas): `class_name DynamicRangeManager` estático/stateless; presets quiet/medio/dinamico (líneas 34-38); `aplicar()` (42-59), `actual()` (64-75), `remover()` (93-101) sobre `AudioEffectCompressor` en el bus.
- `shuffle_sampler.gd`, `compression_manager.gd`, `output_device_manager.gd`, `feedback_director.gd`, más tests (`test_sfx_m43.gd`, `test_musica_m41.gd`, `test_ambient_m42.gd`, `test_audio_effects_m91.gd`, `test_audio_config.gd`, `test_narrative_m150.gd`, etc.) y `scripts/ui/layers/settings_audio_layer.gd`.

## 2. ¿Hay AudioMixer o bus de audio configurado?

**Sí, en runtime, no en asset.** No existe `default_bus_layout.tres` en `game/isla-ancestral/` (verificado: `Test-Path` = False).

- `audio_config_service.gd` (`_crear_buses()`, líneas 59-71): crea 6 buses hijo si no existen (`Music`, `SFX`, `Ambient`, `Voice`, `UI`, `Cinematic`; constante línea 33) enrutados a `Master` (líneas 66, 68-71). Total: 7 buses.
- Valores por defecto (líneas 23-31): Master 0.8, Music 0.7, SFX 0.8, Ambient 0.6, Voice 0.9, UI 0.5, Cinematic 0.8.
- Aplicación (líneas 105-113): `linear_to_db()` con piso 0.0001, respeto de mute (`AudioServer.set_bus_mute` líneas 110/112, `set_bus_volume_db` línea 113).
- API pública: `set_volumen()`/`get_volumen()` (118-130), API porcentaje 0-100 para sliders (138-165), `set_mute()`/`esta_muteado()` (168-178), señales `volumen_cambiado`/`mute_cambiado` (40-41).
- Persistencia: `config.cfg` vía `DataStore` (`_guardar_config()` 266-279; `_cargar_config()` 74-96), incluyendo mutes y opciones desde el fix BUG-092 (líneas 86-94, 274-277). Opciones validadas: `rango_dinamico`, `compresion`, `dispositivo_salida` (líneas 38, 193-203, 231-247).
- Efectoría: `DynamicRangeManager` adjunta `AudioEffectCompressor` al bus `Master` por defecto (`dynamic_range_manager.gd` línea 26, 42-59).
- Consumo: `sfx_manager.gd` lee `AudioConfig.get_volumen("SFX")` como base (`_db_base_sfx()` 302-308) y escribe dB directamente sobre el bus en ducking (`_aplicar_ganancia_sfx()` 295-299). Diseño correcto (no arrastra volumen obsoleto).

## 3. ¿Hay problemas de sonido duplicado o no detenido?

**No hay bug audible hoy, porque nada suena.** Hallazgos:

1. **Sin capa de playback (causa raíz).** Grep `AudioStreamPlayer|AudioServer` sobre `scripts/audio/` solo da hits en `audio_config_service.gd` (buses), `dynamic_range_manager.gd` (efectos), `sfx_manager.gd` (líneas 296/299 volumen) y un test (`test_ambient_m42.gd` línea 80 espera `Layer_0: AudioStreamPlayer` que `ambient_director.gd` nunca crea). Grep `stop\(\)|\.stop|play\(\)` en `scripts/audio/`: 0 hits en código productivo — solo flags `_pausado` y señales. Es decir: "duplicado/no detenido" no puede manifestarse porque no hay reproductores que solapar o dejar colgados.
2. **Stop solo lógico.** `narrative_sound.gd stop_leitmotif()` (117-122), `music_director.gd` sin `stop`, `ambient_director.gd` `pausar()` = `pass` (68-72). En `on_cambio_isla()` (230-243) se hace `stop_leitmotif()` antes de `play_leitmotif()`, pero al conectar players reales ese stop no detendría el stream anterior.
3. **Deriva test vs código.** `test_musica_m41.gd` línea 147 y `test_ambient_m42.gd` línea 90 llaman `esta_pausado()`, método inexistente en `music_director.gd` / `ambient_director.gd` actuales.
4. **Lo que sí está bien (anti-duplicado preventivo):** pool SFX con tope duro 24 y ≤6 por tipo (líneas 43, 62, 350-383); ducking idempotente (líneas 285-289: `if activar == _ducking: return`); recálculo de base en cada cambio de ducking (líneas 295-299); `music_director.gd` evita re-emitir el mismo tema (líneas 69-70); `narrative_sound.gd` evita re-entrada de isla (líneas 231-232).
5. **Riesgo latente al implementar playback:** si se conectan players sin `stop()` real, dos temas/capas podrían coexistir en cambios de isla, bioma o clima (cada `set_bioma/set_estado_clima/set_fase` en `ambient_director.gd` emite sin detener el anterior), y la pausa global solo bloquea voces nuevas en SFX (líneas 351-352) sin pausar streams ya sonando.

## 4. Dos mejoras sugeridas

### Mejora 1 — Capa de reproducción real con stop/fade por bus
Crear un `AudioPlayback` (o 3 pools dentro de cada director) con `AudioStreamPlayer`/`AudioStreamPlayer3D` enrutados a su bus: Music 2 players para crossfade A/B, Ambient 1 player por capa, SFX 24 players (o `AudioStreamPlayer3D` para `pos != null`, hoy solo registrado en el dict línea 370). Conectar las señales existentes (`tema_cambio`, `ambiente_cambiado`, `feedback_aplicado`, `leitmotif_started/ended`) a `play()/stop()` con `tween` de volumen (fade 0.5-1 s). Con esto, `stop_leitmotif()`, `on_cambio_isla()` y los setters de ambiente dejan de ser solo señales y el "no detenido" desaparece por construcción.

### Mejora 2 — Pausa/mute global orquestado por `AudioConfig`
Añadir a `audio_config_service.gd` `pausar_todo()/reanudar_todo()` (delegando `stream_paused` a los pools y, como respaldo, mute temporal de buses) e invocarlos desde la pausa global de `GameTime` (M29). Hoy cada director tiene una `_pausado` aislado (`sfx_manager` líneas 322-340, `music_director` 80-84, `ambient` sin implementar) y `narrative_sound.gd` delega el silencio a M41 sin contrato. Un orquestador único elimina sonidos colgados al pausar/cambiar de escena y hace el silencio narrativo (líneas 167-173) real sin tocar cada director.

## Conclusión final

El sistema de audio de Isla Ancestral está **bien diseñado a nivel datos y buses** (7 buses en runtime con persistencia BUG-092, ducking, compresión dinámica, límites anti-solapamiento en SFX) pero **no tiene capa de reproducción**: los 5 directores son máquinas de estado/señales sobre JSON. Por eso **no hay sonido duplicado ni colgado audible hoy** — el riesgo es latente y aparecerá en cuanto se conecten players sin `stop()`/pausa orquestada. Prioridad: implementar la capa de playback (mejora 1) y la pausa global (mejora 2) antes de poblar assets; corregir además la deriva `esta_pausado()` en los tests de M41/M42.
