**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 38: Economía

## ID del Módulo
- **Código:** M38 (CHECKLIST-GLOBAL: ID 38 — Economía)
- **Carpeta:** `DOCUMENTACION/38-Economia/`
- **Dependencias:** M15 (Recursos), M16 (Crafting), M20 (Sistema de Amistad)
- **Delegable desde:** hoy (diseño completo; la implementación requiere el catálogo de ítems de M15, las recetas de M16 y los gustos de regalos de M20)

## 1. Problema

La isla Aurora es un mundo cozy tipo Stardew Valley: el jugador recolecta recursos (M15), elabora objetos (M16) y construye amistad con los vecinos (M20). Sin un sistema económico, todo ese trabajo no tiene valor de cambio: el jugador no puede convertir su esfuerzo en mejores herramientas, decoración o progreso, y el pueblo no se siente vivo. Pero una economía agresiva rompería la promesa cozy: precios que castigan, inflación incontrolable, deuda estresante o grind obligatorio destruirían el tono del juego. Se necesita un sistema de comercio tranquilo con la comunidad del pueblo: moneda simple, precios estables y amables, tiendas con horarios, trueque con NPCs y un mercado que reaccione suavemente a la oferta sin nunca volverse hostil.

## 2. Objetivo

Diseñar el sistema económico del juego: una moneda única (`monedas_aurora`), catálogo de precios data-driven, tiendas de los vecinos con inventario y horarios, trueque con NPCs (objeto por objeto, ligado a la amistad de M20), y un mercado del pueblo donde los precios varían suavemente por estación y por oferta, con una regla inquebrantable: el jugador nunca queda en bancarrota ni bloqueado; siempre hay un camino económico para avanzar sin estrés.

## 3. Alcance

### 3.1 Dentro del alcance
- Moneda del juego: definición, emisión y persistencia del saldo del jugador.
- Catálogo de precios: valores de compra y venta data-driven para todos los ítems del juego (recursos M15, productos de crafting M16, regalos M20).
- Tiendas de los vecinos: inventario fijo por NPC, horarios de atención diarios, compra y venta, reabastecimiento por días laborables (M29/M30 calendario).
- Trueque con NPCs: intercambio directo de ítems (sin moneda), con reglas de afinidad por amistad (M20) y por temporada.
- Mercado del pueblo: precios dinámicos suaves basados en oferta reciente, estación y evento; tabla pública de precios del día.
- Comercio con el jugador como vendedor: precios de venta por ítem, límites diarios anti-grind cozy.
- Persistencia del estado económico: saldo, reputación comercial, historial de ventas recientes, estado de inventarios de tiendas.
- Integración con M15 (ítems vendibles), M16 (productos de valor), M20 (descuentos y trueques por amistad).

### 3.2 Fuera del alcance
- La UI de comercio (paneles de tienda, carrito, menú de trueque) pertenece al módulo de UI/UX (M53).
- El sistema de misiones económicas (pedidos del tablón) pertenece a historias secundarias (M23).
- La economía de construcción (costos de M17) solo consume precios; no genera precios propios.
- El sistema bancario/deuda: descartado por diseño (el juego no tiene deudas ni créditos).
- Mascotas, impuestos o subastas multijugador: fuera de la visión cozy single-player.

## 4. Restricciones

- **Motor:** Godot 4.x (>= 4.4.1), GDScript tipado explícito, sin C#.
- **Mundo voxel:** la economía no modifica el mundo; solo lee cantidades de M15 y entrega ítems.
- **Tono cozy:** ninguna mecánica puede generar estrés económico (sin deuda, sin inflación fuera de control, sin perder objetos por no pagar).
- **Data-driven:** todos los precios, inventarios de tienda y ofertas de trueque viven en recursos `.tres`, editables sin tocar código.
- **Desacoplamiento:** el módulo no conoce la UI; comunica resultados por señales (sección 9 de AGENTS.md). Los autoloads de economía son consumidos por managers de UI.
- **Persistencia:** el estado económico se guarda con la partida junto a M15/M16/M20, coherente con el PRNG de partida (M29).
- **Sin servidores:** todo es local; no hay economía simulada en red.

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Moneda única | `monedas_aurora`: saldo entero no negativo persisted, consultable y modificable solo a través del EconomyManager |
| RF2 | Catálogo de precios | PriceDefinition por ítem: precio_compra_base, precio_venta_base, descuento_amistad_max, variabilidad_mercado; catálogo central `.tres` |
| RF3 | Compra en tiendas | Tienda NPC recibe monedas y entrega ítems; valida fondos, inventario y horario; señala resultado |
| RF4 | Venta en tiendas | El jugador vende ítems a precio de venta; con límite diario de ventas de un mismo ítem (anti-grind) |
| RF5 | Reabastecimiento | Inventarios de tiendas se restauran por día laborable (M29/M30); objetos de temporada rotan por estación |
| RF6 | Horarios | Cada tienda declara horario (días y franja horaria); fuera de horario el comercio se cierra (señal de cierre) |
| RF7 | Trueque | Intercambio objeto por objeto (o packs) sin moneda; propuestas dependen de amistad (M20) y temporada |
| RF8 | Factor amistad | Nivel de amistad con el NPC (M20) otorga descuentos o mejores ofertas de trueque; también activa ofertas únicas |
| RF9 | Mercado del pueblo | Precios base del día se ajustan suavemente por oferta reciente (ventas del jugador) y estación; ajuste ±10% máximo |
| RF10 | Tabla de precios del día | El juego expone los precios vigentes del día para mostrar en el mercado sin UI propia |
| RF11 | Anti-grind | Límite diario de venta por ítem; precios de reventa siempre menores al de compra; sin préstamos ni intereses |
| RF12 | Regla anti-quiebra | El jugador nunca pierde acceso a la tienda por falta de fondos; si tiene 0 monedas, los NPC ofrecen trueque de partida (trueque mínimo con bienes comunes) |
| RF13 | Persistencia | Saldo, reputación, historial de ventas recientes (ventana de oferta) e inventarios de tienda se guardan y restauran |
| RF14 | Eventos | Ferias y eventos de temporada (M73) pueden aplicar precios especiales temporales (ej: feria duplica valor de ciertos productos) |
| RF15 | Registro de transacciones | Log de cada transacción (compra, venta, trueque) para debugging y analytics (M104) |

## 6. Requisitos No Funcionales

- **Cozy:** cero penalizaciones duras; la pobreza no existe; el sistema garantiza un camino de ingresos básico (venta de excedentes o trueque de partida).
- **Tranquilidad:** precios estables a corto plazo; cambios de mercado lentos y anunciados (nunca de la noche a la mañana sin aviso).
- **Rendimiento:** la economía es un sistema discreto por eventos (transacción, cambio de día); sin bucles por frame; lecturas de precio en O(1) con diccionarios.
- **Determinismo:** los precios del día se calculan con PRNG de partida (M29) para coherencia entre sesiones.
- **Data-driven:** listas de ítems vendibles, precios, horarios y ofertas en `.tres`; validación en editor con errores accionables.
- **Desacoplamiento:** autoloads puros de datos y lógica; sin referencias a nodos de UI; integración por señales.
- **Localización:** nombres de tiendas, NPCs y objetos listos para i18n (claves string en catalogo de traducción).
- **Godot 4.x (>= 4.4.1):** GDScript tipado, recursos `Resource`, señales del core, `RefCounted` para helpers.

## 7. Criterios de Aceptación

1. El jugador compra y vende en al menos 3 tiendas del pueblo con monedas que persisten entre sesiones.
2. Un ítem de M15 y un producto de M16 se venden a los precios definidos por su PriceDefinition sin discrepancias.
3. El trueque con un NPC de amistad alta (M20) ofrece mejores propuestas que con uno de amistad baja.
4. El mercado varía precios dentro de ±10% por día, sin valores negativos y con aviso en la tabla del día.
5. Vendiendo el límite diario de un ítem, el mercado no permite seguir farmeando el mismo ítem ese día (anti-grind).
6. Con 0 monedas, el jugador aún tiene al menos una vía económica viable (trueque de partida) y sin mensajes de fracaso.
7. Tras guardar/cargar, el saldo, los historiales y los inventarios de tienda coinciden exactamente.
8. Durante una feria (M73), los precios especiales se aplican y se revierten correctamente al terminar.

## 8. Fuentes de Contexto (plan maestro)

- Plan maestro: economía sana y tranquila; el dinero no es el objetivo, es una herramienta de comunidad.
- El pueblo debe "sentirse vivo": tiendas con horarios y personas con gustos (M20).
- Los precios son amables: vender lo que uno cultiva o pesca debe ser rentable sin inflar el saldo.
- La moneda del juego se concibe como "monedas de la isla" (monedas_aurora), sin deuda ni banca.
---

## 9. EXPANSIONES DEL MODULO 158 (2026-08-22)

### 9.1 Moneda Unificada Multi-Isla

La misma moneda (monedas_aurora) se usa en TODAS las islas. No hay monedas separadas por isla.

### 9.2 Fuentes de Ingreso del Jugador

| Fuente | Cantidad | Frecuencia | Maximo estimado |
|--------|----------|------------|-----------------|
| Jarrones | 5-15 monedas | Semanal (cada 7 dias M29) | ~150/semana |
| Peces dorados | 1-5 monedas | Diario | ~15/dia |
| Arboles frutos dorados | 2-8 monedas | Diario | ~40/dia |
| Puzzles resueltos | 50-200 monedas | Unico | ~3000 total |
| Vender herramientas (NPCs) | 10-80 monedas | 1x/dia | ~80/dia |
| Vender en tienda | Variable | Diario | Segun items |
| Premium (Steam) | Variable | Instantaneo | Sin limite |

### 9.3 Precios Escalonados por Isla

| Isla | Profesion | T2 | T3 | T4 | Curso |
|------|-----------|-----|-----|-----|-------|
| Principal | Carpinteria | 100 | 500 | 2000 | 300 |
| Isla 2 | Herreria | 500 | 2000 | 5000 | 1500 |
| Isla 3 | Herreria Avanzada | 1000 | 4000 | 8000 | 5000 |
| Isla 4 | Encantamiento | 2000 | 8000 | 15000 | 10000 |

### 9.4 Compra Premium (Steam)

- Paquete 500 monedas (.99 USD)
- Paquete 2000 monedas (.99 USD)
- Paquete 5000 monedas (.99 USD)
- Monedas premium = monedas normales (misma moneda)
- Premium NO compra herramientas directamente

### 9.5 Regla Anti-Frustracion

- No pagar: puzzles, pescar, jarrones = avance lento pero seguro
- Pagar: avanza mas rapido pero recorre todo el mapa
- Jarrones se reponen semanalmente
- Peces y frutos aparecen diariamente
- Nunca hay bloqueo economico permanente
