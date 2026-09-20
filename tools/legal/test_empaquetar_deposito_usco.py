#!/usr/bin/env python3
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
# Este archivo es parte de "Isla Ancestral". Ver LICENSE en la raiz.
# -*- coding: utf-8 -*-
"""M127 iter. 4 -- Test de tools/legal/empaquetar_deposito_usco.py.

La suite prueba el gate EN ROJO, no solo en verde:
  * una violacion NUEVA (secreto comercial con tachado >= visible) -> exit 1;
  * un alcance que no resuelve fuentes -> exit 3 (detector CIEGO);
  * una deuda declarada que ya no ocurre -> se reporta como obsoleta.

El mini-proyecto sintetico se arma en un temporal y se le apunta el modulo
(`mod.RAIZ` / `mod.ALCANCE`), igual que hace test_scan_orphan_code.py: mockear
las rutas no probaria nada, porque la deteccion depende de leer archivos reales.
"""

import importlib.util
import io
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.normpath(os.path.join(HERE, "..", ".."))
SCRIPT = os.path.join(HERE, "empaquetar_deposito_usco.py")

CHECKS_MINIMOS = 38   # MEDIDO en verde (38/38), no estimado


def cargar_modulo():
    spec = importlib.util.spec_from_file_location("deposito_usco", SCRIPT)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def correr(*args):
    return subprocess.run([sys.executable, SCRIPT] + list(args),
                          capture_output=True, text=True, timeout=180, cwd=RAIZ,
                          encoding="utf-8", errors="replace")


def escribir(p, texto):
    with io.open(p, "w", encoding="utf-8", newline="\n") as f:
        f.write(texto)


def main():
    t = []

    def chk(ok, msg):
        t.append((bool(ok), msg))

    mod = cargar_modulo()

    # ---------- 1. El selftest del propio auditor (probado en verde) ----------
    r = correr("--selftest")
    chk(r.returncode == 0, "--selftest sale 0 (vio %d)" % r.returncode)
    chk("FAIL" not in r.stdout, "el selftest no tiene ningun FAIL")
    # NO se fija el conteo en la asercion: se LEE del resumen. Escribir "42/42"
    # de memoria dejo esta suite en rojo cuando el selftest paso a 45/45.
    m = re.search(r"selftest: (\d+)/(\d+) OK", r.stdout)
    chk(m is not None, "el selftest publica su resumen (n/m OK)")
    if m:
        ok_n, tot_n = int(m.group(1)), int(m.group(2))
        chk(ok_n == tot_n, "el selftest pasa todos sus checks (%d/%d)" % (ok_n, tot_n))
        chk(tot_n >= mod.CHECKS_MINIMOS,
            "el selftest supera el piso medido (%d >= %d)" % (tot_n, mod.CHECKS_MINIMOS))
    else:
        chk(False, "sin resumen parseable del selftest")

    # ---------- 2. CLI sobre el repo real ----------
    r = correr("--json")
    chk(r.returncode in (0, 1, 3), "--json corre (vio %d)" % r.returncode)
    try:
        data = json.loads(r.stdout)
        chk(set(["plan", "fuentes", "visuales", "violaciones", "ciego"]).issubset(data.keys()),
            "--json trae las claves del informe")
        chk(len(data["fuentes"]) > 0, "el alcance real resuelve fuentes (%d)" % len(data["fuentes"]))
        chk(data["plan"]["modo"] == "primeras+ultimas",
            "el repo supera 50 paginas -> regla de recorte (%d paginas)" % data["paginas"])
    except json.JSONDecodeError as e:
        chk(False, "--json produce JSON valido: %s" % e)

    r = correr("--plan")
    chk(r.returncode == 0, "--plan sale 0")
    chk("37 CFR 202.20(c)(2)(vii)" in r.stdout, "--plan cita la norma")
    chk("50 lineas/pagina" in r.stdout, "--plan declara la unidad usada (no la supone)")

    # ---------- 3. Gate verde CON deuda declarada ----------
    r = correr("--check")
    chk(r.returncode == 0, "--check sale 0 sobre el repo real (vio %d)" % r.returncode)
    chk("DEUDA DECLARADA" in r.stdout, "--check reporta la deuda declarada (no la esconde)")
    chk("0 violaciones nuevas" in r.stdout, "--check informa 0 violaciones nuevas")

    # ---------- 4. Mini-proyecto sintetico: reglas 4.1 y frontera ----------
    tmp = tempfile.mkdtemp(prefix="dep_usco_")
    try:
        os.makedirs(os.path.join(tmp, "src"))
        os.makedirs(os.path.join(tmp, "src", "vendor"))
        # 3000 lineas -> 60 paginas -> recorte 1..25 + 36..60
        escribir(os.path.join(tmp, "src", "grande.gd"),
                 "# Copyright (c) 2026 Isla Ancestral Team\n" + "var x = 0\n" * 2999)
        # 40 lineas -> 1 pagina
        escribir(os.path.join(tmp, "src", "chico.gd"), "var y = 1\n" * 40)
        # excluido: no debe entrar
        escribir(os.path.join(tmp, "src", "vendor", "ajeno.gd"), "var z = 2\n" * 5000)
        # extension fuera del alcance
        escribir(os.path.join(tmp, "src", "notas.md"), "# notas\n")
        # PNG sintetico de 768x768 (2.56 in @300dpi -> por debajo del minimo)
        png = mod._png(768, 768)
        with open(os.path.join(tmp, "src", "muestra.png"), "wb") as f:
            f.write(png)

        scope = {"version": 1, "paginas_por_unidad": 50,
                 "codigo": {"extensiones": [".gd"], "incluir": ["src"], "excluir": ["vendor"]},
                 "secretos": {"activo": False, "opcion": "a", "tachado_lineas": 0,
                              "visible_lineas": 0},
                 "visuales": [{"ruta": "src/muestra.png", "dpi": 300}], "deuda": []}
        ruta_scope = os.path.join(tmp, "scope.json")
        escribir(ruta_scope, json.dumps(scope, ensure_ascii=False))

        viejo_raiz, viejo_alcance = mod.RAIZ, mod.ALCANCE
        mod.RAIZ, mod.ALCANCE = tmp, ruta_scope
        try:
            res = mod.analizar(mod.cargar_alcance())

            chk([f for f in res["fuentes"]] == ["src/chico.gd", "src/grande.gd"],
                "alcance correcto (vendor y .md fuera): %s" % res["fuentes"])
            # 3044 = 3040 lineas de contenido (3000+40) + 2 separadores
            # "// ==== archivo ====" + 2 elementos vacios finales del split.
            # MEDIDO: la primera version de este test aserto 3040 "de memoria".
            chk(res["lineas"] == 3044, "lineas del flujo (con separadores): %d" % res["lineas"])
            chk(res["paginas"] == 61, "61 paginas (3000+40 lineas / 50): %d" % res["paginas"])
            chk(res["plan"]["modo"] == "primeras+ultimas", "61 > 50 -> regla de recorte")
            chk(res["plan"]["rangos"] == [(1, 25), (37, 61)],
                "rangos 1..25 y 37..61: %s" % res["plan"]["rangos"])
            chk(res["plan"]["unidades"] == 50, "50 unidades (25+25): %d" % res["plan"]["unidades"])
            chk(res["ciego"] == [], "el mini-proyecto NO es ciego")

            # La visual de 768x768 @300dpi viola el minimo -> violacion NUEVA.
            chk(len(res["violaciones"]) == 1 and res["violaciones"][0]["clave"] == "4.3|visual|src/muestra.png",
                "768x768 @300dpi -> 1 violacion 4.3 (2.56 in < 3 in): %s" % res["violaciones"])
            nuevas, vigentes, obs = mod.clasificar_violaciones(res["violaciones"], [])
            chk(len(nuevas) == 1 and vigentes == [] and obs == [],
                "sin deuda declarada la violacion es NUEVA (rompe el gate)")

            # Con la deuda declarada, la misma violacion NO es nueva.
            scope["deuda"] = [{"clave": res["violaciones"][0]["clave"],
                               "motivo": "captura chica (M166)", "dueno": "usuario"}]
            escribir(ruta_scope, json.dumps(scope, ensure_ascii=False))
            res2 = mod.analizar(mod.cargar_alcance())
            nuevas, vigentes, obs = mod.clasificar_violaciones(res2["violaciones"], res2.get("deuda", []))
            chk(nuevas == [] and len(vigentes) == 1, "con la deuda declarada -> 0 nuevas, 1 vigente")

            # Deuda declarada que ya no ocurre -> obsoleta.
            scope["deuda"] = [{"clave": "4.3|visual|src/otra.png", "motivo": "x", "dueno": "y"}]
            escribir(ruta_scope, json.dumps(scope, ensure_ascii=False))
            res3 = mod.analizar(mod.cargar_alcance())
            nuevas, vigentes, obs = mod.clasificar_violaciones(res3["violaciones"], res3.get("deuda", []))
            chk(obs == ["4.3|visual|src/otra.png"], "deuda que ya no ocurre -> obsoleta: %s" % obs)

            # Guarda de ceguera EN ROJO: alcance sin fuentes.
            scope["codigo"]["incluir"] = ["no/existe"]
            scope["deuda"] = []
            escribir(ruta_scope, json.dumps(scope, ensure_ascii=False))
            res4 = mod.analizar(mod.cargar_alcance())
            chk(len(res4["ciego"]) >= 1, "alcance sin fuentes -> la ceguera se declara: %s" % res4["ciego"])

            # Emision del deposito (artefacto real).
            scope["codigo"]["incluir"] = ["src"]
            escribir(ruta_scope, json.dumps(scope, ensure_ascii=False))
            res5 = mod.analizar(mod.cargar_alcance())
            destino = os.path.join(tmp, "salida")
            ruta_dep, ruta_man = mod.emitir(res5, destino)
            chk(os.path.isfile(ruta_dep) and os.path.getsize(ruta_dep) > 0,
                "el deposito de codigo se escribe y no esta vacio")
            man = json.loads(io.open(ruta_man, encoding="utf-8").read())
            chk(man["norma"] == "37 CFR 202.20(c)(2)(vii)", "el manifiesto cita la norma")
            # OJO: JSON convierte las tuplas en listas; comparar contra tuplas falla.
            chk([list(r) for r in man["rangos"]] == [[1, 25], [37, 61]],
                "el manifiesto registra los rangos: %s" % man["rangos"])
            chk(man.get("paquete", {}).get("metadata_ok") is True,
                "el manifiesto mide el metadata del paquete (4.4): %s"
                % man.get("paquete", {}).get("motivo"))
            texto = io.open(ruta_dep, encoding="utf-8").read()
            chk("---- paginas 1..25 ----" in texto and "---- paginas 37..61 ----" in texto,
                "el deposito marca los recortes de pagina")
            with open(ruta_dep, "rb") as f:
                crudo = f.read()
            chk(not crudo.startswith(b"\xef\xbb\xbf"), "el deposito sale UTF-8 SIN BOM")
            chk(b"\r\n" not in crudo, "el deposito sale con LF (no CRLF)")
        finally:
            mod.RAIZ, mod.ALCANCE = viejo_raiz, viejo_alcance
    finally:
        shutil.rmtree(tmp, ignore_errors=True)

    # ---------- 5. Helpers puros ----------
    chk(mod.paginas_de(50 * 50) == 50, "paginas_de(2500)=50")
    chk(mod.paginas_de(50 * 50 + 1) == 51, "paginas_de(2501)=51 (frontera)")
    ok, _ = mod.verificar_tachado(10, 100)
    chk(ok, "tachado 10 < visible 100 -> admisible")
    ok, _ = mod.verificar_tachado(100, 10)
    chk(not ok, "tachado 100 > visible 10 -> inadmisible")

    fallos = 0
    for ok, msg in t:
        print("  [%s] %s" % ("OK" if ok else "FAIL", msg))
        if not ok:
            fallos += 1
    print("=== Resumen M127 empaquetar_deposito_usco: %d/%d OK ===" % (len(t) - fallos, len(t)))
    if len(t) < CHECKS_MINIMOS:
        print("  [FAIL] guardian: solo %d checks (minimo %d)" % (len(t), CHECKS_MINIMOS))
        return 1
    return 1 if fallos else 0


if __name__ == "__main__":
    sys.exit(main())
