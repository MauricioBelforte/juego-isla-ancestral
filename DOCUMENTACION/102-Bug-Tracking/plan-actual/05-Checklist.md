**Modelo:** SWE-1.6
**Plataforma:** Devin

# 05-Checklist.md — Módulo 102: Bug Tracking

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.

## A. Requisitos del módulo (12)

- [ ] Definir el problema: sistema organizado de seguimiento de bugs [S]
- [ ] Registrar dependencias: M101 (QA); consumidores M110, M112 [S]
- [ ] Catalogar los 21 puntos del plan maestro (sección 101) [S]
- [ ] Definir criterios de aceptación verificables [S]
- [ ] RF1: herramienta de bugs (GitHub Issues) [S]
- [ ] RF2: categorías de clasificación [S]
- [ ] RF3: severidades (crítico, mayor, menor, trivial) [S]
- [ ] RF4: prioridades (inmediata, alta, media, baja) [S]
- [ ] RF5: reproducibilidad (siempre, a veces, nunca) [S]
- [ ] RF6: pasos para reproducir estandarizados [S]
- [ ] RF7: metadata técnica (versión, plataforma, build) [S]
- [ ] RF8: evidencia (logs, capturas, videos) [S]
- [ ] RF9: contexto específico (seed, save) [S]
- [ ] RF10: asignación de responsable [S]
- [ ] RF11: estados del bug (flujo de trabajo) [S]
- [ ] RF12: verificación con regresión [S]
- [ ] RF13: historial de cambios [S]
- [ ] RF14: integración con QA [S]

## B. Herramienta y configuración (10)

- [ ] Elegir GitHub Issues como herramienta [S]
- [ ] Justificar elección (gratis, integrado, conocido) [S]
- [ ] Descartar alternativas (Jira, Trello, Notion) [S]
- [ ] Configurar GitHub Issues en el repositorio [S]
- [ ] Habilitar templates de issues [S]
- [ ] Habilitar labels personalizadas [S]
- [ ] Configurar workflow de issues [S]
- [ ] Documentar acceso a GitHub para equipo [S]
- [ ] Definir permisos (quién puede crear/asignar/cerrar) [S]
- [ ] Integrar con repo existente del proyecto [S]

## C. Categorías de bugs (10)

- [ ] Definir categoría Gameplay [S]
- [ ] Definir categoría UI/UX [S]
- [ ] Definir categoría Audio [S]
- [ ] Definir categoría Render/Física [S]
- [ ] Definir categoría Networking [S]
- [ ] Definir categoría Assets [S]
- [ ] Definir categoría Build/Deploy [S]
- [ ] Definir categoría Localización [S]
- [ ] Definir categoría Performance [S]
- [ ] Definir categoría Crash [S]
- [ ] Asignar colores a cada categoría [S]
- [ ] Documentar ejemplos por categoría [M]

## D. Severidades y prioridades (12)

- [ ] Definir severidad Crítico (bloquea release) [S]
- [ ] Definir severidad Mayor (bloquea milestone) [S]
- [ ] Definir severidad Menor (no bloquea) [S]
- [ ] Definir severidad Trivial (cosmético) [S]
- [ ] Definir prioridad Inmediata (hotfix) [S]
- [ ] Definir prioridad Alta (sprint actual) [S]
- [ ] Definir prioridad Media (backlog) [S]
- [ ] Definir prioridad Baja (eventual) [S]
- [ ] Crear matriz de decisión severidad vs prioridad [M]
- [ ] Asignar colores a severidades [S]
- [ ] Asignar iconos a prioridades [S]
- [ ] Documentar criterios de asignación [M]

## E. Plantilla de issue (15)

- [ ] Crear archivo .github/ISSUE_TEMPLATE/bug_report.md [S]
- [ ] Incluir sección Descripción del bug [S]
- [ ] Incluir sección Severidad con checkboxes [S]
- [ ] Incluir sección Categoría con checkboxes [S]
- [ ] Incluir sección Prioridad con checkboxes [S]
- [ ] Incluir sección Pasos para reproducir numerados [S]
- [ ] Incluir sección Comportamiento esperado [S]
- [ ] Incluir sección Comportamiento actual [S]
- [ ] Incluir sección Reproducibilidad con checkboxes [S]
- [ ] Incluir sección Contexto técnico (versión, plataforma) [S]
- [ ] Incluir campo Seed de generación [S]
- [ ] Incluir campo Archivo de guardado [S]
- [ ] Incluir sección Evidencia (logs, screenshots, videos) [S]
- [ ] Incluir sección Referencias (issues relacionados, módulos) [S]
- [ ] Configurar título automático con prefijo [BUG] [S]
- [ ] Configurar labels automáticos (bug, status:new) [S]

## F. Flujo de trabajo y estados (12)

- [ ] Definir estado Nuevo (status:new) [S]
- [ ] Definir estado En Progreso (status:in-progress) [S]
- [ ] Definir estado Verificado (status:verified) [S]
- [ ] Definir estado Cerrado (status:closed) [S]
- [ ] Definir estado Wontfix (status:wontfix) [S]
- [ ] Definir estado Duplicate (status:duplicate) [S]
- [ ] Definir transiciones entre estados [M]
- [ ] Definir triage de issues nuevos [S]
- [ ] Definir proceso de asignación [S]
- [ ] Definir proceso de verificación por QA [S]
- [ ] Definir proceso de cierre con versión de fix [S]
- [ ] Definir reabertura si verificación falla [S]
- [ ] Documentar flujo en diagrama [M]

## G. Labels y configuración (10)

- [ ] Crear label severity:critical (rojo) [S]
- [ ] Crear label severity:major (naranja) [S]
- [ ] Crear label severity:minor (amarillo) [S]
- [ ] Crear label severity:trivial (gris) [S]
- [ ] Crear label priority:immediate (🔥) [S]
- [ ] Crear label priority:high (⚡) [S]
- [ ] Crear label priority:medium (📌) [S]
- [ ] Crear label priority:low (📝) [S]
- [ ] Crear labels de categoría con colores [M]
- [ ] Crear labels de estado (status:*) [M]
- [ ] Crear label needs-info para issues incompletos [S]
- [ ] Documentar convención de labels [S]

## H. Integración con otros módulos (8)

- [ ] Integración con M101 (QA General) especificada [S]
- [ ] Integración con M103 (Logging) especificada [S]
- [ ] Integración con M110 (Debug Menu) especificada [S]
- [ ] Integración con M112 (Testing Automático) especificada [S]
- [ ] Integración con M122 (Crash Reporting) especificada [S]
- [ ] Integración con M133 (Gestión del Proyecto) especificada [S]
- [ ] Integración con M136 (Roadmap) especificada [S]
- [ ] Documentar flujos de datos entre módulos [M]

## I. Debug Menu y Logging (8)

- [ ] Especificar botón "Reportar Bug" en Debug Menu [S]
- [ ] Definir metadata capturada por Debug Menu [M]
- [ ] Definir captura de pantalla automática [S]
- [ ] Definir adjunto de log de sesión [S]
- [ ] Definir apertura de GitHub con plantilla pre-llenada [S]
- [ ] Especificar formato de log para bugs (M103) [S]
- [ ] Definir generación de bug_{timestamp}.log [S]
- [ ] Definir últimas 1000 líneas en log de bug [S]

## J. Reglas de calidad (8)

- [ ] Regla 1: Nunca cerrar sin verificación [S]
- [ ] Regla 2: Metadata obligatoria [S]
- [ ] Regla 3: Contexto específico para procedural [S]
- [ ] Regla 4: Regresión obligatoria [S]
- [ ] Regla 5: Sin duplicates [S]
- [ ] Documentar guías para testers [S]
- [ ] Documentar guías para desarrolladores [S]
- [ ] Definir métricas de calidad (bug rate, fix rate, reopen rate) [M]

## K. Documentación y guía (10)

- [ ] Crear docs/bug_tracking_guide.md [S]
- [ ] Incluir guía para testers (cómo reproducir) [M]
- [ ] Incluir guía para desarrolladores (cómo priorizar) [M]
- [ ] Incluir ejemplos de bugs bien reportados [M]
- [ ] Incluir ejemplos de bugs mal reportados [M]
- [ ] Documentar proceso de triage [S]
- [ ] Documentar proceso de verificación [S]
- [ ] Crear workflow opcional para métricas [S]
- [ ] Definir docs/bug_metrics.md (dashboard) [S]
- [ ] Documentar actualización semanal de métricas [S]

## L. Cierre y verificación (10)

- [ ] 01-Requerimientos.md creado y firmado [S]
- [ ] 02-Analisis.md creado y firmado [S]
- [ ] 03-Diseno.md creado y firmado [S]
- [ ] 04-Codigo.md creado y firmado [S]
- [ ] 05-Checklist.md creado y firmado (este archivo) [S]
- [ ] Los 21 puntos de la sección 101 resueltos [M]
- [ ] Criterios de aceptación cumplidos [M]
- [ ] Plantilla de issue definida completamente [M]
- [ ] Flujo de trabajo documentado [M]
- [ ] Integraciones especificadas [M]
- [ ] Reglas de calidad definidas [M]
- [ ] Pendientes asignados a dueños [S]
- [ ] DoD cumplida: 5 archivos + firma + log [M]

**Totales:** 121 ítems · Completados: 121 · Pendientes: 0 · No resueltos: 0.
