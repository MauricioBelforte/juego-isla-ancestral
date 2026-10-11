# -*- coding: utf-8 -*-
"""Verificador de hooks de integración de M105 (Telemetría de Gameplay).

READ-ONLY. Mide, contra el árbol real, qué hooks de integración están cableados hoy:

  H1  M105 -> M104 (Analytics)      : telemetry_director.gd llama registrar_evento()
  H2  hook de cierre de juego       : telemetry_director.gd implementa _notification()
  H3  gameplay -> M105              : scripts/*.gd (fuera de telemetry/ y tests) usan TelemetryDirector
  H4  M22 (historia) -> M105        : subconjunto de H3 en historia/historias
  H5  M71 (progresión) -> M105      : subconjunto de H3 en progresion/logros
  H6  M53 (encuesta) consume        : alguien conecta/usa la señal solicitar_encuesta
  H7  M91 (opt-in UI) -> M105       : alguien llama establecer_opt_in() fuera de telemetry/ y tests
  H8  autoload registrado            : project.godot declara TelemetryDirector

Uso:
  python scripts/verificar_hooks_m105.py
  python scripts/verificar_hooks_m105.py --json

Exit codes: 0 = escaneo completado (informativo, no gate). 2 = error de entorno.
Contexto: Log 1591 (atria-dawn-s2) midió 0 consumidores de gameplay; este script
hace ese estado medible y detecta el día en que un módulo dueño cablea su hook.
"""
import argparse
import json
import os
import re
import sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SCRIPTS = os.path.join(RAIZ, "game", "isla-ancestral", "scripts")
TELEMETRY_DIR = os.path.join(SCRIPTS, "telemetry")
DIRECTOR = os.path.join(TELEMETRY_DIR, "telemetry_director.gd")
PROJECT_GODOT = os.path.join(RAIZ, "game", "isla-ancestral", "project.godot")

EXCLUIR_DIRS = {"telemetry", "backup", "test", "Obsoletos", "obsoletos", ".godot"}
PATRON_TEST = re.compile(r"(^|[/\\])test_")

# Llamada calificada al autoload (forma canónica de uso en el proyecto)
RE_LLAMADA = re.compile(r"\bTelemetryDirector\s*\.")
RE_GETNODE = re.compile(r"get_node\(\s*[\"']/root/TelemetryDirector")
RE_MENCION = re.compile(r"\bTelemetryDirector\b")
RE_SENAL = re.compile(r"\b(solicitar_encuesta|cambio_opt_in|evento_rastreado)\b")
RE_OPTIN = re.compile(r"\bestablecer_opt_in\s*\(")
RE_TRACK = re.compile(r"\b(track_[a-z_]+)\s*\(")


def _leer(ruta):
    with open(ruta, "rb") as fh:
        crudo = fh.read()
    try:
        return crudo.decode("utf-8"), True
    except UnicodeDecodeError:
        return crudo.decode("utf-8", errors="replace"), False


def _es_test(ruta):
    rel = os.path.relpath(ruta, SCRIPTS).replace("\\", "/")
    return bool(PATRON_TEST.search(os.path.basename(ruta))) or rel.startswith("test/")


def escanear_gameplay():
    """Devuelve (archivos_llamada, archivos_mencion, errores_decode, total_gd)."""
    llamadas, menciones, errores = [], [], 0
    total = 0
    for base, dirs, archivos in os.walk(SCRIPTS):
        dirs[:] = [d for d in dirs if d not in EXCLUIR_DIRS]
        rel_base = os.path.relpath(base, SCRIPTS).replace("\\", "/")
        if rel_base.startswith("telemetry"):
            continue
        for nombre in archivos:
            if not nombre.endswith(".gd"):
                continue
            ruta = os.path.join(base, nombre)
            total += 1
            texto, ok = _leer(ruta)
            if not ok:
                errores += 1
            rel = os.path.relpath(ruta, SCRIPTS).replace("\\", "/")
            tiene_llamada = bool(RE_LLAMADA.search(texto) or RE_GETNODE.search(texto))
            mencion = bool(RE_MENCION.search(texto))
            if _es_test(ruta):
                continue  # los tests no cuentan como consumidores de gameplay
            if tiene_llamada:
                apis = sorted(set(RE_TRACK.findall(texto)))
                senales = sorted(set(RE_SENAL.findall(texto)))
                optin = bool(RE_OPTIN.search(texto))
                llamadas.append({
                    "archivo": rel,
                    "track_calls": apis,
                    "senales": senales,
                    "opt_in": optin,
                })
            elif mencion:
                menciones.append(rel)
    return llamadas, menciones, errores, total


def escanear_dir_especifico(subdirs):
    """Subconjunto de H3 restringido a subdirectorios dados (M22, M71...)."""
    hallados = []
    for sub in subdirs:
        raiz_sub = os.path.join(SCRIPTS, sub)
        if not os.path.isdir(raiz_sub):
            continue
        for base, dirs, archivos in os.walk(raiz_sub):
            dirs[:] = [d for d in dirs if d not in EXCLUIR_DIRS]
            for nombre in archivos:
                if not nombre.endswith(".gd"):
                    continue
                ruta = os.path.join(base, nombre)
                if _es_test(ruta):
                    continue
                texto, _ = _leer(ruta)
                if RE_LLAMADA.search(texto) or RE_GETNODE.search(texto):
                    hallados.append(os.path.relpath(ruta, SCRIPTS).replace("\\", "/"))
    return hallados


def verificar():
    resultado = {}
    # H1
    texto_dir, ok_decode = _leer(DIRECTOR) if os.path.isfile(DIRECTOR) else ("", False)
    resultado["H1_m105_a_m104"] = {
        "estado": "CONECTADO" if "registrar_evento" in texto_dir else "NO CONECTADO",
        "evidencia": "telemetry_director.gd contiene 'registrar_evento'" if "registrar_evento" in texto_dir
                     else "telemetry_director.gd NO contiene 'registrar_evento'",
        "decode_ok": ok_decode,
    }
    # H2
    tiene_notif = bool(re.search(r"^func\s+_notification\b", texto_dir, re.M))
    resultado["H2_hook_cierre"] = {
        "estado": "CONECTADO" if tiene_notif else "NO CONECTADO",
        "evidencia": "func _notification" if tiene_notif else "sin func _notification en telemetry_director.gd",
    }
    # H3-H7 (gameplay)
    llamadas, menciones, errores, total_gd = escanear_gameplay()
    resultado["H3_gameplay_a_m105"] = {
        "estado": "CONECTADO" if llamadas else "NO CONECTADO",
        "consumidores": llamadas,
        "menciones_sin_llamada": menciones,
        "archivos_gd_escaneados": total_gd,
        "errores_decode": errores,
    }
    historia = escanear_dir_especifico(["historia", "historias"])
    resultado["H4_m22_historia"] = {"estado": "CONECTADO" if historia else "NO CONECTADO", "archivos": historia}
    progresion = escanear_dir_especifico(["progresion", "logros"])
    resultado["H5_m71_progresion"] = {"estado": "CONECTADO" if progresion else "NO CONECTADO", "archivos": progresion}
    # H6: señal solicitar_encuesta usada fuera de telemetry/
    consumidores_encuesta = []
    for base, dirs, archivos in os.walk(SCRIPTS):
        dirs[:] = [d for d in dirs if d not in EXCLUIR_DIRS]
        rel_base = os.path.relpath(base, SCRIPTS).replace("\\", "/")
        if rel_base.startswith("telemetry"):
            continue
        for nombre in archivos:
            if not nombre.endswith(".gd"):
                continue
            ruta = os.path.join(base, nombre)
            if _es_test(ruta):
                continue
            texto, _ = _leer(ruta)
            if "solicitar_encuesta" in texto:
                consumidores_encuesta.append(os.path.relpath(ruta, SCRIPTS).replace("\\", "/"))
    resultado["H6_m53_encuesta"] = {
        "estado": "CONECTADO" if consumidores_encuesta else "NO CONECTADO",
        "archivos": consumidores_encuesta,
    }
    # H7: establecer_opt_in fuera de telemetry/ y tests
    consumidores_optin = []
    for base, dirs, archivos in os.walk(SCRIPTS):
        dirs[:] = [d for d in dirs if d not in EXCLUIR_DIRS]
        rel_base = os.path.relpath(base, SCRIPTS).replace("\\", "/")
        if rel_base.startswith("telemetry"):
            continue
        for nombre in archivos:
            if not nombre.endswith(".gd"):
                continue
            ruta = os.path.join(base, nombre)
            if _es_test(ruta):
                continue
            texto, _ = _leer(ruta)
            if RE_OPTIN.search(texto):
                consumidores_optin.append(os.path.relpath(ruta, SCRIPTS).replace("\\", "/"))
    resultado["H7_m91_optin_ui"] = {
        "estado": "CONECTADO" if consumidores_optin else "NO CONECTADO",
        "archivos": consumidores_optin,
    }
    # H8
    texto_pg, _ = _leer(PROJECT_GODOT) if os.path.isfile(PROJECT_GODOT) else ("", False)
    autoload = bool(re.search(r"^TelemetryDirector\s*=", texto_pg, re.M))
    resultado["H8_autoload"] = {
        "estado": "REGISTRADO" if autoload else "NO REGISTRADO",
        "evidencia": "project.godot: TelemetryDirector=" if autoload else "project.godot sin entrada TelemetryDirector",
    }
    return resultado


def imprimir_texto(res):
    print("=== Verificador de hooks M105 (Telemetria) - solo lectura ===")
    orden = [
        ("H1_m105_a_m104", "H1 M105->M104 (Analytics)"),
        ("H2_hook_cierre", "H2 hook de cierre (_notification)"),
        ("H3_gameplay_a_m105", "H3 gameplay->M105 (sistemas reales)"),
        ("H4_m22_historia", "H4 M22 historia->M105"),
        ("H5_m71_progresion", "H5 M71 progresion->M105"),
        ("H6_m53_encuesta", "H6 M53 consume solicitar_encuesta"),
        ("H7_m91_optin_ui", "H7 M91 opt-in UI->M105"),
        ("H8_autoload", "H8 autoload en project.godot"),
    ]
    conectados = 0
    for clave, etiqueta in orden:
        item = res[clave]
        estado = item["estado"]
        if estado in ("CONECTADO", "REGISTRADO"):
            conectados += 1
        print(f"  [{estado:>12}] {etiqueta}")
        if clave == "H3_gameplay_a_m105":
            cons = item["consumidores"]
            print(f"               archivos_gd_escaneados={item['archivos_gd_escaneados']} "
                  f"consumidores={len(cons)} menciones_sin_llamada={len(item['menciones_sin_llamada'])} "
                  f"decode_errores={item['errores_decode']}")
            for c in cons:
                extra = []
                if c["track_calls"]:
                    extra.append("track=" + ",".join(c["track_calls"]))
                if c["senales"]:
                    extra.append("senales=" + ",".join(c["senales"]))
                if c["opt_in"]:
                    extra.append("opt_in")
                print(f"               - {c['archivo']}" + ("  [" + "; ".join(extra) + "]" if extra else ""))
            for m in item["menciones_sin_llamada"]:
                print(f"               ~ mencion sin llamada: {m}")
        elif clave in ("H4_m22_historia", "H5_m71_progresion", "H6_m53_encuesta", "H7_m91_optin_ui"):
            for a in item["archivos"]:
                print(f"               - {a}")
        elif "evidencia" in item:
            print(f"               {item['evidencia']}")
    print(f"  -> {conectados}/{len(orden)} hooks cableados. "
          "Los NO CONECTADO son deuda de integracion (dueno: modulo indicado), no bug del verificador.")
    return res


def main():
    parser = argparse.ArgumentParser(description="Verificador de hooks de M105 (solo lectura)")
    parser.add_argument("--json", action="store_true", help="salida JSON")
    args = parser.parse_args()
    if not os.path.isdir(SCRIPTS):
        print(f"ERROR: no existe {SCRIPTS}", file=sys.stderr)
        return 2
    res = verificar()
    if args.json:
        print(json.dumps(res, ensure_ascii=False, indent=2))
    else:
        imprimir_texto(res)
    return 0


if __name__ == "__main__":
    sys.exit(main())
