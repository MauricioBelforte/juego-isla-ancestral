**Modelo:** step-3.7-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02
**Última actualización:** 2026-09-02 — avance M119 cerrado 100/100 Log 549; M108 núcleo V0 creado; headless bloqueado Log 532

# BACKLOG MASTER — step-3.7-flash

> Metodologia TAREAS-POR-MODELO (ver GUIA-METODOLOGIA.md). Total de tareas pendientes: **178** en 3 módulos.

## Regla permanente de auditoría de logs (obligatoria en TODO ciclo)
1. Antes de cerrar cualquier log, listar `Logs/*.md` y extraer números prefijo.
2. Verificar que no existan duplicados para el número elegido (ni en `Logs/` ni en `Logs/reservas/`).
3. Verificar que `ULTIMO_NUMERO.txt` sea consistente con el máximo número existente.
4. Verificar que todas las referencias a logs en documentos clave (`CHECKLIST-GLOBAL.md`, `ESTADO-PARALELO.md`, `08-GUIA-ORDEN-DE-IMPLEMENTACION.md`, `plan-actual/05-Checklist.md`, checklist personal) apunten a archivos existentes.
5. Si se detecta inconsistencia, corregirla o anotarla como `[?]` antes de continuar.

## Módulos (pendientes)

| ID | Módulo | Tareas pendientes | Nota |
|---|---|---|---|
| 117 | 117-Build-System | 104 | Núcleo cerrado Log 515; brecha M11/M18 |
| 122 | 122-Crash-Reporting | 63 | Núcleo cerrado Log 518; brecha M104/M118 |
| 108 | 108-Pipeline-De-Assets | 11 | Núcleo V0 creado 2026-09-02; 12 scripts en `tools/asset_pipeline/`; test headless bloqueado Log 532 |


## Módulos cerrados parcialmente (sin backlog activo)

| ID | Módulo | Estado | Nota |
|---|---|---|---|
| 119 | 119-Actualizaciones | ✅ Completado | Log 549; 100/100 ítems cerrados; pendientes externos delegados |
| 16 | 16-Crafting | 🟡 Con dudas | Log 513; pendientes con dueño cruzado |
| 23 | 23-Historias-Secundarias | 🟡 Con dudas | Log 510; pendientes con dueño cruzado |
