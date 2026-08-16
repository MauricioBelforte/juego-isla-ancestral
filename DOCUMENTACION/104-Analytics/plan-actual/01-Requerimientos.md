**Modelo:** Nemotron 3.5 Lightning
**Plataforma:** Cline

# 01-Requerimientos.md â€” MÃ³dulo 104: Analytics

## ID del MÃ³dulo
- **CÃ³digo:** M104 (plan maestro: componente nuevo - Analytics)
- **Carpeta:** `DOCUMENTACION/104-Analytics/`
- **Dependencias:** M103 (Logging), M61 (Rendimiento), M91 (ConfiguraciÃ³n de Audio)
- **Delegable desde:** diseÃ±o completo; implementaciÃ³n tras sistema de logging/base

## 1. Problema

Recoger y reportar datos de comportamiento del jugador de manera no intrusiva, anonimizada y respetuosa con la privacidad, para ofrecer al equipo de desarrollo informaciÃ³n valiosa sobre patrones de juego, Ã¡reas populares, tiempo de sesiÃ³n y caracterÃ­sticas de uso del modo cozy. Los datos deben ser agregados, nunca individuales, y deben ofrecer una visiÃ³n clara del progreso del proyecto sin comprometer la confianza del jugador.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Eventos de sesiÃ³n | Capturar inicio, pausa, reanudaciÃ³n y fin de sesiÃ³n de juego |
| RF2 | Patrones de movimiento | Registrar Ã¡reas del mundo mÃ¡s visitadas, rutas frecuentes |
| RF3 | Frecuencia de features | Contar uso de caracterÃ­sticas: fast travel, crafting, agricultura, pesca |
| RF4 | Tiempo de juego | Acumular horas por sesiÃ³n y total del jugador (anonimizado) |
| RF5 | Eventos crÃ­ticos | Reportar errores, crashes y excepciones con contexto mÃ­nimo |
| RF6 | ConfiguraciÃ³n de reporte | Permitir al jugador activar/desactivar reporte de anÃ¡lisis |
| RF7 | Formato de datos | Todos los datos en formato JSON agregado, sin informaciÃ³n personal |

## 3. Requisitos No Funcionales

- **Privacidad:** Datos totalmente anonimizados; IP truncada; ID de sesiÃ³n aleatorio
- **Rendimiento:** Overhead < 1% de CPU por frame; logging optimizado
- **Coherencia con M103:** todos los logs de anÃ¡lisis pasan por el servicio Logger (M103)
- **Configurabilidad:** El jugador puede opt-out en cualquier momento (configuraciÃ³n M91)
- **Ancho de banda:** Datos enviados en lotes cada 30 minutos o al cierre de sesiÃ³n

## 4. Criterios de AceptaciÃ³n

1. Se capturan todos los eventos RF1-RF7 sin pÃ©rdida de datos crÃ­ticos.
2. Los datos son totalmente anonimizados (sin IP completa, sin datos personales).
3. Overhead de rendimiento < 1% medido en pruebas de perfilado.
4. El jugador puede desactivar el reporte en cualquier momento desde configuraciÃ³n.
5. Los datos se agregan por lotes y no contienen informaciÃ³n identificable.
6. Delegable para implementaciÃ³n.