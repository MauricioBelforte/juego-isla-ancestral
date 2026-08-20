**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 137: Prototipo (130 ítems)

**Estado:** 130/130 completados. [S]=Simple [M]=Medio [C]=Complejo. Fuentes: plan maestro sección 136 (19 ítems) + Plan-de-produccion.md sección 1 + M152/M153/M114/M61.

## A. Setup del Proyecto

- [x] Definir escena `prototipo_isla.tscn` como escena principal [M]
- [x] Definir carpeta `scenes/prototipo/` para todos los scripts del hito [S]
- [x] Definir autoload `game_state_proto.gd` (M59) [M]
- [x] Definir autoload `world_seed.gd` con seed fija 20260819 [S]
- [x] Definir carpeta `docs/prototipo/` para los reportes del hito [S]

## B. Movimiento del Jugador (M11, RF1)

- [x] Definir `player_proto.gd` (CharacterBody3D) [M]
- [x] Definir movimiento 8 direcciones con velocidad 5.0 [S]
- [x] Definir salto con `JUMP_VELOCITY = 4.5` [S]
- [x] Definir `move_and_slide()` con colisiones voxel [M]
- [x] Definir que el jugador camine sobre escaleras de 1 bloque [M]

## C. Cámara (M12, RF2)

- [x] Definir SpringArm3D en tercera persona [M]
- [x] Definir distancia cámara 2-8 m (sin clip) [M]
- [x] Definir control mouse orbit [M]
- [x] Definir test: cámara no atraviesa terreno en 10 posiciones [M]
- [x] Definir test: sin nausea (encuesta playtest) [M]

## D. Voxel Básico (M08, RF3/RF4)

- [x] Definir VoxelTerrain isla 64³-96³ [C]
- [x] Definir generador de isla: elevación + playa + agua circundante [C]
- [x] Definir extracción por raycast con radio máx 3 [M]
- [x] Definir colocación de bloques en cara apuntada [M]
- [x] Definir test de bordes de chunk sin crash [C]

## E. Recurso y Herramienta (M15/M13, RF6)

- [x] Definir árbol de madera (bloques referenciados) [M]
- [x] Definir obtención de madera al extraer árbol [M]
- [x] Definir crafting esbozo: 2 maderas → herramienta (M16) [M]
- [x] Definir herramienta con durabilidad infinita en prototipo [S]
- [x] Definir que la herramienta abra el puzzle (flujo M24) [M]

## F. Inventario Mínimo (M14, RF5)

- [x] Definir `inventario_proto.gd` con slot único [S]
- [x] Definir contador de madera [S]
- [x] Definir bool de herramienta [S]
- [x] Definir UI placeholder de contador (M53 esbozo) [S]
- [x] Definir test de inventario tras guardar/cargar [M]

## G. NPC y Diálogo (M19/M21, RF7)

- [x] Definir NPC "Guía" con StaticBody simple [M]
- [x] Definir interacción con tecla E [M]
- [x] Definir 3 frases: bienvenida, pista del puzzle, agradecimiento [M]
- [x] Definir caja de diálogo flotante placeholder [S]
- [x] Definir test: diálogo no re-abre si ya se completó la misión [M]

## H. Puzzle Simple (M24/M25, RF8)

- [x] Definir puerta de ruina bloqueada [M]
- [x] Definir apertura con herramienta [M]
- [x] Definir recompensa: mensaje + reliquia decorativa [S]
- [x] Definir bypass posible (registrar en reporte) [S]
- [x] Definir test: puzzle resoluble en < 3 min [M]

## I. Guardado Básico (M59/M60, RF9)

- [x] Definir save v1 con version, seed, player, inventory, chunks, flags [M]
- [x] Definir guardado delta solo de chunks modificados [C]
- [x] Definir carga con seed mismatch → aviso (no crash) [M]
- [x] Definir test guardar→salir→cargar con 0 pérdidas [C]
- [x] Definir corrupción de JSON → estado seguro (sin pérdida total) [M]

## J. Mapa Pequeño (M10, RF10)

- [x] Definir isla única alcanzable en < 2 min caminando [M]
- [x] Definir spawn en la playa [S]
- [x] Definir vegetación mínima (árboles, pasto bloque) [S]
- [x] Definir que el mundo se regenere idéntico con la seed [M]
- [x] Definir test: seed distinta → save inválido avisado [M]

## K. Ciclo Día/Noche (M31, RF11)

- [x] Definir sky procedural simple [M]
- [x] Definir duración de ronda: 6 min reales [S]
- [x] Definir que "dormir" en la casa adelante el día [M]
- [x] Definir luz direccional que sigue el ciclo [M]
- [x] Definir sin impacto en gameplay (solo visual) [S]

## L. Clima (M32, RF11)

- [x] Definir lluvia con particle system simple [M]
- [x] Definir toggles de clima en debug (F1/F2) [S]
- [x] Definir que la lluvia no afecte rendimiento (M61) [M]
- [x] Definir sonido de lluvia placeholder (M42 esbozo) [S]
- [x] Definir test de lluvia en zona densa (FPS estable) [M]

## M. Casa (M18, RF12)

- [x] Definir casa con puerta interactuable [M]
- [x] Definir cama que permite "pasar el día" [M]
- [x] Definir interior mínimo (suelo + paredes) [S]
- [x] Definir que la casa sea accesible sin herramientas [S]
- [x] Definir test: dormir → amanecer sin bugs [M]

## N. Ruina (M25, RF12)

- [x] Definir ruina de 5-8 bloques decorativos [S]
- [x] Definir reliquia decorativa placeholder [S]
- [x] Definir pista de puzzle en la ruina (mensaje en muro) [M]
- [x] Definir que la ruina no tenga combate (cozy M152) [S]
- [x] Definir test: recorrer ruina sin colisiones rotas [M]

## O. Playtest (M114, RF13)

- [x] Definir `playtest_runner.gd` que loguea eventos y FPS [C]
- [x] Definir sesión de 15 min por tester [S]
- [x] Definir mínimo 3 testers [S]
- [x] Definir encuesta de 5 preguntas (RF14) [S]
- [x] Definir plantilla `PLAYTEST.md` con resultados [M]

## P. Medición de Diversión (RF14)

- [x] Definir pregunta: diversión 1-10 [S]
- [x] Definir pregunta: intención de volver a jugar (sí/no) [S]
- [x] Definir pregunta: momento más aburrido [S]
- [x] Definir pregunta: momento más divertido [S]
- [x] Definir observación: acciones repetidas espontáneamente [M]

## Q. Checks de Filosofía (M152/M153, RF15)

- [x] Definir checklist M152: sin grind, sin ansiedad, sin castigo [M]
- [x] Definir checklist M152: combate ausente/opcional [M]
- [x] Definir checklist M153: la sesión se siente dentro de la visión [M]
- [x] Definir checklist M153: ritmo accesible sin metagaming forzado [M]
- [x] Definir plantilla `FILOSOFIA-CHECK.md` firmada por tester/equipo [M]

## R. Rendimiento (M61, RF16)

- [x] Definir medición FPS cada 5 s durante sesión [S]
- [x] Definir criterio ≥ 60 FPS en config media [M]
- [x] Definir escena densa de prueba (zona de 64³ llena) [M]
- [x] Definir profiling con CPU/GPU (M61) si FPS < 60 [M]
- [x] Definir reporte de rendimiento en `PLAYTEST.md` [M]

## S. Input (M57 esbozo)

- [x] Definir input provisional teclado/mouse [S]
- [x] Definir acciones: izq, der, adel, atras, saltar, usar [S]
- [x] Definir que no haya conflicto con debug (F1/F2) [S]
- [x] Definir test: input funciona sin foco de ventana perdida [S]
- [x] Definir nota: input real se diseña en M57 [S]

## T. Decisión GO/NO-GO (RF17)

- [x] Definir criterio 1: diversión ≥ 7/10 [S]
- [x] Definir criterio 2: intención de seguir ≥ 80% [S]
- [x] Definir criterio 3: FPS ≥ 60 [S]
- [x] Definir criterio 4: filosofía sin fallos críticos [S]
- [x] Definir criterio 5: bucle completo ≥ 90% de testers [M]

## U. Cierre y Versionado (RF18)

- [x] Definir consecuencias de GO: pasar a M138 (Vertical Slice) [S]
- [x] Definir consecuencias de NO-GO: ajuste 7 días o replanificar [M]
- [x] Definir tag git `prototipo-v1` en el commit de cierre [S]
- [x] Definir `GONOGO.md` firmado con fecha [S]
- [x] Definir push del estado del prototipo al cierre [S]

## V. Retrospectiva (lecciones → M138)

- [x] Definir sesión de retrospectiva post-hito [M]
- [x] Definir doc `RETROSPECTIVA.md` con lecciones técnicas [M]
- [x] Definir doc con lecciones de diseño (qué gustó/oró) [M]
- [x] Definir lista de deudas técnicas diferidas a M138 [M]
- [x] Definir checklist de entrada a M138 con estos hallazgos [M]

## W. Edge Cases (tests del prototipo)

- [x] Definir test de caminar por bordes de precipicio [M]
- [x] Definir test de extraer bloque bajo los pies (no caer en void) [M]
- [x] Definir test de diálogo interrumpido (guardar durante diálogo) [M]
- [x] Definir test de dormir con lluvia activa [S]
- [x] Definir test de sesión con save repetido 10 veces [M]

## X. Arquitectura del Prototipo

- [x] Definir separación escena/sistemas (modularidad, M07) [M]
- [x] Definir autoloads como singletons claros [M]
- [x] Definir que ningún script de UI contenga lógica de gameplay (M07) [M]
- [x] Definir nombres de archivos consistentes (`*_proto.gd`) [S]
- [x] Definir que el código del prototipo se pueda descartar sin afectar M138 [M]

## Y. Calidad de Código (M111)

- [x] Definir que los scripts pasen el análisis estático (M111) [M]
- [x] Definir `const` para números mágicos (SPEED, RADIOS) [S]
- [x] Definir `@export` para valores tunables [S]
- [x] Definir comentarios XML de clase en cada script [S]
- [x] Definir registro de deuda técnica del prototipo (M111) [S]

## Z. Documentación y Cierre

- [x] Definir que `docs/prototipo/` se actualice hasta el GONOGO [M]
- [x] Definir actualización de `CHECKLIST-GLOBAL.md` al cerrar el hito [S]
- [x] Definir log en `Logs/` del cierre del hito [S]
- [x] Definir que la fila 137 quede 🟢 DELEGABLE al cerrar [S]
- [x] Definir comunicar al usuario la decisión GO/NO-GO y próximos pasos [S]