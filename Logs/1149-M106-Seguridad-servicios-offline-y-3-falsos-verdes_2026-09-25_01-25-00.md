# Log 1149: P-36 / M106 — servicios offline de seguridad, 3 falsos verdes y recuperación de trabajo huérfano

**Fecha:** 2026-09-25
**Hora:** 01:25
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Reserva:** el pool dio **primero=1149** al medir con `--estado` **justo antes de reservar** (el pedido
decía 1145; 1145/1146/1147/1148 los consumieron hy3, agnes y el coordinador concurrentemente).
Se reservaron **1149** (M106) y **1150** (M122).

## Resumen

M106 figuraba en **149/206**. Al medirlo, el 149 **no estaba en `HEAD`**: la iteración completa de
kimi-k3 (4 helpers, 5 tests, 2 modificaciones de código, 2 docs y 9 logs) existía **sólo en el
worktree** — **trampa 58** (trabajo huérfano). Se recuperó, se corrigieron **3 falsos verdes**, se
implementaron los **7 servicios offline** del diseño y el checklist quedó en
**`[x]=194 · [?]=12 · [ ]=0` (206)**.

1. **Trampa 58 medida:** `HEAD` tenía **4** archivos de M106; el worktree, **11 helpers + 8 tests**.
   Los 9 logs de kimi tampoco estaban versionados. Recuperados en `471d2b8` (autoría kimi-k3).
2. **Falso verde #1 — escáner de secrets en ROJO.** La nota de kimi afirmaba «20/0 verde»; el test
   daba **20/1**: `DirAccess.open("user://…")` devuelve `null` en headless (pitfall §9.6). Se midió
   con `--path` **relativo y absoluto** -> `null` en ambos (no era la invocación). Fix: `_abrir_dir()`
   tolerante -> **20/0**.
3. **Falso verde #2 — KeyManager `[x]` sin implementación.** Sus 5 ítems estaban `[x]` con **cero**
   código: `grep -r "load_keys_from_environment|validate_keys|key_manager" scripts/` -> **0 resultados**.
   También en `HEAD`. Implementado `security_key_manager.gd`.
4. **Falso verde #3 — `security-scan` de `quality.yml`.** No es un gate: son **4 `grep` con `|| true`**
   (trampa 81). **Reportado, NO convertido** (exige el protocolo completo de gate).
5. **7 servicios offline implementados** + `.env.example` + `test_security_m106_services.gd`
   (8 bloques A–H, **78 checks**). Cripto medida contra Python antes de escribirla.

## Cambios Realizados

### Recuperación (trampa 58) — commit `471d2b8`

22 archivos, +1930/−13. Se versionó el trabajo de kimi-k3 **atribuyéndolo a kimi-k3** (yo sólo
recuperé y verifiqué), más el fix del escáner. `HEAD` pasó de 4 a 11 helpers.

### Servicios nuevos — commit `d6fe735` + commit de docs `7d35607`

Todos `RefCounted`, sin `class_name` (preload), headless-safe, cabecera firmada:

| Archivo | API principal |
|---|---|
| `security_output_validator.gd` | `calcular_sha256`, `validar_checksum`, `validar_json`, `validar_firma`, `_igualdad_constante` |
| `security_tamper_protection.gd` | `calcular_checksum`, `calcular_hmac`, `validar_savegame`, `validar_savegame_firma`, `_canonico` |
| `security_duplication_prevention.gd` | `generar_request_id`, `ya_procesado`, `marcar_procesado`, `limpiar_antiguos`, `cantidad_procesados` |
| `security_economy_validation.gd` | `validar_economia`, `validar_economia_checksum`, `calcular_checksum_economia` |
| `security_audit_logger.gd` | `registrar`, `formatear`, `guardar`, `cantidad`, `limpiar` |
| `security_api_security.gd` | señales `api_autenticada(exito)`/`limite_tasa_excedido`; `cargar_api_key`, `autenticar`, `verificar_limite` |
| `security_config.gd` | `extends Resource`, 8 `@export`, `como_diccionario()` |
| `security_key_manager.gd` | `CLAVES_REQUERIDAS` (5), `cargar_desde_entorno`, `obtener`, `validar`, `faltantes` |

- **`.env.example`** creado en la raíz: `.env.local` ya lo citaba y **no existía** (cita rota).

### Defecto encontrado MIDIENDO la salida (no leyendo el código)

`HashingContext.update()` con un buffer **vacío** imprime un `ERROR` de motor
(`Condition "len == 0" is true`, `core/crypto/hashing_context.cpp:54`), disparado por el check
`sha256('')`. El digest era correcto, pero el proyecto trata **WARNINGS como ERRORES**. Corregido con
`_actualizar(ctx, bytes)` que omite la llamada si el buffer mide 0 bytes, en
`security_output_validator.gd` y `security_tamper_protection.gd`. **Lección: un check verde puede
estar tapando un ERROR del motor.**

### Cripto medida contra referencia independiente (Python)

| Vector | Valor |
|---|---|
| `sha256("abc")` | `ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad` |
| `hmac_sha256("key","The quick brown fox…")` | `2d93cbc1be167bcb1637a4a23cbff01a7878f0c50ee833954ea5221bb1b8c628` |

Incluida la rama **clave > 64 B**. Godot 4.7 **no trae HMAC**: se implementó a mano (ipad/opad).

### Documentación

`04-Codigo.md` §26 · `05-Checklist.md` reconciliado (`[x]=194 [?]=12 [ ]=0`) · **`06-Plan-Testings.md`
y `07-Resultados-Testings.md` nuevos** (el `04-Codigo.md` decía «NO APLICA»; con 8 suites y 237 checks,
sí aplica).

## Verificación

| Suite | checks | fallos | `SCRIPT ERROR` | exit |
|---|---|---|---|---|
| `test_security_m106.gd` | 43 | 0 | 0 | 0 |
| `test_security_m106_input.gd` | 25 | 0 | 0 | 0 |
| `test_security_m106_middleware.gd` | 19 | 0 | 0 | 0 |
| `test_security_m106_secrets.gd` | 20 | 0 | 0 | 0 |
| `test_security_m106_env.gd` | 13 | 0 | 0 | 0 |
| `test_security_m106_environments.gd` | 24 | 0 | 0 | 0 |
| `test_security_m106_database.gd` | 15 | 0 | 0 | 0 |
| `test_security_m106_services.gd` | 78 | 0 | 0 | 0 |
| **Total** | **237** | **0** | **0** | **0** |

**×3 corridas consecutivas** (godot 4.7.2 headless). Desglose por bloque de la suite nueva (medido):
A=10, B=8, C=11, D=11, E=8, F=12, G=8, H=10 -> **78**. Piso `CHECKS_MINIMOS := 66` medido en verde.
Guardián de 3 capas **probado en rojo por inyección** (`[FAIL] bloques que NO se ejecutaron: ["C"]`
+ exit 1).

Cada corrida imprime **1** línea `ERROR: 9 resources still in use at exit`: ruido de teardown de los
autoloads, presente **también en las 7 suites preexistentes** -> no atribuible a M106.

## Pendientes con dueño (12 `[?]`)

Firewalls, monitoreo de logs/métricas server-side, usuarios y credenciales reales de BD, CAPTCHA,
bloqueo de IPs en red, logs en servidor y advisories -> **M77** (online) / **M107** (BD) /
**CI-M111** (advisories). **No** se marcan `[x]` sin implementar.

## Honestidad

- El `security-scan` de `quality.yml` **sigue siendo un falso verde**: lo reporto, no lo convierto.
  Convertirlo exige medir contra `HEAD` -> probar en rojo -> barrer -> cablear, y el escáner hoy
  reporta 2 archivos (ambos **fixtures de test**) -> necesita exclusión de tests antes de ser gate.
- `security_api_security.gd` **no usa `Timer`** (un `RefCounted` no admite nodos hijos): el rate limit
  es por contador + `reiniciar_contador()`; la ventana temporal la aporta el llamador. Desviación
  documentada.
- `security-economy` acepta **vocabulario dual** (`oro`/`gold`, `inventario`/`inventory`,
  `cantidad`/`quantity`): el diseño no fija nombres de campo y el savegame usa español.
