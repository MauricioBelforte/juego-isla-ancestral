**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 31: Ciclo Día/Noche

## ID del Módulo
- **Código:** M31 (plan maestro: sección 30 — Ciclo Día/Noche)
- **Carpeta:** `DOCUMENTACION/31-Ciclo-Dia-Noche/`
- **Dependencias:** M29 (GameClock), M07 (entorno/servicios). Consumidores: M36 (Fauna), M41-M44 (Audio), M49 (Iluminación), M63 (Cargas)
- **Delegable desde:** hoy (diseño completo; implementación después de M29/M49)

## 1. Problema

Definir cómo la luz, el cielo y el ambiente cambian con la hora del día (GameClock M29) y qué sistemas se afectan (NPC, fauna, música, sonidos, recursos, actividades), **sin caer en oscuridad excesiva** (pilar cozy) y sin gasto de rendimiento innecesario.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Luz diurna | Sol direccional con intensidad/color según hora y estación |
| RF2 | Luz nocturna | Luna con luz suave + estrellas; NUNCA oscuridad total |
| RF3 | Cielo dinámico | Gradiente cielo/horizonte por hora; nubes; niebla por estación |
| RF4 | Amanecer/atardecer | Gradientes de 90 s de juego (06:00 y 20:00) con transiciones suaves |
| RF5 | Fases | Franjas de gameplay: día, pre-noche, noche profunda, alba (consumidores las consultan) |
| RF6 | Luces artificiales | Refugio, casas y faroles se encienden solos al oscurecer |
| RF7 | Comportamiento por franja | NPC (M19), fauna (M36), música (M41), sonidos (M42), spawn (M15) y actividades (M34, M39) reaccionan a la fase |
| RF8 | Eventos nocturnos | Lluvia de estrellas, fauna nocturna, secretos luminosos (M24/M148) |
| RF9 | Navegación nocturna | Jugar de noche es posible y cómodo (luz ambiental + linterna M13) |

## 3. Requisitos No Funcionales

- **Piso de luz:** la iluminación ambiental nocturna nunca baja de ~0.15 (gamma corregida) — anti-oscuridad absoluta.
- **Rendimiento:** el cielo/sol se actualiza por minuto de juego (señal de M29), no por frame; sombras solo en cascada cercana (M61).
- **Accesibilidad:** opción de "noche con luz mejorada" (M58) sin penalización.
- Sin parpadeos: todas las transiciones interpoladas sin saltos.

## 4. Criterios de Aceptación

1. Los 22 puntos de la sección 30 resueltos (tabla punto por punto).
2. Cronograma de fases horario fijado (compatible con M29: día 06:00-19:59, noche 20:00-05:59).
3. Consumidores definidos con su comportamiento exacto por franja.
4. Regla anti-oscuridad documentada con valores concretos.
5. Módulo marcado delegable (implementación → AGENTE DELEGADO tras M29/M49).

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M029** — Tiempo y Calendario | Ciclo día/noche |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M032** — Clima | Usado por clima |
| **M036** — Fauna | Usado por fauna |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M029** — Tiempo y Calendario | Depende de este módulo |
| **M032** — Clima | Este módulo lo necesita |
| **M036** — Fauna | Este módulo lo necesita |

