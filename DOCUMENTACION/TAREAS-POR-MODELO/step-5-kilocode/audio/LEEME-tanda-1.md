# Audios procedurales para revisión — 97 sonidos (pedido del fundador)

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

**97 de 97** WAV entregados (22 base + 30 variaciones + 5 stings + 6 recetas de feedback + 35 momentos narrativos + lore_oculto). Las 21 situaciones de sfx_tones.json tienen su WAV base, 21/21, mas lore_oculto. No toqué `data/` ni los catálogos de
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

## Tanda 4: los 5 stings musicales

music_context_matrix.json define 5 momentos musicales cortos (LUFS -18). Son frases
de 2-4 s, la misma categoría que lore_oculto, así que se pueden componer con acordes
en vez de sintetizar tonos sueltos:

| Archivo | Duración | Carácter |
|---|---|---|
| sting_sello.wav | 2.1 s | sostenido y ceremonial (3 acordes mayores) |
| sting_puzzle.wav | 1.4 s | construye y corta, el ajá (4 acordes ascendentes) |
| sting_descubrimiento.wav | 2.2 s | apertura amplia, intervalo abierto (8va y 11na) |
| sting_llegada.wav | 2.0 s | el más expansivo, abre con fuerza |
| sting_creditos.wav | 3.6 s | reflexivo, progresión que desciende y resuelve |

Cada acorde tiene envolvente propia y sus notas entran escalonadas (arpegio sutil), con
el timbre (armónicos y ataque) elegido según el carácter del momento. **Verificado
numéricamente que las formas difieren** — la energía por tercios de cada uno es distinta
y coherente con lo que pretende: llegada abre en 0.200 y decae, descubrimiento abre
fuerte y se apaga, puzzle sostiene y corta al final.

## Lo que NO sinteticé y por qué

Las **24 capas de music_context_matrix.json** (ase_aurora, 	iempo_noche,
evento_tormenta, los 4 leitmotifs, etc.) son **beds ambientales pensados para sonar
en loop durante minutos**. Sintetizarlos con senos daría un zumbido de laboratorio, no
música. Esos necesitan composición o assets reales, y es la única parte del audio del
juego que no puedo cubrir por síntesis. Los 24 	emas del JSON no son assets
independientes: son combinaciones de esas capas.

## Tanda 5: las 6 recetas de feedback que faltaban

eedback_recetas.json (consumido por eedback_director.gd) declara 8 situaciones.
Solo 2 tenian WAV (plantar, cosechar); renderice las 6 que faltaban.

A diferencia de sfx_tones.json (que da NOTAS), estas recetas describen **CAPAS** que
hay que mezclar. El JSON dice cuales; el timbre de cada capa y la duracion salen del
generador:

| Archivo | Capas que pide el JSON | Duracion |
|---|---|---|
| loque_roto.wav | crack + roca + eco (+ reverb interior) | 0.48 s |
| loque_colocado.wav | thud + arena (+ reverb interior) | 0.36 s |
| cocinar.wav | sizzle + vapor | 0.45 s |
| brir_contenedor.wav | madera_apertura + click_cierre (+ reverb interior) | 0.38 s |
| pescar_captura.wav | splash + lucha | 0.50 s |
| mineria_golpe.wav | golpe_roca + eco (+ reverb cueva) | 0.65 s |

Verificado numericamente: todos con clipping 0 y pico <= 0.579. El ataque queda al
principio en los seis (energia por cuartos decreciente), que es lo que corresponde
para golpes e impactos.

**Salvedad honesta:** tres recetas pisten interior_capa (reverb interior o de cueva).
Eso lo sintetice como una cola de ruido con decay — **no es una reverb real por
convolucion**. Sirve para dar sensacion de espacio cerrado, pero no sustituye a una IR
verdadera. Si el fundador nota que suena artificial en cueva, es eso.

## Tanda 6: los 35 momentos narrativos (el hueco mas grande)

`narrative_sound.json` declara **35 momentos** y solo 1 tenia WAV (`lore_oculto`, que
agregue yo). Renderice los 34 restantes.

Cada momento trae del JSON tres datos que use tal cual, sin inventar ninguno:
`categoria` (fija la progresion armonica y el timbre), `intensidad` 0.0-1.0 (**fija la
amplitud**) y `duracion_s`. Siete arquetipos, uno por categoria:

| Categoria | Momentos | Caracter |
|---|---|---|
| logro | 4 | acordes mayores ascendentes, brillante |
| descubrimiento | 7 | intervalos abiertos (8va/11na), etereo |
| interaccion | 10 | dos notas, mecanico y corto |
| personaje | 5 | calido, presentacion del personaje |
| ui | 3 | un par de notas, limpio y breve |
| narrativo | 3 | reflexivo, desciende |
| ambiental | 2 | **tritono** a proposito (tension) |

**Verificado que la intensidad manda el volumen**: el pico de cada WAV sigue el orden de
la `intensidad` del JSON (los de 1.0 llegan a 0.85; los de 0.2 quedan en 0.18). No es
casualidad: la formula usa `amp = intensidad * 0.45`.

Dos momentos merecen oido especial:
- **`silencio_revelacion` y `silencio_pos_musica` salen en silencio literal (pico 0.000)**.
  No es un fallo: el JSON les pone `intensidad: 0.0` y su descripcion es "Pausa de tension
  antes de una revelacion" / "Pausa de impacto despues de una pieza musical". **Son
  pausas narrativas, no sonidos.** Renderizarlas como silencio es lo correcto.
- **`area_misteriosa` y `misterio_detectado`** usan el arquetipo de tension, que mete un
  tritono sonando por encima. Es disonante a proposito.
