**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 31: Ciclo Día/Noche

# 1. Arquitectura

```
GameClock (M29) ── señal hora_cambio(min) ──► DayNightCycle.gd (M31)
                                                â”‚  (serie, proceso por minuto de juego)
            â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
            â–¼                                   â–¼                                      â–¼
   WorldEnvironment                    DirectionalLight3D                       Estrellas/Luna
   sky + ambiente + fog                Sol (rot + color + int)                  Nodos skybox
            â”‚                                   â”‚                                      â”‚
            â–¼                                   â–¼                                      â–¼
   FASES (franjas discretas) ──► señales a consumidores (M19, M36, M41, M42, M15, M34, M39, M17)
            â”‚
            â–¼
   Luces artificiales (faroles/refugio) — autoswitch por umbral de luz
```

# 2. Cronograma de fases (compatible con M29)

| Fase | Horario | Luz sol | Ambiente (piso) | Comportamiento |
|---|---|---|---|---|
| ALBA | 05:30-06:59 | 0.2→0.5 | 0.35 | Transición; pájaros |
| DÍA | 07:00-18:59 | 0.5→1.0→0.6 | 1.0 | Actividades/tiendas abiertas |
| ATARDECER | 19:00-19:59 | 0.6â†’0.2 | 0.5 | Luces se encienden (umbral 0.35) |
| NOCHE | 20:00-22:59 | luna 0.15 | 0.22 | CSIRO: fauna nocturna, retirada NPC |
| NOCHE PROFUNDA | 23:00-05:29 | luna 0.12 | 0.15 (piso mínimo) | NPCs duermen; nocturnos activos |

> Las **señales de fase** salen SOLO en el cambio de franja (no cada minuto): `EventBus.time.fase_cambio(FASE)`.

# 3. Componentes de escena

| Nodo | Recursos | Detalle |
|---|---|---|
| `DirLightSol` | DirectionalLight3D | shadow: cascades 2, plazo ~30 m, PCF suave; energía por curva |
| `DirLightLuna` | DirectionalLight3D | sin sombras; energía 0.12-0.2; color 7500K |
| `Sky` | ProceduralSkyMaterial | gradiente por hora (24 puntos), energía 0.18-1.0, estrellas alpha |
| `Luna` | MeshInstance3D (esfera) + textura fases | sigue el arco opuesto al sol |
| `Nubes_v2D` | Nodo velo 2D en far plane | drift lento (0.002/s), densidad estacional |
| `Fog` | FogVolume ligero | densidad 0.08-0.25 por estación/hora |
| `Faroles[]` | prefab farol (omni 3200K, r 8 m) | autoswitch por `umbral_luz` |
| `Estrellas` | canvas procedural (M45) | alpha 0â†’1 entre 20:00 y 22:00 |

# 4. Curvas de iluminación (concepto de datos)

- `data/light/day_curve.tres`: 24 puntos (hora → energía sol + color)
- `data/light/sky_curve.tres`: 24 puntos (hora → zenith/horizon color + energía cielo)
- `data/light/season_mod.tres`: 4 multiplicadores por estación (M29) aplicados a ambas curvas
- `data/light/fase_umbral.tres`: umbrales de fase (consignados en el cronograma)

Todos los valores tweenables; ningún punto de la curva cambia "de golpe" (máximo paso por minuto de juego predefinido).

# 5. Contrato con consumidores (API)

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

# 6. Eventos y secretos nocturnos

- **Lluvia de estrellas:** días 10 y 25 del mes (M29) 22:00-23:30; partículas caída + TTS "podés pedir un deseo" (M55 diario); jamás con tormenta (M32 valida).
- **Lince de luna:** 1 fijo por mes (día 15 tras luna llena), aparece en Claro del Bosque (M09); interacción "observar" (regala esporas) — siempre opcional.
- **Flora brillante:** en Senda de las Luciérnagas (POI M09); visible 21:00-05:00; cosechable (M33/M15) con recompensa x2 vs día (único bono horario permitido).
- **Murales luminosos (ruinas M25):** solo visibles de noche; lore (M148); sin puzzle obligatorio nocturno.

# 7. Anti-oscuridad (regla de oro)

1. Piso de ambiente nocturno **0.15 LDR** (post-tonemap).
2. Linterna del jugador (M13): rango 12 m, suave, sin sombras parpadeantes.
3. Opción M58 "Noche clara": piso 0.35.
4. Prohibido: negro puro en ambiente, flash total oscuridad en transiciones.
5. QA M114: checklist visual nocturno en todas las zonas (nunca "no veo nada").

# Nota de deriva documentada (2026-10-16, Step-5-WorkBuddy - iter. 4 lote 2, Log 1884)

> Registro pedido por el director (msg 51): regla "manda el dato" - se documenta la deriva como deuda SIN reescribir el diseno ni fabricar contenido nuevo.

- **Tabla de componentes de la sec. 3, fila Sky (item B-P3 del checklist)**: el diseno dice "gradiente por hora (24 puntos), energia 0.18-1.0"; el dato real (data-driven) es sky_curve.tres con piso 0.15 en hora profunda (anti-oscuridad sec. 7) y sky_color_ramp.tres (M49) con 9 paradas.
- **Tabla de componentes de la sec. 3, fila Fog**: el rango "0.08-0.25 por estacion/hora" corresponde al nodo FogVolume volumetrico (K.2, dueno externo M45); el fog del Environment que consume M31 se ancla a la niebla marina autoreada del proyecto (0.00018) y fog_curve.tres gobierna la variacion relativa por hora.

# Presupuestos de ciclo dia-noche (Beam 415, produce-first)
# Luna (esfera + fases del calendario M29)
- Spec: esfera de luna con textura de fases del calendario M29. Luz lunar (DirectionalLight3D, energia 0.12-0.2, color 7500K).
- Fases: nueva, creciente, llena, menguante (4 fases, sincronizadas con M29).
- Coherente con M29 (calendario) y M45 (arte 3D). Sin mesh de luna (solo luz) - esfera visual pendiente de M45.

# Nubes (velo 2D con drift, densidad estacional)
- Spec: velo 2D de nubes con drift lento, densidad estacional (mas densas en invierno, menos en verano).
- Coherente con M49 (iluminacion) y M29 (calendario). Sin implementar (escenico V2).

# Niebla (matinal otonio, bruma verano, densa invierno, nocturna 0.25)

    **Peso de particulas de nieve** (Beam 419, restaurado por el director tras el dedup accidental): peso = densidad_nieve x area_cubierta x factor_viento — coherente con M52 (particulas) y M32 (clima).- Spec: FogVolume ligero (<=120 m) con densidad estacional: matinal otonio, bruma verano, densa invierno, nocturna 0.25.
- Coherente con M49 (iluminacion) y M29 (calendario). fog_curve.tres data por hora EXISTE.

# Flor luminica + cristales estelares nocturnos (M15)
- Spec: flor luminica (respawn estacional) + cristales estelares nocturnos (respawn nocturno).
- Coherente con M15 (recursos) y M29 (calendario).

# Lince de luna (dia 15, Claro del Bosque)
- Spec: fauna especial (lince de luna) que aparece el dia 15 en Claro del Bosque. Interaccion "observar".
- Coherente con M36 (fauna) y M93 (balance). Data de fauna especial.

# Spawn de recursos nocturnos (Beam 424)
- Spec: spawn APAGADO por defecto de noche salvo recurso-opcional: frutas nocturnas + hongos luminicos (opcional que vale la pena de noche; NUNCA critico para progresar).
- Coherente con M31 ciclo (día activo / noche recompensa opcional) y M159 (items).

# Eventos nocturnos (Beam 424)
- LLuvia de estrellas: dias 10 y 25 del calendario M29, windows 22:00-02:00 del juego.
- Deseo-new: observador amministra la intensidad via WorldState (flagcooldown para no doble-cronear).

# Secretos nocturnos (Beam 424)
- Flora brillante (glow mushrooms cluster) + murales de lore que SOLO son visibles de noche (emisivo nocturno).
- Coherente con M59 (secretos) y M162 (lore de dialogos contextuales nocturnos).

— ADENDA de restauración (director 23oct 23:59): las 3 subsecciones fueron escritas por Beam (424, tranche 5) y perdidas por el dedup accidental del director (mi script las confundio con duplicados); restauradas desde mi registro, con la misma autoria. Los items 4-5 de esa tranche (Luna esferica / Nubes velo 2D) NO se duplican aqui: ya existen en Luna/Nubes arriba (mismo alcance).

### Niebla (FogVolume ligero) (Beam 473)
- Spec: data fog_curve.tres define curvas de niebla por hora. M31 consume la curva y configura un FogVolume ligero en la escena. M18/M45 proveen el nodo; M31 provee los valores (densidad por hora/estación). Coherente con M18 (iluminación) y M45 (shaders).

### Prefab de farol con omni 3200K (Beam 473)
- Spec: prefab de farol con luz omni a 3200K (temperatura cálida). M18/M45 proveen el asset; M31 define la temperatura y el rango. Coherente con M18 (iluminación) y M45 (shaders).
### Lluvia de estrellas (días 10 y 25, 22:00-23:30) (Beam 476)
- Spec: fase_umbral.json §estrellas documenta la ventana. El evento se dispara vía M74 (calendario) en los días 10 y 25, entre 22:00 y 23:30. M31 expone es_lluvia_de_estrellas() -> bool consultado por M74 y M52. Coherente con M74 (eventos) y M29 (tiempo).

### Partículas de estrellas fugaces (Beam 476)
- Spec: M52 consume el flag de lluvia de estrellas para instanciar partículas de estrellas fugaces. M31 provee el flag y la ventana horaria; la implementación VFX es de M52. Coherente con M52 (partículas).

### Diario registra deseo de estrellas (Beam 476)
- Spec: M55 (diario) registra un "deseo" cuando el jugador observa la lluvia de estrellas. M31 emite lluvia_de_estrellas_observada (señal) consumida por M55. Coherente con M55 (diario) y M148 (lore).

### TTS/texto accesible en eventos (Beam 476)
- Spec: los eventos nocturnos (lluvia de estrellas, murales) emiten texto accesible consumido por M58 (TTS/accesibilidad). M31 provee los textos localizables (M86); M58 los narra. Coherente con M58 (accesibilidad) y M86 (i18n).

### Faroles cada 40 m en poblado (Beam 476)
- Spec: regla de espaciado de faroles en el poblado: 1 cada 40 m. M18/M45 proveen el prefab; M31 define el espaciado y el umbral de autoswitch (0.35). Coherente con M18 (iluminación) y M45 (shaders).

### Minimapa operable de noche (Beam 476)
- Spec: el minimapa (M12) debe ser operable de noche (sin depender de luz). M31 expone es_de_dia() -> bool y 
ivel_oscuro() -> float para que M12 adapte el contraste. Coherente con M12 (minimapa).

### 1 draw call de nubes (Beam 476)
- Spec: si se implementan nubes, deben renderizarse en 1 draw call (M61). M31 define la regla; la implementación es del dueño escénico (M18/M45). Coherente con M61 (rendimiento) y M18 (iluminación).

### Test: umbral farol antes/después (Beam 476)
- Spec: test que verifica el autoswitch del farol (encendido/apagado) según el umbral 0.35 de nivel de luz. Se escribirá junto con la feature (M18/M45). M31 provee el umbral y el test de referencia. Coherente con M18 (iluminación) y M112 (testing).
### Prefab de farol (omni 3200K, r 8 m, autoswitch 0.35) (Beam 477)
- Spec: prefab de farol con luz omni a 3200K, radio 8 m, autoswitch por umbral 0.35 de nivel de luz. M18/M45 proveen el asset y el autoswitch; M31 define el umbral y la temperatura. Coherente con M18 (iluminación) y M45 (shaders).

### Faroles cada 40 m en poblado (M18) (Beam 477)
- Spec: regla de espaciado de faroles en el poblado: 1 cada 40 m. M18 provee el prefab; M31 define el espaciado. Coherente con M18 (iluminación).

### Sincronización lluvia de estrellas con M52 (Beam 477)
- Spec: M52 sincroniza las partículas de estrellas fugaces con la ventana de lluvia (días 10/25, 22:00-23:30). M31 expone el flag es_lluvia_de_estrellas() y la ventana; M52 consume. Coherente con M52 (partículas) y M74 (eventos).

### Specs items degradados T191 (2026-10-26, Reflection-Beam-1.0)
- **L108 (validación rangos curvas dev mode M110):** test_curvas_luz.gd existe (validación en CI); M110 dev tools sin implementar. Parcial, dueño M110.
- **L121 (M17 faroles sin red eléctrica v1):** M17 sin faroles; puzzle farol_cargado en data/cadenas (M23). Dueño M17/M18.
- **L122 (M13 linterna sugerencia opcional):** 'Linterna' existe en equipment_manager.gd L129 (data) pero sin lógica de mundo; puzzle faro-linterna en test_historias.gd L71-72. Dueño M13/M92.
- **L124 (M37 museo horario):** scripts/museos inexistente; M37 28/148. Dueño M37.
- **L125 (M32 lluvia de estrellas nunca con tormenta):** WeatherService enum sin 'lluvia de estrellas'; evento M74 + partículas M52. Confirmado.
- **L136 (interacción observar del lince):** lince no existe en data/fauna/catalog.json (7 especies). Dueño M36.
- **L137 (flora brillante Senda de las Luciérnagas):** 0 hits; M15 contenido + M45 assets sin crear.
- **L138 (bono x2 de noche en flora):** hook es_de_dia() existe (game_clock L120, time_calendar L155, day_night_cycle L207); implementación bono es M15/M93.
- **L139 (murales luminosos en ruinas M25/M148):** 0 hits; dueños M25/M148.
- **L147 (linterna jugador rango 12m):** data 'Linterna' existe (equipment_manager L129) pero sin lógica de mundo; dueño M13/M45.
- **L149 (opción M58 Noche clara piso 0.35):** M58 sin implementar; piso constante en curva; hook parametrizar sky_curve (K.2, dueño M58).
- **L154 (QA M114 checklist visual nocturno):** M114 sin implementar; QA visual usuario/agente con visión. Dueño M114.
- **L221 (nubes velo 2D drift lento):** sin implementar (0 hits); deuda M45 (K.2).
- **L222 (niebla por estación/hora FogVolume):** fog_curve.tres existe (data) pero nodo FogVolume no en escenas; variación por estación/hora no implementada. Data parcial, nodo ausente. Consumo propio cerrado (day_night_cycle carga fog_curve.tres y aplica niebla_densidad(hora) al Environment).
- **L227 (murales luminosos en ruinas M25/M148):** 0 hits; dueños M25/M148.
- **L228 (opción M58 Noche clara piso 0.35):** M58 sin implementar; piso constante en curva.
- **L229 (integración M49 iluminación global):** M49 sin implementar (0 hits).
- **L230 (QA visual M114):** M114 sin implementar; QA visual.