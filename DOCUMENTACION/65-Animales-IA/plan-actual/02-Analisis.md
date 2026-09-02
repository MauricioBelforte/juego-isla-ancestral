# 65-Animales-IA — Análisis (plan-actual)

**Modelo:** Hy3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02

## Dominio
M65 es la capa de movimiento: recibe intenciones de M36 (`solicitar_movimiento`)
y las ejecuta moviendo el `Node3D` del animal. Mantiene un mapa de individuos con
presupuesto y anti-stuck.

## Alternativas
- Mover dentro de M36 directamente vs capa separada M65: se eligió capa separada
  para desacoplar la IA de la definición de especie.
- Boids (PackLogic/SchoolLogic) como RefCounted reutilizables para manada/banco.

## Hallazgo crítico de QA (Log 415)
`FaunaBehavior.tick()` (FSM) no era invocado por nadie → en gameplay real los
animales no se moverían. Corregido: el behavior se auto-impulsa vía `_process`
y cablea `solicitar_avistamiento` al registry. Véase `04-Codigo.md`.

## Dependencias
- M36 Fauna (señal `solicitar_movimiento`, nodo `FaunaBehavior`).
- M59 SaveManager (persistencia de presupuesto).
- M61 (presupuesto de simulación), M08 (voxels para pathfinding futuro).
