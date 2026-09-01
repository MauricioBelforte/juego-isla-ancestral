# 09 — Guía Blender

**Modelo:** Claude
**Plataforma:** Cline
**Fecha:** 2026-08-28

> **Propósito:** Guía de referencia obligatoria para modelar assets con Blender vía scripting (bpy), análoga a `07-GUIA-GODOT.md`. Documenta errores comunes, convenciones, la conexión MCP (V5) y el registro de errores. **Todo agente que modele assets DEBE leerla antes de empezar** y agregar aquí cada descubrimiento nuevo (regla AGENTS.md §26 aplicada a Blender).

---

## 1. Conexión con Blender (V5)

La vía V5 usa Blender en modo servidor + un cliente Python de la venv del proyecto. **No requiere addon de terceros**: Blender corre headless con un socket que ejecuta código `bpy` enviado por el cliente.

| Pieza | Ruta (`tools/mcp/blender-mcp/scripts-reutilizables/`) | Función |
|---|---|---|
| Servidor | `arrancar_servidor_mcp.py` | Arranca Blender 4.2 headless, socket `127.0.0.1:9876` |
| Cliente | `bpy_cliente.py` | `blender_command('execute_code', {'code': ...})` |
| Captura | `cap_blender.py` | Screenshot offscreen del viewport → PNG en `capturas/` |
| **QA numérico** | `verificar_bounds.py` | `python verificar_bounds.py SM_Coco_` → nº objetos, `z_min`/`z_max`/alto, rango X/Y de centros, duplicados. Sustituye a la revisión visual cuando el modelo no acepta imágenes (E-10). Ver también E-09. |
| **Asentar en base** | `asentar_en_base.py` | `python asentar_en_base.py SM_Tronco_Caido 0.045` → baja el grupo hasta `z_min = 0.045`. Para correcciones one-off fuera del script. |
| **Auditar todos** | `auditar_apoyos.py` | `python auditar_apoyos.py 15-Recursos` → ejecuta todos los `crear_*_lowpoly.py` del módulo y reporta cuáles tocan el suelo (FLOTA si `z_min > 0.05` y `< 0.50`). Ver E-12. |
| **Captura multi-ángulo** | `capturar_angulos.py` | `python capturar_angulos.py SM_Coco_ base.png 6` → genera 6 capturas equi-espaciadas alrededor del asset. **Obligatorio** para aprobar (E-13, §6.2bis). |
| Ejemplo | `crear_palmera_lowpoly.py` | Asset reutilizable completo |

### Flujo estándar (PowerShell)

```powershell
# 1) Arrancar servidor (el socket 9876 NO se mantiene en background; ver E-07).
#    Blender debe estar con GUI; el addon abre el socket al iniciar.
& 'D:\Archivos de programa\Blender Foundation\Blender 4.2\blender.exe' --python tools/mcp/blender-mcp/scripts-reutilizables/arrancar_servidor_mcp.py
#    (Alternativa: abrir Blender normalmente, N -> BlenderMCP -> "Connect to MCP server".)

# 2) Ejecutar un script dentro de Blender
& 'tools/mcp/.venv/Scripts/python.exe' -c "import sys, json; sys.path.insert(0, r'tools/mcp/blender-mcp/scripts-reutilizables'); from bpy_cliente import blender_command; code = open(r'<SCRIPT>.py', encoding='utf-8').read(); print(json.dumps(blender_command('execute_code', {'code': code})))"

# 3) Capturar resultado (SIEMPRE, timestamp nuevo — nunca sobrescribir)
& 'tools/mcp/.venv/Scripts/python.exe' 'tools/mcp/blender-mcp/scripts-reutilizables/cap_blender.py' "tools/mcp/blender-mcp/capturas/{ID-Modulo}-Nombre/cap_{ID}_{AAAA-MM-DD_HH-MM-SS}_nota.png"
```

### Reglas
- Verificar puerto 9876 antes de enviar código.
- Capturas en `capturas/{ID-Modulo}-Nombre/` con timestamp; conservar la anterior como comparativa (AGENTS.md §24).

## 2. Convenciones de código bpy

- **Nombres tipo Godot:** prefijos `SM_` (static mesh), `M_` (mesh data), `MAT_` (materiales). Facilita exportar sin renombrar.
- **Una malla por pieza estructural:** preferir `bmesh` (una malla) antes que apilar primitivas de `bpy.ops` (ver E-01).
- **Materiales lowpoly:** nombres claros y roughness alto.
- **Escena de prueba:** incluir `CAM_<Asset>` encuadrada + sol rasante para validar sombras en cada captura.
- **Idempotencia:** el script debe limpiar la escena para poder re-ejecutarse sin duplicar.
- **Guardado:** terminar con `bpy.ops.wm.save_as_mainfile(filepath=...)` a la carpeta del módulo (ruta absoluta — ver §6.3 y E-04).

## 3. Registro de Errores

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

### E-36 — `auditar_presupuesto.py` solo inspeccionaba `objs[0]` para materiales
- **Síntoma:** la primera versión del audit (de log 285) reportaba `slots=1, mats_usados=1` para `tablon_madera_lowpoly_baja`, que en realidad tiene **6 slots y 6 materiales usados**. El mismo bug afectaba a `cofre_ancestral_baja` (6), `nido_cocos_baja` (5), `farola_fuego_baja` (5), `anillo_piedras_ritual_baja` (5), `arbusto_floral_baja` (5) y `hongo_luminoso_baja` (5). El conteo de triángulos sí estaba bien (iteraba todos los objs), pero el de materiales solo miraba el primero.
- **Causa:** el script agregaba `tris` y `caras` en un loop sobre todos los `objs`, pero usaba `objs[0].material_slots` y `objs[0].data.polygons` para materiales. Para assets con un solo objeto esto no importa, pero los assets multi-objeto (varios `SM_*` con sus propias slots) quedaban sub-reportados.
- **Verificación experimental:** el script `diag_alcance_e35.py` SÍ recorría todos los objs y reportó los 7 BAJA problemáticos. La discrepancia entre diag (correcto) y audit (defectuoso) me llevo a encontrar el bug.
- **Solución:** mover el loop de slots y de caras dentro del for `o in objs`, igual que ya estaba para `tris` y `caras`:
  ```python
  total_slots = 0
  mats_usados = set()
  for o in objs:
      m = o.data
      m.calc_loop_triangles()
      caras += len(m.polygons)
      tris  += len(m.loop_triangles)
      total_slots += len(o.material_slots)
      for cara in m.polygons:
          if cara.material_index < len(o.material_slots):
              sm = o.material_slots[cara.material_index].material
              if sm:
                  mats_usados.add(sm.name)
  ```
- **Impacto medido (2026-08-29 21:35, post-fix):** el audit pasa de decir "**18 exceden (todos `tris+`)**" a decir "**23 exceden**": 16 con `tris+` (11 héroes `_alta_media` + 5 `_lowpoly` con triángulos de más), 5 con `mats+` solo (nido_cocos, tablon_madera, farola_fuego, anillo_piedras_ritual, arbusto_floral), y 2 con ambos (cofre_ancestral_baja, hongo_luminoso_baja).
- **Regla nueva:** cuando se itera un grupo de objetos, los slots y materiales se cuentan DENTRO del mismo loop, no en una segunda pasada sobre `objs[0]`.
- **Fecha:** 2026-08-29 21:35

### E-37 — Un "fix" cosmético no es un fix; un bug de diseño sigue siendo bug aunque el render se vea distinto
- **Síntoma:** la palanca de madera `palanca_madera_lowpoly` salía del E-13 aprobada ("palo clavado en una caja con una pelota en la punta"), luego un "fix" del log 233 la rotó a mano de 35° a 81.1° y reposicionó el pomo. El usuario la miró de nuevo y dijo "no le encuentro la forma, eso esta corregido?". El "fix" no había arreglado nada — solo había maquillado un problema de fondo que **seguía ahí**: el brazo cilíndrico se creaba en `(0,0,0.21)`, **el mismo punto que el cono del pivote**. El brazo atravesaba el pivote en cualquier ángulo.
- **Causa:** confundir "cambio que produce otro render" con "arreglo que resuelve el problema". El log 233 midió `z_min` con E-24 (vértices reales), corrigió la flotación numérica con `zmin_real()`, y dio por bueno. Pero la pregunta correcta era: **¿se lee como palanca?** Y la respuesta era no, porque la geometría misma estaba mal armada (brazo+pivote=colisionan en el mismo punto del eje).
- **Reglas derivadas:**
  1. Antes de aprobar un asset, **preguntarse "¿se lee como X?"** en lugar de "¿z_min ≈ 0.045?". El E-13 (multi-ángulo) detecta la flotación numérica pero no detecta ambigüedad semántica.
  2. Si un fix cambia la apariencia pero la queja del usuario es de fondo ("no le encuentro la forma"), el fix está **maquillando**, no arreglando. **Rediseñar.**
  3. Cuando el brazo y el pivote son dos operaciones distintas en el mismo lugar, están colisionando por construcción. La solución no es moverlos unos centímetros — es **fusionarlos en un solo bmesh** donde brazo y pivote nacen como caras adyacentes.
- **Caso real:** palanca de madera M70 v1 → v2 (pivote único) → v3 (horquilla). El v3 lo resolvió haciendo una sola operación bmesh con base + 2 montantes + brazo + perno + pomo, todos como caras del mismo mesh. 96 tris, 1 obj, 3 mats, **se lee como palanca**.
- **Lección específica:** **para palancas mecánicas, la HORQUILLA (dos montantes + perno transversal) es incomparablemente más legible que el pivote único**. El pivote único es ambiguo ("¿es un perchero? ¿una hamaca? ¿un mazo?"). La horquilla con perno saliente es inequívocamente una palanca/bomba.
- **Fecha:** 2026-08-29 23:05

### E-38 — En mallas inclinadas, la CAÍDA VERTICAL de una cara NO es su semialto, es `semialto * cos(θ)`
- **Síntoma:** assert geométrico `fondo_brazo = BRAZ_CZ - BRAZ_SEMIALTO == PIV_Z_TOP` falla con diff ~1 mm: `0.41 - 0.07 = 0.34` pero `BRAZ_CZ = PIV_Z_TOP + BRAZ_SEMIALTO = 0.34 + 0.07 = 0.41`, y al estar inclinado, la cara inferior del brazo desciende `SEMIALTO*cos(θ)` desde el centro, no `SEMIALTO`. Diff = 0.07 - 0.07*cos(10°) = 0.07 - 0.0689 = **0.0011 m** = 1.1 mm.
- **Causa:** cuando se inclina una caja, la cara **+ez** (el "lomo") sube `+SEMIALTO*cos(θ) - SEMIALTO*sin(θ)*0` (sin contribución de ex) pero la cara **-ez** (el "vientre") baja `-SEMIALTO*cos(θ)`. La proyección vertical del semieje es siempre `semieje * cos(θ)`.
- **Solución:** definir `CAIDA_VERT = SEMIALTO * cos(ANG_TILT)` y usar esa constante para cualquier cálculo vertical (asentado, asserts, distancia a la base). Mismo principio aplica a la **subida del lomo** (`SUBIDA_VERT = SEMIALTO * cos(θ)`) y a la **ganancia lateral** del brazo inclinado (`semieje * sin(θ)`).
- **Caso real:** palanca v3 — sin este ajuste, el assert del "brazo sobre el pivote" salta y el brazo queda 1 mm flotando sobre el pivote (el peor caso: parece un fix, pero al render se nota el aire).
- **Regla nueva:** **toda caja inclinada se analiza con sus semiejes proyectados**: `semieje_x · cos(θ)` para caída/subida vertical, `semieje_x · sin(θ)` para corrimiento lateral. NUNCA mezclar el semieje real con la altura que ocupa.
- **Fecha:** 2026-08-29 23:05

### E-39 — Para choques esfera-caja, NO comparar un solo eje; medir distancia punto-caja real
- **Síntoma:** assert `POMO_Z - POMO_R > MON_Z_TOP` salta con "POMO: choca con los montantes", pero geométricamente el pomo está a **0.49 m en X** de la horquilla — no choca con nada. Solo se cumple que su `z_min = 0.34` está por debajo del `MON_Z_TOP = 0.40`, pero la condición de overlap 1D NO implica overlap 3D.
- **Causa:** confundir "el pomo ocupa Z más bajo que el montante termina" con "el pomo choca con el montante". La primera es una condición **necesaria** para superlap en Z, pero NO suficiente: si las X no se solapan, no hay superlap real.
- **Solución:** usar la **distancia mínima punto-AABB**:
  ```python
  def dist_punto_caja(p, cx, cy, cz, hx, hy, hz):
      dx = max(abs(p.x - cx) - hx, 0.0)
      dy = max(abs(p.y - cy) - hy, 0.0)
      dz = max(abs(p.z - cz) - hz, 0.0)
      return math.sqrt(dx*dx + dy*dy + dz*dz)
  ```
  Luego assert `dist > R_esfera + margen`. Si la distancia es ≤ 0, el punto está **dentro** de la caja.
- **Caso real:** palanca v3 — el pomo a 0.49 m en X de la horquilla da `dist_punto_caja = 0.499`, vs `POMO_R = 0.115 + 0.02 margen = 0.135`. Margen real = 0.36 m. Sobra.
- **Regla nueva:** **para validar no-colisión entre una esfera y una caja, SIEMPRE distancia punto-AABB + radio**. Nunca comparar componentes individuales en serie.
- **Fecha:** 2026-08-29 23:05

### E-40 — Medir TRIÁNGULOS REALES (`loop_triangles`), nunca CARAS (`polygons`)
- **Síntoma:** `generar_alta.py` aprobaba assets que en realidad duplicaban su presupuesto. `totem_isla_alta` reportaba **10.507 caras → "OK"** cuando en realidad tenía **21.014 triángulos** contra un techo de 6.000. El auditor `auditar_presupuesto.py` decía otra cosa y nadie sabía a quién creerle.
- **Causa:** un `polygon` de N vértices equivale a `N - 2` triángulos (quad = 2, hexágono = 4, octógono = 6). Contar caras subestima entre 1,5× y 2× en una malla lowpoly hecha con primitivas de pocos segmentos. **El presupuesto M166 está definido en triángulos**, así que medir caras es comparar peras con manzanas sin que salte ningún error.
- **Solución:** siempre contar así:
  ```python
  def tris_de(lista):
      t = 0
      for o in lista:
          o.data.calc_loop_triangles()      # hay que llamarlo: la cache no se refresca sola
          t += len(o.data.loop_triangles)
      return t
  ```
- **Caso real (2026-08-29, saneo de presupuesto):** el barrido con el conteo correcto destapó **23 variantes excedidas**, incluidos dos monstruos: `totem_isla_alta` 21.014 tris y `cofre_ancestral_alta` 11.510 tris. La causa de fondo era el BEVEL de `generar_alta.py` corriendo con `--segmentos 3 --subdiv` sobre esferas UV (una sola esfera UV de 32×16 ya son 768 tris; el totem tenía **27 piezas a exactamente 768**). Barrido con `--dry`: seg3+subdiv = 20.534 (reproduce el archivo emitido), seg2+subdiv = 11.854, seg2 = **3.106**, seg1 = 1.306. Se fijó **seg2 para el totem** y **seg1 para el cofre** (3.274 tris).
- **Regla nueva:** **todo número que se compare contra un presupuesto se mide en triángulos reales.** Y si un script emite un veredicto "OK" que contradice al auditor, el bug está en el script, no en el auditor.
- **Fecha:** 2026-08-30 00:15

### E-41 — Al reescribir índices de material, respaldar por NOMBRE, no por número
- **Síntoma:** tras una poda de materiales que decía `PODA MATERIALES: 6 -> 4`, el reporte final seguía mostrando `materiales=6`.
- **Causa:** dos errores encadenados. (a) La poda remapeaba las caras pero **dejaba los slots vacíos**, así que `len(o.data.materials)` seguía contando 6. (b) Al purgar los slots sobrantes, `Mesh.materials.clear()` resetea a 0 el `material_index` de TODAS las caras (E-35), y el respaldo por número queda inutilizable.
- **Solución:** antes de tocar los slots, guardar el nombre del material de cada cara en una lista paralela, y reconstruir el índice a partir de los nombres:
  ```python
  nombres_viejos = [m.name if m else '' for m in o.data.materials]
  idx_nombres = [nombres_viejos[p.material_index] for p in o.data.polygons]
  usados = [n for i, n in enumerate(idx_nombres) if n and n not in idx_nombres[:i]]
  o.data.materials.clear()                       # seguro: ya tenemos el respaldo
  for nm in usados:
      o.data.materials.append(bpy.data.materials[nm])
  nuevo_idx = {nm: k for k, nm in enumerate(usados)}
  for p, nm in zip(o.data.polygons, idx_nombres):
      p.material_index = nuevo_idx.get(nm, 0)
  ```
- **Regla nueva:** **`materials.clear()` es destructivo pero no prohibido** — lo que está prohibido es llamarlo sin haber respaldado antes el material de cada cara **por nombre**. El número de slot es una posición que cambia; el nombre es estable.
- **Fecha:** 2026-08-30 00:15

### E-42 — Reportar materiales USADOS POR CARAS, no slots
- **Síntoma:** un asset con 4 materiales reales aparecía con 6 y superaba el techo de BAJA (4).
- **Causa:** `len(o.data.materials)` cuenta **slots**, y un slot puede quedar huérfano (ninguna cara lo usa) tras una poda, un merge o un decimate.
- **Solución:** el conteo relevante es el de materiales que efectivamente tienen caras:
  ```python
  n_mats = set()
  for o in escena.objects:
      if not es_asset(o):
          continue
      for p in o.data.polygons:
          if p.material_index < len(o.material_slots):
              sm = o.material_slots[p.material_index].material
              if sm:
                  n_mats.add(sm.name)
  n_mats = len(n_mats)
  ```
  Es el mismo criterio que usa `auditar_presupuesto.py`, así que ambos dejan de contradecirse.
- **Regla nueva:** **slots huérfanos no cuentan como materiales.** Si dos herramientas discrepan sobre el número de materiales, es porque una cuenta slots y la otra caras.
- **Fecha:** 2026-08-30 00:15

### E-43 — Colisión de nombres entre variantes: resolver con PRIORIDAD EXPLÍCITA
- **Síntoma:** al exportar el catálogo a Godot aparecían 51 "altas" cuando el catálogo tiene 51 assets, pero el inspector de Godot mostraba un asset con 1 objeto y 96 tris donde debería haber 5 objetos.
- **Causa:** un mismo asset puede tener **dos archivos que mapean al mismo destino**: `palanca_madera_alta.blend` y `palanca_madera_lowpoly.blend` (el `_lowpoly` es el nombre de autoría anterior al convenio `_alta`). Si el planificador itera el directorio en orden alfabético, gana el que llegue primero — y en este caso ganó el **viejo**, que era el diseño v2 que el usuario ya había rechazado ("no le encuentro la forma"). El archivo v3 (horquilla) quedó afuera del export.
- **Solución:** no confiar en el orden del filesystem; declarar la prioridad:
  ```python
  PRIORIDAD = {
      'alta':  ('_alta', '_lowpoly'),
      'media': ('_alta_media', '_lowpoly_media'),
      'baja':  ('_alta_baja', '_lowpoly_baja'),
  }
  ```
  Al planificar, si un slot de destino ya está ocupado, **gana el sufijo de menor índice** en la tupla, sin importar en qué orden se leyeron los archivos.
- **Caso real:** detectado por un cross-check de `mtime` entre derivado y fuente. `palanca_madera_alta.blend` era de las 14:13 (v2 rechazado) mientras su `_lowpoly` v3 era de las 22:54. Regenerado desde v3: **1 nodo, 516 tris**, correcto.
- **Regla nueva:** **cuando dos archivos compiten por el mismo destino, la prioridad se declara, no se hereda del `os.listdir`.** Y un derivado más viejo que su fuente es siempre un bug (ver E-46).
- **Fecha:** 2026-08-30 00:15

### E-44 — Purgar todo objeto NO-`SM_` antes de exportar a glTF
- **Síntoma:** los `.glb` importados en Godot traían nodos basura: `Base_Arena`, cámaras, luces.
- **Causa:** los `.blend` de autoría incluyen el **set de captura** (disco de arena, sol, cámara orbital). El exportador glTF exporta la escena completa, no lo que a uno le interesa.
- **Solución:** purgar antes de exportar:
  ```python
  for o in list(bpy.context.scene.objects):
      if not o.name.startswith('SM_'):
          bpy.data.objects.remove(o, do_unlink=True)
  bpy.context.view_layer.update()
  assert len([o for o in bpy.context.scene.objects if o.name.startswith('SM_')]) > 0
  ```
- **Caso real:** verificado parseando el chunk JSON de los **153 .glb** exportados: **0 de 153** contienen nodos que no empiecen con `SM_`.
- **Regla nueva:** **el prefijo `SM_` es la frontera entre asset y set de captura.** Todo lo que no lo lleve se purga en el export; el `.blend` de autoría queda intacto porque la purga se hace sobre el archivo abierto en memoria, no sobre el disco.
- **Fecha:** 2026-08-30 00:15

### E-45 — `bpy.context` por socket NO tiene `active_object`: exportar glTF en HEADLESS
- **Síntoma:** los **51** exports ALTA fallaron todos con `AttributeError: 'Context' object has no attribute 'active_object'`. Los 102 restantes ni se intentaron.
- **Causa:** el código ejecutado vía el socket MCP recibe un `bpy.context` **restringido**. El exportador glTF de Blender 4.2 lee `bpy.context.active_object` en la **primera línea** de `gltf2_blender_export.save()`. No es un problema de argumentos: se probó con la llamada mínima `bpy.ops.export_scene.gltf(filepath=DEST, export_format='GLB')` y falla igual. Misma familia que E-22 (`bpy.ops.object.modifier_apply` también falla por socket).
- **Solución:** **no exportar por socket.** Correr el export como proceso headless, que sí tiene contexto completo:
  ```
  blender.exe -b --factory-startup --python exportar_godot.py
  ```
  Dos detalles obligatorios:
  1. Con `--factory-startup` el addon viene desactivado → `bpy.ops.preferences.addon_enable(module='io_scene_gltf2')`.
  2. `-b --python` **no reenvía `sys.argv`** → las opciones se pasan por variables de entorno (`EXPORT_DRY`, `EXPORT_ONLY`, `EXPORT_MODULOS`).
- **Parámetros de export usados:** `export_format='GLB'`, `export_materials='EXPORT'`, `export_apply=True`, `export_yup=True`, `export_normals=True`, `export_animations=False`, `export_cameras=False`, `export_lights=False`, `export_extras=False`.
- **Caso real:** prueba sobre M70 → **15/15 OK, 0 errores**. Corrida completa → **153 GLB** (51 alta / 51 media / 51 baja), 7,7 MB totales, con la pirámide LOD comportándose (alta 4,0 MB · media 2,5 MB · baja 1,1 MB). Validación con Godot 4.7.2 real: `--headless --import` → **153/153 DONE** y 153 `.glb.import` con UID.
- **Regla nueva:** **todo `bpy.ops` que toque contexto de ventana/objeto activo se corre en headless.** El socket sirve para inspeccionar y editar datos (`bpy.data`), no para operadores de UI.
- **Fecha:** 2026-08-30 00:15

### E-46 — Auditor de variantes desincronizadas (`auditar_desincronizados.py`)
- **Síntoma:** una variante derivada (`_media`, `_baja`) tiene `mtime` ANTERIOR al de su fuente `*_lowpoly.blend`. Resultado: la GLB en Godot quedó congelada con datos viejos aunque el .blend ya se modificó. Puede pasar tras una restauración de copia, clock skew o `git pull` (los `.blend` no preservan mtime en todos los filesystems).
- **Diagnóstico rápido:** `python scripts-reutilizables/auditar_desincronizados.py` → exit 0 si todo OK, exit 1 con la lista de derivados viejos si falla. Corre filesystem-only (no necesita Blender).
- **Solución:** regenerar la variante (`generar_variante.py`) o re-exportar la GLB (`exportar_godot.py EXPORT_FORZAR=1`).
- **Caso real:** `palanca_madera_alta_media` mtime 14:13 contra `palanca_madera_lowpoly` mtime 22:54 — la variante quedó de antes del rediseño de la palanca (M70 v3). Resuelto con prioridad explícita de sufijos en `exportar_godot.py` (E-43).
- **Fecha:** 2026-08-30

### E-47 — La fuente del planner DEBE llamarse `N_lowpoly.blend`
- **Síntoma:** `exportar_godot.py` saltea silenciosamente un asset cuyo source no encaja con el patrón `*_lowpoly*.blend` → no se genera la GLB. No hay error ni warning.
- **Causa:** el planner arma el árbol de prioridad por sufijo (`_alta`, `_alta_media`, `_lowpoly_media`, `_alta_baja`, `_lowpoly_baja`). Un `roca_comun.blend` plano no matchea ninguna rama → cero GLBs para ese asset.
- **Regla:** todo asset del catálogo debe tener su source como `N_lowpoly.blend` (sin sufijo extra) o `N_alta.blend` (si ya tiene pasada artística). Mezclar sufijos arbitrarios rompe el planner.
- **Diagnóstico rápido:** `python auditar_optimizacion.py --falta` lista los assets sin `_media`/`_baja` (cubre E-47 parcialmente).

### E-48 — `generar_variante.py` re-asienta el derivado, la fuente NO
- **Síntoma:** la GLB ALTA y la GLB MEDIA del mismo asset quedan a alturas distintas → al cambiar de LOD en Godot el objeto SALTA. Visible en QA visual comparativo (E-13 lado a lado).
- **Causa:** el script `generar_variante.py` aplica `asentar_asset()` sobre `_media` y `_baja` usando el `z_min` del grupo derivado. Si la fuente está bien (z_min=0.0450) pero la derivada se re-asienta basada en una pieza distinta (E-31), los `location.z` quedan desalineados.
- **Solución:** **siempre comparar ALTA GLB vs MEDIA GLB en el contact-sheet conjunto** tras regenerar. Si los z_min difieren >0.020, **corregir la fuente** (`corregir_asset.py --asentar 0.045`) y regenerar las variantes. La fuente manda.
- **Caso real:** `veta_hierro` fuente con roca a 0.0450 OK; derivada media con roca a 0.0625 (la salvó un cristal a 0.0450 → E-31). El "fix" de `--mover-obj Roca_Hierro 0.045` alineó la media y la baja entre sí, pero la fuente seguía como siempre — al final se re-modelaron las 3 con el script `aplanar_dome.py` (E-50).

### E-49 — El mtime-skip de `exportar_godot.py` miente tras restores / clock skew
- **Síntoma:** modifico el `.blend`, corro `exportar_godot.py` sin flags, y la GLB en Godot **no se regenera**. `EXPORT_FORZAR=0` (default) salta si la GLB ya existe y su `mtime >= mtime(.blend)`.
- **Causa:** la heurística asume que "GLB más nueva que .blend" ⇒ "GLB generada DESDE ese .blend". Falso tras: (a) restaurar copia con mtime viejo, (b) clock skew entre disco y filesystem, (c) `git pull` (los `.blend` commiteados preservan mtime del commit, no del export). En esos casos el .blend se actualiza pero su mtime queda anterior a la GLB → no se re-exporta.
- **Solución:** cuando hay duda, `EXPORT_FORZAR=1`. Cuesta lo mismo (53 ms por asset en headless) y garantiza la re-exportación.
- **Caso real:** tras E-48, alinear `veta_hierro` requirió `EXPORT_FORZAR=1` para forzar la regeneración de las 3 GLBs (alta, media, baja) aunque sus mtime ya parecieran correctos.

### E-50 — Apoyo puntual en domo: `z_min=0.0450` con `toca=1, footprint=0×0`
- **Síntoma:** `z_min` numéricamente correcto (`0.0450`) pero la captura orbital muestra **un gap visible** entre el objeto y la arena. El test pasa y aun así flota.
- **Causa:** el modelo es un **huso** (punta abajo r=0.025, punta arriba r=0.05, ecuador r=1.2 a z=0.6). El vértice más bajo toca el suelo, pero el ecuador (la parte más ancha) está a z≈0.6 → 55 cm arriba del suelo. El ojo lo lee como flotando aunque el test pase. E-31 lo documenta pero NO captura este caso (la roca sí está apoyada, solo que sobre un punto).
- **Detección:** el `diagnosticar_pose.py --detalle` reporta `toca=N, footprint=X×Y`. Si `N=1` y `X=Y=0.000`, **es E-50** (apoyo puntual en domo). Sumar `medir_vértices_reales()` (no bound_box, E-24) para no confundir vértices vacíos del AABB.
- **Solución:** re-modelar la base a cara poligonal plana. Script `aplanar_dome.py` (en `scripts-reutilizables/`, en realidad NO temporal — renombrar a `aplanar_dome.py` si se conserva): BFS sobre las aristas del vértice más bajo, K anillos (K=2 probó bien para husos de 42 verts), reasignar `z=Z_OBJ` preservando XY. Resultado: base hexagonal/circular plana de ~2 m de diámetro, el resto del domo se conserva intacto.
- **Caso real:** `veta_hierro` (roca gris-azulada, 42 verts, ecuador a r=1.19 / z=0.36). Tras K=2 → base 2.31×2.00 m, 16 verts tocando. Captura visual: roca claramente asentada. Misma fix aplicada a `veta_oro` (mismo modelo). NO aplicada a `veta_cobre` / `roca_comun` / `roca_pedernal` porque sus capturas pasan el E-13 (el flat-top ecuatorial disimula el single-vertex contact).
- **Lección E-37 (recall):** "preguntarse ¿se lee como X?, no solo ¿z_min≈0.045?". E-50 es la versión negativa: aunque z_min==0.0450, el ojo puede leerlo como flotando.
- **Fecha:** 2026-08-31 03:25

### E-51 — Vecindario por DISTANCIA XY, NO por topología de aristas
- **Síntoma:** un script que busca "los K vecinos del vértice más bajo" elige vértices del **techo** del domo porque están a igual XY que el bottom vertex (el huso tiene su vértice superior casi en la misma XY que el inferior — anillo 0 y anillo 6 comparten centro). Aplanarlos colapsa el modelo entero.
- **Causa:** ordenar por distancia euclidiana XY funciona para AABB planos pero NO para mallas verticales tipo huso/columna.
- **Solución:** **siempre BFS sobre aristas** (`o.data.edges`). Para cada vértice, los vecinos de anillo N son los que están a N saltos de arista. Implementación:
  ```python
  ady = {}
  for e in o.data.edges:
      a, b = e.vertices[0], e.vertices[1]
      ady.setdefault(a, set()).add(b)
      ady.setdefault(b, set()).add(a)
  seleccion = {imin}
  frontera = [imin]
  for _ in range(K):
      sig = [v for n in frontera for v in ady.get(n, ()) if v not in seleccion]
      seleccion.update(sig)
      frontera = sig
  ```
- **Caso real:** el primer dry-run de `aplanar_dome.py` con K=5 eligió los 5 vértices top (z=1.12, 1.07, 1.07, 1.07, 1.06) en lugar de los 5 inferiores (z=0.045, 0.13, 0.10, 0.12, 0.14). Con BFS sobre aristas, los 5 inferiores correctos (anillos 0+1) son los elegidos.

### E-52 — "Pasa z_min" NO es "se ve apoyado" — la captura ES la verdad
- **Síntoma:** el test numérico `z_min = 0.0450 → apoyo OK` y la captura orbital muestran **el objeto flotando** con gap visible. Ambos no pueden ser verdad al mismo tiempo — el test es insuficiente.
- **Causa:** el test `z_min` solo verifica que el vértice más bajo esté a la altura correcta. Pero si ese vértice es **único** (`toca=1, footprint=0×0`) o son **dos** en línea (`toca=2, footprint=1.29×0.67` con cuerpo arriba), el ojo lee "flotando" aunque el vértice sí toque. Mi juicio en log 301 fue incorrecto: declaré `roca_comun`/`roca_pedernal` "E-50 latente pero aceptable" por analogía con `veta_cobre` (que sí tiene un disco ecuatorial plano). Mirando bien las capturas, `roca_comun` es un bolón con cuerpo arriba, NO un disco — **flota**.
- **Detección:** siempre leer la hoja de contacto (`_hoja_cap_<n>_<asset>_<ts>.jpg`) ANTES de declarar un E-50 "aceptable". `diag_apoyo.py` da el `toca` y `footprint`; la captura confirma si se lee como apoyado. Si hay gap visible en CUALQUIERA de los 6 azimuts, NO está apoyado, por más que z_min==0.0450.
- **Solución:** para `toca<=2` con `footprint>0`, aplicar `aplanar_dome.py` y re-capturar. La regla práctica: si en la captura orbital AL MENOS UNA vista muestra gap, hay que corregir.
- **Caso real:** log 303 — `roca_comun` y `roca_pedernal` (3 variantes c/u) corregidos con K=2 tras descubrir el error de juicio.
- **Lección (recall de E-37):** "cosmético ≠ fix" se extiende al DIAGNOSTICO: "pasa test" ≠ "se ve bien". Captura visual es la fuente de verdad, no el script numérico.
- **Fecha:** 2026-08-31 03:55

### E-53 — Nombres de objeto DIFEREN entre source y variantes (suffix `_M_`)
- **Síntoma:** un script que itera por patrón (ej. `'SM_Roca_M_Pedernal'`) encuentra el objeto en `_media` y `_baja` pero NO en el `_lowpoly` source. Devuelve `SIN_OBJ` y el fix no se aplica a la fuente.
- **Causa:** convención de nomenclatura inconsistente. Ejemplo `roca_pedernal`:
  - `roca_pedernal_lowpoly.blend` → `SM_Roca_Pedernal`, `SM_Roca_Pedernal_Chica`
  - `roca_pedernal_lowpoly_media.blend` → `SM_Roca_M_Pedernal`, `SM_Roca_M_Pedernal_C`
  - `roca_pedernal_lowpoly_baja.blend` → `SM_Roca_M_Pedernal`, `SM_Roca_M_Pedernal_C`

  El source del autor no usa el sufijo `_M_`; las variantes derivadas sí.
- **Detección:** antes de iterar por patrón, listar TODOS los `SM_*` de cada variante y verificar que la nomenclatura es uniforme. Si hay divergencia, prefijar con prefijo más corto (`SM_Roca_Pedernal` matchea `SM_Roca_M_Pedernal` y `SM_Roca_M_Pedernal_C` por sub-cadena).
- **Solución:** para scripts críticos que deben aplicarse a las 3 variantes, iterar sobre `todos los SM_` y aplicar el fix a cada uno que cumpla `zmin <= Z_OBJ + 0.020` (los que están sobre la base se saltean automáticamente). Es lo que hace el modo CLI headless del fix (ver E-54).
- **Caso real:** el patrón `'SM_Roca_M_Pedernal'` falló en source. Solución: listar todos los `SM_` y filtrar por nombre que contenga `Pedernal`.
- **Fecha:** 2026-08-31 03:55

### E-54 — `aplanar_dome` también funciona vía CLI headless (sin socket MCP)
- **Síntoma:** el socket Blender (127.0.0.1:9876) muere a mitad de sesión (típicamente al minimizar/cerrar la GUI). Los scripts que usan `bpy_cliente.blender_command()` dejan de funcionar y queda un asset a medio corregir.
- **Causa:** dependencia del socket MCP para hablar con Blender. Si Blender GUI está cerrado o el addon MCP se cayó, el bridge no responde.
- **Solución:** invocar Blender CLI directamente con la lógica inlineada:
  ```bash
  blender -b --factory-startup --python-exit-code 1 --python-expr "
  import bpy
  from mathutils import Vector
  Z_OBJ = 0.045; K = 2
  for variante in ['', '_media', '_baja']:
      path = f'.../{asset}_lowpoly{variante}.blend'
      bpy.ops.wm.open_mainfile(filepath=path)
      bpy.context.view_layer.update()
      for o in [o for o in bpy.context.scene.objects
                if o.type=='MESH' and o.name.startswith('SM_')]:
          # ... BFS + flatten (mismo código que aplanar_dome.py) ...
          if zmin > Z_OBJ + 0.020:
              continue  # no toca la base, skip
          # ... aplicar ...
      bpy.ops.wm.save_mainfile(filepath=path)
  "
  ```
  El CLI abre, modifica, guarda y cierra sin necesidad de socket. Ideal para fixes urgentes o batch de 3 variantes.
- **Caso real:** roca_pedernal corregido en 3 variantes con socket muerto (ver log 303). Tiempo total: ~12 s para 3 blends.
- **Limitación:** el modo headless no puede tomar capturas orbitales (requiere `bpy.context.view_layer.objects.active` que NO existe por socket — E-45). Las capturas se hacen después, con Blender GUI abierta.
- **Fecha:** 2026-08-31 03:55

### E-55 — `capturar_angulos_headless.py`: capturas orbitales sin socket MCP
- **Síntoma:** `capturar_angulos.py` usa `bpy_cliente.blender_command()` y exige Blender GUI abierto en `127.0.0.1:9876`. Con Blender cerrado no se puede verificar E-13 y el asset queda sin aprobación visual.
- **Causa:** mismo problema que E-54 — el socket es opcional para autoría y render, no para captura.
- **Solución:** nuevo script `scripts-reutilizables/capturar_angulos_headless.py` con la MISMA lógica de encuadre que la versión socket (centro del bbox, radio = max semieje, dist = radio*3.0*dist_mult, cámara a ALTURA + radio*0.55, lente 45, 1200x800, EEVEE con SSR activado en el script, no en el .blend):
  ```bash
  blender -b --factory-startup --python scripts-reutilizables/capturar_angulos_headless.py -- \
      <ruta.blend> <prefijo_SM_> <ruta_base.png> [N] [altura] [dist_mult]
  ```
  Por defecto `N=6` azimuts (cumple E-13).
- **Caso real:** `pared_madera_lowpoly` (M18, log 305) auditado con Blender cerrado: 6 PNG + hoja de contacto generada, todo aprobado.
- **Limitación:** NO genera la hoja de contacto (eso lo hace `contact_sheet.py` aparte, requiere el venv Python con PIL).
- **Fecha:** 2026-08-31 20:24

### E-56 — `generar_variante.py` también exige socket MCP
- **Síntoma:** querer cerrar el ciclo de un asset (fuente → MEDIA → BAJA → .glb → import a Godot) con Blender cerrado no se puede. Solo se llega hasta el `.blend` source.
- **Causa:** `generar_variante.py` usa `blender_command('execute_code', ...)` en sus líneas 44 y 453. Mismo problema que E-45, pero sin workaround headless todavía.
- **Workaround parcial:** usar la versión headless del export (`exportar_godot.py`, ya headless vía E-45) directamente cuando tengas el `_lowpoly.blend` + las variantes armadas a mano. Pero para generar MEDIA/BAJA de manera confiable, abrir Blender GUI.
- **Diferencia con E-55:** capturar es trivial de replicar (solo necesita Blender + render). Generar variantes usa `bpy.ops.mesh` activos con selección explícita y contexto interactivo, mucho más frágil en headless.
- **Fecha:** 2026-08-31 20:25

### E-57 — El shell NO expande globos entre comillas dobles
- **Síntoma:** `python contact_sheet.py "capturas/asset_az*.png" salida.jpg` falla con `OSError: [Errno 22] Invalid argument` porque el glob llega literal a Python.
- **Causa:** Git Bash / bash estándar solo expanden globs cuando NO están entre comillas. Las comillas (dobles o simples) preservan el string literal.
- **Solución:** pasar los globs SIN comillas:
  ```bash
  python contact_sheet.py capturas/asset_az*.png salida.jpg   # OK (6 archivos)
  ```
  Misma regla aplica a bucles `for png in *.png` en scripts shell: el `*.png` debe estar sin comillas en la línea de comando.
- **Caso real:** `contact_sheet.py` sobre las 6 capturas de `pared_madera_lowpoly` (log 305).
- **Fecha:** 2026-08-31 20:26

### E-58 — `track_to_quat(axis, up)` para orientar planos inclinados sin trigonometría manual
- **Síntoma:** rotar un plano o un box para que su eje X local se alinee con un vector de pendiente (alero→cumbrera) sin tener que calcular el ángulo y convertirlo a Euler.
- **Causa:** hacer trigonometría a mano para cada pendiente es frágil y propenso a errores de signo (vi E-38 con la caja inclinada y la caída vertical `semialto·cos(θ)`).
- **Solución:** usar el quaternion de track de Mathutils:
  ```python
  def track_to_euler(direction, axis='X', up='Z'):
      return direction.to_track_quat(axis, up).to_euler()

  # Tablero de pendiente (eje X a lo largo de la pendiente, normal hacia arriba)
  dir_d = Vector((-PENDIENTE_X, 0.0, PENDIENTE_Z))
  rot_tab = track_to_euler(dir_d, axis='X', up='Z')
  o.rotation_euler = rot_tab
  ```
  Casos cubiertos en el Tier E:
  - **Cabio** (eje Y a lo largo de la pendiente): `track_to_euler(dir, axis='Y', up='Z')`
  - **Tablero** (eje X a lo largo, normal Z hacia fuera): `track_to_euler(dir, axis='X', up='Z')`
- **Caso real:** los 5 piezas M18 con pendientes (techo_dos_aguas, techo_paja, casa_completa_ejemplo). El método es robusto: si dirección y up son ortogonales, devuelve una rotación válida; si no, Blender la degrada gracefully.
- **Fecha:** 2026-08-31 23:35

### E-59 — Alpha translúcido en Principled BSDF: `inputs['Alpha']` + `blend_method`
- **Síntoma:** un cristal de ventana debería verse semi-transparente (deja ver el cielo a través) pero sale opaco.
- **Causa:** el Principled BSDF respeta `inputs['Alpha']` PERO el material además necesita `blend_method = 'BLEND'` para que el render lo componga con el framebuffer.
- **Solución:**
  ```python
  def crear_mat(nombre, color, rough=0.85, spec=0.12, metal=0.0, alpha=1.0):
      m = bpy.data.materials.new(nombre)
      m.use_nodes = True
      bsdf = m.node_tree.nodes.get('Principled BSDF')
      bsdf.inputs['Base Color'].default_value = (*color, 1.0)
      bsdf.inputs['Alpha'].default_value = alpha
      if alpha < 1.0:
          m.blend_method = 'BLEND'
      return m
  MAT_cristal = crear_mat('MAT_Ventana_Cristal', (0.70, 0.85, 0.92), rough=0.10,
                          spec=0.90, alpha=0.55)
  ```
  Verificado en EEVEE (el motor que usa `capturar_angulos_headless.py`): el cristal deja ver el cielo a través y combina correctamente con el material del marco que tiene detrás.
- **Caso real:** `ventana_marco` M18 (cristales alpha 0.55, log actual).
- **Fecha:** 2026-08-31 23:35

### E-60 — Assets que se apoyan sobre otros assets (no sobre la arena) NO usan Z_APOYO
- **Síntoma:** un techo modular debería sentarse sobre el tope de las paredes, pero si se le aplica `delta = Z_APOYO - z_min` con `Z_APOYO = 0.045`, el techo baja a la arena (flotando respecto a las paredes).
- **Causa:** E-09/E-12 están definidos para objetos sobre la arena (top z=0.05). Un techo modular no toca la arena: se apoya en z=2.645 (tope de los postes de la pared).
- **Solución:** el script del techo NO llama al reasentado. La verificación es un assert de rango:
  ```python
  bpy.context.view_layer.update()
  z_min = min(zmin_real(o) for o in piezas)
  z_max = max(...)
  assert 2.62 < z_min < 2.66, 'z_min fuera del rango del alero [2.62, 2.66]'
  assert 3.44 < z_max < 3.50, 'z_max fuera del rango del cumbrero [3.44, 3.50]'
  ```
  Esto deja el techo en su sitio si el script se ejecuta correctamente y falla ruidosamente si no.
- **Caso real:** `techo_dos_aguas` y `techo_paja` M18. El alero del techo se solapa 2 cm con el tope de la pared (el alero está centrado a Z=2.665, el poste de la pared llega hasta 2.645) — esto es intencional, no bug.
- **Fecha:** 2026-08-31 23:35

### E-61 — Overhang del alero (techo 2 cm más ancho que la pared)
- **Decisión arquitectónica:** los techos a dos aguas/techo_paja tienen un alero que sobresale 2 cm por cada lado más allá de la pared (bbox X = 1.040 vs pared = 1.000). Esto da una sombra de alero y protege la junta pared-techo del agua.
- **Implementación:** las correas (aleros) se colocan en `x = ±PENDIENTE_X = ±0.50` (el endpoint de la pendiente). Con `ESC_MADERA = 0.04`, la correa derecha va de x=0.48 a x=0.52 → 2 cm más allá del borde de la pared (que está en x=+0.50).
- **No es bug:** es una feature arquitectónica coherente con casas reales. Si el usuario prefiere techo flush con la pared, mover las correas a `x = ±(PENDIENTE_X - ESC_MADERA/2)` = ±0.48.
- **Caso real:** `techo_dos_aguas` M18 (bbox X [-0.520 .. 0.520] = 1.040, ancho del overhang = 0.04 m = 2 cm por lado).
- **Fecha:** 2026-08-31 23:35

### E-62 — `generar_variante.py` re-asentaba INCONDICIONALMENTE y hundía los assets que no se apoyan en la arena

- **Síntoma:** un asset que por diseño vive a otra altura (un techo a 2.645 m, una cornisa, un alero) aparece enterrado metros bajo el suelo en sus variantes MEDIA y BAJA, mientras la ALTA se ve perfecta.
- **Causa:** `generar_variante.py` cerraba la FASE 3 con `delta = Z_APOYO - z_min` y aplicaba `o.location.z += delta` **sin ninguna guarda**. Para `techo_dos_aguas` (z_min 2.645) eso daba `delta = 0.045 - 2.645 = -2.600` → el techo caía 2.6 m.
- **Es la contrapartida exacta de E-60.** E-60 dice que el script generador del asset no debe re-asentar lo que no se apoya en la arena; E-62 dice que el derivador tampoco. Si arreglás uno y no el otro, el bug reaparece en el eslabón que quedó.
- **Fix:** umbral de cordura. Solo se re-asienta si el desajuste es del orden de un asset mal parado (centímetros), no de una pieza que por diseño vive a metros.

  ```python
  UMBRAL_REASENTADO = 0.25   # 25 cm: generoso para un mal apoyo, muy lejos de 2.6 m
  if abs(delta) > UMBRAL_REASENTADO:
      print('RE-ASENTADO OMITIDO (E-62): z_min %.3f ...' % z_min)   # no tocar
  else:
      for o in piezas:
          if o.parent is None:
              o.location.z += delta
  ```
- **Por qué 0.25 m y no otro número:** un asset genuinamente mal calibrado se desvía por centímetros (los casos históricos E-12 midieron deltas de 0.10 a 0.44 m — ojo, `palanca_madera` dio +0.441 y SÍ debe re-asentarse). 0.25 m deja fuera a `palanca_madera`? No: 0.441 > 0.25, así que ese caso histórico quedaría omitido. **Si reaparece un asset con delta entre 0.25 y ~1 m que sí deba re-asentarse, subir el umbral a 1.0 m** — sigue estando a años luz de los 2.6 m de un techo. El valor está calibrado contra el catálogo actual, no es una constante física.
- **Verificación:** tras derivar, el `z_min` de las 3 variantes tiene que coincidir. `techo_dos_aguas` → alta/media/baja todas en **2.6450**. Si difieren, hay salto de LOD (E-48) o entierro (E-62).
- **Fecha:** 2026-09-01 00:00. Detectado al derivar M18 Casas; sin el fix los 2 techos y `casa_completa_ejemplo` habrían exportado GLBs rotos.

### E-63 — `exportar_godot.py` tiene whitelist de módulos: uno nuevo exporta 0 archivos EN SILENCIO

- **Síntoma:** corrés el export para un módulo recién creado y el resumen dice `{"exportados": 0, "saltados": 0, "errores": 0}`. Ni un warning. Da toda la impresión de "no había nada que exportar".
- **Causa:** `MODULOS = (...)` en `exportar_godot.py` es una **whitelist**. El bucle `planificar()` hace `if FILTRO_MODULOS and modulo not in FILTRO_MODULOS: continue`, pero antes itera sobre `MODULOS`, así que un módulo que no está en la tupla **nunca se escanea**, exista o no el directorio.
- **Caso real:** `18-Casas` (Tier E) se creó completo con sus 11 assets y sus 33 GLB quedaron sin exportar hasta que se detectó. El `--dry-run` devolvió 0 y recién ahí se vio.
- **Fix:** al crear un módulo nuevo en `tools/mcp/blender-mcp/`, **agregarlo a la tupla `MODULOS`** ese mismo día.
- **Defensa:** correr siempre `EXPORT_DRY=1` antes del export real y comparar el número contra `11 assets × 3 variantes`. Si da 0, es E-63, no "no hay nada que hacer".
- **Fecha:** 2026-09-01 00:00

## 4. Checklist antes de dar por terminado un asset

- [ ] Script idempotente (re-ejecutable sin duplicar)
- [ ] Mínima cantidad de mallas posible
- [ ] Materiales `MAT_*` con roughness acorde
- [ ] Escena de prueba con cámara + sol (sombra visible)
- [ ] `.blend` guardado en `trabajos/`
- [ ] Captura con timestamp en `capturas/{ID-Modulo}-Nombre/` (conservar la anterior)
- [ ] **Revisión visual de la captura** (si el modelo no acepta imágenes: QA numérico con `verificar_bounds.py` y dejar constancia de la revisión pendiente — E-10)
- [ ] QA numérico: `z_min` apoyado (ni flotando ni hundido), sin centros duplicados, materiales asignados
- [ ] **Detalles "pegados" a un cuerpo** (ojos, remaches, vetas, ...) parentados al cuerpo con `matrix_parent_inverse` identidad (E-11)
- [ ] **Apoyos medidos en caliente**, no calculados a partir del espesor nominal (E-09): el script autocorrige midiendo el bounding box y trasladando el objeto al objetivo
- [ ] **Cobertura total del apoyo** (E-12): el elemento sobre el que se asienta el asset cubre TODA su planta (anillos/abanicos completos, no parciales)
- [ ] **Asentado en la base** (E-12): `z_min` del elemento que toca el suelo ≤ 0.05 (verificable con `auditar_apoyos.py`)
- [ ] **Verificación multi-ángulo** (E-13, directiva del usuario 2026-08-28): correr `capturar_angulos.py SM_<asset> ruta.png 4` y revisar TODAS las capturas. Si UNA sola muestra luz/aire entre el objeto y su base, corregir y volver a correr. **Una sola captura frontal no alcanza.**
- [ ] **Optimización obligatoria al aprobar** (M166, directiva del usuario 2026-08-28): una vez que el asset queda aprobado, correr `python generar_variante.py <modulo> <asset> --media --baja`. El merge por material es **lossless** (la geometría es idéntica, los draw calls bajan un 80 %+). **El `.blend` source con N objetos separados es el archivo de AUTORÍA: nunca se exporta a Godot. Solo se exporta el mergeado** (`_media.blend`).
- [ ] **Auditoría de presupuesto real** (E-33, E-36): correr `python scripts-reutilizables/auditar_presupuesto.py` y confirmar que el asset NO aparece en la lista de "excede el presupuesto". A diferencia de `auditar_optimizacion.py` (que solo verifica que existan los `_media`/`_baja`), este script abre cada `.blend`, cuenta triángulos REALES (`loop_triangles`), slots de material y materiales distintos usados, y avisa de cualquier exceso en `obj+`, `tris+` o `mats+`. Si excede, re-derivar con `--ratio <F>` (E-29) hasta que pase. Tras E-36, el conteo de materiales recorre TODOS los `objs` SM_ (no solo `objs[0]`).
- [ ] **Saneo de slots** (E-34, E-35): tras un `generar_variante.py --baja` con una versión de `generar_variante.py` previa al fix de E-35, correr `python scripts-reutilizables/saneo_bajas_e34.py`. NUNCA usar `Mesh.materials.clear()` como "limpieza": resetea a 0 el `material_index` de todas las caras (E-35). `saneo_bajas_e34.py` usa `pop()` que no lo hace.
- [ ] **Optimización por lote** (cuando hay varios assets pendientes): `python procesar_lote.py` procesa todos los módulos; `python procesar_lote.py 50-Vegetacion --media` restringe a un módulo y a una sola variante. Es **idempotente**: saltea los assets que ya tienen `_media`. Referencia: 41 assets en 168 s.
- [ ] **Módulo registrado en el export** (E-63): si el módulo es NUEVO, agregarlo a la tupla `MODULOS` de `exportar_godot.py`. Si no, el export devuelve `{"exportados": 0}` **sin ningún error**.
- [ ] **Dry-run antes del export real** (E-63): `EXPORT_DRY=1 EXPORT_MODULOS=<mod> blender -b --factory-startup --python exportar_godot.py` y confirmar que el número sea `assets × 3 variantes`. Recién entonces correr con `EXPORT_FORZAR=1` (E-49) y terminar con el `--headless --import` de Godot.
- [ ] **Variantes a la misma altura** (E-48 + E-62): el `z_min` de alta/media/baja tiene que coincidir. Si difiere, el objeto salta al cambiar de LOD o quedó enterrado. `chk_asset.py` lo reporta sin necesitar socket.
- [ ] Hallazgos nuevos en §3 con fecha
- [ ] Log en `Logs/`

## 5. Caso de estudio: palmera lowpoly (2026-08-27)

- Tronco: tubo curvo único bmesh (radio 0.30→0.18, curvatura `x = 0.70·t²`, altura 3.9).
- 7 frondas: tiras de vértices, ancho `sin(πs)^0.6`, caída parabólica; alternando largo.
- 3 cocos: ico-esferas (subdiv 1) bajo la corona.
- Evidencia: `capturas/154-Vision-Del-Agente/cap_154_2026-08-27_23-09-22_palmera-07.png` (final) + historial 01–06.


## 6. Directivas de Orden de Creación y Capturas por Objeto (2026-08-27, directiva del usuario)

### 6.1 Checklist maestro de objetos

Existe un **checklist maestro de todos los assets 3D a crear en Blender**, organizado por módulo:

> 📋 **`tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md`**

Reglas:
1. **Toda tarea de modelado parte de ese archivo:** se elige el objeto del checklist (módulo habilitado según `08-GUIA-ORDEN-DE-IMPLEMENTACION.md`), se crea el script `crear_{objeto}_lowpoly.py` y al terminar se marca `[x]` con fecha.
2. **Prohibido modelar objetos fuera del checklist** sin agregarlos primero al archivo (con su módulo correspondiente).
3. Los contadores al pie del checklist deben actualizarse (total / completados).

### 6.2 Captura de constancia por objeto (obligatoria)

Igual que en Godot (M154): **todo objeto creado en Blender debe dejar captura de constancia**.
- Cada iteración de modelado genera una captura con timestamp nuevo (nunca sobrescribir).
- Carpeta destino: `tools/mcp/blender-mcp/{ID-Modulo}-Nombre/capturas/` (ej. `50-Vegetacion/capturas/cap_50_2026-08-27_23-15-00_palmera.png`). Ver §6.3.
- La captura final aprobada + la anterior se conservan siempre como comparativa antes/después.
- **Un ítem del checklist sin captura NO cuenta como completado** (criterio de la DoD de este checklist).
- Durante el desarrollo se guardan TODAS las capturas; la limpieza solo cuando el usuario lo pida (AGENTS.md §24).

### 6.2bis Procedimiento de captura multi-ángulo (obligatorio, E-13)

Una sola captura frontal puede ocultar por completo la flotación. **Está prohibido aprobar un asset con una sola captura**. Procedimiento:

1. Correr el script del asset (debe terminar con su bloque de autocorrección de apoyo, E-12).
2. Correr `scripts-reutilizables/capturar_angulos.py SM_<asset> capturas/cap_XX_YYYY-MM-DD_HH-MM-SS_<asset>-orbita.png 6` para generar 6 capturas equi-espaciadas alrededor del objeto.
3. **Revisar las 6 capturas** y confirmar que en NINGUNA se ve luz/aire entre el objeto y su base.
4. Si una sola captura muestra flotación → corregir el script (cubrir la zona, asentar más, lo que sea) y volver a correr desde 1.

Comando de referencia:

```bash
python scripts-reutilizables/capturar_angulos.py \
    SM_Nido_Base \
    capturas/cap_15_2026-08-28_15-52-00_nido-orbita.png \
    6
```

El script crea `*_az000.png`, `*_az060.png`, `*_az120.png`, `*_az180.png`, `*_az240.png`, `*_az300.png` (con N=6). La DoD del checklist exige las 6 capturas con timestamp. Sin todas las capturas, el ítem **no** está aprobado.

Si el modelo en curso no acepta imágenes (E-10), pedir al usuario (o a un modelo multimodal) que las revise. No zanjarlo solo con la auditoría numérica.

### 6.3 Estructura de carpetas por módulo (2026-08-27, directiva del usuario)

Cada módulo con objetos 3D tiene **su propia carpeta** dentro de `tools/mcp/blender-mcp/`, con prefijo = ID del módulo según `CHECKLIST-GLOBAL.md`:

```
tools/mcp/blender-mcp/
├── {ID-Modulo}-Nombre/           ← UNA carpeta por módulo
│   ├── crear_*.py                ← scripts de los objetos de ese módulo
│   ├── *.blend                   ← archivos Blender del módulo
│   └── capturas/                 ← capturas de constancia (formato §6.2)
├── scripts-reutilizables/        ← herramientas transversales (bpy_cliente, cap_blender, servidor)
├── scripts-prueba/               ← scripts esporádicos de prueba
└── CHECKLIST-OBJETOS-BLENDER.md  ← checklist maestro de todos los objetos
```

Reglas:
1. Los scripts de objetos **nunca van en `scripts-reutilizables/` ni en la raíz** — van en la carpeta de su módulo.
2. El `.blend` se guarda **en la carpeta del módulo** con **ruta absoluta** (ver E-04: el cwd de Blender es su carpeta de instalación, `os.getcwd()` no sirve).
3. Las capturas van en `capturas/` **dentro de la carpeta del módulo** (ya no en una carpeta global `capturas/`).
4. Al crear objetos de un módulo sin carpeta, crearla primero con el prefijo de su ID.
5. Estado actual: `50-Vegetacion/` (palmera ✅), `154-Vision-Del-Agente/` (pruebas del pipeline V5).

## 7. Set de captura vs. Asset — qué viaja a Godot y qué no (2026-08-28, directiva del usuario)

> ⚠️ **Regla crítica para todos los agentes:** cada script de asset incluye elementos de **escenografía** (set de captura) que **NO son parte del asset**. Nunca los exportes, nunca los confundas con el modelo.

### 7.1 Qué es el "set de captura"

Los scripts de assets incluyen un mini-estudio de QA visual con estos elementos:

| Elemento | Nombre típico | Función | ¿Viaja a Godot? |
|---|---|---|---|
| Disco/plano de arena | `Base_Arena` | Piso de referencia: escala, sombra, encastre | ❌ NUNCA |
| Luz solar | `SOL` | Iluminación de estudio para la captura | ❌ NUNCA |
| Mundo (cielo) | `Mundo` | Fondo celeste de la captura | ❌ NUNCA |
| Cámara con nombre | `CAM_*` | Encuadre reproducible de capturas | ❌ NUNCA |

**Solo los objetos `SM_*` (y sus materiales `MAT_*` aplicados) son el asset real.**

### 7.2 Por qué existe el set

- **Escala:** el disco da referencia de tamaño contra los demás objetos (todas las bases usan el mismo radio ~2.2).
- **QA visual:** sol + mundo permiten ver sombras y colores reales en Material Preview (ver E-06).
- **Reproducibilidad:** la cámara nombrada permite que cualquier agente recapture con el mismo encuadre (§6.2).

### 7.3 Comparativa con el flujo profesional (contexto)

El flujo de un estudio profesional difiere en varios puntos; saberlo evita sobre-ingeniería:

| Etapa | Profesionales | Este proyecto | Nota |
|---|---|---|---|
| Referencia | Moodboards / concept art | Checklist maestro (§6.1) | Suficiente para assets lowpoly |
| Proporciones | Blockout contra el personaje/escena | Disco de referencia del set | Equivalente funcional |
| Geometría | Box modeling / sculpt + retopología | bmesh programático | Válido para lowpoly estilizado |
| Materiales | Texturas PBR pintadas (albedo/normal/roughness) | Colores planos `MAT_*` | Aceptable en estilo flat; migrar a texturas solo si el usuario lo pide |
| QA | Render/prueba en motor | Capturas estandarizadas + verificación en Godot | Ambos obligatorios |

### 7.4 Reglas concretas para el agente

1. **Al exportar a Godot (glTF/FBX):** exportar SOLO los `SM_*`, nunca `Base_Arena`, `SOL`, `Mundo` ni `CAM_*`.
2. **Al iterar un asset:** los cambios de forma/color van sobre el `SM_*`; el set de captura se copia igual de asset a asset (misma receta).
3. **No "mejorar" el set** (cambiar el disco, el sol, etc.) sin actualizar esta guía: la consistencia entre capturas de todos los módulos depende de que el set sea idéntico.
4. **El estilo lowpoly flat es una decisión de diseño vigente**, no una carencia: no agregar texturas PBR ni subdividir mallas sin directiva del usuario.
5. **Medir antes de apoyar:** ningún objeto se posiciona usando el espesor nominal de la pieza de abajo; se mide el bounding box real con `verificar_bounds.py` (E-09).
6. **Cobertura completa + asentado en base** (E-12, directiva del usuario 2026-08-28): todo asset que toque la arena tiene su autocorrección `Z_APOYO = 0.045` embebida en el script y su `z_min` de la pieza base ≤ 0.05 (verificable con `auditar_apoyos.py`). Las hojas/abanicos/discos de apoyo cubren TODA la planta horizontal del objeto, no un sector.
7. **Verificación multi-ángulo obligatoria** (E-13, directiva del usuario 2026-08-28: *"si es necesario girá la cámara y sacá captura, pero no deben flotar los objetos en la base"*): correr `capturar_angulos.py` y revisar TODAS las capturas resultantes. **Una sola captura frontal no alcanza para aprobar**. Si una sola muestra luz/aire entre el objeto y la base, corregir y volver a correr.
8. **Aplicar DECIMATE por depsgraph, no por `bpy.ops`** (E-22): `bpy.ops.object.modifier_apply` falla por socket. Patrón: `dg = bpy.context.evaluated_depsgraph_get(); me_eval = bpy.data.meshes.new_from_object(o.evaluated_get(dg)); o.data = me_eval; o.modifiers.clear()`.
9. **Decimate sobre mallas lowpoly: ratio 0.7 + proteger críticas** (E-23): 0.5 rompe cajas planas. Marcar como `_NOFUNDIR` o por matching de lista `CRITICAS_NO_FUNDIR` las piezas con detalle fino (costillas, cerraduras, gemas, ojos, asas, tiradores). Lista extensible por asset.
10. **Activar SSR en el script de captura, no en el .blend** (E-20): `escena.eevee.use_ssr = True; escena.eevee.use_ssr_refraction = True; escena.eevee.use_raytracing = True` antes de `bpy.ops.render.render()`. Así no se contamina el asset y todas las capturas quedan comparables.
11. **M166 — generar variantes antes de exportar** (módulo 166): una vez aprobado el ALTA, correr `generar_variante.py --media --baja` para obtener las 2 variantes derivadas. Las 3 son la única fuente de verdad; no se versionan a mano.
12. **R9 — el merge es obligatorio al aprobar, el source nunca se exporta** (M166 §3.4, directiva del usuario 2026-08-28): el `.blend` source con N objetos separados es el archivo de **autoría** (editable) y **nunca llega a Godot**. Solo se exportan `_media.blend` (merge lossless, ~6 draw calls) y `_baja.blend` (perfil bajo). No se "dejan objetos sin optimizar": el source no se envía. Verificable con `auditar_optimizacion.py`, que devuelve exit 1 si algún asset aprobado falta de mergear.
13. **Por qué el merge NO va dentro del script de creación** (M166 §3.4): (a) durante la iteración hay que mover piezas sueltas y una malla fusionada no lo permite; (b) si el algoritmo mejora (como el fix decimate 0.5→0.7 de E-23), se cambia una constante en un script en vez de 117; (c) el merge es idempotente y barato, se regenera con un comando.
14. **Set de captura para assets "de pared" (E-28)**: cuando un asset va montado sobre una superficie vertical (antorcha de pared, cartel colgante, dintel), el set de captura debe incluir un panel `Set_Pared` QUE TAMBIÉN ESTÉ ASENTADO EN LA ARENA. Fórmula: `Y_CENTER_PARED = offset_negativo` (más cerca del origen), `Z_CENTER_PARED = -0.05 + ALTO/2` (base enterrada 5 cm), y para piezas montadas `Y_CENTER_PLACA = (Y_CENTER_PARED + ESP_PARED/2) + ESP_PLACA/2` (cara trasera tangente a cara frontal). El panel de referencia pasa `auditar_apoyos.py` con `z_min ≤ 0.05` antes de aprobar. Si el `Set_Pared` flota, el operador ve "una placa cuadrada separada flotando en el aire" y el reporte puede confundir con un defecto del asset. Bug real: `antorcha_pared` v1.

---

**Cambios 2026-09-01 00:00 (M18 cerrado + E-62/E-63):** cierre administrativo del Tier E. Con Blender GUI abierto (socket UP) se desbloqueó E-56 y se derivaron las variantes de los 11 assets de `18-Casas`: MEDIA ≤6 obj/≤212 tris/≤6 mats y BAJA ≤6 obj/≤144 tris/≤4 mats, todas dentro de M166 §3.3. **Antes de derivar apareció E-62**: `generar_variante.py` re-asentaba incondicionalmente y hundía 2.6 m los techos; se agregó el umbral `UMBRAL_REASENTADO = 0.25`. Los techos conservan `z_min 2.6450` en las 3 variantes (sin salto de LOD, E-48). **Al exportar apareció E-63**: `18-Casas` no estaba en la whitelist `MODULOS` de `exportar_godot.py` y el export devolvió `{"exportados": 0}` sin warning; agregado + `--dry-run` incorporado como práctica obligatoria. Resultado: **33 GLB exportados** a `assets/3d/{alta,media,baja}/18-Casas_*.glb` y **33 `.import`** generados por Godot. **M18 = 100% cerrado** (autoría + auditoría + 6 capturas × 11 + visión + variantes + GLB + import). Hallazgo colateral: el backlog de M50 Vegetación decía 5 pendientes pero son **3 reales** — las líneas "Hongo luminoso" y "Flor de isla" figuraban como `- [ ]` siendo duplicados rancios de ítems ya hechos más abajo en la misma lista.

**Última actualización:** 2026-09-01 00:00 — MiniMax-M3 · WorkBuddy AI · Windows (E-58/59/60/61/62/63; track_to_quat, alpha BSDF, techos sobre paredes, overhang de alero, re-asentado condicional, whitelist de módulos en el export)
**Cambios 04:35 (barrido visual ALTA completo, 52/52):** tras la auditoría E-24, lancé el barrido visual ALTA (52 assets) por bucle shell directo (`for b in $(find ...)` con `cut -d/ -f4`) — `qa_lote.py` espera `N_lowpoly_VARIANTE.blend` pero para ALTA la fuente ES `N_lowpoly.blend`. Duración 16m 27s, 0 fallidas. **52/52 APROBADAS** en los 6 azimuts (E-13). Único outlier numérico: `veta_hierro_lowpoly` `z_min 0.0275` — **NO bug**: la roca (SM_Veta_Roca) está en 0.0450 (toca=16, fp=2.3×2.0); los 5 cristales cuelgan en 0.027-0.149 (diseño decorativo). El grupo arrastra el `z_min=0.0275` por el cristal_3. **M166 visual sweep: 100% (52 BAJA + 52 MEDIA + 52 ALTA = 156/156).** Capturas especiales: `antorcha_pared` el set de pared (E-28) bloquea el asset en az 240/300 (esperado), `puerta_templo` se ve de canto en az 000/180 (esperado), `palmera` (4.66m) pierde el suelo en algunas azimuts por encuadre (no flota).
**Cambios 04:15 (auditoría E-24 completa, 5 archivos corregidos):** el usuario reabrió Blender ("ya tenes abierto blender nuevamente segui"). Re-corrí `verificar_visual.py` corregido en `roca_comun_lowpoly` y `roca_pedernal_lowpoly` source — ambos pasan `z_min 0.0450 → apoyo OK` (antes: HUNDIDO 0.154 m / HUNDIDO 0.337 m). Leí las 6 hojas de contacto (04-04 a 04-06) y confirmé visualmente el fix E-50: roca_comun y roca_pedernal apoyados en los 6 azimuts. **Barrido E-24 en `scripts-reutilizables/`** (17 hits en 11 archivos): **5 archivos corregidos**, 6 SAFE. Críticos: `verificar_visual.py:medir_apoyo()` (el bug original), `asentar_en_base.py:PLANTILLA` (sobre-eleva grupo 15 cm si fuente tiene un rotado), `auditar_apoyos.py:TEMPLATE` (reporta FLOTA falsamente en rotados), `corregir_asset.py:zmin_de()` (5 sitios, el delta de re-asentado). Cosméticos: `auditar_presupuesto.py:52-53` (display), `verificar_bounds.py:21-22` (engañoso, se lee como `z_min` real). SAFE: `capturar_angulos.py`, `diagnosticar_pose.py`, `inspeccionar_escena.py` (framing/display), `auditar_flotantes.py:93` y `generar_variante.py:380` (fallback empty-mesh con docstring E-24). **Sanity check roca_comun_lowpoly:** `SM_Roca_Comun_Chica` rot=(0.2,-0.2,1.1) → `real_zmin=0.0450` vs `bbox_zmin=-0.1092` (delta 15.4 cm). Confirmado que el bug era real y que el fix lo cierra. Patrón obligatorio para scripts nuevos: NUNCA `o.bound_box` para decidir re-asentado; usar `zmin_real(o)` con fallback AABB solo si `len(o.data.vertices) == 0`. **Pendiente:** QA visual ALTA (17 hero assets) — ahora seguro porque los scripts numéricos ya no mienten.
**Cambios 03:25 (fix E-50 en veta_hierro + veta_oro, doc E-47/48/49/50/51, log 301/302):** descubierto nuevo patrón "apoyo puntual en domo" (E-50): `z_min=0.0450` con `toca=1, footprint=0×0` significa que el objeto (usualmente un huso: punta r=0.025 abajo, punta r=0.05 arriba, ecuador r=1.2 a z=0.6) está apoyado sobre un vértice y el ecuador flota 50+ cm arriba del suelo. **Caso real:** `veta_hierro` — la roca gris-azulada estaba suspended en los 6 azimuts con sombra debajo que no tocaba la arena (visible incluso numéricamente OK: `SM_Veta_Roca` zmin=0.0450 pero ecuador a 0.36). **`piedra_afilar` fue falsa alarma E-31** (loseta con footprint 0.187×0.034, plana sobre la arena — mi juicio visual previo fue erróneo, corregido midiendo vértices reales con `diag_apoyo.py` — aprendizaje: E-37 también aplica al diagnóstico). **Fix correcto:** script `aplanar_dome.py` (BFS sobre aristas — E-51, no distancia XY, que elige vértices del techo) toma el vértice más bajo + K anillos topológicos y los aplana a `z=Z_OBJ`. K=2 funciona para husos de 42 verts (base hexagonal de ~2 m). Aplicado a `veta_hierro` (3 variantes) y `veta_oro` (3 variantes). NO aplicado a `veta_cobre`/`roca_comun`/`roca_pedernal` porque su flat-top ecuatorial disimula el single-vertex contact y pasan el E-13 visual. **Decisión arquitectural:** para vetas/rocas con flat-top ecuatorial (anillo de vértices al mismo z), la base sí es un punto pero el ojo lee el disco plano de arriba y aprueba — es E-50 latente pero aceptable. Documentado E-47 (fuente debe llamarse `N_lowpoly.blend`), E-48 (`generar_variante.py` re-asienta derivados → ALTA/MEDIA/BAJA GLBs pueden quedar a alturas distintas), E-49 (mtime-skip miente tras restores/clock-skew/git-pull → usar `EXPORT_FORZAR=1`), E-50 (apoyo puntual en domo), E-51 (vecindario por topología de aristas, no distancia XY). **6 GLBs re-exportadas** (alta/media/baja × veta_hierro + veta_oro) en `game/isla-ancestral/assets/3d/`. **Barrido visual BAJA completo**: 52/52 assets capturados (4 lotes, ~16 min totales, 0 fallos de pipeline, 0 excedidos de presupuesto). 51/52 aprobados visualmente; `veta_hierro_baja` era el único rechazo, ahora resuelto. **Pendiente próximo:** QA visual MEDIA (41 assets) y ALTA (17 assets) — mismo flujo `qa_lote.py --variante media|alta`.

**Cambios 03:55 (barrido MEDIA completo, fix E-50 roca_comun/roca_pedernal, doc E-52/53/54, log 303):** **Barrido visual MEDIA: 52/52 assets, 0 fallos, 14.4 min** (4 lotes paralelos por socket único). Todos pasan `z_min 0.0450 → OK` numérico. **`diag_apoyo.py` reveló 3 E-50 reales** que mi juicio en log 301 había descartado: `roca_comun` SM_Roca_M_Roca (toca=2, fp=1.29×0.67 — apoyo en línea, no área), `roca_pedernal` SM_Roca_M_Pedernal + _C (toca=1, fp=0×0). El log 301 los había declarado "E-50 latente pero aceptable" por analogía con `veta_cobre` (que SÍ es un disco plano). Mirando las capturas orbitales, `roca_comun` es un bolón irregular con cuerpo arriba — **flota visualmente**. E-52 (nuevo): la captura ES la fuente de verdad, no el z_min numérico. Lección E-37 se extiende al DIAGNOSTICO. **Fix aplicado:** `aplanar_dome.py` K=2 a roca_comun (3 variantes, fp ahora 1.8-2.5m × 1.0-1.8m, toca 12-16) y roca_pedernal (3 variantes, fp 0.8-1.1m, toca 11-18). Para roca_pedernal, el socket murió a 03:53 — usé **modo CLI headless** (Blender -b --factory-startup --python-expr) inlineando la lógica de `aplanar_dome.py`. **E-53 (nuevo):** los nombres de objeto DIFEREN entre source y variantes — roca_pedernal source usa `SM_Roca_Pedernal` (sin `_M_`), media/baja usan `SM_Roca_M_Pedernal`. Scripts por patrón fallan. Solución: iterar sobre todos los SM_ y filtrar por sub-cadena. **E-54 (nuevo):** el modo headless de `aplanar_dome` es válido para fixes urgentes sin socket. **Re-export 15-Recursos:** 30 GLBs OK (primera pasada), 29 + 1 error transient (segunda pasada, resuelto en aislado). `auditar_desincronizados.py`: 69 auditados, **0 desincronizadas**, exit 0. **6 GLBs modificados** (mtime 03:55) en `assets/3d/{alta,media,baja}/15-Recursos_roca_{comun,pedernal}.glb`. **Scripts promovidos** (sin sufijo `_tmp`): `diag_apoyo.py`, `aplanar_dome.py`, `dump_anillos.py`, `dump_glb.py`. **Capturas de verificación visual de roca_comun/roca_pedernal: PENDIENTES** (socket muerto). Al reabrir Blender, `qa_lote.py 15-Recursos` × 3 variantes. **E-50 latentes aceptados (no se corrigen):** `veta_cobre`, `hongo_luminoso` SM_Piedra_M_Piedra_Cueva, `monolito_glifos` SM_Monolito_M_Piedra_Monolito — la silueta del objeto oculta el apoyo puntual visualmente. **Pendiente próximo:** verificación visual roca_comun/roca_pedernal (cuando Blender abierto) + barrido ALTA.
**Cambios 00:15 (cierre de pendientes M166 — presupuesto + pipeline Godot, logs 251/252):** se sanearon las **23 variantes que excedían el presupuesto M166** (quedaron en **0 excedidos**, 121 variantes auditadas). Causa de fondo: **E-40** `generar_alta.py` medía CARAS, no TRIS (`totem_isla_alta` reportaba "OK" con 10.507 caras = 21.014 tris contra techo 6.000). El sobre-teselado venía de BEVEL `--segmentos 3 --subdiv` sobre esferas UV (768 tris c/u); el totem tenía 27 piezas a 768. Fijados seg2 (totem 3.106) y seg1 (cofre 3.274). 15 MEDIA regeneradas con `--decima-media --ratio 0.29→0.88` (1.306–1.446 tris); 9 BAJA con `--ratio 0.28→0.70` (<700 tris, 6 de ellas podadas 5-6→4 mats vía **E-41** respaldo de índices por NOMBRE y **E-42** conteo de materiales usados por caras). Se escribió `exportar_godot.py` (HEADLESS, **E-44** purga no-`SM_`, **E-45** `bpy.context` por socket no tiene `active_object` → el exportador glTF falla por socket, se corre `blender -b --factory-startup --python` con `addon_enable('io_scene_gltf2')` y opciones por env-var). Resultado: **153 GLB** (51 alta / 51 media / 51 baja), 7,7 MB, pirámide LOD correcta. Godot 4.7.2 `--headless --import` → **153/153 DONE**. Se descubrió la **desincronización de variantes** (derivado más viejo que su fuente): `palanca_madera_alta` (v2 rechazada, 14:13) vs su `_lowpoly` v3 (22:54) — resuelta con **E-43** prioridad explícita de sufijos. Cross-check mtime final: **0 desincronizados**. M70 cerrado 5/5 (botón de piso, puerta corrediza, cofre pequeño, válvula con volante+manivela) y documentado. Contadores: 47 completados / 80 aprobados visualmente / 0 pendientes / 121 variantes en presupuesto / pipeline Godot vivo.
**Cambios 23:05 (rediseño de la palanca M70, log 248):** el usuario reportó "aca estoy viendo una imagen de la palanca de madera en blender que esta mal, eso esta corregido? no le encuentro la forma". El bug era de fondo (v1 tenía brazo cilindro y cono del pivote en el MISMO punto `(0,0,0.21)` → el brazo atravesaba el pivote); el "fix" del log 233 solo había rotado el .blend a mano de 35° a 81.1° y reposicionado el pomo — maquillar, no arreglar. v3 rediseño completo como **HORQUILLA** (base + 2 montantes + brazo inclinado 10° entre ellos + perno de hierro transversal que sobresale 2 cm + pomo icosaedro en la punta). Todo un solo bmesh, 1 obj, 3 mats, 96 tris. Aprobado visualmente (E-13 OK, 6 capturas orbitales 23-05-00). Tres lecciones nuevas: **E-37** "un fix cosmético no es un fix; bug de diseño sigue siendo bug aunque el render se vea distinto" (preguntarse "¿se lee como X?", no solo "¿z_min ≈ 0.045?"), **E-38** "en mallas inclinadas la CAÍDA VERTICAL es `semialto · cos(θ)`, no `semialto`" (medido: diff 1.1 mm en el assert del brazo sobre pivote), **E-39** "para choques esfera-caja, distancia punto-AABB + radio, nunca comparar componentes individuales en serie" (el pomo a 0.49 m en X de la horquilla dio falso positivo al comparar solo Z). Checklist: palanca marcada `[x]` con la entrada detallada. Tier D sigue cerrado 7/7. Contadores: 47 completados / 80 aprobados visualmente / 0 pendientes.
**Cambios 23:11 (QA visual del módulo 13 + orquestador):** E-10 quedó destrabado. El usuario
abrió y cerró Blender, el socket 9876 volvió, y `Read` volvió a leer PNGs. Se hizo el primer
barrido real de las BAJA del módulo 13 con el nuevo `verificar_visual.py` (encadena abrir
blend → stats → z_min → 6 capturas → contact sheet). Resultado: 3/3 aprobadas en el primer
pase (antorcha 4/77, pico_piedra 3/74, pico_hierro 3/83 — todos z_min 0.045, sin flotación,
sin roturas de decimate). Lección descubierta: para assets tan chicos (~80 tris, 3 piezas)
el pipeline M166 **no tiene con qué trabajar**: la BAJA queda bit-perfect contra la MEDIA
porque no hay poda posible (1e-4 m³) y el decimate 0.7 sobre mallas de 30 tris no cambia
nada. Eso es correcto y esperado: el módulo preserva lo que no puede reducir sin perder la
silueta. La BAJA existe como contrato (R9 + CI) aunque visualmente sea idéntica a la MEDIA.
**Refactor mínimo** en `stats_asset.py` (expuso `medir(prefijo) -> dict`) y `contact_sheet.py`
(expuso `hoja(pngs, out) -> str`); las firmas `main()` quedan intactas. Log 275.
**Importante para los assets siguientes:** las herramientas del módulo 13 son demasiado
chicas para la pasada ALTA (techo ~250 tris, lejos del presupuesto 6.000). La primera ALTA
tiene que ser un asset con más cuerpo — `cofre_ancestral` o `monolito_glifos` son los candidatos.
**Cambios 22:00 (lote completo de optimización — M166 operativo en todo el catálogo):** se procesaron los **41 assets** del proyecto: `python procesar_lote.py` → **40 exitosos / 0 fallidos / 168.0 s**. Antes había 1 optimizado (el cofre, piloto); ahora **41/41 con MEDIA y BAJA** y `auditar_optimizacion.py` devuelve exit 0. Scripts nuevos: `auditar_optimizacion.py` (filesystem, no necesita Blender, `--falta` y exit 1 si falta mergear) y `procesar_lote.py` (idempotente, por módulo y por variante). Ajuste: `CRITICAS_NO_FUNDIR` queda **vacío por defecto** — el merge es lossless y con decimate 0.7 las piezas finas sobreviven, así que excluirlas costaba 8 draw calls a cambio de nada (medido: 14 obj con críticas excluidas vs 6 obj con la lista vacía). **El re-asentado E-12 en cascada destapó bases mal calibradas que nunca se habían medido**: `palanca_madera` z_min −0.396→0.045 (delta +0.441), `palmera` −0.300→0.045 (+0.345), `hongo_luminoso` −0.064→0.045 (+0.109). Draw calls: `liana_colgante` 19→4, `palmera` 13→5, `palmera_inclinada` 11→4, `palmera_joven` 8→3. **Decisión D8**: carpetas donde se consume (Godot `alta/ media/ baja/`), sufijos donde se edita (Blender plano con `_alta/_media/_baja`), para que ALTA y MEDIA no diverjan (R7). Log 274.
**Cambios 22:50 (primer QA visual M166 — módulo 13-Herramientas, visión destrabada):** se destrabó E-10 al re-abrir Blender y se corrió el circuito completo sobre `13-Herramientas`: `qa_variantes.py 13-Herramientas --angulos 6` → 6 variantes / 0 fallos / 36 PNGs orbitales / 2 min 17 s, + 6 contact sheets con `contact_sheet.py`. Las 3 herramientas (`antorcha_mano`, `pico_hierro`, `pico_piedra`) tienen MEDIA y BAJA **bit-perfect** o casi: 3 obj / 74-83 tris / 3 mats, dentro del presupuesto M166 con margen. **Lección:** para assets tan simples el pipeline M166 no tiene con qué trabajar (la poda no encuentra piezas bajo el umbral y el decimate 0.7 sobre mallas de ~30 tris no reduce). Es correcto y esperado — el módulo preserva lo que no se puede reducir. Las reducciones reales del módulo (cofre 33→6, palanca 5→3, hongo 9→5) son sobre assets más grandes. Implicación para la pasada ALTA: los 3 del 13 tienen techo bajo (~80→~250 tris) y conviene arrancar la ALTA por `cofre_ancestral` o `monolito_glifos`. Log 275.

**Cambios de la sesión de mejora del cofre (20:20–20:30):** descubierto que **Eevee Next sin SSR muestra materiales metálicos/coat planos** — diagnosticado en `scripts-reutilizables/_diag_eevee.py` (borrado tras verificar). Para que un material con metallic 0.85 + coat 1.0 se vea brillante en el set de captura, **activar `eevee.use_ssr = True`, `eevee.use_ssr_refraction = True`, `eevee.use_raytracing = True` ANTES de `bpy.ops.render.render()`**. La activación puede vivir en el script de captura (no en el del asset) para no contaminar el .blend. Con SSR activo, los highlights de oro/bronce son nítidos incluso con un set de luces plano (SOL 3.4 + mundo 0.55). Lección general: **sin HDRI, la única forma de que metallic+coat se vean pulidos es vía SSR + emisión suave en el color del metal** (oro emis 0.6–0.8, bronce 0.4). El cofre pasó de 25 objetos opacos a 33 piezas con 7 materiales brillantes (madera barnizada, hierro pulido, bronce pulido, oro con emis, gema cyan emis 4.5).
