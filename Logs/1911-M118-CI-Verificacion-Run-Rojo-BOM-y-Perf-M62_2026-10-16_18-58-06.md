# Log 1911 - M118-CI-CD - Verificacion del run de quality.yml (msg 286)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-16 18:58:06 (GMT-3)
**Modulo:** M118-CI-CD (verificacion pedida por el director, canal msg 286)
**Tipo:** Verificacion / diagnostico. Sin cambios de codigo, sin commits.

## 1. Encargo

El director (GLM-5.3 Flash-Director, msg 286) pidio verificar el estado del run
actual de quality.yml (todo mi lote ya esta en el remoto) y, si esta ROJO,
diagnosticar la capa que falla con punteros exactos. Restricciones del mensaje:
NO reparar capas de WIP ajeno sin orden; NO tocar .tres (M159 cerrado).

## 2. Medicion - gh run list --workflow=quality.yml --limit 8

8 runs consecutivos, TODOS failure. Duraciones 7m51s - 9m50s (el workflow CORRE,
no esta rechazado). Run mas reciente = HEAD actual 2a943a3:
  run 38971317017 - failure - 8m1s - 2026-10-16T21:43:49Z

## 3. Jobs del run 38971317017: 12 jobs, 9 VERDES / 3 ROJOS

  VERDES: GDScript Linter | Legal Tooling (M127) | Binary magic bytes (BUG-042)
          | Basic Security Scan | GDScript Formatting | Protocolo y Workflows
          | Log numbering protocol (v3) | Architecture Guard (M62) | Release Gate (M151)
  ROJOS:  (a) Run Test Suite (M112 Integration) - step 'Run validation tests' (7m12s)
          (b) UTF-8 sin BOM (AGENTS 28)        - step 'Verify no UTF-8 BOM' (17s)
          (c) Quality Gate Summary             - consecuencia de (a) y (b)

## 4. Causa raiz (a): M62 liberacion - umbral de rendimiento absoluto excedido

Un UNICO test falla en todo el job (todos los demas: 0 fallos):
  === Resumen M62 liberacion: 15 checks, 1 fallos ===
  TEST M62 liberacion FALLIDO - salida con codigo 1
  [FALLO] L191: el pico de liberacion por objeto esta bajo 3.50 ms (variante pesada)
          << pico=3.801 ms

Script: game/isla-ancestral/scripts/rendimiento/memoria/test_m62_liberacion.gd
  L47   const LIMITE_PICO_MS := 3.5
  L39   comentario: umbral ajustado 3.00 -> 3.50 ms por decision del fundador
        (Log 1368) JUSTAMENTE por ruido del runner de CI (contenedor compartido).
Gate: .github/workflows/quality.yml L518
  godot --headless --script scripts/rendimiento/memoria/test_m62_liberacion.gd 2>&1 || FAIL=1

MEDICION LOCAL (Godot 4.7.2 headless real, 3 corridas):
  pico pesado = 0.368 / 0.443 / 0.399 ms  ->  15 checks, 0 fallos, EXIT 0 (x3)
  (limite 3.50 ms; margen local ~8x - 9.5x)
CI (run 38971317017): pico pesado = 3.801 ms  (10.3x el local)

CONCLUSION: NO es degradacion de codigo. Es varianza del runner de CI. El
baseline local es estable y ~9x por debajo del limite. La asercion es de
rendimiento ABSOLUTO y por eso es intrinsecamente flaky en CI (trampa 120: una
cifra sin su condicion de medicion no es una cifra).

## 5. Causa raiz (b): 8 archivos versionados con BOM

  Archivos con BOM: 8   (los 8 bajo 'Mensajes entre modelos/')
    DS-V4.1-Flash-Opencode/13-...-acuse-m112-ok.md
    DeepSeek-V4.1-Flash/278-...-incidente-perdonado-m38-autorizado.md
    DeepSeek-V4.1-Flash/282-...-hallazgo-b-aceptado-cierre-jornada.md
    Hy3/237-...-t19-falso-positivo-cola-libre.md
    Hy3/239-...-nueva-cola-qa-m76-m55-m21.md
    Hy3/245-...-lote1-flips-sello-lote2-proximo.md
    Step-5-WorkBuddy/63-...-alerta-gd-borradas-recuperacion.md
    agnes-3-flash/669-...-captura-v2-m49-primero.md

Los 8 son MENSAJES DEL DIRECTOR (firma glm-5.3-flash-director) repartidos en 5
canales. NO es una capa de codigo: es el tooling del director escribiendo BOM en
los mensajes de canal. El job usa fail-fast: al fallar el step de BOM quedan
SKIPPED los 3 steps posteriores (duplicate funcs, mojibake selftest, mojibake scan).

## 6. Hallazgos secundarios (NO bloquean el job, pero son falso-verde)

Dos SCRIPT ERROR de RUNTIME que ABORTAN una funcion de test sin marcar fallo
(el resumen igual dice 0 fallos -> falso verde, trampas 11/63/85):
  - res://scripts/logros/test_logros.gd:291 (_test_guardado_carga_rf9_rn8)
      SCRIPT ERROR: Invalid call. Nonexistent function 'size' in base 'Callable'.
      -> la suite publica '=== TEST M72 LOGROS: 0 fallo(s) ==='
  - res://scripts/ia_npc/test_rendimiento_m64.gd:64 (_bloque_a_budget)
      SCRIPT ERROR: Invalid call. Nonexistent function 'register' in base 'Node (NPCWatchdog)'.
      -> aborta el bloque A sin marcar fallo.

## 7. Acciones tomadas

  - 0 cambios de codigo. 0 commits. 0 push.
  - 0 ediciones a CHECKLIST-GLOBAL.md / quality.yml / AGENTS.md / project.godot
    / 05-Checklist de modulos. 0 flips. 0 auto-sellos 21.8.
  - Log 1911 reservado (pool head medido = 1911 == ultimo 1910 + 1).
  - Mensaje 288 al director con el diagnostico.

## 8. Pedido al director (decision, no ejecucion)

  (a) M62 L191: la capa roja NO es codigo mio degradado, es un umbral ABSOLUTO
      contra varianza de CI. Opciones: (1) volver el check a ORDEN/RATIO contra
      una constante medida en la misma corrida (patron T-D8, Log 1323) en vez de
      un limite absoluto; (2) subir el umbral otra vez (ya se subio 3.00->3.50 en
      Log 1368); (3) sacarlo del gate duro y reportarlo. NO lo toco sin orden: la
      trampa 81/88 prohibe ajustar un umbral para tapar un fallo.
  (b) BOM: los 8 archivos son MENSAJES DEL DIRECTOR. Fix de raiz = su tooling
      (UTF-8 sin BOM). Parche posible: python scripts/verificar_bom.py --fix
      'Mensajes entre modelos', pero toca 5 canales ajenos -> NO sin orden.
  (c) Los 2 SCRIPT ERROR de falso-verde (M72 logros, M64 rendimiento) son deuda
      de guardas anti-falso-verde (piso de checks + _summary diferido) en suites ajenas.

## 9. Limites

  Sin commits ni push. Worktree COMPARTIDO: git status mostraba 7 rutas ajenas
  (05-Checklist de M46, tracker de agnes, 3 locales + 3 .po/.json) - no tocadas.
