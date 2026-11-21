import os, re, glob
base = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
os.chdir(base)

# Check pt.po translation coverage
po_files = glob.glob('game/isla-ancestral/locales/*.po')
for po in po_files:
    with open(po, encoding='utf-8') as f:
        text = f.read()
    msgid = len(re.findall(r'^msgid\s', text, re.M))
    msgstr_ne = len(re.findall(r'^msgstr\s+".+"', text, re.M))
    empty = len(re.findall(r'^msgstr\s+""', text, re.M))
    print('%s: %d msgid, %d traducido, %d vacio (%d%%)' % (os.path.basename(po), msgid, msgstr_ne, empty, int(100*msgstr_ne/msgid) if msgid else 0))

# Check .tres files
tres = glob.glob('game/isla-ancestral/**/*.tres', recursive=True)
print()
print('Total .tres: %d' % len(tres))

# Check audio
audio = glob.glob('game/isla-ancestral/assets/**/*', recursive=True)
audio_files = [a for a in audio if a.endswith(('.ogg','.wav','.mp3','.flac'))]
print()
print('Audio files: %d' % len(audio_files))
for f in audio_files[:15]:
    print(' ', f)

# Check .import files
imports = glob.glob('game/isla-ancestral/**/*.import', recursive=True)
print()
print('.import files: %d' % len(imports))

# Check data files
data = glob.glob('game/isla-ancestral/data/**/*.json', recursive=True) + glob.glob('game/isla-ancestral/data/**/*.tres', recursive=True)
print()
print('Data files: %d' % len(data))

# Check for orphaned .import (no corresponding source file)
orphaned = 0
for imp in imports[:100]:
    src = imp.replace('.import', '')
    if not os.path.exists(src):
        orphaned += 1
print('Orphaned .import (primeros 100): %d' % orphaned)
