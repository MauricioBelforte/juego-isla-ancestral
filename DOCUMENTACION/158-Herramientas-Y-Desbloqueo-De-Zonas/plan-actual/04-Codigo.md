**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 04-Codigo.md — Modulo 158: Herramientas y Desbloqueo de Zonas

## 1. Archivos del Modulo

| Archivo | Tipo | Descripcion |
|---------|------|-------------|
| tool_tier_system.gd | Autoload | Sistema central de tiers y gates |
| tool_tier_definition.gd | Resource | Definicion de cada tier |
| zone_gate.gd | Node3D | Gate en el mundo (rama, muro, sello, etc.) |
| zone_gate_definition.gd | Resource | Que tier necesita cada zona |
| forge_recipe.gd | Resource | Receta de forja por isla |
| course_definition.gd | Resource | Curso de oficio por isla |
| forge_ui.gd | Control | UI de la forja del herrero |
| course_ui.gd | Control | UI del curso de oficio |
| shop_visitor_manager.gd | Autoload | Manager de NPCs visitantes |
| player_tool_progress.gd | Resource | Progreso de tiers y cursos del jugador |
| jar_spawner.gd | Node3D | Spawner de jarrones con reposicion semanal |
| gold_fish_spawner.gd | Node3D | Spawner de peces dorados diarios |
| gold_tree_spawner.gd | Node3D | Spawner de arboles con frutos dorados |

## 2. Contratos Clave

```
# Verificar si el jugador puede acceder a una zona
ToolTierSystem.can_access_zone(zone_id: String) -> bool

# Obtener tier maximo del jugador para un tipo de herramienta
ToolTierSystem.get_max_tier(tool_type: String) -> ToolTier

# Forjar herramienta
ToolTierSystem.forge_tool(recipe_id: String, materials: Array) -> bool

# Tomar curso
ToolTierSystem.take_course(course_id: String) -> bool

# Registrar gate desbloqueado
ToolTierSystem.unlock_gate(gate_id: String) -> void

# Verificar si un gate bloquea la historia
ToolTierSystem.is_story_gate(gate_id: String) -> bool
```

## 3. Flujo de Forja

```
Jugador habla con herrero en Isla Ceniza
    → Se abre ForgeUI con recetas disponibles
    → Jugador selecciona herramienta T2 (hierro)
    → ForgeUI muestra materiales necesarios + monedas
    → Si tiene todo: confirma forja
    → Se consumen materiales y monedas
    → Se entrega herramienta T2 al inventario
    → Se registra en PlayerToolProgress
    → Se notifica a M71 (Progresion)
    → Se emite señal tool_forged(tier, tool_type)
```

## 4. Flujo de Gate

```
Jugador se acerca a ZoneGate (muro de piedra)
    → ZoneGate verifica PlayerToolProgress
    → Si tiene tier requerido:
        → Animacion de romper/extraccion
        → Gate desaparece permanentemente
        → Se registra en PlayerToolProgress
        → Se emite signal gate_unlocked(zone_id)
    → Si NO tiene tier:
        → Feedback visual (brillo rojo suave)
        → Tooltip: "Necesitas pico de Cobre o superior"
        → NO se bloquea el juego, solo esa zona
```

## 5. Flujo de NPC Visitante

```
Cada dia (GameClock.nuevo_dia)
    → ShopVisitorManager.generate_visitor()
    → Selecciona 1 NPC aleatorio del pool
    → NPC va a la tienda del jugador
    → Compra 1-3 items del stock
    → Paga precio de M38
    → Se registra transaccion
    → Se notifica al jugador
```

## 6. Integraciones

| Modulo | Contrato |
|--------|----------|
| M13 | ToolTierSystem extiende el sistema de herramientas existente |
| M38 | EconomyManager.get_sell_price() para NPCs visitantes |
| M27 | Cada isla declara sus profesionales y recetas |
| M28 | Boleto de barco como gating suave entre islas |
| M22 | HistoriaPrincipal verifica tier minimo por capitulo |
| M29 | GameClock para reposicion semanal de jarrones |
| M71 | ProgressManager registra hitos de tier |
| M95 | PremiumManager para compra de monedas |

## 7. Persistencia

```gdscript
# PlayerToolProgress se guarda en GameState.M158
{
    "max_tiers": {"pico": 2, "hacha": 1, "pala": 0, ...},
    "courses_learned": ["carpinteria_basica"],
    "gates_unlocked": ["muro_pueblo_1", "raiz_templo_2", ...],
    "forge_count": 5,
    "visitor_sales_total": 47
}
```
