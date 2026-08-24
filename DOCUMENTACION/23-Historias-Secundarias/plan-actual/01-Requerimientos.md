# 01 — Requerimientos — M23: Historias Secundarias

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Problema

La isla necesita vida narrativa más allá de la Historia Principal (M22): historias de vecinos, lugares, ruinas, objetos, familias, comerciantes y estaciones, además de 9 tipos de misiones (exploración, construcción, agricultura, pesca, colección, amistad, investigación, puzzles, postgame) con recompensas narrativas y cosméticas, consecuencias y diálogos posteriores — todo sin caer en "misiones genéricas repetidas" (regla explícita del plan).

## Objetivos

- Resolver los 25 puntos de la sección 22 del plan maestro.
- Definir las cadenas de misiones y sus recompensas/consecuencias.
- Misiones con **contexto** (siempre atadas a un lugar/vecino/lore — nunca genéricas).
- Misiones ocultas y misiones de postgame.
- Estructura como **datos** que el sistema de misiones (M68) ejecute.

## Alcance

- 8 tipos de historias: vecinos, lugares, ruinas, objetos, familias, comerciantes, estacionales, secretas.
- 9 tipos de misiones: exploración, construcción, agricultura, pesca, colección, amistad, investigación, puzzles (+ postgame).
- Cadenas de misiones (3-5 pasos por cadena), recompensas narrativas y cosméticas, consecuencias persistentes, diálogos posteriores.
- Anti-repetición: catálogo de 40+ cadenas únicas con contexto (nunca generadas proceduralmente para relleno).

## Fuera de alcance

- Historia Principal (M22) y sus decisiones — solo hooks para consecuencias.
- Ejecución técnica de misiones (M68) y sistema de logros (M72) — solo contratos.
- Diálogo por línea (M23 de diálogo no existe; los textos viven en datos del módulo).
- Postgame completo (M75) — solo el enganche.

## Restricciones

- **Anti-repetición:** prohibido el "recoge 10 X"; toda misión tiene contexto (quién, dónde, por qué).
- **Cozy:** cero castigos por no completar; las cadenas avanzan por elección del jugador; consecuencias siempre benévolas o narrativas.
- **Persistencia:** cada cadena guarda estado (paso, completada, consecuencias aplicadas) en el guardado atómico.
- **Datos-driven:** cadenas en JSON; validación automática (sin referencias rotas, sin requisitos imposibles — M66).
- Documentación `{ID}-Nombre` (`plan-inicial/` inmutable, `plan-actual/` espejo).

## Criterios de éxito

1. Los 25 puntos de la sección 22 resueltos y verificables.
2. Catálogo de 40+ cadenas con contexto verificables (cada cadena referencia un lugar/vecino real del mundo).
3. Suite de testings: cadenas completables de punta a punta, cero softlocks, recompensas únicas.
4. Las consecuencias y diálogos posteriores son persistentes y verificables.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M022** — Historia Principal | Secuelas de la historia |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M022** — Historia Principal | Depende de este módulo |

