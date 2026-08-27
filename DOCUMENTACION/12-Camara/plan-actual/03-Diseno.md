**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 12: Cámara

## 0. Referencia visual: Animal Crossing

> **Estilo de cámara: Animal Crossing / Stardew Valley / Zelda: Link's Awakening DX**
>
> - Cámara fija en ángulo desde arriba (~50° pitch)
> - La cámara **SIGUE** al jugador pero **NO ROTA** con el mouse
> - El jugador se mueve relativo a la pantalla (arriba = alejarse, abajo = acercarse)
> - Vista cenital con ángulo, NO vista tras el hombro
> - El mundo se ve desde arriba, como un diorama

## 1. Modos de cámara (enum)

| Modo | Activo en | Comportamiento |
|---|---|---|
| `Explore` | Juego normal | Ángulo fijo ~50° sobre el jugador, sigue al pivot, sin rotación libre |
| `Build` | Modo construir (M17) | Aérea 45°, distancia 12 m, zoom extendido |
| `Dialog` | Diálogos/NPC (M21) | Encuadre de escena fijo, input bloqueado |
| `Cutscene` | Eventos de historia (M22/M26) | Planos fijos con fade |
| `Minimap` | Vista de supervisor | Textura top-down 2D (no render) |

**Reglas de activación:**
- Explore = base; Build solo con herramienta de construcción equipada y modo activo; al desequipar → Explore.
- Dialog/Cutscene nunca controlables por el jugador (input bloqueado a cámara).
- Minimap sobre todo, cerrable (M y Esc), con marcadores de POI (M71).

## 2. Spring-arm con colisión (especificación)

```
PIVOT = player pivot (M11)  →  brazo de 5 m (default)
Dirección: pitch = 50° fijo (desde horizontal); yaw = fijo (la cámara NO rota)
Raycast (physics layer: bloques) desde PIVOT a la cámara:
  si colisiona → cámara = punto de impacto − 0.8 m (separación mínima, nunca dentro de bloque)
  lerp de retorno: 0.15 s (suave, sin rebotes)
Distancia tras colisión: respetar zoom chosen si permite 0.8 m de separación línea de vista
```

- El raycast ignora al jugador y a los decorativos no sólidos (M50).
- En interiores (región 'interior', M24): distancia máxima 2.2 m y zoom bloqueado a cercano.

## 3. Comportamiento transversal

- **FOV:** 70° en todos los modos; sin cambio dinámico.
- **Pitch fijo:** ~50° sobre horizontal (vista cenital con ángulo). No se ajusta con mouse.
- **Yaw fijo:** La cámara apunta en una dirección fija (ej: sur). El jugador rota, la cámara NO.
- **Shake:** `shake_requested(amplitude, duration)` en EventBus.ui; amplitud ≤ 0.15 m, ≤ 0.5 s; solo narrativos (vórtice, terremotos de evento).
- **Fade/transeción:** `fade_screen(color, time)` centralizado; transición de escena = fade 0.3 s → swap → lerp 0.2 s.
- **Anti-mareo:** Sin rotación de cámara con mouse; movimiento suave solo de posición.

## 4. Minimapa (especificación)

- Este sobre el Canvas: 128×128, esquina superior derecha (default; reposicionable en settings).
- Fuente: texturas del generador M10 (mapa de biomas coloreado) + marcadores: POI (M71), casa del jugador (M31), camino, grieta, puerto.
- No se renderiza el mundo; 0 coste de render; se actualiza al regenerar (M10) o al descubrir POI.
- Iconos: 24×24 px, estilo brillante; colores por tipo.

## 5. Cámara de diálogo (reglas)

- Plano: Vista cenital con los 2 personajes en cuadro (jugador + NPC).
- Bloqueo de input de cámara durante el diálogo; zoom fijo ± 0.5 m según la escena.
- Si el NPC está lejos → el jugador se gira automáticamente (suave 0.5 s) al iniciar el diálogo (regla anti-confusión).
- Aplica a: M21 (diálogos), M22 (historia), M26 (templo), M74 (eventos).

## 6. Presupuesto y settings

- 1 cámara activa (la del mundo) + 1 Canvas de minimapa (textura, sin cámara).
- Settings de cámara: distancia de zoom por defecto, minimapa reposicionable.
- Sin sensibilidad de mouse (la cámara no rota con mouse).
- Persistencia en GameState.M12 (M59).

## 7. Interacción con M13 (herramientas)

- Al apuntar con herramienta (raycast de 4 m), la cámara se "acerca" a 3.5 m durante el uso (ligero, 0.3 s) y vuelve al soltar — ayuda de puntería sin romper el modo.

## 8. Movimiento del jugador (referencia M11)

- El jugador se mueve **relativo a la pantalla**:
  - W / ↑ = alejarse de la cámara (hacia "arriba" en pantalla)
  - S / ↓ = acercarse a la cámara (hacia "abajo" en pantalla)
  - A / ← = moverse a la izquierda en pantalla
  - D / → = moverse a la derecha en pantalla
- El jugador rota para mirar en la dirección que se mueve.
- La cámara NUNCA rota — siempre apunta en la misma dirección.
