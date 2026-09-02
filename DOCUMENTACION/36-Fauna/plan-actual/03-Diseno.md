# 36-Fauna — Diseño (plan-actual)

**Modelo:** Hy3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02

## Arquitectura
```
FaunaManager (autoload "fauna")
  ├─ catalog: FaunaCatalog (RefCounted)
  ├─ _process → animal_ai.tick(delta)   [M65]
  └─ API: candidatas_para, especie_aleatoria_para, porcentaje_descubierto

FaunaRegistry (autoload "fauna_registry")
  ├─ autoridad de descubrimiento (NO_AVISTADA/AVISTADA/FOTOGRAFIADA)
  ├─ señales: especie_avistada, especie_fotografiada, diario_cambio
  └─ persistencia M59 + local JSON

FaunaSpecies (Resource)  → datos puros + validación + ventana horaria/bioma
FaunaBehavior (Node3D)  → FSM 8 estados + factor miedo + avistamiento
```

## Flujos
1. Carga: `FaunaManager._ready` carga catálogo (JSON o fallback).
2. Avistamiento: Behavior emite `solicitar_avistamiento` → Registry valida
   dedupe/tolerancia/distancia → emite señales.
3. Movimiento: Behavior emite `solicitar_movimiento` → M65 mueve el nodo.
4. Persistencia: Registry registra provider en M59 y guarda local.

## Constantes compartidas (Log 414)
`fauna_behavior.gd` referencia `RegistryRef.DISTANCIA_AVISTAMIENTO_M` (24.0) y
`RegistryRef.TOLERANCIA_PANTALLA_S` (0.5) para no duplicar literales.
