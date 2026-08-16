**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 31: Ciclo Día/Noche

## 1. Arquitectura

```
GameClock (M29) ── señal hora_cambio(min) ──► DayNightCycle.gd (M31)
                                                │  (serie, proceso por minuto de juego)
            ┌───────────────────────────────────┼──────────────────────────────────────┐
            ▼                                   ▼                                      ▼
   WorldEnvironment                    DirectionalLight3D                       Estrellas/Luna
   sky + ambiente + fog                Sol (rot + color + int)                  Nodos skybox
            │                                   │                                      │
            ▼                                   ▼                                      ▼
   FASES (franjas discretas) ──► señales a consumidores (M19, M36, M41, M42, M15, M34, M39, M17)
            │
            ▼
   Luces artificiales (faroles/refugio) — autoswitch por umbral de luz
```

## 2. Cronograma de fases (compatible con M29)

| Fase | Horario | Luz sol | Ambiente (piso) | Comportamiento |
|---|---|---|---|---|
| ALBA | 05:30-06:59 | 0.2→0.5 | 0.35 | Transición; pájaros |
| DÍA | 07:00-18:59 | 0.5→1.0→0.6 | 1.0 | Actividades/tiendas abiertas |
| ATARDECER | 19:00-19:59 | 0.6→0.2 | 0.5 | Luces se encienden (umbral 0.35) |
| NOCHE | 20:00-22:59 | luna 0.15 | 0.22 | CSIRO: fauna nocturna, retirada NPC |
| NOCHE PROFUNDA | 23:00-05:29 | luna 0.12 | 0.15 (piso mínimo) | NPCs duermen; nocturnos activos |

> Las **señales de fase** salen SOLO en el cambio de franja (no cada minuto): `EventBus.time.fase_cambio(FASE)`.

## 3. Componentes de escena

| Nodo | Recursos | Detalle |
|---|---|---|
| `DirLightSol` | DirectionalLight3D | shadow: cascades 2, plazo ~30 m, PCF suave; energía por curva |
| `DirLightLuna` | DirectionalLight3D | sin sombras; energía 0.12-0.2; color 7500K |
| `Sky` | ProceduralSkyMaterial | gradiente por hora (24 puntos), energía 0.18-1.0, estrellas alpha |
| `Luna` | MeshInstance3D (esfera) + textura fases | sigue el arco opuesto al sol |
| `Nubes_v2D` | Nodo velo 2D en far plane | drift lento (0.002/s), densidad estacional |
| `Fog` | FogVolume ligero | densidad 0.08-0.25 por estación/hora |
| `Faroles[]` | prefab farol (omni 3200K, r 8 m) | autoswitch por `umbral_luz` |
| `Estrellas` | canvas procedural (M45) | alpha 0→1 entre 20:00 y 22:00 |

## 4. Curvas de iluminación (concepto de datos)

- `data/light/day_curve.tres`: 24 puntos (hora → energía sol + color)
- `data/light/sky_curve.tres`: 24 puntos (hora → zenith/horizon color + energía cielo)
- `data/light/season_mod.tres`: 4 multiplicadores por estación (M29) aplicados a ambas curvas
- `data/light/fase_umbral.tres`: umbrales de fase (consignados en el cronograma)

Todos los valores tweenables; ningún punto de la curva cambia "de golpe" (máximo paso por minuto de juego predefinido).

## 5. Contrato con consumidores (API)

| Consumidor | Señal/consulta | Uso |
|---|---|---|
| M19 NPC | `fase_cambio(FASE)` + `get_fase()` | rutina de la franja |
| M36 Fauna | `fase_cambio(FASE)` | spawner diurno/nocturno |
| M41 Música | `fase_cambio(FASE)` | variante + crossfade |
| M42 Sonido | `fase_cambio(FASE)` | banco diurno/nocturno |
| M15 Recursos | `fase_cambio(FASE)` | spawn condicional (raro nocturno) |
| M34/M39 | `fase_cambio(FASE)` | cierre de tiendas, pesca |
| M17 Construcción | `fase_cambio(FASE)` | faroles requiren red eléctrica? NO en v1 (autoswitch tiempo) — nota M40 |
| M13 Linterna | `get_fase()` | sugirir encendido automático opcional |
| M12 Minimapa | — | no depende de luz (sin cambio) |

## 6. Eventos y secretos nocturnos

- **Lluvia de estrellas:** días 10 y 25 del mes (M29) 22:00-23:30; partículas caída + TTS "podés pedir un deseo" (M55 diario); jamás con tormenta (M32 valida).
- **Lince de luna:** 1 fijo por mes (día 15 tras luna llena), aparece en Claro del Bosque (M09); interacción "observar" (regala esporas) — siempre opcional.
- **Flora brillante:** en Senda de las Luciérnagas (POI M09); visible 21:00-05:00; cosechable (M33/M15) con recompensa x2 vs día (único bono horario permitido).
- **Murales luminosos (ruinas M25):** solo visibles de noche; lore (M148); sin puzzle obligatorio nocturno.

## 7. Anti-oscuridad (regla de oro)

1. Piso de ambiente nocturno **0.15 LDR** (post-tonemap).
2. Linterna del jugador (M13): rango 12 m, suave, sin sombras parpadeantes.
3. Opción M58 "Noche clara": piso 0.35.
4. Prohibido: negro puro en ambiente, flash total oscuridad en transiciones.
5. QA M114: checklist visual nocturno en todas las zonas (nunca "no veo nada").