**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 74: Eventos

## 1. Análisis del Dominio

### 1.1 Festivales como "momentos de conexión"

El plan maestro define los festivales de Aurora como **momentos de conexión con el pueblo**: el jugador comparte la vida de la isla, no "grindece" contenido. Esto desplaza el diseño de:
- *"¿Qué pierdo si no voy?"* → *"¿Qué celebración me espera este año?"*
- Eventos-trampa de tiempo real (móvil) → eventos del calendario interno de la partida.

Consecuencia: el sistema de eventos debe ser **expectativa positiva** (agenda, avisos, ambiente cambiante en la plaza) y nunca amenaza (castigo, exclusividad irrecuperable). La columna vertebral es el **calendario Aurora de M29** (día/mes/estación/año), no el reloj real (M30 ya lo congela offline: sin castigos por ausencia).

### 1.2 Tipos de eventos del mundo de Aurora

| Tipo | Ejemplos | Ciclo | Condición típica |
|---|---|---|---|
| Festival estacional | Fiesta de la Primavera, Solsticio de Verano, Cosecha de Otoño, Festival de Invierno | Anual (fecha fija) | Estación + fecha |
| Feria del pueblo | Feria de la Colmena, Mercado Nocturno | Mensual/anual | Día de semana + mes |
| Competencia | Torneo de Pesca (M34), Concurso Minero (M35), Desafío Agrícola (M33) | Anual/estacional | Hora + inscripción |
| Ritual ancestral | Ceremonia de los Templos (M24), Vigilia de la Luna | Anual | Progreso de historia (M22/M23) |
| Evento climático | Aurora boreal, Niebla del Faro, Lluvia de estrellas | Esporádico | Condición de clima M32 + fecha |
| Sorpresa | Visitas, regalos a la puerta, criaturas (M36) | Azar por día | Probabilidad, sin solapamiento |

### 1.3 Disparadores (cómo se enciende un evento)

Tres familias de disparadores, todas dependientes del **estado de la partida** (nunca del reloj SO):

1. **Fecha fija:** día/mes/estación del calendario M29. Ej: "15 de Flor de Bruma".
2. **Fecha + franja horaria:** se abre a las 10:00 y cierra a las 22:00 (hora interna M30).
3. **Condición contextual:** clima (M32), progreso de historia, amistad (M20), inventario, temporada de cultivo.
4. **Azar controlado:** sorpresas con probabilidad diaria, límite semanal y colisión-check contra festivales.

El disparo genera **señales** en `EventBus` (M29): `evento_proximo`, `evento_iniciado`, `evento_terminado`, `evento_cancelado`. Los consumidores (UI M53, NPCs M19, audio M41/42/43, agenda M30) reaccionan sin que `EventManager` los conozca.

### 1.4 Condiciones de participación

Cada evento define sus condiciones mediante un objeto **`CondicionEvento`** (recurso reutilizable, expresión declarativa sobre el estado):

- Franja horaria abierta (default: todo el día del festival).
- Requisito de progreso (historia M22/M23, templos M24, amistad mínima M20).
- Requisito de inventario/herramienta (M14/M33/M34/M35) para competencias.
- Clima permitido (M32): si el evento es de exterior con tormenta, se ejecuta la **variante cubierta** o se traslada al salón comunal, nunca se pierde.

Fallar una condición **no bloquea el juego** (regla cozy): el jugador recibe un aviso amable y la puerta del evento se reactiva cuando cumpla (dentro del mismo día; para competencias, quedan 2 días de inscripción residuales).

### 1.5 Recompensas

Modelo de recompensa **seguro y no duplicable**, adaptado del plan maestro:

- Definidas en el `EventDefinition` (objetos M14, moneda M38, amistad M20, progreso M71, decoración para la casa M17/M18).
- **Token anti-duplicado:** `sistema.registro = { anio: int, evento_id: String, recompensas_recibidas: PackedStringArray }`. El mismo año solo se entrega una vez; los años siguientes vuelven a entregar (repetibilidad anual — el premio es "por año", no "único en la vida").
- **Doble validación:** condición en datos + estado guardado (RN7); re-entrada rápida o carga concurrente no clonan objetos.
- Para ferias/competencias: **moneda de feria** canjeable en el puesto (M38) — acumulable sin límite anual, así jugadores que llegan tarde al año pueden participar y la feria no cierra temprano.

### 1.6 FOMO vs repetibilidad (M94)

Reglas de diseño que el módulo **aplica automáticamente** (no a mano por evento):

| Regla | Mecanismo | Verificación |
|---|---|---|
| Todo festival se repite cada año | Reprogramación automática en el calendario al fin de año | Auditoría por datos |
| Sin contenido exclusivo irrecuperable | Checklist por evento: toda recompensa única tiene ruta alternativa (tienda M39, museo M37, misión M23) | Test de catálogo |
| Sin castigo por ausencia | El mundo se congela offline (M30); el evento "del día" puede vivirse si el jugador conecta ese día; si no, espera al próximo año (nada se elimina) | Test de ausencia |
| Sin urgencia artificial | Avisos previos cortos y amables; sin contadores de "última oportunidad" | Revisión de strings UI |

### 1.7 Integración con NPCs (M19/M64)

- Los días de evento, las rutinas de NPC (M19/M64) redirigen a los aldeanos al **recinto del festival** durante la franja horaria.
- La integración es por **datos**: cada EventDefinition tiene una "plantilla de ocupación" (quiénes están en el recinto y desde qué hora). M74 publica `EventBus.day.ocupacion_evento(EventDefinition)`; M19 la consume sin acoplarse.
- Los diálogos de festival (M21) se referencian por id de evento; el sistema de eventos entrega el **contexto** (evento actual, participante, resultado) vía una estructura `ContextoFestival` que M21 puede pedir.

### 1.8 Edge cases críticos de dominio

1. **Evento en año nuevo:** el globo festivo cae el 1.1 a las 00:00; la transición de año (M29) y el inicio del evento deben encadenarse sin duplicar el aviso ni perdonarse el evento.
2. **Jugador ausente:** conecta el 3.1 cuando el festival fue el 1.1 → no hay penalización; el historial marca "no participó"; el evento queda disponible el año siguiente.
3. **Evento solapado:** dos eventos caen el mismo día (feria mensual + festival estacional) → el EventManager resuelve por prioridad (festival > competencia > feria > sorpresa); la sorpresa se re-programa a otro día.
4. **Recompensa duplicada:** re-entrada al mismo evento el mismo año → el token anti-duplicado la bloquea; la UI avisa "Ya recibiste la recompensa de este año".
5. **Festival con lluvia:** M32 activa tormenta → el evento exterior corre su variante cubierta (recinto techado, diálogos de variante) en lugar de cancelarse.
6. **Guardar a mitad de evento:** se persiste el estado del evento (en curso/participado/no participado); al cargar, los banners no se re-muestran pero el recinto sigue abierto si quedaba franja horaria.
7. **Recompensa fallida por inventario lleno (M14):** caen al buzón de entregas con retención de 30 días, sin pérdida.
8. **Cambio de clima durante el evento:** si la tormenta aparece a mitad, se evalúa el tope de la franja; el evento no se interrumpe abruptamente (se espera al cierre del día).

## 2. Alternativas consideradas

| Alternativa | Pros | Contras | Decisión |
|---|---|---|---|
| A1: Lógica de cada evento hardcodeada en scripts | Control total | Duplicación, difícil iteración, viola modularidad | ❌ Rechazada |
| A2: Eventos 100% data-driven (`EventDefinition` `.tres`) | Iteración rápida, testeo fácil, agentes de contenido pueden agregar festivales sin código | Requiere motor de condiciones/recompensas genérico | ✅ **Elegida** |
| A3: Cron job global con un solo script que chequea todo cada frame | Simple | Polling, coste por frame, difícil de razonar | ❌ Rechazada |
| A4: Motor de eventos por señales + checks al cambiar de día (M29 `dia_cambio`) | Cero polling, determinista, barato | Requiere hook del calendario (ya existe via EventBus) | ✅ **Elegida (base de A2)** |
| A5: Eventos en tiempo real vinculados al reloj SO | "Sorpresas reales" | Rompe M30/M94 (castigos por ausencia, exploit) | ❌ Prohibida por el plan maestro |
| A6: Recompensas sin registro (siempre entregables) | Simple | Duplicados infinitos, rompe economía M38 | ❌ Rechazada |
| A7: Recompensas con token por año | Sin duplicados, repetibilidad anual, FOMO nulo | Requiere persistencia por año | ✅ **Elegida** |
| A8: Un solo sistema que también haga la UI del festival | Menos archivos | Acopla gameplay con UI (viola M09) | ❌ Rechazada |
| A9: UI separada (banners/ventana/agenda) que consume señales | Desacoplamiento limpio (M53) | Más archivos | ✅ **Elegida** |
| A10: Integrarse a M19 modificando rutinas | Cambios profundos | Rompe sistema estable | ❌ Rechazada (integración por datos/señales) |

## 3. Decisiones técnicas

1. **D1 — Motor por datos + señales:** `EventManager` (autoload/service) recibe el catálogo de `EventDefinition`, consulta la agenda al `dia_cambio` de M29 y publica señales. Nada por frame.
2. **D2 — `CondicionEvento` declarativa:** recurso reutilizable con tipo (hora, clima, amistad, historia, inventario) + valores; evaluación centralizada y testeable unitariamente.
3. **D3 — Token anti-duplicado por año:** registro en `GameState.M74` con versión; una recompensa por evento por año; recompensas de años siguientes sí se otorgan.
4. **D4 — Prioridad de solapamiento:** festival > competencia > feria > ritual > sorpresa; la agenda se normaliza al inicio del año (y al guardar/cargar).
5. **D5 — Persistencia mínima:** `M74: { anio: { evento_id: {estado, recompensas[], mejor_puesto} } }` + "recuerdos" (galería M37). Versionado para migración.
6. **D6 — Fallback de carga (M63):** si la escena del evento no carga, se cancela con aviso y recompensa compensatoria (moneda simbólica), jamas crash.
7. **D7 — Sin tocar módulos estables:** M74 solo consume M19/M21/M29/M30/M32 (APIs y señales). Cualquier necesidad nueva se resuelve con datos o señales nuevas en EventBus documentadas para cada módulo.

## 4. Riesgos y mitigaciones

| Riesgo | Prob. | Impacto | Mitigación |
|---|---|---|---|
| Eventos demasiado frecuentes → saturación | Media | Media | Límite: 1 festival grande por estación + ferias menores; agenda visible permite planificar |
| Festival aburrido por falta de minijuego | Media | Alta | Contratos de minijuego definidos aquí; contenidos se agregan como módulos posteriores sin rediseñar |
| Clima rompe evento de exterior | Media | Alta | Variante cubierta obligatoria por evento exterior (checklist de datos) |
| Duplicación de recompensas por guardado concurrente | Baja | Alta | Token anti-duplicado + validación doble + test de re-entrada |
| FOMO residual en competencias (premio del año) | Media | Media | El premio anual se repite cada año; bicampeón registra *mejor puesto* en historial, no exclusividad |
| Solape de fechas con cumpleaños de NPC (M29) | Baja | Baja | Regla de datos: los cumpleaños nunca se mueven; ferias se corren de día con aviso |

## 5. Referencias al plan maestro

- Festivales como momentos de conexión (M02, M04).
- Repetibilidad y anti-FOMO (M94; reglas rojas).
- Calendario Aurora (M29), hora interna (M30), clima (M32).
- Rutinas NPC (M19/M64), diálogos (M21), amistad (M20).
- Economía y tiendas (M38/M39), inventario (M14), progresión (M71).
- Museo/colecciones (M37), historias secundarias (M23), templos y rutas (M24/M25).
- UI/UX (M53), accesibilidad (M58), localización (M57), análisis de datos (M104).