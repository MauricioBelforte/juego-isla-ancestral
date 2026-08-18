**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 71: Progresión

## ID del Módulo
- **Código:** M71 (CHECKLIST-GLOBAL: ID 71 — Progresión)
- **Carpeta:** `DOCUMENTACION/71-Progresion/`
- **Dependencias:** M22 (Historia Principal), M38 (Economía)
- **Delegable desde:** hoy (diseño completo; la implementación requiere los contractos de señales de M13, M18, M20, M22 y M38, y el EventBus de M07)

## 1. Problema

La isla Aurora es un mundo voxel cozy tipo Stardew Valley. El jugador mejora herramientas (M13), amplía su casa (M18), cultiva amistades (M20), acumula monedas (M38) y avanza en la historia (M22). Pero todos esos sistemas generan avance **de forma dispersa**: cada uno lleva su propio estado, no existe un registro central de lo que el jugador ya logró, ni reglas para abrir contenido nuevo de forma ordenada, ni un relato coherente del progreso ("¿qué me falta por hacer hoy?"). Sin un sistema de progresión transversal, el juego corre dos riesgos graves: 1) el jugador se siente perdido y sin metas, y 2) el contenido nuevo (recetas, zonas, eventos, logros) no tiene un mecanismo limpio de desbloqueo ni de priorización. Un sistema de progresión agresivo (niveles de XP que castigan, contenido bloqueado permanentemente, FOMO) rompería la promesa cozy: aquí todo debe ser desbloqueable con calma y sin frustración.

## 2. Objetivo

Diseñar el sistema de progresión central de la isla Aurora: un **registry de hitos** (milestones) y **desbloqueos data-driven** que orqueste el avance de todos los módulos mencionados, un **perfil de jugador** con estadísticas acumuladas que alimentan condiciones, un **registro de logros** base que consume M72, y una **capa de eventos de progreso** que avisa al resto del juego cuando algo se logra. La regla de oro cozy: **todo es desbloqueable, nada se bloquea permanentemente, y siempre hay al menos una meta alcanzable** (anti-frustración, alineado con M66 y M94).

## 3. Alcance

### 3.1 Dentro del alcance
- Registry de hitos: catálogo central de logros de progresión (id, condición, recompensa, orden, visibilidad) en recursos `.tres`.
- Sistema de desbloqueos: condiciones evaluables (tipos de condición), activación y emisión de señales al desbloquear contenido.
- Perfil de jugador: estadísticas acumuladas de sesión y totales (días jugados, ítems recolectados, monedas ganadas/perdidas, amigos, donaciones, distancia recorrida, acciones de crafting, etc.).
- Registro de logros base: definición, evaluación y señales de logro desbloqueado (la UI/UX de logros pertenece a M72).
- Radar de novedades / primeras veces: "primera vez" de cada actividad (primer pez, primer mineral, primera venta) como desbloqueos informativos.
- Gating suave: los desbloqueos guían la ruta del jugador sin bloquearla; cuando una condición no es cumplible, el sistema lo detecta y lo reporta a M66 (anti-softlock) o activa rutas alternativas.
- Reputación comunitaria: índice derivado de la amistad (M20) y contribuciones económicas (M38), usado para títulos y ofertas sociales, nunca como bloqueo.
- Persistencia del estado de progresión: hitos alcanzados, desbloqueos activos, estadísticas y primeras veces, integrado al guardado global (M59).
- Integración por contrato con M13 (niveles de herramienta), M18 (niveles de casa), M20 (niveles de amistad), M22 (capítulos y sellos), M38 (hitos económicos), M37/M72/M73 (colecciones y logros).

### 3.2 Fuera del alcance
- La UI de progreso (pestañas de logros, panel de hitos, notificaciones) pertenece a M53 (UI/UX) y M72 (logros).
- El curado final de logros (cantidad, nombres, íconos) es responsabilidad de M72; aquí solo se define el motor y el registro técnico.
- Las colecciones en sí (museo M37, coleccionables M73) definen sus propias reglas; el módulo 71 solo registra estadísticas y condiciones que las referencian.
- El sistema de viajes (M28) y fast travel (M69) mantienen su propia lógica; el 71 solo emite/consume desbloqueos de caminos.
- La curva de balance económica (precios M38) y los niveles de herramientas (M13) no se diseñan aquí: el 71 los consume vía condiciones.
- No hay niveles de jugador con XP numérica ni árbol de habilidades: el progreso es por hitos cualitativos y desbloqueos (decisión D2).

## 4. Restricciones

- **Motor:** Godot 4.x (>= 4.4.1), GDScript tipado explícito, sin C# (M04). Voxel Tools para el mundo (M08).
- **Cozy innegociable:** ningún desbloqueo puede ser permanente e imposible; ninguna condición puede volverse incumplible por acción del jugador o del tiempo; cero FOMO (M94).
- **Gating suave:** los desbloqueos informan y guían, nunca bloquean el contenido principal de forma dura; los sellos de M22 son gating *narrativo* validado por M22, el 71 solo los refleja.
- **Data-driven:** hitos, desbloqueos, condiciones y títulos viven en `.tres` editables sin tocar código; validación en editor con errores accionables.
- **Desacoplamiento:** el módulo no conoce la UI; comunica por señales (M07 EventBus por dominios). Los autoloads de progresión los consumen managers de UI y otros módulos.
- **Persistencia:** el estado de progresión se guarda con la partida (M59) y es coherente con el PRNG de partida (M29).
- **Sin red:** todo es local; no hay progresión online ni sincronización de nube.
- **Determinismo:** la evaluación de condiciones es determinista (no depende del frame ni de aleatoriedad no sembrada).

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Registry de hitos central | `MilestoneRegistry`: catálogo data-driven de hitos con id único, nombre i18n, descripción, condición, recompensas opcionales y orden |
| RF2 | Tipos de condición | Condiciones evaluables por tipo: conteo de estadística (>= n), días jugados (>= n), nivel alcanzado (herramienta M13, casa M18, amistad M20), hito previo alcanzado, sellos de historia (M22), riqueza acumulada (M38), colección completada (M37/M72), combinaciones AND/OR/NOT |
| RF3 | Evaluación por eventos | Las condiciones se reevalúan solo cuando cambian sus estadísticas dependientes (dirty flags), nunca por frame |
| RF4 | Desbloqueos | `UnlockSystem`: al cumplirse una condición, activa el desbloqueo declarado (receta, camino, región, mecánica, título) y emite la señal correspondiente |
| RF5 | Señales de progreso | Emisión de `progreso_hito_alcanzado(id)`, `progreso_desbloqueado(id, tipo, valor)` y `progreso_logro(id)` consumibles por M13/M18/M20/M22/M38/M53/M72 |
| RF6 | Perfil de jugador | `PlayerProfile`: estadísticas acumuladas (totales de partida y del día), consultables por id, alimentadas por eventos del EventBus (M07) |
| RF7 | Estadísticas del día | Contadores diarios (basados en M29) que se resetean al cambiar de día; persistentes para coherencia |
| RF8 | Registro de logros base | `AchievementDefinition` (Resource): condiciones, progreso parcial y señales; la capa de presentación/curado es de M72 |
| RF9 | Radar de primeras veces | Registro de la primera ocurrencia de cada actividad definida (primer recurso, primer pez, primera venta, primera donación) como hito informativo |
| RF10 | Gating suave y anti-frustración | Si una condición depende de contenido no generado o no cumplible, el sistema reporta a M66 una ruta alternativa o libera el desbloqueo con requisito reducido (decisión D5) |
| RF11 | Reputación comunitaria | Índice derivado (0-100): promedio ponderado de amistad (M20) y contribuciones económicas (M38); desbloquea títulos sociales y ofertas, nunca bloquea |
| RF12 | Títulos de jugador | Títulos cosméticos y sociales ("Aprendiz de la Isla", "Amigo del Pueblo", "Guardián de Aurora") otorgados por hitos acumulados; sin poder y sin bloqueo |
| RF13 | Persistencia | Hitos alcanzados, desbloqueos, estadísticas, primeras veces y reputación se guardan/restauran con la partida vía GameState (M59) |
| RF14 | Jugador nuevo vs veterano | El sistema distingue estado inicial (onboarding) de veterano; un veterano al cargar recibe resumen de progreso y no repite tutoriales ni hitos ya logrados |
| RF15 | Registro de eventos de progreso | Log de cada hito, desbloqueo y logro (M103) y evento de analytics (M104) sin acoplar el sistema principal |
| RF16 | Catálogo validado en editor | Validación de catálogos: ids únicos, condiciones referencian estadísticas existentes, sin ciclos en dependencias, sin condiciones imposibles detectables estáticamente |

## 6. Requisitos No Funcionales

- **Cozy:** cero castigos por no progresar; el ritmo lo elige el jugador; no existe contenido que "expire" sin otra oportunidad (anti-FOMO, M94).
- **Tranquilidad:** los desbloqueos se anuncian con calma (notificación suave, sin interrupciones agresivas); las metas sugeridas nunca son obligatorias.
- **Rendimiento:** evaluación de condiciones por eventos y caché de resultados; sin recorridos de catálogo por frame; búsqueda de hitos O(1) con diccionarios.
- **Determinismo:** misma partida → mismos hitos; el orden de evaluación no depende del frame ni del orden aleatorio.
- **Data-driven:** catálogos en `.tres` con validación en editor (ids duplicados, estadísticas inexistentes, ciclos, condiciones imposibles).
- **Desacoplamiento:** autoloads puros (lógica y datos); sin referencias a nodos de UI; consumo por señales del EventBus de dominio (M07).
- **Localización:** nombres y descripciones de hitos, títulos y logros con claves i18n (M87).
- **Godot 4.x (>= 4.4.1):** GDScript tipado explícito, `Resource` para datos, señales del core; helpers `RefCounted` para condiciones puras.
- **Compatibilidad de guardado:** versionado del estado de progresión dentro de GameState (M59) para migraciones futuras.
- **Accesibilidad:** la información de progreso debe ser legible y consultable en todo momento para jugadores con baja visión y sin percepción de color (color no es el único indicador; M58).

## 7. Criterios de Aceptación

1. El registry carga 100+ hitos de ejemplo distribuidos en los dominios de M13/M18/M20/M22/M38 con validación en editor sin errores.
2. Al superar una condición (ej: "recolectar 50 maderas"), se emite la señal correspondiente y la UI (M53) muestra la notificación sin intervención de lógica.
3. Un desbloqueo declarado "nivel 2 de herramientas" se activa solo cuando M13 confirma el nivel, y nunca antes.
4. Los sellos de historia (M22) se reflejan como hitos sin que el 71 los valide por sí mismo (solo lee el estado de M22).
5. Con una partida nueva, el sistema no emite ningún hito pre-alcanzado; con una partida veterana, restaurar no re-emite hitos ya logrados.
6. Cantidad de monedas ganadas (M38) alimenta la estadística `monedas_acumuladas` sin duplicar ni perder valores tras guardar/cargar.
7. Si una condición es estáticamente imposible (depende de un ítem marcado revendible=false inexistente), la validación en editor lo reporta antes de jugar.
8. Tras guardar/cargar, hitos, desbloqueos, estadísticas del día y primeras veces coinciden exactamente (sin duplicados ni pérdidas).
9. La reputación comunitaria sube con la amistad (M20) y las ventas/trueques (M38) y nunca deja de ser consultable aunque sea 0.
10. El sistema funciona sin ninguna UI conectada (los autoloads no crashean con cero consumidores de señales).

## 8. Fuentes de Contexto (plan maestro)

- Progresión sin frustración: el jugador nunca debe sentir que "se perdió algo" ni que hay un "camino correcto" único (M94 Retención sin FOMO).
- Todo el contenido es desbloqueable: no hay contenido bloqueado permanentemente (M152 Principios Innegociables).
- La historia (M22) es el esqueleto de la progresión principal; los sellos abren capítulos pero siempre hay algo más por hacer (secundarias M23, templos M24-M26, museo M37).
- El pueblo se siente vivo: la reputación y la amistad (M20) son progresión social, no numérica.
- Ritmo accesible: la curva temprana es rápida (primeras horas con desbloqueos frecuentes) y luego se vuelve una meseta cómoda (M02/M145).
- El juego es cozy single-player 100% local; no hay progresión en red.