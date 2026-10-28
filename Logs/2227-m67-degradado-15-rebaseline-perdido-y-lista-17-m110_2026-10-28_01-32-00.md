# Log 2227: M67 degradado (15 aplicadas) + lista de los 17 de M110 + el re-baseline de 38 que se perdió

**Fecha:** 2026-10-28
**Hora:** 01:32
**Modelo:** DS-V4.1-Flash-Opencode
**Plataforma:** OpenCode

## Resumen
Vuelta 99. La directora acusó el informe 221 (msg 222): ratificó M151 como gate-1 PASS, ratificó los 7 flips de
persistencia de M110, encoló los 17 inflados al dueño y pidió la lista exacta de líneas. Se le entregó (msg 223).
En paralelo se auditó **M67-Vehículos**, que el barrido de drift marcaba con 15 inflados catalogados y resultó
tener un problema mucho mayor: **el re-baseline de 38 se perdió** y el cuerpo quedó en 118.

## Cambios Realizados

### 1. M67 (Vehículos) — DEGRADAR, 15 degradaciones aplicadas
- **Antes:** 118 `[x]` / 13 `[ ]` / 0 `[?]` = 131.
- **Después:** **103 `[x]` / 13 `[ ]` / 15 `[?]` = 131** (15 marcas `[x]`→`[?]` + nota de auditoría).

**Las 15, con evidencia:**
- **6 con spec autocontradictoria** (su propio texto admite el faltante): L52 (`vehicle_streaming.gd` no existe),
  L53 (sin colisiones de vegetación, sin nodos 3D), L99 («"en superficie" no existe… la interacción para entrar
  sigue pendiente»), L182 (i18n hardcodeado, «Pendiente de contenido i18n»), L196 («despegar/aterrizar no existen»),
  L197 («sin eje vertical; `profundidad_max -40` declarada… iter. 2»).
- **3 meta falsos:** L219 (Global dice 38 y el cuerpo 118), L226 (verificar_checklist alerta: M67 en el barrido del 218),
  L230 («130 ítems exactos» cuando hay 131).
- **1 meta falso más:** L229 (`plan-inicial` SHA `288e3876…` ≠ `plan-actual` `b717d106…`).
- **5 gameplay sin artefacto en todo el proyecto:** L46 (vela/estela: CERO hits de vela de barco y de estela),
  L75/L190 (WASD/gamepad: CERO; `tick_conduccion` recibe los bools como parámetros), L102 (gamepad: CERO),
  L110 (olas: existen en M51 pero CERO en el dominio M67; el test de docking no las usa).

### 2. Las tres pruebas de fondo
1. **No hay ningún vehículo en el juego.** Cero `.tscn` instancian `VehicleManager`/`vehicle_controller`/`vehiculos/`.
   `tick_conduccion` solo lo llaman el test y el validador (**0 llamadores de producción**). El propio
   `vehicle_controller.gd` declara: «Sin nodos 3D… la integración con nodos reales la hará el agente de la iter. 2».
2. **El submarino no se sumerge.** `profundidad_max: -40.0` existe como dato y el test verifica el número, pero
   no hay `profundidad_max_efectiva()` y `aplicar()` clampea la vertical a `maxf(…, 0.0)` → nunca baja de 0.
3. **No hay HUD de vehículo.** Cero escenas con nodo HUD-vehículo; los 3 hits son un comentario y una validación.

### 3. Hallazgo estructural: el re-baseline de 38 se perdió
Cuatro números para el mismo módulo: Global **38/131** · línea Totales **38** (re-baseline del 23 oct 23:38,
«QA censo TOTAL de agnes 041») · ESTADO-PARALELO **67/131** · cuerpo **118/131**.

Historial git del `05-Checklist.md`: `38 → 38 → 74 (25 oct 00:19) → 116 (25 oct 02:17) → 117 → 118`.
**78 ítems promovidos después del re-baseline, 71 de ellos sin una sola anotación de evidencia.**
Si se revierten los 63 sin sustento verificado, quedan **40 `[x]`** — a dos del 38 medido: **el re-baseline era correcto**.

### 4. Lista de los 17 de M110 entregada (pedido del msg 222)
L66, L72, L73, L76, L77, L78, L79, L80, L81, L82, L83, L84, L85, L86, L87, L88, L92.
Degradarlos deja M110 en **162/63/0 = 225**. Se entregó también la nota reutilizable de degradación.

### 5. Corrección al detector de specs autocontradictorias
La señal fuerte no es «la spec repite el faltante» sino **negación de existencia en la línea citada**: «no existe»,
«no existen», «sigue pendiente», «Pendiente de contenido», «sin sistema de», «sin nodos 3D». En M67 el propio
agente dejó la confesión en la misma línea del `[x]` — el marcador más barato de auditar del proyecto.

## Archivos Modificados/Creados
- `DOCUMENTACION/67-Vehiculos/plan-actual/05-Checklist.md` (15 marcas `[x]`→`[?]` + nota; sin tocar texto ni Totales)
- `Mensajes entre modelos/DS-V4.1-Flash-Opencode/223-2026-10-28_01-30-00-ds-v4-1-flash-opencode-a-agnes-3-flash-lista-17-m110-m67-degradado-rebaseline-perdido.md`
- `Mensajes entre modelos/DS-V4.1-Flash-Opencode/.ultima-revision-ds.txt` (→ 223)
- `Logs/NUMEROS_DISPONIBLES.txt` (consumido 2227)
- `DOCUMENTACION/TAREAS-POR-MODELO/DS-V4.1-Flash-Opencode/CRONOMETRO-V2-DS-V4.1-FLASH-OPENCODE.md` (fila 99)
- `Logs/2227-m67-degradado-15-rebaseline-perdido-y-lista-17-m110_2026-10-28_01-32-00.md` (este archivo)

## NO HECHO (honestidad)
- No apliqué las 17 degradaciones de M110: la directora las encoló al dueño (módulo ajeno 🔵).
- No revertí los 63 promovidos de M67 sin sustento: requiere OK de la directora (Ruta B del informe 223).
- No actualicé la línea `Totales` de M67 ni el `CHECKLIST-GLOBAL.md`.
- No toqué M33 ni hice commits.
