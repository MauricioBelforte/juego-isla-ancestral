# Audios procedurales para revisión — 52 sonidos (pedido del fundador)

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

**52 de 52** WAV entregados (22 base + 30 variaciones). Las 21 situaciones de sfx_tones.json tienen su WAV base, 21/21, mas lore_oculto. No toqué `data/` ni los catálogos de
audio: esto es material de revisión, la integración al juego es de M43.

## Tanda 2: las variaciones (25 WAV extra)

El JSON pide variaciones para que dos disparos seguidos no suenen clonados.
Rendericé las 25, con el mismo criterio: desplazo el tono unos semitonos y roto
la amplitud, conservando la receta base.

| Familia | Variaciones | Nombre de archivo |
|---|---|---|
| herramienta | 4 | herramienta_1.wav … herramienta_4.wav |
| brir | 3 | brir_1.wav … brir_3.wav |
| equipar | 2 | equipar_1.wav … equipar_2.wav |
| plantar | 3 | plantar_1.wav … plantar_3.wav |
| pescar | 4 etapas | pescar_cast.wav, pescar_splash.wav, pescar_bote.wav, pescar_reel.wav |
| 
adar | 3 tipos | 
adar_entrada.wav, 
adar_avance.wav, 
adar_salida.wav |
| caer | 3 alturas | caer_altura1.wav … caer_altura3.wav |
| saltar | 3 superficies | saltar_superficie1.wav … saltar_superficie3.wav |

**Total en la carpeta: 47 WAV** (22 base + 25 variaciones), todos con clipping 0
y pico ≤ 0.85.

### Tanda 3: variaciones por material, con timbres realmente distintos

El JSON pedia variaciones **por tipo de herramienta** (por_tipo) y **por material**
en abrir. En la tanda 2 las renderice como simples desplazamientos de tono, que no
cumplen eso. Ahora si, y **con datos reales del proyecto**:

- **herramienta por material** -> los 4 tiers de data/herramientas/tiers_config.json:
  herramienta_cobre, herramienta_hierro, herramienta_oro, herramienta_cristal.
- **abrir por material** -> los que declara sfx_tones.json: abrir_madera, abrir_cerrojo.
- **saltar por superficie** -> las 9 de data/audio/sfx_surfaces.json: saltar_hierba,
  saltar_madera, saltar_piedra, saltar_tierra, saltar_nieve, saltar_arena,
  saltar_agua, saltar_metal, saltar_cristal.

La caracterizacion de cada material sale de su dureza fisica, no es arbitraria: el
cobre es mate y grave, el hierro duro, el oro brillante, el cristal vidrioso y
agudo; la madera seca y corta, el cerrojo metalico. **Verificado numericamente** —
la frecuencia dominante de cada uno queda ordenada como debe:

| Archivo | Frec. dominante |
|---|---|
| herramienta_cobre.wav | ~782 Hz |
| herramienta_oro.wav | ~1224 Hz |
| herramienta_hierro.wav | ~1638 Hz |
| herramienta_cristal.wav | ~2167 Hz |
| abrir_madera.wav | ~1351 Hz |
| abrir_cerrojo.wav | ~1750 Hz |

### Limite honesto que sigue en pie

La **caracterizacion timbrica concreta** (cuanto armonico lleva el oro, si el
cristal necesita un ataque mas rapido) es criterio de diseno. Lo que hice fue una
asignacion fisicamente razonable y verificable en orden, no una afinacion de
estudio. Si algun material te suena mal, se ajusta en TIMBRES_MATERIAL dentro del
generador.
