# Log 808 — M18-BIS: Casa choza ampliada (5×4 m, 1 ambiente) CERRADA

**Modelo:** Hy4 preview
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-10
**Módulo:** M18-BIS (Casas grandes) — primera casa de la progresión de vivienda
**Reserva:** `Logs/reservas/808-WorkBuddy-M18BIS-ChozaAmpliada.txt` (se borra al cerrar este log)

---

## 1. Qué se cerró

El **primer escalón** de la progresión de vivienda del jugador (choza → casa mediana →
casona → mansión). Es la más chica de las 5 casas y la única que cumple el presupuesto
M166 §3.3 **sin invocar la excepción de casas grandes** del plan §6.1.

| Variante | SM_ | Tris | Mats | z_min | GLB |
|---|---|---|---|---|---|
| ALTA  | 15 | 1140 | 12 | 0.0450 | 101 296 B |
| MEDIA | 11 | 1140 | 8  | 0.0450 |  74 964 B |
| BAJA  | 11 |  902 | 4  | 0.0450 |  62 108 B |

Verificación Godot: **3/3** `.glb.import` y **3/3** `.scn` con md5 distinto
(`14bf2a21…` ALTA / `499edae6…` MEDIA / `f631ae37…` BAJA).

---

## 2. 🐛 BUG REAL ENCONTRADO Y CORREGIDO — la chimenea no atravesaba el techo

Este es el hallazgo más importante del log. **El generador afirmaba en su propio
comentario que la chimenea "asoma 64 cm sobre la pendiente", pero la geometría real
no atravesaba nada.**

### Diagnóstico

```python
# ANTES (bug)
est.append(caja('Ec', MAT_piedra_oscura, 0.20, 0.20, 3.20, EST_X, EST_Y, PISO_Z + 0.90))
est.append(caja('Ecp', MAT_acento,       0.30, 0.30, 0.10, EST_X, EST_Y, PISO_Z + 4.05))
```

`PISO_Z = 0.105`, y `caja()` interpreta el último argumento como **centro**, no como base:

| Pieza | Centro | Size Z | Top real |
|---|---|---|---|
| Caño `Ec` | `PISO_Z + 0.90` = 1.005 | 3.20 | **2.605** |
| Sombrerete `Ecp` | `PISO_Z + 4.05` = 4.155 | 0.10 | 4.205 (base 4.105) |

La paja en `Y = +0.60` está en `z = 3.464`. Entonces:

- el caño terminaba en **z = 2.605**, es decir **0.86 m DEBAJO del techo**;
- entre el top del caño (2.605) y la base del sombrerete (4.105) había un **hueco
  de 1.50 m**: el sombrerete flotaba en el aire sin nada que lo sostuviera.

La lección de la casa mediana v8 ("sin chimenea que asome, la casa lee *galpón sin
hogar*") estaba documentada pero **no aplicada**: el comentario decía una cosa y el
código hacía otra.

### Fix

```python
# DESPUÉS (correcto) — mismo patrón que la casa mediana v8
est.append(caja('Ec', MAT_piedra_oscura, 0.20, 0.20, 3.40, EST_X, EST_Y, PISO_Z + 2.30))
```

Centro `PISO_Z + 2.30`, size `3.40` → base `PISO_Z + 0.60`, **top `PISO_Z + 4.00`**, que
empalma exacto con la base del sombrerete (`PISO_Z + 4.00`). Tras el re-asentado
(`dz ≈ +0.045`) el caño va de z ≈ 0.65 a z ≈ 4.05: **asoma 54 cm sobre la pendiente**.

**Cómo se detectó:** comparando el comentario del generador contra la aritmética de
`caja()`, y después confirmado en la hoja de contacto — en la hoja *anterior* al fix
la chimenea no se veía por ningún azimut; en la posterior se ve el caño gris con el
sombrerete rojo claro en az000/az060/az300.

**Lección para la guía (E-100):** en `caja(nombre, mat, sx, sy, sz, cx, cy, cz)` el
`cz` es el **CENTRO** de la caja, no su base. Cuando un elemento deba "llegar hasta"
una cota, hay que verificar `cz + sz/2`, no `cz`. Ver §6.

---

## 3. Pipeline ejecutada (5 etapas, headless 100 %)

El socket MCP de Blender (TCP 127.0.0.1:9876) estuvo **caído** durante toda la
sesión (E-45/E-55): todo se hizo con `blender -b --factory-startup --python …`.

1. **Generación ALTA** — `crear_casa_choza_ampliada_lowpoly.py` → 15 SM_ / 1140 tris / 12 mats.
2. **Captura** — `capturar_casa.py` (nuevo, genérico): 6 orbitales + 4 viñetas interiores.
3. **Variantes** — `generar_variante_headless.py --media` y `--baja` (uno por proceso:
   el lote en bucle se cortaba con SIGTERM).
4. **Auditoría numérica** — `auditar_casa_mediana.py` sobre las 3 variantes.
5. **Export + import** — `EXPORT_FORZAR=1 exportar_godot.py` → `godot --headless --import`.

### Auditoría numérica (E-24 / E-50 / E-91 / E-92)

| | ALTA | MEDIA | BAJA |
|---|---|---|---|
| SM_ | 15 | 11 | 11 |
| z_min (vértices reales, E-24) | 0.0450 | 0.0450 | 0.0450 |
| Huella | 5.28 × 4.29 m | 5.28 × 4.29 m | 5.28 × 4.29 m |
| min(fp) (E-50, > 0.30) | 4.29 ✓ | 4.29 ✓ | 4.29 ✓ |
| Vértices tocando z_min (E-91, ≥ 8) | 72 ✓ | 72 ✓ | 61 ✓ |
| Volumen firmado TOTAL (E-92) | +13.5982 m³ | +13.5982 m³ | +9.6456 m³ |

Todos los volúmenes firmados **positivos** → sin errores de winding (E-92).

---

## 4. Decisiones de diseño

- **D1 — Lenguaje rústico deliberado.** Piso de TIERRA APISONADA (no tablones), zócalo
  de piedra más alto y tosco, paja gruesa (0.09 vs 0.06) y cumbrero 1.15 → pendiente
  **28.9°**. La choza debe leerse como el escalón más pobre de la progresión.
- **D2 — 12 materiales = tope exacto.** Mismo set que la casa mediana v8 para coherencia
  visual entre las 5 casas (`MAT_acento` rojo en cumbrera + casings + sombrerete).
- **D3 — Frontones unidos al techo** (E-70) mediante `join()`, para no pasar de 16 SM_.
- **D4 — Capturador genérico.** Se creó `capturar_casa.py` con un dict `VINETAS` por
  casa. `capturar_casa_mediana.py` era de una sola casa; copiarlo 5× hubiera duplicado
  ~200 líneas por casa.

---

## 5. Observaciones honestas (§21.4)

1. **La viñeta interior "cocina + chimenea" necesitó 8 iteraciones** (v2→v10) y la
   composición final **no incluye el caño ni el sombrerete**: al encuadrar la estantería
   de frente quedan por encima del frame. Se compensa con la captura exterior, donde el
   sombrerete rojo sobre la paja sí se ve. Es una **deuda de encuadre**, no un error de
   geometría.
2. **MEDIA/BAJA tienen 11 mallas, por encima del nominal** (≤8 / ≤6). Causa: los 4 muros
   + la hoja de puerta comparten exactamente la misma lista de materiales (`[madera_clara]`),
   así que el MERGE por material los funde en uno solo. Está amparado por la excepción
   de casas grandes (plan §6.1: ≤16 SM_ por sub-grupo/room), y 11 ≤ 16. **No intenté
   forzarlo** poniendo materiales distintos a los muros sólo para bajar el conteo: eso
   sería maquillar el número y empeorar el look rústico.
3. **La poda de materiales de BAJA se llevó la llama emisiva** (`MAT_Casa_Llama`, 10 caras).
   En BAJA no hay fuego visible. Aceptable para el escalón más bajo de LOD, pero conviene
   que M19 lo sepa si espera un punto de luz en la choza a distancia.
4. **`exportar_godot.py` reescribió 370 GLB** de todo el proyecto (la whitelist `MODULOS`
   está completa). El contenido de los otros módulos es idéntico por md5, así que Godot
   reimporta incrementalmente, pero es ruido. **Deuda técnica:** falta un flag `SOLO_MODULO`.
5. **No verifiqué el asset dentro de una escena de Godot instanciada** — sólo el import.
   El instanciado real (ocultar `SM_Techo_*` al entrar, `SM_Mueble_*` interactivos RF7)
   sigue pendiente y es deuda de M19.

---

## 6. Lección para la guía (E-100)

**Síntoma:** una pieza que "debe atravesar el techo" queda corta y su remate flota,
aunque el comentario del generador afirme lo contrario.

**Causa:** confundir el `cz` de `caja()` (CENTRO de la caja) con su base. El top real
es `cz + sz/2`, no `cz`.

**Fix:** calcular el centro como `(base_deseada + top_deseado) / 2` y el size como
`top - base`. En la choza: base `PISO_Z+0.60`, top `PISO_Z+4.00` → centro
`PISO_Z+2.30`, size `3.40`.

**Verificación:** volumen firmado positivo (E-92) **no** atrapa este bug — una caja
corta sigue siendo un sólodo válido. Lo atrapa comparar la cota declarada en el
comentario contra `cz + sz/2`, o mirar la hoja de contacto.

**Aplica a:** cualquier elemento vertical que deba empalmar con otro (caños, postes,
columnas, mástiles, patas).

**Relacionado:** E-24 (medir sobre vértices reales), E-94 (`view_layer.update()` antes
de medir), E-92 (volumen firmado).

---

## 7. Artefactos

**Scripts (nuevos/modificados):**
- `18-Casas/scripts/crear_casa_choza_ampliada_lowpoly.py` — generador (+fix chimenea)
- `18-Casas/scripts/capturar_casa.py` — capturador genérico parametrizado por casa

**Blends:** `casa_choza_ampliada_lowpoly.blend` (+ `_media`, `_baja`)

**Capturas:** 30 PNG (6 orbitales + 4 interiores × 3 variantes) + 3 hojas JPG

**Godot:**
- `assets/3d/{alta,media,baja}/18-Casas_casa_choza_ampliada.glb`
- 3 × `.glb.import`, 3 × `.scn` en `.godot/imported/`

---

## 8. Firma

**Modelo:** Hy4 preview
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-10
**Estado:** M18-BIS choza ampliada **CERRADA**. Pendientes del módulo: casona (10×8),
mansión (14×10), casa de vecino.
