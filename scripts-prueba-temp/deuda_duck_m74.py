# -*- coding: utf-8 -*-
import io

p = "DOCUMENTACION/74-Eventos/plan-actual/04-Codigo.md"
with io.open(p, "r", encoding="utf-8") as f:
    lines = f.read().split("\n")

ancla_idx = None
for i, l in enumerate(lines):
    if "Integraci\u00f3n rutinas NPC" in l:
        ancla_idx = i
        break

if ancla_idx is None:
    print("AVISO: ancla no encontrada")
else:
    nueva = (
      "| **DUCK-TYPING ROTO (deuda de los due\u00f1os): recompensas AMISTAD / PROGRESO / COLECCI\u00d3N sin destino en producci\u00f3n** | "
      "`recompensa_def.gd` llama por duck-typing a `/root` y los 3 m\u00e9todos **no existen en producci\u00f3n** "
      "(s\u00f3lo est\u00e1n en `test_event_manager_verificacion.gd`): M20 debe exponer "
      "`sumar_puntos(id_npc, bonus)` \u00b7 M71 debe exponer `registrar_progreso_evento(id, cantidad)` \u00b7 "
      "M37 debe exponer `registrar_recuerdo(datos)` en `/root/Museo`. Efecto hoy: la recompensa de amistad "
      "**no se entrega** (cae al `push_warning` y devuelve false) y las de progreso/colecci\u00f3n quedan como "
      "hook dormido. **Due\u00f1os: M20 (amistad), M71 (progresi\u00f3n), M37 (museo/colecci\u00f3n).** Verificado "
      "2026-10-13 por step-5-kilocode contra disco (Log 1821). Alternativa para M20: consumir su API real "
      "`get_puntos()`/`aplicar_puntos()` v\u00eda `VecinoAmistad`; el c\u00f3digo de entrega de M74 queda como est\u00e1. |")
    lines.insert(ancla_idx + 1, nueva)
    with io.open(p, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(lines))
    print("Deuda insertada despues de la linea", ancla_idx + 1)
