#!/usr/bin/env python3
"""
bpy_cliente.py — Cliente TCP del socket BlenderMCP (puerto 9876).
Reutilizable desde línea de comandos o como módulo Python.

Uso como CLI:
  python bpy_cliente.py get_scene_info
  python bpy_cliente.py execute_code "bpy.ops.mesh.primitive_cube_add()"
  python bpy_cliente.py get_viewport_screenshot "C:/tmp/cap.png"

Uso como módulo:
  from bpy_cliente import blender_command
  resp = blender_command("get_scene_info")
"""
import json
import socket
import sys
import time

HOST = "localhost"
PORT = 9876


def blender_command(type_, params=None, timeout=60):
    """Envía un comando JSON al socket de BlenderMCP y devuelve la respuesta parseada."""
    s = socket.create_connection((HOST, PORT), timeout=timeout)
    try:
        s.send(json.dumps({"type": type_, "params": params or {}}).encode())
        s.settimeout(timeout)
        data = b""
        while True:
            chunk = s.recv(65536)
            if not chunk:
                break
            data += chunk
            try:
                json.loads(data.decode())
                break  # respuesta completa recibida
            except Exception:
                continue  # seguir recibiendo
    finally:
        s.close()
    return json.loads(data.decode())


def puerto_abierto():
    """True si el socket 9876 está escuchando."""
    try:
        s = socket.create_connection((HOST, PORT), timeout=2)
        s.close()
        return True
    except OSError:
        return False


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    type_ = sys.argv[1]
    params = {}
    if len(sys.argv) >= 3:
        # argv[1] del intérprete puede ser la ruta del script (modo directo) o no (con -m)
        # Buscar el primer argumento que no sea opción del intérprete
        args = [a for a in sys.argv[2:] if not a.startswith("-")]
        if type_ == "execute_code":
            params = {"code": " ".join(args)}
        elif type_ == "get_viewport_screenshot":
            params = {"filepath": args[0] if args else "cap_viewport.png", "method": "offscreen"}
        elif args:
            try:
                params = json.loads(args[0])
            except Exception:
                params = {"arg": args[0]}
    # Reintentos breves (Blender puede estar arrancando)
    for intento in range(3):
        try:
            resp = blender_command(type_, params)
            print(json.dumps(resp, indent=2, ensure_ascii=False)[:4000])
            return
        except OSError:
            time.sleep(2)
    print("ERROR: no se pudo conectar al socket %s:%s" % (HOST, PORT))
    sys.exit(2)


if __name__ == "__main__":
    main()
