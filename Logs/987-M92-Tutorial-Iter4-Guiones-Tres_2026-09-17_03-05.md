# Log 987: M92 Tutorial — iteración 4 (guiones .tres + hot path + espejo documental)

**Fecha:** 2026-09-17
**Hora:** 03:05
**Modelo:** glm-5.3-flash
**Plataforma:** Cline

## Resumen

Iteración 4 del M92 (Tutorial), continuando tras la iter. 3 (Log 914) de la misma firma.
Módulo liberado 🟡 en **97/185**. Se implementaron los ítems Q5, Q2, Q7, R1, R3, R5 y R6.

## Cambios realizados

### `game/isla-ancestral/scripts/tutorial/tutorial_guiones.gd` (NUEVO)
- Resource `TutorialGuiones` (Q5/T-150) con `@export var capitulos: Dictionary` — patrón
  `weather_config.gd`/`clima_config.tres` (M32). Sin parseo en runtime.

### `game/isla-ancestral/data/tutorial/guiones_base.tres` (NUEVO)
- Los **4 capítulos base** serializados (prologo/interactuar/herramienta/vecino), contenido
  idéntico al que estaba por código. Formato `gd_resource type="Resource" script_class=...`.

### `game/isla-ancestral/scripts/tutorial/tutorial_manager.gd` (extensión, núcleo respetado)
- **Q5:** `_registrar_capitulos_base()` carga `res://data/tutorial/guiones_base.tres`
  (duck-typing `res.get("capitulos")`); si falta o está vacío usa
  `_registrar_capitulos_base_fallback()` (por código, con `push_warning`) — degradación
  grácil, el tutorial nunca arranca roto.
- **Q2/Q7:** en `_process`, la proximidad de mundo SOLO consulta al jugador si
  `_targets_mundo` no está vacío — elimina la alocación de `get_nodes_in_group` cuando no
  hay triggers. Con target registrado la proximidad sigue funcionando (verificado).

### `game/isla-ancestral/scripts/tutorial/test_tutorial_iter4.gd` (NUEVO, 21 checks)
- Carga del `.tres`, contenido completo (4 capítulos, meta/rejugable/guiado/pasos), consumo
  por el manager, hot path con targets vacíos, proximidad lejos (10 m, no dispara) y dentro
  (2 m, dispara).

### Documentación
- `05-Checklist.md`: **97/185** (7 ítems más: Q2/Q5/Q7/R1/R3/R5/R6); Reserva → 🟢 Liberado.
- `03-Diseno.md`: nueva sección **§6 "Estado de implementación (iter. 1-4)"** con la tabla
  de iteraciones (Logs 259/336/911/914/987) y los contratos vivos para M53.
- `04-Codigo.md`: Notas del Agente de la iter. 4 (aditivas) + recomendación Q5 marcada HECHA.
- Tableros: CHECKLIST-GLOBAL (fila 92 → 🟡 97/185), guía 08 (fila de registro),
  ESTADO-PARALELO (fila de tabla + cierre de reserva).

## Verificación (binario real headless, `run_m92_tests.bat`)

| Suite | Checks | Resultado |
|---|---|---|
| test_tutorial (núcleo) | 22 | **0 fallos · EXIT=0** |
| test_tutorial_triggers | 71 | **0 fallos · EXIT=0** |
| test_tutorial_iter3 | 103 | **0 fallos · EXIT=0** |
| test_tutorial_iter4 | 21 | **0 fallos · EXIT=0** |

Nota de transparencia: la primera corrida del iter4 dio 1 fallo por un **error aritmético del
propio test** (908−905 = 3 m, no 8 m: el stub estaba dentro del radio 5). Corregido a 915
(10 m); el manager nunca estuvo roto. Segunda corrida: 4/4 verdes.

## Numeración
- Reserva propia: `Logs/reservas/987-glm-5.3-flash-M92-iter4.txt` (2026-09-17 02:55) →
  consumida aquí. `ULTIMO_NUMERO.txt` estaba en 986 al reservar (paralelo de otros agentes).

## Archivos modificados/creados
- `game/isla-ancestral/scripts/tutorial/tutorial_guiones.gd` (nuevo)
- `game/isla-ancestral/data/tutorial/guiones_base.tres` (nuevo)
- `game/isla-ancestral/scripts/tutorial/tutorial_manager.gd` (extensión)
- `game/isla-ancestral/scripts/tutorial/test_tutorial_iter4.gd` (nuevo)
- `scripts/run_m92_tests.bat` (4ª suite)
- `DOCUMENTACION/92-Tutorial/plan-actual/{05-Checklist,04-Codigo,03-Diseno}.md`
- `CHECKLIST-GLOBAL.md` · `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` ·
  `Mensajes entre modelos/ESTADO-PARALELO.md`
- `DOCUMENTACION/TAREAS-POR-MODELO/glm-5.3-flash/92-Tutorial/checklist.md` (65/173)
- `DOCUMENTACION/TAREAS-POR-MODELO/glm-5.3-flash/BACKLOG-MASTER.md` (fila 92: 76 pendientes)

## Pendientes declarados (honestidad)
- UI de presentación (M53, V2) y Q1 (pool visual de nodos).
- Q8 (medición con profiler en plaza densa — RN4 ≤ 0,2 ms).
- Capítulos didácticos RF11-RF18 y S10-S12 (requieren M13/M33/M34/M35/M16 reales).
- ⏳ QA cruzado §21.8 de M92 (y de M66/M30): verificador ≠ autor.
