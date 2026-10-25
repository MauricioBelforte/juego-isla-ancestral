# Log 2179 - M53 UI/UX: coherencia MEDIDA, feedback de 120 ms y canal unico

- **Modelo:** DeepSeek-V4.1-Flash
- **Plataforma:** WorkBuddy
- **Fecha:** 2026-10-25 01:11 (GMT-3)
- **Modulo:** M53-UI-UX
- **Origen:** RAMA 1 - mensaje 393 de agnes-3-flash (acuse del 392: flips aplicados,
  commit encuadrado, CI ratificado, derivacion a M90 encolada). Sin pedido nuevo:
  se prosigue con la tanda anunciada en el 392 -> BACKLOG-11 D8, bloque 53-UI-UX.
- **Pool:** log 2179 reservado (cabeza previa 2179). Canal: cabeza 393 con ultimo
  archivo 393 (la directora consumio 393 sin retirarlo del pool) -> resincronizado
  a 394 = ultimo+1, tomado 394, cabeza nueva 395. Mismo procedimiento ratificado
  en el mensaje 387 (383 -> 386).

## 1. Que se midio ANTES de escribir una sola cifra

Sonda exploratoria sobre 1213 archivos .gd (74 de UI), sin escribir nada:

- 99 literales Color()/#hex en archivos de UI, en 27 archivos; solo 11 archivos
  usaban tokens ThemeUx.
- 20 raices CanvasLayer (14 `extends`, 7 `CanvasLayer.new()`); un solo `layer`
  explicito en ui_root.gd (100).
- 0 funciones de producto con audio + toast simultaneos; las 2 unicas que
  aparecian eran el propio test de no redundancia.
- Tween de 0.12 s: 4 en todo el proyecto, 3 en crop_tile_visual.gd (cosecha).
- `scripts/construccion/` y `scripts/shops/`: 0 tween_property cada uno.

Conclusion previa: L138 no esta cumplido (solo cosecha tiene feedback, y no
completo) y L144 se cumple por vacuidad, no por guardia.

## 2. Entregado

| Artefacto | Ruta | Detalle |
|---|---|---|
| Auditor estatico | `scripts/ui/auditar_ui_m53.py` | Bloques A (L221 canvas), B (L159 paleta), C (L144 redundancia), D (L138 feedback 120 ms). `--json`, `--check`, `--selftest`, `--raiz`; exit 3 = CIEGO |
| Modelo de feedback | `game/isla-ancestral/scripts/ui/feedback_accion_m53.gd` | Tabla de amplitudes por accion + pasos del Tween como datos + aplicador. Determinista (sin Time/TIME/rand) |
| Suite del modelo | `game/isla-ancestral/scripts/ui/test_feedback_accion_m53.gd` | 6 bloques A-F, 64 checks, piso 64 MEDIDO |
| Doc | `DOCUMENTACION/53-UI-UX/plan-actual/03-Diseno.md` | Seccion nueva 8.1-8.7 (+6.943 B) |

Ademas se corrigieron DOS tests que verificaban mal (ver hallazgos 3 y 4).

## 3. Evidencia medida

### 3.1 Auditor (corpus real, 1215 .gd)

- A) L221: 20 raices CanvasLayer (18 de producto), **14 sin `layer` explicito**,
  solo 3 indices en uso (-1, 15, 100), **1 colision**: pantalla_carga.gd:36 y
  ui_root.gd:36 ambos en `layer = 100`.
- B) L159: 11 tokens; 95 archivos con literal de color vs 16 con token;
  **27 literales duplican un token** (deuda estructural); **271 fuera de paleta**
  (criterio de diseno, no defecto automatico); 146 literales en archivos
  no-producto (tests, diag, demo, snapshots), contados aparte.
- C) L144: 0 funciones con triple canal, 0 con audio+toast, 0 tests que
  consagran la ausencia (tras el fix del hallazgo 3).
- D) L138: colocacion 18 archivos de superficie / **0 tweens**; cosecha 6 / **4
  tweens (3 de 0.12, 1 de 0.05)**; compra 9 / **0 tweens**.
- Total: **30 violaciones duras** (informe). `--check` sale 1 a proposito.

### 3.2 Suites

- `auditar_ui_m53.py --selftest`: **14 checks / 0 fallos / EXIT 0 x3**, piso 14
  MEDIDO. Sondas EN ROJO (2): ceguera de paleta inyectada -> 1 fallo EXIT 1;
  piso imposible (99) -> 1 fallo EXIT 1. Restauracion por sha256 verificada
  (93e5b0a5...).
- `test_feedback_accion_m53.gd`: **64 checks / 0 fallos / EXIT 0 x3**, bloques
  6/6, piso 64 MEDIDO, 0 SCRIPT ERROR. Sonda EN ROJO: error de runtime dinamico
  (indice fuera de rango) al inicio del bloque C -> **nombra el bloque C, dispara
  el piso (48 < 64), EXIT 1**; restaurado, sha256 identico (7d9cd99e...).
- Ceguera declarada: `--raiz /no/existe` -> EXIT 3.
- Regresion de hermanas: test_m53_capas 14/0, test_m53_wcag 17/0,
  test_m53_extremos 9/0 (tras el fix del hallazgo 4),
  test_m53_no_redundancia 7/0.

## 4. Hallazgos

1. **L138 incompleto de verdad:** solo cosecha tiene feedback animado (3 de 4
   tweens en 120 ms). Colocacion y compra: 0. El modelo entregado NO esta
   cableado (0 consumidores fuera de su test) -> el item queda en progreso, no
   cerrado. Cableado: M17 (colocacion), M16/farm (cosecha), M95/shops (compra).
2. **Colision de capa en el comentario, no solo en el numero:**
   `pantalla_carga.gd:36` dice `layer = 100  # por encima de todo` y
   `ui_root.gd:36` dice `layer = 100`. Misma capa; el orden de dibujado queda
   librado al orden del arbol. El comentario afirma lo contrario de lo que hace.
3. **Falso verde por consagracion (L144):** `test_m53_no_redundancia.gd` tenia
   `_check(uf == null, "... no hay redundancia posible")`, un PASS que solo se
   cumplia mientras el canal de audio siguiera ROTO. Reemplazado por deuda
   declarada (print, sin assert); la suite sigue verde con 7 checks. La
   no-redundancia ahora se verifica sobre codigo de producto en el bloque C.
4. **Falso verde por premisa vencida (L182):** `test_m53_extremos.gd` exigia
   `font_color == (0.10, 0.05)` ("ensure_contrast oscurece el texto"), correcto
   con la paleta CLARA previa a D102. Con el tema noche (2026-10-18) oscurecer
   BAJA el contraste y `ensure_contrast()` pone casi blanco. Medido: la suite
   estaba en 8 checks / 1 fallo (determinista, 2 corridas) -> el `[x]` de L182 ya
   no se sostenia. Ahora verifica el CONTRATO (ratio WCAG >= 4.5 y texto mas
   claro que el panel): 9 checks / 0 fallos / EXIT 0.

## 5. Defectos propios corregidos ANTES de publicar

- **Guardia estructural que se acusaba a si misma (2 veces):** el chequeo de
  "canal ajeno" leia los COMENTARIOS del modulo, que nombran a proposito los
  canales que NO usa -> 3 falsos positivos. Corregido con un `_solo_codigo()`
  en la suite. El mismo defecto aparecio en el auditor Python: mi comentario que
  citaba el `_check(uf == null, ...)` corregido se contaba como el defecto ->
  agregado `_sin_comentarios()` que respeta cadenas (para no romper `"#RRGGBB"`).
- **Regresion propia de L159:** la primera version del modelo hardcodeaba 3
  tintes `Color(...)` que duplicaban tokens del tema (violaciones 31 -> 34,
  medido con mi propio auditor). Corregido usando `ThemeUx.COLOR_*` via preload.
  Vuelve a 30.
- **Piso medido, no estimado:** el auditor arranco con `CHECKS_MINIMOS = 13`
  cuando el real era 14; la suite GDScript arranco con piso 0 y se fijo en 64
  recien tras medir.

## 6. Flips PROPUESTOS (0 aplicados: los aplica el director)

- L138 Feedback visual colocacion/cosecha/compra (Tween 120 ms): `[ ]` -> `[->]`.
  Modelo + aplicador + suite 64/0 existen y estan verificados; NO cableado.
- L144 Test de no redundancia: `[ ]` -> `[x]`. Hay guardia real (bloque C del
  auditor, probado en rojo) + el test de servicios corregido (7/0).
- L159 Coherencia visual entre capas: sigue `[ ]`. Medido: 27 literales duplican
  token y 95 archivos usan literales vs 16 con token. Hay metrica, no cierre.
- L221 Canvas merge por capa: sigue `[ ]`. Medido: 20 raices, 14 sin layer
  explicito, 1 colision (100). El merge necesita Profiler (M61) antes/despues.

## 7. Pendiente / decisiones al director

1. **Commit** de 5 paths: `scripts/ui/auditar_ui_m53.py`,
   `game/isla-ancestral/scripts/ui/feedback_accion_m53.gd`,
   `game/isla-ancestral/scripts/ui/test_feedback_accion_m53.gd`,
   `game/isla-ancestral/scripts/ui/test_m53_no_redundancia.gd`,
   `game/isla-ancestral/scripts/ui/test_m53_extremos.gd` +
   `DOCUMENTACION/53-UI-UX/plan-actual/03-Diseno.md` + este log. **0 commits / 0 push.**
2. **CI:** cablear solo `--selftest` como gate (el `--check` sale 1 por diseno,
   igual que en M50). Ratificar.
3. **Colision `layer = 100`**: decidir si `pantalla_carga` sube a 110/120 o si
   `ui_root` baja. No lo toque: cambia orden de dibujado en runtime.
4. **27 literales que duplican token**: reemplazo mecanico por `ThemeUx.COLOR_*`.
   Puedo hacerlo en una tanda, pero toca 20+ archivos de otros modulos -> GO.
5. **BOM preexistente** en `03-Diseno.md` (3 bytes): **removido** (contenido
   identico salvo el BOM, verificado por sha256). Quedan **122 secuencias de
   mojibake** (C3 83) en ese archivo, PREEXISTENTES: NO las toque, decision
   aparte (reparar mojibake es otra operacion).
6. **Derivacion M91:** `UIFeedback` no esta montado -> SFX de hover/click no-op.
   Ya estaba documentado; ahora queda como deuda declarada en el test, no como
   PASS.
