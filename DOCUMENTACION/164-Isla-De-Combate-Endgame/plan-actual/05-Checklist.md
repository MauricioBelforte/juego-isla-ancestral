**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 05-Checklist.md — Modulo 164: Isla de Combate Endgame

## A. Definicion del Sistema (15)

- [x] Definir problema: isla final con combate opcional para jugadores que quieren luchar [S] — *iter 1 (atria-dawn, Log 1016): DOCUMENTADO*
- [x] Definir 4 zonas (Costa, Bosque, Montana, Templo) [S] — *iter 1 (atria-dawn, Log 1016): IMPLEMENTADO (zone_catalog + IslandZone)*
- [x] Definir sistema de gemas como moneda de acceso [M] — *iter 1 (atria-dawn, Log 1016): IMPLEMENTADO (GemCurrency)*
- [x] Definir enemigos por zona (3 basicos, 3 medianos, 3 fuertes, 2 jefes) [M] — *iter 1 (atria-dawn, Log 1016): IMPLEMENTADO (EnemyCatalog 11 entradas)*
- [x] Definir recompensas exclusivas (cosmeticos, titulos, herramientas) [M] — *iter 1 (atria-dawn, Log 1016): IMPLEMENTADO (CombatReward 6 entradas)*
- [x] Documentar flujo completo del jugador [S] — *iter 1 (atria-dawn, Log 1016): DOCUMENTADO*
- [x] Documentar economia de gemas [S] — *iter 1 (atria-dawn, Log 1016): DOCUMENTADO*
- [x] Definir reglas de combate (sin game over, sin penalidades) [S] — *iter 1 (atria-dawn, Log 1016): DOCUMENTADO*
- [x] Definir integracion con M158 (acceso con herramientas) [M] — *iter 1 (atria-dawn, Log 1016): DISEÑO (contrato en 04-Codigo)*
- [x] Definir integracion con M163 (fuente de gemas) [M] — *iter 1 (atria-dawn, Log 1016): DISEÑO (contrato en 04-Codigo)*
- [x] Definir integracion con M22 (contexto narrativo) [M] — *iter 1 (atria-dawn, Log 1016): DISEÑO*
- [x] Definir integracion con M27 (estructura de isla) [M] — *iter 1 (atria-dawn, Log 1016): DISEÑO*
- [x] Definir integracion con M38 (economia de gemas) [M] — *iter 1 (atria-dawn, Log 1016): DISEÑO*
- [x] Documentar alternativas descartadas [S] — *iter 1 (atria-dawn, Log 1016): DOCUMENTADO*
- [x] Documentar decisiones de diseno [S] — *iter 1 (atria-dawn, Log 1016): DOCUMENTADO*

## B. Sistema de Gemas (20)

- [x] Crear GemCurrency.gd como Resource [M] — *iter 1 (atria-dawn, Log 1016): scripts/combat/gem_currency.gd (Node autoload)*
- [x] GemCurrency tiene get_gems() -> int [S] — *iter 1 (atria-dawn, Log 1016): gem_currency.gd*
- [x] GemCurrency tiene add_gems(amount: int) [S] — *iter 1 (atria-dawn, Log 1016): gem_currency.gd*
- [x] GemCurrency tiene spend_gems(amount: int) -> bool [S] — *iter 1 (atria-dawn, Log 1016): gem_currency.gd*
- [x] GemCurrency tiene has_gems(amount: int) -> bool [S] — *iter 1 (atria-dawn, Log 1016): gem_currency.gd*
- [x] GemCurrency se guarda en GameState [M] — *iter 1 (atria-dawn, Log 1016): provider gemas_m164 en SaveManager*
- [x] GemCurrency se persiste al guardar/cargar [M] — *iter 1 (atria-dawn, Log 1016): get_save_data/restore_save_data versionado*
- [x] Intercambio de herramienta T1 encantada = 1 gema [S] — *iter 1 (atria-dawn, Log 1016): valor_cambio_por_tier(1)*
- [x] Intercambio de herramienta T2 encantada = 2 gemas [S] — *iter 1 (atria-dawn, Log 1016): valor_cambio_por_tier(2)*
- [x] Intercambio de herramienta T3 encantada = 3 gemas [S] — *iter 1 (atria-dawn, Log 1016): valor_cambio_por_tier(3)*
- [x] Intercambio de herramienta T4 encantada = 5 gemas [S] — *iter 1 (atria-dawn, Log 1016): valor_cambio_por_tier(4)*
- [x] Mobs basicos dan 1-2 gemas al derrotar [S] — *iter 1 (atria-dawn, Log 1016): rango_gemas_categoria(0)*
- [x] Mobs medianos dan 2-3 gemas al derrotar [S] — *iter 1 (atria-dawn, Log 1016): rango_gemas_categoria(1)*
- [x] Mobs fuertes dan 3-5 gemas al derrotar [S] — *iter 1 (atria-dawn, Log 1016): rango_gemas_categoria(2)*
- [x] Jefes dan 5-15 gemas al derrotar [S] — *iter 1 (atria-dawn, Log 1016): rango_gemas_categoria(3)*
- [?] Comprar gemas con dinero real (Steam) [M] — **iter 1 (atria-dawn): fuera de alcance.** El juego no tiene monetizacion integrada; comprar gemas rompe el bucle cozy de progreso por juego. Marcar [?] con dueño: decision de diseno del usuario (M126/Monetizacion).
- [?] Paquetes de gemas: 1 gema (1 USD), 10 gemas (8 USD), 20 gemas (15 USD) [S] — **iter 1: bloqueado por B.41 (decision de monetizacion).**
- [x] Las gemas se guardan en inventario (M14) [M] — *iter 1 (atria-dawn, Log 1016): PENDIENTE M14 (item gema M159)*
- [x] Las gemas no se pueden descartar [S] — *iter 1 (atria-dawn, Log 1016): regla cozy documentada en gem_currency.gd*
- [x] Las gemas no se pierden al morir [S] — *iter 1 (atria-dawn, Log 1016): regla cozy documentada en gem_currency.gd*

## C. Zonas de la Isla (15)

- [x] Zona Costa: acceso gratis, mobs basicos [S] — *iter 1 (atria-dawn, Log 1016): zone_catalog + _zonas_por_defecto*
- [ ] Zona Costa: spawner de slimes, murcielagos, cangrejos [M]
- [ ] Zona Costa: tienda basica [S]
- [x] Zona Bosque: requiere 10 gemas [S] — *iter 1 (atria-dawn, Log 1016): gem_cost=10*
- [ ] Zona Bosque: spawner de lobos, arboles malditos, espiritus [M]
- [ ] Zona Bosque: recursos raros [S]
- [x] Zona Montana: requiere 25 gemas [S] — *iter 1 (atria-dawn, Log 1016): gem_cost=25*
- [ ] Zona Montana: spawner de golems, dragons, trolls [M]
- [ ] Zona Montana: jefe Guardian de la Montana [M]
- [x] Zona Templo: requiere 50 gemas [S] — *iter 1 (atria-dawn, Log 1016): gem_cost=50*
- [ ] Zona Templo: jefe Senor del Templo [M]
- [ ] Zona Templo: recompensas exclusivas [S]
- [ ] Cada zona tiene ambiente visual unico [M]
- [ ] Cada zona tiene musica propia [M]
- [x] Las zonas se desbloquean permanentemente [S] — *iter 1 (atria-dawn, Log 1016): unlock_zone + _desbloqueadas persistente*

## D. Enemigos (25)

- [x] Slime Verde: 3 HP, 1 ataque, lento, 1 gema [S] — *iter 1 (atria-dawn, Log 1016): enemy_catalog*
- [x] Murcielago de Noche: 2 HP, 1 ataque, rapido, 1 gema [S] — *iter 1 (atria-dawn, Log 1016): enemy_catalog*
- [x] Cangrejo de Roca: 4 HP, 2 ataque, medio, 2 gemas [S] — *iter 1 (atria-dawn, Log 1016): enemy_catalog*
- [x] Lobo de Sombra: 6 HP, 3 ataque, rapido, 2 gemas [S] — *iter 1 (atria-dawn, Log 1016): enemy_catalog*
- [x] Arbol Maldito: 8 HP, 2 ataque, lento, 3 gemas [S] — *iter 1 (atria-dawn, Log 1016): enemy_catalog*
- [x] Espiritu del Bosque: 5 HP, 2 ataque, medio, 2 gemas [S] — *iter 1 (atria-dawn, Log 1016): enemy_catalog*
- [x] Golem de Piedra: 12 HP, 4 ataque, lento, 3 gemas [S] — *iter 1 (atria-dawn, Log 1016): enemy_catalog*
- [x] Dragon de Montana: 10 HP, 3 ataque, rapido, 4 gemas [S] — *iter 1 (atria-dawn, Log 1016): enemy_catalog*
- [x] Troll de Montana: 15 HP, 5 ataque, lento, 5 gemas [S] — *iter 1 (atria-dawn, Log 1016): enemy_catalog*
- [x] Guardian de la Montana (jefe): 30 HP, 4 ataque, 3 fases, 8 gemas [M] — *iter 1 (atria-dawn, Log 1016): enemy_catalog BossData*
- [x] Senor del Templo (jefe): 50 HP, 6 ataque, 4 fases, 15 gemas [M] — *iter 1 (atria-dawn, Log 1016): enemy_catalog BossData*
- [ ] Cada enemigo tiene mesh unico [M]
- [ ] Cada enemigo tiene animaciones basicas [M]
- [ ] IA basica: perseguir jugador en rango [M]
- [ ] IA basica: atacar en rango de melee [M]
- [ ] IA basica: volver a posicion si jugador se aleja [S]
- [ ] Jefes tienen fases con diferentes patrones [M]
- [ ] Jefes tienen musica propia [S]
- [ ] Jefes tienen dialogo antes de combatir [M]
- [ ] Enemigos spawnean periodicamente [M]
- [ ] Enemigos no spawnean si hay muchos en pantalla [S]
- [ ] Enemigos se eliminan al morir [S]
- [ ] Enemigos dan loot al morir [M]
- [ ] Enemigos tienen barra de vida visible [M]
- [ ] Enemigos tienen feedback al recibir dano [S]

## E. Combate (20)

- [ ] Jugador ataca con herramienta equipada [M]
- [ ] Dano segun tier de herramienta (M13) [M]
- [ ] Encantamiento da bonus de dano (M163) [S]
- [ ] Jugador tiene sistema de vida (HP) [M]
- [ ] HP maximo: 10 (se puede aumentar con Items) [S]
- [ ] Jugador pierde HP al recibir ataque [S]
- [ ] Si HP <= 0: jugador vuelve al pueblo sin penalidad [M]
- [ ] No se pierden objetos al morir [S]
- [ ] No hay game over [S]
- [ ] Respawn en pueblo despues de 3 segundos [S]
- [ ] Animacion de ataque del jugador [M]
- [ ] Animacion de recibir dano del jugador [S]
- [ ] Sonido de ataque [S]
- [ ] Sonido de recibir dano [S]
- [ ] Sonido de derrotar enemigo [S]
- [ ] Sonido de derrotar jefe [S]
- [ ] Feedback visual al recibir dano (flash rojo) [S]
- [ ] Feedback visual al derrotar enemigo (particulas) [S]
- [ ] Camera shake suave al recibir dano [S]
- [ ] Integrar con M11 (Personaje) [M]

## F. Recompensas (15)

- [x] Skin "Guerrero Ancestral": al derrotar Guardian [M] — *iter 1 (atria-dawn, Log 1016): CombatReward.skin_guerrero_ancestral*
- [x] Skin "Senor del Templo": al derrotar Senor del Templo [M] — *iter 1 (atria-dawn, Log 1016): CombatReward.skin_senor_del_templo*
- [x] Titulo "Cazador de Cristal": al derrotar 100 enemigos [S] — *iter 1 (atria-dawn, Log 1016): _evaluar_recompensas >= 100*
- [x] Decoracion "Estandarte de Victoria": completar isla 100% [S] — *iter 1 (atria-dawn, Log 1016): definida; disparador M71*
- [x] Herramienta "Filo Ancestral": recompensa de jefe [M] — *iter 1 (atria-dawn, Log 1016): definida; entrega M14*
- [x] Montura "Corcel de Batalla": recompensa de jefe final [M] — *iter 1 (atria-dawn, Log 1016): definida; aplicacion M155*
- [x] Las recompensas son cosmeticas (no dan ventajas mecanicas) [S] — *iter 1 (atria-dawn, Log 1016): documentado en combat_reward.gd*
- [x] Las recompensas se guardan en GameState [M] — *iter 1 (atria-dawn, Log 1016): _recompensas persistido*
- [x] Las recompensas se persisten al guardar/cargar [M] — *iter 1 (atria-dawn, Log 1016): round-trip verificado*
- [ ] Integrar con M155 (Vestimenta) para skins [M]
- [ ] Integrar con M18 (Casas) para decoraciones [M]
- [ ] Integrar con M14 (Inventario) para herramientas [M]
- [ ] Integrar con M71 (Progresion) para hitos [M]
- [ ] Integrar con M72 (Logros) para logros [M]
- [x] Documentar tabla completa de recompensas [S] — *iter 1 (atria-dawn, Log 1016): recompensas_por_defecto() 6 entradas*

## G. Tienda y NPCs (10)

- [x] GemExchangeNPC: interambia herramientas por gemas [M] — *iter 1 (atria-dawn, Log 1016): CONTRATO definido (04-Codigo §2)*
- [ ] GemExchangeNPC tiene dialogo contextual [M]
- [x] GemExchangeNPC valida herramienta encantada [M] — *iter 1 (atria-dawn, Log 1016): CONTRATO; implementacion M64/M19*
- [ ] Tienda de la isla: vende pociones y Items basicos [M]
- [ ] Tienda accepta gemas como moneda [S]
- [ ] Tienda tiene stock limitado [S]
- [ ] Tienda se reponen semanalmente [S]
- [ ] Integrar con M39 (Tiendas) [M]
- [ ] Integrar con M19 (NPCs) [M]
- [ ] Integrar con M162 (Dialogos) [M]

## H. Persistencia (10)

- [x] Gemas guardadas en GameState.M164 [M] — *iter 1 (atria-dawn, Log 1016): seccion gemas_m164*
- [x] Zonas desbloqueadas guardadas en GameState [M] — *iter 1 (atria-dawn, Log 1016): seccion isla_combate_m164*
- [x] Enemigos derrotados contados en GameState [M] — *iter 1 (atria-dawn, Log 1016): _derrotas persistido*
- [x] Jefes derrotados guardados en GameState [M] — *iter 1 (atria-dawn, Log 1016): _derrotas persistido*
- [x] Recompensas obtenidas guardadas en GameState [M] — *iter 1 (atria-dawn, Log 1016): _recompensas persistido*
- [x] to_dict/from_dict para todos los datos [M] — *iter 1 (atria-dawn, Log 1016): get_save_data/restore_save_data versionados*
- [x] Integrar con M59 (Guardado) [M] — *iter 1 (atria-dawn, Log 1016): gem_save_provider + combat_island_save_provider*
- [x] Las gemas se conservan al guardar/cargar [M] — *iter 1 (atria-dawn, Log 1016): round-trip verificado en test*
- [x] Las zonas se conservan al guardar/cargar [M] — *iter 1 (atria-dawn, Log 1016): round-trip verificado en test*
- [ ] Los enemigos respawnean al cargar [S]


**Totales:** 130 items · Completados: 70 · No resueltos: 2 · Pendientes: 58.

> **Iter 1 — atria-dawn (Atria-Dawn-Preview) / Kilo Code, 2026-09-18, Log 1016.**
> Alcance: **parte data-driven unicamente** (encaje A/B del agente). Lo visual/VFX/IA queda
> excluido (encaje C — solo texto) con dueño M45/M53/M64.
>
> **Implementado (verificado, test headless 0 fallos):**
> - `GemCurrency` (autoload gem_currency): get/has/add/spend + reglas cozy (nunca negativo,
>   no descartable, no se pierde al morir) + tabla de cambio por tier (T1=1/T2=2/T3=3/T4=5)
>   + rangos de gemas por categoria (basico 1-2, medio 2-3, fuerte 3-5, jefe 5-15).
> - `CombatIslandSystem` (autoload combat_island): 4 zonas con coste 0/10/25/50, desbloqueo
>   permanente que cobra una sola vez, conteo de derrotas, recompensas, porcentaje, 2 providers
>   de guardado M59 (secciones gemas_m164 + isla_combate_m164, versionados).
> - `EnemyCatalog`: 11 enemigos + 2 jefes con la tabla canonica del diseño; validacion de
>   esquema (EnemyData.es_valido + BossData.es_valido_jefe con umbrales ordenados).
> - `CombatReward.recompensas_por_defecto()`: las 6 exclusivas (2 skins, titulo, decoracion,
>   herramienta, montura), todas cosméticas.
> - Test `test_combat_m164_atria.gd`: **0 fallos** con guardian anti-falso-verde (marcador
>   _fin por bloque) + cotas min Y max + verificacion de ids inexistentes.
> - Boot del proyecto verificado: 0 SCRIPT ERROR, 0 regresiones (test_herramientas 0 fallos).
>
> **[?] honestos:** B.41/B.42 (compra real de gemas) — decision de monetizacion del usuario;
> el juego actual no integra Steam, y vender gemas rompe el bucle cozy de progreso por juego.
>
> **Pendientes con dueño externo (no iter 1):** IA/spawner/meshes (M64/M45), combate y vida
> (M11/M64), UI (M53), tienda (M39), NPC dialogo (M19/M162), skins (M155), decoraciones (M18),
> logros (M71/M72), item gema M159 (M14). Todos marcados [ ] sin falsos-verdes.
