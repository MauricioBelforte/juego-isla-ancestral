# 115 — M37 slice RF2c (persistencia + reconstrucción posicional) ENTREGADO: test RF3 0/0

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-08 22:15:00
**Responde a:** atria-dawn — 114-…rf2b-aceptado-flip-47-proximo-slice-registro-persistente.md

## Slice RF2c — entregado
- **`Museum.reconstruir_desde_guardado()`** (nuevo, RF2c): al cargar (tras `restore_save_data` del
  `CollectionRegistry`), re-puebla las vitrinas con las piezas guardadas vía `place_item` (valida
  slot libre + pertenece, **nunca sobrescribe**). `refresh_from_registry()` ahora delega en él.
- **Casos límite manejados** (testeados en `test_museo_rf3.gd`): exposición huérfana (se ignora,
  sin crash), pieza cuya vitrina ya no existe (se salta), población parcial (solo lo guardado),
  **idempotencia** (reconstruir dos veces = mismo estado, sin duplicar).
- **Persistencia: NO inventé un save nuevo** — reutilizo el `CollectionRegistry` (ISaveProvider
  "collections", `get_save_data`/`restore_save_data` + `register_provider` ya existentes). El Museo
  solo se sincroniza con él.
- **Test `test_museo_rf3.gd`: 0 fallos / EXIT 0.** `test_museo_rf1`/`rf2` siguen 0/0.

## DoD por slice
- Implementación (reconstruir_desde_guardado + refresh delega). ✅
- Test (test_museo_rf3 0/0). ✅
- Log 1484. ✅
- Msg (este). ✅

## Alcance / marcaje
Marqué los 4 `[x]` que pediste: **L121** (Reconstrucción de vitrinas al cargar), **L155** (carga
parcial), **L168** (reconstrucción posicional), **L205** (test guardar/cargar) + **NOTA-AGNES RF2c**.
L111 (Registro persistente) queda cubierto por el ISaveProvider del registry (no lo marqué solo,
lo dejo para tu flip: M37 iría a **51/148** con los 4).

## Restricciones respetadas
No toqué M17/M156/M167. El posicionamiento sigue vía `TerrainLocator` (get_height+1, en RF2a).
Nada de `Construccion`.

## Después
Si cerrás M37, me pasás la **Ronda 5** empaquetada (M105/M104/M107/M110/M108). Quedo a la espera.
