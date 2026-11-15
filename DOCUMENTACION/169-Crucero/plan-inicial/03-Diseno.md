**Modelo:** ERNIE-5.5-Flash-Preview (Baidu)
**Plataforma:** Kilo Code
**Fecha:** 2026-11-14 05:25

# 03-Diseno.md — Módulo 169: Crucero de Lujo

## 1. Arquitectura general

```
                    CruceroManager (autoload nuevo)
                    ├── pasajes_disponibles: Array[Pasaje]
                    ├── pasaje_actual: Pasaje
                    ├── cubierta_actual: int
                    ├── camarote_asignado: String
                    └── estado: EMERGENCIA | ATRACADO | ABORDO | NAVEGANDO
                              │
        ┌─────────────────────┼──────────────────────┐
        ▼                     ▼                      ▼
  Crucero (Node3D)     CruceroProa (Node3D)    CruceroManager
  └── Casco (mesh)     └── punto de atraque      └── señal
  └── Cubierta_1..4
  └── Chimeneas
  └── Area3D "Puerto"  ←── el jugador entra por acá
        │
        ├── Interior_Cubierta1 (escena, streameable)
        ├── Interior_Cubierta2 (escena, streameable)
        ├── Interior_Cubierta3 (escena, streameable)
        └── Interior_Cubierta4 (escena, streameable)
```

**Regla de oro (precedente M18):** **una cubierta = una escena `.tscn`**. El exterior es el
"contenedor"; los interiores se cargan y descargan.

## 2. Dimensiones del exterior

| Medida | Valor | Nota |
|---|---|---|
| Eslora (largo) | **72,0 m** | el mayor del juego (flota: 5-15 m) |
| Manga (ancho) | **14,0 m** | |
| Puntal (alto del casco) | **9,6 m** | desde la línea de flotación a la cubierta 4 |
| Línea de flotación | `z = 0` | el agua está en `z = 0` (M51) |
| `Z_APOYO` | `0,045` | convención del proyecto (ver 01-R4) |
| Calado visual | **1,8 m** bajo el agua | el casco se ve sumergido, no se modela el fondo |
| Cubiertas | 4 × **3,2 m** de altura libre | 3,2 m + 0,4 m de forjado = 3,6 m entre pisos |
| Presupuesto | **≤ 9.000 v** (alta), ≤ 3.500 (media), ≤ 1.500 (baja) | 125 v/m |

**Silueta por cubierta** (de abajo hacia arriba, cada una más corta que la anterior):

| Cubierta | Eslora | Manga | Uso |
|---|---|---|---|
| 1 — Cubierta de botes | 72,0 m | 14,0 m | botes salvavidas, carga, proa |
| 2 — Cubierta de camarotes | 66,0 m | 13,2 m | 6 camarotes tipo + pasillo |
| 3 — Cubierta de salones | 56,0 m | 12,4 m | comedor, casino, cocina |
| 4 — Cubierta de mando | 34,0 m | 10,0 m | puente, terraza, chimeneas |

## 3. Desglose de piezas del exterior (presupuesto por pieza)

| # | Pieza | Vértices objetivo | Nota |
|---|---|---:|---|
| 1 | Casco (obra viva + obra muerta) | 1.400 | loft de secciones; proa con tajamar |
| 2 | Cubierta 1 (forjado + baranda) | 700 | baranda con balaustres cada 1,5 m |
| 3 | Cubierta 2 (casco + baranda) | 600 | |
| 4 | Cubierta 3 (casco + baranda) | 550 | |
| 5 | Cubierta 4 (casco + baranda) | 450 | |
| 6 | Chimeneas (2) | 400 | con Hollín y anillo |
| 7 | Puente de mando (timones, ventanas) | 600 | |
| 8 | Botes salvavidas (4) | 800 | 200 c/u, colgados de pescantes |
| 9 | Pescantes y pescantes de proa | 300 | |
| 10 | Mascarón de proa | 250 | |
| 11 | Escaleras exteriores (2) | 400 | 30° con rampa de colisión |
| 12 | Ventanas de camarote (fila) | 500 | 24 ventanas × ~20 v |
| 13 | Detalle de proa (ancla, cadena) | 200 | |
| 14 | Detalle de popa (hélice, timón) | 250 | |
| 15 | Luces de navegación (rojo/verde/blanco) | 100 | |
| **Total** | | **≈ 7.500** | margen de 1.500 v |

## 4. Interiores: escenas y contenido

| Escena | Cubierta | Contenido | Vértices | Puertas al exterior |
|---|---|---:|---:|---|
| `interior_cubierta_1.tscn` | 1 | pasillo de carga, 2 botes, escotillas | ≤ 2.500 | 2 (proa, popa) |
| `interior_cubierta_2.tscn` | 2 | 6 camarotes + pasillo central | ≤ 3.500 | 1 (escalera) |
| `interior_cubierta_3.tscn` | 3 | comedor (12 mesas), casino (4 mesas), cocina | ≤ 4.000 | 1 (escalera) |
| `interior_cubierta_4.tscn` | 4 | puente de mando, terraza | ≤ 2.000 | 1 (escalera) |

**Camarotes tipo (6 variantes):**

| Tipo | Tamaño | Camas | Decorado | Precio del pasaje |
|---|---|---|---|---|
| `camarote_interno` | 2,4 × 3,0 m | 1 litera | sin ventana | 80 monedas |
| `camarote_exterior` | 3,0 × 3,4 m | 1 cama | ventana redonda | 140 monedas |
| `camarote_familiar` | 4,0 × 3,6 m | 2 camas + litera | 2 ventanas | 220 monedas |
| `suite_small` | 4,4 × 4,0 m | cama grande + sofá | ventanal | 400 monedas |
| `suite_grande` | 5,6 × 4,6 m | cama grande + sala | ventanal + balcón | 700 monedas |
| `camarote_tripulacion` | 2,0 × 2,6 m | 1 litera | sin ventana | no vendible |

## 5. Flujo de embarque y viaje

```
1. Jugador llega al puerto (M28/M67: punto de atraque del crucero)
2. Cruza el Area3D "Puerto" del casco → aparece prompt "Embarcar"
3. CruceroManager.vender_pasaje(clase) → valida monedas (M38) y descuenta
4. Fade → carga `interior_cubierta_2.tscn` (o la que corresponda)
5. Jugador recorre: pasillo → camarote asignado (o comedor/casino)
6. Zarpada: M28 dispara la ruta; el jugador puede quedarse dentro o salir a cubierta
7. Durante el viaje: eventos de M28 (P20 pasajeros, clima, encuentro)
8. Llegada: aviso "Puerto destino" → desembarco → descarga del interior
```

**Estados del `CruceroManager`:**

| Estado | Significado | Transición |
|---|---|---|
| `ATRACADO` | en puerto, admite embarque | → `ABORDO` (al cruzar el Area3D) |
| `ABORDO` | jugador dentro, sin zarpar | → `NAVEGANDO` (al zarpar) |
| `NAVEGANDO` | en ruta | → `ATRACADO` (al llegar) |
| `EMERGENCIA` | evento crítico (falla, tormenta) | → `ATRACADO` (al resolver) |

## 6. Integración con sistemas existentes

| Sistema | Punto de contacto | Técnica |
|---|---|---|
| **M68 Transporte** ⭐ | `TransportManager`, `TransportRoute`, `buy_ticket()`, `temporada` | **El buque es una parada tipo `barco` de M68.** No se reimplementa nada de rutas ni pasajes |
| **M74 Eventos** ⭐ | `EventManager`, contrato de minijuego | Cada juego a bordo se registra como evento con `minijuego` (contrato de escena) |
| **M34 Pesca** | `FishingSession` como **plantilla** | Estructura FSM de 7 estados para los juegos a bordo |
| **M21 Diálogos** | `DialogManager` | Retos conversacionales, espectáculo de cubierta 3 |
| **M28-Viajes** | `Boat`, `BoatDeck`, flujo embarque/desembarque | El crucero es un `Boat` más; reutiliza la ruta y el embarque |
| **M28 P20** | Pasajeros NPC con rutinas | 6-10 NPC a bordo |
| **M63 Cargas** | Streaming por cubierta | Cada cubierta es un sector |
| **M67 Vehículos** | `vehicles.json`, atracar/zarpar | Validación de atraque |
| **M29 Tiempo** | `GameClock`, estaciones | Define la **ventana estacional** del buque |
| **M59 GameState** | Persistencia | `pasaje_actual`, `camarote`, `cubierta`, `tramo` |
| **M38 Economía** | Monedas | Pasajes + apuestas del casino |
| **M51 Agua** | Flotación | El casco se posa en `z = 0` |
| **M33 Audio** | Ambiente | Motor, olas, silbato, música de a bordo |

## 6b. Ciclo estacional (capa 1, sobre M68)

```
M29 (calendario) marca la ventana: 1 vez por estación, el buque toca el Puerto de Aurora
        │
        ▼
CruceroManager.anunciar_llegada()  →  aviso en el puerto + marcador en el mapa (M54)
        │
        ▼
M68 TransportManager: la parada "Puerto de Aurora" tiene una ruta TEMPORAL al destino
     (temporada = estación actual). Solo aparece si la estación coincide.
        │
        ▼
buy_ticket(route_id, stop_id)  →  {ok, motivo, precio, route_id}   (M68, sin tocar)
        │
        ├── 1.ª clase  120 monedas  → suite (cubierta 4)
        ├── 2.ª clase   70 monedas  → camarote exterior (cubierta 2)
        └── 3.ª clase   30 monedas  → camarote interno (cubierta 2)
        │
        ▼
Embarque (Area3D del casco) → fade → interior de la cubierta del camarote
        │
        ▼
Navegación: M68 maneja el trayecto y dispara eventos de ruta (M64)
        │   + los juegos a bordo (§6c)
        ▼
Llegada a la isla destino → desembarco → la parada destino queda desbloqueada (M71)
```

**Ventana estacional (propuesta):**

| Estación | ¿El buque toca puerto? | Nota |
|---|---|---|
| Primavera | Sí | temporada alta de viajes |
| Verano | Sí | + 1 festival a bordo (M74) |
| Otoño | Sí | |
| Invierno | **No** | el mar cierra la ruta (coherente con el clima de M32) |

## 6c. Aventura a bordo (capa 3) — juegos y retos

**Principio de diseño:** el buque no es un decorado: es un **lugar con 5 actividades** que se pueden
hacer mientras se viaja. Cada una reutiliza un sistema existente.

| # | Actividad | Cubierta | Sistema que reutiliza | Recompensa | Duración |
|---|---|---|---|---|---|
| 1 | **Casino** — 2 mesas de cartas + 1 ruleta | 3 | M38 (monedas) + M74 (contrato de minijuego) | monedas | 2-5 min |
| 2 | **Torneo de cubierta** — recorrido contra reloj | 1-2 | M74 (evento con `finalizar_evento(resultado)`) | 80 monedas + reputación | 3 min |
| 3 | **Espectáculo** — función guionada en el comedor | 3 | M21 (diálogos con 2 resultados) | 40 monedas | 4 min |
| 4 | **Camarote misterioso** — pista + cofre | 2 | M21 + M74 | ítem raro (M15) | 5 min |
| 5 | **Vigía** — catalejo, detectar algo en el mar | 4 | M34 (FSM de minijuego como plantilla) | 30 monedas + pistas de M27 | 2 min |

**Contrato de minijuego (cómo se engancha a M74):**

```gdscript
# cada actividad implementa el contrato que M74 ya espera
func iniciar_participacion() -> void      # M74 llama acá
func puede_participar() -> bool           # valida monedas,franja horaria,clima
func finalizar_evento(resultado: Dictionary) -> void   # {exito, premio}
```

**Reglas de la aventura a bordo:**

| # | Regla |
|---|---|
| AB1 | Ninguna actividad es obligatoria: se puede viajar sin jugar |
| AB2 | Las actividades se pausan al desembarcar (no se pierde el progreso) |
| AB3 | El casino usa **solo monedas del juego** (M38); sin microtransacciones |
| AB4 | Cada actividad tiene un **límite diario** (para no farmeas): 3 partidas de casino, 1 torneo, 1 vigía |
| AB5 | Las actividades quedan **bloqueadas si el clima es severo** (M32), salvo el casino (interior) |
| AB6 | Reutilizar `fishing_session.gd` como **plantilla de FSM**, no copiar su lógica de pesca |

**Presupuesto de la capa 3:**

| Recurso | Costo estimado |
|---|---|
| 1 escena de casino (interior cubierta 3, ya contada) | 0 v extra |
| 3 minijuegos (cartas, ruleta, vigía) | 2 scripts nuevos (~150 líneas c/u) |
| 1 evento guionado (espectáculo) | 1 `.tres` de M21 |
| 1 reto de recorrido | 1 `Area3D` + 6 triggers de control |

**Señales nuevas (en `EventBus`):**

```gdscript
signal crucero_embarque(cubierta: int)
signal crucero_desembarco(destino: String)
signal crucero_zarpe(origen: String, destino: String)
signal crucero_llegada(puerto: String)
signal crucero_evento(tipo: String, texto: String)
```

## 7. Colisiones

| Elemento | Colisión | Nota |
|---|---|---|
| Casco | `StaticBody3D` con `ConvexPolygonShape3D` simplificado | no usar la malla completa |
| Cubiertas | `StaticBody3D` plano por forjado | 4 planos |
| Barandillas | `StaticBody3D` caja fina | evita caerse |
| Escaleras | `StaticBody3D` rampa + `FloorMaxAngle = 45°` | la malla visual va aparte |
| Camarotes | `StaticBody3D` de caja por habitación | puertas como `Area3D` |
| Muebles | `StaticBody3D` simple | no collide con el jugador (solo decoración) |

## 8. Iluminación

- **Exterior:** el sol del mundo (M32). Las cubiertas altas reciben sol; las bajas quedan en sombra
  por el propio casco (sombreado natural, sin luces extra).
- **Interiores:** 1 `OmniLight3D` por ambiente (comedor, casino, pasillo) + `Environment` propio con
  `ambient_light` cálido. Sin luces dinámicas por camarote (usar `emission` en el material de la lámpara).
- **Chimeneas:** `GPUParticles3D` de humo (M51), 1 por chimenea.

## 9. Presupuesto de rendimiento

| Métrica | Objetivo |
|---|---|
| Draw calls del exterior | ≤ 40 |
| Vértices del exterior (alta) | ≤ 9.000 |
| Escenas de interior en memoria | **1** (la actual) |
| Luces dinámicas en interior | ≤ 4 |
| Tiempo de carga de cubierta | ≤ 1,5 s |

## 10. Plan de iteración (para el agente que implemente)

| Iter | Entregable | Criterio de cierre |
|---|---|---|
| 1 | Exterior LOD alta (casco + 4 cubiertas + chimeneas) | pasa `auditar_glb_490.py` y se ve a 72 m de eslora |
| 2 | Barandillas, pescantes, botes, escaleras | sin piezas flotando; colisión coherente |
| 3 | LOD media y baja | ≤ 3.500 v / ≤ 1.500 v |
| 4 | Interior cubierta 2 (camarotes) | 6 camarotes + pasillo, ≤ 3.500 v |
| 5 | Interior cubierta 3 (comedor/casino) | 12 mesas + 4 mesas de casino |
| 6 | Interior cubierta 4 (puente) | consola de mando + terraza |
| 7 | Integración M28/M63 | embarque → viaje → desembarque sin errores |
| 8 | Pasajeros NPC (M28 P20) | 6-10 NPC con rutina |
| 9 | Audio + VFX | motor, olas, silbato, humo |
| 10 | QA y cierre | suite de tests + prueba del fundador |