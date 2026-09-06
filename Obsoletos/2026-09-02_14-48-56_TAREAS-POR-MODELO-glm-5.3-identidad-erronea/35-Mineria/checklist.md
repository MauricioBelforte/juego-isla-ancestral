**Modelo:** glm-5.3
**Plataforma:** Cline

**Módulo:** 35-Mineria (35)

# Checklist personal tareas — 35-Mineria

> Extraídas del `05-Checklist.md` del módulo (83 pendientes de 142 ítems). Fuente de verdad del ítem: el `05-Checklist.md`.

## Tareas

- [ ] T-001 RF4: cuevas con vetas en paredes y techos [M] *(M35 iter 1 cubre datos; escenas M26 pendientes — fuera de iter 1)* *[?]*
- [ ] T-002 P1: disenar vetas — afloramientos de 1-3 bloques [S]
- [ ] T-003 P2: disenar minerales — tabla de 8+ minerales [S]
- [ ] T-004 P3: disenar niveles de profundidad — 3 bandas [S]
- [ ] T-005 P4: disenar cuevas — vetas incrustadas [S]
- [ ] T-006 P5: disenar materiales raros — oro, cristal, polvo de estrellas [S]
- [ ] T-007 P6: disenar minerales ancestrales — capa de M26 [S]
- [ ] T-008 P7: disenar herramientas — pico con durabilidad y poder [S]
- [ ] T-009 P8: disenar eficiencia — poder vs dureza [S]
- [ ] T-010 P9: disenar particulas — pool de chispas y extraccion [S]
- [ ] T-011 P10: disenar sonidos — golpe, extraccion, derrumbe [S]
- [ ] T-012 P11: disenar iluminacion — brillo propio de la veta [S]
- [ ] T-013 P12: disenar riesgos no violentos — deslumbramiento y caidas suaves [S]
- [ ] T-014 P13: disenar derrumbes controlados — solo entierran la veta [S]
- [ ] T-015 P14: disenar recursos secretos — nodos especiales de M26 [S]
- [ ] T-016 P15: disenar zonas de mineria — cantera, cueva norte, grutas [S]
- [ ] T-017 P16: disenar rutas — caminos de acceso a las zonas [S]
- [ ] T-018 P17: disenar estaciones — puestos de descanso y mejoras [S]
- [ ] T-019 P18: disenar nodos especiales — vetas gigantes raras [S]
- [ ] T-020 P19: disenar colecciones — registro de minerales [S]
- [ ] T-021 P20: disenar crafting asociado — lingotes y mejoras (M16) [S]
- [ ] T-022 P21: disenar economia — precios e intercambio (M36) [S]
- [ ] T-023 P22: disenar regeneracion — respawn lento por tiempo de juego [S]
- [ ] T-024 P23: disenar limites — tope suave diario por zona [S]
- [ ] T-025 P24: evitar mineria excesivamente repetitiva — cadencia y variedad [S]
- [ ] T-026 Color/emisivo de brillo por mineral [S] *(placeholder; assets de M45 pendientes)* *[?]*
- [ ] T-027 Escena de particulas de extraccion por mineral [S] *(placeholder; M52)* *[?]*
- [ ] T-028 Sonidos de golpe y extraccion por material [S] *(placeholder; M43)* *[?]*
- [ ] T-029 Desplazamiento suave si el jugador ocupa un bloque [M] *(M17 + M08; pendiente integracion)* *[?]*
- [ ] T-030 Actualizacion de la UI de durabilidad de M13 [S] *(pendiente M53 UI)* *[?]*
- [ ] T-031 Distribucion de vetas por chunk al generar el gen [M] *(M15 ResourceSpawner lo cubre; M35 hereda)* *[?]*
- [ ] T-032 Seleccion de mineral por profundidad y bioma con PRNG M29 [M] *(M15 lo cubre)* *[?]*
- [ ] T-033 Hook de post-generacion de chunk conectado [S]
- [ ] T-034 Escritura de bloques de mineral en el voxel [M]
- [ ] T-035 Remeshing diferido solo del chunk afectado [C]
- [ ] T-036 Colision por bloque de veta unificada con el voxel [S]
- [ ] T-037 Soporte garantizado: la veta nunca flota [S]
- [ ] T-038 Validacion de ocupacion reutilizando API de lectura M08 [M]
- [ ] T-039 Vetas en paredes y techos de cuevas [M]
- [ ] T-040 Iluminacion de brillo en vetas profundas [M]
- [ ] T-041 Compatible con el ahorro de memoria de chunks [S]
- [ ] T-042 Chunks ya editados no regeneran vetas [M]
- [ ] T-043 Fundicion de lingotes con minerales (M16) [S] *(fuera de iter 1 — dueno M16)* *[?]*
- [ ] T-044 Precios de venta coherentes con economia M36 [S] *(valor_venta en JSON; M38 economia pendiente)* *[?]*
- [ ] T-045 Capa de mineral ancestral solo en cuevas de M26 [S]
- [ ] T-046 Nodos especiales de cristal gigante sembrados por eventos de M26 [M]
- [ ] T-047 Zona ancestral accesible permanentemente tras completar el Templo [S]
- [ ] T-048 Iluminacion del Templo resalta vetas raras [S]
- [ ] T-049 Ninguna veta bloquea mecanismos ni puzzles (anti-softlock) [S]
- [ ] T-050 Acceso a cuevas desde el interior del Templo [S]
- [ ] T-051 Evento de derrumbe decorativo en la sala del mineral ancestral [S]
- [ ] T-052 Mineral ancestral registrado en la coleccion del jugador [S]
- [ ] T-053 Veta a medias: estado intermedio persistido y restaurado [M]
- [ ] T-054 Respawn con zona ocupada: reintento diferido [M]
- [ ] T-055 Respawn con jugador dentro: desplazamiento suave [M]
- [ ] T-056 Respawn con construccion M17 encima: espera al proximo dia [M]
- [ ] T-057 Guardar/cargar durante un golpe sin perdida de state [S]
- [ ] T-058 Doble clique rapido: cooldown descarta el segundo golpe [S]
- [ ] T-059 Veta en borde de chunk: sin duplicacion ni perdida [M]
- [ ] T-060 Herramienta rota a mitad de golpes: se interrumpe sin estado corrupto [S]
- [ ] T-061 Varias vetas en el mismo rayo: prioridad por cercania [M]
- [ ] T-062 Definicion ausente en catalogo: log DOM-MIN y fallback por defecto [S]
- [ ] T-063 Remeshing localizado y diferido por chunk [C]
- [ ] T-064 Pool de particulas de mineria [S]
- [ ] T-065 Sin allocs en el hot path de hit() [M]
- [ ] T-066 Raycast con mascara de colision exclusiva [S]
- [ ] T-067 Barrido de regeneracion iterativo sin crear nodos por veta [M]
- [ ] T-068 Profiler: golpe individual <= 1 ms CPU [M]
- [ ] T-069 Definiciones compartidas como Resource (memoria unica) [S]
- [ ] T-070 Frame budget global respetado en remeshing masivo [C]
- [ ] T-071 Particulas de chispas al golpear [S]
- [ ] T-072 Particulas de satisfaccion al extraer [S]
- [ ] T-073 Sonido de golpe distinto por material [S]
- [ ] T-074 Sonido de extraccion gratificante [S]
- [ ] T-075 Derrumbes controlados suaves y breves [S]
- [ ] T-076 Veta apagandose visualmente al agotarse [S]
- [ ] T-077 Chispa de anuncio dorada al recuperarse [S]
- [ ] T-078 Texto flotante con la cantidad obtenida [S]
- [ ] T-079 Vibracion ligera opcional al extraer [S]
- [ ] T-080 Interaccion consistente con el sistema de recursos M15 [S]
- [ ] T-081 Test: veta a medias sobrevive a guardado/carga [M] *(M15 cubre por nodo; M35 cubre zone_quota — pendiente prueba end-to-end con GameTime real)* *[?]*
- [ ] T-082 Profiler en cueva con 50 vetas activas [C] *(pendiente M61 benchmarks; no bloquea iter 1)* *[?]*
- [ ] T-083 Recorrido cozy completo: cantera, cueva norte y Templo sin fallos [C] *(pendiente M138/M26)* *[?]*
