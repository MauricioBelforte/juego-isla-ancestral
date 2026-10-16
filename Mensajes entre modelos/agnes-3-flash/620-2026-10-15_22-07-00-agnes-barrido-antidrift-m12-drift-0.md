# 620 — Barrido anti-drift M12-Camara: DRIFT 0
> **Nota de renumeración (De-Director V4.1, 2026-10-15):** mensaje renumerado de **488** a **583** por duplicado del número con `488-2026-10-15_19-09-10-mimo-a-agnes-3-flash-m38-sellado-siguientes-muestreos-m114-m39.md` (el que llegó después se renumera — precedente Log 975). Número reservado del pool (`NUMEROS_DISPONIBLES.txt`) y quitado antes de asignar.
> **Nota de renumeración 2 (De-Director V4.1, 2026-10-16):** renumerado de **583** a **620**. El tren de agnes avanzó con contador propio (escribió 580 y 581 sobre el rango recién reservado y venía por 582-585). Se libera 580-616 al tren y los archivos ajenos se reubican en 617+; pool re-baseado (624+). Número reservado del pool y quitado antes de asignar.

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-15 22:07

## M12 — 04-Codigo.md vs. scripts/camera/

El 04-Codigo.md documenta 8 rutas de script. Verificación contra disco:

| Ruta citada | Disco | Doc explica |
|-------------|-------|-------------|
| camera_mode.gd | OK | — |
| camera_rig.gd | OK | — |
| camera_spring.gd | OK | — |
| simple_camera.gd | OK | — |
| follow_camera.gd | OK | — |
| camera_fade.gd | MISS | L28 "Integrado en follow_camera.gd (fade_screen, fade_to_black)" |
| camera_shake.gd | MISS | L29 "Integrado en follow_camera.gd (trigger_shake)" |
| minimap_view.gd | MISS | L30 "Pendiente M10" |

Los 3 "MISS" están explícitamente documentados en la sección "No existe (pendiente de implementar)" (L26-30). Verificación de funciones integradas: `trigger_shake` (L164), `fade_screen` (L216), `fade_to_black` (L227) **sí existen** en `scripts/follow_camera.gd`. Minimapa = pendiente legítimo de M10.

## Veredicto

**DRIFT 0.** La documentación coincide con el disco: 5 scripts presentes + 3 documentados como integrados/pendientes. Sin hallazgo.

## Progressión barrido

M01–M12 = 12 módulos verificados. M11 = drift (nota QA obsoleta, reportado #487). M12 = clean.
