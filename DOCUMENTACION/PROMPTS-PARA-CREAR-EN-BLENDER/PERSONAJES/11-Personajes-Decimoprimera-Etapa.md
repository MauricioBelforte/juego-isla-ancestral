# Me decante por la Opcion 2

Seguimos con **E → A → B**. Primero: **láminas de contacto por isla**, para ver juntos a los NPCs y detectar diferencias de escala, siluetas demasiado parecidas y accesorios fuera de lugar.

Esta entrega genera:

- **Una lámina PNG por isla**, con los personajes identificados por nombre.
- Una imagen individual por NPC.
- Un JSON con los archivos utilizados y sus dimensiones.
- Un HTML para navegar por las cuatro láminas.

**Todos se muestran con la misma escala de cámara**, incluso entre islas. Un guardia de 1,9 m se verá más alto que un anciano de 1,7 m; el script no los iguala artificialmente.

Para esta primera comparación usaremos los **ALTA originales**, porque la revisión artística de las últimas tres islas necesita el parche que haremos después.

---

# 1. Script `contact_sheets_npcs.py`

Es autónomo: no importa los generadores anteriores.

Guárdalo y ejecuta:

```bash
blender --background --factory-startup --python contact_sheets_npcs.py
```

> **Atención:** limpia la sesión de Blender para cargar cada personaje. Ejecútalo en una instancia dedicada, no sobre un trabajo sin guardar. No modifica los `.blend` originales.

```python
# ================================================================
# NPC COZY — LAMINAS DE CONTACTO POR ISLA
# Blender 4.2+
#
# Lee los ALTA originales, o REVISION_02 si se indica expresamente.
# Genera PNG individuales, PNG por isla, JSON y galeria HTML.
#
# No exporta meshes, no modifica los originales, no aplica Decimate.
# ATENCION: limpia la sesion de Blender.
# ================================================================

import bpy
import math
import json
import html
import traceback

from array import array
from pathlib import Path
from mathutils import Vector
from datetime import datetime


# ---------------- CONFIGURACION ----------------

BASE = Path.home() / "NPC_EXPORT"

USAR_REVISION_02 = False

# None = las cuatro islas.
# Ejemplo: {"RAIZ"}
SOLO_ISLAS = None

# Cada personaje ocupa una celda cuadrada.
# 512 px produce laminas de 2048 px de ancho.
TAM_CELDA = 512
COLUMNAS = 4

# Vista frontal tres cuartos.
AZIMUT_GRADOS = 30.0
ELEVACION_GRADOS = 12.0

# Separacion de la camara: no cambia el tamaño en ortografica.
DISTANCIA_CAMARA = 10.0

# Misma escala ortografica para todos.
# None = calcular una escala comun que encuadre todos los NPCs.
ESCALA_ORTOGRAFICA_FIJA = None

# Capturas y reportes de esta ejecucion.
MARCA = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
SALIDA = BASE / "APROBACION" / f"CONTACT_SHEETS_{MARCA}"

FONDO_LINEAL = (0.12, 0.105, 0.09, 1.0)

CATALOGO = {
    "RAIZ": {
        "carpeta": "01_RAIZ",
        "npcs": [
            ("01", "LUNA", "Luna"),
            ("02", "ROCKY", "Rocky"),
            ("03", "CORAL", "Coral"),
            ("04", "CHEF", "Chef"),
            ("05", "FIN", "Fin"),
            ("06", "FLORA", "Flora"),
            ("07", "SAGE", "Sage"),
            ("08", "MERC", "Merc"),
            ("09", "NANA", "Nana"),
            ("10", "CARP", "Carp"),
            ("11", "MELODIA", "Melodia"),
            ("12", "ROCA", "Roca"),
        ],
    },
    "CENIZA": {
        "carpeta": "02_CENIZA",
        "npcs": [
            ("13", "BRASA", "Brasa"),
            ("14", "OBSIDIANA", "Obsidiana"),
            ("15", "TUFA", "Tufa"),
            ("16", "HORNO", "Horno"),
            ("17", "CENIZA", "Ceniza"),
            ("18", "PEDRO", "Pedro"),
            ("19", "VULCANIA", "Vulcania"),
            ("20", "CHISPA", "Chispa"),
            ("21", "CALDERA", "Caldera"),
            ("22", "HUMO", "Humo"),
        ],
    },
    "CORAL": {
        "carpeta": "03_CORAL",
        "npcs": [
            ("23", "OLA", "Ola"),
            ("24", "PERLA", "Perla"),
            ("25", "CONCHA", "Concha"),
            ("26", "ALGA", "Alga"),
            ("27", "TIBURON", "Tiburon"),
            ("28", "ESTRELLA", "Estrella"),
            ("29", "NACAR", "Nacar"),
            ("30", "CORAL_ROSA", "Coral Rosa"),
        ],
    },
    "AURORA": {
        "carpeta": "04_AURORA",
        "npcs": [
            ("31", "HIELO", "Hielo"),
            ("32", "AURORA", "Aurora"),
            ("33", "NIEVE", "Nieve"),
            ("34", "GLACIAR", "Glaciar"),
            ("35", "ESTRELLA_FUGAZ", "Estrella Fugaz"),
        ],
    },
}


# ---------------- UTILIDADES ----------------

def guardar_json(ruta, datos):
    with open(ruta, "w", encoding="utf-8") as archivo:
        json.dump(datos, archivo, ensure_ascii=False, indent=2)


def limpiar_sesion():
    if bpy.context.object and bpy.context.object.mode != "OBJECT":
        bpy.ops.object.mode_set(mode="OBJECT")

    scene = bpy.context.scene
    scene.camera = None
    scene.world = None

    for obj in list(bpy.data.objects):
        bpy.data.objects.remove(obj, do_unlink=True)

    for col in list(bpy.data.collections):
        bpy.data.collections.remove(col)

    for grupo in (
        bpy.data.meshes,
        bpy.data.materials,
        bpy.data.cameras,
        bpy.data.lights,
        bpy.data.curves,
        bpy.data.worlds,
    ):
        for bloque in list(grupo):
            if bloque.users == 0:
                grupo.remove(bloque)

    scene.unit_settings.system = "METRIC"
    scene.unit_settings.scale_length = 1.0
    scene.frame_set(1)


def ruta_npc(carpeta_isla, identificador, nombre):
    carpeta = BASE / carpeta_isla / f"{identificador}_{nombre}"

    if USAR_REVISION_02:
        carpeta = carpeta / "REVISION_02"

    return carpeta / f"SM_NPC_{nombre}.blend"


def cargar_npc(ruta, nombre):
    limpiar_sesion()

    if not ruta.exists():
        raise FileNotFoundError(str(ruta))

    prefijo = f"SM_NPC_{nombre}"

    with bpy.data.libraries.load(str(ruta), link=False) as (src, dst):
        dst.objects = [
            n for n in src.objects
            if n == prefijo or n.startswith(prefijo + "_")
        ]

    col = bpy.data.collections.new("COL_CONTACT_NPC")
    bpy.context.scene.collection.children.link(col)

    objetos = [obj for obj in dst.objects if obj is not None]

    for obj in objetos:
        col.objects.link(obj)
        obj.hide_render = False
        obj.hide_viewport = False
        obj.hide_set(False)

    meshes = [obj for obj in objetos if obj.type == "MESH"]

    if not meshes:
        raise RuntimeError("El archivo no contiene los meshes esperados.")

    # Estas laminas comparan estaticos, no poses de rigs.
    if any(obj.type == "ARMATURE" for obj in objetos):
        raise RuntimeError(
            "Se encontro un rig. Selecciona el ALTA estatico."
        )

    if any(
        mod.type == "ARMATURE"
        for obj in meshes
        for mod in obj.modifiers
    ):
        raise RuntimeError("Se encontro un modificador Armature.")

    bpy.context.view_layer.update()
    return meshes


def puntos_evaluados(meshes):
    depsgraph = bpy.context.evaluated_depsgraph_get()
    resultado = []

    for obj in meshes:
        evaluado = obj.evaluated_get(depsgraph)
        me = evaluado.to_mesh()

        try:
            resultado.extend(
                evaluado.matrix_world @ v.co for v in me.vertices
            )
        finally:
            evaluado.to_mesh_clear()

    if not resultado:
        raise RuntimeError("No hay vertices para medir.")

    return resultado


def dimensiones(puntos):
    minimo = Vector(tuple(
        min(p[i] for p in puntos) for i in range(3)
    ))
    maximo = Vector(tuple(
        max(p[i] for p in puntos) for i in range(3)
    ))
    return minimo, maximo


def orientacion_camara():
    az = math.radians(AZIMUT_GRADOS)
    el = math.radians(ELEVACION_GRADOS)

    radial = Vector((
        math.sin(az) * math.cos(el),
        math.cos(az) * math.cos(el),
        math.sin(el),
    ))

    rotacion = (-radial).to_track_quat("-Z", "Y")
    return radial, rotacion


RADIAL, ROTACION = orientacion_camara()
INV_ROTACION = ROTACION.inverted()


# ---------------- ESCENA DE RENDER ----------------

def orientar(obj, objetivo):
    obj.rotation_euler = (
        Vector(objetivo) - obj.location
    ).to_track_quat("-Z", "Y").to_euler()


def material_texto():
    mat = bpy.data.materials.new("MAT_CONTACT_TEXTO")
    mat.use_nodes = True

    nt = mat.node_tree
    nt.nodes.clear()

    emission = nt.nodes.new("ShaderNodeEmission")
    emission.inputs["Color"].default_value = (
        0.85, 0.78, 0.66, 1.0
    )
    emission.inputs["Strength"].default_value = 1.0

    salida = nt.nodes.new("ShaderNodeOutputMaterial")
    nt.links.new(emission.outputs[0], salida.inputs["Surface"])

    return mat


def preparar_render(escala, objetivo, etiqueta):
    scene = bpy.context.scene

    col = bpy.data.collections.new("COL_CONTACT_PREVIEW")
    scene.collection.children.link(col)

    for nombre, posicion, energia, tamano in [
        ("KEY",  (3.0, 4.0, 4.2), 450, 4.0),
        ("FILL", (-3.0, 1.5, 2.7), 250, 3.5),
        ("RIM",  (0.0, -3.0, 3.3), 400, 3.0),
    ]:
        data = bpy.data.lights.new(nombre, "AREA")
        data.energy = energia
        data.size = tamano

        obj = bpy.data.objects.new(nombre, data)
        col.objects.link(obj)
        obj.location = posicion
        orientar(obj, (0, 0, 0.95))

    world = bpy.data.worlds.new("WORLD_CONTACT")
    world.use_nodes = True
    fondo = world.node_tree.nodes.get("Background")
    fondo.inputs["Color"].default_value = FONDO_LINEAL
    fondo.inputs["Strength"].default_value = 0.5
    scene.world = world

    data = bpy.data.cameras.new("CAM_CONTACT")
    cam = bpy.data.objects.new("CAM_CONTACT", data)
    col.objects.link(cam)

    cam.location = objetivo + RADIAL * DISTANCIA_CAMARA
    cam.rotation_mode = "QUATERNION"
    cam.rotation_quaternion = ROTACION
    data.type = "ORTHO"
    data.ortho_scale = escala
    data.clip_start = 0.01
    data.clip_end = 100.0
    scene.camera = cam

    # Etiqueta en el plano de la camara.
    # No afecta al encuadre del personaje.
    texto_data = bpy.data.curves.new("LABEL_CONTACT", "FONT")
    texto_data.body = etiqueta
    texto_data.align_x = "CENTER"
    texto_data.size = escala * 0.029
    texto_data.extrude = 0

    texto = bpy.data.objects.new("LABEL_CONTACT", texto_data)
    col.objects.link(texto)

    texto.rotation_mode = "QUATERNION"
    texto.rotation_quaternion = ROTACION
    texto.location = cam.location + ROTACION @ Vector((
        0, -escala * 0.455, -1.0
    ))
    texto.data.materials.append(material_texto())

    scene.render.engine = "BLENDER_EEVEE_NEXT"
    scene.render.resolution_x = TAM_CELDA
    scene.render.resolution_y = TAM_CELDA
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"
    scene.render.film_transparent = False
    scene.render.use_border = False
    scene.render.use_compositing = False
    scene.render.use_sequencer = False

    scene.view_settings.view_transform = "AgX"
    scene.view_settings.exposure = 0.0
    scene.view_settings.gamma = 1.0


# ---------------- ENSAMBLAR LAMINA ----------------

def crear_lamina(rutas, destino):
    filas = math.ceil(len(rutas) / COLUMNAS)
    ancho = COLUMNAS * TAM_CELDA
    alto = filas * TAM_CELDA

    # Fondo neutro para celdas vacias.
    pixeles = array("f", [0.055, 0.048, 0.042, 1.0]) * (ancho * alto)

    for indice, ruta in enumerate(rutas):
        if ruta is None:
            continue

        imagen = bpy.data.images.load(str(ruta), check_existing=False)

        try:
            if tuple(imagen.size) != (TAM_CELDA, TAM_CELDA):
                raise RuntimeError(f"Resolucion inesperada: {ruta}")

            origen = array("f", [0.0]) * (TAM_CELDA * TAM_CELDA * 4)
            imagen.pixels.foreach_get(origen)

            columna = indice % COLUMNAS
            fila_desde_arriba = indice // COLUMNAS

            x0 = columna * TAM_CELDA
            y0 = alto - (fila_desde_arriba + 1) * TAM_CELDA

            for y in range(TAM_CELDA):
                inicio_origen = y * TAM_CELDA * 4
                inicio_destino = ((y0 + y) * ancho + x0) * 4
                cantidad = TAM_CELDA * 4

                pixeles[inicio_destino:inicio_destino + cantidad] = (
                    origen[inicio_origen:inicio_origen + cantidad]
                )
        finally:
            bpy.data.images.remove(imagen)

    lamina = bpy.data.images.new(
        name=destino.stem,
        width=ancho,
        height=alto,
        alpha=True,
        float_buffer=True,
    )

    try:
        # Los PNG ya tienen aplicado AgX.
        # Guardar como imagen, no volver a pasar por save_render().
        lamina.colorspace_settings.name = "sRGB"
        lamina.pixels.foreach_set(pixeles)
        lamina.update()
        lamina.filepath_raw = str(destino)
        lamina.file_format = "PNG"
        lamina.save()
    finally:
        bpy.data.images.remove(lamina)


# ---------------- PRIMERA PASADA: MEDIR ----------------

SALIDA.mkdir(parents=True, exist_ok=True)
(SALIDA / "INDIVIDUALES").mkdir(exist_ok=True)

registro = {
    "fecha": MARCA,
    "blender": bpy.app.version_string,
    "fuente": "REVISION_02" if USAR_REVISION_02 else "ALTA_ORIGINAL",
    "escala_comun": True,
    "azimut_grados": AZIMUT_GRADOS,
    "elevacion_grados": ELEVACION_GRADOS,
    "npc": [],
    "laminas": [],
    "errores": [],
    "aprobacion_visual": "PENDIENTE",
}

entradas = []
xs = []
ys = []

for isla, datos in CATALOGO.items():
    if SOLO_ISLAS is not None and isla not in SOLO_ISLAS:
        continue

    for identificador, nombre, etiqueta in datos["npcs"]:
        ruta = ruta_npc(datos["carpeta"], identificador, nombre)

        entrada = {
            "id": identificador,
            "nombre": nombre,
            "etiqueta": etiqueta,
            "isla": isla,
            "archivo": str(ruta),
            "estado": "PENDIENTE",
        }
        entradas.append(entrada)

        try:
            meshes = cargar_npc(ruta, nombre)
            puntos = puntos_evaluados(meshes)
            minimo, maximo = dimensiones(puntos)

            # Proyeccion en los ejes de la camara.
            # Todos los NPCs se comparan en el mismo sistema.
            proyectados = [INV_ROTACION @ p for p in puntos]
            xs.extend(p.x for p in proyectados)
            ys.extend(p.y for p in proyectados)

            entrada["dimensiones_con_accesorios_m"] = list(maximo - minimo)
            entrada["z_minimo_m"] = minimo.z
            entrada["meshes"] = len(meshes)
            entrada["estado"] = "MEDIDO"

        except Exception as error:
            entrada["estado"] = "ERROR"
            entrada["error"] = str(error)
            registro["errores"].append({
                "npc": nombre,
                "fase": "MEDICION",
                "error": str(error),
            })

if not xs or not ys:
    guardar_json(SALIDA / "CONTACT_SHEETS.json", registro)
    raise RuntimeError("No se pudo medir ningun NPC.")


# ---------------- ENCUADRE GLOBAL ----------------

xmin, xmax = min(xs), max(xs)
ymin, ymax = min(ys), max(ys)

centro_x = (xmin + xmax) * 0.5
centro_y = (ymin + ymax) * 0.5

extension_x = xmax - xmin
extension_y = ymax - ymin

# Dejar espacio lateral, superior y para las etiquetas.
escala_necesaria = max(extension_x / 0.88, extension_y / 0.72, 2.4)

escala = (
    ESCALA_ORTOGRAFICA_FIJA
    if ESCALA_ORTOGRAFICA_FIJA is not None
    else escala_necesaria
)

if escala < escala_necesaria:
    registro["errores"].append({
        "fase": "ENCUADRE",
        "error": (
            "La escala fija es menor que la necesaria; "
            "algun personaje puede quedar recortado."
        ),
    })

# Subir visualmente al personaje para reservar el pie de etiqueta.
centro_y -= escala * 0.055

OBJETIVO_COMUN = ROTACION @ Vector((centro_x, centro_y, 0.0))

registro["escala_ortografica_m"] = escala
registro["objetivo_comun"] = list(OBJETIVO_COMUN)


# ---------------- SEGUNDA PASADA: RENDER ----------------

for entrada in entradas:
    nombre = entrada["nombre"]
    identificador = entrada["id"]
    isla = entrada["isla"]

    destino = (
        SALIDA / "INDIVIDUALES"
        / f"{identificador}_{nombre}.png"
    )

    try:
        if entrada["estado"] == "MEDIDO":
            cargar_npc(Path(entrada["archivo"]), nombre)
            etiqueta = f"{identificador}  {entrada['etiqueta']}"
        else:
            limpiar_sesion()
            etiqueta = f"{identificador}  {entrada['etiqueta']} — SIN ARCHIVO"

        preparar_render(escala, OBJETIVO_COMUN, etiqueta)
        bpy.context.scene.render.filepath = str(destino)
        bpy.ops.render.render(write_still=True)

        entrada["imagen"] = str(destino)
        if entrada["estado"] == "MEDIDO":
            entrada["estado"] = "RENDERIZADO"

    except Exception as error:
        traceback.print_exc()
        entrada["imagen"] = None
        registro["errores"].append({
            "npc": nombre,
            "fase": "RENDER",
            "error": str(error),
        })

    registro["npc"].append(entrada)
    guardar_json(SALIDA / "CONTACT_SHEETS.json", registro)


# ---------------- LAMINAS POR ISLA ----------------

for isla in CATALOGO:
    personajes = [e for e in entradas if e["isla"] == isla]
    if not personajes:
        continue

    rutas = [
        Path(e["imagen"]) if e.get("imagen") else None
        for e in personajes
    ]

    destino = SALIDA / f"CONTACT_{isla}.png"

    try:
        crear_lamina(rutas, destino)
        registro["laminas"].append({
            "isla": isla,
            "archivo": str(destino),
            "personajes": len(personajes),
            "columnas": COLUMNAS,
        })
    except Exception as error:
        registro["errores"].append({
            "isla": isla,
            "fase": "MONTAJE",
            "error": str(error),
        })


# ---------------- GALERIA HTML ----------------

secciones = []

for lamina in registro["laminas"]:
    archivo = Path(lamina["archivo"]).name
    isla = html.escape(lamina["isla"])

    secciones.append(f"""
    <section>
      <h2>Isla {isla}</h2>
      <a href="{html.escape(archivo)}">
        <img src="{html.escape(archivo)}" alt="NPCs de {isla}">
      </a>
    </section>
    """)

tabla = []

for entrada in entradas:
    dims = entrada.get("dimensiones_con_accesorios_m")
    medida = (
        " × ".join(f"{v:.3f}" for v in dims) + " m"
        if dims else "—"
    )
    imagen = entrada.get("imagen")
    enlace = (
        f'<a href="INDIVIDUALES/{html.escape(Path(imagen).name)}">Ver</a>'
        if imagen else "—"
    )

    tabla.append(
        "<tr>"
        f"<td>{html.escape(entrada['id'])}</td>"
        f"<td>{html.escape(entrada['etiqueta'])}</td>"
        f"<td>{html.escape(entrada['isla'])}</td>"
        f"<td>{html.escape(medida)}</td>"
        f"<td>{html.escape(entrada['estado'])}</td>"
        f"<td>{enlace}</td>"
        "</tr>"
    )

pagina = f"""<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<title>NPCs — revisión de siluetas</title>
<style>
body {{
  background:#292521; color:#eee5d7;
  font-family:system-ui,sans-serif;
  max-width:1500px; margin:32px auto; padding:0 20px;
}}
img {{ width:100%; height:auto; border:1px solid #665c50; }}
section {{ margin:36px 0; }}
table {{ width:100%; border-collapse:collapse; }}
td,th {{ text-align:left; border-bottom:1px solid #665c50; padding:9px; }}
a {{ color:#d6b781; }}
.note {{ color:#c9bdaa; }}
</style>
</head>
<body>
<h1>Catálogo NPC — láminas de contacto</h1>
<p>Fuente: {html.escape(registro["fuente"])}.
Escala ortográfica común: {escala:.3f} m.</p>
<p class="note">
Las dimensiones incluyen sombreros y herramientas.
RENDERIZADO no significa aprobado.
</p>
{''.join(secciones)}
<h2>Archivos individuales</h2>
<table>
<tr>
<th>ID</th><th>NPC</th><th>Isla</th>
<th>Dimensiones X × Y × Z</th><th>Estado</th><th>Imagen</th>
</tr>
{''.join(tabla)}
</table>
</body>
</html>
"""

(SALIDA / "index.html").write_text(pagina, encoding="utf-8")
guardar_json(SALIDA / "CONTACT_SHEETS.json", registro)

print("\n========== CONTACT SHEETS ==========")
print("Salida:", SALIDA)
print("Laminas:", len(registro["laminas"]))
print("Errores:", len(registro["errores"]))
print("Abrir:", SALIDA / "index.html")
```

---

# 2. Resultado

```text
NPC_EXPORT/
└── APROBACION/
    └── CONTACT_SHEETS_<fecha>/
        ├── index.html
        ├── CONTACT_RAIZ.png
        ├── CONTACT_CENIZA.png
        ├── CONTACT_CORAL.png
        ├── CONTACT_AURORA.png
        ├── CONTACT_SHEETS.json
        └── INDIVIDUALES/
            ├── 01_LUNA.png
            ├── 02_ROCKY.png
            ├── ...
            └── 35_ESTRELLA_FUGAZ.png
```

El script reserva una celda para cada personaje. Si falta un archivo, no desplaza los demás: muestra una celda con su nombre y registra el error.

**La altura informada incluye accesorios.** Un sombrero puntiagudo o una caña pueden aumentar la caja envolvente sin que la anatomía humana esté mal escalada.

---

# 3. Cómo usar estas láminas

La primera revisión debe centrarse en cinco preguntas:

1. **¿Se reconoce la profesión sin leer el nombre?**
2. **¿Se distinguen los personajes que comparten ropa o sombrero?**
3. **¿La herramienta parece estar sostenida y no flotando?**
4. **¿Se mantiene una escala humana coherente entre islas?**
5. **¿La paleta sigue siendo cálida y natural al verlos juntos?**

Marca cada NPC con uno de estos estados:

| Estado | Significado |
|---|---|
| **APROBADO_BASE** | Silueta y proporciones válidas; admite detalle posterior |
| **AJUSTE_MENOR** | Color, accesorio pequeño o agarre |
| **AJUSTE_MAYOR** | Escala, herramienta mal colocada, prenda o cabeza problemática |
| **ERROR_GENERACION** | Archivo ausente, incompleto o fallo del script |

Esta lámina es una **comparación frontal 3/4**, no reemplaza las seis vistas orbitales ni demuestra ausencia de intersecciones.

## Orden que seguimos después

**E queda cubierto con este generador.**

El siguiente bloque será **A: sustituir la revisión artística defectuosa de Ceniza, Coral y Aurora**, corrigiendo:

- Coordenadas de accesorios relativas a la mano.
- Asignación de adornos al brazo correspondiente.
- Accesorios duplicados.
- Postura de ancianos según la ficha real.

Después pasamos a **B: `NPC_BASE.tscn`, navegación, estados Idle/Caminar/Hablar e interacción**, utilizando la versión visual elegida de cada personaje.