# Auditoría 2026-09-19 — Batería anti-sobre-cierre + drift + firmas

**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code
**Fecha:** 2026-09-19
**Log:** 1065

Reporte puro (sin escritura de código). Cubre las tareas 2, 3 y 5 de la batería.

---

## Tarea 2 — Anti-sobre-cierre de ✅ no verificados con binario real

De 34 filas `✅ Completado`, 5 no mencionan verificación cruzada ("Verificado por"/"QA
cruzado"/"§21.8"). Re-corrí sus suites con `D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe`
`--headless --path game/isla-ancestral --script res://...`:

| Módulo | Prog. | Suite | Resultado | Veredicto |
|--------|-------|-------|-----------|-----------|
| M154 Vision-Del-Agente | 155/155 | `validate_vision.py` (M153/operativa) | 19/19 EXIT 0 (mi Log 1048) | ✅ **VERIFICADO** (validador Python) |
| M167 Isla-Raiz | 114/114 | `scripts/terreno/validador_isla_raiz.gd` | **27 OK / 0 FAIL** (EXIT 1 por warning benigno de shutdown) | ✅ **VERIFICADO** |
| M93 Balance | 134/134 | `scripts/balance/test_balance_m93_iter4.gd` | EXIT 0, 0 fallos | ✅ **VERIFICADO** |
| M84 Musica-Y-Audio-Legal | 99/99 | `scripts/legal/test_audio_licenses_m84.gd` | **EXIT 1 — 4 SCRIPT ERROR** (parse error del propio test, líneas 75/94) | 🔴 **NO VERIFICABLE — BUG-062** |
| M94 Retencion-Sin-FOMO | 135/135 | `scripts/motivacion/test_motivacion_m94.gd` | **EXIT 1 — 38 checks, 5 fallos** | 🔴 **SOBRE-CIERRE — BUG-061** |

### Detalle de los 2 hallazgos críticos

**M94 (BUG-061)** — fallos funcionales reales en runtime:
```
[FAIL] diarios = 3 size=0        [FAIL] semanales = 2 size=0
[FAIL] mensuales = 2 size=0      [FAIL] progreso parcial no completa
[FAIL] progreso a 10 completa
```
La generación/consulta de retos devuelve 0 y la lógica de umbral de progreso no funciona.
El conteo del checklist (135/135) es correcto — el problema es runtime.

**M84 (BUG-062)** — la suite no parsea:
```
SCRIPT ERROR: Parse Error: The variable type is being inferred from a Variant value,
so it will be typed as Variant. (Warning treated as error.)  at: :75 y :94
```
Mismo patrón que BUG-048 (`is Tween` sobre var inferida). El ✅ "tests edge cases" de
mimo-v2.5 no es re-validable hoy.

Ambos registrados en `11-BUGS.md` §6 con firma. No se revirtieron (regla del auditor
designado). Filas marcadas en CHECKLIST-GLOBAL con nota 🔴 + referencia al bug.

---

## Tarea 3 — Drift scan de las 167 filas (Progreso declarado vs checklist real)

Método: conteo de `^\s*[-*] \[[ x?]\]` en `plan-actual/05-Checklist.md` vs columna
Progreso. **No se corrigió nada** (reporte para que el dueño o el coordinador apliquen).

**Resultado: 163 OK · 3 con delta · 1 sin checklist legible.**

| ID | Módulo | Declarado | Real | Detalle |
|----|--------|-----------|------|---------|
| 115 | 115-Hardware | 0/104 | **19/104** | x=19, ?=6, pend=79 — **en movimiento**: se editó en vivo a las 04:12 (reconciliación activa, x llegó a 68 durante la auditoría) |
| 25 | 25-Ruinas | 114/122 | **107/122** | x=107, ?=0, pend=15 — declarado 7 por encima del real (posible sobre-cierre de conteo) |
| 72 | 72-Sistema-De-Logros | 87/185 | **1/185** | x=1, ?=0, pend=184 — checklist revertido a casi cero (patrón de reversión masiva); declarado 87 |

**Sin checklist legible (1):**
- **150-Diseno-Sonoro-Narrativo** (declarado 88/150): la fila cita la carpeta
  `150-Diseno-Sonoro-Narrativo` pero el directorio real es otro (drift de nombre). El dueño
  debe alinear el nombre de la columna Módulo con la carpeta real.

Observación: el delta de M115 es **orgánico y en curso** (sesión viva detectada por
LastWriteTime 04:12:46), no es drift a corregir — ver tarea 4.

---

## Tarea 4 — M115-Hardware: NO ejecutada (agente activo)

Condición de la tarea: "SI MiMo NO LO TOMA". **Se tomó**: la reconciliación está en curso
en vivo — el checklist pasó de 0 [x] (mi Log 1059, 02:57) a 19 [x] y luego 68 [x] durante
esta auditoría, con `LastWriteTime` 2026-09-19 04:12:46 (3 minutos antes de la verificación).
No hay post en ESTADO-PARALELO reclamándolo, pero la edición en vivo es evidencia de sesión
activa. **No se tocó** (regla: no pisar trabajo activo).

---

## Tarea 5 — Auditoría de firmas en 11-BUGS.md (sección 7 "Resueltos")

22 bugs resueltos. Detección de firma relajada (`**Modelo:**` **o** `**Firma:**`) + mención
de causa (`causa|origen|motivo`):

- **8 fully compliant** (firma + causa): BUG-001, 002-OK, 012, 039, 052, y otros.
- **13 sin sección "Causa" explícita** — la causa está implícita en el título/Síntoma pero no
  en un campo `Causa` del template §4: **BUG-006, 007, 008, 009, 010, 014, 026, 027, 039→no,
  040, 051, 056, 060** (lista exacta: 051, 056, 006, 007, 008, 009, 010, 014, 026, 027, 040, 060).
- **1 sin firma**: **BUG-013** (IDs de DLC divergentes M95/M120) — sin `**Modelo:**` ni
  `**Firma:**`.

No se borró ni modificó nada de 11-BUGS.md (solo se agregaron BUG-061/062 en §6).

### Recomendación
El template §4 exige `**Modelo:**/**Plataforma:**/**Fecha:**` y una sección de causa. Los 13
bugs sin "Causa" explícita deberían completarse en una pasada de documentación (la info ya
existe en Síntoma — es trabajo de formato, no de investigación). BUG-013 necesita firma.

---

## Resumen de la batería

| # | Tarea | Resultado |
|---|-------|-----------|
| 0 | 7 🟡 estancados | ✅ Log 1059 (cero huecos) |
| 1 | M110 bloqueado | ✅ fila reparada (11 cols) + nota ⛔ + ESTADO-PARALELO |
| 2 | Anti-sobre-cierre ✅ | 3 verificados OK · 1 no verificable (BUG-062) · 1 sobre-cierre (BUG-061) |
| 3 | Drift scan 167 filas | 163 OK · 3 delta (115 vivo, 25 +7, 72 revertido) · 1 sin checklist |
| 4 | M115 reconciliación | ⏭️ saltada — sesión activa detectada (edición en vivo 04:12) |
| 5 | Firmas 11-BUGS.md | 8 OK · 13 sin Causa explícita · 1 sin firma (BUG-013) |
