# Log 791: M09 — terreno original restaurado (perfil M167 intacto)

**Fecha:** 2026-09-08
**Hora:** 00:35
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
El usuario detectó que el terreno cambió ("este no era el terreno de mi isla, lo modificaste mucho"): la iteración anterior había alterado el perfil del generador (max_height 40→250, boost 1.0→6.0) para hacer las montañas "visibles". Restaurado al **perfil original de la Isla Raíz** (config M167: max_height 40, sin boost) — el terreno vuelve a ser exactamente el de siempre. El impostor y el disco de terreno se adaptan automáticamente (muestrean el mismo generador).

## Cambios Realizados
- `main_island.gd`: `max_height 250 → 40`, `max_height_boost 6.0 → 1.0` (perfil original restaurado, comentado con referencia M167 y Log 791).
- El `max_height_boost` queda en el generador (default 1.0 = sin efecto) como constante disponible para FUTURAS decisiones del usuario — no se toca sin su aprobación.

## Evidencia
- `[M09] Spawn sobre superficie calculada Y=8 en (3860, 3860)` — altura original del spawn (antes con boost: Y=81).
- `[M163] Chaman del Monte spawneado en (2320.0, 17.0, 2300.0)` — montañas de altura original ~17m (antes: Y=595).
- Disco de terreno: 9.287 celdas, 203 tiles — regenerado con las alturas originales.
- `[Gaviota] ATERRIZADA en el suelo` — fauna coherente con el terreno restaurado.
- 0 errores en el boot.

## Lección para el registro
- **El perfil del terreno es contenido aprobado por el usuario** (M167 config fija): NO modificar max_height/boost/seed sin su aprobación explícita, aunque el objetivo (visibilidad lejana) parezca justificarlo. La solución correcta para "ver las montañas de lejos" es el impostor (que muestrea el perfil ORIGINAL), no escalar el terreno.

## Archivos Modificados
- `game/isla-ancestral/scripts/main_island.gd` (perfil original restaurado)
