# Guía de GIFs — Isla Ancestral

**Módulo:** M99 Marketing (RF6) · **Fuente de diseño:** `DOCUMENTACION/99-Marketing/plan-actual/03-Diseno.md` §4
**Relacionado:** `lista-capturas.md` (catálogo de tomas fuente)

## 1. Set mínimo

**8+ GIFs** antes del lanzamiento, **uno por feature clave**. La regla es cobertura, no
cantidad: cubrir todas las mecánicas vendibles, no repetir la misma escena con distinto
encuadre.

| Feature | Acción a mostrar | Referencia módulo |
|---|---|---|
| Pesca | Lanzar + recoger + captura saltando | M34 |
| Construcción | Colocar una pieza y verla ensamblarse | M17 |
| Templos / rituales | Activar un sello con partículas | M24 |
| Agricultura | Regalar/regar y crecimiento de cultivo | M33 |
| Minería | Picar con fragmentos saltando | M35 |
| Amistad / diálogos | Vecino reaccionando en la plaza | M19-M21 |
| Crafteo / taller | Mesa de crafteo con resultado apareciendo | M16 |
| Mundo / atardecer | Vuelta a casa al golden hour | M09 |

## 2. Restricciones técnicas

- **Peso máximo ≤ 5 MB** por GIF. Por encima, redes comprimen solas y el resultado se ve mal.
- **Loop limpio**: el último frame debe enlazar con el primero sin salto visible. Si la acción
  no loopea naturalmente (ej. recoger un pez), se captura el "antes" y el "después" para que
  el ciclo se cierre.
- **Duración:** 3-6 segundos por loop. Menos no se entiende; más pesa de más.
- **Marco seguro:** la acción principal centrada, sin elementos críticos en los bordes
  (crops verticales de redes cortan lados).

## 3. Formato

| Formato | Uso |
|---|---|
| **WEBP** animado | Web (la página del juego) — mejor compresión que GIF |
| **MP4** (H.264, sin audio) | Twitter/X, Steam (M97), Discord — redes que no soportan WEBP |
| **GIF** | Fallback universal / foros |

Exportación: **siempre desde el master 4K**, bajando a 1080p y luego al formato final.
Nunca re-comprimir un GIF ya comprimido.

## 4. Uso por canal

| Canal | Formato | Observación |
|---|---|---|
| Página web (galería) | WEBP | Hover-play, sin autoplay con sonido |
| Steam (M97) | GIF/MP4 | Capsule + media reel |
| Instagram | MP4 (reel) | Vertical 9:16 a partir del master |
| TikTok | MP4 | Vertical 9:16, con subtítulos quemados |
| Newsletter | GIF | Peso ≤ 1 MB (clientes de correo pesados) |
| Press kit | MP4 4K | Sin marca de agua |

## 5. Reglas de marca

- **Sin UI sucia:** HUD limpio u oculto (igual que en capturas).
- **Sin spoilers de los sellos:** los GIFs de templos muestran la activación, no la resolución
  del acertijo ni la recompensa final (M24).
- **Personaje visible** siempre que la acción lo permita: vende la escala y la identidad.
- **Sin debug overlays**, sin Godot watermark, sin atajos del editor visibles.
