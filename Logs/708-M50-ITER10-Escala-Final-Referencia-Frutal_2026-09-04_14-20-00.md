# Log 708: M50 Vegetación — iter. 10 (escala final con referencia arbol_frutal)

**Fecha:** 2026-09-04
**Hora:** 14:20
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Iter. 10 con feedback del usuario: **arbol_frutal (6m) = referencia aprobada**. Re-escalados en Blender: palmeras ×1.6 (5m→8m), lianas ×2 (4m→8m), arbustos ×0.5 (1m→0.5m). Hierba runtime 6x→1.5x (más baja).

## Ajustes del usuario → aplicados

| Objeto | Antes | Después | Cómo |
|---|---|---|---|
| palmera | 5m (chica) | **8m** | Blender, horneado |
| palmera_inclinada | 5m (chica) | **8m** | Blender, horneado |
| liana_colgante | 4m (pequeña) | **8m** | Blender, horneado |
| arbusto_redondo | 1m (grande) | **0.5m** | Blender, horneado |
| arbusto_floral | 1m (grande) | **0.5m** | Blender, horneado |
| hierba_alta | runtime 6x (alta) | **runtime 1.5x** | escalas.json |
| arbol_frutal | 6m | 6m | **referencia** ✓ |

## Archivos Modificados/Creados
- 5 GLBs re-exportados (Blender 4.2 bpy)
- `data/escalas/escalas.json` *(palmeras/arbustos/lianas = 1.0, hierba = 1.5)*
- `scripts/reescalar_v5.py` *(reutilizable)*
- `Logs/ULTIMO_NUMERO.txt` *(→ 675)*

## Jerarquía de alturas resultante
arbol_frutal 6m > palmera 8m* ≈ liana 8m* > arbusto 0.5m > hierba ~0.1m
*las palmeras superan al árbol frutal pero su copa está arriba — el tronco visible es menor
