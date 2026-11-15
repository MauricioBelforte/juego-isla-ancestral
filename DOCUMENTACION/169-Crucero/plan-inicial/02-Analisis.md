**Modelo:** ERNIE-5.5-Flash-Preview (Baidu)
**Plataforma:** Kilo Code
**Fecha:** 2026-11-14 05:25

# 02-Analisis.md — Módulo 169: Crucero de Lujo

## 1. Análisis del dominio

Un crucero de pasajeros no es "un barco más grande". Es un **edificio flotante** con cuatro
problemas de diseño que se resuelven por separado:

| Problema | Naturaleza | Módulo que lo resuelve |
|---|---|---|
| Exterior navegable | Asset 3D + ruta | 169 (este módulo) |
| Interiores habitables | Escenas + colisión + iluminación | 169, con patrón M18 |
| Carga/streaming del interior | Rendimiento | M63 (existente, se reutiliza) |
| Viaje y pasajeros | Lógica de trayecto | M28 (existente, se reutiliza) |

**Conclusión del análisis (corregida 2026-11-14 05:35):** el crucero **no debe** meterse en M157 (que define tipos de transporte
genéricos) ni en M67 (que define vehículos manejables con física), y **tampoco** en **M68**, que ya implementó el sistema
de rutas/pasajes/temporada y está en 127/131. Es un **objeto del mundo con interior + capa de aventura**: por eso es
módulo propio **que se apoya en M68**.

## 1b. Corrección de la primera versión de este análisis

La primera versión decía *"el crucero no existe en ningún lado"*. **Falso, y verificado:**

| Afirmación original | Realidad |
|---|---|
| "M157 no tiene crucero" | ✅ cierto, pero irrelevante: M157 es genérico y está sin implementar |
| "M28 solo tiene BoatDeck de una cubierta" | ✅ cierto (una cubierta, sin habitaciones) |
| "No hay rutas entre islas" | ❌ **FALSO**: M68 tiene 10 paradas / 20 rutas, `buy_ticket()` y `temporada` |
| "No hay pasajes" | ❌ **FALSO**: M68 implementa la compra de pasaje |
| "No hay eventos estacionales de barco" | ⚠️ parcial: M68 filtra por `temporada` (M29) y tiene la parada "Puerto del Festival — solo festival" |

**La causa del error:** busqué "crucero" y el sistema está nombrado como **"transporte y navegación"**.
Lección registrada: antes de declarar que algo no existe, buscar por **funcionalidad** (ruta, pasaje, temporada),
no por el nombre que el fundador usó.

## 2. Lo que ya existe y se reutiliza

| Sistema | Qué aporta | Costo de reuso |
|---|---|---|
| **M68 Transporte** | **Rutas entre islas, paradas, `buy_ticket()`, bloqueo por temporada (M29), horarios, clima.** Es el corazón del "viaje entre islas" | **Nulo**: ya está implementado (127/131); el 169 lo *consume* |
| **M68 `transport_route_events.gd`** | Eventos de ruta sin peligro (M64) | **Alto**: los eventos de la travesía van por acá |
| **M74 Eventos** | Festivales + **minijuego por contrato de escena** | **Alto**: cada juego a bordo es un "minijuego" enganchado a M74 |
| **M21 Diálogos** | Diálogos y elecciones | **Alto**: retos conversacionales y el espectáculo |
| **M34 Pesca** | `fishing_session.gd` = FSM de minijuego en 7 estados | **Alto**: plantilla de estructura para los juegos a bordo |
| **M28-Viajes** | `Boat`, `BoatDeck`, flujo embarque/desembarque | **Alto**: mismo flujo, otro mesh |
| **M28 P20** | NPC viajeros con rutinas breves | **Alto**: los pasajeros del crucero |
| **M63 Cargas** | Streaming de escenas por sector | **Alto**: cada cubierta es un sector |
| **M67 Vehículos** | `vehicles.json`, atracar/zarpar | **Medio** |
| **M18 Casas** | Patrón "un interior = una escena" | **Alto**: método, no código |
| **M29 Tiempo** | Estaciones y calendario | **Alto**: define la ventana estacional |
| **M38 Economía** | Monedas | **Alto**: precio del pasaje y apuestas del casino |

**Regla derivada:** el crucero **consume** esos sistemas, no los modifica.

## 3. Alternativas evaluadas

### Alternativa A — Meter el buque dentro de M68 (extendida)

- **A favor:** M68 ya tiene rutas, paradas y `buy_ticket()`; el buque es "una parada más".
- **En contra:** M68 está en **127/131 con QA** y es el único dueño del grafo de transporte. Tocar su
  lógica para agregar un mesh y 4 interiores rompe el §15 (modularidad) y arriesga un módulo que ya
  funciona. Además M68 no tiene capas de asset ni de interiores.
- **Veredicto:** **rechazada como implementación**, aceptada como **contrato**: el 169 consume M68.

### Alternativa A' — Extender M157 con un 6.º tipo "Crucero"

- **A favor:** un solo lugar para todos los transportes.
- **En contra:** M157 es scaffold sin implementar (0/124) y su tabla es 1 fila = 1 vehículo genérico.
- **Veredicto:** **rechazada**.

### Alternativa B — Un solo interior gigante (todas las cubiertas en una escena)

- **A favor:** una sola carga.
- **En contra:** viola R3 (streaming), dispara el presupuesto de vértices, y hace imposible cargar
  solo el comedor cuando el jugador entra al comedor.
- **Veredicto:** **rechazada**.

### Alternativa C — Módulo propio 169 con exterior + 4 interiores separados (ELEGIDA)

- **A favor:** aísla el riesgo, sigue el precedente M18, permite streaming real, y cada cubierta se
  puede iterar sin tocar las demás.
- **En contra:** más archivos y más escenas que coordinar.
- **Veredicto:** **elegida**. Es la única que respeta §15 (modularidad) y R2/R3.

## 4. Decisiones de diseño

| # | Decisión | Justificación |
|---|---|---|
| D1 | Módulo **169-Crucero** independiente | Aísla el riesgo; M157/M67/M28 quedan intactos |
| D2 | **Eslora 72 m**, manga 14 m, 4 cubiertas de 3,2 m | Es el objeto más grande del juego (flota: 5-15 m) y sigue siendo manejable en streaming |
| D3 | **4 cubiertas**: (1) botes y carga, (2) camarotes, (3) comedor y casino, (4) puente y terraza | Separa zonas por aforo y por presupuesto de vértices |
| D4 | **6 camarotes tipo** instanciados (no 40 únicos) | Reutilización; el jugador no distingue repetición si el decorado varía |
| D5 | Interiores como **escenas `.tscn` separadas** cargadas por M63 | R2/R3 |
| D6 | Ruta fija entre 2 puntos, no navegación libre | Reutiliza M28; evita física naval nueva |
| D7 | Pasajeros NPC = sistema de M28 (P20) | Ya resuelto; no reimplementar |
| D8 | Exterior en 3 LOD (alta/media/baja) con ≤ 9.000 v en alta | R4 |
| D9 | Sin texturas: color por material | Estética del juego (todos los assets son así) |
| D10 | Pivote base en la **línea de flotación** (no en la quilla) | Un crucero se posa en el agua, no en el suelo |

## 5. Presupuesto de vértices (medido sobre la flota real)

| Asset | Vértices (LOD alta) | Eslora |
|---|---:|---:|
| `barquita_aurora` | 930 | 5,0 m |
| `perla_ancestral` | 1.039 | 8,7 m |
| `globo_del_viento` | 1.028 | 12,3 m |
| `carreta_ancestral` | 1.328 | 4,2 m |
| `gran_vapor` | 1.636 | 15,0 m |
| **169 crucero (objetivo)** | **≤ 9.000** | **72 m** |

**Nota:** 9.000 v para 72 m es **125 v/m**, muy por debajo de los ~110-130 v/m de la flota actual
(gran vapor: 1.636 v / 15 m = 109 v/m). Es un presupuesto **coherente**, no inflado.

## 6. Riesgos

| Riesgo | Probabilidad | Mitigación |
|---|---|---|
| El interior dispara el frame time | Media | Streaming por cubierta (M63) + ≤ 4.000 v por escena |
| El jugador se cae por la borda | Alta | Barandillas con colisión en todo el perímetro |
| Las escaleras entre cubiertas no calculan bien | Media | Escaleras al 30° con `FloorMaxAngle` y rampa invisible de colisión |
| El camarote se siente repetitivo | Media | 6 tipos × variantes de decorado (cama, vista, tamaño) |
| Colisión con el agua (M51) | Media | El casco tiene colisión propia; el agua ya tiene `Area3D` |
| Interferir con M28 (`BoatDeck`) | Baja | El crucero es otra escena; no se toca `BoatDeck` |
| Se desincroniza el pasaje al recargar | Media | `CruceroManager` persiste en M59 (pasaje, camarote, tramo) |

## 7. Dependencias

```
169-Crucero
├── 68-Transporte    (rutas, paradas, buy_ticket, temporada)  ← PRIMARIA
├── 74-Eventos       (contrato de minijuego a bordo)
├── 34-Pesca         (plantilla FSM de minijuego)
├── 21-Dialogos      (retos conversacionales, espectáculo)
├── 28-Viajes        (Boat/BoatDeck, P20 pasajeros)
├── 63-Cargas        (streaming de cubiertas)
├── 29-Tiempo        (ventana estacional)
├── 38-Economia      (monedas: pasajes y apuestas)
├── 67-Vehiculos     (registro de atraque)
├── 59-GameState     (persistencia)
├── 51-Agua          (flotación)
├── 33-Audio, 51-VFX (ambiente)
└── 18-Casas         (patrón de interiores, no código)
```

**Sin dependencias de M157.** El crucero es un **objeto + aventura**, no un tipo de transporte genérico.