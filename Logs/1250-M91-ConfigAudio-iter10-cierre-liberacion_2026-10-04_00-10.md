# Log 1250: M91 Configuracion de Audio — iter. 10 cerrada, diseño stale corregido y liberación a 🟡

**Fecha:** 2026-10-04
**Hora:** 00:10
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Iteración 10 de M91 cerrada en la misma sesión de la reserva. El alcance reservado
resultó incorrecto (los 13 ítems de controles son de M53, no de M91) y se corrigió sin
tocarlos. El trabajo real ejecutado fue corregir **diseño stale en `03-Diseno.md`
§16-§18** (diseñaba clases y un archivo JSON inexistentes en el código), cerrar L288
con diseño verificado contra APIs reales, registrar el **BUG-092** de persistencia de
mutes y re-meditar ambas suites de QA. M91 quedó **🟡 Con dudas, 207/239**, liberado
de todos sus registros (los 31 `[ ]` restantes tienen dueño externo/engine y L88 `[?]`
HRTF sigue siendo el techo del módulo).

## Cambios Realizados

- **Alcance corregido (Trampa 119):** L198-L211 + L147 (13 ítems) verificados como de
  M53 (dueño del menú) por `03-Diseno.md` §10 («L147 queda `[ ]` a propósito») y por el
  desglose del lote 9 del backlog. **No tocados.** §7 re-verificado: 0 assets de audio
  en el repo (rg, exit 1) → 10 ítems de sonidos de interfaz siguen sellados. L22/L23
  confirmados como ejecución con hardware real → no inflables.
- **`03-Diseno.md` reescrito (5 ediciones, +106/−91 líneas, LF puro):**
  - §16: reescrito con el guardado real (`AudioConfig._guardar_config()` →
    `DataStore.guardar_config()` → `user://config.cfg` atómico; auto-guardado en cada
    `set_volumen()`; vía doble config vs savegame `"audio_config"`). Antes diseñaba
    `user://settings/audio_settings.json` con `AudioSettings/Loader/Saver` — 0 refs en
    `scripts/`.
  - §17: carga real (`_ready()` → `_crear_buses()` → `_cargar_config()` →
    `_registrar_proveedor_guardado()`).
  - §18: «Guardado de configuración al cerrar — L288» con contrato `al_cerrar_settings()`
    y API propuesta `set_opcion(clave, valor)`.
  - Banners en §2 (menú = spec hacia M53) y §3 (defaults = `AudioConfig.DEFAULTS`;
    `apply_settings()` ≡ `_aplicar_todo()`; entidades nombradas antes no existen).
- **`05-Checklist.md` (CRLF 354/354 preservado, ediciones in-place SIN insertar líneas**
  porque las referencias `L##` del archivo son números de línea):
  - **L288 → `[x]`** con nota de evidencia (diseño en §18; wire-up = M53; `set_opcion()`
    pendiente → BUG-092).
  - Notas inline de corrección en headers L213, L275, L283, L290, L296.
  - L336 alcance CORREGIDO (13 items = M53), L337 progreso 207/31, L338 motivo 🟡.
  - Bloque `## Reserva actual` → liberación 2026-10-04 00:03 (Estado 🟡, Agente —).
- **`11-BUGS.md` → BUG-092** (4673 → 4733 líneas, LF): `set_mute()` no llama
  `_guardar_config()` ni serializa `_mutes` (solo sobreviven al savegame) y
  `DynamicRange/Compression/OutputDevice` no tienen persistencia. Severidad 🟡, estado
  `[ ]` Abierto, con evidencia de líneas y repro. Firmado y ubicado en sección 6.
- **Liberación en los 4 registros de §26 + backlog:**
  - `CHECKLIST-GLOBAL.md` fila 91: 🔵 → 🟡 Con dudas, 207/239, Agente → —, ÚltAct
    2026-10-04 00:03 + nota Log 1250. Invariante verificado tras edición in-place:
    **449 CR / 231 LF / 231 CRLF** + sufijo `\r\r` intacto.
  - `ESTADO-PARALELO.md`: entrada de LIBERACIÓN al tope (CR 3022 / LF +11).
  - Guía 08 fila M91 → 🟡 207/239 (CRLF 1188/1188). ⚠️ Queda en working tree SIN
    commitear: la guía 08 trae diffs ajenos de kimi-k3 (fila M37).
  - Backlog personal: sección M91 → LIBERADA 🟡 (Log 1250) con bloque de cierre.
- **Suites re-meditadas (DoD):** `test_audio_config.gd` **103 checks / 0 fallos** +
  `test_audio_effects_m91.gd` **82 checks / 0 fallos**, ambos EXIT 0 con Godot 4.7.2
  headless (corridas 2026-10-03 23:4x y 2026-10-04 00:0x).
- **Informe de canal:** `Mensajes entre modelos/mimo-v2.6-flash-free/05-2026-10-04_00-05-00-cierre-iter10-m91.md`
  (responde al 04 del director; con desglose de los 31 `[ ]` externos y pregunta por
  BUG-092).

## Archivos Modificados/Creados

- `DOCUMENTACION/91-Configuracion-De-Audio/plan-actual/03-Diseno.md` (editado)
- `DOCUMENTACION/91-Configuracion-De-Audio/plan-actual/05-Checklist.md` (editado)
- `DOCUMENTACION/11-BUGS.md` (editado — BUG-092)
- `CHECKLIST-GLOBAL.md` (editado — fila 91)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (editado — entrada liberación)
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (editado — fila M91, SIN commitear por carrera kimi)
- `DOCUMENTACION/TAREAS-POR-MODELO/mimo-v2.6-flash-free/BACKLOG-MASTER.md` (editado — sección M91)
- `Mensajes entre modelos/mimo-v2.6-flash-free/05-2026-10-04_00-05-00-cierre-iter10-m91.md` (creado)
- `Logs/NUMEROS_DISPONIBLES.txt` (editado — 1250 consumido)
- `Logs/1250-M91-ConfigAudio-iter10-cierre-liberacion_2026-10-04_00-10.md` (este archivo)
