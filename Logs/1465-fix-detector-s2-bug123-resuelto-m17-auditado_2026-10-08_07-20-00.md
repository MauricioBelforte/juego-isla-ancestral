# Log 1465: Fix critico del detector (s2 ignorado) · BUG-123 resuelto · M17 auditado y con sello autorizado

**Fecha:** 2026-10-08
**Hora:** 07:20
**Modelo:** Atria-Dawn-Preview (atria-dawn)
**Plataforma:** Kilo Code

## Resumen

Se fixeo el bug del detector de mensajes pendientes que hacía que **los mensajes de s2
(delegado) se clasificaran como lado-director y quedaran ignorados**. Adicionalmente: se
verificó y cerró BUG-123, se aplicó el flip del `[x]` falso de M17 y se autorizó su sello
§21.8 a s2, y se resolvió la colisión de logs 1461.

## 1. FIX CRÍTICO — detector `es_director()`

**Síntoma (reportado por el fundador):** s2 llevaba 3 mensajes (132, 133, 134) sin
respuesta porque el detector los marcaba `[ok] respondido`. **Era el bug latente que tenía
anotado desde la sesión anterior y no había fixeado.**

**Causa:** s2 firma `Atria-Dawn-Preview (atria-dawn-s2)`. En `scripts/verificar_mensajes_pendientes.py`,
`es_director()` (L50-54) excluía delegados con `n.startswith(normalizar(d))` — pero
`normalizar("Atria-Dawn-Preview (atria-dawn-s2)")` = `"atria-dawn-preview(atria-dawn-s2)"`,
que **no empieza** con `"atria-dawn-s2"` (empieza con `"atria"`). Caía entonces a
`startswith("atria")` → **True** → clasificado como lado-director.

**Fix:** exclusión por **contenido**, mismo criterio que `_es_variant_director()`:
`any(normalizar(d) in n for d in DELEGADOS)`. Verificado: el detector ahora marca el
canal de s2 como PENDIENTE y detecta sus mensajes.

**Lección:** el bug ya estaba identificado y documentado en la sesión anterior como "bug
latente restante". No fixearlo a tiempo causó que el delegado más importante del
directorio quedara 4 horas sin respuesta. **Los bugs de detección son prioritarios: lo que
el detector no ve, no existe para el director.**

## 2. BUG-123 — RESUELTO y verificado

agnes-3-flash (msg 101, commit `5f457af`) aplicó el fix:
- `softlock_guard.gd:133` → `inv.get("categoria")` de 1 arg null-safe (antes: `get` de 2
  args sobre Object → SCRIPT ERROR en la rama de recovery rota).
- **Cascada de recovery rota ahora testeada** por primera vez (`test_m66_inv_ruta.gd` +
  `_test_cascada_recovery()`): invariante rota inyectada, `forzar_chequeo` disparado,
  `estado_invalido_detectado` + handler `M66HandlerRegistro` verificados, **sin SCRIPT
  ERROR**.

**Verificación del director:** leí `softlock_guard.gd` L133-141 — el fix es correcto,
null-safe, con comentario explicativo firmado. Suite M66: 0 fallos / 0 ERR / EXIT 0.

**Estado:** marcado `[x] Resuelto` en `DOCUMENTACION/11-BUGS.md`. Queda pendiente la QA
§21.8 fresca de M66 por Hy3 (msg 93) para rehabilitar el sello — ahora con la cascada
testeable, la verificación puede ejercitar el camino que antes era inalcanzable.

## 3. M17 — auditoría DoD de s2 aceptada, flip + sello autorizado

s2 (msg 133) entregó el volumen DoD de M17-Construccion:
- **3 suites en Godot 4.7.2 headless: 368 checks / 0 fallos / EXIT 0** (base 131/0,
  iter2 99/0, iter3 138/0 con stress de 251 piezas).
- **58 de 59 `[x]` respaldados.** Sustancia real: 13 scripts (~2.700 líneas) + 33 recetas
  `.tres` data-driven. Claims especiales verificados en código (LOD 40 m, pooling,
  `navmesh_delta`/`obra_activa` M64, serialización M58, permisos narrativa/agua).
- **1 `[x]` falso:** "La demolición de piezas funcionales libera su contenido".

**Verificación del director del `[x]` falso:** confirmé que
- no existe `build_interaction.gd` (0 archivos),
- `demolir_pieza` en `build_manager.gd` solo devuelve los **materiales** de la receta
  (`_f_devolver.call(devuelto)`), sin lógica de liberación de contenido,
- 0 matches de `liberar|contenido|almacen` en las 3 suites.

**Flip aplicado:** `[x]` → `[?]` con dueño **M18** (es una promesa de integración con M18
no implementada, no un "no hecho"). M17: **59/175 → 58/116/1 = 175**.

**Sello §21.8 AUTORIZADO a s2** (verificador independiente de DeepSeek/Qwen3.8 Max, que
completó el módulo). Que registre el sello en `CHECKLIST-QA-SEALS.md`; el flip ✅ lo hago
yo después.

## 4. Colisión de logs 1461 resuelta

Mi log de push (1461-push-catchup) colisionaba con el log del frente A de mimo (1461).
**Renombré el mío a 1462** — cedo el 1461 a mimo (su reserva fue anterior, 04:05 vs mi
07:00; yo me salté el pool al ser un push automático, excepción de §6.1.a que igual
generó el solapamiento).

## Archivos Modificados/Creados

- `scripts/verificar_mensajes_pendientes.py` — fix `es_director()` (exclusión por contenido)
- `DOCUMENTACION/11-BUGS.md` — BUG-123 marcado resuelto
- `DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md` — 1 `[x]` → `[?]` (dueño M18)
- `CHECKLIST-GLOBAL.md` — fila 17: 58/175 + nota de auditoría + sello autorizado
- `Logs/1461-push-catchup-...` → renombrado `Logs/1462-push-catchup-...`
- Respuestas: agnes #102, s2 #135, s3 #41, mimo #70
