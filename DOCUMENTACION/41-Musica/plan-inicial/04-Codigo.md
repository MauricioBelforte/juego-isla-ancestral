**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 41: Música

## 1. Archivos involucrados (previstos)

| Archivo | Tipo | Rol |
|---|---|---|
| `res://src/audio/music_director.gd` | Autoload (M07) | Selección de tema+capas, A/B crossfade, pausa |
| `res://src/audio/music_player.gd` | Node | Wrapper de AudioStreamPlayer (loop, volumen, límite de voces) |
| `res://src/audio/shuffle_sampler.gd` | Util | Baraja variaciones con PRNG de partida |
| `res://src/audio/ducking.gd` | Util | Reduce música con diálogos/UI |
| `res://src/audio/stings.gd` | Node | Stings puntuales |
| `res://data/audio/music_tema_bank.tres` | Data | Catálogo (path, duración, varíaсiones, LUFS) |
| `res://data/audio/music_context_matrix.tres` | Data | Lógica de matriz (zona × tiempo × evento) |
| `res://data/audio/music_volumes.tres` | Data | Volúmenes y límites |
| `res://audio/music/...wav` | Assets | Temas y variaciones (compositor) |

## 2. API pública

```
MusicDirector (autoload/único):
  play_contexto(entorno: String, hora: int, estacion: int, clima: int)
  play_flujo(momento: FLUJO)            # intra, menu, llegada, creditos...
  play_narrativo(momento: NARRATIVO)    # tension, descubrimiento, misterio, sello...
  sting(tipo: STING)
  pausar() / reanudar()                 # M29 pausa
  EventBus.music.tema_cambio(tema, capas_activas)
```

## 3. Pendientes de implementación (dueño: AGENTE DELEGADO)

| Pendiente | Nota |
|---|---|
| MusicDirector + players + shuffle | Tras sistema base de audio (M06-hito M1) |
| Matriz de contexto en data | Ya definida en 03-Diseno |
| Temas y variaciones (composición) | Dueño: compositor/Assets — el diseño es la spec |
| Integración con M42 (buses) y M44 (feedback) | Buses jerárquicos de M06 |
| Tests M112 | Matrix sin ambigüedad (cada contexto → tema válido), crossfade A/B sin superposición, shuffle sin repetición consecutiva |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 20:40:00
**Estado:** Documentación de diseño completa (módulo delegable)

### Lo que hice
- 51/51 puntos de la sección 40 resueltos.
- Matriz de capas (base+tiempo+evento) que cubre 12×4×3 contextos con ≤ 8 voces.
- Volumetría profesional (LUFS -16, ducking) y presupuesto de producción (≈90 archivos).
- Regla cozy: sin música de combate/horror; tensión narrativa suave ≤ 45 s.

### Lo que NO hice (honestidad obligatoria)
- Composición de audio: depende de assets del compositor y del sistema de audio base (M06, hito M1).

### Recomendaciones para el próximo agente
- Implementar MusicDirector como autoload leyendo la matrix .tres (sin hardcode).
- El shuffle sampler es la pieza clave anti-repetición: testear con 200 loops simulados.