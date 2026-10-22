**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 143: Lanzamiento

## 1. Arquitectura general
El lanzamiento **no toca el juego**: opera sobre el **entorno de publicación y operación** que rodea a la build:

```
[Build RC final (M142)] ──▶ [Plataformas: Página, Build, Tráiler, Comunicado]
                                    │
        [Operación T0-T72] ◀────────┤
        ├── Dashboards (crashes M105, reviews M106, backend M104, ventas M149)
        ├── Guardias por turnos (roles del runbook M142)
        ├── Triaje de bugs (M101) → cola hotfix 2.0.x
        └── Comunidad (soporte M152 + redes M149)
                                    │
        [Cierre T72-T96] ◀──────────┘
        ├── Informe 72 h (4 ejes) → M144
        ├── Agradecimiento público
        └── Preservación de builds (manifiestos M142)
```

## 2. Flujos principales

### 2.1 Publicación día 0 (T0)
Orden fijo del runbook M142, con verificación a cada paso:
1. **Página** visible (store) — verificar "disponible" en cada plataforma.
2. **Build** liberada — verificar hash igual al `rc-final` + manifest.
3. **Tráiler** publicado en canales oficiales.
4. **Comunicado** (prensa + comunidad) multi-idioma.
- Registro de horas por paso; si una plataforma falla → **detener el resto** (runbook de incidentes).

### 2.2 Monitorización (T0-T72)
- **Crashes**: dashboard M105 con alerta automática al cruzar 0.5%; stacktraces agrupados por zona.
- **Reviews**: ingesta de reviews de todas las plataformas (M106); triaje diario: positivas (respuesta en 48 h), negativas (respuesta en 24 h), urgentes (P0/P1 → comité).
- **Servidores/backend**: latencia, errores 4xx/5xx, disponibilidad; objetivo 99.9%.
- **Compras** (si aplica): transacciones, reembolsos, errores de pago.
- **Saves**: errores de guardado/cloud en sesiones reales; correlación con versiones.
- Guardias por turnos: roles definidos (comunidad, técnico, comercial) en el runbook M142.

### 2.3 Triaje de bugs (T0-T72)
```
Reporte (telemetría/review/soporte) → ticket M101 con buildId
   └─ severidad P0/P1 → comité de release → hotfix 2.0.x
   └─ severidad P2 → cola de actualización (M144)
```
- 100% de reportes con respuesta < 24 h; urgentes < 12 h.

### 2.4 Cierre (T72-T96)
- **Informe 72 h** con 4 ejes de métricas (estabilidad, comunidad, adopción, ventas) → aprobado por el equipo → entregado a M144.
- **Agradecimiento**: post multi-idioma con firmas y fecha; enlace a canales.
- **Preservación de builds**: RC final + hotfixes archivados con manifiestos (M142) en un bucket/carpeta de backups con accesos documentados.

## 3. Estados y decisiones de escalado
| Evento | Umbral | Acción |
|--------|--------|--------|
| Crash rate real | ≥ 0.5% | Alerta + comité en < 4 h + hotfix candidato |
| P0 (bloqueo de juego) en reviews | ≥ 3 reportes únicos | Ticket P0 inmediato + respuesta pública |
| Backend caído | > 15 min | Escalado técnico + comunicación de estado |
| Errores de pago | ≥ 1% de transacciones | Detener promociones + verificación de pasarela |
| Save perdido en cloud | ≥ 5 reportes | Ticket P1 + revisión de S3/servidor + hotfix |

## 4. Organización de guardias (runbook M142)
| Turno | Responsable | Foco |
|-------|-------------|------|
| T0-T24 | Todo el equipo | Publicación + primeros incidentes |
| T24-T48 | Equipo core | Bugs críticos + hotfix |
| T48-T72 | Equipo reducido | Comunidad + estabilidad |
| T72-T96 | Equipo core | Informe + cierre de fase |

## 5. Qué NO se hace en Lanzamiento
- No se modifica la build publicada (solo hotfix aprobado).
- No se promete contenido futuro sin fecha (M144).
- No se revelan datos internos de métricas a la comunidad.
- No se responde a trolls: solo se da respuesta oficial a quejas legítimas.
## Pagina visible en Steam (P-100 riel M143 batch)

### Pagina visible en Steam (y plataformas objetivo) el dia 0
- La pagina de tienda debe estar visible y publica el dia de lanzamiento.
- Plataformas objetivo: Steam (PC), itch.io (opcional), Epic (futuro).

### Verificacion de disponibilidad de la pagina
- Checklist pre-publicacion: screenshots, descripcion, trailer, tags, precio.
- Verificacion manual + automatizada (curl a la URL de la tienda).

### Ventana de publicacion < 30 min entre plataformas
- Publicar en todas las plataformas en < 30 min para evitar desincronizacion.
- Runbook: pasos ordenados con tiempos estimados.

### Detener publicacion si una plataforma falla
- Si una plataforma falla, detener el proceso y reportar.
- Runbook de rollback por plataforma.
## Publicacion y trailer (cola total M143 batch 2)

### Captura de confirmacion de publicacion
- Screenshot de la pagina visible en cada plataforma.
- Archivar como evidencia de lanzamiento.

### Pagina con requisitos, FAQ y descripciones
- Requisitos minimos/recomendados del sistema.
- FAQ con preguntas frecuentes.
- Descripciones sin errores (revision de texto).

### Verificacion de fecha de lanzamiento por region
- Confirmar que la fecha es correcta en cada region (UTC).
- Ajustar si hay desfase por zona horaria.

### Confirmacion de visible para descarga
- Verificar que el juego es descargable tras publicar.
- Test de descarga en cada plataforma.
## Trailer y comunicacion (cola total M143 batch 4)

### Publicacion del trailer final en canales oficiales
- Trailer final publicado en YouTube, Twitter/X, Discord.
- Coordinar fecha/hora de publicacion.

### Publicacion con subtitulos por idioma (M87)
- Subtitulos en espanol, ingles, portugues.
- Sincronizados con el audio.

### Variante corta 15s en redes
- Version de 15 segundos para TikTok/Reels/Shorts.
- Highlights del gameplay.

### Enlace del trailer en la store page
- Embed del trailer en la pagina de Steam.
- Verificar reproduccion automatica.
## Comunicacion y soporte (cola total M143 batch 5)

### Programacion de publicacion horaria sincronizada
- Coordinar hora de publicacion en todas las plataformas.
- Sincronizar con zona horaria objetivo (UTC).

### Comunicado de prensa en 2+ idiomas
- Comunicado de prensa en espanol e ingles.
- Publicar en canales oficiales y medios.

### Comunicado de comunidad
- Mensaje de bienvenida multi-idioma en Discord/Twitter.
- Enlaces a canales de soporte y redes.

### Kit de medios actualizado
- Kit de medios con screenshots, trailer, logo.
- Actualizado con el comunicado.
## Soporte post-lanzamiento (cola total M143 batch 6)

### Canales de soporte abiertos y visibles
- Canales de soporte (Discord, email, Steam) visibles desde la hora 0.
- Enlaces en la store page y en el menu del juego.

### FAQ publicada y enlazada
- FAQ con instalacion, saves, plataformas, problemas comunes.
- Enlazada desde la store page y el juego.

### SLA de respuesta <= 24 h habiles
- Tiempo de respuesta maximo: 24 horas habiles.
- Runbook de escalamiento si se supera.

### Plantillas de respuesta
- Plantillas para bugs, reembolsos, consultas comunes.
- Estandarizar respuestas del equipo de soporte.
## Guardias y metricas de soporte (cola total M143 batch 7)

### Guardias de soporte por turnos (runbook M142)
- Runbook de guardias por turnos para soporte 24/7.
- Rotacion de turnos documentada.

### Canal de estado (incidentes)
- Canal de estado para comunicar incidentes a los jugadores.
- Actualizacion automatica desde el sistema de monitoreo.

### Metrica de tiempo de respuesta por dia
- Medir tiempo de respuesta promedio por dia.
- Dashboard de metricas de soporte.

### Dashboard de crashes activo desde T0
- Dashboard de crashes desde el lanzamiento.
- Integracion con el sistema de crash reporting (M122).
## Alertas y crashes (cola total M143 batch 8)

### Alerta automatica al cruzar 0.5% de crash rate
- Alerta cuando el crash rate supera 0.5%.
- Notificacion al equipo de soporte.

### Agrupacion de stacktraces por zona
- Agrupar stacktraces por zona del codigo.
- Facilitar triaje de crashes.

### Triaje de crashes conocidos vs nuevos
- Clasificar crashes como conocidos o nuevos.
- Priorizar crashes nuevos.

### Plan de comite < 4 h ante alerta
- Comite de respuesta en < 4 horas ante alerta.
- Runbook de escalamiento.
## Reviews y backend (cola total M143 batch 9)

### Registro diario de crash rate
- Registro diario del crash rate por plataforma.
- Almacenamiento en dashboard.

### Ingesta de reviews de todas las plataformas
- Ingestar reviews de Steam, Epic, itch.io.
- Centralizar en un solo dashboard.

### Triaje diario de reviews
- Triaje diario: positivas (resp. 48h), negativas (24h).
- Priorizar reviews negativas para respuesta rapida.

### Respuesta publica a negativas con plan de accion
- Responder publicamente a reviews negativas.
- Incluir plan de accion y seguimiento.
## Metricas y disponibilidad (cola total M143 batch 10)

### Metrica de reviews por dia y por plataforma
- Medir reviews por dia en cada plataforma.
- Dashboard de metricas de reviews.

### Registro de temas recurrentes (para M144)
- Registrar temas recurrentes de soporte.
- Alimentar M144 con datos de soporte.

### Objetivo de disponibilidad 99.9% en las 72 h
- Objetivo de disponibilidad: 99.9% en las primeras 72 h.
- Monitoreo continuo.

### Alerta de caida > 15 min con escalado tecnico
- Alerta si el servicio cae > 15 min.
- Escalado tecnico automatico.
## Backend y telemetria (cola total M143 batch 11)

### Dashboard de backend: latencia y errores 4xx/5xx
- Dashboard de latencia y errores HTTP.
- Monitoreo en tiempo real.

### Comunicacion de estado oficial ante incidentes
- Comunicacion oficial de estado ante incidentes.
- Canal de estado publico.

### Verificacion de telemetria (M104) recibiendo datos
- Verificar que la telemetria recibe datos correctamente.
- Validar eventos.

### Registro de metricas de servidor por hora
- Registro de metricas por hora.
- Almacenamiento historico.
## Pagos y transacciones (cola total M143 batch 12)

### Verificacion de cloud saves (M60) y logros (M59) operativos
- Verificar que cloud saves y logros funcionan post-lanzamiento.
- Test de sincronizacion.

### Dashboard de transacciones (si aplica por plataforma)
- Dashboard de transacciones por plataforma.
- Monitoreo de ventas.

### Alerta de errores de pago >= 1% de transacciones
- Alerta si errores de pago superan 1%.
- Escalamiento automatico.

### Verificacion de reembolsos y soporte de compras
- Verificar proceso de reembolsos.
- Soporte de compras operativo.
## DLC y metricas (cola total M143 batch 13)

### Verificacion de DLC/expansiones si existen
- Verificar que DLCs funcionan post-lanzamiento.
- Test de compatibilidad.

### Registro de metricas de ventas por dia
- Registro de ventas diarias por plataforma.
- Dashboard de ventas.

### Dashboard de errores de guardado/cloud
- Dashboard de errores de guardado y cloud.
- Monitoreo de sync.

### Alerta ante >= 5 reportes de save perdido
- Alerta si hay >= 5 reportes de save perdido.
- Escalamiento automatico.
## Backup y triaje de saves (cola total M143 batch 14)

### Verificacion de backup/reintento automatico (M60)
- Verificar que el backup se crea correctamente.
- Reintento automatico si falla.

### Triaje de saves como P1 (perdida de progreso)
- Los saves con perdida de progreso son P1.
- Prioridad maxima en el triaje.

### Registro diario de metricas de save
- Registro diario de metricas de save.
- Almacenamiento historico.

### Triaje diario de todos los reportes
- Triaje diario de telemetria/reviews/crashes.
- Priorizacion por severidad.