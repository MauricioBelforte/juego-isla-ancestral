**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 01: Visión y Concepto

## 1. Carácter del Componente

Este módulo es **100% documental** (conceptual): no genera scripts, prefabs ni assets. Su "código de ejecución" son los documentos que fijan la visión y que los demás módulos usarán como entrada. Por ello **los archivos de testing (06/07) no aplican** a este componente y se omiten a propósito (AGENTS.md §11: archivos de testing opcionales).

## 2. Archivos involucrados

### Entradas (documentos de origen — inmutables)
| Archivo | Rol |
|---|---|
| `DOCUMENTACION/00-PLAN-INICIAL/IDEA-BASE-DEL-JUEGO.md` | GDD maestro: visión, bucles, sistemas, directivas |
| `DOCUMENTACION/00-PLAN-INICIAL/HISTORIA-DEL-JUEGO.md` | Biblia narrativa: contexto, Resonancia, Arquetipos |
| `DOCUMENTACION/00-PLAN-INICIAL/Plan-inicial-minimo.md` | Plan maestro: sección 1 (26 puntos) + 152 módulos |
| `DOCUMENTACION/00-PLAN-INICIAL/Plan-de-produccion.md` | Alcance v1.0, motor, presupuesto, riesgos |
| `DOCUMENTACION/INVESTIGACION SOBRE OTROS JUEGOS/*.md` | Referentes de mercado (cozy, voxel, social, aventuras) |

### Salidas (documentos del componente — vigentes)
| Archivo | Contenido |
|---|---|
| `plan-inicial/01-Requerimientos.md` | Problema, objetivos, alcance, restricciones, criterios |
| `plan-inicial/02-Analisis.md` | 26 puntos resueltos con fuente; público, nombre, diferenciadores |
| `plan-inicial/03-Diseno.md` | Identidad, pitch, descripciones, pilares, alcance v1.0 |
| `plan-inicial/05-Checklist.md` | 100+ ítems del módulo con estado honesto |
| `plan-actual/*` | Copia vigente (espejo del plan-inicial al día) |

## 3. "Funciones clave" del módulo (decisiones que otros módulos consumen)

| Decisión | Consumida por |
|---|---|
| Nombre "Isla Ancestral" | M02 docs, M05 arte (logotipo), M14 UI, publicación |
| Géneros y cámara | M03 motor, M10 movimiento, M05 arte |
| Filosofía cero violencia | M11 combate/sistemas (no aplica), M08 inventario/herramientas, QA |
| Pilares P1-P4 | M04 programación (arquitectura), M13 mundo, M15 IA |
| Pilares N1-N3 | M02 narrativa, M12 misiones, M23 diálogos |
| Pilares visuales/sonoros | M05 arte, M07 audio, M14 UI |
| Alcance v1.0 | CHECKLIST-GLOBAL (anti-scope-creep), roadmap, presupuesto |
| Principios rendimiento | M04, M136 voxel-optimización (60 FPS) |
| Principios accesibilidad | M14 UI/UX, M143 QA accesibilidad |

## 4. Verificación del Módulo

- Trazabilidad: todos los puntos 1-26 del plan maestro referenciados en `02-Analisis.md` con estado.
- Consistencia: ninguna definición contradice GDD/biblia/plan de producción (verificado al redactar).
- Checklist: 100+ ítems cubriendo implementación, integración, edge cases, documentación y polish.

## 5. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-15 23:30:00
**Estado:** Completado (documental)

### Lo que hice
- Consolidé los 26 puntos del plan maestro sección 1 en los 4 documentos del componente.
- Redacté identidad, pitch 15 s, frase, página, pilares (4 diseño + 3 narrativa + visual + sonoro), propuesta de valor, diferenciadores, alcance v1.0 y principios.
- Checklist de 100+ ítems con estados honestos y marcadores de esfuerzo [S]/[M]/[C].

### Lo que NO pude hacer (honestidad obligatoria)
- Verificar la disponibilidad legal del nombre "Isla Ancestral" (Steam, marcas) → requiere conexión a tiendas/registros; queda como pendiente `[ ]` en M02 (ya no es de este módulo).
- Definir el idioma primario de Steam (español vs inglés) → decisión de negocio/marketing tardía.
- Decidir modelo post-lanzamiento (gratis vs DLC) → el plan de producción lo difiere intencionalmente.

### Recomendaciones para el próximo agente
- M02 (Documentación): usar este componente como plantilla de calidad; verificar la disponibilidad del nombre (ítem 3 del plan maestro).
- M03 (Game Engine): el pitch y los diferenciadores (templo = mecánica única, voxel con memoria) deben traducirse a requisitos técnicos de motor; el requisito de 60 FPS voxel es el criterio decisivo.
- M05 (Arte): los pilares visuales de este componente definen el brief del estilo de arte.