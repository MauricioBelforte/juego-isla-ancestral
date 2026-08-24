**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 74: Eventos

## ID del Módulo
- **Código:** M74 (Eventos)
- **Carpeta:** `DOCUMENTACION/74-Eventos/`
- **Dependencias:** M29 (Tiempo y Calendario — fechas, estaciones, cumpleaños), M30 (Reloj en Tiempo Real — hora del día, badges), M32 (Clima — festivales con lluvia/nieve), M19 (NPC y Vecinos — participación de aldeanos), M21 (Diálogos — guiones de festival), M53 (UI/UX — pantallas y HUD), M94 (Anti-FOMO — reglas de no pérdida de contenido)
- **Delegable desde:** hoy (documentación completa; implementación pura sobre los servicios de calendario y clima)

## 1. Problema

Aurora es una isla **cozy** donde el pueblo vive: ferias, festivales estacionales, competencias, rituales ancestrales y sorpresas le dan vida al mundo. El plan maestro pide que los festivales sean **momentos de conexión** con el pueblo (no obligaciones ni castigos), que los eventos se **repitan cada año** y que **ningún contenido se pierda para siempre** (regla roja anti-FOMO, M94). Sin un módulo de eventos, las fechas del calendario (M29) existen pero no producen vida: el pueblo no celebra, no hay recompensas, no hay sorpresas.

## 2. Objetivos

1. Definir un **sistema de eventos** dirigido por datos: cada evento es una definición (fecha, condición, duración, recompensas) que el mundo consulta.
2. Programar eventos en el calendario Aurora: festivales anuales, ferias, competencias, rituales, sorpresas y eventos climáticos especiales.
3. **Disparar** los eventos con anticipación, al comenzar y al terminar, con progreso visual al jugador (aviso previo, banner de inicio, cierre).
4. Habilitar **participación** con condiciones claras (hora, estación, progreso de historia, amistad con NPCs).
5. Entregar **recompensas** seguras (sin duplicados por re-entrada) y registrar resultados persistidos.
6. Garantizar **repetibilidad anual** y **ausencia de FOMO** (M94): todo evento repetible, nada exclusivo irrecuperable, mundo congelado offline (M30).

## 3. Alcance

**Incluye:**
- Definición de eventos por datos (archivos `.tres` de recurso `EventDefinition`).
- Catálogo inicial: festivales de las 4 estaciones, ferias del pueblo, competencias (pesca M34, minería M35, agrícola M33), rituales ancestrales (M24/M25 templos), eventos climáticos especiales (M32), sorpresas (visitas, regalos).
- Motor de disparo automático conectado a `GameClock`/`EventBus` de M29/M30.
- Sistema de participación: entrada, escenario/recinto del evento, minijuegos y diálogos del festival (M21).
- Sistema de recompensas con token anti-duplicado y persistencia.
- UI de festival: banner de aviso previo, panel de agenda, marcador de "hoy hay evento", ventana de festival (M53).
- Registro histórico por partida (qué celebraciones se vivieron cada año).

**Excluye:**
- La implementación de cada minijuego específico (se definen aquí los contratos; los contenidos concretos se agregan como datos sin tocar el motor).
- La escritura de todos los guiones de diálogo del festival (los consume M21; se proveen ganchos y plantillas).
- El sistema de economía de la feria (precios/premios pertenecen a M38/M39; aquí solo se referencian).
- Decisiones de arte/audio (se referencian recursos en M41/M42/M43 sin crearlos).

## 4. Restricciones

- **Idioma y motor:** Godot 4.x + Voxel Tools, **GDScript** (nunca C#), recursos `.tres` para datos.
- **Anti-FOMO (M94):** ningún evento otorga contenido único e irrecuperable; si un evento anual se pierde, se repite el año siguiente; las recompensas importantes tienen rutas alternativas (tiendas, museo M37, misiones M22/M23).
- **Determinismo:** el disparo de eventos depende solo del estado de partida (fecha interna M29, clima M32), nunca del reloj del SO (regla M30).
- **Bloqueo de sesión:** el mundo se congela offline; un evento no puede "perderse" por no jugar (se retoma dentro del mismo año si el jugador conecta ese día).
- **Modularidad (M09):** `EventManager` es un servicio expuesto (ServiceLocator M07 — en este proyecto: autoload/node registrado), sin acoplarse a la UI; la UI solo consume señales y métodos públicos.
- **Rendimiento:** cero polling por frame; todo por señales del `EventBus` o checks baratos al cambiar de día/sesión.
- **Persistencia:** el registro de eventos participados/ganados se guarda en `GameState` (M60) con versionado.
- **No tocar sistemas estables:** M19/M21/M29/M30/M32 no se modifican; M74 solo **consume** sus APIs y se integra por señales.

## 5. Requisitos Funcionales (RF)

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Definición por datos | `EventDefinition` (`.tres`) con: id, tipo, nombre localizable, fecha/día, franja horaria, estación opcional, condición de disparo, duración, recompensas, escena/recinto |
| RF2 | Programación en calendario | Registro automático de eventos en la agenda de M29; consulta "eventos del día" y "eventos próximos" |
| RF3 | Disparo con aviso previo | Aviso N días antes (configurable por evento, default 3); señal `evento_proximo` en EventBus |
| RF4 | Inicio del evento | Al llegar la fecha+franja: señal `evento_iniciado`, banner UI, apertura del recinto, NPCs reposicionados (M19 vía rutinas) |
| RF5 | Participación | Entrada al evento con condiciones verificadas (hora, requisitos, inventario, amistad, historia); si falla condición → feedback claro sin bloqueo del juego |
| RF6 | Recompensas | Entrega segura: chequeo de estado, token anti-duplicado por partida y por año, registro de recepción; recompensas de feria (moneda M38), objetos (M14), amistad (M20), progresión (M71) |
| RF7 | Repetibilidad anual | Todo festival se reprograma el año siguiente automáticamente; resultados anuales bicampeones maestros (anillo dorado en la plaza con los años ganados) |
| RF8 | Eventos climáticos | Eventos gatillados por condiciones de M32 (lluvia, nieve, aurora boreal) con comportamiento seguro: el festival principal corre igual bajo lluvia, con variante cerrada para eventos de exterior |
| RF9 | Sorpresas | Eventos espontáneos (visitas, regalos, criaturas) con probabilidad por día, límite por semana, sin solaparse con festivales |
| RF10 | Agenda y UI | Panel de agenda (festivales del año y del día), badge en el reloj (M30), banner de inicio/fin, tutorial de "primer festival" (M92) |
| RF11 | Historial por partida | Registro persistido de eventos participados/completados por año (galería de recuerdos, ítems del museo M37) |
| RF12 | Fallback anti-error | Si una escena/recinto del evento falta o falla la carga (M63), el evento se cancela con aviso amable y recompensa compensatoria descartable, sin crashear |

## 6. Requisitos No Funcionales (RN)

- **RN1 — Rendimiento:** el tick de eventos no supera 0.05 ms por frame; cero polling continuo; la agenda se recalcula al cambiar de día/sesión.
- **RN2 — Memoria:** los `EventDefinition` se cargan bajo demanda; el catálogo completo de datos es < 1 MB.
- **RN3 — Persistencia estable:** esquema de guardado versionado (M60); corrupción de historial → se reconstruye con datos del calendario sin perder partida.
- **RN4 — Accesibilidad (M58):** todos los avisos de eventos con texto + ícono; opción de pausar avisos; soporte de alto contraste en banners.
- **RN5 — Localización (M57):** nombres y descripciones de eventos desde tablas localizables; nunca texto hardcodeado en GDScript.
- **RN6 — Determinismo:** misma semilla de partida → mismos eventos programados; sin dependencia de fecha real del SO.
- **RN7 — Seguridad de datos:** las recompensas se validan dos veces (definición + estado guardado); no se puede clonar recompensas por re-entrada rápida.
- **RN8 — Frame budget de UI:** banners y agenda usan animación de entrada única; no hay animaciones que bloqueen el juego (UI no-modal).
- **RN9 — Modularidad:** `EventManager` no referencia escenas de UI concretas; la UI de festival se suscribe a señales (`evento_iniciado`, etc.).
- **RN10 — Anti-FOMO (M94):** auditoría por cada evento: repetible, recompensa accesible por otra vía, sin contenido irrecuperable. Checklist por evento en datos.

## 7. Criterios de Aceptación

1. Los 4 tipos de evento (festival anual, feria, competencia, sorpresa/climático) se disparan correctamente en fechas programadas por M29/M30.
2. Un jugador que se pierde un festival lo encuentra **el año siguiente**, con la misma recompensa disponible (sin duplicado el mismo año).
3. El evento con lluvia (M32) ejecuta su variante segura sin romper escenas ni atascos.
4. El panel de agenda muestra el año completo con avisos previos correctos.
5. El historial por partida persiste tras guardar/cargar y no se corrompe.
6. Todos los requisitos funcionales y no funcionales verificables están en el `05-Checklist.md` con su caso de prueba.
7. La integración con M19/M21/M29/M30/M32 no requiere modificar ninguno de esos módulos (solo consumo de APIs y señales).

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M029** — Tiempo y Calendario | Eventos calendario |
| **M030** — Reloj en Tiempo Real | Base para reloj en tiempo real |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M029** — Tiempo y Calendario | Depende de este módulo |
| **M030** — Reloj en Tiempo Real | Depende de este módulo |

