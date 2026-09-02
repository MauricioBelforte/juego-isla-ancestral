import os, re
root = 'game/isla-ancestral'
defined = set()
files = []
for dp, _, fns in os.walk(root):
    for fn in fns:
        if fn.endswith('.gd'):
            fp = os.path.join(dp, fn)
            files.append(fp)
            txt = open(fp, encoding='utf-8', errors='ignore').read()
            for m in re.finditer(r'^\s*class_name\s+([A-Za-z_][A-Za-z0-9_]*)', txt, re.M):
                defined.add(m.group(1))

# builtins comunes de Godot (no son class_name)
builtins = set('''Node Node2D Node3D Control Label Button Panel VBoxContainer HBoxContainer
CanvasLayer RefCounted Resource Texture Texture2D PackedScene Dictionary Array
String StringName Vector2 Vector3 Color Rect2 Basis Transform3D NodePath
FileAccess DirAccess ConfigFile JSON Time OS Engine ProjectSettings
Object MainLoop SceneTree Camera3D CharacterBody3D StaticBody3D Area3D
CollisionShape3D MeshInstance3D AudioStreamPlayer Sprite2D AudioStream
Curve Curve2D Gradient ResourceLoader Image ImageTexture Font FontFile
AcceptDialog Window Popup WindowManager SubViewport Mesh BoxMesh
AnimationPlayer Tween Timer RandomNumberGenerator Crypto RandomNumberGenerator
Mutex Semaphore Thread PacketPeer UDPPacketPeer TCPServer StreamPeer
XMLParser JSONRPC GodotSharp'''.split())

# Buscar usos: extends Nombre  y  Nombre.metodo / Nombre.new(
# para 'extends', ignorar tipos builtin y rutas (contienen /)
extends_bad = []
static_bad = []
for fp in files:
    txt = open(fp, encoding='utf-8', errors='ignore').read()
    for m in re.finditer(r'^\s*extends\s+([A-Za-z_][A-Za-z0-9_]*)', txt, re.M):
        n = m.group(1)
        if n in defined or n in builtins:
            continue
        # podria ser un script con ruta? no, extends con ruta usa ""
        if n[0].isupper() and n not in ('RefCounted',):
            extends_bad.append((fp.replace(root+os.sep,''), n))
    # llamadas estaticas a clases: Ident.metodo(  o Ident.new(
    for m in re.finditer(r'(?<![.\w])([A-Z][A-Za-z0-9_]*)\.(new|validar|registrar|get_|set_|create|parse|load|open|emit|obtener|iniciar|configurar)\b', txt):
        n = m.group(1)
        if n in defined or n in builtins:
            continue
        static_bad.append((fp.replace(root+os.sep,''), n))

print('class_name definidas:', len(defined))
print('\n=== extends a clase inexistente (POSIBLE BUG) ===')
seen=set()
for f,n in extends_bad:
    if (f,n) in seen: continue
    seen.add((f,n)); print('  ', f, '-> extends', n)
print('\n=== uso estatico de clase inexistente (POSIBLE BUG) ===')
seen=set()
for f,n in static_bad:
    if (f,n) in seen: continue
    seen.add((f,n)); print('  ', f, '->', n)
print('\nTotal extends-bad:', len(extends_bad), '| static-bad:', len(static_bad))
