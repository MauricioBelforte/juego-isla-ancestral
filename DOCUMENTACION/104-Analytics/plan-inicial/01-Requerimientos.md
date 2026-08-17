**Modelo:** Nemotron 3.5 Lightning
**Plataforma:** Cline

# 01-Requerimientos.md — Módulo 104: Analytics

## ID del Módulo
- **Código:** M104 (plan maestro: componente nuevo - Analytics)
- **Carpeta:** `DOCUMENTACION/104-Analytics/`
- **Dependencias:** M103 (Logging), M61 (Rendimiento), M91 (Configuración de Audio)
- **Delegable desde:** diseño completo; implementación tras sistema de logging/base

## 1. Problema

Recoger y reportar datos de comportamiento del jugador de manera no intrusiva, anonimizada y respetuosa con la privacidad, para ofrecer al equipo de desarrollo información valiosa sobre patrones de juego, áreas populares, tiempo de sesión y características de uso del modo cozy. Los datos deben ser agregados, nunca individuales, y deben ofrecer una visión clara del progreso del proyecto sin comprometer la confianza del jugador.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Eventos de sesión | Capturar inicio, pausa, reanudación y fin de sesión de juego |
| RF2 | Patrones de movimiento | Registrar áreas del mundo más visitadas, rutas frecuentes |
| RF3 | Frecuencia de features | Contar uso de características: fast travel, crafting, agricultura, pesca |
| RF4 | Tiempo de juego | Acumular horas por sesión y total del jugador (anonimizado) |
| RF5 | Eventos críticos | Reportar errores, crashes y excepciones con contexto mínimo |
| RF6 | Configuración de reporte | Permitir al jugador activar/desactivar reporte de análisis |
| RF7 | Formato de datos | Todos los datos en formato JSON agregado, sin información personal |

## 3. Requisitos No Funcionales

- **Privacidad:** Datos totalmente anonimizados; IP truncada; ID de sesión aleatorio
- **Rendimiento:** Overhead < 1% de CPU por frame; logging optimizado
- **Coherencia con M103:** todos los logs de análisis pasan por el servicio Logger (M103)
- **Configurabilidad:** El jugador puede opt-out en cualquier momento (configuración M91)
- **Ancho de banda:** Datos enviados en lotes cada 30 minutos o al cierre de sesión

## 4. Criterios de Aceptación

1. Se capturan todos los eventos RF1-RF7 sin pérdida de datos críticos.
2. Los datos son totalmente anonimizados (sin IP completa, sin datos personales).
3. Overhead de rendimiento < 1% medido en pruebas de perfilado.
4. El jugador puede desactivar el reporte en cualquier momento desde configuración.
5. Los datos se agregan por lotes y no contienen información identificable.
6. Delegable para implementación.
