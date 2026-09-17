# Log 807: M09/M49/M57 — cierre de sesión de horizonte: impostores duales + fades + zoom verificados

**Fecha:** 2026-09-09
**Hora:** 20:55
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Cierre formal de la sesión de visión lejana. El usuario confirmó:
- **"Bueno ya no se traba ni se buguea, ahora tenemos que trabajar en los impostores de nuevo... anduvo muchísimo mejor, paseo mucho tiempo sin tildarse"** — el criterio de validación anti-tildes CUMPLIDO (Log 798).
- **"Ahora sí están en el lugar correcto"** (montañas impostoras, Log 791-793).
- **"El impostor de las montañas verticales lo veo"** — el heightmap final (Log 795-797) confirmado por el usuario.

## El sistema de horizonte FINAL (3 capas, documentado en 07-GUIA-GODOT §13)

| Capa | Detalle | Fade |
|---|---|---|
| Chunks voxel reales | Detallados a 1024m alrededor del player | — |
| Impostor de montañas | Escalera voxel r 700 de (2660,2580), cimas ×4, ~200m | Invisible <1100m, pleno >1800m |
| Plano verde uniforme | Disco plano a y=4.3 sobre el agua azul, r 0-2600, 11 anillos | Invisible <700m, pleno >1500m |

## Fixes de esta sesión final
1. **Muro perimetral del disco verde** (visible de canto desde lejos).
2. **Suelo fantasma agua/tierra** (nadar en la superficie vs apoyar en el terreno).
3. **Zoom de cámara verificado** (operativo — nunca estuvo roto).
4. **Scroll del minimapa solo con el mouse encima** (antes robaba el zoom de cámara).
5. **Switch bot/humano** en el bot de paseo (`-- paseo`).
6. **Anti-tilde**: generación por columnas + chunks 512m + materiales opacos + fade binario.

## Pendientes (próxima sesión)
- Confirmación visual del usuario del conjunto completo (montañas + plano verde + agua).
- Calibración de colores del plano verde si el usuario lo pide.
- El bot de paseo con teclas simuladas no camina (movimiento relativo a cámara que el bot no rota) — refinamiento del bot, NO del juego.

## Estado final
- FPS 60 estable, 0 errores, sin tildes.
- ULTIMO_NUMERO=807 (758-806 firmados).
- Godot detenido, autoloads de test limpios, proyecto listo para el usuario.
