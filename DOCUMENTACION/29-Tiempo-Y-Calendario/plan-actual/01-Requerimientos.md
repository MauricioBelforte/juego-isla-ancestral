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

## 5. SISTEMA DE FESTIVALES Y EVENTOS (Stardew Valley + Animal Crossing)

**Filosofía:** Los festivales son celebraciones, no obligaciones. Si el jugador se pierde uno, se repite el próximo año. No hay contenido exclusivo permanente.

### 5.1 Calendario del Juego

| Parámetro | Valor | Nota |
|-----------|-------|------|
| 1 día juego | 20 minutos tiempo real | Ajustable |
| 1 semana juego | 7 días = 140 min | — |
| 1 mes juego | 28 días = 560 min | — |
| 1 estación juego | 3 meses = 84 días | — |
| 1 año juego | 4 estaciones = 336 días | ~56 horas reales |

### 5.2 Festivales Estacionales

| Estación | Festival | Duración | Contenido | Recompensa |
|----------|----------|----------|-----------|------------|
| Primavera | Festival de las Flores | 3 días | Decorar el pueblo, buscar flores raras | Mueble floral exclusivo |
| Verano | Festival del Mar | 3 días | Pesca especial, competencia, playa | Caña de oro temporal |
| Otoño | Festival de la Cosecha | 3 días | Comida, trueques, mercado especial | Receta secreta |
| Invierno | Festival de la Luz | 3 días | Velas, fuegos artificiales, medianoche | Lámpara encantada |

#### Reglas de Festivales

| Regla | Detalle |
|-------|---------|
| Duración | 3 días del juego (M29) |
| Participación | Todos los NPCs participan (rutinas especiales) |
| Actividades | Minijuegos, pesca especial, búsqueda del tesoro |
| Items exclusivos | Items coleccionables solo disponibles durante el festival |
| Repetición | Cada festival se repite cada año (sin penalización por perderse) |
| Recompensas |Items exclusivos cosméticos (no bloquean contenido) |

### 5.3 Eventos Periódicos

| Evento | Frecuencia | Contenido | Recompensa |
|--------|------------|-----------|------------|
| Mercado del pueblo | Todos los días | Tiendas con stock renovado | Items variados |
| Paseo de NPCs | Diario | NPCs caminan por el pueblo | +1 amistad al hablar |
| Lluvia de estrellas | 1×/mes | Posibilidad de pedir un deseo | Skip 1 hora juego |
| Visita de mercader | 1×/semana | Mercader viajero con items raros | Items raros |
| Carta del pueblo | 1×/mes | Noticias del pueblo | Información sobre eventos |
| Cumpleaños de NPC | Según calendario | Celebración con el NPC | +5 amistad |
| Día del pueblo | 1×/año | Celebración general | Regalo de todos los NPCs |

### 5.4 Rutinas de NPCs por Hora

| Hora | Acción del NPC | Interacción del jugador |
|------|----------------|------------------------|
| 06:00 | Despertar | No disponible |
| 07:00 | Ir a trabajar | Hablar (diálogo matutino) |
| 08:00 | Trabajar | Regalar (si amistad ≥ 2) |
| 12:00 | Almuerzo | Sentarse juntos (+amistad) |
| 13:00 | Volver a trabajar | Hablar (diálogo de tarde) |
| 17:00 | Paseo por el pueblo | Pasear juntos (+amistad) |
| 19:00 | Volver a casa | Despedirse |
| 20:00 | Descanso | No disponible |
| 22:00 | Dormir | No disponible |

### 5.5 Clima y Rutinas

| Clima | Efecto en NPCs | Efecto en jugador |
|-------|---------------|-------------------|
| Soleado | Pasean más, actividades al aire libre | Todas las actividades disponibles |
| Lluvioso | Buscan refugio, tiendas cerradas | Pesca mejorada (+20% calidad) |
| Nublado | Rutina normal | Sin efecto |
| Nieve | Se visten diferente, menos paseos | Caminar más lento (-10% velocidad) |
| Tormenta | Se quedan en casa | No recommended outdoor activities |

### 5.6 Anti-Frustración Temporal

| Principio | Implementación |
|-----------|---------------|
| Sin FOMO | Los festivales se repiten cada año |
| Sin contenido exclusivo permanente | Los items del festival son cosméticos |
| Sin presión de tiempo | Los eventos duran 3 días (suficiente) |
| Sin penalización por no participar | Los NPCs no se enojan |
| Sin bloqueo de contenido | Todo accesible sin participar en festivales |

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M007** — Arquitectura General | GameClock servicio puro |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M027** — Islas del Mundo | Usado por islas del mundo |
| **M030** — Reloj en Tiempo Real | Reloj en tiempo real |
| **M031** — Ciclo Día/Noche | Ciclo día/noche |
| **M032** — Clima | Clima |
| **M033** — Agricultura | Agricultura |
| **M074** — Eventos | Eventos |
| **M162** — Diálogos Contextuales de NPCs | Diálogos por hora/estación |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M007** — Arquitectura General | Depende de este módulo |
| **M027** — Islas del Mundo | Este módulo lo necesita |
| **M030** — Reloj en Tiempo Real | Este módulo lo necesita |
| **M031** — Ciclo Día/Noche | Este módulo lo necesita |
| **M032** — Clima | Este módulo lo necesita |
| **M033** — Agricultura | Este módulo lo necesita |
| **M074** — Eventos | Este módulo lo necesita |
| **M162** — Diálogos Contextuales de NPCs | Este módulo lo necesita |

