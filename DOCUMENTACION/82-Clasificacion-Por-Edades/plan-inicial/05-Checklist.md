**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 82: Clasificación por Edades

> **Estado:** 🔵 En curso
> **Agente:** Nemotron 3 Ultra / OpenCode
> **Fecha inicio:** 2026-08-21
> **Mínimo de ítems:** 100

---

## A. Análisis de Sistemas de Clasificación

- [ ] Documentar proceso IARC (International Age Rating Coalition): cómo funciona, costos, plataforma de submission
- [ ] Documentar proceso ESRB (EE.UU./Canadá): submission, evaluación, costos, plazos
- [ ] Documentar proceso PEGI (Europa): cuestionario, evaluación, costos
- [ ] Documentar proceso CERO (Japón): submission, evaluación, representante local
- [ ] Documentar proceso GRAC (Corea): submission, evaluación, costos
- [ ] Documentar proceso ACB (Australia): submission, evaluación, costos
- [ ] Documentar proceso USK (Alemania): submission, evaluación, costos
- [ ] Documentar proceso ClassInd (Brasil): submission, evaluación, costos
- [ ] Comparar plazos de cada sistema (semanas/meses)
- [ ] Comparar costos de cada sistema (USD)

## B. Descriptores de Contenido

- [ ] Definir lista completa de descriptores de contenido aplicables al juego
- [ ] Evaluar violencia: ¿hay combate? ¿hay daño a personajes? ¿hay sangre?
- [ ] Evaluar lenguaje: ¿hay lenguaje ofensivo? ¿hay groserías?
- [ ] Evaluar miedo: ¿hay atmósfera tensa en templos? ¿hay jumpscares?
- [ ] Evaluar contenido sugestivo: ¿hay romance? ¿hay desnudez?
- [ ] Evaluar drogas: ¿hay referencias a sustancias?
- [ ] Evaluar gambling: ¿hay mecánicas de azar real?
- [ ] Evaluar interacción: ¿hay chat? ¿hay interacción con otros jugadores?
- [ ] Evaluar compras: ¿hay DLC? ¿hay microtransacciones?
- [ ] Documentar cada descriptor con justificación y nivel

## C. Rating Objetivo

- [ ] Definir rating objetivo para cada plataforma
- [ ] Verificar que contenido actual es compatible con "Everyone" / "PEGI 3"
- [ ] Identificar contenido que pueda elevar el rating (templos, enemies, etc.)
- [ ] Definir estrategia para mantener rating bajo (si es objetivo)
- [ ] Documentar trade-offs entre contenido y rating
- [ ] Validar con M81 (Legal — Menores) que rating objetivo es consistente

## D. Proceso de Submission

- [ ] Crear timeline de submissions (cuándo submitir a cada sistema)
- [ ] Definir quién realiza cada submission (responsable)
- [ ] Documentar documentación requerida para cada submission
- [ ] Definir proceso de actualización si el contenido cambia
- [ ] Definir proceso de appeal si el rating no es el esperado
- [ ] Documentar plazos de respuesta de cada sistema
- [ ] Definir proceso de emergencia si rating es rechazado

## E. Integración con Plataformas

- [ ] Verificar que Steam acepta IARC para todas las regiones
- [ ] Verificar que PlayStation acepta ESRB (EE.UU.) y PEGI (Europa)
- [ ] Verificar que Xbox acepta IARC y/o ESRB/PEGI
- [ ] Verificar que Nintendo acepta IARC y/o CERO/GRAC
- [ ] Documentar qué plataforma requiere submission separada
- [ ] Definir proceso para cada plataforma que requiere submission propia
- [ ] Verificar compatibilidad de ratings entre regiones

## F. Validación Automática

- [ ] Diseñar ContentValidator que verifique contenido vs. rating
- [ ] Definir reglas de validación por rating (qué contenido está permitido)
- [ ] Implementar gate en build pipeline: build falla si contenido inconsistente
- [ ] Definir proceso de revisión manual cuando validación automática falla
- [ ] Documentar excepciones permitidas (ej: templos con tensión leve en "Everyone")
- [ ] Verificar que validación funciona para todos los ratings objetivo

## G. Integración con Marketing y Store

- [ ] Verificar que M97 (Steam Store Page) muestra rating correcto
- [ ] Verificar que M98 (Trailer) es compatible con rating objetivo
- [ ] Verificar que M99 (Marketing) usa rating correcto en materials
- [ ] Definir proceso de actualización de rating en store si contenido cambia
- [ ] Documentar cómo el rating afecta la visibilidad en stores
- [ ] Verificar que rating es visible en todas las plataformas objetivo

## H. Documentación y Compliance

- [ ] Documentar proceso completo en CHECKLIST-GLOBAL.md
- [ ] Actualizar CHECKLIST-GLOBAL.md con estado del módulo
- [ ] Actualizar README.md de DOCUMENTACION/
- [ ] Generar log de creación del módulo en Logs/
- [ ] Verificar que no hay inconsistencias entre archivos del módulo

## I. Entrega y Hitos

- [ ] Completar análisis de sistemas antes de M138 Vertical Slice
- [ ] Completar definición de rating objetivo antes de M139 Pre-Alpha
- [ ] Completar primer submission IARC antes de M140 Alpha
- [ ] Completar submissions a plataformas antes de M141 Beta
- [ ] Verificar consistencia de ratings antes de M142 Release Candidate
- [ ] Verificar ratings visibles en stores antes de M143 Lanzamiento