# Log 902 — M26 Templo Subterráneo, iteración 2

- **Modelo:** DeepSeek-V4.1-Flash / WorkBuddy
- **Plataforma:** WorkBuddy
- **Fecha:** 2026-09-14
- **Módulo:** M26 — Templo Subterráneo (Templo de la Brisa)
- **Reserva:** `Logs/reservas/902-DeepSeek-V4.1-Flash-M26.txt`
- **Estado del módulo:** 🟡 (0/115 → `[x]` 50 · `[?]` 8 · `[ ]` 57)
- **Test:** `scripts/templos/test_templo_m26.gd` → **92 checks, 0 fallos, EXIT 0 ×3**, 0 `SCRIPT ERROR`

## Contexto

M26 estaba documentado como "DELEGABLE PARA IMPLEMENTAR" desde 2026-08-17 (26/26
puntos de la sección 25) y su fila en `CHECKLIST-GLOBAL` decía `0/115`. La
iteración 1 (deepseek-v4-flash-vision-exp, 2026-09-02) había dejado un layout
mínimo de 4 salas + `TemploSchema` + un test de 4 checks.

Esta iteración 2 hace **la parte verificable** del módulo: gating, anti-exploit,
checkpoints atómicos, telemetría de puzzles y las suites de validación que el
diseño exige. No toca lo visual/3D (luces, materiales, partículas, audio): eso
depende de M08, M41/M42/M43, M45/M47/M52, M58, M61 y M63.

## Qué se implementó

| Archivo | Qué |
|---|---|
| `scripts/templos/templo_flow.gd` | `TemploFlow`: 7 anillos, sellos únicos (no duplicables), glifo por anillo, restauración del Sello y apertura de la salida. Lógica pura (`RefCounted`), con señales `anillo_activado` y `sello_restaurado_ok` como hooks |
| `scripts/templos/templo_checkpoint.gd` | `TemploCheckpoint`: los 5 CP (porte, vestíbulo, vientos, central, sello) con guardado atómico (tmp → rename → `.bak`), carga con respaldo y `validar_atomico()` |
| `scripts/templos/templo_telemetria.gd` | `TempleTelemetria`: intentos, pistas y tiempo por puzzle con reloj inyectable; `exportar_a_m24()` / `exportar_json()` (round-trip idempotente) |
| `scripts/templos/templo_validadores.gd` | `TemploValidadores`: suites de softlock, anti-exploit, voxel, accesibilidad, orientación y checkpoints; `validar_todo()` |
| `data/templos/templo_blueprint.json` | Metría voxel (corredor 4x4x4 m, puerta 2x3, techo 3x3, 45°, rampas ≤20°), accesibilidad (contraste 4.5:1, icono 16 px, sin presión temporal), orientación (mojones 40 m, deriva 120 s), gating (7 anillos, sellos únicos) y presupuesto |
| `data/templos/templo_layout_diseno.json` | El grafo del `03-Diseno` en datos: 20 zonas, 24 conexiones, 17 puzzles, 7 anillos con su glifo y su sello |
| `scripts/templos/test_templo_m26.gd` | Suite headless de 7 bloques con marcadores `_fin()` |

## Bugs reales encontrados y corregidos

### 1. `DirAccess.make_dir_recursive()` no es estático (mi código)

`Parse Error: Cannot call non-static function "make_dir_recursive()" on the class "DirAccess" directly`.
Hacía que `templo_checkpoint.gd` **no compilara** → `CpGd.new()` fallaba → el
bloque C se abortaba **en silencio**. Lo delató el marcador `_fin("C")`.
Corregido con `DirAccess.make_dir_recursive_absolute(dir)`.

### 2. `DirAccess.open("user://…")` devuelve `null` en este host (mi código)

Medido con sonda en Godot 4.7.2 headless con `--path` relativo:

| Llamada | Resultado |
|---|---|
| `DirAccess.open("user://…")` | `null` |
| `DirAccess.open("res://")` | OK |
| `DirAccess.get_files_at("user://…")` | `[]` |
| `DirAccess.dir_exists_absolute("user://…")` | `true` |
| `DirAccess.make_dir_recursive_absolute("user://…")` | OK |
| `FileAccess.open("user://…/x.json", WRITE)` | OK |
| `DirAccess.open(globalize_path("user://…"))` | **OK** |
| `DirAccess.get_files_at(globalize_path("user://…"))` | **OK** |

`globalize_path("user://")` = `./Godot/app_userdata/isla-ancestral/` (RELATIVA);
el `user://` real es `game/isla-ancestral/Godot/app_userdata/isla-ancestral/`.
Corregido: el checkpoint usa solo funciones estáticas y deriva la lista de
archivos de los ids conocidos con `FileAccess.file_exists()`.

### 3. Bloqueante de proyecto: el autoload `BackupManager` (M107) no compilaba

`scripts/backup/backup_manager.gd` usaba `var _da := DirAccess.new()` —
`DirAccess` es **abstracta** en Godot 4 → error de parseo → el autoload no
cargaba. Consecuencias:
1. El test de M107 fallaba (`cantidad backups >= 1`) — es **BUG-035**.
2. **Toda** corrida headless del proyecto imprimía 3 líneas `SCRIPT ERROR`,
   contaminando cualquier verificación que filtre por `SCRIPT ERROR`.

Corregido (mismo diagnóstico que BUG-035, ya delegado): crear con
`make_dir_recursive_absolute()` y globalizar antes de `DirAccess.open()`.
Verificado: `test_backup_m107.gd` → **9/0, EXIT 0 ×3, 0 `SCRIPT ERROR`**.
De regalo: la **retención de backups nunca se aplicaba** (`_limpiar_excedentes()`
salía antes por `dir == null`) y ningún test lo cubría. Ahora funciona.

### 4. Dos bugs propios en el test (los detectó la propia suite)

- Reloj de la telemetría: el caso esperaba 20 s y el test solo avanzaba 10 s.
  Se corrigió el avance (10 → 25 → 30), no la aserción.
- "Rechaza glifo incorrecto" daba motivo `sello_inexistente` porque el sello del
  anillo 1 no estaba registrado. Se agregó el registro + 2 checks extra.

## Auditoría del checklist (sobre-cierre)

El `05-Checklist.md` decía `100/100 [x]` **sin un solo marcador puesto**: era una
afirmación de completitud *del diseño*, no un conteo real (el patrón de
sobre-cierre que domina el proyecto). Se agregó un bloque `## Convención` y se
re-derivaron los marcadores con criterio conservador: **`[x]` solo donde hay un
artefacto verificable** (código, datos, test o la línea de diseño citada); los
ítems de diseño narrativo sin artefacto quedan `[ ]` aunque el diseño exista,
porque su autor no los marcó y esta iteración no los reverificó uno por uno.

Conteos finales: **`[x]` 50 · `[?]` 8 · `[ ]` 57 = 115**.

Hallazgos de diseño registrados como `[?]`:
- `03-Diseno` pide **8 glifos del Sello (4 comunes + 4 de cámara)**; el grafo
  nombra 7 (uno por anillo). Falta el 8.º y la separación común/cámara.
- `03-Diseno` se contradice en los checkpoints: §"Checkpoints" lista *porte,
  vestíbulo, vientos, central, sello*; la tabla de zonas lista *vestíbulo,
  vientos, central, final, sello*. Se siguió la lista explícita y se anotó.

## Documentación producida

- `04-Codigo.md` — reescrito con las rutas GDScript reales. El original describía
  `Assets/_Project/Scripts/World/Templo/*.cs` (Unity/C#), **rutas muertas** en un
  proyecto Godot: se documentó el mapeo real y se marcó como diseño NO implementado.
- `05-Checklist.md` — Convención + marcadores honestos + secciones de iteración 1 y 2.
- `06-Plan-Testings.md` — nuevo: 44 casos CP-01..CP-44, bloques, y "casos NO cubiertos".
- `07-Resultados-Testings.md` — nuevo: resultados ×4, bugs, mediciones, observaciones.

## Pendientes

- **QA cruzado §21.8 de M26** por otro agente (verificador ≠ autor).
- **Re-verificación §21.8 de BUG-035** por otro agente (el fix de M107 es mío).
- Contenido visual/3D/audio: luces, materiales, texturas, glifos, partículas,
  sonido → depende de M08, M41/M42/M43, M45/M47/M52, M58, M61, M63.
- Navegación real (M08), NPC atascados (M19/M64), puzzles irresolubles (M24),
  mapa de zona (M58), presupuesto por región (M63), instancing (M61/M63).
- **Higiene §28:** `scripts/backup/test_backup_m107.gd` arrancaba con **BOM UTF-8**
  (violaba §28). **Resuelto en el cierre del ciclo:** BOM eliminado (3 bytes, sin
  cambio funcional) al arreglar BUG-035; el test re-corrido da **9/0, EXIT 0,
  0 SCRIPT ERROR**.

## Anexo — cierre del ciclo (2026-09-14 21:10)

- **Registro en los TRES lugares** (regla de oro): fila 26 de `CHECKLIST-GLOBAL.md`
  (`🟡 Con dudas / Liberado (iter. 2 ✅) | 50/115 | DeepSeek-V4.1-Flash`), fila nueva
  en `Mensajes entre modelos/ESTADO-PARALELO.md`, y `BACKLOG-MASTER.md` (A12, C4,
  cola ítems 28/29 ✅, historial **ciclo 12**, estado de la cola). Checklist personal
  sincronizada in-place (54 líneas) → `[x]`53 · `[?]`9 · `[ ]`57 = 119.
- **BUG-035** en `DOCUMENTACION/11-BUGS.md`: `[?] Delegado` → `[x] Resuelto
  (2026-09-14, Log 902)`, con causa raíz, fix, evidencia y el BOM §28; fila nueva en
  la tabla resumen + fila en el historial §9.
- **CI:** `test_templo_m26.gd` y `test_backup_m107.gd` cableados en la job
  `test-suite` de `.github/workflows/quality.yml` (18 tests, YAML validado con PyYAML,
  6 jobs). El de M26 no estaba cableado; el de M107 protege el fix de BUG-035.
- **Memoria + skill:** `.workbuddy-ai/memory/` (diario + `MEMORY.md`) y la skill
  `isla-ancestral-ciclo-modulo` (trampa 6 de `DirAccess`/`user://` ampliada con lo
  medido en M26; trampa 11 con la reconfirmación del marcador `_fin`).

## Cola

Siguiente en mi backlog: **M124 (A11) infra de contenido de usuario** (compresión
4K→2K, límite de tamaño, sin coords del save, telemetría sin PII) o **M26 iter. 3**
(los `[ ]` verificables restantes), según `TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md`.

---

**Firma:** DeepSeek-V4.1-Flash / WorkBuddy — 2026-09-14
