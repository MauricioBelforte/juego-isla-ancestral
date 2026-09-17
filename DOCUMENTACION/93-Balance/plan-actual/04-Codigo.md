**Modelo:** GLM-5.3 (último modificador — iter. 4 relevo §21.4.7; iter. 3 glm-5.3-flash materializada sin log; núcleo iters. 1-2 Deepseek V4 Flash)

**Plataforma:** Kilo Code

# 04-Codigo.md — Módulo 93: Balance

## 1. Archivos Involucrados

| Archivo | Tipo | Propósito |
|---|---|---|
| `data/balance/meta.json` | Datos | Versión, fecha, módulos afectados |
| `data/balance/prices.json` | Datos | Precios compra/venta (M38/M39) |
| `data/balance/rewards.json` | Datos | Recompensas por actividad (M22/M23, M44) |
| `data/balance/construction.json` | Datos | Costes de construcción (M17) |
| `data/balance/crafting.json` | Datos | Recetas y costes (M16) |
| `data/balance/tools.json` | Datos | Herramientas: durabilidad y mejoras (M13) |
| `data/balance/resources.json` | Datos | Abundancia/respawn por bioma y estación (M15) |
| `data/balance/farming.json` | Datos | Cultivos: ciclo, rendimiento, precio (M33) |
| `data/balance/fishing.json` | Datos | Peces: probabilidades, peso, precio (M34) |
| `data/balance/mining.json` | Datos | Minerales: profundidad, rareza, valor (M35) |
| `data/balance/travel.json` | Datos | Viajes: coste y duración por ruta (M28) |
| `data/balance/seals.json` | Datos | Sellos: bloques de progreso (M153) |
| `data/balance/friendship.json` | Datos | Amistad: puntos, umbrales (M20) |
| `data/balance/quests.json` | Datos | Misiones: recompensas (M22/M23) |
| `data/balance/puzzles.json` | Datos | Puzzles: tiempos y recompensas (M24/M26) |
| `data/balance/unlocks.json` | Datos | Desbloqueos: coste y condición (M71) |
| `data/balance/timing.json` | Datos | Tiempos objetivo diarios (RF16) |
| `data/balance/progression.json` | Datos | Curvas de progresión (RF17) |
| `scripts/balance/balance.gd` | Autoload | Acceso central de lectura |
| `scripts/balance/validate_balance.gd` | Tool | Reglas de negocio verificables |
| `scripts/balance/simulate_economy.gd` | Tool | Simulación económica offline |
| `scripts/balance/balance_report.gd` | Tool | Reporte markdown legible |
| `tests/balance/test_balance.gd` | Test | Suite de tests del balance |

## 2. Funciones Clave

### 2.1 `balance.gd`

```gdscript
extends Node
## Acceso central a los valores de balance. Carga única, solo lectura.

var _prices: Dictionary = {}
var _rewards: Dictionary = {}
# ... resto de tablas

func _ready() -> void:
    load_all()   # ResourceLoader.load() de cada JSON

func load_all() -> void:
    _prices = _load_json("res://data/balance/prices.json")
    _rewards = _load_json("res://data/balance/rewards.json")
    # ... idem resto

func _load_json(path: String) -> Dictionary:
    var f := FileAccess.open(path, FileAccess.READ)
    if f == null:
        push_error("Balance: no se pudo cargar %s" % path)
        return {}
    return JSON.parse_string(f.get_as_text())

func get_price(item_id: String) -> Dictionary:
    return _prices.get("items", {}).get(item_id, {})

func get_sell_price(item_id: String) -> int:
    var p: Dictionary = get_price(item_id)
    return int(p.get("price_sell", 0))

func get_reward(activity_id: String, tier: int = 0) -> Dictionary:
    var r: Dictionary = _rewards.get("activities", {}).get(activity_id, {})
    return r.get(str(tier), r.get("base", {}))

func validate_all() -> Array[String]:
    return validate_balance.check_all(self)
```

### 2.2 `validate_balance.gd` (reglas clave)

```gdscript
extends RefCounted
## Reglas de negocio del balance. Cada regla devuelve un error si no cumple.

static func check_all(balance: Node) -> Array[String]:
    var errors: Array[String] = []
    errors.append_array(check_margins(balance))
    errors.append_array(check_no_grind(balance))
    errors.append_array(check_no_exploit(balance))
    errors.append_array(check_progression_curves(balance))
    errors.append_array(check_daily_timing(balance))
    errors.append_array(check_seals(balance))
    return errors

static func check_margins(balance: Node) -> Array[String]:
    var errors: Array[String] = []
    for item_id: String in balance._prices.get("items", {}):
        var p: Dictionary = balance._prices["items"][item_id]
        if not p.has("price_buy") or not p.has("price_sell"):
            errors.append("ITEM %s sin price_buy/price_sell" % item_id)
            continue
        var ratio: float = float(p.price_sell) / float(p.price_buy)
        if ratio < 0.55 or ratio > 0.70:
            errors.append("ITEM %s margen fuera de rango (%.2f)" % [item_id, ratio])
    return errors

static func check_progression_curves(balance: Node) -> Array[String]:
    # Ninguna curva puede ser exponencial: pendiente decreciente en cada tramo.
    var errors: Array[String] = []
    var curve: Array = balance._progression.get("curves", {}).get("money", [])
    for i in range(1, curve.size() - 1):
        var prev_slope: float = curve[i] - curve[i - 1]
        var next_slope: float = curve[i + 1] - curve[i]
        if next_slope > prev_slope * 1.3:
            errors.append("CURVA money: pendiente creciente en tramo %d (exponencial)" % i)
    return errors

static func check_daily_timing(balance: Node) -> Array[String]:
    var t: Dictionary = balance.get_timing()
    if t.get("routine_minutes", 999) > 30:
        return ["TIMING: rutina diaria supera 30 min"]
    return []

static func check_seals(balance: Node) -> Array[String]:
    var errors: Array[String] = []
    for seal_id: String in balance._seals.get("seals", {}):
        var s: Dictionary = balance._seals["seals"][seal_id]
        if s.get("grind_blocks", 0) > 0:
            errors.append("SEAL %s exige bloques de grind > 0" % seal_id)
    return errors
```

### 2.3 `simulate_economy.gd` (esqueleto)

```gdscript
extends SceneTree
## Simulación económica: corrió en editor o CI. Uso:
##   godot --headless -s scripts/balance/simulate_economy.gd -- --days 180 --scenario rutinario

func _init() -> void:
    var days: int = 180
    var scenario: String = "rutinario"
    # parseo de --days y --scenario
    var result: Dictionary = _simulate(days, scenario)
    var max_ao: float = result.get("ao_total", 0.0)
    var designed: float = result.get("ao_design", 0.0)
    if max_ao > designed * 1.15:
        push_error("ANTI-EXPLOIT: el escenario %s genera %.0f AO vs diseño %.0f" % [scenario, max_ao, designed])
        quit(1)
    else:
        print("SIM OK: %s %d días → %.0f AO (diseño %.0f)" % [scenario, days, max_ao, designed])
        quit(0)
```

## 3. Logs Relacionados (Debug.Log/Mensajes)

| Mensaje | Nivel | Cuándo |
|---|---|---|
| `BALANCE cargado vX.Y.Z (N ítems)` | info | Carga única al inicio |
| `BALANCE no se pudo cargar {path}` | error | JSON faltante o corrupto |
| `BALANCE desvío >20% en {categoria}` | warning | Telemetría (M105) reporta desvío |
| `BALANCE validación: {N} errores` | error | validate en CI/editor |
| `BALANCE simulación falló: {motivo}` | error | simulate_economy exit != 0 |

## 4. Cambios Frecuentes de Balance (Ejemplos de Tuning)

| Cambio | Archivo | Cómo se valida |
|---|---|---|
| Subir precio de un pez raro | `fishing.json` | margen ≠ cambiar | `validate_balance.gd` (margen) + simulación |
| Bajar durabilidad de herramienta | `tools.json` | simulación de sesión |
| Añadir cultivo de invierno | `farming.json` | simulación + tests cultivo |
| Nuevo Sello | `seals.json` + diseño (M153) | validate (grind=0) + playtest |
| Evento de temporada con descuento | `prices.json` (sobreescritura de evento en M74) | margen dentro de rango durante evento |

## 5. Tests (M112)

- `test_balance.gd`: carga correcta de cada JSON, márgenes, curvas, pity, topes de venta, sellos sin grind, rutina ≤ 30 min.
- `test_simulate.gd`: escenario rutinario 365 días no produce AO > diseño.
- Ejecución: `godot --headless -s res://tests/balance/run_tests.gd`.

## 6. Notas del Agente

**Modelo:** glm-5.3-flash (último modificador; núcleo/iter. 1 por Deepseek V4 Flash)

**Plataforma:**Kilo Code
**Fecha:** 2026-08-19 04:23
**Estado:** Documentación completa

### Lo que hice
- Documenté el módulo Balance completo (5 archivos, plan-inicial y plan-actual idénticos al inicio).
- Checklist de 130 ítems verificables, derivados de la sección 92 del plan maestro (21 ítems) + pensamiento propio alineado a M152/M153/M38/M20.
- Diseñé el esquema de datos JSON central, reglas validables, simulación económica y gate CI.

### Lo que NO pude hacer
- Ningún ítem quedó `[?]`: la documentación es diseño a implementar, no código en runtime aún (el proyecto no tiene gameplay implementado).

### Recomendaciones para el próximo agente
- Al implementar, empezar por `balance.gd` + `meta.json` y conectar M38/M39 (tiendas) primero.
- El gate CI de balance (M118) debe correr en cada PR que toque `data/balance/`.

---

## Notas del Agente — Iteración 3 tablas faltantes (historial, no borra las anteriores)

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 01:25:00
**Estado:** Parcial (22 ítems más cerrados; módulo liberado 🟡)

### Lo que hice
- friendship.json v2: generosidad_favorito (x3 puntos, checklist 82), beneficios_por_nivel 2-8 (recetas/descuento/trueque especial/eventos/diálogo secreto, checklist 80), sin_decaimiento_por_ausencia=true (M94, checklist 81).
- quests.json v2: secundaria 15 AO = 10% de taller_crafting (regla 5-15% del siguiente desbloqueo, checklist 87), reglas items_exclusivos_no_monetizables/misiones_siempre_completables (88/89), bonus_eventos_temporada (90).
- puzzles.json v2: recompensa_templo (item_unico no monetizable: canta_gotas/abraska_volcan, checklist 96), recompensa_ruinas (fragmentos+lore, 0 AO, 98), reglas resoluble_con_herramientas_del_momento (97), tiempos 20/45 verificados (95).
- unlocks.json v2: orden_global + campo orden individual (103), historia_sin_coste_monetario (104), cosmeticos_sink_ao (105), museo_records_no_monetarios (106).
- meta.json v2 (1.1.0): rareza probabilidad_raro_max 0.05 (41) + pity (+10%/fallo, cap 2x, reset — 42; M34 ya lo implementa), rendimiento.nodos_activos_max_por_chunk 8 (57, M61), viajes.recompensa_descubrir_ruta_ao 25 (66, M28).
- Test nuevo test_balance_m93_iter3.gd: valida TODAS las reglas nuevas + coherencia con M20 REAL (30 puntos = +1 nivel) y M22 (nodos templo en el grafo) → **0 fallos**.
- FIX del núcleo (test_balance.gd de Deepseek): 2 asserts rotos DESDE SIEMPRE — schema_version==1 rígido (ahora >=1, evolución forward) y "herramienta_basica" receta que NUNCA existió en crafting.json (verificado contra git HEAD; ahora valida una receta real del catálogo). El test núcleo quedó en 0 fallos.
- Regresiones: validate_balance (12 reglas) 0 fallos, test_balance núcleo 0 fallos.
- Checklist: +22 ítems [x]. Progreso 25→47/130.

### Lo que NO pude hacer (honestidad obligatoria)
- Integración consumo M38/M16/M20 (cablear los servicios a estas tablas): es una iteración de integración aparte; los getters del BalanceService ya existen.
- Simulación económica RF20 y reporte playtest RF22: requieren iteración con más módulos activos.

### Recomendaciones para el próximo agente
- Integración consumo: M20 debe leer beneficios_por_nivel (nivel 4 → oferta_trueque_especial) y M39 el descuento_tienda_5.
- M61/M35: respetar nodos_activos_max_por_chunk=8.
- M28: al implementar viajes, pagar recompensa_descubrir_ruta_ao al descubrir ruta nueva.

---

## Notas del Agente — Iteración 4 por relevo §21.4.7 (GLM-5.3)

**Modelo:** GLM-5.3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-12 04:10
**Estado:** Parcial-liberado (auditoría + 5 brechas de data cerradas; módulo queda 🟡 112/134 con 22 [?] con dueño)

### Lo que hice
1. **Relevo §21.4.7:** reserva de glm-5.3-flash del 2026-09-01 (iter. 3: tablas friendship/quests/puzzles/unlocks/meta-rareza) sin log ni liberación por 11 días. Re-verifiqué antes de reclamar: sin logs M93 nuevos desde el 333 (2026-09-01), sin reserva activa, CHECKLIST-GLOBAL última actividad 2026-08-30.
2. **Hallazgo del reclamo — iter. 3 fantasma MATERIALIZADA:** el trabajo de flash SÍ aterrizó en disco sin log: `data/balance/{friendship,quests,puzzles,unlocks}.json` v2 + `meta.json` rareza/rendimiento/viajes + `scripts/balance/test_balance_m93_iter3.gd` (6 bloques, 0 fallos). ~20 ítems del checklist ya estaban cubiertos por estas tablas sin marcar (gap de marcado clásico). La iter. 3 quedó asimilada en esta auditoría.
3. **Auditoría de los 64 [ ] contra código/tablas reales:** 66 → **112 [x]** / 22 [?] / 0 [ ]. Cierres por gap de marcado (ya existía): H items exclusivos (quests v2), P.2/P.3/P.4 reglas de validate (R7/R8/R8b), X.1/X.3 márgenes/sellos (validate cobertura total), W.3/W.5 (arquitectura O(1) + medición de facto), Q.2/Q.3 (grep REAL: crafting_service L67-69 y farm_service L67-69 consumen /root/Balance), Z.1-Z.4 coordinaciones (evidencia: T7 amistad M38 usa umbrales M93, test iter3 ejecuta el servicio M20 real, M94 consume las 3 reglas de ausencia).
4. **5 brechas V0 de DATA cerradas** (con test nuevo, no solo reglas):
   - **D.4 tiempo de minado:** mining.json v2 — `golpes_para_extraer` por mineral (3/5/8), `reglas_minado` (dureza, 1.5 s/golpe, máx 2 min por veta, coherencia con M35 documentada).
   - **L.2-L.4 curvas:** progression.json v2 — `curvas_recursos_acumulados` (día 1/7/28/90 con tope soft), `curva_amistad_total` (semana 1/4/12), `curva_colecciones` (10%/35%/70%).
   - **L.5 no-exponencial:** `reglas_curvas.no_exponencial` + verificación MATEMÁTICA en el test (pendientes por tramo decrecientes en las 3 curvas).
   - **M anti-grind:** meta.json v3 `reglas_anti_grind` — repetición máx 4, tope ventas 600 AO/día, temporada cíclica, colección sin día único, bonus_retorno (+5 AO/día ausente, tope 150).
   - **N anti-exploit:** meta.json v3 `reglas_anti_exploit` — 3 bucles identificados con contramedidas, techo 115%, reloj interno independiente (coherente con C56 29/29), límite 20 ventas/día/categoría.
   - **K rutinas:** timing.json v2 `rutinas` — rutina óptima 30 min con pasos, sesión libre [60,120] min, cultivos sin muerte, estaciones rotativas 28 días.
5. **Test nuevo `test_balance_m93_iter4.gd`:** 7 bloques (minado, curvas, anti-grind, anti-exploit, rutinas, versión 1.2.0, integraciones Q) — **0 fallos**.
6. **Bump de versión 1.1.0 → 1.2.0** (regla U.3) con desacople del test iter3 (ahora acepta >=1.1.0 semántico para no romper en cada bump).

### Tests (QA numérico, Godot 4.7.2 headless)
- `test_balance.gd` 0 fallos · `test_balance_m93_iter3.gd` 0 fallos · `test_balance_m93_iter4.gd` 0 fallos · `validate_balance.gd` 0 fallos
- Consumidores: `test_crafting.gd` 0 · `test_pergaminos_tienda.gd` 0 (M16) · `test_farm.gd` 0 · `test_farm_clima.gd` 0 (M33) · `test_mineria.gd` 0 (M35) · `test_fishing.gd` 0 · `test_fishing_clima.gd` 0 (M34, post-auditoría M34)

### Lo que NO pude hacer (honestidad obligatoria)
- **O.1-O.3 + X.5 (simulación económica):** la brecha grande restante del módulo. `simulate_economy.gd` NO existe (a pesar de figurar en §1 del 04-Codigo — era aspiracional del diseño). Escribirlo con 3 perfiles (rutinario/diligente/minimalista) × 60/180/365 días contra las tablas reales es la **próxima iter natural de M93** — ahora tiene TODO el input: curvas, topes, reglas anti-exploit, techo 115%. No lo hice en esta iter por presupuesto de sesión (la auditoría + data + tests consumieron el ciclo) — prefiero una iter dedicada con margen para iterar el simulador contra desvíos.
- **O.5 (CI):** depende de O.1 + M118.
- **S (telemetría):** eventos de balance → M105 (WorkBuddy activo, Log 826) — propuse el contrato en el checklist: "balance_ao_dia" {ao, dia_absoluto}, "compra"/"venta" {item_id, precio}.
- **T/V.1/V.2:** fase jugable (M114) / simulación (O).
- **Y.1-Y.5:** polish UI → M53/M74/M94/M88/M43.
- **Q.1:** M38/M39 usan EconomyPriceCatalog propio (decisión de arquitectura M38); la fusión de fuentes es una decisión de M38.

### Decisiones
- **P.1/P.2/P.3 no duplicadas en validate_balance:** la regla de curvas vive en progression.json + test iter4 (con exit code, ejecutable en CI igual que validate) — duplicarla en validate sería redundancia de tests.
- **El fishing.json sigue con 2 peces:** M34-documentado (23 peces + cebos + cañas = data de M93). La próxima iter de M93 debería completarlo JUNTO con el simulador (el simulador de pesca necesita el catálogo real para simular el pipeline pescar+vender).
- **Tip del JSON:** progression.json v2 sufría un `}` extra (línea 40) que Godot rechazaba con "Expected 'EOF' at line 39" — el parser de PowerShell 5.1 (ConvertFrom-Json) lo reportaba mal (falso "Primitivo JSON no válido"). LECCIÓN: validar JSON de data con el parser REAL de Godot (script headless de 5 líneas), no confiar en PowerShell.

### Recomendaciones para el próximo agente
- **Próxima iter M93 (iter. 5):** simulate_economy.gd con 3 perfiles + completar catálogo de pesca (25 peces/4 cebos/3 cañas — formato documentado en 04-Codigo M34 §0b) + techo 115% como aserción del simulador.
- **QA cruzado §21.8 (verificador: Hy3, NO auto-verificar):** puntos rápidos → test_balance_m93_iter4.gd 0 fallos (7 bloques), validate_balance 0 fallos, version 1.2.0 en meta.json, mining.json reglas_minado, progression.json 3 curvas + reglas, meta.json v3 reglas_anti_grind/anti_exploit, timing.json rutinas.
- **M38 (si lo tomás):** EconomyPriceCatalog podría SOURCEAR de BalanceService.get_tabla("prices") para una sola fuente de verdad — hoy hay 2 fuentes (prices.json + catálogo M38) con los mismos márgenes 55-70%.
