# Log 1194: API de porcentaje 0-100 para sliders (lote 2 de M91)

**Fecha:** 2026-10-02
**Hora:** 19:15
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Se implementó el **lote 2 de 5** del módulo `91-Configuracion-De-Audio`: la
API de porcentaje 0-100 que la UI de M53 necesita para sus sliders, añadida a
`audio_config_service.gd` **sin tocar la lógica existente**. La suite base
pasó de 0 checks reportados a **66 checks con piso medido en verde**, y el
checklist del módulo pasó de 118 a **141 `[x]`**.

## Cambios Realizados

### Código — `scripts/audio/audio_config_service.gd`

Seis funciones nuevas, sin modificar ninguna existente:

| Función | Tipo | Qué hace |
|---|---|---|
| `porcentaje_a_lineal(p)` | static | slider 0-100 → lineal 0-1 (clamp) |
| `lineal_a_porcentaje(v)` | static | lineal 0-1 → slider 0-100 |
| `porcentaje_a_db(p)` | static | slider 0-100 → dB (`linear_to_db`, piso -80 dB) |
| `db_a_porcentaje(db)` | static | inversa (`db_to_linear`) |
| `set_volumen_porcentaje(bus, p)` | instancia | fija volumen desde el slider |
| `get_volumen_porcentaje(bus)` | instancia | devuelve el valor 0-100 |

**Decisión de diseño:** el estado interno **sigue siendo lineal 0-1**. El
porcentaje es solo presentación, así persistencia (M60), señales
(`volumen_cambiado`) y mute **no cambian de semántica** y no hay dos fuentes
de verdad. `set_volumen_porcentaje` delega en `set_volumen`, por lo que
persiste y emite señal automáticamente.

### Tests — `scripts/audio/test_audio_config.gd`

- Nuevo `_test_porcentaje_0_100()` con **~29 checks**: defaults en % de los 7
  buses, conversión 0-100→dB coherente con lo aplicado en `AudioServer`,
  round-trip porcentaje↔lineal, set/get, clamp (150%→100%, -20%→0%), bus
  inexistente → false, pisos (100% = 0 dB, 0% = -80 dB, 50% = `linear_to_db(0.5)`),
  inversa `db_a_porcentaje`, y restauración del estado para no ensuciar otros tests.
- **Piso `CHECKS_MINIMOS := 66` medido en verde** (patrón M105). El test ahora
  reporta `=== TEST M91 AUDIO: 66 checks, 0 fallo(s) ===` y falla si no llega
  al piso, aunque reporte 0 fallos (anti falso-verde).
- Cabecera actualizada con la modificación.

### Verificación

| Prueba | Resultado |
|---|---|
| `--check-only` del autoload | EXIT 0, sin parse errors |
| Sondeo T-107 (`linear_to_db(0.5)`, `db_to_linear(-6.0)`) | ejecutado, no adivinado |
| `test_audio_config.gd` (piso 66) | **66 checks, 0 fallos**, EXIT 0 |
| `test_audio_effects_m91.gd` (piso 82) | **82 checks, 0 fallos** (regresión nula) |
| `tools/ci/run_tests.py --module m91` | **1 OK, 0 FAIL** |
| Encoding del checklist | UTF-8 estricto, sin BOM, mojibake LIMPIO, 238 CRLF |

### Checklist

`05-Checklist.md`: **118 → 141 `[x]`** (+23 ítems), 98 `[ ]`, 0 `[?]`,
total **239 intacto**. Cubre los 23 ítems de valores por defecto, sliders
0-100% y conversión a dB de las 7 secciones (maestro, música, efectos,
ambiente, voces, UI, cinemáticas) + los ítems 33/34 del bloque general.
Verificación por **identidad de línea** (T-106): número + fragmento, aborto
previo a la escritura.

### No marcado (honestidad)

- `Definir control de música/efectos/ambiente/voces/UI` (5 ítems) → motores
  M41/M42/M43, lote 4.
- `Definir aplicación al bus de X` (6 ítems) → solo está verificado el estado
  inicial de cada bus y el cambio dinámico de Music; requiere un test que
  cambie **cada** bus y compruebe el dB. Queda para el lote 4.
- Sliders en pantalla (líneas 198-204) → dueño **M53**.

### Hallazgo sobre CI

`run_tests.py --module m91` solo descubre `test-audio_effects_m91.gd`, **no**
`test_audio_config.gd`. La suite base se verifica ejecutándola directamente.
A revisar en el lote 4.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/audio/audio_config_service.gd` (+6 funciones, +6 cabecera)
- `game/isla-ancestral/scripts/audio/test_audio_config.gd` (+test porcentaje, piso 66)
- `DOCUMENTACION/91-Configuracion-De-Audio/plan-actual/05-Checklist.md` (118 → 141 `[x]`)
- `DOCUMENTACION/91-Configuracion-De-Audio/plan-actual/04-Codigo.md` (Notas Lote 2)
- `Logs/NUMEROS_DISPONIBLES.txt` (reserva del número 1194)

## Pendiente (backlog M91)

- **Lote 3:** subtítulos, `ui_sound_manager`, `audio_3d_setup`.
- **Lote 4:** integración M91 ↔ M41/M42/M43, tests de "aplicación al bus"
  por bus, `06-Plan-Testings.md`, revisar descubrimiento de tests en CI,
  cierre de la fila 91 en `CHECKLIST-GLOBAL.md`.
