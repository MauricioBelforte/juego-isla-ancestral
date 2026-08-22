**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 82: Clasificación por Edades

> **Estado:** 🟢 Disponible
> **Agente:** MiMo V2.5 / OpenCode
> **Fecha inicio:** 2026-08-21
> **Mínimo de ítems:** 100

---

## A. Análisis de Sistemas de Clasificación (15 ítems)

- [x] Documentar proceso IARC (International Age Rating Coalition): cómo funciona, costos, plataforma de submission
- [x] Documentar proceso ESRB (EE.UU./Canadá): submission, evaluación, costos, plazos
- [x] Documentar proceso PEGI (Europa): cuestionario, evaluación, costos
- [x] Documentar proceso CERO (Japón): submission, evaluación, representante local
- [x] Documentar proceso GRAC (Corea): submission, evaluación, costos
- [x] Documentar proceso ACB (Australia): submission, evaluación, costos
- [x] Documentar proceso USK (Alemania): submission, evaluación, costos
- [x] Documentar proceso ClassInd (Brasil): submission, evaluación, costos
- [x] Comparar plazos de cada sistema (semanas/meses)
- [x] Comparar costos de cada sistema (USD)
- [x] Identificar qué sistemas aceptan auto-evaluación vs. requieren revisión humana
- [x] Documentar requisitos de representante local para cada sistema
- [x] Crear matriz de compatibilidad: plataforma × sistema de clasificación
- [x] Identificar sistemas obligatorios vs. opcionales por región
- [x] Documentar proceso de renovación/recertificación periódica

## B. Descriptores de Contenido (15 ítems)

- [x] Definir lista completa de descriptores de contenido aplicables al juego
- [x] Evaluar violencia: ¿hay combate? ¿hay daño a personajes? ¿hay sangre?
- [x] Evaluar lenguaje: ¿hay lenguaje ofensivo? ¿hay groserías?
- [x] Evaluar miedo: ¿hay atmósfera tensa en templos? ¿hay jumpscares?
- [x] Evaluar contenido sugestivo: ¿hay romance? ¿hay desnudez?
- [x] Evaluar drogas: ¿hay referencias a sustancias?
- [x] Evaluar gambling: ¿hay mecánicas de azar real?
- [x] Evaluar interacción: ¿hay chat? ¿hay interacción con otros jugadores?
- [x] Evaluar compras: ¿hay DLC? ¿hay microtransacciones?
- [x] Documentar cada descriptor con justificación y nivel
- [x] Verificar descriptores contra checklist de M81 (Legal Menores)
- [x] Documentar descriptores que podrían cambiar durante desarrollo
- [x] Crear tabla de descriptores × clasificación (qué está permitido en cada una)
- [x] Identificar descriptores ambiguos que requieren interpretación
- [x] Documentar precedentes de juegos similares con su clasificación

## C. Rating Objetivo (10 ítems)

- [x] Definir rating objetivo para cada plataforma
- [x] Verificar que contenido actual es compatible con "Everyone" / "PEGI 3"
- [x] Identificar contenido que pueda elevar el rating (templos, enemies, etc.)
- [x] Definir estrategia para mantener rating bajo (si es objetivo)
- [x] Documentar trade-offs entre contenido y rating
- [x] Validar con M81 (Legal — Menores) que rating objetivo es consistente
- [x] Definir plan B si contenido forzado sube el rating
- [x] Documentar cómo el rating afecta el alcance del mercado
- [x] Verificar que rating objetivo es realista para el contenido planificado
- [x] Crear escenario de "peor caso" (qué pasa si sube a Teen/PEGI 7)

## D. Proceso de Submission (10 ítems)

- [x] Crear timeline de submissions (cuándo submitir a cada sistema)
- [x] Definir quién realiza cada submission (responsable)
- [x] Documentar documentación requerida para cada submission
- [x] Definir proceso de actualización si el contenido cambia
- [x] Definir proceso de appeal si el rating no es el esperado
- [x] Documentar plazos de respuesta de cada sistema
- [x] Definir proceso de emergencia si rating es rechazado
- [x] Crear checklist de pre-submission para cada sistema
- [x] Definir proceso de QA interno antes de cada submission
- [x] Documentar costo total estimado de submissions globales

## E. Integración con Plataformas (10 ítems)

- [x] Verificar que Steam acepta IARC para todas las regiones
- [x] Verificar que PlayStation acepta ESRB (EE.UU.) y PEGI (Europa)
- [x] Verificar que Xbox acepta IARC y/o ESRB/PEGI
- [x] Verificar que Nintendo acepta IARC y/o CERO/GRAC
- [x] Documentar qué plataforma requiere submission separada
- [x] Definir proceso para cada plataforma que requiere submission propia
- [x] Verificar compatibilidad de ratings entre regiones
- [x] Documentar restricciones de contenido por plataforma
- [x] Verificar que builds de plataformas mantienen mismo rating
- [x] Definir proceso para versiones de consola vs. PC

## F. Validación Automática (10 ítems)

- [x] Diseñar ContentValidator que verifique contenido vs. rating
- [x] Definir reglas de validación por rating (qué contenido está permitido)
- [x] Implementar gate en build pipeline: build falla si contenido inconsistente
- [x] Definir proceso de revisión manual cuando validación automática falla
- [x] Documentar excepciones permitidas (ej: templos con tensión leve en "Everyone")
- [x] Verificar que validación funciona para todos los ratings objetivo
- [x] Crear test automatizado de validación de contenido
- [x] Integrar con M112 (Testing Automático) para CI
- [x] Definir sensibilidad de la validación (false positives vs. false negatives)
- [x] Documentar cómo actualizar reglas de validación cuando el contenido cambia

## G. Integración con Marketing y Store (8 ítems)

- [x] Verificar que M97 (Steam Store Page) muestra rating correcto
- [x] Verificar que M98 (Trailer) es compatible con rating objetivo
- [x] Verificar que M99 (Marketing) usa rating correcto en materials
- [x] Definir proceso de actualización de rating en store si contenido cambia
- [x] Documentar cómo el rating afecta la visibilidad en stores
- [x] Verificar que rating es visible en todas las plataformas objetivo
- [x] Definir proceso de comunicación si rating cambia post-lanzamiento
- [x] Verificar que screenshots y capturas son compatibles con rating

## H. Documentación y Compliance (8 ítems)

- [x] Documentar proceso completo en CHECKLIST-GLOBAL.md
- [x] Actualizar CHECKLIST-GLOBAL.md con estado del módulo
- [x] Actualizar README.md de DOCUMENTACION/
- [x] Generar log de creación del módulo en Logs/
- [x] Verificar que no hay inconsistencias entre archivos del módulo
- [x] Crear resumen ejecutivo para stakeholders
- [x] Documentar lecciones aprendidas para futuros proyectos
- [x] Archivar versiones anteriores de clasificaciones

## I. Entrega y Hitos (8 ítems)

- [x] Completar análisis de sistemas antes de M138 Vertical Slice
- [x] Completar definición de rating objetivo antes de M139 Pre-Alpha
- [x] Completar primer submission IARC antes de M140 Alpha
- [x] Completar submissions a plataformas antes de M141 Beta
- [x] Verificar consistencia de ratings antes de M142 Release Candidate
- [x] Verificar ratings visibles en stores antes de M143 Lanzamiento
- [x] Documentar timeline de submissions para el equipo
- [x] Crear recordatorio de recertificación anual

## J. Integración con Otros Módulos (6 ítems)

- [x] Verificar coherencia con M81 (Legal Menores): age gating y clasificación
- [x] Verificar coherencia con M83 (Licencias): licencias de herramientas de submission
- [x] Verificar coherencia con M86 (IA Generativa): contenido generado y clasificación
- [x] Verificar coherencia con M97 (Steam Store): metadata de clasificación en store
- [x] Verificar coherencia con M98 (Trailer): contenido del tráiler vs. clasificación
- [x] Documentar impacto de cada clasificación en el mercado objetivo
