# Specs de dudas — ítem 68 del BACKLOG (módulos ✅→🟡 por `[?]`, subida documental)

**Agente:** Step-5-WorkBuddy · **Fecha:** 2026-10-18 · **Evidencia:** Log 1968
**Tarea:** "Preparación de specs para módulos ✅→🟡 por `[?]` (subida documental) — 8 [M]"
**Alcance de la tanda:** medición del universo + especificaciones preparadas para los `[?]`
resolubles por documentación. **Sin flips de marca** (los propone el director; §21.8).

---

## 1. Universo medido (2026-10-18, por prefijo de línea sobre `05-Checklist.md`)

- 168 módulos con checklist.
- **101 módulos tienen al menos un `[?]`** (1.152 ítems `[?]` en total).
- De esos 101: **53 no tienen ningún `[ ]`** (módulos funcionalmente completos, frenados
  solo por dudas = el blanco exacto de esta tarea; 783 `[?]`) y **48 tienen además `[ ]`**
  (trabajo real pendiente; 369 `[?]`).

> **Autocorrección honesta (Patrón D):** mi primer contador de `[ ]` usaba `(m)^- \[ \]`
> en lugar de `(?m)` — medía 0 en todos los módulos. Lo detecté al cruzar con el bloque
> `## Totales` de M68 (18 `[ ]` reales). Los contadores de `[x]` y `[?]` sí usaban `(?m)`
> y son correctos. La partición 53/48 de arriba está medida con el regex corregido.

## 2. Clasificación de los `[?]` (muestreo de 65 ítems leídos en 33 módulos)

| Clase | Significado | Módulos del muestreo |
|---|---|---|
| **A — spec/documentación** | La duda se cierra escribiendo/verificando documentación | M126, M3, M123, M52 (2 de 3), M73, M2 |
| **B — dependencia externa con dueño** | Falta otro módulo o acción humana | M29, M56, M50, M66, M77, M87 (5), M96, M89, M30, M13, M147, M141, M149, M83, M78, M86 |
| **C — contenido/implementación** | Falta código o contenido (no es spec) | M148, M52 (1), M109 (3), M60, M24 |
| **D — revertido por sobre-cierre (BUG-070 / Familia A)** | El ítem pide Implementar/Crear y el artefacto no existe | M80 (2), M81 (2), M85 (2), M82 (5) |

**Lectura para el director:** la clase A es la que ataca esta tarea. Las clases B/C/D
necesitan dueño o código — subir documentación ahí sería maquillaje (la lección de la cita
fantasma: si la sección falta, hay que escribirla con la norma real, no inventar la cita).

## 3. Specs preparados

### 3.1 M126 — artefacto CREADO (única entrega en disco de esta tanda)

- Ítem: `plan-actual/05-Checklist.md` L90 `- [?] Diseñar legal/marketing_legal_review.md`
  ("ARTEFACTO INEXISTENTE (director 2026-10-12, barrido Step 5 msg 250)").
- **Creado `legal/marketing_legal_review.md`** (7.073 B, 134 LF, UTF-8 sin BOM, 0 FFFD),
  con la estructura de la plantilla de `03-Diseno.md` §2 y el contenido reconciliado contra
  los datos reales del repo: `data/legal/marketing_legal.json` (políticas),
  `data/legal/audio_licenses.json` (3 pistas: propia / CC-BY / CC0),
  `data/legal/identidad_marca.json` + `legal_data.json` (fuentes OFL 1.1; 4 `.ttf` en
  disco), `data/legal/copyright.json` + `legal/copyright_register.md` (7 elementos; logo
  pendiente de registro), `THIRD-PARTY-NOTICES.md` (Godot MIT + Voxel Tools).
- **Hallazgo honesto que el artefacto deja documentado:** la plantilla declaraba
  "Blender (GPL), GIMP (GPL)" pero `THIRD-PARTY-NOTICES.md` tiene **0 menciones** a
  Blender/GIMP (medido) → pendiente M126/M06. Igual: el clearance de marca solo cubre
  USPTO (M78 L95 `[?]`, EUIPO/WIPO/INPI sin cobertura).
- **Propuesta de flip (la aplica el director):**
  `- [?] Diseñar legal/marketing_legal_review.md ...` →
  `- [x] Diseñar legal/marketing_legal_review.md — creado 2026-10-18 (Step-5-WorkBuddy,
  Log 1968): revisión por áreas con estados ✅/⏳ y citas a data/legal/*.json;
  pendientes humanos (contratos, registro de marca, EUIPO/WIPO/INPI) como KnownIssue
  con dueño.` Con el flip, M126 queda **101/101** y podría volver a ✅.

### 3.2 M3 — uplift propuesto (texto listo, NO aplicado)

Los 3 `[?]` (L67/L68/L69) fueron REVERIFICADOS el 2026-10-15 por step-5-kilocode con las
respuestas ya escritas en las notas; lo que falta es **subirlas al documento**. Raíz real
medida hoy (16 carpetas): `DOCUMENTACION/ Logs/ Mensajes entre modelos/ Obsoletos/
PAPELERA/ build/ docs/ game/ installer/ legal/ out/ scripts-prueba-temp/
scripts-reutilizables/ scripts/ tools/` + archivos de raíz (`AGENTS.md`, `README.md`,
`CHECKLIST-GLOBAL.md`, `CHECKLIST-QA-SEALS.md`, `CHANGELOG.md`, `CONTRIBUTING.md`,
`LICENSE`, `NOTICE.md`, `ASSETS-LICENSE.md`, `AUTHORS.md`, `THIRD-PARTY-NOTICES.md`).

Texto propuesto para `DOCUMENTACION/README.md` (sección nueva "Estructura de la raíz del
repositorio"), que cierra L68 y contesta L67 (las carpetas Unity citadas no aplican: el
proyecto es Godot — AGENTS.md §24, todo el código es GDScript) y L69 (la regla de no
crear logs de runtime ya está en AGENTS.md §18; los logs van a `Logs/`):

> ### Estructura de la raíz del repositorio
> La raíz tiene 16 carpetas: documentación y metodología (`DOCUMENTACION/`,
> `docs/` — material complementario, ver AGENTS.md §3), operación del protocolo
> multiagente (`Logs/`, `Mensajes entre modelos/`), código y datos del juego
> (`game/isla-ancestral/`), legal (`legal/`), herramientas (`scripts/`,
> `scripts-reutilizables/`, `tools/`), distribución (`build/`, `installer/`) y
> áreas de trabajo/archivo (`Obsoletos/`, `PAPELERA/`, `out/`,
> `scripts-prueba-temp/`). **NO existen** las carpetas Unity `Assets/`, `Builds/`,
> `Epics/`: el motor es Godot 4.7.2. Los logs del protocolo se escriben **solo** en
> `Logs/` (AGENTS.md §18); ningún runtime crea archivos de log adicionales dentro de
> carpetas de código o assets.

### 3.3 M73 — verificación HECHA (el `[?]` L215 queda con evidencia, sin flip)

- Medido: `plan-inicial/05-Checklist.md` = **130 ítems exactos**, todos `[ ]`
  (0 `[x]`), con una cabecera que miente: "**130/130 completados**" — la familia del
  defecto M79-L7 (afirmación infalsable contradicha por las marcas).
- `plan-actual/05-Checklist.md` = **135 ítems** (26 `[x]` / 2 `[?]` / 107 `[ ]`).
- **Respuesta a la verificación pendiente del ítem:** plan-inicial **NO** es igual a
  plan-actual (130 vs 135; 5 ítems de diferencia) y `plan-inicial` es NO MODIFICAR por
  convención → la igualdad que pedía el ítem es inalcanzable por diseño.
- **Propuesta al director:** el ítem se satisface como *"confirmado por medición"* y se
  declara la no-igualdad; si se prefiere, cerrar como "no aplica por diseño" (mismo
  criterio que el director aplicó a M2, msg 246). La cabecera falsa de plan-inicial se
  reporta al dueño del módulo (M73 no tiene agente activo).

### 3.4 M52 — dos decisiones de spec listas (no aplicadas; módulo sin dueño activo)

Medido 2026-10-18: `git grep VfxManager` sobre `*.gd`/`*.tscn` = **0 hits**;
`git ls-files "*validate_vfx*"` = **0**; `project.godot` no registra autoload VFX; los
archivos reales son `scripts/particles/{vfx_director,vfx_factory,vfx_pool,vfx_schema,
vfx_trigger,vfx_loops}.gd` + 5 suites (QA §21.8 por agnes, Log 1030).

- **L60 (`Definir VfxManager (autoload)`):** decisión propuesta — **no registrar
  VfxManager**: el rol lo cumple `vfx_director.gd`, invocado por `vfx_trigger.gd`
  (bus de eventos), sin autoload. Evidencia: 0 referencias y 0 autoload; el patrón del
  proyecto para VFX es director + pool, no manager global.
- **L144 (`Definir validate_vfx.gd`):** decisión propuesta — **no crear el archivo**: la
  validación real ya existe repartida (`vfx_pool.gd` → `validar_semillas()`,
  `vfx_schema.gd`, `gen_vfx_catalog.py --check` con 31 entradas verificado por el QA).
  Un `validate_vfx.gd` sería un validador vacío (familia trampa 20/91).
- **L242** (catálogo por evento M44/M92) es clase C: dueño externo
  (deepseek-v4-flash-vision-exp) — fuera del alcance documental.

### 3.5 Otros `[?]` clasificados con evidencia (para la cola del director)

- **M118 L199**: no es doc-fixable — exige una corrida real de GitHub Actions (la nota de
  agnes ya documenta la validación en `03-Diseno.md` §4.1). Se mantiene `[?]` hasta el
  primer run verde en `main`.
- **M29 L75 y L207**: **el mismo `[?]` está duplicado** ("Flecha indicadora en el HUD",
  dueño M53) — al resolverlo, resolver las dos líneas o el conteo queda inflado.
- **M2**: "Copiar plan-inicial → plan-actual" fue invalidado por el director (msg 246):
  `plan-inicial` es NO MODIFICAR y `plan-actual` no debe ser idéntico → cerrar por
  invalidación, no por flip.
- **M123 (2 `[?]`)**: las citas `03-Diseno.md §1.2`/`§1.3` son fantasmas (Patrón C). La
  reparación honesta es **escribir las secciones** (vista de previsualización del paquete;
  re-evaluación del gate tras el tracking) — spec de clase A que preparo en la próxima
  tanda si el director la asigna (el módulo tiene QA §21.8 de Ling 3.1 Flash).
- **M80/M81/M85/M82 (11 `[?]`)**: revertidos por BUG-070 / Familia A — piden
  Implementar/Crear y el artefacto no existe (grep en negativo). Son clase D: necesitan
  código, no documentación.

## 4. Pendientes para el director

1. Aplicar (o no) el flip de **M126 L90** → M126 101/101 (propuesta en §3.1).
2. Autorizar el uplift de **`DOCUMENTACION/README.md`** con el texto de §3.2 (cierra
   M3 L67/L68/L69).
3. Decidir el cierre de **M73 L215** por medición vs. invalidación por diseño (§3.3).
4. Encargar (si corresponde) dueño para las decisiones de spec de **M52** (§3.4) y para
   las secciones fantasma de **M123** (§3.5).
5. Commit de `legal/marketing_legal_review.md` (1 path, nuevo, sin BOM, LF) + Log 1968 +
   este documento + mensaje 75 + BACKLOG-MASTER + tracker.

## 5. Límites de esta tanda

0 commits · 0 push · 0 flips de marca · 0 ediciones a `CHECKLIST-GLOBAL.md`,
`quality.yml`, `AGENTS.md`, `project.godot` ni a `05-Checklist.md` de módulos ajenos.
Único archivo creado fuera de mi carpeta: `legal/marketing_legal_review.md` (ruta
nombrada por el propio ítem del checklist; verificada no-ignorada con
`git check-ignore`, rc=1; hermanos `legal/*` versionados en LF).

**Firma:** Step-5-WorkBuddy — 2026-10-18
