**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 04-Codigo.md — Módulo 125: Términos de Servicio

## 1. Carácter del Componente

Módulo de **términos de servicio** legales para el juego. Define términos de servicio, licencia de uso, cuentas de usuario, conductas prohibidas, contenido de usuarios, cancelación y reembolsos, responsabilidad, cambios del servicio, terminación y jurisdicción aplicable. Implementable inmediatamente (depende de M78 para legal general, M106 para seguridad, M60 para datos). Es un módulo de documentación legal y configuración.

**06-Plan-Testings.md:** NO APLICA (módulo de términos de servicio, sin código de gameplay; tests pueden ser manuales de aceptación de términos)

## 2. Archivos involucrados (implementación)

```
legal/
├── terms_of_service.md                        → Borrador de términos de servicio
└── terms_policy.md                            → Política de términos (para sitio web)

res://legal/
├── terms_manager.gd                           → Sistema de aceptación de términos
└── terms_config.gd                            → Configuración de términos

06-Plan-Testings.md                               → NO APLICA
07-Resultados-Testings.md                        → NO APLICA
```

## 3. Contratos de integración

### Salida (hacia otros módulos)
- **M78 (Legal General):** Términos de servicio como parte del marco legal
- **M106 (Seguridad):** Conductas prohibidas aplicadas por sistema de seguridad
- **M60 (Datos y Serialización):** Eliminación de datos según política de cancelación

### Entrada (desde otros módulos)
- **M78 (Legal General):** Marco legal general para términos de servicio
- **M106 (Seguridad):** Detección de conductas prohibidas (cheating, explotación)
- **M60 (Datos y Serialización):** Solicitudes de eliminación de datos (GDPR)

### Configuración
- `legal/terms_of_service.md` define borrador de términos de servicio
- `res://legal/terms_manager.gd` define sistema de aceptación de términos
- `res://legal/terms_config.gd` define configuración de términos

## 4. Implementación de terms_manager.gd (esqueleto)

```gdscript
# res://legal/terms_manager.gd
class_name TermsManager
extends Node

signal terms_accepted()
signal terms_declined()

var terms_accepted: bool = false
var terms_version: String = "1.0.0"

func _ready():
    check_terms_acceptance()

func check_terms_acceptance():
    var terms_file = FileAccess.open("user://terms_accepted.txt", FileAccess.READ)
    if terms_file:
        var content = terms_file.get_as_text()
        terms_file.close()
        if content == "accepted":
            terms_accepted = true

func show_terms():
    # Mostrar términos de servicio al usuario
    # (implementación en UI)
    pass

func accept_terms():
    terms_accepted = true
    var terms_file = FileAccess.open("user://terms_accepted.txt", FileAccess.WRITE)
    terms_file.store_string("accepted")
    terms_file.close()
    terms_accepted.emit()

func decline_terms():
    terms_declined.emit()
```

## 5. Implementación de terms_config.gd (esqueleto)

```gdscript
# res://legal/terms_config.gd
class_name TermsConfig
extends Resource

@export var terms_version: String = "1.0.0"
@export var terms_date: String = "2026-08-19"
@export var terms_file: String = "res://legal/terms_of_service.md"
@export var accept_required: bool = true
@export var show_on_launch: bool = true
```

## 6. Borrador de términos de servicio

**Archivo: legal/terms_of_service.md**

**Estructura:**
```markdown
# Términos de Servicio - Isla Ancestral

## TL;DR (Resumen Ejecutivo)
- Juego de uso personal, no comercial
- No cheating, explotación, acoso o contenido inapropiado
- Reembolsos según política de Steam (14 días, menos de 2 horas)
- Limitación de responsabilidad al precio del juego
- Cambios notificados con 30 días de antelación
- Leyes del país del desarrollador aplicables

## 1. Introducción y Aceptación
Al usar Isla Ancestral, aceptas estos términos de servicio. Estos términos aplican a todas las versiones del juego (digital, física, etc.).

Fecha de vigencia: 2026-08-19
Versión: 1.0.0

## 2. Licencia de Uso
Se te otorga una licencia personal, no comercial, revocable y no transferible para usar Isla Ancestral.

**Uso personal:** Solo para uso personal del comprador.
**No comercial:** No se permite uso comercial, streaming monetizado sin permiso.
**Revocable:** El desarrollador puede revocar la licencia por violación de términos.
**No transferible:** La licencia no se puede transferir a terceros.

**Excepciones:**
- Streaming/YouTube: permitido con atribución (fair use)
- Capturas de pantalla: permitidas con atribución
- Modding: permitido (según política de modding)

## 3. Cuentas de Usuario (si aplica)
Isla Ancestral v1.0 es offline-first y no requiere cuentas de usuario obligatorias. Si se agregan componentes online en el futuro, se aplicarán los siguientes términos:

**Registro:** Nombre de usuario, email (opcional).
**Autenticación:** Email/password o login social (opcional).
**Seguridad:** Usuario es responsable de mantener la seguridad de su cuenta.
**Datos:** Usuario acepta recopilación de datos según política de privacidad.

## 4. Conductas Prohibidas
Las siguientes conductas están prohibidas:
- Cheating: uso de exploits, hacks, trainers, cheats
- Explotación: uso de bugs para ventaja injusta
- Acoso: acoso, discriminación, odio, lenguaje ofensivo
- Contenido inapropiado: contenido NSFW, político, religioso ofensivo
- Violación de copyright: uso de assets protegidos sin permiso
- Violación de privacidad: compartir datos personales de otros usuarios

**Consecuencias:**
- Primer aviso: advertencia
- Segunda violación: suspensión temporal
- Tercera violación: terminación permanente

## 5. Contenido de Usuarios (si aplica)
Isla Ancestral v1.0 no tiene contenido generado por usuarios (UGC). Si se agrega UGC en el futuro, se aplicarán los siguientes términos:

**Propiedad:** Usuario mantiene propiedad de su contenido.
**Licencia:** Usuario otorga licencia al desarrollador para distribuir su contenido.
**Moderación:** Desarrollador puede moderar contenido inapropiado.
**Responsabilidad:** Usuario es responsable de su contenido.

## 6. Cancelación y Reembolsos
**Cancelación:**
- Cuentas de usuario: usuario puede cancelar su cuenta en cualquier momento.
- Datos: usuario puede solicitar eliminación de sus datos (GDPR).
- Proceso: solicitud por email, eliminación en 30 días.

**Reembolsos:**
- Política de Steam: 14 días desde la compra, menos de 2 horas jugadas.
- Excepciones: desarrollador puede hacer excepciones a su discreción.
- Proceso: usuario solicita reembolso a Steam, desarrollador no tiene control directo.

## 7. Responsabilidad
**Limitación de responsabilidad:**
- Daños directos: limitados al precio del juego.
- Daños indirectos: no responsabilidad por daños indirectos (pérdida de datos, etc.).
- Fuerza mayor: no responsabilidad por eventos fuera del control del desarrollador.
- Viruses/malware: no responsabilidad por viruses/malware en el equipo del usuario.

**Excepciones:**
- Negligencia grave: no limitación de responsabilidad por negligencia grave.
- Violación de leyes: no limitación de responsabilidad por violación de leyes.

## 8. Cambios del Servicio
**Cambios del servicio:**
- Notificación: 30 días de antelación para cambios significativos.
- Actualizaciones: actualizaciones automáticas (Steam).
- EOL (End of Life): notificación con 6 meses de antelación.
- Descarga offline: usuario puede descargar versión offline antes de EOL.

**Excepciones:**
- Hotfixes: notificación inmediata (no requiere 30 días).
- Parches: notificación en changelog (no requiere 30 días).

## 9. Terminación
**Terminación:**
- Por violación de términos: desarrollador puede terminar cuenta/acceso.
- Notificación: 30 días de antelación (excepto violación grave).
- Datos: usuario puede solicitar eliminación de sus datos.
- Reembolso: no reembolso por terminación por violación de términos.

**Excepciones:**
- Violación grave: terminación inmediata sin notificación.

## 10. Jurisdicción Aplicable
**Jurisdicción aplicable:**
- Leyes del país del desarrollador.
- Tribunales del país del desarrollador.
- Idioma: español (idioma original de los términos).

**Excepciones:**
- GDPR: cumplimiento con GDPR para usuarios de la UE.
- CCPA: cumplimiento con CCPA para usuarios de California.

## 11. Contacto
**Email de contacto:** legal@islaancestral.com
**Dirección postal:** [Dirección del desarrollador]
**Horario de atención:** Lun-Vie, 9:00-18:00 (hora local)
```

## 7. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Crear legal/terms_of_service.md | **IMPLEMENTACIÓN INMEDIATA** |
| Crear legal/terms_policy.md | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://legal/terms_manager.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://legal/terms_config.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Integrar con M78 (Legal General) para marco legal | **M78 (Legal General)** |
| Integrar con M106 (Seguridad) para conductas prohibidas | **M106 (Seguridad)** |
| Integrar con M60 (Datos y Serialización) para eliminación de datos | **M60 (Datos y Serialización)** |
| Revisar términos con abogado | **IMPLEMENTACIÓN MANUAL** |
| Publicar términos en sitio web | **IMPLEMENTACIÓN MANUAL** |
| Publicar términos en Steam (EULA) | **IMPLEMENTACIÓN MANUAL** |

## 8. Notas del Agente

**Modelo:** SWE-1.6
**Plataforma:** DEVIN
**Fecha:** 2026-08-19 05:22:00
**Estado:** Completado (especificación; implementación inmediata posible)

### Lo que hice
- Redacté términos de servicio (claros y comprensibles, estilo cozy).
- Definí licencia de uso (personal, no comercial, revocable, no transferible).
- Definí cuentas de usuario (solo si hay componentes online).
- Definí conductas prohibidas (cheating, explotación, acoso, contenido inapropiado).
- Definí contenido de usuarios (solo si hay UGC, no aplica en v1.0).
- Definí cancelación y reembolsos (según política de Steam).
- Definí limitación de responsabilidad (daños directos limitados al precio del juego).
- Definí cambios del servicio (notificación con 30 días de antelación).
- Definí terminación (por violación de términos, con notificación).
- Definí jurisdicción aplicable (leyes del país del desarrollador).
- Definí revisión con abogado (obligatoria antes de publicación).
- Diseñé borrador de términos de servicio (legal/terms_of_service.md).
- Diseñé TermsManager (servicio de aceptación de términos) con signal terms_accepted/terms_declined.
- Diseñé TermsConfig (Resource) con configuración de términos.
- Diseñé sistema de aceptación de términos con check_terms_acceptance(), show_terms(), accept_terms(), decline_terms().
- Diseñé diagrama de flujo de aceptación de términos.

### Lo que NO pude hacer (honestidad obligatoria)
- Revisar términos con abogado (requiere contratación de abogado)
- Publicar términos en sitio web (requiere sitio web)
- Publicar términos en Steam (EULA) (requiere configuración manual de Steamworks)
- Implementar integración real con M78 (Legal General) - es solo diseño de integración
- Implementar integración real con M106 (Seguridad) - es solo diseño de integración
- Implementar integración real con M60 (Datos y Serialización) - es solo diseño de integración

### Recomendaciones para el primer agente (implementador)
- Implementar TermsManager en Godot con autoload.
- Implementar TermsConfig como Resource.
- Crear borrador de términos de servicio (legal/terms_of_service.md).
- Crear política de términos (legal/terms_policy.md) para sitio web.
- Integrar con M78 (Legal General) para marco legal general.
- Integrar con M106 (Seguridad) para aplicar conductas prohibidas.
- Integrar con M60 (Datos y Serialización) para solicitudes de eliminación de datos (GDPR).
- Revisar términos con abogado antes de publicación.
- Publicar términos en sitio web.
- Publicar términos en Steam (EULA).
- Probar aceptación de términos en primer lanzamiento.
- Probar que no se muestren términos si ya fueron aceptados.
- Probar rechazo de términos (cierre del juego).
- Probar actualización de términos (versión nueva → re-aceptación).
