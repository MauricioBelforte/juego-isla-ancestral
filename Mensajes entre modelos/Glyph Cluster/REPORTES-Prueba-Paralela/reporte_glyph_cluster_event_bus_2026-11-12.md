# Reporte de análisis: `EventBus` y `ServiceRegistry`

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code (Agent Manager)  
**Fecha:** 2026-11-12  
**Alcance:** `game/isla-ancestral/scripts/core/event_bus.gd`, `game/isla-ancestral/scripts/core/service_registry.gd` (+ referencias cruzadas en `game/isla-ancestral/scripts` y `game/isla-ancestral/tests`)

---

## 1) Acoplamiento fuerte que debería ser más suelto

### 1.1 Contratos de eventos duplicados / divergentes (bus global vs señales locales)

El patrón base de `EventBus` es correcto para desacoplar dominios (documentado en `event_bus.gd:5-12`, sin imports de dominio), pero hay casos donde el contrato efectivo queda partido entre el bus y señales locales con el mismo nombre o propósito:

| Caso | Evidencia | Impacto |
|---|---|---|
| `travel_started` declarado en el bus pero no usado como contrato global | Declaración: `event_bus.gd:117-118` (`TravelEvents.travel_started(from_island, to_island)`). Emisión real encontrada: `scripts/viajes/travel_service.gd:23` (señal propia) y `scripts/viajes/travel_service.gd:270` (`travel_started.emit(_ruta_actual.route_id)`). Consumo real encontrado: `scripts/viajes/travel_layer.gd:29` (`ts.travel_started.connect(...)`, sobre `TravelService`). No se hallaron `.emit/.connect` sobre `EventBus.travel.travel_started`. | Acoplamiento directo `TravelLayer`/consumidores ↔ `TravelService` (instancia concreta) en lugar de contrato por bus; además la firma difiere (1 arg vs 2 args en el bus), lo que dificulta migrar a un flujo realmente desacoplado. |
| `ui_layers_changed` / `ui_focus_moved` definidos en el bus pero la UI usa sus propias señales | Declaración en bus: `event_bus.gd:148-150`. `UIManager` define sus propias señales homónimas: `scripts/ui/core/ui_manager.gd:22,24`, las emite/conecta internamente (`ui_manager.gd:64,66,247,276,358,368,457,643`) y solo conecta `EventBus.ui.hud_request` hacia adentro (`ui_manager.gd:51-52,476`). No se hallaron emisiones hacia `EventBus.ui.ui_layers_changed`/`EventBus.ui.ui_focus_moved`. | Dos fuentes de verdad para el mismo concepto de UI; otros sistemas que escuchen el bus no recibirán estos eventos, mientras los que escuchen `UIManager` quedan acoplados al nodo concreto. |
| `island_loaded` existe en bus pero sin emisor de dominio claro | Declaración: `event_bus.gd:119-120`. Consumos: `scripts/audio/narrative_sound.gd:55`, `scripts/diario/diary_service.gd:114`, `scripts/telemetry/*`, tests (`scripts/diario/test_diario.gd:98`, etc.). Comentario explícito: `scripts/audio/narrative_sound.gd:57` indica que `EventBus.travel.island_loaded` existe pero ningún dominio lo emite (y el código cae a una señal real de `M63`). | Consumidores acoplados a un evento que puede no dispararse en runtime real, obligando a fallbacks/adaptadores y generando comportamiento dependiente del contexto. |

**Conclusión (1):** El bus reduce acoplamiento en la mayoría de dominios, pero hay **contratos huérfanos o paralelos** (viajes/UI/carga de isla) que reintroducen acoplamiento fuerte o ambigüedad de integración. Esto es un problema de diseño de contrato más que de implementación del bus en sí.

---

## 2) Señales declaradas que nunca se emiten o nunca se conectan

> Nota metodológica: análisis estático por búsqueda de `.emit(` / `.connect(` en `game/isla-ancestral` (scripts y tests). Puede haber emisiones/conexiones dinámicas no detectables por patrón literal (el propio código lo advierte, p.ej. `scripts/core/probe_runtime_bus_m14.gd:7`); los hallazgos abajo son evidencia estática.

### 2.1 Señales sin emisión detectada en el árbol analizado

| Dominio / señal | Declaración | Emisiones detectadas | Conexiones detectadas | Observación |
|---|---:|---:|---:|---|
| `economy.currency_changed` | `event_bus.gd:60` | 0 | 2 (`ui/hud/hud_screen.gd:134`, `saving/save_manager.gd:95`) | Consumidores existen (HUD/save dirty) pero no se ve productor. Riesgo de UI/guardado desactualizado si nadie emite. |
| `economy.purchase_done` | `event_bus.gd:62` | 0 | 0 | Contrato sin uso observado. |
| `economy.debt_paid` | `event_bus.gd:64` | 0 | 0 | Contrato sin uso observado. |
| `world.chunk_modified` | `event_bus.gd:54` | 0 | 0 | Sin uso observado. |
| `world.biome_changed` | `event_bus.gd:56` | 1 (spy/test infra: `core/qa_m40_spy.gd:51`) | 0 | Solo emisión de prueba/QA, sin consumidor. |
| `calendar.vessel_arrived` | `event_bus.gd:104` | 0 | 0 | Sin uso observado. |
| `travel.travel_started` (EventBus) | `event_bus.gd:118` | 0 | 0 | El flujo real usa `TravelService.travel_started` (ver §1.1). |
| `ui.hud_request` | `event_bus.gd:136` | 0 | 1 (`ui/core/ui_manager.gd:52`) | `UIManager` escucha, pero no se halló emisor del bus. |
| `ui.layer_requested` | `event_bus.gd:142` | 0 | 0 | Sin uso observado. |
| `ui.confirm_requested` | `event_bus.gd:144` | 0 | 0 | Sin uso observado. |
| `ui.ui_layers_changed` (EventBus) | `event_bus.gd:148` | 0 (en bus) | 0 (en bus) | `UIManager` emite/conecta sus propias señales homónimas (`ui_manager.gd:22,247,276,...`). |
| `ui.ui_focus_moved` (EventBus) | `event_bus.gd:150` | 0 (en bus) | 0 (en bus) | Ídem anterior (`ui_manager.gd:24,358,368,457,643,...`). |
| `player.player_died` | `event_bus.gd:154` | 0 | 0 | Sin uso observado. |
| `player.level_up` (EventBus.player) | `event_bus.gd:156` | 0 | 0 | Sin uso observado (existen otros `level_up` locales en otros dominios, no este). |
| `player.damage_taken` | `event_bus.gd:158` | 0 | 0 | Sin uso observado. |
| `progresion.nivel_casa_cambio` | `event_bus.gd:178` | 0 | 0 | Sin uso observado. |
| `progresion.nivel_amistad_cambio` | `event_bus.gd:180` | 0 | 0 | Sin uso observado. |

### 2.2 Señales con emisión/conexión asimétrica relevante (riesgo de contrato incompleto)

| Señal | Evidencia | Lectura |
|---|---|---|
| `travel.island_loaded` | Declarada `event_bus.gd:120`; conectada en `scripts/audio/narrative_sound.gd:55`, `scripts/diario/diary_service.gd:114`; emisiones vistas en tests/QA (`scripts/diario/test_diario.gd:98`) y comentario `scripts/audio/narrative_sound.gd:57` ("ningún dominio lo emite"). | Contrato consumido en runtime, pero productor de dominio real no confirmado por análisis estático. |
| `infra.boot_completado` | Declarada `event_bus.gd:171`; emitida por `scripts/core/bootstrap.gd:132`; sin `.connect` detectado. | Evento publicado pero sin suscriptores actuales (puede ser intencional para futuro). |
| `infra.carga_completada` / `infra.game_flow_changed` | Emitidas (`scripts/ui/layers/loading_layer.gd:46`, `scripts/core/game_flow_manager.gd:73`, tests) y conectadas en tests/guard (`scripts/core/test_infraestructura_m40.gd`, `scripts/core/softlock_guard.gd:73`). | Uso concentrado en infraestructura/tests; pocos consumidores de gameplay (coherente con M40, pero conviene vigilar adopción). |

**Conclusión (2):** Hay un conjunto no trivial de señales del bus **sin emisor real**, **sin consumidor**, o con **uso solo en pruebas/spies**. Esto aumenta el coste de mantenimiento y puede ocultar integraciones rotas (especialmente `currency_changed`, `travel_started` del bus y `island_loaded`).

---

## 3) Dependencias circulares entre servicios

### 3.1 Hallazgos

- **`event_bus.gd`** (`game/isla-ancestral/scripts/core/event_bus.gd:1-199`): `extends Node`, `class_name EventBus_`, define únicamente clases internas de eventos y señales; **no referencia `ServiceRegistry` ni dominios concretos**.
- **`service_registry.gd`** (`game/isla-ancestral/scripts/core/service_registry.gd:1-75`): `extends Node`, almacena `Object` por contrato en `Dictionary`; **no referencia `EventBus` ni otros servicios concretos** (solo `push_warning/print`).
- **`bootstrap.gd`** orquesta el registro (`scripts/core/bootstrap.gd:78-82,136-154,217-223`) obteniendo nodos por `/root/...` y registrándolos; la dependencia es **unidireccional** (bootstrap → autoloads), no circular entre `EventBus` y `ServiceRegistry`.

### 3.2 Evaluación

No se identificaron **dependencias circulares directas ni indirectas** entre `EventBus` y `ServiceRegistry`. La relación observada es de composición/registro externo vía bootstrap, que es adecuada.

---

## 4) Funciones críticas sin validación de entrada

### 4.1 `ServiceRegistry.register` — sin validar contrato/instancia

**Archivo/líneas:** `game/isla-ancestral/scripts/core/service_registry.gd:22-28`

```gdscript
func register(contract: String, instance: Object) -> bool:
	if _registry.has(contract):
		push_warning("[M40] DOM-INF-REGISTRO: contrato duplicado '%s' — segundo registro rechazado" % contract)
		_duplicados_rechazados += 1
		return false
	_registry[contract] = instance
	return true
```

**Problemas:**
- No valida `contract` vacío o solo espacios (`""` sería una clave válida pero semánticamente inválida).
- No valida `instance == null`; permitiría registrar `null` y que `has()` devuelva `true` mientras `get_service()` propague `null` como si fuera un servicio válido, dificultando el diagnóstico (además `get_service` solo avisa en acceso temprano cuando devuelve `null` por ausencia, no por registro explícito de `null`).

### 4.2 `ServiceRegistry.validate_required` — asume elemento convertible a contrato válido

**Archivo/líneas:** `game/isla-ancestral/scripts/core/service_registry.gd:63-68`

```gdscript
func validate_required(required: Array) -> Array[String]:
	var missing: Array[String] = []
	for svc in required:
		if not _registry.has(String(svc)):
			missing.append(String(svc))
	return missing
```

**Problemas menores:** no filtra entradas vacías/nulas en `required`; podría reportar faltantes espurios (`""`) o enmascarar errores de configuración del llamador. Es menos crítico que `register`, pero es una superficie de validación débil en una función usada para chequeos de integridad (p.ej. bootstrap).

### 4.3 `EventBus`

`event_bus.gd` no expone funciones críticas propias más allá de la inicialización de dominios (`event_bus.gd:15-44`); el contrato se basa en señales tipadas de Godot. No se detectaron funciones de entrada sin validación dentro de este archivo (la validación efectiva recae en los emisores/consumidores).

---

## 5) Dos mejoras concretas de diseño

### Mejora A — API segura y observable en `ServiceRegistry` (validación + contrato explícito)

**Objetivo:** evitar registros inválidos y mejorar diagnósticos en arranque.

**Cambios sugeridos (compatibles hacia atrás):**
1. Endurecer `register` (`service_registry.gd:22-28`):
   - Rechazar `contract.strip_edges().is_empty()` con `push_warning` y `return false`.
   - Rechazar `instance == null` con `push_warning` y `return false` (o contador específico `registros_invalidos`).
2. Normalizar contrato internamente (`contract = contract.strip_edges()`), y opcionalmente exponer `get_service_or_error(contract)` / aserción en debug para fallos tempranos.
3. En `validate_required` (`service_registry.gd:63-68`), ignorar/advertir elementos vacíos para no contaminar el reporte de faltantes.
4. (Opcional) Añadir `register_typed(contract, instance, expected_script_or_class)` en builds de debug para detectar wiring incorrecto temprano.

**Beneficio:** elimina estados "registrado pero inutilizable", reduce bugs silenciosos de bootstrap/autoload y hace el sistema de servicios más robusto ante refactors.

### Mejora B — Higiene y verificación de contratos del `EventBus`

**Objetivo:** que el bus sea una fuente de verdad confiable (un evento = un contrato, con productor y consumidor claros).

**Cambios sugeridos:**
1. **Auditoría de señales huérfanas/duplicadas:** resolver los casos detectados en §1 y §2:
   - Unificar `travel_started`: o emitir/consumir `EventBus.travel.travel_started` desde `TravelService`/UI, o retirar la señal del bus y documentar el contrato local.
   - Alinear `ui_layers_changed`/`ui_focus_moved`: emitir en `EventBus.ui` desde `UIManager` (además o en lugar de señales locales) o eliminar del bus si no es API pública.
   - Garantizar un emisor real de `travel.island_loaded` en el flujo de carga (SceneManager/Travel) o formalizar el adaptador que hoy menciona `scripts/audio/narrative_sound.gd:57`.
2. **Convención de documentación por señal:** en `event_bus.gd` anotar para cada señal `@emitter` y `@consumer` (módulo/owner esperado) y marcar explícitamente las reservadas/futuras; esto evita que señales como `purchase_done`, `chunk_modified`, `hud_request` queden ambiguas.
3. **Chequeo automatizable:** añadir un script/herramienta (editor o CI) que compare declaraciones de señales del bus vs referencias `.emit/.connect` y reporte huérfanos (con lista blanca para casos dinámicos como advierte `scripts/core/probe_runtime_bus_m14.gd:7`).

**Beneficio:** reduce acoplamiento accidental, evita integraciones "medio cableadas" (consumidores esperando eventos que nunca llegan) y facilita el trabajo paralelo entre módulos.

---

## Conclusión final

- **Acoplamiento:** `EventBus` y `ServiceRegistry` están bien desacoplados entre sí y del dominio en su estructura, pero existen **contratos de eventos duplicados o no unificados** (`travel_started`, señales de UI, `island_loaded`) que generan acoplamiento indirecto y ambigüedad de integración.
- **Señales:** se detectan múltiples señales **sin emisión y/o sin conexión** en análisis estático (economía/jugador/UI/viaje/progresión y otras), además de contratos consumidos cuyo productor real no es evidente. Requiere saneamiento para que el bus sea confiable.
- **Dependencias circulares:** **no se observaron** entre `event_bus.gd` y `service_registry.gd` ni vía bootstrap.
- **Validación de entrada:** el punto crítico es `ServiceRegistry.register` (y en menor medida `validate_required`), que acepta contratos/instancias inválidos; conviene endurecerlos.
- **Prioridad recomendada:** (1) validar y sanear `ServiceRegistry.register/validate_required`, (2) unificar o deprecar contratos huérfanos del `EventBus` (`travel_started`, señales UI, `island_loaded`) y establecer una política de emisor/consumidor por señal.

**Estado del análisis:** basado en inspección estática del código y referencias del repositorio al 2026-11-12. Hallazgos de "sin uso" deben confirmarse considerando posibles emisiones/conexiones dinámicas en runtime.
