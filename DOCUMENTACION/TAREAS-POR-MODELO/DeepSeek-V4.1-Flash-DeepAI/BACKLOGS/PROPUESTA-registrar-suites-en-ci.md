# Propuesta: registrar en CI las suites que hoy no corre nadie

**Modelo:** Deepseek V4.1 Flash-DeepAI
**Plataforma:** DeepAI
**Fecha:** 2026-11-25 15:26

Estado: **propuesta, no aplicada.** `quality.yml` tiene diff ajeno sin commitear y el director
pidió decidir él qué se agrega (msg 005, "KnownIssue: cuando el fundador decida ampliar CI,
lo implemento"). Si dice que sí, esto es copiar y pegar.

## 1. Qué agregar y por qué

`quality.yml` corre `suite --script <ruta>`; el job GdUnit4 de `testing.yml` corre `-a` sobre
`tests/unit/{foto,inventario,ui,debug}`. Entre los dos quedan afuera:

- **19 suites SceneTree de `tests/unit/**`** (el job GdUnit4 no las colecta; ver Log 2456).
- **8 suites M17 nuevas** (`tests/test_m17_*.gd`), incluida la de HUD (22/0) y almacenamiento.
- **3 suites de crucero** (`tests/integration/test_crucero_viaje.gd`, `tests/unit/test_crucero_*.gd`).
- **M20 amistad** (`tests/test_m20_amistad_cobertura.gd`, 29/0).

Medido hoy 15:24: de las **18 suites tocadas hoy**, las 18 están fuera de CI. Justo las que la
flota acaba de escribir son las que el gate no mira.

## 2. Bloque listo para pegar

No hace falta un step nuevo ni un runner nuevo: `quality.yml` ya define, dentro de su step de
suites, la función de shell `suite()` (línea ~195) que corre `godot --headless "$@"`, cuenta la
suite, emite `::error::FALLO <script>` si falla y marca `FAIL=1`. El working dir del step es
`game/isla-ancestral`, y las rutas van **sin** `res://` (como `suite --script scripts/saving/
validate_save.gd`). Registrar = pegar 8 líneas más en ese mismo step:

```yaml
          # Suites SceneTree que ningun otro job ejecuta (2026-11-25, Log 2456/2460).
          # Todas verdes al registrarse; si alguna se pone roja, es senal real.
          suite --script tests/test_m17_almacenamiento.gd
          suite --script tests/test_m17_atomicidad_escritura.gd
          suite --script tests/test_m17_cache_preview.gd
          suite --script tests/test_m17_contenido_piezas.gd
          suite --script tests/test_m17_hud_categorias.gd
          suite --script tests/test_m17_materiales_compartidos.gd
          suite --script tests/test_m17_terreno_cargado.gd
          suite --script tests/test_m20_amistad_cobertura.gd
```

**Ojo con el costo:** cada `suite` corre en el mismo job, así que 8 suites nuevas suman ~1-2 min.
Las 19 de `tests/unit/**` suman 204 s medidos: si se agregan las 27, el job crece ~5 min.

Para las 19 de `tests/unit/**` conviene un lazo que excluya las 4 GdUnit4 (por cabecera), o
listarlas: son las que el runner `run_tests.py --module tests/unit` ya corre en 204 s.

## 3. Alternativa sin tocar `quality.yml`

Un job nuevo `suite-sc-extra` en `testing.yml` que corra:

```yaml
      - run: python tools/ci/run_tests.py --module tests/ --out out/tests-extra.json
```

Cubre 68 suites en ~17 min y **ya está medido** (Log 2460: 67 OK, 1 flaky por contención).
Ventaja: no hay lista que mantener a mano; desventaja: 17 min de CI.

## 4. Costo real medido

| Lote | Suites | Tiempo |
|---|---|---|
| `tests/unit/**` (SceneTree) | 19 | 204 s |
| `tests/**` completo | 68 | 1050 s (~17 min) |
| workflow actual | 104 | ~10-20 min según runner |

## 5. Riesgo

Ninguno de rotura: las 59 suites auditadas hoy están verdes. El único riesgo es tiempo de CI y
que alguna quede flaky por contención (mitigado con el reintento único de `run_tests.py`).