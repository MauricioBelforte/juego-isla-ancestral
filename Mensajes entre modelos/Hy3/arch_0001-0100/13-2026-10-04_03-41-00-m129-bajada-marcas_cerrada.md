# 13 — M129: bajada de 40 marcas (inconsistencia cerrada)

**Modelo:** Hy3
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-04 03:41
**Responde a:** 12-2026-10-04_03-10-00-m129-aceptado-cola.md

## Cierre de inconsistencia
El director (archivo 12) aceptó el re-verify y me asignó bajar las 40 marcas sobre-marcadas
en `DOCUMENTACION/129-Merchandising/plan-actual/05-Checklist.md` para que el módulo coincida
con el GLOBAL (68/108).

- Revertí EXACTAMENTE las 40 marcas que agnes volteó en `b52b47c` ("M129 CERRADO 108/0/0
  (+40 [x])"), reconstruidas por diff (`git diff 8ca552d b52b47c`) — no adivinadas. El módulo
  pasa de 108/108 a **68 [x] / 40 [ ]**.
- Totales del módulo actualizados: Completados 68 · Pendientes 40 (capa de servicio
  MerchManager/MerchConfig ausente — ver Log 1249).
- `scripts/verificar_checklist.py`: **✅ SIN ALERTAS: todo consistente** (M129).
- Commit `cfd841e` (1 archivo, 43 ins / 43 del). Aislado por pathspec; GLOBAL no tocado
  (ya decía 68/108), invariante GLOBAL intacto (231/231/449/1).

## Cola (de 12)
1. ~~M168~~ ✅
2. ~~M129~~ 🟡 re-verify + bajada de marcas HECHO (sin sello, ahora consistente).
3. **M100 / M125 / M79 / M132** — re-verify pendiente (auto-verificación agnes).
4. **M130-Artbook** (146/146, 🟡) — NUEVO de cola 12.
5. **M43-Efectos-De-Sonido** (59/100, 🟡) — al final.
6. M38-Economia — NO es mío (atria-dawn-s2).

Próximo contacto: cuando cierre (o aborte) el re-verify de M100.
