**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 15: Recursos

## ID del Módulo
- **Código:** M15 (CHECKLIST-GLOBAL: ID 15 — Recursos)
- **Carpeta:** `DOCUMENTACION/15-Recursos/`
- **Dependencias:** M14 (Inventario), M16 (Crafting), M08 (Mundo Voxel), M13 (Herramientas)
- **Delegable desde:** hoy (diseño completo; implementación al existir el mundo voxel M08 y las herramientas M13)

## 1. Problema

El mundo voxel de la isla debe entregar los materiales que el jugador necesita para crafting y construcción (M16/M17) de forma coherente, cómoda y cozy: cada árbol, roca, arbusto o yacimiento debe ser un nodo recolectable con definición clara (qué da, cuánto da, con qué herramienta se obtiene), y el mundo debe regenerar esos recursos sin que la isla quede pelada para siempre. Sin un sistema de recursos unificado, cada recolectable sería un script aparte, el balance se volvería inmanejable y el jugador castigado quedaría sin materiales (anti-cozy).

## 2. Alcance

### 2.1 Dentro del alcance
- Definición de los tipos de recurso: madera, piedra, fibras, comida, minerales y recursos raros (incluidos materiales ancestrales, estacionales y regionales del plan maestro).
- Nodos de recurso en el mundo (árboles, rocas, arbustos, yacimientos, plantas de comida) con estados intacto / dañado / agotado.
- Recolección por herramientas (M13): cada recurso declara qué herramienta lo recolecta y en cuántos golpes.
- Generación de drops (cantidad, dispersión, calidad según herramienta).
- Respawning con regla cozy: sin agotamiento irreparable; regeneración estacional y por eventos.
- Integración con M08 (Mundo Voxel): los nodos de recurso se anclan a voxeles/regiones del mundo.
- Integración con M14 (Inventario): los drops se agregan al inventario al recogerlos.
- Integración con M16 (Crafting): los recursos alimentan recetas; balance básico de cantidades.

### 2.2 Fuera del alcance
- La creación de recetas y su UI (M16).
- La interfaz del inventario (M14).
- La generación procedural del terreno y biomas (M08, M09).
- El sistema de herramientas en sí (M13): aquí solo se consume su señal de "golpe aplicado".
- Economía y venta de recursos (módulo de economía futuro).

## 3. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Tipos de recurso | Catálogo data-driven: madera, piedra, fibras, comida, minerales, recursos raros (ancestrales, estacionales, regionales) |
| RF2 | ResourceDefinition | Definición serializable por tipo: id, nombre, icono, categoría, rareza, drops, herramienta requerida, dureza (golpes), valor de venta, temporada de respawn |
| RF3 | ResourceNode | Nodo 3D en el mundo con estados: intacto / dañado / agotado; opcional a la herramienta; animación/feedback por golpe |
| RF4 | Herramienta requerida | Recurso sin herramienta necesaria (manos) o con herramienta mínima (ej: hacha para madera, pico para piedra/mineral) |
| RF5 | Drops | ResourceDrops: lista de ítems con cantidad mín/máx y probabilidad; caen al suelo con dispersión y física suave |
| RF6 | Recogida de drops | El jugador recoge drops al pasar por encima o al interactuar; se envían a M14 Inventario |
| RF7 | Respawning | ResourceSpawner: regeneración por estación (M29/M32) y por eventos (M73); sin agotamiento irreparable |
| RF8 | Regla cozy | Todo recurso agotado vuelve a aparecer; los tiempos de respawn son cortos y amables; nunca se pierde acceso permanente a un material |
| RF9 | Distribución | Los nodos se colocan según reglas por bioma/región (M08/M09); se respetan las zonas generadas |
| RF10 | Persistencia | Estado de cada nodo (agotado, tiempo restante de respawn) se guarda con la partida |
| RF11 | Balance | Cantidades por drop calibradas para que el jugador nunca "se quede sin poder jugar"; sin hambre castigadora (la comida es opcional o regenerativa) |
| RF12 | Feedback | Sonido, partículas y texto de cantidad al recolectar; el mundo reacciona visualmente (tocón, roca quebrada, arbusto sin frutos) |

## 4. Requisitos No Funcionales

- **Cozy:** cero frustración por falta de recursos; respawns generosos; sin castigos por no recolectar (sin hambre castigadora).
- **Rendimiento:** los nodos activos se limitan a la burbuja del jugador; los lejanos se desactivan (spawn budget); pooling de partículas y drops.
- **Determinismo suave:** PRNG de partida (M29) para cantidades y distribución de drops, coherencia entre guardados.
- **Data-driven:** toda la configuración vive en recursos de tipo `ResourceDefinition` (.tres) para que artistas y diseñadores no toquen código.
- **Desacoplamiento:** el módulo no conoce la UI; comunica resultados por señales (sección 9 de AGENTS.md).
- **Godot 4.x (>= 4.4.1):** GDScript tipado, GDExtension Voxel Tools para anclaje al mundo voxel (M08).

## 5. Criterios de Aceptación

1. Los 6 tipos de recurso están definidos y producen drops correctos con las herramientas de M13.
2. Un árbol/roca/arbusto se agota, muestra su estado y vuelve a aparecer según estación/evento (M29/M32/M73).
3. Los drops caen, se recogen y llegan al inventario M14 sin pérdidas ni duplicados.
4. Los recursos raros solo aparecen en su región/temporada y nunca se vuelven inaccesibles para siempre.
5. El estado de todos los nodos persiste entre sesiones (guardado/recarga).
6. En una sesión de prueba de 3 días de juego (M114), el jugador siempre encuentra material para su crafting inmediato (M16).
7. Rendimiento estable con el mundo poblado: sin picos de draw calls ni spawns masivos simultáneos (M61).

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M014** — Inventario | Recursos almacenados |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M016** — Crafting | Usado por crafting |
| **M038** — Economía | Usado por economía |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M014** — Inventario | Depende de este módulo |
| **M016** — Crafting | Este módulo lo necesita |
| **M038** — Economía | Este módulo lo necesita |

