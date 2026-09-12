# Log 860: Auditoría transversal de enlaces markdown y rutas citadas

**Fecha:** 2026-09-12
**Modelo:** Hy3 / WorkBuddy
**Plataforma:** WorkBuddy (WorkBuddy AI)

## 0. Contexto

Paso siguiente anotado en el Log 853 §7.2: *"auditar enlaces markdown
relativos (más allá de `Logs/`) , que es el siguiente nivel de referencias
cruzadas"*. Motivo: las guías se partieron (`07-GUIA-GODOT.md` →
`GUIA-GODOT/*.md`) y nadie verificó el resto de los enlaces.

Herramienta: `scripts/auditar_enlaces_md.py`, con dos modos:

| Modo | Qué audita |
|---|---|
| (por defecto) | enlaces markdown `[texto](ruta)` |
| `--rutas` | rutas citadas como **texto plano entre backticks** |

## 1. Enlaces markdown: 28 → 0

Resultado final: **0 enlaces rotos** de 63 relativos revisados en 3.107 `.md`.
Pero llegar ahí requirió corregir el auditor tres veces, y cada corrección
vale más que el número final:

### 1.1 Los bloques de código se comían al auditor

La primera pasada dio **28 rotos en 10 archivos**, casi todos falsos positivos.
Eran snippets de Godot y plantillas de prompts de Blender que contienen
`[algo](algo)`:

```
ns["color"]("PIEL")              ->  casa con  [^\]]*\]\(
Array[StringName]([&"SILLA"])    ->  idem
Array[BloqueRutina]([SubResource("Bloque_manana"), ...])
```

Dos arreglos complementarios:

1. **Quitar bloques de código cercados** (```` ``` ```` y `~~~`) e inline
   (`` `...` ``) antes de buscar enlaces. Se reemplaza por *espacios*, no se
   borra, para no desplazar posiciones.
2. **Lookbehind** `(?<![A-Za-z0-9_)\]"'])` delante de `[`, que descarta la
   indirección de arreglos: en `ns[` el corchete está precedido por `s`.

### 1.2 `.claude/` son skills instalados, no documentación del proyecto

La segunda pasada parecía haber destruido el auditor: los enlaces revisados
cayeron de 6.628 a 73. No era el limpiador de código: era que acababa de
excluir `.claude/`. Medido:

```
.claude: 954 archivos .md, 11.007 enlaces
```

Es la caché de skills instalados — 11k enlaces que no son documentación del
proyecto, y que además apuntan *entre* skills. Auditarlos genera ruido
irreparable. Excluido con el motivo documentado en el script.

### 1.3 Los 3 enlaces realmente rotos

`docs/developers/guia_desarrolladores.md` apuntaba a tres directorios que
**no existen** (`docs/` solo tiene `codigo_de_calidad`, `developers`,
`marketing`, `playtest`, `qa`, `store`):

```
[M07 Arquitectura]      -> ../arquitectura/README.md   (no existe)
[M112 Testing]          -> ../testing/README.md        (no existe)
[M61 Rendimiento]       -> ../rendimiento/README.md    (no existe)
```

Reparados apuntando a los módulos reales en `DOCUMENTACION/`:

- `../../DOCUMENTACION/07-Arquitectura-General/plan-actual/03-Diseno.md`
- `../../DOCUMENTACION/112-Testing-Automatico/plan-actual/03-Diseno.md`
- `../../DOCUMENTACION/61-Rendimiento/plan-actual/03-Diseno.md`

### 1.4 ⚠️ `docs/` está enteramente fuera del control de versiones

Al querer commitear la reparación:

```
$ git add docs/developers/guia_desarrolladores.md
The following paths are ignored by one of your .gitignore files: docs

$ git check-ignore -v docs/developers/guia_desarrolladores.md
.gitignore:110:docs/

$ git ls-files docs
(vacío)
```

**Nada de `docs/` está versionado**: `developers/`, `marketing/`, `qa/`,
`playtest/`, `store/`. La reparación de los 3 enlaces queda **solo en local**.

No se usó `git add -f`: meter un directorio ignorado al repo cambia una
política del proyecto y puede ser deliberado (por ejemplo si `docs/` fuera
generado). Lo que sí corresponde es señalarlo: hay documentación de
desarrolladores, QA y playtest que se perdería con un `git clean`.
**Decisión del usuario.**

## 2. Rutas en texto plano: el hallazgo que importa

En este proyecto **la mayoría de las referencias no son enlaces markdown** sino
`` `ruta/al/archivo.gd` `` entre backticks — 13.165 citas frente a 63 enlaces.
Es decir: auditar solo enlaces markdown habría revisado el **0,5 %** de las
referencias reales. Modo `--rutas` agregado para eso.

Resultado: **1.914 rutas inexistentes en 513 archivos.**

| Extensión | Rotas |
|---|---:|
| `.md` | 723 |
| `.gd` | 427 |
| `.cs` | 329 |
| `.py` | 115 |
| `.txt` | 79 |
| `.json` | 72 |
| otras (`.png` `.blend` `.tres` `.csv` `.ps1` `.glb` `.html` `.tscn`) | 163 |

| Plan | Rotas |
|---|---:|
| `plan-actual` (vigente) | 601 |
| `plan-inicial` (histórico) | 547 |
| otro | 766 |

### 2.1 329 rutas `.cs` en un proyecto que tiene exactamente 1 `.cs`

`find game/isla-ancestral -name "*.cs" | wc -l` → **1**. Hay 982 `.gd`.

Las 329 citas a `IslaAncestral/Core/*.cs`, `Core/StressRunner.cs`,
`EditorToolBase.cs`… son diseño escrito para C# en un proyecto que se hizo en
GDScript. Son documentación muerta: nadie va a escribir esos archivos.

### 2.2 465 rutas en planes vigentes que no son C#

Módulos cuyo `plan-actual/04-Codigo.md` describe archivos que no existen:
M140 Alpha (34), M139 Pre-Alpha (29), M81 Legal-Menores (25), M137 Prototipo
(20), M138 Vertical-Slice (20), M134 Presupuesto (15)…

Aquí la lectura es distinta: puede ser plan no implementado (legítimo) o
**checklist sobre-cerrado** (el problema que ya apareció en M68: decía
"130/130" con 0 líneas de código). Distinguirlo requiere revisar módulo por
módulo contra su DoD — eso es QA cruzado §21.8, no limpieza automática.

## 3. Por qué NO se auto-reparó nada de la sección 2

El modo `--rutas` es deliberadamente **solo diagnóstico**. Una ruta rota de
enlace se repara porque el destino existe en otro sitio; una ruta de código
inexistente no se repara con sustitución de strings: o hay que escribir el
código, o hay que reescribir el plan. Inventar el destino sería peor que la
referencia rota.

## 4. Trampas registradas (§26)

- **Quitar bloques de código antes de parsear markdown.** Sin eso, la sintaxis
  de indirección (`ns["x"]("Y")`) produce decenas de falsos positivos.
- **Un lookbehind de un carácter** (`(?<![A-Za-z0-9_)\]"'])`) resuelve lo que
  el limpiador de bloques no alcanza (código mal cercado).
- **Medir antes de creer que rompiste algo.** El desplome 6.628 → 73 parecía un
  bug del limpiador y era una exclusión de directorio. Se midió `.claude/` y
  salió la respuesta.
- **Las raíces de resolución importan.** Sin `DOCUMENTACION/` como raíz, las 39
  citas de `AGENTS.md` a `GUIA-GODOT/*.md` salían rotas cuando existían.
  Raíces usadas: dir del archivo, repo, `game/isla-ancestral/`, `DOCUMENTACION/`.
- **Auditar solo enlaces markdown es auditar el 0,5 %.** En este proyecto las
  referencias se escriben en backticks.

## 5. Archivos

- Creado: `scripts/auditar_enlaces_md.py` (modo enlaces + modo `--rutas`)
- Reparado: `docs/developers/guia_desarrolladores.md` (3 enlaces)

## 6. Próximo paso sugerido

1. Decidir qué hacer con las 329 rutas `.cs`: son candidatas a borrado o a
   nota de "diseño histórico en C#, abandonado".
2. Cruzar los módulos con rutas faltantes en `plan-actual` contra su
   `05-Checklist.md`: si el checklist dice 100 % y los archivos no existen, es
   sobre-cierre (QA §21.8).
3. Resolver los 4 casos ambiguos del Log 853 y el `Log 723` fantasma de
   `CHECKLIST-GLOBAL.md`.

---
**Firma:** Hy3 / WorkBuddy · 2026-09-12
