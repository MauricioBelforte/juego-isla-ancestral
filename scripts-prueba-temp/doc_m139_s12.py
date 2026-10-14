# -*- coding: utf-8 -*-
import io
p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """### 4.1 Cierre de metricas y rendimiento de fase (cerrado 2026-10-14, step-5-kilocode)

Cierra la seccion 12 del checklist. Respaldos verificados en disco:

| Componente | Ruta | Cubre |
|---|---|---|
| Frame budget por categoria | `scripts/performance/budget_profile.gd` (+ `test_budget_profile.gd`) | M61: `CATEGORIAS_OFICIALES`, marca inicio/fin de categoria y acumula tiempos (segun 03-Diseno 2.1) |
| Perfiles de hardware | `scripts/hardware/hardware_profile.gd` + autoload `AssetProfile` | perfiles baja/media/alta + blacklist GPU |
| Presupuesto de memoria | `DOCUMENTACION/62-Memoria/plan-actual/03-Diseno.md` (RF2 / presets M90) | total **1.500 / 2.000 / 2.500 MB** por preset |
| Streaming y LOD | `scripts/stream/stream_manager.gd` | LOD por region (coronas del oceano, pisos del subterraneo) + `chunk_lod0/lod1` con distancias |
| Telemetria | `scripts/telemetry/telemetry_director.gd` + `test_telemetria_iter5/7.gd` | M104/M105 con **opt-in** (`establecer_opt_in`, `_cargar_opt_in`) |
| Playtest | `DOCUMENTACION/114-Playtest/` | protocolo profesional + plantilla `PLAYTEST-ENCUESTA.md` + nomenclatura por tester |

**Dashboards locales para playtest (M114):** panel de superposicion (F3) con FPS actual, p99 de
frame, memoria estimada, tiempos de carga de la ultima zona y presupuesto consumido por categoria.
100% local — el mismo BudgetProfile ya expone las categorias; el dashboard solo las lee.

**Frame budget por categoria a cada zona nueva (M61):** toda zona nueva declara su presupuesto por
categoria antes de entrar; si una categoria se pasa del 100% durante 60 frames seguidos, se marca la
zona como `fuera_de_presupuesto` y aparece en el dashboard. La Pradera es la zona de referencia.

**Presupuesto de memoria 1.5 GB con streaming (M62):** el preset base de fase es **1.500 MB** (el
primero de la tabla de M62). Con streaming activo el techo se mantiene; sin streaming (menu,
pantallas modales) el presupuesto no se consume — regla ya presente en `stream_manager.gd`.

**Gate de zona (falla CI):** `test_budget_profile.gd` y el pipeline M108 actuan de gate: si una zona
no declara presupuesto por categoria o se pasa del techo, la CI falla. No se mergea zona sin gate.

**Telemetria de sesion local sin envio remoto (M104/M105):** la telemetria es **opt-in** y escribe
en disco local (`user://`); no hay envio remoto. Si el jugador no acepta, no se registra nada.

**Playtest de fase (M114):** 2-4 h con **5+ testers**, protocolo y plantillas ya definidos en el
modulo 114; cada sesion se archiva con la nomenclatura estandarizada.

**Encuesta de sesion (M114):** la plantilla `PLAYTEST-ENCUESTA.md` es la encuesta post-sesion; se
aplica al terminar cada sesion de playtest.

**Criterio >= 80% "queria seguir jugando":** es el umbral de exito de fase; se mide sobre las
encuestas de los 5+ testers (promedio de la pregunta de continuidad).

**Medicion de distancia de streaming y pops (M63):** el `stream_manager.gd` ya mide las coronas LOD
con distancias declaradas (`chunk_lod0` 1.0, `chunk_lod1` 3.0 ...); la metrica de pops (cuantas
veces una pieza aparecio dentro del radio de vision) se agrega al dashboard local.
"""

ancla = "## 5. Hits de Pre-Alpha"
if ancla in t:
    t = t.replace(ancla, seccion.rstrip() + "\n\n" + ancla, 1)
    print("seccion 4.1 insertada")
else:
    print("AVISO: ancla no encontrada")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("ok")
