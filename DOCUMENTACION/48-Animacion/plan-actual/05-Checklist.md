**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 48: Animación

## A. Problema y objetivos

- [x] Definir el problema: sin sistema de animación los actores se ven robóticos o sin animación [S]
- [x] Definir el objetivo: kit de animación central con producción coherente, FSM espejo y presupuesto verificado [S]
- [x] Registrar dependencias: M45 (rigs), M11/M19/M36 (FSM), M64/M65 (IA), M04 (Godot), M61/M62 (presupuestos), M43/M44/M52 (eventos) [M]
- [x] Mapear la sección 47 "ANIMACIÓN" del plan maestro al ID 48 de la tabla global [M]
- [x] Separar dentro/fuera de alcance: rigs → M45, FSM de comportamiento → M11/M64/M65, VFX → M52, sonido → M43 [S]
- [x] Documentar restricciones: Godot 4.x, FPS 30 base (UI 60), determinismo de mundo, sin RNG, sincronía en timelines [M]
- [x] Definir criterios de aceptación verificables (8 criterios) [S]
- [x] Incluir contexto del plan de producción §4 (rigs por familia, coherencia) [M]

## B. RF1 — Flujo de producción

- [x] Definir pipeline: rig (M45) → blocking → polish → export 30 fps [M]
- [x] Definir convenciones de exportación: FBX, T-pose única, bones subset por familia [M]
- [x] Definir familias de rigs: humanoide, cuadrúpedo, ave, pez [M]
- [x] Definir plantilla de import en editor (import_animation_defaults.gd) [M]
- [x] Definir máximos de duración por categoría [S]

## C. RF2 — Kit de animación del jugador

- [x] Cubrir los 10 estados de la FSM de M11 con animaciones [M]
- [x] Idle, caminar, correr del jugador [S]
- [x] Saltar, nadar, escalar del jugador [M]
- [x] Extraer, colocar, minar, pescar del jugador [M]
- [x] Cosecha, regado, diálogo, dormir del jugador [M]
- [x] Definir blend space 2D de locomoción (dirección × velocidad) [M]
- [x] Definir sockets de herramientas (grip) con M45 [M]

## D. RF3 — Animaciones de NPC y vecinos

- [x] Idle y caminata de NPC (M19) [S]
- [x] Rutinas de trabajo de NPC (M64) [M]
- [x] Conversación y gestos de amistad (M20) [M]
- [x] Animaciones festivas (M74) [M]
- [x] Definir variantes por personalidad (≤3 por gesto) [M]

## E. RF4 — Animaciones de fauna

- [x] Estados de M36/M65: idle, pastorear, huir, volar, nadar, dormir [M]
- [x] Variantes de fase en manadas/bancos (fases escalonadas) [M]
- [x] Definir LOD de animación de fauna (distancia) [M]

## F. RF5 — Animaciones de herramientas

- [x] 9 herramientas × 4 niveles con animación de uso [M]
- [x] Swing de minado/pico con eventos de impacto [M]
- [x] Plantación, regado y cosecha [M]
- [x] Pesca: lanzar, espera, tensión, cobro [M]
- [x] Martillo y lupa (mecánicas infinitas) [M]

## G. RF6 — Animaciones de mecánicas

- [x] Puertas: abrir/cerrar con easing [S]
- [x] Puentes: bajar/subir [M]
- [x] Mecanismos: activar/desactivar [M]
- [x] Ascensores: subir/bajar con easing [M]
- [x] Construcción: colocar/levantar piezas (M17) [M]
- [x] Puzzles: mover piezas, activación (M24) [M]

## H. RF7 — Animaciones de vehículos

- [x] Barcos: balanceo en agua, atraque (M28/M67) [M]
- [x] Dirigibles: ascender/descender, balanceo [M]
- [x] Submarinos: sumergir/emergir [M]

## I. RF8 — Animaciones de mundo

- [x] Vegetación: viento procedural determinista (M50) [M]
- [x] Agua: ondas procedurales deterministas (M51) [M]
- [x] Fuego: procedural de partículas (M52) [M]
- [x] Sin RNG en runtime (fases fijas por TIME) [M]

## J. RF9 — Animaciones de UI

- [x] Transiciones de menú 60 fps (M53) [M]
- [x] Recompensas, contadores, sparkles (M71/M72) [M]
- [x] Descubrimientos y tooltips [M]
- [x] Diálogos: retratos, burbujas, gestos (M21/M46) [M]
- [x] Reducir movimiento con M58 (Reduce Motion) [M]
- [x] No animar UI fuera de pantalla [S]

## K. RF10 — Sincronía

- [x] Eventos de sonido embebidos en timelines (M43) [M]
- [x] Eventos de feedback ASMR en timelines (M44) [M]
- [x] Triggers de partículas en timelines (M52) [M]
- [x] Regla: el evento se emite al frame que lo produce visualmente [M]
- [x] Test de desincronía sonido/impacto [M]

## L. RF11 — Presupuesto y LOD de animación

- [x] Burbuja ≤60 actores plenos (M64) [M]
- [x] Fuera de burbuja: idle simplificado o sin animación por distancia [M]
- [x] Blend trees ≤4 nodos por actor [S]
- [x] Pooling de AnimationPlayer (M62) [M]
- [x] Keyframes optimizados sin redundancia (M61) [M]

## M. RF12 — Validación automática

- [x] Definir script validate_animation.gd [M]
- [x] Verificar naming anim_[actor]_[estado] [S]
- [x] Verificar fps 30 base / UI 60 [S]
- [x] Verificar duración dentro de máximos por categoría [S]
- [x] Verificar T-pose única y bones subset [M]
- [x] Verificar keyframes de evento requeridos [M]
- [x] Verificar coste por actor en animation_budget.json [M]

## N. RF13 — Naming y organización

- [x] Definir prefijos anim_, librerías por actor [S]
- [x] Alinear con M108 [M]

## O. RF14 — Registro de presupuesto

- [x] Definir animation_budget.json por actor/animación [C]
- [x] Definir suma por escena pivote contra presupuesto M61 [M]
- [x] Definir alerta de excedente en editor [S]

## P. RF15 — API de reproducción

- [x] Definir AnimationService con play(actor, estado, blend_time) [C]
- [x] La gameplay llama por ESTADO, no por clip [M]
- [x] Definir fallback idle ante estado sin clip (log WARN) [M]
- [x] Definir señales animation_started/finished/missing [M]
- [x] Prohibir que la capa de animación decida comportamiento [M]

## Q. Requisitos no funcionales

- [x] Rendimiento: burbuja, LOD, pooling, blend trees acotados [M]
- [x] Memoria (M62): bibliotecas compartidas, sin duplicados por escena [M]
- [x] Cozy: movimientos suaves, anticipación corta, follow-through sutil [M]
- [x] Accesible: Reduce Motion en UI (M58) [M]
- [x] Determinismo: mundo procedural sin RNG [M]
- [x] Mantenible: catálogo estado→clip único [M]

## R. Alternativas consideradas

- [x] Descartar animación embebida por escena (duplicados) [M]
- [x] Descartar animación 100% por código (calidad) [M]
- [x] Descartar AnimationPlayer global único [S]
- [x] Descartar retargeting genérico en tiempo real [M]
- [x] Descartar blend trees ilimitados [S]
- [x] Descartar animación 2D/impostores para todo el mundo [M]

## S. Riesgos y mitigaciones

- [x] Riesgo de clips duplicados → AnimationLibrary central + validación [M]
- [x] Riesgo de snaps por blending → blend 250 ms + revisión visual [M]
- [x] Riesgo de desincronía → eventos en timelines + tests [M]
- [x] Riesgo de coste de huesos → burbuja + LOD + registro [M]
- [x] Riesgo de UI molesta → Reduce Motion + duraciones cortas [M]
- [x] Riesgo de imports inconsistentes → plantilla + validador [S]

## T. Integraciones

- [x] Documentar integración con M11/M19/M36 (FSM) [S]
- [x] Documentar integración con M64/M65 (burbuja) [S]
- [x] Documentar integración con M45 (rigs/sockets) [S]
- [x] Documentar integración con M13 (herramientas) [S]
- [x] Documentar integración con M43/M44/M52 (eventos) [S]
- [x] Documentar integración con M50/M51 (procedural) [S]
- [x] Documentar integración con M21/M53/M58 (UI) [S]
- [x] Documentar integración con M61/M62 (presupuesto) [S]
- [x] Documentar integración con M74 (festivales) [S]
- [x] Documentar integración con M108/M118 (import + CI) [S]

## U. Herramientas y flujos

- [x] Documentar flujo estado→clip (AnimationService) [M]
- [x] Documentar flujo de producción de un clip [M]
- [x] Documentar flujo de validación al importar [M]
- [x] Documentar plantilla de import FBX [M]

## V. Criterios de aceptación verificados

- [x] 100% de estados FSM de actores cubiertos con animaciones [M]
- [x] Toda mecánica lista tiene animación o "intencional sin animación" definida [M]
- [x] Clips generados con un flujo único y validados sin errores [M]
- [x] Transiciones sin snaps (blend ≤250 ms) [M]
- [x] Sonido y feedback al frame correcto [M]
- [x] Coste de escena pivote dentro del presupuesto M61 [M]
- [x] Mundo determinista sin RNG visible [M]
- [x] UI respeta M58 y corre a 60 fps [M]

## W. Notas finales

- [x] Documentar el desfase de numeración del plan maestro (47=ANIMACIÓN → ID 48) [S]
- [x] Marcar el módulo como DELEGABLE PARA IMPLEMENTAR [S]
- [x] Registrar dependencia de implementación con el hito M1 (proyecto Godot) [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
