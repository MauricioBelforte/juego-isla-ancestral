**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 41: Música

## 1. Arquitectura

```
Sistema de Audio (M06/AudioBus) ──► MusicDirector.gd (autoload M41)
                                        │
      ┌───────────────┬────────────────┼────────────────┬───────────────┐
      ▼               ▼                ▼                ▼               ▼
  CONTEXTOS      CAPAS (3 máx)    CROSSFADE A/B    SHUFFLE PRNG    VOLUMETRÍA
  (M29/M31/M32)  (base+tiempo+    (2 players)      (variaciones)   (LUFS -16)
   zona/lugar     evento)
```

## 2. Matriz de contexto → capas

| Contexto | Capa BASE | Capa TIEMPO | Capa EVENTO |
|---|---|---|---|
| Playa de día, primavera | playa | día + primavera | — |
| Playa de noche, verano | playa | noche + verano | — |
| Bosque con lluvia | bosque | (hora) + (estación) | lluvia |
| Templo + festival | templo | nocturno | festival |
| Océano (Gran Vapor) | océano | hora | — |
| Submarino | submarina | — | burbujas (M44) |

**Regla:** cualquier combinación tiene ≤ 3 capas; capa de estación recoloriza la orquestación de la base (no compone armonías nuevas).

## 3. Componentes y flujo

| Componente | Responsabilidad |
|---|---|
| `MusicDirector.gd` | Decide tema+capa según Matrix; maneja A/B crossfade (3 s); respeta pausa de juego (M29) y menú |
| `TemaBank.tres` | Catálogo con nombre, path al audio, variaciones, duración, volumen, capa |
| `MusicPlayer.gd` | Envuelve AudioStreamPlayer; polifonía ≤ 8 voces totales |
| `ShuffleSampler.gd` | PRNG con semilla del jugador (M10); no repite la misma variación hasta cubrir las 2 |
| `Ducking.gd` | Baja música -6 dB mientras hay diálogo (M21) o UI crítica |
| `Stings.gd` | Dispara stings puntuales (Sello, puzzle, descubrimiento) con fallback a 1-2 s crossfade |

## 4. Matriz de música narrativa

| Momento | Tema/Sting | Duración | Regla cozy |
|---|---|---|---|
| Tensión narrativa | "preocupación suave" | ≤ 45 s | Siempre resuelve; jamás acompaña peligro real |
| Descubrimiento | sting ascendente | 4 compases | — |
| Misterio | celesta mute | loop ≤ 60 s | Sin disonancia |
| Puzzle resuelto | glissando + campanilla | 2 compases | — |
| Sello obtenido | fanfarria suave | 5 s | — |
| Festival | tema festivo | 90 s | Joy, 100 BPM |
| Ceremonia | coro + tambor | 120 s | Solemne, no ominoso |

## 5. Datos de configuración

- `res://data/audio/music_tema_bank.tres`
- `res://data/audio/music_context_matrix.tres`
- `res://data/audio/music_volumes.tres` (LUFS -16, ducking 6 dB, límites)
- `res://src/audio/music_director.gd` + `music_player.gd` + `shuffle_sampler.gd`

## 6. Reglas de calidad (QA)

- Check de M114: en 60 min de juego sin pausa, ninguna variación debe escucharse consecutiva más de 2 veces. pausas de 5-15 s.
- Check de M114: ningún momento de juego escucha "música de horror"; si QA lo detecta → bug.
- Check de M113: polifonía música ≤ 8 voces; memoria de audio ≤ 40 MB cargados (M62).
- Check final: normalización -16 LUFS y master con headroom 3 dB (M84).

## 7. Presupuesto de producción

| Ítem | Cantidad |
|---|---|
| Temas de zona/bioma | 12 |
| Temas de lugar especial (templo, ruinas, cueva, océano, submarina, Elysia) | 6 |
| Capas de tiempo (día/noche, 4 estaciones, 3 climas) | 10 |
| Variaciones (mín. 2 por tema) | +24 |
| Flujos (intro, menú, llegada, créditos, creación) | 5 |
| Narrativos (tensión, descubrimiento, misterio, festival, ceremonia, sello) | 6 |
| Leitmotifs | 7 |
| Stings | ≤ 20 |
| **Total** | **≈ 90 archivos de audio** (fit presupuesto M133) |