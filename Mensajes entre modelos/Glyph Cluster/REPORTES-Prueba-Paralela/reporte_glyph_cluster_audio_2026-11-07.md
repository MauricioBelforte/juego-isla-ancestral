# Reporte de revisión — Sistema de audio (`game/isla-ancestral/scripts/`)

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code (Agent Manager)  
**Fecha:** 2026-11-07  
**Alcance revisado:** `game/isla-ancestral/scripts/audio/`, `scripts/legal/audio_*`, referencias en `project.godot`, `scripts/ui/layers/settings_audio_layer.gd`, y usos de `AudioStreamPlayer`/`AudioServer` en el proyecto.

---

## 1) Gestión de audio (SFX, música, ambiente)

### Configuración central y buses (autoload `AudioConfig`)
- **Archivo:** `game/isla-ancestral/scripts/audio/audio_config_service.gd`
- Crea en runtime los buses hijo (`Music`, `SFX`, `Ambient`, `Voice`, `UI`, `Cinematic`) si no existen y los enruta a `Master` (`:33`, `:59-71`).
- Aplica volúmenes/mute mediante `AudioServer` (lineal → dB), con coherencia con persistencia (`:99-113`, `:118-179`).
- Persiste configuración vía `DataStore` (sección `audio`, incluye volúmenes, mutes y opciones) y expone señales `volumen_cambiado`/`mute_cambiado` (`:40-41`, `:260-309`).
- Incluye API de porcentaje 0–100 para sliders de UI (`:133-166`) y opciones persistidas (`rango_dinamico`, `compresion`, `dispositivo_salida`) con aplicación al motor (`:186-256`).

### SFX (autoload `SFXManager`)
- **Archivo:** `game/isla-ancestral/scripts/audio/sfx_manager.gd`
- Gestiona un **pool lógico** de 24 voces prealocadas con prioridades, límites por tipo/categoría, pausa/reanudación y ducking de diálogo (`:43-76`, `:175-201`, `:220-233`, `:285-390`).
- Carga catálogos JSON: `res://data/audio/sfx_surfaces.json`, `sfx_tones.json`, `sfx_catalog.json` (`:44-47`, `:84-107`).
- API pública: `reproducir(efecto, pos, prioridad, categoria)`, `reproducir_superficie(...)`, `reproducir_localizado(...)`, `configurar_volumen(bus, db)`, `pausar()/reanudar()`, `ducking_dialogo()` (`:175-201`, `:285-341`).
- Se suscribe a eventos de otros sistemas (diálogos M21, logros, crafting, tienda) usando conexiones defensivas (`has_signal`/`get_node_or_null`) (`:220-281`).
- **Observación importante:** no crea/reproduce `AudioStreamPlayer` reales; registra voces en `_voces` y las depura por antigüedad (> 5 s) (`:350-358`, `:342-347`). La reproducción real queda pendiente o delegada.

### Música (autoload `MusicDirector`)
- **Archivo:** `game/isla-ancestral/scripts/audio/music_director.gd`
- Selecciona tema por contexto (zona/hora/clima) desde `res://data/audio/music_context_matrix.json` y emite `tema_cambio` (`:13-75`).
- Gestiona variaciones con `ShuffleSampler` para evitar repetición consecutiva (`:86-101`; `shuffle_sampler.gd:9-57`).
- Expone `sting()`, `pausar()/reanudar()`; `sting()` es stub (`:77-84`). No se observa asignación/reproducción real de streams en este archivo.

### Ambiente (autoload `AmbientDirector`)
- **Archivo:** `game/isla-ancestral/scripts/audio/ambient_director.gd`
- Selecciona banco/capas por bioma, clima y fase desde `res://data/audio/ambient_biome_bank.json`; emite `ambiente_cambiado` (`:12-66`).
- `pausar()/reanudar()` están vacíos (`:68-72`). No se observa reproducción real de `AudioStreamPlayer` en este archivo.

### Feedback/ASMR y narrativa
- **Feedback:** `game/isla-ancestral/scripts/audio/feedback_director.gd` aplica recetas contextuales, blacklist anti-agresión y emite `feedback_aplicado` (`:13-83`). `key_sync/pausar/reanudar` son stubs (`:75-83`).
- **Narrativa:** `game/isla-ancestral/scripts/audio/narrative_sound.gd` gestiona momentos/leitmotifs narrativos desde `res://data/audio/narrative_sound.json`, emite señales y se integra con `EventBus`/`TravelService` (`:20-243`). La reproducción real se delega conceptualmente a otros directores (señales/estado).

### Registro de autoloads
- **Archivo:** `game/isla-ancestral/project.godot`
- Autoloads de audio registrados: `AudioConfig`, `MusicDirector`, `AmbientDirector`, `SFXManager`, `FeedbackDirector`, `NarrativeSound` (`:88`, `:101-105`).

---

## 2) AudioMixer / bus de audio configurado

- **No se encontró un recurso `AudioBusLayout` (`default_bus_layout.tres` u otros `*.tres/*bus*layout*`) versionado en `game/isla-ancestral/`**. La búsqueda de archivos `*bus*layout*` solo arrojó configs internas de `.godot/editor` no relacionadas y `data/legal/audio_licenses.json`.
- **`project.godot` no define `audio/bus_layout`** (no aparece en el archivo revisado).
- **La topología de buses se configura por código en runtime** mediante `AudioServer` en `audio_config_service.gd` (`:59-71`, `:99-113`).  
  - Esto garantiza que los buses existan y estén enrutados, pero la configuración no está versionada como asset editable en el editor, lo que reduce trazabilidad/auditoría y puede dificultar ajustes finos (efectos por bus, layout visual) y consistencia entre entornos.

---

## 3) Sonido duplicado o no detenido

### Hallazgos / riesgos

1. **SFXManager usa un pool lógico sin players reales ni ciclo `finished`/`stop()` de reproducción real** (`sfx_manager.gd:350-390`, `:342-347`).  
   - Las voces se consideran activas por tiempo (> 5 s) y se purgan por antigüedad. Si se conecta reproducción real con `AudioStreamPlayer`, este modelo puede desincronizar estado y dejar sonidos sonando o “fantasmas” lógicos.
2. **Ducking de SFX muta el bus `SFX` directamente** (`sfx_manager.gd:285-308`, `:296-299`).  
   - Recalcula la base desde `AudioConfig` al aplicar/restaurar (mitiga parte del problema), pero al cambiar el bus fuera del flujo normal de `AudioConfig` puede generar comportamientos confusos si otros sistemas ajustan `SFX` simultáneamente.
3. **Directores de música/ambiente/feedback/narrativa están parcialmente en modo señal/estado (stubs)**:  
   - `music_director.gd:77-84` (`sting` stub, pausa lógica).  
   - `ambient_director.gd:68-72` (pausa/reanudación vacías).  
   - `feedback_director.gd:75-83` (key_sync/pausa stubs).  
   - Esto reduce duplicados actuales, pero indica que la reproducción real está incompleta o distribuida.
4. **Reproducción de audio dispersa fuera de `scripts/audio/` (riesgo de solapamiento/no coordinación)**. Ejemplos detectados:  
   - `scripts/crafting/crafting_feedback.gd:21-55,108-111` (crea y reproduce `AudioStreamPlayer`).  
   - `scripts/ui/services/ui_feedback.gd:17-23,70-81` (players propios; hace `stop()` antes de `play()`).  
   - `scripts/dialogos/ui/dialogue_ui.gd:90,206-209,633` (tipeo).  
   - `scripts/enchantment/shaman_ui.gd:12,81-84,281`.  
   - `scripts/tools/tool_feedback.gd` también usa pool de `AudioStreamPlayer`.  
   Estos casos no prueban por sí solos duplicación, pero aumentan la probabilidad de sonidos no coordinados con buses, ducking, pausa global o límites de `SFXManager`.

### Conclusión
- **No se confirma un bug activo de duplicación/no-detención en los directores revisados**, pero sí hay **riesgos estructurales** (SFX lógico sin players reales, ducking directo sobre bus, reproducción dispersa en UI/gameplay).

---

## 4) Validación de assets de audio

### Existe (legal/metadatos)
- **`scripts/legal/audio_license_validator.gd`** valida el catálogo JSON de licencias: IDs únicos, licencia presente, atribución obligatoria para `CC-BY`, políticas presentes (`:12-38`).
- **`scripts/legal/audio_legal_manager.gd`** carga `res://data/legal/audio_licenses.json`, parsea tracks/licencias/créditos y expone validaciones y utilidades (`:19-22`, `:35-169`, `:184-216`).  
- Dato detectado: `game/isla-ancestral/data/legal/audio_licenses.json`.

### Existe (validación parcial de datos JSON en runtime)
- Los directores/managers de audio verifican existencia de JSON con `FileAccess.file_exists()` y emiten `push_warning()` si faltan:
  - `sfx_manager.gd:85-107` (`sfx_surfaces/tones/catalog`)
  - `music_director.gd:28-33` (`music_context_matrix.json`)
  - `ambient_director.gd:27-32` (`ambient_biome_bank.json`)
  - `feedback_director.gd:29-42` (`feedback_recetas.json`, `feedback_blacklist.json`)
  - `narrative_sound.gd:74-79` (`narrative_sound.json`)

### No observado (validación técnica de assets reales)
- No se encontró en `scripts/audio/` una validación de **archivos de audio reales** (`.ogg/.wav/.mp3`), existencia/carga de `AudioStream` (`ResourceLoader.exists/load`), rutas inválidas, streams nulos, o coherencia entre catálogo lógico (variaciones/nombres) y assets físicos.  
- La validación actual cubre **legalidad/metadatos** y **presencia de JSON**, pero no la integridad técnica de los assets reproducibles.

---

## 5) 2 mejoras concretas

1. **Unificar la reproducción real de audio en `scripts/audio/` con ciclo de vida explícito (evitar duplicados/no-detención).**  
   - Implementar en `SFXManager`/directores la reproducción real con `AudioStreamPlayer`/`AudioStreamPlayer2D/3D` según el caso.  
   - Conectar `finished` para liberar voz/estado al terminar; ejecutar `stop()` en cortes por prioridad, `pausar()/reanudar()`, transiciones y cambios de contexto.  
   - Refactorizar consumidores con players propios (`scripts/crafting/crafting_feedback.gd:21-55,108-111`, `scripts/ui/services/ui_feedback.gd:17-23,70-81`, `scripts/dialogos/ui/dialogue_ui.gd:206-209,633`, `scripts/enchantment/shaman_ui.gd:81-84,281`, `scripts/tools/tool_feedback.gd`) para usar una API común (p. ej. `SFXManager` o un servicio de feedback/UI audio) alineada con buses, ducking y pausa global.

2. **Formalizar el bus layout como asset versionado + validador técnico de assets de audio.**  
   - Crear/versionar un `AudioBusLayout` (p. ej. `default_bus_layout.tres`) y configurarlo en `project.godot`; mantener `audio_config_service.gd` como verificación/reparación en runtime, no como única fuente de verdad (`audio_config_service.gd:59-71`).  
   - Añadir una herramienta/test (editor o headless) que valide los catálogos JSON de audio contra assets reales: `ResourceLoader.exists`/carga de streams, formatos soportados, bus destino válido, rutas/nombres coherentes y streams no nulos. Complementar (no reemplazar) la validación legal existente en `scripts/legal/audio_license_validator.gd` (`:12-38`).

---

## Archivos clave citados
- `game/isla-ancestral/scripts/audio/audio_config_service.gd`
- `game/isla-ancestral/scripts/audio/sfx_manager.gd`
- `game/isla-ancestral/scripts/audio/music_director.gd`
- `game/isla-ancestral/scripts/audio/ambient_director.gd`
- `game/isla-ancestral/scripts/audio/feedback_director.gd`
- `game/isla-ancestral/scripts/audio/narrative_sound.gd`
- `game/isla-ancestral/scripts/audio/shuffle_sampler.gd`
- `game/isla-ancestral/scripts/legal/audio_license_validator.gd`
- `game/isla-ancestral/scripts/legal/audio_legal_manager.gd`
- `game/isla-ancestral/project.godot` (autoloads: `:88,101-105`)
- Referencias de reproducción dispersa: `scripts/crafting/crafting_feedback.gd`, `scripts/ui/services/ui_feedback.gd`, `scripts/dialogos/ui/dialogue_ui.gd`, `scripts/enchantment/shaman_ui.gd`, `scripts/tools/tool_feedback.gd`
