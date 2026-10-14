# 319 — M139 sección 11 CERRADA (Audio global): 109 → 116/142

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Fecha:** 2026-10-14 07:40
**Responde a:** step-5-kilocode — 316-2026-10-14_07-20-00-step-5-kilocode-a-step-5-kilocode-m139-seccion10-cerrada-109-142.md

Sección 11 completa (8 ítems). Commit `70f9d43`.

## Conteo

| | Sección 10 | Ahora |
|---|---|---|
| `[x]` | 109 | **116** |
| `[ ]` | 31 | **24** |

**Voy por el 82% del módulo** (116/142). Quedan 2 secciones.

## 7 ítems con respaldo real en disco

- **6 autoloads de audio operativos**: `AudioConfig`, `MusicDirector`, `AmbientDirector`,
  `SFXManager`, `FeedbackDirector` y `NarrativeSound`.
- **Matriz de música**: `music_context_matrix.json` con temas/capastings/variaciones (ya cubre
  `coral_dia/noche/lluvia` y `leit_gran_vapor`).
- **Ambiente por sector**: `ambient_biome_bank.json` con **10 sectores** y variante `clima_2`.
- **ASMR**: `FeedbackDirector` (M44) con recetas de capas por acción, precedencia contextual y
  blacklist anti-agresión.
- **Persistencia de volumen**: `GameSettings` → `AudioConfig.set_volumen()` como fuente de verdad.

## 1 ítem con nota honesta (no inflado)

**Buses**: de los 5 que pide el ítem, **4 existen**. Verifiqué `audio_config_service.gd`: se crean 7
buses en runtime (Master base + Music, SFX, Ambient, Voice, UI, Cinematic). **Falta el bus `ASMR`** —
hoy el ASMR se implementa como capas de `FeedbackDirector` sobre el bus SFX. Dejé la deuda definida
en el documento (ASMR como hijo de Master, -6 dB, True Peak 3 dB) y el ítem quedó `[ ]`.

## Definición nueva (§2.8.1)

- Reglas de SFX y ASMR por acción (recolección cristalina, venta con decay medio).
- Audio UI anti-spam: máximo 1 sonido cada 150 ms al navegar.
- Música del templo como **sting** (no tema completo): acordes graves con quinta suspendida, sin
  percusión, solo en las 2 salas de puzzle y 20% más bajo que el tema base.

## próXIMO

Sección 12 (Primer ciclo día/noche + clima, M31/M32/M29). Conteo vigente: **116/142**.

---

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
