# Log 796: M09 — impostor optimizado (paso 64m + paredes condicionales)

**Fecha:** 2026-09-08
**Hora:** 08:10
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Optimización del impostor heightmap tras el tildo reportado con el paso 32m + paredes dobles visibles simultáneas en el frustum (GPU integrada saturada por el overdraw):
1. **Paso 32m → 64m**: 4× menos celdas (muestreo y geometría).
2. **Paredes condicionales**: pared SOLO si el vecino es ≥2m más bajo (acantilados reales) — antes 4 paredes por celda siempre; ahora solo en los bordes que importan. Triángulos de pared ≈ −75%.
3. Umbral de ocultamiento: 400m (el impostor es visible desde muy cerca).

## Resultado
- Boot: `[M09-IMP] impostor heightmap completo: 42 tiles activos — ocultos <400m` — 0 errores, sin tildes en el boot.
- Capturas tomadas (`capturas_m51/umbral400_*.png`).

## Archivos Modificados
- `game/isla-ancestral/scripts/world/terreno_horizonte.gd` (paso 64 + paredes condicionales + umbral 400)
