**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 29: Tiempo y Calendario

## 1. Carácter del Componente

Módulo **totalmente delegable para implementación** por otro agente: es un servicio puro (sin voxel, sin assets, sin física). Implementable en cuanto exista el esqueleto del proyecto (M1) y el ServiceLocator (M07), o incluso en paralelo con su propio scaffolding mínimo.

**06-Plan-Testings.md:** NO aplica hoy (la edición de tests unitarios del GameClock se implementa junto con M112 Testing Automático — el cron de fechas se cubre ahí). Se recomienda incluir tests del calendario (bisiesto no aplica: años de 336 días fijos).

## 2. Archivos involucrados (implementación)

```
scripts/time/game_clock.gd            → servicio GameClock (API del diseño 03)
scripts/time/date_model.gd            → struct Fecha (día/mes/año) + conversiones
scripts/time/event_catalog.gd         → calendario de eventos (Resource)
data/time/time_config.tres            → constantes de duración (knobs)
data/time/festivals.tres              → festivales + cumpleaños (contenido M74)
```

## 3. Contratos de integración

- **Registro:** `ServiceRegistry.register("game_clock", game_clock)` (M07).
- **Salida:** señales `dia_cambio`, `hora_cambio`, `estacion_cambio`, `evento_activado` → EventBus.time (M07).
- **Persistencia:** `GameState.M29 = { fecha, hora, eventos_visitados, proximo_evento }` (M59).
- **Consumidores:** M30 (reloj UI), M31 (iluminación), M33 (cultivos), M19 (NPC rutinas), M74 (eventos), M36 (fauna).

## 4. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Implementación del servicio GameClock + tests unitarios | **AGENTE DELEGADO** (módulo delegable) |
| Calibración de duración del día (24 min) por playtest | M114 (playtest) |
| Contenido de festivales (planos, decoración, diálogos) | M74 + M21 (contenido) |
| Nombres de meses/días finales | M149 (nomenclatura) |
| Integración con la cama (avance temporal) | M31 (cama) |

## 5. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 06:40:00
**Estado:** Completado (diseño; implementación delegada)

### Lo que hice
- Resolví los 24 puntos de la sección 28 del plan maestro.
- Diseñé el servicio GameClock con API completa y calendario de Aurora (día 24 min, mes 28 días, año 336 días, 4 estaciones).
- Catálogo de eventos periódicos completo (diario → anual) con regla anti-frustración (repetibles).
- Contrato de persistencia y tabla de consumidores.

### Lo que NO pude hacer (honestidad obligatoria)
- Implementar el servicio → queda para el agente delegado (es el propósito de este módulo).
- Contenido de festivales → M74/M21.
- Nombres finales de meses → M149.

### Recomendaciones para el próximo agente (implementador)
- Usar la API pública del 03-Diseno sin modificarla (los consumidores están diseñados contra ella).
- El reloj NO debe correr offline ni retroceder; solo avanza en sesión con pausas explícitas.
- Incluir tests: cambio de día/semana/mes/estación/año y eventos (día 336 → año 2).