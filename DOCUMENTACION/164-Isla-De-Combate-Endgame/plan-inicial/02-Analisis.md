**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 02-Analisis.md — Modulo 164: Isla de Combate Endgame

## 1. Analisis del Dominio

###flujo del jugador

```
Jugador completa juego principal (o alcanza progresion avanzada)
  → Obtiene herramientas encantadas (M163)
  → Las intercambia por gemas en NPC especial
  → Viaja a isla de combate (M28)
  → Accede a zona Costa (gratis)
  → Combate mobs basicos, obtiene gemas
  → Acumula gemas para zona Bosque
  → Combate mobs medianos, obtiene mas gemas
  → Acumula gemas para zona Montaña
  → Combate jefe 1, obtiene recompensas
  → Acumula gemas para zona Templo
  → Combate jefe final, obtiene recompensas exclusivas
```

### Economia de gemas

| Fuente | Gemas | Esfuerzo |
|--------|-------|----------|
| Intercambiar herramienta T1 encantada | 1 gema | Bajo |
| Intercambiar herramienta T2 encantada | 2 gemas | Medio |
| Intercambiar herramienta T3 encantada | 3 gemas | Alto |
| Intercambiar herramienta T4 encantada | 5 gemas | Muy alto |
| Derrotar mob basico | 1 gema | Combate |
| Derrotar mob mediano | 2 gemas | Combate |
| Derrotar jefe | 5-10 gemas | Combate dificil |
| Completar desafio | 3-7 gemas | Exploracion |
| Comprar Steam | 1-20 gemas | Dinero real |

### Decisiones de diseno

**D1: Isla es opcional.** El jugador que solo quiere vivir en su pueblo y pescar puede ignorar la isla completamente. Ninguna recompensa de la isla es necesaria para el juego principal.

**D2: Sin game over.** Si el jugador "pierde" un combate, vuelve al pueblo sin penalidad. No se pierden objetos, no hay muerte permanente.

**D3: Recompensas cosmeticas.** Las recompensas exclusivas son cosmeticas (skins, titulos, decoraciones). No dan ventajas mecanicas en el juego principal.

**D4: Gema como moneda de acceso.** Cada zona de la isla requiere cierta cantidad de gemas para desbloquear. Esto crea progresion dentro de la isla.

**D5: Combate simple pero satisfactorio.** Los enemigos tienen IA basica pero patrones interesantes. No es un juego de combate complejo, pero se siente bien.

## 2. Analisis de Alternativas

**Alternativa A: Isla con puzzles de combate** - Descartada (complica el sistema cozy)

**Alternativa B: Isla con enemigos y jefes** - ELEGIDA (satisfactoria, clara, opcional)

**Alternativa C: Isla con torre de enemigos** - Descartada (puede frustrar, no cozy)

## 3. Matriz de Dependencias

- M158 (Tiers) → M164 (Acceso con herramientas)
- M163 (Encantamientos) → M164 (Fuente de gemas)
- M22 (Historia) → M164 (Contexto narrativo)
- M27 (Islas) → M164 (Estructura de isla)
- M38 (Economia) → M164 (Sistema de gemas)
- M164 → M71 (Progresion: hitos de combate)
- M164 → M72 (Logros: logros de combate)
