# Reporte: Sistemas de progresión (`scripts/progresion/`)
**Modelo:** Glyph Cluster  
**Plataforma:** (no anunciada)  
**Fecha:** 2026-11-13  
**Alcance:** análisis estático de `game/isla-ancestral/scripts/progresion/` y artefactos de soporte directo (`data/progresion/hitos.json`, `project.godot`, `scripts/core/event_bus.gd`, `scripts/stream/progress_calculator.gd`). Sin modificaciones de código de juego.

## Resumen ejecutivo
El sistema de progresión está bien orientado a datos (catálogo JSON, indexación por estadística sucia, evaluación diferida) pero presenta riesgos de **otorgamiento incorrecto de hitos**, **contratos runtime incompletos para hitos de “primera vez” y dependencias no-stat**, **falta de validación de entradas numéricas** y **desincronización entre estado persistido/caché y contadores reales**.

---

## 1) Contratos de misión/hitos: definición y conexión al runtime

### Hallazgos

| Severidad | Hallazgo | Evidencia | Impacto |
|---|---|---|---|
| **Alta** | Contrato de hitos “primera vez” definido en catálogo pero sin puente de activación en runtime visible en el manager/perfil. `primera_vez` depende de que la actividad deje de ser “primera” (`not profile.primera_vez(actividad_id)`), pero `ProgressionManager` no llama `PlayerProfile.marcar_primera_vez` ni reacciona a eventos que marquen actividades; los hitos `hito_primera_venta` y `hito_ruina_restaurada` quedan huérfanos si ningún otro sistema los integra explícitamente. | `progression_manager.gd:308-310`, `785-786`; `player_profile.gd:59-65`; `hitos.json:109-118`, `442-455` | Hitos de contrato “primera vez” pueden no otorgarse nunca o depender de integración implícita no garantizada. |
| **Alta** | Dependencias de tipo `hito_previo`/condiciones sin `stat_id` no se indexan para reevaluación por eventos. El indexador solo registra hojas con `stat_id` (recurre compuestas, pero ignora hojas sin estadística). No existe disparador que reevalúe dependientes cuando se alcanza un hito previo. | `progression_manager.gd:109-124`, `791-808`, `248-253` | Hitos encadenados por prerequisito lógico (no por contador) pueden quedar sin evaluar aunque el prerequisito se cumpla, salvo reevaluación global manual. |
| **Media** | Conexión a `ToolController` es frágil: intenta autoload en `_ready` y expone `conectar_tool_controller(tc)` para nodos de escena, pero si la escena no realiza la conexión el cambio de herramienta no alimenta `nivel_herramienta_cambio`/stats desde este flujo. | `progression_manager.gd:184-199`, `202-221` | Hitos o lógica dependiente de equipo/nivel de herramienta pueden no dispararse en escenas que omitan el cableado explícito. |
| **Media** | Integración runtime parcial y heterogénea (EventBus dominios + autoloads directos `EconomyManager`/`Barter`) sin contrato unificado de descubrimiento/registro; si una señal o dominio no existe se degrada con warning pero no hay verificación de cobertura mínima de contratos críticos. | `progression_manager.gd:147-183`, `224-239`; `event_bus.gd:15-45`, `160-199`; `project.godot:22-79` | Riesgo de progresión silenciosamente incompleta según composición de escena/autoloads. |
| **Baja** | `hitos_proximos()` filtra solo tipos cuantificables (`stat_min`, `dias_jugados`, `riqueza_acumulada`, `primera_vez`) y omite compuestas/sellos/capítulos, lo que puede desalinear el contrato de “sugeridor de metas” con el catálogo real. | `progression_manager.gd:849-870`; `hitos.json` (hitos compuestos/historia) | UI/consumidores pueden mostrar metas incompletas o sesgadas. |

### Observación de contrato (catálogo ↔ runtime)
- Catálogo cargado desde `res://data/progresion/hitos.json` y validado en arranque con logging/warnings (`_cargar_catalogo`, `_validar_catalogo_en_ruta`), pero la validación no es bloqueante en runtime de juego. `progression_manager.gd:29`, `87-106`, `528-658`.
- Registro como proveedor de guardado condicionado a `SaveManager.register_provider` (duck-typing), coherente con tolerancia a fallos. `progression_manager.gd:908-911`; autoload en `project.godot:30`, `79`.

---

## 2) Umbrales de desbloqueo: validación antes de otorgar hitos

### Hallazgos

| Severidad | Hallazgo | Evidencia | Impacto |
|---|---|---|---|
| **Crítica** | `_reevaluar(stat_id)` otorga el hito directamente (`marcar_hito`) sin comprobar que la condición del hito sea verdadera en ese momento. Solo verifica “no alcanzado” e indexación por estadística sucia. | `progression_manager.gd:248-253`, `791-808` | Puede conceder hitos y recompensas/desbloqueos indebidamente (p.ej. hitos compuestos indexados por una subcondición ya satisfecha mientras otra no, o llamadas/reuso futuro del flujo). Rompe el invariante “umbral cumplido ⇒ hito otorgado”. |
| **Alta** | `marcar_hito()` es idempotente respecto a duplicados pero no es un guardián de condición: asume que el llamador ya validó el umbral. `reevaluar_sucias()` sí evalúa (`evaluar_condicion(cond)`), creando dos rutas con garantías distintas. | `progression_manager.gd:408-416`, `791-808` | Inconsistencia de contrato interno: el camino por evento incremental es menos seguro que el camino de reevaluación masiva. |
| **Media** | Umbrales negativos se detectan en validaciones de catálogo, pero no se rechazan/enfuerzan al evaluar/otorgar en runtime; condiciones inválidas devuelven `false` en varios casos, mas no existe “fail-fast” ni cuarentena del hito. | `progression_manager.gd:528-605`, `660-697`, `700-750` | Datos corruptos o ediciones manuales pueden producir comportamiento ambiguo (hitos imposibles silenciosos, diagnósticos tardíos). |
| **Media** | `activar_desbloqueo` y procesamiento de recompensas no validan formato/semántica (`unlock_id` vacío, `tipo` desconocido, `valor` vacío, duplicados semánticos). | `progression_manager.gd:800-808`, `887-892` | Desbloqueos/títulos inconsistentes en estado persistido y señales emitidas con payloads pobres. |

---

## 3) Validación de entrada en funciones de progresión (negativos, NaN, off-by-one)

### Hallazgos

| Severidad | Hallazgo | Evidencia | Impacto |
|---|---|---|---|
| **Alta** | `PlayerProfile.incrementar` y `set_stat` aceptan valores sin saneamiento: no rechazan negativos, `NaN`, `INF` ni tipos inesperados; `incrementar` castea a `float` y acumula directamente. | `player_profile.gd:31-41` | Contadores corruptos (decrementos accidentales, propagación de NaN/INF) ⇒ evaluaciones erróneas de umbrales y desincronización permanente tras guardado/carga. |
| **Media** | `_stat()` en el manager delega incrementos sin clamp/validación; varios handlers propagan montos/valores de señales externas (`purchase_done` → `monedas_gastadas`, `item_added` cantidad, transacciones económicas) sin normalización defensiva. | `progression_manager.gd:153-165`, `224-244` | Un emisor malformado o negativo puede distorsionar estadísticas y disparar/no disparar hitos indebidamente. |
| **Media** | `ProgressCalculator` valida rango de progreso final pero no valida entradas: `peso_total`/pesos negativos o no enteros coherentes pueden producir semántica confusa antes del `clampf`; `calcular_peso_total` suma sin floor/abs. | `progress_calculator.gd:13-35` | Progreso de streaming/UI inconsistente (especialmente ante datos de cola corruptos). |
| **Baja** | Comparaciones de umbral usan `>=` (correcto para “al menos N”) y condiciones de días/jugados/niveles convierten a `int`; no se observa off-by-one evidente en evaluadores principales. | `progression_manager.gd:277`, `710`, `714`, `720`, etc.; `hitos.json` | Sin off-by-one funcional detectado en revisión estática; riesgo residual bajo. |

---

## 4) Desincronización entre contadores internos y hitos otorgados

### Hallazgos

| Severidad | Hallazgo | Evidencia | Impacto |
|---|---|---|---|
| **Alta** | Caché de evaluación (`_evaluacion_cache`, `evaluar_condicion_id`) no se invalida ante cambios de estadísticas, tiempo, historia, desbloqueos ni carga de partida. Es write-once por clave (hasta eviction simple). | `progression_manager.gd:43-47`, `378-406` | Lecturas de condición obsoletas (falsos negativos/positivos según primer cálculo) y divergencia entre estado real y APIs que consulten la caché. |
| **Alta** | `restore_save_data` restaura hitos, desbloqueos, stats y títulos pero no reconcilia: no reevalúa hitos pendientes que ya cumplen condición con las stats restauradas, ni depura estados imposibles/huérfanos, ni limpia caché. Emite resumen sin recomputar. | `progression_manager.gd:933-958` | Desfase entre contadores y `hitos_alcanzados` tras cargar, migrar catálogo o corregir datos; progreso “perdido” o inconsistente. |
| **Media** | Otorgamiento por `_reevaluar` sin verificar condición (hallazgo 2.1) también es vector de desincronización: puede marcar logrado un hito cuyo predicado global no es cierto. | `progression_manager.gd:248-253` | Estado de hitos diverge de las condiciones fuente de verdad. |
| **Media** | Indexación solo por `stat_id` impide que cambios no-stat (logro de prerequisito, eventos narrativos no traducidos a stats indexadas, colecciones actualizadas por vías no mapeadas) disparen reevaluación dirigida de dependientes. | `progression_manager.gd:109-124`, `901-903` | Hitos alcanzables en datos pero no materializados en `_hitos_alcanzados` sin reevaluación global. |
| **Baja** | `reevaluar_sucias()` barre todos los hitos no alcanzados (O(n)) y se ofrece como mecanismo seguro, pero no hay política explícita de cuándo invocarlo para cerrar brechas; el sistema confía en eventos incrementales. | `progression_manager.gd:408-416` | Riesgo operativo de divergencia acumulada si se pierden eventos o rutas no indexadas. |

---

## 5) Hallazgos adicionales relevantes (contexto de robustez)

| Severidad | Hallazgo | Evidencia |
|---|---|---|
| **Baja** | `_hitost` (typo/estado interno) funciona pero reduce claridad de mantenimiento; no afecta lógica directa. | `progression_manager.gd:36`, `88`, `95-105` |
| **Baja** | `progreso_parcial` solo soporta `stat_min`; otros tipos retornan binario logrado/requerido 0..1, lo que limita observabilidad de progreso real para UI/diagnóstico. | `progression_manager.gd:874-882` |
| **Info** | Validación estática/dinámica de condiciones imposibles existe y es útil, pero la dinámica usa heurísticas amplias (`umbral > actual*10 + 100/1000`) que pueden dar falsos positivos/negativos. | `progression_manager.gd:420-516` |

---

## 6) Priorización sugerida
1. **P0 (inmediato):** exigir evaluación de condición antes de `marcar_hito` en todas las rutas (`_reevaluar`, APIs públicas/puentes) y unificar en un único punto de otorgamiento seguro.
2. **P1:** saneamiento estricto de entradas numéricas en `PlayerProfile` y bordes del manager; invalidación/reconciliación de caché y estado al cambiar stats/cargar.
3. **P1:** cerrar contratos runtime de `primera_vez`, `hito_previo` y conexiones obligatorias (ToolController/consumidores), con telemetría de cobertura.
4. **P2:** ampliar indexación/disparadores para condiciones no-stat y mejorar validación bloqueante en carga.

---

## 7) Mejoras de diseño concretas (con código)

### Mejora 1 — Otorgamiento seguro unificado + reevaluación correcta por condición
**Objetivo:** garantizar que ningún hito se otorgue sin cumplir su predicado actual y que las dependencias lógicas (`hito_previo`, compuestas) puedan reevaluarse cuando cambian hechos no-stat.

```gdscript
# progression_manager.gd (diseño propuesto)

## Punto único de otorgamiento: SIEMPRE valida condición.
func intentar_otorgar_hito(milestone_id: String) -> bool:
	if hito_alcanzado(milestone_id) or not _hitost.has(milestone_id):
		return false
	var cond: Dictionary = _hitost[milestone_id].get("condicion", {})
	if not evaluar_condicion(cond):
		return false
	return _otorgar_hito_validado(milestone_id)

func _otorgar_hito_validado(milestone_id: String) -> bool:
	if hito_alcanzado(milestone_id) or not _hitost.has(milestone_id):
		return false
	_hitos_alcanzados.append(milestone_id)
	var nombre := String(_hitost[milestone_id].get("nombre", milestone_id))
	var recompensas: Array = _hitost[milestone_id].get("recompensas", [])
	_invalidar_cache_por_hito(milestone_id)
	progreso_hito_alcanzado.emit(milestone_id, nombre, recompensas.duplicate(true))
	_log_dom_hito("%s (%s)" % [milestone_id, nombre])
	_aplicar_recompensas(recompensas, milestone_id)
	# Re-evaluar dependientes lógicos (p.ej. hitos con hito_previo)
	_reevaluar_dependientes_de_hito(milestone_id)
	return true

## Reemplazo seguro de la ruta incremental.
func _reevaluar(stat_id: String) -> void:
	if not _condiciones_por_hito.has(stat_id):
		return
	_invalidar_cache_relacionada(stat_id)
	for hito_id in _condiciones_por_hito[stat_id]:
		intentar_otorgar_hito(String(hito_id))

## API pública endurecida.
func marcar_hito(milestone_id: String) -> bool:
	return intentar_otorgar_hito(milestone_id)

## Indexación adicional para dependencias por hito previo.
func _indexar_condicion(hito_id: String, cond: Dictionary) -> void:
	if cond.is_empty():
		return
	var tipo := String(cond.get("tipo", ""))
	match tipo:
		"compuesta":
			for hijo in cond.get("hijos", []):
				_indexar_condicion(hito_id, hijo)
		"hito_previo":
			var ref := String(cond.get("milestone_id", ""))
			if ref != "":
				if not _condiciones_por_hito.has("__hito__:" + ref):
					_condiciones_por_hito["__hito__:" + ref] = []
				var lista: Array = _condiciones_por_hito["__hito__:" + ref]
				if not lista.has(hito_id):
					lista.append(hito_id)
		_:
			var stat := String(cond.get("stat_id", ""))
			if stat != "":
				if not _condiciones_por_hito.has(stat):
					_condiciones_por_hito[stat] = []
				var lista2: Array = _condiciones_por_hito[stat]
				if not lista2.has(hito_id):
					lista2.append(hito_id)

func _reevaluar_dependientes_de_hito(hito_prev: String) -> void:
	var key := "__hito__:" + hito_prev
	if not _condiciones_por_hito.has(key):
		return
	for dependiente in _condiciones_por_hito[key]:
		intentar_otorgar_hito(String(dependiente))
```

**Beneficios:** elimina otorgamientos por asunción, unifica invariantes, y habilita cadenas `hito_previo` sin reevaluación global ciega.

### Mejora 2 — Saneamiento de entradas + reconciliación/caché coherente en carga
**Objetivo:** evitar corrupción numérica (negativos/NaN/INF), mantener caché consistente y reconciliar contadores vs hitos otorgados tras restaurar partida.

```gdscript
# player_profile.gd (diseño propuesto)

func _sanear_delta(cantidad: Variant) -> float:
	var v := float(cantidad)
	if is_nan(v) or is_inf(v):
		push_warning("[PlayerProfile] delta inválido (NaN/INF) ignorado")
		return 0.0
	# Política: stats de progreso son monotónicas; rechazar negativos.
	if v < 0.0:
		push_warning("[PlayerProfile] delta negativo ignorado: %s" % str(cantidad))
		return 0.0
	return v

func incrementar(stat_id: String, cantidad: int = 1) -> void:
	if stat_id.is_empty():
		return
	var delta := _sanear_delta(cantidad)
	if delta == 0.0:
		return
	_totales[stat_id] = float(_totales.get(stat_id, 0.0)) + delta
	_dia[stat_id] = float(_dia.get(stat_id, 0.0)) + delta
	_sucias[stat_id] = true
	if stat_id == "monedas_ganadas":
		_contribucion += delta

func set_stat(stat_id: String, valor: Variant) -> void:
	if stat_id.is_empty():
		return
	match typeof(valor):
		TYPE_INT, TYPE_FLOAT:
			var v := float(valor)
			if is_nan(v) or is_inf(v):
				push_warning("[PlayerProfile] set_stat inválido (NaN/INF): %s" % stat_id)
				return
			_totales[stat_id] = v
			_sucias[stat_id] = true
		_:
			# Permitir solo tipos explícitamente soportados por diseño; ignorar el resto.
			push_warning("[PlayerProfile] set_stat tipo no soportado para %s" % stat_id)

# progression_manager.gd (diseño propuesto)

func _invalidar_cache_total() -> void:
	_evaluacion_cache.clear()

func _invalidar_cache_relacionada(_clave_o_stat: String) -> void:
	# Estrategia simple y segura: invalidación total ante cambios de estado.
	# (Optimizable luego con mapa condición->dependencias si hace falta.)
	_evaluacion_cache.clear()

func reconciliar_tras_carga() -> Dictionary:
	_invalidar_cache_total()
	var otorgados := 0
	# Reintenta otorgar hitos pendientes que ya cumplen condición con stats actuales.
	for hito_id in _hitost:
		if not hito_alcanzado(hito_id):
			if intentar_otorgar_hito(hito_id):
				otorgados += 1
	_log_info("Reconciliación post-carga: +" + str(otorgados) + " hitos")
	return {"otorgados": otorgados, "hitos_total": _hitos_alcanzados.size()}

func restore_save_data(data: Dictionary) -> void:
	# ... restauración actual de hitos/desbloqueos/profile/títulos ...
	_titulos.clear()
	var tit: Dictionary = data.get("titulos", {})
	for k in tit:
		_titulos[String(k)] = String(tit[k])
	var res := reconciliar_tras_carga()
	progreso_resumen_cargado.emit(_hitos_alcanzados.size(), _desbloqueos.size())
	_log_info("Progreso restaurado: %d hitos, %d desbloqueos, %d títulos (reconciliados +%d)" % [
		_hitos_alcanzados.size(), _desbloqueos.size(), _titulos.size(), int(res.get("otorgados", 0))
	])
```

**Beneficios:** reduce corrupción silenciosa de contadores, evita lecturas stale de caché y alinea el estado otorgado con los umbrales reales tras cargar o migrar datos.

---

## Limitaciones del análisis
- Revisión estática sin ejecución en Godot runtime; no se verificaron emisiones reales de señales en escenas.
- No se auditaron consumidores externos completos (M53/M72/UI, escenas que deban invocar `conectar_tool_controller`, sistemas que marquen “primera vez”) más allá de referencias observadas.
- `scripts/progresion/` incluye scripts de test/debug (`test_*.gd`, `debug_tc.gd`) no analizados en profundidad por estar fuera del núcleo de runtime.

## Conclusión
El núcleo de progresión tiene una base sólida, pero hoy depende de supuestos implícitos en rutas críticas (validación previa al otorgamiento, cableado de eventos, monotonicidad de datos). Aplicar otorgamiento condicionado unificado, saneamiento de entradas y reconciliación/invalidación de caché cerraría los principales vectores de error lógico y desincronización identificados.
