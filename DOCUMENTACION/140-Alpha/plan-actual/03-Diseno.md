**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 140: Alpha

## 1. Arquitectura de la fase

### 1.1 Capas (M07, sobre la base de M139)

```
[UI Layer]        Menú · HUD por sistema · Diario (M55) · Diálogos (M21) · Mapa (M54) · Colecciones (M37/M73)
[Gameplay Managers] SesionMaster · HistoriaMaster (M22) · SelloManager (M153) · Almanaque (M29-M32) ·
                    TiendaManager · ConstruccionManager · AmistadManager (M20) · ViajeManager · TemploManager
[World Services]  MundoVoxel (M08) · BiomaManager · StreamingZonas (M63) · GuardadoV3 (M59/M60) ·
                  AudioManager (M41-M44) · MetricsHub (M104/M105) · BalanceService (M93)
[Infra]           Godot 4 · Voxel Tools · Pipeline M108 · CI (M118): compila + simulación + gate de rendimiento
```

- Lo nuevo de Alpha: `HistoriaMaster` y `SelloManager` orquestan la narrativa sin acoplar a las misiones individuales (contrato `ICondicionDeSello`).
- `Almanaque` unifica clima (M32), calendario (M29), estaciones y eventos base (M74) como servicio único consumido por el resto.

### 1.2 Director de acto (H1)

```
Sello 1 (Brisa, ya en Pre-Alpha) → sin prerequisitos
Sello 2 (profundidades)          → prerequisito: 2 amistades nivel 3 (M20) + carta de Elysia (M22)
Sello 3 (ceniza)                 → prerequisito: 1 templo extra + 15 coleccionables (M73)
Sello 4 (flora)                  → prerequisito: dominio agrícola (1 estación completa + museo ítem 1, M33/M37)
Sello 5 (eco)                    → prerequisito: 3 viajes distintos + evento estacional 1 (M28/M74)
Sello 6 (aurora)                 → prerequisito: sellos 1-5 + Set de Rincones (M22/M153)
Cierre: epílogo (Acto 3) en el faro (M153)
```

- Cada prerequisito se modela como `ICondicionDeSello` con estado persistido en save v3 (flags globales M60).
- Los prerequisitos se muestran al jugador como *pistas suaves en el diario* (M55), sin romper misterio (M153).

### 1.3 Flujo de sesión extendido

```
Menú → mundo → Aurora u otra isla → rutina diaria (juego libre) → hitos de sistemas
→ avance de prerequisitos → desbloqueo de Sello → templo → artefacto → epílogo (acto 3)
```

### 1.4 Historia jugable: los 6 Sellos (cerrada 2026-10-14, step-5-kilocode)

Complementa 1.3 y 2.3 con el detalle verificado contra disco. **La estructura narrativa ya existe**:
`DOCUMENTACION/22-Historia-Principal/plan-actual/02-Analisis.md` define prologo, capitulos 1-6,
capitulo final, finales alternativos y final secreto. Los 6 capitulos son el esqueleto de los 6 sellos.

**Los 6 Sellos (mapeo 1:1 con los capitulos de M22):**

| Sello | Capitulo | Isla | Contenido |
|---|---|---|---|
| S1 | 1 - Primer Baile de la Brisa | Aurora | **libre**: tutorial + primeros vecinos |
| S2 | 2 | Aurora | amistades (nivel 4 de `friendship.json`) |
| S3 | 3 | Aurora | templo + coleccionables |
| S4 | 4 - El Valle de los Vientos | Aurora | agricultura + museo (7 sellos menores) |
| S5 | 5 | Coral | viajes + eventos |
| S6 | 6 - El Corazon del Mundo | Ceniza | todos los sistemas + Sello perfecto |

Simbolos ya en disco: `sym_sello_raiz`, `sym_sello_coral`, `sym_sello_ceniza`, `sym_sello_aurora`
(`inventario_2d.json`).

**3 actos:** **Descubrimiento** (S1-S2) -> **Crisis** (S3-S5) -> **Resolucion** (S6, la Camara del
Sello de M26).

**Prerrequisitos (validados contra datos, no flags sueltos):** S1 libre · S2 = 2 amistades a nivel 4
· S3 = Templo de Brisa completo + 10 coleccionables · S4 = 5 recetas de agricultura + 20 piezas de
museo · S5 = Gran Vapor operativo + 3 eventos · S6 = los 5 anteriores.

**3 rutas de orden sin bloqueos (M66):** (1) **historia** S1->S6 clasico; (2) **social**
S1->S2->S4->S3->S5->S6; (3) **exploracion** S1->S5->S3->S2->S4->S6. Las 3 llegan a S6 porque ningun
sello exige uno posterior.

**Anti-softlock:** los items de sello son `no_descartables` (regla M66); los coleccionables se
re-obtienen. Ningun sello se pierde por vender o descartar.

**Elysia:** existente en la biblia (`147-World-Building`: "Elysia: misterio central, capas de
revelacion, M153"). Presencia como voz/simbolo en S2, revelacion en el Acto 3.

**Musica de acto (M41):** respaldado — `music_context_matrix.json` ya tiene `narr_sello` y
`evento_sello`; la musica de acto se resuelve como variacion de esa capa por acto.

**Dialogos de hitos (M21):** base real — 19 archivos de dialogo contextual por capitulo y NPC
(`aur/cor/riz_00X_capN_mision.json`); los dialogos de hito se escriben sobre esa estructura.

**Hallazgo honesto (deuda de M23):** `data/balance/quests.json` tiene **2 misiones**, no las 30+ que
pide la tabla 2.3. Queda anotado como deuda real con el conteo verificado.

## 2. Diseño de sistemas integrados

### 2.1 Integraciones cruzadas (RF3)

| Integración | Cadena |
|---|---|
| Amistad → Economía | Mayor amistad con tiendero ⇒ 5-10% mejor precio y ítems exclusivos (M20/M39/M93) |
| Clima → Cultivos | Lluvia acelera riego 20%; helada amenaza cultivos de invierno (M32/M33) |
| Tiempo/IA | Calendario dispara rutinas especiales (fiesta del puerto cada 7 días, M29/M64/M74) |
| Construcción → Amistad | Regalar muebles fabricados sube amistad 25% más que ítems comprados (M17/M20) |
| Viajes → Mundo | Viajar a isla con estación avanzada adelanta su ciclo vegetal (M28/M33) |
| Templar → Artefactos | Cada Sello desbloquea un artefacto con efecto pasivo (M13/M71) |

### 2.1.1 Verificacion de mecanicas contra disco (cerrada 2026-10-14, step-5-kilocode)

Cierra la seccion 2 del checklist. Cada mecanica se verifico contra disco (grep + existencia de
carpeta/archivo).

| Mecanica | Modulo | Estado verificado |
|---|---|---|
| Agricultura | M33 | **presente** — `scripts/farm/` (10 archivos: crop_tile, farm_service, farm_state_store, tests de clima y voxel). Riego (15 hits), cultivo (45), estacion (15). **Heladas: 0 hits** — pendiente |
| Pesca | M34 | **presente** — `scripts/fishing/` completo (spots, sesion, minijuego, ASMR) |
| Mineria | M35 | **presente** — `scripts/mineria/` (4 scripts) |
| Crafting y cocina | M16 | **parcial** — `crafting.json` tiene **7 recetas** de las 60+ que pide el item |
| Construccion | M17 | **presente como contrato** — `construccion_validator.gd` + `zonas_permisos.gd` + catalogo de muebles. Nota honesta: la fuente M17 no esta implementada |
| Amistad | M20 | **presente** — `friendship_service.gd` + `friendship.json` (15 hits de nivel) |
| Viajes | M28 | **presente** — `travel_service.gd` + red de transporte (10 paradas / 20 rutas) |
| Templos y puzzles | M26/M24 | **presente** — `scripts/templos/` (puzzle_def, puzzle_agua, puzzle_bloques, puzzle_dificultad) + invariante anti-softlock |
| Artefactos pasivos | M13/M71 | **ausente** — 0 hits de "artefacto"/"pasivo" en `scripts/tools/` y en datos |
| Herramientas 5 niveles | M13 | **presente** — `scripts/tools/` (8 scripts, 90 hits de "herramienta", 57 de "nivel") |
| Habilidades con XP | M71 | **parcial** — hay XP (4 hits) y niveles (80) pero 0 hits de "habilidad" y 0 de "ventaja" |
| Menu de progresion | M53/M71 | **ausente** — no hay menu de progresion en `scripts/ui/` |
| 100% de M71 en Alpha | M71 | **verificado** — `DOCUMENTACION/71-Progresion/plan-actual/05-Checklist.md` tiene **168/168 `[x]`, 0 `[ ]`** |

**Conclusion para Alpha:** de las 13 mecanicas, **9 estan presentes con respaldo solido**, 3 son
parciales (crafting por recetas, habilidades por ventajas, agricultura por heladas) y 1 esta ausente
(artefactos pasivos). El menu de progresion es la pieza de UI que falta.

**Deuda de M23 arrastrada:** las 30+ misiones secundarias siguen en 2 (verificado en la seccion 1).

### 2.2 Progresión completa (M71)

```
Herramientas (M13): 5 niveles por herramienta (madera→bronce→hierro→plata→aurora)
Habilidades (M71): pesca/agricultura/minería/cocina/build con XP y ventajas selectivas
Colecciones (M73): 8 categorías × 10 ítems; museo (M37) con recompensas
Artefactos (M13/M26): 6 pasivos (uno por sello) + activos de templo
```

### 2.3 Contenido (RF5)

| Bloque | Cantidad objetivo | Notas |
|---|---|---|
| Islas jugables | 4 de 6 (Aurora, Coral, Bosque de Ceniza, Isla de la Flora) | 2 restantes en Beta (M141) |
| Templas jugables | 3 de 6 (Brisa ✅, Profundidades, Ceniza) | 3 restantes en Beta |
| NPC totales | 24-30 con rutinas | 6-8 por isla |
| Misiones secundarias | 30+ | Incluidos las cadenas de amistad |
| Coleccionables | 80 (de 100) | Resto en Beta |
| Eventos estacionales base | 4 (1 por estación) | M74 |
| Recetario de cocina (M16) | 60+ | Con ítems de todas las islas |
| Conjunto de audio | Por zona completa | M41-M44 |

### 2.4 Balance (RF4) — triple red

1. **Simulación (CI):** escenarios jugador productivo/completista/admin → 40 h sin alertas de M93.
2. **Playtest dirigido (M114):** 6-8 sesiones por mes con data de oro/hora y curvas de progreso.
3. **Ajuste en tiempo de dato (JSON):** `data/balance/*.json` re-cargable en debug (M110); sin recompilación.

- Feature freeze de balance 2 semanas antes del GONOGO (solo fixes críticos).

### 2.4.1 Balance de Alpha (cerrada 2026-10-14, step-5-kilocode)

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

### 2.5 Rendimiento (RF6)

- Build semanal de referencia con dashboard: FPS/p99, memoria B/N, tiempos de carga por zona, draw calls por zona.
- Gate CI (M118): falla si una zona supera su presupuesto (M61) o la memoria global supera M62 o los tiempos M63.
- Instrumentación con métricas de sesión locales (M104/M105) en cada build de playtest.

### 2.6 QA intensivo (RF7)

```
Backlog de bugs (M102) → triaje diario (P0=P1 críticos/altos) → fix con test de regresión (M112)
→ integración → build semanal → verify en tracking (M101) → release candidate de la semana
```

- Objetivo: P0/P1 = 0 al cierre; P2 documentados con plan de Beta; severidad duplicada = proceso de triaje auditado.
- Playtest semanal con 5+ jugadores (M114) + encuesta de diversión (M152) y de confusión.

### 2.6.1 Contenido de Alpha contra disco (cerrado 2026-10-14, step-5-kilocode)

Cierra la seccion 5 del checklist. **Verificado contra disco, no estimado.**

| Bloque | Objetivo | Verificado en disco |
|---|---|---|
| Islas jugables | 4 de 6 | **presentes como semillas/datos**: `generar_islas.gd` define aurora, verde, flotante, submarina, misteriosa, secreta; "ceniza" (4 hits) y "flora" (16 hits) ya aparecen en el catalogo. **Las 4 de Alpha (Aurora, Coral, Ceniza, Flora) quedan como seleccion a confirmar** |
| Templos nuevos | 2 (Profundidades, Ceniza) | **presentes como puzzles** — `scripts/templos/` tiene puzzle_agua y puzzle_bloques como base; los 2 templos nuevos son instanciacion, no motor nuevo |
| NPC con rutinas | 24-30 en 4 islas | **parcial** — `scripts/npc/` tiene 9 scripts y el elenco de M139 definio 8 NPC (2.3.1). Faltan ~16-22 NPC para el rango |
| Coleccionables | 80 de 100 | **15 reales** — `data/coleccionables/catalog.json` tiene 15 items. Brecha grande |
| Museo completo | M37 | **parcial** — modulo 37-Museo existe y M139 definio 5 secciones (Naturaleza, Geologia, Botanica, Marina, Pesca); el catalogo completo no esta |
| Eventos estacionales | 4 (1 por estacion) | **parcial** — `catalogo_eventos.json` existe (analytics) y hay 30 hits de fiesta/festival; los 4 eventos base estan por definir como datos |
| Recetario | 60+ con items de todas las islas | **7 reales** — `data/balance/crafting.json`. Brecha muy grande (arrastra desde la seccion 2) |
| Flora y fauna por isla | M50/M36 | **presente** — `vegetacion_config.json` v2 con 7 tipos de terreno (playa, pradera, bosque, montana, ribera, humedal, cercanias) y `data/fauna/catalog.json` con 7 especies |
| Audio por zona | M41-M44 | **presente** — 10 sectores en `ambient_biome_bank.json` + matriz de musica + ASMR (verificado en M139 seccion 11) |
| Meta de partida | 60-100 h | no verificable por disco (requiere telemetria de sesion) |
| Verificacion de horas | telemetria de sesion | **presente como contrato** — telemetria opt-in local definida en M139 4.1; la metrica de horas por sesion se agrega al dashboard |
| Reutilizacion via pipeline M108 | 100% del contenido | **presente** — pipeline con validador y cuarentena verificado en M139 seccion 9 |

**Conclusion de contenido para Alpha:** de 12 bloques, **5 tienen respaldo solido** (templos como
instanciacion, flora/fauna, audio, pipeline y el contrato de horas), **5 son parciales** con brecha
cuantificada (NPC 8/24-30, coleccionables 15/80, museo, eventos, recetario 7/60+) y **2 no son
verificables por disco** (meta de horas y su metodo, que requieren telemetria real).

**Brechas cuantificadas para planificar:** NPC +16 minimo · coleccionables +65 · recetas +53 ·
museo: 3 de 8 secciones (a confirmar con M37).

### 2.7 Deuda técnica (RF8/RF9)

- Inventario de TODO/FIXME en el repo (script CI, M111) → sprint de 2 semanas de pago → 0 al cierre.
- Deuda de M135 re-metricada (50% de reducción) con informe por sistema.

### 2.7.1 Integraciones verificadas contra disco (cerrada 2026-10-14, step-5-kilocode)

Cierra la seccion 3 del checklist. Cada integracion se verifico con grep sobre el modulo que deberia
implementarla.

| Integracion | Estado verificado |
|---|---|
| Amistad -> economia (5-10% precio) | **presente** — `economy_manager.gd` + `price_manager.gd` (10 hits de descuento/precio) + `bonus_amistad` en `recompensa_def.gd` (M74/M20) |
| Clima -> cultivos (lluvia 20%, helada) | **presente, parcial** — `weather_service.gd` + `test_farm_clima.gd` + `test_fishing_clima.gd`. La lluvia esta; **helada: 0 hits** (deuda de M33) |
| Calendario -> rutinas NPC (fiestas) | **presente** — 30 hits de fiesta/festival; modulos 29-Tiempo-Y-Calendario y 74-Eventos existen |
| Construccion -> amistad (regalos fabricados +25%) | **ausente** — 0 hits de regalo fabricado |
| Viajes -> estacion vegetal por isla | **presente** — `island_props.gd` (M27) mas `test_mercado_estacion_ferias.gd` y `test_estacion_iter5.gd` (5 hits) |
| Templos -> artefactos -> progresion | **ausente** — los artefactos pasivos no existen (seccion 2), la cadena esta cortada en el primer eslabon |
| Economia global -> tiendas por isla | **presente** — `catalogo_tiendas.gd` con tienda_general y herreria (Aurora) + mercader_viajero; la de Coral (glasswork) pendiente de alta |
| Clima -> audio ambiental (M32/M42) | **presente** — `ambient_biome_bank.json` ya tiene variante `clima_2` por sector |
| Eventos -> diario (M74/M55) | **presente** — `event_manager.gd` y `save_provider.gd` referencian el diario (2 hits) |
| Servicio `Almanaque` | **ausente** — 0 hits en `scripts/`. Queda como servicio por disenar |
| `HistoriaMaster` sin acoplar misiones | **ausente** — 0 hits. Queda como contrato por disenar |
| Pruebas de integracion por cadena (M112) | **presente** — 17 hits, incluidos `test_m162_integracion_m19.gd`, `test_m18_m60_integration.gd` y `test_terrenos_integracion.gd` |

**Definicion de `Almanaque` (propuesta, no implementada):** servicio unico que expone `ahora()`,
`estacion()`, `clima_previsto()` y `eventos_hoy()`, y que ningun otro servicio consulta al reloj
directamente. Hoy el tiempo pasa por `TimeCalendar` (autoload) y el clima por `weather_service.gd`;
`Almanaque` seria la fachada unica. Queda `[ ]` hasta que se implemente.

**Definicion de `HistoriaMaster` (propuesta, no implementada):** orquesta actos y sellos (1.4) pero
no conoce misiones individuales — esas viven en M22/M23 y se subscriben por senal. Evita el
acoplamiento que el item pide.

**Cadena cortada a reportar:** la integracion templos -> artefactos -> progresion depende de los
artefactos pasivos, ausentes (deuda de la seccion 2). Mientras no existan, esa cadena no se puede
probar.

## 3. Hits GONOGO-BETA (M141)

| Hit | Criterio |
|---|---|
| H1 | Historia jugable completa (6 sellos + epílogo), sin bloqueos, canon OK |
| H2 | Todas las mecánicas principales presentes e integradas (RF2/RF3) |
| H3 | Primer balance estable: 40 h simuladas sin alertas + 2 meses de playtests acumulados |
| H4 | Contenido Alpha: 4 islas, 3 templos, 24-30 NPC, 30+ secundarias, 80 coleccionables |
| H5 | Rendimiento medible: presupuestos M61-M63 cumplidos en build semanal de referencia |
| H6 | QA: 0 bugs P0/P1; P2 documentados; tracking verificado (M101/M102) |
| H7 | Arquitectura: 0 TODO/FIXME; deuda M135 ≥ 50% reducida |
| H8 | Save v3 migrado a todo el juego; 0 pérdidas en 30 ciclos |
| H9 | Accesibilidad M58 validada en los sistemas nuevos |
| H10 | GONOGO-BETA documentado y firmado con backlog de Beta priorizado (M141) |

## 4. Plan de oleadas (W1-W6)

| Semana | Foco |
|---|---|
| W1 | Economía global + tiendas por isla + balance JSON (M93/M38/M39) |
| W2 | Amistad + diálogos + eventos de temporada base (M20/M21/M74) |
| W3 | Templos 2-3 + puzzles + artefactos (M26/M24/M13/M71) |
| W4 | Viajes + 2 islas nuevas + clima/calendario (M28/M27/M29-M32) |
| W5 | **Semana de integración** (cross-system QA, regresión, perfil) |
| W6+ | Sprint de deuda (2 sem) + Sprint de QA intensivo (3-4 sem) → GONOGO-BETA |