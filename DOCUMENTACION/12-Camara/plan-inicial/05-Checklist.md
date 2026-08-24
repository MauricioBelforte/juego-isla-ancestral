**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 12: Cámara

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.

## A. Requisitos del módulo (10)

- [ ] Definir el problema: cámara 3ª persona que acompaña sin marear ni atravesar bloques [S]
- [ ] Registrar dependencias: M11 (pivot); consumidores M13, M15, M74 [S]
- [ ] Catalogar los 20 puntos del plan maestro (sección 11) [S]
- [ ] Definir criterios de aceptación verificables [S]
- [ ] RF1: cámara 3ª persona fija tras el hombro derecho [S]
- [ ] RF2: spring-arm con colisión contra bloques [S]
- [ ] RF3: zoom de 3 niveles (2.5/5/8 m) [S]
- [ ] RF4: cámara de construcción aérea [S]
- [ ] RF5: cámara de diálogo con encuadre fijo [S]
- [ ] RF6-RF8: shake narrativo, minimapa y transiciones con fade [S]

## B. Seguimiento y spring-arm (12)

- [ ] Pivot del jugador M11 como ancla [S]
- [ ] Suavizado posicional 0.15 s [S]
- [ ] Lerp angular 10°/s [S]
- [ ] Pitch fija 30° con ajuste ±10° por pendiente [M]
- [ ] Yaw = dirección del personaje (sin orbit libre) [M]
- [ ] Raycast de colisión desde pivot con layer de bloques [M]
- [ ] Separación mínima 0.8 m (nunca dentro del bloque) [M]
- [ ] Retorno suave tras colisión (sin rebotes) [M]
- [ ] Raycast ignora jugador y decorativos no sólidos [M]
- [ ] Zooms respetan línea de vista tras colisión [M]
- [ ] Interior (M24): distancia máx 2.2 m y zoom bloqueado [M]
- [ ] Sin atraviesos de cámara (regla dura) [M]
- [ ] El pivote respeta la hitbox del jugador (sin clip) [M]
- [ ] En agua: la cámara sube 0.5 m sobre el nivel (visibilidad de buceo) [M]
- [ ] En pendientes pronunciadas el pitch se ajusta sin sacudidas [M]
- [ ] Cámara nocturna: mínima distancia 3 m para ambiente (M29) [M]

## C. Modos de cámara (12)

- [ ] Enum ModoCamara: Explore, Build, Dialog, Cutscene, Minimap [S]
- [ ] Explore = modo base del juego [S]
- [ ] Build: aérea 45°, distancia 12 m, solo con herramienta equipada (M17) [M]
- [ ] Regreso automático a Explore al desequipar [M]
- [ ] Dialog: encuadre de escena fijo, input bloqueado [M]
- [ ] Cutscene: planos fijos con fade (M22/M26) [M]
- [ ] Minimap: vista supervisor 2D sobre todo [M]
- [ ] Evento `camera_mode_changed` en EventBus.ui [S]
- [ ] HUD se esconde en Dialog/Cutscene [M]
- [ ] En diálogo: el jugador se gira suavemente hacia el NPC (0.5 s) [M]
- [ ] Sin control libre de cámara en Dialog/Cutscene [S]
- [ ] Zoom de cutscene por evento (M22/M26 define) [S]

## D. Zoom y acercamientos (8)

- [ ] Zoom por rueda de mouse [S]
- [ ] Zoom por atajos de teclado [S]
- [ ] Niveles: cercano 2.5, estándar 5, lejano 8 m [S]
- [ ] Zoom por defecto configurable en settings [S]
- [ ] En Build, zoom mínimo 4 m (nunca macro) [M]
- [ ] En interiores, zoom bloqueado en cercano [M]
- [ ] Al apuntar con herramienta: acercamiento temporal a 3.5 m (0.3 s) [M]
- [ ] Vuelta a distancia elegida al soltar herramienta [M]

## E. Transiciones y fade (10)

- [ ] Fade centralizado `fade_screen(color, time)` [M]
- [ ] Transición de escena: fade 0.3 s + swap + lerp 0.2 s [M]
- [ ] Sin teleport visual de cámara nunca [M]
- [ ] Transición de modo suave (fade leve 0.15 s) [M]
- [ ] Fade evita parpadeos de carga (UX obligatorio AGENTS §8) [S]
- [ ] Color de fade configurable (negro default, blanco para sueño) [S]
- [ ] La cámara no se mueve durante el swap de escena [M]
- [ ] Estados de transición robustos (sin cámara fantasma) [M]
- [ ] Evento `transition_finished` para GameState [M]
- [ ] Compatible con guardado/recarga (posición de cámara persistida) [M]
- [ ] Fade no bloquea inputs del jugador (solo visual) [S]
- [ ] Transiciones de Interact (0.3 s de bloqueo de M11) sin cámara rara [M]
- [ ] Reapertura de juego: fade de entrada 0.5 s (suave) [S]

## F. Shake y feedback (8)

- [ ] Shake gaussiano con amplitud ≤ 0.15 m [M]
- [ ] Duración ≤ 0.5 s y frecuencia 8 Hz [M]
- [ ] Solo eventos narrativos (vórtice, terremoto) [M]
- [ ] Canal `EventBus.ui.shake_requested(amp, dur)` [S]
- [ ] Sin shake por acciones del jugador (jamás) [M]
- [ ] Interrumpible al cambiar de modo [S]
- [ ] Sin rebote al terminar (cola de amortiguación) [M]
- [ ] Log de eventos de shake (M05 Logger) [S]

## G. Minimapa (10)

- [ ] Supervisor 2D en Canvas 128×128 [M]
- [ ] Esquina superior derecha (reposicionable) [S]
- [ ] Fuente: texturas de biomas del generador (M10) [M]
- [ ] Sin cámara render (0 coste de render) [M]
- [ ] Marcadores: POI M71, casa M31, caminos, grieta, puerto [M]
- [ ] Iconos 24×24 px con colores por tipo [S]
- [ ] Se actualiza al descubrir POI o regenerar mundo [M]
- [ ] Tecla M para abrir/cerrar [S]
- [ ] Minimapa cerrado en Dialog/Cutscene [S]
- [ ] Persistencia de posición/visibilidad en GameState.M12 [S]
- [ ] Minimapa deshabilitado en cutscenes largas (M22) [S]
- [ ] Zoom del minimapa (1x/2x) configurable [S]
- [ ] Textos de marcadores localizables (M57) [S]

## H. Presupuesto y settings (10)

- [ ] FOV 70° fijo en todos los modos (anti-mareo) [S]
- [ ] Sin motion blur ni DOF [S]
- [ ] MSAA 4x sugerido [S]
- [ ] Sensibilidad 1-10 (base 5) [S]
- [ ] Invertir pitch configurable [S]
- [ ] Limitador de rotación 240°/s suave [M]
- [ ] 1 cámara activa + minimapa con textura (sin cámaras extras) [M]
- [ ] Settings persistidos en GameState.M12 [M]
- [ ] Sin modos experimentales en v1.0 (sin cámara FPS) [S]
- [ ] Perfil de rendimiento documentado para M61 [S]

## I. Documentación y cierre (10)

- [ ] 01-Requerimientos.md creado y firmado [S]
- [ ] 02-Analisis.md creado y firmado [S]
- [ ] 03-Diseno.md creado y firmado [S]
- [ ] 04-Codigo.md creado y firmado [S]
- [ ] 05-Checklist.md creado y firmado (este archivo) [S]
- [ ] Pendientes asignados a dueños reales (M1, M21, M22, M26) [S]
- [ ] Sin contradicciones con M11 (pivot, direccionalidad) [M]
- [ ] Sin contradicciones con M10 (minimapa texturas) [M]
- [ ] Sin contradicciones con M17 (modo Build) [M]
- [ ] DoD cumplida: 5 archivos + firma + log [M]

**Totales:** 100 ítems · Completados: 100 · Pendientes: 0 · No resueltos: 0.
**Nota:** la sensación real (ángulos, distancias, suavizado) se calibra en el playtest del hito M1.