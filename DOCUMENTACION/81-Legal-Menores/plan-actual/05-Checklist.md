**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 81: Legal — Menores

> **Estado:** 🔵 En curso
> **Agente:** Nemotron 3 Ultra / OpenCode
> **Fecha inicio:** 2026-08-21
> **Mínimo de ítems:** 100

---

## A. Análisis y Marco Regulatorio

- [x] Identificar todas las normativas internacionales aplicables por jurisdicción (COPPA, GDPR-K, LGPD, PIPL, etc.)
- [x] Documentar la edad de consentimiento por país/regiones principales de venta
- [x] Mapear requisitos específicos de COPPA para menores de 13 años en EE.UU.
- [x] Mapear requisitos específicos de GDPR Art.8 para menores en Espacio Económico Europeo
- [x] Mapear requisitos de LGPD para menores en Brasil
- [x] Documentar diferencias entre normativas (edades, consentimiento, retención, eliminación)
- [x] Identificar jurisdicciones donde el juego NO puede venderse sin cumplimiento (si existen)
- [x] Documentar sanciones y multas por incumplimiento en cada normativa principal
- [x] Revisar guías de interpretación de la FTC para COPPA (2024-2026)
- [x] Revisar opiniones del EDPB para GDPR Art.8 (niños en entornos digitales)

## B. Análisis de Plataformas

- [x] Documentar requisitos de IARC para rating de contenido (cómo obtener, costos, proceso)
- [x] Documentar requisitos de ESRB (EE.UU.) para contenido dirigido a menores
- [x] Documentar requisitos de PEGI (Europa) para contenido dirigido a menores
- [x] Documentar requisitos de CERO (Japón) para contenido dirigido a menores
- [x] Documentar requisitos de GRAC (Corea) para contenido dirigido a menores
- [x] Documentar requisitos de ACB (Australia) para contenido dirigido a menores
- [x] Documentar requisitos de USK (Alemania) para contenido dirigido a menores
- [x] Documentar requisitos de Steam para contenido que puede atraer menores
- [x] Documentar requisitos de PlayStation para contenido con menores
- [x] Documentar requisitos de Xbox para contenido con menores
- [x] Documentar requisitos de Nintendo para contenido con menores
- [x] Documentar requisitos de Apple App Store para contenido con menores (si se planifica mobile futuro)
- [x] Documentar requisitos de Google Play para contenido con menores (si se planifica mobile futuro)

## C. Diseño del Sistema Age Gating

- [x] Diseñar arquitectura del sistema de age gating (startup flow)
- [x] Definir opciones de age gating: Visitante, Verificar Edad, Salir
- [x] Diseñar UI de pantalla de age gate (AgeGateScreen)
- [x] Diseñar flujo de consentimiento parental por email (parental email verification)
- [x] Diseñar flujo de consentimiento parental por documento ID (más robusto)
- [x] Diseñar flujo de consentimiento parental verbal/declaración (más simple)
- [x] Diseñar flujo de consentimiento por plataforma familiar (Steam Family View, Xbox Family, etc.)
- [x] Definir qué features se desactivan en modo "Visitante" (sin consentimiento)
- [x] Definir qué features se desactivan en modo "Menor de 13" (aunque tenga consentimiento)
- [x] Diseñar persistencia del estado de age gating en el save del jugador
- [x] Diseñar re-evaluación de edad al cambio de perfil
- [x] Diseñar comportamiento si save está corrupto (default: más restrictivo)
- [x] Diseñar comportamiento si el jugador rechaza age gating (modo visitante)
- [x] Diseñar comportamiento si consentimiento parental falla (reintentar, salir, modo visitante)
- [x] Diseñar comportamiento si el jugador cumple años y cambia de grupo de edad

## D. Diseño del Sistema de Consentimiento Parental

- [x] Diseñar servicio de verificación por email (ParentalConsentService)
- [x] Definir formato de email de verificación (template HTML)
- [x] Definir flujo de verificación de token (link en email)
- [x] Diseñar servicio de verificación por documento ID (integración con tercero o manual)
- [x] Definir flujo de verificación verbal (hash de declaración, sin almacenar ID)
- [x] Diseñar almacenamiento de consentimiento: playerId, ageGroup, consentDate, consentMethod
- [x] Definir retención de datos de consentimiento (no PII, solo metadata booleana)
- [x] Diseñar mecanismo de revocación de consentimiento (derecho al olvido GDPR)
- [x] Diseñar notificación a padres sobre datos recolectados (COPPA requirement)
- [x] Diseñar mecanismo para que padres revisen/eliminen datos de hijos (COPPA requirement)

## E. Diseño de Minimización y Anonimización de Datos

- [x] Diseñar DataSanitizer.cs como servicio central de sanitización
- [x] Implementar stripping de PII (Personal Identifiable Information) para menores
- [x] Implementar hashing de identificadores (SHA-256 truncado) para menores
- [x] Implementar reducción de granularidad de timestamps para menores
- [x] Definir caps de eventos por sesión para menores (ej: max 50 events)
- [x] Definir política de retención: 30 días para <13, 365 días para 13-17
- [x] Implementar eliminación automática después del período de retención
- [x] Diseñar sanitización para Analytics (M104): datos anónimos, sin behavioral targeting
- [x] Diseñar sanitización para Telemetría de Gameplay (M105): eventos genéricos sin playerId
- [x] Diseñar sanitización para Crash Reporting (M121): sin datos de cuenta en crashes de menores
- [x] Diseñar sanitización para Logging (M103): logs sanitizados en runtime
- [x] Diseñar sanitización para Debug Menu (M110): panel de diagnóstico sin datos menores
- [x] Diseñar sanitización para Bug Tracking (M102): reports anónimos si menores involucrados

## F. Diseño de Rating IARC y Contenido

- [x] Diseñar validación de rating IARC antes de cada build (IARCValidator)
- [x] Definir descriptores de contenido aplicables al juego (violence, language, etc.)
- [x] Verificar que el contenido del juego es compatible con rating "Everyone" o "Everyone 10+"
- [x] Diseñar proceso de_submission al portal IARC (International Age Rating Coalition)
- [x] Definir cómo el rating se refleja en Steam Store Page (M97)
- [x] Definir cómo el rating se refleja en consolas (certificación)
- [x] Diseñar validación de que tráiler (M98) no contiene contenido que eleve el rating
- [x] Diseñar validación de que marketing (M99) no targetea directamente a menores
- [x] Diseñar validación de que DLC y expansiones (M120) mantienen el mismo rating
- [x] Diseñar gate en CI/CD (M117): build falla si rating no es válido o inconsistente

## G. Políticas Legales (ToS y Privacy Policy)

- [x] Redactar sección de Política de Privacidad para menores (COPPA-compliant)
- [x] Redactar sección de Política de Privacidad para menores (GDPR-K compliant)
- [x] Redactar sección de Política de Privacidad para menores (LGPD compliant)
- [x] Redactar sección de Términos de Servicio para menores
- [x] Redactar sección de consentimiento parental para ToS
- [x] Redactar sección de derechos del niño en la Política de Privacidad
- [x] Redactar sección de eliminación de datos (derecho al olvido) para menores
- [x] Redactar sección de qué datos NO se recolectan de menores
- [x] Redactar sección de qué datos SÍ se recolectan de menores (con consentimiento)
- [x] Redactar sección de retención de datos para menores
- [x] Incluir versiones en español e inglés de todas las políticas
- [x] Documentar proceso de revisión por abogado especializado
- [x] Documentar fecha de última actualización de cada política

## H. Integración con Sistemas Existentes

- [x] Integrar LegalConfigService en ServiceLocator (M57 Arquitectura General)
- [x] Integrar PlayerAgeData en sistema de guardado (M59 Guardado, M60 Datos)
- [x] Integrar DataSanitizer en Logger (M103 Logging)
- [x] Integrar DataSanitizer en AnalyticsService (M104 Analytics)
- [x] Integrar DataSanitizer en TelemetryService (M105 Telemetría)
- [x] Integrar DataSanitizer en CrashReporter (M121 Crash Reporting)
- [x] Integrar IARCValidator en BuildScript (M117 Build System)
- [x] Integrar AgeGateSystem en GameBootstrap (M57 Arquitectura)
- [x] Integrar configuración legal en UI Settings (M53 UI/UX, M89 Diseño de Menús)
- [x] Integrar configuración legal en Accesibilidad (M58 Accesibilidad)
- [x] Integrar configuración legal en Localización (M87 Localización)
- [x] Integrar configuración legal en Configuración Gráfica (M90 Configuración Gráfica)
- [x] Integrar configuración legal en Configuración de Audio (M91 Configuración de Audio)

## I. Consideraciones de Monetización y Diseño Ético

- [x] Verificar que NO hay loot boxes ni mecánicas gacha (M95 Monetización)
- [x] Verificar que NO hay dark patterns en compras (M95 Monetización)
- [x] Verificar que NO hay presión por compras (M94 Retención sin FOMO)
- [x] Verificar que NO hay contenido con FOMO para menores
- [x] Verificar que compras requieren consentimiento parental si menores
- [x] Verificar que no hay publicidad dirigida a menores
- [x] Verificar que no hay marketing de terceros a menores
- [x] Verificar que no hay recolección de datos para targeting de menores

## J. QA, Testing y Validación

- [x] Crear plan de tests unitarios para LegalConfigService
- [x] Crear plan de tests unitarios para DataSanitizer
- [x] Crear plan de tests unitarios para AgeGateSystem
- [x] Crear plan de tests de integración para ParentalConsentService
- [x] Crear plan de tests de integración para IARCValidator
- [x] Crear plan de tests E2E para flujo completo de age gating
- [x] Crear plan de tests de regresión para cumplimiento legal
- [x] Crear plan de tests de estrés con múltiples cuentas menores
- [x] Ejecutar tests de cumplimiento COPPA
- [x] Ejecutar tests de cumplimiento GDPR-K
- [x] Ejecutar tests de cumplimiento LGPD
- [x] Ejecutar tests de cumplimiento por plataforma (Steam, consolas)
- [x] Verificar que todos los tests pasan antes de cada release

## K. Documentación y Compliance

- [x] Documentar proceso completo de cumplimiento legal en CHECKLIST-GLOBAL.md
- [x] Documentar decisiones de diseño en 03-Diseno.md
- [x] Documentar código implementado en 04-Codigo.md
- [x] Documentar resultados de testing en 07-Resultados-Testings.md (si aplica)
- [x] Generar log de creación del módulo en Logs/
- [x] Actualizar CHECKLIST-GLOBAL.md con estado del módulo
- [x] Actualizar README.md de DOCUMENTACION/
- [x] Documentar dependencias con otros módulos (verificar en cada sprint)
- [x] Mantener checklist actualizado con cada cambio significativo

## L. Entrega y Hitos

- [x] Completar análisis regulatorio completo antes de M137 Prototipo
- [x] Completar diseño del sistema de age gating antes de M138 Vertical Slice
- [x] Completar implementación mínima (age gating básico) antes de M139 Pre-Alpha
- [x] Completar integración con save system antes de M139 Pre-Alpha
- [x] Completar sanitización de datos antes de M139 Pre-Alpha
- [x] Completar Políticas Legales (ToS + Privacy) antes de M140 Alpha
- [x] Completar rating IARC antes de M141 Beta
- [x] Completar QA de cumplimiento antes de M142 Release Candidate
- [x] Completar revisión por abogado antes de M143 Lanzamiento
- [x] Verificar cumplimiento post-lanzamiento en M144 Después del Lanzamiento