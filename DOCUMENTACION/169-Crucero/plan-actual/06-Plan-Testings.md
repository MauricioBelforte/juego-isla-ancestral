**Modelo:** ERNIE-5.5-Flash-Preview (Baidu)
**Plataforma:** Kilo Code
**Fecha:** 2026-11-25

# 06-Plan-Testings.md — Módulo 169: Crucero de Lujo

## 1. Alcance

M169 (Crucero) es un módulo de **gameplay core** (viaje entre islas + aventura a bordo) con
persistencia, streaming de cubiertas y contrato con M68/M74/M63. Por eso amerita plan de
testings propio (AGENTS.md §14).

Este plan cubre la **lógica** (autoloads, datos, streaming, colisiones de escena) con tests
headless. **No cubre** la validación visual del exterior/interiores (requiere Blender + juez
visual, fuera del alcance de este agente — no hay visión en el harness).

## 2. Convención de tests

- Formato **SceneTree** del repo (`extends SceneTree` + `call_deferred("_correr")`), NO GdUnit4
  (aunque el addon esté instalado). Es la convención real de `tests/`.
- Ejecución headless:
  `godot --headless --path game/isla-ancestral --script res://tests/<...>.gd`
- Los autoloads no se resuelven como identificador en modo `--script` (E-GD-01), pero existen
  como hijos del `root`: se obtienen con `get_node_or_null` y, si faltan, se instancia el script.
- Las lambdas de GDScript capturan **por valor**: los contadores de señales son variables miembro.

## 3. Suites

| # | Suite | Archivo | Cubre |
|---|---|---|---|
| U1 | Manager | `tests/unit/test_crucero_manager.gd` | catálogos, precios, cubiertas, persistencia, estados |
| U2 | Eventos | `tests/unit/test_crucero_eventos.gd` | 5 actividades, límite diario, bloqueo por clima, premio tope |
| U3 | Ambiental | `tests/unit/test_crucero_ambiental.gd` | 1 línea/NPC, fallback, ids |
| U4 | Interior | `tests/unit/test_crucero_interior.gd` | luces, puerta (ciclo 4→1), spawn, configurar |
| U5 | Puerto | `tests/unit/test_crucero_puerto.gd` | Area3D embarque/desembarco, señales, no-jugador |
| I1 | Viaje (integración) | `tests/integration/test_crucero_viaje.gd` | ciclo completo embarque→zarpe→llegada→desembarco |

## 4. Casos por suite (criterios de éxito)

### U1 Manager (13)
- 3 clases y 7 camarotes cargados de los JSON.
- `precio_de("primera")==140`, `precio_de("tercera")==30`, suite_dúo con 2 niveles.
- `cambiar_cubierta(4)` acepta; `(9)` y `(-1)` rechazan.
- Roundtrip `a_dict()`/`cargar_desde()` conserva cubierta.
- Estado inicial ATRACADO; sin pasaje no se puede embarcar.
- Rechaza clase inexistente.

### U2 Eventos (6)
- 5 actividades cargadas; casino jugable; actividad inexistente rechazada.
- Límite diario bloquea al superar; premio por encima del tope no rompe.

### U3 Ambiental (5)
- 6 NPCs con línea; cada línea no vacía; `capitan` empieza con "Capitan"; id inexistente → "".

### U4 Interior (9)
- Ciclo de puertas 1→2 y 4→1.
- Luces: apagadas en reposo, `activar` enciende, `desactivar` apaga.
- Puerta emite `puerta_cruzada(destino)` al cruzar un jugador; no-jugador no dispara.
- `configurar()` fija cubierta; `punto_de_spawn` usa el marcador.

### U5 Puerto (7)
- Sin pasaje no embarca; con pasaje ABORDO embarca y emite `jugador_embarco`.
- Desembarco emite `jugador_desembarco(destino)` y libera pasaje.
- Cuerpo no-jugador no dispara.

### I1 Viaje (19)
- Ciclo completo: ATRACADO → ABORDO (embarcar) → NAVEGANDO (zarpe) → ATRACADO (llegada) → desembarco.
- Señales `embarque`/`zarpe`/`llegada`/`desembarco` emitidas con valores correctos.
- `CruceroManager` es autoload (hijo del root).

## 5. Criterios de éxito globales

- **0 FAIL** en las 6 suites.
- **0 SCRIPT ERROR** / `Invalid type` en la salida (el fix de `_CAT`/`_gl` debe evitarlos).
- Boot headless emite `[CRU] catalogos cargados: 3 clases, 7 camarotes`.
- Regresión P-09: ningún otro módulo cambia de comportamiento (diff contra HEAD sin cambios
  fuera de `scripts/crucero/`, `tests/`, `data/crucero/`, `scenes/crucero/`, docs M169).

## 6. Cobertura pendiente (fuera de este plan)

- Validación visual del exterior y 5 interiores (B-02/B-03, juez visual).
- Colisión del casco/botes (T02-03) y AABB de ventanas (T02-04): requieren Blender.
- Integración en escena con M28/M63/M74 (hoy el manager está aislado; tests unitarios lo validan).

**Firma:** ERNIE-5.5-Flash-Preview (Baidu) / Kilo Code — 2026-11-25