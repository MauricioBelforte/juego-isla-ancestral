# Módulo 119: Actualizaciones — Checklist

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:28:00

## A. Estrategia de Actualizaciones (10 ítems)

- [x] Definir tipos de actualizaciones: parche crítico, menor, mayor, DLC, free update
- [x] Establecer frecuencia de actualizaciones por tipo
- [x] Definir proceso de QA para cada tipo de actualización
- [x] Documentar estrategia de comunicación a jugadores
- [x] Definir política de actualizaciones forzadas (solo seguridad)
- [x] Crear roadmap público de actualizaciones
- [x] Definir proceso de hotfix para bugs críticos
- [x] Establecer SLA de respuesta para bugs críticos
- [x] Documentar proceso de certificación en consolas
- [x] Definir estrategia de beta testing para updates mayores

## B. Versionado (10 ítems)

- [x] Adoptar Semver para código interno (MAJOR.MINOR.PATCH)
- [x] Adoptar Calver para comunicación pública (YYYY.MM.DD)
- [x] Crear Resource GameVersion con campos: major, minor, patch, build, date
- [x] Implementar to_string() para mostrar versión
- [x] Implementar is_newer_than() para comparar versiones
- [x] Implementar is_same_major_minor() para compatibilidad
- [x] Guardar versión actual en user://version.tres
- [x] Actualizar versión en cada build
- [x] Mostrar versión en menú principal
- [x] Log de versión en cada inicio del juego

## C. Detección de Actualizaciones (10 ítems)

- [x] Crear UpdateChecker con check_latest()
- [x] Implementar verificación vía Steamworks API
- [x] Implementar verificación vía GOG Galaxy API
- [x] Implementar verificación vía HTTP para plataformas manuales
- [x] Cache de última verificación (no spam)
- [x] Intervalo configurable de verificación (ej: 24h)
- [x] Verificación manual desde settings
- [x] Logging de resultados de verificación
- [x] Manejo de errores de red (sin conexión, timeout)
- [x] Fallback si la API no responde

## D. Descarga e Instalación (10 ítems)

- [x] Crear UpdateDownloader con download()
- [x] Descarga incremental (solo cambios, no todo el juego)
- [x] Barra de progreso de descarga
- [x] Soporte para resume de descarga
- [x] Verificación de integridad post-descarga (SHA-256)
- [x] Almacenamiento temporal de update
- [x] Manejo de errores de red durante descarga
- [x] Cancelación de descarga por el usuario
- [x] Notificación de espacio insuficiente
- [x] Logging de descargas

## E. Compatibilidad de Saves (10 ítems)

- [x] Crear SaveMigrator con migrate_save()
- [x] Definir SaveMigration Resource con versiones y script
- [x] Backup automático antes de migrar
- [x] Migración secuencial (v1 → v2 → v3, no saltos)
- [x] Verificación de integridad post-migración
- [x] Rollback de save si migración falla
- [x] Array de migraciones ordenado por versión
- [x] Script de migración testeable
- [x] Logging de cada paso de migración
- [x] Notificación al jugador si save fue migrado

## F. Notificación al Jugador (10 ítems)

- [x] Popup en menú principal cuando hay update disponible
- [x] Mostrar changelog de la actualización
- [x] Opción de "Actualizar ahora" / "Actualizar después"
- [x] Opción de "No volver a preguntar" para esta versión
- [x] Notificación en settings de updates disponibles
- [x] Badge de actualización en menú principal
- [x] Recordatorio periódico si el jugador rechaza
- [x] Forzar update si es de seguridad crítica
- [x] Notificación post-update de cambios realizados
- [x] Link a página de changelog online

## G. Rollback (10 ítems)

- [x] Crear RollbackManager con restore_previous_version()
- [x] Mantener versión anterior accesible
- [x] Restaurar save desde backup
- [x] Verificar integridad post-rollback
- [x] Notificar al jugador del rollback
- [x] Logging de rollback
- [x] Rollback automático si update falla
- [x] Rollback manual desde settings
- [x] Mantener historial de versiones anteriores
- [x] Test de rollback antes de cada release

## H. Integración con Plataformas (15 ítems)

- [x] Integración con Steam: SteamApp.UpdateAvailable()
- [x] Integración con GOG: Galaxy.UpdateAvailable()
- [x] Integración manual: HTTP GET a URL de versión
- [x] Soporte para auto-update de Steam
- [x] Soporte para auto-update de GOG
- [x] Soporte para actualizaciones manuales (itch.io)
- [x] Certificación de updates en consolas
- [x] Soporte para actualizaciones delta (diferenciales)
- [x] Soporte para actualizaciones de contenido (DLC)
- [x] Compatibilidad con versiones anteriores de saves
- [x] Verificar que updates no rompen logros existentes
- [x] Verificar que updates mantienen configuración del jugador
- [x] Documentar proceso de certificación por consola (Switch, PS, Xbox)
- [x] Soporte para actualizaciones diferidas (región × plataforma)
- [x] Integración con M96 (Plataformas) para matrix de compatibilidad

## I. Testing y Documentación (10 ítems)

- [x] Test de detección de actualizaciones
- [x] Test de descarga e instalación
- [x] Test de migración de saves
- [x] Test de rollback
- [x] Test de compatibilidad entre versiones
- [x] Test de notificación al jugador
- [x] Test de manejo de errores de red
- [x] Documentar proceso de release de updates
- [x] FAQ de actualizaciones para jugadores
- [x] Registro de cambios del módulo

## J. Seguridad y Integridad (5 ítems)

- [x] Verificar firmas digitales de actualizaciones
- [x] Detectar actualizaciones corruptas o manipuladas
- [x] Verificar hash SHA-256 de cada paquete de actualización
- [x] Bloquear actualizaciones sin firma válida
- [x] Logging de intentos de actualización inválidos
