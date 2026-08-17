**Modelo:** SWE-1.6
**Plataforma:** Devin

# 04-Codigo.md — Módulo 102: Bug Tracking

## 1. Carácter del Componente

Módulo de **infraestructura de desarrollo** que especifica el sistema de seguimiento de bugs usando GitHub Issues. No crea código del juego, sino configuración del repositorio (templates, labels, workflows). Implementable inmediatamente (no depende de otros módulos del juego).

**06-Plan-Testings.md:** NO aplica (es configuración de repo, no código que requiere tests).

## 2. Archivos involucrados (implementación)

```
.github/ISSUE_TEMPLATE/bug_report.md       ← Plantilla de reporte de bug
.github/labels/                           ← Etiquetas predefinidas (creadas via GitHub API o manual)
.github/workflows/bug_metrics.yml        ← (Opcional) Workflow para métricas
docs/bug_tracking_guide.md                ← Guía para testers y desarrolladores
docs/bug_metrics.md                       ← Dashboard de métricas (generado por workflow)
```

## 3. Contratos de integración

### Entrada (desde otros módulos)
- **M101 (QA General):** Testers crean issues usando la plantilla
- **M103 (Logging):** Logs generados se adjuntan a issues
- **M110 (Debug Menu):** Botón "Reportar Bug" genera draft con metadata capturada
- **M112 (Testing Automático):** Tests que fallan pueden crear issues automáticamente (futuro)

### Salida (hacia otros módulos)
- **M101 (QA General):** Issues verificados y cerrados vuelven al pool de QA
- **M133 (Gestión del Proyecto):** Métricas de bugs informan roadmap y milestones
- **M136 (Roadmap):** Bugs críticos pueden ajustar prioridades de roadmap

### Configuración
- GitHub repository settings: habilitar issues, templates, labels
- GitHub Actions: (opcional) workflow para métricas

## 4. Implementación de labels (configuración)

Las etiquetas se crean en GitHub via:

**Opción A: GitHub UI manual**
- Settings → Labels → Create label
- Configurar nombre, color, descripción

**Opción B: GitHub API (script)**
```bash
# Script para crear labels (opcional, futuro)
gh label create severity:critical --color "d73a4a" --description "Bloquea release"
gh label create severity:major --color "ff7b72" --description "Bloquea milestone"
# ... etc para todas las labels
```

## 5. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Crear archivo `.github/ISSUE_TEMPLATE/bug_report.md` | **IMPLEMENTACIÓN INMEDIATA** |
| Crear labels en GitHub (manual o script) | **IMPLEMENTACIÓN INMEDIATA** |
| Crear guía `docs/bug_tracking_guide.md` | **IMPLEMENTACIÓN INMEDIATA** |
| Workflow `.github/workflows/bug_metrics.yml` | M133 (Gestión del Proyecto) - opcional |
| Integración con Debug Menu (botón reportar) | M110 (Debug Menu) |
| Integración con Logging (auto-adjuntar logs) | M103 (Logging) |
| Tests automáticos que crean issues | M112 (Testing Automático) - futuro |

## 6. Notas del Agente

**Modelo:** SWE-1.6
**Plataforma:** Devin
**Fecha:** 2026-08-16 17:15:00
**Estado:** Completado (especificación; implementación inmediata posible)

### Lo que hice
- Resolví los 21 puntos de la sección 101 del plan maestro.
- Diseñé el sistema de bug tracking usando GitHub Issues (gratis, integrado).
- Definí categorías, severidades, prioridades y flujo de trabajo completo.
- Creé plantilla de issue con metadata específica para el proyecto (seed, save).
- Especifiqué integración con M101 (QA), M103 (Logging), M110 (Debug Menu), M112 (Testing).

### Lo que NO pude hacer (honestidad obligatoria)
- Crear los archivos físicos en `.github/` (requiere acceso al repo real, no solo documentación).
- Crear las labels en GitHub (requiere acceso al repo).
- Implementar el workflow de métricas (opcional, futuro).

### Recomendaciones para el próximo agente (implementador)
- Crear la plantilla `.github/ISSUE_TEMPLATE/bug_report.md` exactamente como está en 03-Diseno.md.
- Crear las labels manualmente en GitHub Settings → Labels (más rápido que script).
- La guía `docs/bug_tracking_guide.md` debe incluir ejemplos concretos del proyecto (bugs reales del prototipo).
- El botón "Reportar Bug" del Debug Menu (M110) debe capturar metadata específica: seed, posición, FPS.
- Priorizar bugs críticos y mayores antes de menores y triviales (matriz de decisión en 02-Analisis.md).
