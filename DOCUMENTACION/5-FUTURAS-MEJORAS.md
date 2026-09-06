# 5-FUTURAS-MEJORAS.md

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16

## Propósito

**Anotador de ideas del usuario.** Contiene únicamente directivas, ideas y mejoras que el usuario comunica al agente. NO se agregan propuestas generadas por agentes (AGENTS.md §3).

## Reglas

- Cada entrada registra fecha y prioridad: Alta 🔴 / Media 🟡 / Baja 🟢.
- Se marca `[ ]` → `[x]` cuando la idea se implementa.
- No reemplaza a `3-DOCUMENTO-TAREAS-ACTUAL.md`.

## Ideas del usuario

### 🔴 Alta

- [x] **Selección de personaje al inicio del juego.** Permitir elegir entre varios personajes con distinto diseño visual al comenzar la partida. Cada personaje tendría un look único (cabello, facciones, complexión) pero manteniendo el mismo estilo cozy/coherente con el mundo voxel. Definir si hay 4-6 opciones base. **Fecha:** 2026-08-22. **Implementado en:** M11 (expansión), M155, M156.
- [x] **El transporte entre islas debe ser una experiencia con misterios propios.** El viaje en barco/avión/tren entre islas o ciudades NO debe ser una simple pantalla de carga. Debe ser una experiencia jugable por sí misma, con misterios internos que resolver durante el trayecto (pistas, eventos, NPCs a bordo, secretos del mar/cielo). Esto convierte el "tiempo muerto" de viaje en contenido significativo. Definir qué medios de transporte existen y qué tipo de misterios se resuelven en cada uno. **Fecha:** 2026-08-22. **Implementado en:** M69 (expansión), M157.

### 🟡 Media

- [x] **Sistema de vestimenta y accesorios.** Permitir vestir al personaje durante el juego con distintas prendas y accesorios. Definir si las prendas son solo cosméticas o si dan bonos (ej: capa de frío para biomas helados). Incluir accesorios funcionales que afecten movimiento: zapatillas, patines, bicicleta para aumentar velocidad. Coherencia con M11 (personaje) y M57 (accesibilidad). **Fecha:** 2026-08-22. **Implementado en:** M155, M156.
- [x] **Terrenos con movimiento diferenciado.** Definir tipos de terreno (barro, pavimento, césped, arena, nieve, rocas) que afectan la velocidad del jugador. Equipamiento específico para cada terreno: botas de barro para barro, patines para pavimento, bicicleta para caminos. Sin el equipamiento adecuado, el jugador se mueve más lento pero NUNCA se bloquea. Cozy = sin frustración. **Fecha:** 2026-08-22. **Implementado en:** M156, M155.

### 🟢 Baja

*(sin entradas)*

---

## Ideas del usuario — 2026-09-03

### 🔴 Alta

- [ ] **Animales con sexo para reproducción.** Los animales del juego deben tener sexo (macho/hembra) para poder reproducirse. La reproducción requiere pareja de distinto sexo. Definir mecánica: tiempo de gestación, crías, si las crías heredan características, límite de población, interactions con el ecosistema. Coherente con M65 (Animales IA) y M36 (Fauna). **Fecha:** 2026-09-03.

- [ ] **Animales dan objetos o habilidades.** Los animales deben dejar objetos al ser criados/interactuados (huevos, leche, pelo, plumas, etc.) o tener habilidades especiales que ayuden al jugador. Estos objetos sirven para misiones, intercambios con NPCs, o crafting. Definir qué animal da qué objeto/frecuencia. Coherente con M15 (catálogo de recursos), M73 (coleccionables), M39 (tiendas). **Fecha:** 2026-09-03.

### 🟡 Media

- [ ] **Jaulas para atrapar animales.** Crear jaulas/contenedores para atrapar animales vivos. Los animales atrapados pueden: (1) intercambiarse con NPCs por objetos valiosos, (2) tenerlos enjaulados en casa del jugador como decoración/mascota, (3) soltarlos para reproducción. Definir: cómo se fabrica la jaula, qué animales se pueden atrapar, si hay límite, interacción con M155 (vestimenta/accesorios) y M19 (NPCs). **Fecha:** 2026-09-03.

---

## Descubrimientos de auditoría — 2026-08-23

> Revisión exhaustiva de ~30 módulos clave. Los ítems marcados con 🔴 bloquean codificación.

### 🔴 Alta — Bloquean codificación

- [x] **Unificar tiers de herramientas.** M13 dice T1=Cobre/T2=Hierro/T3=Oro/T4=Cristal. M158 dice T1=Madera/T2=Cobre/T3=Hierro/T4=Encantada. Contradicción que rompe la progresión. **Fecha:** 2026-08-23. **Implementado en:** M13/M158 unificados (commit e10777a).

- [x] **Definir esquema `ItemData` completo (M14).** No existe el struct/concreto con campos: id, nombre, categoría, rareza, icono, max_stack, tooltip, precio_venta, etc. Sin esto no se puede codificar inventario ni tiendas. **Fecha:** 2026-08-23. **Implementado en:** M14 plan-actual/04-Codigo.md (commit e10777a).

- [x] **Crear catálogo concreto de recursos (M15).** El esquema `ResourceDefinition` existe pero no hay un solo recurso definido. No se sabe cuántos tipos de madera, minerales, peces, etc. existen. Las tablas de drops (probabilidad, cantidad) están vacías. **Fecha:** 2026-08-23. **Implementado en:** M15 plan-actual/04-Codigo.md — 69 recursos base (12 madera + 14 piedra/mineral + 10 fibra/planta + 12 comida + 8 especial + 8 pescados + 5 tesoros).

- [x] **Completar tabla de polígonos de Arte 3D (M45).** Solo 3 de 14 categorías tienen techo de tris (personaje ≤8000, prop ≤200, edificio ≤15000). Faltan: animales, muebles, herramientas, barcos, vehículos, vegetación, ruinas, templos, decorativos, interactivos, NPCs. Sin esto los artistas no saben los límites. **Fecha:** 2026-08-23. **Implementado en:** M45 plan-actual/01-Requerimientos.md — 14 categorías completas con LOD0/LOD1/LOD2.

- [x] **Definir tablas de durabilidad por herramienta (M13).** No hay cuántos golpes aguanta cada herramienta por tier. El contrato `try_extract`/`try_place` con M08 (Voxel) no está formalizado. La lupa y las tijeras están enumeradas pero sin funcionalidad descrita. **Fecha:** 2026-08-23. **Implementado en:** M13 plan-actual/01-Requerimientos.md — 9 herramientas × 4 tiers + contrato try_extract/try_place.

### 🟡 Media — Dificultan codificación

- [x] **Resolver contradicciones en Amistad (M20).** RF1 dice "niveles 0-10" pero la tabla define 6 niveles (0-5). RF9 dice "cero decaimiento" pero la sección 5.6 introduce decaimiento suave (-2 a -5 tras 1-3 meses). El sistema de cartas solo se menciona, no se diseña. **Fecha:** 2026-08-23. **Implementado en:** M20 plan-actual/01-Requerimientos.md — niveles unificados 0-5, decaimiento eliminado, sistema de cartas diseñado.

- [x] **Completar anti-inflación de economía (M38).** Los bienes entre islas dan 30-60% de bono pero no hay mecanismo que evite la inflación. La lógica de amortiguación "no afectan el mercado local" no está detallada. **Fecha:** 2026-08-23. **Implementado en:** M38 plan-actual/01-Requerimientos.md — 5 mecanismos: límite diario, amortiguación por volumen, separación de mercados, bono inter-islas, reserva de mercado.

- [x] **Diseñar reputación de tienda del jugador (M39).** Se menciona que crece con las ventas y desbloquea NPCs especiales pero no se diseña (qué NPCs, cómo escala, qué desbloquea). Los 3 niveles de tienda del jugador tienen costo de mejora indefinido. **Fecha:** 2026-08-23. **Implementado en:** M39 plan-actual/01-Requerimientos.md — 6 niveles de reputación, NPCs especiales, objetos exclusivos, costos de mejora.

- [x] **Cerrar formato de guardado (M59/M60).** Todo M59 delega el formato a M60, que a su vez solo tiene requerimientos. No hay benchmarks de rendimiento ("no lag" sin métricas). No se detallan edge cases para múltiples slots. **Fecha:** 2026-08-23. **Implementado en:** M59 plan-actual/01-Requerimientos.md — esquema JSON completo, benchmarks, edge cases.

- [x] **Priorizar pantallas de UI/UX (M53).** Hay 25 pantallas listadas pero sin orden de implementación (MVP vs post-MVP). No hay especificaciones de assets (colores hex, espaciados, duraciones de animación). **Fecha:** 2026-08-23. **Implementado en:** M53 plan-actual/01-Requerimientos.md — 10 pantallas MVP + 15 post-MVP + assets base.

- [x] **Completar documentación de IA de NPC (M64).** Solo tiene `01-Requerimientos.md`. Faltan `02-Analisis.md`, `03-Diseno.md`, `04-Codigo.md`, `05-Checklist.md`. **Fecha:** 2026-08-23. **Implementado en:** M64 plan-actual/ — 4 archivos creados (02-Analisis, 03-Diseno, 04-Codigo, 05-Checklist con 100+ items).

- [x] **Resolver cantidad de NPCs.** M19 define 8-12 vecinos con 8 ejemplos. M161/M162 documentan 23 NPCs. Hay que definir cuántos NPCs hay realmente en el juego. **Fecha:** 2026-08-23. **Implementado en:** M19 plan-actual/01-Requerimientos.md — **35 NPCs** distribuidos en 4 islas (12 Raíz + 10 Ceniza + 8 Coral + 5 Aurora). M161/M162 necesitan actualización para alinear con los 35 NPCs.

### 🟢 Baja — Pendientes menores

- [x] **Corregir referencia a Godot en M11.** El archivo dice "New Input System de Godot" — el proyecto usa Unity. Error de documentación. **Fecha:** 2026-08-23. **Implementado en:** M11 plan-actual/04-Codigo.md y 05-Checklist.md — corregido a "Input System de Godot".

- [ ] **Revisar módulos no auditados.** M33 (Agricultura), M34 (Pesca), M35 (Minería), M36 (Fauna), M50 (Vegetación), M51 (Agua), M52 (Partículas), M60 (Serialización), M62 (Memoria), M63 (Streaming), M65 (Animales IA), M87 (Localización), M92 (Tutorial), M93 (Balance). **Fecha:** 2026-08-23. **Acción:** auditoría futura de estos módulos.

- [x] **Vincular ART_STYLE_3D.md (M45).** El archivo referenciado en RF1 no está vinculado ni incluido en la documentación. **Fecha:** 2026-08-23. **Implementado en:** M45 plan-actual/ART_STYLE_3D.md — guía de estilo completa con paleta, métricas, topología, nombres y checklist.

---

## Nuevos sistemas diseñados — 2026-08-23

### 🔴 Sistema de Herramientas Unificado (M13/M158)

**Tiers de material (4):**
| Tier | Material | Isla | Cómo se obtiene |
|------|----------|------|-----------------|
| T1 | Cobre | Raíz | Carpintero te regala 1 al inicio, o comprás en tienda |
| T2 | Hierro | Ceniza | Forjado con herrero (curso necesario) |
| T3 | Oro | Coral/Viaje | Forjado con herrero avanzado |
| T4 | Cristal | Aurora | Forjado con cristalero |

**Profesiones de forja:**
- **Carpintero** (Isla Raíz): Herramientas T1 de cobre
- **Herrero** (Isla Ceniza): Herramientas T2 de hierro
- **Herrero Avanzado** (Isla Coral): Herramientas T3 de oro
- **Cristalero** (Isla Aurora): Herramientas T4 de cristal

**Sistema de Encantamientos (capa adicional sobre cualquier tier):**

Los encantamientos son **permanent por herramienta** y se pueden **vender** (distintas tiendas compran distintos encantamientos). El jugador puede obtener más encantamientos llevando **incienso** a un **chamán** ubicado en un monte.

| Tier encantado | Nombre | Habilidad |
|----------------|--------|-----------|
| Cobre Encantado | `Cobre Ancestral` | Se intercambia por un objeto especial con un NPC + bonus adicional por definir |
| Hierro Encantado | `Hierro Próspero` | Al romper rocas/minerales, da el doble de monedas |
| Oro Encantado | `Oro Brillante` | Aumenta el precio de venta en tiendas +50% |
| Cristal Encantado | `Cristal de Caverna` | Funciona en cuevas con bonus de extracción |

**Chamán del Monte:**
- NPC especial en un monte remoto
- Se le lleva **incienso** (recurso especial, se cultiva o se encuentra)
- A cambio, **encanta una herramienta** con el encantamiento correspondiente a su tier
- No es limitante: el jugador puede volver a conseguir encantamientos siempre que tenga incienso
- El incienso es un recurso renovable (cultivo de plantas especiales o eventos)

### 🔴 Isla Final con Combat (nuevo sistema)

**Concepto:** Si el jugador llega a un punto avanzado del juego y quiere combatir, existe una **isla final** donde el combate es posible. El juego principal permanece cozy; la isla de combate es **totalmente opcional**.

**Sistema de Gemas:**
- El jugador obtiene **gemas** mediante intercambios de herramientas encantadas y otros logros
- Las gemas son la **moneda de acceso** a la isla final
- Cantidad de gemas determina qué contenido de combate se desbloquea

**Contenido de la Isla Final:**
- **Villanos** enemigos con distintos patrones de ataque
- **Mobs** básicos para farmear gemas
- **Jefes** con mecánicas únicas (no agresivos ni frustrantes, manteniendo filosofía cozy)
- **Recompensas exclusivas**: objetos cosméticos, herramientas únicas, títulos

**Filosofía de combate:**
- Combate **opcional**, nunca forzado
- Sin penalizaciones por no combatir (cozy)
- Sin game over (si perdés, volvés al pueblo sin penalidad)
- Recompensas que complementan el juego principal, no lo reemplazan
- Si la gente llega a este punto, es porque quiere la posibilidad de luchar

**Fecha:** 2026-08-23. **Acción:** crear módulo dedicado para isla de combate + sistema de gemas + chamán.

---

## Ideas del usuario — 2026-09-03 (continuación)

### 🔴 Alta

- [ ] **Más animales funcionales.** Agregar más especies de animales al juego, cada uno con utilidad única. Ejemplo: el **topo** puede cavar el terreno para el jugador (abrir cuevas, desenterrar recursos). Definir lista completa de animales y sus habilidades/objetos. **Cada isla tendrá animales únicos de su bioma**, lo que incentiva la exploración y viaje entre islas. Los animales tienen sexo (macho/hembra) y se pueden **atrapar con jaulas** en una isla para trasladarlos y reproducirlos en otra isla (ej: atrapar un topo macho en Isla Raíz y una hembra en Isla Ceniza para criar topos en tu granja). Coherente con M65 (Animales IA), M36 (Fauna), M08 (Mundo Voxel). **Fecha:** 2026-09-03.

**Distribución de animales por isla:**

| Isla | Animales exclusivos | Bioma |
|------|---------------------|-------|
| Raíz | Topo, Abeja, Lombriz | Tropical/templado |
| Ceniza | Cuervo, Zorro, Puercoespín | Volcánico/rocoso |
| Coral | Tortuga marina, Pato, Cangrejo | Costero/marino |
| Aurora | Venado, Búho, Lobo | Bosque frío/nevado |

**Lista propuesta de animales y utilidades:**

| Animal | Utilidad | Objeto que deja | Isla | Notas |
|--------|----------|-----------------|------|-------|
| Topo | Cava terreno (abre cuevas, desenterrar recursos) | Tierra rica, minerales | Raíz | Requiere tier de herramienta alto para desbloquear |
| Abeja | Polinización (aumenta rendimiento de cultivos cercanos) | Miel, cera | Raíz | Colmena colocable, necesita flores |
| Lombriz | Aeración de suelo (mejora calidad de tierra de cultivo) | Humus, fertilizante | Raíz | Aparece al cavar tierra |
| Cuervo | Exploración (muestra mapa temporal de zona cercana) | Plumas, objetos perdidos | Ceniza | Se le da maíz como alimento |
| Zorro | Rastreo (encuentra objetos ocultos en el suelo) | Pieles, colas | Ceniza | Atraído por comida específica |
| Puercoespín | Defensa (espanta NPCs hostiles cercanos) | Púas, cerdas | Ceniza | Útil en zonas peligrosas |
| Tortuga marina | Transporte ligero (porta 1-2 objetos entre orillas) | Caparazón decorativo, huevos | Coral | Ya existe en M36, expandir utilidad |
| Pato | Pesca auxiliar (atrae peces a la zona) | Plumas, huevos | Coral | Colocable en agua |
| Cangrejo | Recoge objetos del fondo del mar | Caparazón, pinzas | Coral | Sumergible |
| Venado | Tiro con arco (dropea carne y cuero al ser cazado con arco) | Cuero, carne, astas | Aurora | Cacería estilo peaceful |
| Búho | Vigilancia nocturna (detecta eventos nocturnos raros) | Plumas, plumones | Aurora | Activo de noche |
| Lobo | Guardia (protege granja de depredadores) | Pieles, dientes | Aurora | Necesita domesticación |

- [ ] **Dificultad alta para modificar terreno.** El sistema de modificación de terreno (cavar, construir, moldear) debe tener dificultad MUY ALTA al inicio. El jugador debe subir de tier de herramientas y explorar bastante antes de poder modificar la isla libremente. Esto previene bugs tempranos (modificaciones accidentales del mundo,Softlocks, destrucción de zonas clave). Coherente con M13 (herramientas, tiers T1-T4), M156 (terrenos), M08 (mundo voxel). **Fecha:** 2026-09-03.

### 🟡 Media

- [ ] **Aviso al alejarse nadando.** Cuando el jugador se aleje demasiado de la isla nadando, mostrar un cartel/aviso tipo "¡No puedes alejarte de la isla! Es demasiado peligroso" con efecto visual (niebla, pantalla que se oscurece, oceano profundo). Definir radio de alejamiento máximo y qué pasa si insiste (daño gradual, teletransporte al spawn). Coherente con M08 (mundo voxel), M51 (agua), M11 (personaje). **Fecha:** 2026-09-03.

- [ ] **Identidad visual y ambiental por isla.** Cada isla podría tener sus propios bloques, colores, animales e iluminación o clima diferenciados. Definir si cada isla tiene: paleta propia de bloques/biomas, fauna exclusiva adicional a la distribución actual, iluminación ambiental distinta (hora dorada, neblina, auroras) o clima local opcional a M32. Objetivo: que el jugador perciba claramente que llegó a un lugar diferente sin depender solo de texto. Coherente con M09 (terreno), M27 (islas), M32 (clima), M36/M65 (fauna), M45/M50 (arte/vegetación). **Fecha:** 2026-09-04.

- [ ] **Estandarizar tamaños de objetos.** Buscar un parámetro de medida coherente para todos los objetos del juego. Problemas actuales: las palmeras y árboles se ven chicos, el cangrejo es casi del tamaño de la tortuga. Definir escala de referencia (ej: personaje = 1.8m, palmera = 4-6m, tortuga = 0.8m, cangrejo = 0.2m). Aplicable a M45 (tabla de polígonos/Assets 3D), M36 (Fauna), M50 (Vegetación), M08 (Mundo Voxel). **Fecha:** 2026-09-03.

  - [x] **Implementar tabla EscalasGlobales (M45/M50/M36/M19).** Autoload con tabla data-driven de 43 tipos (vegetación 15, fauna 9, NPCs 8, props 11) en `data/escalas/escalas.json`. Cualquier módulo consulta `EscalasGlobales.escala_de(tipo)`. **Decisión de rendimiento:** exportar GLBs con tamaño correcto desde Blender es lo ideal (normales correctas, colisiones match, física sin bugs); la tabla runtime es el parche pragmático para GLBs existentes. Transición: cuando M166 re-exporte con tamaños correctos → poner entrada a 1.0 → la tabla queda solo para objetos dinámicos. **Fecha:** 2026-09-04. **Log:** 645.

### 🟢 Baja

- [ ] **Cuevas solo accesibles por aberturas naturales.** El terreno será tan duro al inicio que la única forma de entrar en una cueva sea por una abertura natural visible en el mapa. No se podrá cavar libremente para llegar a cuevas. Esto refuerza la mecánica de dificultad alta de terreno y hace que explorar cuevas sea un hallazgo especial. Coherente con M08 (mundo voxel), M156 (terrenos), M13 (herramientas). **Fecha:** 2026-09-03.

- [ ] **Jaulas con datos del animal atrapado.** Las jaulas deben almacenar internamente qué animal contienen (especie, sexo, stats). El jugador puede inspeccionar la jaula para ver qué tiene dentro antes de intercambiar. Esto permite decidir strategicamente qué animales vale la pena atrapar y trasladar. Coherente con M65 (Animales IA), M14 (inventario), M39 (tiendas/intercambios). **Fecha:** 2026-09-03.

- [ ] **Objetos sólidos (árboles, rocas, edificios).** Los árboles, rocas grandes y edificios deben tener colisión sólida para que el jugador no pueda atravesarlos. Refuerza la inmersión y evita bugs de clipping. Coherente con M08 (mundo voxel), M45 (Assets 3D), M11 (personaje). **Fecha:** 2026-09-03.

- [ ] **Bordes suaves en cubos del terreno.** Para diferenciarse de Minecraft, investigar una lógica de "borde suave" (smooth edge) en los cubos visibles del terreno, especialmente en las esquinas donde se notan las caras cuadradas. Opciones: redondear vértices, usar shaders de blending entre bloques, o meshes con esquinas redondeadas. Objetivo: terreno voxel que se vea natural y fluido, no bloqueado. Coherente con M08 (mundo voxel), M156 (terrenos). **Fecha:** 2026-09-03.

- [ ] **Agregar un cerro más alto al terreno.** Añadir una elevación/cerro más alto en el mapa para dar variedad al relieve y crear un punto de referencia visual. Puede servir como zona de desafío o punto de observación. Coherente con M08 (mundo voxel), M156 (terrenos), M160 (ubicaciones). **Fecha:** 2026-09-03.