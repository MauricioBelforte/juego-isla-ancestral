# Log 2454: El gate en verde, medido hoy y no heredado

**Fecha:** 2026-11-25
**Hora:** 11:26
**Modelo:** Deepseek V4.1 Flash-DeepAI
**Plataforma:** DeepAI

## Qué se midió

Los 4 jobs de CI llevaban desde esta mañana en verde. La pregunta de esta tanda fue si siguen
en verde **con la flota escribiendo en paralelo**, y con qué evidencia.

## Resultado

```
CI local (suites del workflow) ... 104 suites | 0 rojas
lint_check --no-syntax ........... 2287 archivos | 0 errores | 2186 warnings
validar_workflows --selftest ..... 6/6 fixtures
validar_workflows ................ OK (needs coherentes, --script versionados)
test_scripts ..................... OK
auditar_arquitectura --selftest .. 0 fallos
auditar_cobertura_suites --check . OK (todas las rutas del workflow existen)
verificar_checklist .............. exit 1 (advisory por diseño)
```

Las suites se extrajeron del propio `quality.yml` (104 hoy; eran 101 al mediodía: otros agentes
registraron 3 más) y se corrieron con `& godot --headless --script` + `$LASTEXITCODE`.

## El exit 1 que no es un rojo

`verificar_checklist.py` devuelve 1 por inconsistencias del tablero (módulos `✅` con `[?]` o
`[ ]`). Verificado en el YAML: el step (`.github/workflows/quality.yml:1137-1151`) solo falla
con **exit 3** (detector ciego: no pudo leer `CHECKLIST-GLOBAL.md`); con exit 1 emite warning y
sale 0 a propósito, para no bloquear a la flota por el contenido de un tablero compartido.
Un agente que vea ese 1 y lo reporte como "CI rojo" está mirando mal.

## Cross-QA §21.8

- **M20 (glm-5.3-flash):** `test_m20_amistad_cobertura` 29/0; `test_m20_amistad_suites` 8/0.
  El wrapper reporta **8 checks propios** (los 79 de su informe son la suma de las 3 suites
  internas). Coincide con lo reportado: verificado.
- **M17 (minimax-m3-1-flash):** ya cerrado en Log 2451 (24/0 + 22/0 con la API implementada).

## Hallazgo para el director (no lo toqué)

El verificador marca **10 inconsistencias** entre el estado del tablero y los checklists de los
módulos: M38 (1 `[?]`, ✅), M53 (2 `[?]` + 2 `[ ]`, ✅), M64 (10 `[?]`, ✅ sello 14°), M72, M73
(56 `[?]`, ✅), M75 (87 `[?]`, ✅), y 3 filas con progreso desfasado (M49 110/143 vs 118/143,
M94 89/138 vs 132/138).

En M38 el `[?]` es honesto: RF13 pide persistir el stock de tiendas y depende de M39. Bajar un
`✅` sellado a `🟡` es decisión del director: no des-sello módulos ajenos.

## Limpieza

Los dos scripts temporales de medición (`tools/_tmp_ci_suites.ps1`, `tools/_tmp_gates.ps1`) se
borraron; no quedan artefactos en el repo.