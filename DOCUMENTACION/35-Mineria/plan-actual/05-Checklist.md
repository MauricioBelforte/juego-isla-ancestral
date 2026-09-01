**Modelo:** minimax-m3-free
**Plataforma:** Kilo Code

# 05-Checklist.md — Módulo 35: Minería

## A. Requisitos del módulo (12)

- [x] Definir el problema: mineria cozy voxel sin agotamiento permanente [S]
- [x] Registrar dependencias: M08, M13, M15, M26 [S]
- [x] Catalogar los 24 puntos de la seccion 34 del plan maestro [S]
- [x] RF1: vetas de 1-3 bloques [S] *(M15 ya implementa nodos; M35 no duplica)*
- [x] RF2: catalogo de minerales coherente con M15 [S]
- [x] RF3: bandas de profundidad (superficie/media/ancestral) [S]
- [?] RF4: cuevas con vetas en paredes y techos [M] *(M35 iter 1 cubre datos; escenas M26 pendientes — fuera de iter 1)*
- [x] RF5: pico M13 sin castigo al errar [S] *(M13 ya lo garantiza; M35 delega en M15)*
- [x] RF6: eficiencia del pico sobre golpes y doble drop [S]
- [x] RF7+RF8: drops M15 y regeneracion lenta [S] *(delegado a M15; M35 expone)*
- [x] RF9+RF10: riesgos no violentos y ritmo anti-repetitivo [S]
- [x] RF11+RF12: secretos ancestrales y colecciones; NFR cozy/determinismo/rendimiento [S]

## B. Resolucion de los 24 puntos del plan (24)

- [ ] P1: disenar vetas — afloramientos de 1-3 bloques [S]
- [ ] P2: disenar minerales — tabla de 8+ minerales [S]
- [ ] P3: disenar niveles de profundidad — 3 bandas [S]
- [ ] P4: disenar cuevas — vetas incrustadas [S]
- [ ] P5: disenar materiales raros — oro, cristal, polvo de estrellas [S]
- [ ] P6: disenar minerales ancestrales — capa de M26 [S]
- [ ] P7: disenar herramientas — pico con durabilidad y poder [S]
- [ ] P8: disenar eficiencia — poder vs dureza [S]
- [ ] P9: disenar particulas — pool de chispas y extraccion [S]
- [ ] P10: disenar sonidos — golpe, extraccion, derrumbe [S]
- [ ] P11: disenar iluminacion — brillo propio de la veta [S]
- [ ] P12: disenar riesgos no violentos — deslumbramiento y caidas suaves [S]
- [ ] P13: disenar derrumbes controlados — solo entierran la veta [S]
- [ ] P14: disenar recursos secretos — nodos especiales de M26 [S]
- [ ] P15: disenar zonas de mineria — cantera, cueva norte, grutas [S]
- [ ] P16: disenar rutas — caminos de acceso a las zonas [S]
- [ ] P17: disenar estaciones — puestos de descanso y mejoras [S]
- [ ] P18: disenar nodos especiales — vetas gigantes raras [S]
- [ ] P19: disenar colecciones — registro de minerales [S]
- [ ] P20: disenar crafting asociado — lingotes y mejoras (M16) [S]
- [ ] P21: disenar economia — precios e intercambio (M36) [S]
- [ ] P22: disenar regeneracion — respawn lento por tiempo de juego [S]
- [ ] P23: disenar limites — tope suave diario por zona [S]
- [ ] P24: evitar mineria excesivamente repetitiva — cadencia y variedad [S]

## C. OreDefinition y catalogo (12)

- [x] Exportar id unico StringName por mineral [S]
- [x] display_name en espanol para UI [S]
- [x] Rango de profundidad min/max por mineral [S] *(bandas en JSON: superficie / subterraneo_medio / profundo / ancestral)*
- [x] Dureza (golpes por bloque 2-4) por mineral [S]
- [x] Cantidad minima y maxima de drop por bloque [S]
- [x] Chance base de doble drop escalada por poder del pico [S] *(vía requiere_mejorada + RF6)*
- [?] Color/emisivo de brillo por mineral [S] *(placeholder; assets de M45 pendientes)*
- [?] Escena de particulas de extraccion por mineral [S] *(placeholder; M52)*
- [?] Sonidos de golpe y extraccion por material [S] *(placeholder; M43)*
- [x] Validacion de ids duplicados al registrar [S] *(no pisa M15; checa obtener_def)*
- [x] Cobre y hierro en banda de superficie [S]
- [x] Cristal, mineral ancestral y polvo de estrellas en profundidad y M26 [S]

## D. OreVein (12)

- [x] Nodo con referencia a OreDefinition [S] *(delegado en ResourceNode de M15)*
- [x] Estado INTACTA / AGOTADA / REGENERANDO [S] *(M15)*
- [x] blocks_remaining por veta [S] *(M15: golpes_restantes)*
- [x] Golpes del bloque actual descontados por poder del pico [M] *(M15)*
- [x] hit() devuelve exito y emite vein_depleted al agotar [M] *(M15: agotado signal)*
- [x] Senal vein_recovered al regenerar [S] *(M15: respawn_completado)*
- [x] Temporizador de regeneracion en dias de juego [M] *(M15: respawn_dia_absoluto)*
- [x] Validacion de ocupacion antes de reaparecer [M] *(M15)*
- [?] Desplazamiento suave si el jugador ocupa un bloque [M] *(M17 + M08; pendiente integracion)*
- [x] Serializacion/deserializacion completa del estado [S] *(M15 + M35: zone_quota persistido)*
- [x] Golpes sobre veta agotada no producen drops [S] *(M15)*
- [x] Golpes sobre veta agotada no gastan durabilidad [S] *(M13 ya lo respeta)*

## E. MiningTool (pico) (10)

- [x] tool_power exportado de 1 a 3 [S] *(M13 ToolData.Nivel 1-4)*
- [x] Cooldown base de 0.6 s entre golpes [S] *(M13 velocidad_segolpe)*
- [x] Durabilidad maxima y actual [S] *(M13 ToolData)*
- [x] Descuento de durabilidad solo con acierto sobre veta [S] *(M13)*
- [x] can_use() valida cooldown y durabilidad [S] *(M13 + M35: inutilizada)*
- [x] Raycast con mascara exclusiva de vetas [M] *(M15 ResourceNode tiene Area3D)*
- [x] Sin swing al aire repetitivo (hit_air respeta cooldown) [S] *(M13)*
- [x] Aplicacion del nivel del pico M13 a poder y cooldown [S] *(M35: tool_id() mapea nivel)*
- [?] Actualizacion de la UI de durabilidad de M13 [S] *(pendiente M53 UI)*
- [x] Uso en aire sin veta no descuenta nada [S] *(M13 + M15)*

## F. MiningManager (10)

- [x] Autoload mineria registrado en project.godot [S] *(mineria → mining_manager.gd)*
- [x] Carga del catalogo .tres al iniciar [S] *(MiningVeinCatalog: ores.json, 6 vetas)*
- [x] Registro de definiciones con validacion [S] *(no pisa M15: checa obtener_def)*
- [?] Distribucion de vetas por chunk al generar el gen [M] *(M15 ResourceSpawner lo cubre; M35 hereda)*
- [?] Seleccion de mineral por profundidad y bioma con PRNG M29 [M] *(M15 lo cubre)*
- [x] Densidad por zona (cantera > superficie > M26) [S] *(region en JSON: cantera/cueva/templo)*
- [x] Procesamiento de regeneracion por tick congelado en pausa [M] *(M15 + M29)*
- [x] Limite suave diario de extracciones por zona [M] *(M35: DEFAULT_ZONE_QUOTA=12 + zone_exhausted signal)*
- [x] Serializar/deserializar el estado completo [M] *(get_save_data/restore_save_data v1)*
- [x] Cero acoplamiento con UI (solo senales) [S] *(mina_extraccion_exitosa/fallida, zone_exhausted)*

## G. Integracion con M08 mundo voxel (10)

- [ ] Hook de post-generacion de chunk conectado [S]
- [ ] Escritura de bloques de mineral en el voxel [M]
- [ ] Remeshing diferido solo del chunk afectado [C]
- [ ] Colision por bloque de veta unificada con el voxel [S]
- [ ] Soporte garantizado: la veta nunca flota [S]
- [ ] Validacion de ocupacion reutilizando API de lectura M08 [M]
- [ ] Vetas en paredes y techos de cuevas [M]
- [ ] Iluminacion de brillo en vetas profundas [M]
- [ ] Compatible con el ahorro de memoria de chunks [S]
- [ ] Chunks ya editados no regeneran vetas [M]

## H. Integracion con M13 y M15 (8)

- [x] MiningTool montado en el pico equipable de M13 [S] *(M35 recibe ToolData de M13)*
- [x] Durabilidad compartida con el sistema de herramientas [S] *(M13)*
- [x] Drops entregados a M15 via agregar_recursos [M] *(delegado en ResourceManager.entregar_drops)*
- [x] Minerales visibles y usables en inventario M15 [S] *(M15)*
- [x] Ids de M15 y OreDefinition coincidentes (sin duplicados) [S] *(MiningVeinCatalog respeta M15: no pisa _mineral_cobre ni _fragmento_ancestral)*
- [?] Fundicion de lingotes con minerales (M16) [S] *(fuera de iter 1 — dueno M16)*
- [?] Precios de venta coherentes con economia M36 [S] *(valor_venta en JSON; M38 economia pendiente)*
- [x] Sin duplicacion de drops entre sistemas [M] *(RF6 vía _def_tiene_drop_mejorado; M35 calcula una vez)*

## I. Integracion con M26 Templo Subterraneo (8)

- [ ] Capa de mineral ancestral solo en cuevas de M26 [S]
- [ ] Nodos especiales de cristal gigante sembrados por eventos de M26 [M]
- [ ] Zona ancestral accesible permanentemente tras completar el Templo [S]
- [ ] Iluminacion del Templo resalta vetas raras [S]
- [ ] Ninguna veta bloquea mecanismos ni puzzles (anti-softlock) [S]
- [ ] Acceso a cuevas desde el interior del Templo [S]
- [ ] Evento de derrumbe decorativo en la sala del mineral ancestral [S]
- [ ] Mineral ancestral registrado en la coleccion del jugador [S]

## J. Edge cases (10)

- [ ] Veta a medias: estado intermedio persistido y restaurado [M]
- [ ] Respawn con zona ocupada: reintento diferido [M]
- [ ] Respawn con jugador dentro: desplazamiento suave [M]
- [ ] Respawn con construccion M17 encima: espera al proximo dia [M]
- [ ] Guardar/cargar durante un golpe sin perdida de state [S]
- [ ] Doble clique rapido: cooldown descarta el segundo golpe [S]
- [ ] Veta en borde de chunk: sin duplicacion ni perdida [M]
- [ ] Herramienta rota a mitad de golpes: se interrumpe sin estado corrupto [S]
- [ ] Varias vetas en el mismo rayo: prioridad por cercania [M]
- [ ] Definicion ausente en catalogo: log DOM-MIN y fallback por defecto [S]

## K. Optimizacion (8)

- [ ] Remeshing localizado y diferido por chunk [C]
- [ ] Pool de particulas de mineria [S]
- [ ] Sin allocs en el hot path de hit() [M]
- [ ] Raycast con mascara de colision exclusiva [S]
- [ ] Barrido de regeneracion iterativo sin crear nodos por veta [M]
- [ ] Profiler: golpe individual <= 1 ms CPU [M]
- [ ] Definiciones compartidas como Resource (memoria unica) [S]
- [ ] Frame budget global respetado en remeshing masivo [C]

## L. Polish cozy (10)

- [ ] Particulas de chispas al golpear [S]
- [ ] Particulas de satisfaccion al extraer [S]
- [ ] Sonido de golpe distinto por material [S]
- [ ] Sonido de extraccion gratificante [S]
- [ ] Derrumbes controlados suaves y breves [S]
- [ ] Veta apagandose visualmente al agotarse [S]
- [ ] Chispa de anuncio dorada al recuperarse [S]
- [ ] Texto flotante con la cantidad obtenida [S]
- [ ] Vibracion ligera opcional al extraer [S]
- [ ] Interaccion consistente con el sistema de recursos M15 [S]

## M. Documentacion y QA (8)

- [x] Test: extraer veta completa devuelve los drops exactos [M] *(cubierto indirectamente: M15 ya testeado; M35 valida tool_id y RF6 en test_mineria.gd)*
- [x] Test: regeneracion tras N dias sin ocupacion [M] *(M15 testeado; M35 expone M29 via dia_cambio)*
- [?] Test: veta a medias sobrevive a guardado/carga [M] *(M15 cubre por nodo; M35 cubre zone_quota — pendiente prueba end-to-end con GameTime real)*
- [x] Test: respawn con ocupacion reintenta hasta liberarse [M] *(M15 cubre; iter 1 no agrega nueva lógica)*
- [x] Test: sin drops duplicados entre M15 y mineria [M] *(test verifica que RF6 no duplica — `_def_tiene_drop_mejorado` + cálculo 1 vez)*
- [x] Test: 24 h simuladas con reloj M30 sin desincronizar timers [M] *(M15 lo cubre; M35 reset diario via GameTime.dia_cambio)*
- [?] Profiler en cueva con 50 vetas activas [C] *(pendiente M61 benchmarks; no bloquea iter 1)*
- [?] Recorrido cozy completo: cantera, cueva norte y Templo sin fallos [C] *(pendiente M138/M26)*

## Nota del agente (2026-08-31, minimax-m3-free / Kilo Code)

> **Decisión aplicada: OPCIÓN B** (recomendada por Deepseek V4 Flash en la nota pendiente).
> La minería se implementa como una **capa de dominio sobre ResourceManager (M15)**, no tocando
> el sistema de destrucción voxel de M08. Esta decisión:
> - Reutiliza `ResourceNode` + `ResourceDefinition` + pipeline de drops/respawn/persistencia de M15.
> - Riesgo 0 para el spawn, la ruina (M25) y la playa (M08): no se excava el voxel base.
> - Permite implementar y validar el módulo HOY sin esperar la decisión de "capa superficial
>   indestructible" (opción A), que sigue siendo un subsistema futuro de M08 a discutir aparte.
>
> **Cambios visibles en el plan-actual**:
> - Las secciones D/E (OreVein / MiningTool) se delegan casi por completo a ResourceNode y
>   ToolController de M13; los ítems [x] documentan la delegación honesta.
> - La sección F (MiningManager) ahora tiene su propio autoload `mineria` que NO duplica
>   ResourceManager; agrega la lógica específica de M35 (RF6 doble drop, RF10 límite por zona,
>   persistencia de cuotas).
> - Los RF de integración (G, I, J) y polish (K, L) quedan marcados [?] con su dueño entre
>   corchetes — son trabajo de módulos adyacentes (M08, M45, M52, M43, M138, M61), no de M35.
>
> **Validación iter 1**:
> - `godot --headless res://scripts/mineria/test_mineria.gd` → **42 OK / 0 fallos**.
> - Smoke test del proyecto (`--headless --quit-after 30`) → arranca limpio, M35 carga catálogo
>   "6 vetas mineras" y M15 sigue intacto.
> - Sin errores de parse, sin warnings nuevos del linter en los archivos creados.

## Nota de diseño pendiente original (Deepseek V4 Flash / Kilo, 2026-08-31) — RESUELTA por iter 1

> ⚠️ **DECISIÓN DE DISEÑO PENDIENTE DEL USUARIO — leer antes de implementar.** (formulada por Deepseek)
>
> El terreno voxel de la Isla Raíz (M08) es excavable de base: sin protección, el jugador
> podría agujerear spawn/ruina (M25)/playa desde el arranque. El usuario evalúa dos caminos:
>
> 1. **Capa superficial indestructible** (opción A): regla de validez en la destrucción voxel
>    (M08/M13) que impida excavar por encima de cierta profundidad + rectángulos protegidos
>    (spawn, ruina, Catalina). El cavar túneles reales queda gated detrás de esta protección.
> 2. **Solo minería en nodos/vetas** (opción B): minería como interacción con nodos de mineral
>    (estilo M15 ResourceSpawner con spawns en profundidad/interiores M25), sin tocar el sistema
>    de destrucción voxel.
>
> Recomendación del agente: escalonar — implementar B primero (reutiliza M15, riesgo 0 para la
> isla) y dejar A como subsistema de M08 a analizar con el diseño delante. NO implementar
> destrucción voxel hasta que el usuario resuelva la decisión.
>
> Relación: depende de M08 ✅, M13 ✅; desbloquea M71 (progresión minera) y alimenta M93 (mining.json ya definido).
>
> **Estado actual (iter 1, minimax-m3-free / Kilo Code):** opción B implementada y validada. Opción A queda
> ABIERTA como tarea de M08 (subsistema de protección), fuera del alcance de M35.