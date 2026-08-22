**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 158: Herramientas y Desbloqueo de Zonas

## ID del Módulo
- **Código:** M158
- **Carpeta:** `DOCUMENTACION/158-Herramientas-Y-Desbloqueo-De-Zonas/`
- **Dependencias:** M13 (Herramientas), M38 (Economía), M27 (Islas), M28 (Viajes), M71 (Progresión)
- **Relaciones:** M25 (Ruinas), M24 (Templos y Puzzles), M22 (Historia Principal), M26 (Templo Subterráneo), M95 (Monetización)

## 1. Problema

El jugador necesita una progresión clara de herramientas que desbloquee contenido en el mundo, pero sin copiar la fórmula de Zelda (llave开门). Cada isla del archipiélago tiene una profesión especializada (carpintero, herrero, encantador) que ofrece herramientas de mayor tier a cambio de materiales + monedas. El jugador debe poder elegir su ritmo: explorar y resolver todo manualmente, o pagar dinero real para avanzar más rápido. La historia principal REQUIERE herramientas hasta tier 4 para completarse.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | 4 tiers de herramientas | Madera (T1) → Cobre (T2) → Hierro (T3) → Encantada (T4). Cada tier desbloquea nuevo contenido |
| RF2 | T1 se encuentra en isla principal | Ramas, piedras, herramientas básicas recolectables del mundo sin costo |
| RF3 | T2-T4 se obtienen en islas distintas | Cada isla tiene un profesional (carpintero, herrero, encantador) que forja el tier correspondiente |
| RF4 | Requisito de forja: materiales + monedas | El jugador lleva materiales de la isla + paga monedas por el servicio de forja |
| RF5 | Cada isla = precios progresivamente más caros | Isla principal (barato) → Isla 2 (medio) → Isla 3 (caro) → Isla 4 (muy caro) |
| RF6 | Cursos para aprender oficios | Carpintero (isla principal), Herrería (isla 2), Encantamiento (isla 3). Cursos caros, permiten vender herramientas |
| RF7 | La tienda del jugador vende herramientas | NPCs visitantes compran 1×/día las herramientas/crafts del jugador |
| RF8 | La historia requiere T4 | Los templos finales y sellos de la historia necesitan herramientas encantadas (T4) |
| RF9 | Ruta de exploración no lineal | El jugador elige qué isla visitar primero; no hay ruta obligatoria lineal |
| RF10 | Construcción en otras islas | El jugador puede construir casas en islas visitadas y quedarse a trabajar allí |
| RF11 | Tier 1 = exploración básica | Ramas, piedras sueltas, jarrones, árboles pequeños |
| RF12 | Tier 2 = muros de piedra, raíces gruesas | Desbloquea caminos nuevos, pueblos ocultos dentro de la isla principal |
| RF13 | Tier 3 = sellos ancestrales, puertas de templo | Desbloquea templos y contenido avanzado de la historia |
| RF14 | Tier 4 = cámaras secretas, zonas encantadas | Contenido final de la historia, lore oculto, final secreto |
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

1. El jugador obtiene T1 en la isla principal sin costo (recolectando del mundo)
2. El jugador puede viajar a isla 2 con un boleto (M28) y forjar T2 pagando materiales + monedas
3. Cada isla subsiguiente tiene precios ≥50% más caros que la anterior
4. Los templos de la historia principal no se pueden completar sin T3/T4
5. El jugador premium puede comprar monedas y saltarse el grind de recolección
6. Jarrones se reponen cada 7 días del juego (M29 calendario)
7. NPCs visitantes compran herramientas del jugador 1×/día
8. El jugador puede construir en otras islas y quedarse a vivir allí
9. La progresión no es lineal: el jugador puede visitar islas en cualquier orden
10. Checklist mínimo 100 ítems verificables

## 5. Alcance

**Dentro del alcance:** sistema de tiers de herramientas, gates por tier en el mundo, sistema de forja por isla, costos progresivos, cursos de oficio, venta de herramientas del jugador, progresión de la historia ligada a tiers, fuentes de ingreso del jugador, integración premium.

**Fuera del alcance:** el sistema base de herramientas (M13), las tiendas NPCs (M39 se expande aparte), la economía general (M38 se expande aparte), los viajes entre islas (M28), la definición de islas (M27).
