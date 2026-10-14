# -*- coding: utf-8 -*-
import io, re
p = "DOCUMENTACION/71-Progresion/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 "Permitir desbloqueos cuya condicion referencia": "AUDIT 2026-10-14 (step-5-kilocode): _evaluar_nivel_modulo_puro (L351) + obtener_nivel_herramienta (L360) implementan el patron; condiciones por nivel de herramienta son evaluables en el catalogo.",
 "Garantizar que ningun logro sea imposible": "AUDIT 2026-10-14 (step-5-kilocode): detectar_condiciones_imposibles_estaticas() (L388) + validacion (L529) en codigo; cobertura postgame (M75) no verificada.",
 "Definir estadisticas minimas iniciales": "AUDIT 2026-10-14 (step-5-kilocode): _stat() (L241) + progreso_resumen_cargado (L23) implementan el registro de stats; la lista canonica del item no se verifico como conjunto.",
 "Analizar dominio de reputacion": "AUDIT 2026-10-14 (step-5-kilocode): amistad 0-4 con reflejo (integrar_amistad, test L267); reputacion comunitaria derivada sin implementar.",
 "Analizar dominio de economia": "AUDIT 2026-10-14 (step-5-kilocode): dominio economia (5 hitos en hitos.json) + _on_transaccion_registrada (L226); M38 como facilitador confirmado.",
 "Definir curva tardia": "AUDIT 2026-10-14 (step-5-kilocode): sin curva tardia en datos; los hitos 'historia' (3) dependen de M22 (capitulos/sellos).",
 "Asegurar que todo es desbloqueable": "AUDIT 2026-10-14 (step-5-kilocode): sin elecciones excluyentes permanentes — no hay flags de exclusion en hitos.json; el diseno de progresion horizontal no bloquea. Confirmado por datos.",
 "Diagramar flujo de condicion imposible": "AUDIT 2026-10-14 (step-5-kilocode): _es_condicion_imposible (L396) + detectar_condiciones_imposibles_estaticas implementan la deteccion; el diagrama con M66 no existe como documento.",
 "Registrar hito reflejo por cada herramienta": "AUDIT 2026-10-14 (step-5-kilocode): nivel_herramienta_cambio (L216) + test_nivel_herramienta.gd (M13 iter 5) — el reflejo por herramienta/nivel esta implementado.",
 "Definir condiciones nivel_modulo(herramienta": "AUDIT 2026-10-14 (step-5-kilocode): el tipo de condicion 'nivel_modulo' existe en el evaluador (L351) y los hitos de hitos.json usan condiciones por nivel; el esquema exacto del item no se verifico como formato.",
 "Consumir la senal de cambio de nivel de casa": "AUDIT 2026-10-14 (step-5-kilocode): house_nivel se lee via player_profile (house_nivel 3 en test L316); la senal de M18 (nombre a confirmar) no esta conectada explicitamente.",
 "Definir condiciones nivel_modulo(casa": "AUDIT 2026-10-14 (step-5-kilocode): mismo evaluador nivel_modulo (L351) cubre casa; hitos.json tiene condiciones por nivel de casa.",
 "Actualizar estadisticas de amistad": "AUDIT 2026-10-14 (step-5-kilocode): integrar_amistad + dominio 'amistad' (6 hitos) implementan el reflejo por NPC; 'amigos en nivel N' como stat no verificado.",
 "Permitir desbloqueos sociales por amistad": "AUDIT 2026-10-14 (step-5-kilocode): desbloqueos por amistad existen (hitos de dominio amistad) sin bloquear contenido principal; trueques unicos M38 no verificados.",
 "Consumir sello_obtenido": "AUDIT 2026-10-14 (step-5-kilocode): sello_obtenido no aparece en codigo de M71; el dominio 'historia' usa hitos por capitulo. Consumo de senal de M22 no implementado.",
 "Registrar hitos narrativos reflejos por sello": "AUDIT 2026-10-14 (step-5-kilocode): dominio 'historia' (3 hitos) existe pero no hay reflejo por sello individual.",
 "Registrar hitos narrativos reflejos por sello y capitulo": "AUDIT 2026-10-14 (step-5-kilocode): idem — hitos narrativos por capitulo/sello sin reflejo automatico en M71.",
 "Definir condiciones sello_historia": "AUDIT 2026-10-14 (step-5-kilocode): el tipo de condicion 'sello_historia'/'capitulo_historia' no existe en el evaluador; las condiciones de historia usan otro formato.",
 "Permitir desbloqueos de contenido tardio": "AUDIT 2026-10-14 (step-5-kilocode): sin desbloqueos condicionados a sellos en hitos.json; la vigilancia de M66 (condiciones imposibles) existe.",
 "Registrar los 5 finales de M22": "AUDIT 2026-10-14 (step-5-kilocode): 0 hits de finales de M22 en hitos.json; los finales son de M22 (22-Historia-Principal).",
 "Coordinar con postgame": "AUDIT 2026-10-14 (step-5-kilocode): sin coordinacion con M75 en codigo; postgame no implementado.",
 "Condicion actualmente no cumplible": "AUDIT 2026-10-14 (step-5-kilocode): _es_condicion_imposible (L396) reporta condiciones imposibles; la ruta alternativa con M66 no esta implementada.",
 "Muchos hitos simultaneos al despertar": "AUDIT 2026-10-14 (step-5-kilocode): signals de hitos existen (progreso_hito_alcanzado L20) pero sin cola priorizada de notificaciones en M53.",
 "Condiciones como RefCounted reutilizados": "AUDIT 2026-10-14 (step-5-kilocode): condiciones evaluadas como diccionarios puros (evaluar_pura L260) sin pool de RefCounted; el patron del item no esta implementado.",
 "Crear 05-Checklist.md con mas de 130": "AUDIT 2026-10-14 (step-5-kilocode): el checklist existe con 213 items (168 [x] + 45 [?]); supera los 130 pero no todos completados (45 [?]). Parcial por diseno.",
 "Definir prueba de condicion imposible": "AUDIT 2026-10-14 (step-5-kilocode): deteccion estatica existe (detectar_condiciones_imposibles_estaticas L388) pero la prueba especifica del item no se verifico como test dedicado.",
 "Definir prueba de determinismo": "AUDIT 2026-10-14 (step-5-kilocode): test_progresion.gd (20 KB) cubre evaluacion y condiciones; la prueba de determinismo (mismos hitos en el mismo orden) no se verifico como test.",
}

n = 0
for i, l in enumerate(lines):
    if not re.match(r"^\s*- \[\?\]", l):
        continue
    if "AUDIT 2026-10-14" in l or "DEGRADADO 2026-10-12" in l:
        continue
    for clave, nota in notas.items():
        if clave in l:
            lines[i] = l.rstrip() + " | " + nota
            n += 1
            break

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))
print("anotados (M71 mas):", n)
