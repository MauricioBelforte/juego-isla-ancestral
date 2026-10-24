#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Suite de `scripts/auditar_indice_m01.py`.

Prueba el auditor EN LAS DOS DIRECCIONES sobre un arbol sintetico en un
directorio temporal (no toca el repo):

  - verde: un item cerrado con GLOBAL OK NO se reporta como candidato si ya
    esta marcado [x], y un item abierto no se reporta como candidato;
  - rojo: un item cerrado con GLOBAL OK y sin marcar SI se reporta, y `--check`
    sale 1;
  - ceguera: sin GLOBAL, sin carpetas o con un indice incompleto, sale 3.

Uso:  python scripts/test_auditar_indice_m01.py
Salida: N checks / M fallos, exit 0 si 0 fallos y N >= CHECKS_MINIMOS.
"""

import os
import shutil
import subprocess
import sys
import tempfile

AQUI = os.path.dirname(os.path.abspath(__file__))
AUDITOR = os.path.join(AQUI, "auditar_indice_m01.py")
PY = sys.executable

CHECKS_MINIMOS = 62  # medido en verde (62/0 x3) el 2026-10-24; se ajusta SOLO tras medir

_checks = 0
_fallos = 0


def chequear(cond, desc):
    global _checks, _fallos
    _checks += 1
    if cond:
        print("[OK]    %s" % desc)
    else:
        _fallos += 1
        print("[FALLO] %s" % desc)


def construir(base, marcas, estado_global, carpetas=True, con_global=True, n_items=152, estados=None):
    """Arma un arbol sintetico. `marcas` = lista de marcas del indice (len n_items).

    `estados` (opcional): dict {numero_de_fila: estado} para fijar filas concretas
    del GLOBAL. Las no listadas caen al comportamiento por defecto.
    """
    os.makedirs(os.path.join(base, "scripts"))
    shutil.copy2(AUDITOR, os.path.join(base, "scripts", "auditar_indice_m01.py"))
    doc = os.path.join(base, "DOCUMENTACION")
    plan = os.path.join(doc, "01-Fundamentos-Del-Proyecto", "plan-actual")
    os.makedirs(plan)

    lineas = ["# indice sintetico", ""]
    for i in range(n_items):
        num = i + 1
        lineas.append("- [%s] **M%02d** Modulo %02d [M] - descripcion" % (marcas[i], num, num))
    with open(os.path.join(plan, "05-Checklist.md"), "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(lineas) + "\n")

    if carpetas:
        for i in range(n_items):
            num = i + 2  # carpeta = item + 1
            nombre = "%02d-Modulo-%02d" % (num, num) if num < 100 else "%03d-Modulo-%03d" % (num, num)
            pa = os.path.join(doc, nombre, "plan-actual")
            os.makedirs(pa)
            with open(os.path.join(pa, "05-Checklist.md"), "w", encoding="utf-8", newline="\n") as f:
                f.write("- [x] item cerrado\n")

    if con_global:
        filas = ["# GLOBAL sintetico", "", "| ID | Modulo | Estado | Progreso | P | C | D | R | A | F | N |",
                 "|---|---|---|---|---|---|---|---|---|---|---|"]
        for i in range(n_items):
            num = i + 2
            estado = (estados or {}).get(num)
            if estado is None:
                estado = estado_global if i == 0 else "\U0001F7E1 Con dudas"
            filas.append("| %d | mod-%d | %s | 1/1 | M | 1 | - | - | - | - | nota |" % (num, num, estado))
        with open(os.path.join(base, "CHECKLIST-GLOBAL.md"), "w", encoding="utf-8", newline="\n") as f:
            f.write("\n".join(filas) + "\n")


def correr(base, *args):
    r = subprocess.run([PY, os.path.join(base, "scripts", "auditar_indice_m01.py")] + list(args),
                       capture_output=True, text=True, encoding="utf-8", cwd=base)
    return r.returncode, r.stdout


def main():
    global _checks, _fallos
    base = tempfile.mkdtemp(prefix="m01_audit_")
    try:
        OK = "\u2705 Completado"
        AMARILLO = "\U0001F7E1 Con dudas"

        # --- Bloque A: verde, item ya marcado [x] y GLOBAL OK -> 0 candidatos
        marcas = ["x"] + [" "] * 151
        a = os.path.join(base, "A")
        construir(a, marcas, OK)
        rc, out = correr(a)
        chequear(rc == 0, "A: exit 0 con 152 items y GLOBAL legible")
        chequear("CANDIDATOS NUEVOS (0)" in out, "A: 0 candidatos (el [x] ya estaba)")
        chequear("YA FLIPEADOS VALIDOS (1)" in out, "A: 1 flipeado valido")
        rc, _ = correr(a, "--check")
        chequear(rc == 0, "A: --check exit 0 sin candidatos")

        # --- Bloque B: rojo, item cerrado + GLOBAL OK pero SIN marcar -> candidato
        marcas = [" "] * 152
        b = os.path.join(base, "B")
        construir(b, marcas, OK)
        rc, out = correr(b)
        chequear("CANDIDATOS NUEVOS (1)" in out, "B: detecta el candidato (M01 -> carpeta 02)")
        chequear("M01" in out, "B: nombra M01")
        rc, _ = correr(b, "--check")
        chequear(rc == 1, "B: --check exit 1 con candidatos")

        # --- Bloque C: control negativo, cerrado pero GLOBAL amarillo -> no candidato
        c = os.path.join(base, "C")
        construir(c, [" "] * 152, AMARILLO)
        rc, out = correr(c)
        chequear("CANDIDATOS NUEVOS (0)" in out, "C: GLOBAL amarillo NO produce candidato")
        rc, _ = correr(c, "--check")
        chequear(rc == 0, "C: --check exit 0 (control negativo)")

        # --- Bloque D: control negativo, GLOBAL OK pero el item tiene un [?]
        d = os.path.join(base, "D")
        construir(d, [" "] * 152, OK)
        pa = os.path.join(d, "DOCUMENTACION", "02-Modulo-02", "plan-actual", "05-Checklist.md")
        with open(pa, "w", encoding="utf-8", newline="\n") as f:
            f.write("- [x] cerrado\n- [?] con dudas\n")
        rc, out = correr(d)
        chequear("CANDIDATOS NUEVOS (0)" in out, "D: un [?] abierto NO produce candidato")

        # --- Bloque E: ceguera
        e = os.path.join(base, "E")
        construir(e, [" "] * 152, OK, con_global=False)
        rc, out = correr(e)
        chequear(rc == 3, "E: sin CHECKLIST-GLOBAL -> exit 3 (detector ciego)")

        f = os.path.join(base, "F")
        construir(f, [" "] * 152, OK, carpetas=False)
        rc, out = correr(f)
        chequear(rc == 3, "F: sin carpetas de modulo -> exit 3")

        g = os.path.join(base, "G")
        construir(g, [" "] * 152, OK, n_items=10)
        rc, out = correr(g)
        chequear(rc == 3, "G: indice incompleto (10 items) -> exit 3")

        # --- Bloque H: el mapeo +1 se respeta (M01 apunta a la carpeta 02)
        rc, out = correr(b, "--json")
        import json
        datos = json.loads(out)
        chequear(datos["registros"][0]["carpeta_esperada"] == 2, "H: M01 -> carpeta 02 (desplazamiento +1)")
        chequear(datos["registros"][0]["carpeta"] == "02-Modulo-02", "H: resuelve la carpeta 02")

        # --- Bloque I: clasificacion de los [ ] por la condicion que los bloquea
        ib = os.path.join(base, "I")
        # filas 2..5: M01 OK, M02 amarillo, M03 OK, M04 amarillo; el resto amarillo
        construir(ib, [" "] * 152, OK, estados={2: OK, 3: AMARILLO, 4: OK, 5: AMARILLO})
        # M03 -> carpeta 04: GLOBAL dice OK pero la checklist tiene un [?]
        with open(os.path.join(ib, "DOCUMENTACION", "04-Modulo-04", "plan-actual", "05-Checklist.md"),
                  "w", encoding="utf-8", newline="\n") as f:
            f.write("- [x] cerrado\n- [?] con dudas\n")
        # M04 -> carpeta 05: GLOBAL amarillo y la checklist tiene un [ ]
        with open(os.path.join(ib, "DOCUMENTACION", "05-Modulo-05", "plan-actual", "05-Checklist.md"),
                  "w", encoding="utf-8", newline="\n") as f:
            f.write("- [x] cerrado\n- [ ] pendiente\n")

        rc, out = correr(ib, "--pendientes")
        chequear(rc == 0, "I: --pendientes exit 0")
        chequear("items [ ] en el indice : 152" in out, "I: cuenta los 152 pendientes")
        chequear("[1] resoluble_headless" in out, "I: 1 resoluble headless (M01)")
        chequear("[149] bloqueado_global" in out, "I: 149 bloqueados por la FILA GLOBAL")
        chequear("[1] bloqueado_checklist" in out, "I: 1 con el GLOBAL sobre-afirmado (M03)")
        chequear("[1] bloqueado_ambos" in out, "I: 1 dependiente del modulo (M04)")
        chequear("CASI CERRADAS (abiertos <= 5): 2" in out, "I: 2 casi cerradas (M03 y M04)")
        chequear("[0] sin_checklist" in out, "I: 0 sin checklist")

        rc, out = correr(ib, "--json")
        datos_i = json.loads(out)
        cats = [r["categoria_pendiente"] for r in datos_i["registros"][:4]]
        chequear(cats == ["resoluble_headless", "bloqueado_global",
                          "bloqueado_checklist", "bloqueado_ambos"],
                 "I: una categoria por item, en orden")
        chequear(datos_i["pendientes"]["por_categoria"]["bloqueado_ambos"] == 1,
                 "I: el JSON agrega bien bloqueado_ambos")

        # un [x] nunca entra en la clasificacion de pendientes (bloque A: M01 esta [x])
        rc, out = correr(a, "--json")
        chequear(json.loads(out)["registros"][0]["categoria_pendiente"] is None,
                 "I: un item [x] no se clasifica como pendiente")

        # --- Bloque J: prueba EN ROJO del clasificador, por inyeccion y con restauracion
        import hashlib
        copia = os.path.join(ib, "scripts", "auditar_indice_m01.py")
        orig = open(copia, "rb").read()
        sha_antes = hashlib.sha256(orig).hexdigest()
        roto = orig.replace(b'    if r["candidato"]:\n        return "resoluble_headless"\n',
                            b'    if False:\n        return "resoluble_headless"\n')
        chequear(roto != orig, "J: la inyeccion encontro su ancla (el archivo cambio)")
        with open(copia, "wb") as f:
            f.write(roto)
        rc, out = correr(ib, "--pendientes")
        chequear("[0] resoluble_headless" in out,
                 "J: con el clasificador ciego el resoluble DESAPARECE (sonda ROJA)")
        with open(copia, "wb") as f:
            f.write(orig)
        chequear(hashlib.sha256(open(copia, "rb").read()).hexdigest() == sha_antes,
                 "J: restauracion byte-exacta por sha256")
        rc, out = correr(ib, "--pendientes")
        chequear("[1] resoluble_headless" in out, "J: tras restaurar vuelve el verde")

        # --- Bloque K: clasificacion por TIPO de dependencia (7 familias, 1 item cada una)
        # M01 -> carpeta 02 queda bloqueado_ambos (checklist abierta + GLOBAL amarillo);
        # el resto de los modulos tiene la checklist cerrada -> bloqueado_global.
        k = os.path.join(base, "K")
        construir(k, [" "] * 152, AMARILLO)
        CHECK_K = os.path.join(k, "DOCUMENTACION", "02-Modulo-02", "plan-actual", "05-Checklist.md")
        ITEMS_K = [
            "- [ ] Definir credenciales OAuth para el backup\n",          # cuenta_externa_fundador
            "- [ ] Validar 60 FPS en Steam Deck\n",                       # hardware
            "- [ ] Audio de recogida (campana suave)\n",                  # asset
            "- [ ] Anotar el alcance como pendiente de negocio\n",         # decision_proyecto
            "- [ ] Recetas consumibles por M10\n",                        # otro_modulo
            "- [ ] Highlight del objetivo NO implementado\n",             # trabajo_propio
            "- [ ] Saltar, nadar y escalar del jugador\n",                # sin dependencia declarada
        ]
        with open(CHECK_K, "w", encoding="utf-8", newline="\n") as f:
            f.write("".join(ITEMS_K))

        rc, out = correr(k, "--dependencias")
        chequear(rc == 0, "K: --dependencias exit 0")
        chequear("modulos bloqueado_ambos : 1" in out, "K: clasifica 1 modulo bloqueado_ambos")
        chequear("items abiertos leidos   : 7" in out, "K: lee los 7 items abiertos")
        for tipo in ("cuenta_externa_fundador", "hardware", "asset",
                     "decision_proyecto", "otro_modulo", "trabajo_propio", "sin_dependencia_declarada"):
            chequear("  %-24s %5d  %5.1f%%" % (tipo, 1, 100.0 / 7) in out,
                     "K: 1 item en %s" % tipo)

        rc, out = correr(k, "--dependencias", "--json")
        datos_k = json.loads(out)
        dep_k = datos_k["dependencias"]
        tipos_k = [it["tipo"] for it in dep_k["detalle"][0]["items"]]
        chequear(tipos_k == ["cuenta_externa_fundador", "hardware", "asset",
                             "decision_proyecto", "otro_modulo", "trabajo_propio", "sin_dependencia_declarada"],
                 "K: un tipo por item, en el orden de las familias")
        chequear(sum(dep_k["por_tipo"].values()) == dep_k["items"],
                 "K: la suma por tipo cuadra con el total de items")
        chequear(dep_k["detalle"][0]["externos"] == 4,
                 "K: 4 items externos en el modulo (cuenta+hardware+asset+decision)")

        # --- Bloque L: controles negativos del clasificador
        l = os.path.join(base, "L")
        construir(l, [" "] * 152, AMARILLO)
        CHECK_L = os.path.join(l, "DOCUMENTACION", "02-Modulo-02", "plan-actual", "05-Checklist.md")
        with open(CHECK_L, "w", encoding="utf-8", newline="\n") as f:
            f.write(
                "- [ ] Sin contradicciones con M01 (recetas)\n"          # auto-referencia -> NO otro_modulo
                "- [ ] Cuevas con 3 entradas por isla [M]\n"             # [M] = esfuerzo, no modulo
                "- [ ] Audio de recogida | QA: NO implementado\n"        # precedencia: asset gana a propio
                "- [?] -- pendiente de M10\n"                            # enunciado vacio -> usa el texto
            )
        rc, out = correr(l, "--dependencias", "--json")
        dep_l = json.loads(out)["dependencias"]
        tipos_l = [it["tipo"] for it in dep_l["detalle"][0]["items"]]
        chequear(tipos_l[0] == "sin_dependencia_declarada",
                 "L: la auto-referencia a M01 NO cuenta como otro_modulo")
        chequear(tipos_l[1] == "sin_dependencia_declarada",
                 "L: el tag de esfuerzo [M] NO se confunde con un modulo")
        chequear(tipos_l[2] == "asset",
                 "L: la precedencia pone asset antes que trabajo_propio")
        chequear(tipos_l[3] == "otro_modulo",
                 "L: un item que EMPIEZA por separador se clasifica con su texto completo")

        # --- Bloque M: ceguera del clasificador de dependencias
        m = os.path.join(base, "M")
        construir(m, [" "] * 152, AMARILLO)   # todas las checklists cerradas -> 0 bloqueado_ambos
        rc, out = correr(m, "--dependencias")
        chequear(rc == 3, "M: sin ningun item abierto -> exit 3 (detector ciego)")
        chequear("no se leyo ningun item abierto" in out,
                 "M: el informe nombra la causa de la ceguera")

        # el invariante aritmetico tambien vale con varios modulos bloqueados
        n = os.path.join(base, "N")
        construir(n, [" "] * 152, AMARILLO)
        for num, texto in ((2, "- [ ] Audio de menu\n- [ ] Probar salto\n"),
                           (3, "- [ ] Icono de fatiga\n")):
            pa = os.path.join(n, "DOCUMENTACION", "%02d-Modulo-%02d" % (num, num),
                              "plan-actual", "05-Checklist.md")
            with open(pa, "w", encoding="utf-8", newline="\n") as f:
                f.write(texto)
        rc, out = correr(n, "--dependencias", "--json")
        dep_n = json.loads(out)["dependencias"]
        chequear(dep_n["modulos"] == 2, "N: clasifica los 2 modulos bloqueado_ambos")
        chequear(dep_n["items"] == 3, "N: suma los 3 items abiertos de los 2 modulos")
        cuadra = all(sum(x["por_tipo"].values()) == x["abiertos"] for x in dep_n["detalle"])
        chequear(cuadra, "N: por modulo, la suma por tipo cuadra con sus abiertos")
        chequear(dep_n["por_tipo"]["asset"] == 2,
                 "N: agrega bien asset entre modulos (audio + icono)")
        chequear(dep_n["modulos"] == dep_n["modulos_esperados"],
                 "N: modulos clasificados == modulos bloqueado_ambos (guarda de ceguera)")

        # --- Bloque O: PRECISION de la familia `hardware` (iter. 10)
        # El patron viejo cazaba "fps"/"rendimiento" por si solos: 16 de 56 items
        # (28,6%) eran IMPLEMENTACION ("FPS overlay") o TARGETS de diseno ("Definir
        # objetivo 30 fps"). Ahora `hardware` exige token DURO de dispositivo, o
        # token BLANDO de performance + verbo de MEDICION en el mismo enunciado.
        # Estos 6 casos son la prueba EN ROJO de la regla: sin ella, los 3 primeros
        # pasarian a `hardware`.
        o = os.path.join(base, "O")
        construir(o, [" "] * 152, AMARILLO)
        CHECK_O = os.path.join(o, "DOCUMENTACION", "02-Modulo-02", "plan-actual", "05-Checklist.md")
        with open(CHECK_O, "w", encoding="utf-8", newline="\n") as f:
            f.write(
                "- [ ] FPS overlay cada 0.5s\n"                              # 0: implementacion, NO hardware
                "- [ ] Definir objetivo 30 fps minimo / 60 deseado\n"        # 1: target de diseno, NO hardware
                "- [ ] Implementar metricas de rendimiento (tiempo de tick)\n"  # 2: implementacion, NO hardware
                "- [ ] Validar pueblo completo 60 FPS\n"                     # 3: mide en dispositivo -> hardware
                "- [ ] Pruebas de legibilidad en diferentes dispositivos\n"   # 4: plural de token duro
                "- [ ] Validar VRAM menor al presupuesto\n"                  # 5: token duro sin verbo
            )
        rc, out = correr(o, "--dependencias", "--json")
        dep_o = json.loads(out)["dependencias"]
        tipos_o = [it["tipo"] for it in dep_o["detalle"][0]["items"]]
        for idx in (0, 1, 2):
            chequear(tipos_o[idx] == "sin_dependencia_declarada",
                     "O: el item %d NO es hardware (menciona fps/rendimiento sin pedir medir)" % idx)
        for idx in (3, 4, 5):
            chequear(tipos_o[idx] == "hardware",
                     "O: el item %d SI es hardware (mide en dispositivo)" % idx)
        chequear(dep_o["por_tipo"]["hardware"] == 3,
                 "O: exactamente 3 de 6 items son hardware (no 6)")
        chequear(dep_o["detalle"][0]["externos"] == 3,
                 "O: el modulo tiene 3 items externos, no 6")

    finally:
        shutil.rmtree(base, ignore_errors=True)

    print("")
    if _checks < CHECKS_MINIMOS:
        _fallos += 1
        print("[FALLO] solo %d checks ejecutados (minimo %d)" % (_checks, CHECKS_MINIMOS))
    print("=== Resumen: %d checks, %d fallos ===" % (_checks, _fallos))
    return 1 if _fallos else 0


if __name__ == "__main__":
    sys.exit(main())
