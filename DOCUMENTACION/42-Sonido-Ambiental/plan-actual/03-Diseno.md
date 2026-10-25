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

## Specs Sonido Ambiental (Beam 668)

### RF4: fauna con horas de actividad
- Spec: RF4: fauna con horas de actividad. Coherente with M42 (sonido ambiental) and M36 (fauna).

### RF6: interiores con reverb
- Spec: RF6: interiores con reverb. Coherente with M42 (sonido ambiental) and M48 (iluminacion).

### P3: hierba — rizoma suave en praderas
- Spec: P3: hierba — rizoma suave en praderas. Coherente with M42 (sonido ambiental) and M49 (vegetacion).

### P4: agua — generica en lagos/estanques
- Spec: P4: agua — generica en lagos/estanques. Coherente with M42 (sonido ambiental) and M51 (agua).

### P6: cascada — 3D en 2 POIs fijos, hasta 120 m
- Spec: P6: cascada — 3D en 2 POIs fijos, hasta 120 m. Coherente with M42 (sonido ambiental) and M51 (agua).


## Specs Sonido Ambiental (Beam 669)

### P7: ocean — costa 3D + mar lejano 2D
- Spec: P7: océano — costa 3D + mar lejano 2D. Coherente with M42 (sonido ambiental) and M51 (agua).

### P8: lluvia — capa 2D fina + goteras en cobertizos
- Spec: P8: lluvia — capa 2D fina + goteras en cobertizos. Coherente with M42 (sonido ambiental) and M31 (clima).

### P9: tormenta — lluvia densa + truenos random 30-90 s
- Spec: P9: tormenta — lluvia densa + truenos random 30-90 s. Coherente with M42 (sonido ambiental) and M31 (clima).

### P14: minería — golpe + gravilla, oclusión de túnel
- Spec: P14: minería — golpe + gravilla, oclusión de túnel. Coherente with M42 (sonido ambiental) and M35 (minería).

### P16: árboles — crujido al tala/impacto
- Spec: P16: árboles — crujido al tala/impacto. Coherente with M42 (sonido ambiental) and M15 (recursos).


## Specs Sonido Ambiental (Beam 670)

### P17: animales — 2D lejanos + 3D cercanos
- Spec: P17: animales — 2D lejanos + 3D cercanos. Coherente with M42 (sonido ambiental) and M36 (fauna).

### P19: insectos — nocturnos (20:00-05:00), contenidos
- Spec: P19: insectos — nocturnos (20:00-05:00), contenidos. Coherente with M42 (sonido ambiental) and M31 (ciclo).

### P21: cuevas — reverb 1.5 s + goteras + eco
- Spec: P21: cuevas — reverb 1.5 s + goteras + eco. Coherente with M42 (sonido ambiental) and M25 (templo).

### P22: ruinas — ecos + viento silbante + metalofono lejano
- Spec: P22: ruinas — ecos + viento silbante + metalófono lejano. Coherente with M42 (sonido ambiental) and M25 (templo).

### P23: templo — coro distante/drones, reverb 1.2 s, 30% tiempo
- Spec: P23: templo — coro distante/drones, reverb 1.2 s, 30% tiempo. Coherente with M42 (sonido ambiental) and M23 (templos).


## Specs Sonido Ambiental (Beam 671)

### Playa: oceano + viento + aves costeras
- Spec: playa: oceano + viento + aves costeras. Coherente with M42 (sonido ambiental) and M51 (agua).

### Pradera: hierba + viento + aves
- Spec: pradera: hierba + viento + aves. Coherente with M42 (sonido ambiental) and M49 (vegetacion).

### Bosque templado: hojas + pajaros + hojarasca
- Spec: bosque templado: hojas + pajaros + hojarasca. Coherente with M42 (sonido ambiental) and M49 (vegetacion).

### Pinos: viento en ramas + cuervos
- Spec: pinos: viento en ramas + cuervos. Coherente with M42 (sonido ambiental) and M49 (vegetacion).

### Montaña: viento fuerte + piedra + eco
- Spec: montaña: viento fuerte + piedra + eco. Coherente with M42 (sonido ambiental) and M31 (clima).


## Specs Sonido Ambiental (Beam 672)

### Desierto (Cenizas): viento seco + dunas
- Spec: desierto (Cenizas): viento seco + dunas. Coherente with M42 (sonido ambiental) and M31 (clima).

### Selva (Verde): fauna densa
- Spec: selva (Verde): fauna densa. Coherente with M42 (sonido ambiental) and M36 (fauna).

### Manglar: agua + ranas
- Spec: manglar: agua + ranas. Coherente with M42 (sonido ambiental) and M51 (agua).

### Tundra: nieve + viento frio
- Spec: tundra: nieve + viento frio. Coherente with M42 (sonido ambiental) and M31 (clima).

### Coral: olas + gaviotas
- Spec: coral: olas + gaviotas. Coherente with M42 (sonido ambiental) and M51 (agua).


## Specs Sonido Ambiental (Beam 673)

### Volcan/Cenizas: viento + piedra caliente
- Spec: volcan/Cenizas: viento + piedra caliente. Coherente with M42 (sonido ambiental) and M31 (clima).

### Cueva: reverb + goteras + eco (subterraneo)
- Spec: cueva: reverb + goteras + eco (subterraneo). Coherente with M42 (sonido ambiental) and M25 (templo).

### Dia: aves poisson + viento normal
- Spec: dia: aves poisson + viento normal. Coherente with M42 (sonido ambiental) and M31 (ciclo).

### Alba: 15% densidad de aves
- Spec: alba: 15% densidad de aves. Coherente with M42 (sonido ambiental) and M31 (ciclo).

### Profunda: densidad -20% (misterio suave)
- Spec: profunda: densidad -20% (misterio suave). Coherente with M42 (sonido ambiental) and M31 (ciclo).


## Specs Sonido Ambiental (Beam 674)

### LLUVIA: capa exterior + goteras
- Spec: LLUVIA: capa exterior + goteras. Coherente with M42 (sonido ambiental) and M31 (clima).

### TORMENTA: lluvia densa + truenos
- Spec: TORMENTA: lluvia densa + truenos. Coherente with M42 (sonido ambiental) and M31 (clima).

### <= 2 fauna 2D
- Spec: <= 2 fauna 2D. Coherente with M42 (sonido ambiental) and M61 (rendimiento).

### 1 bus de reverb interior
- Spec: 1 bus de reverb interior. Coherente with M42 (sonido ambiental) and M61 (rendimiento).

### Total <= 11 buses activos
- Spec: total <= 11 buses activos. Coherente with M42 (sonido ambiental) and M61 (rendimiento).


## Specs Sonido Ambiental (Beam 675)

### Oclusion RayCast solo en interiores criticos
- Spec: oclusion RayCast solo en interiores criticos. Coherente with M42 (sonido ambiental) and M61 (rendimiento).

### Samples -> compositor (spec lista)
- Spec: samples -> compositor (spec lista). Coherente with M42 (sonido ambiental) and M108 (pipeline).
