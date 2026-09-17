# 04 — Errores Avanzados de Blender (E-36 en adelante)

**Modelo:** MiniMax-M3 (OpenCode) — continuado por Hy4 preview (WorkBuddy)
**Plataforma:** OpenCode CLI / WorkBuddy
**Fecha:** 2026-09-10

**Propósito:** errores E-36 en adelante documentados, cada uno con síntoma, causa, verificación, solución, caso real y reglas derivadas.

> **Sobre el nombre del archivo (log 809):** antes se llamaba
> `04-errores-avanzados-e36-eNN.md` y había que renunciarlo a CADA error nuevo
> (e36-e97 → e36-e100 → …), rompiendo los enlaces en `AGENTS.md`, `INDICE.md` y
> la guía comparativa. Se renombró a **`04-errores-avanzados.md`**, sin rango,
> para que los enlaces sean estables. El rango real está en el título de cada
> sección `### E-NNN`, y el total vivo en `INDICE.md`.

---

### E-36 — `auditar_presupuesto.py` solo inspeccionaba `objs[0]` para materiales
- **Síntoma:** la primera versión del audit (de log 285) reportaba `slots=1, mats_usados=1` para `tablon_madera_lowpoly_baja`, que en realidad tiene **6 slots y 6 materiales usados**. El mismo bug afectaba a `cofre_ancestral_baja` (6), `nido_cocos_baja` (5), `farola_fuego_baja` (5), `anillo_piedras_ritual_baja` (5), `arbusto_floral_baja` (5) y `hongo_luminoso_baja` (5). El conteo de triángulos sí estaba bien (iteraba todos los objs), pero el de materiales solo miraba el primero.
- **Causa:** el script agregaba `tris` y `caras` en un loop sobre todos los `objs`, pero usaba `objs[0].material_slots` y `objs[0].data.polygons` para materiales. Para assets con un solo objeto esto no importa, pero los assets multi-objeto (varios `SM_*` con sus propias slots) quedaban sub-reportados.
- **Solución:** mover el loop de slots y de caras dentro del for `o in objs`, igual que ya estaba para `tris` y `caras`.
- **Regla nueva:** cuando se itera un grupo de objetos, los slots y materiales se cuentan DENTRO del mismo loop, no en una segunda pasada sobre `objs[0]`.
- **Fecha:** 2026-08-29 21:35

### E-37 — Un "fix" cosmético no es un fix; un bug de diseño sigue siendo bug aunque el render se vea distinto
- **Síntoma:** la palanca de madera `palanca_madera_lowpoly` salía del E-13 aprobada ("palo clavado en una caja con una pelota en la punta"), luego un "fix" del log 233 la rotó a mano de 35° a 81.1° y reposicionó el pomo. El usuario la miró de nuevo y dijo "no le encuentro la forma, eso esta corregido?". El "fix" no había arreglado nada — solo había maquillado un problema de fondo que **seguía ahí**: el brazo cilíndrico se creaba en `(0,0,0.21)`, **el mismo punto que el cono del pivote**. El brazo atravesaba el pivote en cualquier ángulo.
- **Causa:** confundir "cambio que produce otro render" con "arreglo que resuelve el problema".
- **Reglas derivadas:**
  1. Antes de aprobar un asset, **preguntarse "¿se lee como X?"** en lugar de "¿z_min ≈ 0.045?". El E-13 (multi-ángulo) detecta la flotación numérica pero no detecta ambigüedad semántica.
  2. Si un fix cambia la apariencia pero la queja del usuario es de fondo ("no le encuentro la forma"), el fix está **maquillando**, no arreglando. **Rediseñar.**
  3. Cuando el brazo y el pivote son dos operaciones distintas en el mismo lugar, están colisionando por construcción. La solución no es moverlos unos centímetros — es **fusionarlos en un solo bmesh** donde brazo y pivote nacen como caras adyacentes.
- **Caso real:** palanca de madera M70 v1 → v2 (pivote único) → v3 (horquilla). El v3 lo resolvió haciendo una sola operación bmesh con base + 2 montantes + brazo + perno + pomo, todos como caras del mismo mesh. 96 tris, 1 obj, 3 mats, **se lee como palanca**.
- **Lección específica:** **para palancas mecánicas, la HORQUILLA (dos montantes + perno transversal) es incomparablemente más legible que el pivote único**.
- **Fecha:** 2026-08-29 23:05

### E-38 — En mallas inclinadas, la CAÍDA VERTICAL de una cara NO es su semialto, es `semialto * cos(θ)`
- **Síntoma:** assert geométrico falla con diff ~1.1 mm: la cara inferior del brazo desciende `SEMIALTO*cos(θ)` desde el centro, no `SEMIALTO`.
- **Causa:** cuando se inclina una caja, la proyección vertical del semieje es siempre `semieje * cos(θ)`.
- **Solución:** definir `CAIDA_VERT = SEMIALTO * cos(ANG_TILT)` y usar esa constante para cualquier cálculo vertical.
- **Regla nueva:** **toda caja inclinada se analiza con sus semiejes proyectados**: `semieje_x · cos(θ)` para caída/subida vertical, `semieje_x · sin(θ)` para corrimiento lateral. NUNCA mezclar el semieje real con la altura que ocupa.
- **Fecha:** 2026-08-29 23:05

### E-39 — Para choques esfera-caja, NO comparar un solo eje; medir distancia punto-caja real
- **Síntoma:** assert de colisión salta aunque geométricamente el pomo está a 0.49 m en X de la horquilla — no choca con nada.
- **Causa:** confundir "el pomo ocupa Z más bajo que el montante termina" con "el pomo choca con el montante". La primera es condición **necesaria** pero NO suficiente.
- **Solución:** usar la **distancia mínima punto-AABB**:
  ```python
  def dist_punto_caja(p, cx, cy, cz, hx, hy, hz):
      dx = max(abs(p.x - cx) - hx, 0.0)
      dy = max(abs(p.y - cy) - hy, 0.0)
      dz = max(abs(p.z - cz) - hz, 0.0)
      return math.sqrt(dx*dx + dy*dy + dz*dz)
  ```
- **Regla nueva:** **para validar no-colisión entre una esfera y una caja, SIEMPRE distancia punto-AABB + radio**. Nunca comparar componentes individuales en serie.
- **Fecha:** 2026-08-29 23:05

### E-40 — Medir TRIÁNGULOS REALES (`loop_triangles`), nunca CARAS (`polygons`)
- **Síntoma:** `generar_alta.py` aprobaba assets que duplicaban su presupuesto. `totem_isla_alta` reportaba 10.507 caras → "OK" cuando tenía 21.014 triángulos contra un techo de 6.000.
- **Causa:** un `polygon` de N vértices equivale a `N - 2` triángulos. Contar caras subestima entre 1,5× y 2×.
- **Solución:** contar con `calc_loop_triangles()`:
  ```python
  def tris_de(lista):
      t = 0
      for o in lista:
          o.data.calc_loop_triangles()
          t += len(o.data.loop_triangles)
      return t
  ```
- **Regla nueva:** **todo número que se compare contra un presupuesto se mide en triángulos reales.**
- **Fecha:** 2026-08-30 00:15

### E-41 — Al reescribir índices de material, respaldar por NOMBRE, no por número
- **Síntoma:** tras una poda de materiales que decía `PODA MATERIALES: 6 -> 4`, el reporte final seguía mostrando `materiales=6`.
- **Causa:** dos errores encadenados. (a) La poda dejaba slots vacíos. (b) `Mesh.materials.clear()` resetea a 0 el `material_index` de TODAS las caras.
- **Solución:** respaldar el material de cada cara **por nombre** antes de tocar slots:
  ```python
  nombres_viejos = [m.name if m else '' for m in o.data.materials]
  idx_nombres = [nombres_viejos[p.material_index] for p in o.data.polygons]
  usados = [n for i, n in enumerate(idx_nombres) if n and n not in idx_nombres[:i]]
  o.data.materials.clear()
  for nm in usados:
      o.data.materials.append(bpy.data.materials[nm])
  nuevo_idx = {nm: k for k, nm in enumerate(usados)}
  for p, nm in zip(o.data.polygons, idx_nombres):
      p.material_index = nuevo_idx.get(nm, 0)
  ```
- **Regla nueva:** **`materials.clear()` es destructivo pero no prohibido** — lo que está prohibido es llamarlo sin haber respaldado antes el material de cada cara **por nombre**.
- **Fecha:** 2026-08-30 00:15

### E-42 — Reportar materiales USADOS POR CARAS, no slots
- **Síntoma:** un asset con 4 materiales reales aparecía con 6 y superaba el techo de BAJA (4).
- **Causa:** `len(o.data.materials)` cuenta **slots**, y un slot puede quedar huérfano.
- **Regla nueva:** **slots huérfanos no cuentan como materiales.**
- **Fecha:** 2026-08-30 00:15

### E-43 — Colisión de nombres entre variantes: resolver con PRIORIDAD EXPLÍCITA
- **Síntoma:** al exportar el catálogo a Godot aparecían 51 "altas" pero el inspector mostraba un asset con 1 objeto y 96 tris donde debería haber 5.
- **Causa:** un mismo asset tenía dos archivos que mapean al mismo destino; ganó el viejo por orden alfabético.
- **Solución:** declarar prioridad explícita:
  ```python
  PRIORIDAD = {
      'alta':  ('_alta', '_lowpoly'),
      'media': ('_alta_media', '_lowpoly_media'),
      'baja':  ('_alta_baja', '_lowpoly_baja'),
  }
  ```
- **Regla nueva:** **cuando dos archivos compiten por el mismo destino, la prioridad se declara, no se hereda del `os.listdir`.**
- **Fecha:** 2026-08-30 00:15

### E-44 — Purgar todo objeto NO-`SM_` antes de exportar a glTF
- **Síntoma:** los `.glb` importados en Godot traían nodos basura: `Base_Arena`, cámaras, luces.
- **Causa:** los `.blend` de autoría incluyen el set de captura. El exportador glTF exporta la escena completa.
- **Solución:** purgar antes de exportar:
  ```python
  for o in list(bpy.context.scene.objects):
      if not o.name.startswith('SM_'):
          bpy.data.objects.remove(o, do_unlink=True)
  bpy.context.view_layer.update()
  ```
- **Regla nueva:** **el prefijo `SM_` es la frontera entre asset y set de captura.**
- **Fecha:** 2026-08-30 00:15

### E-45 — `bpy.context` por socket NO tiene `active_object`: exportar glTF en HEADLESS
- **Síntoma:** los 51 exports ALTA fallaron todos con `AttributeError: 'Context' object has no attribute 'active_object'`.
- **Causa:** el socket MCP recibe un `bpy.context` **restringido**. El exportador glTF lee `bpy.context.active_object`.
- **Solución:** **no exportar por socket.** Correr el export como proceso headless:
  ```
  blender.exe -b --factory-startup --python exportar_godot.py
  ```
- **Regla nueva:** **todo `bpy.ops` que toque contexto de ventana/objeto activo se corre en headless.**
- **Fecha:** 2026-08-30 00:15

### E-46 — Auditor de variantes desincronizadas (`auditar_desincronizados.py`)
- **Síntoma:** una variante derivada tiene `mtime` ANTERIOR al de su fuente. La GLB en Godot quedó congelada con datos viejos.
- **Diagnóstico rápido:** `python scripts-reutilizables/auditar_desincronizados.py`
- **Solución:** regenerar la variante o re-exportar la GLB con `EXPORT_FORZAR=1`.
- **Fecha:** 2026-08-30

### E-47 — La fuente del planner DEBE llamarse `N_lowpoly.blend`
- **Síntoma:** `exportar_godot.py` saltea silenciosamente un asset cuyo source no encaja con el patrón `*_lowpoly*.blend`.
- **Causa:** el planner arma el árbol de prioridad por sufijo. Un `roca_comun.blend` plano no matchea ninguna rama.
- **Regla:** todo asset del catálogo debe tener su source como `N_lowpoly.blend` o `N_alta.blend`.

### E-48 — `generar_variante.py` re-asienta el derivado, la fuente NO
- **Síntoma:** la GLB ALTA y la GLB MEDIA del mismo asset quedan a alturas distintas → al cambiar de LOD en Godot el objeto SALTA.
- **Solución:** **siempre comparar ALTA GLB vs MEDIA GLB en el contact-sheet conjunto** tras regenerar. Si los z_min difieren >0.020, **corregir la fuente** y regenerar las variantes. La fuente manda.

### E-49 — El mtime-skip de `exportar_godot.py` miente tras restores / clock skew
- **Síntoma:** modifico el `.blend`, corro `exportar_godot.py` sin flags, y la GLB en Godot **no se regenera**.
- **Causa:** la heurística asume que "GLB más nueva que .blend" ⇒ "GLB generada DESDE ese .blend". Falso tras restores, clock skew o `git pull`.
- **Solución:** cuando hay duda, `EXPORT_FORZAR=1`.

### E-50 — Apoyo puntual en domo: `z_min=0.0450` con `toca=1, footprint=0×0`
- **Síntoma:** `z_min` numéricamente correcto pero la captura orbital muestra **un gap visible** entre el objeto y la arena. El test pasa y aun así flota.
- **Causa:** el modelo es un huso. El vértice más bajo toca el suelo, pero el ecuador está a z≈0.6 → 55 cm arriba del suelo.
- **Detección:** `diagnosticar_pose.py --detalle` reporta `toca=N, footprint=X×Y`. Si `N=1` y `X=Y=0.000`, **es E-50**.
- **Solución:** re-modelar la base a cara poligonal plana con `aplanar_dome.py`.
- **Lección:** la auditoría numérica `z_min == Z_APOYO` es **necesaria pero no suficiente**. La captura orbital es la fuente de verdad final.
- **Fecha:** 2026-08-31 03:25

### E-51 — Vecindario por DISTANCIA XY, NO por topología de aristas
- **Síntoma:** un script que busca "los K vecinos del vértice más bajo" elige vértices del techo del domo.
- **Causa:** ordenar por distancia euclidiana XY funciona para AABB planos pero NO para mallas verticales.
- **Solución:** **siempre BFS sobre aristas** (`o.data.edges`).

### E-52 — "Pasa z_min" NO es "se ve apoyado" — la captura ES la verdad
- **Síntoma:** el test numérico dice `z_min = 0.0450 → apoyo OK` y la captura orbital muestra el objeto flotando.
- **Solución:** para `toca<=2` con `footprint>0`, aplicar `aplanar_dome.py` y re-capturar. Si en la captura AL MENOS UNA vista muestra gap, hay que corregir.
- **Fecha:** 2026-08-31 03:55

### E-53 — Nombres de objeto DIFEREN entre source y variantes (suffix `_M_`)
- **Síntoma:** un script que itera por patrón encuentra el objeto en `_media` y `_baja` pero NO en el `_lowpoly` source.
- **Solución:** iterar sobre `todos los SM_` y aplicar el fix a cada uno que cumpla `zmin <= Z_OBJ + 0.020`.
- **Fecha:** 2026-08-31 03:55

### E-54 — `aplanar_dome` también funciona vía CLI headless (sin socket MCP)
- **Síntoma:** el socket Blender muere a mitad de sesión.
- **Solución:** invocar Blender CLI directamente:
  ```bash
  blender -b --factory-startup --python-exit-code 1 --python-expr "..."
  ```
- **Fecha:** 2026-08-31 03:55

### E-55 — `capturar_angulos_headless.py`: capturas orbitales sin socket MCP
- **Síntoma:** `capturar_angulos.py` exige Blender GUI abierto.
- **Solución:** nuevo script `scripts-reutilizables/capturar_angulos_headless.py`.
- **Fecha:** 2026-08-31 20:24

### E-56 — `generar_variante.py` también exige socket MCP
- **Síntoma:** con Blender cerrado no se puede generar MEDIA/BAJA.
- **Workaround:** usar la versión headless del export directamente cuando tengas las variantes armadas a mano.

### E-57 — El shell NO expande globos entre comillas dobles
- **Síntoma:** `python contact_sheet.py "capturas/asset_az*.png" salida.jpg` falla.
- **Solución:** pasar los globs SIN comillas.

### E-58 — `track_to_quat(axis, up)` para orientar planos inclinados sin trigonometría manual
- **Solución:** usar el quaternion de track de Mathutils:
  ```python
  def track_to_euler(direction, axis='X', up='Z'):
      return direction.to_track_quat(axis, up).to_euler()
  ```

### E-59 — Alpha translúcido en Principled BSDF: `inputs['Alpha']` + `blend_method`
- **Síntoma:** un cristal debería verse semi-transparente pero sale opaco.
- **Solución:** usar `inputs['Alpha']` Y `blend_method = 'BLEND'`.

### E-60 — Assets que se apoyan sobre otros assets NO usan Z_APOYO
- **Síntoma:** un techo modular baja a la arena si se le aplica `delta = Z_APOYO - z_min`.
- **Solución:** el script del techo NO llama al reasentado. Usar assert de rango.

### E-61 — Overhang del alero (techo 2 cm más ancho que la pared)
- **Decisión arquitectónica:** feature intencional, no bug.

### E-62 — `generar_variante.py` re-asentaba INCONDICIONALMENTE
- **Síntoma:** assets que viven a otra altura aparecen enterrados en variantes MEDIA/BAJA.
- **Fix:** umbral de cordura `UMBRAL_REASENTADO = 0.25`:
  ```python
  if abs(delta) > UMBRAL_REASENTADO:
      print('RE-ASENTADO OMITIDO (E-62)')
  else:
      for o in piezas:
          if o.parent is None:
              o.location.z += delta
  ```

### E-63 — `exportar_godot.py` tiene whitelist de módulos: uno nuevo exporta 0 archivos EN SILENCIO
- **Síntoma:** export para un módulo nuevo devuelve `{"exportados": 0}`.
- **Fix:** agregar módulos nuevos a la tupla `MODULOS`.

### E-64 — Los `ERROR` de la GDExtension de voxel con el editor abierto son RUIDO
- **Consecuencia:** **no cerrar el editor del usuario para "desbloquear" el import.** El import SÍ funciona.

### E-65 — El sidecar se llama `<asset>.glb.import`, no `<asset>.import`
- **Solución — verificar por variante:**
  ```bash
  for v in alta media baja; do
    echo "$v: glb=$(ls $v/*.glb | wc -l)  import=$(ls $v/*.import | wc -l)"
  done
  ```

### E-66 — `contact_sheet.py`: el shell NO expande globos entre comillas dobles y el `argv` con `*` rompe el script
- **Fix interno:** detectar el `*` y expandirlo con `glob.glob()`.

### E-67 — `arena()` del helper ponía el top del disco en z=0, no en z=0.05
- **Fix:** constante `ALTURA_ARENA = 0.05` y `location.z = ALTURA_ARENA - profundo/2`.

### E-68 — `primitive_cube_add(size=1, scale=s)` produce un cubo de `s`, NO de `2*s`
- **Regla:** `scale` es la **dimensión final del cubo**, no "la mitad de la dimensión final". Cualquier línea `caja(..., ANCHO/2.0, ALTO/2.0, ...)` está MAL escrita.

### E-69 — Cuerda "colgante": la curva es una PARÁBOLA, no una catenaria `cosh`
- **Regla:** cuerda suelta → `cosh`; tablero con carga uniforme → parábola.

### E-70 — Contar los `SM_` ANTES de generar: el presupuesto ALTA es ≤16 objetos
- **Regla:** escribir la fórmula de conteo en el docstring antes de generar. Cualquier doble bucle `lado × repetición` crece multiplicativo.

### E-71 — Los ítems duplicados del checklist viven en SECCIONES DISTINTAS
- **Defensa obligatoria:** hacer `grep -in` GLOBAL al checklist antes de empezar.

### E-72 — mtime de `.import` más viejo que el `.glb` NO significa import desactualizado
- **Verificación correcta:** conteo por variante y existencia del `.scn`, no mtime.

### E-73 — Un travesaño horizontal a la altura del pecho/torso LEE COMO FALO
- **Regla:** si una pieza es **larga, delgada y horizontal** y queda alineada con la altura de la cadera/torso de una figura humanoide, **no la uses como elemento estructural único**.

### E-74 — Cosa cilíndrica que sobresale horizontalmente de un torso LEE COMO PICO
- **Regla:** las cosas que sobresalen de un cuerpo deben ir por las **extremidades** o en **dirección coherente** con la anatomía. Nunca perpendiculares al pecho.

### E-75 — `bpy.ops.object.join()` aplica la `inverse_matrix` del activo
- **Regla:** aplicar transformadas (`location=True, rotation=True, scale=True`) en CADA pieza ANTES del join.

### E-76 — API 4.x: `IDMaterials.pop(index, update_data=True)` ya no existe
- **Fix:** reemplazar `pop(index=0, update_data=True)` por `o.data.materials.clear()`.

### E-77 — `loft()` recibe anillos como `(z, cx, cy, rx, ry)`: Z PRIMERO
- **Patrón correcto:**
  ```python
  muestras = polilinea(pts, ts)
  anillos = [(p[2], p[0], p[1], r, r) for p in muestras]
  ```

### E-78 — Huella E-50 sobre anillos elípticos: el vértice que toca está en el CENTRO
- **Fix:** suela plana (caja debajo). La regla: **una superficie que toca el piso debería tener ≥4 vértices en sus esquinas, no 1 en el centro**.

### E-79 — Assets MONTADOS NO se asientan en Z_APOYO
- **Fix:** marcar con Empty `_MONTADO`. El script `generar_variante.py` lo detecta y omite el re-asentado.

### E-80 — `generar_variante.py` re-asienta assets al suelo: marcar MONTADOS con Empty `_MONTADO`
- **Fix:** detectar Empty `_MONTADO` y omitir re-asentado sin importar el delta.

### E-81 — Torso humano: el hombro NO es un anillo más ancho, es un CAP elipsoidal separado
- **Fix:** (1) Profundizar el pecho (`ry ≥ 0.13`). (2) Caps de deltoides como elipsoides separados. (3) Trapecio más largo.

### E-82 — Construcción de paths desde `dirname(__file__)`
- **Fix:** construir directamente desde `DIR_SCRIPTS` sin pasar por `RAIZ`+re-armar. El `assert basename(DIR_MOD) == '<NN>'` mata el bug.

### E-83 — `Mesh.materials.clear()` resetea `material_index` de TODAS las caras a 0
- **Fix:** respaldar `material_index` por cara, `clear()`, re-asignar:
  ```python
  idx_caras = [p.material_index for p in o.data.polygons]
  o.data.materials.clear()
  for m in vistos: o.data.materials.append(m)
  for p, mi in zip(o.data.polygons, idx_caras):
      p.material_index = mapa[mi] if mi < len(mapa) else 0
  ```

### E-84 — `clearance_cuerpo()` debe incluir los DELTOIDES
- **Fix:** añadir el término `DELTOIDES` al `min(...)` de `clearance_cuerpo()`.

### E-85 — `primitive_torus_add()` ya tiene el agujero en +Z: NO rotar 90°
- **Fix:** NO rotar. `primitive_torus_add()` ya produce un torus HORIZONTAL.

### E-86 — Mangas excluidas del check por diseño
- **Fix superior (E-89):** cada pieza declara contra qué partes se audita.

### E-87 — Los vértices de TAPA de un tubo cerrado quedan DENTRO del cuerpo
- **Fix:** marcar en vertex group `OCULTO`. El guard los salta.

### E-89 — Cada pieza de ropa declara contra qué PARTES del cuerpo se audita
- **Asignación típica:**
  ```python
  PARTES = {
      'SM_Camp_Camisa':     ('torso', 'deltoides'),
      'SM_Camp_Cordon':     ('torso',),
      'SM_Camp_Delantal':   ('torso', 'piernas'),
      'SM_Camp_Pantalones': ('piernas',),
      'SM_Camp_Mangas':     ('brazos', 'deltoides'),
  }
  ```

### E-90 — `construir_cabeza()` devuelve la cabeza en el FRAME LOCAL
- **Fix:** (1) Clave `'Z_CRANEo'` con "o" minúscula. (2) Subir TODAS las piezas con `OFFSET_CABEZA`. (3) Guard que mate el fallo silencioso.

### E-91 — `asentar()` rechaza herramientas alargadas: usar `asentar_herramienta()`
- **Tres condiciones:** `len(verts) >= 8`, `min(fp) >= 0.02`, `max(fp) >= 0.45 × L`.
- **Nunca delegar a `plantilla_asset.asentar` para herramientas.**
- **Mangos cónicos:** mantener `hz` CONSTANTE a lo largo del mango.

### E-92 — `loft()` NO puede hacer piezas HUECAS: usar `revolucion()`
- **Fix:** `revolucion(perfil, materiales, lados, idx_mat)` asigna material por TRAMO.
- **Verificación de orientación — volumen firmado:** `V > 0` = normales hacia afuera.

### E-93 — El volumen firmado SÓLO vale en caras PLANAS
- **Fix:** hacer la hoja **PLANA**. Verificar con `desvio_planar(pts)`.

### E-94 — `zmin_real()` mide con `matrix_world`, que queda VIEJO
- **Fix:** llamar a `bpy.context.view_layer.update()` **antes** de medir.

### E-95 — `tubo_arco()` para asas curvas
- **Función:** `tubo_arco(nombre, pts, radios, lados, material, ref)`.
- **Cuidado de degeneración:** pasar un `ref` que NO esté en el plano de la curva.

### E-70b — `prisma_contorno_en(bm, contorno, grosor, mi)` para inyectar piezas en un bmesh existente
- **Uso:** inyectar hojas dentro de un bmesh del tallo para no exceder presupuesto de objetos.

### E-96 — El podador de BAJA elige por CARAS, no por importancia
- **Fix:** controlar el recuento de caras del material a proteger. Subir `lados` si es necesario.

### E-97 — `hoja_util.py` es la nueva casa canónica de las hojas planas-arqueadas
- **Funciones:** `cruz`, `newell`, `desvio_planar`, `vol_firmado`, `prisma_contorno`, `prisma_contorno_en`, `hoja_plana_arqueada`.


### E-98 — `material_index` es GLOBAL al objeto, no por slot local
- **Síntoma:** se asigna un material por índice y queda asignado otro.
- **Causa:** el índice referencia la lista completa de materiales del objeto; si un
  objeto tiene menos slots que el índice máximo, Blender reasigna en silencio.
- **Fix:** todos los objetos del asset llevan la lista completa en el MISMO orden.

### E-99 — `BMFace.normal` vale `(0,0,0)` hasta llamar a `bm.normal_update()`
- **Síntoma:** al clasificar caras por normal recién creadas, todas caen en la misma
  rama y un material queda huérfano (caso real: tiles arada/regada de M33).
- **Fix:** `bm.normal_update()` DESPUÉS de crear las caras y ANTES de clasificar.

### E-100 — En `caja()` el `cz` es el CENTRO, no la base: el top real es `cz + sz/2`
- **Síntoma:** una pieza que "debe atravesar el techo" queda corta y su remate queda
  flotando, aunque el comentario del generador afirme lo contrario. Caso real: el caño
  de la chimenea de la choza ampliada (log 808) estaba en `PISO_Z+0.90` con `sz=3.20`
  → top real **2.605**, es decir 0.86 m DEBAJO del techo (3.464) y 1.50 m separado del
  sombrerete (4.105). La chimenea no atravesaba nada.
- **Causa:** confundir el argumento `cz` de `caja(nombre, mat, sx, sy, sz, cx, cy, cz)`
  (CENTRO de la caja) con su base. El top es `cz + sz/2`, no `cz`.
- **Fix:** calcular centro y tamaño a partir de las cotas deseadas:
  `centro = (base + top) / 2` y `size = top - base`. En la choza: base `PISO_Z+0.60`,
  top `PISO_Z+4.00` → `centro = PISO_Z+2.30`, `size = 3.40`.
- **Verificación:** el volumen firmado (E-92) **NO atrapa este bug** — una caja corta
  sigue siendo un sólido válido con normales correctas. Lo atrapa (a) comparar la cota
  declarada en el comentario contra `cz + sz/2`, o (b) mirar la hoja de contacto.
- **Aplica a:** cualquier elemento vertical que deba empalmar con otro: caños de
  chimenea, postes, columnas, mástiles, patas, pilotes.
- **Relacionado:** E-24 (medir sobre vértices reales), E-94 (`view_layer.update()`
  antes de medir), E-92 (volumen firmado).

### E-101 — Calcular la raíz del repo contando `..` a mano
- **Síntoma:** un script de auditoría ubicado en `tools/mcp/blender-mcp/` reporta
  `GLB en Godot: 0` y `.scn importados: 0` aunque el juego tiene 373 GLB, y en
  consecuencia marca **123 ítems** como "incompletos" sin que falte nada.
- **Causa:** `PROY = os.path.join(ROOT, '..', '..')` sube 2 niveles desde
  `.../juego-isla-ancestral/tools/mcp/blender-mcp` y aterriza en
  `.../juego-isla-ancestral/tools`, no en la raíz. Hacían falta **3** niveles.
  El número mágico depende de la profundidad del archivo, así que se rompe en
  cuanto el script se mueve.
- **Fix:** derivar la raíz buscando un marcador, nunca contando niveles:
  ```python
  def raiz_repo():
      d = os.path.dirname(os.path.abspath(__file__))
      for _ in range(8):
          if os.path.isfile(os.path.join(d, 'AGENTS.md')):
              return d
          p = os.path.dirname(d)
          if p == d: break
          d = p
      raise SystemExit('No encontre AGENTS.md')
  ```
- **Verificación:** el propio script imprime los totales indexados; si un índice
  da **0** es bug del script, no dato del repo. Desconfiar siempre del 0.
- **Aplica a:** todo script de tooling que deba escribir/leer fuera de su carpeta.
- **Relacionado:** E-63 (whitelist de módulos que silencia exportaciones).

### E-102 — Quitar solo `_media`/`_baja` al derivar el nombre base de un `.blend`
- **Síntoma:** un indexador de `.blend` encuentra 424 archivos pero ninguno
  coincide con los assets del checklist: todo el catálogo aparece "ausente".
- **Causa:** los `.blend` se llaman `<asset>_lowpoly.blend`, `<asset>_alta.blend`,
  `<asset>_lowpoly_media.blend`, `<asset>_alta_baja.blend`. Si solo se quitan los
  sufijos de **variante** (`_media`, `_baja`) queda `cristal_ancestral_lowpoly`,
  no `cristal_ancestral`. Hay que quitar TAMBIÉN los de **calidad**.
- **Fix:** aplicar los sufijos en orden variante → calidad y cortar en el primero
  que matchee: `('_media', '_baja', '_alta', '_lowpoly')`.
- **Verificación:** cruzar el total de bases derivadas contra la cantidad de
  nombres DISTINCTOS de GLB (145 en ALTA); si el índice de blends da ~0 hay bug.
- **Aplica a:** cualquier script que reconstruya el nombre del asset desde el
  nombre del archivo (auditorías, export, generación de variantes).
- **Relacionado:** E-43 (prioridad de sufijos por variante en `exportar_godot.py`).

### E-103 — Sidecar `.glb.import` sin su `.glb`: el checklist dice "completo" y el GLB no existe
- **Síntoma:** Godot muestra el asset en el FileSystem con su `.import`, las
  escenas que lo referencian cargan, pero el recurso 3D está vacío o roto. Un
  checklist que se audite por "existe el `.import`" sigue dando OK.
- **Causa:** los GLB son archivos **nuevos** (nunca commiteados: `git ls-files`
  no los lista). Cualquier `git clean -fd`, `git stash -u` o checkout de otro
  agente borra los binarios y deja los sidecars `.glb.import`, que sí están en
  el working tree. Caso real (log 809): **56 GLB perdidos** — 41 ALTA, 4 MEDIA,
  11 BAJA — todos de 18-Casas (casa_mediana + 30 `decor_*`) y 33-Agricultura
  (10 assets), exactamente los dos módulos con assets sin commitear.
  Ninguno estaba en git, así que `git checkout` **no** los recupera.
- **Detección:** comparar los conjuntos, no mirar mtimes:
  ```python
  glb = {f[:-4] for f in os.listdir(d) if f.endswith('.glb')}
  imp = {f[:-len('.glb.import')] for f in os.listdir(d) if f.endswith('.glb.import')}
  huerfanos = imp - glb          # sidecars sin binario
  ```
  (`auditar_checklist.py`, sección **E** del reporte.)
- **Fix:** re-exportar SOLO los faltantes, sin `EXPORT_FORZAR` (que reescribiría
  los 317 restantes y tocaría trabajo de otros agentes). Como el export saltea
  cuando el destino existe y es más nuevo que el `.blend`, basta con acotar por
  módulo: `EXPORT_MODULOS="18-Casas;33-Agricultura" blender -b --factory-startup
  --python scripts-reutilizables/exportar_godot.py` → **56 exportados, 0 errores**.
  Después, reimportar en Godot: `Godot --headless --path game/isla-ancestral --import`.
- **Verificación:** huérfanos = 0 y el hash que Godot guarda en el nombre del
  `.scn` **no cambió** (casa_mediana sigue en `f20efca8…`/`d0ae8a0a…`/`f194e690…`
  para ALTA/MEDIA/BAJA), lo que confirma que la re-exportación reproduce el
  binario original. Ojo: el hash del `.scn` de Godot **NO** es el md5 del GLB
  (se probó: 0/373 coinciden) — no usarlo como prueba de identidad de archivo.
- **Lección de proceso:** commitear los GLB nuevos apenas se exportan. Mientras
  sean untracked, son recuperables solo regenerándolos desde el `.blend`.
- **Aplica a:** todo asset recién creado; auditar por **conjuntos de nombres**,
  nunca por mtime ni por existencia del sidecar.
- **Relacionado:** E-49 (salto por mtime miente), E-63 (whitelist de módulos),
  E-65/E-72 (verificar import de Godot por conteo).

### E-104 — Una sola caja apoyada aporta 4 vértices: el guard de apoyo (`toca >= 8`) la rechaza

- **Síntoma:** el generador aborta con `apoyo puntual: 4 verts (E-50)` en un asset
  que *sí* está apoyado. Pasó dos veces en el log 811: la nevera con el zócalo
  (1.00 × 0.85) directo al piso, y el cuadro con una peana única de 0.70 × 0.34.
- **Causa:** el guard de `asentar()` cuenta **vértices reales en z_min**, no
  superficie de contacto. Una caja aporta exactamente sus 4 vértices inferiores,
  por ancha que sea: 4 < 8 y el asset se rechaza aunque la huella mida 0.70 m.
- **Fix:** dar **2 o más apoyos** (2 cajas = 8, 4 cajas = 16) o, mejor,
  **cilindros** (ver E-105). Además suele ser más coherente con el objeto: un
  pozo de conserva va sobre tacos de piedra, no cementado al piso; un cuadro
  con marco va sobre dos peanas, no sobre una base corrida.
- **Verificación:** `toca` en la salida de `auditar_mobiliario.py` debe ser
  `>= 8` en ALTA. Si da 4, falta un apoyo; si da 8 justos, no hay margen para
  BAJA (E-105).
- **Aplica a:** todo asset de cuerpo único (electrodomésticos, arcones, cuadros,
  maceteros, cofres) que antes se resolvía "apoyando la caja grande".
- **Relacionado:** E-50 (apoyo puntual), E-91 (piezas < 0.7 m no usan `asentar()`),
  E-105.

### E-105 — El decimate de BAJA se come primero los apoyos chicos: curar con VÉRTICES, no con asserts

- **Síntoma:** el asset pasa ALTA y MEDIA con `toca=16`, y en BAJA cae a
  `toca=5` y se rechaza. Nada cambió en la geometría entre ALTA y BAJA salvo el
  decimate. Casos reales (log 811): `nevera_rustica` 16 → **5** y
  `cuadro_ancestral` 8 → **2**.
- **Causa:** el podador fusiona por material y aplica decimate sobre la malla
  **completa**. Las patas son una fracción ínfima de esa malla (en la nevera,
  4 patas de 0.16 m contra un cuerpo de 0.92 × 0.78: ~17%), así que el decimate
  las colapsa primero. Es E-96 (se poda el material con menos caras) cruzado con
  el comportamiento del decimate: **lo chico y poco denso desaparece primero**.
- **Fix — darles vértices, NUNCA relajar el guard:** pasar los apoyos de caja a
  **cilindro**. Un cilindro de 16 segmentos aporta 16 vértices en la base; 4
  cilindros dan 64. Resultado medido:
  - `nevera_rustica`: 4 cilindros r 0.11, h 0.08 → `toca = 64 → 64 → 44`
    (ALTA/MEDIA/BAJA). Antes: 16 → 16 → **5**.
  - `cuadro_ancestral`: 2 cilindros r 0.17, h 0.05 → `toca = 32 → 32 → 22`.
    Antes: 8 → 8 → **2**.

  Bajar el `>= 8` del guard a `>= 4` habría "arreglado" el síntoma y dejado pasar
  assets que flotan de verdad: no hacerlo nunca.
- **Regla derivada:** en un asset cuyos apoyos compartan material con un cuerpo
  mucho más grande, los apoyos deben ser **la parte más densa en vértices** de la
  malla, no la más chica.
- **Verificación:** auditar las 3 variantes y exigir `toca >= 8` en **BAJA**
  (no solo en ALTA). Valores observados en el lote que quedaron justos en el
  mínimo y conviene vigilar: `estanteria` BAJA `toca=8`, `maceta_interior` BAJA
  `toca=8`.
- **Aplica a:** generación de variantes MEDIA/BAJA de cualquier mueble con patas,
  peanas o tacos.
- **Relacionado:** E-96 (poda por caras), E-104, E-50.
