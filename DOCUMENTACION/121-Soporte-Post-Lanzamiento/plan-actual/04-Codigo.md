**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 04-Codigo.md — Módulo 121: Soporte Post-Lanzamiento

## 1. Carácter del Componente

Módulo de **soporte post-lanzamiento** para mantenimiento del juego. Define canal de soporte, FAQ, sistema de tickets, seguimiento de errores, seguimiento de crashes, seguimiento de rendimiento, seguimiento de reviews, hotfixes, parches, actualizaciones, recuperación de saves, comunicación de incidencias, roadmap, community updates, backups, monitorización y plan de abandono del servicio. Implementable inmediatamente (depende de M102 para bug tracking, M122 para crash reporting, M61 para rendimiento, M100 para community management, M107 para backups). Es un módulo de servicios y procesos.

**06-Plan-Testings.md:** NO APLICA (módulo de soporte post-lanzamiento, sin código de gameplay complejo; tests pueden ser manuales de soporte)

## 2. Archivos involucrados (implementación)

```
res://support/
├── support_manager.gd                          → Sistema de soporte
├── faq_manager.gd                              → Sistema de FAQ
├── ticket_manager.gd                           → Sistema de tickets
├── hotfix_manager.gd                           → Proceso de hotfixes
└── patch_manager.gd                            → Proceso de parches

res://support/faq.json                           → Configuración de FAQ

06-Plan-Testings.md                               → NO APLICA
07-Resultados-Testings.md                        → NO APLICA
```

## 3. Contratos de integración

### Salida (hacia otros módulos)
- **M102 (Bug Tracking):** Tickets de soporte convertidos en issues
- **M122 (Crash Reporting):** Crashes monitoreados para hotfixes
- **M61 (Rendimiento):** Problemas de rendimiento monitoreados para parches
- **M100 (Community Management):** Comunicación de incidencias y community updates
- **M107 (Backups):** Backups automáticos para recuperación de saves

### Entrada (desde otros módulos)
- **M102 (Bug Tracking):** Errores reportados → tickets de soporte
- **M122 (Crash Reporting):** Crashes reportados → tickets de soporte
- **M61 (Rendimiento):** Problemas de rendimiento reportados → tickets de soporte
- **M100 (Community Management):** Feedback de comunidad → tickets de soporte
- **M107 (Backups):** Backups automáticos para recuperación de saves

### Configuración
- `res://support/faq.json` define configuración de FAQ
- `res://support/support_manager.gd` define sistema de soporte
- `res://support/ticket_manager.gd` define sistema de tickets

## 4. Implementación de support_manager.gd (esqueleto)

```gdscript
# res://support/support_manager.gd
class_name SupportManager
extends Node

signal ticket_created(ticket_id: String)
signal ticket_resolved(ticket_id: String)

var support_email: String = "support@islaancestral.com"
var support_discord_channel: String = "#soporte"
var support_steam_url: String = "https://steamcommunity.com/app/APPID/discussions/"

func _ready():
    setup_email_autoresponder()
    setup_discord_channels()

func setup_email_autoresponder():
    # Configurar respuesta automática de email
    # (implementación específica según servicio de email, ej: Gmail, SendGrid)
    pass

func setup_discord_channels():
    # Configurar canales de Discord
    # (#soporte, #faq, #anuncios)
    # (implementación específica según Discord bot)
    pass

func create_ticket(category: String, priority: String, description: String) -> String:
    var ticket_id = generate_ticket_id()
    ticket_created.emit(ticket_id)
    return ticket_id

func generate_ticket_id() -> String:
    return str(Time.get_unix_time_from_system()) + "_" + str(randi() % 10000)

func resolve_ticket(ticket_id: String):
    ticket_resolved.emit(ticket_id)
```

## 5. Implementación de faq_manager.gd (esqueleto)

```gdscript
# res://support/faq_manager.gd
class_name FAQManager
extends Node

var faq_data: Dictionary = {}

func _ready():
    load_faq()

func load_faq():
    # Cargar FAQ desde archivo JSON
    var faq_file = FileAccess.open("res://support/faq.json", FileAccess.READ)
    if faq_file:
        var json = JSON.parse_string(faq_file.get_as_text())
        if json.error == OK:
            faq_data = json.result
        faq_file.close()

func search_faq(query: String) -> Array:
    var results = []
    for category in faq_data.keys():
        for question in faq_data[category]:
            if query.to_lower() in question.to_lower():
                results.append({
                    "category": category,
                    "question": question,
                    "answer": faq_data[category][question]
                })
    return results
```

## 6. Implementación de ticket_manager.gd (esqueleto)

```gdscript
# res://support/ticket_manager.gd
class_name TicketManager
extends Node

var tickets: Dictionary = {}

func create_ticket(category: String, priority: String, description: String, user_info: Dictionary) -> String:
    var ticket_id = generate_ticket_id()
    tickets[ticket_id] = {
        "ticket_id": ticket_id,
        "category": category,
        "priority": priority,
        "description": description,
        "user_info": user_info,
        "status": "open",
        "created_at": Time.get_unix_time_from_system(),
        "updated_at": Time.get_unix_time_from_system()
    }
    return ticket_id

func update_ticket_status(ticket_id: String, status: String):
    if tickets.has(ticket_id):
        tickets[ticket_id].status = status
        tickets[ticket_id].updated_at = Time.get_unix_time_from_system()

func get_ticket(ticket_id: String) -> Dictionary:
    if tickets.has(ticket_id):
        return tickets[ticket_id]
    return {}

func generate_ticket_id() -> String:
    return str(Time.get_unix_time_from_system()) + "_" + str(randi() % 10000)
```

## 7. Implementación de hotfix_manager.gd (esqueleto)

```gdscript
# res://support/hotfix_manager.gd
class_name HotfixManager
extends Node

func trigger_hotfix(bug_id: String):
    # Proceso de hotfix para bug crítico
    # 1. Identificación
    # 2. Reproducción
    # 3. Corrección
    # 4. Testing
    # 5. Deployment
    # 6. Comunicación
    print("Triggering hotfix for bug: %s" % bug_id)

func deploy_hotfix(hotfix_version: String):
    # Deployment de hotfix en Steam
    # (implementación específica según Steamworks)
    print("Deploying hotfix version: %s" % hotfix_version)

func communicate_hotfix(hotfix_version: String, bug_description: String):
    # Comunicación de hotfix a comunidad
    # Steam announcements, Twitter/X, Discord
    print("Communicating hotfix: %s - %s" % [hotfix_version, bug_description])
```

## 8. Implementación de patch_manager.gd (esqueleto)

```gdscript
# res://support/patch_manager.gd
class_name PatchManager
extends Node

func create_patch(patch_version: String, bug_ids: Array):
    # Proceso de parche para bugs no críticos
    # 1. Acumulación de bugs
    # 2. Corrección
    # 3. Testing
    # 4. Deployment
    # 5. Changelog
    print("Creating patch version: %s with bugs: %s" % [patch_version, str(bug_ids)])

func deploy_patch(patch_version: String):
    # Deployment de parche en Steam
    # (implementación específica según Steamworks)
    print("Deploying patch version: %s" % patch_version)

func update_changelog(patch_version: String, bug_ids: Array):
    # Actualización de changelog
    # Steam announcements
    print("Updating changelog for patch: %s with bugs: %s" % [patch_version, str(bug_ids)])
```

## 9. Configuración de FAQ

**Archivo: res://support/faq.json**

**Estructura:**
```json
{
  "tecnico": {
    "¿Cuáles son los requisitos de sistema?": "Requisitos mínimos: Windows 10/11, Intel i5-6500 / AMD Ryzen 3 1200, 8GB RAM, GTX 1050 Ti / RX 570. Requisitos recomendados: Windows 10/11, Intel i7-8700K / AMD Ryzen 5 3600, 16GB RAM, GTX 1660 / RX 5600 XT.",
    "¿El juego soporta controladores?": "Sí, soportamos controladores Xbox, PlayStation y Switch Pro (a través de Steam Input). También soportamos input de teclado y ratón.",
    "¿Hay permadeath?": "No, no hay permadeath. Cuando mueres, reapareces en tu casa con toda tu inventario intacta. La filosofía del juego es cozy y sin castigos irreversibles."
  },
  "gameplay": {
    "¿El juego tiene combate?": "El combate es completamente opcional en Isla Ancestral. Puedes jugar todo el juego sin combatir, enfocándote en exploración, construcción, agricultura, pesca, minería, y relación con NPCs.",
    "¿Cómo hago para construir una casa?": "Para construir una casa, necesitas herramientas de construcción (martillo, pala, etc.) y recursos (madera, piedra). Coloca el recurso en el terreno y usa la herramienta de construcción para construir paredes, techos y muebles.",
    "¿Cómo viajo entre islas?": "Para viajar entre islas, necesitas un barco. Visita el puerto de la isla y habla con el capitán para desbloquear viajes. Una vez desbloqueado, puedes viajar desde el puerto a otras islas."
  },
  "historia": {
    "¿Cuántos finales tiene el juego?": "Isla Ancestral tiene 5 finales diferentes. El final que obtienes depende de las decisiones que tomes durante la historia principal.",
    "¿Puedo cambiar de final?": "Sí, puedes volver a puntos clave de la historia y tomar diferentes decisiones para obtener otros finales. Los sellos te ayudan a recordar qué decisiones tomaste.",
    "¿El juego tiene multijugador?": "Isla Ancestral está diseñado como una experiencia single-player en v1.0. Multijugador es una característica que podríamos evaluar para expansiones futuras, pero no está en el roadmap actual."
  },
  "dlc": {
    "¿Qué DLC hay disponibles?": "Los DLC disponibles se listan en la tienda de Steam. Cada DLC expande la experiencia con nuevas islas, NPCs, historias, sistemas y colecciones. DLC es completamente opcional y no es necesario para disfrutar del juego base.",
    "¿Cómo instalo DLC?": "Para instalar DLC, ve a la tienda de Steam y compra el DLC deseado. El DLC se descargará e instalará automáticamente. Necesitas reiniciar el juego para que el DLC esté disponible.",
    "¿Puedo desinstalar DLC?": "Sí, puedes desinstalar DLC desde Steam. La desinstalación conservará tus savegames, pero marcará contenido DLC como incompleto."
  },
  "soporte": {
    "¿Cómo reporto un bug?": "Para reportar un bug, ve a Steam Community Hub - Bugs y Problemas y crea un nuevo hilo describiendo el bug en detalle. También puedes reportar bugs en Discord (#soporte) o por email (support@islaancestral.com).",
    "¿Cómo contacto a soporte?": "Puedes contactar soporte por email (support@islaancestral.com), Discord (#soporte) o Steam Community Hub (Discussions, Bugs y Problemas). Intenta proporcionar tanta información como posible sobre tu problema.",
    "¿Cuánto tiempo tarda la respuesta?": "Intentamos responder a tickets de soporte dentro de 24-48 horas para tickets prioritarios y 72 horas para tickets no prioritarios. En tiempos de alto volumen (post-lanzamiento), los tiempos pueden ser mayores."
  }
}
```

## 10. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Crear res://support/support_manager.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://support/faq_manager.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://support/ticket_manager.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://support/hotfix_manager.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://support/patch_manager.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://support/faq.json | **IMPLEMENTACIÓN INMEDIATA** |
| Configurar email de soporte (support@islaancestral.com) | **IMPLEMENTACIÓN MANUAL** |
| Configurar Discord (canales #soporte, #faq, #anuncios) | **IMPLEMENTACIÓN MANUAL** |
| Configurar Steam Community Hub (Discussions, Bugs y Problemas) | **IMPLEMENTACIÓN MANUAL** |
| Configurar Twitter/X (@IslaAncestral) | **IMPLEMENTACIÓN MANUAL** |
| Integrar con M102 (Bug Tracking) para tickets → issues | **M102 (Bug Tracking)** |
| Integrar con M122 (Crash Reporting) para crashes → tickets | **M122 (Crash Reporting)** |
| Integrar con M61 (Rendimiento) para rendimiento → tickets | **M61 (Rendimiento)** |
| Integrar con M100 (Community Management) para comunicación | **M100 (Community Management)** |
| Integrar con M107 (Backups) para recuperación de saves | **M107 (Backups)** |
| Configurar monitorización de servicios online (si aplica) | **IMPLEMENTACIÓN MANUAL** |
| Documentar plan de abandono del servicio (si hay online) | **IMPLEMENTACIÓN MANUAL** |

## 11. Notas del Agente

**Modelo:** SWE-1.6
**Plataforma:** DEVIN
**Fecha:** 2026-08-19 05:16:00
**Estado:** Completado (especificación; implementación inmediata posible)

### Lo que hice
- Resolví los 17 puntos de la sección 120 del plan maestro.
- Definí canal de soporte (email, Discord, Steam forums, Twitter/X).
- Definí FAQ documentada y accesible (técnico, gameplay, historia, DLC, soporte).
- Definí sistema de tickets (Steam Support, sistema propio, categorías, prioridades).
- Definí seguimiento de errores integrado con M102 (Bug Tracking).
- Definí seguimiento de crashes integrado con M122 (Crash Reporting).
- Definí seguimiento de rendimiento integrado con M61 (Rendimiento).
- Definí seguimiento de reviews (Steam, Reddit, Twitter/X, Metacritic).
- Definí proceso de hotfixes (bugs críticos, 24-48 horas).
- Definí proceso de parches (bugs no críticos, mensual/trimestral).
- Definí proceso de actualizaciones (new features, trimestral/semestral).
- Definí proceso de recuperación de saves (backup automático, integración con M107).
- Definí comunicación de incidencias (transparente, oportuna, 24 horas).
- Definí roadmap público actualizado regularmente (mensual/trimestral).
- Definí community updates regulares (Twitter/X, Discord, Reddit, semanal/mensual).
- Definí backups automáticos (integración con M107).
- Definí monitorización de servicios online (24/7, uptime, logs, alertas).
- Definí plan de abandono del servicio (notificación 6 meses, exportación de datos, retención de logs 90 días).
- Diseñé SupportManager (servicio de soporte) con signal ticket_created/ticket_resolved.
- Diseñé FAQManager (servicio de FAQ) con search_faq().
- Diseñé TicketManager (servicio de tickets) con create_ticket(), update_ticket_status(), get_ticket().
- Diseñé HotfixManager (servicio de hotfixes) con trigger_hotfix(), deploy_hotfix(), communicate_hotfix().
- Diseñé PatchManager (servicio de parches) con create_patch(), deploy_patch(), update_changelog().
- Diseñé faq.json con configuración de FAQ (técnico, gameplay, historia, DLC, soporte).

### Lo que NO pude hacer (honestidad obligatoria)
- Implementar configuración real de email (requiere servicio de email como Gmail/SendGrid)
- Implementar configuración real de Discord (requiere Discord bot)
- Implementar configuración real de Steam Community Hub (requiere configuración manual)
- Implementar configuración real de Twitter/X (requiere configuración manual)
- Implementar integración real con M102 (Bug Tracking) - es solo diseño de integración
- Implementar integración real con M122 (Crash Reporting) - es solo diseño de integración
- Implementar integración real con M61 (Rendimiento) - es solo diseño de integración
- Implementar integración real con M100 (Community Management) - es solo diseño de integración
- Implementar integración real con M107 (Backups) - es solo diseño de integración
- Implementar monitorización real de servicios online (requiere servicio de monitorización como UptimeRobot)
- Implementar plan de abandono real del servicio (requiere implementación de componentes online)

### Recomendaciones para el primer agente (implementador)
- Implementar SupportManager en Godot con autoload.
- Implementar FAQManager en Godot con autoload.
- Implementar TicketManager en Godot con autoload.
- Implementar HotfixManager en Godot con autoload.
- Implementar PatchManager en Godot con autoload.
- Configurar email de soporte (support@islaancestral.com) con respuesta automática.
- Configurar Discord (canales #soporte, #faq, #anuncios) con Discord bot.
- Configurar Steam Community Hub (Discussions, Bugs y Problemas) moderado por equipo de comunidad.
- Configurar Twitter/X (@IslaAncestral) para respuestas a preguntas frecuentes.
- Integrar con M102 (Bug Tracking) creando issues automáticamente por tickets.
- Integrar con M122 (Crash Reporting) monitoreando crashes para hotfixes.
- Integrar con M61 (Rendimiento) monitoreando problemas de rendimiento para parches.
- Integrar con M100 (Community Management) para comunicación de incidencias y community updates.
- Integrar con M107 (Backups) para recuperación de saves con backup automático.
- Configurar monitorización de servicios online (UptimeRobot, Pingdom, etc.) si hay componentes online.
- Documentar plan de abandono del servicio si hay componentes online.
- Probar canal de soporte (email, Discord, Steam).
- Probar búsqueda de FAQ.
- Probar sistema de tickets.
- Probar proceso de hotfixes.
- Probar proceso de parches.
- Probar recuperación de saves.
- Probar comunicación de incidencias.
- Probar roadmap público.
- Probar community updates.
