# Log 1817: Auditoría `[?]` M27 bloque 1 + higiene Totales M15/M16 + verificación commits atria (pendiente)

**Fecha:** 2026-10-13
**Hora:** 17:10
**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code

## Resumen

Dos encargos recibidos por canal el 2026-10-13 (msg del director 16:35 y reenvío de s3 16:45):

1. **Verificar commits de atria** (M04 iter4+5 y M35 lote 3) → resultado: **PENDIENTE**, atria aún no
   commiteó (evidencia abajo).
2. **Higiene de líneas Totales de M15/M16** (drift detectado por s2, marcas de agnes intactas) →
   **CERRADO**, commit `528cfac`.
3. **Auditoría de `[?]` con Patrón D** (10 bloques: M27, M74, M34, M11) → **bloque 1 (M27 b1)
   CERRADO**: 10 ítems verificados contra disco, 0 promociones, 10 `[?]` con evidencia anotada.

## 1. Commits de atria — PENDIENTE (no existen)

- `git log --all --oneline -- Logs/1810-*` → **vacío** (el archivo existe en disco, 5009 B, untracked).
- `git log --all --oneline -- Logs/1812-*` → **vacío** (existe en disco, 5652 B, untracked).
- `git log --all --oneline -- Logs/1814-*` → **vacío** (existe en disco, 6113 B, untracked).
- `origin/main` sigue en `edc12ca` — **sin avance**.
- Archivos de módulo de ambos lotes modificados sin commitear (`M`):
  `DOCUMENTACION/04-Game-Engine/plan-actual/{02-Analisis.md,05-Checklist.md}`,
  `DOCUMENTACION/35-Mineria/plan-actual/{04-Codigo.md,05-Checklist.md}`.
- Verificación por vía alternativa: las 3 ramas locales (`main`, `wb-m24-iter3`, `wb-m24-iter4`)
  tampoco contienen esos pathspecs; `git status` confirma `??` para los 3 logs.

## 2. Totales M15/M16 — CERRADO (commit 528cfac)

Conteo real verificado con regex por prefijo de línea antes de editar:

| Módulo | real [x]/[ ]/[?] | Totales antes | Totales después |
|---|---|---|---|
| M15-Recursos | 172 / 37 / 10 | 162 / 47 / 10 (+10 drift) | 172 / 37 / 10 |
| M16-Crafting | 155 / 36 / 13 | 154 / 37 / 13 (+1 drift) | 155 / 36 / 13 |

Solo se tocó la línea Totales (con nota del corrector); las marcas de agnes quedaron intactas.
Commit `528cfac` con pathspec explícito de los 2 archivos.

## 3. Auditoría `[?]` M27 bloque 1 (10 ítems) — CERRADO, 0 promociones

Método Patrón D (como Log 1807): grep/artifact en disco; promover `[?]`→`[x]` solo con respaldo.
**Resultado: los 10 carecen de respaldo → permanecen `[?]` con explicación de qué falta anotada
en cada línea.** Evidencia destacada:

- Carga `.tres`: sincrónica confirmada (`island_registry.gd` L73/L154, `ResourceLoader.load` directo).
- Enum `IslandPref`: no existe; capacidad equivalente sí (`TIPO_CARGA/TIPO_DESCARGA/TIPO_PRECARGA`
  en `island_ops.gd` L27-29; anillos `enum {NUCLEO,CERCANO,MEDIO,LEJANO}` en `island_ring.gd` L17).
- Signals `isla_cargando/cargada/descargada`: 0 hits; existe `signal island_loaded` sin progreso.
- Regen M10: `test_generacion_m10_atria.gd` cubre determinismo de chunks/biomas, 0 hits de ancla.
- Re-roll de anclas y log ERROR por 8 intentos: 0 hits (INTENTOS_MAX=12 es de `terreno_horizonte.gd`,
  contexto distinto).
- NPC sobre isla anclada: posicionamiento con `TerrainLocator.get_height()` (`shaman_npc.gd` L27,
  `incense_spawner.gd` L161) pero sin verificación del contrato isla-ya-anclada.

Conteos M27 antes/después: **126 `[x]` / 0 `[ ]` / 66 `[?]`** → sin cambios (solo se anotó evidencia).
Archivo modificado en working tree (sin commit a la espera de criterio del director).

## Archivos Modificados/Creados

- `DOCUMENTACION/15-Recursos/plan-actual/05-Checklist.md` (Totales; commiteado)
- `DOCUMENTACION/16-Crafting/plan-actual/05-Checklist.md` (Totales; commiteado)
- `DOCUMENTACION/27-Islas-Del-Mundo/plan-actual/05-Checklist.md` (10 `[?]` anotados; sin commit)
- `Logs/1817-...md` (este log)
- `Logs/NUMEROS_DISPONIBLES.txt` (1817 consumido)
- `scripts-prueba-temp/audit_m27_b1.py` (script de anotación, carpeta temporal del repo)

## Hallazgo adicional (para el director)

Se detectó **mojibake cp1252 en scripts .gd del juego** (comentarios con `Â§`, `Ã³`, `â€”`), ej.:
`game/isla-ancestral/scripts/world/test_generacion_m10_atria.gd` L6-8,
`scripts/islas/test_islas_m27_iter2.gd` L6. `scripts/diagnosticar_mojibake.py` quedó colgado por
timeout al escanear todo el repo; no se aplicó `fix_encoding.py` (requiere criterio del director).
