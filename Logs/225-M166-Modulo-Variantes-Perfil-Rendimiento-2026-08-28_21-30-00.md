# Log 225 — M166 Módulo Variantes y Perfil de Rendimiento (cierre + iteración)

**Fecha:** 2026-08-28 21:30 ART · **Módulo:** 166 · **Agente:** MiniMax-M3

## Resumen

Cierre del módulo M166 (Variantes y Perfil de Rendimiento) tras iteración correctiva sobre el primer piloto. La idea original del usuario fue "2 versiones, liviana y detallada"; la implementación correcta resultó en 3 perfiles (ALTA / MEDIA / BAJA) derivados automáticamente de un único .blend source.

## Decisión de fondo (respuesta a "que te parece?")

La idea del usuario era correcta en **espíritu** pero el **eje** estaba mal puesto:

- **NO** "menos triángulos". 784 triángulos es nada (un personaje AAA = 50k-150k, frame budget Switch ~500k).
- **SÍ** "menos draw calls". 33 objetos por cofre × 50 cofres = 1.650 draw calls, que saturan el render thread de Godot 4 antes de tocar la GPU.
- **NO** modelar dos versiones a mano. 117 assets × 2 = 234 piezas que se desincronizan inevitablemente.
- **SÍ** una fuente de verdad (ALTA) + 2 variantes derivadas por merge por material + poda/decimate opcionales.

## Lo que se construyó

### Scripts nuevos en `tools/mcp/blender-mcp/scripts-reutilizables/`

1. **`stats_asset.py`** — Mide objetos / triángulos / vértices / materiales de un asset y lo compara con la tabla de presupuesto. Imprime verdict OK/NO por perfil.

2. **`generar_variante.py`** — El corazón del módulo. Pipeline de 4 fases:
   - FASE 0: PODA (solo BAJA, ANTES del merge, por umbral de bbox 1e-4 m³)
   - FASE 1: MERGE por material (MEDIA y BAJA; preserva material_index por cara)
   - FASE 2: DECIMATE ratio 0.7 (solo BAJA, solo sobre mallas fundidas, NO sobre críticas)
   - FASE 3: shade_flat + re-asentado a z_min = 0.045 (E-12)
   - FASE 4: guardado con E-21 (.blend@)

3. **`abrir_blend.py`** — Helper para que `stats_asset` y `capturar_angulos` operen sobre el .blend correcto vía el socket MCP.

### Script modificado

- **`capturar_angulos.py`** — Activación de `eevee.use_ssr = True`, `use_ssr_refraction = True`, `use_raytracing = True` antes de cada `bpy.ops.render.render()` (E-20 refinado). La activación vive en el script de captura, NO en el .blend del asset, así no se contamina.

## Piloto: cofre ancestral (M25)

Datos verificados con `stats_asset.py`:

| Perfil | Objetos (draw calls) | Triángulos | Materiales | z_min |
|--------|----------------------|------------|------------|-------|
| ALTA   | 33                   | 784        | 6          | 0.045 |
| MEDIA  | 15                   | 784        | 6          | 0.045 |
| BAJA   | 14                   | 681        | 6          | 0.045 |

**Reducción real de draw calls**: 33 → 14 (BAJA), 33 → 15 (MEDIA). El cofre MEDIO es visualmente indistinguible del ALTA; el BAJA pierde solo remaches decorativos y glifos (poda), mantiene cerradura, gema, costillas, asas, tirador.

Capturas de QA en `tools/mcp/blender-mcp/25-Ruinas-Templos/capturas/`:
- `cap_25_cofre_ALTA_21-00-00_az{000..300}.png` (ALTA, con SSR)
- `cap_25_cofre_MEDIA_21-30-00_az{000..300}.png` (MEDIA regenerado con críticas protegidas)
- `cap_25_cofre_BAJA_21-30-00_az{000..300}.png` (BAJA regenerado con críticas protegidas)

Todas aprobadas: sin flotación, sin artefactos críticos.

## Errores nuevos descubiertos

### E-22 — `bpy.ops.object.modifier_apply.poll()` falla por socket MCP

**Síntoma**: `poll() failed, context is incorrect` al aplicar DECIMATE desde el socket.

**Causa**: `bpy.ops.object.*` requiere un contexto activo (viewport, objeto activo) que el socket MCP no provee.

**Fix**: aplicar el modificador evaluando el depsgraph y reasignando la malla:
```python
dg = bpy.context.evaluated_depsgraph_get()
me_eval = bpy.data.meshes.new_from_object(o.evaluated_get(dg))
mats = [m for m in o.data.materials if m is not None]
o.data = me_eval
for m in mats:
    o.data.materials.append(m)
o.modifiers.clear()
```

### E-23 — Decimate 0.5 destruye mallas planas lowpoly

**Síntoma**: tras `DECIMATE ratio=0.5` sobre mallas fundidas con cajas de 6 caras (paneles del cofre), las caras quedan como triángulos grandes rotos que rompen la silueta y dejan huecos.

**Causa**: `DECIMATE` colapsa vértices de mallas planas sin respetar las aristas duras. Como las caras son grandes, cada colapso deforma regiones enteras.

**Fix**:
1. Subir el ratio a 0.7 (corte más suave, mantiene silueta).
2. Marcar como `CRITICAS_NO_FUNDIR` las piezas con detalle fino (costillas, cerradura, gemas, ojos, falleba, asa, tirador) — no se funden ni se decimatan.
3. Lista extensible por asset: al usar M166 sobre un objeto nuevo, agregar sufijos específicos al `CRITICAS_NO_FUNDIR`.

### E-20 refinado — SSR debe activarse también en el script de captura

**Síntoma**: las variantes con menos objetos se ven planas (sin highlights) aunque los materiales sean idénticos al ALTA.

**Causa**: `capturar_angulos.py` no activaba `eevee.use_ssr`, `eevee.use_ssr_refraction` ni `eevee.use_raytracing`. En el ALTA las capturas se sacaron con otro script que sí los activaba, por eso se veían pulidas. El "azul raro" del cuerpo del cofre en las primeras capturas de MEDIA/BAJA NO era un bug, era que faltaba SSR.

**Fix**: agregar el bloque try/except en el bucle de captura. Ya está aplicado en el script.

## Documentación creada

- `DOCUMENTACION/166-Variantes-Y-Perfil-De-Rendimiento/plan-inicial/` — 5 archivos (01-05)
- `DOCUMENTACION/166-Variantes-Y-Perfil-De-Rendimiento/plan-actual/` — mirror con header `plan-actual · Piloto: cofre ancestral (aprobado) · 2026-08-28`
- Fila 166 agregada a `CHECKLIST-GLOBAL.md` con score `100/100` y enlaces de integración a M25, M108, M159.

## Pendiente (no urgente)

- Implementar el autoload `AssetProfile` en Godot 4 (diseñado pero no codificado; bloqueado por falta de 5+ assets con sus 3 variantes).
- Procesar 4 assets más del Tier C con el módulo (M45 monolito, M16 hacha, M45 estrella, M13 coco) para tener masa crítica de prueba.
- Exportar las 3 variantes del cofre a glTF y verificar la carga en Godot 4.
- Documentar E-22 y E-23 en `09-GUIA-BLENDER.md` §3 en la próxima sesión de mantenimiento.

## Comando de regeneración (receta)

```bash
cd tools/mcp/blender-mcp/scripts-reutilizables

# 1) Verificar coste del ALTA
python stats_asset.py SM_Cofre_ ../25-Ruinas-Templos/cofre_ancestral_lowpoly

# 2) Generar variantes
python generar_variante.py 25-Ruinas-Templos cofre_ancestral_lowpoly --media --baja

# 3) QA visual de MEDIA
python abrir_blend.py 25-Ruinas-Templos cofre_ancestral_lowpoly_media
python capturar_angulos.py SM_Cofre_ ../25-Ruinas-Templos/capturas/cap_25_cofre_MEDIA.png 6

# 4) QA visual de BAJA
python abrir_blend.py 25-Ruinas-Templos cofre_ancestral_lowpoly_baja
python capturar_angulos.py SM_Cofre_ ../25-Ruinas-Templos/capturas/cap_25_cofre_BAJA.png 6
```
