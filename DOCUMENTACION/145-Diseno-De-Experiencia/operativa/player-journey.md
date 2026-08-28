**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 145-Diseno-De-Experiencia
**Estado:** Implementación operativa (entregable M145)

---

# Player Journey (`player-journey`) — Módulo 145

> Estándar de experiencia del jugador de punta a punta. Los dueños de implementación: M22 (historia), M92 (tutorial/eventos), M89 (menús), M94 (retención), M153 (objetivo verificable). Principio rector (M152): cozy, sin FOMO, sin castigos irreversibles.

## 1. Fases del journey

| # | Fase | Qué vive el jugador | Emoción objetivo | Punto de decisión |
|---|------|---------------------|------------------|-------------------|
| 1 | Descubrimiento | Trailer, capturas, página de tienda | Curiosidad, calma anticipada | Comprar / wishlist |
| 2 | Primera vez | Apertura, menú principal, nueva partida | Acogida (casa/abuela, 05-DOCU diseño) | Elegir perfil/slot (M89) |
| 3 | Introducción | Cutscene inicial, primer NPC (Finneas), primer objetivo | Maravilla del mundo | Aceptar primera misión |
| 4 | Primeros pasos | Movimiento, interacción F, primera herramienta, primer recurso | Competencia creciente | Qué explorar primero |
| 5 | Juego principal | Exploración, misiones, construcción, agricultura, pesca | Flujo cozy (calma+logro alternados) | Qué sistema profundizar |
| 6 | Progresión | Sellos (M22), desbloqueos de zonas (M158), mejoras | Propósito, orgaña silenciosa | Seguir la historia o la vida en la isla |
| 7 | Postgame | Coleccionables (M73), museo (M37), festivales (M74) | Nostalgia cálida, maestría | Qué completar (sin presión, M94) |

## 2. Diagrama del journey (ASCII)

```
[Descubrimiento]→[Primera vez]→[Introducción]→[Primeros pasos]     (0-60 min)
      store        menú/slot      cutscene+NPC      mover/F/herramienta
                                                            │
        ┌───────────────────────────────────────────────────┘
        ▼
   [Juego principal] ⇄ (bucle diario cozy: tareas cortas + exploración libre)
        │  desbloqueos por Sellos (M22) y zonas (M158)
        ▼
   [Progresión] → 6 Sellos → historia completa
        │
        ▼
   [Postgame] → coleccionables, museo, festivales (sin FOMO: todo repetible)
```

## 3. Momentos "wow" (diseño intencional)

1. **Primer amanecer sobre Aurora** con música de capas (M41) — minutos 10-20.
2. **Primera restauración del faro** (objetivo corto del GDD, M138 slice).
3. **Apertura del Templo de la Brisa** (puzzle → revelación de historia, M22/M24).
4. **Primer viaje inter-isla** (Gran Vapor a Coral, M27/M28).
5. **Museo completo** con pieza final recompensando la curiosidad (M37).

## 4. Puntos de abandono potenciales y su mitigación

| Riesgo de abandono | Fase | Mitigación |
|---|---|---|
| Onboarding lento o verbal | 3-4 | Eventos guiados orgánicos ≤ 10 min (ver `onboarding.md`), opción de saltar |
| No saber qué hacer después del tutorial | 4-5 | Objetivos rotatorios sobremesa (M94), diario (M55), NPC que sugieren (M21) |
| Fricción de guardado/pérdida | 4-5 | Autosave por hitos (M59/M66), sin castigo por morir/olvidar |
| Grind para avanzar historia | 6 | Sellos por hitos jugables, no por repetición; economía cozy (M152) |
| Contenido que expira | Todos | Regla anti-FOMO total (M94): nada expira, todo vuelve |

## 5. Ritmo de revelación de contenido

- Por **Sellos** (M22/M147): capas de revelación progresivas del misterio de la isla.
- Por **herramientas/zonas** (M158): gating natural sin paredes artificiales.
- Por **estaciones** (M29/M74): contenido estacional que vuelve (nunca expira).
- Regla 0/0 (M148): el lore se revela jugando, nunca en infodumps.

## 6. Métricas clave por fase (detalle en `metrics.md`)

| Fase | Métrica principal | Fuente |
|---|---|---|
| Descubrimiento | Conversión página→wishlist (M97/M99) | Steam (manual) |
| Primera vez | Tiempo hasta primer objetivo | M105 telemetría |
| Introducción/Primeros pasos | Tasa de completado de onboarding | M105 |
| Juego principal | Sesiones/semana, duración media | M105 |
| Progresión | Sellos completados por jugador | M105 |
| Postgame | % de jugadores en postgame con ≥5 h | M105 |

**Firma del último agente que modificó este documento:**

**Modelo:** GLM
**Plataforma:** Kilo
