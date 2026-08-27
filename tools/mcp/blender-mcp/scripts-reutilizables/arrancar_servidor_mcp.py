#!/usr/bin/env python3
"""
arrancar_servidor_mcp.py — Se ejecuta DENTRO de Blender al arranque (vía --python).
Activa automáticamente el servidor del addon BlenderMCP en el puerto 9876,
sin necesidad de conectar el panel N a mano.

Uso (PowerShell):
  & "D:\Archivos de programa\Blender Foundation\Blender 4.2\blender.exe" --python "ruta\a\arrancar_servidor_mcp.py"
"""
import bpy

def main():
    try:
        # Si el servidor ya corre, no hacer nada
        scene = bpy.context.scene
        if getattr(scene, "blendermcp_server_running", False):
            print("[BlenderMCP] El servidor ya estaba corriendo (puerto %s)" % scene.blendermcp_port)
            return
        bpy.ops.blendermcp.start_server()
        print("[BlenderMCP] Servidor iniciado OK (puerto 9876)")
    except AttributeError:
        print("[BlenderMCP] ERROR: operator blendermcp.start_server no disponible.")
        print("[BlenderMCP] El addon 'Blender MCP' NO está habilitado en esta instalación de Blender.")
        print("[BlenderMCP] Reinstalarlo: Edit > Preferences > Add-ons > (˅) Install from Disk...")
        print("[BlenderMCP] Seleccionar: tools/mcp/blender-mcp/addon.py")
    except Exception as e:
        print("[BlenderMCP] ERROR inesperado: %r" % e)

main()
