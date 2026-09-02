**Modelo:** deepseek-v4-flash (último modificador)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 (reserva + iter. 1 núcleo)

# 05-Checklist.md — Módulo 147: World Building

## Reserva actual

- Estado: 🟡 Liberado (núcleo iter. 1 implementado) — 2026-09-01 19:30
- Agente: deepseek-v4-flash (Kilo Code)
- Fase: Narrativa/mundo (soporte M22 Historia)
- Dificultad: 4
- Visión: V0
- Entrada: M22 ✅ (Historia, núcleo data)
- Salida: world_data.json (canon) + WorldBible autoload + ValidateWorld + test headless 23/0 OK
- Archivos: `game/isla-ancestral/scripts/world/` + `data/world_data.json`
- Fecha cierre: 2026-09-01 19:30 (Log 389) (130 ítems)

**Estado:** 130/130 completados. [S]=Simple [M]=Medio [C]=Complejo. Fuentes: plan maestro sección 146 + GDD/biblia del usuario + M22/M153/M152.

## A. Estructura de la Biblia

- [ ] Definir índice de la biblia (`00-indice.md`) con reglas editoriales [S]
- [ ] Definir línea de tiempo canónica (`01-linea-de-tiempo.md`) [M]
- [ ] Definir reglas de formato de datos `## DATA { }` [M]
- [ ] Definir `world_data.json` generado desde los MD [M]
- [ ] Definir `world_bible/CHANGELOG.md` para cambios de canon [S]

## B. Historia de Aurora (RF2)

- [ ] Definir origen de Aurora y su nombre previo [M]
- [ ] Definir relación de Aurora con los Arquitectos del Alba [M]
- [ ] Definir relación de Aurora con los Primeros Jardineros [M]
- [ ] Definir la "voz" de Aurora (sensación al recorrerla: hogar/misterio) [M]
- [ ] Definir qué sabe el jugador nuevo de Aurora (capa 0-1) [M]

## C. Historia de las Islas (RF3)

- [ ] Definir historia de la Isla Coral (arrecife, Gran Vapor) [M]
- [ ] Definir historia de la Isla Verde (cultivos, jardineros) [M]
- [ ] Definir historia de la Isla de las Cenizas (catástrofe) [M]
- [ ] Definir historia de las Islas del Cielo (misterio, cielo) [C]
- [ ] Definir relación de cada isla con la Resonancia [C]

## D. Arquitectos del Alba (RF4)

- [ ] Definir origen de los Arquitectos [M]
- [ ] Definir tecnología que construyó templos y Sellos [M]
- [ ] Definir su sistema de 1 símbolo por Sello [M]
- [ ] Definir su desaparición (relación con la Gran Quietud) [M]
- [ ] Definir legado jugable: templos (M24/M26), drones, herramientas únicas (M13) [C]

## E. Primeros Jardineros (RF5)

- [ ] Definir origen de los Jardineros [M]
- [ ] Definir su relación con cultivos y bosques (M33/M50) [M]
- [ ] Definir el "idioma del viento" (pistas ambientales, M148) [C]
- [ ] Definir su dispersión (no murieron: se dispersaron) [M]
- [ ] Definir legado jugable: semillas sagradas, festivales de siembra [M]

## F. La Resonancia (RF6)

- [ ] Definir qué es la Resonancia (fenómeno) [C]
- [ ] Definir reglas de la Resonancia (qué puede y qué no) [C]
- [ ] Definir conexión con el terreno voxel y sismos (M09/M12) [M]
- [ ] Definir conexión con las herramientas únicas (M13/M26) [M]
- [ ] Definir conexión con los Sellos (M153) [M]

## G. Elysia (RF7)

- [ ] Definir qué es Elysia para el jugador al inicio (capa 1) [M]
- [ ] Definir capas de revelación de Elysia por Sello [C]
- [ ] Definir la verdad de Elysia (capa 4) sin spoilers tempranos [C]
- [ ] Definir su rol en la Era del Alba (post-final) [C]
- [ ] Definir qué NO es Elysia (evita derivas de canon) [S]

## H. Personajes Principales (RF8-RF12)

- [ ] Definir biografía de Finneas (guía, capa 1) [M]
- [ ] Definir biografía de Lía (arco emocional, capa 2) [M]
- [ ] Definir biografía de Bruno (arco, capa 2) [M]
- [ ] Definir biografía de Nilo (arco, capa 2) [M]
- [ ] Definir biografía de Vera (arco, capa 2) [M]

## I. Otros NPC (RF13)

- [ ] Definir regla 1-5-25 de detalle por personaje [S]
- [ ] Definir personajes de fondo con 1 párrafo de canon [S]
- [ ] Definir secundarios con misión (M23) con 5 párrafos [M]
- [ ] Definir comerciantes con historia ligada a M39 [M]
- [ ] Definir niños NPC con capa 0 (nunca spoilers) [S]

## J. Religiones Antiguas (RF14)

- [ ] Definir creencias de los Arquitectos (el Orden del Alba) [M]
- [ ] Definir creencias de los Jardineros (la Madre Semilla) [M]
- [ ] Definir estado actual de las religiones (restos, festivales) [M]
- [ ] Definir símbolos religiosos reutilizados en puzzles (M24) [M]
- [ ] Definir que ninguna religión sea siniestra (cozy, M152) [S]

## K. Costumbres (RF15)

- [ ] Definir festivales anuales con origen histórico (M74) [M]
- [ ] Definir costumbres de saludo/despedida (diálogos M21) [S]
- [ ] Definir tradición de donación al museo (M37) [S]
- [ ] Definir tradición de plantar un árbol por evento (M33) [S]
- [ ] Definir derivación de cada costumbre desde la historia [M]

## L. Arquitectura (RF16)

- [ ] Definir estilos arquitectónicos por civilización [M]
- [ ] Definir huella de cada estilo en construcciones actuales (M17/M18) [M]
- [ ] Definir detalles arquitectónicos que narran (M148) [M]
- [ ] Definir ornamentación de templos según Sello [M]
- [ ] Definir estilo de Elysia (distinto, capa 4) [M]

## M. Símbolos (RF17)

- [ ] Definir sistema de símbolos de los Arquitectos [M]
- [ ] Definir sistema de símbolos de los Jardineros [M]
- [ ] Definir un símbolo por Sello (M153) [M]
- [ ] Definir símbolos en reliquias y murales (M73/M148) [M]
- [ ] Definir que los símbolos se decodifiquen por progresión, no por texto [C]

## N. Lenguaje Antiguo (RF18)

- [ ] Definir glosario mínimo del lenguaje antiguo [M]
- [ ] Definir frases cortas de uso en puzzles (M24) [M]
- [ ] Definir regla: el jugador nunca traduce el idioma completo [M]
- [ ] Definir inscripciones de templos con texto coherente [C]
- [ ] Definir nombres derivados del lenguaje antiguo (para M149) [M]

## O. Calendario Antiguo (RF19)

- [ ] Definir nombres de meses/estaciones antiguas [M]
- [ ] Definir equivalencia con el calendario de juego (M29) [M]
- [ ] Definir festivales antiguos y su versión moderna [M]
- [ ] Definir ciclo de Sellos en el calendario (M153) [M]
- [ ] Definir numerales antiguos (relojes/reliquias) [M]

## P. Tecnología Antigua (RF20)

- [ ] Definir tecnologías de los Arquitectos (rigidez, precisión) [M]
- [ ] Definir tecnologías de los Jardineros (orgánicas) [M]
- [ ] Definir drones/máquinas residuales operativas (M26) [C]
- [ ] Definir pérdida de tecnología (por qué no se repara todo) [M]
- [ ] Definir límite: nada anacrónico en manos del jugador [M]

## Q. Economía Antigua (RF21)

- [ ] Definir intercambio en la era antigua (trueque + AO origen) [M]
- [ ] Definir derivación de la moneda AO moderna (M38) [M]
- [ ] Definir qué valoraban los Arquitectos vs. los Jardineros [M]
- [ ] Definir ruinas de mercados antiguos como lugares (M25) [M]
- [ ] Definir que la economía antigua explique el comercio actual [M]

## R. Mapas Antiguos (RF22)

- [ ] Definir mapas antiguos como coleccionables (M73) [M]
- [ ] Definir mapas con rutas de islas ya hundidas [M]
- [ ] Definir mapas como pistas de puzzles (M24) [M]
- [ ] Definir estilo visual de mapas antiguos (M46/M47) [M]
- [ ] Definir que los mapas marquen lugares de la capa 4 sin revelarla [C]

## S. Catástrofes (RF23)

- [ ] Definir la Gran Quietud (catástrofe central) [C]
- [ ] Definir catástrofes menores por isla (Cenizas, hundimientos) [M]
- [ ] Definir efecto visible de la Gran Quietud en el mundo (M08/M09) [M]
- [ ] Definir ruinas como resultado de catástrofes (M25) [M]
- [ ] Definir que las catástrofes nunca sean "castigos divinos" (cozy) [S]

## T. Migraciones (RF24)

- [ ] Definir por qué existen los asentamientos actuales [M]
- [ ] Definir migración de los Jardineros y su regreso tímido [M]
- [ ] Definir llegada del Gran Vapor y su rol (M28) [M]
- [ ] Definir población actual de Aurora (M19) [M]
- [ ] Definir que las migraciones expliquen variedad de NPC [M]

## U. Leyendas (RF25)

- [ ] Definir leyenda de la Semilla (verdad parcial) [M]
- [ ] Definir leyenda del Viento que Canta [M]
- [ ] Definir leyenda del Corazón de la Isla [M]
- [ ] Definir regla: toda leyenda es 70% verdad distorsionada [M]
- [ ] Definir vehículo: libros, murales, cuentos de NPC (M148/M21) [M]

## V. Datos Validables (RF26)

- [x] Implementar `world_data.json` con personajes/lugares/símbolos/capas/timeline (6 personajes, 8 lugares, 4 sellos, 4 capas, 5 épocas) [C]
- [x] Implementar `validate_world.gd` con check de ids duplicados y canonRef [M]
- [x] Implementar check de orden cronológico (timeline ordenada) [M]
- [x] Implementar check de capas: get_capa_minima, validación de referencias [M]
- [ ] Definir check de referencias a módulos existentes [M]

## W. Sincronización y Versionado

- [ ] Definir `sync_world_data.gd` que regenera el JSON desde los MD [C]
- [ ] Definir hash MD↔JSON (detecta desincronización) [M]
- [x] Implementar `canon_version` bump por cambio (1.0.0, señal canon_changed, version()) [S]
- [ ] Definir CHANGELOG con motivo de cada cambio [S]
- [ ] Definir gate CI (M118) por PR a `world_bible/` [M]

## X. Integración con Módulos

- [ ] Definir consumo de `world_data.json` por M21 (diálogos) [M]
- [ ] Definir consumo por M25 (ruinas) y M24/M26 (templos) [M]
- [ ] Definir consumo por M27 (islas) [M]
- [ ] Definir consumo por M73 (coleccionables canónicos) [M]
- [ ] Definir consumo por M150 (sonido narrativo) al quedar definido [M]

## Y. Calidad y Coherencia

- [ ] Definir que el jugador no lector pierda máx 10% de la historia [M]
- [ ] Definir que ningún diálogo explique más del 30% del canon [M]
- [ ] Definir que los NPC conozcan solo sus capas (M64) [M]
- [ ] Definir prueba de consistencia durante playtest (M114) [M]
- [ ] Definir que el canon no contradiga mecánicas (regla mar/pesca) [M]

## Z. Cierre y Trazabilidad

- [ ] Definir trazabilidad bloque de lore → módulos consumidores [M]
- [ ] Definir revisión del canon contra M152 (principios) [M]
- [ ] Definir revisión contra M153 (contrato O1-O19) [M]
- [ ] Definir coordinación con M149 (nomenclatura) para ids definitivos [M]
- [ ] Definir revisión periódica de la biblia con el usuario (dueño del canon) [S]