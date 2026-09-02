**Modelo:** glm-5.3 (último modificador; iter. 2)
**Plataforma:** Cline

# 04-Codigo.md — Módulo 30: Reloj en Tiempo Real

## 1. Archivos involucrados

### Scripts
| Archivo | Propósito | Estado |
|---|---|---|
| `scripts/clock/w_reloj.gd` | Widget HUD de reloj (lee GameClock M29). Iter. 2: hover D70 vía TooltipService por rect (sin capturar el mouse, D78 intacto) + config data-driven + formato 12h/24h | ✅ Implementado |
| `scripts/clock/reloj_hud.gd` | HUD Reloj — capa de DISPLAY + POLÍTICA. Consumidor de GameClock (M29). Traduce estado interno a strings para Label. Formato 12h/24h, sesión del día (MAÑANA/DÍA/TARDE/NOCHE), helpers de estilo visual para UI | ✅ Implementado |
| `scripts/clock/w_reloj_config.gd` | `WRelojConfig` (Resource): usar_formato_12h, margen_borde, ancho_min, mostrar_chip_estacion, color_fondo. Defaults = comportamiento previo | ✅ Implementado (iter. 2) |
| `scripts/clock/caso_reloj.gd` | Escenario del test: fondo neutro + WReloj en CanvasLayer layer 0 (bajo el TooltipService, que es layer 1) | ✅ Implementado (iter. 2) |
| `scripts/clock/caso_reloj_tests.gd` | Suite headless del bloque E: 10 casos de límites + widget en escena (E93) + hover D70 + config F100/F107 + formato F101 + scan anti-reloj-SO (C56/E89/E90). **29 checks, 0 fallos** | ✅ Implementado (iter. 2) |
| `scripts/clock/preview_reloj.gd` | Preview visual (V2). Iter. 2: 3.ª captura con tooltip del hover forzado (`demo_cursor_dentro`) | ✅ Actualizado (iter. 2) |

### Escenas y datos
| Archivo | Propósito |
|---|---|
| `res://data/ui/w_reloj.tres` | Config del widget (WRelojConfig): formato 24h, margen 16, ancho 230, chip on, color de fondo |
| `res://scenes/caso_reloj.tscn` | Escenario del test E93 (raíz Node + `caso_reloj.gd`) |
| `res://scenes/preview_reloj.tscn` | Preview visual del widget (iter. 1) |
| `scripts/clock/Obsoletos/2026-08-31_23-05-00_w_reloj.gd` | Backup §5 del `w_reloj.gd` previo a la iter. 2 |

> Nota iter. 2: `res://ui/hud/w_reloj.tscn` y `res://ui/hud/hud.gd` del diseño original no existen como tales; el widget se monta directamente en el CanvasLayer "UI" de `main_island.tscn` (nodo `RelojWidget`) y el HUD formal de M53 (`hud.tscn`) quedó huérfano tras el Log 291.

## 2. Contrato de datos (API consumida de M29)

| Método/señal | Uso en M30 |
|---|---|
| `GameClock.get_hora()` | Hora HH:MM para el widget |
| `GameClock.get_fecha()` | Fecha (día, mes, estación, año) |
| `GameClock.get_estacion()` | Ícono y color del widget |
| `EventBus.time.hora_cambio(hora)` | Actualizar label HH:MM (sin polling) |
| `EventBus.time.dia_cambio(DiaInfo)` | Actualizar fecha + aviso de eventos del día |
| `EventBus.time.estacion_cambio(estacion)` | Cambiar ícono/color + aviso UI |
| `EventBus.time.evento_activado(EventoPeriodico)` | Badge de evento en el reloj |
| `GameState.M29` | Lectura de fecha/hora persistida al cargar |

> **Corrección iter. 2 (glm-5.3/Cline):** la API REAL de M29 expone **señales propias de GameClock** (`minuto_cambio/hora_cambio/dia_cambio/estacion_cambio/evento_activado`) + dominio `EventBus.calendar` (`day_started/season_changed`). `EventBus.time` solo expone `fase_cambio` (M31). El widget consume las señales de GameClock directamente (patrón cacheado documentado en 07 §10). Consumidores futuros (M74/M28/M36): usar esta API real, no la de la tabla original de arriba.

## 3. Regla de oro (anti-exploit, se documenta y se testea)

> **Ningún sistema de gameplay lee el reloj del sistema operativo.** La única fuente de tiempo es `GameClock` (interna, determinista, inmune a `Time.get_unix_time_from_system()`).

- El widget solo ESCRIBE (display), nunca produce tiempo.
- Adelantar/retroceder el reloj del SO no produce ninguna ventaja (0 código depende de él).
- El mundo se congela offline (M29): no hay tiempo real parcial ni castigos por ausencia (pilar anti-FOMO).

## 4. Pendientes (estado iter. 2 — glm-5.3/Cline)

| Pendiente | Nota |
|---|---|
| ~~Implementar `w_reloj.gd`~~ | ✅ Iter. 1 (GLM/Cline) + iter. 2 (hover D70 / config / formato) |
| ~~Implementar `caso_reloj_tests.gd`~~ | ✅ Iter. 2: 29 checks, 0 fallos (incluye la tabla §5) |
| ~~Conectar con HUD principal (M53)~~ | ✅ Montado en `main_island.tscn` (CanvasLayer UI); hover usa TooltipService (M53) |
| ~~Test estático anti-reloj-SO~~ | ✅ Iter. 2: scan integrado en la suite (240 archivos, 0 usos en gameplay) |
| Badge de evento (D74) | Requiere diseño M64; la señal `evento_activado` ya dispara (caso 6 del test) |
| Localización (M57) | Nombres desde claves .po — dueño M57 |
| Ícono de estación (D67 `[?]`) | Requiere assets M45/M46 |

## 5. Tabla de pruebas de límites (para M112)

| # | Caso | Entrada | Esperado |
|---|---|---|---|
| 1 | Tick normal | 1 s real | +1 min de juego, HH:MM actualiza |
| 2 | Fin de día | 23:59 → 00:00 | `dia_cambio`, fecha avanza |
| 3 | Fin de mes | día 28 → mes+1 día 1 | `mes_cambio`, sin error |
| 4 | Fin de año | día 336 → año+1 | año avanza, sin overflow |
| 5 | Cambio de estación | último día Verano | `estacion_cambio` + aviso |
| 6 | Cumpleaños | fecha exacta vecino | `evento_activado` |
| 7 | Persistencia | guardar 14:32 → cargar | 14:32 exacto |
| 8 | Retroceder SO | `Set-SystemTime -1d` | sin efecto en juego |
| 9 | Adelantar SO | `Set-SystemTime +1mes` | sin efecto en juego |
| 10 | Ausencia | 7 días reales sin jugar | estado congelado al volver |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 07:20:00
**Estado:** Parcial (documentación de diseño completa; implementación delegada)

### Lo que hice
- Resolví los 20 puntos de la sección 29 del plan maestro (todos en 02-Analisis.md).
- Documenté la política anti-exploit completa (regla de oro + 4 reglas operativas).
- Diseñé el widget de reloj y la tabla de 10 pruebas de límites de fecha.

### Lo que NO hice (honestidad obligatoria)
- Implementar código: el módulo es intencionalmente **delegable** (depende de M29 implementado). Dueño: AGENTE DELEGADO → hito M1/prototipo.

### Recomendaciones para el próximo agente
- Implementar después de que GameClock (M29) exista; el contrato de API está fijado arriba.
- El test 8/9 (reloj del SO) es barato de automatizar en M112 (Windows: `Set-SystemTime`).
- No agregar ningún uso real del tiempo del SO sin pasar por decisión del GDD (pilar anti-FOMO).

---

## Notas del Agente (iteración 2)

**Modelo:** glm-5.3-flash (campo, visión) + glm-5.3 (cierre/auditoría)
**Plataforma:** Cline
**Fecha:** 2026-09-01 00:55
**Estado:** Parcial — núcleo cerrado (98/104); 5 `[ ]` con dueño externo + 1 `[?]`

### Lo que hice
- D70 hover/desplegable: tooltip vía TooltipService (M53), detección por rect SIN capturar el mouse (D78 intacto), formato M88 con fecha/sesión/estación/próximos eventos. Captura oficial: `cap_30_2026-08-31_23-30-00_02_hover.png`.
- F100/F107/F101: `w_reloj_config.gd` (WRelojConfig) + `data/ui/w_reloj.tres` + fallback a defaults + formato 12h/24h vía `RelojHud.formatear_hora` estático.
- Bloque E completo: `caso_reloj_tests.gd` (29 checks, 0 fallos; incluye scan anti-reloj-SO de 240 archivos) + escenario `caso_reloj.tscn`.
- Backup §5 del w_reloj.gd previo (`Obsoletos/2026-08-31_23-05-00_w_reloj.gd`).
- Contrato §2 corregido a la API real de M29 (señales de GameClock + EventBus.calendar).
- ⚠️ Hallazgo cross-module reportado (dueño M53/M88): la fuente del theme global está ausente (`FreeType: Error loading font: ''`) y TODOS los Labels del juego renderizan sin texto (comparar captura iter. 1 del 26/08 vs iter. 2). El tooltip del hover se ve porque TooltipService no usa el theme. Documentado también en 07-GUIA-GODOT §8.

### Recomendaciones para el próximo agente
- Fix URGENTE en M53/M88: fuente del theme global (fallback condicional o instalar Nunito/Fredoka One).
- D74: conectar badge a `TimeCalendar.evento_activado` cuando M64 defina el diseño.
- Seams de test (`config_inyectada`, `ruta_config`, `demo_cursor_dentro`): no usarlos en gameplay.

---

## Notas del Agente — Iteración 3 localización (historial, no borra las anteriores)

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 23:00:00
**Estado:** Parcial (nombres de estación localizables implementados y verificados; módulo liberado 🟡 — cierra el [?] ítem 108)

### Lo que hice
- w_reloj.gd `_estacion_nombre(est)`: ahora consulta Localization (M87) con claves `CLOCK.ESTACIONES.0..3` (tr_key, fallback al hardcode del núcleo si Localization no existe o la clave falta — headless seguro).
- Catálogos .po ampliados: CLOCK.ESTACIONES.0-3 en es.po (Primavera/Verano/Otoño/Invierno) y en.po (Spring/Summer/Autumn/Winter).
- Test test_reloj_localizacion.gd: es/en/retorno a es → **0 fallos**.

### Hallazgo documentado (para 07-GUIA-GODOT en próxima pasada de guía)
- Nodos instanciados con `new()` SIN agregar al árbol: `get_node_or_null("/root/X")` devuelve null (no hay ruta absoluta fuera del árbol). El test del widget tenía que hacer `root.add_child(widget)` antes de llamar métodos que consultan autoloads. (Pitfall conocido §9.51 — confirmado en el caso widget+Localization.)

### Lo que NO pude hacer (honestidad obligatoria)
- Badge de evento activo (M74 evento_activado → icono en el reloj): UI V2 con dueño.
- Consumidores M74/M36: M28 (mío) consume GameTime directamente, no el reloj HUD; advertidos vía 04-Codigo.
- El resto de pendientes de la fila global: con dueño (M74/M36/UI).

### Recomendaciones para el próximo agente
- M53: el tooltip del reloj usa _texto_tooltip() → estación traducida automáticamente vía _estacion_nombre.
- M87: cualquier widget nuevo con textos del reloj debe usar las mismas claves CLOCK.ESTACIONES.*.
