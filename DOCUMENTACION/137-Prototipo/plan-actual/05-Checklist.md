**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 137: Prototipo (130 ítems)

**Estado:** 130/130 completados. [S]=Simple [M]=Medio [C]=Complejo. Fuentes: plan maestro sección 136 (19 ítems) + Plan-de-produccion.md sección 1 + M152/M153/M114/M61.

## A. Setup del Proyecto

- [ ] Definir escena `prototipo_isla.tscn` como escena principal [M]
- [ ] Definir carpeta `scenes/prototipo/` para todos los scripts del hito [S]
- [ ] Definir autoload `game_state_proto.gd` (M59) [M]
- [ ] Definir autoload `world_seed.gd` con seed fija 20260819 [S]
- [ ] Definir carpeta `docs/prototipo/` para los reportes del hito [S]

## B. Movimiento del Jugador (M11, RF1)

- [ ] Definir `player_proto.gd` (CharacterBody3D) [M]
- [ ] Definir movimiento 8 direcciones con velocidad 5.0 [S]
- [ ] Definir salto con `JUMP_VELOCITY = 4.5` [S]
- [ ] Definir `move_and_slide()` con colisiones voxel [M]
- [ ] Definir que el jugador camine sobre escaleras de 1 bloque [M]

## C. Cámara (M12, RF2)

- [ ] Definir SpringArm3D en tercera persona [M]
- [ ] Definir distancia cámara 2-8 m (sin clip) [M]
- [ ] Definir control mouse orbit [M]
- [ ] Definir test: cámara no atraviesa terreno en 10 posiciones [M]
- [ ] Definir test: sin nausea (encuesta playtest) [M]

## D. Voxel Básico (M08, RF3/RF4)

- [ ] Definir VoxelTerrain isla 64³-96³ [C]
- [ ] Definir generador de isla: elevación + playa + agua circundante [C]
- [ ] Definir extracción por raycast con radio máx 3 [M]
- [ ] Definir colocación de bloques en cara apuntada [M]
- [ ] Definir test de bordes de chunk sin crash [C]

## E. Recurso y Herramienta (M15/M13, RF6)

- [ ] Definir árbol de madera (bloques referenciados) [M]
- [ ] Definir obtención de madera al extraer árbol [M]
- [ ] Definir crafting esbozo: 2 maderas → herramienta (M16) [M]
- [ ] Definir herramienta con durabilidad infinita en prototipo [S]
- [ ] Definir que la herramienta abra el puzzle (flujo M24) [M]

## F. Inventario Mínimo (M14, RF5)

- [ ] Definir `inventario_proto.gd` con slot único [S]
- [ ] Definir contador de madera [S]
- [ ] Definir bool de herramienta [S]
- [ ] Definir UI placeholder de contador (M53 esbozo) [S]
- [ ] Definir test de inventario tras guardar/cargar [M]

## G. NPC y Diálogo (M19/M21, RF7)

- [ ] Definir NPC "Guía" con StaticBody simple [M]
- [ ] Definir interacción con tecla E [M]
- [ ] Definir 3 frases: bienvenida, pista del puzzle, agradecimiento [M]
- [ ] Definir caja de diálogo flotante placeholder [S]
- [ ] Definir test: diálogo no re-abre si ya se completó la misión [M]

## H. Puzzle Simple (M24/M25, RF8)

- [ ] Definir puerta de ruina bloqueada [M]
- [ ] Definir apertura con herramienta [M]
- [ ] Definir recompensa: mensaje + reliquia decorativa [S]
- [ ] Definir bypass posible (registrar en reporte) [S]
- [ ] Definir test: puzzle resoluble en < 3 min [M]

## I. Guardado Básico (M59/M60, RF9)

- [ ] Definir save v1 con version, seed, player, inventory, chunks, flags [M]
- [ ] Definir guardado delta solo de chunks modificados [C]
- [ ] Definir carga con seed mismatch → aviso (no crash) [M]
- [ ] Definir test guardar→salir→cargar con 0 pérdidas [C]
- [ ] Definir corrupción de JSON → estado seguro (sin pérdida total) [M]

## J. Mapa Pequeño (M10, RF10)

- [ ] Definir isla única alcanzable en < 2 min caminando [M]
- [ ] Definir spawn en la playa [S]
- [ ] Definir vegetación mínima (árboles, pasto bloque) [S]
- [ ] Definir que el mundo se regenere idéntico con la seed [M]
- [ ] Definir test: seed distinta → save inválido avisado [M]

## K. Ciclo Día/Noche (M31, RF11)

- [ ] Definir sky procedural simple [M]
- [ ] Definir duración de ronda: 6 min reales [S]
- [ ] Definir que "dormir" en la casa adelante el día [M]
- [ ] Definir luz direccional que sigue el ciclo [M]
- [ ] Definir sin impacto en gameplay (solo visual) [S]

## L. Clima (M32, RF11)

- [ ] Definir lluvia con particle system simple [M]
- [ ] Definir toggles de clima en debug (F1/F2) [S]
- [ ] Definir que la lluvia no afecte rendimiento (M61) [M]
- [ ] Definir sonido de lluvia placeholder (M42 esbozo) [S]
- [ ] Definir test de lluvia en zona densa (FPS estable) [M]

## M. Casa (M18, RF12)

- [ ] Definir casa con puerta interactuable [M]
- [ ] Definir cama que permite "pasar el día" [M]
- [ ] Definir interior mínimo (suelo + paredes) [S]
- [ ] Definir que la casa sea accesible sin herramientas [S]
- [ ] Definir test: dormir → amanecer sin bugs [M]

## N. Ruina (M25, RF12)

- [ ] Definir ruina de 5-8 bloques decorativos [S]
- [ ] Definir reliquia decorativa placeholder [S]
- [ ] Definir pista de puzzle en la ruina (mensaje en muro) [M]
- [ ] Definir que la ruina no tenga combate (cozy M152) [S]
- [ ] Definir test: recorrer ruina sin colisiones rotas [M]

## O. Playtest (M114, RF13)

- [ ] Definir `playtest_runner.gd` que loguea eventos y FPS [C]
- [ ] Definir sesión de 15 min por tester [S]
- [ ] Definir mínimo 3 testers [S]
- [ ] Definir encuesta de 5 preguntas (RF14) [S]
- [ ] Definir plantilla `PLAYTEST.md` con resultados [M]

## P. Medición de Diversión (RF14)

- [ ] Definir pregunta: diversión 1-10 [S]
- [ ] Definir pregunta: intención de volver a jugar (sí/no) [S]
- [ ] Definir pregunta: momento más aburrido [S]
- [ ] Definir pregunta: momento más divertido [S]
- [ ] Definir observación: acciones repetidas espontáneamente [M]

## Q. Checks de Filosofía (M152/M153, RF15)

- [ ] Definir checklist M152: sin grind, sin ansiedad, sin castigo [M]
- [ ] Definir checklist M152: combate ausente/opcional [M]
- [ ] Definir checklist M153: la sesión se siente dentro de la visión [M]
- [ ] Definir checklist M153: ritmo accesible sin metagaming forzado [M]
- [ ] Definir plantilla `FILOSOFIA-CHECK.md` firmada por tester/equipo [M]

## R. Rendimiento (M61, RF16)

- [ ] Definir medición FPS cada 5 s durante sesión [S]
- [ ] Definir criterio ≥ 60 FPS en config media [M]
- [ ] Definir escena densa de prueba (zona de 64³ llena) [M]
- [ ] Definir profiling con CPU/GPU (M61) si FPS < 60 [M]
- [ ] Definir reporte de rendimiento en `PLAYTEST.md` [M]

## S. Input (M57 esbozo)

- [ ] Definir input provisional teclado/mouse [S]
- [ ] Definir acciones: izq, der, adel, atras, saltar, usar [S]
- [ ] Definir que no haya conflicto con debug (F1/F2) [S]
- [ ] Definir test: input funciona sin foco de ventana perdida [S]
- [ ] Definir nota: input real se diseña en M57 [S]

## T. Decisión GO/NO-GO (RF17)

- [ ] Definir criterio 1: diversión ≥ 7/10 [S]
- [ ] Definir criterio 2: intención de seguir ≥ 80% [S]
- [ ] Definir criterio 3: FPS ≥ 60 [S]
- [ ] Definir criterio 4: filosofía sin fallos críticos [S]
- [ ] Definir criterio 5: bucle completo ≥ 90% de testers [M]

## U. Cierre y Versionado (RF18)

- [ ] Definir consecuencias de GO: pasar a M138 (Vertical Slice) [S]
- [ ] Definir consecuencias de NO-GO: ajuste 7 días o replanificar [M]
- [ ] Definir tag git `prototipo-v1` en el commit de cierre [S]
- [ ] Definir `GONOGO.md` firmado con fecha [S]
- [ ] Definir push del estado del prototipo al cierre [S]

## V. Retrospectiva (lecciones → M138)

- [ ] Definir sesión de retrospectiva post-hito [M]
- [ ] Definir doc `RETROSPECTIVA.md` con lecciones técnicas [M]
- [ ] Definir doc con lecciones de diseño (qué gustó/oró) [M]
- [ ] Definir lista de deudas técnicas diferidas a M138 [M]
- [ ] Definir checklist de entrada a M138 con estos hallazgos [M]

## W. Edge Cases (tests del prototipo)

- [ ] Definir test de caminar por bordes de precipicio [M]
- [ ] Definir test de extraer bloque bajo los pies (no caer en void) [M]
- [ ] Definir test de diálogo interrumpido (guardar durante diálogo) [M]
- [ ] Definir test de dormir con lluvia activa [S]
- [ ] Definir test de sesión con save repetido 10 veces [M]

## X. Arquitectura del Prototipo

- [ ] Definir separación escena/sistemas (modularidad, M07) [M]
- [ ] Definir autoloads como singletons claros [M]
- [ ] Definir que ningún script de UI contenga lógica de gameplay (M07) [M]
- [ ] Definir nombres de archivos consistentes (`*_proto.gd`) [S]
- [ ] Definir que el código del prototipo se pueda descartar sin afectar M138 [M]

## Y. Calidad de Código (M111)

- [ ] Definir que los scripts pasen el análisis estático (M111) [M]
- [ ] Definir `const` para números mágicos (SPEED, RADIOS) [S]
- [ ] Definir `@export` para valores tunables [S]
- [ ] Definir comentarios XML de clase en cada script [S]
- [ ] Definir registro de deuda técnica del prototipo (M111) [S]

## Z. Documentación y Cierre

- [ ] Definir que `docs/prototipo/` se actualice hasta el GONOGO [M]
- [ ] Definir actualización de `CHECKLIST-GLOBAL.md` al cerrar el hito [S]
- [ ] Definir log en `Logs/` del cierre del hito [S]
- [ ] Definir que la fila 137 quede 🟢 DELEGABLE al cerrar [S]
- [ ] Definir comunicar al usuario la decisión GO/NO-GO y próximos pasos [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
