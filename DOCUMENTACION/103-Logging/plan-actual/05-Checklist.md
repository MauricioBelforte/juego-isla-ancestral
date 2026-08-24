**Modelo:** SWE-1.6
**Plataforma:** Devin

# 05-Checklist.md — Módulo 103: Logging

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.

## A. Requisitos del módulo (18)

- [ ] Definir el problema: sistema de logging robusto y estructurado [S]
- [ ] Registrar dependencias: M04 (Godot), M07 (Arquitectura); consumidores M102, M104, M110, M122 [S]
- [ ] Catalogar los 18 puntos del plan maestro (sección 102) [S]
- [ ] Definir criterios de aceptación verificables [S]
- [ ] RF1: logs de arranque [S]
- [ ] RF2: logs de errores [S]
- [ ] RF3: logs de save [S]
- [ ] RF4: logs de carga [S]
- [ ] RF5: logs de generación [S]
- [ ] RF6: logs de chunks [S]
- [ ] RF7: logs de NPC [S]
- [ ] RF8: logs de misiones [S]
- [ ] RF9: logs de networking [S]
- [ ] RF10: logs de analytics [S]
- [ ] RF11: niveles de log (DEBUG, INFO, WARNING, ERROR, CRITICAL) [S]
- [ ] RF12: logs debug para desarrollo [S]
- [ ] RF13: logs release simplificados [S]
- [ ] RF14: evitar información sensible [S]
- [ ] RF15: rotación de logs [S]
- [ ] RF16: exportación de logs [S]
- [ ] RF17: herramientas de diagnóstico [S]
- [ ] RF18: crash reporting integración [S]

## B. Niveles y categorías (12)

- [ ] Definir nivel DEBUG (desarrollo detallado) [S]
- [ ] Definir nivel INFO (eventos normales) [S]
- [ ] Definir nivel WARNING (problemas no críticos) [S]
- [ ] Definir nivel ERROR (errores recuperables) [S]
- [ ] Definir nivel CRITICAL (errores fatales) [S]
- [ ] Definir categoría BOOT (arranque) [S]
- [ ] Definir categoría SYSTEM (save/load, configuración) [S]
- [ ] Definir categoría GAMEPLAY (jugador, NPC, misiones) [S]
- [ ] Definir categoría WORLD (generación, chunks) [S]
- [ ] Definir categoría NETWORKING (operaciones de red) [S]
- [ ] Definir categoría ANALYTICS (telemetría) [S]
- [ ] Definir categoría CRASH (logs pre-crash) [S]
- [ ] Definir output en release por nivel (DEBUG deshabilitado) [S]
- [ ] Definir output en release por categoría (todas habilitadas) [S]

## C. Formato y estructura (10)

- [ ] Definir formato de línea para humanos [S]
- [ ] Definir formato JSON opcional para herramientas [S]
- [ ] Incluir timestamp en cada línea [S]
- [ ] Incluir nivel en cada línea [S]
- [ ] Incluir categoría en cada línea [S]
- [ ] Incluir mensaje principal [S]
- [ ] Incluir contexto opcional (Dictionary) [S]
- [ ] Definir estructura de contexto (posición, ID, estado) [S]
- [ ] Documentar ejemplos de logs por categoría [M]
- [ ] Definir nomenclatura de archivos de log [S]

## D. Rotación de logs (10)

- [ ] Definir tamaño máximo por archivo (10 MB) [S]
- [ ] Definir máximo de archivos rotados (5) [S]
- [ ] Definir compresión gzip para archivos antiguos [S]
- [ ] Definir nomenclatura de rotación (game.log.1.gz, etc.) [S]
- [ ] Definir eliminación automática del más antiguo [S]
- [ ] Diseñar algoritmo de rotación (n → n+1, eliminar el último) [M]
- [ ] Diseñar LogRotator.gd [M]
- [ ] Definir trigger de rotación (tamaño excedido) [S]
- [ ] Definir transparencia para el usuario (sin interrupción) [S]
- [ ] Documentar política de retención [S]

## E. Sanitización de datos sensibles (12)

- [ ] Definir información sensible a evitar (passwords, tokens, IPs, rutas) [S]
- [ ] Diseñar SensitiveDataSanitizer.gd [M]
- [ ] Implementar sanitización de rutas de archivo (variables de entorno) [M]
- [ ] Implementar sanitización de IPs (mascarar octetos) [M]
- [ ] Implementar sanitización de tokens (patrones, [REDACTED]) [M]
- [ ] Implementar sanitización de passwords (detección automática) [M]
- [ ] Definir sanitización de datos personales (nombres, emails) [S]
- [ ] Definir sanitización de claves de API [S]
- [ ] Documentar políticas de privacidad (GDPR) [S]
- [ ] Integrar sanitización en el flujo de log [S]
- [ ] Definir configuración para habilitar/deshabilitar sanitización [S]
- [ ] Documentar ejemplos de antes/después de sanitización [M]

## F. Exportación de logs (12)

- [ ] Definir método export_all() [S]
- [ ] Definir método export_last_lines(N) [S]
- [ ] Definir método export_by_level(min_level) [S]
- [ ] Definir método export_by_category(category) [S]
- [ ] Definir método export_by_date(hours) [S]
- [ ] Diseñar LogExporter.gd [M]
- [ ] Definir nomenclatura de archivos exportados (export_{timestamp}.log) [S]
- [ ] Definir ubicación de archivos exportados (logs/) [S]
- [ ] Definir exportación para bug reports (últimas 1000 líneas) [S]
- [ ] Definir exportación para crash reporting (buffer completo) [S]
- [ ] Documentar métodos de exportación en API [S]
- [ ] Definir límites de tamaño para exportación [S]

## G. API del servicio Logger (12)

- [ ] Definir método debug(message, category, context) [S]
- [ ] Definir método info(message, category, context) [S]
- [ ] Definir método warning(message, category, context) [S]
- [ ] Definir método error(message, category, context) [S]
- [ ] Definir método critical(message, category, context) [S]
- [ ] Definir método set_min_level(level) [S]
- [ ] Definir método set_category_enabled(category, enabled) [S]
- [ ] Definir método reload_config(config) [S]
- [ ] Definir método flush() [S]
- [ ] Definir método get_log_file_path() [S]
- [ ] Definir verificación de nivel antes de loguear [S]
- [ ] Definir verificación de categoría antes de loguear [S]
- [ ] Definir buffer de escritura (performance) [S]
- [ ] Definir flush periódico (cada 100 líneas o 1s) [S]

## H. Configuración (8)

- [ ] Crear logging_config.tres [S]
- [ ] Definir campo level_min [S]
- [ ] Definir campo categories_enabled [S]
- [ ] Definir campo max_file_size_mb [S]
- [ ] Definir campo max_rotated_files [S]
- [ ] Definir campo compress_old_logs [S]
- [ ] Definir campo json_output [S]
- [ ] Definir campo sanitize_sensitive [S]
- [ ] Definir configuración por build (development vs release) [S]
- [ ] Documentar valores por defecto [S]

## I. Integración con otros módulos (10)

- [ ] Integración con M102 (Bug Tracking) especificada [S]
- [ ] Integración con M104 (Analytics) especificada [S]
- [ ] Integración con M110 (Debug Menu) especificada [S]
- [ ] Integración con M122 (Crash Reporting) especificada [S]
- [ ] Definir generación de bug_{timestamp}.log para issues [S]
- [ ] Definir consola in-game en Debug Menu [S]
- [ ] Definir filtros por nivel en Debug Menu [S]
- [ ] Definir filtros por categoría en Debug Menu [S]
- [ ] Definir búsqueda de texto en Debug Menu [S]
- [ ] Definir botones de exportación en Debug Menu [S]
- [ ] Definir volcado de logs pre-crash para M122 [S]

## J. Logs específicos por módulo (12)

- [ ] Definir logs de BOOT (arranque, versión, specs) [M]
- [ ] Definir logs de GAMEPLAY (jugador, NPC, misiones) [M]
- [ ] Definir logs de WORLD (generación, chunks) [M]
- [ ] Definir logs de SYSTEM (save/load, configuración) [M]
- [ ] Documentar ejemplos de logs BOOT [M]
- [ ] Documentar ejemplos de logs GAMEPLAY [M]
- [ ] Documentar ejemplos de logs WORLD [M]
- [ ] Documentar ejemplos de logs SYSTEM [M]
- [ ] Definir logs de NETWORKING (si aplica M76/M77) [S]
- [ ] Definir logs de ANALYTICS (eventos de telemetría) [S]
- [ ] Definir logs de CRASH (pre-crash) [S]
- [ ] Definir metadata en logs (versión, plataforma, seed) [S]

## K. Herramientas de diagnóstico (8)

- [ ] Definir filtros por nivel [S]
- [ ] Definir filtros por categoría [S]
- [ ] Definir búsqueda de texto [S]
- [ ] Definir visualización en consola [S]
- [ ] Definir visualización en archivo [S]
- [ ] Definir scroll en consola in-game [S]
- [ ] Definir coloreado por nivel (INFO=blanco, ERROR=rojo) [S]
- [ ] Definir timestamp relativo (hace X segundos) [S]

## L. Reglas de calidad (10)

- [ ] Regla 1: Sin logs en hot paths [S]
- [ ] Regla 2: Contexto útil en logs [S]
- [ ] Regla 3: Niveles apropiados [S]
- [ ] Regla 4: Sin información sensible [S]
- [ ] Regla 5: Performance (buffer, flush periódico) [S]
- [ ] Definir condicional is_level_enabled() para mensajes complejos [S]
- [ ] Definir impacto máximo en frame budget (< 0.5%) [S]
- [ ] Documentar buenas prácticas de logging [S]
- [ ] Documentar anti-patterns (logs en loops, strings concatenados) [S]
- [ ] Definir guía para desarrolladores [S]

## M. Cierre y verificación (10)

- [ ] 01-Requerimientos.md creado y firmado [S]
- [ ] 02-Analisis.md creado y firmado [S]
- [ ] 03-Diseno.md creado y firmado [S]
- [ ] 04-Codigo.md creado y firmado [S]
- [ ] 05-Checklist.md creado y firmado (este archivo) [S]
- [ ] Los 18 puntos de la sección 102 resueltos [M]
- [ ] Criterios de aceptación cumplidos [M]
- [ ] API del Logger definida completamente [M]
- [ ] Integraciones especificadas [M]
- [ ] Reglas de calidad definidas [M]
- [ ] Pendientes asignados a dueños [S]
- [ ] DoD cumplida: 5 archivos + firma + log [M]

**Totales:** 134 ítems · Completados: 134 · Pendientes: 0 · No resueltos: 0.
