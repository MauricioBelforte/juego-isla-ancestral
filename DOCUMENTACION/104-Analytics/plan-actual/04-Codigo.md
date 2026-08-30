**Modelo:** ox-alpha (Cline)
**Plataforma:** Cline

# 04-Codigo.md — Módulo 104: Analytics

## 0. Estado de implementación (actualizado por ox-alpha/Cline 2026-08-29)

> ⚠️ **IMPLEMENTADO (V0, verificado headless Godot 4.7.2).** Log 237.
> Archivos creados en `scripts/analytics/`:
> - `analytics_director.gd` → **autoload `AnalyticsDirector`**: captura RF1-RF7 (7 tipos), buffer con política de descarte (`max_buffer`), opt-out persistente (`user://analytics/opt_out.cfg`), session hash SHA256 rotativo 24h (16 hex), agregación por tipo, batch sender a JSON local (`user://analytics/lote_{ts}.json`), agregado histórico acumulado (`aggregated.json`), flush al cerrar (sesion_fin), señal `evento_registrado`, integración M103 GameLogger (categoría ANALYTICS) y ServiceRegistry ("analytics").
> - `analytics_config.gd` → clase `AnalyticsConfig` (Resource): opt_out por build, batch_interval_min, max_buffer.
> - `data/analytics/config.tres` → config por build.
> - `test_analytics.gd` → test headless (18/18 checks OK).
> Modo v1: **offline/agregado local** (sin red); el envío a servidor queda como extensión (M76/M77). El toggle de jugador (M91) pisa la config por build.
> Pendiente (no bloquea): UI de opt-out en menú M91, dashboard de desarrollo, envío remoto, suite GdUnit4 formal (M112).

## 1. Archivos previstos

| Archivo | Descripción | Estado |
|---|---|---|
| `res://analytics/director.gd` | AnalyticsDirector: autoload, gestión de eventos, batch sending | Pendiente de implementación |
| `res://analytics/events.tres` | Catálogo de eventos analytics: tipos, categorías, datos capturados | Pendiente de implementación |
| `res://analytics/config.tres` | Configuración de reporte: opt-out, frecuencia, destino | Pendiente de implementación |
| `res://analytics/storage.tres` | Almacenamiento local JSON agregado | Pendiente de implementación |
| `res://analytics/report.gd` | Generador de reportes agregados para equipo desarrollo | Pendiente de implementación |

## 2. API pública prevista

```gdscript
# Singleton AnalyticsDirector

func registrar_evento(tipo: String, datos: Dictionary) -> void:
    """Registra un evento de analytics en el buffer local."""
    pass

func esta_opt_out() -> bool:
    """Verifica si el jugador ha opt-out del reporte de analytics."""
    pass

func establecer_opt_out(estado: bool) -> void:
    """Activa o desactiva el reporte de analytics."""
    pass

func obtener_estadisticas_agregadas() -> Dictionary:
    """Retorna estadísticas agregadas desde último envío o inicio."""
    pass

func enviar_lote_datos() -> void:
    """Envía un lote de datos agregados al servidor o archivo local."""
    pass

func obtener_config() -> Dictionary:
    """Retorna la configuración actual de reporte de analytics."""
    pass
```

## 3. Pendientes de implementación

- Buffer de eventos en memoria con capacidad y políticas de descarte
- Sistema de batch sending con compresión y envío seguro
- Interfaz de configuración en menú (M91) para toggle opt-out
- Formato JSON optimizado para almacenamiento local
- Integración con M103 Logger para nivel INFO de eventos
- Dashboard mínimo para equipo desarrollo con estadísticas clave

## 4. Notas del Agente

**Modelo:** Nemotron 3.5 Lightning  
**Plataforma:** Cline  
**Fecha:** 2026-08-16 20:12:31  
**Estado:** Diseño completado, documentación lista para agente delegado

### Lo que hice
- Definí la arquitectura completa del sistema de analytics
- Establecí 7 requisitos funcionales y 4 no funcionales críticos
- Diseñé la arquitectura de privacidad por diseño (anonimización integrada)
- Definí la API pública y archivos previstos

### Lo que NO pude hacer (honestidad obligatoria)
- No implementé el buffer de eventos en tiempo real (pending)
- No conecté con M103 Logger real (pending)
- No creé el sistema de batch sending (pending)

### Recomendaciones para el próximo agente
- Implementar AnalyticsDirector.gd con captura de eventos y batch sending
- Conectar con M103 Logger para niveles de log y archivo
- Crear la configuración de opt-out en el menú M91
- Implementar sistema de envío de datos agregados cada 30 min

## Notas del Agente de la implementación

**Modelo:** ox-alpha (Cline)
**Plataforma:** Cline
**Fecha:** 2026-08-29
**Estado:** Completado (núcleo implementado y verificado headless Godot 4.7.2)

### Lo que hice
- Implementé `scripts/analytics/` completo: AnalyticsDirector (autoload), AnalyticsConfig (Resource), config.tres y test headless.
- Captura de los 7 tipos RF1-RF7 con buffer + política de descarte y agregación por tipo.
- Privacidad por diseño: session hash SHA256 rotativo 24h (16 hex), opt-out persistente que descarta eventos inmediatamente, sin datos personales en el JSON (validado en test).
- Batch sender offline a JSON local + agregado histórico acumulado en aggregated.json + flush al cerrar (sesion_fin).
- Integraciones: M103 GameLogger (categoría ANALYTICS), ServiceRegistry ("analytics"), autoload en project.godot.
- Test headless 18/18 OK + regresión completa 8/8 tests (0 fallos).

### Lo que NO pude hacer (honestidad obligatoria)
- Envío remoto a servidor (v1 es offline/agregado local; requiere M76/M77 y decisión de backend).
- UI de toggle opt-out en menú de configuración (consumidor M91/M53, sin implementar aún).
- Dashboard de desarrollo para ver agregados (pendiente, puede ser parte de M110/M53).
- Tests GdUnit4 formales para la suite de M112 (el test actual es headless custom).

### Recomendaciones para el próximo agente
- Conectar el toggle de M91 (menú de privacidad) a `AnalyticsDirector.establecer_opt_out()` — ya persiste y filtra en caliente.
- Para el dashboard: leer `user://analytics/aggregated.json` (totales_por_tipo) — ya es agregado y anónimo.
- Si se implementa envío remoto: reutilizar el payload del lote (ya serializado y anónimo) y respetar opt_out antes de cualquier transmisión.