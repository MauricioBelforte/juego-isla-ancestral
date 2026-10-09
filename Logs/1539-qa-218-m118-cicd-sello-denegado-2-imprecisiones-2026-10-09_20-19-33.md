# Log 1539: QA §21.8 M118-CI-CD — 102/4/0 confirmado, sello DENEGADO (2 imprecisiones)

**Fecha:** 2026-10-09
**Hora:** 20:19
**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code

## Resumen
QA §21.8 de M118-CI-CD (encargo del director, msg 176). Conteo confirmado,
muestreo anti-inflacion ejecutado, veredicto: **NO sellable** — 2 de 8 items
muestreados citan artefactos imprecisos. Las 4 marcas CASO A revertidas por
Hy3 estan confirmadas como artefactos inexistentes.

## Cambios Realizados
Ninguno — QA READ-ONLY (no se tocaron checklists ni GLOBAL; flips a cargo del
director).

## Hallazgos

### 1. Conteo verificado
Real: **102 [x] / 4 [ ] / 0 [?]** = 106 items. Coincide con GLOBAL (102/106,
nota "102/0/4").

### 2. Las 4 [ ] — CASO A confirmadas (Hy3 Log 1125)
Las 4 citas `03-Diseno.md §` son **fantasma**: el archivo solo tiene §1-§4
(Arquitectura / Flujo de operacion / Workflow GitHub Actions / QA), verificado.
`.github/workflows/` tiene exactamente 6 workflows (backup, bug_metrics,
dev-build, quality, release-build, testing): **ninguno** referencia itch.io /
butler / stakeholders / firebelley. La reversión ✅→🟡 de Hy3 es correcta.
- P5 (L28) despliegue itch.io al crear tag — cita §2.5 fantasma
- L100 Subida a Itch.io (manual trigger) — cita §3.10 fantasma
- L109 Email a stakeholders en tags — cita §3.9 fantasma
- L191 Validación en GitHub Actions real — cita §4.1 fantasma (requiere push)

### 3. Muestreo anti-inflación §21.8.2.b — 8 items con verbos de creacion

| Item | Artefacto citado | Disco | Veredicto |
|---|---|---|---|
| L84 | autoload CiCdManager en project.godot | `CiCdManager="*res://scripts/ci/cicd_manager.gd"` | OK |
| L85 | ci_gates.json con 3 gates | pr/nightly/release exactos | OK |
| L41 | `validar_tag_semver()` | existe en cicd_manager.gd | OK |
| L72 | `gate_calidad_codigo()` | existe | OK |
| L74 | `registrar_fallo/exito_pipeline()` | existen | OK |
| L94 | `_sha256_archivo()` | existe | OK |
| **L36** | `build_dev.ps1` / `build_release.ps1` | **no existen** (hay `.py` en `tools/ci/`) | FALLA |
| **L87** | GLBs no vacios en `media/` | `media/` **no existe**; el gate usa `assets/3d/media/` (130 GLBs) | FALLA |

**6/8 exactos, 2 fallas.** Por la regla estricta §21.8.2.b (2+ fallas -> sello
denegado), el muestreo no pasa limpio.

**Matiz importante (honestidad):** las 2 fallas son **imprecision documental,
no inflacion**. El artefacto funcional existe en otra forma:
- `tools/ci/build_dev.py` y `tools/ci/build_release.py` existen (Python, no
  PowerShell). El modulo ya reconoce este patron de herencia Unity->Godot en
  L34 (`BuildScript.cs` -> `build_info.gd`).
- `gate_assets_existen()` SI existe (L113 de cicd_manager.gd) y escanea
  `res://assets/3d/media/` — ruta real con **130 GLBs**. El checklist acorta
  la ruta como "media/" y el Log 684 decia "99 GLBs" (hoy son 130).

No es "planificado como hecho" (el argumento que la regla reprueba): el
sistema esta implementado y funciona. Es el ITEM el que cita mal el artefacto.

### 4. Sello Log 857 — invalido, confirmado
El GLOBAL ya lo anota: "Sello Log 857 invalido (no verificado por Hy3; Log 857
= agnes-2.5-flash)". M118 **nunca tuvo sello §21.8** (no figura en
CHECKLIST-QA-SEALS.md, verificado por Hy3 Log 1125).

### 5. Tests citados
`test_gates_m118.gd` y `test_cicd_m118.gd` existen en disco (con sus `.out`).

## Veredicto
**M118 NO esta a DoD para sello §21.8.** Se necesita:

1. **Reformular L36 y L87** para que citen los artefactos reales
   (`tools/ci/build_dev.py`+`build_release.py`; `gate_assets_existen()` sobre
   `assets/3d/media/`). Con eso el muestreo pasa 8/8.
2. **Decision sobre las 4 [ ]**: son KnownIssue de infraestructura externa
   (BUTLER_API_KEY, email service, push real). O se delegan formalmente o se
   documentan como deuda aceptada.
3. **Re-QA** despues de (1).

Mientras tanto: conteo sano, arquitectura real implementada (cicd_manager.gd
con 9 funciones citadas + 3 gates en ci_gates.json + 2 suites), y las 4
deudas CASO A honestamente marcadas. El modulo esta **mas cerca de lo que el
GLOBAL sugiere**: la unica barrera para el sello son 2 lineas de checklist
mal redactadas y la decision sobre la deuda externa.

## Archivos Modificados/Creados
- `Logs/1539-...md` — este log
- `Mensajes entre modelos/atria-dawn-s2/177-...md` — informe al director
- `Logs/NUMEROS_DISPONIBLES.txt` — 1539 consumido
- `Mensajes entre modelos/atria-dawn-s2/NUMEROS_DISPONIBLES.txt` — 177 consumido
