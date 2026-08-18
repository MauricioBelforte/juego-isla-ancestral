**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 72: Sistema de Logros

## 1. Análisis del dominio

### 1.1 Qué es un logro en un juego cozy

En un juego cozy como Isla Ancestral (mundo voxel, isla Aurora, ritmo calmado tipo Stardew Valley), el logro no es una competición ni una exigencia: es una **celebración registrada** de un hito que el jugador alcanzó jugando con calma. El diseño de logros del proyecto se guía por reglas propias:

- **Motivadores, no estresores:** un logro pide "cosechar 100 cultivos en total" pero nunca "cosechar 1000 en un día" ni "completar la colección antes del día 30".
- **Alcanzables por jugar tranquilo:** todo logro es alcanzable sin jugar contrarreloj ni grindeando acciones repetitivas con números abusivos (prohibición de M94 y M66).
- **Sin FOMO y sin castigo:** no existen logros de tiempo real (M30), logros "por no hacer algo" ni logros que se pierdan para siempre.
- **Sorpresa amable:** los logros ocultos se revelan al desbloquearse; la sorpresa es un regalo, no un requisito.

### 1.2 Definición de logros (RF1)

Se analizaron dos enfoques de definición:

- **A. Logros hardcodeados por sistema** (cada sistema crea su propio flag "logro_pescador_master = true"): desacoplado, inconsistente, imposible de curar desde diseño y de sincronizar con Steam como catálogo; cada logro exige código nuevo.
- **B. Catálogo data-driven central** (recursos `.tres` con id, texto, ícono, condición y metadatos): un solo motor evalúa todo; agregar un logro no toca código; el catálogo se valida en editor y se puede mapear 1:1 con Steam.

**Decisión D1 — Catálogo data-driven central (B).** El motor es genérico (tipos de condición), el contenido vive en `.tres`, y la curaduría (nombres, íconos, cantidades) es editable por diseño sin programación. Coincide con la arquitectura de M71 (registry de hitos) y M37 (colecciones).

### 1.3 Condiciones de desbloqueo (RF2)

Las condiciones posibles provienen de sistemas ya documentados:

| Fuente | Condición ejemplo | Emisor del evento |
|---|---|---|
| M71 perfil de jugador | `stat_contador(cosechas_totales) >= 100` | M71 (estadísticas acumuladas) |
| M71 hitos | `hito_71(herramienta_nivel_max)` | M71 (señal de hito) |
| M37 colecciones | `coleccion_completa(museo)` / `coleccion_porcentaje(museo) >= 0.8` | M37 (señal de donación) |
| M34 pesca | `pescar_especie(x)` / `pescar_todas_las_especies()` | M34 (señal de captura) |
| M20 amistad | `amistad_maxima(npc)` / `amistad_total >= n` | M20 (señal de nivel de amistad) |
| M22 historia | `sello_historia(capitulo_1)` | M22 (señal de capítulo) |
| Compuestas | `AND(a, b)`, `OR(a, b)`, `NOT(a)` | Cualquier combinación |

Análisis: las condiciones no deben evaluarse "a demanda" del sistema sino **reactivamente**: cada emisor dispara un evento de progreso (via M07 EventBus o señal directa del manager), y el AchievementManager re-evalúa solo los logros cuyas condiciones dependen de ese tipo de evento (dirty flags). Esto evita el barrido por frame (RN1).

### 1.4 Persistencia (RF7/RF9)

- **Formato:** diccionario `{ achievement_id: { desbloqueado: bool, fecha_iso: String, progreso: float, extra: Dictionary } }`.
- **Dónde:** dentro del guardado global de la partida (M60/M59), junto a hitos de M71; es coherente con el PRNG (M29).
- **Write-through:** cada desbloqueo se persiste inmediatamente (archivo de estado o flag en memoria + guardado global periódico), de modo que un cierre abrupto no pierda logros (RN2).
- **Borrado de partida:** el estado se limpia con la partida; la reconcialiación con Steam (si existe) ocurre en la próxima sesión (RF11).

### 1.5 Notificaciones (RF6)

Análisis de opciones de feedback al desbloquear:

- **A. Modal central (popup que roba el foco):** rompe el ritmo cozy; el jugador pierde control; prohibido en M58.
- **B. Toast encolado no bloqueante:** aparece a un costado de la pantalla, se apila si llegan varios a la vez (máx. 3 visibles), se desvanece solo, puede ser tocado para abrir el panel; nunca roba input.
- **C. Solo registro silencioso (sin UI):** pierde la celebración; el jugador no se entera del hito.

**Decisión D2 — B (toast encolado no bloqueante)** con animación suave, ícono + nombre + descripción corta, configurable (desactivable en accesibilidad M58) y con delays regenerativos para evitar spam de varios logros simultáneos (se funden en un resumen "3 nuevos logros desbloqueados" si la cola supera N).

### 1.6 Sincronización Steamworks: opcional vs solo local (RF12)

Análisis de tres posturas:

- **A. Steam obligatorio:** el juego exige Steam para logros; rompe builds sin SDK y plataformas alternativas; rechazado (el proyecto es multi-plataforma, sin red obligatoria).
- **B. Solo local (sin Steam nunca):** simple y seguro, pero pierde la visibilidad pública del 100% de logros en la página de Steam (M97) y el overlay de logros de la plataforma.
- **C. Local por defecto + capa opcional Steam desacoplada:** el motor de logros es 100% local y agnóstico; una capa `steam_sync` (M97) opcional detecta en runtime si corre con Steam y sincroniza en ambos sentidos (local → `SetAchievement`/`StoreStats`; `GetAchievement` → local para logros "imposibles" ya ganados fuera). Sin Steam el juego es idéntico.

**Decisión D3 — C.** El AchievementManager no conoce Steam; la capa `steam_sync` se registra como listener de la señal `logro_desbloqueado` y consulta `API_Steam` solo si está disponible. El mapeo logro-local ↔ logro-Steam vive en el propio `.tres` (`logro_steam_id`), validado en editor (RF14).

### 1.7 Retroactividad (RF5)

Caso crítico: aceptar una actualización, DLC o parche agrega un logro cuya condición el jugador ya cumplió ("pescar todas las especies" cuando el jugador ya tiene la colección completa). Sin retroactividad, el logro sería **imposible de obtener** — violación grave de M66 (anti-softlock).

**Decisión D4 — Evaluación retroactiva al cargar:** al cargar la partida y al registrar definiciones nuevas, el manager evalúa todas las condiciones de logros no desbloqueados; los que cumplan se otorgan con la fecha de la carga y notificación normal (encolada). Además, como la persistencia guarda progreso parcial (RF8), los logros acumulativos retoman su conteo exacto al cargar.

## 2. Alternativas consideradas y decisiones

| # | Decisión | Alternativa descartada | Motivo |
|---|---|---|---|
| D1 | Catálogo data-driven central (`.tres`) | Logros hardcodeados por sistema | Mantenibilidad, consistencia, curaduría sin código, mapeo Steam 1:1 |
| D2 | Toast encolado no bloqueante | Modal central / solo registro | Ritmo cozy, accesibilidad M58, celebración visible |
| D3 | Steam opcional desacoplado (capa `steam_sync`) | Steam obligatorio / solo local | Multi-plataforma (M97), cero dependencia, sync bidireccional |
| D4 | Sin logros online ni de temporada | Logros multijugador / estacionales | El juego no tiene red; cero FOMO (M94) |
| D5 | Evaluación reactiva por eventos con dirty flags | Barrido por frame / evaluación manual por sistema | Rendimiento (RN1), determinismo (RN4), cero acoplamiento |
| D6 | Persistencia write-through + guardado global (M60) | Solo en guardado manual | RN2: no perder logros por cierre abrupto |
| D7 | Progreso parcial expuesto por API (`get_progreso`) | Solo estado binario desbloqueado/sin | El panel "X de Y" motiva sin estresar (RF8) |
| D8 | Logros ocultos revelados al desbloquearse | Logros ocultos permanente (Secret en Steam) | Sorpresa amable; evitar frustración de "¿qué hago?" |

## 3. Riesgos y mitigaciones

- **Spam de notificaciones** (migración de partida viejas desbloquea 20 logros a la vez): mitigado con cola + resumen "N nuevos logros" (D2) y delays regenerativos.
- **Doble desbloqueo por eventos duplicados** (una señal emitida dos veces): mitigado con flag atómico `_desbloqueados[id]` y guarda previa a la evaluación (RF4).
- **Inconsistencia con Steam** (logro local sin el Steam o viceversa): mitigado con reconciliación en carga (RF12) y validación en editor del mapeo (RF14).
- **Logros imposibles por condición rota** (referencia a estadística inexistente): mitigado con validación en editor que falla el import con error accionable.
- **Crecimiento del catálogo** (cada logro cuesta una evaluación): mitigado con índice condición → logros dependientes (solo se re-evalúan los afectados).
- **Pérdida de logros por guardado fallido:** mitigado con write-through (D6) y backups de M107.

## 4. Métricas y presupuesto

- Presupuesto de evaluación por evento: < 1 ms con 200 logros definidos (RN1).
- Tamaño de estado de logros en partida: < 10 KB con 500 logros desbloqueados (RN12).
- Tiempo de notificación: entrada 0.25 s, visible 3.5 s, salida 0.5 s, encolable.
- Máximo 3 notificaciones visibles simultáneas; si la cola supera 5, se resume en un único toast.

## 5. Conclusiones

El módulo 72 se implementa como un **motor de logros local, data-driven y reactivo**, con persistencia write-through, retroactividad garantizada, notificaciones cozy no bloqueantes y una capa Steam estrictamente opcional y desacoplada. El contenido (logros cozy) es curaduría en `.tres`; el motor es código genérico por tipos de condición. No se compromete rendimiento, no se toca la UI core (M53/M58) y no se agrega ninguna dependencia obligatoria.