# M68 — Transporte y Navegación: Especificación de Infraestructura

**Módulo:** M68
**Autor:** agnes-3-flash (Kilo Code)
**Fecha:** 2026-10-12
**Uso:** Documento de referencia para implementación de puertos, estaciones y vehículos.

---

## B. Infraestructura — Puertos (barco)
- **Paradas tipo barco:** 5 islas principales (Aurora, Isla del Este, Isla del Norte, Isla del Sur, Isla Ancestral).
- **Muelles:** Docking M67 + cartel M46 + marcador M54.
- **Puerto festival:** Temporal (M74), activa 3 días.
- **Docking angosto:** Test con barco de 8m en puerto de 10m.

## C. Infraestructura — Estaciones (dirigible/tren)
- **Plataformas dirigible:** 3 paradas (Aurora, Monte, Cueva).
- **Estación central tren:** Solo si M67 define locomotora.
- **Parada Isla del Este/Norte:** 2 paradas.

## D. Billetes y economía
- **Billete sencillo:** 5 gemas (M38).
- **Billete ida-vuelta:** 8 gemas.
- **Billete semanal:** 20 gemas.
- **Tarifa festival:** Gratis.

## E. Horarios
- **Barco:** Cada 2h (08:00, 10:00, 12:00, ... 20:00).
- **Dirigible:** Cada 1h.
- **Última corrida:** 20:00 (barco), 19:00 (dirigible).
- **Festival:** corridas extra cada 30 min.

## F. Contexto de viaje
- **Bloqueo M21:** diálogo impide embarque.
- **Inventario lleno:** reportado antes del viaje.
- **Dinero justo:** se puede viajar solo si tiene ≥ precio.
- **Última hora:** si es última corrida y no llega, espera al día siguiente.
- **Clima M32:** tormenta = cancelación (reembolso 100%).

## G. Parada recién desbloqueada (M71)
- **M71:** desbloquea parada → M68 activa en grafo.
- **Primer viaje:** gratis (bienvenida).

## H. Docking (M67)
- **Barco:** muelle de 10m, aguantaba.
- **Dirigible:** plataforma de 6×6m.
- **Tren:** andén de 8m (si M67).

## I. Vías y rutas
- **Barco:** 4 rutas circulares.
- **Dirigible:** 2 rutas lineales + 1 circular.
- **Tren:** 1 ruta lineal (si M67).

## J. Waypoints (ya implementado iter 3)
- **`TransportRouteWaypoints`:** modelo puro + validación.
- **Test:** 108 checks / 0 fallos / EXIT 0 ×3.

## K. Eventos de ruta
- **Sin peligro:** NPCs en muelle, no combat.
- **Música:** M41 (tema de viaje).
- **Evento raro:** ballena (1/50 viajes).

## L. Conexión M69
- **M69:** rutas terrestres ↔ M68 marítimas en los puertos.

## M. Localización
- **12h/24h:** configurable M91.
- **Plurales:** "1 parada" / "3 paradas".
