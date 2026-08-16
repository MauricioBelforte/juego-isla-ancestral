**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 13: Herramientas

## 1. Análisis de los puntos del plan maestro (sección 12)

| # | Punto | Resolución |
|---|---|---|
| 1 | Herramientas básicas | ✅ 9 herramientas: pico, azada, hacha, pala, regadera, caña, martillo, tijeras, lupa |
| 2 | Niveles | ✅ Cobre → Hierro → Oro → Cristal (4 niveles progresivos atados a M46) |
| 3 | Durabilidad | ✅ Cada herramienta tiene durabilidad; NUNCA se rompe: llega a 1 y queda inservible hasta reparar |
| 4 | Reparación | ✅ Gratis en casa/mesa de trabajo con recursos del mundo (M16/M17) |
| 5 | Energía de uso | ⏸ Sin gasto de energía propia (stamina de M11 cubre el sprint); el desgaste es por uso |
| 6 | Alcance | ✅ 4 m (rayo de M11) |
| 7 | Velocidad por nivel | ✅ T₂×0.8, T₃×0.65, T₄×0.5 (tiempo de extracción base 1 s) |
| 8 | Área | ✅ nivel 3+: área 3×3 (pico/pala) |
| 9 | Sonidos | ✅ por material (piedra, tierra, madera, agua) |
| 10 | Partículas | ✅ por tipo de bloque (polvo, chispas, gotas al regar) |
| 11 | Herramienta de mano | ✅ Martillo (M17), lupa (M26) |
| 12 | Rango | ✅ interact via InteractionService (4 m) |
| 13 | Mejora | ✅ Cada nivel se fabrica con receta (M16) + recursos (M46) — progresión visible |
| 14 | Reparación estética | ✅ Al reparar en mesa: brillo + sonido |
| 15 | Pico | ✅ Extrae piedra/minerales; bloques de piedra → 2-6 golpes según bloque |
| 16 | Azada | ✅ Prepara tierra para sembrar (labrado 1×1; mejorada 3×3) |
| 17 | Hacha | ✅ Tala árboles (tronco de 4-6 bloques ×1.5 s) |
| 18 | Pala | ✅ Excava la tierra/arena/barro (1-2 golpes) |
| 19 | Regadera | ✅ Riega cultivos (agua de río/lago; 20 usos por llenado) |
| 20 | Caña de pescar | ✅ Pesca en agua (mini-juego de espera y botón, M35); se mejora caña→red |
| 21 | Martillo | ✅ Modo construir (M17): rotar, colocar, arreglar |
| 22 | Tijeras | ✅ Recolectan fibras/plantas (sin destruir raíz) |
| 23 | Lupa | ✅ Inspecciona: glifos, criaturas, puzzles (M26/M44) |
| 24 | Almacenamiento | ✅ Se guardan en el inventario (M14); 1 por slot herramienta (6 slots dedicados) |
| 25 | Logros | ✅ "Herramienta de cristal alcanzada" (M71 sugiere) |
| 26 | Tutorías | ✅ Primeras herramientas como recompensa de inicio (M22); tutorial contextual (M57) |
| 27 | Balance | ✅ Tabla de tiempos por bloque y nivel documentada (a afinar en M1) |

## 2. Tabla de durabilidad (usos antes de reparar)

| Herramienta | Cobre | Hierro | Oro | Cristal |
|---|---|---|---|---|
| Pico | 60 | 110 | 180 | 300 |
| Azada | 50 | 100 | 160 | 260 |
| Hacha | 55 | 105 | 170 | 280 |
| Pala | 60 | 110 | 180 | 300 |
| Regadera | 40 | 70 | 120 | 200 |
| Caña | 30 | 55 | 90 | 150 |
| Martillo | ∞ | ∞ | ∞ | ∞ |
| Tijeras | 45 | 85 | 140 | 230 |
| Lupa | ∞ | ∞ | ∞ | ∞ |

- Martillo y lupa: durabilidad infinita (herramientas de inteligencia, no de fuerza).
- Reparación: costo = 1/2 del costo de fabricación en materiales base (M16).

## 3. Fórmula de desgaste y tiempo

```
tiempo_extracción(bloque, nivel) = tiempo_base(bloque) × factor(nivel)
factor: T1=1.0, T2=0.8, T3=0.65, T4=0.5
desgaste por uso = 1 (fijo; sin aleatoriedad — determinista, regla cozy)
área 3×3 activa desde T3 (pico, azada, pala) con click sostenido
```

## 4. Decisiones y alternativas

- **Sin rotura total:** descartada la mecánica "se rompe y desaparece" (frustración); reparación gratis con recursos.
- **Sin durabilidad aleatoria:** determinista por uso (predecible, amable).
- **Martillo/lupa infinitos:** las herramientas "de conocimiento" no se desgastan (premio a la exploración).
- **Energía de uso:** el desgaste no consume energía del personaje (M11 stamina es solo sprint) — el mundo no pide "mana".
- **Caña→red:** la mejora de pesca es una evolución de herramienta (M35 detalla el mini-juego).