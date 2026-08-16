**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 13: Herramientas

## 1. Arquitectura

```
Tool (Resource)
├── id, nombre (localizable M57), rareza
├── tipo: PICO | AZADA | HACHA | PALA | REGADERA | CAÑA | MARTILLO | TIJERAS | LUPA
├── nivel: 1-4 (cobre, hierro, oro, cristal)
├── durabilidad_max, factor_tiempo, area_extraccion (1×1 / 3×3)
├── acciones_permitidas: extract, till, chop, dig, water, fish, build, inspect, shear
└── receta_reparacion: [RecursoCantidad] (costo = ½ fabricación, M16)
```

- Instancias con durabilidad propia viven en el inventario (M14) como `ToolItem` (M14 slot de 6).

## 2. Acciones por herramienta

| Herramienta | Acción | Guarda contrato en | Notas |
|---|---|---|---|
| Pico | `try_extract(bloque)` | M08 (contrato) | golpes 2-6 según dureza |
| Azada | `till(parcela)` | M33 (cultivo) | labrado 1×1³ (3×3 desde T3) |
| Hacha | `try_extract(arbol)` | M50 (vegetación) | tronco completo 1.5 s |
| Pala | `try_extract(tierra/arena/barro)` | M08 | 1-2 golpes |
| Regadera | `water(parcela)` | M33 | 20 usos por llenado (agua cercana) |
| Caña | `fish(agua)` | M35 | mini-juego (M35) |
| Martillo | `build/rotate/repair` | M17 | durabilidad ∞ |
| Tijeras | `shear(planta)` | M50 | sin destruir raíz |
| Lupa | `inspect(glifo/criatura)` | M26/M44 | durabilidad ∞ |

## 3. Contrato con M08 (extracción)

```
WorldVoxel.extract(pos) → (BlockId extraido, drops[], diff)   # M08
WorldVoxel.place(pos, BlockId, metadata) → diff
```

- El pico/pala usan `extract`; el martillo usa `place` (M17).
- Los drops van directos al inventario de bolsillo (M14) con regla de overflow → caja más cercana.
- El diffs generado se aplica al WorldPartition (M08) — NUNCA doble escritura.

## 4. Mejoras y progresión

- Nivel 2 (hierro): se fabrica con receta M16 + mineral de hierro (M46).
- Nivel 3 (oro): receta + oro (M46, profundo).
- Nivel 4 (cristal): receta + cristal de Resonancia (M46 especial).
- La mesa de trabajo (M16) repara y mejora; costo de reparación = ½ fabricación.
- Logros: "Primera herramienta", "Herrero", "Cristal de Resonancia" (M71).

## 5. Feedback perceptivo (sin penalización)

- Sonido por material (piedra/tierra/madera/agua).
- Partículas por acción (polvo de excavación, chispas en mineral, gotas de agua al regar).
- Punto de mira: el recurso "late" si la herramienta equipada es aplicable (brillo al 60% del umbral).
- Al 20% de durabilidad: icono de reparación en el HUD + el mango parpadea (aviso, no castigo).
- Ajuste de cámara (M12): acercamiento a 3.5 m durante el uso.

## 6. Tutorías y balance de tiempos (base)

| Bloque | T1 pico | T2 | T3 | T4 |
|---|---|---|---|---|
| Tierra | 0.6 s | 0.5 | 0.4 | 0.3 |
| Piedra | 1.0 s | 0.8 | 0.65 | 0.5 |
| Mineral | 1.5 s | 1.2 | 1.0 | 0.75 |
| Tronco | 1.5 s | 1.2 | 1.0 | 0.75 |

- Tutorial contextual: la primera azada y la primera caña llegan por el prólogo (M22/Hana).
- Sin herramientas atascadas: siempre hay un camino para reparar cerca (mesa de pueblo M16).

## 7. Durabilidad y reparación (reglas cozy)

- La durabilidad baja de a 1 por uso; NUNCA 0 → herramienta inservible hasta reparar (no desaparece).
- Reparar = gastar materiales + ir a la mesa de trabajo (M16) o al herrero (NPC, M19).
- La reparación es instantánea en la mesa (sin minijuego) — cozy.
- Durabilidad y reparación se persisten en GameState.M13 (M59).