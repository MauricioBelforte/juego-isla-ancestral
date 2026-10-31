# 65-Animales-IA — Diseño (plan-actual)

**Modelo:** Hy3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02

## Arquitectura
```
M65AnimalAI (autoload "animal_ai")
  â”œâ”€ _individuos: instancia_id -> {nodo, destino, velocidad, en_movimiento, ...}
  â”œâ”€ presupuesto_max (40) / presupuesto_actual
  â”œâ”€ registrar(nodo)  [llamado por FaunaBehavior._ready]
  â”œâ”€ desregistrar(nodo)
  â”œâ”€ tick(dt)         [llamado por FaunaManager._process]
  â””â”€ _on_solicitar_movimiento(destino, velocidad, instancia_id)  [signal callback]

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

## Anti-stuck (individual + grupo coordinado)

**Individual — IMPLEMENTADO** (`scripts/animales_ia/m65_animal_ai.gd` L159-168):
todo individuo registrado en el autoload acumula `distancia_acumulada`; si
supera **30 m** sin haber llegado (`dist > 0.5`), aborta el movimiento
(`en_movimiento = false`) y resetea el acumulador. El reset también ocurre al
llegar a destino (L151/L163). Cubierto por
`scripts/animales_ia/test_m65.gd` â†’ *"anti-stuck: tras 35m acumulados, aborta"*
(medido 2026-10-19: 24 OK / 0 fallos / EXIT 0).

**Herencia por grupo — VIGENTE:** PackLogic y SchoolLogic emiten
`solicitar_movimiento` sobre sus miembros, que están registrados en el
autoload `animal_ai` â†’ cada miembro hereda el anti-stuck individual. No
existe hoy un aborto exclusivo de grupo (verificado 2026-10-19: 0
referencias a `distancia_acumulada`/aborto en `pack_logic.gd` ni
`school_logic.gd`).

**Grupo coordinado — DISEÑO (implementación diferida a navmesh M65,
KnownIssue no bloqueante; ítems 36-Fauna L208/L212):**

- *Manada (PackLogic):* si el líder queda sin movimiento por aborto
  individual y un seguidor está a más de `DELTA_SEGUIDOR` (5 m), el seguidor
  recalcula la cohesión hacia la posición **actual** del líder. Si el grupo
  completo no desplaza más de 0.5 m en 5 s, rotación forzada de líder.
- *Banco (SchoolLogic):* si la dirección grupal no produce desplazamiento
  neto (≤ 0.5 m en 5 s), forzar migración anticipada: reset de
  `_tiempo_migracion` + nueva dirección aleatoria (adelanta el ciclo de 30 s).
- *Prueba:* cuando se implemente, extender `tests/test_m65.gd` con casos de
  grupo (líder abortado con seguidor lejano; banco sin desplazamiento).

## Specs Animales-IA (Beam 516)

### Movimiento real con NavigationServer3D evitando voxels (M08)
- Spec: movimiento real con NavigationServer3D evitando voxels. Coherente con M65 (animales-IA) y M08 (terreno).