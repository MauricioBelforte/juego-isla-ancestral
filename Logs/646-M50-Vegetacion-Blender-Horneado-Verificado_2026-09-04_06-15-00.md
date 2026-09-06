# Log 646: M50 — Verificación post-horneado de GLBs en Blender

**Fecha:** 2026-09-04
**Hora:** 06:15
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Los 13 GLBs de vegetación fueron **re-escalandose en Blender 4.2** (background mode con bpy) para alcanzar las alturas objetivo exactas de 5-FUTURAS-MEJORAS. `escalas.json` actualizado a 1.0 para los GLBs horneados. 2 ítems con altura ~0 planos (raíces, hierba) mantienen escala runtime.

## Proceso

### 1. Respaldo (regla §5)
15 GLBs copiados a `assets/3d/media/Obsoletos/respaldo_original_2026-09-04_06-06-43/`

### 2. Pasada v1 (corregida)
Multiplicador fijo de la tabla → palmera x5 = 19.3m (¡demasiado!). Error: asumí GLBs de ~1m pero tenían alturas variadas (0.05m-3.86m).

### 3. Pasada v2 (corrección)
**Multiplicador dinámico = altura_objetivo / altura_actual** → 13 GLBs re-exportados a altura exacta:
- Palmeras: 5.0m ✓
- Arbol frutal: 6.0m ✓
- Arbustos: 1.0m ✓
- Flor: 0.25m ✓
- Hongo: 0.5m ✓
- Bambú: 2.5m ✓
- 2 SKIPPED (raíces, hierba): altura XZ plana, necesitan eje distinto — mantienen escala runtime

### 4. escalas.json actualizado
Vegetación = 1.0 (horneado), excepciones runtime para las 2 planas.

## Verificación visual (captura godot-mcp)
Juego corriendo con: iluminación M49 (sombras ✓), recursos M15 (manchas naranjas ✓), jabalí M65 ✓, flora/hierba de cercanías visible (pequeñas — natural para flores). **Faltan árboles cerca del spawn** para referencia de escala (palmeras/arbol_frutal están en bioma "playa"/"bosque" lejos del spawn).

## Archivos Modificados/Creados
- 13 GLBs re-exportados con scale horneado *(Blender 4.2 bpy)*
- `data/escalas/escalas.json` *(vegetación = 1.0 + 2 excepciones runtime)*
- `game/isla-ancestral/scripts/reescalar_vegetacion_v2.py` *(script Blender reutilizable)*
- `assets/3d/media/Obsoletos/respaldo_original_2026-09-04_06-06-43/` *(respaldo §5)*
- `Logs/ULTIMO_NUMERO.txt` *(→ 646)*
- `Logs/reservas/646-...txt` *(creada y borrada)*

## Decisión de rendimiento documentada (5-FUTURAS-MEJORAS)
Exportar con tamaño correcto desde Blender > escalar en runtime (normales correctas, colisiones match, física sin bugs). La tabla runtime queda como fallback para objetos que no se han re-exportado aún.
