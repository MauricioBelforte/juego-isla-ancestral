**Modelo:** ox-alpha
**Plataforma:** Cline
**Fecha:** 2026-08-23

# 01-Requerimientos.md — Módulo 130: Artbook

## 1. Problema

El proyecto Isla Ancestral acumulará durante su desarrollo una enorme cantidad de arte conceptual, diseños descartados, storyboards y material visual que hoy vive disperso en carpetas de trabajo (M45 Arte 3D, M46 Arte 2D, M47 Texturas, M48 Animación, M52 VFX). Sin un artbook planificado como producto:

1. Ese material se pierde o queda sin contexto cuando las versiones avanzan y los archivos se sobrescriben.
2. El juego pierde una pieza clave de la identidad de marca (M128) y del merchandising premium (M129 ya reserva una subsección de artbook sin especificación propia).
3. La comunidad y la prensa no tienen un objeto de colección que cuente la historia detrás del mundo (Aurora, los Arquitectos del Alba, la Resonancia).
4. No existe un registro curado de la evolución visual del mundo, útil también para onboarding de nuevos artistas y para el QA cruzado de consistencia estética.

El plan maestro (sección #129 ARTBOOK) exige 15 contenidos: arte conceptual, evolución del mundo, diseño de Aurora, diseño de personajes, diseño de animales, diseño de ruinas, diseño de herramientas, diseño de vehículos, diseño de biomas, diseño de UI, storyboards, conceptos descartados, comentarios de desarrolladores, proceso de producción y créditos.

## 2. Objetivos

| ID | Objetivo |
|----|----------|
| O1 | Definir el artbook como producto editorial completo: estructura de capítulos, contenido mínimo por capítulo y criterios de curaduría. |
| O2 | Cubrir el 100% de los 15 puntos del plan maestro sección #129. |
| O3 | Establecer el pipeline de recolección y curaduría de arte desde las carpetas fuente (M45/M46/M47/M48/M52) sin interrumpir el trabajo de producción. |
| O4 | Definir especificaciones técnicas de edición (formato, resolución, color, tipografía) compatibles con Print on Demand (M129) y versión digital. |
| O5 | Incluir la capa narrativa única del proyecto: comentarios de desarrolladores y conceptos descartados que expliquen el "porqué" de cada decisión visual. |
| O6 | Garantizar trazabilidad legal: todo asset incluido tiene licencia y autoría registradas (M78/M127/M132). |

## 3. Alcance

### 3.1 Dentro del alcance
- Estructura editorial completa del artbook (capítulos, orden, extensión objetivo).
- Criterios de selección y curaduría de piezas por categoría.
- Especificaciones técnicas de maquetación (digital PDF y física impresa).
- Plan de recolección de assets desde los módulos de arte.
- Formato de los comentarios de desarrolladores y de las fichas de conceptos descartados.
- Integración con el catálogo de merchandising (M129) y la identidad de marca (M128).
- Checklist de producción verificable (≥100 ítems).

### 3.2 Fuera del alcance
- La producción física real (imprenta, papel, encuadernación): pertenece a M129 Merchandising.
- El diseño gráfico final página por página: requiere diseñador editorial contratado.
- El soundtrack físico/vinilo: M129.
- La store page y materiales de marketing digital: M97/M99.

## 4. Requisitos Funcionales

| ID | Requisito |
|----|-----------|
| RF1 | Arte conceptual: capítulo con las piezas fundacionales del estilo Cozy Voxel (paletas pastel, iluminación suave, siluetas redondeadas). |
| RF2 | Evolución del mundo: línea de tiempo visual desde el primer prototipo hasta la versión final de Aurora. |
| RF3 | Diseño de Aurora: planos de la isla, el puerto, el faro, la plaza y el pueblo en sus estados deteriorado → restaurado. |
| RF4 | Diseño de personajes: hojas de modelo del jugador (6 opciones), Finneas, Lía, Bruno, Nilo, Vera y vecinos adicionales. |
| RF5 | Diseño de animales: hojas de modelo de la fauna por bioma (M36/M65) con variantes estacionales. |
| RF6 | Diseño de ruinas: kit modular de ruinas (M25), templos (M24/M26) y la iconografía ancestral. |
| RF7 | Diseño de herramientas: las 9 herramientas × 4 niveles (M13) y las herramientas de aventura (Gancho Mecánico, Lanza-Semillas, Varas de Flujo). |
| RF8 | Diseño de vehículos: barco, Gran Vapor, dirigible, submarino (M67/M157). |
| RF9 | Diseño de biomas: las 13 regiones geográficas (M09) y las 12+ islas satélite (M27). |
| RF10 | Diseño de UI: evolución de la interfaz, iconos, fuentes (M88) y pantallas clave (M53/M89). |
| RF11 | Storyboards: secuencias narrativas clave (encendido del faro, llegada del Gran Vapor, descubrimiento del Corazón del Mundo, Elysia). |
| RF12 | Conceptos descartados: galería curada con ficha explicando qué era, por qué se descartó y qué aprendió el equipo. |
| RF13 | Comentarios de desarrolladores: citas contextuales ancladas a piezas concretas (formato estándar definido en 03-Diseno). |
| RF14 | Proceso de producción: capítulo metodológico (pipeline de arte M108, estilo voxel, validador de assets). |
| RF15 | Créditos: sección final coherente con M131 (roles, licencias, agradecimientos). |
| RF16 | Dos formatos de salida: PDF digital (pantalla) y maqueta lista para POD (CMYK, sangrado). |
| RF17 | Toda pieza incluida lleva metadatos: autor, fecha, módulo de origen, estado (concepto/final/descartado). |

## 5. Criterios de Aceptación

1. Los 15 puntos del plan maestro tienen capítulo o sección asignada con contenido mínimo definido.
2. Existe el pipeline de curaduría documentado y probado con al menos 20 piezas reales de muestra.
3. Las especificaciones técnicas son compatibles con los perfiles CMYK ya definidos en M129.
4. El formato de comentario de desarrollador y de ficha de descarte estándar está definido con ejemplos.
5. Checklist de ≥100 ítems creado y verificado.

## 6. Restricciones

- **Motor/plataforma:** Godot 4.x no interviene; este módulo es editorial. Herramientas: editor de imágenes, maquetación y control de versiones Git LFS para assets pesados (M06).
- **Idioma:** español como idioma base; textos preparados para localización futura (M87) si el artbook se traduce.
- **Legal:** toda pieza de terceros requiere licencia registrada (M83/M85); el artbook hereda la política anti-spoilers de M98 solo parcialmente (el artbook SÍ puede mostrar finales, es producto post-lanzamiento).
- **Presupuesto:** el costo de producción editorial se estima dentro de M134; el artbook es post-lanzamiento (coincide con M129).
- **No modificar** `DOCUMENTACION/00-PLAN-INICIAL/`.

## 7. Dependencias

| Módulo | Tipo | Relación |
|--------|------|----------|
| M45 Arte 3D | Fuente | Modelos, renders y hojas de estilo voxel |
| M46 Arte 2D | Fuente | Iconos, retratos, símbolos, atlas |
| M47 Texturas y Materiales | Fuente | Atlas de bloques y shaders |
| M48 Animación | Fuente | Frames clave y hojas de animación |
| M09/M27 Geografía e Islas | Fuente | Mapas y referencias de biomas/islas |
| M22 Historia Principal | Fuente | Storyboards narrativos |
| M128 Identidad de Marca | Dependencia | Logo, paleta, tipografía del libro |
| M129 Merchandising | Dependencia | Specs POD, precios, canal de venta |
| M131 Créditos | Dependencia | Sección final de créditos |
| M108 Pipeline de Assets | Relación | Capítulo de proceso de producción |
| M78/M127 Legal PI/Copyright | Relación | Derechos de las piezas incluidas |
| M59 Guardado / M06 Git | Relación | Respaldo de la carpeta del artbook |