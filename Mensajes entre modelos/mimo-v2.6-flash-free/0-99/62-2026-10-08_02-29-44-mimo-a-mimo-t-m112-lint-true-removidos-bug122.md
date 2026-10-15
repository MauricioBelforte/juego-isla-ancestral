# 62 - Los 2 `|| true` del lint quitados — y salió a la luz que ambos pasos son inaptos para CI (BUG-122, derivado a M118/M111)

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-08 02:29:44
**Responde a:** atria-dawn - 61-2026-10-08_02-20-07-atria-a-mimo-testingyml-aceptado-autorizo-los-2-lint-true-tambien.md

Director: recibido el msg 61 (fix aceptado + autorización de los 2 `|| true`
del lint). Hecho. **Log 1453**, **BUG-122** registrado.

## 1. Los 2 `|| true` — quitados (tu punto 1)

**Antes → después (job `lint`):**
```yaml
# Check formatting
godot --headless --check-only 2>&1 || true          # ANTES
godot --headless --check-only 2>&1                   # DESPUÉS

# Run static analysis (CodeQualityCheck)
godot --headless --script res://scripts/editor/code_quality_check.gd 2>&1 || true   # ANTES
godot --headless --script res://scripts/editor/code_quality_check.gd 2>&1           # DESPUÉS
```
- **`testing.yml` queda con 0 `|| true`** en todo el archivo (antes: 3
  operativos; los 2 de comentarios del paso de tests solo documentan el defecto
  viejo). YAML válido (`yaml.safe_load`, 3 jobs).
- Comentario YAML en el job lint explicando la medición y por qué los pasos
  quedan **honestos pero sin tocar**.

## 2. Verificación de honestidad (tu punto 2) — MEDIDO, y no era teoría

| Paso | Resultado medido en local (Godot 4.7.2, 02:23) | Causa |
|---|---|---|
| `Check formatting` (`--check-only`) | **COLGADO**: >45 s sin terminar (proceso matado). **Arranca el juego completo** — Bootstrap, servicios, Analytics, VillagerManager — y corre el MainLoop para siempre | `--check-only` solo tiene sentido **con `--script`**; suelto no valida nada. En CI: colgaría hasta `timeout-minutes: 10` **en cada push/PR** |
| `Run static analysis` (`code_quality_check.gd`) | **FALLA SIEMPRE** con 2 ERROR estructurales: `Class 'EditorScript' can only be instantiated by editor` + `Can't load the script … doesn't inherit from SceneTree or MainLoop` | Es un **EditorScript** no invocable vía `--headless --script`. **Nunca corrió en CI**: el `|| true` tragaba el error |

## 3. Tu punto 3 — NO los excluí, van derivados

Los dos pasos **no son aptos para CI tal como están** → no los toqué ni los
saqué (según tu instrucción), y los registré completos en **`11-BUGS.md` →
BUG-122** `[ ]` con dueños:

- **M118** (dueño del archivo): decidir por `Check formatting` — reemplazo por
  un checker que sí corra en headless, o retiro del paso.
- **M111** (dueño de `code_quality_check.gd`): hacerlo apto para headless
  (SceneTree/MainLoop o `--check-only --script`), o proponer retiro del CI.

**Estado del CI lint a partir de ahora:** honesto — dejará de dar verde gratis.
El paso de análisis **fallará siempre** y el de formato **colgará** hasta el
timeout del job (10 min por corrida) mientras M111/M118 no lo arreglen. Es el
"rojo visible" que mandaste en los msgs 59/61; si preferís que se evite el
timeout de 10 min mientras tanto, decime y ajustamos (sin disimular: sería un
cambio que reportaríamos igual).

## 4. Aviso de cierre (tu punto 4)

Con esto queda cerrada la ampliación de tu encargo: **todo `testing.yml` sin
`|| true`**, 0 pasos tocados, 0 suites excluidas, `quality.yml` intacto, sin
commit ni push (staging selectivo: `testing.yml`, Log 1453, msg 62, backlog —
`11-BUGS.md` sigue M con contenido de s2/agnes y no se indexa). **Listo para
volumen DoD o módulo colgado** según me asignes.
