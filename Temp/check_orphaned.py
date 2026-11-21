import os, glob, re
os.chdir(r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral")

# Get all GD files, normalized to relative paths from game/isla-ancestral/
gd_files = set()
for f in glob.glob('game/isla-ancestral/**/*.gd', recursive=True):
    # Normalize to res:// style
    rel = f.replace('game/isla-ancestral/', '', 1).replace('\\', '/')
    gd_files.add(rel)

referenced = set()
# Check .tscn references
for tscn in glob.glob('game/isla-ancestral/**/*.tscn', recursive=True):
    with open(tscn, encoding='utf-8') as f:
        text = f.read()
    for m in re.finditer(r'script="?(res://[^"\s]+)"?', text):
        val = m.group(1).strip('"').strip("'")
        if val.startswith('res://'):
            referenced.add(val[6:])
    for m in re.finditer(r'ext_resource[^"]*"res://([^"]+)"', text):
        referenced.add(m.group(1))

# Check .gd references
for gd in gd_files:
    path = 'game/isla-ancestral/' + gd
    if not os.path.exists(path):
        continue
    with open(path, encoding='utf-8') as f:
        text = f.read()
    for m in re.finditer(r'(?:preload|load)\("res://([^"]+)"\)', text):
        referenced.add(m.group(1))
    for m in re.finditer(r'res://([^"\s]+\.gd)', text):
        referenced.add(m.group(1))

# Normalize and compare
orphaned = []
for f in gd_files:
    if f in referenced:
        continue
    # Also check if referenced by name (class_name matching)
    base = os.path.basename(f)
    stem = os.path.splitext(base)[0]
    found = False
    for ref in referenced:
        if stem.lower() in ref.lower():
            found = True
            break
    if not found:
        orphaned.append(f)

# Filter out addons, tests, tools
orphaned = [o for o in orphaned if not o.startswith('addons/') and not o.startswith('tests/') and not o.startswith('tools/') and not o.startswith('_')]
print('GD files total: %d' % len(gd_files))
print('Referenced: %d' % len(referenced))
print('Orphaned (sin addons/tests/tools/_): %d' % len(orphaned))
for o in sorted(orphaned)[:30]:
    print(' ', o)
