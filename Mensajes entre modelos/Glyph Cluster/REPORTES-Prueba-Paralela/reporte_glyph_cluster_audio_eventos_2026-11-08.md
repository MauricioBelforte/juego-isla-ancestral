# Reporte — Audio en eventos de gameplay (SFX, música de fondo, audio espacial)

**Modelo:** Glyph Cluster  
**Fecha:** 2026-11-08  
**Alcance:** `game/isla-ancestral/scripts/` (búsqueda de `.gd` relacionados con audio/eventos de gameplay)  
**Objetivo:** analizar cómo se dispara audio desde eventos, riesgo de sonido duplicado/no detenido, validación de assets antes de reproducir, estado del audio espacial y proponer 2 mejoras.

## Archivos relevantes revisados

- `game/isla-ancestral/scripts/audio/sfx_manager.gd` (autoload `SFXManager`, registrado en `project.godot:103`)
- `game/isla-ancestral/scripts/audio/music_director.gd` (autoload `MusicDirector`, `project.godot:101`)
- `game/isla-ancestral/scripts/audio/ambient_director.gd` (autoload `AmbientDirector`, `project.godot:102`)
- `game/isla-ancestral/scripts/audio/feedback_director.gd` (autoload `FeedbackDirector`, `project.godot:104`)
- `game/isla-ancestral/scripts/audio/narrative_sound.gd` (autoload/nodo de narrativa sonora)
- `game/isla-ancestral/scripts/audio/audio_config_service.gd` (configuración de buses/volumen; contexto de ruteo)
- `game/isla-ancestral/scripts/tools/tool_feedback.gd` (feedback de herramientas con audio/partículas propio)
- `game/isla-ancestral/scripts/dialogos/ui/dialogue_ui.gd:426,628-633` (sonido de tipeo local)
- Datos: `game/isla-ancestral/data/audio/*.json` (`sfx_surfaces.json`, `sfx_catalog.json`, `sfx_tones.json`, `music_context_matrix.json`, `ambient_biome_bank.json`, `feedback_recetas.json`, `feedback_blacklist.json`, `narrative_sound.json`)
- Registro de autoloads: `game/isla-ancestral/project.godot:19,101-104`

> Nota: la búsqueda encontró llamadas directas a la API de los directores principalmente en tests (`scripts/audio/test_*`) y en el propio `SFXManager`; fuera de `scripts/audio/` se observaron rutas de audio separadas (`ToolFeedback`, tipeo de diálogo) más que invocaciones a `SFXManager`/`MusicDirector`/`AmbientDirector`.

## 1) ¿Cómo se dispara el audio desde eventos de gameplay?

### SFX por eventos (canal central)
`SFXManager` funciona como autoload y se conecta en `_ready()` a diálogos y a autoloads de gameplay reales mediante `_conectar_dialogos()` y `_conectar_autoloads()` (`sfx_manager.gd:73-83,218-252`).

- **Diálogo (M21):** escucha `dialogue_started` / `dialogue_ended` de `/root/DialogueManager` sin modificar sus archivos, y aplica ducking de SFX (`sfx_manager.gd:220-233,285-289`).
- **Logros:** `Achievements.logro_desbloqueado` → `_on_logro_desbloqueado` → `reproducir("logro", null, 10)` (`sfx_manager.gd:239,254-256`).
- **Crafting:** `Crafting.crafting_completed/failed` → SFX `crafting_exito` (prio 6) / `error` (prio 10) (`sfx_manager.gd:240-241,258-264`).
- **Tienda:** `ShopManager.compra_exitosa/venta_exitosa/compra_rechazada/venta_rechazada` → `compra`/`venta`/`error` (`sfx_manager.gd:242-245,266-281`).

El patrón es defensivo: usa `get_node_or_null`, `has_signal` y evita doble conexión (`sfx_manager.gd:247-252`). Esto reduce acoplamiento y fallos de arranque si un módulo cambia señales.

### API pública para disparos directos/localizados
- `reproducir(efecto, pos, prioridad, categoria)` delega al motor lógico `_reproducir` (`sfx_manager.gd:185-190`).
- `reproducir_superficie()` elige variación por superficie desde `sfx_surfaces.json` (`sfx_manager.gd:177-183`).
- `reproducir_localizado(tipo, material, pos)` resuelve variaciones de catálogo/superficies y registra posición (`sfx_manager.gd:192-216`).

### Música, ambiente y narrativa (eventos/estado)
- `MusicDirector.play_contexto(entorno, hora, _estacion, clima)` selecciona tema por contexto y emite `tema_cambio` (`music_director.gd:44-74`). `sting()` es stub (`:76-78`).
- `AmbientDirector.set_bioma/set_estado_clima/set_fase` emite `ambiente_cambiado` con capas (`ambient_director.gd:41-66`).
- `NarrativeSound` se conecta a `EventBus` (`quest.prereq_met`, `travel.island_loaded`) y a `TravelService.travel_arrived` como respaldo; dispara momentos/leitmotifs por eventos narrativos (`narrative_sound.gd:44-71,134-144,201-243`). Indica que la reproducción real depende de que `MusicDirector` escuche señales (`:113-114`).

### Rutas paralelas de audio (fuera del canal central)
- `ToolFeedback` conecta callbacks del controlador de herramientas y reproduce audio sintetizado (`AudioStreamWAV` en runtime) con pool round-robin de `AudioStreamPlayer` (`tool_feedback.gd:14-17,29-42,49-71,102-108`). No usa `SFXManager`.
- `DialogueUI._reproducir_sonido_tipeo()` incrementa contador y reproduce un `AudioStreamPlayer` local si tiene stream, con protección básica `not playing` (`dialogue_ui.gd:426,628-633`).

## 2) ¿Hay sonido duplicado o no detenido?

### SFXManager (control lógico)
Hay mitigaciones **lógicas** contra saturación/duplicación excesiva:
- Pool preallocado a 24 voces (`MAX_VOCES = 24`, `sfx_manager.gd:43,74,350-383,385-390`).
- Límite de ≤ 6 simultáneos del mismo tipo (`MAX_MISMO_TIPO`, `_reproducir :360-361`).
- Límite de UI: máx. 2 simultáneos para categoría `ui` (`CATEGORIAS["ui"].max_simultaneos`, `:55,363-366`).
- Si el pool está lleno, reemplaza la voz de menor prioridad solo si la nueva es mayor; si no, descarta (`:372-383`).
- Purga voces vencidas (> 5 s) al reproducir y al reanudar (`:354-358,342-347`).
- `pausar()` evita emitir nuevas voces; `reanudar()` desplaza timestamps por el tiempo pausado para no “envejecer” voces durante pausa (`:322-340`).

**Pero:** `_reproducir` no instancia ni controla nodos `AudioStreamPlayer/2D/3D`, no asigna `stream`, no llama `play()` ni `stop()`. Solo registra metadatos (`tipo`, `prioridad`, `categoria`, `tiempo_ms`, `pos`) en `_voces` (`:350-383`). Por tanto, el “no detenido”/duplicación **real de reproducción audible** no puede gestionarse aquí mientras no exista reproducción real conectada al pool lógico.

### Música/Ambiente/Feedback (directores de estado)
- `MusicDirector` evita cambio redundante si `tema == tema_actual` (`music_director.gd:69-70`), pero no reproduce audio ni gestiona crossfade real; `pausar/reanudar` solo marcan `_pausado` (`:80-84`).
- `AmbientDirector` reemite ambiente al cambiar bioma/clima/fase (`ambient_director.gd:41-66`) sin deduplicación por estado equivalente.
- `FeedbackDirector.sensacion()` emite `feedback_aplicado` salvo blacklist/acción inexistente (`feedback_director.gd:53-67`), sin reproducción ni control de parada.

### Rutas paralelas
- `ToolFeedback` usa pools round-robin de audio/partículas y siempre hace `p.play()` al asignar stream (`tool_feedback.gd:102-108,140-147`). Si se reutiliza un reproductor ocupado, puede cortarse/solaparse según estado del player; no hay comprobación de prioridad ni detención explícita por evento.
- `DialogueUI` solo reproduce tipeo si `not _sonido_tipeo.playing` (`dialogue_ui.gd:632`), lo que evita solape inmediato del mismo player, pero depende de tener `stream` asignado.

## 3) ¿Hay validación de assets de audio antes de reproducir?

### Datos JSON (sí, en carga)
Los managers validan existencia de archivos de datos antes de parsear:
- `SFXManager`: `sfx_surfaces.json`, `sfx_tones.json`, `sfx_catalog.json` (`sfx_manager.gd:84-107`).
- `AmbientDirector`: `ambient_biome_bank.json` (`ambient_director.gd:26-33`).
- `FeedbackDirector`: recetas y blacklist (`feedback_director.gd:28-42`).
- `MusicDirector`: matriz (`music_director.gd:27-33`).
- `NarrativeSound`: `narrative_sound.json` (`narrative_sound.gd:73-79`).

Si faltan, emiten `push_warning` y degradan (diccionarios vacíos / sin match).

### Assets de audio reales (no se observa validación de streams/rutas)
- Los JSON de audio contienen IDs/variaciones/conteos/reglas (p. ej. `sfx_surfaces.json` tiene `golpe_madera_1..4`; `sfx_catalog.json` define conteos y distancias 3D), pero **no referencias a rutas `.ogg/.wav/.mp3`**.
- No se encontraron referencias a `res://assets/audio`, `.ogg/.wav/.mp3` en `scripts/audio` o `data/audio` durante la inspección.
- `SFXManager`/`MusicDirector`/`AmbientDirector`/`FeedbackDirector` no cargan `AudioStream` ni validan `ResourceLoader.exists()`/`FileAccess.file_exists()` de assets de sonido antes de reproducir, porque actualmente operan con metadatos/eventos lógicos.
- `ToolFeedback` genera `AudioStreamWAV` en runtime (síntesis), por lo que no depende de assets externos; `DialogueUI` solo reproduce si `stream != null` (`dialogue_ui.gd:632`).

**Conclusión parcial:** hay validación de presencia/formato básico de datos de catálogo al cargar, pero **no hay validación de assets de audio reproducibles** en el flujo central porque el flujo central aún no reproduce streams reales.

## 4) ¿Hay audio espacial configurado correctamente?

**No está completamente implementado/configurado en el canal central.**

- `SFXManager.reproducir()` acepta `pos` y lo guarda en la voz lógica; el comentario indica que el 2º argumento puede ser posición y que la emisión 3D queda pendiente de `AudioStreamPlayer3D` (`sfx_manager.gd:186-190,370,381`). No se crean `AudioStreamPlayer3D`/`2D`.
- `reproducir_localizado()` recibe `Vector3` y lo pasa a `_reproducir` (`:195-201`), pero el resultado es solo registro lógico.
- `sfx_catalog.json` declara `distancias_3d_m` (`paso` 15 m, `romper` 20 m, `mundo` 30 m, `ui_2d`/`dialogo_2d` 0), lo que sugiere intención de espacialización, pero no hay código que aplique esas distancias a atenuación/max distance/unit size de un player 3D.
- `ToolFeedback` reproduce con `AudioStreamPlayer` (no espacial) y posiciona partículas en mundo (`tool_feedback.gd:38-41,102-108,140-147`).
- `NarrativeSound`/`MusicDirector`/`AmbientDirector` son lógicos/señales; no hay reproducción espacial.
- Buses: no se encontró `default_bus_layout.tres`/`audio_bus_layout.tres`; `AudioConfigService` crea buses en runtime y gestiona volumen/mute (`audio_config_service.gd:59-114` aprox., según estructura). Esto permite ruteo, pero no prueba por sí solo una configuración espacial correcta (atenuación 3D, panning, buses por tipo espacial).

## 5) Sugerencias de mejora (2)

1. **Implementar reproducción real en `SFXManager` con separación 2D/3D y validación de stream.**  
   - Crear/gestionar un pool real de `AudioStreamPlayer` (UI/2D) y `AudioStreamPlayer3D` (eventos con `pos` válido), asignando `bus` (`SFX`, `UI` según categoría) y aplicando `distancias_3d_m` del catálogo.  
   - Antes de `play()`, resolver el asset (ID → ruta/`AudioStream`) y validar con `ResourceLoader.exists()`/carga no nula; si falla, registrar `push_warning` con `efecto/material/categoría` y devolver `false` sin consumir voz útil.  
   - Al reemplazar/purgar una voz, llamar `stop()` sobre el player asociado para evitar audio huérfano/no detenido. **Archivos:** `sfx_manager.gd`, `data/audio/sfx_catalog.json` (+ mapeo de assets).

2. **Unificar disparadores de gameplay al canal de eventos y evitar rutas paralelas no coordinadas.**  
   - Migrar `ToolFeedback` y el sonido de tipeo de `DialogueUI` para usar `SFXManager`/directores (o al menos un servicio común) con prioridades/categorías/ducking consistentes.  
   - Añadir deduplicación/antispam contextual para eventos repetibles (p. ej. golpes rápidos, pasos, UI): ventana mínima por `tipo+origen` o reutilización de voz activa cuando corresponda, respetando `MAX_MISMO_TIPO` y la semántica de prioridad.  
   - Exponer telemetría de depuración (voz lógica ↔ player real, motivo de descarte, asset faltante) para QA. **Archivos:** `tools/tool_feedback.gd`, `dialogos/ui/dialogue_ui.gd`, `audio/sfx_manager.gd`.

## Conclusión final

El proyecto tiene una base sólida de **orquestación lógica de audio por eventos**: `SFXManager` se conecta de forma defensiva a eventos de gameplay (logros, crafting, tienda, diálogo), maneja prioridades, límites por tipo/categoría, pausa, purga temporal y ducking; `NarrativeSound` integra señales de narrativa/viaje; y existen datos JSON de superficies/tonos/catálogos/recetas. Sin embargo, en el estado revisado el canal central es mayormente **lógico/de metadatos**: no reproduce streams reales, no detiene players reales, no valida assets de audio reproducibles (solo existencia de JSON de datos) y **no configura audio espacial real** aunque acepta posiciones y declara distancias 3D en datos. Además coexisten rutas paralelas (`ToolFeedback`, tipeo de diálogo) que pueden fragmentar prioridades, ducking y control de duplicados. Priorizar la conexión “voz lógica ↔ player real 2D/3D + validación de assets + stop/purge real” y la unificación de disparadores daría coherencia audible y controlable al sistema.