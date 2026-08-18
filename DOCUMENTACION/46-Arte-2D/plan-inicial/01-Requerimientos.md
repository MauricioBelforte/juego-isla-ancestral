**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 46: Arte 2D

## ID del Módulo
- **Código:** M46 (CHECKLIST-GLOBAL: ID 46 — Arte 2D; plan maestro: sección 45 "ARTE 2D")
- **Carpeta:** `DOCUMENTACION/46-Arte-2D/`
- **Dependencias:** M45 (Arte 3D — coherencia de estilo), M53 (UI/UX — superficie de la UI), M88 (Fuentes Tipográficas), M14 (Inventario — iconos de objetos), M47 (Texturas — atlas), M57 (Interfaz de Control — iconos de input). Relaciones: M22/M23 (ilustraciones narrativas), M24/M25/M26 (símbolos ancestrales, mapas antiguos), M37 (Museos — coleccionables), M108 (Pipeline de Assets)
- **Delegable desde:** M53 (UI confirmada), M45 (guía de estilo 3D unificada), M88 (fuentes definidas)

## 1. Problema

Aurora es un mundo voxel cozy con una fuerte identidad visual 3D (M45), pero el jugador pasa gran parte del tiempo mirando superficies 2D: el inventario (M14), los menús (M53), el mapa (M54), los diálogos (M21) y las pantallas de crafteo (M16). Sin una dirección de arte 2D definida, estos elementos corren el riesgo de parecer "otro juego": iconos con estilos dispares, ilustraciones de retratos que no se parecen a los NPCs 3D (M19), resoluciones inconsistentes, atlas mal empaquetados y textos ilegibles. El plan maestro lo pide explícitamente: logo, iconos, UI, mapas, ilustraciones, retratos, pantallas, botones, inventario, iconos de objetos/materiales/herramientas, símbolos ancestrales, mapas antiguos, textos de ruinas, coleccionables, insignias y emblemas. Un arte 2D mal planificado duplica trabajo (cada icono re-hecho), rompe la promesa cozy (UI fría o sobrecargada) y malgasta presupuesto de texturas (M62).

## 2. Objetivo

Definir el sistema de arte 2D del juego: guía de estilo 2D derivada de la 3D (M45), atlas y resoluciones estándar por superficie, banco de iconos (objetos, materiales, herramientas, habilidades), retratos de NPCs coherentes con los modelos 3D, ilustraciones narrativas (mapas, ruinas, símbolos), insignias/emblemas, convenciones de empaquetado (atlas) y compresión, y un pipeline de revisión. El resultado debe ser un catálogo de requisitos verificables que garantice que cualquier pieza 2D se sienta del mismo juego que el mundo voxel.

## 3. Alcance

### 3.1 Dentro del alcance
- Guía de estilo 2D: paleta, trazos, redondeo y sombreado derivados de M45 y M152.
- Logo del juego y submarca (iconos de app/plataforma).
- Banco de iconos: objetos, materiales, herramientas, recursos, peces, cultivos, etc. (M14/M15/M13/M33/M34/M35).
- Retratos de diálogo (portraits) de NPCs y jugador, coherentes con los modelos 3D (M19/M11).
- Ilustraciones: pantallas de carga, mapas antiguos, textos de ruinas (M24/M25), minimapa artístico (M54).
- Símbolos ancestrales, insignias y emblemas (logros M72, sellos de historia M22, coleccionables M37).
- Botones, marcos, paneles y decoraciones de UI (M53) — como *especificación*; el layout es de M53.
- Convenciones de resolución, formato, atlas, compresión y transparencias.
- Carpetas y nombres de assets (alineados a M108).

### 3.2 Fuera del alcance
- Layout, navegación y jerarquía visual de la UI (M53).
- Fuentes tipográficas (M88) — aquí solo se garantiza el contraste de iconos frente al texto.
- Animación de UI y sprites animados (M48).
- Texturas/materials 3D (M47).
- Iconografía de accesibilidad específica (M58 la consume, no la define).
- El empaquetado técnico final en Godot (atlas AtlasTexture, import settings) pertenece a M108.

## 4. Restricciones

- **Estilo:** derivado del 3D (M45): paleta pastel, redondeado suave, sombras planas; prohibido el detalle realista.
- **Coherencia:** todo icono/retrato/ilustración debe poder compararse cara a cara con su referencia 3D.
- **Rendimiento:** atlas únicos por superficie, resolución máxima definida (2K por atlas, 1K por defecto), compresión obligatoria (M108).
- **Resoluciones estándar:** iconos 128×128 (objetos), 256×256 (retratos), 512×512 (ilustraciones), 1024×1024 máx (pantallas).
- **Escalabilidad:** diseño vectorial (SVG) como fuente editable; PNG/WebP para runtime (M108).
- **Localización (M87):** textos NUNCA embebidos en arte; iconos sin texto, o con texto en capa separada.
- **Desacoplamiento:** el arte 2D es contenido puro (texturas/atlas); la UI solo referencia recursos, no rutas.
- **Validable:** checklist de revisión de pieza 2D (estilo, resolución, padding, transparencia).

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Guía de estilo 2D | Documento `ART_STYLE_2D.md` derivado de M45: paleta, trazo, sombreado, redondeo |
| RF2 | Logo | Logo principal + variantes (claro/oscuro, ícono solo) en SVG y raster 1024 |
| RF3 | Banco de iconos de objetos | Iconos de todos los ítems de M14/M15 con claves i18n y tamaños estándar |
| RF4 | Iconos de herramientas | 9 herramientas × 4 niveles (M13) con variantes de nivel distinguibles |
| RF5 | Retratos (portraits) | Retrato de cada NPC (M19) y jugador: expresión base + variantes emocionales (M21) |
| RF6 | Iconos de UI | Acciones (M57), estados, botones, marcos y paneles según M53 |
| RF7 | Símbolos ancestrales | Set de símbolos para ruinas/templos (M24/M25/M26) sin palabras |
| RF8 | Mapas antiguos | Ilustración tipo pergamino para el mapa del tesoro / ruinas (M25, M54) |
| RF9 | Insignias y emblemas | Logros (M72), sellos (M22), coleccionables (M37) |
| RF10 | Ilustraciones de carga | Pantallas de carga con arte de Aurora (M63 carga con progreso real) |
| RF11 | Pérdida de cámara | Icono del jugador en mapas/minimapa (M54) coherente con el personaje |
| RF12 | Atlas por superficie | Empaquetado en atlas separados: ui_atlas, icons_atlas, portraits_atlas, story_atlas |
| RF13 | Convenciones de formato | SVG fuente; PNG/WebP runtime; transparencia sin halos; padding estándar |
| RF14 | Validación de pieza | Script `validate_2d.gd` (editor): tamaño, resolución, transparencia, duplicados |
| RF15 | Convenciones de nombres | Prefijos `ico_`, `pt_`, `illus_`, `sym_`, `badge_`, `ui_art_` (M108) |
| RF16 | Sin texto embebido | 0 textos en arte; todo texto es capa de M87/M88 |

## 6. Requisitos No Funcionales

- **Legibilidad:** iconos legibles a 32 px (tamaño mínimo de display en UI); contraste mínimo AA (M58).
- **Consistencia:** un solo set de iconos para el mismo objeto en todas las superficies (inventario, tienda, crafteo).
- **Rendimiento:** atlas únicos (≤2K), carga diferida por superficie (M63), sin texturas duplicadas en memoria (M62).
- **Cozy:** colores amables, sin brillos agresivos, sin parpadeos; las insignias celebran, no presionan.
- **Mantenible:** fuentes vectoriales editables; regeneración de atlas por script (M108).
- **Accesibilidad (M58):** variantes de alto contraste opcionales declaradas como recursos separados.

## 7. Criterios de Aceptación

1. El `ART_STYLE_2D.md` existe, deriva de M45 y un recién llegado puede dibujar una pieza sin preguntar.
2. El icono de cada objeto (M14) comparte familia visual y es legible a 32 px en inventario y tienda.
3. El retrato del NPC en diálogo se parece al modelo 3D del mismo NPC (comparación lado a lado).
4. Los símbolos ancestrales no contienen texto y se reutilizan en ruinas y templos sin rediseño.
5. El atlas de la UI funciona con la carga diferida (M63) y no hay texturas duplicadas en memoria.
6. El validador rechaza una pieza 2D con resolución incorrecta o transparencia con halo, con mensaje accionable.
7. Un botón con texto usa la fuente M88 (nunca arte con texto embebido).
8. Todas las piezas cumplen las convenciones de nombres de M108 y están trackeadas en Git LFS.

## 8. Fuentes de Contexto (plan maestro)

- Sección 45 "ARTE 2D": logo, iconos, UI, mapas, ilustraciones, retratos, pantallas, botones, inventario, iconos de objetos/materiales/herramientas, símbolos ancestrales, mapas antiguos, textos de ruinas, coleccionables, insignias, emblemas, definición de resolución/formato/atlas/compresión/transparencias y guías de estilo.
- Plan de producción §4: dirección de arte, paleta pastel, consistencia visual UI ("juego cozy vive y muere por lo agradable que se siente navegar sus menús").
- M152: calidad > cantidad; performance prioridad sobre visuales.