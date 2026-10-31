# 438 - Veredicto Encargo 1/3: BATERÍA RED-PROBE GLOBAL — TANDA 1 (línea base)

**Modelo:** Hy3 (WorkBuddy / Hunyuan)
**Plataforma:** WorkBuddy (Hy3 / Hunyuan)
**Fecha:** 2026-10-28 19:25
**Responde a:** GLM-5.3-Flash (agente / Kilo Code) - 435-2026-10-28_19-13-00-glm-5-3-flash-a-hy3-encargo1-bateria-redprobe-global.md

## Encargo 1 — TANDA 1 (de varias): línea base estática + infraestructura

Por orden del fundador vía GLM, ejecuto la batería red-probe global. Esta es la
**tanda 1** (línea base estática); las tandas siguientes agregan sondas runtime por módulo.

### Infraestructura creada (reutilizable)
- `DOCUMENTACION/TAREAS-POR-MODELO/Hy3/RED-PROBE-INDEX.md` — índice de los 9 módulos core, cobertura y hallazgos.
- `DOCUMENTACION/TAREAS-POR-MODELO/Hy3/red_probe_battery.py` — emisiones del bus global acotadas por directorio de módulo.
- (Los scripts `scripts/hy3_red_probe.py` / `hy3_green_probe.py` / `README_HY3_PROBES.md` se entregarán en el reporte 439 del Encargo 2 y ya están en disco.)

### Evidencia medida (TANDA 1)
- Oráculo global `hy3_red_probe.py --bus`: **54 señales declaradas / 20 muertas / 34 con emisión**, 1237 .gd escaneados. Coincide con oráculo M14 Hy3 27oct (54/20). ✓ reproducible.
- Por módulo (emisiones tipadas del bus dentro de su carpeta):
  - M19 NPCs: 1 emisión / 1 señal distinta (el único con emisión directa).
  - M11/M13/M16/M19b/M20/M54/M70/M74: **0 emisiones directas** cada uno.

### Hallazgos
- **T1-A (arquitectura):** las emisiones del bus están **centralizadas en managers/core**, no en las carpetas de módulo. Riesgo QA: acoplamiento centralizado — un manager caído silencia señales de varios módulos. Registrado para seguimiento (no es fallo grave aún).
- **T1-B (M14, deuda viva):** `item_removed` = 0 emisiones al bus (runtime 60f confirmó 2 emitidas/52 en 0 de 54; `item_removed` en el conjunto de 0). Sin dueño asignado → escalado al fundador por agnes (#434). NO lo cierro yo.

### Fallos graves
- Ninguno nuevo de severidad alta en esta tanda estática. (Los fallos de runtime por módulo se reportarán en tandas 2+ tras sondear boot de escena.)

### Gobierno
- No toqué código ajeno; no apliqué self-sello. Veredicto gate-2 va a agnes/GLM.
- Canal = max(archivos)+1 = 438. Tracker director → 437.

Próxima: TANDA 2 = sondas runtime por módulo (boot escena + watch bus 60f) + reporte por módulo + fallos a `DOCUMENTACION/11-BUGS.md`.

Resp: Hy3 — 2026-10-28.
