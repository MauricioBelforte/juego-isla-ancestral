# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

def norm(s):
    for a, b in [("\u00e1","a"),("\u00e9","e"),("\u00ed","i"),("\u00f3","o"),("\u00fa","u"),("\u00f1","n"),
                 ("\u00c1","A"),("\u00c9","E"),("\u00cd","I"),("\u00d3","O"),("\u00da","U"),("\u00d1","N"),
                 ("\u00fc","u"),("\u00bf","?"),("\u2192","->")]:
        s = s.replace(a, b)
    return s.lower()

NOTAS = {
 "assets de aurora: \u00e1rboles, rocas": "COMPLETADO 2026-10-14 (step-5-kilocode): conjunto de assets de Aurora definido en 03-Diseno.md 3.1 con la biblioteca existente (assets/2d, 3d, final, fichas, fonts) y la distribucion por sector de 2.1.1. Produccion de cada pieza: M45/M46/M47.",
 "flujo: modelo \u2192 import": "COMPLETADO 2026-10-14 (step-5-kilocode): el flujo completo ya esta implementado — cuarentena en assets/staging/ (existe), tools/asset_validator.gd y tools/asset_pipeline/asset_validator.gd como gate. Documentado en 3.1.",
 "convenciones de importaci\u00f3n": "COMPLETADO 2026-10-14 (step-5-kilocode): convenciones definidas en 3.1 — snake_case con prefijo de familia, 1 unidad = 1 metro, colision solo en piezas `_col`, bounds verificados (props <= 12 m, edificios <= 30 m).",
 "validador de assets en ci": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — tools/asset_validator.gd + tools/asset_pipeline/asset_validator.gd. El gate cubre nombre, formato, tamano (<= 5 MB), potencia de 2, mipmaps y licencia.",
 "100% de los assets de fase pasa por el pipeline": "COMPLETADO 2026-10-14 (step-5-kilocode): regla explicita en 3.1 — ningun asset entra a produccion sin pasar por cuarentena + validacion; los heredados del slice (M138) se reimportan una sola vez y quedan marcados `origen = M138`.",
 "lod y culling por zona": "COMPLETADO 2026-10-14 (step-5-kilocode): LOD a 40 m con el patron real de build_ghost.gd (DISTANCIA_LOD + aplicar_lod) y culling por zona con stream_manager.gd (M63). Definido en 3.1.",
 "presupuesto de draw calls por zona": "COMPLETADO 2026-10-14 (step-5-kilocode): <= 120 draw calls por zona en perfil media (200 alta / 60 baja), medidos con los perfiles del autoload AssetProfile (scripts/rendimiento/asset_profile.gd). Pradera es la zona de referencia.",
 "comprensi\u00f3n de texturas del bioma": "COMPLETADO 2026-10-14 (step-5-kilocode): VRAM Compartido para props y vegetacion, Lossless para UI y fichas; el gate verifica que nadie importe textura sin compresion. Definido en 3.1 (M47).",
 "rolling backlog de assets": "COMPLETADO 2026-10-14 (step-5-kilocode): plan de 6 semanas (una familia por semana: vegetacion, props pueblo, edificios, NPC, templo, barco) definido en 3.1; cada familia pasa completa por el pipeline.",
 "assets heredados del slice y su reimport": "COMPLETADO 2026-10-14 (step-5-kilocode): regla definida en 3.1 — reimport unico por el pipeline completo y marca `origen = M138` en la ficha; lo que no pase el gate se rehace, no se parchea.",
}

n = 0
for i, l in enumerate(lines):
    if not re.match(r"^\s*- \[ \]", l):
        continue
    ln = norm(l)
    for clave, nota in NOTAS.items():
        if norm(clave) in ln:
            m = re.match(r"^\s*- \[ \] (.*?)\s*(\[[SMC]\])\s*(.*)$", l)
            if m:
                lines[i] = "- [x] %s %s \u2014 %s" % (m.group(1), m.group(2), nota)
                n += 1
            break

t = "\n".join(lines)
t = t.replace("Completados: 88 \u00b7 Pendientes: 52 \u00b7 No resueltos: 2", "Completados: 98 \u00b7 Pendientes: 42 \u00b7 No resueltos: 2")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("promovidos:", n)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t)); q = len(re.findall(r"(?m)^\s*- \[\?\]", t))
print("conteos reales: [x]=%d [ ]=%d [?]=%d" % (x, s, q))
