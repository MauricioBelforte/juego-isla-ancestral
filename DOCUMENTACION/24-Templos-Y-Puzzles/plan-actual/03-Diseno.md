# 03 — Diseño — M24: Templos y Puzzles

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Framework emisor→receptor (decisión central)

- **Emisor:** elemento que produce una señal ante una acción del jugador o del mundo (palanca, placa, cristal de luz, compuerta, secuencia, sonido).
- **Receptor:** elemento que reacciona a la señal (puerta, nivel de agua, rayo activado, bloque movido).
- **Regla:** conector declarativo entre emisores y receptores con condiciones (umbral de peso, línea de audición, dirección de luz, estado de otro puzzle).
- **Estado de sala:** vector `S = (e1…en)` con el valor de cada emisor; el **estado objetivo** `T` es la solución única verificable.

```
Palanca_A(Emisor) ──regla: si ON──▶ Puerta_Este(Receptor)
Cristal_B(Emisor luz) ──si rayo 45°──▶ Runa_Acceso(Receptor: S[7]=1)
```

## Validación de arbitrary/ambigüedad

- En el **Editor** (Validación) y en **tests** se computa el grafo: si hay 0, 2+ soluciones alcanzables o una solución que dependa de una regla no conectada → el puzzle **falla la suite** y no entra al build.
- Doble convalidación en runtime: `estado == objetivo` para completar; si el jugador está a 1 paso del objetivo, el framework emite "casi solución" (efecto visual sutil, no texto).
- Las reglas son transitivas (el puzzle multilateral comparte el vector de sala).

## Familias y datos

| Familia | Emisores | Receptores | Verificación |
|---|---|---|---|
| Luz | farol, lente, prisma | cristal, runa activada | rayo en línea recta, ángulo de incidencia (datos) |
| Espejos | espejo rotatorio | receptor de rayo | giro 45° múltiplos, prueba de camino (Editor) |
| Agua | compuerta, fuente | nivel de agua, barca | altura por compuerta (datos), boyantes |
| Hielo | bloque de hielo | ranuras | simetría de patrón (Editor) |
| Presión | placa, umbral de peso | puerta, elevador | peso estático/dinámico |
| Bloques | bloque push/pull | ranura, puente | movimiento 1 eje, colisiones |
| Gravedad | burbuja de gravedad | dirección de desplazamiento | zonas seleccionadas por sala |
| Movimiento | plataforma móvil, cinta, pulso | sincronización reloj (M29) | fase del reloj (datos) |
| Sonido | campana, gong | receptor acústico | línea de audición clara (M43 hook) |
| Secuencia | botones de secuencia | urna sellada | patrón visible en pista tras 2 intentos |
| Símbolos | glifo, pedestal | sello de puerta | glosario M25 (inscripciones) |
| Ambientales | viento (M32), lluvia, criatura (M65) | puerta de viento, rama | condición climática activa |
| Herramientas | pico, gancho, farol | grieta, pasarela, techo | inventario presente |
| Multilateral | estado de sala compartido | puerta final | mapa-emisor central |

## Sistema de ayuda (Guía del Templo)

1. **0 fallos:** pista ambiental en el diario (icono).
2. **3 fallos / 90 s sin progreso:** pista textual de la familia (ej: "los espejos giran en múltiplos de 45°").
3. **Pista 2:** indica el emisor exacto a activar.
4. **Pista 3 / 5 min sin progreso:** solución paso a paso (una por acordeón).
5. Nunca se penaliza usar ayuda; el jugador elige cuándo consultar.

El sistema respeta "nunca arbitrarios": toda pista está anclada a una regla del grafo (se genera desde datos, no texto suelto).

## Dificultad

| Banda | Zonas | Características |
|---|---|---|
| Exploración | exteriores, ruinas pequeñas (M25) | 1-2 emisores, familia visible, pista en 90 s |
| Ritual | templos medianos | 2-4 emisores, 1 familia oculta, pista en 60 s |
| Antiguo | templo subterráneo (M26), finales | multilaterales, 2 familias, pista en 45 s |

## Checkpoints y reinicio (contrato M66)

- `PuzzleState` serializa: vector de sala, posición de jugador frente al puzzle, recompensas pendientes.
- Guardado en checkpoint de sala (atomico tmp+rename+.bak) y cada 60 s si el jugador está dentro de un puzzle.
- Reinicio: a pedido (botón en Guía del Templo si el puzzle está irresoluble) o automático a los 30 s de diagnóstico inválido (M66).
- Recompensas: 1 sola vez; el cofre de M66 no duplica (slot inmutable).

## UI / Feedbacks (hooks)

- Marco de puzzle activo + nombre (iconografía del templo), brújula de pista en el diario.
- Efecto "casi solución" (parpadeo sutil de receptor a 1 paso).
- Toast de progreso de puzzle (M57, baja prioridad, sin spam).
- M43: cues de activación/fallo con cooldowns.

## Rendimiento y QA

- Framework datos-driven: cada puzzle = archivo JSON/YAML serializable; runtime ≤ 1 ms por tick (sin allocations).
- Validación en Editor (armado) + tests automáticos por familia + playtests externos con métricas de tiempo/pistas/abandonos.
- Suite de integración con M66 (reinicio), M08 (terreno alterado), M13 (framework emisor→receptor, dependencia).