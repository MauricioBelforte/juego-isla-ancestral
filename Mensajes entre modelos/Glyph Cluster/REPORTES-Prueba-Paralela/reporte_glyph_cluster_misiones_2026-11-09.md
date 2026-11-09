# Reporte: Misiones, quests y objetivos — `game/isla-ancestral/scripts/`

**Modelo:** Glyph Cluster  
**Plataforma:** Vercel AI Gateway (Kilo Code)  
**Fecha:** 2026-11-09  
**Alcance analizado:** `game/isla-ancestral/scripts/**/*misio*.gd`, `*quest*.gd`, `*objetiv*.gd`, datos `data/historias/*`, `data/motivacion/*`, autoloads en `game/isla-ancestral/project.godot`, y test de persistencia M59 relacionado.

## Archivos relevantes identificados

| Archivo | Rol |
|---|---|
| `game/isla-ancestral/scripts/historias/quest_chain.gd` (L1–59) | Modelo `Resource` `QuestChain` para cadenas de misiones (M23). |
| `game/isla-ancestral/scripts/historias/quest_chain_service.gd` (L1–173) | Servicio/cargador de cadenas desde `res://data/historias/*.json`, estado y persistencia (M23). |
| `game/isla-ancestral/scripts/historias/secondary_stories_service.gd` (L1–470) | **Autoload `Historias`** (`project.godot` L72). Motor activo de historias secundarias: inicio, avance, validación, recompensas, consecuencias y save (M23). |
| `game/isla-ancestral/scripts/historias/validate_quest_chains.gd` (L1–33) | `EditorScript` para validar cadenas (apunta al servicio `quest_chain_service.gd`). |
| `game/isla-ancestral/scripts/core/invariants/mision_invariant.gd` (L1–81) | Invariante M66: detecta objetivos activos sin fallback, evita duplicación de recompensas de fallback, avisa al diario al activar fallback. |
| `game/isla-ancestral/scripts/motivacion/objetivo_data.gd` (L1–23) | `Resource` con definición de objetivo (diario/semanal/mensual). |
| `game/isla-ancestral/scripts/motivacion/objetivo_activo.gd` (L1–49) | Estado vivo de objetivo: progreso, cobro, ciclo, serialización. |
| `game/isla-ancestral/scripts/motivacion/motivacion_manager.gd` (L1–180) | **Autoload `MotivacionManager`** (`project.godot` L97). Tablero de objetivos, rotación sin FOMO, recompensas acumuladas, auditoría anti-FOMO. |
| `game/isla-ancestral/scripts/saving/test_carga_npc_misiones_m59.gd` (L1–492) | Suite M59: pruebas de carga con misión a medias (L135) y tras completar misión/reabrir (L136), contrato directo + e2e con `SaveManager`. |
| `game/isla-ancestral/data/historias/secundarias.json` | Catálogo principal de cadenas secundarias (schema v1, muchas cadenas). |
| `game/isla-ancestral/data/historias/cadenas_ejemplo.json` | Catálogo adicional mergeado por el servicio activo. |
| `game/isla-ancestral/data/historias/cosmeticos.json` | Catálogo de cosméticos referenciados por recompensas. |
| `game/isla-ancestral/data/motivacion/objetivos.json` | Catálogo de objetivos de motivación. |

## 1) ¿Cómo se gestionan las misiones?

Hay **dos sistemas distintos** relacionados con “objetivos”:

### A. Historias secundarias / cadenas de misiones (M23, sistema de quests)

- **Modelo de datos:** `QuestChain` (`quest_chain.gd` L9–59) define `id`, `titulo`, `contexto`, `pasos`, `recompensa`, `consecuencia`, flags `oculta`/`postgame` y validación básica (`validar`, L28–45). Cada paso es un `Dictionary` con `id`, `tipo` y referencias (`npc`/`lugar`/`objeto`/`ref`).
- **Motor activo/autoload:** `secondary_stories_service.gd` se registra como `Historias` (`project.godot` L72). Carga data-driven desde `res://data/historias/secundarias.json` (L28, L69–84) y mergea `cadenas_ejemplo.json` (L29, L108–126). Mantiene:
  - `_cadenas`: catálogo cargado (L45).
  - `_estado`: progreso por cadena `{paso_actual, activa, completada}` (L46–47, L277, L321, L350–351).
  - `_fuente` y reporte de merge (L48–51, L140–147).
- **Ciclo de vida:**
  - `iniciar_cadena()` valida existencia, no reinicio, requisito de postgame (`Historia.final_elegido`) y emite `EventBus.quest.quest_started` (L267–283).
  - `reportar_paso()` valida cadena activa, tipo del paso actual y evidencia contra `ref_paso_actual()`; avanza o completa (L305–324).
  - `reportar_entrega()` consume del inventario (`/root/Inventario`) para pasos `entregar` antes de avanzar (L328–345).
  - `_completar_cadena()` aplica consecuencias al `WorldState` (flags), registra recompensa de diario si existe (`/root/Diary`), emite desbloqueo cosmético y señales de quest completada (L348–384).
- **Visibilidad/consultas:** `cadenas_disponibles()` filtra ocultas no iniciadas, postgame sin final M22 y completadas (L223–237). Hay consultas `esta_activa`, `esta_completada`, `get_cadena`, `ids_cadenas`, recompensas cosméticas derivadas de completadas (L150–219).
- **Persistencia:** implementa proveedor M59 con sección `secondary_stories`; guarda activas y completadas, ignora huérfanas al restaurar (L443–470). `SaveManager` lo registra en `_ready` (L128–131).

### B. Objetivos de motivación (M94, no son cadenas narrativas)

- **Modelo:** `ObjetivoData` (plazo diario/semanal/mensual, condición, cantidad, recompensa; L10–23) y `ObjetivoActivo` (progreso, cobrado, ciclo, completado, serialización; L10–49).
- **Gestor/autoload:** `MotivacionManager` carga `res://data/motivacion/objetivos.json`, crea activos, registra progreso, otorga recompensas acumuladas sin expiración, rota objetivos sin pérdida (RF1/FOMO), expone auditoría anti-FOMO y snapshot/restauración (L6–180, autoload `project.godot` L97). Esto es un tablero de retención, separado del motor de cadenas M23.

## 2) ¿Hay validación de progreso de misiones?

Sí, en varios niveles, pero con diferencias según componente:

- **Validación estructural de cadena (modelo):** `QuestChain.validar()` exige `id`, `titulo`, `contexto >= 10`, `>= 3 pasos`, cada paso con `id` y `tipo`, y recompensa con `diario` o `cosmetico` (`quest_chain.gd` L26–45).
- **Validación al cargar (servicio legacy/cargador):** `quest_chain_service.gd` valida cada cadena antes de registrarla y advierte si es inválida (`_registrar_cadena`, L60–83; `validar_todas`, L166–173). Filtra IDs de sección con `has("id")`/`has("tipo")` implícitamente al registrar datos, pero la validación fuerte es `chain.validar()`.
- **Validación anti-repetición/esquema (motor activo):** `secondary_stories_service.gd` implementa `_errores_de_cadena()` y `validar_cadenas()`: contexto suficientemente largo, `>= 3` pasos, tipos conocidos (`hablar/explorar/puzzle/entregar`), IDs de paso únicos, recompensa y consecuencia presentes, título único (L36, L389–431). El merge de ejemplos rechaza cadenas nuevas inválidas (L108–126).
- **Validación de progreso en runtime:**
  - `iniciar_cadena()` impide cadenas inexistentes, re-inicio y postgame sin final (L267–276).
  - `reportar_paso()` exige cadena activa, tipo correcto del paso actual y evidencia coincidente con `npc/lugar/objeto/ref` (`_slug` normaliza acentos/ñ; L305–324, L434–438).
  - `reportar_entrega()` exige paso `entregar`, verifica inventario, consume 1 unidad y solo entonces avanza (L328–345).
- **Validación/invariantes transversales:** `MisionInvariant` (M66) comprueba que objetivos activos tengan fallback declarado; si falta, `_check()` falla y da razón útil. También gestiona anti-duplicación de recompensas de fallback y aviso al diario al activar fallback (L14–81).
- **Validación por pruebas:** `test_carga_npc_misiones_m59.gd` verifica coherencia tras carga: misión a medias conserva `paso_actual`, no re-ofrece el paso ya hecho, permite reportar el siguiente, e2e con `SaveManager`; misión completada no se reabre, no se duplica, no se reinicia ni se re-ofrece, y persiste estable (L235–443).

## 3) ¿Hay misiones que no se pueden completar?

### Hallazgos directos del análisis estático

No se observó, solo por inspección de los scripts de misiones, un bloqueo duro codificado explícitamente; sin embargo, hay **riesgos reales de incompletabilidad** dependientes de datos/contenido y de wiring externo:

1. **Dependencia de sistemas externos para cumplir pasos (riesgo alto de “misión imposible” si falta contenido/cableado):**  
   El motor M23 no ejecuta por sí mismo los pasos de mundo; espera que otros sistemas llamen `reportar_paso()` o `reportar_entrega()` con el tipo/evidencia correctos (`secondary_stories_service.gd` L304–345). Un paso `hablar/explorar/puzzle/entregar` puede quedar bloqueado si no existe el NPC/lugar/puzzle/objeto en runtime, si el trigger no llama al servicio, o si la evidencia no coincide con el `ref` esperado. El test M59 ejercita el contrato del servicio, pero no prueba que todos los triggers de juego real disparen cada paso.

2. **Riesgo de datos: recompensa de diario puede ser “data muerta”/no entregada aunque la cadena complete (riesgo funcional medio):**  
   Al completar, el servicio registra `rec.diario` en `/root/Diary` si no está vacío (L360–370), pero el propio código documenta que `Diary.registrar()` puede devolver `false` en silencio si la entrada no existe en el catálogo de M55 (“2 de 79 capítulos existen en disco; el resto es contenido de M55 — hallazgo reportado”). La cadena igual se marca completada y aplica consecuencia/cosmético; el jugador puede perder la recompensa narrativa sin error visible.

3. **Catálogo grande y posible drift de contenido (riesgo medio, requiere validación runtime/editor):**  
   `secundarias.json` contiene muchas cadenas con objetos `OBJ-*`, lugares, puzzles y flags de consecuencia (muestra visible desde L1; archivo largo). Si algún `objeto` no existe en `ItemDatabase`, no hay trigger para `puzzle/ref`, o el NPC/lugar no está cableado, la cadena puede quedar atrapada en un paso. Esto no se puede confirmar solo leyendo los scripts de misión; exige cruzar IDs contra inventario, escenas, puzzles y diálogos.

4. **Diseño de invariante no integrado visiblemente al motor activo (riesgo arquitectónico):**  
   `MisionInvariant` requiere registrar objetivos/fallbacks (`registrar_objetivo`, `registrar_fallback`, L30–38) y expone `activar_fallback` (L60–72). En los archivos inspeccionados no se ve su integración con `secondary_stories_service.gd` ni con `quest_chain_service.gd`; por tanto, cadenas/pasos sin fallback no se detectan automáticamente por este invariante salvo que otro sistema lo alimente. Esto puede dejar “condiciones imposibles” sin ruta alternativa declarada.

5. **Validación de entrega exige posesión exacta del item (comportamiento esperado, pero puede bloquear progreso):**  
   `reportar_entrega()` falla si el objeto no está en inventario (`count_item < 1`) o no se puede retirar (L339–345). Si el item es consumido/perdido por otro flujo o nunca se otorga, la cadena queda activa e incompletable hasta recuperar el objeto.

### Conclusión sobre incompletabilidad

- **No se detectó una misión específica garantizadamente incompletable** solo con evidencia estática de los scripts analizados.
- **Sí hay superficie de riesgo** para misiones incompletables por: faltantes de triggers/contenido externo, IDs de diario inexistentes (recompensa narrativa fallida), objetos/puzzles/lugares no conectados, o ausencia de integración del invariante de fallback.

## 4) Sugerencias de mejora (2)

1. **Unificar y endurecer el pipeline de validación de cadenas (editor/CI/runtime de carga).**  
   - Hacer que `validate_quest_chains.gd` use el motor realmente activo (`secondary_stories_service.gd` / autoload `Historias`) o un validador compartido, en lugar de instanciar `quest_chain_service.gd` con ruta distinta (riesgo de validar lógica vieja; `validate_quest_chains.gd` L13–33 vs autoload real `project.godot` L72).  
   - Agregar validación cruzada de referencias: que `npc/lugar/objeto/ref` existan en sus catálogos/sistemas (`ItemDatabase`, escenas/lugares, puzzles), que `recompensa.diario` exista en M55, que `recompensa.cosmetico` exista en `cosmeticos.json`, y que flags de `consecuencia` sigan el esquema canónico.  
   - Ejecutar `validar_cadenas()`/`validar_cosmeticos()` en CI/headless y fallar ante errores, no solo advertir.

2. **Agregar observabilidad y rutas de recuperación para misiones atascadas.**  
   - Emitir logs/eventos estructurados cuando `reportar_paso`/`reportar_entrega` falle (`cadena no activa`, `tipo incorrecto`, `evidencia incorrecta`, `objeto no disponible`) incluyendo `cadena_id`, `paso_actual`, `tipo esperado` y `evidencia`. Esto facilita detectar quests imposibles en playtests.  
   - Integrar `MisionInvariant` con el motor activo: registrar objetivos/pasos activos y fallbacks declarados desde `Historias`; si un paso depende de un objeto/trigger frágil, declarar fallback o alternativa equivalente.  
   - Añadir una herramienta de diagnóstico (debug/QA) que liste cadenas activas, paso esperado (`ref_paso_actual`), prerequisitos y razón probable de bloqueo; opcionalmente un comando seguro de recuperación solo en builds de debug para no dejar softlocks en pruebas.

## Conclusión final

La base de misiones/quests está **parcialmente madura y data-driven**: el sistema activo es M23 (`Historias` → `secondary_stories_service.gd`) con validación de esquema/anti-repetición, avance validado por tipo/evidencia, consumo de entregas, consecuencias, cosméticos, señales y persistencia probada en M59 para estados “a medias” y “completada”. Existe además M94 (`MotivacionManager`) como sistema separado de objetivos de retención. Los principales riesgos no son de lógica básica del motor, sino de **integración y contenido** (triggers externos, IDs de diario/objetos/puzzles/lugares, posible desalineación entre el validador/editor y el autoload real) y de **falta de integración visible del invariante de fallbacks**. Priorizar validación cruzada automática y diagnóstico de bloqueos reduciría significativamente la probabilidad de misiones no completables.
