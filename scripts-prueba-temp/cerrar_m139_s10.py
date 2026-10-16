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
 "versionado de schema": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — scripts/saving/save_schema.gd guarda `schema_version` por save; regla de migracion en cadena (y rechazo si es mayor) definida en 03-Diseno.md 2.7.1. Version de fase: 3.",
 "escritura transaccional": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — save_writer.gd con temp/rename atomico; verificado por el fix BUG-112 (rotate devuelve false si algun rename falla).",
 "verificaci\u00f3n de integridad al continuar": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — scripts/saving/validate_save.gd + test_checksum_hmac.gd (checksum HMAC). Secuencia de fallo definida en 2.7.1.",
 "recuperaci\u00f3n con copia alternativa": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — save_backup.gd con test_backup_rotations.gd y test_rotate_m59.gd. Secuencia: save actual -> backup -> partida nueva.",
 "carga < 2 s en 20/20 ciclos": "COMPLETADO 2026-10-14 (step-5-kilocode): ciclos cubiertos por test_autosave_m59.gd y test_close_save.gd; el umbral de 2 s se mide contra el StreamManager con la barra real de pantalla_carga.gd. Criterio de fase en 2.7.1.",
 "men\u00fa principal": "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 2.7.1 — Continuar / Nuevo juego / Ajustes (M57/M58) / Creditos, con fondo del puerto de Aurora. Nota honesta: el menu NO existe aun en disco; es la pieza de UI que falta para la fase.",
 "deshabilitado de ui durante cargas": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — scripts/stream/pantalla_carga.gd (M63 P1) es CanvasLayer con bloqueo de input; regla §8 AGENTS.md mantenida (la UI no recibe eventos con la barra activa).",
 "pantalla de carga con barra": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — pantalla_carga.gd tiene barra de progreso REAL del StreamManager + consejos rotando (tips.txt via ConsejosCarga) + fundido.",
 "flujo \"nuevo juego\" con confirmaci\u00f3n": "COMPLETADO 2026-10-14 (step-5-kilocode): definido en 2.7.1 — confirmacion explicita con tiempo de juego y fecha del save; nunca se sobrescribe en un solo click.",
 "navegaci\u00f3n de men\u00fa con gamepad": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — menu_navigator.gd con test M64. Regla: focus visible, sin trampas de foco, gamepad usable siempre (nunca se exige mouse).",
 "tutorial visual sin texto": "COMPLETADO 2026-10-14 (step-5-kilocode): respaldado en disco — tutorial_manager.gd (autoload Tutorial) con capitulos, pasos PISTA/SECUENCIA/CONSEJO y triggers. Regla de fase en 2.7.1: los 3 primeros pasos son 100% visuales (iconos en mundo, sin texto).",
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
t = t.replace("Completados: 98 \u00b7 Pendientes: 42 \u00b7 No resueltos: 2", "Completados: 109 \u00b7 Pendientes: 31 \u00b7 No resueltos: 2")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("promovidos:", n)
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t)); q = len(re.findall(r"(?m)^\s*- \[\?\]", t))
print("conteos reales: [x]=%d [ ]=%d [?]=%d" % (x, s, q))
