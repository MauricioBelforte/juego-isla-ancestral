"""HY4F v2 - buque M169 original,072 m,4 cubiertas,Z_APOYO,presupuesto y LODs.
Genera 3 .blend (alta/media/baja) y 5 renders de la LOD alta.
Sin importar .blend de ERNIE. Fuentes: INVESTIGACION-detalles-M169.md.
"""
import bpy, bmesh, math, os, sys
from mathutils import Vector, Euler

OUT = sys.argv[sys.argv.index('--') + 1]
os.makedirs(OUT, exist_ok=True)

# ---------------- parametros spec
Z_APOYO = 0.045
KEEL = Z_APOYO
WL = KEEL + 1.80
D1 = WL + 2.20
H_DECK = 3.20       # libre; forjado 0.40 -> separacion 3.60
ESP = 0.40
D2, D3, D4 = D1 + H_DECK + ESP, D1 + 2*(H_DECK+ESP), D1 + 3*(H_DECK+ESP)
HB = 7.0            # media manga 14 m
STATIONS = [(-36.0, 0.12), (-34, 0.30), (-31, 0.48), (-27, 0.62), (-22, 0.74),
            (-15, 0.84), (-6, 0.92), (4, 0.96), (14, 0.97), (24, 0.95),
            (30, 0.88), (34, 0.74), (36, 0.60)]
NIVELES = [(72.0, HB, D1), (66.0, 6.6, D2), (56.0, 6.2, D3), (34.0, 5.0, D4)]

def srgb(v):
    return v/12.92 if v <= 0.04045 else ((v+0.055)/1.055)**2.4

def mat(tag, hexs, rough=0.8, metal=0.0, emit=None):
    h = hexs.lstrip('#')
    rgb = [srgb(int(h[i:i+2],16)/255) for i in (0,2,4)]
    m = bpy.data.materials.get(tag) or bpy.data.materials.new(tag)
    m.diffuse_color = (*rgb,1); m.use_nodes = True
    bs = m.node_tree.nodes.get('Principled BSDF')
    bs.inputs['Base Color'].default_value = (*rgb,1)
    bs.inputs['Roughness'].default_value = rough
    bs.inputs['Metallic'].default_value = metal
    if emit:
        bs.inputs['Emission Color'].default_value = (*rgb,1)
        bs.inputs['Emission Strength'].default_value = emit
    return m

M = {
 'Casco': mat('MAT_Crucero_Casco','#1B3A5C',0.55),
 'Franja': mat('MAT_Crucero_Franja','#8C2F39',0.60),
 'Super': mat('MAT_Crucero_Super','#F5F0E8',0.80),
 'Cubierta': mat('MAT_Crucero_Cubierta','#B4864B',0.85),
 'Metal': mat('MAT_Crucero_Metal','#9EA7AD',0.35,0.85),
 'Chimenea': mat('MAT_Crucero_Chimenea','#22262B',0.70,0.30),
 'Dorado': mat('MAT_Crucero_Dorado','#C9A227',0.30,0.90),
 'Vidrio': mat('MAT_Crucero_Vidrio','#A8D8E8',0.08),
 'VidrioOscuro': mat('MAT_Crucero_VidrioOscuro','#2C4A5A',0.12),
 'Emergencia': mat('MAT_Crucero_Emergencia','#C0392B',0.70),
 'Madera': mat('MAT_Crucero_Madera','#6B4A2F',0.80),
 'Bambu': mat('MAT_Crucero_Bambu','#C8A96B',0.80),
 'RojoLuz': mat('MAT_Crucero_LuzRoja','#FF2020',0.20,0.0,2.0),
 'VerdeLuz': mat('MAT_Crucero_LuzVerde','#20FF50',0.20,0.0,2.0),
 'BlancaLuz': mat('MAT_Crucero_LuzBlanca','#FFFFFF',0.20,0.0,2.0),
 'BoteA': mat('MAT_Crucero_BoteNaranja','#E07C39',0.70),
 'BoteB': mat('MAT_Crucero_BoteCrema','#E8D9B5',0.70),
 'Agua': mat('MAT_Crucero_Agua','#1C4A5B',0.35),
}

class Geo:
    def __init__(self):
        self.d = {k:([],[]) for k in M}
    def put(self, k, vs, fs):
        v,f = self.d[k]; off = len(v)
        v.extend(vs); f.extend(tuple(off+i for i in face) for face in fs)
    def box(self, k, c, s, rz=0.0):
        x,y,z = c; a,b,d = [q/2 for q in s]
        angle = rz if rz else 0.0
        cs,sn = math.cos(angle),math.sin(angle)
        vs = [(-a,-b,-d),(a,-b,-d),(a,b,-d),(-a,b,-d),
              (-a,-b,d),(a,-b,d),(a,b,d),(-a,b,d)]
        vs = [(px*cs-py*sn, px*sn+py*cs, pz) for px,py,pz in vs]
        vs = [(x+px,y+py,z+pz) for px,py,pz in vs]
        fs = [(0,3,2,1),(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)]
        self.put(k,vs,fs)
    def cyl(self, k, c, r, h, n=12, axis='z'):
        x,y,z = c; vs=[]
        for t in (0,1):
            zz = z + (t-0.5)*h
            for i in range(n):
                a = 2*math.pi*i/n
                px,py = r*math.cos(a), r*math.sin(a)
                if axis=='z': vs.append((x+px,y+py,zz))
                elif axis=='y': vs.append((x+px, y+(t-0.5)*h, z+py))
                else: vs.append((x+(t-0.5)*h, y+px, z+py))
        fs=[]
        for i in range(n):
            j=(i+1)%n
            fs.append((i,j,n+j,n+i))
        fs.append(tuple(reversed(range(n))))
        fs.append(tuple(range(n,2*n)))
        self.put(k,vs,fs)
    def prism(self, k, poly, z0, z1):
        n=len(poly)
        vs=[(x,y,z0) for x,y in poly]+[(x,y,z1) for x,y in poly]
        fs=[]
        for i in range(n):
            j=(i+1)%n
            fs.append((i,j,n+j,n+i))
        fs.append(tuple(reversed(range(n))))
        fs.append(tuple(range(n,2*n)))
        self.put(k,vs,fs)
    def loft(self, k, rings, cap=True):
        n=len(rings[0]); vs=[p for r in rings for p in r]; fs=[]
        for i in range(len(rings)-1):
            for j in range(n):
                jn=(j+1)%n
                fs.append((i*n+j,(i+1)*n+j,(i+1)*n+jn,i*n+jn))
        if cap:
            fs.append(tuple(reversed(range(n))))
            fs.append(tuple((len(rings)-1)*n+j for j in range(n)))
        self.put(k,vs,fs)

def section(y,f):
    hb=HB*f
    pts=[(0,y,KEEL),(0.45*hb,y,KEEL+0.02),(0.85*hb,y,KEEL+0.28),
         (0.98*hb,y,KEEL+0.75),(hb,y,WL),(0.985*hb,y,WL+1.0),
         (0.955*hb,y,D1-0.9),(0.930*hb,y,D1-0.25),(0.905*hb,y,D1),
         (0.45*hb,y,D1),(0,y,D1)]
    mirror=[(-x,yy,z) for x,yy,z in reversed(pts[1:-1])]
    return pts+mirror

def stadium(L,B,n=24):
    r=B; rect=L/2-r
    p=[]
    for i in range(n):
        t=i/(n-1); p.append((B,-rect+t*2*rect))
    for i in range(1,n):
        a=math.pi/2*i/(n-1); p.append((B*math.cos(a),rect+r*math.sin(a)))
    for i in range(n):
        t=i/(n-1); p.append((-B,rect-t*2*rect))
    for i in range(1,n):
        a=math.pi/2*i/(n-1); p.append((-B*math.cos(a),-rect-r*math.sin(a)))
    return p

def boat(g,k,cx,cy,cz):
    # casco de bote: 8 vertices, proa/popa afinadas
    vs=[(cx-0.55,cy-2.0,cz+0.45),(cx+0.55,cy-2.0,cz+0.45),
        (cx+0.75,cy+1.2,cz+0.45),(cx-0.75,cy+1.2,cz+0.45),
        (cx-0.25,cy-1.2,cz-0.30),(cx+0.25,cy-1.2,cz-0.30),
        (cx+0.30,cy+0.8,cz-0.30),(cx-0.30,cy+0.8,cz-0.30)]
    fs=[(0,1,2,3),(4,7,6,5),(0,4,5,1),(1,5,6,2),(2,6,7,3),(3,7,4,0)]
    g.put(k,vs,fs)

def build(lod='alta'):
    g=Geo()
    stations = STATIONS if lod!='baja' else STATIONS[::2]
    N = 24 if lod=='alta' else (16 if lod=='media' else 8)
    # casco loft
    g.loft('Casco',[section(y,f) for y,f in stations])
    # tajamar/mascaron de proa (dentro de 72 m: y max 36)
    g.prism('Dorado',[(0,34.2),(0.9,35.2),(0.45,36.0),(-0.45,36.0),(-0.9,35.2)],WL-1.0,WL-0.2)
    # franja de flotacion continua
    band=[]
    for y,f in stations:
        hb=HB*f
        band.append([(hb*1.003,y,WL-0.30),(hb*1.003,y,WL+0.10),
                     (-hb*1.003,y,WL+0.10),(-hb*1.003,y,WL-0.30)])
    g.loft('Franja',band)
    # popa redonda: hélice + timón (a proa de la hélice están los botes)
    g.cyl('Metal',(0,-35.9,WL-0.55),1.15,0.22,12,'y')
    for i in range(4):
        a=math.pi/2*i
        g.box('Metal',(0.55*math.cos(a),-35.9,WL-0.55+0.55*math.sin(a)),(0.20,0.10,0.80),rz=a)
    g.box('Chimenea',(0,-35.2,WL-0.4),(0.30,2.2,2.0))  # timón: z_min = 0,045
    # cubiertas: 1 sigue casco; 2-4 contorno propio
    cont1=[(0.905*HB*f*0.99,y) for y,f in stations]
    cont1 += [(-0.905*HB*f*0.99,y) for y,f in reversed(stations)]
    g.prism('Cubierta',cont1,D1,D1+ESP)
    for L,B,z in NIVELES[1:]:
        g.prism('Cubierta',[(x*0.99,y*0.99) for x,y in stadium(L,B,N)],z,z+ESP)
    # superestructura 4 niveles (tubos)
    for i,(L,B,z) in enumerate(NIVELES):
        if i<3:
            g.prism('Super',stadium(L-3.0,max(2.0,B-0.4),N),z+ESP,z+ESP+H_DECK)
    # puente en cubierta 4: bloque mas alto, con fachada de vidrio
    g.box('Super',(0,10,D4+ESP+1.8),(9.0,16.0,3.6))
    for side in (-1,1):
        g.box('Super',(side*6.75,10,D4+ESP+0.15),(3.5,7.0,0.25))   # alas hasta manga total
    # ventanas del puente: fachada PROA (y=18.05) y bandas laterales
    for i in range(5):
        g.box('Vidrio',((i-2)*1.6,18.08,D4+ESP+2.0),(1.25,0.10,1.05))
    for side in (-1,1):
        for j in range(4):
            g.box('Vidrio',(side*4.58,5.0+j*3.2,D4+ESP+2.0),(0.10,1.45,0.95))
    # 24 ventanas de camarote (12 por banda) en nivel 2: superficie real x=+-6.2
    step=5.0 if lod!='baja' else 10.0
    ys=[-25+i*step for i in range(11)] if lod!='baja' else [-25,-15,-5,5,15,25]
    for y in ys[:12 if lod!='baja' else 6]:
        for s in (-1,1):
            g.box('VidrioOscuro',(s*6.28,y,D2+1.7),(0.10,1.10,0.85))
    # chimeneas con anillo y boca
    for y,r,h in [(-8,1.7,5.0),(-15,1.4,4.0)]:
        g.cyl('Chimenea',(0,y,D4+ESP+h/2),r,h,14)
        g.cyl('Franja',(0,y,D4+ESP+h-0.5),r*1.02,0.55,14)
        g.cyl('Chimenea',(0,y,D4+ESP+h+0.05),r*0.78,0.12,14)
    # mástil delantero + radar (soporte real de la luz de mástil delantera)
    g.cyl('Metal',(0,12,D4+6.0),0.18,8.0,10)
    g.box('Metal',(0,12,D4+9.8),(5.0,0.30,0.18))
    g.cyl('Super',(0,12,D4+10.2),1.4,0.16,16)
    g.cyl('Metal',(0,26,D4+3.0),0.14,4.0,8)
    g.box('Metal',(0,26,D4+4.9),(3.2,0.24,0.14))
    # 4 botes en pescantes, 2 por banda, COLGADOS fuera del casco y a proa de la hélice
    for s in (-1,1):
        for i,y in enumerate([-4.0,7.0]):
            boat(g,'BoteA' if i==0 else 'BoteB',s*8.7,y,D1+2.0)
            g.box('Metal',(s*8.2,y-1.4,D1+2.2),(0.16,0.16,3.0))
            g.box('Metal',(s*8.2,y+1.4,D1+2.2),(0.16,0.16,3.0))
            g.box('Metal',(s*8.5,y,D1+3.7),(0.65,3.2,0.12))
    # barandas con balaustres cada 1,5 m (alta); 4 tramos rectos (media); sin (baja)
    if lod!='baja':
        for L,B,z in NIVELES:
            p=stadium(L-2.0,B-0.35,N if lod=='alta' else 12)
            if lod=='alta':
                for j in range(len(p)):
                    x0,y0=p[j]; x1,y1=p[(j+1)%len(p)]
                    if math.hypot(x1-x0,y1-y0)>0.5:
                        g.box('Metal',((x0+x1)/2,(y0+y1)/2,z+ESP+1.0),
                              (0.06,math.hypot(x1-x0,y1-y0),0.06),rz=math.atan2(y1-y0,x1-x0)-math.pi/2)
                per=sum(math.hypot(p[(j+1)%len(p)][0]-p[j][0],p[(j+1)%len(p)][1]-p[j][1]) for j in range(len(p)))
                nb=int(per/1.5)
                for j in range(nb):
                    t=(j+0.5)/nb*per; acc=0
                    for q in range(len(p)):
                        x0,y0=p[q]; x1,y1=p[(q+1)%len(p)]
                        segl=math.hypot(x1-x0,y1-y0)
                        if acc+segl>=t:
                            u=(t-acc)/segl
                            g.box('Metal',(x0+(x1-x0)*u,y0+(y1-y0)*u,z+ESP+0.5),(0.07,0.07,1.0))
                            break
                        acc+=segl
            else:
                hw=B-0.35; hl=L/2-1.0
                for a in (-hw,hw):
                    g.box('Metal',(0,a,z+ESP+1.0),(2*hl,0.08,0.08))
                for a in (-hl,hl):
                    g.box('Metal',(a,0,z+ESP+1.0),(0.08,2*hw,0.08))
    # 2 escaleras exteriores 30 grados con rampa
    if lod!='baja':
        for s,yc in [(-1,-20.0),(1,20.0)]:
            for i in range(8):
                z=D1+ESP+i*(H_DECK+ESP)/8
                yy=yc+i*0.9
                g.box('Metal',(s*7.4,yy,z),(1.1,0.9,0.10))
            g.box('Madera',(s*7.4,yc+3.6,D1+ESP+(H_DECK+ESP)/2),(1.1,8.0,0.10),rz=math.radians(0))
    # Ancla y cadena de proa: se recogen a la altura de la línea de flotación (z_min intacto)
    g.box('Metal',(0,35.0,WL+0.20),(1.2,0.25,0.25))
    g.box('Metal',(0,35.0,WL-0.35),(0.25,0.25,0.70))
    for i in range(4):
        g.cyl('Metal',(0,35.2-i*0.35,WL+0.20),0.09,0.35,8,'y')
    # escotillas y cajas de provisiones en cubierta 1
    if lod=='alta':
        for y in [-28,-24,-20]:
            g.box('Madera',(0,y,D1+ESP+0.25),(4.0,2.6,0.5))
            g.box('Metal',(0,y,D1+ESP+0.55),(4.2,0.12,0.12))
        for y in [-16,-13,-10]:
            for s in (-1,1):
                g.box('Bambu',(s*4.0,y,D1+ESP+0.45),(1.2,1.2,0.9))
    # luces de navegación COLREG 21/23: montadas en superficie real, no flotando
    g.box('RojoLuz',(-6.6,20,D2+2.0),(0.30,0.30,0.30))
    g.box('VerdeLuz',(6.6,20,D2+2.0),(0.30,0.30,0.30))
    g.box('BlancaLuz',(0,26,D4+5.05),(0.28,0.20,0.28))  # delantera, anclada al mástil de proa
    g.box('BlancaLuz',(0,12,D4+10.5),(0.35,0.35,0.35))         # segunda, mas alta y a popa
    # luz de popa: sobre el coronamiento de la superestructura (soporte visible)
    g.box('Super',(0,-31.5,D1+2.4),(2.4,2.0,3.2))
    g.box('BlancaLuz',(0,-31.5,D1+4.15),(0.30,0.30,0.30))
    return g

def realize(g, lod):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    # re-crear materiales porque factory los borro
    global M
    M={k:mat('MAT_Crucero_'+k.replace('Luz',''),'#FFFFFF') for k in g.d}
    # paleta real por nombre
    cols={'Casco':'#1B3A5C','Franja':'#8C2F39','Super':'#F5F0E8','Cubierta':'#B4864B',
          'Metal':'#9EA7AD','Chimenea':'#22262B','Dorado':'#C9A227','Vidrio':'#A8D8E8',
          'VidrioOscuro':'#2C4A5A','Emergencia':'#C0392B','Madera':'#6B4A2F','Bambu':'#C8A96B',
          'RojoLuz':'#FF2020','VerdeLuz':'#20FF50','BlancaLuz':'#FFFFFF',
          'BoteA':'#E07C39','BoteB':'#E8D9B5','Agua':'#1C4A5B'}
    for k,c in cols.items():
        if k in M:
            M[k]=mat('MAT_Crucero_'+k,c,0.8,0.0,0.3 if k.endswith('Luz') else None)
    total=0; objs=0
    for k,(vs,fs) in g.d.items():
        if not vs: continue
        me=bpy.data.meshes.new('MESH_'+k); me.from_pydata(vs,[],fs); me.update()
        bm=bmesh.new(); bm.from_mesh(me); bmesh.ops.recalc_face_normals(bm,faces=bm.faces); bm.to_mesh(me); bm.free()
        me.materials.append(M[k])
        o=bpy.data.objects.new('SM_Crucero_'+k,me); bpy.context.scene.collection.objects.link(o)
        total+=len(vs); objs+=1
    return total,objs

def add_context():
    # mar y rig, no exportables
    vs=[(-130,-130,-0.35),(130,-130,-0.35),(130,130,-0.35),(-130,130,-0.35)]
    me=bpy.data.meshes.new('CTX_Mar_Mesh'); me.from_pydata(vs,[],[(0,1,2,3)]); me.update()
    me.materials.append(mat('MAT_Crucero_Agua','#1C4A5B',0.35))
    o=bpy.data.objects.new('CTX_Mar',me); bpy.context.scene.collection.objects.link(o)
    def area(tag,loc,e,size):
        d=bpy.data.lights.new(tag,'AREA'); d.energy=e; d.shape='DISK'; d.size=size
        q=bpy.data.objects.new(tag,d); bpy.context.scene.collection.objects.link(q); q.location=loc
        q.rotation_euler=(Vector((0,0,6))-q.location).to_track_quat('-Z','Y').to_euler()
    area('HY4F_Sol',(45,-35,60),260000,30)
    area('HY4F_Relleno',(-50,25,35),90000,25)
    w=bpy.data.worlds.new('HY4F_Cielo'); bpy.context.scene.world=w; w.use_nodes=True
    w.node_tree.nodes.get('Background').inputs['Color'].default_value=(0.22,0.31,0.38,1)
    w.node_tree.nodes.get('Background').inputs['Strength'].default_value=0.85
    return [
      ('tres_cuartos',(70,76,40),(0,0,8),'PERSP',40),
      ('perfil',(120,0,16),(0,0,8),'PERSP',45),
      ('cenital',(0,0,150),(0,0,0),'ORTHO',90),
      ('proa',(30,95,24),(0,10,8),'PERSP',38),
      ('popa',(-28,-92,26),(0,-10,8),'PERSP',38),
    ]

def render_views(views):
    sc=bpy.context.scene
    sc.render.engine='BLENDER_EEVEE_NEXT'
    sc.render.resolution_x=1280; sc.render.resolution_y=720
    sc.render.resolution_percentage=100; sc.render.image_settings.file_format='PNG'
    for name,loc,tgt,typ,lens in views:
        d=bpy.data.cameras.new('HY4F_Cam_'+name); d.type=typ
        if typ=='ORTHO': d.ortho_scale=lens
        else: d.lens=lens
        cam=bpy.data.objects.new('HY4F_Cam_'+name,d); sc.collection.objects.link(cam)
        cam.location=loc
        up='X' if name=='cenital' else 'Y'
        cam.rotation_euler=(Vector(tgt)-cam.location).to_track_quat('-Z',up).to_euler()
        sc.camera=cam
        sc.render.filepath=os.path.join(OUT,'buque_HY4F_v2_%s.png'%name)
        bpy.ops.render.render(write_still=True)
        print('VIEW',name,os.path.getsize(sc.render.filepath))

lines=[]
for lod in ('alta','media','baja'):
    g=build(lod)
    v,o=realize(g,lod)
    if lod=='alta':
        views=add_context(); render_views(views)
    else:
        # sin contexto en LOD exportables
        pass
    bpy.context.scene.camera=None
    dst=os.path.join(OUT,'buque_HY4F_v2_%s.blend'%lod)
    bpy.ops.wm.save_as_mainfile(filepath=dst)
    lines.append('%s: %d vertices, %d objetos de material, archivo %s'%(lod,v,o,os.path.basename(dst)))
    print('LOD',lines[-1])

Path=os.path.join(OUT,'METRICAS-LOD.txt')
with open(Path,'w',encoding='utf-8') as f:
    f.write('\n'.join(lines)+'\n')
print('DONE')
