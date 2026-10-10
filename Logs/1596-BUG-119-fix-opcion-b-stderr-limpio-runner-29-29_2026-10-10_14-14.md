# Log 1596: BUG-119 — Opción B aplicada (stderr limpio, runner 29/29) + lección E-26

**Fecha:** 2026-10-10
**Hora:** 14:14
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Aplicada y verificada la **Opción B** autorizada por el director en msg 103: el intento
sincrónico de `IncenseSpawner._ready()` ya no emite `push_warning` (stderr) cuando va a
armarse el reintento — emite `print` (stdout) con la nota "reintento armado"; el fracaso
verdadero lo sigue anunciando el timeout de `_process()` (8 s) como warning. Además
registrada la lección del import cache como **E-26** en `GUIA-GODOT/06-registro-errores.md`.
Sin commits (el director centraliza).

## Cambios Realizados

### 1. Fix Opción B — `game/isla-ancestral/scripts/enchantment/incense_spawner.gd`

- Nuevo flag `_aviso_inicial_diferido` con comentario que documenta el porqué (BUG-119,
  autorización msg 103): el warning de 0 puntos del intento inicial iba a stderr y el éxito
  del retry (~30 ms después, frame 3) a stdout — leyendo solo err del runner parecía fallo
  real en cada boot `--script`.
- `_ready()`: envuelve la llamada sincrónica inicial con el flag (`true` antes / `false`
  después); el armado del reintento queda intacto (`_puntos.is_empty()`).
- `_spawneear()`: si `creados == 0` y el flag está activo → `print(msg + " — reintento armado
  (esperando terreno)")`; si no → `push_warning(msg)` (comportamiento previo para cualquier
  otro fallo, incluido `_on_estacion_cambio` y los reintentos).

**No se tocó** `shaman_npc.gd`: su intento inicial ya es silencioso (solo `push_warning` en
el timeout de 8 s, que debe permanecer warning).

### 2. Lección E-26 — `DOCUMENTACION/GUIA-GODOT/06-registro-errores.md`

- **E-26** (plantilla síntoma/causa/solución/firma): borrar `.godot/imported/` "para simular
  frío" NO regenera el caché en runtime (errores `Cannot open file ... .scn` masivos); hay
  que regenerar con `godot --headless --path game\isla-ancestral --import` (RC 0, 974 archivos
  / ~10 MB; descarta 82 huérfanos) **antes** de medir.
- Título del archivo actualizado a "E-11 a E-26"; fila 06 del `INDICE.md` actualizada.

## Verificación (condición del director: "sin runner, no hay flip")

| Paso | Resultado |
|---|---|
| Sonda `_sonda_bug119.gd` (B1) | RC 0; **0 SCRIPT ERROR**; **0** "0 puntos creados" en err; 1× print "reintento armado"; 1× "6 puntos en montaña"; mismo race frame 2→3 (h=16, chaman 35→17) |
| **Runner completo** `run_tests.gd` | **RC 0 · ÉXITO MEDIDO — 29/29 suites · 1267 tests · 0 fallos** (baseline M3 intacto) |
| stderr del runner | **0 líneas M163** (sin "0 puntos creados"); solo el warning M39 "mercader_viajero sin npc_duenio_id" — **preexistente y ajeno** (ya estaba en runs de M3/BUG-052) |
| stdout del runner | print "reintento armado (esperando terreno)" + "6 puntos en montaña (24 fallas de altura, centro (2320.0, 2300.0))" |

Evidencia: `$env:TEMP/opencode/sonda119_b1_{out,err}.txt`, `runner_bug119b_{out,err}.txt`.

### Flip del 11-BUGS

**NO se tocó** `11-BUGS.md` (READ-ONLY + "sin runner, no hay flip" del director = él
centraliza). El flip propuesto: BUG-119 pasa de "[x] Resuelto 2026-10-08" a resuelto con
**verificación 2026-10-10** (Opción B, runner 29/29, stderr limpio; causa race de 1 frame
documentada en Log 1590/Msg 102).

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/enchantment/incense_spawner.gd` (fix Opción B)
- `DOCUMENTACION/GUIA-GODOT/06-registro-errores.md` (E-26 + título)
- `DOCUMENTACION/GUIA-GODOT/INDICE.md` (fila 06)
- `Logs/NUMEROS_DISPONIBLES.txt` (reserva 1596)

## Siguiente

Informe msg 104 al director. Cola: 3) gate `.gitignore` anidados (baja). Opción A
(posponer spawns hasta `get_height>=0`) queda documentada como mejora de flujo separada.
