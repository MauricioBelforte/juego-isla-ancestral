# 03 — Scripts Reutilizables y Helpers

**Modelo:** MiniMax-M3 (OpenCode)
**Plataforma:** OpenCode CLI
**Fecha:** 2026-09-10

**Propósito:** Extraído de OBSOLETOS/09-GUIA-BLENDER.md — funciones helper y scripts reutilizables documentados en las descripciones de errores (especialmente E-67, E-68, E-77, E-91, E-92, E-95, E-97). Firma de cada función, patrones de uso y parámetros clave.

---

## 1. `plantilla_asset.py` — Helpers generales de assets

### `arena()`
- **Propósito:** Crea el disco de arena de referencia para el set de captura.
- **Bug documentado (E-67):** la versión original ponía el top del disco en z=0, no en z=0.05. Fix: nueva constante `ALTURA_ARENA = 0.05` y `location.z = ALTURA_ARENA - profundo/2`.
- **Uso:** se invoca internamente en los scripts de assets para crear el set de captura.

### `asentar(escena, z_apoyo=0.045, ...)`
- **Propósito:** Re-asenta un asset en la arena midiendo `z_min` real (vértices, no AABB).
- **Heurística E-50:** exige `min(fp_x, fp_y) > 0.30` — calibrada para props de ~1 m. Rechaza objetos cuyo diámetro sea menor a ~0.7 m (ver E-91).
- **Caso especial E-78:** en anillos elípticos, el vértice más bajo está en el CENTRO del anillo, no en el borde → la huella se colapsa a la línea media. Solución: suela plana (caja debajo).
- **No usar para:** herramientas alargadas (usar `asentar_herramienta()`), assets montados (usar `_MONTADO`), assets que se apoyan sobre otros assets (E-60).

### `loft(nombre, anillos, lados, material, escena)`
- **Propósito:** Apila anillos para crear mallas tubulares/cilíndricas.
- **Formato de anillo (E-77):** `anillos = [(z, cx, cy, rx, ry), ...]` — **Z PRIMERO**, no `(x, y, z, ...)`. Si pasás coordenadas en el orden natural de un vector 3D, el helper interpreta tu X como Z y la malla queda deformada SIN ERROR EN CONSOLA.
- **Assert de validación (E-77):** verificación de que los z son no decrecientes:
  ```python
  for i in range(len(anillos) - 1):
      assert anillos[i][0] <= anillos[i+1][0] + 1e-9, (
          'E-77: anillo %d tiene z=%.4f y el siguiente z=%.4f. Los anillos '
          'van de ABAJO hacia ARRIBA y el PRIMER campo es Z, no X.' % (...))
  ```
- **Restricción (E-92):** NO puede hacer piezas HUECAS (bowl, vasija, ánfora) porque exige z crecientes. Para eso usar `revolucion()`.
- **Patrón correcto al pasar polilíneas:**
  ```python
  muestras = polilinea(pts, ts)          # devuelve (x, y, z)
  anillos = [(p[2], p[0], p[1], r, r)    # (z, x, y, rx, ry) ← reordenás
             for p in muestras]
  ```

### `prisma(nombre, pts, grosor, material, escena)`
- **Propósito:** Crea prismas extrudiendo un contorno 2D a lo largo de un eje.
- **Uso en herramientas (E-91):** con `lados=6, fase=0` la cara inferior es PLANA (dos vértices inferiores a 240° y 300°). Dividir el espesor por `F_PLANO = 0.8660` para que el grosor efectivo coincida con el pedido.
- **`lados=4` (sección romboidal):** todos los vértices inferiores quedan a la misma `y = 0` → apoyo en una línea única. Útil para mangos romboidales filados; destructivo para hojas.
- **No confundir con `loft()`:** `prisma()` avanza RECTO por un eje (`X`/`Y`/`Z`). Para curvas 3D usar `tubo_arco()`.

### `revolucion(nombre, perfil, materiales, lados, idx_mat, escena)`
- **Propósito:** Revoluciona un perfil 2D `(r, z)` alrededor de Z. Acepta que el perfil suba y baje (a diferencia de `loft()`).
- **Documentado en E-92.**
- **Orientación automática:** las caras laterales se generan con el mismo winding que `loft()`. Cuando el perfil baja (pared interior), el winding se invierte solo: la normal pasa a mirar hacia la cavidad. No hace falta `flip_normals()`.
- **Material por TRAMO:** `idx_mat` es una lista de `len(perfil)-1` enteros, uno por segmento. Permite franjas pintadas o interior vidriado sin sumar triángulos.
- **Vértices degenerados (E-72):** si un punto del perfil tiene `r ≈ 0`, crea UN vértice y abanica. Puede causar problemas con decimate.
- **Verificación de orientación — volumen firmado (E-92):**
  ```python
  vol = 0.0
  for f in bm.faces:
      vs = [v.co for v in f.verts]
      for k in range(1, len(vs) - 1):
          a, b, c = vs[0], vs[k], vs[k + 1]
          vol += (a.x * (b.y * c.z - b.z * c.y)
                  - a.y * (b.x * c.z - b.z * c.x)
                  + a.z * (b.x * c.y - b.y * c.x))
  vol /= 6.0
  assert vol > 0, 'normales hacia adentro: el perfil está recorrido al revés'
  ```
  `V > 0` = normales hacia afuera. `V < 0` = perfil recorrido al revés.
- **Aplica a:** bowls, platos, cuencos, vasijas, ánforas, jarras, tinajas, copas, cualquier sólido de revolución con cavidad.
- **No aplica a:** piezas con sección no circular (prismas, mangos, hojas → `prisma()` / `herramienta_util`).

---

## 2. `herramienta_util.py` — Helpers para herramientas alargadas

### `prisma(nombre, estaciones, material, escena)`
- **Propósito:** Crea piezas alargadas (herramientas) como series de secciones poligonales a lo largo de un eje.
- **Diferencia con `plantilla_asset.prisma()`:** este está optimizado para herramientas con grosor variable, taper, y asentado especializado.
- **Mangos cónicos (E-91):** mantener `hz` CONSTANTE a lo largo del mango (e.g. `0.030`) y aplicar el "swell" ergonómico solo en `hy`. Así la generatriz inferior completa es horizontal y todos sus vértices tocan.

### `asentar_herramienta(escena, min_toca=8, min_fp=0.02, frac_largo=0.45, z_apoyo=0.045)`
- **Propósito:** Re-asenta herramientas alargadas con una heurística distinta a `plantilla_asset.asentar()`.
- **Tres condiciones (E-91):**
  1. `len(verts que tocan) >= 8`
  2. `min(fp_x, fp_y) >= 0.02` — descarta apoyo en arista viva finísima
  3. `max(fp_x, fp_y) >= 0.45 · L`, donde `L` es el eje horizontal más largo del bounding box. **Esta es la regla que sustituye al `0.30`** para herramientas.
- **Nunca delegar a `plantilla_asset.asentar` para herramientas.**

### `cerrar_herramienta(escena, modulo, asset, loc_cam, mira_cam)`
- **Propósito:** Wrapper que hace todo: asentar + iluminar + cámara + shade_flat + auditar + guardar.
- **Uso:**
  ```python
  from herramienta_util import prisma, asentar_herramienta, cerrar_herramienta
  cerrar_herramienta(escena, modulo='16-Crafting', asset='machete',
                     loc_cam=(1.0, -1.5, 0.8), mira_cam=(0.0, 0.0, 0.05))
  ```

### `tubo_arco(nombre, pts, radios, lados, material, ref)`
- **Propósito:** Crea tubos que siguen una curva 3D arbitraria (asas curvas, varillas, arcos).
- **Documentado en E-95.**
- **En cada estación:**
  ```python
  t = normalize(p[i+1] - p[i-1])      # tangente
  u = normalize(t × ref)               # ref FUERA del plano de la curva
  v = t × u                            # v ya unitario
  verts[k] = c + u * rx * cos(a) + v * ry * sin(a)   # para k=0..lados-1
  ```
- **Cuidado de degeneración:** si la tangente se vuelve paralela a `ref`, el frame degenera. Pasar un `ref` que NO esté en el plano de la curva:
  - arco en plano **YZ** → `ref = (1, 0, 0)` (X)
  - asa en plano **XZ** → `ref = (0, 1, 0)` (Y)
  - arco en plano **XY** → `ref = (0, 0, 1)` (Z)
- **Aplica a:** cualquier asa / arco / varilla curva (regaderas, canastas, palanganas, asas de cofres, varillas de paraguas, mangos curvos).

---

## 3. `hoja_util.py` — Helpers para hojas planas-arqueadas

- **Documentado en E-97.** Nueva casa canónica de las funciones de hoja.

### Funciones disponibles:
- `cruz(a, b)` — producto cruz de tuplas 3D
- `newell(pts)` — normal de un contorno poligonal
- `desvio_planar(pts)` — max |dot(p − p0, n)| para verificar planitud (E-93)
- `vol_firmado(bm)` — volumen firmado de una malla cerrada (E-92)
- `prisma_contorno(nombre, contorno, grosor, material, escena)` — objeto nuevo
- `prisma_contorno_en(bm, contorno, grosor, mi)` — inyectar piezas en un bmesh existente (E-70b)
- `hoja_plana_arqueada(...)` — contorno de una hoja plana-arqueada

### `prisma_contorno_en(bm, contorno, grosor, mi)` (E-70b)
- **Propósito:** Inyectar un prisma dentro de un bmesh existente, conservando el `material_index` que se le pasa.
- **Uso:**
  ```python
  bm = bmesh.new(); bm.from_mesh(o.data)         # bm del tallo
  for hoja in hojas:
      cont = hoja_plana_arqueada(...)
      prisma_contorno_en(bm, cont, grosor=0.006, mi=IDX_HOJA)
  bm.to_mesh(o.data); bm.free()
  ```
- **Ventaja:** el asset queda como **un solo `SM_`** con sus hojas inyectadas, sin exceder el presupuesto de objetos (E-70).
- **Cuidado:** asegurarse de que el objeto ya tenga el material antes de inyectar (E-83).

---

## 4. `montado_util.py` — Helpers para assets montados (sombreros, armas, ropa)

### `unir(objetos, escena)`
- **Propósito:** Fusiona múltiples objetos `SM_` en uno solo, deduplicando materiales.
- **Fix E-83:** respaldar `material_index` por cara ANTES de `clear()`, reasignar después:
  ```python
  idx_caras = [p.material_index for p in o.data.polygons]
  o.data.materials.clear()
  for m in vistos: o.data.materials.append(m)
  for p, mi in zip(o.data.polygons, idx_caras):
      p.material_index = mapa[mi] if mi < len(mapa) else 0
  ```

### `clearance_cuerpo(p, partes=None)`
- **Propósito:** Verifica que las piezas de ropa/montaje estén fuera del cuerpo.
- **Fix E-84:** incluir los DELTOIDES (E-81) en el cálculo de distancia.
- **Fix E-89:** admite un subconjunto de `('torso','brazos','piernas','deltoides')` para que cada pieza declare contra qué partes se audita.

### `Z_REF_CABEZA`
- **Constante** que define la altura de referencia del cuello para assets con cabeza (E-90).

---

## 5. Scripts de verificación y auditoría

### `verificar_bounds.py`
- **Propósito:** QA numérico de un asset: cantidad de objetos, `z_min`/`z_max`, rango X/Y, duplicados.
- **Uso:** `python verificar_bounds.py SM_Coco_`

### `auditar_apoyos.py`
- **Propósito:** Ejecuta todos los `crear_*_lowpoly.py` de un módulo y reporta cuáles tocan el suelo.
- **Uso:** `python auditar_apoyos.py 15-Recursos`
- **Criterio:** FLOTA si `z_min > 0.05` y `< 0.50`.

### `capturar_angulos.py`
- **Propósito:** Genera N capturas equi-espaciadas alrededor del asset (E-13).
- **Uso:** `python capturar_angulos.py SM_Coco_ base.png 6`

### `capturar_angulos_headless.py` (E-55)
- **Propósito:** Capturas orbitales sin socket MCP (Blender cerrado).
- **Uso:** `blender -b --factory-startup --python scripts-reutilizables/capturar_angulos_headless.py -- <ruta.blend> <prefijo_SM_> <ruta_base.png> [N]`

### `auditar_presupuesto.py`
- **Propósito:** Recorre blends, cuenta triángulos reales (`loop_triangles`), slots y materiales usados. Reporta excesos en `obj+`, `tris+` o `mats+`.
- **Fix E-36:** ahora recorre TODOS los objs SM_ (no solo `objs[0]`).

### `saneo_bajas_e34.py` (E-34)
- **Propósito:** Deduplica slots de material en `_baja.blend` usando `pop()` (no `clear()`). Re-ejecutable, idempotente.

### `generar_variante.py`
- **Propósito:** Genera variantes MEDIA y BAJA de un asset.
- **Parámetros clave:**
  - `--media` / `--baja` — tipo de variante
  - `--ratio <float>` — override del ratio de decimate para assets con geometría densa (E-29)
- **Bug E-62:** re-asentaba INCONDICIONALMENTE. Fix: umbral `UMBRAL_REASENTADO = 0.25` m.
- **Bug E-80:** re-asentaba assets montados. Fix: detectar Empty `_MONTADO` y omitir.

### `exportar_godot.py`
- **Propósito:** Exporta `.blend` a `.glb` para Godot.
- **Modo headless (E-45):** se corre con `blender -b --factory-startup --python exportar_godot.py`, NO por socket MCP.
- **Parámetros por env-var:** `EXPORT_DRY`, `EXPORT_FORZAR`, `EXPORT_MODULOS`.
- **E-63:** tiene whitelist de módulos; agregar módulos nuevos a la tupla `MODULOS`.

### `contact_sheet.py`
- **Propósito:** Genera hojas de contacto con múltiples capturas.
- **Bug E-30/E-66:** el shell no expande globs entre comillas dobles. Fix interno: detectar `*` y expandir con `glob.glob()`.

### `aplanar_dome.py` (E-50, E-51)
- **Propósito:** Aplana la base de domos/husos para lograr apoyo estable.
- **Algoritmo:** BFS sobre aristas del vértice más bajo, K anillos topológicos, reasignar `z=Z_OBJ` preservando XY.
- **Uso CLI headless (E-54):** `blender -b --factory-startup --python-expr "..."`

### `asentar_en_base.py`
- **Propósito:** Baja un grupo hasta `z_min = 0.045`. Para correcciones one-off.
- **Uso:** `python asentar_en_base.py SM_Tronco_Caido 0.045`
- **Bug E-24:** reportaba `HUNDIDO` falsamente en objetos rotados (usaba AABB). Fix: usar `zmin_real()`.

### `corregir_asset.py`
- **Propósito:** Corrige apoyo y otros problemas de un asset.
- **Fix E-24:** `zmin_de()` ahora usa vértices reales, no AABB.

---

## 6. Funciones auxiliares de geometría

### `zmin_real(o)` (E-24)
- **Propósito:** Mide el `z_min` real de un objeto usando vértices de la malla, no el AABB.
- **Implementación:** `min((o.matrix_world @ v.co).z for v in o.data.vertices)`
- **Fallback:** si `len(o.data.vertices) == 0`, usar AABB.
- **Requisito (E-94):** llamar `bpy.context.view_layer.update()` ANTES de medir.

### `altura_maxima(objs)`
- **Propósito:** Mide la altura real del GLB actual para calcular el multiplicador de escalado.
- **Uso en pipeline de escalado:** `multiplicador = altura_objetivo / altura_actual`

### `hijo(objeto, padre)` (E-18, E-27)
- **Propósito:** Parentea un objeto hijo a un padre sin romper la herencia.
- **Implementación segura:**
  ```python
  def hijo(objeto, padre):
      bpy.context.view_layer.update()
      objeto.parent = padre        # Blender calcula matrix_parent_inverse solo
      return objeto
  ```
- **NO tocar `matrix_parent_inverse`** después del parenteo.

### `volumen_firmado(caras)` (E-32, E-92)
- **Propósito:** Calcula el volumen con signo de una isla cerrada de caras.
- **Implementación:**
  ```python
  def volumen_firmado(caras):
      v = 0.0
      for f in caras:
          co = [vert.co for vert in f.verts]
          for k in range(1, len(co) - 1):
              v += co[0].dot(co[k].cross(co[k + 1]))
      return v / 6.0
  ```
- **`V > 0`** = normales hacia afuera. **`V < 0`** = dada vuelta.

### `newell(pts)` (E-97)
- **Propósito:** Calcula la normal de un contorno poligonal (regla de la mano derecha).
- **Uso:** orientación de caras en islas cerradas.

### `dist_punto_caja(p, cx, cy, cz, hx, hy, hz)` (E-39)
- **Propósito:** Distancia mínima entre un punto y un AABB.
- **Uso:** validar no-colisión entre esferas y cajas.
