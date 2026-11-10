# Reporte de análisis: sistema de misiones/quests/objetivos

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code (Vercel AI Gateway, identidad de sesión según entorno)  
**Fecha:** 2026-11-10 04:10 UTC  
**Alcance solicitado:** `game/isla-ancestral/scripts/` (archivos `.gd` relacionados con misiones, quests, objetivos).  

## 1. Archivos relevantes analizados

### Núcleo de historias secundarias / cadenas (M23)
- `game/isla-ancestral/scripts/historias/quest_chain.gd` (59 líneas)
- `game/isla-ancestral/scripts/historias/quest_chain_service.gd` (173 líneas)
- `game/isla-ancestral/scripts/historias/secondary_stories_service.gd` (470 líneas) — **autoload activo**
- `game/isla-ancestral/scripts/historias/validate_quest_chains.gd` (33 líneas)
- `game/isla-ancestral/scripts/historias/test_historias.gd` (parcialmente leído, suite extensa con bloques A-Z/AA/AB)

### Motivación / objetivos rotatorios (M94)
- `game/isla-ancestral/scripts/motivacion/objetivo_data.gd` (23 líneas)
- `game/isla-ancestral/scripts/motivacion/objetivo_activo.gd` (49 líneas)
- `game/isla-ancestral/scripts/motivacion/motivacion_manager.gd` (180 líneas)

### Invariantes / anti-softlock relacionados
- `game/isla-ancestral/scripts/core/invariants/mision_invariant.gd` (81 líneas)

### Persistencia / integración observada
- `game/isla-ancestral/scripts/saving/test_carga_npc_misiones_m59.gd` (parcial, inicio leído; valida carga con misiones a medias/completadas usando autoload `Historias`)

### Datos
- `game/isla-ancestral/data/historias/secundarias.json` (catálogo principal, parcialmente leído: incluye `cadena-faro`, `cadena-invernadero`, `cadena-epilogo-plaza`, `cadena-secretta-luciernagas`, etc.)
- `game/isla-ancestral/data/historias/cadenas_ejemplo.json` (presente, mergeado por `SecondaryStoriesService`)
- `game/isla-ancestral/data/historias/cosmeticos.json` (presente)
- `game/isla-ancestral/data/motivacion/objetivos.json` (7 objetivos: diarios/semanales/mensuales)

### Configuración
- `game/isla-ancestral/project.godot:72` registra autoload: `Historias="*res://scripts/historias/secondary_stories_service.gd"`.

## 2. ¿Cómo se gestionan las misiones?

### 2.1 Dos sistemas diferenciados

1. **Historias secundarias / cadenas de misiones (M23, autoload `Historias`)**  
   - Implementación efectiva en runtime: `secondary_stories_service.gd` (autoload según `project.godot:72`).  
   - Modelo de datos: `QuestChain` (`quest_chain.gd`) define estructura Resource (`id`, `titulo`, `contexto`, `pasos`, `recompensa`, `consecuencia`, `oculta`, `postgame`, `dialogo_posterior`) y validación básica `validar()` (`quest_chain.gd:28-45`).  
   - Carga data-driven: `_cargar_cadenas()` lee `res://data/historias/secundarias.json` y mergea `res://data/historias/cadenas_ejemplo.json` con reglas de conflicto/rechazo (`secondary_stories_service.gd:56-126`). El catálogo principal prevalece en conflictos por ID; cadenas inválidas del merge se rechazan y se reportan en `_merge_ejemplos`.  
   - Estado en memoria: `_estado[chain_id] = {paso_actual, activa, completada}` (`secondary_stories_service.gd:47,277,350-351`).  
   - API principal: `cadenas_disponibles()`, `get_cadena()`, `iniciar_cadena()`, `reportar_paso()`, `reportar_entrega()`, `esta_activa()`, `esta_completada()`, `get_save_data()/restore_save_data()` (`secondary_stories_service.gd:223-470`).  
   - Visibilidad/reglas: cadenas ocultas no aparecen en disponibles hasta iniciarse (`223-237`, `372-386` en test), postgame requiere `Historia.final_elegido() != ""` (`226,273-276`).  
   - Consecuencias y recompensas al completar: aplica flags de consecuencia a `WorldState` (M21), intenta registrar capítulo de diario en `Diary` (M55), emite `cosmetico_desbloqueado` y señales de `EventBus.quest` (`348-384`).  
   - Persistencia: sección `secondary_stories` con activas/completadas; al restaurar ignora huérfanas no presentes en catálogo (`442-470`).

2. **Servicio alternativo/paralelo `QuestChainService` (`quest_chain_service.gd`)**  
   - Existe como script separado (carga `data/historias/*.json`, usa `QuestChain.new()` y almacena `_cadenas/_estado`, señales propias `cadena_descubierta/completada/paso_completado`, sección save `historias`) (`quest_chain_service.gd:10-163`).  
   - **No es el autoload registrado** (`project.godot` apunta a `secondary_stories_service.gd`); `validate_quest_chains.gd` intenta cargar/usar este servicio como `EditorScript` (`validate_quest_chains.gd:10-33`). Esto sugiere coexistencia de dos implementaciones con contratos distintos (IDs de sección, firmas, semántica de progreso).

3. **Objetivos de motivación/retención (M94, autoload `MotivacionManager`)**  
   - Catálogo JSON `res://data/motivacion/objetivos.json` con objetivos diarios/semanales/mensuales (`motivacion_manager.gd:20,45-65`; `data/motivacion/objetivos.json`).  
   - Estado vivo por objetivo en `ObjetivoActivo` (`objetivo_activo.gd`: progreso, ciclo, completado, cobrado).  
   - Gestión: `objetivos_por_plazo()`, `registrar_progreso()`, `cobrar_recompensa()`, `rotar_objetivos()`; recompensas acumuladas sin expiración y auditoría anti-FOMO (`motivacion_manager.gd:66-154`).  
   - Persistencia vía `snapshot()/restaurar()` (posible integración con DataStore M60 según comentario, líneas 155-180).  
   - **Es un sistema de objetivos recurrentes, no de cadenas narrativas** (condiciones como `recolectar_madera`, `hablar_npc` según `ObjetivoData.condicion`, línea 19; datos en JSON).

### 2.2 Integración con otros sistemas
- `WorldState` (flags de consecuencia), `EventBus.quest`, `Diary` (recompensa narrativa), `Inventario` (entregas), `SaveManager` (registro de proveedor ISaveProvider) y `Historia`/M22 (gating postgame) (`secondary_stories_service.gd` en varios puntos).
- `MisionInvariant` registra objetivos/fallbacks y detecta objetivos activos sin fallback declarado (`mision_invariant.gd:30-56`), orientado a anti-softlock M66 más que a ejecución de quests.

## 3. ¿Hay validación de progreso de misiones?

### 3.1 Validaciones presentes (historias secundarias, runtime principal)
- **Al cargar datos:** validación estructural/anti-repetición por cadena (`QuestChain.validar()` en `quest_chain.gd:28-45`: id/título/contexto mínimo 10 chars, >=3 pasos, pasos con id/tipo, recompensa con diario o cosmético). `SecondaryStoriesService` rechaza cadenas inválidas en merge de ejemplos (`secondary_stories_service.gd:119-122`) y expone `validar_cadenas()`/`_errores_de_cadena()` con reglas adicionales (tipos permitidos `hablar/explorar/puzzle/entregar`, ids de paso únicos, recompensa y consecuencia no vacías, títulos únicos) (`388-431`). Tipos permitidos definidos en `TIPOS_PASO` (`36`).  
- **Al iniciar:** cadena debe existir, no estar ya iniciada/completada; postgame bloqueado sin final M22 (`267-283`).  
- **Al reportar avance:** requiere cadena activa, índice de paso válido, **tipo correcto** del paso actual y **evidencia coincidente** con la referencia esperada (`npc/lugar/objeto/ref`) comparada por slug normalizado (`reportar_paso`, `305-325`; `ref_paso_actual`, `290-301`; `_slug`, `434-438`).  
- **Entregas:** `reportar_entrega()` verifica tipo `entregar`, existencia de item en inventario (`Inventario.count_item/remover_items`) y luego delega en `reportar_paso` (`328-345`). Esto consume el ítem (efecto de progreso irreversible controlado).  
- **Completitud:** al alcanzar el último paso se marca completada, inactiva y se aplican consecuencias/recompensas (`348-384`).  
- **Datos de prueba:** `test_historias.gd` cubre carga, validador, flujo completo, entregas, ocultas, postgame, persistencia, merge, etc. (estructura visible en líneas leídas).

### 3.2 Validaciones presentes (objetivos M94)
- `ObjetivoActivo.avanzar()` calcula transición a completado según `cantidad_requerida` (`objetivo_activo.gd:25-32`).  
- `MotivacionManager.registrar_progreso()` busca objetivo/catálogo, aplica avance y otorga recompensa al completarse (`motivacion_manager.gd:77-88,119-131`).  
- Auditoría anti-FOMO sobre configuración/catálogo (`motivacion_manager.gd:145-153`).

### 3.3 Limitaciones/gaps de validación
- **`QuestChainService` (no-autoload) tiene progreso más débil:** `marcar_paso_completado()` solo asigna `paso_actual` y, si el `id` coincide con el último paso, marca completada; no valida orden secuencial, tipo/evidencia, pertenencia real del paso intermedio, ni requisitos/inventario (`quest_chain_service.gd:123-136`). `get_consecuencias_pendientes()` existe pero no se observa aplicación automática equivalente al flujo de `SecondaryStoriesService`.  
- **No hay validación fuerte de alcanzabilidad de contenido referenciado** en runtime: se valida estructura/tipo de paso, pero no se verifica que el NPC/lugar/puzzle/objeto exista realmente en escenas, sistemas o catálogos de items/puzzles (riesgo de contenido huérfano). La coincidencia es por string/slug.  
- **`MisionInvariant` valida “tiene fallback declarado”, no progreso correcto:** `_check()` falla si hay objetivos activos sin fallback registrado (`mision_invariant.gd:42-49`), útil para detectar diseño incompleto, pero no garantiza que una misión pueda avanzar/completarse.

## 4. ¿Hay misiones que no se pueden completar?

### 4.1 Hallazgos basados en código/datos (riesgos concretos)

1. **Dependencia de contenido externo no verificada automáticamente**  
   - Las cadenas dependen de que otros sistemas emitan/acepten evidencias correctas (`hablar` con NPC id, `explorar` lugar, `puzzle` ref, `entregar` objeto). `SecondaryStoriesService` exige coincidencia exacta normalizada (`305-319`) y, para entregas, que el objeto esté en inventario y se pueda retirar (`339-345`). Si el evento del sistema dueño nunca llama a `reportar_paso/reportar_entrega` con la evidencia esperada, o si el ítem/puzzle/NPC no existe o tiene ID distinto, la cadena queda bloqueada.  
   - Ejemplo visible en datos: `cadena-faro` requiere `puzzle ref "faro-linterna"` y entrega `farol_cargado` (`secundarias.json:9-12`); `cadena-invernadero` requiere `semilla_antigua` (líneas 24-26). La completabilidad depende de que esos refs/ítems sean obtenibles en el juego.

2. **Requisito de postgame para algunas cadenas**  
   - `cadena-epilogo-plaza` está marcada `postgame: true` (`secundarias.json:46`) e `iniciar_cadena()` la rechaza sin final elegido en M22 (`secondary_stories_service.gd:273-276`). Si el jugador no alcanza/cierra el final requerido, la cadena es intencionalmente no iniciable/completable en esa partida (comportamiento de diseño, pero puede percibirse como “no completable” sin contexto).

3. **Cadenas ocultas dependen de descubrimiento/inicio**  
   - `cadena-secretta-luciernagas` es oculta (`secundarias.json:59`) y no aparece en disponibles hasta iniciarse (`secondary_stories_service.gd:230-231`); si no existe trigger de descubrimiento que llame a `iniciar_cadena`, no se puede progresar.

4. **Posible inconsistencia entre implementaciones**  
   - `quest_chain_service.gd` podría marcar una cadena como completada al recibir el ID del último paso sin validar pasos previos (`123-136`), lo que es un riesgo de integridad (falso completado) más que de imposibilidad; pero también carece de aplicación robusta de consecuencias y gating. Si alguna herramienta/editor usa este servicio en lugar del autoload real, puede haber discrepancias de estado.  
   - `validate_quest_chains.gd` instancia `quest_chain_service.gd` para validar (`25-33`), mientras el runtime usa `secondary_stories_service.gd`: la validación editorial y la validación/runtime real no son exactamente la misma ruta de código.

5. **MisionInvariant puede señalar diseño incompletable pero no lo impide solo**  
   - `_check()` devuelve falso si un objetivo activo no tiene fallback (`mision_invariant.gd:42-49`), lo que indica potencial condición imposible por diseño; la recuperación efectiva depende de que otros sistemas registren objetivos/fallbacks y reaccionen.

### 4.2 No se confirma evidencia directa de misiones “imposibles” en disco
- No se encontró en los archivos leídos una cadena con pasos vacíos/corruptos cargada en el catálogo principal mostrado ni un bloqueo hardcodeado explícito; el sistema principal incluye filtros/validaciones y pruebas extensas. Sin embargo, la completabilidad real depende de la existencia y cableado de contenido externo (puzzles, ítems, NPCs, lugares, triggers, flags de historia).

## 5. Sugerencias de mejora (2)

1. **Unificar contrato y ruta de validación/ejecución de cadenas (eliminar duplicidad riesgosa)**  
   - **Problema:** coexisten `secondary_stories_service.gd` (autoload real, lógica rica) y `quest_chain_service.gd` (API distinta, progreso sin validación de tipo/evidencia/orden, sección save distinta). `validate_quest_chains.gd` usa el servicio alternativo.  
   - **Mejora:** consolidar en una sola implementación canónica (preferiblemente `secondary_stories_service.gd`/`Historias`) y adaptar herramientas editor/headless para validar contra el mismo contrato. Añadir tests de compatibilidad de persistencia (`historias` vs `secondary_stories`) o migración explícita.  
   - **Beneficio:** reduce bugs por divergencia, evita falsas validaciones en editor y estados inconsistentes entre runtime y herramientas.

2. **Agregar validación de alcanzabilidad/integridad referencial de cadenas en CI o carga**  
   - **Problema:** la validación actual comprueba forma (tipos, cantidad de pasos, ids, recompensa/consecuencia) pero no que `npc`, `lugar`, `objeto` y `ref` de puzzle existan en catálogos/sistemas correspondientes; un ID mal escrito o contenido faltante puede volver una misión no completables en runtime.  
   - **Mejora:** incorporar un validador cruzado (script/editor test) que verifique referencias contra fuentes conocidas (por ejemplo: ids de villagers/NPCs, ítems en `data/items` o inventario, puzzles registrados, lugares/flags esperados) y reporte errores como bloqueantes antes de merge/release. Complementar con logging de diagnóstico cuando `reportar_paso` falle por evidencia/tipo.  
   - **Beneficio:** detecta misiones imposibles por contenido roto temprano y mejora la trazabilidad para QA/diseño.

## 6. Conclusión final

- **Gestión:** el proyecto gestiona misiones principalmente mediante **cadenas data-driven de historias secundarias** (M23) en el autoload `Historias` (`secondary_stories_service.gd`), con soporte de inicio, avance por pasos tipados, entregas con consumo de inventario, consecuencias en mundo, recompensas y persistencia; además existe un subsistema separado de **objetivos recurrentes de motivación** (M94) con progreso/ciclos/recompensas acumuladas.  
- **Validación de progreso:** hay validación sólida en el servicio principal (estructura de cadenas, tipos de paso, evidencia/ref por slug, estado activo, requisitos postgame, inventario en entregas y pruebas amplias), pero `QuestChainService` alternativo es notablemente más permisivo y la alcanzabilidad de referencias externas no se valida integralmente.  
- **Misiones no completables:** no se identificó una cadena rota explícita en la muestra leída, pero **sí existen condiciones/riesgos reales de no completabilidad** por dependencias externas no cableadas (NPC/lugar/puzzle/ítem/evidencia), gating postgame/oculto, y por la divergencia entre servicios/herramientas de validación.  
- **Recomendación prioritaria:** unificar la implementación/validación de cadenas y añadir verificación de integridad referencial de contenido para prevenir cadenas bloqueadas en juego.

**Nota:** análisis realizado a partir de lectura estática de código/datos disponibles en el workspace al momento de la ejecución; no se ejecutó Godot headless ni se verificó en runtime la existencia efectiva de todos los assets/NPCs/puzzles referenciados fuera de los archivos inspeccionados.  
