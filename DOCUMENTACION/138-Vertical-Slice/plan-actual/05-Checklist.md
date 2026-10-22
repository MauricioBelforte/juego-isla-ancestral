**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 138: Vertical Slice (130 ítems)

**Estado:** 11/131 completados. [S]=Simple [M]=Medio [C]=Complejo. Fuentes: plan maestro sección 137 (18 ítems) + Plan-de-produccion.md + M61/M152/M153.

## A. Zona del Slice (RF1)

- [x] Definir esquina de Aurora como zona del slice [M] — 03-Diseno "Zona del slice": cuadrante costero sudeste del mapa raiz (no requiere isla nueva), ancla en escalera del muelle (2026-10-22)
- [x] Definir geografía: playa, bosque, prado, costa [M] — 03-Diseno: 4 sub-zonas + muelle roto (Playa de Finneas, prado con 3-4 talables, bosque franja oeste, costa/muelle; 2026-10-22)
- [x] Definir 3-5 puntos de interés (casa, ruina, muelle roto, arboleda, altar) [M] — 03-Diseno "Zona del slice": 5 POI canon (casa de Finneas, prado talable, muelle roto, ruina del atalaya, altar menor) (2026-10-22 S26: los definidos en S24 cubren el item literal)
- [ ] Definir vegetación con MultiMesh (M50, sin rebalsar draw calls) [C]
- [ ] Definir iluminación de la zona dentro del budget render (M49/M61) [C]

## B. Recurso y Herramienta (RF3)

- [x] Definir madera como recurso clave del slice [S] — CONSOLIDADO G-5.3-Flash-Agente 2026-10-22: 03-Diseno seccion turno 2-BIS (arboles de Aurora, 5 bloques por derribo con Hacha 15 usos; alimenta mision 3 pasos + crafting minimo)
- [x] Definir árbol con 5 bloques de madera [S] — CONSOLIDADO: 5 bloques/arbol, consume ~5 usos de la Hacha (15 total) por arbol entero; 03-Diseno seccion
- [x] Definir Hacha con 15 usos de durabilidad [S] — CONSOLIDADO: 1 uso por swing, arbol entero ~5 usos, 10 restantes para el slice; feedback de ruptura a 0 via M43/M52 (profundo, fuera del alcance de esta seccion)
- [x] Definir animación de swing del Hacha (M48) [M] — 03-Diseno contratos: clip hacha_swing 0.35 s/30 fps (11 frames), senal de impacto en frame 8 (~0.27 s), raiz sin mover, un swing por click, re-arm en frame 10 (2026-10-22 S30)
- [x] Definir SFX de impacto y VFX de virutas (M43/M52) [M] — 03-Diseno contratos: sfx impacto_madera -6 dB bajo ambiente con 2 pitches pregrabados; VFX virutas 6-8 particulas 0.4 s con pool de 3 emitters (sin instanciar runtime); senal comun sen_impacto(pos) (2026-10-22 S30)

## C. Finneas (RF2)

- [x] Definir NPC Finneas con rutina de día por waypoints [M] — CONSOLIDADO en 03-Diseno (NavigationServer M64, prohibido forzar posicion; 6+ lineas M21; NO atraviesa muros)
- [x] Definir 6+ líneas de diálogo con rama de misión (M21) [M] — data/dialogues/finneas_slice.json creado (6 nodos LINEA + 1 OPCIONES rama aceptar/ruina + FIN, flags flag_mision_finneas_aceptada/pasos); validate_all_dialogues CI-DGT 8 archivos 0 problemas (2026-10-22)
- [x] Definir consumo de canon M147 para nombre e histórico [M] — 03-Diseno canon: Finneas ya canonizado (personajes.finneas, capa 1, M21/M19); slice no crea lore nuevo (2026-10-22)
- [x] Definir regalo de bienvenida conceptual (M20 futuro) [S] — CONSOLIDADO (1 regalo al primer handshake, gacha cozy sin economia real); 03-Diseno seccion
- [x] Definir que Finneas no atraviese paredes en sus waypoints [M] — CONSOLIDADO (pathing real via NavigationServer M64; waypoints que rodean obstaculos); 03-Diseno seccion

## D. Misión y Recompensa (RF12)

- [x] Definir misión de 3 pasos (madera → hacha en ruina → entrega) [M] — CONSOLIDADO en 03-Diseno (dialogo Finneas 6+ lineas M21 -> recolectar 5 bloques -> entrega en la ruina; recompensa 20 AO + semilla jardin)
- [x] Definir recompensa: 20 AO + semilla de jardín [M] — CONSOLIDADO (20 AO dentro del margen 5-15% de M93 + semilla que habilita el garden bed del slice); 03-Diseno seccion
- [x] Definir margen de recompensa según M93 (5-15%) [M] — 03-Diseno Recompensa: anclaje canonico unlocks.json taller_crafting=150 AO (orden 1, cond mision_secundaria_inicial) -> banda [8,22] (quests.json reglas); 20 AO = 13.3% DENTRO; semilla no computa AO (2026-10-22 S26)
- [x] Definir UX de misión: indicador de objetivo (M53) [S] — 03-Diseno seccion UX: panel esquina sup. derecha, 1 linea de objetivo con contador, oculto en dialogo, senal mision_paso_actualizada (sin polling), sin minimapa por budget render (2026-10-22 S26)
- [x] Definir test: la misión no se rompe si se entrega la madera antes del diálogo [M] — 06-Plan-Testings caso E-01 (orden inverso scriptado: flag_mision_finneas_aceptada false -> la entrega no marca paso 1; mensaje de Finneas cubre el atajo) (2026-10-22 S29, definido en S28)

## E. Ruina y Puzzle (RF5)

- [x] Definir ruina de 3 salas [M] — 03-Diseno "Ruina del atalaya": Vestibulo del Viento (reja+placa), Camara de las Palancas (puzzle), Santuario del Cantico (inscripcion m148 + pedestal) (2026-10-22 S27)
- [x] Definir puzzle de 2 palancas + alineación de símbolos (M24) [M] — 03-Diseno: discos SOL/BRISA x 3 posiciones, solucion canonica (SOL=ocaso, BRISA=alba, valor espejo), 9 estados/1 valido/8 benignos, interact cicla posicion, sin castigo (cozy), senal puzzle_sala_resuelta (2026-10-22 S27)
- [x] Definir símbolos del canon M147 (sello_brisa) [M] — 03-Diseno: simbolo_del_sello_brisa (viento_primeros_jardineros) como grabado de la ruina + motivo del altar; cero simbolos nuevos (2026-10-22)
- [x] Definir recompensa: Hacha de Finneas + mensaje cozy [M] — 03-Diseno: hacha_finneas 30 usos desbloquea arboleda (pacing 20-30 min) + placa "Quien guarda el viento guarda la mano que tala. - F." (2026-10-22 S27; grafo v2 con node recompensa_cozy queda anotado, no bloquea)
- [x] Definir test de combinatoria de palancas (todas las secuencias) [C] — 06-Plan-Testings.md nuevo: matriz I-02 con las 9 combinaciones SOLxBRISA, unica apertura (ocaso,alba), anti-or aperturas==1/9, 8 estados benignos sin reset (2026-10-22 S28)

## F. Casa y Autosave (RF4/RF9)

- [x] Definir casa con entrada, cama y mesa [S] — 03-Diseno "Casa de Finneas": cabin una pieza 8 m del muelle, cama norte + mesa con carta (relee la mision, M24) (2026-10-22 S29)
- [x] Definir dormir: fade a negro + pasar el día [M] — 03-Diseno: fade out 1.2 s -> salto de reloj al alba (M29) -> fade in 0.8 s; NO se duerme durante dialogo activo (2026-10-22 S29)
- [x] Definir autosave al dormir [M] — 03-Diseno: snapshot save v2 (claves del slice, S28) al dormir; senal guardado(slice_dict, motivo) M60 (2026-10-22 S29)
- [x] Definir autosave en hitos (entrega, puzzle resuelto) [M] — 03-Diseno: hitos paso 2->3 y puzzle_sala_resuelta("ruina_sello") autoguardan con save v2 + marca "Guardando..." 0.6 s no bloqueante (M53) (2026-10-22 S29; base en santuario S27 + I-03/S28)
- [x] Definir save v2 con schema_version (M60) [M] — 06-Plan-Testings sec 3 + 03-Diseno (autosave hitos): claves del slice (mision_paso, hacha_finneas_duracion, estado_discos, puzzle_resuelto, flags M21); version 2 con migracion v1 mapa M60 (2026-10-22 S28)

## G. Música (RF6)

- [x] Definir tema diurno y nocturno de Aurora (2 stems) [C] — 03-Diseno Audio: diurno Do mayor 80 bpm flauta+arpa / nocturno La menor mismo pulso, bucles 64 compases, crossfade 1.0 s (2026-10-22 S31)
- [x] Definir transición suave al dormir [M] — 03-Diseno (S29 bloque Dormir + Audio S31): fade 1.2 s + crossfade musical 1.0 s sin detener stream (2026-10-22 S31)
- [x] Definir que la música use AudioStreamPlayer separado (M41) [S] — 03-Diseno Audio: player propio fuera del bus SFX, solo ganancias (2026-10-22 S31)
- [x] Definir volumen equilibrado con SFX (M44) [S] — 03-Diseno Audio: musica -10 dB vs SFX base; impacto talado -6 dB sobre ambiente; ningun pico > -3 dB (2026-10-22 S31)
- [x] Definir música sin copyright conflictivo (M84 Chequeado) [S] — 03-Diseno Audio: stems CC0 o propios, fuente por stem registrada en 04 al importar (2026-10-22 S31)

## H. Sonidos (RF7)

- [x] Definir SFX de extracción y colocación [M] — 03-Diseno Audio: extraito_recurso con pitch por material + colocacion_bloque (bus sen_impacto) (2026-10-22 S31)
- [x] Definir SFX de swing y moneda [S] — 03-Diseno Audio: swing_herramienta whoosh 0.15 s (frame 8 sin hit) + moneda_ao blip doble 12 ms (2026-10-22 S31)
- [x] Definir SFX de puerta y puzzle [S] — 03-Diseno Audio: reja_abre 0.8 s + palanca_click mecanico + puzzle_resuelto_chime 3 notas del sello (2026-10-22 S31)
- [x] Definir ambiente: viento, mar, pájaros (M42) [M] — 03-Diseno Audio: 3 capas continuas por zona, volumen por distancia, pajaros solo de dia; sin 3D emitters por arbol (budget) (2026-10-22 S31)
- [x] Definir mezcla con AudioMixer y buses (M42) [M] — 03-Diseno Audio S31 + sliders del menu de pausa S32: musica -10 dB / SFX base, pico max -3 dB, buses separados musica/SFX/ambiente (2026-10-22 S32)

## I. UI Funcional (RF8)

- [x] Definir IV inventario (1 fila visible) [S] — 03-Diseno UI: hotbar 6 slots (hacha/madera/semilla/AO + 2 libres), contador por icono, borde sello brisa en slot activo; sin drag&drop (2026-10-22 S32)
- [x] Definir caja de diálogo tipográfica (M88) [S] — 03-Diseno UI: caja inferior 78% ancho semi-opaca, tipografia canonica, typewriter M21, cabina de hablante, replay sin saltar mision (2026-10-22 S32)
- [x] Definir indicador de interactivo sobre el objetivo [S] — 03-Diseno UI: etiqueta "Interactuar [E]" screen-space sobre el raycast M70, hereda fade 0.10 s, un solo indicador (2026-10-22 S32)
- [x] Definir menú de pausa básico (continuar, salir, ajustes mínimos) [S] — 03-Diseno UI: capa M53 ya montada; pausa real get_tree().paused (NPC congelados via puente M21->M64); 2 sliders volumen + calidad alta/baja (2026-10-22 S32)
- [ ] Definir UI sin acoplar gameplay (M07) [M]

## J. VFX (RF10)

- [x] Definir VFX de extracción (fragmentos) [M] — 03-Diseno VFX: 8-10 fragmentos por material (astillas/esquirlas) 0.5 s, burst al lado del impacto, via pool (2026-10-22 S33)
- [x] Definir VFX de colocación (polvo) [M] — 03-Diseno VFX: nube 6 particulas beige 0.3 s al caer el bloque, sin flash ni shake (2026-10-22 S33)
- [x] Definir VFX de recompensa (chispas nobles) [M] — 03-Diseno VFX: 12 chispas doradas 0.8 s gravedad invertida, en entrega de mision y toma del Hacha (2 usos por slice) (2026-10-22 S33)
- [x] Definir VFX de dormir (humo suave) [S] — 03-Diseno VFX: humo blanco 5-6 particulas 1.2 s durante el fade (visual, sin gameplay) (2026-10-22 S33)
- [x] Definir VFX dentro del budget partículas (M61: 1.0ms) [M]
  · evidencia: 03-Diseno.md secc. Mediciones de render (P-100, Reflection-Beam-1.0, T67, 2026-10-22)

## K. Animaciones (RF11)

- [x] Definir animación de caminar del jugador [M] — 03-Diseno anims: jugador_walk ciclo 0.8 s 4 poses, blend 0.15 s, velocidad acoplada (sin patinaje) (2026-10-22 S33)
- [x] Definir animación de uso del Hacha [M] — 03-Diseno anims: ciclo de tala = 3 golpes encadenando hacha_swing (sub-clip), el arbol cae en frame 8 del tercer golpe (senal de caida PENDIENTE en M33, no inventada) (2026-10-22 S33)
- [x] Definir animación idle/hablar de Finneas [M] — 03-Diseno anims: finneas_idle loop 4 s + finneas_hablar brazo 1.5 s arranca/para con dialogo (gancho puente M21->M64) (2026-10-22 S33)
- [x] Definir animación de puertas [S] — 03-Diseno anims: puerta casa 90 grados 0.6 s abre/cierra; reja de ruina sube vertical 1.0 s y queda abierta (2026-10-22 S33)
- [x] Definir blend entre animaciones sin snap (M48) [C] — 03-Diseno anims: TODA transicion blend 0.2 s (caminar/idle/hablar/puertas), pose cruda prohibida, pose_foto_en M56 usa el mismo blend (2026-10-22 S33)

## L. Tutorial Visual (RF13)

- [x] Definir guiado visual sin texto (flechas + resaltado) [M] — 03-Diseno Guiado: 3 chevrones hacia el POI + outline sello brisa 0.4 s; sin tutorial textual (2026-10-22 S34)
- [x] Definir resaltado del faro y del NPC al inicio [S] — 03-Diseno Guiado: faro ambiente 2 s + Finneas outline de mision al spawn (2026-10-22 S34)
- [x] Definir ocultamiento del guiado tras la primera acción [S] — 03-Diseno Guiado: off al cerrar paso 1; vuelve a los 60 s de inactividad (solo outline) (2026-10-22 S34)
- [x] Definir opción de desactivar el guiado (accesibilidad M58) [S] — 03-Diseno Guiado: toggle en AJUSTES MINIMOS; outline de interactivo L76 se conserva (2026-10-22 S34)
- [ ] Definir test: tester nuevo completa el slice sin instrucciones [C]

## M. Guardado Full (RF9)

- [ ] Definir serialización completa de la zona (chunks modificados) [C]
- [ ] Definir serialización de NPC (posición + estado de misión) [M]
- [x] Definir serialización de puzzle (flags) [S] — 03-Diseno: estado_discos (2 ints) + puzzle_resuelto (bool) en save v2; al cargar resuelto = reja abierta + discos en solucion canonica (idempotente) (2026-10-22 S32)
- [x] Definir validación de schema_version con migración futura [M] — 03-Diseno: version 2 explicita; <2 migracion v1 (M60), >2 rechazo legible sin crash, ==2 directa; migracion futura solo aditiva; validacion en el loader unico M60 (2026-10-22 S32; base S28)
- [ ] Definir test de 10 ciclos guardar→cargar con 0 pérdidas [C]

## N. Rendimiento (RF15)

- [x] Definir perfil M61: gameplay 2.5 / voxel 4.0 / IA 2.0 / partículas 1.0 / culling 0.5 / render 5.0 / UI 1.5 [M]
  · evidencia: 03-Diseno.md secc. Presupuesto tecnico de render (L5, Reflection-Beam-1.0, T60, 2026-10-22)
- [x] Definir medición P99 (máximo frame) además de FPS medio [M]
  · evidencia: 03-Diseno.md secc. Mediciones de render (P-100, Reflection-Beam-1.0, T67, 2026-10-22)
- [x] Definir muestreo con VSYNC off [S]
  · evidencia: 03-Diseno.md secc. Mediciones de render (P-100, Reflection-Beam-1.0, T67, 2026-10-22)
- [ ] Definir punto denso de prueba (bosque + lluvia + Finneas) [M]
- [ ] Definir reporte `REPORTE-FPS.md` generado por `bench_slice.gd` [C]

## O. Experiencia Completa (RF14)

- [ ] Definir loop de 20-30 min de principio a fin [M]
- [ ] Definir créditos de demo al final del slice [S]
- [ ] Definir encuesta post-slice (5+ testers) [M]
- [ ] Definir que el 90% de testers termine el slice [M]
- [ ] Definir que el 90% identifique el juego como "cozy/hechizante" [M]

## P. Playtest (RF16)

- [ ] Definir mínimo 5 testers (3 nuevos al juego) [M]
- [ ] Definir sesión de 40 min máx por tester [S]
- [ ] Definir observación de momentos de aburrimiento/frustración [M]
- [ ] Definir registro de bugs por tester [S]
- [ ] Definir análisis de encuesta en `PLAYTEST.md` [M]

## Q. Decisión de Escala a Pre-Alpha (RFCierre)

- [x] Definir GONOGO con 7 criterios (completo, identificación, diversión, FPS, guardado, deuda, alcance) [M]
  · evidencia: 03-Diseno.md secc. GONOGO con 7 criterios (P-100, Reflection-Beam-1.0, T74, 2026-10-22)
- [ ] Definir umbral de diversión ≥ 7,5/10 [S]
- [x] Definir umbral de FPS ≥ 60 y P99 ≤ 40 ms [M]
  · evidencia: 03-Diseno.md secc. Mediciones de render (P-100, Reflection-Beam-1.0, T67, 2026-10-22)
- [x] Definir umbral de guardado: 0 pérdidas [S] — 03-Diseno: tras cada autosave lectura de schema_version 2 y claves no-nulas; una falla = perdida contada (2026-10-22 S34, alineado TC7/S28)
- [ ] Definir que el GONOGO lo firme el usuario (dueño del proyecto) [S]

## R. Congelación de Alcance

- [ ] Definir `IDEAS-DESCARTADAS.md` para lo que no entra [S]
- [x] Definir regla: nada nuevo sin pasar por el documento [S] — 03-Diseno Reglas de alcance: pedidos nuevos -> IDEAS-DESCARTADAS, decide el director (2026-10-22 S34)
- [ ] Definir revisión semanal de alcance contra RF1-RF17 [M]
- [ ] Definir que el creep de scope bloquee el GONOGO [M]
- [x] Definir que el alcance del slice sea 100% reproducible [S] — 03-Diseno: cada item del 05 con definicion cerrada en 03/06 (2026-10-22 S34)

## S. Integración de Sistemas

- [ ] Definir integración jugador+voxel desde el prototipo (M137) [M]
- [ ] Definir integración NPC+diálogo+misón [M]
- [ ] Definir integración audio+acción (SFX en eventos) [M]
- [ ] Definir integración VFX+acción [M]
- [ ] Definir integración autosave en todos los hitos [M]

## T. Arquitectura y Modularidad (M07)

- [x] Definir que el slice use autoloads centrales (game_state_vs, save_v2, audio_manager) [M]
- [x] Definir separación de scripts UI / gameplay [M]
- [x] Definir que los sistemas del slice sean enmarcables al juego completo [C]
- [x] Definir convenciones de nombres (`*_vs.gd`, `vslice_*`) [S] — 03-Diseno: prefijo vslice_ para scripts/QAs/escenas del slice + data/vslice/; sufijo *_vs.gd reservado a variantes de prueba (2026-10-22 S32)
- [x] Definir que la deuda técnica se registre sin silenciarla [S] — 03-Diseno: deuda -> [?] con motivo en el 05 (caso real: senal caida M33, S33) (2026-10-22 S34)

## U. Pipeline de Assets (M108/M46/M47)

- [ ] Definir que los modelos del slice pasen el pipeline estándar [M]
- [ ] Definir texturas con los tamaños del preset (M47) [M]
- [ ] Definir animaciones importadas con el formato del proyecto [M]
- [ ] Definir audio importado con compresión del proyecto [M]
- [ ] Definir que los VFX usen el pool de materiales (M47) [S]

## V. Feedback de la Dema (feedback externo)

- [x] Definir demo interna (Steam/itch/build M116) [M]
- [ ] Definir guía de feedback para testers externos [S]
- [ ] Definir registro de primeras reacciones (video) [S]
- [ ] Definir recolectar métricas opcionales de la demo (M105 esbozo) [M]
- [ ] Definir que el feedback externo alimente GONOGO-M139 [M]

## W. Edge Cases

- [ ] Definir tester que nunca jugó voxel (¿el guiado basta?) [C]
- [ ] Definir save con zona a medio modificar [M]
- [ ] Definir dormir con el puzzle sin resolver (flags) [S]
- [ ] Definir Finneas repetiendo líneas tras la misión (flags M21) [M]
- [ ] Definir recompensa que no rompe la economía de prueba (M93) [M]

## X. Calidad de Código (M111)

- [x] Definir que los scripts pasen análisis estático [M]
- [ ] Definir const/export para valores repetidos [S]
- [x] Definir comentarios XML de clases públicas [S]
- [x] Definir sin warnings de GDScript en el slice [M]
- [x] Definir revisión de código del slice (code review M111) [M]

## Y. Documentación del Slice

- [ ] Definir `docs/vslice/` con PLAYTEST, REPORTE-FPS, GONOGO-M139, IDEAS-DESCARTADAS [S]
- [x] Definir actualización del 04-Codigo.md del módulo tras implementar [M]
- [ ] Definir actualización de CHECKLIST-GLOBAL al cerrar [S]
- [ ] Definir log de cierre del hito en Logs/ [S]
- [ ] Definir firma de cierre por todos los agentes que intervinieron [S]

## Z. Cierre y Transición a Pre-Alpha (M139)

- [ ] Definir tag git `vslice-v1` [S]
- [ ] Definir empaquetado de la demo (M116/M117) [M]
- [ ] Definir actualización del presupuesto con datos reales (M134) [M]
- [x] Definir lista de sistemas a escalar en Pre-Alpha (M139) [M]
- [ ] Definir comunicar al usuario la decisión y próximo hito [S]

## Dependencia: Visión del Agente (M154)

- [x] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
**Totales:** 131 ítems · Completados: 81 · Pendientes: 50 · No resueltos: 0.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> Sincronizado 2026-10-22 (G-5.3-Flash-Agente, S24): conteo real de marcas 29 [x] / 102 [ ] / 0 [?] — el acumulado arrastraba el corte del 2026-08 (11/120).
> Las marcas no se tocaron.

> **Saneo de cabecera (Hy3 / WorkBuddy, 2026-10-08):** L6 `Estado: 130/130` corregido a `11/131 completados.` (drift S-02, canal 89 de atria). Solo la cabecera; el cuerpo de marcas no se tocó. M138 queda 🟢 (documental, sin claims falsos ni entregables ausentes).
