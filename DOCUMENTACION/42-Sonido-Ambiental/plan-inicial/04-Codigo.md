**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 42: Sonido Ambiental

## 1. Archivos involucrados (previstos)

| Archivo | Tipo | Rol |
|---|---|---|
| `res://src/audio/ambient_director.gd` | Autoload (M07) | Selección de banco + capas; crossfade; pausa |
| `res://src/audio/ambient_source.gd` | Nodo | Fuente 3D (distancia, variaciones, oclusión ligera) |
| `res://src/audio/ambient_fauna.gd` | Util | Horizonte de fauna (poisson por horas) |
| `res://data/audio/ambient_biome_bank.tres` | Data | Banco por bioma |
| `res://data/audio/ambient_state_layers.tres` | Data | Capas de hora/clima |
| `res://data/audio/ambient_volumes.tres` | Data | Volúmenes/límites |
| `res://audio/ambient/...wav` | Assets | Loops y variaciones (compositor) |

## 2. API pública

```
AmbientDirector (autoload/único):
  set_bioma(bioma: String)                 # M09/M63 cambio de zona
  set_estado_clima(clima: int, intensidad: float)   # M32
  set_fase(fase: FASE)                     # M31
  fuente_posicional(path, pos) -> AmbientSource
  pausar() / reanudar()                    # M29
```

## 3. Pendientes de implementación (dueño: AGENTE DELEGADO)

| Pendiente | Nota |
|---|---|
| AmbientDirector + capas + crossfade | Tras sistema de audio base (M06-hito M1) |
| Banco de biomas (13) | Composición de assets |
| Fuentes 3D (río, cascada, océano, fuego, mecanismos, máquinas) | Con M09 POIs |
| Fauna poisson + reverb interiores | QA M114 |
| Tests M112 | Banco→bioma sin huecos, capas por hora/clima correctas, ≤ 11 buses |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 21:10:00
**Estado:** Documentación de diseño completa (módulo delegable)

### Lo que hice
- 25/25 puntos de la sección 41 resueltos con tabla banco→bioma.
- Estructura por capas (bioma + hora/clima) coherente con M31/M32.
- Presupuesto de fuentes (≤ 11 buses) y volumetría (≤ -18 LUFS) para M61.

### Lo que NO hice (honestidad obligatoria)
- Implementar: requiere sistema de audio base (M06). Dueño: AGENTE DELEGADO.
- Samples de audio: los produce el compositor (spec lista).

### Recomendaciones para el próximo agente
- Implementar AmbientDirector sin leer el clima/hora directamente (solo señales de M31/M32).
- El pool de AudioStreamPlayers debe ser estático (sin allocs por frame — M61).