**Modelo:** Nemotron 3.5 Lightning
**Plataforma:** Cline

# 04-Codigo.md — Módulo 131: Créditos

## 1. Archivos previstos

| Archivo | Descripción | Estado |
|---|---|---|
| `res://credits/director.gd` | CreditsDirector: autoload, gestión de datos, lógica de idioma | Pendiente de implementación |
| `res://credits/catalog.tres` | Catálogo de créditos: equipos, contribuyentes, assets, licencias | Pendiente de implementación |
| `res://credits/scene.tscn` | CreditsScene: nodo raíz con UI completa | Pendiente de implementación |
| `res://credits/ui/credits-canvas.tscn` | CreditsCanvas: CanvasLayer con interfaz completa | Pendiente de implementación |
| `res://credits/data.tres` | Datos de créditos: lista estructurada por categorías | Pendiente de implementación |

## 2. API pública prevista

```gdscript
# Singleton CreditsDirector

func cargar_creditos() -> Dictionary:
    """Carga todos los datos de créditos desde el catálogo."""
    pass

func obtener_equipos() -> Array:
    """Retorna la lista de equipos principales."""
    pass

func obtener_contribuyentes() -> Array:
    """Retorna la lista de contribuyentes voluntarios."""
    pass

func obtener_assets_terceros() -> Array:
    """Retorna la lista de assets de terceros con licencias."""
    pass

func obtener_creditos_idioma(idioma: String) -> Array:
    """Retorna créditos traducidos al idioma especificado."""
    pass

func siguiente_seccion() -> void:
    """Avanza a la siguiente sección de créditos."""
    pass

func detener_animacion() -> void:
    """Detiene la animación automática de desplazamiento."""
    pass

func establecer_idioma(idioma: String) -> void:
    """Cambia el idioma de displayed créditos."""
    pass

func obtener_idioma_actual() -> String:
    """Retorna el idioma actual de displayed créditos."""
    pass
```

## 3. Pendientes de implementación

- Base de datos completa de contribuyentes y sus roles
- Sistema de traducción automática o manual para 2 idiomas
- Interfaz de búsqueda en tiempo real con filtrado
- Configuración de tamaño de texto y velocidad de animación
- Integración con M91 (Configuración de Audio) para control de velocidad
- Integración con M90 (Configuración Gráfica) para fuentes y contraste

## 4. Notas del Agente

**Modelo:** Nemotron 3.5 Lightning  
**Plataforma:** Cline  
**Fecha:** 2026-08-16 HH:MM:SS  
**Estado:** Diseño completado, documentación lista para agente delegado

### Lo que hice
- Definí la arquitectura completa del sistema de créditos
- Establecí 7 criterios de aceptación basados en requisitos de reconocimiento
- Diseñé la estructura de categorías y configuración de interfaz
- Definí la API pública y archivos previstos

### Lo que NO pude hacer (honestidad obligatoria)
- No implementé la base de datos de contribuyentes (pendiente de recopilación real)
- No conecté con los sistemas de configuración M90/M91/M91 (pending)

### Recomendaciones para el próximo agente
- Implementar CreditsDirector.gd con carga de datos y gestión de idioma
- Crear la interfaz UI en Godot CanvasLayer con RichTextLabel
- Integrar sistema de búsqueda y filtrado por nombre/rol/equipo
- Conectar con M90/M91 para configuración de texto y animación