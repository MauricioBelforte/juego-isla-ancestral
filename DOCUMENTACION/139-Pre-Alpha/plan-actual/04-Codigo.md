**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 139: Pre-Alpha

## 1. Archivos involucrados (referencia al naming del proyecto)

### 1.1 Orquestación y sesión (nuevos en esta fase)

| Archivo (res://) | Propósito | Módulos |
|---|---|---|
| `scripts/core/sesion_master.gd` | Flujo de fase: menú → mundo, GONOGO local, inicialización de managers | M07/M53/M139 |
| `scripts/core/zonas/zona_manager.gd` | Streaming por zona, presupuesto de memoria, prioridades de carga | M63/M62 |
| `scripts/core/zonas/viaje_manager.gd` | Gran Vapor: embarcar, travesía, desembarcar en Coral y vuelta | M28/M67/M68 |
| `scripts/core/save/guardado_v3.gd` | Save particionado + manifest + checksums; escritura transaccional | M59/M60 |
| `scripts/core/save/integridad_save.gd` | Validación de manifiesto, recuperación de copia, teleport de seguridad | M66 |
| `scripts/core/menu/menu_principal.gd` | Menú: continuar/nuevo/ajustes/créditos; deshabilitado durante carga | M53/M08 |

### 1.2 Mundo y contenido

| Archivo (res://) | Propósito | Módulos |
|---|---|---|
| `scripts/world/aurora/aurora_factory.gd` | Construcción guiada de Aurora (sectores, POIs, spawns) sobre MundoVoxel | M10/M27/M50/M51 |
| `scripts/world/coral/coral_enclave.gd` | Enclave visitable: muelle, tienda de glasswork, NPC enano | M27/M28/M39 |
| `scripts/world/npc/npc_profile.gd` | Plantilla de NPC: rutina (waypoints), horarios, personalidad | M19/M64 |
| `scripts/world/npc/rutina_ia.gd` | Máquina de estados de rutina con tolerancia y anti-stuck | M64/M66 |
| `scripts/world/misiones/mision_intro_aurora.gd` | Cadena intro: Finneas → Maribel → Obé → Templo (GONOGO tutorial) | M22/M23/M92 |
| `scripts/world/templo/templo_brisa.gd` | Orquestación del Templo: salas, puzzles, recompensa | M26/M24/M13 |
| `scripts/world/templo/puzzle_velas.gd` | Puzzle 1: velas con ráfagas de viento (orden) | M24/M42 |
| `scripts/world/templo/puzzle_carrillon.gd` | Puzzle 2: carillón de 5 campanas (melodía) | M24/M44 |
| `scripts/world/economia/tienda_manager.gd` | Ciclo de tienda (horarios), stock, precios desde balance JSON | M38/M39/M93 |
| `scripts/world/economia/banco_local.gd` | Depósito de Cole con interés 0.5% diario y techo | M38 |
| `scripts/world/construccion/catalogo_piezas.gd` | Catálogo de piezas y requisitos | M17/M16 |
| `scripts/world/construccion/colocador.gd` | Grid de colocación, validación de terreno, preview | M17/M09 |
| `scripts/world/audio/audio_global.gd` | Buses por zona, transiciones clima/día-noche, eventos | M41-M44/M31/M32 |
| `scripts/core/metrics/metrics_hub.gd` | Telemetría local de sesión (FPS, memoria, uso por sistema) | M104/M105 |

### 1.3 Pipeline e infraestructura

| Archivo (res://) | Propósito | Módulos |
|---|---|---|
| `tools/pipeline/import_normalizado.gd` | Importador con convenciones (nombres, unidades, collision, LOD) | M108/M45/M47 |
| `tools/pipeline/validador_asset.gd` | Valida frame budget, bounds, LOD y naming antes de integrar | M108/M61 |
| `.github/workflows/ci_prealpha.yml` | CI: compilación + tests + simulación económica M93 + ingresar cada zona al presupuesto | M118/M93/M101 |
| `tests/simulacion_economia.gd` | Simulación de jugador productivo contra curvas M93 (gate) | M93/M112 |

## 2. Funciones clave (firmas de referencia)

### 2.1 `guardado_v3.gd`
- `func guardar_particion(tipo: int, datos: Dictionary) -> bool` — escribe a temp, checksums, rename atómico.
- `func cargar_manifest() -> Dictionary` — lee `manifest.json`, valida version de schema (M60).
- `func verificar_integridad() -> Dictionary` — checksums por partición; devuelve particiones dañadas.

### 2.2 `zona_manager.gd`
- `func cargar_zona(id_zona: int, origen: Vector3, teleport_seguro: bool) -> void` — prioriza streaming M63.
- `func presupuesto_memoria_ok() -> bool` — consulta M62 y bloquea spawns si excede.

### 2.3 `templo_brisa.gd`
- `func completar_sala(id_sala: int) -> void` — valida estado, desbloquea siguiente, persiste progreso.
- `func recompensa_obtenida(herramienta: String) -> bool` — entrega Herramienta del Viento (M13), escribe flag global (M60).

### 2.4 `rutina_ia.gd`
- `func tick_rutina(tiempo_actual: float) -> void` — máquina de estados por hora (M64).
- `func reubicar_si_atascado() -> void` — anti-stuck con teleport a waypoint previo (M66).

### 2.5 `tienda_manager.gd`
- `func iniciar_dia(stock_base: Dictionary, precios: Dictionary) -> void` — regenera stock según curva M93.
- `func vender_al_jugador(id_item: String, cantidad: int) -> Dictionary` — valida oro/UI y persiste.

### 2.6 `colocador.gd`
- `func preview_posicion(valida: Vector3) -> Dictionary` — valida grid, terreno y colisiones (M08/M09).
- `func colocar(id_pieza: String, posicion: Vector3, rotacion: float) -> bool` — persiste pieza en zona (M60).

### 2.7 `metrics_hub.gd`
- `func registrar_evento(sistema: String, valor: Variant) -> void` — recolección local (M104/M105).
- `func dump_informe_sesion() -> Dictionary` — resumen para playtest (M114).

## 3. Configuración y datos

### 3.1 Balance (M93)
- `data/balance/curvas.json` — curvas de precio por categoría (margen 55-70%).
- `data/balance/tiendas/aurora.json` — stock y precios de Tía Rúa y mercado.
- `data/balance/tiendas/coral.json` — tienda de glasswork del enclave.
- `data/balance/items.json` — ítems de Aurora (60+ recursos, herramientas, piezas).

### 3.2 Mundo (M147)
- `data/world/biblia.json` — canon de Aurora/Coral (flora, NPC, lore de templo y faro).
- `data/world/sellos.json` — recordatorio de capas de revelación (sin spoilers).

## 4. Tests asociados (M112/M101)

| Prueba | Alcance |
|---|---|
| Test guardado v3 | 20 ciclos guardar/cargar con corrupción inyectada (recuperación OK) |
| Test templo | 3 rutas de solución por sala; ningún softlock (hints y reorden) |
| Test rutinas NPC | 48 h simuladas sin atascos ni faltas de objetivo |
| Test economía | Jugador productivo no rompe curva antes de 30 h simuladas |
| Test streaming | Carga de zona < 2 s, memoria dentro de presupuesto (M62) |
| Test menú | Continuar con save corrupto → recuperación o nuevo juego (M66) |
| Test viaje | Ida/vuelta Coral sin pérdida de progreso ni duplicados |

## 5. Logs relacionados

- Log 72 (M93), 73 (M147), 77 (M137), 78 (M138), 79 (QA cruzado Lotes 1-2 y extensiones 126/127/129).
- Este módulo: Log 80 (M139-Pre-Alpha).

## 6. Notas de integración

- El slice (M138) aporta: mundo voxel base, Finneas, ruina, autosave v2 (se migra a v3), audio curado y UI de base.
- Aurora_Factory reutiliza los generadores del slice (M08/M10/M50/M51), los parametriza y los conecta a `ZonaManager`.
- No se tocan los hits ya establecidos de M137 (prototipo núcleo) ni M138 (GONOGO superado): el Pre-Alpha es una capa de escala sobre ellos.
- Los ítems de integración cruzada están referenciados en el `05-Checklist.md` con sus módulos de origen.