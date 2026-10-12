# M164 — Isla de Combate Endgame: Especificación de Zonas y Spawners

**Módulo:** M164
**Autor:** agnes-3-flash (Kilo Code)
**Fecha:** 2026-10-12
**Uso:** Documento de referencia para implementación de spawners y contenido por zona.

---

## Zonas de la Isla — Detalle

### Costa (gratis)
- **Mobs:** Slime (3×), Murciélago (3×), Cangrejo (3×)
- **Spawner:** `scripts/combat/spawners/costa_spawner.gd` — 9 entidades, spawn rate 2/min
- **Tienda básica:** 3 objetos (poción, escudo, espada T1)
- **Bioma:** Arena + agua + vegetación litoral

### Bosque (10 gemas)
- **Mobs:** Lobo (3×), Árbol Maldito (3×), Espíritu (3×)
- **Spawner:** `scripts/combat/spawners/bosque_spawner.gd` — 9 entidades, spawn rate 1.5/min
- **Recursos raros:** Hierba luminosa, resina ancestral, flor de hueso
- **Bioma:** Bosque denso + claro central

### Montaña (25 gemas)
- **Mobs:** Golem de Piedra (3×), Dragón Menor (3×), Troll (3×)
- **Spawner:** `scripts/combat/spawners/montana_spawner.gd` — 9 entidades, spawn rate 1/min
- **Jefe:** Guardián de la Montaña (HP 500, 3 fases, drop: Espada Ancestral + Título "Conquistador")
- **Bioma:** Roca + nieve + cristal

### Templo (50 gemas)
- **Jefe:** Señor del Templo (HP 1000, 4 fases, drop: Arma Ancestral + Título "Guardián Final")
- **Recompensas exclusivas:** Armadura Ancestral, Escudo Radiante, Gorra Luminosa
- **Bioma:** Ruinas + glifos + energía ancestral

## Spawner Base (shared)

```gdscript
class_name ZoneSpawner extends Node
# Campamentos: {zona: "costa"}
# Mobs: [mob_id, mob_id, ...] (max 9)
# Spawn rate: float (2.0 = 2/min)
# Aggro range: int (50 = 50m)
# Loot table: {item_id: [prob_min, prob_max]}
# Cooldown: float (10.0 = 10s entre spawns)
```

## Tienda (Costa)

| Item | Precio (gemas) |
|------|---------------|
| Poción Menor | 2 |
| Escudo T1 | 5 |
| Espada T1 | 5 |
| Coraza T1 | 5 |
| Amuleto Ancestral | 15 |
