**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 71: Progresión

## 1. Arquitectura

El sistema de progresión se organiza en **autoloads de lógica pura** (sin UI) que se comunican por señales a través del EventBus de dominio (M07). La UI (M53) y los módulos consumidores (M13/M18/M20/M22/M38/M72) escuchan las señales salientes; ningún autoload referencia nodos de Canvas.

```
[Autoloads del módulo]
ProgressionManager  → orquestador: registros, evaluación, emisión de señales, persistencia
MilestoneRegistry   → catálogo data-driven de hitos, desbloqueos y logros (carga .tres)
UnlockSystem        → evaluador de condiciones (dirty flags + caché) y activador de desbloqueos
PlayerProfile       → estadísticas acumuladas y del día, primeras veces, reputación, títulos

[Recursos .tres (data)]
data/catalogos/milestone_catalog.tres   → lista de MilestoneDefinition
data/catalogos/unlock_catalog.tres      → lista de UnlockDefinition
data/catalogos/achievement_catalog.tres → lista de AchievementDefinition
data/catalogos/title_catalog.tres       → lista de TitleDefinition
data/condiciones/*.tres                 → condiciones reutilizables por tipo
data/hitos/*.tres                       → hitos por dominio (herramientas/, casa/, amistad/, historia/, economia/, colecciones/, generales/)

[Flujo de dependencia]
EventBus (M07) ← PlayerProfile (registra estadísticas)
PlayerProfile → UnlockSystem (estadísticas y dirty flags)
UnlockSystem → MilestoneRegistry (definiciones) y ProgressionManager (emisión)
ProgressionManager → señales de progreso → consumidores externos
```

Orquestación: el `ProgressionManager` suscribe eventos de dominio del EventBus (M07): recolectar ítem (M15), vender (M38), subir amistad (M20), completar sello (M22), mejorar casa (M18), etc. Cada evento incrementa estadísticas del `PlayerProfile`; el `UnlockSystem` marca sucias las condiciones dependientes y las reevalúa; los hitos cumplidos se marcan y emiten señales.

## 2. Diagramas de Flujo (texto)

### 2.1 Registro de estadística → reevaluación de condiciones

```
EventBus (M07) emite evento de dominio (ej: "item_recolectado(cantidad=1)")
  → PlayerProfile.incrementar("items_recolectados", 1)
  → PlayerProfile marca sucias las estadísticas afectadas
  → UnlockSystem.reevaluar_sucias()
  → por cada condición dependiente (diccionario estadística → condiciones):
       ├─ condición cumplida ?
       │    ├─ hito: ProgressionManager.marcar_hito(id) [idempotente]
       │    │    → señal progreso_hito_alcanzado(id, nombre_i18n, recompensas)
       │    │    → aplicar recompensas no críticas (título, infoa, marcador)
       │    │    → log DOM-PROG-HITO + evento analytics M104
       │    └─ desbloqueo: UnlockSystem.activar_desbloqueo(id)
       │         → señal progreso_desbloqueado(id, tipo, valor)
       │         → log DOM-PROG-UNLOCK
       └─ NO cumplida → se registra progreso parcial (logrado/requerido) para UI de M53
```

### 2.2 Hito narrativo (sellos M22 y capítulos)

```
M22 emite "sello_obtenido(sello_id)" / "capitulo_avanzado(capitulo_id)"
  → ProgressionManager refleja como hito_narrativo (solo lectura, no valida)
  → condiciones que dependen del sello se reevaluan (dirty)
  → si un desbloqueo depende de sellos (ej: acceso a contenido del capítulo 5):
       → gating suave: se emite señal de desbloqueo PERO M66 vigila
  → la historia (M22) sigue siendo la fuente de verdad del avance narrativo
```

### 2.3 Jugador nuevo vs veterano (carga de partida)

```
carga de partida (M59 inicia restauración)
  → GameState entrega sección "progresion" versionada
  → ProgressionManager.cargar_estado(data):
       ├─ valida integridad (hitos alcanzados existen en catálogo)
       ├─ si partida nueva (sin estado): inicializar perfil + hitos de onboarding (M92)
       └─ si veterana:
            → restaurar estadísticas, hitos, desbloqueos, primeras veces, reputación
            → NO re-emitir señales de hitos ya alcanzados (idempotencia)
            → emitir progreso_resumen_cargado(hitos_total, desbloqueos_total) para UI
```

### 2.4 Condición incumplible (gating suave con M66)

```
validación en editor: condición imposible detectada estáticamente → error bloqueante
runtime: UnlockSystem detecta condición cuyo estado del mundo la hace imposible
  (ej: depende de un ítem inexistente, o un NPC que no apareció por semilla)
  → informa a M66 vía señal progreso_condicion_imposible(condicion_id, motivo)
  → M66 decide: ruta alternativa (definida en el UnlockDefinition.alternativa_id)
  → o requisito reducido (UnlockDefinition.desbloqueo_reducido)
  → el sistema NUNCA deja el desbloqueo permanentemente inaccesible sin Aviso documentado
```

## 3. Clases / Autoloads Previstos

### 3.1 `ProgressionManager` (autoload)
- Responsable: orquestación, marcado idempotente de hitos, emisión de señales, persistencia.
- Expone: `marcar_hito(milestone_id) -> bool`, `hito_alcanzado(id) -> bool`, `hitos_alcanzados() -> Array`, `hitos_proximos(limite) -> Array`, `guardar_estado() -> Dictionary`, `cargar_estado(data) -> void`, `reset_dia()`.
- Señales: `progreso_hito_alcanzado(id, nombre_i18n, recompensas)`, `progreso_desbloqueado(id_unlock, tipo, valor)`, `progreso_logro(id_logro)`, `progreso_primera_vez(actividad_id)`, `progreso_condicion_imposible(condicion_id, motivo)`, `progreso_resumen_cargado(totales)`.

### 3.2 `MilestoneRegistry` (autoload / Resource)
- Responsable: carga y validación de catálogos (hitos, desbloqueos, logros, títulos); búsquedas O(1).
- Expone: `get_milestone(id) -> MilestoneDefinition`, `get_unlock(id) -> UnlockDefinition`, `get_logro(id) -> AchievementDefinition`, `load_catalogos() -> Array[String]` (errores de validación), `condiciones_de_estadistica(stat_id) -> Array`.

### 3.3 `UnlockSystem` (autoload)
- Responsable: evaluador de condiciones con dirty flags y caché; activador de desbloqueos.
- Expone: `reevaluar_sucias()`, `evaluar(condicion_id) -> bool`, `progreso_parcial(condicion_id) -> Dictionary` ({logrado, requerido}), `activar_desbloqueo(unlock_id)`, `caché_invalida(stat_id)`.
- Señales: (emisiones delegadas a ProgressionManager para un solo punto de salida).

### 3.4 `PlayerProfile` (autoload)
- Responsable: estadísticas acumuladas y del día, primeras veces, reputación y títulos.
- Expone: `incrementar(stat_id, cantidad)`, `set(stat_id, valor)`, `get(stat_id) -> Variant`, `estadisticas_dia() -> Dictionary`, `primera_vez(actividad_id) -> bool`, `marcar_primera_vez(actividad_id)`, `reputacion() -> float` (0-100), `titulos() -> Array`, `guardar_estado() / cargar_estado()`.

### 3.5 Recursos de datos (`.tres`)
- `MilestoneDefinition`: `milestone_id`, `nombre_i18n`, `descripcion_i18n`, `condicion (Resource)`, `recompensas: Array[Dictionary]`, `orden: int`, `visible: bool`, `dominio: StringName` ("herramientas"/"casa"/"amistad"/"historia"/"economia"/"colecciones"/"generales").
- `UnlockDefinition`: `unlock_id`, `tipo: StringName` ("receta"/"zona"/"mecanica"/"titulo"/"info"), `valor: StringName` (contenido destino), `condicion (Resource)`, `alternativa_id: StringName` (ruta M66), `desbloqueo_reducido: UnlockDefinition`, `notificacion_i18n`.
- `ConditionDefinition`: `condicion_id`, `tipo: StringName` (ver 3.6), `parametros: Dictionary` (stat_id, umbral, modulo_ref, valor_ref), `operador: StringName` ("AND"/"OR"/"NOT") y `hijos: Array[Resource]` para compuestas.
- `AchievementDefinition`: `logro_id`, `nombre_i18n`, `descripcion_i18n`, `condicion (Resource)`, `progreso_parcial: bool`, `visible: bool` (curaduría final M72).
- `TitleDefinition`: `title_id`, `nombre_i18n`, `requisito: ConditionDefinition`, `orden`.

### 3.6 Tipos de condición soportados (catálogo inicial)
| tipo | parámetros | ejemplo |
|---|---|---|
| `stat_min` | stat_id, umbral | `items_recolectados >= 100` |
| `dias_jugados` | umbral (días GameClock M29) | `dias >= 30` |
| `nivel_modulo` | modulo ("herramienta"/"casa"/"amistad"), ref, nivel | `picota >= 2` (M13) / `casa >= 2` (M18) / `amistad pilar >= 3` (M20) |
| `sello_historia` | sello_id | `sello_brisa == true` (M22) |
| `capitulo_historia` | capitulo_id | `capitulo_4 == true` (M22) |
| `riqueza_acumulada` | umbral monedas (M38) | `monedas_ganadas_total >= 5000` |
| `coleccion_completa` | coleccion_id (M37/M73) | `fauna_aves == completa` |
| `hito_previo` | milestone_id | `hito_picota_n2 == alcanzado` |
| `primera_vez` | actividad_id | `primera_venta == true` |
| `compuesta` | operador AND/OR/NOT + hijos | `(sello_1 AND sello_2) OR amistad>=4` |

## 4. Integración con Módulos 13, 18, 20, 22 y 38

### 4.1 M13 (Herramientas)
- Fuente de verdad de niveles: M13 emite señal (ej: `nivel_herramienta_cambio(herramienta_id, nivel)` — nombre real a confirmar al implementar).
- El 71 registra el hito "herramienta X nivel N" y permite condiciones `nivel_modulo`.
- Contrato: los desbloqueos de nivel superior se declaran en el catálogo del 71 con condición tipada; M13 solo valida su propia progresión interna.
- Reversa: si M13 necesita saber "puedo habilitar nivel 3 porque el jugador alcanzó X" → escucha `progreso_desbloqueado`.

### 4.2 M18 (Casas)
- Igual patrón que M13: `nivel_casa_cambio(nivel)` → hito reflejo + condiciones de nivel.
- Las mejoras de casa (decoración, huertos) pueden tener desbloqueos propios tipados "receta"/"info".
- Sin acoplamiento: el 71 nunca mueve bloques ni valida construcciones (M17/M18).

### 4.3 M20 (Amistad)
- Señal consumida: `nivel_amistad_cambio(npc_id, nivel)` (0-4) → `PlayerProfile` actualiza estadísticas de amistad y reputación.
- Hitos: "todas las amistades en nivel 2", "primer amigo nivel 3", "amistad máxima con X".
- Condiciones de desbloqueo por amistad existen para contenido social (trueques únicos M38, eventos M74); nunca bloquean contenido principal (D7).

### 4.4 M22 (Historia Principal)
- Solo lectura: capítulos y 7 sellos se reflejan como hitos narrativos; el 71 no valida el grafo (M22 lo hace).
- Condiciones `sello_historia`/`capitulo_historia` disponibles para desbloqueos post-capítulo 4 (contenido tardío) con vigilancia de M66.
- Los 5 finales (M22) registran un hito de cierre; el postgame (M75) reinicia la "lista de cosas por hacer" manteniendo desbloqueos.

### 4.5 M38 (Economía)
- Estadísticas económicas alimentadas por señales de M38 (`transaccion_registrada`, `trueque_exitoso`): monedas_ganadas_total, monedas_gastadas_total, trueques_realizados, objetos_vendidos.
- Hitos económicos informativos ("primer millar de monedas", "10 trueques") celebran sin exigir grind (regla de oro: riqueza nunca es condición de contenido principal).
- La reputación comunitaria suma un componente de contribución (ventas y trueques), ponderado al 40% frente al 60% de amistad.

## 5. Contrato de Señales (resumen)

| Señal | Emisor | Consumidores |
|---|---|---|
| `progreso_hito_alcanzado(id, nombre, recompensas)` | ProgressionManager | UI notificaciones (M53), logros (M72), títulos |
| `progreso_desbloqueado(unlock_id, tipo, valor)` | ProgressionManager | M13/M18/M20/M38/M22 (activación), M53, sonido M43 |
| `progreso_logro(id_logro)` | ProgressionManager | M72 (presentación), M103, M104 |
| `progreso_primera_vez(actividad_id)` | ProgressionManager | M53 (radar de novedades), M37 (museo) |
| `progreso_condicion_imposible(condicion_id, motivo)` | ProgressionManager | M66 (anti-softlock) |
| `progreso_resumen_cargado(totales)` | ProgressionManager | M53 (resumen de veterano), M92 |
| `nivel_herramienta_cambio(id, nivel)` | M13 | PlayerProfile (estadísticas) |
| `nivel_casa_cambio(nivel)` | M18 | PlayerProfile |
| `nivel_amistad_cambio(npc, nivel)` | M20 | PlayerProfile, reputación |
| `sello_obtenido(sello_id)` / `capitulo_avanzado(id)` | M22 | ProgressionManager (reflejo) |
| `transaccion_registrada(tx)` / `trueque_exitoso(...)` | M38 | PlayerProfile (economía), reputación |

## 6. Persistencia

Se guarda en la sección `progresion` de GameState (M59), versionada (`version: 1`):
- `hitos_alcanzados: Array[StringName]` (ids, orden de consecución).
- `desbloqueos_activos: Array[StringName]`.
- `logros_desbloqueados: Array[StringName]` + progresos parciales.
- `estadisticas_totales: Dictionary` (stat_id → valor acumulado).
- `estadisticas_dia: Dictionary` + `fecha_dia_actual: int` (M29) para reset correcto.
- `primeras_veces: Array[StringName]`.
- `reputacion: float` (se recalcula al cargar desde amistad/contribuciones, no se confía solo en el valor persistido).
- `titulos: Array[StringName]`.
- `version: int`.

Reglas: al cargar, los hitos se validan contra el catálogo; los ids desconocidos se conservan (migración hacia adelante) sin romper la partida; nunca se re-emiten señales de hitos restaurados.

## 7. Optimización

- Búsqueda de hitos/desbloqueos O(1) con diccionarios precargados en el `_ready()` del registry (validación incluida).
- Sín bucles por frame: la reevaluación ocurre solo al marcar una estadística como sucia (evento); entre eventos, nada se ejecuta.
- Caché de resultados de evaluación invalidada únicamente por la estadística afectada (mapa stat_id → condiciones dependientes).
- Progreso parcial calculado solo cuando lo pide la UI (evaluación perezosa), nunca por frame.
- Arrays acotados: catálogos estáticos (sin instanciación en runtime), primeras veces en un `Dictionary[StringName, bool]`.
- Sin asignaciones pesadas en el camino de evaluación: las condiciones puras son `RefCounted` baratos, reutilizados del pool del registry.
- Presupuesto de memoria: el estado de progresión es un Dictionary plano (decenas de entradas), no crece con los frames.

## 8. Catálogo Inicial de Hitos (tabla de referencia)

| Dominio | Hito de ejemplo | Condición | Recompensa |
|---|---|---|---|
| Herramientas (M13) | `hito_picota_n2` | nivel_modulo(picota, 2) | info: receta mejorada |
| Casa (M18) | `hito_casa_n2` | nivel_modulo(casa, 2) | marcador de mapa (M54) |
| Amistad (M20) | `hito_amigo_n3` | nivel_modulo(amistad, pilar, 3) | título "Amigo del Pueblo" |
| Historia (M22) | `hito_sello_brisa` | sello_historia(sello_brisa) | info: lore (M148) |
| Economía (M38) | `hito_monedas_1000` | riqueza_acumulada(1000) | variante decorativa |
| Colecciones (M37) | `hito_fauna_completa` | coleccion_completa(fauna_aves) | placa de museo |
| Generales | `hito_dias_30` | dias_jugados(30) | título "Guardián de Aurora" |
| Primeras veces | `primera_venta` | primera_vez(primera_venta) | — (celebración) |

Regla de balance: las recompensas de hitos son cosméticas, informativas o QoL (nunca poder duro); el poder duro (niveles de herramienta, casa) lo gestionan M13/M18 como módulos dueños; el 71 solo los refleja y los referencia en condiciones.