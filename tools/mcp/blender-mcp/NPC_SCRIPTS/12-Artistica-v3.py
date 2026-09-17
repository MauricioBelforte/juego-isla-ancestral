import bpy
import math
import traceback

from pathlib import Path
from mathutils import Vector


# ---------------- CONFIGURACION ----------------

CARPETA_SCRIPT = (
    Path(__file__).resolve().parent
    if "__file__" in globals()
    else Path(bpy.path.abspath("//"))
)

SCRIPT_ANTERIOR = (
    CARPETA_SCRIPT / "05-Op2.py"
)

BASE_EXPORT = Path(r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\NPC_EXPORT")

GENERAR_CAPTURAS_V3 = True
RESOLUCION_V3 = 768

# None = los 23 NPCs.
# Ejemplo: {"OBSIDIANA", "CHISPA", "HIELO", "ESTRELLA_FUGAZ"}
SOLO_NOMBRES_V3 = None

MAX_TRIS = 6000


# ---------------- CARGAR SOLO UTILIDADES ----------------

if not SCRIPT_ANTERIOR.exists():
    raise FileNotFoundError(
        f"Falta el archivo requerido: {SCRIPT_ANTERIOR}"
    )

fuente = SCRIPT_ANTERIOR.read_text(encoding="utf-8")

m_decoracion = "# ---------------- DECORACION ----------------"
m_render = "# ---------------- RENDER Y EXPORT ----------------"
m_lote = "# ---------------- LOTE ----------------"

for marcador in (m_decoracion, m_render, m_lote):
    if marcador not in fuente:
        raise RuntimeError(
            "El script anterior no coincide con la version esperada."
        )

utilidades = fuente.split(m_decoracion, 1)[0]

# Corregir llamada con argumentos posicionales.
utilidades = utilidades.replace(
    'me.color_attributes.new("COLOR_0", "FLOAT_COLOR", "CORNER")',
    'me.color_attributes.new('
    'name="COLOR_0", type="FLOAT_COLOR", domain="CORNER")'
)

render_export = fuente.split(m_render, 1)[1].split(m_lote, 1)[0]

# Cambiar solo la etiqueta de capturas de esta revision.
render_export = render_export.replace(
    'f"cap_NPC_{nombre}_v2_',
    'f"cap_NPC_{nombre}_v3_'
)

NS = {
    "__name__": "utilidades_revision",
    "__file__": str(SCRIPT_ANTERIOR),
}

exec(compile(utilidades, str(SCRIPT_ANTERIOR), "exec"), NS)
exec(compile(render_export, "<render_revision_03>", "exec"), NS)

NS["BASE"] = BASE_EXPORT
NS["RESOLUCION"] = RESOLUCION_V3

Detalles = NS["Detalles"]
cargar = NS["cargar"]
buscar_material = NS["buscar_material"]
triangulos = NS["triangulos"]
materiales_usados = NS["materiales_usados"]
limites = NS["limites"]
guardar_json = NS["guardar_json"]
exportar_glb = NS["exportar_glb"]
renderizar = NS["renderizar"]

# Una etiqueta de color desconocida ahora detiene la ejecucion,
# en lugar de convertirse silenciosamente en gris.
color_original = NS["color_lineal"]

def color_estricto(nombre):
    if nombre not in NS["COLORES"]:
        raise ValueError(f"Color no definido: {nombre}")
    return color_original(nombre)

NS["color_lineal"] = color_estricto


# ---------------- CATALOGO ----------------

LOTES = [
    ("02_CENIZA", [
        "BRASA", "OBSIDIANA", "TUFA", "HORNO", "CENIZA",
        "PEDRO", "VULCANIA", "CHISPA", "CALDERA", "HUMO",
    ]),
    ("03_CORAL", [
        "OLA", "PERLA", "CONCHA", "ALGA",
        "TIBURON", "ESTRELLA", "NACAR", "CORAL_ROSA",
    ]),
    ("04_AURORA", [
        "HIELO", "AURORA", "NIEVE",
        "GLACIAR", "ESTRELLA_FUGAZ",
    ]),
]

ANCIANOS = {"OBSIDIANA", "ALGA", "HIELO", "NIEVE"}
GUARDIAS = {"CALDERA", "TIBURON"}


# ---------------- DECORACION CORREGIDA ----------------

def decorar_v3(nombre, partes, coleccion):
    mat_ropa = buscar_material(partes, "CAMISA")
    mat_duro = buscar_material(partes, "BOTAS")

    # El cráneo original alcanza Z=1.540 antes de hornear escala.
    # No se utiliza HAIR: puede contener sombreros altos.
    cabeza = partes["HEAD"]

    z_craneo = max(
        (cabeza.matrix_world @ v.co).z
        for v in cabeza.data.vertices
    )
    factor = z_craneo / 1.540

    ancho = (
        1.12 if nombre in GUARDIAS
        else 0.98 if nombre in ANCIANOS
        else 1.0
    )

    def transformar(p):
        # Replica exclusivamente la postura del generador ALTA.
        p = p.copy()

        if nombre in ANCIANOS:
            t = max(0.0, min(1.0, (p.z - 0.85) / 0.65))
            p.y += 0.040 * t * t

        return p * factor

    detalles = {
        parte: Detalles(obj, transformar)
        for parte, obj in partes.items()
    }

    body = detalles["BODY"]
    head = detalles["HEAD"]

    registro = []

    def anotar(texto):
        registro.append(texto)

    def mano(lado):
        signo = -1 if lado == "L" else 1
        return Vector((
            signo * 0.210 * ancho,
            0.129,
            0.900,
        ))

    def pulsera(lado, tono="CUERO", radio=0.033):
        """
        Tubo cerrado alrededor de la muñeca.
        Cada pulsera pertenece a su propio brazo.
        """
        destino = detalles[f"ARM_{lado}"]
        centro = mano(lado) + Vector((0, -0.018, 0.018))

        eje = Vector((0, 0.52, -0.85)).normalized()
        u = Vector((1, 0, 0))
        v = eje.cross(u).normalized()

        puntos = [
            centro + radio * (
                u * math.cos(2 * math.pi * i / 12)
                + v * math.sin(2 * math.pi * i / 12)
            )
            for i in range(13)
        ]

        destino.tubo(
            puntos, [0.003] * len(puntos),
            mat_duro, tono, 6, cerrar=False
        )
        anotar(f"Pulsera {lado}: {tono}")

    def gema_mano(lado, tono):
        # Sugerencia de anillo sobre manopla, no dedos individuales.
        destino = detalles[f"ARM_{lado}"]
        centro = mano(lado) + Vector((0.012, 0.035, 0.010))

        destino.esfera(
            centro, (0.009, 0.004, 0.008),
            mat_duro, "ORO", 8, 4
        )
        destino.esfera(
            centro + Vector((0, 0.004, 0.002)),
            (0.005, 0.003, 0.005),
            mat_duro, tono, 6, 4
        )
        anotar(f"Anillo sugerido en mano {lado}")

    def cuentas_collar(tono, cantidad=7):
        # Completa la cuerda ya existente: no agrega otro collar.
        for i in range(cantidad):
            t = i / max(1, cantidad - 1)
            x = -0.041 + 0.082 * t
            z = 1.190 + 0.024 * (abs(2*t - 1) ** 1.4)

            body.esfera(
                (x, 0.126, z),
                (0.005, 0.004, 0.005),
                mat_duro, tono, 6, 4
            )
        anotar(f"Cuentas añadidas a collar existente: {tono}")

    def pendiente(lado, tono):
        signo = -1 if lado == "L" else 1
        head.esfera(
            (signo * 0.121, 0.003, 1.356),
            (0.007, 0.005, 0.010),
            mat_duro, tono, 8, 5
        )
        anotar(f"Pendiente {lado}")

    def hebilla():
        # Situada por delante del cinturon original.
        body.caja(
            (0, 0.123, 0.933),
            (0.037, 0.006, 0.025),
            mat_duro, "HIERRO"
        )
        body.caja(
            (0, 0.127, 0.933),
            (0.023, 0.003, 0.013),
            mat_duro, "CUERO"
        )
        anotar("Hebilla frontal")

    def parche(centro, ancho_parche, alto_parche, tono):
        # Superficie plana, no esfera sobresaliente.
        x, y, z = centro
        vertices = [
            (x-ancho_parche/2, y, z-alto_parche/2),
            (x+ancho_parche/2, y, z-alto_parche/2),
            (x+ancho_parche/2, y, z+alto_parche/2),
            (x-ancho_parche/2, y, z+alto_parche/2),
        ]
        body.agregar(
            vertices, [(0,1,2,3)], mat_ropa, tono
        )

    def silbato():
        body.caja(
            (0, 0.137, 1.180),
            (0.017, 0.018, 0.031),
            mat_duro, "PLATA"
        )
        body.caja(
            (0, 0.148, 1.186),
            (0.009, 0.005, 0.006),
            mat_duro, "CARBON"
        )
        anotar("Silbato sobre collar existente")

    def marca_runa(centro, escala=1.0):
        c = Vector(centro)
        puntos = [
            c + Vector((-0.006, 0, -0.009)) * escala,
            c + Vector((0, 0, 0.010)) * escala,
            c + Vector((0.006, 0, -0.009)) * escala,
        ]
        body.tubo(
            puntos, [0.0014 * escala] * 3,
            mat_duro, "ORO", 5
        )

    def broche():
        body.esfera(
            (0, 0.128, 1.221),
            (0.015, 0.006, 0.017),
            mat_duro, "PLATA", 8, 5
        )
        anotar("Broche plateado")

    def botones():
        for z in (1.125, 1.075, 1.025):
            body.esfera(
                (0.040, 0.132, z),
                (0.004, 0.003, 0.004),
                mat_duro, "PLATA", 6, 4
            )
        anotar("Botones de chaleco")

    # ---------------- CENIZA ----------------

    if nombre == "BRASA":
        hebilla()

        for sg in (-1, 1):
            brazo = detalles["ARM_L" if sg < 0 else "ARM_R"]
            # Mancha superficial en manga.
            brazo.esfera(
                (sg * 0.211, 0.054, 1.094),
                (0.014, 0.003, 0.017),
                mat_ropa, "CARBON", 8, 4
            )
        anotar("Manchas de carbon en mangas")
        # No duplica la linterna ni el casco de cinturon.

    elif nombre == "OBSIDIANA":
        # La mochila ya existe. Añadir solo pergaminos que asoman.
        for x, z in [(-0.060, 1.24), (0.035, 1.28)]:
            body.tubo(
                [(x, -0.177, 1.15), (x, -0.177, z)],
                [0.017, 0.017],
                mat_ropa, "CREMA", 8
            )
        anotar("Dos pergaminos sobre mochila existente")

        parche((-0.060, 0.110, 1.062), 0.047, 0.055, "GRIS")
        anotar("Remiendo frontal de tunica")

    elif nombre == "TUFA":
        # Los frascos y el bolsillo ya existen.
        pulsera("L", "HIERBA")
        for x in (-0.025, 0.005, 0.035):
            body.esfera(
                (x, 0.134, 1.035),
                (0.004, 0.003, 0.004),
                mat_ropa, "VERDE", 6, 4
            )
        anotar("Pequenas marcas botanicas en delantal")

    elif nombre == "HORNO":
        parche((0.052, 0.159, 0.755), 0.028, 0.017, "TIERRA")
        parche((-0.062, 0.170, 0.630), 0.022, 0.026, "NARANJA")
        anotar("Manchas planas de comida en delantal")

    elif nombre == "CENIZA":
        hebilla()
        pulsera("L")
        pulsera("R")
        # No incorpora placas de bota a coordenadas de guardia.

    elif nombre == "PEDRO":
        # Plano que asoma del bolsillo original.
        body.caja(
            (0.062, 0.180, 0.856),
            (0.052, 0.005, 0.059),
            mat_ropa, "CREMA"
        )
        for x in (0.049, 0.063, 0.076):
            body.tubo(
                [(x, 0.184, 0.843), (x, 0.184, 0.875)],
                [0.0009, 0.0009],
                mat_duro, "AZUL", 5
            )
        anotar("Plano plegado en bolsillo existente")
        hebilla()

    elif nombre == "VULCANIA":
        broche()
        botones()
        # No recrea el pergamino ni aplica encorvamiento inexistente.

    elif nombre == "CHISPA":
        for x in (-0.090, -0.045, 0, 0.045, 0.090):
            body.esfera(
                (x, 0.131, 0.925),
                (0.009, 0.003, 0.009),
                mat_duro, "ORO", 8, 4
            )
        anotar("Monedas de cinturon")

        pulsera("L", "COBRE")
        pulsera("R", "COBRE")
        gema_mano("R", "AMBAR")

    elif nombre == "CALDERA":
        silbato()
        hebilla()
        # Conserva la linterna ya existente.

    elif nombre == "HUMO":
        cuentas_collar("CARBON")
        pulsera("L", "CUERO")
        pulsera("R", "CUERO")
        # Sin conchas ni adornos de barba ajenos a su ficha.

    # ---------------- CORAL ----------------

    elif nombre == "OLA":
        cuentas_collar("BLANCO")
        pendiente("L", "CREMA")
        pendiente("R", "CREMA")
        pulsera("L", "ROSA")

    elif nombre == "PERLA":
        cuentas_collar("BLANCO")
        pulsera("L", "ORO")
        pulsera("R", "ORO")
        gema_mano("L", "BLANCO")
        # La joya en proceso de ARM_R permanece intacta.

    elif nombre == "CONCHA":
        cuentas_collar("CREMA")
        pulsera("L", "ROSA")

    elif nombre == "ALGA":
        cuentas_collar("CREMA")
        pulsera("L", "HIERBA")
        # No crea una segunda cesta: ya lleva una en ARM_L.

    elif nombre == "TIBURON":
        silbato()
        hebilla()

        # Llaves junto a la cadera, incorporadas a BODY.
        for x in (0.128, 0.143):
            body.tubo(
                [(x, 0.078, 0.915), (x, 0.078, 0.868)],
                [0.0025, 0.0025],
                mat_duro, "HIERRO", 6
            )
            body.caja(
                (x+0.004, 0.078, 0.870),
                (0.010, 0.005, 0.006),
                mat_duro, "HIERRO"
            )
        anotar("Dos llaves de cinturon")

    elif nombre == "ESTRELLA":
        for x in (-0.073, -0.025, 0.025, 0.073):
            marca_runa((x, 0.124, 0.938), 0.8)
        anotar("Runas decorativas de cinturon")
        gema_mano("L", "AZUL_LUZ")
        # No amplia ni duplica el telescopio.

    elif nombre == "NACAR":
        for x in (-0.105, -0.087, -0.069):
            body.tubo(
                [(x, 0.126, 0.942), (x, 0.126, 0.895)],
                [0.002, 0.002],
                mat_duro, "HIERRO", 5
            )
        anotar("Clavos sujetos al cinturon")
        hebilla()

    elif nombre == "CORAL_ROSA":
        cuentas_collar("CREMA")
        pulsera("L", "ROSA")

        # Bordado sencillo en torso: rama de coral.
        body.tubo(
            [(0.055, 0.112, 1.015),
             (0.058, 0.113, 1.053),
             (0.050, 0.113, 1.076)],
            [0.0018] * 3,
            mat_ropa, "ROSA", 5
        )
        body.tubo(
            [(0.058, 0.113, 1.047),
             (0.075, 0.113, 1.062)],
            [0.0015] * 2,
            mat_ropa, "ROSA", 5
        )
        anotar("Motivo sencillo de coral en vestido")

    # ---------------- AURORA ----------------

    elif nombre == "HIELO":
        for x in (-0.06, 0, 0.06):
            marca_runa((x, 0.124, 0.938), 0.8)
        anotar("Runas de cinturon")
        gema_mano("L", "AZUL_LUZ")
        # Báculo y cristal originales: no se duplican.

    elif nombre == "AURORA":
        pulsera("L", "ORO")
        pulsera("R", "ORO")

        body.esfera(
            (0, 0.138, 1.183),
            (0.019, 0.006, 0.022),
            mat_duro, "ORO", 10, 5
        )
        anotar("Medalla frontal sobre colgante existente")
        # Gafas y telescopio permanecen sin duplicados.

    elif nombre == "NIEVE":
        pulsera("L", "HIERBA")

        for x in (-0.008, 0, 0.008):
            body.tubo(
                [(0, 0.136, 1.194), (x, 0.139, 1.156)],
                [0.0012, 0.0012],
                mat_duro, "MADERA", 5
            )
            body.esfera(
                (x, 0.140, 1.164),
                (0.006, 0.003, 0.013),
                mat_ropa, "HIERBA", 6, 4
            )
        anotar("Ramito de hierbas sobre collar")
        # Conserva los frascos y el mandil originales.

    elif nombre == "GLACIAR":
        hebilla()

        for x in (-0.110, -0.090):
            body.tubo(
                [(x, 0.120, 0.953), (x, 0.120, 0.889)],
                [0.004, 0.003],
                mat_duro, "HIERRO", 6
            )
        anotar("Herramientas pequenas de cinturon")

    elif nombre == "ESTRELLA_FUGAZ":
        gema_mano("L", "NEGRO")

        for x in (-0.030, 0.030):
            body.esfera(
                (x, 0.132, 1.198),
                (0.004, 0.004, 0.013),
                mat_duro, "CREMA_OSC", 6, 4
            )
        anotar("Dos cuentas oseas de collar")

        # Detalle localizado sobre EL farol existente.
        # Centro original del farol:
        # mano derecha + (0, 0.04, -0.08).
        centro_farol = mano("R") + Vector((0, 0.04, -0.08))
        brazo_r = detalles["ARM_R"]

        for x in (-0.027, 0.027):
            brazo_r.esfera(
                centro_farol + Vector((x, 0.035, 0.055)),
                (0.003, 0.002, 0.003),
                mat_duro, "HIERRO", 6, 4
            )
        anotar("Remaches del farol existente")

    else:
        raise RuntimeError(f"NPC sin decoracion definida: {nombre}")

    for grupo in detalles.values():
        grupo.aplicar(coleccion)

    return {
        "factor_referencia": factor,
        "ancho_arquetipo": ancho,
        "postura_encorvada": nombre in ANCIANOS,
        "detalles_anadidos": registro,
    }


# ---------------- VALIDACION Y LOTE ----------------

BASE_EXPORT.mkdir(parents=True, exist_ok=True)

catalogo = {
    "revision": 3,
    "fuente": "ALTA_ORIGINAL",
    "correctos": [],
    "errores": [],
    "aprobacion_visual": "PENDIENTE",
}

for isla, nombres in LOTES:
    for nombre in nombres:
        if SOLO_NOMBRES_V3 is not None and nombre not in SOLO_NOMBRES_V3:
            continue

        candidatos = sorted(
            (BASE_EXPORT / isla).glob(
                f"*/SM_NPC_{nombre}.blend"
            )
        )

        if len(candidatos) != 1:
            catalogo["errores"].append({
                "npc": nombre,
                "error": (
                    "Se esperaba un original unico; "
                    f"encontrados: {len(candidatos)}"
                ),
            })
            continue

        origen = candidatos[0]
        salida = origen.parent / "REVISION_03"
        salida.mkdir(parents=True, exist_ok=True)

        try:
            raiz, partes, col = cargar(origen, nombre)

            tris_antes = sum(
                triangulos(obj) for obj in partes.values()
            )
            mats_antes = materiales_usados(partes)

            datos = decorar_v3(nombre, partes, col)
            bpy.context.view_layer.update()

            tris_despues = sum(
                triangulos(obj) for obj in partes.values()
            )
            mats_despues = materiales_usados(partes)

            if tris_despues > MAX_TRIS:
                raise RuntimeError(
                    f"Presupuesto excedido: {tris_despues} tris."
                )

            if mats_despues != mats_antes or len(mats_despues) > 6:
                raise RuntimeError("Se altero el conjunto de materiales.")

            meshes_finales = [
                obj for obj in col.objects if obj.type == "MESH"
            ]
            if len(meshes_finales) != 8:
                raise RuntimeError("El resultado no contiene ocho meshes.")

            for obj in partes.values():
                if obj.parent != raiz:
                    raise RuntimeError(
                        f"Parentesco incorrecto: {obj.name}"
                    )
                if obj.data.color_attributes.get("COLOR_0") is None:
                    raise RuntimeError(
                        f"Falta COLOR_0: {obj.name}"
                    )
                if (obj.scale - Vector((1,1,1))).length > 1e-6:
                    raise RuntimeError(
                        f"Escala incorrecta: {obj.name}"
                    )

            minimo, maximo = limites(partes)

            if abs(minimo.z) > 0.001:
                raise RuntimeError(
                    f"Contacto con suelo incorrecto: {minimo.z}"
                )

            raiz["REVISION_ARTISTICA"] = 3
            raiz["APROBACION_VISUAL"] = "PENDIENTE"

            informe = {
                "npc": nombre,
                "isla": isla,
                "revision": 3,
                "origen": str(origen),
                **datos,
                "triangulos_antes": tris_antes,
                "triangulos_despues": tris_despues,
                "triangulos_anadidos": tris_despues - tris_antes,
                "meshes": 8,
                "objetos_con_empty": 9,
                "materiales": len(mats_despues),
                "dimensiones_con_accesorios_m": list(maximo-minimo),
                "intersecciones": "NO_COMPROBADAS",
                "microaccesorios_completos": False,
                "aprobacion_visual": "PENDIENTE",
                "capturas": [],
            }

            exportar_glb(
                raiz, partes,
                salida / f"SM_NPC_{nombre}.glb"
            )

            if GENERAR_CAPTURAS_V3:
                informe["capturas"] = renderizar(
                    nombre, partes, salida
                )

            # Eliminar bloques temporales sin usuarios.
            for grupo in (bpy.data.meshes, bpy.data.materials):
                for bloque in list(grupo):
                    if bloque.users == 0:
                        grupo.remove(bloque)

            bpy.ops.wm.save_as_mainfile(
                filepath=str(
                    salida / f"SM_NPC_{nombre}.blend"
                )
            )

            guardar_json(
                salida / "REVISION_03.json", informe
            )

            # Un fallo antiguo no debe parecer vigente
            # despues de una ejecucion correcta.
            error_anterior = salida / "ERROR_REVISION_03.json"
            if error_anterior.exists():
                error_anterior.unlink()

            catalogo["correctos"].append({
                "npc": nombre,
                "isla": isla,
                "triangulos": tris_despues,
                "carpeta": str(salida),
            })

        except Exception as error:
            traceback.print_exc()

            fallo = {
                "npc": nombre,
                "isla": isla,
                "error": str(error),
                "traceback": traceback.format_exc(),
            }

            catalogo["errores"].append(fallo)
            guardar_json(
                salida / "ERROR_REVISION_03.json",
                fallo
            )

        finally:
            guardar_json(
                BASE_EXPORT / "REVISION_03_CATALOGO.json",
                catalogo
            )

guardar_json(
    BASE_EXPORT / "REVISION_03_CATALOGO.json",
    catalogo
)

print("\n========== REVISION 03 ==========")
print("Completados:", len(catalogo["correctos"]))
print("Errores:", len(catalogo["errores"]))
print("Informe:", BASE_EXPORT / "REVISION_03_CATALOGO.json")