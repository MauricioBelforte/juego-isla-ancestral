**Modelo:** Devin
**Plataforma:** Antigravity

# 02-Analisis.md — Módulo 103: Logging

## 1. Análisis de los puntos del plan maestro (sección 102)

| # | Punto | Resolución |
|---|---|---|
| 1 | Logs de arranque | ✅ Registro de inicialización: Godot version, sistema operativo, GPU, RAM, configuración inicial |
| 2 | Logs de errores | ✅ Captura de excepciones, errores de script, asserts fallidos, stack traces |
| 3 | Logs de save | ✅ Registro de operaciones de guardado: inicio, progreso, éxito/fracaso, tiempo, tamaño |
| 4 | Logs de carga | ✅ Registro de operaciones de carga: archivo, progreso, éxito/fracaso, tiempo |
| 5 | Logs de generación | ✅ Registro de generación procedural: seed, duración, chunks generados, eventos anómalos |
| 6 | Logs de chunks | ✅ Registro de loading/unloading: posición, estado, memoria, tiempo |
| 7 | Logs de NPC | ✅ Registro de comportamiento: estado actual,目标位置, eventos, errores de pathfinding |
| 8 | Logs de misiones | ✅ Registro de progreso: inicio, pasos completados, recompensas, fallos |
| 9 | Logs de networking | ✅ Registro de operaciones: conexión, paquetes, latencia, desconexiones (si aplica M76/M77) |
| 10 | Logs de analytics | ✅ Registro de eventos de telemetría: eventos enviados, fallos de envío (M104) |
| 11 | Niveles de log | ✅ DEBUG, INFO, WARNING, ERROR, CRITICAL con filtros configurables |
| 12 | Logs debug | ✅ Verbosos para desarrollo (detalles internos), deshabilitados en release |
| 13 | Logs release | ✅ Simplificados para producción (solo WARNING+, sin detalles internos) |
| 14 | Evitar información sensible | ✅ Sin passwords, tokens, IPs privadas, datos personales, rutas absolutas del usuario |
| 15 | Rotación de logs | ✅ Límite de 10 MB por archivo, máximo 5 archivos antiguos, compresión gzip |
| 16 | Exportación de logs | ✅ Capacidad de exportar logs filtrados (últimas N líneas, por nivel, por fecha) |
| 17 | Herramientas de diagnóstico | ✅ Filtros por nivel, categoría, tiempo; búsqueda de texto; visualización en consola |
| 18 | Crash reporting | ✅ Integración con M122: volcado de logs pre-crash automáticamente adjuntado |

## 2. Alternativas consideradas

| Enfoque | Pros | Contras | Decisión |
|---|---|---|---|---|
| Godot内置print() | Simple, nativo | Sin niveles, sin rotación, sin estructuración | ❌ Descartado |
| Sistema propio simple | Control total | Requiere implementación desde cero | ⚠️ Parcial |
| Logger estructurado JSON | Parseable, herramientas | Más verboso en archivo | ✅ ELEGIDO (híbrido) |
| Servicio remoto (Sentry) | Crash reporting pro | Costo, complejidad, sobrekill | ❌ Descartado (M122 lo maneja) |

**Decisión final:** Sistema propio híbrido (línea estructurada para humanos, JSON opcional para herramientas), con rotación y niveles.

## 3. Estructura de niveles de log

| Nivel | Uso | Ejemplo | Output en Release |
|---|---|---|---|---|
| DEBUG | Desarrollo detallado | "Chunk generado en (100, 200) con 1234 bloques" | ❌ No |
| INFO | Eventos normales | "Jugador entró a la zona del templo" | ✅ Sí |
| WARNING | Problemas no críticos | "NPC atascado en pathfinding, recalculando..." | ✅ Sí |
| ERROR | Errores recuperables | "Falló carga de textura, usando fallback" | ✅ Sí |
| CRITICAL | Errores fatales | "No se puede guardar el archivo: permiso denegado" | ✅ Sí |

## 4. Categorías de logs (para filtros)

- **BOOT:** Arranque del juego, inicialización
- **SYSTEM:** Eventos del sistema (save/load, configuración)
- **GAMEPLAY:** Eventos de gameplay (jugador, NPC, misiones)
- **WORLD:** Generación de mundo, chunks, voxel
- **NETWORKING:** Operaciones de red (si aplica)
- **ANALYTICS:** Eventos de telemetría
- **CRASH:** Logs pre-crash (M122)

## 5. Formato de línea de log

**Formato humano (console/archivo):**
```
[2026-08-16 17:30:45] [INFO] [GAMEPLAY] Jugador entró a la zona del templo
```

**Formato JSON (opcional, para herramientas):**
```json
{
  "timestamp": "2026-08-16T17:30:45Z",
  "level": "INFO",
  "category": "GAMEPLAY",
  "message": "Jugador entró a la zona del templo",
  "context": {
    "player_id": "player_001",
    "zone": "templo_principal",
    "position": {"x": 100.5, "y": 0.0, "z": 200.3}
  }
}
```

## 6. Rotación de logs

**Política:**
- Tamaño máximo por archivo: 10 MB
- Máximo de archivos rotados: 5 (game.log, game.log.1, ..., game.log.4)
- Compresión: archivos antiguos comprimidos con gzip (.gz)
- Limpieza automática: el más antiguo se elimina cuando se rota

**Nomenclatura:**
- Activo: `game.log`
- Rotados: `game.log.1.gz`, `game.log.2.gz`, ..., `game.log.4.gz`

## 7. Exportación de logs

**Métodos:**
1. **Exportar todo:** Archivo completo `game.log`
2. **Exportar últimas N líneas:** Últimas 1000 líneas (para bug reports)
3. **Exportar por nivel:** Solo ERROR+ y CRITICAL
4. **Exportar por fecha:** Logs de las últimas 24 horas
5. **Exportar por categoría:** Solo WORLD o GAMEPLAY

**Output:** Archivo `logs/export_{timestamp}.log` con el contenido filtrado.

## 8. Integración con otros módulos

### M102 (Bug Tracking)
- El Debug Menu (M110) genera `bug_{timestamp}.log` con las últimas 1000 líneas
- Este archivo se adjunta automáticamente al issue de GitHub

### M104 (Analytics)
- Los eventos de analytics se loguean como INFO categoría ANALYTICS
- Fallos de envío se loguean como WARNING categoría ANALYTICS

### M110 (Debug Menu)
- El Debug Menu muestra logs en tiempo real (consola in-game)
- Permite filtrar por nivel y categoría
- Botón "Exportar logs" genera archivo para bug report

### M122 (Crash Reporting)
- Al crashear, se volca el buffer de logs a `crash_{timestamp}.log`
- Este archivo se adjunta al reporte de crash automáticamente

## 9. Seguridad y privacidad

**Información sensible a evitar:**
- Passwords de usuario
- Tokens de autenticación
- IPs privadas (usar 192.168.x.x → 192.168.0.0/16)
- Rutas absolutas del usuario (c:\Users\Nombre → %USERPROFILE%)
- Datos personales (nombres reales, emails)
- Claves de API

**Sanitización automática:**
- Rutas de archivo: reemplazar con variables de entorno
- IPs: mascarar octetos excepto el primero
- Tokens: detectar patrones y reemplazar con `[REDACTED]`

## 10. Configuración

**Archivo `logging_config.tres`:**
```gdscript
resource_name "LoggingConfig"

level_min = "DEBUG"           # DEBUG, INFO, WARNING, ERROR, CRITICAL
categories_enabled = ["BOOT", "SYSTEM", "GAMEPLAY", "WORLD", "NETWORKING", "ANALYTICS", "CRASH"]
max_file_size_mb = 10
max_rotated_files = 5
compress_old_logs = true
json_output = false           # true para herramientas
sanitize_sensitive = true
```

**Configuración por build:**
- **Development:** level_min = DEBUG, json_output = false
- **Release:** level_min = INFO, json_output = false
- **Debug build:** level_min = DEBUG, json_output = true
