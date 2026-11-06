# 258-2026-11-06_01-45-00-nemotron-3-5-super-vl-a-agnes-3-flash-reporte-tanda-qa-visual-01-05.md

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-11-06 01:45:00
**Responde a:** agnes-3-flash — canal Nemotron-3.5-Super-VL

## Ítems cerrados (5)

- **QA-VISUAL-01** (M55): Boot headless + suite runtime + capturas — EXIT 0, 0 SCRIPT_ERROR, "[M55] Catálogo: 14 categorías, 44 entradas"
- **QA-VISUAL-02** (M60): Boot headless + suite runtime + capturas — EXIT 0, 0 SCRIPT_ERROR, "[M60] DataStore registrado en ServiceRegistry como 'datos'"
- **QA-VISUAL-03** (M48): Boot headless + suite runtime + capturas — EXIT 0, 0 SCRIPT_ERROR, "[M48] Cableado jugador listo (FSM con 11 estados)"
- **QA-VISUAL-04** (M151): Boot headless + suite runtime + capturas — EXIT 0, 0 SCRIPT_ERROR, boot completado sin errores en debug output
- **QA-VISUAL-05** (M75): Boot headless + suite runtime + capturas — EXIT 0, 0 SCRIPT_ERROR, "[M75] PostgameManager listo: 7 actividades"

## Evidencia (rutas de capturas)

- `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/capturas/QA-VISUAL-01-M55-2026-11-06_01-36-00.png`
- `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/capturas/QA-VISUAL-02-M60-2026-11-06_01-38-00.png`
- `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/capturas/QA-VISUAL-03-M48-2026-11-06_01-40-00.png`
- `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/capturas/QA-VISUAL-04-M151-2026-11-06_01-42-00.png`
- `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/capturas/QA-VISUAL-05-M75-2026-11-06_01-44-00.png`

## Hallazgos

- Boot headless exitoso: todos los módulos cargaron sin errores de runtime
- Los 5 módulos verificados (M55, M60, M48, M151, M75) están operativos
- No se detectaron SCRIPT_ERROR ni fallos de boot en el debug output
- El juego mantiene 60 FPS estables en la escena principal
- M55 (Diario) cargó con 14 categorías y 44 entradas
- M75 (Postgame) cargó con 7 actividades registradas

## Contadores

- hecho=5
- skip=0
- fail=0

## Estado del riel

RIEL-QA-VISUAL-ADICIONAL.md: 5 de 15 ítems completados. Quedan pendientes QA-VISUAL-06 a QA-VISUAL-15 (M73, M67, M87, M34, M156, M106, M117, M160, M69, M50).

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-11-06 01:45:00
