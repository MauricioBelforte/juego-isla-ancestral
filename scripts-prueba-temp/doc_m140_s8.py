# -*- coding: utf-8 -*-
import io
p = "DOCUMENTACION/140-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """### 2.10.1 Correccion de arquitectura de Alpha (cerrada 2026-10-14, step-5-kilocode)

Cierra la seccion 8 del checklist. Verificado contra disco:

| Item | Estado |
|---|---|
| Inventario TODO/FIXME por script CI | ya `[x]`; **verificado: 25 TODO/FIXME en 21 archivos** de `scripts/` |
| Sprint de deuda de 2 semanas | definido aca — 2 semanas antes del GONOGO-BETA, dedicadas solo a deuda (coincide con el feature freeze de balance de 2.4.1: uno corre codigo, el otro congela datos) |
| Objetivo 0 TODO/FIXME al cierre | definido aca con **punto de partida real: 25** — el objetivo es 0 al cierre de Alpha; los que queden pasan a Beta documentados |
| Revisiones de diseno por sistema | ya `[x]` |
| Verificacion de interfaz entre managers (M07) | ya `[x]`; la base es ServiceRegistry + los contratos nuevos de M139 (ITienda, ITemplo, IViajable, SesionMaster) |
| Eliminacion de codigo muerto | **patron existente** — hay 3 carpetas `Obsoletos` (`clock`, `fauna`, `localizacion`) con archivos archivados. La politica: nada se borra en caliente, se mueve a `Obsoletos/` con fecha y se borra al cerrar la fase |
| Refactor de hot spots | definido aca — sale del dashboard de `BudgetProfile` (2.8.1): la categoria que mas presupuesto consuma se refactoriza primero; si la mejora no supera el 15%, se revierte |
| Metrica de complejidad ciclomatica | ya `[x]` |

**Nota honesta:** el inventario de TODO/FIXME da **25** (no 0). El objetivo de 0 al cierre de Alpha
requiere el sprint de deuda; hoy no esta cumplido y queda anotado.
"""

ancla = "### 2.7 Deuda"
if ancla in t:
    t = t.replace(ancla, seccion.rstrip() + "\n\n" + ancla, 1)
    print("seccion 2.10.1 insertada")
else:
    print("AVISO: ancla no encontrada")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("ok")
