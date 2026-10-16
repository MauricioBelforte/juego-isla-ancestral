# -*- coding: utf-8 -*-
import io

p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """
### 2.3.2 Horarios, pronombres canonicos y ganchos (cerrado 2026-10-14, step-5-kilocode)

Cierra los items de rutas, horarios, pronombres y ganchos de la seccion 4 del checklist.
Base: elenco de 2.3 (rol y gancho ya definidos) + esta tabla de rangos sin solapamiento.

**Rangos de rutina (hora 0-23, sin solapamiento catastrofico):**

| NPC | 06-12 | 12-18 | 18-22 | 22-06 |
|---|---|---|---|---|
| Finneas | taller | plaza | faro | casa |
| Maribel | **muelle (40% del dia: pesca)** | mercado (60%) | casa | casa |
| Ob\u00e9 | taller | mina | casa | casa |
| T\u00eda R\u00faa | casa | **tienda (08:00-20:00, M39)** | casa | casa |
| Pax | bosque | playa | libre | casa |
| Kor | **acantilado S (bucle fijo)** | acantilado S | acantilado S | casa |
| Cole | casa | **oficina banco 14-16 (2 h)** | casa | casa |
| Bram (Coral) | muelle | taller de vidrio | mirador | casa |

Regla anti-solapamiento: dos NPC con puesto fijo nunca comparten el mismo waypoint en la misma
franja (Kor y Bram son puestos fijos en zonas distintas). Tolerancia de desvio 0.75 m (M66).

**Pronombres y nombres canonicos (M147):**

| NPC | Pronombres | Nota |
|---|---|---|
| Finneas | \u00e9l | vecino principal, heredado del slice M138 |
| Maribel | ella | pescadora |
| Ob\u00e9 | \u00e9l | artesano |
| T\u00eda R\u00faa | ella | tiendera |
| Pax | elle | ni\u00f1e exploradore |
| Kor | \u00e9l | vig\u00eda |
| Cole | elle | banco miniatura |
| Bram | \u00e9l | enano vidriero (Coral) |

Estos son los nombres y pronombres canonicos del elenco Pre-Alpha; M147 (World-Building) es la guia
de referencia y cualquier cambio se hace all\u00e1 primero.

**Ganchos (resumen, ya definidos en 2.3 y 2.3.1):** Maribel = pescado +15% al entardecer \u00b7
Pax = coleccionables escondidos (M73) \u00b7 Kor = misterio del faro (M153) \u00b7 Cole = deposito con
interes 0.5% diario (M38) \u00b7 Ob\u00e9 = desbloquea piezas de construccion (M17) \u00b7
Bram = material del arrecife + pista del 2\u00ba bioma \u00b7 Finneas = cadena intro (M22/M23) \u00b7
T\u00eda R\u00faa = tienda AO (M39).

**Plantillas creadas:** `scripts/world/npc/npc_profile.gd` (Resource con validacion) y
`scripts/world/npc/rutina_ia.gd` (maquina de estados IDLE/CAMINANDO/ESPERANDO/EN_PUESTO/RECUPERANDO
con anti-stuck y teleport al waypoint previo, M66).
"""

ancla = "## 3. Pipeline de assets (M108)"
if ancla in t:
    t = t.replace(ancla, seccion.strip() + "\n\n" + ancla, 1)
    print("seccion 2.3.2 insertada")
else:
    print("AVISO: no se encontro la seccion 3")

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("03-Diseno.md actualizado")
