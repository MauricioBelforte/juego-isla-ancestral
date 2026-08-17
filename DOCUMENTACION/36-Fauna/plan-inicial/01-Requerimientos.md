**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 36: Fauna

## ID del Módulo
- **Código:** M36 (Fauna)
- **Carpeta:** `DOCUMENTACION/36-Fauna/`
- **Dependencias:** M65 (Animales IA), M09 (Biomas), M56 (Fotografía), M37 (Museos). Relaciones: M29 (Tiempo y Calendario), M31 (Ciclo Día/Noche), M32 (Clima), M08 (Mundo Voxel), M103 (Logging), M61 (Rendimiento).
- **Delegable desde:** tras M65 (runtime de animales) y M09 (biomas). El diseño de contenido (especies) puede iniciarse en paralelo.

## 1. Problema

Poblar la isla ancestral de fauna viva y creíble que refuerce la fantasía cozy del juego: la fauna **no se caza, no se captura y no recibe daño**. Los animales existen para ser observados, fotografiados y registrados en un diario/catálogo que alimenta la colección del museo (M37). El desafío es dar vida a criaturas (terrestres, acuáticas, aéreas y ancestrales) con comportamientos diferenciados (huida instintiva, curiosidad, pasividad, nocturnidad), distribución por bioma (M09), presencia estacional y condicionada al clima, todo bajo un presupuesto de spawn y rendimiento acotado.

## 2. Principio de Diseño Innegociable (Cozy)

- **Cero daño:** los animales no son atacables, no pierden vida, no existen botones de captura ni herramientas de caza.
- **Sin explotación:** no hay granjas de farmeo de criaturas, ni recolección de partes, ni comercio de animales.
- **Observación respetuosa:** acercarse demasiado rápido o en diagonal asusta (huida suave); esperar quieto o usar la cámara (M56) premia con acercamientos y especies tímidas.
- **La fauna es un ecosistema:** cada especie tiene horario, estación, bioma y conducta; el mundo "vive" con o sin el jugador (simulación ligera lejana).

## 3. Catálogo de Fauna (por Bioma M09)

Cada especie posee: ID único, bioma principal, rareza, ventana horaria, estación, clima especial, comportamiento y notas de avistamiento.

| Especie | Bioma (M09) | Rareza | Horario | Estación | Comportamiento | Clima especial |
|---|---|---|---|---|---|---|
| Cangrejo Ermitaño | Playa | Común | Diurno | Todas | CURIOSO (se acerca lentamente) | aparece tras la marea alta |
| Gaviota Crestada | Playa | Común | Diurno | Todas | CURIOSO (se acerca si hay quietud) | vuela bajo antes de tormenta |
| Estrella de Arena | Playa | Común | Crepúsculo | Todas | PASIVO (estático, brillo suave) | solo en noches despejadas |
| Tortuga de Concha Lunar | Playa | Rara | Nocturno | Verano | PASIVO (anida en arena) | noches de luna llena |
| Rana Ancestral | Humedal | Común | Noche | Primavera/Verano | CURIOSO (croa al acercarse) | aparece en charcas tras lluvia |
| Garza del Amanecer | Humedal | Poco común | Alba | Todas | HUIDA SUAVE (vuela si se asusta) | niebla matinal |
| Libélula Radiante | Humedal | Poco común | Diurno | Primavera | HUIDA RÁPIDA (zigzag) | tras lluvia leve |
| Nutria del Río | Ribera | Poco común | Diurno | Todas | CURIOSO (observa desde el agua) | crecida suave de río |
| Salmón Saltarín | Ribera | Común | Crepúsculo | Otoño | PASIVO (salta en cascadas) | niebla otoñal |
| Conejo de Las Praderas | Pradera | Común | Diurno | Todas | HUIDA SUAVE (conejera cercana) | — |
| Cierva de Aurora | Pradera | Poco común | Diurno | Todas | CURIOSO (se acerca si no corres) | flores en primavera |
| Marmota Vigía | Pradera | Común | Diurno | Todas | CURIOSO (silba como alarma) | días despejados |
| Ardilla Recolectora | Bosque | Común | Diurno | Otoño | CURIOSO (roba bellotas, no molesta) | — |
| Zorro de Cola Luminosa | Bosque | Rara | Nocturno | Todas | HUIDA RÁPIDA (teleport suave con destellos) | noches sin lluvia |
| Búho de las Raíces | Bosque | Poco común | Nocturno | Todas | PASIVO (vigila desde ramas) | — |
| Ciervo de Astas de Cristal | Bosque Ancestral | Rara | Alba | Primavera | HUIDA SUAVE (lentísimo, tembloroso) | rocío de madrugada |
| Mariposa Lunar | Bosque Ancestral | Rara | Nocturno | Primavera/Verano | CURIOSO (revolotea cerca de la luz de la cámara) | noches despejadas |
| Lémur de las Nieblas | Bosque Ancestral | Muy rara | Crepúsculo | Todas | CURIOSO (aparece y desaparece en niebla) | niebla densa |
| Lince Ancestral | Bosque Ancestral | Muy rara | Nocturno | Invierno | HUIDA INSTINTIVA (se esconde entre los árboles) | noches de nieve |
| Cabra de los Picos | Montaña | Poco común | Diurno | Todas | CURIOSO (trepa, no teme a las alturas) | días claros |
| Águila Roca | Montaña | Rara | Diurno | Todas | PASIVO AÉREO (circunda a distancia) | corrientes de viento |
| Armiño del Paso | Montaña | Poco común | Diurno | Invierno | HUIDA SUAVE (muda de pelaje) | nevadas |
| Delfín de la Bahía | Océano | Rara | Diurno | Verano | CURIOSO (acompaña barcas, salta) | mar en calma |
| Mantarraya Serena | Océano | Rara | Crepúsculo | Todas | PASIVO MARINO (planea al fondo) | — |
| Murciélago Ancestral | Cueva | Poco común | Nocturno | Todas | HUIDA RÁPIDA (bandada pequeña) | — |
| Pez Ciego de la Gruta | Cueva | Común | Siempre | Todas | PASIVO (brilla tenue en la oscuridad) | — |
| Lombriz Luminosa | Humedal/Tierra | Poco común | Noche | Primavera | PASIVO (emerge tras lluvia) | **solo tras lluvia** (especie rara condicionada al clima) |

Total del catálogo inicial: **27 especies** (expandibles vía `especies/*.tres` sin tocar código).

## 4. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Catálogo de especies | 27 especies en datos (Resource .tres), cargadas por ID; cada una define bioma, rareza, horario, estación, clima, comportamiento y métricas (escala, velocidad, radios) |
| RF2 | Comportamiento por especie | Cuatro personalidades: HUIDA INSTINTIVA, HUIDA SUAVE, CURIOSO (acercamiento) y PASIVO (observar); parámetros por especie (distancia de alarma, distancia de curiosidad, velocidad de huida) |
| RF3 | Horarios y estaciones | Filtros de spawn por hora (M31) y estación (M29); especies nocturnas/albales/crepusculares; migración estacional (cambia bioma activo según estación) |
| RF4 | Especies raras condicionadas al clima | Algunas especies solo aparecen con clima específico (M32): Lombriz Luminosa solo tras lluvia, Tortuga Lunar solo luna llena, Lince Ancestral solo nevada nocturna; el spawner re-evalúa al cambiar el clima |
| RF5 | Sin captura ni daño | No existen interacciones de daño/captura; las colisiones del jugador no lesionan; la huida reemplaza cualquier "combate" |
| RF6 | Registro y diario | FaunaRegistry guarda descubrimientos por especie: estado (NO_AVISTADA, AVISTADA, FOTOGRAFIADA), lugar, fecha, hora, clima y recuento de avistamientos |
| RF7 | Avistamiento y dedupe | Un avistamiento válido (distancia minima y en pantalla) se registra una sola vez por instancia; duplicados del mismo individuo no repiten entrada; especie ya descubierta muestra su ficha sin duplicar |
| RF8 | Fotografía (M56) | Si el jugador fotografía una especie (M56), se marca FOTOGRAFIADA y se abre una entrada de museo M37; fotos de instancias únicas (dónde/cuándo) quedan en el diario |
| RF9 | Spawn por bioma (M09) | El spawner consulta el bioma del voxel (M09) y elige el pool de especies válido; terrestres evitan agua profunda y pendientes; acuáticos exigen cuerpo de agua |
| RF10 | Presupuesto de población | Límites: especies por área, individuos por especie y total activo; manadas (2-5) solo para especies gregarias; despawn por distancia |
| RF11 | Determinismo | Spawn y comportamiento base por PRNG de partida M29; mismas semillas -> misma isla (reproducibilidad entre cargas) |
| RF12 | Persistencia | Registro de avistamientos y fotos persistido (JSON en `user://`); el diario sobrevive a reinicios; migración de datos con versión de archivo |

## 5. Requisitos No Funcionales

- **Cozy (innegociable):** cero violencia contra fauna; sonidos suaves (no agresivos); nunca bloquear al jugador (los animales ceden el paso); ninguna especie "hostil".
- **Rendimiento (M61):** máx 40 individuos activos en la burbuja (radio 72 m); behavior tick 0.2 s; sin pathfinding continuo (M65 gestiona deambular local); LOD/animación simplificada fuera de 40 m; despawn duro a 96 m con fade.
- **Diversidad visual:** variantes de color (2-3 por especie) y de tamaño (cría/adulto) para evitar hordas idénticas.
- **Determinismo suave:** PRNG M29 para spawn, manadas y personalidad (pH de miedo individual ±10 %).
- **Accesibilidad:** modo "fauna tranquila" (opcional) reduce huida; indicador de avistamiento claro (icono/ficha sin ruido visual).
- **Sin acoplamiento de UI:** el registro vive en capa de datos; la UI del diario consume estado mediante señales.

## 6. Criterios de Aceptación

1. Las 27 especies del catálogo existen como recursos y spawnean en su bioma/horario/estación/clima correspondiente.
2. La fauna nunca recibe daño ni puede ser capturada (verificado en QA).
3. Los avistamientos se registran una vez por individuo; el dedupe funciona con repeticiones del mismo individuo.
4. Fotografiar (M56) una especie la marca FOTOGRAFIADA y desbloquea la entrada de museo (M37).
5. La Lombriz Luminosa solo aparece tras lluvia (clima M32) y la Tortuga de Concha Lunar solo en noches de luna llena.
6. El presupuesto de la sección 5 se respeta en el mapa completo (profiler M113).
7. El diario/registro persiste entre partidas y migra su formato.
8. Cero colisiones de rendimiento ni excepciones en console tras 3 días simulados de recorrido (M114).