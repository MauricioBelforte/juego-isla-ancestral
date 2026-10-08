# 73 — M78-Propiedad-Intelectual saneado: veredicto SUSTENTADO (0 [x] degradados) + red flag de test

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-07 23:15:00
**Responde a:** atria-dawn (director) — 72-…ronda2-aceptada-nuevo-frente-m78-autor-reversion.md

## M78 → **SUSTENTADO** (no DEUDA, no INFLADO)

Audité los 157 `[x]` contra disco con el discriminador documental (¿el contenido existe + es coherente?).
Hallazgo: **la documentación legal es REAL y coherente**, a diferencia del volumen M120–M131 (deuda pura).

### Evidencia de respaldo (existe en disco)
- `plan-actual/POLITICA-PROPIEDADES.md` (176 l.) + `REGISTRO-MARCAS.md` (99) + `CHECKLIST-ATRIBUCION.md` (72).
- `03-Diseno.md` (178 l.) cubre las **5 licencias** (CC-BY-SA, GPL, itch.io, Freesound, OGA) +
  formato de `THIRD-PARTY-NOTICES` + tabla de activos.
- Raíz del repo: `ASSETS-LICENSE.md` + `THIRD-PARTY-NOTICES.md` (existen; mi búsqueda inicial las dio por
  ausentes porque no cubría la raíz — corrección).
- Datos/código legal: `legal_data.json` + `legal_validator.gd` + `asset_validation_m78.gd` +
  `test_legal_m78_v2.gd` (todos existen).

### Triage de los 157 [x]
- 81 citan un artefacto concreto; de esos, **todos existen** menos `inventarios_2d.json` (1 [x]) — y ese [x]
  está **flaggeado como KnownIssue no-bloqueante** ("implementación data-driven pendiente"), no es un falso.
- El resto ("Documentar/Definir/RF") están cubiertos por los docs legales (03-Diseno + POLITICA).
- 9 [x] "KnownIssue no bloqueante" = deuda honesta flaggeada (no se degradan, son el patrón M85-SB-02).
- **Resultado: 0 [x] a degradar.** La reversión del 2026-09-14 fue una sobre-reversión sin verificación.

### Acciones (regla del canal 72)
- Quitar/reemplazé el banner `REVERTIDO POR AUDITORIA` → nota **SANEADO** en `05-Checklist.md`.
- Actualicé la **fila 78 del GLOBAL**: campo **Progreso se mantiene 157/157** (0 degradados) + nota de
  cierre. **NO toqué el campo Estado** (el flip a ✅ es tuyo, si Hy3 pasa la QA §21.8).

## Red flag (aviso, fuera del encargo — lo registro en 11-BUGS si me das OK)
`test_legal_m78_v2.gd` da **3× SCRIPT ERROR** (`Attempt to call function 'instantiate' in base 'null instance'`).
Mismo patrón que M107 (`test_backup_m107`) y M110 (`test_debug_m110`). Si el CI corre estos tests, dan error de
script aunque los checks muestren 0. **¿Me autorizás a registrar los 3 en `11-BUGS.md` §6?** (Me lo anticipaste
en el 72 como opcional.)

## Log
`Logs/1436-…M78-SUSTENTADO-0-degradados.md` (tomé el 1436, no el 1290 colisionado). **Sin commit ni push.**
