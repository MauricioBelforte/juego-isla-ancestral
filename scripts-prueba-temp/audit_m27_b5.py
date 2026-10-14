# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/27-Islas-Del-Mundo/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 41: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de falloff de biomas dentro de isla en islas/ ni world/.",
 42: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de recetas de formaciones (playas/acantilados) de M09.",
 43: "AUDIT 2026-10-13 (step-5-kilocode): clima_tendencia es solo dato de definicion (generar_islas.gd L124, island_definition.gd L53); 0 consumidores en M32.",
 44: "AUDIT 2026-10-13 (step-5-kilocode): el campo musica existe por isla (generar_islas.gd L154+ 'mus_aurora' etc.) pero no hay consumo al desembarcar en los scripts de audio/M41.",
 45: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de spawn de fauna/vegetacion condicionado al bioma.",
 46: "AUDIT 2026-10-13 (step-5-kilocode): Aurora siempre carga por fallback de archipielago.gd y hay bounds para streaming (island_definition.gd L99) pero no hay evidencia de streaming fino de chunks lejanos para Aurora.",
 47: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de precalentamiento/cacheo de Aurora en el menu (M63).",
 48: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de telemetria de carga por isla (tiempos/memoria/errores) ligada a M105.",
 49: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de profiling de carga contra frame budget de M61.",
 50: "AUDIT 2026-10-13 (step-5-kilocode): descubrir() existe y devuelve true solo la primera vez 'para el toast de M54' (island_registry.gd L359), con tests (test_islas_m27.gd L382+), pero 0 consumidores en produccion: el toast no esta cableado.",
}

idx = 0
checked = 0
for i, l in enumerate(lines):
    if re.match(r"^\s*- \[\?\]", l):
        n = idx + 1
        if n in notas and "AUDIT 2026-10-13" not in l:
            lines[i] = l.rstrip() + " | " + notas[n]
            checked += 1
        idx += 1

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))
print("anotados (b5):", checked)
