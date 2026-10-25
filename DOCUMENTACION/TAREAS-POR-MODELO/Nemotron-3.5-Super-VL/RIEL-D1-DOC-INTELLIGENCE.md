# RIEL-D1 — DOCUMENT INTELLIGENCE (nicho N.2; 15 items)

**Armado por:** GLM-5.3-Flash (orden fundador 25oct) | **Fecha:** 2026-10-25
**Nicho:** tablas, gráficos dentro de capturas, OCR, análisis de documentos grandes con 1M contexto. Output: informe en tu canal con citas exactas (linea/L#) — NO editar el documento analizado salvo encargo expreso de la directora.

| # | Tarea | Output |
|---|---|---|
| D1-001 | Auditar la tabla de `CHECKLIST-GLOBAL.md`: drift de conteos por módulo (columna Progreso vs conteo real de [x] en el 05 de cada módulo) | informe con tabla de módulos con drift |
| D1-002 | Auditar la coherencia de la fila de cada uno de los módulos NO completados en CHECKLIST-GLOBAL (estado textual vs emoji declarado) | informe de filas desalineadas |
| D1-003 | Mapear los ítems FLAG FUNDADOR / FLAG TECNICO declarados en los 05 de los módulos (cuáles, en qué módulo, qué esperan) | censo con L# |
| D1-004 | Censo de archivos `.po` (es/pt): msgids por archivo, claves usadas vs huérfanas (solo lectura; PT-runtime sigue esperando GO del fundador) | informe |
| D1-005 | Auditoría visual de la GUIA-GODOT: índice de errores E-11..E-19 vs archivos reales citados | informe de referencias muertas |
| D1-006 | Censo de `Logs/`: log más reciente por riel (log_count por canal), detección de backlogs de logs muertos | informe |
| D1-007 | Tabla comparativa de la flota activa (9+1 agentes): qué módulo tiene cada uno, desde CHECKLIST-GLOBAL + ESTADO-PARALELO | informe de ocupación |
| D1-008 | Detección de documentos dentro de `DOCUMENTACION/` mayores a 5.000 líneas (candidatos a saneamiento como fue la GUIA-COMPARATIVA 64-copias; lección 2190) | informe con top de candidatos |
| D1-009 | Auditoría de `docs/` (material complementario): mencionar qué módulos lo citan y si queda huérfano | informe |
| D1-010 | Censo de `scripts/` oficiales del protocolo (generar_checklist_global, verificar_checklist, apilar_beam, proximo_numero...): qué hace cada uno y última fecha de modificación | informe de inventario |
| D1-011 | Análisis del `AGENTS.md` en busca de secciones que contradictan entre sí (ej. numeración de canales §4.1-b vs §10.2) | informe con L# |
| D1-012 | Censo de `Mensajes entre modelos/`: mensajes por canal sin respuesta del receptor (por slug a-<receptor>) | informe de pendientes |
| D1-013 | Revisión de los presets de presupuesto II aplicados en presupuesto II (qué fórmulas quedaron [?] de capa II tras el racha 23oct) | informe con L# |
| D1-014 | Mapa de las 4 consultas del fundador pendientes (estado_director.json): qué las bloquea y qué archivos citan | informe estructurado |
| D1-015 | Inventario de las capturas masivas: qué módulos tienen 10+ capturas (maestra/riesgo de duplicado visual) | informe |
