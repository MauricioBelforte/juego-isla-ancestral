# T266 - M73: fix validador CATEGORIAS_CONOCIDAS (12 categorias faltantes - FALLO runtime)

**Fuente:** gate-2 Hy3 #383 (24oct) + Log. **Dueno M73 (collectibles).**

## Contexto (medido por Hy3, verificado)
`data/coleccionables/catalog.json` = **81 items en 19 categorias**. Pero `validate_collectibles.gd:17-20`
(`CATEGORIAS_CONOCIDAS`) solo lista **8**. Las **12 categorias nuevas** (expandidas por Beam/Step-5)
no son reconocidas -> **48 errores 'categoria desconocida'** -> `validate_collectibles.gd.validar()`
devuelve `ok=false` -> **suite `test_validate_collectibles_m73.gd` rc=1 (FALLO runtime, 1 de 9)**.
Hy3 compro con green-probe: anadiendo las 12 categorias la suite pasa (rc=0). Revertio byte-exact.

## Que hacer (produce-first: primero la lista real de 19 categorias de catalog.json)
1. `grep -oE '"categoria"[: ]*"[a-z_]+"' game/isla-ancestral/data/coleccionables/catalog.json | sort -u`
   (o JSON: `json.load` y `set(item['categoria'])` si el campo existe) para obtener las 19.
2. Diferenciar contra las 8 actuales en `validate_collectibles.gd:17-20` -> **12 faltantes**.
   Esperadas (por Hy3): insectos, fosiles, cartas, fotos, mapas, herramientas, ropa, simbolos,
   mensajes, secretos, muebles, objetos_historia.
3. Ampliar `CATEGORIAS_CONOCIDAS` (L17-20) con las 12 (una sola comilla/dos puntos por linea, NO coma).
4. Correr `test_validate_collectibles_m73.gd` -> debe dar rc=0 / 0 fallos (green-probe de Hy3 lo comprobante).

## Cita
- `game/isla-ancestral/scripts/tools/validate_collectibles.gd:17-20` (CATEGORIAS_CONOCIDAS)
- `game/isla-ancestral/tests/test_validate_collectibles_m73.gd` (suite M73)
- `data/coleccionables/catalog.json` (81 items / 19 categorias)

**Nota (M110, debito no-blocking):** `scripts/debug_menu.gd:721` `_do_export_diagnostic` stderr
`ERROR: Parameter "t" is null` (textura nula en el path de export de diagnostico). Hy3 lo marco; los 3
suites M110 pasan porque no asertan ese error. Cerrarlo en una tanda posterior.

Firma: agnes-3-flash (Sapiens AI) / Kilo Code - 2026-10-25.
