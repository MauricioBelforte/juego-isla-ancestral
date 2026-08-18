**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 39: Tiendas

## 1. Análisis del Dominio

El dominio de las tiendas de la isla Aurora se descompone en ocho subsistemas interconectados:

### 1.1 Tipos de tienda
- **Dominio:** establecimientos con identidad y reglas propias. Se definen cinco tipos:
  - **Puesto de semillas:** catálogo agrícola, rotación estacional fuerte, ítems básicos siempre presentes.
  - **Pescadería:** pescados y cebos; catálogo ligado a lo que se puede pescar en la estación (M15).
  - **Ferretería:** herramientas, materiales de construcción y repuestos; stock más estable, compras de mayor ticket.
  - **Tienda general:** mezcla de comida, decoración y objetos cotidianos; el tipo más flexible.
  - **Mercader viajero:** sin local fijo; aparece en días señalados con catálogo rodante (ítems raros, semillas fuera de temporada, curiosidades).
- **Concepto clave:** el tipo de tienda define comportamiento de catálogo y stock, pero los valores concretos viven en `.tres`; el código es genérico.

### 1.2 Tiendas como atributos de NPC
- **Dominio:** una tienda no es un objeto suelto: es una propiedad de un vecino (M19/M20). El jugador interactúa con el NPC dueño para comerciar.
- **Consecuencias:** la tienda hereda identidad del dueño (nombre, avatares, amistad M20); la amistad del jugador con el dueño afecta precios (delegado a M38) y catálogos especiales (ofertas de amistad).
- **Regla:** toda `ShopDefinition` referencia un `npc_duenio_id` válido del pueblo; la validación en editor verifica la existencia del NPC.

### 1.3 Catálogos por NPC
- **Dominio:** cada comerciante declara dos listas: ítems que vende (offsets hacia el jugador) e ítems que compra (recompra del jugador). No todo lo vendible se compra: la pescadería no recompra herramientas, la ferretería no recompra semillas.
- **Formato:** `ShopCatalog` con entradas `{item_id, slot_categoria, peso_rareza, stock_min, stock_max, restock_diario}`.
- **Concepto clave:** la recompra selectiva evita que cualquier ítem se pueda "descartar" en cualquier tienda; eso alimenta el loop cozy de darle la cosa correcta al comerciante correcto.

### 1.4 Horarios y días de descanso
- **Dominio:** cada tienda declara días abiertos (1-7, calendario M29), franja horaria (M30) y días de descanso (uno o dos por semana, configurables).
- **Consulta pura:** el estado abierto/cerrado es una función del día y la hora actuales; no hay estado interno frágil que pueda desincronizarse.
- **Mercaderes viajeros:** el "horario" es su calendario de aparición (días específicos, ferias M73, o probabilidad PRNG), no una franja diaria.
- **Concepto clave:** el cierre es un evento amable: la UI (M53) muestra el cartel "cerrado" y el horario de reapertura; nunca un castigo.

### 1.5 Stock y canalizaciones de stock (pipeline)
- **Dominio:** el stock no se edita a mano por día: se **genera** a partir de una canalización (pipelines) con etapas encadenadas y deterministas:
  1. **Definición base:** stock inicial de cada ítem del catálogo (rango min-max configurable).
  2. **Filtro estacional:** descarta o escala ítems fuera de temporada (M29).
  3. **Filtro de eventos:** aplica catálogo extendido o ítems especiales durante ferias (M73).
  4. **Aforo por rareza:** los ítems raros tienen menos ejemplares (peso en stock), los básicos tienen garantía de presencia.
  5. **Salida determinista:** el resultado se materializa con PRNG de partida (M29); misma semilla → mismo stock.
- **Reabastecimiento:** por día laborable se repone hasta los máximos, sin superar el tope declarado; los ítems vendidos se restan, los sobrantes se conservan (cozy: el stock no "se evapora" al dormir).
- **Concepto clave:** la canalización centraliza TODA la lógica de generación; los tipos de tienda solo aportan parámetros, no ramas de código.

### 1.6 Precios: dinámicos vs fijos
- **Dominio:** el módulo 38 define precios base por ítem (`PriceDefinition`) con variabilidad de mercado (±10%) y descuentos de amistad (hasta -15%).
- **Tiendas fijas:** operan con la variabilidad diaria de M38 (mercado del pueblo); el precio del día se calcula al amanecer con PRNG.
- **Mercaderes viajeros:** pueden pagar/vender con recargos fijos declarados (ej: +15% por ítem "exótico" o -10% por liquidación), siempre dentro de los topes de M38 (clamp final en el rango del ítem).
- **Precios jugador-vendedor:** dos direcciones: `precio_compra` (jugador paga) y `precio_venta` (jugador recibe). Siempre distintas (`venta < compra`, regla anti-aribitraje de M38). Este módulo jamás inventa un precio: solo consulta `PriceManager`.
- **Concepto clave:** la tienda es el "mostrador"; el precio es del ítem (M38), no del local.

### 1.7 Compra y venta
- **Dominio:** operaciones monetarias entre el jugador y el mostrador, con validaciones en cascada:
  - **Compra:** tienda abierta → stock suficiente → fondos suficientes (M38) → cupo en inventario (M14) → transacción atómica.
  - **Venta:** tienda abierta → ítem en inventario del jugador (M14) → la tienda recomprar ese ítem (catálogo) → transacción atómica (se quitan ítems, se depositan monedas).
- **Atomicidad:** o se mueven ambas partes (monedas e ítems) o ninguna; si falla el paso final se revierte todo y se emite señal de rechazo.
- **Límites:** los límites anti-grind y ventana de oferta viven en M38 (PriceManager), no aquí; este módulo solo respeta lo que M38 responde.

### 1.8 Renovación de stock
- **Dominio:** dos escalas: diaria (restock hasta máximos por día laborable) y estacional (el catálogo efectivo cambia con la estación).
- **Eventos:** la renovación se dispara por la señal `nuevo_dia_laborable` (M29) y, si corresponde, `estacion_cambio` (M29).
- **Mercaderes viajeros:** su renovación es la regeneración del catálogo rodante en cada aparición.

### 1.9 Eventos y ferias
- **Dominio:** durante ferias (M73), las tiendas fijas pueden ampliar catálogo (ítems especiales del evento) y los mercaderes viajeros aparecen con seguridad (días de feria = aparición garantizada).
- **Regla:** los efectos de eventos son temporales y reversibles; al terminar, el stock vuelve a la canalización normal del día siguiente.

### 1.10 Mercaderes viajeros
- **Dominio:** NPCs populares con calendario de aparición: ferias (garantizado), días fijos de semana (configurable) y probabilidad PRNG diaria (semilla M29).
- **Catálogo rodante:** generado por StockGenerator con pool propio (ítems raros, fuera de temporada, curiosidades), con recargos/descuentos declarados.
- **Persistencia:** el estado "mer_activo hoy" se guarda; si el jugador cierra y reabre el mismo día, el mercader sigue donde estaba.

## 2. Alternativas Consideradas

| Alternativa | Veredicto | Motivo |
|---|---|---|
| Stock infinito (catálogo sin límites) | **Descartado** | Mata la sensación de vida y de reabastecimiento; el stock finito hace que el pueblo "trabaje" |
| Stock definido a mano por día | **Descartado** | Imposible de mantener data-driven para decenas de ítems; errores y desbalance |
| Canalizaciones de stock (pipeline) | **Adoptado** | Centraliza generación, es determinista, testeable etapa por etapa y editable con recursos |
| Tiendas desligadas de NPCs (objetos sin dueño) | **Descartado** | Rompe la identidad cozy: el pueblo necesita caras, gustos y amistad (M20) |
| Precios definidos por la tienda | **Descartado** | Duplica lógica con M38; riesgo de divergencia; la regla del proyecto es un único dueño del precio |
| Mercaderes viajeros con inventario aleatorio puro | **Descartado** | Sin PRNG de partida rompe el determinismo de guardado/partida |
| Días de descanso fijos globales (todo el pueblo cierra el lunes) | **Descartado** | Monótono e irreal; cada tienda declara los suyos |
| Catálogo único por tipo de tienda | **Descartado** | Todos los puestos de semillas serían clones; el catálogo por NPC permite identidad propia |

## 3. Decisiones Clave

1. **D1 — Tiendas como atributos de NPCs:** toda `ShopDefinition` exige `npc_duenio_id`; el comercio ocurre contra el vecino (M19/M20), no contra un objeto anónimo.
2. **D2 — Tipos de tienda tipados pero data-driven:** los cinco tipos (SEMILLAS, PESCADERIA, FERRETERIA, GENERAL, VIAJERO) son constantes que el `ShopManager` usa para defaults; los valores reales viven en `.tres`.
3. **D3 — Catálogos por NPC:** `ShopCatalog` por comerciante con ítems ofrecidos y ítems recomprados; validación en editor de que el ítem exista en M15.
4. **D4 — Horarios consultados, no almacenados:** el estado abierto/cerrado es función pura de M29/M30; sin flags manuales.
5. **D5 — Canalización de stock determinista:** StockGenerator con 5 etapas (base → estación → eventos → aforo → PRNG); testeable y repetible con semilla.
6. **D6 — Reabastecimiento por mínimo/máximo:** se repone el stock diario hasta el máximo sin tirar sobrantes (los vendidos se restan; los que quedaron se conservan).
7. **D7 — Precios 100% delegados a M38:** `precio_compra`/`precio_venta` vienen de `PriceManager`; los mercaderes viajeros declaran recargos que M38 aplica dentro de sus topes.
8. **D8 — Transacciones atómicas:** o se mueven monedas e ítems o no se mueve nada; orden estricto (validar → mover inventario → mover monedas → señales) con reversión ante fallo.
9. **D9 — Mercaderes viajeros con calendario declarativo:** días fijos + ferias garantizadas + probabilidad PRNG diaria; catálogo rodante persistido por día.
10. **D10 — Eventos temporales reversibles:** los efectos de M73 se aplican como etapa extra de la canalización y se revierten con el cambio de día.

## 4. Riesgos y Mitigaciones

| Riesgo | Mitigación |
|---|---|
| Catálogo de M15 cambiante rompe referencias | Validación en editor: `item_id` inexistente → error accionable (misma estrategia que M38) |
| Stock infinitude por error de configuración (máximos gigantes) | Rangos min-max con clamp global y advertencia en log DOM-TIEN-CONFIG |
| Desincronización con M38 (precios distintos en tienda vs mercado) | D7: única fuente de precio (PriceManager); este módulo nunca calcula valores |
| Mercader viajero "atrapado" entre días (guardado en día de aparición) | Persistencia del calendario de aparición y del catálogo rodante; regeneración segura al cargar |
| Tienda abierta cuando debería estar cerrada (fechas límite) | D4: consulta pura a M29/M30; sin estado interno; tests de borde de hora exacta |
| Transacción a medias (monedas movidas sin ítems o viceversa) | D8: atomicidad estricta con rollback y señal de rechazo |
| Restock duplicado (doble señal del mismo día) | Idempotencia del restock: se registra `fecha_ultimo_restock` por tienda y se ignora si ya se reabasteció ese día |
| Feria que pisa el stock normal | La etapa de eventos se aplica DESPUÉS de la estacional y se revierte al día siguiente (D10) |

## 5. Modelo Conceptual (entidades)

- `ShopDefinition` (Resource): tienda → `shop_id`, `npc_duenio_id`, `tipo`, nombre i18n, horario, días de descanso, catálogo, pool del mercader (si VIAJERO), recargos.
- `ShopCatalog` (Resource): lista de `StockEntry` vendidos y lista de `item_id` recomprados.
- `StockEntry` (Resource): ítem del catálogo → `item_id`, `stock_min`, `stock_max`, `restock_diario`, `peso_rareza`, `temporadas: Array` (vacío = todas).
- `Shop` (RefCounted): instancia runtime de una tienda → `definicion`, `stock_actual: Dictionary`, `fecha_ultimo_restock`, `mer_activo` (si viajero), catálogo rodante materializado.
- `ShopManager` (autoload): registro de tiendas, orquestación compra/venta, señales, resto de consultas.
- `StockGenerator` (RefCounted/helper): canalización en 5 etapas; entrada = `ShopDefinition` + contexto (estación, eventos, PRNG); salida = stock materializado.
- `ShopUI` (script de escena, capa M53): consume señales y datos de ShopManager; no contiene lógica de negocio.

## 6. Relaciones con Otros Módulos

| Módulo | Relación |
|---|---|
| M38 (Economía) | Única fuente de precios (`PriceManager`), monedas (`EconomyManager`) y anti-grind; este módulo consulta y ejecuta contra ella |
| M14 (Inventario) | `agregar_items/remover_items` para mover ítems en compra/venta; cupo de inventario validado |
| M15 (Recursos/Ítems) | Los `item_id` de catálogos son claves de M15; la rareza alimenta el aforo de stock |
| M19 (Población) | `npc_duenio_id` debe existir en la población del pueblo |
| M20 (Amistad) | El dueño NPC puede ofrecer catálogo especial por amistad (vía M38 en precios) |
| M29 (Calendario) | Días de la semana, estaciones y PRNG; dispara restock, rotación y aparición de mercaderes |
| M30 (Reloj) | Hora actual para el estado abierto/cerrado |
| M53 (UI/UX) | Consume señales (`compra_exitosa`, `inventario_tienda_cambio`, etc.) y datos de catálogo |
| M73 (Eventos) | Ferias: mercaderes garantizados y catálogo extendido temporal |
| M104 (Analytics) | Registro de transacciones de tienda y patrones de compra |

## 7. Conclusión del Análisis

El sistema de tiendas de la isla Aurora será un conjunto de comercios vivos: atributos de NPCs con identidad propia, catálogos por comerciante, horarios y descansos consultados al calendario, stock generado por canalizaciones deterministas y reabastecido por día laborable, precios enteramente delegados a M38 y mercaderes viajeros que traen novedad sin romper la estabilidad. El diseño mantiene el desacoplamiento por señales, la atomicidad de transacciones y la filosofía cozy (nunca se pierde lo comprado; los básicos nunca faltan). Queda listo para implementar en Godot 4.x con GDScript tipado.