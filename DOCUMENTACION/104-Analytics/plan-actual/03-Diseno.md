**Modelo:** Nemotron 3.5 Lightning
**Plataforma:** Cline

# 03-Diseno.md — Módulo 104: Analytics

## 1. Arquitectura

```
M103 (Logging) ──► Logger Service (niveles, categorías, rotación)
                      │
                      ▼
                      AnalyticsDirector (autoload, singleton)
                      │
              ──► Eventos locales (cola en memoria)
                      │
              ──► Batch Sender (enviado cada 30 min o al cierre)
                      │
              ──► Storage Local (JSON agregado, en Application.persistentDataPath)
                      │
              ──► Configuración M91 (opt-out toggle)
                      │
                      ▼
                      Reportes Agregados (dashboard equipo desarrollo)
```

## 2. Flujo de operación

1. **Captura:** Cuando ocurre un evento RF1-RF7, AnalyticsDirector añade el evento a una cola en memoria local
2. **Filtrado:** Si el jugador ha opt-out (configuración M91), el evento se descarta inmediatamente
3. **Acumulación:** Eventos se acumulan en buffer local JSON, sin información personal
4. **Envio por lotes:** Cada 30 minutos o al cerrar sesión, el Batch Sender comprime y envía datos al servidor de desarrollo (o archivo local para modo offline)
5. **Almacenamiento:** Los datos agregados se almacenan en `persistentDataPath/analytics/aggregated.json` para análisis posterior
6. **Reset:** Al abrir nueva sesión, el buffer se reinicia manteniendo solo las estadísticas acumuladas totales

## 3. Eventos a capturar (RF1-RF7)

| Evento | Datos capturados | Agregación |
|---|---|---|
| Sesión inicio | ID sesión (hash rotativo), hora inicio | Contador de sesiones por día |
| Sesión fin | Duración total, eventos count | Horas de juego acumuladas |
| Área visitada | ID bioma, zona general | Heatmap por zona (no coordenadas) |
| Feature usada | Tipo de feature (fast_travel, crafting, etc.) | Contador de usos por tipo |
| Error/crash | Tipo error, mensaje truncated, stack trace hash | Contador de errores por tipo |
| Pausa reanudación | Duración pausa, motivo | Estadísticas de interrupciones |
| Config cambio | Tipo cambio, valor anterior/nuevo | Uso de configuraciones M91/M90 |

## 4. Privacidad y Anonimización

- **Hashed session ID:** `SHA256(seed + fecha)` que rota cada 24h
- **IP truncada:** Solo los primeros 2 octetos se conservan (región general)
- **Sin nombres de jugadores:** Todos los campos de identificador personal están excluidos
- **Datos sensibles filtrados:** Ubicaciones exactas, nombres de cuenta, hardware details identificables

## 5. QA

- Test M112: cada evento RF1-RF7 se captura y almacena correctamente
- Test de privacidad: verificación de que no hay datos personales en logs exportados
- Test de rendimiento: overhead < 1% en pruebas de profiling extendidas
- Test de opt-out: toggle M91 detiene toda captura inmediatamente
- Test de agregación: datos exportados son solo JSON agregado sin identificadores