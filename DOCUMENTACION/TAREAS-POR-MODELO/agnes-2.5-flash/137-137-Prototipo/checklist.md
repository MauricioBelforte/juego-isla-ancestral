# Tareas módulo 137 137-Prototipo

**Estado:** ðŸŸ¢ Disponible

**Items pendientes:** 121

[ ] T-137-001: Definir escena `prototipo_isla.tscn` como escena principal
[ ] T-137-002: Definir autoload `game_state_proto.gd` (M59)
[ ] T-137-003: Definir autoload `world_seed.gd` con seed fija 20260819
[ ] T-137-004: Definir carpeta `docs/prototipo/` para los reportes del hito
[ ] T-137-005: Definir `player_proto.gd` (CharacterBody3D)
[ ] T-137-006: Definir movimiento 8 direcciones con velocidad 5.0
[ ] T-137-007: Definir salto con `JUMP_VELOCITY = 4.5`
[ ] T-137-008: Definir `move_and_slide()` con colisiones voxel
[ ] T-137-009: Definir que el jugador camine sobre escaleras de 1 bloque
[ ] T-137-010: Definir SpringArm3D en tercera persona
[ ] T-137-011: Definir distancia cámara 2-8 m (sin clip)
[ ] T-137-012: Definir control mouse orbit
[ ] T-137-013: Definir test: cámara no atraviesa terreno en 10 posiciones
[ ] T-137-014: Definir test: sin nausea (encuesta playtest)
[ ] T-137-015: Definir VoxelTerrain isla 64³-96³
[ ] T-137-016: Definir generador de isla: elevación + playa + agua circundante
[ ] T-137-017: Definir extracción por raycast con radio máx 3
[ ] T-137-018: Definir colocación de bloques en cara apuntada
[ ] T-137-019: Definir test de bordes de chunk sin crash
[ ] T-137-020: Definir árbol de madera (bloques referenciados)
[ ] T-137-021: Definir obtención de madera al extraer árbol
[ ] T-137-022: Definir crafting esbozo: 2 maderas → herramienta (M16)
[ ] T-137-023: Definir herramienta con durabilidad infinita en prototipo
[ ] T-137-024: Definir que la herramienta abra el puzzle (flujo M24)
[ ] T-137-025: Definir `inventario_proto.gd` con slot único
[ ] T-137-026: Definir contador de madera
[ ] T-137-027: Definir bool de herramienta
[ ] T-137-028: Definir UI placeholder de contador (M53 esbozo)
[ ] T-137-029: Definir test de inventario tras guardar/cargar
[ ] T-137-030: Definir NPC "Guía" con StaticBody simple
[ ] T-137-031: Definir interacción con tecla E
[ ] T-137-032: Definir 3 frases: bienvenida, pista del puzzle, agradecimiento
[ ] T-137-033: Definir caja de diálogo flotante placeholder
[ ] T-137-034: Definir test: diálogo no re-abre si ya se completó la misión
[ ] T-137-035: Definir puerta de ruina bloqueada
[ ] T-137-036: Definir apertura con herramienta
[ ] T-137-037: Definir recompensa: mensaje + reliquia decorativa
[ ] T-137-038: Definir bypass posible (registrar en reporte)
[ ] T-137-039: Definir test: puzzle resoluble en < 3 min
[ ] T-137-040: Definir save v1 con version, seed, player, inventory, chunks, flags
[ ] T-137-041: Definir guardado delta solo de chunks modificados
[ ] T-137-042: Definir carga con seed mismatch → aviso (no crash)
[ ] T-137-043: Definir test guardar→salir→cargar con 0 pérdidas
[ ] T-137-044: Definir isla única alcanzable en < 2 min caminando
[ ] T-137-045: Definir spawn en la playa
[ ] T-137-046: Definir vegetación mínima (árboles, pasto bloque)
[ ] T-137-047: Definir que el mundo se regenere idéntico con la seed
[ ] T-137-048: Definir test: seed distinta → save inválido avisado
[ ] T-137-049: Definir sky procedural simple
[ ] T-137-050: Definir duración de ronda: 6 min reales
[ ] T-137-051: Definir que "dormir" en la casa adelante el día
[ ] T-137-052: Definir luz direccional que sigue el ciclo
[ ] T-137-053: Definir sin impacto en gameplay (solo visual)
[ ] T-137-054: Definir lluvia con particle system simple
[ ] T-137-055: Definir toggles de clima en debug (F1/F2)
[ ] T-137-056: Definir que la lluvia no afecte rendimiento (M61)
[ ] T-137-057: Definir sonido de lluvia placeholder (M42 esbozo)
[ ] T-137-058: Definir test de lluvia en zona densa (FPS estable)
[ ] T-137-059: Definir casa con puerta interactuable
[ ] T-137-060: Definir cama que permite "pasar el día"
[ ] T-137-061: Definir interior mínimo (suelo + paredes)
[ ] T-137-062: Definir que la casa sea accesible sin herramientas
[ ] T-137-063: Definir test: dormir → amanecer sin bugs
[ ] T-137-064: Definir ruina de 5-8 bloques decorativos
[ ] T-137-065: Definir reliquia decorativa placeholder
[ ] T-137-066: Definir pista de puzzle en la ruina (mensaje en muro)
[ ] T-137-067: Definir que la ruina no tenga combate (cozy M152)
[ ] T-137-068: Definir test: recorrer ruina sin colisiones rotas
[ ] T-137-069: Definir sesión de 15 min por tester
[ ] T-137-070: Definir mínimo 3 testers
[ ] T-137-071: Definir encuesta de 5 preguntas (RF14)
[ ] T-137-072: Definir plantilla `PLAYTEST.md` con resultados
[ ] T-137-073: Definir pregunta: diversión 1-10
[ ] T-137-074: Definir pregunta: intención de volver a jugar (sí/no)
[ ] T-137-075: Definir pregunta: momento más aburrido
[ ] T-137-076: Definir pregunta: momento más divertido
[ ] T-137-077: Definir observación: acciones repetidas espontáneamente
[ ] T-137-078: Definir checklist M152: sin grind, sin ansiedad, sin castigo
[ ] T-137-079: Definir checklist M152: combate ausente/opcional
[ ] T-137-080: Definir checklist M153: la sesión se siente dentro de la visión
[ ] T-137-081: Definir checklist M153: ritmo accesible sin metagaming forzado
[ ] T-137-082: Definir plantilla `FILOSOFIA-CHECK.md` firmada por tester/equipo
[ ] T-137-083: Definir medición FPS cada 5 s durante sesión
[ ] T-137-084: Definir escena densa de prueba (zona de 64³ llena)
[ ] T-137-085: Definir profiling con CPU/GPU (M61) si FPS < 60
[ ] T-137-086: Definir reporte de rendimiento en `PLAYTEST.md`
[ ] T-137-087: Definir input provisional teclado/mouse
[ ] T-137-088: Definir acciones: izq, der, adel, atras, saltar, usar
[ ] T-137-089: Definir que no haya conflicto con debug (F1/F2)
[ ] T-137-090: Definir nota: input real se diseña en M57
[ ] T-137-091: Definir criterio 1: diversión ≥ 7/10
[ ] T-137-092: Definir criterio 2: intención de seguir ≥ 80%
[ ] T-137-093: Definir criterio 3: FPS ≥ 60
[ ] T-137-094: Definir criterio 4: filosofía sin fallos críticos
[ ] T-137-095: Definir criterio 5: bucle completo ≥ 90% de testers
[ ] T-137-096: Definir consecuencias de GO: pasar a M138 (Vertical Slice)
[ ] T-137-097: Definir consecuencias de NO-GO: ajuste 7 días o replanificar
[ ] T-137-098: Definir tag git `prototipo-v1` en el commit de cierre
[ ] T-137-099: Definir `GONOGO.md` firmado con fecha
[ ] T-137-100: Definir push del estado del prototipo al cierre
[ ] T-137-101: Definir sesión de retrospectiva post-hito
[ ] T-137-102: Definir doc `RETROSPECTIVA.md` con lecciones técnicas
[ ] T-137-103: Definir doc con lecciones de diseño (qué gustó/oró)
[ ] T-137-104: Definir lista de deudas técnicas diferidas a M138
[ ] T-137-105: Definir checklist de entrada a M138 con estos hallazgos
[ ] T-137-106: Definir test de caminar por bordes de precipicio
[ ] T-137-107: Definir test de extraer bloque bajo los pies (no caer en void)
[ ] T-137-108: Definir test de diálogo interrumpido (guardar durante diálogo)
[ ] T-137-109: Definir test de dormir con lluvia activa
[ ] T-137-110: Definir test de sesión con save repetido 10 veces
[ ] T-137-111: Definir autoloads como singletons claros
[ ] T-137-112: Definir nombres de archivos consistentes (`*_proto.gd`)
[ ] T-137-113: Definir que el código del prototipo se pueda descartar sin afectar M138
[ ] T-137-114: Definir `const` para números mágicos (SPEED, RADIOS)
[ ] T-137-115: Definir `@export` para valores tunables
[ ] T-137-116: Definir registro de deuda técnica del prototipo (M111)
[ ] T-137-117: Definir que `docs/prototipo/` se actualice hasta el GONOGO
[ ] T-137-118: Definir actualización de `CHECKLIST-GLOBAL.md` al cerrar el hito
[ ] T-137-119: Definir log en `Logs/` del cierre del hito
[ ] T-137-120: Definir que la fila 137 quede 🟢 DELEGABLE al cerrar
[ ] T-137-121: Definir comunicar al usuario la decisión GO/NO-GO y próximos pasos
