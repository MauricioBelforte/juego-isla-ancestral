# Reporte de arquitectura: EventBus y ServiceRegistry

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-08 04:22 (UTC, según contexto)  
**Alcance:** `game/isla-ancestral/scripts/core/event_bus.gd`, `game/isla-ancestral/scripts/core/service_registry.gd` (+ verificación de usos con `git grep` en `game/isla-ancestral/`)

---

## 1) ¿Hay acoplamiento fuerte entre sistemas que debería ser suelto?

**Conclusión:** no se observa acoplamiento fuerte *entre* `EventBus` y `ServiceRegistry`, ni acoplamiento directo de estos módulos con dominios de juego. El diseño es mayormente desacoplado por señales/autoload.

**Evidencia:**
- `event_bus.gd:1-46` define el bus como autoload de eventos tipados por dominio y declara explícitamente el patrón “Signal Up, Call Down”; no importa dominios ni referencias a `ServiceRegistry`.
- `service_registry.gd:9-75` implementa un registro genérico `Dictionary` por contrato `String`; no referencia `EventBus` ni dominios concretos.

**Acoplamiento residual (aceptable, pero a vigilar):**
- Los consumidores acceden a ambos autoloads por ruta de escena (`/root/EventBus`, `/root/ServiceRegistry`) con `get_node_or_null`/`has_node`/`get_node` en muchos scripts (verificación: ~170 coincidencias bajo `game/isla-ancestral/scripts`). Esto acopla el código al **nombre del autoload** y a la disponibilidad en árbol, no a implementaciones concretas. Es un patrón común en Godot, pero concentra dependencia en convención global.

**Veredicto (1):** sin acoplamiento fuerte entre sistemas que deba hacerse suelto en estos dos archivos; el acoplamiento existente es de infraestructura (autoload naming), no de dominio.

---

## 2) ¿Hay señales declaradas que nunca se emiten o nunca se conectan?

Verificación realizada con `git grep` sobre `game/isla-ancestral` para `.emit(` / `.connect(` / referencias de cada señal.

| Señal | Declaración | `emit` encontrado | `connect` encontrado | Estado |
|---|---:|---|---|---|
| `WorldEvents.chunk_modified` | `event_bus.gd:54` | No (fuera de docs/declaración) | No | **Declarada, sin uso (ni emit ni connect)** |
| `EconomyEvents.debt_paid` | `event_bus.gd:64` | No | No | **Declarada, sin uso (ni emit ni connect)** |
| `WorldEvents.biome_changed` | `event_bus.gd:56` | Solo en QA spy: `scripts/core/qa_m40_spy.gd:51` | No encontrado en scripts | **Se emite solo en código de prueba/spy; sin consumidor conectado** (posible API preparada o huérfana en runtime) |

**Notas de contraste (señales que sí tienen uso):**
- `block_placed`/`block_removed` tienen emisiones/conexiones reales (p. ej. `save_manager.gd:86-87`, `tutorial_manager.gd:201`, tests/spy). `block_removed` aparece en `save_manager.gd:87`, `qa_m40_spy.gd:76`, `particles/test_vfx_m52_iter6.gd:263`.
- Eventos de economía usados: `currency_changed` y `purchase_done` tienen conexiones/emisiones en HUD, guardado, progresión, logros, etc. (`debt_paid` es la excepción sin uso).
- Eventos de jugador: `player_died`, `level_up`, `damage_taken` están declarados (`event_bus.gd:154-158`); el muestreo de `friendship_level_up` (NPC) muestra uso activo, pero **no se auditó exhaustivamente cada señal de `PlayerEvents`** en esta pasada — conviene completar la matriz si se quiere certeza total.

**Veredicto (2):** hay señales muertas/preparadas sin integración real: `world.chunk_modified` y `economy.debt_paid` no se emiten ni se conectan; `world.biome_changed` solo se emite en QA spy sin conexiones detectadas. Esto sugiere deuda de contrato o funcionalidad pendiente.

---

## 3) ¿Hay dependencias circulares entre servicios?

**Conclusión:** no se detectan dependencias circulares *entre* `event_bus.gd` y `service_registry.gd`.

**Evidencia:**
- `event_bus.gd` no referencia `ServiceRegistry` (búsqueda: sin coincidencias).
- `service_registry.gd` no referencia `EventBus` (búsqueda: sin coincidencias).
- Ambos son autoloads de infraestructura consumidos por dominios; la dirección esperada es “dominios → EventBus/ServiceRegistry”, no al revés.

**Limitación:** la ausencia de ciclo entre estos dos archivos no garantiza ausencia de ciclos entre *servicios registrados* en `ServiceRegistry` (p. ej. A obtiene B y B obtiene A en `_ready`/resolución). Eso requeriría auditoría de los contratos registrados y de sus constructores/`_ready`.

**Veredicto (3):** sin dependencias circulares entre `EventBus` y `ServiceRegistry`.

---

## 4) ¿Hay alguna función crítica sin validación de entrada?

Sí. `ServiceRegistry` expone API crítica de resolución/registro con validación parcial.

| Función | Archivo:línea | Problema | Riesgo |
|---|---:|---|---|
| `register(contract, instance)` | `service_registry.gd:22-28` | Valida duplicado, pero **no valida** `contract` vacío/whitespace ni `instance == null`. Permite registrar `""` o `null` como servicio válido (devuelve `true`, línea 27-28). | Un contrato vacío o servicio nulo puede propagarse como dependencia “válida” y fallar tarde en consumidores; dificulta diagnóstico (parece registrado). |
| `get_service(contract)` | `service_registry.gd:33-38` | Advierte acceso temprano si es `null`, pero no distingue `contract` inválido (`""`) de “aún no registrado”. | Ruido o ambigüedad diagnóstica; consultas con clave vacía son errores de llamada que pasan silenciosos salvo semántica del warning. |
| `unregister(contract)` | `service_registry.gd:45-46` | Sin validación ni retorno; borra silenciosamente. | Errores de contrato no se detectan; difícil saber si se desregistró algo real. |
| `validate_required(required)` | `service_registry.gd:63-68` | Acepta `Array` genérico y castea con `String(svc)`; correcto para robustez, pero no valida elementos nulos/vacíos como error explícito de configuración. | Un requisito `""`/`null` puede evaluarse como faltante confuso o como clave inesperada. |

**`EventBus`:** no define métodos públicos con lógica (solo señales y contenedores de eventos en `event_bus.gd:15-43,48-199`). No se identifican funciones críticas con validación faltante dentro del archivo; el riesgo está en el uso externo de señales (tipado ayuda en GDScript, pero no impide abuso).

**Veredicto (4):** `ServiceRegistry.register` carece de validación crítica de entradas (`contract` vacío, `instance` nulo); es la mejora de robustez más importante en estos dos archivos.

---

## 5) Dos mejoras concretas de diseño

### Mejora A — Endurecer el contrato de `ServiceRegistry.register` (robustez y diagnóstico temprano)

**Archivo:** `game/isla-ancestral/scripts/core/service_registry.gd:22-28`

**Cambio propuesto:**
1. Rechazar `contract.strip_edges().is_empty()` con `push_warning`/`push_error` identificable (p. ej. `DOM-INF-CONTRATO-INVALIDO`) y `return false`.
2. Rechazar `instance == null` o, si se quiere más estricto, `not is_instance_valid(instance)` cuando aplique (cuidar tipos `Object` liberados).
3. (Opcional) Normalizar el contrato: `var key := contract.strip_edges()` y usar `key` como clave canónica para evitar duplicados por espacios.
4. Documentar en el comentario que `register` es **fallible por validación**, no solo por duplicado.

**Beneficio:** evita estado corrupto silencioso en el registro central; alinea con el enfoque defensivo ya usado en `get_service`/duplicados.

### Mejora B — Política explícita para señales “reservadas/no usadas” en `EventBus`

**Archivo:** `game/isla-ancestral/scripts/core/event_bus.gd:48-65,154-158` (y otros dominios según auditoría completa)

**Cambio propuesto:**
1. Para señales sin integración runtime confirmada (`chunk_modified:54`, `debt_paid:64`; revisar también `biome_changed:56` que solo aparece en spy), elegir una política:
   - **Eliminar** si no hay roadmap inmediato (reduce superficie de API y confusión).
   - **O marcar** con convención clara, p. ej. comentario `## RESERVADA (sin emisor/consumidor runtime a 2026-11-08) — no usar sin implementar flujo` y/o prefijo en documentación interna.
2. Añadir una prueba/smoke de contrato (GdUnit o script de verificación) que falle o advierta cuando una señal “activa” no tenga al menos un emisor o un consumidor esperado en runtime, según la política del módulo.
3. Completar la matriz de uso para `PlayerEvents` (`player_died/level_up/damage_taken`, `event_bus.gd:154-158`) con el mismo método de auditoría, ya que no fue exhaustiva en esta pasada.

**Beneficio:** reduce deuda de contrato, evita que otros sistemas se acoplen a señales fantasma y hace visible qué eventos son reales vs. planeados.

---

## Conclusión final

- **Acoplamiento (1):** bajo entre `EventBus` y `ServiceRegistry`; no hay acoplamiento fuerte entre sistemas que requiera rediseño inmediato. El acoplamiento principal es al naming de autoloads (`/root/...`), propio de Godot.
- **Señales (2):** `world.chunk_modified` y `economy.debt_paid` están declaradas sin emisiones/conexiones detectadas; `world.biome_changed` solo aparece en emisión de QA spy sin consumidor. Se recomienda limpieza o marcación explícita como reservadas.
- **Dependencias circulares (3):** no se observan entre los dos archivos analizados.
- **Validación (4):** `ServiceRegistry.register` acepta `contract` vacío e `instance` nulo, lo cual es un riesgo evitable en una API crítica.
- **Mejoras (5):** (A) validar/normalizar entradas en `ServiceRegistry.register`; (B) definir política y verificación para señales reservadas/no integradas en `EventBus`.

**Estado del análisis:** estático + evidencias por búsqueda en repositorio; no ejecuta Godot runtime. Para certeza total de (2) conviene completar la matriz de todas las señales de todos los dominios con el mismo criterio.
