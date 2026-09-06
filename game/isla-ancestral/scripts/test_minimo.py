import bpy
import math
import bmesh

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)

m = bpy.data.materials.new("TEST_ROJO")
m.use_nodes = True
m.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (1.0, 0.0, 0.0, 1.0)
m.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.5

bpy.ops.mesh.primitive_cube_add(size=0.3, location=(0, 0, 0.15))
cubo = bpy.context.active_object
cubo.data.materials.append(m)

# cilindro bmesh
import bmesh
bm = bmesh.new()
for a in range(8):
    ang = 2 * 3.14159 * a / 8
    bm.verts.new((0.1 * math.cos(ang) + 0.3, 0.1 * math.sin(ang), 0.15))
for a in range(8):
    ang = 2 * 3.14159 * a / 8
    bm.verts.new((0.1 * math.cos(ang) + 0.3, 0.1 * math.sin(ang), 0.30))
bm.verts.ensure_lookup_table()
for k in range(8):
    a = (k + 1) % 8
    bm.faces.new((bm.verts[k], bm.verts[a], bm.verts[8 + a], bm.verts[8 + k]))
me = bpy.data.meshes.new("M_Test_Bmesh")
bm.to_mesh(me)
bm.free()
bmesh_obj = bpy.data.objects.new("Bmesh_Test", me)
bpy.context.scene.collection.objects.link(bmesh_obj)
bmesh_obj.data.materials.append(m)

bpy.ops.object.camera_add(location=(0.5, -0.5, 0.3), rotation=(1.1, 0, 0.6))
bpy.context.scene.camera = bpy.context.active_object
bpy.ops.object.light_add(type="SUN", location=(1, -1, 2))
bpy.context.active_object.data.energy = 5.0
bpy.context.active_object.rotation_euler = (0.785, 0, -0.524)
bpy.ops.object.light_add(type="AREA", location=(-0.5, -0.5, 0.5))
l2 = bpy.context.active_object
l2.data.energy = 100
l2.data.size = 1.0

sc = bpy.context.scene
sc.render.engine = "CYCLES"
sc.cycles.device = "CPU"
sc.cycles.samples = 32
sc.render.resolution_x = 400
sc.render.resolution_y = 400
sc.render.image_settings.file_format = "PNG"
sc.render.filepath = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\36-Fauna\capturas\test_minimo_rojo.png"
bpy.ops.render.render(write_still=True)
print("TEST MINIMO COMPLETO")
