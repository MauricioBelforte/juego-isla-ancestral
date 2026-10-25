# 06-Plan-Testings.md — Módulo 33: Agricultura

**Modelo:** Step-5-WorkBuddy (último modificador; suites previas por Deepseek V4 Flash, atria y G-5.3-Flash-Agente)
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-25

## 1. Alcance

Este documento no existía en el plan-actual de M33 (creado 2026-10-25 por
Step-5-WorkBuddy, riel asignado por la directora agnes-3-flash msg 218).
Registra el plan de testings del módulo y los resultados medidos en
`07-Resultados-Testings.md`.

Binario de verificación (único aceptado):
`D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral --script res://scripts/farm/<suite>.gd`

## 2. Suites del módulo (5, todas en `scripts/farm/`)

| Suite | Bloques | Piso (`CHECKS_MINIMOS`) | Cubre |
|---|---|---|---|
| `test_farm.gd` | catálogo, ciclo completo, pausa de agua, persistencia, ruta del controller | 29 | RF1-RF7: arar, plantar (consume semilla M14), regar, avance diario M29, cosecha M14,persistencia M59 |
| `test_farm_clima.gd` | riego por lluvia, sin exceso, climas secos no riegan | 20 | Puente M32→M33: LLUVIA/TORMENTA/TROPICAL riegan; nunca exceden agua 2 |
| `test_farm_m33_lote.gd` | determinismo, 4 estaciones, 30 días sin agua, inventario lleno, pisoteo NPC, stress 400 | 30 | Sección N + K + L: determinismo save/recarga, ventana estacional, pausa sin muerte, cosecha bloqueada, contrato de pisoteo, estrés |
| `test_farm_voxel_m33.gd` | arar escribe voxel, variante húmeda/seca, lluvia húmeda, cosecha conserva arada, nieve no borra estado, headless sin terrain | 20 | Integración M08: TIERRA_ARADA (id 31) y variante húmeda |
| `qa_farm_pausas_m33.gd` | dormante retoma, doble pausa, sequía sin muerte, decorativo, árbol en invierno | 17 | Reglas cozy: pausa nunca retrocede, cero pérdida de progreso |

## 3. Guarda anti-falso-verde (3 capas, obligatoria en toda suite)

Todas las suites del módulo instrumentan:

1. `_fin(bloque)` por bloque ejecutado (`_WB_BLOQUES`).
2. `CHECKS_MINIMOS` MEDIDO en verde (nunca estimado).
3. `_summary()` diferido aparte (`call_deferred`) con `quit(1 si fallos)`.

**Verificación del guardián (2026-10-25, Step-5-WorkBuddy):** sonda por inyección
de runtime sobre `test_farm_m33_lote.gd` (subscript dinámico
`_farm` → `Dictionary`, abort dentro de `_test_determinismo`):

- CON piso: EXIT 1, «solo 27 checks ejecutados (mínimo 30)», 1 fallo.
- SIN piso (sonda con `CHECKS_MINIMOS := 0`): EXIT 0, 27 checks, 0 fallos =
  **falso verde demostrado**. El piso es la capa que caza el abort.

Trampa registrada: el `_fin()` de cada bloque lo llama el runner DESPUÉS de la
función, así que un abort dentro de un bloque NO se ve en la capa de bloques
(solo el piso lo detecta). Ver Log 2180 §3.

## 4. Pendientes de testing (honesto)

- Los 28 `[ ]` restantes del checklist son de dueño externo (M22, M16, M38/M39,
  M53, M44, M45/M46, M64, M17, M92/M152, M43, M42, M52, M31/M32, M70, M14) o de
  feature propia aún no implementada (P13/P15/P23/P24, L183/L185/L188/L199/L201).
- Deuda de rendimiento M61 abierta: `advance_day` full ~430 ms sobre ~400
  cultivos (I/O de visuales + voxels); el modelo puro mide 1 ms.
