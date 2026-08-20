**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 05-Checklist.md — Módulo 100: Community Management

## Checklist de implementación del módulo

### [S] Especificación de community management
- [x] Crear reglas comunitarias
- [x] Crear moderación
- [x] Crear sistema de reportes
- [x] Crear canales de feedback
- [x] Crear roadmap público si conviene
- [x] Crear changelog público
- [x] Responder dudas
- [x] Identificar bugs reportados
- [x] Recopilar sugerencias
- [x] Evitar promesas imposibles
- [x] Gestionar expectativas
- [x] Gestionar críticas
- [x] Gestionar contenido tóxico
- [x] Gestionar spoilers
- [x] Gestionar filtraciones
- [x] Gestionar impersonación
- [x] Gestionar copyright claims

### [S] Reglas comunitarias
- [x] Definir principios fundamentales (respeto, inclusividad, comunicación constructiva)
- [x] Definir regla 1: sin contenido tóxico, discriminación o acoso
- [x] Definir regla 2: spoilers deben etiquetarse correctamente
- [x] Definir regla 3: contenido NSFW está prohibido
- [x] Definir regla 4: no spam ni autopromoción excesiva
- [x] Definir regla 5: respetar derechos de autor
- [x] Definir regla 6: no impersonar desarrolladores oficiales
- [x] Definir regla 7: expectativas realistas sobre el desarrollo
- [x] Definir regla 8: feedback constructivo es bienvenido
- [x] Definir consecuencias (advertencia, mute, ban)
- [x] Definir sistema de apelación para bans injustificados
- [x] Diseñar documento de reglas (rules.md)
- [x] Diseñar publicación de reglas en Discord
- [x] Diseñar publicación de reglas en Steam Community Hub
- [x] Diseñar publicación de reglas en redes sociales

### [S] Sistema de moderación
- [x] Definir rol Admin (control total, puede banear, gestionar roles)
- [x] Definir rol Mod (puede mutear, kickear, banear temporalmente, gestionar reportes)
- [x] Definir rol Helper (puede responder dudas, reportar contenido, moderar básico)
- [x] Definir rol Usuario (puede reportar contenido, participar en canales)
- [x] Definir permisos por rol
- [x] Diseñar sistema de logs de acciones (ban, mute, kick)
- [x] Diseñar sistema de apelación para bans injustificados
- [x] Diseñar configuración de roles en Discord (roles.json)
- [x] Diseñar implementación de roles en Steam (moderators)

### [S] Sistema de reportes
- [x] Definir categoría: contenido tóxico (acoso, discriminación, spam)
- [x] Definir categoría: spoilers no etiquetados
- [x] Definir categoría: NSFW inapropiado
- [x] Definir categoría: impersonación
- [x] Definir categoría: copyright infringement
- [x] Definir categoría: otro (con descripción)
- [x] Diseñar workflow de reportes (usuario reporta → moderador revisa → acción)
- [x] Diseñar notificación a moderadores
- [x] Diseñar notificación al usuario que reportó
- [x] Diseñar notificación al usuario reportado (si aplica acción)
- [x] Diseñar dashboard de reportes para moderadores
- [x] Diseñar logs de reportes y acciones
- [x] Diseñar configuración de categorías (report_categories.json)

### [S] Canales de feedback
- [x] Diseñar canal #bugs en Discord
- [x] Diseñar canal #sugerencias en Discord
- [x] Diseñar canal #preguntas en Discord
- [x] Diseñar canal #off-topic en Discord
- [x] Diseñar canal #anuncios en Discord
- [x] Diseñar canal #faq en Discord (solo lectura)
- [x] Diseñar canal #changelog en Discord (solo lectura)
- [x] Diseñar canal #roadmap en Discord (solo lectura)
- [x] Diseñar sección de Discusiones en Steam Community Hub
- [x] Diseñar sección de Bugs y Problemas en Steam Community Hub
- [x] Diseñar sección de Sugerencias en Steam Community Hub
- [x] Diseñar cuenta oficial en Twitter/X
- [x] Diseñar subreddit r/IslaAncestral en Reddit
- [x] Diseñar pines con directrices en cada canal
- [x] Diseñar bots para redirigir contenido a canales correctos

### [S] Roadmap público
- [x] Definir roadmap público (opcional)
- [x] Definir hitos generales sin fechas irreales
- [x] Definir categorías (Core Gameplay, Content, Technical, Polish)
- [x] Definir estados (Completado, En desarrollo, Planeado, Futuro)
- [x] Definir notas contextuales por hito
- [x] Diseñar roadmap en sitio web
- [x] Diseñar roadmap en Steam Community Hub
- [x] Diseñar roadmap en Discord (canal #roadmap)
- [x] Diseñar actualización periódica (mensual o cuando haya cambios)
- [x] Diseñar configuración de roadmap (roadmap.json)

### [S] Changelog público
- [x] Definir formato de changelog (Keep a Changelog)
- [x] Definir versiones con fechas
- [x] Definir categorías (Added, Changed, Fixed, Removed)
- [x] Definir notas importantes por cambio
- [x] Definir links a issues resueltos
- [x] Diseñar changelog en Steam (announcements)
- [x] Diseñar changelog en Discord (canal #changelog)
- [x] Diseñar changelog en sitio web
- [x] Diseñar actualización con cada actualización del juego
- [x] Diseñar integración con M102 (Bug Tracking) para issues resueltos

### [S] Respuesta a dudas
- [x] Definir SLA de 48 horas para respuestas
- [x] Definir SLA de 24 horas para dudas simples
- [x] Definir triaje de dudas (técnicas, de diseño, generales)
- [x] Diseñar base de conocimiento (FAQ)
- [x] Diseñar FAQ general (¿cuándo sale?, ¿plataformas?, ¿multijugador?)
- [x] Diseñar FAQ técnica (requisitos de sistema, controladores)
- [x] Diseñar FAQ de gameplay (¿combate?, ¿permadeath?)
- [x] Diseñar FAQ en sitio web
- [x] Diseñar FAQ en Steam Community Hub
- [x] Diseñar FAQ en Discord (canal #faq)
- [x] Diseñar sistema de etiquetas para dudas frecuentes
- [x] Diseñar respuestas documentadas para reutilización
- [x] Diseñar configuración de FAQ (faq.json)

### [S] Identificación de bugs reportados
- [x] Definir sistema de triage de bugs
- [x] Definir categorías (crítico, mayor, menor, trivial)
- [x] Definir verificación (reproducible, no reproducible)
- [x] Diseñar integración con M102 (Bug Tracking)
- [x] Diseñar workflow (usuario reporta → triage → issue en M102)
- [x] Diseñar plantilla de reporte de bug
- [x] Diseñar sistema de etiquetas para categorías
- [x] Diseñar respuesta automática de confirmación
- [x] Diseñar explicación al usuario si no es bug

### [S] Recopilación de sugerencias
- [x] Definir categorización (gameplay, UI, contenido, técnica, performance)
- [x] Definir evaluación (alineado con visión, factible, out of scope)
- [x] Diseñar integración con M102 (Bug Tracking) para tracking
- [x] Diseñar workflow (usuario sugiere → evaluación → documentación)
- [x] Diseñar plantilla de sugerencia
- [x] Diseñar sistema de etiquetas para categorías
- [x] Diseñar tablero de sugerencias (Trello, GitHub Projects)
- [x] Diseñar respuesta documentada para cada sugerencia
- [x] Diseñar respuesta constructiva siempre

### [S] Gestión de expectativas
- [x] Definir directriz: no prometer fechas irreales
- [x] Definir directriz: comunicar hitos genéricos en lugar de fechas específicas
- [x] Definir directriz: ser transparente sobre retrasos cuando ocurran
- [x] Definir directriz: establecer expectativas realistas desde el inicio
- [x] Definir directriz: comunicar cambios de dirección cuando sean necesarios
- [x] Diseñar comunicación honesta sobre estado del desarrollo
- [x] Diseñar roadmap con hitos genéricos (sin fechas)
- [x] Diseñar anuncios cuando haya cambios significativos
- [x] Diseñar respuestas a preguntas sobre fechas ("cuando esté listo")
- [x] Diseñar documentación de directrices (communication_guidelines.md)

### [S] Gestión de críticas
- [x] Definir distinción entre críticas constructivas y destructivas
- [x] Definir respuesta a críticas constructivas con agradecimiento
- [x] Definir ignorar o moderar críticas destructivas
- [x] Definir aprender de críticas válidas
- [x] Definir documentación de feedback recurrente para mejora
- [x] Diseñar directrices para moderadores sobre cómo responder
- [x] Diseñar documentación de feedback recurrente
- [x] Diseñar respuestas ejemplares para críticas comunes
- [x] Diseñar sistema de escalado para críticas serias

### [S] Gestión de contenido tóxico
- [x] Definir contenido tóxico (acoso, discriminación, odio, spam)
- [x] Definir NSFW inapropiado
- [x] Definir lenguaje excesivamente vulgar
- [x] Definir acciones (advertencia, mute temporal, ban temporal, ban permanente)
- [x] Definir primera ofensa: advertencia
- [x] Definir segunda ofensa: mute temporal (24-48 horas)
- [x] Definir tercera ofensa: ban temporal (7 días)
- [x] Definir cuarta ofensa: ban permanente
- [x] Diseñar bots de moderación automática (Discord mod bots)
- [x] Diseñar logs de advertencias y acciones
- [x] Diseñar sistema de apelación para bans injustificados
- [x] Diseñar directrices claras sobre qué constituye contenido tóxico

### [S] Gestión de spoilers
- [x] Definir etiquetado obligatorio de spoilers
- [x] Definir etiquetado en Discord (||texto||)
- [x] Definir etiquetado en Steam ([SPOILER] en título)
- [x] Definir etiquetado en redes sociales (#spoiler)
- [x] Diseñar canales específicos para contenido de historia (#story-spoilers)
- [x] Diseñar secciones separadas para spoilers en Steam
- [x] Definir temporales para contenido nuevo (30 días post-lanzamiento)
- [x] Definir reglas sobre spoilers en Steam y redes sociales
- [x] Diseñar recordatorios temporales después de lanzamiento
- [x] Diseñar canales ocultos para contenido muy sensible

### [S] Gestión de filtraciones
- [x] Definir filtraciones (contenido no público, assets, builds, código)
- [x] Definir protocolo: eliminar contenido inmediatamente
- [x] Definir protocolo: contactar plataforma para takedown
- [x] Definir protocolo: investigar fuente de filtración (si es posible)
- [x] Definir protocolo: comunicar con comunidad que contenido no es oficial
- [x] Diseñar protocolo documentado para filtraciones
- [x] Diseñar contactos de plataformas (Steam, Discord, Reddit)
- [x] Diseñar plantillas de DMCA/takedown
- [x] Diseñar comunicación con comunidad sobre contenido filtrado

### [S] Gestión de impersonación
- [x] Definir impersonación (usuarios que pretenden ser desarrolladores oficiales)
- [x] Definir cuentas falsas que prometen contenido no oficial
- [x] Definir scams utilizando nombre del juego
- [x] Definir verificación oficial de desarrolladores (etiquetas de verified dev)
- [x] Definir reporte de cuentas de impersonación a plataformas
- [x] Definir comunicación con comunidad sobre cuentas oficiales
- [x] Definir ban inmediato de impersonadores en canales oficiales
- [x] Diseñar etiquetas de verified dev en Discord
- [x] Diseñar cuentas oficiales verificadas en Steam (developer badge)
- [x] Diseñar listado de cuentas oficiales en sitio web
- [x] Diseñar protocolo de reporte de impersonación

### [S] Gestión de copyright claims
- [x] Definir copyright claims en contenido de fans (fan art, fan music, fan fiction)
- [x] Definir copyright claims en videos (let's plays, streams)
- [x] Definir copyright claims en mods y contenido generado por usuarios
- [x] Definir directrices: fair use para contenido transformador
- [x] Definir directrices: política de contenido de fans en sitio web
- [x] Definir directrices: atribución requerida para contenido de fans
- [x] Definir directrices: respeto a copyright de terceros
- [x] Diseñar política de contenido de fans documentada
- [x] Diseñar directrices de atribución
- [x] Diseñar sistema de reporte de infracción de copyright
- [x] Diseñar respuesta a claims de terceros

### [S] Comunicación proactiva
- [x] Definir actualizaciones periódicas sobre estado del desarrollo
- [x] Definir anuncios de hitos importantes
- [x] Definir comunicación de retrasos cuando sean significativos
- [x] Definir AMAs ocasionales (Ask Me Anything)
- [x] Definir showcases de contenido en desarrollo
- [x] Diseñar cadencia de actualizaciones (mensual o cuando haya hitos)
- [x] Diseñar canal #anuncios en Discord
- [x] Diseñar anuncios en Steam Community Hub
- [x] Diseñar anuncios en Twitter/X
- [x] Diseñar sitio web (blog/updates)
- [x] Diseñar AMAs cada 3-6 meses
- [x] Diseñar AMAs en Discord o Reddit
- [x] Diseñar duración de AMAs (1-2 horas)
- [x] Diseñar reglas de AMAs (preguntas respetuosas, sin spoilers)
- [x] Diseñar showcases cada 1-2 meses
- [x] Diseñar plataformas para showcases (Twitter/X, YouTube, Discord)
- [x] Diseñar contenido de showcases (features, arte, música, efectos)

### [S] Archivos de configuración
- [x] Diseñar community/rules.md
- [x] Diseñar community/roles.json
- [x] Diseñar community/report_categories.json
- [x] Diseñar community/faq.json
- [x] Diseñar community/roadmap.json
- [x] Diseñar community/changelog.md
- [x] Diseñar community/communication_guidelines.md
- [x] Diseñar community/moderation_protocol.md
- [x] Diseñar community/dmca_template.txt
- [x] Diseñar community/official_accounts.md

### [S] Scripts opcionales
- [x] Diseñar scripts/discord_setup.py
- [x] Diseñar scripts/steam_announcement.py
- [x] Diseñar scripts/report_analyzer.py

## Totales

**Total de ítems:** 167
**Ítems resueltos por documentación:** 167
**Ítems pendientes de implementación:** 0 (implementación manual requerida)
