#!/usr/bin/env python3
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
# Este archivo es parte de "Isla Ancestral". Ver LICENSE en la raiz.

# M127 iter. 3 (items L141 y L164) - Auditoria automatizada de dependencias.
#
# Responde dos preguntas que el modulo declara como entregable:
#   L141: certificar la ausencia de codigo no autorizado.
#   L164: certificar que el build final no incorpora assets placeholder de
#         terceros sin licencia.
#
# Que comprueba:
#   1. Cada addon presente en game/isla-ancestral/addons/ esta DECLARADO en
#      data/legal/licencias.json. Un addon en disco sin declarar es codigo de
#      terceros dentro del build sin trazabilidad de licencia (caso real:
#      addons/gdUnit4, autor "Mike Schulze" v6.2.1, con LICENSE en disco pero
#      ausente de licencias.json y de NOTICE.md).
#   2. Cada addon declarado tiene un ARCHIVO DE LICENCIA en disco y aparece en
#      NOTICE.md (la obligacion de atribucion de MIT/CC-BY es sobre el binario
#      distribuido, no sobre el repo).
#   3. Cada manifiesto de dependencias (requirements.txt, package.json) esta
#      declarado como EXCLUIDO del build, con motivo. Una exclusion invisible
#      es un agujero negro: aqui se reporta como EXCLUIDA (visible), no se
#      saltea en silencio.
#   4. Los assets de terceros declarados en los inventarios llevan licencia, y
#      los archivos que no son lo que su extension dice (placeholders) se
#      detectan reutilizando tools/legal/validate_asset_metadata.py.
#
# Uso:
#   python tools/legal/audit_dependencies.py --check     # CI: exit 1 si hay hallazgos
#   python tools/legal/audit_dependencies.py --detalle
#   python tools/legal/audit_dependencies.py --json
#
# Exit 0 si OK, 1 si hay hallazgos.

import os
import re
import sys
import json
import argparse

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
SCOPE_JSON = os.path.join(HERE, "audit_dependencies_scope.json")

# Archivos de licencia aceptados como evidencia dentro de un addon.
ARCHIVOS_LICENCIA = ("LICENSE", "LICENSE.md", "LICENSE.txt", "LICENCE",
                     "LICENCE.md", "COPYING", "COPYING.md", "COPYING.txt")

# Manifiestos de dependencias reconocidos.
MANIFIESTOS = ("requirements.txt", "requirements-dev.txt", "package.json",
               "pyproject.toml", "Pipfile")


def _leer_json(ruta):
    with open(ruta, "rb") as fh:
        return json.loads(fh.read().decode("utf-8-sig"))


def normalizar(texto):
    """Tokens significativos de un nombre de dependencia."""
    return {t for t in re.split(r"[^a-z0-9]+", texto.lower()) if t and not t.isdigit()}


# --------------------------------------------------------------------------
# 1. Addons en disco
# --------------------------------------------------------------------------
def leer_plugin_cfg(ruta):
    """Metadatos declarados por el propio addon (plugin.cfg / *.gdextension)."""
    datos = {}
    if not os.path.isfile(ruta):
        return datos
    with open(ruta, "r", encoding="utf-8", errors="replace") as fh:
        for linea in fh:
            if "=" in linea and not linea.strip().startswith(";"):
                k, v = linea.split("=", 1)
                datos[k.strip().lower()] = v.strip().strip('"')
    return datos


def addons_en_disco(raiz, dir_addons):
    """[{id, ruta, tiene_licencia, licencia, meta}] por cada addon presente."""
    base = os.path.join(raiz, dir_addons)
    salida = []
    if not os.path.isdir(base):
        return salida
    for nombre in sorted(os.listdir(base)):
        ruta = os.path.join(base, nombre)
        if not os.path.isdir(ruta):
            continue
        lic = next((f for f in ARCHIVOS_LICENCIA if os.path.isfile(os.path.join(ruta, f))), None)
        meta = leer_plugin_cfg(os.path.join(ruta, "plugin.cfg"))
        if not meta:
            ext = next((f for f in sorted(os.listdir(ruta)) if f.endswith(".gdextension")), None)
            meta = leer_plugin_cfg(os.path.join(ruta, ext)) if ext else {}
        salida.append({
            "id": nombre,
            "ruta": "%s/%s" % (dir_addons, nombre),
            "tiene_licencia": lic is not None,
            "licencia": lic,
            "meta": meta,
        })
    return salida


def resolver_declaracion(addon, licencias, mapa):
    """Devuelve el id declarado en licencias.json para un addon, o None.

    Primero el mapa explicito del scope (la intencion declarada por el dueño);
    si no hay, heuristica por interseccion de tokens. La heuristica es solo un
    fallback: no puede declarar nada que no exista en licencias.json.
    """
    ids = {e.get("id") for e in licencias}
    explicito = mapa.get(addon["id"])
    if explicito:
        return explicito if explicito in ids else None
    tokens_addon = normalizar(addon["id"])
    mejor, mejor_puntaje = None, 0
    for e in licencias:
        tokens = normalizar(str(e.get("software", ""))) | normalizar(str(e.get("id", "")))
        comunes = len(tokens & tokens_addon)
        if comunes > mejor_puntaje:
            mejor, mejor_puntaje = e.get("id"), comunes
    return mejor if mejor_puntaje else None


# --------------------------------------------------------------------------
# 2. Manifiestos de dependencias
# --------------------------------------------------------------------------
def buscar_manifiestos(raiz, excluir_dirs):
    salida = []
    for actual, dirs, archivos in os.walk(raiz):
        dirs[:] = [d for d in dirs if d not in excluir_dirs and not d.startswith(".")]
        for nombre in archivos:
            if nombre in MANIFIESTOS:
                salida.append(os.path.relpath(os.path.join(actual, nombre), raiz).replace("\\", "/"))
    return sorted(salida)


def contar_deps(ruta, raiz):
    """Cuantas dependencias declara el manifiesto (informativo)."""
    ruta_abs = os.path.join(raiz, ruta)
    try:
        with open(ruta_abs, "r", encoding="utf-8", errors="replace") as fh:
            texto = fh.read()
    except OSError:
        return 0
    if ruta.endswith(".json"):
        try:
            d = json.loads(texto)
        except Exception:
            return 0
        return len(d.get("dependencies", {})) + len(d.get("devDependencies", {}))
    return sum(1 for l in texto.splitlines() if l.strip() and not l.strip().startswith("#"))


# --------------------------------------------------------------------------
# 3. Assets de terceros y placeholders
# --------------------------------------------------------------------------
def assets_terceros(raiz):
    """Entradas de inventario con origen=tercero: (sin_licencia, total)."""
    sin_lic, total = [], 0
    fuentes = ["game/isla-ancestral/data/legal/modelos_3d.json",
               "game/isla-ancestral/data/legal/audio_licenses.json"]
    for rel in fuentes:
        ruta = os.path.join(raiz, rel)
        if not os.path.isfile(ruta):
            continue
        try:
            datos = _leer_json(ruta)
        except Exception:
            continue
        for it in list(datos.get("assets", [])) + list(datos.get("tracks", [])):
            origen = str(it.get("origen", "")).lower()
            lic = str(it.get("licencia", "")).strip().lower()
            if origen == "tercero" or (lic and lic not in ("propia", "propietaria")):
                total += 1
                if not lic or lic in ("", "desconocida", "pendiente"):
                    sin_lic.append("%s: '%s' (origen=%s)" % (rel, it.get("id", "?"), it.get("origen", "-")))
    return sin_lic, total


def placeholders(raiz, scope):
    """Delega en validate_asset_metadata: archivos que no son lo que dicen ser."""
    try:
        sys.path.insert(0, HERE)
        import validate_asset_metadata as V
    except ImportError as e:
        return None, ["NO_SE_PUDO_IMPORTAR validate_asset_metadata: %s" % e]
    sub = dict(scope.get("asset_scope", {}))
    original = V.SCOPE_JSON
    tmp = os.path.join(raiz, ".workbuddy-tmp-asset-scope.json")
    try:
        with open(tmp, "w", encoding="utf-8") as fh:
            json.dump(sub, fh)
        V.SCOPE_JSON = tmp
        informe, probs = V.construir_informe(raiz)
    finally:
        V.SCOPE_JSON = original
        if os.path.isfile(tmp):
            os.remove(tmp)
    if informe is None:
        return None, probs
    return [h for h in informe["hallazgos"] if h["magic_ok"] is False], []


# --------------------------------------------------------------------------
# 4. Auditoria
# --------------------------------------------------------------------------
def auditar(raiz, scope):
    hallazgos = []
    info = {"addons": [], "manifiestos": [], "problemas": []}

    lic_path = os.path.join(raiz, scope.get("licencias_json", ""))
    if not os.path.isfile(lic_path):
        return None, ["FALTA_LICENCIAS_JSON: %s" % scope.get("licencias_json")]
    try:
        licencias = _leer_json(lic_path).get("licencias", [])
    except Exception as e:
        return None, ["LICENCIAS_ILEGIBLE: %s" % e]
    ids_declarados = {e.get("id") for e in licencias}

    notice_path = os.path.join(raiz, scope.get("notice", "NOTICE.md"))
    notice = ""
    if os.path.isfile(notice_path):
        with open(notice_path, "r", encoding="utf-8", errors="replace") as fh:
            notice = fh.read()
    else:
        info["problemas"].append("FALTA_NOTICE: %s" % scope.get("notice"))

    # --- addons ---
    for addon in addons_en_disco(raiz, scope.get("addons", "")):
        declarado = resolver_declaracion(addon, licencias, scope.get("mapa_addons", {}))
        entrada = {"id": addon["id"], "ruta": addon["ruta"], "declarado_como": declarado,
                   "licencia_en_disco": addon["licencia"], "meta": addon["meta"]}
        info["addons"].append(entrada)
        if declarado is None:
            hallazgos.append({
                "tipo": "DEP_NO_DECLARADA",
                "objeto": addon["ruta"],
                "detalle": "addon presente en disco sin entrada en %s (autor: %s, version: %s)" % (
                    scope.get("licencias_json"), addon["meta"].get("author", "?"), addon["meta"].get("version", "?")),
            })
            continue
        if not addon["tiene_licencia"]:
            hallazgos.append({
                "tipo": "SIN_ARCHIVO_LICENCIA",
                "objeto": addon["ruta"],
                "detalle": "declarado como '%s' pero no hay archivo de licencia en el directorio" % declarado,
            })
        else:
            entrada["licencia_en_disco"] = addon["licencia"]
        # La obligacion de atribucion es sobre el binario distribuido.
        etiqueta = next((str(e.get("software", "")) for e in licencias if e.get("id") == declarado), "")
        if etiqueta and notice and etiqueta.lower() not in notice.lower():
            hallazgos.append({
                "tipo": "NO_EN_NOTICE",
                "objeto": addon["ruta"],
                "detalle": "'%s' declarado en %s pero no aparece en %s (obligacion de atribucion)" % (
                    etiqueta, scope.get("licencias_json"), scope.get("notice")),
            })

    # --- manifiestos ---
    excluidos = scope.get("manifiestos_excluidos", {})
    for rel in buscar_manifiestos(raiz, {".git", ".kilo", "node_modules", "PAPELERA", "Obsoletos", "__pycache__"}):
        n = contar_deps(rel, raiz)
        entrada = {"ruta": rel, "dependencias": n, "excluido_del_build": rel in excluidos}
        info["manifiestos"].append(entrada)
        if rel in excluidos:
            continue
        hallazgos.append({
            "tipo": "MANIFIESTO_NO_DECLARADO",
            "objeto": rel,
            "detalle": "%d dependencias declaradas y el manifiesto no figura en manifiestos_excluidos" % n,
        })

    # --- assets de terceros ---
    sin_lic, total_terceros = assets_terceros(raiz)
    info["assets_terceros"] = total_terceros
    for s in sin_lic:
        hallazgos.append({"tipo": "ASSET_TERCERO_SIN_LICENCIA", "objeto": s, "detalle": "asset de tercero sin licencia declarada"})

    # --- placeholders (delegado) ---
    ph, probs = placeholders(raiz, scope)
    if ph is None:
        info["problemas"].extend(probs)
    else:
        info["placeholders"] = len(ph)
        for h in ph:
            hallazgos.append({
                "tipo": "ASSET_PLACEHOLDER",
                "objeto": h["ruta"],
                "detalle": h["hallazgos"][0] if h["hallazgos"] else "contenido no corresponde a la extension",
            })
    return (info, hallazgos), []


def aplicar_baseline(hallazgos, baseline):
    """Marca los hallazgos que el scope declara como aceptados.

    Un baseline NO es una lista de excepciones silenciosas: cada entrada se
    imprime como ACEPTADO con su motivo y su dueño, y --estricto la cuenta como
    fallo. Es el patron del proyecto: si una heuristica marca algo legitimo, el
    arreglo es darle al humano un lugar donde decirlo por escrito y versionado,
    no aflojar la comprobacion.
    """
    indice = {(b.get("tipo"), b.get("objeto")): b for b in baseline}
    for h in hallazgos:
        b = indice.get((h["tipo"], h["objeto"]))
        if b:
            h["aceptado"] = True
            h["motivo_aceptado"] = b.get("motivo", "")
            h["dueno"] = b.get("dueno", "")
        else:
            h["aceptado"] = False
    # Baseline que ya no matchea ningun hallazgo = deuda saldada: avisar para
    # que se limpie (si no, el baseline se pudre y deja de significar nada).
    usados = {(h["tipo"], h["objeto"]) for h in hallazgos if h.get("aceptado")}
    obsoletos = [b for k, b in indice.items() if k not in usados]
    return obsoletos


def imprimir(info, hallazgos, detalle):
    print("=== audit_dependencies (M127 / L141 + L164) ===")
    print("addons en disco    : %d" % len(info["addons"]))
    print("manifiestos        : %d (%d excluidos del build)" % (
        len(info["manifiestos"]), sum(1 for m in info["manifiestos"] if m["excluido_del_build"])))
    print("assets de terceros : %d" % info.get("assets_terceros", 0))
    print("placeholders       : %d" % info.get("placeholders", 0))

    if info["problemas"]:
        print("\n-- problemas de fuentes --")
        for p in info["problemas"]:
            print("   " + p)

    if detalle:
        print("\n-- addons --")
        for a in info["addons"]:
            print("   %-26s declarado=%s licencia=%s" % (a["id"], a["declarado_como"] or "NO", a["licencia_en_disco"] or "-"))
        print("\n-- manifiestos --")
        for m in info["manifiestos"]:
            print("   %-40s deps=%-4d excluido=%s" % (m["ruta"], m["dependencias"], m["excluido_del_build"]))

    nuevos = [h for h in hallazgos if not h.get("aceptado")]
    aceptados = [h for h in hallazgos if h.get("aceptado")]

    if aceptados:
        print("\n-- aceptados en el baseline (%d) — deuda visible, no silenciada --" % len(aceptados))
        for h in aceptados:
            print("   [ACEPTADO][%s] %s" % (h["tipo"], h["objeto"]))
            print("      motivo: %s" % h.get("motivo_aceptado", ""))
            print("      dueño : %s" % (h.get("dueno", "")))

    if nuevos:
        print("\n-- HALLAZGOS NUEVOS (%d) --" % len(nuevos))
        for h in nuevos:
            print("   [%s] %s" % (h["tipo"], h["objeto"]))
            print("      %s" % h["detalle"])


def main(argv=None):
    ap = argparse.ArgumentParser(description="Auditoria de dependencias (M127 L141/L164)")
    ap.add_argument("--raiz", default=PROJECT_ROOT)
    ap.add_argument("--check", action="store_true", help="exit 1 solo si hay hallazgos NUEVOS")
    ap.add_argument("--estricto", action="store_true", help="exit 1 si hay cualquier hallazgo (baseline incluido)")
    ap.add_argument("--detalle", action="store_true")
    ap.add_argument("--json", action="store_true")
    args = ap.parse_args(argv)

    if not os.path.isfile(SCOPE_JSON):
        print("[FALLO] FALTA_SCOPE: %s" % SCOPE_JSON)
        return 1
    try:
        scope = _leer_json(SCOPE_JSON)
    except Exception as e:
        print("[FALLO] SCOPE_ILEGIBLE: %s" % e)
        return 1

    resultado, problemas = auditar(args.raiz, scope)
    if resultado is None:
        for p in problemas:
            print("[FALLO] " + p)
        return 1
    info, hallazgos = resultado
    obsoletos = aplicar_baseline(hallazgos, scope.get("baseline", []))
    info["baseline_obsoleto"] = obsoletos

    nuevos = [h for h in hallazgos if not h["aceptado"]]
    total = len(hallazgos) + len(info["problemas"])
    fallos = len(nuevos) + len(info["problemas"])

    if args.json:
        print(json.dumps({"info": info, "hallazgos": hallazgos}, ensure_ascii=False, indent=2))
        print("=== Resumen: %d nuevos, %d totales ===" % (len(nuevos), total), file=sys.stderr)
    else:
        imprimir(info, hallazgos, args.detalle)
        if obsoletos:
            print("\n-- baseline OBSOLETO (%d): el hallazgo ya no existe, limpiar la entrada --" % len(obsoletos))
            for b in obsoletos:
                print("   [%s] %s" % (b.get("tipo"), b.get("objeto")))
        print("\n=== Resumen: %d hallazgo(s) nuevo(s), %d total(es) (%d aceptados) ===" % (
            len(nuevos), total, len(hallazgos) - len(nuevos)))

    if args.estricto and total:
        return 1
    if args.check and fallos:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
