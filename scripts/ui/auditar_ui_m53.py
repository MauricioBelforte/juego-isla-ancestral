#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""M53 - BACKLOG-11 D8, bloque 53-UI-UX: auditor de COHERENCIA de la UI.

Mide sobre el codigo REAL (solo lectura, sin Godot) lo que piden cuatro items
del checklist de M53:

  * L138 - Feedback visual de colocacion, cosecha y compra (Tween 120 ms)
           -> por cada superficie de accion: hay feedback animado? con que
              duracion? cuantos se apartan de los 120 ms canonicos?
  * L144 - Test de no redundancia: nunca sonido + visual + toast para la misma
           accion -> funciones que emiten 3 canales a la vez, y tests que
           "pasan" afirmando la AUSENCIA del canal (falso verde que consagra
           el defecto).
  * L159 - Coherencia visual entre todas las capas (un solo lenguaje)
           -> literales de color que DUPLICAN un token de ThemeUx (deberian
              usar la constante) y literales fuera de la paleta.
  * L221 - Canvas merge por capa para minimizar draw calls
           -> raices CanvasLayer y colisiones de `layer` explicito.

No escribe nada. Solo lee y mide.

Uso:
    python scripts/ui/auditar_ui_m53.py              # informe legible
    python scripts/ui/auditar_ui_m53.py --json       # solo JSON
    python scripts/ui/auditar_ui_m53.py --check      # exit 1 si hay violacion dura
    python scripts/ui/auditar_ui_m53.py --selftest   # suite hermetica del auditor
    python scripts/ui/auditar_ui_m53.py --raiz DIR   # auditar otro corpus

Codigos de salida:
    0 = medido y sin violaciones duras
    1 = medido con violaciones duras (o corpus sintetico incoherente)
    2 = uso invalido
    3 = AUDITOR CIEGO (no pudo medir: falta el tema, no hay .gd, corpus corto)
"""
from __future__ import annotations

import argparse
import json
import os
import pathlib
import re
import sys
import tempfile

RAIZ = pathlib.Path(__file__).resolve().parents[2]
PROY = RAIZ / "game" / "isla-ancestral"
DIR_SCRIPTS = PROY / "scripts"
TEMA = DIR_SCRIPTS / "ui" / "theme" / "theme_ux.gd"

# ── Constantes de criterio (declaradas, no magicas) ──────────────────────
DURACION_CANONICA_S = 0.12          # 120 ms — L138
TOLERANCIA_S = 0.001
DIST_TOKEN_IGUAL = 0.05             # dos colores a menos de 0.05 son "el mismo"
CORPUS_MINIMO = 100                 # menos .gd que esto = corpus sospechoso -> CIEGO
MIN_CANALES_REDUNDANCIA = 3         # audio + visual + toast

# Archivos que NO son superficie de producto (tests, diagnostico, previews, QA,
# demos/benchmarks/capturas y snapshots con fecha en el nombre). Se declaran:
# lo que cae aca se cuenta aparte ("no-producto"), nunca se descarta en silencio.
PATRON_NO_PRODUCTO = re.compile(
    r"(^test_|_test\.gd$|^_diag|^diag_|^qa_|^preview_|_demo\.gd$|^bench_|^captura_|^caso_"
    r"|^\d{4}-\d{2}-\d{2}_)"
)

# Superficies por accion de L138: (nombre, directorios/carpetas, claves de nombre)
SUPERFICIES = {
    "colocacion": {
        "dirs": ["construccion"],
        "nombre": re.compile(r"coloc|place|build|ghost", re.I),
    },
    "cosecha": {
        "dirs": ["farm"],
        "nombre": re.compile(r"cosech|harvest|crop|recolect", re.I),
    },
    "compra": {
        "dirs": ["shops"],
        "nombre": re.compile(r"compra|purchase|buy|shop|tienda", re.I),
    },
}

# Canales de feedback (L144)
CANALES = {
    "audio": re.compile(
        r"AudioStreamPlayer|play_sfx|SFXManager|FeedbackDirector|sensacion\(|UIFeedback|\.play\("
    ),
    "toast": re.compile(r"notif\.push|NotificationService|\.push\(\s*\{"),
    "visual": re.compile(r"create_tween|tween_property|modulate|pulse|flash"),
    "haptico": re.compile(r"vibrat|haptic|Input\.vibrate"),
}

RE_FUNC = re.compile(r"^func\s+([A-Za-z0-9_]+)\s*\(", re.M)
RE_COLOR = re.compile(r"Color\(\s*([0-9.]+)\s*,\s*([0-9.]+)\s*,\s*([0-9.]+)")
RE_HEX = re.compile(r"\"#([0-9a-fA-F]{6})\"")
RE_TOKEN = re.compile(r"^const\s+(COLOR_[A-Z0-9_]+)\s*:=\s*Color\(([^)]*)\)", re.M)
RE_LAYER = re.compile(r"^\s*layer\s*=\s*(-?[0-9]+)", re.M)
RE_TWEEN_DUR = re.compile(r"tween_property\([^)]*?,\s*([0-9.]+)\s*\)")
RE_EXTIENDE_CANVAS = re.compile(r"^extends\s+CanvasLayer", re.M)

# Un test que "pasa" afirmando que el canal NO existe: consagra el defecto.
RE_ASERCION_AUSENCIA = re.compile(
    r"(?:_check|assert|assert_eq)\([^)]*?(?:==\s*null|==\s*NULL)[^)]*?"
    r"(?:no\s+hay\s+redundancia|no\s+est[aá]\s+montado|no\s+puede\s+haber\s+redundancia"
    r"|sin\s+fuente\s+de\s+sonido|no-op)",
    re.I | re.S,
)


# ── Utilidades ───────────────────────────────────────────────────────────
def _sin_comentarios(txt: str) -> str:
    """Quita comentarios `#` respetando cadenas ("..." y '...').

    Necesario: un comentario que EXPLICA el defecto (p.ej. citando el
    `_check(uf == null, "... no hay redundancia")` que se corrigio) no es el
    defecto. Sin esto, el auditor se acusa a si mismo y el hallazgo se pierde.
    """
    out = []
    i = 0
    n = len(txt)
    comilla = None
    while i < n:
        c = txt[i]
        if comilla:
            out.append(c)
            if c == "\\" and i + 1 < n:
                out.append(txt[i + 1])
                i += 2
                continue
            if c == comilla:
                comilla = None
            i += 1
            continue
        if c in ("\"", "'"):
            comilla = c
            out.append(c)
            i += 1
            continue
        if c == "#":
            while i < n and txt[i] != "\n":
                i += 1
            continue
        out.append(c)
        i += 1
    return "".join(out)


def _leer(ruta: pathlib.Path) -> str:
    """Texto del archivo con los comentarios ya removidos."""
    try:
        crudo = ruta.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return ""
    return _sin_comentarios(crudo)


def _gd(raiz: pathlib.Path) -> list[pathlib.Path]:
    out = []
    for dp, _dn, fn in os.walk(raiz):
        for f in fn:
            if f.endswith(".gd"):
                out.append(pathlib.Path(dp) / f)
    return sorted(out)


def _dist(a, b) -> float:
    return sum((x - y) ** 2 for x, y in zip(a, b)) ** 0.5


def _hex_a_rgb(h: str) -> list[float]:
    return [int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4)]


# ── Bloque A: raices de canvas y colisiones de capa (L221) ───────────────
def medir_canvas(archivos: list[pathlib.Path]) -> dict:
    raices = []
    capas = {}
    for f in archivos:
        txt = _leer(f)
        ext = bool(RE_EXTIENDE_CANVAS.search(txt))
        nuevo = "CanvasLayer.new()" in txt
        if not (ext or nuevo):
            continue
        lay = [int(m) for m in RE_LAYER.findall(txt)]
        raices.append({
            "archivo": str(f),
            "modo": "extends" if ext else "new",
            "layers": lay,
            "explicito": bool(lay),
            "producto": not PATRON_NO_PRODUCTO.search(f.name),
        })
        if ext and lay:
            capas.setdefault(lay[0], []).append(str(f))
    colisiones = {str(k): v for k, v in capas.items() if len(v) > 1}
    return {
        "raices": len(raices),
        "de_producto": sum(1 for r in raices if r["producto"]),
        "sin_layer_explicito": sum(1 for r in raices if not r["explicito"] and r["producto"]),
        "layers_distintos": sorted(capas.keys()),
        "colisiones": colisiones,
        "detalle": raices,
        "violaciones": [
            "L221 colision de layer %s: %s" % (k, ", ".join(sorted(v)))
            for k, v in colisiones.items()
        ],
    }


# ── Bloque B: coherencia de paleta (L159) ────────────────────────────────
def medir_paleta(archivos: list[pathlib.Path], tema: pathlib.Path) -> dict:
    txt_tema = _leer(tema)
    tokens = {}
    for m in RE_TOKEN.finditer(txt_tema):
        vals = [float(x) for x in m.group(2).split(",")]
        tokens[m.group(1)] = vals[:3]
    if not tokens:
        return {"ciego": True, "motivo": "sin tokens COLOR_* en %s" % tema}

    duplican, fuera, sin_medir = [], [], []
    archivos_con_literal = set()
    archivos_con_token = set()
    for f in archivos:
        if f == tema:
            continue
        txt = _leer(f)
        if re.search(r"ThemeUx\.COLOR_[A-Z0-9_]+", txt):
            archivos_con_token.add(str(f))
        colores = []
        for m in RE_COLOR.finditer(txt):
            colores.append([float(m.group(i)) for i in (1, 2, 3)])
        for m in RE_HEX.finditer(txt):
            colores.append(_hex_a_rgb(m.group(1)))
        if not colores:
            continue
        archivos_con_literal.add(str(f))
        es_producto = not PATRON_NO_PRODUCTO.search(f.name)
        for c in colores:
            nombre, val = min(tokens.items(), key=lambda kv: _dist(c, kv[1]))
            d = _dist(c, val)
            reg = {"archivo": str(f), "color": [round(x, 3) for x in c],
                   "token": nombre, "dist": round(d, 3)}
            if not es_producto:
                sin_medir.append(reg)
            elif d <= DIST_TOKEN_IGUAL:
                duplican.append(reg)
            else:
                fuera.append(reg)
    return {
        "tokens": len(tokens),
        "archivos_con_literal": len(archivos_con_literal),
        "archivos_con_token": len(archivos_con_token),
        "literales_duplican_token": len(duplican),
        "literales_fuera_paleta": len(fuera),
        "literales_no_producto": len(sin_medir),
        "detalle_duplican": duplican,
        "detalle_fuera": fuera,
        "violaciones": [
            "L159 literal que duplica %s en %s" % (r["token"], os.path.basename(r["archivo"]))
            for r in duplican
        ],
    }


# ── Bloque C: no redundancia de canales (L144) ───────────────────────────
def medir_redundancia(archivos: list[pathlib.Path]) -> dict:
    triples = []
    dobles = []
    consagran = []
    for f in archivos:
        txt = _leer(f)
        if PATRON_NO_PRODUCTO.search(f.name):
            for m in RE_ASERCION_AUSENCIA.finditer(txt):
                consagran.append({
                    "archivo": str(f),
                    "fragmento": " ".join(m.group(0).split())[:120],
                })
            continue
        lineas = txt.split("\n")
        cortes = [i for i, l in enumerate(lineas) if RE_FUNC.match(l)]
        cortes.append(len(lineas))
        for k in range(len(cortes) - 1):
            a, b = cortes[k], cortes[k + 1]
            cuerpo = "\n".join(lineas[a:b])
            presentes = sorted(n for n, rx in CANALES.items() if rx.search(cuerpo))
            if len(presentes) >= MIN_CANALES_REDUNDANCIA:
                triples.append({"archivo": str(f), "func": lineas[a].strip()[:70],
                                "canales": presentes})
            elif "audio" in presentes and "toast" in presentes:
                dobles.append({"archivo": str(f), "func": lineas[a].strip()[:70],
                               "canales": presentes})
    viol = ["L144 triple canal en %s::%s %s" % (os.path.basename(t["archivo"]),
                                                t["func"], t["canales"]) for t in triples]
    viol += ["L144 test que consagra la ausencia del canal en %s"
             % os.path.basename(c["archivo"]) for c in consagran]
    return {
        "funciones_triple_canal": len(triples),
        "funciones_doble_canal_audio_toast": len(dobles),
        "tests_que_consagran_ausencia": len(consagran),
        "detalle_triples": triples,
        "detalle_dobles": dobles,
        "detalle_consagran": consagran,
        "violaciones": viol,
    }


# ── Bloque D: feedback de 120 ms por accion (L138) ───────────────────────
def medir_feedback(archivos: list[pathlib.Path]) -> dict:
    por_accion = {}
    viol = []
    for accion, cfg in SUPERFICIES.items():
        superficies = []
        for f in archivos:
            en_dir = any(part in f.parts for part in cfg["dirs"])
            if not (en_dir or cfg["nombre"].search(f.name)):
                continue
            if PATRON_NO_PRODUCTO.search(f.name):
                continue
            superficies.append(f)
        durs = []
        con_feedback = []
        for f in superficies:
            txt = _leer(f)
            d = [float(x) for x in RE_TWEEN_DUR.findall(txt)]
            if d:
                con_feedback.append(str(f))
                durs.extend(d)
        conformes = [d for d in durs if abs(d - DURACION_CANONICA_S) <= TOLERANCIA_S]
        desvio = [d for d in durs if abs(d - DURACION_CANONICA_S) > TOLERANCIA_S]
        por_accion[accion] = {
            "archivos_superficie": len(superficies),
            "archivos_con_feedback_animado": len(con_feedback),
            "tweens": len(durs),
            "tweens_120ms": len(conformes),
            "tweens_otra_duracion": len(desvio),
            "duraciones": sorted({round(x, 3) for x in durs}),
            "detalle_con_feedback": con_feedback,
        }
        if not durs:
            viol.append("L138 accion '%s': 0 feedback animado en %d archivos de superficie"
                        % (accion, len(superficies)))
        elif not conformes:
            viol.append("L138 accion '%s': %d tweens y ninguno de 120 ms (%s)"
                        % (accion, len(durs), sorted({round(x, 3) for x in durs})))
    return {
        "duracion_canonica_s": DURACION_CANONICA_S,
        "por_accion": por_accion,
        "violaciones": viol,
    }


# ── Evaluacion completa ──────────────────────────────────────────────────
def evaluar(raiz: pathlib.Path, tema: pathlib.Path | None = None) -> dict:
    raiz = pathlib.Path(raiz)
    tema = pathlib.Path(tema) if tema else (raiz / "ui" / "theme" / "theme_ux.gd")
    if not raiz.is_dir():
        return {"ciego": True, "motivo": "directorio inexistente: %s" % raiz}
    archivos = _gd(raiz)
    if not archivos:
        return {"ciego": True, "motivo": "0 archivos .gd en %s" % raiz}
    if len(archivos) < CORPUS_MINIMO and tema == (DIR_SCRIPTS / "ui" / "theme" / "theme_ux.gd"):
        return {"ciego": True, "motivo": "corpus sospechoso: %d .gd" % len(archivos)}
    paleta = medir_paleta(archivos, tema)
    if paleta.get("ciego"):
        return paleta
    canvas = medir_canvas(archivos)
    redundancia = medir_redundancia(archivos)
    feedback = medir_feedback(archivos)
    violaciones = canvas["violaciones"] + paleta["violaciones"] + \
        redundancia["violaciones"] + feedback["violaciones"]
    return {
        "ciego": False,
        "raiz": str(raiz),
        "archivos_gd": len(archivos),
        "canvas": canvas,
        "paleta": paleta,
        "redundancia": redundancia,
        "feedback": feedback,
        "violaciones_duras": len(violaciones),
        "violaciones": violaciones,
    }


def imprimir(r: dict) -> None:
    if r.get("ciego"):
        print("AUDITOR CIEGO: %s" % r.get("motivo"))
        return
    c, p, rd, fb = r["canvas"], r["paleta"], r["redundancia"], r["feedback"]
    print("=== M53 COHERENCIA UI — %s (%d .gd) ===" % (r["raiz"], r["archivos_gd"]))
    print("[A] L221 canvas: %d raices (%d de producto), %d sin layer explicito, layers=%s, colisiones=%d"
          % (c["raices"], c["de_producto"], c["sin_layer_explicito"],
             c["layers_distintos"], len(c["colisiones"])))
    print("[B] L159 paleta: %d tokens | %d archivos con literal vs %d con token | "
          "duplican token=%d | fuera de paleta=%d | no-producto=%d"
          % (p["tokens"], p["archivos_con_literal"], p["archivos_con_token"],
             p["literales_duplican_token"], p["literales_fuera_paleta"],
             p["literales_no_producto"]))
    print("[C] L144 redundancia: triple canal=%d | audio+toast=%d | tests que consagran ausencia=%d"
          % (rd["funciones_triple_canal"], rd["funciones_doble_canal_audio_toast"],
             rd["tests_que_consagran_ausencia"]))
    print("[D] L138 feedback %.0f ms:" % (fb["duracion_canonica_s"] * 1000))
    for accion, d in fb["por_accion"].items():
        print("      %-12s superficie=%2d con_feedback=%2d tweens=%2d en_120ms=%2d otra=%2d durs=%s"
              % (accion, d["archivos_superficie"], d["archivos_con_feedback_animado"],
                 d["tweens"], d["tweens_120ms"], d["tweens_otra_duracion"], d["duraciones"]))
    print("--- violaciones duras: %d ---" % r["violaciones_duras"])
    for v in r["violaciones"][:40]:
        print("  * " + v)
    if r["violaciones_duras"] > 40:
        print("  ... %d mas (ver --json)" % (r["violaciones_duras"] - 40))


# ── Suite hermetica del auditor ──────────────────────────────────────────
def _corpus_sintetico(base: pathlib.Path, limpio: bool) -> pathlib.Path:
    tema = base / "ui" / "theme" / "theme_ux.gd"
    tema.parent.mkdir(parents=True, exist_ok=True)
    tema.write_text(
        "class_name ThemeUx\n"
        "const COLOR_BG := Color(0.14, 0.16, 0.24)\n"
        "const COLOR_ACENTO := Color(0.87, 0.66, 0.33)\n",
        encoding="utf-8")
    (base / "construccion").mkdir(parents=True, exist_ok=True)
    (base / "farm").mkdir(parents=True, exist_ok=True)
    (base / "shops").mkdir(parents=True, exist_ok=True)
    for d in ("construccion", "farm", "shops"):
        (base / d / "nucleo.gd").write_text("extends Node\n", encoding="utf-8")
    if limpio:
        (base / "farm" / "crop_visual.gd").write_text(
            "extends Node\nfunc _ready() -> void:\n"
            "\tvar t := create_tween()\n\tt.tween_property(self, \"scale\", Vector2.ONE, 0.12)\n",
            encoding="utf-8")
        (base / "construccion" / "ghost_feedback.gd").write_text(
            "extends Node\nfunc _ready() -> void:\n"
            "\tvar t := create_tween()\n\tt.tween_property(self, \"modulate:a\", 1.0, 0.12)\n",
            encoding="utf-8")
        (base / "shops" / "compra_feedback.gd").write_text(
            "extends Node\nfunc _ready() -> void:\n"
            "\tvar t := create_tween()\n\tt.tween_property(self, \"scale\", Vector2.ONE, 0.12)\n",
            encoding="utf-8")
        (base / "hud_ok.gd").write_text(
            "extends CanvasLayer\nfunc _ready() -> void:\n\tlayer = 100\n"
            "\tmodulate = ThemeUx.COLOR_BG\n", encoding="utf-8")
    else:
        # una sola accion con feedback (las otras dos sin el) -> L138
        (base / "farm" / "crop_visual.gd").write_text(
            "extends Node\nfunc _ready() -> void:\n"
            "\tvar t := create_tween()\n\tt.tween_property(self, \"scale\", Vector2.ONE, 0.35)\n",
            encoding="utf-8")
        # literal que duplica un token -> L159
        (base / "hud_malo.gd").write_text(
            "extends CanvasLayer\nconst C := Color(0.14, 0.16, 0.24)\n"
            "func _ready() -> void:\n\tlayer = 100\n", encoding="utf-8")
        # triple canal -> L144
        (base / "emisor_malo.gd").write_text(
            "extends Node\nfunc comprar() -> void:\n"
            "\tUIFeedback.play_confirm()\n"
            "\tnotif.push({\"text\": \"ok\"})\n"
            "\tvar t := create_tween()\n\tt.tween_property(self, \"scale\", Vector2.ONE, 0.12)\n",
            encoding="utf-8")
        # test que consagra la ausencia -> L144
        (base / "test_consagra.gd").write_text(
            "extends SceneTree\nfunc _run() -> void:\n"
            "\t_check(uf == null, \"UIFeedback no está montado: no hay redundancia posible\")\n",
            encoding="utf-8")
        # colision de layer -> L221
        (base / "hud_bis.gd").write_text(
            "extends CanvasLayer\nfunc _ready() -> void:\n\tlayer = 100\n", encoding="utf-8")
    return base


def selftest() -> int:
    checks = 0
    fallos = 0

    def check(cond: bool, msg: str) -> None:
        nonlocal checks, fallos
        checks += 1
        if not cond:
            fallos += 1
            print("FALLO: " + msg)

    with tempfile.TemporaryDirectory() as td:
        base = pathlib.Path(td)
        limpio = _corpus_sintetico(base / "limpio", True)
        r = evaluar(limpio, limpio / "ui" / "theme" / "theme_ux.gd")
        check(not r.get("ciego"), "corpus limpio medible (no ciego)")
        check(r["violaciones_duras"] == 0,
              "corpus limpio sin violaciones duras (medido=%d)" % r["violaciones_duras"])
        check(r["feedback"]["por_accion"]["cosecha"]["tweens_120ms"] == 1,
              "corpus limpio: cosecha con 1 tween de 120 ms")

        sucio = _corpus_sintetico(base / "sucio", False)
        r2 = evaluar(sucio, sucio / "ui" / "theme" / "theme_ux.gd")
        check(not r2.get("ciego"), "corpus sucio medible")
        check(r2["paleta"]["literales_duplican_token"] == 1,
              "detecta 1 literal que duplica token (medido=%d)"
              % r2["paleta"]["literales_duplican_token"])
        check(r2["redundancia"]["funciones_triple_canal"] == 1,
              "detecta 1 funcion triple canal (medido=%d)"
              % r2["redundancia"]["funciones_triple_canal"])
        check(r2["redundancia"]["tests_que_consagran_ausencia"] == 1,
              "detecta 1 test que consagra la ausencia (medido=%d)"
              % r2["redundancia"]["tests_que_consagran_ausencia"])
        check(len(r2["canvas"]["colisiones"]) == 1,
              "detecta 1 colision de layer (medido=%d)" % len(r2["canvas"]["colisiones"]))
        acc = r2["feedback"]["por_accion"]
        check(acc["cosecha"]["tweens_120ms"] == 0 and acc["cosecha"]["tweens"] == 1,
              "cosecha con tween de 0.35 no cuenta como 120 ms")
        check(acc["colocacion"]["tweens"] == 0 and acc["compra"]["tweens"] == 0,
              "colocacion y compra sin feedback medidos como 0")
        check(r2["violaciones_duras"] >= 6,
              "corpus sucio acumula >=6 violaciones (medido=%d)" % r2["violaciones_duras"])

        # ceguera declarada
        vacio = base / "vacio"
        vacio.mkdir()
        r3 = evaluar(vacio)
        check(bool(r3.get("ciego")), "corpus vacio -> CIEGO")
        sin_tema = _corpus_sintetico(base / "sintema", True)
        (sin_tema / "ui" / "theme" / "theme_ux.gd").unlink()
        r4 = evaluar(sin_tema, sin_tema / "ui" / "theme" / "theme_ux.gd")
        check(bool(r4.get("ciego")), "sin theme_ux.gd -> CIEGO")

        # no invencion de numeros: el JSON debe ser serializable y coherente
        js = json.loads(json.dumps(r2))
        check(js["violaciones_duras"] == len(js["violaciones"]),
              "violaciones_duras == len(violaciones) en JSON")

    # Piso medido: si la suite deja de correr checks (bloque abortado), no puede
    # publicar "0 fallos". Se compara contra el valor MEDIDO en verde, no estimado.
    if checks < CHECKS_MINIMOS:
        print("FALLO: piso de checks %d < %d (bloque sin ejecutar)" % (checks, CHECKS_MINIMOS))
        fallos += 1
    print("=== SELFTEST AUDITOR M53: %d checks, %d fallo(s) (piso %d) ==="
          % (checks, fallos, CHECKS_MINIMOS))
    return 1 if fallos else 0


CHECKS_MINIMOS = 14  # MEDIDO en verde 2026-10-25 (14 checks, 0 fallos)


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(description="Auditor de coherencia UI de M53")
    ap.add_argument("--json", action="store_true")
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--selftest", action="store_true")
    ap.add_argument("--raiz", default=str(DIR_SCRIPTS))
    args = ap.parse_args(argv)

    if args.selftest:
        return selftest()

    r = evaluar(pathlib.Path(args.raiz))
    if r.get("ciego"):
        if args.json:
            print(json.dumps(r, ensure_ascii=False))
        else:
            print("AUDITOR CIEGO: %s" % r.get("motivo"))
        return 3
    if args.json:
        print(json.dumps(r, ensure_ascii=False, indent=2))
    else:
        imprimir(r)
    if args.check and r["violaciones_duras"]:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
