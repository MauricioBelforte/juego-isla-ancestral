# 57 - Drifts Fix + Volumen (nueva tanda)

**Creado por:** agnes-3-flash (directora) - 2026-11-21 08:05
**Nicho:** Volumen/Limpieza + Cross-doc
**Tareas:** 15

## A - Fix 55 drifts de b56 (CHECKLIST-GLOBAL vs plan-actual)

b56 encontro 55 modulos con drift. Los top 4: M122 (-2), M91 (-2), M40 (-4), M106 (-12).
Tarea: fijar los 55 drifts en CHECKLIST-GLOBAL para que el Progreso coincida con el conteo real de [x] en plan-actual/05-Checklist.md.

- [ ] T57-01: Fix M122 Crash-Reporting: Progreso 254 → 256
- [ ] T57-02: Fix M91: Progreso 237 → 239
- [ ] T57-03: Fix M40: Progreso 206 → 210
- [ ] T57-04: Fix M106: Progreso 194 → 206
- [ ] T57-05: Fix los 51 drifts restantes (listar en Log + aplicar)

## B - Volumen: Data files (995)

- [ ] T57-06: Contar 995 data files (.json/.tres/.cfg) y verificar que none tienen errores de sintaxis (JSON parse, .tres parse)
- [ ] T57-07: Verificar que las rutas res:// en data files apunten a archivos que existen

## C - Volumen: Scene integrity

- [ ] T57-08: Verificar que todos los .tscn en game/ tengan ext_resource que apunten a archivos que existen
- [ ] T57-09: Verificar que todos los .tscn tengan un nodo raiz valid

## D - Volumen: Audio

- [ ] T57-10: Mover o documentar los 97 .wav en TAREAS-POR-MODELO/step-5-kilocode/audio/ (estan fuera del juego, pero son assets de M41)
- [ ] T57-11: Verificar si hay .ogg/.mp3/.flac en otras rutas del repo

## E - Volumen: Scripts

- [ ] T57-12: Contar 48 TODO/FIXME/HACK en 40 .gd files y verificar si alguno es fixable sin decision de fundador
- [ ] T57-13: Verificar que los autoloads en project.godot apunten a scripts que existen

## F - Cross-doc

- [ ] T57-14: Verificar que los 55 drifts de b56 esten fixeados (post-T57-01..05)
- [ ] T57-15: Generar reporte de estado: conteos reales vs CHECKLIST-GLOBAL para los 20 modulos con mas [x]

## Totales

| Seccion | Tareas |
|---------|--------|
| A (Drifts) | 5 |
| B (Data) | 2 |
| C (Scene) | 2 |
| D (Audio) | 2 |
| E (Scripts) | 2 |
| F (Cross-doc) | 2 |
| **Total** | **15** |
