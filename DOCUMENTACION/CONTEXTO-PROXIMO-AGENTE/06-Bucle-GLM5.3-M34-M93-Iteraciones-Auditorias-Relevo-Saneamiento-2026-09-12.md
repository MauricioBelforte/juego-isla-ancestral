# 06-Bucle-GLM5.3-M34-M93-Iteraciones-Auditorias-Relevo-Saneamiento-2026-09-12

## Fecha
2026-09-12 (sesión de continuación 5 — ciclo completo M34+M93+Saneamiento, ~02:00 → ~04:30)

## Identidad del agente que escribió esto

**Modelo:** GLM-5.3 (flagship de Z.ai, 743B, **NO la variante flash**)
**Plataforma:** Kilo Code
**Firma definida por el usuario:** "GLM-5.3 / Kilo Code" — con ese nombre firmá todo.

⚠️ **CRÍTICO para vos (próximo agente):** si sos GLM-5.3 flagship en Kilo Code, continuás ESTA línea con ESTE backlog (`DOCUMENTACION/TAREAS-POR-MODELO/glm-5.3/BACKLOG-MASTER.md`, actualizado 2026-09-12). Si sos OTRO modelo, NO tomes estos módulos — usá tu propio backlog.

---

## Resumen ejecutivo de la sesión

Dos ciclos completos + saneamiento de infraestructura:

| # | Módulo | Iteración | Log | Progreso | Qué se hizo |
|---|--------|-----------|-----|----------|-------------|
| 1 | **M34-Pesca** | iter. 2 | 833 | 4→**84 [x]**/69 [?]/0 [ ] de 153 | Auditoría doc↔código + 3 brechas V0 (bug estaciones "todas" ROTO, bug horas perdidas, PRNG runtime→semilla M29) + tests nuevos |
| 2 | **M93-Balance** | iter. 4 por relevo §21.4.7 | 836 | 66→**112 [x]**/22 [?]/0 [ ] de 134 | Relevo legítimo + iter. 3 fantasma asimilada + auditoría 64 [ ] + 5 brechas data cerradas (minado, curvas, anti-grind, anti-exploit, rutinas) + versión 1.2.0 |
| — | **Infra** | — | — | GLOBAL | Saneamiento 810 runs mojibake de CHECKLIST-GLOBAL (script nuevo) + 4 BOM eliminados |

**Tests:** 14 suites 0 fallos total (incluyendo regresiones de M16/M33/M35/M72).  
**0 bloqueos huérfanos.** TODO liberado en los 4 registros sincronizados.

---

## CICLO 1: M34-Pesca iter. 2 (Log 833) — DETALLE COMPLETO

### Contexto previo

- **Núcleo** implementado por Deepseek V4 Flash (Log 297): `fishing_manager.gd` (306 líneas), FSM `FishingSession` (104 líneas), `FishDefinition`/`CeboDefinition`/`FishingRod` como Resources puros, `FishingSpot` stub, tests `test_fishing.gd` y `test_fishing_clima.gd`.
- **Bonos clima** implementados por glm-5.3-flash (Log 310): `_peso_efectivo()` con factor lluvia ×1.15 / tropical ×1.25, nunca filtro.
- **Estado del checklist** antes de esta iter.: solo 4 [x] marcados en todo el documento (el resto [ ] por gap de marcado masivo). El núcleo YA FUNCIONABA pero no estaba documentado como implementado.
- **El JSON `data/balance/fishing.json`** tenía SOLO 2 peces (sardina + luna) — el data M93 estaba incompleto de nacimiento. Este data es PROPIEDAD de M93; NO expandirlo desde M34.

### Brecha V0 #1 — BUG CRÍTICO: `temporadas: ["todas"]` rompía el filtro de estación

**Síntoma:** los peces con `"temporadas": ["todas"]` en fishing.json nunca aparecían como candidatos filtrados por estación, porque `_estacion_numero("todas")` devolvía `-1` y `pez.estaciones = [-1]` nunca matcheaba una estación real 0-3. Esto hacía que el filtro de estación CAYERA SIEMPRE al fallback "nunca pescar nada" (L167) — es decir, el comportamiento cozy de "siempre hay peces" era un accidente: funcionaba porque fallaba el filtro, no porque el filtro estuviera bien.

**Fix aplicado en `scripts/fishing/fishing_manager.gd` `_cargar_peces()` (línea 72-82):**
```gdscript
var temporada: Array = datos.get("temporadas", [])
if not temporada.has("todas"):
    for t in temporada:
        var est := _estacion_numero(String(t))
        if est >= 0:
            pez.estaciones.append(est)
```
Contrato FishDefinition L14: **arrays vacíos = todas**.

**Test agregado:** `_test_iter2_estaciones_todas()` en `test_fishing.gd` — verifica que sardina.tiene.estaciones.is_empty() == true Y que `_candidatas_de_estacion(estacion, 4)` devuelve sardina para las 4 estaciones (hora 4 = NOCHE, que es franja de sardina; a hora 12 sería filtrada por franja, no por estación).

### Brecha V0 #2 — BUG: `horas: [4, 20]` descartaba la segunda hora

**Síntoma:** el código original usaba solo `horas[0]`:
```gdscript
# ANTES (ROTO):
if horas.size() >= 2:
    pez.franjas = [_franja_de_hora(int(horas[0]))]
```
`horas: [4, 20]` generaba `franjas = [ALBA]` — la hora 20 (NOCHE/ATARDECER según el mapeo) se perdía.

**Fix aplicado:** cada hora del array mapea a su franja, deduplicando:
```gdscript
# DESPUÉS (CORREGIDO):
var franjas_set: Array[int] = []
for h in horas:
    var franja := _franja_de_hora(int(h))
    if not franjas_set.has(franja):
        franjas_set.append(franja)
pez.franjas = franjas_set
```

**Reflexión importante sobre el mapeo de franjas:** el archivo de contexto 04 decía erróneamente que `_franja_de_hora(4)` = ALBA. **Es NOCHE**, porque `< 5 = NOCHE`. Esto causó 4 fallos iniciales en el test que corregí después de revisar el código real (`fishing_manager.gd` L85-92). **Lección: verificar siempre el código, no las notas de contexto.**

### Brecha V0 #3 — PRNG no determinista por partida

**Síntoma:** `_prng.seed = hash(Time.get_ticks_usec())` en `_ready()` generaba semilla de entropía runtime — cada inicio de juego daba diferente secuencia de peces/tamaños. Violaba el checklist E.10/F.7 ("PRNG de partida reutilizado") y el diseño §2.5.

**Fix aplicado:** uso de la semilla canónica M29 H120:
```gdscript
func _ready() -> void:
    _prng = RandomNumberGenerator.new()
    var gt := get_node_or_null("/root/GameTime")
    if gt and gt.has_method("rng_diario"):
        _prng = gt.rng_diario("m34")
    _cargar_peces()
```
Fallback: si GameTime no existe (headless/test puro), semilla 0 estable (determinista global).

### Extracción de función para testabilidad

Reutilicé el patrón de Log 310 (_peso_efectivo extraído):
```gdscript
# NUEVO en fishing_manager.gd L205-214:
func _candidatas_de_estacion(estacion: int, hora: int = 12) -> Array:
    var franja_actual: int = _franja_de_hora(hora)
    var candidatas: Array = []
    for pez in _peces:
        if pez.estaciones.size() > 0 and not pez.estaciones.has(estacion): continue
        if pez.franjas.size() > 0 and not pez.franjas.has(franja_actual): continue
        candidatas.append(pez)
    return candidatas
```
`resolver_especie` ahora llama a `_candidatas_de_estacion` en vez del filtro inline.

### Tests agregados (test_fishing.gd)

Bloque `_test_iter2_prng_semilla_m29()`:
- Verifica `GameTime.rng_diario("m34")` produce misma secuencia entre dos instancias (reproducible mismo día).
- Verifica namespace aislado: `rng_diario("m34")` ≠ `rng_diario("m34_otro")`.

Bloque `_test_iter2_filtro_estacion_verano()`:
- Simula las 4 estaciones con hora 4 (NOCHE, franja de sardina).
- Verifica sardina candidata en TODAS las estaciones POR REGLA (no fallback).
- Verifica luna solo candidata en verano (verano=1).

### Regresión post-iter. 2

| Suite | Resultado |
|---|---|
| `test_fishing.gd` | 0 fallos (7 bloques) |
| `test_fishing_clima.gd` | 0 fallos |
| `test_semilla_iter1.gd` (M29) | 25/25 |
| `test_consumidores_tiempo.gd` (M29) | 12/0 |
| `test_logros.gd` (M72) | 0 fallos |
| `test_clima.gd` (M32) | 0 fallos |

### Archivos modificados (ciclo 1)

- `game/isla-ancestral/scripts/fishing/fishing_manager.gd` — fix ×3 + extracción `_candidatas_de_estacion`
- `game/isla-ancestral/scripts/fishing/test_fishing.gd` — 4 bloques nuevos
- `DOCUMENTACION/34-Pesca/plan-actual/05-Checklist.md` — auditoría 4→84 [x]
- `DOCUMENTACION/34-Pesca/plan-actual/04-Codigo.md` — §0 con rutas REALES (las §1/§2 del diseño eran aspiracionales: FishingMinigameUI.gd y FishCollectionData.gd NO existen)
- REGISTROS coordinadores: CHECKLIST-GLOBAL fila 34, guía 08 fila M34, ESTADO-PARALELO.

---

## CICLO 2: M93-Balance iter. 4 por relevo §21.4.7 (Log 836) — DETALLE COMPLETO

### El relevo (§21.4.7)

La reserva de glm-5.3-flash era del **2026-09-01 01:00** (iter. 3: tablas friendship/quests/puzzles/unlocks/meta-rareza). Al cierre del usuario, llevaba **11 días sin actividad ni log** confirmado. Antes de reclamar verifiqué:

1. **CHECKLIST-GLOBAL:** fila 93 última actividad 2026-08-30.
2. **ESTADO-PARALELO:** sin entrada M93 reciente de flash.
3. **Logs/reservas/:** ninguna reserva activa de flash sobre M93.
4. **Logs/*.md:** último log M93 fue 333 (2026-09-01). Logs 834/835 fueron de Hy3 (M10/M11 QA cruzado).
5. **Disco:** confirmé que las tablas v2 de flash EXISTEN en `data/balance/`.

**Conclusión:** relevo legítimo. Reservé log 836 (bucle §6.1.a completo) y bloqué M93 en los 4 registros.

### Hallazgo: iter. 3 FANTASMA materializada sin log

El trabajo de flash **SÍ existía en disco**:
- `friendship.json` v2: generosidad ×3, umbrales 30/70/120/150/260, beneficios_por_nivel (recetas/descuento/trueque/especial/eventos/secretos).
- `quests.json` v2: misiones secundaria (15 AO) y principal (200 AO + fragmento_ancestral), reglas items_exclusivos_no_monetizables, bonus_eventos_temporada.
- `puzzles.json` v2: 2 puzzles con tiempos 20/45 min, templo herramienta única no monetizable, ruinas lore.
- `unlocks.json` v2: orden_global ascendente, cosméticos sink AO, museo_records_no_monetarios.
- `meta.json` (antes de mi iter.): rareza con pity (incremento 0.1/fallo, cap 2×, reset), rendimiento.nodos_activos_max_por_chunk = 8, viajes.recompensa_descubrir_ruta_ao = 25.
- `test_balance_m93_iter3.gd`: 6 bloques testeando cada tabla (0 fallos).

**Lección crítica:** "sin log" NO significa "sin trabajo" — siempre verificar el DISCO antes de descartar un trabajo previo.

### Auditoría: 66 → 112 [x] con evidencia

De los 64 [ ] pendientes, cerré 46 marcándolos con evidencia real (ya estaban cubiertos por las tablas v2 o por reglas ya implementadas):

**Por gap de marcado (había que verificar y marcar):**
- **B.4 (pity):** meta.json ya contenía la regla `rareza.pity` con todos los campos. Test iter3 lo verificaba.
- **H.3 (items exclusivos):** quests.json reglas.items_exclusivos_no_monetizables = true + mision_principal_acto1 items_exclusivos = true.
- **K.1 (rutina ≤30 min):** validate R7 (R7 ya verificaba sesion_rutina_total_min ≤ 30). Timing ya tenía el dato.
- **K.3/K.4 (ausencia benigna):** rules de M94 en friendship (sin_decaimiento_por_ausencia) y farming (sin muerte por ausencia).
- **K.5 (estaciones rotativas):** M29 (TimeCalendar ESTACION_POR_MES cíclico).
- **L.3-L.5 (curvas):** parcialmente... pero estas NO estaban en el JSON anterior — las agrego yo en este ciclo.
- **P.2/P.3/P.4:** reglas de validate_balance ya existentes (R7/R8/R8b) — marcarlas como cerradas con evidencia de ejecución.
- **X.1/X.3:** validate R1 (márgenes) y R8b (sellos sin grind) ya testeados exhaustivamente — los había marcados pero no con la evidencia de cobertura total.
- **W.3/W.5:** arquitectura O(1) por diseño (get_* son dict.get, sin proceso por frame); medición de facto (tests corren en <2s incluyendo toda la carga).
- **Q.2/Q.3:** grep REAL de consumidores: `crafting_service.gd` L67-69 y `farm_service.gd` L67-69.
- **Q.4 (pesca):** M34 lee fishing.json DIRECTO, no por BalanceService. Documentar esta dualidad como decisión de arquitectura.
- **Z.1-Z.4:** evidencia de consumidores reales (T7 amistad M38 consume umbrales M93; test iter3 ejecuta servicio M20 real; M94 hereda reglas de ausencia; M153 contract).

### Brechas V0 de DATA cerradas (5 nuevas)

**1. mining.json v2 — D.4 (tiempo de minado):**
```json
"reglas_minado": {
    "golpes_base_por_dureza": {"blanda": 2, "media": 4, "dura": 6},
    "segundos_por_golpe": 1.5,
    "duracion_max_min": 2,
    "coherencia_m35": "MiningVeinCatalog (data/mining/ores.json) define las vetas del mundo; esta tabla define el RITMO económico."
}
```
Cada mineral también tiene `golpes_para_extraer` (3/5/8 para cobre/hierro/piedra_preciosa).

**2. progression.json v2 — L.2/L.3/L.4/L.5 (curvas de progresión):**
- `curvas_recursos_acumulados`: día 1/7/28/90 con tope soft día 28+.
- `curva_amistad_total`: semana 1/4/12: 6/20/45 niveles totales.
- `curva_colecciones`: semana 1/4/12: 10%/35%/70%.
- `reglas_curvas.no_exponencial: true` (declaración explícita de la regla).

**3. meta.json v3 — M (anti-grind) + N (anti-exploit):**
- `reglas_anti_grind`: repeticion_max_sin_progreso = 4, tope_ventas_diarias_ao = 600, temporada_ciclica_sin_fomo = true, coleccion_sin_dia_unico = true, bonus_retorno (+5 AO/día tope 150).
- `reglas_anti_exploit`: bucles_identificados (regar+vender, pescar+vender, minar+craftear con contramedidas), techo_bucle_vs_diseño_pct = 115, reloj_interno_independiente = true, limite_items_vendidos_dia_categoria = 20.

**4. timing.json v2 — K.1/K.2/K.3/K.4/K.5 (rutinas completas):**
- `rutinas.rutina_optima`: 30 min reales, 5 pasos listados, progreso_diario_garantizado.
- `rutinas.sesion_libre_1_2h`: rango [60, 120], bloques sugeridos.
- `rutinas.cultivos_sin_muerte`: mueren_por_ausencia = false.
- `rutinas.estaciones_rotativas`: 28 días/estación, contenido_rotativo listado.

**5. Version bump:** balance_version 1.1.0 → **1.2.0** (regla U.3).

### Test nuevo: test_balance_m93_iter4.gd (7 bloques, 0 fallos)

- `_test_minado_d4`: verifica golpes_para_extraer > 0 y reglas_minado presentes.
- `_test_curvas_no_exponenciales`: calcula pendientes por tramo en las 3 curvas y verifica decrecimiento matemático.
- `_test_anti_grind`: verifica repeticion_max ≤ 4, tope ventas ∈ [rutina, 10×rutina], temporada cíclica, colección sin día único, bonus retorno.
- `_test_anti_exploit`: 3 bucles identificados con contramedidas, techo 115%, reloj independiente, límite 20/día/categoría.
- `_test_rutinas_k`: rutina ≤30, rango 60-120, cultivos sin muerte, 28 días/estación.
- `_test_version_120`: balance_version == "1.2.0".
- `_test_integraciones_q`: tablas legibles para M16/M33/M34.

### Fix colateral: test iter3 desacoplado del bump de versión

`_test_version()` original exigía == "1.1.0" exacto; ahora acepta >=1.1.0 semánticamente (compara partes del version string). Evita que cada bump rompa el test de la iter. anterior.

### Regresión total

| Suite | Módulo | Resultado |
|---|---|---|
| test_balance_m93_iter4.gd | M93 NUEVO | 0 fallos |
| test_balance_m93_iter3.gd | M93 | 0 fallos |
| test_balance.gd | M93 | 0 fallos |
| validate_balance.gd | M93 | 0 fallos |
| test_crafting.gd | M16 (consumidor) | 0 fallos |
| test_pergaminos_tienda.gd | M16 | 0 fallos |
| test_farm.gd | M33 (consumidor) | 0 fallos |
| test_farm_clima.gd | M33 | 0 fallos |
| test_mineria.gd | M35 | 0 fallos |
| test_fishing.gd | M34 (del ciclo 1) | 0 fallos |
| test_fishing_clima.gd | M34 | 0 fallos |

**Total: 11 suites, 0 fallos.**

### Archivos modificados (ciclo 2)

- `game/isla-ancestral/data/balance/mining.json` (v2)
- `game/isla-ancestral/data/balance/progression.json` (v2)
- `game/isla-ancestral/data/balance/meta.json` (v3)
- `game/isla-ancestral/data/balance/timing.json` (v2)
- `game/isla-ancestral/scripts/balance/test_balance_m93_iter4.gd` (NUEVO)
- `game/isla-ancestral/scripts/balance/test_balance_m93_iter3.gd` (fix versión)
- `DOCUMENTACION/93-Balance/plan-actual/05-Checklist.md` (auditoría completa)
- `DOCUMENTACION/93-Balance/plan-actual/04-Codigo.md` (Notas del Agente iter. 4)
- REGISTROS coordinadores: CHECKLIST-GLOBAL, guía 08, ESTADO-PARALELO.

---

## SANEAMIENTO DE INFRAESTRUCTURA (§28)

### Problema: mojibake masivo en CHECKLIST-GLOBAL.md

El archivo tenía **810 runs de mojibake REAL** en 40+ filas de la tabla. El problema era doble-codificación UTF-8→cp1252→UTF-8 (ejemplo: el emoji 🟡 (U+1F7E1) quedó como `🟡` (U+00F0 U+0178 U+0178 U+00A1)).

**Diagnóstico paso a paso:**
1. Bytes crudos del archivo: `C3 B0 C5 B8 C5 B8 C2 A1` → interpretado como UTF-8 da los chars ð Ÿ Ÿ ¡.
2. Esos mismos chars, decoded como cp1252 → bytes `F0 9F 9F A1` → re-decoded como UTF-8 → **🟡**. Correcto.
3. Patrón general: cada run de chars no-ASCII consecutivos que sean mapeables a cp1252 Y cuyo resultado decodifique como UTF-8 válido son mojibake reversible.

### Script creado: `scripts/saneamiento_utf8.py`

Script reutilizable que:
- Lee archivo como UTF-8.
- Por cada run de chars no-ASCII consecutivos en una línea: intenta decode cp1252 → redecode UTF-8.
- Si el resultado es limpio (sin U+FFFD, sin error de parseo): reemplaza el run.
- Si algún char no mapea a cp1252 o el resultado tiene FFFD: deja el run intacto (safe).
- soporta `--dry-run` (simula sin escribir) y `--backup` (crea copia con timestamp).

**Por qué es seguro:** un run legítimo de 1 char no-ASCII (ñ, é) nunca decodifica como UTF-8 válido tras cp1252 (un byte ≥0x80 aislado es lead byte sin continuadores). Solo secuencias de 2+ chars mojibake colisionan. En la práctica, esto saneó 810 runs de forma 100% reversible.

**Backup:** `CHECKLIST-GLOBAL.md.bak_2026-09-11_23-21-57`.

### BOMs eliminados

4 BOMs UTF-8 (EF BB BF) encontrados y removidos:
- `scripts/logros/achievement_service.gd` (preexistente de otra sesión)
- `scripts/progresion/player_profile.gd` (preexistente)
- `scripts/progresion/progression_manager.gd` (preexistente)
- `scripts/fishing/fishing_manager.gd` (introducido por mí vía edit tool — lección 29)

Regla nueva: **byte-scan EF BB BF después de CADA edit de código, no solo de docs.**

### Bug preexistente NO tocado

10 push_error `[VAL-DGV] nodo 'inicio': condicion usa clave de mundo desconocida 'new_level'` en `test_logros.gd`. Fuente: `data/dialogues/reaccion_nivel.json` (M22/M71) usa clave "new_level" que el validador de diálogo no reconoce. **No es de M34 ni M93. Registrado en Log 833 pero no tocado** (no tocar módulos ajenos §21.4). Recomendación: registrar en DOCUMENTACION/11-BUGS.md.

---

## Estado del proyecto al cerrar la sesión

### Módulos de la línea GLM-5.3 (resumen)

| Módulo | Estado | Progreso | Log | Qué falta |
|---|---|---|---|---|
| M38-Economía | ✅ | 163/163 | 823 | QA cruzado §21.8 (Hy3) |
| M29-Tiempo | 🟡 | 194/195 | 824 | 1 [?] flecha HUD (M53) |
| M30-Reloj | 🟡 | 98/104 | 827 | 2 [?] externos |
| M31-Ciclo-Día-Noche | 🟡 | 115/169 | 829 | 54 [?] con dueño |
| M32-Clima | 🟡 | 96/121 | 830 | 25 [?] con dueño V2 |
| **M34-Pesca** | 🟡 | **84/153** | **833** | 69 [?] con dueño (M93/M52/M53/M51/M14/M15/M105/M57/M37) |
| **M93-Balance** | 🟡 | **112/134** | **836** | 22 [?] (simulación O = brecha grande restante; telemetría/playtest/polish) |

### Reservas activas (protocolo)

- `Logs/reservas/835-HY3-M11.txt` — **NO ES MÍA**. Es residuo de WorkBuddy (su log 835 ya escrito en disco). No borrar ni modificar. Próximo número libre potencial: **837**.

### ULTIMO_NUMERO.txt

Contiene **836** (escrito por mí, sin BOM). El archivo original tenía BOM que saneé durante la escritura.

### M145/M146/M149 — verificados y descartados

Todos sus pendientes son **[?] de fase jugable** (testing con jugadores reales, playtesting emocional, hablantes nativos). No hay NADA V0 tomable — cerrarlos sería "por hacer" prematuro. NO tomar hasta fase jugable.

---

## Próximos pasos para el próximo agente GLM-5.3

### Prioridad 1: M93-Balance iter. 5 (SIMULACIÓN ECONÓMICA)

Es la brecha grande restante del módulo y ahora tiene TODO el input listo:

**Lo que necesita `simulate_economy.gd`:**
- 3 perfiles de jugador: rutinario (30 min/día), diligente (90 min/día), minimalista (10 min/día).
- Escenarios: 60/180/365 días.
- SimularAO_diario() usando rewards.json, prices.json, farming.json, fishing.json, timing.json.
- Verificar: ningún pipeline supera el techo 115% del diseño (regla N.2).
- Salida: AO_total, recursos_por_pipeline, desvío_vs_diseño %.
- Exit code != 0 si detecta exploit o desvío > umbral (patron validate_balance).
- Opcional: ejecutar en CI (M118) cuando exista el job.

**Complemento: catálogo de pesca completo (25 peces)**
- Formato documentado en 04-Codigo M34 §0b (temporadas/horas/clima/probabilidad/pity/peso_kg/precio_venta).
- Distribución sugerida: ~15 comunes, 6 poco comunes, 3 raros, 2 legendarios, 2 ancestrales.
- El simulador necesita el catálogo real para simular pescar+vender.

### Prioridad 2: M18-Casas (SOLO si WorkBuddy liberó M18-BIS)

Verificar ANTES: CHECKLIST-GLOBAL fila 18 + ESTADO-PARALELO + Logs/reservas. Última actividad de WorkBuddy en M18-BIS fue 2026-09-05 (glm-5.3-free). Si no hay 🔵 activo y pasó más de 24h → relevo legítimo.

### Prioridad 3: M35-Minería (82 [ ])

Núcleo implementado por minimax-m3-free (iter. 1), pero con 82 pendientes. Sin relevos activos verificados — verificar Estado-PARALELO antes de tomar.

### NO tomar (verificado esta sesión)

- **M153** (fase jugable/telemetría).
- **M145/M146/M149** (fase jugable, todos [?] de testing con jugadores).
- **M41/M42** (🔵 agnes-2.5-flash, no tocar).
- **M28/M37/M71/M72/M158** (Recom = flash/agnes; relevo §21.4.7 SOLO si 24h+ sin actividad verificada).

---

## Errores/fixes documentados en esta sesión

### Error: confiar en el archivo de contexto 04 para el mapeo de horas

El archivo 04 decía: `_franja_de_hora(4)` = ALBA. **Error:** es NOCHE. Causó 4 fallos de test que corregí verificando el código real (`fishing_manager.gd` L85-92). **Lección 30: verificar siempre el código, no las notas de contexto.**

### Error: parser de PowerShell false-positivo con JSON con TABs

`ConvertFrom-Json` de PowerShell reportó "Primitivo JSON no válido" para progression.json que SÍ era válido. El error REAL era un `}` extra en la línea 40 (cierres dobles) que el parser de Godot detectó correctamente ("Expected 'EOF' at line 39"). **Lección 27: validar JSON de data con script headless de Godot de 5 líneas, NUNCA con el parser de PowerShell.**

### Artefacto de highlight de rg

`rg -n "Balance"` mostró `func n()` en vez de `func get_progression()` — era ARTEFACTO del highlight/corte, no corrupción real del archivo. **Lección 28: verificar con Select-String antes de "arreglar" archivos sanos.**

---

## Comandos de regresión para el próximo agente

```powershell
$godot = "D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe"
$game = "<raíz>\game\isla-ancestral"

# M34 (ciclo 1):
& $godot --headless --path $game -s res://scripts/fishing/test_fishing.gd         # 7 bloques, 0 fallos
& $godot --headless --path $game -s res://scripts/fishing/test_fishing_clima.gd  # 0 fallos

# M93 (ciclo 2):
& $godot --headless --path $game -s res://scripts/balance/test_balance_m93_iter4.gd  # 7 bloques NUEVO
& $godot --headless --path $game -s res://scripts/balance/test_balance_m93_iter3.gd  # 6 bloques
& $godot --headless --path $game -s res://scripts/balance/test_balance.gd            # suite base
& $godot --headless --path $game -s res://scripts/balance/validate_balance.gd        # 10 reglas

# Consumidores M93:
& $godot --headless --path $game -s res://scripts/crafting/test_crafting.gd          # M16
& $godot --headless --path $game -s res://scripts/crafting/test_pergaminos_tienda.gd # M16
& $godot --headless --path $game -s res://scripts/farm/test_farm.gd                  # M33
& $godot --headless --path $game -s res://scripts/farm/test_farm_clima.gd            # M33
& $godot --headless --path $game -s res://scripts/mineria/test_mineria.gd             # M35

# Diagnóstico rápido de JSONs editados (lección 27):
# Crear script headless temp con 5 líneas: abrir JSON, JSON.parse_string, print keys, quit(0)
```

---

## Pendiente del USUARIO (no del agente)

1. **Abrirle sesión a Hy3 (WorkBuddy) para QA cruzado §21.8** de la línea. M38 (primer ✅), M29, M30, M31, M32, M34, M93. Hy3 YA está activo haciendo QAs (logs 834/835).
2. **Registrar bug VAL-DGV new_level** (M22/M71) en `DOCUMENTACION/11-BUGS.md` — 10 push_error en test_logros desde `data/dialogues/reaccion_nivel.json`.
3. **V1 verificación in-game del cableado M13→M15** (tecla 2 hacha → árbol → E). De la sesión 01, sigue pendiente.
4. **Verificación visual opcional del respawn estacional M15** (print `[M15] estación cambió`).

---

## Scripts útiles creados en esta sesión

| Script | Propósito | Uso |
|---|---|---|
| `scripts/saneamiento_utf8.py` | Saneamiento selectivo de mojibake cp1252→UTF-8 | `python scripts/saneamiento_utf8.py <archivo> [--dry-run] [--backup]` |

---

**Modelo:** GLM-5.3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-12 ~04:30
**Estado:** Sesión cerrada. 2 ciclos completados, saneamiento de infra completado, BACKLOG-MASTER actualizado, 0 bloqueos huérfanos.
