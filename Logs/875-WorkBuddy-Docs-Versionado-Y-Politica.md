# Log 875: `docs/` — se versiona y se declara su política de uso

**Fecha:** 2026-09-13
**Hora:** 17:29
**Modelo:** Hy4 / WorkBuddy
**Plataforma:** WorkBuddy (WorkBuddy AI)

> **Nota de identidad (corregida el 2026-09-13, Log 880):** este log se firmó
> originalmente como `Hy3 / WorkBuddy`. Es una atribución errónea: **Hy3 es otro
> agente**, que trabaja en **otro chat** de WorkBuddy (al igual que DeepSeek-V4.1-Flash).
> La identidad en este proyecto es **por chat, no por plataforma**: todo lo que se
> produce en un chat pertenece al modelo de ese chat. El trabajo de este log es de
> **Hy4 / WorkBuddy**. Se corrige la firma; el contenido no cambia.

## 0. Contexto

Cierre de la investigación de la carpeta `docs/` pedida por el usuario
(*"no sabemos que modelo escribió la carpeta docs? ... evaluemos eso primero"*).
Con el diagnóstico terminado, el usuario encargó cuatro acciones:

> *"versionarlo, hacer referencia a esa carpeta en los planes actuales donde se
> relacionen, aclarar en el agent que no se usa esa sino nuestra metodología,
> pero si alguien está trabajando en algún módulo que se relaciona con esas
> carpetas las puede consultar ya que es información que complementa, siempre y
> cuando no se duplique el trabajo"*

## 1. Diagnóstico previo (resumen)

- **17 archivos / 116 KB**, escritos entre 2026-08-28 y 2026-09-02.
- **Nunca versionados**: `git log --all -- docs/` devolvía vacío. Causa: patrón
  genérico `docs/` en `.gitignore:110`, introducido por daño colateral en el
  commit `e2845e8` (2026-08-30, *"excluye addons de terceros, .uid y scripts
  sueltos"*).
- **Autores** (por firma de Logs): `docs/qa/` → deepseek-v4-flash (Log 509, M101);
  `docs/playtest/` → deepseek-v4-flash (Log 481, M114);
  `docs/marketing/` → deepseek-v4-flash (Log 421, M98);
  `docs/codigo_de_calidad/` → Devin (Log 26, M111);
  `bug_tracking_guide.md` + `bug_metrics.md` → ox-alpha (M102, verificado por Hy3
  en Log 767).
- **Sí se usa**: 49 referencias vivas en `DOCUMENTACION/` (M111 ×21, M102 ×16,
  M114 ×12) + `CHECKLIST-GLOBAL.md` filas 41 y 42 + 5 logs.
- **No lo lee ningún código**: 0 hits en `.gd` / `.py` / `.json`.
- **No es material suelto**: es el entregable documental de M101, M102, M111,
  M114 y M98.

## 2. Cambios realizados

### 2.1 Versionado (commit `82fe882`)

`.gitignore` — se reemplazó el patrón genérico por uno acotado, para no
versionar el `docs/` interno del proyecto Godot:

```diff
-docs/
+# `docs/` (raíz) SÍ se versiona: material complementario de M98/M101/M102/M111/M114.
+# Ver política en AGENTS.md §3. Solo se ignora el docs/ interno del proyecto Godot.
+game/isla-ancestral/docs/
 .github/
```

Verificado después del cambio:
- `docs/` → ya no ignorado.
- `game/isla-ancestral/docs/LSP_KNOWN_ISSUES.md` → sigue ignorado (`.gitignore:112`).
- `tools/mcp/.venv/.../cyclopts/docs` → sigue ignorado (`.gitignore:84`).

Antes de commitear se pasó `scripts/diagnosticar_mojibake.py`: **los 17 archivos
están limpios** (UTF-8 válido, 0 U+FFFD). Commit selectivo de 18 archivos
(17 de `docs/` + `.gitignore`); no se tocó nada del trabajo de otros agentes.

### 2.2 Política en `AGENTS.md` (commit `b3865c1`)

Nueva subsección en **§3 Estructura de Documentación del Proyecto**, inmediatamente
después de la regla general, con cuatro reglas:

1. `docs/` **NO** es el destino de documentación nueva — la metodología oficial
   sigue siendo `DOCUMENTACION/`.
2. `docs/` **SÍ** se puede consultar como material complementario, con tabla de
   módulos relacionados (M101, M102, M111, M114, M98) y su origen.
3. **NO duplicar trabajo**: si el contenido ya existe, ampliarlo en el plan del
   módulo y referenciar `docs/` como apoyo.
4. No confundir con `GUIA-GODOT/` ni `GUIA-BLENDER/` (esas sí son canónicas).

### 2.3 Referencias en los planes actuales (commit `b3865c1`)

Se añadió la nota de ubicación en el `04-Codigo.md` de los cinco módulos:

| Módulo | Estado anterior | Ahora |
|--------|-----------------|-------|
| `101-QA-General` | **no mencionaba `docs/`** | §2.1 nueva: declara canónica la copia del plan y `docs/qa/` como histórico |
| `102-Bug-Tracking` | ya citaba `docs/` | nota: versionado, única copia, material complementario |
| `111-Codigo-De-Calidad` | ya citaba `docs/` | nota + corrección: sólo existen `checklist_commit.md` y `deuda_tecnica.md`; la guía de desarrolladores está en `docs/developers/` |
| `114-Playtest` | ya citaba `docs/` | nota: versionado, única copia, redactar en `DOCUMENTACION/` |
| `98-Trailer` | **no mencionaba `docs/`** | fila nueva en §1.1 apuntando a `docs/marketing/guion-trailer.md` |

## 3. Archivos modificados/creados

**Commit `82fe882` (18):**
- `.gitignore` (modificado)
- `docs/` completo (17 archivos nuevos en git)

**Commit `b3865c1` (6):**
- `AGENTS.md` (+16 líneas, §3)
- `DOCUMENTACION/101-QA-General/plan-actual/04-Codigo.md` (+14)
- `DOCUMENTACION/102-Bug-Tracking/plan-actual/04-Codigo.md` (+8)
- `DOCUMENTACION/111-Codigo-De-Calidad/plan-actual/04-Codigo.md` (+10)
- `DOCUMENTACION/114-Playtest/plan-actual/04-Codigo.md` (+9)
- `DOCUMENTACION/98-Trailer/plan-actual/04-Codigo.md` (+7)

## 4. Lo que NO se tocó (y por qué)

- **`DOCUMENTACION/114-Playtest/plan-actual/05-Checklist.md`** — apareció con 29
  líneas cambiadas durante esta sesión y **no son mías**: otro agente está
  cerrando el ítem de NDA en este momento. Quedó fuera del commit.
- **`docs/qa/` vs `DOCUMENTACION/101-QA-General/plan-actual/`** — la divergencia
  de las 7 plantillas no se resolvió fusionando (sería reescribir material de
  M101, cuyo dueño es deepseek-v4-flash). Se declaró canónica la copia del plan
  por ser 2–3× más extensa y por AGENTS.md §3.
- **`.github/`** — sigue ignorado (` .gitignore:113`). Ver §5.

## 5. Hallazgo nuevo: `.github/` tampoco está versionado

`git log --all -- .github/` devuelve vacío. Están fuera de git:
`.github/ISSUE_TEMPLATE/bug_report.md`, `create_labels.sh` y los workflows
`bug_metrics.yml`, `backup.yml`, `dev-build.yml`, `quality.yml`,
`release-build.yml`, `testing.yml`. Es **el mismo riesgo que tenía `docs/`** y
afecta a M102 y a todo el CI. No se tocó porque excede lo pedido — queda como
decisión del usuario.

## 6. Verificación

| Comprobación | Resultado |
|---|---|
| `git check-ignore docs/qa/QA-CHECKLIST.md` | vacío → versionado |
| `git log --oneline -- docs/` | 1 commit (`82fe882`) |
| `git diff --stat -- AGENTS.md` | +16 líneas, sin cambios ajenos |
| `scripts/diagnosticar_mojibake.py` sobre `docs/` | sin hallazgos |
| Codificación UTF-8 de los 5 planes editados | OK, 0 U+FFFD |

## 7. Próximos pasos sugeridos

1. Decidir si `.github/` se versiona (mismo procedimiento que `docs/`).
2. Resolver la divergencia `docs/qa/` con el dueño de M101.
3. Retomar: 14 módulos sobre-cerrados · 329 rutas `.cs` inexistentes ·
   4 referencias ambiguas de `Logs/` + Log 723 fantasma.
