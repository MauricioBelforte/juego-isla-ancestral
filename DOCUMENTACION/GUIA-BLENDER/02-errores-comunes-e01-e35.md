# 02 — Errores Comunes de Blender (E-01 a E-35)

**Modelo:** MiniMax-M3 (OpenCode)
**Plataforma:** OpenCode CLI
**Fecha:** 2026-09-10

**Propósito:** Extraído de OBSOLETOS/09-GUIA-BLENDER.md §3 "Registro de Errores", errores E-01 a E-35. Documenta síntomas, causas, soluciones y fechas de errores comunes encontrados al modelar assets con Blender vía scripting (bpy).

---

> Formato: síntoma / causa / solución / fecha. Agregar TODO descubrimiento nuevo (obligatorio, AGENTS.md §26).

### E-01 — Tronco "escalonado" al apilar cilindros
- **Síntoma:** tronco curvado con N cilindros de `primitive_cylinder_add` apilados muestra escalones/huecos en cada unión, aún solapando y reduciendo el giro.
- **Causa:** cada cilindro tiene sus rings de tapa; al decrecer el radio, la silueta muestra cada unión. Inherente a la técnica.
- **Solución:** construir el tronco como **UNA sola malla con `bmesh`**: rings de vértices interpolados sobre la curva (radio y posición en función de `t`), puenteados con caras laterales + tapas. Bonus: 15 objetos vs 24.
- **Fecha:** 2026-08-27

### E-02 — `NameError: name 'cos' is not defined` (código remoto)
- **Causa:** el script usaba `cos()` sin importarla (`from math import radians, sin, pi`). El error solo aparece al ejecutar en el namespace remoto.
- **Solución:** importar todas las funciones de `math` usadas. Validar imports antes de enviar.
- **Fecha:** 2026-08-27

### E-03 — Captura cenital / sin materiales / con grilla
- **Causa:** viewport por defecto sin cámara activa ni modo renderizado.
- **Solución:** el script crea `CAM_<Asset>` con encuadre fijo; `cap_blender.py` captura offscreen desde esa cámara, overlays off, modo Rendered.
- **Fecha:** 2026-08-27

### E-04 — El `.blend` se guarda en la carpeta de instalación de Blender
- **Indicio:** `blend: D:\Archivos de programa\Blender Foundation\Blender 4.2\tools\mcp\...`
- **Causa:** el script ejecutado vía MCP usa `os.getcwd()`, pero el cwd del proceso de Blender es su carpeta de instalación, no la raíz del proyecto.
- **Solución:** usar **ruta absoluta** construida desde la raíz del proyecto (constante `RAIZ` en el script) — ver §6.3 regla 2.
- **Fecha:** 2026-08-27

### E-07 — `blender -b` (background) NO arranca el servidor MCP del addon
- **Síntoma:** el puerto 9876 nunca abre; en la consola de Blender aparece `BlenderMCP: cannot start server in background mode (blender -b) - commands would never execute` y luego `[BlenderMCP] Servidor iniciado OK (puerto 9876)` (engañoso, porque la `bpy.ops.blendermcp.start_server()` reporta OK pero el thread de fondo se detiene al cerrar la app headless).
- **Causa:** el addon BlenderMCP implementa el socket como un **timer/thread en el event loop de la UI de Blender**; en `-b` no hay event loop de UI, así que el socket muere.
- **Solución:** arrancar Blender **con GUI** (`blender.exe --python arrancar_servidor_mcp.py`, sin `-b`). El usuario debe tener Blender abierto en la sesión; el addon abre el socket automáticamente. Contradice la receta de §1 (que muestra `-b`); §1 debe corregirse.
- **Verificación 2026-08-28 (WorkBuddy):** `blender.exe -b --python arrancar_servidor_mcp.py` → "server shut down" tras 1 s. Con GUI abierta: `get_scene_info` → `success` con 3 objetos. El server es el del addon, no un servidor headless independiente; el flujo V5 es **asistido** (Blender con GUI) o **MCP-tools** (V5 vía el server MCP registrado como `blender` en `~/.workbuddy-ai/mcp.json`).
- **Fecha:** 2026-08-28

### E-08 — `primitive_cylinder_add` no acepta `radius2` (Blender 4.x)
- **Síntoma:** `Code execution error: Converting py args to operator properties: keyword "radius2" unrecognized`.
- **Causa:** en Blender 4.x `primitive_cylinder_add` quedó con un único parámetro `radius` (cilindro recto). El **cono** sí conserva `radius1` / `radius2`.
- **Solución:** piezas con afinado (raíces, muñones, cuernos, picos) → `primitive_cone_add(radius1=..., radius2=...)`. `primitive_cylinder_add` solo para radio constante.
- **Fecha:** 2026-08-28

### E-09 — El tilt de una pieza plana eleva su tope real muy por encima del espesor nominal
- **Síntoma:** tiras de hoja de espesor 0.06 centradas en z=0.045 (tope nominal 0.075) dan bounding box `z_max = 0.134`. Los objetos apoyados encima quedan hundidos ~10 cm.
- **Causa:** al inclinar una pieza larga y fina un ángulo θ, su semi-eje Z efectivo pasa a ser `sqrt((L/2·sinθ)² + (e/2·cosθ)²)`. Con L=0.95, e=0.06 y θ=8°: 0.072 en vez de 0.03. El bounding box lo delata, el cálculo nominal no.
- **Solución:** **nunca** posicionar apoyos con el espesor nominal. Medir primero con `scripts-reutilizables/verificar_bounds.py` y recién entonces fijar la altura. En el nido de cocos la base pasó de `R*1.20` a `R*1.65` (z_min coco 0.133 vs z_max hoja 0.134).
- **Fecha:** 2026-08-28

### E-10 — El modelo en curso puede no aceptar imágenes (revisión visual bloqueada)
- **Síntoma:** al leer un PNG de captura: "the current model does not support images. Content filtered."
- **Causa:** la sesión cambió a un modelo no multimodal; la capacidad de visión no es una propiedad estable del entorno, depende del modelo activo.
- **Solución:** sustituir la revisión visual por **QA numérico** (`verificar_bounds.py` + `get_object_info`): cantidad de objetos, `z_min`/`z_max` (¿flota? ¿se hunde?), rango X/Y, materiales asignados, polígonos. Dejar constancia en el `Logs/` de que la revisión visual queda pendiente y retomarla al volver a un modelo multimodal.
- **Fecha:** 2026-08-28

### E-11 — Detalles posicionados en coords de mundo se "despegan" del cuerpo al rotarlo
- **Síntoma:** en el nido de cocos, los 3 "ojos" (esferas pequeñas) eran invisibles: aunque se renderizaban, quedaban **enterrados dentro del coco**. La distancia ojo→centro del coco era ~0.16, menor que el semieje vertical efectivo de la malla (~0.22). Y al rotar el coco, los ojos se quedaban en su sitio (fijo al mundo) en vez de seguirlo.
- **Causa:** el código original creaba los ojos con `location = pos_coco + offset_mundo` y los dejaba en la colección suelta. El `offset_mundo` se calculó para el coco sin rotar; al rotar, la posición en mundo del ojo no acompañaba.
- **Solución:** **parenteo + `matrix_parent_inverse` identidad**. `oj.parent = coco; oj.matrix_parent_inverse = Matrix()` hace que `mundo = M_coco @ local`; poniendo el ojo en coords locales (`radio*0.33·cos(ang)`, `radio*0.33·sin(ang)`, `radio*0.80`) el ojo sigue la rotación del coco y queda sobre la superficie. **Regla general:** cualquier detalle "pegado" a un cuerpo (ojos, remaches, ojos de cerradura, vetas, grietas) tiene que ser hijo del cuerpo, no un objeto independiente.
- **Validación:** `scripts-prueba/verificar_ojos_coco.py` usa `obj.ray_cast(origen_fuera, -direccion)` en el espacio local del coco; calcula `ratio = distancia_ojo / radio_superficie_en_esa_direccion`. 0.90–1.15 = sobre la superficie. **Es la forma correcta de chequear, no usar el semieje del bounding box (que sobreestima por la rotación).**
- **Fecha:** 2026-08-28

### E-12 — La base de apoyo debe tener cobertura COMPLETA de la planta
- **Síntoma:** nido de cocos con 5 tiras de hoja de 14 cm de ancho en un abanico de ±70°. La vista por defecto lo mostraba correcto, pero al rotar la cámara se veía que 3 de los 6 cocos inferiores (los que caían a 137°, 200° y la zona de atrás) colgaban sobre arena desnuda con 1.7 cm de aire. El tronco caído, la palmera común, la inclinada, la joven y las cañas de bambú tenían un problema análogo: el z_min calculado caía 2-9 cm por encima de la arena porque se usaba el espesor nominal de la base sin medir el bounding box real con tilt/ruido.
- **Causa:** confundir "el apoyo más alto" con "el apoyo bajo el objeto" y no auditar cada uno de los puntos de la planta de lo que se sostiene.
- **Solución — tres reglas combinadas:**
  1. **Cobertura total del apoyo:** el elemento sobre el que se asienta otro (lecho, disco, raíces) debe cubrir TODA la planta horizontal del objeto soportado. Si hay anillos/abanicos, su ancho × nº de tiras debe sumar al menos 2π·r_max del objeto.
  2. **Autocorrección medida en caliente (E-09):** al final del script, medir `z_min` del grupo y trasladar hasta `Z_APOYO = 0.045` (5 mm hundido en la arena). El script no debe "calcular" el apoyo a partir de un espesor nominal: lo **mide**.
  3. **Auditor post-corrección:** `scripts-reutilizables/auditar_apoyos.py` recorre todos los `crear_*_lowpoly.py` de un módulo, los ejecuta y reporta qué objetos tocan el suelo. Marca FLOTA si `z_min > 0.05` PERO `z_min < 0.50` (los que están arriba del suelo no se auditan, son parte de la composición).
- **Receta para el tronco acostado:** los árboles y troncos tienen **múltiples puntos bajos** (raíces, muñones, hojarasca) además del propio tronco. Asentar el conjunto completo (todos los `SM_*` del script) en bloque, no solo el tronco.
- **Directiva del usuario (2026-08-28):** *"así con todos los objetos que creemos"*. Aplica a TODO asset que tenga una pieza en contacto con la arena o con otra pieza de apoyo. La autocorrección debe ir embebida en el script (no en un script externo posterior), para que cada re-ejecución produzca la pose correcta.
- **Fecha:** 2026-08-28

### E-13 — Una sola captura frontal puede ocultar flotación (revisar desde varios ángulos)
- **Síntoma:** después de "corregir" el apoyo del nido de cocos (z_min 0.067) y verificar con la cámara default, el usuario giró la cámara manualmente en Blender y reportó que seguía flotando. La causa: el plano de la cámara default miraba el lado "bueno" del asset; el problema estaba en el lado opuesto. Numericamente el `z_min` global estaba bien, pero la pieza con `z_min` más alto era la del lado iluminado, no la del lado contrario.
- **Causa:** confiar en una sola captura cenital/frontal. Una pieza de un objeto extenso (montón de cocos, racimo de cañas, árbol) puede tener su punto de apoyo bien en una zona y flotar claramente en otra, sin que la captura default lo muestre.
- **Solución — captura orbital obligatoria:**
  1. Usar `scripts-reutilizables/capturar_angulos.py` para generar N capturas (default 4, recomendado 6 u 8) rotando la cámara alrededor del asset a igual distancia y altura.
  2. **Revisar TODAS las capturas** — si el modelo en curso no acepta imágenes, pedir a uno multimodal que las revise, o al menos verificar que no haya **una sola** con luz visible entre el objeto y su base.
  3. Si una sola captura muestra flotación, el asset NO está aprobado aunque el resto esté bien.
- **Procedimiento completo (directiva del usuario 2026-08-28):** *"si es necesario girá la cámara y sacá captura, pero no deben flotar los objetos en la base"*. Esto es regla de DoD del checklist, no una sugerencia.
- **Fecha:** 2026-08-28

### E-14 — `wm.read_factory_settings()` desde el socket MCP mata el listener del addon
- **Síntoma:** tras ejecutar `bpy.ops.wm.read_factory_settings(use_empty=True)` por el socket 9876, Blender sigue vivo pero `127.0.0.1:9876` deja de escuchar. Procesos psutil: `Blender 26224 → connections=[]`. No hay forma de enviar más comandos sin que el usuario re-abra el socket manualmente desde el panel.
- **Causa:** el addon BlenderMCP vive como atributo `bpy.types.blendermcp_server` con su socket TCP en un thread. `wm.read_factory_settings()` resetea `bpy.types` y elimina ese atributo, pero el thread del server queda en estado inconsistente (el socket no se reabre).
- **Solución provisional:** el usuario debe re-click en N → BlenderMCP → "Connect to MCP server" en el panel, o bien cerrar y reabrir Blender con el último .blend.
- **Solución definitiva — NO usar `wm.read_factory_settings` desde el socket MCP.** Para empezar limpio dentro de un script, usar la limpieza idempotente que ya hacen los `crear_*_lowpoly.py`: `bpy.data.objects.remove(...)` + `bpy.data.{meshes,materials,lights,cameras,worlds}.remove(... users==0)`. Eso no toca `bpy.types` ni al server.
- **Cuándo se justifica `wm.read_factory_settings`:** solo si Blender quedó en un estado irrecuperable (cuelgue, escena corrupta). En ese caso, asumir que después hay que re-click en el panel.
- **Fecha:** 2026-08-28
- **Caso que lo gatilló:** prueba para "resetear Blender" al inicio del turn, para arrancar desde escena vacía. Le costó la sesión ~1 h al agente mientras esperaba la reconexión del usuario.

### E-15 — `BMesh data of type BMVert has been removed` al leer `bm.verts[...]` tras `bm.free()`
- **Síntoma:** `RuntimeError: BMesh data of type BMVert has been removed` al iterar o indexar la malla de un bmesh después de haberla pasado a un objeto con `bm.to_mesh(me)` y liberado con `bm.free()`.
- **Causa:** `bm.free()` destruye los handles de la capa Python; acceder a `bm.verts`, `bm.faces`, `bm.edges` después es indefinido.
- **Solución:** nunca releer el bmesh tras `bm.free()`. Si se necesita inspeccionar la malla, hacerlo sobre el `me` (Mesh) o el `objeto` ya creado. Si se necesita información durante la construcción, guardarla en variables Python antes de `bm.free()`.
- **Fecha:** 2026-08-28

### E-16 — `faces.new(): face already exists` al cerrar una superficie por revolución/loft
- **Síntoma:** `ValueError: faces.new(verts): face already exists` al construir la última cara de un cilindro/loft/revolución de bmesh.
- **Causa:** se intenta cerrar la superficie con un cuadrilátero plano, pero ya existe una cara con esos mismos 4 vértices (creada durante el bandeo de la primera vuelta, por error, o el winding se invierte y se considera la misma cara).
- **Solución:** los **casquetes** de cierre deben tener **winding invertido** respecto al bandeo cilíndrico (regla de la mano derecha de las normales). Si el cuerpo va `i, i+1, i+1', i'` el casquete de cierre va `i, i', i+1'` (reverso) o usar `faces.new((v0, vN, vN-1, ...))`. Adicionalmente, verificar que no se haya creado una cara duplicada con esos mismos índices.
- **Caso de uso en el proyecto:** tapa del cofre ancestral (medio cilindro con eje en X). Sin el winding invertido, el casquete +X o el −X falla con `face already exists`.
- **Fecha:** 2026-08-28

### E-17 — `StructRNA of type Material has been removed` al limpiar materiales con `users==0`
- **Síntoma:** al ejecutar dos bloques de limpieza consecutivos (uno al inicio del script y otro a mitad), los `data.remove(... users==0)` dejan referencias inconsistentes y los objetos creados luego pierden su material.
- **Causa:** eliminar materiales con `users==0` cuando todavía hay objetos no procesados (creados tras la primera limpieza) que intentarán asignar uno que acaba de ser barrido.
- **Solución:** mantener **una sola limpieza idempotente al inicio** del script (limpia `objects`, `meshes`, `materials`, `lights`, `cameras`, `worlds` con `users==0`) y **nunca** repetirla a mitad. La limpieza es la misma que en E-14.
- **Fecha:** 2026-08-28

### E-18 — `matrix_parent_inverse = Matrix()` solo vale si el padre tiene `matrix_world` identidad
- **Síntoma:** herramientas (pico de piedra/hierro, antorcha de mano, hacha, machete) se renderean con la cabeza/pomo/llama **separados del mango** y la herramienta parada vertical, aunque numéricamente el `z_min` del grupo da "correcto" (positivo, pero el grupo entero está mucho más alto de lo esperado: ≈ +0.5 en vez de ≈ −0.05).
- **Causa:** en E-11 se documentó que el parenteo de detalles requiere `matrix_parent_inverse = Matrix()`. Esa es la **inversa de la matriz identidad**, así que solo es válida cuando el **padre** también tiene `matrix_world = Matrix()` (sin rotar, sin escalar, sin trasladar). Si el mango (padre) está rotado `−90°` en Y para alinear la herramienta horizontal, su `matrix_world` ya no es identidad. Hacer `hijo.matrix_parent_inverse = Matrix()` entonces **no compensa** la rotación del padre: el hijo hereda esa rotación al calcular su `matrix_world = M_padre @ M_local`. El resultado: el `+X` local del hijo apunta a `+Z` mundial → la herramienta queda parada en vertical, y las piezas se ven "sueltas" porque sus posiciones locales fueron calculadas asumiendo mango horizontal.
- **Solución:** usar la **inversa real** del `matrix_world` del padre, no `Matrix()`:
  ```python
  def hijo(objeto, padre):
      bpy.context.view_layer.update()           # actualiza matrix_world del padre
      objeto.parent = padre
      objeto.matrix_parent_inverse = padre.matrix_world.inverted()
      return objeto
  ```
  Reemplaza las N líneas `X.parent = Y; X.matrix_parent_inverse = Matrix()` por `hijo(X, Y)`.
- **Receta general — baking sin transformaciones:** si los hijos se crean **en coordenadas absolutas de mundo** (con `location` ya en su posición final) y los padres tienen transformaciones, llamar `hijo` con la inversa real evita que el padre "arrastre" a los hijos a una pose no intencionada. Si en cambio los hijos se construyen en **coordenadas locales** del padre, alcanza con `Matrix()`, pero hay que asegurarse de que las coordenadas locales sean correctas.
- **Diagnóstico rápido:** si ves la herramienta parada vertical con piezas separadas, imprime `padre.matrix_world` y `padre.rotation_euler`. Si `rotation_euler ≠ (0,0,0)`, es E-18.
- **Fecha:** 2026-08-28

### E-19 — El cono de `primitive_cone_add` nace a lo largo del **eje Z local**, no del X ni del Y
- **Síntoma:** al crear un cono para hacer una proa de bote apuntando a `+X`, el cono queda apuntando hacia **arriba** (`+Z`) aunque se le asigne `rotation_euler = (0, 0, math.radians(-90))`. El bounding box da un `z_max` exagerado (cono vertical) en vez del esperado horizontal.
- **Causa:** `primitive_cone_add` crea la geometría con el eje de revolución a lo largo del **Z local**. Rotar el cono sobre su propio eje Z **no cambia la dirección** del cono (es simétrico axialmente). Hay que rotar sobre un eje **perpendicular** al eje del cono: Y (o X) según a dónde se quiera apuntar.
  - Para apuntar a `+X`: `rotation_euler = (0, math.radians(90), 0)` (rota 90° sobre Y, lleva el `+Z` local a `+X` mundial).
  - Para apuntar a `−X`: `rotation_euler = (0, math.radians(-90), 0)`.
  - Para apuntar a `+Y`/`−Y`: rotar sobre X.
- **Problema secundario (escalado):** tras rotar sobre Y, el eje local X del cono cae en el `−Z` mundial. Escalar sobre X aplasta el cono en altura (lo que en este caso sirve para que la sección coincida con el casco), pero hay que **medir el bounding box** después de escalar para confirmar.
- **Receta del proyecto (proa del bote):** `cone(vertices=4, radius1=0.21, radius2=0.0, depth=0.30, loc=(0.575, 0, 0.10))` con `rotation=(0, 90°, 0)` y `scale=(0.43, 1.0, 1.0)` produce una proa apuntando a `+X` con sección transversal 0.21 (Y) × 0.13 (Z), centrada en y=0.
- **Diagnóstico rápido:** si el cono queda vertical con la punta hacia arriba tras una rotación, es E-19. Imprimí `o.rotation_euler` y `o.dimensions` antes y después de aplicar la transformación.
- **Alternativa a la rotación:** usar `primitive_cube_add` con `scale=(depth/2, radius1, radius2)` y modelar la proa con un tetraedro o pirámide a mano vía bmesh (más control, más código).
- **Fecha:** 2026-08-28

### E-20 — Eevee Next sin SSR muestra materiales metálicos / coat **planos** (sin highlights)
- **Síntoma:** al renderizar un asset con `Metallic > 0.5` o `Coat Weight > 0.5` (especialmente si además hay `Emission > 0`), el material se ve **sin highlights, opaco, como un color plano**. El mismo material con Cycles se ve brillante.
- **Causa:** `Eevee Next` (motor por defecto en Blender 4.2+) viene con `use_ssr = False` y `use_raytracing = False` por defecto. Sin SSR (Screen Space Reflections), no hay forma de calcular rebotes de luz del entorno, así que los materiales pulidos no muestran nada.
- **Workaround sin HDRI:** para que un material con `metallic 0.85 + coat 1.0` se vea brillante, hay que **activar SSR + raytracing ANTES de `bpy.ops.render.render()`**:
  ```python
  escena = bpy.context.scene
  escena.eevee.use_ssr = True
  escena.eevee.use_ssr_refraction = True
  escena.eevee.use_raytracing = True
  ```
  Y subir `Emission Strength` para que el material emita su propio brillo (0.5 a 4.5 según el caso).
- **Donde activar:** la activación puede vivir en el **script de captura** (no en el del asset) para no contaminar el .blend. `capturar_angulos.py` ya lo hace.
- **Diagnóstico rápido:** si el asset se ve opaco pero los materiales tienen emission > 0, es E-20. Activá SSR y volvé a capturar.
- **Fecha:** 2026-08-28

### E-21 — `wm.save_as_mainfile` falla con `Unable to make version backup` si existe `.blend@`
- **Síntoma:** al guardar un `.blend`, Blender devuelve error: `Unable to make version backup / Version backup failed (file saved with @)`. El archivo a veces queda en blanco.
- **Causa:** Blender intenta crear un backup `ruta.blend@` antes de sobreescribir `ruta.blend`. Si ya existe un `.blend@` de un crash previo, no puede sobreescribirlo.
- **Solución:** borrar el `@` antes de guardar:
  ```python
  if os.path.exists(ruta + '@'):
      os.remove(ruta + '@')
  bpy.ops.wm.save_as_mainfile(filepath=ruta)
  ```
- **Diagnóstico rápido:** si el error menciona "version backup" o "@", es E-21. Borrá el `@` huérfano.
- **Fecha:** 2026-08-28

### E-22 — `bpy.ops.object.modifier_apply.poll()` falla por socket MCP
- **Síntoma:** al aplicar un modificador (DECIMATE, MIRROR, etc.) desde un script ejecutado por el socket MCP del addon Blender, sale `Operator bpy.ops.object.modifier_apply.poll() failed, context is incorrect`. El modificador no se aplica.
- **Causa:** `bpy.ops.object.*` requiere un contexto activo (viewport con objeto activo seleccionado) que el socket MCP no provee. El socket ejecuta código en modo "background" sin contexto de UI.
- **Solución:** aplicar el modificador evaluando el depsgraph y reasignando la malla. No usar `bpy.ops`:
  ```python
  dg = bpy.context.evaluated_depsgraph_get()
  me_eval = bpy.data.meshes.new_from_object(o.evaluated_get(dg))
  mats = [m for m in o.data.materials if m is not None]
  o.data = me_eval
  for m in mats:
      o.data.materials.append(m)
  o.modifiers.clear()
  ```
- **Diagnóstico rápido:** si el error menciona "poll() failed" y "modifier_apply", es E-22. Usá el patrón de depsgraph.
- **Aplica a:** `modifier_apply`, `transform_apply`, `select_all`, `shade_flat` (algunos), `delete` (algunos), y casi todos los `bpy.ops.object.*` con contexto.
- **Excepción:** `bpy.ops.wm.open_mainfile` y `bpy.ops.wm.save_as_mainfile` SÍ funcionan por socket (no requieren contexto de viewport).
- **Fecha:** 2026-08-28

### E-23 — Decimate agresivo (ratio 0.5) destruye mallas planas lowpoly
- **Síntoma:** tras `DECIMATE ratio=0.5` sobre mallas con cajas de 6 caras (paneles, marcos, base), las caras quedan como triángulos grandes rotos que rompen la silueta y dejan huecos. Visualmente: el cofre se ve "agujereado" o "con triángulos flotantes".
- **Causa:** `DECIMATE` colapsa vértices de mallas planas sin respetar las aristas duras. Como las caras son grandes, cada colapso deforma regiones enteras en vez de suavizar.
- **Solución doble:**
  1. **Subir el ratio a 0.7** (corte más suave, mantiene la silueta, deja ~80 % de la geometría en mallas planas).
  2. **Marcar como `_NOFUNDIR`** las piezas con detalle fino (costillas, cerradura, gemas, ojos, falleba, asa, tirador) — no se funden ni se decimatan. El sufijo explícito o matching por lista `CRITICAS_NO_FUNDIR`.
- **Diagnóstico rápido:** si la BAJA de un asset tiene triángulos grandes o huecos visibles, es E-23. Subí el ratio y/o protegé las críticas.
- **Calibración del umbral de poda** (asociado): en `generar_variante.py` se usa `UMBRAL_PODA = 1e-4 m³` (cubo 4.6 cm) — por debajo caen glifos y tirador, NO caen la gema ni las asas.
- **Fecha:** 2026-08-28

### E-24 — El re-asentado debe medir vértices reales, no las 8 esquinas del AABB
- **Síntoma:** tras re-asentar una pieza rotada, el conjunto queda flotando a una altura absurda (ej. el Soporte de `palanca_madera` quedó a +0.486 m del suelo cuando el Brazo inclinado se midió desde el AABB). Otro caso: `verificar_visual.py roca_comun_lowpoly SM_ 6` reportaba `z_min -0.1092 → HUNDIDO 0.154 m` cuando la roca estaba perfectamente apoyada a z=0.045.
- **Causa:** `object.bound_box` devuelve **8 esquinas del AABB en el frame local del objeto** — incluye esquinas donde NO hay geometría real. Si el objeto está inclinado/rotado, la proyección de esas esquinas al world space arrastra el `z_min` a valores irreales (incluso negativos para mallas rotadas hacia abajo). Caso roca_comun: `SM_Roca_Comun_Chica` con `rot=(0.2, -0.2, 1.1)` → `bbox_min=-0.1092` mientras `vert_min=0.0450` (delta 15.4 cm).
- **Solución:** medir el `z_min` recorriendo los **vértices reales** de la malla: `min((o.matrix_world @ v.co).z for v in o.data.vertices)`. Solo caer al AABB si `len(o.data.vertices) == 0` (objetos vacíos / con shape keys).
- **Helper ya integrado:** la función `zmin_real(o)` de `generar_variante.py` (FASE 3) usa vértices reales; cualquier nuevo script que necesite re-asentar debe reusarla o replicarla. Misma forma en `auditar_flotantes.py:zmin_real()`.
- **Auditoría E-24 (2026-08-31 04:12):** barrido de todos los call-sites de `bound_box` en `scripts-reutilizables/`. **5 archivos corregidos** (todos los que tomaban decisiones de apoyo/Asentado o reportaban `z_min` como dato):
  - `verificar_visual.py:medir_apoyo()` — reporta `HUNDIDO` falsamente en rotados
  - `asentar_en_base.py:PLANTILLA` — sobre-eleva el grupo 15 cm si la fuente tiene un rotado
  - `auditar_apoyos.py:TEMPLATE` — reporta `FLOTA` falsamente en rotados
  - `corregir_asset.py:zmin_de()` — el delta de re-asentado arrastraba el grupo entero hacia arriba
  - `auditar_presupuesto.py:52-53` (cosmético, solo display) y `verificar_bounds.py:21-22` (engañoso, se lee como `z_min` real)
  - **SAFE** (no se tocan): `capturar_angulos.py:117` y `diagnosticar_pose.py:51` (framing de cámara, AABB es correcto); `inspeccionar_escena.py` (display); `auditar_flotantes.py:93` y `generar_variante.py:380` (fallback empty-mesh, ya con docstring E-24).
- **Regla práctica al escribir un script nuevo que mide apoyo:** NUNCA `o.bound_box` para decidir re-asentado. Usar siempre `zmin_real(o)`. El AABB es válido solo para "footprint visual" y "centro de encuadre de cámara".
- **Caso real:** `palanca_madera` Brazo inclinado 35° → AABB z_min = -0.396 → con la corrección por vértices reales z_min = +0.045 exacto. Caso 2 (2026-08-31): `roca_comun` `SM_Roca_Comun_Chica` rot=(0.2,-0.2,1.1) → AABB z_min = -0.1092 → con la corrección z_min = 0.0450 exacto.
- **Fecha:** 2026-08-29 (original), 2026-08-31 04:12 (auditoría completa de 5 archivos)

### E-25 — `bpy.ops.object.modifier_apply` falla por contexto desde el socket MCP
- **Síntoma:** `bpy.ops.object.modifier_apply.poll() failed, context is incorrect` al aplicar modificadores (`DECIMATE`, `SUBSURF`, `MIRROR`) en scripts enviados por el socket del addon.
- **Causa:** el `poll()` chequea `bpy.context.active_object` y el override_area/viewport, y desde el socket el contexto es headless y no tiene las áreas de la UI inicializadas.
- **Solución:** aplicar el modificador evaluando el depsgraph y reasignando la malla resultante:
  ```python
  mod = o.modifiers.new('Decimate', 'DECIMATE')
  mod.ratio = 0.7
  bpy.context.view_layer.update()
  dg = bpy.context.evaluated_depsgraph_get()
  me_eval = bpy.data.meshes.new_from_object(o.evaluated_get(dg))
  mats = [m for m in o.data.materials if m is not None]
  o.data = me_eval
  for m in mats: o.data.materials.append(m)
  o.modifiers.clear()
  ```
  Mismo resultado, sin tocar `bpy.ops`. Ya integrado en `generar_variante.py` (FASE 2) y `corregir_asset.py`.
- **Fecha:** 2026-08-29

### E-26 — `capturar_angulos.py` no abría el `.blend`; renderizaba la escena residual
- **Síntoma:** las capturas de un asset mostraban piezas que NO correspondían al .blend (mezcla de assets viejos, o el set de captura anterior). El "OBJETOS_ENCUADRADOS" salía bien, pero el frame tenía más cosas.
- **Causa:** el script asumía que el .blend activo en memoria era el del asset, sin garantía. Si Blender tenía otra escena cargada (de una sesión previa con el archivo aún abierto), la captura salía sobre eso.
- **Solución doble:**
  1. Pasar siempre `--blend <ruta>` al script de captura; internamente abrir con `bpy.ops.wm.open_mainfile(filepath=...)` antes de encuadrar.
  2. Imprimir trazas obligatorias: `ARCHIVO_ABIERTO: <ruta>` y `OBJETOS_ENCUADRADOS: <N>` al inicio. Si no aparecen, el script no abrió el archivo correcto.
- **Fecha:** 2026-08-29

### E-27 — Sobreescribir `child.matrix_parent_inverse` tras `child.parent = parent` rompe la herencia
- **Síntoma:** al parentar un objeto hijo, su posición `local.location` se aplica como posición **world directa** en vez de como offset dentro del frame del padre. El hijo aparece en el origen world (o muy lejos) en vez de donde se lo espera.
- **Causa:** Blender, al asignar `child.parent = parent`, calcula `child.matrix_parent_inverse = parent.matrix_world.inverted()`. Si después sobreescribís esa variable manualmente, anulás la herencia: `child.matrix_world = parent.matrix_world @ child.matrix_parent_inverse @ child.matrix_local` se reduce a `child.matrix_world = child.matrix_local`, así que cualquier `child.location` posterior se interpreta en world space, no en el frame del padre.
- **Caso GRAVE (M13, 2026-08-29):** si ADEMÁS movés el padre después de emparentar (paso 7 de los scripts de tools, `mango.location.z += delta` para asentar), los hijos NO lo siguen y quedan flotando a la altura anterior. En los .blend del módulo 13 se midió: mango en x=-0.097, cabeza/ataduras/pomo en x=0 → **9-10 cm de separación**, z_min global del source en -0.4629 (46 cm hundido).
- **Solución:** después de `child.parent = parent`, NO tocar `matrix_parent_inverse`. Para mover el hijo dentro del frame del padre, setear `child.location = (lx, ly, lz)` en coords locales y dejar que Blender mantenga `matrix_parent_inverse` por su cuenta. Y si vas a mover al padre para asentar, dejá que los hijos lo sigan: con la herencia intacta, mover el mango arrastra a todos sus hijos.
- **Patrón seguro `hijo()`:**
  ```python
  def hijo(objeto, padre):
      bpy.context.view_layer.update()
      objeto.parent = padre        # Blender calcula matrix_parent_inverse solo
      return objeto
  ```
- **Patrón padre legible:** si además querés que el offset del hijo en el script sea en coords de mundo (no en el frame rotado del padre), mantené al padre con `matrix_world` identidad. Cero rotación + cero traslación inicial = `local == world`. Aplica a los scripts que modelan un mango tendido/vertical sin que el frame del mango influya en los hijos.
- **Caso real (M166-cuerda):** `cuerda_enrollada` v1: `punta.parent = cabo; punta.matrix_parent_inverse = cabo.matrix_world.inverted(); punta.location = (0, 0, 0.193)` → el cono apareció en el origen. La versión correcta: `punta.parent = cabo; punta.location = (0, 0, 0.34/2 + 0.045/2)` (sin la línea del matrix_parent_inverse).
- **Caso real (M13, 2026-08-29):** los 3 scripts `crear_{pico_piedra,pico_hierro,antorcha_mano}_lowpoly.py` usaban `hijo()` con el `matrix_parent_inverse = padre.matrix_world.inverted()` y además movían el mango al asentar. Resultado medido: separación 9.3-9.7 cm entre mango y resto, z_min del source -0.4629. v2 reescrito: `hijo()` sin tocar `matrix_parent_inverse`, mango con rotación identidad, y `assert abs(z_final - Z_APOYO) < 1e-4` al final para fallar fuerte si vuelve a fallar.
- **Diagnóstico rápido:** si un objeto parentado aparece desplazado del padre y no respeta rotaciones/escalas del padre, es E-27. Borrá la línea `child.matrix_parent_inverse = ...` y volvé a setear `location` en local. Si el z_min global del source es muy negativo (-0.4 o peor) y los hijos están sobre z=0, es la misma clase: el padre se movió al asentar y los hijos no lo siguieron.
- **Fecha:** 2026-08-29 (caso M13 agregado el 2026-08-29 19:36)

### E-28 — El set de captura de un asset "de pared" debe estar ASENTADO en la arena
- **Síntoma:** en un asset tipo antorcha de pared / cartel colgante / dintel, el operador ve "una placa cuadrada detrás separada flotando en el aire" — pero el asset (sin pared) está bien. La placa está volando 30–50 cm del suelo y a 0.4 m de distancia del panel.
- **Causa:** los sets de captura referencian superficies (`Set_Pared`, `Set_Techo`, `Set_Suelo_Colgante`) que el script original dejó centradas en su altura nominal, no apoyadas en `z=0`. El panel de referencia queda flotando, y el asset (que sí está apoyado) parece estar "junto a una pared fantasma".
- **Solución:** cualquier panel de referencia en el set de captura debe **asentarse en la arena con la misma regla que un asset regular**:
  - `Z_CENTER_PARED = -0.05 + ALTO/2` (base enterrada ~5 cm en la arena, mismo offset que `asentar_en_base.py`).
  - `Z_BASE_PARED = Z_CENTER - ALTO/2 ≤ 0.045` (verificable con `auditar_apoyos.py`).
  - Para piezas montadas contra el panel, calcular la posición tangente a la cara frontal:
    - `Y_CENTER_PARED = offset_negativo` (la cara frontal queda más cerca del origen)
    - `Y_CENTER_PLACA = (Y_CENTER_PARED + ESP_PARED/2) + ESP_PLACA/2` (cara trasera de la placa = cara frontal del muro)
    - Luego `X_BRAZO / Z_BRAZO` se calculan en función de `PLACA_FRONT_Y = Y_CENTER_PLACA + ESP_PLACA/2`.
- **Caso real:** `antorcha_pared` v1: `Set_Pared` centrada en z=1.10, ALTO 1.40 → base a z=0.40 flotando; placa a y=-0.020 cuando la cara frontal del muro estaba en y=-0.425 → 0.42 unidades de aire. v2 corrigió con `PARED_Z_CENTER = -0.05 + 1.40/2 = 0.65` y `PLACA_Y_CENTER = (-0.45 + 0.025) + 0.010 = -0.415`.
- **Directiva:** cualquier `Set_*` debe pasar `auditar_apoyos.py` con `z_min ≤ 0.05` ANTES de considerarlo válido para captura. Si el set flota, el asset no se puede aprobar visualmente.
- **Fecha:** 2026-08-29

### E-29 — `--ratio` como escape-valve per-asset para E-23
- **Síntoma:** un asset con mucha geometría densa (frondas de helechos, ramas de nido, racimos) queda por encima del presupuesto BAJA de 700 tris aún con `DECIMATE_RATIO = 0.7` global.
- **Causa:** E-23 calibró el ratio 0.7 como el sweet-spot para mallas planas lowpoly (cajas, paneles, aros). Pero para activos con muchas caras pequeñas contiguas (hojas, ramas, palitos), 0.7 sólo elimina un 30 % y el conteo queda alto.
- **Solución:** `generar_variante.py` ahora acepta `--ratio <float>` por invocación, sobreescribiendo el default SOLO para ese asset. El global sigue siendo 0.7.
  - Uso: `python generar_variante.py 16-Crafting hacha_piedra_lowpoly --ratio 0.4` → la BAJA sale con 0.4 en vez de 0.7. Verificá visualmente que la silueta se preserva.
  - Casos calibrados 2026-08-29: `nido_cocos_baja` 970→611 tris con `--ratio 0.4`; `helecho_gigante_baja` 936→650 tris con `--ratio 0.5`. Ambos verificados visualmente.
- **Regla de uso:** NO subir el global a 0.5 (rompe E-23 en cajas planas). Usar `--ratio` SOLO para activos puntuales con geometría densa y verificar siempre la silueta en la captura BAJA antes de aprobarla.
- **Fecha:** 2026-08-29

### E-30 — `contact_sheet.py` con glob produce hojas de 1 imagen
- **Síntoma:** al ejecutar `python contact_sheet.py capturas/*.png hoja.jpg`, la hoja generada muestra UNA sola captura (repetida 6 veces en grilla) en vez de las 6 distintas. Visualmente parece aprobada pero en realidad solo revisaste 1 ángulo.
- **Causa:** la shell expande el glob y todos los PNGs llegan como `sys.argv[1..N-1]`, pero la función `main()` tomaba solo `sys.argv[1]` como rutas. El output argument (último argv) se leía bien, pero los inputs se perdían. El mensaje "con 1 capturas" en el output era la única señal.
- **Solución:** tomar `pngs = sys.argv[1:-1]` cuando el modo es por rutas (cualquier argv[1] que sea archivo o contenga `*`). Imprimir AVISO si `len(pngs) < 2` para detectar regresiones. Si esto vuelve a fallar y nadie lo nota, E-13 (verificación multi-ángulo) queda invalidada en silencio.
- **Caso real (2026-08-29):** descubierto al regenerar las hojas de `pico_piedra_v2`. La primera corrida dio "con 1 capturas"; al investigar, encontré el bug. Fix aplicado a `scripts-reutilizables/contact_sheet.py`. El path programático (`verificar_visual.py` → `hoja(pngs, salida_jpg)`) SIEMPRE estuvo bien porque pasaba una lista.
- **Diagnóstico rápido:** después de cada `contact_sheet.py ...`, verificar que el output diga "con 6 capturas" (o el N que corresponda). Si dice "con 1", el bug volvió.
- **Fecha:** 2026-08-29

### E-31 — Audit estático de E-27 da falsos negativos; el geométrico también puede confundir "E-27" con "sobresalir por diseño"
- **Síntoma 1 (audit estático):** un AST walker que solo marca "RIESGO ALTO si el padre recibe una escritura `.location` DESPUÉS del parenting" pasa por alto dos casos reales:
  - **Padre rotado ANTES del parenting** (`o_tallo.rotation_euler = ...` antes del bucle que parenta las hojuelas). El `matrix_parent_inverse` sobreescrito descarta esa rotación, y las hojuelas leen su `location` como mundo → todas se apilan en `+X` (caso `helecho_gigante` v1: 47/80 hojuelas separadas hasta 0.8351 m).
  - **Mismo nombre de variable en scopes distintos** (`cuerpo` se mueve en el asentado L415, pero `cuerpo` aparece como `padre` en la línea 404 vía un `agregar()`). El audit no correlaciona ambas referencias (caso `cofre_ancestral` v1: 5 cm de gap).
- **Síntoma 2 (audit geométrico AABB-gap):** la métrica `distancia Mínima AABB-AABB en world` (umbral 0.02 m) funciona bien para **hand-tools y vegetación** (las piezas están DENTRO del bbox del padre), pero confunde E-27 con **"sobresalir por diseño"** en cofres, casas y props similares (tiradores, asas, bisagras, salientes decorativos que sobresalen del cuerpo a propósito).
- **Causa:** los dos audits usan heurísticas incompletas. La estática solo rastrea el camino de las variables; la geométrica mide espacio, no intención de diseño.
- **Solución — la métrica correcta depende del TIPO de asset:**
  1. **Hand-tools / hand-held** (pico, hacha, antorcha de mano, machete, etc.) y **vegetación** (helechos, palmeras, plantas con tallo central):
     - Audit: AABB-gap ≤ 0.02 m funciona. Las piezas solidarias (cabeza, pomo, gemas, anillas, cordeles) están DENTRO del bbox del padre.
     - El `assert abs(z_final - Z_APOYO) < 1e-4` del `hijo()` canónico (E-27) cubre la separación tras el asentado.
  2. **Props con piezas que sobresalen a propósito** (cofres, casas, carros, balsas, antorchas de pared, paneles):
     - El AABB-gap va a dar falsos positivos: el tirador de un cofre SOBRESALE 5 cm por diseño (es la manija), las asas 1.8 cm, las bisagras traseras 1.2 cm. La métrica correcta sería "el centroide del hijo cae sobre la SUPERFICIE del padre", no "el bbox-gap es chico".
     - **No** poner un `assert` AABB-gap en el script: rompe builds válidos por diseño.
     - El control de calidad pasa a la **verificación visual E-13** (6 capturas orbitales) — si el asentar hubiera roto el parenteo, el render lo mostraría.
- **Regla de uso del audit AABB-gap:**
  - Úsalo en `scripts-reutilizables/` como **herramienta de triaje** sobre hand-tools y vegetación, no como filtro automático.
  - Para props con piezas sobresalientes, **anotá en el script** qué piezas tienen separación intencional y por qué, así el próximo que lo lea no "arregla" un bug que es feature.
- **Caso real (2026-08-29, audit de 7 assets):**
  - Estática: 6 RIESGO NULO, 1 RIESGO ALTO (`estrella_mar` — falso positivo por suposición de variable, ver diagnóstico abajo).
  - Geométrica: `helecho_gigante` 47/80 separados (0.84 m, **bug real**), `cofre_ancestral` 1 separado (`SM_Cofre_Tirador` 5 cm, **diseño**), resto 0.
  - Fijados: `helecho_gigante` (borrar línea de `matrix_parent_inverse`), `cofre_ancestral` (mismo fix + nota explícita en el script de que el tirador sobresale por diseño).
- **Conclusión:** ningún audit es 100 % confiable. El **render E-13 con 6 ángulos** sigue siendo la fuente de verdad final.
- **Fecha:** 2026-08-29 19:50

### E-32 — No deducir el winding a mano: `recalc_face_normals` + 1 medición global
- **Síntoma:** al armar una isla cerrada con bmesh (capa exterior + capa interior + borde perimetral, o un tubo, o una cuña), el orden de los vértices de cada cara determina la dirección de la normal. Deducirlo a mano con productos vectoriales "en el papel" es frágil: la primera versión de `crear_vieira_playa_lowpoly.py` puso la cara exterior mirando a `+X` y la interior a `-X` (lo opuesto a lo que el material asumía), y la orientación equivocada no se notó hasta el render E-13 (se veía la cáscara cremosa en vez del nácar).
- **Causa:** el winding "correcto" depende de la convención local del script (orden de los parámetros, signo de la curvatura, etc.). Cualquier cambio sutil en el orden de los índices rompe la suposición.
- **v1 (vieira, log 287) — dos patrones según la forma de la isla:**
  1. **Isla cerrada y conexa** (cáscara, caja, domo, tubo con tapas): crear todas las caras en cualquier orden, llamar a `bmesh.ops.recalc_face_normals(bm, faces=...)` para que unifique las normales según la topología, y después hacer UNA sola medición que decida la orientación global. Ejemplo de la vieira:
     ```python
     bmesh.ops.recalc_face_normals(bm, faces=caras_valva)
     suma_ext = sum(f.normal.x for f in caras_ext)
     if suma_ext > 0.0:
         bmesh.ops.reverse_faces(bm, faces=caras_valva)
     assert suma_ext < 0.0, 'E-32: la capa exterior no mira a -X'
     ```
  2. **Isla cerrada y convexa** (cuña, prisma triangular, cono, pirámide): recalc unifica y después test de centroide por cara: si `f.normal.dot(f.calc_center_median() - centroide) < 0.0`, la cara está mirando hacia adentro → `f.normal_flip()`. Usado para las aurículas y la bisagra de la vieira.
- **v2 (puente, Log 285) — un único test para TODAS las islas cerradas (conexas o no, convexas o no):** el test de centroide de v1 solo sirve para islas **convexas**. Un tubo que sigue una catenaria (como las 4 cuerdas del puente) NO es convexo, y el test de centroide le erraría. El test exacto y universal es el **volumen con signo** (teorema de la divergencia):
  ```python
  def volumen_firmado(caras):
      v = 0.0
      for f in caras:
          co = [vert.co for vert in f.verts]
          for k in range(1, len(co) - 1):
              v += co[0].dot(co[k].cross(co[k + 1]))
      return v / 6.0
  ```
  `V > 0` -> las normales miran hacia afuera. `V < 0` -> la isla está dada vuelta. No depende de la forma, solo de que la isla sea **watertight**.
  **Patrón final (reemplaza a los dos de v1):**
  ```python
  bmesh.ops.recalc_face_normals(bm, faces=isla)
  if volumen_firmado(isla) < 0.0:
      bmesh.ops.reverse_faces(bm, faces=isla)
  ```
  Aplicar **una vez por isla** (cada primitiva del script es su propia isla). Caso real: 4 cuerdas catenarias + 1 caja = 5 islas, todas orientadas con el mismo helper.
- **Regla:** si podés medirlo, no lo deduzcas. La medición es robusta; la deducción es frágil.
- **Casos reales (2026-08-29):**
  - `crear_vieira_playa_lowpoly.py` v1: 3 familias de caras con winding derivado a mano, 2 invertidas. v2 con patrón (1) + assert anti-regresión. 10 min para encontrar el patrón correcto.
  - `crear_puente_cuerda_lowpoly.py` (log 285): el patrón (2) de v1 (centroide) no le servía para los tubos catenarios. Reemplazo por volumen firmado: funcionó a la primera.
- **Bonus lesson — `R_MIN > 0` en rejillas polares:** el mismo script de la vieira usaba `r = t * R_MAX` para los radios de la rejilla, de modo que en `i = 0` los `N_ANG + 1` vértices del arco de la bisagra colapsaban en un mismo punto y se generaban caras degeneradas (área cero, no reportadas por bmesh). La v2 hace `r = R_MIN + t * (R_MAX - R_MIN)` con `R_MIN = 0.035`, dándole a la bisagra una línea real de 6.8 cm. **Regla:** una rejilla polar que arranca en `r = 0` es un anti-patrón; siempre usar `R_MIN > 0` aunque sea chico.
- **Fecha:** 2026-08-29 20:51 (v1) / 2026-08-29 21:12 (v2)

### E-33 — `generar_variante.py` reporta CARAS, no triángulos. El presupuesto M166 está en triángulos reales.
- **Síntoma:** la salida de `python generar_variante.py ... --baja` dice `objetos=1  tris=482  materiales=3` para la vieira. La tabla M166 §3.3 dice BAJA ≤ 700 **tris**. El primer impulso es "OK, 482 < 700". Pero al medir con `mesh.calc_loop_triangles()` (la fuente de verdad para el conteo de triángulos en Blender), la misma BAJA de la vieira tiene **676 tris reales**. La diferencia es ~2× porque `generar_variante.py` cuenta `len(mesh.polygons)` y la mayoría de las caras son quads (1 polígono = 2 triángulos).
- **Causa:** la columna "tris" del output de `generar_variante.py` y de la checklist estaba usando `len(m.polygons)`, no `len(m.loop_triangles)`. Esto es un **bug histórico**: los 43 assets aprobados hasta ahora figuran en el checklist con números que son MITAD del tri-count real.
- **Impacto medido (2026-08-29, muestra de 4 assets ya aprobados):**
  - `cofre_ancestral` MEDIA: 784 reportados → **1482 tris reales** (límite 1500, pasa por 18 tris).
  - `cofre_ancestral` BAJA: 571 → **962 tris reales** (límite 700, **excede por 37 %**).
  - `helecho_gigante` MEDIA: 1190 → **2288 tris reales** (límite 1500, **excede por 53 %**).
  - `helecho_gigante` BAJA: 672 → **1144 tris reales** (límite 700, **excede por 63 %**).
  - `concha_mar` MEDIA: 319 → 649 tris reales (límite 1500, OK).
  - `concha_mar` BAJA: 378 → 423 tris reales (límite 700, OK).
  - `vieira_playa` MEDIA: 482 → 968 tris reales (límite 1500, OK).
  - `vieira_playa` BAJA: 482 → 676 tris reales (límite 700, OK, margen de 24).
- **Cuestiones derivadas que esto abre:**
  1. El budget M166 debe ser re-validado para los 43 assets existentes. El script `auditar_optimizacion.py` (mencionado en el checklist §4) ya cuenta tris reales — correrlo sobre todos los assets y los que excedan pasan por un `--ratio` más agresivo (E-29).
  2. La columna del checklist y el output de `generar_variante.py` deben mostrar triángulos reales. Fix sugerido: en `generar_variante.py`, cambiar la línea de impresión por `tris=len(m.loop_triangles)` (requiere `m.calc_loop_triangles()` antes).
  3. La nueva medición NO invalida los assets visualmente aprobados (el render E-13 sigue siendo válido); lo que invalida es la **afirmación numérica de cumplimiento de presupuesto** para varios de ellos.
- **Acción inmediata:** antes de empezar el pipeline Blender→Godot, correr `auditar_optimizacion.py` y aplicar `--ratio <F>` (E-29) a los assets que excedan. La escala es manejable: los BAJA problemáticos están ~2× arriba del límite, así que con `--ratio 0.4` en `cofre` y `helecho` (que ya está calibrado a 0.5) alcanzan.
- **Regla nueva:** cualquier check numérico de presupuesto en Blender usa `mesh.calc_loop_triangles()` y `len(mesh.loop_triangles)`. No `len(mesh.polygons)`.
- **Diagnóstico rápido:**
  ```python
  import bpy
  for o in bpy.context.scene.objects:
      if not o.name.startswith('SM_'): continue
      o.data.calc_loop_triangles()
      print(o.name, 'polygons=%d tris=%d' % (len(o.data.polygons), len(o.data.loop_triangles)))
  ```
- **Herramienta persistente:** `scripts-reutilizables/auditar_presupuesto.py` (log 285) recorre los 111 `_baja`/`_media`/`_alta_media` blends, abre cada uno, mide triángulos reales, slots y materiales usados, y reporta quién excede el presupuesto. Resultado del 2026-08-29 21:35 (post E-36): **23 de 111 exceden** — 16 con `tris+` (11 son los `_alta_media` héroes, 5 son `_lowpoly` aprobados que en realidad exceden), 5 con `mats+` solo (nido_cocos_baja, tablon_madera_baja, farola_fuego_baja, anillo_piedras_ritual_baja, arbusto_floral_baja), y 2 con ambos (cofre_ancestral_baja, hongo_luminoso_baja). Ver §E-36 adyacente para el bug original del audit que ocultaba los `mats+`.
- **Acción derivada (ya hecha en Log 285):** se arregló `generar_variante.py` para que imprima `len(m.loop_triangles)`, no `len(m.polygons)`. Diff de 1 línea. A partir de log 285 los outputs del script reflejan triángulos reales.
- **Fecha:** 2026-08-29 20:51 (v1) / 2026-08-29 21:12 (v2 + herramienta persistente)

### E-34 — `generar_variante.py` duplicaba los slots de material al aplicar decimate
- **Síntoma:** después de correr `generar_variante.py ... --baja`, el `_baja.blend` del asset tenía el DOBLE de slots de material en `material_slots` que materiales realmente usados por las caras. Caso real (log 285): `puente_cuerda_baja` reportaba `materiales=6` cuando solo usaba 3. La BAJA del mismo asset sin el fix: `1 slots, 1 mats usados` o `3 slots, 3 mats usados` (después del fix), pero ANTES: `6 slots, 3 mats usados` para el puente, `2 slots, 1 mats usados` para muchos otros.
- **Causa:** en la fase de decimate (líneas 200-211 de `generar_variante.py` v1), el código hacía:
  ```python
  me_eval = bpy.data.meshes.new_from_object(o.evaluated_get(dg))
  mats = [m for m in o.data.materials if m is not None]
  o.data = me_eval
  for m in mats:
      o.data.materials.append(m)
  ```
  `new_from_object()` **ya copia** los slots del objeto evaluado. Después, el bucle los vuelve a appendar → duplicados (3 → 6, 2 → 4, etc.). Las caras siguen apuntando a los slots 0..N-1, así que visualmente no hay draw calls de más, pero el CONTEO de materiales en el checklist se infla y algunos assets BAJA superaban el límite de 4 slots sin haberlo hecho realmente.
- **Impacto medido (2026-08-29 21:12, mass-fix `saneo_bajas_e34.py`):** **45 de 46** `_baja.blend` tenían slots duplicados. Después del saneo, todas tienen el número correcto (en general 1; el puente tiene 3 legítimos).
- **Solución — dos pasos:**
  1. **Origen:** deduplicar los slots comparando con `mats` y solo si difieren reconstruir la lista. **NO usar `Mesh.materials.clear()` (ver E-35).** Diff:
     ```python
     me_eval = bpy.data.meshes.new_from_object(o.evaluated_get(dg))
     mats = [m for m in o.data.materials if m is not None]
     o.data = me_eval
     if [s.material for s in o.material_slots] != mats:
         idx_caras = [p.material_index for p in o.data.polygons]
         o.data.materials.clear()
         for m in mats:
             o.data.materials.append(m)
         for p, mi in zip(o.data.polygons, idx_caras):
             p.material_index = mi
     ```
  2. **Batch fix:** `scripts-reutilizables/saneo_bajas_e34.py` abre cada `_baja.blend` y dedupa los slots con `o.data.materials.pop(index=i)` (no `clear()`). Re-ejecutable, idempotente: la segunda corrida no cambia nada.
- **Regla nueva:** después de cualquier `generar_variante.py --baja`, correr `saneo_bajas_e34.py` (o el audit `auditar_presupuesto.py`) para confirmar que `slots == mats_usados`. Si difieren, hay duplicados.
- **Caso real (2026-08-29):** descubierto al inspeccionar la BAJA del puente tras aplicar E-32 v2. El script de saneo también confirma que el bug afectaba a los 45 `_baja.blend` preexistentes — un bug silencioso de **3 meses** en los assets del proyecto.
- **Herramientas persistentes:**
  - `scripts-reutilizables/saneo_bajas_e34.py` (fix batch)
  - `scripts-reutilizables/auditar_presupuesto.py` (verificación: cuenta slots vs mats usados y avisa si difieren)
- **Fecha:** 2026-08-29 21:12

### E-35 — `Mesh.materials.clear()` resetea a 0 el `material_index` de TODAS las caras
- **Síntoma:** tras ejecutar la versión "fix" de E-34 que llamaba `o.data.materials.clear()`, la BAJA del asset se renderizaba con **un solo material** aunque los slots siguieran siendo N. El histograma de `material_index` colapsaba a `{0: N_caras}`. Caso real (2026-08-29 21:30, log 286): `puente_cuerda_baja` y `pozo_piedra_baja` regeneradas con la primera versión del fix salieron con `slots=3, mats_usados=1` y `slots=4, mats_usados=1` respectivamente, cuando deberían haber sido `3/3` y `4/4`.
- **Causa:** `IDMaterials.clear()` (interfaz de bajo nivel de la lista de materiales del Mesh) borra todos los slots y, en Blender 4.2, pone `material_index = 0` en cada `MPoly` como parte de la limpieza. El bug **no es de mi script**: la API de Blender documenta que clear() remueve las referencias de la lista pero NO garantiza que las `material_index` de las caras queden dentro de rango — quedan en 0.
- **Verificación experimental (log 286, `diag_merge_decimate.py`):**
  ```
  SRC        faces=361  hist={0:216, 1:102, 2:7, 3:36}   slots=4
  BMESH      faces=361  hist={0:216, 1:102, 2:7, 3:36}
  to_mesh    faces=361  hist={0:216, 1:102, 2:7, 3:36}   attrs=[material_index, sharp_face]
  OBJ MERGED faces=361  hist={0:216, 1:102, 2:7, 3:36}   slots=4
  EVALUATED  faces=299  hist={0:216, 1:57, 2:2, 3:24}    <-- decimate CONSERVA los indices
  tras o.data=  faces=299  hist={0:216, 1:57, 2:2, 3:24}  slots=4
  tras clear()  faces=299  hist={0:299}                  slots=0   <-- ACÁ se pierden
  ```
  El `Decimate` modifier respeta el `material_index` correctamente. El reset es exclusivo de `materials.clear()`.
- **Solución definitiva:** la del propio E-34 v2 — respaldar `material_index` de cada cara antes del `clear()`, restaurar después con `p.material_index = mi`. Y ANTES de tocar nada, **solo reconstruir si la lista de slots realmente difiere** (chequeo de identidad en `o.material_slots`); si no difiere, no se hace nada y se eliminan ambos bugs.
- **Impacto medido:** los 45 BAJA saneados con `saneo_bajas_e34.py` (que usa `pop()` en vez de `clear()`) están correctos. Solo `puente_cuerda_baja` y `pozo_piedra_baja` se rompieron porque fueron regeneradas con la versión "fix" defectuosa. Regeneradas con el fix v2: hist {0:24, 1:78, 2:206} y {0:216, 1:57, 2:2, 3:24} respectivamente.
- **Regla nueva:** **NUNCA** `Mesh.materials.clear()` como paso de "limpieza" sobre una malla con caras. Si hay que deduplicar slots, usar `pop(index=i)` o respaldar+restaurar los indices.
- **Fecha:** 2026-08-29 21:30
