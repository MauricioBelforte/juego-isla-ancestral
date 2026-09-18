**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

# 07-Resultados-Testings.md — Módulo 127: Copyright del Juego

> **Iter. 3 (2026-09-18, Log 986).** Cifras **medidas**, no copiadas: cada suite se
> corrió y se leyó su última línea `=== Resumen ===` (las líneas previas pueden ser
> las de la inyección del bloque `test_inyeccion`).

## 1. Suites de `tools/legal/` (Python, stdlib)

| # | Suite | Checks | Fallos | Exit |
|---|---|---|---|---|
| 1 | `test_generate_copyright.py` | 13 | 0 | 0 |
| 2 | `test_generate_authors.py` | 10 | 0 | 0 |
| 3 | `test_generate_register.py` | 18 | 0 | 0 |
| 4 | `test_signoff_check.py` | 12 | 0 | 0 |
| 5 | `test_insert_copyright_headers.py` | 32 | 0 | 0 |
| 6 | `test_timestamp_seal.py` | 30 | 0 | 0 |
| 7 | `test_scan_orphan_code.py` | 19 | 0 | 0 |
| 8 | `test_validate_asset_metadata.py` | 71 | 0 | 0 |
| 9 | `test_audit_dependencies.py` | 40 | 0 | 0 |
| 10 | `test_dump_authorship_evidence.py` | 35 | 0 | 0 |
| 11 | `test_registros_db.py` | 44 | 0 | 0 |
| | **TOTAL** | **324** | **0** | **0** |

Desglose de la iter. 3 (las 7 suites nuevas): **32 + 30 + 19 + 71 + 40 + 35 + 44
= 271 checks, 0 fallos**.

## 2. Suite GDScript (runtime)

```
godot --headless --path game/isla-ancestral \
      --script res://scripts/legal/test_copyright_m127.gd
```

| Corrida | Checks | Fallos | `SCRIPT ERROR` | Exit |
|---|---|---|---|---|
| 1 | 13 | 0 | 0 | 0 |
| 2 | 13 | 0 | 0 | 0 |
| 3 | 13 | 0 | 0 | 0 |

Sin regresión tras insertar la cabecera de copyright en `copyright_validator.gd`
y `test_copyright_m127.gd` (+4 líneas cada uno, `git diff --stat` = 8 inserciones,
0 borrados): la cabecera va antes de `extends`, que es legal en GDScript.

## 3. Gates de CI (`--check`) sobre el repo real

| Gate | Resultado | Exit |
|---|---|---|
| `insert_copyright_headers.py --check` | 0 pendientes (idempotente) | 0 |
| `timestamp_seal.py --cadena` | cadena intacta | 0 |
| `scan_orphan_code.py --check` | 0 huérfanos *(tras commitear las 14 herramientas nuevas)* | 0 |
| `validate_asset_metadata.py --check` | 0 nuevos sobre el techo declarado | 0 |
| `audit_dependencies.py --check` | 0 nuevos sobre el baseline declarado | 0 |
| `registros_db.py --check` | 0 errores de contrato | 0 |

Modo `--estricto` (cuenta también el techo): sale **1** en los dos validadores con
deuda, que es exactamente lo que debe hacer.

## 4. Evidencia medida sobre el repo real

### 4.1 Sellado SHA-256 (`timestamp_seal.py --crear`)

```
archivos     = 135
bytes        = 390 704
hash_arbol   = 1ab1687367daad9e83c51504e5428b4ad5f6f3af57df22c757d6011b6b27bd7b
hash_previo  = (primer sello)
hash_cadena  = 0786f5d5871c88ad92b3439c5d1f1cab2835905197a51bbc9f04e88adfaa939f
```

El sello se **regeneró** una vez: el primero se creó mientras todavía se escribían
las herramientas, así que sellaba versiones intermedias. Un sello que no cubre las
versiones finales es evidencia engañosa. Queda un solo sello, el bueno.

### 4.2 Metadata de assets (`validate_asset_metadata.py`)

```
archivos en alcance        = 422
magic inválido (placeholder) = 3
sin atribución embebida    = 418
con atribución embebida    = 0
entradas de inventario     = 54 (incompletas: 0)
```

**Los 3 placeholders** son `assets/fonts/{FredokaOne-Regular,Nunito-Bold,Nunito-Regular}.ttf`:
304 KB cada uno, magic `0a0a0a0a`, contenido real = **HTML** (páginas 404 de
`github.githubassets.com` guardadas con extensión `.ttf`). Es BUG-042; dueño M46/M88.
No se borraron: son de otro módulo.

**Los 418 sin atribución** son `.glb` exportados por el I/O de Blender con
`asset.generator` pero **sin `asset.copyright`**. glTF 2.0 tiene el campo; el
exportador no lo escribe. Dueño: pipeline de exportación (M166/M09).

### 4.3 Dependencias (`audit_dependencies.py`)

```
addons en disco    = 2   (gdUnit4, zylann.voxel)
manifiestos        = 2   (2 excluidos del build)
assets de terceros = 4
placeholders       = 3
hallazgos          = 5 → 4 aceptados en baseline + 1 resuelto declarando el manifiesto
```

- **`addons/gdUnit4`** (autor *Mike Schulze*, v6.2.1, MIT, `LICENSE` presente en
  disco) **no está declarado** en `licencias.json` ni en `NOTICE.md`. Es un addon
  de *testing*: decidir si se declara y se atribuye, o si se saca del árbol antes
  del build. **Decisión del dueño** — el auditor no toca `licencias.json` porque
  ese archivo alimenta `NOTICE.md` y `LICENSE`, que son artefactos legales.
- `addons/zylann.voxel` → declarado como `voxel_tools` (MIT), con `LICENSE.md` y
  presente en `NOTICE.md`. Sin hallazgos.
- `tools/mcp/godot-mcp/package.json` (5 deps) no estaba declarado: se agregó a
  `manifiestos_excluidos` con motivo (tooling de desarrollo, fuera del build).

### 4.4 Volcado de autoría (`dump_authorship_evidence.py --generar`)

Sobre `game/isla-ancestral/scripts/legal`: 5 commits, 52 archivos tocados,
+4033/−54, 1 autor. Sobre el repo entero en el rango `2026-09-01..2026-09-18`:
187 commits, 39 209 bytes de volcado, huella SHA-256 generada y verificada.

## 5. Hallazgos técnicos de la iteración (bugs de las propias herramientas)

Los encontró la suite, no una lectura casual. Cada uno está cubierto por un check.

| Hallazgo | Cómo se detectó | Arreglo |
|---|---|---|
| `detectar_contenido()` no ignoraba el espacio en blanco inicial | El fixture HTML empieza con `\n\n`; el real con 8 saltos. Reportaba "texto plano" en vez de "HTML" | `lstrip()` antes de comparar |
| La tabla de magic usaba **OR** en formatos multi-firma | Un `RIFF/WAVE` con extensión `.webp` pasaba como válido | Alternativas (OR) con requisitos internos (AND) |
| El parser de comentarios Vorbis se quedaba el NUL terminador | `COPYRIGHT="Isla Ancestral\x00\x00..."` ≠ `"Isla Ancestral"` | Parser real del bloque `\x03vorbis` con longitudes LE |
| `--json` imprimía el resumen en stdout | `json.load()` moría con `Extra data` | JSON puro en stdout, resumen a stderr |
| `fnmatch` no da semántica globstar | `*/assets/*.ttf` **no** matchea `assets/x.ttf`; `**/assets/3d/*.glb` **no** matchea `assets/3d/alta/x.glb` | `coincide_patron()` propio con `**/` |
| Faltaba `import re` en `validate_asset_metadata.py` | `NameError` al aplicar el baseline | Import agregado |
| `FORMAT` vs `FORMATO` (typo) | `NameError` en la primera corrida | Corregido |
| El volcado **no** es determinista con rango abierto | Dos corridas seguidas dieron cuerpos distintos: entró un commit ajeno mientras corrían 187 `git show` | Documentado: el determinismo vale para rango **cerrado**; el test usa `2026-09-01..2026-09-10` |
| El árbol de trabajo restaurado sin mi cambio | Técnica de bytes: si se restaura sin lo mío, el próximo commit ajeno revierte el cambio en silencio | Se escribe `árbol_actual + lo mío`, no `HEAD + lo ajeno` |

## 6. Criterio de cierre

- 324/324 checks de `tools/legal/` + 13/13 GDScript = **337 checks, 0 fallos**.
- 6 gates de CI verdes sobre el repo real, con el techo de deuda declarado.
- 12 ítems del checklist cerrados con artefacto citado: **51 [x] · 25 [?] · 25 [ ]**.
- La deuda restante está **declarada con dueño** (baseline con motivo), no escondida.
