# Reporte de arquitectura: `EventBus` y `ServiceRegistry`

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-12  
**Alcance:** análisis estático de `game/isla-ancestral/scripts/core/event_bus.gd` y `game/isla-ancestral/scripts/core/service_registry.gd`, con contraste puntual contra usos/emisiones/conexiones en `game/isla-ancestral/scripts` y `game/isla-ancestral/tests`.

---

## 1) Acoplamiento entre sistemas

### 1.1 `event_bus.gd` — desacoplamiento por señales, acoplamiento a infraestructura global

**Hallazgos**
- `event_bus.gd:3-13` define explícitamente el patrón “Signal Up, Call Down” y declara: “EventBus NO importa ningún dominio (solo define tipos)”. La implementación confirma esto: no hay `preload`/`load`/referencias a sistemas de dominio; solo señales tipadas agrupadas por clases internas (`WorldEvents`, `EconomyEvents`, etc., `:48-199`) instanciadas como miembros (`:15-43`).
- Esto **reduce el acoplamiento directo productor↔consumidor** (no necesitan conocerse entre sí), pero introduce **acoplamiento fuerte a un punto global compartido**:
  - Todos los sistemas dependen del autoload/singleton `EventBus` y de la forma exacta del contrato de cada señal (nombre, dominio y tipos de parámetros). Cualquier cambio de firma (p.ej. `gift_given(npc_id, item_id, clase)` en `:92`) es un cambio de ruptura transversal.
  - El bus es **monolítico** (16 dominios en un único archivo). Agregar o modificar dominios exige tocar `core/event_bus.gd`, concentrando conflictos de edición y acoplamiento de cambio (violación práctica de apertura/cierre a nivel de archivo).
  - Existe acoplamiento semántico cruzado por dominio: p.ej. `ProgresionEvents.nivel_amistad_cambio` (`:180`) convive con eventos de amistad en `NPCEvents` (`:88`), lo que obliga a los consumidores a conocer en qué subdominio vive cada señal.

**Conclusión (1):** no se observa acoplamiento fuerte *directo* entre sistemas de dominio dentro del bus (correcto para un event bus), pero sí **acoplamiento fuerte y centralizado a la infraestructura global y a sus contratos**. El riesgo principal es el “god-bus” como punto único de dependencia/cambio.

### 1.2 `service_registry.gd` — Service Locator con dependencias implícitas

**Hallazgos**
- Registro dinámico por clave string (`_registry: Dictionary`, `:11`) con `register/get_service/has/unregister` (`:22-46`). `get_service` devuelve `Variant` (`:33`), sin tipado de la instancia recuperada.
- El patrón Service Locator **suelta el acoplamiento de construcción/importación directa** en muchos casos, pero **endurece el acoplamiento implícito en tiempo de ejecución**:
  - Los consumidores quedan acoplados al nombre de contrato y a la API concreta del servicio obtenido (acoplamiento por convención, no verificable en compilación). Ej.: `contratos.gd` documenta el uso `ServiceRegistry.get_service(Contratos.ECONOMY_MANAGER)` (`scripts/core/contratos.gd:12-13`), pero el tipo real no se impone.
  - Dependencias ocultas: no son visibles en la firma/constructor del consumidor; fallan tarde (null + warning de acceso temprano, `:34-38`) o por API inesperada.
  - Centraliza descubrimiento pero no ciclo de vida/orden: la corrección depende de que alguien registre antes (de ahí el aviso `DOM-INF-ACCESO-TEMPRANO`).

**Conclusión (1):** acoplamiento “suelto” a nivel de referencias directas entre clases, pero **acoplamiento implícito y no tipado a contratos de servicio** (locator global). Es un trade-off razonable para autoloads, aunque frágil ante refactors y errores de orden de inicialización.

---

## 2) Señales declaradas sin emisión y/o sin conexión

Búsqueda realizada sobre `game/` y `scripts/` (incluye tests) por `.señal.emit/.connect` y por `emit_signal/connect("señal")` (sin resultados por nombre string para las candidatas). Clasificación:

| Dominio/Señal | Declaración | Emisión detectada | Conexión detectada | Estado |
|---|---:|---|---|---|
| `world.chunk_modified` | `event_bus.gd:54` | No | No | **Huérfana** (sin emisor ni receptor) |
| `economy.debt_paid` | `event_bus.gd:64` | No | No | **Huérfana** |
| `calendar.vessel_arrived` | `event_bus.gd:104` | No | No | **Huérfana** |
| `ui.layer_requested` | `event_bus.gd:142` | No | No | **Huérfana** |
| `ui.confirm_requested` | `event_bus.gd:144` | No | No | **Huérfana** |
| `player.player_died` | `event_bus.gd:154` | No | No | **Huérfana** |
| `player.level_up` | `event_bus.gd:156` | No | No | **Huérfana** (distinta de `npc.friendship_level_up`) |
| `player.damage_taken` | `event_bus.gd:158` | No | No | **Huérfana** |
| `ui.hud_request` | `event_bus.gd:136` | No | Sí: `scripts/ui/core/ui_manager.gd:52` | **Conectada, nunca emitida** (contrato inerte) |
| `ui.ui_layers_changed` | `event_bus.gd:148` | Sí: `scripts/ui/core/ui_manager.gd:247,276` | No | **Emitida, sin suscriptores** |
| `travel.island_loaded` | `event_bus.gd:120` | Solo test: `scripts/diario/test_diario.gd:98` | Sí (prod): `scripts/audio/narrative_sound.gd:55`, `scripts/diario/diary_service.gd:114` | **Sin emisor en producción** (contrato roto en runtime real); `narrative_sound.gd:57` documenta que ningún dominio la emite |
| `ui.dialog_requested` | `event_bus.gd:138` | Solo test: `scripts/saving/test_autosave_m59.gd:64` | Sí (prod): `ui_manager.gd:54`, `ui/layers/dialog_layer.gd:56`, `saving/save_manager.gd:118` | **Sin emisor en producción detectado** (usada en tests para ejercer listeners) |
| `ui.dialog_finished` | `event_bus.gd:140` | Solo test: `scripts/saving/test_autosave_m59.gd:74` | Sí (prod): `ui/layers/dialog_layer.gd:58`, `saving/save_manager.gd:119` | **Sin emisor en producción detectado** |

**Señales verificadas como activas (emisión y conexión presentes):** entre otras, `travel.travel_started` (`viajes/travel_service.gd:270` ↔ `viajes/travel_layer.gd:29`), `ui.notify` (múltiples emisores/receptores), `ui.ui_focus_moved` (emitida y conectada en `ui_manager.gd`), `npc.friendship_level_up`, `fishing.sesion_iniciada/terminada`, dominios `weather/time/infra/progresion/diary` con uso en scripts de producción.

**Conclusión (2):** hay **8 señales completamente huérfanas**, **1 conectada sin emisión**, **1 emitida sin suscriptores** y **3 con suscriptores de producción pero emisión solo en tests** (o ausente en producción). Esto indica deriva de contrato/API muerta o incompleta.

---

## 3) Dependencias circulares entre servicios

**Entre los dos módulos analizados:**
- `event_bus.gd` no referencia `ServiceRegistry` ni servicios registrados.
- `service_registry.gd` no referencia `EventBus` ni dominios de juego.
- **No existe dependencia circular directa entre `EventBus` y `ServiceRegistry`.**

**Entre servicios registrados (visión limitada al core analizado):**
- `ServiceRegistry` es un contenedor pasivo (`Dictionary` contrato→instancia) sin resolución automática ni inicialización de dependencias; no impone ni puede crear por sí mismo ciclos estructurales. Los usos observados en el ámbito inspeccionado son puntuales (`contratos.gd`, `test_datos_m60_iter4.gd:694`, referencia en `telemetry_director.gd`) y no evidencian ciclos.
- **No puede afirmarse la ausencia total de ciclos entre todos los servicios del proyecto** solo con estos dos archivos; para confirmarlo haría falta un grafo de dependencias de todos los `register/get_service` en runtime/código.

**Conclusión (3):** sin ciclos en el núcleo analizado; **sin evidencia de ciclos** entre servicios a partir de la muestra disponible, pero la verificación exhaustiva queda fuera del alcance de este análisis estático de los dos ficheros core.

---

## 4) Funciones críticas sin validación de entrada

### 4.1 `ServiceRegistry.register` — validación insuficiente (crítico)

`service_registry.gd:22-28`:
```gdscript
func register(contract: String, instance: Object) -> bool:
	if _registry.has(contract):
		...
		return false
	_registry[contract] = instance
	return true
```
- **No valida `contract` vacío o en blanco**: permite registrar `""` (o variantes sin sentido) como clave válida, contaminando el registro y haciendo difícil el diagnóstico.
- **No valida `instance == null`**: acepta registrar `null` (tipado `Object` permite casos límite en GDScript). Consecuencia: `has(contract)` devolvería `true`, pero `get_service` (`:33-38`) retorna `null` y emite `DOM-INF-ACCESO-TEMPRANO` en la primera consulta (porque compara `svc == null`), reportando erróneamente “no registrado/aún no disponible” cuando en realidad hay una entrada corrupta. Esto es una **inconsistencia de estado** difícil de depurar.
- Es una función crítica: un registro inválido rompe el descubrimiento de servicios del que dependen subsistemas (bootstrap/validaciones como `validate_required`, `:63-68`).

### 4.2 Otras funciones (menor severidad)

- `get_service/has/unregister` (`:33-46`): no validan el contrato de entrada; impacto bajo (devuelven null/no-op) pero podrían normalizar/rechazar entradas vacías por higiene.
- `validate_required` (`:63-68`): asume elementos convertibles a `String`; robusto en la práctica pero sin guarda explícita ante elementos nulos/no string.
- `EventBus` carece de métodos ejecutables con entrada externa; el riesgo no está en sus APIs sino en el contrato de señales consumido por terceros.

**Conclusión (4):** sí, **`register` carece de validación crítica de entradas** (contrato vacío/blanco e instancia nula), con posibilidad de estado inconsistente observable.

---

## 5) Dos mejoras concretas de diseño

### Mejora 1 — Endurecer el contrato de `ServiceRegistry.register` (guardas + semántica clara)

**Cambio propuesto (concreto):**
- En `register` (`service_registry.gd:22`):
  - Rechazar si `contract.strip_edges().is_empty()` → `push_error("[M40] DOM-INF-REGISTRO: contrato vacío/inválido")` y `return false`.
  - Rechazar si `instance == null` → `push_error("[M40] DOM-INF-REGISTRO: instancia nula para '%s'" % contract)` y `return false`.
  - (Opcional) normalizar clave con `contract = contract.strip_edges()` antes de almacenar/consultar para evitar duplicados por espacios.
- En `get_service`, distinguir “no registrado” de “registrado como null” es innecesario si `register` prohíbe null; con la guarda anterior, la semántica queda inequívoca.
- Añadir prueba unitaria específica (ya existen `test_smoke_core_hy3.gd`/`test_infraestructura_m40.gd` en el árbol) que verifique: rechazo de `""`, rechazo de `"   "` y rechazo de `null`, sin alterar entradas válidas.

**Beneficio:** elimina estados corruptos, hace el fallo explícito y temprano, y mejora la fiabilidad del diagnóstico `DOM-INF-ACCESO-TEMPRANO`.

### Mejora 2 — Gobernanza y saneamiento del contrato de señales del `EventBus`

**Cambio propuesto (concreto):**
- **Auditar y resolver señales en deriva** identificadas en la sección 2:
  - *Eliminar o mover a un bloque `# RESERVADO/NO IMPLEMENTADO`* las huérfanas sin caso de uso actual: `world.chunk_modified`, `economy.debt_paid`, `calendar.vessel_arrived`, `ui.layer_requested`, `ui.confirm_requested`, `player.player_died`, `player.level_up`, `player.damage_taken`.
  - *Cerrar asimetrías*: implementar emisor de producción para `travel.island_loaded` (hoy solo test, pero con receptores en `narrative_sound`/`diary_service`) y para `ui.dialog_requested`/`ui.dialog_finished` si el flujo de UI debe ser event-driven; o bien eliminar listeners/contrato si el flujo real es por llamada directa. Conectar o retirar `ui.ui_layers_changed`; emitir o retirar `ui.hud_request`.
- **Institucionalizar verificación automática**: incorporar una comprobación en CI/tests (apoyándose en el enfoque ya presente en el repo, p.ej. `scripts/red_probe_event_bus.py` y suites de core) que reporte señales declaradas sin al menos un emisor y un receptor en código de producción (excluyendo tests), para evitar regresiones de contrato.
- **Documentar el contrato por señal** (emisor dueño + consumidores esperados) junto a la declaración para que el acoplamiento contractual sea explícito.

**Beneficio:** reduce superficie de API muerta, evita integraciones que “escuchan” eventos que nunca ocurren en producción (`island_loaded`/diálogos), y hace sostenible la evolución del bus monolítico.

---

## Resumen ejecutivo

1. **Acoplamiento:** el bus evita acoplamiento directo entre dominios pero centraliza dependencia/contratos en un singleton monolítico; el registry es un Service Locator con dependencias implícitas y sin tipado de retorno.
2. **Señales:** 8 huérfanas, 1 conectada sin emisión, 1 emitida sin conexión y 3 sin emisión en producción pese a tener listeners (incl. `travel.island_loaded` reconocido en código como no emitido).
3. **Ciclos:** no hay dependencia circular entre `EventBus` y `ServiceRegistry`; no se evidencian ciclos entre servicios en la muestra, sin prueba exhaustiva global.
4. **Validación:** `ServiceRegistry.register` no valida contrato vacío ni instancia nula (riesgo de estado inconsistente).
5. **Mejoras:** (a) guardas estrictas en `register` + test; (b) saneamiento/gobernanza del contrato de señales con verificación automática de emisores/receptores.