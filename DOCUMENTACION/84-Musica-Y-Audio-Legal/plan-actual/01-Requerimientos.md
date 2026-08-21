# Módulo 84: Música y Audio — Legal — Requerimientos

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:25:00

## Problema

El módulo 41 (Música) define la composición y el sistema de capas, pero no cubre los aspectos legales específicos de la música y el audio:
- Licenciamiento de composiciones originales vs. librerías de stock
- Derechos de interpretación (artistas, sesionistas)
- Sincronización con gameplay (timing, mood)
- Uso de audio generado por IA (M139) y sus implicaciones legales
- Distribución en plataformas (Steam, consolas) con requisitos de audio
- Créditos y atribución en el juego

## Objetivos

1. Definir estructura legal para composiciones originales del juego
2. Establecer contratos de licenciamiento para librerías de audio
3. Definir derechos de interpretación para artistas/voice actors
4. Crear sistema de créditos de audio para el juego
5. Validar compatibilidad legal de audio generado por IA
6. Establecer proceso de clearances para muestras musicales

## Alcance

- **Incluye:** Licencias de composiciones, contratos de artistas, créditos de audio, IA generativa de audio
- **No incluye:** Diseño musical (M41), sonido ambiental (M42), efectos de sonido (M43)

## Restricciones

- Cada composición necesita contrato claro de licencia
- Artistas tienen derecho a credito obligatorio
- Audio de IA puede no tener protección de copyright (área gris legal)
- Plataformas pueden exigir licenses específicas
- Budget para clearances de muestras musicales

## Dependencias del Módulo

| Tipo | Módulos |
|------|---------|
| Antes de empezar | 41-Música, 78-Legal PI, 79-Legal Contratos |
| Durante el desarrollo | 86-IA Generativa |
| Relacionados | 139-IA Generativa, 141-Beta |

## Criterios de Aceptación

- [ ] Plantilla de contrato de licencia musical para el juego
- [ ] Plantilla de contrato para artistas/voice actors
- [ ] Sistema de créditos de audio documentado
- [ ] Proceso de clearances para muestras definido
- [ ] Validación legal de audio generado por IA
