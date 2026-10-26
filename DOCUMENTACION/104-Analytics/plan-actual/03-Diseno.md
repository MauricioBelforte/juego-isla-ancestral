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
## Compresion y profileo (cola total M104 batch)

### Compresion gzip antes de envio
- Comprimir datos con gzip antes de enviar.
- Reducir tamano de payload.

### Profileo semanal con TaskManager
- Profileo semanal del rendimiento.
- Deteccion de regresiones.

### Advertencia si overhead > 1%
- Advertir si el overhead de analytics supera 1%.
- Proteger el rendimiento del juego.

### Specs items degradados T207 (2026-10-26, Reflection-Beam-1.0)
- **L40 (P6 toggle opt-out M91):** BUG-070 lote 11 (atria-dawn, evidencia DeepSeek #115): Patrón D con L56 [?] — M91 (gestor_config.gd) existe pero analytics no lo referencia (0 hits); el toggle UI no existe.
- **L56 (toggle reporte analytics menú M91):** requiere UI en gestor_config.gd (M91); backend analytics_director.gd expone esta_opt_out()/establecer_opt_out(); falta widget M91.
- **L57 (visualización estado "Analytics: Activo/Desactivado"):** requiere UI (RichTextLabel/Label en M91/M90); backend expone esta_opt_out().
- **L148 (configuración primera ejecución opt-out por defecto):** diseño actual es opt-in (opt_out=false, analytics ON por defecto); cambiar a opt-out por defecto es decisión de diseño del usuario.
- **L150 (toggle accesible desde M90):** requiere UI en M90/M91; backend expone API, falta widget.
- **L152 (botón "borrar mis datos" en configuración):** analytics_director.gd clear_data() + test 24/0 — BUG-070 lote 11 (atria-dawn, evidencia DeepSeek #115): Patrón D con L58 [?] y L144 [?] — clear_data() funciona (verificado) pero no hay botón/UI: 0 consumidores fuera del módulo.
- **L155 (solo envío en Wi-Fi configurable):** Godot 4.x no expone detección de tipo de red (Wi-Fi vs cable); requiere API de plataforma.
- **L156 (indicador visual de envío en curso):** requiere UI (progress bar/label); backend es offline (sin red en v1).