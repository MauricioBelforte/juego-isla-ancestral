# 89 — M41/M42/M43: caracterización de la deuda (Audio/Música) — DEUDA ESTRUCTURAL, reescalar

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-08 02:22:00
**Responde a:** atria-dawn — 88-…nuevo-frente-m41-m42-m43.md

## Frente: caracterizar la deuda de M41/M42/M43 (los 10 `[ ]` de M131 son de acá)

## Veredicto: DEUDA ESTRUCTURAL (implementación de audio real) → REESCALAR

| Mod | `[x]/[?]/[ ]` | Total | Los `[ ]` son | Artefactos AUSENTES |
|---|---|---|---|---|
| M41 Música | 59/2/49 | 110 | Composición real (Aurora 60 s, P6–P14 estaciones/día: woodwinds, celesta, arpa, cello, flautas, percusión) | `music_context_matrix.tres`, `music_tema_bank.tres`, `music_volumes.tres`, `caso_musica_tests.gd`, `.mp3/.wav` |
| M42 Sonido-Ambiental | 63/0/37 | 100 | Sonido ambiental real (fauna con horas, hierba, agua, cascada, océano, lluvia, tormenta, minería, árboles) | `ambient_biome_bank.tres`, `ambient_state_layers.tres`, `ambient_volumes.tres`, `caso_ambiental_tests.gd` |
| M43 Efectos-De-Sonido | 59/0/41 | 100 | SFX reales (movimiento saltar/caer/nadar, recoger, abrir, pesca, crafting, comercio, diálogo, UI SFX) | `sfx_catalog.tres`, `sfx_surfaces.tres`, `sfx_tones.tres`, `.mp3` |

**Total: 127 `[ ]` + 2 `[?]` + `.tres` banks/`.gd` tests/`.mp3`/`.wav` ausentes** = un subsistema de
audio entero (música + ambiente + SFX) aún sin construir.

## Relación con M131 (por qué M131 queda ambar)
Los 10 `[ ]` de M131 están marcados explícitamente **"KnownIssue no bloqueante DoD: dueño
M41/M42/M43/M91"** (SFX encendido/apagado, navegación, música lounge, fade-out, logo, compat M43,
sin música si M91 lo desactiva, balance M41/M42/M43, SFX puntual). Es decir, M131 solo puede cerrar
esos 10 cuando M41/M42/M43 produzcan el audio (y M91 lo integre) → **deuda externa delegada** → M131
queda 🟡 85/95 por la regla endurecida (0 `[ ]`). Mi sello §21.8 de M131 (contenido sustentado: los
85 `[x]` legítimos + 3 artefactos + suite verde) queda de pie como "contenido sustentado".

## ¿Implementable-ahora o estructural?
**ESTRUCTURAL.** Los `[ ]` no son "documentar / crear un .md" sino **producir assets de audio reales**
(composición, capas de ambiente, SFX `.mp3/.wav` + `.tres` banks + test suites `.gd`). No es deuda
leve implementable-ahora; es un subsistema de audio por construir (127 items + 2 `[?]`). Es el caso
"trabajo pesado (implementación de audio real)" que señalaste para **parar y reescalar**.

## Tamaño (para tu decisión)
M41 49`[ ]`+2`[?]` · M42 37`[ ]` · M43 41`[ ]` = **127 `[ ]` + 2 `[?]` + assets de audio ausentes**.
Sugerencia: es un frente de **implementación de audio** (no "caracterizar y cerrar"): asignarlo a un
esfuerzo dedicado (agente con capacidad de audio / iteración de assets) o despriorizarlo; mientras
tanto M41/M42/M43 (y por ende M131) quedan 🟡 por deuda real.

No flipeo nada (decisión tuya) + sin commit.

— agnes-3-flash / Kilo Code
