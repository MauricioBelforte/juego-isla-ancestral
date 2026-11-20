# 38-Backlog: CI verde post-fix M169

> Creada por: agnes-3-flash - 2026-11-20 07:47
> Verificar que el fix 91bd99d dejo CI verde (o reportar lo que queda rojo).

## Tareas

- [x] T38-01: check-only 3 scripts M169. crucero_interior EXIT 0; crucero_manager L122 y crucero_eventos L79 dan 'Identifier not found' (TransportManager/TimeCalendar = autoloads declarados en project.godot L131/L31). Artefacto de --check-only --script, NO regresion. Fix 91bd99d CONFIRMADO: 0 '_GL(' en los 3 scripts (Log 2428).
- [x] T38-02: Boot main_island 300s EXIT 124 (timeout esperado, loop no auto-quit), 0 SCRIPT ERROR totales, 0 de crucero, Bootstrap completo (Log 2428).
- [x] T38-03: test_crucero_manager.gd EXIT 0 / 13 OK / 0 FAIL (Log 2428).
- [x] T38-04: test_crucero_eventos.gd EXIT 0 / 6 OK / 0 FAIL (Log 2428).
- [x] T38-05: test_m16_crafting_toast.gd EXIT 0 / 9 checks / 0 fallos (Log 2428).
- [x] T38-06: test_mineria.gd EXIT 0 / 92 checks / 0 fallos (Log 2428).
- [x] T38-07: test_progresion.gd EXIT 0 / 83 checks / 0 fallos (Log 2428).
- [x] T38-08: test_m89_menus.gd EXIT 0 / 58 checks / 0 fallos (Log 2428).
- [x] T38-09: test_logros.gd EXIT 0 / 72 checks / 0 fallos (Log 2428).
- [x] T38-10: test_bug128_hud_real.gd EXIT 0 / 18 checks / 0 fallos; warning InputMap 'posar' no bloqueante (Log 2428).
- [x] T38-11: CONFIRMADO ROJO pre-existente. validate_photo.gd EXIT 1 / 8 SCRIPT ERROR Parse Error (svc inferido, get_node_or_null en self). Sin fix (Log 2428).
- [x] T38-12: CONFIRMADO ROJO pre-existente. merch_validator.gd EXIT 1 / Class 'MerchValidator' hides a global script class L12; duplicado en legal/ y legal/Obsoletos/ (ambos versionados). Sin fix (Log 2428).
- [x] T38-13: CONFIRMADO ROJO + FALSO VERDE. check-only colector EXIT 0 con 2 SCRIPT ERROR (MerchValidator + Failed to compile). quality.yml L77/L148 con '|| true' enmascara el parse error (Log 2428).
- [x] T38-14: 10/14 VERDE (fix 91bd99d confirmado + boot + 8 suites), 3/14 ROJO pre-existente (T38-11/12/13), 1/14 resumen. Veredicto: camino M169 verde; CI no 100% verde por 3 items pre-existentes, 1 enmascarado por '|| true' (Log 2428).
