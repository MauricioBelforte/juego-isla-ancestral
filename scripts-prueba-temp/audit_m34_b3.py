# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/34-Pesca/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 21: "AUDIT 2026-10-13 (step-5-kilocode): id_receta se carga de datos (fishing_manager.gd L148) como contrato; las recetas que consumen peces son de M15, no de M34.",
 22: "AUDIT 2026-10-13 (step-5-kilocode): la cana/cebos existen como datos (fishing_manager.gd _cargar_canas_de) pero el equipamiento desde hotbar M14/M13 no esta cableado.",
 23: "AUDIT 2026-10-13 (step-5-kilocode): M34 aporta catalogo y entrega_museo() (fishing_manager.gd); la recompensa por completar seccion es diseno de M37.",
 24: "AUDIT 2026-10-13 (step-5-kilocode): contrato completo — ventana_activa(inicio_ventana, duracion) se emite en fishing_session.gd L59; no hay FishingHud (M53).",
 25: "AUDIT 2026-10-13 (step-5-kilocode): picada_iniciada se emite (fishing_manager.gd L206) y existe el estado PICADA (enum L13); el indicador visual/sonoro es de M53/M42.",
 26: "AUDIT 2026-10-13 (step-5-kilocode): mismo contrato ventana_activa (L59); el anillo/barra suave es de M53.",
 27: "AUDIT 2026-10-13 (step-5-kilocode): pulsaciones_minijuego(restantes) se emite en L70/L74 de fishing_session.gd; el tick visual/sonoro es de M53/M42.",
 28: "AUDIT 2026-10-13 (step-5-kilocode): captura_fallida('el_pez_se_fue') se emite con motivo no punitivo por diseno (fishing_manager.gd L227); la vista es de M53.",
 29: "AUDIT 2026-10-13 (step-5-kilocode): captura_exitosa(pez, tamano) lleva el payload completo (FishDefinition + tamano); el zoom de camara es de M53.",
 30: "AUDIT 2026-10-13 (step-5-kilocode): registrar_captura() existe y el dato vez==1 seria detectable, pero 0 hits de NotificationService/notificar_nueva_especie: el consumo es de M53.",
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
print("anotados (M34 b3):", checked)
