# BACKLOG-MASTER.md — step 5 workbuddy

Canal: `Mensajes entre modelos/Step-5-WorkBuddy/`. Numeracion propia (pool de esa
carpeta). Identidad de firma: **step 5 workbuddy**.

## Reservas de log (protocolo v3, AGENTS.md 6.1)

- [x] Log reservado: **1796** — M04-Game-Engine iteracion 1: 10 flips seccion B
      (Costos y licencias) con cita real. Archivo:
      `Logs/1796-M04-iter1-costos-licencias_2026-10-12_23-50-00.md`.
- [x] Log **1797** consumido por error (doble ejecucion de `reservar_log.py
      --reservar`); sin archivo asociado. Deuda declarada en Log 1796 y en el
      informe al director (msg 04). No reasignar.
- [x] Log reservado: **1801** — M04-Game-Engine iteracion 2: 12 flips seccion A
      (Evaluacion de candidatos) con cita real. Archivo:
      `Logs/1801-M04-iter2-evaluacion-candidatos_2026-10-13_02-18-42.md`.
      Pool medido antes: head 1801 -> 1802. ASCII puro verificado por bytes.

## Commits (delegados a atria-dawn; yo no commiteo ni pusheo)

- [x] M04 iter 1: pedido msg 65 a atria-dawn -> commit **e38ad5a**
      (9 archivos, +376/-12) + push a origin/main, 2026-10-13 00:04.
      Verificado por mi: `git show --stat e38ad5a` y
      `git branch -r --contains e38ad5a`. Pool de canal excluido del commit
      (correcto). Acuse enviado (msg 69 en carpeta atria-dawn).
- [ ] M04 iter 2: pedido msg 72 a atria-dawn (2026-10-13 02:23) -> pendiente de
      commit. 6 archivos: 02-Analisis.md, 05-Checklist.md, Log 1801,
      BACKLOG-MASTER, msgs 7/8 (+ msg 72 si lo incluye). Pool de canal
      excluido (sta stale: cabeza 002 zero-padded vs mensajes unpadded).

## Lote WB (encargo del director, msg 01; orden aprobado msg 03)

Orden de trabajo: M04 -> M109 -> M67 -> M75 -> M56 -> M73 -> M20 -> M158;
M90 y M17 diferidos al final (solo si el director los libera; gemelo
StepFun-Step-5-Preview activo hoy).

| Modulo | Carpeta | Estado iteracion |
|---|---|---|
| M04-Game-Engine | DOCUMENTACION/04-Game-Engine/ | iter 1: 14->24 [x] (Log 1796); commiteado e38ad5a + push origin/main (atria-dawn); iter 2: 24->36 [x] seccion A (Log 1801, pend. commit msg 72) |
| M109-Herramientas-Internas | DOCUMENTACION/109-Herramientas-Internas/ | pendiente |
| M67-Vehiculos | DOCUMENTACION/67-Vehiculos/ | pendiente |
| M75-Postgame | DOCUMENTACION/75-Postgame/ | pendiente |
| M56-Fotografia | DOCUMENTACION/56-Fotografia/ | pendiente |
| M73-Coleccionables | DOCUMENTACION/73-Coleccionables/ | pendiente |
| M20-Sistema-De-Amistad | DOCUMENTACION/20-Sistema-De-Amistad/ | pendiente |
| M158-Herramientas-Y-Desbloqueo-De-Zonas | DOCUMENTACION/158-Herramientas-Y-Desbloqueo-De-Zonas/ | pendiente |
| M90-Configuracion-Grafica | DIFERIDO (gemelo activo) | no tocar |
| M17-Construccion | DIFERIDO (gemelo activo) | no tocar |

Prohibidos absolutos (del otro frente): M40, M70, M140, M63, M112, M94, M92, M91,
M104, M88, M160.

## Pendientes de esta iteracion

- [x] Iteracion 2 de M04: seccion A (Evaluacion de candidatos, 12 items) con cita — HECHA (Log 1801; 24->36 [x] / 92 [ ] / 0 [?] = 128).
- [ ] Iteracion 3 de M04: seccion C (Soporte voxel y rendimiento, 14 items) — propuesta al director en msg 8, esperando confirmacion (alternativa: seccion D, 10 items).
- [ ] Acuse del commit de iter 2 cuando atria-dawn confirme (verificar sha + origin/main antes de acusar, como con e38ad5a).
