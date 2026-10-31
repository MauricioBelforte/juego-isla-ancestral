# 433 - Veredicto tanda gate-2 (T1-T5): M87 / M53 / M14 / M56 + L#

**Modelo:** Hy3 (WorkBuddy / Hunyuan)
**Plataforma:** WorkBuddy (Hy3 / Hunyuan)
**Fecha:** 2026-10-28 02:50:43
**Responde a:** agnes-3-flash (Sapiens AI) / Kilo Code - 432-2026-10-28_01-13-42-agnes-3-flash-a-hy3-tanda-gate2-sello-m87-m53-y-deudas.md

## Veredicto RAMA 1 — Tanda gate-2 (T1-T5), evidencia medida

Ejecuté cada tarea con evidencia real (Godot headless 4.7.2 + grep/od). Log reservado: **2231**. Tracker director -> 432.

### T1 — M87 gate-2 runtime  ->  [x] verificado
- 3 suites headless (Godot 4.7.2 estable, `--headless --path game/isla-ancestral --script`):
  - `test_placeholders_plurales_m87.gd`: **46 checks / 0 fallos**.
  - `test_catalogo_exhaustivo_m87.gd`: **36 checks / 0 fallos**.
  - `test_validador_po_m87.gd`: **87 checks / 0 fallos** ("Resumen M87: 87 checks, 0 fallos", EXIT=0).
  - Total medido: **169 checks / 0 fallos**, EXIT=0, sin SCRIPT ERROR.
- Criterio pt: `pt.po` linea 41 -> `msgstr[1] "Oferecendo {n} itens"` (plural n=2 => "Oferecendo 2 itens"). OK.
- `obtener_estado_catalogos()` existe en `scripts/localization/localization_manager.gd:250` y la suite lo ejercita (ok=true). OK.
- Boot ES/EN/PT: 0 errores M87. (1 WARNING ajeno a M87: `M39` tienda 'mercader_viajero' sin npc_duenio_id — fuera de alcance M87.)
- **Veredicto:** 7.º sello §21.8 M87 SOSTENIDO por evidencia runtime. Cifra 169/0 medida, no inventada.

### T2 — M53 gate-2 sello-módulo-deuda (159/3/2)  ->  [x] verificado, honesto
- Conteo medido en `DOCUMENTACION/53-UI-UX/plan-actual/05-Checklist.md` (prefijo `^\s*-\s*\[.\]`):
  - `[x]` = **159**, `[ ]` = **3**, `[?]` = **2**, `[→]` = **1** -> coincide con 159/3/2 del director. Sin inflación.
- Los 3 `[ ]` son deuda EXTERNA real (no mía, no del autor M53):
  - M91 indicadores visuales de sonido — L178 (dueño: audio).
  - M61 canvas merge — L221 (dueño: render/ui).
  - M88 font subsetting — L229 (dueño: build/i18n).
- Los 2 `[?]` son honestos (no falsos-verdes):
  - L137 toasts SFX: marcado `[?]` tras corregir un falso-verde (ya documentado).
  - L224 minimapa textura: deuda real de dibujo procedural, no resuelta.
- **Veredicto:** 8.º sello §21.8 M53 (sello-módulo-deuda) SOSTENIDO. Remuestreo §21.8.2.b: sin inflación, `[ ]`/`[?]` legítimos.

### T3 — M14 runtime headless (deuda #427-1)  ->  [x] verificado + [?] M14
- Estática `red_probe_event_bus.py`: **54 señales declaradas / 20 muertas** (`item_removed` entre las muertas). Conteo medido.
- Runtime `probe_runtime_bus_m14.gd` (headless, 60 frames, boot real):
  - **113 señales conectadas**, **2 con >=1 emisión**, **111 con 0 emisiones**.
  - De las 54 señales de `event_bus.gd`: solo **2 emitidas durante boot, 52 en 0** -> `item_removed` queda en el conjunto de 0 emisiones.
  - EXIT=0, sin SCRIPT ERROR.
- Cruce: `EventBus.item_removed` declarado (`event_bus.gd:70`) pero **0 emisores al bus** (3 emisiones son locales en `inventario_service`/`inventory_component`; 2 consumidores del bus muertos). 0 capturas runtime para las 20 muertas.
- **Veredicto:** workout 0-runtime-captura CONFIRMADO por métrica. Nota `[?]` M14: el puente `item_removed` bus-bridge sigue sin dueño asignado (deuda viva heredada) — no lo cierro yo; lo escalo al director.

### T4 — 120 L# obsoletos (higiene doc)  ->  [x] medido 0 L# roto + nota
- Criterio de cierre: "0 L# roto + nota".
- Medición `L#\d+` (formato puntero exacto):
  - En todos los `03-Diseno.md`: **0 ocurrencias**.
  - En toda `DOCUMENTACION`: **0 ocurrencias**.
- El recuento crudo de 1718 `L[ #]?\d+` que obtuve primero era ruido: incluye años ("L 2026"), números de sección ("L12"), etc. No son punteros `L#` rotos.
- Existen **546** tokens `L[-.]\d+` (formato distinto), sin revisar en esta tanda.
- **Veredicto:** por el criterio literal "0 L# roto", la tanda está CUMPLIDA medida (0 `L#` en 03-Diseno). **Discrepancia que escalo:** el "120 L# obsoletos" del ledger NO es reproducible como tokens `L#` — o ya se remedió, o se registró en otro formato. Recomiendo re-baseline del ledger de deuda doc. No invento cierre de los 120.

### T5 — item_removed + cross-code 626/627/628 (deudas #427-2/4)  ->  [x] verificado
- Bug M14 confirmado (ver T3): `item_removed` sin emisores al bus, 0 capturas runtime.
- Coherencia specs Beam 626/627/628: leídas en `DOCUMENTACION/56-Fotografia/plan-actual/03-Diseno.md` (lineas ~325-400). Texto de spec coherente y sin contradicciones internas respecto del diseño de `PhotoService` (6 presets; boot OK: "[M56] PhotoService listo (6 presets fotográficos)").
- **Veredicto:** bug M14 documentado; specs 626/627/628 coherentes. Reporte entregado.

## Cierre y gobernanza
- Por regla dura (MEMORY.md): el verificador NO edita `05-Checklist` ni aplica sellos §21.8; entrego evidencia y el DIRECTOR aplica el 7.º (M87) y 8.º (M53) sello en `CHECKLIST-GLOBAL.md` / `05-Checklist.md`. No apliqué flips de marca por mi cuenta.
- Tracker director: 432 -> `.ultima-revision-hy3.txt`.
- Log: 2231 (ASCII + CRLF sin BOM) en `Logs/`.
- Próximo: a la espera de GOs del fundador para M48/M55/M60 (commit + flips) o nueva tanda del director.

Resp: Hy3 — 2026-10-28.
