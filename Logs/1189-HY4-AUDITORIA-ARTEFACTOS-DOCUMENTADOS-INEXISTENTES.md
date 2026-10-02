# Log 1189 - HY4: auditoria de artefactos documentados inexistentes (B6)

**Modelo:** Hy4 preview (WorkBuddy)
**Fecha:** 2026-10-02
**Frente:** Opcion B "parchar huecos" - frente nuevo B6
**Archivos tocados:** 2 (marcas `_ (diseno heredado) _`) + este log + BACKLOG-MASTER

---

## 1. Que se midio

Pregunta: **la documentacion de `plan-actual` cita rutas de archivos que no
existen?** Se escaneo `DOCUMENTACION/**/plan-actual/*.md` buscando tokens con
forma de ruta (`gd`, `cs`, `tres`, `tscn`, `json`, `py`, `glb`, `blend`, `png`).

Resultado bruto: **2763 referencias** en 169 carpetas `plan-actual`.

## 2. Cinco mediciones hasta llegar a una confiable

El primer numero fue **1577 rutas rotas**. Era basura. Cuatro correcciones
sucesivas, cada una detectada sospechando del detector y no del repo:

| # | Detector | Resultado | Que estaba mal |
|---|----------|-----------|----------------|
| v1 | `os.path.exists` contra la raiz del repo | 1577 rotas | El proyecto Godot vive en `game/isla-ancestral/`; 1235 referencias resuelven ahi |
| v2 | + base `game/isla-ancestral/` | 958 rotas | Mezclaba diseno de modulos NO implementados (M120, M121, M125, M150...) con deriva real |
| v3 | + cruce con estado de `CHECKLIST-GLOBAL.md` | 284 menciones en 28 modulos cerrados | Faltaba una tercera base: `game/isla-ancestral/scripts/` |
| v4 | + 3 bases y clasificacion A/B/C | 1529 A - 147 B - 1087 C | `C` mezclaba "ausente" con "renombrado" |
| v5 | + `difflib` para separar C1/C2 | **1529 A - 147 B - 515 C2 - 572 C1** | - |

**Clasificacion final:**

- **A (1529)** - la ruta resuelve exactamente. Correctas.
- **B (147)** - la ruta no resuelve, pero un archivo con ese mismo nombre base
  existe en otra ruta. Doc desactualizada, artefacto vivo.
- **C2 (515)** - sin coincidencia exacta pero con candidato parecido
  (`difflib`, cutoff 0.72). Renombrado o reubicado.
- **C1 (572)** - sin coincidencia exacta ni parecida. **Artefacto ausente.**

## 3. Verificacion manual de los C1 principales

Ninguno de estos existe en el disco (comprobado uno a uno):

| Ruta citada | Modulo | Realidad |
|---|---|---|
| `addons/gut/gut_cmdln.gd` | M112 | El proyecto usa **gdUnit4**; `addons/` solo tiene `gdUnit4` y `zylann.voxel`. GUT nunca estuvo. |
| `addons/gdUnit4/bin/gdUnit4cmd.gd` | M112 | gdUnit4 esta, pero no ese bin. |
| `tests/helpers/autoload_overrides.gd` | M112 | `tests/helpers/` existe; este archivo no. |
| `tests/fixtures/fixture_items.tres`, `fixture_npc.tscn`, `fixture_save_data.gd`, `fixture_economy.gd`, `fixture_crop.tscn` | M112 | `tests/fixtures/` existe; esos 5 no. |
| `tests/unit/world_voxel/test_voxel_algorithms.gd` | M112 | Las carpetas de `tests/unit/` estan en espanol (`inventario`, `economia`, `eventos`...) |
| 7 rutas `tests/integration/...` | M112 | `tests/integration/` existe con otros nombres |
| `scripts/ui/crash_dashboard.gd` | M122 | `scripts/crash/` tiene 10+ `.gd` reales (`crash_alerts`, `crash_analytics`, `crash_bug_tracking`, `crash_context_sanitizer`...), no ese |
| `scripts/services/metadata_collector.gd` | M122 | Ausente |
| `scripts/mcp/screenshot_mcp.py` | M154 | Ausente (citado 5 veces) |
| `scripts/blender/setup_estudio.py`, `scripts/blender/personaje_voxel.py` | M154 | Ausentes |
| `scripts/core/legal/parental_consent_service.gd` | M81 | Ausente |
| `scripts/core/legal/iarc_submission.gd`, `rating_display.gd` | M82 | Ausentes |
| `data/player/player_motion.tres` | M11 | Ausente (citado 3 veces) |

## 4. Falsos positivos reconocidos (para no re-auditar)

- **M26 Templo Subterraneo** - las 5 rutas `Assets/_Project/Scripts/World/Templo/*.cs`
  aparecen en C1, pero el propio `04-Codigo.md` ya tiene un bloque
  `! Diseno original NO implementado (rutas muertas)` que lo explica.
  **El detector es ciego al contexto**: no hay que tocar nada.
- **M106 Seguridad** - `security/api_security.gd`, `key_manager.gd`,
  `input_validator.gd`, `output_validator.gd`, `tamper_protection.gd`,
  `duplication_prevention.gd`, `economy_validation.gd`, `audit_logger.gd`
  figuran como rotas, pero **todos existen** como
  `game/isla-ancestral/scripts/security/security_<nombre>.gd`.
  Es deriva de prefijo, no ausencia. (Esto casi se reporta como hueco:
  se detecto al verificar a mano.)
- **Modulos sin implementar** (M120 DLC, M121 Soporte, M125 Terminos,
  M150 Diseno Sonoro, M90 Grafica, M91 Audio, M58 Accesibilidad...) - sus rutas
  son **intencion de diseno**, no referencias rotas. 1030 de las 1314
  menciones "rotas" caen aqui.

## 5. Accion tomada (2 archivos)

Solo donde el `[x]` cita un artefacto que **no puede existir** (ruta Unity/C#
en un proyecto Godot/GDScript):

- `DOCUMENTACION/118-CI-CD/plan-actual/05-Checklist.md:34` -
  `[x] Godot Editor script BuildScript.cs configurado`  marcado
  `_ (diseno heredado) _`, con el equivalente vivo `scripts/core/build_info.gd`.
- `DOCUMENTACION/81-Legal-Menores/plan-actual/05-Checklist.md:75` -
  `[x] Disenar DataSanitizer.cs...`  marcado `_ (diseno heredado) _`.

Se preserva el `[x]`: **no se volteo ninguna casilla**. Voltear es decision de
QA (21.8) y el perfil Hy4 excluye el sello.

## 6. Lo que NO se hizo

- **No se volteo ningun `[x]`**  se reporta, no se sella.
- **No se reescribieron las 662 rutas desactualizadas (B + C2)**. Riesgo alto:
  una sustitucion masiva con rutas inferidas ya costo 205 reemplazos
  inventados (trampa 60). Queda como tarea con verificacion manual.
- **No se auditaron modulos no cerrados**: su documentacion es intencion.

## 7. Hallazgo para el coordinador / Hy3

**28 modulos marcados  citan artefactos ausentes.** El mas afectado es
**M112 Testing Automatico** (25 rutas citadas que no existen, incluido el
framework GUT completo, que nunca se uso). Siguen M154 (18), M122 (7),
M123 (6), M82 (6), M81 (5), M11 (4).

B2 ("auditoria de sobre-cierre", Log 904) concluyo *ninguno sobre-cerrado*
contando casillas. **Este log mide otro eje**: existencia real de los
artefactos que la propia documentacion cita. Los dos resultados son
compatibles y no se contradicen: un modulo puede tener su checklist
coherente y aun asi documentar archivos inexistentes.

## 8. Trampa nueva (62) - tres bases de resolucion antes de creer un "roto"

Un detector de rutas rotas sobre este repo necesita probar al menos:

1. raiz del repo
2. `game/isla-ancestral/`
3. `game/isla-ancestral/scripts/`

y ademas **separar "ausente" de "renombrado"** (`difflib` sobre nombres base)
y **descartar modulos no implementados** cruzando con `CHECKLIST-GLOBAL.md`.
Sin esos cuatro filtros el numero inflado (1577) es indistinguible del real.

**Regla:** un "roto" solo es un hueco si el modulo esta cerrado Y el nombre
base no aparece en ningun lado del repo.
