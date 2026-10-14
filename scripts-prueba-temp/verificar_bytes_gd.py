# -*- coding: utf-8 -*-
import io

files = [
 "game/isla-ancestral/scripts/world/test_generacion_m10_atria.gd",
 "game/isla-ancestral/scripts/islas/test_islas_m27_iter2.gd",
 "game/isla-ancestral/scripts/houses/house_interior.gd",
]
for p in files:
    with io.open(p, "rb") as f:
        raw = f.read()
    # lineas 5-10
    lineas = raw.split(b"\n")[5:10]
    print("==", p, "==")
    print("  hex primeros 30 bytes:", raw[:30].hex(" "))
    try:
        t = raw.decode("utf-8")
        estado = "UTF-8 OK"
    except UnicodeDecodeError as e:
        t = raw.decode("cp1252", errors="replace")
        estado = "NO es UTF-8 valido (" + str(e)[:60] + ") -> leido como cp1252"
    print("  ", estado)
    for l in lineas[:4]:
        s = l.decode("utf-8", errors="replace")
        if s.strip():
            print("   |", s[:95])
