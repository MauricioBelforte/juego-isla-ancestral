**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

# 06-Plan-Testings.md — Módulo 127: Copyright del Juego

> **Creado en la iter. 3 (2026-09-18, Log 986).** El `04-Codigo.md` de la iteración
> de diseño declaraba "06-Plan-Testings.md: NO EXISTE en plan-actual/". La
> cobertura real existía pero no estaba declarada en ningún plan: vivía (y vive)
> en `scripts/legal/test_copyright_m127.gd` y en las suites de `tools/legal/`.
> Este archivo reemplaza aquella afirmación.

## 1. Alcance

El módulo es **legal + tooling**, no gameplay. Por eso lo testeable headless y
determinista es:

- **La capa de datos** (`copyright.json`): estructura, campos obligatorios, ids
  únicos, políticas declaradas.
- **La capa de herramientas** (`tools/legal/*.py`): cada generador y cada
  validador legal. Todas usan **solo la stdlib**, así que corren en CI sin
  `pip install` (salvo `pyyaml`, que solo hace falta para validar el YAML del
  workflow a mano, no para las suites).
- **La capa de evidencia**: que el sellado SHA-256 y el volcado de autoría
  **detecten la manipulación**, no solo que se generen.

Lo que **NO** es testeable aquí y no se pretende:

- El registro formal ante la USCO (acto administrativo humano, con pago).
- La validez legal de una prueba pericial (la dicta un juez, no un script).
- La aprobación estética de las muestras visuales del paquete de registro.

## 2. Herramientas y suites

Ejecución (desde la raíz del repo):

```bash
python tools/legal/test_<herramienta>.py     # exit 0 = verde
```

| # | Suite | Herramienta que prueba | Checks | Iter. |
|---|---|---|---|---|
| 1 | `test_generate_copyright.py` | `generate_copyright_docs.py` (NOTICE.md + LICENSE) | 13 | 2 |
| 2 | `test_generate_authors.py` | `generate_authors.py` (AUTHORS.md + CONTRIBUTING.md) | 10 | 2 |
| 3 | `test_generate_register.py` | `generate_copyright_register.py` (registro) | 18 | 2 |
| 4 | `test_signoff_check.py` | `signoff_check.py` (validador pre-release) | 12 | 2 |
| 5 | `test_insert_copyright_headers.py` | `insert_copyright_headers.py` | 32 | 3 |
| 6 | `test_timestamp_seal.py` | `timestamp_seal.py` | 30 | 3 |
| 7 | `test_scan_orphan_code.py` | `scan_orphan_code.py` | 19 | 3 |
| 8 | `test_validate_asset_metadata.py` | `validate_asset_metadata.py` | 71 | 3 |
| 9 | `test_audit_dependencies.py` | `audit_dependencies.py` | 40 | 3 |
| 10 | `test_dump_authorship_evidence.py` | `dump_authorship_evidence.py` | 35 | 3 |
| 11 | `test_registros_db.py` | `registros_db.py` | 44 | 3 |

Además, la suite GDScript del runtime:

```bash
"$GODOT" --headless --path game/isla-ancestral \
  --script res://scripts/legal/test_copyright_m127.gd 2>&1 \
  | grep -E "^=== |\[OK\]|\[FALLO\]|Resumen|SCRIPT ERROR|Parse Error"
```

| Suite GDScript | Prueba | Checks |
|---|---|---|
| `test_copyright_m127.gd` | `copyright_validator.gd` contra el JSON real | 13 |

## 3. Qué se verifica (por clase de regla)

### 3.1 Contrato de datos y documentos

- `copyright.json` cumple el contrato mínimo (`id`, `elemento`, `titular`, `year`).
- Los documentos generados son **deterministas** (sin fecha de generación) → se
  pueden comparar byte a byte en CI (`--check`).
- `legal/copyright_register.md` está en sync con `copyright.json`.

### 3.2 Preservación de bytes (regla §28 del proyecto)

- Ninguna herramienta escribe BOM.
- `insert_copyright_headers.py` y `registros_db.py` **preservan el fin de línea
  por archivo** (en `scripts/legal/` conviven `.gd` LF y un `.gd` CRLF).
- `insert_copyright_headers.py` es **idempotente**: una segunda corrida no cambia
  ni un byte, y no pisa la línea `# -*- coding:` de un `.py`.

### 3.3 Detección, no solo generación

Es la parte que de verdad importa en un módulo legal: un validador que nunca
falla no prueba nada.

- `timestamp_seal.py --verificar` debe **fallar** si un archivo del alcance cambió
  (probado por inyección: se altera un archivo y el sello se pone rojo).
- `dump_authorship_evidence.py --verificar` debe **fallar** si se edita un byte
  del volcado (probado por inyección).
- `validate_asset_metadata.py` debe distinguir un `.ttf` real de un `.ttf` que en
  realidad es HTML (BUG-042), y no confundir un `RIFF/WAVE` con un `.webp`.
- `audit_dependencies.py` debe detectar un addon presente en disco y **no**
  declarado, y un manifiesto de dependencias no declarado.
- `scan_orphan_code.py` debe detectar archivo sin historial, sin cabecera y con
  autor placeholder.

### 3.4 Guardas anti-falso-verde (obligatorias en este proyecto)

Toda suite nueva implementa las **tres capas** del skill:

1. `_fin("bloque")` por bloque + `_resumen()` que **nombra** los bloques que no
   corrieron (un `SCRIPT ERROR` aborta una función en silencio).
2. Piso `CHECKS_MINIMOS` (el real medido en verde, no el teórico).
3. **La guarda probada por inyección** (`test_inyeccion`): se baja el contador a
   un valor bajo y se comprueba que el resumen **falla** y nombra los bloques
   faltantes. Una guarda nunca probada es una guarda que puede estar muerta.

## 4. Criterio de verde

- Cada suite: `exit 0` y `0 fallo(s)` en su línea `=== Resumen ===`.
- La suite GDScript: `13 checks, 0 fallos`, `exit 0`, **0 `SCRIPT ERROR`**.
- Los gates de CI (`--check`) deben salir 0 **con el techo de deuda declarado**.
  La deuda conocida está en `asset_metadata_scope.json` y
  `audit_dependencies_scope.json`, con motivo y dueño por entrada.
