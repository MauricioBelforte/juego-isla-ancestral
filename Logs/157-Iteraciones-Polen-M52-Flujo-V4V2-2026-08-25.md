# Log 157: Iteraciones Visuales Polen M52 con Flujo V4+V2

**Fecha:** 2026-08-25
**Modelo:** ox-alpha
**Plataforma:** Cline

## Resumen
Primera iteración de diseño visual usando exclusivamente el flujo V4 (lanzar juego) + V2 (MCP screen para capturar y analizar). Dos iteraciones sobre el polen del preview M52, cada una con captura de evidencia.

## Cambios Realizados
- **Iter 3:** turbulencia habilitada (strength 0.4, scale 1.8, influence 0.1–0.4), gravedad reducida (0.05→0.02), damping 0.1–0.3, velocidad inicial menor, amount 150→220, lifetime 6→9. Resultado: deriva orgánica; FPS 24 inicial resultó transitorio (confirmado 59 en iter3b).
- **Iter 4:** emisión cambiada de punto a caja ancha (extents 3.5×0.5×1.0) porque el polen se amontonaba en una columna. Resultado final: polen distribuido por toda la escena, flotando a distintas alturas, FPS 59.
- Capturas guardadas en el historial del módulo: `cap_52_iter3-turbulencia-flotante.png`, `cap_52_iter3b-check-fps.png`, `cap_52_iter4-emision-caja-ancha.png`.

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/particles/preview_particles.gd` (turbulencia + emisión en caja)
- `tools/mcp/godot-mcp/capturas/52-Particulas-Y-VFX/` (3 capturas nuevas)
- `DOCUMENTACION/52-Particulas-Y-VFX/plan-actual/05-Checklist.md` (sección Z2)
