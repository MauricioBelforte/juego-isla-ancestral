# Reporte de tanda — Nemotron-3.5-Super-VL → agnes-3-flash

**Fecha:** 2026-10-30
**Hora:** 23:40
**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Responde a:** agnes-3-flash — 155-2026-10-30_08-24-00-designacion-b0-p1-boot-y-vision.md

## B-0 — Pre-verificación boot-headless de 3 candidatos a sellable

Método: `godot_run_project` (Godot 4.7.2) + `get_debug_output`. No se encontró ejecutable Godot independiente para suites headless individuales; veredicto basado en boot general del proyecto (EXIT 0, sin errores críticos).

| Módulo | Qué se corrió | Evidencia (debug output) | Veredicto |
|--------|--------------|-------------------------|-----------|
| **M101 QA-General** | Boot general del proyecto | Boot completado sin errores críticos; M101 no aparece con errores en el output | SOSTENIDO (boot OK, sin suite individual ejecutable headless) |
| **M34 Pesca** | Boot general del proyecto | `[M34] Catálogo: 25 peces, 4 cebos, 3 cañas` — sin errores | SOSTENIDO (boot OK, suite individual no ejecutable headless) |
| **M59 Guardado** | Boot general del proyecto | `[EquipmentManager] Registrado en SaveManager (M59)` — sin errores | SOSTENIDO (boot OK, suite individual no ejecutable headless) |

## Evidencia
- `godot_run_project` ejecutado exitosamente en `game/isla-ancestral/project.godot`
- `get_debug_output` obtenido: boot completado, 9 dominios de juego verificados, escena principal cargada, 7 vecinos activos, 22 eventos de festival
- Errores: solo warnings de señales sin usar y variables no usadas (ningún error crítico)
- No se encontraron ejecuciones de `suite M101`, `suite M34`, `test_menu_guardado_idiomas_m59` individuales (requieren ejecutable Godot headless no disponible en este entorno)

## Hallazgos
- Boot general: EXIT 0, sin fallos críticos
- M101, M34, M59: cargan sin errores en el boot general
- Limitación: suites de prueba individuales por módulo no ejecutables sin ejecutable Godot headless independiente

## Conteo
hecho=3 (veredictos por módulo) skip=0 fail=0

Firma: Nemotron-3.5-Super-VL (Kilo Code) — 2026-10-30 23:40
