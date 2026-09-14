# Log 881: M148 Lore-Ambiental — iteración 2 (data-only: CI gate, grafo, persistencia)

**Fecha:** 2026-09-13
**Hora:** 19:0x
**Modelo:** DeepSeek-V4.1-Flash / WorkBuddy
**Plataforma:** WorkBuddy
**Módulo:** 148 — Lore Ambiental
**Reserva:** `Logs/reservas/881-DeepSeek-V4.1-Flash-M148.txt`

## 0. Contexto

Continuación del bucle por módulo sobre el backlog propio
(`TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md`, entrada A9). M148
estaba "🟡 Con dudas 14/114" y **liberado** (su dueño, `deepseek-v4-flash-vision-exp`,
inactivo). Se retoma la parte **data-only**, que es lo que encaja con el perfil
del agente: verificación, gate de CI, grafo de datos, persistencia y determinismo
headless — sin arte, escena ni UI.

**Nota de numeración:** el 880 ya estaba tomado por el chat **Hy4/WorkBuddy**
(`880-HY4-IDENTIDAD-POR-CHAT.md`, otra conversación). Se reservó el **881**.

## 1. Diagnóstico — sobre-cierre

`05-Checklist.md` declaraba en su bloque "Totales":

> **Total de ítems:** 114 · **resueltos por documentación:** 114 (0 pendientes, 0 dudas)

Conteo real (script, `^- \[`):

| Estado | Declarado | Real |
|--------|-----------|------|
| `[x]` | 114 | **17** |
| `[?]` | 0 | **1** |
| `[ ]` | 0 | **99** |
| Total | 114 | **117** |

**Causa raíz:** la propia "Convención" definía

> `- [ ]` = completado por documentación … `[ ]` = pendiente

— es decir, `[ ]` significaba **a la vez** completado y pendiente. Con esa
ambigüedad cualquier conteo es "correcto". Además:

- El archivo tenía **BOM** (viola AGENTS.md §28).
- Declaraba cifras inexistentes: **68 piezas** (real: 60) e islas con
  **18/17/17/16** (real: 18/14/14/14).
- `04-Codigo.md` describía una implementación **Unity/C#**
  (`Assets/_Project/Scripts/…/LoreCatalogo.cs`, `MonoBehaviour`, `IInteractable`).
  **0 de esos archivos existe**: el proyecto es Godot 4.7.2 (982 `.gd`, 1 `.cs`).
- El `LoreAuditor` declarado "0 errores en catálogo real" **no validaba el grafo**:
  `es_pista_valida()` solo comprobaba `not consumidor_id.is_empty()`, y el
  array `pistas` que construía **nunca se usaba** (código muerto).
- No existía ninguna puerta de CI real, pese a que el ítem "Definir CI: LoreGate
  en build" ya estaba marcado `[x]`.

## 2. Implementado

### 2.1 Grafo de pistas real
- **Nuevo** `data/lore/consumidores.json`: **18 consumidores** válidos
  (`puzzle_templo_*`, `sello_*`, `coleccion_*`, `npc_*`, `altar_*`, `rumor_cancion`)
  con tipo y módulo dueño.
- `LoreCatalogo`: `cargar_consumidores()`, `consumidor_valido()`, `ids_consumidores()`,
  `pistas()`, `es_tipo_pista()` (estático) y `es_pista_valida()` reescrito para
  consultar el **registro** (antes: "no vacío").
- `LoreAuditor.validar_grafo()` nuevo; `validar()` ahora también comprueba
  **tipo en rango**, **título/texto vacíos**, **isla vacía** y **consumidor
  desconocido**; `reporte_cobertura()` nuevo.

### 2.2 Gate de CI (`lore_gate.gd`)
Script `SceneTree` headless: carga el catálogo, corre el auditor y el grafo, e
imprime el reporte de cobertura. **`exit 0`** si todo es válido, **`exit 1`** si no.
Cableado en `.github/workflows/quality.yml` → job `test-suite` (junto a
`test_lore_m148.gd`). El workflow usa `bash -e`, así que un `exit 1` rompe el job.

### 2.3 Persistencia (`lore_save_provider.gd`)
`LoreSaveProvider` implementa el contrato `ISaveProvider` **por duck-typing**,
igual que `PlayerSaveProvider`/`BuildingsSaveProvider` (M59). Sección `"lore"`
con `{version, explorado[], por_isla{}}`.

**No se tocó M59**: `SaveSnapshot.collect()` ya hace `payload[section] = data` para
cada proveedor registrado, y `restore()` solo llama si la sección existe. Es el
punto de extensión documentado y es aditivo por diseño.

- `marcar_explorado(id, isla)` devuelve **`true` solo si es nueva** → permite
  decidir si notificar (no re-notificación, RF8).
- `migrar(data, desde_version)` normaliza saves **sin** la sección o parciales
  (v0/v1), deduplica ids, coacciona tipos y **nunca degrada**.
- Contadores por isla persistidos (`contador_isla`).

> Sobre "migración **v3.1**" del checklist: el esquema real de M59 es
> **`SCHEMA_VERSION = 1`**. El "v3.1" del documento era aspiracional. La
> migración implementada es la real y verificable: *sección `lore` ausente →
> estado vacío válido*, más normalización de datos parciales.

### 2.4 Test reescrito (`test_lore_m148.gd`)
8 bloques (A–H) con marcador **`_fin()`** por bloque verificado en `_run()`
(anti-falso-verde: un error de script aborta la función en silencio y el resumen
imprimiría "0 fallos"). Bloques adversarios, migración y **30 ciclos save/load**
con round-trip JSON real. Resultado: **85 checks, 0 fallos, 3/3 corridas, 0 `SCRIPT ERROR`**.

## 3. Bugs reales encontrados por la prueba adversaria

### Bug 1 — `String(x)` no es constructor válido en Godot 4
`migrar()` hacía `String(i)` sobre un `int`:

```
SCRIPT ERROR: Invalid call. Nonexistent 'String' constructor.
```

En Godot 4 los constructores de `String` son `String()`, `String(String)`,
`String(StringName)`, `String(NodePath)`: **no hay `String(int)`**. El error
**aborta la función en silencio**, de modo que `migrar()` no normalizaba nada.
Corregido a **`str(x)`**. El mismo patrón estaba latente en `lore_catalogo.gd`
(`String(d.get(...))`, `String(i)`) y se corrigió: funcionaba solo porque el JSON
siempre entregaba `String`.

### Bug 2 — El chequeo de IDs duplicados del auditor era código muerto
`LoreCatalogo._piezas` **ya es** un `Dictionary` por `id`, así que `cargar()`
colapsaba el duplicado (el segundo pisaba al primero) **antes** de que el auditor
pudiera verlo. La prueba sintética original "pasaba" porque inyectaba los
duplicados directamente en `_piezas`, saltándose la carga real.

Solución: la detección se movió **al cargar** (`LoreCatalogo.ids_duplicados()` +
`entradas_sin_id()`), y el auditor la reporta. Confirmado por la prueba negativa
del gate: `ID duplicado: dup` ahora aparece.

> Este es el valor de la prueba adversaria: un validador que siempre devolviera
> "OK" habría pasado la prueba anterior sin ser detectado.

## 4. Verificación

| Comprobación | Resultado |
|---|---|
| `test_lore_m148.gd` | **85 checks · 0 fallos** ×3 corridas |
| `SCRIPT ERROR` | **0** en las 3 corridas |
| `lore_gate.gd` con catálogo real | **exit 0** — 60 piezas, 16 pistas, grafo consistente |
| `lore_gate.gd` con catálogo roto | **exit 1** — 5 violaciones (incluye ID duplicado) |
| `lore.json` tras la prueba negativa | restaurado, **60 piezas** |
| Marcadores `_fin()` | 8/8 bloques cerraron |
| `quality.yml` | YAML válido (6 jobs); `lore_gate.gd` + `test_lore_m148.gd` en `test-suite` |
| `05-Checklist.md` | BOM eliminado; 117 ítems → **23 `[x]` / 2 `[?]` / 92 `[ ]`** |
| `04-Codigo.md` | reescrito con archivos Godot reales + apéndice C# como diseño muerto |
| `CHECKLIST-GLOBAL.md` fila 148 | `🟡 Liberado | 23/117 | DeepSeek-V4.1-Flash | 2026-09-13` (CRLF intacto) |
| `ESTADO-PARALELO.md` | fila M148 agregada (CRLF intacto) |

## 5. Brechas declaradas abiertas (no cerradas)

Ninguna es de tipo datos/CI; son contenido, escena o UI:

| Brecha | Diseño | Real | Naturaleza |
|---|---|---|---|
| Islas con lore | 6 | 4 | Contenido narrativo (M147/M26) |
| Pistas | 30 | 16 | Contenido narrativo |
| Secretos por temporada | 3 (12/año) | 1 (4/año) | Contenido + M74 |
| `TriggerLore` (inspección 3D) | existe en diseño | no existe | Requiere escena/arte |
| Sección de diario (UI) | sección + filtros | no existe | Depende de M55/M89 |

## 6. Archivos

**Nuevos**
- `game/isla-ancestral/scripts/lore/lore_gate.gd`
- `game/isla-ancestral/scripts/lore/lore_save_provider.gd`
- `game/isla-ancestral/data/lore/consumidores.json`
- `DOCUMENTACION/148-Lore-Ambiental/plan-actual/06-Plan-Testings.md`
- `DOCUMENTACION/148-Lore-Ambiental/plan-actual/07-Resultados-Testings.md`

**Modificados**
- `game/isla-ancestral/scripts/lore/lore_catalogo.gd` (consumidores, duplicados, `cargar_desde_texto`, `str()`)
- `game/isla-ancestral/scripts/lore/lore_auditor.gd` (grafo, tipo, texto, cobertura, duplicados)
- `game/isla-ancestral/scripts/lore/test_lore_m148.gd` (reescrito, 85 checks)
- `DOCUMENTACION/148-Lore-Ambiental/plan-actual/04-Codigo.md` (reescrito)
- `DOCUMENTACION/148-Lore-Ambiental/plan-actual/05-Checklist.md` (BOM, convención, conteos, cifras)
- `.github/workflows/quality.yml` (gate + test de lore en `test-suite`)
- `CHECKLIST-GLOBAL.md` (fila 148)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (fila M148)
- `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md`

**No modificado (a propósito)**
- `scripts/saving/save_schema.gd`, `save_snapshot.gd`, `save_loader.gd` (M59):
  la integración usa el punto de extensión documentado, sin tocar el módulo.

## 7. Próximo en la cola

**M52 Partículas (A8)** → luego **M26 Templo (A12)**.

---

**Firma:** DeepSeek-V4.1-Flash / WorkBuddy · 2026-09-13 · Log 881
