# Log 421: M91 Configuración de Audio iter. 1 — núcleo buses/volúmenes/persistencia — glm-5.3-flash

**Fecha:** 2026-09-01
**Hora:** 24:15
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen

Iteración 1 del M91 Configuración de Audio (Media 1, V0/V1): AudioConfigService autoload con los 7 buses de audio del diseño (§4), volúmenes lineal→db, mute, persistencia vía M60 y señales para la UI. Módulo liberado 🟡 10/239.

## Cambios Realizados

### audio_config_service.gd (nuevo, autoload AudioConfig)
- 7 buses de audio creados en runtime enrutados a Master (Master/Music/SFX/Ambient/Voice/UI/Cinematic — §4) si no existen.
- set_volumen/get_volumen con clamp 0-1 y linear→db en AudioServer; set_mute/esta_muteado; buses_disponibles().
- Defaults §3 coherentes con GestorConfig DEFAULTS_BASE de M60 (Master 0.8/Music 0.7/SFX 0.8/Ambient 0.6/Voice 0.9/UI 0.5/Cinematic 0.8).
- Persistencia automática en cada set vía M60 GestorConfig sección "audio" (la sección existía desde mi iter. 2 de M87).
- Señales volumen_cambiado/mute_cambiado (M53 UI y M41-M44 consumidores).
- Provider ISaveProvider M59 sección "audio_config".

### test_audio_config.gd (nuevo)
- Buses creados y enrutados, defaults §3, set/clamp/mute con AudioServer refleja, persistencia M60 round-trip, coherencia GestorConfig → **0 fallos a la primera**.

### Registro
- Regresiones: test_datos_m60 66/0, test_localizacion_iter2 M87 0 fallos.
- Autoload AudioConfig en project.godot; caché regenerada.
- Checklist: 10 ítems [x]. Progreso 0→10/239.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/audio/audio_config_service.gd` (nuevo)
- `game/isla-ancestral/scripts/audio/test_audio_config.gd` (nuevo)
- `game/isla-ancestral/project.godot` (autoload AudioConfig)
- `DOCUMENTACION/91-Configuracion-De-Audio/plan-actual/04-Codigo.md` (Notas del Agente iter. 1)
- `DOCUMENTACION/91-Configuracion-De-Audio/plan-actual/05-Checklist.md` (10/239 + reserva liberada)
- `CHECKLIST-GLOBAL.md`, `Mensajes entre modelos/ESTADO-PARALELO.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`

## Verificación

- test_audio_config.gd: 0 fallos a la primera · regresiones M60 (66/0) y M87 (0 fallos) (Godot 4.5 headless).
