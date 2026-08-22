**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 138: Vertical Slice (130 ítems)

**Estado:** 130/130 completados. [S]=Simple [M]=Medio [C]=Complejo. Fuentes: plan maestro sección 137 (18 ítems) + Plan-de-produccion.md + M61/M152/M153.

## A. Zona del Slice (RF1)

- [x] Definir esquina de Aurora como zona del slice [M]
- [x] Definir geografía: playa, bosque, prado, costa [M]
- [x] Definir 3-5 puntos de interés (casa, ruina, muelle roto, arboleda, altar) [M]
- [x] Definir vegetación con MultiMesh (M50, sin rebalsar draw calls) [C]
- [x] Definir iluminación de la zona dentro del budget render (M49/M61) [C]

## B. Recurso y Herramienta (RF3)

- [x] Definir madera como recurso clave del slice [S]
- [x] Definir árbol con 5 bloques de madera [S]
- [x] Definir Hacha con 15 usos de durabilidad [S]
- [x] Definir animación de swing del Hacha (M48) [M]
- [x] Definir SFX de impacto y VFX de virutas (M43/M52) [M]

## C. Finneas (RF2)

- [x] Definir NPC Finneas con rutina de día por waypoints [M]
- [x] Definir 6+ líneas de diálogo con rama de misión (M21) [M]
- [x] Definir consumo de canon M147 para nombre e histórico [M]
- [x] Definir regalo de bienvenida conceptual (M20 futuro) [S]
- [x] Definir que Finneas no atraviese paredes en sus waypoints [M]

## D. Misión y Recompensa (RF12)

- [x] Definir misión de 3 pasos (madera → hacha en ruina → entrega) [M]
- [x] Definir recompensa: 20 AO + semilla de jardín [M]
- [x] Definir margen de recompensa según M93 (5-15%) [M]
- [x] Definir UX de misión: indicador de objetivo (M53) [S]
- [x] Definir test: la misión no se rompe si se entrega la madera antes del diálogo [M]

## E. Ruina y Puzzle (RF5)

- [x] Definir ruina de 3 salas [M]
- [x] Definir puzzle de 2 palancas + alineación de símbolos (M24) [M]
- [x] Definir símbolos del canon M147 (sello_brisa) [M]
- [x] Definir recompensa: Hacha de Finneas + mensaje cozy [M]
- [x] Definir test de combinatoria de palancas (todas las secuencias) [C]

## F. Casa y Autosave (RF4/RF9)

- [x] Definir casa con entrada, cama y mesa [S]
- [x] Definir dormir: fade a negro + pasar el día [M]
- [x] Definir autosave al dormir [M]
- [x] Definir autosave en hitos (entrega, puzzle resuelto) [M]
- [x] Definir save v2 con schema_version (M60) [M]

## G. Música (RF6)

- [x] Definir tema diurno y nocturno de Aurora (2 stems) [C]
- [x] Definir transición suave al dormir [M]
- [x] Definir que la música use AudioStreamPlayer separado (M41) [S]
- [x] Definir volumen equilibrado con SFX (M44) [S]
- [x] Definir música sin copyright conflictivo (M84 Chequeado) [S]

## H. Sonidos (RF7)

- [x] Definir SFX de extracción y colocación [M]
- [x] Definir SFX de swing y moneda [S]
- [x] Definir SFX de puerta y puzzle [S]
- [x] Definir ambiente: viento, mar, pájaros (M42) [M]
- [x] Definir mezcla con AudioMixer y buses (M42) [M]

## I. UI Funcional (RF8)

- [x] Definir IV inventario (1 fila visible) [S]
- [x] Definir caja de diálogo tipográfica (M88) [S]
- [x] Definir indicador de interactivo sobre el objetivo [S]
- [x] Definir menú de pausa básico (continuar, salir, ajustes mínimos) [S]
- [x] Definir UI sin acoplar gameplay (M07) [M]

## J. VFX (RF10)

- [x] Definir VFX de extracción (fragmentos) [M]
- [x] Definir VFX de colocación (polvo) [M]
- [x] Definir VFX de recompensa (chispas nobles) [M]
- [x] Definir VFX de dormir (humo suave) [S]
- [x] Definir VFX dentro del budget partículas (M61: 1.0ms) [M]

## K. Animaciones (RF11)

- [x] Definir animación de caminar del jugador [M]
- [x] Definir animación de uso del Hacha [M]
- [x] Definir animación idle/hablar de Finneas [M]
- [x] Definir animación de puertas [S]
- [x] Definir blend entre animaciones sin snap (M48) [C]

## L. Tutorial Visual (RF13)

- [x] Definir guiado visual sin texto (flechas + resaltado) [M]
- [x] Definir resaltado del faro y del NPC al inicio [S]
- [x] Definir ocultamiento del guiado tras la primera acción [S]
- [x] Definir opción de desactivar el guiado (accesibilidad M58) [S]
- [x] Definir test: tester nuevo completa el slice sin instrucciones [C]

## M. Guardado Full (RF9)

- [x] Definir serialización completa de la zona (chunks modificados) [C]
- [x] Definir serialización de NPC (posición + estado de misión) [M]
- [x] Definir serialización de puzzle (flags) [S]
- [x] Definir validación de schema_version con migración futura [M]
- [x] Definir test de 10 ciclos guardar→cargar con 0 pérdidas [C]

## N. Rendimiento (RF15)

- [x] Definir perfil M61: gameplay 2.5 / voxel 4.0 / IA 2.0 / partículas 1.0 / culling 0.5 / render 5.0 / UI 1.5 [M]
- [x] Definir medición P99 (máximo frame) además de FPS medio [M]
- [x] Definir muestreo con VSYNC off [S]
- [x] Definir punto denso de prueba (bosque + lluvia + Finneas) [M]
- [x] Definir reporte `REPORTE-FPS.md` generado por `bench_slice.gd` [C]

## O. Experiencia Completa (RF14)

- [x] Definir loop de 20-30 min de principio a fin [M]
- [x] Definir créditos de demo al final del slice [S]
- [x] Definir encuesta post-slice (5+ testers) [M]
- [x] Definir que el 90% de testers termine el slice [M]
- [x] Definir que el 90% identifique el juego como "cozy/hechizante" [M]

## P. Playtest (RF16)

- [x] Definir mínimo 5 testers (3 nuevos al juego) [M]
- [x] Definir sesión de 40 min máx por tester [S]
- [x] Definir observación de momentos de aburrimiento/frustración [M]
- [x] Definir registro de bugs por tester [S]
- [x] Definir análisis de encuesta en `PLAYTEST.md` [M]

## Q. Decisión de Escala a Pre-Alpha (RFCierre)

- [x] Definir GONOGO con 7 criterios (completo, identificación, diversión, FPS, guardado, deuda, alcance) [M]
- [x] Definir umbral de diversión ≥ 7,5/10 [S]
- [x] Definir umbral de FPS ≥ 60 y P99 ≤ 40 ms [M]
- [x] Definir umbral de guardado: 0 pérdidas [S]
- [x] Definir que el GONOGO lo firme el usuario (dueño del proyecto) [S]

## R. Congelación de Alcance

- [x] Definir `IDEAS-DESCARTADAS.md` para lo que no entra [S]
- [x] Definir regla: nada nuevo sin pasar por el documento [S]
- [x] Definir revisión semanal de alcance contra RF1-RF17 [M]
- [x] Definir que el creep de scope bloquee el GONOGO [M]
- [x] Definir que el alcance del slice sea 100% reproducible [S]

## S. Integración de Sistemas

- [x] Definir integración jugador+voxel desde el prototipo (M137) [M]
- [x] Definir integración NPC+diálogo+misón [M]
- [x] Definir integración audio+acción (SFX en eventos) [M]
- [x] Definir integración VFX+acción [M]
- [x] Definir integración autosave en todos los hitos [M]

## T. Arquitectura y Modularidad (M07)

- [x] Definir que el slice use autoloads centrales (game_state_vs, save_v2, audio_manager) [M]
- [x] Definir separación de scripts UI / gameplay [M]
- [x] Definir que los sistemas del slice sean enmarcables al juego completo [C]
- [x] Definir convenciones de nombres (`*_vs.gd`, `vslice_*`) [S]
- [x] Definir que la deuda técnica se registre sin silenciarla [S]

## U. Pipeline de Assets (M108/M46/M47)

- [x] Definir que los modelos del slice pasen el pipeline estándar [M]
- [x] Definir texturas con los tamaños del preset (M47) [M]
- [x] Definir animaciones importadas con el formato del proyecto [M]
- [x] Definir audio importado con compresión del proyecto [M]
- [x] Definir que los VFX usen el pool de materiales (M47) [S]

## V. Feedback de la Dema (feedback externo)

- [x] Definir demo interna (Steam/itch/build M116) [M]
- [x] Definir guía de feedback para testers externos [S]
- [x] Definir registro de primeras reacciones (video) [S]
- [x] Definir recolectar métricas opcionales de la demo (M105 esbozo) [M]
- [x] Definir que el feedback externo alimente GONOGO-M139 [M]

## W. Edge Cases

- [x] Definir tester que nunca jugó voxel (¿el guiado basta?) [C]
- [x] Definir save con zona a medio modificar [M]
- [x] Definir dormir con el puzzle sin resolver (flags) [S]
- [x] Definir Finneas repetiendo líneas tras la misión (flags M21) [M]
- [x] Definir recompensa que no rompe la economía de prueba (M93) [M]

## X. Calidad de Código (M111)

- [x] Definir que los scripts pasen análisis estático [M]
- [x] Definir const/export para valores repetidos [S]
- [x] Definir comentarios XML de clases públicas [S]
- [x] Definir sin warnings de GDScript en el slice [M]
- [x] Definir revisión de código del slice (code review M111) [M]

## Y. Documentación del Slice

- [x] Definir `docs/vslice/` con PLAYTEST, REPORTE-FPS, GONOGO-M139, IDEAS-DESCARTADAS [S]
- [x] Definir actualización del 04-Codigo.md del módulo tras implementar [M]
- [x] Definir actualización de CHECKLIST-GLOBAL al cerrar [S]
- [x] Definir log de cierre del hito en Logs/ [S]
- [x] Definir firma de cierre por todos los agentes que intervinieron [S]

## Z. Cierre y Transición a Pre-Alpha (M139)

- [x] Definir tag git `vslice-v1` [S]
- [x] Definir empaquetado de la demo (M116/M117) [M]
- [x] Definir actualización del presupuesto con datos reales (M134) [M]
- [x] Definir lista de sistemas a escalar en Pre-Alpha (M139) [M]
- [x] Definir comunicar al usuario la decisión y próximo hito [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
