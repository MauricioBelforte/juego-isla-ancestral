**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 28: Viajes

## ID del Módulo
- **Código:** M28 (plan maestro: sección 27 — Viajes)
- **Carpeta:** `DOCUMENTACION/28-Viajes/`
- **Dependencias:** M22 (Historia), M27 (Islas del Mundo). Relaciones: M32 (Clima), M63 (Cargas y Streaming), M69 (Fast Travel), M29 (Tiempo y Calendario), M58 (Guardado), M38 (Economía), M50 (Agua), M51 (Partículas y VFX), M40/M41/M42 (Música y Sonido), M52/M56 (UI/UX)
- **Delegable desde:** hoy (diseño completo; implementación tras M27 y M63)

## 1. Problema

El jugador vive en la isla principal de Aurora pero el mundo se compone de múltiples islas (M27). Se necesita un sistema que permita desplazarse entre ellas de forma **cozy, creíble y sin fricción**: sin pantallas de carga largas ni barreras frustrantes, integrado con la narrativa del **Gran Vapor** (barco de vapor que conecta puertos), con costes, horarios y bloqueos suaves. El clima (M32) puede **retrasar** los viajes pero **nunca bloquearlos** por completo, preservando la sensación relajada del juego.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Boleto y reserva | El jugador compra un boleto (M38) y reserva plaza para un destino; la reserva se valida contra capacidad del vapor |
| RF2 | Embarque | Animación de embarque guiada desde el muelle del puerto hacia el barco; el jugador no controla el movimiento durante el embarque |
| RF3 | Travesía visible | Viaje con travesía simulada corta y visible: el Gran Vapor navega por el mar con cámara cinematográfica, el jugador puede moverse a bordo |
| RF4 | Llegada a puertos | Llegada con atraque automático al muelle de la isla destino; el jugador desembarca con una transición suave |
| RF5 | Viaje rápido | Viaje rápido (M69) disponible solo entre puntos desbloqueados; costoso en moneda y requiere haber visitado el destino antes |
| RF6 | Clima (M32) | El clima adverso retrasa la salida o el trayecto (espera corta), pero nunca impide viajar; aviso claro al jugador |
| RF7 | Cancelación | El jugador puede cancelar el viaje antes de partir; el boleto se devuelve parcial o totalmente según política |
| RF8 | Viajes especiales | Viajes con horario especial: nocturnos, estacionales (M29) y expediciones secretas desbloqueables |
| RF9 | Eventos en el trayecto | Eventos suaves durante la travesía: NPC viajeros, objetos coleccionables visibles en el mar, diálogos breves |
| RF10 | Transporte de recursos | El jugador puede transportar recursos en el almacén del vapor (cantidad limitada) |

## 3. Requisitos No Funcionales

- **Cozy:** cero tensión; los retrasos por clima se presentan con diálogo amable del capitán y música tranquila.
- **Tiempos:** travesía simulada de 20–60 s reales según distancia (nunca más de 90 s); viaje rápido instantáneo con transición de 2–3 s.
- **Rendimiento (M61):** durante la travesía la isla de origen se descarga y la de destino se precarga con M63 (streaming); budget de frame ≤ 16 ms en travesía.
- **Sin bloqueos duros:** ningún clima, muelle ocupado o evento puede dejar al jugador atrapado sin salida; siempre existe un fallback.
- **Accesibilidad (M57):** opción de "travesía acelerada" que reduce el tiempo del trayecto a la mitad.
- **Guardado (M58):** el estado del viaje (ruta activa, destino, tiempo restante) es serializable y se restaura correctamente.

## 4. Criterios de Aceptación

1. Los 25 puntos de la sección 27 resueltos en el diseño.
2. Sistema de embarcar → travesía visible → llegar funcionando de punta a punta con el Gran Vapor.
3. Clima M32 retrasa pero nunca bloquea; verificado con tormenta y niebla.
4. Viaje rápido (M69) costoso y condicionado a desbloqueos.
5. Muelle ocupado y cancelación resueltos con reglas concretas (cola de espera, devolución).
6. Streaming M63 integrado: sin pausas visibles de carga en la transición entre islas.
7. Delegable para implementación.