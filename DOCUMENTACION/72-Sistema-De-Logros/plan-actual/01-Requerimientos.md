**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 72: Sistema de Logros

## ID del Módulo
- **Código:** M72 (CHECKLIST-GLOBAL: ID 72 — Sistema de Logros)
- **Carpeta:** `DOCUMENTACION/72-Sistema-De-Logros/`
- **Dependencias:** M71 (Progresión), M37 (Museos y Colecciones), M97 (Steam Store Page)
- **Delegable desde:** hoy (diseño completo; la implementación requiere los contractos de señales de M71, M37 y M60, y el EventBus de M07)

## 1. Problema

La isla Aurora es un mundo voxel cozy tipo Stardew Valley. El jugador cosecha (M33), pesca (M34), mina (M35), completa colecciones (M37), cultiva amistades (M20) y avanza en la progresión (M71). Todos esos sistemas producen logros y metas personales, pero **no existe un registro unificado de logros del jugador**: no hay forma de que el jugador sepa qué hitos ya consiguió, qué logros le faltan por conseguir, ni un momento celebratorio cuando alcanza una meta larga (la centésima cosecha, la última especie de pez). Por otro lado, los logros implementados "a mano" en cada sistema serían inconsistentes (unos se guardan, otros no; unos avisan, otros no) y costosos de mantener. Si además se planea publicar en Steam (M97), hace falta un catalogo de logros sincronizable con la plataforma. Por último, un sistema de logros mal diseñado puede caer en el "grind" estresante (logros que exigen mil acciones repetitivas, logros imposibles, logros con FOMO), lo que rompería la promesa cozy del juego: los logros deben ser **tranquilos y motivadores**, celebraciones del juego, no exigencias.

## 2. Objetivo

Diseñar el sistema de logros de la isla Aurora: un **catálogo data-driven** de logros cozy (definidos en recursos `.tres` sin tocar código), un **motor de evaluación de condiciones** que desbloquee logros cuando el jugador cumple sus metas, **notificaciones UI elegantes y no intrusivas**, **persistencia local** del estado de logros con la partida, un **panel de consulta** (logros obtenidos, en progreso y ocultos), y una **capa de sincronización opcional con Steam** (M97) totalmente desacoplada: el juego funciona 100% local sin Steam. La regla de oro cozy: **ningún logro exige esfuerzo repetitivo agresivo; cada logro celebra un hito alcanzable, y la condición cumplida antes de instalar el logro se otorga retroactivamente sin castigar al jugador** (alineado con M152 Principios Innegociables y M66 Anti-Softlock).

## 3. Alcance

### 3.1 Dentro del alcance
- Definición de logros: recurso `AchievementDefinition` (id único, nombre i18n, descripción, ícono, condición, progreso parcial, visibilidad/revelación, logro Steam asociado opcional).
- Catálogo base: logros cozy coherentes con la visión del juego (cosecha, pesca, minería, amistad, colecciones M37, progresión M71, exploración, economía, eventos, primeras veces).
- Motor de condiciones: tipos de condición data-driven (contador de estadística, colección completada, especie de pez capturada, amistad máxima, hito de M71, sello de historia, compuestas AND/OR/NOT).
- Desbloqueo: evaluación por eventos (dirty flags), otorgamiento único (sin doble desbloqueo), emisión de señales a la UI y al resto del juego.
- Retroactividad: al cargar una partida, las condiciones ya cumplidas se otorgan automáticamente (logros instalados después de que el jugador cumplió la meta).
- Notificación UI: toast no bloqueante con cola, entrada amable, sin interrumpir el momento cozy; accesible desde M53 (UI/UX).
- Panel de logros: consulta de logros obtenidos (fecha), en progreso (X de Y) y ocultos (revelados al desbloquearse).
- Persistencia: estado de logros (desbloqueados, progresos parciales, fechas) guardado con el guardado global (M60-M59), no bloqueante.
- Integración con Steam (M97): capa opcional `steam_sync` que sube los logros locales a la API de Steamworks (SetAchievement / GetAchievement / Statistics) solo si el juego corre con Steam; si no, todo funciona igual en local.
- Validación en editor: tool scripts que detectan ids duplicados, condiciones inválidas, logros sin ícono, y no coincidencias con el catálogo Steam.

### 3.2 Fuera del alcance
- La curaduría final de nombres, íconos y textos de cada logro es responsabilidad de este módulo pero se hace en `.tres` (no en código); el balance de cuántos logros hay por categoría queda a criterio de diseño (M02 Visión y Concepto).
- El sistema de estadísticas que alimenta las condiciones pertenece a M71 (perfil de jugador); aquí solo se consumen.
- Las reglas propias de las colecciones (qué ítems existen, qué hace falta donar) pertenecen a M37; aquí solo se registra la condición "colección X completa".
- La página de Steam Store (imágenes, textos, traducciones del store) pertenece a M97; aquí solo se declara el mapeo logro-local ↔ logro-Steam.
- Rediseño de la UI de notificaciones core (M53) y de accesibilidad (M58): este módulo las consume y respeta sus reglas.
- No hay logros multijugador, logros de temporada ni logros online de ninguna clase: el juego no tiene red (decisión D4).

## 4. Restricciones

- **Motor:** Godot 4.x (>= 4.4.1), GDScript tipado explícito, sin C# (M04). Voxel Tools para el mundo (M08).
- **Cozy innegociable:** logros tranquilos y motivadores; prohibido el "grind" estresante (condiciones con números abusivos), el FOMO (M94), los logros imposibles o irrecuperables por acción del tiempo (M66), y los logros que exigen jugar contrarreloj (M30 reloj en tiempo real).
- **Data-driven:** los logros viven en `.tres` editables sin tocar código; la lógica de evaluación es genérica por tipo de condición.
- **Desacoplamiento:** el módulo no conoce la UI; comunica por señales (M07 EventBus por dominios). El AchievementManager es un autoload que otros sistemas consultan, pero nadie depende de su UI.
- **Persistencia:** el estado de logros se guarda con la partida (M60/M59) y se restaura completo; la pérdida de un logro por falla de guardado es inaceptable (backup de M107).
- **Sin red obligatoria:** Steam es opcional y 100% desacoplado; el juego funciona idéntico sin Steam (decisión D4). No hay logros online de ninguna plataforma más.
- **Determinismo:** la evaluación de condiciones es determinista y dependiente de eventos, nunca por frame ni por aleatoriedad no sembrada.
- **Rendimiento:** la evaluación de logros no puede superar un presupuesto trivial por evento (micro-segundos); prohibido evaluar todos los logros por frame.
- **Idioma:** todos los textos son en español (i18n preparado para traducción).

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Definición de logros | `AchievementDefinition` (Resource): `achievement_id` único, `nombre_i18n`, `descripcion_i18n`, `icono`, `categoria`, `condicion`, `oculto` (sorpresa), `logro_steam_id` opcional |
| RF2 | Tipos de condición | Condiciones genéricas evaluables: `stat_contador >= n` (estadística de M71), `coleccion_completa(id)` (M37), `pescar_especie(id)` y `pescar_todas_las_especies`, `amistad_maxima(npc)` y `amistad_total >= n` (M20), `hito_71(id)` alcanzado, `sello_historia(id)` (M22), `compuesta(AND/OR/NOT)` |
| RF3 | Evaluación por eventos | Las condiciones se reevalúan solo cuando cambian sus estadísticas dependientes (dirty flags emitidos por M71/M37/M20), nunca por frame |
| RF4 | Desbloqueo único | `unlock(id)`: otorga el logro una sola vez, registra fecha/hora, emite señal, persiste sin esperar el guardado manual |
| RF5 | Retroactividad | Al cargar partida (y al registrar una definición nueva), las condiciones ya cumplidas se otorgan automáticamente con la fecha de la carga |
| RF6 | Notificación | Toast no bloqueante encolado (máximo N visibles a la vez), con ícono, nombre y animación de entrada/salida; no interrumpe el juego |
| RF7 | Panel de logros | Consulta por categoría: obtenidos (con fecha), en progreso (progreso parcial "X de Y" cuando aplica), ocultos (revelados solo al desbloquearse o por regla de visibilidad) |
| RF8 | Progreso parcial | Logros escalonados o acumulativos exponen `progreso_parcial(id)` para que la UI muestre "37 de 50 peces" |
| RF9 | Persistencia | `GuardadoLogros`: diccionario `{id: {desbloqueado, fecha, progreso_parcial}}` serializado con el guardado global (M60), carga/descarga síncrona segura y sin bloqueo de frames |
| RF10 | Consulta de estado | API pública `is_unlocked(id)`, `get_estado(id)`, `get_progreso(id)`, `get_todos()` consumible por UI M53, escritor de diálogos y tutorial M92 |
| RF11 | Reset de partida | Al borrar la partida (M60) el estado de logros se limpia; los logros de Steam se pueden restaurar en la próxima sesión vía sync |
| RF12 | Sincronización Steam (opcional) | `steam_sync`: al iniciar sesión Steam y al desbloquear un logro, sube a Steamworks `SetAchievement`/`StoreStats`; al cargar partida, reconcilia si Steam ya tenía el logro (y si la partida no, lo otorga local y viceversa) |
| RF13 | Registro y analytics | Cada desbloqueo se registra en logs (M103) y analytics (M104) con id, fecha y origen (juego / retroactivo / steam) |
| RF14 | Validación en editor | Tool script de validación: ids únicos, íconos presentes, condiciones válidas, categorías conocidas, mapeo Steam consistente, sin logros duplicados con M71 |

## 6. Requisitos No Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RN1 | Rendimiento | Evaluación de un evento con 200 logros: < 1 ms total; cero evaluación por frame; sin allocaciones significativas por evento |
| RN2 | Persistencia segura | El estado de logros nunca se pierde por cierre abrupto: se persiste inmediatamente tras cada desbloqueo (write-through) además del guardado global |
| RN3 | Desacoplamiento total de Steam | El módulo compila y funciona 100% sin el SDK de Steam; Steam es un plugin opcional (M97) que el juego detecta en runtime |
| RN4 | Determinismo | Dada la misma partida, la evaluación produce siempre los mismos desbloqueos (sin dependencia de frame, orden de import o aleatoriedad) |
| RN5 | i18n | Nombres y descripciones usan claves de traducción (español base); el catálogo Steam también soporta claves de localización |
| RN6 | Compatibilidad | Godot 4.x >= 4.4.1, GDScript tipado; sin dependencias externas salvo la capa Steam (opcional) |
| RN7 | Sin bloqueo de UI | La notificación es no modal, encolable y desactivable en opciones de accesibilidad (M58); el jugador nunca pierde control |
| RN8 | Persistencia con la partida | El estado vive en el guardado de la partida (M60) y es coherente con el PRNG de partida (M29) y con M71 |
| RN9 | Mantenibilidad | Agregar un logro = crear un `.tres` y registrarlo; no requiere tocar código excepto cuando se agrega un tipo de condición nuevo |
| RN10 | Testability | El AchievementManager es testeable con partidas sintéticas (M112 Testing Automático), sin UI ni Steam en los tests unitarios |
| RN11 | Cozy | No hay logros por tiempo real (M30), ni logros que castiguen no jugar, ni porcentajes de jugadores visibles que generen presión social |
| RN12 | Menor tamaño de partida | El estado de logros pesa menos de 10 KB incluso con 500 logros desbloqueados |

## 7. Criterios de Aceptación

1. Con una partida nueva, al cosechar el primer cultivo se desbloquea el logro "Primera cosecha" con notificación visible.
2. Si el logro se instala después de que el jugador ya pescó todas las especies, al cargar la partida se otorga retroactivamente.
3. Desbloquear el mismo logro dos veces es imposible (no re-notifica, no re-persiste, no re-sube a Steam).
4. Cerrar el juego inmediatamente después de un desbloqueo no pierde el logro (write-through + guardado global).
5. Con Steam desactivado, el 100% de los logros funciona igual; con Steam activo, se sincronizan ambos sentidos.
6. En una sesión con 200 logros definidos, ningún frame supera +0.5 ms por eventos de progreso.
7. El panel de logros muestra obtenidos, en progreso (con "X de Y") y ocultos según su estado.
8. Borrar la partida limpia el estado de logros local y la próxima sesión Steam reconcilia.
9. Los textos están en español y no hay caracteres raros ni codificaciones rotas.
10. Toda la documentación de este módulo refleja el código real implementado (plan-actual).

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M071** — Progresión | Logros sobre progresión |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M071** — Progresión | Depende de este módulo |

