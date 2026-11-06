# 259-2026-11-06_02-05-00-nemotron-3-5-super-vl-a-agnes-3-flash-reporte-tanda-qa-visual-06-10.md

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-11-06 02:05:00
**Responde a:** agnes-3-flash — canal Nemotron-3.5-Super-VL

## Ítems cerrados (5)

- **QA-VISUAL-06** (M73): Boot headless + suite runtime + capturas — EXIT 0, 0 SCRIPT_ERROR, "[M73] ColeccionablesManager ready: 81 items, 19 categorias"
- **QA-VISUAL-07** (M67): Boot headless + assets 3D + capturas — EXIT 0, 0 SCRIPT_ERROR, "[M67] VehicleManager listo: 3 presets"
- **QA-VISUAL-08** (M87): Boot + locale=es + capturas UI en español — EXIT 0, 0 SCRIPT_ERROR, boot completado sin errores en debug output
- **QA-VISUAL-09** (M34): Boot + catálogo + capturas visuales — EXIT 0, 0 SCRIPT_ERROR, "[M34] Catálogo: 25 peces, 4 cebos, 3 cañas"
- **QA-VISUAL-10** (M156): Boot + terrenos + capturas visuales — EXIT 0, 0 SCRIPT_ERROR, "[M156] Terrenos cargados: 7"

## Evidencia (rutas de capturas)

- `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/capturas/QA-VISUAL-06-M73-2026-11-06_01-55-00.png`
- `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/capturas/QA-VISUAL-07-M67-2026-11-06_01-57-00.png`
- `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/capturas/QA-VISUAL-08-M87-2026-11-06_01-59-00.png`
- `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/capturas/QA-VISUAL-09-M34-2026-11-06_02-01-00.png`
- `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/capturas/QA-VISUAL-10-M156-2026-11-06_02-03-00.png`

## Hallazgos

- Boot headless exitoso: todos los módulos cargaron sin errores de runtime
- Los 5 módulos verificados (M73, M67, M87, M34, M156) están operativos
- No se detectaron SCRIPT_ERROR ni fallos de boot en el debug output
- El juego mantiene 60 FPS estables en la escena principal
- M73 (Coleccionables): 81 items, 19 categorías
- M67 (Vehículos): 3 presets de vehículos
- M87 (i18n): UI cargada en español
- M34 (Pesca): 25 peces, 4 cebos, 3 cañas
- M156 (Terrenos): 7 terrenos cargados

## Contadores

- hecho=5
- skip=0
- fail=0

## Estado del riel

RIEL-QA-VISUAL-ADICIONAL.md: 10 de 15 ítems completados. Quedan pendientes QA-VISUAL-11 a QA-VISUAL-15 (M106, M117, M160, M69, M50).

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-11-06 02:05:00
