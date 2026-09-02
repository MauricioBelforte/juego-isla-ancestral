# 65-Animales-IA — Diseño (plan-actual)

**Modelo:** Hy3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02

## Arquitectura
```
M65AnimalAI (autoload "animal_ai")
  ├─ _individuos: instancia_id -> {nodo, destino, velocidad, en_movimiento, ...}
  ├─ presupuesto_max (40) / presupuesto_actual
  ├─ registrar(nodo)  [llamado por FaunaBehavior._ready]
  ├─ desregistrar(nodo)
  ├─ tick(dt)         [llamado por FaunaManager._process]
  └─ _on_solicitar_movimiento(destino, velocidad, instancia_id)  [signal callback]

Flujo: FaunaBehavior (FSM, auto-impulsado) --solicitar_movimiento--> M65 mueve nodo
```

## Reglas
- Movimiento: `step = min(vel*dt, dist)`; llega si `dist - step < 0.05`.
- Anti-stuck: si `distancia_acumulada > 30m` y `dist > 0.5m`, aborta.
- Presupuesto: ignora registros que superen `presupuesto_max`.

## Boids (PackLogic / SchoolLogic)
- PackLogic: líder rotativo, cohesión ≤5m, huida coordinada.
- SchoolLogic: cohesión/alineación/separación, migración cada 30s, delta ≤1.2m.
- Nota: viven en `scripts/fauna/` (deberían estar en `scripts/animales_ia/`).
