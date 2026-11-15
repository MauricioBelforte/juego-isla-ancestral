# Nicho y limites — ERNIE-5.5-Flash-Preview

**Vigente desde:** 2026-11-14 (directiva del fundador).
**Por que existe:** para que ningun agente (ni yo en otra sesion) me vuelva a asignar
trabajo que no puedo hacer bien. Esto no es un backlog: es mi regla de trabajo.

## 1. Lo que SI hago (y hago bien)

| Area | Detalle |
|---|---|
| **Modelado de objetos en Blender** | props, mobiliario, herramientas, decoracion, estructuras chicas. Procedural, low-poly, con `Z_APOYO = 0.045`, prefijo `SM_`, un material por pieza, 3 LOD. |
| **Auditoria de assets por binario** | GLB (JSON + BIN): escala en mundo, normales unitarias, `z_min`/`z_max`, vertices por malla, materiales, jerarquia de nodos. `.blend` ajenos: `libraries.load` + link explicito + depsgraph. |
| **Saneamiento de documentacion** | Godot vs Unity en `AGENTS.md`, estructura de docs, deteccion real de mojibake (con Python, **nunca** con `Get-Content` pelado). |

## 2. Lo que NO hago

| Limite | Origen |
|---|---|
| **Diseno de PERSONAJES** (cuerpo, rostro, proporcion, silueta, ropa ajustada) | Directiva del fundador 2026-11-14, tras dos iteraciones fallidas en el Mayordomo del Pueblo (M161): "no se te da bien el diseno de personajes con precision... te doy la creacion de objetos pero no de personajes". |
| **QA visual / estetico de cualquier tipo** | El harness no me pasa imagenes: `Cannot read image (this model does not support image input)`. La ficha del proveedor dice multimodal, pero el canal no existe aca. |
| **Firmar un `[x]` que dependa de "se ve bien"** | Sin vision no puedo. Eso lo firma un modelo con vision (agnes, Hy3, s2). |

## 3. Regla operativa

> Si la tarea se resuelve preguntando **"como se ve?"** → no es mia. Si se resuelve
> preguntando **"cuanto mide / cuantos vertices / donde esta el eje / que dice el archivo?"**
> → es mia.

## 4. Como entrego cuando trabajo en 3D

1. **Derivar la geometria del asset existente**, no adivinar anillos: duplicar el mesh del
   cuerpo/base e inflar 1,4-3,6 cm **a lo largo de la normal**. Asi nada queda superpuesto
   ni descentrado. (Esto fue lo que arreglo el Mayordomo v1 -> v2.)
2. **Anatomia de la escena:** excluir siempre el **set de captura** (`Base_Arena`, camaras,
   luces) del asset y del calculo de `z_min`.
3. **Colocar accesorios sobre la superficie medida** (raycast o muestreo de vertices), nunca
   en coordenadas "a ojo": un accesorio con radio menor al del cuerpo queda **incrustado**.
4. **Verificar con numeros antes de mostrar:** `z_min == 0.045`, bbox de cada prenda vs la
   parte del cuerpo que cubre, conteo de vertices, materiales sin duplicar (`.001`).
5. **No puedo evaluar el resultado visual.** Lo muestro encuadrado y el fundador juzga.

## 5. Errores propios que ya cometi (no repetir)

- **Ojos en el origen:** `matrix_world` stale tras `libraries.load` -> la pieza quedo en el
  piso. Fix: hornear `matrix_basis` en el mesh y resetear.
- **Accesorios incrustados:** cadena con radio 0,15 contra un torso de 0,25 -> invisible.
- **Sombrero gigante:** ala de 68 cm sobre una cabeza de 29 cm. Medir la cabeza, no suponer.
- **Baston flotando:** mango a la altura del pecho cuando la mano esta en 0,57-0,70.
- **Ropa "a ojo":** anillos supuestos en vez de derivar del cuerpo -> proporciones falsas.

**Firma:** ERNIE-5.5-Flash-Preview (Baidu) / Kilo Code — 2026-11-14 05:10
