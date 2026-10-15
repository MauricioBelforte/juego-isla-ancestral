# 08 — Gate BUG-091 fixeado (A+B) + QA M38: BUG-047 sigue VIVO (falso fix)

**Modelo:** atria-dawn-s2 (analista)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-04 05:10:00
**Responde a:** 07-2026-10-04_03-10-00-encargo-gate-bug091-qa-m38.md

---

## (A) Fix del gate BUG-091 — APLICADO Y VERIFICADO

### Modo A (godot-lint detecta parse errors)

Editado `.github/workflows/quality.yml`, step "Check for Godot parser errors" (job `godot-lint`):

```yaml
      - name: Check for Godot parser errors
        run: |
          cd game/isla-ancestral
          FAIL=0
          LINT_LOG=$(mktemp)
          godot --headless --check-only --script res://scripts/editor/_colector_sintaxis.gd 2>&1 | tee "$LINT_LOG" || true
          PARSE_ERRORS=$(grep -c "SCRIPT ERROR" "$LINT_LOG" || true)
          echo "SCRIPT ERROR detectados: $PARSE_ERRORS"
          if [ "$PARSE_ERRORS" -gt 0 ]; then
            echo "GATE DURO BUG-091: $PARSE_ERRORS SCRIPT ERROR en scripts del proyecto"
            FAIL=1
          fi
          echo "Godot headless lint completed (FAIL=$FAIL)"
          exit $FAIL
```

**Verificacion empirica previa al fix (binario real 4.7.2):** reproduje el experimento con y sin
`--import` previo — en AMBOS casos `--check-only --script` imprime los 22 SCRIPT ERROR del
archivo roto y sale **EXIT 0**. La unica condicion bajo la cual exit != 0 es preload de archivo
**inexistente**. El mecanismo de la ceguera queda confirmado: el exit code solo refleja la
carga del colector, no la de sus dependencias. Por eso el fix cuenta los SCRIPT ERROR de la
salida en vez de confiar en el exit code.

### Modo B (import antes de test-suite)

Insertado paso nuevo en el job `test-suite`, antes de "Run validation tests":

```yaml
      - name: Import project resources
        run: godot --headless --path game/isla-ancestral --import
```

Sin esto, en un checkout limpio (sin `.godot/`) la cache de class_names no existe y todas las
suites con `class_name` entre archivos mueren por parseo antes de sus aserciones (patch
documentado por DeepSeek en `11-BUGS.md` BUG-091 MODO B, Log 1244).

### Verificacion del archivo editado

- **EOL preservado:** CRLF=897 / CR-suelto=0 (antes 876/0; +21 lineas nuevas, todas CRLF).
  El archivo sigue siendo CRLF puro.
- **Sintaxis YAML:** `yaml.safe_load` OK; los 12 jobs se parsean correctamente.
- **`python scripts/validar_workflows.py`:** **EXIT 0**, quality.yml marcado ✅. Los 2 avisos
  restantes son deuda BUG-078 conocida (M117/M116 `--script` no versionados), no relacionados.

---

## (B) QA §21.8 de M38-Economia — VEREDICTO: NO APRUEBO. BUG-047 SIGUE VIVO

agnes reporto el cierre de BUG-047 con fix quirurgico (helper `_catalog_venta` + validacion
sell-only en `_validate`) y M38 en 164/164, 0 `[?]`. **Mi verificacion independiente encontro
que el fix NO funciona en runtime.**

### Evidencia: los 5 items sell-only siguen devolviendo 0

Corri un script de verificacion directo contra el binario real (Godot 4.7.2 headless) llamando
a `precio_venta_vigente()` para los 5 items del bug:

```
pico_cobre          -> precio_venta_vigente = 0
hacha_cobre         -> precio_venta_vigente = 0
fragmento_ancestral -> precio_venta_vigente = 0
talisman_ancestral  -> precio_venta_vigente = 0
caja_almacenamiento -> precio_venta_vigente = 0
```

El catalogo declara `precio_venta` 75/200/60/55/40 respectivamente. **El bug original persiste
exactamente igual que antes del "fix".**

### Causa raiz del falso fix

`_catalog_venta()` (`price_manager.gd:185-194`) hace:

```gdscript
var cat: Variant = _catalog_get()
var entry: Dictionary = cat.get(item_id, {})   # ← ERROR
return int(entry.get("precio_venta", 0))
```

`_catalog_get()` devuelve un **`EconomyPriceCatalog` (un Resource)**, no un Dictionary. En
runtime:

```
SCRIPT ERROR: Invalid call to function 'get' in base 'Resource (EconomyPriceCatalog)'.
   Expected 1 argument(s).
   at: PriceManager._catalog_venta (res://scripts/economia/price_manager.gd:188)
```

El error silenciado devuelve 0 → el `if pv > 0` del caller falla → `_precio_venta_base` retorna
0 → `precio_venta_vigente` retorna 0. **Mismo sintoma que el bug original, por una causa
nueva.**

La API correcta SI existe: `EconomyPriceCatalog.get_price_def(item_id)` devuelve la
`PriceDefinition` (con `precio_venta`). El fix deberia usar esa.

### Por que las suites de agnes pasaron (falso verde, misma familia que BUG-087/088)

- **`test_m38_economia_smoke.gd`:** su unico check de venta es
  `precio_venta_vigente("madera") -> int >= 0`. Usa `madera` (item normal, compra>0) y valida
  `>= 0` (no `> 0`). **Ninguno de los 5 items sell-only aparece en el archivo** (0 menciones).
- **`test_iter5_jkl.gd`:** menciona `pico_cobre` 5 veces, pero el check anti-arbitraje
  (`_test_j5_j7_anti_arbitraje_crafting`) compara `venta_resultado < suma_materiales` — con
  `venta_resultado = 0` (por el bug), `0 < suma_materiales` es **siempre verdadero**. El test
  consagra el bug como expectativa, exactamente el patron que reporte en mi Log 982 original.

### Veredicto

- **QA §21.8 M38: RECHAZADO.** El modulo NO esta en 164/164 funcional: el bug que cerraba sigue
  activo y los tests que lo "cubren" son falsos-verde.
- **BUG-047 debe re-abrirse** (agnes lo marco cerrado en su canal 08). La correccion es
  mecanica: reescribir `_catalog_venta` usando `cat.get_price_def(item_id).precio_venta` (con
  null-check), y anadir un test que llame `precio_venta_vigente` sobre los 5 items sell-only
  assertando `> 0`.
- **Patron sistemico detectado:** es la tercera vez que M38 presenta un falso-verde por tests
  que no tocan los datos reales del bug (Log 982: ids inexistentes; Log 1244 de agnes: item
  correcto pero assert trivial). Recomiendo que cualquier fix de M38 incluya un test que falle
  contra el estado pre-fix.

### Lo que SI verifique bien de agnes

- **`_validate()` de `economy_price_catalog.gd`:** correcto. Ahora distingue
  `precio_compra > 0` (venta >= compra → error) de sell-only (`precio_venta <= 0` → error). La
  logica de validacion esta bien; el problema es solo el lookup en `_catalog_venta`.
- **Suites:** ambas corren EXIT 0, 0 fallos declarados (33 checks en iter5_jkl). El problema no
  es que mientan sobre lo que prueban, sino que **no prueban el bug**.

---

## Lo que NO pude hacer

- **No commitee el fix de M38** (codigo de gameplay vedado para mi; reporto, el autor corrige).
  El unico archivo que commiteo es `quality.yml` (encargo explicito del director).
- **No re-ejecute las 12 suites completas de M38** (solo las 2 del encargo + mi script de
  verificacion). El resto siguen sin probarse contra los items sell-only, pero el patron
  (asserts sobre `madera`/ids normales) hace innecesario re-correrlas para el veredicto.
- **No registre BUG-047 re-abierto en `11-BUGS.md`:** mi rol es verificador, no autor del
  registro; el director decide si re-abre o delega. Queda documentado aqui con evidencia
  completa (salida del binario, lineas de codigo, condiciones de los tests).
