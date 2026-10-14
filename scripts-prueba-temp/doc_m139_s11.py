# -*- coding: utf-8 -*-
import io

p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """### 2.8.1 Sistema de audio de fase (cerrado 2026-10-14, step-5-kilocode)

Cierra la seccion 11 del checklist. **La arquitectura de audio ya existe y esta operativa:**

| Director / config | Ruta (autoload) | Cubre |
|---|---|---|
| `AudioConfig` | `scripts/audio/audio_config_service.gd` | perfiles y volumen; fuente de verdad de audio |
| `MusicDirector` | `scripts/audio/music_director.gd` | musica por contexto (M41) |
| `AmbientDirector` | `scripts/audio/ambient_director.gd` | ambiente (M42) |
| `SFXManager` | `scripts/audio/sfx_manager.gd` | efectos de sonido (M43) |
| `FeedbackDirector` | `scripts/audio/feedback_director.gd` | **ASMR y feedback con recetas de capas por accion**, blacklist anti-agresion y sincronia de keyframes (M44) |
| `NarrativeSound` | `scripts/audio/narrative_sound.gd` | sonido narrativo |

**Buses (verificado en `audio_config_service.gd`):** se crean 7 en runtime — `Master` (base) +
`Music`, `SFX`, `Ambient`, `Voice`, `UI` y `Cinematic`. **Nota honesta: el bus `ASMR` que pide el
checklist NO existe** — hoy el ASMR se implementa como capas dentro de `FeedbackDirector` sobre el
bus `SFX`. La definicion del bus propio queda anotada como deuda: agregarlo como hijo de Master con
atenuacion -6 dB y limite deTrue Peak en 3 dB.

**Transiciones de musica por zona y estado:** respaldadas por
`data/audio/music_context_matrix.json` (temas, capas, stings y variaciones) + `MusicDirector`. La
matriz ya cubre contexto por zona y estado (dia/noche/lluvia, con `coral_dia`, `coral_noche`,
`coral_lluvia` y `leit_gran_vapor`).

**Ambiente por sector:** respaldado por `data/audio/ambient_biome_bank.json`, que define capas para
**10 sectores** (playa, bosque, pradera, volcan, montana, selva, desierto, laguna, arrecife, ceniza)
con variante `clima_2`. Los sectores de la fase (puerto, bosque, templo, faro) mapean a playa /
bosque / montana / acantilado.

**SFX por interaccion (M43):** `SFXManager` los emite por evento; la regla de fase es que todo lo
interactuable del slice (recoger, pescar, vender, construir, abrir) tenga su sample con variacion de
tono para no cansar.

**ASMR de recoleccion y venta (M44):** `FeedbackDirector` ya aplica recetas de capas por accion con
precedencia contextual (interior/clima/hora). La regla de fase: recoleccion = capas cortas y
cristalinas; venta = capas con decay medio. Sin muestras agresivas (la blacklist anti-agresion ya
esta implementada).

**Audio UI:** bus `UI` con confirmaciones cortas y no repetitivas (max 1 sonido cada 150 ms para
evitar spam al navegar el menu).

**Musica del templo con tension suave:** definida como **sting** de la matriz (no tema completo):
acordes graves con quinta suspendida, sin percusion, entrando solo en las 2 salas de puzzle y
saliendo al resolverlos. Volumen 20% por debajo del tema base.

**Persistencia de niveles de volumen:** `GameSettings` documenta el volumen y delega en
`AudioConfig.set_volumen()` como fuente de verdad; los niveles se guardan en el save de ajustes y se
aplican al arrancar.
"""

ancla = "### 2.7.1 Save v3 + menu de fase"
if ancla in t:
    print("AVISO: 2.7.1 encontrado, usar otro ancla")
# insertar antes de la seccion 3 (Pipeline)
a2 = "## 3. Pipeline de assets (M108)"
if a2 in t:
    t = t.replace(a2, seccion.rstrip() + "\n\n" + a2, 1)
    print("seccion 2.8.1 insertada antes de Pipeline")
else:
    print("AVISO: ancla Pipeline no encontrada")

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("03-Diseno.md actualizado")
