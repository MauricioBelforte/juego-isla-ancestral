**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 04-Codigo.md — Módulo 150: Diseño Sonoro Narrativo

## 1. Carácter del Componente

Módulo de **diseño sonoro narrativo** para guiar al jugador a través del audio. Define sonido distintivo de Aurora, Resonancia, cada Sello, Elysia, cada templo, descubrimientos, misterios, puertas antiguas, máquinas, telemetría ancestral, leitmotifs sonoros, variación de intensidad y silencio narrativo. Implementable inmediatamente (depende de M41 para música, M40 para audio, M22 para historia principal, M25 para ruinas y templos). Es un módulo de diseño de audio y configuración.

**06-Plan-Testings.md:** NO APLICA (módulo de diseño sonoro, sin código de gameplay complejo; tests pueden ser manuales de audio)

## 2. Archivos involucrados (implementación)

```
res://audio/
├── narrative_audio_manager.gd                 → Sistema de audio narrativo
└── leitmotif_config.gd                        → Configuración de leitmotifs

06-Plan-Testings.md                               → NO APLICA
07-Resultados-Testings.md                        → NO APLICA
```

## 3. Contratos de integración

### Salida (hacia otros módulos)
- **M41 (Música):** Leitmotifs sonoros integrados con sistema de música
- **M40 (Audio):** Sistema de audio narrativo integrado con sistema de audio
- **M22 (Historia Principal):** Leitmotifs de Aurora y Elysia integrados con historia
- **M25 (Ruinas y Templos):** Leitmotifs de templos integrados con ruinas

### Entrada (desde otros módulos)
- **M41 (Música):** Tracks de música para leitmotifs
- **M40 (Audio):** Efectos de sonido para sonidos puntuales
- **M22 (Historia Principal):** Eventos de historia para triggers de audio
- **M25 (Ruinas y Templos):** Eventos de templos para triggers de audio

### Configuración
- `res://audio/narrative_audio_manager.gd` define sistema de audio narrativo
- `res://audio/leitmotif_config.gd` define configuración de leitmotifs

## 4. Implementación de narrative_audio_manager.gd (esqueleto)

```gdscript
# res://audio/narrative_audio_manager.gd
class_name NarrativeAudioManager
extends Node

signal leitmotif_started(leitmotif_id: String)
signal leitmotif_ended(leitmotif_id: String)

var current_leitmotif: String = ""
var audio_context: String = "calm"  # calm, tension, danger

func _ready():
    setup_audio_context()

func setup_audio_context():
    # Configurar contexto de audio (calma, tensión, peligro)
    pass

func play_leitmotif(leitmotif_id: String, context: String = "calm"):
    # Reproducir leitmotif con variación según contexto
    current_leitmotif = leitmotif_id
    audio_context = context
    leitmotif_started.emit(leitmotif_id)
    print("Playing leitmotif: %s (context: %s)" % [leitmotif_id, context])

func stop_leitmotif():
    # Detener leitmotif actual
    if current_leitmotif != "":
        leitmotif_ended.emit(current_leitmotif)
        print("Stopping leitmotif: %s" % current_leitmotif)
        current_leitmotif = ""

func play_discovery_sound():
    # Reproducir sonido de descubrimiento
    print("Playing discovery sound")

func play_mystery_sound():
    # Reproducir sonido de misterio
    print("Playing mystery sound")

func play_ancient_door_sound():
    # Reproducir sonido de puerta antigua
    print("Playing ancient door sound")

func play_machine_sound():
    # Reproducir sonido de máquina
    print("Playing machine sound")

func play_telemetry_sound():
    # Reproducir sonido de telemetría ancestral
    print("Playing telemetry sound")

func set_audio_context(context: String):
    # Cambiar contexto de audio (calma, tensión, peligro)
    audio_context = context
    if current_leitmotif != "":
        play_leitmotif(current_leitmotif, context)

func play_narrative_silence(duration: float):
    # Reproducir silencio narrativo (pausa)
    print("Playing narrative silence for %s seconds" % duration)
    await get_tree().create_timer(duration).timeout
```

## 5. Implementación de leitmotif_config.gd (esqueleto)

```gdscript
# res://audio/leitmotif_config.gd
class_name LeitmotifConfig
extends Resource

@export var aurora_leitmotif: AudioStream
@export var resonance_leitmotif: AudioStream
@export var elysia_leitmotif: AudioStream
@export var sello_1_leitmotif: AudioStream
@export var sello_2_leitmotif: AudioStream
@export var sello_3_leitmotif: AudioStream
@export var sello_4_leitmotif: AudioStream
@export var sello_5_leitmotif: AudioStream
@export var sello_6_leitmotif: AudioStream
@export var sello_7_leitmotif: AudioStream
@export var temple_hielo_leitmotif: AudioStream
@export var temple_volcan_leitmotif: AudioStream
@export var temple_bosque_leitmotif: AudioStream
```

## 6. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Crear res://audio/narrative_audio_manager.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://audio/leitmotif_config.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear tracks de audio para leitmotifs | **IMPLEMENTACIÓN MANUAL** |
| Crear efectos de sonido para sonidos puntuales | **IMPLEMENTACIÓN MANUAL** |
| Integrar con M41 (Música) para leitmotifs | **M41 (Música)** |
| Integrar con M40 (Audio) para efectos de sonido | **M40 (Audio)** |
| Integrar con M22 (Historia Principal) para triggers de audio | **M22 (Historia Principal)** |
| Integrar con M25 (Ruinas y Templos) para triggers de audio | **M25 (Ruinas y Templos)** |

## 7. Notas del Agente

**Modelo:** SWE-1.6
**Plataforma:** DEVIN
**Fecha:** 2026-08-20 15:50:00
**Estado:** Completado (especificación; implementación inmediata posible)

### Lo que hice
- Definí sonido distintivo de Aurora (personaje principal: suave, acogedor, naturaleza).
- Definí sonido distintivo de Resonancia (mecánica central: místico, vibrante, energía).
- Definí sonido distintivo de cada Sello (decisión del jugador: instrumento distintivo).
- Definí sonido distintivo de Elysia (antagonista: tenso, misterioso, oscuro).
- Definí sonido distintivo de cada templo (bioma, tema: sonido único).
- Definí sonido distintivo de descubrimientos (brillo, campana, swoosh).
- Definí sonido de misterios (susurro, eco, ambiente tenso).
- Definí sonido de puertas antiguas (engranaje, rocas, eco).
- Definí sonido de máquinas (zumbido, chisporroteo, energía).
- Definí sonido de telemetría ancestral (beep, chirp, tono suave).
- Definí leitmotifs sonoros (personajes, islas, temas).
- Definí variación de intensidad (calma, tensión, peligro).
- Definí silencio narrativo (pausas, énfasis, tensión).
- Diseñé NarrativeAudioManager (servicio de audio narrativo) con play_leitmotif(), stop_leitmotif(), set_audio_context().
- Diseñé LeitmotifConfig (Resource) con propiedades de leitmotifs.
- Diseñé diagrama de flujo de audio narrativo.

### Lo que NO pude hacer (honestidad obligatoria)
- Crear tracks de audio reales para leitmotifs (requiere compositor y producción musical)
- Crear efectos de sonido reales para sonidos puntuales (requiere diseñador de audio)
- Implementar integración real con M41 (Música) - es solo diseño de integración
- Implementar integración real con M40 (Audio) - es solo diseño de integración
- Implementar integración real con M22 (Historia Principal) - es solo diseño de integración
- Implementar integración real con M25 (Ruinas y Templos) - es solo diseño de integración

### Recomendaciones para el primer agente (implementador)
- Implementar NarrativeAudioManager en Godot con autoload.
- Implementar LeitmotifConfig como Resource.
- Crear tracks de audio para leitmotifs (contratar compositor).
- Crear efectos de sonido para sonidos puntuales (contratar diseñador de audio).
- Integrar con M41 (Música) para leitmotifs.
- Integrar con M40 (Audio) para efectos de sonido.
- Integrar con M22 (Historia Principal) para triggers de audio.
- Integrar con M25 (Ruinas y Templos) para triggers de audio.
- Probar leitmotif de Aurora (calma, tensión, peligro).
- Probar leitmotif de Resonancia (calma, tensión, peligro).
- Probar leitmotif de cada Sello.
- Probar leitmotif de Elysia (misterio, peligro).
- Probar leitmotif de cada templo.
- Probar sonido de descubrimientos.
- Probar sonido de misterios.
- Probar sonido de puertas antiguas.
- Probar sonido de máquinas.
- Probar sonido de telemetría ancestral.
- Probar variación de intensidad.
- Probar silencio narrativo.
