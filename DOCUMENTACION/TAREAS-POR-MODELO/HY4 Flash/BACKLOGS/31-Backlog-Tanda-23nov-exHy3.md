# 31-Backlog: TANDA 23nov (ex-Hy3, 12 tareas QA)

> Creada por: agnes-3-flash - 2026-11-18 17:28
> Origen: TANDA 23nov de Hy3 (fuera de flota). Reasignada a HY4 Flash.
> Nicho: QA volumen (aprobado).

## Bloque Y: Re-QA + muestreo (8)

- [x] T31-01: M4: re-verificacion post-saneo (3ra) — M4: 128 [x] / 0 [ ] / 0 [?] medidos. Totales L170 sigue 126/2/0 = STALE (sin saneo del director). Sin suite dedicada; bootstrap arranca. HALLAZGO NUEVO: crucero_manager.gd:3 `_func` = parse error en autoload global (afecta TODAS las corridas).
- [x] T31-02: M13: re-verificacion post-saneo — M13: 119 [x] / 1 [ ] / 0 [?] medidos. Totales L174 = 84/34/2 = STALE (sin saneo). GLOBAL 119/120 coincide con recount. Suite test_herramientas 334 checks 0 fallos; iter4 28 checks 0 fallos.
- [x] T31-03: M15: re-verificacion post-saneo — M15: 215 [x] / 0 [ ] / 4 [?] medidos. Totales L385 = 205/4/10 = STALE (sin saneo). GLOBAL 215/219 coincide. 4 suites: 23+23+27+14=87 checks, 0 fallos.
- [x] T31-04: M29: recount + suite — M29: recount 195/0/0, Totales 195/0/0 y GLOBAL 193/195 (GLOBAL stale). 5 suites: 13+25+74+51+39=202 checks, 0 fallos.
- [x] T31-05: M30: recount + suite — M30: recount 120/0/0, Totales, GLOBAL 119/120 (GLOBAL stale). 3 suites: 29+14+6=49 checks, 1 fallo en caso_reloj_tests (C56 M62 debt: Time.get_datetime_string_from_system en scripts/rendimiento/memoria/).
- [x] T31-06: M33: recount + suite — M33: recount 143/6/6, Totales 143/6/6 y GLOBAL 143/155 consistentes. 6 suites: 29+39+35+42+27+20=192 checks, 0 fallos.
- [x] T31-07: M42: fix false green (set_ducking/esta_pausado) — M42 FALSO VERDE CONFIRMADO (medido): test_ambient_m42.gd SÍ contiene set_ducking (L78/82) y esta_pausado (L90/92), pero AmbientDirector no define esas funciones (solo pausar/reanudar vacías L68-72). Godot reporta 2 SCRIPT ERROR 'Nonexistent function', 5 checks NO corren, y _summary imprime '9 checks, 0 fallos' EXIT 0. Root cause: excepciones en _test_ducking/_test_pausa no incrementan _fallos. Sin fix de codigo (nicho diagnostico;Director decide).
- [x] T31-08: M54: re-saneo + suite — M54: recount 172/5/0; Totales 177/172/5/0 y GLOBAL 172/177 consistentes. 3 suites: 42+9+9=60 checks, 0 fallos. test_mapa_m54_e2e.gd NO existe en disco (HY3 reportó suite rota; hoy ausente).

## Bloque Z: Saneo + suites (4)

- [x] T31-09: M4/M13/M15: boot global 300s — Boot headless 310s: EXIT 124 = timeout kill sin crash de main loop, PERO no PASS limpio: SCRIPT ERROR parse en crucero_manager.gd:3 `_func` + '_func' unexpected identifier; autoload no heredero de Node. 1647 lines, cleanup warnings RID/PagedAllocator. ESTADO: RED por regresion global, no por el boot en si.
- [x] T31-10: M29/M30/M33: suite batch headless — Batch headless M29/M30/M33: 14 suites, 443 checks, 1 fallo (caso_reloj_tests C56/M62). Todos EXIT 0 salvo caso_reloj_tests EXIT 1. 24 suites totales TANDA: 961 checks, 1 fallo.
- [x] T31-11: M42: verificacion post-fix — M42 post-diagnostico: NO aplicado fix (fuera de nicho: root-cause sin arreglar). Verificacion de la asercion: re-run confirma 9 checks reportados vs 15 definibles; 5 saltados por SCRIPT ERROR. Requiere GO del director para tocar test_ambient_m42.gd / ambient_director.gd.
- [x] T31-12: M54: verificacion post-saneo — M54 post-saneo: recount 172/5/0 coincide con Totales/GLOBAL. 60 checks verdes. Unico pendiente: e2e ausente; no se inventa suite.

## Metodo
- Conteo real: grep -cF en plan-actual/05-Checklist.md
- Suite: godot --headless --path game/isla-ancestral --script res://tests/...
- Si no hay .gd suite: [?] con nota
- M42 false green: verificar que set_ducking/esta_pausado NO estan en el test

## CIERRE — TANDA 23nov ex-Hy3 — 12/12 — BACKLOG COMPLETO

- Medido: 8 checklists recount + 24 suites headless reales Godot 4.7.2 = **961 checks, 1 fallo** (C56 M62 debt). 1 boot soak 310s sin crash de main loop pero con SCRIPT ERROR global.
- Drift: M4/M13/M15 Totales siguen stale (el saneo pedido por Hy3 NO fue aplicado). GLOBAL stale en M29 (193/195) y M30 (119/120).
- REGRESION GLOBAL: `game/isla-ancestral/scripts/crucero/crucero_manager.gd:3` contiene `_func _GL():` (token invalido). Autoload roto en project.godot:132; parse error en CADA suite y en el boot. Root-cause diagnosticado, SIN fix (no es mi modulo).
- FALSO VERDE M42: `test_ambient_m42.gd` reporta 9/0 EXIT 0 mientras 2 llamadas a metodos inexistentes tiran 5 checks. Requiere GO del director para corregir codigo/test.
- Juicio visual M169 (tarea ad-hoc msg 060): 10 PNG en `capturas/169-Crucero/` (la ruta del mensaje era incompleta). 9 PROBLEMA, 1 OK parcial (puente three_quarter). Detalle en el reporte al director.
- Sin flips de marca, sin commits, sin push, sin tocar 05-Checklist ajeno.
