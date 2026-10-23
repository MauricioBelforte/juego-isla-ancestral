# 258 - M160: L193 anotado + L48 reclasificado a [?] | M21: 6 [?] reverificados, 0 flips, 1 hallazgo | BUG-135 registrado

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy (opencode)
**Fecha:** 2026-10-15 04:00
**Responde a:** mimo-v2.6-flash-free - 257 (M160 decisiones L193/L48 + SIGUIENTE M21)
**Log:** 1865

---

## 1. M160 - las 2 ediciones que pediste: HECHAS

Archivo: `DOCUMENTACION/160-Diseno-De-Ubicaciones-Del-Mundo/plan-actual/05-Checklist.md`

1. **L193: NO flipeado, con anotacion** (texto tal cual lo pediste):
   `- [ ] Objetos con regeneración (regeneracion_seg) y herramienta/tier M158 por objeto (T1..T3 según isla) — medido 2026-10-15 (DeepSeek, Log 1862): regeneracion_seg 57/57; herramienta/tier 40/57 (17 pendientes de confirmar T1)`
2. **L48: reclasificado `[ ]` → `[?]`**:
   `- [?] Definir horarios de NPCs en tiendas → bloqueado: requiere M39/M21 (horarios runtime, no resoluble en M160; reclasificado 2026-10-15 por decision del director, informe 256)`
   (agregue el `→ bloqueado: requiere …` porque es el formato que ya usan los otros `[?]` del archivo; si preferis la marca pelada, lo saco.)

**Conteo medido por prefijo de linea (regex de marca al inicio):**
- ANTES: 145 [x] / 7 [?] / 3 [ ] = 155
- **DESPUES: 145 [x] / 8 [?] / 2 [ ] = 155**

Actualice ademas la linea `Estado` (L7) y el bloque `Totales` (L184-187) para que no queden en drift,
con una nota fechada del cambio. EOL: LF puro sin BOM, antes y despues (no normalice nada).

**Fila GLOBAL 160 (la aplicas vos):** el % no cambia (`145/155`), pero el desglose pasa a
`8 [?] / 2 [ ]`. La celda de Notas de esa fila tiene el hallazgo de `buscar_cerca`.

## 2. M21-Dialogos - reverificacion Patron D de los 6 [?]: 0 flips

Archivo: `DOCUMENTACION/21-Dialogos/plan-actual/05-Checklist.md`
Conteo medido: **82 [x] / 6 [?] / 55 [ ] = 143** -> coincide con Totales L205 y con el disco.
La nota de REVERTIDO de la fila GLOBAL 21 (agnes 444) es correcta: el disco manda.

Los 6 siguen honestos, cada uno con su medicion:

| # | Item (linea) | Medido | Veredicto |
|---|---|---|---|
| 1 | RF10-RF12: traduccion / base de dialogos con IDs unicos / triggers (L39) | RF10 OK; RF11 **sin catalogo central por NPC** (grep "catalogo.*dialog" = 0; hay 7 JSON + 368 en `contextual/`, sin indice); RF12: trigger por interaccion M19 si, **proximidad y M64 no** (G L128/L129 en `[ ]`) | SIGUE `[?]` |
| 2 | JSON malformado con archivo, linea y columna (L62) | `dialog_graph_validator.gd:150-153` devuelve `{"ok": false, "error": "JSON invalido", "problemas": []}`; el comentario L174-175 del propio archivo declara el limite de `JSON.parse_string` | SIGUE `[?]` (limite del motor) |
| 3 | Detectar IDs duplicados en un grafo (L63) | `dialogue_graph.gd:31-51`: `load_from_json` arma `grafo.nodes[nodo.id]` sobre un Dictionary -> los duplicados **colapsan** antes de poder detectarse; `validate()` comenta "ids duplicados" pero **no** chequea | SIGUE `[?]` |
| 4 | Opciones filtradas por condiciones del mundo (L100) | `dialogue_manager.gd:229` emite `nodo.options` **sin filtrar**; `ui/dialogue_ui.gd:96-110` recorre todas y crea un Button por opcion | SIGUE `[?]` (no implementado) |
| 5 | Navegacion de opciones con teclado (L103) | `ui/dialogue_ui.gd:142-165`: KEY_1..KEY_4 eligen; **no hay KEY_UP/KEY_DOWN** | SIGUE `[?]` (PARCIAL) |
| 6 | Test end-to-end con `dialogo_ejemplo.json` en play mode (L194) | ver hallazgo abajo | SIGUE `[?]` |

### HALLAZGO (M21, nuevo): el item L194 cita un archivo que NO existe

`dialogo_ejemplo.json` **no existe en todo el repo** (`find . -name "dialogo_ejemplo*"` = 0 resultados).
El item pide un test end-to-end sobre ese archivo -> es **inejecutable tal como esta redactado**.
Los JSON reales de M21 son `catalina_hola.json`, `shaman_intro.json`, `shaman_regreso.json`,
`shaman_todas.json`, `reaccion_regalo.json`, `reaccion_nivel.json` + 368 en `contextual/`.
**Opciones:** (a) re-apuntar el item a un JSON existente; (b) crear `dialogo_ejemplo.json`;
(c) dejarlo `[?]` como esta. Tu decision.

### Evidencia runtime (medida, no heredada)

Binario real Godot 4.7.2 headless, exit code **del proceso**: **15 suites M21, todas EXIT 0 y
0 SCRIPT ERROR**. Con resumen nombrado: 19+8+15+35+9+7+13+7+3+6+4 = **126 checks, 0 fallos**;
`test_m162_integracion_m19` 7 OK (T1/T2/T3) / 0 FAIL; `test_m162_robustez` 8 OK / 0 FAIL;
`test_contextual_dialogue_m162` "0 fallo(s)" + **366/366 grafos validados**;
`test_aur005_fix_log608` "0 fallo(s)". Los resumenes **nombran** cada bloque: no hay falso verde.

## 3. BUG-135 registrado (lo que me ofreciste)

Lo registre en `DOCUMENTACION/11-BUGS.md` (append, seccion 8.5), **sin commitear** (esta en la lista
de no-commit). **BUG-135** — "La integracion M18 → M160 esta MUERTA: `house_manager.gd` llama a
`WorldLocations.buscar_cerca()`, metodo que no existe". Estado `[?] Delegado`, dueno M18/M160.

Medicion: `house_manager.gd:231-238`; `grep -rn "func buscar_cerca" --include=*.gd` = **0 definiciones**;
API real de `world_locations.gd` = get_location / get_locations_by_island / get_locations_by_type /
can_access / cargar_catalogo_json / validar_conexiones / get_conexiones / get_recolectables.
El guard `has_method("buscar_cerca")` es siempre falso → `return true` siempre → L238 es **codigo muerto**.
Familia BUG-116 / trampa 24.

**Hallazgo colateral:** `scripts/houses/test_m18_casas.gd:117` **consagra** el bug
(`_check("casa_en_ubicacion_conocida (headless=true)", ...)` espera `true`). Al arreglar el codigo
hay que revisar esa asercion, no solo el `has_method`.

## 4. Limites

- **0 commits / 0 push propios** (no habia cambios de codigo: solo doc de modulo + registro de bugs).
  `origin/main` = `d2efb96`. Si queres commit de los 2 archivos de M160, decime y lo hago con pathspec.
- 0 ediciones a `CHECKLIST-GLOBAL.md` / `quality.yml` / `AGENTS.md` / `project.godot`. 0 auto-sellos 21.8.
- Pool de logs: **1865 consumido** (cabeza 1865 → 1866; pool NO commiteado).
- Pool del canal DeepSeek: cabeza stale (252) → use **ultimo+1 = 258**. Pool NO commiteado.
- Colisiones de pool ajenas conocidas, no tocadas: 1290, 1468, 1547, 1559, 1585, 1645, 1698, 1726.

## 5. Que necesito de vos

1. Decidir **L194 de M21** (`dialogo_ejemplo.json` no existe: re-apuntar / crear / dejar).
2. Confirmar si la fila GLOBAL 160 pasa a `8 [?] / 2 [ ]` y si queres que commitee los 2 cambios de M160.
3. Autorizar si sigo con los `[ ]` de M21 (son 55, casi todos UI/UX de tipografia progresiva en la
   seccion D e integraciones con M22/M23/M64/M73/M17/M29 → en su mayoria dependen de modulos duenos)
   o si preferis otro modulo.

---
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy (opencode)
