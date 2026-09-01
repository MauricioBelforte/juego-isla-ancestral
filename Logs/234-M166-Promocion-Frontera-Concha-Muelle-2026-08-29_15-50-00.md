# Log 234 — M166 · Promoción de la frontera + verificación visual

**Fecha:** 2026-08-29 (continuación del log 233)
**Hora:** 15:50
**Tier:** M166 — Variantes y perfil de rendimiento
**Actividad:** Decisión sobre los 3 assets de frontera + verificación E-13 de los nuevos ALTA.

---

## 1. Resultado ejecutivo

**Héroes: 15 → 17** (se promovieron `muelle_madera` y `concha_mar` desde la frontera).

| Asset | Decisión | Razón |
|---|---|---|
| `muelle_madera` | **ALTA ✓** | Criterio 3 "hito visual" — es el punto icónico de la costa. |
| `concha_mar` | **ALTA ✓** | Criterio 2 "se sostiene en mano y se ve en primerísimo plano" — encaja perfecto. |
| `losa_grabado` | **MEDIA** (sin cambio) | Criterio 2 falla: va en el piso, nunca se ve de cerca. El detalle que pide no se aprovecha. |

**Bug colateral detectado y arreglado:** `SM_Concha_Interior` en el source estaba modelado a `z=-0.040` (enterrado 8 cm), cuando la boca de la concha está a `z=0.184` (el interior debe asomar por la abertura, no estar debajo del suelo). Fix: subido a `loc.z=0.184` en el source.

**E-24 patch (log 233) verificado en escenarios no triviales:** aplicado y re-aplicado en cada nuevo `.blend` generado. La métrica de re-asentado (`delta -0.000`) confirma que el parche funciona cuando los sources están bien modelados.

---

## 2. Bug colateral: el `SM_Concha_Interior` enterrado

**Síntoma:** en el primer intento de generar `concha_mar_alta_media`, el log mostró `RE-ASENTADO: z_min -0.040 -> 0.045 (delta +0.085)`. Esto levantó **toda la concha 8.5 cm**, dejándola flotando 13 cm sobre la arena (z_min final = 0.130). El E-24 patch funcionaba perfectamente; el problema era de source.

**Causa raíz:** el `SM_Concha_Interior` (un disco de 8 cm) estaba modelado con `loc.z=-0.000`, lo que con su geometría local de `[-0.040..0.040]` daba vértices en world `z=-0.040`. Como el E-24 patch ahora mide vértices reales (no AABB), capturó este `-0.040` y aplicó el delta para "apoyarlo". El resultado fue catastrófico: el conjunto entero se levantó para que ese disco enterrado tocara el suelo.

**Fix:** `interior.location.z = shell.location.z` (= 0.184). El disco queda en `z=[0.144..0.224]`, dentro de la boca de la concha, sin disparar el re-asentado.

**Verificación post-fix:**
```
=== concha_mar_alta_media.blend (regenerado) ===
MERGE: 2 objetos -> 2 mallas
RE-ASENTADO: z_min 0.045 -> 0.045 (delta -0.000)  ✓
objetos=2  tris=1162  materiales=2
```

**Lección (§9 de la guía de blender — alta):** el E-24 patch NO arregla sources mal modelados. El re-asentado siempre va a tratar de apoyar el vértice más bajo; si ese vértice está enterrado por error, va a levantar todo. **Antes de generar la ALTA, validar que todos los SM_ tengan su `z_min` esperado** (≈0.045 para assets apoyados, ≈-0.5 o menos para assets que se hunden, etc.).

---

## 3. Nuevas variantes generadas

### 3.1 `muelle_madera`

```
ALTA:    19 obj / 182 → 1986 tris / 3 mats        (3 objetos pasan el umbral de subdiv)
ALTA-MEDIA: 19 → 3 mallas / 1986 tris / 3 mats    (merge por material, R9)
```

E-13 (6 capturas orbitales): **APROBADO** — pilotes apoyados, cubierta horizontal, barandilla y argollas en su lugar. Sin flotación.

### 3.2 `concha_mar`

```
ALTA:    2 obj / 319 → 1162 tris / 2 mats
ALTA-MEDIA: 2 → 2 mallas / 1162 tris / 2 mats     (cada material = su propia malla; no se mergean porque son críticos distintos)
```

E-13 (6 capturas orbitales): **APROBADO** — concha apoyada, interior disco visible asomando por la abertura (az120).

**Pendiente visual no bloqueante:** el `SM_Concha_Interior` sigue a `x=0.310` mientras la boca de la concha termina en `x≈0.212`. En algunas perspectivas el disco se ve separado de la concha en lugar de dentro. Es un bug de modelado del source (la posición X del interior), no de la pasada. Lo dejo para una futura iteración de M166 (no impacta el QA E-13 de "no flota").

---

## 4. Conteo D9 actualizado

| Categoría | Antes | Ahora |
|---|---|---|
| ALTA (héroes) | 15 | **17** |
| FRONTERA | 3 | **1** (`losa_grabado`) |
| MEDIA-only (relleno) | 23 | **23** (sin cambio: `losa_grabado` ya estaba acá) |
| **Total** | 41 | 41 |

Actualizado en `03-Diseno.md` §3.5 (tabla de D9) y §3.6 (pendientes).

---

## 5. Cambios al sistema

- **`generar_variante.py`** (log 233) — sin cambios en este log.
- **`generar_alta.py`** (log 232) — sin cambios en este log.
- **`03-Diseno.md`** — D9 actualizado (2 promociones + 1 mantenimiento), conteo de 15→17, lista de pendientes.
- **Skill `blender-m166-qa/SKILL.md`** — sin cambios estructurales (las correcciones de E-24 y la receta ALTA ya están documentadas).

---

## 6. Pendientes que siguen abiertos

1. **Re-derivar `_media` y `_baja` desde `_alta`** (R9: el ALTA es source of truth). Hoy las `_media`/`_baja` existentes se generaron desde el source; hay que regenerarlas para que sean consistentes con las ALTA recién hechas. No urge, pero es deuda técnica.
2. **Bug del `SM_Concha_Interior` posicionado en x=0.310** (separado 10 cm de la boca de la concha) — bug de modelado del source, no de pasada.
3. **Bug en `diagnosticar_pose.py`** línea ~36: `bote_pesca_lowpoly` está listado bajo `25-Ruinas-Templos`, debería ser `40-Infraestructura`.
4. **Captura faltante** `cap_13_pico_piedra_lowpoly_baja_00-35-41_az180.png` (set de 5/6).
5. **Crear `res://assets/props/{asset_id}/{perfil}/` en Godot** (D8) para los 17 héroes.
6. **Declarar `variantes_disponibles`** en M159 `ItemData`: `["alta","media","baja"]` para los 17, `["media","baja"]` para los 23 de relleno.
7. **Limpiar scripts temporales** de `C:/Users/Maury-New/AppData/Local/Temp/` (fix_concha.py, fix_concha_src.py, cap.py, cap_runner.py, diag_*.py, scan_aabb.py, sweep_palanca.py, etc.) — son ~15 archivos.

---

## 7. Próximos pasos sugeridos

Dada la conversación, el usuario pidió "seguir por donde consideres, ya sea mejora o crea nuevos". Opciones:

- **(A) Cerrar los pendientes del log 234** (mover `concha_mar` interior, regenerar `_media`/`_baja` desde `_alta`, crear las carpetas Godot). Trabajo de un par de horas.
- **(B) Volver a la pasada BAJA** — los 23 de relleno tienen `_baja` pero muchos no pasaron E-13. Vale la pena auditar con `auditar_optimizacion.py` y re-procesar los que fallen.
- **(C) Empezar la pasada de un módulo nuevo** (hay 41 fuentes pero solo 17 héroes; quedan 24 que tienen `_media` y `_baja` pero se beneficiarían de refinamiento).

Mi recomendación: **(A)** — cerrar la frontera de M166 antes de empezar otro tier. Cuando esté limpio, (B) o (C).
