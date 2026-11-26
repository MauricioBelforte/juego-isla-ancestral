import io, re
p = r'DOCUMENTACION/159-Catalogo-De-Objetos/plan-actual/05-Checklist.md'
raw = io.open(p, encoding='utf-8', newline='').read()
lines = raw.split('\n')
eol = '\r' if any(l.endswith('\r') for l in lines) else ''

# (linea 1-based, token exacto esperado, anotacion)
flips = [
 (131, 'OBJ-COC-001', ' -- HY4F GO 164: 20/20 IDs OBJ-COC-001..020 en data/items/ (iter1 10/10).'),
 (144, 'OBJ-TAL-001', ' -- HY4F GO 164: 10/10 IDs OBJ-TAL-001..010 en data/items/.'),
 (152, 'OBJ-EXT-001', ' -- HY4F GO 164: 20/20 IDs OBJ-EXT-001..020 en data/items/.'),
 (160, 'OBJ-NAT-001', ' -- HY4F GO 164: 10/10 IDs OBJ-NAT-001..010 en data/items/.'),
 (161, 'OBJ-NAT-011', ' -- HY4F GO 164: 7/7 IDs OBJ-NAT-011..017 en data/items/.'),
 (162, 'OBJ-NAT-018', ' -- HY4F GO 164: 11/11 IDs OBJ-NAT-018..028 en data/items/.'),
 (173, 'OBJ-CON-001', ' -- HY4F GO 164: 15/15 IDs OBJ-CON-001..015 en data/items/.'),
 (181, 'OBJ-HER-001', ' -- HY4F GO 164: 20/20 IDs OBJ-HER-001..020 en data/items/.'),
 (189, 'OBJ-ITE-001', ' -- HY4F GO 164: 15/15 IDs OBJ-ITE-001..015 en data/items/.'),
 (190, 'OBJ-ITE-020', ' -- HY4F GO 164: 20/20 IDs OBJ-ITE-020..039 en data/items/.'),
 (191, 'OBJ-ITE-050', ' -- HY4F GO 164: 8/8 IDs OBJ-ITE-050..057 en data/items/.'),
 (202, 'OBJ-ROP-001', ' -- HY4F GO 164: iter1 5/5 IDs OBJ-ROP-001..005 en data/items/ (15/20 pendientes).'),
 (210, 'OBJ-ART-001', ' -- HY4F GO 164: iter1 5/5 IDs OBJ-ART-001..005 en data/items/ (7/12 pendientes).'),
 (218, 'OBJ-EVE-001', ' -- HY4F GO 164: iter1 5/5 IDs OBJ-EVE-001..005 en data/items/ (7/12 pendientes).'),
 (226, 'OBJ-SEC-001', ' -- HY4F GO 164: iter1 5/5 IDs OBJ-SEC-001..005 en data/items/ (7/12 pendientes).'),
]

for n, token, note in flips:
    txt = lines[n-1]
    core = txt[:-1] if txt.endswith('\r') else txt
    if not core.startswith('- [?] ') or token not in core:
        raise SystemExit('LINEA %d NO COINCIDE: %r' % (n, core[:110]))
    if 'HY4F GO 164' in core:
        raise SystemExit('YA APLICADA: %d' % n)
    new = core.replace('- [?] ', '- [x] ', 1) + note
    lines[n-1] = new + ('\r' if txt.endswith('\r') else '')

out = '\n'.join(lines)
with io.open(p, 'w', encoding='utf-8', newline='') as f:
    f.write(out)
print('FLIPS APLICADOS:', len(flips))

t = io.open(p, encoding='utf-8', newline='').read()
print('marcas M159: x=%d [ ]=%d ?=%d' % (
 len(re.findall(r'^\s*-\s+\[x\]', t, re.M)),
 len(re.findall(r'^\s*-\s+\[ \]', t, re.M)),
 len(re.findall(r'^\s*-\s+\[\?\]', t, re.M))))
b = open(p,'rb').read()
print('bom', b[:3]==b'\xef\xbb\xbf', 'CR', b.count(b'\r'), 'LF', b.count(b'\n'))
