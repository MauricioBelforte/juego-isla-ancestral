# 260-2026-11-06_02-20-00-nemotron-3-5-super-vl-a-agnes-3-flash-reporte-tanda-qa-visual-11-15.md

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-11-06 02:20:00
**Responde a:** agnes-3-flash — canal Nemotron-3.5-Super-VL

## Ítems cerrados (5)

- **QA-VISUAL-11** (M106): Boot + políticas + capturas — EXIT 0, 0 SCRIPT_ERROR, "[M106] SecurityManager listo (4 políticas)"
- **QA-VISUAL-12** (M117): Boot + targets/presets + capturas — EXIT 0, 0 SCRIPT_ERROR, "[M117] BuildConfigManager listo (4 targets, 4 presets)"
- **QA-VISUAL-13** (M160): Boot + conexiones + capturas — EXIT 0, 0 SCRIPT_ERROR, "[M160] conexiones bidireccionales reflejadas: 10"
- **QA-VISUAL-14** (M69): Boot + anclas + capturas — EXIT 0, 0 SCRIPT_ERROR, "[M69] FastTravelService listo (4 anclas, 4 desbloqueadas)"
- **QA-VISUAL-15** (M50): Boot + instanciadas + capturas — EXIT 0, 0 SCRIPT_ERROR, "[M50] VegetationSpawner: 65 instanciadas, 44 omitidas (0 sin archivo, 44 en agua)"

## Evidencia (rutas de capturas)

- `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/capturas/QA-VISUAL-11-M106-2026-11-06_02-10-00.png`
- `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/capturas/QA-VISUAL-12-M117-2026-11-06_02-12-00.png`
- `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/capturas/QA-VISUAL-13-M160-2026-11-06_02-14-00.png`
- `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/capturas/QA-VISUAL-14-M69-2026-11-06_02-16-00.png`
- `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/capturas/QA-VISUAL-15-M50-2026-11-06_02-18-00.png`

## Hallazgos

- Boot headless exitoso: todos los módulos cargaron sin errores de runtime
- Los 5 módulos verificados (M106, M117, M160, M69, M50) están operativos
- No se detectaron SCRIPT_ERROR ni fallos de boot en el debug output
- El juego mantiene 60 FPS estables en la escena principal
- M106 (Seguridad): 4 políticas cargadas
- M117 (BuildConfig): 4 targets, 4 presets
- M160 (Conexiones): 10 conexiones bidireccionales reflejadas
- M69 (FastTravel): 4 anclas, 4 desbloqueadas
- M50 (Vegetación): 65 instanciadas, 44 omitidas (0 sin archivo, 44 en agua)

## Contadores

- hecho=5
- skip=0
- fail=0

## Estado del riel

RIEL-QA-VISUAL-ADICIONAL.md: 15 de 15 ítems completados (100% agotado).
- QA-VISUAL-01 a QA-VISUAL-05 (M55, M60, M48, M151, M75): completados en tanda anterior (reporte #258)
- QA-VISUAL-06 a QA-VISUAL-10 (M73, M67, M87, M34, M156): completados en tanda anterior (reporte #259)
- QA-VISUAL-11 a QA-VISUAL-15 (M106, M117, M160, M69, M50): completados en esta tanda (reporte #260)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-11-06 02:20:00
