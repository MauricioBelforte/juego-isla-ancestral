# 05 — Checklist — M65: Animales IA (100/100)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Implementación

- [ ] Definir la arquitectura del sistema de fauna (orquestador bajo NPCManager) [M]
- [ ] Crear FaunaProfile como ScriptableObject con datos por especie [M]
- [ ] Definir los 10 estados de la FSM de fauna [M]
- [ ] Implementar el estado Dormir con mínimo 30 s reales [M]
- [ ] Implementar el estado Pastorear con FOV interior de 120° [M]
- [ ] Implementar el estado Hidratarse en lagos y ríos navegables [M]
- [ ] Implementar el estado Comer con fuentes comestibles por especie [M]
- [ ] Implementar el estado Explorar con wander de bajo costo [M]
- [ ] Implementar el estado Curiosear (jugador quieto o agachado) [M]
- [ ] Implementar el estado Huir con huida radial no violenta [M]
- [ ] Implementar el estado Migrar por rutas de etapas [M]
- [ ] Implementar el estado Reproducir con nido y cría [C]
- [ ] Implementar el estado Anclado para despawn y rehidratación [M]
- [ ] Implementar PackLogic para manadas con líder rotativo [M]
- [ ] Implementar SchoolLogic para bancos con delta ≤ 1.2 m [M]
- [ ] Definir 6 especies de bosque (ciervo, cabra, jabalí, zorro, liebre, aves) [S]
- [ ] Definir 4 especies acuáticas (peces, cangrejos, nutrias, patos) [S]
- [ ] Definir 3 especies aéreas (gaviota, búho, murciélago) [S]
- [ ] Definir 2 especies de montaña (cabra salvaje, águila) [S]
- [ ] Definir 2 especies de pradera (oveja, grulla) [S]
- [ ] Definir 1 especie nocturna de refugio (lechuza) [S]
- [ ] Definir 1 especie rara/ancestral (búho gema, aparecer en eventos) [C]
- [ ] Diseñar el perfil estacional de cada especie (M32) [M]
- [ ] Diseñar variantes de color por bioma sin costo extra [S]
- [ ] Diseñar crías con 3 etapas de crecimiento [M]

## Comportamiento herbívoro

- [ ] Definir zonas de vegetación como fuentes de pastoreo [M]
- [ ] Implementar reposición de alimento en la zona tras consumo [M]
- [ ] Implementar fuga del pastor al detectar al jugador a 12 m [S]
- [ ] Implementar retorno a manada tras la fuga [S]
- [ ] Implementar liderazgo y reposición de líder en la manada [S]
- [ ] Implementar descanso de manada en sombra/refugio [S]
- [ ] Implementar alimentación con prioridad sobre explorar [M]
- [ ] Implementar hambre lenta de 10 min reales sin comer [M]
- [ ] Implementar emigración suave al agotar la hambre [M]
- [ ] Documentar el comportamiento de la manada en el plan-actual [S]

## Comportamiento acuático

- [ ] Implementar nado 3D con buceo [C]
- [ ] Implementar banco con unidad de flujo y dispersión [M]
- [ ] Implementar salto de peces en superficie con evento visual [S]
- [ ] Implementar cangrejos costeros 2D con marea baja [M]
- [ ] Implementar patos con zonas de flotación en lagos [S]
- [ ] Implementar salida del agua por rampa navegable [M]
- [ ] Implementar reacción a perturbación del agua (canguraje) [S]
- [ ] Implementar despawn marino por lejanía con anclado [S]
- [ ] Documentar el comportamiento acuático en el plan-actual [S]

## Comportamiento aéreo

- [ ] Implementar vuelo con waypoints circulares [M]
- [ ] Implementar perchas en árboles y rocas [S]
- [ ] Implementar térmicas de ascenso [S]
- [ ] Implementar separación vertical para no rozar la isla [M]
- [ ] Implementar alarmas de aves al sentirse observadas [S]
- [ ] Implementar vuelo nocturno del búho y murciélago [S]
- [ ] Implementar migración columnata de aves (M36 visual) [M]
- [ ] Implementar anclado aéreo fuera de burbuja [S]
- [ ] Documentar el comportamiento aéreo en el plan-actual [S]

## Comportamiento nocturno

- [ ] Implementar actividad nocturna según luminosidad de M31 [M]
- [ ] Implementar día de reposo para nocturnos en refugio [S]
- [ ] Implementar despertar por ruido o agua cercana [S]
- [ ] Implementar luciérnagas decorativas en la noche [S]
- [ ] Implementar ramo de búhos al anochecer (evento M42) [S]
- [ ] Documentar el comportamiento nocturno en el plan-actual [S]

## Comportamiento migratorio y estacional

- [ ] Implementar migración en ventana estacional (M32) [M]
- [ ] Implementar migración en el horario temprano de la mañana [S]
- [ ] Implementar rutas por etapas entre biomas [M]
- [ ] Implementar marcadores de etapa con validación navegable [M]
- [ ] Implementar regreso al bioma de origen en estación seca [M]
- [ ] Implementar agrupación mayor en invierno (M31 temperatura) [S]
- [ ] Implementar cambio de fuente de alimento según estación [M]
- [ ] Implementar perfil estacional del pelaje (shader param) [S]
- [ ] Documentar el comportamiento migratorio y estacional [S]

## Reproducción, descanso y alimentación

- [ ] Implementar ciclo de reproducción por especie [C]
- [ ] Implementar nido oculto con protección de observación [M]
- [ ] Implementar cría con 3 etapas y crecimiento por días de juego (M29) [M]
- [ ] Implementar sin loot de crías ni explotación [S]
- [ ] Implementar madriguera para descanso nocturno de diurnos [M]
- [ ] Implementar fuente de agua para cada especie acuática/terrestre [M]
- [ ] Implementar hambre lenta y emigración sin muerte visible [M]
- [ ] Implementar cooldown de sonido de alimentación [S]
- [ ] Documentar reproducción, descanso y alimentación [S]

## Huida, curiosidad e interacción con entorno

- [ ] Implementar huida radial con radio por especie [M]
- [ ] Implementar retorno a explorar tras la huida [S]
- [ ] Implementar curiosidad si el jugador está quieto/agachado (M57) [M]
- [ ] Implementar umbral tímido de distancia por especie [S]
- [ ] Implementar observación de 5 s y retirada [S]
- [ ] Implementar reacción a agua perturbada y zonas alteradas [M]
- [ ] Implementar rehidratación en lagos/ríos con animación [S]
- [ ] Implementar sonido de curiosidad con cooldown (M43) [S]
- [ ] Documentar huida, curiosidad e interacción [S]

## Sonidos contextuales

- [ ] Definir tabla de timestamps de fauna (M42/M43) [S]
- [ ] Implementar alarma de manada al huir (radio 40 m) [S]
- [ ] Implementar canto de aves al amanecer/atardecer (M31) [S]
- [ ] Implementar salpicadura de buceo (radio 20 m) [S]
- [ ] Implementar roce en pastos al pastorear (radio 10 m) [S]
- [ ] Implementar respeto de BusPriority y cooldowns [M]
- [ ] Implementar evento de búho al anochecer [S]
- [ ] Documentar sonidos contextuales en el plan-actual [S]

## Spawns y despawns

- [ ] Implementar spawn por pesos de bioma con sorteo local [M]
- [ ] Implementar densidad máxima por bioma [M]
- [ ] Implementar validación de navegación del slot [M]
- [ ] Implementar spawn con semilla determinística [M]
- [ ] Implementar despawn fuera de burbuja con anclado [M]
- [ ] Implementar rehidratación de estado completo al volver [M]
- [ ] Implementar despawn de emigración sin residuos [M]
- [ ] Implementar sin destrucción a mitad de cuadro [S]
- [ ] Documentar spawns y despawns en el plan-actual [S]

## Optimización y población

- [ ] Implementar presupuesto total de fauna (M61) [M]
- [ ] Implementar instancing animado para grupos ≥ 8 [C]
- [ ] Implementar pooling de FaunaBody sin allocations en Update [M]
- [ ] Implementar tick 1 s para lejanos [M]
- [ ] Implementar tope por manada y tope por bioma [S]
- [ ] Implementar reintegro probabilístico si se supera el tope [S]
- [ ] Implementar reducción de burbuja fauna antes que NPC [M]
- [ ] Implementar watchdog anti-atasco 2 s/6 s [M]
- [ ] Implementar teleport discreto en revalidación de chunk [M]
- [ ] Documentar optimización y población en plan-actual [S]

## Integración y terreno modificado

- [ ] Integrar registro de fauna con M36 (avistamiento, no caza) [M]
- [ ] Integrar horarios con M31 y estaciones con M32 [S]
- [ ] Integrar quieto/agachado de M57 [S]
- [ ] Integrar carga por región de M63 [M]
- [ ] Implementar revalidación de slots al cambiar el terreno (M08/M28) [C]
- [ ] Implementar migración temprana si el slot queda inválido [S]
- [ ] Documentar integración y terreno modificado [S]

## Testings y documentación

- [ ] Diseñar 06-Plan-Testings.md con unitarias de FSM (10 estados) [M]
- [ ] Diseñar 06-Plan-Testings.md con integración (biomas, estaciones, migración) [M]
- [ ] Diseñar 06-Plan-Testings.md con edge cases (slot inválido, tope, despawn) [M]
- [ ] Diseñar 06-Plan-Testings.md con pruebas de rendimiento (frame budget) [M]
- [ ] Crear 07-Resultados-Testings.md para registrar la ejecución [S]
- [ ] Documentar todas las decisiones en 02-Analisis y 03-Diseno [M]
- [ ] Actualizar plan-actual como espejo del estado real [M]
- [ ] Crear Log en Logs/ con formato NN-DESCRIPCION_FECHA [S]
- [ ] Actualizar fila 65 en CHECKLIST-GLOBAL al implementar [S]

**Total:** 100/100 [ ] — Módulo listo como **DELEGABLE PARA IMPLEMENTAR**.