**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 03-Diseno.md — Módulo 150: Diseño Sonoro Narrativo

## 1. Estructura del módulo

```
Diseño Sonoro Narrativo (sistema de audio narrativo)
├── Sonido distintivo de Aurora
│   ├── Sonido suave y acogedor
│   ├── Tema: naturaleza (aves, viento, agua)
│   ├── Instrumentos: flauta, piano suave, cuerdas
│   └── Leitmotif: repetición con variación
├── Sonido distintivo de Resonancia
│   ├── Sonido místico y vibrante
│   ├── Tema: energía (resonancia, campanas)
│   ├── Instrumentos: campanas, sintetizadores, bajo
│   └── Leitmotif: repetición con variación
├── Sonido distintivo de cada Sello
│   ├── Cada Sello tiene sonido único
│   ├── Tema: instrumento distintivo por Sello
│   ├── Instrumentos: cello, piano, flauta, etc.
│   └── Leitmotif: repetición al recordar Sello
├── Sonido distintivo de Elysia
│   ├── Sonido tenso y misterioso
│   ├── Tema: oscuro (campanas distantes, bajo)
│   ├── Instrumentos: bajo, campanas distantes, eco
│   └── Leitmotif: repetición con variación
├── Sonido distintivo de cada templo
│   ├── Cada templo tiene sonido único
│   ├── Tema: bioma (hielo, volcán, bosque)
│   ├── Instrumentos: cello, bajo, flauta
│   └── Leitmotif: repetición en templo específico
├── Sonido distintivo de descubrimientos
│   ├── Sonido de brillo y satisfacción
│   ├── Tema: descubrimiento (campana, swoosh)
│   └── Sonido puntual (no leitmotif)
├── Sonido de misterios
│   ├── Sonido tenso y misterioso
│   ├── Tema: secreto (susurro, eco)
│   └── Sonido puntual (no leitmotif)
├── Sonido de puertas antiguas
│   ├── Sonido de mecanismo antiguo
│   ├── Tema: antiguo (engranaje, rocas)
│   └── Sonido puntual (no leitmotif)
├── Sonido de máquinas
│   ├── Sonido de tecnología ancestral
│   ├── Tema: tecnología (zumbido, chisporroteo)
│   └── Sonido puntual (no leitmotif)
├── Sonido de telemetría ancestral
│   ├── Sonido de UI suave
│   ├── Tema: tecnología ancestral (beep, chirp)
│   └── Sonido puntual (no leitmotif)
├── Leitmotifs sonoros
│   ├── Personajes (Aurora, Elysia, NPCs)
│   ├── Islas (cada isla tiene leitmotif)
│   └── Temas (cozy, tensión, peligro, misterio)
├── Variación de intensidad
│   ├── Calma (leitmotifs suaves)
│   ├── Tensión (leitmotifs tensos)
│   └── Peligro (leitmotifs peligrosos)
└── Silencio narrativo
    ├── Pausas para énfasis
    ├── Silencio para tensión
    └── Silencio para impacto
```

## 2. Sistema de audio narrativo

**Archivo: res://audio/narrative_audio_manager.gd**

**Estructura:**
```gdscript
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

func stop_leitmotif():
    # Detener leitmotif actual
    if current_leitmotif != "":
        leitmotif_ended.emit(current_leitmotif)
        current_leitmotif = ""

func play_discovery_sound():
    # Reproducir sonido de descubrimiento
    pass

func play_mystery_sound():
    # Reproducir sonido de misterio
    pass

func play_ancient_door_sound():
    # Reproducir sonido de puerta antigua
    pass

func play_machine_sound():
    # Reproducir sonido de máquina
    pass

func play_telemetry_sound():
    # Reproducir sonido de telemetría ancestral
    pass

func set_audio_context(context: String):
    # Cambiar contexto de audio (calma, tensión, peligro)
    audio_context = context
    if current_leitmotif != "":
        play_leitmotif(current_leitmotif, context)

func play_narrative_silence(duration: float):
    # Reproducir silencio narrativo (pausa)
    await get_tree().create_timer(duration).timeout
```

## 3. Configuración de leitmotifs

**Archivo: res://audio/leitmotif_config.gd**

**Estructura:**
```gdscript
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

## 4. Diagrama de flujo de audio narrativo

```
[Evento trigger]
    ↓
[NarrativeAudioManager recibe evento]
    ↓
[Es leitmotif?]
    ↓ Sí
[Play leitmotif con variación según contexto]
    ↓
[LeitmotifStarted emitido]
    ↓
[Contexto cambia?]
    ↓ Sí
[Variar intensidad de leitmotif]
    ↓ No
[Es sonido puntual?]
    ↓ Sí
[Play sonido puntual (descubrimiento, misterio, puerta, máquina, telemetría)]
    ↓ No
[Es silencio narrativo?]
    ↓ Sí
[Play silencio narrativo (pausa)]
    ↓ No
[Fin]
```

## 5. Pruebas de audio narrativo

**Pruebas manuales:**
- Probar leitmotif de Aurora (calma, tensión, peligro)
- Probar leitmotif de Resonancia (calma, tensión, peligro)
- Probar leitmotif de cada Sello
- Probar leitmotif de Elysia (misterio, peligro)
- Probar leitmotif de cada templo
- Probar sonido de descubrimientos
- Probar sonido de misterios
- Probar sonido de puertas antiguas
- Probar sonido de máquinas
- Probar sonido de telemetría ancestral
- Probar variación de intensidad
- Probar silencio narrativo

**Pruebas automáticas:**
- Tests de NarrativeAudioManager
- Tests de LeitmotifConfig
- Tests de play_leitmotif() con diferentes contextos
