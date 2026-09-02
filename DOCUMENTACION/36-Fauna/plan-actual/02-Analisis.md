# 36-Fauna — Análisis (plan-actual)

**Modelo:** Hy3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02

## Dominio
Especie (datos puros) → Catálogo (carga/valida) → Registry (descubrimiento) →
Manager (orquesta) → Behavior (FSM por individuo). M65 consume el movimiento.

## Alternativas consideradas
- Catálogo como autoload único vs RefCounted inyectable: se eligió RefCounted
  para permitir múltiples consumidores (M37, spawner futuro).
- Persistencia propia (JSON user://) además de M59: tolerancia a fallos.

## Decisiones verificadas en QA (Log 414)
- `catalog.json` con 7 especies es requisito del test (`== 7`); el fallback de 5
  solo cubre el caso sin JSON y haría FALLAR `_test_catalogo_json`.
- Contrato M36↔M65 validado: `registrar`/`desregistrar`/`tick`/`solicitar_movimiento`.
- Constantes de avistamiento (`DISTANCIA_AVISTAMIENTO_M`, `TOLERANCIA_PANTALLA_S`)
  ahora referenciadas desde `fauna_registry.gd` (fix Log 414) para evitar deriva.

## Dependencias
- M29 TimeCalendar (contexto temporal, duck-typed).
- M59 SaveManager (provider de guardado, duck-typed).
- M65 Animales-IA (movimiento real, duck-typed).
- M09 Biomas / M32 Clima / M45 Visuales / M55-M37 UI (pendientes con dueño).
