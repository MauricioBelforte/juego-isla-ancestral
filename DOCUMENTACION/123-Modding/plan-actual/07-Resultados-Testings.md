# 07-Resultados-Testings.md — Módulo 123: Modding

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-13 (iteración 2, Log 879)
**Estado:** ✅ 69 checks / 0 fallos / 3 de 3 corridas

## 1. Resumen de la iteración 2

Punto de partida: el módulo declaraba en su `05-Checklist.md` un bloque "Totales"
que decía **"106 ítems, 0 pendientes, 0 dudas"**, mientras el archivo tenía **24
`[ ]` reales** sobre 108. Además, `test_modding_m123.gd` **empezaba con BOM UTF-8**
(violación §28) y `04-Codigo.md` describía la implementación en **C# (Unity)** —
diseño muerto que nunca correspondió al código real en GDScript.

La iteración corrige el sobre-cierre, implementa las reglas que faltaban y añade
**sandbox de rutas** y **esquema de assets alineado con M108**.

## 2. Archivos

| Archivo | Cambio |
|---|---|
| `scripts/modding/mod_sandbox.gd` | **NUEVO** — `ruta_segura()` (anti path traversal), `nombre_asset_valido()` / `extension_compatible()` (espejo de M108), `validar_assets()` (esquema + límite 10 MB + duplicados) |
| `scripts/modding/mod_validator.gd` | **Reescrito** — códigos de error `E01..E14`, `validar_paquete()` (corrupto/readme/schema), duplicados con override |
| `scripts/modding/modding_manager.gd` | **Extendido** — `resolver_prioridad()` (menor prioridad se omite) y `es_compatible_update()` (M118) |
| `scripts/modding/test_modding_m123.gd` | **Reescrito** — 11 bloques A-K, marcadores `_fin()`, 69 checks. **BOM eliminado** |
| `data/mods/mod_manifest.json` | **Extendido** — `schema_version`, `author`, `prioridad`, `readme`, `assets[]` por id, límites |

## 3. Suites ejecutadas

| Suite | Comando | Resultado |
|---|---|---|
| Test de modding (11 bloques) | `--headless --path game/isla-ancestral --script res://scripts/modding/test_modding_m123.gd` | **69 checks, 0 fallos** ×3 |

```
=== Resumen M123: 69 checks, 0 fallos ===
TEST M123 OK — todos los checks pasaron
```

**0 `SCRIPT ERROR`.** Cada bloque deja un marcador `_fin()` y `_run()` verifica
que los 11 bloques corrieron: un error de script que aborte una función en
silencio (falso verde) no puede pasar desapercibido.

## 4. Cobertura por bloque

| Bloque | Qué prueba | Checks |
|---|---|---|
| A | Manifiesto: 2 mods, `mod()`, `carpeta_mods()`, `schema_version` | 6 |
| B | Compatibilidad por build + activación | 6 |
| C | Conflictos por override | 2 |
| D | Catálogo real válido (0 errores) | 2 |
| E | Errores de manifiesto + duplicado con override | 4 |
| F | **Sandbox**: path traversal, absolutas, unidad de disco, backslash | 8 |
| G | **Esquema M108**: nombres, extensiones, 10 MB, duplicados | 13 |
| H | **Paquete**: corrupto (E06), readme (E07), schema (E13), válido | 5 |
| I | **Prioridad**: mayor gana, menor se omite con motivo | 4 |
| J | **M118**: compatibilidad con updates, incl. downgrade | 4 |
| K | **Códigos**: E01..E14 completos y usados | 4 |
| — | Marcadores de bloque (anti-falso-verde) | 11 |

## 5. Bugs reales encontrados y corregidos (por el propio test)

El test es **adversarial**: construye fixtures que *deben* fallar. Al hacerlo,
encontró 2 bugs en el código nuevo de esta iteración:

1. **Extensión derivada del campo equivocado.** `extension_compatible(nombre)`
   tomaba la extensión del `nombre`, pero el esquema M108 define el `nombre`
   **sin** extensión (la extensión está en la `ruta`). Resultado: todo asset se
   marcaba como E09. Corregido: `extension_compatible(nombre, ruta)`.
2. **`JSON.parse_string` devuelve números como `float`.** El chequeo de `prioridad`
   exigía `TYPE_INT` y rechazaba `10` (que el parser entrega como `10.0`).
   Corregido: se acepta `TYPE_INT` o `TYPE_FLOAT`.

Ambos habrían pasado desapercibidos con un test tautológico.

## 6. Defectos del módulo corregidos en esta iteración

1. **BOM UTF-8 en `test_modding_m123.gd`** (§28) → eliminado.
2. **Bloque "Totales" falso**: decía 106 ítems / 0 pendientes; real = 108 / 24.
   Corregido a los conteos reales.
3. **Convención ambigua**: el encabezado decía *"`[ ]` = completado por
   documentación. `[ ]` = pendiente."* (dos veces `[ ]`) → corregido a
   `[x]` = completado / `[ ]` = pendiente / `[?]` = no resuelto.
4. **Cabecera desfasada**: "(110 ítems)" → 108.

## 7. Lo que NO se pudo verificar

- Desempaquetado real de un `.zip`/`.mod` (no implementado).
- Instalación en `user://mods/` (no implementado).
- Integración con Steam Workshop M97 (V2) y UI M89.
- Carga de un mod real de terceros (no existe ninguno en el árbol).

## 8. Registro

- Fila 123 de `CHECKLIST-GLOBAL.md`, fila en `ESTADO-PARALELO.md`, log
  `Logs/879-M123-Modding-Iter2_2026-09-13.md`.

**Firmado:** DeepSeek-V4.1-Flash / WorkBuddy — 2026-09-13
