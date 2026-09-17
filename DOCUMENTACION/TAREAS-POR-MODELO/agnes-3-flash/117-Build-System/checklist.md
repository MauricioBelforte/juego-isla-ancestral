**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Módulo:** 117-Build-System (iteración 3 agnes, Log 946)
**Fecha:** 2026-09-17

# Checklist personal — M117 Build-System (iter. 3 agnes, acotada)

> Encaje A: tooling/CI + data-driven + auditoría headless (V0). **Alcance deliberadamente limitado** a
> sync del instalador + gate CI. Los 18 `[?]` externos (M118/M96/M116-infra/M113/build-real) NO son míos.

## Iteración agnes (Log 946)
- [x] Relevo §21.4.7 de la iter. 2 (muse-spark, Log 941) → M117 en curso por agnes-3-flash
- [x] Diagnóstico: root-cause del V3 M116 rojo (`bump_version.py` no toca `installer/*.iss`)
- [x] `bump_version.py`: `_set_version_in_installer_iss()` + `INSTALLER_DIR` (cwd-first) + loop principal
- [x] `installer/IslaAncestral.iss`: AppVersion `0.0.2` → `0.0.6` (fix inmediato del desync)
- [x] `test_bump_version.py`: +3 casos (real sincroniza `.iss`; conserva comentario; DRY no toca) → 14/14
- [x] `quality.yml`: gate duro corre `test_build_m117.gd` + `test_instalador_m116.gd` (cierre del `[?]`
  "test_build_m117.gd no corre aislado")
- [x] Verificación: `test_bump_version.py` 14/14 + `run_tests.py --module build` 2 OK + sintaxis/YAML OK

## Hallazgos
- **Falso-verde M116:** su check V3 estaba rojo (desync `.iss` vs `project.godot`) pero el módulo quedaba
  `✅`. El fix sistemático (sync en el bump) lo vuelve verde genuino + el gate duro lo protege de futuro.
- **Limitación de Godot:** `--script` siempre bootea los autoloads del proyecto (M111 también; 58 leaks
  de ObjectDB preexistentes ajenos). "Aislación real" imposible → el cierre correcto es gate duro + runner.

## Pendiente (fuera de mi alcance acotado — para el dueño M117 / otros)
- [ ] 18 `[?]` externos: M118 (smoke/nightly/permisos/keystore), M96+infra (presets/firmado macOS/Linux),
  M116-infra (signtool real), M113 (gates de stress), build real (T-029/T-030 medición)
- [ ] QA cruzado §21.8 del Log 946 (verificador ≠ agnes-3-flash)

## Reglas de uso
- No afirmar "M117 completo": mi iteración es acotada; el estado global sigue 🟡.
- Cualquier futuro bump de versión debe ir por `python tools/ci/bump_version.py` (el gate duro ahora
  bloquea el release si el `.iss` se desalinea de `project.godot`).
