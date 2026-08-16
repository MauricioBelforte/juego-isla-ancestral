# 04-Codigo.md — CODIGO DEL PROYECTO (PLAN INICIAL GENERICO)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-15
**Componente:** 01-Fundamentos-Del-Proyecto
**Estado:** Documentación inicial (plan genérico) — sin código implementado aún

> **Nota:** Este archivo documenta el **código planificado** del proyecto base. No existe código fuente real todavía: este componente es la fundación documental. A medida que se desarrollen los 152 módulos, cada uno actualizará su propio `04-Codigo.md` con el código real, y este archivo se mantendrá como mapa de la arquitectura de código prevista.

---

## 1. Convenciones de Código

| Convención | Regla |
|------------|-------|
| Language | C# (.NET Standard 2.1) si Unity · GDScript 2.0 / C# si Godot |
| Namespaces | `IslaAncestral.[Sistema]` (ej: `IslaAncestral.World`, `IslaAncestral.Puzzle`) |
| Nomenclatura | PascalCase clases/métodos/propiedades públicas · camelCase locales · `_campo` privados |
| Documentación | `///` XML docs en clases y métodos públicos |
| Serialización | `[SerializeField]` en vez de `public` cuando sea posible |
| Logging | `Debug.Log/LogWarning/LogError` en desarrollo; sistema con rotación en `Logs/` |
| Tests | Unity Test Framework (Edit Mode + Play Mode) o `gut` en Godot |

---

## 2. Estructura de Archivos Planificada

### 2.1 Núcleo (Core)

| Archivo | Responsabilidad |
|---------|-----------------|
| `IslaAncestral/Core/GameBootstrap.cs` | Orquestación del arranque: servicios, managers, carga del GameState |
| `IslaAncestral/Core/ServiceLocator.cs` | Registro y acceso a servicios desacoplado |
| `IslaAncestral/Core/EventBus.cs` | Bus de eventos global (time tick, weather change, quest update) |
| `IslaAncestral/Core/GameSession.cs` | Estado de sesión entre escenas |

### 2.2 Mundo Voxel (World)

| Archivo | Responsabilidad |
|---------|-----------------|
| `IslaAncestral/World/VoxelGrid.cs` | Grilla 3D de bloques por chunk; lectura/escritura de bloques |
| `IslaAncestral/World/Chunk.cs` | Datos de un chunk (16³/32³), estado de malla, modificaciones |
| `IslaAncestral/World/ChunkMesher.cs` | Face culling + greedy meshing (candidato a hilo secundario) |
| `IslaAncestral/World/ChunkManager.cs` | Streaming, orden de generación por distancia, pooling de meshes |
| `IslaAncestral/World/VoxelRaycaster.cs` | Raycast preciso contra la grilla para herramientas |
| `IslaAncestral/World/TerrainGenerator.cs` | Ruido (Perlin/Simplex), biomas, transiciones |
| `IslaAncestral/World/BlockDatabase.cs` | ScriptableObject/catálogo de bloques (propiedades, materiales) |
| `IslaAncestral/World/WorldDiffStore.cs` | Persistencia incremental de bloques modificados |

### 2.3 Puzzles (Puzzle)

| Archivo | Responsabilidad |
|---------|-----------------|
| `IslaAncestral/Puzzle/SignalType.cs` | Enum de señales: Luz, Peso, Agua, Viento, Semilla, Frio, Calor |
| `IslaAncestral/Puzzle/ISignalEmitter.cs` | Contrato: emite señal |
| `IslaAncestral/Puzzle/ISignalReceiver.cs` | Contrato: recibe señal y dispara acción |
| `IslaAncestral/Puzzle/SignalEmitter.cs` / `SignalReceiver.cs` | Implementaciones base |
| `IslaAncestral/Puzzle/SignalHub.cs` | Ruteo de señales entre emisores y receptores |
| `IslaAncestral/Puzzle/PuzzleManager.cs` | Estado de puzzles activos, checkpoints, reinicios |
| `IslaAncestral/Puzzle/TempleDoor.cs` | Receptor típico: abre/cierra puerta |
| `IslaAncestral/Puzzle/MirrorBeam.cs` | Puzzle de luz: espejos rotatorios y receptores de haz |

### 2.4 Jugador y Herramientas (Gameplay)

| Archivo | Responsabilidad |
|---------|-----------------|
| `IslaAncestral/Gameplay/PlayerController.cs` | Movimiento, cámara en tercera persona, estados |
| `IslaAncestral/Gameplay/ToolController.cs` | Uso de herramientas: pala, pico, hacha, gancho, vara, lanza |
| `IslaAncestral/Gameplay/ITool.cs` | Contrato de herramienta (eficacia de recolección, alcance de acertijo) |
| `IslaAncestral/Gameplay/InteractionSystem.cs` | Detección de interactuables, indicador, prioridad |
| `IslaAncestral/Gameplay/Inventory.cs` | Slots, stacks, categorías, hotbar |
| `IslaAncestral/Gameplay/CraftingSystem.cs` | Recetas, estaciones, preview |
| `IslaAncestral/Gameplay/BuildingSystem.cs` | Colocación de bloques/objetos, validación, snapping |
| `IslaAncestral/Gameplay/WaterTool.cs` | Vara de Flujo: congelar/evaporar agua |

### 2.5 Economía y Comunidad (Economy)

| Archivo | Responsabilidad |
|---------|-----------------|
| `IslaAncestral/Economy/Wallet.cs` | Doble moneda: Gemas de Ámbar y Pases de Mérito |
| `IslaAncestral/Economy/ShopSystem.cs` | Tiendas, stock, rotación, precios |
| `IslaAncestral/Economy/InfrastructureProject.cs` | Obras de Finneas: requisitos, costos, estados |
| `IslaAncestral/Economy/VillagerEconomy.cs` | Compras/ventas de vecinos |

### 2.6 Narrativa (Narrative)

| Archivo | Responsabilidad |
|---------|-----------------|
| `IslaAncestral/Narrative/DialogueSystem.cs` | Motor de diálogo por nodos (carga de árboles externos) |
| `IslaAncestral/Narrative/NarrativeFlags.cs` | Flags consultables: sellos, grabaciones, estado del mundo |
| `IslaAncestral/Narrative/QuestSystem.cs` | Misiones, prerequisitos, estados |
| `IslaAncestral/Narrative/FriendshipData.cs` | Puntos de amistad por NPC, umbrales, regalos |

### 2.7 Sistemas de Mundo (Systems)

| Archivo | Responsabilidad |
|---------|-----------------|
| `IslaAncestral/Systems/TimeSystem.cs` | Reloj del juego: hora, día, estación, año; eventos |
| `IslaAncestral/Systems/SeasonSystem.cs` | Estaciones y contenido estacional |
| `IslaAncestral/Systems/WeatherSystem.cs` | Clima con transiciones y efectos |
| `IslaAncestral/Systems/TravelSystem.cs` | Gran Vapor, boletos, carga diegética, islas |
| `IslaAncestral/Systems/EventCalendar.cs` | Festivales, cumpleaños, eventos mensuales |

### 2.8 IA (AI)

| Archivo | Responsabilidad |
|---------|-----------------|
| `IslaAncestral/AI/NpcAgent.cs` | Máquina de estados: rutina diaria, social, contextual |
| `IslaAncestral/AI/NpcSchedule.cs` | Horarios por hora/día/clima/estación |
| `IslaAncestral/AI/NpcNavigation.cs` | Pathfinding sobre terreno modificable + fallbacks |
| `IslaAncestral/AI/AnimalAgent.cs` | Comportamiento no hostil de fauna |

### 2.9 Persistencia (Persistence)

| Archivo | Responsabilidad |
|---------|-----------------|
| `IslaAncestral/Persistence/GameState.cs` | Estado serializable versionado (ver `03-Diseno.md` §7) |
| `IslaAncestral/Persistence/SaveManager.cs` | Slots, autosave, copias de seguridad |
| `IslaAncestral/Persistence/SaveMigrator.cs` | Migraciones entre versiones de schema |
| `IslaAncestral/Persistence/ChunkSerializer.cs` | Diffs de chunks a disco |

### 2.10 Datos (Data)

| Archivo | Responsabilidad |
|---------|-----------------|
| `IslaAncestral/Data/BlockType.cs` / `ItemType.cs` | Definiciones de bloques/objetos (SO) |
| `IslaAncestral/Data/CraftingRecipe.cs` | Recetas (SO) |
| `IslaAncestral/Data/VillagerProfile.cs` | Personalidad, gustos, diálogos (SO) |
| `IslaAncestral/Data/QuestDefinition.cs` | Misiones (SO) |

---

## 3. Flujo de Arranque (Bootstrapping)

```
Application Start
    → GameBootstrap.Initialize()
        → ServiceLocator.Register(todos los managers)
        → SaveManager.Load(slot)  [o NewGame]
        → WorldManager.GenerateChunksAround(player)
        → EventBus.Publish(GameStarted)
    → Escena jugable
```

---

## 4. Firma de Datos (Save File)

| Campo | Ejemplo |
|-------|---------|
| `schemaVersion` | `1` |
| `seed` | `123456789` |
| `player` | `{ "pos": [x,y,z], "inventory": [...] }` |
| `wallets` | `{ "amber": 420, "merit": 12 }` |
| `worldDiffs` | `{ "chunk_3_5_0": { "2_1_7": "stone", ... } }` |
| `calendar` | `{ "day": 12, "season": "spring", "year": 1, "time": 840 }` |
| `story` | `{ "seals": ["brisa"], "visited": ["aurora", "coral"] }` |

---

## 5. Logs Relacionados

| Log | Descripción |
|-----|-------------|
| `Logs/04-CREACION_COMPONENTE_01-FUNDAMENTOS_2026-08-15_*.md` | Creación del componente base (este log) |
| `Logs/02-ADAPTACION_AGENTS_UNITY_2026-08-15_22-46-00.md` | Adaptación del AGENTS.md |
| `Logs/03-NUEVAS_DIRECTIVAS_AGENTS_2026-08-15_22-58-00.md` | Nuevas directivas del AGENTS.md |

---

## 6. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-15
**Estado:** Base documental creada

### Lo que hice
- Definí la arquitectura de código planificada (carpetas, namespaces, archivos por sistema).
- Documenté el flujo de arranque, el formato de save y las convenciones.

### Lo que NO puedo hacer aún (honestidad)
- No hay código real todavía: este componente es la fundación documental del proyecto. Los 152 módulos individuales implementarán el código real en sus propias fases.

### Recomendaciones para el próximo agente
- Al elegir motor (Unity vs Godot), traducir esta estructura a la convención del motor elegido.
- El prototipo de preproducción (módulo 136 PROTOTIPO) debe probar el sistema voxel (cavar/colocar/guardar/cargar) antes de comprometer la arquitectura.