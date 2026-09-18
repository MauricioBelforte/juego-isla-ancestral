#!/usr/bin/env python3
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
# Este archivo es parte de "Isla Ancestral". Ver LICENSE en la raiz.
# -*- coding: utf-8 -*-
"""M127 iter. 3 -- Test de tools/legal/insert_copyright_headers.py.

Cubre lo que un test "de humo" no cubriria:
  * PRESERVACION DE BYTES: LF, CRLF y archivo sin newline final.
  * IDEMPOTENCIA real (procesar dos veces = bytes identicos).
  * Que la actualizacion de ano NO trunque lineas vecinas legitimas
    (p. ej. `# -*- coding: utf-8 -*-`): ese fue un bug real de la primera version.
  * EOL mixto -> el archivo se deja INTACTO (normalizarlo lo reescribiria entero).
  * Guardian anti-falso-verde: piso de checks (CHECKS_MINIMOS).
"""

import importlib.util
import json
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.normpath(os.path.join(HERE, "..", ".."))
SCRIPT = os.path.join(HERE, "insert_copyright_headers.py")
HDR = [
    "# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.",
    "# SPDX-License-Identifier: LicenseRef-Propietaria",
    "# Este archivo es parte de \"Isla Ancestral\". Ver LICENSE en la raiz.",
]

CHECKS_MINIMOS = 20


def cargar_modulo():
    spec = importlib.util.spec_from_file_location("ich_m127", SCRIPT)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def correr(*args, cwd=None):
    return subprocess.run([sys.executable, SCRIPT] + list(args),
                          capture_output=True, text=True, timeout=60,
                          cwd=cwd or RAIZ)


def main():
    tests = []
    mod = cargar_modulo()
    mod.procesar.titular_year = ("Isla Ancestral Team", 2026)

    # ---------- CLI ----------
    r = correr("--list")
    tests.append((r.returncode == 0, f"--list exit {r.returncode} (esperado 0)"))
    n_listados = len([l for l in r.stdout.splitlines() if "/" in l])
    tests.append((n_listados >= 10, f"--list lista >=10 archivos (vio {n_listados})"))

    r = correr("--check")
    tests.append((r.returncode == 0, f"--check en el repo real exit {r.returncode} (esperado 0: ya aplicado)"))

    r = correr("--check", "--json")
    try:
        data = json.loads(r.stdout)
        tests.append((data.get("faltantes") == [], f"--json reporta faltantes vacio: {data.get('faltantes')}"))
        tests.append((data.get("con_bom") == [], f"--json reporta 0 archivos con BOM: {data.get('con_bom')}"))
        tests.append((data.get("eol_mixto") == [], f"--json reporta 0 EOL mixto: {data.get('eol_mixto')}"))
        tests.append((data.get("en_alcance", 0) >= 10, f"--json informa el alcance: {data.get('en_alcance')}"))
    except json.JSONDecodeError as e:
        tests.append((False, f"--json produce JSON valido: {e}"))

    # ---------- preservacion de bytes ----------
    lf = "extends Node\nvar x := 1\n"
    nuevo, accion = mod.procesar(lf, ".gd")
    tests.append((accion == "insertada", f"LF: accion insertada (vio {accion})"))
    tests.append(("\r" not in nuevo, "LF: no se introdujo CR (archivo LF sigue LF)"))
    tests.append((nuevo.endswith("var x := 1\n"), "LF: el contenido original queda al final"))

    crlf = "extends Node\r\nvar x := 1\r\n"
    nuevo_crlf, accion = mod.procesar(crlf, ".gd")
    tests.append((accion == "insertada", f"CRLF: accion insertada (vio {accion})"))
    tests.append((nuevo_crlf.count("\n") - nuevo_crlf.count("\r\n") == 0,
                  "CRLF: 0 LF sueltos tras insertar (no se normalizo a LF)"))
    tests.append((nuevo_crlf.endswith("var x := 1\r\n"), "CRLF: el contenido original queda al final"))

    sin_nl, accion = mod.procesar("extends Node", ".gd")
    tests.append((accion == "insertada" and sin_nl.endswith("extends Node"),
                  "sin newline final: no revienta y conserva la ultima linea"))

    bom_antes = nuevo.encode("utf-8")
    tests.append((not bom_antes.startswith(b"\xef\xbb\xbf"), "no se agrega BOM"))

    # ---------- idempotencia ----------
    dos, accion2 = mod.procesar(nuevo, ".gd")
    tests.append((accion2 == "ok", f"idempotencia: 2a pasada es 'ok' (vio {accion2})"))
    tests.append((dos == nuevo, "idempotencia: bytes identicos en la 2a pasada"))

    # ---------- orden respecto de @tool / shebang ----------
    tool = "@tool\nextends Node\n"
    nuevo_tool, _ = mod.procesar(tool, ".gd")
    tests.append((nuevo_tool.startswith("@tool\n"), "@tool queda PRIMERO (la cabecera va despues)"))
    tests.append((nuevo_tool.index("Copyright (c)") > nuevo_tool.index("@tool"), "cabecera despues de @tool"))

    sh = "#!/usr/bin/env python3\nimport os\n"
    nuevo_sh, _ = mod.procesar(sh, ".py")
    tests.append((nuevo_sh.startswith("#!/usr/bin/env python3\n"), "shebang queda PRIMERO en .py"))

    # ---------- actualizacion de ano sin truncar vecinos ----------
    con_coding = ("#!/usr/bin/env python3\n"
                  "# Copyright (c) 2019 Otro Titular. Todos los derechos reservados.\n"
                  "# SPDX-License-Identifier: LicenseRef-Propietaria\n"
                  "# Este archivo es parte de \"Isla Ancestral\". Ver LICENSE en la raiz.\n"
                  "# -*- coding: utf-8 -*-\n"
                  "import os\n")
    act, accion3 = mod.procesar(con_coding, ".py")
    tests.append((accion3 == "actualizada", f"ano viejo -> accion 'actualizada' (vio {accion3})"))
    tests.append(("# -*- coding: utf-8 -*-" in act, "la linea de coding SOBREVIVE a la actualizacion"))
    tests.append((act.count("SPDX-License-Identifier") == 1, "no se duplica la cabecera al actualizar"))
    tests.append(("Copyright (c) 2026" in act, "el ano se actualizo a 2026"))

    # ---------- casos que NO se tocan ----------
    mixto = "extends Node\nvar a\r\nvar b\n"
    sin_cambio, accion4 = mod.procesar(mixto, ".gd")
    tests.append((accion4 == "mixto", f"EOL mixto -> accion 'mixto' (vio {accion4})"))
    tests.append((sin_cambio == mixto, "EOL mixto: el texto queda INTACTO"))

    md, accion5 = mod.procesar("# titulo\n", ".md")
    tests.append((accion5 == "ok" and md == "# titulo\n", "extension no soportada: sin cambios"))

    # ---------- alcance ----------
    tests.append((mod.es_excluido("src/vendor/a.gd", ["vendor"]) is True, "es_excluido detecta el patron"))
    tests.append((mod.es_excluido("src/a.gd", ["vendor"]) is False, "es_excluido no sobre-excluye"))

    with tempfile.TemporaryDirectory() as tmp:
        os.makedirs(os.path.join(tmp, "src", "vendor"))
        for rel in ("src/a.gd", "src/b.md", "src/vendor/c.gd"):
            with open(os.path.join(tmp, rel.replace("/", os.sep)), "w", encoding="utf-8") as f:
                f.write("x\n")
        viejo_raiz = mod.RAIZ
        mod.RAIZ = tmp
        try:
            got = mod.archivos_en_alcance([".gd"], ["src"], ["vendor"])
        finally:
            mod.RAIZ = viejo_raiz
        tests.append((got == ["src/a.gd"], f"archivos_en_alcance filtra extension y exclusion: {got}"))

    # ---------- dogfooding ----------
    with open(SCRIPT, "rb") as f:
        propio = f.read()
    tests.append(("SPDX-License-Identifier" in propio.decode("utf-8"),
                  "el propio tool lleva la cabecera (dogfooding)"))
    tests.append((not propio.startswith(b"\xef\xbb\xbf"), "el propio tool es UTF-8 sin BOM"))

    # ---------- resumen + guardian ----------
    fallos = 0
    for ok, msg in tests:
        print(f"  [{'OK' if ok else 'FAIL'}] {msg}")
        if not ok:
            fallos += 1
    print(f"=== Resumen M127 insert_copyright_headers: {len(tests) - fallos}/{len(tests)} OK ===")
    if len(tests) < CHECKS_MINIMOS:
        print(f"  [FAIL] guardian: solo {len(tests)} checks ejecutados (minimo {CHECKS_MINIMOS})"
              " -- un aborto silencioso NO puede pasar por verde")
        return 1
    return 1 if fallos > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
