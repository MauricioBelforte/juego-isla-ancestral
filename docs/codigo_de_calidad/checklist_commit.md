# Checklist de Calidad por Commit - Isla Ancestral

> **Módulo:** M111 Código de Calidad
> **Versión:** 1.0
> **Fecha:** 2026-08-28

---

## Antes de Commit (Pre-commit Local)

Ejecutar **todos** estos checks antes de `git commit`:

### ✅ 1. Godot Parser Check
```bash
cd game/isla-ancestral
godot --headless --check-only
```
- **Debe salir:** Exit code 0, sin errores de parsing
- **Falla si:** Sintaxis inválida, referencias rotas, tipos incorrectos

### ✅ 2. GDScript Formatting Check
```bash
godot --headless --format --check-only
```
- **Debe salir:** Exit code 0, sin diferencias de formato
- **Falla si:** Código no sigue formatter oficial de Godot 4.x
- **Fix automático:** `godot --headless --format` (aplica cambios)

### ✅ 3. M111 CodeQualityCheck (Análisis Estático)
```bash
godot --headless --script scripts/editor/code_quality_check.gd
```
- **Debe salir:** 0 errores de **naming conventions** (severity: error)
- **Warnings permitidos:** method_too_long, class_too_long, high_complexity, deep_nesting, missing_documentation
- **Revisar reporte:** `user://code_quality_report.txt`

### ✅ 4. Tests Relevantes (M112)
```bash
# Tests de validación existentes
godot --headless --script scripts/saving/validate_save.gd
godot --headless --script scripts/time/test_calendario.gd
godot --headless --script scripts/time/test_consumidores_tiempo.gd
godot --headless --script scripts/friendship/test_amistad.gd
godot --headless --script scripts/economia/test_loop_economico.gd
godot --headless --script scripts/economia/test_minorista_mayorista.gd
godot --headless --script scripts/economia/test_topos_banda.gd
```
- **Debe salir:** Todos los tests pasan (exit code 0 cada uno)
- **Si añades código:** Añadir tests correspondientes

### ✅ 5. Sin Warnings de Godot en Output
- Abrir editor Godot → pestaña **Output**
- Verificar: **0 warnings** nuevos introducidos por tus cambios
- Warnings pre-existentes OK (registrar en deuda técnica si son tuyos)

### ✅ 6. Documentación Actualizada
- [ ] Si cambiaste API pública → actualizar docstrings (## comentarios)
- [ ] Si añadiste módulo/sistema → actualizar `docs/developers/guia_desarrolladores.md`
- [ ] Si introdujiste deuda técnica intencional → registrar en `docs/codigo_de_calidad/deuda_tecnica.md`

### ✅ 7. Deuda Técnica Registrada (si aplica)
- [ ] ¿Introdujiste código que viola límites (líneas, complejidad, anidamiento)?
- [ ] ¿Hay TODOs/FIXMEs que no se resolverán en este PR?
- [ ] → Crear entrada en `deuda_tecnica.md` con prioridad y dueño

---

## Después de Commit (Post-commit / CI)

Estos se validan **automáticamente en GitHub Actions** (`.github/workflows/quality.yml`):

### ✅ 8. CI Pipeline Verde
- [ ] **godot-lint** - Parser check pasa
- [ ] **code-quality-script** - CodeQualityCheck pasa (0 naming errors)
- [ ] **formatting-check** - Formato correcto
- [ ] **test-suite** - Todos los tests de validación pasan
- [ ] **security-scan** - Sin secrets hardcodeados, sin prints excesivos

### ✅ 9. Code Review Aprobado (si requerido)
**Requerido para:**
- Módulos nuevos (M07, M08, M59+)
- Cambios críticos gameplay (combate, economía, guardado, tiempo)
- Arquitectura central (EventBus, ServiceRegistry, Bootstrap)
- Refactorizaciones > 100 líneas
- Bugs P0/P1

**Checklist Reviewer (16 ítems):**
| # | Verificación | ✅/❌ |
|---|--------------|------|
| 1 | Nomenclatura correcta | |
| 2 | Límites tamaño (método≤50, clase≤300, archivo≤500) | |
| 3 | Complejidad ciclomática ≤10 | |
| 4 | Anidamiento ≤4 | |
| 5 | Doc en clases públicas | |
| 6 | Doc en funciones públicas | |
| 7 | Tipado estático params/return | |
| 8 | @onready para nodos | |
| 9 | Señales tipadas | |
| 10 | Callable.bind para callbacks | |
| 11 | Sin memory leaks | |
| 12 | Validaciones defensivas | |
| 13 | Manejo errores robusto | |
| 14 | Tests si aplica (M112) | |
| 15 | Sin código duplicado (DRY) | |
| 16 | Compat Godot 4.4.1+ | |

### ✅ 10. Changelog Actualizado
- Formato: **Conventional Commits**
- Ejemplos:
  - `feat: add villager dialogue system (M19)`
  - `fix: resolve save corruption on web build (M59)`
  - `refactor: extract PriceManager from EconomyManager (M38)`
  - `docs: update developer guide with naming conventions (M111)`
  - `chore: update pre-commit hooks config`

### ✅ 11. Sin Regresiones
- [ ] Funcionalidad relacionada sigue funcionando
- [ ] Tests de integración pasan (M14+M38+M39 loop)
- [ ] Manual smoke test: juego arranca, movimiento WASD, guardar/cargar

---

## Resumen Rápido (Copy-Paste para PR Description)

```markdown
## Checklist de Calidad - Pre-commit

- [ ] `godot --headless --check-only` ✅
- [ ] `godot --headless --format --check-only` ✅
- [ ] `CodeQualityCheck` (0 naming errors) ✅
- [ ] Tests relevantes pasan ✅
- [ ] 0 warnings nuevos en Godot Output ✅
- [ ] Documentación actualizada ✅
- [ ] Deuda técnica registrada (si aplica) ✅

## Post-commit (CI)

- [ ] CI pipeline verde ✅
- [ ] Code review aprobado (si requerido) ✅
- [ ] Changelog (Conventional Commits) ✅
- [ ] Sin regresiones ✅
```

---

## Referencias Rápidas

| Comando | Qué hace |
|---------|----------|
| `godot --headless --check-only` | Parser + type check |
| `godot --headless --format --check-only` | Verifica formato |
| `godot --headless --format` | Auto-formatea |
| `godot --headless --script scripts/editor/code_quality_check.gd` | Análisis estático M111 |
| `pre-commit run --all-files` | Ejecuta todos los hooks locales |
| `cat user://code_quality_report.txt` | Ver reporte calidad |

---

## Notas

- **No commitees** si algún check pre-commit falla
- **No merges** si CI falla o review no aprobado (cuando requerido)
- **Registra deuda** si haces trade-off consciente (documenta por qué y cuándo se arregla)
- **Automatiza**: `pre-commit install` para hooks automáticos en cada commit

---

*Parte del Módulo 111 - Código de Calidad*
*Última actualización: 2026-08-28*