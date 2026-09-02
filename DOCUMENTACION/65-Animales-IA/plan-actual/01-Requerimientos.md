# 65-Animales-IA — Requerimientos (plan-actual)

**Modelo:** Hy3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02

> Documentación reversa tras QA cruzado (Log 415). M65 implementado por
> minimax-m3-free (Log 384) + agnes-2.5-flash (pack_logic/school_logic, Log 453).

## Problema
Ejecutar el movimiento real de los animales de M36 (deambular, huir, alimentarse)
consumiendo la señal `solicitar_movimiento` que emite cada `FaunaBehavior`, con
presupuesto de simulación y anti-stuck.

## Objetivos
- Manager `animal_ai` que mueve nodos según destino/velocidad recibidos.
- Presupuesto global de individuos (M61) y anti-stuck por acumulación de distancia.
- Integración con M36 (señal) y M59 (persistencia de presupuesto).

## Alcance (iter 1)
- `m65_animal_ai.gd` (autoload) + `test_m65.gd`.
- `pack_logic.gd` (manada) + `school_logic.gd` (banco) en `scripts/fauna/`.
- Tests headless 23/0 OK (Log 384).

## Restricciones
- Sin class_name (autoload). Duck-typing con M36. No acoplar a M64 (NPCAgent).
- Tolerante a fallos: si M36 no está, no rompe el arranque.
