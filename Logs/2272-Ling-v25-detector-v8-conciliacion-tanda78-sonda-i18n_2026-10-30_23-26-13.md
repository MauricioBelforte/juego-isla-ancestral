# Log 2272: Vuelta 25 Ling — detector v8 (37/37 FORMULA-C en A2), conciliación TANDA 7/8 DeepSeek, sonda i18n flota 0 deuda

**Fecha:** 2026-10-30
**Hora:** 23:26
**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code

## Resumen

Vuelta 25 del cron Ling (override 205, nicho auditoría/doc/i18n). Write real triple: (1) detector repo-wide de autocontradicción marca↔nota parcheado a v8 (2 fixes) con aislamiento del efecto y verificación 37/37 FORMULA-C en bucket A2; (2) conciliación con la TANDA 7/8 de DeepSeek-V4.1-Flash — caso M157 L148 (solapamiento único entre ambos detectores) resuelto por precisión de nota sin flip; (3) sonda i18n de la movida de flota post-v24: 0 deuda jugador-visible. Report-only: 0 flips, 0 commits, 0 push.

## Cambios Realizados

- **Detector v8** (`scripts/detectar_autocontradiccion.py`): `sin implementar` agregado a CONTRARIOS_A2 (L108); guardia en pasada 2 — la promoción vecinal ±4 no aplica si la propia línea del hit tiene evidencia contraria; header actualizado a v8. Aislamiento (v7 snapshot desde HEAD `59ecee4` vs v8, mismo working tree): promovidos 14→2, A2 219→243, C2 565→553; invariantes A1=32 / R4=239 / A3=8 / SOS=313 / FP=4 / FORMULA=80 / GRIS=209 / items [x]=23010 / checklists=168.
- **Verificación FORMULA-C 37/37 en A2** (`Temp/kilo/verif37_v8.py`): M31=23 (20 FC + L59/60/218), M34=10, M27=10, M156=13. Hallazgo nuevo: M156 L173 FORMULA-C "por espejo" (contraria ANTES del "Flipado", fuera del rg de las 37; v8 la mantiene en A2 correctamente).
- **Caso M157 L148 (J-04)**: nota reformulada con alcance documental explícito "(cerrado)" + cifra medida 0/20 scripts en disco + corroboración Nemotron B-0 P1 (reporte 164); [x] documental sostenido SIN flip; M157 queda A2=0 (verificado con `--modulo 157`). Stale corregido: J-05 L149 (Totales 4/128→8/124), L214 drift (4/132→8/132), Notas del Agente vuelta 25 añadidas.
- **Documentación:** informe padre §15 (detector v8 + caso M157) / §16 (conciliación TANDA 7/8) / §17 (sonda i18n); anexo FORMULA-C §5 (candidatos v8 → APLICADOS + 37/37) y §7 (trazabilidad v8 + corrección honesta de referencia stale `v24_detector.txt` no persistido); backlog ESTADO v25.
- **Sonda i18n flota** (`Temp/kilo/sonda_v25_flota.py`): 11 archivos del working tree (movida post-v24: TANDA 8 DS + rebaselines M85/M67) — 88 acentos 100% dev-side (15 print/push_error + 73 strings _check/_warn + slugificación diary_service L127/128), 150 candidatos 100% FP (rutas res://, claves internas, asserts, budgets.json=spec para gates) → 0 deuda i18n jugador-visible nueva. Riel PT intacto (pt.po sha1 95EE2CE0D1, git status riel vacío, K4 "Portugués" vivo).

## Archivos Modificados/Creados

- **Modificados:** `scripts/detectar_autocontradiccion.py` · `DOCUMENTACION/157-Medios-De-Transporte/plan-actual/05-Checklist.md` (J-04 L148, J-05 L149, L214, Notas del Agente) · `DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/AUDITORIA-AUTOCONTRADICCION-REPO-WIDE.md` (§15-17) · `DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/ANEXO-A-FORMULA-C-37-FLIPS-CONTRARIOS.md` (§5/§7) · `DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOG-MASTER.md` (ESTADO v25) · `Logs/NUMEROS_DISPONIBLES.txt` (pop ritual 2272)
- **Creados:** este Log 2272 · msg 334 del canal Ling-3.1-Flash · `Temp/kilo/` (sonda_v25_flota.py, verif37_v8.py, detector_v7_snap.py, v25_detector_v8.txt, v25_detector_v8_final.txt, v25_v7_snap.txt)

**Estado:** 0 flips aplicados (report-only) · 0 commits · 0 push · HEAD `59ecee4` · riel PT intacto.
