# Log 1228 — Sección O: Auditoría de CITAS DE LOGS rotas + 11-BUGS

- **Fecha:** 2026-10-03
- **Autor:** hy3 / WorkBuddy (verificador)
- **Alcance:** (a) citas de log rotas en CHECKLIST-GLOBAL; (b) bonus 11-BUGS.md doble `## 8.`; (c) verificar scripts.

## 1. Citas de log rotas (existencia + pertenencia)

- **Existencia:** escaneo de 365 citas (`Log NNNN`) en CHECKLIST-GLOBAL contra `Logs/<num>-*.md`. **Solo 1 cita sin archivo:** `Log 1036` (citada en fila 11 / M11-Personaje, atribuida a nex-n2.5-pro). No existe `Logs/1036-*.md`.
  - **Corrección aplicada:** anotada en CHECKLIST-GLOBAL fila 11 como `Log 1036 (⚠ archivo no encontrado en Logs/ — cita rota, sin sello §21.8 válido)`. NO se inventó ningún sello ni número sustituto.
- **Pertenencia / sello mal atribuido:** chequeo de TODAS las citas `Log NNNN` en el campo STATUS (donde se reclamaría un sello propio) contra el módulo del archivo de log. **0 coincidencias falsas** — ninguna fila reclama el log de otro módulo como su propio sello en el estado.
  - Las ~60 citas cruzadas (módulo de la cita ≠ módulo de la fila) son **referencias legítimas compartidas**, p. ej. `Log 856` = isla-raíz M54 citado por 15+ módulos (M19/M28/M37/M48/M56/M58/M62/M63/M65/M67/M73/M74/M75), `Log 1146` = M167 (M114/M119/M94), `Log 1148` = M07 (M133/134/135/136). No se modifican.
- Extiende la corrección previa M123 (Log 532 → 879, ya aplicada en commits anteriores).

## 2. Bonus 11-BUGS.md — doble `## 8.`

- `DOCUMENTACION/11-BUGS.md` tenía DOS encabezados `## 8.`:
  - Línea 2124: `## 8. Bugs Delegados a Otros Agentes` (oficial).
  - Línea 4472: `## 8. Bugs Delegados — auditoría reductos (256,...) centro viejo (hy3, Log 1179, 2026-09-30)` (duplicado).
- Como `## 9.` ya está ocupado por "Historial de Modificaciones", renombrar a `9.` colisionaría. **Resolución:** renombrado el duplicado a **`## 8.1`** (subsección de la sección 8 oficial), preservando TODO el histórico (nunca borrado).

## 3. Verificación de scripts

- `python scripts/test_scripts.py` → **10 PASS / 0 FAIL** ✅ (gate del coordinador cumplido).
- `python scripts/verificar_checklist.py` → corre pero **exit 1 con 3 ALERTAS** (no son citas rotas, son drifts de conteo GLOBAL vs módulo):
  - `100-Community-Management`: GLOBAL 146/222 vs módulo 222/222 (módulo dice 100%; GLOBAL subcuenta).
  - `54-Mapa`: GLOBAL 127/177 vs módulo 133/177 (ya notado en Log 1226).
  - `70-Interacciones`: GLOBAL 77/198 vs módulo 155/198 (ya notado en Log 1224, diferido a Sección N).
  - Estos 3 son drifts de GLOBAL por subcálculo (no introducidos por este log). Se reportan para que el coordinador reconcilie los conteos de GLOBAL (o confirme la autoridad del módulo). No se alteraron los conteos en este paso para no inventar cifras.

## Archivos

- `Logs/1228-seccion-o-citas-rotas_2026-10-03.md` (este log)
- `CHECKLIST-GLOBAL.md`: anotación ⚠ en fila 11 (Log 1036 roto).
- `DOCUMENTACION/11-BUGS.md`: `## 8.` duplicado → `## 8.1`.
- `DOCUMENTACION/TAREAS-POR-MODELO/Hy3/BACKLOG-MASTER.md`: Sección O marcada `[x]`.
