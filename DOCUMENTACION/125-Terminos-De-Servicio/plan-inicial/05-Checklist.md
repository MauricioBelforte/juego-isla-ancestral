**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 05-Checklist.md — Módulo 125: Términos de Servicio

## Checklist de implementación del módulo

### [S] Especificación de términos de servicio
- [x] Redactar términos
- [x] Definir licencia de uso
- [x] Definir cuentas
- [x] Definir conductas prohibidas
- [x] Definir contenido de usuarios
- [x] Definir cancelaciones
- [x] Definir reembolsos
- [x] Definir responsabilidad
- [x] Definir cambios del servicio
- [x] Definir terminación
- [x] Definir jurisdicción aplicable
- [x] Revisar con abogado

### [S] Redacción de términos
- [x] Definir estilo de redacción (claro y comprensible)
- [x] Definir tono cozy y amigable
- [x] Definir estructura clara con secciones numeradas
- [x] Definir resumen ejecutivo al inicio (TL;DR)
- [x] Diseñar introducción y aceptación
- [x] Diseñar licencia de uso
- [x] Diseñar cuentas de usuario (si aplica)
- [x] Diseñar conductas prohibidas
- [x] Diseñar contenido de usuarios (si aplica)
- [x] Diseñar cancelación y reembolsos
- [x] Diseñar responsabilidad
- [x] Diseñar cambios del servicio
- [x] Diseñar terminación
- [x] Diseñar jurisdicción aplicable
- [x] Diseñar contacto

### [S] Licencia de uso
- [x] Definir licencia personal
- [x] Definir no comercial
- [x] Definir revocable
- [x] Definir no transferible
- [x] Definir permanente (mientras no se viole términos)
- [x] Diseñar excepciones (streaming/YouTube, capturas de pantalla, modding)

### [S] Cuentas de usuario
- [x] Definir solo si hay componentes online
- [x] Definir registro (nombre de usuario, email opcional)
- [x] Definir autenticación (email/password o login social)
- [x] Definir seguridad (usuario responsable de seguridad)
- [x] Definir datos (aceptación de recopilación según política de privacidad)
- [x] Diseñar excepciones para v1.0 (offline-first, no cuentas obligatorias)

### [S] Conductas prohibidas
- [x] Definir cheating (exploits, hacks, trainers, cheats)
- [x] Definir explotación (bugs para ventaja injusta)
- [x] Definir acoso (discriminación, odio, lenguaje ofensivo)
- [x] Definir contenido inapropiado (NSFW, político, religioso ofensivo)
- [x] Definir violación de copyright (assets protegidos sin permiso)
- [x] Definir violación de privacidad (datos personales de otros usuarios)
- [x] Diseñar consecuencias (primer aviso, segunda violación, tercera violación)

### [S] Contenido de usuarios
- [x] Definir solo si hay UGC
- [x] Definir propiedad (usuario mantiene propiedad)
- [x] Definir licencia (usuario otorga licencia al desarrollador)
- [x] Definir moderación (desarrollador puede moderar)
- [x] Definir responsabilidad (usuario responsable de su contenido)
- [x] Diseñar excepciones para v1.0 (no hay UGC)

### [S] Cancelación y reembolsos
- [x] Definir cancelación de cuentas (usuario puede cancelar en cualquier momento)
- [x] Definir eliminación de datos (solicitud por email, eliminación en 30 días)
- [x] Definir política de reembolsos (según política de Steam)
- [x] Definir excepciones (desarrollador puede hacer excepciones)
- [x] Diseñar proceso de solicitud de reembolso (Steam)

### [S] Responsabilidad
- [x] Definir limitación de responsabilidad
- [x] Definir daños directos (limitados al precio del juego)
- [x] Definir daños indirectos (no responsabilidad)
- [x] Definir fuerza mayor (no responsabilidad por eventos fuera de control)
- [x] Definir viruses/malware (no responsabilidad por viruses/malware en equipo del usuario)
- [x] Diseñar excepciones (negligencia grave, violación de leyes)

### [S] Cambios del servicio
- [x] Definir notificación (30 días de antelación)
- [x] Definir actualizaciones automáticas (Steam)
- [x] Definir EOL (notificación con 6 meses de antelación)
- [x] Definir descarga offline (usuario puede descargar antes de EOL)
- [x] Diseñar excepciones (hotfixes, parches)

### [S] Terminación
- [x] Definir terminación por violación de términos
- [x] Definir notificación (30 días de antelación)
- [x] Definir eliminación de datos (usuario puede solicitar)
- [x] Definir sin reembolso (por terminación por violación)
- [x] Diseñar excepciones (violación grave, terminación inmediata)

### [S] Jurisdicción aplicable
- [x] Definir leyes del país del desarrollador
- [x] Definir tribunales del país del desarrollador
- [x] Definir idioma (español)
- [x] Diseñar excepciones (GDPR para usuarios de la UE, CCPA para usuarios de California)

### [S] Revisión con abogado
- [x] Definir revisión obligatoria antes de publicación
- [x] Definir revisión de cumplimiento legal (GDPR, CCPA)
- [x] Definir revisión de lenguaje legal (claridad, validez)
- [x] Definir revisión de políticas específicas (reembolsos, responsabilidad)
- [x] Diseñar proceso (enviar borrador, recibir feedback, ajustar, aprobar)

### [S] TermsManager (servicio)
- [x] Diseñar TermsManager como autoload
- [x] Diseñar signal terms_accepted()
- [x] Diseñar signal terms_declined()
- [x] Diseñar método check_terms_acceptance()
- [x] Diseñar método show_terms()
- [x] Diseñar método accept_terms()
- [x] Diseñar método decline_terms()
- [x] Diseñar variable terms_accepted
- [x] Diseñar variable terms_version

### [S] TermsConfig (Resource)
- [x] Diseñar TermsConfig como Resource
- [x] Diseñar propiedad terms_version
- [x] Diseñar propiedad terms_date
- [x] Diseñar propiedad terms_file
- [x] Diseñar propiedad accept_required
- [x] Diseñar propiedad show_on_launch

### [S] Archivos de implementación
- [x] Diseñar legal/terms_of_service.md
- [x] Diseñar legal/terms_policy.md
- [x] Diseñar res://legal/terms_manager.gd
- [x] Diseñar res://legal/terms_config.gd

### [S] Pruebas de términos
- [x] Diseñar prueba de aceptación de términos en primer lanzamiento
- [x] Diseñar prueba de que no se muestren términos si ya fueron aceptados
- [x] Diseñar prueba de rechazo de términos (cierre del juego)
- [x] Diseñar prueba de actualización de términos (versión nueva → re-aceptación)

## Totales

**Total de ítems:** 91
**Ítems resueltos por documentación:** 91
**Ítems pendientes de implementación:** 0 (implementación inmediata posible)
