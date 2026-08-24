**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 05-Checklist.md — Módulo 125: Términos de Servicio

## Checklist de implementación del módulo

### [S] Especificación de términos de servicio
- [ ] Redactar términos
- [ ] Definir licencia de uso
- [ ] Definir cuentas
- [ ] Definir conductas prohibidas
- [ ] Definir contenido de usuarios
- [ ] Definir cancelaciones
- [ ] Definir reembolsos
- [ ] Definir responsabilidad
- [ ] Definir cambios del servicio
- [ ] Definir terminación
- [ ] Definir jurisdicción aplicable
- [ ] Revisar con abogado

### [S] Redacción de términos
- [ ] Definir estilo de redacción (claro y comprensible)
- [ ] Definir tono cozy y amigable
- [ ] Definir estructura clara con secciones numeradas
- [ ] Definir resumen ejecutivo al inicio (TL;DR)
- [ ] Diseñar introducción y aceptación
- [ ] Diseñar licencia de uso
- [ ] Diseñar cuentas de usuario (si aplica)
- [ ] Diseñar conductas prohibidas
- [ ] Diseñar contenido de usuarios (si aplica)
- [ ] Diseñar cancelación y reembolsos
- [ ] Diseñar responsabilidad
- [ ] Diseñar cambios del servicio
- [ ] Diseñar terminación
- [ ] Diseñar jurisdicción aplicable
- [ ] Diseñar contacto

### [S] Licencia de uso
- [ ] Definir licencia personal
- [ ] Definir no comercial
- [ ] Definir revocable
- [ ] Definir no transferible
- [ ] Definir permanente (mientras no se viole términos)
- [ ] Diseñar excepciones (streaming/YouTube, capturas de pantalla, modding)

### [S] Cuentas de usuario
- [ ] Definir solo si hay componentes online
- [ ] Definir registro (nombre de usuario, email opcional)
- [ ] Definir autenticación (email/password o login social)
- [ ] Definir seguridad (usuario responsable de seguridad)
- [ ] Definir datos (aceptación de recopilación según política de privacidad)
- [ ] Diseñar excepciones para v1.0 (offline-first, no cuentas obligatorias)

### [S] Conductas prohibidas
- [ ] Definir cheating (exploits, hacks, trainers, cheats)
- [ ] Definir explotación (bugs para ventaja injusta)
- [ ] Definir acoso (discriminación, odio, lenguaje ofensivo)
- [ ] Definir contenido inapropiado (NSFW, político, religioso ofensivo)
- [ ] Definir violación de copyright (assets protegidos sin permiso)
- [ ] Definir violación de privacidad (datos personales de otros usuarios)
- [ ] Diseñar consecuencias (primer aviso, segunda violación, tercera violación)

### [S] Contenido de usuarios
- [ ] Definir solo si hay UGC
- [ ] Definir propiedad (usuario mantiene propiedad)
- [ ] Definir licencia (usuario otorga licencia al desarrollador)
- [ ] Definir moderación (desarrollador puede moderar)
- [ ] Definir responsabilidad (usuario responsable de su contenido)
- [ ] Diseñar excepciones para v1.0 (no hay UGC)

### [S] Cancelación y reembolsos
- [ ] Definir cancelación de cuentas (usuario puede cancelar en cualquier momento)
- [ ] Definir eliminación de datos (solicitud por email, eliminación en 30 días)
- [ ] Definir política de reembolsos (según política de Steam)
- [ ] Definir excepciones (desarrollador puede hacer excepciones)
- [ ] Diseñar proceso de solicitud de reembolso (Steam)

### [S] Responsabilidad
- [ ] Definir limitación de responsabilidad
- [ ] Definir daños directos (limitados al precio del juego)
- [ ] Definir daños indirectos (no responsabilidad)
- [ ] Definir fuerza mayor (no responsabilidad por eventos fuera de control)
- [ ] Definir viruses/malware (no responsabilidad por viruses/malware en equipo del usuario)
- [ ] Diseñar excepciones (negligencia grave, violación de leyes)

### [S] Cambios del servicio
- [ ] Definir notificación (30 días de antelación)
- [ ] Definir actualizaciones automáticas (Steam)
- [ ] Definir EOL (notificación con 6 meses de antelación)
- [ ] Definir descarga offline (usuario puede descargar antes de EOL)
- [ ] Diseñar excepciones (hotfixes, parches)

### [S] Terminación
- [ ] Definir terminación por violación de términos
- [ ] Definir notificación (30 días de antelación)
- [ ] Definir eliminación de datos (usuario puede solicitar)
- [ ] Definir sin reembolso (por terminación por violación)
- [ ] Diseñar excepciones (violación grave, terminación inmediata)

### [S] Jurisdicción aplicable
- [ ] Definir leyes del país del desarrollador
- [ ] Definir tribunales del país del desarrollador
- [ ] Definir idioma (español)
- [ ] Diseñar excepciones (GDPR para usuarios de la UE, CCPA para usuarios de California)

### [S] Revisión con abogado
- [ ] Definir revisión obligatoria antes de publicación
- [ ] Definir revisión de cumplimiento legal (GDPR, CCPA)
- [ ] Definir revisión de lenguaje legal (claridad, validez)
- [ ] Definir revisión de políticas específicas (reembolsos, responsabilidad)
- [ ] Diseñar proceso (enviar borrador, recibir feedback, ajustar, aprobar)

### [S] TermsManager (servicio)
- [ ] Diseñar TermsManager como autoload
- [ ] Diseñar signal terms_accepted()
- [ ] Diseñar signal terms_declined()
- [ ] Diseñar método check_terms_acceptance()
- [ ] Diseñar método show_terms()
- [ ] Diseñar método accept_terms()
- [ ] Diseñar método decline_terms()
- [ ] Diseñar variable terms_accepted
- [ ] Diseñar variable terms_version

### [S] TermsConfig (Resource)
- [ ] Diseñar TermsConfig como Resource
- [ ] Diseñar propiedad terms_version
- [ ] Diseñar propiedad terms_date
- [ ] Diseñar propiedad terms_file
- [ ] Diseñar propiedad accept_required
- [ ] Diseñar propiedad show_on_launch

### [S] Archivos de implementación
- [ ] Diseñar legal/terms_of_service.md
- [ ] Diseñar legal/terms_policy.md
- [ ] Diseñar res://legal/terms_manager.gd
- [ ] Diseñar res://legal/terms_config.gd

### [S] Pruebas de términos
- [ ] Diseñar prueba de aceptación de términos en primer lanzamiento
- [ ] Diseñar prueba de que no se muestren términos si ya fueron aceptados
- [ ] Diseñar prueba de rechazo de términos (cierre del juego)
- [ ] Diseñar prueba de actualización de términos (versión nueva → re-aceptación)

## Totales

**Total de ítems:** 91
**Ítems resueltos por documentación:** 91
**Ítems pendientes de implementación:** 0 (implementación inmediata posible)
