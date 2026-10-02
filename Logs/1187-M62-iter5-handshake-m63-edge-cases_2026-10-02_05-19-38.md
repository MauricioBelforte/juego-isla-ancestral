# Log 1187 -- M62 iter. 5: handshake con M63 + edge cases de la checklist

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-02 05:19
**Modulo:** M62 (Memoria)
**Tipo:** implementacion + suite nueva + cierre parcial de checklist (NO sella QA 21.8)
**Reserva:** numero 1187 (protocolo v3, AGENTS.md 6.1.a)

---

## 1. Que se pidio y que se hizo

Directiva: el modulo M62 me fue **reservado de vuelta** al autor original
(commit `6d8d02b`, 2026-10-02 07:40). El verificador hy3 (Log 1128) dejo M62
**sin sello limpio**: 98 `[x]` / 52 `[ ]` / 0 `[?]`, con la nota de que "el
autor original puede cerrar los 52 `[ ]`". Empezar por M62.

Esta iteracion implementa lo que faltaba del **handshake con M63** (diseno
5.3) y varios edge cases de K que existian solo en prosa, agrega la suite
`test_memoria_m62_iter5.gd` (guardian probado con 5 sondas) y **cierra 9** de
los 52 `[ ]` con evidencia. Los 43 restantes son no-headless y se delegan con
dueno nombrado.

## 2. Estado de partida MEDIDO (no heredado)

`test_memoria_m62_iter3.gd` corrida en vivo: **133 checks, 0 fallos, exit 0**
(coincide exacto con la linea base declarada por el usuario). Se re-midio en
vez de heredar el visto bueno (trampa 119).

## 3. Las 6 suites, x3 cada una (MEDIDO)

Comando: `godot --headless --path game/isla-ancestral --script res://scripts/rendimiento/memoria/<t>.gd`

| suite | checks | fallos | exit | x3 |
|---|---|---|---|---|
| test_memoria_m62 | 27 | 0 | 0 | identicas |
| test_enforcement_m62 | 47 | 0 | 0 | identicas |
| test_pool_iter2 | 25 | 0 | 0 | identicas |
| test_memoria_m62_iter3 | 133 | 0 | 0 | identicas |
| test_m62_liberacion | 15 | 0 | 0 | identicas |
| test_memoria_m62_iter5 (nueva) | 60 | 0 | 0 | identicas |

**Total M62: 307 checks, 0 fallos.** Las 5 suites previas se re-corrieron
DESPUES de tocar `memory_monitor.gd`/`unload_policy.gd`: 247 checks, 0 fallos,
sin regresion.

Nota de contaminacion ajena: el run headless emite 4 `SCRIPT ERROR: Parse
Error` de `res://scripts/interacciones/interaction_manager.gd` (kimi/M70, en
paralelo). NO rompen la suite de M62 (corre completa, 60/0), pero ensucian la
salida. Medido con `grep -v interaction_manager` y confirmado que el resumen de
M62 se imprime igual.

## 4. Handshake con M63 (L157 / L160) -- lo central de la iteracion

Diseno 5.3: el 63 decide que CARGAR, el 62 decide que LIBERAR. Faltaba el
contrato entre ambos.

- `MemoryMonitor.avisar_carga_iniciada(recurso)` / `avisar_carga_terminada()`
  / `esta_en_carga()` / `recursos_en_carga()`.
- `MemoryMonitor._puede_descargar(recurso)` = el filtro del handshake.
- `UnloadPolicy.ejecutar_descarga(hasta_mb, max_por_frame, filtro: Callable)`:
  3.er parametro OPCIONAL (`Callable()` = sin filtro -> compatibilidad total).
  Un candidato vetado **no sale de la cola** y se cuenta en
  `diferidos_ultimo_lote()`.
- `_enforcement()` pasa `_puede_descargar` como filtro: **el 62 NUNCA
  descarga un recurso que el 63 esta cargando**, ni en el nivel 3 (duro).
- Los vetos se cuentan en `descartes_por_carga()`.

## 5. Edge cases de K implementados

- **L167 atlas LRU con log:** `MemoryMonitor.evictar_atlas(entradas, tope)`:
  evicta por uso mas ANTIGUO y registra el evento via `_log_m62()`.
- **L168 region rapida:** `avisar_cambio_region(region)`: si hay candidatos
  pendientes, FUERZA la liberacion (`liberaciones_forzadas()`); la MISMA
  region no cuenta como cambio.
- **L171 audio diferido:** `iniciar_descarga_audio()` / `pedir_banco_audio()`:
  pedido durante una descarga -> diferido (`bancos_audio_diferidos()`), se
  reproduce al terminar.
- **L172/L173 cola de transicion:** `iniciar_transicion_escena()` devuelve
  `false` y ENCOLA el 2.o cambio (`doble_descarga_evitada()`);
  `terminar_transicion_escena()` encadena el encolado;
  `cancelar_transicion_escena()` DRENA la cola (nada colgado).
- **L113/RN9 determinismo:** la decision de nivel y el orden de descarga son
  funcion pura de la entrada.

## 6. Guardian anti-falso-verde probado EN ROJO (5 sondas)

Protocolo del skill 4: copia temporal -> inyeccion -> correr -> borrar. Las 5
sondas dan EXIT 1; el control sin mutar da EXIT 0.

| sonda | inyeccion | medido |
|---|---|---|
| A | asercion falsa | 61 checks, 1 fallos -> EXIT 1 |
| B | `return` al inicio de `_run()` | 7 checks, 8 fallos -> EXIT 1 |
| C | piso +1 (61) | 60 checks, 1 fallos -> EXIT 1 |
| D | `return` al inicio del bloque C | 46 checks, 2 fallos -> EXIT 1 |
| E | `_fin("A")` suprimido | 61 checks, 1 fallos -> EXIT 1 |
| -- | control sin mutar | 60 checks, 0 fallos -> EXIT 0 |

**Exit code REAL del proceso** verificado en la sonda B (la mas importante,
prueba la capa 3): `EXIT REAL = 1`, con los 7
`[FAIL] el bloque X NO se ejecuto` impresos por `_summary()` en su propio
`call_deferred`, aunque `_run()` haya abortado.

Piso `CHECKS_MINIMOS` arranco en placeholder (44) y se fijo en **60 medidos en
verde** tras la 1.a corrida (regla: el piso se mide, no se estima).

## 7. Defecto propio cazado por el propio guardian

La 1.a corrida de la suite fallo: escribi `mm.descastes_por_carga()`
(transposicion) cuando el metodo es `descartes_por_carga()`. El `SCRIPT ERROR`
ABORTO el bloque B y el guardian lo dijo: `[FAIL] el bloque B NO se ejecuto`
-> 58 checks, 1 fallos, EXIT 1. Corregido: 60/0. No hubo "0 fallos" falso.

## 8. Regresion y auditoria

- `auditar_arquitectura_m62.py` (estricto): **0 hallazgos nuevos**, 0
  violaciones B1/B2/B3 en el codigo nuevo; `--selftest` verde.
- `validar_workflows.py` cazo la suite nueva como **no versionada** (trampa 98:
  verde en disco, rojo en CI) -> resuelto al commitearla. Quedan **5
  `DEUDA_CONOCIDA` obsoletas AJENAS** (dueno M64): reportadas, NO tocadas.

## 9. Checklist: 9 items pasan a `[x]` con evidencia

Antes: 98 `[x]` / 52 `[ ]` / 0 `[?]`. Despues: **107 `[x]` / 43 `[ ]` / 0 `[?]`**
(contado por PREFIJO DE LINEA, no `grep -o`).

- **L113** (RN9 determinismo) -- bloque G
- **L157** (handshake 63/62) -- bloque A
- **L160** (nunca descarga lo que el 63 carga) -- bloques A y B
- **L162** (no tocar la carpeta 61) -- `git status` de la iter.: solo
  `scripts/rendimiento/memoria/`
- **L167** (atlas LRU con log) -- bloque F
- **L168** (region rapida -> fuerza liberacion) -- bloque D
- **L171** (audio diferido) -- bloque E
- **L172** (doble cambio de escena) -- bloque C
- **L173** (cancelacion limpia) -- bloque C

## 10. Lo que NO se hizo (honestidad obligatoria)

- **NO cerre los 43 `[ ]` restantes.** Son no-headless por naturaleza: sesiones
  de 30 min (L100/L109/L208), teleport x10 con mundo real (L101/L209),
  baselines de L (L184-L188), e integraciones con internals de otros modulos:
  M08 voxel (L132/L134-L139), M41-M44 audio (L144-L150), M29 (L96), M63/M09
  (L95). Cerrarlos desde aca seria marcar sin medir.
- **NO toque M61** (`scripts/rendimiento/` fuera de `memoria/`): esta en curso
  por otro agente. Por eso **L154** sigue `[ ]`.
- **NO toque `scripts/interacciones/`** (kimi/M70).
- **NO modifique el auditor** para anadir un check de "carpeta 61 intacta":
  decision explicita (el handshake ya esta cubierto por comportamiento en
  iter5; un check de scope no encaja en un auditor de arquitectura).
- **QA cruzado 21.8 sigue pendiente** (verificador != autor) y **sin sello
  limpio**: 43 `[ ]`.

## 11. Archivos

- `game/isla-ancestral/scripts/rendimiento/memoria/memory_monitor.gd` (editado)
- `game/isla-ancestral/scripts/rendimiento/memoria/unload_policy.gd` (editado)
- `game/isla-ancestral/scripts/rendimiento/memoria/test_memoria_m62_iter5.gd` (nuevo)
- `DOCUMENTACION/62-Memoria/plan-actual/04-Codigo.md` (Notas iter. 5)
- `DOCUMENTACION/62-Memoria/plan-actual/05-Checklist.md` (9 marcas + reserva)
- `DOCUMENTACION/62-Memoria/plan-actual/06-Plan-Testings.md`
- `DOCUMENTACION/62-Memoria/plan-actual/07-Resultados-Testings.md`
- `.github/workflows/quality.yml` (gate de la suite nueva)

## 12. Trampas que deja esta iteracion

- **Un guardian de 3 capas se prueba con 5 sondas, no con una.** La sonda B
  (abortar `_run()` entero) es la unica que prueba la capa 3 de verdad: las
  demas pueden pasar con la capa 1 sola.
- **El piso nace placeholder y muere medido.** Un `CHECKS_MINIMOS` copiado
  (44) contra 60 reales habria dejado pasar la perdida de 16 checks.
- **Un typo en el test lo caza el propio guardian.** `descastes` vs
  `descartes` no dio un "0 fallos" silencioso: dio `[FAIL] el bloque B NO se
  ejecuto`. Es la trampa 11/119 al reves: el guardian funciono.
- **La salida headless trae errores AJENOS.** 4 `SCRIPT ERROR` de
  `interaction_manager.gd` (kimi/M70) conviven con un 60/0 de M62. Medir el
  propio modulo exige filtrar la salida, no leer el total crudo.
