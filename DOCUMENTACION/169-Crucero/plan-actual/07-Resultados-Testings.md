**Modelo:** ERNIE-5.5-Flash-Preview (Baidu)
**Plataforma:** Kilo Code
**Fecha:** 2026-11-25

# 07-Resultados-Testings.md — Módulo 169: Crucero de Lujo

## 1. Resumen de ejecución

**Motor:** `D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe` (4.7.2, la versión del proyecto).
**Fecha:** 2026-11-25.
**Resultado global:** **59 OK / 0 FAIL** en 6 suites. **0 SCRIPT ERROR.**

| Suite | Archivo | OK | FAIL |
|---|---|---:|---:|
| U1 Manager | `tests/unit/test_crucero_manager.gd` | 13 | 0 |
| U2 Eventos | `tests/unit/test_crucero_eventos.gd` | 6 | 0 |
| U3 Ambiental | `tests/unit/test_crucero_ambiental.gd` | 5 | 0 |
| U4 Interior | `tests/unit/test_crucero_interior.gd` | 9 | 0 |
| U5 Puerto | `tests/unit/test_crucero_puerto.gd` | 7 | 0 |
| I1 Viaje | `tests/integration/test_crucero_viaje.gd` | 19 | 0 |
| **Total** | | **59** | **0** |

## 2. Comando de ejecución

```powershell
$godot="D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe"
foreach($t in @(
  "res://tests/unit/test_crucero_manager.gd",
  "res://tests/unit/test_crucero_eventos.gd",
  "res://tests/unit/test_crucero_ambiental.gd",
  "res://tests/unit/test_crucero_interior.gd",
  "res://tests/unit/test_crucero_puerto.gd",
  "res://tests/integration/test_crucero_viaje.gd"
)){ & $godot --headless --path "game/isla-ancestral" --script $t }
```

## 3. Detalle por suite

### U1 Manager — 13/0
3 clases · 7 camarotes · `precio_de("primera")==140` · `precio_de("tercera")==30` ·
suite_dúo 2 niveles · `cambiar_cubierta(4)` acepta · `(9)`/`(-1)` rechazan ·
roundtrip `a_dict`/`cargar_desde` conserva cubierta 4 · estado inicial ATRACADO ·
sin pasaje no embarca · rechaza clase inexistente.

### U2 Eventos — 6/0
5 actividades cargadas · casino jugable · inexistente rechazada · límite diario bloquea ·
premio por encima del tope no rompe.

### U3 Ambiental — 5/0
6 NPCs con línea · cada línea no vacía · `capitan` empieza con "Capitan" ·
id inexistente devuelve "" · `tiene()` rechaza inexistente.

### U4 Interior — 9/0
destino 1→2 · destino 4→1 (ciclo) · luces apagadas en reposo · activar enciende ·
desactivar apaga · puerta emite al cruzar jugador (2→3) · no-jugador no dispara ·
`configurar` fija cubierta 3 · `punto_de_spawn` usa el marcador.

### U5 Puerto — 7/0
sin pasaje no embarca · con pasaje embarca · manager en ABORDO · desembarco emitido ·
destino = isla_norte · pasaje liberado · no-jugador no embarca.

### I1 Viaje — 19/0
manager disponible · es autoload · estado inicial ATRACADO · sin pasaje no embarca ·
puede embarcar con pasaje · `embarcar()` acepta · señal `embarque` · cubierta 2 ·
zarpe → NAVEGANDO · señal `zarpe` (origen isla_raiz) · llegada → ATRACADO ·
señal `llegada` (puerto isla_norte) · señal `desembarco` · pasaje liberado ·
camarote liberado · estado ATRACADO · sin pasaje no embarca de nuevo.

## 4. Regresión P-09 (ningún otro módulo cambió)

Cambios de código limitados a `scripts/crucero/` (manager, interior, puerto), `data/crucero/`,
`tests/` y docs M169. El fix de `_gl`/`_CAT` se aplicó **solo** a los 4 scripts del crucero
(manager, eventos, interior; puerto nace ya con el fix). No se tocó código de otros módulos.

## 5. Bugs encontrados y resueltos durante el testing

| # | Bug | Causa | Fix |
|---|---|---|---|
| 1 | Boot no imprimía `[CRU] catalogos cargados` | `_gl` nunca se asignaba → `_log_*` no-op | `_gl = get_node_or_null("/root/GameLogger")` en `_ready()` |
| 2 | `Invalid type in function 'info'` | `_log_*` pasaba `cat: String` donde se espera `Category` (int) | `_CAT` map (BOOT..CRASH → 0..6) |
| 3 | Puerto no conectaba con M74 | `get_node_or_null("/root/EventManager")` inexistente (autoload = `eventos`) | usar `/root/eventos` + fallback |
| 4 | Tests de señales daban FAIL | lambdas GDScript capturan por valor | contadores como variables miembro |

## 6. Pendiente de validación visual

- Exterior LOD alta/media/baja y 5 interiores: **sin validar** (requiere Blender + juez visual).
- Colisión del bote (T02-03) y AABB de ventanas (T02-04): **no verificables** sin Blender/visión.

**Firma:** ERNIE-5.5-Flash-Preview (Baidu) / Kilo Code — 2026-11-25