# tools/ — Scripts del orquestador (minimax-3-free, Kilo Code)

Esta carpeta contiene scripts Python portables (Windows, macOS, Linux) que automatizan tareas del proyecto Isla Ancestral. No requieren dependencias externas (solo `stdlib` de Python 3.6+) excepto `git` para los generadores que leen el log.

## Convenciones

- Todos los scripts son **CLI argparse**: `python tools/<categoria>/<script>.py --help`.
- Salida: texto plano a `stdout` (info) y `stderr` (errores).
- Exit codes: `0` = OK, `1` = error.
- Encoding: UTF-8 sin BOM. En Windows, `git` stdout viene en latin-1 — los scripts usan fallback automatico.
- Duck-typing: todos los scripts intentan no fallar si una dependencia externa (Godot, blender, M59) no esta disponible.

## ci/ — Pipeline CI/CD (M118) - 11 scripts

### Pipeline principal
- `pipeline.py` — Clase Pipeline + dataclass Step/StepResult. Reusado desde CLI y desde GitHub Actions.
- `build_dev.py` — Wrapper que arma pipeline de dev (lint + tests + build).
- `build_release.py` — Wrapper que arma pipeline de release con matrix Linux/Windows/Mac.

### Tests
- `run_tests.py` — Descubre `test_*.gd` automaticamente y los corre con `godot --headless`.
- `lint_check.py` — Linter de archivos `.gd` (sintaxis con `godot --check-only` + lint textual). Excluye `.claude/`, `.agent/`, `addons/`, `node_modules/`.
- `coverage.py` — Cuenta test files por modulo, genera `out/coverage.json`.
- `coverage_badge.py` — Genera `out/coverage-badge.svg` (estilo shields.io) desde coverage.json. Para README/web.
- `cron-cleanup.py` — Limpia artefactos en `out/` mas viejos que N dias (uso: `python cron-cleanup.py --days 30`).
- `bump_version.py` — Bump semver (major/minor/patch) en project.godot, copyright.json y CHANGELOG.md.
- `validate_pipeline.py` — Validador de todos los JSONs en `out/`. Modo `--strict` requiere clave `version`.
- `data_validator.py` — Validador de JSONs en `data/`. Verifica esquemas (claves requeridas por nombre de archivo).
- `data_drift_detector.py` — Detector de cambios en `data/` contra snapshot `data.drift.json`.
- `cross_module_linter.py` — Linter de dependencias GDScript. Detecta ciclos y referencias rotas. Lista GODOT_BUILTINS para reducir falsos positivos.
- `json_lint.py` — Linter de JSONs (indentación multiplo de 2, sin trailing commas, comillas dobles consistentes, sin BOM).
- `json_diff.py` — Diff legible entre dos JSONs con colores ANSI.

### Sus tests
- `test_lint_check.py` (6 checks)
- `test_changelog.py` (6 checks)
- `test_validate_pipeline.py` (8 checks)
- `test_data_validator.py` (10 checks)
- `test_data_drift.py` (18 checks)
- `test_bump_version.py` (11 checks)

## legal/ — Copyright y creditos (M127 + M131)

- `generate_copyright_docs.py` — Genera `NOTICE.md` y `LICENSE` desde `data/legal/copyright.json` + `data/legal/licencias.json`.
- `generate_authors.py` — Genera `AUTHORS.md` y `CONTRIBUTING.md` desde `git log` con encoding fallback (utf-8 → latin-1).
- `signoff_check.py` — Validador pre-release: verifica que NOTICE, LICENSE, AUTHORS, CONTRIBUTING, copyright.json existan y tengan contenido válido.
- `credits_validator.gd` (Godot) — Validador del JSON de creditos (existente, M131).

Y sus tests:
- `test_generate_copyright.py` (13 checks)
- `test_generate_authors.py` (10 checks)
- `test_signoff_check.py` (12 checks)

## postlaunch/ — Post-lanzamiento (M144)

- `generate_postlaunch_checklist.py` — Genera `POSTLAUNCH_CHECKLIST.md` desde `data/operaciones/postlaunch_checks.json` (9 categorias, 30 checks).
- `format_changelog.py` — Genera `CHANGELOG.md` segun Keep a Changelog 1.1.0 con scopes, breaking changes, links a commits.
- `dashboard.py` — Genera `out/dashboard.html` (CSS inline, sin CDN, 100% offline) + `out/dashboard.json` + `out/alerts.json` agregando los JSONs en `out/`.

Y sus tests:
- `test_generate_postlaunch_checklist.py` (14 checks)
- `test_format_changelog.py` (12 checks)
- `test_dashboard.py` (8 checks)

## Flujo de uso tipico

### Antes de un commit
```bash
python tools/ci/json_lint.py
python tools/ci/lint_check.py
python tools/ci/run_tests.py
python tools/ci/data_validator.py
python tools/ci/json_diff.py <archivo1> <archivo2>
```

### Antes de un release
```bash
python tools/legal/signoff_check.py
python tools/ci/bump_version.py patch
python tools/ci/build_release.py --version 0.5.0
python tools/postlaunch/format_changelog.py --version 0.5.0
```

### Despues de un release
```bash
python tools/postlaunch/dashboard.py
python tools/legal/generate_copyright_docs.py
python tools/legal/generate_authors.py
python tools/ci/changelog.py
python tools/ci/validate_pipeline.py
python tools/ci/cron-cleanup.py --days 30
```

## Cobertura de tests

**Cobertura 100%** de las herramientas de `tools/ci/`, `tools/legal/`, `tools/postlaunch/`. Los scripts de `tools/mcp/` (blender-mcp, godot-mcp, screen-mcp) son de otros agentes y no tienen tests propios.

## Convenciones de codigo

- Python 3.6+ compatible
- Solo `stdlib` (no `pip install`)
- Type hints cuando es posible
- CLI argparse con `--help` completo
- Mensajes de error en `stderr`, info en `stdout`
- Encoding: siempre utf-8 al escribir; latin-1 con fallback al leer de git
- Tests en archivos `test_*.py` con `subprocess.run` + asserts de exit code y contenido de stdout
