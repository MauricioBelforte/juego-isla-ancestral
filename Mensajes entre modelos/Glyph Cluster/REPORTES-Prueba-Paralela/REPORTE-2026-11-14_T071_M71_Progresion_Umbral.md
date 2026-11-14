# Reporte de auditoria T-071 — M71 Progresion: validacion de umbral en _reevaluar()
# Proyecto: Isla Ancestral (Godot 4.7)

**Modelo:** Glyph Cluster (modelo de arquitectura de sistemas Godot)
**Plataforma:** Kilo Code
**Fecha:** 2026-11-14
**Alcance:** scripts/progresion/progression_manager.gd (rutas de otorgamiento de hitos), scripts/postgame/postgame_manager.gd, scripts/logros/achievement_service.gd.
**Regla aplicada:** no se escribio codigo del juego; solo supervisa y valida. Incluye codigo conceptual SOLO como propuesta de diseno, sin tocar el juego.

---

## Resumen ejecutivo

Se confirman los hallazgos del reporte previo (2026-11-13): `_reevaluar()` en `progression_manager.gd:248-253` otorga el hito directamente via `marcar_hito()` sin comprobar que la condicion del hito sea verdadera en ese momento. Solo verifica "no alcanzado" (`hito_alcanzado == false`) e indexacion por estadistica sucia. Esto rompe el invariante "umbral cumplido => hito otorgado": un hito puede marcarse alcanzado aunque su condicion no se cumpla.

Se identificaron **dos rutas inseguras** (otorgamiento sin validacion de condicion) y **dos rutas seguras** (validan condicion antes de marcar_hito). Se documentan a continuacion con archivo:linea, severidad y accionable.

---

## Metodo de revision

1. Lectura de `progression_manager.gd:248-253` (`_reevaluar`) y `:791-808` (`marcar_hito`).
2. Lectura de `progression_manager.gd:408-416` (`reevaluar_sucias`) y `:380-389` (`evaluar_condicion_id`) para confirmar la ruta segura.
3. Lectura de `postgame_manager.gd:225-234` (`_marcar_hito_derivado`) como ruta puente de otorgamiento.
4. Lectura de `achievement_service.gd:129-154` y `:212-222` (`evaluar_todos`) para confirmar que M72 usa `evaluar_condicion` (valida) y solo reacciona a la senal `progreso_hito_alcanzado` de M71 (no otorga hitos directamente).
5. Busqueda de todas las referencias a `marcar_hito` y `_reevaluar` en scripts/ para descartar otras rutas de otorgamiento.

---

## Hallazgos

### P-01 — _reevaluar() otorga hito sin validar condicion (defecto F1)
**archivo:linea:** scripts/progresion/progression_manager.gd:248, :249, :251, :252, :253
**Severidad:** Crítico
**Accionable:** Si
**Descripcion:** `_reevaluar(stat_id)` itera los hitos dependientes de la estadistica sucia y, para cada uno que **no** esta alcanzado (`not hito_alcanzado(hito_id)`), llama directamente a `marcar_hito(hito_id)`. **En ningun punto invoca `evaluar_condicion()`** para verificar que el umbral/condicion del hito se cumpla en ese momento. Esto permite marcar un hito como alcanzado aunque su condicion sea falsa, rompiendo el invariante de progresion. El comentario en :247 ("Reevalua SOLO los hitos dependientes de la estadistica sucia") no compensa la falta de validacion de condicion.
**Evidencia:** progression_manager.gd:251 `for hito_id in _condiciones_por_hito[stat_id]:`, :252 `if not hito_alcanzado(String(hito_id)):`, :253 `marcar_hito(String(hito_id))` (sin llamada a `evaluar_condicion` ni a `evaluar_condicion_id`).

### P-02 — API publica marcar_hito() no valida condicion (otorgamiento forzado)
**archivo:linea:** scripts/progresion/progression_manager.gd:791, :792, :793, :794-808
**Severidad:** Alto
**Accionable:** Si
**Descripcion:** `marcar_hito(milestone_id)` es publico y solo verifica idempotencia (`hito_alcanzado(milestone_id) or not _hitost.has(milestone_id)` -> retorna false). **No valida la condicion del hito** antes de entregar la recompensa (`_hitost[milestone_id]["recompensa_entregada"] = true`, emision de `progreso_hito_alcanzado`, activacion de desbloqueos/titulos). Cualquier llamador (M75 postgame, M72 logros, tests, debug) puede forzar un hito sin comprobar el umbral. Es un contrato de entrega sin guarda de elegibilidad.
**Evidencia:** progression_manager.gd:792 `if hito_alcanzado(milestone_id) or not _hitost.has(milestone_id): return false`, :794 `_hitost[milestone_id]["recompensa_entregada"] = true`, :798 `progreso_hito_alcanzado.emit(...)`, :801-807 (entrega recompensas/unlocks/titulos sin validar condicion previa).

### P-03 — Ruta puente postgame delega a reevaluar_sucias (SEGURA, citada para trazabilidad)
**archivo:linea:** scripts/postgame/postgame_manager.gd:225, :231, :233, :234
**Severidad:** Ruido (no es un defecto, pero depende de la ruta segura)
**Descripcion:** `_marcar_hito_derivado(id)` marca `primera_vez` en el perfil y luego llama a `pm.reevaluar_sucias()`. Como `reevaluar_sucias()` **sí** valida `evaluar_condicion(cond)` antes de `marcar_hito()` (ver P-04), esta ruta es segura **indirectamente**. Sin embargo, su seguridad depende enteramente de que `reevaluar_sucias()` no se vuelva insegura; si alguien refactoriza `reevaluar_sucias` para llamar a `_reevaluar`, este puente se vuelve inseguro.
**Evidencia:** postgame_manager.gd:233 `if pm.has_method("reevaluar_sucias"): pm.reevaluar_sucias()`.

### P-04 — reevaluar_sucias() valida condicion antes de marcar_hito (SEGURA)
**archivo:linea:** scripts/progresion/progression_manager.gd:408, :411, :414, :415, :416
**Severidad:** Ruido (ruta de referencia correcta)
**Descripcion:** `reevaluar_sucias()` itera todos los hitos no alcanzados y, para cada uno, obtiene su condicion (`_hitost[hito_id].get("condicion", {})`) y **solo llama a `marcar_hito(hito_id)` si `evaluar_condicion(cond)` retorna true**. Esta es la implementacion de referencia del invariante "umbral cumplido => hito otorgado". Es el patron que `_reevaluar()` deberia seguir.
**Evidencia:** progression_manager.gd:414 `var cond: Dictionary = _hitost[hito_id].get("condicion", {})`, :415 `if evaluar_condicion(cond):`, :416 `marcar_hito(hito_id)`.

### P-05 — M72 (logros) reacciona a senal, no otorga hitos (SEGURA, fuera de alcance directo)
**archivo:linea:** scripts/logros/achievement_service.gd:134, :221
**Severidad:** Ruido
**Descripcion:** `achievement_service.gd` se conecta a `pm.progreso_hito_alcanzado` y a `pm.progreso_desbloqueado`, y su `evaluar_todos()` llama a `pm.evaluar_condicion(cond)` antes de `desbloquear(id)`. M72 **no otorga hitos de M71**; solo valida logros propios. No es una ruta de otorgamiento de hitos de progresion, por lo que no es defecto de M71. Se cita para descartar confusion entre otorgamiento de hito (M71) y desbloqueo de logro (M72).
**Evidencia:** achievement_service.gd:134 `_conectar(pm.progreso_hito_alcanzado, ...: evaluar_todos())`, :221 `if pm.evaluar_condicion(cond):`.

---

## Analisis de rutas de otorgamiento

| Ruta | Archivo:linea | Valida condicion | Estado |
|------|--------------|------------------|--------|
| `_reevaluar()` | progression_manager.gd:248-253 | NO | INSEGURA (defecto F1) |
| `marcar_hito()` public | progression_manager.gd:791-808 | NO | INSEGURA (API publica sin guarda) |
| `reevaluar_sucias()` | progression_manager.gd:408-416 | SI | SEGURA (referencia correcta) |
| `_marcar_hito_derivado()` | postgame_manager.gd:225-234 | SI (indirecto) | SEGURA si `reevaluar_sucias` se mantiene |
| `evaluar_todos()` (M72) | achievement_service.gd:212-222 | SI | SEGURA (no otorga hitos M71) |

**Veredicto:** El defecto esta concentrado en `_reevaluar()` (P-01) y se agrava por la API publica `marcar_hito()` sin guarda (P-02). La ruta de referencia correcta es `reevaluar_sucias()` (P-04).

---

## Conclusiones

1. **Confirmado el defecto F1:** `_reevaluar()` otorga hitos sin validar el umbral. Se reproduce aislado en `test_bug_reevaluar_m71_hy3.gd`.
2. **`marcar_hito()` es una API publica peligrosa:** permite otorgamiento forzado sin guarda de elegibilidad.
3. **La ruta segura ya existe** (`reevaluar_sucias()`) y deberia ser el patron unico de otorgamiento.
4. **M72 (logros) no esta implicado** en otorgamiento de hitos M71; solo reacciona a su senal.

---

## Mejoras concretas de diseno (codigo conceptual)

### Mejora 1 — Unificar el otorgamiento seguro via `marcar_hito_si_cumple()`

Agregar un metodo privado `marcar_hito_si_cumple(milestone_id)` que valide la condicion antes de entregar, y hacerlo el unico punto de entrada para otorgar hitos. `marcar_hito()` publico se reduzca a una wrapper que llame a este metodo (o se marque como uso interno/forzado con nombre distinto, p. ej. `forzar_hito()`).

Concepto (progression_manager.gd):

```gdscript
## Otorga el hito SOLO si su condicion se cumple actualmente.
## Retorna true si se otorgo, false si ya estaba alcanzado o si la condicion no se cumple.
func marcar_hito_si_cumple(milestone_id: String) -> bool:
	if hito_alcanzado(milestone_id) or not _hitost.has(milestone_id):
		return false
	var cond: Dictionary = _hitost[milestone_id].get("condicion", {})
	if not evaluar_condicion(cond):
		return false  # umbral no cumplido: no otorgar
	return marcar_hito(milestone_id)  # entrega segura (idempotente)
```

Luego `_reevaluar()` (línea 248-253) se cambia a llamar `marcar_hito_si_cumple(hito_id)` en lugar de `marcar_hito(hito_id)` directamente. Esto elimina P-01 sin tocar `marcar_hito()` publico.

### Mejora 2 — Hacer `marcar_hito()` un punto unico con guarda opcional, y deprecivar otorgamiento forzado

Convertir `marcar_hito()` para que acepte un parametro opcional `validar: bool = true` que, cuando es true (por defecto), ejecute `evaluar_condicion` antes de entregar. Agregar un metodo separado `forzar_hito(milestone_id)` para casos excepcionales (migracion, tests, debug) que deje constancia en log. Esto centra toda la logica de otorgamiento en un solo punto y hace visible el otorgamiento sin guarda.

Concepto (progression_manager.gd):

```gdscript
## Otorga el hito. Si validar=true (defecto), comprueba la condicion antes.
func marcar_hito(milestone_id: String, validar: bool = true) -> bool:
	if hito_alcanzado(milestone_id) or not _hitost.has(milestone_id):
		return false
	if validar:
		var cond: Dictionary = _hitost[milestone_id].get("condicion", {})
		if not evaluar_condicion(cond):
			push_warning("[M71] Hito '%s' no cumple condicion; no otorgado" % milestone_id)
			return false
	# entrega segura (idempotente)
	_hitost[milestone_id]["recompensa_entregada"] = true
	_hitos_alcanzados.append(milestone_id)
	...
	return true

## Otorgamiento forzado sin guarda (solo migracion/tests/debug). Registra advertencia.
func forzar_hito(milestone_id: String) -> bool:
	push_warning("[M71] forzar_hito('%s') — otorgamiento sin validacion de umbral" % milestone_id)
	return marcar_hito(milestone_id, validar=false)
```

Con esto, `_reevaluar()` llama `marcar_hito_si_cumple()` (Mejoras 1) y `marcar_hito(publico)` valida por defecto (Mejoras 2), cerrando ambas rutas inseguras (P-01 y P-02).

---

**Fin del reporte.**
