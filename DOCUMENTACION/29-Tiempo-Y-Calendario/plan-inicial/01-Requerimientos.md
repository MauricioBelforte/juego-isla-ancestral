**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 29: Tiempo y Calendario

## ID del Módulo
- **Código:** M29 (plan maestro: sección 28 — Tiempo y Calendario)
- **Carpeta:** `DOCUMENTACION/29-Tiempo-Y-Calendario/`
- **Dependencias:** M07 (Arquitectura, GameClock/EventBus). Dependen de este: M30 (Reloj), M31 (Día/Noche), M32 (Clima), M33 (Agricultura), M36 (Fauna), M74 (Eventos)
- **Delegable desde:** hoy (implementación pura de servicios, sin mundo voxel funcional)

## 1. Problema

Aurora necesita un **flujo del tiempo** que organice la rutina del pueblo (NPC, cultivos, tiendas), los festivales y las estaciones — sin frustrar al jugador por contenido pasajero (regla roja).

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Reloj de juego | Tiempo de juego comprimido dentro de la partida |
| RF2 | Calendario | Fecha: día, semana, mes, estación, año |
| RF3 | Estaciones | 4 estaciones con efectos (clima, cultivos, nieve, fauna) |
| RF4 | Eventos periódicos | Festivales, cumpleaños, visitas, eventos semanales/mensuales |
| RF5 | Calendario visible | UI con días marcados y eventos próximos |
| RF6 | Comportamiento por hora | NPC y tiendas siguen rutinas (hook para M19) |
| RF7 | Sin frustración temporal | Todo evento importante es repetible (regla cozy roja) |

## 3. Requisitos No Funcionales

- Sin time-gates de contenido: nada se pierde para siempre.
- GameClock como **servicio** (ServiceLocator M07), no singleton disperso.
- Determinista: semilla de tiempo por partida; el reloj pausa/avanza solo dentro de la sesión.
- Frame budget despreciable (es estado, sin cómputo por frame salvo tick).

## 4. Criterios de Aceptación

1. Los 24 puntos de la sección 28 del plan maestro resueltos.
2. Modelo de fecha/estaciones definido en datos (data/time/*.tres).
3. Eventos periódicos catalogados por ciclo (diario/semanal/mensual/estacional/anual).
4. Contrato GameClock (API pública) escrito para que otros agentes lo consuman.