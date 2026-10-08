# Log 1454: Frente 95 — M37 Sustentado + BUG-106 (catálogos M39→M15) + M66 (fix test falso-verde)

**Fecha:** 2026-10-08
**Hora:** 05:56
**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code

## Resumen
Frente 95 (directriz del fundador: nadie reposa hasta que él diga) — 3 tareas. Reporte en mi canal: 96.

## M37 (TAREA 1)
- Conteo 36 [x] / 0 [?] / 112 [ ] = 148 (coincide con el director).
- 36 [x] SUSTENTADOS: artefactos reales (collection_registry.gd 292l, donation_service.gd 95l,
  exhibiciones.json) + test_museo.gd 0/0 EXIT 0. No INFLADO.
- Correción: M37 es **Museos-Y-Colecciones**, no "Logging/Telemetría" (el director lo nombró mal).
- Reclamo: GLOBAL M37 → agnes-3-flash 🔵 (NO lo toco, es del director).

## BUG-106 (TAREA 2) — CERRADO
- Causa: 8 item_ids de M39 = nombres de NODOS M15 que el ItemDatabase M15 no tiene (8/8 ausentes
  vía get_item) → 8 WARNINGs reales de boot.
- Fix: mapeo por el campo nombre de M15 en scripts/shops/catalogo_tiendas.gd (24 ocurrencias):
  madera_roble→wood, piedra_caliza→stone, baya_roja→OBJ-ITE-024, mineral_cobre→copper_ore,
  fragmento_ancestral→OBJ-ART-003, pergamino_rec_tela_lino→OBJ-ART-002, herramienta_basica→OBJ-HER-001,
  fibra_algodon→grass (⚠️ M15 no tiene fibra = sustituto, flag). Verifiqué: mapeados 0/8 ausentes.
- Guardián: test_catalogo_m39_m15.gd (8/8 ∈ M15, EXIT 0). M39 perf sigue EXIT 0. No toqué M15.

## M66 (TAREA 3) — fix test falso-verde CERRADO
- Era: _check(true) guardado/transición + ClassDB… or true + set_script(RefCounted)-sobre-Node
  (ERROR ignorado).
- Fix (SOLO test, producción intacta): test_m66_handler.gd (M66HandlerRegistro, IRecoverable concreto)
  + checks concretos + retiro de or true. Suite test_anti_softlock_m66.gd: 0 fallos / 0 SCRIPT ERROR /
  EXIT 0. Fail-true verificado (rojo al desactivar registrar_handler, verde al restaurar).
- BUG LATENTE en producción (NO tocado): softlock_guard.gd:133 inv.get("categoria",0) = get de 2 args
  sobre Object → ERROR solo cuando una invariante está rota (early-return lo mascara). Queda para el
  dueño de M66.

## Archivos
- scripts/shops/catalogo_tiendas.gd (mapeo BUG-106 + comentario de trazabilidad)
- scripts/shops/test_catalogo_m39_m15.gd (nuevo, guardián anti-regresión)
- scripts/shops/test_bug106_verify.gd (diagnóstico 8/8 ausentes → 0/8 mapeados)
- scripts/core/test_anti_softlock_m66.gd (fix falsos-verdes)
- scripts/core/test_m66_handler.gd (nuevo helper M66HandlerRegistro)
- (borrado test_m66_inv_ruta.gd: su inyección tocaba el bug latente de producción)
- Reporte 96. Sin commit ni push.

— agnes-3-flash / Kilo Code
