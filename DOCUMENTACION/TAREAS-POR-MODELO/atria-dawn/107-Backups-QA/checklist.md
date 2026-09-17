**Modelo:** atria-dawn (Atria Dawn Preview, Shanghai AI Laboratory)
**Plataforma:** Kilo Code
**Módulo:** 107-Backups (QA cruzado post-agnes)
**Fecha:** 2026-09-16 (tarea en ESPERA)

# Checklist personal tareas — 107-Backups QA (verificador ≠ autor)

> ⚠️ **NO trabajar ahora.** M107 está 🔵 reservado por **agnes-3-flash** (reserva 927, 2026-09-16 05:20).
> Esta es la tarea de **QA cruzado §21.8** que el usuario me encomendó: *"cuando agnes termine con el m107 vos vas a revisar si todo está bien, si algo te genera dudas te encargas de arreglarlo o mejorarlo"*.
> **Condición de arranque:** agnes libera M107 (estado `🟡` o `✅`) en CHECKLIST-GLOBAL.md.

## Disparador

- [x] Q-001 **Esperar liberación de agnes-3-flash** — detectar `🟡`/`✅` + log de agnes en `Logs/9*agnes*M107*` o equivalente
- [x] Q-002 Leer el log de agnes completo + `## Notas del Agente` en `04-Codigo.md` antes de tocar nada

## Verificación (regla §21.8: verificador ≠ autor)

- [x] Q-003 Re-ejecutar `test_backup_m107.gd` headless ×3 → misma cuenta de checks, 0 fallos, 0 SCRIPT ERROR
- [x] Q-004 Verificar que TODOS los `[x]` del 05-Checklist tienen artefacto real (script/doc/config) — no claims vacíos
- [x] Q-005 Verificar que los `[?]` tienen dueño externo nombrado y no son deuda disfrazada
- [x] Q-006 Cruce de consistencia: lo que dice `04-Codigo.md` vs los archivos que existen en `scripts/backup/`, `.github/workflows/`, `docs/`, `game/.../scripts/backup/`
- [x] Q-007 Verificar que el `Totales` del 05-Checklist coincide con el conteo real `[x]`/`[?]`/`[ ]`
- [x] Q-008 Auditar los scripts PowerShell (`backup_local.ps1`, `verify_backups.ps1`, `restore_backup.ps1`, `register_task.ps1`) — parámetros, checksums, retención, manejo de errores, rutas reales (C:/D:/ no E:)
- [x] Q-009 Auditar `backup.yml` — guard de secrets (sin secrets → salta, no rompe), cron, notificación
- [x] Q-010 Auditar `backup_manager.gd` — BUG-035 sigue reparado (`DirAccess.new()` era abstracto), `globalize_path` en uso, `_limpiar_excedentes` aplica retención real

## Acción sobre dudas (directiva del usuario)

- [x] Q-011 Si algo genera dudas → **arreglar o mejorar** (no solo anotar): fix + test + nota
- [x] Q-012 Si agnes dejó gaps verificables y cerrables → implementar con test headless propio y marcar `[x]` con mi firma
- [x] Q-013 Si la duda es de diseño/política (dueño humano) → `[?]` con dueño nombrado, sin inventar

## Cierre

- [x] Q-014 Sello de verificación en CHECKLIST-GLOBAL.md: `✅ Verificado por atria-dawn (Kilo Code) YYYY-MM-DD` — **solo si pasa todo**
- [x] Q-015 Si NO pasa → módulo vuelve a `🟡`, hallazgos en `## Notas del Agente` (sin borrar las de agnes)
- [x] Q-016 Reservar log propio para el QA (protocolo §6.1.a) antes de escribir el log
- [x] Q-017 Log con firma atria-dawn + evidencia (tests, conteos, fixes)
