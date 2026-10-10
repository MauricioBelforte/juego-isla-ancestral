# Log 1575: BUG-052 — medición completa (434/418/16) y decisión: limpiar los 16 respaldos, NO subir el trinquete

**Fecha:** 2026-10-10
**Hora:** 01:49
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Encargo del msg 95 (canal mimo): BUG-052 — 434 GLBs / 0 sidecars, trinquete
`max: 418` excedido en 16. Se midió todo en disco y con el validador real
(ambos modos), se auditaron los 16 archivos (hash, referencias, git) y se
decide: **limpiar los 16 (moverlos fuera del árbol del proyecto), NO subir el
trinquete a 434.** Decisión reportada al director para su luz verde (msg 93:
"Mídelo y dime"); no se movió ningún archivo en esta ronda.

## Cambios Realizados

Ninguno en producción (ronda de medición/decisión). Solo este log.

## Mediciones (todas con disco/herramientas reales)

### Conteo de GLB en `game/isla-ancestral/assets/3d` (recursivo)

| Categoría | Cantidad |
|---|---|
| Total `.glb` en disco | **434** |
| Dentro de `media/Obsoletos/` | **16** |
| Activos (fuera de Obsoletos) | **418** |

Claim de 11-BUGS/Log 1035 (agnes-3-flash): **434 = 418 + 16 — confirmado exacto.**

### Validador (`tools/legal/validate_asset_metadata.py`)

- `--check` (gate CI): **EXIT 0** — `sin atribucion embebida: 418`, `aceptados 418 de max 418`, `0 hallazgos nuevos`. Cuenta **418** porque el scope excluye `"Obsoletos"` → **verde por exclusión** (el disco tiene 434).
- `--estricto`: **EXIT 1** por diseño (`exit 1 si hay cualquier hallazgo, techo incluido` — L599-600 del script): hay 418 sin atribución. No es regresión.

### Auditoría de los 16 (`assets/3d/media/Obsoletos/`)

- Composición: 15 × `50-Vegetacion_*.glb` en `respaldo_original_2026-09-04_06-06-43/` + 1 × `conejo_v5_aprobado_2026-09-04_23-36-40.glb`.
- **MD5 vs homónimo activo:** los **15 de vegetación son IDÉNTICOS byte a byte** (duplicados puros); el conejo es versión previa (v5 aprobada, activo hoy = `36-Fauna_conejo.glb`, existe en `alta/` y `media/`).
- **Referencias:** grep recursivo `media/Obsoletos|Obsoletos/respaldo|conejo_v5` sobre TODO `game/isla-ancestral/` → **0 hits** (nada de scripts, scenes, data).
- **`.import`:** los 16 los tienen (Godot los importa hoy → entran en "Export all resources" = bloat de export sin uso).
- **Git:** los 16 están trackeados (recuperables siempre).
- Tamaño total: 675.5 KB.

## Decisión: LIMPIAR (mover), NO subir el trinquete

**Opción A — subir `max` 418 → 434: RECHAZADA.** Razones:
1. No cambia lo medido: el validador excluye `Obsoletos` → siempre cuenta 418; subir el techo a 434 solo daría **+16 de holgura fantasma** (16 GLBs nuevos sin copyright pasarían sin fallar `--check`), aflojando el gate diseñado para fallar con el primer activo nuevo.
2. Semántica: el trinquete es **techo de deuda de assets ACTIVOS**; los 16 son respaldos, no deuda. Subirlo contaría respaldos como deuda.
3. `max 434` vs `contados 418` = discrepancia permanente 16 en el propio config.

**Opción B — limpiar los 16: ACEPTADA (recomendada al director).** Razones:
1. Disco 434 → 418 = techo 418 = conteo 418 → desaparece el "excedido en 16" y el verde deja de depender de la exclusión para estos archivos.
2. 15/16 son duplicados idénticos; el 16 tiene homónimo activo. 0 referencias. Trackeados en git.
3. Godot deja de importar/exportar 16 GLB + 16 `.import` inútiles.
4. No se borra nada: se **mueven** a `Obsoletos/` raíz del repo (fuera de `res://`), convención §5 AGENTS.md.

**Plan listo (pendiente de OK del director, msg siguiente):**
```powershell
$dst = "Obsoletos\2026-10-10_01-49-00_glb-respaldos-assets-3d"
Move-Item "game\isla-ancestral\assets\3d\media\Obsoletos" $dst -Recurse
# + mover los .import (quedan junto a cada .glb, ya incluidos en el Move-Item
#   porque viven DENTRO de Obsoletos/) — verificar 418 en disco,
#   re-correr validador --check (418/418, exit 0) y runner completo.
```
Nota: los `.import` de los 16 están dentro de `media/Obsoletos/` (junto a su
`.glb`), así que un `Move-Item -Recurse` de la carpeta los transporta juntos.

## Archivos Modificados/Creados

- `Logs/1575-BUG-052-medicion-434-418-16-y-decision-limpiar-16-no-subir-trinquete_2026-10-10_01-49-00.md` (este)
- Informe en el canal mimo (msg siguiente a 95)

## Firmas

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-10 01:49

---

## ACTUALIZACIÓN POST-MOVIMIENTO (2026-10-10 02:33)

**Luz verde del director (msg 97, 05:15)**: "LIMPIEZA AUTORIZADA — muévelos los 16, trinquete
intacto en 418". Ejecutado y verificado:

### Movimiento aplicado

- **Lección de entorno:** el plan original usaba `Move-Item ... -Recurse` — **`Move-Item` de
  PowerShell 5.1 NO tiene parámetro `-Recurse`** (falla con `NamedParameterNotFound`; nada se
  movió en el primer intento, verificado 434 intactos). Sin `-Recurse`, `Move-Item src dst`
  (dst inexistente) mueve la carpeta completa con hijos = rename. Comando final:
  `Move-Item "game\isla-ancestral\assets\3d\media\Obsoletos" "Obsoletos\2026-10-10_01-49-00_glb-respaldos-assets-3d"`
- Origen ya no existe; destino con **32 archivos** (16 `.glb` + 16 `.import`).

### Las 3 verificaciones obligatorias (msg 97) — TODAS EN VERDE

| # | Verificación | Resultado |
|---|---|---|
| V1 | Disco `.glb` en `assets/3d` recursivo | **418** ✓ (era 434) |
| V2 | Validador `--check` | **418/418, EXIT 0** ✓ (0 hallazgos nuevos) |
| V3 | Runner completo `tests/run_tests.gd` | **EXIT 0** ✓ — `suites OK: 29/29`, `checks SceneTree 1246 + GdUnit4 21 = 1267 tests`, `0 fallos` |

- **V3 detalle:** primer intento a los 7 min excedió el timeout de la tool (25/29 OK, muerto en
  fase GdUnit4); re-ejecutado con 15 min → **EXIT 0 completo**. Err solo contiene 2
  `push_warning` **preexistentes**: `[M39] tienda sin npc_duenio_id` y `[M163] IncenseSpawner:
  0 puntos (24 fallas de altura en centro)` = **síntoma de BUG-119** (reportado por s3 antes del
  movimiento, NO causado por esta limpieza: los 16 no tenían 0 referencias).
- **Nota:** mi conteo auxiliar de fallos marcó "1" por falso positivo case-insensitive sobre la
  palabra `failures` de la línea `0 failures`; la línea `[EVIDENCIA]` del propio runner
  (`29/29 ... 0 fallos`) es la fuente autoritativa.

### Scope JSON actualizado (motivo, `max` intacto)

- `tools/legal/asset_metadata_scope.json` L33: "los **434** .glb exportados" → "los **418**
  .glb exportados" + nota de cierre `(2026-10-10 BUG-052: los 16 respaldos ... movieron a
  Obsoletos/2026-10-10_01-49-00_glb-respaldos-assets-3d; disco = techo = 418.)`.
- **`max: 418` NO tocado** (directiva expresa del msg 97).

### Estado git (sin stage — prohibido para mí)

- 16 `.glb` trackeados aparecen como ` D` en worktree (borrados en disco, no staged).
- Los 16 `.import` no estaban trackeados (gitignored) → no aparecen.
- Destino `Obsoletos/2026-10-10_.../` = untracked. Stage global: **0 líneas**.
- El commit lo hace el director.

### Sin flips de marcas

- `11-BUGS.md` BUG-052 sigue `[ ]` — **el flip lo hace el director** con este reporte
  (msg 97: "Reporta 418/418 EXIT 0, runner EXIT 0 → yo flipo").

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-10 02:33
