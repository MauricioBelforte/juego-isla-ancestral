# Log 906 — BUG-039: `generar_checklist_global.py` destruía `CHECKLIST-GLOBAL.md`

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-15
**Tipo:** Bug transversal (infraestructura de coordinación multiagente)
**Severidad:** Alta — pérdida de datos en la "única fuente de verdad" del proyecto
**Estado:** [x] Resuelto y verificado

---

## 1. Cómo apareció

El ciclo anterior (Log 905, M124) cerró bien. Al ir a registrar la fila 124 verifiqué el
archivo y noté que la fila decía `10/106` cuando el `05-Checklist.md` ya estaba en `81/106`.
Antes de tocar nada hice lo que manda la regla del proyecto — **contar antes de creer**:
una auditoría de las 158 filas numéricas contra el conteo real de cada
`05-Checklist.md` (`- [x]` + `| [x] |`) dio **104 desajustes (66 %)**.

Casos propios, ya liberados y con log firmado, que habían vuelto a su estado **pre-ciclo**:

| Módulo | Fila decía | `05-Checklist.md` real | Log del ciclo |
|---|---|---|---|
| M27 Islas-Del-Mundo | `9/171` · `🟡 Con dudas` · dueño `deepseek-v4-flash-vision-exp` | `83/192` | 831 |
| M68 Transporte-Y-Navegación | `0/131` · `🟡 Con dudas` · agente `—` | `36/131` | 828 |
| M87 Localización | `90/136` · `🟡 Con dudas` · **fila malformada** (faltaba una columna) | `120/136` | 874 |
| M116 Instalador | `91/198` | `198/198` | 877 |
| M123 Modding | `20/106` | `108/108` | 879 |

**Mientras investigaba, el generador corrió en vivo** (01:11:31) sobre el archivo y el daño
quedó registrado en su propio backup automático
`scripts/backups/CHECKLIST-GLOBAL_20260915_011131.md`.

## 2. Causa raíz — cuatro defectos, todos medidos

1. **Reescribe el archivo completo desde una plantilla fija** (un f-string con título +
   tabla + simbología + resumen). Todo lo que no está en la plantilla se pierde:
   **119 693 B → 85 123 B (−34,5 KB)**. Borró:
   - `> ⛔ CODIFICACIÓN UTF-8 OBLIGATORIA` (la regla de AGENTS.md §28),
   - `### Flujo para modelos nuevos (SIEMPRE empezar acá)` — los 6 pasos de onboarding,
   - la nota `> **Columna "Recom":** …`.

2. **Elimina la columna `Recom`** (plantilla de 10 columnas sobre archivo de 11). Como el
   lector mapea columnas **por posición** según el encabezado existente, cada corrida
   desplaza `Agente actual ← Recom`, `Última actividad ← Agente actual`, `Notas ← Última
   actividad`, y pierde la nota de las filas que no traían `Recom`.

3. **El fin de la tabla se detectaba con "primera línea que no empieza con barra vertical".**
   Hay filas cuya Nota continuó en una línea huérfana — por ejemplo el sello de QA de M114
   (` 🔵 Verificado por Hy3/WorkBuddy (Log 866, §21.8): test_playlist_m114.gd EXIT 0`).
   El corte dejaba **el resto de la tabla** dentro del "sufijo", que se anexaba tal cual:
   **303 filas numéricas en vez de 167** (duplicadas) y **220 650 B**.

4. **`Path.write_text()` sin `newline=` traduce el salto de línea a `os.linesep`** → en
   Windows convertía en silencio un archivo **LF** en **CRLF**.

## 3. Fix aplicado (`scripts/generar_checklist_global.py`)

| Antes | Después |
|---|---|
| `contenido` = f-string con plantilla fija | `leer_estructura_existente()` → `(prefijo, encabezado, separador, cuerpo, sufijo)`; prefijo y sufijo se **conservan literales** |
| fin de tabla = primera línea que no empieza con barra vertical | fin de tabla = **siguiente encabezado markdown (`#`)** |
| encabezado/separador hardcodeados (10 columnas) | **heredados del archivo existente** (11 columnas: `Recom` sobrevive) |
| `split` posicional | `split("|", ncols-1)` + `parsear_filas()` que **reengancha líneas huérfanas** a las Notas de la fila anterior |
| filas sin `05-Checklist.md` desaparecían | se **conservan** (avisa cuántas) |
| `Estado` siempre recalculado | se **conserva la anotación manual** si el emoji coincide (`🟡 Liberado (Log 831)` ≠ `🟡 Con dudas`) |
| `write_text(encoding="utf-8")` | `write_text(..., newline=salto)` con **salto detectado** del archivo |

## 4. Verificación

| Comprobación | Antes | Después |
|---|---|---|
| Filas numéricas | 303 (duplicadas) | **167**, sin duplicados, bloque contiguo 30–196 |
| Columnas por fila | 8/10/11/12/13/14 mezcladas | **11 uniformes** |
| Secciones de encabezado | 0 de 3 | **3 de 3** |
| Desajustes `Progreso` vs `[x]` real | 93 | **0** |
| Fin de línea | LF→CRLF | **LF** |
| BOM / U+FFFD | — | `bom=False` · `fffd=0` (§28) |
| Filas propias (27/68/87/124) | desplazadas | intactas en `Recom`/`Agente`/`fecha`/`Notas` |

Comando: `python scripts/generar_checklist_global.py`
Salida: `Módulos: 167 | Columnas: 11 | Salto de línea: LF` · `10398/23969 (43.4 %)`
Archivo final: **119 081 B**, 222 líneas.

## 5. Trabajo colateral

- Restauré `CHECKLIST-GLOBAL.md` desde `scripts/backups/CHECKLIST-GLOBAL_20260915_011131.md`.
- Reescribí las filas **27, 68 y 87** (registros perdidos, reconstruidos desde el
  `05-Checklist.md` del módulo — que es la fuente de verdad — y desde los logs 831/828/874).
- Registré **BUG-039** en `DOCUMENTACION/11-BUGS.md` (tabla resumen + sección detallada +
  historial de modificaciones).
- Detecté de paso que **104 de 158 filas** tenían la columna `Progreso` desactualizada;
  la regeneración las dejó en **0 desajustes**.

## 6. Hallazgo secundario (no resuelto, es de otros)

El archivo tenía **anchos de fila mezclados** (8, 10, 11, 12, 13 y 14 columnas) porque
distintos agentes editaron filas a mano con esquemas distintos. La regeneración lo
normalizó a 11 columnas, pero **los valores de `Prioridad`/`Complejidad` de algunas filas
ya venían corridos** antes de este bug (p. ej. M19 tiene `glm-5.3-flash` en `Prioridad`).
Eso no lo toqué: requiere revisar fila por fila con su dueño.

## 7. Lección transversal

> Un archivo que dice "**Generado por script**" sólo es confiable si el script **preserva
> lo que no le pertenece**. Nunca regenerar desde plantilla un archivo que otros agentes
> editan a mano: leer la estructura existente, reemplazar sólo las columnas calculadas y
> conservar el resto byte a byte.

**Firma:** DeepSeek-V4.1-Flash / WorkBuddy
