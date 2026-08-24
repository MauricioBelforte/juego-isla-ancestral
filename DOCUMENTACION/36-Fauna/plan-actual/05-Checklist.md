**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Modulo 36: Fauna

## A. Catalogo y contenido de especies (14)

- [ ] Definir el id unico de cada especie en kebab-case (27 definidos) [S]
- [ ] Definir nombre visible y nombre cientifico por especie para fichas M37 [S]
- [ ] Definir bioma principal por especie segun M09 (playa, humedal, ribera, pradera, bosque, bosque ancestral, montana, oceano, cueva) [S]
- [ ] Definir rareza escalonada: comun 14, poco comun 7, rara 5, muy rara 3 [S]
- [ ] Definir ventana horaria por especie (diurna, crepuscular, nocturna, alba, toda hora) [S]
- [ ] Definir estaciones activas por especie segun M29 [S]
- [ ] Definir requisito de clima especial por especie (lluvia, niebla, nieve, noche limpia, luna llena) [S]
- [ ] Definir comportamiento por especie (huida instintiva, huida suave, curiosa, pasiva, pasiva aerea, pasiva marina) [S]
- [ ] Definir clase por especie (terrestre, acuatica, aerea, anfibia) [S]
- [ ] Definir escala minima y maxima (cria/adulto) por especie [S]
- [ ] Definir 2-3 variantes de color por especie [M]
- [ ] Definir radios de alarma y curiosidad por especie (valores coherentes con el tamano) [S]
- [ ] Definir velocidades de deambular, huida y factor de miedo base por especie [M]
- [ ] Definir 27 recursos .tres de especies validados por FaunaCatalog [M]

## B. Comportamiento y FSM de FaunaBehavior (14)

- [ ] Implementar enum de estados: INACTIVO, DEAMBULAR, ALIMENTARSE, DESCANSAR, ALERTA, HUIDA, CURIOSA_ACERCARSE, OBSERVANDO_JUGADOR [S]
- [ ] Implementar transicion de INACTIVO a DEAMBULAR al despertar de la receta lejana [S]
- [ ] Implementar deambular por puntos cercanos delegando a M65 [M]
- [ ] Implementar estado ALIMENTARSE en zonas de alimento del bioma (M65) [M]
- [ ] Implementar estado DESCANSAR con horarios compatibles con la ventana de la especie [M]
- [ ] Implementar ALERTA al detectar jugador en el radio de alarma sin correr [M]
- [ ] Implementar HUIDA no violenta: fuga en curva con separacion de obstaculos (M65) [M]
- [ ] Implementar velocidad de huida como multiplo configurado por especie [S]
- [ ] Implementar CURIOSA_ACERCARSE solo para especies curiosas y jugador quieto [M]
- [ ] Implementar OBSERVANDO_JUGADOR: el animal se detiene y mira (sin bloquear al jugador) [S]
- [ ] Implementar factor de miedo individual +-10 % por PRNG M29 [S]
- [ ] Implementar reevaluacion tras huida: el animal se detiene a distancia segura y vuelve a deambular [M]
- [ ] Implementar colision blanda con el jugador (sin dano, sin empuje agresivo) [S]
- [ ] Implementar pausa M29: behavior congelado sin desincronizar horarios [S]

## C. FaunaSpawner y biomas M09 (14)

- [ ] Implementar burbuja de spawn centrada en el jugador (radio 72 m) [M]
- [ ] Implementar tick de spawn de 1 s con candidatos por celda [M]
- [ ] Implementar consulta de bioma M09 en posicion candidata [M]
- [ ] Implementar cache de bioma (maximo 20 celdas) para no abusar de M09 [M]
- [ ] Implementar filtro de especie por bioma valido [S]
- [ ] Implementar filtro por ventana horaria M31 [S]
- [ ] Implementar filtro por estacion M29 [S]
- [ ] Implementar filtro por clima M32 y clima especial de la especie [M]
- [ ] Implementar validacion de superficie: terrestres no spawnean en agua ni pendientes extremas [M]
- [ ] Implementar exclusion de interiores de edificios y volumenes M17 [M]
- [ ] Implementar validacion de masa de agua para especies acuaticas [M]
- [ ] Implementar manadas 2-5 solo para especies gregarias [M]
- [ ] Implementar distancia minima entre individuos (anti-apilamiento) [M]
- [ ] Implementar despawn con fade a mas de 96 m [S]

## D. Registro, diario y dedupe (14)

- [ ] Implementar FaunaRegistry como autoload (unica autoridad de descubrimientos) [S]
- [ ] Implementar estados por especie: NO_AVISTADA, AVISTADA, FOTOGRAFIADA [S]
- [ ] Implementar registro de encuentro con contexto (fecha, hora, clima, bioma) [M]
- [ ] Implementar dedupe por instancia: el mismo individuo no repite entrada [M]
- [ ] Implementar dedupe temporal: mismo individuo a menos de 30 s no re-registra [M]
- [ ] Implementar deteccion de avistamiento por distancia y especie en pantalla [M]
- [ ] Implementar tolerancia minima de 0.5 s en pantalla antes de registrar (evita destellos) [S]
- [ ] Implementar ficha de especie bloqueada (silueta + pista) antes del primer avistamiento [M]
- [ ] Implementar ficha completa despues del primer avistamiento [S]
- [ ] Implementar pista del diario por especie no avistada [M]
- [ ] Implementar contador de avistamientos por especie [S]
- [ ] Implementar senal especie_avistada con contexto completo [S]
- [ ] Implementar senal diario_cambio para refrescar UI sin acoplamiento [S]
- [ ] Implementar consulta de historial para la UI del diario (sin estado en UI) [M]

## E. Integracion con M65 Animales IA (10)

- [ ] Definir contrato de delegacion: M36 setea personalidad, M65 ejecuta movimiento y estados base [M]
- [ ] Implementar paso de parametros al animal M65 al instanciar (velocidades, radios) [M]
- [ ] Implementar deambular por puntos con evitacion M65 [M]
- [ ] Implementar alimentacion y descanso como estados base de M65 [M]
- [ ] Implementar huida usando la primitiva de M65 (huida no violenta) [M]
- [ ] Implementar sonidos contextuales de la especie via M65 (M43/M44) [M]
- [ ] Implementar sincronia de horario: animal lejano en receta congelada (M65) [M]
- [ ] Implementar anti-solapamiento entre individuos (separacion suave) [M]
- [ ] Garantizar que ninguna especie ataca ni hace dano al jugador [S]
- [ ] Garantizar que el jugador nunca es bloqueado por manadas (los animales ceden el paso) [S]

## F. Integracion con M56 Fotografia (10)

- [ ] Definir contrato de senal foto_con_fauna(foto_id, especie_id, contexto) [S]
- [ ] Implementar suscripcion de FaunaRegistry a M56 [S]
- [ ] Implementar marcado FOTOGRAFIADA al recibir foto valida [S]
- [ ] Implementar almacenamiento de foto_id por especie en el registro [M]
- [ ] Implementar senal especie_fotografiada hacia M37 [S]
- [ ] Implementar deteccion de especie en frustum por M56 (distancia maxima de foto valida) [M]
- [ ] Implementar recompensa de cercania: especie quieta y cerca es mas facil de fotografiar [M]
- [ ] Implementar bloqueo de foto valida si el animal esta en HUIDA (foto borrosa descartada) [M]
- [ ] Implementar mensaje de diario al fotografiar por primera vez (ficha dorada) [M]
- [ ] Implementar fallback: si M56 no esta disponible, el registro sigue funcionando solo con avistamientos [S]

## G. Integracion con M37 Museos (8)

- [ ] Implementar porcentaje_descubierto() para el contador global del museo [S]
- [ ] Implementar envio de fichas completas (nombre, cientifico, foto, biologa) al museo [M]
- [ ] Implementar desbloqueo de vitrina por especie al ser FOTOGRAFIADA [M]
- [ ] Implementar desbloqueo de placa informativa por especie al ser AVISTADA [M]
- [ ] Implementar siluetas "pendiente de descubrir" en la sala del museo [M]
- [ ] Implementar contador "X de 27 especies descubiertas" en la sala [S]
- [ ] Implementar recompensa de museo al completar 100 % de la fauna [M]
- [ ] Implementar sincronizacion de descubrimientos nuevos con la sala en tiempo real (sin recargar escena) [M]

## H. Tiempo, estaciones, clima y especies raras (12)

- [ ] Implementar re-evaluacion de spawn al cambiar la hora (M31) [M]
- [ ] Implementar re-evaluacion de spawn al cambiar la estacion (M29) [M]
- [ ] Implementar re-evaluacion inmediata al cambiar el clima (M32) [M]
- [ ] Implementar Lombriz Luminosa solo tras lluvia (clima lluvia reciente + noche) [M]
- [ ] Implementar Tortuga de Concha Lunar solo en noches de luna llena [M]
- [ ] Implementar Mariposa Lunar solo en noches despejadas de primavera [M]
- [ ] Implementar Lince Ancestral solo en noches de nieve (invierno) [M]
- [ ] Implementar Lemur de las Nieblas solo con niebla densa [M]
- [ ] Implementar desaparicion suave de especies condicionadas al romperse la condicion [M]
- [ ] Implementar migracion estacional: especies que cambian de bioma activo segun estacion [M]
- [ ] Implementar aviso sutil en el diario: "despues de la lluvia..." como pista de clima [S]
- [ ] Implementar prueba de 24 h simuladas con clima forzado para validar todas las ventanas [M]

## I. Optimizacion y presupuesto (10)

- [ ] Implementar pool de instancias por especie (sin allocs en spawn) [M]
- [ ] Implementar limite de 40 individuos activos en burbuja [M]
- [ ] Implementar limite de 6 individuos por especie simultaneos [M]
- [ ] Implementar receta lejana: fuera de burbuja el animal queda congelado sin pathfinding [M]
- [ ] Implementar LOD de animacion simplificada a partir de 40 m [M]
- [ ] Implementar tick de behavior de 0.2 s solo dentro de la burbuja [M]
- [ ] Implementar cache de bioma para reducir consultas M09 a 20 por tick [M]
- [ ] Implementar desinstalacion de recetas lejanas al acumular individuos en zonas vacias [M]
- [ ] Verificar con profiler M113: 40 activos sin picos en frame time [C]
- [ ] Verificar que sin fauna cerca (zona desierta) el coste sea practicamente cero [M]

## J. Persistencia y determinismo (8)

- [ ] Implementar serializacion JSON versionada (version 1) en user://fauna/registro.json [M]
- [ ] Implementar backup rotativo (2 copias) antes de sobrescribir el registro [M]
- [ ] Implementar carga con migracion incremental por version [M]
- [ ] Implementar inicializacion de especies desconocidas como NO_AVISTADA al migrar [S]
- [ ] Implementar determinismo de spawn por PRNG de partida M29 [M]
- [ ] Implementar determinismo de manadas, variantes y factor de miedo por PRNG [M]
- [ ] Implementar proteccion de save corrupto: fallback a registro vacio + log (M122) [M]
- [ ] Implementar test de determinismo: misma semilla genera la misma poblacion [C]

## K. Edge cases y manejo de errores (12)

- [ ] Manejar avistamiento duplicado del mismo individuo (dedupe confirmado en 3 aproximaciones) [M]
- [ ] Manejar especie que pierde su condicion climatica a mitad de avistamiento [S]
- [ ] Manejar spawn con presupuesto saturado: se salta y reintenta el proximo tick [S]
- [ ] Manejar bioma devuelto como desconocido por M09 (no spawnea nada) [S]
- [ ] Manejar manada incompleta (tick de spawn cortado) [S]
- [ ] Manejar jugador teletransportandose (fast travel M69): burbuja se re-centra sin residuos [M]
- [ ] Manejar pausa de juego a mitad de huida [S]
- [ ] Manejar foto tomada de especie ya fotografiada (no duplica, reemplaza la mejor) [M]
- [ ] Manejar catalogo con id duplicado (error de validacion + log) [S]
- [ ] Manejar catalogo con bioma inexistente en M09 (advertencia sin crash) [S]
- [ ] Manejar raton/UI abriendo el diario mientras se registra un avistamiento [S]
- [ ] Manejar frames bajos (0.2 s de tick de spawn se alarga): sin acumular instancias dobles [M]

## L. Pruebas y QA (8)

- [ ] Test unitario: FaunaCatalog valida 27 especies sin errores [M]
- [ ] Test unitario: dedupe bloquea entrada duplicada por instancia [M]
- [ ] Test de integracion: fotografia M56 marca FOTOGRAFIADA y llega a M37 [M]
- [ ] Test de integracion: lombriz luminosa solo aparece tras lluvia [M]
- [ ] Test de 24 h simuladas: todas las ventanas horarias cumplidas con clima forzado [C]
- [ ] Prueba de 3 dias de recorrido M114: todos los biomas, sin excepciones en consola [C]
- [ ] Prueba de rendimiento M113: 40 activos sin picos, zero allocs en spawn [C]
- [ ] Verificacion final cozy: cero dano posible contra fauna en ningun estado del juego [S]

## M. Documentacion y cierre (8)

- [ ] Crear 01-Requerimientos.md firmado [S]
- [ ] Crear 02-Analisis.md firmado [S]
- [ ] Crear 03-Diseno.md firmado [S]
- [ ] Crear 04-Codigo.md con Notas del Agente firmadas [S]
- [ ] Crear 05-Checklist.md firmado (este archivo) [S]
- [ ] Registrar los contratos M56/M37/M65/M09 en las fichas de integracion del proyecto [S]
- [ ] Copiar la documentacion completa a plan-actual [S]
- [ ] Generar log en Logs/ al implementar el modulo (DoD) [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
