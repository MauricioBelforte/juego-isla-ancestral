# -*- coding: utf-8 -*-
"""Normaliza a LF los 3 txt de salida del detector (artifacts Temp/kilo, CRLF por traduccion Windows)."""
import os

d = os.path.dirname(os.path.abspath(__file__))
while d and not os.path.isdir(os.path.join(d, ".git")):
    d = os.path.dirname(d)
ROOT = d

for f in ["v25_detector_v8.txt", "v25_detector_v8_final.txt", "v25_v7_snap.txt"]:
    p = os.path.join(ROOT, "Temp", "kilo", f)
    raw = open(p, "rb").read()
    n = raw.count(b"\r\n")
    raw2 = raw.replace(b"\r\n", b"\n")
    with open(p, "wb") as fh:
        fh.write(raw2)
    print("%s: %d CRLF normalizados a LF (%d bytes)" % (f, n, len(raw2)))
