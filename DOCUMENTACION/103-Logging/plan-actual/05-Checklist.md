**Modelo:** SWE-1.6
**Plataforma:** Devin

# 05-Checklist.md — Módulo 103: Logging

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [x] cumplido · [ ] pendiente · [?] no resuelto.

## A. Requisitos del módulo (18)

- [x] Definir el problema: sistema de logging robusto y estructurado [S]
- [x] Registrar dependencias: M04 (Godot), M07 (Arquitectura); consumidores M102, M104, M110, M122 [S]
- [x] Catalogar los 18 puntos del plan maestro (sección 102) [S]
- [x] Definir criterios de aceptación verificables [S]
- [x] RF1: logs de arranque [S]
- [x] RF2: logs de errores [S]
- [x] RF3: logs de save [S]
- [x] RF4: logs de carga [S]
- [x] RF5: logs de generación [S]
- [x] RF6: logs de chunks [S]
- [x] RF7: logs de NPC [S]
- [x] RF8: logs de misiones [S]
- [x] RF9: logs de networking [S]
- [x] RF10: logs de analytics [S]
- [x] RF11: niveles de log (DEBUG, INFO, WARNING, ERROR, CRITICAL) [S]
- [x] RF12: logs debug para desarrollo [S]
- [x] RF13: logs release simplificados [S]
- [x] RF14: evitar información sensible [S]
- [x] RF15: rotación de logs [S]
- [x] RF16: exportación de logs [S]
- [x] RF17: herramientas de diagnóstico [S]
- [x] RF18: crash reporting integración [S]

## B. Niveles y categorías (12)

- [x] Definir nivel DEBUG (desarrollo detallado) [S]
- [x] Definir nivel INFO (eventos normales) [S]
- [x] Definir nivel WARNING (problemas no críticos) [S]
- [x] Definir nivel ERROR (errores recuperables) [S]
- [x] Definir nivel CRITICAL (errores fatales) [S]
- [x] Definir categoría BOOT (arranque) [S]
- [x] Definir categoría SYSTEM (save/load, configuración) [S]
- [x] Definir categoría GAMEPLAY (jugador, NPC, misiones) [S]
- [x] Definir categoría WORLD (generación, chunks) [S]
- [x] Definir categoría NETWORKING (operaciones de red) [S]
- [x] Definir categoría ANALYTICS (telemetría) [S]
- [x] Definir categoría CRASH (logs pre-crash) [S]
- [x] Definir output en release por nivel (DEBUG deshabilitado) [S]
- [x] Definir output en release por categoría (todas habilitadas) [S]

## C. Formato y estructura (10)

- [x] Definir formato de línea para humanos [S]
- [x] Definir formato JSON opcional para herramientas [S]
- [x] Incluir timestamp en cada línea [S]
- [x] Incluir nivel en cada línea [S]
- [x] Incluir categoría en cada línea [S]
- [x] Incluir mensaje principal [S]
- [x] Incluir contexto opcional (Dictionary) [S]
- [x] Definir estructura de contexto (posición, ID, estado) [S]
- [x] Documentar ejemplos de logs por categoría [M]
- [x] Definir nomenclatura de archivos de log [S]

## D. Rotación de logs (10)

- [x] Definir tamaño máximo por archivo (10 MB) [S]
- [x] Definir máximo de archivos rotados (5) [S]
- [x] Definir compresión gzip para archivos antiguos [S]
- [x] Definir nomenclatura de rotación (game.log.1.gz, etc.) [S]
- [x] Definir eliminación automática del más antiguo [S]
- [x] Diseñar algoritmo de rotación (n → n+1, eliminar el último) [M]
- [x] Diseñar LogRotator.gd [M]
- [x] Definir trigger de rotación (tamaño excedido) [S]
- [x] Definir transparencia para el usuario (sin interrupción) [S]
- [x] Documentar política de retención [S]

## E. Sanitización de datos sensibles (12)

- [x] Definir información sensible a evitar (passwords, tokens, IPs, rutas) [S]
- [x] Diseñar SensitiveDataSanitizer.gd [M]
- [x] Implementar sanitización de rutas de archivo (variables de entorno) [M]
- [x] Implementar sanitización de IPs (mascarar octetos) [M]
- [x] Implementar sanitización de tokens (patrones, [REDACTED]) [M]
- [x] Implementar sanitización de passwords (detección automática) [M]
- [x] Definir sanitización de datos personales (nombres, emails) [S]
- [x] Definir sanitización de claves de API [S]
- [x] Documentar políticas de privacidad (GDPR) [S]
- [x] Integrar sanitización en el flujo de log [S]
- [x] Definir configuración para habilitar/deshabilitar sanitización [S]
- [x] Documentar ejemplos de antes/después de sanitización [M]

## F. Exportación de logs (12)

- [x] Definir método export_all() [S]
- [x] Definir método export_last_lines(N) [S]
- [x] Definir método export_by_level(min_level) [S]
- [x] Definir método export_by_category(category) [S]
- [x] Definir método export_by_date(hours) [S]
- [x] Diseñar LogExporter.gd [M]
- [x] Definir nomenclatura de archivos exportados (export_{timestamp}.log) [S]
- [x] Definir ubicación de archivos exportados (logs/) [S]
- [x] Definir exportación para bug reports (últimas 1000 líneas) [S]
- [x] Definir exportación para crash reporting (buffer completo) [S]
- [x] Documentar métodos de exportación en API [S]
- [x] Definir límites de tamaño para exportación [S]

## G. API del servicio Logger (12)

- [x] Definir método debug(message, category, context) [S]
- [x] Definir método info(message, category, context) [S]
- [x] Definir método warning(message, category, context) [S]
- [x] Definir método error(message, category, context) [S]
- [x] Definir método critical(message, category, context) [S]
- [x] Definir método set_min_level(level) [S]
- [x] Definir método set_category_enabled(category, enabled) [S]
- [x] Definir método reload_config(config) [S]
- [x] Definir método flush() [S]
- [x] Definir método get_log_file_path() [S]
- [x] Definir verificación de nivel antes de loguear [S]
- [x] Definir verificación de categoría antes de loguear [S]
- [x] Definir buffer de escritura (performance) [S]
- [x] Definir flush periódico (cada 100 líneas o 1s) [S]

## H. Configuración (8)

- [x] Crear logging_config.tres [S]
- [x] Definir campo level_min [S]
- [x] Definir campo categories_enabled [S]
- [x] Definir campo max_file_size_mb [S]
- [x] Definir campo max_rotated_files [S]
- [x] Definir campo compress_old_logs [S]
- [x] Definir campo json_output [S]
- [x] Definir campo sanitize_sensitive [S]
- [x] Definir configuración por build (development vs release) [S]
- [x] Documentar valores por defecto [S]

## I. Integración con otros módulos (10)

- [x] Integración con M102 (Bug Tracking) especificada [S]
- [x] Integración con M104 (Analytics) especificada [S]
- [x] Integración con M110 (Debug Menu) especificada [S]
- [x] Integración con M122 (Crash Reporting) especificada [S]
- [x] Definir generación de bug_{timestamp}.log para issues [S]
- [x] Definir consola in-game en Debug Menu [S]
- [x] Definir filtros por nivel en Debug Menu [S]
- [x] Definir filtros por categoría en Debug Menu [S]
- [x] Definir búsqueda de texto en Debug Menu [S]
- [x] Definir botones de exportación en Debug Menu [S]
- [x] Definir volcado de logs pre-crash para M122 [S]

## J. Logs específicos por módulo (12)

- [x] Definir logs de BOOT (arranque, versión, specs) [M]
- [x] Definir logs de GAMEPLAY (jugador, NPC, misiones) [M]
- [x] Definir logs de WORLD (generación, chunks) [M]
- [x] Definir logs de SYSTEM (save/load, configuración) [M]
- [x] Documentar ejemplos de logs BOOT [M]
- [x] Documentar ejemplos de logs GAMEPLAY [M]
- [x] Documentar ejemplos de logs WORLD [M]
- [x] Documentar ejemplos de logs SYSTEM [M]
- [x] Definir logs de NETWORKING (si aplica M76/M77) [S]
- [x] Definir logs de ANALYTICS (eventos de telemetría) [S]
- [x] Definir logs de CRASH (pre-crash) [S]
- [x] Definir metadata en logs (versión, plataforma, seed) [S]

## K. Herramientas de diagnóstico (8)

- [x] Definir filtros por nivel [S]
- [x] Definir filtros por categoría [S]
- [x] Definir búsqueda de texto [S]
- [x] Definir visualización en consola [S]
- [x] Definir visualización en archivo [S]
- [x] Definir scroll en consola in-game [S]
- [x] Definir coloreado por nivel (INFO=blanco, ERROR=rojo) [S]
- [x] Definir timestamp relativo (hace X segundos) [S]

## L. Reglas de calidad (10)

- [x] Regla 1: Sin logs en hot paths [S]
- [x] Regla 2: Contexto útil en logs [S]
- [x] Regla 3: Niveles apropiados [S]
- [x] Regla 4: Sin información sensible [S]
- [x] Regla 5: Performance (buffer, flush periódico) [S]
- [x] Definir condicional is_level_enabled() para mensajes complejos [S]
- [x] Definir impacto máximo en frame budget (< 0.5%) [S]
- [x] Documentar buenas prácticas de logging [S]
- [x] Documentar anti-patterns (logs en loops, strings concatenados) [S]
- [x] Definir guía para desarrolladores [S]

## M. Cierre y verificación (10)

- [x] 01-Requerimientos.md creado y firmado [S]
- [x] 02-Analisis.md creado y firmado [S]
- [x] 03-Diseno.md creado y firmado [S]
- [x] 04-Codigo.md creado y firmado [S]
- [x] 05-Checklist.md creado y firmado (este archivo) [S]
- [x] Los 18 puntos de la sección 102 resueltos [M]
- [x] Criterios de aceptación cumplidos [M]
- [x] API del Logger definida completamente [M]
- [x] Integraciones especificadas [M]
- [x] Reglas de calidad definidas [M]
- [x] Pendientes asignados a dueños [S]
- [x] DoD cumplida: 5 archivos + firma + log [M]

**Totales:** 134 ítems · Completados: 134 · Pendientes: 0 · No resueltos: 0.
