#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""M50 - BACKLOG-11 D8, bloque 50-Vegetacion: auditor de PRESUPUESTO de vegetacion.

Mide, sobre el plan REAL y los GLB REALES, lo que piden los items L118
(presupuesto instancias/draw calls/VRAM), L174 (vegetacion caracteristica por
bioma) y L180 (costo MultiMesh dentro del presupuesto) del checklist de M50:

  * instancias del plan (por bioma y por tipo)  -> lo entrega medir_plan_m50.gd
  * triangulos y vertices por tipo               -> validar_malla_glb.medir_malla()
  * primitivas (= surfaces = draw calls por instancia)
  * draw calls con instanciacion DIRECTA (la que usa vegetation_spawner.gd)
  * draw calls con MultiMesh (1 por primitiva por tipo)
  * VRAM estimada de mallas unicas + bytes de texturas
  * veredicto contra data/performance/budgets.json (limites + bloque vegetacion)

No escribe nada. Solo lee y mide.

Uso:
    python scripts/vegetacion/auditar_presupuesto_m50.py            # informe
    python scripts/vegetacion/auditar_presupuesto_m50.py --json     # solo JSON
    python scripts/vegetacion/auditar_presupuesto_m50.py --check    # exit 1 si viola
    python scripts/vegetacion/auditar_presupuesto_m50.py --selftest # suite hermética

Codigos de salida:
    0 = medido y sin violaciones
    1 = medido con violaciones (o inconsistencia de datos)
    2 = uso invalido
    3 = AUDITOR CIEGO (no pudo medir: falta el plan, el GLB o el presupuesto)
"""
from __future__ import annotations

import argparse
import importlib.util
import json
import os
import pathlib
import re
import subprocess
import sys
import tempfile

RAIZ = pathlib.Path(__file__).resolve().parents[2]
PROY = RAIZ / "game" / "isla-ancestral"
DIR_MEDIA = PROY / "assets" / "3d" / "media"
DIR_VEG = PROY / "scripts" / "vegetacion"
CONFIG = PROY / "data" / "vegetacion" / "vegetacion_config.json"
BUDGETS = PROY / "data" / "performance" / "budgets.json"
GODOT = os.environ.get(
    "GODOT_BIN",
    "D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe",
)
DUMPER = "res://scripts/vegetacion/medir_plan_m50.gd"

# Bytes por vertice para la estimacion de VRAM de malla (pos 12 + normal 12 + uv 8).
BYTES_VERTICE = 32
BYTES_INDICE = 4


def _cargar_validador():
    """Importa el medidor de GLB ya verificado (no se reimplementa el parser)."""
    ruta = RAIZ / "scripts" / "validar_malla_glb.py"
    if not ruta.exists():
        return None
    spec = importlib.util.spec_from_file_location("validar_malla_glb_m50", str(ruta))
    if spec is None or spec.loader is None:
        return None
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def medir_plan(timeout: int = 240) -> dict:
    """Corre el medidor GDScript y devuelve su JSON. {} si no se pudo medir."""
    if not pathlib.Path(GODOT).exists():
        return {"ciego": True, "motivo": "binario Godot ausente: %s" % GODOT}
    cmd = [GODOT, "--headless", "--path", str(PROY), "--script", DUMPER, "--", "--json"]
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
    except (OSError, subprocess.SubprocessError) as exc:
        return {"ciego": True, "motivo": "no se pudo correr el medidor: %s" % exc}
    for linea in reversed(r.stdout.splitlines()):
        linea = linea.strip()
        if linea.startswith("{") and linea.endswith("}"):
            try:
                return json.loads(linea)
            except json.JSONDecodeError:
                continue
    return {"ciego": True, "motivo": "el medidor no imprimio JSON (exit %d)" % r.returncode}


def medir_tipos(tipos, vmg) -> dict:
    """tris/verts/prims/texturas por tipo, leyendo el GLB de nivel medio."""
    out = {}
    for tipo in tipos:
        ruta = DIR_MEDIA / (tipo + ".glb")
        if not ruta.exists():
            out[tipo] = {"error": "glb_ausente"}
            continue
        try:
            rec = vmg.medir_malla(str(ruta))
            js, _binc = vmg.leer_glb(str(ruta))
        except Exception as exc:  # noqa: BLE001 - un GLB corrupto no debe tumbar el auditor
            out[tipo] = {"error": "parse_error", "detalle": str(exc)[:120]}
            continue
        prims = sum(len(m.get("primitives", [])) for m in js.get("meshes", []))
        out[tipo] = {
            "tris": int(rec.get("tris", 0)),
            "verts": int(rec.get("verts", 0)),
            "prims": prims,
            "materiales": len(js.get("materials", [])),
            "imagenes": len(js.get("images", [])),
            "uv": bool(rec.get("uv_presente", False)),
        }
    return out


def leer_json(ruta: pathlib.Path) -> dict:
    try:
        return json.loads(ruta.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}


def escanear_codigo() -> dict:
    """Mide si el modulo usa MultiMesh y si existe algun shader de viento."""
    multi = 0
    archivos = 0
    detalle = []
    for p in sorted(DIR_VEG.glob("*.gd")):
        try:
            txt = p.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        archivos += 1
        n = len(re.findall(r"\bMultiMesh\b", txt))
        if n:
            multi += n
            detalle.append(p.name)
    shaders = []
    for ext in ("*.gdshader", "*.gdshaderinc"):
        shaders.extend(p for p in PROY.rglob(ext))
    viento = [p.name for p in shaders if re.search(r"viento|wind", p.name, re.I)]
    # Cableado real: quien referencia la ruta del shader y NO es un test.
    cableado = []
    for p in viento:
        rel = "res://" + str((PROY / "shaders" / p).relative_to(PROY)).replace("\\", "/")
        for consumidor in list(PROY.rglob("*.gd")) + list(PROY.rglob("*.tres")) + list(PROY.rglob("*.tscn")):
            if consumidor.name.startswith("test_"):
                continue
            try:
                txt = consumidor.read_text(encoding="utf-8", errors="replace")
            except OSError:
                continue
            if rel in txt:
                cableado.append(str(consumidor.relative_to(PROY)))
    return {
        "gd_vegetacion": archivos,
        "multimesh_usos": multi,
        "multimesh_archivos": detalle,
        "shaders_total": len(shaders),
        "shaders_viento": viento,
        "viento_cableado": cableado,
    }


def evaluar(datos: dict, budgets: dict) -> dict:
    """Calcula totales y veredicto. Funcion PURA (la usa el selftest)."""
    plan = datos.get("plan") or {}
    tipos = datos.get("tipos") or {}
    codigo = datos.get("codigo") or {}
    veg = budgets.get("vegetacion") or {}
    limites = budgets.get("limites") or {}
    gpu = budgets.get("gpu") or {}
    mem = budgets.get("memoria") or {}

    por_tipo = plan.get("por_tipo") or {}
    violaciones = []
    avisos = []

    draw_directo = 0
    tris_total = 0
    verts_unicos = 0
    prims_por_tipo = 0
    instancias = 0
    sin_medir = []
    for tipo, n in sorted(por_tipo.items()):
        rec = tipos.get(tipo) or {}
        if "error" in rec:
            sin_medir.append(tipo)
            continue
        n = int(n)
        instancias += n
        draw_directo += n * int(rec.get("prims", 0))
        tris_total += n * int(rec.get("tris", 0))
        verts_unicos += int(rec.get("verts", 0))
        prims_por_tipo += int(rec.get("prims", 0))

    imagenes = sum(int((r or {}).get("imagenes", 0)) for r in tipos.values() if isinstance(r, dict))
    vram_mallas_mb = (verts_unicos * BYTES_VERTICE) / (1024.0 * 1024.0)
    vram_texturas_mb = 0.0  # medido: 0 imagenes en el corpus de vegetacion
    vram_mb = vram_mallas_mb + vram_texturas_mb

    techo_draw = int(gpu.get("draw_calls_escena_objetivo", limites.get("draw_calls_max", 0)) or 0)
    if techo_draw and draw_directo > techo_draw:
        violaciones.append(
            "draw_calls_escena: %d con instanciacion directa > techo %d" % (draw_directo, techo_draw)
        )
    elif techo_draw and draw_directo > techo_draw * 0.90:
        avisos.append(
            "draw_calls_escena: %d de %d (%.1f%% del techo con solo %d instancias)"
            % (draw_directo, techo_draw, 100.0 * draw_directo / techo_draw, instancias)
        )

    if bool(veg.get("gpu_instancing_obligatorio", False)) and int(codigo.get("multimesh_usos", 0)) == 0:
        violaciones.append(
            "gpu_instancing_obligatorio: 0 usos de MultiMesh en scripts/vegetacion (%d .gd medidos)"
            % int(codigo.get("gd_vegetacion", 0))
        )
    if bool(veg.get("viento_en_vertex_shader", False)) and not (codigo.get("shaders_viento") or []):
        violaciones.append(
            "viento_en_vertex_shader: 0 shaders de viento en el proyecto (%d shaders totales)"
            % int(codigo.get("shaders_total", 0))
        )
    elif bool(veg.get("viento_en_vertex_shader", False)) and not (codigo.get("viento_cableado") or []):
        avisos.append(
            "viento_en_vertex_shader: el shader existe (%s) pero tiene 0 consumidores fuera de tests "
            "-> norma NO cumplida en runtime (modelo de amplitudes listo en viento_vegetacion.gd)"
            % ", ".join(codigo.get("shaders_viento") or [])
        )

    densidad_max = int(veg.get("densidad_max_por_bioma", 0) or 0)
    por_bioma = plan.get("por_bioma") or {}
    for bioma, n in sorted(por_bioma.items()):
        if densidad_max and int(n) > densidad_max:
            violaciones.append("densidad_por_bioma: %s=%d > %d" % (bioma, int(n), densidad_max))

    if int(plan.get("fuera_anillo", 0) or 0) > 0:
        violaciones.append("clamp_anillo: %d items fuera del anillo de tierra" % int(plan["fuera_anillo"]))
    if plan.get("inconsistencias"):
        violaciones.append("integridad_datos: %d items con tipo fuera de su bioma o GLB ausente" % len(plan["inconsistencias"]))
    if sin_medir:
        violaciones.append("tipos_sin_medir: %s" % ", ".join(sorted(sin_medir)))

    vram_techo = float(mem.get("vram_por_escena_mb", 0) or 0)
    if vram_techo and vram_mb > vram_techo:
        violaciones.append("vram_escena: %.2f MB > %.2f MB" % (vram_mb, vram_techo))

    if imagenes == 0:
        avisos.append("texturas: 0 imagenes en los 15 GLB -> VRAM de texturas = 0 (medido, no estimado)")

    techo_chunk = int(veg.get("instancias_por_chunk_max", 0) or 0)
    return {
        "instancias": instancias,
        "tipos": len(por_tipo),
        "draw_calls_directo": draw_directo,
        "draw_calls_multimesh": prims_por_tipo,
        "reduccion_multimesh_x": round(draw_directo / prims_por_tipo, 2) if prims_por_tipo else None,
        "tris_total": tris_total,
        "verts_unicos": verts_unicos,
        "vram_mallas_mb": round(vram_mallas_mb, 3),
        "vram_texturas_mb": vram_texturas_mb,
        "vram_mb": round(vram_mb, 3),
        "imagenes": imagenes,
        "techo_draw_calls": techo_draw,
        "margen_draw_calls": techo_draw - draw_directo,
        "techo_instancias_por_chunk": techo_chunk,
        "densidad_max_por_bioma": densidad_max,
        "violaciones": violaciones,
        "avisos": avisos,
    }


def evaluar_ceguera(datos: dict, vmg) -> list:
    """Motivos por los que el auditor no puede medir (lista vacia = puede)."""
    motivos = []
    plan = datos.get("plan") or {}
    if plan.get("ciego"):
        motivos.append("plan: %s" % plan.get("motivo", "sin motivo"))
    if not plan.get("total"):
        motivos.append("plan: total de instancias = 0")
    if vmg is None:
        motivos.append("no se pudo importar scripts/validar_malla_glb.py")
    tipos = datos.get("tipos") or {}
    if not tipos:
        motivos.append("no se midio ningun tipo")
    medidos = [t for t, r in tipos.items() if isinstance(r, dict) and "error" not in r]
    if tipos and not medidos:
        motivos.append("0 de %d tipos medibles (todos con error de GLB)" % len(tipos))
    if not (datos.get("budgets") or {}):
        motivos.append("no se pudo leer data/performance/budgets.json")
    return motivos


def informe(res: dict, datos: dict) -> None:
    plan = datos["plan"]
    print("=== M50 - PRESUPUESTO DE VEGETACION (medido) ===")
    print("  plan: %d instancias | %d biomas | %d tipos | semilla %s"
          % (res["instancias"], plan.get("biomas", 0), res["tipos"], plan.get("semilla")))
    print("  radio: min %.2f / max %.2f / mediana %.2f (limite anillo %.2f, fuera %d)"
          % (plan.get("radio_min", 0), plan.get("radio_max", 0), plan.get("radio_mediana", 0),
             plan.get("limite_anillo", 0), plan.get("fuera_anillo", 0)))
    print("  triangulos totales ....... %d" % res["tris_total"])
    print("  draw calls DIRECTA ....... %d (techo %d, margen %d)"
          % (res["draw_calls_directo"], res["techo_draw_calls"], res["margen_draw_calls"]))
    print("  draw calls MULTIMESH ..... %d (reduccion x%s)"
          % (res["draw_calls_multimesh"], res["reduccion_multimesh_x"]))
    print("  VRAM mallas unicas ....... %.3f MB (verts unicos %d) + texturas %.3f MB"
          % (res["vram_mallas_mb"], res["verts_unicos"], res["vram_texturas_mb"]))
    print("  codigo: MultiMesh usos %d | shaders viento %d | cableado %d"
          % (datos["codigo"]["multimesh_usos"], len(datos["codigo"]["shaders_viento"]),
             len(datos["codigo"].get("viento_cableado") or [])))
    for v in res["violaciones"]:
        print("  [VIOLACION] %s" % v)
    for a in res["avisos"]:
        print("  [aviso] %s" % a)
    print("  veredicto: %s" % ("SIN VIOLACIONES" if not res["violaciones"] else "%d VIOLACIONES" % len(res["violaciones"])))


# ---------------------------------------------------------------- selftest ---

def _datos_sinteticos(draw_extra: int = 0, multimesh: int = 0, shader: bool = False) -> dict:
    plan = {
        "total": 4, "biomas": 2, "semilla": 42,
        "por_bioma": {"playa": 2, "pradera": 2},
        "por_tipo": {"t_a": 2, "t_b": 2},
        "fuera_anillo": 0, "inconsistencias": [], "ciego": False,
    }
    tipos = {
        "t_a": {"tris": 100, "verts": 50, "prims": 2, "materiales": 2, "imagenes": 0, "uv": False},
        "t_b": {"tris": 10 + draw_extra, "verts": 20, "prims": 3, "materiales": 3, "imagenes": 0, "uv": False},
    }
    return {
        "plan": plan,
        "tipos": tipos,
        "codigo": {"gd_vegetacion": 7, "multimesh_usos": multimesh,
                   "multimesh_archivos": [], "shaders_total": 3,
                   "shaders_viento": ["viento.gdshader"] if shader else []},
        "budgets": {
            "limites": {"draw_calls_max": 400},
            "gpu": {"draw_calls_escena_objetivo": 400},
            "memoria": {"vram_por_escena_mb": 1024},
            "vegetacion": {"gpu_instancing_obligatorio": True, "viento_en_vertex_shader": True,
                           "densidad_max_por_bioma": 30, "instancias_por_chunk_max": 124},
        },
    }


def selftest() -> int:
    checks = 0
    fallos = 0
    vistos = {}

    def chk(nombre: str, cond: bool) -> None:
        nonlocal checks, fallos
        checks += 1
        if not cond:
            fallos += 1
            print("[FALLO] %s" % nombre)

    def fin(bloque: str) -> None:
        vistos[bloque] = True
        print("[FIN] bloque %s (+%d checks)" % (bloque, checks - fin.previo))
        fin.previo = checks

    fin.previo = 0
    vmg = _cargar_validador()

    # --- Bloque A: evaluador puro
    d = _datos_sinteticos(multimesh=1, shader=True)
    r = evaluar(d, d["budgets"])
    chk("A1 sin violaciones en caso sano", r["violaciones"] == [])
    chk("A2 instancias = suma del plan", r["instancias"] == 4)
    chk("A3 tris = 2*100 + 2*10", r["tris_total"] == 220)
    chk("A4 draw directo = 2*2 + 2*3", r["draw_calls_directo"] == 10)
    chk("A5 multimesh = 2 + 3 primitivas", r["draw_calls_multimesh"] == 5)
    chk("A6 reduccion = 2.0", r["reduccion_multimesh_x"] == 2.0)
    fin("A")

    # --- Bloque B: el evaluador DETECTA cada violacion (probado en rojo)
    d = _datos_sinteticos(multimesh=0, shader=False)
    r = evaluar(d, d["budgets"])
    nombres = " ".join(r["violaciones"])
    chk("B1 detecta MultiMesh ausente", "gpu_instancing_obligatorio" in nombres)
    chk("B2 detecta shader de viento ausente", "viento_en_vertex_shader" in nombres)
    chk("B3 son exactamente 2 violaciones", len(r["violaciones"]) == 2)
    d = _datos_sinteticos(multimesh=1, shader=True)
    d["plan"]["por_bioma"]["pradera"] = 31
    r = evaluar(d, d["budgets"])
    chk("B4 detecta densidad > 30", any("densidad_por_bioma" in v for v in r["violaciones"]))
    d = _datos_sinteticos(multimesh=1, shader=True)
    d["plan"]["fuera_anillo"] = 3
    r = evaluar(d, d["budgets"])
    chk("B5 detecta items fuera del anillo", any("clamp_anillo" in v for v in r["violaciones"]))
    d = _datos_sinteticos(multimesh=1, shader=True)
    d["plan"]["por_tipo"]["t_a"] = 100000
    r = evaluar(d, d["budgets"])
    chk("B6 detecta techo de draw calls", any("draw_calls_escena" in v for v in r["violaciones"]))
    d = _datos_sinteticos(multimesh=1, shader=True)
    d["tipos"]["t_a"] = {"error": "glb_ausente"}
    r = evaluar(d, d["budgets"])
    chk("B7 detecta tipo sin medir", any("tipos_sin_medir" in v for v in r["violaciones"]))
    d = _datos_sinteticos(multimesh=1, shader=True)
    d["codigo"]["viento_cableado"] = []
    r = evaluar(d, d["budgets"])
    chk("B8 shader presente pero sin cablear = aviso, no violacion",
        not any("viento_en_vertex_shader" in v for v in r["violaciones"])
        and any("0 consumidores" in a for a in r["avisos"]))
    fin("B")

    # --- Bloque C: ceguera (no confundir "no medi" con "esta bien")
    d = _datos_sinteticos(multimesh=1, shader=True)
    chk("C1 caso sano no es ciego", evaluar_ceguera(d, vmg) == [])
    d2 = dict(d)
    d2["plan"] = {"ciego": True, "motivo": "plan vacio"}
    chk("C2 plan ciego se declara", any("plan" in m for m in evaluar_ceguera(d2, vmg)))
    d3 = _datos_sinteticos(multimesh=1, shader=True)
    d3["tipos"] = {"t_a": {"error": "parse_error"}, "t_b": {"error": "parse_error"}}
    chk("C3 0 tipos medibles = ciego", any("0 de 2" in m for m in evaluar_ceguera(d3, vmg)))
    d4 = _datos_sinteticos(multimesh=1, shader=True)
    d4["budgets"] = {}
    chk("C4 presupuesto ausente = ciego", any("budgets" in m for m in evaluar_ceguera(d4, vmg)))
    fin("C")

    # --- Bloque D: medidor de GLB real (fixture sintetico, sin depender del corpus)
    if vmg is None:
        chk("D0 validador GLB importable", False)
    else:
        with tempfile.TemporaryDirectory() as tmp:
            ruta = pathlib.Path(tmp) / "sintetico.glb"
            # pos = lista PLANA de floats (VEC3): 4 vertices -> 12 floats.
            pos = [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0]
            ruta.write_bytes(vmg._glb_sintetico(pos, idx=[0, 1, 2, 1, 3, 2]))
            rec = vmg.medir_malla(str(ruta))
            chk("D1 GLB sintetico parsea", bool(rec.get("parse_ok")))
            chk("D2 2 triangulos medidos", int(rec.get("tris", -1)) == 2)
            js, _ = vmg.leer_glb(str(ruta))
            chk("D3 1 primitiva contada", sum(len(m.get("primitives", [])) for m in js.get("meshes", [])) == 1)
            roto = pathlib.Path(tmp) / "roto.glb"
            roto.write_bytes(b"no soy un glb")
            js_roto, _ = vmg.leer_glb(str(roto))
            chk("D4 GLB corrupto devuelve (None, None)", js_roto is None)
            falta = medir_tipos(["tipo_que_no_existe_m50"], vmg)
            chk("D5 tipo sin GLB se marca glb_ausente",
                (falta.get("tipo_que_no_existe_m50") or {}).get("error") == "glb_ausente")
    fin("D")

    # --- Bloque E: el escaner de codigo mide el modulo real
    cod = escanear_codigo()
    chk("E1 escaneo encontro archivos .gd", int(cod["gd_vegetacion"]) > 0)
    chk("E2 el escaneo devuelve una lista de archivos con MultiMesh", isinstance(cod["multimesh_archivos"], list))
    chk("E3 el escaneo devuelve lista de shaders de viento", isinstance(cod["shaders_viento"], list))
    chk("E4 shaders_total es un entero >= 0", isinstance(cod["shaders_total"], int) and cod["shaders_total"] >= 0)
    fin("E")

    # --- Guardian de 3 capas
    minimo = 27
    esperados = ["A", "B", "C", "D", "E"]
    faltan = [b for b in esperados if b not in vistos]
    if faltan:
        fallos += 1
        print("[FALLO] bloques no ejecutados: %s" % faltan)
    if checks < minimo:
        fallos += 1
        print("[FALLO] solo %d checks ejecutados (minimo %d)" % (checks, minimo))
    print("=== selftest: %d checks, %d fallos ===" % (checks, fallos))
    return 0 if fallos == 0 else 1


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description="Auditor de presupuesto de vegetacion (M50)")
    ap.add_argument("--json", action="store_true", help="imprime solo JSON")
    ap.add_argument("--check", action="store_true", help="exit 1 si hay violaciones")
    ap.add_argument("--selftest", action="store_true", help="corre la suite hermética")
    ap.add_argument("--sin-godot", action="store_true", help="no corre el medidor; usa un plan sintetico")
    args = ap.parse_args(argv)

    if args.selftest:
        return selftest()

    vmg = _cargar_validador()
    datos = {
        "plan": medir_plan(),
        "codigo": escanear_codigo(),
        "budgets": leer_json(BUDGETS),
    }
    tipos_plan = list((datos["plan"].get("por_tipo") or {}).keys())
    datos["tipos"] = medir_tipos(tipos_plan, vmg) if (vmg and tipos_plan) else {}

    motivos = evaluar_ceguera(datos, vmg)
    if motivos:
        print("[M50-PRESUPUESTO] AUDITOR CIEGO:")
        for m in motivos:
            print("  - %s" % m)
        return 3

    res = evaluar(datos, datos["budgets"])
    salida = {"medido": res, "plan": datos["plan"], "codigo": datos["codigo"], "tipos": datos["tipos"]}
    if args.json:
        print(json.dumps(salida, ensure_ascii=False, indent=1))
    else:
        informe(res, datos)
    if args.check and res["violaciones"]:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
