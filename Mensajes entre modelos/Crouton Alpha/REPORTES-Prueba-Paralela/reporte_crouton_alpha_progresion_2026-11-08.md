# Reporte — Sistemas de Progresión, Experiencia, Niveles y Habilidades
**Modelo:** Crouton Alpha
**Fecha:** 2026-11-08
**Alcance:** `game/isla-ancestral/scripts/` — búsqueda de archivos `.gd` relacionados con progresión, experiencia, niveles, habilidades
**Idioma del reporte:** español

---

## 1. Archivos localizados

### 1.1 Módulo principal de progresión (M71) — `scripts/progresion/`
| Archivo | Descripción |
|---|---|
| `scripts/progresion/progression_manager.gd` (959 líneas) | Autoload `ProgressionManager`. Catálogo de hitos, evaluador de condiciones (11 tipos), desbloqueos, títulos cosméticos, persistencia. |
| `scripts/progresion/player_profile.gd` (117 líneas) | Autoload `PlayerProfile`. Estadísticas totales/diarias (`_totales`, `_dia`), primeras veces, reputación, contribución. |
| `scripts/progresion/test_progresion.gd` (440 líneas) | Suite principal (83 checks mínimos, 20 bloques). |
| `scripts/progresion/test_flujo_xp_recompensa_m71_hy3.gd` (265 líneas) | Flujo XP/recompensa (37 checks, 10 bloques). |
| `scripts/progresion/test_bug_reevaluar_m71_hy3.gd` (100 líneas) | Reproducción aislada F1 (defecto `_reevaluar` sin validar umbral). |
| `scripts/progresion/test_nivel_herramienta.gd` (66 líneas) | Puente M13→M71: `herramienta_equipada` → `nivel_herramienta_cambio`. |
| `scripts/progresion/debug_tc.gd` (20 líneas) | Debug de autoloads de herramientas. |
| `data/progresion/hitos.json` (458 líneas, 26 hitos) | Catálogo data-driven de hitos (schema v1). |
| `data/balance/progression.json` (56 líneas, schema v2) | Curvas de progresión anti-exponenciales (economía, amistad, colecciones, recursos). |

### 1.2 Sistemas de nivel relacionados
| Archivo | Descripción |
|---|---|
| `scripts/friendship/vecino_amistad.gd` (149 líneas) | Nivel de amistad por vecino (0–10, umbrales `[0,20,40,70,100,140,190,250,320,400,500]`). |
| `scripts/friendship/friendship_service.gd` (708 líneas) | Autoload `Friendship`. Aplica puntos, subidas de nivel, señales `friendship_level_up`. |
| `scripts/crafting/crafting_service.gd` (líneas 362–401) | Niveles de herramientas: `durabilidad_maxima(tipo,nivel)`, `efectividad(tipo,nivel)`, `mejorar` (consume materiales, sube nivel). |
| `scripts/herramientas158/tool_tier_system.gd` | Tiers de herramientas (`nivel`, daño, velocidad, área). |
| `scripts/core/event_bus.gd` (líneas 41, 155, 173–180) | Dominio `progresion`: `nivel_herramienta_cambio`, `nivel_casa_cambio`, `nivel_amistad_cambio`, `jugador_subio_nivel`. |
| `scripts/stream/progress_calculator.gd` (35 líneas) | **Falso positivo**: progreso de streaming/carga (pesos por operación), NO experiencia de jugador. |

### 1.3 Búsquedas negativas
- No existen carpetas `scripts/nivel/`, `scripts/xp/` ni archivos `*experiencia*`, `*habilidad*` dedicados.
- No hay sistema clásico "barra XP + nivel de personaje" con curva `xp_necesaria(nivel)`. La "experiencia" del juego es **acumulación de estadísticas discretas** (items, misiones, monedas…) que disparan hitos. Ver §2.

---

## 2. ¿Cómo se gestiona la experiencia y la subida de nivel?

### 2.1 Modelo general (M71 — Progresión, no RPG clásico)
No hay `experiencia` ni `nivel_jugador` como en un RPG. Hay **estadísticas acumuladas** en `PlayerProfile._totales: Dictionary` (`player_profile.gd:20`) y un **catálogo de hitos** que se desbloquean cuando una estadística cruza un umbral. Los hitos otorgan recompensas (`info`, `unlock`, `titulo`, `cosmetico`) y emiten señales (`progreso_hito_alcanzado`, `progreso_desbloqueado`, `progreso_titulo_obtenido`).

**Flujo de acumulación** (`progression_manager.gd:147–174`, `_conectar_eventos()`):
- `EventBus.inventory.item_added` → `_stat("+", "items_recolectados", q)`
- `EventBus.economy.purchase_done` → `monedas_gastadas`
- `EventBus.npc.gift_given` → `regalos_dados`
- `EventBus.quest.prereq_met` → `sellos_obtenidos` (+ reflejo narrativo `sello_*`)
- `EventBus.quest.quest_completed` → `misiones_completadas`
- `EventBus.npc.friendship_level_up` → `amistades_subidas`
- `EventBus.travel.travel_started` → `viajes_realizados`
- `EconomyManager.transaccion_registrada` (deposito/trueque_ingreso) → `monedas_ganadas`
- `Barter.trueque_exitoso` → `trueques_realizados`
- `ToolController.herramienta_equipada` (puente `conectar_tool_controller`, líneas 193–221) → estadística monótona `nivel_<herramienta>`

Cada `_stat()` llama `profile.incrementar()` (`player_profile.gd:31–36`) y `_reevaluar(stat_id)` (`progression_manager.gd:248–253`), que marca los hitos indexados por esa estadística vía `_condiciones_por_hito` (dirty-flagging O(1) por evento, diseño §7).

### 2.2 Evaluación de condiciones (11 tipos, `evaluar_condicion`, líneas 702–750)
`stat_min`, `dias_jugados`, `sello_historia`, `capitulo_historia`, `riqueza_acumulada`, `primera_vez`, `hito_previo`, `coleccion_completa`, `nivel_modulo`, `compuesta` (AND/OR/NOT). Existe además `evaluar_pura()` (líneas 260–328): predicado puro sin leer autoloads, con caché `evaluar_condicion_id()` (líneas 380–405, `CACHE_MAX_SIZE = 64`).

### 2.3 Niveles de amistad (M20) — el sistema de "nivel" más cercano a RPG
`vecino_amistad.gd:98–108` (`aplicar_puntos`):
```gdscript
puntos += maxi(0, delta)
while nivel < umbrales.size() - 1 and puntos >= umbrales[nivel]:
    nivel += 1
    subio = true
    # anexos recompensas por nivel
```
Conserva excedente, sube múltiples niveles en un solo salto (while), y emite `friendship_level_up` vía `FriendshipService`. Umbrales crecientes (20→500) pero constantes, no exponenciales. Límites diarios (regalo/charla/carta 1/día, `vecino_amistad.gd:18–23`) evitan grind. `get_progreso()` (líneas 44–49) calcula fracción `puntos/umbral` para UI.

### 2.4 Niveles de herramientas/casas (M13/M18)
`crafting_service.gd:363–371`: curvas lineales `durabilidad_maxima = base + 50*nivel`, `efectividad = 1.0 + 0.15*nivel`. `mejorar()` consume materiales y sube nivel, `reparar()` restaura. `level_up` de herramienta alimenta `_on_herramienta_equipada` (líneas 202–221) que solo incrementa la estadística si el nuevo nivel es mayor (monótona, líneas 219–221).

### 2.5 Reputación (player_profile.gd:70–76)
`reputacion = (amistad_norm*0.6 + contribucion_norm*0.4)*100`, con `CONTRIBUCION_META = 2000`. Si no hay dato de amistad, solo contribución re-escalada al 100%.

---

## 3. Validación de valores negativos o desbordamiento

### 3.1 Lo que SÍ está validado
- **Catálogo (hitos)**: `validar_catalogo()` (líneas 530–556) y `_detectar_problemas_bloqueantes()` (líneas 674–697) rechazan **umbrales negativos** en todos los tipos (`stat_min`, `riqueza_acumulada`, `dias_jugados`, `nivel_modulo`). Los tests confirman 0 errores en el catálogo actual.
- **Amistad**: `aplicar_puntos` usa `maxi(0, delta)` (`vecino_amistad.gd:99`) → delta negativo se neutraliza a 0. `deserializar` usa `maxi(0, ...)` para puntos y `clampi(1, umbrales.size()-1)` para nivel (líneas 135–136). `get_progreso` evita división por cero con `maxi(1, ...)` (línea 48).
- **Herramientas**: `durabilidad_maxima`/`efectividad` usan `maxi(0, nivel)` (líneas 366, 371). Puente de herramienta solo sube si `nivel > prev` (línea 220).
- **Persistencia**: `restore_save_data` purga hitos desconocidos (líneas 934–940) y re-aísla títulos (líneas 953–956).
- **Reputación**: `clampf(..., 0.0, 1.0)` en ambos componentes (líneas 71–72); no puede exceder 100 ni bajar de 0.
- **Streaming/progress_calculator**: `clampf(..., 0.0, 1.0)` y guarda `peso_total <= 0 → 1.0` (líneas 21–23).

### 3.2 Lo que NO está validado (hallazgos)

| # | Ubicación | Problema | Severidad |
|---|---|---|---|
| V-1 | `player_profile.gd:31–36` `incrementar(stat_id, cantidad)` | **No valida `cantidad` negativa**. `incrementar("items_recolectados", -100)` decrementa la estadística, pudiendo volverla negativa. El camino de eventos siempre pasa `q >= 0`, pero la API es pública y `set_stat` (líneas 39–41) tampoco valida. | Media |
| V-2 | `player_profile.gd:35–36` | `_contribucion += float(cantidad)` se incrementa también con cantidades negativas → reputación calculada sobre contribución negativa (aunque `clampf` la lleva a 0, se pierde ganancia real). | Media |
| V-3 | `player_profile.gd:104–117` `cargar()` | **Carga valores sin validar**: si el save trae `items_recolectados = -50` (save corrupto/editado) o `_contribucion = 1e308`, los acepta tal cual. No hay `clamp`/`maxi(0, ...)` como sí hace `vecino_amistad.deserializar`. | Media |
| V-4 | `progression_manager.gd:226–232` `_on_transaccion_registrada` | Los `elif` no tienen `else`: transacciones de tipo desconocido se ignoran silenciosamente. Correcto por robustez, pero sin log → diagnóstico difícil. | Baja |
| V-5 | Desbordamiento aritmético | `PlayerProfile` almacena stats como `float` (`float(_totales.get(...))`). Por encima de 2^53 (~9×10¹⁵) se pierde precisión. Sin cap superior ni `INF` guard. En la práctica inalcanzable hoy, pero no hay const `MAX_STAT`. | Baja |

**No hay validación de overflow** en ningún sistema de nivel: ni cap de `nivel` máximo de herramienta (salvo implícito por datos), ni de `puntos` de amistad, ni de reputación más allá de `clampf` 0–100.

---

## 4. Problemas de cálculo de niveles o umbrales

### 4.1 [CRÍTICO — confirmado por test] F1: `_reevaluar()` marca hitos sin validar umbral
`progression_manager.gd:248–253`:
```gdscript
func _reevaluar(stat_id: String) -> void:
    if not _condiciones_por_hito.has(stat_id):
        return
    for hito_id in _condiciones_por_hito[stat_id]:
        if not hito_alcanzado(String(hito_id)):
            marcar_hito(String(hito_id))   # ← NO llama evaluar_condicion()
```
**`_reevaluar` marca TODOS los hitos indexados bajo la estadística sucia sin comprobar `stat >= umbral`.** El test `test_bug_reevaluar_m71_hy3.gd` (líneas 68–72) lo demuestra: con 10 items se desbloquea `hito_items_50` (umbral 50) y la cadena compuesta `hito_explorador_completo` (requiere 50 items + 3 viajes + 5 misiones). El otro test lo nota como `[NOTA] F1` (líneas 116–120). `reevaluar_sucias()` (líneas 408–416) SÍ valida con `evaluar_condicion()`, por lo que hay **dos caminos inconsistentes**: el dirigido por eventos (buggy) y el batch (correcto). `evaluar_pura()` también valida, pero `_reevaluar` no la usa.

**Impacto desproporcionado**: el primer ítem recolectado desbloquea instantáneamente todos los hitos de `items_recolectados` (10, 50), `monedas_ganadas` (500, 2000), `misiones_completadas` (1, 5, 10), etc., y todas sus recompensas (títulos, unlocks). El sistema de progresión es, en la práctica, "al primer evento, todos los hitos de esa familia".

### 4.2 Umbral de amistad inconsistente entre balance y código
- `data/balance/progression.json:8–10`: `amistad_umbral_nivel_2 = 30`, `nivel_3 = 70`, `nivel_5 = 150`.
- `vecino_amistad.gd:12`: `UMBRALES = [0, 20, 40, 70, 100, 140, ...]` → nivel 2 = 20, nivel 3 = 40, nivel 5 = 140.
- `scripts/friendship/friendship_service.gd:49` usa `VECINO_SCRIPT.UMBRALES` y solo lo sobrescribe si existe `amistad_config.tres` (`_cargar_config`, líneas 143–151). Si el `.tres` no existe, manda el const.

El test `test_balance.gd:63` afirma `nivel_2 = 30` (del JSON) y `test_balance_m93_iter3.gd:74–80` afirma "M20: 30 puntos = +1 nivel (umbral nivel_2=30 real)" — **contradice el código real (20)**. Tests verdes contra un número distinto del implementado: falsa confianza.

### 4.3 Umbrales y curvas anti-patrón en `progression.json` (nota del propio autor, líneas 11, 54)
- `_nota_sello_1`: si `dinero_diario_promedio_ao = 80` es **por día**, el umbral de sello (1200) debería ser 80 o el tiempo 15 días. Ambigüedad unidad "por día vs por sesión" documentada pero sin resolver en el balance.
- `reglas_curvas.no_exponencial = true` verificada por test (`dia_7→dia_28` +50%, `dia_28→dia_90` +0%). Bien diseñado, pero el umbral de amistad de §4.2 rompe la coherencia entre balance y código.

### 4.4 `get_progreso` puede exceder 1.0
`vecino_amistad.gd:47–49`: `en_nivel = puntos - umbral_ini; ancho = max(1, umbral_sig - umbral_ini); progreso = en_nivel/ancho`. Si `puntos` supera `umbral_sig` (excedente de multi-nivel antes de resolver), `progreso > 1.0`. `aplicar_puntos` resuelve niveles en un while, pero entre el cálculo del excedente y la subida, un caller que lea `get_progreso` antes de aplicar vería >1.

### 4.5 Caché LRU rota
`progression_manager.gd:392–405` (`_evaluate_cache_set`): la "LRU simple" recorre el dict y toma la primera key como "más vieja" (líneas 399–402), pero los dict de GDScript no garantizan orden de inserción en todos los builds; si la key "más vieja" es un hito recientemente usado, se evicta una entrada caliente. Además, **la caché nunca se invalida**: `evaluar_condicion_id()` congela el resultado (líneas 380–389) y no hay `invalidate_cache()` — si una condición cambia (ej. `ToolController` aparece después), el resultado congelado queda para siempre hasta reinicio.

### 4.6 Duplicación de evaluadores
`evaluar_condicion()` (líneas 702–750) y `evaluar_pura()` (líneas 260–328) implementan los **mismos 11 tipos** en paralelo (duplican ~70 líneas de match). La deriva ya es visible: `evaluar_pura` tiene fallback a `estado` explícito, `evaluar_condicion` no. Cualquier fix futuro debe tocar dos lugares.

---

## 5. Dos mejoras sugeridas

### Mejora 1 — Corregir `_reevaluar()` para validar el umbral antes de marcar (prioridad máxima)
```gdscript
func _reevaluar(stat_id: String) -> void:
    if not _condiciones_por_hito.has(stat_id):
        return
    for hito_id in _condiciones_por_hito[stat_id]:
        if hito_alcanzado(String(hito_id)):
            continue
        var cond: Dictionary = _hitost[hito_id].get("condicion", {})
        if evaluar_condicion(cond):        # gate que falta
            marcar_hito(String(hito_id))
```
Efecto: un solo cambio restaura la semántica "hito desbloqueado cuando stat >= umbral" en el camino de eventos. Acompañar con:
- Convertir `test_bug_reevaluar_m71_hy3.gd` (hoy diseñado para FALLAR) en test de regresión verde.
- Añadir invalidación de caché: `func invalidar_cache() -> void: _evaluacion_cache.clear()` llamada tras `incrementar()` relevante o al recibir `herramienta_equipada`.
- Unificar `_reevaluar` y `reevaluar_sucias` para que ambos deleguen en el mismo `evaluar_condicion()`.

### Mejora 2 — Endurecer `PlayerProfile.incrementar()` / `cargar()` contra negativos, overflow y drift
```gdscript
const MAX_STAT: float = 1.0e12  # cap de sanidad anti-desbordamiento

func incrementar(stat_id: String, cantidad: int = 1) -> void:
    cantidad = maxi(0, cantidad)                     # no decrementos por la API pública
    var nuevo := float(_totales.get(stat_id, 0.0)) + float(cantidad)
    _totales[stat_id] = minf(nuevo, MAX_STAT)          # cap anti-desbordamiento
    _dia[stat_id] = minf(float(_dia.get(stat_id, 0.0)) + float(cantidad), MAX_STAT)
    _sucias[stat_id] = true
    if stat_id == "monedas_ganadas":
        _contribucion = minf(_contribucion + float(cantidad), MAX_STAT)

func cargar(data: Dictionary) -> void:
    # ... por cada k: _totales[k] = minf(maxf(float(t[k]), 0.0), MAX_STAT)
    _contribucion = clampf(float(data.get("contribucion", 0.0)), 0.0, MAX_STAT)
```
Y, por coherencia, alinear `progression.json` (30/70/150) con `vecino_amistad.gd` (20/40/140) o viceversa, de modo que los tests de balance afirmen el número real del código y no una cifra del JSON que el runtime ignora.

---

## 6. Conclusión final

**El sistema de progresión de Isla Ancestral (M71) no es un sistema de experiencia/nivel clásico.** Es un sistema de **hitos (achievements) disparados por estadísticas acumuladas**, complementado por **niveles de amistad por vecino (M20)** y **niveles de herramientas/casas (M13/M18)**. No existe carpeta `scripts/xp/`, `scripts/nivel/` ni barra de XP: la "progresión" es data-driven (`data/progresion/hitos.json`, 26 hitos) con un evaluador de condiciones de 11 tipos, caché y persistencia versionada (`SaveManager`, sección `"progresion"`).

**Fortalezas verificadas:** validación de umbrales negativos en el catálogo (`validar_catalogo`, `detectar_condiciones_imposibles`, `validar_catalogo_bloqueante`); neutralización de deltas negativos en amistad (`maxi(0, delta)`); estadística de herramienta monótona; reputación acotada 0–100; idempotencia de `marcar_hito` y `activar_desbloqueo`; persistencia que purga hitos obsoletos; suites de test con guardia anti-falso-verde (83 + 37 + 7 checks).

**Problema crítico confirmado F1:** `_reevaluar()` (`progression_manager.gd:248–253`) marca hitos sin validar su umbral. Con el camino de eventos, recolectar 10 items desbloquea también el hito de 50 y la cadena "Explorador Completo" — **toda la economía de hitos queda trivializada al primer evento**. El test `test_bug_reevaluar_m71_hy3.gd` lo reproduce de forma aislada y su cabecera declara que debe FALLAR hasta que se corrija. Es el defecto a corregir antes de cualquier otra mejora.

**Secundarios:** umbral de amistad nivel 2 incoherente (balance JSON dice 30, código usa 20); `get_progreso` puede superar 1.0; caché de condiciones sin invalidación con "LRU" que evicta entradas calientes; `PlayerProfile.incrementar`/`cargar`/`set_stat` aceptan negativos y sin cap superior; evaluadores duplicados `evaluar_condicion`/`evaluar_pura` (riesgo de deriva).

**Veredicto:** arquitectura sólida y bien testeada en catálogo/persistencia/idempotencia, pero **no apta para producción hasta corregir F1**. Corregir `_reevaluar` (Mejora 1) es una línea; endurecer `PlayerProfile` (Mejora 2) es defensa en profundidad barata. Una vez cerrado F1, el diseño data-driven + anti-exponencial (`progression.json`) es coherente con el tono cozy del juego (límites diarios, sin decaimiento, reputación por contribución+amistad).

**Archivos clave para la corrección:**
- `game/isla-ancestral/scripts/progresion/progression_manager.gd:248–253` (F1)
- `game/isla-ancestral/scripts/progresion/test_bug_reevaluar_m71_hy3.gd:68–72` (repro)
- `game/isla-ancestral/scripts/progresion/player_profile.gd:31–41` (negativos/overflow)
- `game/isla-ancestral/scripts/friendship/vecino_amistad.gd:12` (umbrales) vs `game/isla-ancestral/data/balance/progression.json:8–10`
