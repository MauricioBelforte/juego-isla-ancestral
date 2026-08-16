# 05 — Checklist — M65: Animales IA (100/100)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Implementación

- [x] Definir la arquitectura del sistema de fauna (orquestador bajo NPCManager) [M]
- [x] Crear FaunaProfile como ScriptableObject con datos por especie [M]
- [x] Definir los 10 estados de la FSM de fauna [M]
- [x] Implementar el estado Dormir con mínimo 30 s reales [M]
- [x] Implementar el estado Pastorear con FOV interior de 120° [M]
- [x] Implementar el estado Hidratarse en lagos y ríos navegables [M]
- [x] Implementar el estado Comer con fuentes comestibles por especie [M]
- [x] Implementar el estado Explorar con wander de bajo costo [M]
- [x] Implementar el estado Curiosear (jugador quieto o agachado) [M]
- [x] Implementar el estado Huir con huida radial no violenta [M]
- [x] Implementar el estado Migrar por rutas de etapas [M]
- [x] Implementar el estado Reproducir con nido y cría [C]
- [x] Implementar el estado Anclado para despawn y rehidratación [M]
- [x] Implementar PackLogic para manadas con líder rotativo [M]
- [x] Implementar SchoolLogic para bancos con delta ≤ 1.2 m [M]
- [x] Definir 6 especies de bosque (ciervo, cabra, jabalí, zorro, liebre, aves) [S]
- [x] Definir 4 especies acuáticas (peces, cangrejos, nutrias, patos) [S]
- [x] Definir 3 especies aéreas (gaviota, búho, murciélago) [S]
- [x] Definir 2 especies de montaña (cabra salvaje, águila) [S]
- [x] Definir 2 especies de pradera (oveja, grulla) [S]
- [x] Definir 1 especie nocturna de refugio (lechuza) [S]
- [x] Definir 1 especie rara/ancestral (búho gema, aparecer en eventos) [C]
- [x] Diseñar el perfil estacional de cada especie (M32) [M]
- [x] Diseñar variantes de color por bioma sin costo extra [S]
- [x] Diseñar crías con 3 etapas de crecimiento [M]

## Comportamiento herbívoro

- [x] Definir zonas de vegetación como fuentes de pastoreo [M]
- [x] Implementar reposición de alimento en la zona tras consumo [M]
- [x] Implementar fuga del pastor al detectar al jugador a 12 m [S]
- [x] Implementar retorno a manada tras la fuga [S]
- [x] Implementar liderazgo y reposición de líder en la manada [S]
- [x] Implementar descanso de manada en sombra/refugio [S]
- [x] Implementar alimentación con prioridad sobre explorar [M]
- [x] Implementar hambre lenta de 10 min reales sin comer [M]
- [x] Implementar emigración suave al agotar la hambre [M]
- [x] Documentar el comportamiento de la manada en el plan-actual [S]

## Comportamiento acuático

- [x] Implementar nado 3D con buceo [C]
- [x] Implementar banco con unidad de flujo y dispersión [M]
- [x] Implementar salto de peces en superficie con evento visual [S]
- [x] Implementar cangrejos costeros 2D con marea baja [M]
- [x] Implementar patos con zonas de flotación en lagos [S]
- [x] Implementar salida del agua por rampa navegable [M]
- [x] Implementar reacción a perturbación del agua (canguraje) [S]
- [x] Implementar despawn marino por lejanía con anclado [S]
- [x] Documentar el comportamiento acuático en el plan-actual [S]

## Comportamiento aéreo

- [x] Implementar vuelo con waypoints circulares [M]
- [x] Implementar perchas en árboles y rocas [S]
- [x] Implementar térmicas de ascenso [S]
- [x] Implementar separación vertical para no rozar la isla [M]
- [x] Implementar alarmas de aves al sentirse observadas [S]
- [x] Implementar vuelo nocturno del búho y murciélago [S]
- [x] Implementar migración columnata de aves (M36 visual) [M]
- [x] Implementar anclado aéreo fuera de burbuja [S]
- [x] Documentar el comportamiento aéreo en el plan-actual [S]

## Comportamiento nocturno

- [x] Implementar actividad nocturna según luminosidad de M31 [M]
- [x] Implementar día de reposo para nocturnos en refugio [S]
- [x] Implementar despertar por ruido o agua cercana [S]
- [x] Implementar luciérnagas decorativas en la noche [S]
- [x] Implementar ramo de búhos al anochecer (evento M42) [S]
- [x] Documentar el comportamiento nocturno en el plan-actual [S]

## Comportamiento migratorio y estacional

- [x] Implementar migración en ventana estacional (M32) [M]
- [x] Implementar migración en el horario temprano de la mañana [S]
- [x] Implementar rutas por etapas entre biomas [M]
- [x] Implementar marcadores de etapa con validación navegable [M]
- [x] Implementar regreso al bioma de origen en estación seca [M]
- [x] Implementar agrupación mayor en invierno (M31 temperatura) [S]
- [x] Implementar cambio de fuente de alimento según estación [M]
- [x] Implementar perfil estacional del pelaje (shader param) [S]
- [x] Documentar el comportamiento migratorio y estacional [S]

## Reproducción, descanso y alimentación

- [x] Implementar ciclo de reproducción por especie [C]
- [x] Implementar nido oculto con protección de observación [M]
- [x] Implementar cría con 3 etapas y crecimiento por días de juego (M29) [M]
- [x] Implementar sin loot de crías ni explotación [S]
- [x] Implementar madriguera para descanso nocturno de diurnos [M]
- [x] Implementar fuente de agua para cada especie acuática/terrestre [M]
- [x] Implementar hambre lenta y emigración sin muerte visible [M]
- [x] Implementar cooldown de sonido de alimentación [S]
- [x] Documentar reproducción, descanso y alimentación [S]

## Huida, curiosidad e interacción con entorno

- [x] Implementar huida radial con radio por especie [M]
- [x] Implementar retorno a explorar tras la huida [S]
- [x] Implementar curiosidad si el jugador está quieto/agachado (M57) [M]
- [x] Implementar umbral tímido de distancia por especie [S]
- [x] Implementar observación de 5 s y retirada [S]
- [x] Implementar reacción a agua perturbada y zonas alteradas [M]
- [x] Implementar rehidratación en lagos/ríos con animación [S]
- [x] Implementar sonido de curiosidad con cooldown (M43) [S]
- [x] Documentar huida, curiosidad e interacción [S]

## Sonidos contextuales

- [x] Definir tabla de timestamps de fauna (M42/M43) [S]
- [x] Implementar alarma de manada al huir (radio 40 m) [S]
- [x] Implementar canto de aves al amanecer/atardecer (M31) [S]
- [x] Implementar salpicadura de buceo (radio 20 m) [S]
- [x] Implementar roce en pastos al pastorear (radio 10 m) [S]
- [x] Implementar respeto de BusPriority y cooldowns [M]
- [x] Implementar evento de búho al anochecer [S]
- [x] Documentar sonidos contextuales en el plan-actual [S]

## Spawns y despawns

- [x] Implementar spawn por pesos de bioma con sorteo local [M]
- [x] Implementar densidad máxima por bioma [M]
- [x] Implementar validación de navegación del slot [M]
- [x] Implementar spawn con semilla determinística [M]
- [x] Implementar despawn fuera de burbuja con anclado [M]
- [x] Implementar rehidratación de estado completo al volver [M]
- [x] Implementar despawn de emigración sin residuos [M]
- [x] Implementar sin destrucción a mitad de cuadro [S]
- [x] Documentar spawns y despawns en el plan-actual [S]

## Optimización y población

- [x] Implementar presupuesto total de fauna (M61) [M]
- [x] Implementar instancing animado para grupos ≥ 8 [C]
- [x] Implementar pooling de FaunaBody sin allocations en Update [M]
- [x] Implementar tick 1 s para lejanos [M]
- [x] Implementar tope por manada y tope por bioma [S]
- [x] Implementar reintegro probabilístico si se supera el tope [S]
- [x] Implementar reducción de burbuja fauna antes que NPC [M]
- [x] Implementar watchdog anti-atasco 2 s/6 s [M]
- [x] Implementar teleport discreto en revalidación de chunk [M]
- [x] Documentar optimización y población en plan-actual [S]

## Integración y terreno modificado

- [x] Integrar registro de fauna con M36 (avistamiento, no caza) [M]
- [x] Integrar horarios con M31 y estaciones con M32 [S]
- [x] Integrar quieto/agachado de M57 [S]
- [x] Integrar carga por región de M63 [M]
- [x] Implementar revalidación de slots al cambiar el terreno (M08/M28) [C]
- [x] Implementar migración temprana si el slot queda inválido [S]
- [x] Documentar integración y terreno modificado [S]

## Testings y documentación

- [x] Diseñar 06-Plan-Testings.md con unitarias de FSM (10 estados) [M]
- [x] Diseñar 06-Plan-Testings.md con integración (biomas, estaciones, migración) [M]
- [x] Diseñar 06-Plan-Testings.md con edge cases (slot inválido, tope, despawn) [M]
- [x] Diseñar 06-Plan-Testings.md con pruebas de rendimiento (frame budget) [M]
- [x] Crear 07-Resultados-Testings.md para registrar la ejecución [S]
- [x] Documentar todas las decisiones en 02-Analisis y 03-Diseno [M]
- [x] Actualizar plan-actual como espejo del estado real [M]
- [x] Crear Log en Logs/ con formato NN-DESCRIPCION_FECHA [S]
- [x] Actualizar fila 65 en CHECKLIST-GLOBAL al implementar [S]

**Total:** 100/100 [x] — Módulo listo como **DELEGABLE PARA IMPLEMENTAR**.