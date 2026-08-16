**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 42: Sonido Ambiental

## 1. Arquitectura

```
Sistema de Audio (M06/buses) ──► AmbientDirector.gd (autoload M42)
        │
   ┌────┴──────────────────────────────────────────────┐
   ▼                                                  ▼
BANCOS DE BIOMA (13+1)                        FUENTES POSICIONALES 3D
(loop 2D por zona + variaciones)             (río, cascada, océano costa,
   │                                             fuego, mecanismos, máquinas)
   └────────────────┬─────────────────────────────┘
                    ▼
         CAPAS DE ESTADO (suman, no reemplazan)
    hora (M31: día/alba/atardecer/noche/profunda)
    clima (M32: lluvia, tormenta, nieve, viento)
                    ▼
         REVERB POR INTERIOR (cueva/ruinas/templo)
```

## 2. Mapa banco → bioma

| Bioma (M09) | Banco (capas) |
|---|---|
| Playa | océano costa fuerte + viento + aves costeras |
| Pradera | hierba + viento suave + aves |
| Bosque templado | hojas + pájaros + pasos hojarasca |
| Bosque de pinos | viento entre ramas + cuervos lejanos |
| Montaña | viento fuerte + piedra + eco lejano |
| Desierto (Cenizas) | viento seco + dunas crujientes |
| Selva (Isla Verde) | fauna densa (aves tropicales, insectos) |
| Manglar | agua + ranas + chorreras |
| Tundra (invierno) | nieve + viento frío |
| Coral / costa coralina | olas + gaviotas + mar generosa |
| Volcán / Cenizas | viento + piedra caliente (leves) |
| Cielo (islas flotantes) | viento etéreo + coro distante |
| Interior de cueva | subterráneo: reverb + goteras + eco |

## 3. Capas de estado (reglas de densidad)

| Estado | Efecto sobre banco |
|---|---|
| Día | aves activas (poisson 6+), viento normal |
| Alba | aves frisan (15% densidad) |
| Atardecer | transición de aves → insectos |
| Noche | insectos/grillos activos; aves silencio |
| Profunda | densidad -20% (misterio suave, cozy) |
| LLUVIA | capa de lluvia exterior + goteras |
| TORMENTA | lluvia densa + truenos random 30-90 s |
| NIEVE | casi silencio + crujidos (pasos M44) |
| VIENTO | modula viento base (±10 dB) |

## 4. Presupuesto de fuentes (M61)

| Categoría | Fuentes simultáneas |
|---|---|
| Ambiental 2D (banco bioma + capas) | ≤ 6 |
| Posicional 3D (río/cascada/océano/fuego) | ≤ 3 |
| Fauna 2D | ≤ 2 |
| Interior reverb | 1 bus |
| **Total** | **≤ 11 bus activos** (meta: latencia < 12 ms usando el pool de M06) |

## 5. Datos de configuración

- `res://data/audio/ambient_biome_bank.tres` (banco por bioma)
- `res://data/audio/ambient_state_layers.tres` (capas hora/clima)
- `res://data/audio/ambient_volumes.tres` (volúmenes/limites)
- `res://src/audio/ambient_director.gd` (selector de bancos)
- `res://src/audio/ambient_source.gd` (fuente 3D con distancia y variaciones)

## 6. Reglas de QA

- En cualquier punto del mapa (M114): audible y balanceado; ningún bioma con silencio total ni "lluvia escena".
- Normalización: ambientes ≤ -18 LUFS; música -16 (M41); diálogos +6 dB sobre música (M21).
- Test de pausa: al pausar (M29) no hay sonido residual.
- Test de rendimiento: ≤ 11 buses en M113 profiler.