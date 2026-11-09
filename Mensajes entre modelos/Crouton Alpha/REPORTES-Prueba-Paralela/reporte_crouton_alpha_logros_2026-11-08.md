# Reporte — Sistema de Logros (M72) — Isla Ancestral

**Modelo:** Crouton Alpha
**Plataforma:** Kilo Code
**Fecha:** 2026-11-08

## Alcance del análisis

- `game/isla-ancestral/scripts/logros/achievement_service.gd` (622 líneas, autoload `Achievements`)
- `game/isla-ancestral/data/logros/logros.json` (18 logros, schema 2)
- `game/isla-ancestral/scripts/progresion/progression_manager.gd` L702-L750 (evaluador `evaluar_condicion`)
- Tests: `test_logros.gd`, `test_logros_m72_statids.gd`, `test_logros_rf10_m72.gd`, `test_logros_rf13_m72.gd`, `test_logros_rf1_e.gd`, `test_logros_depende_de_m72.gd`, `test_m72_deuda_assets.gd`, `test_m72_rf6_m72.gd`

---

## 1. ¿Cómo se gestionan los logros?

**Modelo data-driven + autoload + delegación del evaluador.** No hay lógica de condiciones propia: `AchievementService` carga el catálogo y delega la evaluación a `ProgressionManager` (M71), que implementa el motor `evaluar_condicion()` con 10 tipos (`stat_min`, `dias_jugados`, `sello_historia`, `capitulo_historia`, `riqueza_acumulada`, `primera_vez`, `hito_previo`, `coleccion_completa`, `nivel_modulo`, `compuesta AND/OR/NOT`). Separación deliberada para no duplicar lógica (`achievement_service.gd` L5-L11).

- **Catálogo:** `logros.json` con `id`, `nombre`/`descripcion` + claves i18n `LOGROS.*`, `icono`, `categoria`, `orden`, `condicion`, `depende_de` opcional y `oculto` opcional. Carga en `_cargar_catalogo()` (L61-L102), con validación al arranque.
- **Bucle de evaluación event-driven, nunca por frame** (`evaluar_todos()` L213-L222): se re-evalúan los logros pendientes cuando llegan eventos de `ProgressionManager` (`progreso_hito_alcanzado`, `progreso_desbloqueado`, L134-L135) y de `EventBus` (`item_added`, `purchase_done`, `gift_given`, `quest_completed`, `friendship_level_up`, L140-L150). Casos especiales: pesca (`_on_captura_pesca` L182-L194 incrementa `peces_capturados` / `pescar_<id>`) y amistad (`_on_nivel_amistad` L201-L209 mantiene `amistad_max_<npc>` monótona).
- **Desbloqueo idempotente** (`desbloquear()` L239-L265): verifica existencia en catálogo, no-duplicación y gate de dependencias (`depende_de`, L242-L246); emite `logro_desbloqueado`, fecha determinista de M29 (cero reloj real), `mark_dirty` write-through, eventos a analytics (M104) y log (M103), y toast no bloqueante bufferizado vía `EventBus.ui.notify` (cola/pool en M53, L280-L315). Los toasts respetan accesibilidad M58 (`_toasts_disabled`, L162-L175).
- **API de consulta completa** (RF10, L357-L436): `get_todos()`, `get_estado()`, `get_desbloqueados()`, `get_en_progreso()`, `porcentaje_real()` (total real, sin anti-spoiler del diario M55), `get_progreso_humano("X de Y")`. Los logros ocultos se muestran como `???` hasta desbloquearse (L397-L401).

## 2. ¿Hay validación de condiciones para desbloquear logros?

**Sí, en dos niveles:**

- **Forma del catálogo (RF14, L439-L579):** `validar_catalogo()` corre al arranque y cuenta problemas accionables: `id` vacío o duplicado (L468-L475), `icono` vacío (L477-L479), `categoria` fuera del vocabulario cerrado de 8 (L481-L485, `CATEGORIAS_VALIDAS` L451-L455), `logro_steam_id` duplicado (L487-L493), condición vacía (L495-L497) y tipo desconocido contra `TIPOS_CONDICION_VALIDOS` (L566-L575). Recurse sobre condiciones `compuesta` (L576-L578). Salida: `[M72][RF14] Catálogo OK: 18 logros, 0 problemas` (L509).
- **Evalución en tiempo real:** tipo desconocido → `false` (evaluador `progression_manager.gd` L749-L750); condición vacía → `false` (L703-L704); dependencias no cumplidas → `false` sin bloquear (L244-L246); `stat_min` exige `stat_id` no vacío. El test `test_logros_m72_statids` valida además que los `stat_id` del catálogo resuelvan contra el registro de stats de M71 (RF14 data-integrity).
- **Additional hardeness (anti-grind / anti-spoiler):** los criterios de diseño (H2) atan los logros a hitos/stats reales y evitan contadores inventados; las categorías `epilogo` deben referenciar hitos reales (`hito_previo`, ej. `logro_ruina_restaurada` L276-L279), no contadores.

**Deuda visible (no defectos de forma):** `iconos_ausentes()` (L520-L530) y `claves_i18n_ausentes()` (L533-L545) miden iconos sin PNG y claves `LOGROS.*` fuera de `locales/es.po`, reportadas en cada arranque como `[M72][DEUDA]` (L506-L507).

## 3. ¿Hay logros que no se pueden conseguir?

**Sí, varios por `stat_id` incorrecto o por integración muerta (datos, no infraestructura):**

| Logro | Líneas `logros.json` | Condición declarada | Problema |
|---|---|---|---|
| `logro_dias_en_aurora` | L252-L266 | `stat_min` sobre `viajes_realizados` umbral 30 | Un logro de días en la isla exige **30 viajes**; el tipo correcto es `dias_jugados` (existe en el evaluador). Prácticamente inalcanzable y semánticamente roto. |
| `logro_primer_cultivo` | L175-L188 | `regalos_dados` ≥ 1 | Regalar 1 vez desbloquea "Manos en la Tierra" sin cultivar nada. |
| `logro_cosecha_diez` | L190-L204 | `regalos_dados` ≥ 10 | Con 10 regalos se "cosecha 10 cultivos". |
| `logro_primer_mineral` | L206-L219 | `regalos_dados` ≥ 1 | Con 1 regalo se desbloquea "Primera Veta" sin minar. |
| `logro_minero_veterano` | L221-L235 | `regalos_dados` ≥ 25 | Con 25 regalos, "Minero Veterano" sin extraer un mineral. |

Los cuatro logros de agricultura/minería reutilizan el stat `regalos_dados` (único stat sin contrapartida sembrada: el grep por `cultivos_cosechados` / `minerales_extraidos` devuelve 0 hits en el cableado; el único contador real es `peces_capturados` con su conector específico en `achievement_service.gd` L186). Resultado: se obtienen **fácil pero sin jugar** a lo que describen (inflación cruzada a la inversa: desbloqueo sin mérito).

Otros riesgos de inalcanzabilidad:

- `logro_coleccionista` (L38-L50) exige `coleccion_completa` sobre `flora`. El evaluador resuelve contra `CollectionRegistry` (`progression_manager.gd` L727-L728), pero la conexión de colecciones en `achievement_service.gd` L155-L158 espera el nodo `/root/coleccionables` (minúscula) y `categoria_completed` (M37). Si el nombre del autoload no coincide en `project.godot`, la señal nunca llega y este logro depende solo de la re-evaluación genérica. Integración frágil, no cableado por `stat` propio.
- **Iconos inexistentes:** los 18 `icono` apuntan a `res://assets/ui/logros/*.png`; verificado con `Test-Path`: `assets/ui/logros` = **False** y `assets/ui` = **False**. El logro se desbloquea (el dato pasa), pero la UI no tiene qué mostrar. El propio servicio lo auto-reporta como `[M72][DEUDA]` en cada boot (L506-L507).
- **i18n sin consumo:** las 36 claves `LOGROS.*` no están en ningún `.po` y no hay `tr()` en el servicio: la UI muestra el literal español (falso i18n decorativo).
- Logros con cadena dura que heredan riesgo: `logro_siete_sellos` (L20-L36) depende de `logro_primer_sello` y 7 sellos reales; `logro_ruina_restaurada` (L268-L283, categoría `epilogo`) depende de `logro_siete_sellos` + hito `hito_ruina_restaurada` (M75). Correctos por diseño, pero el último eslabón es endgame puro.

El resto del catálogo es consistente: `logro_primer_sello` ↔ `sello_historia/sello_ceniza_sala1` (L13-L16), `logro_vecino` ↔ `regalos_dados` (L76-L80), `logro_misionero` ↔ `misiones_completadas` (L92-L95), `logro_secreto_guardian` oculto ↔ `hito_sello_ceniza_sala1` (L107-L110), pesca y amistad con stats reales y conectores dedicados.

## 4. ¿Hay persistencia de logros desbloqueados?

**Sí, completa y versionada (M59, sección `achievements`):**

- `get_section_name()` → `"achievements"` (L584-L585); `VERSION_ESTADO = 2` (L34).
- `get_save_data()` (L588-L594) serializa `{version, desbloqueados: {id: {dia, hora}}}` solo con JSON-safe (`String/int`); fecha determinista del calendario Aurora M29, cero reloj real (L268-L277).
- `restore_save_data()` (L597-L622) **migra v1** (lista sin fechas → fecha `-1`, L601-L609) y **v2** (dict con fechas, L610-L619); ignora IDs de catálogos viejos con aviso, y **nunca re-emite señales** de restaurados (L620). Tras cargar, `re_evaluar_todo()` (L227-L233, RF5) otorga retroactivamente los logros cuya condición ya estaba cumplida, con la fecha de carga.
- **Write-through:** `SaveManager.mark_dirty()` tras cada desbloqueo (L253-L255); la escritura la agrupa M59.

## 5. Dos mejoras sugeridas

### Mejora 1 — Corregir los `stat_id` erróneos y cablear stats reales de cultivo/minería/días

Reemplazar en `logros.json` los 5 logros afectados por stats reales y, donde no existen, crear los conectores hoy ausentes:
- `logro_dias_en_aurora`: `tipo: dias_jugados, umbral: 30` (el evaluador ya lo soporta, `progression_manager.gd` L711-L714).
- `logro_primer_cultivo` / `logro_cosecha_diez`: nuevos `stat_min` `cultivos_cosechados` (1 / 10), conectados en `progression_manager.gd` a la señal/base de cosecha de granja (M33).
- `logro_primer_mineral` / `logro_minero_veterano`: nuevos `stat_min` `minerales_extraidos` (1 / 25), conectados a la señal de extracción de minería (M35).
- Añadir validación RF14 que rechace `regalos_dados` fuera del dominio amistad (el `test_logros_m72_statids` ya cubre el vocabulario de stats: extenderlo con una regla dominio↔categoría). Esto cierra el inflado cruzado y vuelve alcanzables los 5 logros con mérito real.

### Mejora 2 — Cerrar la deuda de presentación e integración (iconos, i18n y nodo de colecciones)

Tres frentes pequeños pero visibles:
- Generar o mover los 18 PNG a `res://assets/ui/logros/` (hoy la carpeta no existe). `iconos_ausentes()` (L520-L530) ya mide la deuda en cada arranque: el objetivo es que `[M72][DEUDA]` dé 0.
- Agregar las 36 claves `LOGROS.*` a `locales/es.po`/`en.po` **y** cablear el `tr()` en el consumidor de UI (hoy `grep 'tr('` en el servicio = 0: sin el `tr()`, las claves quedan decorativas).
- Alinear el nombre del nodo de colecciones esperado en `achievement_service.gd` L156 (`/root/coleccionables`) con el autoload real en `project.godot` (o resolver vía `CollectionRegistry` ya usado por el evaluador en `progression_manager.gd` L727). Eso asegura que `logro_coleccionista` se desbloquee sin depender de que el jugador provoque otro evento.

---

## Conclusión final

El sistema está **bien arquitectado y probado**: catálogo data-driven, evaluador compartido con M71, desbloqueo idempotente con dependencias, señales y toasts correctos, validación RF14 con errores accionables, persistencia versionada con migración y retroactividad, y suites de tests con guardián anti-falso-verde. El módulo quedó sellado en 200/200 (§21.8, 6 sellos vigentes).

El problema real está **en los datos, no en el motor**: 5 de 18 logros referencian `stat_id` equivocados (`regalos_dados` para cultivo/minería y `viajes_realizados` para días) y 18 íconos + 36 claves i18n apuntan a ubicaciones inexistentes. Esos 5 logros hoy se desbloquean sin jugar a lo descrito (o exigen 30 viajes para un logro de días) y la presentación de los 18 depende de deuda externa. La infraestructura aguanta; con las dos mejoras (stats correctos + cierre de deuda de presentación/integración) el catálogo queda limpio sin tocar una línea del diseño.
