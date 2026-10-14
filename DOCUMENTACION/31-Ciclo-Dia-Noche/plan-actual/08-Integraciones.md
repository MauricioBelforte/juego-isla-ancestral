# 08-Integraciones.md — M31: Ciclo Día-Noche

> Consolidación de diseño de integración (Patrón D, 2026-10-13, Hy3 / WorkBuddy).
> Solo se documenta aquí lo ya verificado en 01-04; sin promociones sin evidencia.

## M31 ↔ M63 (Cargas / Horizonte)

- **Dependencia declarada:** M63 figura como dependencia de M31 en
  `01-Requerimientos.md:9` (*"Dependencias: ... M63 (Cargas)"*).
- **Punto de encuentro real:** el gradiente cielo/horizonte por hora de M31
  (`01-Requerimientos.md:22`, RF3; `02-Analisis.md:14`, `ProceduralSkyMaterial`
  gradiente zenith/horizonte por hora) es el insumo de horizonte que consume M63
  (POI/Horizonte) para el descubrimiento anticipado a >=60 m.
- **Estado:** diseño documentado en 01/02. La integración visual M31→M63 es de
  datos (hora/fase) y no requiere código nuevo en M31. **Sin `[x]` que cerrar
  aquí** (la sección F del 05-Checklist ya registra consumidores verificados).

## M31 ↔ M32 (Clima)

- **Coordinación documentada:**
  - `03-Diseno.md:73` — *"Lluvia de estrellas ... jamás con tormenta (M32 valida)"*.
  - `02-Analisis.md:28-29` — eventos nocturnos coordinados con M32 (tormenta).
  - `05-Checklist.md:125` (sección F) — *"M32 Clima: lluvia de estrellas nunca con
    tormenta — WeatherService enum sin 'lluvia de estrellas' ... coordinación de
    dueños, no código M31"* (marcado `[?]`, dueño M32).
- **Estado:** la integración está documentada como coordinación de dueños (M32
  emite la señal; M31 consume fase). El item sigue `[?]` porque es deuda de
  implementación de M32, no de M31. **No se cierra.**

## Nota de cierre

Las dos integraciones asignadas (M63 horizonte, M32 clima) ya estaban documentadas
en 01-04 y registradas en la sección F del 05-Checklist. Esta consolidación solo
las hace explícitas en un archivo dedicado; no promueve ningún `[ ]`/`[?]` sin
evidencia adicional.
