**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 82: Clasificación por Edades

> **Estado:** ?? Disponible
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
- [ ] Comparar plazos de cada sistema (semanas/meses)
- [ ] Comparar costos de cada sistema (USD)
- [ ] Identificar qué sistemas aceptan auto-evaluación vs. requieren revisión humana
- [x] Documentar requisitos de representante local para cada sistema
- [ ] Crear matriz de compatibilidad: plataforma × sistema de clasificación
- [ ] Identificar sistemas obligatorios vs. opcionales por región
- [x] Documentar proceso de renovación/recertificación periódica

## B. Descriptores de Contenido (15 ítems)

- [x] Definir lista completa de descriptores de contenido aplicables al juego
- [ ] Evaluar violencia: ¿hay combate? ¿hay daño a personajes? ¿hay sangre?
- [ ] Evaluar lenguaje: ¿hay lenguaje ofensivo? ¿hay groserías?
- [ ] Evaluar miedo: ¿hay atmósfera tensa en templos? ¿hay jumpscares?
- [ ] Evaluar contenido sugestivo: ¿hay romance? ¿hay desnudez?
- [ ] Evaluar drogas: ¿hay referencias a sustancias?
- [ ] Evaluar gambling: ¿hay mecánicas de azar real?
- [ ] Evaluar interacción: ¿hay chat? ¿hay interacción con otros jugadores?
- [ ] Evaluar compras: ¿hay DLC? ¿hay microtransacciones?
- [x] Documentar cada descriptor con justificación y nivel
- [x] Verificar descriptores contra checklist de M81 (Legal Menores)
- [x] Documentar descriptores que podrían cambiar durante desarrollo
- [x] Crear tabla de descriptores × clasificación (qué está permitido en cada una)
- [x] Identificar descriptores ambiguos que requieren interpretación
- [x] Documentar precedentes de juegos similares con su clasificación

## C. Rating Objetivo (10 ítems)

- [x] Definir rating objetivo para cada plataforma
- [ ] Verificar que contenido actual es compatible con "Everyone" / "PEGI 3"
- [x] Identificar contenido que pueda elevar el rating (templos, enemies, etc.)
- [x] Definir estrategia para mantener rating bajo (si es objetivo)
- [x] Documentar trade-offs entre contenido y rating
- [x] Validar con M81 (Legal — Menores) que rating objetivo es consistente
- [x] Definir plan B si contenido forzado sube el rating
- [x] Documentar cómo el rating afecta el alcance del mercado
- [x] Verificar que rating objetivo es realista para el contenido planificado
- [ ] Crear escenario de "peor caso" (qué pasa si sube a Teen/PEGI 7)

## D. Proceso de Submission (10 ítems)

- [ ] Crear timeline de submissions (cuándo submitir a cada sistema)
- [ ] Definir quién realiza cada submission (responsable)
- [x] Documentar documentación requerida para cada submission
- [ ] Definir proceso de actualización si el contenido cambia
- [x] Definir proceso de appeal si el rating no es el esperado
- [x] Documentar plazos de respuesta de cada sistema
- [x] Definir proceso de emergencia si rating es rechazado
- [x] Crear checklist de pre-submission para cada sistema
- [ ] Definir proceso de QA interno antes de cada submission
- [x] Documentar costo total estimado de submissions globales

## E. Integración con Plataformas (10 ítems)

- [x] Verificar que Steam acepta IARC para todas las regiones
- [x] Verificar que PlayStation acepta ESRB (EE.UU.) y PEGI (Europa)
- [x] Verificar que Xbox acepta IARC y/o ESRB/PEGI
- [x] Verificar que Nintendo acepta IARC y/o CERO/GRAC
- [x] Documentar qué plataforma requiere submission separada
- [ ] Definir proceso para cada plataforma que requiere submission propia
- [x] Verificar compatibilidad de ratings entre regiones
- [x] Documentar restricciones de contenido por plataforma
- [x] Verificar que builds de plataformas mantienen mismo rating
- [ ] Definir proceso para versiones de consola vs. PC

## F. Validación Automática (10 ítems)

- [x] Diseñar ContentValidator que verifique contenido vs. rating
- [x] Definir reglas de validación por rating (qué contenido está permitido)
- [x] Implementar gate en build pipeline: build falla si contenido inconsistente
- [ ] Definir proceso de revisión manual cuando validación automática falla
- [x] Documentar excepciones permitidas (ej: templos con tensión leve en "Everyone")
- [x] Verificar que validación funciona para todos los ratings objetivo
- [x] Crear test automatizado de validación de contenido
- [x] Integrar con M112 (Testing Automático) para CI
- [ ] Definir sensibilidad de la validación (false positives vs. false negatives)
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
- [ ] Generar log de creación del módulo en Logs/
- [ ] Verificar que no hay inconsistencias entre archivos del módulo
- [ ] Crear resumen ejecutivo para stakeholders
- [x] Documentar lecciones aprendidas para futuros proyectos
- [ ] Archivar versiones anteriores de clasificaciones

## I. Entrega y Hitos (8 ítems)

- [ ] Completar análisis de sistemas antes de M138 Vertical Slice
- [x] Completar definición de rating objetivo antes de M139 Pre-Alpha
- [x] Completar primer submission IARC antes de M140 Alpha
- [ ] Completar submissions a plataformas antes de M141 Beta
- [x] Verificar consistencia de ratings antes de M142 Release Candidate
- [x] Verificar ratings visibles en stores antes de M143 Lanzamiento
- [x] Documentar timeline de submissions para el equipo
- [x] Crear recordatorio de recertificación anual

## J. Integración con Otros Módulos (6 ítems)

- [ ] Verificar coherencia con M81 (Legal Menores): age gating y clasificación
- [ ] Verificar coherencia con M83 (Licencias): licencias de herramientas de submission
- [ ] Verificar coherencia con M86 (IA Generativa): contenido generado y clasificación
- [ ] Verificar coherencia con M97 (Steam Store): metadata de clasificación en store
- [ ] Verificar coherencia con M98 (Trailer): contenido del tráiler vs. clasificación
- [x] Documentar impacto de cada clasificación en el mercado objetivo

## Verificación QA Cruzado — Hy3 / Kilo Code (2026-09-02)

**Modelo:** Hy3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02
**Rol:** QA cruzado (AGENTS.md §21.8) — validación / detección de bugs

### Resultado de test (headless, Godot 4.7.2-stable)
- godot --headless -s res://scripts/legal/test_rating_m82.gd -> **9 checks, 0 fallos** (exit 0) ✅

### Artefactos verificados
- data/legal/clasificacion.json — carga y estructura validada por el test.
- scripts/legal/RatingValidator.gd — alidar()/
eporte() detectan datos corruptos.
- scripts/legal/test_rating_m82.gd — ejecuta sin errores, sin regresiones con M60 (66/0 OK).

### Hallazgo honesto (brecha de implementación)
El módulo se liberó como "núcleo iter. 1" con JSON + Validator + Test.
- Autoload de servicio del plan: **NO mencionado** en la liberación (Log 423-431); igual que M125-M131, solo existe JSON+Validator+Test. Verificar/implementar en pasada futura si el plan lo exige.
El checklist de producto (espec. completa) permanece sin marcar: la capa de validación de datos SÍ está verificada; la capa de servicio/docs puede faltar según el plan.

### Veredicto QA
- DoD de la *capa de validación de datos*: **CUMPLIDO** (código existe, compila, tests 0 fallos, sin regresiones).
- Producto completo según plan: revisar con dueño.
- Estado recomendado: **🟡 Con dudas** (scaffold de validación verificado; pendiente capa de servicio/docs si aplica).

**Firma:** Hy3 / Kilo Code — 2026-09-02
