# Audios procedurales para revisión — 22 sonidos (pedido del fundador)

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Fecha:** 2026-10-15

## Qué es esta carpeta

Audios **generados por código**, no grabados. Los rendericé desde las recetas que ya
existen en el proyecto, para que el fundador los escuche por nombre con cualquier
reproductor y evalúe el timbre **antes** de que nadie los integre al juego.

- **21 situaciones** salen de `game/isla-ancestral/data/audio/sfx_tones.json` — el
  catálogo que diseñó M43 y que `sfx_manager.gd` ya consume.
- **`lore_oculto.wav`** sale de `narrative_sound.json` v1.2.0 (momento que agregué yo
  en el commit 47353d0 para M150).

Formato de todos: **mono / 16-bit / 44.100 Hz**, que Godot lee directo.

## Cómo escucharlos

Abrí esta carpeta con tu reproductor. El nombre del archivo es la situación.
Escuchalos en este orden si querés comparar familias de timbre:

| Grupo | Archivos |
|---|---|
| Agua / naturaleza | `pescar`, `nadar`, `regar`, `cosechar`, `plantar` |
|UI / economia | `confirmacion`, `logro`, `error`, `recoger`, `compra`, `venta`, `menu`, `seleccion`, `dialog` |
| Movimiento | `saltar`, `caer`, `equipar` |
| Objetos | `abrir`, `cerrar`, `herramienta`, `crafting_exito` |
| Narrativo | `lore_oculto` |

## Verificación numérica (lo que sí pude comprobar sin oreja)

Los 22 se midieron antes de entregarse. **Todos con clipping = 0 y pico ≤ 0.85**, así
que ninguno distorsiona. Offset DC en todos los casos bajo 0.007: no van a hacer pop.

Dos que merecen ojo:
- **`plantar.wav`** tiene offset DC de −0.0068, el más alto de la tanda. Es ruido
  filtrado pasa-bajos y ese filtro de un polo arrastra componente continua. Suave,
  pero si escuchás algo raro en los graves, es esto.
- **`cosechar.wav`** tiene pico 0.625, el más alto. Ya está normalizado, no satura.

## Lo que NO puedo verificar — y necesito de vos

**Si suenan bien.** Puedo demostrar que no saturan, no que un seno con armónicos suene
a "cosechar" o que el tritono de `lore_oculto` suene a misterio. Eso lo definís vos.

## Salvedades honestas sobre el alcance

1. **Un sonido por situación, no las variaciones.** El JSON pide variaciones que mi
   generador no renderiza: `herramienta` pide 4, `abrir` pide 3 (madera/cerrojo),
   `equipar` pide 2, `saltar` pide variar por superficie, `caer` pide 3 rangos de
   altura, `pescar` pide 4 etapas (cast/splash/bote/reel), `nadar` pide 3 tipos.
   Entregué **uno representativo por situación**. Si el enfoque te gusta, renderizo
   las familias completas.
2. **`compra` y `venta` piden "monedas": 2** — un detalle de sonido de monedas que no
   sinteticé. Quedan como el tono base nomás.
3. **`lore_oculto` es diseño mío**, no viene del JSON: usé un tritono (4ª aumentada),
   que suena irresuelto, con una 5ª que aparece al final y se corta. Es el único de
   los 22 donde inventé la receta.
4. **No ejecuté nada en Godot** (no disponible en este entorno). La verificación es
   numérica sobre el WAV, no de escucha.

## Para ajustar

Los parámetros están en constantes al inicio de
`scripts-prueba-temp/generar_audios.py`: `AMP_BASE` (volumen), `AMP_ARMONICO`
(brillo), `ATAQUE_S` / `RELEASE_S` (suavidad). Decime "más seco", "más brillante",
"más largo" de un sonido y lo regenero.

## Estado

**22 de 22** objetivos de esta tanda entregados. No toqué `data/` ni los catálogos de
audio: esto es material de revisión, la integración al juego es de M43.
