**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 145-Diseno-De-Experiencia
**Estado:** Implementación operativa (entregable M145)

---

# Sistema de Feedback (`feedback-system`) — Módulo 145

> Qué feedback recibe el jugador por acción. Implementación: M43 (SFX, pool 24 voces), M44 (ASMR/sincronía), M52 (VFX), M41 (música), M48 (animación). Regla madre: feedback **sutil y satisfactorio** — confirma sin gritar (M152 cozy).

## 1. Tipos de feedback

| Tipo | Qué incluye | Regla cozy |
|---|---|---|
| Visual | Partículas suaves, brillos breves, iconos, squash&stretch leve | Nada de flashes agresivos; movimiento reducible (M58) |
| Sonoro | Efx cortos cálidos, capas musicales reactivas (M41) | Volúmenes bajos; blacklist anti-agresión (M44) |
| Háptico | Vibración leve de gamepad en eventos destacados | Intensidad baja; desactivable (M90) |
| Textual | Tooltips, toasts de notificación (M53), mensajes flotantes | ≤ 2 líneas, tono cálido, sin exclamaciones agresivas |

## 2. Mapeo de feedback por acción (catálogo base)

| # | Acción | Visual | Sonoro | Háptico | Textual |
|---|--------|--------|--------|---------|---------|
| 1 | Caminar (pisar) | polvo leve por superficie | paso suave por superficie (M43 6 superficies) | — | — |
| 2 | Correr | ráfaga de viento sutil | capa de respiración/woosh | — | — |
| 3 | Recoger ítem | arco de luz al inventario | "pop" cálido corto | tick corto | nombre del ítem (toast pequeño) |
| 4 | Cavar | partículas de tierra | golpe + tierra | pulsito | — |
| 5 | Golpear árbol | sacudida + hojas | golpe seco cálido | pulsito | — |
| 6 | Colocar bloque | destello suave | "clac" redondeado | pulsito | — |
| 7 | Construir (completar) | confeti de polvo dorado | acorde ascendente | doble pulsito | "¡Construcción lista!" |
| 8 | Craft completado | icono animado | melodía de 3 notas | — | ítem obtenido |
| 9 | Misión completada | sello de estrella suave | leitmotif corto (M41) | — | toast de recompensa |
| 10 | Misión nueva | icono "!" suave en NPC | nota de atención cálida | — | entrada en diario |
| 11 | Recibir daño | parpadeo blanco breve (sin rojo sangre) | thud amortiguado | vibración breve | — |
| 12 | Descubrir lugar | onda de brillo en el POI | campana suave | — | nombre del lugar (letra grande) |
| 13 | Hablar con NPC | retrato con bounce (M46) | voz "murmura" por NPC (M21) | — | subtítulos (M58) |
| 14 | Subir amistad | corazones pastel | arpegio tierno | — | toast "Amistad nivel X" |
| 15 | Dormir/pasar día | fundido a negro cálido | música de cuna | — | resumen del día (opcional) |
| 16 | Guardar | icono pluma girando | "shhh" suave | — | "Partida guardada" |
| 17 | Error/acción inválida | shake pequeño | "bop" grave suave | — | razón breve (ej: "necesitas pico") |
| 18 | Logro (M72) | estela dorada | fanfarria corta | patrón suave | toast con nombre |
| 19 | Clima cambia | partículas del clima (M52) | transición de capa ambiente | — | — |
| 20 | Festival inicia | banderines + brillos | tema del festival | — | cartel del evento |

## 3. Reglas de feedback cozy

1. **Confirmar, no castigar:** el error (acción 17) informa sin sons rojos ni penalización estética fuerte.
2. **Menos es más:** solo la acción más importante de la pantalla lleva VFX destacado por vez (presupuesto §4).
3. **Sin feedback agresivo:** prohibido strobing, shake fuerte, sonidos > 200 ms de ataque duro (M44 blacklist).
4. **Redundancia mínima par:** cada evento importante tiene mínimo 2 canales (visual+sonoro) y **representación cruzada** (sonidos con alternativa visual para accesibilidad, M58).
5. **Toda vibración es opcional** (M90) y se apaga con "reducción de movimiento" (M58).

## 4. Presupuesto de feedback por escena

| Recurso | Tope por escena | Fuente del tope |
|---|---|---|
| Sistemas de partículas activos | ≤ 12 (pool M52) | M52 presupuesto por escena |
| Voces SFX simultáneas | ≤ 8 de las 24 (prioridad M43) | M43 |
| Overlays textuales simultáneos | ≤ 3 toasts | M53 NotificationService |
| Vibraciones simultáneas | 1 | M90 |
| Capas musicales | base + 1 reactiva | M41 matriz |

## 5. Testing y mantenimiento

- Testing con jugadores: `plan-testing-experiencia.md` (¿el feedback se entiende sin texto? ¿algo resulta molesto en 30 min de sesión?).
- Cada VFX/SFX nuevo entra por su módulo dueño (M52/M43) con este estándar como criterio de aceptación.

**Firma del último agente que modificó este documento:**

**Modelo:** GLM
**Plataforma:** Kilo
