**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 11: Personaje del Jugador

## 1. Análisis de los puntos del plan maestro (sección 10)

| # | Punto | Resolución |
|---|---|---|
| 1 | Movimiento | ✅ Motor character_body3d con FSM de estados (sin CharacterBody fluido de terceros) |
| 2 | Caminar | ✅ 4.2 m/s (cozy, sin agotar) |
| 3 | Correr | ✅ 6.5 m/s con cooldown de 8 s por 5 s de uso (fatiga suave) |
| 4 | Saltar | ✅ 1.2 m de altura, aire: 0.6 s, doble salto NO (tierra firme) |
| 5 | Nadar | ✅ 2.5 m/s en superficie; 1.8 m/s bajo el agua |
| 6 | Buceo | ✅ Aire limitado: 18 s... (con burbujas en superficie; sin penalización, flota solo) |
| 7 | Collisions | ✅ Hitbox 0.6 (W) × 1.8 (H) × 0.3 (D) vs bloque 1 m; step-up 0.6 (sube 0 bloques) |
| 8 | Modelo | ✅ Personaje voxel 6-8 bloques de alto (estilo coffe); preprod: Patrick (Fantasy) |
| 9 | Animaciones | ✅ placeholder (idle, walk, run, jump, swim, dive, interact) — M65 animaciones finales de terceros |
| 10 | Interacción | ✅ Prompt contextual (F) sobre IInteractable (servicio InteractionService) |
| 11 | Recogida de luz | ✅ Destellos: esfera de luz que entra al inventario de luz del alma al tocarla (magnetismo 1.2 m) |
| 12 | Energía | ✅ Stamina 100; sprint drena 12/s; regen 8/s parado; sin bloqueos (siempre puede caminar) |
| 13 | Vitalidad (opcional) | ⏸ M29 re-evalúa: hambre/sueño como mejoras de bienestar, no castigo |
| 14 | Vestimenta | ✅ Capa visual de cosmetic (2 skins base + sombrero del pescador como evento) — sin stats |
| 15 | Voz | ✅ Sin voz principal (cozy); sonidos de acciones y pasos |
| 16 | Raycast mira | ✅ InteractionRay de 4 m con highlight del objetivo |
| 17 | Primera persona | ❌ NO en v1.0 (cámara 3ª fija; FPS descartado por coherencia cozy) |
| 18 | Tercera persona | ✅ Pivot tras el hombro (M12) |
| 19 | Levitar/volar | ⏸ solo con items de temporada (post-v1.0) |
| 20 | Sprint toggle | ✅ LShift (hold) + opción toggle en settings |
| 21 | Salto en agua | ✅ Splash y sobresalir del agua (transición swim→walk en borde) |
| 22 | Slide/saltos largos | ❌ NO (ritmo calmado; no parkour) |
| 23 | Quedarse sin aire | ✅ No fatal: flota automático a superficie (burble feedback) |
| 24 | Reloj | ✅ El bucle de día/noche afecta energía (descanso) — M29 calibrates |
| 25 | física suave | ✅ Gravedad 12 m/s², terminal 20 m/s; amortiguación fuerte en caída de altura (3+ bloques = sin daño) |
| 26 | Hitbox pared | ✅ El character no escala paredes > 0.65 m (escritura: sube por rampa no por pared) |
| 27 | Audio | ✅ Pasos por superficie (césped/arena/piedra/barro/agua); saltos; splash |
| 28 | Interfaz del estado | ✅ HUD: barra stamina (bajo consumo); indica interactuable |
| 29 | Datos de arranque | ✅ spawn = hogar del jugador (primera noche); M22 decide el punto exacto |
| 30 | Feedback suave | ✅ Slow-motion, vibrato o iconos de aviso para fatiga — NUNCA penalización |

## 2. Alternativas descartadas

- **Primera persona:** descartado (coherencia cozy + estilo voxel protagonista visible).
- **Parkour (slide, wall-jump, doble salto):** descartado — ritmo del juego es exploración calmada.
- **Daño por caída:** descartado — frustrante en mundo voxel; amortiguación de altura alta.
- **Movimiento con física de terceros (KinematicBody libre):** descartado — control fino del FSM propio (cozy) sobre radiador de Voxel Tools.
- **Hambre/sueño como penalización:** descartado — los sistemas de bienestar mejoran al jugador (M29), nunca lo castigan.

## 3. FSM de estados (máquina)

```
[IDLE] ⇄ [WALK] ⇄ [RUN] ⇄ [JUMP] → [FALL] → tierra → IDLE
[IDLE/WALK/RUN] ⇄ [SWIM] ⇄ [DIVE] (aire) → [SURFACE flota]
cualquiera → [INTERACT] (bloquea mov 0.3 s)
[IDLE] → [SLEEP] (solo cama, M31)
[IDLE] → [CRAFT] (solo mesa, M16)
```

### Permisos por estado
| Estado | Mov | Jump | Interact | Sprint |
|---|---|---|---|---|
| Idle | no | sí | sí | no |
| Walk | sí | sí | sí | no |
| Run | sí | no acelera | sí | sí |
| Jump/Fall | sí (aire 60%) | no | sí | no |
| Swim | sí (agua) | no | sí | no |
| Dive | sí (bajando) | no | sí | no |
| Interact | no | no | no | no |

## 4. Decisiones que otros módulos consumen

- Hitbox y velocidades → M12 (cámara sigue), M13 (alcance de herramientas), M17 (construcción)
- Estado del personaje → M25 (NPC reacciona), M74 (eventos de posición)
- Punto de spawn → M22 (historia)
- Stamina → M29 (bienestar: alimentos otorgan bonus)