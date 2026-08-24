**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 158: Herramientas y Desbloqueo de Zonas

## ID del Módulo
- **Código:** M158
- **Carpeta:** `DOCUMENTACION/158-Herramientas-Y-Desbloqueo-De-Zonas/`
- **Dependencias:** M13 (Herramientas), M38 (Economía), M27 (Islas), M28 (Viajes), M71 (Progresión)
- **Relaciones:** M25 (Ruinas), M24 (Templos y Puzzles), M22 (Historia Principal), M26 (Templo Subterráneo), M95 (Monetización)

## 1. Problema

El jugador necesita una progresión clara de herramientas que desbloquee contenido en el mundo, pero sin copiar la fórmula de Zelda (llave开门). Cada isla del archipiélago tiene una profesión especializada (carpintero, herrero, herrero avanzado, cristalero) que ofrece herramientas de mayor tier a cambio de materiales + monedas. El jugador debe poder elegir su ritmo: explorar y resolver todo manualmente, o pagar dinero real para avanzar más rápido. La historia principal REQUIERE herramientas hasta tier 4 para completarse. Los encantamientos son una capa adicional lateral (cualquier tier se puede encantar).

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | 4 tiers de herramientas | Cobre (T1) → Hierro (T2) → Oro (T3) → Cristal (T4). Cada tier desbloquea nuevo contenido |
| RF2 | T1 se obtiene en isla principal | El carpintero te regala 1 herramienta de cobre al inicio (tutorial), o comprás en tienda |
| RF3 | T2-T4 se obtienen en islas distintas | Cada isla tiene un profesional especializado que forja el tier correspondiente |
| RF4 | Requisito de forja: materiales + monedas | El jugador lleva materiales de la isla + paga monedas por el servicio de forja |
| RF5 | Cada isla = precios progresivamente más caros | Isla principal (barato) → Isla 2 (medio) → Isla 3 (caro) → Isla 4 (muy caro) |
| RF6 | Cursos para aprender oficios | Carpintero (Isla Raíz), Herrería (Isla Ceniza), Herrería Avanzada (Isla Coral), Cristalería (Isla Aurora). Cursos progresivos, permiten forjar herramientas de ese tier |
| RF7 | La tienda del jugador vende herramientas | NPCs visitantes compran 1×/día las herramientas/crafts del jugador |
| RF8 | La historia requiere T4 | Los templos finales y sellos de la historia necesitan herramientas de cristal (T4) |
| RF9 | Ruta de exploración no lineal | El jugador elige qué isla visitar primero; no hay ruta obligatoria lineal |
| RF10 | Construcción en otras islas | El jugador puede construir casas en islas visitadas y quedarse a trabajar allí |
| RF11 | Tier 1 = exploración básica | Ramas, piedras sueltas, jarrones, árboles pequeños (herramientas de cobre del carpintero) |
| RF12 | Tier 2 = muros de piedra, raíces gruesas | Desbloquea caminos nuevos, pueblos ocultos dentro de la isla principal (herramientas de hierro del herrero) |
| RF13 | Tier 3 = sellos ancestrales, puertas de templo | Desbloquea templos y contenido avanzado de la historia (herramientas de oro del herrero avanzado) |
| RF14 | Tier 4 = cámaras secretas, zonas encantadas | Contenido final de la historia, lore oculto, final secreto (herramientas de cristal del cristalero) |
| RF15 | Compra premium (dinero real) | El jugador puede comprar monedas por Steam para saltarse el grind |
| RF16 | Sin premium = progresión manual | El jugador que no paga debe resolver puzzles, buscar jarrones, pescar, vender |
| RF17 | Jarrones se reponen semanalmente | Fuente de monedas diaria limitada pero constante |
| RF18 | Múltiples fuentes de ingreso | Pescar (oro suelto), jarrones, árboles (frutos valiosos), vender en tienda, NPCs visitantes |
| RF19 | No hay bloqueo permanente | Si el jugador quiere solo vivir en su pueblo y pescar, puede hacerlo. Las herramientas son OPCIONALES para la vida diaria |
| RF20 | Ruta de progresión flexible | No lineal como Zelda; el jugador puede ir y venir entre islas como quiera |

## 3. Requisitos No Funcionales

- **Cozy:** sin estrés por no tener dinero; siempre hay algo que hacer en la isla principal
- **No-copia de Zelda:** no hay llaves que开门; las herramientas desbloquean contenido, no puertas específicas
- **Persistencia:** tier alcanzado, monedas, materiales y cursos aprendidos se guardan en GameState
- **Data-driven:** tablas de costos, materiales y desbloqueos en Resources (.tres)
- **Desacoplamiento:** el sistema de gates no conoce la UI; comunica por señales

## 4. Criterios de Aceptación

1. El jugador obtiene T1 (cobre) del carpintero en Isla Raíz al inicio del juego
2. El jugador puede viajar a Isla Ceniza con un boleto (M28) y forjar T2 (hierro) pagando materiales + monedas
3. Cada isla subsiguiente tiene precios ≥50% más caros que la anterior
4. Los templos de la historia principal no se pueden completar sin T3/T4
5. El jugador premium puede comprar monedas y saltarse el grind de recolección
6. Jarrones se reponen cada 7 días del juego (M29 calendario)
7. NPCs visitantes compran herramientas del jugador 1×/día
8. El jugador puede construir en otras islas y quedarse a vivir allí
9. La progresión no es lineal: el jugador puede visitar islas en cualquier orden
10. Los encantamientos son opcionales y laterales: cualquier tier se puede encantar (chamán del monte)

## 5. Alcance

**Dentro del alcance:** sistema de tiers de herramientas, gates por tier en el mundo, sistema de forja por isla, costos progresivos, cursos de oficio, venta de herramientas del jugador, progresión de la historia ligada a tiers, fuentes de ingreso del jugador, integración premium.

**Fuera del alcance:** el sistema base de herramientas (M13), las tiendas NPCs (M39 se expande aparte), la economía general (M38 se expande aparte), los viajes entre islas (M28), la definición de islas (M27).

---

## L. MAPA DE PROGRESION COMPLETO (2026-08-23 — tiers unificados)

### L.1 Estructura del Mundo

```
ISLA RAIZ (Principal) — costos baratos
├── Pueblo central
│   ├── Carpintero (regala T1 cobre al inicio, vende herramientas, curso 300 monedas)
│   ├── Tiendas del pueblo (M39)
│   ├── Casa del jugador (M18)
│   └── Muelle del barco (M28)
├── Zonas explorables
│   ├── Bosque (ramas, piedras, jarrones)
│   ├── Costa (pescado, oro suelto)
│   ├── Ruinas cercanas (puzzles T1)
│   └── Montana (minerales basicos, chaman del monte)
└── Gates T1
    ├── Rama gruesa -> bosque profundo
    ├── Muro suave -> cueva pequena
    └── Raiz -> sendero oculto

ISLA CENIZA — boleto 100 monedas
├── Puerto costero
│   ├── Herrero (vende T2 hierro, curso 1500 monedas)
│   ├── Tiendas de Ceniza
│   └── Pueblo minero
├── Zonas explorables
│   ├── Minas (hierro, carbon, minerales)
│   ├── Desierto ceniza (fosiles, obsidiana)
│   ├── Pueblo oculto (desbloqueado con T2)
│   └── Ruinas volcanicas (puzzles T2)
└── Gates T2
    ├── Muro de piedra -> pueblo oculto
    ├── Raiz gruesa -> cueva de obsidiana
    └── Sello debil -> pasaje subterraneo

ISLA CORAL — boleto 300 monedas
├── Costa tropical
│   ├── Herrero Avanzado (vende T3 oro, curso 5000 monedas)
│   ├── Sanador (compra plantas medicinales)
│   └── Explorador (guia de arrecife)
├── Zonas explorables
│   ├── Arrecife (coral, perlas, oro suelto)
│   ├── Playa (conchas, arena dorada)
│   ├── Ruinas antiguas (puzzles T3, lore)
│   └── Templo Sumergido (requiere T3)
└── Gates T3
    ├── Sello ancestral -> templo principal
    ├── Muro de raices -> selva prohibida
    └── Cristal crecido -> camara del sabio

ISLA AURORA — boleto 800 monedas
├── Cumbres y valles
│   ├── Cristalero (vende T4 cristal, curso 10000 monedas)
│   ├── Sabio (lore y secretos)
│   └── Mercader de rarezas
├── Zonas explorables
│   ├── Montanas cristalinas (cristales, minerales raros)
│   ├── Templo del Alba (puzzles T4, sellos finales)
│   ├── Camara secreta (lore oculto, final secreto)
│   └── Grieta del mundo (zona mas dificil)
└── Gates T4
    ├── Sello de cristal -> templo final
    ├── Cristal bloqueado -> camara secreta
    └── Tumba ancestral -> lore oculto
```

### L.2 Flujo del Jugador Ejemplo

```
Dia 1-3: Isla Raiz
  -> Recibe T1 (cobre) del carpintero
  -> Recolecta ramas, piedras, jarrones
  -> Pesca, vende en tienda
  -> Compra boleto (100 monedas) para Isla Ceniza

Dia 4-7: Isla Ceniza
  -> Forja T2 (hierro) con herrero (500 monedas + 10 hierro)
  -> Explora pueblo oculto (desbloqueado con T2)
  -> Aprende a vender herramientas
  -> Compra boleto (300 monedas) para Isla Coral

Dia 8-14: Isla Coral
  -> Forja T3 (oro) con herrero avanzado (2000 monedas + 20 oro)
  -> Explora ruinas antiguas (puzzles T3)
  -> Descubre lore de la historia principal
  -> Compra boleto (800 monedas) para Isla Aurora

Dia 15-21: Isla Aurora
  -> Forja T4 (cristal) con cristalero (5000 monedas + 5 cristales)
  -> Completa historia principal (requiere T4)
  -> Descubre final secreto

OPCIONAL: Encantamientos
  -> Recoge incienso (cultivo o eventos)
  -> Visita chaman del monte (Isla Raiz)
  -> Encanta herramienta (cualquier tier)
  -> Vende encantamiento en tienda especializada (precio premium)
```

### L.3 Tabla Resumen de Profesiones por Isla

| Isla | Profesion | Tier que forja | Material | Costo aprox. | Curso |
|------|-----------|----------------|----------|--------------|-------|
| Raiz | Carpintero | T1 Cobre | Cobre | Gratis (regalo inicial) | 300 monedas |
| Ceniza | Herrero | T2 Hierro | Hierro | 500 monedas + 10 hierro | 1500 monedas |
| Coral | Herrero Avanzado | T3 Oro | Oro | 2000 monedas + 20 oro | 5000 monedas |
| Aurora | Cristalero | T4 Cristal | Cristal | 5000 monedas + 5 cristales | 10000 monedas |

### L.4 Tabla de Gates por Tier

| Tier | Material | Gate ejemplo | Contenido desbloqueado |
|------|----------|--------------|------------------------|
| T1 | Cobre | Rama gruesa | Bosque profundo, cueva pequena |
| T2 | Hierro | Muro de piedra | Pueblo oculto, minas profundas |
| T3 | Oro | Sello ancestral | Templos, ruinas antiguas, lore |
| T4 | Cristal | Sello de cristal | Templo final, camara secreta, final |

### L.5 Reglas de Progresion

1. **No hay orden obligatorio:** el jugador puede ir a cualquier isla que haya desbloqueado
2. **Cada isla es independiente:** no hay contenido bloqueado por isla anterior
3. **El dinero es el gating principal:** el jugador debe juntar monedas para viajar y forjar
4. **Las herramientas son el gating secundario:** cierto contenido requiere tier minimo
5. **Nunca hay bloqueo permanente:** siempre hay algo que hacer en cualquier isla
6. **El jugador puede quedarse en cualquier isla:** construir casa y trabajar alli
7. **El comercio inter-islas motiva los viajes:** productos de una isla se venden mejor en otra
8. **Premium acelera pero no reemplaza:** el jugador premium junta dinero mas rapido pero SIEMPRE debe viajar
9. **Los encantamientos son laterales:** cualquier tier se puede encantar, no es obligatorio
10. **El chaman del monte** se accede con incienso (recurso renovable, no limitante)

---

## Modulos Relacionados

> **Referencia rapida para codificacion.** Al trabajar en este modulo, consulta la documentacion de estos modulos relacionados.

### Depende de (necesito su documentacion)

| Modulo | Que aporta a este modulo |
|--------|--------------------------|
| **M013** — Herramientas | Sistema base de herramientas (8 tipos, mejoras Afilar/Templar/Potenciar) |
| **M027** — Islas del Mundo | Estructura de 4 islas con profesiones |
| **M028** — Viajes | Sistema de boletos y barcos |
| **M038** — Economia | Monedas, precios, comercio |
| **M071** — Progresion | Hitos de tier alcanzado |
| **M095** — Monetizacion | Compra de monedas por Steam |
| **M022** — Historia Principal | Sellos y templos requieren tiers |

### Relacionados laterales (mismo dominio)

| Modulo | Relacion |
|--------|----------|
| **M013** — Herramientas | Depende de este modulo |
| **M027** — Islas del Mundo | Depende de este modulo |
| **M028** — Viajes | Depende de este modulo |
| **M038** — Economia | Depende de este modulo |
| **M039** — Tiendas | Vende herramientas y encantamientos |
| **M071** — Progresion | Registra hitos de tier |

### Inversos (modulos que dependen de M158)

| Modulo | Como afecta M158 |
|--------|------------------|
| **M022** — Historia Principal | Requiere tiers para avance de capitulos |
| **M025** — Ruinas | Gates de tier bloquean contenido |
| **M024** — Templos y Puzzles | Requieren tiers para acceder |
| **M026** — Templo Subterraneo | Requiere T3/T4 |
| **M071** — Progresion | Registra hitos de tier |

