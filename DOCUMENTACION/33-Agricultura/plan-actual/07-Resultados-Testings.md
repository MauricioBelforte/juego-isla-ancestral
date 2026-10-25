# 07-Resultados-Testings.md — Módulo 33: Agricultura

**Modelo:** Step-5-WorkBuddy (último modificador; corridas previas por Deepseek V4 Flash, atria y G-5.3-Flash-Agente)
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-25

## Segunda corrida medida el 2026-10-25 (Step-5-WorkBuddy, Log 2182) — features propias

Binario real: `Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral`.
Nada heredado: las 6 suites se corrieron HOY por este agente (5 previas reverificadas
sin regresión tras tocar `farm_service.gd` + 1 nueva).

| Suite | Checks | Fallos | EXIT | SCRIPT ERROR | Piso |
|---|---|---|---|---|---|
| `test_farm.gd` | 29 | 0 | 0 | 0 | 29 |
| `test_farm_clima.gd` | 20 | 0 | 0 | 0 | 20 |
| `test_farm_m33_lote.gd` | 42 | 0 | 0 | 0 | 30 |
| `test_farm_voxel_m33.gd` | 27 | 0 | 0 | 0 | 20 |
| `qa_farm_pausas_m33.gd` | 35 | 0 | 0 | 0 | 17 |
| `test_farm_features_m33.gd` (nueva) | 39 | 0 | 0 | 0 | 39 |
| **Total** | **192** | **0** | **0** | **0** | — |

### Verificación del guardián de la suite nueva (sonda por inyección)

Sobre `test_farm_features_m33.gd`:

- Piso 40 (no medido) sobre 39 checks reales: EXIT 1 → el piso se ajustó a 39 MEDIDO.
- Inyección de contenido: `TABLA_CRUCES` vaciada en `farm_service.gd` → EXIT 1,
  3 fallos («tulipán + lavanda -> lirio_estelar ()», «las flores padres se consumen»,
  «25 cruces idénticos»). Sonda borrada; servicio restaurado byte-exacto.
- Trampa evitada: el test de fuente de L188 usa `_solo_codigo()` (elimina
  comentarios respetando cadenas) para no acusarse a sí mismo.

## Resultados medidos el 2026-10-25 (Step-5-WorkBuddy, Log 2180)

Binario real: `Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral`.
Nada heredado: las 5 suites se corrieron HOY por este agente.

| Suite | Checks | Fallos | EXIT | SCRIPT ERROR | Piso |
|---|---|---|---|---|---|
| `test_farm.gd` | 29 | 0 | 0 | 0 | 29 |
| `test_farm_clima.gd` | 20 | 0 | 0 | 0 | 20 |
| `test_farm_m33_lote.gd` | 42 | 0 | 0 | 0 | 30 |
| `test_farm_voxel_m33.gd` | 27 | 0 | 0 | 0 | 20 |
| `qa_farm_pausas_m33.gd` | 35 | 0 | 0 | 0 | 17 |
| **Total** | **153** | **0** | **0** | **0** | — |

### Verificación del guardián (sonda por inyección de runtime)

Sobre `test_farm_m33_lote.gd`, abort inyectado al inicio de `_test_determinismo`
(`var _boom: Dictionary = _farm`, subscript dinámico Variant→Dictionary):

- CON piso 30: EXIT 1, 27 checks, «[FAIL] solo 27 checks ejecutados (mínimo 30)», 1 fallo.
- SIN piso (piso puesto a 0): EXIT 0, 27 checks, 0 fallos → falso verde.
- Sonda borrada; suite restaurada byte-exacta (`git status` limpio en `scripts/farm/`).

## Flips habilitados por esta corrida (05-Checklist, 2026-10-25)

Con la evidencia de arriba se marcaron `[x]` (10 ítems, ofrecidos a revertir):

- L164 pisoteo NPC (bloque `_test_pisoteo_npc` + `shake()` en crop_tile_visual.gd L42).
- L220 determinismo guardado/recarga (bloque `_test_determinismo`).
- L222 4 estaciones con ventana parcial (bloque `_test_4_estaciones`).
- L224 30 días sin agua (bloque `_test_30_dias_sin_agua`).
- L229 inventario lleno al cosechar (bloque `_test_inventario_lleno`).
- L236 5 alternativas descartadas (02-Analisis §4).
- L240 prototipo 3 cultivos + riego + avance diario (02-Analisis §5 + test_farm.gd).
- L242/L244/L246 docs creados y firmados (01/02/03/04/05 verificados; 03-Diseno reparado).

M33 queda en **133 [x] / 22 [ ] / 0 [?] = 155** (prefijo de línea) tras los 6 flips
de la corrida 2 (P11/P13/P15/P23/P24 + L188), todos con cita a la suite nueva
`test_farm_features_m33.gd` (39/0) y al catálogo `data/balance/farming.json`
(schema_version 2).

## Regresiones medidas en la misma corrida

Sin regresión: las 5 suites del módulo cubren el riel farm completo
(ciclo, clima, lote, voxel M08, pausas) y todas quedaron en verde.
