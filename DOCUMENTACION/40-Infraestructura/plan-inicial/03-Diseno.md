**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 40: Infraestructura

## 1. Arquitectura

### 1.1 Autoloads CORE con orden de carga (project.godot)

```
┌─ CAPA CORE (M40) — se instancia siempre en este orden ─────────────┐
│  1. EventBus         · bus de eventos por dominios tipados         │
│  2. Logger           · contrato de logging global (detalle M103)   │
│  3. GameState        · dato puro de partida (M07), sin servicios   │
│  4. ServiceRegistry  · Service Locator (M07): contratos → servicio │
│  5. SceneManager     · orquestador de escenas raíz (usa M63)       │
│  6. GameFlowManager  · máquina de estados de flujo del juego       │
│  7. Bootstrap        · ÚLTIMO: sanity, config, registro, arranque  │
└──────────────────────────────────┬─────────────────────────────────┘
                                  │ declara y verifica
┌─ CAPA DE DOMINIOS (se auto-registran) ─────────────────────────────┐
│  M38: EconomyManager · PriceManager · ShopManager · BarterSystem   │
│  (otros dominios futuros siguen el mismo contrato de auto-registro)│
└──────────────────────────────────┬─────────────────────────────────┘
                                  │ consume por contrato (obtener) y eventos
┌─ CAPA DE PRESENTACIÓN (M53/M63) ───────────────────────────────────┐
│  UIController (M53): solo ServiceRegistry + EventBus               │
│  SceneManager: carga boot → menú → mundo con progreso (M63)        │
└────────────────────────────────────────────────────────────────────┘
```

**Orden en `project.godot` (declaración prevista):**

```ini
[autoload]
EventBus="10*res://core/event_bus.gd"
Logger="20*res://core/logger.gd"
GameState="30*res://core/game_state.gd"
ServiceRegistry="40*res://core/service_registry.gd"
SceneManager="50*res://core/scene_manager.gd"
GameFlowManager="60*res://core/game_flow_manager.gd"
Bootstrap="1*res://core/bootstrap.gd"
```

Nota: la prioridad numérica (mayor = instancia antes) se usa por legibilidad; el requisito funcional es el ORDEN, que se valida en el test de arranque y se loguea en DOM-INF-BOOT (RF6).

### 1.2 Reglas de capas (heredadas de M07)

1. Un script de dominio X solo importa: core, data y dominios de nivel inferior; nunca UI ni dominios superiores.
2. `EventBus` no importa dominios: solo define el espacio de nombres de eventos.
3. `GameState` no importa servicios: es dato puro + serialización.
4. `Bootstrap` es el único que conoce el catálogo COMPLETO de servicios esperados (verificación de integridad).

## 2. Mapa de Servicios (ServiceRegistry)

| Contrato (`StringName`) | Servicio | Proveedor | Observaciones |
|---|---|---|---|
| `&"core.event_bus"` | EventBus | autoload | registrado por el propio autoload |
| `&"core.logger"` | Logger | autoload | contrato; detalle M103 |
| `&"core.game_state"` | GameState | autoload | dato puro |
| `&"core.scene_manager"` | SceneManager | autoload | carga con progreso (M63) |
| `&"core.game_flow"` | GameFlowManager | autoload | estados de flujo |
| `&"economia"` | EconomyManager | M38 | auto-registro |
| `&"economia.precios"` | PriceManager | M38 | auto-registro |
| `&"economia.tiendas"` | ShopManager | M38 | auto-registro |
| `&"economia.trueque"` | BarterSystem | M38 | auto-registro |
| `&"mundo_voxel"` | VoxelWorld (M08) | futuro | se registra al implementarse |
| `&"ui"` | UIController (M53) | futuro | solo consume, no registra dominio de juego |

Contrato de registro: única instancia por contrato (duplicado = error DOM-INF-REGISTRO); `obtener()` sobre contrato no registrado = null + warning DOM-INF-FALTANTE (nunca excepción).

## 3. Diagramas de Flujo (texto)

### 3.1 Arranque del juego (boot)

```
Godot inicia
  → project.godot instancia autoloads CORE en orden (1..7)
  → EventBus._ready(): prepara tablas de dominios vacías
  → Logger._ready(): prepara contrato de log
  → GameState._ready(): (aún sin partida)
  → ServiceRegistry._ready(): mapa de contratos vacío
  → SceneManager._ready(): registra escena inicial = boot.tscn
  → GameFlowManager._ready(): estado = ESTADO_BOOT
  → Bootstrap._ready():                                  [RF2]
      1. sanity check: EventBus, Logger, GameState, ServiceRegistry,
         SceneManager, GameFlowManager presentes y respondiendo
      2. carga config general (Settings M90) con fallback a defaults
      3. detecta partida guardada (M60) → GameState.cargar() o nueva
      4. espera el auto-registro de dominios (M38) y llama
         ServiceRegistry.verificar_integridad([&"economia", ...])  [RF11]
      5. diagnostico.chequear_capas() (solo editor/CI) o log de advertencia
      6. GameFlowManager.cambiar_estado(ESTADO_MENU)               [D8]
      7. SceneManager.cambiar_escena("res://core/scenes/main_menu.tscn")
         con progreso (M63) y UI bloqueada (AGENTS.md §8)
      8. log DOM-INF-BOOT con el orden real de autoloads y contratos
  → si cualquier paso falla → ESTADO_ERROR (pantalla con motivo + reintentar)
```

### 3.2 Menú → Mundo (nueva partida / continuar)

```
Jugador pulsa "Nueva partida" o "Continuar" (UI M53)
  → UIController llama GameFlowManager.cambiar_estado(ESTADO_CARGANDO)
  → Bootstrap (o GameFlow) valida GameState:
       nueva → GameState.inicializar_nueva(seed M29)
       continuar → GameState.cargar() (M60) → migración por dominio (M07)
  → SceneManager.cambiar_escena("res://core/scenes/world.tscn", modo=CARGANDO)
       → delega la carga pesada a M63 (progreso visual, chunks por isla)
       → UI deshabilitada hasta completado (AGENTS.md §8)
  → señal carga_completada → GameFlowManager.cambiar_estado(ESTADO_MUNDO)
  → UIController (M53) enlaza HUD por ServiceRegistry.obtener() y EventBus
```

### 3.3 Error de arranque (fallback)

```
Bootstrap._ready() falla (config corrupta, contrato faltante, sanity KO)
  → GameFlowManager.cambiar_estado(ESTADO_ERROR)
  → log DOM-INF-ERROR con motivo accionable (nunca mensaje críptico)
  → SceneManager.cambiar_escena("res://core/scenes/error.tscn", modo=ERROR)
  → pantalla de error: motivo (clave i18n M58) + botón "Reintentar"
  → pulsar reintentar → ESTADO_BOOT → Bootstrap._ready() se re-ejecuta
  → si persiste el error: se muestra de nuevo sin loop invisible (máx. 3
    intentos automáticos documentados en log, luego espera intervención)
```

## 4. Manejo de Estados de Juego (GameFlowManager)

```gdscript
enum Estado { BOOT, MENU, CARGANDO, MUNDO, PAUSA, TRANSICION, ERROR }

# Transiciones permitidas (D8): origen -> destinos válidos
const TRANSICIONES: Dictionary = {
    Estado.BOOT:        [Estado.MENU, Estado.ERROR],
    Estado.MENU:        [Estado.CARGANDO, Estado.ERROR],
    Estado.CARGANDO:    [Estado.MUNDO, Estado.ERROR],
    Estado.MUNDO:       [Estado.PAUSA, Estado.TRANSICION, Estado.ERROR],
    Estado.PAUSA:       [Estado.MUNDO, Estado.ERROR],
    Estado.TRANSICION:  [Estado.CARGANDO, Estado.ERROR],
    Estado.ERROR:       [Estado.BOOT],
}
```

Reglas:
- `cambiar_estado(estado)` con transición no permitida → warning DOM-INF-ESTADO + rechazo (no cambia).
- `MUNDO` es el único estado con gameplay activo; `PAUSA` no muta datos de mundo.
- `TRANSICION` es transitorio (islas, cuevas); siempre deriva a CARGANDO.
- `ERROR` es alcanzable desde cualquier estado y solo vuelve a `BOOT`.
- El GameFlowManager emite `estado_cambio(anterior, actual)` por EventBus (`infra.game_flow`).

## 5. Clases / Autoloads Previstos

### 5.1 `EventBus` (autoload, prioridad 10)
- Responsable: reenvío de eventos por dominio sin conocer dominios.
- Expone: `emitir(dominio: StringName, evento: StringName, payload: Variant = null)`, `suscribir(dominio, evento, callable) -> int` (id), `desuscribir(dominio, evento, callable)`, `limpiar_receptor(nodo)` (seguridad en liberaciones).
- Señales internas: ninguna pública; todo sale por `emitir`.
- Debug: espía `pintar_dominio(dominio)` para el Debug Menu (M110).

### 5.2 `Logger` (autoload, prioridad 20)
- Responsable: contrato de logging con tags (DOM-INF-*).
- Expone: `info/aviso/error(tag, mensaje)`; la implementación profunda con rotación es de M103.

### 5.3 `GameState` (autoload, prioridad 30)
- Responsable: dato puro de partida particionado (M07): meta, world, player, economy, calendar, discovery, story.
- Expone: `inicializar_nueva(seed: int)`, `cargar(snapshot: Dictionary)`, `acceder(dominio: StringName) -> Node/Resource`, `snapshot() -> Dictionary` (delegación a M60/M62).
- Regla: no importa servicios; no emite eventos de juego.

### 5.4 `ServiceRegistry` (autoload, prioridad 40)
- Responsable: Service Locator por contratos.
- Expone: `registrar(contrato: StringName, servicio: Node) -> bool`, `obtener(contrato: StringName) -> Node`, `esta_registrado(contrato) -> bool`, `listar_contratos() -> Array[StringName]`, `verificar_integridad(esperados: Array[StringName]) -> Array[String]`.
- Política: registro duplicado → false + warning; `obtener()` no registrado → null + warning DOM-INF-FALTANTE.

### 5.5 `SceneManager` (autoload, prioridad 50)
- Responsable: transiciones de escena raíz con progreso y bloqueo de UI.
- Expone: `cambiar_escena(ruta: String, modo: GameFlowManager.Estado = TRANSICION)`, `escena_actual() -> String`, señal `carga_completada(ruta)`.
- Delega el progreso al contrato de M63; sin lógica de streaming propia.

### 5.6 `GameFlowManager` (autoload, prioridad 60)
- Responsable: máquina de estados de flujo (sección 4).
- Expone: `estado_actual() -> Estado`, `cambiar_estado(estado: Estado) -> bool`, `transiciones_permitidas()`.

### 5.7 `Bootstrap` (autoload, prioridad 1 — ÚLTIMO en instanciarse)
- Responsable: orquestación completa del arranque (flujo 3.1) y del error (flujo 3.3).

### 5.8 `Diagnostico` (helper `RefCounted`, no autoload)
- Responsable: scan estático del grafo de imports (editor/CI) y utilidades de sanity de runtime.
- Expone: `chequear_ciclos(ruta_raiz) -> Array[String]`, `chequear_capas(ruta_raiz) -> Array[String]` (reglas de M07), `verificar_escena_previa(escena, servicios) -> Array[String]` (RF12).

### 5.9 Escenas raíz (`res://core/scenes/`)
- `boot.tscn`: sanity visual mínima + log de arranque (sólo infraestructura).
- `main_menu.tscn`: propiedad de M53 (aquí solo el punto de integración).
- `world.tscn`: propiedad de M08/M63 (punto de integración).
- `error.tscn`: pantalla de error de arranque (motivo + reintentar), del CORE.

## 6. Integración con Módulos 38, 53, 63 y 07

### 6.1 M38 (Economía)
- Sus 4 autoloads se declaran en `project.godot` DESPUÉS del CORE (sin prioridad competitiva).
- Cada uno se auto-registra en su `_ready()`: `ServiceRegistry.registrar(&"economia", self)` etc. (D4).
- El Bootstrap espera la verificación de integridad: `verificar_integridad([&"economia", &"economia.precios", &"economia.tiendas", &"economia.trueque"])`.
- Excepción de orden: si `EconomyManager` se registrara antes que `ServiceRegistry`, la UI jamás lo nota: `obtener()` es por contrato (D3).

### 6.2 M53 (UI-UX)
- `UIController` obtiene servicios con `ServiceRegistry.obtener(...)` en su `_ready()` **aplazado** (primer frame) para garantizar el orden (RF12).
- Toda comunicación de gameplay → UI viaja por `EventBus` (dominios `economy`, `inventory`, `world`, `infra`).
- El menú principal se carga como escena raíz; el HUD se monta dentro de `world.tscn`.
- Ningún autoload CORE referencia nodos de M53 (verificado por `chequear_capas`).

### 6.3 M63 (Cargas y Streaming)
- `SceneManager` consume el contrato de M63: progreso, cancelación segura, streaming por isla.
- Las transiciones boot → menú → mundo muestran barra/progreso visual y deshabilitan la UI interactiva (AGENTS.md §8).
- `world.tscn` se carga con el modo CARGANDO; los chunks se siguen cargando con M63 dentro de ESTADO_MUNDO.

### 6.4 M07 (Arquitectura General)
- Este módulo materializa su diseño: ServiceRegistry (M07 §2), EventBus (M07 §5), GameState (M07 §4) y las reglas anti-circulares (M07 §7) pasan a ser autoloads verificables.
- El detalle profundo de GameState (versiones, migraciones, partición fina) queda en M59/M60 como indica el plan maestro; aquí se fija el contrato infraestructural.

## 7. Contrato de Señales / Eventos (resumen)

| Evento (dominio.nombre) | Emisor | Consumidores |
|---|---|---|
| `infra.game_flow` (cambio de estado) | GameFlowManager | UI pantallas (M53), menú de pausa, Boot |
| `infra.boot.completado` | Bootstrap | UIController (enlaza HUD) |
| `infra.boot.error(motivo)` | Bootstrap | Escena error (CORE) |
| `infra.carga.iniciada` / `infra.carga.completada` | SceneManager | UI progreso (M53/M63) |
| `economy.*` (M38) | M38 | UI HUD/tiendas (M53), log (M103) |
| `world.*` / `npc.*` / `calendar.*` (M07) | dominios | segun plan maestro (M07 §5) |

## 8. Diagnóstico Automatizado (D9)

- **Estático (editor + CI, M118):** `Diagnostico.chequear_ciclos("res://")` y `chequear_capas("res://")`; salida legible con archivo:línea; gate de CI.
- **Runtime (Bootstrap):** sanity check de autoloads (RF11), verificación de integridad de contratos, detección de accesos tempranos (RF12) y log DOM-INF-BOOT con orden real.
- **QA cruzado (AGENTS.md §21.8):** el diagnóstico es la evidencia objetiva de que las capas se respetan; se usa en la revisión de módulos.

## 9. Optimización

- `ServiceRegistry.obtener()` es lectura de `Dictionary` (O(1)); sin instanciación.
- `EventBus.emitir()` reenvía el `Callable` directo; cero alocaciones de nodos; los payloads grandes se evitan por convención (se pasan referencias livianas).
- Todo el CORE es inactivo durante el gameplay salvo los eventos que lo tocan; no hay `_process` en ningún autoload CORE (cero coste por frame).
- `GameFlowManager` y `SceneManager` son máquinas de estado puras: sin temporizadores ni pooling.
- Los arrays de suscriptores del bus se podan al liberar nodos (`limpiar_receptor`) para evitar fugas de Callables.
- Presupuesto de memoria: mapas de contratos y dominios acotados (decenas de entradas), cargados una única vez en el arranque.