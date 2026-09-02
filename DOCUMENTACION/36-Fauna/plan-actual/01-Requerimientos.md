# 36-Fauna — Requerimientos (plan-actual)

**Modelo:** Hy3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02

> Documentación reversa del estado real tras QA cruzado (Log 414). El módulo fue
> implementado por minimax-m3-free (Log 376) sin documentación previa; este plan
> registra el estado verificado.

## Problema
El juego necesita un sistema de fauna que popule la isla con especies creíbles,
descubribles por el jugador (diario/museo) y con comportamiento básico, sin
acoplarse a otros sistemas (biomas M09, clima M32, IA M65, guardado M59).

## Objetivos
- Catálogo data-driven de especies (JSON + fallback in-code).
- Registro de avistamientos (autoridad única de descubrimiento).
- Comportamiento por individuo (FSM 8 estados) tolerante a ausencia de M65.
- Integración limpia con M65 (movimiento) y M59 (persistencia).

## Alcance (iter 1)
- 6 archivos: `fauna_species.gd`, `fauna_catalog.gd`, `fauna_registry.gd`,
  `fauna_manager.gd`, `fauna_behavior.gd`, `test_fauna.gd` + `data/fauna/catalog.json`.
- Autoloads `fauna` y `fauna_registry`.

## Restricciones
- Sin class_name en autoloads (07-GUIA-GODOT §9.17).
- Duck-typing con M29/M59/M65 (no romper si faltan).
- No generar assets visuales (M45).
- Tests headless 59/0 OK (Log 376).
