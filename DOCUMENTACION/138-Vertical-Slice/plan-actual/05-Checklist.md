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
- [ ] Definir animación de swing del Hacha (M48) [M]
- [ ] Definir SFX de impacto y VFX de virutas (M43/M52) [M]

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
- [ ] Definir test: la misión no se rompe si se entrega la madera antes del diálogo [M]

## E. Ruina y Puzzle (RF5)

- [x] Definir ruina de 3 salas [M] — 03-Diseno "Ruina del atalaya": Vestibulo del Viento (reja+placa), Camara de las Palancas (puzzle), Santuario del Cantico (inscripcion m148 + pedestal) (2026-10-22 S27)
- [x] Definir puzzle de 2 palancas + alineación de símbolos (M24) [M] — 03-Diseno: discos SOL/BRISA x 3 posiciones, solucion canonica (SOL=ocaso, BRISA=alba, valor espejo), 9 estados/1 valido/8 benignos, interact cicla posicion, sin castigo (cozy), senal puzzle_sala_resuelta (2026-10-22 S27)
- [x] Definir símbolos del canon M147 (sello_brisa) [M] — 03-Diseno: simbolo_del_sello_brisa (viento_primeros_jardineros) como grabado de la ruina + motivo del altar; cero simbolos nuevos (2026-10-22)
- [x] Definir recompensa: Hacha de Finneas + mensaje cozy [M] — 03-Diseno: hacha_finneas 30 usos desbloquea arboleda (pacing 20-30 min) + placa "Quien guarda el viento guarda la mano que tala. - F." (2026-10-22 S27; grafo v2 con node recompensa_cozy queda anotado, no bloquea)
- [ ] Definir test de combinatoria de palancas (todas las secuencias) [C]

## F. Casa y Autosave (RF4/RF9)

- [ ] Definir casa con entrada, cama y mesa [S]
- [ ] Definir dormir: fade a negro + pasar el día [M]
- [ ] Definir autosave al dormir [M]
- [ ] Definir autosave en hitos (entrega, puzzle resuelto) [M]
- [ ] Definir save v2 con schema_version (M60) [M]

## G. Música (RF6)

- [ ] Definir tema diurno y nocturno de Aurora (2 stems) [C]
- [ ] Definir transición suave al dormir [M]
- [ ] Definir que la música use AudioStreamPlayer separado (M41) [S]
- [ ] Definir volumen equilibrado con SFX (M44) [S]
- [ ] Definir música sin copyright conflictivo (M84 Chequeado) [S]

## H. Sonidos (RF7)

- [ ] Definir SFX de extracción y colocación [M]
- [ ] Definir SFX de swing y moneda [S]
- [ ] Definir SFX de puerta y puzzle [S]
- [ ] Definir ambiente: viento, mar, pájaros (M42) [M]
- [ ] Definir mezcla con AudioMixer y buses (M42) [M]

## I. UI Funcional (RF8)

- [ ] Definir IV inventario (1 fila visible) [S]
- [ ] Definir caja de diálogo tipográfica (M88) [S]
- [ ] Definir indicador de interactivo sobre el objetivo [S]
- [ ] Definir menú de pausa básico (continuar, salir, ajustes mínimos) [S]
- [ ] Definir UI sin acoplar gameplay (M07) [M]

## J. VFX (RF10)

- [ ] Definir VFX de extracción (fragmentos) [M]
- [ ] Definir VFX de colocación (polvo) [M]
- [ ] Definir VFX de recompensa (chispas nobles) [M]
- [ ] Definir VFX de dormir (humo suave) [S]
- [x] Definir VFX dentro del budget partículas (M61: 1.0ms) [M]
  · evidencia: 03-Diseno.md secc. Mediciones de render (P-100, Reflection-Beam-1.0, T67, 2026-10-22)

## K. Animaciones (RF11)

- [ ] Definir animación de caminar del jugador [M]
- [ ] Definir animación de uso del Hacha [M]
- [ ] Definir animación idle/hablar de Finneas [M]
- [ ] Definir animación de puertas [S]
- [ ] Definir blend entre animaciones sin snap (M48) [C]

## L. Tutorial Visual (RF13)

- [ ] Definir guiado visual sin texto (flechas + resaltado) [M]
- [ ] Definir resaltado del faro y del NPC al inicio [S]
- [ ] Definir ocultamiento del guiado tras la primera acción [S]
- [ ] Definir opción de desactivar el guiado (accesibilidad M58) [S]
- [ ] Definir test: tester nuevo completa el slice sin instrucciones [C]

## M. Guardado Full (RF9)

- [ ] Definir serialización completa de la zona (chunks modificados) [C]
- [ ] Definir serialización de NPC (posición + estado de misión) [M]
- [ ] Definir serialización de puzzle (flags) [S]
- [ ] Definir validación de schema_version con migración futura [M]
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
- [ ] Definir umbral de guardado: 0 pérdidas [S]
- [ ] Definir que el GONOGO lo firme el usuario (dueño del proyecto) [S]

## R. Congelación de Alcance

- [ ] Definir `IDEAS-DESCARTADAS.md` para lo que no entra [S]
- [ ] Definir regla: nada nuevo sin pasar por el documento [S]
- [ ] Definir revisión semanal de alcance contra RF1-RF17 [M]
- [ ] Definir que el creep de scope bloquee el GONOGO [M]
- [ ] Definir que el alcance del slice sea 100% reproducible [S]

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
- [ ] Definir convenciones de nombres (`*_vs.gd`, `vslice_*`) [S]
- [ ] Definir que la deuda técnica se registre sin silenciarla [S]

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
**Totales:** 131 ítems · Completados: 36 · Pendientes: 95 · No resueltos: 0.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> Sincronizado 2026-10-22 (G-5.3-Flash-Agente, S24): conteo real de marcas 29 [x] / 102 [ ] / 0 [?] — el acumulado arrastraba el corte del 2026-08 (11/120).
> Las marcas no se tocaron.

> **Saneo de cabecera (Hy3 / WorkBuddy, 2026-10-08):** L6 `Estado: 130/130` corregido a `11/131 completados.` (drift S-02, canal 89 de atria). Solo la cabecera; el cuerpo de marcas no se tocó. M138 queda 🟢 (documental, sin claims falsos ni entregables ausentes).
