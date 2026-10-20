# Log 2022 - M50-Vegetacion - REPOBLACION V3 items 21-30 (tanda con runs Godot)

- **Agente:** Step-5-WorkBuddy
- **Fecha:** 2026-10-19 (run del juego 05:07-05:39; cierre de tanda 20:45)
- **Modulo:** 50-Vegetacion (M50)
- **Msg:** 096-2026-10-19_20-45-13-Step-5-WorkBuddy-a-glm-5.3-flash-director-tanda-m50-items-21-30-vegetacion
- **Origen:** REPOBLACION V3 items 21-30 (metodo V2, director GLM-5.3 Flash-Director) + directiva de runs (director msg 094, directiva del fundador 07:48)

## Evidencia medida en esta tanda

### Suites headless (binario real: Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral --script res://scripts/vegetacion/...)
- test_vegetation_headless.gd: 7 checks, 0 fallos, EXIT 0, 0 SCRIPT ERROR
- test_vegetation_plan_headless.gd: 5 checks, 0 fallos, EXIT 0, 0 SCRIPT ERROR
- test_vegetation_spawner_headless.gd: 4 checks, 0 fallos, EXIT 0, 0 SCRIPT ERROR
- test_distribucion.gd: 7 checks, 0 fallos, EXIT 0, 0 SCRIPT ERROR

### Run real del juego (ventana; aplica directiva de runs msg 094)
- [M50] VegetationSpawner: poblando isla...
- [M50] Plan generado: 109 items
- [M50] VegetationSpawner: 65 instanciadas, 44 omitidas (0 sin archivo, 44 en agua)
- FPS 60 estables durante la captura (cap_50_2026-10-19_05-12-10_fps-60-pivote.png)
- Cierre controlado: analytics sesion_fin 05:39:32, sin crash, 0 SCRIPT ERROR de runtime

### Escalas (item 29)
- Editados 3 multiplicadores en game/isla-ancestral/data/escalas/escalas.json: palmera 4.0->1.0, arbol_frutal 3.0->1.0, hierba_alta 0.8->1.0
- Verificado simulando la logica del autoload EscalasGlobales (match por substring): los 10 tipos horneados quedan en 1.0 y renderizan a su altura objetivo exacta (antes: arbol_frutal 18 m vs 6 m horneado, palmera 28 m vs 7 m, hierba_alta 0.48 m vs 0.6 m)
- Causa raiz: tools/mcp/blender-mcp/scripts-reutilizables/reescalar_v5.py hornea los GLB a su altura objetivo (su docstring dice dejar escalas.json a 1.0 definitivo); el multiplicador del JSON aplicaba doble escala en runtime

## Veredicto de la tanda (10 items de la cola V3)
- 2 flips con cita real: L175 (escena pivote, FPS 60 verificado en run) y L256 (escalas a 1.0, verificado por el autoload)
- 8 items quedan [ ] honesto con nota medida: L118, L174, L176, L178, L179, L180, L181, L257
- Conteo por prefijo de linea del checklist: 131 [x] / 8 [ ] = 139 (antes de la tanda: 129 [x] / 10 [ ])

## Features inexistentes en disco (medido hoy)
- viento_shader.gdshader: 0 archivos (sostiene L176)
- estaciones: grep estacion|season en scripts/vegetacion = 0 (sostiene L178)
- regeneracion/replantado: grep regener|replant|repoblar en scripts/vegetacion = 0 (sostiene L181)
- MultiMesh: no usado; instanciacion directa de GLB (documentado en L140; sostiene L180 y parte de L118)
- validate_vegetation.gd, especies.tres, densidades_bioma.tres: 0 archivos

## Entregables
- Capturas: tools/mcp/godot-mcp/capturas/50-Vegetacion/cap_50_2026-10-19_05-07-30_poblado-runtime-verificacion.png
- Capturas: tools/mcp/godot-mcp/capturas/50-Vegetacion/cap_50_2026-10-19_05-12-10_fps-60-pivote.png
- DOCUMENTACION/50-Vegetacion/plan-actual/05-Checklist.md: 2 flips + 8 notas medidas (25.463 B, LF puro, sin BOM, verificado por bytes)
- game/isla-ancestral/data/escalas/escalas.json: 3 valores a 1.0

## Nota de gobernanza
- 0 commits / 0 push (politica del director); los cambios quedan en el worktree para su revision.
- Log numerado 2022 (head del pool medido en 2022 justo antes de reservar_log.py).
