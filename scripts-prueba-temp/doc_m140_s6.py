# -*- coding: utf-8 -*-
import io
p = "DOCUMENTACION/140-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """### 2.8.1 Rendimiento medible de Alpha (cerrada 2026-10-14, step-5-kilocode)

Cierra la seccion 6 del checklist. **Buena parte del trabajo ya estaba hecho y verificado en M139
(secciones 9 y 12)** — aca se reconfirma para Alpha sin duplicar.

| Item | Respaldo |
|---|---|
| Dashboard FPS/p99/memoria/carga/draw calls | **definido en M139 4.1** — panel de superposicion (F3) 100% local que lee `BudgetProfile` + `AssetProfile` |
| Gate CI de presupuestos por zona (M61) | **presente** — `validate_budget.gd` (usa `draw_calls`) + `test_budget_profile.gd` + pipeline M108 como gate; regla de M139 4.1 |
| Presupuesto de memoria global (M62) | **definido en M139 4.1** — preset base 1.500 MB (tabla de M62: 1.500/2.000/2.500) |
| Presupuesto de tiempos de carga/streaming (M63) | **definido en M139** — carga < 2 s con barra real de `pantalla_carga.gd` + presupuesto de ms por frame de `stream_manager.gd` |
| Telemetria de sesion en playtest | **definida en M139 4.1** — opt-in, local (`user://`), sin envio remoto |
| Profiling periodico por sistema nuevo | **definido en M139 4.1** — el dashboard mide por categoria y toda zona nueva declara su presupuesto |
| Escenario de referencia (ruta fija 20 min) | ya estaba `[x]` en el checklist; aca se confirma como la ruta Aurora completa de M139 (6 sectores + templo + Coral) |
| Build semanal de referencia | ya estaba `[x]`; se confirma como la build que corre el escenario de 20 min |

**Reporte semanal de rendimiento con tendencia (definido aca):** resumen semanal que compara la
build actual contra la anterior con 3 metricas clave (p99 de frame, memoria pico, tiempo de carga de
la zona mas pesada) y marca la tendencia (mejorando/estable/regresando). Sale del mismo
`BudgetProfile` + telemetria local.

**Plan de accion ante regresiones (definido aca):** si el p99 de frame sube > 15% o la memoria pico
pasa el presupuesto, la zona afectada se marca `fuera_de_presupuesto` (regla de M139 4.1), se hace
**rollback de la zona** a la ultima version con presupuesto OK (git tag por zona) y se abre bug en
`11-BUGS.md` con severidad. La build semanal no se publica con una zona en regresion.
"""

ancla = "### 2.7 Deuda"
if ancla in t:
    t = t.replace(ancla, seccion.rstrip() + "\n\n" + ancla, 1)
    print("seccion 2.8.1 insertada")
else:
    print("AVISO: ancla no encontrada")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("ok")
