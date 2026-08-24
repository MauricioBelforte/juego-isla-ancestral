**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 35: Minería

## A. Requisitos del módulo (12)

- [ ] Definir el problema: mineria cozy voxel sin agotamiento permanente [S]
- [ ] Registrar dependencias: M08, M13, M15, M26 [S]
- [ ] Catalogar los 24 puntos de la seccion 34 del plan maestro [S]
- [ ] RF1: vetas de 1-3 bloques [S]
- [ ] RF2: catalogo de minerales coherente con M15 [S]
- [ ] RF3: bandas de profundidad (superficie/media/ancestral) [S]
- [ ] RF4: cuevas con vetas en paredes y techos [S]
- [ ] RF5: pico M13 sin castigo al errar [S]
- [ ] RF6: eficiencia del pico sobre golpes y doble drop [S]
- [ ] RF7+RF8: drops M15 y regeneracion lenta [S]
- [ ] RF9+RF10: riesgos no violentos y ritmo anti-repetitivo [S]
- [ ] RF11+RF12: secretos ancestrales y colecciones; NFR cozy/determinismo/rendimiento [S]

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

- [ ] Exportar id unico StringName por mineral [S]
- [ ] display_name en espanol para UI [S]
- [ ] Rango de profundidad min/max por mineral [S]
- [ ] Dureza (golpes por bloque 2-4) por mineral [S]
- [ ] Cantidad minima y maxima de drop por bloque [S]
- [ ] Chance base de doble drop escalada por poder del pico [S]
- [ ] Color/emisivo de brillo por mineral [S]
- [ ] Escena de particulas de extraccion por mineral [S]
- [ ] Sonidos de golpe y extraccion por material [S]
- [ ] Validacion de ids duplicados al registrar [S]
- [ ] Cobre y hierro en banda de superficie [S]
- [ ] Cristal, mineral ancestral y polvo de estrellas en profundidad y M26 [S]

## D. OreVein (12)

- [ ] Nodo con referencia a OreDefinition [S]
- [ ] Estado INTACTA / AGOTADA / REGENERANDO [S]
- [ ] blocks_remaining por veta [S]
- [ ] Golpes del bloque actual descontados por poder del pico [M]
- [ ] hit() devuelve exito y emite vein_depleted al agotar [M]
- [ ] Senal vein_recovered al regenerar [S]
- [ ] Temporizador de regeneracion en dias de juego [M]
- [ ] Validacion de ocupacion antes de reaparecer [M]
- [ ] Desplazamiento suave si el jugador ocupa un bloque [M]
- [ ] Serializacion/deserializacion completa del estado [S]
- [ ] Golpes sobre veta agotada no producen drops [S]
- [ ] Golpes sobre veta agotada no gastan durabilidad [S]

## E. MiningTool (pico) (10)

- [ ] tool_power exportado de 1 a 3 [S]
- [ ] Cooldown base de 0.6 s entre golpes [S]
- [ ] Durabilidad maxima y actual [S]
- [ ] Descuento de durabilidad solo con acierto sobre veta [S]
- [ ] can_use() valida cooldown y durabilidad [S]
- [ ] Raycast con mascara exclusiva de vetas [M]
- [ ] Sin swing al aire repetitivo (hit_air respeta cooldown) [S]
- [ ] Aplicacion del nivel del pico M13 a poder y cooldown [S]
- [ ] Actualizacion de la UI de durabilidad de M13 [S]
- [ ] Uso en aire sin veta no descuenta nada [S]

## F. MiningManager (10)

- [ ] Autoload mineria registrado en project.godot [S]
- [ ] Carga del catalogo .tres al iniciar [S]
- [ ] Registro de definiciones con validacion [S]
- [ ] Distribucion de vetas por chunk al generar M08 [M]
- [ ] Seleccion de mineral por profundidad y bioma con PRNG M29 [M]
- [ ] Densidad por zona (cantera > superficie > M26) [S]
- [ ] Procesamiento de regeneracion por tick congelado en pausa [M]
- [ ] Limite suave diario de extracciones por zona [M]
- [ ] Serializar/deserializar el estado completo [M]
- [ ] Cero acoplamiento con UI (solo senales) [S]

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

- [ ] MiningTool montado en el pico equipable de M13 [S]
- [ ] Durabilidad compartida con el sistema de herramientas [S]
- [ ] Drops entregados a M15 via agregar_recursos [M]
- [ ] Minerales visibles y usables en inventario M15 [S]
- [ ] Ids de M15 y OreDefinition coincidentes (sin duplicados) [S]
- [ ] Fundicion de lingotes con minerales (M16) [S]
- [ ] Precios de venta coherentes con economia M36 [S]
- [ ] Sin duplicacion de drops entre sistemas [M]

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

- [ ] Test: extraer veta completa devuelve los drops exactos [M]
- [ ] Test: regeneracion tras N dias sin ocupacion [M]
- [ ] Test: veta a medias sobrevive a guardado/carga [M]
- [ ] Test: respawn con ocupacion reintenta hasta liberarse [M]
- [ ] Test: sin drops duplicados entre M15 y mineria [M]
- [ ] Test: 24 h simuladas con reloj M30 sin desincronizar timers [M]
- [ ] Profiler en cueva con 50 vetas activas [C]
- [ ] Recorrido cozy completo: cantera, cueva norte y Templo sin fallos [C]