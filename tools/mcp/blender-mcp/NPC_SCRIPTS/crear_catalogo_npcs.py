import bpy
import math
import json
import traceback
import unicodedata

from pathlib import Path
from mathutils import Vector


# ---------------- CONFIGURACION ----------------

# Al ejecutar mediante --python, __file__ apunta a este archivo.
CARPETA_SCRIPT = Path(r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\NPC_SCRIPTS")

BASE_LUNA = CARPETA_SCRIPT / "crear_luna.py"
SALIDA = Path(r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\NPC_EXPORT")

GENERAR_CAPTURAS = True
RESOLUCION_CAPTURAS = 768

# None = todos. Ejemplos: {1, 2, 3}, {13, 14}, set(range(23, 31)).
SOLO_IDS = None

# Mantener False permite obtener informe de los fallos y continuar.
DETENER_EN_ERROR = False


# ---------------- PALETAS ----------------
# Piel: valores exactos proporcionados.
# Pelo y ojos: propuestas, porque faltan los hex oficiales M161.

SK = {
    1: "#F5D6C4",
    2: "#D4A882",
    3: "#C49A6C",
    4: "#8B6914",
    5: "#5C4033",
}

HR = {
    1: "#BD995F",
    2: "#98704E",
    3: "#694B37",
    4: "#A75E40",
    5: "#302923",
    6: "#96918A",
    7: "#E3DED3",
    8: "#C98C64",
}

EY = {
    1: "#624A35",
    2: "#637653",
    3: "#688B9A",
    4: "#AD8649",
    5: "#858985",
}

P = {
    "crema": "#E9DDC5",
    "lino": "#D8C8AA",
    "blanco": "#EEE9DF",
    "tierra": "#A17A58",
    "madera": "#65513E",
    "cuero": "#825D43",
    "terracota": "#A7664E",
    "rosa": "#BC8984",
    "verde": "#758565",
    "agua": "#739D9A",
    "cielo": "#8DAEB8",
    "naranja": "#C8874E",
    "gris": "#858783",
    "carbon": "#465057",
    "hierro": "#899194",
    "negro": "#302E2C",
    "azul": "#39486F",
    "rojo": "#A9564D",
    "oro": "#BD9F59",
    "cobre": "#AD7956",
    "plata": "#B8BCB6",
    "azul_luz": "#8FBAC9",
}

ISLAS = {
    "RAIZ": "01_RAIZ",
    "CENIZA": "02_CENIZA",
    "CORAL": "03_CORAL",
    "AURORA": "04_AURORA",
}


# ---------------- FICHAS ----------------
# Campos:
# ID | nombre | isla | SK | HR | EY | altura anatomica
# camisa | pantalon/falda | pelo | sombrero | prendas | herramienta | extras
#
# Prendas:
# falda, falda_larga, tunica, shorts, bombacho
# delantal:<color>, chaleco:<color>, capa:<color>, bufanda:<color>
#
# Extras implementados:
# lentes, collar, frascos, bolsillo, guantes, cruz, cinta,
# pluma, mochila, barba, constelaciones, lampara_cinto
#
# Las prendas y accesorios son islas de geometria incorporadas
# a los ocho meshes, no superficies soldadas al cuerpo.

DATOS = """
1|Luna|RAIZ|2|2|2|1.8|crema|crema|mono|ninguno|falda,delantal:lino|pintura|cinta
2|Rocky|RAIZ|3|3|4|1.8|lino|madera|corto|ninguno|delantal:cuero|hacha|bolsillo
3|Coral|RAIZ|1|1|3|1.8|agua|crema|trenza|ninguno|shorts,chaleco:naranja|mapa|collar
4|Chef|RAIZ|2|3|1|1.8|crema|terracota|mono|cofia|falda,delantal:terracota|cuchara|bolsillo,pan
5|Fin|RAIZ|3|5|1|1.8|cielo|crema|corto|pescador|shorts,chaleco:naranja|cana|rayas
6|Flora|RAIZ|2|8|2|1.8|rosa|verde|trenza|paja|delantal:crema|rastrillo|cinta,guantes,bolsillo
7|Sage|RAIZ|1|6|5|1.7|crema|carbon|mono|ninguno|falda,chaleco:carbon|libro|lentes,collar,guantes
8|Merc|RAIZ|2|2|2|1.8|crema|terracota|mono|ninguno|falda,delantal:crema,bufanda:terracota|bolsa|collar
9|Nana|RAIZ|5|7|2|1.7|blanco|blanco|mono|sanador|falda,delantal:verde|pocion|cruz,frascos,collar
10|Carp|RAIZ|3|3|4|1.8|lino|madera|corto|paja|delantal:cuero|hacha|bolsillo
11|Melodía|RAIZ|2|4|4|1.8|rojo|negro|crespo|copa|chaleco:negro|cencerro|guantes,pan
12|Roca|RAIZ|4|5|1|1.9|azul|azul|corto|guardia|chaleco:carbon|espada|guantes,collar
13|Brasa|CENIZA|4|5|1|1.8|tierra|carbon|crespo|ninguno|chaleco:carbon|pico|casco_cinto,lampara_cinto,bolsillo
14|Obsidiana|CENIZA|5|7|3|1.7|carbon|gris|largo|ancho|tunica|baston|barba,lentes,mochila,frascos
15|Tufa|CENIZA|2|3|2|1.8|crema|verde|mono|cofia|falda,delantal:crema|pocion|frascos,bolsillo
16|Horno|CENIZA|4|5|1|1.8|blanco|terracota|corto|cofia|delantal:terracota|cuchara|bolsillo,pan
17|Ceniza|CENIZA|3|2|1|1.8|gris|gris|corto|lana|chaleco:cuero|antorcha|guantes
18|Pedro|CENIZA|5|5|1|1.8|carbon|carbon|corto|minero|chaleco:hierro|pico|guantes,lampara_cinto,bolsillo
19|Vulcania|CENIZA|4|7|4|1.8|crema|carbon|largo|ninguno|falda,chaleco:carbon|pergamino|lentes,collar,guantes
20|Chispa|CENIZA|2|4|5|1.8|oro|crema|crespo|turbante|tunica,bombacho,chaleco:cobre|bolsa|pluma
21|Caldera|CENIZA|4|5|1|1.9|carbon|carbon|corto|minero|chaleco:hierro|lanza|guantes,lampara_cinto,collar
22|Humo|CENIZA|5|5|5|1.8|carbon|negro|largo|turbante_oscuro|tunica,bombacho|flauta|collar
23|Ola|CORAL|3|1|3|1.8|agua|crema|largo|paja_ancho|falda_larga|red|collar,sandalias
24|Perla|CORAL|1|7|3|1.8|oro|crema|trenza|turbante|tunica,bombacho,chaleco:cobre|joya|pluma,collar
25|Concha|CORAL|3|2|1|1.8|crema|crema|corto|paja|shorts|bolsa|collar,sandalias
26|Alga|CORAL|5|6|2|1.7|verde|verde|trenza|ninguno|tunica|canasto|collar,sandalias
27|Tiburón|CORAL|4|5|1|1.9|azul|azul|corto|guardia|chaleco:carbon|lanza|guantes,collar
28|Estrella|CORAL|2|7|5|1.8|azul|azul|largo|ninguno|tunica,capa:oro|telescopio|constelaciones,collar
29|Nácar|CORAL|3|1|3|1.8|crema|crema|corto|ninguno|shorts,chaleco:cuero|martillo|guantes,bolsillo
30|Coral Rosa|CORAL|1|8|2|1.8|crema|crema|largo|ninguno|falda_larga|caracola|collar,sandalias
31|Hielo|AURORA|4|7|3|1.7|azul|azul|largo|mago|tunica,capa:oro|baculo|constelaciones,collar,guantes
32|Aurora|AURORA|1|7|3|1.8|azul|carbon|largo|ninguno|tunica,capa:oro|telescopio|lentes,constelaciones,collar
33|Nieve|AURORA|5|6|2|1.7|blanco|blanco|largo|sanador|falda,delantal:verde|pocion|cruz,frascos,collar
34|Glaciar|AURORA|4|5|1|1.8|carbon|carbon|corto|minero|chaleco:hierro|pico|guantes,bolsillo
35|Estrella Fugaz|AURORA|2|1|5|1.8|carbon|carbon|corto|capucha|tunica,capa:negro|farol|collar,guantes
""".strip()


def slug(texto):
    texto = unicodedata.normalize("NFKD", texto)
    texto = texto.encode("ascii", "ignore").decode()
    return texto.upper().replace(" ", "_")


def fichas():
    salida = []
    for linea in DATOS.splitlines():
        f = linea.split("|")
        salida.append({
            "id": int(f[0]),
            "nombre": f[1],
            "slug": slug(f[1]),
            "isla": f[2],
            "sk": int(f[3]),
            "hr": int(f[4]),
            "ey": int(f[5]),
            "altura": float(f[6]),
            "camisa": P[f[7]],
            "pantalon": P[f[8]],
            "pelo": f[9],
            "sombrero": f[10],
            "prendas": f[11].split(","),
            "herramienta": f[12],
            "extras": set(f[13].split(",")),
        })
    return salida


# ---------------- REUTILIZACION DE LUNA ----------------

if not BASE_LUNA.exists():
    raise FileNotFoundError(
        f"No se encuentra {BASE_LUNA}. "
        "Guarda ahi el script completo de Luna de la entrega anterior."
    )

FUENTE = BASE_LUNA.read_text(encoding="utf-8")

MARCADOR = "# ---------------- LIMPIEZA DE SESION ----------------"
if MARCADOR not in FUENTE:
    raise RuntimeError(
        "crear_luna.py no coincide con la version esperada."
    )

PREFIJO, RESTO = FUENTE.split(MARCADOR, 1)
SUFIJO = MARCADOR + RESTO


# ---------------- GENERADOR DE VARIANTES ----------------

def construir_npc(ns, ficha):
    """
    Conserva cabeza y ojos de Luna, recoloreados.
    Reconstruye torso, ropa, pelo, extremidades y herramientas.
    """
    Pieza = ns["Pieza"]
    partes = ns["PARTES"]

    # Alias a las primitivas del script base.
    E0 = ns["elipsoide"]
    T0 = ns["tubo"]
    B0 = ns["caja"]
    R0 = ns["anillo_z"]
    C0 = ns["conectar_anillos"]

    piel = SK[ficha["sk"]]
    pelo = HR[ficha["hr"]]
    iris = EY[ficha["ey"]]
    camisa = ficha["camisa"]
    pantalon = ficha["pantalon"]

    prendas = ficha["prendas"]
    extras = ficha["extras"]

    # Seis familias de material.
    SKIN, HAIR, CLOTH, LOWER, BOOT, EYE = range(6)

    def tono(x):
        return P.get(x, x)

    def E(parte, c, r, mat, col, n=10, m=6):
        E0(partes[parte], c, r, mat, tono(col), n, m)

    def T(parte, puntos, radios, mat, col, n=8, cerrar=True):
        T0(partes[parte], puntos, radios, mat, tono(col), n, cerrar)

    def B(parte, c, r, mat, col):
        B0(partes[parte], c, r, mat, tono(col))

    def Z(parte, specs, mat, col, n=16, cerrar=False):
        anillos = [R0(*s, n) for s in specs]
        C0(
            partes[parte], anillos, mat, tono(col),
            cerrar_inicio=cerrar, cerrar_final=cerrar
        )

    def aro(parte, centro, rx, rz, mat, col, grosor=0.0025, n=16):
        c = Vector(centro)
        puntos = [
            c + Vector((
                rx * math.cos(2 * math.pi * i / n),
                0,
                rz * math.sin(2 * math.pi * i / n)
            ))
            for i in range(n + 1)
        ]
        T(parte, puntos, [grosor] * len(puntos), mat, col, 5)

    # Actualiza colores de cabeza y ojos ya construidos.
    cambios = {
        ns["color"]("PIEL"): ns["color"](piel),
        ns["color"]("PELO"): ns["color"](pelo),
        ns["color"]("VERDE_OJO"): ns["color"](iris),
    }

    for nombre in ("HEAD", "EYES"):
        partes[nombre].colores = [
            cambios.get(tuple(c), c) for c in partes[nombre].colores
        ]

    for nombre in ("BODY", "HAIR", "ARM_L", "ARM_R", "LEG_L", "LEG_R"):
        partes[nombre] = Pieza(nombre)

    # Ancho estructural por arquetipo.
    ancho = 1.12 if ficha["altura"] == 1.9 else (
        0.98 if ficha["altura"] == 1.7 else 1.0
    )

    # ---------------- TORSO: 12 ANILLOS ----------------

    torso = ns["TORSO"]
    Z(
        "BODY",
        [(0, 0, z, rx * ancho, ry * ancho)
         for z, rx, ry in torso],
        CLOTH, camisa, 16, True
    )

    # Cuello: 3 anillos.
    Z("BODY", [
        (0, 0, 1.235, 0.057, 0.055),
        (0, 0, 1.280, 0.054, 0.052),
        (0, 0, 1.330, 0.059, 0.056),
    ], SKIN, piel, 12)

    # ---------------- EXTREMIDADES ----------------

    manos = {}

    for sg, brazo, pierna in [
        (-1, "ARM_L", "LEG_L"),
        (1, "ARM_R", "LEG_R")
    ]:
        hombro = 0.19 * ancho
        x = sg * 0.214 * ancho

        puntos = [
            (sg * hombro, 0.000, 1.200),
            (sg * 0.207 * ancho, 0.014, 1.125),
            (sg * 0.215 * ancho, 0.025, 1.045),
            (sg * 0.217 * ancho, 0.052, 0.987),
            (x, 0.080, 0.950),
        ]

        # Manga corta para los personajes especificados.
        corta = ficha["id"] in {
            3, 5, 6, 13, 17, 23, 25, 29
        }

        T(
            brazo, puntos[:3] if corta else puntos,
            [0.045, 0.044, 0.042] if corta
            else [0.045, 0.044, 0.042, 0.040, 0.038],
            CLOTH, camisa, 12
        )

        T(
            brazo,
            puntos[2:] + [(sg * 0.210 * ancho, 0.110, 0.912)]
            if corta else [
                (x, 0.083, 0.954),
                (sg * 0.210 * ancho, 0.110, 0.912)
            ],
            [0.035, 0.032, 0.030, 0.028] if corta else [0.031, 0.028],
            SKIN, piel, 10
        )

        mano = Vector((sg * 0.210 * ancho, 0.129, 0.900))
        manos[brazo] = mano

        guante = "guantes" in extras
        blanco = ficha["id"] in {7, 11, 19}
        col_mano = P["blanco"] if blanco else P["cuero"]
        mat_mano = CLOTH if guante else SKIN

        E(
            brazo, mano, (0.033, 0.039, 0.040),
            mat_mano, col_mano if guante else piel
        )
        E(
            brazo, mano + Vector((-sg * 0.026, 0.017, 0.012)),
            (0.012, 0.017, 0.022),
            mat_mano, col_mano if guante else piel, 8, 4
        )

        # Pierna: exactamente cinco anillos.
        xleg = sg * 0.079 * ancho
        specs = [
            (xleg, 0.000, 0.810, 0.067, 0.071),
            (xleg, 0.007, 0.645, 0.062, 0.065),
            (xleg, 0.016, 0.450, 0.054, 0.057),
            (xleg, 0.008, 0.290, 0.047, 0.050),
            (xleg, 0.003, 0.150, 0.043, 0.047),
        ]

        if "bombacho" in prendas:
            specs = [
                (x, y, z, rx * (1.4 if z > 0.3 else 1),
                 ry * (1.4 if z > 0.3 else 1))
                for x, y, z, rx, ry in specs
            ]

        Z(pierna, specs, LOWER, pantalon, 12)

        # Recolorea las caras inferiores en shorts o bajo falda.
        descubre = (
            "shorts" in prendas or
            any(p.startswith("falda") for p in prendas)
        )
        if descubre:
            pieza = partes[pierna]
            for i, cara in enumerate(pieza.caras):
                zmedio = sum(pieza.vertices[v].z for v in cara) / len(cara)
                if zmedio < 0.64:
                    pieza.slots[i] = SKIN
                    pieza.colores[i] = ns["color"](piel)

        sandalia = "sandalias" in extras
        bota_color = (
            "oro" if ficha["id"] == 32
            else "gris" if ficha["id"] == 5
            else "negro" if ficha["altura"] == 1.9
            else "cuero"
        )

        Z(pierna, [
            (xleg, 0.047, 0.000, 0.057, 0.094),
            (xleg, 0.047, 0.019, 0.059, 0.096),
        ], BOOT, "madera", 12, True)

        if sandalia:
            E(
                pierna, (xleg, 0.044, 0.048),
                (0.052, 0.085, 0.028), SKIN, piel, 12, 6
            )
            for y in (0.022, 0.075):
                B(
                    pierna, (xleg, y, 0.072),
                    (0.100, 0.014, 0.010), BOOT, "cuero"
                )
        else:
            Z(pierna, [
                (xleg, 0.047, 0.018, 0.059, 0.096),
                (xleg, 0.045, 0.065, 0.060, 0.092),
                (xleg, 0.020, 0.109, 0.052, 0.064),
                (xleg, 0.005, 0.150, 0.048, 0.052),
                (xleg, 0.003, 0.240, 0.049, 0.052),
            ], BOOT, bota_color, 12, True)

    # ---------------- PRENDAS ----------------

    def falda(zb, col, plisada=False):
        anillos = []
        for z, rx, ry in [
            (0.930, 0.149, 0.112),
            (0.820, 0.170, 0.125),
            ((0.820 + zb) / 2, 0.186, 0.137),
            (zb, 0.204, 0.151),
        ]:
            n = 32
            anillo = []
            for j in range(n):
                a = 2 * math.pi * j / n
                d = 0.008 * math.cos(8 * a) if plisada else 0
                anillo.append((
                    (rx * ancho + d) * math.cos(a),
                    (ry + d) * math.sin(a), z
                ))
            anillos.append(anillo)
        C0(partes["BODY"], anillos, LOWER, tono(col))

    if "falda" in prendas:
        falda(0.49, pantalon, True)
    if "falda_larga" in prendas:
        falda(0.20, pantalon, False)
    if "tunica" in prendas:
        falda(0.25 if "bombacho" not in prendas else 0.56, camisa)

    for prenda in prendas:
        if ":" not in prenda:
            continue

        tipo, col = prenda.split(":")

        if tipo == "delantal":
            # Panel frontal curvo, abierto y de doble cara.
            verts = []
            for z, w, y in [
                (0.54, 0.125, 0.174),
                (0.74, 0.121, 0.159),
                (0.93, 0.103, 0.131),
                (1.13, 0.063, 0.132)
            ]:
                for j in range(9):
                    u = -1 + 2 * j / 8
                    verts.append((w * u, y - 0.014 * u*u, z))
            caras = []
            for k in range(3):
                for j in range(8):
                    i = k * 9 + j
                    caras.append((i, i+1, i+10, i+9))
            partes["BODY"].agregar(verts, caras, CLOTH, tono(col))

            for sg in (-1, 1):
                T("BODY", [
                    (sg*0.055, 0.132, 1.12),
                    (sg*0.065, 0.075, 1.22),
                    (sg*0.060, -0.04, 1.23),
                ], [(0.009, 0.003)]*3, CLOTH, col, 6)

        elif tipo == "chaleco":
            # Dos paneles acolchados y panel posterior.
            for sg in (-1, 1):
                E("BODY", (sg*0.085, 0.095, 1.065),
                  (0.081, 0.035, 0.151), CLOTH, col, 10, 6)
            E("BODY", (0, -0.090, 1.068),
              (0.163, 0.025, 0.156), CLOTH, col, 12, 6)

        elif tipo == "bufanda":
            Z("BODY", [
                (0, 0, 1.258, 0.076, 0.068),
                (0, 0, 1.295, 0.078, 0.071),
            ], CLOTH, col, 12)
            T("BODY", [(0, -0.07, 1.28), (0.045, -0.13, 1.06)],
              [(0.025, 0.006)]*2, CLOTH, col, 6)

        elif tipo == "capa":
            # Paño posterior abierto con curvatura lateral.
            vertices = []
            for z, w, y in [
                (1.24, 0.13, -0.085),
                (1.12, 0.20, -0.125),
                (0.80, 0.23, -0.157),
                (0.30 if ficha["id"] == 35 else 0.60, 0.25, -0.19),
            ]:
                for j in range(9):
                    u = -1 + j / 4
                    vertices.append((w*u, y + 0.04*u*u, z))
            caras = []
            for k in range(3):
                for j in range(8):
                    i = k*9+j
                    caras.append((i, i+1, i+10, i+9))
            partes["BODY"].agregar(vertices, caras, CLOTH, tono(col))

    # Cinturon.
    Z("BODY", [
        (0, 0, 0.922, 0.153*ancho, 0.118),
        (0, 0, 0.945, 0.153*ancho, 0.118),
    ], BOOT, "cuero", 16)

    # ---------------- PELO ----------------

    centro = ns["CENTRO_CABEZA"]
    anillos = []

    for k in range(1, 8):
        anillo = []
        for j in range(20):
            a = 2*math.pi*j/20
            limite = math.radians(100 - 30*math.sin(a))
            ph = limite*k/7
            anillo.append(centro + Vector((
                0.124*math.sin(ph)*math.cos(a),
                0.121*math.sin(ph)*math.sin(a),
                0.166*math.cos(ph)
            )))
        anillos.append(anillo)

    corona = centro + Vector((0, 0, 0.166))
    anillos.insert(0, [corona.copy() for _ in range(20)])
    C0(partes["HAIR"], anillos, HAIR, pelo)

    estilo = ficha["pelo"]

    if estilo == "mono":
        E("HAIR", (0, -0.124, 1.411),
          (0.068, 0.057, 0.065), HAIR, pelo, 12, 8)

    elif estilo == "largo":
        E("HAIR", (0, -0.083, 1.245),
          (0.116, 0.063, 0.195), HAIR, pelo, 12, 8)

    elif estilo == "trenza":
        for i in range(7):
            E("HAIR",
              (0.010*math.sin(i*2.4), -0.121, 1.385-i*0.046),
              (0.037-i*0.002, 0.033, 0.032),
              HAIR, pelo, 8, 5)

    elif estilo == "crespo":
        for i in range(9):
            a = 2*math.pi*i/9
            E("HAIR",
              (0.106*math.cos(a), 0.087*math.sin(a), 1.48),
              (0.053, 0.050, 0.056), HAIR, pelo, 8, 5)

    if "barba" in extras:
        E("HEAD", (0, 0.076, 1.245),
          (0.082, 0.068, 0.145), HAIR, pelo, 10, 7)

    # ---------------- SOMBREROS ----------------

    sombrero = ficha["sombrero"]

    if sombrero in {"paja", "paja_ancho", "ancho", "pescador"}:
        col = (
            "carbon" if sombrero == "ancho"
            else "cielo" if sombrero == "pescador"
            else "lino"
        )
        ancho_ala = 0.235 if sombrero == "paja_ancho" else 0.19
        E("HAIR", (0, 0, 1.508),
          (ancho_ala, ancho_ala*0.88, 0.016), CLOTH, col, 16, 6)
        E("HAIR", (0, 0, 1.545),
          (0.124, 0.118, 0.069), CLOTH, col, 12, 8)
        Z("HAIR", [
            (0, 0, 1.524, 0.125, 0.120),
            (0, 0, 1.541, 0.125, 0.120),
        ], CLOTH, "rosa" if "cinta" in extras else "cuero", 16)

    elif sombrero in {"cofia", "sanador"}:
        E("HAIR", (0, 0, 1.526),
          (0.135, 0.127, 0.068), CLOTH, "blanco", 12, 8)
        B("HAIR", (0, 0.113, 1.536),
          (0.178, 0.012, 0.060), CLOTH, "blanco")

    elif sombrero in {"guardia", "minero"}:
        E("HAIR", (0, 0, 1.515),
          (0.135, 0.133, 0.085), BOOT, "hierro", 12, 8)
        E("HAIR", (0, 0.065, 1.486),
          (0.142, 0.138, 0.015), BOOT, "hierro", 12, 5)
        if sombrero == "minero":
            E("HAIR", (0, 0.132, 1.533),
              (0.034, 0.013, 0.034), EYE, "crema", 10, 6)
        else:
            B("HAIR", (0, 0.133, 1.533),
              (0.045, 0.008, 0.050), BOOT, "oro")

    elif sombrero in {"turbante", "turbante_oscuro", "lana"}:
        col = "oro" if sombrero == "turbante" else "carbon"
        E("HAIR", (0, 0, 1.526),
          (0.139, 0.133, 0.080), CLOTH, col, 12, 8)
        for z in (1.503, 1.530, 1.551):
            Z("HAIR", [
                (0, 0, z, 0.137, 0.132),
                (0, 0, z+0.006, 0.137, 0.132),
            ], CLOTH, col, 16)

    elif sombrero == "copa":
        E("HAIR", (0, 0, 1.513),
          (0.172, 0.156, 0.013), CLOTH, "oro", 16, 5)
        Z("HAIR", [
            (0, 0, 1.514, 0.112, 0.107),
            (0, 0, 1.692, 0.117, 0.112),
        ], CLOTH, "oro", 16, True)
        Z("HAIR", [
            (0, 0, 1.526, 0.115, 0.110),
            (0, 0, 1.553, 0.115, 0.110),
        ], CLOTH, "rojo", 16)

    elif sombrero == "mago":
        E("HAIR", (0, 0, 1.518),
          (0.190, 0.174, 0.018), CLOTH, "azul", 16, 5)
        T("HAIR", [
            (0, 0, 1.520), (0, 0, 1.650),
            (0.025, -0.025, 1.785), (0.06, -0.04, 1.85)
        ], [0.124, 0.080, 0.035, 0.005], CLOTH, "azul", 12)

    elif sombrero == "capucha":
        # Capucha con abertura frontal real, no esfera que tape la cara.
        anillos = []
        for z, rx, ry in [
            (1.25, 0.12, 0.12),
            (1.38, 0.15, 0.15),
            (1.50, 0.14, 0.14),
            (1.58, 0.045, 0.060),
        ]:
            anillo = []
            # Recorrido largo alrededor de nuca; hueco hacia +Y.
            for j in range(17):
                a = math.radians(135 + 270*j/16)
                anillo.append((rx*math.cos(a), ry*math.sin(a), z))
            anillos.append(anillo)

        verts = [v for a in anillos for v in a]
        caras = []
        for k in range(3):
            for j in range(16):
                i = k*17+j
                caras.append((i, i+1, i+18, i+17))
        partes["HAIR"].agregar(verts, caras, CLOTH, P["carbon"])

    # ---------------- ACCESORIOS PRINCIPALES ----------------

    if "lentes" in extras:
        for sg in (-1, 1):
            aro("HEAD", (sg*0.045, 0.121, 1.409),
                0.026, 0.029, BOOT, "oro" if ficha["id"] == 32 else "madera")
        T("HEAD", [(-0.019, 0.122, 1.413), (0.019, 0.122, 1.413)],
          [0.0025]*2, BOOT, "madera", 5)

    if "collar" in extras:
        T("BODY", [
            (-0.061, 0.044, 1.270),
            (-0.044, 0.109, 1.215),
            (0, 0.123, 1.190),
            (0.044, 0.109, 1.215),
            (0.061, 0.044, 1.270)
        ], [0.003]*5, BOOT, "cuero", 5)
        E("BODY", (0, 0.130, 1.183),
          (0.016, 0.008, 0.020), BOOT, "crema", 8, 5)

    if "bolsillo" in extras:
        B("BODY", (0.063, 0.175, 0.800),
          (0.070, 0.009, 0.080), CLOTH, "cuero")

    if "frascos" in extras:
        for x in (-0.100, -0.050, 0.050, 0.100):
            E("BODY", (x, 0.135, 0.899),
              (0.015, 0.018, 0.026), CLOTH, "verde", 8, 5)
            B("BODY", (x, 0.135, 0.928),
              (0.016, 0.017, 0.011), BOOT, "cuero")

    if "cruz" in extras:
        B("HAIR", (0, 0.123, 1.538),
          (0.040, 0.004, 0.012), CLOTH, "verde")
        B("HAIR", (0, 0.125, 1.538),
          (0.012, 0.004, 0.040), CLOTH, "verde")

    if "pluma" in extras:
        E("HAIR", (0.075, 0.010, 1.632),
          (0.017, 0.011, 0.091), CLOTH, "rojo", 8, 6)

    if "cinta" in extras and sombrero == "ninguno":
        for sg in (-1, 1):
            E("HAIR", (sg*0.033, -0.17, 1.44),
              (0.039, 0.012, 0.021), CLOTH, "rosa", 8, 4)

    if "mochila" in extras:
        E("BODY", (0, -0.15, 1.050),
          (0.122, 0.068, 0.151), BOOT, "cuero", 12, 8)

    if "pan" in extras:
        # Panuelo/pajarita estilizado.
        for sg in (-1, 1):
            E("BODY", (sg*0.026, 0.075, 1.266),
              (0.033, 0.012, 0.021), CLOTH, "rojo", 8, 4)

    if "lampara_cinto" in extras:
        B("BODY", (0.155, 0.050, 0.900),
          (0.045, 0.043, 0.063), BOOT, "hierro")
        E("BODY", (0.155, 0.075, 0.900),
          (0.014, 0.008, 0.021), EYE, "crema", 8, 4)

    if "casco_cinto" in extras:
        E("BODY", (-0.165, -0.035, 0.86),
          (0.066, 0.059, 0.049), BOOT, "hierro", 10, 6)

    if "constelaciones" in extras:
        for x, z in [
            (-0.06, 1.16), (0.03, 1.12), (0.065, 1.05),
            (-0.04, 1.02)
        ]:
            E("BODY", (x, 0.119, z),
              (0.005, 0.003, 0.005), CLOTH, "oro", 6, 4)

    # ---------------- HERRAMIENTAS ----------------
    # Geometria incorporada al brazo: no se puede soltar sin separarla.

    R = "ARM_R"
    L = "ARM_L"
    mr = manos[R]
    ml = manos[L]
    tool = ficha["herramienta"]

    def local_tubo(parte, mano, puntos, radios, mat, col, n=8):
        T(parte, [mano+Vector(p) for p in puntos], radios, mat, col, n)

    def mango(largo=0.32):
        local_tubo(R, mr,
                   [(0, 0.018, -0.10), (0, 0.018, largo)],
                   [0.009, 0.008], BOOT, "madera")

    if tool in {"hacha", "pico", "martillo", "rastrillo", "cuchara"}:
        mango(0.30)

        if tool == "hacha":
            # Hoja roma de perfil trapezoidal, extrusion simple.
            vertices = []
            for y in (0.009, 0.031):
                for x, z in [(0,0.22), (0.12,0.19), (0.12,0.32), (0,0.30)]:
                    vertices.append(mr+Vector((x,y,z)))
            caras = [
                (0,3,2,1), (4,5,6,7),
                (0,1,5,4), (1,2,6,5), (2,3,7,6), (3,0,4,7)
            ]
            partes[R].agregar(vertices, caras, BOOT, P["hierro"])

        elif tool == "pico":
            local_tubo(R, mr, [
                (-0.16,0.018,0.24), (-0.07,0.018,0.30),
                (0.07,0.018,0.30), (0.16,0.018,0.24)
            ], [0.006,0.020,0.020,0.006], BOOT, "hierro")

        elif tool == "martillo":
            B(R, mr+Vector((0,0.018,0.29)),
              (0.16,0.044,0.054), BOOT, "hierro")
            B(L, ml+Vector((0,0.055,0)),
              (0.08,0.12,0.22), BOOT, "madera")

        elif tool == "rastrillo":
            B(R, mr+Vector((0,0.018,0.29)),
              (0.23,0.026,0.023), BOOT, "madera")
            for x in (-0.09,-0.045,0,0.045,0.09):
                local_tubo(R,mr,[(x,0.018,0.29),(x,0.06,0.22)],
                           [0.006]*2,BOOT,"madera",6)

        else:
            E(R, mr+Vector((0,0.018,0.32)),
              (0.038,0.012,0.060), BOOT,"madera",10,6)

    elif tool in {"espada", "lanza", "baston", "baculo", "cana"}:
        largo = 0.69 if tool != "espada" else 0.44
        local_tubo(R,mr,[
            (0,0.022,-0.46), (0,0.022,0.0), (0.025,0.022,largo)
        ], [0.012,0.011,0.008], BOOT,
           "hierro" if tool=="espada" else "madera")

        if tool == "espada":
            B(R,mr+Vector((0,0.022,0.07)),
              (0.13,0.027,0.018),BOOT,"oro")
            B(R,mr+Vector((0.012,0.022,0.27)),
              (0.037,0.017,0.36),BOOT,"hierro")
        elif tool == "lanza":
            E(R,mr+Vector((0.025,0.022,largo)),
              (0.027,0.012,0.089),BOOT,"hierro",8,6)
        elif tool == "baculo":
            E(R,mr+Vector((0.025,0.022,largo+0.04)),
              (0.044,0.034,0.072),EYE,"azul_luz",6,4)
        elif tool == "cana":
            local_tubo(R,mr,[
                (0.025,0.022,largo), (0.05,0.15,largo-0.08),
                (0.05,0.15,-0.35)
            ],[0.0015]*3,BOOT,"crema",5)

    elif tool in {"pocion", "farol", "antorcha"}:
        if tool == "pocion":
            E(R,mr+Vector((0,0.027,0.074)),
              (0.036,0.032,0.047),EYE,"verde",10,6)
            local_tubo(R,mr,[(0,0.027,0.105),(0,0.027,0.14)],
                       [0.014]*2,BOOT,"cuero")
        elif tool == "antorcha":
            mango(0.26)
            E(R,mr+Vector((0,0.02,0.30)),
              (0.027,0.022,0.067),EYE,"naranja",8,5)
            B(L,ml+Vector((0,0.05,0.01)),
              (0.12,0.009,0.10),CLOTH,"crema")
        else:
            c=mr+Vector((0,0.04,-0.08))
            B(R,c,(0.063,0.050,0.082),EYE,"azul_luz")
            for x in (-0.034,0.034):
                for y in (-0.028,0.028):
                    B(R,c+Vector((x,y,0)),
                      (0.007,0.007,0.10),BOOT,"madera")
            B(R,c+Vector((0,0,0.055)),
              (0.082,0.068,0.018),BOOT,"madera")
            B(R,c-Vector((0,0,0.055)),
              (0.082,0.068,0.018),BOOT,"madera")
            aro(R,c+Vector((0,0,0.084)),
                0.028,0.028,BOOT,"madera",0.004)

    elif tool in {"mapa","pergamino","libro"}:
        if tool == "mapa":
            local_tubo(R,mr,[(0,0.03,-0.08),(0,0.03,0.13)],
                       [0.023]*2,CLOTH,"crema",10)
            E(L,ml+Vector((0,0.047,0.025)),
              (0.028,0.026,0.009),BOOT,"oro",10,5)
        elif tool == "pergamino":
            B(R,mr+Vector((-0.03,0.04,0.035)),
              (0.15,0.010,0.14),CLOTH,"crema")
            for z in (-0.039,0.109):
                local_tubo(R,mr,[(-0.115,0.04,z),(0.055,0.04,z)],
                           [0.014]*2,CLOTH,"crema")
        else:
            for dx in (-0.040,0.040):
                B(L,ml+Vector((dx,0.058,0.020)),
                  (0.079,0.12,0.022),BOOT,"cuero")
                B(L,ml+Vector((dx,0.058,0.035)),
                  (0.072,0.112,0.011),CLOTH,"crema")

    elif tool in {"bolsa","canasto"}:
        c=ml+Vector((0,0.045,-0.070))
        E(L,c,(0.074,0.058,0.075),BOOT,"cuero",12,8)
        aro(L,c+Vector((0,0,0.068)),0.053,0.038,BOOT,"madera",0.005)
        if tool=="canasto":
            for x in (-0.035,0,0.035):
                T(L,[c+Vector((x,0,0.02)),c+Vector((x,0,0.12))],
                  [0.016,0.004],CLOTH,"verde",6)

    elif tool in {"flauta","telescopio"}:
        col="oro" if tool=="telescopio" else "madera"
        r=0.026 if tool=="telescopio" else 0.009
        local_tubo(R,mr,[(-0.11,0.04,0.03),(0.11,0.04,0.07)],
                   [r,r*1.2],BOOT,col,10)
        if tool=="telescopio":
            E(R,mr+Vector((0.112,0.04,0.071)),
              (0.012,0.026,0.026),EYE,"azul_luz",8,5)
        else:
            for x in (-0.065,-0.025,0.015,0.055):
                E(R,mr+Vector((x,0.049,0.05+x*0.18)),
                  (0.003,0.002,0.003),BOOT,"negro",6,4)

    elif tool=="red":
        mango(0.23)
        c=mr+Vector((0,0.023,0.34))
        aro(R,c,0.11,0.12,BOOT,"madera",0.006,20)
        for u in (-0.06,-0.03,0,0.03,0.06):
            longitud=0.10*math.sqrt(max(0,1-(u/0.11)**2))
            T(R,[c+Vector((u,0,-longitud)),c+Vector((u,0,longitud))],
              [0.0017]*2,CLOTH,"crema",5)

    elif tool=="joya":
        c=mr+Vector((0,0.038,0.034))
        aro(R,c,0.020,0.020,BOOT,"oro",0.003,12)
        E(R,c+Vector((0,0,0.022)),(0.009,0.009,0.009),
          CLOTH,"blanco",8,5)

    elif tool=="caracola":
        c=mr+Vector((0,0.04,0.025))
        E(R,c,(0.055,0.043,0.048),CLOTH,"crema",12,8)
        local_tubo(R,c,[(0,0,0),(0.06,0,0.02),(0.09,0,0.04)],
                   [0.03,0.02,0.007],CLOTH,"rosa",8)

    elif tool=="cencerro":
        c=mr+Vector((0,0.036,-0.025))
        Z(R,[
            (c.x,c.y,c.z-0.06,0.044,0.034),
            (c.x,c.y,c.z+0.02,0.026,0.023)
        ],BOOT,"oro",8,True)
        aro(R,c+Vector((0,0,0.046)),0.020,0.022,BOOT,"oro",0.004,12)

    else:
        raise ValueError(f"Herramienta no implementada: {tool}")

    # ---------------- POSTURA DE ANCIANOS ----------------
    # Inclinacion geometrica suave de la parte superior,
    # sin rotaciones de objeto. No sustituye a un rig.
    if ficha["altura"] == 1.7:
        for pieza in partes.values():
            for v in pieza.vertices:
                t=max(0.0,min(1.0,(v.z-0.85)/0.65))
                v.y += 0.040*t*t

    # Pivotes alineados con el ancho de hombros.
    ns["PIVOTES_REF"]["ARM_L"] = (-0.19*ancho,0,1.20)
    ns["PIVOTES_REF"]["ARM_R"] = ( 0.19*ancho,0,1.20)

    ns["PARTES"] = partes


# ---------------- ADAPTAR EXPORTADOR BASE ----------------

def preparar_exportador(ficha):
    codigo = SUFIJO.replace("LUNA", ficha["slug"])

    # El tipo humano permanece. Cambiamos metadatos fijos de Luna.
    codigo = codigo.replace(
        'raiz["NPC_ID"] = "01"',
        f'raiz["NPC_ID"] = "{ficha["id"]:02d}"'
    )
    codigo = codigo.replace(
        'raiz["ISLA"] = "RAIZ"',
        f'raiz["ISLA"] = "{ficha["isla"]}"'
    )
    codigo = codigo.replace(
        'raiz["PROFESION"] = "PINTORA"',
        f'raiz["PROFESION"] = "{ficha["herramienta"].upper()}"'
    )
    codigo = codigo.replace(
        '"isla": "RAIZ"',
        f'"isla": "{ficha["isla"]}"'
    )

    if ficha["id"] != 1:
        # Altura anatomica: NO encoger al humano para meter su
        # sombrero en 1.8 m. Los sombreros pueden superar esa altura.
        inicio = codigo.index("altura_ref = max(")
        fin = codigo.index("factor = ALTURA_OBJETIVO / altura_ref", inicio)

        codigo = (
            codigo[:inicio]
            + 'altura_ref = max(v.z for v in PARTES["HEAD"].vertices)\n\n'
            + codigo[fin:]
        )

        # El assert de altura excluye pelo y sombreros.
        codigo = codigo.replace(
            '"_BODY", "_HEAD", "_HAIR", "_LEG_L", "_LEG_R"',
            '"_BODY", "_HEAD", "_LEG_L", "_LEG_R"'
        )

    # Algunos accesorios se asignan al material OJOS para sugerir
    # brillo. Es la misma emision tenue, no una luz real.
    return codigo


# ---------------- EJECUCION POR LOTES ----------------

SALIDA.mkdir(parents=True, exist_ok=True)

registro = {
    "tipo": "PRIMERA_PASADA_PROCEDURAL",
    "blender": bpy.app.version_string,
    "capturas_activadas": GENERAR_CAPTURAS,
    "correctos": [],
    "errores": [],
    "pendientes_comunes": [
        "Aprobacion visual de cada NPC.",
        "Prueba de importacion en Godot 4.7.2.",
        "Microaccesorios y bordados particulares.",
        "Revision de intersecciones y agarres de herramientas.",
        "Rig, pesos, animaciones y variantes LOD.",
    ],
}

for ficha in fichas():
    if SOLO_IDS is not None and ficha["id"] not in SOLO_IDS:
        continue

    print(
        f'\n===== NPC {ficha["id"]:02d}/35: '
        f'{ficha["nombre"]} ====='
    )

    try:
        # Espacio de nombres independiente para cada NPC.
        ns = {
            "__name__": "__main__",
            "__file__": str(BASE_LUNA),
        }

        # Construye primitivas/datos de Luna, sin limpiar/exportar aun.
        exec(compile(PREFIJO, str(BASE_LUNA), "exec"), ns)

        if ficha["id"] != 1:
            construir_npc(ns, ficha)

        carpeta = (
            SALIDA
            / ISLAS[ficha["isla"]]
            / f'{ficha["id"]:02d}_{ficha["slug"]}'
        )

        ns["NOMBRE"] = ficha["slug"]
        ns["OUTPUT_DIR"] = carpeta
        ns["ALTURA_OBJETIVO"] = ficha["altura"]
        ns["RENDER_CAPTURAS"] = GENERAR_CAPTURAS
        ns["RESOLUCION"] = RESOLUCION_CAPTURAS
        ns["ESCALAR_PIVOTES"] = True

        exportador = preparar_exportador(ficha)
        exec(compile(exportador, "<exportador_npc>", "exec"), ns)

        # Ficha separada para conservar identidad y opciones
        # aunque el exportador base utilice metadatos abreviados.
        ficha_json = {
            **ficha,
            "extras": sorted(ficha["extras"]),
            "estado": "GENERADO_PENDIENTE_APROBACION",
            "altura_incluye_sombrero": ficha["id"] == 1,
            "herramienta_separable": False,
            "microaccesorios_completos": False,
        }

        with open(carpeta / "FICHA_NPC.json", "w", encoding="utf-8") as f:
            json.dump(ficha_json, f, ensure_ascii=False, indent=2)

        registro["correctos"].append({
            "id": ficha["id"],
            "nombre": ficha["nombre"],
            "carpeta": str(carpeta),
            "triangulos": ns["resumen"]["triangulos_total"],
            "meshes": ns["resumen"]["objetos_mesh"],
            "materiales": ns["resumen"]["materiales_unicos"],
        })

    except Exception as error:
        traceback.print_exc()
        registro["errores"].append({
            "id": ficha["id"],
            "nombre": ficha["nombre"],
            "error": str(error),
            "traceback": traceback.format_exc(),
        })
        if DETENER_EN_ERROR:
            raise

    finally:
        with open(
            SALIDA / "CATALOGO_RESUMEN.json", "w", encoding="utf-8"
        ) as f:
            json.dump(registro, f, ensure_ascii=False, indent=2)


print("\n================ RESULTADO DEL LOTE ================")
print(f'Generados: {len(registro["correctos"])}')
print(f'Con error: {len(registro["errores"])}')
print(f'Informe: {SALIDA / "CATALOGO_RESUMEN.json"}')
