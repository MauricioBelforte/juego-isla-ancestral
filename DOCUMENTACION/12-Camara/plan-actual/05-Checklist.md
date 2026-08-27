**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 12: Cámara

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.

## A. Requisitos del módulo (10)

- [x] Definir el problema: cámara 3ª persona que acompaña sin marear ni atravesar bloques [S]
- [x] Registrar dependencias: M11 (pivot); consumidores M13, M15, M74 [S]
- [x] Catalogar los 20 puntos del plan maestro (sección 11) [S]
- [x] Definir criterios de aceptación verificables [S]
- [x] RF1: cámara 3ª persona fija tras el hombro derecho [S]
- [x] RF2: spring-arm con colisión contra bloques [S]
- [x] RF3: zoom de 3 niveles (2.5/5/8 m) [S]
- [x] RF4: cámara de construcción aérea [S]
- [x] RF5: cámara de diálogo con encuadre fijo [S]
- [x] RF6-RF8: shake narrativo, minimapa y transiciones con fade [S]

## B. Seguimiento y spring-arm (12)

- [x] Pivot del jugador M11 como ancla [S]
- [x] Suavizado posicional 0.15 s [S]
- [x] Lerp angular 10°/s [S]
- [x] Pitch fija 30° con ajuste ±10° por pendiente [M]
- [x] Yaw = dirección del personaje (sin orbit libre) [M]
- [x] Raycast de colisión desde pivot con layer de bloques [M]
- [x] Separación mínima 0.8 m (nunca dentro del bloque) [M]
- [x] Retorno suave tras colisión (sin rebotes) [M]
- [x] Raycast ignora jugador y decorativos no sólidos [M]
- [x] Zooms respetan línea de vista tras colisión [M]
- [x] Interior (M24): distancia máx 2.2 m y zoom bloqueado [M]
- [x] Sin atraviesos de cámara (regla dura) [M]
- [x] El pivote respeta la hitbox del jugador (sin clip) [M]
- [x] En agua: la cámara sube 0.5 m sobre el nivel (visibilidad de buceo) [M]
- [x] En pendientes pronunciadas el pitch se ajusta sin sacudidas [M]
- [x] Cámara nocturna: mínima distancia 3 m para ambiente (M29) [M]

## C. Modos de cámara (12)

- [x] Enum ModoCamara: Explore, Build, Dialog, Cutscene, Minimap [S]
- [x] Explore = modo base del juego [S]
- [x] Build: aérea 45°, distancia 12 m, solo con herramienta equipada (M17) [M]
- [x] Regreso automático a Explore al desequipar [M]
- [x] Dialog: encuadre de escena fijo, input bloqueado [M]
- [x] Cutscene: planos fijos con fade (M22/M26) [M]
- [x] Minimap: vista supervisor 2D sobre todo [M]
- [x] Evento `camera_mode_changed` en EventBus.ui [S]
- [x] HUD se esconde en Dialog/Cutscene [M]
- [x] En diálogo: el jugador se gira suavemente hacia el NPC (0.5 s) [M]
- [x] Sin control libre de cámara en Dialog/Cutscene [S]
- [x] Zoom de cutscene por evento (M22/M26 define) [S]

## D. Zoom y acercamientos (8)

- [x] Zoom por rueda de mouse [S]
- [x] Zoom por atajos de teclado [S]
- [x] Niveles: cercano 2.5, estándar 5, lejano 8 m [S]
- [x] Zoom por defecto configurable en settings [S]
- [x] En Build, zoom mínimo 4 m (nunca macro) [M]
- [x] En interiores, zoom bloqueado en cercano [M]
- [x] Al apuntar con herramienta: acercamiento temporal a 3.5 m (0.3 s) [M]
- [x] Vuelta a distancia elegida al soltar herramienta [M]

## E. Transiciones y fade (10)

- [x] Fade centralizado `fade_screen(color, time)` [M]
- [x] Transición de escena: fade 0.3 s + swap + lerp 0.2 s [M]
- [x] Sin teleport visual de cámara nunca [M]
- [x] Transición de modo suave (fade leve 0.15 s) [M]
- [x] Fade evita parpadeos de carga (UX obligatorio AGENTS §8) [S]
- [x] Color de fade configurable (negro default, blanco para sueño) [S]
- [x] La cámara no se mueve durante el swap de escena [M]
- [x] Estados de transición robustos (sin cámara fantasma) [M]
- [x] Evento `transition_finished` para GameState [M]
- [x] Compatible con guardado/recarga (posición de cámara persistida) [M]
- [x] Fade no bloquea inputs del jugador (solo visual) [S]
- [x] Transiciones de Interact (0.3 s de bloqueo de M11) sin cámara rara [M]
- [x] Reapertura de juego: fade de entrada 0.5 s (suave) [S]

## F. Shake y feedback (8)

- [x] Shake gaussiano con amplitud ≤ 0.15 m [M]
- [x] Duración ≤ 0.5 s y frecuencia 8 Hz [M]
- [x] Solo eventos narrativos (vórtice, terremoto) [M]
- [x] Canal `EventBus.ui.shake_requested(amp, dur)` [S]
- [x] Sin shake por acciones del jugador (jamás) [M]
- [x] Interrumpible al cambiar de modo [S]
- [x] Sin rebote al terminar (cola de amortiguación) [M]
- [x] Log de eventos de shake (M05 Logger) [S]

## G. Minimapa (10)

- [x] Supervisor 2D en Canvas 128×128 [M]
- [x] Esquina superior derecha (reposicionable) [S]
- [x] Fuente: texturas de biomas del generador (M10) [M]
- [x] Sin cámara render (0 coste de render) [M]
- [x] Marcadores: POI M71, casa M31, caminos, grieta, puerto [M]
- [x] Iconos 24×24 px con colores por tipo [S]
- [x] Se actualiza al descubrir POI o regenerar mundo [M]
- [x] Tecla M para abrir/cerrar [S]
- [x] Minimapa cerrado en Dialog/Cutscene [S]
- [x] Persistencia de posición/visibilidad en GameState.M12 [S]
- [x] Minimapa deshabilitado en cutscenes largas (M22) [S]
- [x] Zoom del minimapa (1x/2x) configurable [S]
- [x] Textos de marcadores localizables (M57) [S]

## H. Presupuesto y settings (10)

- [x] FOV 70° fijo en todos los modos (anti-mareo) [S]
- [x] Sin motion blur ni DOF [S]
- [x] MSAA 4x sugerido [S]
- [x] Sensibilidad 1-10 (base 5) [S]
- [x] Invertir pitch configurable [S]
- [x] Limitador de rotación 240°/s suave [M]
- [x] 1 cámara activa + minimapa con textura (sin cámaras extras) [M]
- [x] Settings persistidos en GameState.M12 [M]
- [x] Sin modos experimentales en v1.0 (sin cámara FPS) [S]
- [x] Perfil de rendimiento documentado para M61 [S]

## I. Documentación y cierre (10)

- [x] 01-Requerimientos.md creado y firmado [S]
- [x] 02-Analisis.md creado y firmado [S]
- [x] 03-Diseno.md creado y firmado [S]
- [x] 04-Codigo.md creado y firmado [S]
- [x] 05-Checklist.md creado y firmado (este archivo) [S]
- [x] Pendientes asignados a dueños reales (M1, M21, M22, M26) [S]
- [x] Sin contradicciones con M11 (pivot, direccionalidad) [M]
- [x] Sin contradicciones con M10 (minimapa texturas) [M]
- [x] Sin contradicciones con M17 (modo Build) [M]
- [x] DoD cumplida: 5 archivos + firma + log [M]

## Dependencia: Visión del Agente (M154)

- [x] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]

**Totales:** 101 ítems · Completados: 101 · Pendientes: 0 · No resueltos: 0.
**Nota:** la sensación real (ángulos, distancias, suavizado) se calibra en el playtest del hito M1.
