**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 32: Clima

## 1. Archivos involucrados (previstos)

| Archivo | Tipo | Rol |
|---|---|---|
| `res://world/weather/weather_service.gd` | Node (autoload M07) | Determinismo, selección diaria, intensidad, API pública |
| `res://world/weather/particulas_clima.gd` | Node3D | 1 sistema GPU compartido (lluvia/nieve/hojas) |
| `res://world/weather/particulas_clima.tscn` | Escena | Densidades por clima + calidad (M90) |
| `res://data/weather/clima_config.tres` | Data | Probabilidades, duraciones, atenuaciones, volúmenes |
| `res://data/weather/eventos_tabla.tres` | Data | Aurora/arcoíris/posposiciones |
| `res://ui/hud/banner_clima.gd` | UI | Banner + aviso de tormenta mañana (lee M29/M30) |
| `res://tests/caso_clima_tests.gd` | Test | Suite M112 (determinismo, transiciones, validaciones) |

## 2. Contrato de datos

```
CLIMA = { SOLEADO, NUBLADO, LLUVIA, TORMENTA, NIEBLA, NIEVE, VIENTO, TROPICAL, ESPECIAL }

clima_config.tres:
  por_clima = {
    LLUVIA:   { prob_estacion: {P:0.18, V:0.08, O:0.12, I:0.05}, dur_min: 120, dur_max: 240,
                sol: 0.70, particulas: "lluvia_fina", audio_bus: "lluvia" },
    TORMENTA: { prob_estacion: {P:0.06, V:0.10, O:0.04, I:0.02}, dur_max: 180, sol: 0.35,
                particulas: "lluvia_densa", audio_bus: "tormenta" },
    ...
  }
```

## 3. Pendientes de implementación (dueño: AGENTE DELEGADO)

| Pendiente | Nota |
|---|---|
| `weather_service.gd` (determinismo + API) | Indispensable tras GameClock (M29) y la franjas (M31) |
| `particulas_clima` (1 sistema compartido) | Con M61 (presupuesto 1 ms) y M90 (calidad) |
| Integración con M31 (atenuación de luz) | Solo lee `get_intensidad()` — sin estado duplicado |
| Integración con M42 (buses) y M41 (variante lluvia) | Crossfade 60-90 s |
| Banner climático (M30 HUD) | Aviso: "Mañana: tormenta" |
| Suite de tests M112 | Determinismo (mismo seed+día ⇒ mismo clima), validación aurora/estrellas, nunca 2 tormentas seguidas, transiciones sin corte de intensidad |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 20:10:00
**Estado:** Documentación de diseño completa (módulo delegable)

### Lo que hice
- 25/25 puntos de la sección 31 resueltos (tabla en 02-Analisis).
- Catálogo de 9 climas con probabilidades estacionales, duraciones, atenuación de sol y partículas.
- Determinismo (seed, día) documentado con fórmula — sin exploits de recarga.
- Regla de oro: clima jamás bloquea/destruye/castiga (bono sí, bloqueo no); alineado con M152 de DEVIN.
- Validaciones mutuas: lluvia de estrellas (M31) ↔ tormenta; aurora con despejado.

### Lo que NO hice (honestidad obligatoria)
- Implementar: requiere M29/M31 existentes (hito M1). Dueño: AGENTE DELEGADO.
- No fijé assets de partículas ni nombres finales de materiales (M45/M47 los producen).

### Recomendaciones para el próximo agente
- Implementar WeatherService como autoload puro sin leer el calendario (todo por API M29).
- El determinismo por (seed, día) debe estar probado antes que cualquier efecto visual (es la base anti-exploit).
- Los consumidores (NPC/fauna/agri/pesca) deben escuchar señales, nunca consultar internals.