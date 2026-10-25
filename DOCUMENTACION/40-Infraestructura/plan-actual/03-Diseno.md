**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md â€” MÃ³dulo 40: Infraestructura

## 1. Arquitectura

### 1.1 Autoloads CORE con orden de carga (project.godot)

```
â”Œâ”€ CAPA CORE (M40) â€” se instancia siempre en este orden â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  1. EventBus         Â· bus de eventos por dominios tipados         â”‚
â”‚  2. Logger           Â· contrato de logging global (detalle M103)   â”‚
â”‚  3. GameState        Â· dato puro de partida (M07), sin servicios   â”‚
â”‚  4. ServiceRegistry  Â· Service Locator (M07): contratos â†’ servicio â”‚
â”‚  5. SceneManager     Â· orquestador de escenas raÃ­z (usa M63)       â”‚
â”‚  6. GameFlowManager  Â· mÃ¡quina de estados de flujo del juego       â”‚
â”‚  7. Bootstrap        Â· ÃšLTIMO: sanity, config, registro, arranque  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                                  â”‚ declara y verifica
â”Œâ”€ CAPA DE DOMINIOS (se auto-registran) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  M38: EconomyManager Â· PriceManager Â· ShopManager Â· BarterSystem   â”‚
â”‚  (otros dominios futuros siguen el mismo contrato de auto-registro)â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                                  â”‚ consume por contrato (obtener) y eventos
â”Œâ”€ CAPA DE PRESENTACIÃ“N (M53/M63) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  UIController (M53): solo ServiceRegistry + EventBus               â”‚
â”‚  SceneManager: carga boot â†’ menÃº â†’ mundo con progreso (M63)        â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

**Orden en `project.godot` (declaraciÃ³n prevista):**

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

Nota: la prioridad numÃ©rica (mayor = instancia antes) se usa por legibilidad; el requisito funcional es el ORDEN, que se valida en el test de arranque y se loguea en DOM-INF-BOOT (RF6).

### 1.2 Reglas de capas (heredadas de M07)

1. Un script de dominio X solo importa: core, data y dominios de nivel inferior; nunca UI ni dominios superiores.
2. `EventBus` no importa dominios: solo define el espacio de nombres de eventos.
3. `GameState` no importa servicios: es dato puro + serializaciÃ³n.
4. `Bootstrap` es el Ãºnico que conoce el catÃ¡logo COMPLETO de servicios esperados (verificaciÃ³n de integridad).

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

Contrato de registro: Ãºnica instancia por contrato (duplicado = error DOM-INF-REGISTRO); `obtener()` sobre contrato no registrado = null + warning DOM-INF-FALTANTE (nunca excepciÃ³n).

## 3. Diagramas de Flujo (texto)

### 3.1 Arranque del juego (boot)

```
Godot inicia
  â†’ project.godot instancia autoloads CORE en orden (1..7)
  â†’ EventBus._ready(): prepara tablas de dominios vacÃ­as
  â†’ Logger._ready(): prepara contrato de log
  â†’ GameState._ready(): (aÃºn sin partida)
  â†’ ServiceRegistry._ready(): mapa de contratos vacÃ­o
  â†’ SceneManager._ready(): registra escena inicial = boot.tscn
  â†’ GameFlowManager._ready(): estado = ESTADO_BOOT
  â†’ Bootstrap._ready():                                  [RF2]
      1. sanity check: EventBus, Logger, GameState, ServiceRegistry,
         SceneManager, GameFlowManager presentes y respondiendo
      2. carga config general (Settings M90) con fallback a defaults
      3. detecta partida guardada (M60) â†’ GameState.cargar() o nueva
      4. espera el auto-registro de dominios (M38) y llama
         ServiceRegistry.verificar_integridad([&"economia", ...])  [RF11]
      5. diagnostico.chequear_capas() (solo editor/CI) o log de advertencia
      6. GameFlowManager.cambiar_estado(ESTADO_MENU)               [D8]
      7. SceneManager.cambiar_escena("res://core/scenes/main_menu.tscn")
         con progreso (M63) y UI bloqueada (AGENTS.md Â§8)
      8. log DOM-INF-BOOT con el orden real de autoloads y contratos
  â†’ si cualquier paso falla â†’ ESTADO_ERROR (pantalla con motivo + reintentar)
```

### 3.2 MenÃº â†’ Mundo (nueva partida / continuar)

```
Jugador pulsa "Nueva partida" o "Continuar" (UI M53)
  â†’ UIController llama GameFlowManager.cambiar_estado(ESTADO_CARGANDO)
  â†’ Bootstrap (o GameFlow) valida GameState:
       nueva â†’ GameState.inicializar_nueva(seed M29)
       continuar â†’ GameState.cargar() (M60) â†’ migraciÃ³n por dominio (M07)
  â†’ SceneManager.cambiar_escena("res://core/scenes/world.tscn", modo=CARGANDO)
       â†’ delega la carga pesada a M63 (progreso visual, chunks por isla)
       â†’ UI deshabilitada hasta completado (AGENTS.md Â§8)
  â†’ seÃ±al carga_completada â†’ GameFlowManager.cambiar_estado(ESTADO_MUNDO)
  â†’ UIController (M53) enlaza HUD por ServiceRegistry.obtener() y EventBus
```

### 3.3 Error de arranque (fallback)

```
Bootstrap._ready() falla (config corrupta, contrato faltante, sanity KO)
  â†’ GameFlowManager.cambiar_estado(ESTADO_ERROR)
  â†’ log DOM-INF-ERROR con motivo accionable (nunca mensaje crÃ­ptico)
  â†’ SceneManager.cambiar_escena("res://core/scenes/error.tscn", modo=ERROR)
  â†’ pantalla de error: motivo (clave i18n M58) + botÃ³n "Reintentar"
  â†’ pulsar reintentar â†’ ESTADO_BOOT â†’ Bootstrap._ready() se re-ejecuta
  â†’ si persiste el error: se muestra de nuevo sin loop invisible (mÃ¡x. 3
    intentos automÃ¡ticos documentados en log, luego espera intervenciÃ³n)
```

## 4. Manejo de Estados de Juego (GameFlowManager)

```gdscript
enum Estado { BOOT, MENU, CARGANDO, MUNDO, PAUSA, TRANSICION, ERROR }

# Transiciones permitidas (D8): origen -> destinos vÃ¡lidos
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
- `cambiar_estado(estado)` con transiciÃ³n no permitida â†’ warning DOM-INF-ESTADO + rechazo (no cambia).
- `MUNDO` es el Ãºnico estado con gameplay activo; `PAUSA` no muta datos de mundo.
- `TRANSICION` es transitorio (islas, cuevas); siempre deriva a CARGANDO.
- `ERROR` es alcanzable desde cualquier estado y solo vuelve a `BOOT`.
- El GameFlowManager emite `estado_cambio(anterior, actual)` por EventBus (`infra.game_flow`).

## 5. Clases / Autoloads Previstos

### 5.1 `EventBus` (autoload, prioridad 10)
- Responsable: reenvÃ­o de eventos por dominio sin conocer dominios.
- Expone: `emitir(dominio: StringName, evento: StringName, payload: Variant = null)`, `suscribir(dominio, evento, callable) -> int` (id), `desuscribir(dominio, evento, callable)`, `limpiar_receptor(nodo)` (seguridad en liberaciones).
- SeÃ±ales internas: ninguna pÃºblica; todo sale por `emitir`.
- Debug: espÃ­a `pintar_dominio(dominio)` para el Debug Menu (M110).

### 5.2 `Logger` (autoload, prioridad 20)
- Responsable: contrato de logging con tags (DOM-INF-*).
- Expone: `info/aviso/error(tag, mensaje)`; la implementaciÃ³n profunda con rotaciÃ³n es de M103.

### 5.3 `GameState` (autoload, prioridad 30)
- Responsable: dato puro de partida particionado (M07): meta, world, player, economy, calendar, discovery, story.
- Expone: `inicializar_nueva(seed: int)`, `cargar(snapshot: Dictionary)`, `acceder(dominio: StringName) -> Node/Resource`, `snapshot() -> Dictionary` (delegaciÃ³n a M60/M62).
- Regla: no importa servicios; no emite eventos de juego.

### 5.4 `ServiceRegistry` (autoload, prioridad 40)
- Responsable: Service Locator por contratos.
- Expone: `registrar(contrato: StringName, servicio: Node) -> bool`, `obtener(contrato: StringName) -> Node`, `esta_registrado(contrato) -> bool`, `listar_contratos() -> Array[StringName]`, `verificar_integridad(esperados: Array[StringName]) -> Array[String]`.
- PolÃ­tica: registro duplicado â†’ false + warning; `obtener()` no registrado â†’ null + warning DOM-INF-FALTANTE.

### 5.5 `SceneManager` (autoload, prioridad 50)
- Responsable: transiciones de escena raÃ­z con progreso y bloqueo de UI.
- Expone: `cambiar_escena(ruta: String, modo: GameFlowManager.Estado = TRANSICION)`, `escena_actual() -> String`, seÃ±al `carga_completada(ruta)`.
- Delega el progreso al contrato de M63; sin lÃ³gica de streaming propia.

### 5.6 `GameFlowManager` (autoload, prioridad 60)
- Responsable: mÃ¡quina de estados de flujo (secciÃ³n 4).
- Expone: `estado_actual() -> Estado`, `cambiar_estado(estado: Estado) -> bool`, `transiciones_permitidas()`.

### 5.7 `Bootstrap` (autoload, prioridad 1 â€” ÃšLTIMO en instanciarse)
- Responsable: orquestaciÃ³n completa del arranque (flujo 3.1) y del error (flujo 3.3).

### 5.8 `Diagnostico` (helper `RefCounted`, no autoload)
- Responsable: scan estÃ¡tico del grafo de imports (editor/CI) y utilidades de sanity de runtime.
- Expone: `chequear_ciclos(ruta_raiz) -> Array[String]`, `chequear_capas(ruta_raiz) -> Array[String]` (reglas de M07), `verificar_escena_previa(escena, servicios) -> Array[String]` (RF12).

### 5.9 Escenas raÃ­z (`res://core/scenes/`)
- `boot.tscn`: sanity visual mÃ­nima + log de arranque (sÃ³lo infraestructura).
- `main_menu.tscn`: propiedad de M53 (aquÃ­ solo el punto de integraciÃ³n).
- `world.tscn`: propiedad de M08/M63 (punto de integraciÃ³n).
- `error.tscn`: pantalla de error de arranque (motivo + reintentar), del CORE.

## 6. IntegraciÃ³n con MÃ³dulos 38, 53, 63 y 07

### 6.1 M38 (EconomÃ­a)
- Sus 4 autoloads se declaran en `project.godot` DESPUÃ‰S del CORE (sin prioridad competitiva).
- Cada uno se auto-registra en su `_ready()`: `ServiceRegistry.registrar(&"economia", self)` etc. (D4).
- El Bootstrap espera la verificaciÃ³n de integridad: `verificar_integridad([&"economia", &"economia.precios", &"economia.tiendas", &"economia.trueque"])`.
- ExcepciÃ³n de orden: si `EconomyManager` se registrara antes que `ServiceRegistry`, la UI jamÃ¡s lo nota: `obtener()` es por contrato (D3).

### 6.2 M53 (UI-UX)
- `UIController` obtiene servicios con `ServiceRegistry.obtener(...)` en su `_ready()` **aplazado** (primer frame) para garantizar el orden (RF12).
- Toda comunicaciÃ³n de gameplay â†’ UI viaja por `EventBus` (dominios `economy`, `inventory`, `world`, `infra`).
- El menÃº principal se carga como escena raÃ­z; el HUD se monta dentro de `world.tscn`.
- NingÃºn autoload CORE referencia nodos de M53 (verificado por `chequear_capas`).

### 6.3 M63 (Cargas y Streaming)
- `SceneManager` consume el contrato de M63: progreso, cancelaciÃ³n segura, streaming por isla.
- Las transiciones boot â†’ menÃº â†’ mundo muestran barra/progreso visual y deshabilitan la UI interactiva (AGENTS.md Â§8).
- `world.tscn` se carga con el modo CARGANDO; los chunks se siguen cargando con M63 dentro de ESTADO_MUNDO.

### 6.4 M07 (Arquitectura General)
- Este mÃ³dulo materializa su diseÃ±o: ServiceRegistry (M07 Â§2), EventBus (M07 Â§5), GameState (M07 Â§4) y las reglas anti-circulares (M07 Â§7) pasan a ser autoloads verificables.
- El detalle profundo de GameState (versiones, migraciones, particiÃ³n fina) queda en M59/M60 como indica el plan maestro; aquÃ­ se fija el contrato infraestructural.

## 7. Contrato de SeÃ±ales / Eventos (resumen)

| Evento (dominio.nombre) | Emisor | Consumidores |
|---|---|---|
| `infra.game_flow` (cambio de estado) | GameFlowManager | UI pantallas (M53), menÃº de pausa, Boot |
| `infra.boot.completado` | Bootstrap | UIController (enlaza HUD) |
| `infra.boot.error(motivo)` | Bootstrap | Escena error (CORE) |
| `infra.carga.iniciada` / `infra.carga.completada` | SceneManager | UI progreso (M53/M63) |
| `economy.*` (M38) | M38 | UI HUD/tiendas (M53), log (M103) |
| `world.*` / `npc.*` / `calendar.*` (M07) | dominios | segun plan maestro (M07 Â§5) |

## 8. DiagnÃ³stico Automatizado (D9)

- **EstÃ¡tico (editor + CI, M118):** `Diagnostico.chequear_ciclos("res://")` y `chequear_capas("res://")`; salida legible con archivo:lÃ­nea; gate de CI.
- **Runtime (Bootstrap):** sanity check de autoloads (RF11), verificaciÃ³n de integridad de contratos, detecciÃ³n de accesos tempranos (RF12) y log DOM-INF-BOOT con orden real.
- **QA cruzado (AGENTS.md Â§21.8):** el diagnÃ³stico es la evidencia objetiva de que las capas se respetan; se usa en la revisiÃ³n de mÃ³dulos.

## 9. OptimizaciÃ³n

- `ServiceRegistry.obtener()` es lectura de `Dictionary` (O(1)); sin instanciaciÃ³n.
- `EventBus.emitir()` reenvÃ­a el `Callable` directo; cero alocaciones de nodos; los payloads grandes se evitan por convenciÃ³n (se pasan referencias livianas).
- Todo el CORE es inactivo durante el gameplay salvo los eventos que lo tocan; no hay `_process` en ningÃºn autoload CORE (cero coste por frame).
- `GameFlowManager` y `SceneManager` son mÃ¡quinas de estado puras: sin temporizadores ni pooling.
- Los arrays de suscriptores del bus se podan al liberar nodos (`limpiar_receptor`) para evitar fugas de Callables.
- Presupuesto de memoria: mapas de contratos y dominios acotados (decenas de entradas), cargados una Ãºnica vez en el arranque.
## Specs Infraestructura (Beam 506)

### Carga de mundo interrumpida por error → ESTADO_ERROR
- Spec: carga de mundo interrumpida por error: vuelve a ESTADO_ERROR sin estado fantasma. Coherente con M40 (infraestructura) y M07 (guardado).