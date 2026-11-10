# Reporte de Análisis de Audio — Isla Ancestral

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code (Agent Manager)  
**Fecha:** 2026-11-09  
**Alcance:** `game/isla-ancestral/scripts/audio/`, configuración de buses/audio en `project.godot`, y referencias runtime relacionadas.

---

## 1) Cómo se gestiona el audio (SFX, música, ambiente)

### Arquitectura general
El audio está organizado por **autoloads especializados** declarados en `project.godot` (`[autoload]`):
- `AudioConfig="*res://scripts/audio/audio_config_service.gd"` (`project.godot`:97)
- `MusicDirector="*res://scripts/audio/music_director.gd"` (`project.godot`:109)
- `AmbientDirector="*res://scripts/audio/ambient_director.gd"` (`project.godot`:110)
- `SFXManager="*res://scripts/audio/sfx_manager.gd"` (`project.godot`:111)
- `FeedbackDirector="*res://scripts/audio/feedback_director.gd"` (`project.godot`:112)
- `NarrativeSound="*res://scripts/audio/narrative_sound.gd"` (`project.godot`:113)

Los directores son **data-driven**: cargan JSON desde `res://data/audio/` y exponen señales/estado; en varios casos la reproducción real de `AudioStream` está pendiente o delegada (integración parcial).

### SFX (`scripts/audio/sfx_manager.gd`)
- **Tipo:** autoload, pool lógico de **24 voces** prealocadas (`MAX_VOCES := 24`, L43; `_voces.resize(MAX_VOCES)`, L74).
- **Datos:** carga superficies/tonos/catálogo JSON (`RUTA_SURFACES/TONES/CATALOG`, L44–46; carga en L76–108).
- **API:** `reproducir_superficie` (L177–183), `reproducir` (L189–191), `reproducir_localizado` (L195–201), `configurar_volumen` delegando a `AudioConfig` (L313–318), `pausar/reanudar` (L322–340), `ducking_dialogo` (L285–289).
- **Límites/prioridades:** categorías (`CATEGORIAS`, L54–59), ≤6 del mismo tipo (`MAX_MISMO_TIPO`, L62; check L360–361), límite por categoría UI (L363–366), reemplazo por prioridad cuando el pool está lleno (L372–383), purga de voces >5s (L355–358, L342–347).
- **Integraciones:** ducking con `DialogueManager` (`_conectar_dialogos`, L220–233) y suscripciones defensivas a autoloads de logros/crafting/tienda (`_conectar_autoloads/_conectar_si`, L238–252) usando `has_signal`/`is_connected`.
- **Estado de reproducción real:** el comentario indica que el 2º argumento `pos` registra espacialidad pero la emisión 3D queda a la espera de `AudioStreamPlayer3D` (L188). No se crean `AudioStreamPlayer*` ni se asignan `AudioStream` en este script; es un **gestor lógico de voces/prioridades**, no un motor de reproducción de samples.

### Música (`scripts/audio/music_director.gd`)
- **Tipo:** autoload; carga matriz de contexto (`RUTA_MATRIZ`, L15; `_cargar_matriz`, L27–33).
- **Lógica:** `play_contexto(entorno, hora, _estacion, clima)` selecciona tema por noche/lluvia y fallback (L44–62), `_cambiar_tema` evita reemitir el mismo tema y emite `tema_cambio` con capas (L65–74).
- **Variaciones:** `siguiente_variacion` usa `ShuffleSampler` cacheado por tema (L87–95).
- **Estado de reproducción real:** no hay `AudioStreamPlayer`, `play()`, `stop()`, tween/crossfade ni asignación de streams; implementa selección/estado y señalización. `sting()` es stub (L77–78). El diseño menciona A/B crossfade (L7), pero el código actual no lo ejecuta.

### Ambiente (`scripts/audio/ambient_director.gd`)
- **Tipo:** autoload; carga banco por bioma (`RUTA_BANCO`, L14; L26–32).
- **Lógica:** `set_bioma/set_estado_clima/set_fase` actualizan estado y emiten `ambiente_cambiado` con capas (L41–66). `pausar/reanudar` vacíos (L68–72).
- **Estado de reproducción real:** no instancia reproductores ni streams; emite la intención/capas para que otro sistema las reproduzca.

### Feedback ASMR (`scripts/audio/feedback_director.gd`)
- **Tipo:** autoload; carga recetas y blacklist (`RUTA_RECETAS/BLACKLIST`, L13–14).
- **Lógica:** `sensacion(accion)` aplica blacklist, precedencia contextual (interior agrega capa) y emite `feedback_aplicado` (L53–67). `key_sync` es stub (L75–77).
- **Estado de reproducción real:** sin `AudioStreamPlayer`/streams.

### Sonido narrativo (`scripts/audio/narrative_sound.gd`)
- **Tipo:** autoload; catálogo `narrative_sound.json` (L27) con momentos/leitmotifs/reglas.
- **Integración:** conecta triggers vía `EventBus` y `TravelService` de forma defensiva (L47–62, L65–71). Emite `leitmotif_started/ended`, `momento_played`, `silencio_started` (L22–25).
- **Reproducción real:** el propio script aclara que la reproducción depende de M41 (`MusicDirector`) y que aquí solo se emiten señales/estado (L113–114, L172–173). `play_narrative_silence` usa `await create_timer` (L167–173) solo como pausa lógica.

### Configuración y efectos (`audio_config_service.gd`, managers M91)
- `AudioConfig` gestiona volúmenes, mute, persistencia y opciones (`rango_dinamico`, `compresión`, `dispositivo_salida`) aplicadas a `AudioServer`/managers (L33–39, L118–174, L193–255, L266–309).
- `DynamicRangeManager` aplica presets/compressor por bus vía `AudioServer` (stateless, deriva estado del servidor). `CompressionManager` gestiona `AudioEffectLimiter`. `OutputDeviceManager` lista/selecciona dispositivos reales (`AudioServer.get_output_device*`).

---

## 2) ¿Hay AudioMixer o bus de audio configurado?

- **No se encontró** `default_bus_layout.tres` en `game/isla-ancestral/` (búsqueda de `*bus*layout*` sin resultados). Tampoco hay sección `[audio]` con `bus_layout` visible en `project.godot` (inspección del inicio del archivo).
- **Los buses se crean en runtime** por `AudioConfigService`:
  - Hijos definidos: `Music, SFX, Ambient, Voice, UI, Cinematic` (`BUSES_HIJOS`, L33).
  - `_crear_buses()` crea los que falten, los enruta a `Master` y fuerza envío de buses no-Master a `Master` (L59–71). `Master` se asume existente en el engine (L11, L60).
  - Volúmenes se aplican con `linear_to_db` y mute por bus (L99–113).
- **Conclusión:** hay **gestión programática de buses vía `AudioServer`**, pero **no hay un AudioBusLayout/Mixer persistido como recurso `.tres` versionado** en el proyecto Godot inspeccionado. Esto hace que la topología dependa del autoload y de que no exista un layout editable en el editor como fuente de verdad.

---

## 3) ¿Hay problemas de sonido duplicado o no detenido?

### Hallazgos concretos

1. **SFXManager no reproduce audio real (riesgo de “falso OK”)**  
   - `sfx_manager.gd` administra un pool lógico (`_voces`) y tiempos, pero no crea `AudioStreamPlayer*` ni llama `play()`/`stop()` sobre streams (búsqueda en `scripts/audio/*.gd`: solo comentario sobre `AudioStreamPlayer3D`, L188; sin players reales).  
   - **Impacto:** no hay sonido duplicado por este script, pero tampoco hay reproducción efectiva de SFX desde el manager; sistemas que crean players por su cuenta (p.ej. `crafting_feedback.gd`, `tool_feedback.gd`, `shaman_ui.gd`) no pasan por el pool de M43.

2. **Posibles duplicados en scripts fuera de `scripts/audio/` (gestión local de players)**  
   - `scripts/crafting/crafting_feedback.gd`: crea 4 `AudioStreamPlayer` y los añade al árbol (L21–24, L37–53) y llama `_tocar(player)` → `player.play()` (L108–111). No hay `stop()` antes de `play()` ni verificación de `playing`; si se dispara rápido, puede solapar o reiniciar según nodo/stream.  
   - `scripts/herramientas/tool_feedback.gd`: pool de `AudioStreamPlayer` (L15, L38) y `p.play()` (L108) sin evidencia en esta inspección de control de solapamiento/stop.  
   - `scripts/shaman/shaman_ui.gd`: crea player y `play()` (L12, L81, L281) sin `stop()` previo visible en la búsqueda.  
   - **Riesgo:** solapamiento/duplicación audible depende del uso; no se observa un controlador central que evite disparos simultáneos de estos players locales.

3. **Reproducción no detenida / lifecycle en narrativa**  
   - `narrative_sound.gd` hace `await get_tree().create_timer(duration).timeout` en `play_narrative_silence` (L167–173). No se guarda referencia al timer para cancelar si se inicia otro silencio o cambia el estado; en ráfagas podría haber esperas superpuestas lógicas (las señales `silencio_started` se emiten cada vez). No controla players reales, pero el estado de “silencio” puede ser ambiguo.

4. **Conexiones de señales (duplicados potenciales)**  
   - `sfx_manager.gd` usa `_conectar_si` con `has_signal` y `is_connected` (L247–252) — **buena práctica**.  
   - `narrative_sound.gd` conecta señales con guardas `is_connected` (L52–62).  
   - Como son autoloads, el riesgo de reconexión duplicada en runtime normal es bajo; seguir este patrón en cualquier reconexión dinámica.

5. **Music/Ambient/Feedback no detienen audio real**  
   - No hay `stop()`/players en estos directores; la detención real dependerá de la integración futura. No se detecta “sonido no detenido” dentro de estos scripts porque no inician reproducción de streams.

**Conclusión (3):** No se evidencia un bug activo de *loop infinito* o *AudioStreamPlayer huérfano* dentro de `scripts/audio/` porque la reproducción real está mayormente ausente/delegada. Los riesgos principales son: **(a)** SFXManager no reproduce audio real pese a modelar voces; **(b)** scripts de gameplay crean y reproducen `AudioStreamPlayer` locales sin coordinación central ni stops/guards evidentes (posible solapamiento); **(c)** silencio narrativo con `await` sin cancelación de timers previos.

---

## 4) ¿Hay validación de assets de audio?

- **Validación de existencia de JSON de configuración:** los directores verifican `FileAccess.file_exists(...)` y emiten `push_warning` si falta el archivo (`music_director.gd` L27–29; `ambient_director.gd` L27–29; `feedback_director.gd` L29–31, L38–39; `narrative_sound.gd` L74–76; `sfx_manager.gd` L85–87, L94–95, L102–104).
- **Validación de formato:** parsean con `JSON.parse_string` y comprueban `typeof(...) == TYPE_DICTIONARY` antes de usar (mismos archivos). Esto evita crashes por JSON inválido en el nivel básico.
- **No hay validación de assets de audio binarios (`.ogg/.wav/.mp3`) ni de rutas `res://` de streams:** los JSON inspeccionados (`sfx_surfaces.json`, `music_context_matrix.json`) contienen **identificadores/variaciones/capas** (p.ej. `golpe_*`, `base_*`, `tiempo_*`, `evento_*`), no rutas a archivos de audio. No se observa `ResourceLoader.exists`, `load/preload` de streams, ni verificación de que cada capa/variación mapee a un recurso reproducible.
- **Pruebas:** existen tests (`test_sfx_m43.gd`, `test_musica_m41.gd`, `test_ambient_m42.gd`, `test_audio_config.gd`, etc.) que ejercitan lógica; no sustituyen validación runtime/editor de assets faltantes.

**Conclusión (4):** hay validación defensiva de **config JSON** (existencia + tipo), pero **no hay validación de recursos de audio reales** ni de resolución completa “id/capa → stream existente”. Si se integran samples, los fallos podrían manifestarse tarde (en reproducción).

---

## 5) Dos mejoras sugeridas

### Mejora 1 — Unificar reproducción real bajo un backend de `AudioStreamPlayer` conectado al pool de M43
**Problema:** `SFXManager` modela prioridades, límites y ducking, pero no reproduce audio; otros scripts instancian players locales sin pasar por políticas comunes.  
**Acción propuesta:**
- Implementar un backend en `sfx_manager.gd` (o servicio hermano) que asigne `AudioStreamPlayer`/`AudioStreamPlayer3D` desde un pool real (o nodos hijos creados bajo el autoload) y los conecte al bus `SFX` (`AudioConfig` ya gestiona buses).
- Resolver `efecto/superficie/variación → res://...` con un registro validado (ver Mejora 2) y llamar `play()`/`stop()` en el slot; conectar `finished` para liberar la voz lógica inmediatamente (además de la purga por tiempo, L355–358).
- Migrar progresivamente `crafting_feedback.gd`, `tool_feedback.gd`, `shaman_ui.gd` a la API de M43 o a un helper común para evitar solapamiento no controlado.
- **Beneficio:** evita duplicados/solapamientos descoordinados, aplica límites/prioridades/ducking de forma efectiva y hace observable la reproducción.

### Mejora 2 — Validación de assets + fallback explícito y AudioBusLayout versionado
**Problema:** falta `default_bus_layout.tres`; los JSON no referencian streams; no se valida que las capas/variaciones tengan recursos reproducibles.  
**Acción propuesta:**
- Añadir `res://default_bus_layout.tres` (o layout equivalente) alineado con los buses de M91 (`Master/Music/SFX/Ambient/Voice/UI/Cinematic`) para que el editor y el runtime compartan una fuente de verdad; mantener `_crear_buses()` como red de seguridad.
- Incorporar un validador (runtime en debug o test headless) que: (a) verifique existencia de cada JSON de `data/audio/`; (b) compruebe que cada id/capa/variación referenciada tenga stream resoluble (`ResourceLoader.exists` o mapa explícito); (c) reporte faltantes con `push_warning`/log estructurado sin romper el juego (fallback silencioso controlado).
- **Beneficio:** detección temprana de assets faltantes, configuración de buses reproducible en editor/CI y menor riesgo de fallos tardíos en integración de audio real.

---

## Conclusión final

El sistema de audio de Isla Ancestral tiene una **base arquitectónica clara**: autoloads separados por dominio (config, SFX, música, ambiente, feedback, narrativa), buses gestionados en runtime por `AudioConfig` (`Master` + 6 hijos), persistencia de opciones/volúmenes y datos JSON para contexto/catálogos. Sin embargo, la **capa de reproducción real está incompleta**: `MusicDirector`, `AmbientDirector`, `FeedbackDirector` y `SFXManager` operan principalmente como estado/señales o pool lógico (sin `AudioStreamPlayer`/streams en `scripts/audio/`), y no existe `default_bus_layout.tres` versionado. No se detectan sonidos duplicados/no detenidos originados dentro de `scripts/audio/` por reproducción directa, pero sí **riesgos de solapamiento** en scripts de gameplay que crean players locales y **falta de validación de assets de audio reales**. Priorizar la integración de un backend de reproducción unificado y un pipeline de validación de assets/bus layout cerraría la brecha entre el diseño lógico y el audio audible en juego.

---

## Archivos y líneas clave revisadas

| Archivo | Líneas/referencias relevantes |
|---|---|
| `game/isla-ancestral/project.godot` | `[autoload]` audio: 97, 109–113 |
| `game/isla-ancestral/scripts/audio/audio_config_service.gd` | Buses/hijos 33; creación/enrutado 59–71; aplicar volumen/mute 99–113; set/get volumen 118–165; mute 168–174; opciones 193–255; persistencia 266–309 |
| `game/isla-ancestral/scripts/audio/sfx_manager.gd` | Pool 24/prealloc 43,74; datos 44–46,84–108; categorías/límites 54–62,360–366; API 177–201,313–340; ducking 220–233,285–308; conexiones defensivas 238–252; nota sin `AudioStreamPlayer3D` real 188 |
| `game/isla-ancestral/scripts/audio/music_director.gd` | Matriz 15,27–33; contexto/tema 44–74; variación/shuffle 87–95; stubs/sin players (archivo completo) |
| `game/isla-ancestral/scripts/audio/ambient_director.gd` | Banco 14,26–32; emisión ambiente 41–66; sin players |
| `game/isla-ancestral/scripts/audio/feedback_director.gd` | Recetas/blacklist 13–14,29–42; `sensacion` 53–67; sin players |
| `game/isla-ancestral/scripts/audio/narrative_sound.gd` | Señales 22–25; conexiones EventBus/Travel 47–62; reproducción delegada a M41 113–114,172–173; silencio con await 167–173 |
| `game/isla-ancestral/scripts/audio/shuffle_sampler.gd` | PRNG/shuffle 19–57 |
| `game/isla-ancestral/scripts/audio/dynamic_range_manager.gd` | Presets/compresor vía `AudioServer` (stateless) |
| `game/isla-ancestral/scripts/audio/compression_manager.gd` | `AudioEffectLimiter` (stateless) |
| `game/isla-ancestral/scripts/audio/output_device_manager.gd` | `get_output_device_list/get/set_output_device` |
| `game/isla-ancestral/scripts/ui/layers/settings_audio_layer.gd` | UI sliders/mute/opciones → `AudioConfig` (archivo completo) |
| `game/isla-ancestral/data/audio/` | `sfx_surfaces.json`, `sfx_catalog.json`, `sfx_tones.json`, `music_context_matrix.json`, `ambient_biome_bank.json`, `feedback_recetas.json`, `feedback_blacklist.json`, `narrative_sound.json` |
| `game/isla-ancestral/` (raíz) | **No existe** `default_bus_layout.tres` (verificado) |
| Referencias runtime externas (muestra) | `scripts/crafting/crafting_feedback.gd` (AudioStreamPlayer + `play`, L21–24,37–53,108–111); `scripts/herramientas/tool_feedback.gd` (pool + `play`, L15,38,108); `scripts/shaman/shaman_ui.gd` (player + `play`, L12,81,281) |