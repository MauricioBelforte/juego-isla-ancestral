**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 03-Diseno.md — Módulo 121: Soporte Post-Lanzamiento

## 1. Arquitectura del módulo

```
Soporte Post-Lanzamiento (sistema de mantenimiento del juego)
├── Canal de soporte
│   ├── Email (support@islaancestral.com)
│   ├── Discord (canal #soporte)
│   ├── Steam Community Hub (Discussions, Bugs y Problemas)
│   └── Twitter/X (@IslaAncestral)
├── FAQ
│   ├── Preguntas técnicas
│   ├── Preguntas de gameplay
│   ├── Preguntas de historia
│   ├── Preguntas de DLC
│   └── Preguntas de soporte
├── Sistema de tickets
│   ├── Steam Support (integrado)
│   ├── Sistema propio (opcional)
│   ├── Categorías (bugs, crashes, rendimiento, dudas, sugerencias)
│   └── Prioridades (crítica, alta, media, baja)
├── Seguimiento de errores
│   ├── Integración con M102 (Bug Tracking)
│   ├── Errores reportados por comunidad
│   ├── Triaje de errores
│   ├── Priorización según severidad y frecuencia
│   └── Corrección → testing → deployment
├── Seguimiento de crashes
│   ├── Integración con M122 (Crash Reporting)
│   ├── Crashes reportados automáticamente
│   ├── Análisis de crashes
│   ├── Priorización según matriz de frecuencia, severidad, impacto
│   └── Corrección → testing → deployment
├── Seguimiento de rendimiento
│   ├── Integración with M61 (Rendimiento)
│   ├── Problemas de rendimiento reportados
│   ├── Análisis de rendimiento (profiling, benchmarks)
│   ├── Optimización según presupuestos de M61
│   └── Corrección → testing → deployment
├── Seguimiento de reviews
│   ├── Steam reviews
│   ├── Reddit reviews
│   ├── Twitter/X reviews
│   └── Metacritic reviews
├── Hotfixes
│   ├── Bugs críticos (crash, savegame corrupto, performance severa)
│   ├── Tiempo: 24-48 horas
│   ├── Proceso: identificación → reproducción → corrección → testing → deployment
│   └── Deployment automático en Steam
├── Parches
│   ├── Bugs no críticos (cosméticos, menores, QoL)
│   ├── Tiempo: mensual/trimestral
│   ├── Proceso: acumulación → corrección → testing → deployment
│   └── Deployment mensual/trimestral
├── Actualizaciones
│   ├── New features (DLC, contenido nuevo, mecánicas nuevas)
│   ├── Tiempo: trimestral/semestral
│   ├── Proceso: desarrollo → testing → deployment → changelog → marketing
│   └── Deployment trimestral/semestral
├── Recuperación de saves
│   ├── Backup automático de savegames (integración con M107)
│   ├── Recuperación de savegame corrupto
│   ├── Recuperación de savegame perdido
│   └── Recuperación por solicitud del usuario
├── Comunicación de incidencias
│   ├── Incidencias críticas: comunicación inmediata
│   ├── Incidencias no críticas: comunicación regular
│   ├── Comunicación transparente
│   └── Comunicación oportuna (24 horas)
├── Roadmap
│   ├── Roadmap público actualizado regularmente
│   ├── Hitos genéricos sin fechas irreales
│   ├── Categorías (Core Gameplay, Content, Technical, Polish)
│   └── Estados (Completado, En desarrollo, Planeado, Futuro)
├── Community updates
│   ├── Twitter/X: actualizaciones semanales
│   ├── Discord: actualizaciones semanales en #anuncios
│   ├── Reddit: actualizaciones mensuales
│   └── AMAs ocasionales (cada 3-6 meses)
├── Backups
│   ├── Backups automáticos (integración con M107)
│   ├── Backups regulares (diario, semanal, mensual)
│   ├── Backups en nube (opcional)
│   ├── Backups encriptados
│   └── Backups off-site
├── Monitorización
│   ├── Monitorización 24/7 de servicios online
│   ├── Monitorización de uptime (ping, health checks)
│   ├── Monitorización de logs (errores, crashes, performance)
│   └── Alertas por anomalías
└── Plan de abandono del servicio
    ├── Notificación con 6 meses de antelación
    ├── Exportación de datos del usuario
    ├── Apagado de servicios online
    ├── Retención de logs por período legal (90 días)
    └── Documentación de proceso de abandono
```

## 2. Sistema de soporte

**Archivo: res://support/support_manager.gd**

**Estructura:**
```gdscript
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
    # (implementación específica según servicio de email)
    pass

func setup_discord_channels():
    # Configurar canales de Discord
    # (#soporte, #faq, #anuncios)
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

## 3. Sistema de FAQ

**Archivo: res://support/faq_manager.gd**

**Estructura:**
```gdscript
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

## 4. Sistema de tickets

**Archivo: res://support/ticket_manager.gd**

**Estructura:**
```gdscript
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

## 5. Proceso de hotfixes

**Archivo: res://support/hotfix_manager.gd**

**Estructura:**
```gdscript
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
    pass

func deploy_hotfix(hotfix_version: String):
    # Deployment de hotfix en Steam
    # (implementación específica según Steamworks)
    pass

func communicate_hotfix(hotfix_version: String, bug_description: String):
    # Comunicación de hotfix a comunidad
    # Steam announcements, Twitter/X, Discord
    pass
```

## 6. Proceso de parches

**Archivo: res://support/patch_manager.gd**

**Estructura:**
```gdscript
class_name PatchManager
extends Node

func create_patch(patch_version: String, bug_ids: Array):
    # Proceso de parche para bugs no críticos
    # 1. Acumulación de bugs
    # 2. Corrección
    # 3. Testing
    # 4. Deployment
    # 5. Changelog
    pass

func deploy_patch(patch_version: String):
    # Deployment de parche en Steam
    # (implementación específica según Steamworks)
    pass

func update_changelog(patch_version: String, bug_ids: Array):
    # Actualización de changelog
    # Steam announcements
    pass
```

## 7. Configuración de FAQ

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

## 8. Diagrama de flujo de soporte

```
[Usuario reporta problema]
    ↓
[Usuario elige canal de soporte]
    ↓
[Ticket creado (automático o manual)]
    ↓
[Triage de ticket (categoría, prioridad)]
    ↓
[Assignación de ticket]
    ↓
[Investigación del problema]
    ↓
[Problema resuelto?]
    ↓ No
[Escalado a desarrolladores]
    ↓
[Desarrolladores corrigen problema]
    ↓
[Testing de corrección]
    ↓
[Deployment (hotfix/patch/actualización)]
    ↓
[Comunicación a usuario]
    ↓
[Ticket resuelto]
```

## 9. Pruebas de soporte

**Pruebas manuales:**
- Probar canal de soporte (email, Discord, Steam)
- Probar búsqueda de FAQ
- Probar sistema de tickets
- Probar proceso de hotfixes
- Probar proceso de parches
- Probar recuperación de saves
- Probar comunicación de incidencias
- Probar roadmap público
- Probar community updates

**Pruebas automáticas:**
- Tests de integración con M102 (Bug Tracking)
- Tests de integración con M122 (Crash Reporting)
- Tests de integración con M61 (Rendimiento)
- Tests de integración con M107 (Backups)
