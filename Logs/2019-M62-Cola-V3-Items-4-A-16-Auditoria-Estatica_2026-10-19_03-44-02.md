# 2019 - M62 - COLA V3 items 4-16: auditoria estatica medida

**Modelo:** DeepSeek-V4.1-Flash (WorkBuddy)
**Fecha:** 2026-10-19 03:44 (GMT-3)
**Modulo:** M62-Memoria (items de integracion M08/M27/M41-M44/M61/M63/M91)
**Encargo:** director GLM-5.3-Flash, msg 319 ("items 4-16 de la cola (estaticos)";
item 2 y 12 -runtime 30 min- SALTEADOS por su orden escrita).

## 1. Alcance y metodo

Los 13 items de la cola se auditaron con tres fuentes independientes:

1. Las suites headless del propio modulo (`scripts/rendimiento/memoria/test_m62_*.gd`),
   corridas 3 veces cada una con la Godot real (`Godot_v4.7.2-stable_win64_console.exe`),
   midiendo EXIT, resumen, conteo de `SCRIPT ERROR` y estabilidad del conteo.
2. Lectura del codigo de produccion de los modulos duenos (M08/M27/M42/M63/M61).
3. Medicion de los artefactos que el item necesita para ser cierto (assets, callers).

Regla aplicada: un `[x]` sin nota de evidencia NO se hereda; se re-mide. Un `[ ]`
no se cierra por lectura: se mide que le falta y con que linea.

## 2. Items 4, 5, 6, 7 y 14: suites existentes, corridas 3x

| Item | Suite | Checks | Corridas | Piso | EXIT | SCRIPT ERROR |
|------|-------|--------|----------|------|------|--------------|
| L141 mallas en hilos | test_m62_hilos_cola_mallas.gd | 33 | 3/3 identicas | 33 | 0 | 0 |
| L142 diffs/ediciones | test_m62_diffs_ediciones.gd | 24 | 3/3 identicas | 24 | 0 | 0 |
| L143 anillo/borde | test_m62_anillo_borde.gd | 24 | 3/3 identicas | 24 | 0 | 0 |
| L149 bancos de audio | test_m62_audio_bioma.gd | 45 | 3/3 identicas | 45 | 0 | 0 |
| L163 sin doble carga | test_m62_sin_duplicacion.gd | 33 | 3/3 identicas | 33 | 0 | 0 |

`CHECKS_MINIMOS` de cada suite coincide EXACTAMENTE con el conteo medido
(33/24/24/45/33): el piso no esta inflado ni flojo. Cero `_check(true` en las 5
(0 aserciones infalsables). Logs crudos: `out/tanda61/<suite>-<1..3>.log`.

Lo que cada suite prueba de verdad (muestras textuales de los checks):

- L141: "SIN COPIAS: el resultado es la MISMA instancia del cache (identidad +
  ruta)", "peso reclamado EXACTAMENTE una vez (delta 4.0)", "control positivo:
  el detector SI ve una copia forzada (2 CACHE_MODE_IGNORE = 2 vivas)". La cola
  es la REAL de StreamManager (M63), no un doble.
- L142: "SIN estructuras de historial por edicion (8 patrones)" sobre
  `res://scripts/tools/tool_controller.gd` (archivo de produccion), mas
  liberacion determinista de 3 payloads (0/3 vivos por WeakRef).
- L143: "el borde se descargo ANTES de cargar: 0/4 vivos del borde y 5/5 del
  interior", "una sola marca NO libera (gracia de 2 frames)", "liberar de nuevo
  es idempotente (0)".
- L149: "NINGUN banco del bioma viejo sobrevive al salir (WeakRef)", veto por
  handshake M63 con `descartes_por_carga`, orden de drenaje por lejania (5,3,1),
  `objetos_vivos` base=4477 fin=4477 (delta 0).
- L163: "el registro NO creo objetos nuevos (la oferta es la MISMA instancia)",
  "re-registrar el mismo chunk 30 veces NO infla la cola del 62", swap con UNA
  sola entrada activa por chunk_id.

## 3. Guardian probado EN ROJO (no heredado)

Inyeccion de un error de runtime (`var _nulo: Node = null; _nulo.get_name()`)
al inicio del bloque B de `test_m62_diffs_ediciones.gd`, sobre una COPIA
temporal (`test_m62_diffs_ediciones_ROJO_TMP.gd`; el original nunca se toco:
sha256 `0689b07d17dbfed3e63559f1778ecb4d338cc765ced8bc88425b1d3e2c5e24e3`
antes y despues).

Resultado medido (out/tanda61/rojo.log):

    SCRIPT ERROR: Cannot call method 'get_name' on a null value.
    [FALL] el bloque B NO se ejecuto (posible SCRIPT ERROR que aborto la funcion)
    [FALL] solo 20 checks ejecutados (minimo medido en verde: 24)
    === Resumen ... 20 checks, 2 fallos ===
    EXIT=1

Dos capas independientes dispararon (marcador de bloque + piso de checks) y el
proceso salio 1. La copia temporal se borro; 0 archivos `ROJO_TMP` en disco.

## 4. Hallazgo A - 10 de las 17 suites de M62 no corren en CI

`ls scripts/rendimiento/memoria/test_*.gd` = **17**. Cableadas en
`.github/workflows/quality.yml` = **7** (test_memoria_m62, test_enforcement_m62,
test_pool_iter2, test_memoria_m62_iter3, test_m62_liberacion,
test_memoria_m62_iter5, test_m62_pureza_save). **NO cableadas = 10**:
hilos_cola_mallas, diffs_ediciones, anillo_borde, audio_bioma, sin_duplicacion,
texturas_region, duro95, leaks_teleport, voxel_buffers, colliders_chunk.

Consecuencia honesta: 5 de los items de esta tanda se apoyan en suites que hoy
solo corren a mano. Si se pudren, ningun gate lo dice. Propuesta al director en
el reporte (quality.yml es NO-TOCAR para mi).

## 5. Hallazgo B - L149: verde de MECANISMO, feed de produccion ausente

`pedir_banco_audio()` e `iniciar_descarga_audio()` estan definidas en
`memory_monitor.gd` (L386/L398) y tienen **0 llamadores de produccion**: el
unico consumidor es la suite. `scripts/audio/ambient_director.gd` (M42) carga
`ambient_biome_bank.json` en un diccionario y NUNCA llama a la API del 62.

Por lo tanto el item tal como esta escrito ("cargados al entrar y descargados al
salir de la region") es cierto en el MECANISMO del 62 y falso de punta a punta en
produccion. Coincide con la deuda ya declarada en la Tanda 60 ("registro de
bancos al viajar M42 - item 112"). Decision pedida: dejar `[x]` con nota de
alcance, o bajar a `[?]` hasta que M42 cablee.

## 6. Items 8, 9, 10 y 11 - bloqueados por ausencia de assets (medido)

- Archivos de audio en TODO `game/isla-ancestral`: **0** `.ogg`, **0** `.wav`,
  **0** `.mp3` (find con `.godot` podado). Solo hay catalogos JSON en
  `data/audio/` (7 archivos).
- API de streaming: **0** apariciones de `AudioStreamOggVorbis`, `AudioStreamMP3`,
  `load_from_file` ni `load_from_buffer` en `scripts/`.
- `.ogg` liberados de cache (L152): no hay ni un `.ogg` que liberar.
- Buses M91 (L153): `audio_config_service.gd` crea buses y fija volumen/mute;
  no existe ninguna logica de retencion/liberacion de streams detenidos.
- Descarga diferida 1 frame del banco anterior (L154): lo que existe es
  `bancos_audio_diferidos()` (diferido hasta TERMINAR la descarga), que es otro
  criterio. No hay diferido de 1 frame para audio.

Veredicto: los 4 quedan `[ ]`, y la causa NO es deuda de codigo del 62 sino
ausencia de assets de M41/M42/M44/M91. El presupuesto de audio de los presets
(150/200/250 MB) es hoy un numero de diseno sin contraparte en disco.

## 7. Item 13 (L159) - presupuestos definitivos de M61: existen y son medibles

`data/performance/budgets.json` (M61, version 2) trae valores definitivos:
`presupuesto_total_ms` 16.7 (categorias suman 16.5), `remesh_bloque_ms_max` 2.0,
`carga_fria_s_max` 30, `carga_caliente_s_max` 10, `lod_niveles` 3,
`npcs_activos_max` 20. Gate propio: `scripts/performance/validate_budget.gd`
(EXIT propio, valida `remesh_bloque_ms_max <= 2.0`).

`data/rendimiento/budgets.json` (M62, version 2) fija los topes duros en MB:
baja 1500 / media 2000 / alta 2500 (sumas verificadas de las 8 categorias).

Correspondencia medida: son unidades distintas (ms vs MB), asi que no hay
conflicto posible; el unico numero de M61 que restringe al 62 es
`remesh_bloque_ms_max` 2.0, y **no lo consume ningun script del 62** (solo el
gate del 61). No existe artefacto que enlace ambos archivos: la lectura no deja
traza. Veredicto propuesto: `[x]` con la tabla de correspondencia como nota, o
`[?]` si el director exige traza automatica. Decision suya.

## 8. Item 15 (L166) - drift-check tras teleport: API si, llamador no

`MemoryMonitor.drift_check()` y `drift_porciento()` existen (memory_monitor.gd
L471/L478, con baseline y senal `drift_detectado`) y estan probados en
`test_memoria_m62_iter3.gd` (bloque E). Callers de produccion: **0** (grep
excluyendo tests y el propio monitor). `island_travel_guard.gd` tiene
`evaluar_viaje()` y `debe_precargar()` pero **0** apariciones de `drift`.

Veredicto: `[ ]` correcto. Lo que falta es exactamente 1 punto de llamada
post-viaje (M69/M28) que consulte `drift_check()` y registre el resultado; el
mecanismo del 62 ya esta listo y probado.

## 9. Item 16 (L180) - preset Baja en isla pequena (M27)

Lo que SI existe en M27:
- `island_ops.gd`: cola de operaciones con prioridad estable
  (`prioridad_por_defecto`, `encolar(tipo, isla, prioridad)`), probada en
  `test_islas_m27_iter2.gd` ("la prioridad pone la carga antes que la precarga").
- `island_travel_guard.debe_precargar(pos, isla_actual, presupuesto)`: ordena
  candidatas por distancia y respeta un tope por parametro.

Lo que NO existe: **0** apariciones de `preset` en `scripts/islas/*.gd`. El tope
de precarga no se deriva del preset activo y no hay descarga agresiva de islas
viajeras (el 62 encola por lejania, pero nadie le pasa el preset).
Veredicto: `[ ]` correcto, con 2 de 3 sub-partes ya implementadas.

## 10. Item 12 (L155, 30 min con clima cambiante) - SALTEADO

Por la misma razon que el item 2 (orden escrita del director en msg 319):
runtime/Play Mode exige corridas que solo habilita el fundador.

## 11. Numeracion

- Log **2019** (`reservar_log.py --reservar`, cabeza medida justo antes = 2019;
  pool quedo en 2020).
- Canal: ultimo mensaje real **319** (del director); pool del canal con cabeza
  **320** = ultimo+1 -> se usa **320** y se deja el pool en **321..420**.

## 12. Limites cumplidos

**0 commits / 0 push / 0 flips / 0 auto-sellos 21.8.** No se toco
`CHECKLIST-GLOBAL.md`, `AGENTS.md`, `project.godot`, `quality.yml`, ni el
`05-Checklist` de ningun modulo (las notas de evidencia se PROPONEN en el
reporte). La unica escritura en `game/` fue una copia temporal para la prueba en
rojo, ya borrada; el original conserva su sha256. `git status` sin cambios
propios en archivos versionados.

## 13. Pedidos al director

1. Cablear en `quality.yml` las 10 suites de M62 que hoy no corren en CI
   (prioridad: las 5 de esta tanda). Es su archivo: no lo toco.
2. L149: decidir `[x]` con nota de alcance ("mecanismo del 62; feed M42 ausente")
   o `[?]`. Y pedir a M42 el cableado de `pedir_banco_audio`.
3. L159: decidir si la tabla de correspondencia M61/M62 alcanza como evidencia
   de lectura o si exige traza automatica.
4. Anotar en la fila M62 del GLOBAL el `[?]` "esperando habilitacion de runs"
   para los items de runtime (2 y 12): el GLOBAL es su archivo.
5. Reponer cola: los items 4-7, 13, 14, 16 quedan medidos; los 8-11 estan
   bloqueados por assets y los 12/2 por runtime. La cola activa se queda sin
   items ejecutables estaticos de M62.

**Modelo:** DeepSeek-V4.1-Flash
