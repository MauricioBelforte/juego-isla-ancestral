# Log 141: Expansión M160 — Mapa Detallado 4 Islas (60 ubicaciones)

**Fecha:** 2026-08-24
**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

## Resumen
Expansión completa de M160 (Diseño de Ubicaciones del Mundo) de 46 a 60 ubicaciones detalladas en las 4 islas del juego. Cada ubicación incluye objetos fijos con IDs M159, conexiones inter-islas y puntos de recolección.

## Cambios Realizados

### M160 — Expansión de 46 a 60 ubicaciones

**Isla Raíz (RIZ): 18 ubicaciones** (antes 12)
- 5 casas NPC detalladas (Luna, Rocky, Merc, Chamán, jugador)
- Monte de la Tribu (Chamán del Monte M163) con objetos ritual
- Todos los objetos con IDs M159 y posiciones

**Isla Coral (COR): 15 ubicaciones** (antes 12)
- 2 casas NPC (Perla joyera, Ola pescador)
- Ferretería tropical (Nácar) con herramientas T2
- Pescadería (Concha) con peces frescos
- Playa de coral, Arrecife, Cataratas, Cueva del Coral
- Monte Vigía con vista panorámica

**Isla Ceniza (CEN): 14 ubicaciones** (antes 11)
- Casa del Herrero Avanzado (Pedro)
- Mina Abandonada con minerales T2/T3
- Cueva Profunda con obsidiana y ruinas ancestrales
- Ruinas de la Forja con forja ancestral interactiva

**Isla Aurora (AUR): 13 ubicaciones** (antes 11)
- 3 casas NPC (Elena joyera, Pedro minero, Carlos cristalero)
- Bosque Nieve con bayas árticas
- Lago Cristal con pesca de hielo
- Glaciar con fósiles
- Cueva de Hielo con hielo ancestral
- Templo Ancestral (final del juego, requiere T4 + 4 llaves)

### CHECKLIST-GLOBAL.md actualizado
- M160: de 46 a 60 ubicaciones documentadas
- Notas actualizadas con nuevo conteo de ubicaciones

### Totales por isla
| Isla | Antes | Después | Tipos |
|------|-------|---------|-------|
| RIZ | 12 | 18 | PUB, CASA×5, TIE, TAL, CUE, BOS×3, PLA×2, RUI, PUER, MON |
| COR | 12 | 15 | PUB, CASA×2, TIE×2, SEL×2, PLA×2, CUE, MON, PUER |
| CEN | 11 | 14 | PUB, CASA, TIE, TAL, CUE×2, BOS, RUI, PUER, MON×2 |
| AUR | 11 | 13 | PUB, CASA×3, TIE, TAL, NIE×2, LAG, GLA, CUE, TEM, PUER |
| **Total** | **46** | **60** | |

## Archivos Modificados/Creados
- `DOCUMENTACION/160-Diseno-De-Ubicaciones-Del-Mundo/plan-actual/03-Diseno.md` — Expansión de 46 a 60 ubicaciones con detalle completo
- `CHECKLIST-GLOBAL.md` — Actualizado M160 con nuevo conteo de ubicaciones
