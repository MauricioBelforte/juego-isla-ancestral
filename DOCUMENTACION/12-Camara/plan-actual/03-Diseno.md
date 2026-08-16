**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 12: Cámara

## 1. Modos de cámara (enum)

| Modo | Activo en | Comportamiento |
|---|---|---|
| `Explore` | Juego normal | Tras el hombro, zoom 2.5/5/8 |
| `Build` | Modo construir (M17) | Aérea 45°, distancia 12 m |
| `Dialog` | Diálogos/NPC (M21) | Encuadre de escena fijo |
| `Cutscene` | Eventos de historia (M22/M26) | Planos fijos con fade |
| `Minimap` | Vista de supervisor | Textura top-down 2D (no render) |

**Reglas de activación:**
- Explore = base; Build solo con herramienta de construcción equipada y modo activo; al desequipar → Explore.
- Dialog/Cutscene nunca controlables por el jugador (input bloqueado a cámara).
- Minimap sobre todo, cerrable (M y Esc), con marcadores de POI (M71).

## 2. Spring-arm con colisión (especificación)

```
PIVOT = player pivot (M11)  →  brazo de 5 m (default)
Dirección: yaw = dirección del personaje; pitch = 30° + ajuste de pendiente (±10°)
Raycast (physics layer: blocos) desde PIVOT a la cámara:
  si colisiona → cámara = punto de impacto − 0.8 m (separación mínima, nunca dentro de bloque)
  lerp de retorno: 0.15 s (suave, sin rebotes)
Distancia tras colisión: respetar zoom chosen si permite 0.8 m de separación línea de vista
```

- El raycast ignora al jugador y a los decorativos no sólidos (M50).
- En interiores (región 'interior', M24): distancia máxima 2.2 m y zoom bloqueado a cercano.

## 3. Comportamiento transversal

- **FOV:** 70° en todos los modos; sin cambio dinámico.
- **Shake:** `shake_requested(amplitude, duration)` en EventBus.ui; amplitud ≤ 0.15 m, ≤ 0.5 s; solo narrativos (vórtice, terremotos de evento).
- **Fade/transeción:** `fade_screen(color, time)` centralizado; transición de escena = fade 0.3 s → swap → lerp 0.2 s.
- **Anti-mareo:** limitador de rotación 240°/s suave; ningún movimiento casual de cámara en el aire (solo sigue al pivot).

## 4. Minimapa (especificación)

- Este sobre el Canvas: 128×128, esquina superior derecha (default; reposicionable en settings).
- Fuente: texturas del generador M10 (mapa de biomas coloreado) + marcadores: POI (M71), casa del jugador (M31), camino, grieta, puerto.
- No se renderiza el mundo; 0 coste de render; se actualiza al regenerar (M10) o al descubrir POI.
- Iconos: 24×24 px, estilo brillante; colores por tipo.

## 5. Cámara de diálogo (reglas)

- Plano: Over-the-shoulder del jugador hacia el NPC (o plano medio con los 2 en cuadro al 50%).
- Bloqueo de input de cámara durante el diálogo; zoom fijo ± 0.5 m según la escena.
- Si el NPC está lejos → el jugador se gira automáticamente (suave 0.5 s) al iniciar el diálogo (regla anti-confusión).
- Aplica a: M21 (diálogos), M22 (historia), M26 (templo), M74 (eventos).

## 6. Presupuesto y settings

- 1 cámara activa (la del mundo) + 1 Canvas de minimapa (textura, sin cámara).
- Settings de cámara: sensibilidad (1-10), distancia de zoom por defecto, invertir pitch, minimapa reposicionable.
- Persistencia en GameState.M12 (M59).

## 7. Interacción con M13 (herramientas)

- Al apuntar con herramienta (raycast de 4 m), la cámara se "acerca" a 3.5 m durante el uso (ligero, 0.3 s) y vuelve al soltar — ayuda de puntería sin romper el modo.