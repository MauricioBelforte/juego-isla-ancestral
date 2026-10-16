# -*- coding: utf-8 -*-
import io
p = "DOCUMENTACION/140-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """### 2.7.1 Integraciones verificadas contra disco (cerrada 2026-10-14, step-5-kilocode)

Cierra la seccion 3 del checklist. Cada integracion se verifico con grep sobre el modulo que deberia
implementarla.

| Integracion | Estado verificado |
|---|---|
| Amistad -> economia (5-10% precio) | **presente** — `economy_manager.gd` + `price_manager.gd` (10 hits de descuento/precio) + `bonus_amistad` en `recompensa_def.gd` (M74/M20) |
| Clima -> cultivos (lluvia 20%, helada) | **presente, parcial** — `weather_service.gd` + `test_farm_clima.gd` + `test_fishing_clima.gd`. La lluvia esta; **helada: 0 hits** (deuda de M33) |
| Calendario -> rutinas NPC (fiestas) | **presente** — 30 hits de fiesta/festival; modulos 29-Tiempo-Y-Calendario y 74-Eventos existen |
| Construccion -> amistad (regalos fabricados +25%) | **ausente** — 0 hits de regalo fabricado |
| Viajes -> estacion vegetal por isla | **presente** — `island_props.gd` (M27) mas `test_mercado_estacion_ferias.gd` y `test_estacion_iter5.gd` (5 hits) |
| Templos -> artefactos -> progresion | **ausente** — los artefactos pasivos no existen (seccion 2), la cadena esta cortada en el primer eslabon |
| Economia global -> tiendas por isla | **presente** — `catalogo_tiendas.gd` con tienda_general y herreria (Aurora) + mercader_viajero; la de Coral (glasswork) pendiente de alta |
| Clima -> audio ambiental (M32/M42) | **presente** — `ambient_biome_bank.json` ya tiene variante `clima_2` por sector |
| Eventos -> diario (M74/M55) | **presente** — `event_manager.gd` y `save_provider.gd` referencian el diario (2 hits) |
| Servicio `Almanaque` | **ausente** — 0 hits en `scripts/`. Queda como servicio por disenar |
| `HistoriaMaster` sin acoplar misiones | **ausente** — 0 hits. Queda como contrato por disenar |
| Pruebas de integracion por cadena (M112) | **presente** — 17 hits, incluidos `test_m162_integracion_m19.gd`, `test_m18_m60_integration.gd` y `test_terrenos_integracion.gd` |

**Definicion de `Almanaque` (propuesta, no implementada):** servicio unico que expone `ahora()`,
`estacion()`, `clima_previsto()` y `eventos_hoy()`, y que ningun otro servicio consulta al reloj
directamente. Hoy el tiempo pasa por `TimeCalendar` (autoload) y el clima por `weather_service.gd`;
`Almanaque` seria la fachada unica. Queda `[ ]` hasta que se implemente.

**Definicion de `HistoriaMaster` (propuesta, no implementada):** orquesta actos y sellos (1.4) pero
no conoce misiones individuales — esas viven en M22/M23 y se subscriben por senal. Evita el
acoplamiento que el item pide.

**Cadena cortada a reportar:** la integracion templos -> artefactos -> progresion depende de los
artefactos pasivos, ausentes (deuda de la seccion 2). Mientras no existan, esa cadena no se puede
probar.
"""

ancla = "## 3. Hits GONOGO-BETA"
if ancla in t:
    t = t.replace(ancla, seccion.rstrip() + "\n\n" + ancla, 1)
    print("seccion 2.7.1 insertada")
else:
    print("AVISO: ancla no encontrada")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("ok")
