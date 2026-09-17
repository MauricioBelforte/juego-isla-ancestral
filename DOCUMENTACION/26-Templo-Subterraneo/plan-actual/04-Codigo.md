# 04 — Código — M26: Templo Subterráneo

**Modelo:** Deepseek V4 Flash (diseño, 2026-08-17) · DeepSeek-V4.1-Flash / WorkBuddy (iter. 2, 2026-09-14)
**Plataforma:** OpenCode (diseño) · WorkBuddy (iter. 2)
**Fecha:** 2026-08-17 (diseño) · 2026-09-14 (iter. 2)

## Archivos reales (Godot 4.7.2, GDScript)

Todas las rutas son relativas a `game/isla-ancestral/` (`res://`).

| Archivo | Contenido | Iteración |
|---|---|---|
| `scripts/templos/templo_schema.gd` | `TemploSchema` — validación del layout mínimo (salas únicas/conectadas, puzzles con emisor/receptor, checkpoint final, guardián, recompensa) | 1 |
| `data/templos/templo_subterraneo.json` | Layout mínimo: 4 salas, 4 puzzles, 3 checkpoints, guardián polilla de la Raíz | 1 |
| `scripts/templos/templo_flow.gd` | `TemploFlow` — orquestador de gating: 7 anillos, sellos únicos, glifo por anillo, restauración del Sello, apertura de la salida | 2 |
| `scripts/templos/templo_checkpoint.gd` | `TemploCheckpoint` — los 5 CP con guardado atómico (tmp → rename → `.bak`) y carga con respaldo | 2 |
| `scripts/templos/templo_telemetria.gd` | `TempleTelemetria` — intentos/pistas/tiempo por puzzle, reloj inyectable, export JSON a M24 | 2 |
| `scripts/templos/templo_validadores.gd` | `TemploValidadores` — suites de softlock, anti-exploit, voxel, accesibilidad, orientación y checkpoints | 2 |
| `data/templos/templo_blueprint.json` | Metría voxel (4x4x4 m, puertas 2x3, techos 3x3, 45°, rampas ≤20°), accesibilidad, orientación, gating, presupuesto | 2 |
| `data/templos/templo_layout_diseno.json` | Grafo del diseño `03-Diseno` en datos: 20 zonas, 24 conexiones, 17 puzzles, 7 anillos | 2 |
| `scripts/templos/test_templo_m26.gd` | Suite headless de 7 bloques con marcadores `_fin()` | 2 |

Los `.uid` de cada script los genera Godot (`--editor --quit`).

## API real (GDScript)

```gdscript
# TemploFlow (RefCounted) — lógica pura, sin nodos ni autoloads.
const ANILLOS_TOTAL := 7
var anillos: Array[bool]          # 7
var glifos: Array[String]         # glifo esperado por anillo
var sellos_disponibles: Dictionary  # sello_id -> true
var sellos_colocados: Dictionary    # indice(int) -> sello_id
var sello_restaurado: bool
var ultimo_motivo: String

func registrar_sello(sello_id: String) -> bool            # rechaza vacío/duplicado
func activar_anillo(indice: int, sello_id: String, glifo: String) -> bool
func anillos_activos() -> int
func progreso() -> float
func restaurar_sello() -> bool                            # exige los 7 anillos
func salida_abierta() -> bool
func intentar_abrir_salida() -> bool                      # falla sin sello restaurado
func estado() -> Dictionary
func cargar_estado(datos: Dictionary) -> void
signal anillo_activado(indice: int)
signal sello_restaurado_ok()                              # hook de cutscene (M33)

# TemploCheckpoint (RefCounted)
const CP_IDS := ["porte", "vestibulo", "vientos", "central", "sello"]
func asegurar_dir() -> bool
func guardar(id: String, datos: Dictionary) -> bool       # atómico
func cargar(id: String) -> Dictionary
func cargar_con_respaldo(id: String) -> Dictionary        # cae al .bak
func borrar(id: String) -> bool
func listar() -> Array[String]
func cantidad_backups() -> int
func cantidad_tmp_huerfanos() -> int
func validar_atomico() -> Array[String]

# TempleTelemetria (RefCounted)
func avanzar(delta_s: float) -> void                      # reloj inyectable
func registrar_intento(puzzle_id: String, pistas_usadas: int = 0) -> void
func registrar_resolucion(puzzle_id: String, tiempo_s: float = -1.0) -> void
func resumen(puzzle_id: String) -> Dictionary
func resumen_global() -> Dictionary
func exportar_a_m24() -> Dictionary
func exportar_json() -> String
func cargar_json(txt: String) -> bool
func puzzles_dificiles(umbral: int = 3) -> Array[String]

# TemploValidadores (RefCounted) — todo `static`
func validar_softlock(layout: Dictionary) -> Array[String]
func validar_anti_exploit(layout: Dictionary, blueprint: Dictionary) -> Array[String]
func validar_voxel(blueprint: Dictionary) -> Array[String]
func validar_accesibilidad(blueprint: Dictionary) -> Array[String]
func validar_orientacion(blueprint: Dictionary) -> Array[String]
func validar_checkpoints(layout: Dictionary, blueprint: Dictionary) -> Array[String]
func validar_todo(layout: Dictionary, blueprint: Dictionary) -> Dictionary
func alcanzables(layout: Dictionary, desde: String) -> Dictionary
func adyacencia(layout: Dictionary) -> Dictionary
```

## Integración con M24

`TemploFlow` y `TemploValidadores` **no** dependen del framework `PuzzleRoom`
(M24, `scripts/templos/puzzle_room.gd`): trabajan sobre los datos del layout.
La conexión prevista es:
- `PuzzleRoom.al_cambiar` (M24) → activa el anillo correspondiente vía `TemploFlow.activar_anillo()`.
- `PuzzlePuerta.evaluar()` (M24) → puertas de sala; el gating de la salida es de `TemploFlow`.
- `TempleTelemetria.exportar_a_m24()` → balance de dificultad de M24.

## ⚠️ Diseño original NO implementado (rutas muertas)

El `04-Codigo.md` original (iteración 0, 2026-08-17) describía estos archivos:

```
Assets/_Project/Scripts/World/Templo/TempleFlow.cs
Assets/_Project/Scripts/World/Templo/TempleVoxelBlueprint.asset
Assets/_Project/Scripts/World/Templo/AnilloViento.cs
Assets/_Project/Scripts/World/Templo/PuzzleFinalFases.cs
Assets/_Project/Scripts/World/Templo/TempleCheckpoint.cs
Assets/_Project/Scripts/World/Templo/TempleTelemetry.cs
Assets/_Project/Scripts/Data/Templo/*.json
```

**Ninguno existe ni puede existir:** son rutas **Unity/C#** (`Assets/_Project/…`,
`.cs`, `.asset`) en un proyecto **Godot/GDScript**. Es parte del mismo patrón de
diseño muerto que el proyecto ya contabiliza (329 rutas `.cs` en la
documentación). La implementación real es la de la tabla de arriba. El mapeo es:
`TempleFlow.cs` _(diseno heredado)_ → `templo_flow.gd`; `TempleVoxelBlueprint.asset` →
`templo_blueprint.json`; `AnilloViento.cs` _(diseno heredado)_ + `PuzzleFinalFases.cs` _(diseno heredado)_ → dentro de
`templo_flow.gd` (los 7 anillos son estado de `TemploFlow`); `TempleCheckpoint.cs` _(diseno heredado)_
→ `templo_checkpoint.gd`; `TempleTelemetry.cs` _(diseno heredado)_ → `templo_telemetria.gd`;
`Data/Templo/*.json` → `data/templos/*.json`.

## Reglas de implementación

1. El templo se genera desde `templo_blueprint.json` + `templo_layout_diseno.json`
   (M08); **el diseño de salas es datos, no código**.
2. Gating estricto: la salida se abre solo con `restaurar_sello()`; los sellos son
   objetos únicos (cofre de M66).
3. Los 5 CP usan guardado atómico + `.bak`.
4. Anti-exploit: sin teleports, rampas ≤ 20°, barreras invisibles en huecos;
   `TemploValidadores` lo verifica.
5. Telemetría en JSON exportable a M24.
6. No tocar M45/M47 (assets) ni M33 (cutscenes) — solo hooks (señales).
7. Documentar cada desvío en `plan-actual/` + Log en `Logs/` + fila 26 del CHECKLIST-GLOBAL.

## ⚠️ Trampas medidas en este host (Godot 4.7.2 headless, `--path` relativo)

1. **`DirAccess.open("user://…")` devuelve `null`** y `DirAccess.get_files_at()`
   sobre `user://` devuelve `[]`, aunque `FileAccess` **sí** resuelve `user://` y
   `DirAccess.open("res://")` funciona. La forma que sí funciona es globalizar
   primero: `DirAccess.open(ProjectSettings.globalize_path("user://…"))`.
   Medido con sonda el 2026-09-14.
2. **`DirAccess.new()` no existe** (`DirAccess` es abstracta) y
   `DirAccess.make_dir_recursive()` **no es estático**: la variante estática es
   `make_dir_recursive_absolute()`, que acepta `user://` tal cual.
3. `globalize_path("user://")` devuelve una ruta **relativa**
   (`./Godot/app_userdata/isla-ancestral/`): el `user://` real es
   `game/isla-ancestral/Godot/app_userdata/isla-ancestral/`.
4. Un error de script **aborta la función en silencio**: de ahí los marcadores
   `_fin()` por bloque en la suite (si un bloque no se ejecuta, el marcador falta
   y el test lo delata).

## Notas del Agente

**Modelo:** DeepSeek-V4.1-Flash / WorkBuddy
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-14
**Estado:** Implementación de la parte verificable (lógica + datos + tests). El
módulo sigue 🟡 porque la geometría (M08), los assets (M45/M47/M52/M63), el audio
(M41/M42/M43) y las UI de M58 no existen todavía.

- Iter. 2 implementó gating, checkpoints atómicos, telemetría y los validadores;
  92 checks, 0 fallos, EXIT 0 ×3, 0 `SCRIPT ERROR` (ver `07-Resultados-Testings.md`).
- De paso se corrigió un **bloqueante de proyecto**: `scripts/backup/backup_manager.gd`
  (M107, autoload `BackupManager`) no compilaba por `DirAccess.new()` sobre una
  clase abstracta — eso rompía el autoload y ensuciaba con 3 `SCRIPT ERROR` la
  salida de **toda** corrida headless del proyecto (BUG-035).
- El encabezado original del checklist afirmaba `100/100 [x]` sin marcadores
  puestos: era sobre-cierre de bookkeeping. Ver `05-Checklist.md` §Convención.
