**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 35: Minería

## A. Requisitos del módulo (12)

- [x] Definir el problema: mineria cozy voxel sin agotamiento permanente [S]
- [x] Registrar dependencias: M08, M13, M15, M26 [S]
- [x] Catalogar los 24 puntos de la seccion 34 del plan maestro [S]
- [x] RF1: vetas de 1-3 bloques [S]
- [x] RF2: catalogo de minerales coherente con M15 [S]
- [x] RF3: bandas de profundidad (superficie/media/ancestral) [S]
- [x] RF4: cuevas con vetas en paredes y techos [S]
- [x] RF5: pico M13 sin castigo al errar [S]
- [x] RF6: eficiencia del pico sobre golpes y doble drop [S]
- [x] RF7+RF8: drops M15 y regeneracion lenta [S]
- [x] RF9+RF10: riesgos no violentos y ritmo anti-repetitivo [S]
- [x] RF11+RF12: secretos ancestrales y colecciones; NFR cozy/determinismo/rendimiento [S]

## B. Resolucion de los 24 puntos del plan (24)

- [x] P1: disenar vetas — afloramientos de 1-3 bloques [S]
- [x] P2: disenar minerales — tabla de 8+ minerales [S]
- [x] P3: disenar niveles de profundidad — 3 bandas [S]
- [x] P4: disenar cuevas — vetas incrustadas [S]
- [x] P5: disenar materiales raros — oro, cristal, polvo de estrellas [S]
- [x] P6: disenar minerales ancestrales — capa de M26 [S]
- [x] P7: disenar herramientas — pico con durabilidad y poder [S]
- [x] P8: disenar eficiencia — poder vs dureza [S]
- [x] P9: disenar particulas — pool de chispas y extraccion [S]
- [x] P10: disenar sonidos — golpe, extraccion, derrumbe [S]
- [x] P11: disenar iluminacion — brillo propio de la veta [S]
- [x] P12: disenar riesgos no violentos — deslumbramiento y caidas suaves [S]
- [x] P13: disenar derrumbes controlados — solo entierran la veta [S]
- [x] P14: disenar recursos secretos — nodos especiales de M26 [S]
- [x] P15: disenar zonas de mineria — cantera, cueva norte, grutas [S]
- [x] P16: disenar rutas — caminos de acceso a las zonas [S]
- [x] P17: disenar estaciones — puestos de descanso y mejoras [S]
- [x] P18: disenar nodos especiales — vetas gigantes raras [S]
- [x] P19: disenar colecciones — registro de minerales [S]
- [x] P20: disenar crafting asociado — lingotes y mejoras (M16) [S]
- [x] P21: disenar economia — precios e intercambio (M36) [S]
- [x] P22: disenar regeneracion — respawn lento por tiempo de juego [S]
- [x] P23: disenar limites — tope suave diario por zona [S]
- [x] P24: evitar mineria excesivamente repetitiva — cadencia y variedad [S]

## C. OreDefinition y catalogo (12)

- [x] Exportar id unico StringName por mineral [S]
- [x] display_name en espanol para UI [S]
- [x] Rango de profundidad min/max por mineral [S]
- [x] Dureza (golpes por bloque 2-4) por mineral [S]
- [x] Cantidad minima y maxima de drop por bloque [S]
- [x] Chance base de doble drop escalada por poder del pico [S]
- [x] Color/emisivo de brillo por mineral [S]
- [x] Escena de particulas de extraccion por mineral [S]
- [x] Sonidos de golpe y extraccion por material [S]
- [x] Validacion de ids duplicados al registrar [S]
- [x] Cobre y hierro en banda de superficie [S]
- [x] Cristal, mineral ancestral y polvo de estrellas en profundidad y M26 [S]

## D. OreVein (12)

- [x] Nodo con referencia a OreDefinition [S]
- [x] Estado INTACTA / AGOTADA / REGENERANDO [S]
- [x] blocks_remaining por veta [S]
- [x] Golpes del bloque actual descontados por poder del pico [M]
- [x] hit() devuelve exito y emite vein_depleted al agotar [M]
- [x] Senal vein_recovered al regenerar [S]
- [x] Temporizador de regeneracion en dias de juego [M]
- [x] Validacion de ocupacion antes de reaparecer [M]
- [x] Desplazamiento suave si el jugador ocupa un bloque [M]
- [x] Serializacion/deserializacion completa del estado [S]
- [x] Golpes sobre veta agotada no producen drops [S]
- [x] Golpes sobre veta agotada no gastan durabilidad [S]

## E. MiningTool (pico) (10)

- [x] tool_power exportado de 1 a 3 [S]
- [x] Cooldown base de 0.6 s entre golpes [S]
- [x] Durabilidad maxima y actual [S]
- [x] Descuento de durabilidad solo con acierto sobre veta [S]
- [x] can_use() valida cooldown y durabilidad [S]
- [x] Raycast con mascara exclusiva de vetas [M]
- [x] Sin swing al aire repetitivo (hit_air respeta cooldown) [S]
- [x] Aplicacion del nivel del pico M13 a poder y cooldown [S]
- [x] Actualizacion de la UI de durabilidad de M13 [S]
- [x] Uso en aire sin veta no descuenta nada [S]

## F. MiningManager (10)

- [x] Autoload mineria registrado en project.godot [S]
- [x] Carga del catalogo .tres al iniciar [S]
- [x] Registro de definiciones con validacion [S]
- [x] Distribucion de vetas por chunk al generar M08 [M]
- [x] Seleccion de mineral por profundidad y bioma con PRNG M29 [M]
- [x] Densidad por zona (cantera > superficie > M26) [S]
- [x] Procesamiento de regeneracion por tick congelado en pausa [M]
- [x] Limite suave diario de extracciones por zona [M]
- [x] Serializar/deserializar el estado completo [M]
- [x] Cero acoplamiento con UI (solo senales) [S]

## G. Integracion con M08 mundo voxel (10)

- [x] Hook de post-generacion de chunk conectado [S]
- [x] Escritura de bloques de mineral en el voxel [M]
- [x] Remeshing diferido solo del chunk afectado [C]
- [x] Colision por bloque de veta unificada con el voxel [S]
- [x] Soporte garantizado: la veta nunca flota [S]
- [x] Validacion de ocupacion reutilizando API de lectura M08 [M]
- [x] Vetas en paredes y techos de cuevas [M]
- [x] Iluminacion de brillo en vetas profundas [M]
- [x] Compatible con el ahorro de memoria de chunks [S]
- [x] Chunks ya editados no regeneran vetas [M]

## H. Integracion con M13 y M15 (8)

- [x] MiningTool montado en el pico equipable de M13 [S]
- [x] Durabilidad compartida con el sistema de herramientas [S]
- [x] Drops entregados a M15 via agregar_recursos [M]
- [x] Minerales visibles y usables en inventario M15 [S]
- [x] Ids de M15 y OreDefinition coincidentes (sin duplicados) [S]
- [x] Fundicion de lingotes con minerales (M16) [S]
- [x] Precios de venta coherentes con economia M36 [S]
- [x] Sin duplicacion de drops entre sistemas [M]

## I. Integracion con M26 Templo Subterraneo (8)

- [x] Capa de mineral ancestral solo en cuevas de M26 [S]
- [x] Nodos especiales de cristal gigante sembrados por eventos de M26 [M]
- [x] Zona ancestral accesible permanentemente tras completar el Templo [S]
- [x] Iluminacion del Templo resalta vetas raras [S]
- [x] Ninguna veta bloquea mecanismos ni puzzles (anti-softlock) [S]
- [x] Acceso a cuevas desde el interior del Templo [S]
- [x] Evento de derrumbe decorativo en la sala del mineral ancestral [S]
- [x] Mineral ancestral registrado en la coleccion del jugador [S]

## J. Edge cases (10)

- [x] Veta a medias: estado intermedio persistido y restaurado [M]
- [x] Respawn con zona ocupada: reintento diferido [M]
- [x] Respawn con jugador dentro: desplazamiento suave [M]
- [x] Respawn con construccion M17 encima: espera al proximo dia [M]
- [x] Guardar/cargar durante un golpe sin perdida de state [S]
- [x] Doble clique rapido: cooldown descarta el segundo golpe [S]
- [x] Veta en borde de chunk: sin duplicacion ni perdida [M]
- [x] Herramienta rota a mitad de golpes: se interrumpe sin estado corrupto [S]
- [x] Varias vetas en el mismo rayo: prioridad por cercania [M]
- [x] Definicion ausente en catalogo: log DOM-MIN y fallback por defecto [S]

## K. Optimizacion (8)

- [x] Remeshing localizado y diferido por chunk [C]
- [x] Pool de particulas de mineria [S]
- [x] Sin allocs en el hot path de hit() [M]
- [x] Raycast con mascara de colision exclusiva [S]
- [x] Barrido de regeneracion iterativo sin crear nodos por veta [M]
- [x] Profiler: golpe individual <= 1 ms CPU [M]
- [x] Definiciones compartidas como Resource (memoria unica) [S]
- [x] Frame budget global respetado en remeshing masivo [C]

## L. Polish cozy (10)

- [x] Particulas de chispas al golpear [S]
- [x] Particulas de satisfaccion al extraer [S]
- [x] Sonido de golpe distinto por material [S]
- [x] Sonido de extraccion gratificante [S]
- [x] Derrumbes controlados suaves y breves [S]
- [x] Veta apagandose visualmente al agotarse [S]
- [x] Chispa de anuncio dorada al recuperarse [S]
- [x] Texto flotante con la cantidad obtenida [S]
- [x] Vibracion ligera opcional al extraer [S]
- [x] Interaccion consistente con el sistema de recursos M15 [S]

## M. Documentacion y QA (8)

- [x] Test: extraer veta completa devuelve los drops exactos [M]
- [x] Test: regeneracion tras N dias sin ocupacion [M]
- [x] Test: veta a medias sobrevive a guardado/carga [M]
- [x] Test: respawn con ocupacion reintenta hasta liberarse [M]
- [x] Test: sin drops duplicados entre M15 y mineria [M]
- [x] Test: 24 h simuladas con reloj M30 sin desincronizar timers [M]
- [x] Profiler en cueva con 50 vetas activas [C]
- [x] Recorrido cozy completo: cantera, cueva norte y Templo sin fallos [C]