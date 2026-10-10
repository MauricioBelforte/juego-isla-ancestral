# Log 1536 - M37 Museos y Colecciones - Iter. 4 slice RF2d: versionado del bloque de guardado

**Agente:** DeepSeek-V4.1-Flash (WorkBuddy)
**Fecha:** 2026-10-09 19:56:01 (GMT-3)
**Modulo:** 37-Museos-Y-Colecciones
**Tipo:** implementacion aditiva + test con guardian de 3 capas
**Responde a:** canal 123 (atria-a-deepseek, 2026-10-09 19:17) - eleccion de encargo (opcion 1)

## 1. Premisa del encargo: MEDIDA y CORREGIDA

El director propuso "M37 Museos (RF3 - registro persistente): RF3 es la pieza que falta".
Medido contra la documentacion del modulo:

- `01-Requerimientos.md` L23: **RF3 = "Donacion de peces"** (peces capturados en M34) - NO es persistencia.
  En el 05-Checklist L30 figura `[x]` (glm-5.3-flash 2026-09-01; trucha del catalogo M34 al acuario).
- La persistencia del registro se llama **RF2c** y YA fue entregada por agnes-3-flash el 2026-10-08
  (commit `6e709b8`; `Museum.reconstruir_desde_guardado()` + `test_museo_rf3.gd`; la fila 37 del GLOBAL lo cita).

=> La premisa "RF3 = persistencia, falta" NO cierra: ambas piezas (RF3 y RF2c) ya estan hechas.

## 2. Lo que SI faltaba (persistencia/data): versionado del bloque de guardado

`03-Diseno.md` seccion 8 (L234-235) exige: "Escritura atomica: ... bloque unico" y
"**Versionado del bloque para migraciones futuras** (agregar exposiciones nuevas no rompe guardados)".
El `get_save_data()` del registro NO emitia version y `restore_save_data()` no migraba
(item C.60 `[ ]`; K.169 `[ ]`). Implementado.

## 3. Implementacion (aditiva, sin cambiar el esquema de datos)

`game/isla-ancestral/scripts/museum/collection_registry.gd`:
- `const VERSION_GUARDADO := 1` (v0 = bloque legado sin "version"; v1 = con "version").
- `get_save_data()` incluye `"version": VERSION_GUARDADO`.
- `restore_save_data(data)`: si `version > VERSION_GUARDADO` -> push_warning + `return` SIN cargar
  (no degrada el estado; regla dura M59 "nunca degradar un save mas nuevo"). Si no, migra y carga.
- `migrar_bloque(datos, desde) -> Dictionary`: migra v0->v1 (no-op estructural; normaliza
  `piezas`/`recompensas` ausentes o invalidos). Devuelve copia; NO muta la entrada.

`game/isla-ancestral/scripts/museum/test_museo_rf2d.gd` (NUEVO): guardian de 3 capas
(contador + piso `CHECKS_MINIMOS` MEDIDO + marcadores por bloque + watchdog). 7 bloques A-G.

## 4. Evidencia MEDIDA (Godot 4.7.2 headless, binario _console)

| suite | resultado | EXIT |
|---|---|---|
| test_museo_rf2d (NUEVA) | 28 checks / 0 fallos | 0 (x3) |
| test_museo_rf3 (agnes, RF2c) | 0 fallo(s) | 0 |
| test_museo_rf2 (agnes, RF2b) | 0 fallo(s) | 0 |
| test_museo_rf1 (agnes, RF1/RF5) | 0 fallo(s) | 0 |
| test_museo (glm, iter.3) | 0 fallo(s) | 0 |
| saving/validate_save (M59) | 16 checks / 0 fallos | 0 |
| saving/test_rotate_m59 (M59) | 43 checks / 0 fallos, 9 bloques | 0 |

`--check-only` sobre `collection_registry.gd`: EXIT 0. 0 SCRIPT ERROR en todas las corridas.

Piso `CHECKS_MINIMOS=28`: MEDIDO (la corrida verde real da 28; no estimado).

### Guardian probado EN ROJO (2 inyecciones, scratch gitignored `_wb_rf2d.tmp/`, borrado)
- P1 (piso 28 -> 29): `[FAIL] solo 28 checks ejecutados (minimo 29)` +
  `=== Resumen: 28 checks, 1 fallos ===` + **EXIT 1**.
- P2 (aborto de RUNTIME al cerrar el bloque B: `var _boom: Node = null; _boom.free()`):
  `SCRIPT ERROR: Invalid call. Nonexistent function 'free' in base 'Nil'` +
  `[FAIL] bloque C/D/E/F/G NO se ejecuto` + piso (`9 < 28`) + **EXIT 1**.

## 5. Hallazgo (no tocado): `test_museo_rf3.gd` es un falso-verde estructural

`test_museo_rf3.gd` (agnes) NO tiene contador de checks, ni piso, ni marcadores de bloque; y su
`_check(true, "expo huerfana ignorada sin crash (n2=%d)")` (L48) es **infalsable**. Ademas sus
casos (d)/(e) pasan `piezas_o`/`piezas_m` (un dict de PIEZAS) a `restore_save_data()`, que espera
el BLOQUE `{piezas, recompensas}` -> el camino "huerfana" NO se ejercita (queda en `{}`). Por eso
su "0 fallo(s)" no es evidencia fuerte. **Recomendacion:** endurecerla con el mismo patron
(contador + piso + marcadores). NO la toque (artefacto de agnes; riesgo de colision).

## 6. Drift detectado (NO tocado; lo reconcilia el director)

- `CHECKLIST-GLOBAL.md` fila 37 dice `51/148`; el `05-Checklist.md` real (por PREFIJO de linea) =
  **67 [x] / 0 [?] / 81 [ ] = 148**. Drift de 16.
- El propio `05-Checklist.md` declara `**Totales:** 148 items - Completados: 36` (L253) y una nota
  de auditoria dice `36 [x] / 112 [ ]` (L255-257) -> STALE vs los 67 reales.
- El pool de LOGS `Logs/NUMEROS_DISPONIBLES.txt` arrancaba con **BOM** (`\ufeff1536`): el 1536 era
  invisible a `isdigit()` (trampa 77). La herramienta lo consumio igual y el archivo se autocuro
  (head -> 1537). Reportado; NO toque el pool.

## 7. Numeracion

- Log **1536** (pool GLOBAL; head medido JUSTO antes: `\ufeff1536` con BOM -> consumido 1536; head final 1537).
- Canal **124** (pool DeepSeek; head medido 124).
- Colisiones ajenas 1290/1468: reportadas, NO tocadas.

## 8. Restricciones respetadas

SIN commit / SIN push (el director centraliza). NO se toco `CHECKLIST-GLOBAL.md`, `quality.yml`,
`main_island.gd`, `service_registry.gd`/`bootstrap.gd`, ni el `05-Checklist.md` del modulo (el flip
es del director). NO se toco ningun artefacto de agnes. Scratch `_wb_rf2d.tmp/` borrado.
