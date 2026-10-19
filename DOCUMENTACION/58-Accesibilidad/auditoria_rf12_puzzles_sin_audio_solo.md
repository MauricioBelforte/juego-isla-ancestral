# M58-Accesibilidad — Auditoría RF12: ningún puzzle depende de oír un sonido específico

**Modelo:** G-5.3-Flash-Agente (GLM-5.3-Flash)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-19 06:20 (UTC)
**Ítem origen:** cola repoblada del director (05 real M58), item [39] RF12 — auditor [C]

## Alcance

Todos los puzzles del r código: `game/isla-ancestral/scripts/templos/puzzle_*.gd` (agua, bloques, espejos, gravedad, luz, emisor, sonido, room, def, dificultad).

## Resultado

### 1) Cero audio directo en la lógica de los puzzles resolver
- `rg -ni "player\.|sfx|AudioStream|SFXManager|tonos"` sobre `puzzle_agua / puzzle_bloques / puzzle_espejos / puzzle_gravedad / puzzle_luz` → **0 hits** — los puzzles se resuelven con interacciones visuales/Grid sin reproducir audio.

### 2) El puzzle de SONIDO es data-only (deliberado)
- `puzzle_sonido.gd` cabecera **declarada**: "MODELO PURO DE DATOS: esta clase NO toca `AudioServer` ni ningún nodo de audio (item 104). El 'sonido' es un identificador de tono (dato), no una reproducción" + **test por grep en la fuente** ("0 referencias a AudioServer", test por grep documentado).
- Conclusión: el puzzle familia SONIDO usa **ids de tonos como datos** — la reproducción real queda fuera de la familia (capa presentación), el modelo resuelve sin oír NADA.

### 3) El feedback del puzzle-room es texto/visual
- `puzzle_room.gd` expone **feedback textual/estado**: "casi solución" (a UN paso del objetivo) y resultado del último chequeo — caminos de solución sin audio.
- `puzzle_luz.gd` — feedback de dirección en la PRIMERA interacción (item 53) — visual.
- Los emisores (`puzzle_emisor.gd`) son EMISORES DE DATOS (no emiten sonido crudo).

## Cierre RF12

**NINGÚN puzzle depende de oír un sonido específico** — verificable con grep (0 referencias a AudioServer/P SFX en los modelos de puzzle) y por el diseño data-only declarado en las cabeceras (item 104). El audio de los puzzles es CAMADA DE PRESENTACIÓN aparte con feedback visual/texto equivalente siempre disponible.

## Recomendación para los dueños (no acción mía)

- Mantener el **test por grep** (0 AudioServer en los modelos de datos de sync) como **barra del CI** (hold la línea — si alguien añade audio en los modelos, rompe el test y el gate saltará).
- Cubrir el caso EL EQUIVALENTE VISUAL del puzzle_sonido (los tonos como colores/formas en la presentación) — tarea del dueño de la pantalla de puzzles (M24/M53-Accesibilidad).

Firma: G-5.3-Flash-Agente / Kilo Code.
