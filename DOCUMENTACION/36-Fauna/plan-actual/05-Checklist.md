**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Modulo 36: Fauna

## A. Catalogo y contenido de especies (14)

- [x] Definir el id unico de cada especie en kebab-case (27 definidos) [S]
- [x] Definir nombre visible y nombre cientifico por especie para fichas M37 [S]
- [x] Definir bioma principal por especie segun M09 (playa, humedal, ribera, pradera, bosque, bosque ancestral, montana, oceano, cueva) [S]
- [x] Definir rareza escalonada: comun 14, poco comun 7, rara 5, muy rara 3 [S]
- [x] Definir ventana horaria por especie (diurna, crepuscular, nocturna, alba, toda hora) [S]
- [x] Definir estaciones activas por especie segun M29 [S]
- [x] Definir requisito de clima especial por especie (lluvia, niebla, nieve, noche limpia, luna llena) [S]
- [x] Definir comportamiento por especie (huida instintiva, huida suave, curiosa, pasiva, pasiva aerea, pasiva marina) [S]
- [x] Definir clase por especie (terrestre, acuatica, aerea, anfibia) [S]
- [x] Definir escala minima y maxima (cria/adulto) por especie [S]
- [x] Definir 2-3 variantes de color por especie [M]
- [x] Definir radios de alarma y curiosidad por especie (valores coherentes con el tamano) [S]
- [x] Definir velocidades de deambular, huida y factor de miedo base por especie [M]
- [x] Definir 27 recursos .tres de especies validados por FaunaCatalog [M]

## B. Comportamiento y FSM de FaunaBehavior (14)

- [x] Implementar enum de estados: INACTIVO, DEAMBULAR, ALIMENTARSE, DESCANSAR, ALERTA, HUIDA, CURIOSA_ACERCARSE, OBSERVANDO_JUGADOR [S]
- [x] Implementar transicion de INACTIVO a DEAMBULAR al despertar de la receta lejana [S]
- [x] Implementar deambular por puntos cercanos delegando a M65 [M]
- [x] Implementar estado ALIMENTARSE en zonas de alimento del bioma (M65) [M]
- [x] Implementar estado DESCANSAR con horarios compatibles con la ventana de la especie [M]
- [x] Implementar ALERTA al detectar jugador en el radio de alarma sin correr [M]
- [x] Implementar HUIDA no violenta: fuga en curva con separacion de obstaculos (M65) [M]
- [x] Implementar velocidad de huida como multiplo configurado por especie [S]
- [x] Implementar CURIOSA_ACERCARSE solo para especies curiosas y jugador quieto [M]
- [x] Implementar OBSERVANDO_JUGADOR: el animal se detiene y mira (sin bloquear al jugador) [S]
- [x] Implementar factor de miedo individual +-10 % por PRNG M29 [S]
- [x] Implementar reevaluacion tras huida: el animal se detiene a distancia segura y vuelve a deambular [M]
- [x] Implementar colision blanda con el jugador (sin dano, sin empuje agresivo) [S]
- [x] Implementar pausa M29: behavior congelado sin desincronizar horarios [S]

## C. FaunaSpawner y biomas M09 (14)

- [x] Implementar burbuja de spawn centrada en el jugador (radio 72 m) [M]
- [x] Implementar tick de spawn de 1 s con candidatos por celda [M]
- [x] Implementar consulta de bioma M09 en posicion candidata [M]
- [x] Implementar cache de bioma (maximo 20 celdas) para no abusar de M09 [M]
- [x] Implementar filtro de especie por bioma valido [S]
- [x] Implementar filtro por ventana horaria M31 [S]
- [x] Implementar filtro por estacion M29 [S]
- [x] Implementar filtro por clima M32 y clima especial de la especie [M]
- [x] Implementar validacion de superficie: terrestres no spawnean en agua ni pendientes extremas [M]
- [x] Implementar exclusion de interiores de edificios y volumenes M17 [M]
- [x] Implementar validacion de masa de agua para especies acuaticas [M]
- [x] Implementar manadas 2-5 solo para especies gregarias [M]
- [x] Implementar distancia minima entre individuos (anti-apilamiento) [M]
- [x] Implementar despawn con fade a mas de 96 m [S]

## D. Registro, diario y dedupe (14)

- [x] Implementar FaunaRegistry como autoload (unica autoridad de descubrimientos) [S]
- [x] Implementar estados por especie: NO_AVISTADA, AVISTADA, FOTOGRAFIADA [S]
- [x] Implementar registro de encuentro con contexto (fecha, hora, clima, bioma) [M]
- [x] Implementar dedupe por instancia: el mismo individuo no repite entrada [M]
- [x] Implementar dedupe temporal: mismo individuo a menos de 30 s no re-registra [M]
- [x] Implementar deteccion de avistamiento por distancia y especie en pantalla [M]
- [x] Implementar tolerancia minima de 0.5 s en pantalla antes de registrar (evita destellos) [S]
- [x] Implementar ficha de especie bloqueada (silueta + pista) antes del primer avistamiento [M]
- [x] Implementar ficha completa despues del primer avistamiento [S]
- [x] Implementar pista del diario por especie no avistada [M]
- [x] Implementar contador de avistamientos por especie [S]
- [x] Implementar senal especie_avistada con contexto completo [S]
- [x] Implementar senal diario_cambio para refrescar UI sin acoplamiento [S]
- [x] Implementar consulta de historial para la UI del diario (sin estado en UI) [M]

## E. Integracion con M65 Animales IA (10)

- [x] Definir contrato de delegacion: M36 setea personalidad, M65 ejecuta movimiento y estados base [M]
- [x] Implementar paso de parametros al animal M65 al instanciar (velocidades, radios) [M]
- [x] Implementar deambular por puntos con evitacion M65 [M]
- [x] Implementar alimentacion y descanso como estados base de M65 [M]
- [x] Implementar huida usando la primitiva de M65 (huida no violenta) [M]
- [x] Implementar sonidos contextuales de la especie via M65 (M43/M44) [M]
- [x] Implementar sincronia de horario: animal lejano en receta congelada (M65) [M]
- [x] Implementar anti-solapamiento entre individuos (separacion suave) [M]
- [x] Garantizar que ninguna especie ataca ni hace dano al jugador [S]
- [x] Garantizar que el jugador nunca es bloqueado por manadas (los animales ceden el paso) [S]

## F. Integracion con M56 Fotografia (10)

- [x] Definir contrato de senal foto_con_fauna(foto_id, especie_id, contexto) [S]
- [x] Implementar suscripcion de FaunaRegistry a M56 [S]
- [x] Implementar marcado FOTOGRAFIADA al recibir foto valida [S]
- [x] Implementar almacenamiento de foto_id por especie en el registro [M]
- [x] Implementar senal especie_fotografiada hacia M37 [S]
- [x] Implementar deteccion de especie en frustum por M56 (distancia maxima de foto valida) [M]
- [x] Implementar recompensa de cercania: especie quieta y cerca es mas facil de fotografiar [M]
- [x] Implementar bloqueo de foto valida si el animal esta en HUIDA (foto borrosa descartada) [M]
- [x] Implementar mensaje de diario al fotografiar por primera vez (ficha dorada) [M]
- [x] Implementar fallback: si M56 no esta disponible, el registro sigue funcionando solo con avistamientos [S]

## G. Integracion con M37 Museos (8)

- [x] Implementar porcentaje_descubierto() para el contador global del museo [S]
- [x] Implementar envio de fichas completas (nombre, cientifico, foto, biologa) al museo [M]
- [x] Implementar desbloqueo de vitrina por especie al ser FOTOGRAFIADA [M]
- [x] Implementar desbloqueo de placa informativa por especie al ser AVISTADA [M]
- [x] Implementar siluetas "pendiente de descubrir" en la sala del museo [M]
- [x] Implementar contador "X de 27 especies descubiertas" en la sala [S]
- [x] Implementar recompensa de museo al completar 100 % de la fauna [M]
- [x] Implementar sincronizacion de descubrimientos nuevos con la sala en tiempo real (sin recargar escena) [M]

## H. Tiempo, estaciones, clima y especies raras (12)

- [x] Implementar re-evaluacion de spawn al cambiar la hora (M31) [M]
- [x] Implementar re-evaluacion de spawn al cambiar la estacion (M29) [M]
- [x] Implementar re-evaluacion inmediata al cambiar el clima (M32) [M]
- [x] Implementar Lombriz Luminosa solo tras lluvia (clima lluvia reciente + noche) [M]
- [x] Implementar Tortuga de Concha Lunar solo en noches de luna llena [M]
- [x] Implementar Mariposa Lunar solo en noches despejadas de primavera [M]
- [x] Implementar Lince Ancestral solo en noches de nieve (invierno) [M]
- [x] Implementar Lemur de las Nieblas solo con niebla densa [M]
- [x] Implementar desaparicion suave de especies condicionadas al romperse la condicion [M]
- [x] Implementar migracion estacional: especies que cambian de bioma activo segun estacion [M]
- [x] Implementar aviso sutil en el diario: "despues de la lluvia..." como pista de clima [S]
- [x] Implementar prueba de 24 h simuladas con clima forzado para validar todas las ventanas [M]

## I. Optimizacion y presupuesto (10)

- [x] Implementar pool de instancias por especie (sin allocs en spawn) [M]
- [x] Implementar limite de 40 individuos activos en burbuja [M]
- [x] Implementar limite de 6 individuos por especie simultaneos [M]
- [x] Implementar receta lejana: fuera de burbuja el animal queda congelado sin pathfinding [M]
- [x] Implementar LOD de animacion simplificada a partir de 40 m [M]
- [x] Implementar tick de behavior de 0.2 s solo dentro de la burbuja [M]
- [x] Implementar cache de bioma para reducir consultas M09 a 20 por tick [M]
- [x] Implementar desinstalacion de recetas lejanas al acumular individuos en zonas vacias [M]
- [x] Verificar con profiler M113: 40 activos sin picos en frame time [C]
- [x] Verificar que sin fauna cerca (zona desierta) el coste sea practicamente cero [M]

## J. Persistencia y determinismo (8)

- [x] Implementar serializacion JSON versionada (version 1) en user://fauna/registro.json [M]
- [x] Implementar backup rotativo (2 copias) antes de sobrescribir el registro [M]
- [x] Implementar carga con migracion incremental por version [M]
- [x] Implementar inicializacion de especies desconocidas como NO_AVISTADA al migrar [S]
- [x] Implementar determinismo de spawn por PRNG de partida M29 [M]
- [x] Implementar determinismo de manadas, variantes y factor de miedo por PRNG [M]
- [x] Implementar proteccion de save corrupto: fallback a registro vacio + log (M122) [M]
- [x] Implementar test de determinismo: misma semilla genera la misma poblacion [C]

## K. Edge cases y manejo de errores (12)

- [x] Manejar avistamiento duplicado del mismo individuo (dedupe confirmado en 3 aproximaciones) [M]
- [x] Manejar especie que pierde su condicion climatica a mitad de avistamiento [S]
- [x] Manejar spawn con presupuesto saturado: se salta y reintenta el proximo tick [S]
- [x] Manejar bioma devuelto como desconocido por M09 (no spawnea nada) [S]
- [x] Manejar manada incompleta (tick de spawn cortado) [S]
- [x] Manejar jugador teletransportandose (fast travel M69): burbuja se re-centra sin residuos [M]
- [x] Manejar pausa de juego a mitad de huida [S]
- [x] Manejar foto tomada de especie ya fotografiada (no duplica, reemplaza la mejor) [M]
- [x] Manejar catalogo con id duplicado (error de validacion + log) [S]
- [x] Manejar catalogo con bioma inexistente en M09 (advertencia sin crash) [S]
- [x] Manejar raton/UI abriendo el diario mientras se registra un avistamiento [S]
- [x] Manejar frames bajos (0.2 s de tick de spawn se alarga): sin acumular instancias dobles [M]

## L. Pruebas y QA (8)

- [x] Test unitario: FaunaCatalog valida 27 especies sin errores [M]
- [x] Test unitario: dedupe bloquea entrada duplicada por instancia [M]
- [x] Test de integracion: fotografia M56 marca FOTOGRAFIADA y llega a M37 [M]
- [x] Test de integracion: lombriz luminosa solo aparece tras lluvia [M]
- [x] Test de 24 h simuladas: todas las ventanas horarias cumplidas con clima forzado [C]
- [x] Prueba de 3 dias de recorrido M114: todos los biomas, sin excepciones en consola [C]
- [x] Prueba de rendimiento M113: 40 activos sin picos, zero allocs en spawn [C]
- [x] Verificacion final cozy: cero dano posible contra fauna en ningun estado del juego [S]

## M. Documentacion y cierre (8)

- [x] Crear 01-Requerimientos.md firmado [S]
- [x] Crear 02-Analisis.md firmado [S]
- [x] Crear 03-Diseno.md firmado [S]
- [x] Crear 04-Codigo.md con Notas del Agente firmadas [S]
- [x] Crear 05-Checklist.md firmado (este archivo) [S]
- [x] Registrar los contratos M56/M37/M65/M09 en las fichas de integracion del proyecto [S]
- [x] Copiar la documentacion completa a plan-actual [S]
- [x] Generar log en Logs/ al implementar el modulo (DoD) [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
