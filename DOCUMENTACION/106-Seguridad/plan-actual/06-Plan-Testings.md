**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

# 06-Plan-Testings.md — Módulo 106: Seguridad

> **Iter. P-36 (2026-09-25, Log 1149).** Creado al cerrar P-36. Antes **no existía** y `04-Codigo.md`
> afirmaba «06-Plan-Testings.md → NO APLICA». El módulo tiene **8 suites headless** y **237 checks**:
> sí aplica (AGENTS.md §450: los 2 archivos de testing se agregan «solo si el módulo lo amerita» —
> Seguridad es integración crítica).

## 1. Objetivo y alcance

Convertir en **checks ejecutables** lo que el diseño de M106 describe como servicios, y **medir** los
falsos verdes que el módulo arrastraba: ítems `[x]` sin implementación, un test en rojo declarado
verde, y un gate de CI que no gatea.

**Alcance verificado:** los helpers de `res://scripts/security/` — `security_manager.gd` (catálogo
data-driven, autoload), `security_input_validator.gd`, `security_output_validator.gd`,
`security_tamper_protection.gd`, `security_duplication_prevention.gd`, `security_economy_validation.gd`,
`security_audit_logger.gd`, `security_api_security.gd`, `security_config.gd`, `security_key_manager.gd`,
`security_secret_scanner.gd`, `security_rate_limit_middleware.gd`, `security_environment_resolver.gd`,
`security_database_config.gd` + los 3 JSON de `data/security/` + `.env.example`.

**Fuera de alcance (con dueño):** firewalls, monitoreo de logs/métricas server-side, usuarios y
credenciales de BD reales, CAPTCHA, bloqueo de IPs en red y advisories → **M77** (online) /
**M107** (BD/backups) / **CI-M111**. Son los 12 `[?]` del checklist: **no** se marcan `[x]` sin
implementación.

## 2. Herramienta

Godot 4.7.2 headless (el ejecutable es un **directorio** en este entorno):

```
"D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe" \
  --headless --path game/isla-ancestral \
  --script res://scripts/security/test_security_m106_services.gd
```

Suites del módulo:

| Suite | Checks | Cobertura | Guardián |
|---|---|---|---|
| `test_security_m106.gd` | 43 | catálogo `SecurityManager`, `validar_save` (CRC32), API del autoload | _fin + resumen |
| `test_security_m106_input.gd` | 25 | `InputValidator`: string/int/float/email/enum + `sanitizar` | _fin + resumen |
| `test_security_m106_middleware.gd` | 19 | `security_rate_limit_middleware.gd` (T-005) | _fin + resumen |
| `test_security_m106_secrets.gd` | 20 | `security_secret_scanner.gd` (T-006); **corregido en P-36** (estaba en rojo) | _fin + resumen |
| `test_security_m106_env.gd` | 13 | `.env.local` / `.gitignore` (T-007) | _fin + resumen |
| `test_security_m106_environments.gd` | 24 | `security_environment_resolver.gd` (T-008) | _fin + resumen |
| `test_security_m106_database.gd` | 15 | `security_database_config.gd` (T-009) | _fin + resumen |
| `test_security_m106_services.gd` | 78 | **P-36**: los 7 servicios offline + KeyManager | ✅ **3 capas** |

**Guardián de 3 capas (solo la suite nueva de P-36; las 7 previas usan `_fin`/resumen):**
(1) cada bloque cierra con `_fin("X")` y `_summary()` **nombra** los bloques que no terminaron,
invocado en su **propio `call_deferred`** para que corra **aunque `_run()` aborte** a mitad de frame
(trampa 62); (2) piso `CHECKS_MINIMOS := 66` **medido en verde** —no estimado—; (3) aserciones
**falsables** (nunca `_check(true, …)`). El guardián se **probó en rojo por inyección**
(ver `07-Resultados-Testings.md` §4).

`--check-only --script` se usa además para detectar errores de parseo sin ejecutar.

## 3. Estrategia anti-falso-verde

En GDScript un `SCRIPT ERROR` **aborta la función en silencio**: la suite seguiría imprimiendo
«0 fallos». Defensas aplicadas:

1. **`_fin(nombre)`** al final de cada bloque → registra el cierre y cuántos checks aportó.
2. **`_summary()`** exige que estén los **8** bloques (`BLOQUES := ["A"…"H"]`); si falta alguno,
   añade un `[FAIL]` que **nombra** los bloques que no terminaron.
3. **Piso `CHECKS_MINIMOS`**: si el total ejecutado baja del piso **medido en verde** (66), la suite
   falla. Es la defensa contra el aborto que se come checks sin dejar ningún `[FALLO]` (trampa 85).
4. El guardián se **prueba por inyección** — no basta con que exista.
5. **Conteo por prefijo de línea** al reconciliar el checklist (`^\s*-\s+\[[ x?]\]`), nunca `grep -o`.

## 4. Bloques de `test_security_m106_services.gd`

| Bloque | Qué verifica | Por qué |
|---|---|---|
| **A** | `OutputValidator`: `calcular_sha256` vs vector estándar · `validar_checksum` (ok/roto) · `validar_json` · `validar_firma` · `_igualdad_constante` | RF de integridad de datos online; SHA-256 es el reemplazo fuerte del CRC32 de `validar_save` |
| **B** | `TamperProtection`: checksum canónico (claves ordenadas) · `calcular_hmac` vs vector Python · rama clave **>64 B** · `validar_savegame` / `validar_savegame_firma` | Prevención de manipulación de savegame (RF) |
| **C** | `DuplicationPrevention`: `generar_request_id` único · `ya_procesado`/`marcar_procesado` · `limpiar_antiguos` por antigüedad · `cantidad_procesados` | Prevención de duplicación de requests (idempotencia) |
| **D** | `EconomyValidation`: `validar_economia` (oro/inventario) · vocabulario dual (`oro`/`gold`, `inventario`/`inventory`, `cantidad`/`quantity`) · checksum de economía | Economía adulterada (RF11 de kimi, extendido a offline) |
| **E** | `AuditLogger`: `registrar` · `formatear` · `guardar` (crea directorio) · `cantidad` · `limpiar` | Registro de accesos importantes (RF13), versión local/offline |
| **F** | `ApiSecurity`: señales `api_autenticada(exito)` / `limite_tasa_excedido` · `cargar_api_key` · `configurar_limite_tasa` · `reiniciar_contador` · `autenticar` · `verificar_limite` | Protección de API + rate limiting (RF1/RF2), versión cliente |
| **G** | `SecurityConfig` (`Resource`): los 8 `@export` · `como_diccionario()` devuelve copia · mutación de propiedad | Configuración de seguridad serializable |
| **H** | `KeyManager`: `CLAVES_REQUERIDAS` = 5 · entorno completo → 0 vacías y `validar()` true · entorno parcial → 4 vacías y `validar()` false · `obtener`/`faltantes` · sin cargar → false | **Falso verde corregido**: los 5 ítems estaban `[x]` con cero implementación |

## 5. Criterios de aceptación

- **Exit code 0** y `0 fallos` en **3 corridas consecutivas**.
- **0 ocurrencias** de `SCRIPT ERROR` en la salida.
- Los **8 bloques** cierran (sin abortos silenciosos).
- El guardián **falla** cuando se inyecta un aborto (probado, no supuesto).
- El total **no baja del piso** `CHECKS_MINIMOS` (66).
- Los vectores criptográficos están **medidos contra una implementación independiente** (Python
  `hashlib`/`hmac`), no copiados de la salida del propio motor.

## 6. Aislamiento

Los bloques que escriben usan `user://` (audit logger) y limpian al final. Ninguna suite toca
`project.godot` ni el estado del autoload `SecurityManager` de forma persistente. Los tests de
secretos operan sobre `res://scripts/` en **modo lectura**.

## 7. Qué NO cubre esta suite (honestidad obligatoria)

- **Firewalls, WAF, CAPTCHA y bloqueo de IPs en red** → **M77**. Aquí no hay servidor.
- **Monitoreo de logs/métricas y advisories de seguridad server-side** → **M77 / CI-M111**.
- **Usuarios y credenciales reales de BD, rotación de credenciales** → **M107**.
- **Conexión real a las bases por entorno**: `security_database_config.gd` valida la **separación**
  (nombres, hosts, origen de credenciales), no abre conexiones (drivers/pool son de M60/M77).
- **Rate limiting con ventana temporal real**: `security_api_security.gd` es un `RefCounted` (no
  puede tener nodos `Timer` hijos) → cuenta con `reiniciar_contador()`; la ventana la aporta el
  llamador. Documentado como desviación en `04-Codigo.md` §26.5.
- **`security-scan` de `quality.yml` NO es un gate real**: son 4 `grep` con `|| true` (falso verde
  permanente, trampa 81). **Reportado, no convertido** — convertir un gate exige el protocolo
  completo (medir contra `HEAD` → probar en rojo → barrer → cablear).
