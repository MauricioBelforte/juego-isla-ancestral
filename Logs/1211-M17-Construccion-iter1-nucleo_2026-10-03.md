# Log 1211 - M17-Construccion: iter. 1 (nucleo de dominio + persistencia M60)

**Fecha:** 2026-10-03
**Modulo:** 17-Construccion (construccion sobre el mundo de voxels, M08)
**Autor:** DeepSeek-V4.1-Flash (WorkBuddy)
**Tipo:** iteracion de implementacion. **NO sella 21.8** (autor != verificador).
**Binario:** `C:\Temp\godot\godot472.exe --headless --path game/isla-ancestral --script res://scripts/construccion/test_construccion.gd`

---

## Alcance de la iteracion

Nucleo de dominio de la construccion: sesion, validacion, colocacion/demolicion,
undo/redo y persistencia. **Fuera de alcance** (iteraciones siguientes): preview/ghost
visual, catalogo completo de 12 familias, integracion con M18, badges de QA.

### Archivos NUEVOS (`game/isla-ancestral/scripts/construccion/`)

| Archivo | class_name | Rol |
|---|---|---|
| `construccion_tipos.gd` | `ConstruccionTipos` | enums `Modo`/`Permiso`/`Motivo` + textos + clave de celda |
| `placement_rule.gd` | `PlacementRule` | Resource de receta: tamano, soportes, costo, bloque, huella, devolucion |
| `zone_registry.gd` | `ZoneRegistry` | zonas (AABB + permiso); la zona mas especifica (menor volumen) gana |
| `construccion_validator.gd` | `ConstruccionValidator` | AUTORIDAD unica de validacion (7 etapas) |
| `build_history.gd` | `BuildHistory` | undo/redo por deltas (limite 200, limpia redo al registrar) |
| `construccion_mundo.gd` | `ConstruccionMundo` | adaptador M08 (`VoxelTool`): superficie / escritura / borrado |
| `build_manager.gd` | (autoload `Construccion`, sin class_name) | fachada: sesion, colocacion, demolicion, undo/redo, persistencia |

- Datos: `game/isla-ancestral/data/construccion/piezas/{pared_madera,piso_tablones,techo_paja}.tres`
- Autoload: `project.godot` -> `Construccion="*res://scripts/construccion/build_manager.gd"`

## Hallazgo 1 - colision de `class_name`

El diseno proponia `class_name BuildValidator`, pero ESE nombre ya es global y pertenece
a **M117** (`game/isla-ancestral/scripts/build/build_validator.gd:10`). Dos `class_name`
iguales rompen el proyecto entero. Renombrado a **`ConstruccionValidator`**. Verificado:
los otros 6 nombres propuestos (`BuildManager`/`BuildPreview`/`BuildGhost`/`BuildHistory`/
`PlacementRule`/`ZoneRegistry`) estan libres (0 colisiones).

## Persistencia - cierra BUG-057 (contrato M60, sin tocar `scripts/saving`)

`BuildManager` expone el contrato que `scripts/datos/buildings_save_provider.gd` busca por
duck-typing:
- `obtener_estructuras() -> Array`  (copia canonica, **sin aliasing**)
- `restaurar_estructuras(lista) -> void`  (idempotente)

Forma canonica = la de `EstructurasCodec`: `{id, tipo, pos[3] int, rot_y, planta, variante}`.
`_alta_estructura()` **reconstruye `pos` desde la celda** (no reutiliza el `pos` de la
entrada) -> mover/undo dejan la ocupacion coherente.

## Prueba (binario real, verde)

```
=== RESUMEN M17 CONSTRUCCION: 131 checks, 0 fallos, 12 bloques cerrados ===
RESULTADO: OK
EXIT=0
```

`CHECKS_MINIMOS = 131` (**medido en verde**, no estimado). Guardian anti-falso-verde de
3 capas: `_fin(clave)` por bloque + piso de checks + `_summary()` en `call_deferred` que
decide el exit code y **NOMBRA** los bloques sin cerrar.

Bloques: 1 tipos - 2 placement_rule (incl. rotacion + semantica half-open de zona) -
3 zone_registry - 4 validador camino feliz (AFIRMA `ok == true`) - 5 motivos (los 11 +
acumulacion + ctx vacio falla cerrado) - 6 history - 7 sesion - 8 colocar - 9 demoler/
undo/redo - 10 mover + rollback - 11 persistencia (duck-typing REAL de
`BuildingsSaveProvider`, sin aliasing, idempotencia, `pos` TYPE_INT) - 12 catalogo `.tres`.

## Prueba en ROJO (el guardian, probado por inyeccion)

- **PROBE A** (funcional: `tiene_soporte()` forzado a `true`, i.e. soporte desactivado):
  `exit 1`, 3 fallos nombrados -> `RESUMEN: 131 checks, 3 fallos, 12 bloques cerrados`,
  `RESULTADO: FALLO (3)`.
- **PROBE C** (aborto de runtime DENTRO del bloque 8): `exit 1`, el guardian NOMBRA
  `[8]` y reporta `PISO NO CUMPLIDO: 120 checks < CHECKS_MINIMOS=131` +
  `RESULTADO: FALLO (suite incompleta)`. Prueba las capas 1 y 3.

Ambas sondas restauran el archivo mutado byte-exacto (`bytes iguales: True`). Sondas en
`Obsoletos/raiz-temporales-m17-2026-10-03/probe_a.py` y `probe_c.py`.

## Gate en `quality.yml`

Job `test-suite`:
`godot --headless --script scripts/construccion/test_construccion.gd 2>&1 || FAIL=1`.
EOL preservado (843 -> 854 CRLF; el archivo es CRLF).

## Hallazgos AJENOS (no bloquean M17, no los toco)

1. **`godot-lint` esta ROJO localmente** por errores de parseo **reales** en archivos
   VERSIONADOS de otros modulos (medido con Godot 4.7.2, el binario autoritativo):
   - `tests/unit/time/test_time_calendar.gd:28` ("Builtin type cannot be used as a name").
   - `tools/asset_pipeline/atlas_builder.gd:17` ("Expression is of type Node so it can't
     be of type String").
   - `tools/asset_pipeline/promote_asset.gd` / `retire_asset.gd` / `apply_import_presets*.gd`.
   - `tools/validate_dialogues.gd:73` (Variant inference, warning-as-error).
   Presentes desde `6014d11` (2026-09-02). **MIS archivos**: los 8 pasan `--check-only`
   (exit 0), y el colector regenerado reporta **0 errores** en `scripts/construccion/`.
2. El colector versionado `scripts/editor/_colector_sintaxis.gd` esta **STALE**: referencia
   `res://tools/probe_mesh_tmp.gd` (scratch) y `res://scripts/mapa/test_mapa_m54_e2e.gd`
   (cuarentenado por hy3, Log 1234). En CI se REGENERA antes de `--check-only`, asi que es
   inerte; lo dejo tal cual (restaurado byte-exacto tras mi verificacion).

## Estado / proximo

- M17 queda **En curso (iter. 1)**. NO sella 21.8.
- Siguiente: preview/ghost, catalogo de 12 familias, integracion M18, badges de QA.
