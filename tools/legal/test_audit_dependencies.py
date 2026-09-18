#!/usr/bin/env python3
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
# Este archivo es parte de "Isla Ancestral". Ver LICENSE en la raiz.

# M127 iter. 3 - Suite de tools/legal/audit_dependencies.py.
#
# Fixture: repositorio minimo con los 4 casos que el auditor debe distinguir:
#   - addon declarado, con licencia en disco y en NOTICE   -> sin hallazgo
#   - addon declarado, SIN archivo de licencia              -> SIN_ARCHIVO_LICENCIA
#   - addon declarado, ausente de NOTICE                    -> NO_EN_NOTICE
#   - addon NO declarado                                    -> DEP_NO_DECLARADA
# mas manifiestos (declarado/excluido y no declarado), un asset placeholder y un
# asset de tercero sin licencia.
#
# Guardas anti-falso-verde: _fin() por bloque, piso CHECKS_MINIMOS, y el piso
# probado por inyeccion en test_inyeccion().

import io
import os
import sys
import json
import shutil
import contextlib
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import audit_dependencies as A  # noqa: E402

MODULO = "M127 audit_dependencies"
CHECKS_MINIMOS = 20

_checks = 0
_fallos = 0
_vistos = {}
BLOQUES = ["helpers", "addons", "manifiestos", "assets", "baseline", "inyeccion"]


def _check(cond, msg):
    global _checks, _fallos
    _checks += 1
    if cond:
        print("  [OK] %s" % msg)
    else:
        _fallos += 1
        print("  [FALLO] %s" % msg)


def _fin(nombre):
    _vistos[nombre] = True


def _resumen():
    for n in BLOQUES:
        if n not in _vistos:
            print("  [FALLO] bloque '%s' NO se ejecuto (posible aborto)" % n)
            globals()["_fallos"] += 1
            globals()["_checks"] += 1
    if _checks < CHECKS_MINIMOS:
        print("  [FALLO] solo %d checks ejecutados (minimo %d)" % (_checks, CHECKS_MINIMOS))
        globals()["_fallos"] += 1
        globals()["_checks"] += 1
    print("=== Resumen %s: %d checks, %d fallo(s) ===" % (MODULO, _checks, _fallos))
    return 1 if _fallos else 0


# ---------------------------------------------------------------- fixture
def escribir(base, rel, contenido):
    ruta = os.path.join(base, rel)
    os.makedirs(os.path.dirname(ruta), exist_ok=True)
    modo = "wb" if isinstance(contenido, bytes) else "w"
    with open(ruta, modo, **({} if isinstance(contenido, bytes) else {"encoding": "utf-8"})) as fh:
        fh.write(contenido)
    return ruta


SCOPE_BASE = {
    "version": 1,
    "addons": "game/isla-ancestral/addons",
    "licencias_json": "game/isla-ancestral/data/legal/licencias.json",
    "notice": "NOTICE.md",
    "mapa_addons": {},
    "manifiestos_excluidos": {"requirements.txt": "tooling de desarrollo, fuera del build"},
    "asset_scope": {"rutas": ["game/isla-ancestral/assets"], "extensiones": [".png"], "excluir": []},
}


def construir_fixture(base):
    # --- addons ---
    escribir(base, "game/isla-ancestral/addons/dep_ok/LICENSE", "MIT License\n")
    escribir(base, "game/isla-ancestral/addons/dep_ok/plugin.cfg",
             '[plugin]\nname="Dep OK"\nauthor="Autora"\nversion="1.0"\n')
    escribir(base, "game/isla-ancestral/addons/dep_sin_lic/plugin.cfg",
             '[plugin]\nname="Dep Sin Lic"\nauthor="Otro"\nversion="2.0"\n')
    escribir(base, "game/isla-ancestral/addons/huerfano/LICENSE", "MIT License\n")
    escribir(base, "game/isla-ancestral/addons/huerfano/plugin.cfg",
             '[plugin]\nname="Huerfano"\nauthor="Nadie"\nversion="9.9"\n')

    # --- licencias declaradas ---
    escribir(base, "game/isla-ancestral/data/legal/licencias.json", json.dumps({
        "licencias": [
            {"id": "dep_ok", "software": "Dep OK", "licencia": "MIT", "uso": "test"},
            {"id": "dep_sin_lic", "software": "Dep Sin Lic", "licencia": "MIT", "uso": "test"},
        ]}))
    escribir(base, "game/isla-ancestral/data/legal/modelos_3d.json", json.dumps({
        "assets": [{"id": "modelo_x", "origen": "tercero", "licencia": ""}]}))
    escribir(base, "game/isla-ancestral/data/legal/audio_licenses.json", json.dumps({
        "tracks": [{"id": "tema_y", "licencia": "propia"}]}))

    # NOTICE: nombra "Dep OK" pero NO "Dep Sin Lic"
    escribir(base, "NOTICE.md", "# Notice\n\n## Terceros\n\n- **Dep OK** - MIT\n")

    # --- manifiestos ---
    escribir(base, "requirements.txt", "paquete==1.0\notro==2.0\n# comentario\n")
    escribir(base, "package.json", json.dumps({"dependencies": {"a": "1"}, "devDependencies": {"b": "2"}}))

    # --- asset placeholder (PNG con contenido HTML) ---
    escribir(base, "game/isla-ancestral/assets/x.png", b"\n\n<!DOCTYPE html>\n<html>x</html>\n" * 6)


def escribir_scope(base, extra=None):
    scope = json.loads(json.dumps(SCOPE_BASE))
    if extra:
        scope.update(extra)
    ruta = os.path.join(base, "_scope.json")
    escribir(base, "_scope.json", json.dumps(scope, ensure_ascii=False))
    return ruta


# ---------------------------------------------------------------- bloques
def test_helpers(base):
    print("\n-- bloque helpers --")
    _check(A.normalizar("Voxel Tools") == {"voxel", "tools"}, "normalizar separa tokens")
    _check(A.normalizar("zylann.voxel") == {"zylann", "voxel"}, "normalizar corta por puntos")
    # El filtro isdigit() descarta tokens que son SOLO digitos (el "4" de
    # "gdUnit-4"), no los digitos dentro de un token: "gdUnit4" -> {"gdunit4"}.
    _check(A.normalizar("gdUnit4") == {"gdunit4"}, "normalizar conserva el sufijo dentro del token")
    _check(A.normalizar("gdUnit-4") == {"gdunit"}, "normalizar descarta el token que es solo un numero")

    # Resolucion explicita por mapa
    licencias = [{"id": "voxel_tools", "software": "Voxel Tools"}]
    addon = {"id": "zylann.voxel", "meta": {}}
    _check(A.resolver_declaracion(addon, licencias, {"zylann.voxel": "voxel_tools"}) == "voxel_tools",
           "el mapa explicito resuelve la declaracion")
    # Mapa explicito que apunta a un id inexistente -> NO declara (no inventa)
    _check(A.resolver_declaracion(addon, licencias, {"zylann.voxel": "no_existe"}) is None,
           "mapa a un id inexistente -> None (no inventa la declaracion)")
    # Heuristica por tokens
    _check(A.resolver_declaracion(addon, licencias, {}) == "voxel_tools",
           "la heuristica por tokens resuelve zylann.voxel -> voxel_tools")
    # Sin ninguna coincidencia
    _check(A.resolver_declaracion({"id": "gdunit4", "meta": {}}, licencias, {}) is None,
           "gdUnit4 no matchea ninguna licencia declarada -> None")

    # plugin.cfg
    cfg = A.leer_plugin_cfg(os.path.join(base, "game/isla-ancestral/addons/dep_ok/plugin.cfg"))
    _check(cfg.get("author") == "Autora" and cfg.get("version") == "1.0", "lee plugin.cfg")
    _check(A.leer_plugin_cfg(os.path.join(base, "no_existe.cfg")) == {}, "plugin.cfg ausente -> {}")
    _fin("helpers")


def test_addons(base):
    print("\n-- bloque addons --")
    scope = json.loads(json.dumps(SCOPE_BASE))
    (info, hallazgos), probs = A.auditar(base, scope)
    _check(probs == [], "auditar no reporta problemas de fuentes")
    tipos = {(h["tipo"], h["objeto"]) for h in hallazgos}

    _check(len(info["addons"]) == 3, "detecta los 3 addons en disco: %d" % len(info["addons"]))
    _check(("DEP_NO_DECLARADA", "game/isla-ancestral/addons/huerfano") in tipos,
           "addon no declarado -> DEP_NO_DECLARADA")
    _check(("SIN_ARCHIVO_LICENCIA", "game/isla-ancestral/addons/dep_sin_lic") in tipos,
           "declarado sin LICENSE -> SIN_ARCHIVO_LICENCIA")
    _check(("NO_EN_NOTICE", "game/isla-ancestral/addons/dep_sin_lic") in tipos,
           "declarado pero ausente de NOTICE -> NO_EN_NOTICE")
    _check(not any(o == "game/isla-ancestral/addons/dep_ok" for _, o in tipos),
           "el addon correcto (declarado + LICENSE + en NOTICE) NO genera hallazgo")

    detalle_huerfano = next(h["detalle"] for h in hallazgos if h["objeto"].endswith("huerfano"))
    _check("Nadie" in detalle_huerfano and "9.9" in detalle_huerfano,
           "el hallazgo cita autor y version del plugin.cfg")
    _fin("addons")


def test_manifiestos(base):
    print("\n-- bloque manifiestos --")
    scope = json.loads(json.dumps(SCOPE_BASE))
    (info, hallazgos), _ = A.auditar(base, scope)
    por_ruta = {m["ruta"]: m for m in info["manifiestos"]}
    _check("requirements.txt" in por_ruta, "encuentra requirements.txt")
    _check("package.json" in por_ruta, "encuentra package.json")
    _check(por_ruta["requirements.txt"]["excluido_del_build"] is True, "requirements.txt marcado excluido")
    _check(por_ruta["requirements.txt"]["dependencias"] == 2, "cuenta 2 deps (ignora el comentario): %d"
           % por_ruta["requirements.txt"]["dependencias"])
    _check(por_ruta["package.json"]["dependencias"] == 2, "cuenta deps+devDeps de package.json: %d"
           % por_ruta["package.json"]["dependencias"])
    _check(any(h["tipo"] == "MANIFIESTO_NO_DECLARADO" and h["objeto"] == "package.json" for h in hallazgos),
           "manifiesto no declarado -> MANIFIESTO_NO_DECLARADO")
    _check(not any(h["objeto"] == "requirements.txt" for h in hallazgos),
           "manifiesto declarado como excluido -> sin hallazgo")
    _fin("manifiestos")


def test_assets(base):
    print("\n-- bloque assets --")
    scope = json.loads(json.dumps(SCOPE_BASE))
    (info, hallazgos), _ = A.auditar(base, scope)
    _check(info["assets_terceros"] == 1, "cuenta 1 asset de tercero declarado: %d" % info["assets_terceros"])
    _check(any(h["tipo"] == "ASSET_TERCERO_SIN_LICENCIA" for h in hallazgos),
           "asset de tercero sin licencia -> ASSET_TERCERO_SIN_LICENCIA")
    _check(info.get("placeholders") == 1, "delega en validate_asset_metadata y cuenta 1 placeholder: %s"
           % info.get("placeholders"))
    ph = [h for h in hallazgos if h["tipo"] == "ASSET_PLACEHOLDER"]
    _check(len(ph) == 1 and "HTML" in ph[0]["detalle"], "el placeholder se rotula con el contenido real (HTML)")

    # Si falta el sub-scope de assets, el auditor no debe reventar.
    scope2 = json.loads(json.dumps(SCOPE_BASE))
    del scope2["asset_scope"]
    res2, probs2 = A.auditar(base, scope2)
    _check(res2 is not None, "sin asset_scope el auditor sigue funcionando (no revienta)")
    _fin("assets")


def test_baseline(base):
    print("\n-- bloque baseline --")
    # Sin baseline: hay hallazgos nuevos -> --check sale 1
    scope_path = escribir_scope(base)
    original = A.SCOPE_JSON
    A.SCOPE_JSON = scope_path
    try:
        with contextlib.redirect_stdout(io.StringIO()):
            rc = A.main(["--raiz", base, "--check"])
        _check(rc == 1, "--check sin baseline con hallazgos -> exit 1")
        with contextlib.redirect_stdout(io.StringIO()):
            rc_e = A.main(["--raiz", base, "--estricto"])
        _check(rc_e == 1, "--estricto con hallazgos -> exit 1")

        # Con baseline que acepta TODO hallazgo -> --check sale 0 y --estricto 1
        (_, hallazgos), _ = A.auditar(base, json.loads(json.dumps(SCOPE_BASE)))
        baseline = [{"tipo": h["tipo"], "objeto": h["objeto"], "motivo": "aceptado en el test", "dueno": "test"}
                    for h in hallazgos]
        scope_path = escribir_scope(base, {"baseline": baseline})
        A.SCOPE_JSON = scope_path
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf):
            rc = A.main(["--raiz", base, "--check"])
        _check(rc == 0, "con baseline completo --check -> exit 0")
        salida = buf.getvalue()
        _check("[ACEPTADO]" in salida, "los aceptados se IMPRIMEN (no se silencian)")
        _check("motivo: aceptado en el test" in salida, "el aceptado imprime su motivo")
        with contextlib.redirect_stdout(io.StringIO()):
            rc_e = A.main(["--raiz", base, "--estricto"])
        _check(rc_e == 1, "--estricto sigue contando el baseline como deuda")

        # Un hallazgo NUEVO (fuera del baseline) debe volver a fallar
        scope_path = escribir_scope(base, {"baseline": baseline[:-1]})
        A.SCOPE_JSON = scope_path
        with contextlib.redirect_stdout(io.StringIO()):
            rc = A.main(["--raiz", base, "--check"])
        _check(rc == 1, "un hallazgo fuera del baseline -> --check exit 1 (la guarda sirve)")

        # Baseline obsoleto (acepta algo que ya no existe) se reporta
        obsoleto = baseline + [{"tipo": "DEP_NO_DECLARADA", "objeto": "addons/ya_no_esta", "motivo": "x", "dueno": "y"}]
        scope_path = escribir_scope(base, {"baseline": obsoleto})
        A.SCOPE_JSON = scope_path
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf):
            A.main(["--raiz", base, "--check"])
        _check("baseline OBSOLETO" in buf.getvalue(), "avisa cuando una entrada del baseline ya no aplica")
    finally:
        A.SCOPE_JSON = original
    _fin("baseline")


def test_inyeccion(base):
    print("\n-- bloque inyeccion (el piso de checks esta vivo?) --")
    global _checks, _fallos, _vistos
    guardado = (_checks, _fallos, dict(_vistos))
    _checks, _fallos, _vistos = 2, 0, {}
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        rc = _resumen()
    salida = buf.getvalue()
    _checks, _fallos, _vistos = guardado
    _check(rc == 1, "con 2 checks el piso FALLA y sale 1 (piso vivo)")
    _check("minimo %d" % CHECKS_MINIMOS in salida, "el resumen cita el piso (%d)" % CHECKS_MINIMOS)
    _check("bloque 'inyeccion' NO se ejecuto" in salida, "el resumen nombra los bloques faltantes")
    _fin("inyeccion")


def main():
    base = tempfile.mkdtemp(prefix="m127_audit_deps_")
    try:
        construir_fixture(base)
        test_helpers(base)
        test_addons(base)
        test_manifiestos(base)
        test_assets(base)
        test_baseline(base)
        test_inyeccion(base)
    finally:
        shutil.rmtree(base, ignore_errors=True)
    return _resumen()


if __name__ == "__main__":
    sys.exit(main())
