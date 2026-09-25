# Log 1150: P-36 / M122 — 10 helpers offline, 80 pendientes cerrados y 2 falsos verdes

**Fecha:** 2026-09-25
**Hora:** 01:30
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Reserva:** **1150**, tomado del pool tras medir `--estado` (ver Log 1149). El pool ya arrancaba en
**1154** al cerrar (1151–1153 los consumieron hy3/agnes concurrentemente).

## Resumen

M122 figuraba en **185/265** con **80 `[ ]`** — la deuda más grande del paquete. Se cerró completa:
**`[x]=254 · [?]=11 · [ ]=0` (265)**. El módulo tenía **dos falsos verdes** que nadie había medido.

1. **Test headless en ROJO declarado verde.** `test_crash_m122.gd` daba **12 checks, 2 fallos**; la
   «Evidencia» del checklist afirmaba `=== TEST M122: 12 checks, 0 fallos === (Log 518)`. Causa: un
   **bug real** en `crash_reporter.dumps_pendientes()` — usaba `DirAccess.open("user://…")`, que
   devuelve **`null` en headless** (pitfall §9.6, **la misma trampa que en M106**), así que devolvía
   `[]` **aunque los dumps SÍ estaban en disco**. Corregido con `_abrir_dir()` tolerante y orden
   estable -> **13/0**.
2. **Totales inventados.** `## Totales` decía «Total de ítems: **335** · resueltos: **335** ·
   pendientes: **0**». Hay **265** marcadores y había **80 `[ ]`**. Ninguno de los dos números era
   medido. Reescrito con la regla de marcado explícita.
3. **10 helpers offline implementados** (los servicios del diseño que sólo existían como esqueleto)
   + 2 suites, **181 checks, 0 fallos**.
4. **Defectos del diseño corregidos** (no cosmética): variable `crash` **no declarada** en
   `_format_issue_body`; `OS.get_dynamic_memory_usage()` **no existe** en Godot 4.7 (SCRIPT ERROR de
   parseo medido); `debug_menu.add_panel()` — **API que M110 no expone**; sanitización **superficial**
   que dejaba pasar PII anidada; `pop_front()` único en la caché.

## Cambios Realizados — commit `00e870b` (17 archivos, +1887/−111)

### Los 10 helpers (todos `RefCounted` sin `class_name`, preload, cabecera firmada)

| Archivo | API principal |
|---|---|
| `crash_metadata.gd` | `recolectar_hardware`, `recolectar_software(escena)`, `recolectar_contexto_juego(datos)`, `recolectar_todo` |
| `crash_context_sanitizer.gd` | `CLAVES_INSEGURAS` (9), `sanitizar` (**recursivo**), `es_clave_insegura`, `claves_removidas`, `es_contexto_seguro` |
| `crash_cache.gd` | `MAX_CACHE_SIZE` (10), `guardar`, `cargar`, `limpiar`, `cantidad`, `archivo_existe` |
| `crash_sender.gd` | `configurar(url, clave, transporte)`, `construir_headers/cuerpo`, `enviar`, `enviar_cache`, `comprimir`/`descomprimir` (GZIP) |
| `crash_logging.gd` | `NIVEL`, `CATEGORIA_CRASH` (6), `formatear_entradas`, `registrar(datos, logger)` |
| `crash_bug_tracking.gd` | `debe_crear_issue`, `formatear_titulo`, `formatear_cuerpo`, `crear_issue` |
| `crash_debug_menu.gd` | `describir_panel`, `formatear_metadata`, `accion_test_crash`, `accion_enviar_pendientes` |
| `crash_alerts.gd` | `UMBRAL_CRITICO` (5 %), `UMBRAL_NUEVA` (1 %), `evaluar`, `formatear_alerta`, `construir_payload`, `enviar_todas` |
| `crash_analytics.gd` | `huella_stack`, `normalizar_stack`, `agrupar`, `frecuencias`, `top`, `nuevas` |
| `crash_prioritizer.gd` | `prioridad` (matriz §13), `prioridad_de`, `filtrar`, `ordenar`, `ORDEN` |

### Hashing del stack trace (ítem «Diseñar algoritmo de hashing de stack trace»)

`huella_stack()` **normaliza antes de hashear**: quita tokens `0x…`, quita el sufijo `:NNN`, descarta
líneas vacías. Así el mismo bug **agrupa entre builds** aunque cambien direcciones y números de línea
(probado con un test explícito). Hash: `String.sha256_text()` del motor, **sin criptografía propia**.

### Patrón de diseño clave: transporte inyectado

Los helpers que en el diseño hacían `HTTPRequest.new()` (CrashSender, CrashBugTracking, CrashAlerts)
ahora reciben un **`Callable`**. Sin transporte son **fail-closed** (`false`/`0`) — y eso **se asertó**.
Es lo que hace testeable el módulo **sin red** y sin acoplarlo al árbol de nodos.

## Verificación

| Suite | checks | fallos | `SCRIPT ERROR` | exit |
|---|---|---|---|---|
| `test_crash_m122.gd` (autoload) | 13 | 0 | 0 | 0 |
| `test_crash_m122_offline.gd` (10 bloques A–J) | 168 | 0 | 0 | 0 |
| **Total** | **181** | **0** | **0** | **0** |

**×3 corridas consecutivas** (godot 4.7.2 headless). Desglose medido: A=15, B=20, C=11, D=20, E=13,
F=16, G=13, H=19, I=18, J=23 -> **168**. Pisos `CHECKS_MINIMOS` = **13** y **168**, medidos en verde.

**Guardián probado EN ROJO por inyección** (aborto de tipos al inicio del bloque I):

```
[FAIL] bloques que NO se ejecutaron: ["I"]
[FAIL] checks ejecutados (146) por debajo del piso (168)
TEST M122-OFFLINE FALLIDO — salida con código 1
```

Detalle fino: el bloque **J sí corrió** (146 = 168 − 18) — el aborto mata sólo la función donde
ocurre, y aun así el guardián lo detecta por las dos vías (bloque faltante **y** piso).

## Drift diseño ↔ código (patrón M167): REPORTADO, NO REESCRITO

El diseño propone **9 archivos en 4 directorios** (`scripts/services/`, `scripts/ui/`,
`scripts/integrations/`, `scripts/alerts/`) con `class_name`; el repo tiene **1 autoload en
`scripts/crash/`** sin `class_name` y con otra API.

**Decisión tomada (y su límite):** implementé los 10 helpers en **`scripts/crash/`** — donde vive el
módulo y donde apunta el autoload — y **documenté cada divergencia en `04-Codigo.md` §15**. **No
reescribí el diseño ni creé directorios nuevos.** Motivos: (a) la regla del proyecto §9.17/§9.41
**prohíbe** `class_name` en autoloads, o sea el diseño es el que está mal; (b) la adaptación del
autoload ya estaba documentada por el agente anterior (deepseek-v4-flash, 2026-09-01); (c) crear una
segunda estructura de directorios habría duplicado el módulo.

**Lo que NO hice y por qué:** no toqué `project.godot` para aplicar la sección `crash_reporting/*` de
§11 (archivo compartido, y P-32 acaba de sanear su BOM). Queda declarado como hueco con dueño
**M117/coordinador**.

## Pendientes con dueño (11 `[?]`)

Export presets de debug/símbolos (**M117**) · profiling e impacto en FPS (**M61**) · opt-out en
settings y su test (**M90**) · tests manuales (**M114**) · GDPR ×2 (**COORDINADOR**) · envío real a
Crashlytics/Sentry y dashboard (**M104/M118**) · integración completa M103/M102/M110
(**M103/M102/M110**). **No** se marcan `[x]` sin implementar.

## Honestidad

- La **matriz de prioridad del diseño (§13) no cubre** «Media (1–5 %) + Algunos» ni «Baja (<1 %) +
  Todos»: se **interpolaron** (MEDIA en ambos casos) y el test **fija** esa decisión para que un
  cambio futuro sea visible.
- La frecuencia es **relativa a la muestra local**; el % real de usuarios necesita backend.
- El panel de M110 se prueba **como datos**: su API real no existe todavía.
- Los dumps de `test_crash_m122.gd` **no se limpian** a propósito: `user://crash/` es el directorio
  real del módulo y sirve de evidencia de que la captura funciona.
