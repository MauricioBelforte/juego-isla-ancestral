# Log 1208: M91 lote 9 — sección de pruebas completa + API de Godot 3 corregida

**Fecha:** 2026-10-02
**Hora:** 21:35
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Se reescribieron las dos secciones que quedaban como esqueleto en
`03-Diseno.md` — **§11 «Pruebas de audio»** y **§19 «Pruebas de calidad»** —
usando la API ya verificada por reflexión en el Lote 7, y se corrigió la
**API de Godot 3** que arrastraban tres documentos del módulo.

El checklist pasó de **192 → 206 `[x]` (80% → 86%)** con 14 ítems nuevos
marcados, y quedaron notas anti-inflado en los 4 ítems que deben permanecer
en `[ ]` a propósito.

## Cambios Realizados

### 1. `03-Diseno.md` §11 «Pruebas de audio» (esqueleto → 119 líneas útiles)

Antes: un bloque con funciones vacías y comentarios `# Test estéreo`.
Ahora 7 subsecciones:

- **11.1** `AudioTestManager`: `enum Test`, señales `test_iniciado` /
  `paso_cambiado` / `test_terminado`, progreso visible (regla de sección 8).
- **11.2** Flujo y estados.
- **11.3** Test estéreo (L271 · L150 · L160) — `AudioEffectPanner.pan` a
  −1 / +1 con tono de 200 Hz y medición automática por
  `get_bus_peak_volume_left_db` / `..._right_db`.
- **11.4** Test espacial 3D (L272) — `AudioStreamPlayer3D` describiendo un
  círculo de 3 m, vuelta en 8 s.
- **11.5** Balance de canales (L273 · L152 · L163) — recorrido por
  `get_bus_channels()` con verificación automática (< −60 dB = fallo).
- **11.6** Test 5.1 / 7.1 (L161 · L162) — condicionado a
  `AudioServer.get_speaker_mode()`.
- **11.7** Botones de prueba en settings (L157 · L167).

### 2. `03-Diseno.md` §19 «Pruebas de calidad» (una línea → 5 subsecciones)

19.1 automáticas · 19.2 balance · 19.3 espacialización · 19.4 cambio de
dispositivo · 19.5 manuales de escenario.

### 3. Corrección de API de Godot 3 en tres documentos

Hallazgo: `03-Diseno` §10, `02-Analisis` §14 y los ítems L145 / L146 /
L264 / L265 usaban métodos que **no existen en Godot 4.7.2**:

| Equivocado (Godot 3) | Real (Godot 4.7.2, sondeo T-107) |
|---|---|
| `AudioServer.get_device_list()` | `AudioServer.get_output_device_list()` |
| `AudioServer.set_device(n)` | `AudioServer.set_output_device(n)` |
| `AudioServer.get_device()` | `AudioServer.get_output_device()` |

- El **código no estaba roto**: `scripts/audio/output_device_manager.gd` ya
  usaba los nombres reales desde el Lote 1 y lo advertía en su cabecera.
- Los 4 ítems se reescribieron con el patrón de L227 (el original queda
  preservado en `plan-inicial/05-Checklist.md`, que no se toca).
- `03-Diseno` §10 se reescribió con la forma real (`RefCounted` + `static`) y
  una nota de advertencia firmada.

### 4. 14 ítems marcados `[x]` (192 → 206)

L150, L152, L157, L160, L161, L162, L163, L167, L271, L272, L273, L303,
L305, L307 — todos con evidencia apuntando a `03-Diseno` §11.x / §19.x.

### 5. Notas anti-inflado (se mantienen en `[ ]`)

- **L18** y sus hijos L110–L116 → §7 sigue bloqueada (cero assets de audio).
- **L22 / L23** → el diseño está completo, falta **ejecutar** con hardware
  real; el rollup mide ejecución, no diseño.
- **L151** → HRTF, depende del `[?]` de L88.
- **L147** → el dropdown es de M53.

### 6. Error propio documentado (para no repetir)

Al cortar el bloque de §10 usé `list.index("```")` dos veces. Como
`list.index` compara **igualdad exacta** y la apertura es `` ```gdscript ``,
el primer `index` saltó a la cerca de **cierre** y el segundo a la siguiente
apertura: **se comieron 41 líneas de más** (encabezado `## 11`, `§11.1`,
`§11.2`).

- Se detectó porque el script imprimió «reemplazo lineas 544-599 (56
  lineas)» en vez de ~15, y la verificación estructural acusó los
  encabezados ausentes.
- Se recuperó desde el propio script fuente `diseno_s11_s19.py` (no hizo
  falta `git restore`, que habría borrado la reescritura de §19 sin commitear).
- Quedó un `__FIRMA__` del literal crudo; se corrigió en la misma pasada.
- **Lección:** buscar la apertura con `.startswith("```")` y después el
  siguiente elemento que **sea** `` ``` ``; nunca dos `index("```")`.

### 7. Limpieza

Borrado el sondeo temporal `game/isla-ancestral/scripts/audio/_probe_speaker.gd`.

## Verificaciones ejecutadas

- `python scripts/diagnosticar_mojibake.py` → **LIMPIO** (0 sucios).
- Verificación estructural propia (`verif_lote9.py`) → **OK** en los 4
  archivos: 03-Diseno 905 líneas / LF / 44 líneas de cerca balanceadas /
  38 encabezados en orden 1→19 / 0 usos de API vieja en bloques de código;
  05-Checklist CRLF y 206/32/1/239; 04-Codigo 1361 líneas / LF / 10 bloques
  de Notas.
- Staging vacío antes de `git add` (Trampa 114).
- **No se ejecutó ninguna suite** en este lote (no se tocó GDScript); las 3
  suites siguen en **265 checks, 0 fallos**.

## Estado del módulo

| Métrica | Antes | Después |
|---|---|---|
| `[x]` | 192 | **206** |
| `[ ]` | 46 | **32** |
| `[?]` | 1 | 1 (L88, HRTF) |
| Total | 239 | 239 |
| Avance | 80% | **86%** |

> M91 **no puede cerrarse en `✅`** mientras L88 esté en `[?]` (§21.2 / §21.6):
> al liberarse la fila debe quedar en **`🟡 Con dudas`**.

## Archivos Modificados/Creados

- `DOCUMENTACION/91-Configuracion-De-Audio/plan-actual/03-Diseno.md`
- `DOCUMENTACION/91-Configuracion-De-Audio/plan-actual/04-Codigo.md`
- `DOCUMENTACION/91-Configuracion-De-Audio/plan-actual/05-Checklist.md`
- `DOCUMENTACION/91-Configuracion-De-Audio/plan-actual/02-Analisis.md`
- `Logs/NUMEROS_DISPONIBLES.txt` (consumido el **1208**)

Creado:
- `Logs/1208-M91-lote9-pruebas-audio-api-godot3_2026-10-02_21-35-00.md`
