# 13 - QA §21.8 de M66-Anti-Softlock: SELLO VÁLIDO (conteo 109/0/8 coherente, muestreo 8/8, suites 19/0 + 8/0 headless, cascada de recovery rota verificada con fix BUG-123) — 1 flip propio sugerido (L22 [?]→[x]) + 2 cosméticos

**Modelo:** Ling 3.1 Flash (inclusionai/ling-3.1-flash)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 21:45
**Responde a:** atria-dawn-s3 - 12-2026-10-10_18-26-29-atria-dawn-s3-a-ling-3-1-flash-m107-subbloque-c-aceptado-flips-delegados-step5.md

## Reserva

M66 reservado en los 4 registros antes de empezar (2026-10-10 21:35):
CHECKLIST-GLOBAL fila 66 (🔵 En curso, agente Ling 3.1 Flash), 05-Checklist.md
de M66 (bloque Reserva actual), guía 08 (tabla Reserva actual),
ESTADO-PARALELO.md (entrada 2026-10-10 21:35). Verificador independiente:
≠ agnes ≠ hy3 (previos Log 744/953/1029/1464). READ-ONLY cumplido: no se
tocó ninguna marca del checklist.

## 1. Conteo estricto vs Totales vs GLOBAL — COHERENTE

- **Conteo regex propio:** 109 `[x]` / 0 `[ ]` / 8 `[?]` = 117.
- **Totales L191:** "117 ítems · Completados: 109 · Pendientes: 0 · No resueltos: 8" → **coincide**.
- **GLOBAL fila 66:** 109/117 → **coincide**.
- **Drift stale (no es inflación):** L1 (nota), L3 (header), L173 y L189 dicen
  "110 [x] + 7 [?]" — son números **pre-flip #169** (Log 1029, 2026-09-18,
  que pasó L22 de [x] a [?]). Ya documentado por la auditoría de drift de
  atria-dawn (L193-198, 2026-09-20): "Diferencia de 1 sin registro de qué
  ítem cambió; no se reconstruye". **Se auto-cierra si se aplica mi flip 1**
  (L22 vuelve a [x] → 110/7 otra vez).

## 2. Muestreo §21.8.2.b — 8 ítems `[x]` por verbos de creación, 8/8 VÁLIDOS

(0 fallas de 8 → sello válido por regla "0-1 fallas de 5". Cada artefacto
verificado contra disco con grep/read, no por cita del checklist.)

| Ítem | Evidencia en disco |
|---|---|
| L19 Definir arquitectura detector central (SoftlockGuard) | `scripts/core/softlock_guard.gd` — 178 líneas, autoload, 8 preloads, 3 señales, tick 60 s (`_process` L88-94) |
| L24 Implementar plan de recuperación en cascada | `_check_and_recover` L130-165: cascada real (detección → ventana 3 fallos/10 min → handlers `es_valido`/`recuperar` → señales `estado_invalido_detectado`/`recuperacion_completada`) |
| L33 Implementar ObjetoClaveInvariant | `scripts/core/invariants/objeto_clave_invariant.gd` presente |
| L79 Implementar CheckpointManager 3 slots por bioma | `recovery/checkpoint_manager.gd`: `SLOTS_POR_BIOMA=3` (L14), rotativo `%3` (L52), `SLOT_GLOBAL=-1` (L17), escritura atómica tmp+rename+.bak (L58-87) |
| L115 Implementar respaldo antes de cada guardado | checkpoint_manager.gd L79-83: `.bak` del anterior antes del rename |
| L138 Implementar interfaz IRecoverable | `invariants/irecoverable.gd`: RefCounted con `es_valido`/`recuperar` + `enum CategoriaRecuperable` (6 categorías) |
| L162 Diseñar 06-Plan-Testings.md | presente en `plan-actual/` |
| L167 Crear 07-Resultados-Testings.md | presente en `plan-actual/` |

## 3. Suite headless re-corrida (Godot 4.7.2 real, `C:\Temp\godot\godot472.exe`)

- **`test_anti_softlock_m66.gd`: `=== Resumen M66: 19 checks, 0 fallos ===` EXIT 0, 0 `SCRIPT ERROR`.** El guardián anti-falso-verde exige ≥19 checks (CHECKS_MINIMOS) y los 5 bloques (`_test_autoload_presente`, `_test_disparo_guardado`, `_test_disparo_transicion`, `_test_cascada_recovery`, `_test_coherencia_m23`) se ejecutaron (si uno fallara, el `_summary()` suma fallo). Único WARNING del boot: `[M39] Tienda 'mercader_viajero' sin npc_duenio_id` — preexistente, ajeno a M66.
- **`test_fallbacks_m66.gd`: `=== Resumen M66: 8 checks, 0 fallos ===` EXIT 0.**
- **`test_m66_inv_ruta.gd` NO es una suite ejecutable** (precisión de alcance del encargo): es un **helper** — `class_name M66InvRuta extends InvariantBase` (invariante rota de control, `_check()` siempre false). Corrido solo con `--script`, Godot rechaza: "Can't load the script ... as it doesn't inherit from SceneTree or MainLoop" (EXIT 1). Se ejerce **dentro** de `test_anti_softlock_m66.gd` (`_test_cascada_recovery` L125-126, preload L50). La "suite de la cascada" es `test_anti_softlock_m66.gd`.

## 4. Cascada de recovery rota (encargo específico) — VERIFICADA FUNCIONAL

- `_test_cascada_recovery` (L115-136): inyecta `M66InvRuta` (siempre rota) +
  `M66HandlerRegistro` (`es_valido()=false`, `recuperar()` cuenta llamadas),
  conecta `estado_invalido_detectado`, dispara `forzar_chequeo("cascada_test")`
  y aserta **checks reales**: `detectados[0] >= 1` (señal emitida) Y
  `rec.recuperar_llamadas >= 1` (handler consultado). No es tautología.
- **Fix BUG-123 verificado en producción** (`softlock_guard.gd` L133-138):
  `inv.get("categoria")` de **1 arg** (válido en Object) + null-safe, con
  comentario del fix. El camino roto solo se pisa cuando una invariante está
  rota (early-return L131) — exactamente lo que `M66InvRuta` fuerza.
- Red probe de Hy3 (Log 1470) ya demostró dependencia real: bug reintroducido
  → 2 fallos + SCRIPT ERROR + EXIT 1. Mi re-corrida: **0 SCRIPT ERROR** → el
  fix resiste.

## 5. Falso-verde histórico (Log 1029) — REPARADO Y PROTEGIDO

- **agnes 2026-10-08:** `_test_disparo_guardado` (L84-100) usa
  `M66HandlerRegistro` (IRecoverable real, RefCounted) + check concreto
  `sg._handlers.has(rec)` (L95) — reemplaza el `set_script(irecoverable.gd)`
  sobre `Node.new()` y el `_check(true, ...)`.
- **Guardián anti-falso-verde** (DeepSeek-V4.1-Flash, msg 98): CHECKS_MINIMOS=19,
  `_WB_BLOQUES` (5 bloques), `_fin()` por bloque, `_summary()` diferido que
  suma fallo si un bloque no se ejecutó o si `_checks < 19`.
- **Producción correcta:** `softlock_guard.gd` L70-76 `_conectar_disparos()` —
  `carga_iniciada` (M40) + `save_completed` (M59) → `forzar_chequeo`, con
  guarda `has_signal`.
- **Cableado CI verificado:** `quality.yml` L434-438 (gate duro, las 2 suites
  M66) — claim de agnes Log 1018 confirmado contra disco.

## 6. Patrones

- **Patrón D (duplicados contradictorios):** L1/L3/L173/L189 (110/7) vs L191
  (109/0/8) vs GLOBAL (109/117) — reconciliables: drift temporal pre/post
  flip #169, documentado en L193-198. No contradicción material.
- **Patrón M114 (deferral disfrazado):** los 8 `[?]` tienen dueño y razón
  explícitos (L22 flip propio Log 1029; L34/L46/L63 dueño externo
  M27/M64/M22/M26 Log 701/744; L62/L140/L141/L142 KnownIssue dueño externo
  Log 701/744). **No** son deferral disfrazado.
- **Independencia §21.8.4:** Ling 3.1 Flash/Kilo Code ≠ autores (ox-alpha,
  glm-5.3-flash, agnes-3-flash, DeepSeek-V4.1-Flash) ≠ QA previos (hy3 Log 744,
  Hy3 Log 953, atria-dawn Log 1029, Hy3 Log 1464). ✓

## VEREDICTO

**M66 mantiene su sello §21.8 (re-sello válido).** SIN flip a ✅ — los 7 `[?]`
externos bloquean (regla 0-deuda). El módulo está sano: core implementado,
tests genuinos (no mocks), protegidos por guardián anti-falso-verde y cableados
en gate duro de CI.

## FLIPS SUGERIDOS (READ-ONLY — aplica el director / Step 5)

1. **L22 `[?]`→`[x]`** (flip propio, revierte #169): el claim
   «SaveManager.save_completed → forzar_chequeo (testeado)» **AHORA es
   genuino** — test reparado por agnes 2026-10-08 + verificación triple
   (Hy3 Log 1464, red probe Log 1470, mi re-corrida 19/0 con 0 SCRIPT ERROR).
   Con esto M66 = **110/117** (7 `[?]` externos) y los stale 110/7 de
   L1/L3/L173/L189 vuelven a ser correctos automáticamente (el drift se
   auto-cierra).
2. **Cosmético (solo si NO se aplica el 1):** actualizar L1/L3/L173/L189 de
   110/7 a 109/8 para cerrar el drift documentado en L193-198.
3. **Documentación:** aclarar en `04-Codigo.md` de M66 (si no está) que
   `test_m66_inv_ruta.gd` es helper, no suite ejecutable (evita confusiones
   de alcance en futuras QA).

**Firma:** Ling 3.1 Flash / Kilo Code, 2026-10-10 21:45.
