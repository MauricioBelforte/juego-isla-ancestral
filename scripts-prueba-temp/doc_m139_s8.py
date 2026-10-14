# -*- coding: utf-8 -*-
import io

p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """### 2.8.1 Gran Vapor — cierre de fase (cerrado 2026-10-14, step-5-kilocode)

Cierra la seccion 8 del checklist. Respaldos verificados en disco: la red de transporte
(`scripts/transporte/generar_red_transporte.gd` — 10 paradas, 20 rutas, incluye `puerto_aurora` con
tipo `barco` e `isla_raiz`), el servicio de viaje (`scripts/viajes/travel_service.gd` — contrato de
embarque con flags M22 via WorldState y `_destinos_visitados`), `boat_route.gd`, los modulos
67-Vehiculos y 68-Transporte-Y-Navegacion, y el leitmotiv `leit_gran_vapor` ya presente en
`music_context_matrix.json` (M41) junto a las capas `olas`/`gaviotas` de `ambient_biome_bank.json`
(M42).

**Gran Vapor:** unico vehiculo de la fase. Atracado en el puerto de Aurora (parada `puerto_aurora`
de la red de transporte), con apariencia de vapor de carga remodelado a ferry. No se conduce: es
transporte de punto a punto.

**Interaccion de embarque (IViajable):** el muelle expone el contrato — el jugador habla con el
tripulante, confirma destino (Coral) y el servicio de viaje valida el flag de desbloqueo (M22 via
WorldState). Con la herramienta `IViajable` creada hoy para el contrato entre capas, el muelle y el
`travel_service` quedan con interfaz comun.

**Cutscene de travesia:** 20-25 s sin gameplay de mar. Camara fija en la popa mirando la estela,
el barco saliendo del puerto, un primer plano del ocena y la llegada al muelle de Coral. Se puede
saltar con la accion de cancelar (sin penalizacion).

**Desembarco en Coral y vuelta:** el desembarco deja al jugador en el muelle de Coral (sector ya
definido en 2.2) con Bram visible como primer contacto. La vuelta es desde el mismo muelle, sin
costo adicional y sin desbloqueo extra (ida y vuelta libre dentro de la misma sesion de viaje).

**Costo del viaje:** ticket de **25 AO** el primer viaje; viajes siguientes **gratis** el mismo dia
(regla cozy anti-frustracion). Coincide con la recompensa por descubrir ruta nueva (25 AO) que ya
existe en `meta.json`, asi que el primer viaje se autofinancia con el meta.

**Que se puede llevar:** el inventario completo viaja con el jugador (regla anti-frustracion: nunca
separar al jugador de sus cosas). Las piezas colocadas y las plantas de la parcela no viajan.

**Vista del ocena como anzuelo (M51/M152):** durante la cutscene, el horizonte muestra siluetas de
islas no visitadas con neblina. Es la unica pista visual del segundo bioma y funciona como anzuelo
de curiosidad (mecanica documentada en 2.2).

**Camara del Gran Vapor (M12):** la cutscene usa el `camera_rig` existente en modo fijo (sin
spring); al embarcar la camara pasa a modo cinematico y al desembarcar vuelve al seguimiento del
jugador. Sin modo de conduccion.

**Audio de travesia (M42/M41):** capas `olas` + `gaviotas` (M42) como base, con el leitmotiv
`leit_gran_vapor` (M41) entrando en el segundo plano cuando el puerto se pierde de vista. Volumen
bajo, sin percusiva.

**Variante para que no sea repetitivo:** el tripulante tiene 4 lineas de dialogo rotativas por viaje
(una por viaje del dia, ciclo de 4 dias) mas una variante nocturna. El dialogo se almacena en el
`world_state` para no repetir la misma linea dos veces seguidas.
"""

ancla = "### 2.9" if "### 2.9" in t else None
# insertar antes de la seccion 3 (Pipeline) si no hay 2.9
a2 = "## 3. Pipeline de assets (M108)"
t = t.replace(a2, seccion.rstrip() + "\n\n" + a2, 1)
print("seccion 2.8.1 insertada antes de Pipeline")

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
