Vamos con **las casas 2, 3, 4 y 5**, usando un generador por lotes y la misma base técnica de la choza.

Para que la guía siga siendo manejable, esta entrega construye **las cuatro casas completas en una primera pasada ALTA**: estructura, huecos reales, cubierta, distribución y mobiliario principal. También incluye exportación, capturas y LOD automáticos.

**No voy a presentar como terminados detalles que el código no construye:** las tallas ancestrales elaboradas, estampados florales, ropa colgada detallada y el pulido de algunos muebles quedan para una segunda pasada artística.

## Decisiones comunes

- Coordenadas: `X=0…largo`, `Y=0…ancho`; fachada hacia **+Y**.
- `z_min = 0.045`.
- Alturas de puertas, muebles y cubierta medidas desde el **piso terminado**.
- Aleros, pórticos y patio pueden sobresalir de la huella de las paredes.
- Ocho materiales compartidos; colores particulares mediante `COLOR_0`.
- Los muebles no enumerados como objetos independientes se incorporan a conjuntos. Sus posiciones de interacción se registran en JSON.
- La cubierta de estas cuatro casas tiene **cumbrera paralela a X**: así existe una vertiente frontal donde colocar las claraboyas.
- Las claraboyas son **aberturas triangulares en la cubierta**, no simples triángulos pegados encima.
- MEDIA y BAJA se obtienen midiendo triángulos, no suponiendo que un porcentaje fijo cumple el presupuesto.

### Ajustes de distribución

**Casa 2:** la puerta exterior en `X=5.50` desemboca en el lado derecho, como dicta tu posición. Eso significa que se entra primero al dormitorio. Si prefieres entrada por sala, después moveremos la puerta o invertiremos los ambientes.

**Mansión:** las superficies aproximadas de los ambientes necesitan reorganización para caber dentro de 14 × 10 m. Utilizo dos alas y una franja central de comedor/circulación. La torre queda dentro de la esquina posterior derecha.

---

# 1. Archivos necesarios

Guarda el script de la choza anterior como:

```text
crear_casa_01_choza.py
```

Y este nuevo script al lado:

```text
crear_casas_02_05.py
```

El generador reutiliza **solo las primitivas de geometría** de la choza; no ejecuta su construcción ni su exportación.

Ejecuta:

```bash
blender --background --factory-startup --python crear_casas_02_05.py
```

> Ejecuta en una instancia dedicada: se limpia la sesión entre casas. Los resultados se guardan en `CASAS_EXPORT`.

---

# 2. Generador de las cuatro casas

```python
# ================================================================
# CASAS 02–05 — GENERADOR POR LOTES
# Blender 4.2+
#
# Requiere crear_casa_01_choza.py de la entrega anterior.
# Reutiliza solo sus primitivas, no ejecuta aquella casa.
#
# Construye ALTA y genera MEDIA/BAJA independientes.
# No incluye colisiones, scripts de interaccion ni navegacion.
# ================================================================

import bpy
import bmesh
import math
import json
import random
import traceback

from pathlib import Path
from datetime import datetime
from mathutils import Vector, Matrix


# ---------------- CONFIGURACION ----------------

CARPETA_SCRIPT = (
    Path(__file__).resolve().parent
    if "__file__" in globals()
    else Path(bpy.path.abspath("//"))
)

ARCHIVO_BASE = CARPETA_SCRIPT / "crear_casa_01_choza.py"
SALIDA_BASE = Path.home() / "CASAS_EXPORT"

# None = casas 2, 3, 4 y 5.
SOLO_CASAS = None

GENERAR_LODS = True
CAPTURAS_EXTERIORES = True
CAPTURAS_INTERIORES = True
RESOLUCION = 1024

Z_MIN = 0.045
SEMILLA = 42

CASAS = [
    dict(
        id=2, nombre="CASA_MEDIANA",
        L=8.0, W=6.0, base=0.25,
        pared=0.12, altura=2.60, cumbrera=3.40,
        puerta_x=5.50, puerta_w=1.00, puerta_h=2.10,
        alero=0.30, max_obj=18,
    ),
    dict(
        id=3, nombre="CASONA",
        L=10.0, W=8.0, base=0.30,
        pared=0.12, altura=2.60, cumbrera=3.60,
        puerta_x=5.00, puerta_w=1.00, puerta_h=2.10,
        alero=0.30, max_obj=20,
    ),
    dict(
        id=4, nombre="MANSION",
        L=14.0, W=10.0, base=0.40,
        pared=0.15, altura=2.80, cumbrera=3.80,
        puerta_x=7.00, puerta_w=1.20, puerta_h=2.20,
        alero=0.50, max_obj=24,
    ),
    dict(
        id=5, nombre="CASA_VECINO",
        L=7.0, W=5.0, base=0.15,
        pared=0.12, altura=2.60, cumbrera=3.20,
        puerta_x=2.50, puerta_w=1.00, puerta_h=2.10,
        alero=0.30, max_obj=14,
    ),
]

# Ocho familias PBR. El color particular vive en COLOR_0.
WOOD, STONE, THATCH, FABRIC, METAL, TRANS, CLAY, LEAF = range(8)

FAMILIAS = [
    ("MAT_MADERA", 0.86, 0.0, 1.0),
    ("MAT_PIEDRA", 0.95, 0.0, 1.0),
    ("MAT_PAJA", 0.95, 0.0, 1.0),
    ("MAT_TELA", 0.82, 0.0, 1.0),
    ("MAT_METAL", 0.60, 0.65, 1.0),
    ("MAT_TRANSLUCIDO", 0.65, 0.0, 0.65),
    ("MAT_BARRO", 0.90, 0.0, 1.0),
    ("MAT_VEGETAL", 0.90, 0.0, 1.0),
]

COLORES = {
    "madera": (180,140,90),
    "oscura": (90,65,40),
    "media": (140,105,65),
    "uniforme": (170,130,85),
    "paja": (210,180,120),
    "paja_osc": (170,140,80),
    "paja_naranja": (200,160,100),
    "piedra": (130,125,120),
    "piedra_osc": (90,85,80),
    "piedra_clara": (160,155,150),
    "tela": (200,190,170),
    "azul": (120,140,170),
    "lona": (190,175,150),
    "tela_osc": (70,60,55),
    "cuero": (120,80,45),
    "metal": (70,70,75),
    "bronce": (160,113,70),
    "barro": (150,110,70),
    "verde": (80,120,60),
    "verde_osc": (62,92,48),
    "vidrio": (150,170,200),
    "cuerda": (140,120,80),
    "cera": (222,204,159),
}


# ---------------- IMPORTAR PRIMITIVAS ----------------

if not ARCHIVO_BASE.exists():
    raise FileNotFoundError(
        f"Falta {ARCHIVO_BASE}. Guarda el script de la choza."
    )

fuente = ARCHIVO_BASE.read_text(encoding="utf-8")
marcador = "# ---------------- CIMIENTO ----------------"

if marcador not in fuente:
    raise RuntimeError("La version del script base no coincide.")

ns = {"__name__": "primitivas_casas"}
exec(compile(fuente.split(marcador)[0], str(ARCHIVO_BASE), "exec"), ns)

Pieza = ns["Pieza"]
rgba_lineal = ns["rgba_lineal"]


# ---------------- CONSTRUCTOR ----------------

class Casa:
    def __init__(self, ficha):
        self.f = ficha
        self.L = ficha["L"]
        self.W = ficha["W"]
        self.F = Z_MIN + ficha["base"]
        self.H = self.F + ficha["altura"]
        self.R = self.F + ficha["cumbrera"]
        self.piezas = {}
        self.interacciones = []
        self.huecos = []
        self.avisos = []
        self.rng = random.Random(SEMILLA + ficha["id"])

    def pieza(self, nombre):
        nombre = "SM_" + nombre
        if nombre not in self.piezas:
            self.piezas[nombre] = Pieza(nombre)
        return self.piezas[nombre]

    def color(self, clave, factor=1.0):
        return rgba_lineal([
            c*factor for c in COLORES[clave]
        ])

    def geometria(self, grupo, vertices, caras, mat, col):
        p = self.pieza(grupo)
        inicio = len(p.caras)
        p.agregar(vertices, caras, mat)
        p.colores[inicio:] = [self.color(col)] * (len(p.caras)-inicio)

    def caja(self, grupo, centro, tam, mat=WOOD,
             col="madera", radio=0.0):
        if min(tam) <= 0:
            return
        p = self.pieza(grupo)
        inicio = len(p.caras)
        p.caja(centro, tam, mat, radio=radio)
        p.colores[inicio:] = [self.color(col)] * (len(p.caras)-inicio)

    def tubo(self, grupo, a, b, r, mat=WOOD,
             col="oscura", n=8):
        p = self.pieza(grupo)
        inicio = len(p.caras)
        p.tubo(a, b, r, mat, n)
        p.colores[inicio:] = [self.color(col)] * (len(p.caras)-inicio)

    def interactivo(self, id_, grupo, x, y, tipo):
        self.interacciones.append({
            "id": id_,
            "mesh": "SM_"+grupo,
            "tipo": tipo,
            "posicion_blender": [x,y,self.F],
            "posicion_godot": [x,self.F,-y],
        })

    def marco(self, grupo, eje, fijo, a, b, z0, z1):
        # Marco exterior al vano, no reduce la abertura.
        if eje == "X":
            for x in (a-0.035,b+0.035):
                self.caja(grupo,(x,fijo,(z0+z1)/2),
                          (0.07,0.17,z1-z0),"", "") if False else None
                self.caja(grupo,(x,fijo,(z0+z1)/2),
                          (0.07,0.17,z1-z0),WOOD,"oscura")
            self.caja(grupo,((a+b)/2,fijo,z1+0.035),
                      (b-a+0.14,0.17,0.07),WOOD,"oscura")
        else:
            for y in (a-0.035,b+0.035):
                self.caja(grupo,(fijo,y,(z0+z1)/2),
                          (0.17,0.07,z1-z0),WOOD,"oscura")
            self.caja(grupo,(fijo,(a+b)/2,z1+0.035),
                      (0.17,b-a+0.14,0.07),WOOD,"oscura")

    def pared(self, grupo, eje, fijo, longitud, huecos=(),
              origen=0.0, interior=False):
        grosor = self.f["pared"]
        cortes = {origen,origen+longitud}
        cantidad = math.ceil(longitud/0.50)

        cortes.update(
            origen+longitud*i/cantidad for i in range(cantidad+1)
        )
        for a,b,z0,z1,tipo in huecos:
            cortes.update((a,b))

        cortes = sorted(cortes)
        color = "uniforme" if self.f["id"] == 5 else "madera"

        for a,b in zip(cortes[:-1],cortes[1:]):
            if b <= origen or a >= origen+longitud:
                continue

            medio = (a+b)/2
            tramos = [(self.F,self.H)]

            for h0,h1,z0,z1,tipo in huecos:
                if h0 <= medio <= h1:
                    nuevos = []
                    for t0,t1 in tramos:
                        if z0 > t0:
                            nuevos.append((t0,min(t1,z0)))
                        if z1 < t1:
                            nuevos.append((max(t0,z1),t1))
                    tramos = [(u,v) for u,v in nuevos if v-u > 1e-5]

            for z0,z1 in tramos:
                if eje == "X":
                    c=((a+b)/2,fijo,(z0+z1)/2)
                    t=(b-a,grosor,z1-z0)
                else:
                    c=(fijo,(a+b)/2,(z0+z1)/2)
                    t=(grosor,b-a,z1-z0)

                self.caja(grupo,c,t,WOOD,color)

        for a,b,z0,z1,tipo in huecos:
            self.marco(grupo,eje,fijo,a,b,z0,z1)
            self.huecos.append({
                "grupo":"SM_"+grupo,
                "tipo":tipo,
                "ancho":b-a,
                "alto":z1-z0,
            })

            if tipo == "VENTANA":
                # Cortina interior ligeramente separada.
                if eje == "X":
                    verts=[
                        (a,fijo,z0),(b,fijo,z0),
                        (b,fijo,z1),(a,fijo,z1)
                    ]
                else:
                    verts=[
                        (fijo,a,z0),(fijo,b,z0),
                        (fijo,b,z1),(fijo,a,z1)
                    ]
                self.geometria(grupo,verts,[(0,1,2,3)],TRANS,"tela")

    def suelo(self, grupo, x0,x1,y0,y1, piedra=False):
        n = 4
        paso=(y1-y0)/n
        for i in range(n):
            self.caja(
                grupo,((x0+x1)/2,y0+(i+0.5)*paso,self.F-0.035),
                (x1-x0,paso,0.07),
                STONE if piedra else WOOD,
                "piedra" if piedra else "madera"
            )

    def z_techo(self,y):
        return self.R-(self.R-self.H)*abs(y-self.W/2)/(self.W/2)

    def panel_techo(self,grupo,x0,x1,y0,y1,col="paja",elev=0.0):
        z=lambda y:self.z_techo(y)+elev
        v=[
            (x0,y0,z(y0)),(x1,y0,z(y0)),
            (x1,y1,z(y1)),(x0,y1,z(y1)),
            (x0,y0,z(y0)+0.12),(x1,y0,z(y0)+0.12),
            (x1,y1,z(y1)+0.12),(x0,y1,z(y1)+0.12)
        ]
        f=[(0,3,2,1),(4,5,6,7),(0,1,5,4),
           (1,2,6,5),(2,3,7,6),(3,0,4,7)]
        self.geometria(grupo,v,f,THATCH,col)

    def cubierta(self,chimeneas,claraboyas=0,torre=None):
        a=self.f["alero"]
        agujeros=[]

        for x,y in chimeneas:
            agujeros.append((x-0.27,x+0.27,y-0.27,y+0.27,"CH"))

        tam=0.50 if self.f["id"]==3 else 0.40
        if claraboyas:
            yc=self.W*0.76
            pendiente=(self.R-self.H)/(self.W/2)
            profundidad=tam/math.sqrt(1+pendiente*pendiente)

            for x in (self.L*0.28,self.L*0.72):
                agujeros.append((
                    x-tam/2,x+tam/2,
                    yc-profundidad/2,yc+profundidad/2,"VENT"
                ))

        if torre:
            x,y,r=torre
            agujeros.append((x-r,x+r,y-r,y+r,"TORRE"))

        for grupo,y0,y1 in [
            ("Techo_Izq",-a,self.W/2),
            ("Techo_Der",self.W/2,self.W+a)
        ]:
            xs={-a,self.L+a}
            ys={y0,y1}
            ys.update(y0+(y1-y0)*i/4 for i in range(1,4))

            for x0,x1,b0,b1,tipo in agujeros:
                xs.update((x0,x1))
                if y0 < b0 < y1: ys.add(b0)
                if y0 < b1 < y1: ys.add(b1)

            xs=sorted(x for x in xs if -a<=x<=self.L+a)
            ys=sorted(ys)

            for xa,xb in zip(xs[:-1],xs[1:]):
                for ya,yb in zip(ys[:-1],ys[1:]):
                    mx,my=(xa+xb)/2,(ya+yb)/2
                    dentro=any(
                        x0<mx<x1 and b0<my<b1
                        for x0,x1,b0,b1,t in agujeros
                    )
                    if dentro:
                        continue

                    banda=int((my-y0)/(y1-y0)*4)
                    col="paja_osc" if banda%2 else "paja"
                    if self.f["id"]==5:
                        col="paja_naranja"
                    self.panel_techo(grupo,xa,xb,ya,yb,col)

        # Claraboyas triangulares: rellenar esquinas del hueco
        # rectangular y dejar el triangulo central transparente.
        for x0,x1,y0,y1,tipo in agujeros:
            if tipo!="VENT":
                continue

            def p(x,y,dz=0.0):
                return (x,y,self.z_techo(y)+0.12+dz)

            a0=p(x0,y0)
            b0=p(x1,y0)
            c0=p(x1,y1)
            d0=p(x0,y1)
            punta=p((x0+x1)/2,y0)

            self.geometria(
                "Techo_Der",[a0,punta,d0,b0,c0,punta],
                [(0,1,2),(3,4,5)],THATCH,"paja"
            )
            self.geometria(
                "Techo_Der",[d0,c0,punta],
                [(0,1,2)],TRANS,"vidrio"
            )
            for u,v in [(d0,c0),(c0,punta),(punta,d0)]:
                self.tubo("Techo_Der",u,v,0.025,WOOD,"oscura",6)

        # Cierre de esquinas entre hueco cuadrado y torre circular.
        if torre:
            cx,cy,r=torre
            verts=[]
            for i in range(17):
                t=2*math.pi*i/16
                dx,dy=math.cos(t),math.sin(t)
                k=r/max(abs(dx),abs(dy))
                for rr in (r,k):
                    x,y=cx+dx*rr,cy+dy*rr
                    verts.append((x,y,self.z_techo(y)+0.12))
            faces=[
                (2*i,2*i+1,2*i+3,2*i+2) for i in range(16)
            ]
            self.geometria("Techo_Izq",verts,faces,THATCH,"paja")

        self.tubo(
            "Cumbrera",(-a,self.W/2,self.R+0.10),
            (self.L+a,self.W/2,self.R+0.10),
            0.075,WOOD,"oscura",8
        )

        # Testeros laterales.
        for grupo,x0,x1 in [
            ("Pared_Oeste",0,self.f["pared"]),
            ("Pared_Este",self.L-self.f["pared"],self.L)
        ]:
            v=[
                (x0,0,self.H),(x0,self.W,self.H),(x0,self.W/2,self.R),
                (x1,0,self.H),(x1,self.W,self.H),(x1,self.W/2,self.R)
            ]
            f=[(0,2,1),(3,4,5),(0,1,4,3),(1,2,5,4),(2,0,3,5)]
            self.geometria(grupo,v,f,WOOD,"madera")

        if self.f["id"]==4:
            # Segundo nivel central, solapado sobre la cubierta baja.
            for y0,y1 in [
                (self.W/2-1.05,self.W/2),
                (self.W/2,self.W/2+1.05)
            ]:
                self.panel_techo(
                    "Techo_Superior",-0.15,self.L+0.15,
                    y0,y1,"paja_osc",0.30
                )

    # ---------------- MOBILIARIO ----------------

    def mesa(self,g,x,y,sx=1.2,sy=0.6,h=0.80):
        self.caja(g,(x,y,self.F+h-0.035),(sx,sy,0.07),
                  WOOD,"media",0.035)
        for dx in (-sx/2+0.10,sx/2-0.10):
            for dy in (-sy/2+0.10,sy/2-0.10):
                self.caja(g,(x+dx,y+dy,self.F+(h-0.07)/2),
                          (0.075,0.075,h-0.07),WOOD,"oscura")
        self.interactivo(f"MESA_{len(self.interacciones)}",g,x,y,"MESA")

    def silla(self,g,x,y,angulo=0):
        p=self.pieza(g)
        inicio=len(p.vertices)

        self.caja(g,(x,y,self.F+0.42),(0.42,0.42,0.06),
                  WOOD,"media",0.025)
        for dx in (-0.15,0.15):
            for dy in (-0.15,0.15):
                self.caja(g,(x+dx,y+dy,self.F+0.195),
                          (0.05,0.05,0.39),WOOD,"oscura")
        self.caja(g,(x,y-0.18,self.F+0.72),(0.40,0.05,0.36),
                  WOOD,"media",0.018)

        R=Matrix.Rotation(angulo,3,"Z")
        c=Vector((x,y,self.F))
        for i in range(inicio,len(p.vertices)):
            p.vertices[i]=c+R@(p.vertices[i]-c)

        self.interactivo(f"SILLA_{len(self.interacciones)}",g,x,y,"SILLA")

    def comedor(self,g,x,y,sx,sy,n):
        self.mesa(g,x,y,sx,sy)
        por_lado=(n-2)//2

        for signo in (-1,1):
            self.silla(g,x+signo*(sx/2+0.42),y,
                       -signo*math.pi/2)

        for i in range(por_lado):
            dx=-sx/2+(i+1)*sx/(por_lado+1)
            self.silla(g,x+dx,y-sy/2-0.42,0)
            self.silla(g,x+dx,y+sy/2+0.42,math.pi)

    def cama(self,g,x,y,ancho=1.5,largo=2.0,dosel=False):
        self.caja(g,(x,y,self.F+0.40),(ancho,largo,0.10),
                  WOOD,"media",0.04)
        for dx in (-ancho/2+0.08,ancho/2-0.08):
            for dy in (-largo/2+0.08,largo/2-0.08):
                self.caja(g,(x+dx,y+dy,self.F+0.19),
                          (0.09,0.09,0.38),WOOD,"oscura")

        self.caja(g,(x,y,self.F+0.52),(ancho-0.06,largo-0.05,0.14),
                  THATCH,"paja",0.055)
        self.caja(g,(x,y+0.22,self.F+0.603),
                  (ancho-0.03,largo-0.52,0.026),
                  FABRIC,"azul" if ancho>1 else "tela",0.025)

        n=2 if ancho>1 else 1
        for i in range(n):
            px=x+(i-(n-1)/2)*ancho/n
            self.caja(g,(px,y-largo/2+0.25,self.F+0.64),
                      (ancho/n-0.12,0.34,0.10),FABRIC,"tela",0.04)

        self.caja(g,(x,y-largo/2+0.025,self.F+0.57),
                  (ancho,0.065,0.65),WOOD,"oscura",0.025)

        if dosel:
            for dx in (-ancho/2,ancho/2):
                for dy in (-largo/2,largo/2):
                    self.tubo(g,(x+dx,y+dy,self.F),
                              (x+dx,y+dy,self.F+2.30),
                              0.035,WOOD,"oscura",6)
            self.caja(g,(x,y,self.F+2.30),
                      (ancho+0.10,largo+0.10,0.025),FABRIC,"tela")

        self.interactivo("CAMA_"+str(len(self.interacciones)),g,x,y,"CAMA")

    def estante(self,g,x,y,ancho=1.2,niveles=3,libros=True):
        for z in (0.35+i*0.48 for i in range(niveles)):
            self.caja(g,(x,y,self.F+z),(ancho,0.32,0.045),
                      WOOD,"media")
        for dx in (-ancho/2+0.03,ancho/2-0.03):
            self.caja(g,(x+dx,y,self.F+(0.38+0.48*(niveles-1))/2),
                      (0.06,0.28,0.38+0.48*(niveles-1)),
                      WOOD,"oscura")

        for i in range(4):
            px=x-ancho*0.3+i*ancho*0.18
            if libros:
                self.caja(g,(px,y,self.F+0.47),
                          (0.09,0.20,0.19),FABRIC,
                          "azul" if i%2 else "tela")
            else:
                self.tubo(g,(px,y,self.F+0.38),
                          (px,y,self.F+0.58),0.075,CLAY,"barro",8)
        self.interactivo("ESTANTE_"+str(len(self.interacciones)),g,x,y,"ESTANTE")

    def comoda(self,g,x,y,ancho=1.1,alto=0.9,cajones=3):
        self.caja(g,(x,y,self.F+alto/2),(ancho,0.48,alto),
                  WOOD,"media",0.03)
        for i in range(cajones):
            z=self.F+(i+0.5)*alto/cajones
            self.caja(g,(x,y+0.249,z),(ancho-0.08,0.012,alto/cajones-0.035),
                      WOOD,"madera")
            self.tubo(g,(x-0.07,y+0.275,z),(x+0.07,y+0.275,z),
                      0.013,METAL,"bronce",6)
        self.interactivo("COMODA_"+str(len(self.interacciones)),g,x,y,"COMODA")

    def cocina(self,g,x,y,n=2):
        self.caja(g,(x,y,self.F+0.40),(1.35,0.72,0.80),
                  STONE,"piedra",0.04)
        self.caja(g,(x,y,self.F+0.815),(1.39,0.76,0.035),
                  METAL,"metal")
        for i in range(n):
            xx=x+(i-(n-1)/2)*0.36
            self.tubo(g,(xx,y,self.F+0.835),(xx,y,self.F+0.855),
                      0.13,METAL,"metal",10)
        self.caja(g,(x,y+0.369,self.F+0.34),(0.46,0.02,0.37),
                  METAL,"metal")
        self.interactivo("COCINA",g,x,y,"COCINA")

    def chimenea(self,g,x,y):
        top=self.z_techo(y)+0.55
        for xx in (x-0.18,x+0.18):
            self.caja(g,(xx,y,(self.F+top)/2),
                      (0.09,0.45,top-self.F),STONE,"piedra_osc")
        for yy in (y-0.18,y+0.18):
            self.caja(g,(x,yy,(self.F+top)/2),
                      (0.27,0.09,top-self.F),STONE,"piedra")

    def nevera(self,g,x,y,doble=False):
        self.caja(g,(x,y,self.F+0.38),
                  (1.15 if doble else 0.72,0.65,0.76),
                  STONE,"piedra_clara",0.035)
        self.caja(g,(x,y,self.F+0.795),
                  (1.19 if doble else 0.76,0.69,0.07),
                  WOOD,"media",0.02)
        self.interactivo("NEVERA",g,x,y,"NEVERA_RUSTICA")

    def sofa(self,g,x,y,ancho=1.8):
        self.caja(g,(x,y,self.F+0.25),(ancho,0.75,0.34),
                  WOOD,"oscura",0.035)
        self.caja(g,(x,y,self.F+0.46),(ancho-0.10,0.68,0.16),
                  FABRIC,"tela",0.06)
        self.caja(g,(x,y-0.31,self.F+0.75),(ancho,0.18,0.60),
                  FABRIC,"tela",0.05)
        for dx in (-ancho/2+0.06,ancho/2-0.06):
            self.caja(g,(x+dx,y,self.F+0.64),(0.14,0.77,0.28),
                      WOOD,"media",0.03)
        self.interactivo("SOFA_"+str(len(self.interacciones)),g,x,y,"SOFA")

    def planta(self,g,x,y,tamano=1.0):
        z=self.F
        self.tubo(g,(x,y,z),(x,y,z+0.30*tamano),
                  0.16*tamano,CLAY,"barro",8)
        for i in range(5):
            a=2*math.pi*i/5
            p0=Vector((x,y,z+0.26*tamano))
            punta=p0+Vector((
                0.36*math.cos(a),0.36*math.sin(a),0.45
            ))*tamano
            medio=p0.lerp(punta,0.55)
            lado=Vector((-math.sin(a),math.cos(a),0))*0.10*tamano
            self.geometria(
                g,[p0,medio-lado,punta,medio+lado],
                [(0,1,2),(0,2,3)],LEAF,
                "verde" if i%2 else "verde_osc"
            )

    def farol(self,g,x,y,h=1.5):
        self.tubo(g,(x,y,self.F),(x,y,self.F+h),
                  0.035,WOOD,"oscura",6)
        self.caja(g,(x,y,self.F+h),(0.23,0.23,0.035),
                  WOOD,"oscura")
        self.caja(g,(x,y,self.F+h+0.29),(0.26,0.26,0.035),
                  WOOD,"oscura")
        for dx in (-0.09,0.09):
            for dy in (-0.09,0.09):
                self.tubo(g,(x+dx,y+dy,self.F+h),
                          (x+dx,y+dy,self.F+h+0.29),
                          0.012,WOOD,"oscura",5)
        self.tubo(g,(x,y,self.F+h+0.02),(x,y,self.F+h+0.17),
                  0.035,FABRIC,"cera",6)

    def alfombra(self,g,x,y,sx,sy):
        self.caja(g,(x,y,self.F+0.006),(sx,sy,0.012),
                  FABRIC,"cuero",0.04)

    def mascara(self,g,x,y,z):
        self.caja(g,(x,y,z),(0.33,0.07,0.49),
                  WOOD,"oscura",0.075)
        for dx in (-0.075,0.075):
            self.caja(g,(x+dx,y+0.041,z+0.045),
                      (0.07,0.018,0.045),WOOD,"madera")
        self.caja(g,(x,y+0.06,z-0.03),(0.045,0.08,0.13),
                  WOOD,"media",0.01)

    def portico(self,ancho=2.0,prof=1.5,columnas=2):
        g="Portico"
        cx=self.f["puerta_x"]
        for i in range(columnas):
            x=cx-ancho/2+i*ancho/max(1,columnas-1)
            self.tubo(g,(x,self.W+prof,Z_MIN),
                      (x,self.W+prof,self.F+2.40),
                      0.10 if columnas==4 else 0.065,
                      STONE if columnas==4 else WOOD,
                      "piedra_clara" if columnas==4 else "oscura",8)

        self.tubo(g,(cx-ancho/2,self.W+prof,self.F+2.40),
                  (cx+ancho/2,self.W+prof,self.F+2.40),
                  0.075,WOOD,"oscura",8)

        v=[
            (cx-ancho/2-0.12,self.W,self.F+2.58),
            (cx+ancho/2+0.12,self.W,self.F+2.58),
            (cx+ancho/2+0.12,self.W+prof+0.12,self.F+2.40),
            (cx-ancho/2-0.12,self.W+prof+0.12,self.F+2.40)
        ]
        self.geometria(g,v,[(0,1,2,3)],FABRIC,"lona")


# ---------------- TORRE DE LA MANSION ----------------

def torre(c,cx,cy,r):
    g="Torre"
    n=16
    f=c.F
    altura=3.60

    # Entrada hacia +Y: dos segmentos centrales sin tramo inferior.
    for i in range(n):
        a=2*math.pi*i/n
        b=2*math.pi*(i+1)/n
        medio=(a+b)/2

        entrada=abs(medio-math.pi/2)<0.40
        ventana=i in (0,7,12)

        tramos=[(0,altura)]
        if entrada:
            tramos=[(2.10,altura)]
        elif ventana:
            tramos=[(0,2.45),(3.10,altura)]

        for z0,z1 in tramos:
            v=[]
            for z in (f+z0,f+z1):
                for rr,t in [(r,a),(r,b),(r-0.12,b),(r-0.12,a)]:
                    v.append((cx+rr*math.cos(t),cy+rr*math.sin(t),z))
            faces=[
                (0,3,2,1),(4,5,6,7),
                (0,1,5,4),(1,2,6,5),
                (2,3,7,6),(3,0,4,7)
            ]
            c.geometria(g,v,faces,STONE,"piedra_clara")

    # Cono de paja abierto por abajo.
    verts=[(cx,cy,f+4.50)]
    verts += [
        (cx+(r+0.12)*math.cos(2*math.pi*i/n),
         cy+(r+0.12)*math.sin(2*math.pi*i/n),
         f+altura)
        for i in range(n)
    ]
    c.geometria("Torre_Techo",verts,
                [(0,1+i,1+(i+1)%n) for i in range(n)],
                THATCH,"paja")

    # Escalera visual de 300 grados, con 24 peldaños.
    c.tubo(g,(cx,cy,f),(cx,cy,f+2.0),0.10,WOOD,"oscura",8)
    for i in range(24):
        a=math.radians(300)*i/24
        b=math.radians(300)*(i+1)/24
        z=f+(i+1)*1.90/24
        verts=[]
        for zz in (z-0.055,z):
            for rr,t in [(0.16,a),(1.12,a),(1.12,b),(0.16,b)]:
                verts.append((cx+rr*math.cos(t),cy+rr*math.sin(t),zz))
        faces=[(0,3,2,1),(4,5,6,7),(0,1,5,4),
               (1,2,6,5),(2,3,7,6),(3,0,4,7)]
        c.geometria(g,verts,faces,WOOD,"media")

    # Plataforma parcial: conserva hueco para la escalera.
    for i in range(3):
        a=math.radians(300+i*20)
        b=math.radians(300+(i+1)*20)
        verts=[
            (cx,cy,f+1.90),
            (cx+1.20*math.cos(a),cy+1.20*math.sin(a),f+1.90),
            (cx+1.20*math.cos(b),cy+1.20*math.sin(b),f+1.90)
        ]
        c.geometria(g,verts,[(0,1,2)],WOOD,"madera")

    c.avisos.append(
        "Torre: escalera y plataforma son prototipo visual. "
        "Faltan barandilla, colisiones y validacion de paso/altura libre."
    )


# ---------------- CONSTRUIR CADA CASA ----------------

def construir(ficha):
    c=Casa(ficha)
    L,W,F=c.L,c.W,c.F
    id_=ficha["id"]

    # Zocalo completo, con juntas superficiales.
    c.caja("Cimiento",(L/2,W/2,Z_MIN+ficha["base"]/2),
           (L,W,ficha["base"]),STONE,"piedra_osc",0.035)

    for x in range(1,int(L)):
        c.caja("Cimiento",(x,W+0.001,Z_MIN+ficha["base"]/2),
               (0.012,0.003,ficha["base"]*0.82),STONE,"piedra")
    for y in range(1,int(W)):
        c.caja("Cimiento",(L+0.001,y,Z_MIN+ficha["base"]/2),
               (0.003,0.012,ficha["base"]*0.82),STONE,"piedra")

    px=ficha["puerta_x"]
    pw=ficha["puerta_w"]
    puerta=(px-pw/2,px+pw/2,F,F+ficha["puerta_h"],"PUERTA")

    def v(centro,w=0.60,h=0.60):
        return (centro-w/2,centro+w/2,F+1.10,F+1.10+h,"VENTANA")

    norte=[]
    sur=[puerta]
    este=[]
    oeste=[]

    if id_==2:
        norte=[v(2.0),v(6.1,0.80)]
        este=[v(3.7)]
        oeste=[v(3.7)]
    elif id_==3:
        sur += [v(2.1),v(7.9)]
        norte=[v(2.2),v(7.8)]
        este=[v(6.0)]
        oeste=[v(6.0)]
    elif id_==4:
        sur += [v(2.2,0.80,0.70),v(11.4,0.80,0.70)]
        norte=[v(2.1,0.80,0.70),v(9.8,0.80,0.70)]
        este=[v(4.1,0.80,0.70),v(7.5,0.80,0.70)]
        oeste=[v(2.3,0.80,0.70),v(7.5,0.80,0.70)]
    else:
        sur += [v(5.4)]
        este=[v(1.5)]
        oeste=[v(3.6)]

    c.pared("Pared_Norte","X",0.06,L,norte)
    c.pared("Pared_Sur","X",W-0.06,L,sur)
    c.pared("Pared_Este","Y",L-0.06,W,este)
    c.pared("Pared_Oeste","Y",0.06,W,oeste)

    for x in (0.075,L-0.075):
        for y in (0.075,W-0.075):
            c.caja("Pared_Sur" if y>W/2 else "Pared_Norte",
                   (x,y,F+ficha["altura"]/2),
                   (0.12,0.12,ficha["altura"]),WOOD,"oscura")

    chimeneas=[]
    torre_pos=None

    if id_==2:
        c.pared("Pared_Interior","Y",4.0,W,[
            (2.55,3.45,F,F+2.10,"PUERTA_INTERIOR")
        ])
        c.suelo("Suelo_Sala",0.12,3.94,0.12,W-0.12)
        c.suelo("Suelo_Dormitorio",4.06,L-0.12,0.12,W-0.12)

        c.comedor("Mesa_Comedor",2.0,3.45,1.40,0.80,4)
        c.cocina("Cocina_Lena",1.20,0.66)
        c.nevera("Nevera_Rustica",3.20,0.58)
        c.estante("Cocina_Lena",2.45,0.30,1.05,3,False)
        c.farol("Mesa_Comedor",0.55,4.80)
        c.alfombra("Suelo_Sala",2.0,3.40,2.4,2.1)

        c.cama("Cama_Doble",6.45,1.55)
        c.mesa("Cama_Doble",7.55,0.75,0.42,0.42,0.58)
        c.comoda("Comoda",7.30,4.65)
        c.mascara("Comoda",6.5,0.15,F+1.85)
        c.planta("Comoda",4.65,4.90,0.85)
        c.planta("Pared_Sur",4.48,W+0.45)
        c.planta("Pared_Sur",6.52,W+0.45)

        chimeneas=[(1.20,0.45)]
        c.chimenea("Chimenea_Exterior",*chimeneas[0])

    elif id_==3:
        # Division longitudinal termina antes del vestibulo.
        c.pared("Pared_Interior_1","Y",5.0,6.8,[
            (5.15,6.05,F,F+2.10,"PUERTA_INTERIOR")
        ])
        c.pared("Pared_Interior_2","X",4.0,5.0,[
            (2.05,2.95,F,F+2.10,"PUERTA_INTERIOR")
        ])
        c.pared("Pared_Interior_3","X",4.0,5.0,[
            (7.05,7.95,F,F+2.10,"PUERTA_INTERIOR")
        ],origen=5.0)

        c.suelo("Suelo",0.12,4.94,0.12,W-0.12)
        c.suelo("Suelo",5.06,L-0.12,0.12,3.94)
        c.suelo("Suelo",5.06,L-0.12,4.06,W-0.12,True)

        c.sofa("Sillon",1.45,4.90,2.0)
        c.mesa("Sillon",1.45,6.12,1.0,0.60,0.35)
        c.estante("Estanteria_Grande",2.25,4.30,2.4,3)
        c.farol("Sillon",0.5,6.80)
        c.alfombra("Suelo",1.6,6.0,2.5,2.0)

        c.comedor("Mesa_Comedor",7.5,6.30,1.60,0.90,6)
        c.cocina("Cocina_Completa",8.9,4.70)
        c.nevera("Cocina_Completa",6.15,4.55)
        c.estante("Cocina_Completa",8.0,4.28,1.3,2,False)

        c.cama("Cama_Doble",2.45,1.55)
        for x in (1.32,3.58):
            c.mesa("Cama_Doble",x,0.70,0.42,0.42,0.58)
        c.comoda("Cama_Doble",0.85,2.80,0.90,1.25,5)
        c.planta("Cama_Doble",4.3,0.65)

        c.cama("Taller",5.85,1.45,0.90,2.0)
        c.mesa("Taller",8.45,1.0,1.20,0.80)
        c.silla("Taller",8.45,1.95,math.pi)
        c.estante("Taller",8.40,0.30,1.35,3,False)

        c.portico()
        c.mesa("Portico",3.20,W+0.65,1.2,0.42,0.45)
        c.farol("Portico",6.40,W+0.55,0.75)

        chimeneas=[(0.55,4.65),(9.35,4.65)]
        for i,pos in enumerate(chimeneas):
            c.chimenea(f"Chimenea_{i+1}",*pos)

    elif id_==4:
        for x,g in [(5.0,"Pared_Interior_1"),(9.0,"Pared_Interior_2")]:
            c.pared(g,"Y",x,W,[
                (1.95,2.85,F,F+2.10,"PUERTA_INTERIOR"),
                (7.05,7.95,F,F+2.10,"PUERTA_INTERIOR"),
            ])
        c.pared("Pared_Interior_3","X",4.50,5.0,[])
        c.pared("Pared_Interior_4","X",5.00,5.0,[],origen=9.0)

        c.suelo("Suelo",0.15,L-0.15,0.15,W-0.15)
        c.suelo("Cocina_Completa",9.08,L-0.15,5.08,W-0.15,True)

        c.sofa("Sillon_Grande",2.30,5.25,2.8)
        c.mesa("Sillon_Grande",2.30,6.60,1.20,0.80,0.35)
        c.estante("Estanteria_Monumental",2.45,4.78,3.9,4)
        c.farol("Estanteria_Monumental",0.45,5.1)
        c.farol("Estanteria_Monumental",4.50,5.1)
        c.mascara("Estanteria_Monumental",2.50,4.60,F+2.20)
        c.planta("Sillon_Grande",0.55,9.10,1.25)
        c.alfombra("Suelo",2.4,7.0,3.6,2.5)

        c.comedor("Mesa_Comedor",7.0,5.0,2.0,1.0,8)

        c.cocina("Cocina_Completa",12.65,5.65,3)
        c.mesa("Cocina_Completa",11.70,7.80,1.40,0.80)
        c.nevera("Cocina_Completa",9.85,5.70,True)
        c.estante("Cocina_Completa",12.0,5.30,1.60,3,False)

        # Lavadero: cuatro paredes y fondo, no bloque cerrado.
        gx,gy=13.3,8.9
        for dx in (-0.35,0.35):
            c.caja("Cocina_Completa",(gx+dx,gy,F+0.60),
                   (0.08,0.62,0.50),STONE,"piedra")
        for dy in (-0.27,0.27):
            c.caja("Cocina_Completa",(gx,gy+dy,F+0.60),
                   (0.62,0.08,0.50),STONE,"piedra")
        c.caja("Cocina_Completa",(gx,gy,F+0.37),
               (0.62,0.54,0.06),STONE,"piedra")
        c.caja("Cocina_Completa",(gx,gy,F+0.60),
               (0.60,0.50,0.006),TRANS,"vidrio")

        c.estante("Biblioteca",2.40,0.35,3.80,4)
        c.sofa("Biblioteca",1.0,1.60,0.90)
        c.mesa("Biblioteca",2.4,2.5,0.80,0.60)
        c.farol("Biblioteca",2.65,2.5,0.85)
        c.alfombra("Suelo",2.4,2.4,2.6,2.3)

        c.cama("Cama_King",10.20,3.50,1.80,2.20,True)
        for x in (9.20,11.30):
            c.mesa("Cama_King",x,2.55,0.46,0.46,0.60)
        c.estante("Vestidor",9.70,0.32,1.0,3,False)
        c.silla("Vestidor",13.0,4.25)
        c.planta("Vestidor",13.45,3.60)
        c.avisos.append(
            "Vestidor: estante abierto y asiento base; "
            "ropa colgada y mecedora detallada pendientes."
        )

        c.portico(3.4,1.7,4)
        c.caja("Terraza",(L+1.5,6.5,Z_MIN+0.08),
               (3.0,2.0,0.16),STONE,"piedra")
        c.mesa("Terraza",L+1.5,6.5,1.3,0.42,0.45)
        c.planta("Terraza",L+2.6,7.15)

        torre_pos=(12.35,1.65,1.50)
        torre(c,*torre_pos)

        chimeneas=[(0.65,5.1),(13.10,5.5)]
        for i,pos in enumerate(chimeneas):
            c.chimenea(f"Chimenea_{i+1}",*pos)

    else:
        c.suelo("Suelo",0.12,L-0.12,0.12,W-0.12)
        c.cama("Cama",1.45,1.45)
        c.comedor("Mesa_Sillas",3.80,3.25,0.90,0.65,2)
        c.cocina("Cocina",5.90,0.75,1)
        c.estante("Cocina",4.80,0.30,1.20,2,False)
        c.farol("Mesa_Sillas",4.90,3.8)
        c.planta("Cocina",6.30,3.70)
        c.alfombra("Suelo",3.70,3.2,1.7,1.5)

        c.portico(1.5,0.85,2)
        c.mascara("Pared_Sur",2.50,W+0.04,F+2.35)

        # Patio frontal: entrada abierta de 1.2m.
        for x in (0.5,1.5,3.5,4.5):
            c.caja("Valla_Patio",(x,W+1.75,Z_MIN+0.40),
                   (0.09,0.09,0.80),WOOD,"oscura")
        for a,b in [(0.5,1.90),(3.10,4.5)]:
            for z in (Z_MIN+0.30,Z_MIN+0.63):
                c.caja("Valla_Patio",((a+b)/2,W+1.75,z),
                       (b-a,0.06,0.07),WOOD,"madera")

        chimeneas=[(5.90,0.48)]
        c.chimenea("Cocina",*chimeneas[0])

    c.cubierta(
        chimeneas,
        claraboyas=2 if id_ in (2,3) else 0,
        torre=torre_pos
    )

    c.avisos += [
        "Accesorios pequeños y tallas elaboradas pendientes.",
        "No se ha certificado automaticamente la holgura entre todos los muebles.",
        "Los conjuntos de muebles comparten mesh; interacciones en JSON.",
        "LOD reducido destinado al exterior lejano; interior requiere ALTA.",
    ]
    return c


# ---------------- ESCENA Y MATERIALES ----------------

def limpiar():
    if bpy.context.object and bpy.context.object.mode!="OBJECT":
        bpy.ops.object.mode_set(mode="OBJECT")
    for o in list(bpy.data.objects):
        bpy.data.objects.remove(o,do_unlink=True)
    for c in list(bpy.data.collections):
        bpy.data.collections.remove(c)
    for grupo in (
        bpy.data.meshes,bpy.data.materials,bpy.data.cameras,
        bpy.data.lights,bpy.data.worlds
    ):
        for b in list(grupo):
            if b.users==0:
                grupo.remove(b)


def material(nombre,rough,metal,alpha):
    m=bpy.data.materials.new(nombre)
    m.use_nodes=True
    m.use_backface_culling=False
    nt=m.node_tree
    nt.nodes.clear()

    a=nt.nodes.new("ShaderNodeVertexColor")
    a.layer_name="COLOR_0"
    p=nt.nodes.new("ShaderNodeBsdfPrincipled")
    p.inputs["Roughness"].default_value=rough
    p.inputs["Metallic"].default_value=metal
    p.inputs["Alpha"].default_value=alpha
    out=nt.nodes.new("ShaderNodeOutputMaterial")
    nt.links.new(a.outputs["Color"],p.inputs["Base Color"])
    nt.links.new(p.outputs["BSDF"],out.inputs["Surface"])

    if alpha<1:
        if hasattr(m,"surface_render_method"):
            m.surface_render_method="DITHERED"
        elif hasattr(m,"blend_method"):
            m.blend_method="BLEND"
    return m


def instanciar(c):
    limpiar()
    scene=bpy.context.scene
    scene.unit_settings.system="METRIC"
    scene.unit_settings.scale_length=1.0

    col=bpy.data.collections.new("COL_CASA")
    scene.collection.children.link(col)
    raiz=bpy.data.objects.new(
        f"SM_CASA_{c.f['id']:02d}_{c.f['nombre']}",None
    )
    col.objects.link(raiz)

    mats=[material(*f) for f in FAMILIAS]
    objs=[]

    for nombre,pieza in c.piezas.items():
        if not pieza.caras:
            continue
        me=bpy.data.meshes.new(nombre+"_MESH")
        me.from_pydata(pieza.vertices,[],pieza.caras)
        me.update()

        usados=sorted(set(pieza.slots))
        idx={s:i for i,s in enumerate(usados)}
        for s in usados:
            me.materials.append(mats[s])

        attr=me.color_attributes.new(
            name="COLOR_0",type="FLOAT_COLOR",domain="CORNER"
        )
        me.color_attributes.active_color=attr
        me.color_attributes.render_color_index=0

        for p,s,rgba in zip(me.polygons,pieza.slots,pieza.colores):
            p.material_index=idx[s]
            for li in p.loop_indices:
                attr.data[li].color=rgba

        bm=bmesh.new()
        bm.from_mesh(me)
        bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
        bm.to_mesh(me)
        bm.free()

        obj=bpy.data.objects.new(nombre,me)
        col.objects.link(obj)
        obj.parent=raiz
        objs.append(obj)

    bpy.context.view_layer.update()
    return raiz,objs,col


def stats(objs):
    puntos=[]
    total=0
    materiales=set()
    for o in objs:
        o.data.calc_loop_triangles()
        total+=len(o.data.loop_triangles)
        puntos += [o.matrix_world@v.co for v in o.data.vertices]
        for p in o.data.polygons:
            materiales.add(o.data.materials[p.material_index])

    mn=Vector(tuple(min(p[i] for p in puntos) for i in range(3)))
    mx=Vector(tuple(max(p[i] for p in puntos) for i in range(3)))

    return {
        "triangulos":total,
        "meshes":len(objs),
        "objetos_con_empty":len(objs)+1,
        "materiales":len(materiales),
        "z_min":mn.z,
        "dimensiones_totales":list(mx-mn),
    }


def activar(o):
    bpy.ops.object.select_all(action="DESELECT")
    o.select_set(True)
    bpy.context.view_layer.objects.active=o


def exportar(raiz,objs,ruta):
    bpy.ops.object.select_all(action="DESELECT")
    raiz.select_set(True)
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active=objs[0]

    opts=dict(
        filepath=str(ruta),export_format="GLB",
        use_selection=True,export_yup=True,export_apply=True,
        export_animations=False,export_materials="EXPORT"
    )
    props={p.identifier for p in bpy.ops.export_scene.gltf.get_rna_type().properties}
    if "export_all_vertex_colors" in props:
        opts["export_all_vertex_colors"]=True
    bpy.ops.export_scene.gltf(**opts)


# ---------------- CAPTURAS ----------------

def capturas(c,objs,carpeta):
    scene=bpy.context.scene
    preview=bpy.data.collections.new("COL_PREVIEW")
    scene.collection.children.link(preview)

    centro=Vector((c.L/2,c.W/2,c.F+1.5))
    medidas=Vector(stats(objs)["dimensiones_totales"])

    def apuntar(o):
        o.rotation_euler=(centro-o.location).to_track_quat("-Z","Y").to_euler()

    for i,pos in enumerate([
        (c.L/2,c.W+5,10),(-5,c.W/2,8),(c.L+4,-4,10)
    ]):
        d=bpy.data.lights.new(f"SM_LUZ_{i}","AREA")
        d.energy=1800 if i==0 else 1100
        d.size=8
        o=bpy.data.objects.new(f"SM_LUZ_{i}",d)
        preview.objects.link(o)
        o.location=pos
        apuntar(o)

    d=bpy.data.cameras.new("SM_CAMARA")
    cam=bpy.data.objects.new("SM_CAMARA",d)
    preview.objects.link(cam)
    d.type="ORTHO"
    d.ortho_scale=medidas.length*1.15
    scene.camera=cam

    world=bpy.data.worlds.new("WORLD_PREVIEW")
    world.use_nodes=True
    bg=world.node_tree.nodes.get("Background")
    bg.inputs["Color"].default_value=rgba_lineal((128,128,128))
    bg.inputs["Strength"].default_value=1
    scene.world=world

    scene.render.engine="BLENDER_EEVEE_NEXT"
    scene.view_settings.view_transform="Standard"
    scene.view_settings.exposure=0
    scene.view_settings.gamma=1
    scene.render.resolution_x=RESOLUCION
    scene.render.resolution_y=RESOLUCION
    scene.render.resolution_percentage=100
    scene.render.image_settings.file_format="JPEG"
    scene.render.image_settings.color_mode="RGB"
    scene.render.image_settings.quality=90
    scene.render.film_transparent=False
    scene.render.use_compositing=False
    scene.render.use_sequencer=False

    carpeta.mkdir(exist_ok=True)
    fecha=datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    rutas=[]

    modos=[]
    if CAPTURAS_EXTERIORES: modos.append("EXTERIOR")
    if CAPTURAS_INTERIORES: modos.append("INTERIOR")

    for modo in modos:
        for o in objs:
            o.hide_render=(
                modo=="INTERIOR"
                and (
                    "Techo" in o.name
                    or "Cumbrera" in o.name
                    or o.name=="SM_Pared_Sur"
                )
            )

        for i in range(6):
            a=math.radians(i*60)
            r=max(c.L,c.W)*1.4
            cam.location=centro+Vector((r*math.sin(a),r*math.cos(a),r))
            apuntar(cam)
            ruta=carpeta/f"CASA_{c.f['id']:02d}_{modo}_{fecha}_{i*60:03d}.jpg"
            scene.render.filepath=str(ruta)
            bpy.ops.render.render(write_still=True)
            rutas.append(str(ruta))

    for o in objs:
        o.hide_render=False

    scene.camera=None
    for o in list(preview.objects):
        bpy.data.objects.remove(o,do_unlink=True)
    bpy.data.collections.remove(preview)
    return rutas


# ---------------- LOD ----------------

def reducir_materiales(objs,nivel):
    # Conserva la transparencia separada del resto.
    origen={nombre:i for i,(nombre,*_) in enumerate(FAMILIAS)}
    if nivel=="MEDIA":
        mapa={0:0,1:1,2:2,3:3,4:1,5:4,6:1,7:5}
        cfg=[
            ("MADERA",.86,0,1),("MINERAL",.92,0,1),
            ("PAJA",.95,0,1),("TELA",.82,0,1),
            ("TRANS",.65,0,.65),("VEGETAL",.90,0,1)
        ]
    else:
        mapa={0:0,1:1,2:0,3:2,4:1,5:3,6:1,7:0}
        cfg=[
            ("ORGANICO",.88,0,1),("MINERAL",.92,0,1),
            ("TELA",.82,0,1),("TRANS",.65,0,.65)
        ]

    mats=[material("MAT_"+nivel+"_"+n,r,m,a) for n,r,m,a in cfg]

    for o in objs:
        asignaciones=[
            mapa[origen[o.data.materials[p.material_index].name]]
            for p in o.data.polygons
        ]
        usados=sorted(set(asignaciones))
        idx={s:i for i,s in enumerate(usados)}
        o.data.materials.clear()
        for s in usados:
            o.data.materials.append(mats[s])
        for p,s in zip(o.data.polygons,asignaciones):
            p.material_index=idx[s]


def decimar(objs,limite):
    for o in objs:
        activar(o)
        mod=o.modifiers.new("TRIANGULAR","TRIANGULATE")
        bpy.ops.object.modifier_apply(modifier=mod.name)

    for _ in range(12):
        total=stats(objs)["triangulos"]
        if total<=limite:
            return
        ratio=max(0.02,min(0.95,limite*0.96/total))

        for o in objs:
            if len(o.data.polygons)<=8:
                continue
            activar(o)
            mod=o.modifiers.new("DECIMATE_LOD","DECIMATE")
            mod.ratio=ratio
            mod.use_collapse_triangulate=True
            bpy.ops.object.modifier_apply(modifier=mod.name)

        if stats(objs)["triangulos"]>=total:
            break

    raise RuntimeError("No se alcanzo el presupuesto del LOD.")


# ---------------- LOTE ----------------

SALIDA_BASE.mkdir(parents=True,exist_ok=True)
catalogo={"correctos":[],"errores":[]}

for ficha in CASAS:
    if SOLO_CASAS is not None and ficha["id"] not in SOLO_CASAS:
        continue

    carpeta=SALIDA_BASE/f"CASA_{ficha['id']:02d}_{ficha['nombre']}"
    carpeta.mkdir(exist_ok=True)

    try:
        casa=construir(ficha)
        raiz,objs,col=instanciar(casa)
        alta=stats(objs)

        if alta["triangulos"]>6000:
            raise RuntimeError(
                f"ALTA supera presupuesto: {alta['triangulos']} tris. "
                "No se exporta como modelo valido."
            )
        if alta["meshes"]>ficha["max_obj"]:
            raise RuntimeError(
                f"Objetos: {alta['meshes']} > {ficha['max_obj']}"
            )
        if alta["materiales"]>8:
            raise RuntimeError("Mas de ocho materiales.")
        if abs(alta["z_min"]-Z_MIN)>1e-5:
            raise RuntimeError("z_min incorrecto.")

        informe={
            "casa":ficha,
            "piso_z":casa.F,
            "huecos":casa.huecos,
            "interacciones":casa.interacciones,
            "avisos":casa.avisos,
            "niveles":{"ALTA":alta},
            "capturas":[],
            "errores":[],
            "aprobacion_visual":"PENDIENTE",
            "colisiones":"NO_GENERADAS",
        }

        if CAPTURAS_EXTERIORES or CAPTURAS_INTERIORES:
            informe["capturas"]=capturas(casa,objs,carpeta/"CAPTURAS")

        carpeta_alta=carpeta/"ALTA"
        carpeta_alta.mkdir(exist_ok=True)
        exportar(raiz,objs,carpeta_alta/f"{raiz.name}_ALTA.glb")
        ruta_alta=carpeta_alta/f"{raiz.name}_ALTA.blend"
        bpy.ops.wm.save_as_mainfile(filepath=str(ruta_alta))

        # Cada LOD parte otra vez de la misma geometria procedural ALTA.
        if GENERAR_LODS:
            for nivel,limite in [("MEDIA",1500),("BAJA",700)]:
                try:
                    raiz,objs,col=instanciar(casa)
                    reducir_materiales(objs,nivel)
                    decimar(objs,limite)

                    datos=stats(objs)
                    dz=datos["z_min"]-Z_MIN
                    if abs(dz)>0.01:
                        raise RuntimeError("El LOD altero el apoyo de la casa.")

                    for o in objs:
                        for v in o.data.vertices:
                            v.co.z-=dz
                        if o.data.color_attributes.get("COLOR_0") is None:
                            raise RuntimeError("COLOR_0 perdido.")

                    datos=stats(objs)
                    informe["niveles"][nivel]=datos

                    destino=carpeta/nivel
                    destino.mkdir(exist_ok=True)
                    exportar(raiz,objs,destino/f"{raiz.name}_{nivel}.glb")
                    bpy.ops.wm.save_as_mainfile(
                        filepath=str(destino/f"{raiz.name}_{nivel}.blend")
                    )
                except Exception as error:
                    informe["errores"].append({
                        "nivel":nivel,"error":str(error)
                    })

        with open(carpeta/"INFORME.json","w",encoding="utf-8") as f:
            json.dump(informe,f,ensure_ascii=False,indent=2)

        catalogo["correctos"].append({
            "id":ficha["id"],
            "nombre":ficha["nombre"],
            "carpeta":str(carpeta),
            "alta":alta,
            "errores_lod":informe["errores"],
        })

    except Exception as error:
        traceback.print_exc()
        fallo={
            "id":ficha["id"],
            "nombre":ficha["nombre"],
            "error":str(error),
            "traceback":traceback.format_exc(),
        }
        catalogo["errores"].append(fallo)
        with open(carpeta/"ERROR.json","w",encoding="utf-8") as f:
            json.dump(fallo,f,ensure_ascii=False,indent=2)

with open(SALIDA_BASE/"CATALOGO_CASAS_02_05.json","w",encoding="utf-8") as f:
    json.dump(catalogo,f,ensure_ascii=False,indent=2)

print("\n=== CASAS 02–05 ===")
print("ALTA generadas:",len(catalogo["correctos"]))
print("Errores:",len(catalogo["errores"]))
```

---

# 3. Qué construye cada casa

## Casa 2 — Mediana

- Envolvente 8 × 6 m.
- Dos ambientes.
- Puerta exterior y paso interior abiertos.
- Cuatro ventanas con cortinas.
- Dos claraboyas triangulares.
- Mesa y cuatro sillas.
- Cocina, nevera rústica, estante y farol.
- Cama doble, velador, cómoda, máscara y plantas.
- Chimenea con abertura en la cubierta.

**Pendiente de detalle:** cocina más orgánica, salvaguardas de circulación alrededor de la mesa y accesorios pequeños.

## Casa 3 — Casona

- Envolvente 10 × 8 m.
- Cuatro zonas y vestíbulo frontal compartido.
- Tres pasos interiores.
- Seis ventanas.
- Pórtico, asiento exterior y farol.
- Sala, comedor para seis, cocina, dormitorio doble y taller con cama simple.
- Dos chimeneas.
- Dos claraboyas.

**Pendiente de detalle:** cuadro floral, espejo, jarrón con asa, herramientas específicas y acabado del sofá.

## Casa 4 — Mansión

- Envolvente principal 14 × 10 m.
- Cinco ambientes organizados mediante dos alas y comedor/circulación central.
- Ocho ventanas y cuatro pasos interiores.
- Doble cubierta.
- Pórtico de cuatro columnas.
- Terraza lateral.
- Torre cilíndrica con entrada, tres vanos altos, cubierta cónica y escalera visual.
- Mesa para ocho.
- Cocina, lavadero, biblioteca y cama king con dosel.
- Dos chimeneas.

**Pendiente importante:** la torre es una **base visual**, no una escalera ya validada para caminar. Faltan barandillas, colisiones y revisión de alturas libres. El vestidor y la mecedora tienen sustitutos básicos, no su acabado final.

## Casa 5 — Vecino

- Envolvente 7 × 5 m.
- Tres ventanas.
- Paja anaranjada.
- Toldo frontal, máscara y valla con entrada libre.
- Cama doble, mesa para dos, cocina, estante, alfombra, farol y planta.
- Chimenea incorporada al conjunto de cocina.

**Pendiente de detalle:** variantes de color por vecino, patio plantado y pequeñas diferencias de fachada.

---

# 4. Organización de salida

```text
CASAS_EXPORT/
├── CASA_01_CHOZA/
├── CASA_02_CASA_MEDIANA/
├── CASA_03_CASONA/
├── CASA_04_MANSION/
├── CASA_05_CASA_VECINO/
└── CATALOGO_CASAS_02_05.json
```

Dentro de cada casa:

```text
ALTA/
MEDIA/
BAJA/
CAPTURAS/
INFORME.json
```

El informe contiene:

- Triángulos reales.
- Meshes y materiales.
- `z_min`.
- Dimensiones totales, incluyendo anexos.
- Tamaños de huecos.
- Posiciones de muebles interactivos.
- Errores de LOD y advertencias.

**Si una casa supera el presupuesto, el script no la declara correcta ni reduce silenciosamente el ALTA.** Lo registra en `ERROR.json`.

---

## Qué tenemos al terminar esta etapa

**Las cinco tipologías quedan definidas como bases procedurales**, no solo como fachadas: incluyen distribución y mobiliario.

Antes de integrarlas en el juego, los siguientes trabajos son:

1. **Revisión visual conjunta** de las cinco casas.
2. Corregir circulación, puerta de Casa 2 y acceso a la torre.
3. Añadir hojas de puertas independientes y colisiones que no bloqueen los huecos.
4. Preparar ocultación de cubierta al entrar.
5. Completar los detalles artísticos pendientes.
6. Validar LOD desde fuera; mantener ALTA para interiores.

**El siguiente paso más útil es la integración arquitectónica en Godot: colisiones, entradas transitables y ocultación del techo**, porque esos tres elementos permiten recorrer las casas y detectar problemas de distribución rápidamente.