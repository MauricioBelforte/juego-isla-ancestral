**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 46: Arte 2D

## A. Problema y objetivos

- [x] Definir el problema: sin dirección 2D, iconos/retratos/UI se sienten de otro juego e incoherentes con el 3D [S]
- [x] Definir el objetivo: guía de estilo 2D heredada del 3D, bancos de iconos/retratos, atlas y validación [S]
- [x] Registrar dependencias: M45 (3D), M53 (UI), M88 (fuentes), M14 (iconos), M47 (texturas), M57 (input), M108 (pipeline) [S]
- [x] Mapear la sección 45 "ARTE 2D" del plan maestro al ID 46 de la tabla global (desfase de numeración) [M]
- [x] Separar dentro/fuera de alcance: layout de UI → M53, fuentes → M88, animación → M48, texturas 3D → M47 [S]
- [x] Documentar restricciones: estilo heredado, sin texto en arte, atlas ≤2K, resoluciones estándar, SVG fuente [S]
- [x] Definir criterios de aceptación verificables (8 criterios) [S]
- [x] Incluir contexto del plan de producción §4: paleta pastel, "el juego cozy vive y muere por sus menús" [M]

## B. RF1 — Guía de estilo 2D

- [x] Definir ART_STYLE_2D.md derivado de M45: paleta, trazo, sombreado, redondeo [M]
- [x] Definir trazo exterior redondeado 2-3 px a 128 px [S]
- [x] Definir sombra plana inferior 10% [S]
- [x] Prohibir gradientes complejos, ruido, texturas foto, neón [S]
- [x] Definir recetas visuales por familia de iconos [M]

## C. RF2 — Logo

- [x] Definir logo principal + variante clara/oscura + icono solo [M]
- [x] Definir fuentes SVG y raster 1024 [S]
- [x] Definir submarca para iconos de plataforma (Steam M97) [S]

## D. RF3 — Banco de iconos de objetos

- [x] Definir iconos de todos los ítems de M14/M15 con claves i18n [M]
- [x] Definir tamaño de trabajo 128×128 [S]
- [x] Definir legibilidad mínima 32 px (prueba obligatoria) [M]
- [x] Definir fondo de rareza por color según M38 [M]
- [x] Definir ángulo canónico 3/4 con plantilla 3D [M]

## E. RF4 — Iconos de herramientas

- [x] Definir iconos de 9 herramientas × 4 niveles (M13) [M]
- [x] Definir diferencias visuales de nivel (mango, hoja, aura) [M]
- [x] Definir variante de nivel 4 ancestral con símbolo [S]

## F. RF5 — Retratos (portraits)

- [x] Definir retrato de cada NPC (M19) y jugador [M]
- [x] Definir 5 expresiones base: base, alegre, triste, sorprendido, pensativo [M]
- [x] Definir +3 expresiones extra para NPCs románticos (M20) [M]
- [x] Definir plantilla 3D obligatoria (render del modelo + repintado) [M]
- [x] Definir tamaño 256×256 y prueba a 96 px [S]

## G. RF6 — Iconos de UI

- [x] Definir iconos de acciones (M57): interactuar, atacar, saltar, menú [M]
- [x] Definir botones, marcos y paneles como slice9 para M53 [M]
- [x] Definir estados visuales: normal, hover, pressed, disabled [M]

## H. RF7 — Símbolos ancestrales

- [x] Definir set de símbolos para M24/M25/M26 sin palabras [M]
- [x] Definir geometría suave y reutilizable [S]
- [x] Definir símbolos en superficies: ruinas, templos, sellos [M]

## I. RF8 — Mapas antiguos

- [x] Definir ilustración pergamino para mapas del tesoro (M25) [M]
- [x] Definir estilo con safe zone central para UI [S]
- [x] Definir integración con M54 (mapa) como skin artística opcional [M]

## J. RF9 — Insignias y emblemas

- [x] Definir marco común de insignias (círculo + figura + borde de rareza) [M]
- [x] Definir tamaño grande 100 px y pequeño 48 px [S]
- [x] Definir integración con logros (M72) y sellos (M22) [M]
- [x] Definir fondo de museo para coleccionables (M37) [S]

## K. RF10 — Ilustraciones de carga

- [x] Definir pantallas de carga con arte de Aurora [M]
- [x] Definir formato 1024×1024 con área de texto libre [S]
- [x] Definir integración con M63 (progreso real sobre el arte) [M]

## L. RF11 — Pérdida de cámara / minimapa

- [x] Definir icono del jugador en mapa/minimapa coherente con personaje 3D [M]
- [x] Definir variante de dirección (heading) para minimapa [S]

## M. RF12 — Atlas por superficie

- [x] Definir ui_atlas, icons_atlas, portraits_atlas, story_atlas, badges_atlas [M]
- [x] Definir límite 2048×2048 por atlas [S]
- [x] Definir padding ≥ 2 px [S]
- [x] Definir sin rotaciones en empaquetado [S]
- [x] Definir regeneración por script (pack_atlas.gd) [M]

## N. RF13 — Convenciones de formato

- [x] Definir SVG como fuente editable (Inkscape/Krita) [S]
- [x] Definir PNG/WebP como runtime (M108) [S]
- [x] Definir transparencia sin halos (alfa limpio) [M]
- [x] Definir tamaños múltiplos de 4 (compresión) [S]

## O. RF14 — Validación de pieza

- [x] Definir script validate_2d.gd en Assets/_Project/Editor/ [M]
- [x] Verificar formato y tamaño cuadrado permitido [S]
- [x] Verificar resolución múltiplo de 4 [S]
- [x] Verificar alfa sin halos en bordes [M]
- [x] Verificar duplicados de id contra catálogo [M]
- [x] Verificar convenciones de nombres por tipo [S]

## P. RF15 — Convenciones de nombres

- [x] Definir prefijos: ico_, pt_, illus_, sym_, badge_, ui_art_ [S]
- [x] Alinear con M108 (Pipeline de Assets) [M]
- [x] Definir sufijos de variantes de expresión (pt_<npc>_alegre) [S]

## Q. RF16 — Sin texto embebido

- [x] Definir regla dura: 0 textos en arte [S]
- [x] Documentar que M87/M88 superponen todo texto [M]
- [x] Incluir verificación de regiones de texto en el validador [M]

## R. Requisitos no funcionales

- [x] Legibilidad a 32 px con contraste AA (M58) [M]
- [x] Consistencia: un solo set de iconos en todas las superficies [M]
- [x] Rendimiento: atlas únicos, carga diferida (M63), sin duplicados (M62) [M]
- [x] Cozy: colores amables, sin parpadeos, insignias que celebran [M]
- [x] Mantenible: SVG editable, regeneración por script [M]
- [x] Accesibilidad: variantes de alto contraste separadas [M]

## S. Alternativas consideradas

- [x] Descartar iconos sin referencia 3D (incoherencia) [M]
- [x] Descartar retratos por IA directa (inconsistencia + legal) [M]
- [x] Descartar un solo atlas gigante (memoria M62) [M]
- [x] Descartar texto embebido (localización M87) [M]
- [x] Adoptar atlas por superficie + SVG fuente [M]

## T. Riesgos y mitigaciones

- [x] Riesgo de iconos incoherentes → guía + recetas + review [M]
- [x] Riesgo de retratos que no parecen al NPC → plantilla 3D + comparación [M]
- [x] Riesgo de atlas descontrolados → límite 2K + regeneración [M]
- [x] Riesgo de texto en arte → regla dura + validador [M]
- [x] Riesgo de memoria por texturas 2D → compresión + carga diferida [M]

## U. Integraciones

- [x] Documentar integración con M45 (plantillas 3D, catálogo compartido) [S]
- [x] Documentar integración con M53 (piezas UI) [S]
- [x] Documentar integración con M87 (localización, cero texto) [S]
- [x] Documentar integración con M88 (fuentes) [S]
- [x] Documentar integración con M63 (carga diferida) [S]
- [x] Documentar integración con M62 (memoria) [S]
- [x] Documentar integración con M108 (importación) [S]
- [x] Documentar integración con M72/M22/M37 (insignias, sellos, coleccionables) [M]
- [x] Documentar integración con M58 (accesibilidad) [M]

## V. Herramientas y flujos

- [x] Documentar flujo de creación de icono (plantilla 3D → ilustrar → validar → atlas) [M]
- [x] Documentar flujo de creación de retrato (render → repintado → expresiones → atlas) [M]
- [x] Documentar flujo de empaquetado (pack_atlas.gd) [M]
- [x] Documentar herramientas: Inkscape, Krita, Blender para renders [S]
- [x] Documentar uso de IA como base + repintado (M86) [M]

## W. Criterios de aceptación verificados

- [x] ART_STYLE_2D.md permite dibujar sin preguntar [M]
- [x] Icono de cada objeto legible a 32 px en inventario y tienda [M]
- [x] Retrato del NPC se parece al modelo 3D (comparación lado a lado) [M]
- [x] Símbolos ancestrales sin texto reutilizables [M]
- [x] Atlas con carga diferida sin duplicados en memoria [M]
- [x] Validador rechaza pieza con resolución o halo incorrectos [M]
- [x] Botón con texto usa fuente M88, nunca arte [M]
- [x] Piezas cumplen M108 y Git LFS [M]

## X. Notas finales

- [x] Documentar el desfase de numeración del plan maestro (45=ARTE 2D → ID 46) [S]
- [x] Marcar el módulo como DELEGABLE PARA IMPLEMENTAR [S]
- [x] Registrar dependencia de implementación con el hito M1 (proyecto Godot) [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
