**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 03-Diseno.md — Módulo 125: Términos de Servicio

## 1. Estructura de los términos de servicio

```
Términos de Servicio (documento legal)
├── Introducción y aceptación
│   ├── Resumen ejecutivo (TL;DR)
│   ├── Fecha de vigencia
│   └── Aceptación de términos
├── Licencia de uso
│   ├── Licencia personal
│   ├── No comercial
│   ├── Revocable
│   └── No transferible
├── Cuentas de usuario (si aplica)
│   ├── Registro
│   ├── Autenticación
│   ├── Seguridad
│   └── Datos
├── Conductas prohibidas
│   ├── Cheating
│   ├── Explotación
│   ├── Acoso
│   ├── Contenido inapropiado
│   ├── Violación de copyright
│   └── Violación de privacidad
├── Contenido de usuarios (si aplica)
│   ├── Propiedad
│   ├── Licencia
│   ├── Moderación
│   └── Responsabilidad
├── Cancelación y reembolsos
│   ├── Cancelación de cuentas
│   ├── Eliminación de datos
│   └── Política de reembolsos
├── Responsabilidad
│   ├── Limitación de responsabilidad
│   ├── Daños directos
│   ├── Daños indirectos
│   ├── Fuerza mayor
│   └── Viruses/malware
├── Cambios del servicio
│   ├── Notificación (30 días)
│   ├── Actualizaciones automáticas
│   ├── EOL (6 meses)
│   └── Descarga offline
├── Terminación
│   ├── Por violación de términos
│   ├── Notificación (30 días)
│   ├── Eliminación de datos
│   └── Sin reembolso
├── Jurisdicción aplicable
│   ├── Leyes del país del desarrollador
│   ├── Tribunales del país del desarrollador
│   ├── GDPR (usuarios de la UE)
│   └── CCPA (usuarios de California)
└── Contacto
    ├── Email de contacto
    ├── Dirección postal
    └── Horario de atención
```

## 2. Borrador de términos de servicio

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
...
## 2. Licencia de Uso
...
## 3. Cuentas de Usuario (si aplica)
...
## 4. Conductas Prohibidas
...
## 5. Contenido de Usuarios (si aplica)
...
## 6. Cancelación y Reembolsos
...
## 7. Responsabilidad
...
## 8. Cambios del Servicio
...
## 9. Terminación
...
## 10. Jurisdicción Aplicable
...
## 11. Contacto
...
```

## 3. Sistema de aceptación de términos

**Archivo: res://legal/terms_manager.gd**

**Estructura:**
```gdscript
class_name TermsManager
extends Node

signal terms_accepted()
signal terms_declined()

var terms_accepted: bool = false

func _ready():
    check_terms_acceptance()

func check_terms_acceptance():
    var terms_file = FileAccess.open("user://terms_accepted.txt", FileAccess.READ)
    if terms_file:
        terms_accepted = true
        terms_file.close()

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

## 4. Configuración de términos

**Archivo: res://legal/terms_config.gd**

**Estructura:**
```gdscript
class_name TermsConfig
extends Resource

@export var terms_version: String = "1.0.0"
@export var terms_date: String = "2026-08-19"
@export var terms_file: String = "res://legal/terms_of_service.md"
@export var accept_required: bool = true
@export var show_on_launch: bool = true
```

## 5. Diagrama de flujo de aceptación de términos

```
[Usuario inicia juego]
    ↓
[TermsManager check_terms_acceptance()]
    ↓
[Términos aceptados previamente?]
    ↓ Sí
[Continuar al juego]
    ↓ No
[Mostrar términos de servicio]
    ↓
[Usuario lee términos]
    ↓
[Usuario acepta?]
    ↓ No
[TermsManager decline_terms()]
    ↓
[Cerrar juego]
    ↓ Sí
[TermsManager accept_terms()]
    ↓
[Guardar aceptación en user://terms_accepted.txt]
    ↓
[Continuar al juego]
```

## 6. Pruebas de términos

**Pruebas manuales:**
- Probar aceptación de términos en primer lanzamiento
- Probar que no se muestren términos si ya fueron aceptados
- Probar rechazo de términos (cierre del juego)
- Probar actualización de términos (versión nueva → re-aceptación)

**Pruebas automáticas:**
- Tests de TermsManager
- Tests de TermsConfig
- Tests de aceptación/rechazo
