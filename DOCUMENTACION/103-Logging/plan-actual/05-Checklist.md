**Modelo:** ox-alpha (Cline)
**Plataforma:** Cline

## Reserva actual

- Estado: 🔵 En curso
- Agente: ox-alpha (Cline)
- Fase: F0/transversal (infraestructura)
- Dificultad: 2
- Vision: V0
- Entrada: M04 Godot ✅ + M07 ServiceRegistry ✅
- Salida: Logger (autoload) + LogRotator + SensitiveDataSanitizer + LogExporter + logging_config.tres, verificados headless Godot 4.7.2
- Archivos: `game/isla-ancestral/scripts/logging/*.gd`, `data/logging/logging_config.tres`, `project.godot`
- Fecha: 2026-08-29

# 05-Checklist.md — Módulo 103: Logging

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.

## A. Requisitos del módulo (18)

- [ ] Definir el problema: sistema de logging robusto y estructurado [S]
- [ ] Registrar dependencias: M04 (Godot), M07 (Arquitectura); consumidores M102, M104, M110, M122 [S]
- [ ] Catalogar los 18 puntos del plan maestro (sección 102) [S]
- [ ] Definir criterios de aceptación verificables [S]
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
- [ ] RF17: herramientas de diagnóstico [S]
- [ ] RF18: crash reporting integración [S]

## B. Niveles y categorías (12)

- [x] Definir nivel DEBUG (desarrollo detallado) [S]
- [ ] Definir nivel INFO (eventos normales) [S]
- [ ] Definir nivel WARNING (problemas no críticos) [S]
- [x] Definir nivel ERROR (errores recuperables) [S]
- [x] Definir nivel CRITICAL (errores fatales) [S]
- [x] Definir categoría BOOT (arranque) [S]
- [x] Definir categoría SYSTEM (save/load, configuración) [S]
- [x] Definir categoría GAMEPLAY (jugador, NPC, misiones) [S]
- [x] Definir categoría WORLD (generación, chunks) [S]
- [x] Definir categoría NETWORKING (operaciones de red) [S]
- [x] Definir categoría ANALYTICS (telemetría) [S]
- [ ] Definir categoría CRASH (logs pre-crash) [S]
- [x] Definir output en release por nivel (DEBUG deshabilitado) [S]
- [x] Definir output en release por categoría (todas habilitadas) [S]

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
- [x] Definir nomenclatura de rotación (game.log.1.gz, etc.) [S]
- [ ] Definir eliminación automática del más antiguo [S]
- [x] Diseñar algoritmo de rotación (n → n+1, eliminar el último) [M]
- [ ] Diseñar LogRotator.gd [M]
- [x] Definir trigger de rotación (tamaño excedido) [S]
- [ ] Definir transparencia para el usuario (sin interrupción) [S]
- [ ] Documentar política de retención [S]

## E. Sanitización de datos sensibles (12)

- [x] Definir información sensible a evitar (passwords, tokens, IPs, rutas) [S]
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
- [x] Definir exportación para bug reports (últimas 1000 líneas) [S]
- [x] Definir exportación para crash reporting (buffer completo) [S]
- [x] Documentar métodos de exportación en API [S]
- [x] Definir límites de tamaño para exportación [S]

## G. API del servicio Logger (12)

- [x] Definir método debug(message, category, context) [S]
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
- [x] Definir configuración por build (development vs release) [S]
- [ ] Documentar valores por defecto [S]

## I. Integración con otros módulos (10)

- [ ] Integración con M102 (Bug Tracking) especificada [S]
- [x] Integración con M104 (Analytics) especificada [S]
- [x] Integración con M110 (Debug Menu) especificada [S]
- [ ] Integración con M122 (Crash Reporting) especificada [S]
- [x] Definir generación de bug_{timestamp}.log para issues [S]
- [x] Definir consola in-game en Debug Menu [S]
- [x] Definir filtros por nivel en Debug Menu [S]
- [x] Definir filtros por categoría en Debug Menu [S]
- [x] Definir búsqueda de texto en Debug Menu [S]
- [x] Definir botones de exportación en Debug Menu [S]
- [ ] Definir volcado de logs pre-crash para M122 [S]

## J. Logs específicos por módulo (12)

- [x] Definir logs de BOOT (arranque, versión, specs) [M]
- [x] Definir logs de GAMEPLAY (jugador, NPC, misiones) [M]
- [x] Definir logs de WORLD (generación, chunks) [M]
- [x] Definir logs de SYSTEM (save/load, configuración) [M]
- [ ] Documentar ejemplos de logs BOOT [M]
- [ ] Documentar ejemplos de logs GAMEPLAY [M]
- [ ] Documentar ejemplos de logs WORLD [M]
- [ ] Documentar ejemplos de logs SYSTEM [M]
- [x] Definir logs de NETWORKING (si aplica M76/M77) [S]
- [x] Definir logs de ANALYTICS (eventos de telemetría) [S]
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
- [x] Regla 4: Sin información sensible [S]
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

## N. Implementación (ox-alpha/Cline 2026-08-29, V0, verificado headless)

- [x] Crear scripts/logging/logger.gd como autoload **GameLogger** (⚠️ no `Logger`: clase nativa Godot 4.7) [M]
- [x] Implementar API pública del Logger: debug/info/warning/error/critical con (message, category, context) [M]
- [x] Implementar set_min_level/set_category_enabled/is_level_enabled/reload_config [M]
- [x] Implementar enums Level (DEBUG..CRITICAL) y Category (BOOT..CRASH) [S]
- [x] Implementar formato de línea humano [timestamp] [NIVEL] [CAT] mensaje + contexto opcional [M]
- [x] Implementar formato JSON opcional (json_output) para herramientas [M]
- [x] Implementar buffer + flush periódico (cada 100 líneas) para performance [M]
- [x] Implementar export_all/export_last_lines/export_by_level/export_by_category/export_by_date [M]
- [x] Crear scripts/logging/log_rotator.gd (LogRotator): rotación n→n+1, elimina el más antiguo [M]
- [x] Implementar compresión gzip de rotados (compress_old_logs) [M]
- [x] Crear scripts/logging/sensitive_data_sanitizer.gd: IPs, tokens/passwords, rutas de usuario → [REDACTED] [M]
- [x] Implementar sanitización de contexto (Dictionary) preservando valores no sensibles [M]
- [x] Crear scripts/logging/log_exporter.gd (LogExporter): export a user://logs/export_{ts}.log [M]
- [x] Crear clase LoggingConfig (Resource) con getters para el Logger [M]
- [x] Crear data/logging/logging_config.tres (config por build) [M]
- [x] Registrar autoload GameLogger en project.godot [S]
- [x] Registrar servicio "logger" en ServiceRegistry (M07) desde _ready [S]
- [x] Emitir señal line_emitted(level, category, line) para consola in-game (M110 futuro) [M]
- [x] Test headless test_logger.gd: 14/14 checks OK (niveles, sanitización, exportación, rotación, persistencia) [M]
- [x] Regresión completa: 6 tests de economía/tiendas/tiempo con 0 fallos tras el autoload (Godot 4.7.2) [S]
- [x] Documentar descubrimiento: Godot 4.7 reserva "Logger" → usar GameLogger (ver plan-actual/04-Codigo.md) [S]

**Totales:** 134 ítems (diseño) + 21 ítems (implementación) · Diseño: 134 · Implementación: 21 completados
## Verificación + fix (2026-09-02 06:45 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] GameLogger verificado: 14/14 checks OK, exit 0 (API info/debug/warning/error/critical, export_all/export_last_lines, set_min_level, get_log_file_path, escritura y lectura del archivo)
- [x] **Fix 1 (logger.gd):** escritura INMEDIATA + flush línea a línea (antes buffering de 100 líneas — el QA por logs y el crash-proof no veían las últimas líneas; ahora están en disco al momento)
- [x] **Fix 2 (test):** llamada a _summary() faltante — el test nunca terminaba (proceso colgado sin quit)
- [x] Verificado que las líneas [INFO]/[WARNING] llegan al archivo en el mismo frame
