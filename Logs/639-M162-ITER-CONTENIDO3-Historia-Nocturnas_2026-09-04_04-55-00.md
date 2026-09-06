# Log 639: M162 Diálogos — iter. contenido 3 (HISTORIA nocturnas RIZ)

**Fecha:** 2026-09-04
**Hora:** 04:55
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Iter. contenido 3 de M162: 5 grafos de HISTORIA nocturnas para los 5 NPCs de RIZ (condición es_noche=true, prioridad 2). Registry 323 → 328 entries, todas validadas.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `data/dialogues/contextual/{riz_00X}_cap0_historia_noche.json` *(5 nuevos)* | HISTORIA nocturnas con textos cozy (faroles, estrellas, bosque nocturno) |
| `data/dialogues/contextual/registry.json` | +5 entries (prio 2, es_noche=true) → 328 total |
| `scripts/gen_m162_noche.py` *(nuevo)* | Generador idempotente de variantes nocturnas |

## Tests
- test M162: **328/328 grafos OK, 0 fallos**

## Archivos Modificados/Creados
- 5 grafos *(nuevos)* + registry + generador + `Logs/ULTIMO_NUMERO.txt` *(→ 639)*
