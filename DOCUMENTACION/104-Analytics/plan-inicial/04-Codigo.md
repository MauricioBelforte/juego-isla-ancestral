**Modelo:** Nemotron 3.5 Lightning
**Plataforma:** Cline

# 04-Codigo.md — Módulo 104: Analytics

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
**Fecha:** 2026-08-16 HH:MM:SS  
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