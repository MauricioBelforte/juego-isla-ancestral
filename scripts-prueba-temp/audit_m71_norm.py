# -*- coding: utf-8 -*-
import io, re
p = "DOCUMENTACION/71-Progresion/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

def norm(s):
    for a, b in [("\u00e1","a"),("\u00e9","e"),("\u00ed","i"),("\u00f3","o"),("\u00fa","u"),("\u00f1","n"),
                 ("\u00cd","i"),("\u00d3","o"),("\u00da","u"),("\u00d1","n"),("\u00c1","a")]:
        s = s.replace(a, b)
    return s.lower()

# (clave normalizada, nota)
notas = [
 ("permitir desbloqueos cuya condicion referencia",
  "AUDIT 2026-10-14 (step-5-kilocode): _evaluar_nivel_modulo_puro (L351) + obtener_nivel_herramienta (L360): el patron nivel->desbloqueo esta implementado y es evaluable desde el catalogo."),
 ("garantizar que ningun logro sea imposible",
  "AUDIT 2026-10-14 (step-5-kilocode): detectar_condiciones_imposibles_estaticas (L388) + _es_condicion_imposible (L396) en codigo; la cobertura postgame (M75) no esta verificada. Parcial."),
 ("definir estadisticas minimas iniciales",
  "AUDIT 2026-10-14 (step-5-kilocode): _stat (L241) + progreso_resumen_cargado (L23) registran stats; la lista canonica del item no se verifico como conjunto explicito en datos."),
 ("analizar dominio de reputacion",
  "AUDIT 2026-10-14 (step-5-kilocode): amistad 0-4 con reflejo (integrar_amistad + test L267); reputacion comunitaria derivada sin implementar. Parcial."),
 ("analizar dominio de economia",
  "AUDIT 2026-10-14 (step-5-kilocode): dominio economia con 5 hitos + _on_transaccion_registrada (L226); M38 como facilitador confirmado por diseno."),
 ("definir curva tardia",
  "AUDIT 2026-10-14 (step-5-kilocode): curva tardia no definida; los 3 hitos de dominio 'historia' dependen de M22."),
 ("diagramar flujo de condicion imposible",
  "AUDIT 2026-10-14 (step-5-kilocode): deteccion estatica implementada (_es_condicion_imposible L396); el diagrama de cooperacion con M66 no existe como documento."),
 ("consumir la senal de cambio de nivel de casa",
  "AUDIT 2026-10-14 (step-5-kilocode): house_nivel se lee por player_profile (valor 3 en test L316) pero la senal de M18 no esta conectada por nombre en M71."),
 ("actualizar estadisticas de amistad",
  "AUDIT 2026-10-14 (step-5-kilocode): integrar_amistad cubre el reflejo por NPC (dominio amistad, 6 hitos); la stat 'amigos en nivel N' no esta verificada."),
 ("permitir desbloqueos de contenido tardio",
  "AUDIT 2026-10-14 (step-5-kilocode): sin desbloqueos por sello en hitos.json; la deteccion de condiciones imposibles (M66) si existe."),
 ("condicion actualmente no cumplible",
  "AUDIT 2026-10-14 (step-5-kilocode): reportada a M66 por diseno (comentario del item); la deteccion estatica existe (L388) pero la ruta alternativa no."),
 ("muchos hitos simultaneos al despertar",
  "AUDIT 2026-10-14 (step-5-kilocode): signals de hito existen (L20) sin cola priorizada de notificaciones en M53."),
 ("crear 02-analisis.md con dominio",
  "AUDIT 2026-10-14 (step-5-kilocode): 02-Analisis.md plan-actual verificado por Log 623 (dominio, curvas, anti-frustracion, alternativas D1-D10). Respaldo confirmado."),
 ("crear 05-checklist.md con mas de 130",
  "AUDIT 2026-10-14 (step-5-kilocode): el checklist existe con 213 items (>130) pero 45 quedan [?]; el item pide 'todos completados'. Parcial."),
 ("definir prueba de condicion imposible",
  "AUDIT 2026-10-14 (step-5-kilocode): detectar_condiciones_imposibles_estaticas (L388) cubre la deteccion; la prueba dedicada con ruta alternativa en runtime no se verifico."),
]

n = 0
for i, l in enumerate(lines):
    if not re.match(r"^\s*- \[\?\]", l):
        continue
    if "AUDIT 2026-10-14" in l or "DEGRADADO 2026-10-12" in l:
        continue
    ln = norm(l)
    for clave, nota in notas:
        if clave in ln:
            lines[i] = l.rstrip() + " | " + nota
            n += 1
            break

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))
print("anotados:", n)
