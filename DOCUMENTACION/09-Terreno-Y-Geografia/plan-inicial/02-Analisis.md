**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 09: Terreno y Geografía

## 1. Análisis de los 25 puntos del plan maestro (sección 8)

| # | Punto | Resolución |
|---|---|---|
| 1 | Montañas | ✅ Receta: crestas con clavos; bloqueo de nieve estacional arriba |
| 2 | Valles | ✅ Depresiones anchas con río central (agricultura M33) |
| 3 | Playas | ✅ Banda de arena inclinada 5-10 bloques hacia el agua |
| 4 | Acantilados | ✅ Paredes de piedra con lava-costeras; acceso solo por caminos/puentes |
| 5 | Ríos | ✅ Curvas suaves (spline) de 2-4 bloques de ancho, profundidad 1-2 |
| 6 | Lagos | ✅ Depresiones con agua nivel + borde de barro |
| 7 | Cascadas | ✅ Donde río corta acantilado (agua en cascada visual) |
| 8 | Cuevas | ✅ Subterráneas de roca con entradas a nivel de ríos/acantilados |
| 9 | Túneles | ✅ Conectan zonas (lado - lado de montaña) |
| 10 | Cañones | ✅ Grietas profundas para templos/escondites (la GRAN GRIETA de Aurora) |
| 11 | Bosques | ✅ Zonas densas de troncos + copa (M50) |
| 12 | Praderas | ✅ Césped abierto, ideal para construcción |
| 13 | Humedales | ✅ Barro + agua superficial + juncos (flora específica) |
| 14 | Desiertos | ✅ Arena + dunas suaves (islas viaje / zonas áridas) |
| 15 | Zonas nevadas | ✅ Steppe de nieve + hielo (cumbres) |
| 16 | Zonas volcánicas | ✅ Volcán PACÍFICO (sin destrucción): colinas negras + vapor — narrativa cero violencia |
| 17 | Zonas tropicales | ✅ Palmas, arena clara, agua turquesa (Isla Coral) |
| 18 | Zonas costeras | ✅ Perímetro completo: playa + acantilado + puerto |
| 19 | Biomas especiales | ✅ Ruinas antiguas (zonas de piedra estructurada) + zona de Resonancia (cristales) |
| 20 | Transición de biomas | ✅ Mezcla por altura/humedad con rampas (no fronteras lineales) |
| 21 | Altura de terreno | ✅ Reglas por bioma (costa 0-15, colinas 15-60, montañas 60-120, cumbres 120+) |
| 22 | Erosión visual | ✅ Bordes suavizados con bloques auxiliares (detalle en la receta) |
| 23 | Elementos naturales | ✅ Rocas sueltas, raíces, musgo — colocación procedural decorativa |
| 24 | Puntos panorámicos | ✅ Miradores: cumbres, faro, puente del puerto |
| 25 | Puntos de interés | ✅ Faro, puerto, plaza del pueblo, granja, grieta, templos, canteras |

## 2. Geografía de Aurora (isla inicial) — esbozo

```
        [Norte] Cumbres nevadas (mirador) ── Tunel
             │
    Bosque denso ─────── Gran Grieta (acantilados 2) ── Templo de la Brisa
             │                │
    Ríos ─────── Valle (pueblo + granja) ─────── Pradera (expansión)
             │                │
    Humedal + lago ────── Puerto (muelle) ── Faro (apagado) [misterio inicial]
             │                │
        [Sur] Playas de arena ──── Arrecife cercano (buceo roadmap)
```

- El **faro apagado** al sur-este: progresión del prólogo (M22).
- La **gran grieta** en el centro-norte: acceso al templo tras semana 2 (GDD journey).
- Los **acantilados oeste** protegen la costa (imposible rodear sin puente de Finneas → infraestructura M40).

## 3. Receta geográfica genérica (plantilla por formación)

```
Formación { nombre, biomas_fuente, posición (relativa), tamaño (m),
  alturas (inicio/cresta), material (BlockId), modificadores de ruido,
  reglas de mezcla, elementos_decorativos, puntos_de_interes, restricciones }
```

- Aurora, Coral, Verde, Nieve, Volcánica (roading oficial post-v1.0) comparten la misma biblia de recetas → sostenibilidad (GDD §5).

## 4. Decisiones y alternativas

- **Híbrido manual+procedural:** el artista/diseñador define recetas y zonas (marco); el generador rellena con ruido (M10). Descartado 100% procedural: pierde carácter narrativo.
- **Alturas por bioma** (no generación libre): garantiza zonas jugables y visuales legibles.
- **Volcán pacífico:** vapor+colores cálidos, sin destrucción — coherencia con filosofía cero violencia.
- **Cascadas:** solo donde existe diferencia de altura real (regla de flujo = evita cascadas imposibles).