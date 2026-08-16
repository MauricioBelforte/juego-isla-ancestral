**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 32: Clima

## 1. Arquitectura

```
GameClock (M29) ── día/estación ──► WeatherService.gd (M32)
                                       │ (determinista: seed + día_del_año)
        ┌──────────────┬──────────────┼──────────────────┬────────────────┐
        ▼              ▼              ▼                  ▼                ▼
   PARTICULAS      AUDIO M42     LUZ (M31)         MUNDO (M50/M51)    EVENTOS
   (1 sistema)   (buses clima)  (atenuación)      (sway/agua/nieve)  (aurora,
        │              │              │                  │             arcoíris)
        ▼
   CONSUMIDORES: M19 NPC · M33 Agri · M34 Pesca · M36 Fauna
        ▼
   UI (M30): banner de clima + aviso de tormenta (1 día antes, vía M29)
```

## 2. Catálogo de climas (data-driven)

| Clima | Estación | Prob (def) | Duración (juego) | Sol | Partículas | Notas |
|---|---|---|---|---|---|---|
| SOLEADO | todas | Primavera 40% / Verano 60% / Otoño 35% / Invierno 25% | 2-4 h | 1.0 | — | base |
| NUBLADO | todas | 30% | 2-3 h | 0.85 | — | — |
| LLUVIA | P, O | 18% / 12% | 2-4 h | 0.70 | lluvia fina | riega M33 |
| TORMENTA | P, V | 6% / 10% | ≤3 h | 0.35 | lluvia densa | aviso previo |
| NIEBLA | O, I | 10% / 15% | 2-3 h | 0.60 | — | visual 120 m |
| NIEVE | Invierno | 25% | 3-6 h | 1.10 | nieve leve | cubierta M08 |
| VIENTO | O, I | 15% | 2-3 h | 1.0 | hojas/polen | estético |
| TROPICAL | Verano | 2-4/año | 2-3 h | 0.35 | lluvia+hojas | rarísima |
| ESPECIAL | — | por calendario | 0.5-1 h | varía | — | aurora/arcoíris |

> Las probabilidades se aplican SOLO al seleccionar el clima del día (determinista). El clima **profundo** (tormenta/tropical) nunca dos días seguidos (garantía cozy).

## 3. Determinismo (fórmula)

```
dia = fecha.dia_del_ano()            # 1..336 (M29)
rng  = PRNG(semilla_partida, dia)    # semilla múltiplo de 7919 (dev seed estable)
clima = tabla_estacional[estacion][rng.randf()]
intensidad inicial = 0 → rampa a 1 en [60, 90] s de juego
```

- `GameState.M32` guarda: `semilla_clima`, `clima_actual`, `intensidad`, `clima_mañana`.
- Al cargar: recomputa `clima(dia)` y valida contra guardado (si difieren, gana el recomputado — nunca data corrupta).

## 4. API pública

```
WeatherService (autoload/único, M07):
  get_clima() -> CLIMA                 # enum
  get_intensidad() -> float            # 0..1 (transición)
  es_precipitacion() -> bool           # lluvia/nieve/tormenta/tropical
  clima_de_mañana() -> CLIMA           # para el aviso (M30/M29)
  EventBus.weather.clima_cambio(CLIMA)
  EventBus.weather.intensidad_cambio(float)
```

## 5. Transiciones

1. `clima_cambio` a medianoche del juego (M29) — o por evento especial (aurora).
2. Intensidad 0→1 (o 1→0) tween lineal en 60-90 s; partículas con densidad = `intensidad * densidad_clima`.
3. Audio: los buses de M42 cruzan volúmenes en la misma ventana (no instantáneo).
4. La luz de M31 consulta `get_intensidad()` para la atenuación (tabla del Análisis punto 15) — sin duplicar estado.

## 6. Efectos por consumidor (resumen)

- **M19 NPC:** refugio en tormenta (path a refugio más cercano, M09 POIs), paraguas cosmético en lluvia.
- **M33 Agri:** lluvia ⇒ regado automático (mismo día); invernadero neutraliza nieve; tormenta sin daño.
- **M34 Pesca:** lluvia +15% raro; tropical +25% raro; niebla como siempre.
- **M36 Fauna:** spawns condicionados (anfibios con lluvia; aves anidadas en tormenta).
- **M50/M51:** sway y ondas por `get_intensidad()` (no estado propio).
- **M28/M69 Viajes:** el clima jamás cancela.

## 7. Eventos especiales (reglas de validación)

- Aurora boreal: día fijo de Invierno (M29), 21:00-04:00, solo cielo despejado (reemplaza el clima del día por "despejado" esas horas).
- Lluvia de estrellas (M31): requiere despejado; si el día tiene tormenta → se pospone al primer día despejado siguiente (M29 avisará con 1 día).
- Arcoíris: 30 min de juego tras terminar lluvia/tormenta con sol ≥ 0.9; cosmético.

## 8. Accesibilidad (M58) — datos

| Opción | Efecto |
|---|---|
| Reducir clima | densidad de partículas -50% |
| Sin truenos | silencia bus de truenos (fotosensibilidad) |
| Niebla reducida | distancia visual 80% (logos coherentes) |
| Banner climático | siempre hay texto (nunca solo imagen) |