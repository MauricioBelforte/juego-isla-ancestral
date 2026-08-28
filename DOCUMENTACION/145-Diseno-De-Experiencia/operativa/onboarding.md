**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 145-Diseno-De-Experiencia
**Estado:** Implementación operativa (entregable M145)

---

# Onboarding (`onboarding`) — Módulo 145

> Eventos guiados, **no tutoriales de texto**. Implementación: M92 (Tutorial, dueño del catálogo) + M22/M19 (narrativa y NPC). Duración objetivo completa: **5-10 minutos**. Sin interrupciones: el jugador aprende jugando (M152).

## 1. Eventos guiados (orden orgánico)

| # | Evento | Disparador orgánico | Enseña | Prerrequisitos |
|---|--------|--------------------|--------|----------------|
| 1 | **Primer paso** | Al tomar control tras la cutscene | WASD + correr + salto | Ninguno |
| 2 | **Primera interacción** | NPC a 2 m mirando al jugador | Tecla F (hablar) | Evento 1 |
| 3 | **Primera herramienta** | Cofre/casa con la herramienta brillando (M13) | Equipar y usar (cavar/golpear) | Evento 2 |
| 4 | **Primera construcción** | Parcela marcada cerca de la casa | Modo construir (M17) | Evento 3 |
| 5 | **Primera misión** | NPC con "!" suave (no exclamación roja gigante) | Diario (M55) y objetivos | Evento 2 |
| 6 | **Primer viaje** | Muelle con bote (post-Sello 1, M28) | Mapa (M54) y fast travel opcional (M69) | Misión inicial activa |

Reglas de los eventos:
1. **Contextuales, nunca modales:** un indicador en el mundo, no un panel que bloquea.
2. **Progresión sin prisa:** cada evento se dispara cuando el jugador está cerca de su contexto natural.
3. **Sin castigo por ignorarlos:** el juego avanza igual; el recordatorio vuelve suavizado (regla M152).
4. **Textos ≤ 2 líneas** con símbolo visual (M46) y sonido suave (M43).

## 2. Opción de saltar y recordatorios

- **Saltar:** cada evento puede ocultarse definitivamente desde su propio indicador ("no volver a mostrar") y globalmente en Opciones → Accesibilidad/Jugabilidad (M58/M90).
- **Recordatorios para jugadores perdidos:** si el jugador lleva > 20 min sin progresar en la misión activa, un NPC cercano ofrece una pista conversacional (M21) — nunca un popup.
- **Ayuda contextual F1:** pantalla de referencia de controles (M57) consultable siempre.

## 3. Flujo de onboarding (secuencia orgánica)

```
Cutscene → [1 mover] → [2 hablar] → misión 1 abierta →
[3 herramienta] → [4 construir] → primer objetivo cumplido (farol/faro) →
[5 misión/diario] → onboarding "termina" cuando el jugador elige su próxima
actividad libremente (señal de éxito: deja de seguir la guía)
→ [6 viaje] se descubrirá más tarde, orgánicamente
```

Señal de cierre de onboarding: el jugador realiza **3 acciones consecutivas sin indicador guiado** → el sistema marca onboarding completado (métrica, M105).

## 4. Métricas de onboarding

| Métrica | Definición | Objetivo |
|---|---|---|
| Tasa de completado | % de nuevas partidas que llegan al cierre orgánico | ≥ 90 % |
| Tiempo medio | Desde control del jugador hasta cierre orgánico | 5-10 min |
| Abandono por evento | % que abandona dentro de 5 min tras cada evento | < 3 % por evento |
| % que salta | % que oculta los eventos | informativo (sin objetivo) |

Fuente: M105 (telemetría de gameplay); revisión mensual (ver `metrics.md`).

## 5. Testing del onboarding

- **Plan y guía:** ver `plan-testing-experiencia.md` (sesiones con jugadores nuevos en el vertical slice M138, vía M114).
- **Iteración:** por cada evento con >3 % de abandono, rediseño del disparador o del texto; registro de cambios en el checklist de M92.

**Firma del último agente que modificó este documento:**

**Modelo:** GLM
**Plataforma:** Kilo
