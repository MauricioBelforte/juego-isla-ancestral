# 02 — Análisis — M22: Historia Principal

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Puntos de la sección 21 resueltos

| Punto (Plan) | Resolución |
|---|---|
| Definir prólogo | El navegante llega tras una tormenta (M32); Primer Baile de la Brisa; conoce la aldea y el misterio del Sello (hook M26) |
| Definir capítulo 1 | "Las Cenizas Futuras": explorar el islote quemado, descubrir el primer mural (M25) y entender la caída |
| Definir capítulo 2 | "El Puente de las Memorias": restaurar el puente (herramienta M24) y cruzar a la Isla de Coral |
| Definir capítulo 3 | "El Jardín Ahogado": bajar el nivel de agua (puzzle M24 agua) y recuperar el faro (M25) |
| Definir capítulo 4 | "El Valle de los Vientos": entrar al Templo de la Brisa (M26), 7 anillos + sellos |
| Definir capítulo 5 | "La Noche Eterna": eclipse (M31) y reaparición de las sombras; regreso a la aldea |
| Definir capítulo 6 | "El Corazón del Mundo": Isla de las Cenizas (volcán/geoda), saber del Sello original |
| Definir capítulo final | "La Brisa y el Sello": restaurar el Sello en la Cámara (M26) y elegir el final |
| Definir final principal | La Brisa regresa: el pueblo vuelve a florecer; el jugador elige quedarse o partir |
| Definir finales alternativos | 3 variantes (quedarse en la aldea / regresar al antiguo mundo / quedarse como guardián del Sello) |
| Definir final secreto | Si se restauran las 4 salas secretas del templo + sello perfecto: "El Primer Guardián" (epílogo del Templo de la Brisa) |
| Definir escenas principales | 14 escenas nodo (conectadas por puertas de progresión, M21/misiones) |
| Definir giros narrativos | 3 giros (la Marca del navegante, la sombra es la civilización caída, el Sello no estaba roto: fue escondido) |
| Definir pistas | 30 pistas distribuidas (murales 12, inscripciones 8, objetos 6, diálogos 4) que anticipan el final |
| Definir foreshadowing | 10 foreshadows (la brisa en el prólogo, el faro ciego, los 7 glifos, la lluvia gris...) |
| Definir revelaciones | 6 revelaciones (identidad del "guardián", origen de la civilización, la marca, el Sello, el eclipse, el destino del pueblo) |
| Definir ritmo | Curva de tensión por capítulo: 1-2 picos; los capítulos 3 y 5 son los álgidos |
| Definir momentos emotivos | 4 (despedida del barco, baile de brisa, restauración del jardín, regreso final) |
| Definir momentos de calma | 6 (pesca, jardín, biblioteca, el faro al atardecer, la plaza, la cámara después del sello) |
| Definir momentos de descubrimiento | 8 (murales, sala secreta, faro restaurado, anillos, geoda, salas del templo, glifos del sello, final secreto) |
| Definir secuencia de templos | Orden: Templo de Ceniza (ruina, fácil) → Templo de Mar (agua) → Templo de la Brisa (M26) al final del arco |
| Definir secuencia de Sellos | 7 sellos recuperados en orden narrativo real (no lineal obligado): 4 salas secretas + 3 intermedias del M26 |
| Definir desarrollo del misterio | Misterio de 4 capas: ¿qué cayó? ¿quién era el guardián? ¿por qué la brisa? ¿qué es el Sello? |
| Definir información oculta | 5 caches de lore ocultos (referencias cruzadas a M25 murales/inscripciones) |
| Evitar exposición excesiva | Regla: máx 4 líneas de diálogo expositivo por escena; el resto se entrega por contexto (objetos/murales) |

## Alternativas descartadas

1. **Historia lineal sin ramas:** descartado — los 3 finales alternativos y 7 sellos exigen ramas; el grafo es el modelo.
2. **Guion gigante en un documento:** descartado — requiere datos (nodos) para M21/M23/M68 y validación automática.
3. **Exposición por muros de texto:** descartado — viola "anti-exposición"; la historia se cuenta por el mundo.
4. **Final secreto imposible de descubrir sin wiki:** descartado — las pistas (30) hacen el final secreto deducible.

## Decisiones

- **Grafo de escenas** con nodos de progresión serializada: cada capítulo es un conjunto de nodos con requisitos (puzzles resueltos, sellos, lugar).
- **Los 7 sellos son el gating real**: progresan la Historia Principal; el orden sugerido es narrativo pero no bloquea (libertad cozy).
- **El final secreto** requiere sello perfecto + 4 salas secretas (es verificable por M66).
- **Los momentos emotivos se atan a M41/M44** (música/momento) y a M33 (cutscenes): hooks, no implementación.
- **Anti-exposición medible**: test de guion (líneas por escena, palabras por diálogo).