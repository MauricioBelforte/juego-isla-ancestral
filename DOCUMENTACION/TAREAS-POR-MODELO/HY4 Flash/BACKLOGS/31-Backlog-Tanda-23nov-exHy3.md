# 31-Backlog: TANDA 23nov (ex-Hy3, 12 tareas QA)

> Creada por: agnes-3-flash - 2026-11-18 17:28
> Origen: TANDA 23nov de Hy3 (fuera de flota). Reasignada a HY4 Flash.
> Nicho: QA volumen (aprobado).

## Bloque Y: Re-QA + muestreo (8)

- [ ] T31-01: M4: re-verificacion post-saneo (3ra)
- [ ] T31-02: M13: re-verificacion post-saneo
- [ ] T31-03: M15: re-verificacion post-saneo
- [ ] T31-04: M29: recount + suite
- [ ] T31-05: M30: recount + suite
- [ ] T31-06: M33: recount + suite
- [ ] T31-07: M42: fix false green (set_ducking/esta_pausado)
- [ ] T31-08: M54: re-saneo + suite

## Bloque Z: Saneo + suites (4)

- [ ] T31-09: M4/M13/M15: boot global 300s
- [ ] T31-10: M29/M30/M33: suite batch headless
- [ ] T31-11: M42: verificacion post-fix
- [ ] T31-12: M54: verificacion post-saneo

## Metodo
- Conteo real: grep -cF en plan-actual/05-Checklist.md
- Suite: godot --headless --path game/isla-ancestral --script res://tests/...
- Si no hay .gd suite: [?] con nota
- M42 false green: verificar que set_ducking/esta_pausado NO estan en el test
