"""Tercera pasada: puente, barandas, botes, pileta. Completa el crucero grande."""
import bpy
import bmesh
import math
from mathutils import Vector

def bb(o):
    dg = bpy.context.evaluated_depsgraph_get()
    dg.update()
    oe = o.evaluated_get(dg); me = oe.to_mesh(); mw = oe.matrix_world
    vs = [mw @ v.co for v in me.vertices]; oe.to_mesh_clear()
    return (min(v.x for v in vs), max(v.x for v in vs), min(v.y for v in vs),
            max(v.y for v in vs), min(v.z for v in vs), max(v.z for v in vs))

def M(n): return bpy.data.materials[n]

def caja(name, x0, x1, y0, y1, z0, z1, material):
    bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x = x0 if v.co.x < 0 else x1
        v.co.y = y0 if v.co.y < 0 else y1
        v.co.z = z0 if v.co.z < 0 else z1
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free(); me.update()
    ob = bpy.data.objects.new(name, me)
    bpy.context.scene.collection.objects.link(ob); ob.data.materials.append(material)
    return ob

def contorno(L, B, n=26):
    pts=[]; r=B; rect=L/2-r
    for i in range(n):
        t=i/(n-1); pts.append((B,-rect+t*2*rect))
    for i in range(1,n):
        a=(math.pi/2)*i/(n-1); pts.append((B*math.cos(a), rect+r*math.sin(a)))
    for i in range(n):
        t=i/(n-1); pts.append((-B, rect-t*2*rect))
    for i in range(1,n):
        a=(math.pi/2)*i/(n-1); pts.append((-B*math.cos(a), -rect-r*math.sin(a)))
    return pts

D1 = bb(bpy.data.objects['SM_Crucero_Cubierta_1'])[4]
D4 = bb(bpy.data.objects['SM_Crucero_Cubierta_4'])[4]
c1 = bb(bpy.data.objects['SM_Crucero_Cubierta_1'])
c4 = bb(bpy.data.objects['SM_Crucero_Cubierta_4'])

# ---------------- barandas (piso 1 y piso 4), con postes cada 2,6 m
M_METAL = M('MAT_Crucero_Metal')
for nombre, c in (('SM_Crucero_Baranda_Cub1', c1), ('SM_Crucero_Baranda_Cub4', c4)):
    L = (c[3]-c[2]) - 0.5
    B = (c[1]-c[0])/2 - 0.2
    cont = contorno(L, B)
    bm = bmesh.new()
    for zz, rr in ((D1 if 'Cub1' in nombre else D4, 0.030),):
        pass
    z0 = D1 if 'Cub1' in nombre else D4
    for hh, rr in ((1.05, 0.030), (0.55, 0.022)):
        for (x1_,y1_),(x2_,y2_) in zip(cont, cont[1:]+cont[:1]):
            dx,dy = x2_-x1_, y2_-y1_
            seg = math.hypot(dx,dy)
            if seg < 1e-5: continue
            ang = math.atan2(dy,dx)
            b2=bmesh.new(); bmesh.ops.create_cube(b2,size=1.0)
            for v in b2.verts:
                lx=v.co.x*seg; ly=v.co.y*(rr*2); lz=v.co.z*(rr*2)
                v.co.x=(x1_+x2_)/2 + lx*math.cos(ang) - ly*math.sin(ang)
                v.co.y=(y1_+y2_)/2 + lx*math.sin(ang) + ly*math.cos(ang)
                v.co.z=z0+hh+lz
            m2=bpy.data.meshes.new('t'); b2.to_mesh(m2); b2.free()
            bm.from_mesh(m2); bpy.data.meshes.remove(m2)
    # postes
    total = sum(math.hypot(b[0]-a[0], b[1]-a[1]) for a,b in zip(cont, cont[1:]+cont[:1]))
    n = max(4, int(total/2.6))
    for i in range(n):
        t = i/n*len(cont); k = min(int(t), len(cont)-1); f = t-int(t)
        a, b = cont[k], cont[(k+1) % len(cont)]
        x = a[0]*(1-f)+b[0]*f; y = a[1]*(1-f)+b[1]*f
        b2=bmesh.new(); bmesh.ops.create_cube(b2,size=1.0)
        for v in b2.verts:
            v.co.x=v.co.x*0.07+x; v.co.y=v.co.y*0.07+y; v.co.z=v.co.z*1.11+z0+0.555
        m2=bpy.data.meshes.new('t'); b2.to_mesh(m2); b2.free()
        bm.from_mesh(m2); bpy.data.meshes.remove(m2)
    bm.normal_update()
    me=bpy.data.meshes.new(nombre); bm.to_mesh(me); bm.free(); me.update()
    ob=bpy.data.objects.new(nombre, me)
    bpy.context.scene.collection.objects.link(ob); ob.data.materials.append(M_METAL)

# ---------------- puente (proa del piso 4) + alas + mastil + radar
M_SUPER = M('MAT_Crucero_Super'); M_VID = M('MAT_Crucero_VidrioOscuro'); M_ORO = M('MAT_Crucero_Dorado')
y_proa = c4[2] + 0.6
P = caja('SM_Crucero_Puente', -3.80, 3.80, y_proa, y_proa + 4.2, D4, D4 + 2.9, M_SUPER)
for i in range(6):
    x = -3.0 + i*1.2
    caja('SM_Crucero_Puente_Vidrio_%d'%(i+1), x-0.52, x+0.52, y_proa-0.05, y_proa+0.05, D4+1.05, D4+2.30, M_VID)
for sx, tag in ((1,'E'), (-1,'B')):
    caja('SM_Crucero_Ala_%s'%tag, sx*3.9, sx*6.2, y_proa+0.4, y_proa+2.4, D4, D4+2.2, M_SUPER)
    caja('SM_Crucero_Ala_Vidrio_%s'%tag, sx*3.95, sx*6.15, y_proa+0.42, y_proa+0.52, D4+0.95, D4+1.95, M_VID)
# mastil
bm=bmesh.new(); bmesh.ops.create_cone(bm, cap_ends=True, segments=8, radius1=0.18, radius2=0.12, depth=2.0)
for v in bm.verts:
    v.co.y += y_proa + 2.0; v.co.z += D4 + 2.9 + 1.0
me=bpy.data.meshes.new('SM_Crucero_Mastil'); bm.to_mesh(me); bm.free(); me.update()
ob=bpy.data.objects.new('SM_Crucero_Mastil', me)
bpy.context.scene.collection.objects.link(ob); ob.data.materials.append(M_METAL)
for i, (z, w) in enumerate(((D4+4.55, 3.0), (D4+4.85, 2.4))):
    caja('SM_Crucero_Radar_%d'%(i+1), -w/2, w/2, y_proa+1.94, y_proa+2.06, z, z+0.12, M_METAL)
for i, sx in enumerate((-1, 1)):
    caja('SM_Crucero_Antena_%d'%(i+1), sx*0.18-0.03, sx*0.18+0.03, y_proa+1.96, y_proa+2.02, D4+3.9, D4+5.0, M_METAL)

# ---------------- botes salvavidas + pescantes (banda de botes)
M_ROJO = M('MAT_Crucero_Emergencia')
for i, y in enumerate((-10.0, 0.0, 10.0)):
    for sx, tag in ((1,'E'), (-1,'B')):
        cx = sx*(bb(bpy.data.objects['SM_Crucero_Casco'])[1] + 1.0)
        caja('SM_Crucero_Bote_%s%d'%(tag,i+1), cx-0.6, cx+0.6, y-2.2, y+2.2, D1-1.2, D1-0.4, M_ROJO)
        caja('SM_Crucero_Bote_%s%d_Caseta'%(tag,i+1), cx-0.45, cx+0.45, y-1.0, y+1.0, D1-0.4, D1+0.1, M_SUPER)

# ---------------- pileta, jacuzzis, tumbonas (piso 4)
M_AGUA = M('MAT_Crucero_Agua'); M_CUBI = M('MAT_Crucero_Cubierta'); M_BAM = M('MAT_Crucero_Bambu')
caja('SM_Crucero_Piscina_Borde', -3.2, 3.2, 2.0, 5.4, D4, D4+0.45, M_CUBI)
caja('SM_Crucero_Piscina_Agua', -2.9, 2.9, 2.3, 5.1, D4+0.28, D4+0.42, M_AGUA)
for i, (x, y) in enumerate(((-3.6, -0.6), (3.6, -0.6))):
    caja('SM_Crucero_Jacuzzi_%d'%(i+1), x-0.75, x+0.75, y-0.75, y+0.75, D4, D4+0.5, M_CUBI)
    caja('SM_Crucero_Jacuzzi_Agua_%d'%(i+1), x-0.6, x+0.6, y-0.6, y+0.6, D4+0.35, D4+0.48, M_AGUA)
for i in range(6):
    x = -2.5 + i*1.0
    caja('SM_Crucero_Tumbona_%d'%(i+1), x-0.31, x+0.31, 7.0, 8.75, D4, D4+0.18, M_BAM)

print('puente, barandas, botes y pileta: ok')
print('objetos:', len([o for o in bpy.data.objects if o.type=='MESH']),
      ' verts:', sum(len(o.data.vertices) for o in bpy.data.objects if o.type=='MESH'))