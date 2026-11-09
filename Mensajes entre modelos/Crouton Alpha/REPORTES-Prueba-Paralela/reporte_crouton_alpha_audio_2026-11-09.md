# Reporte de audio — Isla Ancestral

**Modelo:** Crouton Alpha
**Fecha:** 2026-11-09
**Alcance:** `game/isla-ancestral/scripts/` (audio, sonido, música) + `game/isla-ancestral/data/audio/` + `game/isla-ancestral/project.godot`

> Nota: este es el reporte del día 2026-11-09 (actualización del reporte del 2026-11-08 en la misma carpeta). Se re-analizó el árbol completo, no solo `scripts/audio/`, para incluir productores de audio fuera de esa carpeta.

## 1. ¿Cómo se gestiona el audio (SFX, música, ambiente)?

### 1.1 `scripts/audio/` — núcleo data-driven (6 directores + managers)

**`audio_config_service.gd` (M91, autoload `AudioConfig`) — configuración y buses**

- Crea en runtime 6 buses hijo si no existen: `Music`, `SFX`, `Ambient`, `Voice`, `UI`, `Cinematic` (líneas 33, 59-71), enrutados a `Master` (línea 66, 68-71). Total 7 buses.
- Volumen lineal 0-1 con piso dB -80: `_aplicar_volumen()` (líneas 105-113), API `set_volumen()`/`get_volumen()` (118-130), API porcentaje 0-100 para sliders M53 (138-165), mute persistente `set_mute()`/`esta_muteado()` (168-178).
- Persistencia en `config.cfg` vía `DataStore` (fix BUG-092): mutes y opciones (rango_dinamico, compresion, dispositivo_salida) se guardan y restauran (líneas 74-96, 193-203, 266-279).
- Sin `class_name`: es autoload (línea 19, pitfall §9.17/§9.41). Señales `volumen_cambiado`/`mute_cambiado` (40-41).

**`sfx_manager.gd` (M43, autoload `SFXManager`, 400 líneas) — SFX**

- Pool fijo de 24 voces preallocadas: `MAX_VOCES := 24` (línea 43), `_voces.resize(MAX_VOCES)` en `_ready()` (línea 74).
- Categorías con prioridad invertida (líneas 54-59): ui=10, mundo=7, bloque=5, paso=1. Límites: ≤6 del mismo tipo (`MAX_MISMO_TIPO := 6`, línea 62; chequeo líneas 359-361), UI máx 2 simultáneos (línea 55; chequeo 364-366).
- `_reproducir()` (líneas 350-383): purga voces >5 s (354-358), busca slot libre (368-371), si pool lleno corta la voz de menor prioridad solo si la nueva es mayor (372-383). Nunca crece sin tope.
- API pública: `reproducir(efecto, pos, prioridad, categoria)` (líneas 189-190; nota: `pos` es `Variant = null`, con `Vector3` se registra como espacial pero no se instancia `AudioStreamPlayer3D` — comentario línea 188), `reproducir_localizado()` (195-201), `reproducir_superficie()` (177-183), `catalogo()`/`catalogo_variaciones()` (110-125), `tono()` (394-396).
- Data-driven: `sfx_surfaces.json`, `sfx_tones.json`, `sfx_catalog.json` (constantes líneas 44-46; carga con `push_warning` si faltan, líneas 84-107).
- Ducking de diálogo: `ducking_dialogo()` baja bus SFX −6 dB, idempotente (líneas 285-289), suscripción a `DialogueManager.dialogue_started/ended` en `_conectar_dialogos()` (220-227). En cada cambio recalcula la base desde `AudioConfig` (`_aplicar_ganancia_sfx()` 295-299, `_db_base_sfx()` 302-308) para no arrastrar un volumen obsoleto. Esto escribe dB directamente sobre el bus (`AudioServer.set_bus_volume_db`, línea 299) — es la única escritura dB del núcleo.
- 7 suscripciones defensivas a otros autoloads (`_conectar_autoloads()`, líneas 238-252): `Achievements.logro_desbloqueado` (255-256), `Crafting.crafting_completed/failed` (259-264), `ShopManager.compra/venta_exitosa/rechazada` (267-281). Todas con `has_signal` antes de `connect` (`_conectar_si()`, 247-252).
- Pausa: `pausar()`/`reanudar()` (322-340) con purga y desplazamiento de `tiempo_ms` (335-340). En pausa no se emite nada nuevo (líneas 351-352).
- PRNG cacheado con semilla del reloj M29 (`_semilla_rng()`, líneas 131-136); sin allocs por evento.

**`music_director.gd` (M41, autoload `MusicDirector`, 101 líneas) — música**

- Selección por contexto: `play_contexto(entorno, hora, estacion, clima)` (líneas 44-51): noche si hora<6 o ≥21 (línea 47), lluvia si clima==2 (línea 49), si no tema base por entorno (`_tema_base_entorno()`, 53-58, fallback `aurora_dia` línea 58).
- `_cambiar_tema()` (65-74): valida contra `music_context_matrix.json`, evita re-emitir si es el mismo tema (69-70), emite señal `tema_cambio(tema, capas)` (línea 73). **No instancia ningún `AudioStreamPlayer` ni hace crossfade** — el header (líneas 5-8) anuncia "A/B crossfade, shuffle, pausa" pero el código es solo selección+señal.
- Variaciones sin repetición consecutiva: `siguiente_variacion()` (87-95) con `ShuffleSampler` (`shuffle_sampler.gd`, 57 líneas: baraja con PRNG de partida, re-baraja evitando repetir la última al inicio, líneas 32-54).
- Stubs: `sting()` es `pass` (líneas 77-78, comentario "el compositor provee los assets"); `pausar()`/`reanudar()` solo flipan `_pausado` (80-84).

**`ambient_director.gd` (M42, autoload `AmbientDirector`, 72 líneas) — ambiente**

- Banco por bioma `ambient_biome_bank.json` (constante línea 14; 13 biomas: playa, bosque, pradera, volcán, montaña, selva, desierto, laguna, arrecife, ceniza, aurora, cueva, subterráneo). `set_bioma()` (41-46), `set_estado_clima()` (48-50), `set_fase()` (52-54) → `_emitir_ambiente()` (56-66): duplica capas, agrega capa de clima (`clima_%d`), emite `ambiente_cambiado(bioma, capas)`.
- `pausar()`/`reanudar()` (68-72): `pass` total. Sin players ni capas reales.

**`feedback_director.gd` (M44, autoload `FeedbackDirector`, 83 líneas) — ASMR/feedback**

- `sensacion(accion)` (53-67): consulta `feedback_recetas.json` (línea 13; 8 recetas), blacklist `feedback_blacklist.json` (línea 14: prohibidas `explosion`, `grito`, `alarma`, `sirena`) → devuelve `[]`, agrega capa interior (reverb) si `_contexto["interior"]`, emite `feedback_aplicado`. Sin reproducción.
- `key_sync()` (75-77) y pausa (79-83): `pass`.

**`narrative_sound.gd` (M150, autoload `NarrativeSound`, 243 líneas) — diseño sonoro narrativo**

- Catálogo `narrative_sound.json` (constante línea 27; 30+ momentos, 8 leitmotifs, `leitmotifs_por_isla` RIZ/COR/CEN/AUR líneas 350-355, reglas líneas 356-359).
- Estado + señales únicamente. `play_leitmotif()` (102-114) setea `current_leitmotif` y emite `leitmotif_started`; el comentario (113-114) admite que "la reproducción real depende de M41". `stop_leitmotif()` (117-122) limpia estado y emite `leitmotif_ended` — **no detiene ningún stream**. `play_narrative_silence()` (167-173) hace `stop_leitmotif()` + `await` timer; "el MusicDirector debe silenciar su salida" (línea 172).
- Integración EventBus (`_conectar_eventos()`, líneas 47-62): `quest.prereq_met` → `trigger_sello()` (203-210), `travel.island_loaded` / `TravelService.travel_arrived` → `on_cambio_isla()` (230-243) con fade-out (stop antes de play, líneas 238/242). Normaliza 3 nomenclaturas de isla (187-199: `islas.json` RIZ/COR/CEN/AUR vs `tiers_config.json` isla_raiz/coral/ceniza/aurora vs `rutas.json` isla_raiz/sur/norte/brisa/espejo — estas últimas devuelven `""`).

**`dynamic_range_manager.gd` (132 líneas) + `compression_manager.gd` (102 líneas) + `output_device_manager.gd` (57 líneas) — efectoría (M91)**

- Stateless: el estado se deriva de `AudioServer` (presencia de `AudioEffectCompressor`/`AudioEffectLimiter` en el bus), sin nodos ni coste por frame.
- `DynamicRangeManager`: presets quiet/medio/dinamico (líneas 34-38), `aplicar()` (42-59), `actual()` (64-75, devuelve `custom` si no coincide con preset), `remover()` (93-101). Corrige errores del diseño original: usa `AudioEffectCompressor.threshold/ratio/attack_us/release_ms` reales de Godot 4.7 (comentario líneas 16-22, T-107).
- `CompressionManager`: `AudioEffectLimiter` sobre bus `Master` por defecto (líneas 20, 23-26), `activar()`/`desactivar()`/`activa()` (30-49). También API sondeada (T-107, líneas 13-16).
- `OutputDeviceManager`: `dispositivos()` (31-32), `seleccionar()` (43-47, valida contra lista real), categorías UI como etiquetas (líneas 26, 51-57).

### 1.2 Productores reales de audio fuera de `scripts/audio/` (síntesis + pools)

| Archivo | Líneas | Qué produce | Bus |
|---|---|---|---|
| `scripts/tools/tool_feedback.gd` (M13, 174 líneas) | 30-36, 37-42, 102-108 | Pool round-robin de 5 `AudioStreamPlayer` (POOL_AUDIO, línea 26) con 7 sonidos sintetizados (`_sintetizar()`, líneas 76-100: suma de parciales + ruido, envolvente exponencial). Golpes, extracciones, colocación, fallos, rotura. | Sin `bus` explícito → `Master` (default de Godot) |
| `scripts/crafting/crafting_feedback.gd` (M16, 181 líneas) | 21-29, 37-56, 108-111, 156-181 | 4 `AudioStreamPlayer` (ok/desc/anc/sec) con beeps sinusoidales en memoria (`_generar_seno()`, líneas 156-181: 660 Hz/0.18 s, 880 Hz/0.28 s, 1046 Hz/0.35 s, 988 Hz/0.32 s, con envolvente attack/release) | `bus = "Master"` explícito (líneas 39, 44, 49, 54) |
| `scripts/ui/services/ui_feedback.gd` (M53 H, 103 líneas) | 17-20, 64-82 | 4 `AudioStreamPlayer` (hover/click/confirm/invalid) creados en `_crear_players()`, `_play()` con stop-preventivo si ya suena (líneas 78-81). Volumen configurable (93-101). | `bus = "UI"` (línea 73) |
| `scripts/enchantment/shaman_ui.gd` (M163, 281 líneas) | 12, 81-83, 264-281 | 1 `AudioStreamPlayer` `SfxEncantar` con beep procedural 660→880 Hz 0.12 s (`_beep()`, líneas 264-281: regenera el WAV en cada éxito) | Sin bus → `Master` |
| `scripts/dialogos/ui/dialogue_ui.gd` (M21, 633 líneas) | 90, 206-208 | 1 `AudioStreamPlayer` `SonidoTipeo` para tipeo (seguro en headless sin stream). El contador `_conteo_sonido_tipeo` (línea 91) limita la frecuencia. | Sin bus → `Master` |
| `scripts/rendimiento/memoria/pool_factory.gd` (M62, 130 líneas) | 22, 75-76, 106-108 | Familia `audio_voz` (límite 24, precalentamiento 8, línea 22): instanciación centralizada. Al estacionar limpia `stream = null` y `stop()` (106-108). | Sin bus → `Master` |

### 1.3 `data/audio/` (8 JSON, sin assets binarios)

`ambient_biome_bank.json` (13 biomas, capas+clima), `feedback_blacklist.json` (4 prohibidas), `feedback_recetas.json` (8 recetas), `music_context_matrix.json` (26 temas, 22 capas con LUFS, 5 stings, 4 variaciones), `narrative_sound.json` (30+ momentos, 8 leitmotifs con instrumentos/tonalidad/tempo, `leitmotifs_por_isla`, 2 reglas), `sfx_catalog.json`, `sfx_surfaces.json`, `sfx_tones.json`. **No hay ningún `.ogg`/`.wav`/`.mp3` en el árbol** — toda la data son nombres de capa/song sin archivos de audio. Los únicos sonidos reales son los sintetizados en memoria (tool_feedback, crafting_feedback, shaman_ui).

### 1.4 Datos que referencian audio (recursos)

- `scripts/combat/island_zone.gd` línea 22: `@export var music_track: AudioStream = null` (dueño M43/M65, vacío = sin música).
- `scripts/combat/boss_data.gd` línea 19: `@export var music_track: AudioStream = null` (dueño M43/M65, vacío = música de zona).
- `scripts/backup/backup_manager.gd` líneas 80-81: `func backup_musica()` (categoría `musica`).

## 2. ¿Hay AudioMixer o bus de audio configurado?

**Sí, en runtime (no en asset).** No existe `default_bus_layout.tres` en `game/isla-ancestral/` (verificado por búsqueda: sin resultados en `.tres`).

- **7 buses:** `Master` (del engine) + 6 creados por `AudioConfig` en `_ready()` (`_crear_buses()`, `audio_config_service.gd` líneas 52-55, 59-71), enrutados a `Master` (líneas 66, 68-71). El test `test_audio_effects_m91.gd` valida `AudioServer.bus_count == 7` y enrutado a `Master` (líneas 44-51).
- **Defaults** (`audio_config_service.gd` líneas 23-31): Master 0.8, Music 0.7, SFX 0.8, Ambient 0.6, Voice 0.9, UI 0.5, Cinematic 0.8.
- **Persistencia:** `config.cfg` vía `DataStore` + `GestorConfig` (M60, `scripts/datos/gestor_config.gd` líneas 26-32: `volumen_maestro` 0.8, `volumen_musica` 0.7, `volumen_sfx` 0.8, `volumen_ambiente` 0.7, `volumen_voz` 0.9), con escritura atómica (líneas 69-78) y fix BUG-092 para mutes/opciones.
- **Efectos sobre bus `Master`:** `AudioEffectCompressor` (DynamicRangeManager) y `AudioEffectLimiter` (CompressionManager). El test `test_audio_effects_m91.gd` líneas 164-171 verifica la presencia del compressor; las fuentes de verdad de rango/compresión se derivan de `AudioServer` (no hay estado duplicado).
- **Consumo cruzado:** `SFXManager` lee `AudioConfig.get_volumen("SFX")` como base (`sfx_manager.gd` líneas 304-308) y aplica delta de ducking sobre el bus; `UIFeedback` (`ui_feedback.gd` líneas 73, 86-96) pone sus players en bus `UI` con volumen propio (`-6 dB` por defecto, línea 14).
- **Autoloads registrados** en `project.godot` (líneas 88, 101-105): `AudioConfig`, `MusicDirector`, `AmbientDirector`, `SFXManager`, `FeedbackDirector`, `NarrativeSound`.
- **Hueco:** `project.godot` no declara sección `[audio]` (sin `driver/enable_input` ni `buses/default_bus_layout`); el layout existe solo por código. Si otro autoload toca `AudioServer` antes de `AudioConfig._ready()` (orden de carga), los buses no existirían todavía — hoy no ocurre porque los 4 directores solo emiten señales, pero es un riesgo de acoplamiento temporal.

## 3. ¿Hay problemas de sonido duplicado o no detenido?

**No hay bug audible hoy, porque el núcleo (M41/M42/M44/M150) no suena; los productores reales (M13/M16/UI/M163/M21) sí suenan y están bien diseñados.** Hallazgos:

1. **Sin playback en el núcleo (causa raíz, ya documentada el 2026-11-08).** Grep `AudioStreamPlayer` sobre `scripts/audio/` solo da hits en `audio_config_service.gd` (buses), `dynamic_range_manager.gd`/`compression_manager.gd` (efectos), `sfx_manager.gd` (volumen de bus, líneas 296/299) y tests. Grep `stop()`/`play()` en `scripts/audio/`: 0 hits en código productivo — solo flags `_pausado` y señales. Por eso "duplicado/no detenido" no puede manifestarse en música/ambiente/feedback/narrativo hoy.
2. **Stop solo lógico en el núcleo.** `narrative_sound.gd stop_leitmotif()` (líneas 117-122), `music_director.gd` sin `stop`, `ambient_director.gd pausar() = pass` (líneas 68-72). En `on_cambio_isla()` (líneas 230-243) se hace `stop_leitmotif()` antes de `play_leitmotif()`, pero al conectar players reales ese stop no detendría el stream anterior. Cada `set_bioma/set_estado_clima/set_fase` en `ambient_director.gd` emite sin detener el anterior (líneas 41-66).
3. **Los productores reales sí gestionan el stop correctamente:**
   - `ui_feedback.gd _play()` (líneas 78-81): si el player ya suena, `stop()` antes de `play()` — anti-solapamiento por player.
   - `pool_factory.gd _estacionar()` (líneas 106-108): `stream = null` + `stop()` al devolver al pool — evita retención de streams (el test `test_m62_buses_m91.gd` líneas 184, 205, 232 verifica `p.stop()` y WeakRef).
   - `tool_feedback.gd` (líneas 102-108): pool round-robin de 5 players, sin necesidad de detener porque cada disparo toma el siguiente player libre.
   - `sfx_manager.gd`: tope duro 24 + ≤6 por tipo + UI máx 2 (líneas 43, 62, 350-383); ducking idempotente (líneas 285-289, `if activar == _ducking: return`); `music_director.gd` no re-emite el mismo tema (líneas 69-70); `narrative_sound.gd` no re-entra a la misma isla (líneas 231-232).
4. **Duplicado potencial en la frontera SFX↔Feedback (M43 vs M13/M16):** `sfx_manager.gd` y `tool_feedback.gd`/`crafting_feedback.gd` reproducen los mismos eventos por canales distintos. Ejemplo: `crafting_completed` dispara `SFXManager._on_crafting_completed()` (→ `reproducir("crafting_exito")`, líder 259-260) **y** `CraftingFeedback._on_crafting_completed()` (→ `_tocar(_audio_ok)`, `crafting_feedback.gd` líneas 71-73) **y** `FeedbackDirector.sensacion()` (sin reproducción hoy). Los dos primeros ya coexisten: un craft exitoso suena el beep sinusoidal de crafting **más** la cola SFX (que hoy no instancia player, pero en cuanto lo haga, duplicado). El diseño M44 preveía `sensacion()` como única entrada ASMR, pero M13/M16 tienen sus propios players y no pasan por SFXManager.
5. **Pausar/no detener al cambiar de escena:** `sfx_manager.gd pausar()` (líneas 351-352) bloquea voces nuevas pero no pausa streams reales (no hay ninguno que pausar hoy en el núcleo; en M13/M16/UI los players quedan sonando si la escena cambia). `music_director.gd pausar()` (80-84) y `ambient_director.gd` (68-72) son stubs/`pass`. `narrative_sound.gd play_narrative_silence()` (líneas 167-173) delega el silencio a M41 sin contrato implementado.
6. **Deriva test vs código (ya documentada el 2026-11-08):** `test_musica_m41.gd` líneas 147 y `test_ambient_m42.gd` línea 90 llaman `esta_pausado()`, método inexistente en `music_director.gd`/`ambient_director.gd` actuales. `test_ambient_m42.gd` línea 80 espera `Layer_0: AudioStreamPlayer` que `ambient_director.gd` nunca crea.

## 4. ¿Hay validación de assets de audio?

**Parcial. Hay validación de buses y config, y de data JSON (existencia); no hay validación de assets binarios de audio porque no hay ninguno.**

- **Buses/valores:** `test_audio_config.gd` valida buses, volúmenes linear→dB, persistencia M60, API porcentaje. `test_audio_effects_m91.gd` (líneas 44-51, 87, 103, 132) valida topología de 7 buses, compresor, rechazo de bus inexistente. `test_sfx_m43.gd` valida ducking idempotente y jerarquía SFX < diálogo (líneas 258-281).
- **Data JSON:** todos los directores hacen `FileAccess.file_exists()` + `JSON.parse_string()` + `typeof(parsed) == TYPE_DICTIONARY` con `push_warning` si falta o es inválida (`music_director.gd` líneas 27-33, `ambient_director.gd` 26-32, `feedback_director.gd` 28-42, `sfx_manager.gd` 84-107, `narrative_sound.gd` 73-79). `play_contexto()`/`play_momento()`/`momento()`/`leitmotif()` devuelven `""`/`{}`/`false` con `push_warning` si el id no existe (`narrative_sound.gd` líneas 102-109, 135-139) — degradación silenciosa, no validación dura.
- **Sin validación binaria:** no hay assets `.ogg`/`.wav` que validar (los streams reales se sintetizan en memoria: `tool_feedback.gd` líneas 76-100, `crafting_feedback.gd` líneas 156-181, `shaman_ui.gd` líneas 264-281). No hay validador que recorra `res://audio/` o compruebe `AudioStream` importables; no hay godoc que audite LUFS (los JSON declaran LUFS: `music_context_matrix.json` líneas 28-53 = −16..−24 LUFS) ni que detecte streams nulos en `IslandZone.music_track`/`BossData.music_track` (`island_zone.gd` línea 22, `boss_data.gd` línea 19, sin `.import` ni preload).
- **Cobertura de tests:** 7 tests (`test_sfx_m43.gd`, `test_musica_m41.gd`, `test_ambient_m42.gd`, `test_feedback_m44.gd`, `test_audio_config.gd`, `test_audio_effects_m91.gd`, `test_narrative_m150.gd`) + `test_crafting.gd` líneas 215-219 (verifica `AudioStreamWAV` creable) + `test_m62_buses_m91.gd` (verifica stop/WeakRef) + `test_m62_ogg_cache.gd` (PoolFactory de audio). Suficiente para el estado actual.

## 5. Dos mejoras sugeridas

### Mejora 1 — Centralizar la reproducción por SFXManager y eliminar el duplicado M43/M13/M16

Que `ToolFeedback` y `CraftingFeedback` no instancien sus propios `AudioStreamPlayer`, sino que pidan a `SFXManager.reproducir_localizado()` / `reproducir()` con la categoría correspondiente (paso/bloque/mundo). `SFXManager` ya tiene pool (24), límites (≤6 por tipo, UI máx 2), ducking y pausa; añadirle una capa de 24 `AudioStreamPlayer` reales (o `AudioStreamPlayer3D` cuando `pos != null`, hoy solo guardado en el dict línea 370) y enrutar cada bus (`Music` para M41, `Ambient` para M42, `UI` para M53 que ya lo hace en `ui_feedback.gd` línea 73). Con esto un craft exitoso suena una sola vez, el cambio de bioma/clima (M42) y de tema (M41) dejan de ser solo señales y el "no detenido" desaparece por construcción (cada tema/capa posee su player con `stop()`+fade). Archivos a tocar: `sfx_manager.gd` (añadir pool real), `tool_feedback.gd` (sustituir `_reproducir`, líneas 102-108), `crafting_feedback.gd` (sustituir 4 players, líneas 37-56), `music_director.gd` (conectar `tema_cambio`), `ambient_director.gd` (conectar `ambiente_cambiado`), `narrative_sound.gd` (conectar `leitmotif_started/ended`).

### Mejora 2 — Orquestar pausa/mute global en `AudioConfig` + validador de assets de audio

Añadir a `audio_config_service.gd` `pausar_todo()`/`reanudar_todo()` que deleguen `stream_paused` a los pools (SFXManager, Music, Ambient, UIFeedback) y, como respaldo, `set_bus_mute` temporal de `Music`/`Ambient`/`SFX`; invocarlos desde la pausa global de `GameTime` (M29). Hoy cada director tiene su propia `_pausado` aislado (`sfx_manager` líneas 322-340, `music_director` 80-84, `ambient` `pass` 68-72) y `narrative_sound.gd` delega el silencio a M41 sin contrato (líneas 167-173). Incluir además un `audio_asset_validator.gd` (huella `GUIA-GODOT/06`, patrón `validate_animation_cli.gd`/`validate_world.gd`): recorre `data/audio/` + `res://` buscando `.ogg/.wav/.mp3/.aif`, comprueba `ResourceLoader.exists()`, avisa si una entrada JSON (`music_context_matrix.json`, `narrative_sound.json`, `ambient_biome_bank.json`) nombra una capa sin archivo, y audita los LUFS declarados vs el techo de `CompressionManager` (0 dB, `compression_manager.gd` línea 24). Hoy la ausencia de archivos es invisible porque todo son nombres en JSON.

## Conclusión final

El sistema de audio de Isla Ancestral está **bien diseñado a nivel de bus/configuración** (7 buses en runtime con persistencia BUG-092, compresión dinámica stateless, ducking idempotente, límites anti-solapamiento en SFX, síntesis procedural robusta a headless en M13/M16/M163) y **vacío a nivel de reproducción en el núcleo** (los 5 directores M41/M42/M44/M150/SFXManager solo emiten señales sobre JSON; producen 0 `AudioStreamPlayer` reales). Por eso **no hay sonido duplicado ni colgado audible hoy en el núcleo — el riesgo es latente y aparecerá en cuanto se conecten players sin `stop()`/pausa orquestada**. El único duplicado real ya presente es la doble vía craft (M43 SFXManager + M16 CraftingFeedback sobre el mismo evento), y la validación de assets binarios no existe porque no hay assets binarios: toda la salida son nombres en 8 JSON + WAVs sintetizados en memoria. **Prioridad:** (1) centralizar la reproducción en SFXManager y eliminar los pools de M13/M16 (mejora 1); (2) pausa global orquestada + validador de assets (mejora 2); corregir además la deriva `esta_pausado()` en los tests M41/M42 y `Layer_0: AudioStreamPlayer` en el test M42.
