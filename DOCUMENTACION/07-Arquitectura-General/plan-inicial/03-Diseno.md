**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 07: Arquitectura General

## 1. Diagrama de managers (servicios iniciales)

```
┌─ CORE ─────────────────────────────────────────────────┐
│ Bootstrap (registro+arranque) · EventBus · Logger ·    │
│ ErrorHandler · Settings · ThreadPool                   │
└───────────────────────────┬────────────────────────────┘
                            │ dependen de CORE
┌─ DOMINIOS ────────────────▼────────────────────────────┐
│ GAMEPLAY:  GameState · QuestManager · EconomyService · │
│            InventoryService · CraftingManager ·        │
│            BuildManager · FarmingSystem · FishingSystem│
│            MiningSystem · ToolManager · DialogueEngine │
│            FriendshipService · TravelManager ·         │
│            DiscoveryService                            │
│ WORLD:     VoxelWorld · ChunkManager · BiomeManager ·  │
│            GenerationManager · WeatherSystem ·         │
│            SeasonSystem · GameClock                    │
│ AI:        NPCScheduler · NPCEmotionService            │
│ UI:        UIController (SPI hacia servicios)          │
└────────────────────────────────────────────────────────┘
```

## 2. Contrato de integración de un módulo nuevo

1. Crear el servicio en `scripts/{dominio}/` siguiendo M05.
2. Registrar la interfaz en `ServiceRegistry` (Bootstrap).
3. Suscribirse/emitir por `EventBus` con dominio tipado.
4. Exponer API pública; nada de campos públicos mutables.
5. Data en `Resources` (`.tres`) y persistencia SOLO vía GameState.
6. Test unitario mínimo del contrato (M-QA).

## 3. Gestión del ciclo de vida

- **Bootstrap** (autoload 0): registra servicios, carga config, inicia GameState (load/migración), arranca escena Main.
- **Escena cambio (islas):** SceneManager → pide World a VoxelWorld → descarga chunk por chunk (progreso visual, AGENTS §8) → carga diégetica (Gran Vapor) → resume GameClock.
- **Cierre:** autosave (GameState), flush de cola, logs.

## 4. GameState (diseño de alto nivel — detalle en M59)

```
GameState
├── meta (version, seed, fecha guardado)
├── world (diffs chunks por isla)
├── player (position, inventory, tools, skills)
├── economy (gems, merit_passes, debt/finneas)
├── relationships (friendship points por NPC)
├── story (sellos, flags de mundo, misiones activas)
├── calendar (fecha, estación, eventos)
├── discovery (islas visitadas/desbloqueadas, regiones)
└── settings-derivados (no: settings son del usuario, aparte)
```

Partición por dominios → cada uno tiene su propio versionado/migración.

## 5. EventBus: dominios y señales principales (borrador)

| Dominio | Señales base |
|---|---|
| `world` | chunk_modified, block_placed, block_removed, biome_changed |
| `economy` | currency_changed, purchase_done, debt_paid |
| `inventory` | item_added, item_removed, hotbar_selected |
| `quest` | quest_started, quest_updated, prereq_met(seal) |
| `npc` | npc_moved_in, friendship_level_up, gift_given |
| `calendar` | day_started, season_changed, vessel_arrived |
| `travel` | travel_started, island_loaded |
| `ui` | hud_request, dialog_requested (UI se suscribe; gameplay NO depende de UI) |

## 6. Streaming y escenas (alto nivel)

- **Por isla:** escena separada + carga con progreso (AGENTS §8 UX).
- **Dentro de la isla:** chunks 16³ cargados alrededor del jugador (radio 3-4), descarga fuera de radio; mods al disco por diffs.
- **Sin carga:** transiciones dentro de la isla (cuevas/templos) con fade + streaming de chunks.

## 7. Reglas anti-circulares (verificables)

1. `script` de dominio X solo importa: core, data, y dominios de nivel inferior (nunca UI ni dominios superiores).
2. `EventBus` no importa dominios (solo define tipos de eventos).
3. `GameState` no importa servicios (es dato puro + serialización).
4. La verificación de capas se automatiza con un script en M1 (estático por imports).