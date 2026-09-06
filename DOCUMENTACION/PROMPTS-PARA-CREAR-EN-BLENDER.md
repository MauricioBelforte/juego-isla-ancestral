SM_Pulpo_Arrecife, SM_Pez_Rio y NPC — misma estrategia
Entiendo tu mensaje como tres encargos: pulpo, pez y un primer personaje NPC (con la receta lista para generar más). Los tres reutilizan el NÚCLEO COMÚN del mensaje anterior sin cambios, más un parche de 6 líneas que va justo debajo del núcleo.

Python

# ---- PARCHE AL NÚCLEO (pegar debajo del NÚCLEO COMÚN, antes de la especie) ----
# 'up' del anillo = +Z proyectado sobre el plano del anillo. Así "dorsal" es siempre arriba
# aunque el tubo apunte hacia -Y (brazos del pulpo que van hacia atrás, aletas, etc.).
def frame(tang):
    t  = tang.normalized()
    up = Vector((0, 0, 1)) - t * t.z
    if up.length < 1e-6: up = Vector((0, 1, 0))
    up.normalize()
    return t.cross(up).normalized(), up
Fichas propuestas
Pulpo de Arrecife	Pez de Río	NPC "Granjera"
Base	Octopus vulgaris	Trucha común / carpa	Humano estilizado, ~5 cabezas
Bioma	Rocas de marea, arrecife	Río, estanque	Isla (granja)
Comportamiento	Curioso, cambia de color al acercarte	Nada en bancos, huye lento	Habla, saluda, camina
Tamaño (escala 1.0)	0,7 m de envergadura, 0,5 m alto	0,42 m largo	1,55 m alto
Variantes	1 Arcilla / 2 Musgo	1 Trucha / 2 Carpa dorada	por FICHA (piel, pelo, ropa)
Objetos / mats	3 (o 6 con brazos por pares) / 3	6 / 4	8 / 6
Estilo cozy	Manto redondo, ojos como bultitos, brazos gruesos que reposan y curvan la punta	Cuerpo rechoncho, aletas redondeadas, ojito	Cabeza grande, manoplas sin dedos, botas redondas
1) PULPO — SM_Pulpo_Arrecife
Estructura: SM_Pulpo_Body (manto + cabeza + bultos oculares + membrana interbraquial), SM_Pulpo_Tentaculos (8 brazos, 16 loops cada uno) y SM_Pulpo_Eyes. Con TENTACULOS_POR_PAR = True los brazos salen en 4 objetos (frontal / derecho / izquierdo / trasero) para animarlos por pares sin pasar de 8 objetos.

Python

# ============================================================
#  SM_Pulpo_Arrecife — variante ALTA (pegar debajo del NÚCLEO + PARCHE)
# ============================================================
PREFIJO, RAIZ_NOMBRE, MAT_BASE = "Pulpo", "SM_Pulpo_Arrecife", "Piel"
VARIANTE_INICIAL   = 1
TENTACULOS_POR_PAR = False     # True -> 4 objetos de 2 brazos (6 obj en total)

SEG_MANTO, ANILLOS_MANTO = 28, 16
SEG_TENT,  ANILLOS_TENT  = 10, 16      # 16 loops por brazo: ondular / enroscar
SEG_FALDA                = 32          # múltiplo de 8: los lóbulos coinciden con los brazos
SEG_OJO,   ANILLOS_OJO   = 12, 6
N_TENT = 8

PALETA = {1: dict(principal=(178, 108, 80), vientre=(222, 180, 148), oscuro=(134, 74, 56)),   # Arcilla
          2: dict(principal=(122, 124, 92), vientre=(196, 190, 152), oscuro=( 84, 88, 62))}   # Musgo
COL_OJOS = (30, 20, 10)
TINT_V, TINT_P, TINT_O, tinte_dorsal = hacer_tintes(PALETA[1])

def aplicar_variante(n):
    m = MATS[f"MAT_{PREFIJO}_{MAT_BASE}_0{n}"]
    for o in OBJS_PELAJE: o.data.materials[0] = m

# ---------- perfiles (metros) ----------
MANTO_A, MANTO_B = Vector((0.0, 0.12, 0.20)), Vector((0.0, -0.24, 0.36))   # t: 0 cabeza -> 1 punta del manto
def path_manto(t):   return MANTO_A.lerp(MANTO_B, t)
def radios_manto(t):
    u = 2 * t - 1
    s = (1 - abs(u) ** 2.6) ** (1 / 2.6)
    k = 0.86 + 0.14 * smooth(t / 0.35)              # cabeza algo más estrecha que el manto
    return 0.15 * s * k, 0.15 * s * k

def dir_ojo(sg, t=0.22, ph=math.radians(48)):
    c = path_manto(t); rx, _ = radios_manto(t)
    side, up = frame(path_manto(t + 1e-3) - path_manto(t - 1e-3))
    return c, (side * sg * math.cos(ph) + up * math.sin(ph)).normalized(), rx

def ring_falda(z, r, lob):
    out = []
    for a in angs(SEG_FALDA):
        rr = r * (1 + lob * math.cos(N_TENT * a - math.pi))          # lóbulo en la base de cada brazo
        out.append(Vector((rr * math.cos(a), rr * math.sin(a), z)))
    return out

def ang_tent(i): return 2 * math.pi * i / N_TENT + math.pi / N_TENT
def radios_tent(t):
    rx = 0.009 + 0.036 * (1 - t) ** 1.15                              # punta con volumen (0,9 cm)
    return rx, rx * 0.85
def path_tent(i):
    th = ang_tent(i)
    d = Vector((math.cos(th), math.sin(th), 0.0)); s = Vector((-d.y, d.x, 0.0))
    fase = _h(i, 3, 7, 11) * 6.283
    def p(t):
        r  = 0.09 + 0.33 * t - 0.05 * t * t - 0.06 * max(0.0, (t - 0.80) / 0.20) ** 2   # la punta vuelve hacia dentro
        zb = 0.12 * max(0.0, (0.80 - t) / 0.80) ** 1.7 + 0.11 * max(0.0, (t - 0.80) / 0.20) ** 2  # baja al suelo y se levanta
        w  = 0.045 * t * math.sin(math.pi * 1.4 * t + fase)          # ondulación propia de cada brazo
        return d * r + s * w + Vector((0, 0, zb + radios_tent(t)[1]))  # la panza del brazo toca Z=0 en t=0.8
    return p

# ---------- tintes ----------
def tinte_manto(co, i):
    t, h = coord_local(co, path_manto, radios_manto)
    return tinte_dorsal(0.25 + 0.75 * (h + 1) / 2)
def tinte_tent(co, i):
    th = math.atan2(co.y, co.x)
    k = int(round((th - math.pi / N_TENT) / (2 * math.pi / N_TENT))) % N_TENT
    t, h = coord_local(co, path_tent(k), radios_tent, 24)
    return tinte_dorsal(0.08 + 0.62 * (h + 1) / 2)                     # cara inferior (ventosas) clara

# ---------- geometría ----------
def crear_cuerpo():
    bm = bmesh.new()
    curva_tubo(bm, path_manto, radios_manto, ANILLOS_MANTO, SEG_MANTO, 0.02, 0.98, True, True, coseno=True, punta=0.3)
    for sg in (-1, 1):                                                 # bultos oculares
        c, d, rx = dir_ojo(sg)
        add_elipsoide(bm, Vector((0.048, 0.048, 0.042)), 10, 5, tf_desplazar(c + d * rx * 0.90))
    build_tube(bm, [ring_falda(0.17, 0.125, 0.02), ring_falda(0.11, 0.19, 0.06), ring_falda(0.05, 0.245, 0.10)],
               None, Vector((0, 0, 0.05)))                             # membrana interbraquial, cerrada por debajo
    return bm

def crear_tentaculos(indices):
    bm = bmesh.new()
    for i in indices:
        curva_tubo(bm, path_tent(i), radios_tent, ANILLOS_TENT, SEG_TENT, 0.0, 1.0, False, True, punta=0.6)
    return bm

def crear_ojos():
    bm = bmesh.new()
    for sg in (-1, 1):
        c, d, rx = dir_ojo(sg)
        add_elipsoide(bm, Vector((0.027, 0.027, 0.027)), SEG_OJO, ANILLOS_OJO, tf_desplazar(c + d * (rx * 0.90 + 0.034)))
    return bm

# ---------- escena ----------
iniciar_escena(RAIZ_NOMBRE, 0.25, (0.8, 0, 0))
MATS = {f"MAT_{PREFIJO}_Piel_01": mat_pelaje(f"MAT_{PREFIJO}_Piel_01", PALETA[1], 0.55),   # piel húmeda: menos rugosa
        f"MAT_{PREFIJO}_Piel_02": mat_pelaje(f"MAT_{PREFIJO}_Piel_02", PALETA[2], 0.55),
        f"MAT_{PREFIJO}_Ojos":    mat_ojos(f"MAT_{PREFIJO}_Ojos", COL_OJOS)}
PEL = MATS[f"MAT_{PREFIJO}_Piel_0{VARIANTE_INICIAL}"]
PIV_BRAZOS, PIV_CABEZA = Vector((0, 0, 0.16)), path_manto(0.15)

OBJS_PELAJE = [crear_objeto("SM_Pulpo_Body", crear_cuerpo(), [PEL], tinte_manto)]
if TENTACULOS_POR_PAR:
    for nombre, idx in (("SM_Pulpo_Tent_Front", (1, 2)), ("SM_Pulpo_Tent_R", (0, 7)),
                        ("SM_Pulpo_Tent_L", (3, 4)),     ("SM_Pulpo_Tent_Back", (5, 6))):
        OBJS_PELAJE.append(crear_objeto(nombre, crear_tentaculos(idx), [PEL], tinte_tent, PIV_BRAZOS))
else:
    OBJS_PELAJE.append(crear_objeto("SM_Pulpo_Tentaculos", crear_tentaculos(range(N_TENT)), [PEL], tinte_tent, PIV_BRAZOS))
TODOS = OBJS_PELAJE + [crear_objeto("SM_Pulpo_Eyes", crear_ojos(), [MATS[f"MAT_{PREFIJO}_Ojos"]], None, PIV_CABEZA)]
estadisticas(RAIZ_NOMBRE)
Produce: ≈ 4.000 tris (Body ~1.250, brazos ~2.480, Eyes ~290), 3 objetos, 3 materiales. Envergadura ~0,7 m, alto ~0,5 m, brazos apoyados en Z = 0 con la punta levantada y curvada hacia dentro (gesto curioso). La cara inferior de cada brazo sale clara (ventosas sugeridas sin geometría).

2) PEZ — SM_Pez_Rio
Estructura: SM_Pez_Body (con pélvicas y anal integradas), SM_Pez_Tail (pedúnculo + 2 lóbulos, para el coletazo), SM_Pez_Fin_Dorsal, SM_Pez_Fin_Pec_L/R, SM_Pez_Eyes. Pivote en la panza (Z = 0) según convención; en Godot súbelo a la altura de nado.

Python

# ============================================================
#  SM_Pez_Rio — variante ALTA (pegar debajo del NÚCLEO + PARCHE)
# ============================================================
PREFIJO, RAIZ_NOMBRE, MAT_BASE = "Pez", "SM_Pez_Rio", "Escamas"
VARIANTE_INICIAL = 1
SEG_CUERPO, ANILLOS_CUERPO = 20, 18
SEG_ALETA,  ANILLOS_ALETA  = 10, 5
SEG_OJO,    ANILLOS_OJO    = 10, 5

PALETA = {1: dict(principal=(118, 116, 74), vientre=(222, 206, 172), oscuro=( 78, 80, 48)),   # Trucha
          2: dict(principal=(176, 130, 70), vientre=(232, 212, 170), oscuro=(126, 86, 44))}   # Carpa dorada
COL_OJOS, COL_ALETAS = (30, 20, 10), (196, 170, 124)
TINT_V, TINT_P, TINT_O, tinte_dorsal = hacer_tintes(PALETA[1])

def aplicar_variante(n):
    m = MATS[f"MAT_{PREFIJO}_{MAT_BASE}_0{n}"]
    for o in OBJS_PELAJE: o.data.materials[0] = m

# ---------- perfiles (metros) ----------
CZ = 0.096                                           # centro del cuerpo: las aletas pélvicas rozan Z=0
CUERPO_A, CUERPO_B = Vector((0, -0.15, CZ)), Vector((0, 0.16, CZ))   # t: 0 pedúnculo -> 1 hocico
def path_cuerpo(t):  return CUERPO_A.lerp(CUERPO_B, t)
def radios_cuerpo(t):
    u = 2 * t - 1
    s = (1 - abs(u) ** 1.9) ** (1 / 1.9) if u < 0 else (1 - u ** 2.8) ** (1 / 2.8)   # trasera afilada, frente redondo
    return 0.042 * s * (1 + 0.10 * t), 0.075 * s                                    # comprimido lateralmente

def path_ped(t):    return Vector((0, -0.135 - 0.065 * t, CZ))
def radios_ped(t):  return 0.014 - 0.003 * t, 0.024 - 0.006 * t

def tf_alinear(centro, dir, thin):
    """Eje local Z -> dir (largo de la aleta); eje local X -> thin (grosor)."""
    z = Vector(dir).normalized()
    x = Vector(thin) - z * Vector(thin).dot(z); x.normalize()
    M = Matrix((x, z.cross(x), z)).transposed()
    return lambda p: centro + M @ p

def aleta(bm, base, r, dir, thin=(1, 0, 0), mat=1):
    d = Vector(dir).normalized()
    add_elipsoide(bm, r, SEG_ALETA, ANILLOS_ALETA, tf_alinear(base + d * r.z * 0.9, d, thin), mat)   # 10 % embebida

# ---------- tintes ----------
def tinte_cuerpo(co, i):
    t, h = coord_local(co, path_cuerpo, radios_cuerpo)
    base = tinte_dorsal(smooth((h + 0.45) / 1.3))                      # vientre claro amplio, lomo oscuro
    mota = smooth((voronoi_borde(co, 0.035, 3) - 0.45) / 0.25) * smooth((h + 0.2) / 0.3)   # motas en el lomo
    return lerp(base, TINT_O, 0.6 * mota)

# ---------- geometría ----------
def crear_cuerpo():
    bm = bmesh.new()
    curva_tubo(bm, path_cuerpo, radios_cuerpo, ANILLOS_CUERPO, SEG_CUERPO, 0.03, 0.985, False, True, coseno=True, punta=0.3)
    for sg in (-1, 1):                                                 # pélvicas
        aleta(bm, Vector((sg * 0.02, 0.035, 0.0265)), Vector((0.003, 0.016, 0.020)), (sg * 0.35, -0.65, -0.68))
    aleta(bm, Vector((0, -0.07, 0.036)), Vector((0.003, 0.018, 0.024)), (0, -0.77, -0.64))   # anal
    return bm

def crear_cola():
    bm = bmesh.new()
    curva_tubo(bm, path_ped, radios_ped, 4, 10, 0.0, 1.0, False, False)
    for sg in (-1, 1):                                                 # lóbulos caudales
        aleta(bm, path_ped(1.0), Vector((0.004, 0.028, 0.055)), (0, -0.57, sg * 0.82))
    return bm

def crear_dorsal():
    bm = bmesh.new()
    aleta(bm, Vector((0, -0.005, CZ + 0.065)), Vector((0.004, 0.045, 0.035)), (0, -0.42, 0.91), mat=0)
    return bm

def crear_pectoral(sg):
    bm = bmesh.new()
    c = path_cuerpo(0.70); rx, _ = radios_cuerpo(0.70)
    aleta(bm, c + Vector((sg * rx * 0.9, 0, -0.02)), Vector((0.003, 0.020, 0.035)), (sg * 0.72, -0.55, -0.42), (0, 0.25, 1), 0)
    return bm

def crear_ojos():
    bm = bmesh.new()
    c = path_cuerpo(0.82); rx, rz = radios_cuerpo(0.82); ph = math.radians(15)
    for sg in (-1, 1):
        add_elipsoide(bm, Vector((0.013, 0.013, 0.013)), SEG_OJO, ANILLOS_OJO,
                      tf_desplazar(c + Vector((sg * rx * math.cos(ph) * 0.92, 0, rz * math.sin(ph) * 0.92))))
    return bm

# ---------- escena ----------
iniciar_escena(RAIZ_NOMBRE, 0.15, (0.5, 0, 0))
MATS = {f"MAT_{PREFIJO}_Escamas_01": mat_pelaje(f"MAT_{PREFIJO}_Escamas_01", PALETA[1], 0.45),   # brillo húmedo
        f"MAT_{PREFIJO}_Escamas_02": mat_pelaje(f"MAT_{PREFIJO}_Escamas_02", PALETA[2], 0.45),
        f"MAT_{PREFIJO}_Aletas":     mat_plano(f"MAT_{PREFIJO}_Aletas", COL_ALETAS, 0.55),
        f"MAT_{PREFIJO}_Ojos":       mat_ojos(f"MAT_{PREFIJO}_Ojos", COL_OJOS)}
ESC = MATS[f"MAT_{PREFIJO}_Escamas_0{VARIANTE_INICIAL}"]; ALE = MATS[f"MAT_{PREFIJO}_Aletas"]
PIV_COLA, PIV_CABEZA = Vector((0, -0.14, CZ)), Vector((0, 0.10, CZ))

OBJS_PELAJE = [crear_objeto("SM_Pez_Body", crear_cuerpo(), [ESC, ALE], tinte_cuerpo),
               crear_objeto("SM_Pez_Tail", crear_cola(),   [ESC, ALE], tinte_cuerpo, PIV_COLA)]
ALETAS = [crear_objeto("SM_Pez_Fin_Dorsal", crear_dorsal(),      [ALE], None, Vector((0, -0.005, CZ + 0.065))),
          crear_objeto("SM_Pez_Fin_Pec_L",  crear_pectoral(-1),  [ALE], None, path_cuerpo(0.70)),
          crear_objeto("SM_Pez_Fin_Pec_R",  crear_pectoral(1),   [ALE], None, path_cuerpo(0.70))]
TODOS = OBJS_PELAJE + ALETAS + [crear_objeto("SM_Pez_Eyes", crear_ojos(), [MATS[f"MAT_{PREFIJO}_Ojos"]], None, PIV_CABEZA)]
estadisticas(RAIZ_NOMBRE)
Produce: ≈ 1.700 tris, 6 objetos, 4 materiales. 0,42 m de largo, 0,23 m de alto. Lomo oliva con motas Voronoi (trucha) → vientre crema; la variante 2 reutiliza el mismo degradado en tonos dorados. Si quieres aletas translúcidas, en Godot pon transparency = ALPHA y albedo.a = 0.85 al material Aletas; en el GLB van opacas para no depender del orden de dibujado.

3) PERSONAJE NPC — SM_NPC_Granjera
Mismo motor, otra colección (COL_NPC) y sin vertex color (la ropa es color plano). Toda la identidad del personaje sale de FICHA; para crear otro NPC cambias la ficha y vuelves a ejecutar.

text

SM_NPC_<Nombre> (Empty, pies en Z=0)
├── SM_NPC_Body    torso + cuello   (slots: Camisa, Pantalon, Piel)
├── SM_NPC_Head    cabeza + nariz + orejas + sonrisa (Piel, Ojos)
├── SM_NPC_Hair    casquete de pelo con flequillo + moño opcional (Pelo)
├── SM_NPC_Arm_L / Arm_R   manga + manopla + pulgar (Camisa, Piel)
├── SM_NPC_Leg_L / Leg_R   pierna + bota (Pantalon, Botas)
└── SM_NPC_Eyes    (Ojos)
Mats: MAT_NPC_Piel_xx, MAT_NPC_Pelo_xx, MAT_NPC_Camisa_xx, MAT_NPC_Pantalon_xx, MAT_NPC_Botas_xx, MAT_NPC_Ojos  (6)
Python

# ============================================================
#  SM_NPC_<Nombre> — personaje NPC cozy (pegar debajo del NÚCLEO + PARCHE)
# ============================================================
FICHA = dict(id="01", nombre="Granjera",
             piel=(226, 184, 150), pelo=(112, 72, 42), camisa=(178, 142, 90),
             pantalon=(98, 90, 72), botas=(86, 60, 42), ojos=(40, 28, 18),
             pelo_largo=True)                    # moño en la nuca
RAIZ_NOMBRE = f"SM_NPC_{FICHA['nombre']}"

SEG_TORSO = 24
SEG_CABEZA, ANILLOS_CABEZA = 20, 12
SEG_EXTR,   ANILLOS_EXTR   = 12, 10
SEG_PELO,   ANILLOS_PELO   = 20, 8
SEG_OJO,    ANILLOS_OJO    = 10, 5

# ---- proporciones (m): figura de ~5 cabezas, 1,55 m ----
CABEZA_C, CABEZA_R = Vector((0, 0, 1.40)), Vector((0.105, 0.112, 0.125))
TORSO = [(0.76, 0.160, 0.110), (0.86, 0.165, 0.115), (0.94, 0.140, 0.100), (1.05, 0.155, 0.110),   # (z, rx, ry)
         (1.15, 0.175, 0.115), (1.22, 0.200, 0.110), (1.255, 0.120, 0.095), (1.275, 0.058, 0.058), (1.33, 0.058, 0.058)]
Z_CINTURON, Z_CUELLO = 0.93, 1.27
HOMBRO = lambda sg: Vector((sg * 0.19, 0.0, 1.20))
CADERA = lambda sg: Vector((sg * 0.088, 0.0, 0.82))
PIV_CUELLO = Vector((0, 0, 1.29))

# ---------- geometría ----------
def crear_torso():
    bm = bmesh.new()
    rings = [ring_Z(0, 0, z, rx, ry, SEG_TORSO) for z, rx, ry in TORSO]
    build_tube(bm, rings, Vector((0, 0, TORSO[0][0] - 0.02)), Vector((0, 0, TORSO[-1][0] + 0.02)))
    for f in bm.faces:
        zm = sum(v.co.z for v in f.verts) / len(f.verts)
        f.material_index = 1 if zm < Z_CINTURON else (2 if zm > Z_CUELLO else 0)   # 0 camisa, 1 pantalón, 2 piel
    return bm

def crear_cabeza():
    bm = bmesh.new()
    add_elipsoide(bm, CABEZA_R, SEG_CABEZA, ANILLOS_CABEZA, tf_desplazar(CABEZA_C))
    add_elipsoide(bm, Vector((0.016, 0.020, 0.015)), 8, 4, tf_desplazar(CABEZA_C + Vector((0, 0.108, -0.012))))   # nariz
    for sg in (-1, 1):
        add_elipsoide(bm, Vector((0.012, 0.024, 0.030)), 8, 4, tf_desplazar(CABEZA_C + Vector((sg * 0.104, -0.005, -0.005))))  # orejas
    add_elipsoide(bm, Vector((0.024, 0.005, 0.006)), 8, 3, tf_desplazar(CABEZA_C + Vector((0, 0.100, -0.052))), 1)   # sonrisa
    return bm

def crear_pelo():
    bm = bmesh.new(); R = CABEZA_R * 1.08
    def ph_max(a):                                   # borde: flequillo alto delante, nuca baja detrás, leve ondulación
        return math.radians(100 - 32 * math.sin(a) + 6 * math.cos(3 * a))
    def punto(a, ph):
        return CABEZA_C + Vector((R.x * math.sin(ph) * math.cos(a), R.y * math.sin(ph) * math.sin(a), R.z * math.cos(ph)))
    rings = [[punto(a, ph_max(a) * k / ANILLOS_PELO) for a in angs(SEG_PELO)] for k in range(1, ANILLOS_PELO + 1)]
    build_tube(bm, rings, CABEZA_C + Vector((0, 0, R.z)), None)               # casquete abierto por abajo
    if FICHA["pelo_largo"]:
        add_elipsoide(bm, Vector((0.05, 0.05, 0.06)), 10, 5, tf_desplazar(CABEZA_C + Vector((0, -0.11, 0.03))))   # moño
    return bm

def path_brazo(sg):
    A, B, C = HOMBRO(sg), Vector((sg * 0.235, 0.03, 0.99)), Vector((sg * 0.245, 0.085, 0.80))
    return lambda t: A * (1 - t) ** 2 + B * 2 * t * (1 - t) + C * t * t   # ligera flexión de codo hacia delante
def radios_brazo(t):
    r = 0.052 - 0.014 * t; return r, r
def crear_brazo(sg):
    bm = bmesh.new()
    curva_tubo(bm, path_brazo(sg), radios_brazo, ANILLOS_EXTR, SEG_EXTR, 0.0, 1.0, True, True, punta=0.2)
    m = path_brazo(sg)(1.0) + Vector((0, 0.015, -0.045))
    add_elipsoide(bm, Vector((0.040, 0.050, 0.058)), 10, 5, tf_desplazar(m), 1)                              # manopla
    add_elipsoide(bm, Vector((0.016, 0.022, 0.028)), 6, 3, tf_desplazar(m + Vector((-sg * 0.030, 0.030, 0.015))), 1)  # pulgar
    return bm

def crear_pierna(sg):
    bm = bmesh.new(); x = sg * 0.088
    spec = [(0.84, 0.095, 0.0), (0.70, 0.088, 0.005), (0.56, 0.078, 0.010), (0.44, 0.072, 0.020),   # (z, r, dy) rodilla insinuada
            (0.32, 0.068, 0.010), (0.20, 0.064, 0.0), (0.12, 0.066, 0.0)]
    rings = [ring_Z(x, dy, z, r, r * 1.05, SEG_EXTR) for z, r, dy in spec]
    build_tube(bm, rings, None, None)                                          # abierta arriba (dentro del torso) y abajo (dentro de la bota)
    for f in bm.faces:
        if sum(v.co.z for v in f.verts) / 4 < 0.26: f.material_index = 1      # caña de la bota
    add_elipsoide(bm, Vector((0.070, 0.118, 0.060)), 12, 6, tf_desplazar(Vector((x, 0.045, 0.060))), 1)   # bota, suela en Z=0
    return bm

def crear_ojos():
    bm = bmesh.new()
    for sg in (-1, 1):
        add_elipsoide(bm, Vector((0.017, 0.017, 0.017)), SEG_OJO, ANILLOS_OJO, tf_desplazar(CABEZA_C + Vector((sg * 0.042, 0.097, 0.012))))
    return bm

# ---------- escena ----------
iniciar_escena(RAIZ_NOMBRE, 0.3, (0.8, 0, 0))
COL_FAUNA.name = "COL_NPC"
i = FICHA["id"]
MATS = {"Piel":     mat_plano(f"MAT_NPC_Piel_{i}",     FICHA["piel"],     0.60),
        "Pelo":     mat_plano(f"MAT_NPC_Pelo_{i}",     FICHA["pelo"],     0.55),
        "Camisa":   mat_plano(f"MAT_NPC_Camisa_{i}",   FICHA["camisa"],   0.85),
        "Pantalon": mat_plano(f"MAT_NPC_Pantalon_{i}", FICHA["pantalon"], 0.85),
        "Botas":    mat_plano(f"MAT_NPC_Botas_{i}",    FICHA["botas"],    0.70),
        "Ojos":     mat_ojos("MAT_NPC_Ojos", FICHA["ojos"])}
M = MATS
TODOS = [crear_objeto("SM_NPC_Body",  crear_torso(),     [M["Camisa"], M["Pantalon"], M["Piel"]], None, Vector((0, 0, 0.80))),
         crear_objeto("SM_NPC_Head",  crear_cabeza(),    [M["Piel"], M["Ojos"]],  None, PIV_CUELLO),
         crear_objeto("SM_NPC_Hair",  crear_pelo(),      [M["Pelo"]],             None, PIV_CUELLO),
         crear_objeto("SM_NPC_Arm_L", crear_brazo(-1),   [M["Camisa"], M["Piel"]], None, HOMBRO(-1)),
         crear_objeto("SM_NPC_Arm_R", crear_brazo(1),    [M["Camisa"], M["Piel"]], None, HOMBRO(1)),
         crear_objeto("SM_NPC_Leg_L", crear_pierna(-1),  [M["Pantalon"], M["Botas"]], None, CADERA(-1)),
         crear_objeto("SM_NPC_Leg_R", crear_pierna(1),   [M["Pantalon"], M["Botas"]], None, CADERA(1)),
         crear_objeto("SM_NPC_Eyes",  crear_ojos(),      [M["Ojos"]],             None, PIV_CUELLO)]
estadisticas(RAIZ_NOMBRE)
Produce: ≈ 3.300 tris, 8 objetos, 6 materiales, 1,55 m de alto (1,56 con el moño), pies en Z = 0, mirando a +Y (−Z en Godot). Postura en A suave (brazos ligeramente separados y flexionados), lista para riggear con un esqueleto humanoide estándar: los pivotes ya están en cadera, hombros, cuello.

Más NPCs con la misma receta
Cambia FICHA y ejecuta de nuevo (cada uno con su id para que los materiales no colisionen):

id	nombre	piel	pelo	camisa	pantalón	botas	pelo_largo
01	Granjera	(226,184,150)	(112,72,42)	(178,142,90)	(98,90,72)	(86,60,42)	True
02	Pescador	(198,150,118)	(84,74,66)	(116,128,120)	(78,70,60)	(64,52,44)	False
03	Herrera	(168,120,92)	(52,40,34)	(150,92,70)	(70,62,58)	(58,44,36)	True
04	Niño	(232,196,164)	(188,140,80)	(160,158,112)	(110,96,78)	(92,68,50)	False → baja CABEZA_R ×1.1 y TORSO/piernas ×0.8
Variables útiles para diferenciar siluetas sin tocar la geometría: CABEZA_R (cabeza más grande = más joven), TORSO (barriga: sube rx/ry en z 0.86–1.05), ph_max (flequillo, raya, pelo corto: 100 − 32·sin → 85 − 20·sin), pelo_largo (moño) y el radio de radios_brazo. Un sombrero de paja son 2 líneas: add_elipsoide(r=(0.19,0.19,0.012)) + (0.10,0.10,0.06) sobre CABEZA_C + (0,0,0.12) en crear_pelo (usa el slot Pelo o añade MAT_NPC_Accesorio si te sobra material).

Validación y Godot (las tres piezas)
Mismo checklist automático que la fauna anterior: remove_doubles, normales recalculadas, escala 1, pies/panza/brazos en Z = 0, extremos abiertos donde una parte entra en otra, simetría analítica, sin subsurf. La consola imprime tris/objetos/materiales/dimensiones.
exportar_glb(ruta) en cualquiera de los tres. Pulpo y pez llevan COLOR_0 (activa Vertex Color → Use as Albedo si el importador no lo hace); el NPC no usa vertex color.
Pelo del NPC: el casquete es una lámina de una cara. Si vas a ver al personaje desde abajo (cámara a 2 m no lo hará), añade Solidify 0.01 al objeto SM_NPC_Hair antes de exportar (Apply Modifiers ON lo hornea).
Colisiones: pulpo SphereShape r 0,25 en (0, 0.22, 0); pez CapsuleShape r 0,07 / alto 0,38 tumbada; NPC CapsuleShape r 0,25 / alto 1,5 en (0, 0.78, 0).
Pivote del pez en la panza por convención: en Godot ponlo a la altura de nado y rota sobre el nodo raíz; si prefieres girar sobre el centro de masa, cambia todos los CZ por 0.0 y súbelo desde GDScript.
MEDIA/BAJA: pulpo → Decimate 0.35 / 0.17 y Join de ojos al cuerpo (BAJA: brazos + cuerpo en uno, 2 obj); pez → ya cumple MEDIA (≤1.500 tris con Decimate 0.85); BAJA: Join de aletas al cuerpo, cola aparte (2 obj, 3 mats quitando Ojos con vertex color). NPC → MEDIA: Body+Legs, Head+Hair+Eyes, Arm_L, Arm_R; BAJA: todo en uno salvo cabeza, y funde Botas en Pantalon.


# Prompt para Modelado Blender — Nutria de Ribera (Isla Ancestral)

Copia desde "INICIO DEL PROMPT" hasta "FIN DEL PROMPT" y pégalo en el modelo que vayas a usar.

---

## INICIO DEL PROMPT

Necesito que me models una **Nutria de Ribera** en Blender para un videojuego indie de estilo **cozy/relajado** (sin combate, sin estrés). El motor es **Godot 4.7.2** y el formato de exportación es **GLB**.

### Contexto del Proyecto

El juego se llama **Isla Ancestral**. Es un sandbox cozy donde el jugador cultiva una isla, explora, conoce vecinos NPCs y descubre fauna. La estética es:
- **Stylized pero con anatomía realista** — no es cartoon exagerado, ni realismo fotorrealista. Punto medio: formas orgánicas suaves, proporciones ligeramente redondeadas, colores cálidos y terrosos.
- **Paleta de colores**: tierra, ocres, verdes apagados, marrones cálidos. Nada de neones ni colores saturados.
- **Inspiración**: estética de Stardew Valley / Animal Crossing pero en 3D low-poly cuidado.
- **Tono**: acogedor, cálido, natural. La nutria debe verse amigable y curiosa, no agresiva ni realista dura.

### Especificaciones de la Especie

| Dato | Valor |
|------|-------|
| Nombre | Nutria de Ribera (*Lutra lutra*) |
| Clase | Anfibia (opera en tierra y agua) |
| Comportamiento | Curiosa (se acerca al jugador, no huye) |
| Bioma | Ribera (orillas de ríos, zonas pantanosas) |
| Rareza | Poco Común |
| Horario | Diurna |
| Escala | 0.6–0.9 (un poco más chica que un conejo grande) |
| Variantes de color | 2: marrón chocolate cálido / marrón oscuro |
| Velocidad | Deambular lenta (1.2), huida media (4.0) |

### Referencia Anatómica (real)

La nutria real tiene:
- Cuerpo alargado y flexible (aspecto "cilíndrico" pero suave)
- Patas cortas con membranas entre los dedos (para nadar)
- Cabeza ancha y achatada con hocico corto
- Ojos pequeños y redondos, orejas diminutas
- Cola larga, gruesa en la base y afilada en la punta (aprox. 40% del cuerpo)
- Pelaje denso y brillante (en 3D se sugiere con variaciones de color, no con pelo real)
- Pose típica: encorvada o "S" cuando está en reposo, erguida cuando está curiosa

### Estructura del Mesh

```
SM_Nutria_Ribera
├── SM_Nutria_Body          ← Cuerpo principal (torso + cabeza como continuidad)
├── SM_Nutria_Head          ← Cabeza separada (para animaciones de mirada)
├── SM_Nutria_Leg_FL        ← Pata delantera izquierda
├── SM_Nutria_Leg_FR        ← Pata delantera derecha
├── SM_Nutria_Leg_BL        ← Pata trasera izquierda
├── SM_Nutria_Leg_BR        ← Pata trasera derecha
├── SM_Nutria_Tail          ← Cola (para animación de balanceo)
└── SM_Nutria_Eyes          ← Ojos (2 small spheres, material emisivo sutil)
```

### Presupuesto Poligonal (budget del juego)

| Variante | Triángulos máximos | Objetos máx | Materiales máx |
|----------|-------------------|-------------|----------------|
| ALTA (hero) | ≤ 6,000 tris | ≤ 8 obj | ≤ 6 mats |
| MEDIA | ≤ 1,500 tris | ≤ 4 obj | ≤ 4 mats |
| BAJA (low) | ≤ 700 tris | ≤ 3 obj | ≤ 3 mats |

**Empieza por la variante ALTA** (la más detallada). Después generaremos las variantes MEDIA y BAJA con decimate.

### Convenciones de Naming (OBLIGATORIO)

```
SM_Nutria_Ribera          ← Mesh principal
MAT_Nutria_Pelaje_01      ← Material pelaje variante 1
MAT_Nutria_Pelaje_02      ← Material pelaje variante 2
MAT_Nutria_Ojos           ← Material ojos
COL_Fauna                 ← Colección donde va todo
```

- Prefijo `SM_` para meshes (Static Mesh)
- Prefijo `MAT_` para materiales
- Todo en mayúsculas con guiones bajos
- Los ojos van en un material separado (pueden tener emission sutil para que se noten)

### Paleta de Colores (Referencia)

**Variante 1 — Marrón Chocolate:**
- Pelaje principal: RGB(140, 97, 72) → #8C6148
- Pelaje vientre: RGB(180, 140, 110) → #B48C6E
- Pelaje oscuro (espalda): RGB(100, 68, 48) → #644430
- Ojos: RGB(30, 20, 10) → #1E140A (casi negro)
- Nariz: RGB(50, 35, 25) → #322319

**Variante 2 — Marrón Oscuro:**
- Pelaje principal: RGB(107, 76, 61) → #6B4C3D
- Pelaje vientre: RGB(150, 115, 90) → #96735A
- Pelaje oscuro: RGB(70, 48, 35) → #463023
- Ojos y nariz: igual que variante 1

### Flujo de Trabajo (Blender)

1. **Escena Setup:**
   - Colección `COL_Fauna`
   - Agrega un cubo de referencia de 1m en el origen (para escala)
   - La nutria debe medir ~0.7m de largo total (cuerpo + cola) en pose neutra
   - Centro de pivote en la base del cuerpo (pies tocando el suelo)

2. **Blockout:**
   - Empieza con primitivas (esferas UV, cilindros)
   - Cuerpo: esfera UV alargada en Z (forma de salchicha suave)
   - Cabeza: esfera UV ligeramente achatada, conectada al cuerpo
   - Patas: cilindros bajos con 8 lados
   - Cola: cono alargado o esfera UV estirada
   - **NO uses subsurf todavía** — trabaja con geometría controlada

3. **Refinamiento:**
   - Une las patas al cuerpo con bridge edge loops o merge
   - Suaviza las transiciones cabeza-cuerpo
   - Define la forma de la cola (grosor variable: gruesa en base, fina en punta)
   - Ojos: dos esferas UV pequeñas separadas del mesh principal
   - Nariz: triangula o inset en el hocico

4. **Detalles de Superficie:**
   - Usa **edge loops** para definir musculatura sutil (hombros, caderas)
   - La cola debe tener al menos 4-5 edge loops para poder animarla
   - Patas: dedos sugiriéndose con inset + extrude, NO modelados individualmente
   - Orejas: pequeñas protuberancias en la cabeza, NO modeladas separadas

5. **Materiales (Principled BSDF → GLTF PBR):**
   - Pelaje: Base Color = variante correspondiente, Roughness 0.7-0.8, Metallic 0.0
   - Ojos: Base Color = casi negro, Roughness 0.2, Emission sutil (0.05-0.1) en color cálido
   - Nariz: Base Color = muy oscuro, Roughness 0.4
   - **NO uses subdivision surface** — el estilo del juego es low-poly controlado

6. **Organización Final:**
   - Todos los meshes como hijos de un Empty vacío llamado `SM_Nutria_Ribera`
   - Aplica transformaciones (Ctrl+A → All Transforms)
   - Verifica que no haya vértices duplicados (M → Merge by Distance)
   - Verifica normales (Shift+N para recalcular outside)
   - Nombra todo correctamente según las convenciones

### Checklist de Validación (antes de exportar)

- [ ] Triángulos ≤ 6,000 (usa Shift+Z en viewport → Statistics)
- [ ] Objetos ≤ 8
- [ ] Materiales ≤ 6
- [ ] Sin vértices sueltos (Select All → M → By Distance)
- [ ] Sin caras internas (backfaces)
- [ ] Normales outward
- [ ] Transformaciones aplicadas (scale 1,1,1)
- [ ] Pivote en base del cuerpo (pies en Z=0)
- [ ] La nutria mide ~0.7m de largo total
- [ ] Se ve bien desde ángulo de cámara 3/4 (la vista principal del juego)

### Exportación GLB (para Godot)

```
Formato: GLB
+Y Up
Apply Modifiers: ON
Animation: OFF (por ahora)
Path Mode: Copy (embed textures si las hubiera)
```

### Referencias Visuales (descripción)

Busca en Google Images:
- "otter 3d model low poly" — para la forma general
- "otter concept art cozy" — para el estilo
- "otter side view anatomy" — para proporciones
- "river otter face close up" — para la cara

La referencia principal es una nutria europea (*Lutra lutra*) pero con el estilo suavizado del proyecto.

### Errores Comunes a Evitar

1. **NO hagas la cola demasiado delgada** — en el juego se ve desde lejos, necesita volumen
2. **NO modeles pelo real** — el estilo es mesh limpio con materiales
3. **NO hagas los ojos demasiado grandes** — que se vean naturales, no cartoon
4. **NO olvides que es anfibia** — las patas deben verse funcionales en agua Y en tierra
5. **NO uses symmetrize automático al final** — verifica manualmente que la simetría se vea bien
6. **NO excedas el polycount** — si vas bien de polígonos, mejor. Menos es más en este estilo

### Resultado Esperado

Un archivo `.blend` con:
- Colección `COL_Fauna` organizada
- 8 objetos nombrados correctamente
- 3 materiales (pelaje variante 1, pelaje variante 2, ojos)
- Silueta reconocible como nutria desde cualquier ángulo
- Estilo cozy coherente con el proyecto

## FIN DEL PROMPT

---

## Notas Adicionales (contexto extra)

- Exportamos a GLB, no FBX
- Godot 4.7.2 con GDScript
- El juego es first-person/third-person, la cámara está a ~2m del suelo
- Los animales se ven principalmente desde arriba y desde el lado (vista 3/4)
- El poligonal total del juego es bajo — optimización es clave
- No necesitamos rig ni animaciones en este paso (eso viene después)
- La variante 1 es la "estándar" (más común), la variante 2 es la "oscura" (poco común)
- Ambas deben verse bien juntas en el mismo bioma
