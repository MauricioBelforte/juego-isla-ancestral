# Log 237: M104 Analytics — implementación del director de analytics

**Fecha:** 2026-08-29
**Hora:** 17:40
**Modelo:** ox-alpha (Cline)
**Plataforma:** Cline

## Resumen
Se implementó el módulo M104 (Analytics), de infraestructura transversal V0, conforme al diseño de Nemotron 3.5/B1 (03-Diseno/04-Codigo). Sistema de telemetría con privacidad por diseño: captura de 7 tipos de evento, opt-out persistente, session hash anónimo rotativo 24h, agregación y batch JSON local (modo offline v1). Verificado headless Godot 4.7.2 con regresión completa.

## Cambios Realizados
- **`scripts/analytics/analytics_director.gd`** → autoload `AnalyticsDirector`: registrar_evento (RF1-RF7: sesion_inicio/fin, area_visitada, feature_usada, error, pausa_reanudacion, config_cambio), buffer con descarte (max_buffer), esta_opt_out/establecer_opt_out persistente (user://analytics/opt_out.cfg, filtra en caliente), session hash SHA256 rotativo 24h (16 hex, sin datos personales), obtener_estadisticas_agregadas, enviar_lote_datos (JSON local lote_{ts}.json), agregado histórico (aggregated.json), flush al cerrar con sesion_fin, señal evento_registrado.
- **`scripts/analytics/analytics_config.gd`** → clase `AnalyticsConfig` (Resource): opt_out por build, batch_interval_min, max_buffer.
- **`data/analytics/config.tres`** → config por build.
- **`scripts/analytics/test_analytics.gd`** → test headless.
- **Registrado** autoload `AnalyticsDirector` en `project.godot` + servicio `"analytics"` en ServiceRegistry (M07).
- **Integración M103**: logs propios vía GameLogger (categoría ANALYTICS, solo trazas, nunca contenido del evento).

## Verificación
- `test_analytics.gd`: 18/18 checks OK (captura 7 tipos, opt-out inmediato y persistido, privacidad del JSON, batch, histórico acumulado, política de buffer).
- Regresión headless (0 fallos): test_logger 14/14, topos_banda 11/11, minorista_mayorista 14/14, edge_cases_precio 20/20, loop_economico 14/14, calendario 13/13, consumidores_tiempo OK, analytics 18/18.

## Archivos Modificados/Creados
- Creados: `scripts/analytics/*.gd` (3), `data/analytics/config.tres`, `.uid` generados por Godot.
- Modificados: `project.godot` (autoload AnalyticsDirector).
- Documentación: `DOCUMENTACION/104-Analytics/plan-actual/04-Codigo.md`, `05-Checklist.md` (sección N de implementación, 14 ítems [x]).