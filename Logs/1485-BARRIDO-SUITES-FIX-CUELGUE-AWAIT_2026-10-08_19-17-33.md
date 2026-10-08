# Log 1485: Barrido de suites muertas - entrega 2: fix del cuelgue (`await .ready`) en 2 suites propias

**Fecha:** 2026-10-08
**Hora:** 19:17
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Tipo:** Fix de suite propia (continuacion de Log 1483, encargo msg 93 seccion 6)
**Alcance:** `tests/unit/data/test_npc_visual_database.gd` (M161),
`tests/unit/player/test_equipment_manager.gd` (M155). Ambos son output de MI
conversion gdUnit4->headless (commit 7c9d130, Log 1268).

## 1. Resumen

Las 2 suites marcadas **CUELGA-WATCHDOG** en el inventario (Log 1483) ya NO cuelgan:
corren completas, imprimen resumen y son **estables x3**. Al destrabarlas quedo a la vista
que **no eran solo un cuelgue**: tenian fallos REALES escondidos detras del hang. Se fijan
los pisos medidos y se prueba el guardia en rojo. Los fallos expuestos se delegan a su dueno.

## 2. Causa raiz (medida con sonda, no supuesta)

Patron repetido en cada bloque:

```gdscript
var db = DB_SCRIPT.new()
root.add_child(db)
await db.ready            # <-- cuelga
```

**Sonda aislada** (Node vacio, watchdog 8 s): tras `add_child(n)`,
`n.is_node_ready()` ya es **true** de inmediato; `await n.ready` **NO resuelve** (TIMEOUT).
Causa: `add_child` propaga `ready` de forma **SINCRONA**, asi que el `await` posterior
espera una re-emision que nunca llega. Confirmado que las **5** suites del repo con este
patron estan **todas** rotas (estas 2 + 3 gdUnit4 con TIMEOUT).

## 3. Fix aplicado

- `await <nodo>.ready` -> `await process_frame` (idioma del proyecto, trampa 22).
  Se conserva la corrutina a proposito: quitar el await dejaria un `REDUNDANT_AWAIT`
  (warning-as-error en este repo) en `await _bloque_X()`.
- Reemplazos: **10** en `test_npc_visual_database.gd`, **20** en `test_equipment_manager.gd`.
- Piso `CHECKS_MINIMOS`: 0 -> **353** (npc) y 0 -> **35** (equipment), MEDIDOS en la corrida.
- Cabecera de cada archivo: nota del fix con la causa medida.
- EOL: LF puro preservado, sin BOM, sin FFFD. Sin `quality.yml` (regla del encargo).

## 4. Verificacion (x3, estable)

| Suite | checks | fallos | exit | SCRIPT ERROR | WATCHDOG |
|---|---|---|---|---|---|
| test_npc_visual_database.gd | 353 | 3 | 1 | 0 | 0 |
| test_equipment_manager.gd | 35 | 13 | 1 | 4 | 0 |

Las 3 corridas de cada suite dan EXACTAMENTE los mismos numeros (deterministas).
Antes del fix: 0 checks, WATCHDOG a los 60 s, rc=1, sin resumen.

## 5. Guardia probado EN ROJO (por inyeccion)

- **Piso:** piso inyectado a 400 (> 353) -> `[FAIL] solo 353 checks ejecutados (minimo 400)`,
  4 fallos, exit 1. Restaurado byte-exacto (sha256 identico).
- **Bloques faltantes:** en la corrida real de equipment el guardia ya nombro
  `bloques que no terminaron: ["B", "C", "L", "U"]` -> la capa de `_fin()` funciona.

## 6. Hallazgos expuestos (estaban ocultos por el cuelgue)

### 6.1 npc (3 fallos) - DATOS de M161

`visual.sombrero.color_principal .is_not_empty()` falla en 3 de 23 NPCs. Medido: 4 `.tres`
de `data/npc_visuals/` tienen algun `color_principal = ""`; 3 de ellos en el sombrero.
Dueno: M161 (pista del mapa: Hy4). **No se toca** (dato ajeno).

### 6.2 equipment (13 fallos + 4 SCRIPT ERROR) - contrato del SUT de M155

Causa medida: `equip_item()` exige que el item este en el **inventario**
(`_get_inventory() -> /root/Inventario`; si `count_item <= 0` -> `return false`). En headless
el Inventario real no tiene los items, asi que `equip_item` devuelve false y
`get_equipped_item` devuelve **null** -> `slot.item_id` sobre Nil = SCRIPT ERROR.
El SUT **no expone hook de test** (`_get_inventory()` lee el autoload real, sin override).
Nota: el bloque D ("equip_wrong_slot_fails") PASA por el motivo equivocado (falla por
inventario, no por slot) - candidato a trampa 88. Dueno: M155. **No se toca.**

## 7. Correccion de atribucion (mi error en el Log 1268)

En el Log 1268 reporte estas 2 suites como rojas **"bloqueadas por bugs AJENOS"**,
citando un `Parse Error: Cannot infer the type of "pct"` en `settings_audio_layer.gd:394`
(edicion EN VUELO de M53/mimo). **Esa atribucion era incorrecta**: el error ajeno ya NO
esta (medido: 0 Parse/Compile/inference errors en la salida actual; el archivo ya usa
`var pct: float = float(...)`), y la suite **igual colgaba**. La causa PERSISTENTE era mi
propio `await .ready`. Es la familia M-07 (localizar antes de afirmar). Se corrige aqui.

## 8. Delegacion

- npc 3 fallos -> datos de M161 (Hy4): color de sombrero vacio en 3 `.tres`.
- equipment 13 fallos -> M155: o el SUT expone un hook de inventario para tests, o se
  decide que el test inyecte items por la API real. Es decision de contrato del SUT.

## 9. Restricciones

Sin commit/push (no autorizado). Sin tocar `quality.yml`, `CHECKLIST-GLOBAL.md` ni QA-SEALS.
Pool de logs: 1483 (inventario) + 1485 (este); el 1484 lo consumio otro agente.
