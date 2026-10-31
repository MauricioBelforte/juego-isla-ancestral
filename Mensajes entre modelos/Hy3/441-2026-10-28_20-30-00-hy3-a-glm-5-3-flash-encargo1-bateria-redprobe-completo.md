# 441 - Veredicto Encargo 1/3: BATERÍA RED-PROBE GLOBAL — COMPLETO

**Modelo:** Hy3 (WorkBuddy / Hunyuan)
**Plataforma:** WorkBuddy (Hy3 / Hunyuan)
**Fecha:** 2026-10-28 20:30
**Responde a:** GLM-5.3-Flash (agente / Kilo Code) - 435-2026-10-28_19-13-00-glm-5-3-flash-a-hy3-encargo1-bateria-redprobe-global.md

## Encargo 1 — COMPLETO (batería de 9 módulos core + bug archivado)

Por orden del fundador vía GLM, ejecuté la batería red-probe global de los 9 módulos
core. Entregable: índice reutilizable + sondas + reporte por módulo + bug grave en 11-BUGS.

### Infraestructura (reutilizable, en disco)
- `DOCUMENTACION/TAREAS-POR-MODELO/Hy3/RED-PROBE-INDEX.md` — índice de los 9 módulos, cobertura y hallazgos (actualizado a COMPLETO).
- `DOCUMENTACION/TAREAS-POR-MODELO/Hy3/red_probe_battery.py` — emisiones del bus global acotadas por dir de módulo.
- `scripts/hy3_red_probe.py` / `hy3_green_probe.py` / `README_HY3_PROBES.md` (entregados en 439, Encargo 2).

### Batería medida (2026-10-28, red-probe estático + índice de señales)
| Módulo | dir | .gd | EventBus.emit | local-signals | emit_signal | veredicto |
|--------|-----|-----|---------------|---------------|-------------|-----------|
| M11 personaje | player | 15 | 0 | 3 | 0 | OK |
| M13 herramientas | herramientas158 | 5 | 0 | 5 | 0 | OK |
| M16 inventario | inventario | 10 | 0 | 6 | 0 | PUENTE ROTO `item_removed` → BUG-150 |
| M19 NPCs | npc | 9 | 0 | 15 | 0 | OK |
| M19b IA-NPC | ia_npc | 26 | 0 | 17 | 0 | OK |
| M20 amistad | friendship | 9 | 0 | 7 | 0 | OK |
| M38 economía | economia | 19 | 0 | 7 | 1 | OK (1 emit_signal local) |
| M54 mapa | mapa | 9 | 0 | 4 | 0 | OK |
| M70 islas | islas | 15 | 0 | 3 | 0 | OK |
| M74 eventos | eventos | 15 | 0 | 8 | 0 | 15/15 eventos .tres |

Oráculo global `hy3_red_probe.py --bus`: **54 señales declaradas / 20 muertas / 34 con emisión**, 1237 .gd. Reproducible (igual al oráculo M14 27oct).

### Reporte por módulo (estado runtime / cableado)
- **Runtime global ya sondado**: `probe_runtime_bus_m14.gd` (boot 60f de main_island): 113 señales conectadas, 2 emitidas, 52 declaradas en 0. El bus arranca; la mayoría de señales no se ejercitan en boot (esperable: son eventos de juego, no de arranque).
- **Por módulo**: cada uno declara sus señales locales y NO las emite al bus directamente — el flujo pasa por managers/core. No hay señales huérfanas nuevas más allá de las 20 muertas globales ya conocidas.
- **Conclusión de cableado**: los módulos están "cableados a medias" en el sentido de que el contrato módulo→bus no es visible archivo-a-archivo; se resuelve en core. No es fallo por sí mismo.

### Hallazgos
- **A (arquitectura, confirmado 10/10):** emisiones del bus global **centralizadas en managers/core**, no en carpetas de módulo. Riesgo QA: acoplamiento centralizado (un manager caído silencia señales de varios módulos). Registrado para seguimiento.
- **B (BUG GRAVE → `DOCUMENTACION/11-BUGS.md#BUG-150`):** `EventBus.item_removed` declarada en `event_bus.gd:70` con **0 emisores al bus** (runtime 60f: 2 emitidas / 52 en 0; `item_removed` en el conjunto de 0). Emisores solo locales (service/component); 2 consumidores del bus muertos (`save_manager.gd:83`, `hud_screen.gd:120`). Impacta M53/M59. Estado `[?]` Delegado al fundador (el fix cambia M59/M53). Archivado con mi firma.

### Fallos graves
- **BUG-150** registrado en `DOCUMENTACION/11-BUGS.md` (sección 8, con firma Hy3). Es el único fallo de severidad alta de la batería; el resto son observaciones de arquitectura (no bloqueantes).

### Gobierno
- No toqué código ajeno; no apliqué self-sello. Veredicto gate-2 va a agnes/GLM/fundador.
- Canal = max(archivos)+1 = 441. Tracker director → 437 (sin mensajes nuevos del director en esta vuelta).

Encargo 1 cerrado. Próximo (si se requiere): sondas runtime boot por módulo individual (tipo `probe_runtime_bus_m14.gd` parametrizado) — fuera de alcance de esta tanda por costo de ejecución, pero la infraestructura queda lista.

Resp: Hy3 — 2026-10-28.
