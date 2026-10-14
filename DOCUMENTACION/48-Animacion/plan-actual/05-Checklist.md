**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 48: Animación

## A. Problema y objetivos

- [x] Definir el problema: sin sistema de animación los actores se ven robóticos o sin animación [S]
- [ ] Definir el objetivo: kit de animación central con producción coherente, FSM espejo y presupuesto verificado [S]
  · espera: pendiente de definicion de diseno (contrato del item) (marcado [S])
- [ ] Registrar dependencias: M45 (rigs), M11/M19/M36 (FSM), M64/M65 (IA), M04 (Godot), M61/M62 (presupuestos), M43/M44/M52 (eventos) [M]
  · espera: depende de M4/M11/M19/M36/M43/M44/M45/M52/M61/M62/M64/M65 (coordinar con su dueno)
- [ ] Mapear la sección 47 "ANIMACIÓN" del plan maestro al ID 48 de la tabla global [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Separar dentro/fuera de alcance: rigs → M45, FSM de comportamiento → M11/M64/M65, VFX → M52, sonido → M43 [S]
  · espera: depende de M11/M43/M45/M52/M64/M65 (coordinar con su dueno)
- [ ] Documentar restricciones: Godot 4.x, FPS 30 base (UI 60), determinismo de mundo, sin RNG, sincronía en timelines [M]
  · espera: pendiente de documentacion (marcado [M])
- [ ] Definir criterios de aceptación verificables (8 criterios) [S]
  · espera: pendiente de definicion de diseno (contrato del item) (marcado [S])
- [ ] Incluir contexto del plan de producción §4 (rigs por familia, coherencia) [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])

## B. RF1 — Flujo de producción

- [ ] Definir pipeline: rig (M45) → blocking → polish → export 30 fps [M]
  · espera: depende de M45 (coordinar con su dueno)
- [ ] Definir convenciones de exportación: FBX, T-pose única, bones subset por familia [M]
  · espera: pendiente de definicion de diseno (contrato del item) (marcado [M])
- [ ] Definir familias de rigs: humanoide, cuadrúpedo, ave, pez [M]
  · espera: pendiente de definicion de diseno (contrato del item) (marcado [M])
- [ ] Definir plantilla de import en editor (import_animation_defaults.gd) [M]
  · espera: pendiente de definicion de diseno (contrato del item) (marcado [M])
- [ ] Definir máximos de duración por categoría [S]
  · espera: pendiente de definicion de diseno (contrato del item) (marcado [S])

## C. RF2 — Kit de animación del jugador

- [ ] Cubrir los 11 estados de la FSM de M11 con animaciones (idle, caminar, correr, saltar, caer, nadar, bucear, salir a superficie, interactuar, dormir, fabricar — verificado contra `scripts/player/player_fsm.gd` L26-L36; el texto previo decía "10 estados" y listaba estados inexistentes) [M]
  · espera: depende de M11 (coordinar con su dueno)
- [x] Idle, caminar, correr del jugador  [S] -> IMPLEMENTADO Fase 1 Step 5 (Log 1603): jugador_lib.tres 3 clips placeholder; test 12/0
- [ ] Saltar, nadar, escalar del jugador [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Extraer, colocar, minar, pescar del jugador [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Cosecha, regado, diálogo, dormir del jugador [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Definir blend space 2D de locomoción (dirección × velocidad) [M]
  · espera: pendiente de definicion de diseno (contrato del item) (marcado [M])
- [ ] Definir sockets de herramientas (grip) con M45 [M]
  · espera: depende de M45 (coordinar con su dueno)

## D. RF3 — Animaciones de NPC y vecinos

- [ ] Idle y caminata de NPC (M19) [S]
  · espera: depende de M19 (coordinar con su dueno)
- [ ] Rutinas de trabajo de NPC (M64) [M]
  · espera: depende de M64 (coordinar con su dueno)
- [ ] Conversación y gestos de amistad (M20) [M]
  · espera: depende de M20 (coordinar con su dueno)
- [ ] Animaciones festivas (M74) [M]
  · espera: depende de M74 (coordinar con su dueno)
- [ ] Definir variantes por personalidad (≤3 por gesto) [M]
  · espera: pendiente de definicion de diseno (contrato del item) (marcado [M])

## E. RF4 — Animaciones de fauna

- [ ] Estados de M36/M65: idle, pastorear, huir, volar, nadar, dormir [M]
  · espera: depende de M36/M65 (coordinar con su dueno)
- [ ] Variantes de fase en manadas/bancos (fases escalonadas) [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Definir LOD de animación de fauna (distancia) [M]
  · espera: pendiente de definicion de diseno (contrato del item) (marcado [M])

## F. RF5 — Animaciones de herramientas

- [ ] 9 herramientas × 4 niveles con animación de uso [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Swing de minado/pico con eventos de impacto [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Plantación, regado y cosecha [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Pesca: lanzar, espera, tensión, cobro [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Martillo y lupa (mecánicas infinitas) [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])

## G. RF6 — Animaciones de mecánicas

- [ ] Puertas: abrir/cerrar con easing [S]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [S])
- [ ] Puentes: bajar/subir [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Mecanismos: activar/desactivar [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Ascensores: subir/bajar con easing [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Construcción: colocar/levantar piezas (M17) [M]
  · espera: depende de M17 (coordinar con su dueno)
- [ ] Puzzles: mover piezas, activación (M24) [M]
  · espera: depende de M24 (coordinar con su dueno)

## H. RF7 — Animaciones de vehículos

- [ ] Barcos: balanceo en agua, atraque (M28/M67) [M]
  · espera: depende de M28/M67 (coordinar con su dueno)
- [ ] Dirigibles: ascender/descender, balanceo [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Submarinos: sumergir/emergir [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])

## I. RF8 — Animaciones de mundo

- [ ] Vegetación: viento procedural determinista (M50) [M]
  · espera: depende de M50 (coordinar con su dueno)
- [ ] Agua: ondas procedurales deterministas (M51) [M]
  · espera: depende de M51 (coordinar con su dueno)
- [ ] Fuego: procedural de partículas (M52) [M]
  · espera: depende de M52 (coordinar con su dueno)
- [ ] Sin RNG en runtime (fases fijas por TIME) [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])

## J. RF9 — Animaciones de UI

- [ ] Transiciones de menú 60 fps (M53) [M]
  · espera: depende de M53 (coordinar con su dueno)
- [ ] Recompensas, contadores, sparkles (M71/M72) [M]
  · espera: depende de M71/M72 (coordinar con su dueno)
- [ ] Descubrimientos y tooltips [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Diálogos: retratos, burbujas, gestos (M21/M46) [M]
  · espera: depende de M21/M46 (coordinar con su dueno)
- [ ] Reducir movimiento con M58 (Reduce Motion) [M]
  · espera: depende de M58 (coordinar con su dueno)
- [ ] No animar UI fuera de pantalla [S]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [S])

## K. RF10 — Sincronía

- [ ] Eventos de sonido embebidos en timelines (M43) [M]
  · espera: depende de M43 (coordinar con su dueno)
- [ ] Eventos de feedback ASMR en timelines (M44) [M]
  · espera: depende de M44 (coordinar con su dueno)
- [ ] Triggers de partículas en timelines (M52) [M]
  · espera: depende de M52 (coordinar con su dueno)
- [ ] Regla: el evento se emite al frame que lo produce visualmente [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Test de desincronía sonido/impacto [M]
  · espera: pendiente de verificacion/QA (criterio del item) (marcado [M])

## L. RF11 — Presupuesto y LOD de animación

- [x] Burbuja ≤60 actores plenos (M64) [M] → **agnes-3-flash (2026-10-14): `03-Diseno.md` §3.2 "Burbuja de animación plena: ≤ 60 actores (M64)".**
  · espera: depende de M64 (coordinar con su dueno)
- [x] Fuera de burbuja: idle simplificado o sin animación por distancia [M] → **agnes-3-flash (2026-10-14): `03-Diseno.md` §3.2 "Fuera de burbuja: idle simplificado (2-4 huesos) o sin animación".**
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [x] Blend trees ≤4 nodos por actor [S] → **agnes-3-flash (2026-10-14): `03-Diseno.md` §3.2 "Blend trees: ≤ 4 nodos por actor".**
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [S])
- [x] Pooling de AnimationPlayer (M62) [M] → **agnes-3-flash (2026-10-14): `03-Diseno.md` §3.2 "Todos los AnimationPlayer en pooling".**
  · espera: depende de M62 (coordinar con su dueno)
- [ ] Keyframes optimizados sin redundancia (M61) [M]
  · espera: depende de M61 (coordinar con su dueno)

## M. RF12 — Validación automática

- [?] Definir script validate_animation.gd [M]
- [ ] Verificar naming anim_[actor]_[estado] [S]
  · espera: pendiente de verificacion/QA (criterio del item) (marcado [S])
- [ ] Verificar fps 30 base / UI 60 [S]
  · espera: pendiente de verificacion/QA (criterio del item) (marcado [S])
- [ ] Verificar duración dentro de máximos por categoría [S]
  · espera: pendiente de verificacion/QA (criterio del item) (marcado [S])
- [ ] Verificar T-pose única y bones subset [M]
  · espera: pendiente de verificacion/QA (criterio del item) (marcado [M])
- [ ] Verificar keyframes de evento requeridos [M]
  · espera: pendiente de verificacion/QA (criterio del item) (marcado [M])
- [?] Verificar coste por actor en animation_budget.json [M]

## N. RF13 — Naming y organización

- [ ] Definir prefijos anim_, librerías por actor [S]
  · espera: pendiente de definicion de diseno (contrato del item) (marcado [S])
- [ ] Alinear con M108 [M]
  · espera: depende de M108 (coordinar con su dueno)

## O. RF14 — Registro de presupuesto

- [?] Definir animation_budget.json por actor/animación [C]
- [ ] Definir suma por escena pivote contra presupuesto M61 [M]
  · espera: depende de M61 (coordinar con su dueno)
- [ ] Definir alerta de excedente en editor [S]
  · espera: pendiente de definicion de diseno (contrato del item) (marcado [S])

## P. RF15 — API de reproducción

- [x] Definir AnimationService con play(actor, estado, blend_time) [C]
- [x] La gameplay llama por ESTADO, no por clip  [M] -> IMPLEMENTADO: animation_service.play(actor, estado, blend_time); animacion_jugador_m48.gd hace polling de la FSM por estado
- [x] Definir fallback idle ante estado sin clip (log WARN)  [M] -> IMPLEMENTADO: signal animation_missing + fallback a idle documentado; probado en test_animacion_play_m48 bloque 2
- [ ] Definir señales animation_started/finished/missing [M]
  · espera: pendiente de definicion de diseno (contrato del item) (marcado [M])
- [ ] Prohibir que la capa de animación decida comportamiento [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])

## Q. Requisitos no funcionales

- [ ] Rendimiento: burbuja, LOD, pooling, blend trees acotados [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Memoria (M62): bibliotecas compartidas, sin duplicados por escena [M]
  · espera: depende de M62 (coordinar con su dueno)
- [ ] Cozy: movimientos suaves, anticipación corta, follow-through sutil [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Accesible: Reduce Motion en UI (M58) [M]
  · espera: depende de M58 (coordinar con su dueno)
- [ ] Determinismo: mundo procedural sin RNG [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Mantenible: catálogo estado→clip único [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])

## R. Alternativas consideradas

- [x] Descartar animación embebida por escena (duplicados) [M] → **agnes-3-flash (2026-10-14): `02-Analisis.md` §2 "Importar FBX con animación embebida por escena: Descartado — Duplica clips".**
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [x] Descartar animación 100% por código (calidad) [M] → **agnes-3-flash (2026-10-14): `02-Analisis.md` §2 "Animación 100% por código: Descartado — Clips de animador dan mejor calidad".**
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [x] Descartar AnimationPlayer global único [S] → **agnes-3-flash (2026-10-14): `02-Analisis.md` §2 "Un AnimationPlayer global del mundo: Descartado — Costo y acoplamiento".**
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [S])
- [x] Descartar retargeting genérico en tiempo real [M] → **agnes-3-flash (2026-10-14): `02-Analisis.md` §2 "Rigen de animación en tiempo real: Descartado — Costo y complejidad".**
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [x] Descartar blend trees ilimitados [S] → **agnes-3-flash (2026-10-14): `02-Analisis.md` §2 "Blend trees ilimitados: Descartado — Costo explosivo; ≤ 4 nodos".**
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [S])
- [ ] Descartar animación 2D/impostores para todo el mundo [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])

## S. Riesgos y mitigaciones

- [x] Riesgo de clips duplicados → AnimationLibrary central + validación [M] → **agnes-3-flash (2026-10-14): `03-Diseno.md` §1 "libraries/ (AnimationLibrary por actor/familia)" + validate_animation.gd.**
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [x] Riesgo de snaps por blending → blend 250 ms + revisión visual [M] → **agnes-3-flash (2026-10-14): `03-Diseno.md` §3.1 "blend por crossfade 250ms".**
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Riesgo de desincronía → eventos en timelines + tests [M]
  · espera: pendiente de verificacion/QA (criterio del item) (marcado [M])
- [x] Riesgo de coste de huesos → burbuja + LOD + registro [M] → **agnes-3-flash (2026-10-14): `03-Diseno.md` §2.1 "LOD: burbuja" + §3.2 "presupuesto de animación".**
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Riesgo de UI molesta → Reduce Motion + duraciones cortas [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Riesgo de imports inconsistentes → plantilla + validador [S]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [S])

## T. Integraciones

- [x] Documentar integración con M11/M19/M36 (FSM) [S] → **agnes-3-flash (2026-10-14): `03-Diseno.md` §1 "El jugador (M11), los NPC (M19/M64) y la fauna (M36/M65) llaman a AnimationService.play".**
  · espera: depende de M11/M19/M36 (coordinar con su dueno)
- [ ] Documentar integración con M64/M65 (burbuja) [S]
  · espera: depende de M64/M65 (coordinar con su dueno)
- [ ] Documentar integración con M45 (rigs/sockets) [S]
  · espera: depende de M45 (coordinar con su dueno)
- [ ] Documentar integración con M13 (herramientas) [S]
  · espera: depende de M13 (coordinar con su dueno)
- [ ] Documentar integración con M43/M44/M52 (eventos) [S]
  · espera: depende de M43/M44/M52 (coordinar con su dueno)
- [ ] Documentar integración con M50/M51 (procedural) [S]
  · espera: depende de M50/M51 (coordinar con su dueno)
- [ ] Documentar integración con M21/M53/M58 (UI) [S]
  · espera: depende de M21/M53/M58 (coordinar con su dueno)
- [ ] Documentar integración con M61/M62 (presupuesto) [S]
  · espera: depende de M61/M62 (coordinar con su dueno)
- [ ] Documentar integración con M74 (festivales) [S]
  · espera: depende de M74 (coordinar con su dueno)
- [ ] Documentar integración con M108/M118 (import + CI) [S]
  · espera: depende de M108/M118 (coordinar con su dueno)

## U. Herramientas y flujos

- [x] Documentar flujo estado→clip (AnimationService) [M]
- [ ] Documentar flujo de producción de un clip [M]
  · espera: pendiente de documentacion (marcado [M])
- [ ] Documentar flujo de validación al importar [M]
  · espera: pendiente de documentacion (marcado [M])
- [ ] Documentar plantilla de import FBX [M]
  · espera: pendiente de documentacion (marcado [M])

## V. Criterios de aceptación verificados

- [ ] 100% de estados FSM de actores cubiertos con animaciones [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Toda mecánica lista tiene animación o "intencional sin animación" definida [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Clips generados con un flujo único y validados sin errores [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Transiciones sin snaps (blend ≤250 ms) [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Sonido y feedback al frame correcto [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] Coste de escena pivote dentro del presupuesto M61 [M]
  · espera: depende de M61 (coordinar con su dueno)
- [ ] Mundo determinista sin RNG visible [M]
  · espera: pendiente de definicion/cierre (ver descripcion del item) (marcado [M])
- [ ] UI respeta M58 y corre a 60 fps [M]
  · espera: depende de M58 (coordinar con su dueno)

## W. Notas finales

- [ ] Documentar el desfase de numeración del plan maestro (47=ANIMACIÓN → ID 48) [S]
  · espera: pendiente de documentacion (marcado [S])
- [x] Marcar el módulo como DELEGABLE PARA IMPLEMENTAR [S]
- [x] Registrar dependencia de implementación con el hito M1 (proyecto Godot) [S]

## Dependencia: Visión del Agente (M154)

- [x] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
**Totales:** 123 items - Completados: 22 - Pendientes: 98 - No resueltos: 3. (Corregido agnes-3-flash 2026-10-14: +13 flips lotes 1-3 citando 02-Analisis/03-Diseno)

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 9 [x] / 114 [ ] / 0 [?].
> Las marcas no se tocaron.
