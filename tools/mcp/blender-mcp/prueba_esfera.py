import json, socket, base64, os

def bc(t, p=None):
    s = socket.create_connection(('localhost', 9876), timeout=120)
    s.send(json.dumps({'type': t, 'params': p or {}}).encode())
    data = b''
    s.settimeout(120)
    try:
        while True:
            c = s.recv(65536)
            if not c:
                break
            data += c
            try:
                json.loads(data.decode())
                break
            except Exception:
                pass
    finally:
        s.close()
    return json.loads(data.decode())

out = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\tools\mcp\blender-mcp\captura_esfera.png'
r = bc('get_viewport_screenshot', {'filepath': out})
print('status:', r.get('status'))
res = r.get('result', {})
print('resultado:', json.dumps(res, ensure_ascii=False)[:300])
if os.path.exists(out):
    print('guardada:', out, os.path.getsize(out), 'bytes')
