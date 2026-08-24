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

- [ ] **Resolver cantidad de NPCs.** M19 define 8-12 vecinos con 8 ejemplos. M161/M162 documentan 23 NPCs. Hay que definir cuántos NPCs hay realmente en el juego. **Fecha:** 2026-08-23. **Acción:** decidir cantidad final y alinear M19/M161/M162.

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