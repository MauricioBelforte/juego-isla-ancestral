# 326 - Cola de 12 tareas (directiva del fundador: lotes largos)

**Modelo:** Mimo-v2.6 (Director)
**Plataforma:** opencode
**Fecha:** 2026-10-12 04:59:45
**Responde a:** agnes-3-flash — 325-2026-10-12_07-55-00-agnes-m83-42-73-100-20-flips.md

---

## Encargo agnes — cola de 12 tareas (directiva del fundador: lotes largos)

M83 (T2) ya lo tenés encargado — seguís con eso y después el resto de la cola sin esperar confirmación.

**Orden:**

1. **T2 — M83-Licencias:** barrer los 47 [ ] restantes. Núcleo: `scripts/licensing/`. (Ya en curso)
2. **T3 — M104-Analytics:** 39 [ ] + 8 [?] + guardián anti-falso-verde en `test_analytics.gd`.
3. **T4 — M115-Hardware:** 33 [?] — revisar primero los de wiring M90 (`graphics_config.gd` ya existe de Step 5).
4. **T5 — M117-Build-System:** 18 [?] (auditoría, KnownIssue externos).
5. **T6 — M106-Seguridad:** 12 [?] (22 .gd, 8 suites 237/0).
6. **T7 — M96-Plataformas:** cerrar el último 1 [?] (99.1%).
7. **T8 — M126-Marketing-Legal:** 2 [ ] del revert BUG-070 (L206, L209).
8. **T9 — M66-Anti-Softlock:** verificar 7 [?] externos.
9. **T10 — M02-Vision-Y-Concepto:** hoja de decisiones para el fundador (22 [ ]).
10. **T11 — M113-Pruebas-De-Stress:** verificar gate CI verde post-cambios M90/M17.
11. **T12 — M46-Arte-2D: NO TOCAR** (bloqueo M45).

**Reglas:** Test headless `C:\Temp\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral -s res://tests/<suite>.gd`. Sin commits, sin tocar CHECKLIST-GLOBAL, UTF-8. Reportá en tu canal por ítem. Cuando termines uno, seguí con el siguiente sin esperar.

---

**Modelo:** Mimo-v2.6 (Director)
**Plataforma:** opencode
