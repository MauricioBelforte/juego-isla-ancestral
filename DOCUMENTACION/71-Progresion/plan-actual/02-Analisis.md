**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 71: Progresión

## 1. Análisis del Dominio

La progresión del juego se descompone en seis dominios interconectados, todos convergentes en un registry central de hitos:

### 1.1 Desbloqueos (unlocks)
- **Dominio:** apertura de contenido nuevo: recetas (M16), caminos y regiones (M27/M28), mecánicas (ej: fotografía M56, eventos M74), mejoras vendibles (M39), y contenido narrativo (M22).
- **Características:** cada desbloqueo declara una condición evaluable, un tipo ("receta", "zona", "mecanica", "titulo", "info") y un valor (id del contenido). Los desbloqueos son **suaves**: informan y guían, no bloquean el camino crítico.
- **Concepto clave:** desbloquear no es "subir de nivel"; es "el mundo te reconoce y te abre una puerta". La información del desbloqueo se entrega como notificación calmada (M53) con motivo visible ("Nueva receta disponible").

### 1.2 Mejoras y niveles (upgrades)
- **Dominio:** progresión vertical de herramientas (M13: 9 herramientas x 4 niveles, durabilidad cozy, martillo y lupa infinitos) y de la casa (M18: niveles de ampliación/mejoras).
- **Características:** los niveles son propiedad de M13/M18 (fuente de verdad); el módulo 71 solo **registra hitos** ("herramienta X en nivel 2", "casa en nivel 3") y puede **declarar condiciones** que los referencien para abrir otro contenido (ej: "picota nivel 3 → desbloquear acceso a la cueva profunda").
- **Concepto clave:** la mejora es el premio visible de la economía (M38) y de la recolecta (M15); el 71 la convierte en moneda de progreso transversal.

### 1.3 Reputación y relaciones
- **Dominio:** progresión social: niveles de amistad individuales (M20, niveles 0-4) y una **reputación comunitaria** derivada (promedio ponderado de amistades + contribuciones económicas como ventas, trueques y donaciones al museo M37).
- **Características:** la reputación (0-100) desbloquea títulos sociales y ofertas de trueque mejores vía M38/M20, pero **nunca** bloquea comercio, construcción ni historia.
- **Concepto clave:** en un pueblo cozy, "el respeto del pueblo" es el XP social; se gana con acciones amables (regalos, trueques justos, donaciones), no con números anónimos.

### 1.4 Colecciones
- **Dominio:** progresión horizontal: museo (M37), coleccionables (M73), especies de fauna (M36), registros fotográficos (M56) y logros (M72).
- **Características:** el 71 registra estadísticas (especies vistas, donaciones, fotos tomadas, reliquias encontradas) y condiciones de completitud ("colección de peces completa").
- **Concepto clave:** las colecciones son progresión *de curiosidad*: no otorgan poder, otorgan reconocimiento (títulos, placas, secretos). El registro de "primera vez" (radar de novedades) pertenece aquí.

### 1.5 Hitos narrativos
- **Dominio:** avance de la historia principal (M22: 7 capítulos, 7 sellos como gating del capítulo 4+; 5 finales) y cadenas secundarias persistentes (M23).
- **Características:** los capítulos y sellos son **fuente de verdad de M22**; el 71 solo los refleja como hitos y permite que otros desbloqueos dependan de ellos.
- **Concepto clave:** el esqueleto del progreso es narrativo: el jugador avanza porque *quiere descubrir*, no porque una barra de XP lo presione. Los sellos son gating validado por M22 y vigilado por M66 (anti-softlock).

### 1.6 Economía como facilitador
- **Dominio:** la economía (M38: monedas_aurora, trueques, mercado) es **facilitadora**, no objetivo: el progreso real no es "ser rico" sino "tener la casa hermosa y el pueblo feliz".
- **Características:** el 71 registra estadísticas económicas (monedas ganadas en total, monedas actuales, trueques realizados, objetos vendidos) y deriva hitos informativos ("primera semana próspera"), pero nunca condiciona contenido principal a ser millonario (anti-frustración).
- **Concepto clave:** la riqueza acumulada es una estadística más; los hitos económicos existen para celebrar, no para exigir grind.

## 2. Curvas de Progresión

### 2.1 Curva de desbloqueos (orientativa)
- **Fase temprana (días 1-7):** desbloqueos frecuentes (cada 30-60 min de juego): primeras recetas, primeras herramientas, primer amigo, primer sello. Objetivo: generar sensación de mundo grande y acogedor.
- **Fase media (semanas 2-4):** desbloqueos espaciados (cada 2-4 días de juego): niveles 2-3 de herramientas, casa nivel 2, amistades nivel 3, sellos 2-4. Objetivo: meseta cómoda con metas siempre visibles.
- **Fase tardía (post-capítulo 4):** desbloqueos selectos (sellos 5-7, casa nivel 4, colecciones completables): la meta es la completitud y el desbloqueo de secretos (final alternativo M22), sin presión temporal.

### 2.2 Curva de condiciones (reglas anti-explotación)
- Las condiciones usan **umbrales absolutos** (>= n) en estadísticas de partida, nunca "racha de n días seguidos" (anti-burnout) ni "n eventos en 24h" (anti-reloj-SO, M30).
- Las condiciones combinadas (AND) deben seguir siendo cumplibles individualmente: si una rama depende de un sello (M22) y otra de una amistad (M20), el jugador puede elegir cuál completar primero (elección, no bloqueo).

### 2.3 Relación hitos ↔ recompensas
- Las recompensas de hitos son **no críticas**: cosméticos (títulos, variantes de color), QoL (marcadores en mapa M54, atajos M69), o información (recetas de decoración). El poder duro (herramientas, casas) lo dan los módulos dueños; el 71 solo refleja el hito.

## 3. Anti-Frustración (principios adoptados)

1. **Todo desbloqueable:** ningún contenido es exclusivo de una elección excluyente permanente; las rutas alternativas cumplen la misma función.
2. **Nada expira:** los hitos de temporada (M29) se pueden lograr en la próxima estación; no hay ventanas de oportunidad únicas (anti-FOMO M94).
3. **Condición imposible = bug:** si la validación estática detecta una condición incumplible (estadística sin fuente, ítem inexistente, ciclo de dependencias), se reporta en editor (M66 coopera en runtime).
4. **Pista siempre presente:** la UI (M53) muestra 1-3 metas sugeridas derivadas de hitos próximos; si el jugador ignora, nada se rompe ni se pierde.
5. **Jugador nuevo vs veterano:** las partidas nuevas reciben el flujo de onboarding (M92); las veteranas restauran el estado y omiten notificaciones de hitos ya logrados (RF14).
6. **Sin penalización por inactividad:** el progreso solo avanza con acciones; no hay "decaimiento" de reputación ni pérdida de desbloqueos por no jugar (alineado con M94 y M30).

## 4. Alternativas Consideradas

| Alternativa | Veredicto | Motivo |
|---|---|---|
| XP numérica + niveles de jugador | **Descartada** | El plan maestro evita números de poder; los niveles de jugador crean presión numérica y comparación, anti-cozy |
| Árbol de habilidades | **Descartado** | Complejidad y optimización ansiosa; los desbloqueos por hitos son más narrativos y guiados |
| Progresión lineal estricta (capítulo → capítulo) | **Descartada** | El juego tiene 5 finales y secundarias; la progresión es no lineal con canal principal narrativo (M22) |
| Gating duro (bloquea contenido hasta cumplir) | **Descartado** | Anti-cozy; la historia misma (M22) ya usa sellos narrativos; el resto debe ser suave |
| Cada módulo con su progresión aislada | **Descartada** | Duplica lógica, no permite hitos transversales ("primer día completo") ni logros cruzados |
| Registry central + eventos (adoptado) | **Adoptado** | Un solo catálogo data-driven, condiciones reutilizables, consumo por señales (M07) |
| Rutas alternativas obligatorias para todo | **Matizado** | Solo para condiciones identificadas como "posiblemente incumplibles" (M66); el resto mantiene condiciones simples |
| Reputación como moneda de bloqueo | **Descartado** | La reputación otorga títulos y ofertas; nunca bloquea (D7) |
| Logros con recompensas de poder | **Descartado** | Los logros celebran; su recompensa es cosmética o informativa (M72 cuida la curaduría) |

## 5. Decisiones Clave

1. **D1 — Registry central de hitos:** `MilestoneRegistry` como fuente de verdad del "qué se puede lograr"; cada hito tiene id, condición, recompensas opcionales y orden sugerido.
2. **D2 — Sin XP ni niveles de jugador:** progreso por hitos cualitativos y estadísticas; el "nivel" solo existe en herramientas (M13), casa (M18) y amistad (M20), siempre propiedad de sus módulos.
3. **D3 — Condiciones data-driven por tipo:** `ConditionDefinition` con tipo + parámetros (estadística, umbral, referencia de módulo); sin código por hito individual; combinables con AND/OR/NOT.
4. **D4 — Evaluación por eventos con dirty flags:** cada estadística registra dependientes; el sistema reevalúa solo lo sucio; resultado en caché hasta invalidación.
5. **D5 — Gating suave + rutas alternativas:** condición incumplible estáticamente → error en editor; dinámicamente → notifica a M66 que activa una ruta alternativa o libera el desbloqueo con requisito reducido.
6. **D6 — Señales como único contrato de salida:** `progreso_hito_alcanzado`, `progreso_desbloqueado`, `progreso_logro`, `progreso_primera_vez`; cero referencias a nodos de UI.
7. **D7 — Reputación blanda:** índice 0-100 derivado (amistad 60% + contribuciones 40%); otorga títulos y ofertas suaves, nunca bloquea contenido principal.
8. **D8 — Primeras veces como hitos informativos:** el radar de novedades es un sub-tipo de hito (sin recompensa, pura celebración), desplegable en la UI de M53.
9. **D9 — Persistencia versionada:** el estado de progresión es una sección versionada de GameState (M59); las migraciones solo agregan, nunca quitan desbloqueos.
10. **D10 — Logs y analytics obligatorios:** cada hito/desbloqueo/logro se registra en M103 y se emite a M104 sin acoplar el sistema principal.

## 6. Riesgos y Mitigaciones

| Riesgo | Mitigación |
|---|---|
| Condiciones imposibles por bugs de datos | Validación estática en editor (RF16) + detector de M66 en runtime + rutas alternativas (D5) |
| Desbloqueos duplicados por doble evento | Evaluación idempotente: los hitos se marcan alcanzados antes de emitir; re-evaluación no re-emite |
| Progreso perdido por guardado corrupto | Sección versionada de GameState (M59) + validación al cargar: hitos sin condición no se pierden (D9) |
| Overload de notificaciones al despertar (muchos hitos a la vez) | Cola de notificaciones con prioridad y límite por día en M53; el 71 solo emite señales |
| Jugador veterano con "nada por hacer" | Sugeridor de metas (M53 consume hitos próximos); postgame (M75) re-apunta la progresión |
| Reputación percibida como castigo si baja | La reputación solo sube o se mantiene; nunca decrece (no hay decaimiento) |
| Uso de reloj real en condiciones | Prohibido por M30: las condiciones usan días/estaciones del GameClock (M29), nunca el reloj del SO |
| Ciclos en dependencias entre hitos | Validación topológica del grafo en editor (RF16) |

## 7. Modelo Conceptual (entidades)

- `MilestoneDefinition` (Resource): hito → id, nombre i18n, descripción, condición, recompensas opcionales, orden, visibilidad (oculto/visible).
- `UnlockDefinition` (Resource): desbloqueo → id, tipo ("receta"/"zona"/"mecanica"/"titulo"/"info"), valor (contenido destino), condición, notificación i18n.
- `ConditionDefinition` (Resource): condición → tipo, parámetros (estadística, umbral, módulo, referencia), operador (AND/OR/NOT con hijos).
- `AchievementDefinition` (Resource): logro → id, condición, progreso parcial opcional; la curaduría final es de M72.
- `TitleDefinition` (Resource): título social → nombre i18n, requisito (hitos alcanzados/reputación), orden.
- `ProgressionManager` (autoload): orquesta registros, evalua condiciones, emite señales, persiste.
- `MilestoneRegistry` (autoload/Resource): catálogo cargado de hitos y desbloqueos.
- `UnlockSystem` (autoload): evaluador de condiciones y activador de desbloqueos.
- `PlayerProfile` (autoload): estadísticas acumuladas y del día, primeras veces, reputación.

## 8. Relaciones con Otros Módulos

| Módulo | Relación |
|---|---|
| M13 (Herramientas) | Consume señal de desbloqueo para habilitar niveles; el 71 registra hitos de nivel alcanzado (fuente de verdad: M13) |
| M18 (Casas) | Mismo patrón: hitos de nivel de casa; condiciones que referencian niveles |
| M20 (Amistad) | Señal `nivel_amistad_cambio(npc_id, nivel)` alimenta estadísticas y reputación |
| M22 (Historia) | Capítulos y sellos se reflejan como hitos (solo lectura); desbloqueos pueden depender de sellos |
| M38 (Economía) | Estadísticas económicas (monedas acumuladas, trueques, ventas); sin bloqueos por riqueza |
| M37/M72/M73 (Colecciones) | Condiciones de completitud de colecciones; el 71 registra el "radar de novedades" |
| M07 (Arquitectura) | EventBus por dominios: el 71 produce y consume eventos de dominio |
| M29 (Calendario) | Días jugados para condiciones; sin reloj real (M30) |
| M53 (UI/UX) | Consumidor de señales para notificaciones y panel de progreso |
| M59 (Guardado) | Estado de progresión persistido y versionado en GameState |
| M66 (Anti-Softlock) | Receptor de condiciones incumplibles; activa rutas alternativas |
| M92 (Tutorial) | Hitos de onboarding en partidas nuevas; resumen de veterano en cargas |
| M104 (Analytics) | Eventos de hito/desbloqueo/logro para telemetría |

## 9. Conclusión del Análisis

La progresión de Aurora será un sistema central, data-driven y desacoplado: un registry de hitos y desbloqueos con condiciones tipadas evaluadas por eventos, un perfil de jugador con estadísticas acumuladas, y una capa de señales que todos los módulos consumen sin acoplarse. Se descarta XP numérica, árbol de habilidades y gating duro; se adopta progresión narrativa por hitos con gating suave, rutas alternativas anti-frustración y reputación blanda. El diseño queda listo para implementación en Godot 4.x con GDScript tipado, respetando los contratos de señales de M13/M18/M20/M22/M38 y el EventBus de M07.