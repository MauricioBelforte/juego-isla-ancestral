**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Módulo:** 61-Rendimiento (iteración agnes acotada, Log 943)
**Fecha:** 2026-09-16

# Checklist personal — M61 Rendimiento (iter. agnes, acotada)

> Encaje A: data-driven + gate CI + headless (V0). **Alcance deliberadamente limitado** a la dimensión de
> CANTIDAD del gate. Metodología completa (bench visual V2, CI M116, técnicas LOD/pooling) = dueño M61.

## Iteración agnes (Log 943)
- [x] Relevo §21.4.7 de la reserva agnes-2.5 stale (09-03) → M61 en curso por agnes-3-flash
- [x] `budgets.json`: bloque `limites` (`particulas_simultaneas_max` 500 / `draw_calls_max` 400 / `objetos_mundo_max` 1000)
- [x] `validate_budget.gd`: `_validar_limites()` + `_medicion_dentro_limites()` (tolerante si el bloque falta)
- [x] Gate headless: 0 fallos, exit 0, 0 `SCRIPT ERROR` (incl. trampa de tipos del linter estricto)
- [x] §M "≤500 partículas/cámara" → `[x]` con evidencia en `05-Checklist.md` M61
- [x] Nota en `04-Codigo.md` M61 (§Iteración agnes) + CHECKLIST-GLOBAL fila 61 → 🟡 Liberado

## Pendiente (fuera de mi alcance acotado — para el dueño M61 o próxima iter. con visión)
- [ ] Contador runtime de partículas (que M52 no exceda 500 en ejecución) — **dueño M52**
- [ ] Bench visual V2 (frame render per-category vs `frame_total`) y gate CI M116 — **dueño M61/V2**
- [ ] Técnicas de optimización (LOD/pooling/batching terreno) — **dueños M07/M50**
- [ ] `QA note §Visual 2026-08-30 (M61)`: "Draw calls 400-471 superan objetivo" → re-verificar post-optimización

## Reglas de uso
- No afirmar "M61 completo": mi iteración es acotada; el estado global de M61 sigue 🟡.
- QA cruzado §21.8 del Log 943 lo hace un verificador ≠ agnes-3-flash.
