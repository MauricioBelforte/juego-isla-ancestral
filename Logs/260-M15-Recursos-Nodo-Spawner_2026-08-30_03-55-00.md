# Log 260: M15 Recursos (iter. 2) — ResourceNode 3D + ResourceSpawner

**Fecha:** 2026-08-30
**Hora:** 03:55
**Modelo:** Deepseek V4 Flash
**Plataforma:** Kilo

## Resumen
Iteración 2 del M15 (Recursos, V1/V2 — con visión). Se implementaron las clases visuales:
ResourceNode (nodo 3D recolectable con estados INTACTO/DANIADO/AGOTADO) y ResourceSpawner
(instanciación y planificación de regiones con presupuesto). Se cableó la población inicial de
la isla desde la escena principal. Test headless 0 fallos.

## Cambios Realizados

### Código (Godot)
- `scripts/resources/resource_node.gd` — **NUEVO** class_name ResourceNode (Node3D):
  - Estados INTACTO/DANIADO/AGOTADO con mesh placeholder por estado (BoxMesh + color por
    categoría: madera marrón, piedra gris, mineral cobre, raro dorado, etc.).
  - `configurar(def)` a partir de ResourceDefinition (golpes, herramienta requerida).
  - `aplicar_golpe(herramienta_id)` valida herramienta (RF4), descuenta golpes y agota.
  - Area3D de interacción + señales `golpe_aplicado`/`agotado`.
  - Mesh por categoría con tamaño diferenciado; placeholders hasta assets del arte.
- `scripts/resources/resource_spawner.gd` — **NUEVO** class_name ResourceSpawner (Node):
  - `planificar_region(region_id, centro, terreno)` y `instanciar_nodo(def_id, x, z, terreno)`.
  - Presupuesto MAX_NODOS_ACTIVOS = 200; distribución determinista (def_id.hash()).
  - Posiciona usando TerrainLocator (M167) `posicionar_sobre_terreno` (anti-flotamiento).
  - Al agotarse, genera drops vía ResourceManager.entregar_drops y emite `recurso_reaparecio`.
  - Orden correcto: add_child → posicionar (evita error "not inside tree").
- `scripts/resources/resource_manager.gd` — Modificado: expone `poblar_isla(centro)` y `definir_region`;
  crea el spawner en `_ready`.
- `scripts/main_island.gd` — Modificado: hook `_poblar_recursos()` que llama
  `ResourceManager.poblar_isla` (deferred) al arrancar.
- `scripts/resources/test_recurso_nodo.gd` — **NUEVO** test: estados del nodo, golpe con
  herramienta correcta/incorrecta, agotamiento, instanciación del spawner, planificar_region
  headless. 0 fallos.

### Documentación
- `DOCUMENTACION/15-Recursos/plan-actual/05-Checklist.md` — marcados ítems D (ResourceNode) y
  F (ResourceSpawner).
- `DOCUMENTACION/15-Recursos/plan-actual/04-Codigo.md` — notas de iteración 2.

## Archivos Modificados/Creados
| Archivo | Acción |
|---------|--------|
| `scripts/resources/resource_node.gd` | Creado |
| `scripts/resources/resource_spawner.gd` | Creado |
| `scripts/resources/test_recurso_nodo.gd` | Creado |
| `scripts/resources/resource_manager.gd` | Modificado |
| `scripts/main_island.gd` | Modificado (hook población) |
| `DOCUMENTACION/15-Recursos/plan-actual/05-Checklist.md` | Modificado |
| `DOCUMENTACION/15-Recursos/plan-actual/04-Codigo.md` | Modificado |
| `Logs/ULTIMO_NUMERO.txt` | Modificado (259 → 260) |
| `Logs/260-M15-Recursos-Nodo-Spawner_2026-08-30_03-55-00.md` | Creado (este log) |

## Validación
- `test_recurso_nodo.gd` headless: 0 fallos (estados, golpe herramienta, agotamiento, spawner).
- `--verbose`: sin warnings de resource_node/spawner/manager.
- Arranque del juego con MCP Godot: 0 errores nuevos (población inicial de recursos).

## Pendientes honestos
- Meshes/iconos reales del equipo de arte (los actuales son placeholders BoxMesh + color).
- Respawn estacional/eventos (M29/M73) aún no conectado (solo agotamiento + drops).
- Persistencia completa de nodos agotados (M59) parcial.
- Integración con la señal `golpe_aplicado` de M13 (aún el nodo recibe llamada directa).