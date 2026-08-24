**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 18: Casas

## ID del Módulo
- **Código:** M18 (plan maestro: sección 17 — CASAS)
- **Carpeta:** `DOCUMENTACION/18-Casas/`
- **Dependencias:** M17 (Construcción), M14 (Inventario), M19 (NPC y Vecinos), M29 (Tiempo y Calendario). Relaciones: M21 (Diálogos), M61 (Rendimiento), M58 (Guardado)
- **Delegable desde:** hoy (diseño completo; implementación tras la base de M17, M14 y M19)

## 1. Problema

La casa del jugador es el corazón cozy de la experiencia: un refugio que crece con el jugador, con interior habitable, almacenamiento doméstico, decoración personalizable y lugar de sociabilización con los vecinos. El reto es lograr una casa viva y modificable (construcción M17, ampliaciones por etapas, reubicación, decoración interior) sin degradar el rendimiento del mundo voxel abierto, con interior persistente, muebles interactivos y visitas de NPC (M19), todo integrado con inventario (M14) y tiempo (M29).

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Sistema de parcelas | Parcela de terreno validada por M17 donde la casa ocupa su huella; una por jugador, reubicable con coste |
| RF2 | Casa del jugador | Construible desde cero mediante el modo construcción de M17; estado visual exterior según etapa de mejora |
| RF3 | Ampliaciones por etapas | Mejoras escalonadas (choza base, living, dormitorio, cocina, taller, sótano/ático) con costes y materiales |
| RF4 | Interior con habitaciones | Escena interior propia con habitaciones desbloqueables por etapa; entrada/salida por la puerta principal |
| RF5 | Almacenamiento doméstico | Cofres, estanterías y muebles de almacenamiento con slots, integrados con el inventario M14 |
| RF6 | Decoración | Colocación de muebles y objetos en grid interior: rotación, recolocación, objetos de pared, cuadros, plantas |
| RF7 | Muebles interactivos | Camas (dormir), sillas (sentarse), lámparas (encender), electrodomésticos y mesas utilizables |
| RF8 | Cocina, taller y jardín | Espacios funcionales de la casa: cocina, taller y jardín exterior con interacción y recetas (M16) |
| RF9 | Estilos y colecciones | Estilos de decoración (ancestral, floral, oceánico, etc.) y sets coleccionables que premiar |
| RF10 | Visitas de vecinos | Vecinos M19 visitan la casa según horario M29, reaccionan a la decoración y dialogan (M21) |
| RF11 | Persistencia | Interior, decoración, almacenamiento y etapa de mejora se guardan y restauran (M58) |
| RF12 | Casas de vecinos | Parcelas y casas de NPC en el pueblo (M19), con su propio interior y comportamiento |

## 3. Requisitos No Funcionales

- **Cozy:** cero agresividad; hogar acogedor; escenarios de luz cálida; sonidos suaves; el jugador nunca es bloqueado por el sistema de casa.
- **Rendimiento (M61):** interior instanciado con coste cero en el mundo exterior; grid de decoración sin allocs por frame; entrada/salida sin congelamiento.
- **Determinismo suave:** preferencias de vecinos y variaciones por PRNG de partida (M29).
- **Guardado (M58):** serialización compacta por IDs (mueble, rotación, celda); versionado de esquema.
- Pausa con GameClock (M29) congela obras y visitas sin desincronizar.

## 4. Criterios de Aceptación

1. Los 25 puntos de la sección 17 resueltos.
2. Arquitectura House / HouseInterior / HouseUpgrade / HouseStorage / HouseDecor definida con contratos API.
3. Flujo completo verificado: construir casa, entrar, ampliar, decorar, almacenar y recibir visitas.
4. Edge cases documentados (casa en construcción, mudanza de muebles, obra en curso).
5. Delegable para implementación.
---

## 5. SISTEMA DE COLECCIÓN Y DECORACIÓN (Tsuki's Odyssey + Animal Crossing)

**Filosofía:** La casa es el refugio del jugador. Decorar es una actividad cozy, no una obligación. No hay penalización por no decorar. La recompensa es estética y social.

### 5.1 Progresión de la Casa

| Etapa | Nombre | Habitaciones | Costo | Desbloquea |
|-------|--------|-------------|-------|------------|
| 0 | Choza | 1 (sala) | Gratis | Cama básica, 1 cofre |
| 1 | Casa pequeña | 2 (sala + dormitorio) | 500 monedas | Cocina básica, 2 cofres |
| 2 | Casa mediana | 3 (+ baño) | 1500 monedas | Taller, 4 cofres |
| 3 | Casa amplia | 4 (+ sala de estar) | 4000 monedas | Biblioteca, 6 cofres |
| 4 | Mansión | 5 (+ jardín interior) | 10000 monedas | Sala de museo, 10 cofres |

**Regla cozy:** Las mejoras son Opcionales. La choza base es perfectamente funcional. Mejorar la casa da más espacio y slots de decoración, pero no bloquea contenido.

### 5.2 Sistema de Grid para Decoración

#### Dimensiones del Grid

| Etapa | Grid suelo | Grid pared | Total slots |
|-------|-----------|-----------|-------------|
| Choza | 4×4 = 16 | 8 (paredes) | 24 |
| Casa pequeña | 6×6 = 36 | 16 | 52 |
| Casa mediana | 8×8 = 64 | 24 | 88 |
| Casa amplia | 10×10 = 100 | 32 | 132 |
| Mansión | 12×12 = 144 | 48 | 192 |

#### Reglas de Colocación

| Regla | Detalle |
|-------|---------|
| Rotación | 4 direcciones (0°, 90°, 180°, 270°) |
| Superposición | No se pueden solapar muebles |
| Pared | Solo en slots de pared (cuadros, estanterías, espejos) |
| Suelo | Solo en slots de suelo (mesas, sillas, camas) |
| Exteriores | Solo en parcela exterior (bancos, fuentes, cercas) |
| Movimiento | Los muebles se pueden recolocar libremente (sin costo) |

### 5.3 Fuentes de Muebles

| Fuente | Tipo | Cantidad | Costo promedio |
|--------|------|----------|----------------|
| Carpintero del pueblo | Básicos (mesas, sillas) | 50+ | 50-200 monedas |
| Tienda del pueblo | Decoración (lámparas, cuadros) | 30+ | 30-150 monedas |
| Artesanos de otras islas | Específicos de isla | 20+ por isla | 200-500 monedas |
| Recetas de crafting | Crafteados por el jugador | 40+ | Materiales |
| Puzzles / Ruinas | Antiguos / Ancestrales | 30+ | Gratis (exploración) |
| Regalos de NPCs | Exclusivos de NPC | 12+ | Gratis (amistad) |
| Eventos / Festivales | Estacionales | 10+ | Gratis (participación) |
| Tesoros ocultos | Raros / Legendarios | 15+ | Gratis (exploración) |

### 5.4 Categorías de Muebles

| Categoría | Ejemplos | Grid | Interactivo |
|-----------|----------|------|-------------|
| Mobiliario | Mesas, sillas, camas, estanterías | Suelo | Sí (sentarse, dormir) |
| Iluminación | Lámparas, faroles, velas | Suelo/Pared | Sí (encender/apagar) |
| Decoración de pared | Cuadros, espejos, relojes | Pared | Sí (mirar) |
| Plantas | Macetas, jardines interiores | Suelo | Sí (regar) |
| Alfombras | Redondas, rectangulares | Suelo | No |
| Cocina | Mesón, horno, ollas | Suelo | Sí (cocinar) |
| Taller | Mesa de trabajo, yunque | Suelo | Sí (fabricar) |
| Exteriores | Bancos, fuentes, cercas | Exterior | Sí (sentarse) |

### 5.5 Estilos de Decoración (Sets)

Cada set tiene una temática y un bono social al completarlo:

| Set | Piezas | Temática | Bono al completar |
|-----|--------|----------|-------------------|
| Ancestral | 10 | Ruinas, piedra, glifos | NPC arqueólogos visitan +1×/semana |
| Floral | 12 | Flores, jardín, primavera | NPC jardineros visitan +1×/semana |
| Oceánico | 10 | Coral, conchas, azul | NPC pescadores visitan +1×/semana |
| Bosque | 10 | Madera, hojas, natural | NPC exploradores visitan +1×/semana |
| Nocturno | 8 | Cristal, brillo, misterio | NPCs nocturnos visitan +1×/semana |
| Cocina | 8 | Utensilios, ollas, recetas | NPC chefs visitan +1×/semana |

**Regla:** Completar un set es 100% opcional. No hay contenido bloqueado por no completar sets.

### 5.6 Interacción con Muebles

| Mueble | Acción | Resultado | Tiempo |
|--------|--------|-----------|--------|
| Cama | Dormir | Restaura energía 100%, avanza tiempo | 8h juego |
| Silla | Sentarse | Recupera +30% energía | 30 min juego |
| Mesa | Colocar item | Decoración + funcional | Instantáneo |
| Lámpara | Encender/apagar | Cambia iluminación | Instantáneo |
| Estantería | Almacenar | Guarda items (slots por estantería) | Instantáneo |
| Cocina | Cocinar | Crea comidas (M16) | 5-30 min juego |
| Mesa de trabajo | Fabricar | Crea herramientas/items (M16) | 10-60 min juego |
| Radio/Música | Escuchar | Cambia música ambiental | Instantáneo |
| Cuadro | Mirar | Muestra vista previa de foto (M56) | 5 min juego |
| Maceta | Regar | Plantas crecen +1 etapa | 1 día juego |

### 5.7 Reacción de NPCs a la Decoración

- Cada NPC tiene gustos personales (profesión, personalidad)
- Si la decoración de la casa coincide con los gustos del NPC, reacciona positivamente
- Reacciones: "¡Me encanta!", "Qué bonito", "No es lo mío", "No me gusta"
- Las reacciones NO afectan la amistad (solo cosmético)
- Los NPCs pueden pedir al jugador que coloque un mueble específico (misión secundaria)
- No hay penalización por ignorar la petición

### 5.8 Persistencia de Decoración

- La decoración se guarda por completo en M58
- Cada celda del grid almacena: ID mueble + rotación + variante
- La decoración se carga instantáneamente al entrar a la casa
- No hay límite de muebles por habitación (solo límite de grid)
- Los muebles se pueden mover y recolocar libremente (sin costo)

### 5.9 Anti-Frustración

| Principio | Implementación |
|-----------|---------------|
| Sin penalización por no decorar | La casa es funcional sin decoración |
| Sin límite de tiempo | Decorar se puede hacer en cualquier momento |
| Sin costo por recolocar | Los muebles se mueven gratis |
| Sin bloqueo de contenido | Todo accesible sin decorar |
| Sin presión de completar sets | Los sets son cosméticos

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M017** — Construcción | Base para construcción |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M159** — Catálogo de Objetos | Usado por catálogo de objetos |
| **M160** — Diseño de Ubicaciones del Mundo | Usado por diseño de ubicaciones del mundo |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M017** — Construcción | Depende de este módulo |
| **M159** — Catálogo de Objetos | Este módulo lo necesita |
| **M160** — Diseño de Ubicaciones del Mundo | Este módulo lo necesita |

