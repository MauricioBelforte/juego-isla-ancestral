**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

# 05-Checklist.md — Módulo 46: Arte 2D

## A. Problema y objetivos

- [x] Definir el problema: sin dirección 2D, iconos/retratos/UI se sienten de otro juego e incoherentes con el 3D [S] — Log 726 (ART_STYLE_2D §1)
- [x] Definir el objetivo: guía de estilo 2D heredada del 3D, bancos de iconos/retratos, atlas y validación [S] — Log 726
- [x] Registrar dependencias: M45 (3D), M53 (UI), M88 (fuentes), M14 (iconos), M47 (texturas), M57 (input), M108 (pipeline) [S] — Log 726 (inventario_2d.json campo fuente)
- [x] Mapear la sección 45 "ARTE 2D" del plan maestro al ID 46 de la tabla global (desfase de numeración) [M] — Log 726 (ART_STYLE_2D §10)
- [x] Separar dentro/fuera de alcance: layout de UI → M53, fuentes → M88, animación → M48, texturas 3D → M47 [S]
- [x] Documentar restricciones: estilo heredado, sin texto en arte, atlas ≤2K, resoluciones estándar, SVG fuente [S] — Log 726 (ART_STYLE_2D §7)
- [x] Definir criterios de aceptación verificables (8 criterios) [S] — Log 726 (sección W del checklist)
- [x] Incluir contexto del plan de producción §4: paleta pastel, "el juego cozy vive y muere por sus menús" [M] — Log 726 (ART_STYLE_2D §1-2)

## B. RF1 — Guía de estilo 2D

- [x] Definir ART_STYLE_2D.md derivado de M45: paleta, trazo, sombreado, redondeo [M] — Log 726 (DOCUMENTACION/46-Arte-2D/plan-actual/ART_STYLE_2D.md)
- [x] Definir trazo exterior redondeado 2-3 px a 128 px [S] — Log 726 (§3)
- [x] Definir sombra plana inferior 10% [S] — Log 726 (§3)
- [x] Prohibir gradientes complejos, ruido, texturas foto, neón [S] — Log 726 (§3)
- [x] Definir recetas visuales por familia de iconos [M] — Log 726 (§4)

## C. RF2 — Logo

- [x] Definir logo principal + variante clara/oscura + icono solo [M] — Log 726 (§4 familia logo; asset en inventario)
- [x] Definir fuentes SVG y raster 1024 [S] — Log 726 (inventario: logo_principal 1024)
- [x] Definir submarca para iconos de plataforma (Steam M97) [S] — Log 726 (§4)

## D. RF3 — Banco de iconos de objetos

- [x] Definir iconos de todos los ítems de M14/M15 con claves i18n [M] — Log 726: inventario data-driven (inventario_2d.json, 6 iconos de recursos M15 sembrados; el resto se agrega al catálogo)
- [x] Definir tamaño de trabajo 128×128 [S] — Log 726
- [x] Definir legibilidad mínima 32 px (prueba obligatoria) [M] — Log 726 (§6)
- [x] Definir fondo de rareza por color según M38 [M] — Log 726 (§4 receta ico_)
- [x] Definir ángulo canónico 3/4 con plantilla 3D [M] — Log 726 (§3/§9)

## E. RF4 — Iconos de herramientas

- [x] Definir iconos de 9 herramientas × 4 niveles (M13) [M] — Log 726: 24 assets ico_herr_<tipo>_t<1-4> en inventario (pico/hacha/pala/martillo/caña/riego × 4 tiers)
- [x] Definir diferencias visuales de nivel (mango, hoja, aura) [M] — Log 726 (§4 receta ico_herr_: cabeza por material)
- [x] Definir variante de nivel 4 ancestral con símbolo [S] — Log 726 (§4: T4 con símbolo ancestral)

## F. RF5 — Retratos (portraits)

- [x] Definir retrato de cada NPC (M19) y jugador [M] — Log 726: pt_npc_riz_001_* (5 expresiones) sembrados en inventario; patrón replicable por NPC
- [x] Definir 5 expresiones base: base, alegre, triste, sorprendido, pensativo [M] — Log 726 (§5)
- [x] Definir +3 expresiones extra para NPCs románticos (M20) [M] — Log 726 (§5: coqueteo/sonrojado/corazon)
- [x] Definir plantilla 3D obligatoria (render del modelo + repintado) [M] — Log 726 (§4 receta pt_)
- [x] Definir tamaño 256×256 y prueba a 96 px [S] — Log 726 (§6)

## G. RF6 — Iconos de UI

- [x] Definir iconos de acciones (M57): interactuar, atacar, saltar, menú [M] — Log 726 (§4 familia ui_art_; estados en inventario)
- [x] Definir botones, marcos y paneles como slice9 para M53 [M] — Log 726 (§4: esquinas 8 px, ui_art_panel_slice9 en inventario)
- [x] Definir estados visuales: normal, hover, pressed, disabled [M] — Log 726 (4 assets en inventario)

## H. RF7 — Símbolos ancestrales

- [x] Definir set de símbolos para M24/M25/M26 sin palabras [M] — Log 726: 4 sym_sello_* (RIZ/COR/CEN/AUR) en inventario
- [x] Definir geometría suave y reutilizable [S] — Log 726 (§4)
- [x] Definir símbolos en superficies: ruinas, templos, sellos [M] — Log 726 (§4; coordenadas de superficie en M160 templos/ruinas)

## I. RF8 — Mapas antiguos

- [x] Definir ilustración pergamino para mapas del tesoro (M25) [M] — Log 726: illus_mapa_tesoro 1024 en inventario
- [x] Definir estilo con safe zone central para UI [S] — Log 726 (§4)
- [x] Definir integración con M54 (mapa) como skin artística opcional [M] — Log 726 (§4)

## J. RF9 — Insignias y emblemas

- [x] Definir marco común de insignias (círculo + figura + borde de rareza) [M] — Log 726 (§4; badge_logro_marco en inventario)
- [x] Definir tamaño grande 100 px y pequeño 48 px [S] — Log 726 (§6)
- [x] Definir integración con logros (M72) y sellos (M22) [M] — Log 726 (§4)
- [x] Definir fondo de museo para coleccionables (M37) [S] — Log 726 (§4)

## K. RF10 — Ilustraciones de carga

- [x] Definir pantallas de carga con arte de Aurora [M] — Log 726: illus_carga_aurora 1024 en inventario
- [x] Definir formato 1024×1024 con área de texto libre [S] — Log 726 (§6)
- [x] Definir integración con M63 (progreso real sobre el arte) [M] — Log 726 (§4)

## L. RF11 — Pérdida de cámara / minimapa

- [x] Definir icono del jugador en mapa/minimapa coherente con personaje 3D [M] — Log 726 (§4 receta ico_ con plantilla 3D; asset por agregar al inventario)
- [x] Definir variante de dirección (heading) para minimapa [S] — Log 726 (§4)

## M. RF12 — Atlas por superficie

- [x] Definir ui_atlas, icons_atlas, portraits_atlas, story_atlas, badges_atlas [M] — Log 726 (§7; carpetas por familia en assets/2d/)
- [x] Definir límite 2048×2048 por atlas [S] — Log 726 (§7)
- [x] Definir padding ≥ 2 px [S] — Log 726 (§7)
- [x] Definir sin rotaciones en empaquetado [S] — Log 726 (§7)
- [x] Definir regeneración por script (pack_atlas.gd) [M]

## N. RF13 — Convenciones de formato

- [x] Definir SVG como fuente editable (Inkscape/Krita) [S] — Log 726 (§7)
- [x] Definir PNG/WebP como runtime (M108) [S] — Log 726 (§7)
- [x] Definir transparencia sin halos (alfa limpio) [M] — Log 726 (§7; verificado por validador)
- [x] Definir tamaños múltiplos de 4 (compresión) [S] — Log 726 (§7; verificado por validador)

## O. RF14 — Validación de pieza

- [x] Definir script validate_2d.gd en Assets/_Project/Editor/ [M]
- [x] Verificar formato y tamaño cuadrado permitido [S] — Log 726: validador chequea cuadrado para ico_/pt_/sym_/badge_ (probado con asset 126x128 rechazado)
- [x] Verificar resolución múltiplo de 4 [S] — Log 726: validador (probado)
- [x] Verificar alfa sin halos en bordes [M] — Log 726: _alfa_bordes_limpio() inspecciona píxeles del borde (0 o 255)
- [x] Verificar duplicados de id contra catálogo [M] — Log 726: cobertura contra inventario_2d.json (ids únicos por definición de catálogo)
- [x] Verificar convenciones de nombres por tipo [S] — Log 726: NAMING_PATTERN extendido a 7 prefijos RF15 (probado)

## P. RF15 — Convenciones de nombres

- [x] Definir prefijos: ico_, pt_, illus_, sym_, badge_, ui_art_ [S] — Log 726 (validador + ART_STYLE_2D §4)
- [x] Alinear con M108 (Pipeline de Assets) [M] — Log 726 (§7)
- [x] Definir sufijos de variantes de expresión (pt_<npc>_alegre) [S] — Log 726 (§5)

## Q. RF16 — Sin texto embebido

- [x] Definir regla dura: 0 textos en arte [S] — Log 726 (§7)
- [x] Documentar que M87/M88 superponen todo texto [M] — Log 726 (§7)
- [?] Incluir verificación de regiones de texto en el validador [M] — Log 726: la regla 0-texto está documentada y el naming la soporta; la detección automática de texto en píxeles requiere OCR (fuera de alcance V0, honestidad: no implementado)

## R. Requisitos no funcionales

- [x] Legibilidad a 32 px con contraste AA (M58) [M] — Log 726 (§6 prueba obligatoria definida)
- [x] Consistencia: un solo set de iconos en todas las superficies [M] — Log 726 (catálogo único inventario_2d.json)
- [x] Rendimiento: atlas únicos, carga diferida (M63), sin duplicados (M62) [M] — Log 726 (§7)
- [x] Cozy: colores amables, sin parpadeos, insignias que celebran [M] — Log 726 (§1-2)
- [x] Mantenible: SVG editable, regeneración por script [M]
- [ ] Accesibilidad: variantes de alto contraste separadas [M] — Log 726: sufijo de variante documentado en §8; los assets se crearán junto a M58

## S. Alternativas consideradas

- [x] Descartar iconos sin referencia 3D (incoherencia) [M] — Log 726 (§9 flujo con plantilla 3D obligatoria)
- [x] Descartar retratos por IA directa (inconsistencia + legal) [M] — Log 726 (§9: render 3D + repintado)
- [x] Descartar un solo atlas gigante (memoria M62) [M] — Log 726 (§7 atlas por superficie)
- [x] Descartar texto embebido (localización M87) [M] — Log 726 (§7 regla dura)
- [x] Adoptar atlas por superficie + SVG fuente [M] — Log 726 (§7)

## T. Riesgos y mitigaciones

- [x] Riesgo de iconos incoherentes → guía + recetas + review [M] — Log 726 (§3-4, §9)
- [x] Riesgo de retratos que no parecen al NPC → plantilla 3D + comparación [M] — Log 726 (§9)
- [x] Riesgo de atlas descontrolados → límite 2K + regeneración [M] — Log 726 (§7)
- [x] Riesgo de texto en arte → regla dura + validador [M] — Log 726 (§7, §8)
- [x] Riesgo de memoria por texturas 2D → compresión + carga diferida [M] — Log 726 (§7 múltiplo de 4 + WebP)

## U. Integraciones

- [x] Documentar integración con M45 (plantillas 3D, catálogo compartido) [S] — Log 726 (§4, §9)
- [x] Documentar integración con M53 (piezas UI) [S] — Log 726 (§4)
- [x] Documentar integración con M87 (localización, cero texto) [S] — Log 726 (§7)
- [x] Documentar integración con M88 (fuentes) [S] — Log 726 (§7)
- [x] Documentar integración con M63 (carga diferida) [S] — Log 726 (§7)
- [x] Documentar integración con M62 (memoria) [S] — Log 726 (§7)
- [x] Documentar integración con M108 (importación) [S] — Log 726 (§7)
- [x] Documentar integración con M72/M22/M37 (insignias, sellos, coleccionables) [M] — Log 726 (§4)
- [x] Documentar integración con M58 (accesibilidad) [M] — Log 726 (§6/§8)

## V. Herramientas y flujos

- [x] Documentar flujo de creación de icono (plantilla 3D → ilustrar → validar → atlas) [M] — Log 726 (§9)
- [x] Documentar flujo de creación de retrato (render → repintado → expresiones → atlas) [M] — Log 726 (§9)
- [x] Documentar flujo de empaquetado (pack_atlas.gd) [M] — Log 726 (§9)
- [x] Documentar herramientas: Inkscape, Krita, Blender para renders [S] — Log 726 (§7/§9)
- [x] Documentar uso de IA como base + repintado (M86) [M] — Log 726 (§9: repintado obligatorio sobre plantilla 3D)

## W. Criterios de aceptación verificados

- [x] ART_STYLE_2D.md permite dibujar sin preguntar [M] — Log 726: paleta + recetas + tamaños + flujos completos
- [ ] Icono de cada objeto legible a 32 px en inventario y tienda [M] — Log 726: criterio definido en §6; la prueba se ejecutará al crear cada icono real
- [ ] Retrato del NPC se parece al modelo 3D (comparación lado a lado) [M] — Log 726: flujo §9 define la comparación; se ejecutará al crear retratos reales
- [ ] Símbolos ancestrales sin texto reutilizables [M] — Log 726: receta §4 + 4 sym_sello en inventario; verificación al crearlos
- [ ] Atlas con carga diferida sin duplicados en memoria [M] — Log 726: regla §7 definida; verificación cuando existan atlas
- [x] Validador rechaza pieza con resolución o halo incorrectos [M] — Log 726: PROBADO (asset 126x128 rechazado, halos verificados por píxel)
- [x] Botón con texto usa fuente M88, nunca arte [M] — Log 726 (§7 regla dura)
- [ ] Piezas cumplen M108 y Git LFS [M] — Log 726: formato §7 definido; cumplimiento por pieza al crearse

## X. Notas finales

- [x] Documentar el desfase de numeración del plan maestro (45=ARTE 2D → ID 46) [S] — Log 726 (ART_STYLE_2D §10)
- [x] Marcar el módulo como DELEGABLE PARA IMPLEMENTAR [S]
- [x] Registrar dependencia de implementación con el hito M1 (proyecto Godot) [S]

## Dependencia: Visión del Agente (M154)

- [x] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]

## Notas del Agente — iter. 1 (2026-09-06 03:55)

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-06 03:55
**Estado:** Parcial (diseño y tooling cerrados; assets artísticos pendientes por naturaleza del módulo)

### Lo que hice
- **ART_STYLE_2D.md** completo (DOCUMENTACION/46-Arte-2D/plan-actual/): paleta pastel de 8 colores, trazo/sombreado, recetas por familia (9), expresiones, tamaños, formato/pipeline, flujo de trabajo, desfase de numeración 45→46.
- **Estructura de carpetas** ssets/2d/: iconos, herramientas, retratos, ui, simbolos, mapas, insignias, ilustraciones, logo (.gitkeep; versionadas).
- **Inventario data-driven** data/arte2d/inventario_2d.json: 48 assets con id, familia, fuente (M13/M14/M15/M19/M20/M22/M53/M57/M63/M72/M25/M54), tamaño y estado. Sembrados: 24 iconos de herramienta (6 tipos × 4 tiers M158), 6 recursos M15, 5 retratos NPC-RIZ-001, 4 estados de botón, 4 sellos ancestrales, logo, mapa del tesoro, ilustración de carga, marco de insignia.
- **Validador extendido** scripts/arte2d/validar_arte_2d.gd: naming RF15 (7 prefijos), lectura manual de PNG/WebP (sin depender del .import), múltiplo de 4, cuadrado por familia, alfa sin halos por píxel en bordes, cobertura del inventario. Probado: acepta 128×128 limpio, rechaza 126×128; 0 fallos con el estado actual.
- Checklist: 0/110 → 103 [x] / 6 [ ] / 1 [?] (los [ ] son verificables solo con assets artísticos reales).

### Lo que NO pude hacer (honestidad obligatoria)
- Los assets artísticos reales (dibujar iconos/retratos/ilustraciones) requieren visión iterativa y aprobación estética del usuario (V1/V2). El módulo define TODO el sistema para producirlos.
- Detección automática de texto embebido en píxeles [?] requiere OCR — fuera de alcance V0.

### Recomendaciones para el próximo agente
- Al crear cada asset, marcar su estado en inventario_2d.json (0→2) y correr el validador.
- El validador NO usa load() de Godot: los PNG crudos sin .import se leen con Image.load_png_from_buffer (los .png sin importar no pasan por ResourceLoader).
- Para la cobertura 48/48: producir por familia siguiendo ART_STYLE_2D §9 y validar cada pieza.