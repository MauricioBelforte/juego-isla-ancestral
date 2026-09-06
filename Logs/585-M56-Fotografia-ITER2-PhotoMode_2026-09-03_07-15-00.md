# Log 585: M56 Fotografía — iter. 2 PhotoMode (entrada/salida con mundo congelado)

**Fecha:** 2026-09-03
**Hora:** 07:15
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Iter. 2 de M56 Fotografía: PhotoService promovido a autoload (único administrador del modo) con PhotoMode completo de entrada/salida: mundo congelado vía GameClock (M31), logs PHOTO-ENTER/EXIT, bloqueo de acciones de juego y restauración exacta del estado previo. 8 ítems marcados [x] → 12/137.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `scripts/foto/photo_service.gd` | +_entrar_modo_foto()/_salir_modo_foto() (pausa/resume GameClock, _camara_previa, _clock_pausado_antes para respetar pausa previa), acciones_bloqueadas(), set_modo_foto() ahora orquesta el ciclo con idempotencia |
| `project.godot` | Autoload PhotoService registrado |
| `scripts/foto/test_photomode.gd` *(nuevo)* | 12 checks: presets, entrada/salida, señal, idempotencia, bloqueo de acciones, reloj pausado/reanudado |
| `DOCUMENTACION/56-Fotografia/plan-actual/05-Checklist.md` | 8 ítems [x] + Notas del Agente |
| `CHECKLIST-GLOBAL.md` / `ESTADO-PARALELO.md` | M56 iter. 2 Liberado (12/137) |

## Tests (headless Godot 4.7.2)
- `test_photomode.gd`: **0 fallos** (12 checks) — logs PHOTO-ENTER/EXIT visibles, reloj pausado dentro/reanudado fuera, acciones bloqueadas/libres, doble entrada/salida sin dobles señales ni roturas
- Regresión: `test_photo_service_headless.gd` (core presets, iter. 1) **10 checks, 0 fallos**

## Notas técnicas
- Respeto de pausa previa: si el reloj ya estaba pausado (menú), al salir del modo foto NO se reanuda — restauración exacta del estado anterior (checklist A3).
- acciones_bloqueadas() es la API de bloqueo consultable por M57/M70 — sin capturar input directamente (desacople §9).
- Pendientes V2 con dueño de visión: Navigator/cámara libre, filtros de render (M49), fijar hora/clima, UI de captura.
