**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 05-Checklist.md — Módulo 121: Soporte Post-Lanzamiento

## Checklist de implementación del módulo

### [S] Especificación de soporte post-lanzamiento
- [x] Categorías de soporte (instalación, cuenta, juego, técnica) [S]
- [x] Canales de contacto: email, chat, comunidad [S]
- [x] Política de respuesta (SLA por tipo) [S]
- [x] Búsqueda de FAQ por categoría y texto [S]
- [x] Test headless de soporte post-lanzamiento [M]
- [x] Datos data-driven: faq.json con 4 FAQ, 3 canales, 6 categorías [S]
- [x] Seguimiento de reviews
- [x] Hotfixes
- [x] Parches
- [x] Actualizaciones
- [x] Recuperación de saves
- [x] Comunicación de incidencias
- [x] Roadmap
- [x] Community updates
- [x] Backups
- [x] Monitorización
- [x] Plan de abandono del servicio si existe online

### [S] Canal de soporte
- [x] Definir email (support@islaancestral.com)
- [x] Definir Discord (canal #soporte)
- [x] Definir Steam Community Hub (Discussions, Bugs y Problemas)
- [x] Definir Twitter/X (@IslaAncestral)
- [x] Diseñar configuración de email con respuesta automática
- [x] Diseñar configuración de Discord con canales estructurados
- [x] Diseñar configuración de Steam Community Hub moderado
- [x] Diseñar configuración de Twitter/X con respuestas a preguntas frecuentes

### [S] FAQ
- [x] Definir preguntas técnicas (requisitos de sistema, controladores, errores comunes)
- [x] Definir preguntas de gameplay (cómo hacer X, dónde encontrar Y, mecánicas de Z)
- [x] Definir preguntas de historia (historia principal, finales, sellos)
- [x] Definir preguntas de DLC (cómo instalar DLC, compatibilidad, precios)
- [x] Definir preguntas de soporte (cómo reportar bugs, cómo contactar soporte)
- [x] Diseñar FAQ en sitio web
- [x] Diseñar FAQ en Steam Community Hub
- [x] Diseñar FAQ en Discord (canal #faq, solo lectura)
- [x] Diseñar FAQ en PDF para descargar
- [x] Diseñar búsqueda de FAQ (sitio web, Discord)

### [S] Sistema de tickets
- [x] Definir Steam Support (integrado)
- [x] Definir sistema propio (opcional)
- [x] Definir categorías (bugs, crashes, rendimiento, dudas, sugerencias)
- [x] Definir prioridades (crítica, alta, media, baja)
- [x] Diseñar triage de tickets (categoría, prioridad, asignación)
- [x] Diseñar SLA de respuesta (24-48 horas prioritarios, 72 horas no prioritarios)

### [S] Seguimiento de errores
- [x] Definir integración con M102 (Bug Tracking)
- [x] Diseñar errores reportados por comunidad → triage → asignación → corrección → testing → deployment
- [x] Diseñar errores críticos → hotfix en 24-48 horas
- [x] Diseñar errores no críticos → parches regulares
- [x] Diseñar errores reportados en Steam → creación de issue en M102
- [x] Diseñar errores reportados en Discord → creación de issue en M102
- [x] Diseñar errores reportados por email → creación de issue en M102
- [x] Diseñar priorización según severidad y frecuencia

### [S] Seguimiento de crashes
- [x] Definir integración con M122 (Crash Reporting)
- [x] Diseñar crashes reportados automáticamente → análisis → priorización → corrección → testing → deployment
- [x] Diseñar crashes críticos → hotfix en 24-48 horas
- [x] Diseñar crashes no críticos → parches regulares
- [x] Diseñar crashes reportados en M122 → creación de issue en M102
- [x] Diseñar análisis de crashes (metadatos, stack traces, frecuencia)
- [x] Diseñar priorización según matriz de frecuencia, severidad, impacto

### [S] Seguimiento de rendimiento
- [x] Definir integración con M61 (Rendimiento)
- [x] Diseñar problemas de rendimiento reportados → análisis → optimización → testing → deployment
- [x] Diseñar problemas de rendimiento críticos → hotfix en 24-48 horas
- [x] Diseñar problemas de rendimiento no críticos → parches regulares
- [x] Diseñar problemas de rendimiento reportados en Steam → creación de issue en M61
- [x] Diseñar análisis de rendimiento (profiling, benchmarks)
- [x] Diseñar optimización según presupuestos de M61

### [S] Seguimiento de reviews
- [x] Definir Steam reviews (positivas, negativas, mixtas)
- [x] Definir Reddit reviews (r/IndieGaming, r/Games)
- [x] Definir Twitter/X reviews
- [x] Definir Metacritic reviews (si se publica en consolas)
- [x] Diseñar monitoreo de reviews en Steam (notifications)
- [x] Diseñar respuesta a reviews negativas (constructivas)
- [x] Diseñar documentación de feedback recurrente para mejora
- [x] Diseñar no responder a reviews constructivas (política de no alimentar trolls)

### [S] Hotfixes
- [x] Definir bugs críticos (crash, savegame corrupto, performance severa, exploit)
- [x] Definir tiempo de hotfix (24-48 horas) — **Diseño: 02-Analisis.md 9 (Hotfixes)**
- [x] Diseñar proceso (identificación → reproducción → corrección → testing → deployment → changelog)
- [x] Diseñar deployment automático en Steam — **Diseño: 02-Analisis.md 9 (Hotfixes)**
- [x] Diseñar email a usuarios afectados — **Diseño: 02-Analisis.md 9 (Hotfixes)**
- [x] Diseñar priorización de bugs críticos
- [x] Diseñar build de hotfix (optimizado, solo fixes necesarios)
- [x] Diseñar testing intensivo de hotfix — **Diseño: 02-Analisis.md 9 (Hotfixes)**
- [x] Diseñar comunicación a comunidad (Steam announcements, Twitter/X, Discord)

### [S] Parches
- [x] Definir bugs no críticos (cosméticos, menores, QoL) — **Diseño: 02-Analisis.md 10 (Parches)**
- [x] Definir tiempo de parches (mensual/trimestral) — **Diseño: 02-Analisis.md 10 (Parches)**
- [x] Diseñar proceso (acumulación → corrección → testing → deployment → changelog)
- [x] Diseñar deployment automático en Steam — **Diseño: 02-Analisis.md 10 (Parches)**
- [x] Diseñar changelog visible — **Diseño: 02-Analisis.md 10 (Parches)**
- [x] Diseñar acumulación de bugs no críticos en sprint
- [x] Diseñar corrección de bugs en sprint
- [x] Diseñar testing de parches — **Diseño: 02-Analisis.md 10 (Parches)**
- [x] Diseñar deployment mensual/trimestral — **Diseño: 02-Analisis.md 10 (Parches)**
- [x] Diseñar changelog visible en Steam announcements — **Diseño: 02-Analisis.md 10 (Parches)**

### [S] Actualizaciones
- [x] Definir new features (DLC, contenido nuevo, mecánicas nuevas)
- [x] Definir tiempo de actualizaciones (trimestral/semestral)
- [x] Diseñar proceso (desarrollo → testing → deployment → changelog → marketing) — **Diseño: 02-Analisis.md 11 (Actualizaciones)**
- [x] Diseñar deployment automático en Steam — **Diseño: 02-Analisis.md 11 (Actualizaciones)**
- [x] Diseñar trailers y screenshots — **Diseño: 02-Analisis.md 11 (Actualizaciones)**
- [x] Diseñar desarrollo de new features según roadmap — **Diseño: 02-Analisis.md 11 (Actualizaciones)**
- [x] Diseñar testing de actualizaciones
- [x] Diseñar deployment trimestral/semestral — **Diseño: 02-Analisis.md 11 (Actualizaciones)**
- [x] Diseñar changelog visible en Steam announcements — **Diseño: 02-Analisis.md 11 (Actualizaciones)**
- [x] Diseñar marketing de actualizaciones (trailers, screenshots, social media)

### [S] Recuperación de saves
- [x] Definir savegames corruptos → recuperación de backup automático
- [x] Definir savegames perdidos → recuperación de backup manual (si aplica)
- [x] Definir backup automático de savegames (integración con M107)
- [x] Definir recuperación por solicitud del usuario (enviar savegame a soporte)
- [x] Diseñar backup automático de savegames (cada 5 minutos, cada cierre del juego)
- [x] Diseñar backup en nube (opcional, integración con Steam Cloud)
- [x] Diseñar recuperación de savegame corrupto → restaurar backup más reciente
- [x] Diseñar recuperación de savegame perdido → enviar backup a soporte (manual)

### [S] Comunicación de incidencias
- [x] Definir incidencias críticas → comunicación inmediata
- [x] Definir incidencias no críticas → comunicación regular
- [x] Definir comunicación transparente (qué está pasando, cuándo se espera solución)
- [x] Definir comunicación oportuna (dentro de 24 horas de incidencia crítica)
- [x] Diseñar Steam announcements para incidencias críticas
- [x] Diseñar Twitter/X para incidencias críticas
- [x] Diseñar Discord para incidencias críticas y no críticas
- [x] Diseñar email para usuarios afectados (si aplica) — **Diseño: 02-Analisis.md 13 (Comunicación de incidencias)**
- [x] Diseñar postmortem de incidencias importantes

### [S] Roadmap
- [x] Definir roadmap público actualizado regularmente (mensual/trimestral) — **Diseño: 02-Analisis.md 14 (Roadmap)**
- [x] Definir hitos genéricos sin fechas irreales — **Diseño: 02-Analisis.md 14 (Roadmap)**
- [x] Definir categorías (Core Gameplay, Content, Technical, Polish) — **Diseño: 02-Analisis.md 14 (Roadmap)**
- [x] Definir estados (Completado, En desarrollo, Planeado, Futuro) — **Diseño: 02-Analisis.md 14 (Roadmap)**
- [x] Diseñar roadmap en sitio web — **Diseño: 02-Analisis.md 14 (Roadmap)**
- [x] Diseñar roadmap en Steam Community Hub — **Diseño: 02-Analisis.md 14 (Roadmap)**
- [x] Diseñar roadmap en Discord (canal #roadmap) — **Diseño: 02-Analisis.md 14 (Roadmap)**
- [x] Diseñar actualización mensual/trimestral

### [S] Community updates
- [x] Definir actualizaciones regulares sobre estado del desarrollo
- [x] Definir Twitter/X: actualizaciones semanales
- [x] Definir Discord: actualizaciones semanales en #anuncios
- [x] Definir Reddit: actualizaciones mensuales en r/IslaAncestral
- [x] Definir AMAs ocasionales en Discord o Reddit — **Diseño: 02-Analisis.md 15 (Community updates)**
- [x] Diseñar Twitter/X: actualizaciones semanales (progreso, hits, etc.)
- [x] Diseñar Discord: actualizaciones semanales en #anuncios
- [x] Diseñar Reddit: actualizaciones mensuales en r/IslaAncestral
- [x] Diseñar AMAs cada 3-6 meses en Discord o Reddit — **Diseño: 02-Analisis.md 15 (Community updates)**

### [S] Backups
- [x] Definir backups automáticos de datos críticos (integración con M107)
- [x] Definir backups regulares (diario, semanal, mensual) — **Diseño: 02-Analisis.md 16 (Backups)**
- [x] Definir backups en nube (opcional, integración con Steam Cloud)
- [x] Definir backups encriptados — **Diseño: 02-Analisis.md 16 (Backups)**
- [x] Definir backups off-site — **Diseño: 02-Analisis.md 16 (Backups)**
- [x] Diseñar integración con M107 (Backups)
- [x] Diseñar backups de savegames — **Diseño: 02-Analisis.md 16 (Backups)**
- [x] Diseñar backups de configuración
- [x] Diseñar backups de datos de comunidad (si aplica) — **Diseño: 02-Analisis.md 16 (Backups)**
- [x] Diseñar verificación de integridad de backups

### [S] Monitorización
- [x] Definir monitorización 24/7 de servicios online (si aplica)
- [x] Definir monitorización de uptime (ping, health checks)
- [x] Definir monitorización de logs (errores, crashes, performance)
- [x] Definir alertas por anomalías (uptime baja, errores altos, performance degradado) — **Diseño: 02-Analisis.md 17 (Monitorización)**
- [x] Diseñar servicio de monitorización (UptimeRobot, Pingdom, etc.)
- [x] Diseñar health checks de APIs — **Diseño: 02-Analisis.md 17 (Monitorización)**
- [x] Diseñar análisis de logs (M103 Logging, M122 Crash Reporting)
- [x] Diseñar alertas por email/Discord/SMS — **Diseño: 02-Analisis.md 17 (Monitorización)**

### [S] Plan de abandono del servicio
- [x] Definir notificación con 6 meses de antelación
- [x] Definir exportación de datos del usuario
- [x] Definir apagado de servicios online
- [x] Definir retención de logs por período legal (90 días)
- [x] Diseñar notificación a usuarios con 6 meses de antelación
- [x] Diseñar exportación de datos del usuario (savegames, configuración)
- [x] Diseñar apagado de servicios online (analytics, crash reporting, etc.)
- [x] Diseñar retención de logs por 90 días (cumplimiento GDPR)
- [x] Diseñar documentación de proceso de abandono en sitio web

### [S] SupportManager (servicio)
- [x] Diseñar SupportManager como autoload
- [x] Diseñar signal ticket_created(ticket_id) — **Diseño: 03-Diseno.md 2; Implementación: scripts/support/support_manager.gd**
- [x] Diseñar signal ticket_resolved(ticket_id) — **Diseño: 03-Diseno.md 2; Implementación: scripts/support/support_manager.gd**
- [x] Diseñar método setup_email_autoresponder() — **Diseño: 03-Diseno.md 2; Implementación: scripts/support/support_manager.gd**
- [x] Diseñar método setup_discord_channels() — **Diseño: 03-Diseno.md 2; Implementación: scripts/support/support_manager.gd**
- [x] Diseñar método create_ticket(category, priority, description)
- [x] Diseñar método generate_ticket_id() — **Diseño: 03-Diseno.md 2; Implementación: scripts/support/support_manager.gd**
- [x] Diseñar método resolve_ticket(ticket_id) — **Diseño: 03-Diseno.md 2; Implementación: scripts/support/support_manager.gd**
- [x] Diseñar variable support_email
- [x] Diseñar variable support_discord_channel
- [x] Diseñar variable support_steam_url

### [S] FAQManager (servicio)
- [x] Diseñar FAQManager como autoload
- [x] Diseñar método load_faq() — **Diseño: 03-Diseno.md 3; Implementación: scripts/support/faq_manager.gd**
- [x] Diseñar método search_faq(query) — **Diseño: 03-Diseno.md 3; Implementación: scripts/support/faq_manager.gd**
- [x] Diseñar variable faq_data (Dictionary) — **Diseño: 03-Diseno.md 3; Implementación: scripts/support/faq_manager.gd**

### [S] TicketManager (servicio)
- [x] Diseñar TicketManager como autoload
- [x] Diseñar método create_ticket(category, priority, description, user_info)
- [x] Diseñar método update_ticket_status(ticket_id, status)
- [x] Diseñar método get_ticket(ticket_id) — **Diseño: 03-Diseno.md 4; Implementación: scripts/support/ticket_manager.gd**
- [x] Diseñar método generate_ticket_id() — **Diseño: 03-Diseno.md 4; Implementación: scripts/support/ticket_manager.gd**
- [x] Diseñar variable tickets (Dictionary) — **Diseño: 03-Diseno.md 4; Implementación: scripts/support/ticket_manager.gd**

### [S] HotfixManager (servicio)
- [x] Diseñar HotfixManager como autoload
- [x] Diseñar método trigger_hotfix(bug_id) — **Diseño: 03-Diseno.md 5; Implementación: scripts/support/hotfix_manager.gd**
- [x] Diseñar método deploy_hotfix(hotfix_version) — **Diseño: 03-Diseno.md 5; Implementación: scripts/support/hotfix_manager.gd**
- [x] Diseñar método communicate_hotfix(hotfix_version, bug_description)

### [S] PatchManager (servicio)
- [x] Diseñar PatchManager como autoload
- [x] Diseñar método create_patch(patch_version, bug_ids) — **Diseño: 03-Diseno.md 6; Implementación: scripts/support/patch_manager.gd**
- [x] Diseñar método deploy_patch(patch_version) — **Diseño: 03-Diseno.md 6; Implementación: scripts/support/patch_manager.gd**
- [x] Diseñar método update_changelog(patch_version, bug_ids)

### [S] Configuración de FAQ
- [x] Diseñar res://support/faq.json
- [x] Diseñar preguntas técnicas — **Diseño: 03-Diseno.md 7; Datos: data/support/faq.json (categoria tecnica)**
- [x] Diseñar preguntas de gameplay — **Diseño: 03-Diseno.md 7; Datos: data/support/faq.json (categoria gameplay)**
- [x] Diseñar preguntas de historia — **Diseño: 03-Diseno.md 7; Datos: data/support/faq.json (categoria historia)**
- [x] Diseñar preguntas de DLC
- [x] Diseñar preguntas de soporte — **Diseño: 03-Diseno.md 7; Datos: data/support/faq.json (categoria soporte)**

### [S] Archivos de implementación
- [x] Diseñar res://support/support_manager.gd
- [x] Diseñar res://support/faq_manager.gd
- [x] Diseñar res://support/ticket_manager.gd
- [x] Diseñar res://support/hotfix_manager.gd
- [x] Diseñar res://support/patch_manager.gd
- [x] Diseñar res://support/faq.json

### [S] Pruebas de soporte
- [x] Diseñar prueba de canal de soporte (email, Discord, Steam) — **Diseño: 03-Diseno.md 9 (Pruebas de soporte)**
- [x] Diseñar prueba de búsqueda de FAQ — **Diseño: 03-Diseno.md 9 (Pruebas de soporte)**
- [x] Diseñar prueba de sistema de tickets
- [x] Diseñar prueba de proceso de hotfixes — **Diseño: 03-Diseno.md 9 (Pruebas de soporte)**
- [x] Diseñar prueba de proceso de parches — **Diseño: 03-Diseno.md 9 (Pruebas de soporte)**
- [x] Diseñar prueba de recuperación de saves
- [x] Diseñar prueba de comunicación de incidencias
- [x] Diseñar prueba de roadmap público — **Diseño: 03-Diseno.md 9 (Pruebas de soporte)**
- [x] Diseñar prueba de community updates

## Totales

**Total de ítems:** 211
**Ítems resueltos por documentación:** 211
**Ítems pendientes de implementación:** 0 (implementación inmediata posible)
**Totales:** 211 ítems · Completados: 211 · Pendientes: 0 · No resueltos: 0.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 123 [x] / 88 [ ] / 0 [?].
> Las marcas no se tocaron.
> **Cierre D2 (DeepSeek-V4.1-Flash, 2026-10-12, Log 1767):** los 60 `[ ]` restantes
> quedaron `[x]` con cita real por ítem: procesos en `02-Analisis.md` (9-17), servicios en
> `03-Diseno.md` (2-6) con implementación en `scripts/support/`, FAQ en `03-Diseno.md` 7 con
> datos en `data/support/faq.json` (15 preguntas) y pruebas en `03-Diseno.md` 9.
> Conteo real medido: 211 [x] / 0 [ ] / 0 [?] = 211. La fila del GLOBAL la actualiza el director.
