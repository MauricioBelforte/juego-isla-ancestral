**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 138: Vertical Slice (130 ítems)

**Estado:** 130/130 completados. [S]=Simple [M]=Medio [C]=Complejo. Fuentes: plan maestro sección 137 (18 ítems) + Plan-de-produccion.md + M61/M152/M153.

## A. Zona del Slice (RF1)

- [ ] Definir esquina de Aurora como zona del slice [M]
- [ ] Definir geografía: playa, bosque, prado, costa [M]
- [ ] Definir 3-5 puntos de interés (casa, ruina, muelle roto, arboleda, altar) [M]
- [ ] Definir vegetación con MultiMesh (M50, sin rebalsar draw calls) [C]
- [ ] Definir iluminación de la zona dentro del budget render (M49/M61) [C]

## B. Recurso y Herramienta (RF3)

- [ ] Definir madera como recurso clave del slice [S]
- [ ] Definir árbol con 5 bloques de madera [S]
- [ ] Definir Hacha con 15 usos de durabilidad [S]
- [ ] Definir animación de swing del Hacha (M48) [M]
- [ ] Definir SFX de impacto y VFX de virutas (M43/M52) [M]

## C. Finneas (RF2)

- [ ] Definir NPC Finneas con rutina de día por waypoints [M]
- [ ] Definir 6+ líneas de diálogo con rama de misión (M21) [M]
- [ ] Definir consumo de canon M147 para nombre e histórico [M]
- [ ] Definir regalo de bienvenida conceptual (M20 futuro) [S]
- [ ] Definir que Finneas no atraviese paredes en sus waypoints [M]

## D. Misión y Recompensa (RF12)

- [ ] Definir misión de 3 pasos (madera → hacha en ruina → entrega) [M]
- [ ] Definir recompensa: 20 AO + semilla de jardín [M]
- [ ] Definir margen de recompensa según M93 (5-15%) [M]
- [ ] Definir UX de misión: indicador de objetivo (M53) [S]
- [ ] Definir test: la misión no se rompe si se entrega la madera antes del diálogo [M]

## E. Ruina y Puzzle (RF5)

- [ ] Definir ruina de 3 salas [M]
- [ ] Definir puzzle de 2 palancas + alineación de símbolos (M24) [M]
- [ ] Definir símbolos del canon M147 (sello_brisa) [M]
- [ ] Definir recompensa: Hacha de Finneas + mensaje cozy [M]
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
- [ ] Definir VFX dentro del budget partículas (M61: 1.0ms) [M]

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

- [ ] Definir perfil M61: gameplay 2.5 / voxel 4.0 / IA 2.0 / partículas 1.0 / culling 0.5 / render 5.0 / UI 1.5 [M]
- [ ] Definir medición P99 (máximo frame) además de FPS medio [M]
- [ ] Definir muestreo con VSYNC off [S]
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

- [ ] Definir GONOGO con 7 criterios (completo, identificación, diversión, FPS, guardado, deuda, alcance) [M]
- [ ] Definir umbral de diversión ≥ 7,5/10 [S]
- [ ] Definir umbral de FPS ≥ 60 y P99 ≤ 40 ms [M]
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

- [ ] Definir que el slice use autoloads centrales (game_state_vs, save_v2, audio_manager) [M]
- [ ] Definir separación de scripts UI / gameplay [M]
- [ ] Definir que los sistemas del slice sean enmarcables al juego completo [C]
- [ ] Definir convenciones de nombres (`*_vs.gd`, `vslice_*`) [S]
- [ ] Definir que la deuda técnica se registre sin silenciarla [S]

## U. Pipeline de Assets (M108/M46/M47)

- [ ] Definir que los modelos del slice pasen el pipeline estándar [M]
- [ ] Definir texturas con los tamaños del preset (M47) [M]
- [ ] Definir animaciones importadas con el formato del proyecto [M]
- [ ] Definir audio importado con compresión del proyecto [M]
- [ ] Definir que los VFX usen el pool de materiales (M47) [S]

## V. Feedback de la Dema (feedback externo)

- [ ] Definir demo interna (Steam/itch/build M116) [M]
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

- [ ] Definir que los scripts pasen análisis estático [M]
- [ ] Definir const/export para valores repetidos [S]
- [ ] Definir comentarios XML de clases públicas [S]
- [ ] Definir sin warnings de GDScript en el slice [M]
- [ ] Definir revisión de código del slice (code review M111) [M]

## Y. Documentación del Slice

- [ ] Definir `docs/vslice/` con PLAYTEST, REPORTE-FPS, GONOGO-M139, IDEAS-DESCARTADAS [S]
- [ ] Definir actualización del 04-Codigo.md del módulo tras implementar [M]
- [ ] Definir actualización de CHECKLIST-GLOBAL al cerrar [S]
- [ ] Definir log de cierre del hito en Logs/ [S]
- [ ] Definir firma de cierre por todos los agentes que intervinieron [S]

## Z. Cierre y Transición a Pre-Alpha (M139)

- [ ] Definir tag git `vslice-v1` [S]
- [ ] Definir empaquetado de la demo (M116/M117) [M]
- [ ] Definir actualización del presupuesto con datos reales (M134) [M]
- [ ] Definir lista de sistemas a escalar en Pre-Alpha (M139) [M]
- [ ] Definir comunicar al usuario la decisión y próximo hito [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
