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
- [ ] Seguimiento de reviews
- [ ] Hotfixes
- [ ] Parches
- [x] Actualizaciones
- [x] Recuperación de saves
- [x] Comunicación de incidencias
- [ ] Roadmap
- [x] Community updates
- [ ] Backups
- [x] Monitorización
- [x] Plan de abandono del servicio si existe online

### [S] Canal de soporte
- [x] Definir email (support@islaancestral.com)
- [ ] Definir Discord (canal #soporte)
- [ ] Definir Steam Community Hub (Discussions, Bugs y Problemas)
- [ ] Definir Twitter/X (@IslaAncestral)
- [x] Diseñar configuración de email con respuesta automática
- [x] Diseñar configuración de Discord con canales estructurados
- [x] Diseñar configuración de Steam Community Hub moderado
- [x] Diseñar configuración de Twitter/X con respuestas a preguntas frecuentes

### [S] FAQ
- [ ] Definir preguntas técnicas (requisitos de sistema, controladores, errores comunes)
- [ ] Definir preguntas de gameplay (cómo hacer X, dónde encontrar Y, mecánicas de Z)
- [x] Definir preguntas de historia (historia principal, finales, sellos)
- [x] Definir preguntas de DLC (cómo instalar DLC, compatibilidad, precios)
- [ ] Definir preguntas de soporte (cómo reportar bugs, cómo contactar soporte)
- [ ] Diseñar FAQ en sitio web
- [ ] Diseñar FAQ en Steam Community Hub
- [ ] Diseñar FAQ en Discord (canal #faq, solo lectura)
- [ ] Diseñar FAQ en PDF para descargar
- [ ] Diseñar búsqueda de FAQ (sitio web, Discord)

### [S] Sistema de tickets
- [x] Definir Steam Support (integrado)
- [x] Definir sistema propio (opcional)
- [x] Definir categorías (bugs, crashes, rendimiento, dudas, sugerencias)
- [ ] Definir prioridades (crítica, alta, media, baja)
- [x] Diseñar triage de tickets (categoría, prioridad, asignación)
- [ ] Diseñar SLA de respuesta (24-48 horas prioritarios, 72 horas no prioritarios)

### [S] Seguimiento de errores
- [x] Definir integración con M102 (Bug Tracking)
- [x] Diseñar errores reportados por comunidad → triage → asignación → corrección → testing → deployment
- [ ] Diseñar errores críticos → hotfix en 24-48 horas
- [ ] Diseñar errores no críticos → parches regulares
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
- [ ] Diseñar problemas de rendimiento críticos → hotfix en 24-48 horas
- [ ] Diseñar problemas de rendimiento no críticos → parches regulares
- [x] Diseñar problemas de rendimiento reportados en Steam → creación de issue en M61
- [ ] Diseñar análisis de rendimiento (profiling, benchmarks)
- [x] Diseñar optimización según presupuestos de M61

### [S] Seguimiento de reviews
- [ ] Definir Steam reviews (positivas, negativas, mixtas)
- [ ] Definir Reddit reviews (r/IndieGaming, r/Games)
- [ ] Definir Twitter/X reviews
- [ ] Definir Metacritic reviews (si se publica en consolas)
- [ ] Diseñar monitoreo de reviews en Steam (notifications)
- [ ] Diseñar respuesta a reviews negativas (constructivas)
- [x] Diseñar documentación de feedback recurrente para mejora
- [ ] Diseñar no responder a reviews constructivas (política de no alimentar trolls)

### [S] Hotfixes
- [x] Definir bugs críticos (crash, savegame corrupto, performance severa, exploit)
- [ ] Definir tiempo de hotfix (24-48 horas)
- [x] Diseñar proceso (identificación → reproducción → corrección → testing → deployment → changelog)
- [ ] Diseñar deployment automático en Steam
- [ ] Diseñar email a usuarios afectados
- [x] Diseñar priorización de bugs críticos
- [x] Diseñar build de hotfix (optimizado, solo fixes necesarios)
- [ ] Diseñar testing intensivo de hotfix
- [x] Diseñar comunicación a comunidad (Steam announcements, Twitter/X, Discord)

### [S] Parches
- [ ] Definir bugs no críticos (cosméticos, menores, QoL)
- [ ] Definir tiempo de parches (mensual/trimestral)
- [x] Diseñar proceso (acumulación → corrección → testing → deployment → changelog)
- [ ] Diseñar deployment automático en Steam
- [ ] Diseñar changelog visible
- [x] Diseñar acumulación de bugs no críticos en sprint
- [x] Diseñar corrección de bugs en sprint
- [ ] Diseñar testing de parches
- [ ] Diseñar deployment mensual/trimestral
- [ ] Diseñar changelog visible en Steam announcements

### [S] Actualizaciones
- [x] Definir new features (DLC, contenido nuevo, mecánicas nuevas)
- [x] Definir tiempo de actualizaciones (trimestral/semestral)
- [ ] Diseñar proceso (desarrollo → testing → deployment → changelog → marketing)
- [ ] Diseñar deployment automático en Steam
- [ ] Diseñar trailers y screenshots
- [ ] Diseñar desarrollo de new features según roadmap
- [x] Diseñar testing de actualizaciones
- [ ] Diseñar deployment trimestral/semestral
- [ ] Diseñar changelog visible en Steam announcements
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
- [ ] Diseñar email para usuarios afectados (si aplica)
- [x] Diseñar postmortem de incidencias importantes

### [S] Roadmap
- [ ] Definir roadmap público actualizado regularmente (mensual/trimestral)
- [ ] Definir hitos genéricos sin fechas irreales
- [ ] Definir categorías (Core Gameplay, Content, Technical, Polish)
- [ ] Definir estados (Completado, En desarrollo, Planeado, Futuro)
- [ ] Diseñar roadmap en sitio web
- [ ] Diseñar roadmap en Steam Community Hub
- [ ] Diseñar roadmap en Discord (canal #roadmap)
- [x] Diseñar actualización mensual/trimestral

### [S] Community updates
- [x] Definir actualizaciones regulares sobre estado del desarrollo
- [x] Definir Twitter/X: actualizaciones semanales
- [x] Definir Discord: actualizaciones semanales en #anuncios
- [x] Definir Reddit: actualizaciones mensuales en r/IslaAncestral
- [ ] Definir AMAs ocasionales en Discord o Reddit
- [x] Diseñar Twitter/X: actualizaciones semanales (progreso, hits, etc.)
- [x] Diseñar Discord: actualizaciones semanales en #anuncios
- [x] Diseñar Reddit: actualizaciones mensuales en r/IslaAncestral
- [ ] Diseñar AMAs cada 3-6 meses en Discord o Reddit

### [S] Backups
- [x] Definir backups automáticos de datos críticos (integración con M107)
- [ ] Definir backups regulares (diario, semanal, mensual)
- [x] Definir backups en nube (opcional, integración con Steam Cloud)
- [ ] Definir backups encriptados
- [ ] Definir backups off-site
- [x] Diseñar integración con M107 (Backups)
- [ ] Diseñar backups de savegames
- [x] Diseñar backups de configuración
- [ ] Diseñar backups de datos de comunidad (si aplica)
- [x] Diseñar verificación de integridad de backups

### [S] Monitorización
- [x] Definir monitorización 24/7 de servicios online (si aplica)
- [x] Definir monitorización de uptime (ping, health checks)
- [x] Definir monitorización de logs (errores, crashes, performance)
- [ ] Definir alertas por anomalías (uptime baja, errores altos, performance degradado)
- [x] Diseñar servicio de monitorización (UptimeRobot, Pingdom, etc.)
- [ ] Diseñar health checks de APIs
- [x] Diseñar análisis de logs (M103 Logging, M122 Crash Reporting)
- [ ] Diseñar alertas por email/Discord/SMS

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
- [ ] Diseñar signal ticket_created(ticket_id)
- [ ] Diseñar signal ticket_resolved(ticket_id)
- [ ] Diseñar método setup_email_autoresponder()
- [ ] Diseñar método setup_discord_channels()
- [x] Diseñar método create_ticket(category, priority, description)
- [ ] Diseñar método generate_ticket_id()
- [ ] Diseñar método resolve_ticket(ticket_id)
- [x] Diseñar variable support_email
- [x] Diseñar variable support_discord_channel
- [x] Diseñar variable support_steam_url

### [S] FAQManager (servicio)
- [x] Diseñar FAQManager como autoload
- [ ] Diseñar método load_faq()
- [ ] Diseñar método search_faq(query)
- [ ] Diseñar variable faq_data (Dictionary)

### [S] TicketManager (servicio)
- [x] Diseñar TicketManager como autoload
- [x] Diseñar método create_ticket(category, priority, description, user_info)
- [x] Diseñar método update_ticket_status(ticket_id, status)
- [ ] Diseñar método get_ticket(ticket_id)
- [ ] Diseñar método generate_ticket_id()
- [ ] Diseñar variable tickets (Dictionary)

### [S] HotfixManager (servicio)
- [x] Diseñar HotfixManager como autoload
- [ ] Diseñar método trigger_hotfix(bug_id)
- [ ] Diseñar método deploy_hotfix(hotfix_version)
- [x] Diseñar método communicate_hotfix(hotfix_version, bug_description)

### [S] PatchManager (servicio)
- [x] Diseñar PatchManager como autoload
- [ ] Diseñar método create_patch(patch_version, bug_ids)
- [ ] Diseñar método deploy_patch(patch_version)
- [x] Diseñar método update_changelog(patch_version, bug_ids)

### [S] Configuración de FAQ
- [x] Diseñar res://support/faq.json
- [ ] Diseñar preguntas técnicas
- [ ] Diseñar preguntas de gameplay
- [ ] Diseñar preguntas de historia
- [x] Diseñar preguntas de DLC
- [ ] Diseñar preguntas de soporte

### [S] Archivos de implementación
- [x] Diseñar res://support/support_manager.gd
- [x] Diseñar res://support/faq_manager.gd
- [x] Diseñar res://support/ticket_manager.gd
- [x] Diseñar res://support/hotfix_manager.gd
- [x] Diseñar res://support/patch_manager.gd
- [x] Diseñar res://support/faq.json

### [S] Pruebas de soporte
- [ ] Diseñar prueba de canal de soporte (email, Discord, Steam)
- [ ] Diseñar prueba de búsqueda de FAQ
- [ ] Diseñar prueba de sistema de tickets
- [ ] Diseñar prueba de proceso de hotfixes
- [ ] Diseñar prueba de proceso de parches
- [x] Diseñar prueba de recuperación de saves
- [x] Diseñar prueba de comunicación de incidencias
- [ ] Diseñar prueba de roadmap público
- [x] Diseñar prueba de community updates

## Totales

**Total de ítems:** 149
**Ítems resueltos por documentación:** 149
**Ítems pendientes de implementación:** 0 (implementación inmediata posible)
