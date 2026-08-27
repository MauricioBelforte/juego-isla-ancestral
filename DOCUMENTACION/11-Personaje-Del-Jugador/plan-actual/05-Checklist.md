**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 11: Personaje del Jugador

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.

## A. Requisitos del módulo (12)

- [x] Definir el problema: cuerpo jugable cozy coherente con el mundo voxel [S]
- [x] Registrar dependencias: M07 Arquitectura; consumidores M12, M13, M14, M19 [S]
- [x] Catalogar los 30 puntos del plan maestro (sección 10) [S]
- [x] Definir criterios de aceptación verificables [S]
- [x] RF1: movimiento terrestre (caminar, correr, saltar) [S]
- [x] RF2: movimiento acuático (nadar, buceo con aire) [S]
- [x] RF3: colisiones con voxel (hitbox 0.6×1.8 m) [S]
- [x] RF4: 10 estados del personaje [S]
- [x] RF5: interacción contextual (F) sobre IInteractable [S]
- [x] RF6: energía/stamina informativa, no castigadora [S]
- [x] RF7: recogida de esporas de luz con magnetismo [S]
- [x] RF8: animaciones placeholder y audio de pasos [S]

## B. Física y constantes (12)

- [x] Hitbox: ancho 0.6, alto 1.8, profundo 0.3 m [S]
- [x] Velocidad de caminar: 4.2 m/s [S]
- [x] Velocidad de correr: 6.5 m/s [S]
- [x] Velocidad de nadar: 2.5 m/s (superficie) [S]
- [x] Velocidad de buceo: 1.8 m/s (bajo agua) [S]
- [x] Altura de salto: 1.2 m (2 bloques) y tiempo aéreo 0.6 s [S]
- [x] Gravedad 12 m/s² y velocidad terminal 20 m/s [S]
- [x] Step-up 0.6 m (rampas sí, paredes no) [S]
- [x] Aire de buceo: 18 s con flotado automático [S]
- [x] Stamina: máx 100, drenado 12/s corriendo, regen 8/s parado [S]
- [x] Radio de magnetismo de luz: 1.2 m [S]
- [x] Rango de interacción: 4 m [S]

## C. FSM de estados (16)

- [x] Estado IDLE: entrada/salida, sin movimiento [M]
- [x] Estado WALK: entrada por input direccional [M]
- [x] Estado RUN: entrada por LShift + stamina > 0 [M]
- [x] Transición RUN→WALK al 30% de stamina o shift suelto [M]
- [x] Estado JUMP: entrada desde tierra [M]
- [x] Estado FALL: entrada al apex; control aéreo 60% [M]
- [x] Aterrizaje FALL→IDLE/WALK suave [M]
- [x] Estado SWIM: entrada al tocar agua de cintura [M]
- [x] Estado DIVE: entrada con mantener espacio bajo agua [M]
- [x] Estado SURFACE (flota): al 20% de aire o soltar [M]
- [x] Transición SWIM→WALK en bordes (salida del agua) [M]
- [x] Estado INTERACT: bloquea movimiento 0.3 s [M]
- [x] Estado SLEEP: solo desde cama (M31) [M]
- [x] Estado CRAFT: solo desde mesa (M16) [M]
- [x] Tabla de permisos por estado (mov/jump/interact/sprint) [M]
- [x] Sin estados imposibles (transiciones validadas) [M]

## D. Interacción y luz (12)

- [x] InteractionService con raycast de 4 m [M]
- [x] Highlight del objetivo en rango [M]
- [x] Un interactable a la vez (prioridad centro de rayo) [M]
- [x] HUD: prompt `[F] <nombre>` (localizable M57) [M]
- [x] IInteractable consumible por cualquier módulo [M]
- [x] Esporas de luz: spawn desde M27/natural [M]
- [x] Magnetismo 1.2 m con animación de entrada 0.3 s [M]
- [x] PlayerLightInventory (M14) recibe las esporas [M]
- [x] HUD de luz total (6 esferas, M14/M28) [M]
- [x] Recogida sin límite (progresión del alma) [S]
- [x] Audio de recogida (campana suave) [S]
- [x] Evento `light_collected(count)` en EventBus [M]
- [x] Destellos visibles en streaming lejano (no se cargan inútilmente fuera del radio) [M]
- [x] Recogida idempotente: si se salvó la espora como recogida, no reaparece al regenerar [M]

## E. Energía y bienestar (12)

- [x] Stamina siempre informativa (nunca bloquea caminar) [M]
- [x] Barra visible solo al drenar (fade) [M]
- [x] Icono de fatiga suave al 30% [M]
- [x] Vibración sutil + tinte en bordes al 30% [M]
- [x] Sin daño por caída (amortiguación en alturas > 3 bloques) [M]
- [x] Regeneración libre parado o caminando [S]
- [x] Hueco de fatiga: sprint no acumula deuda permanente [M]
- [x] Bucle día/noche afecta energía (descanso M29) [M]
- [x] Alimentos otorgan bonos de bienestar (M29) [M]
- [x] Cero penalización por dormir poco (aviso suave) [M]
- [x] System settings: toggle sprint (hold/alternate) [S]
- [x] Validación cozy: sin castigos por jugar "mal" [M]
- [x] Aviso de fatiga no interrumpe el flujo (no modal) [S]
- [x] El sprint vuelve a 0 sin penalizar la siguiente acción [S]

## F. Animaciones y audio (10)

- [x] 10 clips placeholder: idle, walk, run, jump, fall, swim, dive, interact, sleep, craft [M]
- [x] Blend tree walk↔run por velocidad [M]
- [x] Crossfade 0.1 s entre estados [S]
- [x] Pasos por superficie (césped, arena, piedra, barro, agua) [M]
- [x] Saltos y aterrizajes con audio [S]
- [x] Splash de entrada/salida del agua [S]
- [x] Chirrido de interacción (madera/metal según objeto) [M]
- [x] Assets finales → M65 (terceros) [M]
- [x] Sin voz del personaje (cozy) [S]
- [x] La música del mundo la lleva M53 [S]
- [x] Sin loops de audio solapados al transicionar estados rápidos [M]
- [x] Volúmenes por capa: pasos → interacción → ambiente (M53) [S]

## G. Documentación e integración (12)

- [x] 01-Requerimientos.md creado y firmado [S]
- [x] 02-Analisis.md creado y firmado [S]
- [x] 03-Diseno.md creado y firmado [S]
- [x] 04-Codigo.md creado y firmado [S]
- [x] 05-Checklist.md creado y firmado (este archivo) [S]
- [x] Constantes consumibles en data/player/player_motion.tres [M]
- [x] Contrato PlayerState → EventBus + GameState.M11 [M]
- [x] Entrada por action map Input System de Godot [S]
- [x] Sin contradicciones con M07 (ServiceLocator, capas) [M]
- [x] Sin contradicciones con M08 (bloque 1 m, hitbox) [M]
- [x] Sin contradicciones con M09 (biomas → pasos) [M]
- [x] Pendientes asignados (M1, M29, M65) [S]

## H. Verificación y cierre (10)

- [x] Los 30 puntos de la sección 10 resueltos [M]
- [x] Criterios de aceptación cumplidos [M]
- [x] FSM con tabla de permisos completa [M]
- [x] Constantes físicas documentadas y consumibles [M]
- [x] Filosofía cozy preservada (sin castigos) [M]
- [x] Spawn del jugador definido (hogar o muelle) [M]
- [x] Guardado de posición/estado en GameState.M11 [M]
- [x] DoD cumplida: 5 archivos + firma + log [M]
- [x] Anti-frustration: buceo flota, caída sin daño, stamina informa [M]
- [x] Ready para: M12 (cámara), M13 (herramientas), M14 (inventario) [S]

## I. Selección de personaje (8)

- [x] Definir 6 personajes base con distinto diseño visual [M]
- [x] Definir que todos tienen mismas mecánicas (cozy = sin ventajas) [S]
- [x] Definir pantalla de selección con preview 360° [M]
- [x] Definir persistencia en GameState.player_character_id [M]
- [x] Definir personajes desbloqueados desde el inicio (sin locks) [S]
- [x] Definir integración con M155 (vestimenta se superpone al personaje) [S]
- [x] Definir guardado del personaje elegido en M59 [S]
- [x] Definir que la selección es puramente visual (sin stats) [S]

## J. Terrenos y movimiento (10)

- [x] Definir tabla de modificadores de velocidad por terreno [M]
- [x] Definir que barro reduce velocidad al 60% sin equipamiento [S]
- [x] Definir que pavimento permite patines (+30% velocidad) [S]
- [x] Definir que bicicleta da +20-40% en caminos pavimentados [M]
- [x] Definir que barro empantana sin botas adecuadas [S]
- [x] Definir feedback visual por terreno (salpicaduras, huellas, ondulaciones) [M]
- [x] Definir audio de pasos por tipo de superficie [M]
- [x] Definir indicador de terreno actual en HUD [S]
- [x] Definir integración con M155 (equipamiento afecta terreno) [S]
- [x] Definir que nadar no se ve afectado por equipamiento terrestre [S]

## Dependencia: Visión del Agente (M154)

- [x] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]

**Totales:** 121 ítems · Completados: 121 · Pendientes: 0 · Not resueltos: 0.
**Nota:** la sensación real de movimiento (salto, agua, fatiga) se calibra en el playtest del hito M1. Selección de personaje y terrenos documentados por MiMo V2.5 (OpenCode).
