# -*- coding: utf-8 -*-
import subprocess, glob, os

def head_eol(p):
    h = subprocess.run(["git", "show", "HEAD:" + p], capture_output=True)
    if h.returncode != 0:
        return None
    d = h.stdout
    return (d.count(b"\r\n"), d.count(b"\r") - d.count(b"\r\n"), d.count(b"\n") - d.count(b"\r\n"))

# M77: restore + re-apply binary
p77 = glob.glob("DOCUMENTACION/77-*")[0].replace("\\", "/") + "/plan-actual/05-Checklist.md"
print("M77 HEAD EOL (CRLF,CR,LF):", head_eol(p77))
subprocess.run(["git", "checkout", "--", p77], check=True)
d = open(p77, "rb").read()
n = d.count(b"[x]")
d = d.replace(b"[x]", b"[?]")
d = d.replace(b"Completados: 4", b"Completados: 0")
d = d.replace(b"No resueltos: 0", b"No resueltos: 4")
# audit note on first degraded line
i = d.find(b"[?] Verificar coherencia")
if i >= 0:
    e = d.find(b"\n", i)
    d = d[:e] + b"  [Auditoria T-agnes 2026-10-06: contractos mp/net ausentes en disco; M77 bloqueada v1 single-player]" + d[e:]
open(p77, "wb").write(d)
print("M77 WT after re-apply: [x] flipped=%d; EOL=(%s)" % (
    n, (d.count(b"\r\n"), d.count(b"\r") - d.count(b"\r\n"), d.count(b"\n") - d.count(b"\r\n"))))

# M45: check HEAD EOL vs WT
p45 = glob.glob("DOCUMENTACION/45-*")[0].replace("\\", "/") + "/plan-actual/05-Checklist.md"
print("M45 HEAD EOL (CRLF,CR,LF):", head_eol(p45))
d45 = open(p45, "rb").read()
print("M45 WT   EOL (CRLF,CR,LF):", (d45.count(b"\r\n"), d45.count(b"\r") - d45.count(b"\r\n"), d45.count(b"\n") - d45.count(b"\r\n")))
print("M45 [x]=%d [?]=%d" % (d45.count(b"[x]"), d45.count(b"[?]")))
