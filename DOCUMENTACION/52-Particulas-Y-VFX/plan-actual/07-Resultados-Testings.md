**Modelo:** DeepSeek-V4.1-Flash / WorkBuddy
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-13

# 07-Resultados-Testings.md — Módulo 52: Partículas y VFX (iter. 5)

## 1. Suites ejecutadas

| Suite | Archivo | Resultado | Corridas |
|-------|---------|-----------|----------|
| Pool + runtime (iter. 5) | `game/isla-ancestral/scripts/particles/test_vfx_pool_m52.gd` | **89 checks · 0 fallos** | 3/3 determinista |
| Catálogo (heredado) | `.../test_vfx_catalog_headless.gd` | **4 checks · 0 fallos** | 1 |
| Factory (heredado) | `.../test_vfx_factory_headless.gd` | **8 checks · 0 fallos** | 1 |
| Director (heredado) | `.../test_vfx_director_headless.gd` | **4 checks · 0 fallos** | 1 |
| **Total M52** | — | **105 checks · 0 fallos** | — |
| `SCRIPT ERROR` | — | **0** | 3 |

```
=== Resumen M52: 89 checks, 0 fallos ===
```

Salida real (extracto; los autoloads inundan stdout, por eso se filtra):

```
=== [M52] Test de VfxPool + runtime (iter. 5) ===
--- A. VfxFactory: creación real de emisores ---
  [OK] draw_pass_1 asignado (NO 'mesh')
  [OK] 'mesh' ya no existe en GPUParticles3D
  [OK] crear() devuelve un nodo (antes null)
  [OK] crear() deja emitiendo
--- B. Determinismo: semillas estables ---
  [OK] misma entrada -> misma semilla
  [OK] secuencia reproducible
  [OK] validador rechaza repetidas consecutivas
--- C. VfxPool: préstamo, liberación y reuso ---
  [OK] precalentar crea 3 emisores
  [OK] reuso: creados sigue 3
  [OK] semilla fijada (determinismo)
  [OK] motivo del descarte registrado
--- D. Límites: emisores y partículas ---
  [OK] no se superan los 2 emisores
  [OK] se recicló el más antiguo
  [OK] el reciclado se reutiliza (c == a)
  [OK] tope de partículas respetado
--- E. VfxDirector: dispatch real con pool ---
  [OK] disparar CREA el emisor en el contenedor
  [OK] actualizar libera emisores agotados
  [OK] finalizar vacía el pool
--- F. VFX-SKIP: señal, motivos y log ---
  [OK] motivo 'sin cupo de emisores'
  [OK] el director cuenta el skip (VFX-SKIP)
  [OK] vaciar resetea motivos
  [OK] bloque A completó (marcador _fin)
  ... (6 marcadores)
=== Resumen M52: 89 checks, 0 fallos ===
```

## 2. Cobertura por bloque

| Bloque | Tema | Checks |
|--------|------|--------|
| A | Runtime de la factory (`nuevo_emisor`, `crear`, color) — **antes roto** | 14 |
| B | Determinismo (`semilla_de`, `validar_semillas`) | 9 |
| C | Pool: préstamo, liberación, reuso, motivos | 20 |
| D | Límites: emisores y partículas con reciclado | 12 |
| E | Director: dispatch real, vida de one-shot, `finalizar` | 14 |
| F | Log `VFX-SKIP`: señal, motivos y wiring del director | 14 |
| — | Marcadores `_fin` (anti-falso-verde) | 6 |
| **Total** | | **89** |

## 3. Bug real encontrado y corregido

| Bug | Síntoma | Causa | Arreglo |
|---|---|---|---|
| `VfxFactory.crear()` no creaba nada | `crear()` devolvía `null`; **ningún VFX se instanciaba** aunque los 3 tests puros daban verde | Asignaba `GPUParticles3D.mesh`, **eliminada en Godot 4.3** (hoy `draw_pass_1`); el error abortaba la función en silencio | `gp.draw_pass_1 = _quad()` |
| Semilla no determinista | `seed` cambiaba en cada `restart()` (medido `2694543342 → 2659173778`) | `restart()` **re-aleatoriza** `seed` | Asignar `gp.seed = semilla` **después** de `restart()` |

## 4. Observaciones

- El test **instancia nodos reales** (`GPUParticles3D`, `Node3D`) y usa
  `await process_frame`: en headless eso deja avanzar el boot de los autoloads,
  por eso la salida cruda es ruidosa. No afecta al resultado.
- `await process_frame` es necesario para que `VfxDirector._ready()` (que carga
  el catálogo) se ejecute antes de las comprobaciones.
- El marcador `_fin()` por bloque es la defensa contra el **falso verde**: un
  `SCRIPT ERROR` aborta la función en silencio y sin el marcador el resumen
  imprimiría "0 fallos" con un bloque entero salteado.
- Se regeneraron los `.uid` de `vfx_pool.gd` y `test_vfx_pool_m52.gd`
  (`--headless --path … --editor --quit`) y se re-verificó la suite tras el scan.

## 5. Pendiente de verificación (no cubierto)

- Calibración **visual** (amplitudes, colores, densidades): requiere visión
  fiable, no disponible en este host.
- `Reduce Motion`/`vfx_quality` (M58), loops con culling, LOD por distancia,
  presupuesto por preset (M90), `vfx_trigger.gd`, atmosféricos, UI 2D:
  **no implementados** → sin tests.
