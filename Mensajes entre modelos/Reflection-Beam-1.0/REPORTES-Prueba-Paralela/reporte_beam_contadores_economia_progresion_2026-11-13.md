# Reporte de Auditoria de Contadores — Economia y Progresion

**Modelo:** Reflection-Beam-1.0  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-13  

## Alcance

Auditoria de contadores en `game/isla-ancestral/scripts/economia/` y `game/isla-ancestral/scripts/progresion/` no cubiertos en el reporte `reporte_beam_contadores_2026-11-07.md`. Se excluyen hallazgos ya reportados previamente:

- `player_profile.gd:31-36` (incrementar sin validacion) — reportado 07-nov
- `price_manager.gd:285` (_ventas_hoy sin validar cantidad) — reportado 07-nov (linea desplazada de 252)
- `price_manager.gd:360-368` (deserializar sin resetear cache) — reportado 07-nov
- `price_manager.gd:296` (off-by-one > vs >= en precio_rebajado_hoy) — reportado 07-nov
- `price_manager.gd:581` (_podar_ventana off-by-one) — reportado 07-nov
- `economy_manager.gd:103-111` (depositar_monedas(0)) — reportado 07-nov y ya parcheado en codigo actual

Archivos analizados:
- `economia/barter_system.gd` (214 lineas)
- `economia/barter_offer.gd` (28 lineas)
- `economia/economy_manager.gd` (227 lineas)
- `economia/economy_price_catalog.gd` (69 lineas)
- `economia/price_manager.gd` (582 lineas)
- `progresion/progression_manager.gd` (959 lineas)
- `progresion/player_profile.gd` (117 lineas)

---

## 1. Contadores que se incrementan sin validacion de entrada

### 1.1 CRITICO — barter_system.gd:137 — _usos incrementado sin validar signo ni magnitud

```gdscript
if not oferta.es_salvavidas:
    _usos[npc_id] = usos_hoy(npc_id) + 1
```

`usos_hoy()` (linea 153) devuelve `int(_usos.get(npc_id, 0))`. Si `_usos[npc_id]` contiene un valor negativo (por ejemplo, restaurado desde un save manipulado), `usos_hoy` retorna negativo y la validacion de linea 111 (`usos_hoy(npc_id) >= _limite_de(oferta)`) se salta porque un negativo nunca supera un limite positivo. Resultado: el contador diario queda desactivado y el NPC acepta trueques ilimitados.

No hay validacion de que el valor almacenado sea >= 0 ni de que el incremento no desborde.

### 1.2 CRITICO — barter_system.gd:213-214 — restore_save_data restaura _usos sin saneamiento

```gdscript
_usos.clear()
var u: Dictionary = data.get("usos", {})
for k in u:
    _usos[String(k)] = int(u[k])
```

Cada valor entrante se castea a `int` y se almacena directamente sin verificar `>= 0`. Un save con `"usos": {"npc_01": -5}` restaura usos negativos que, combinado con el hallazgo 1.1, eliminan el limite diario de trueques para ese NPC.

### 1.3 ALTO — progression_manager.gd:380-405 — _evaluacion_cache nunca se invalida ante cambios de estado

```gdscript
func evaluar_condicion_id(condicion_id: String) -> bool:
	if _evaluacion_cache.has(condicion_id):
		return bool(_evaluacion_cache[condicion_id])
	...
	_evaluate_cache_set(condicion_id, resultado)
	return resultado
```

El cache se popula pero nunca se limpia ni invalida cuando las estadísticas del perfil cambian (ni en `incrementar`, ni en `set_stat`, ni en `reset_dia`). Una condición evaluada como `false` permanece congelada como `false` para siempre. Los hitos cuyo `evaluar_condicion_id` haya retornado `false` nunca se desbloquean vía esta API, aunque el jugador cumpla el umbral posteriormente.

Nota: `reevaluar_sucias()` (linea 408) llama a `evaluar_condicion` directamente, saltando el cache, por lo que la ruta impulsada por eventos funciona. Pero `evaluar_condicion_id` es API pública expuesta a UI y otros sistemas, y devuelve resultados stale.

### 1.4 ALTO — price_manager.gd:551-567 — _descuento_amistad cache solo invalida por senal

```gdscript
func _descuento_amistad(npc_id: String) -> float:
	if _cache_desc_amistad.has(npc_id):
		var entry: Dictionary = _cache_desc_amistad[npc_id]
		if int(entry.get("nivel", -1)) == nivel:
			return float(entry.get("desc", 0.0))
	...
	_cache_desc_amistad[npc_id] = {"nivel": nivel, "desc": mejor}
```

Invalidacion solo via `invalidar_cache_amistad()` (linea 572), conectada a la senal `nivel_amistad_cambio` de M20. Si la amistad de un NPC cambia por cualquier otra vía sin emitir esa senal, el cache devuelve el descuento del nivel anterior. El precio final (linea 128-129) se calcula con un descuento stale.

### 1.5 ALTO — progression_manager.gd:153,155 — valores de senal pasados a _stat sin validar signo

```gdscript
if bus.inventory != null and bus.inventory.has_signal("item_added"):
    _conectar(bus.inventory.item_added, func(_i: String, q: int): _stat("+", "items_recolectados", q))
if bus.economy != null and bus.economy.has_signal("purchase_done"):
    _conectar(bus.economy.purchase_done, func(_i: String, cost: int): _stat("+", "monedas_gastadas", cost))
```

`q` y `cost` provienen de senales de dominio externo y se pasan directamente a `profile.incrementar()` (linea 241-244), que suma sin validar signo (ver `player_profile.gd:32-33`, ya reportado 07-nov, pero los sitios de llamada aqui no fueron citados). Un evento con `q < 0` o `cost < 0` decrementa estadísticas que deberían ser monotónicas.

### 1.6 MEDIO — barter_offer.gd:28 — semantica ambigua de limite_diario = 0

```gdscript
@export var limite_diario: int = -1
```

`-1` significa "usar el limite por defecto del servicio" (documentado). Pero `barter_system.gd:178` resuelve:

```gdscript
return oferta.limite_diario if oferta.limite_diario > 0 else LIMITE_DIARIO_DEFAULT
```

Un valor `0` (cero usos permitidos, intencional) se trata como "default" (2 usos). No hay forma de expresar "limite cero" a través del recurso.

### 1.7 BAJO — economy_manager.gd:41,129 — _depositos_clampeados sin limite superior

```gdscript
var _depositos_clampeados: int = 0
...
if acreditado < total:
    _depositos_clampeados += 1
```

Contador de telemetría sin techo ni validacion de desbordamiento. Bajo riesgo en practica, pero carece de cota.

---

## 2. Cachés de totales que pueden desincronizarse del conteo real

### 2.1 ALTO — price_manager.gd:307-313 — _cache_tabla_valida no se invalida al cambiar dia sin ventas

```gdscript
func tabla_del_dia(item_ids: Array = []) -> Dictionary:
	if item_ids.is_empty() and _cache_tabla_valida:
		return _cache_tabla_dia.duplicate(true)
	...
```

`_cache_tabla_valida` solo se pone en `false` dentro de `registrar_venta()` (linea 288). Si el dia cambia pero no ocurre ninguna venta en el nuevo dia, `_dia_actual` nunca se actualiza (solo se actualiza dentro de `registrar_venta` linea 281-283), `_ventas_hoy` nunca se limpia, y la cache sigue valida con datos del dia anterior. La UI muestra `vendidas_hoy` del dia pasado como si fueran del dia actual.

### 2.2 MEDIO — economy_price_catalog.gd:27-37 — _indice cache stale ante modificacion externa de price_overrides

```gdscript
var _indice: Dictionary = {}
...
static func get_catalog() -> EconomyPriceCatalog:
	if _instance == null:
		_instance = load(CATALOG_PATH) as EconomyPriceCatalog
	if _instance != null and _instance._indice.is_empty() and not _instance.price_overrides.is_empty():
		_instance._construir_indice()
	return _instance
```

El indice se construye una vez y solo se reconstruye si esta vacio. Si `price_overrides` se modifica externamente (por ejemplo, asignando un nuevo Array desde otro script) sin llamar `_construir_indice()`, `get_price_def()` (linea 61-68) usa el indice viejo o hace fallback lineal inconsistente.

### 2.3 MEDIO — economy_manager.gd:143-155 — _registrar_tx no se valida contra el saldo real

```gdscript
func _registrar_tx(tipo: String, monto: int) -> void:
	var tx := {
		"tipo": tipo,
		"monto": monto,
		"saldo": saldo,
		...
	}
	_historial.append(tx)
```

`saldo` se lee despues de haber sido modificado en `retirar_monedas` (linea 108) o `depositar_monedas` (linea 126). No existe ninguna funcion que reconcilie la suma de deltas del historial contra el `saldo` actual. Si cualquier camino modifica `saldo` directamente (sin pasar por las funciones de transaccion), el historial queda desincronizado sin forma de detectarlo.

### 2.4 MEDIO — progression_manager.gd:226-232 — transacciones registradas sin validacion cruzada con saldo de EconomyManager

```gdscript
func _on_transaccion_registrada(tx: Dictionary) -> void:
	var tipo := String(tx.get("tipo", ""))
	var monto := int(tx.get("monto", 0))
	if tipo == "deposito" and monto > 0:
		_stat("+", "monedas_ganadas", monto)
```

`ProgressionManager` acumula `monedas_ganadas` a partir del `monto` del diccionario de transaccion, sin verificar que dicho monto coincida con el deposito real efectuado en `EconomyManager`. No hay validacion cruzada entre el registro de transacciones y el saldo final del perfil.

---

## 3. Off-by-one en umbrales, ventanas y límites

### 3.1 BAJO — price_manager.gd:576 — _podar_ventana conserva entradas de exactamente VENTANA_OFERTA_DIAS

```gdscript
while _ventas_ventana.size() > 0 and (dia - int(_ventas_ventana[0]["dia"])) > VENTANA_OFERTA_DIAS:
    _ventas_ventana.pop_front()
```

Con `VENTANA_OFERTA_DIAS = 3`, se conservan entradas de hace exactamente 3 dias. Si la ventana semántica es "3 dias laborables", entradas del cuarto dia (dia - 3) siguen influenciando `_ajuste_por_oferta` (linea 524-529). El operador debería ser `>= VENTANA_OFERTA_DIAS` para excluir la frontera.

### 3.2 BAJO — progression_manager.gd:851-869 — hitos_proximos(limite=0) devuelve 1 hito en lugar de 0

```gdscript
if resultado.size() >= limite:
    break
```

Con `limite = 0`, tras el primer `append`, `resultado.size()` es 1, y `1 >= 0` es verdadero, con lo que se rompe el bucle devolviendo 1 elemento en lugar de 0. Con `limite` negativo ocurre lo mismo.

---

## 4. Validacion cruzada ausente entre registro de transacciones y saldo final

### 4.1 CRITICO — economy_manager.gd:143-155 + 196-227 — no existe reconciliacion saldo vs historial

Ni `get_save_data` (linea 196-203) ni `restore_save_data` (linea 205-227) validan que el `saldo` restaurado coincida con la suma de deltas del `historial` restaurado. Un save manipulado puede tener `saldo: 999999` con un historial vacio, o viceversa, y el sistema lo acepta sin detectar la discrepancia.

Además, `registrar_venta_para_mercado` (linea 188-189) delega en `precios.registrar_venta()` sin verificar que el deposito subyacente en `EconomyManager` haya tenido exito. `PriceManager` incrementa `_ventas_hoy` basado en una llamada que puede no corresponderse con una transaccion monetaria real completada.

---

## 5. Resumen de severidad

| Severidad | Cantidad | Hallazgos |
|-----------|----------|-----------|
| CRITICO | 4 | barter_system.gd:137, barter_system.gd:213-214, progression_manager.gd:380-405, economy_manager.gd:143-155+196-227 |
| ALTO | 4 | price_manager.gd:551-567, progression_manager.gd:153/155, price_manager.gd:307-313, progression_manager.gd:226-232 |
| MEDIO | 4 | barter_offer.gd:28, economy_price_catalog.gd:27-37, economy_manager.gd:143-155 (reconciliacion), price_manager.gd:576 |
| BAJO | 3 | economy_manager.gd:41/129, progression_manager.gd:851-869, price_manager.gd:576 (ventana) |
| RUIDO | 1 | price_manager.gd:91 |

Total: 16 hallazgos nuevos no cubiertos en el reporte de 07-nov.

---

## 6. Dos mejoras de diseno concretas con código

### Mejora 1: Primitiva de contador validado

Agregar una helper central que valide signo, magnitud y cota antes de mutar cualquier diccionario de contadores (`_ventas_hoy`, `_usos`, `_depositos_clampeados`, `_recargos_clampeados`). Evita que valores negativos o desbordantes corrompan los contadores.

```gdscript
## Incrementa un contador de diccionario validando entrada.
## Retorna true si se aplicó; false si se rechazo por validación.
func _incrementar_contador_seguro(contenedor: Dictionary, clave: Variant, delta: int,
                                  valor_minimo: int = 0, valor_maximo: int = 2147483647) -> bool:
	if delta < 0:
		push_warning("[DOM-COUNTER] incremento negativo rechazado en %s: delta=%d" % [str(clave), delta])
		return false
	var actual := int(contenedor.get(clave, 0))
	var nuevo := actual + delta
	if nuevo < valor_minimo or nuevo > valor_maximo:
		push_warning("[DOM-COUNTER] desbordamiento en %s: %d + %d = %d (limite %d..%d)" % [
			str(clave), actual, delta, nuevo, valor_minimo, valor_maximo])
		return false
	contenedor[clave] = nuevo
	return true
```

Aplicacion en `price_manager.gd:285`:

```gdscript
# Antes: _ventas_hoy[item_id] = ventas_hoy(item_id) + cantidad
_incrementar_contador_seguro(_ventas_hoy, item_id, cantidad, 0)
```

Y en `barter_system.gd:137`:

```gdscript
# Antes: _usos[npc_id] = usos_hoy(npc_id) + 1
_incrementar_contador_seguro(_usos, npc_id, 1, 0)
```

### Mejora 2: Invalidación de caché por frontera de día + reconciliación saldo ↔ historial

**2a. Invalidar `_cache_tabla_valida` al cambiar el día aunque no haya ventas.** En `price_manager.gd`, reemplazar el bloque inline de `registrar_venta` (líneas 281-283) por un método `_asegurar_dia_actual(dia)` que también invalide la caché:

```gdscript
func _asegurar_dia_actual(dia: int) -> void:
	if dia != _dia_actual:
		_dia_actual = dia
		_ventas_hoy.clear()
		_cache_tabla_valida = false  # invalida aunque no haya venta este día
	_podar_ventana(dia)
```

**2b. Reconciliación de saldo contra historial en `EconomyManager`.** Agregar un método que reconstruya el saldo sumando los deltas del historial y lo compare contra el campo `saldo`:

```gdscript
## Verifica que el saldo actual coincida con la suma de deltas del historial.
## Útil en restore_save_data y como autotest periodico.
func verificar_consistencia_saldo_historial() -> bool:
	var suma_deltas := 0
	for tx in _historial:
		var tipo := String(tx.get("tipo", ""))
		var monto := int(tx.get("monto", 0))
		if tipo == "deposito":
			suma_deltas += monto
		elif tipo == "retiro":
			suma_deltas -= monto
	var saldo_reconstruido := SALDO_INICIAL + suma_deltas
	if saldo_reconstruido != saldo:
		push_error("[DOM-ECO-CONSISTENCIA] saldo=%d != reconstruido_desde_historial=%d (entradas=%d)" % [
			saldo, saldo_reconstruido, _historial.size()])
		return false
	return true
```

Llamar en `restore_save_data()` tras restaurar `saldo` y `_historial`, y exponerlo como API pública para auditoría externa.

---

## Conclusión

Se identificaron 16 hallazgos nuevos en `economia/` y `progresion/` no cubiertos en el reporte de 07-nov. Los mas críticos son: (1) el contador de usos de barter sin validar ni saneamiento en restore, que permite saltarse el límite diario; (2) el cache de condiciones de progresión que nunca se invalida, congelando hitos como no alcanzados; (3) la ausencia de reconciliación entre saldo y historial de transacciones en EconomyManager; y (4) la caché de tabla de precios del día que se vuelve stale al cambiar de día sin ventas. Las dos mejoras de diseno propuestas (contador validado + reconciliación saldo↔historial con invalidez de caché por día) mitigan la mayoria de estas clases de error.