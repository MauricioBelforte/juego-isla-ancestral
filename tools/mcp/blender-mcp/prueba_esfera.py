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

r = bc('get_viewport_screenshot', {})
print('status:', r.get('status'))
res = r.get('result', {})
if isinstance(res, dict) and 'base64_image' in res:
    img = base64.b64decode(res['base64_image'])
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'captura_esfera.png')
    with open(out, 'wb') as f:
        f.write(img)
    print('guardada:', out, len(img), 'bytes')
else:
    print('respuesta:', json.dumps(r, ensure_ascii=False)[:400])
