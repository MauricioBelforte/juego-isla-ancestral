**Modelo:** Nemotron 3.5 Lightning
**Plataforma:** Cline

# 01-Requerimientos.md â€” MÃ³dulo 131: CrÃ©ditos

## ID del MÃ³dulo
- **CÃ³digo:** M131 (plan maestro: componente nuevo - CrÃ©ditos finales)
- **Carpeta:** `DOCUMENTACION/131-Creditos/`
- **Dependencias:** M142 (Release Candidate), M78 (Legal - Propiedad Intelectual), M87 (LocalizaciÃ³n), M90 (ConfiguraciÃ³n GrÃ¡fica), M91 (ConfiguraciÃ³n de Audio)
- **Delegable desde:** diseÃ±o completo; implementaciÃ³n tras sistema de narrativa/base

## 1. Problema

Mostrar los crÃ©ditos finales del juego de manera apropiada, reconociendo las contribuciones de todos los equipos, colaboradores y autores de assets utilizados. Los crÃ©ditos deben ser visualmente coherentes con el estilo cozy del juego, legibles y ofrecer una experiencia agradable de cierre. Deben incluir reconocimiento a contribuyentes voluntarios, testers, y mencionar el uso de assets de terceros con licencias apropiadas.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Lista de equipos | Mostrar nombres de los equipos de desarrollo principal, arte, sonido, QA, comunidad |
| RF2 | CrÃ©ditos de contribuyentes | Reconocer contribuyentes voluntarios, testers, traductores con opciÃ³n de bÃºsqueda |
| RF3 | Reconocimiento de assets | Mencionar assets de terceros con licencias Creative Commons o comerciales |
| RF4 | Idiomas mÃºltiples | Mostrar crÃ©ditos en al menos 2 idiomas (espaÃ±ol/inglÃ©s) con conmutaciÃ³n |
| RF5 | NavegaciÃ³n de pantalla | Desplazamiento por crÃ©ditos con opciÃ³n de detener/continuar animaciÃ³n |
| RF6 | Copyright y aÃ±o | Mostrar aÃ±o actual y leyenda de copyright del juego |
| RF7 | Accesibilidad | TamaÃ±o de texto ajustable, alto contraste opcional para lectura |

## 3. Requisitos No Funcionales

- **Cozy:** experiencia de cierre tranquila; sin textos forzados; ritmo suave de apariciÃ³n
- **Rendimiento:** O(n) donde n = nÃºmero de crÃ©ditos; sin alocs por frame durante la visualizaciÃ³n
- **Legibilidad:** tamaÃ±o mÃ­nimo de fuente garantizado en todas las resoluciones
- **Coherencia visual:** estilo consistente con M87 (ConfiguraciÃ³n GrÃ¡fica) y M91 (ConfiguraciÃ³n de Audio)
- **Tiempo de visualizaciÃ³n:** 3-5 minutos como mÃ¡ximo para crÃ©ditos completos

## 4. Criterios de AceptaciÃ³n

1. Todos los equipos principales listados y reconocidos.
2. Contribuyentes voluntarios y testers incluidos.
3. Assets de terceros con licencias mencionadas.
4. Soporte para conmutaciÃ³n de idiomas (espaÃ±ol/inglÃ©s).
5. NavegaciÃ³n y control de reproducciÃ³n funcionando.
6. Copyright y aÃ±o actual displayados.
7. Accesibilidad de tamaÃ±o de texto y contraste.
8. Delegable para implementaciÃ³n.