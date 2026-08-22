**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 39: Tiendas

## ID del Módulo
- **Código:** M39 (CHECKLIST-GLOBAL: ID 39 — Tiendas)
- **Carpeta:** `DOCUMENTACION/39-Tiendas/`
- **Dependencias:** M38 (Economía), M14 (Inventario), M29 (Calendario y estaciones), M30 (Reloj), M19 (Población del pueblo), M20 (Amistad), M53 (UI/UX), M73 (Eventos)
- **Delegable desde:** hoy (diseño completo; la implementación requiere los precios y el catálogo de M38, el contrato de inventario de M14, el calendario de M29 y el reloj de M30)

## 1. Problema

La isla Aurora es un mundo voxel cozy tipo Stardew Valley: el pueblo está poblado por vecinos (M19) que conviven, trabajan y reaccionan al paso del tiempo (M29/M30). La economía del juego (M38) define moneda (`monedas_aurora`), precios y reglas de comercio, pero sin un lugar físico donde comprar y vender, esos sistemas carecen de cara visible: el jugador no tiene dónde gastar sus monedas, los cultivos, pescados y materiales no tienen punto de venta, y el pueblo no se siente vivo. Un sistema de tiendas mal diseñado rompería la promesa cozy: inventarios infinitos e irrealistas, stock que nunca se agota, tiendas abiertas a cualquier hora, o precios que obligan a grindear. Se necesita un sistema de tiendas que sean atributos vivos de sus dueños NPC: cada comerciante tiene su catálogo, su horario, sus días de descanso y su stock renovable, con canalizaciones de stock deterministas y precios delegados a M38.

## 2. Objetivo

Diseñar el sistema de tiendas del juego: puestos y establecimientos pertenecientes a NPCs (puesto de semillas, pescadería, ferretería, tienda general y mercaderes viajeros), cada uno con catálogo propio data-driven, horarios y días de descanso (M29/M30), stock diario generado por canalizaciones de stock (StockGenerator), reabastecimiento por día laborable, rotación estacional y precios de compra/venta delegados al módulo de economía (M38). El resultado debe ser un pueblo que "se siente vivo": tiendas que abren y cierran, stock que se renueva, mercaderes que aparecen y desaparecen, y un jugador que siempre tiene dónde comprar y vender sin fricción ni estrés.

## 3. Alcance

### 3.1 Dentro del alcance
- Definición de tiendas como atributos de NPCs: cada tienda tiene un dueño (M19/M20) y una identidad propia.
- Tipos de establecimiento: puesto de semillas, pescadería, ferretería, tienda general y mercaderes viajeros.
- Catálogos por NPC: cada comerciante declara qué vende y qué compra, con claves i18n.
- Horarios de atención: días abiertos, franjas horarias y días de descanso, consultados al calendario (M29) y al reloj (M30).
- Canalizaciones de stock (StockGenerator): generación de stock inicial, reabastecimiento diario, rotación estacional y filtros por eventos; stock acotado y determinista con PRNG de partida.
- Compra (jugador → tienda) y venta (jugador → tienda) delegando precios a M38 (PriceManager), con flujos completos de validación.
- Precios jugador-vendedor distintos según dirección de la operación (compra vs venta), siempre provistos por M38.
- Mercaderes viajeros: NPCs temporales con calendario de aparición (días de feria, días aleatorios con PRNG) y catálogo rodante.
- Persistencia del estado de tiendas: stock actual, desviaciones respecto a base, fechas de último reabastecimiento, aparición de mercaderes.
- Registro de transacciones de tienda (log) y señales para UI (M53), sonido (M43) y analytics (M104).

### 3.2 Fuera del alcance
- Los precios, la moneda y el trueque pertenecen a M38: este módulo los consulta, no los define.
- La UI completa de comercio (ventanas, carrito, catálogo visual) pertenece a M53; aquí solo se definen las señales y datos que la UI consume.
- El sistema de misiones económicas y pedidos del tablón pertenece a historias secundarias (M23).
- El espacio físico de las tiendas (mesones del edificio, voxel art del puesto) es contenido del mundo (módulos de mundo/voxel, M17/M21 y afines).
- La economía de construcción (costos de M17) consume precios de M38; no define tiendas.
- Multijugador y comercio entre jugadores: descartado (juego single-player).

## 4. Restricciones

- **Motor:** Godot 4.x (>= 4.4.1), GDScript tipado explícito, sin C#.
- **Mundo voxel:** las tiendas no modifican el mundo; solo leen datos y entregan ítems por M14.
- **Tono cozy:** ninguna tienda puede generar estrés (sin colas, sin stock que "se pierde", sin subastas, sin presión de compra).
- **Data-driven:** catálogos, horarios, stock y tipos de tienda viven en recursos `.tres`, editables sin tocar código.
- **Desacoplamiento:** el módulo no conoce la UI; comunica resultados por señales (sección 9 de AGENTS.md). Los autoloads de tiendas son consumidos por managers de UI.
- **Precios delegados:** toda consulta de precio pasa por M38 (PriceManager); este módulo jamás define valores monetarios.
- **Determinismo:** el stock generado y los mercaderes viajeros usan el PRNG de partida (M29) para coherencia entre sesiones.
- **Persistencia:** el estado de tiendas se guarda con la partida junto a M14/M38.
- **Sin servidores:** todo es local.

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Tiendas por NPC | Cada tienda declara `npc_duenio_id` (M19/M20); una tienda no existe sin su dueño; un NPC puede ser socio de más de un puesto |
| RF2 | Tipos de tienda | Enum/constante de tipos: SEMILLAS, PESCADERIA, FERRETERIA, GENERAL, VIAJERO; cada tipo define comportamiento de catálogo y stock |
| RF3 | Catálogos por NPC | `ShopCatalog` por comerciante: lista de ítems ofrecidos (venta) y ítems comprados (recompra), con claves i18n |
| RF4 | Horarios | `{dias_abierto: Array[int], hora_apertura, hora_cierre}`; estado abierto/cerrado consultado a M29/M30 |
| RF5 | Días de descanso | Días de la semana en que la tienda permanece cerrada (señal de cierre explícita para la UI) |
| RF6 | Stock inicial | Al crear la tienda (o al comenzar partida), StockGenerator produce el stock base del día |
| RF7 | Reabastecimiento | Renovación de stock por día laborable (evento `nuevo_dia_laborable` de M29), respetando máximos por ítem |
| RF8 | Rotación estacional | El stock se filtra por estación (M29): semillas de la estación, cebos de verano, etc. |
| RF9 | Canalización de stock | StockGenerator aplica etapas: definición base → filtro estacional → filtro de eventos → aforo por rareza → salida determinista |
| RF10 | Compra | El jugador compra ítems del catálogo: valida apertura, stock, fondos (M38) e inventario (M14) |
| RF11 | Venta | El jugador vende ítems a la tienda: valida apertura, recompra permitida (M38), stock del jugador (M14) e ingreso de monedas (M38) |
| RF12 | Precios desde M38 | `precio_compra` (lo que paga el jugador) y `precio_venta` (lo que recibe el jugador) siempre consultados a PriceManager |
| RF13 | Mercaderes viajeros | NPCs temporales cuyo calendario de aparición usa PRNG (M29) y ferias (M73); traen catálogo rodante generado por StockGenerator |
| RF14 | Consulta de stock | `stock_de(shop_id, item_id)` y `listar_stock(shop_id)` para UI y otros sistemas |
| RF15 | Señales de resultados | `compra_exitosa/compra_rechazada`, `venta_exitosa/venta_rechazada`, `inventario_tienda_cambio`, `tienda_abierta/tienda_cerrada` |
| RF16 | Persistencia | Stock actual, desviaciones, mercaderes activos y contadores diarios se guardan y restauran |
| RF17 | Eventos y ferias | Durante una feria (M73) los mercaderes viajeros aparecen y las tiendas pueden aplicar catálogo extendido |
| RF18 | Registro de transacciones | Log de cada operación (compra, venta, reabastecimiento, aparición de mercader) para debugging y analytics (M104) |

## 6. Requisitos No Funcionales

- **Cozy:** cero fricción innecesaria; tiendas abiertas la mayoría de los días; nunca se le quita al jugador algo comprado por un error del sistema.
- **Tranquilidad:** el stock nunca se agota por completo de los ítems básicos; el reabastecimiento es predecible (cada día laborable).
- **Rendimiento:** sistema discreto por eventos (transacción, cambio de día); sin bucles por frame; consultas de stock en O(1) con diccionarios.
- **Determinismo:** generación de stock y aparición de mercaderes con PRNG de partida (M29); misma semilla → mismo día idéntico.
- **Data-driven:** catálogos, horarios, stock y tipos en `.tres`; validación en editor con errores accionables.
- **Desacoplamiento:** autoloads puros de datos y lógica; sin referencias a nodos de UI; integración por señales.
- **Localización:** nombres de tiendas, catálogos y NPCs listos para i18n (claves string en catálogo de traducción).
- **Godot 4.x (>= 4.4.1):** GDScript tipado, recursos `Resource`, señales del core, `RefCounted` para helpers.
- **Seguridad de datos:** stock nunca negativo; transacciones atómicas (o ambas partes se mueven o ninguna).
- **Sin red:** todo local, sin sincronización.

## 7. Criterios de Aceptación

1. El jugador puede comprar en el puesto de semillas, la pescadería, la ferretería y la tienda general con precios idénticos a los que devuelve M38 para cada ítem.
2. La pescadería está cerrada su día de descanso declarado y a las 21:00, y la compra se rechaza con motivo CERRADA sin efectos laterales.
3. Al avanzar un día laborable (M29), el stock de cada tienda se renueva según su definición y la estación vigente (semillas solo de temporada).
4. Vendiendo pescado a la pescadería, el jugador recibe el `precio_venta` de M38 y el stock de monedas cambia exactamente.
5. Si el jugador no tiene fondos, la compra se rechaza con motivo SIN_FONDOS y no se descuenta stock ni monedas.
6. Un mercader viajero aparece el día de la feria (M73) con un catálogo rodante distinto al de las tiendas fijas, y desaparece al finalizar.
7. Tras guardar/cargar, el stock de todas las tiendas, los mercaderes activos y los contadores diarios coinciden exactamente.
8. Dos partidas con la misma semilla (M29) generan el mismo stock el mismo día en las mismas tiendas.

## 8. Fuentes de Contexto (plan maestro)

- El pueblo debe "sentirse vivo": tiendas con dueños, horarios y días de descanso.
- Los comercios son espacios de comunidad, no trampas económicas: vender lo que uno cultiva o pesca es rentable (M38 garantiza los precios amables).
- Los mercaderes viajeros aportan variedad y novedad sin romper la estabilidad de las tiendas fijas.
- El stock, como los precios, es amable: los ítems básicos nunca faltan del todo.
---

## 9. EXPANSIONES DEL MODULO 158 (2026-08-22)

### 9.1 Nuevos Tipos de Tienda

| Tipo | Isla | Descripcion |
|------|------|-------------|
| CARPINTERO | Principal | Vende herramientas T1, cursos de carpinteria |
| HERRERO | Isla 2 | Vende herramientas T2, cursos de herreria |
| HERRERO_AVANZADO | Isla 3 | Vende herramientas T3, cursos avanzados |
| ENCANTADOR | Isla 4 | Vende herramientas T4, cursos de encantamiento |
| TIENDA_JUGADOR | Cualquier isla | Tienda del jugador, vende items craft/herramientas |

### 9.2 Tienda del Jugador

- El jugador puede construir una tienda en su casa (M18) o en isla visitada
- La tienda del jugador recibe 1 NPC visitante por dia maximo
- El NPC compra 1-3 items del stock del jugador
- El jugador debe tener items en la tienda para que los compren
- Si no hay items, no vienen NPCs
- Los NPCs son aleatorios del pool de M19

### 9.3 NPCs Visitantes (ShopVisitorManager)

- 1 NPC por dia como maximo
- El NPC trae monedas propias (no infinito, ~50-200 monedas)
- Compra 1-3 items del stock del jugador
- Prefiere items de la profesion del NPC
- Si el jugador no tiene tienda abierta, no vienen
- Se registra transaccion en log
- Se emite signal visitor_sale(item, price)

### 9.4 Integracion con M158 (Herramientas y Desbloqueo)

- El carpintero de la isla principal vende herramientas T1
- El herrero de isla 2 vende herramientas T2
- El herrero avanzado de isla 3 vende herramientas T3
- El encantador de isla 4 vende herramientas T4
- Cada tienda profesional tambien ofrece cursos de oficio
- Los cursos son unicos y caros (inversion a largo plazo)
- Al tomar un curso, el jugador aprende a vender herramientas en su tienda

### 9.5 Tabla de Cursos y Precios

| Curso | Isla | Costo | Desbloquea |
|-------|------|-------|------------|
| Carpinteria Basica | Principal | 300 monedas | Vende T1 (precio 10-15) |
| Herreria | Isla 2 | 1500 monedas | Vende T1-T2 (precio 15-30) |
| Herreria Avanzada | Isla 3 | 5000 monedas | Vende T1-T3 (precio 20-50) |
| Encantamiento | Isla 4 | 10000 monedas | Vende T1-T4 (precio 30-80) |
