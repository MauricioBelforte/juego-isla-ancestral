# -*- coding: utf-8 -*-
"""Delta v26 Ling (report-only): impacto de las degradaciones de la flota (TANDA 9 DeepSeek + agnes)
sobre los buckets del detector v8. Diff de contadores + lineas de detalle A1/A3 entre
snapshot v8-final (Temp/kilo/v25_detector_v8_final.txt, 2026-10-30 23:26 local) y WT actual
(Temp/kilo/v26_detector_delta.txt, 2026-10-31 ~04:0xZ).
Ademas: verifica M157 L148 (debe seguir [x] con nota reformulada) y blindaje riel PT.
Escribe Temp/kilo/v26_delta_analysis.txt (UTF-8, LF)."""
import io, os, re, hashlib, subprocess

d = os.path.dirname(os.path.abspath(__file__))
while d and not os.path.isdir(os.path.join(d, ".git")):
    d = os.path.dirname(d)
ROOT = d

def rd(p):
    with io.open(os.path.join(ROOT, p), "r", encoding="utf-8", errors="strict") as f:
        return f.read()

v8 = rd("Temp/kilo/v25_detector_v8_final.txt")
v26 = rd("Temp/kilo/v26_detector_delta.txt")

def hdr(txt, pat, default="?"):
    m = re.search(pat, txt)
    return m.group(1) if m else default

def detalle(txt, tag):
    out = {}
    for ln in txt.splitlines():
        if ln.startswith("[%s]" % tag):
            m = re.match(r"\[%s\] (\S+) (L\d+):" % tag, ln)
            if m:
                out["%s %s" % (m.group(1), m.group(2))] = ln
    return out

L = []
def w(s=""):
    L.append(s)

w("DELTA v26 — detector v8: snapshot v8-final (2026-10-30 23:26 local) vs WT actual (2026-10-31 ~04:0xZ)")
w("Fuentes: Temp/kilo/v25_detector_v8_final.txt | Temp/kilo/v26_detector_delta.txt")
w("Causa del movimiento: degradaciones aplicadas por la FLOTA post-v25 (TANDA 9 DeepSeek-V4.1-Flash: 10 AUTO -> 8 reales a [?] + M38 L41; agnes gate-1 por tanda). Report-only Ling: 0 flips propios esta vuelta.")
w("")
w("===== CONTADORES (header del detector) =====")
pares = [
    ("items [x]", r"items \[x\]: (\d+)"),
    ("A1-GRAVE", r"A1-GRAVE flip declarado no aplicado: (\d+)"),
    ("promovidos C2 vecinos", r"promovidos a C2 por vecinos: (\d+)"),
    ("R4-GRAVE", r"R4-GRAVE re-flip Beam-26oct spec sobre disco: (\d+)"),
    ("A3-PENDIENTE-REAL", r"A3-PENDIENTE-REAL/autodescarga step-5 14oct: (\d+)"),
    ("A2-DEUDA", r"A2-DEUDA viva: (\d+)"),
    ("C2-RESUELTO", r"C2-RESUELTO textual: (\d+)"),
    ("SOS sostenidos", r"SOS sostenidos Beam26: (\d+)"),
    ("FP", r"\| FP: (\d+)"),
    ("FORMULA legitimos", r"FORMULA legitimos: (\d+)"),
    ("GRIS diseno", r"GRIS diseno step-5 14oct: (\d+)"),
]
for nombre, pat in pares:
    a, b = hdr(v8, pat), hdr(v26, pat)
    try:
        delta = int(b) - int(a)
        ds = "%s%d" % ("+" if delta >= 0 else "", delta)
    except ValueError:
        ds = "?"
    w("%-22s v8=%-6s v26=%-6s delta %s" % (nombre, a, b, ds))
w("")
w("===== A1/A3 POR MODULO (diff de dicts de header) =====")
for tag in ("A1", "A3"):
    pat = r"### %s por modulo: (\{.*?\})" % tag
    d8 = eval(hdr(v8, pat, "{}"))
    d26 = eval(hdr(v26, pat, "{}"))
    w("--- %s: total v8=%d -> v26=%d ---" % (tag, sum(d8.values()), sum(d26.values())))
    for mod in sorted(set(d8) | set(d26)):
        a, b = d8.get(mod, 0), d26.get(mod, 0)
        if a != b:
            w("  %s: %d -> %d (%s%d)" % (mod, a, b, "+" if b - a >= 0 else "", b - a))
w("")
w("===== LINEAS A1/A3 SALIDAS ENTRE v8 Y v26 (degradadas por la flota) =====")
salidas_total = 0
for tag in ("A1", "A3"):
    b8, b26 = detalle(v8, tag), detalle(v26, tag)
    salieron = sorted(set(b8) - set(b26))
    w("--- %s: %d lineas (v8) -> %d lineas (v26); salieron %d ---" % (tag, len(b8), len(b26), len(salieron)))
    for k in salieron:
        salidas_total += 1
        w("  SALIO %s :: %s" % (k, b8[k][:200]))
w("  TOTAL lineas salidas A1+A3: %d (debe coincidir con delta items [x] = -7)" % salidas_total)
w("")
w("===== M157 L148 (verificacion directa — debe seguir [x] con nota reformulada) =====")
m157 = rd("DOCUMENTACION/157-Medios-De-Transporte/plan-actual/05-Checklist.md").splitlines()
l148 = m157[147] if len(m157) >= 148 else "?"
w("  L148: %s" % l148[:220])
w("  sigue [x]: %s | nota reformulada (alcance cerrado 25oct): %s" % (l148.startswith("- [x]"), "alcance del item cerrado" in l148))
w("")
w("===== BLINDAJE RIEL PT =====")
pt = os.path.join(ROOT, "game/isla-ancestral/locales/pt.po")
sha = hashlib.sha1(open(pt, "rb").read()).hexdigest()[:10]
st = subprocess.run(["git", "status", "--porcelain", "--", "game/isla-ancestral/locales",
                     "game/isla-ancestral/scripts/localization", "game/isla-ancestral/scripts/localizacion",
                     "game/isla-ancestral/data/localizacion"], cwd=ROOT, capture_output=True, text=True)
head = subprocess.run(["git", "rev-parse", "--short", "HEAD"], cwd=ROOT, capture_output=True, text=True).stdout.strip()
w("  pt.po sha1=%s (canonico 95ee2ce0d1) | git status riel: %s | HEAD=%s" % (
    sha, "VACIO" if st.stdout.strip() == "" else "TOCADO:" + st.stdout.strip()[:80], head))

out = "\n".join(L) + "\n"
with io.open(os.path.join(ROOT, "Temp/kilo/v26_delta_analysis.txt"), "w", encoding="utf-8", newline="\n") as f:
    f.write(out)
print(out)
