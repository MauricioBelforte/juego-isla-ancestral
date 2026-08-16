**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 07: Arquitectura General

## 1. Análisis de los 27 puntos del plan maestro (sección 6)

| # | Punto | Resolución |
|---|---|---|
| 1 | Arquitectura modular | ✅ Managers por dominio (§2 de 03-Diseno) |
| 2 | Separar sistemas independientes | ✅ Cada dominio con API pública propia |
| 3 | Minimizar dependencias circulares | ✅ Regla de capas A→B→C unidireccional |
| 4 | Managers necesarios | ✅ Lista cerrada de 18 servicios iniciales |
| 5 | Evitar GameManager monolítico | ✅ Bootstrap orquesta; servicios sin estado global |
| 6 | Sistema de eventos global | ✅ EventBus tipado (M05) |
| 7 | Sistema de configuración | ✅ Settings autoload |
| 8 | Sistema de datos | ✅ Resources (datos) separados de comportamiento |
| 9 | Persistencia | ✅ GameState versionado (M59) |
| 10 | Streaming | ✅ SceneManager + chunks (M63) |
| 11 | Escenas | ✅ SceneManager con carga diegética |
| 12 | Chunks | ✅ VoxelWorld/ChunkManager (M08) |
| 13 | Objetos interactivos | ✅ InteractableService (M70) |
| 14 | NPC | ✅ NPCScheduler + emotions (M64) |
| 15 | Misiones | ✅ QuestManager (M22/M71) |
| 16 | Inventario | ✅ InventoryService (M14) |
| 17 | Crafting | ✅ CraftingManager (M16) |
| 18 | Economía | ✅ EconomyService con doble wallet (M38) |
| 19 | Construcción | ✅ BuildManager (M17) |
| 20 | Agricultura | ✅ FarmingSystem (M33) |
| 21 | Pesca | ✅ FishingSystem (M34) |
| 22 | Minería | ✅ MiningSystem (M35) |
| 23 | Clima | ✅ WeatherSystem (M32) |
| 24 | Estaciones | ✅ SeasonSystem (M29/M32) |
| 25 | Tiempo | ✅ GameClock (M29-M31) |
| 26 | Viaje | ✅ TravelManager (M28) |
| 27 | Descubrimiento | ✅ DiscoveryService (M10/regiones) |

## 2. Decisiones de arquitectura

### 2.1 Patrón base: Service Locator liviano
- Autoloads de Godot = singleton services registrados en un `ServiceRegistry`.
- Los servicios NO se refieren entre sí por nombre; se consultan por interface/registro → testable e intercambiable.
- Regla: un servicio depende de la API de otro, nunca de su implementación.

### 2.2 Capas de dependencia (unidireccionales)

```
UI (presentación) ─────────────────────────┐
        │ (llama)                          │ (escucha eventos)
        ▼                                  ▼
SERVICIOS (Economy, Inventory, Quest…) ◄─ EventBus (conector)
        │ (operan sobre)
        ▼
SISTEMAS (voxel, física, IA, tiempo)
        │ (leen/escriben)
        ▼
DATOS (Resources, GameState, configs) ── Persistencia
```

- **Prohibido:** UI→Sistemas directo; Sistemas→Servicios de otro dominio; acceso directo a GameState fuera de servicios de datos.

### 2.3 Comunicación
- Síncrona liviana: llamadas directas entre servicios vecinos de confianza.
- Cruzada/desacoplada: eventos tipados por `EventBus` (dominio:world, domain:economy…).
- Pesada/lenta (guardados, generación de chunks): cola de trabajo en `ThreadPool` con `call_deferred` al hilo principal.

### 2.4 GameState como fuente de verdad
- Todo lo persistible se registra en GameState (versionado, migraciones M59).
- Los servicios mutan estado SOLO a través de su API pública (nunca campos sueltos).
- Autosave por eventos acotados (día completado, hito, viaje).

## 3. Análisis de alternativas

| Patrón | Veredicto | Motivo |
|---|---|---|
| ECS | Descartado por ahora | Complejidad innecesaria para coin sim; GDScript sin ECS maduro |
| ScriptableObjects puros (Unity) | N/A | Motor es Godot: Resources cumple el rol de datos |
| Singleton puro por clase | Descartado | Espagueti; Service Registry da trazabilidad |
| MVC/MVP por dominio | Adoptado parcial | UI = View; Services = Controller; GameState/Resources = Model |

## 4. Riesgos

| Riesgo | Mitigación |
|---|---|
| Bus de eventos lento | Eventos ligeros + medición en M61 |
| Servicios que se llaman sin constancia | Revisión cross en QA; script de verificación de capas |
| GameState gigante | Partición por dominios con versionado propio |
| Overload de Bootstrap | Solo registro + arranque; nada de lógica |