**Modelo:** Nemotron 3.5 Lightning
**Plataforma:** Cline

# 02-Analisis.md — Módulo 104: Analytics

## 1. Resolución de los puntos del plan

| # | Punto | Resolución |
|---|---|---|
| 1 | Eventos de sesión | Capturar timestamp de inicio, duración, hora del día (usando M29/M31) |
| 2 | Patrones de movimiento | Mapeo de calor (heatmap) de áreas visitadas, anonimizado por zona |
| 3 | Frecuencia de features | Contadores por tipo: usos de fast travel, crafting completado, agricultura cosechada, peces capturados |
| 4 | Tiempo de juego | Acumulación horaria total y por sesión, guardada en M103 Logger |
| 5 | Eventos críticos | Errores, crashes, excepciones con stack trace truncated (sin variables personales) |
| 6 | Configuración de reporte | Toggle en menú de configuración (M91); opt-out global por jugador |
| 7 | Formato de datos | JSON estructurado con tipo de evento, contador, metadatos agregados |

## 2. Decisiones clave

1. **Anonimización por diseño:** Todo dato de analytics se anonimiza al capturar. Los IDs de sesión son hashes rotativos que cambian cada 24h. Nunca se almacenan nombres de jugadores, posiciones exactas o IDs de cuenta.

2. **Agregación en tiempo real:** Los contadores se agregan localmente y solo se envían lotes cada 30 minutos o al cierre de sesión. Esto minimiza el impacto en el ancho de banda y en el rendimiento del juego.

3. **Opt-out respetado:** El toggle de reporte está prominentemente visible en el menú de configuración (M91). Si el jugador desactiva el reporte, se detiene toda captura de datos inmediatamente y se borra el buffer local.

4. **Integración con M103:** Todos los eventos de analytics pasan a través del servicio Logger (M103) con nivel INFO, lo que asegura también el logging de consola y archivo para desarrollo, pero mantiene los datos de analytics separados y agregados.

5. **Heatmap por zona, no por coordenada:** En lugar de guardar coordenadas GPS exactas, el mundo se divide en regiones/biomas y se registra qué zonas fueron visitadas con mayor frecuencia. Esto provee datos valiosos sin comprometer la privacidad.

## 3. Alternativas descartadas

- **Tracking de coordenadas exactas:** Descartado por privacidad; riesgos de cumplimiento GDPR y expectativa del usuario de anonimato.
- **Perfiles de jugadores individuales:** Descartado; contradictorio con el diseño cozy y principios de privacidad del proyecto.
- **Enviado de datos en tiempo real continuo:** Descartado; alto overhead de batería/red y posible fricción para el usuario.
- **Perfilamiento de hardware detallado:** Descartado; innecesario para los objetivos de diseño y complejidad innecesaria.