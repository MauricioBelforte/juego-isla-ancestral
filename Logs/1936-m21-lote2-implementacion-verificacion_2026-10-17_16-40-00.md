# Log 1936: M21 Lote 2 - Implementacion y verificacion (Hy3 / WorkBuddy)

**Modelo:** Hy3
**Plataforma:** WorkBuddy (Hunyuan)
**Fecha:** 2026-10-17 16:40:00
**Modulo:** M21 (Dialogos) - Lote 2 (msg 249, autorizado)

## Alcance

20 items delegados (D Tipografia 12, K Polish 6, E Opciones bloqueadas 2).
19 implementables + 1 N/A (D L79: UI 100% programatica, no hay .tscn).
L80 y L87 ya [x] en Lote 1.

## Cambios

- `scripts/dialogos/dialogue_node.gd`: campo aditivo `hide_blocked` (default false,
  retrocompatible) para E L101.
- `scripts/dialogos/ui/dialogue_ui.gd`: rewrite conservando firmas publicas del Lote 1
  (regression verde) + features Lote 2. Tween/Audio/Portrait guardados con
  `is_inside_tree()`; reduce_motion honrado.
- `data/dialogues/ejemplo_localizado_m21.json`: reescrito al esquema canonico
  (`id`/`start`, `tipo` entero 0/1/3, nodos alcanzables). Antes fallaba
  `DialogGraphValidator` (claves `dialogue_id`/`start_node_id`, `tipo` string, `muestra`
  colgando).

## Tests (guardian anti-falso-verde de 3 capas: _fin + _WB_BLOQUES + CHECKS_MINIMOS
medido + _summary diferido, verificado en ROJO por inyeccion de runtime)

- test_typewriter_m21.gd: 19 checks, 0 fallos (L81-L86)
- test_indicadores_m21.gd: 7 checks, 0 fallos (L88/L89)
- test_pagejump_m21.gd: 15 checks, 0 fallos (L90/L91/L92)
- test_opciones_bloqueadas_m21.gd: 8 checks, 0 fallos (L101/L102)
- test_polish_m21.gd: 11 checks, 0 fallos (K L185-L190)

Regresion M21 completa: 12/12 suites verdes, 0 fallos
(las 5 nuevas + 7 existentes: clima, skip, 5 invalidos, CI, grafo, eventos, iter10).

## Commit

Autorizado por msg 249 (pathspec explicito). Solo archivos M21 Lote 2:
dialogue_node.gd, dialogue_ui.gd, 5 suites nuevas, ejemplo_localizado_m21.json.
NO auto-sello: los 20 flips en 05-Checklist.md los aplica el director.
NO edito CHECKLIST-GLOBAL.md ni quality.yml.

## Evidencia headless (Godot 4.7.2)

EXIT 0 en las 12 suites. Resumenes:
Typewriter 19/0, Indicadores 7/0, PageJump 15/0, OpcionesBloqueadas 8/0, Polish 11/0,
validacion_ci 8/0.
