# -*- coding: utf-8 -*-
import io, re
p = "DOCUMENTACION/71-Progresion/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 "Permitir desbloqueos cuya condicion": "AUDIT 2026-10-14 (step-5-kilocode): evaluar_nivel_modulo_puro (L351) evalua condiciones por nivel de modulo (herramienta/casa) con dirty-flagging; el ejemplo picota nivel 3 -> cueva profunda es instancia de ese patron evaluable.",
 "Garantizar que ningun logro sea imposible": "AUDIT 2026-10-14 (step-5-kilocode): detectar_condiciones_imposibles_estaticas() (L388) + validacion de catalogo (L529) implementan la deteccion estatica; el caso postgame (M75) no esta cubierto. Parcial.",
 "Definir estadisticas minimas iniciales": "AUDIT 2026-10-14 (step-5-kilocode): _stat(oper, stat_id, cantidad) (L241) con resumen (progreso_resumen_cargado L23) implementa el registro; la lista canonica del item no se verifico como conjunto en un archivo.",
 "Analizar dominio de reputacion": "AUDIT 2026-10-14 (step-5-kilocode): amistad 0-4 con reflejo confirmado (integrar_amistad + test L267); reputacion comunitaria derivada sin implementar.",
 "Analizar dominio de colecciones": "AUDIT 2026-10-14 (step-5-kilocode): dominio 'colecciones' existe en hitos.json (1 hito) y M37 museo/museos NO existe en disco (verificado: scripts/museos inexistente). Coleccion horizontal parcial.",
 "Analizar dominio de hitos narrativos": "AUDIT 2026-10-14 (step-5-kilocode): dominio 'historia' existe en hitos.json (3 hitos) y los 7 capitulos/sellos de M22 estan en 22-Historia-Principal. Esqueleto respaldado.",
 "Analizar dominio de economia": "AUDIT 2026-10-14 (step-5-kilocode): dominio 'economia' existe en hitos.json (5 hitos) y _on_transaccion_registrada (L226) refleja M38; M38 como facilitador confirmado por diseno.",
 "Definir curva temprana": "AUDIT 2026-10-14 (step-5-kilocode): no hay curva de desbloqueos temprana parametrizada; los 10 hitos 'generales' de hitos.json no tienen frecuencia definida. Analisis pendiente.",
 "Definir curva media": "AUDIT 2026-10-14 (step-5-kilocode): idem — sin curva media definida en datos ni codigo.",
 "Definir curva tardia": "AUDIT 2026-10-14 (step-5-kilocode): idem — sin curva tardia; los hitos de 'historia' (3) dependen de M22.",
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
print("anotados (M71 b2):", n)
