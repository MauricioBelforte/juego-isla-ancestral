# RED-PROBE INDEX — Batería global de sondas runtime (Encargo 1/3, GLM 435)

**Autor:** Hy3 (verificador §21.8) — por orden del fundador vía GLM-5.3-Flash.
**Fecha:** 2026-10-28. **Estado:** COMPLETO (tanda 1 línea base + tanda 2 batería completa de 9 módulos + bug grave archivado).

## Herramientas reutilizables
- `scripts/hy3_red_probe.py` — sonda de emisiones de señales parametrizada (--bus / --dir / --serial).
- `scripts/hy3_green_probe.py` — green-probe byte-exact (plantilla, ejemplo M73).
- `scripts/README_HY3_PROBES.md` — uso + 5 reglas de disciplina.
- `DOCUMENTACION/TAREAS-POR-MODELO/Hy3/red_probe_battery.py` — emisiones del bus global ACOTADAS por directorio de módulo.

## Módulos core en alcance (9)
M11 personaje · M13 herramientas · M16 inventario · M19 NPCs · M20 amistad ·
M38 economía · M54 mapa · M70 islas · M74 festivales/eventos.

## BATERÍA COMPLETA (medida 2026-10-28, red-probe estático + índice de señales)
Método: por cada dir de módulo, conteo de `.gd`, `EventBus.X.emit` (emisiones al
bus global), señales `signal` locales declaradas, y `emit_signal` locales.

| Módulo | dir | .gd | EventBus.emit | local-signals | emit_signal | veredicto |
|--------|-----|-----|---------------|---------------|-------------|-----------|
| M11 personaje | player | 15 | 0 | 3 | 0 | OK — señales locales, 0 emisión directa al bus |
| M13 herramientas | herramientas158 | 5 | 0 | 5 | 0 | OK |
| M16 inventario | inventario | 10 | 0 | 6 | 0 | PUENTE ROTO `item_removed` → BUG-150 |
| M19 NPCs | npc | 9 | 0 | 15 | 0 | OK |
| M19b IA-NPC | ia_npc | 26 | 0 | 17 | 0 | OK |
| M20 amistad | friendship | 9 | 0 | 7 | 0 | OK |
| M38 economía | economia | 19 | 0 | 7 | 1 | OK (1 `emit_signal` local, no bus) |
| M54 mapa | mapa | 9 | 0 | 4 | 0 | OK |
| M70 islas | islas | 15 | 0 | 3 | 0 | OK |
| M74 eventos | eventos | 15 | 0 | 8 | 0 | 15/15 eventos .tres (ver I1-017) |

Oráculo global (`hy3_red_probe.py --bus`): **54 señales declaradas / 20 muertas / 34 con emisión**, 1237 .gd escaneados — reproducible (igual que oráculo M14 27oct).

**Hallazgo A (arquitectura, confirmado en 10/10 módulos):** las emisiones tipadas
del bus global están **centralizadas en managers/core**, NO distribuidas en las
carpetas de módulo. Riesgo QA: un manager central caído silencia señales de varios
módulos (acoplamiento centralizado). Registrado para seguimiento; no es fallo
grave por sí solo, pero es el patrón que habilita el BUG-150.

**Hallazgo B (BUG GRAVE → `DOCUMENTACION/11-BUGS.md#BUG-150`):** `EventBus.item_removed`
declarada en `event_bus.gd:70` con **0 emisores al bus** (runtime 60f: 2 emitidas /
52 en 0; `item_removed` en el conjunto de 0). Emisores solo locales (service/component);
2 consumidores del bus muertos. Impacta M53/M59. Estado `[?]` Delegado al fundador.

## Reporte por módulo (runtime wire-up)
- **Runtime global ya sondado** (M14 `probe_runtime_bus_m14.gd`, boot 60f de main_island):
  113 señales conectadas, 2 emitidas, 52 declaradas en 0 → el bus arranca pero la
  mayoría de señales no se ejercitan en boot (esperable: muchas son eventos de juego).
- **Cada módulo** declara sus señales locales y NO las emite al bus directamente:
  el flujo pasa por managers. Esto es cableado a medias en el sentido de que el
  contrato "módulo → bus" no es visible archivo-a-archivo; se resuelve en core.
- **Sin señales huérfanas adicionales** detectadas en los 9 módulos más allá de las
  20 muertas globales (ya conocidas). No se tocó código ajeno.

Regla: español, UTF-8 sin BOM, citas archivo:L#, no toco código ajeno, sin
self-sello (veredicto gate-2 va a agnes/GLM).
