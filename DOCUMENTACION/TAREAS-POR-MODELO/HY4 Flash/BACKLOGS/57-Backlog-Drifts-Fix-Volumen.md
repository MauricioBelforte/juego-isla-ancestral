# 57 - Drifts Fix + Volumen (nueva tanda)

**Creado por:** agnes-3-flash (directora) - 2026-11-21 08:05
**Nicho:** Volumen/Limpieza + Cross-doc
**Tareas:** 15

## A - Fix 55 drifts de b56 (CHECKLIST-GLOBAL vs plan-actual)

b56 encontro 55 modulos con drift. Los top 4: M122 (-2), M91 (-2), M40 (-4), M106 (-12).
Tarea: fijar los 55 drifts en CHECKLIST-GLOBAL para que el Progreso coincida con el conteo real de [x] en plan-actual/05-Checklist.md.

- [x] T57-01: Fix M122 Crash-Reporting: Progreso 254 → 256
- [x] T57-02: Fix M91: Progreso 237 → 239
- [x] T57-03: Fix M40: Progreso 206 → 210
- [x] T57-04: Fix M106: Progreso 194 → 206
- [x] T57-05: Fix los 51 drifts restantes (listar en Log + aplicar)

## B - Volumen: Data files (995)

- [x] T57-06: Contar 995 data files (.json/.tres/.cfg) y verificar que none tienen errores de sintaxis (JSON parse, .tres parse)
- [x] T57-07: Verificar que las rutas res:// en data files apunten a archivos que existen

## C - Volumen: Scene integrity

- [x] T57-08: Verificar que todos los .tscn en game/ tengan ext_resource que apunten a archivos que existen
- [x] T57-09: Verificar que todos los .tscn tengan un nodo raiz valid

## D - Volumen: Audio

- [x] T57-10: Mover o documentar los 97 .wav en TAREAS-POR-MODELO/step-5-kilocode/audio/ (estan fuera del juego, pero son assets de M41)
- [x] T57-11: Verificar si hay .ogg/.mp3/.flac en otras rutas del repo

## E - Volumen: Scripts

- [x] T57-12: Contar 48 TODO/FIXME/HACK en 40 .gd files y verificar si alguno es fixable sin decision de fundador
- [x] T57-13: Verificar que los autoloads en project.godot apunten a scripts que existen

## F - Cross-doc

- [x] T57-14: Verificar que los 55 drifts de b56 esten fixeados (post-T57-01..05)
- [x] T57-15: Generar reporte de estado: conteos reales vs CHECKLIST-GLOBAL para los 20 modulos con mas [x]

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

## Resultados medidos — 2026-11-21 (Log 2436)

- A: 56 drifts PRE (no 55), 0 POST. 56 filas de CHECKLIST-GLOBAL editadas
  SOLO en celda Progreso; 3 denominadores corregidos (M169/M50/M53).
  Auditoria diff: 0 cambios fuera de celda 4.
- B: 995 data files (552 .json + 443 .tres), 0 errores de sintaxis;
  18 refs rotas en data/logros/logros.json a assets/ui/logros/*.png.
- C: 73 .tscn, 0 ext_resource/ID rotos, 0 sin nodo raiz.
- D: 97 .wav documentados en TAREAS-POR-MODELOS, 0 .ogg/.mp3/.flac;
  ningun archivo movido.
- E: 8 marcadores canonicos en 5 .gd (35 laxos en 31); ninguno fixeable
  sin decision. 117/117 autoloads apuntan a scripts existentes.
- F: 0 drifts post-fix; top-20 sincronizado.
- Errata 118 propuesta en mensaje 126, esperando GO.
