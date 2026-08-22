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
---

## 4. EXPANSIONES COZY (2026-08-22)

### 4.1 Festivales Estacionales

Inspirado en Tsuki's Odyssey y Stardew Valley, cada estación tiene un festival único.

| Estación | Festival | Contenido | Recompensa |
|----------|----------|-----------|------------|
| Primavera | Festival de las Flores | Decorar el pueblo con flores | Mueble floral exclusivo |
| Verano | Festival del Mar | Pesca especial, playa | Caña de oro temporal |
| Otoño | Festival de la Cosecha | Comida, trueques | Receta secreta |
| Invierno | Festival de la Luz | Velas, fuegos artificiales | Lámpara encantada |

#### Reglas de Festivales

- Cada festival dura 3 días del juego (M29)
- Todos los NPCs participan (rutinas especiales)
- Hay actividades únicas (minijuegos, pesca especial, etc.)
- Los items del festival son coleccionables (solo disponibles ese año)
- No hay penalización por perderse un festival (se repite cada año)
- Los festivales son la principal fuente de items exclusivos

### 4.2 Eventos Diarios

| Evento | Frecuencia | Contenido |
|--------|------------|-----------|
| Mercado del pueblo | Todos los días | Tiendas con stock renovado |
| Paseo de NPCs | Diario | NPCs caminan por el pueblo |
| Lluvia de estrellas | 1×/mes | Posibilidad de pedir un deseo (skip time) |
| Visita de mercader | 1×/semana | Mercader viajero con items raros |
| Carta del工会 | 1×/mes | Noticias del pueblo, nuevos NPCs |

### 4.3 Rutinas de NPCs por Hora

| Hora | Acción del NPC |
|------|----------------|
| 06:00 | Despertar |
| 07:00 | Ir a trabajar (tienda/taller) |
| 12:00 | Almuerzo (casa o restaurante) |
| 13:00 | Volver a trabajar |
| 17:00 | Paseo por el pueblo |
| 19:00 | Volver a casa |
| 20:00 | Descanso / visita a vecinos |
| 22:00 | Dormir |

### 4.4 Clima y Rutinas

- Si llueve, los NPCs buscan refugio
- Si hace mucho calor, los NPCs van a la sombra
- Si hay nieve, los NPCs se visten diferente
- El clima afecta las actividades disponibles
- Pero nunca bloquea completamente la vida del pueblo
