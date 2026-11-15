**Modelo:** ERNIE-5.5-Flash-Preview (Baidu)
**Plataforma:** Kilo Code
**Fecha:** 2026-11-14 05:25
**Corrección:** 2026-11-14 05:35 — el fundador aclaró el concepto (viaje entre islas + aventura a bordo) y se verificó que **M68 ya documenta el sistema de rutas/pasajes/temporada**. Este archivo se reescribió para reflejar eso.

# 01-Requerimientos.md — Módulo 169: Crucero Real (buque de línea entre islas)

> **Origen:** encargo directo del fundador (2026-11-14):
> 1. *"hay algo que me esta faltando es el crucero gigante con distintos pisos y habitaciones eso no esta documentado?"*
> 2. *"la idea del crucero o barco gigante es el viaje entre islas… que cada cierto tiempo en una época del año pase ese buque, compren el ticket en alguna parte, suban los que quieran ir a otra isla"*
> 3. *"la idea es que ese mismo barco sea por sí una aventura en sí con juegos y retos ahí mismo"*

## Problema

El concepto tiene **tres capas**, y el estado real de cada una es distinto:

| Capa | Estado real | Dónde está |
|---|---|---|
| **1. Sistema de rutas entre islas, pasajes y temporada** | ✅ **YA EXISTE** | **M68 Transporte-Y-Navegación** (127/131, 🟡) |
| **2. El buque físico multi-cubierta (el objeto)** | ❌ **NO EXISTE** | — (M28 solo tiene `BoatDeck`, **una** cubierta) |
| **3. La aventura a bordo (juegos y retos)** | ❌ **NO EXISTE** | — (los ladrillos están en M74/M68/M21, nadie los conectó) |

**Error de este agente, reconocido:** la primera versión de este archivo decía *"el crucero no existe"*.
Era falso: **el sistema de transporte entre islas está documentado e implementado en M68**. Lo que no
existe es **el buque** (capa 2) y **la aventura a bordo** (capa 3). El módulo 169 cubre esas dos capas
**sobre** M68, sin reemplazarlo.

### Evidencia de la capa 1 (M68 — verificada en disco 2026-11-14)

`DOCUMENTACION/68-Transporte-Y-Navegacion/plan-actual/04-Codigo.md`:

```gdscript
@export var temporada: String         # "" | "todas" | estación (M29)
func buy_ticket(route_id, stop_id) -> Dictionary   # {ok, motivo, precio, route_id}
```

> **Orden de bloqueo** (determinista y testeado): desbloqueo de parada → flag de ruta → horario del
> destino → **temporada** → clima.

`transport_network.tres` = **única fuente de verdad** (10 paradas, 20 rutas). Paradas de ejemplo:

| Parada | Tipo | Conexiones | Coste (M38) | Horario (M29) |
|---|---|---:|---|---|
| Puerto de Aurora (isla principal) | barco | 6 rutas | 20-80 | 06:00-22:00 |
| Puerto de la Isla del Este | barco | 3 rutas | 30-60 | 07:00-21:00 |
| Plataforma del Norte | dirigible | 2 rutas | 50-90 | 08:00-19:00 |
| **Puerto del Festival (M74)** | **barco/temp** | 1 ruta | 10 | **solo festival** |

**Conclusión:** el "cada cierto tiempo, en una época del año" y el "comprar el ticket en alguna parte"
**ya están resueltos**: `temporada` en la ruta + `buy_ticket()` + parada temporal del festival (M74).

### Evidencia de la capa 3 (aventura a bordo)

| Ladrillo existente | Dónde | Sirve para |
|---|---|---|
| Festivales con minijuegos por **contrato de escena** | M74 `03-Diseno.md` L113/L139/L167 | enganchar un juego a bordo al sistema de festivales |
| Eventos de ruta **sin peligro** | M68 `transport_route_events.gd` (M64) | eventos durante la travesía |
| Diálogos y elecciones | M21 | retos conversacionales |
| Minijuego de pesca (FSM 7 estados) | M34 `fishing_session.gd` | **plantilla** de minijuego |
| Casino / juegos de mesa | — | **no existe**, se crea |

**Conclusión:** la aventura a bordo **no está documentada**; hay que diseñarla apoyándose en M74 + M68 + M34.

## Objetivos

1. **Modelar el buque** (exterior multi-cubierta + 4 interiores) como asset del juego, integrado con M68.
2. **Definir la aventura a bordo**: 3-4 actividades con reto (no solo casino), conectadas al sistema de
   festivales de M74 y a los eventos de ruta de M68.
3. **Definir el ciclo estacional**: el buque llega en una ventana del año (M29), se anuncia, vende
   pasajes (M68 `buy_ticket`), embarca a quien quiera ir a otra isla, zarpa.
4. **No modificar** M68, M28, M74 ni M34: se agrega en paralelo (§15 AGENTS).

## Alcance

**Capa 2 — el buque**
- Exterior: casco 72 × 14 m, 4 cubiertas, 2 chimeneas, botes, puente. 3 LOD.
- Interiores: 4 escenas (botes/carga, camarotes, comedor-casino, puente) + 6 camarotes tipo.

**Capa 3 — la aventura a bordo**
- **Casino**: 2 mesas de cartas + 1 ruleta (minijuego simple de apuesta, monedas M38).
- **Torneo de cubierta**: 1 reto físico (recorrido de cubierta contra reloj).
- **Espectáculo de cubierta 3**: evento guionado (M21) con 2 resultados.
- **Camarote misterioso**: 1 reto de exploración (pista + recompensa).
- **Vigía**: mirar por el catalejo y detectar algo en el mar (mini-reto de observación).

**Capa 1 — el ciclo (sobre M68)**
- Ventana estacional (M29) en la que el buque toca el puerto.
- Anuncio en el puerto y en el mapa (M54).
- Venta de pasajes (M68 `buy_ticket`) con 3 clases.
- Embarque de los NPC que quieran viajar (M64 pasajeros).
- Travesía con eventos de ruta (M68) + los juegos a bordo.
- Desembarco en la isla destino.

## Fuera de alcance

- **Reemplazar M68**: no. M68 sigue siendo el dueño de rutas, paradas, pasajes y bloqueos.
- **Navegación libre del buque**: sigue rutas (M68), no es manejable.
- **Multijugador**.
- **Diseño de personajes NPC**: no lo firma este agente (ver `NICHO-Y-LIMITES.md`).
- **Casino con dinero real / apuestas de valor**: monedas del juego (M38) únicamente.

## Restricciones

| # | Restricción |
|---|---|
| R1 | **No tocar** M68, M28, M74 ni M34. El 169 se agrega en paralelo (§15 AGENTS). |
| R2 | **Un interior = una escena** (precedente M18). |
| R3 | **Streaming** por cubierta (M63). |
| R4 | Exterior ≤ 9.000 v (alta); interior por escena ≤ 4.000 v. |
| R5 | `Z_APOYO = 0,045`; pivote en la **línea de flotación** (el buque se posa en el agua). |
| R6 | Nomenclatura `SM_`/`MAT_Crucero_*`, un material por pieza, sin texturas. |
| R7 | Eslora **72 m** (el mayor del juego: la flota va de 4,2 a 15,0 m). |
| R8 | Español en toda la documentación. |
| R9 | Ningún GLB con `z_min` fuera de `0,045 ± 0,020` (auditable). |
| R10 | Los juegos a bordo deben reutilizar M74 (contrato de minijuego) y M21 (diálogo), no reimplementarlos. |

## Criterios de aceptación

| # | Criterio | Verificación |
|---|---|---|
| CA1 | Los 10 archivos de documentación existen | `Test-Path` |
| CA2 | El exterior pasa `auditar_glb_490.py` y mide 72 m | script + inspección |
| CA3 | El buque llega en su ventana estacional y se anuncia | M29 + M54 |
| CA4 | El jugador compra pasaje con `buy_ticket()` de M68 | log de M38 |
| CA5 | Se puede jugar al menos 1 actividad a bordo de principio a fin | prueba manual |
| CA6 | M68, M28, M74 y M34 no cambiaron de comportamiento | suite de tests existente |

## Actores

| Actor | Rol |
|---|---|
| Jugador | Compra pasaje, embarca, juega a bordo, desembarca |
| `CruceroManager` (nuevo, autoload) | Presencia del buque, ventana estacional, ocupación |
| M68 `TransportManager` | Rutas, paradas, `buy_ticket`, bloqueos por temporada |
| M74 `EventManager` | Contrato de minijuego a bordo |
| Pasajeros NPC (M64) | Viajan, juegan, dan pistas |

## Fuentes consultadas

- `DOCUMENTACION/68-Transporte-Y-Navegacion/plan-actual/{01,03,04}*.md` — **sistema de rutas y pasajes**
- `DOCUMENTACION/74-Eventos/plan-actual/03-Diseno.md` — festivales y minijuegos por contrato
- `DOCUMENTACION/28-Viajes/plan-actual/03-Diseno.md` — `Boat`, `BoatDeck`, P20 pasajeros
- `DOCUMENTACION/34-Pesca/plan-actual/04-Codigo.md` — `fishing_session.gd` como plantilla de minijuego
- `DOCUMENTACION/67-Vehiculos/` + `data/vehiculos/vehicles.json` — registro de vehículos
- `DOCUMENTACION/GUIA-BLENDER/09-nivel-detalle-modelado.md` — presupuesto y método
- `DOCUMENTACION/168-Plantilla-De-Isla/` — formato de módulo