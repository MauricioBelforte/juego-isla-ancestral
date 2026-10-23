# 05 - Aviso Guía de Comunicación: acuse + inicio de frente (M168)

**Modelo:** Hy3
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-03 20:43:02
**Responde a:** 04-2026-10-03_20-35-00-aviso-guia-comunicacion.md

## Acuse de la nueva Guía de Comunicación

Leí `Mensajes entre modelos/GUIA-COMUNICACION.md` y los archivos 01→04 de mi canal. Adopto la regla de oro:

> El informe detallado se escribe en esta carpeta; por el chat, solo se avisa (una línea).

Confirmado además (archivo 03 del director): mis 4 commits del Lote N ya están en `origin/main` (llega­ron con los pushes del director, `ee9914f..f50b3a9` = HEAD `f50b3a9`). No ejecuto `git push`. A partir de ahora: cierro cada ítem con informe completo acá + log reservado + marcas en los 3 lugares, y por el chat una sola línea.

## Frente vigente (de 02 / 03 / 04)
1. **QA 21.8 de M168-Plantilla-De-Isla** — PRIORIDAD.
2. **Re-verify de sellos de agnes**: M129 (sin sello, 108/108) → M100 / M125 / M79 / M132.
3. **Cola P** (no adelantarse): M17 (DeepSeek), M43 (mimo), M37 (kimi), M06 (agnes).

## M168 — lectura inicial del estado (antes de cerrar la QA)
- **Fila 168 (CHECKLIST-GLOBAL):** 🟡 "Con dudas Completado (maqueta)" · 104/104 · Media · responsable agnes-3-flash · 2026-10-03 08:35.
- **Nota en la fila:** "✅ Completado (maqueta 5 docs + MAPA-OBJETOS). Verificado por Hy3 (Log 700, Log 848). ⚠ Sección N (Log 1227, hy3, 2026-10-03): ✅→🟡 Con dudas — declarado 0/104 con estado ✅ era FALSO (0 completados, 104 [ ] de documentación de plantilla); sobre-cierre crítico."
- **Log 1236 (agnes, 08:35):** marcó 0/104 → 104/104; aclara que los 104 ítems son la estructura del template (secciones A–O con campos `[COMPLETAR]`), no trabajo pendiente. Queda 🟡 para QA cruzada, NO ✅ por autorsello.
- **Hallazgo propio (ya registrado en Log 1227 / Sección N):** yo detecté el sobre-cierre crítico que bajó la fila de ✅ a 🟡. El matiz del director (archivo 03) es correcto: los 104 son placeholders de plantilla, así que el veredicto probable es ✅ **como MAQUETA**, no sobre-cierre.
- **Código/tests:** `DOCUMENTACION/168-Plantilla-De-Isla/plan-actual/` contiene solo docs (01-Requerimientos … 05-Checklist, MAPA-OBJETOS). No encontré scripts `*.gd` ni `test_*` de M168 en `game/` → es módulo de documentación/plantilla, sin ejecutable. La DoD §21.8 para este módulo: entrega = docs de plantilla + checklist; los "tests" no aplican (no hay código), pero lo verifico contra la regla 3 (mínimo de checks) del gate.

## Plan de QA §21.8 de M168
1. Leer `05-Checklist.md` de M168 y verificar que los 104 `[x]` corresponden a placeholders de plantilla reales (no sobre-marca).
2. Verificar DoD: docs plan-actual vs entrega; logs (1236); ausencia de código/tests justificada; `[?]` documentados.
3. Decidir: ✅ como MAQUETA (si la estructura de plantilla está completa y los 104 son efectivamente placeholders) o 🟡 con notas si encuentro algo real.
4. Reservar log (siguiente libre, ~1237) al cerrar, editar fila 168 byte-exact (si cambia el veredicto), marcar en los 3 lugares, commitear, y por el chat: `terminé M168 QA §21.8, informe en mi carpeta`.

## Nota de identidad
Mi `IDENTITY.md` inyectado dice "Hy4", pero este chat, tu dirección ("Hy3:"), el historial (Lote M/N) y todo el canal `Mensajes entre modelos/Hy3/` me identifican como **Hy3**. Procedo como Hy3 (rol correcto); señalo el desajuste del entorno por si lo querés corregir. No afecta el trabajo.
