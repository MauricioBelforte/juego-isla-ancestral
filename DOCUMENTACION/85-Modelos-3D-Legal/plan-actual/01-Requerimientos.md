# Módulo 85: Modelos 3D — Legal — Requerimientos

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:26:00

## Problema

El módulo 45 (Arte 3D) define la creación de modelos voxel y low-poly, pero no cubre los aspectos legales:
- Licenciamiento de modelos creados para el juego
- Uso de librerías de modelos de terceros (TurboSquid, Sketchfab, etc.)
- Derechos de artistas 3D que crean contenido para el juego
- Validación de modelos descargados vs. licencias permitidas
- Créditos de artistas 3D en el juego
- Uso de herramientas de modelado (Blender, MagicaVoxel) y sus licencias

## Objetivos

1. Definir estructura legal para modelos 3D originales del juego
2. Establecer contratos de licenciamiento para modelos de terceros
3. Definir derechos de artistas 3D freelance
4. Crear sistema de créditos de arte 3D
5. Validar compatibilidad legal de modelos descargados
6. Establecer proceso de verificación de licencias de modelos

## Alcance

- **Incluye:** Licencias de modelos 3D, contratos de artistas, créditos, validación
- **No incluye:** Diseño de modelos (M45), texturas (M47), animación (M48)

## Restricciones

- Cada modelo necesita licencia clara
- Modelos de stock pueden tener restriction de redistribución
- Artistas tienen derecho a credito
- Algunas licencias prohíben uso comercial
- Modelos de IA generativa requieren validación adicional

## Dependencias del Módulo

| Tipo | Módulos |
|------|---------|
| Antes de empezar | 45-Arte 3D, 78-Legal PI, 79-Legal Contratos |
| Durante el desarrollo | 71-Gestión de Assets, 72-Validación de Builds |
| Relacionados | 86-IA Generativa, 139-IA Generativa |

## Criterios de Aceptación

- [ ] Plantilla de contrato para artistas 3D
- [ ] Sistema de validación de licencias de modelos
- [ ] Inventario de modelos y sus licencias
- [ ] Créditos de artistas 3D documentados
- [ ] Proceso de verificación pre-build

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M045** — Arte 3D | Base para arte 3d |
| **M078** — Legal — Propiedad Intelectual | Base para legal — propiedad intelectual |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M045** — Arte 3D | Depende de este módulo |
| **M078** — Legal — Propiedad Intelectual | Depende de este módulo |

