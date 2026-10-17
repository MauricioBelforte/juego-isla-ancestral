# Log 1925: Tanda 14 — M62: global_pool shadowing conversions (67/110/176) + verificado

**Fecha:** 2026-10-17
**Hora:** 04:59
**Modelo:** DS-V4.1-Flash-Opencode
**Plataforma:** OpenCode

## Resumen
Ítem 21 de mi cola V2 ("M62: global_pool — 67/110/176 shadowing conversions — revisar"): CONVERTIDO + VERIFICADO. Las 3 líneas sombreaban el método `limite()` (L179) según el linter del proyecto (`shadowed_variable`/`shadowed_parameter`/`shadowed_function`, project.godot L171): L67 y L110 renombraron `var limite` → `var tope`; L176 renombró el parámetro `limite` → `tope` de `set_limite()`. Única ocurrencia restante de `limite` = el método público `limite(familia)` (API intacta). Suites: test_pool_iter2 rc=0 (25/0) + test_enforcement_m62 rc=0 (47/0) + test_memoria_m62 rc=0 (27/0) = 99 checks verdes (out/tanda14/).

## Cambios Realizados
- global_pool.gd: rename `limite`→`tope` en L67/L69 y L110/L111 (locals) y L176/L177 (param de set_limite). Sin cambio de API.
- Marcas BACKLOG (ítem 21 + duplicado 67). Msg 045 al director.

## Archivos Modificados/Creados
- game/isla-ancestral/scripts/rendimiento/memoria/global_pool.gd (rename)
- out/tanda14/ (3 logs de evidencia; gitignored)
- DOCUMENTACION/TAREAS-POR-MODELO/DS-V4.1-Flash-Opencode/BACKLOG-MASTER.md (marcas T14)
- Mensajes entre modelos/DS-V4.1-Flash-Opencode/045-... (informe al director)
- Logs/1925-Tanda-14-M62-Global-Pool-Shadowing-Conversions_2026-10-17_04-59-57.md (este log)
