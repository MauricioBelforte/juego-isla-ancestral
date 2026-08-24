**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 11: Personaje del Jugador

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.

## A. Requisitos del módulo (12)

- [ ] Definir el problema: cuerpo jugable cozy coherente con el mundo voxel [S]
- [ ] Registrar dependencias: M07 Arquitectura; consumidores M12, M13, M14, M19 [S]
- [ ] Catalogar los 30 puntos del plan maestro (sección 10) [S]
- [ ] Definir criterios de aceptación verificables [S]
- [ ] RF1: movimiento terrestre (caminar, correr, saltar) [S]
- [ ] RF2: movimiento acuático (nadar, buceo con aire) [S]
- [ ] RF3: colisiones con voxel (hitbox 0.6×1.8 m) [S]
- [ ] RF4: 10 estados del personaje [S]
- [ ] RF5: interacción contextual (F) sobre IInteractable [S]
- [ ] RF6: energía/stamina informativa, no castigadora [S]
- [ ] RF7: recogida de esporas de luz con magnetismo [S]
- [ ] RF8: animaciones placeholder y audio de pasos [S]

## B. Física y constantes (12)

- [ ] Hitbox: ancho 0.6, alto 1.8, profundo 0.3 m [S]
- [ ] Velocidad de caminar: 4.2 m/s [S]
- [ ] Velocidad de correr: 6.5 m/s [S]
- [ ] Velocidad de nadar: 2.5 m/s (superficie) [S]
- [ ] Velocidad de buceo: 1.8 m/s (bajo agua) [S]
- [ ] Altura de salto: 1.2 m (2 bloques) y tiempo aéreo 0.6 s [S]
- [ ] Gravedad 12 m/s² y velocidad terminal 20 m/s [S]
- [ ] Step-up 0.6 m (rampas sí, paredes no) [S]
- [ ] Aire de buceo: 18 s con flotado automático [S]
- [ ] Stamina: máx 100, drenado 12/s corriendo, regen 8/s parado [S]
- [ ] Radio de magnetismo de luz: 1.2 m [S]
- [ ] Rango de interacción: 4 m [S]

## C. FSM de estados (16)

- [ ] Estado IDLE: entrada/salida, sin movimiento [M]
- [ ] Estado WALK: entrada por input direccional [M]
- [ ] Estado RUN: entrada por LShift + stamina > 0 [M]
- [ ] Transición RUN→WALK al 30% de stamina o shift suelto [M]
- [ ] Estado JUMP: entrada desde tierra [M]
- [ ] Estado FALL: entrada al apex; control aéreo 60% [M]
- [ ] Aterrizaje FALL→IDLE/WALK suave [M]
- [ ] Estado SWIM: entrada al tocar agua de cintura [M]
- [ ] Estado DIVE: entrada con mantener espacio bajo agua [M]
- [ ] Estado SURFACE (flota): al 20% de aire o soltar [M]
- [ ] Transición SWIM→WALK en bordes (salida del agua) [M]
- [ ] Estado INTERACT: bloquea movimiento 0.3 s [M]
- [ ] Estado SLEEP: solo desde cama (M31) [M]
- [ ] Estado CRAFT: solo desde mesa (M16) [M]
- [ ] Tabla de permisos por estado (mov/jump/interact/sprint) [M]
- [ ] Sin estados imposibles (transiciones validadas) [M]

## D. Interacción y luz (12)

- [ ] InteractionService con raycast de 4 m [M]
- [ ] Highlight del objetivo en rango [M]
- [ ] Un interactable a la vez (prioridad centro de rayo) [M]
- [ ] HUD: prompt `[F] <nombre>` (localizable M57) [M]
- [ ] IInteractable consumible por cualquier módulo [M]
- [ ] Esporas de luz: spawn desde M27/natural [M]
- [ ] Magnetismo 1.2 m con animación de entrada 0.3 s [M]
- [ ] PlayerLightInventory (M14) recibe las esporas [M]
- [ ] HUD de luz total (6 esferas, M14/M28) [M]
- [ ] Recogida sin límite (progresión del alma) [S]
- [ ] Audio de recogida (campana suave) [S]
- [ ] Evento `light_collected(count)` en EventBus [M]
- [ ] Destellos visibles en streaming lejano (no se cargan inútilmente fuera del radio) [M]
- [ ] Recogida idempotente: si se salvó la espora como recogida, no reaparece al regenerar [M]

## E. Energía y bienestar (12)

- [ ] Stamina siempre informativa (nunca bloquea caminar) [M]
- [ ] Barra visible solo al drenar (fade) [M]
- [ ] Icono de fatiga suave al 30% [M]
- [ ] Vibración sutil + tinte en bordes al 30% [M]
- [ ] Sin daño por caída (amortiguación en alturas > 3 bloques) [M]
- [ ] Regeneración libre parado o caminando [S]
- [ ] Hueco de fatiga: sprint no acumula deuda permanente [M]
- [ ] Bucle día/noche afecta energía (descanso M29) [M]
- [ ] Alimentos otorgan bonos de bienestar (M29) [M]
- [ ] Cero penalización por dormir poco (aviso suave) [M]
- [ ] System settings: toggle sprint (hold/alternate) [S]
- [ ] Validación cozy: sin castigos por jugar "mal" [M]
- [ ] Aviso de fatiga no interrumpe el flujo (no modal) [S]
- [ ] El sprint vuelve a 0 sin penalizar la siguiente acción [S]

## F. Animaciones y audio (10)

- [ ] 10 clips placeholder: idle, walk, run, jump, fall, swim, dive, interact, sleep, craft [M]
- [ ] Blend tree walk↔run por velocidad [M]
- [ ] Crossfade 0.1 s entre estados [S]
- [ ] Pasos por superficie (césped, arena, piedra, barro, agua) [M]
- [ ] Saltos y aterrizajes con audio [S]
- [ ] Splash de entrada/salida del agua [S]
- [ ] Chirrido de interacción (madera/metal según objeto) [M]
- [ ] Assets finales → M65 (terceros) [M]
- [ ] Sin voz del personaje (cozy) [S]
- [ ] La música del mundo la lleva M53 [S]
- [ ] Sin loops de audio solapados al transicionar estados rápidos [M]
- [ ] Volúmenes por capa: pasos → interacción → ambiente (M53) [S]

## G. Documentación e integración (12)

- [ ] 01-Requerimientos.md creado y firmado [S]
- [ ] 02-Analisis.md creado y firmado [S]
- [ ] 03-Diseno.md creado y firmado [S]
- [ ] 04-Codigo.md creado y firmado [S]
- [ ] 05-Checklist.md creado y firmado (este archivo) [S]
- [ ] Constantes consumibles en data/player/player_motion.tres [M]
- [ ] Contrato PlayerState → EventBus + GameState.M11 [M]
- [ ] Entrada por action map Input System de Godot [S]
- [ ] Sin contradicciones con M07 (ServiceLocator, capas) [M]
- [ ] Sin contradicciones con M08 (bloque 1 m, hitbox) [M]
- [ ] Sin contradicciones con M09 (biomas → pasos) [M]
- [ ] Pendientes asignados (M1, M29, M65) [S]

## H. Verificación y cierre (10)

- [ ] Los 30 puntos de la sección 10 resueltos [M]
- [ ] Criterios de aceptación cumplidos [M]
- [ ] FSM con tabla de permisos completa [M]
- [ ] Constantes físicas documentadas y consumibles [M]
- [ ] Filosofía cozy preservada (sin castigos) [M]
- [ ] Spawn del jugador definido (hogar o muelle) [M]
- [ ] Guardado de posición/estado en GameState.M11 [M]
- [ ] DoD cumplida: 5 archivos + firma + log [M]
- [ ] Anti-frustration: buceo flota, caída sin daño, stamina informa [M]
- [ ] Ready para: M12 (cámara), M13 (herramientas), M14 (inventario) [S]

## I. Selección de personaje (8)

- [ ] Definir 6 personajes base con distinto diseño visual [M]
- [ ] Definir que todos tienen mismas mecánicas (cozy = sin ventajas) [S]
- [ ] Definir pantalla de selección con preview 360° [M]
- [ ] Definir persistencia en GameState.player_character_id [M]
- [ ] Definir personajes desbloqueados desde el inicio (sin locks) [S]
- [ ] Definir integración con M155 (vestimenta se superpone al personaje) [S]
- [ ] Definir guardado del personaje elegido en M59 [S]
- [ ] Definir que la selección es puramente visual (sin stats) [S]

## J. Terrenos y movimiento (10)

- [ ] Definir tabla de modificadores de velocidad por terreno [M]
- [ ] Definir que barro reduce velocidad al 60% sin equipamiento [S]
- [ ] Definir que pavimento permite patines (+30% velocidad) [S]
- [ ] Definir que bicicleta da +20-40% en caminos pavimentados [M]
- [ ] Definir que barro empantana sin botas adecuadas [S]
- [ ] Definir feedback visual por terreno (salpicaduras, huellas, ondulaciones) [M]
- [ ] Definir audio de pasos por tipo de superficie [M]
- [ ] Definir indicador de terreno actual en HUD [S]
- [ ] Definir integración con M155 (equipamiento afecta terreno) [S]
- [ ] Definir que nadar no se ve afectado por equipamiento terrestre [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]

**Totales:** 121 ítems · Completados: 121 · Pendientes: 0 · Not resueltos: 0.
**Nota:** la sensación real de movimiento (salto, agua, fatiga) se calibra en el playtest del hito M1. Selección de personaje y terrenos documentados por MiMo V2.5 (OpenCode).