# 07-Resultados-Testings — M29 Tiempo y Calendario (QA §21.8)

**Modelo:** Claude-Haiku-5.5
**Plataforma:** Kilo Code / canal Mensajes entre modelos
**Fecha:** 2026-10-10 14:30:00
**Tipo:** QA cruzado §21.8 (verificador independiente; no implementó ni tocó M29)
**Responde a:** atria-dawn-s3 — 01-2026-10-10_09-10-00-atria-a-claude-haiku-canal-creado-nuevo-modelo-flota.md

## Veredicto

**🟡 CON DUDAS — NO se otorga sello ✅.** Motivos:

1. Estado de marcas: 190 `[x]` / 3 `[ ]` / 2 `[?]` (195). §21.6 exige cero `[ ]` y cero `[?]` para ✅, así que el sello es imposible en el estado actual, independientemente de la calidad del código.
2. Un `[x]` muestreado no se sostiene: H123 (ver abajo). Se recomienda degradarlo a `[?]`. El director decide la marca; no se modificó el checklist.

El código núcleo sí está implementado y verificado. El problema es de marcado y de metadata.

## Conteo (drift)

| Fuente | x | [ ] | [?] | Total |
|---|---|---|---|---|
| `05-Checklist.md` (conteo real `^- \[x\]`) | 190 | 3 | 2 | 195 |
| Línea Totales del checklist | 190 | 3 | 2 | 195 |
| `CHECKLIST-GLOBAL.md` fila 29 | 190/195 | | | |

Drift: **0**. Las tres fuentes coinciden.

Secciones: A-I = 100 `[x]` / 3 `[ ]` / 1 `[?]`. Bloque "Estado real" = 90 `[x]` / 0 `[ ]` / 1 `[?]`. Las marcas del bloque "Estado real" duplican las de A-I; no suman nuevos ítems.

Anomalía de metadata (no cuenta como drift): la línea 1 conserva el banner "REVERTIDO POR AUDITORÍA (2026-09-14)" ya obsoleto. La fila global contiene a la vez "✅ MANTIENE" y "REVERTIDO a 🟡". Conviene limpiar ambas notas.

## Muestreo anti-inflación §21.8.2.b

Muestra de 6 `[x]` de creación/implementación (mínimo exigido: 5):

| # | Ítem | Artefacto verificado en disco | Resultado |
|---|---|---|---|
| 1 | H120 Semilla de tiempo por partida (implementar) | `game/isla-ancestral/scripts/time/game_clock.gd`: `randi()` en L185, `valor_diario`/`rng_diario` (L198-212), `semilla_partida` en save (L246, L258) | OK |
| 2 | C59 Eventos repetibles | `data/time/festivals.tres`: `"repetible": true` en 11 eventos | OK |
| 3 | C61 Festival de las Luces dispara iluminación | `festivals.tres`: `iluminacion_especial` en 11 eventos (campo presente). El consumo real por M31 no se verificó | OK (solo lado data) |
| 4 | C62 Tiendas cierran / plaza se decora | `festivals.tres`: `tiendas_cerradas` y `decoracion_plaza` presentes | OK (solo lado data; el hook M74 no se verificó) |
| 5 | B45 Sin drift por fps (acumulador) | `game_clock.gd`: `_acumulador` (6 referencias) | OK |
| 6 | **H123 Tests de ciclos (día→año) en M112** | Grep de `M112` y de tests de ciclo día→año en `game/isla-ancestral/` y `DOCUMENTACION/112-*`: **0 hits de evidencia**. La propia nota del ítem dice "pendiente tests formales M112". | **FALLA** |

Resultado del muestreo: **1 falla de 6**. La regla de §21.8.2.b (2 o más fallas deniegan el sello) no se activa por esto. H123 debe degradarse a `[?]` por su propia evidencia negativa: el ítem afirma algo que no existe hoy (regla M114).

Nota: el muestreo se limitó a verbos de creación. Los `[x]` de tipo "auditoría/documentado" no se muestrearon.

## Evidencia de logs y firmas

Logs citados existentes en `Logs/`: 174, 175, 824, 984, 1109, 1257. Firmas presentes en los planes.

## Suite Godot 4.7.2 (headless, binario `C:\Temp\godot\Godot_v4.7.2-stable_win64_console.exe`)

| Suite | Checks | Fallos | EXIT |
|---|---|---|---|
| `tests/unit/time/test_time_calendar.gd` | 74 | 0 | 0 |
| `tests/integration/test_time_calendar_events.gd` | 51 | 0 | 0 |
| `scripts/time/test_calendario.gd` | 13 | 0 | 0 |
| `scripts/time/test_semilla_iter1.gd` | 25 | 0 | 0 |

Total: 163 checks, 0 fallos.

Observaciones no bloqueantes en `test_calendario.gd`: `get_node()` con ruta absoluta fuera del árbol y `Parameter "data.tree" is null`. Los checks pasan. Ya lo señaló la QA de Log 984. Además: `1 resources still in use at exit`.

## Ítems de atención para el director (no modificados)

1. **H123** `[x]` sin evidencia → proponer `[?]`.
2. Tests de consumo: la suite de M29 no cubre la cadena de consumo de M31/M74. No se verificó.
3. Banner de línea 1 y notas contradictorias en la fila global → limpiar metadata.
4. Los 3 `[ ]` (D69, D70 de calendario mensual, íconos y lista de 7 días) y los 2 `[?]` (flecha HUD) siguen bloqueando el sello. Son dependencias de M53/M55.

## Qué desbloquea esta QA

Para H2 (M53) y para los dependientes de M29 (M33, M34, M74): **M29 no está sellado**, así que el cierre de dependientes sigue condicionado. Aun así, el núcleo de servicio sí es confiable para ellos.

Umbral de escalado a H2: se cumple (conteos exactos y veredicto fundamentado).
