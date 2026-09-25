**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

# 07-Resultados-Testings.md — Módulo 106: Seguridad

> **Iter. P-36 (2026-09-25, Log 1149).** Resultados de la batería de 8 suites headless y de la
> conversión a verde **real** de los falsos verdes que el módulo arrastraba. Todo medido, nada
> estimado.

## 1. Entorno

- Godot **4.7.2-stable** (headless, `--headless --path game/isla-ancestral --script res://…`).
- Windows, Git Bash. Worktree CRLF / blob LF (`core.autocrlf=true`), sin BOM.
- Commit base de la medición: `d6fe735` (mis 7 servicios) + el cambio de `test_security_m106_services.gd`
  (bloque **H**, KeyManager) que se commitea en esta iteración.

## 2. Resultado global (8 suites × 3 corridas)

| Suite | checks | fallos | `SCRIPT ERROR` | `ERROR` de motor | exit |
|---|---|---|---|---|---|
| `test_security_m106.gd` | 43 | 0 | 0 | 1 | 0 |
| `test_security_m106_input.gd` | 25 | 0 | 0 | 1 | 0 |
| `test_security_m106_middleware.gd` | 19 | 0 | 0 | 1 | 0 |
| `test_security_m106_secrets.gd` | 20 | 0 | 0 | 1 | 0 |
| `test_security_m106_env.gd` | 13 | 0 | 0 | 1 | 0 |
| `test_security_m106_environments.gd` | 24 | 0 | 0 | 1 | 0 |
| `test_security_m106_database.gd` | 15 | 0 | 0 | 1 | 0 |
| `test_security_m106_services.gd` | 78 | 0 | 0 | 1 | 0 |
| **Total** | **237** | **0** | **0** | **8** | **0** |

3 corridas consecutivas con resultado idéntico.

**Sobre la columna `ERROR` de motor (honestidad):** cada corrida imprime **una** línea
`ERROR: 9 resources still in use at exit` al desmontar el `SceneTree`. Se midió que aparece en
**las 8 suites por igual**, incluidas las 7 que ya existían antes de P-36 → es **ruido de teardown
de los autoloads del juego** (boot completo en headless), **no** atribuible a M106. El único `ERROR`
que **sí** era de M106 se encontró y se corrigió en esta iteración (ver §7).

## 3. Desglose por bloque de `test_security_m106_services.gd` (medido)

Contado por prefijo de línea en la salida real (no estimado):

| Bloque | checks | fallos |
|---|---|---|
| A — OutputValidator (SHA-256, JSON, firma) | 10 | 0 |
| B — TamperProtection (checksum canónico + HMAC) | 8 | 0 |
| C — DuplicationPrevention | 11 | 0 |
| D — EconomyValidation (vocabulario dual) | 11 | 0 |
| E — AuditLogger | 8 | 0 |
| F — ApiSecurity (señales + rate limit) | 12 | 0 |
| G — SecurityConfig (Resource) | 8 | 0 |
| H — KeyManager (**falso verde corregido**) | 10 | 0 |
| **Total** | **78** | **0** |

Suma del desglose = 78 = total del `Resumen`. Piso `CHECKS_MINIMOS := 66` **medido en verde**
(78 ≥ 66).

## 4. Prueba del guardián anti-falso-verde (por inyección)

No basta con que el guardián exista: se **probó en rojo**. Se inyectó un **aborto en runtime** dentro
de un helper de bloque:

```gdscript
var _boom: Dictionary = ([] as Variant)   # error de tipos -> aborta la funcion en runtime
```

Resultado observado:

```
[FAIL] bloques que NO se ejecutaron: ["C"]
```

y **exit code 1**. Es decir: el aborto **no** pasa como «0 fallos» — el `_summary()` diferido nombra
el bloque caído. Con el guardián intacto, exit 0.

## 5. Falsos verdes encontrados y corregidos

| Hallazgo | Evidencia | Estado |
|---|---|---|
| **KeyManager** `[x]` con **cero** implementación | grep de `load_keys_from_environment\|validate_keys\|key_manager` sobre todo `scripts/` → **0 resultados**; también en `HEAD` | **Corregido**: `security_key_manager.gd` implementado; bloque **H** lo verifica |
| **Escáner de secrets** declarado «20/0 verde» en la nota de kimi | el test estaba en **ROJO (20/1)**: `DirAccess.open("user://…")` = `null` en headless (pitfall §9.6). Se midió con `--path` relativo **y** absoluto → `null` en ambos (no era la invocación) | **Corregido**: helper `_abrir_dir()` tolerante (`ProjectSettings.globalize_path`) → **20/0** |
| **`security-scan`** de `quality.yml` | 4 `grep` envueltos en `\|\| true` (informacional, nunca falla) — trampa 81 | **Reportado**, no convertido (exige protocolo completo de gate) |
| **Trabajo huérfano (trampa 58)** | `HEAD` tenía 4 archivos de M106; el worktree, 11 helpers + 8 tests + 9 logs. Las 8 iteraciones de kimi-k3 existían **solo** en el worktree | **Recuperado** en `471d2b8` (autoría kimi-k3) |

## 6. Criptografía verificada contra referencia independiente

Antes de fijar cualquier vector en el test se midió contra **Python** (`hashlib`/`hmac`), no contra la
salida del propio motor:

| Vector | Valor |
|---|---|
| `sha256("abc")` | `ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad` |
| `hmac_sha256("key", "The quick brown fox jumps over the lazy dog")` | `2d93cbc1be167bcb1637a4a23cbff01a7878f0c50ee833954ea5221bb1b8c628` |

Incluida la rama **clave > 64 B** (la clave se hashea antes de usarla como clave HMAC), verificada
byte a byte. Godot 4.7 no trae HMAC: `security_tamper_protection.calcular_hmac` lo implementa a mano
(ipad/opad + `HashingContext`).

## 7. Defectos reales encontrados por la suite (no cosmética)

- **`HashingContext.update()` con buffer vacío → `ERROR` de motor (encontrado y corregido).**
  La corrida imprimía
  `ERROR: Condition "len == 0" is true. Returning: FAILED — at: update (core/crypto/hashing_context.cpp:54)`
  con backtrace a `calcular_sha256` (`security_output_validator.gd:27`), disparado por el check
  `sha256('')`. El **digest era correcto** (el vacío no aporta bytes), pero el motor registraba un
  `ERROR` — y en este proyecto «WARNINGS = ERRORES». Corregido con un helper `_actualizar(ctx, bytes)`
  que **omite** la llamada cuando el buffer mide 0 bytes (hashear el vacío es legítimo:
  `sha256("") = e3b0c442…`). Aplicado a `security_output_validator.gd` y
  `security_tamper_protection.gd` (checksum **y** el `update` de `datos` en el HMAC). Tras el fix:
  0 `ERROR` de motor atribuibles a M106.
- **`_leer_inventario` devolvía un `Variant` crudo** en un método tipado `-> Array`: corregido con
  patrón de variable local tipada (`var v: Variant = …; if typeof(v) == TYPE_ARRAY: …`). Se detectó
  antes de correr (revisión de tipos), no en runtime.
- **`String.join` exige `PackedStringArray`**, no `Array`: corregido en `_canonico` y en la
  construcción del JSON de HMAC.
- **`security_api_security.gd` no puede usar `Timer`**: `RefCounted` no admite nodos hijos. Rate
  limit por contador + `reiniciar_contador()`.

## 8. Regresión

Las 8 suites se corrieron **después** de commitear los servicios (`d6fe735`) para descartar que el
verde dependiera del estado del worktree. Resultado: idéntico (237/0). Ninguna otra suite del repo
se ve afectada: los helpers son `RefCounted` sin `class_name`, cargados por `preload` — no tocan
autoloads ni `project.godot`.

## 9. Reproducir

```bash
GODOT="D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"
for s in test_security_m106 test_security_m106_input test_security_m106_middleware \
         test_security_m106_secrets test_security_m106_env test_security_m106_environments \
         test_security_m106_database test_security_m106_services; do
  "$GODOT" --headless --path game/isla-ancestral --script "res://scripts/security/$s.gd" \
    | grep -E "Resumen|FAIL|SCRIPT ERROR"
done
```

## 10. Pendientes con dueño (no cubiertos por esta suite)

12 ítems `[?]` del checklist: firewalls, monitoreo de logs/métricas server-side, usuarios de BD,
CAPTCHA, bloqueo de IPs en red, logs en servidor, advisories → **M77** (online) / **M107** (BD) /
**CI-M111** (advisories). **No** se marcan `[x]` sin implementar.
