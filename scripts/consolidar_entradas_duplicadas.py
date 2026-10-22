#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Consolidacion de ENTRADAS DUPLICADAS de DOCUMENTACION/11-BUGS.md (M102).

Problema que resuelve (residuo del saneamiento 71 -> 24): el registro tiene, para
el MISMO bug, dos entradas de detalle con dos formatos historicos distintos
(`### BUG-xxx — ...` de las secciones 6/7 y `## BUG-xxx: ...` del bloque viejo de
la seccion 8). El medidor las declara `entrada_duplicada`.

Reglas de diseno (no negociables):

1. **No reimplementa el parser.** Importa `metricas_bugs` y usa
   `leer_registro()` como unica fuente de verdad de QUE esta duplicado.
2. **Lossless.** NO se borra ni una linea de contenido. Lo unico que cambia es el
   ENCABEZADO redundante, que se demota a una linea de blockquote
   (`> **Registro previo consolidado de BUG-xxx ...**`). El texto de la entrada
   queda intacto debajo, como evidencia historica.
3. **Solo consolida lo que es el MISMO bug.** Los ids que colisionan entre bugs
   DISTINTOS (mismo numero, sintoma distinto) NO se tocan: renumerar es decision
   del director. Se listan en `COLISIONES` solo para el informe.
4. **Se mide a si mismo.** Aplica el cambio EN MEMORIA, corre el medidor sobre un
   archivo temporal y ABORTA si (a) aparece una firma de defecto NUEVA, (b) la
   firma `entrada_duplicada:<id>` sigue viva, o (c) el multiset de lineas no
   cuadra exactamente con `-1 encabezado +1 puntero` por cada consolidacion.
5. **Idempotente.** Correrlo dos veces no cambia nada la segunda vez.
6. **EOL por bytes.** El archivo es LF puro, sin BOM: se verifica antes de
   escribir y se preserva. Nunca se normaliza EOL a ciegas.

Uso:
  python scripts/consolidar_entradas_duplicadas.py            # dry-run
  python scripts/consolidar_entradas_duplicadas.py --aplicar  # escribe
  python scripts/consolidar_entradas_duplicadas.py --check    # exit 1 si queda trabajo
  python scripts/consolidar_entradas_duplicadas.py --selftest # pruebas con fixtures
"""

import argparse
import collections
import io
import os
import re
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import metricas_bugs as mb  # noqa: E402

RUTA_POR_DEFECTO = mb.RUTA_POR_DEFECTO

# Ids con DOS entradas del MISMO bug (medido 2026-10-22: sintoma identico en
# ambas). El valor es el motivo, para que quede en el informe.
CONSOLIDAR = collections.OrderedDict([
    ("BUG-047", "M38 items solo-vendibles: '### ... — RESUELTO' + '## BUG-047:' viejo"),
    ("BUG-051", "CI job godot-lint no-op: '### ... — ...' + '## BUG-051 — ...' viejo"),
    ("BUG-061", "M94 suite 5 checks: entrada 'falla' + re-registro 'fallaba'"),
    ("BUG-062", "M84 suite no parsea: entrada 'no parsea' + re-registro 'no parseaba'"),
    ("BUG-089", "minimap_widget 2 _ready: entrada corregida + 'DELEGACION ANULADA'"),
    ("BUG-120", "run_tests.gd falso-verde: '### ... — ...' + '## BUG-120:' viejo"),
])

# Ids que el medidor tambien marca duplicados pero son bugs DISTINTOS con el
# mismo numero. NO se tocan (renumerar = decision del director). Solo informe.
COLISIONES = collections.OrderedDict([
    ("BUG-052", "Boot .get() de 2 args vs Deuda de copyright de .glb"),
    ("BUG-058", "validar_nombres.py falsos positivos vs Autoload M107 ZIPWriter"),
])

RE_ENCABEZADO = re.compile(r"^(#{2,3})\s+(BUG-\d+)\s*(.*)$")
PREFIJO_PUNTERO = "> **Registro previo consolidado de %s (M102, 2026-10-22):** %s"


def leer_texto(ruta):
    """Lee el registro validando el contrato de bytes (LF puro, sin BOM)."""
    with open(ruta, "rb") as fh:
        crudo = fh.read()
    if crudo[:3] == b"\xef\xbb\xbf":
        raise SystemExit("ABORT: el archivo tiene BOM; no es el contrato esperado.")
    if b"\r\n" in crudo:
        raise SystemExit("ABORT: el archivo tiene CRLF; no es el contrato esperado "
                         "(medir EOL antes de escribir).")
    return crudo.decode("utf-8")


def escribir_texto(ruta, texto):
    with open(ruta, "wb") as fh:
        fh.write(texto.encode("utf-8"))


def entradas_por_id(datos):
    por_id = collections.defaultdict(list)
    for e in datos["entradas"]:
        por_id[e["id"]].append(e)
    return por_id


def cuerpo_de(lineas, entrada):
    """Lineas de contenido (no vacias) desde el encabezado hasta el siguiente."""
    ini = entrada["linea"] - 1
    fin = len(lineas)
    for j in range(ini + 1, len(lineas)):
        if lineas[j].lstrip().startswith("#"):
            fin = j
            break
    return [l for l in lineas[ini + 1:fin] if l.strip()]


def elegir_par(lineas, entradas):
    """Devuelve (conservar, demotar). Criterio medido: mas contenido gana;
    empate -> la entrada de linea menor (la primera registrada)."""
    pesadas = sorted(entradas, key=lambda e: (-len(cuerpo_de(lineas, e)), e["linea"]))
    return pesadas[0], pesadas[1]


def linea_puntero(encabezado, bid):
    m = RE_ENCABEZADO.match(encabezado)
    titulo = (m.group(3) if m else "").strip()
    # `## BUG-047: Titulo` deja el separador pegado al grupo 3: sacarlo antes de
    # volver a componer (si no, queda ":** : M38 — ...").
    titulo = titulo.lstrip(":.\u2014\u2013- ").strip()
    titulo = re.sub(r"\s*[\u2014\u2013]\s*", " — ", titulo).strip(" —")
    return PREFIJO_PUNTERO % (bid, titulo)


def plan(lineas, datos):
    """Lista de acciones (bid, linea_demotada, encabezado, puntero)."""
    por_id = entradas_por_id(datos)
    acciones = []
    for bid in CONSOLIDAR:
        ents = por_id.get(bid, [])
        if len(ents) != 2:
            raise SystemExit("ABORT: %s tiene %d entrada(s), se esperaban 2 "
                             "(el registro cambio: re-medir antes de aplicar)."
                             % (bid, len(ents)))
        _keep, demote = elegir_par(lineas, ents)
        idx = demote["linea"] - 1
        enc = lineas[idx]
        if not RE_ENCABEZADO.match(enc):
            raise SystemExit("ABORT: la linea %d de %s no es un encabezado "
                             "parseable: %r" % (demote["linea"], bid, enc[:80]))
        acciones.append((bid, demote["linea"], enc, linea_puntero(enc, bid)))
    return acciones


def aplicar(lineas, acciones):
    nuevas = list(lineas)
    for _bid, ln, _enc, puntero in sorted(acciones, key=lambda a: -a[1]):
        nuevas[ln - 1] = puntero
    return nuevas


def firmas(datos):
    return collections.Counter(mb.firma_de(d) for d in datos["defectos"])


def medir_texto(texto, ruta_tmp):
    escribir_texto(ruta_tmp, texto)
    return mb.leer_registro(ruta_tmp, "")


def validar(antes_lineas, despues_lineas, datos_antes, datos_despues, acciones):
    """Invariantes. Devuelve lista de problemas (vacia = OK)."""
    fallos = []

    # (a) ninguna firma NUEVA
    fa, fd = firmas(datos_antes), firmas(datos_despues)
    nuevas = fd - fa
    if nuevas:
        fallos.append("firmas NUEVAS: %s" % dict(nuevas))

    # (b) las firmas consolidadas desaparecieron
    for bid, _ln, _enc, _p in acciones:
        f = "entrada_duplicada:%s" % bid
        if fd.get(f):
            fallos.append("%s sigue duplicada" % bid)

    # (c) multiset de lineas: -1 encabezado +1 puntero por accion
    ca, cd = collections.Counter(antes_lineas), collections.Counter(despues_lineas)
    quitadas, puestas = ca - cd, cd - ca
    if sum(quitadas.values()) != len(acciones) or sum(puestas.values()) != len(acciones):
        fallos.append("multiset de lineas no cuadra: -%d +%d (esperado -%d +%d)"
                      % (sum(quitadas.values()), sum(puestas.values()),
                         len(acciones), len(acciones)))
    for bid, _ln, enc, puntero in acciones:
        if quitadas.get(enc) != 1:
            fallos.append("el encabezado demotado de %s no es unica baja" % bid)
        if puestas.get(puntero) != 1:
            fallos.append("el puntero de %s no es unica alta" % bid)

    # (d) conteos coherentes
    if datos_despues["metricas"]["entradas"] != datos_antes["metricas"]["entradas"] - len(acciones):
        fallos.append("entradas %d -> %d (esperado -%d)"
                      % (datos_antes["metricas"]["entradas"],
                         datos_despues["metricas"]["entradas"], len(acciones)))
    return fallos


def ejecutar(ruta, aplicar_cambios):
    texto = leer_texto(ruta)
    lineas = texto.split("\n")
    datos = mb.leer_registro(ruta, "")
    acciones = plan(lineas, datos)
    print("=" * 70)
    print("CONSOLIDACION DE ENTRADAS DUPLICADAS — %s" % ruta)
    print("=" * 70)
    print("Ids a consolidar (mismo bug, 2 entradas) : %d" % len(acciones))
    print("Ids en colision (bugs DISTINTOS, no tocar): %d" % len(COLISIONES))
    for bid, motivo in COLISIONES.items():
        print("  - %s: %s" % (bid, motivo))
    if not acciones:
        print("\nNADA POR HACER: no queda ninguna entrada duplicada consolidable.")
        return 0

    for bid, ln, enc, puntero in acciones:
        print("  %s  L%-5d  %s" % (bid, ln, enc[:70]))
        print("        -> %s" % puntero[:100])

    nuevas = aplicar(lineas, acciones)
    nuevo_texto = "\n".join(nuevas)
    tmp = os.path.join(tempfile.mkdtemp(prefix="m102_"), "11-BUGS.md")
    datos_despues = medir_texto(nuevo_texto, tmp)
    fallos = validar(lineas, nuevas, datos, datos_despues, acciones)
    print("\nDefectos (sin dashboard): %d -> %d (esperado %d)"
          % (len(datos["defectos"]), len(datos_despues["defectos"]),
             len(datos["defectos"]) - len(acciones)))
    print("Entradas: %d -> %d | IDs unicos registro: %d -> %d"
          % (datos["metricas"]["entradas"], datos_despues["metricas"]["entradas"],
             datos["metricas"]["ids_unicos_registro"], datos_despues["metricas"]["ids_unicos_registro"]))
    if fallos:
        print("\nABORTADO — invariantes rojas:")
        for f in fallos:
            print("  ! %s" % f)
        return 1
    print("\nINVARIANTES OK: diff lossless, 0 firmas nuevas, duplicados cerrados.")

    if not aplicar_cambios:
        print("DRY-RUN: no se escribio nada. Usar --aplicar.")
        return 0
    escribir_texto(ruta, nuevo_texto)
    print("ESCRITO: %s (%d bytes)" % (ruta, len(nuevo_texto.encode("utf-8"))))
    return 0


def check(ruta):
    datos = mb.leer_registro(ruta, "")
    lineas = leer_texto(ruta).split("\n")
    pend = [b for b in CONSOLIDAR if len(entradas_por_id(datos).get(b, [])) > 1]
    if pend:
        print("CHECK ROJO: quedan duplicados consolidables: %s" % ", ".join(pend))
        return 1
    print("CHECK VERDE: ningun id de CONSOLIDAR queda duplicado.")
    return 0


# --------------------------------------------------------------------------
# selftest
# --------------------------------------------------------------------------
FIXTURE = """# Registro

## 5. Tabla

| ID | Título |
|----|--------|
| BUG-001 | uno |

## 6. Bugs Abiertos (pendientes)

### BUG-001 — bug uno, entrada larga

- **Estado:** [ ] Abierto
- **Severidad:** Mayor
- linea de contenido 1
- linea de contenido 2

## 8. Bloque viejo

## BUG-001: bug uno (registro previo)

- **Fecha de reporte:** 2026-09-01
- **Estado:** [ ] Abierto

### BUG-002 — bug dos, sin duplicado

- **Estado:** [x] Resuelto
"""

FIXTURE_COLISION = """# Registro

## 5. Tabla Resumen de Bugs

| ID | Título |
|----|--------|

## 6. Bugs Abiertos (pendientes)

### BUG-003 — sintoma A del bug tres

- **Estado:** [ ] Abierto

### BUG-003 — sintoma B, DISTINTO, del bug tres

- **Estado:** [ ] Abierto
"""


def _contar(texto, ruta):
    escribir_texto(ruta, texto)
    d = mb.leer_registro(ruta, "")
    return d, collections.Counter(mb.firma_de(x) for x in d["defectos"])


def selftest():
    checks = []

    def check_(cond, msg):
        checks.append((bool(cond), msg))

    tmpd = tempfile.mkdtemp(prefix="m102_selftest_")
    ruta = os.path.join(tmpd, "11-BUGS.md")

    datos, f = _contar(FIXTURE, ruta)
    check_(f.get("entrada_duplicada:BUG-001", 0) >= 1, "fixture reproduce entrada_duplicada")

    lineas = FIXTURE.split("\n")
    ents = [e for e in datos["entradas"] if e["id"] == "BUG-001"]
    check_(len(ents) == 2, "fixture tiene 2 entradas de BUG-001 (medido %d)" % len(ents))

    keep, demote = elegir_par(lineas, ents)
    check_(keep["linea"] == 11, "conserva la entrada con mas contenido (L%d)" % keep["linea"])
    check_(demote["linea"] == 20, "demota la entrada pobre (L%d)" % demote["linea"])

    puntero = linea_puntero(lineas[demote["linea"] - 1], "BUG-001")
    check_(puntero.startswith("> **Registro previo consolidado de BUG-001"),
           "puntero con prefijo canonico")
    check_("bug uno" in puntero, "puntero conserva el titulo")
    check_("## BUG-001" not in puntero, "el puntero ya no es encabezado")

    p2 = linea_puntero("## BUG-009: Titulo con dos puntos", "BUG-009")
    check_(": :" not in p2 and "Titulo con dos puntos" in p2,
           "puntero sin separador residual: %r" % p2)

    nuevas = aplicar(lineas, [("BUG-001", demote["linea"], lineas[demote["linea"] - 1], puntero)])
    texto2 = "\n".join(nuevas)
    datos2, f2 = _contar(texto2, ruta)
    check_(f2.get("entrada_duplicada:BUG-001", 0) == 0, "tras aplicar no hay duplicado")
    check_(datos2["metricas"]["entradas"] == datos["metricas"]["entradas"] - 1,
           "entradas bajan exactamente 1")
    check_(datos2["metricas"]["ids_unicos_registro"] == datos["metricas"]["ids_unicos_registro"],
           "ids unicos del registro NO cambian")
    check_(texto2.count("linea de contenido 1") == 1 and texto2.count("linea de contenido 2") == 1,
           "contenido de la entrada conservada intacto")
    check_("**Fecha de reporte:** 2026-09-01" in texto2, "contenido del duplicado se conserva")
    check_(len(nuevas) == len(lineas), "no cambia el numero de lineas")

    fallos = validar(lineas, nuevas, datos, datos2, [("BUG-001", demote["linea"], lineas[demote["linea"] - 1], puntero)])
    check_(fallos == [], "validar() verde sobre el caso bueno: %s" % fallos)

    # --- guardian EN ROJO (R1): inyeccion de una firma NUEVA ---
    # Fila de tabla para un id sin entrada -> `fila_sin_entrada:BUG-777` es una
    # firma que NO estaba: el guardian tiene que nombrarla.
    roto = texto2.replace("|----|--------|",
                          "|----|--------|\n| BUG-777 | inyectado | M001 | 🟠 Mayor | [ ] Abierto | qa | 2026-01-01 |", 1)
    datos3, _f3 = _contar(roto, ruta)
    fallos3 = validar(nuevas, roto.split("\n"), datos2, datos3,
                      [("BUG-001", demote["linea"], lineas[demote["linea"] - 1], puntero)])
    check_(fallos3 != [], "guardian ROJO: detecta firma nueva (fila inyectada)")
    check_(any("NUEVAS" in x and "fila_sin_entrada:BUG-777" in x for x in fallos3),
           "guardian nombra la firma nueva: %s" % fallos3[:1])

    # --- guardian EN ROJO (R2): borrar una linea de contenido ---
    sin_linea = [l for l in nuevas if l != "- linea de contenido 2"]
    fallos4 = validar(lineas, sin_linea, datos, datos2,
                      [("BUG-001", demote["linea"], lineas[demote["linea"] - 1], puntero)])
    check_(fallos4 != [], "guardian ROJO: detecta perdida de contenido (multiset)")

    # --- el puntero NO se re-consolida (idempotencia) ---
    datos5, f5 = _contar("\n".join(nuevas), ruta)
    check_(f5.get("entrada_duplicada:BUG-001", 0) == 0, "idempotente: 2a pasada no reaplica")

    # --- colision de bugs DISTINTOS: no esta en CONSOLIDAR, no se toca ---
    ruta_c = os.path.join(tmpd, "colision.md")
    dc, fc = _contar(FIXTURE_COLISION, ruta_c)
    check_(fc.get("entrada_duplicada:BUG-003", 0) >= 1, "fixture de colision medido duplicado")
    check_("BUG-003" not in CONSOLIDAR, "una colision no se consolida automaticamente")

    # --- contrato de bytes ---
    ruta_bom = os.path.join(tmpd, "bom.md")
    with open(ruta_bom, "wb") as fh:
        fh.write(b"\xef\xbb\xbf" + FIXTURE.encode("utf-8"))
    try:
        leer_texto(ruta_bom)
        check_(False, "leer_texto aborta con BOM")
    except SystemExit:
        check_(True, "leer_texto aborta con BOM")
    ruta_crlf = os.path.join(tmpd, "crlf.md")
    with open(ruta_crlf, "wb") as fh:
        fh.write(FIXTURE.replace("\n", "\r\n").encode("utf-8"))
    try:
        leer_texto(ruta_crlf)
        check_(False, "leer_texto aborta con CRLF")
    except SystemExit:
        check_(True, "leer_texto aborta con CRLF")

    # --- piso: todos los checks anteriores corrieron ---
    ok = sum(1 for c, _ in checks if c)
    print("=" * 70)
    print("SELFTEST consolidar_entradas_duplicadas — %d checks" % len(checks))
    print("=" * 70)
    for cond, msg in checks:
        print("  [%s] %s" % ("OK" if cond else "FALLA", msg))
    print("\nRESULTADO: %d/%d OK, %d fallos" % (ok, len(checks), len(checks) - ok))
    return 0 if ok == len(checks) else 1


def main(argv=None):
    ap = argparse.ArgumentParser(description="Consolida entradas duplicadas de 11-BUGS.md")
    ap.add_argument("--archivo", default=RUTA_POR_DEFECTO)
    ap.add_argument("--aplicar", action="store_true")
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--selftest", action="store_true")
    args = ap.parse_args(argv)
    if args.selftest:
        return selftest()
    if args.check:
        return check(args.archivo)
    return ejecutar(args.archivo, args.aplicar)


if __name__ == "__main__":
    sys.exit(main())
