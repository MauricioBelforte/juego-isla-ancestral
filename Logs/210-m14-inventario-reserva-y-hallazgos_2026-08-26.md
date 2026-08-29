# Log 210: M14 Inventario — reserva de módulo y hallazgos previos a implementación

**Fecha:** 2026-08-26
**Modelo:** ox-alpha
**Plataforma:** Cline

## Resumen
Se reservó el módulo 14 (Inventario, Alta, complejidad 3) en CHECKLIST-GLOBAL y ESTADO-PARALELO, y se ejecutó la fase de **documentación de hallazgos** previa a codificar (directiva del usuario): cruce del diseño vigente contra los módulos ya implementados (M59 Guardado, M159 Catálogo, M13 Herramientas, M39 Tiendas) y la skill `godot-inventory-system` de `.claude/skills/`.

## Hallazgos documentados (resumen — detalle completo en plan-actual/04-Codigo.md §Análisis previo)

1. **H1 CRÍTICO — Colisión `class_name ItemData`:** M159 ya definió la clase. El módulo debe EXTENDER ese Resource, no duplicarlo (rompería catálogo y preview M13).
2. **H2 CRÍTICO — Nombre del autoload fijado:** ShopManager (M39) ya espera `/root/Inventario` con adaptadores `agregar_items()/remover_items()`. El autoload se registra como `Inventario`, no `InventoryService`.
3. **H3 — Catálogo existente:** no crear `item_catalog.gd`; reutilizar el autoload ItemDatabase (M159).
4. **H4 — Slots con instancia:** las herramientas de M13 tienen durabilidad por instancia → InventorySlot necesita campo `instancia: Dictionary` (serialización de ToolData).
5. **H5 — Patrones adoptados de la skill godot-inventory-system:** items como Resource nunca Nodes; add en dos pasadas con sobrante int; señal batched única tras loops; persistencia solo ids+cantidades+instancia; duplicate(true) sobre blueprints compartidos.
6. **H6 — Primer ISaveProvider real:** el inventario será el primer proveedor del SaveManager (M59), validando checksum/backups end-to-end.
7. **H7 — Rutas reales:** `scripts/inventario/` (no `src/inventario/` como decía el diseño).
8. **H8 — Alcance iteración 1 propuesto:** núcleo de datos + servicio autoload + ISaveProvider; UI/cofres después.

## Cambios Realizados
- CHECKLIST-GLOBAL.md: fila 14 → 🔵 Reservado por ox-alpha (Cline).
- ESTADO-PARALELO.md: reserva registrada.
- DOCUMENTACION/14-Inventario/plan-actual/04-Codigo.md: nueva sección "Análisis previo a la implementación — Hallazgos" (H1-H8) con decisiones; encabezado histórico de Deepseek V4 Flash restaurado.

## Archivos Modificados
- CHECKLIST-GLOBAL.md
- Mensajes entre modelos/ESTADO-PARALELO.md
- DOCUMENTACION/14-Inventario/plan-actual/04-Codigo.md

## Próximo paso
Con los hallazgos asentados, la siguiente sesión puede implementar directamente la iteración 1 (H8) sin re-analizar: el diseño está cruzado contra la realidad del código existente.
