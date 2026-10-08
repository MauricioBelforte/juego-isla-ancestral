import sys

raw = open("CHECKLIST-GLOBAL.md", "rb").read()
crlf = raw.count(b"\r\n")
cr = raw.count(b"\r")
lf = raw.count(b"\n")
bom = raw[:3] == b"\xef\xbb\xbf"
print("CRLF=%d CR=%d LF=%d BOM=%s" % (crlf, cr, lf, bom))
lines = raw.split(b"\n")
idx = [i for i, ln in enumerate(lines) if ln.startswith(b"| 37 |")]
print("fila37 idx:", idx)
if idx:
    row = lines[idx[0]]
    print("cols:", row.decode("utf-8").count("|") - 1)
    print("termina en CR:", row.endswith(b"\r"))
