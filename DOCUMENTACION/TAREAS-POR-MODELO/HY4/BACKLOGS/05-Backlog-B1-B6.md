# Hy4 — B1-B6: Opción B cerrados (mojibake, BOM, rutas .cs, CI, autoría, artefactos)
**Fuente:** BACKLOG-MASTER.md Hy4 (sección dividida 4nov por fundador)
**Modelo:** Hy4 preview (Tencent Hunyuan)
**Plataforma:** WorkBuddy
**Estado:** Histórico/Cerrado

## Opción B — "parchar huecos" (encargada por el usuario 2026-09-14)

Rol asignado explicitamente: *"te necesito en este tipo de tareas parchando
huecos"*. Cuatro frentes transversales. Estado al 2026-09-14:

| # | Frente | Estado | Log | Commits |
|---|--------|--------|-----|---------|
| B1 | Mojibake real | **CERRADO** | 903 | `f308b7c`, `c952bdf` |
| B2 | 14 módulos sobre-cerrados | **CERRADO** (ninguno lo estaba) | 904 | `d35d458` |
| B3 | Log 723 inexistente | **CERRADO** | 904 | `a50b061` |
| B3b | 296 rutas `.cs` fantasma | **PENDIENTE** (decidir alcance) | — | — |
| B4 | Vigilar primer push de CI | **PENDIENTE** | — | — |

### B1 — Mojibake
Los 22 marcadores que quedaban eran **documentación** del síntoma, no
corrupción. Se añadió filtro por contenido de línea (`PAT_LINEA_DOC`) y
`scripts/test_diagnosticar_mojibake.py` como guarda contra falso verde.
Verificador: **SUCIO 0 / IRREVERSIBLE 0**.

### B2 — Auditoría de sobre-cierre
**Ninguno de los 14 está sobre-cerrado.** Los 7 revertidos por agnes sí estaban
bien reflejados (fila global 0/N). Trampas corregidas: contar `[x]` a secas
cuenta el propio banner de reversión; `head`/`grep` muestran falso mojibake por
la consola.
Desajustes reales (cierre no propagado): **M145** 105/105 vs fila 90/105,
**M146** 100/100 vs 90/100, **M119** 118 vs 100, **M136** 199 vs 200.
→ M145/M146 derivados a Hy3 (QA §21.8); el perfil Hy4 excluye el sello.

### B2b — BOM (hallazgo mayor, §28)
`scripts/fix_encoding.py` **detecta el BOM y lo descarta**: líneas 195-196 lo
quitan en memoria y la 260 solo reescribe cp1252/mojibake. Por eso sobrevivían.
Alcance medido: **509 archivos** (`scripts/verificar_bom.py`).
Corregidos los 7 del alcance auditado; **5 de ellos eran regresiones recién
introducidas** (HEAD limpio, BOM solo en working tree) → hay agentes escribiendo
BOM ahora mismo. Quedan 502 por decidir (362 en `Logs/`, histórico).

### B3 — Log 723
`CHECKLIST-GLOBAL.md` citaba 2 veces el "Log 723" como QA de M11, pero no
existe (salta 722→724). El QA real es el **Log 835**
(`Logs/835-HY3-M11-QA-CRUZADO.md`). Sustituido.

### B3b — Rutas `.cs` (pendiente)
296 rutas distintas, 561 ocurrencias; 531 en `DOCUMENTACION`, de las que
**238 están en `plan-actual`** (documentación viva), no solo en el diseño
histórico de Unity. Concentradas en M01 (55), M113 (22×3), M109 (21×4),
M141 (13×2). No se tocan sin decidir: renombrar `.cs`→`.gd` sería ficción.

---

## Cierres del 2026-09-16 (Log 925)

### B2 — BOM: CERRADO (decisión del usuario: "los 502, en dos commits")

| Commit | Contenido |
|---|---|
| `eb98614` | 83 archivos vivos con BOM en HEAD (por blob: 44 `.gd` con ediciones ajenas en vuelo quedaron intactos) |
| `b929ba0` | 361 logs históricos. Verificado antes: **0 de 361** con ediciones sin commitear → `git add` directo |

**Estado:** 509 → **3** archivos con BOM, los 3 fuera de versionado
(`app_userdata/…m87_val_bom.po`, `_probe_col.gd`, `scripts/backups/`).
⚠️ **El BOM se regenera**: ese mismo día aparecieron 5 archivos nuevos con BOM
y luego una regresión más en `08-GUIA-ORDEN-DE-IMPLEMENTACION.md`. Sigue
pendiente meter `scripts/verificar_bom.py` en CI (tarea B4).

### B3b — Rutas `.cs`: CERRADO (decisión: "corregir las reales + marcar el resto")

El grueso lo hizo **otro agente** en `53edd1b` (34 reemplazos + 175 marcas en
44 archivos, `plan-actual` y `plan-inicial`). **No se duplicó**: se auditó y se
cerró lo que faltaba.

| Commit | Contenido |
|---|---|
| `5df6e55` | 61 menciones en 12 archivos: **6** con `.gd` real reemplazadas, **55** marcadas `_ (diseno heredado) _` |

Reemplazos reales: `StressRunner`, `StressScenario`, `InventoryStress`,
`SaveLoadStress`, `BuildInfo` ×2.
Método: 9 archivos limpios por disco; 3 con ediciones ajenas
(M26, M118, M81) **por blob** para no pisarlas.

**Hecho verificado:** 0 `.cs` propios (el único es del addon gdUnit4),
0 `.csproj`/`.sln`/`.unity`/`.prefab`, **800 `.gd`** en `game/isla-ancestral/`.

### ⚠️ Trampa nueva (60) — regex de ruta con prefijo opcional sin anclar

`(?:[A-Za-z0-9_./\-]*/)?([A-Za-z0-9_]+)\.cs\b` **captura solo la última letra**:
el prefijo se come el nombre porque su clase incluye `_` y alfanuméricos.
Produjo 205 reemplazos con rutas inventadas. Se detectó por guardas
(`20 <= con_gd <= 40`, `os.path.isfile`) y se revirtió con
`git reset -q HEAD -- <paths>` (worktree intacto).
**Regla:** en sustituciones masivas, guarda que falle fuerte ANTES de escribir.

### Hueco nuevo detectado (no tocado)

**Dos autoloads de localización duplicados** en `project.godot`:
`Localization` → `res://scripts/localization/localization_manager.gd` (14,6 KB) y
`LocalizationManager` → `res://scripts/localizacion/localization_manager.gd` (2,7 KB).
Conocido como H-1. Requiere dueño de módulo; no mergear de paso.

---

## B4 — BOM en CI: CERRADO (commit `a0dd230`)

Job **`encoding-guard`** en `.github/workflows/quality.yml`: python 3.12 +
`scripts/verificar_bom.py` (sale con 1 si hay BOM). Agregado a `needs` del
`summary` y a la condición de fallo. Segundo paso informativo
(`continue-on-error`): `diagnosticar_mojibake.py` — no bloquea a propósito.

Correcciones en `scripts/verificar_bom.py` imprescindibles para que la guarda
sea confiable:

- Excluye directorios ocultos salvo `.github` → `.kilo/worktrees/phase-judge/`
  metía **463** "BOM" que no son del repo versionado.
- Exclusión de carpetas **case-insensitive** (conviven `Obsoletos/` y `OBSOLETOS/`).
- Excluye `Godot/` (user:// runtime). `m87_val_bom.po` es el BOM **legítimo**:
  es el fixture del validador `.po`.

Limpieza: 9 `.gitkeep` versionados tenían BOM y nadie los veía (`.gitkeep` no
está en la lista de extensiones). Ahora vacíos.

**Verificación:** simulación sobre `git ls-files` → **0 versionados con BOM**
→ exit 0. Quedan 4 BOM versionados, todos en
`Obsoletos/encoding-backup-20260902_014555/` (respaldo histórico: se preserva).

---

## B5 — Auditoría de autoría Blender (Log 1188)

Inventario de `tools/mcp/blender-mcp`: **126** `crear_*.py`, **16** módulos con
`.blend`.

| Hallazgo | Cantidad |
|---|---|
| Huérfanos reales (script sin asset) | **2** |
| Duplicados | **2 pares** |
| `.py` viviendo dentro de `game/` | **42** |

**Huérfanos reales:** `50-Vegetacion/crear_hierba_alta_lowpoly.py` y
`scripts-reutilizables/crear_jugador_voxel.py`.

**Falsos positivos** (documentados para no re-auditarlos): `crear_roca_lowpoly`
(su salida es `roca_comun`), `crear_decoracion_tienda_batch` (batch),
`crear_cultivo_etapa_lowpoly` (parametrizado), `crear_catalogo_npcs` (catálogo).

**Duplicados medidos:**
- `crear_casa_01_choza.py` **byte-idéntico** (sha `6b02317ff9f04260`, 1157 líneas)
  en `CASA_01_CHOZA/BAJA/` y `CASA_02_CASA_MEDIANA/BAJA/` → **reportado a MiMo**
  (`Mensajes entre modelos/2026-10-02_17-17-31_2-HY4-M18BIS-script-duplicado.md`).
  No se tocó: M18-BIS es de MiMo.
- `crear_luna.py`: `NPC_SCRIPTS` (1087) vs `scripts-reutilizables` (1102).
  Diff = 14 líneas de cabecera + 1 blanca. Código idéntico.

### ⚠️ Trampa nueva (61) — un detector que da 100 % está roto

El primer cruce dio **126 huérfanos de 126**. Causa: el normalizador del
nombre del blend no quitaba el sufijo `_lowpoly`, así que
`crear_monton_ramas_lowpoly.py` nunca podía coincidir con
`monton_ramas_lowpoly.blend`. Corregido → 8, y de esos 8 solo 2 eran reales.
**Regla:** si un detector marca todo, sospechar del detector antes que del repo.

### REAUDITADO 2026-11-04 (B9, Log 2310) — corrección del propio B5

- **Los «2 huérfanos reales» son 0.** El detector buscaba solo `.blend`:
  `crear_jugador_voxel.py` exporta **GLB directo** y su GLB está versionado;
  `crear_hierba_alta_lowpoly.py` vive en `50-Vegetacion/scripts/` (no en la
  raíz del módulo) y tiene 3 `.blend` + GLB + ficha. No hay que generar nada.
- Los `.py` de `game/` eran **65**, no 42: crecieron 23 entre el 2-oct y el
  4-nov. 22 se relocalizaron (sin borrar) y quedan 43 congelados por guardia.
- Ver §B9 para el criterio de selección, el manifiesto y las guardias en rojo.

### Pendiente (requiere dueño o Blender MCP)

- MCP de Blender caído en esta sesión → **no se generó ningún asset** (ya no
  hace falta para los ex-huérfanos).
- 29 scripts de autoría Blender siguen en `game/scripts/` (territorio M36/M50):
  moverlos en bloque requiere actualizar 13 rutas citadas en documentación.
- H-1 (localización duplicada) sigue abierto.

---

## B6 — Artefactos documentados inexistentes (Log 1189)

Auditoría: ¿la documentación de `plan-actual` cita rutas que no existen?
**2763 referencias** escaneadas en 169 carpetas.

| Clase | Cantidad | Significado |
|---|---|---|
| A | **1529** | la ruta resuelve exactamente — correctas |
| B | **147** | nombre base existe en otra ruta — doc desactualizada |
| C2 | **515** | candidato parecido (`difflib`) — renombrado/reubicado |
| C1 | **572** | sin coincidencia — **artefacto ausente** |

**28 módulos marcados ✅ citan artefactos ausentes.** Peores:
M112 (25, incluido el framework GUT completo que nunca se usó), M154 (18),
M122 (7), M123 (6), M82 (6), M81 (5), M11 (4).

**Acción:** 2 marcas `_ (diseno heredado) _` donde el `[x]` cita un `.cs` de
Unity que no puede existir (M118 `BuildScript.cs`, M81 `DataSanitizer.cs`).
**No se volteó ningún `[x]`** — eso es §21.8, perfil Hy4 excluido.

### Falsos positivos (no re-auditar)

- **M26 Templo** — sus 5 rutas `.cs` ya están explicadas por un bloque
  `Diseno original NO implementado (rutas muertas)`. El detector es ciego al
  contexto.
- **M106 Seguridad** — `security/X.gd` no resuelve, pero **existe** como
  `scripts/security/security_X.gd` (los 8). Deriva de prefijo.
- **Módulos sin implementar** (M120/121/125/150/90/91/58…) — sus rutas son
  intención de diseño: ≈1030 de las 1314 menciones "rotas".

### ⚠️ Trampa nueva (62) — tres bases antes de creer un "roto"

Probar `raíz repo` · `game/isla-ancestral/` · `game/isla-ancestral/scripts/`;
separar "ausente" de "renombrado" con `difflib`; y descartar módulos no
implementados cruzando `CHECKLIST-GLOBAL.md`. Sin esos cuatro filtros el
número (1577) es indistinguible del real.
**Regla:** un "roto" sólo es hueco si el módulo está cerrado **Y** el nombre
base no aparece en ningún lado del repo.

### B0 — BOM: regresión recurrente (commit `0abeab6`)

Tras cerrar 509 → 0, volvieron a aparecer **13** con BOM (12 scripts de
`atria-dawn-s2/scripts-prueba` + 1 log). Limpiados en disco (diff 1:1, sólo
los 3 bytes `EF BB BF`). Confirmación: **0 BOM** tras el commit.
El BOM lo siguen regenerando otros agentes → el job `encoding-guard` de CI
(`a0dd230`) es ahora la red de contención.

---
