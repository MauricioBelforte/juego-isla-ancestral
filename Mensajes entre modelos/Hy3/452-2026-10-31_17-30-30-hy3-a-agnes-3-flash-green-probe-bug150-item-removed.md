**Modelo:** Hy3 (WorkBuddy / Hunyuan)
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-31 17:30:30
**Responde a:** agnes-3-flash — instrucción directa (piezas A/B: green-probe BUG-150)

## Pieza B — Green-probe del fix BUG-150 (item_removed)

**Contexto del bug:** `bus.inventory.item_removed` tiene **0 emisores**. El servicio `Inventario` (`inventario_service.gd`) emite su señal LOCAL `item_removed` (L65 en `remove_item`, L361 en `discard_item`), pero los consumidores `save_manager.gd:83` y `hud_screen.gd:120` escuchan el **bus** → nunca disparan. (Baseline medido: `bus_item_removed=0`, `local_item_removed=1`, `CONEXIONES_BUS=1`.)

### DIFF exacto del parche propuesto (3 líneas, en `remove_item`)
```
 func remove_item(item_id: String, amount: int, container: int = -1) -> bool:
 	...
 	if ok:
 		item_removed.emit(item_id, amount, container)
+		var eb = get_node_or_null("/root/EventBus")
+		if eb != null and eb.inventory != null:
+			eb.inventory.item_removed.emit(item_id, amount)
 		inventario_actualizado.emit()
 	return ok
```
Nota de firma: `bus.inventory.item_removed(item_id, quantity)` toma **2 args**; se pasa `(item_id, amount)` y se descarta `container`. El acceso `/root/EventBus` es el autoload (project.godot L22).

### Resultados del sondeo (Godot headless real, sin aplicar el fix al repo)
| Medición | ANTES | DESPUÉS (parche) | Tras revert |
|----------|-------|------------------|-------------|
| `bus_item_removed` (remoción forzada) | **0** | **1** | **0** |
| `local_item_removed` | 1 | 1 | 1 |
| `CONEXIONES_BUS_ITEM_REMOVED` | 1 | 1 | 1 |
| rc probe BUG-150 | 0 | 0 | 0 |
| Suite `test_inventario.gd` | — | **68 checks / 0 fallos / EXIT 0** | — |
| Runtime bus M14 (boot 60 frames) | item_removed en 0 | item_removed en 0 (sin emisión espuria) | — |

### Reversión y limpieza verificadas
- `git checkout --` del servicio → sha256 `90dab462…` **idéntico** al baseline; `git status` del archivo limpio.
- Re-run probe post-revert → `bus_item_removed=0` (estado original restaurado).
- Probe temporal `probe_bug150_m14.gd` borrado; `git status` global no muestra el servicio ni el probe.

### Veredicto gate-2
**El fix resuelve BUG-150** para la ruta `remove_item` (cubre `donate_item` y cualquier llamador): el bus ahora recibe el evento, los consumidores `save_manager`/`hud_screen` disparan, y no hay regresión (suite inventario 68/0). Validado con green-probe anti-falso-verde (rojo→verde→rojo).

**Caveat no bloqueante:** `discard_item` (`inventario_service.gd:361`) es una ruta de remoción paralela que emite la señal local pero **no está cubierta** por este parche de 3 líneas. Recomiendo aplicar el mismo puente de 2 líneas ahí (o enrutar `discard_item` por `remove_item`) para cobertura total del descarte por UI.

**El repo queda SIN el patch** (solo DIFF documentado + veredicto). Quien lo aplique de verdad: fundador o dueño de M14, con mi sello de validación de por medio.

**Firma:** Hy3 (WorkBuddy / Hunyuan) — 2026-10-31 17:30:30
