# Log 2248: M74 degradado (58 flips) y hallazgo del flip masivo de 413 [?]

**Fecha:** 2026-10-29
**Hora:** 04:47
**Modelo:** DeepSeek V4.1 Flash
**Plataforma:** OpenCode

## Resumen

Auditoría gate-1 del módulo **74-Eventos** (285/0/0, Global 285/285, sin trabajo en vuelo).
Resultado: **DEGRADADO Y APLICADO** — 58 marcas `[x]` → `[?]`, y un hallazgo sistémico:
el commit `3a3d32c` borró **413 `[?]` en 22 módulos** sin evidencia, en un solo acto.

## 1. Disparador

M74 tenía **285 `[x]` / 0 `[ ]` / 0 `[?]`**: cero pendientes en 285 ítems. En este proyecto
eso no es un logro, es una señal. Además tenía 12 líneas de spec autocontradictoria.

## 2. Evidencia en la propia línea

Cada ítem auditado el 2026-10-13 lleva la anotación del auditor en la MISMA línea que la marca,
y dice lo contrario:

- L117 `RF5.15` minijuego: «0 hits de minijuego/partida de festival en scripts/eventos/».
- L130 `RF6.7` progreso M71: «0 hits de entrega de progreso a M71».
- L160 `RF10.3` tutorial M92: «0 hits de tutorial/primer festival (M92)».
- L179 `RN12` determinismo: «0 hits de semilla/seed».
- L222 `I15` cargador M63: «0 hits de cargador bajo demanda».
- L232 `I25` analytics M104: «0 hits de analytics/telemetria (M104)».
- L327-L333 `M21-M27`: «verificacion manual… Pendiente» / «manual. Pendiente.» (7 pruebas).

Clasificación: **33 negaciones limpias** + **19 parciales** (artefacto citado no hace lo que
el ítem pide: stub, roto, dormido) = **52**; más 6 ítems del mismo bloque detectados por diff
(ver §3) = **58**.

## 3. La prueba documental (git)

| Commit | Fecha | Mensaje | M74 |
|---|---|---|---|
| `b9ba71e` | 2026-10-13 17:31 | «Se completo la auditoria de los 59 items con duda de M74 con evidencia» | 227/0/58 |
| `3a3d32c` | 2026-10-25 22:17 | «Se preservó reorientacion de flota + drift Global + sellos M73» | 285/0/0 |

Diff: 503 → 503 líneas, **58 líneas distintas, todas `[?]` → `[x]`, texto idéntico**. La línea
`Totales` del archivo nunca se actualizó (sigue diciendo 227 completados / 58 no resueltos).

## 4. Verificación propia contra disco (2026-10-29)

Grep acotado a `game/isla-ancestral/scripts/eventos/`:

| Comprobación | Hits |
|---|---|
| `minijuego\|minigame` | 0 |
| `tutorial\|M92` | 0 |
| `analytics\|telemetr\|M104` | 0 |
| `M53\|hud` | 0 |
| `M58\|accesib` | 0 |
| `contraste` | 0 |
| `seed\|randomize\|RandomNumberGenerator` | 0 |
| `banner\|modal` | 0 |
| `tween\|AnimationPlayer` | 0 |
| `Profiler\|performance\|memoria\|alloc` | 0 |
| `concurrent` | 0 |
| `queue_free` de recinto en producción | 0 (los 2 hits son de un test M21) |

Casos especiales:
- **I10 ROTo:** `recompensa_def.gd` L95-96 llama `fs.sumar_puntos(...)`; `func sumar_puntos`
  da **0 hits en todo el juego**. La recompensa de amistad no se entrega y solo emite un warning.
- **I12 dormido:** `registrar_progreso_evento` solo lo define un stub de test; M71 no lo expone.

## 5. Acción aplicada

58 marcas `[x]` → `[?]`, restaurando el blob auditado de `b9ba71e`.

- Cuerpo: **227 `[x]` / 0 `[ ]` / 58 `[?]` = 285** = línea `Totales`.
- Nota firmada al pie del `05-Checklist.md` con causa y evidencia.
- UTF-8 sin BOM, CRLF preservado (503 CRLF), sin mojibake.
- `git diff --numstat`: 77 insertadas / 58 borradas (58 marcas + 19 líneas de nota).

## 6. Hallazgo sistémico: el flip masivo

Balance de `3a3d32c` sobre los 23 `05-Checklist.md` que tocó:
**+446 `[x]` · −413 `[?]` · −33 `[ ]`**.

| Módulo | `[?]` antes → después | `[x]` |
|---|---|---|
| 74-Eventos | 58 → 0 | +58 |
| 71-Progresion | 45 → 0 | +45 |
| 12-Camara | 45 → 2 | +43 |
| 11-Personaje-Del-Jugador | 45 → 7 | +38 |
| 27-Islas-Del-Mundo | 40 → 3 | +37 |
| 162-Dialogos-Contextuales | 36 → 2 | +34 |
| 156-Terrenos-Y-Movimiento | 34 → 4 | +30 |
| 105-Telemetria-De-Gameplay | 28 → 0 | +28 |
| 34-Pesca | 36 → 8 | +28 |
| 115-Hardware | 26 → 0 | +26 |
| 63-Cargas-Y-Streaming | 27 → 5 | +22 |
| 64-IA-De-NPC | 29 → 10 | +19 |
| 94-Retencion-Sin-FOMO | 55 → 50 | +5 |

Otros commits con el mismo patrón: `dd6fb70` (25-oct) **−54 `[?]` / +468 `[x]`**;
`a7a3a6b` (26-oct) **−291 `[?]` / +302 `[x]`**. Los tres son commits de «Se preservó la
jornada…»: capturaron árboles de trabajo ya inflados, no los generaron. No hay script en
`scripts/` con `replace("[?]", "[x]")` (`aplicar_drifts_global.py` solo toca el Global).

Módulos que quedaron con `[?]` = 0 exacto y totales altos: **M74** (285), **M71** (213),
**M105** (171), **M115** (104).

## 7. Recomendaciones

1. No revertir los 413 a ciegas: cada módulo necesita contraste contra su último blob auditado.
2. Patrón de búsqueda: `[?]` → `[x]` con **texto idéntico** entre dos versiones del archivo.
3. Prioridad: **M71** (45→0) y **M105** (28→0), sin dueño en vuelo.
4. El detector negativo amplio (959 líneas `[x]` en 131 módulos) es ruidoso (incluye «no
   bloqueante», límites de diseño y preguntas al fundador): usarlo como triage, no como veredicto.

## 8. Estado del Global (para la directora)

Fila M74: `🟡 Con dudas | 285/285 | … | — | atria-dawn | 2026-10-12`.
`Progreso` debe pasar a **227/285**; la fila tiene corrimiento de columnas (Agente='—',
Última actividad='atria-dawn', Notas arranca con '2026-10-12').

## Archivos Modificados/Creados

- `DOCUMENTACION/74-Eventos/plan-actual/05-Checklist.md` — **modificado**: 58 `[x]` → `[?]` + nota firmada al pie.
- `Mensajes entre modelos/DS-V4.1-Flash-Opencode/225-2026-10-29_04-47-00-ds-v4-1-flash-opencode-a-agnes-3-flash-m74-58-degradados-flip-masivo-413.md` — **creado** (informe a la directora).
- `Logs/2248-m74-degradado-58-flips-y-hallazgo-flip-masivo-413_2026-10-29_04-47-00.md` — **creado** (este archivo).
- `Logs/NUMEROS_DISPONIBLES.txt` — **modificado**: consumida la línea `2248`.
- `Mensajes entre modelos/DS-V4.1-Flash-Opencode/.ultima-revision-ds.txt` — **modificado**: 223 → 225.
- `DOCUMENTACION/TAREAS-POR-MODELO/DS-V4.1-Flash-Opencode/CRONOMETRO-V2-DS-V4.1-FLASH-OPENCODE.md` — **modificado**: vuelta 100.

## Sin tocar (por regla)

- `CHECKLIST-GLOBAL.md` (solo lectura: los sellos y el saneo son de la directora).
- Sin commits: la directora/automatización commitea.
- M67 Ruta B (63 promovidos) sigue pendiente de OK explícito.
