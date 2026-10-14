# -*- coding: utf-8 -*-
import io

files = [
 ("game/isla-ancestral/scripts/houses/house_interior.gd", [30, 34, 45]),
 ("game/isla-ancestral/scripts/houses/test_m18_sistemas_s2.gd", [17, 29, 45]),
]
for p, lineas in files:
    with io.open(p, "rb") as f:
        raw = f.read()
    print("==", p)
    print("   BOM:", "CON BOM!" if raw[:3] == b"\xef\xbb\xbf" else "sin BOM ok")
    print("   decodifica UTF-8:", end=" ")
    try:
        t = raw.decode("utf-8")
        print("OK")
    except UnicodeDecodeError as e:
        print("FALLO:", e)
        continue
    with io.open(p + ".bak-mojibake-20261013", "rb") as f:
        antes = f.read().decode("utf-8")
    # misma cantidad de lineas y de caracteres estructurables?
    la, ld = antes.count("\n"), t.count("\n")
    print("   lineas antes/despues:", la, "/", ld, "OK" if la == ld else "DRIFT!")
    ls = t.split("\n")
    for n in lineas:
        if n <= len(ls):
            print("   L{0}: {1}".format(n, ascii(ls[n-1].strip()[:95])))
