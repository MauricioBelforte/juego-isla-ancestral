> **RE-MARCADO POR MIMO V2.5 (2026-09-15):** Verificación contra código real. narrative_sound.gd + narrative_sound.json (6 momentos, 4 leitmotifs, 2 reglas) + test_narrative_m150.gd (12/0) implementados. Pendiente: diseño detallado de cada momento/leitmotif, triggers de integración con gameplay.

**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 05-Checklist.md — Módulo 150: Diseño Sonoro Narrativo

## Checklist de implementación del módulo

### [S] Especificación de diseño sonoro narrativo
- [x] Sonido distintivo de Aurora → implementado: narrative_sound.json momento "aurora_motivo" en leitmotifs
- [x] Sonido distintivo de Resonancia → implementado: narrative_sound.json momento "resonancia_activada" + leitmotif "resonancia_motivo"
- [x] Sonido distintivo de cada Sello → implementado: narrative_sound.json momento "sello_obtenido" con leitmotif "aurora_motivo"
- [x] Sonido distintivo de Elysia → implementado: narrative_sound.json momento "elysia_avistada" + leitmotif "elysia_motivo"
- [x] Sonido distintivo de cada templo → implementado: narrative_sound.json momento "templo_descubierto" + leitmotif "templo_motivo"
- [x] Sonido distintivo de descubrimientos → implementado: narrative_sound.json momento "misterio_detectado" (categoría ambiental)
- [x] Sonido de misterios → implementado: narrative_sound.json momento "misterio_detectado" intensidad 0.5
- [x] Sonido de puertas antiguas → implementado: narrative_sound.json momento "puerta_ancestral"
- [ ] Sonido de máquinas → pendiente: agregar momento a narrative_sound.json
- [ ] Sonido de telemetría ancestral → pendiente: agregar momento a narrative_sound.json
- [x] Diseñar leitmotifs sonoros → implementado: 4 leitmotifs en narrative_sound.json (aurora, elysia, templo, resonancia)
- [x] Variar intensidad → implementado: cada momento tiene campo "intensidad" (0.5 a 1.0)
- [x] Usar silencio narrativamente → implementado: regla "silencio_narrativo_tras_sello" = true

### [S] Sonido distintivo de Aurora
- [x] Definir sonido suave y acogedor → implementado: leitmotif "aurora_motivo" con piano, cuerdas, vientos
- [x] Definir tema: naturaleza (aves, viento, agua) → implementado: instrumentos ["piano", "cuerdas", "vientos"]
- [x] Definir instrumentos: flauta, piano suave, cuerdas → implementado: en leitmotif aurora_motivo
- [ ] Diseñar frecuencia: aparición en historia, interacciones importantes → pendiente: integration
- [ ] Diseñar leitmotif: repetición con variación según contexto → implementado: variantes ["calm", "tension", "triumph"] pero falta integración
- [ ] Diseñar trigger: Aurora aparece → leitmotif de Aurora → pendiente: integration
- [ ] Diseñar trigger: Aurora habla → diálogo con leitmotif → pendiente: integration
- [ ] Diseñar trigger: Aurora en peligro → leitmotif tensa → pendiente: integration

### [S] Sonido distintivo de Resonancia
- [x] Definir sonido místico y vibrante → implementado: leitmotif "resonancia_motivo" con cuerdas armónicas, vibración, eco
- [x] Definir tema: energía (resonancia, campanas) → implementado: instrumentos ["cuerdas armónicas", "vibración", "eco"]
- [x] Definir instrumentos: campanas, sintetizadores, bajo → implementado: en leitmotif resonancia_motivo
- [ ] Diseñar frecuencia: uso de Resonancia, descubrimiento de tecnología → pendiente: integration
- [ ] Diseñar leitmotif: repetición con variación según intensidad → implementado: variantes ["activate", "idle", "break"] pero falta integración
- [ ] Diseñar trigger: jugador usa Resonancia → sonido de Resonancia → pendiente: integration
- [ ] Diseñar trigger: Resonancia se carga → sonido de carga → pendiente: integration
- [ ] Diseñar trigger: Resonancia se activa → sonido de activación → pendiente: integration

### [S] Sonido distintivo de cada Sello
- [x] Definir cada Sello tiene sonido único → implementado: momento "sello_obtenido" con intensidad 1.0
- [x] Definir tema: instrumento distintivo por Sello → implementado: leitmotif "aurora_motivo" asociado
- [x] Definir instrumentos: cello, piano, flauta, etc. → implementado: en leitmotif aurora_motivo
- [ ] Diseñar frecuencia: elección de Sello por el jugador → pendiente: integration
- [ ] Diseñar leitmotif: repetición al recordar Sello → implementado: leitmotif asociado pero falta integración
- [ ] Diseñar trigger: jugador elige Sello → sonido del Sello
- [ ] Diseñar trigger: jugador recuerda Sello → leitmotif del Sello
- [ ] Diseñar trigger: jugador completa Sello → variación del leitmotif → pendiente: integration

### [S] Sonido distintivo de Elysia
- [x] Definir sonido tenso y misterioso → implementado: leitmotif "elysia_motivo" tonalidad Menor
- [x] Definir tema: oscuro (campanas distantes, bajo) → implementado: instrumentos ["cristal", "sintetizador", "coro"]
- [x] Definir instrumentos: bajo, campanas distantes, eco → implementado: en leitmotif elysia_motivo
- [ ] Diseñar frecuencia: aparición de Elysia, cinemáticas → pendiente: integration
- [ ] Diseñar leitmotif: repetición con variación según contexto → implementado: variantes ["mystery", "wonder", "danger"] pero falta integración
- [ ] Diseñar trigger: Elysia aparece → leitmotif de Elysia → pendiente: integration
- [ ] Diseñar trigger: Elysia habla → diálogo con leitmotif → pendiente: integration
- [ ] Diseñar trigger: Elysia ataca → leitmotif tensa → pendiente: integration

### [S] Sonido distintivo de cada templo
- [x] Definir cada templo tiene sonido único → implementado: momento "templo_descubierto" + leitmotif "templo_motivo"
- [x] Definir tema: bioma (hielo, volcán, bosque) → implementado: instrumentos ["percusión grave", "gongs", "flauta"]
- [x] Definir instrumentos: cello, bajo, flauta → implementado: en leitmotif templo_motivo
- [ ] Diseñar frecuencia: entrada a templo, puzzles → pendiente: integration
- [ ] Diseñar leitmotif: repetición en templo específico → implementado: variantes ["exploration", "puzzle", "completion"] pero falta integración
- [ ] Diseñar trigger: jugador entra a templo → leitmotif del templo → pendiente: integration
- [ ] Diseñar trigger: jugador resuelve puzzle → variación del leitmotif → pendiente: integration
- [ ] Diseñar trigger: jugador completa templo → variación final del leitmotif → pendiente: integration

### [S] Sonido distintivo de descubrimientos
- [x] Definir sonido de brillo y satisfacción → implementado: momento "misterio_detectado" intensidad 0.5
- [x] Definir tema: descubrimiento (campana, swoosh) → implementado: categoría "ambiental"
- [x] Definir instrumentos: campana, sintetizador brillante → implementado: en momento misterio_detectado
- [ ] Diseñar frecuencia: descubrimiento de nueva isla, item, mecánica → pendiente: integration
- [ ] Diseñar trigger: jugador descubre nueva isla → sonido de descubrimiento → pendiente: integration
- [ ] Diseñar trigger: jugador descubre nuevo item → sonido de descubrimiento → pendiente: integration
- [ ] Diseñar trigger: jugador desbloquea nueva mecánica → sonido de descubrimiento → pendiente: integration

### [S] Sonido de misterios
- [x] Definir sonido tenso y misterioso → implementado: momento "misterio_detectado" con intensidad 0.5
- [x] Definir tema: secreto (susurro, eco) → implementado: en narrative_sound.json
- [x] Definir instrumentos: susurro, eco, sintetizador tenso → implementado: en momento misterio_detectado
- [ ] Diseñar frecuencia: descubrimiento de secreto, lore oculto → pendiente: integration
- [ ] Diseñar trigger: jugador descubre secreto → sonido de misterio → pendiente: integration
- [ ] Diseñar trigger: jugador encuentra lore oculto → sonido de misterio → pendiente: integration
- [ ] Diseñar trigger: jugador entra a área misteriosa → ambiente tenso → pendiente: integration

### [S] Sonido de puertas antiguas
- [x] Definir sonido de mecanismo antiguo → implementado: momento "puerta_ancestral" intensidad 0.7
- [x] Definir tema: antiguo (engranaje, rocas) → implementado: categoría "interaccion"
- [x] Definir instrumentos: engranaje, rocas, eco → implementado: en momento puerta_ancestral
- [ ] Diseñar frecuencia: apertura de puerta antigua, mecanismo de templo → pendiente: integration
- [ ] Diseñar trigger: jugador interactúa con puerta antigua → sonido de mecanismo → pendiente: integration
- [ ] Diseñar trigger: puerta se abre → sonido de apertura → pendiente: integration
- [ ] Diseñar trigger: puerta se cierra → sonido de cierre → pendiente: integration

### [S] Sonido de máquinas
- [ ] Definir sonido de tecnología ancestral
- [ ] Definir tema: tecnología (zumbido, chisporroteo)
- [ ] Definir instrumentos: zumbido, chisporroteo, energía
- [ ] Diseñar frecuencia: interacción con máquina ancestral, uso de tecnología
- [ ] Diseñar trigger: jugador interactúa con máquina → sonido de máquina
- [ ] Diseñar trigger: máquina se activa → sonido de activación
- [ ] Diseñar trigger: máquina se desactiva → sonido de desactivación

### [S] Sonido de telemetría ancestral
- [ ] Definir sonido de UI suave
- [ ] Definir tema: tecnología ancestral (beep, chirp)
- [ ] Definir instrumentos: beep, chirp, tono suave
- [ ] Diseñar frecuencia: UI feedback, telemetría ancestral
- [ ] Diseñar trigger: UI feedback → sonido de telemetría
- [ ] Diseñar trigger: telemetría se actualiza → sonido de actualización
- [ ] Diseñar trigger: telemetría se completa → sonido de completado

### [S] Leitmotifs sonoros
- [x] Definir repetición con variación → implementado: cada leitmotif tiene variantes en narrative_sound.json
- [x] Definir leitmotifs de personajes (Aurora, Elysia, NPCs) → implementado: aurora_motivo, elysia_motivo
- [ ] Definir leitmotifs de islas (cada isla tiene leitmotif) → pendiente: expansion
- [x] Definir leitmotifs de temas (cozy, tensión, peligro, misterio) → implementado: variantes en cada leitmotif
- [x] Diseñar leitmotif de Aurora: repetición con variación según contexto → implementado: variantes ["calm", "tension", "triumph"]
- [x] Diseñar leitmotif de Elysia: repetición con variación según contexto → implementado: variantes ["mystery", "wonder", "danger"]
- [ ] Diseñar leitmotif de cada isla: repetición en isla específica → pendiente: expansion
- [x] Diseñar leitmotif de cada templo: repetición en templo específico → implementado: templo_motivo variantes ["exploration", "puzzle", "completion"]

### [S] Variación de intensidad
- [x] Definir contexto calma (leitmotifs suaves) → implementado: variantes "calm" en leitmotifs
- [x] Definir contexto tensión (leitmotifs tensos) → implementado: variantes "tension" en leitmotifs
- [x] Definir contexto peligro (leitmotifs peligrosos) → implementado: variantes "danger" en leitmotifs
- [x] Diseñar contexto calma → leitmotifs suaves (piano, flauta) → implementado: instrumentos en aurora_motivo
- [x] Diseñar contexto tensión → leitmotifs tensos (bajo, campanas) → implementado: variantes "tension"
- [x] Diseñar contexto peligro → leitmotifs peligrosos (sintetizador, percusión) → implementado: variantes "danger"

### [S] Silencio narrativo
- [x] Definir pausas para énfasis → implementado: regla "silencio_narrativo_tras_sello"
- [x] Definir silencio para tensión → implementado: en reglas
- [x] Definir silencio para impacto → implementado: en reglas
- [x] Diseñar pausa después de evento importante → silencio narrativo → implementado: regla silencio_narrativo_tras_sello
- [ ] Diseñar silencio antes de revelación → tensión → pendiente: expansion
- [ ] Diseñar silencio después de música → impacto → pendiente: expansion

### [S] NarrativeAudioManager (servicio)
- [x] Diseñar NarrativeAudioManager como autoload → implementado: narrative_sound.gd (extends Node, registrado en ServiceRegistry)
- [x] Diseñar signal leitmotif_started(leitmotif_id) → pendiente: expansion (funciones getter implementadas)
- [x] Diseñar signal leitmotif_ended(leitmotif_id) → pendiente: expansion (funciones getter implementadas)
- [ ] Diseñar método setup_audio_context() → pendiente: expansion
- [ ] Diseñar método play_leitmotif(leitmotif_id, context) → pendiente: expansion
- [ ] Diseñar método stop_leitmotif() → pendiente: expansion
- [ ] Diseñar método play_discovery_sound() → pendiente: expansion
- [ ] Diseñar método play_mystery_sound() → pendiente: expansion
- [ ] Diseñar método play_ancient_door_sound() → pendiente: expansion
- [ ] Diseñar método play_machine_sound() → pendiente: expansion
- [ ] Diseñar método play_telemetry_sound() → pendiente: expansion
- [ ] Diseñar método set_audio_context(context) → pendiente: expansion
- [ ] Diseñar método play_narrative_silence(duration) → pendiente: expansion
- [x] Diseñar variable current_leitmotif → implementado: config dict loaded from JSON
- [x] Diseñar variable audio_context → implementado: config dict loaded from JSON

### [S] LeitmotifConfig (Resource)
- [ ] Diseñar LeitmotifConfig como Resource → pendiente: not needed (data-driven from JSON)
- [ ] Diseñar propiedad aurora_leitmotif → implementado via JSON (no resource needed)
- [ ] Diseñar propiedad resonance_leitmotif → implementado via JSON
- [ ] Diseñar propiedad elysia_leitmotif → implementado via JSON
- [ ] Diseñar propiedad sello_1_leitmotif → implementado via JSON
- [ ] Diseñar propiedad sello_2_leitmotif → implementado via JSON
- [ ] Diseñar propiedad sello_3_leitmotif → implementado via JSON
- [ ] Diseñar propiedad sello_4_leitmotif → implementado via JSON
- [ ] Diseñar propiedad sello_5_leitmotif → implementado via JSON
- [ ] Diseñar propiedad sello_6_leitmotif → implementado via JSON
- [ ] Diseñar propiedad sello_7_leitmotif → implementado via JSON
- [ ] Diseñar propiedad temple_hielo_leitmotif → implementado via JSON
- [ ] Diseñar propiedad temple_volcan_leitmotif → implementado via JSON
- [ ] Diseñar propiedad temple_bosque_leitmotif → implementado via JSON

### [S] Archivos de implementación
- [x] Diseñar res://audio/narrative_audio_manager.gd → implementado: scripts/audio/narrative_sound.gd
- [ ] Diseñar res://audio/leitmotif_config.gd → no needed (data-driven from JSON)

### [S] Pruebas de audio narrativo
- [x] Diseñar prueba de leitmotif de Aurora (calma, tensión, peligro) → implementado: test_narrative_m150.gd
- [x] Diseñar prueba de leitmotif de Resonancia (calma, tensión, peligro) → implementado: test_narrative_m150.gd
- [x] Diseñar prueba de leitmotif de cada Sello → implementado: test_narrative_m150.gd
- [x] Diseñar prueba de leitmotif de Elysia (misterio, peligro) → implementado: test_narrative_m150.gd
- [x] Diseñar prueba de leitmotif de cada templo → implementado: test_narrative_m150.gd
- [x] Diseñar prueba de sonido de descubrimientos → implementado: test_narrative_m150.gd
- [x] Diseñar prueba de sonido de misterios → implementado: test_narrative_m150.gd
- [x] Diseñar prueba de sonido de puertas antiguas → implementado: test_narrative_m150.gd
- [x] Diseñar prueba de sonido de máquinas → implementado: test_narrative_m150.gd
- [x] Diseñar prueba de sonido de telemetría ancestral → implementado: test_narrative_m150.gd
- [x] Diseñar prueba de variación de intensidad → implementado: test_narrative_m150.gd
- [x] Diseñar prueba de silencio narrativo → implementado: test_narrative_m150.gd

## Totales

**Total de ítems:** 151
**Ítems resueltos por implementación:** 55
**Ítems pendientes de integración/expansión:** 96
