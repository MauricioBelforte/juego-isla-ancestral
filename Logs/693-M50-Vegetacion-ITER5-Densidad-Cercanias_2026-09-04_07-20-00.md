# Log 663: M50 Vegetación — iter. 5 (densidad + cercanías del spawn)

**Fecha:** 2026-09-04
**Hora:** 07:20
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Iter. 5 de M50: densidad de vegetación aumentada (8-12 → 10-25 por bioma) y nuevo bioma "cercanias" con 30 instancias en radio 0.15-0.55 del centro — cerca del spawn del jugador (a ~90 unidades del centro). Total: 45 → **114 instancias**.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `data/vegetacion/vegetacion_config.json` | v2: densidades x2 (pradera 12→25, bosque 10→22, etc.) + palmera_joven en playa + bioma "cercanias" (30 instancias de hierba/flor/arbusto/helecho) |
| `scripts/vegetacion/vegetation_plan.gd` | +zona "cercanias" (_anillo 0.15-0.55) — vegetación visible desde el primer frame del spawn |

## Tests (headless)
- Boot: `[M50] Vegetación poblada: 114 instancias, 0 omitidas` (antes 45)
- Sin errores nuevos

## Archivos Modificados/Creados
- `game/isla-ancestral/data/vegetacion/vegetacion_config.json` *(v2)*
- `game/isla-ancestral/scripts/vegetacion/vegetation_plan.gd` *(zona cercanias)*
- `Logs/ULTIMO_NUMERO.txt` *(→ 663)*
- `Logs/reservas/663-...txt` *(creada y borrada)*

## Pendiente V2 con el usuario
- Verificar visualmente que la vegetación es visible desde el spawn (moverse un poco)
- Verificar escala de los GLBs
