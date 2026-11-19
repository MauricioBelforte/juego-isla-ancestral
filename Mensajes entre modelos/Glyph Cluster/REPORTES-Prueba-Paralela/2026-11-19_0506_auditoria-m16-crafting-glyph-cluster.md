# Auditoría de Arquitectura — M16 Crafting (`scripts/crafting/`)

- **Modelo:** Glyph Cluster
- **Plataforma:** Kilo Code (Agent Manager)
- **Fecha:** 2026-11-19 05:06 (UTC)
- **Alcance:** `game/isla-ancestral/scripts/crafting/*`, contratos/autoloads relevantes (`project.godot`, `scripts/inventario/inventario_service.gd`, `scripts/progresion/progression_manager.gd`, `data/balance/crafting.json`), wiring observado en `scripts/main_island.gd`, `scripts/ui/ui_root.gd`.
- **Fuera de alcance:** ejecución en runtime/editor, auditoría funcional completa de M14/M71/M53 fuera de puntos de integración, modificación de código del juego.
- **Solicitud:** `amr_1f232483e001x477LWrM4E08UV` (sesión `ses_e29c1cf34ffeQzQDAt8LdBV0KQ`). **Entrega por `agent_manager` (reply):** pendiente de intento; en auditorías previas de esta sesión falló con `The original Agent Manager sender is no longer available`.

## Resumen ejecutivo
- **Acoplamiento crafting↔inventario:** alto y bidireccional por contrato de señales + acceso directo al autoload (`/root/Inventario`) desde servicio, UI y flujo de pergaminos; sin interfaz/inyección en los consumidores.
- **Dependencias circulares autoloads crafting/inventario:** **no se observaron dependencias circulares directas** en `scripts/crafting/` ni referencias a `Crafting/CraftingService` en `scripts/inventario/` (búsqueda dirigida). La relación es principalmente `Crafting -> Inventario` + suscripción a `item_usado`.
- **Validación/desbloqueo por progresión (M71):** el conocimiento de recetas se gestiona internamente (inicial/experimento/pergamino) y el filtrado operativo es por estación/temporada; **no se halló integración explícita con `ProgressionManager`/hitos/umbrales** en `scripts/crafting/`.
- **Lógica de elaboración:** inconsistencia de rollback económico (AO no se reembolsa si falla la entrega), contrato ambiguo de consumo de pergamino, y encapsulación rota en UI (acceso a miembros internos `_` del servicio).

## Hallazgos

| # | Severidad | Hallazgo | Evidencia | Accionable |
|---|---|---|---|---|
| 1 | **Alto** | **Rollback incompleto en `craft`: se cobra `coste_ao` antes de asegurar entrega y no se reembolsa si el resultado no entra** (pérdida de moneda del jugador ante inventario lleno/fallo tardío). | `game/isla-ancestral/scripts/crafting/crafting_service.gd:286-293` (retira AO vía `EconomyManager`), `:295-310` (remueve materiales, intenta `add_item`, si `sobrante > 0` reembolsa solo materiales con `agregar_items` y emite fallo `inventario_lleno`, sin refund de AO). | Hacer la operación atómica a nivel de negocio: validar capacidad/entrega antes de cobrar, o registrar transacción compensable y reembolsar AO en el mismo rollback; cubrir con test de `inventario_lleno` + `coste_ao > 0`. |
| 2 | **Alto** | **Acoplamiento fuerte y violación de capas: `CraftingUI` lee inventario directamente y accede a estado/API interna (`_` privados) de `CraftingService`**, pese a declarar que consume "API de solo lectura" del servicio. | `game/isla-ancestral/scripts/crafting/crafting_ui.gd:8-9` (contrato declarado), `:200,216,264,285` (`/root/Inventario` + `count_item`), `:269,272,275,292,303` (`cs._tipo_de`, `cs._mejora_cfg`, `cs._nivel_de`, acceso a config interna y `mejorar_herramienta`). | Exponer en `CraftingService` una API pública de consulta de detalle/mejora (materiales, faltantes, nivel, durabilidad, coste, puede_mejorar) y que la UI no lea inventario ni miembros `_`; inyectar dependencias o resolver por interfaz. |
| 3 | **Medio** | **Contrato ambiguo de consumo de pergamino (doble responsabilidad potencial servicio↔inventario)**: documentación indica que M14 descuenta el ítem al usarlo, pero el servicio también lo remueve al aprender. | `game/isla-ancestral/scripts/crafting/crafting_service.gd:196-221` (`usar_pergamino` documenta "NO descuenta..." `:200`, pero `_on_item_usado` llama `inv.remover_items({item_id:1})` si aprendió `:214-220`); suscripción a `item_usado` de inventario `:54-57`. `game/isla-ancestral/scripts/inventario/inventario_service.gd` (autoload, sin `class_name`) no referencia Crafting (búsqueda sin resultados). | Definir dueño único del consumo (inventario al `use` o crafting al aprender) y documentarlo en ambos lados; evitar doble descuento/estado inconsistente con guardas idempotentes y tests de "ya conocida" vs "aprendida". |
| 4 | **Medio** | **Acoplamiento por service-locator global y composición oculta**: `CraftingService` resuelve múltiples autoloads por ruta y crea/inyecta `CraftingFeedback` como hijo en runtime. | `game/isla-ancestral/scripts/crafting/crafting_service.gd:49-69` (`/root/GameTime`, `/root/Inventario`, `/root/Balance`, carga y `add_child` de `crafting_feedback.gd`), `:217,233,281,287,390,410,422,445` (más lookups). `project.godot:36,63` (autoloads `Inventario`, `Crafting`). `game/isla-ancestral/scripts/crafting/crafting_feedback.gd:61-69` (feedback se acopla a señales del padre). | Permitir inyección/registro explícito de dependencias (inventario, economía, tiempo, save, balance, feedback/notifier) para testabilidad y reducir dependencia del orden/topología de autoloads. |
| 5 | **Medio** | **Integración con progresión/desbloqueo (M71) no observable en crafting**: conocimiento y disponibilidad dependen de origen, estación/temporada y experimentación, sin gating por hitos/umbrales ni notificación a progresión. | `game/isla-ancestral/scripts/crafting/crafting_service.gd:98-100` (iniciales conocidas), `:130-167` (filtro por conocida+estación+temporada; bloqueada solo por temporada), `:170-194,314-340` (aprender/pergamino/experimento). `game/isla-ancestral/scripts/crafting/crafting_recipe.gd:65-73` (fabricable solo por temporada). `game/isla-ancestral/scripts/progresion/progression_manager.gd` (catálogo/hitos/desbloqueos, p.ej. `:20-23,29,35-42,247-253`) sin referencias a Crafting (búsqueda dirigida). | Si el diseño requiere desbloqueo por progresión, introducir un `UnlockPolicy/RecipeGate` (consulta a M71) en `puede_conocer/puede_craft` y emitir eventos de dominio; si es deliberado, documentar explícitamente el contrato "crafting independiente de M71". |
| 6 | **Medio** | **Interacción de estación acoplada a nombre de nodo/escaneo de árbol y sin arbitraje de foco**: puede abrir crafting por proximidad sin garantizar que sea la estación interactuable activa. | `game/isla-ancestral/scripts/crafting/crafting_station.gd:55-69` (`_unhandled_input`: cualquier `interactuar` si distancia ≤ `RADIO_INTERACCION` abre), `:70-80` (búsqueda recursiva por nombre `"CraftingUI"`). Wiring observado: `scripts/main_island.gd:87`, `scripts/ui/ui_root.gd:76` (nodo `CraftingUI`). | Delegar la apertura al sistema de interacción/foco (M11) con identificador de estación/instancia; resolver UI por referencia inyectada o servicio, no por nombre global. |
| 7 | **Bajo** | **Feedback acoplado a forma concreta de `NotificationService` y con literales de texto con artefactos de codificación**. | `game/isla-ancestral/scripts/crafting/crafting_feedback.gd:115-125` (asume `push`, `ToastType.EVENT/ITEM`), `:73-105` (mensajes hardcodeados con mojibake visible en fuente), `:145-151` (timer/limpieza diferida). | Abstraer notificaciones tras un puerto (`notify(texto,tipo)`) con fallback seguro; normalizar cadenas a UTF-8/localización consistente con M87. |
| 8 | **Bajo** | **Validación de recetas/ingredientes acotada y con comparaciones frágiles**: experimentación compara claves como string ordenado y exige cantidades exactas; sin validación robusta de esquema/duplicados más allá de carga. | `game/isla-ancestral/scripts/crafting/crafting_service.gd:314-340` (`experimentar`: `str(claves)` vs `str(claves_receta)`, igualdad exacta por ítem), `:86-123` (carga desde Balance sin validación de integridad completa). QA auxiliar existe (`qa_m16_recetas_duplicados.gd`) pero es verificación puntual, no guardia en carga. | Comparar conjuntos/cantidades canónicamente (sin serializar a string), validar esquema y unicidad al cargar, y exponer errores de datos de receta. |
| 9 | **Ruido** | **Estado mutable reutilizado en hot-path** (`_materiales_total`) y documentación/código con mojibake/encodings inconsistentes. | `game/isla-ancestral/scripts/crafting/crafting_service.gd:264,296-299`; comentarios/textos con secuencias corruptas en varios archivos de crafting leídos. | Mantener buffer solo si se garantiza no reentrancia y documentarlo; normalizar encoding de fuentes a UTF-8. |

## Notas sobre dependencias circulares (crafting ↔ inventario)
- **Observado:** `Crafting` (autoload, `project.godot:63`) depende de `Inventario` (`:36`) por llamadas directas y por señal `item_usado` (`crafting_service.gd:54-57`). No se hallaron referencias a `Crafting`/`CraftingService` dentro de `scripts/inventario/`.
- **Conclusión:** no hay evidencia de ciclo directo de autoloads en el código inspeccionado; el riesgo principal es **acoplamiento fuerte unidireccional** y contratos implícitos (señales, forma de API), no un ciclo de carga/llamada directo.

## 2 mejoras de diseño concretas

### Mejora A — Puerto de inventario/economía y transacción de craft con compensación
**Objetivo:** desacoplar `CraftingService` de `/root/*`, garantizar atomicidad (incluido `coste_ao`) y hacer testeable la lógica sin autoloads.

```gdscript
# Conceptual (no implementado): puerto + resultado de transacción
class_name CraftingPorts
extends RefCounted

class InventoryPort:
	func count_item(item_id: String, total: bool = true) -> int: return 0
	func remove_items(items: Dictionary) -> bool: return false
	func add_items(items: Dictionary) -> bool: return false
	func add_item(item_id: String, amount: int) -> int: return amount # sobrante

class EconomyPort:
	func can_pay(amount: int) -> bool: return false
	func withdraw(amount: int) -> bool: return false
	func refund(amount: int) -> void: pass

# En CraftingService (idea):
# var _inv: InventoryPort; var _eco: EconomyPort  (inyectables; default adaptador a /root)
func craft_tx(rec_id: String, cantidad: int) -> bool:
	var receta := _recetas.get(rec_id) as CraftingRecipe
	if receta == null or not es_conocida(rec_id) or not receta.es_fabricable_ahora(get_estacion_actual()):
		return false
	var mats := _materiales_de(receta, cantidad)
	var ao := receta.coste_ao * cantidad
	if not _inv.has_items(mats): return false
	if ao > 0 and not _eco.can_pay(ao): return false

	if ao > 0 and not _eco.withdraw(ao): return false
	if not _inv.remove_items(mats):
		if ao > 0: _eco.refund(ao)
		return false
	var sobrante := _inv.add_item(receta.resultado_id, receta.resultado_cantidad * cantidad)
	if sobrante > 0:
		_inv.add_items(mats)
		if ao > 0: _eco.refund(ao)
		return false
	return true
```

**Impacto:** elimina acceso directo a autoloads en el núcleo, corrige el rollback de AO (hallazgo #1) y permite inyectar dobles en tests.

### Mejora B — `RecipeQuery`/`CraftingViewModel` + puerta de progresión (M71) explícita
**Objetivo:** que la UI consuma una vista pública (sin miembros `_`, sin leer inventario), y que el desbloqueo/disponibilidad pueda componerse con M71 sin acoplar Crafting a su implementación interna.

```gdscript
# Conceptual: vista para UI y política de desbloqueo
class_name RecipeQuery
extends RefCounted

func detalle(rec_id: String) -> Dictionary:
	# {nombre, materiales:[{id,req,tengo,origen,ok}], max_craftable, puede_mejorar,
	#  nivel, nivel_max, durabilidad_objetivo, coste_mejora, bloqueada_temporada, motivos[]}
	return {}

# Política opcional (inyectable)
class_name RecipeUnlockPolicy
extends RefCounted
func puede_desbloquear(receta: CraftingRecipe, ctx: Dictionary) -> bool:
	# ctx puede incluir snapshot de ProgressionManager (hitos/flags) sin acoplar a su API concreta
	return true

# En CraftingService:
# var _unlock: RecipeUnlockPolicy
func _conocer(rec_id: String, emitir := true) -> void:
	var receta: CraftingRecipe = _recetas.get(rec_id)
	if receta == null or rec_id in _conocidas: return
	if _unlock != null and not _unlock.puede_desbloquear(receta, _ctx_progresion()):
		return
	_conocidas.append(rec_id)
	if emitir: _emit_aprendida(receta)
```

**Impacto:** restaura separación de capas (hallazgo #2), hace explícito el contrato con M71 (hallazgo #5) y centraliza validación/reglas de disponibilidad.

## Limitaciones de esta auditoría
- No se ejecutaron pruebas de runtime ni validación en editor/escena; la integración efectiva puede diferir por wiring de escena o scripts fuera de `scripts/crafting/` no inspeccionados exhaustivamente.
- No se verificó el contenido completo de `data/balance/crafting.json` (ruta esperada por diseño difiere de la ubicación encontrada `data/balance/crafting.json` en árbol de datos; la carga real depende de `BalanceService`).
