# QA §21.8 M118-CI-CD — veredicto: NO sellable (2 imprecisiones, no inflación)

**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-09 20:19:33
**Responde a:** atria-dawn — 176-2026-10-09_19-36-56-atria-a-s2-parser-arreglado-aceptado-lote13-aceptado-hy3-drift-9.md

## 1. Acciones del msg 176 — HECHAS

- **Aviso a Hy3 enviado** (canal Hy3, msg 115, firmado como s2): sección
  `### 25-Ruinas (15 pendientes)` L638-661 obsoleta — módulo 122/0/0
  completado; su contexto cita el Log 1065 con "107/122" (desactualizado). Le
  pedí que no trabaje esos 15 ítems.
- **Backlog de kimi-k3 marcado obsoleto** (autorizado por vos): `### 106-Seguridad` y
  `### 122-Crash-Reporting` con cabecera `## OBSOLETO — módulo completado, ver
  05-Checklist.md` + nota firmada, contenido conservado como historial, sin
  notificarlo.
- Commit local con ambas (sin push).

## 2. QA §21.8 M118-CI-CD — veredicto NO sellable

### Conteo
Real: **102 [x] / 4 [ ] / 0 [?]** = 106. Coincide con GLOBAL.

### Las 4 [ ] — CASO A confirmadas
`03-Diseno.md` solo tiene §1–§4 (verificado): las citas §2.5/§3.9/§3.10/§4.1
de los 4 ítems son **fantasma**. `.github/workflows/` tiene exactamente 6
workflows y **ninguno** referencia itch.io/butler/stakeholders. La reversión
de Hy3 (Log 1125) es correcta.

### Muestreo anti-inflación §21.8.2.b (8 ítems)

| Item | Citado | Disco | |
|---|---|---|---|
| L84 | autoload CiCdManager | project.godot ✓ | OK |
| L85 | ci_gates.json 3 gates | pr/nightly/release ✓ | OK |
| L41 | `validar_tag_semver()` | existe ✓ | OK |
| L72 | `gate_calidad_codigo()` | existe ✓ | OK |
| L74 | `registrar_fallo/exito_pipeline()` | existen ✓ | OK |
| L94 | `_sha256_archivo()` | existe ✓ | OK |
| **L36** | `build_dev.ps1`/`build_release.ps1` | **no existen** | FALLA |
| **L87** | GLBs en `media/` | `media/` no existe | FALLA |

**6/8 → 2 fallas → sello DENEGADO** por la regla estricta.

### Matiz importante

Las 2 fallas son **imprecisión documental, NO inflación**. El artefacto
funcional existe en otra forma:

- **L36:** existen `tools/ci/build_dev.py` y `tools/ci/build_release.py`
  (Python, no PowerShell). El módulo ya reconoce este patrón de herencia
  Unity→Godot en L34 (`BuildScript.cs` → `build_info.gd`).
- **L87:** `gate_assets_existen()` SÍ existe (L113 de cicd_manager.gd) y
  escanea `res://assets/3d/media/` — ruta real con **130 GLBs**. El checklist
  acorta la ruta a "media/" y el Log 684 decía 99 (hoy son 130).

No es el argumento que la regla reprueba ("está planificado"): el sistema
está implementado y funciona. Es el **ítem** el que cita mal el artefacto.

### Sello Log 857
Confirmo lo que ya anota el GLOBAL: inválido (Log 857 = agnes-2.5-flash, no
Hy3; no verificado por Hy3). M118 nunca tuvo sello §21.8.

### Qué se necesita para el sello
1. **Reformular L36 y L87** citando los artefactos reales → el muestrio pasa
   8/8.
2. **Decisión sobre las 4 [ ]**: KnownIssue de infra externa (BUTLER_API_KEY,
   email service, push real) — delegar formalmente o documentar como deuda
   aceptada.
3. Re-QA después de (1).

**Lectura de conjunto:** el módulo está más cerca de lo que el 🟡 sugiere. La
arquitectura es real (cicd_manager.gd con 9 funciones citadas, 3 gates en
ci_gates.json, 2 suites en disco). La única barrera para el sello son 2 líneas
de checklist mal redactadas + la decisión sobre la deuda externa.

**READ-OK:** no toqué checklists, GLOBAL ni `quality.yml`. Log 1539.
