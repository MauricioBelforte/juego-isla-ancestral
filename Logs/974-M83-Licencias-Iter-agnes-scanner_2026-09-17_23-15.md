# Log 974: M83 Licencias — iter. agnes acotada (capa scanner del diseño §A)

**Fecha:** 2026-09-17
**Hora:** 23:15
**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code

## Resumen

Iteración del bucle V0/tooling/data-driven de **agnes-3-flash** sobre **M83 Licencias de Software**
(relevo del `Revertido por auditoría 2026-09-14` que había marcado M83 "completado" sin verificación).
**Alcance deliberadamente acotado:** implementar la **capa scanner** que faltaba del diseño §A y dejar
la capa de Resources (decisión de diseño) para el dueño M83.

## Cambios Realizados

- **Nuevo `scripts/licensing/license_scanner.gd`** (`class_name LicenseScanner`, `RefCounted`, funciones
  `static` → headless/CI sin autoload):
  - `TYPES`: catálogo data-driven de los 15 tipos de §A.2 (Array, no `enum` — pitfall de enums).
  - `classificar(texto)`: clasificador por **frases de alta señal** (AGPL>LGPL>GPL>MPL>CC_BY_NC>CC0>
    CC_BY>APACHE_2>BSD_3/2>MIT) con fallback `UNKNOWN`.
  - `detectar_archivo_licencia(dir)`: LICENSE/LICENSE.txt/LICENSE.md/COPYING/COPYING.txt.
  - `scan_addon(dir)`: plugin.cfg (name/version) + clasificación de la licencia.
  - `scan_addons()`: inventario de `res://addons/` vía `DirAccess.get_directories()`.
  - `cargar_catalogo()`: `data/legal/licencias.json`.
  - `reporte(inventario)`: logging legible de cada licencia.
- **Nuevo `scripts/licensing/test_license_scanner_m83.gd`** (headless, SceneTree): **24 checks, 0 fallos,
  exit 0** (clasificador 12 tipos + 2 fallback; detección en addons reales gdUnit4/voxel → MIT;
  catálogo; regresión con `LicenseValidator`).
- **`quality.yml`:** gate duro `test-suite` ahora corre `test_licenses_m83.gd` +
  `test_license_scanner_m83.gd`.
- **`05-Checklist.md` M83:** 7 ítems §A re-marcados `[x]` con evidencia (A.2/A.4/A.6/A.7/A.8/A.9/A.14);
  `Totales` corregido (stale 7 → **16 `[x]`/84 `[ ]`**); §"Iteración agnes" agregado.
- **`04-Codigo.md` M83:** §"Iteración agnes — capa scanner".

## Hallazgos (trampas medidas)

1. **`DirAccess.iterate_subdirs`/`iterate_directories` no existen en Godot 4.7.2** — el método correcto es
   `get_directories()` (análogo a `get_files()`). Verificado con introspección `get_method_list()`.
2. **Falso positivo del clasificador por substring:** el marcador `mpl` (3 letras) falseaba con la
   palabra "im**pl**ied" del texto MIT → los addons MIT se clasificaban MPL_2. Fix: frases de alta señal
   (`mozilla public license` / `mpl 2.0`), nunca substrings cortos.
3. **`Totales` stale:** el checklist decía "Completados: 7" pero traía 9 `[x]` reales (desfase de la
   re-verificación de MiMo). Corregido a 16.
4. **Boot-time UI errors ajenos:** 6 `SCRIPT ERROR` de `theme_ux`/`theme_service`/`dialog_layer`/`ui_root`
   (preexistentes) no afectan el exit 0/1 del test M83.

## Verificación (godot 4.7.2 headless)

- `godot --headless --script res://scripts/licensing/test_license_scanner_m83.gd` → **24 checks, 0 fallos,
  exit 0**, 0 `SCRIPT ERROR` propios de M83.
- Regresión: `test_licenses_m83.gd` → **17 checks, 0 fallos, exit 0**.

## Estado de M83
🟡 **Liberado (iter. agnes scanner, acotada).** 16/100. Mi parte (capa scanner §A + test + gate CI)
entregada y verificada. Los ítems `§A.1/A.3/A.5/A.10` (Resources `LicenseProfile`/`LicensePolicy`,
`scan_project` completo, `scan_directory` recursivo, inventario-Resource) siguen `[ ]` = **decisión del
dueño M83** (yo usé Dictionary+JSON para no forzar el diseño). QA cruzado §21.8 pendiente
(verificador ≠ agnes-3-flash).
