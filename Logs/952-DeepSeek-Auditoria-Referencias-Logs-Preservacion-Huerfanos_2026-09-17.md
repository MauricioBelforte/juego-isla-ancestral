# Log 952 — Auditoría de referencias a `Logs/` + preservación de huérfanos (DeepSeek-V4.1-Flash / WorkBuddy)

**Firmado por:** DeepSeek-V4.1-Flash (WorkBuddy)
**Fecha:** 2026-09-17
**MID:** — (transversal: higiene de `Logs/` y auditoría de referencias; no es ciclo de módulo)
**Alcance:** (1) verificación de la afirmación del usuario *"corregí las referencias a los logs mal
enumerados"*; (2) auditoría de `scripts/auditar_referencias.py`; (3) protección contra la pérdida de
logs (trampa 64); (4) preservación del contenido único que quedó en cuarentena.
**Reserva:** `Logs/reservas/952-deepseek-auditoria-logs.txt`
**Trampas cubiertas:** 64 (log untracked), 66 (.gitignore sigue al archivo), 67 (dedup por número), 68 (auditor no excluía `.kilo/`).
**§21.8:** este log **no** es un QA cruzado (no hay módulo verificado) → no aplica auto-QA.

---

## 1. Verificación de la corrección de referencias (pedido del usuario)

El usuario afirmó haber corregido las referencias a logs mal enumerados. **Resultado medido: la
afirmación es FALSA para las referencias a logs.** Evidencia directa sobre el árbol actual:

- Las **17 citas vivas a números de log VACÍOS** siguen exactamente igual (ver §3).
- Las dos líneas del **M115** siguen leyendo `*(Logs/308, 320, 327 — uno por iteración)*`:
  - `DOCUMENTACION/115-Hardware/plan-actual/05-Checklist.md:141`
  - `DOCUMENTACION/TAREAS-POR-MODELO/deepseek-v4-flash/115-Hardware/checklist.md:102`
  - Comprobado: `Logs/308` **no existe**; `Logs/320` es **M30** (`320-M30-Auditoria-PostCierre-Iter2`);
    `Logs/327` sí es M115 (`327-M115-Hardware-Iter1`).
- El **"Log 723 fantasma"** ya estaba documentado como hallazgo en `Logs/853` (y repetido en
  860/875/876/880), y **sigue citado 3 veces** en `DOCUMENTACION/TAREAS-POR-MODELO/HY4/BACKLOG-MASTER.md`
  (L250, L277, L278).

**Lo que SÍ está corregido y verificado completo: la reorganización de guías.**

- `07-GUIA-GODOT.md` y `09-GUIA-BLENDER.md` archivadas en `DOCUMENTACION/OBSOLETOS/`.
- Canon: `GUIA-GODOT/` (17 archivos) y `GUIA-BLENDER/` (11), con `INDICE.md`.
- Colisión 01-12 resuelta: `01-zoom-camara-personaje→16`, `02-disco-plano-verde→17`,
  `03-impostores-terreno→18`, `README.md→INDICE.md`.
- **0 referencias colgadas** a las rutas viejas en documentación viva (las que quedan viven dentro
  de `Logs/*.md`, es decir son historial).

## 2. Hallazgo principal: 7 números de log VACÍOS, citados por CÓDIGO DE JUEGO

Clasificación de la cuarentena `.workbuddy-ai/recuperado-2026-09-16-borrado-logs/Logs/`
(gitignoreada) contra el árbol actual:

| Clase | N | Destino |
|---|---|---|
| Duplicados exactos (SHA-256 idéntico a un log vivo) | 12 | no se copian (redundantes; el dedup renumeró bien: `770→838`, `771→839/840`, …) |
| Gemelos renombrados (mismo contenido, otro número) | 3 | no se copian: `831→832`, `938→941`, `926` (cambio de fecha) |
| **Huérfanos (contenido único)** | **26** | **copiados a `PAPELERA/logs-recuperados-2026-09-16/`** |

De esos 26 huérfanos, **7 números no tienen NINGÚN archivo en `Logs/`**:

`723, 792, 800, 801, 802, 803, 805`  → 12 archivos (801×2, 802×3, 803×3).

**Causa raíz (trampa 67):** el dedup del 2026-09-16 deduplica **por número**. En estos 7 casos
borró **todas** las copias y **no renumeró ninguna** → el número desapareció pero el código y la
documentación siguen citándolo.

### 2.1 Citas vivas a números vacíos (17)

**Código de juego** (3):
- `game/isla-ancestral/scripts/world/terreno_horizonte.gd:238` → `Log 800`
- `game/isla-ancestral/scripts/world/terreno_horizonte.gd:255` → `Log 792`
- `game/isla-ancestral/scripts/world/terreno_horizonte.gd:293` → `Log 803`

**Guías vivas** (10):
- `DOCUMENTACION/GUIA-GODOT/16-zoom-camara-personaje.md:88` → 803
- `DOCUMENTACION/GUIA-GODOT/18-impostores-terreno.md` → L149 (803), L317 (800), L319 (803), L326 (802)
- `DOCUMENTACION/GUIA-GODOT/19-diagnostico-tildes.md` → L34, L45, L80, L99 (802), L90 (805)

**Otros docs vivos** (4):
- `DOCUMENTACION/TAREAS-POR-MODELO/HY4/BACKLOG-MASTER.md` → L250, L277, L278 (723)
- `out/changelog_m117_iter2.md:398` (723)

**Historial dentro de `Logs/`** (14 menciones en 9 archivos: 814, 816, 817, 848, 853 ×4, 860, 875, 876, 880).

### 2.2 Agravante: números que existen pero con OTRO log (resolución silenciosa equivocada)

Los otros 16 huérfanos comparten número con un log **DISTINTO** que sí está en `Logs/`. Citar ese
número resuelve **al log equivocado**, que es peor que un hueco porque no se nota. Ejemplos:

| Huérfano (contenido único perdido) | `Logs/` tiene en ese número |
|---|---|
| `722-HY3-M10-QA-CRUZADO` | `722-M48-AnimationService-FSM` |
| `761-workbuddy-M33-3D-CULTIVOS` | `761-AGNES-BUCLE-P9-CIERRE-ITEMS` |
| `790-workbuddy-M33-3D-Regadera` | `790-M09-DISCO-VERDE-FUNCIONA-MONTANAS-600M` |
| `831-HY3-M09-REGRESSION-VoxelViewer-reparent` | `831-M27-Iter1-Nucleo-Archipielago` |
| `874-AGNES-ROUND11-CIERRE-M123-M116` | `874-M87-Localizacion-Iter5-Validador` |

## 3. Preservación (hecho — sin tocar ninguna cita)

- **26 huérfanos copiados a `PAPELERA/logs-recuperados-2026-09-16/`** + `README.md` con procedencia,
  clasificación y el estado de cada número.
- **Por qué ahí:** la cuarentena original vive en `.workbuddy-ai/` que está **gitignoreado**
  (0 archivos versionados) → **mismo punto único de fallo** que causó la pérdida del 2026-09-16.
  `PAPELERA/` está versionada y ya alberga los artefactos del dedup (`renumber_map*.json`,
  `duplicates_scan.txt`, `renombrar_logs.py`).
- **27 archivos, CRLF, sin BOM** (§28). Dos traían BOM (`152-…`, `874-…`) → removido.
- **NO se restauraron en `Logs/`**: `801/802/803` tienen 2-3 logs **distintos** cada uno; restaurar
  el número original **recrea la colisión** (trampa 67). La reparación correcta es **renumerar a
  slots libres + actualizar las citas**, y eso es decisión del dueño de cada log.

## 4. Fixes de herramientas (commiteados)

- `scripts/auditar_referencias.py`: **`'.kilo'` en `EXCLUIDOS`** (commit `fd5796b`).
  Sin esto auditaba el git worktree `.kilo/worktrees/phase-judge` (congelado en `2e9f0be`) y
  reportaba **158 rutas rotas donde hay 1**.
- `scripts/auditar_referencias.py`: **`'PAPELERA'` en `EXCLUIDOS`**. Medido: el `README.md` de la
  cuarentena (que por definición nombra números rotos) aportaba **13 rutas rotas falsas**.
  Auditoría global: **13 → 1**.
- Nota de método: `git check-ignore -v` **imprime el patrón aunque sea una negación** y sale con
  **código 1 cuando el archivo NO está ignorado** → usar el **exit code**, no la salida.

## 5. Higiene de `Logs/` (hecho)

- **4 logs untracked commiteados** — trampa 64 (commit `a42c636`): `944`, `945`,
  `949-Hy3-M87`, `950-Hy3-M127`. Los 4 tenían la reserva ya consumida.
- **14 logs con regresión LF→CRLF normalizados** (`928, 934, 939-950`). Sus blobs son **LF puro**
  → tras normalizar, `git diff` queda **vacío** (el ` M` que muestra `git status` es un flag
  *stat-dirty* obsoleto; se limpia con `git update-index --refresh` o un `git add` inocuo).
- `Logs/705` y `Logs/710` tienen blob **mixto** (CRLF+LF) → **exentos de normalización**;
  restaurados **byte-idéntico** desde `git cat-file -p HEAD:<ruta>`.
- **4 temporales movidos fuera de `Logs/`** → `.workbuddy-ai/tmp/logs-scratch-atria-dawn-m09-2026-09-16/`
  (`_boot.bat`, `_boot.txt`, `_m09_qa.txt`, `_run_one.bat`). `Logs/` vuelve a ser sólo
  `NNN-*.md` + `ULTIMO_NUMERO.txt` + `reservas/`.

## 6. Hallazgo nuevo (concurrencia): colisión de número 949

`Logs/949-QA-M08-Mundo-Voxel_2026-09-17_05-38.md` (Atria-Dawn-Preview / Kilo Code) está
**untracked** y usa el número **949**, ya ocupado por `Logs/949-Hy3-M87.md`
(reserva `Logs/reservas/949-hy3-M87.txt`). Es **trampa 67 en curso**. No lo renumeré
(trabajo ajeno) ni lo commiteé (cementaría la colisión) → **requiere decisión del autor**.
Slots libres: **952+** (este log tomó 952).

## 7. Pendientes (requieren decisión del dueño)

1. **Renumerar los 26 huérfanos a slots libres + actualizar las 17 citas vivas** (código + docs).
   Casos sin ambigüedad (número libre + un solo huérfano): **792, 800, 805** (+723 si el dueño
   confirma que `723-HY3-M11-QA-CRUZADO` es el log que se quería citar).
2. **M115**: reemplazar `Logs/308, 320, 327` por los logs reales de M115
   (`327` Iter1, `414` Iter2, `526` Núcleo Iter1, `921` Iter agnes) en las 2 checklists.
3. **HY4/BACKLOG-MASTER.md** L250/L277/L278: el "Log 723 fantasma" (ya señalado en `Logs/853`).
4. Renumerar `Logs/949-QA-M08-…` (Atria).
5. `Logs/reservas/` contiene **9 scripts `.py` versionados** (`add_hitos_test.py`, `m71_liberar.py`,
   `scan_deepseek.py`, …) citados por `Logs/849` → violan la regla de que `Logs/` sólo tiene logs.

---

## Verificación

- `scripts/auditar_referencias.py`: **1 ruta rota** (falso positivo conocido: el glob
  `Logs/9*agnes*M107*`), 4 ambiguas, 26 menciones `Log NNN` sin log.
- `PAPELERA/logs-recuperados-2026-09-16/`: **27 archivos**, CRLF, sin BOM,
  `git check-ignore` → **exit 1 (no ignorado)**.
- Este log: UTF-8 sin BOM, CRLF, en `Logs/952-…`.
