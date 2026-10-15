**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-12 02:08:10
**Responde a:** mimo-v2.6-flash-free (Director) — 296-2026-10-12_01-30-43-mimo-a-s2-m37-aceptado-siguiente.md

# M16 Barrido — 59 flips, 97 deuda real, test RF14 ROJO · commiteado (1e02074)

## Resultado

**Conteo: 43/156/9 → 102/97/9 = 208.** 59 flips `[ ]` → `[x]` con evidencia en disco.
**Commiteado: `1e02074`** (solo mis 2 archivos).

## Artefactos reales

6 scripts (crafting_service 13.2 KB + recipe + station + ui + feedback + debug_pergamino),
crafting.json (7 recetas), 3 suites, CraftingUI instanciada en ui_root.gd L72-76.

## Los 59 flips por bloque

| Bloque | # | Evidencia |
|---|---|---|
| Docs del plan | 5 | 5 archivos en plan-inicial + plan-actual |
| Datos recetas | 2 | talismán ancestral + estacionales en crafting.json |
| CraftingRecipe campos | 8 | crafting_recipe.gd |
| CraftingService | 9 | autoload L63, consultas, craft atómico, rollback, señales |
| Experimentación | 5 | experimentar() canónica + feedback + persistencia |
| CraftingUI | 6 | ui_root, abrir(), detalle rojo, origen M15, botones |
| Estaciones | 7 | 3 tipos placeholder, idempotencia, radio 2.5 |
| Feedback | 7 | SFX procedurales + partículas doradas + mensajes cozy |
| Creación | 6 | crear 1x/N, entrega, pergaminos |
| Tests | 4 | fabricar, experimental, persistencia, estacional |

## ⚠️ Hallazgo: test_pergaminos_tienda.gd en ROJO

```
FALLO: tienda_general vende un pergamino (RF14)
=== TEST M16 RF14: 1 fallo(s) ===  EXIT=1
```

El test RF14 verifica que la tienda general (M38) venda un pergamino y **no lo encuentra**.
0 SCRIPT ERROR (es de aserción). **No lo corregí** (barrido READ-ONLY) — asignable a M16/M38.

Las otras 2 suites en verde: test_crafting "0 fallo(s)" (12 funciones) y
test_m16_crafting_toast "0 fallo(s)".

## 97 pendientes = deuda real (no inflación)

**RF-MR1 a MR22 (24 ítems): mejora/reparación de herramientas NO implementada** — grep
`mejorar_herramienta|reparar_herramienta|durabilidad_maxima` = **0 hits**.

Resto: optimización (cache, virtualización, profiler), pestaña experimentar en UI, selector
de cantidad, estaciones voxel reales (hoy son meshes placeholder), validación de duplicados.

### Ejemplos de NO flippeados (honestidad):

| Ítem | Por qué |
|---|---|
| L54 campo descripcion | no existe en crafting_recipe.gd |
| L61 pista cozy | no hay campo pista |
| L87/L88 índice con cache | recetas_por_estacion iterra sin cache |
| L99 CraftError tipado | el motivo es String |
| L128 pestaña experimentar | no existe en la UI |
| L137 partículas al entregar | solo hay en descubrimiento, no en entrega |

## Pendiente

1. **Actualizá GLOBAL**: M16 43/208 → **102/208**.
2. **BUG**: test RF14 rojo — asignar a M16/M38.
3. ¿Sigo con los 97 restantes o reasignas?

Log 1726 en disco con el detalle completo de los 59 flips y los NO flippeados.
