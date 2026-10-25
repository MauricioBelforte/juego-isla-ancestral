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

## Specs Herramientas (Beam 668)

### RF5: martillo (construir) y lupa (inspeccionar -> contenido M26/M44)
- Spec: RF5: martillo (construir) y lupa (inspeccionar -> contenido M26/M44). Coherente with M13 (herramientas) and M06 (puzzles).

### Regadera: riega cultivos (20 usos por llenado -> mecanica M33)
- Spec: regadera: riega cultivos (20 usos por llenado -> mecanica M33). Coherente with M13 (herramientas) and M33 (agricultura).

### Cana de pescar: pesca en agua (M35 mini-juego)
- Spec: cana de pescar: pesca en agua (M35 mini-juego). Coherente with M13 (herramientas) and M34 (pesca).

### Tijeras: recolectan fibras sin destruir la raiz (M50)
- Spec: tijeras: recolectan fibras sin destruir la raiz (M50). Coherente with M13 (herramientas) and M50 (vegetacion).

### Lupa: inspecciona glifos/criaturas (M26/M44)
- Spec: lupa: inspecciona glifos/criaturas (M26/M44). Coherente with M13 (herramientas) and M26 (templos).


## Specs Herramientas (Beam 669)

### Regadera requiere agua cercana para llenarse (M33)
- Spec: regadera requiere agua cercana para llenarse (M33). Coherente with M13 (herramientas) and M33 (agricultura).

### Cana evoluciona a red (progresion pesca M35)
- Spec: cana evoluciona a red (progresion pesca M35). Coherente with M13 (herramientas) and M34 (pesca).

### Nivel 2 Hierro: receta M16 + hierro (M46)
- Spec: nivel 2 Hierro: receta M16 + hierro (M46). Coherente with M13 (herramientas) and M16 (crafting).

### Nivel 3 Oro: receta M16 + oro profundo (M46)
- Spec: nivel 3 Oro: receta M16 + oro profundo (M46). Coherente with M13 (herramientas) and M16 (crafting).

### Nivel 4 Cristal: receta M16 + cristal de Resonancia (M46)
- Spec: nivel 4 Cristal: receta M16 + cristal de Resonancia (M46). Coherente with M13 (herramientas) and M16 (crafting).


## Specs Herramientas (Beam 670)

### Mejoras fabricadas en mesa de trabajo (M16)
- Spec: mejoras fabricadas en mesa de trabajo (M16). Coherente with M13 (herramientas) and M16 (crafting).

### Progresion visible (apariencia + brillo por nivel -> M45/M65 assets)
- Spec: progresion visible (apariencia + brillo por nivel -> M45/M65 assets). Coherente with M13 (herramientas) and M45 (arte 2D).

### Logros: "Primera herramienta", "Herrero", "Cristal" (M71)
- Spec: logros: "Primera herramienta", "Herrero", "Cristal" (M71). Coherente with M13 (herramientas) and M71 (progresion).

### Reparacion gratis con recursos del mundo (mesa M16)
- Spec: reparacion gratis con recursos del mundo (mesa M16). Coherente with M13 (herramientas) and M16 (crafting).

### Costo de reparacion = 1/2 costo de fabricacion (campo receta_reparacion listo; tabla M16)
- Spec: costo de reparacion = 1/2 costo de fabricacion (campo receta_reparacion listo; tabla M16). Coherente with M13 (herramientas) and M16 (crafting).


## Specs Herramientas (Beam 670b)

### Reparacion instantanea en la mesa (sin minijuego -> M16)
- Spec: reparacion instantanea en la mesa (sin minijuego -> M16). Coherente with M13 (herramientas) and M16 (crafting).

### Reparacion alternativa en el herrero (NPC M19)
- Spec: reparacion alternativa en el herrero (NPC M19). Coherente with M13 (herramientas) and M19 (amistad).

### Regla: siempre hay camino de reparacion cerca (mesa del pueblo -> M16/M27)
- Spec: regla: siempre hay camino de reparacion cerca (mesa del pueblo -> M16/M27). Coherente with M13 (herramientas) and M27 (islas).

### Overflow de drops -> caja mas cercana (M14)
- Spec: overflow de drops -> caja mas cercana (M14). Coherente with M13 (herramientas) and M14 (recursos).

### Hacha usa contrato vegetacion (M50; por ahora voxels de madera)
- Spec: hacha usa contrato vegetacion (M50; por ahora voxels de madera). Coherente with M13 (herramientas) and M50 (vegetacion).


## Specs Herramientas (Beam 671)

### Azada/regadera usan parcelas de M33
- Spec: azada/regadera usan parcelas de M33. Coherente with M13 (herramientas) and M33 (agricultura).

### Cana usa M35, lupa M26/M44
- Spec: cana usa M35, lupa M26/M44. Coherente with M13 (herramientas) and M34 (pesca).

### Tierras de cultivo: la azada marca la parcela en GameState.M33
- Spec: tierras de cultivo: la azada marca la parcela en GameState.M33 (no toca el voxel -> M33). Coherente with M13 (herramientas) and M33 (agricultura).

### El martillo solo coloca en zonas validas (check de AIR; reglas de zonas -> M08/M17)
- Spec: el martillo solo coloca en zonas validas (check de AIR; reglas de zonas -> M08/M17). Coherente with M13 (herramientas) and M17 (construccion).

### Acercamiento de camara 3.5 m durante el uso (M12)
- Spec: acercamiento de camara 3.5 m durante el uso (M12). Coherente with M13 (herramientas) and M10 (personaje).


## Specs Herramientas (Beam 672)

### Vuelta a distancia elegida al soltar (M12)
- Spec: vuelta a distancia elegida al soltar (M12). Coherente with M13 (herramientas) and M10 (personaje).

### Vibracion al golpear (dispositivo con haptics -> fase plataformas)
- Spec: vibracion al golpear (dispositivo con haptics -> fase plataformas). Coherente with M13 (herramientas) and M56 (interfaz).

### Prompt [F] muestra la herramienta recomendada cuando aplica (M53/M19)
- Spec: prompt [F] muestra la herramienta recomendada cuando aplica (M53/M19). Coherente with M13 (herramientas) and M53 (UI).

### Stamina de M11 queda solo para sprint (M11)
- Spec: stamina de M11 queda solo para sprint (M11). Coherente with M13 (herramientas) and M11 (movimiento).

### Tutorial contextual: primera azada y cana en prologo (M22)
- Spec: tutorial contextual: primera azada y cana en prologo (M22). Coherente with M13 (herramientas) and M22 (historia).


## Specs Herramientas (Beam 673)

### Compatible con cultivos (M33: azada/regadera)
- Spec: compatible con cultivos (M33: azada/regadera). Coherente with M13 (herramientas) and M33 (agricultura).

### Compatible con mineria (M46: tipos de mineral por profundidad)
- Spec: compatible con mineria (M46: tipos de mineral por profundidad). Coherente with M13 (herramientas) and M35 (mineria).

### Red de pesca como herramienta post-progresion (M35 la consume)
- Spec: red de pesca como herramienta post-progresion (M35 la consume). Coherente with M13 (herramientas) and M34 (pesca).
