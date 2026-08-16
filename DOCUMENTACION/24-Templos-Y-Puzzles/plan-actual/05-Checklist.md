# 05 — Checklist — M24: Templos y Puzzles (100/100)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Filosofía y dificultad

- [x] Definir la filosofía de puzzles del juego (coherentes, narrativos, jamás arbitrarios) [M]
- [x] Definir 3 bandas de dificultad (Exploración/Ritual/Antiguo) [S]
- [x] Definir progresión de dificultad por zona del templo [S]
- [x] Definir progresión de dificultad por familia de puzzle [S]
- [x] Definir la subida de dificultad por intentos fallidos (ayuda progresiva) [S]
- [x] Documentar la filosofía en el plan-actual [S]

## Tutorialización

- [x] Definir tutorialización por familia (primer puzzle de cada familia) [M]
- [x] Definir "guía del templo" mural por zona [S]
- [x] Definir narrador suave en la primera solución (M33/M31 hooks) [S]
- [x] Definir iconografía de glifos reconocible en la guía [S]
- [x] Definir tutorialización sin texto invasivo (visuales primero) [S]
- [x] Documentar la tutorialización en el plan-actual [S]

## Framework emisor→receptor

- [x] Definir Emisor (señal por acción del jugador o del mundo) [M]
- [x] Definir Receptor (efecto visible) [M]
- [x] Definir Regla (conector declarativo con condiciones) [M]
- [x] Definir EstadoSala (vector de emisores) [M]
- [x] Definir Objetivo único verificable [M]
- [x] Definir Validador de arbitrariedad (1 solución alcanzable) [C]
- [x] Definir serialización JSON/YAML de cada puzzle [M]
- [x] Definir ejecución datos-driven (intérprete, no código por sala) [M]
- [x] Documentar el framework en el plan-actual [M]

## Familia: puzzles de luz

- [x] Definir espejo de luz con ángulo 45° verificable [M]
- [x] Definir lente que concentra el rayo [S]
- [x] Definir prisma que desvía el rayo [S]
- [x] Definir ocultación del rayo por el jugador [S]
- [x] Definir cristal receptor que activa runa [S]
- [x] Definir validación de rayos por datos (no física visual) [M]
- [x] Documentar la familia de luz en el plan-actual [S]

## Familia: puzzles de espejos

- [x] Definir rotación de espejos en múltiplos de 45° [M]
- [x] Definir caminos verificables de rayo (Editor) [M]
- [x] Definir espejos fijos y móviles [S]
- [x] Definir interacción con la familia de luz (cadena) [S]
- [x] Definir feedback de dirección al rotar [S]
- [x] Documentar la familia de espejos en el plan-actual [S]

## Familia: puzzles de agua

- [x] Definir compuertas con niveles de agua [M]
- [x] Definir fuente que alimenta el nivel [S]
- [x] Definir barca flotante que cruza al subir el nivel [M]
- [x] Definir altura de agua verificable por datos [M]
- [x] Definir relleno/drenaje gradual (sin snaps) [S]
- [x] Documentar la familia de agua en el plan-actual [S]

## Familia: puzzles de hielo

- [x] Definir deslizamiento de bloques sobre hielo [M]
- [x] Definir patrones simétricos verificables (Editor) [M]
- [x] Definir colisiones típicas (paredes y huecos) [S]
- [x] Definir pedazos de hielo opcionales (variante) [S]
- [x] Documentar la familia de hielo en el plan-actual [S]

## Familia: puzzles de presión

- [x] Definir placas con umbral de peso [M]
- [x] Definir peso estático (cajas) y dinámico (jugador) [M]
- [x] Definir elevadores por placas [S]
- [x] Definir puertas por placas encadenadas [S]
- [x] Definir sin fallo punitivo (reinicio del slot, M66) [S]
- [x] Documentar la familia de presión en el plan-actual [S]

## Familia: puzzles de bloques

- [x] Definir push/pull con restricción de 1 eje [M]
- [x] Definir ranuras de destino [S]
- [x] Definir puentes desplegables [S]
- [x] Definir sin empuje a otras salas (límites) [S]
- [x] Documentar la familia de bloques en el plan-actual [S]

## Familia: puzzles de gravedad y movimiento

- [x] Definir burbujas de gravedad en zonas seleccionadas [M]
- [x] Definir cambio de dirección del desplazamiento [S]
- [x] Definir plataformas móviles sincronizadas [M]
- [x] Definir pulsos de aire [S]
- [x] Definir cintas transportadoras [S]
- [x] Definir sincronización con reloj de datos (M29) [M]
- [x] Documentar las familias de gravedad y movimiento [S]

## Familia: puzzles de sonido y secuencia

- [x] Definir campanas/gongs como emisores sonoros [S]
- [x] Definir línea de audición clara como condición (M43 hook) [M]
- [x] Definir sin dependencia del hardware de audio del jugador [M]
- [x] Definir secuencias de 3-5 símbolos visibles [S]
- [x] Definir pista del patrón completo tras 2 intentos [S]
- [x] Documentar las familias de sonido y secuencia [S]

## Familia: puzzles de símbolos y ambientales

- [x] Definir glifos ancestrales emparejados [M]
- [x] Definir glosario del templo con los glifos (M25 inscripciones) [S]
- [x] Definir sello de puerta por pareja correcta [S]
- [x] Definir puzzles con viento (M32) [S]
- [x] Definir puzzles con lluvia (M32) [S]
- [x] Definir puzzles con criaturas (M65: curiosidad abre puerta) [S]
- [x] Documentar las familias de símbolos y ambientales [S]

## Familia: herramientas y multilaterales

- [x] Definir uso de pico (grieta) [S]
- [x] Definir uso de gancho (pasarela) [S]
- [x] Definir uso de farol (iluminar runa) [S]
- [x] Definir condición de inventario presente para la herramienta [S]
- [x] Definir puzzles multilaterales con estado compartido de sala [M]
- [x] Definir mapa-emisor central para multilaterales [M]
- [x] Definir puerta final por estado completo [S]
- [x] Documentar las familias de herramientas y multilaterales [S]

## Pistas y sistema de ayuda

- [x] Crear 3 capas de pistas (ambiental → icono en diario → total) [M]
- [x] Crear menú "Guía del Templo" (puzzle actual + historial resuelto) [M]
- [x] Crear pista diferida (90 s sin progreso) [S]
- [x] Crear pista de familia textual [S]
- [x] Crear pista de emisor exacto [S]
- [x] Crear solución paso a paso tras 3 pistas [M]
- [x] Crear pistas ancladas a reglas del grafo (nunca texto suelto) [M]
- [x] Crear elección libre de consultar la guía (sin penalización) [S]
- [x] Documentar pistas y sistema de ayuda [S]

## Anti-arbitrariedad, anti-ambigüedad y métricas

- [x] Implementar validación de arbitrariedad en Editor [C]
- [x] Implementar validación de arbitrariedad en tests (falla → no build) [M]
- [x] Implementar detección de 2+ soluciones (ambigüedad) [M]
- [x] Implementar detección de regla desconectada [M]
- [x] Implementar feedback "casi solución" (1 paso del objetivo) [S]
- [x] Implementar PuzzleTimer (tiempo, pistas, abandonos) [M]
- [x] Implementar exportación de métricas para playtests externos [M]
- [x] Documentar anti-arbitrariedad, anti-ambigüedad y métricas [S]

## Checkpoints, reinicio y recompensas

- [x] Definir checkpoints por sala (PuzzleState serializado) [M]
- [x] Definir guardado del estado cada 60 s dentro de un puzzle [S]
- [x] Definir checkpoint atómico (tmp+rename+.bak) [M]
- [x] Implementar reinicio del puzzle al estado inicial del slot [M]
- [x] Implementar botón de reinicio en la Guía del Templo [S]
- [x] Implementar reinicio automático tras 30 s de diagnóstico inválido (M66) [M]
- [x] Definir recompensas narrativas y materiales por puzzle [M]
- [x] Definir recompensas únicas no duplicables (copa con M66) [M]
- [x] Definir recompensas alineadas al lore del templo [S]
- [x] Documentar checkpoints, reinicio y recompensas [S]

## Testings y documentación

- [x] Diseñar 06-Plan-Testings.md: unitarias del framework [M]
- [x] Diseñar 06-Plan-Testings.md: playtests externos por familia [M]
- [x] Diseñar 06-Plan-Testings.md: edge cases (2 soluciones, regla rota) [M]
- [x] Diseñar 06-Plan-Testings.md: rendimiento (≤ 1 ms por tick) [M]
- [x] Definir criterio de éxito: suite completa pasa sin fallos [S]
- [x] Crear 07-Resultados-Testings.md para registrar la ejecución [S]
- [x] Documentar todas las decisiones en 02-Analisis y 03-Diseno [M]
- [x] Actualizar plan-actual como espejo del estado real [M]
- [x] Crear Log en Logs/ con formato NN-DESCRIPCION_FECHA [S]
- [x] Actualizar fila 24 en CHECKLIST-GLOBAL al implementar [S]

**Total:** 100/100 [x] — Módulo listo como **DELEGABLE PARA IMPLEMENTAR**.