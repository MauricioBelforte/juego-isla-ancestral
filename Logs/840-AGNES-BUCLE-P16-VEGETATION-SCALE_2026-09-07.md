# Log 771: M50 Vegetación — ajuste de escalas GLB

**Fecha:** 2026-09-07
**Hora:** 04:10
**Modelo:** agnes-2.5-flash
**Plataforma:** Kilo Code

## Resumen
Ajuste de escalas de vegetación en escalas.json para mejorar visibilidad.

## Cambios Realizados

### Datos
- **data/escalas/escalas.json**: actualizadas escalas de vegetación
  - palmera: 1.0 → 4.0
  - arbol_frutal: 1.0 → 3.0
  - arbol_roble: 3.5 (existente)
  - arbusto: 1.0 (mantenido)
  - hierba_alta: 1.5 → 0.8
  - flor: 0.5 (nuevo)
  - helecho: 0.6 (nuevo)

### Checklist M50
- Item escala correcta por tipo → [x]

## Estado M50
- Antes: 29/142 (20%)
- Después: 30/142 (21%)
- Pendientes: 39 sin dueño (GLBs existen, escalas ajustadas)

## Nota
Los GLBs de vegetación (15 archivos) ya existen en assets/3d/media/.
Las escalas ahora deberían ser visibles en el juego.
Requiere recargar EscalasGlobales (autoload) para aplicar cambios.
