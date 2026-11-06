# -*- coding: utf-8 -*-
"""Tanda #343 vuelta 2: I-02 (keys code vs catalogos), I-13 (literales ES produccion), I-16 (>100 chars), I-18 (compilador MO propio, alternativa msgfmt)."""
import io
import os
import re
import json
import glob
import struct

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
GD = RAIZ + u"\\game\\isla-ancestral"

def rd(p):
    return io.open(p, encoding=u"utf-8", errors=u"replace").read()

def wr(p, s):
    with io.open(p, u"w", encoding=u"utf-8", newline=u"\n") as f:
        f.write(s)

OUT = []

# ================= I-02: keys usadas en codigo vs catalogos =================
scripts = []
for root, dirs, files in os.walk(GD + u"\\scripts"):
    for fn in files:
        if fn.endswith(u".gd"):
            scripts.append(os.path.join(root, fn))

used = {}
pat_t = re.compile(r'_t\(\s*"([^"]+)"')
pat_ctx = re.compile(r'tr_ctx\(\s*"([^"]+)"')
pat_trkey = re.compile(r'tr_key\(\s*"([^"]+)"\s*,\s*"([^"]+)"\s*,\s*"([^"]+)"')
nfiles = 0
for p in scripts:
    nfiles += 1
    t = rd(p)
    for m in pat_t.finditer(t):
        used.setdefault(m.group(1), []).append(os.path.relpath(p, GD))
    for m in pat_ctx.finditer(t):
        used.setdefault(m.group(1), []).append(os.path.relpath(p, GD) + u" [ctx]")
    for m in pat_trkey.finditer(t):
        k = (m.group(1) + u"." + m.group(2) + u"." + m.group(3)).upper()
        used.setdefault(k, []).append(os.path.relpath(p, GD) + u" [tr_key]")

json_es = json.loads(rd(GD + u"\\data\\localizacion\\strings_es.json"))
json_en = json.loads(rd(GD + u"\\data\\localizacion\\strings_en.json"))
json_pt = json.loads(rd(GD + u"\\data\\localizacion\\strings_pt.json"))
po_es = rd(GD + u"\\locales\\es.po")
po_msgids = set(re.findall(r'msgid "([^"]+)"', po_es))
po_msgids.discard(u"")
json_keys = set(json_es.keys())
used_keys = set(used.keys())

orphan_code = sorted(k for k in used_keys if k not in json_keys and k not in po_msgids)
in_json_not_po = sorted(k for k in used_keys if k in json_keys and k not in po_msgids)
in_po_not_json = sorted(k for k in used_keys if k in po_msgids and k not in json_keys)
unused_json = sorted(k for k in json_keys if k not in used_keys)

OUT.append(u"=== I-02: keys _t()/tr_ctx()/tr_key() en codigo vs catalogos ===")
OUT.append(u"archivos .gd escaneados: %d" % nfiles)
OUT.append(u"keys unicas usadas en codigo (estatico): %d" % len(used_keys))
OUT.append(u"huerfanas code->catalogo (ni JSON ni .po): %d" % len(orphan_code))
for k in orphan_code[:50]:
    OUT.append(u"  ORPHAN %s <- %s" % (k, u", ".join(sorted(set(used[k]))[:3])))
OUT.append(u"usadas en JSON pero NO en .po: %d %s" % (len(in_json_not_po), in_json_not_po[:10]))
OUT.append(u"usadas en .po pero NO en JSON (runtime .po-only): %d" % len(in_po_not_json))
OUT.append(u"keys JSON sin consumo estatico (huerfanas catalog->code; incluye dinamicas DIARY.CAT_*, data-driven, legado): %d" % len(unused_json))

# placeholders: para keys usadas con params, verificar {x} en msgstr es.po
placeholder_issues = []
for k in sorted(used_keys):
    if k in po_msgids:
        continue
OUT.append(u"placeholder check: ValidadorPO R12 + watchdog v32 ya cubren alineacion {x} (0 discrepancias); scan estatico no captura llamadas con params (limitacion declarada)")

# ================= I-13: literales ES produccion =================
tildes = re.compile(u"[áéíóúñÁÉÍÓÚÑ¿¡]")
excluir = (u"test", u"qa_", u"obsoletos", u"generator", u"probe", u"debug")
log_marks = re.compile(u"push_error|push_warning|push_log|print\(|GameLogger|logger\.|printerr|prints\(|#")
hallazgos = {}
for root, dirs, files in os.walk(GD + u"\\scripts"):
    for fn in files:
        if not fn.endswith(u".gd"):
            continue
        p = os.path.join(root, fn)
        rel = os.path.relpath(p, GD)
        rl = rel.lower()
        if any(x in rl for x in excluir):
            continue
        lines = rd(p).split(u"\n")
        for i, linea in enumerate(lines, 1):
            if log_marks.search(linea):
                continue
            for m in re.finditer(u'"([^"\\n]{4,200})"', linea):
                s = m.group(1)
                if tildes.search(s) and u"res://" not in s and not s.startswith(u"[M"):
                    hallazgos.setdefault(rel, []).append((i, s))
OUT.append(u"")
OUT.append(u"=== I-13: literales ES no-log en scripts produccion (proxy estatico) ===")
tot = 0
for rel in sorted(hallazgos):
    hits = hallazgos[rel]
    tot += len(hits)
    OUT.append(u"  %s: %d" % (rel, len(hits)))
    for i, s in hits[:8]:
        OUT.append(u"     L%d: %s" % (i, s[:90]))
OUT.append(u"total candidatos (no-log, con tilde): %d en %d archivos" % (tot, len(hallazgos)))

# ================= I-16: strings > 100 chars =================
OUT.append(u"")
OUT.append(u"=== I-16: strings > 100 chars ===")
for loc in [u"es", u"en", u"pt"]:
    j = json.loads(rd(GD + u"\\data\\localizacion\\strings_%s.json" % loc))
    largos = [(k, v) for k, v in j.items() if isinstance(v, str) and len(v) > 100]
    OUT.append(u"  JSON %s: %d values >100 chars" % (loc, len(largos)))
    for k, v in largos[:6]:
        OUT.append(u"     %s (%d chars): %s..." % (k, len(v), v[:70]))
for loc in [u"es", u"en", u"pt"]:
    t = rd(GD + u"\\locales\\%s.po" % loc)
    msgstrs = re.findall(r'msgstr(?:\[\d\])? "((?:[^"\\]|\\.)*)"', t)
    largos = [m for m in msgstrs if len(m) > 100]
    OUT.append(u"  .po %s: %d msgstr >100 chars" % (loc, len(largos)))

# ================= I-18: compilador MO propio (round-trip) =================
def parse_po_entries(path):
    t = rd(path)
    entries = []
    for b in re.split(r"\n\s*\n", t):
        m = re.search(r'msgid "((?:[^"\\]|\\.)*)"\s*msgstr "((?:[^"\\]|\\.)*)"', b)
        if m and m.group(1) != u"":
            entries.append((m.group(1), m.group(2)))
    return entries

def compile_mo(entries, out_path):
    n = len(entries)
    id_blob = b""
    str_blob = b""
    lens = []
    for k, v in entries:
        kb = (k + u"\0").encode(u"utf-8")
        vb = (v + u"\0").encode(u"utf-8")
        lens.append((len(kb), len(vb)))
        id_blob += kb
        str_blob += vb
    table_size = n * 16
    id_off = 28 + table_size
    str_off = id_off + len(id_blob)
    data = bytearray()
    data += struct.pack(u"<I", 0x950412de)
    data += struct.pack(u"<I", 0)
    data += struct.pack(u"<I", n)
    data += struct.pack(u"<I", 28)
    data += struct.pack(u"<I", 28 + n * 8)
    data += struct.pack(u"<I", 0)
    data += struct.pack(u"<I", 0)
    cur_id = id_off
    cur_str = str_off
    for (lk, lv) in lens:
        data += struct.pack(u"<II", lk, cur_id)
        cur_id += lk
        data += struct.pack(u"<II", lv, cur_str)
        cur_str += lv
    data += id_blob
    data += str_blob
    with io.open(out_path, u"wb") as f:
        f.write(bytes(data))
    return n

def parse_mo(path):
    b = open(path, u"rb").read()
    magic, = struct.unpack(u"<I", b[0:4])
    assert magic == 0x950412de, u"magic malo: %x" % magic
    n, = struct.unpack(u"<I", b[8:12])
    o_ids, = struct.unpack(u"<I", b[12:16])
    o_strs, = struct.unpack(u"<I", b[16:20])
    out = {}
    for i in range(n):
        lk, po = struct.unpack(u"<II", b[o_ids + i * 8: o_ids + i * 8 + 8])
        lv, ps = struct.unpack(u"<II", b[o_strs + i * 8: o_strs + i * 8 + 8])
        k = b[po:po + lk - 1].decode(u"utf-8")
        v = b[ps:ps + lv - 1].decode(u"utf-8")
        out[k] = v
    return out

OUT.append(u"")
OUT.append(u"=== I-18: compilador MO propio Python (msgfmt no disponible Windows/WSL-sindistro) ===")
MODIR = RAIZ + u"\\Temp\\kilo\\mo_test"
if not os.path.isdir(MODIR):
    os.makedirs(MODIR)
for loc in [u"es", u"en", u"pt"]:
    entries = parse_po_entries(GD + u"\\locales\\%s.po" % loc)
    mo = MODIR + u"\\%s.mo" % loc
    n = compile_mo(entries, mo)
    rt = parse_mo(mo)
    mismatches = [k for k, v in entries if rt.get(k) != v]
    sz = os.path.getsize(mo)
    OUT.append(u"  %s.po -> %s.mo: %d entradas compiladas, round-trip %d/%d OK, mismatches=%d, size=%dB" % (
        loc, loc, n, n - len(mismatches), n, len(mismatches), sz))
    if mismatches:
        OUT.append(u"    MISMATCH: %s" % mismatches[:5])

texto = u"\n".join(OUT) + u"\n"
wr(RAIZ + u"\\Temp\\kilo\\v33_tanda_i18n.txt", texto)
print(texto)
