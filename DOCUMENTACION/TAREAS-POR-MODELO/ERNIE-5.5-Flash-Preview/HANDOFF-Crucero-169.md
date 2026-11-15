# HANDOFF — 169-Crucero, exterior v1 (guardado 2026-11-13 22:47)

**Para:** el próximo agente (o yo en la próxima sesión).
**Estado:** el fundador pidió **guardar así y seguir mañana**. El archivo está guardado tal cual.
**Veredicto del fundador sobre el exterior v1:** *"quedó raro, todavía falta pulirlo"*.

## Archivo

```
tools/mcp/blender-mcp/169-Crucero/crucero_exterior_lowpoly.blend
colección: M169_Crucero · 102 objetos · 6.469 vértices · 12 materiales
z: 0,0450 … 16,93 m   (Z_APOYO correcto; el mástil de radar es el punto más alto)
```

## Decisiones de diseño ya tomadas (no renegociar sin orden)

| Dato | Valor |
|---|---|
| Eslora / manga | 72,0 m / 13,58 m de casco (16,6 m con botes) |
| Calado | quilla 0,045 → línea de flotación **1,80** |
| Cubiertas | 1: 3,40 · 2: 6,60 · 3: 9,80 · 4: 12,60 (3,20 m entre forjados) |
| Superestructura (media manga) | nivel 1: 4,45 · nivel 2: 4,30 · nivel 3: 3,90 |
| **Paseo de cubierta 1** | **1,59 m por lado** (entre la pared 4,45 y la reja 6,04) |
| Piso 4 | 24,0 × 9,9 m, con **cornisa** bajo el voladizo (1,05 m) |
| Puente | 9,10 × 4,35 × 2,45 m, frente curvo, **banda vidriada envolvente**, visera, **bridge wings** con bielas, **mástil de radar** + 2 barras + 2 antenas |
| Carriles de cubierta 4 | puente (−11,95…−7,60) · chimenea 1 (−7,45…−4,55) · jacuzzis (−3,15…−1,65) · piscina (0,30…3,70) · chimenea 2 (6,55…9,45) · tumbonas (10,0…11,8) |
| Botes | cuelgan del **casco azul**: z 2,35…3,20, x ±7,49 (borde interno 6,69; holgura mínima 0,03 m en y=+4,5) |

## Lo que falta (en orden de prioridad para mañana)

1. **Pulir la estética.** El fundador dice que "quedó raro". Los sospechosos que **no pude ver**:
  - proporción entre el casco y la superestructura (ahora la blanca es bastante más angosta)
  - el frente curvo del puente y las alas
  - densidad de ventanas (14 ojos de buey + 10 ventanales para 66 m es **poco** para un crucero)
  - la cornisa del piso 4 y las bielas de las alas
- [ ] **Interiores** (4 escenas): camarotes con camas/armarios/baños, comedor, casino, puente. Es donde están los muebles que pidió el fundador.
- [ ] **LODs** media y baja (presupuesto ≤ 3.500 / ≤ 1.500 v).
- [ ] **Exportar GLB** a `assets/3d/{alta,media,baja}/169-Crucero_*.glb` (headless, E-106).
- [ ] Integración con M68 (rutas/pasajes/temporada), M74 (minijuego), M63 (streaming), M28 (viaje).

## Lecciones de esta sesión (para no repetir)

1. **No comparé el AABB contra la pared correcta:** medir la distancia de una puerta al punto más cercano de *cualquier* malla da falsos positivos con piezas separadas. Hay que comparar contra la pared que corresponde.
2. **Después de editar `v.co` hay que actualizar el depsgraph** (`bpy.context.view_layer.update()` + `dg.update()`); si no, `evaluated_get()` devuelve la malla vieja y las verificaciones mienten.
3. **El AABB es cota cuadrada:** en objetos rotados o piezas planas (alfombras, alas) da intersecciones falsas. Para verificar de verdad hay que comparar mallas o usar la manga interpolada.
4. **`libraries.load()` no vincula a la escena** → `matrix_world` queda stale (ya costó un diagnóstico el 2026-11-13).
5. **Verificar con `verificar_checklist` y `git status`**, no con "quedó bien": el re-export dio 76 "ok" y 0 cambios en disco.

**Firma:** ERNIE-5.5-Flash-Preview (Baidu) / Kilo Code — 2026-11-13 22:47