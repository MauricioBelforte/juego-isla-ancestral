**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 92: Tutorial

## 1. Análisis del dominio

### 1.1 Tipos de tutorial en juegos cozy

**A) Tutorial contextual (diegético, en el mundo):** pequeñas pistas flotantes, marcadores y leyendas que aparecen junto al elemento que se enseña en el momento exacto. Ventajas: no rompe la inmersión, corto, se adapta al ritmo. Desventajas: puede pasar desapercibido; difícil enseñar secuencias largas (ej: crafting con 4 pasos) solo con burbujas.

**B) Secuencia guiada (prólogo/sandbox dirigido):** encadenado de pasos con objetivo activo y obstáculos mínimos, los primeros 10-15 minutos, mientras el mundo "se presenta". Ventajas: aprendizaje garantizado, memorable, coherente con la historia (un personaje guía). Desventajas: si se alarga, se siente como raíl y castiga al re-jugador. En Stardew Valley el prólogo (carta de tu abuelo + Lewis) hace esto de forma muy suave.

**C) Sandbox libre (sin tutorial):** exploración pura. Ventajas: libertad total. Desventajas: jugadores nuevos se pierden; en un juego de 10+ sistemas (AZADA, PICO, CAÑA, E...) la curva es empinada y el jugador abandona.

**D) Tutorial "pared de texto" (anti-patrón):** pantalla de instrucciones con 10 párrafos antes de jugar. Ventaja: información completa. Desventajas: prólogo eterno, antitético al cozy; la mayoría de jugadores la saltea (si se permite) o se aburre y cierra.

### 1.2 Onboarding en juegos de granja cozy (referencias)

- **Stardew Valley:** prólogo guiado muy breve (carta + personaje-guía), luego libertad total; el jugador aprende haciendo; pocos modales; las herramientas se explican por pistas de diálogo opcionales.
- **Animal Crossing/Cozy Grove:** "Día 1" como secuencia guiada corta; las mecánicas se van desbloqueando por días, evitando el info-dump; los NPCs enseñan desde el diálogo.
- **Moonlighter/Garden Paws:** pistas contextuales flotantes sobre el objeto y tecla; el tutorial es opcional y salteable desde la primera partida.
- **Aprender-haciendo (learning by doing):** la mejor retención ocurre cuando el jugador ejecuta la acción 1-2 veces con guía mínima, no cuando lee manuales. El 92 sigue este principio: cada capítulo = 1 mecánica, ≤ 3 pasos, feedback inmediato.

### 1.3 Accesibilidad y ritmo (juego acogedor)

- Lectura: pistas ≤ 2 líneas + ícono; tiempo de lectura mínimo 4 s (escalable x1/x2/x4 para M58).
- Movimiento: los consejos no requieren reflejos; las pistas de pesca/minería pueden re-mostrarse si falla el mini-juego (sin castigo).
- Contraste: la burbuja apoya en M58 alto contraste; el 92 no define colores finales.
- Ritmo: cada capítulo se dispara por contexto real (nunca por tiempo global de partida), excepto el prólogo que se dispara en la llegada.

### 1.4 Rejugabilidad y "jugador que ya sabe"

- El estado del tutorial es POR GUARDADO (RN11): una partida nueva vuelve a mostrar el tutorial porque el jugador puede ser otro (couch co-op / familia, algo común en cozy games).
- Pero dentro de la MISMA partida no se repite: una vez completado un capítulo, jamás vuelve (excepto re-play manual desde opciones).
- Revalidación: si el jugador pesca antes del capítulo de pesca, el capítulo se salta en silencio (RF3/RF19). Esto cubre el caso "vení de otro juego cozy y ya sé cómo se hace".
- Gestión de expectativa: el re-play pide confirmación y hace snapshot para no contaminar la partida (RN11).

## 2. Alternativas consideradas

| Alt | Propuesta | Ventajas | Desventajas | Veredicto |
|---|---|---|---|---|
| A1 | Manual/pared de texto inicial obligatorio | Implementación trivial, información completa | Rompe cozy, info-dump, mala retención | ✗ Descartada |
| A2 | Tutorial 100% contextual (solo burbujas) | Mínima intrusión | Secuencias multi-paso (crafting) se vuelven confusas; el prólogo de la isla no se "presenta" | ✗ Descartada sola; se usa como componente |
| A3 | Prólogo con secuencia guiada estricta y bloqueo de sistemas | Retención perfecta, narrativa | Frustra al re-jugador; raíl largo; riesgo de softlock | ✗ Descartada en su forma estricta |
| A4 | Híbrido: prólogo guiado suave + capítulos contextuales + consejos opcionales + skip/replay/revalidación | Aprende-haciendo, respeta el ritmo, cubre secuencias, re-jugador feliz | Más sistemas que las alternativas (3 subsistemas coordinados) | ✔ **DECISIÓN** |

### 2.1 Decisión A4 — detalle

- **Prólogo guiado suave (secuencia guiada, RF5):** solo llega hasta "saludar a tu primer vecino" (2-4 pasos), sin bloqueos de sistemas; los raíles mínimos y el mundo se abre de inmediato.
- **Capítulos contextuales (RF11-RF18):** cada sistema grande (interactuar, herramientas, cultivo, pesca, minería, crafting, NPC) tiene su propio guion corto disparado por trigger real; el jugador los recibe cuando llega al lugar correspondiente, no todos en el primer minuto (evita el info-dump de Stardew-clones mal hechos).
- **Consejos opcionales (RF6):** profundización sin enseñanza obligatoria (senderismo por la isla, horarios de riego), se muestran una vez en contextos de espera.
- **Opciones completas:** skip global, skip por capítulo, pistas off, consejos off, re-play; todo en opciones del juego (M53), persistido en GameState.M92.

## 3. Decisiones de diseño derivadas

1. **Triggers por señal, no por timer:** el 92 escucha señales de los sistemas (M70 "primera_interaccion", M33 "cultivo_regado", M34 "pez_capturado", M16 "item_crafteado") + condiciones de mundo. Nunca un reloj global "a los 3 minutos mostrar X".
2. **Cada capítulo es un Resource reutilizable** (`CapituloGuion`) con: id, lista de pasos, trigger, condiciones y meta. El mismo guion sirve para partida nueva, re-play y futuro New Game+.
3. **Pistas como pool:** máximo 2 burbujas vivas, poolable (M53/M63), para respetar el presupuesto de rendimiento (RN4).
4. **Revalidación por señales espejo:** cada capítulo declara su "señal de maestría"; si llega antes del trigger, el capítulo se completa en silencio (RF3/RF19).
5. **Fail-safe por watchdog (M66):** capítulos con timeout (120 s por defecto) y re-programación hasta 3 intentos; nunca un modal de "se requiere el tutorial".
6. **Sin dependencia de contenido narrativo:** los NPC tutores aparecen opcionalmente; el 92 funciona aunque un sistema aún no esté implementado (los capítulos se omiten con log de degradación, M103).
7. **UI pertenece a M53:** el 92 entrega datos y estados; M53 dibuja (burbujas, marcadores, popup de capítulo completado). Los .tscn de prueba son de depuración, no finales.

## 4. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| Info-dump (demasiados capítulos juntos) | Capítulos solo por trigger de contexto real + máx. 2 pistas simultáneas (RN2) |
| Re-jugador aburrido | Revalidación de "ya lo sabe" (RF3) + skip remanente con un toque (M57) |
| Tutorial roto que bloquea | Watchdog (RF23), re-programación ×3 y descarte seguro (RN10) |
| Sistema enseñado aún no implementado | Omisión de capítulos con log (M103) — el 92 arranca como esqueleto |
| Texto largo / lectura lenta | Pistas ≤ 2 líneas (RN1) + duración x1/x2/x4 (RN12) |
| Pistas que tapan el mundo | Burla de posición arriba del objetivo con offset por cámara (M53); ≤ 2 vivas |