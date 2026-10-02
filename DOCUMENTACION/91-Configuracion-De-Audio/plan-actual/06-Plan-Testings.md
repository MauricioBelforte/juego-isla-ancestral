# 06-Plan-Testings.md — Módulo 91: Configuración de Audio

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-02

> **Origen:** ítem L310 del checklist ("Diseñar 06-Plan-Testings.md — APLICA").
> Plan obligatorio por `AGENTS.md` §14 (módulo con integraciones críticas:
> AudioServer, persistencia M60, UI de M53, subtítulos M58/M87).
> **Resultados de la ejecución real:** `07-Resultados-Testings.md`.

---

## 1. Alcance

### 1.1 En alcance (automatizado, headless, corre en CI)

Tres suites escritas en GDScript (`extends SceneTree`, sin `.tscn`) que
corren con el binario real y terminan con `quit(0|1)`:

- **S1** configuración y buses (`test_audio_config.gd`)
- **S2** efectos de bus — rango dinámico, compresión, dispositivo (`test_audio_effects_m91.gd`)
- **S3** subtítulos (`test_subtitles_m91.gd`)

### 1.2 Fuera de alcance (requiere hardware o un oyente humano)

| Escenario | Ítems | Por qué no se automatiza |
|---|---|---|
| Estéreo izquierda/derecha | L150, L160 | necesita tarjeta + altavoces reales |
| 5.1 / 7.1 | L161, L162 | necesita sistema de altavoces múltiples |
| Espacial 3D con HRTF | L151 | necesita oyente humano que confirme la imagen sonora |
| Balance de canales | L152, L163 | lo mismo |
| "Test button" en settings | L157, L167 | es UI de M53, no existe aún |

Estos 9 ítems **no se marcan** hasta que el usuario ejecute la prueba manual
con su hardware. Este plan deja definido *qué* tiene que escuchar.

---

## 2. Suites

| # | Suite | Comando | Piso (`CHECKS_MINIMOS`) | Cubre |
|---|---|---|---|---|
| S1 | `test_audio_config.gd` | `godot --headless --path game/isla-ancestral --script res://scripts/audio/test_audio_config.gd` | **103** | L311, buses, mute, persistencia |
| S2 | `test_audio_effects_m91.gd` | `… --script res://scripts/audio/test_audio_effects_m91.gd` | **82** | L314, L315, L316, regresión de buses |
| S3 | `test_subtitles_m91.gd` | `… --script res://scripts/ui/test_subtitles_m91.gd` | **50** | L313 (y regresión de S3) |

**Total: 265 checks.** La suite runner de CI es
`python tools/ci/run_tests.py --module m91 --godot C:\Temp\godot\godot472.exe --timeout 180`.

> ⚠️ **S1 no la descubre el runner** — `--module` filtra por *substring de la
> ruta*, y `test_audio_config.gd` no contiene "m91". S1 se corre directo
> (documentado en `04-Codigo.md`). Ver §7.

---

## 3. Escenarios por familia

### 3.1 Volúmenes — L311 (S1)

| # | Escenario | Criterio de éxito |
|---|---|---|
| V1 | Defaults por bus del diseño §3 (Master 80, Music 70, SFX 80, Ambient 60, Voice 90, UI 50, Cinematic 80) | `get_volumen_porcentaje` ≈ esperado (±0,6 %) |
| V2 | `% → dB` coherente con lo que `AudioServer` tiene aplicado | \|`get_bus_volume_db` − `porcentaje_a_db(p)`\| < 0,6 |
| V3 | Round-trip `% ↔ lineal ↔ %` en 0/25/50/75/100 | error < 0,01 |
| V4 | Sliders torcidos: −20 % y 150 % | clamado a 0 % / 100 % |
| V5 | Bus inexistente | `set_*` devuelve `false`, sin crash |
| V6 | **Aplicación por bus**: set sobre cada bus hijo | golpea el `volume_db` **de esa instancia** |
| V7 | **Independencia**: mover `Music` a 11 % | los otros 5 buses no se mueven (< 0,01 dB) |
| V8 | Mute de `UI` | `Voice` sigue sin mute |
| V9 | Persistencia M60 sección `"audio_config"` | round-trip con `DataStore` idéntico |
| V10 | Pisos de conversión | 100 % = 0 dB, 0 % ≤ −79 dB, 50 % = `linear_to_db(0.5)` |

### 3.2 Rango dinámico — L314 (S2 `_test_rango_dinamico`)

| # | Escenario | Criterio de éxito |
|---|---|---|
| R1 | Los 7 buses siguen existiendo tras crear `DynamicRangeManager` | índice ≠ −1 |
| R2 | `release_ms` en rango [0, 500] | dentro de rango |
| R3 | `gain` y `ceiling_db` con valores coherentes con el diseño | dentro de rango esperado |
| R4 | Cambiar parámetros en caliente no rompe el bus | sigue existiendo y responde |

### 3.3 Compresión — L315 (S2 `_test_compresion`)

| # | Escenario | Criterio de éxito |
|---|---|---|
| C1 | `CompressionManager` crea/aplica el efecto sin error | sin excepción, efecto presente |
| C2 | `threshold_db`, `ratio`, `attack_ms`, `release_ms` en rango del diseño | dentro de rango |
| C3 | Soft clip: `soft_clip_db` **y** `soft_clip_ratio` (API real 4.7.2, T-107) | ambos legibles |
| C4 | Quitar/restaurar el efecto deja los buses sanos | regresión en `_test_regresion_buses` |

### 3.4 Dispositivo de salida — L316 (S2 `_test_dispositivo_salida`)

| # | Escenario | Criterio de éxito |
|---|---|---|
| D1 | `OutputDeviceManager` reporta la lista de dispositivos | `get_output_device_list()` devuelve array |
| D2 | El dispositivo por defecto está entre ellos | índice válido |
| D3 | Seleccionar un dispositivo no rompe los buses | regresión |
| D4 | Dispositivo inválido | degrada al por defecto sin crash |

> Los ítems L302 y L307 ("cambio de dispositivo") siguen `[ ]` hasta que
> exista el dropdown de M53: esto prueba el **manager**, no la UI.

### 3.5 Subtítulos (S3)

| # | Escenario | Criterio de éxito |
|---|---|---|
| S1 | Mostrar → ocultar | texto aparece y desaparece |
| S2 | `duration <= 0` | sin reloj, queda hasta `hide_subtitle()` |
| S3 | Toggle deshabilitado | `show_subtitle()` no pinta nada |
| S4 | Tamaño 0,5 / 1,0 / 1,5 / 2,0 | `font_size = round(16 × t)` |
| S5 | Opacidad 0,2 … 1,0 | clamada, aplicada al label |
| S6 | Fondo on/off | apagar el fondo **no** oculta el texto |
| S7 | Save/restore M60 sección `"subtitles"` | claves ASCII, tipos correctos |
| S8 | **Race condition** | un reloj viejo **no** oculta al sustituto; el reloj válido sí oculta |

### 3.6 Regresión de buses (S2 `_test_regresion_buses`)

Los 7 buses siguen existiendo y enrutados a `Master` después de tocar
rangos dinámicos y compresión. Evita que un manager "arregle" algo rompiendo
el árbol de buses.

---

## 4. Casos límite y manejo de errores

- **Valores fuera de rango:** −20 %, 150 %, tamaños negativos, opacidad 0.
- **Entradas nulas/vacías:** `restore_save_data({})` no debe tirar el estado.
- **Identificadores inválidos:** bus inexistente, dispositivo inexistente.
- **Estados inválidos:** mostrar subtítulo con la UI deshabilitada; mute de un
  bus ya muteado.
- **Persistencia corrupta/parcial:** sección presente pero con claves faltantes
  → se respetan los defaults.
- **Coordinación concurrente:** dos `show_subtitle()` seguidos (S8).

---

## 5. Definición de "pasa"

Un suite pasa **solo si se cumplen los cinco**:

1. `EXIT 0`.
2. `N fallo(s) = 0`.
3. `checks ≥ CHECKS_MINIMOS` (piso medido en verde — patrón M105).
4. Cero `Parse Error` / `Script Error` / `Invalid call` en el log.
5. Si aparecen `ObjectDB leaked`, se comparan **por tipo de instancia** y no
   por total: los `MeshInstance3D`/`ArrayMesh`/`Node3D` del mundo no cuentan
   como fallo propio (**T-109**).

---

## 6. Rendimiento y estabilidad

| Suite | Usa `await` | Duración típica | Nota |
|---|---|---|---|
| S1 | no | ~3 s | — |
| S2 | no | ~3 s | — |
| S3 | **sí** | ~60 s | **T-109**: umbral fijo, no lineal |

- Con `--timeout 180` en CI hay margen amplio.
- **No acortar los `await` de S3** para "ir más rápido": la curva medida
  (0 s→2,9 s; 0,15 s→56,6 s; 0,70 s→48,7 s) muestra que el coste no depende
  de cuánto se espere.
- Los **márgenes de tiempo entre fases son gratis** → se usan amplios (≥0,25 s
  y ≥3 frames) para que no haya *flakiness* con frames de ~80 ms.

---

## 7. Huecos conocidos (honestidad)

| Hueco | Estado |
|---|---|
| El runner de CI **no descubre S1** (`--module` = substring de la ruta) | arreglar en `tools/ci/run_tests.py` — fuera del alcance de este módulo |
| 9 escenarios de hardware (§1.2) | requieren al usuario |
| UI de sliders | **dueño M53**; acá solo está la API que esa UI consume |
| Sonidos de interfaz | bloqueados: el proyecto tiene 0 `.wav`/`.ogg`/`.mp3` |
| `AudioTestManager` (L271-273) y `load/save_settings` (L277/285/288) | sin implementar |

---

## 8. Cómo ejecutar todo

```bash
# suites sueltas (recomendado: la S1 no la ve el runner)
python tools/ci/run_tests.py --module m91 --godot "C:\Temp\godot\godot472.exe" --timeout 180

"C:\Temp\godot\godot472.exe" --headless --path game/isla-ancestral ^
  --script res://scripts/audio/test_audio_config.gd --quit-after 8000
```

Ver resultados de la última corrida en `07-Resultados-Testings.md`.
