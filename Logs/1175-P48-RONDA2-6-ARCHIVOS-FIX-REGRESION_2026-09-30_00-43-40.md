# Log 1175: P-48 ronda 2 — 6 archivos restantes del dominio mimo + fix de regresión

**Fecha:** 2026-09-30
**Hora:** 00:43
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Reserva:** primer libre verificado = **1175** (pool incluido en este mismo commit, § del coordinador).

## Encargo

El coordinador señaló que mi cierre anterior dijo «0 sucias» pero quedaban **6 archivos de mi
dominio**: 5 M + 1 ??. Confirmar propiedad y cerrarlos.

## Propiedad confirmada: **SÍ son míos** (los 6)

El bucket P-48 original los tenía asignados a otros por el **mapa módulo→agente**, no por medición:

| Archivo | P-48 decía | Evidencia real |
|---|---|---|
| `data/villagers/{bruno_sapo,finneas_zorro,luna_zorra,mateo_mapache,mercedes_lince}.tres` | `OTRO:hy4` («M19 → Hy4») | **Log 1040** (`Modelo: MiMo V2.5`): lista `mercedes_lince.tres` como *creado* y los otros como *modificados — Rutina diaria enhanced/child/elderly* |
| `scripts/audio/narrative_sound.gd` | `OTRO:deepseek-v4-flash*` (tomaba el **primer** token de la cabecera compuesta) | Cabecera `deepseek (iter. 1) / **mimo-v2.5 (iter. 2)**`; el diff pendiente **es** el iter. 2; **Log 1095** (`Modelo: mimo-v2.5`) |

**El `Log 1167` (P-52, DeepSeek-V4.1-Flash) ya lo había medido por diff y llegó a la misma
conclusión:** «los 4 diffs coinciden palabra por palabra con esas descripciones → son de **mimo**
(M64)… M150 es de mimo (**confirmado por el coordinador**)… el bucket *hy4* queda vacío».
Su lección: *el mapa módulo→agente es una pista, no una prueba*.

## Commits creados

| Commit | Módulo | Archivos |
|---|---|---|
| `8db4abd` | M64 vecinos | 5 `.tres` |
| `c6b3426` | M150 sonido narrativo | `narrative_sound.gd` + `test_narrative_m150.gd` |

## ⚠️ Regresión que YO introduje y corregí

Al haber commiteado `data/audio/narrative_sound.json` v1.1 en **`3a568ea`** (ronda 1), el catálogo
pasó de **6 → 32 momentos**, y `test_narrative_m150.gd` (autores de deepseek, sin cambios, en HEAD)
exigía `== 6` → **2 checks en rojo**. Medido antes/después:

```
3a568ea^  momentos=6    bytes=3104   test OK
3a568ea   momentos=32   bytes=9716   test FAIL
```

El estado rojo ya estaba en el worktree desde el 2026-09-20 (json v1.1 + test v1.0); **mi commit lo
movió a HEAD**. Fix: los dos asserts de conteo fijo `== 6` → `>= 6` (los 6 anclas originales
`sello_obtenido`, `elysia_avistada`, etc. ya se validan uno a uno en `_test_momentos`, así que el
conteo exacto era lo único frágil). **12 checks, 0 fallos, exit 0.**

## Verificación

- **M64: 5/5 OK** (re-corrida tras los 5 `.tres`)
- **M150: 12 checks / 0 fallos / exit 0** (directo y vía `run_tests.py`)
- `narrative_sound.gd`: `--check-only` **0 errores**
- 5 `.tres`: cabecera `format=3` válida, rutina de **8-9 tramos**
- **Push NEGATIVO**

## Sin tocar

`CHECKLIST-GLOBAL.md`, buckets C / AMBIGUO / EOL / SCRATCH, y los archivos de agnes.
`game_clock.gd` (7.ª exclusión de P-52) ya estaba **limpio** al revisarlo.

## Archivos Modificados/Creados

- `game/isla-ancestral/data/villagers/{bruno_sapo,finneas_zorro,luna_zorra,mateo_mapache,mercedes_lince}.tres`
- `game/isla-ancestral/scripts/audio/narrative_sound.gd`
- `game/isla-ancestral/scripts/audio/test_narrative_m150.gd`
- `Logs/NUMEROS_DISPONIBLES.txt` (reserva 1175, en este mismo commit)
- `Logs/1175-P48-RONDA2-6-ARCHIVOS-FIX-REGRESION_2026-09-30_00-43-40.md` (este archivo)
