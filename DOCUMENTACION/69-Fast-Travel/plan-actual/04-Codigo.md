**Modelo:** Nemotron 3.5 Lightning
**Plataforma:** Cline

# 04-Codigo.md — Módulo 69: Fast Travel

## 1. Archivos previstos

| Archivo | Descripción | Estado |
|---|---|---|
| `res://fast_travel/manager.gd` | FastTravelManager: autoload, lógica de validación, costo, restricciones | Pendiente de implementación |
| `res://fast_travel/service.gd` | FastTravelService: singleton, gestión de destinos, último punto guardado | Pendiente de implementación |
| `res://fast_travel/menu.gd` | FastTravelMenu: CanvasLayer, interfaz de selección de destinos | Pendiente de implementación |
| `res://fast_travel/effects.gd` | FastTravelEffect: animación de transición (bruma, desvanecimiento) | Pendiente de implementación |
| `res://fast_travel/data.tres` | Catálogo de puntos de viaje desbloqueados y costos asociados | Pendiente de implementación |

## 2. API pública prevista

```gdscript
# Singleton FastTravelManager

func viajar_a(destino: String) -> void:
    """Inicia el viaje rápido al destino especificado."""
    pass

func esta_disponible(destino: String) -> bool:
    """Verifica si el fast travel está disponible al destino."""
    pass

func agregar_punto_viaje(nombre: String, posicion: Vector2) -> void:
    """Añade un nuevo punto de viaje desbloqueado."""
    pass

func obtener_puntos_disponibles() -> Array:
    """Retorna la lista de puntos de viaje desbloqueados y accesibles."""
    pass

func establecer_ultimo_punto(nombre: String) -> void:
    """Guarda el último punto de viaje usado por sesión."""
    pass

func obtener_ultimo_punto() -> String:
    """Retorna el nombre del último punto de viaje visitado."""
    pass
```

## 3. Pendientes de implementación

- Lógica completa de validación de restricciones por estado del jugador
- Integración con sistema de recursos (M03/M35) para costo de viajes
- Animaciones de transición visual optimizadas
- Interfaz de menú responsive y accesible
- Guardado y carga de puntos de viaje entre sesiones

## 4. Notas del Agente

**Modelo:** Nemotron 3.5 Lightning
**Plataforma:** Cline
**Fecha:** 2026-08-16 HH:MM:SS  
**Estado:** Diseño completado, documentación lista para agente delegado

### Lo que hice
- Diseñé la arquitectura completa del sistema fast travel
- Definí 13 criterios de aceptación basados en la sección 68 del plan maestro
- Establecí reglas de costo, restricciones y integración con M29/M31
- Definí la API pública y archivos previstos

### Lo que NO pude hacer (honestidad obligatoria)
- No implementé el código GDScript real (diseño y documentación solo)
- No conecté con el sistema de recursos existente (pending)

### Recomendaciones para el próximo agente
- Implementar FastTravelManager.gd con validación de estado
- Conectar con el sistema de inventario para costo en recursos
- Crear la interfaz de menú en Godot CanvasLayer
- Probar restricciones durante combate y diálogos