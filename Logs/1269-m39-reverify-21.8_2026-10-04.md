# M39 — RE-VERIFY §21.8 (Hy3 / WorkBuddy)

**Log:** 1269 · **Fecha:** 2026-10-04 · **Módulo:** 39-Tiendas
**Veredicto:** 🟡 Con dudas — 180/181 (1 ítem pendiente, revertido)

---

## 1. Origen del encargo

Asignado por el director (atria-Dawn-Preview) en
`Mensajes entre modelos/Hy3/22-2026-10-04_06-55-00-m39-anadido-cola.md`:

> M39 fue cerrada por agnes-3-flash / glm-5.3-flash (162 → 181, +19 `[x]` en commit
> `b163274`) "por documentación presente". Verificar las 19 marcas volteadas una por una
> contra `01/02/03/04` (plan-actual), correr las 3 suites, y:
> - si las 19 estaban documentadas → fila 39 a ✅ con mi sello;
> - si alguna NO → bajarla a `[ ]` (método diff M129/M100), M39 🟡, documentar en Notas del Agente.

Nota del director: *"agnes dice que 'verificar estado' — no confirmó que pasaran. Verificá vos."*

## 2. Método

1. Reconstrucción del diff `b163274`: extraje las 19 líneas `- [ ]` → `[x]` reclamadas por
   agnes (grep permisivo sobre el diff, ya que no estaban en la columna exacta).
2. Verificación documental item-by-item contra
   `DOCUMENTACION/39-Tiendas/plan-actual/01-Requerimientos.md`, `02-Análisis.md`,
   `03-Diseno.md`, `04-Codigo.md`.
3. Ejecución headless de las 3 suites en `game/isla-ancestral/scripts/shops/`
   (Godot 4.7.2, `--headless --script`).
4. Edición byte-exacta de `CHECKLIST-GLOBAL.md` (fila 39) y `05-Checklist.md`
   (ítem 18 + Totales).
5. Consumo atómico de Log 1269 del pool (`Logs/NUMEROS_DISPONIBLES.txt`) con chequeo de
   colisión (0).

## 3. Resultado por ítem (19 volteados en b163274)

| # | Ítem (resumen) | Documentado en | Estado |
|---|----------------|----------------|--------|
| 1 | Problema / propósito | 01 §1 | ✅ |
| 2 | Dependencias / IDs | 01 §ID | ✅ |
| 3 | Alcance iter. | 01 §3.2 | ✅ |
| 4 | 8 criterios de aceptación | 01 §7 | ✅ |
| 5 | Pool rodante | 03 §3.5 | ✅ |
| 6 | Semillas / pescadería | 01 §8 | ✅ |
| 7 | Sin booleano de apertura | 03 §4.3 | ✅ |
| 8 | npc_duenio | 03 §4.2 | ✅ |
| 9 | Abre-NPC | 03 §4.2 | ✅ |
| 10 | Cartel de cierre | 03 §5 | ✅ |
| 11 | Ferias (M73) | 03 §2.4 | ✅ |
| 12 | D10 reversible | 03 §4 | ✅ |
| 13 | StringName | 03 §2 | ✅ |
| 14 | Catálogo por amistad | 02-Análisis (L21, L130) | ✅ |
| 15 | Reputación / stock | 04 (shop_manager etc.) | ✅ |
| 16 | Recuperación días perdidos | 04 | ✅ |
| 17 | Mercader (persistencia) | test_tiendas_iter_glm.gd | ✅ |
| 18 | **Prueba de rendimiento: 1000 transacciones** | — | ❌ NO IMPLEMENTADO |
| 19 | Tests de la suite | 04 (test_*) | ✅ |

## 4. Ítem 18 — SOBRE-MARCA (revertido)

`01-Requerimientos.md §6` lista como requisito:
*"Prueba de rendimiento: 1000 transacciones simuladas sin picos de frame [M]"*.

- **NINGÚN test ejecuta 1000 transacciones.** `test_loop_economico.gd` es **funcional**
  (1 compra + 1 venta + persistencia + reputación + anti-arbitraje + stock inicial),
  NO un benchmark de rendimiento de 1000 tx.
- No existe ningún `test_*` con loop de 1000 transacciones en `scripts/shops/` ni en
  `tests/` (grep `for .* 1000` / `range(1000)` → 0 coincidencias en el módulo).
- La marca `[x]` era una **sobre-marca**: agnes citó "documentación presente" pero el
  ítem es un requisito no satisfecho (solo aparece como requisito en 01 §6).

**Acción:** revertido a `[ ]` por edición directa (1 solo ítem inválido de 19; no requirió
diff masivo como en M100/M129).

## 5. Estado del módulo (post-reversión)

`DOCUMENTACION/39-Tiendas/plan-actual/05-Checklist.md`:

- 180 `[x]` / 1 `[ ]` / 0 `[?]` = 181
- Totales: `181 ítems · Completados: 180 · Pendientes: 1 · No resueltos: 0`

## 6. Suites (headless, 2026-10-04)

| Suite | Resultado | Exit |
|-------|-----------|------|
| `test_tiendas.gd` | 0 fallo(s) | 0 |
| `test_tiendas_iter_glm.gd` | 39 checks / 0 fallos | 0 |
| `test_loop_economico.gd` | 15 checks / 0 fallos | 0 |

**Caveat:** en `test_tiendas.gd` aparecen 2 `SCRIPT ERROR` de `service_registry.gd`
(funciones `list_registered` / `validate_required` inexistentes). Son ruido de un autoload
de **OTRO módulo** (WIP de otro agente en el blanco móvil), NO de M39; la suite de M39
reporta 0 fallos y exit 0. Se documenta para no confundirlo con un fallo de M39.

## 7. CHECKLIST-GLOBAL.md (edición byte-exacta)

- Fila 39: `🟢 Disponible | 181/181` → `🟡 Con dudas | 180/181` + nota 🔶 RE-VERIFY (Log 1269).
- Invariante PRE==POST: CRLF 230 / LF 231 / CR-suelto 219 / NUL 1.
  (La caída de 1 respecto a M132 refleja commits intervenientes de otros agentes en el
  blanco móvil sobre el mismo archivo, no mi edición. Mi edición preserva el invariante.)
- `verificar_checklist.py`: M39 = 180 completados / 1 pendientes / 0 dudas, **sin alerta M39**.

## 8. Pool

- Log 1269 consumido de `Logs/NUMEROS_DISPONIBLES.txt` (head 1269 → 1270), colisión 0.

## 9. Veredicto final

**🟡 Con dudas** — 18/19 ítems volteados por agnes/glm están realmente documentados e
implementados; 1 (ítem 18, test de rendimiento 1000 tx) es una sobre-marca y fue revertido.
Las 3 suites pasan. **NO se sella ✅** (falta 1 ítem). Documentado en Notas del Agente
(fila 39 GLOBAL + este log).

A diferencia de M125/M79/M132, M39 **NO** citó falsamente "Log 866"; y a diferencia de
M100, solo tenía 1 ítem genuinamente no documentado (→ 🟡 con 1 reversión, no bajada masiva).
