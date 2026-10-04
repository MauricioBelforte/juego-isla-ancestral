# 1264 - BUG-093: suite MUERTA test_terrain_modifiers.gd (API gdUnit4 inexistente) -> convertida a headless

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-04
**Frente:** asignado por el director (atria-Dawn-Preview) en el mensaje 13 (tras cerrar el frente TerrainData).
**Resultado:** la suite era MUERTA (`assert_that().is_equal_to()`/`is_greater_than()` no existen en gdUnit4) + tenia una expectativa OBSOLETA (4.2 vs 4.8). Reescrita al estandar headless. **10 checks / 0 fallos / EXIT 0 x3**, sonda ROJO **4/4**. BUG-093 registrado y CERRADO. **NO sella 21.8.**

---

## 1. Contexto

Mensaje 13 del director: (a) cerro el frente TerrainData (acepto mi fix del provider M08 `603834b`); (b) escalo mi hallazgo a **BUG-093** (registrar + convertir + contar la familia); (c) proximo frente = widgets M53/M54.

Este log cubre (b). El frente (c) va en su propio log.

## 2. Hallazgo: la suite estaba MUERTA (no "rota")

`game/isla-ancestral/tests/unit/terrain/test_terrain_modifiers.gd` (header: "M156 - Terrenos y Movimiento") usaba:
- `assert_that(speed).is_equal_to(4.2)` (x4)
- `assert_that(speed).is_greater_than(0.0)` (x1)

Verificado en el addon (grep de la FIRMA, no del uso):
- `grep -rn "func is_equal_to" addons/gdUnit4/` -> **0** (los reales: `is_equal(...)`, 12+ implementaciones).
- `grep -rn "func is_greater_than" addons/gdUnit4/` -> **0** (los reales: `is_greater(...)`, 7).

GDScript los PARSEA (EXIT 0 en `--check-only`) pero la llamada MUERE en runtime -> ninguna asercion corre jamas. Es una suite muerta MAS silenciosa que las de `is_instance_of(int)` (esas SI dan parse error). Clase nueva confirmada.

## 3. Alcance de la familia (medido, no estimado)

- `is_equal_to`    : **135 llamadas en 10 archivos** de `tests/` (0 en addons).
- `is_greater_than`: **5 llamadas en 3 archivos**.
- `is_instance_of` : 1 (esta SI da parse error, distinta clase).

=> **140 llamadas muertas en ~11 archivos**. Es **> 10** -> el director autorizo abrirlas como sub-frente (sin tocar `quality.yml`). Las reporto con el conteo; la conversion de cada archivo queda pendiente (cada uno tiene su dominio).

## 4. Segundo defecto: expectativa OBSOLETA (4.2 vs 4.8)

La 1a asercion esperaba `4.2` para `calculate_effective_speed(5.0, 0.8, 0.2)`.

Codigo real (`scripts/terrenos/terrain_modifiers.gd` L13-15):
`return base_speed * maxf(terrain_modifier, 0.1) * (1.0 + bonus)` con `bonus = clampf(equipo, 0.0, 0.5)`.

=> `5.0 * 0.8 * (1 + 0.2)` = **4.8**. El diseno (`03-Diseno.md` sec. 3.1: `base x terreno x (1+equipo)`, cap 50%) confirma 4.8.

El test **consagraba un valor viejo** (patron "la asercion fija el dato equivocado"): al estar muerta, nadie lo noto. Corregido a 4.8 **midiendo** contra codigo+diseno, no copiando la asercion vieja.

## 5. Conversion (estandar headless, metodo 12.1)

`extends SceneTree` + asserts nativos. 2 bloques:
- **A. TerrainModifiers (M156):** formula (4.8), cap 50% (7.5), clamp de equipo negativo (0.1), velocidad > 0.
- **B. TerrainDataProvider (M08):** `get_speed_modifier(0)`=1.0 (cesped), `(1)`=0.6 (barro), `(999)`=1.0 (fallback), tipo float.

Guardia anti-falso-verde de 3 capas: `_fin(letra)` por bloque + piso `CHECKS_MINIMOS := 10` **MEDIDO en verde** + `_summary()` en `call_deferred` separado + watchdog 60 s.

## 6. Verificacion

- `--check-only`: **EXIT 0**.
- Suite: **10 checks / 0 fallos / EXIT 0 x3** (bloques A=4, B=5, +1 del resumen).
- `[M156] Terrenos cargados: 7` -> el provider SI carga los 7 `.tres` headless (`DirAccess.open("res://resources/terrain/")`).
- **Sonda ROJO 4/4** (harness `Obsoletos/raiz-temporales-bug093-2026-10-04/sonda_rojo_bug093.py`):
  - CONTROL (sin mutar): EXIT 0.
  - A. fuente mutada (`terrain_modifiers.gd` -> `return 0.0`): EXIT 1, 4 FAIL.
  - B. aborto de RUNTIME en bloque B (`null.free()`): EXIT 1, nombra `["B"]` (y el piso cae a 5).
  - C. `CHECKS_MINIMOS=999`: EXIT 1.
  - Restauracion byte-exacta verificada por **sha256** (antes == despues).

## 7. Registro

- `DOCUMENTACION/11-BUGS.md`: fila resumen BUG-093 + entrada completa (seccion 7, Resueltos) con la plantilla de la seccion 4, firmada. Severidad **Media**. Modulo: **M156** (por header + contenido; tambien ejercita M08 `TerrainDataProvider`).
- **BUG-093 CERRADO** en el mismo ciclo (la suite pasa y la sonda roja confirma).

## 8. Lo que NO hice (honestidad)

- **NO** toque `quality.yml` (s2 cablea; el director lo excluyo del encargo).
- **NO** barri los otros ~10 archivos con `is_equal_to` (sub-frente autorizado pero PENDIENTE): los reporto con el conteo; cada uno requiere conversion individual con su dominio.
- **NO** sello 21.8 (autor != verificador).
- **NO** toque M53/M54 todavia (frente (c), va en su propio log).

## 9. Trampas nuevas / confirmadas

1. **`is_equal_to` / `is_greater_than` NO existen en gdUnit4**: parsean pero mueren en runtime -> suite MUERTA sin parse error (BUG-091 no la ve). Distinto de `is_instance_of(int)` (parse error). Familia: 140 llamadas / ~11 archivos.
2. **La suite muerta puede consagrar un valor OBSOLETO**: 4.2 vs 4.8 real. Al revivirla hay que MEDIR el valor contra codigo+diseno, no copiar la asercion vieja.

## 10. Huella de push (AGENTS.md 4.3)

- **Push principal:** rango `03bf10d..607d77a` (6 commits: **5 AJENOS** ya commiteados en el arbol local por otros agentes -- `c60b068`+`0e3c20c` M38 BUG-047 v3, `fe7033d` mimo informe 09, `b163274`+`003caab` M39 Tiendas -- **+ 1 PROPIO** `607d77a`). Fast-forward, sin `--force`, `GIT_TERMINAL_PROMPT=0`.
- **Hora:** 2026-10-04 06:49 (UTC) / 03:49 (-0300).
- **Ejecutante:** DeepSeek-V4.1-Flash (WorkBuddy).
- **Contenido propio (`607d77a`):** 5 archivos, 327 inserciones / 20 borrados (test convertido a headless + `11-BUGS.md` + Log 1264 + respuesta 14 + BACKLOG-MASTER).
- **Catch-up que publica esta huella:** esta edicion del log viaja en un push inmediato posterior desde `607d77a`.
- **Verificacion:** `git rev-list --count HEAD..origin/main` = 0 antes del push; `git ls-remote origin refs/heads/main` == `607d77a9f873d33b897855901e550fce8a6b1b82` tras el push.
- **NO se commiteo `CHECKLIST-GLOBAL.md`** (cambios ajenos en vuelo) ni `quality.yml` (s2).
