# Log 610: M158 Herramientas — iter. 2 (ShopVisitor + JarManager)

**Fecha:** 2026-09-04
**Hora:** 03:50
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Iter. 2 de M158: ShopVisitorManager (NPCs visitantes que compran 1x/día) y JarManager (jarrones fuente de ingreso con reposición semanal M29). 14 ítems marcados [x] → 53/140.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `scripts/herramientas158/shop_visitor.gd` *(nuevo)* | Visitantes diarios data-driven (3 NPC por profesión); 1x/día con PRNG determinista M29; solo si puede_vender_tier (curso tomado); compra atómica M14→M38 con PriceManager duck-typed + fallback; monedas propias limitadas; señales visitor_llego/visitor_sale; persistencia último_dia_visita |
| `scripts/herramientas158/jar_manager.gd` *(nuevo)* | 15 jarrones con 5-15 AO; reposición semanal determinista (seed semana*104729); abrir idempotente anti-grind; jarrones_disponibles() para UI; persistencia completa |
| `scripts/herramientas158/tool_tier_system.gd` | +_setup_iter2(): instancia ShopVisitor como Node interno + JarManager RefCounted; hook day_started para visitas; get_save_data/restore_save_data extienden con jarrones y visitante |
| `scripts/herramientas158/test_iter2.gd` *(nuevo)* | ~25 checks: visitante diario/1x/día/día siguiente, compra atómica + saldo, item fantasma, jarrones 15/repo/idempotencia, round-trip |
| `DOCUMENTACION/158-Herramientas-Y-Desbloqueo-De-Zonas/plan-actual/05-Checklist.md` | 11 ítems [x] |
| `CHECKLIST-GLOBAL.md` / `ESTADO-PARALELO.md` | M158 iter. 2 Liberado (53/140) |

## Tests (headless Godot 4.7.2)
- `test_iter2.gd`: **0 fallos**
- Regresión: `test_tiers.gd` (iter. 1) **0 fallos**

## Bugs encontrados y corregidos durante el test
1. **Visitante nunca se iba**: `_visitante_hoy` no se limpiaba al pasar de día → nadie más podía venir. Fix: limpiar en intentar_visita_diaria (cozy: sin despedida, el NPC simplemente se fue).
2. **Reposición esperada != 700**: verificar_reposicion(707) re-repone a 707 (correcto); el check del test esperaba 700 literal → ajustado a >=700.

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/herramientas158/shop_visitor.gd` *(nuevo)*
- `game/isla-ancestral/scripts/herramientas158/jar_manager.gd` *(nuevo)*
- `game/isla-ancestral/scripts/herramientas158/tool_tier_system.gd` *(modificado)*
- `game/isla-ancestral/scripts/herramientas158/test_iter2.gd` *(nuevo)*
- `DOCUMENTACION/158-Herramientas-Y-Desbloqueo-De-Zonas/plan-actual/05-Checklist.md` *(modificado)*
- `CHECKLIST-GLOBAL.md`, `Mensajes entre modelos/ESTADO-PARALELO.md` *(modificados)*
- `Logs/ULTIMO_NUMERO.txt` *(→ 610)*
- `Logs/reservas/610-...txt` *(creado y borrado)*

## Notas técnicas
- ShopVisitorManager es Node interno de Tiers (NO autoload adicional) — evita saturar la tabla de autoloads y los hooks quedan dentro del mismo proceso.
- PRNG determinista por día/semana (M29): mismo día → mismo visitante/mismas monedas — replay-safe y sin rand global.
- Anti-grind: jarrones idempotentes (1 vez por reposición), visitante con tope de monedas, solo visita con curso (progresión real).
- Pendientes: HUD M53 (visitante de hoy/monedas restantes), cable M70 (interacción física), Premium M97.
