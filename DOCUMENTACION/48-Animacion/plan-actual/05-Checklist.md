**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 48: Animación

## A. Problema y objetivos

- [ ] Definir el problema: sin sistema de animación los actores se ven robóticos o sin animación [S]
- [ ] Definir el objetivo: kit de animación central con producción coherente, FSM espejo y presupuesto verificado [S]
- [ ] Registrar dependencias: M45 (rigs), M11/M19/M36 (FSM), M64/M65 (IA), M04 (Godot), M61/M62 (presupuestos), M43/M44/M52 (eventos) [M]
- [ ] Mapear la sección 47 "ANIMACIÓN" del plan maestro al ID 48 de la tabla global [M]
- [ ] Separar dentro/fuera de alcance: rigs → M45, FSM de comportamiento → M11/M64/M65, VFX → M52, sonido → M43 [S]
- [ ] Documentar restricciones: Godot 4.x, FPS 30 base (UI 60), determinismo de mundo, sin RNG, sincronía en timelines [M]
- [ ] Definir criterios de aceptación verificables (8 criterios) [S]
- [ ] Incluir contexto del plan de producción §4 (rigs por familia, coherencia) [M]

## B. RF1 — Flujo de producción

- [ ] Definir pipeline: rig (M45) → blocking → polish → export 30 fps [M]
- [ ] Definir convenciones de exportación: FBX, T-pose única, bones subset por familia [M]
- [ ] Definir familias de rigs: humanoide, cuadrúpedo, ave, pez [M]
- [ ] Definir plantilla de import en editor (import_animation_defaults.gd) [M]
- [ ] Definir máximos de duración por categoría [S]

## C. RF2 — Kit de animación del jugador

- [ ] Cubrir los 10 estados de la FSM de M11 con animaciones [M]
- [ ] Idle, caminar, correr del jugador [S]
- [ ] Saltar, nadar, escalar del jugador [M]
- [ ] Extraer, colocar, minar, pescar del jugador [M]
- [ ] Cosecha, regado, diálogo, dormir del jugador [M]
- [ ] Definir blend space 2D de locomoción (dirección × velocidad) [M]
- [ ] Definir sockets de herramientas (grip) con M45 [M]

## D. RF3 — Animaciones de NPC y vecinos

- [ ] Idle y caminata de NPC (M19) [S]
- [ ] Rutinas de trabajo de NPC (M64) [M]
- [ ] Conversación y gestos de amistad (M20) [M]
- [ ] Animaciones festivas (M74) [M]
- [ ] Definir variantes por personalidad (≤3 por gesto) [M]

## E. RF4 — Animaciones de fauna

- [ ] Estados de M36/M65: idle, pastorear, huir, volar, nadar, dormir [M]
- [ ] Variantes de fase en manadas/bancos (fases escalonadas) [M]
- [ ] Definir LOD de animación de fauna (distancia) [M]

## F. RF5 — Animaciones de herramientas

- [ ] 9 herramientas × 4 niveles con animación de uso [M]
- [ ] Swing de minado/pico con eventos de impacto [M]
- [ ] Plantación, regado y cosecha [M]
- [ ] Pesca: lanzar, espera, tensión, cobro [M]
- [ ] Martillo y lupa (mecánicas infinitas) [M]

## G. RF6 — Animaciones de mecánicas

- [ ] Puertas: abrir/cerrar con easing [S]
- [ ] Puentes: bajar/subir [M]
- [ ] Mecanismos: activar/desactivar [M]
- [ ] Ascensores: subir/bajar con easing [M]
- [ ] Construcción: colocar/levantar piezas (M17) [M]
- [ ] Puzzles: mover piezas, activación (M24) [M]

## H. RF7 — Animaciones de vehículos

- [ ] Barcos: balanceo en agua, atraque (M28/M67) [M]
- [ ] Dirigibles: ascender/descender, balanceo [M]
- [ ] Submarinos: sumergir/emergir [M]

## I. RF8 — Animaciones de mundo

- [ ] Vegetación: viento procedural determinista (M50) [M]
- [ ] Agua: ondas procedurales deterministas (M51) [M]
- [ ] Fuego: procedural de partículas (M52) [M]
- [ ] Sin RNG en runtime (fases fijas por TIME) [M]

## J. RF9 — Animaciones de UI

- [ ] Transiciones de menú 60 fps (M53) [M]
- [ ] Recompensas, contadores, sparkles (M71/M72) [M]
- [ ] Descubrimientos y tooltips [M]
- [ ] Diálogos: retratos, burbujas, gestos (M21/M46) [M]
- [ ] Reducir movimiento con M58 (Reduce Motion) [M]
- [ ] No animar UI fuera de pantalla [S]

## K. RF10 — Sincronía

- [ ] Eventos de sonido embebidos en timelines (M43) [M]
- [ ] Eventos de feedback ASMR en timelines (M44) [M]
- [ ] Triggers de partículas en timelines (M52) [M]
- [ ] Regla: el evento se emite al frame que lo produce visualmente [M]
- [ ] Test de desincronía sonido/impacto [M]

## L. RF11 — Presupuesto y LOD de animación

- [ ] Burbuja ≤60 actores plenos (M64) [M]
- [ ] Fuera de burbuja: idle simplificado o sin animación por distancia [M]
- [ ] Blend trees ≤4 nodos por actor [S]
- [ ] Pooling de AnimationPlayer (M62) [M]
- [ ] Keyframes optimizados sin redundancia (M61) [M]

## M. RF12 — Validación automática

- [ ] Definir script validate_animation.gd [M]
- [ ] Verificar naming anim_[actor]_[estado] [S]
- [ ] Verificar fps 30 base / UI 60 [S]
- [ ] Verificar duración dentro de máximos por categoría [S]
- [ ] Verificar T-pose única y bones subset [M]
- [ ] Verificar keyframes de evento requeridos [M]
- [ ] Verificar coste por actor en animation_budget.json [M]

## N. RF13 — Naming y organización

- [ ] Definir prefijos anim_, librerías por actor [S]
- [ ] Alinear con M108 [M]

## O. RF14 — Registro de presupuesto

- [ ] Definir animation_budget.json por actor/animación [C]
- [ ] Definir suma por escena pivote contra presupuesto M61 [M]
- [ ] Definir alerta de excedente en editor [S]

## P. RF15 — API de reproducción

- [ ] Definir AnimationService con play(actor, estado, blend_time) [C]
- [ ] La gameplay llama por ESTADO, no por clip [M]
- [ ] Definir fallback idle ante estado sin clip (log WARN) [M]
- [ ] Definir señales animation_started/finished/missing [M]
- [ ] Prohibir que la capa de animación decida comportamiento [M]

## Q. Requisitos no funcionales

- [ ] Rendimiento: burbuja, LOD, pooling, blend trees acotados [M]
- [ ] Memoria (M62): bibliotecas compartidas, sin duplicados por escena [M]
- [ ] Cozy: movimientos suaves, anticipación corta, follow-through sutil [M]
- [ ] Accesible: Reduce Motion en UI (M58) [M]
- [ ] Determinismo: mundo procedural sin RNG [M]
- [ ] Mantenible: catálogo estado→clip único [M]

## R. Alternativas consideradas

- [ ] Descartar animación embebida por escena (duplicados) [M]
- [ ] Descartar animación 100% por código (calidad) [M]
- [ ] Descartar AnimationPlayer global único [S]
- [ ] Descartar retargeting genérico en tiempo real [M]
- [ ] Descartar blend trees ilimitados [S]
- [ ] Descartar animación 2D/impostores para todo el mundo [M]

## S. Riesgos y mitigaciones

- [ ] Riesgo de clips duplicados → AnimationLibrary central + validación [M]
- [ ] Riesgo de snaps por blending → blend 250 ms + revisión visual [M]
- [ ] Riesgo de desincronía → eventos en timelines + tests [M]
- [ ] Riesgo de coste de huesos → burbuja + LOD + registro [M]
- [ ] Riesgo de UI molesta → Reduce Motion + duraciones cortas [M]
- [ ] Riesgo de imports inconsistentes → plantilla + validador [S]

## T. Integraciones

- [ ] Documentar integración con M11/M19/M36 (FSM) [S]
- [ ] Documentar integración con M64/M65 (burbuja) [S]
- [ ] Documentar integración con M45 (rigs/sockets) [S]
- [ ] Documentar integración con M13 (herramientas) [S]
- [ ] Documentar integración con M43/M44/M52 (eventos) [S]
- [ ] Documentar integración con M50/M51 (procedural) [S]
- [ ] Documentar integración con M21/M53/M58 (UI) [S]
- [ ] Documentar integración con M61/M62 (presupuesto) [S]
- [ ] Documentar integración con M74 (festivales) [S]
- [ ] Documentar integración con M108/M118 (import + CI) [S]

## U. Herramientas y flujos

- [ ] Documentar flujo estado→clip (AnimationService) [M]
- [ ] Documentar flujo de producción de un clip [M]
- [ ] Documentar flujo de validación al importar [M]
- [ ] Documentar plantilla de import FBX [M]

## V. Criterios de aceptación verificados

- [ ] 100% de estados FSM de actores cubiertos con animaciones [M]
- [ ] Toda mecánica lista tiene animación o "intencional sin animación" definida [M]
- [ ] Clips generados con un flujo único y validados sin errores [M]
- [ ] Transiciones sin snaps (blend ≤250 ms) [M]
- [ ] Sonido y feedback al frame correcto [M]
- [ ] Coste de escena pivote dentro del presupuesto M61 [M]
- [ ] Mundo determinista sin RNG visible [M]
- [ ] UI respeta M58 y corre a 60 fps [M]

## W. Notas finales

- [ ] Documentar el desfase de numeración del plan maestro (47=ANIMACIÓN → ID 48) [S]
- [ ] Marcar el módulo como DELEGABLE PARA IMPLEMENTAR [S]
- [ ] Registrar dependencia de implementación con el hito M1 (proyecto Godot) [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
