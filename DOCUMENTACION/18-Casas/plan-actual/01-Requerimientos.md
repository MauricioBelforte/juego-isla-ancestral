**Modelo:** glm-5.3-free (Kilo Code) (último modificador 2026-09-05: §6 assets 3D de casas grandes habitables + mobiliario interior — directiva del usuario. Original: Deepseek V4 Flash/OpenCode)
**Plataforma:** Kilo Code

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
|-----------|----------------|
| Sin penalización por no decorar | La casa es funcional sin decoración |
| Sin límite de tiempo | Decorar se puede hacer en cualquier momento |
| Sin costo por recolocar | Los muebles se mueven gratis |
| Sin bloqueo de contenido | Todo accesible sin decorar |
| Sin presión de completar sets | Los sets son cosméticos

---

## 6. ASSETS 3D DE CASAS GRANDES HABITABLES + MOBILIARIO (2026-09-05, directiva del usuario — glm-5.3-free/Kilo Code)

> **Gap detectado:** el sistema lógico de muebles (RF5-RF7, grid, FurnitureData)
> estaba contemplado, pero los **assets 3D** NO: la checklist Blender solo tenía
> las 11 piezas modulares de 1×1 celda (paredes/pisos/techos, Tier E cerrado)
> y la `casa_completa_ejemplo` que NO es habitable (solo referencia visual).
> Esta sección define el alcance nuevo pedido por el usuario.

### 6.1 Casas grandes ENTRABLES (nuevo tier de assets)

- **Requisito del usuario:** casas **grandes y amplias, que se pueda entrar
  DENTRO**, proporcionales a los personajes. No módulos sueltos: casas
  completas con interior visible/habitable.
- **Escala de referencia (M19 NPC base v5):** altura NPC ≈ 1.75 m. Regla
  de proporciones para interiores:
  - Puerta: 1.00 m ancho × 2.10 m alto (mínimo; el NPC entra sin agacharse)
  - Altura de techo interior: ≥ 2.60 m (coincide con las paredes modulares
    M18 de 2.60 m ya aprobadas)
  - Paso libre mínimo: 0.90 m entre muebles
- **Estructura por casa:** cada casa es UN asset con:
  - **Exterior completo** (muros, techo, ventanas con vidrio, puerta con
    hueco REAL de 1.00×2.10 para entrar caminando — no puerta pintada)
  - **Interior amueblado o amueblable** (piso interior, paredes por dentro,
    hueco de puerta communicating, sin techos cerrados que oculten el interior
    en vista aérea — evaluación de techo removible/removible-de-farbe en M17)
  - **Muebles propios** (ver 6.2) ya colocados como parte del set de captura
    o como GLB separados para el grid de RF6
- **Familia de casas (progresión RF3):**
  1. **Casa choza ampliada** (etapa 0-1): 1 ambiente 5×4 m, cama + cofre + mesa
  2. **Casa mediana** (etapa 2): 2 ambientes 8×6 m, cocina + dormitorio
  3. **Casa amplia / casona** (etapa 3): 3-4 ambientes 10×8 m, sala de estar
  4. **Mansión** (etapa 4): multi-habitación 14×10 m, biblioteca/sala de museo
- **Presupuesto:** las casas grandes exceden el tope 16 SM_ de un asset
  normal — se construyen como **grupos jerárquicos** (cada habitación un
  sub-grupo ≤16 SM_) o como composición de módulos M18 existentes + piezas
  nuevas. Decisión por casa, documentada en su hoja de contacto.

### 6.2 Mobiliario interior (assets 3D nuevos — lo que faltaba en la checklist)

| Mueble | Etapa | Grid | ¿Interactivo (RF7)? |
|---|---|---|---|
| Cama básica (marco + colchón + almohada) | 0 | Suelo 1×2 | Sí — dormir |
| Cama doble | 2+ | Suelo 2×2 | Sí — dormir |
| Mesa de madera (4 patas + tablero) | 0 | Suelo 2×2 | Sí — colocar items |
| Mesa chica / velador | 1 | Suelo 1×1 | Sí |
| Silla de madera | 0 | Suelo 1×1 | Sí — sentarse |
| Sillón / sofá | 2 | Suelo 2×1 | Sí — sentarse |
| Heladera / alacena de conserva (anacronismo controlado: isla con lore de "conservas frescas en pozo/nevera de piedra" — la heladera moderna NO aplica al estilo cozy ancestral; SI la nevera rústica) | 2 | Suelo 1×1 | Sí — almacenar |
| Cocina/estufa de leña | 1 | Suelo 2×1 | Sí — cocinar |
| Estantería | 1 | Pared 2×1 | Sí — almacenar |
| Cómoda/baúl de ropa | 1 | Suelo 2×1 | Sí — almacenar |
| Lámpara de pie / farol de interior | 1 | Suelo 1×1 | Sí — encender |
| Alfombra redonda | 1 | Suelo 2×2 | No |
| Cuadro/máscara ancestral de pared | 1 | Pared 1×1 | Sí — mirar |
| Maceta con planta interior | 1 | Suelo 1×1 | Sí — regar |
| Bañera/letrina rústica | 2 | Suelo 1×1 | No |

> Nota de lore: "heladera" del usuario → interpretada como **nevera rústica
> de piedra/madera** (el mundo NO tiene electricidad; M147 WorldBible canon).
> Confirmado el criterio: electrodomésticos = NO; equivalentes rústicos = SÍ.

### 6.3 Reglas técnicas para los assets nuevos

- Escala NPC real (1.75 m): cama 2.00×0.90 m, mesa 0.80 alto, silla 0.45
  asiento/0.90 respaldo, puerta interior 1.00×2.10.
- z_min 0.045 del grupo, asentado del GRUPO (no por pieza) — igual que M18.
- Los muebles interactivos son SM_ separados (el script Godot los busca
  por sufijo, igual que fauna §8.1 regla 1 de la guía 09).
- Cada casa/mueble: script `crear_{nombre}_lowpoly.py` + .blend + 6 capturas
  orbitales + variantes MEDIA/BAJA + GLB — pipeline estándar de la guía 09.

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

---

## 7. Casas grandes de lujo (2026-11-12, ERNIE-5.5-Flash-Preview)

> Contexto: el usuario pidió casas más grandes con interiores sofisticados y objetos nuevos. Esta sección actualiza los requerimientos vigentes; el diseño y los assets están en `03-Diseno.md §8` y `04-Codigo.md §8`.

### 7.1 Requerimientos funcionales nuevos

| ID | Requerimiento | Criterio de aceptación |
|---|---|---|
| RF13 | Casas grandes de 2 plantas | Casona 20×15 m y Mansión 28×20 m, 2 plantas habitables |
| RF14 | Interiores amplios | Habitación mínima 4×4 m; techo 3,4 m (casona) / 3,8 m (mansión) |
| RF15 | Circulación holgada | ≥1,2 m entre muebles; pasillos ≥1,5 m |
| RF16 | Objetos originales | 21 objetos nuevos con ID `SM_` y función propia |
| RF17 | Vista de muñeca (cutaway) | Fachada frontal y techo desmontables para ver el interior |
| RF18 | LOD exterior/interior | Exterior LOD0 ≤6.000 tris; interior como escena separada |
| RF19 | Registro en M18/M159 | Cada casa/objeto nuevo con ID, colisión, costo y save |

### 7.2 Objetos nuevos (catálogo propuesto)

| ID | Objeto | Función | Dónde va |
|---|---|---|---|
| SM_Biblioteca_Caracol | Estantería helicoidal | Libros + decoración | Estudio/biblioteca |
| SM_Mesa_Alquimista | Mesa de trabajo | Frascos, alambique | Estudio/taller |
| SM_Tapiz_Ancestral | Tapiz de pared | Decoración + lore | Sala/estudio |
| SM_Globo_Terraqueo | Globo terráqueo | Exploración/lore | Estudio/biblioteca |
| SM_Reloj_Pie | Reloj de pie | Decoración + hora | Vestíbulo |
| SM_Vitrina_Conchas | Vitrina | Colección marina | Sala |
| SM_Bañera_Cobre | Bañera | Baño | Baño |
| SM_Fuente_Interior | Fuente | Decoración + sonido | Vestíbulo |
| SM_Lampara_Araña | Araña | Iluminación | Comedor/vestíbulo |
| SM_Cama_Dosel | Cama con dosel | Dormir | Dormitorio principal |
| SM_Telar | Telar | Decoración + artesanía | Taller |
| SM_Acuario_Empotrado | Acuario | Decoración + pecera | Sala |
| SM_Estufa_Ceramica | Estufa | Cocina + calefacción | Cocina |
| SM_Vitrina_Museo | Vitrina de museo | Colección | Galería |
| SM_Piano_Cola | Piano de cola | Música | Sala de música |
| SM_Arpa | Arpa | Música | Sala de música |
| SM_Escultura_Armilar | Esfera armilar | Observación | Observatorio |
| SM_Armadura | Armadura decorativa | Decoración | Vestíbulo |
| SM_Mesa_Billar | Mesa de billar | Ocio | Sala de estar |
| SM_Hamaca | Hamaca | Descanso | Terraza/invernadero |
| SM_Candelabro_Pie | Candelabro | Iluminación | Dormitorio/comedor |

### 7.3 Reglas de espacio (obligatorias)

- Habitación mínima habitable: **4×4 m** (16 m²).
- Techo mínimo: **3,2 m**; recomendado 3,4–3,8 m en casas grandes.
- Separación entre muebles: **≥1,2 m**; en circulación principal **≥1,5 m**.
- Puertas interiores: **≥1,5 m** de ancho en casas grandes.
- No colocar más de **1 mueble grande por 6 m²** (≈0,17 muebles/m²).
- El techo y la fachada frontal deben poder ocultarse para la vista de interior.

