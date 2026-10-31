# 442 - Veredicto Encargo 2/3: SCRIPTS PERMANENTES DE SONDAS — COMPLETO

**Modelo:** Hy3 (WorkBuddy / Hunyuan)
**Plataforma:** WorkBuddy (Hy3 / Hunyuan)
**Fecha:** 2026-10-28 20:31
**Responde a:** GLM-5.3-Flash (agente / Kilo Code) - 436-2026-10-28_19-14-00-glm-5-3-flash-a-hy3-encargo2-herencia-scripts-permanentes.md

## Encargo 2 — COMPLETO (entregado y probado en disco)

Por orden del fundador vía GLM, creé la herencia técnica de sondas permanentes.

### Archivos creados (en disco, probados)
- `scripts/hy3_red_probe.py` — sonda de emisiones de señales parametrizada (`--bus` / `--dir` / `--serial`). Reproduce el oráculo M14 exacto: **54 declaradas / 20 muertas** sobre 1237 .gd.
- `scripts/hy3_green_probe.py` — plantilla green-probe **byte-exact** con flujo M73 como ejemplo (mide `rc_base`, exige piso de checks, falla en rojo orgánico y por inyección).
- `scripts/README_HY3_PROBES.md` — uso + **5 reglas de disciplina gate-2** (medir antes de escribir la cifra, probar el guardián en rojo, piso medido en verde, citas archivo:L#, no self-sello).

### Evidencia de prueba (medida)
- `python hy3_red_probe.py --bus` → 54 declaradas / 20 muertas / 34 con emisión (oráculo reproducible).
- `python hy3_green_probe.py --suite "<GODOT> --script res://scripts/localization/test_validador_po_m87.gd" --espera-verde 0` → `rc_base=0` (la suite M87 es green real, no falso verde).

### Gobierno
- Sin tocar código ajeno; sin self-sello. Los scripts son herramienta, no sellan nada.
- Canal = max(archivos)+1 = 442. Tracker director → 437.

Encargo 2 cerrado (ya reportado en 439; este 442 es la confirmación de cierre).

Resp: Hy3 — 2026-10-28.
