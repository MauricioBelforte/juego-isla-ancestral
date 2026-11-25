# -*- coding: utf-8 -*-
"""b62 evidence scan. No writes to tracked files; prints measured hits only."""
import os, re, io, sys

REPO = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
GAME = os.path.join(REPO, "game", "isla-ancestral")
SRC = os.path.join(GAME, "scripts")
DATA = os.path.join(GAME, "data")
SCENES = os.path.join(GAME, "scenes")

EXTS = (".gd", ".tscn", ".tres", ".json", ".md", ".cfg", ".csv", ".ini", ".shader")

def iter_files(roots, exts=EXTS):
    seen = set()
    for root in roots:
        if not os.path.exists(root):
            continue
        if os.path.isfile(root):
            yield root
            continue
        for dp, dns, fns in os.walk(root):
            dns[:] = [d for d in dns if d not in (".godot", "imported", "exported", "node_modules")]
            for fn in fns:
                if fn.lower().endswith(exts):
                    p = os.path.join(dp, fn)
                    if p not in seen:
                        seen.add(p)
                        yield p

def rel(p):
    return os.path.relpath(p, GAME).replace("\\", "/")

def grep(patterns, roots, exts=EXTS, limit=8, flags=re.I):
    rx = re.compile("|".join("(?:%s)" % p for p in patterns), flags)
    files = 0
    hits = 0
    samples = []
    for p in iter_files(roots, exts):
        try:
            txt = io.open(p, encoding="utf-8", errors="replace").read()
        except Exception:
            continue
        n = 0
        first = None
        for i, line in enumerate(txt.splitlines(), 1):
            m = rx.search(line)
            if m:
                n += 1
                if first is None:
                    first = (i, line.strip()[:160])
        if n:
            files += 1
            hits += n
            if len(samples) < limit:
                samples.append("%s:%d %s" % (rel(p), first[0], first[1]))
    return files, hits, samples

def exists(paths):
    out = []
    for p in paths:
        full = p if os.path.isabs(p) else os.path.join(GAME, p)
        out.append("%s=%s" % (p, "SI" if os.path.exists(full) else "NO"))
    return " ".join(out)

def show(title, files, hits, samples):
    print("%s | files=%d hits=%d" % (title, files, hits))
    for s in samples:
        print("   %s" % s)

print("== A. M01 derivados: artefacto de implementacion en scripts/ ==")
# T62-01 M12 Herramientas
show("T62-01 M12 herramientas158/tools",
     *grep([r"herramienta", r"tool_tier", r"jar_manager"],
           [os.path.join(SRC, "herramientas158"), os.path.join(SRC, "tools")]))
print("   " + exists(["scripts/herramientas158/tool_tier_system.gd", "scripts/tools/tool_controller.gd"]))
# T62-02 M16 Construccion
show("T62-02 M16 construccion",
     *grep([r"build_manager", r"mode_construccion|modo_construccion", r"class_name\s+BuildManager"],
           [os.path.join(SRC, "construccion")]))
print("   " + exists(["scripts/construccion/build_manager.gd", "scripts/construccion/construccion_mundo.gd"]))
# T62-03 M36 Museos
show("T62-03 M36 museum",
     *grep([r"class_name\s+Museum", r"donation_service", r"collection_registry"],
           [os.path.join(SRC, "museum"), os.path.join(SCENES, "museo")]))
print("   " + exists(["scripts/museum/museum.gd", "scenes/museo/museum.tscn"]))
# T62-04 M39 Infraestructura (fuentes reales, sin .godot)
show("T62-04 M39 infraestructura (source)",
     *grep([r"infraestructura", r"muelle", r"faro(_|\b|il|ola)", r"plaza", r"puente"],
           [os.path.join(SRC, "islas"), os.path.join(SRC, "world"), os.path.join(SRC, "eventos"), DATA, SCENES],
           exts=(".gd", ".json", ".tscn", ".tres")))
# T62-05 M44 Arte-3D
show("T62-05 M44 arte3d/validadores",
     *grep([r"material", r"mesh", r"validator|validador"],
           [os.path.join(SRC, "arte3d"), os.path.join(SRC, "validadores")]))
print("   " + exists(["scripts/arte3d/materiales_recursos.gd", "scripts/validadores/validador_autoloads.gd",
                      "scripts/arte3d/validate_mesh.gd", "assets/arte3d/asset_catalog.json"]))
show("T62-05b validate_mesh.gd/asset_catalog.json en todo el repo",
     *grep([r"validate_mesh\.gd", r"asset_catalog\.json"], [GAME]))
# T62-06 M50 Agua
show("T62-06 M50 agua runtime",
     *grep([r"agua_animada", r"ocean|oc[eé]ano|water|oleaje|corriente"],
           [os.path.join(SRC, "world"), os.path.join(SRC, "shaders"), os.path.join(SRC, "terrenos"),
            os.path.join(SCENES)]))
print("   " + exists(["scripts/world/agua_animada.gd"]))
# T62-07 M58 Guardado
show("T62-07 M58 saving",
     *grep([r"SaveManager", r"save_manager", r"autosave"],
           [os.path.join(SRC, "saving")]))
print("   " + exists(["scripts/saving/save_manager.gd", "scripts/saving/save_backup.gd"]))
# T62-08 M66 Vehiculos
show("T62-08 M66 vehiculos",
     *grep([r"VehicleManager|vehicle_manager", r"VehicleController|vehicle_controller", r"vehicle_preset"],
           [os.path.join(SRC, "vehiculos")]))
print("   " + exists(["scripts/vehiculos/vehicle_manager.gd", "scripts/vehiculos/vehicle_controller.gd"]))
# T62-09 M68 Fast Travel
show("T62-09 M68 fasttravel",
     *grep([r"FastTravelService|fast_travel_service", r"teletransport", r"punto_de_viaje|travel_point"],
           [os.path.join(SRC, "fasttravel")]))
print("   " + exists(["scripts/fasttravel/fast_travel_service.gd", "scripts/fasttravel/fast_travel_effect.gd"]))
# T62-10 M108 Herramientas Internas
show("T62-10 M108 tools/editor",
     *grep([r"recipe_tool|dialogos_auditor|plugin_herramientas|editor_base"],
           [os.path.join(SRC, "tools"), os.path.join(SRC, "editor")]))
print("   " + exists(["scripts/editor/tools/recipe_tool.gd", "scripts/editor/tools/dialogos_auditor.gd",
                      "scripts/tools/tool_controller.gd", "scenes/dialogo_ui.tscn"]))

print("\n== B. M20 Amistad: artefacto concreto por linea citada ==")
# T62-11 L30 nombres de nivel
show("T62-11 L30 nombres de nivel",
     *grep([r"Conocido", r"Confidente", r"Mejor\s+amigo", r"nombre.*nivel|nivel.*nombre|level_name"],
           [SRC, DATA]))
# T62-12 L32 acceso eventos por nivel minimo
show("T62-12 L32 acceso eventos por nivel minimo",
     *grep([r"nivel[_ ]m[ií]nimo", r"min_level", r"requiere_nivel", r"nivel_requerido"],
           [os.path.join(SRC, "friendship"), os.path.join(SRC, "eventos"), DATA]))
# T62-13 L33 desbloqueo historias por nivel
show("T62-13 L33 desbloqueo historias por nivel",
     *grep([r"desbloquear.*historia|historia.*desbloque", r"nivel.*historia|historia.*nivel",
            r"friendship.*quest|quest.*friendship"],
           [os.path.join(SRC, "friendship"), os.path.join(SRC, "historias"), DATA]))
# T62-14 L38 feedback nivel subido
show("T62-14 L38 feedback nivel subido",
     *grep([r"nivel[_ ]subido|subi[oó]?\s+de\s+nivel|level_up|levelup", r"animaci[oó]n.*nivel|desbloqueos"],
           [os.path.join(SRC, "friendship"), os.path.join(SRC, "ui"), os.path.join(SCENES)]))
# T62-15 L191/L192/L193
show("T62-15a L192 recuerdos hablados (get_recuerdos en dialogos)",
     *grep([r"get_recuerdos", r"recuerdos"], [os.path.join(SRC, "dialogos")]))
show("T62-15b L191 frases de despedida por nivel",
     *grep([r"despedida|hasta\s+ma[nñ]ana|farewell|goodbye"], [SRC, DATA]))
show("T62-15c L193 regalos de retorno por correo",
     *grep([r"regalo.*retorno|retorno.*regalo|buzon.*regalo|regalo.*buzon|thank.?you.?gift"],
           [os.path.join(SRC, "friendship"), os.path.join(SRC, "eventos"), DATA]))
