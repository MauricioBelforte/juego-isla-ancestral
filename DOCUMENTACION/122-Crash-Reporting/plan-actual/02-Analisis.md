**Modelo:** SWE-1.6
**Plataforma:** Devin

# 02-Analisis.md — Módulo 122: Crash Reporting

## 1. Análisis de los puntos del plan maestro (sección 121)

| # | Punto | Resolución |
|---|---|---|
| 1 | Integrar crash reporter | ✅ Crashlytics (Firebase) o Sentry como servicio externo recomendado. Implementación propia como fallback. |
| 2 | Capturar stack trace | ✅ Stack trace completo del crash (funciones, líneas, archivos). |
| 3 | Capturar versión | ✅ Versión del juego (semver) al momento del crash. |
| 4 | Capturar plataforma | ✅ OS (Windows/Linux/macOS), arquitectura (x64), driver de GPU. |
| 5 | Capturar GPU | ✅ Modelo, memoria VRAM, driver version. |
| 6 | Capturar CPU | ✅ Modelo, núcleos, frecuencia. |
| 7 | Capturar memoria | ✅ RAM total, RAM disponible, uso al momento del crash. |
| 8 | Capturar escena | ✅ Escena activa (ruta) al momento del crash. |
| 9 | Capturar contexto seguro | ✅ Información sanitizada (sin datos personales, sin sensitive data). |
| 10 | Agrupar crashes | ✅ Agrupar crashes similares por stack trace hashing. |
| 11 | Priorizar crashes | ✅ Priorizar por frecuencia, severidad (crash vs hang), impacto (todos vs pocos usuarios). |
| 12 | Analizar frecuencia | ✅ Dashboard de estadísticas de frecuencia de crashes por versión. |
| 13 | Corregir crashes críticos | ✅ Workflow: identificar → reproducir → corregir → testear → desplegar. |
| 14 | Crear builds de diagnóstico | ✅ Builds con logs adicionales, asserts no eliminados, símbolos de debug. |
| 15 | Integración con M103 | ✅ Logs de crash en Logging service, marcados como CRITICAL. |

## 2. Alternativas de Crash Reporter

### Opción A: Crashlytics (Firebase)
**Ventajas:**
- Gratis para uso moderado
- Integración nativa con Godot (GDExtension)
- Dashboard potente
- Agrupación automática de crashes
- Soporte para iOS, Android, web (si es necesario)

**Desventajas:**
- Requiere cuenta de Google
- Posibles límites de uso
- Depende de servicio externo

### Opción B: Sentry
**Ventajas:**
- Open source (self-hosted disponible)
- Integración con múltiples plataformas
- Dashboard potente
- Filtros avanzados

**Desventajas:**
- Límites en plan gratuito
- Requiere configuración

### Opción C: Implementación propia
**Ventajas:**
- Total control de datos
- Sin dependencias externas
- Personalización completa

**Desventajas:**
- Desarrollo costoso
- Mantenimiento continuo
- Menos potente que soluciones SaaS

**Decisión:** **Crashlytics (Firebase)** como opción principal, con **Sentry** como fallback y **implementación propia** como último recurso.

## 3. Metadata del sistema a capturar

**Información de hardware:**
- OS: Windows/Linux/macOS + versión
- Arquitectura: x64/x86/ARM
- CPU: modelo, núcleos, frecuencia
- GPU: modelo, VRAM, driver version
- RAM: total, disponible, uso al crash

**Información de software:**
- Versión del juego (semver: v1.0.0)
- Versión de Godot (4.4.1+)
- Modo de ejecución (debug/release)
- Escena activa (ruta)

**Información de contexto:**
- Hora del juego (M29)
- Estación del juego (M31)
- Posición del jugador (coordenadas)
- Seed del mundo (M10)

**Información sanitizada:**
- NO incluir: nombre de usuario, IP, email, datos personales
- NO incluir: contenido de chat, datos de inventario específicos
- SI incluir: categoría de error, tipo de entidad afectada

## 4. Contexto seguro

**Reglas de sanitización:**
- Remover PII (Personally Identifiable Information)
- Remover datos sensibles (API keys, tokens)
- Remover contenido de chat
- Remover datos de usuario específicos
- Incluir solo categorías y tipos

**Ejemplo de contexto seguro:**
```json
{
  "scene": "res://scenes/gameplay/main.tscn",
  "game_time": "12:30",
  "season": "VERANO",
  "player_position": {"x": 100, "y": 10, "z": 200},
  "world_seed": "1234567890",
  "error_category": "WORLD_GENERATION",
  "entity_type": "NPC"
}
```

**Ejemplo de contexto NO seguro:**
```json
{
  "username": "JuanPerez",
  "ip": "192.168.1.1",
  "inventory": {"item_id": "sword", "quantity": 5}
}
```

## 5. Agrupación de crashes

**Criterios de agrupación:**
- Stack trace hashing (funciones clave)
- Tipo de error (null reference, out of bounds, etc.)
- Escena activa
- Versión del juego

**Beneficios:**
- Identificar crashes recurrentes
- Priorizar correcciones
- Reducir duplicidad en reporting

## 6. Priorización de crashes

**Matriz de prioridad:**
| Frecuencia | Severidad | Impacto | Prioridad |
|------------|-----------|---------|-----------|
| Alta | Crash | Todos | 🔴 CRÍTICA |
| Alta | Hang | Todos | 🔴 CRÍTICA |
| Alta | Crash | Algunos | 🟡 ALTA |
| Media | Crash | Todos | 🟡 ALTA |
| Baja | Crash | Algunos | 🟢 MEDIA |
| Baja | Hang | Algunos | 🟢 BAJA |

**Workflow de priorización:**
1. Dashboard muestra crashes por frecuencia
2. Filtrar por severidad (crash vs hang)
3. Filtrar por impacto (todos vs pocos usuarios)
4. Ordenar por prioridad
5. Asignar a desarrollador

## 7. Workflow de corrección de crashes

**Pasos:**
1. **Identificar:** Crash reporter agrupa y prioriza crashes
2. **Reproducir:** Desarrollador reproduce crash con steps reproductibles
3. **Corregir:** Desarrollador corrige bug
4. **Testear:** QA verifica corrección
5. **Desplegar:** Patch con hotfix o versión mayor
6. **Verificar:** Crash reporter confirma reducción de frecuencia

**Integración con M102 (Bug Tracking):**
- Crear issue en GitHub por crash crítico
- Vincular issue con crash en dashboard
- Cerrar issue cuando crash resuelto

## 8. Builds de diagnóstico

**Características:**
- Logs adicionales (M103)
- Asserts no eliminados (debug mode)
- Símbolos de debug para stack traces detallados
- Profiling habilitado (M61)
- Crash reporter en modo verbose

**Uso:**
- Cuando crash no es reproducible en debug
- Cuando crash ocurre solo en release
- Cuando stack trace es insuficiente

## 9. Integración con M103 (Logging)

**Logs de crash:**
- Nivel: CRITICAL
- Categoría: CRASH
- Contenido: stack trace, metadata, contexto seguro
- Formato: JSON para parseo automático

**Trigger:**
- Crash reporter genera log de crash
- Logging service guarda log en archivo
- Crash reporter envía log a servicio externo

## 10. Integración con M102 (Bug Tracking)

**Workflow:**
1. Crash crítico detectado
2. Crear issue en GitHub automáticamente
3. Vincular issue con crash en dashboard
4. Desarrollador corrige y cierra issue
5. Crash reporter marca crash como resuelto

**Plantilla de issue:**
```
[CRASH] Crash en <escena> - <tipo de error>

Stack trace:
<stack trace>

Metadata:
- Versión: v1.0.0
- OS: Windows 10
- GPU: NVIDIA RTX 3060
- CPU: Intel i7-10700K
- RAM: 16 GB

Contexto:
- Escena: res://scenes/gameplay/main.tscn
- Hora: 12:30
- Estación: VERANO
- Posición: (100, 10, 200)

Frecuencia: <n> usuarios afectados
Prioridad: 🔴 CRÍTICA
```

## 11. Integración con M110 (Debug Menu)

**Debug Menu:**
- Panel de "Diagnostics"
- Botón "Test Crash" (para testear crash reporter)
- Botón "Send Crash Report" (envío manual de crash)
- Visualización de metadata del sistema

## 12. Opt-out del usuario

**Opciones:**
- Checkbox en configuración inicial
- Checkbox en settings (M90)
- Botón "No enviar" al primer crash
- Explicación clara de qué datos se envían

**Cumplimiento GDPR:**
- Consentimiento explícito
- Opción de opt-out en cualquier momento
- Datos anonimizados
- Política de privacidad accesible

## 13. Offline mode

**Caché de crashes:**
- Si no hay conexión, crash se guarda localmente
- Al reconectar, crash se envía automáticamente
- Límite de caché: 10 crashes
- Si caché llena, crash más antiguo se descarta

## 14. Performance impact

**Optimizaciones:**
- Crash reporter ligero (no impactar FPS)
- Envío de crash en background
- No enviar datos en tiempo real (batch)
- Compresión de datos antes de envío

## 15. Dashboard de estadísticas

**Métricas:**
- Crashes por versión
- Crashes por plataforma
- Crashes por escena
- Frecuencia de crashes (por 1000 usuarios)
- Tasa de corrección (crashes resueltos / total)

**Visualización:**
- Gráficos de tendencia
- Tablas de crashes priorizados
- Filtros por versión, plataforma, escena
- Exportación de datos (CSV)

## 16. Alertas

**Alertas automáticas:**
- Alerta cuando crash crítico supera umbral (ej: 5% de usuarios)
- Alerta cuando crash nuevo alta frecuencia (ej: >100 usuarios en 24h)
- Notificación por email/Slack a equipo de desarrollo

## 17. Retención de datos

**Política de retención:**
- Crashes retenidos por 90 días
- Crash metadata anonimizada
- Logs de crash retenidos por 30 días
- Cumplimiento GDPR

## 18. Testing de crash reporter

**Tests manuales:**
- Testear crash con "Test Crash" en Debug Menu
- Verificar que crash se envía correctamente
- Verificar que metadata se captura
- Verificar que contexto es seguro
- Testear opt-out
- Testear offline mode

**Tests automáticos:**
- Mock de crash reporter para tests de integración
- Tests de sanitización de contexto
- Tests de agrupación de crashes
