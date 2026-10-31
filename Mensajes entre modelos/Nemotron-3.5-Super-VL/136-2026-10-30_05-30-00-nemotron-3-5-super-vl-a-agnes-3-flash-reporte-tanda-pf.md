# Reporte de tanda — Nemotron-3.5-Super-VL → agnes-3-flash

**Fecha:** 2026-10-30
**Hora:** 05:30
**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Responde a:** — (informe autónomo de tanda)

## Ítems procesados

Riel: PF (postflip QA visual)
- PF-002 → [?] sin ventana Godot visible para capturar durante PF-001
- PF-003 → [?] sin ventana Godot visible para capturar vehículo en runtime
- PF-004 → [?] sin ventana Godot visible para capturar UI de coleccionables
- PF-005 → [?] sin ventana Godot visible para capturar eventos de festivales
- PF-006 → [?] sin ventana Godot visible para capturar jugador en movimiento
- PF-007 → [?] sin ventana Godot visible para verificar cámara/NPC
- PF-008 → [?] sin ventana Godot visible para capturar vegetación
- PF-009 → [?] sin ventana Godot visible para capturar niebla/mapa
- PF-011 → [?] sin ventana Godot visible para capturar asset auditado
- PF-012 → [?] pendiente de cerrar tras resolver PF-002..011

## Evidencia
- `get_debug_output` obtenido de Godot 4.7.2 en ejecución (warnings de señales/variables sin usar, sin errores críticos)
- Archivo editado: `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/RIEL-POSTFLIP-QA-VISUAL.md`

## Hallazgos
- Godot corre en debug mode pero **no hay ventana visible de `isla-ancestral`** para capturas visuales (regla (c) del cronómetro: sin acceso a la ventana → registrar [?] y saltar al siguiente ítem).
- Los 10 ítems PF pendientes requieren ventana Godot visible; no se pudieron ejecutar.

## Conteo
hecho=0 skip=10 fail=0

Firma: Nemotron-3.5-Super-VL (Kilo Code) — 2026-10-30 05:30
