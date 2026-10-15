# 66 — M105: drift corregido (120/45 → 122/43 en 7 lugares) + 3 pares `[?]` a FUSIONAR · TAREA 11: 16 alertas clasificadas (0 A / 9 B / 7 C)

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 23:00
**Responde a:** atria-dawn-s3 — 65-...-m104-m156-m122-aceptados-m94-flipado-m13-tarea-11.md

Leí tu mensaje (esperé los 5 min de T-19: llegó con plantilla vacía) y procesé las 3 tareas en orden.
**Reporte único.**

---

## TAREA 8 + 12 — M105: Patrón D de `[?]` + drift + header de Totales

### 8a — Los 3 pares de `[?]`: veredicto **FUSIONAR** (READ-ONLY, los flips son tuyos)

| Par | Líneas | Sección de AMBAS | Texto |
|---|---|---|---|
| 1 | **L230 / L231** | `### [S] Integración con M22` (la misma) | "Diseñar M105 identificar capítulos donde muchos jugadores se atascan" |
| 2 | **L234 / L235** | `### [S] Integración con M102` (la misma) | "Diseñar datos de telemetría identificar bugs emergentes" |
| 3 | **L237 / L238** | `### [S] Integración con M102` (la misma) | "Diseñar M105 generar issues en M102 basados en patrones de datos" |

**Los 3 pares viven en la MISMA sección** → es el caso que describiste: *"duplicado puro: FUSIONAR igual
(degradar un `[?]` a nota sin marca, como hicimos con GDPR en M122 L185)"*.

**Matiz que cambia el detalle:** no son texto idéntico, son **el mismo ítem con dos versiones de la
nota**. Ejemplo del par 1:

- **L231** (más estricta): *"La métrica de atasco NO está diseñada en 03-Diseno.md… queda `[?]` hasta
  que exista diseño + datos"*
- **L230** (más reciente): *"patrón de detección diseñado (tiempos anormales por capítulo)… Core
  telemetría operativo"*

**Recomendación de fusión:** quedate con **la nota más estricta** (L231, L234, L237) porque es la que
 documenta el requisito pendiente con precisión; la otra pasa a nota sin marca. **Impacto aritmético:**
`[?]` **43 → 40**, `[x]` sigue 122, total 165 → **162**.

### 8b — Drift de conteo: la verdad es el disco

| Fuente | Conteo | ¿Correcto? |
|---|---|---|
| **Disco** (`^\s*-\s*\[[ x?]\]`) | **122 `[x]` / 43 `[?]` / 0 `[ ]` = 165** | ✅ |
| `CHECKLIST-GLOBAL.md` fila 105 | 122/165 | ✅ **coincide con disco** |
| Notas internas (7 lugares) | 120/45 | ❌ **stale** |

**Origen del drift:** dos ítems pasaron de `[?]` a `[x]` sin que se actualizaran las notas internas.
El total (165) nunca cambió — es el mismo patrón que M107 y M116.

### Correcciones de texto aplicadas (precedente M107)

Corregí **7 lugares**, no 2 — el drift estaba más propagado de lo que reportó mimo:

| Línea | Antes → Después |
|---|---|
| L31 | `120 [x] · 45 [?] · 0 [ ]` → **`122 [x] · 43 [?] · 0 [ ]`** |
| L77 | `[x] 120 / [ ] 0 / [?] 45` → **`[x] 122 / [ ] 0 / [?] 43`** |
| L90 | "Los 45 `[?]` no se tocaron" → **"Los 43 `[?]`…"** |
| L102 | `120 [x] / 45 [?] / 0 [ ] = 165` → **`122 [x] / 43 [?] / 0 [ ] = 165`** |
| L338 | "Ítems implementados y cubiertos por test: 120" → **122** |
| L339 | "Ítems bloqueados con dueño nombrado (`[?]`): 45" → **43** |
| L345 | `**Totales:** 165 · Completados: 120 · No resueltos: 45` → **122 / 43** |

**Verificado:** diff contra mi backup = **7 bloques, todos correcciones de número**. **Ninguna marca
tocada** (`[x]`/`[?]`/`[ ]` intactos: 122/43/0). Backup:
`Obsoletos/2026-10-10_19-46-57_05-Checklist-M105.md`.

**Nota:** el `git diff` de este archivo muestra más cambios (52/37) porque **hy3 tiene trabajo
pre-existente sin commitear** en el mismo archivo (es el verificador de hooks de M105). Mis 7 bloques
son solo texto.

---

## TAREA 11 — Alertas de `verificar_checklist.py`: 16 clasificadas

Corrí el script y tomé la lista completa. **Resultado: 0 tipo A / 9 tipo B / 7 tipo C.**

### (A) Drift real de conteo: **0**

Verifiqué los conteos de disco de los 6 módulos con estado ✅ contra GLOBAL: **los 6 cuadran
exacto**. No hay un solo número que corregir.

| Módulo | Disco | GLOBAL | ¿Cuadra? |
|---|---|---|---|
| M116 Instalador | 169/23/0=192 | 169/192 | ✅ |
| M118 CI-CD | 102/0/4=106 | 102/106 | ✅ |
| M18 Casas | 80/0/69=149 | 80/149 | ✅ |
| M24 Templos | 126/1/1=128 | 126/128 | ✅ |
| M53 UI-UX | 139/0/26=165 | 139/165 | ✅ |
| M87 Localizacion | 131/5/0=136 | 131/136 | ✅ |

### (B) Falsa alerta: **9** — el script aplica una regla de módulo a filas que no lo son

**8 son hitos de producción, no módulos de trabajo:** M137 Prototipo, M138 Vertical-Slice,
M139 Pre-Alpha, M140 Alpha, M141 Beta, M142 Release-Candidate, M143 Lanzamiento, M144
Despues-Del-Lanzamiento. Todos `🟢 Disponible` con `[x]` de **definición de hito** (entregables
planificados), no de implementación.

**M99 Marketing** entra en el mismo grupo: verifiqué sus 7 `[x]` y **todos son "Definir X"**
(test de legibilidad, SEO básico, meta de 500+ suscriptores, build de demo estable…). Diseño
documentado, módulo nunca reclamado.

**Por qué es falsa:** el script asume *"si tiene `[x]`, alguien trabajó el módulo"*. En hitos y en
M99 los `[x]` son decisiones de diseño, no trabajo. **No hay nada que corregir.**

### (C) Requiere flip de marca/estado: **7** (decisión tuya)

Todas tienen conteo correcto; lo que no cuadra es el **estado ✅ vs DoD §21.6** (que exige 0 `[?]` y
0 `[ ]`):

| # | Módulo | Deuda real | Estado GLOBAL |
|---|---|---|---|
| 1 | M116 Instalador | 23 `[?]` | ✅ Completado (QA §21.8 Ling msg 15) |
| 2 | M118 CI-CD | 4 `[ ]` | ✅ Completado (QA §21.8 s2) |
| 3 | M18 Casas | **69 `[ ]`** (80/149 = 54%) | ✅ Completado (QA §21.8 Hy3) |
| 4 | M24 Templos | 1 `[?]` | ✅ Completado |
| 5 | M24 Templos | 1 `[ ]` | ✅ Completado (misma fila, 2ª alerta) |
| 6 | M53 UI-UX | 26 `[ ]` | ✅ Completado |
| 7 | M87 Localizacion | 5 `[?]` | ✅ Completado (QA §21.8) |

**No apliqué ningún flip** — son decisiones tuyas. **M18 es el caso más extremo** (54% del módulo con
sello ✅) y ya lo había reportado en el informe del bloque 2C.

---

## Resumen

| # | Tarea | Estado |
|---|---|---|
| 8a | 3 pares `[?]` de M105 | ✅ veredicto **FUSIONAR** (misma sección) → `[?]` 43→40 |
| 8b/12 | Drift + header Totales | ✅ **7 correcciones de texto** aplicadas; 0 marcas tocadas |
| 11 | 16 alertas | ✅ clasificadas: **0 A / 9 B / 7 C** |

**Cambios en working tree (0 commits):** `DOCUMENTACION/105-Telemetria-De-Gameplay/plan-actual/05-Checklist.md`
**Pool del canal:** 115 números.
**Pendiente para vos:** los 7 flips de estado de tipo C, y los 3 FUSIONAR de M105 si aprobás el veredicto.

Listo para el próximo apilado.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 23:00
