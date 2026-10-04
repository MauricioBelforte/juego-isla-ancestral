# Log 1291 - T-D5: M120-DLC (auditoria contra disco + versionado + compatibilidad de saves)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-04 20:44
**Tarea:** T-D5 (M120-DLC), asignada por el director (atria-Dawn-Preview / Kilo Code, mensaje 24)
**Resuelve:** parte tecnica de M120 (versionado + compatibilidad de saves entre DLC) + auditoria contra disco
**Log reservado:** 1291 (protocolo v3, `scripts/reservar_log.py --reservar`; --estado justo antes: primero=1291)
**NO sella sec.21.8** (autor del fix tecnico = yo; la verificacion cruzada no me corresponde)

---

## 1. Contexto (encargo del director, mensaje 24)

El director asigno T-D5 (M120-DLC) con una advertencia: M120 esta entre los 44 modulos con
drift de estado (tiene 163 [x] pero el GLOBAL lo pinta VERDE y con progreso bajo). Mismo patron
que M03. Instruccion literal: "Empeza por una auditoria contra disco (como hiciste en M03)
antes de aceptar el conteo del GLOBAL - probablemente el 6/222 sea otro falso cero y tu primer
trabajo sea sincronizarlo."

Y la definicion de la tarea: "**Parte tecnica**: compatibilidad de saves entre DLC + versionado
(lo 'design-heavy' queda [?] con dueno)".

Regla nueva del director: avisar ANTES de tocar un modulo fuera de mis restricciones. M120 ES
mi tarea asignada, asi que la edicion de `dlc_manager.gd` entra en el encargo (se reporta igual).

---

## 2. Auditoria contra disco (metodo M03)

### 2.1 Conteo de marcas (MEDIDO, no heredado)

- Checklist `05-Checklist.md`: **163 [x] / 59 [ ] / 0 [?] = 222**.
- Fila 120 del GLOBAL: `VERDE Disponible | 163/222`.
- `verificar_checklist.py` sobre M120: **el progreso declarado COINCIDE con el real**
  (163/222). La unica alerta es de ESTADO:

  > X Inconsistencia en 120-DLC-Y-Expansiones: tiene 163 items [x] pero su estado global
  > es 'VERDE Disponible'.

**Conclusion clave: NO hay "6/222".** El numero del GLOBAL (163/222) ya esta sincronizado con
el conteo real de marcas. El "falso cero" que el director sospechaba NO existe en este modulo.
Lo que SI existe es el drift de ESTADO: VERDE (Disponible) con 163 [x] marcados -> corresponde AMARILLO.

### 2.2 Huella tecnica real en disco

Existe:
- `game/isla-ancestral/scripts/dlc/dlc_manager.gd` (autoload M120, `project.godot:118`).
- `game/isla-ancestral/data/dlc/dlc_manifest.json` (2 DLC: `isla_hielo`, `pack_aurora`).
- `game/isla-ancestral/data/dlc/bundles.json` (1 bundle: `bundle_deluxe`, descuento 0.15).
- `game/isla-ancestral/scripts/dlc/sincronizar_dlc.gd` (helper).
- `game/isla-ancestral/scripts/dlc/test_dlc_m120.gd` (test legacy, 16 checks).
- `game/isla-ancestral/tests/unit/dlc/test_dlc_manager.gd` (test NUEVO T-D5, 39 checks).

Disenado en `04-Codigo.md` sec.2/sec.5-7 pero **NO implementado** (no existe el archivo):
- `dlc_compatibility_checker.gd`
- `dlc_uninstaller.gd`
- `dlc_bundle_manager.gd`

Sus funciones estan parcialmente absorbidas en `DlcManager` (`es_compatible`/`version_base_actual`;
`bundle`/`bundles_que_contienen`) o pendientes (desinstalacion real, calculo de descuento).
`04-Codigo.md` sec.9 los lista como "IMPLEMENTACION INMEDIATA" (pendientes con dueno).

### 2.3 Son sobre-marcas los 163 [x]?

**NO.** El checklist de M120 es un checklist de **diseno** (cabecera "Modelo: SWE-1.6 /
Plataforma: DEVIN"). La practica totalidad de los items son "Disenar X" / "Definir X" (diseno
documentado en `04-Codigo.md`, que es extenso y real). Los pocos items tecnicos ([M]/[S]) tienen
respaldo: `DlcManager` existe, los JSON existen, los tests existen. Los items que nombran los 3
servicios ausentes dicen "**Disenar** res://dlc/...gd" (diseno -> [x] legitimo); su IMPLEMENTACION
figura aparte como pendiente. Comparado con M100/M129 (donde los [x] afirmaban IMPLEMENTACION
inexistente), aqui NO hay sobre-marcas que revertir.

### 2.4 Dos [x] tecnicos que NO estaban respaldados ANTES (los respalda mi fix)

- "[x] Verificar compatibilidad con version base [M]" -> `es_compatible` existia pero comparaba
  versiones como strings (roto, ver sec.3). Ahora respaldado.
- "[x] Activar/desactivar DLC con persistencia [M]" -> `activar/desactivar` existian pero la
  persistencia NO. Ahora respaldado (ISaveProvider).

---

## 3. Aporte tecnico T-D5 (BUG-102)

### Defecto 1: versionado lexicografico

`es_compatible(id, version_base)` hacia `return version_base >= d.version_requerida`.
Comparar strings NO es comparar versiones: `"1.10.0" >= "1.9.0"` = **false**. Un DLC que exige
la base >= 1.9.0 se reportaba INCOMPATIBLE con la base 1.10.0.

**Fix:** `comparar_versiones(a, b) -> int` **semantica** (por segmentos ".") + `_parsear_version()`
(tolera "1.2" == "1.2.0" y sufijos "1.0.0-beta"). `version_base_actual()` lee
`application/config/version` de ProjectSettings.

### Defecto 2: DLCs activos no persistidos

`activar(id)` solo mutaba `_activos` en memoria; `DlcManager` NO era ISaveProvider (M59) -> la
lista de DLCs activos se perdia en cada guardado/carga.

**Fix:** `DlcManager` implementa ISaveProvider (seccion `"dlc"`):
- `get_section_name()` -> `"dlc"`
- `get_save_data()` -> `{ "activos": [...], "version_base": <version actual> }`
- `restore_save_data(data)`: activa los DLC instalados; los que el save referencia pero NO
  estan instalados NO se activan a ciegas -> van a `_faltantes` (via `dlcs_faltantes()`).
- `version_guardada()` / `save_de_version_superior()` (deteccion de downgrade).
- Registro defensivo: `SaveManager.register_provider(self)` solo si el autoload existe.

---

## 4. Medidas (antes de escribir la cifra)

- Comparacion de versiones: antes (string `>=`) `"1.10.0" >= "1.9.0"` = **false**;
  ahora `comparar_versiones("1.10.0","1.9.0")` = **1** (mayor). Correcto.
- Roundtrip save: activar `isla_hielo` + `pack_aurora` -> `get_save_data()` ->
  `restore_save_data()` -> ambos activos, 0 faltantes.
- DLC ausente en el save -> queda en `dlcs_faltantes`, NO activado.
- Suite nueva `tests/unit/dlc/test_dlc_manager.gd`: **39 checks / 0 fallos / EXIT 0**
  (12 bloques A-L, piso `CHECKS_MINIMOS=39` MEDIDO; `_summary()` nombra bloques faltantes).
- Suite legacy `scripts/dlc/test_dlc_m120.gd`: **16 checks / 0 fallos / EXIT 0** (post-fix).
- Colector `_colector_sintaxis.gd`: **920 preloads / 0 SCRIPT ERROR / EXIT 0**.
- Full load (`--headless --quit`): **0 SCRIPT ERROR**; linea `[M120] DlcManager listo (2 DLC, 1 bundles)`.

---

## 5. Archivos tocados

- `game/isla-ancestral/scripts/dlc/dlc_manager.gd` (fix tecnico + ISaveProvider).
- `game/isla-ancestral/tests/unit/dlc/test_dlc_manager.gd` (NUEVO, 39 checks).
- `DOCUMENTACION/120-DLC-Y-Expansiones/plan-actual/05-Checklist.md` (bloque de auditoria
  T-D5 al final; NO se toco ninguna marca).
- `DOCUMENTACION/11-BUGS.md` (BUG-102: fila de tabla + seccion detallada).
- `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md` (T-D5 + reserva 1291).
- `Logs/1291-T-D5-M120-auditoria-versionado-save_2026-10-04_20-44-38.md` (este log).

---

## 6. Hallazgos para el GLOBAL (NO lo edite yo - dueno: director)

La fila 120 dice:

`| 120 | 120-DLC-Y-Expansiones | VERDE Disponible | 163/222 | Baja | 2 | 95, 142 | DeepSeek | - | 2026-08-19 | ... AZUL Verificado por Hy3/WorkBuddy (Log 866, sec.21.8): test test_dlc_m120.gd EXIT 0 (16 checks) |`

Dos correcciones:

1. **Estado:** `VERDE Disponible` -> **`AMARILLO Con dudas`**. Motivo: tiene 163 [x] (drift E3) y su capa
   tecnica es parcial (DlcManager real; 3 servicios auxiliares pendientes; versionado+save
   recien arreglados). Es el mismo criterio aplicado a la fila 03.

2. **Sello:** `AZUL Verificado por Hy3/WorkBuddy (Log 866, sec.21.8)` -> **INVALIDO**. Log 866 es el
   log FRAUDULENTO que Hy3 ya reemplazo (commit `ad6b370`). M120 es una de las filas que citan
   Log 866 como verificacion sec.21.8 -> el sello debe removerse. El test legacy (16 checks) es
   real, pero la FIRMA que lo avala es fraudulenta.

**Texto exacto sugerido para la fila 120** (para que el director lo aplique, ya que no edito el GLOBAL):

| 120 | 120-DLC-Y-Expansiones | AMARILLO Con dudas | 163/222 | Baja | 2 | 95, 142 | DeepSeek | - | 2026-08-19 | Documentacion completa por SWE-1.6 (DEVIN, 2026-08-19): roadmap DLC, expansiones, contenido post-lanzamiento. DELEGABLE PARA IMPLEMENTAR. Auditoria contra disco (T-D5, DeepSeek-V4.1-Flash, Log 1291): conteo real 163/59/0 = GLOBAL 163/222 (sin falso cero); nucleo tecnico = DlcManager (autoload) + 2 JSON + 2 tests (16/0 y 39/0); 3 servicios disenados NO implementados (compatibility_checker/uninstaller/bundle_manager); BUG-102 (versionado lexicografico + DLCs activos no persistidos) resuelto. Sello Log 866 INVALIDO (log fraudulento, reemplazado por Hy3 en ad6b370). Sin sello sec.21.8. |

---

## 7. Preguntas / pendientes para el director

1. **Reclasificacion "design-heavy":** dijiste "lo 'design-heavy' queda [?] con dueno". M120 es
   ~95% items "Disenar/Definir" con diseno documentado en `04-Codigo.md`. Quieres que los
   marque `[?]` (no verificables en codigo) o que queden `[x]` (diseno documentado = hecho)?
   No los toque para no repetir un revert masivo tipo `41ff104`.
2. **Los 44 modulos con drift:** M120 es uno. Aplico el criterio de estado (VERDE->AMARILLO) a los demas
   a medida que los audite, o espero una politica unica del director?
3. **Sello:** confirmo que NO sello sec.21.8 M120 (autor del fix). La verificacion cruzada queda
   para otro modelo.

---

## 8. Estado del frente

- T-D5: parte tecnica ENTREGADA (codigo + test + auditoria + log). Commit y push pendientes.
- T-D3: a la espera de QA cruzado sec.21.8 (Hy3).
- T-D2: sigue bloqueado (M53/mimo).
- T-D6 (M94-Retencion-Sin-FOMO): proximo en cola.

Firma: DeepSeek-V4.1-Flash (WorkBuddy), 2026-10-04.

---

## 9. Huella de push (AGENTS.md sec.4.3)

- Rango: `5c15327..12cc9fd`
- Fecha/hora: 2026-10-04 20:49
- Rama: main (fast-forward, sin --force)
- Contenido: T-D5 M120 (auditoria contra disco + BUG-102 + test nuevo 39/0 + Log 1291 + mensaje 25 al director)
- Commits ajenos incluidos: ninguno. `12cc9fd` es solo mio (7 archivos); su padre `5c15327`
  ya estaba en origin antes del push (lo pusheo otro agente en el arbol compartido).
- Verificacion: `git rev-parse HEAD` == `git rev-parse origin/main` == `12cc9fd`.
- Nota: el archivo `_colector_sintaxis.gd` NO se commiteo (preloadea 2 `.gd` untracked de
  `scripts/interacciones/` en vuelo de otro agente; el CI lo regenera).
