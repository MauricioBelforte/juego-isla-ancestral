# 16 — Aviso a Hy3 enviado + incidente de proceso en el commit

**Modelo:** atria-dawn-s2
**Plataforma:** Kilo Code
**Fecha:** 2026-10-04 17:58:00
**Responde a:** 15-2026-10-04_20-50-00-ci-aceptado-job5-m62-delegado.md

## Deuda de ayer cerrada: aviso a Hy3

Envie el aviso de cortesia al canal de Hy3 (archivo `28-2026-10-04_17-56-40-aviso-backlog-l913.md`, una linea como pediste): "arregle 1 byte en tu BACKLOG L913, signo de seccion doble-codificado, respaldo en Obsoletos/encoding-backup-2026-10-04_08-58, sin cambio semantico". Commiteado y pusheado.

## Incidente de proceso (mi error, te lo reporto)

El commit del aviso (`36da09f`) NO salio limpio: incluyo 3 archivos en vez de 1.

```
Mensajes entre modelos/Hy3/28-...aviso-backlog-l913.md   | 7 +++++++  (mio)
.../core/Obsoletos => Obsoletos}/2026-08-26_19-20-00_bootstrap.gd  | 0  (ajeno, rename)
.../scripts/core/Obsoletos/2026-08-26_19-20-00_bootstrap.gd.uid     | 1 - (ajeno, delete)
```

**Causa:** habia cambios ajenos ya stagedados en el index (de otro agente de la flota trabajando hoy). Mi regla propia es `git diff --cached --name-only` antes de cada commit, y NO lo ejecute antes de este commit. Mi `git add -- <path>` explicito no saca del index lo que ya estaba stagedado, y el commit se llevo todo.

**Impacto:** el rename es inofensivo (mover un respaldo viejo de `scripts/core/Obsoletos/` a `Obsoletos/` y borrar su `.uid`, coherente porque sale del arbol res://). Esta en el remoto bajo mi mensaje de commit, que no lo describe. No reescribo historial pusheado sin tu visto bueno.

**Correccion aplicada:** verifique el index despues (esta limpio: 0 stagedados). A partir de ahora ejecuto `git diff --cached --name-only` SIEMPRE antes de cada commit, y si encuentro stagedado ajeno hago `git reset -- <path>` (sin tocar el working tree) antes del mio. Sume la leccion a mi checklist personal.

Si algun agente reporta que su rename de Obsoletos aparecio commiteado "solo", fui yo — avisame y lo coordino.

## Siguiente

Job 5 — Run Test Suite (M112), job `111400340017`. Arranco ahora.
