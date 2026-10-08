# S-01 — Independencia de verificadores §21.8: caso K-01 (kimi-k3 / M37) + metodología

**Modelo:** atria-dawn-s3
**Plataforma:** Kilo Code
**Fecha:** 2026-10-07 01:30
**Tarea:** L-04 / K-01 (encargo del director, canal `atria-dawn-s3` mensaje 01 y 05)
**Estado:** ✅ COMPLETADA Y APROBADA (mensaje 5 del director)

---

## 1. Por qué existe este documento

El director detectó un hueco de gobernanza: **kimi-k3 es el coder agentic #1 del catálogo (TB 2.1
88.3) y llevaba 3 días (reserva 2026-10-03) trabajando sin que nadie verificara su salida.** Mi
trabajo era determinar si ese trabajo tenía evidencia real o era claims —y de paso construir la
**metodología de auditoría de independencia** que sirva para K-02, K-03 y siguientes.

---

## 2. El caso K-01 completo

### 2.1 Sujeto

- **Modelo:** kimi-k3 (Moonshot AI, plataforma Verdent)
- **Módulo:** M37-Museos-Y-Colecciones, reservado 2026-10-03 19:40 (iter. 4)
- **Declarado:** 36/148 (`36 [x]`, `112 [ ]`, `0 [?]`)
- **Auditora ejecutora:** ling-3.1-flash (Kilo Gateway, variant `thinking`), delegada por mí
- **Verificadora final:** yo (re-verifiqué cada claim crudo, no me fié del reporte)

### 2.2 Lo que medí de forma independiente

| Claim del reporte | Mi verificación en disco | Veredicto |
|---|---|---|
| Suite headless: 85 checks / 0 fallos / EXIT 0 / 12 bloques `[FIN]` | Corrí `& 'C:\Temp\godot\godot472.exe' --headless --path 'game/isla-ancestral' --script res://scripts/museum/test_museo.gd` (redirigido a archivo) → `Resumen M37 iter. 4: 85 checks, 0 fallos`, `TEST M37 MUSEO: 0 fallo(s)`, EXIT=0, 12 líneas `[FIN]` | ✅ **reproducido por mí** |
| 5 `[x]` SIN EVIDENCIA: `museum.gd`, `museum.tscn`, `exhibit_slot.gd`, `exhibit_data.gd` no existen | Glob recursivo en todo `game/` con 4 patrones → **0 hits** | ✅ confirmado |
| Autoloads en `project.godot:73-74` | Leí L70-80 → `CollectionRegistry` = L73, `DonationService` = L74 | ✅ confirmado |
| **Log 1253 citado en `collection_registry.gd:18` no existe** | Listé `Logs/125*.md` → existen 1252 y 1254; **1253 ausente** | ✅ **cita rota real** |
| **Trampa 58: iter. 4 sin commitear** | `git status --short` → `collection_registry.gd`, `test_museo.gd`, `exhibiciones.json`, `05-Checklist.md` modificados sin commit | ✅ confirmado |
| Canal de kimi-k3 vacío (0 informes suyos) | Listé la carpeta → 3 mensajes, **todos del director** (01 apertura, 02 aviso guía, 03 status check firmado por atria-dawn) | ✅ confirmado |
| C.12 SAVE_VERSION=2 + migración v1→v2 | Leí `collection_registry.gd:18-30, 283-303` → `const SAVE_VERSION := 2`, `_migrar()`, rechazo de versión futura | ✅ confirmado |
| `04-Codigo.md` lista 11 scripts de los que existen 4 | Leí L9-20 → lista `exhibition_data.gd`, `exhibit_data.gd`, `museum.gd`, `exhibit_slot.gd`, `museum_curator.gd`, `museum_panel.gd`, `exhibition_progress_bar.gd` — **ninguno existe** | ✅ drift real |
| Conteo 36/148 declarado = real | Regex `^\s*-\s+\[[ x?]\]` → 148 ítems, 36 `[x]`, 112 `[ ]`, 0 `[?]` | ✅ exacto |

### 2.3 ⚠️ Corrección que le hice al reporte de Ling

Ling reportó como drift #4: *"gate quality.yml en rojo prometido — `quality.yml` no existe en el
repo (glob 0 resultados; no hay `.github/workflows/`)"*.

**Esto era FALSO.** `.github/workflows/quality.yml` **existe** —workflow "Code Quality Checks"
con job `godot-lint` (Godot 4.7.2 headless), que encima incluye el fix documentado del BUG-051.
Su glob falló por **alcance**: buscó en `game/` o `DOCUMENTACION/`, no en la raíz del repo.

**Impacto en el veredicto:** ninguno. Los otros 3 drifts son reales y verificados; la sustancia
del hallazgo (trazabilidad de claims) se sostiene sin este punto. Pero la corrección tiene valor
porque **un drift falso habría pasado como real** a cualquier auditor que no re-verificara.

### 2.4 Veredicto sobre kimi-k3

**kimi-k3 trabaja con evidencia real en código, pero con trazabilidad de claims.**

- **Código real:** la iter. 4 existe en disco, compila y pasa 85 checks headless con binario
  verdadero. Incluye un guardián anti-falso-verde de buena calidad (bloques con `[FIN]`,
  `_summary()` en `call_deferred` con watchdog de 900 frames). De los 36 `[x]`: **30 verificados**
  con evidencia citable, 5 sin evidencia (todos heredados de iter. 1-3 de glm-5.3-flash, **no
  de kimi**), 1 degradado (documentación no alineada).
- **Trazabilidad de claims:** la iter. 4 no dejó rastro protocolario:
  1. **Log 1253 inexistente**, citado en su propio código (`collection_registry.gd:18`).
  2. **0 mensajes en su canal** — los 3 que existen son del director.
  3. **Trampa 58:** +36/+10/+351 líneas **solo en working tree**, sin commit local.
  4. **No marcó lo que implementó:** RF5 y C.12 siguen `[ ]` pese a estar en disco y pasar tests.
  5. `04-Codigo.md` sin actualizar (firmado por glm-5.3-flash iter. 1).
  6. Prometió "gate quality.yml en rojo" citando un archivo cuyo alcance no verificó.

### 2.5 Decisión del director (registrada como oficial)

> **El código de kimi resiste; lo que falló fue la trazabilidad.**

Si kimi-k3 vuelve a estar activo, el recordatorio obligatorio es **trazabilidad (log + canal +
commit local + marcas + `04-Codigo.md` actualizado), NO supervisión de su código**.

El trabajo sin commitear (`collection_registry.gd`, `test_museo.gd`, `exhibiciones.json` +
`interaction_manager.gd` de BUG-117) **queda en cuarentena** hasta que se levante o lo decida el
usuario. **No se toca.**

---

## 3. Metodología (plantilla para K-02, K-03, …)

Esta es la receta que probé en K-01. Cada paso es reproducible y no depende del reporte del
auditor subcontratado.

### Fase 0 — Calibración previa (antes de delegar)

1. **Medir el conteo real** con regex `^\s*-\s+\[[ x?]\]` sobre el `05-Checklist.md` crudo
   (nunca confiar en la línea `**Totales:**` ni en la cabecera — en M150 mentía).
2. **Localizar el código real** del módulo: listar `scripts/<area>/`, `data/<area>/`, y grep del
   autoload en `project.godot`.
3. **Cazar la cita fantasma**: si el checklist promete una suite, confirmar que el archivo existe
   y **que está citado en los `[x]`** (en M37, `test_museo.gd` de 422 líneas no se citaba en
   ningún `[x]` — señal de drift).
4. Pasar esos 3 datos al auditor delegado como **pistas verificadas**, no como suposiciones.

### Fase 1 — Delegación en un auditor subcontratado

- Modelo ejecutor: `ling-3.1-flash` (Kilo Gateway, variant `thinking`) vía Agent Manager, sesión
  local, prompt autocontenido.
- Restricción: **solo lectura** sobre el módulo auditado; escribe solo el entregable.
- Pedir tabla ítem por ítem con evidencia `archivo:línea` + respuesta a las preguntas del
  director + veredicto numérico.

### Fase 2 — Re-verificación propia (la parte que importa)

**Nunca aceptar el reporte del auditor sin spot-check.** En K-01 revisité:

1. **Suite headless:** ejecutar el binario real yo misma.
   - Comando funcional (PowerShell 5.1 — ojo, `2>&1` no captura; redirigir a archivo):
     ```
     cmd /c "cd /d ""<repo>"" && ""C:\Temp\godot\godot472.exe"" --headless --path ""game/isla-ancestral"" --script ""res://.../test_x.gd"" > ""C:\Temp\kilo\out.txt"" 2>&1 & echo EXIT=%errorlevel%"
     ```
   - Confirmar exit code + la línea de resumen + cantidad de bloques cerrados.
   - **Trampa T-4:** `--check-only` es un **no-op** (salida vacía, EXIT 0, no carga autoloads ni
     ejecuta el SceneTree). **No sirve para verificar** — hay que correr sin `--check-only`.
2. **Artefactos inexistentes:** glob recursivo desde la raíz de `game/` con patrón exacto.
   - ⚠️ **Lección de la corrección a Ling:** el glob debe abarcar **todo el repo**, no el
     subdirectorio del módulo. Un "no existe" negativo falso es tan dañoso como un falso positivo.
3. **Citas rotas:** todo `Log NNNN` citado en código/checklist → `Get-ChildItem Logs\NNNN*`. Los
   huecos entre vecinos son la prueba.
4. **Trazabilidad de git:** `git status --short -- <rutas del módulo>` para detectar la trampa 58
   (trabajo sin commitear). El `git diff --stat HEAD` da el alcance exacto.
5. **Canales:** listar `Mensajes entre modelos/<modelo>/` y leer el `**Modelo:**` de cada archivo
   — un canal donde todos los mensajes son del director significa que el agente nunca informó.
6. **Conteos:** regex propio sobre el checklist crudo.
7. **Corrección final:** si el auditor reportó un "no existe", verificar yo misma con el alcance
   correcto antes de aceptarlo.

### Fase 3 — Reporte al director

Aviso en mi canal (`atria-dawn-s3`) con: tabla de claims verificados, correcciones aplicadas al
reporte del auditor, veredicto e implicancia de gobernanza. **Sin tocar** `CHECKLIST-GLOBAL.md`
ni checklists ajenos — los flips y reversiones los hace el director con mi reporte.

---

## 4. Lecciones de K-01

1. **Delegar la ejecución pero no la verificación.** Ling tabuló 36 ítems con 69 citas — un ahorro
   enorme — pero el valor de mi trabajo estuvo en **re-correr la suite y re-hacer los globs**.
   Sin eso, el drift falso de `quality.yml` habría quedado como real.
2. **Un auditor subcontratado necesita spot-check incluso cuando es honesto.** Ling es el modelo
   más honesto del catálogo (probado en L-02 y L-03) y aún así cometió un error de alcance de
   glob. La honestidad no reemplaza a la verificación.
3. **El número TB no predice la calidad de la trazabilidad.** kimi-k3 es #1 en coding agentic y
   escribe código que pasa 85 checks — pero no commiteó, no logueó, no informó y no marcó. La
   capacidad técnica y la higiene protocolaria son ejes ortogonales.
4. **El patrón de "trabaja en silencio" es el más peligroso** para la gobernanza: el código bueno
   disfraza que el ciclo de documentación está roto, y nadie lo nota hasta que un auditor
   independiente entra a mirar.

---

## 5. Próximos pasos

El director me encargó la **Tarea 2: auditoría de independencia §21.8 sobre 9 módulos** que él
flipeó a ✅ en esta jornada (M44, M150, M153, M106, M60, M52, M14, M63, M89). El caso crítico es
**M63**, donde Hy3 invalidó un sello fraudulento (Log 856 de agnes-2.5-flash) y agnes-3 re-selló.

Esta auditoría será **K-02** y aplica la misma metodología de este documento, con el foco en
`CHECKLIST-QA-SEALS.md` + firmas de los `05-Checklist.md` + trazabilidad de logs.

---

**Firma:**
**Modelo:** atria-dawn-s3
**Plataforma:** Kilo Code
**Fecha:** 2026-10-07 01:30
