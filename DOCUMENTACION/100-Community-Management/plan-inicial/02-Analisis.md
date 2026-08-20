**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 02-Analisis.md — Módulo 100: Community Management

## 1. Análisis de los puntos del plan maestro (sección 99)

| # | Punto | Resolución |
|---|---|---|
| 1 | Crear reglas comunitarias | ✅ Reglas claras: respeto, spoilers, contenido tóxico, copyright, impersonación, expectativas realistas |
| 2 | Crear moderación | ✅ Sistema de moderación con roles (Admin, Mod, Helper), permisos, logs de acciones |
| 3 | Crear sistema de reportes | ✅ Sistema de reportes integrado en canales (Discord, Steam), categorías, workflow de revisión |
| 4 | Crear canales de feedback | ✅ Canales estructurados: bugs, sugerencias, preguntas, off-topic, anuncios |
| 5 | Crear roadmap público si conviene | ✅ Roadmap público opcional con hitos generales (sin fechas irreales) |
| 6 | Crear changelog público | ✅ Changelog público con cada actualización ( Steam, Discord, sitio web) |
| 7 | Responder dudas | ✅ Sistema de respuesta a dudas con SLA de 48 horas, base de conocimiento |
| 8 | Identificar bugs reportados | ✅ Sistema de triage de bugs reportados por comunidad, integración con M102 |
| 9 | Recopilar sugerencias | ✅ Sistema de recopilación y categorización de sugerencias, integración con M102 |
| 10 | Evitar promesas imposibles | ✅ Directriz: no prometer fechas irreales,Features, mecánicas sin confirmación |
| 11 | Gestionar expectativas | ✅ Gestión de expectativas: comunicación honesta, hitos genéricos, transparencia |
| 12 | Gestionar críticas | ✅ Gestión de críticas: distinguir constructivas de destructivas, responder a constructivas |
| 13 | Gestionar contenido tóxico | ✅ Moderación de contenido tóxico: advertencias, timeouts, bans permanentes |
| 14 | Gestionar spoilers | ✅ Etiquetado de spoilers, canales específicos, temporales para contenido nuevo |
| 15 | Gestionar filtraciones | ✅ Protocolo para filtraciones: DMCA, takedowns, comunicación con plataformas |
| 16 | Gestionar impersonación | ✅ Protocolo para impersonación: verificación oficial, etiquetas de desarrollador |
| 17 | Gestionar copyright claims | ✅ Protocolo para copyright claims en contenido de fans: fair use, directrices |

## 2. Reglas comunitarias

**Reglas fundamentales:**
- Respeto mutuo entre todos los miembros
- Sin contenido tóxico, discriminación o acoso
- Spoilers deben etiquetarse correctamente
- Contenido NSFW está prohibido
- No spam ni autopromoción excesiva
- Respetar derechos de autor (no compartir contenido pirata)
- No impersonar desarrolladores oficiales
- Expectativas realistas sobre el desarrollo
- Feedback constructivo es bienvenido

**Implementación:**
- Documento de reglas en Discord (reglas #general)
- Reglas en Steam Community Hub
- Reglas en redes sociales (Twitter/X, Reddit)
- Aceptación de reglas al unirse a Discord
- Recordatorio periódico de reglas

## 3. Sistema de moderación

**Roles de moderación:**
- **Admin:** Control total del servidor/canal, puede banear, gestionar roles
- **Mod:** Puede mutear, kickear, banear temporalmente, gestionar reportes
- **Helper:** Puede responder dudas, reportar contenido, moderar básico
- **Usuario:** Puede reportar contenido, participar en canales

**Permisos:**
- Admin: todos los permisos
- Mod: moderación, gestión de reportes, respuestas oficiales
- Helper: respuestas a dudas, reportes, moderación básica
- Usuario: solo participación y reportes

**Implementación:**
- Sistema de roles en Discord (Discord roles)
- Sistema de moderación en Steam (moderators)
- Logs de acciones de moderación (ban, mute, kick)
- Sistema de apelación para bans injustificados

## 4. Sistema de reportes

**Categorías de reportes:**
- Contenido tóxico (acoso, discriminación, spam)
- Spoilers no etiquetados
- NSFW inapropiado
- Impersonación
- Copyright infringement
- Otro (con descripción)

**Workflow de reportes:**
- Usuario reporta contenido
- Sistema notifica a moderadores
- Moderador revisa reporte
- Moderador toma acción (advertencia, mute, ban, nada)
- Sistema notifica al usuario que reportó
- Sistema notifica al usuario reportado (si aplica acción)

**Implementación:**
- Sistema de reportes en Discord (Discord mod bots)
- Sistema de reportes en Steam (report button)
- Dashboard de reportes para moderadores
- Logs de reportes y acciones

## 5. Canales de feedback

**Canales en Discord:**
- #bugs: reportar bugs y problemas técnicos
- #sugerencias: proponer ideas y mejoras
- #preguntas: dudas sobre el juego
- #off-topic: conversación general
- #anuncios: anuncios oficiales del desarrollo

**Canales en Steam:**
- Steam Community Hub - Discusiones
- Steam Community Hub - Bugs y Problemas
- Steam Community Hub - Sugerencias

**Canales en redes sociales:**
- Twitter/X: respuestas a preguntas, encuestas
- Reddit: subreddit dedicado, AMAs ocasionales

**Implementación:**
- Canales estructurados en Discord
- Pines con directrices en cada canal
- Bots para redirigir contenido a canales correctos
- Integración con M102 (Bug Tracking) para bugs reportados

## 6. Roadmap público

**Roadmap público (opcional):**
- Hitos generales sin fechas irreales
- Categorías: Core Gameplay, Content, Technical, Polish
- Estado: Completado, En desarrollo, Planeado, Futuro
- Notas: información contextual sobre cada hito

**Implementación:**
- Roadmap en sitio web del juego
- Roadmap en Steam Community Hub
- Roadmap en Discord (canal #roadmap)
- Actualización periódica (mensual o cuando haya cambios significativos)

## 7. Changelog público

**Changelog público:**
- Versiones con fechas
- Cambios por categoría: Added, Changed, Fixed, Removed
- Notas importantes por cambio
- Links a issues/problemas resueltos

**Implementación:**
- Changelog en Steam (announcements)
- Changelog en Discord (canal #changelog)
- Changelog en sitio web
- Formato estándar: Keep a Changelog
- Integración con M102 (Bug Tracking) para issues resueltos

## 8. Respuesta a dudas

**Sistema de respuesta a dudas:**
- SLA de 48 horas para respuestas
- Base de conocimiento (FAQ) documentada
- Triaje de dudas: técnicas, de diseño, generales
- Respuestas consistentes y documentadas

**Implementación:**
- FAQ en sitio web
- FAQ en Steam Community Hub
- FAQ en Discord (canal #faq)
- Sistema de etiquetas para dudas frecuentes
- Respuestas documentadas para reutilización

## 9. Identificación de bugs reportados

**Sistema de triage de bugs:**
- Bugs reportados por comunidad → triage
- Categorías: crítico, mayor, menor, trivial
- Verificación: reproducible o no reproducible
- Integración con M102 (Bug Tracking)

**Workflow:**
- Usuario reporta bug en #bugs o Steam
- Moderador o desarrollador revisa reporte
- Si es bug válido, se crea issue en M102
- Si no es bug, se explica al usuario
- Priorización según severidad

**Implementación:**
- Integración con M102 (Bug Tracking)
- Plantilla de reporte de bug
- Sistema de etiquetas para categorías
- Respuesta automática de confirmación

## 10. Recopilación de sugerencias

**Sistema de recopilación de sugerencias:**
- Sugerencias reportadas en #sugerencias o Steam
- Categorización: gameplay, UI, contenido, técnica, performance
- Evaluación: alineado con visión, factible, out of scope
- Integración con M102 (Bug Tracking) para tracking

**Workflow:**
- Usuario propone sugerencia
- Moderador o desarrollador revisa sugerencia
- Si es válida, se documenta y prioriza
- Si no es válida, se explica por qué
- Respuesta constructiva siempre

**Implementación:**
- Plantilla de sugerencia
- Sistema de etiquetas para categorías
- Tablero de sugerencias (Trello, GitHub Projects)
- Respuesta documentada para cada sugerencia

## 11. Gestión de expectativas

**Directrices de gestión de expectativas:**
- No prometer fechas irreales
- Comunicar hitos genéricos en lugar de fechas específicas
- Ser transparente sobre retrasos cuando ocurran
- Establecer expectativas realistas desde el inicio
- Comunicar cambios de dirección cuando sean necesarios

**Implementación:**
- Comunicación honesta sobre estado del desarrollo
- Roadmap con hitos genéricos (sin fechas)
- Anuncios cuando haya cambios significativos
- Respuestas a preguntas sobre fechas: "cuando esté listo" en lugar de fechas irreales

## 12. Gestión de críticas

**Gestión de críticas:**
- Distinguir entre críticas constructivas y destructivas
- Responder a críticas constructivas con agradecimiento
- Ignorar o moderar críticas destructivas (sin alimentar trolls)
- Aprender de críticas válidas
- Documentar feedback recurrente para mejora

**Implementación:**
- Directrices para moderadores sobre cómo responder
- Documentación de feedback recurrente
- Respuestas ejemplares para críticas comunes
- Sistema de escalado para críticas serias

## 13. Gestión de contenido tóxico

**Contenido tóxico:**
- Acoso, discriminación, odio, spam
- NSFW inapropiado
- Lenguaje excesivamente vulgar

**Acciones de moderación:**
- Primera ofensa: advertencia (warning)
- Segunda ofensa: mute temporal (24-48 horas)
- Tercera ofensa: ban temporal (7 días)
- Cuarta ofensa: ban permanente

**Implementación:**
- Bots de moderación automática (Discord mod bots)
- Logs de advertencias y acciones
- Sistema de apelación para bans injustificados
- Directrices claras sobre qué constituye contenido tóxico

## 14. Gestión de spoilers

**Spoilers:**
- Etiquetado obligatorio de spoilers
- Canales específicos para contenido de historia
- Temporales para contenido nuevo (ej: 30 días post-lanzamiento)
- Uso de canales ocultos para contenido muy sensible

**Implementación:**
- Etiquetas de spoiler en Discord (||texto||)
- Canales específicos (#story-spoilers)
- Reglas sobre spoilers en Steam y redes sociales
- Recordatorios temporales después de lanzamiento

## 15. Gestión de filtraciones

**Filtraciones:**
- Contenido no público (assets, builds, código)
- Información confidencial del desarrollo
- Builds de prueba o alpha

**Protocolo:**
- Eliminar contenido filtrado inmediatamente
- Contactar plataforma para takedown (DMCA si aplica)
- Investigar fuente de filtración (si es posible)
- Comunicar con comunidad que el contenido no es oficial

**Implementación:**
- Protocolo documentado para filtraciones
- Contactos de plataformas (Steam, Discord, Reddit)
- Plantillas de DMCA/takedown
- Comunicación con comunidad sobre contenido filtrado

## 16. Gestión de impersonación

**Impersonación:**
- Usuarios que pretenden ser desarrolladores oficiales
- Cuentas falsas que prometen contenido no oficial
- Scams utilizando nombre del juego

**Protocolo:**
- Verificación oficial de desarrolladores (etiquetas de verified dev)
- Reporte de cuentas de impersonación a plataformas
- Comunicación con comunidad sobre cuentas oficiales
- Ban inmediato de impersonadores en canales oficiales

**Implementación:**
- Etiquetas de verified dev en Discord
- Cuentas oficiales verificadas en Steam (developer badge)
- Listado de cuentas oficiales en sitio web
- Protocolo de reporte de impersonación

## 17. Gestión de copyright claims

**Copyright claims en contenido de fans:**
- Fan art, fan music, fan fiction
- Videos del juego (let's plays, streams)
- Mods y contenido generado por usuarios

**Directrices:**
- Fair use para contenido transformador (fan art, fan music)
- Política de contenido de fans en sitio web
- Atribución requerida para contenido de fans
- Respeto a copyright de terceros

**Implementación:**
- Política de contenido de fans documentada
- Directrices de atribución
- Sistema de reporte de infracción de copyright
- Respuesta a claims de terceros

## 18. Comunicación proactiva

**Comunicación proactiva:**
- Actualizaciones periódicas sobre estado del desarrollo
- Anuncios de hitos importantes
- Comunicación de retrasos cuando sean significativos
- AMAs ocasionales (Ask Me Anything)
- Showcases de contenido en desarrollo

**Implementación:**
- Cadencia de actualizaciones (mensual o cuando haya hitos)
- Canal #anuncios en Discord
- Anuncios en Steam Community Hub
- AMAs en Discord o Reddit (ocasionales)
- Showcases en Twitter/X o YouTube
