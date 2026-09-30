# Log 1178: BUG-081 - 4 errores de inferencia de tipos en scripts/legal + test M131 en verde

**Fecha:** 2026-09-30
**Hora:** 04:24
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Reserva:** primer libre verificado en disco = **1178** (pool incluido en este mismo commit, ← del coordinador).

## Resumen

Se cerro **BUG-081** (registrado por atria-dawn en `026f15f`, hallazgo original de mimo-v2.5
durante el cierre del bucket P-48): los **4 errores de inferencia de tipos** de
`scripts/legal/` quedaron corregidos y `test_credits_m131.gd` paso de **FAIL** a **OK**.
Ademas se detecto y corrigio un **quinto defecto** que el reporte original no contemplaba:
una asercion de conteo magico en el propio test (mismo patron que T-104/M150).

Mediciones, antes y despues:

| Escenario | Antes | Despues |
|---|---|---|
| `run_tests.py --module m131` | 2 OK, **1 FAIL** (`test_credits_m131`), exit=1 | **3 OK, 0 FAIL**, exit=0 |
| `test_credits_m131.gd` directo | 8 checks, **1 fallo** (`[FAIL] 3 secciones size=7`) | 8 checks, **0 fallos** |
| `run_tests.py --module m84` | 1 OK, 0 FAIL (sin regresion) | 1 OK, 0 FAIL, exit=0 |
| `--check-only` sobre los 4 scripts | 4 con error | **4/4 OK** |

## Cambios Realizados

### 1. `credits_manager.gd` — el contrato declarado era falso (no solo el retorno)

`obtener_assets_terceros()` declaraba `-> Array[Dictionary]` y hacia
`return sec.get("entradas", [])`.

**Hallazgo propio (va mas alla del reporte):** inspeccionando `data/legal/creditos.json`
se vio que `assets_terceros.entradas` son **Strings** (`"Font Awesome (CC BY 4.0)"`,
`"Kenney.nl Assets (CC0)"`, `"OpenGameArt Contributors"`), no Dictionaries. Por lo tanto
el arreglo "obvio" (mantener `Array[Dictionary]` y filtrar con `is Dictionary`) habria
**devuelto un Array vacio en silencio**: peor que el bug original y pasaria cualquier
test que solo cheque `assets is Array` (el unico consumidor, `test_credits_m131_v2.gd:112`).

Se cambio el contrato a `-> Array[String]`, construyendo `var result: Array[String] = []`
con `result.append(String(entrada))`, replicando el estilo de la funcion hermana
`obtener_contribuyentes() -> Array[String]` (L216-223) y alineado con el stub del
`plan-actual/04-Codigo.md` de M131, que declara `func obtener_assets_terceros() -> Array`.

### 2-4. Tres `:=` sobre Variant → anotacion explicita `: String`

- `audio_credit.gd:50` — `var rol_texto := AudioRole.keys()[rol].capitalize()`
- `audio_credits_generator.gd:33` — `var rol_key := AudioCredit.AudioRole.keys()[cred.rol]`
- `audio_credits_generator.gd:98` — `var tipo_key := AudioLicense.AudioType.keys()[lic.audio_type]`

`.keys()` devuelve `Array` y su indexado produce `Variant`, asi que `:=` no infiere
(leccion §28 de `GUIA-GODOT/01-gdscript-errores-comunes.md`). Se resolvio con anotacion
de tipo explicita `: String`, no con `:=`.

### 5. `test_credits_m131.gd` — conteo magico (familia T-104, fuera del reporte original)

L46: `_check("3 secciones", data.get("secciones", []).size() == 3, ...)` pero el catalogo
tiene **7 secciones** (`desarrollo`, `musica`, `arte`, `qa`, `comunidad`, `agradecimientos`,
`assets_terceros`) desde el commit `b8bd39f` (2026-09-02), mientras que el test entro en
`9450f6a` el mismo dia con `== 3`. O sea: el test viene en rojo desde entonces.

Se cambio a `>= 3` con comentario que documenta el porque, aplicando la **prevencion #2**
que el propio registro de errores exige para T-104: *"si hace falta un conteo, `>= N`
(piso) documentando por que es el contrato real"*. Es exactamente la misma familia de
regresion que ya se corrigio en `test_narrative_m150.gd` en la ronda 2 de P-48.

**Protocolo T-104 aplicado:** la suite se corrio **ANTES** de tocar nada (baseline
2 OK / 1 FAIL) y **DESPUES** de los cambios (3 OK / 0 FAIL), de modo que la atribucion
del rojo queda visible en este mismo log.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/legal/credits_manager.gd` (contracto del retorno)
- `game/isla-ancestral/scripts/legal/audio_credit.gd` (L50)
- `game/isla-ancestral/scripts/legal/audio_credits_generator.gd` (L33, L98)
- `game/isla-ancestral/scripts/legal/test_credits_m131.gd` (L46)
- `DOCUMENTACION/11-BUGS.md` (BUG-081: tabla L147 + detalle → Resuelto + firma)
- `DOCUMENTACION/84-Musica-Y-Audio-Legal/plan-actual/04-Codigo.md` (nota de reapertura)
- `DOCUMENTACION/131-Creditos/plan-actual/05-Checklist.md`
- `CHECKLIST-GLOBAL.md` (fila M131)
- `DOCUMENTACION/TAREAS-POR-MODELO/mimo-v2.6-flash-free/BACKLOG-MASTER.md`
- `Logs/NUMEROS_DISPONIBLES.txt` (1178 consumido)

**Commits de codigo:** `6b7fdf1` (4 errores de inferencia, 3 archivos) ·
`d0c9603` (conteo magico del test, 1 archivo).

## Notas para el proximo agente

- **M84 sigue siendo `✅` sellado.** Este cambio es un bugfix sobre un modulo cerrado,
  no un reabrimiento de desarrollo: no se lo debe marcar como `✅` nuevo ni resetear
  su progreso. La nota de reapertura quedo en su `plan-actual/04-Codigo.md`.
- `obtener_assets_terceros()` cambio de `Array[Dictionary]` a `Array[String]`. Si algun
  codigo futuro esperaba diccionarios, tendra que adaptarse: los datos son strings.
- El test `test_credits_m131.gd` pertenece a `deepseek-v4-flash` (header del archivo),
  pero M131 esta asignado a este chat; se corrigio por cercania con el modulo.
