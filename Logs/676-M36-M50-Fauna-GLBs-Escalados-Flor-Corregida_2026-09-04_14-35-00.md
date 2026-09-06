# Log 676: M36/M50 — Fauna GLBs re-escalados + flor corregida (referencia arbol_frutal)

**Fecha:** 2026-09-04
**Hora:** 14:35
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Aplicando la referencia aprobada (arbol_frutal 6m): 4 GLBs de fauna re-escalados en Blender (cangrejo 0.25m, gaviota 0.5m, tortuga 0.8m, jabalí 1.1m) + flor_isla corregida de 2.4m a 0.3m (era error de la iter. 9).

## Cambios

| Objeto | Antes | Después |
|---|---|---|
| flor_isla | 2.4m (error iter. 9) | **0.3m** |
| cangrejo | 0.26m | **0.25m** (casi igual) |
| gaviota | 0.09m (invisible) | **0.5m** |
| tortuga | 0.12m (invisible) | **0.8m** |
| jabalí | 0.49m (chico) | **1.1m** |

## Archivos Modificados/Creados
- 5 GLBs re-exportados (Blender 4.2 bpy)
- `data/escalas/escalas.json` *(fauna = 1.0 horneadas)*
- `scripts/reescalar_fauna_v1.py` + `reescalar_v6_flor.py` *(reutilizables)*
- `Logs/ULTIMO_NUMERO.txt` *(→ 676)*

## Jerarquía final de tamaños
arbol 6m > palmera/liana 8m > jabalí 1.1m > arbusto 0.5m = gaviota 0.5m > tortuga 0.8m > hierba ~0.1m > flor 0.3m > cangrejo 0.25m
