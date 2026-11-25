# LOG 2444 - M20 tanda GLM-5.3-Flash: 5 ítems implementables cerrados (102→105/150) + verificación 9 implementables M01

**Modelo:** GLM-5.3-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-11-25
**Hora:** 09:54

## Resumen

Reintegración a la flota como AGENTE (encargo directo del fundador: trabajo a full; la dirección sigue siendo agnes-3-flash). Una tanda de M20-Sistema-De-Amistad cerrada (reclamo §21.4.7 del 🔵 stale 29 días de minimax-m3-1-flash) y una verificación read-only de los 9 implementables M01 que quedaron fuera de la b62 de HY4. Reportes 992/993 en el canal de la directora.

## Cambios Realizados

### Reintegración y relevamiento (sin ediciones)
- Leído el canal GLM-5.3-Flash (msg 34, acuse de la directora, sin encargo pendiente), el backlog propio (`TAREAS-POR-MODELO/glm-5.3-flash/BACKLOG-MASTER.md`), DOC-INT-4 (Nemotron 320), la b62 de HY4 (msg 150/152 + Log 2442) y la fila 20 del GLOBAL.
- Coordinación con agentes pares vía mensajes del entorno (GPT-6-Luna, DeepSeek-V4.1-Flash-DeepAI, minimax-m3-1-flash): sin solapamientos; avisado a minimax del reclamo de M20.
- Verificación read-only en disco de los 9 implementables M01 restantes (M24/M43/M51/M67/M72/M84/M87/M107/M109 con offset +1 → módulos reales 25/44/52/68/73/85/88/108/110): **9/9 con artefacto concreto** (evidencia en el reporte 992, lista para flip por quien la directora designe).

### Reserva M20 (§21.3, 4 registros)
- CHECKLIST-GLOBAL fila 20, ESTADO-PARALELO, guía 08 y 05-Checklist M20 (bloque "Reserva actual").

### Implementación M20 (5 ítems [S], tanda cerrada)
1. **L133 metadatos de item sin modificar M14:** verificado (consulta de solo lectura `ItemDatabase.get_item`); check nombrado nuevo.
2. **L136 recetas desbloqueadas por nivel → tabla de crafting:** nuevo método público `crafting_service.gd::aprender_receta_externa(rec_id)` (idempotente, emite receta_aprendida solo si es nueva) + `friendship_service.gd::_entregar_recompensa` con mapa `RECOMPENSA_RECETA` (herramienta_basica→rec_hacha_cobre, comida_gourmet→rec_ensalada_bayas; fallback "rec_"+sufijo; receta inexistente = aviso sin crash).
3. **L138 items decorativos regalo válido:** `gift_evaluator.gd::es_regalo_valido` (Resource con id no vacío = regalable; Dictionary solo se rechaza con "regalo_valido": false) + entrega al inventario al reclamar (mapa `RECOMPENSA_DECORATIVA`: decorativo_estatua→OBJ-EXT-017; decorativo_fuente sin ítem en catálogo = omitido con registro).
4. **L173 evaluador sin allocations:** defaults `[]` reemplazados por array estático compartido `_SIN_DATOS` en `gift_evaluator.gd` (el literal se evaluaba por llamada y asignaba un Array nuevo); ruta sin gustos medida 0.0071 ms/evaluación.
5. **L177 logs debug off en release:** flag `_logs_debug = OS.is_debug_build()` en `friendship_service.gd`; `registrar_evento` (DOM-AMISTAD, sin consumidores externos) no asigna en release.

### Fix lateral de la suite (bug preexistente en HEAD)
- `tests/test_m20_amistad_cobertura.gd` llamaba `_fs.charla()` — API inexistente (el servicio expone `charlar`): script error que silenciaba 3 checks y abortaba el recorrido M114. Corregidos los 4 llamados a `charlar()`. Confirmado contra `git show HEAD` (el servicio en HEAD ya tenía solo `charlar`).

## Verificación (§12/§14)

- `tests/test_m20_amistad_cobertura.gd` headless (godot472 4.7.2): **29 checks / 0 fallos / EXIT 0** (9 checks nuevos de la tanda).
- Wrapper `tests/test_m20_amistad_suites.gd` headless: **3 suites OK (14+53+12) + 8 checks de integración, 0 fallos — 79 checks verificados** (sin regresión).

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/friendship/friendship_service.gd` (constantes RECOMPENSA_RECETA/RECOMPENSA_DECORATIVA, _logs_debug, _entregar_recompensa, guard en registrar_evento)
- `game/isla-ancestral/scripts/friendship/gift_evaluator.gd` (es_regalo_valido + _SIN_DATOS estático)
- `game/isla-ancestral/scripts/crafting/crafting_service.gd` (aprender_receta_externa, +18 líneas, aditivo)
- `game/isla-ancestral/tests/test_m20_amistad_cobertura.gd` (+9 checks, fix charla→charlar)
- `DOCUMENTACION/20-Sistema-De-Amistad/plan-actual/05-Checklist.md` (5 flips con cita + Totales 105/45/0)
- `CHECKLIST-GLOBAL.md` (fila 20: 🟡 liberado 105/150 con nota)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (entrada de la tanda, cerrada)
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (reserva/cierre §21.3)
- `Mensajes entre modelos/agnes-3-flash/992-...` y `993-...` (reportes a la directora)

## Pendientes / Deuda (honestidad)

- Los 45 [ ] restantes de M20 son deuda externa (FriendshipEvent/5 tipos, schema versionado, UI M53, M21/M23) — no tocados.
- decorativo_fuente no tiene ítem en el catálogo M159: la entrega se omite con registro (requiere asset catálogo; dueño M159/M97).
- Los 21 implementables M20 restantes de DOC-INT-4 no se tocaron (por ruteo de la directora; evitar colisión con la b63 de HY4).
- QA cruzado §21.8 pendiente: la verificación debe hacerla un modelo distinto (Hy3/agnes/s2).

**Modelo:** GLM-5.3-Flash
**Plataforma:** Kilo Code
