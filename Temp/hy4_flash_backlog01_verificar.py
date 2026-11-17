"""Verificacion de formato del backlog 01 (HY4 Flash). Solo lectura."""
from pathlib import Path
import re
from collections import Counter

R = Path('.')
DOC = R / 'DOCUMENTACION'

def lineas(p):
    return p.read_text(encoding='utf-8').splitlines()

def ultima_con_contenido(ls):
    for i in range(len(ls) - 1, -1, -1):
        if ls[i].strip():
            return i + 1, ls[i]
    return 0, ''

print('=== T1/T2/T3: 05-Checklist.md activos ===')
cks = sorted(DOC.glob('*/plan-actual/05-Checklist.md'))
sin_totales, totales_no_final, marcas_raras = [], [], []
for p in cks:
    ls = lineas(p)
    nlast, last = ultima_con_contenido(ls)
    hits = [i + 1 for i, l in enumerate(ls) if re.search(r'(?i)\btotales\b', l)]
    if not hits:
        sin_totales.append(p.as_posix())
    elif nlast not in hits:
        totales_no_final.append((p.as_posix(), hits[-1], nlast, last.strip()[:100]))
    raros = []
    for i, l in enumerate(ls, 1):
        m = re.match(r'^\s*[-*+]\s+\[([^\]]*)\]', l)
        if m and m.group(1) not in ('x', ' ', '?'):
            raros.append((i, m.group(1)))
    if raros:
        marcas_raras.append((p.as_posix(), raros))
print('activos:', len(cks))
print('con Totales en cualquier linea:', len(cks) - len(sin_totales))
print('SIN Totales:', len(sin_totales))
print('con Totales PERO no en la ultima linea con contenido:', len(totales_no_final))
for row in totales_no_final[:12]:
    print('  ', row[0], '| Totales L%d | ultima L%d: %s' % (row[1], row[2], row[3]))
marcas = Counter(m for _, ms in marcas_raras for _, m in ms)
print('archivos con marcas fuera de x/espacio/?:', len(marcas_raras), '| marcas:', dict(marcas))
for p, ms in marcas_raras:
    print('  ', p, '->', ms[:4])

print()
print('=== T4/T5: 04-Codigo.md activos ===')
cod = sorted(DOC.glob('*/plan-actual/04-Codigo.md'))
sin_logs = []
for p in cod:
    t = p.read_text(encoding='utf-8')
    if not re.search(r'^#{2,4}\s+.*\blogs?\b', t, flags=re.I | re.M):
        heads = [l for l in t.splitlines() if l.startswith('## ')]
        sin_logs.append((p.as_posix(), heads[-3:]))
print('activos:', len(cod), '| SIN seccion Logs:', len(sin_logs))
for p, heads in sin_logs[:12]:
    print('  ', p, '| headings fin:', heads[-2:])

print()
print('=== T6/T7: indices GUIA-GODOT / GUIA-BLENDER ===')
for guia in ('GUIA-GODOT', 'GUIA-BLENDER'):
    carpeta = DOC / guia
    idx = carpeta / 'INDICE.md'
    texto = idx.read_text(encoding='utf-8')
    refs = {Path(x).name for x in re.findall(r'[\wÀ-ÿ\-\./]+\.md', texto)}
    reales = {p.name for p in carpeta.glob('*.md')} - {'INDICE.md'}
    print(guia, '| .md reales:', len(reales), '| referenciados:', len(refs))
    print('  citados pero AUSENTES:', sorted(refs - reales - {'INDICE.md'}))
    print('  existentes pero NO citados:', sorted(reales - refs))

print()
print('=== T8: plantilla seccion 4 de 11-BUGS.md ===')
bugs_path = DOC / '11-BUGS.md'
bl = lineas(bugs_path)
inicio = next((i for i, l in enumerate(bl) if l.startswith('## 4.')), None)
fin = next((i for i, l in enumerate(bl) if l.startswith('## 5.')), None)
plantilla = '\n'.join(bl[inicio:fin]) if inicio is not None and fin is not None else ''
campos = ['Plantilla de Registro de Bug', 'Fecha de reporte', 'Módulo(s) afectado(s)',
          'Severidad', 'Prioridad sugerida', '**Estado:**', 'Descripción del problema',
          'Pasos para reproducir', 'Comportamiento esperado', 'Comportamiento actual',
          'Evidencia', 'Intentos de solución', 'Referencias cruzadas', 'Firma',
          '**Modelo:**', '**Plataforma:**', 'Resolución']
print('seccion 4:', 'PRESENTE' if inicio is not None else 'AUSENTE',
      '| lineas:', (fin - inicio) if inicio is not None and fin is not None else 0)
for c in campos:
    if c not in plantilla:
        print('  FALTA:', c)
print('  campos verificados:', sum(1 for c in campos if c in plantilla), '/', len(campos))

print()
print('=== T9: bugs sin firma ===')
encabezados = [(i, l) for i, l in enumerate(bl) if re.match(r'^### BUG-\d+\b', l)]
print('bloques BUG-NNN detectados:', len(encabezados))
sin_firma, sin_firma_antes_cierre = [], []
for k, (i, l) in enumerate(encabezados):
    j = encabezados[k + 1][0] if k + 1 < len(encabezados) else len(bl)
    bloque = bl[i:j]
    id_bug = re.match(r'### (BUG-\d+)', l).group(1)
    corte = next((q for q, x in enumerate(bloque) if re.match(r'^####\s+(CIERRE|DIAGNÓSTICO|Acuse|Fix)', x)), len(bloque))
    antes = '\n'.join(bloque[:corte])
    if '**Modelo:**' not in '\n'.join(bloque):
        sin_firma.append((id_bug, i + 1))
    if '**Modelo:**' not in antes:
        sin_firma_antes_cierre.append((id_bug, i + 1))
print('sin **Modelo:** en todo el bloque:', len(sin_firma))
print('sin **Modelo:** antes de cierre/diagnostico/fix:', len(sin_firma_antes_cierre))
print('ejemplos (todo el bloque):', sin_firma[:15])
print('ejemplos (antes de cierre):', sin_firma_antes_cierre[:15])

print()
print('=== T10: filas duplicadas en CHECKLIST-GLOBAL.md ===')
gl = lineas(R / 'CHECKLIST-GLOBAL.md')
filas = [(i + 1, l.strip()) for i, l in enumerate(gl)
         if l.strip().startswith('|') and not re.match(r'^\|[\s\-:|]+\|$', l.strip())]
print('lineas totales:', len(gl), '| filas de tabla:', len(filas))
dup = Counter(f for _, f in filas)
repe = [(f, n) for f, n in dup.items() if n > 1]
print('filas EXACTAS duplicadas:', len(repe), '| filas implicadas:', sum(n for _, n in repe))
for f, n in sorted(repe, key=lambda x: -x[1])[:12]:
    print('  x%d %s' % (n, f[:180]))
first_cell = Counter(f.split('|')[1].strip() for _, f in filas)
rep1 = [(k, v) for k, v in first_cell.items() if v > 1]
print('primer celda repetida (puede ser legitimo):', len(rep1), rep1[:12])

print()
print('=== T11: ESTADO-PARALELO.md ===')
ep = R / 'Mensajes entre modelos' / 'ESTADO-PARALELO.md'
epl = lineas(ep)
print('existe:', ep.exists(), '| bytes:', ep.stat().st_size, '| lineas:', len(epl))
heads = [l for l in epl if l.startswith('## ')]
print('encabezados:', len(heads), '| 🔵:', sum('🔵' in h for h in heads),
      '| ✅:', sum('✅' in h for h in heads), '| 🟡:', sum('🟡' in h for h in heads))
ids = set()
for h in heads:
    ids.update(int(n) for n in re.findall(r'\bM(\d{1,3})\b', h))
mods = {int(m.name.split('-')[0]) for m in DOC.iterdir() if m.is_dir() and re.match(r'^\d{2,3}-', m.name)}
print('ids de modulo citados en encabezados:', len(ids))
print('citados SIN carpeta de modulo:', sorted(ids - mods))
fechas = [f for h in heads for f in re.findall(r'\b20\d\d-\d\d-\d\d\b', h)]
print('rango de fechas en encabezados:', min(fechas) if fechas else '-', '..', max(fechas) if fechas else '-')
print('primer encabezado:', heads[0][:120] if heads else '-')
print('ultimo encabezado:', heads[-1][:120] if heads else '-')

print()
print('=== T12: Logs/NUMEROS_DISPONIBLES.txt ===')
pool_path = R / 'Logs' / 'NUMEROS_DISPONIBLES.txt'
pool_txt = pool_path.read_text(encoding='utf-8')
nums = [int(x) for x in pool_txt.split() if x.strip().isdigit()]
print('lineas:', len(pool_txt.splitlines()), '| numeros:', len(nums),
      '| min:', min(nums), '| max:', max(nums))
print('duplicados:', [n for n, c in Counter(nums).items() if c > 1][:20])
huecos = sorted(set(range(min(nums), max(nums) + 1)) - set(nums))
print('huecos internos:', len(huecos), huecos[:30])
usados = set()
for p in (R / 'Logs').glob('*.md'):
    m = re.match(r'^(\d{1,4})-', p.name)
    if m:
        usados.add(int(m.group(1)))
colision = sorted(set(nums) & usados)
print('numeros del pool ya usados por logs .md:', len(colision), colision[:20])
print('logs .md con prefijo numerico:', len(usados))
