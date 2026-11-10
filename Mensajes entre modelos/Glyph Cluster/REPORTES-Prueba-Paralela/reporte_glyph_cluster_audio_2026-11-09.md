# Reporte de análisis: sistema de audio (SFX, música, ambiente)

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code / Vercel AI Gateway  
**Fecha:** 2026-11-09  
**Alcance:** `game/isla-ancestral/scripts/audio/`, configuración de autoloads en `game/isla-ancestral/project.godot`, datos en `game/isla-ancestral/data/audio/`, y referencias de uso de audio en scripts del juego.

---

## Resumen ejecutivo

El proyecto implementa una arquitectura de audio **data-driven** con autoloads especializados (M41 música, M42 ambiente, M43 SFX, M44 feedback, M91 configuración, M150 sonido narrativo). La lógica de selección, prioridades, categorías y reglas está bien estructurada y respaldada por JSON. Sin embargo, en el estado revisado **no hay reproducción real de streams de audio** en los directores principales: operan como orquestadores de estado/señales/catálogos. Además, **no existe `default_bus_layout.tres`** en el repositorio (no se detectó ningún `.tres/.res` de bus layout) y no se encontraron assets de audio (`.wav/.ogg/.mp3`) bajo `game/isla-ancestral/`. La configuración de buses se crea/ajusta en runtime por `AudioConfig`.

---

## 1) ¿Cómo se gestiona el audio (SFX, música, ambiente)?

### 1.1 Autoloads y responsabilidades

Configurados en `game/isla-ancestral/project.godot` (sección `[autoload]`):

| Autoload | Script | Rol |
|---|---|---|
| `AudioConfig` | `scripts/audio/audio_config_service.gd` | Buses, volúmenes/mute, persistencia, opciones (M91). |
| `MusicDirector` | `scripts/audio/music_director.gd` | Selección de tema por contexto (zona/hora/estación/clima), variaciones shuffle, señales (M41). |
| `AmbientDirector` | `scripts/audio/ambient_director.gd` | Selección de banco/capas por bioma, clima y fase; emite `ambiente_cambiado` (M42). |
| `SFXManager` | `scripts/audio/sfx_manager.gd` | Pool lógico de 24 voces, prioridades/categorías, límites, catálogo/tonos/superficies, ducking, API pública (M43). |
| `FeedbackDirector` | `scripts/audio/feedback_director.gd` | Recetas de feedback/ASMR por acción, precedencia contextual, blacklist (M44). |
| `NarrativeSound` | `scripts/audio/narrative_sound.gd` | Momentos narrativos, leitmotifs, triggers por eventos (M150). |

### 1.2 Música (M41)

- **Archivo:** `game/isla-ancestral/scripts/audio/music_director.gd`
- **Datos:** `res://data/audio/music_context_matrix.json` (`RUTA_MATRIZ`, línea 15).
- **Lógica:** `play_contexto(entorno, hora, estacion, clima)` (líneas 44–51) resuelve tema base y variantes (`*_noche`, `*_lluvia`) con fallback a `aurora_dia` (línea 58). `_cambiar_tema()` evita reemitir si el tema no cambia (líneas 65–74) y emite `tema_cambio(tema, capas)`.
- **Variaciones:** usa `ShuffleSampler` por tema (líneas 87–95) con semilla derivada de `_hash(tema)` (líneas 97–101).
- **Reproducción real:** `sting()` es stub (líneas 76–78); `pausar()/reanudar()` solo marcan estado (líneas 80–84). No se crean `AudioStreamPlayer` ni se asignan streams en este script.

### 1.3 Ambiente (M42)

- **Archivo:** `game/isla-ancestral/scripts/audio/ambient_director.gd`
- **Datos:** `res://data/audio/ambient_biome_bank.json` (`RUTA_BANCO`, línea 14).
- **Lógica:** `set_bioma()`, `set_estado_clima()`, `set_fase()` actualizan estado y llaman `_emitir_ambiente()` (líneas 41–66), que compone capas base + capa de clima y emite `ambiente_cambiado`.
- **Reproducción real:** no instancia reproductores ni reproduce audio; `pausar()/reanudar()` son stubs (líneas 68–72).

### 1.4 SFX (M43)

- **Archivo:** `game/isla-ancestral/scripts/audio/sfx_manager.gd`
- **Datos:** `sfx_surfaces.json`, `sfx_tones.json`, `sfx_catalog.json` (`data/audio/`, líneas 44–46, carga 84–107).
- **Gestión:** pool lógico prealocado a 24 slots (`MAX_VOCES`, `_voces.resize`, líneas 43, 74). `_reproducir()` (líneas 350–383):
  - respeta pausa (`_pausado`);
  - purga lógica de voces > 5 s;
  - limita ≤ 6 del mismo tipo (`MAX_MISMO_TIPO`, líneas 60–62, 359–361);
  - limita UI a 2 simultáneos por categoría (líneas 54–59, 362–366);
  - asigna slot libre o reemplaza la voz de menor prioridad si la nueva es mayor (límite duro, sin crecimiento).
- **API:** `reproducir_superficie`, `reproducir(efecto,pos,prioridad,categoria)`, `reproducir_localizado`, `tono/tonos_disponibles`, `configurar_volumen`, `pausar/reanudar`, `ducking_dialogo` (líneas 175–341, 392–400).
- **Integraciones defensivas:** conexión opcional a `DialogueManager` (ducking, líneas 220–233) y a autoloads reales (`Achievements`, `Crafting`, `ShopManager`) mediante `_conectar_si()` con `get_node_or_null` + `has_signal` (líneas 238–281).
- **Reproducción real:** el diseño prevé emisión 3D futura (`AudioStreamPlayer3D`, comentario línea 188), pero el código actual **no crea nodos de audio ni reproduce streams**; gestiona metadatos/slots/decisiones.

### 1.5 Feedback/ASMR (M44) y narrativa (M150)

- **M44:** `feedback_director.gd` carga `feedback_recetas.json` y `feedback_blacklist.json`, filtra acciones prohibidas, aplica precedencia contextual (`interior` agrega capa) y emite `feedback_aplicado`. No reproduce audio.
- **M150:** `narrative_sound.gd` carga `narrative_sound.json`, gestiona leitmotifs/momentos/silencio y se conecta a `EventBus`/`TravelService` de forma defensiva. Comentarios explícitos indican que la reproducción real depende de M41/MusicDirector (líneas 113–114, 172).

### 1.6 Uso fuera de `scripts/audio/`

Se observan reproductores locales en otros módulos (no centralizados en SFXManager), p. ej.:
- `scripts/crafting/crafting_feedback.gd`: crea 4 `AudioStreamPlayer` y reproduce con `play()` (líneas ~21–53, 108–111).
- `scripts/enchantment/shaman_ui.gd`: crea `AudioStreamPlayer` y reproduce (líneas ~12, 81, 280–281).

Esto indica coexistencia entre el sistema de audio “director” y audio ad-hoc por feature.

---

## 2) ¿Hay AudioMixer o bus de audio configurado?

### Hallazgos

- **No se encontró archivo de layout de buses** (`default_bus_layout.tres/res`) bajo `game/isla-ancestral/` (búsqueda de `*bus_layout*` y `*.tres/*.res` relacionados sin resultados). `project.godot` no contiene `audio/buses/default_bus_layout` (búsqueda sin coincidencias).
- **Sí hay configuración programática de buses** en `scripts/audio/audio_config_service.gd` (M91):
  - Define buses esperados: `Master`, `Music`, `SFX`, `Ambient`, `Voice`, `UI`, `Cinematic` (`DEFAULTS`/`BUSES_HIJOS`, líneas 23–33).
  - `_crear_buses()` crea buses hijo si no existen y los enruta a `Master` (líneas 59–71). También re-enruta buses existentes (no `Master`) hacia `Master` (líneas 68–71).
  - Aplica volumen lineal→dB con `AudioServer.set_bus_volume_db/linear_to_db` y mute (líneas 100–113).
  - Persiste en configuración vía `DataStore` sección `audio`, incluyendo `mutes` y `opciones` (BUG-092, líneas 74–97, 266–279).

### Conclusión del punto 2

**No hay AudioMixer/bus layout versionado como recurso**, pero **sí hay gestión de buses en runtime** mediante `AudioServer`. Esto funciona, aunque reduce reproducibilidad/configuración visual en editor y puede ocultar diferencias entre entornos si el layout esperado no está materializado.

---

## 3) ¿Hay problemas de sonido duplicado o no detenido?

### Riesgos / observaciones

1. **Directores sin reproducción real:** `MusicDirector`, `AmbientDirector` y `NarrativeSound` no reproducen streams; por tanto, **no generan duplicados por sí mismos** en el estado actual, pero tampoco detienen audio real. El riesgo de duplicado/no detenido se traslada a los módulos que consuman sus señales.
2. **SFXManager es lógico, no reproductor:** `_reproducir()` controla slots/prioridades/límites (incluye reemplazo por prioridad y corte por mismo tipo/categoría), lo cual **mitiga duplicados/apilamiento a nivel de decisión**. Sin embargo, al no manejar `AudioStreamPlayer` reales, no puede garantizar `stop()` de instancias ya sonando; la garantía real dependerá de la futura integración.
3. **Reproductores ad-hoc fuera del sistema:** `crafting_feedback.gd` crea 4 `AudioStreamPlayer` persistentes y llama `_tocar()` → `player.play()` sin comprobar si ya está sonando ni llamar `stop()` antes (líneas 108–111). Reproducciones rápidas pueden solaparse o reiniciarse según el comportamiento deseado; no hay política de voz/ducking compartida con M43. `shaman_ui.gd` reutiliza un `AudioStreamPlayer` y hace `play()` tras asignar stream (líneas 280–281) — reutilizar el mismo player reduce duplicación de nodos, pero no hay `stop()` explícito previo.
4. **Pausa incompleta a nivel motor:** `AudioConfig` no expone pausa global de buses; `MusicDirector/AmbientDirector/FeedbackDirector` tienen `pausar()/reanudar()` mayormente stub/lógicos. `SFXManager.pausar()` evita nuevas emisiones lógicas y `reanudar()` ajusta tiempos/purga (líneas 322–347), pero **no pausa streams reales** porque no los gestiona. Si existen reproductores reales en consumidores, podrían seguir sonando durante pausa.

### Evaluación

- **Duplicado confirmado en arquitectura central:** no evidenciado en los directores/autoloads revisados (actúan como lógica/señales).
- **No detenido / control incompleto:** **riesgo medio-alto** por diseño parcial (directores sin playback real) y por reproductores ad-hoc sin política unificada de `stop()`/pausa/canal.

---

## 4) ¿Hay validación de assets de audio?

### Lo que sí existe

- **Validación de existencia/carga de datos JSON** (catálogos/configuración), con `push_warning` si falta el archivo o el parseo no devuelve `Dictionary`:
  - Música: `music_director.gd` líneas 27–33.
  - Ambiente: `ambient_director.gd` líneas 26–33.
  - SFX superficies/tonos/catálogo: `sfx_manager.gd` líneas 84–107.
  - Feedback recetas/blacklist: `feedback_director.gd` líneas 28–42.
  - Narrativa: `narrative_sound.gd` líneas 73–79.
- **Validación defensiva de integraciones:** `SFXManager._conectar_si()` verifica nodo/señal antes de conectar (líneas 247–252). `NarrativeSound` degrada si `EventBus` no existe (líneas 47–63).
- **Validación de buses/opciones en runtime:** `AudioConfig` crea buses faltantes, valida claves/valores de opciones y confirma aplicación antes de persistir (líneas 59–71, 191–256).

### Lo que falta / es débil

- **No se valida la existencia/carga de assets de audio reales** (`AudioStream` `.ogg/.wav/.mp3/.tres`): los JSON referencian conceptos/variaciones, pero no hay comprobación `ResourceLoader.exists/load` de streams ni reporte por asset faltante.
- **No se detectaron assets de audio** en el árbol de `game/isla-ancestral/` (búsqueda de `.wav/.ogg/.mp3` sin resultados). Esto sugiere pipeline incompleto o assets externos/no versionados; sin validación, los fallos aparecerían tarde.
- **No hay verificación de asignación de bus** en reproductores ad-hoc (p. ej. `crafting_feedback.gd`, `shaman_ui.gd` no fijan `bus` explícitamente en el fragmento revisado), lo que puede enviar audio al bus por defecto y saltarse mezcla/mute de M91.
- **Módulo legal de licencias de audio** existe (`scripts/legal/audio_*`, `data/legal/audio_licenses.json`), pero no se evidenció una validación cruzada automática “asset usado ↔ licencia válida ↔ archivo presente” integrada al arranque de audio.

### Conclusión del punto 4

**Validación de metadatos/JSON: aceptable. Validación de assets de audio reales: insuficiente/inexistente** en el flujo revisado.

---

## 5) Sugerencias de mejora (2)

### Mejora 1 — Implementar capa de reproducción real unificada (players + buses + pausa/stop)

**Problema que ataca:** los directores gestionan decisión/estado pero no reproducen audio; hay reproductores ad-hoc sin política común; riesgo de no detenido, mezcla inconsistente y difícil control de pausa.  
**Acción recomendada:**
- Introducir una capa común (p. ej. servicio interno o helper) que cree/gestione `AudioStreamPlayer`/`AudioStreamPlayer2D`/`AudioStreamPlayer3D` con asignación explícita de `bus` (`Music`, `SFX`, `Ambient`, `UI`, `Voice`, `Cinematic`).
- Conectar `MusicDirector.tema_cambio` y `AmbientDirector.ambiente_cambiado` a reproductores reales con crossfade/capas; hacer que `SFXManager._reproducir()` emita/reproduzca usando el pool (o que consuma un pool de players) y soporte `stop()`/purga real al pausar.
- Unificar `crafting_feedback`/`shaman_ui` para enrutar por `SFXManager` o, mínimo, fijar `bus = "SFX"`/`"UI"` y respetar pausa/mute.
- Añadir (o versionar) un `default_bus_layout.tres` coherente con los buses de M91 para previsibilidad en editor/build.

**Impacto esperado:** control real de duplicados/detención, mezcla consistente, mejor depuración y cumplimiento de accesibilidad/volumen.

### Mejora 2 — Validación de assets y “audio manifest” en arranque/QA

**Problema que ataca:** faltan assets `.wav/.ogg/.mp3` detectables y no hay verificación de streams referenciados; los JSON pueden apuntar a contenido inexistente.  
**Acción recomendada:**
- Definir un manifiesto que mapee IDs de eventos/temas/capas a rutas `res://` de `AudioStream` (o extender los JSON existentes) y validar en arranque/CI:
  - `FileAccess.file_exists`/`ResourceLoader.exists` por recurso,
  - `load()` no nulo y tipo esperado (`AudioStream`),
  - bus destino válido.
- Registrar resultados en log estructurado (`[AudioQA] missing/ok`) y, en debug, exponer un reporte (aprovechando el patrón de `scripts/legal/audio_license_report_*`).
- Integrar chequeo cruzado con licencias (`data/legal/audio_licenses.json`) para assets presentes/usados.

**Impacto esperado:** detección temprana de audio roto, menos regresiones al integrar assets reales y trazabilidad legal/técnica.

---

## Archivos analizados (principales)

- `game/isla-ancestral/project.godot` — autoloads de audio, ausencia de `audio/buses` en el fragmento revisado.
- `game/isla-ancestral/scripts/audio/audio_config_service.gd` — M91 (líneas citadas: buses 23–71, carga/persistencia 74–97/266–309, API volumen/mute/opciones).
- `game/isla-ancestral/scripts/audio/sfx_manager.gd` — M43 (pool/límites 43–74/350–390, carga datos 84–107, API/ducking/integraciones 175–341).
- `game/isla-ancestral/scripts/audio/music_director.gd` — M41 (contexto/temas 44–74, variaciones 87–101).
- `game/isla-ancestral/scripts/audio/ambient_director.gd` — M42 (bioma/clima/fase 41–66).
- `game/isla-ancestral/scripts/audio/feedback_director.gd` — M44 (recetas/blacklist/contexto 22–73).
- `game/isla-ancestral/scripts/audio/narrative_sound.gd` — M150 (carga/eventos/momentos 35–243).
- `game/isla-ancestral/scripts/audio/shuffle_sampler.gd` — utilitario de variaciones.
- Datos: `game/isla-ancestral/data/audio/*.json` (music_context_matrix, ambient_biome_bank, sfx_catalog/surfaces/tones, feedback_recetas/blacklist, narrative_sound).
- Referencias externas observadas: `scripts/crafting/crafting_feedback.gd`, `scripts/enchantment/shaman_ui.gd` (reproductores ad-hoc).

## Conclusión final

El sistema de audio del proyecto tiene una **base arquitectónica sólida** (autoloads por dominio, datos JSON, prioridades/categorías, persistencia de configuración y creación dinámica de buses). Su principal brecha es que **la reproducción efectiva de audio está incompleta o delegada**: los directores no instancian/reproducen streams y no hay assets de audio versionados detectados ni bus layout de recurso. Esto limita la capacidad de garantizar, hoy, ausencia de duplicados/no detenidos en tiempo real y la validez de los assets. Priorizar una **capa de playback unificada** y una **validación de assets/manifiesto** cerraría el gap entre el diseño lógico y el audio audible en juego.