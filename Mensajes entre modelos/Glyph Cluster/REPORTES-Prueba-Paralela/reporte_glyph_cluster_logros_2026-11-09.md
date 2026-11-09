# Reporte: Sistema de logros (M72) - Glyph Cluster

Fecha: 2026-11-09  
Ruta del proyecto: D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\  
Directorio analizado: game/isla-ancestral/scripts/logros/ + game/isla-ancestral/data/logros/

## Archivos analizados

### Scripts (.gd)
- `game/isla-ancestral/scripts/logros/achievement_service.gd` (622 líneas) - Autoload "Achievements" (M72)
- Tests relacionados (existentes):
  - `game/isla-ancestral/scripts/logros/test_logros.gd`
  - `game/isla-ancestral/scripts/logros/test_logros_m72_statids.gd`
  - `game/isla-ancestral/scripts/logros/test_logros_depende_de_m72.gd`
  - `game/isla-ancestral/scripts/logros/test_logros_rf1_e.gd`
  - `game/isla-ancestral/scripts/logros/test_logros_rf10_m72.gd`
  - `game/isla-ancestral/scripts/logros/test_logros_rf13_m72.gd`
  - `game/isla-ancestral/scripts/logros/test_m72_deuda_assets.gd`
  - `game/isla-ancestral/scripts/logros/test_m72_rf6_m72.gd`

### Datos
- `game/isla-ancestral/data/logros/logros.json` (285 líneas) - Catálogo con 18 logros

## 1) ¿Cómo se gestionan los logros?

El sistema está centralizado en `AchievementService` (autoload `Achievements`):

- **Carga data-driven**: Lee `res://data/logros/logros.json` en `_ready()` (`_cargar_catalogo()` L61-103). Cada entrada se normaliza a un diccionario interno con `id`, `nombre`, `descripcion`, `nombre_i18n`, `descripcion_i18n`, `icono`, `categoria`, `logro_steam_id`, `condicion`, `oculto`, `progreso_parcial`, `orden`, `depende_de`.
- **Delegación de evaluación**: Las condiciones usan el mismo formato que M71. La evaluación se delega a `ProgressionManager.evaluar_condicion(cond)` (L220-222). No duplica lógica de evaluación.
- **Evaluación por eventos**: Conexiones event-driven a `ProgressionManager` (hitos), `EventBus` (inventory/economy/npc/quest), `Fishing.captura_exitosa` (L152-154, L182-194), `coleccionables.categoria_completed` (L156-158). Nunca evalúa por frame.
- **Desbloqueo idempotente**: Verifica si ya está desbloqueado (`logro_id in _desbloqueados`) y comprueba dependencias (`depende_de`) antes de desbloquear (L239-266).
- **Fechas deterministas**: Usa `GameTime.dia_absoluto()` y `GameTime.get_hora()` para registrar fecha/hora (RN11, sin reloj real) (L268-277).
- **Persistencia**: Se registra como proveedor de guardado en `SaveManager` (`_registrar_proveedor_guardado()` L105-109). Guarda en sección `achievements` con `version: 2` (L34, L588-622). Soporta migración desde v1 (array) a v2 (diccionario con fechas).
- **Retroactividad**: Tras restaurar, `call_deferred("re_evaluar_todo")` otorga logros cuyas condiciones ya se cumplen (RF5) (L225-233, L620-622).
- **UI/Notificaciones**: Emite `logro_desbloqueado`, `logro_progreso`, `panel_solicitado` (L36-39). Toasts bufferizados por frame (RF6) y enviados vía `EventBus.ui.notify`. Respeta configuración de accesibilidad (M58) para desactivar toasts (L47-48, L161-175, L282-284).
- **API para UI**: `get_todos()`, `get_estado()`, `get_porcentaje_completado()`, `listado_para_ui()`, `get_en_progreso()`, etc. (L367-437).

## 2) ¿Hay validación de condiciones para desbloquear logros?

Sí, hay validación en múltiples niveles:

### En el servicio (validación de catálogo)
- **Validación al arranque**: `_cargar_catalogo()` llama a `validar_catalogo()` (L100-103). Imprime advertencias si hay problemas.
- **Validación de catálogo** (`validar_catalogo()`, L458-511):
  - IDs vacíos o duplicados.
  - Cada logro debe tener `icono` no vacío (RF1/RF14).
  - `categoria` debe pertenecer a `CATEGORIAS_VALIDAS` (L451-455): agricultura, pesca, mineria, amistad, colecciones, progresion, exploracion, epilogo.
  - `logro_steam_id` no duplicados.
  - `condicion` no vacía.
  - Valida tipos de condición contra `TIPOS_CONDICION_VALIDOS` (L443-446): stat_min, dias_jugados, sello_historia, capitulo_historia, riqueza_acumulada, primera_vez, hito_previo, coleccion_completa, nivel_modulo, compuesta.
  - Para `stat_min` exige `stat_id` no vacío.
  - Para `compuesta` valida recursivamente los hijos.
- **Deuda de dependencias externas** (medida, no falla validación): `iconos_ausentes()` verifica existencia de archivos PNG en disco; `claves_i18n_ausentes()` verifica claves en `locales/es.po` (L520-563). Se reporta como `[M72][DEUDA]` pero no incrementa el contador de problemas.

### En el desbloqueo
- **Idempotencia**: No desbloquea si ya está en `_desbloqueados` (L240).
- **Dependencias**: Revisa `depende_de` - solo desbloquea si todas las dependencias ya están desbloqueadas (L243-246).
- **Delegación al evaluador**: Usa `ProgressionManager.evaluar_condicion(cond)` para determinar si se cumple la condición (L221).

### En el evaluador
La validación lógica de condiciones se delega a `ProgressionManager` (M71). El contrato es el mismo formato documentado en el código.

## 3) ¿Hay logros que no se pueden conseguir?

Basado en el análisis del catálogo y código:

### Posibles problemas identificados

**Logros con condiciones que usan stats posiblemente no alimentados:**
- `logro_primer_cultivo` (L175-188), `logro_cosecha_diez` (L190-204), `logro_primer_mineral` (L206-219), `logro_minero_veterano` (L221-235) usan `stat_id: "regalos_dados"` con umbrales 1, 10, 1, 25. Esto parece **incorrecto semánticamente** - regalar no está relacionado con plantar/cosechar/minar. Probablemente deberían usar stats como `cultivos_sembrados`/`cultivos_cosechados` o `minerales_extraidos`, pero en el código actual solo se alimenta `peces_capturados` (L186) y `amistad_max_*` (L205-208). Estos logros podrían nunca desbloquearse si `regalos_dados` no se incrementa por esas acciones.

- `logro_dias_en_aurora` (L252-266) usa `stat_id: "viajes_realizados"` con umbral 30. También parece **erróneo** - debería usar días jugados. El código tiene soporte para `dias_jugados` en los tipos válidos, pero este logro usa `viajes_realizados`. Probablemente no se puede conseguir o cuenta mal.

- `logro_primera_isla` (L237-250) usa `viajes_realizados` umbral 2 - razonable si contar incluye viaje inicial.

- `logro_vecino` (L68-81) usa `regalos_dados` umbral 1 - podríaconectarse a regalos dados, pero semánticamente cuestionable.

**Logros dependientes:**
- `logro_siete_sellos` depende de `logro_primer_sello` (L33-35). Si hay algún problema con `logro_primer_sello`, este queda bloqueado.
- `logro_ruina_restaurada` depende de `logro_siete_sellos` (L280-282) y usa `hito_previo` con `hito_ruina_restaurada` (L276-279). Bloqueado en cadena si hay problemas.

**Logro oculto:**
- `logro_secreto_guardian` (L98-111) usa `hito_previo` con `hito_sello_ceniza_sala1` (L108-110). Aparece como "???" hasta desbloquearse (L397-401). Depende de que ese hito exista en M71.

**Acciones no conectadas al sistema:**
El código solo conecta eventos específicos (L129-159). Acciones como **plantar/cosechar, minar/extracciones minerales, construir** no tienen conexiones explícitas. Si los stats correspondientes no se incrementan desde otros sistemas, esos logros nunca se desbloquearán. Los que usan `regalos_dados` podrían desbloquearse accidentalmente si ese stat se usa para otra cosa.

## 4) ¿Hay persistencia de logros desbloqueados?

**Sí, completamente implementada:**

- **Registro como proveedor**: Se registra en `SaveManager` via `register_provider(self)` (L105-109).
- **Sección de guardado**: `get_section_name()` retorna `"achievements"` (L584-586).
- **Datos guardados** (v2): Diccionario con `version: 2` y `desbloqueados` como diccionario mapeando `logro_id -> {"dia": int, "hora": int}` (L588-595). Las fechas son deterministas (basadas en GameTime).
- **Restauración**: `restore_save_data()` (L597-622) limpia estado, restaura logros válidos del catálogo, migra desde v1 (array) ignorando logros que ya no existen en el catálogo actual, y llama `re_evaluar_todo()` de forma diferida para retroactividad (RF5).
- **Write-through**: Tras cada desbloqueo exitoso llama `SaveManager.mark_dirty()` (L253-255).
- **Idempotente y robusto**: Ignora logros obsoletos del catálogo viejo al restaurar (L609, L618). No re-emite señales al restaurar (L620).

## 5) Sugerencias de mejoras

### Mejora 1: Corregir mapeo de stats para logros agrícolas/mineros/pesca
**Problema**: `logro_primer_cultivo`, `logro_cosecha_diez`, `logro_primer_mineral`, `logro_minero_veterano` usan `regalos_dados` en lugar de stats específicos. `logro_dias_en_aurora` usa `viajes_realizados` en lugar de días jugados.

**Solución**:
1. Definir/incrementar stats correctos en los sistemas correspondientes (Agricultura: `cultivos_plantados`/`cultivos_cosechados`, Minería: `minerales_extraidos`, Tiempo: `dias_jugados`).
2. Actualizar `logros.json` para apuntar a los stats correctos.
3. Añadir conexiones en `achievement_service.gd` si es necesario (similar a cómo se hace con pesca/amistad/colecciones).
4. Añadir validación/migración si hay saves existentes con logros incorrectamente asignados.

**Beneficio**: Logros realmente alcanzables y semánticamente correctos.

### Mejora 2: Añadir tracking de acciones faltantes y validación de alcanzabilidad
**Problema**: Muchas acciones (plantar, cosechar, minar) no están conectadas. No hay forma de detectar logros potencialmente inalcanzables.

**Solución**:
1. **Conexiones adicionales**: Añadir señales en `achievement_service.gd` para agricultura/minería cuando existan en EventBus (o conectar a autoloads correspondientes).
2. **Método de validación de alcanzabilidad**: Añadir `validar_alcanzabilidad()` que verifique para cada logro con `stat_min` si existe algún código que incremente ese stat, o si usa tipos válidos conectados. Reportar logros sospechosos.
3. **Tests**: Ampliar tests para cubrir el caso de logros con stats no alimentados.

**Beneficio**: Detecta proactivamente logros inalcanzables antes de release, similar a como ya se hace con `validar_catalogo()` para estructura.

## Conclusión final

El sistema de logros (M72) está bien diseñado: **data-driven, event-driven, con delegación al evaluador de M71, persistencia robusta con migración y retroactividad, y validación de catálogo**. La arquitectura es limpia (autoload, sin lógica duplicada). 

**Puntos fuertes**: Idempotencia, dependencias entre logros, toasts no bloqueantes, soporte i18n/ocultos/categorías, fechas deterministas, API completa para UI.

**Áreas de mejora críticas**: Varios logros usan stats incorrectos (`regalos_dados` para agricultura/minería, `viajes_realizados` para días jugados), lo que probablemente los hace **no alcanzables**. Además, faltan conexiones para acciones de agricultura/minería. Se recomienda corregir el mapeo de stats y añadir validación de alcanzabilidad para prevenir logros imposibles.
