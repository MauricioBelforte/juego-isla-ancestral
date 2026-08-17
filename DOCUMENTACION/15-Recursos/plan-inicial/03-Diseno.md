**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 15: Recursos

## 1. Arquitectura

```
                ResourceManager.gd (autoload, única autoridad del módulo)
   ┌───────────────┬───────────────┬─────────────────┬───────────────┐
   ▼               ▼               ▼                 ▼               ▼
ResourceDef-    ResourceNode    ResourceDrops    ResourceSpawner   RecursoBolsa
inition    (nodo 3D en el    (generación y      (instanciación,   (drop agregado
(recursos .tres   mundo; estados   física de drops;  respawn, presu-  para suelo
 data-driven)     intacto/dañado/  pooling, imán)    puesto, guardado) saturado)
                  agotado)
   │               │               │                 │               │
   └───────┬───────┴───────┬───────┴─────────┬───────┴───────┬───────┘
           ▼               ▼                 ▼               ▼
        Mundo Voxel     Herramientas       Inventario    Calendario/
        (M08 altura/    (M13 señal         (M14 señal     Eventos
         región)         golpe)             agregar_items)  (M29/M32/M73)
```

**Capas:** el módulo es 100% data-driven (definiciones), no conoce la UI, y se comunica por señales con M08/M13/M14/M29/M32/M73. Un único autoload (`ResourceManager`) orquesta; las clases de nodo no se conocen entre sí.

## 2. Diagramas de Flujo

### 2.1 Flujo de recolección

```
                      ┌────────────────────────────────────────┐
                      │ Pasos: jugador golpea con herramienta  │
                      └────────────────────────────────────────┘
                                        ▼
                        M13 emite señal: golpe_aplicado(pos, herr_id)
                                        ▼
        ResourceNode (dentro del Area3D del golpe) recibe la señal
                                        ▼
              ¿herramienta válida para este resource def?
                    ┌───────────NO───────────┐
                    ▼                        ▼
        feedback "tienes que golpear        ¿estado == intacto?
        con <X>" (texto suave/visual)            │
                    │                          SÍ│
                    └───────────────┬────────────▼
                                    ▼
                        estado = dañado; golpes -= 1;
                        animación + partículas + sonido
                                    ▼
                       ¿golpes restantes == 0?
                    ┌───────────NO───────────┐
                    ▼                        ▼
            quedará dañado (estado        estado = agotado;
            visible, respawn parcial)     ResourceDrops.generar(def)
                                                 ▼
                              drops físicos caen al suelo (dispersión)
                                                 ▼
                                  jugador se acerca → imán → recogida
                                                 ▼
                              M14.agregar_items(entrega) + feedback
```

### 2.2 Flujo de respawn

```
                    ResourceManager recibe estacion_cambio(nueva) (M29/M32)
                                        ▼
                para cada nodo con estado == agotado:
                        ¿fecha_reaparicion <= fecha actual?
                          ┌──────NO──────┐
                          ▼              ▼ SÍ (o evento M73 que lo repone)
               espera (nada)     Revalidar posición con M08
                                                 ▼
                        ¿hay construcción (M17) sobre el voxel?
                          ┌──────SÍ──────┐
                          ▼              ▼ NO
              reposicionar al voxel      instanciar ResourceNode
              libre más cercano          (chequeo presupuesto)
                        (radio 8 vox.)            ▼
                                        registrado intacto; seed PRNG
```

### 2.3 Flujo de spawn inicial del mundo (con M08/M09)

```
        M08 emite: region_activada(region_id)
                ▼
   ResourceSpawner.planificar_region(region_id)
    (usa reglas de bioma del ResourceDefinition)
                ▼
        por tipo de recurso, genera candidatos
        (posiciones dentro de la región, sobre voxel)
                ▼
        valida: accesible (M08 caminable), no superpuesto,
        no dentro de zona de construcción, dentro de límites
                ▼
        registra en tabla de nodos (determinista por seed PRNG)
        e instancia dentro de la burbuja del jugador (48 m)
```

## 3. Clases

### 3.1 `ResourceDefinition` (Resource, serializable → .tres)

| Campo | Tipo | Descripción |
|---|---|---|
| `def_id` | StringName | Id único (ej: `madera_roble`) |
| `display_name` | String | Nombre mostrable |
| `categoria` | enum | MADERA, PIEDRA, FIBRA, COMIDA, MINERAL, RARO |
| `rareza` | int | 0 común .. 3 legendario |
| `icono` | Texture2D | Ícono para inventario/UI |
| `herramienta_requerida` | StringName | Id de herramienta M13 o `""` (manos) |
| `golpes_requeridos` | int | Dureza del nodo (default 2-3) |
| `drops` | Array[DropEntry] | Qué entrega y en qué cantidad/probabilidad |
| `temporada_respawn` | StringName | Estación M29 que reabastece (`"primavera"`, `"todas"`, ...) |
| `evento_respawn` | StringName | Id de evento M73 que repone (`""` = ninguno) |
| `region` | StringName | Región requerida para spawn natural (`""` = cualquier) |
| `mesh_intacto` / `mesh_daniado` / `mesh_agotado` | PackedScene | Variantes visuales (tocón, roca quebrada...) |
| `valor_venta` | int | Comercio futuro |
| `fuentes_alternativas` | Array[StringName] | Recursos de respaldo para QA anti-bloqueo |

**DropEntry:** `{item_id, cantidad_min, cantidad_max, probabilidad_float, requiere_herramienta_mejorada}`.

### 3.2 `ResourceNode` (Node3D)

- Área de interacción (Area3D) con `area_entered` para imán/detección.
- Estados: `INTACTO`, `DANIADO`, `AGOTADO`.
- Escucha la señal global de golpes de M13 y valida herramienta.
- Al agotarse: notifica `ResourceManager.recurso_agotado(node_ref)` (para respawn y guardado) y pide a `ResourceDrops.generar(def)`.
- Feedback: animación de sacudida, partículas del material, sonido por material.
- Modo impostor: variante sin física ni Area3D (para > 48 m).

### 3.3 `ResourceDrops` (Node o autoload helper)

- `generar(def, pos, rng)` → instancia drops físicos (RigidBody3D) con dispersión circular configurable.
- Pooling interno (max 60 físicos, 200 totales).
- Imán: cuando el jugador está a < 1.5 m, el drop se desliza hacia él.
- Auto-recogida al contacto; envía `entrega` a M14 con señales `drop_recogido(item_id, cantidad)`.
- Regla de suelo saturado: si en la zona hay > `MAX_DROPS_ZONA` (40) físicos, crea `RecursoBolsa` con todo el contenido acumulado.
- Expiración cacheada: si nadie recoge en 120 s, el drop se convierte en bolsa durmiente (sin física) para no perder nada.

### 3.4 `ResourceSpawner` (Node, hijo de ResourceManager)

- `planificar_region(region_id)` y `instanciar_nodo(entry)`.
- Presupuesto: burbuja 48 m activa, 48-96 m impostores, > 96 m solo datos; máx 200 instancias activas.
- Tabla `nodos: Dictionary` (node_id → entry) persistida parcialmente.
- Procesa señales de estación (M29/M32) y eventos (M73) para respawn.
- Revalidación de posición con M08 en respawn y carga de chunk.
- Emite `recurso_reaparecio(def_id, pos)` para M73/UX.

### 3.5 `RecursoBolsa` (Area3D)

- Un solo objeto físico con `contenido: Array[ItemEntry]`.
- Al recogerse: entrega todo a M14; el excedente (inventario lleno) se redirige a la caja de almacenamiento del hogar (señal `almacenar_sin_costo` de M17/M14).
- Nunca se pierde contenido.

## 4. Contratos de API (señales globales)

### Recibe (entra al módulo)
| Señal | Emisor | Contrato |
|---|---|---|
| `golpe_aplicado(pos_global, herramienta_id, fuerza)` | M13 | pos_global: Vector3; herramienta_id: StringName o `""` (manos); fuerza: int (1 normal) |
| `estacion_cambio(nueva_estacion)` | M29/M32 | nueva_estacion: StringName |
| `evento_iniciado(id_evento, region_id)` / `evento_finalizado(id_evento)` | M73 | id_evento: StringName |
| `region_activada(region_id)` | M08 | gatilla planificación de spawn |
| `voxel_modificado(pos_voxel, region_id)` | M17/M08 | revalida nodos cercanos (construcción) |

### Emite (sale del módulo)
| Señal | Consumidor | Contrato |
|---|---|---|
| `drop_recogido(item_id, cantidad)` | M14 (ya agregó), UI / Logs | item_id: StringName; cantidad: int |
| `recurso_agotado(def_id, pos, region_id)` | Guardado M29, mundo M08 | para persistencia y feedback visual |
| `recurso_reaparecio(def_id, pos)` | M73, UX, Logs | aviso de mundo vivo |
| `recoleccion_evento(def_id, cantidad_total, herramienta_id)` | Analytics/UX M111 | métricas |
| `suelo_saturado(registrado)` | Logs M103 | aviso de conversión a bolsa |

### Interfaz mínima de `ResourceManager` (autoload, público)

| Método | Firma | Descripción |
|---|---|---|
| `obtener_def(def_id)` | `func obtener_def(def_id: StringName) -> ResourceDefinition` | Catálogo |
| `registrar_nodo_entrada(entry)` | `func registrar_nodo(entry: Dictionary) -> int` | Devuelve node_id |
| `recurso_agotado(node_id)` | `func recurso_agotado(node_id: int) -> void` | Marca para respawn |
| `pedir_respawn(nodo_id)` | `func pedir_respawn(nodo_id: int) -> void` | Fuerza reposición (cheats/tests) |
| `guardar_estado()` / `cargar_estado(data)` | `func guardar_estado() -> Dictionary` / `func cargar_estado(data: Dictionary) -> void` | Persistencia |
| `cantidad_de(def_id)` | `func cantidad_de(def_id: StringName) -> int` | Consulta para M16 (balance) |

## 5. Integración por Módulo

### 5.1 Con M08 (Mundo Voxel)
- Consulta de altura: `VoxelWorld.get_surface_height(region_id, voxel_x, voxel_z) -> Vector3`.
- `region_activada` gatilla `planificar_region`.
- Validación de accesibilidad: `VoxelWorld.es_caminable(pos_voxel)` (evita recursos inaccesibles).
- Nodos anclados por `region_id` + `voxel_base`; se revalidan al cargar chunk.

### 5.2 Con M13 (Herramientas)
- El nodo recibe `golpe_aplicado` y valida `herramienta_requerida` (o manos si `""`).
- `fuerza` multiplica el daño (pico mejorado rompe más rápido).
- Nada del lado herramienta conoce a los recursos (desacoplamiento).

### 5.3 Con M14 (Inventario)
- Los drops llaman `Inventario.agregar_items(entrega)` al recogerse.
- Si el inventario está lleno: excedente a caja de almacenamiento vía señal.
- Los recursos son ítems normales de inventario (`item_id == def_id` o mapping en clase ítem).

### 5.4 Con M16 (Crafting)
- Las recetas referencian `item_id` de recursos; `ResourceManager.cantidad_de` permite validar stock.
- El balance de cantidades (RF11) se ajusta en conjunto con las recetas; se centraliza en `ResourceDefinition` (cantidades por drop), no en cada receta.

### 5.5 Con M29/M32/M73 (Tiempo, Estaciones, Eventos)
- `estacion_cambio` dispara respawns vencidos.
- `evento_iniciado` puede reponer recursos raros: `pedir_respawn` por evento (festival de la cosecha M73 repone comida).
- El PRNG M29 asegura cantidades deterministas entre cargas.

## 6. Regla Cozy (normas de diseño)

1. **Sin agotamiento irreparable:** ningún recurso desaparece para siempre; siempre hay respawn por estación o evento.
2. **Sin hambre castigadora:** la comida es buff, jamás necesidad letal (ver 02-Analisis 2.6).
3. **Generosidad en cantidades:** los drops básicos se sobredimensionan un 20% respecto al consumo mínimo razonable de M16.
4. **Sin atascos:** si falta un material, el juego sugiere (interfaz M16/UI) una fuente alternativa registrada en `fuentes_alternativas`.
5. **Tiempos de espera amables:** máximo 1 estación de juego para materiales comunes; los raros se garantizan una vez por estación en su región.