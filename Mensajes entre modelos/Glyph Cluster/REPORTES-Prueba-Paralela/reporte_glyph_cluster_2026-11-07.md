# Reporte de arquitectura — `EventBus` y `ServiceRegistry`

**Fecha:** 2026-11-07  
**Modelo:** Glyph Cluster  
**Alcance:** análisis estático de `game/isla-ancestral/scripts/core/event_bus.gd` y `game/isla-ancestral/scripts/core/service_registry.gd`, con evidencia de uso real en `game/isla-ancestral/scripts/**/*.gd` y contexto de `bootstrap.gd` / `contratos.gd` / `scene_manager.gd`.

---

## 1) Acoplamiento fuerte que debería ser suelto

### 1.1 Diseño base (bajo acoplamiento)
`EventBus` aplica “Signal Up, Call Down” (`event_bus.gd:5-13`): declara dominios/señales y no importa lógica de dominio. `ServiceRegistry` almacena `Object` genéricos por contrato (`service_registry.gd:11,22,27,33`) sin referencias a dominios concretos. No se observa acoplamiento fuerte directo entre `EventBus` ↔ `ServiceRegistry`.

### 1.2 Acoplamientos fuertes detectados
| Punto | Evidencia | Por qué es fuerte | Impacto |
|---|---|---|---|
| Catálogo de dominios/autoloads hardcodeado en infraestructura | `bootstrap.gd:23-33` (`DOMINIOS_ESPERADOS`), `:64-77` (mapa contrato→nombre de nodo `/root/*`), `:80-82` (registro) | El orquestador conoce la composición concreta del juego; agregar/quitar dominio exige modificar `Bootstrap`. | Frágil ante cambios; riesgo de desincronización entre catálogo esperado y nodos reales. |
| Resolución mixta por `ServiceRegistry` y por árbol `/root/...` | `contratos.gd` centraliza IDs; `bootstrap.gd:82,149,154,218` registra; pero muchos consumidores usan `get_node_or_null("/root/...")` (p. ej. `scene_manager.gd:82,95`) | Acopla consumidores al grafo de escena/autoloads en vez de al contrato de servicio. | Dificulta pruebas, sustitución/mocking y refactors de composición. |
| `Bootstrap` se registra como `"service_registry"` y expone `get_service()` | `bootstrap.gd:154,222-223` | Mezcla responsabilidades (bootstrap vs registry) y crea dos puntos de acceso al mismo concepto. | API ambigua; mayor superficie de mantenimiento. |

**Conclusión:** el acoplamiento fuerte residual está en la capa de composición/acceso (catálogo hardcodeado + dependencia de `/root`), no en el bus de eventos como mecanismo.

---

## 2) Señales declaradas que nunca se emiten o nunca se conectan

Metodología: búsqueda de `.emit(...)`/`.connect(...)` en `game/isla-ancestral/scripts/**/*.gd`. Se distinguen usos runtime de usos exclusivos de tests/QA cuando aplica.

| Dominio.Señal | Emisión runtime | Conexión runtime | Diagnóstico |
|---|---|---|---|
| `world.chunk_modified` (`event_bus.gd:54`) | No | No | **Sin emisor ni consumidor runtime.** Solo aparece en definición/QA. |
| `world.biome_changed` (`:56`) | No (solo `qa_m40_spy`) | No | **Sin uso runtime.** |
| `economy.currency_changed` (`:60`) | No | No | **Sin uso.** |
| `economy.purchase_done` (`:62`) | No | No | **Sin uso.** |
| `economy.debt_paid` (`:64`) | No | No | **Sin uso.** |
| `inventory.hotbar_selected` (`:72`) | No detectada | Sí (`hotbar_widget.gd:136`, `hud_screen.gd:121`) | **Consumida, sin emisor runtime** (contrato incompleto). |
| `calendar.vessel_arrived` (`:104`) | No | No | **Sin uso.** |
| `travel.island_loaded` (`:120`) | No runtime real (emit en `diario/test_diario.gd:98`; `travel_service.gd` emite `travel_started`, no `island_loaded`) | Sí (`narrative_sound.gd:55`, `diary_service.gd:114`) | **Consumidores runtime existen; emisor runtime ausente.** Riesgo de funcionalidad nunca disparada. |
| `ui.hud_request` (`:136`) | No | Sí (`ui_manager.gd:52`) | **Consumida, sin emisor.** |
| `ui.dialog_requested` (`:138`) | No `.emit` localizado en scripts | Sí (`ui_manager.gd:54`, `dialog_layer.gd:56`, `save_manager.gd:104`) | **Consumidores existen; emisor no localizado** (posible emisión fuera del patrón buscado o contrato aún no cableado). |
| `ui.layer_requested` (`:142`) | No | No | **Sin uso.** |
| `ui.confirm_requested` (`:144`) | No | No | **Sin uso.** |
| `player.player_died` (`:154`) | No | No | **Sin uso.** |
| `player.level_up` (`:156`) | No | No | **Sin uso** (distinta de `npc.friendship_level_up`). |
| `player.damage_taken` (`:158`) | No | No | **Sin uso.** |
| `progresion.nivel_casa_cambio` (`:178`) | No | No | **Sin uso** (`nivel_herramienta_cambio` sí se usa: emite `progression_manager.gd:216`, conecta `test_nivel_herramienta.gd:37`). |
| `progresion.nivel_amistad_cambio` (`:180`) | No | No | **Sin uso** (la amistad usa `npc.friendship_level_up`). |
| `diary.categoria_completa` (`:188`) | Sí (`diary_service.gd:313`) | No detectada | **Emitida, sin consumidor runtime.** |
| `infra.carga_completada` (`:169`) | Vía `scene_manager.gd:65 -> _emitir_infra('carga_completada', ...)` (`:81-88`); `loading_layer.gd:46` emite una señal *local* `carga_completada.emit()` | No se detectó `.connect` a `EventBus.infra.carga_completada` | **Probable emisor bus sin consumidor en bus**; verificar intención (¿debería escuchar UI/guardas?). |

**Señales con cableado activo (muestra):** `time.fase_cambio` (emit `day_night_cycle.gd:316`, connect `test_ciclo_dia_noche.gd:102`), `weather.clima_cambio/intensidad_cambio` (emit `weather_service.gd`, connects en `farm/event_manager/tests`), `vehicle.*` (emit `vehicle_manager.gd`, connects tests), `fishing.sesion_iniciada/terminada` (emit `fishing_manager.gd`, connect/block `save_manager.gd`), `infra.game_flow_changed/boot_completado/carga_iniciada` (usos runtime/tests presentes), `ui.notify/ui_layers_changed/ui_focus_moved` (usos en UI).

---

## 3) Dependencias circulares entre servicios

- **`EventBus` ↔ dominios:** no hay dependencias/imports de dominio en `event_bus.gd`; solo define señales/tipos. Los dominios usan el autoload `EventBus`. **Sin ciclo.**
- **`ServiceRegistry` ↔ servicios:** trabaja con `Object`/`Variant` genéricos (`service_registry.gd:11,22,33`); no referencia servicios concretos. **Sin ciclo.**
- **`Bootstrap` → `ServiceRegistry`/`EventBus`/nodos `/root/*`:** dependencia unidireccional de arranque (`bootstrap.gd:78-82,138-154,164-179`). Usa `call_deferred` (`:51-55`) para respetar orden de autoloads. **Sin ciclo estático.**
- **`SceneManager` → `GameFlowManager`/`EventBus.infra`:** resuelve dependencias por `/root` y nombre de estado dinámico (`scene_manager.gd:94-109,82-88,102-109`); no hay referencia inversa. **Sin ciclo estático detectado.**

**Riesgo asociado (no circularidad):** el orden de inicialización y la doble vía de acceso (registry + `/root`) pueden producir accesos tempranos (`ServiceRegistry` ya mitiga con aviso único `DOM-INF-ACCESO-TEMPRANO`, `:13,34-37`), pero no forman un ciclo de dependencias entre módulos.

**Conclusión:** no se observan dependencias circulares estáticas entre `EventBus`, `ServiceRegistry`, `Bootstrap` y `SceneManager`. El riesgo principal es de inicialización/composición, no de ciclo.

---

## 4) Funciones críticas sin validación de entrada

### 4.1 `ServiceRegistry` (crítico)
| Función | Validación actual | Falta / riesgo |
|---|---|---|
| `register(contract, instance)` (`:22-28`) | Rechaza duplicados (`_registry.has`) y no sobrescribe (**bien**). | No valida `contract` vacío/solo espacios, `instance == null`, ni `is_instance_valid(instance)`. Registrar `""` o `null` contamina el registro. |
| `get_service(contract)` (`:33-38`) | Retorna `null` + warning único por acceso temprano (**bien**). | No valida formato de `contract`; no distingue “no registrado” de “contrato inválido”. |
| `unregister(contract)` (`:45-46`) | — | Operación silenciosa: no informa si el contrato no existía; no valida entrada. |
| `validate_required(required)` (`:63-68`) | Convierte a `String` defensivamente. | Acepta `Array` genérico; sin validación de elementos nulos/vacíos. |
| `contracts()/list_registered()` (`:49-58`) | — | Bajo riesgo; devuelven copia lógica de claves/strings. |

### 4.2 `EventBus` (crítico como contrato)
- No implementa API propia de `emit/subscribe`; expone instancias de dominio (`:15-43`) y señales tipadas (`Vector3i`, `int`, `String`, `Dictionary`, `Array`, etc.).
- **Validación disponible:** tipado de GDScript en firmas de señal.
- **Validación ausente (semántica):** no hay guardas para IDs vacíos, cantidades negativas, enums fuera de rango, rutas inválidas, `spawn_point`/`cargo` incoherentes, etc. La responsabilidad queda dispersa en emisores/consumidores.

### 4.3 `Bootstrap` (relacionado)
- `_autoregistrar_dominios()` (`:63-82`): valida `nodo != null` y `reg != null/not reg.has` (**bien**), pero depende de la existencia del autoload `ServiceRegistry`.
- `_registry()` (`:138-139`) puede devolver `null`; llamadas posteriores asumen disponibilidad en algunos caminos (riesgo controlado parcialmente por chequeos locales).

**Conclusión:** la brecha más concreta y corregible está en `ServiceRegistry.register/unregister` (entradas nulas/vacías/instancias inválidas). `EventBus` requiere validación semántica en los puntos de emisión/consumo o helpers de dominio, ya que el bus solo tipa forma.

---

## 5) Dos mejoras concretas de diseño sugeridas

### Mejora 1 — Endurecer `ServiceRegistry` y alinearlo con `Contratos`
**Cambios concretos:**
1. En `register(contract, instance)` (`service_registry.gd:22`): rechazar `contract.strip_edges().is_empty()` e `instance == null`; opcionalmente validar `instance is Object` y `is_instance_valid(instance)` cuando aplique. Devolver `false` con `push_warning` específico (`DOM-INF-CONTRATO-INVALIDO` / `DOM-INF-INSTANCIA-INVALIDA`). Mantener el rechazo de duplicados existente (`:23-26`).
2. En `unregister(contract)` (`:45`): devolver `bool` (`true` si existía) y opcionalmente advertir en debug si se intenta borrar un contrato desconocido.
3. Integrar `Contratos.es_contrato_valido()` (`contratos.gd:89-93`) en `register/get_service` (al menos en debug o bajo flag): advertir ante contratos no declarados para detectar typos (`"analytic"` vs `"analytics"`).
4. Añadir pruebas unitarias/headless para casos: contrato vacío, instancia `null`, duplicado, unregister inexistente, contrato inválido.

**Beneficio:** registro fail-fast, menor estado corrupto, diagnósticos accionables y alineación con el catálogo centralizado de M40.

### Mejora 2 — Auditoría viva del contrato de señales del `EventBus`
**Cambios concretos:**
1. Crear un chequeo automatizado (script/test headless, reutilizando el enfoque de `qa_m40_spy`/`test_arquitectura`) que reporte por cada señal: **definida / emitida runtime / conectada runtime / solo tests**.
2. Para señales huérfanas detectadas, tomar decisión explícita por ítem (dueño + fecha): *implementar emisor/consumidor*, *deprecar* (comentario + módulo responsable) o *eliminar*. Priorizar los casos con medio contrato: `inventory.hotbar_selected` (agregar emisor donde cambia el slot), `travel.island_loaded` (emitir al completar carga de isla), `diary.categoria_completa` (conectar UI/logro/notificación si aplica), `ui.hud_request`/`ui.dialog_requested` (confirmar emisores reales).
3. Revisar señales sin uso actual (`world.chunk_modified/biome_changed`, `economy.*`, `calendar.vessel_arrived`, `player.*`, `ui.layer_requested/confirm_requested`, `progresion.nivel_casa_cambio/nivel_amistad_cambio`): mantener solo si hay roadmap inmediato; si no, marcarlas como reservadas/deprecadas para evitar integraciones “al aire”.
4. Verificar `infra.carga_completada`: confirmar si debe tener consumidor en bus (además de la señal local de `loading_layer.gd`) y cablearlo o documentar la separación.

**Beneficio:** reduce superficie muerta, evita contratos parcialmente implementados, mejora trazabilidad para QA (§21.8.2.b evidencia real) y hace el bus observable/mantenible.

---

## Resumen ejecutivo
- **Acoplamiento:** bajo en el patrón EventBus; fuerte residual en composición/bootstrap y acceso por `/root`.
- **Señales:** múltiples señales sin uso runtime y varios contratos a medio cablear (emisor o consumidor faltante).
- **Dependencias circulares:** no detectadas entre los componentes analizados.
- **Validación:** `ServiceRegistry.register` carece de guardas para entradas inválidas/nulas; `EventBus` carece de validación semántica.
- **Acción prioritaria:** (1) endurecer `ServiceRegistry` + contrato `Contratos`; (2) auditoría viva de señales con decisiones explícitas por señal huérfana.
