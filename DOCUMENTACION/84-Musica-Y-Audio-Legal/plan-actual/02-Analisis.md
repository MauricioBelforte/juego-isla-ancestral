# Módulo 84: Música y Audio — Legal — Análisis

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:25:00

## 1. Análisis del Dominio

### Tipos de Audio en un Juego

| Tipo | Ejemplos | Protección Legal |
|------|----------|------------------|
| **Composición original** | Banda sonora, leitmotifs | Copyright automático al crear |
| **Interpretación** | Ejecución por músico | Derechos de artista intérprete |
| **Librerías de stock** | Samples, loops | Licencia de uso (varía) |
| **Audio generado por IA** | Música procedural, voz sintética | Área gris legal |
| **Muestras musicales** | Clips de canciones existentes | Requiere clearances |
| **Sound design** | Efectos de sonido originales | Copyright automático |

### Estructura Legal del Audio en Juegos

```
[Composición] + [Interpretación] + [Licencia] = [Audio Legal]
       │              │                  │
       ▼              ▼                  ▼
  Composer      Session Musicians    Libraries
  (Copyright)   (Performance)        (Usage Rights)
```

### Contratos Necesarios

| Contrato | Para quién | Contenido |
|----------|------------|-----------|
| **Work-for-Hire** | Compositor del juego | Cesión total de PI al estudio |
| **Licencia de uso** | Librerías de stock | Derecho a usar en el juego |
| **Contrato de artista** | Músicos, cantantes | Pago + credito + regalías |
| **Contrato de voz** | Voice actors | Pago + credito + release |
| **Clearance de muestras** | Dueños de canciones | Derecho a usar fragmentos |

## 2. Decisiones de Diseño

### Decisión 1: Modelo de Propiedad de Audio

**Opción A:** Work-for-Hire total (el estudio posee todo)
- Pro: Control total, sin regalías futuras
- Contra: Más caro upfront, puede alejar artistas

**Opción B:** Licencia exclusiva con regalías
- Pro: Más atractivo para artistas
- Contra: Complejidad de regalías, costos recurrentes

**Decisión:** Work-for-Hire para composiciones core del juego. Licencia con regalías para contenido DLC/expansiones.

### Decisión 2: Audio Generado por IA

**Opción A:** Prohibir audio de IA
- Pro: Claridad legal total
- Contra: Pierde funcionalidad procedural

**Opción B:** Permitir con disclosure
- Pro: Innovación
- Contra: Riesgo legal no definido

**Decisión:** Permitir audio de IA generativa como herramienta de composición, pero siempre con composer humano como autor final. El AI es herramienta, no autor.

### Decisión 3: Sistema de Créditos

**Opción A:** Créditos en menú del juego
- Pro: Tradicional, visible
- Contra: Olvidable

**Opción B:** Créditos en archivo web + menú
- Pro: Persistente, detallado
- Contra: Requiere hosting

**Decisión:** Ambos. Créditos básicos en menú del juego + archivo web detallado.

## 3. Análisis de Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
| Artista demanda por falta de credito | Media | Alto | Credito obligatorio en TODOS los builds |
| Librería de stock revoque licencia | Baja | Alto | Verificar perpetual license |
| Audio de IA genera disputa de copyright | Media | Medio | Composer humano como autor final |
| Música de stock tiene sample no-clearance | Media | Alto | Verificar licenses antes de usar |
| Voice actor reclama más pagos | Baja | Medio | Contrato con pago completo documentado |

## 4. Mapeo de Dependencias del Juego

### Audio Actual del Proyecto

| Componente | Tipo | Estado Legal |
|------------|------|--------------|
| Banda sonora original | Composición | Work-for-Hire pendiente |
| Samples de ambiance | Stock library | Licencia pendiente |
| Efectos de sonido | Original | Copyright automático |
| Voz del jugador | N/A | Sin voz |
| Música procedural (AI) | Generativa | Área gris |

## 5. Framework Legal Recomendado

### Para Compositor del Juego

1. Contrato Work-for-Hire con pago upfront
2. Cesión de copyright al estudio
3. Créito obligatorio en todos los builds
4. Opción de regalías para secuelas/DLC

### Para Artistas/Session Musicians

1. Pago por sesión (work-for-hire o flat fee)
2. Crédito obligatorio
3. Release de grabación
4. Sin regalías en juego base

### Para Librerías de Stock

1. Verificar perpetual license (no subscription)
2. Verificar uso comercial permitido
3. Verificar attribution requirements
4. Guardar copia de licencia en repositorio
