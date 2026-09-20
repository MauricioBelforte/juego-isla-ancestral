# 06 — Plan de Testings — M25: Ruinas (hy3 / WorkBuddy, 2026-09-19)

**Propósito:** Definir el plan de validación del sistema de ruinas antes de su implementación
de juego. Cubre las 5 áreas pendientes del `05-Checklist.md` (items 9–13 del backlog
T1–T15): validación del kit, armado de los 13 tipos, progresión de descubrimiento,
pruebas de rendimiento (LOD) y criterio de éxito.

**Alcance:** Diseño/documentación (no ejecuta GDScript). La ejecución real queda para la
fase de implementación de M25 (autor: MiMo V2.5) y se registrará en `07-Resultados-Testings.md`.

**Entorno objetivo:** Godot 4.7.2.stable, headless (`--headless --path game/isla-ancestral --quit --script`).
Regla anti-falso-verde (Lección 28): toda suite reporta `EXIT` real y cuenta de `SCRIPT ERROR`;
un "0 fallos" sin `EXIT 0` y 0 `SCRIPT ERROR` NO cuenta como pasada.

---

## 1. Validación del kit (pivotes / snaps)

**Objetivo:** Garantizar que cada pieza del kit modular (≤40 piezas, 6 snaps por cara) se
ensambla sin traslape y con pivote en esquina inferior izquierda.

**Casos:**
- V1 — Pivote por pieza en esquina inferior izquierda (regla documentada en `03-Diseno.md`).
- V2 — 6 snaps por cara conectan solo con caras compatibles (muro↔muro, suelo↔suelo, etc.).
- V3 — Validación de traslapes: dos piezas en la misma celda → fallo de build (`_build_fail`).
- V4 — Fallo de build si la validación falla (no se genera la ruina).
- V5 — Todos los grupos (suelo, muro, apertura, soporte, techo, escalera, decoración, canal)
  validan contra el catálogo de `03-Diseno.md`.

**Hook:** `operativa/validar_nombres.py` (patrón de M149) puede extenderse con
`validar_kit.py` que parsea el `.tscn` de la ruina y chequea pivotes/snaps.

**Criterio de aceptación:** V1–V5 pasan; 0 `SCRIPT ERROR`; `EXIT 0`.

---

## 2. Armado de los 13 tipos

**Objetivo:** Verificar que los 13 tipos de estructura documentados se construyen completos.

**Tipos (de `03-Diseno.md`):**
1. Choza/ermita (3–5 piezas, 1 puzzle Exploración)
2. Caserío (8–15 piezas, 1–2 puzzles Ritual)
3. Atalaya (vista de bioma — ver `08-Integraciones.md` §Atalayas)
4. Templo (plan en cruz: nave + crucero + ábside)
5. Fortín mediano
6. Templo/fortín grande (25–60 piezas)
7. Ciudad antigua (3–5 bloques urbanos)
8. Observatorio (domo + agujero cenital)
9. Estación (amarre de vehículos M66)
10. Faro (haz fisicalizable, luz M24)
11. Puente de arco (validación estructural)
12. Puente colgante (3 cables)
13. Jardín en terrazas (canales de agua)

**Casos:** por cada tipo, T_n_a (ensamblaje sin traslape) y T_n_b (puzzles M24 conectados
vía contrato `set_emisor`/`get_emisor`). Referencia: `03-Diseno.md` L89–L99.

**Criterio de aceptación:** los 13 tipos ensamblan; sus activadores emiten vía contrato M24
(`signal emisor_cambiado(id, activo)`); 0 `SCRIPT ERROR`.

---

## 3. Progresión de descubrimiento

**Objetivo:** Validar la máquina de estados NoDescubierta → Descubierta → Explorada → Completada.

**Casos:**
- P1 — Detección a 15 m (`_detectar_descarte`) dispara Descubierta.
- P2 — Hint de horizonte al descubrir (M63) se emite.
- P3 — Transición a Explorada al 50% de puzzles resueltos.
- P4 — Transición a Completada al guardar relicto (`relicto_guardado`).
- P5 — Eventos de transición (diario, mapa M58, museo M36) se señalizan.
- P6 — Guardado atómico en cada transición (`signal estado_cambiado(ruina_id, nuevo_estado)`, `03-Diseno.md` L295).
- P7 — Persistencia del estado por ruina (reinicio conserva estado).

**Criterio de aceptación:** P1–P7 transicionan correctamente; estado persiste; 0 `SCRIPT ERROR`.

---

## 4. Pruebas de rendimiento (LOD)

**Objetivo:** Verificar presupuesto de draw calls / memoria con LOD 0–2 vía M63 (culling por región).

**Casos:**
- R1 — Ruina grande (60 piezas) en LOD0 ≤ presupuesto de `budgets.json` (M166).
- R2 — LOD1/LOD2 reducen draw calls ≥ 40% vs LOD0.
- R3 — Culling por región (M63) descarta ruinas fuera de vista (0 costo de simulación).
- R4 — Sin `Update` por ruina (estática); sin costos de simulación.

**Criterio de aceptación:** R1–R4 dentro de presupuesto M166; sin regresión de FPS headless.

---

## 5. Criterio de éxito

**Definición:** la suite completa (V1–V5, T1–T13, P1–P7, R1–R4) pasa sin fallos.

- `EXIT 0` en cada script headless.
- 0 `SCRIPT ERROR` en stderr.
- Conteo de checks verde (0 fallos) en `07-Resultados-Testings.md`.
- Antiguo-falso-verde: un resumen "0 fallos" sin `EXIT 0` + 0 `SCRIPT ERROR` NO califica.

**Gate CI:** `quality.yml` debe marcar fallo si algún script de M25 termina con `EXIT != 0`
o `SCRIPT ERROR > 0` (patrón de BUG-039 / guardian de M149).

---

## Anexo — Edge cases (ya [x] en checklist)

- Ruina sin puzzle: válida como estructura decorativa, no emite `emisor_cambiado`.
- Cofre (M66): objeto único (`copia única`, `03-Diseno.md`), no bloquea progresión si está vacío.
