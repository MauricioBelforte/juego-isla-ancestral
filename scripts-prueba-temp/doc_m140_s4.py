# -*- coding: utf-8 -*-
import io
p = "DOCUMENTACION/140-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """### 2.4.1 Balance de Alpha (cerrada 2026-10-14, step-5-kilocode)

Cierra la seccion 4 del checklist. Base verificada: 69 scripts de balance en `scripts/` (incluidos
`balance_service.gd`, `test_balance_m93_iter3.gd`, `test_balance_m93_iter4.gd`,
`validate_balance.gd`), mas **57 hits de estacional/temporada** y 29 de regalo.

**Curvas Alpha (definicion):** 7 curvas — precios (lineal en rutina, logaritmica en metas largas,
ya definida en M139 2.5.1), drops (lineal con techo por isla), XP (curva suave: nivel N cuesta
1.15^N), amistad (lineal con aceleracion en el ultimo nivel), puzzles (dificultad por numero de
emisores, ya en `puzzle_dificultad.gd`), cultivos (tiempo de crecimiento por estacion) y dificultad
global (3 presets de M93). **Nota honesta:** el archivo `data/balance/curvas.json` NO existe — las
curvas viven distribuidas en cada `test_balance_m93_iter*.gd`.

**Simulacion M93 en CI con 3 escenarios:** ya existe la simulacion (`test_balance_m93_iter3/4.gd`,
69 scripts de balance). Los 3 escenarios nombrados (productivo, completista, administrador) se
definen aqui como perfiles de la misma simulacion — **no existen como tales** (0 hits de
"completista"/"administrador").

**Umbral de 40 h simuladas:** definido aqui como criterio de CI — 40 h de juego simulado sin
alertas criticas de curva. Hoy el umbral verificado es de 30 h (M93/M139 seccion 5).

**Playtest dirigido mensual con oro/hora:** definido aqui — una sesion mensual midiendo oro por
hora por escenario, volcada al reporte semanal. No existe instrumentacion de oro/hora (0 hits).

**Feature freeze de balance:** definido aqui — 2 semanas antes del GONOGO-BETA se congelan las
curvas; solo se permiten correcciones de bugs, no ajustes.

**Margenes por categoria (55-70%):** ya definidos y verificados en M139 2.5.1 (el jugador vende al
55-70% del precio base).

**Anti-grind y anti-exploit:** ya definidos en M139 2.5.1 — precio de compra +5% por unidad en la
misma sesion, tope 25%. Para Alpha se extiende a los flujos nuevos (regalos y cocina).

**Balance de regalos de amistad por afinidad (M20/M93):** definido aqui — el valor de un regalo
sube con la afinidad (nivel 1-4: x1, x1.5, x2, x3) y ningun regalo supera el 10% del oro diario
estimado. Nota: la "afinidad" como variable no existe (0 hits); hoy la amistad se mide por nivel.

**Balance de recetas por isla (M16/M93):** **deuda real** — `crafting.json` tiene solo 7 recetas
(de las 60+ que pide M16). El balance por isla no se puede hacer sobre 7 recetas.

**Balance de temporada:** respaldado — 57 hits de estacional/temporada, incluidos
`test_balance_m93_iter3/4.gd` y `test_mercado_estacion_ferias.gd`. Los precios estacionales de
cultivos se definen aqui (x1.2 en estacion de cosecha, x0.8 fuera).

**Reporte de balance semanal (M104):** definido aqui — resumen semanal automatico con oro/hora,
curvas fuera de rango y top de items explotados; sale del `BudgetProfile` + telemetria local.
"""

ancla = "### 2.5 Rendimiento (RF6)"
if ancla in t:
    t = t.replace(ancla, seccion.rstrip() + "\n\n" + ancla, 1)
    print("seccion 2.4.1 insertada")
else:
    print("AVISO: ancla no encontrada")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("ok")
