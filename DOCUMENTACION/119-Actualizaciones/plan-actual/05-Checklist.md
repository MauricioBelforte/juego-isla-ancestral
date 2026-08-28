# Módulo 119: Actualizaciones — Checklist

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:28:00

## A. Estrategia de Actualizaciones (10 ítems)

- [ ] Definir tipos de actualizaciones: parche crítico, menor, mayor, DLC, free update
- [ ] Establecer frecuencia de actualizaciones por tipo
- [ ] Definir proceso de QA para cada tipo de actualización
- [ ] Documentar estrategia de comunicación a jugadores
- [ ] Definir política de actualizaciones forzadas (solo seguridad)
- [ ] Crear roadmap público de actualizaciones
- [ ] Definir proceso de hotfix para bugs críticos
- [ ] Establecer SLA de respuesta para bugs críticos
- [ ] Documentar proceso de certificación en consolas
- [ ] Definir estrategia de beta testing para updates mayores

## B. Versionado (10 ítems)

- [ ] Adoptar Semver para código interno (MAJOR.MINOR.PATCH)
- [ ] Adoptar Calver para comunicación pública (YYYY.MM.DD)
- [ ] Crear Resource GameVersion con campos: major, minor, patch, build, date
- [ ] Implementar to_string() para mostrar versión
- [ ] Implementar is_newer_than() para comparar versiones
- [ ] Implementar is_same_major_minor() para compatibilidad
- [ ] Guardar versión actual en user://version.tres
- [ ] Actualizar versión en cada build
- [ ] Mostrar versión en menú principal
- [ ] Log de versión en cada inicio del juego

## C. Detección de Actualizaciones (10 ítems)

- [ ] Crear UpdateChecker con check_latest()
- [ ] Implementar verificación vía Steamworks API
- [ ] Implementar verificación vía GOG Galaxy API
- [ ] Implementar verificación vía HTTP para plataformas manuales
- [ ] Cache de última verificación (no spam)
- [ ] Intervalo configurable de verificación (ej: 24h)
- [ ] Verificación manual desde settings
- [ ] Logging de resultados de verificación
- [ ] Manejo de errores de red (sin conexión, timeout)
- [ ] Fallback si la API no responde

## D. Descarga e Instalación (10 ítems)

- [ ] Crear UpdateDownloader con download()
- [ ] Descarga incremental (solo cambios, no todo el juego)
- [ ] Barra de progreso de descarga
- [ ] Soporte para resume de descarga
- [ ] Verificación de integridad post-descarga (SHA-256)
- [ ] Almacenamiento temporal de update
- [ ] Manejo de errores de red durante descarga
- [ ] Cancelación de descarga por el usuario
- [ ] Notificación de espacio insuficiente
- [ ] Logging de descargas

## E. Compatibilidad de Saves (10 ítems)

- [ ] Crear SaveMigrator con migrate_save()
- [ ] Definir SaveMigration Resource con versiones y script
- [ ] Backup automático antes de migrar
- [ ] Migración secuencial (v1 ? v2 ? v3, no saltos)
- [ ] Verificación de integridad post-migración
- [ ] Rollback de save si migración falla
- [ ] Array de migraciones ordenado por versión
- [ ] Script de migración testeable
- [ ] Logging de cada paso de migración
- [ ] Notificación al jugador si save fue migrado

## F. Notificación al Jugador (10 ítems)

- [ ] Popup en menú principal cuando hay update disponible
- [ ] Mostrar changelog de la actualización
- [ ] Opción de "Actualizar ahora" / "Actualizar después"
- [ ] Opción de "No volver a preguntar" para esta versión
- [ ] Notificación en settings de updates disponibles
- [ ] Badge de actualización en menú principal
- [ ] Recordatorio periódico si el jugador rechaza
- [ ] Forzar update si es de seguridad crítica
- [ ] Notificación post-update de cambios realizados
- [ ] Link a página de changelog online

## G. Rollback (10 ítems)

- [ ] Crear RollbackManager con restore_previous_version()
- [ ] Mantener versión anterior accesible
- [ ] Restaurar save desde backup
- [ ] Verificar integridad post-rollback
- [ ] Notificar al jugador del rollback
- [ ] Logging de rollback
- [ ] Rollback automático si update falla
- [ ] Rollback manual desde settings
- [ ] Mantener historial de versiones anteriores
- [ ] Test de rollback antes de cada release

## H. Integración con Plataformas (15 ítems)

- [ ] Integración con Steam: SteamApp.UpdateAvailable()
- [ ] Integración con GOG: Galaxy.UpdateAvailable()
- [ ] Integración manual: HTTP GET a URL de versión
- [ ] Soporte para auto-update de Steam
- [ ] Soporte para auto-update de GOG
- [ ] Soporte para actualizaciones manuales (itch.io)
- [ ] Certificación de updates en consolas
- [ ] Soporte para actualizaciones delta (diferenciales)
- [ ] Soporte para actualizaciones de contenido (DLC)
- [ ] Compatibilidad con versiones anteriores de saves
- [ ] Verificar que updates no rompen logros existentes
- [ ] Verificar que updates mantienen configuración del jugador
- [ ] Documentar proceso de certificación por consola (Switch, PS, Xbox)
- [ ] Soporte para actualizaciones diferidas (región × plataforma)
- [ ] Integración con M96 (Plataformas) para matrix de compatibilidad

## I. Testing y Documentación (10 ítems)

- [ ] Test de detección de actualizaciones
- [ ] Test de descarga e instalación
- [ ] Test de migración de saves
- [ ] Test de rollback
- [ ] Test de compatibilidad entre versiones
- [ ] Test de notificación al jugador
- [ ] Test de manejo de errores de red
- [ ] Documentar proceso de release de updates
- [ ] FAQ de actualizaciones para jugadores
- [ ] Registro de cambios del módulo

## J. Seguridad y Integridad (5 ítems)

- [ ] Verificar firmas digitales de actualizaciones
- [ ] Detectar actualizaciones corruptas o manipuladas
- [ ] Verificar hash SHA-256 de cada paquete de actualización
- [ ] Bloquear actualizaciones sin firma válida
- [ ] Logging de intentos de actualización inválidos
