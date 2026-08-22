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

## 4. EXPANSIONES COZY (2026-08-22)

### 4.1 Sistema de Colección de Muebles

Inspirado en Tsuki's Odyssey y Animal Crossing, el jugador puede coleccionar muebles y objetos decorativos que encuentra en el mundo.

#### Fuentes de Muebles

| Fuente | Tipo de Mueble | Cantidad |
|--------|---------------|----------|
| Tiendas del pueblo | Básicos (mesas, sillas, lámparas) | 50+ |
| Artesanos de otras islas | Específicos de isla | 20+ por isla |
| Puzzles / Ruinas | Antiguos / Ancestrales | 30+ |
| Recetas de crafting (M16) | Crafteados por el jugador | 40+ |
| Regalos de NPCs | Exclusivos de NPC | 12+ (1 por NPC favorito) |
| Eventos / Festivales | Estacionales | 10+ |
| Tesoros ocultos | Raros / Legendarios | 15+ |

#### Categorías de Muebles

| Categoría | Ejemplos | Slots en casa |
|-----------|----------|---------------|
| Mobiliario | Mesas, sillas, camas, estanterías | Grid suelo |
| Iluminación | Lámparas, faroles, velas, candiles | Grid pared/suelo |
| Decoración de pared | Cuadros, estampas, espejos, relojes | Grid pared |
| Plantas | Macetas, jardines interiores, árboles mini | Grid suelo |
| Alfombras | Redondas, rectangulares, temáticas | Grid suelo |
| Cocina | Mesón, horno, estantería de especias | Grid suelo |
| Taller | Mesa de trabajo, herramientas decorativas | Grid suelo |
| Exteriores | Bancos, fuentes, cercas, jardines | Parcela exterior |

### 4.2 Estilos de Decoración (Sets)

Cada set tiene una temática y un bono social cuando el jugador completa el set:

| Set | Temática | Piezas | Bono al completar |
|-----|----------|--------|-------------------|
| Ancestral | Ruinas, piedra, glifos | 10 | NPC arqueólogos visitan |
| Floral | Flores, jardín, primavera | 12 | NPC jardineros visitan |
| Oceánico | Coral, conchas, azul | 10 | NPC pescadores visitan |
| Bosque | Madera, hojas, natural | 10 | NPC exploradores visitan |
| Nocturno | Cristal, brillo, misterio | 8 | NPCs nocturnos visitan |
| Cocina | Utensilios, ollas, recetas | 8 | NPC chefs visitan |

### 4.3 Bono de Decoración para NPCs

- Cuando el jugador completa un set, los NPCs reaccionan positivamente
- NPCs con gustos afines al set visitan la casa más frecuentemente
- La reputación de la casa crece (visible en el mapa)
- Los NPCs pueden regalar items raros si les gusta la decoración
- No hay penalización por no decorar (cozy = sin presión)

### 4.4 Interacción con Muebles

| Mueble | Acción | Resultado |
|--------|--------|-----------|
| Cama | Dormir | Restaura energía, avanza tiempo |
| Silla | Sentarse | Recuperación lenta de energía |
| Mesa | Colocar item | Decoración + funcional |
| Lámpara | Encender/apagar | Cambia iluminación de la habitación |
| Estantería | Almacenar | Guarda items extra |
| Cocina | Cocinar | Crea comidas (M16) |
| Mesa de trabajo | Fabricar | Crea herramientas/items (M16) |
| Radio/Música | Escuchar | Cambia música ambiental |
| Cuadro | Mirar | Muestra vista previa de foto (M56) |
| Maceta | Regar | Crecen plantas decorativas |

### 4.5 Persistencia de Decoración

- La decoración se guarda por completo en M58
- Cada celda del grid almacena: ID mueble + rotación + variante
- La decoración se carga instantáneamente al entrar a la casa
- No hay límite de muebles por habitación (solo límite de grid)
- Los muebles se pueden mover y recolocar libremente
