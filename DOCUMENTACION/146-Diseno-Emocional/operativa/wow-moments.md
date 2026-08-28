**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 146-Diseno-Emocional
**Estado:** Implementación operativa (entregable M146)

---

# Wow Moments (`wow-moments`) — Módulo 146

> Los 8 momentos memorables del juego, cada uno con su estructura de diseño (setup → reveal → payoff → afterglow) y presupuesto por fase. Integración: los 5 "wow" del journey (M145 §3) están incluidos aquí con más detalle.

## 1. Estructura estándar de un wow moment

| Etapa | Qué es | Regla |
|---|---|---|
| **Setup** | Preparación que el jugador vive (no cutscene) | Debe involucrar acción o anticipación del jugador |
| **Reveal** | El momento en sí | ≤ 30 s de atención dirigida; audio+visual coordinados (M41/M49/M52) |
| **Payoff** | Recompensa tangible o narrativa | Siempre hay algo que conservar (objeto, recuerdo, desbloqueo) |
| **Afterglow** | Calma posterior | ≥ 2 min de juego libre sin nuevo pico (dosificación de paleta) |

## 2. Los 8 wow moments

### WM-1 — Primera vista de Aurora (Asombro · Introducción)
- **Setup:** despertar en la playa tras la cutscene; cámara libre.
- **Reveal:** al girar, la isla completa al fondo con música de capas abriéndose (M41).
- **Payoff:** el mapa se activa con la vista como miniatura (M54).
- **Afterglow:** caminar libre por la playa, sin misión forzada durante 2 min.

### WM-2 — Primera casa completada (Satisfacción · Primeras horas)
- **Setup:** la casa en reparación con piezas faltantes visibles día a día.
- **Reveal:** al colocar la última pieza, la casa "cobra vida" (luz interior + humo de chimenea).
- **Payoff:** la casa guarda al jugador (save point cálido) y un cofre decorativo.
- **Afterglow:** los NPC pasan y comentan la casa (M162).

### WM-3 — Descubrir el Templo de la Brisa (Asombro · Juego principal)
- **Setup:** rumor de NPC + símbolo repetido en 3 lugares (M148 red de pistas).
- **Reveal:** la puerta del templo se abre con el puzzle resuelto (M24); murales animados.
- **Payoff:** primer fragmento de la historia de los Sellos (M22).
- **Afterglow:** salida al exterior con vista nocturna; regreso tranquilo al pueblo.

### WM-4 — Primer evento estacional (Pertenencia · Primeras horas/juego principal)
- **Setup:** decoración progresiva del pueblo días antes (M74).
- **Reveal:** el festival abre con toda la comunidad reunida y tema musical propio.
- **Payoff:** recuerdo exclusivo-pero-repetible (vuelve el próximo año, M94) + mini-juego.
- **Afterglow:** sobremesa con NPCs en la plaza.

### WM-5 — Ver la isla completa desde el mirador (Asombro · Progresión)
- **Setup:** sendero que se desbloquea con herramienta de tier 2 (M158).
- **Reveal:** panorámica donde se ven todas las zonas exploradas marcadas con luz propia.
- **Payoff:** fotografía especial (M56) + nombre del mirador en el mapa.
- **Afterglow:** descenso por ruta nueva de regreso.

### WM-6 — Recibir un regalo inesperado de un NPC (Pertenencia · Juego principal)
- **Setup:** amistad nivel suficiente (M20) + diálogos que insinúan sin avisar (M162).
- **Reveal:** el NPC entrega el regalo en una escena de diálogo única.
- **Payoff:** objeto con valor emocional (menciona la historia compartida) — no power-game.
- **Afterglow:** el objeto tiene entrada en el diario/museo.

### WM-7 — Completar la historia principal (Satisfacción + Nostalgia · Progresión)
- **Setup:** el último Sello; el pueblo "se prepara" en días previos.
- **Reveal:** secuencia final jugable (no cutscene pasiva) con toda la comunidad.
- **Payoff:** epílogo personalizado según amistades y construcciones del jugador.
- **Afterglow:** postgame abierto con la isla transformada (M75), sin "fin del mundo".

### WM-8 — Easter egg final (Curiosidad · Postgame)
- **Setup:** pista críptica en un mural antiguo (M148) que solo cobra sentido tras la historia.
- **Reveal:** lugar secreto con mensaje de los ancestros (tono cálido, no espantoso).
- **Payoff:** cosmético único + entrada de museo "secreta".
- **Afterglow:** —; es el broche más lejano del juego.

## 3. Presupuesto de wow moments por fase

| Fase del roadmap | Wow moments permitidos | Regla |
|---|---|---|
| M137 Prototipo | 0 (solo calma/satisfacción base) | El prototipo valida bucle, no espectáculo |
| M138 Vertical Slice | WM-1 (primer amanecer incluido) | 1 solo asombro: es la puerta emocional del juego |
| M139 Pre-Alpha | WM-2 | La satisfacción de construcción es el centro |
| M140 Alpha | WM-3, WM-4, WM-6 | Pertenencia + misterio de la historia |
| M141-M142 | WM-5, WM-7 | Progresión y cierre |
| Postgame (M144/M120) | WM-8 | Broche |

Regla: entre dos reveals de asombro hay **mínimo 2-3 horas de juego** esperadas; nunca dos wow moments en la misma sesión corta.

## 4. Métricas de éxito por momento

| Métrica | Fuente | Objetivo |
|---|---|---|
| Recall ("¿qué momento recordás?") | playtesting S1-S5 (M114) | El wow de la fase aparece en ≥ 50 % de menciones |
| Reacción observable durante el reveal (pausa, sonrisa, comentario) | observación del facilitador | Presente en ≥ 70 % de jugadores |
| Continuación post-afterglow | M105 (sesión sigue ≥ 15 min) | ≥ 80 % |
| Abandono post-reveal | M105 | Sin incremento vs. baseline |

**Firma del último agente que modificó este documento:**

**Modelo:** GLM
**Plataforma:** Kilo
