**Modelo:** ox-alpha
**Plataforma:** Cline
**Fecha:** 2026-08-23

# 02-Analisis.md — Módulo 130: Artbook

## 1. Análisis del Dominio

Un artbook de videojuego es un producto editorial híbrido: mitad libro de arte, mitad documento histórico del desarrollo. Para Isla Ancestral tiene una particularidad: el mundo tiene una narrativa visual propia (los Arquitectos del Alba, la Resonancia, los seis Sellos) que el artbook puede contar como "arqueología del diseño", igual que el jugador hace arqueología en el juego.

### 1.1 Tipos de contenido a curar
- **Concepto fundacional:** bocetos tempranos, paletas exploratorias, pruebas de estilo voxel.
- **Diseño de producción:** hojas de modelo finales (turnarounds, expresiones, variantes).
- **Material de proceso:** capturas de bloqueo, wireframes de UI, storyboards, tableros de moodboard.
- **Descartes:** piezas abandonadas con valor documental y didáctico.

### 1.2 Audiencias objetivo
| Audiencia | Qué busca | Implicación editorial |
|---|---|---|
| Fans del juego | Ver "detrás de escena" y lore visual | Comentarios de devs + conceptos descartados |
| Coleccionistas | Objeto físico premium | Calidad de impresión, tapa dura, numeración (M129) |
| Artistas/aspirantes | Aprender el proceso | Capítulo de proceso de producción paso a paso |
| Prensa/creadores | Material citable | Piezas de alta resolución sin marca de agua en versión digital |
| Equipo futuro | Onboarding y consistencia | El artbook como referencia canónica de estilo |

### 1.3 Fuentes de material por módulo
| Módulo fuente | Material esperado | Volumen estimado |
|---|---|---|
| M45 Arte 3D | Renders, turnarounds, kits modulares | ~60 piezas |
| M46 Arte 2D | Iconos, retratos, símbolos ancestrales | ~50 piezas |
| M47 Texturas | Atlas de bloques, variantes por bioma | ~20 planchas |
| M48 Animación | Hojas de sprites/frames clave | ~25 secuencias |
| M09/M27 Geografía/Islas | Mapas, secciones, vistas aéreas | ~15 mapas |
| M22 Historia | Storyboards de escenas clave | ~10 secuencias |
| M53/M88 UI/Fuentes | Evolución de pantallas e iconografía | ~30 pantallas |

## 2. Alternativas Consideradas

| Alternativa | Veredicto | Motivo |
|---|---|---|
| Solo digital vs digital + físico | **Ambos** | El digital es barato y sirve a prensa/comunidad; el físico es el objeto premium que pide M129. Comparten maqueta base |
| Curaduría al final del proyecto vs continua | **Continua (curaduría incremental)** | Al final sería inviable (cientos de archivos sin metadatos); la recolección continua con metadatos evita pérdida |
| Orden cronológico vs temático | **Temático con línea de tiempo interna** | El lector busca por tema (personajes, biomas); la cronología vive dentro de cada capítulo como subsección "evolución" |
| Incluir spoilers/finales | **Sí, con aviso** | Es producto post-lanzamiento; se incluye advertencia de spoilers en las páginas correspondientes |
| Comentarios de devs anónimos vs firmados | **Firmados con rol** | Da humanidad y credibilidad; formato uniforme |
| Maquetación propia vs contratada | **Contratada con guía de estilo propia** | Este módulo define contenido y specs; el diseño final de páginas requiere diseñador editorial (M129/M132) |
| Un tomo vs varios volúmenes | **Un tomo (~200-240 págs) con posibilidad de volumen 2 post-DLC** | Un solo SKU simplifica logística (M129); el volumen 2 queda como opción si M120 lo justifica |

## 3. Decisiones Clave

1. **D1 — Curaduría incremental con manifiesto:** cada pieza candidata se registra en un manifiesto (`artbook_manifest.csv`) con metadatos desde el día que se crea, no al final.
2. **D2 — Estructura temática de 12 capítulos:** cubre los 15 puntos del plan maestro agrupando lógicamente (ver 03-Diseno).
3. **D3 — Ficha estándar de pieza:** toda pieza lleva ficha con autor, fecha, módulo origen, estado y comentario opcional de dev.
4. **D4 — Formato de comentario de desarrollador:** cita breve (≤40 palabras), firmada con nombre+rol, anclada a una pieza concreta, tono cálido y honesto (incluye errores aprendidos).
5. **D5 — Ficha estándar de concepto descartado:** qué era → por qué se descartó → qué enseñó → ¿algo sobrevivió en otra forma?
6. **D6 — Doble salida desde una sola maqueta:** PDF RGB para pantalla + export CMYK con sangrado 3 mm para POD (M129), misma paginación.
7. **D7 — Política de spoilers explícita:** capítulos finales marcados con banda de advertencia; el lector es avisado antes de revelar Sellos/Elysia/finales.
8. **D8 — Respaldo Git LFS:** la carpeta del artbook vive fuera de `Assets/` del motor, versionada en Git LFS (M06) y respaldada por la estrategia 3-2-1 (M107).
9. **D9 — Créditos heredados de M131:** no se duplica información; se referencia y se reproduce la versión resumida.
10. **D10 — Idioma base español, textos externalizables:** todos los textos del libro viven en archivos de texto separados de las imágenes para permitir traducción futura (M87).

## 4. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Pérdida de arte temprano (sobrescritura) | Alta | Alto | D1: manifiesto continuo + snapshot semanal de carpeta candidatos (M107) |
| Metadatos incompletos (autor/fecha desconocidos) | Media | Medio | Plantilla obligatoria al nominar pieza; validador simple del CSV |
| Spoilers accidentales en marketing | Baja | Alto | D7: bandas de advertencia + revisión cruzada con M99 antes de publicar extractos |
| Costo de impresión dispara precio | Media | Medio | Specs compatibles con perfiles CMYK de M129; límite de páginas tintadas |
| Derechos de piezas de terceros sin registrar | Baja | Alto | RF17 + verificación contra inventario de licencias (M83/M85) antes de cierre editorial |
| El libro queda desactualizado tras parches/DLC | Media | Bajo | El artbook documenta hasta RC (M142); cambios posteriores van a errata digital o volumen 2 |

## 5. Modelo Conceptual (entidades)

- `PiezaDeArte`: imagen/render + metadatos (id, autor, fecha, módulo_origen, estado, capítulo asignado).
- `ManifiestoArtbook` (CSV): registro central de piezas candidatas y seleccionadas.
- `FichaDev`: comentario de desarrollador (autor, rol, texto ≤40 palabras, pieza anclada).
- `FichaDescarte`: concepto descartado (descripción, motivo, aprendizaje, supervivencia).
- `Capitulo`: unidad editorial (título, objetivo, piezas mínimas, extensión en páginas).
- `Maqueta`: documento de maquetación con paginación única para ambas salidas.
- `SpecTecnica`: resolución, perfil de color, sangrado, tipografías (M128).

## 6. Relaciones con Otros Módulos

| Módulo | Relación |
|---|---|
| M45/M46/M47/M48/M52 | Fuentes primarias de material visual |
| M09/M27 | Mapas y referencias geográficas |
| M22/M23 | Storyboards narrativos |
| M128 Identidad de Marca | Logo, paleta y tipografía del libro |
| M129 Merchandising | Canal de venta, specs POD, precio, tirada |
| M131 Créditos | Sección final |
| M108 Pipeline de Assets | Capítulo de proceso; convenciones documentadas |
| M83/M85 Licencias | Verificación legal de piezas de terceros |
| M78/M127 PI/Copyright | Avisos legales del libro |
| M06/M107 | Versionado LFS y respaldo 3-2-1 |
| M87 Localización | Preparación de textos para traducción futura |
| M134 Presupuesto | Costos editoriales estimados |

## 7. Conclusión del Análisis

El artbook debe tratarse como un producto editorial con pipeline propio de curaduría incremental, no como una tarea de fin de proyecto. La estructura temática de 12 capítulos cubre el 100% del plan maestro, el manifiesto con metadatos evita la pérdida de material, y la doble salida (digital + POD) reutiliza una sola maqueta. Las decisiones quedan listas para el diseño detallado en 03-Diseno.