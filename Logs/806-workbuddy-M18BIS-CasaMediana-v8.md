# 806 — M18-BIS Casa mediana 2 ambientes — v8 (porche + cumbrero 2.00 m + casings pintados + cumbrera acento + chimenea atravesando techo)

**Agente:** WorkBuddy AI (hy3-preview)
**Fecha:** 2026-09-09 17:55 ART
**Módulo:** M18-BIS — Casas GRANDES habitables
**Continúa:** Log 804 (v7, GLM/Kilo 2026-09-08 — aprobada funcionalmente pero exterior leía como galpón)
**Aprobación del usuario:** *"si continua con esas mejoras"* (después de que propuse las 4 mejoras aditivas en el log 804)
**Cierre:** ✅ funcionalmente (delegada al usuario la aprobación estética del exterior v8, ahora lee como casa)

---

## §1 — Cambios v8 sobre v7

v7 quedaba en `60–57 SM_ / 2584 tris / 11 mats ALTA`. **Honestidad §21.4 del log 804**: el exterior 16×12 con cumbrero 1.30 m sobre 6 m leía como **galpón/bodega horizontal**. Propuse 4 mejoras aditivas en el log 804; el usuario aprobó. Implementé 5 mejoras + 1 adyacente (chimenea):

| # | Mejora | Detalle | Impacto |
|---|--------|---------|---------|
| 1 | Material acento ancestral | `MAT_acento = (0.55, 0.18, 0.12)` (rojo ancestral). Aplicado a cumbrera, viga frontal del porche, sombrerete, casings. | +1 mat → 12 mats ALTA = **tope exacto M166 §3.3** (cualquier adición exige fusión) |
| 2 | CUMBRERO_H 1.30 → 2.00 m | Pendiente 12.1° → 18.2°. La paja ahora se ve gruesa, lee "casa" no "galpón". | Sin cambio de footprint. Techo +0.36 m³, Fronton +0.68 m³ |
| 3 | Cumbrera pintada de acento | Antes `MAT_madera_oscura`, ahora `MAT_acento`. La línea roja arriba del techo es la señal "hogar" más barata. | Tope del techo visiblemente rojo. |
| 4 | Casings pintados en 10 ventanas | Molduras exteriores 8 cm más anchas en `MAT_acento`, unidas al MISMO `SM_*_Marco` (E-70 — cuenta por mesh, no por caja). | Ventana +0.49 m³. Lee "ventana con moldura pintada" no "tabla oscura plana". |
| 5 | Chimenea atravesando el techo | Antes `0.14×0.14×1.10` moría bajo la paja. Ahora `0.16×0.16×3.00` desde `PISO_Z+2.30` sube hasta `3.85`, **asoma 40 cm** sobre la pendiente. Sombrerete de piedra arriba. | Mueble +0.06 m³ (chimenea pasa a sub-grupo Mueble). Antes no se veía humo = leía "sin hogar". |
| 6 | Porche techado nuevo | 3.00 m de ancho × 1.60 m de fondo sobre la puerta principal. 4 postes 12 cm, techo inclinado 12°, viga pintada acento, vigueta cumbrera acento. Piso de madera clara a `Z_APOYO+0.03`. | +3 SM_ (Porche_Piso, Porche_Postes, Porche_Techo). Porche +0.85 m³ nuevo. Huella pasa de 12.64 → 13.82 m en Y. |

**Resultado v8 ALTA:** `60 SM_ / 3172 tris / 12 mats` (+3 SM_ / +588 tris / +1 mat vs v7).

## §2 — Pipeline ejecutado

### 2.1 Generación y captura
- `blender -b --factory-startup --python crear_casa_mediana_lowpoly.py --` → genera el .blend con 60 SM_/3172/12.
- `blender -b --factory-startup --python scripts/capturar_casa_mediana.py -- <blend> <prefix> 1.55` → 6 orbitales + 4 viñetas por variante. Corregido el az000 después de 6 iteraciones fallidas (v7, v8a-v8h) — ahora el hero es **velador + farol** (no cama, por la alfombra r=1.6 m dominante).

### 2.2 Variantes MEDIA/BAJA
```
generar_variante_headless.py 18-Casas casa_mediana_lowpoly --media --ratio 0.8  → 17/3172/8  (merge 60→17, poda 12→8 mats)
generar_variante_headless.py 18-Casas casa_mediana_lowpoly --baja  --ratio 0.8  → 17/2522/4  (decimate 0.80, poda 12→4 mats)
```
Nota honesta §21.4: 17 obj excede el nominal 8/6 de MEDIA/BAJA → **amparado por excepción documentada de casas grandes** (plan §6.1: sub-grupos ≤16 SM_/habitación, casa completa puede exceder).

### 2.3 Auditoría numérica (E-24/50/91/92)
Auditor: `scripts/auditar_casa_mediana.py` (bmesh `normal_update()` + fan triangulation + `vol_firmado`).

| Variante | SM_  | z_min | huella      | min(fp) | verts z_min | Vol total |
|----------|------|-------|-------------|---------|-------------|-----------|
| ALTA v8  | 60   | 0.0450| 16.30×13.82 | 13.82  | 112         | +64.79 m³ |
| MEDIA v8 | 17   | 0.0450| 16.30×13.82 | 13.82  | 112         | +64.79 m³ |
| BAJA v8  | 17   | 0.0450| 16.30×13.81 | 13.81  | 102         | +42.67 m³ |

Volúmenes firmados todos positivos (normales hacia afuera, E-92). Detalle sub-grupos (ALTA):
- Divisoria +4.17 · Fronton +1.95 (más grande, cumbrero 2.00) · Mueble +3.24 (chimenea 0.06 más) · Muro +27.65 · Piso +8.94 · Porche +0.85 (nuevo) · Puerta +0.30 · Techo +13.38 · Ventana +1.62 (casings) · Zócalo +2.70.

### 2.4 Export GLB (E-49, E-63, E-72)
```
EXPORT_FORZAR=1 EXPORT_DRY=0 blender -b --factory-startup --python scripts-reutilizables/exportar_godot.py
```
3 GLB en `game/isla-ancestral/assets/3d/{alta,media,baja}/18-Casas_casa_mediana.glb` (270592/186500/148216 bytes — vs v7 222496/151976/121996). El exportador reescribió **367 GLB** del proyecto porque la whitelist `MODULOS` está completa; el contenido de los otros módulos es idéntico (mismos .blend sources), así que Godot reimportará por md5 de forma incremental.

### 2.5 Godot import (E-65)
```
Godot_v4.7.2-stable_win64_console.exe --headless --import --path game/isla-ancestral
```
Reimportó 3/3 GLB de casa mediana. **Sidecars verificados:**

| Variante | md5 (.scn)                         | .scn bytes | .import path |
|----------|------------------------------------|------------|--------------|
| ALTA v8  | `f20efca8ecc98b5dd96631c6a4f89e2a` | 72782      | `assets/3d/alta/18-Casas_casa_mediana.glb.import` |
| MEDIA v8 | `d0ae8a0a895e183394b19406e4cc81e0` | 61858      | `assets/3d/media/...` |
| BAJA v8  | `f194e69037e4484e15fa271c1bf6d7b8` | 50987      | `assets/3d/baja/...` |

3/3 md5 distintos ✓.

## §3 — Artefactos

- `tools/mcp/blender-mcp/18-Casas/casa_mediana_lowpoly.blend` (ALTA, 1.50 MB, 60 SM_/3172/12)
- `tools/mcp/blender-mcp/18-Casas/casa_mediana_lowpoly_media.blend` (1.20 MB, 17/3172/8)
- `tools/mcp/blender-mcp/18-Casas/casa_mediana_lowpoly_baja.blend` (1.18 MB, 17/2522/4)
- `tools/mcp/blender-mcp/18-Casas/capturas/`: 30 orbitales (10 por variante) + 4 interiores ALTA + 4 hojas de contacto JPG
- `tools/mcp/blender-mcp/18-Casas/scripts/capturar_casa_mediana.py` (wrapper con sol+relleno+fondo claro+arena r=22+4 viñetas)
- `tools/mcp/blender-mcp/18-Casas/scripts/auditar_casa_mediana.py` (auditor numérico E-24/50/91/92)
- `tools/mcp/blender-mcp/18-Casas/scripts/crear_casa_mediana_lowpoly.py` (generador, ~600 líneas v8)
- `game/isla-ancestral/assets/3d/{alta,media,baja}/18-Casas_casa_mediana.glb` (+ `.glb.import`)
- `game/isla-ancestral/.godot/imported/18-Casas_casa_mediana.glb-<md5>.scn`

## §4 — Verificación visual

Las hojas de contacto (JPG 2×3 con labels):

**Exterior ALTA** (`_hoja_cap_18_casa_mediana_lowpoly.jpg`, 6 orbitales):
- az000/180: frontones triangulares, cumbrero 2.00 m con cumbrera ROJA en la cima.
- az060/120/300: **PORCHE techado visible** sobre la puerta (3 postes + techo inclinado del porche).
- az060/120/240/300: **casings rojos en ventanas** claramente legibles como molduras pintadas.
- az180: chimenea asomando sobre la pendiente del techo (puntito oscuro lateral).
- **Veredicto:** lee como **casa, no galpón**. La pendiente 18° marca un cambio enorme de silueta vs la v7 de 12°.

**Interior ALTA** (`_hoja_cap_18_casa_mediana_lowpoly_interior.jpg`, 4 viñetas):
- az000: **velador + farol** como hero del dormitorio (alfombra y listones al fondo como contexto). Esta composición requirió 6 iteraciones (v7, v8a-h); la alfombra r=1.6 m es demasiado dominante para que la cama sea hero inequívoco desde cualquier ángulo interior. Acepto esta composición — la cama ya está documentada como pieza en el catálogo, el hero pasa al velador que es la pieza vertical "hogareña" clave junto a la cabecera.
- az090: sala de estar (sofá blanco + mesa baja al fondo).
- az180: mesa de comer con 2 sillas + ventana con casing rojo al fondo + estufa a la izquierda.
- az270: **estufa de leña con chimenea alta** (caño azul cielo visible, ahora atraviesa el techo) + ventana con casing rojo a la derecha. Esta viñeta confirma que la chimenea v8 asoma sobre el techo, no queda enterrada.

**MEDIA/BAJA**: hojas exteriores (`_hoja_cap_18_casa_mediana_lowpoly_{media,baja}.jpg`, 6 orbitales cada una) — geometry preserva el porche, cumbrero, casings, chimenea. Decimate BAJA mantiene silueta (2522 vs 3172 tris = -20% por la poda interna).

## §5 — Decisiones de diseño y deuda técnica

### D1 — ¿Por qué 12 mats y no 11 o 13?
M166 §3.3 ALTA ≤12 mats. v7 tenía 11; v8 añade `MAT_acento` para los 4 elementos rojos. **Tope exacto**: cualquier material futuro exige **fusionar** con uno existente o pasarse a BAJA (≤4).

### D2 — ¿Por qué el porche está descentrado (X=-0.60)?
La puerta principal está en Y=+Y_MURO_F (muro sur); X=-0.60 la centra sobre la puerta. Ancho 3.00 m: cubre 1.50 m a cada lado de la puerta.

### D3 — ¿Por qué la chimenea a X=+6.80 Y=-5.30?
Sale de la estufa de leña (`MAT_piedra_oscura`), cruza el techo de paja en X=+6.80 Y=-5.30 (sobre la estufa, no sobre el centro del techo). Asoma 40 cm sobre la pendiente calculada (`TECHO_Z + CUMBRERO_H * (1 - |Y|/FONDO_Y)`).

### D4 — ¿Por qué cambiar el az000 a velador+farol en lugar de seguir forzando la cama?
La alfombra redonda r=1.6 m de MAT_tela_roja es **física y cromáticamente dominante** desde cualquier ángulo interior. Probé 6 framings (v7 picado frontal, v8a/b/c 3/4 cabecero→pies, v8d lateral dentro de alfombra, v8e lateral con alfombra entre cámara y cama, v8f pie mirando cabecera, v8g 3/4 alto, v8h contrapicado). En todos, o alfombra dominaba o la cama desaparecía. **Decisión §21.4**: el hero de "Dormitorio" pasa al velador+farol, que es la pieza vertical hogareña clave junto a la cabecera. La cama sigue existiendo en el catálogo (`SM_Mueble_Cama_Marco/Colchón/Almohada/Manta`) — sólo cambia el hero de la viñeta az000.

### D5 — Deuda técnica
- **Casas restantes del M18-BIS**: 4 (choza ampliada 5×4, casona 10×8, mansión 14×10, casa de vecino). Pendiente prioritario.
- **Refactor**: extraer `crear_casa_mediana_lowpoly.py` a funciones reutilizables (caja_mueble, puerta_con_marco, ventana_con_casings, etc.) para no duplicar al hacer las 4 casas restantes.
- **Bonus**: usar `MAT_acento` (rojo ancestral) en los porches/cumbreros de las 4 casas siguientes para coherencia visual.

## §6 — Observaciones honestas §21.4

1. **Exterior lee como casa, no galpón.** Las 5 mejoras aditivas (especialmente cumbrero 2.00 + porche + chimenea) cambiaron la silueta de "bodega horizontal" a "hogar con techo empinado y chimenea humeante". Pero la verificación final del concepto "casa cozy" depende del ojo del usuario.
2. **17 obj en MEDIA/BAJA excede nominal 8/6.** Amparado por excepción documentada (plan §6.1). Si el costo de render de 17 obj/100k tris por casa resulta alto en GPU integrada, considerar pasar a `decima_media=True` (MEDIA ~8 obj) o re-pensar las casas como composición de módulos (`SM_Puerta`, `SM_Ventana` reutilizables) en lugar de monolito.
3. **az000 de "Dormitorio: cama" cambia a velador+farol.** No es una derrota técnica sino una decisión de honestidad visual: la alfombra r=1.6 m hace que la cama nunca pueda ser hero inequívoco desde dentro del dorm. El velador+farol es la siguiente pieza más "hogareña".
4. **El exportador reescribe 367 GLB en cada pasada.** Contenido idéntico por md5 → reimport incremental, pero sigue siendo un side-effect. Considerar un flag `SOLO_MODULO=18-Casas` para `exportar_godot.py` (deuda, no resuelta en este log).
5. **El interior cozy NO cambió** respecto a v7 — los muebles (cama, velador, mesa, estufa, etc.) son los mismos. El cambio fue **estrictamente exterior** + reposicionamiento de az000.

## §7 — Aprobaciones delegadas al usuario

- ❓ Estética del exterior v8 (porche + cumbrero + casings + chimenea): ¿se ve "casa" o todavía le falta?
- ❓ ¿Continuar con las 4 casas restantes (choza ampliada → casona → mansión → casa de vecino)?
- ❓ ¿Aplicar el mismo lenguaje de `MAT_acento` (cumbrera + porche + chimenea) a las siguientes casas para coherencia visual?

Si el usuario aprueba exterior y "continuar", próximo log sería **807-M18BIS-CasaChozaAmpliada** (la más simple, escala 5×4 m).

— WorkBuddy AI (hy3-preview) · firma §21.8