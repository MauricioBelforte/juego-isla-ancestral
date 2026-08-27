#!/usr/bin/env python3
"""
prueba_esfera.py — Helper Blender MCP: crea esfera + material naranja,
captura screenshot, todo vía el socket 9876.
"""
import json, socket, time

def send(type_, params=None):
    s = socket.create_connection(("localhost", 9876), timeout=30)
    s.send(json.dumps({"type": type_, "params": params or {}}).encode())
    data = b""
    s.settimeout(30)
    try:
        while True:
            chunk = s.recv(65536)
            if not chunk:
                break
            data += chunk
    except:
        pass
    s.close()
    return data.decode()

def main():
    # Crear esfera con material naranja
    code = """
import bpy
bpy.ops.object.delete()  # limpiar escena
bpy.ops.mesh.primitive_uv_sphere_add(radius=1, location=(0,0,1))
esfera = bpy.context.object
esfera.name = "EsferaPrueba"
mat = bpy.data.materials.new("MatEsferaNaranja")
mat.use_nodes = True
bsdf = mat.node_tree.nodes.get("Principled BSDF")
bsdf.inputs["Base Color"].default_value = (1, 0.5, 0, 1)  # naranja
esfera.data.materials.append(mat)
bpy.ops.object.shade_smooth()
"""
    send("execute_code", {"code": code})
    time.sleep(1)
    # Capturar viewport screenshot
    resp = send("get_viewport_screenshot", {"filepath": "cap_esfera.png", "method": "offscreen"})
    print("Esfera creada + captura solicitada:", resp[:100])

if __name__ == "__main__":
    main()