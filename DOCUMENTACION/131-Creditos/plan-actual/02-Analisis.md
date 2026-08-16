**Modelo:** Nemotron 3.5 Lightning
**Plataforma:** Cline

# 02-Analisis.md — Módulo 131: Créditos

## 1. Resolución de los puntos del plan

| # | Punto | Resolución |
|---|---|---|
| 1 | Lista de equipos | 5 equipos principales: Desarrollo, Arte, Sonido, QA, Comunidad — nombres y roles definidos |
| 2 | Créditos de contribuyentes | Base de datos de contribuyentes voluntarios; opción de búsqueda y filtro por rol |
| 3 | Reconocimiento de assets | Catálogo de assets de terceros con licencias (CC BY, CC0, comerciales) y enlaces |
| 4 | Idiomas múltiples | Sistema de conmutación español/inglés; textos de créditos traducidos |
| 5 | Navegación de pantalla | Scroll vertical con velocidad configurable; botón "Detener/Continuar animación" |
| 6 | Copyright y año | Campo dinámico que muestra año actual; leyenda "© Isla Ancestral 2024" |
| 7 | Accesibilidad | Control de tamaño de texto (S/M/L); modo alto contraste opcional; respeta configuración M91 |

## 2. Decisiones clave

1. **Formato de lista alfabética:** Los créditos se organizan por equipo y luego alfabéticamente dentro de cada categoría, facilitando la búsqueda visual y el reconocimiento ordenado.

2. **Sistema de búsqueda:** Campo de búsqueda integrado que permite filtrar por nombre, rol o equipo, mejorando la accesibilidad y usabilidad para listas extensas.

3. **Idiomas duales:** Todos los textos están preparados para doble idioma (español/inglés), con la opción de conmutar en el menú de configuración (M91/M87). Los créditos críticos (copyright, años) se mantienen en el idioma del proyecto base.

4. **Tiempo de visualización controlado:** Los créditos tienen una duración máxima de 5 minutos con animación configurable. El usuario puede saltar secciones o detener la animación en cualquier momento.

5. **Formato de licencias:** Los assets de terceros se categorizan y muestran con su licencia correspondiente (CC0, CC BY-SA, licencia comercial). Se incluyen enlaces breves a la licencia completa.

## 3. Alternativas descartadas

- **Creditos interactivos completos:** Permitir al usuario explorar libres el reconocimiento descartado; complejidad UX innecesaria para una pantalla de cierre.
- **Créditos solo en un idioma:** Descartado para proyectos con visión internacional; limita accesibilidad.
- **Lista cronológica de contribuyentes:** Descartado; difícil de mantener y menos claro que organización por categorías/roles.
- **Créditos ilímites sin paginación:** Descartado; riesgo de pantalla interminable en proyectos con muchos colaboradores.

## 4. QA

- Test M115: todos los equipos principales listados y visibles
- Test de búsqueda: filtro por nombre, rol y equipo funciona correctamente
- Test de idioma: conmutación español/inglés cambia todos los textos
- Test de accesibilidad: tamaño de texto ajustable y modo contraste alternan
- Test de tiempo: duración máxima 5 minutos con animación continua
- Test de copyright: año actual y leyenda displayados correctamente