# Log 1274: CI job Legal Tooling (M127) — falso positivo por shallow clone

**Fecha:** 2026-10-04
**Hora:** 08:35
**Modelo:** atria-dawn-s2 (analista)
**Plataforma:** Kilo Code

## Resumen

El job `Legal Tooling Tests (M127)` de `quality.yml` fallaba en CI por un **falso positivo**:
el checkout de GitHub Actions es un shallow clone por defecto (`fetch-depth: 1`), y la suite
`test_dump_authorship_evidence.py` genera un volcado de commits sobre un **rango de fechas
cerrado** (`2026-09-01..2026-09-18`) que en un shallow clone está vacío. Fix: `fetch-depth: 0`
en el checkout del job.

## Cambios Realizados

### Diagnostico

- Run `37187254128`, job `111391721535`. Las 11 suites legales: 7 dan OK
  (`generate_copyright` 13/13, `generate_authors` 10/10, `generate_register` 18/18,
  `signoff_check` 12/12, `insert_copyright_headers` 32/32, `timestamp_seal` 30/30,
  `scan_orphan_code` 19/19). La 8va, `test_dump_authorship_evidence.py`, daba
  **35 checks, 1 fallo**:
  `[FALLO] volca al menos 1 commit del rango: 0`.
- **Reproduccion local:** la suite pasa **35/0** en el repo local (historial completo).
- **Causa raiz:** `test_generar()` llama `D.generar(None, "2026-09-01", "2026-09-18", out)` y
  comprueba `r["commits"] > 0`. El checkout del job usaba `actions/checkout@v4` **sin
  `fetch-depth`** → shallow (depth 1) → el rango histórico no existe → 0 commits. Los 11
  checkouts del workflow estaban sin `fetch-depth`; solo este job lo necesitaba.

### Fix (workflow, no codigo de juego)

`.github/workflows/quality.yml`, job `Legal Tooling Tests (M127)`: añadido

```yaml
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
```

con comentario documentando el falso positivo (regla 6 del encargo CI del director).

### Incidente menor: BOM en el pool de logs

Al reservar este número del pool, mi script de PowerShell reescribió `Logs/NUMEROS_DISPONIBLES.txt`
**con BOM y una línea fantasma** (el archivo usa LF y mi split asumía CRLF). Reconstruido
manualmente: 226 números (cabeza 1275, cola 1500), LF consistente, **sin BOM**. Verificado con
`python scripts/verificar_bom.py` → exit 0.

Este mismo BOM fue, de paso, la causa del job `UTF-8 sin BOM (AGENTS §28)` que fallaba en CI
(commit `e564605`, ya arreglado): mi reserva anterior del Log 1271 escribió con el UTF8 de .NET
(que incluye BOM por defecto).

**Leccion para el resto de la flota:** al escribir `Logs/NUMEROS_DISPONIBLES.txt` o cualquier
`.txt` del repo, usar `UTF8Encoding($false)` (sin BOM) y respetar el EOL existente (LF en ese
archivo). `[System.IO.File]::WriteAllText` con `[System.Text.Encoding]::UTF8` **pone BOM**.

## Verificacion

- `python scripts/validar_workflows.py` → EXIT 0, quality.yml ✅.
- `python scripts/verificar_bom.py` → exit 0 (sin BOM en todo el repo).
- YAML válido, 12 jobs.
- EOL de `quality.yml` preservado.

## Archivos Modificados/Creados

- `.github/workflows/quality.yml` — `fetch-depth: 0` en el checkout del job M127.
- `Logs/NUMEROS_DISPONIBLES.txt` — reconstruido sin BOM, número 1274 reservado.
- `Logs/1274-*` — este log.

## Estado de los 5 jobs rojos (encargo canal 10)

| Job | Estado | Nota |
|---|---|---|
| UTF-8 sin BOM (AGENTS §28) | ✅ arreglado | BOM en NUMEROS_DISPONIBLES.txt (mío); commit `e564605` |
| Legal Tooling Tests (M127) | ✅ arreglado | falso positivo shallow clone; este log |
| GDScript Linter | ⚠️ no tocar | esperado: el gate BUG-091 es duro por diseño (director) |
| Architecture Guard (M62) | ⏳ pendiente | siguiente |
| Run Test Suite (M112) | ⏳ pendiente | luego |

## Huella de push (AGENTS.md §4.3)

Se completa tras el push.
