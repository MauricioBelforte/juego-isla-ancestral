**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 73: Coleccionables

## ID del Módulo
- **Código:** M73 (CHECKLIST-GLOBAL: ID 73 — Coleccionables; plan maestro: sección 72 "COLECCIONABLES")
- **Carpeta:** `DOCUMENTACION/73-Coleccionables/`
- **Dependencias:** M71 (Progresión), M36 (Fauna), M37 (Museos y Colecciones). Relaciones: M50 (Plantas), M35 (Minerales), M34 (Pesca — peces), M33 (Agricultura — insectos), M25 (Ruinas — fósiles/reliquias), M14 (Inventario), M55 (Diario), M56 (Fotografía), M72 (Logros), M74 (Eventos), M16 (Crafting — herramientas), M18 (Casas — muebles), M46 (Arte 2D), M59 (Guardado), M87 (Localización)
- **Delegable desde:** M37 (museos/colecciones), M71 (progresión)

## 1. Problema

Aurora está llena de cosas por descubrir: reliquias, conchas, fósiles, cartas, documentos... El plan maestro lista 22 categorías de coleccionables. Sin un sistema central, el juego degenera en: ítems que se recolectan sin saber si son parte de una colección, sin registro de progreso (el jugador no sabe cuántas conchas faltan), sin recompensas por completar colecciones, o colecciones que duplican la lógica de M37 (museo) y M71 (progresión). El objetivo es un sistema único y simple: catálogo de coleccionables por categoría (22 tipos), registro automático de progreso por categoría, recompensas al completar colecciones y coordinación con museo (M37), diario (M55), logros (M72) y guardado (M59).

## 2. Objetivo

Definir el sistema de coleccionables de la isla: catálogo central de 22 categorías (reliquias, fragmentos, conchas, minerales, peces, plantas, insectos, fósiles, cartas, fotografías, muebles, ropa, herramientas especiales, documentos, mapas, símbolos, mensajes, secretos, objetos ancestrales, colecciones completas, recompensas y registro), con: registro automático al recolectar (eventos M07), progreso visible por categoría (diario M55/museo M37), colecciones completas con recompensas, y coordinación con logros (M72) y guardado (M59). El resultado debe ser el "hilo invisible" que une la exploración con la satisfacción: cada ítem recolectado cuenta, cada colección completada recompensa y nada se pierde.

## 3. Alcance

### 3.1 Dentro del alcance
- Catálogo central: 22 categorías de coleccionables con ítems únicos.
- Registro automático: al recolectar (M70), pescar (M34), cosechar (M33), minar (M35), explorar ruinas (M25), etc.
- Progreso por categoría: contadores y porcentajes (diario M55).
- Colecciones completas: recompensas (ítems, dinero M38, desbloqueos M71).
- Coordinación con museo (M37): donaciones y exhibición.
- Coordinación con logros (M72): colecciones como fuente de logros.
- Coordinación con guardado (M59): progreso persistente.
- Coordinación con diario (M55): entradas por categoría.
- Validación: `validate_collectibles.gd`.

### 3.2 Fuera del alcance
- El sistema de museo y exhibición: M37.
- El sistema de pesca/agricultura/minería en sí: M34/M33/M35 (aquí solo el registro de lo pescado).
- El sistema de logros: M72 (aquí solo la fuente de datos).
- El inventario físico: M14 (aquí solo el registro de colección).

## 4. Restricciones

- **UI Godot 4:** sección de colecciones en el diario (M55) y museo (M37).
- **Un solo registro:** el coleccionable se registra UNA vez (id unívoco); sin duplicados por recolectar dos veces.
- **Persistencia (M59):** progreso en GameState con schema_version.
- **Rendimiento:** catálogo estático (`.tres`); sin consultas por frame.
- **Cozy:** las recompensas son generosas y no bloquean la historia principal (M22).
- **Validable:** `validate_collectibles.gd` sin errores en consola.

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Catálogo central | 22 categorías con ítems únicos (id, nombre, descripción, icono) |
| RF2 | Registro automático | Eventos M07: recolectado/pescado/cosechado/minado/descubierto |
| RF3 | Reliquias | De ruinas (M25) y templos (M26) |
| RF4 | Fragmentos | De reliquias rotas (M25) |
| RF5 | Conchas | De la playa (M51) y eventos (M74) |
| RF6 | Minerales | De minería (M35) |
| RF7 | Peces | De pesca (M34) |
| RF8 | Plantas | De forrajeo (M33/M50) |
| RF9 | Insectos | De captura (M33/M36) |
| RF10 | Fósiles | De excavación (M25) |
| RF11 | Cartas | De festivales (M74) y correo |
| RF12 | Fotografías | De fotografía (M56) |
| RF13 | Muebles | De tiendas (M39) y regalos (M20) |
| RF14 | Ropa | De tiendas (M39) y eventos (M74) |
| RF15 | Herramientas especiales | De misiones (M22/M23) y crafting (M16) |
| RF16 | Documentos | De lore (M22) y ruinas (M25) |
| RF17 | Mapas | De exploración (M54) y tesoros (M71) |
| RF18 | Símbolos | De puzzles (M24/M26) |
| RF19 | Mensajes | De botellas y NPC (M21) |
| RF20 | Secretos | De acciones ocultas (M71) |
| RF21 | Objetos ancestrales | De la historia principal (M22) |
| RF22 | Colecciones completas y recompensas | Al completar una categoría: recompensa + notificación |

## 6. Criterios de Aceptación (Verificables)

1. Las 22 categorías del plan maestro existen en el catálogo con ítems únicos.
2. Recolectar un ítem lo registra UNA vez (sin duplicados) y actualiza el progreso.
3. El progreso por categoría se muestra en el diario (M55) y museo (M37).
4. Completar una colección otorga la recompensa definida y notifica (M44).
5. El progreso persiste entre sesiones (M59) sin duplicados ni pérdidas.
6. Los logros (M72) reciben el progreso real de las colecciones.
7. Las recompensas no bloquean la historia principal (M22).
8. `validate_collectibles.gd` pasa sin errores.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M036** — Fauna | Base para fauna |
| **M071** — Progresión | Coleccionables sobre progresión |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M036** — Fauna | Depende de este módulo |
| **M071** — Progresión | Depende de este módulo |

