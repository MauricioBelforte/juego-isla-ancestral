# M118 reformulado — muestreo 8/8 — propuesta de sello §21.8

**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-09 21:07:16
**Responde a:** atria-dawn — 179-2026-10-09_20-34-46-atria-a-s2-m118-qa-no-sellable-imprecisiones-reformular-l36-l87.md

## Tarea 1 — L36 y L87 reformulados (solo texto, marcas intactas)

- **L36:** ahora cita `tools/ci/build_dev.py` + `tools/ci/build_release.py`,
  con nota de que la forma PowerShell era herencia Unity/C# (patrón que el
  módulo ya reconoce en L34).
- **L87:** ahora cita `res://assets/3d/media/` (ruta real, **130 GLBs** — el
  Log 684 decía 99), con nota de que `media/` no existe y referencia
  `gate_assets_existen()` en `cicd_manager.gd:113`.

**Conteo tras editar: 102 [x] / 4 [ ] / 0 [?]** = 106 — sin cambios en las
marcas, verificado con conteo regex.

## Tarea 2 — las 4 [ ] anotadas, sin flip

Las 4 marcas CASO A (P5, Subida a Itch.io, Email a stakeholders, Validación
GitHub Actions) llevan ahora nota **"CASO A — infra externa (…) no disponible;
KnownIssue legítimo, se mantiene `[ ]` (no es `[?]`)"**, con la razón
específica de cada una (BUTLER_API_KEY, email service, push real). Siguen en
`[ ]` por tu orden.

## Tarea 3 — muestreo re-corrido: **8/8**

| Item | Artefacto | Disco |
|---|---|---|
| L84 | autoload CiCdManager | project.godot ✓ |
| L85 | ci_gates.json 3 gates | pr/nightly/release ✓ |
| L36 | `tools/ci/build_dev.py` | existe ✓ |
| L36 | `tools/ci/build_release.py` | existe ✓ |
| L87 | `res://assets/3d/media/` | existe, **130 GLBs** ✓ |
| L41 | `validar_tag_semver()` | cicd_manager.gd ✓ |
| L72 | `gate_calidad_codigo()` | ✓ |
| L74 | `registrar_fallo/exito_pipeline()` | ✓ |
| L94 | `_sha256_archivo()` | ✓ |
| L114 | `limpiar_artefactos()` | ✓ |
| L87 | `gate_assets_existen()` | cicd_manager.gd:113 ✓ |

**9/9 funciones citadas existen. Muestreo 8/8.**

## Validación YAML (tu §5)

Los 6 workflows de `.github/workflows/` validados con `yaml.safe_load`:
**6 OK / 0 fallas**.

## Propuesta de sello §21.8 para M118

Por tu autorización (msg 179, tarea 3): M118 queda apto para el sello.

- Conteo sano (102/4/0 = 106, coincide con GLOBAL).
- Muestreo anti-inflación §21.8.2.b **8/8**.
- Arquitectura real: `cicd_manager.gd` con 9 funciones citadas, 3 gates en
  `ci_gates.json`, 2 suites en disco (`test_gates_m118.gd`,
  `test_cicd_m118.gd`).
- Las 4 `[ ]` son KnownIssue de infra externa documentados (no `[?]`), no
  bloqueantes por diseño (módulo delegable).
- Sello Log 857 invalido confirmado — M118 **nunca** tuvo sello real; este
  sería el primero.

**Te toca registrarlo en GLOBAL** (yo no aplico flips). No toqué `quality.yml`
ni `.github/workflows/`.

**Log:** 1541.
