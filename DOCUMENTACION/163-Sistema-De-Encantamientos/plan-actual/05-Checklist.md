**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 05-Checklist.md — Modulo 163: Sistema de Encantamientos

> **Modelo:** stepfun-3.7-flash
> **Plataforma:** Kilo Code
> **Fecha:** 2026-09-02 02:10
> **Estado:** 🔵 En curso — iter. 1 núcleo data-driven + chamán integrado en escena

## Reserva actual

| Campo | Valor |
|-------|-------|
| Módulo | M163 Sistema De Encantamientos |
| Agente | stepfun-3.7-flash (Kilo Code) |
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
- [ ] Definir dialogo del chaman (M21) [M]
- [x] Crear ShamanUI.gd como Control básico [M]
- [ ] ShamanUI muestra herramientas encantables del jugador [M]
- [ ] ShamanUI muestra costo en incienso y monedas por tier [S]
- [ ] ShamanUI valida incienso suficiente antes de encantar [M]
- [ ] ShamanUI valida monedas suficientes antes de encantar [M]
- [ ] Animacion de encantamiento (brillo, sonido, particulas) [M]
- [ ] Feedback visual al encantar exitosamente [S]
- [ ] Feedback visual al no tener recursos [S]
- [ ] El chaman tiene dialogo contextual segun progresion [M]
- [ ] El chaman recuerda cuantas veces encantaste [S]
- [ ] El chaman tiene frase especial si encantas todas las herramientas [S]
- [ ] Integrar chaman con M19 (NPCs y Vecinos) [M]
- [ ] Integrar chaman con M162 (Dialogos contextuales) [M]
- [ ] El chaman aparece en mapa de ubicaciones (M160) [S]
- [ ] El chaman tiene rutina diaria (M19) [M]
- [ ] El chaman se puede visitar en cualquier momento del dia [S]
- [x] El chaman no se mueve de su ubicacion (vive en la montaña) [S]

## C. Incienso (15)

- [ ] Crear IncenseCultivation.gd como Resource [M]
- [ ] Definir incienso basico: se cultiva en plantas de montaña [S]
- [ ] Definir incienso raro: se obtiene en eventos estacionales [S]
- [ ] Tiempo de cultivo: 3 dias del juego para cosecha [M]
- [ ] Rendimiento: 2-4 incienso por cosecha [S]
- [ ] Crear IncenseSpawner.gd como Node3D [M]
- [ ] Spawner genera puntos de incienso en montaña de Isla Raiz [M]
- [ ] Los puntos se renuevan cada 3 dias del juego [M]
- [ ] Incienso se guarda en inventario (M14) como item [S]
- [ ] Incienso tiene stack_max de 99 [S]
- [ ] Incienso es renewable: nunca se agota [S]
- [ ] Eventos estacionales dan incienso raro (M29) [M]
- [ ] Incienso se puede regalar a NPCs (M19) [S]
- [ ] Incienso tiene precio de venta bajo (no es para vender) [S]
- [ ] Incienso tiene descripcion tematica [S]

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
- [ ] Siguientes pasos: probar interacción real con chamán en runtime, crear diálogo shaman_intro en data/dialogues/, implementar sección C (Incienso) y D (Encantamientos por Tier), integrar con tiendas M39 y economía M38

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
- Consultar DOCUMENTACION/07-GUIA-GODOT.md §9 para pitfalls conocidos de Godot 4.x.
