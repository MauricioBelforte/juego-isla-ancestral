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
- [ ] **Auditoría de optimización**: correr `python auditar_optimizacion.py` y confirmar que el asset figura con `MEDIA = OK`. Si figura `FALTA`, no exportar todavía. Con `--falta` lista solo los pendientes; devuelve **exit 1** si falta alguno (apto para CI).
- [ ] **Optimización por lote** (cuando hay varios assets pendientes): `python procesar_lote.py` procesa todos los módulos; `python procesar_lote.py 50-Vegetacion --media` restringe a un módulo y a una sola variante. Es **idempotente**: saltea los assets que ya tienen `_media`. Referencia: 41 assets en 168 s.
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

---

**Última actualización:** 2026-08-28 23:11 — MiniMax-M3 · WorkBuddy AI · Windows
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
(expuso `hoja(pngs, out) -> str`); las firmas `main()` quedan intactas. Log 227.
**Importante para los assets siguientes:** las herramientas del módulo 13 son demasiado
chicas para la pasada ALTA (techo ~250 tris, lejos del presupuesto 6.000). La primera ALTA
tiene que ser un asset con más cuerpo — `cofre_ancestral` o `monolito_glifos` son los candidatos.
**Cambios 22:00 (lote completo de optimización — M166 operativo en todo el catálogo):** se procesaron los **41 assets** del proyecto: `python procesar_lote.py` → **40 exitosos / 0 fallidos / 168.0 s**. Antes había 1 optimizado (el cofre, piloto); ahora **41/41 con MEDIA y BAJA** y `auditar_optimizacion.py` devuelve exit 0. Scripts nuevos: `auditar_optimizacion.py` (filesystem, no necesita Blender, `--falta` y exit 1 si falta mergear) y `procesar_lote.py` (idempotente, por módulo y por variante). Ajuste: `CRITICAS_NO_FUNDIR` queda **vacío por defecto** — el merge es lossless y con decimate 0.7 las piezas finas sobreviven, así que excluirlas costaba 8 draw calls a cambio de nada (medido: 14 obj con críticas excluidas vs 6 obj con la lista vacía). **El re-asentado E-12 en cascada destapó bases mal calibradas que nunca se habían medido**: `palanca_madera` z_min −0.396→0.045 (delta +0.441), `palmera` −0.300→0.045 (+0.345), `hongo_luminoso` −0.064→0.045 (+0.109). Draw calls: `liana_colgante` 19→4, `palmera` 13→5, `palmera_inclinada` 11→4, `palmera_joven` 8→3. **Decisión D8**: carpetas donde se consume (Godot `alta/ media/ baja/`), sufijos donde se edita (Blender plano con `_alta/_media/_baja`), para que ALTA y MEDIA no diverjan (R7). Log 226.
**Cambios 22:50 (primer QA visual M166 — módulo 13-Herramientas, visión destrabada):** se destrabó E-10 al re-abrir Blender y se corrió el circuito completo sobre `13-Herramientas`: `qa_variantes.py 13-Herramientas --angulos 6` → 6 variantes / 0 fallos / 36 PNGs orbitales / 2 min 17 s, + 6 contact sheets con `contact_sheet.py`. Las 3 herramientas (`antorcha_mano`, `pico_hierro`, `pico_piedra`) tienen MEDIA y BAJA **bit-perfect** o casi: 3 obj / 74-83 tris / 3 mats, dentro del presupuesto M166 con margen. **Lección:** para assets tan simples el pipeline M166 no tiene con qué trabajar (la poda no encuentra piezas bajo el umbral y el decimate 0.7 sobre mallas de ~30 tris no reduce). Es correcto y esperado — el módulo preserva lo que no se puede reducir. Las reducciones reales del módulo (cofre 33→6, palanca 5→3, hongo 9→5) son sobre assets más grandes. Implicación para la pasada ALTA: los 3 del 13 tienen techo bajo (~80→~250 tris) y conviene arrancar la ALTA por `cofre_ancestral` o `monolito_glifos`. Log 227.

**Cambios de la sesión de mejora del cofre (20:20–20:30):** descubierto que **Eevee Next sin SSR muestra materiales metálicos/coat planos** — diagnosticado en `scripts-reutilizables/_diag_eevee.py` (borrado tras verificar). Para que un material con metallic 0.85 + coat 1.0 se vea brillante en el set de captura, **activar `eevee.use_ssr = True`, `eevee.use_ssr_refraction = True`, `eevee.use_raytracing = True` ANTES de `bpy.ops.render.render()`**. La activación puede vivir en el script de captura (no en el del asset) para no contaminar el .blend. Con SSR activo, los highlights de oro/bronce son nítidos incluso con un set de luces plano (SOL 3.4 + mundo 0.55). Lección general: **sin HDRI, la única forma de que metallic+coat se vean pulidos es vía SSR + emisión suave en el color del metal** (oro emis 0.6–0.8, bronce 0.4). El cofre pasó de 25 objetos opacos a 33 piezas con 7 materiales brillantes (madera barnizada, hierro pulido, bronce pulido, oro con emis, gema cyan emis 4.5).
