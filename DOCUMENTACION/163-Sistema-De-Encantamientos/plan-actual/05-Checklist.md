**Modelo:** mimo-v2.6-flash-free (último modificador; base step-3.7-flash / GLM-5.3 Flash)
**Plataforma:** opencode
**Fecha:** 2026-10-07 05:08

# 05-Checklist.md — Modulo 163: Sistema de Encantamientos

> **Modelo:** stepfun-3.7-flash
> **Plataforma:** Kilo Code
> **Fecha:** 2026-09-02
> **Estado:** 🟡 Con dudas — liberado 2026-09-02 23:31

## Reserva actual

| Campo | Valor |
|-------|-------|
| Módulo | M163 Sistema De Encantamientos |
| Agente | **mimo-v2.6-flash-free** (iter. 2 Sección C: asignada 2026-10-07 04:12 por atria-dawn-preview, plan OK con opción A; iter. 1 Sección B aceptada 2026-10-07 03:27; anterior: step-3.7-flash → glm-5.3-flash, liberado 2026-09-02) |
| Fase | F5 |
| Dificultad | 3 |
| Visión | V0 |
| Entrada | M13 core ✅, M159 ✅, M158 pendiente (no bloquea núcleo) |
| Salida | EnchantmentSystem autoload + EnchantmentData Resource + 4 .tres + tests headless |
| Archivos afectados | `game/isla-ancestral/scripts/enchantment/`, `game/isla-ancestral/data/enchantments/`, `project.godot` |

## A. Definicion del Sistema (15)

- [x] Definir problema: capa de progresion lateral para herramientas [S]
- [x] Definir 4 encantamientos por tier (Cobre Ancestral, Hierro Prospero, Oro Brillante, Cristal de Caverna) [S]
- [x] Encantamiento es permanente y no se puede remover [S]
- [x] Cualquier tier se puede encantar (sin restriccion) [S]
- [x] Sistema es OPCIONAL: ningun contenido lo requiere obligatoriamente [S]
- [x] Documentar habilidades por tier en 01-Requerimientos [M]
- [x] Documentar costos por tier (incienso + monedas) [M]
- [x] Definir visual por encantamiento (brillo, color, particulas) [M]
- [x] Definir flujo completo del jugador [S]
- [x] Definir integracion con M14 (Inventario) [M]
- [x] Definir integracion con M39 (Tiendas para venta) [M]
- [x] Definir integracion con M13 (Herramientas base) [M]
- [x] Definir integracion con M158 (Tiers) [M]
- [x] Documentar alternativas descartadas [S]
- [x] Documentar decisiones de diseno [S]

## B. Chamán del Monte (20)

- [x] Crear ShamanNPC.gd como InteractableBase (Node3D) [M]
- [x] Definir posicion del chaman (Isla Raiz, montaña remota) [S]
- [x] Definir dialogo del chaman (M21) [M] (data/dialogues/shaman_intro|regreso|todas.json; validados por DialogueGraph.validate() + validador M21 en suite B)
- [x] Crear ShamanUI.gd como Control básico [M]
- [x] ShamanUI muestra herramientas encantables del jugador [M] (shaman_ui.gd: ids_herramientas + _cargar_herramientas con filtro ItemData.Categoria.HERRAMIENTAS; suite C8)
- [x] ShamanUI muestra costo en incienso y monedas por tier [S] (_actualizar_info (incienso/monedas OK|FALTA) + boton con [T?] y costos; suite C9)
- [x] ShamanUI valida incienso suficiente antes de encantar [M] (encantar_seleccion() con system.has_incense; suite C24/C25)
- [x] ShamanUI valida monedas suficientes antes de encantar [M] (_puede_pagar/_retirar via EconomyManager — corrige bug GLM del item "moneda" inexistente; suite C26/C27)
- [x] Animacion de encantamiento (brillo, sonido, particulas) [M] (_exito: tween flash del panel + CPUParticles2D one-shot teñido con visual_color + beep procedural AudioStreamWAV 660→880 Hz; suite C10)
- [x] Feedback visual al encantar exitosamente [S] (label verde en _exito; suite C14)
- [x] Feedback visual al no tener recursos [S] (label rojo en _fallo: seleccion/recursos/ya encantada; suite C23/C25/C27)
- [x] El chaman tiene dialogo contextual segun progresion [M] (shaman_npc.interactuar elige intro/regreso/todas; suite C5/C16/C20)
- [x] El chaman recuerda cuantas veces encantaste [S] (EnchantmentSystem.encantos_totales + session {encantos} en start_dialogue; suite C6/C17)
- [x] El chaman tiene frase especial si encantas todas las herramientas [S] (todas_encantadas() + dialogo shaman_todas; suite C19/C20)
- [?] Integrar chaman con M19 (NPCs y Vecinos) [M] — dueño: AGENTE DELEGADO M19 (requiere M19 completado; fuera del alcance de iter 1)
- [?] Integrar chaman con M162 (Dialogos contextuales) [M] — dueño: AGENTE DELEGADO M162 (los 3 dialogos locales existen; la integracion con el registro contextual de M162 la cierra ese modulo)
- [?] El chaman aparece en mapa de ubicaciones (M160) [S] — dueño: AGENTE DELEGADO M160 (requiere M160; posicion fija disponible: 320, 35, 300)
- [?] El chaman tiene rutina diaria (M19) [M] — dueño: AGENTE DELEGADO M19 (diseno de rutina pendiente; L64 fija su ubicacion)
- [x] El chaman se puede visitar en cualquier momento del dia [S] (shaman_npc no define requisitos de horario: InteractableBase.requisitos_cumplidos sin filtro de hora; E siempre despacha, suite C4/C16/C20)
- [x] El chaman no se mueve de su ubicacion (vive en la montaña) [S]

## C. Incienso (15)

- [x] Crear IncenseCultivation.gd como Resource [M] (scripts/enchantment/incense_cultivation.gd; suite B1-B16)
- [x] Definir incienso basico: se cultiva en plantas de montaña [S] (incense_point.gd: planta InteractableBase categoria cosecha que nace plantado; D1-D4; runtime real 6/6 en montaña)
- [x] Definir incienso raro: se obtiene en eventos estacionales [S] (punto con raro=true + incense_rare.tres; D10-D16)
- [x] Tiempo de cultivo: 3 dias del juego para cosecha [M] (IncenseCultivation.DIAS_COSECHA=3 sobre GameTime.dia_absoluto; B6/B7/B8, C6-C8)
- [x] Rendimiento: 2-4 incienso por cosecha [S] (RENDIMIENTO_MIN/MAX con rng diario inyectable; B9, C9)
- [x] Crear IncenseSpawner.gd como Node3D [M] (incense_spawner.gd extends Node3D, spawneo determinista seed 163; D1)
- [x] Spawner genera puntos de incienso en montaña de Isla Raiz [M] (centro = MundoRaiz.CENTRO-(240,260) como _crear_shaman, alturas via TerrainLocator; D2-D5 + runtime: '6 puntos, 0 fallas, centro (2320, 2300)')
- [x] Los puntos se renuevan cada 3 dias del juego [M] (IncensePoint.renovar + IncenseSpawner._on_dia_cambio conectado a GameTime.dia_cambio; D7/D8, C13-C17)
- [x] Incienso se guarda en inventario (M14) como item [S] (data/items/incense.tres + incense_rare.tres auto-cargados por ItemDatabase; add/count/remove; A1-A13, C9, D15)
- [x] Incienso tiene stack_max de 99 [S] (A3/A4)
- [x] Incienso es renewable: nunca se agota [S] (cosecha limpia lote y renovacion a los 3 dias; B11, C16-C17)
- [x] Eventos estacionales dan incienso raro (M29) [M] (IncenseSpawner._on_estacion_cambio conectado a GameTime.estacion_cambio de M29 sin tocar M29; D10-D12)
- [?] Incienso se puede regalar a NPCs (M19) [S] - dueño: AGENTE DELEGADO M19 (no existe sistema de regalos/afinidad; el item ya existe en M14 para cuando M19 lo habilite)
- [x] Incienso tiene precio de venta bajo (no es para vender) [S] (precio_venta=5 incense / 20 rare; A8)
- [x] Incienso tiene descripcion tematica [S] (descripcion en ambos .tres; A9)

## D. Encantamientos por Tier (30)

- [ ] Cobre Ancestral: intercambio especial + bonus adicional [M]
- [ ] Cobre Ancestral: brillo naranja suave en filo [S]
- [ ] Cobre Ancestral: costo 3 incienso + 200 monedas [S]
- [ ] Cobre Ancestral: animacion de encantamiento 2s [S]
- [ ] Hierro Prospero: x2 monedas al romper minerales [M]
- [ ] Hierro Prospero: brillo gris con particulas [S]
- [ ] Hierro Prospero: costo 5 incienso + 500 monedas [S]
- [ ] Hierro Prospero: animacion de encantamiento 3s [S]
- [ ] Oro Brillante: +50% precio venta en tiendas [M]
- [ ] Oro Brillante: brillo dorado intenso [S]
- [ ] Oro Brillante: costo 8 incienso + 800 monedas [S]
- [ ] Oro Brillante: animacion de encantamiento 4s [S]
- [ ] Cristal de Caverna: bonus extraccion cuevas [M]
- [ ] Cristal de Caverna: brillo azul cristalino [S]
- [ ] Cristal de Caverna: costo 12 incienso + 1000 monedas [S]
- [ ] Cristal de Caverna: animacion de encantamiento 5s [S]
- [ ] Cada encantamiento tiene icono unico [S]
- [ ] Cada encantamiento tiene descripcion unica [S]
- [ ] Cada encantamiento tiene nombre localizable [S]
- [ ] Las habilidades se activan automaticamente al equipar [M]
- [ ] Las habilidades no se pueden desactivar [S]
- [ ] Una herramienta solo puede tener 1 encantamiento [S]
- [ ] No se puede encantar una herramienta ya encantada [S]
- [ ] El encantamiento se hereda al mejorar la herramienta [M]
- [ ] El encantamiento se conserva al reparar [S]
- [ ] El encantamiento se pierde al descartar la herramienta [S]
- [ ] El encantamiento se conserva al guardar/cargar [M]
- [ ] Integrar con M13 (mejoras Afilar/Templar/Potenciar) [M]
- [ ] Las mejoras y encantamientos son compatibles [S]
- [ ] Documentar tabla completa de encantamientos [S]

## E. Venta de Encantamientos (15)

- [ ] Mercader de rarezas (Aurora): compra cualquier encantado +100% [M]
- [ ] Herrero (Ceniza): compra Hierro Prospero +80% [S]
- [ ] Sabio (Aurora): compra Cristal de Caverna +120% [S]
- [ ] Sanador (Coral): compra Cobre Ancestral +60% [S]
- [ ] Precio de venta = base_price * (1 + bonus_encantamiento) [M]
- [ ] La venta requiere herramienta encantada en inventario [S]
- [ ] La venta consume la herramienta encantada [S]
- [ ] La venta da monedas al jugador [S]
- [ ] La venta se registra en M38 (Economia) [M]
- [ ] Las tiendas tienen stock limitado de compra [S]
- [ ] Las tiendas se reponen semanalmente [S]
- [ ] El jugador recibe notificacion al vender [S]
- [ ] El jugador puede cancelar la venta [S]
- [ ] Integrar con M39 (Tiendas) [M]
- [ ] Documentar tabla de precios de venta [S]

## F. Visual y Efectos (15)

- [ ] Cada encantamiento tiene efecto de particulas unico [M]
- [ ] Cobre Ancestral: particulas naranjas sutiles [S]
- [ ] Hierro Prospero: particulas grises brillantes [S]
- [ ] Oro Brillante: particulas doradas intensas [S]
- [ ] Cristal de Caverna: particulas azules cristalinas [S]
- [ ] Efecto visible en mano del jugador [M]
- [ ] Efecto visible en inventario (icono con brillo) [S]
- [ ] Sonido de encantamiento unico por tier [M]
- [ ] Sonido de activacion de habilidad [S]
- [ ] Animacion de encantamiento en chaman [M]
- [ ] Animacion de intercambio especial (Cobre Ancestral) [M]
- [ ] Sin efecto visual al no tener encantamiento [S]
- [ ] Los efectos no impactan rendimiento (pool de particulas) [M]
- [ ] Los efectos se desactivan lejos del jugador [S]
- [ ] Documentar efectos visuales en03-Diseno [S]

## G. Persistencia e Integracion (10)

- [ ] Encantamientos guardados en GameState.M163 [M]
- [ ] to_dict/from_dict para encantamientos [M]
- [ ] El encantamiento se conserva al guardar/cargar [M]
- [ ] El encantamiento se conserva al viajar entre islas [S]
- [ ] El encantamiento se conserva al respawnear [S]
- [ ] Integrar con M59 (Guardado) [M]
- [ ] Integrar con M14 (Inventario) [M]
- [ ] Integrar con M71 (Progresion) [S]
- [ ] Integrar con M72 (Logros) [S]
- [ ] Logro "Primera herramienta encantada" [S]

## Progreso iter 1 (2026-09-02 — GLM-5.3 Flash / Kilo Code)

- [x] Sección A completada (15/15): sistema data-driven con 4 encantamientos .tres, EnchantmentSystem autoload, EnchantmentData Resource, API de lectura en inventario_service.gd
- [x] Sección B en progreso (4/20): shaman_npc.gd como InteractableBase, posición en Isla Raíz (320, 11, 300), shaman_ui.gd como Control básico, NPC spawneado en main_island.gd y registrado en escena
- [x] Errores corregidos: class_name EnchantmentSystem en autoload eliminado, tipo EnchantmentData cambiado a Resource, rutas .tres ajustadas a res://, inferencia de tipo en TerrainLocator.get_height() corregida, posición del NPC reordenada antes de add_child()
- [x] Siguientes pasos: probar interacción real con chamán en runtime, crear diálogo shaman_intro en data/dialogues/, implementar sección C (Incienso) y D (Encantamientos por Tier), integrar con tiendas M39 y economía M38

**Notas del Agente**

**Modelo:** GLM-5.3 Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 03:58
**Estado:** Parcial — Sección A completada, Sección B iniciada (4/20)

### Lo que hice
- Implementé el núcleo data-driven de encantamientos: EnchantmentSystem autoload, EnchantmentData Resource, 4 archivos .tres de prueba.
- Creé shaman_npc.gd como InteractableBase con posición fija en Isla Raíz.
- Creé shaman_ui.gd como Control básico para futura interfaz de encantamientos.
- Integré el spawn del chamán en main_island.gd y registré el NPC en la escena.
- Corregí errores de parsing, rutas y tipos en scripts y .tres.

### Lo que NO pude hacer
- Interacción real con el chamán en runtime: pendiente probar el flujo completo de presionar E y abrir UI.
- Diálogo shaman_intro: requiere datos en data/dialogues/ e integración con M21/M162.
- Sección C (Incienso): cultivo, spawner, items y eventos estacionales.
- Sección D (Encantamientos por Tier): efectos, animaciones, integración con M13 mejoras.

### Recomendaciones para el próximo agente
- Revisar CHECKLIST-GLOBAL.md y ESTADO-PARALELO.md para coordinar.
- Priorizar interacción real chamán-jugador antes de ampliar secciones C/D.
- Usar V4 (godot-mcp) para capturas de prueba de la UI de encantamientos.
- Consultar DOCUMENTACION/GUIA-GODOT/INDICE.md para pitfalls conocidos de Godot 4.x.
## Progreso — Seccion B (iter. 1 de mimo-v2.6-flash-free, 2026-10-07)

- Seccion B completada (16/20 en esta iter: 4 [x] previos de GLM + 12 [x] nuevos; restantes 4 [ ] pasan a [?] con dueno)
- Flujo real del chaman E2E: E -> DialogueManager (intro/regreso/todas) -> ShamanUI -> encantar con cobro EconomyManager
- Corregidos 4 bugs: to_dict no serializaba enchantment_<tool_id> (A15); item_db.Categoria invalido en shaman_ui (x2, rompia la lista de herramientas); _actualizar_info pisaba el feedback de exito (C14); bug GLM de monedas via item "moneda" inexistente -> EconomyManager
- Suite ampliada test_enchantment.gd: 58 checks / 0 fallos / exit 0 (unit A + validadores B + E2E C + 8 checks negativos)
- Sonda roja obligatoria: guard de incienso en enchant_tool mutado -> A9 falla exit 1 -> restaurado -> 58/0 exit 0
- 3 dialogos locales creados y validados (shaman_intro, shaman_regreso con {encantos}, shaman_todas)

## Progreso — Seccion C (iter. 2 de mimo-v2.6-flash-free, 2026-10-07 05:08)

- Seccion C completada: 14 [x] con cita + 1 [?] (L80 regalar NPCs → dueño M19).
- `incense_cultivation.gd` (Resource: 3 dias, 2-4, RNG diario M29), `incense_point.gd` (InteractableBase categoria cosecha, cadena E), `incense_spawner.gd` (Node3D: centro montaña = formula de _crear_shaman, alturas TerrainLocator, seed fija 163, renovacion via dia_cambio, raro via estacion_cambio).
- 2 items: `data/items/incense.tres` (stack 99, cat ITEMS, precio 5) + `incense_rare.tres` (rareza RARO, precio 20).
- `main_island.gd` opcion A AUTORIZADA (msg 53): +1 linea en _ready + funcion `_crear_incense_spawner()`; diff exacto informado en el informe de cierre.
- Suite nueva `test_incienso.gd`: **67 checks / 0 fallos / exit 0** con CHECKS_MINIMOS MEDIDO = 67; regresion `test_enchantment.gd` **58/0 exit 0**.
- 2 sondas rojas obligatorias con EXIT=1 verificado y restauracion byte-exacta: (1) guard de cosecha antes de tiempo mutado → 3 FAIL; (2) guard de doble plantado mutado → 1 FAIL.
- Runtime real headless: `[M163] IncenseSpawner: 6 puntos en montaña (0 fallas de altura, centro (2320.0, 2300.0))` — sin [?] de terreno (condicion 3 del msg 53 no se activo).
- Estacionalidad cableada a `GameTime.estacion_cambio` (M29) SIN tocar M29 → C12 queda [x] (mejor que la meta aprobada).

**Notas del Agente (iter. 1 — Seccion B)**

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-07 03:05
**Estado:** Parcial — Seccion B cerrada (35 [x] / 4 [?] / 85 [ ]); secciones C-G intactas

### Lo que hice
- Cierre de la seccion B (12 [x] con cita + 4 [?] con dueno nombrado, criterio del director msg 49).
- Codigo: enchantment_system.gd (contador encantos, todas_encantadas, persistencia to_dict/from_dict), shaman_ui.gd (tier, monedas EconomyManager, encantar_seleccion testeable, feedback brillo/particulas/sonido), shaman_npc.gd (dialogo por progresion con session {encantos}).
- 3 dialogos locales en data/dialogues/ validados por DialogueGraph.validate() y el validador M21 (0 claves desconocidas).
- Test: reescritura completa de test_enchantment.gd (58 checks: unit, validadores, E2E cadena E, 8 negativos). Sonda roja ejecutada y revertida.
- Bugs corregidos en codigo de GLM: to_dict/from_dict incompleto; item_db.Categoria invalido x2; orden feedback vs _actualizar_info; cobro de monedas con item "moneda" inexistente.

### Lo que NO pude hacer (honestidad obligatoria)
- 4 items quedaron [?] con dueno: L59/L62 (M19), L60 (M162), L61 (M160) — dependen de otros modulos.
- Feedback visual verificado por estado de la UI en headless, NO visualmente (M154 V0: sin via de vision en este chat; capturas pendientes si el director las requiere).
- interaction_manager.gd NO se toco (cuarentena kimi): la cadena E funciona con el patron oficial de M70 (llamada manual a _evaluar_y_seleccionar; el _process del manager no corre en tests --script — hallazgo documentado aqui).

### Intentos fallidos / decisiones
- _process del InteractionManager no corre en tests --script (igual que el test M70 lo asume): solucion = _evaluar_y_seleccionar() manual antes de cada E, no es bug del juego.
- La seccion A deja encantos_totales > 0 global: el E2E resetea estado con from_dict limpio antes de C para probar la primera visita.

### Recomendaciones para el próximo agente
- Siguientes iteraciones: seccion C (Incienso) y D (Encantamientos por Tier) — intactas.
- Si se quiere ver el feedback en vivo, correr con V4 (godot-mcp) y capturar; la UI es un Control hijo de UIRoot.
- La sonda roja se hizo mutando enchant_tool; repetirla al tocar esa funcion.

**Notas del Agente (iter. 2 — Seccion C)**

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-07 05:08
**Estado:** Parcial — Seccion C cerrada (49 [x] / 5 [?] / 70 [ ]); seccion D intacta

### Lo que hice
- Cierre de la seccion C: 14 [x] con cita de suite/runtime + 1 [?] (L80, dueño M19).
- Meta aprobada 48 [x] + hasta 2 [?]: real 49 [x] + 1 [?] — C12 (estacionalidad M29) cableo, no quedo [?].
- Runtime real verificado: 6/6 puntos sobre la montaña con TerrainLocator real (0 fallas de altura), sin hardcode de radio/centro de isla (check anti-P39 en suite D5/D6).
- `main_island.gd` tocado SOLO en lo autorizado (opcion A, msg 53): llamada `_crear_incense_spawner()` en _ready + 9-linea de la funcion al final. `_crear_shaman()` intacto.

### Lo que NO pude hacer (honestidad obligatoria)
- L80 regalar incienso a NPCs → [?] dueño M19 (no existe sistema de regalos/afinidad).
- Verificado en headless, NO visualmente (M154 V0: sin via de vision en este chat).
- Persistencia de los puntos del spawner (M59) NO implementada: los 15 items de C no la piden; si se guarda/carga partida, los puntos se regeneran con su spawneo determinista (seed 163), no se serializa estado de cosecha. Documentado como mejora futura.

### Intentos fallidos / decisiones
- class_name nuevo no se registra hasta refrescar el cache: `godot --headless --path ... --editor --quit` (sin eso, el test moria con "Identifier IncenseCultivation not declared").
- `var gt := _game_time()` con funcion sin `-> Node` producia Parse Error "Cannot infer the type" y tumbo la suite; corregido tipando el retorno.
- Un `--script` con error de carga NO sale: Godot ejecuta el juego normal (colgado 75s) — capturar siempre con archivo + timeout.
- Guard `dia_agotado < 0` rompia con dia_absoluto bajo en tests (dia 1 - 3 = -2) → guard `== -1`.

### Recomendaciones para el próximo agente
- Siguiente: seccion D (Encantamientos por Tier) — intacta, 32 [ ].
- Si se necesita persistir puntos de incienso, agregar get_save_data/restore al spawner registrandolo como ISaveProvider (patron GameTime/resource_spawner).
- Repetir las 2 sondas rojas al tocar los guards de `IncenseCultivation`.

**Totales:** 124 ítems · Completados: 49 · Pendientes: 70 · No resueltos: 5.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 23 [x] / 101 [ ] / 0 [?].
> Las marcas no se tocaron.
