**Modelo:** Nemotron 3.5 Lightning
**Plataforma:** Cline

# 01-Requerimientos.md — Módulo 131: Créditos

## ID del Módulo
- **Código:** M131 (plan maestro: componente nuevo - Créditos finales)
- **Carpeta:** `DOCUMENTACION/131-Creditos/`
- **Dependencias:** M142 (Release Candidate), M78 (Legal - Propiedad Intelectual), M87 (Localización), M90 (Configuración Gráfica), M91 (Configuración de Audio)
- **Delegable desde:** diseño completo; implementación tras sistema de narrativa/base

## 1. Problema

Mostrar los créditos finales del juego de manera apropiada, reconociendo las contribuciones de todos los equipos, colaboradores y autores de assets utilizados. Los créditos deben ser visualmente coherentes con el estilo cozy del juego, legibles y ofrecer una experiencia agradable de cierre. Deben incluir reconocimiento a contribuyentes voluntarios, testers, y mencionar el uso de assets de terceros con licencias apropiadas.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Lista de equipos | Mostrar nombres de los equipos de desarrollo principal, arte, sonido, QA, comunidad |
| RF2 | Créditos de contribuyentes | Reconocer contribuyentes voluntarios, testers, traductores con opción de búsqueda |
| RF3 | Reconocimiento de assets | Mencionar assets de terceros con licencias Creative Commons o comerciales |
| RF4 | Idiomas múltiples | Mostrar créditos en al menos 2 idiomas (español/inglés) con conmutación |
| RF5 | Navegación de pantalla | Desplazamiento por créditos con opción de detener/continuar animación |
| RF6 | Copyright y año | Mostrar año actual y leyenda de copyright del juego |
| RF7 | Accesibilidad | Tamaño de texto ajustable, alto contraste opcional para lectura |

## 3. Requisitos No Funcionales

- **Cozy:** experiencia de cierre tranquila; sin textos forzados; ritmo suave de aparición
- **Rendimiento:** O(n) donde n = número de créditos; sin alocs por frame durante la visualización
- **Legibilidad:** tamaño mínimo de fuente garantizado en todas las resoluciones
- **Coherencia visual:** estilo consistente con M87 (Configuración Gráfica) y M91 (Configuración de Audio)
- **Tiempo de visualización:** 3-5 minutos como máximo para créditos completos

## 4. Criterios de Aceptación

1. Todos los equipos principales listados y reconocidos.
2. Contribuyentes voluntarios y testers incluidos.
3. Assets de terceros con licencias mencionadas.
4. Soporte para conmutación de idiomas (español/inglés).
5. Navegación y control de reproducción funcionando.
6. Copyright y año actual displayados.
7. Accesibilidad de tamaño de texto y contraste.
8. Delegable para implementación.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M142** — Release Candidate | Base para release candidate |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M130** — Artbook | Usado por artbook |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M130** — Artbook | Este módulo lo necesita |
| **M142** — Release Candidate | Depende de este módulo |

