# -*- coding: utf-8 -*-
import io, re
p = "DOCUMENTACION/71-Progresion/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 "RF8: registro base de logros": "AUDIT 2026-10-14 (step-5-kilocode): PARCIAL — progression_manager.gd (autoload, 36 KB) implementa hitos/desbloqueos/titulos con condiciones evaluadas en puro y dirty-flagging O(1) (§7), pero el REGISTRO DE LOGROS con progreso parcial y la presentacion en M72 no estan: progress partial no existe en el codigo. La base de hitos si.",
 "Definir MilestoneDefinition": "AUDIT 2026-10-14 (step-5-kilocode): no existe una clase MilestoneDefinition; los hitos se modelan como diccionarios dentro de hitos.json (id/nombre/condicion/recompensas/dominio), sin nombre_i18n ni descripcion_i18n como campos dedicados. Parcial por datos, ausente como clase.",
 "Crear milestone_catalog": "AUDIT 2026-10-14 (step-5-kilocode): NO existe milestone_catalog.tres; el catalogo real es data/progresion/hitos.json (8875 B, 25 hitos) cargado por progression_manager.gd L89 via FileAccess. El item pide .tres, la evidencia es .json.",
 "Implementar get_milestone": "AUDIT 2026-10-14 (step-5-kilocode): 0 hits de get_milestone/get_unlock/get_logro/get_titulo en scripts/progresion/; el acceso es por _hitost[index] interno y signals (progreso_titulo_obtenido L27). No hay API getter publica.",
 "Registrar hitos reflejo de niveles de herramientas": "AUDIT 2026-10-14 (step-5-kilocode): el reflejo M13 existe y esta cableado — conectar_tool_controller (L193), nivel_herramienta_cambio (L216) y evaluar_nivel_modulo_puro (L351) con obtener_nivel_herramienta (L360). Los hitos que usan esa condicion se evaluan.",
 "Registrar hitos reflejo de niveles de casa": "AUDIT 2026-10-14 (step-5-kilocode): house_nivel via player_profile.gd (3831 B) y progresion como autoload; house_nivel nivel 3 existe (test_progresion.gd L316). El reflejo de casa esta implementado.",
 "Respetar que la fuente de verdad": "AUDIT 2026-10-14 (step-5-kilocode): confirmado por diseno — progression_manager.gd L15 documenta duck-typing con M13 (tool_controller) y M18 (casa) como fuentes; M71 solo lee niveles, no los escribe.",
 "Permitir desbloqueos cuya condicion": "AUDIT 2026-10-14 (step-5-kilocode): evaluar_condicion_id (L380) evalua por id con cache; _indexar_condicion (L109) indexa por estadistica raiz. La condicion 'nivel de herramienta' existe como tipo evaluable (L351).",
 "Definir AchievementDefinition": "AUDIT 2026-10-14 (step-5-kilocode): no existe clase AchievementDefinition ni logro_id; los logros no estan modelados como entidad en M71 (solo hitos). Dueno M72.",
}

n = 0
for i, l in enumerate(lines):
    if not re.match(r"^\s*- \[\?\]", l):
        continue
    if "AUDIT 2026-10-14" in l:
        continue
    for clave, nota in notas.items():
        if clave in l:
            lines[i] = l.rstrip() + " | " + nota
            n += 1
            break

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))
print("anotados (M71 b1):", n)
