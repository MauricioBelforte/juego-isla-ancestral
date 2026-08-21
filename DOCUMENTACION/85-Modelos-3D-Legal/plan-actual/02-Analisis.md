# Módulo 85: Modelos 3D — Legal — Análisis

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:26:00

## 1. Análisis del Dominio

### Tipos de Modelos 3D en un Juego

| Tipo | Ejemplos | Protección Legal |
|------|----------|------------------|
| **Originales creados para el juego** | Personajes, escenarios, props | Copyright automático |
| **Librerías de stock** | Modelos de TurboSquid, Sketchfab | Licencia de uso (varía) |
| **Modelos de código abierto** | Blender Studio, Sketchfab CC | Varía por licencia CC |
| **Modelos de IA generativa** | Herramientas de generación 3D | Área gris legal |
| **Modelos modificados** | Remix de modelos existentes | Depende de licencia original |

### Licencias Comunes de Modelos 3D

| Licencia | Permisos | Restricciones |
|----------|----------|---------------|
| **Royalty-Free** | Uso comercial, ilimitado | No redistribuir el modelo suelto |
| **Editorial** | Solo uso editorial | No uso comercial |
| **Editorial Plus** | Uso comercial limitado | Restricciones por plataforma |
| **Creative Commons** | Varía por variante | Attribution, NC, SA, etc. |
| **GPL/CC-BY** | Uso libre | Requiere attribution |
| **Propietaria** | Restringida | Negociar caso por caso |

### Herramientas de Modelado y Licencias

| Herramienta | Licencia | Impacto |
|-------------|----------|---------|
| Blender | GPL | Modelos creados son libres (CC-BY o similar) |
| MagicaVoxel | Free/Propietaria | Modelos son de uso libre |
| ZBrush | Propietaria | Modelos son del artista |
| Maya | Propietaria | Modelos son del artista |
| Godot (importación) | MIT | Sin restricciones |

## 2. Decisiones de Diseño

### Decisión 1: Modelo de Propiedad de Modelos

**Opción A:** Work-for-Hire total (el estudio posee todo)
- Pro: Control total, sin regalías futuras
- Contra: Más caro, puede alejar artistas freelance

**Opción B:** Licencia exclusiva con regalías
- Pro: Más atractivo para artistas
- Contra: Complejidad de gestión

**Decisión:** Work-for-Hire para modelos core (personajes principales, assets críticos). Licencia no-exclusiva para modelos secundarios (props genéricos, decoración).

### Decisión 2: Modelos de Stock

**Opción A:** Solo royalty-free con uso comercial
- Pro: Sin problemas legales
- Contra: Menor variedad disponible

**Opción B:** Permitir editorial con restricciones
- Pro: Mayor variedad
- Contra: Requiere tracking de restricciones

**Decisión:** Solo royalty-free con uso comercial confirmado. No usar modelos editoriales.

### Decisión 3: Créditos de Artistas

**Opción A:** Créditos en menú del juego
- Pro: Tradicional
- Contra: Limitado en espacio

**Opción B:** Créditos en archivo web + menú
- Pro: Completo
- Contra: Requiere hosting

**Decisión:** Ambos. Créditos básicos en menú + archivo web detallado.

## 3. Análisis de Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
| Modelo de stock revoque licencia | Baja | Alto | Verificar perpetual license |
| Artista demanda por falta de credito | Media | Alto | Credito obligatorio en TODOS los builds |
| Modelo de IA genera disputa | Media | Medio | Artista humano como autor final |
| Modelo tiene copyright no detectado | Media | Alto | Verificar licencia antes de usar |
| Herramienta GPL infecta modelos | Baja | Baja | Modelos son outputs, no código |

## 4. Mapeo de Dependencias del Juego

### Modelos Actuales del Proyecto

| Componente | Tipo | Estado Legal |
|------------|------|--------------|
| Personaje del jugador | Original | Work-for-Hire pendiente |
| NPCs | Original | Work-for-Hire pendiente |
| Escenarios | Original | Work-for-Hire pendiente |
| Props | Mixto | Verificar stock |
| Animales | Original | Work-for-Hire pendiente |
| Herramientas | Original | Work-for-Hire pendiente |

## 5. Framework Legal Recomendado

### Para Artistas 3D Freelance

1. Contrato Work-for-Hire con pago upfront
2. Cesión de copyright al estudio
3. Crédito obligatorio
4. Opción de regalías para DLC/merchandise

### Para Modelos de Stock

1. Verificar perpetual license
2. Verificar uso comercial
3. Verificar attribution requirements
4. Guardar copia de licencia

### Para Modelos de Código Abierto

1. Verificar licencia CC (BY, BY-SA, BY-NC)
2. Cumplir con attribution
3. Verificar si SA requiere relicenciar el juego
4. Documentar attribution en créditos
