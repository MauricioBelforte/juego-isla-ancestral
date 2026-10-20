# -*- coding: utf-8 -*-
# Verificación de proveedores de guardado (M90/M91/M58/M87) — item 44 de la cola M59
import io, re, glob, os

BASE = r"game\isla-ancestral\scripts"
CANDIDATOS = {
    "M90 grafica": glob.glob(BASE + r"\**\graphics_config.gd", recursive=True),
    "M91 audio": [r"game\isla-ancestral\scripts\audio\audio_config_service.gd"],
    "M58 accesibilidad": [r"game\isla-ancestral\scripts\accesibilidad\accesibilidad_manager.gd"],
    "M87 idioma": glob.glob(BASE + r"\localization\*.gd", recursive=True),
}

for k, rutas in CANDIDATOS.items():
    out = []
    for r in rutas:
        if not os.path.exists(r):
            continue
        s = io.open(r, encoding="utf-8").read()
        reg = "register_provider" in s
        sec = re.search(r"func get_section_name\(\)[^\n]*\n\s*return \"([^\"]+)\"", s)
        out.append("%s [reg=%s, sección=%s]" % (os.path.basename(r), reg, sec.group(1) if sec else "-"))
    print(k, "->", " | ".join(out) if out else "SIN ARCHIVO")
