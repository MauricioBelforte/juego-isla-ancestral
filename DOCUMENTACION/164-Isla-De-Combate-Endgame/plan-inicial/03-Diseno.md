**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 03-Diseno.md — Modulo 164: Isla de Combate Endgame

## 1. Arquitectura del Sistema

```
CombatIslandSystem (autoload)
├── GemCurrency (Resource)            <- sistema de gemas
├── IslandZone (Resource)             <- zona de la isla
├── EnemyData (Resource)              <- definicion de enemigos
├── BossData (Resource)               <- definicion de jefes
├── CombatReward (Resource)           <- recompensas de combate
├── GemExchangeNPC (Node3D)           <- NPC que intercambia por gemas
├── EnemySpawner (Node3D)             <- spawner de enemigos
└── CombatIslandUI (Control)          <- UI de la isla
```

## 2. Definicion de Zonas

| Zona | Gemas | Enemigos | Recompensas |
|------|-------|----------|-------------|
| Costa | 0 | Mobs basicos (1-3 HP) | Gemas, recursos comunes |
| Bosque | 10 | Mobs medianos (5-8 HP) | Gemas, recursos raros |
| Montaña | 25 | Mobs fuertes (10-15 HP) | Gemas, jefe 1 |
| Templo | 50 | Jefe final (50 HP) | Recompensas exclusivas |

## 3. Definicion de Enemigos

### Mobs Basicos (Costa)

| ID | Nombre | HP | Ataque | Velocidad | Gemas |
|----|--------|----|----|-----------|-------|
| slime_verde | Slime Verde | 3 | 1 | lento | 1 |
| murcielago_noche | Murcielago de Noche | 2 | 1 | rapido | 1 |
| cangrejo_roca | Cangrejo de Roca | 4 | 2 | medio | 2 |

### Mobs Medianos (Bosque)

| ID | Nombre | HP | Ataque | Velocidad | Gemas |
|----|--------|----|----|-----------|-------|
| lobo_sombra | Lobo de Sombra | 6 | 3 | rapido | 2 |
| arbol_maldito | Arbol Maldito | 8 | 2 | lento | 3 |
| espiritu_bosque | Espiritu del Bosque | 5 | 2 | medio | 2 |

### Mobs Fuertes (Montana)

| ID | Nombre | HP | Ataque | Velocidad | Gemas |
|----|--------|----|----|-----------|-------|
| golem_piedra | Golem de Piedra | 12 | 4 | lento | 3 |
| dragon_montana | Dragon de Montana | 10 | 3 | rapido | 4 |
| troll_montana | Troll de Montana | 15 | 5 | lento | 5 |

### Jefes

| ID | Nombre | HP | Ataque | Fase | Gemas |
|----|--------|----|----|------|-------|
| guardian_montana | Guardian de la Montana | 30 | 4 | 3 fases | 8 |
| senor_templo | Senor del Templo | 50 | 6 | 4 fases | 15 |

## 4. Sistema de Combate

```
Jugador entra en rango de enemigo
  → Enemigo activa IA (perseguir/atacar)
  → Jugador usa herramienta para atacar
  → Herramienta tiene dano segun tier (M13)
  → Encantamiento da bonus especial (M163)
  → Al derrotar enemigo: gemas + recursos
  → Si jugador "pierde" (HP <= 0): vuelve al pueblo sin penalidad
  → No se pierden objetos
  → No hay game over
```

## 5. Recompensas Exclusivas

| Recompensa | Tipo | Como se obtiene |
|------------|------|-----------------|
| Skin "Guerrero Ancestral" | Cosmetico | Derrotar Guardian de la Montana |
| Skin "Senor del Templo" | Cosmetico | Derrotar Senor del Templo |
| Titulo "Cazador de Cristal" | Titulo | Derrotar 100 enemigos |
| Decoracion "Estandarte de Victoria" | Mueble | Completar la isla al 100% |
| Herramienta "Filo Ancestral" | Herramienta T3 especial | Recompensa de jefe |
| Montura "Corcel de Batalla" | Montura | Recompensa de jefe final |

## 6. Tienda de la Isla

| Item | Precio | Descripcion |
|------|--------|-------------|
| Pocion de vida | 5 gemas | Restaura 3 HP |
| Escudo temporal | 10 gemas | Bloquea 1 ataque |
 mapa de la isla | 3 gemas | Muestra ubicacion de enemigos |
 | Antorcha | 2 gemas | Ilumina zonas oscuras |

---

## Modulos Relacionados

### Depende de

| Modulo | Que aporta |
|--------|------------|
| **M158** — Herramientas | Acceso a isla |
| **M163** — Encantamientos | Fuente de gemas |
| **M22** — Historia | Contexto |
| **M27** — Islas | Estructura |
| **M38** — Economia | Gemas |

### Relacionados laterales

| Modulo | Relacion |
|--------|----------|
| **M013** — Herramientas | Combate |
| **M039** — Tiendas | Tienda isla |
| **M014** — Inventario | Guarda gemas |
| **M071** — Progresion | Hitos |
| **M072** — Logros | Logros |
