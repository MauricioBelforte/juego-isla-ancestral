# Log 1541: M118 reformulado y re-muestreado 8/8 — propuesta de sello §21.8

**Fecha:** 2026-10-09
**Hora:** 21:07
**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code

## Resumen
Tras la QA §21.8 de M118 (Log 1539, sello denegado por 2 imprecisiones
documentales), se reformularon los 2 items defectuosos, se anotaron las 4
marcas CASO A como KnownIssue legitimo, y el muestreo anti-inflacion §21.8.2.b
pasa ahora **8/8**. Se propone el sello §21.8 para M118 (autorizado por el
director, msg 179).

## Cambios Realizados

### `DOCUMENTACION/118-CI-CD/plan-actual/05-Checklist.md` (solo TEXTO, marcas intactas)

1. **L36 reformulado** — de "Scripts PowerShell build_dev.ps1 y
   build_release.ps1" a "Scripts de build `tools/ci/build_dev.py` y
   `tools/ci/build_release.py`", con nota que explica que la forma PowerShell
   era herencia Unity/C# (patron ya reconocido en L34: `BuildScript.cs` →
   `build_info.gd`).
2. **L87 reformulado** — de "GLBs no vacios en media/" a
   "`res://assets/3d/media/`", con nota: `media/` no existe; la ruta real del
   gate es `res://assets/3d/media/` con **130 GLBs** hoy (el Log 684 decia 99);
   `gate_assets_existen()` en `scripts/ci/cicd_manager.gd:113`.
3. **4 marcas `[ ]` anotadas** como CASO A KnownIssue legitimo (P5 L28, Subida
   a Itch.io L100, Email a stakeholders L109, Validacion GitHub Actions L191),
   con la razon especifica de infra externa (BUTLER_API_KEY, email service,
   push real). **No se fliparon a `[?]`** (orden del director: son infra
   externa real pendiente, no dudas).

**Conteo tras las ediciones: 102 [x] / 4 [ ] / 0 [?]** = 106 — sin cambios en
las marcas, solo texto (READ-ONLY sobre marcas, verificado con conteo regex).

## Verificacion

### Muestreo §21.8.2.b re-corrido — 8/8

| Item | Artefacto citado (reformulado) | Disco | |
|---|---|---|---|
| L84 | autoload CiCdManager | `project.godot` | OK |
| L85 | ci_gates.json 3 gates | pr/nightly/release | OK |
| L36 | `tools/ci/build_dev.py` | existe | OK |
| L36 | `tools/ci/build_release.py` | existe | OK |
| L87 | `res://assets/3d/media/` | existe, **130 GLBs** | OK |
| L41 | `validar_tag_semver()` | cicd_manager.gd | OK |
| L72 | `gate_calidad_codigo()` | cicd_manager.gd | OK |
| L74 | `registrar_fallo/exito_pipeline()` | cicd_manager.gd | OK |
| L94 | `_sha256_archivo()` | cicd_manager.gd | OK |
| L114 | `limpiar_artefactos()` | cicd_manager.gd | OK |
| L87 | `gate_assets_existen()` | cicd_manager.gd:113 | OK |

Funciones citadas del modulo: **9/9 existen** en `scripts/ci/cicd_manager.gd`.

### Validacion YAML (pedido del director, msg 179 §5)
Los 6 workflows de `.github/workflows/` validados con `yaml.safe_load`:
**6 OK / 0 fallas**. (`quality.yml` L239 ya arreglado por el director.)

## Propuesta de sello §21.8 para M118

Cumple los criterios verificables:
- Conteo sano: 102/4/0 = 106, coincide con GLOBAL.
- Muestreo anti-inflacion §21.8.2.b: **8/8** (antes 6/8 por 2 imprecisiones
  documentales ya corregidas).
- Arquitectura real en disco: `cicd_manager.gd` (9 funciones citadas), 3 gates
  en `ci_gates.json`, 2 suites (`test_gates_m118.gd`, `test_cicd_m118.gd`).
- Las 4 `[ ]` son KnownIssue de infra externa documentados (no `[?]`), no
  bloqueantes por diseno (modulo delegable).
- Sello previo Log 857: invalido (agnes-2.5-flash, no Hy3) — M118 nunca tuvo
  sello real; este seria el primero.

**Veredicto propuesto:** M118 apto para sello §21.8. El director lo registra
en GLOBAL (yo no aplico flips).

## Archivos Modificados/Creados
- `DOCUMENTACION/118-CI-CD/plan-actual/05-Checklist.md` — L36, L87 y 4 notas
  CASO A (solo texto)
- `Logs/1541-...md` — este log
- `Mensajes entre modelos/atria-dawn-s2/180-...md` — informe + propuesta
- `Logs/NUMEROS_DISPONIBLES.txt` — 1541 consumido
- `Mensajes entre modelos/atria-dawn-s2/NUMEROS_DISPONIBLES.txt` — 180 consumido
