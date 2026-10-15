# Audios procedurales para revisión — tanda 1 (3 de 21)

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Fecha:** 2026-10-15

## Qué es esta carpeta

Audios **generados por código**, no grabados. Los rendericé desde las recetas que ya
existen en `game/isla-ancestral/data/audio/sfx_tones.json` — el catálogo de 21
situaciones que diseñó M43 y que `sfx_manager.gd` ya consume.

**El objetivo es que los escuches por nombre con tu reproductor y me digas si el timbre
pega con lo que imaginaste**, antes de que nadie los integre al juego.

## Cómo escucharlos

Abrí esta carpeta con cualquier reproductor. El nombre del archivo es la situación:

| Archivo | Situación | Duración | Timbre |
|---|---|---|---|
| `pescar.wav` | pesca | 0.60 s | agua + seno modulado |
| `cosechar.wav` | cosechar cultivos | 0.35 s | follaje |
| `herramienta.wav` | usar herramienta | 0.20 s | metálico |

## De dónde salió cada sonido

Los tres salen **directamente del JSON de M43**, no los inventé yo:

```
"pescar":      {"notas_semitonos": [0,2,5,7], "orden": "ascendente",
                "duracion_s": 0.6, "tono": "agua",
                "etapas": ["cast","splash","bote","reel"]}
"cosechar":    {"notas_semitonos": [0,4,7], "orden": "ascendente",
                "duracion_s": 0.35, "tono": "follaje", "logro_ligero": true}
"herramienta": {"notas_semitonos": [0,4], "orden": "ascendente",
                "duracion_s": 0.2, "tono": "metálico",
                "variaciones": 4, "por_tipo": true}
```

Las `notas_semitonos` las convertí a frecuencias (0 = 440 Hz, cada semitono ×2^(1/12)).
El campo `tono` definió el timbre: **agua** = seno + ruido modulado, **follaje** = ruido
filtrado pasa-bajos, **metálico** = seno + ruido pasa-altos.

## Verificación numérica (lo que sí puedo comprobar sin oreja)

Cada WAV se midió antes de entregarse:

| Archivo | Pico | Offset DC | Duración | Clipping |
|---|---|---|---|---|
| `pescar.wav` | 0.449 | −0.00001 | 0.60 s | 0 |
| `cosechar.wav` | 0.625 | −0.00251 | 0.35 s | 0 |
| `herramienta.wav` | 0.350 | +0.00000 | 0.20 s | 0 |

**Pico ≤ 0.999 y clipping = 0** en los tres: no distorsionan. Offset DC casi cero: no
van a hacer pop en los parlantes. Formato mono / 16-bit / 44.1 kHz, que Godot lee
directamente.

## Lo que no puedo verificar y necesito de vos

**Si suenan bien.** Puedo demostrar que no saturan, no que un seno de 880 Hz con armónicos
suene a "cosechar". Eso lo definís vos.

## Para ajustar

Los parámetros están en constantes al inicio de
`scripts-prueba-temp/generar_audios.py`: `AMP_BASE` (volumen general),
`AMP_ARMONICO` (brillo), `ATAQUE_S` y `RELEASE_S` (suavidad). Si me decís "más seco",
"más brillante" o "más largo", los cambio y regenero.

## Qué falta

Quedan **18 de 21 situaciones** por renderizar. Cuando valides estas tres, sigo con el
resto. No toqué `data/` ni el catálogo: esto es material de revisión, la integración al
juego es de M43.
