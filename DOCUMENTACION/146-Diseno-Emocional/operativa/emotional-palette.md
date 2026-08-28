**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 146-Diseno-Emocional
**Estado:** Implementación operativa (entregable M146)

---

# Paleta Emocional (`emotional-palette`) — Módulo 146

> Las 6 emociones del juego, su intensidad y frecuencia objetivo. Integra el journey de M145 (`player-journey.md` §1) y los Principios Innegociables (M152). Toda decisión de diseño debe poder nombrar **qué emoción busca**.

## 1. Tabla de la paleta

| Emoción | Rol | Intensidad | Frecuencia | ¿Dónde se siente? |
|---|---|---|---|---|
| **Calma** | Emoción principal (colchón del juego) | Baja-media, sostenida | **Constante** | Exploración libre, pesca, jardinería, lluvia bajo techo, música de base (M41) |
| **Curiosidad** | Emoción secundaria (motor de exploración) | Media | Frecuente | Rumores de NPCs (M148), caminos que se pierden, piezas de lore, cuevas |
| **Satisfacción** | Emoción de logro | Media-alta, corta | Frecuente | Completar una construcción, cerrar misión, craft completo, ordenar el inventario |
| **Asombro** | Emoción de descubrimiento | Alta, muy corta | Infrecuente (dosificada) | Primer amanecer, Templo de la Brisa, vista de la isla, revelaciones de los Sellos |
| **Pertenencia** | Emoción social | Media, creciente | Regular | Amistades que suben nivel (M20), festivales (M74), regalos de NPCs, el pueblo creciendo (M18) |
| **Nostalgia** | Emoción nostálgica (recompensa del tiempo) | Baja-media, tardía | Infrecuente, crece con las horas | Ver estaciones cambiar (M29), revisar fotos (M56), volver a lugares del inicio, museo completo (M37) |

## 2. Reglas de dosificación

1. **La calma es el fondo, no el premio:** siempre debe poder volverse a ella en < 2 minutos (cualquier pico se disuelve en calma).
2. **El asombro se raciona:** máximo 1 momento de asombro cada 2-3 horas de juego (ver `wow-moments.md`).
3. **La satisfacción es el ritmo:** el bucle debe cerrar una micro-satisfacción cada 5-15 minutos.
4. **La nostalgia no se fuerza:** emerge del tiempo jugado; solo se diseñan sus "anclas" (lugares, fotos, museo).
5. **La pertenencia se gana en pequeños gestos:** nombres, recordatorios de NPCs, la casa llena — nunca con fanfarrias.

## 3. Emociones a evitar (y cómo se previenen)

| Emoción a evitar | Disparador típico | Prevención |
|---|---|---|
| **Frustración** | Bloqueos opacos, pérdida de progreso, castigos duros | Sin game over, autosave por hitos (M59/M66), errores informan sin castigar (M145 feedback §3) |
| **Ansiedad** | Timers agresivos, contenido que expira, stock limitado | Nada expira (M94), eventos repetibles, sin streaks |
| **Aburrimiento** | Rutina sin sorpresa ni variedad | Objetivos rotatorios (M94), estaciones que cambian el mundo, 60+ misiones secundarias (M23) |
| **Culpa** | "No jugué y perdí X" | Sin decay de amistades ni de cosechas a largo plazo (M152) |
| **Sobrecarga** | Demasiadas mecánicas nuevas a la vez | Onboarding orgánico secuencial (M145), gating por herramientas (M158) |

## 4. Referencia rápida

> Antes de aprobar cualquier feature: **"¿Qué emoción de la paleta refuerza?"** Si la respuesta es "ninguna" o una de la lista a evitar → rediseñar o derivar a FUTURAS-MEJORAS.

## 5. Guidelines visuales y sonoras rápidas por emoción (intención; implementación = dueños)

| Emoción | Color sugerido (HEX, a validar con M53/M47) | Iluminación (M49) | Composición | Nota sonora (M41/M42) |
|---|---|---|---|---|
| Calma | #A8D8D8 (verde-agua pastel) | Suave, cálida, sin contraluces | Encuadres estables, horizonte medio | Capa base + ambiente constante |
| Curiosidad | #F5E6A8 (amarillo suave) | Puntos de luz que "invitan" a acercarse | Elemento parcialmente oculto en bordes | Motivo que se sugiere y se corta |
| Satisfacción | #B5E0B5 (verde fresco) | Brillo breve del resultado | Centro-encuadre del objeto logrado | Acorde ascendente corto |
| Asombro | #C5B8E8 (lavanda) | Dramática but suave (sin strobe), rayos god | Planos anchos, horizonte bajo | Capa orquestal que se abre |
| Pertenencia | #F2C4C4 (rosa pastel) | Luz de hogar, fuentes cálidas | Grupo en cuadro, jugador incluido | Tema comunitario |
| Nostalgia | #E8C8A8 (ámbar) | Atardeceres, luz de memoria | Objetos con historia en primer plano | Melodía que reutiliza motivos del inicio |

Estos valores son **intención de diseño** (marcadores para M45/M47/M49/M53); la paleta final la valida el dueño con capturas (M154).

## Changelog

| Fecha | Cambio | Autor |
|---|---|---|
| 2026-08-28 | Creación de la paleta emocional y guidelines por emoción (implementación M146, log 200) | GLM (Kilo) |

**Firma del último agente que modificó este documento:**

**Modelo:** GLM
**Plataforma:** Kilo
