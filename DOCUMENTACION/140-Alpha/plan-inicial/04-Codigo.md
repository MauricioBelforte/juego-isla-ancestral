**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 140: Alpha

## 1. Archivos involucrados (referencia al naming del proyecto)

### 1.1 Narrativa y sellos (nuevos en Alpha)

| Archivo (res://) | Propósito | Módulos |
|---|---|---|
| `scripts/gameplay/historia/historia_master.gd` | Orquestador de actos: estado de sellos, prerequisitos, epílogo | M22/M153 |
| `scripts/gameplay/historia/condicion_sello.gd` | Contrato `ICondicionDeSello` con estado persistido | M22/M153/M60 |
| `scripts/gameplay/historia/diario_sugerencias.gd` | Pistas suaves en el diario según prerequisitos pendientes | M55/M153 |
| `scripts/gameplay/historia/actos.gd` | Definición de actos 1-3 y puntos de retorno (anti-softlock M66) | M22/M66 |

### 1.2 Sistemas principales (integración)

| Archivo (res://) | Propósito | Módulos |
|---|---|---|
| `scripts/world/almanaque/almanaque.gd` | Servicio único: calendario + estaciones + clima + eventos base | M29-M32/M74 |
| `scripts/world/economia/tienda_por_isla.gd` | Tiendas por isla con stock/prices desde BalanceService | M38/M39/M93 |
| `scripts/gameplay/amistad/amistad_manager.gd` | Niveles, regalos, beneficio cruzado (precios, diálogos) | M20/M21 |
| `scripts/gameplay/amistad/recompensa_cruzada.gd` | Cadena amistad→economía (5-10% precio) | M20/M39/M93 |
| `scripts/world/clima/clima_agricultura.gd` | Efecto lluvia/helada sobre cultivos y riego | M32/M33 |
| `scripts/gameplay/construccion/regalo_construido.gd` | Bonus de amistad por muebles fabricados | M17/M20 |
| `scripts/world/viajes/viaje_isla.gd` | Viaje entre islas con estación por isla | M28/M33 |
| `scripts/world/viajes/isla_estacion.gd` | Ciclo vegetal adelantado por isla | M28/M33 |
| `scripts/gameplay/artefactos/artefacto_manager.gd` | 6 artefactos pasivos (uno por sello) | M13/M26/M71 |

### 1.3 Contenido y mundo

| Archivo (res://) | Propósito | Módulos |
|---|---|---|
| `scripts/world/islas/isla_profundidades.gd` | Isla 2: cavernas, muelle profundo | M27/M35 |
| `scripts/world/islas/isla_ceniza.gd` | Isla 3: bosque de ceniza, volcán dormido | M27/M50/M32 |
| `scripts/world/islas/isla_flora.gd` | Isla 4: conservatorio, flora única | M27/M33/M37 |
| `scripts/world/templos/templo_profundidades.gd` | Templo 2: puzzles de agua y espejos | M26/M24/M51 |
| `scripts/world/templos/templo_ceniza.gd` | Templo 3: puzzles de sombra y calor | M26/M24/M32 |
| `scripts/world/misiones/secundarias_alpha.gd` | Biblioteca de 30+ misiones secundarias (cadenas de amistad) | M23/M20 |
| `scripts/world/eventos/eventos_estacionales.gd` | 4 eventos base estacionales | M74 |

### 1.4 QA, rendimiento y deuda

| Archivo (res://) | Propósito | Módulos |
|---|---|---|
| `tools/qa/triaje_bugs.gd` | Plantilla de triaje diario (P0-P2, severidad, tracking) | M101/M102 |
| `tools/qa/reporte_semanal.gd` | Reporte automático del backlog de bugs | M101/M102 |
| `tools/qa/escaneo_todo_fixme.gd` | Script CI para inventariar TODO/FIXME | M111/M118 |
| `tests/progressive_save_migration.gd` | Migración versionada del save v3 | M59/M60 |
| `tests/gate_rendimiento.gd` | Gate CI: presupuestos por zona (M61/M62/M63) | M61-M63/M118 |
| `tests/simulacion_balance_alpha.gd` | Simulación 40 h con escenarios extremos (M93) | M93/M112 |

## 2. Funciones clave (firmas de referencia)

### 2.1 `historia_master.gd`
- `func registrar_progreso_sello(id_sello: String, terminado: bool) -> void` — actualiza flags globales (M60).
- `func prerequisitos_pendientes(id_sello: String) -> Array[String]` — consulta condiciones al diario (M55).
- `func estado_acto() -> int` — 1/2/3 según sellos completados y flags (M153).

### 2.2 `condicion_sello.gd`
- `func cumplida(estado_mundo: Dictionary) -> bool` — polimórfica por tipo de condición.
- `func pista_diario() -> String` — texto suave sin spoiler (M55/M153).

### 2.3 `almanaque.gd`
- `func tick(delta: float) -> void` — avanza hora/día/estación/clima (M29-M32).
- `func edad_dia_en(anio: int, dia: int) -> Dictionary` — DAta para rutinas y eventos (M64/M74).
- `func evento_activo() -> EventoEstacional` — evento base activo o null (M74).

### 2.4 `tienda_por_isla.gd`
- `func precios_jugador(id_npc: String, precio_base: float) -> float` — aplica amistad (M20/M93).
- `func rotar_stock(dia: int) -> void` — regenera stock según curva (M93).

### 2.5 `artefacto_manager.gd`
- `func activar_pasivo(id_sello: String) -> void` — registra el pasivo en el mundo (M13/M71).
- `func lista_activos() -> Array[Dictionary]` — para UI de colecciones (M37/M73).

### 2.6 `triaje_bugs.gd`
- `func agregar_reporte(bug: Dictionary) -> void` — normaliza severidad y duplicados (M102).
- `func resumen_semanal() -> Dictionary` — P0-P2 counts, trend, regresión (M101).

## 3. Datos y configuración

| Dato | Ruta | Módulos |
|---|---|---|
| Curvas de balance Alpha | `data/balance/alpha/curvas.json` | M93 |
| Precios por isla | `data/balance/alpha/tiendas/*.json` | M39/M93 |
| Recetario extendido | `data/items/recetas.json` | M16/M71 |
| Colecciones y museo | `data/world/colecciones.json` | M73/M37 |
| Sellos y prerequisitos | `data/historia/sellos.json` | M22/M153 |
| Misiones secundarias | `data/historia/secundarias.json` | M23 |
| Eventos estacionales | `data/world/eventos.json` | M74 |
| Artefactos | `data/world/artefactos.json` | M13/M26 |
| Rutinas NPC por isla | `data/world/npc_rutinas.json` | M19/M64 |

## 4. Tests asociados (M112/M101)

| Prueba | Alcance |
|---|---|
| Historia | 3 rutas de orden de sellos sin bloqueos; epílogo alcanzable; anti-softlock M66 |
| Migración save | 30 ciclos v3 a v3.1 sin pérdidas; migración desde Pre-Alpha |
| Integración cruzada | Las 6 cadenas de la sección 2.1 con casos borde |
| Balance 40 h | Simulación M93 con escenarios extremos en CI |
| Gate de rendimiento | Presupuestos por zona en build semanal (M61-M63) |
| QA | Backlog P0/P1 en 0 al cierre; triaje auditado (M101/M102) |
| Colecciones | 80/80 completables en Alpha sin softlocks |

## 5. Logs relacionados

- Log 80 (M139), 82 (QA Lote 3). Este módulo: Log 83 (M140-Alpha).

## 6. Notas de integración

- Se hereda todo el Pre-Alpha (M139): Aurora, elenco, economía local, Templo de Brisa, Gran Vapor, save v3, menú, pipeline M108.
- `HistoriaMaster` NO toca la lógica de misiones individuales: consume condiciones y emite eventos (M07/M15 en AGENTS.md: no modificar flujos que funcionan, orquestar nuevo sistema encima).
- El desempeño de cada sistema nuevo se mide contra su módulo de origen y el gate M61-M63.
- El `05-Checklist.md` referencia los ítems de integración cruzada con sus módulos de origen.