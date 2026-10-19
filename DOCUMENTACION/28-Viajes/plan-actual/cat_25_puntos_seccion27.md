# M28-Viajes — Catálogo de los 25 puntos de la sección 27 del Plan Inicial

**Modelo:** G-5.3-Flash-Agente (GLM-5.3-Flash)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-19 05:45 (UTC)
**Origen:** `DOCUMENTACION/00-PLAN-INICIAL/Plan-inicial-minimo.md` — "27. VIAJES" (25 ítems exactos). Detección del ítem [29] de la cola repoblada del director.

## Estado por punto (mapeado al 05 real de M28-Viajes y rutas del código actual)

| # | Punto (texto literal del plan) | Mapeo | Estado hoy |
|---|---|---|---|
| 1 | Diseñar puerto | RF4 atraque (05 M28) / `[TRP] red cargada: 10 paradas` (travel_service) | parcial |
| 2 | Diseñar barco | P2 barco Gran Vapor (ítem [35] cola) | pendiente |
| 3 | Diseñar dirigible | P3 dirigible (ítem [36] cola) | pendiente |
| 4 | Diseñar submarino | P4 submarino (ítem [37] cola) | pendiente |
| 5 | Diseñar boleto | RF1 boleto y reserva (ítem [30] cola) | pendiente |
| 6 | Diseñar requisitos | RF1 requisitos (M65/M94 gating; M58 desbloqueo) | parcial |
| 7 | Diseñar sistema de reservas | RF1 reserva capacidad → transport_service reserva | parcial |
| 8 | Diseñar animación de embarque | RF3 travesía visible — fase embarque | pendiente |
| 9 | Diseñar pantalla de viaje | RF3 pantalla travesía 20-60 s | parcial (viaje rápido M69) |
| 10 | Diseñar transición | RF4 llegada + transición de escena | parcial |
| 11 | Diseñar llegada | RF4 llegada/atraque automático y desembarque suave (ítem [32]) | pendiente |
| 12 | Diseñar efectos de clima | integración M31 clima en travesía | pendiente |
| 13 | Diseñar calendario | M29 calendario + ferias (viajes según feria) | parcial |
| 14 | Diseñar viajes especiales | viajes especiales (05 M28 tanda anterior) | parcial |
| 15 | Diseñar expediciones secretas | postgame M75 / secretos — sin expedición marina | pendiente |
| 16 | Diseñar viajes nocturnos | ciclo M30 noche — sin viaje nocturno diferenciado | pendiente |
| 17 | Diseñar viajes estacionales | viajes estacionales (M29 estaciones) | pendiente |
| 18 | Diseñar eventos en el trayecto | eventos del trayecto (M74 eventos en ruta) | parcial |
| 19 | Diseñar objetos coleccionables del viaje | M73 coleccionables — sin collector del viaje | pendiente |
| 20 | Diseñar NPC viajeros | M19/M75 viajeros del vapor | parcial |
| 21 | Diseñar transporte de recursos | transporte de recursos — carga y descarga en vapor | pendiente |
| 22 | Diseñar almacenamiento | bodega del vapor — storage en travesía | pendiente |
| 23 | Definir restricciones | restricciones (capacidad + gating) | parcial |
| 24 | Definir costes | RF5 costes (viaje rápido costoso vía M69 — ítem [33]) + boleto | parcial |
| 25 | Definir desbloqueos | M158 tiers/M65 chocobo-equivalente de viaje rápido | parcial |

## Uso previsto (para el dueño del frente M28-Viajes)

- Los 25 puntos son la **checklist maestra de diseño del Gran Vapor** — este catálogo no ejecuta nada: mapea cada punto al RF/cola/estado de hoy para que el dueño retome SIN releer 3.200 líneas del plan.
- Capas ya vivas detectadas en logs del boot: travel_service (10 paradas/20 rutas), travel_service reserva+capacidad, bridges M69 (rápido), M74 eventos, M73 coleccionables — los módulos de apoyo EXISTEN; lo pendiente es el COMPORTAMIENTO Y DISEÑO del trayecto (embarque/pantalla/llegada).
- Los ítems [30]-[37] de la cola repoblada cubren los RF primarios y diseños P2-P4 — este catálogo los relación 1:1 con la sección 27.

Firma: G-5.3-Flash-Agente / Kilo Code.
