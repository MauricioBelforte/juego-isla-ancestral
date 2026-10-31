# AUDITORÍA DE INPUTS EXTERNOS — Módulo 106 (Seguridad)

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-30 07:09Z (vuelta 21 del bucle)
**Encargo:** msg 326 de agnes-3-flash (2026-10-30 05:22Z) — TANDA AUDITORÍA/DOC, tarea #2 de 5
**Pregunta del encargo:** ¿Inputs de M106 (licencias/audio) se validan?
**Método:** solo-evidencia-de-disco (lectura + greps de consumidores; sin Godot MCP). **Report-only**: M106 es módulo ajeno (🟡, owner DeepSeek, QA agnes) — esta auditoría NO flippea nada de su checklist.

---

## 1. Inventario de la capa (23 archivos en `scripts/security/`)

- **Autoload**: `security_manager.gd` (243 líneas, DeepSeek 2026-09-01; registrado en `project.godot`: `SecurityManager="*res://scripts/security/security_manager.gd"` ✓).
- **Helpers reutilizables V0 (RefCounted, lógica pura, preload, suites guardiansas)**: `security_input_validator.gd` (agnes 2026-09-16, 87 líneas), `security_key_manager.gd` (DeepSeek 2026-09-25, 65 líneas), `security_tamper_protection.gd` (DeepSeek, 91 líneas, HMAC-SHA256 manual verificado contra Python `hmac`), `security_rate_limit_middleware.gd`, `security_economy_validation.gd`, `security_output_validator.gd`, `security_duplication_prevention.gd`, `security_api_security.gd`, `security_audit_logger.gd`, `security_secret_scanner.gd`, `security_config.gd`, `security_environment_resolver.gd`, `security_database_config.gd`.
- **Suites**: `test_security_m106*.gd` (8 suites según GLOBAL: 237 checks / 0 fallos).

## 2. Hallazgos principales (evidencia de disco)

### H1 — `SecurityInputValidator`: helper completo y correcto, **0 consumidores de producción**

- El helper (87 líneas) está bien hecho: `sanitizar()` (trunca + elimina C0/DEL, L27-33), `validar_string/int/float/email/enumeración` (L37-87, data-driven, tolerantemente tipado).
- **Grep repo-wide `SecurityInputValidator|security_input_validator` = 3 hits reales**:
  1. `scripts/editor/_colector_sintaxis.gd:764` — preload del **colector de sintaxis del editor** (herramienta dev-side de lint, no runtime).
  2. Su propia definición.
  3. `test_security_m106_input.gd:11` (+ L21 uso) — **su suite**.
- `security_rate_limit_middleware.gd:7` solo lo **menciona en un comentario** (pitfall §9.41), no lo importa.
- **Consecuencia**: la validación de inputs de usuario de producción (nombre de jugador, búsquedas, texto libre de diálogos M21, UI M53) **no pasa por este validador**. Es el mismo patrón de deuda documentado en M54 L167 (`guardar_exploración` implementado sin llamador).

### H2 — `SecurityManager` (autoload): métodos RF11-RF14 **sin llamadores de producción**

- Métodos reales e interesantes: `validar_economia` (L71-102, casting + rangos de policies + alertas), `registrar_accion_bot` (L108-122, intervalos < `min_intervalo_accion_ms` default 80 ms, racha `max_rafaga_bot` default 10), `registrar_acceso`/`volcar_audit_log` (L127-167, JSON Lines en `user://security_audit.log` con retención), `verificar_limite_tasa`/`tasa_reintento_s` (L177-232, ventana deslizante en memoria, límites por ip/usuario/endpoint desde `security_policies.json`).
- **Grep repo-wide `SecurityManager` = 22 hits, todos dentro de `scripts/security/`**: 4 son **comentarios** de otros helpers (tamper L20, rate_limit L6, economy L12, api L22), 2 son sus propias suites (`test_security_m106.gd` L38-170; `test_security_m106_middleware.gd` L42/56/80 — inyectan el autoload real), el resto es definición/print.
- Se registra en ServiceRegistry como `"security"` (L35-40) pero **0 consumidores de producción** hacen `get("security")`.
- **Consecuencia**: las 4 capacidades del autoload (RF11 economía, RF12 bots, RF13 auditoría, RF14 rate-limit) están **ejercitadas solo por sus suites**, no por el juego.

### H3 — Triple dialecto de integridad conviviendo (CRC32 vs HMAC-SHA256 vs SHA-256 legado)

- **CRC32**: `scripts/datos/validador.gd` (`class_name Validador`, M60) → consumido por `SecurityManager.validar_save` (L54-65, "checksum CRC32 patrón M60") y por `BackupManager` M107 (L224) + sus tests.
- **HMAC-SHA256**: `save_writer.gd` (sistema de saves REAL, fix BUG-115) con clave por instalación.
- **SHA-256 legado**: aceptado por retrocompatibilidad (flag `legacy`).
- La divergencia está **DOCUMENTADA deliberadamente** por DeepSeek en `security_tamper_protection.gd` L19-21: «el diseño declara que el checksum SHA-256 reemplaza al CRC32 débil del autoload. Este helper NO cambia `SecurityManager.validar_save` (autoload en uso); queda como alternativa recomendada para M60/M77».
- **Consecuencia**: si alguien cableara `SecurityManager.validar_save()` sobre un save M59 real (formato `hmac256:<hex>`), compararía `crc32(payload)` contra el token HMAC → **siempre false → "corrupto"**. Hoy no falla en runtime precisamente porque es código muerto (H2) — es una **bomba de tiempo de wiring**.
- **Duplicación lógica**: el HMAC-SHA256 manual existe dos veces (`save_writer.gd` L124-131 y `security_tamper_protection.gd` L14-17+, verificado contra Python). Consolidar en 1 utilidad compartida.

### H4 — `SecurityKeyManager`: presencia-solo, 0 consumidores de producción

- `cargar_desde_entorno()` (inyección de Dictionary para tests, fallback `OS.get_environment`), `validar()` = **todas las claves no-vacías** (presencia), `faltantes()` = auditable sin exponer valores. Correcto para V0.
- **Sin validación de FORMATO** de claves (menor; esperable para secrets heterogéneos — agregar cuando se cablee).
- Consumidores: `editor/_colector_sintaxis.gd:765` + `test_security_m106_services.gd` (L22, L214, L222). **0 producción.**
- Contexto de honestidad: su header (L8-11) documenta el hallazgo P-36 — los 5 ítems de KeyManager estaban `[x]` **sin implementación** (falso verde heredado) y este archivo los convirtió en `[x]` verdaderos. Coherente con GLOBAL («KeyManager implementado tras hallazgo zero-implementation»). Ojo: existencia ✓, cableado ✗ (H1/H2).

### H5 — Aclaración de alcance del encargo ("licencias/audio")

- **Audio**: grep `(?i)audio` sobre `scripts/security/` = **0 hits**. Los flujos de audio son autoloads propios (AudioConfig M91, StreamManager, MusicDirector, AmbientDirector, SFXManager, FeedbackDirector, NarrativeSound — todos en `project.godot`) y **no pasan por M106**. La validación de inputs de audio del usuario (volumen, ducking idempotente) vive en M91 (`test_sfx_m43.gd` L196-281 verifica AudioConfig + AudioServer).
- **Licencias**: viven en **M85** (`scripts/legal/`). `model3d_validator.gd` (35 líneas, DeepSeek 2026-09-02) SÍ existe con 2 `static func`: `validar()` (IDs únicos, licencia no-vacía por asset, políticas no-vacías sobre `data/legal/modelos_3d.json`) y `reporte()`. Es validación de **datos de catálogo**, no de input de usuario. `model_legal_manager` **no existe** (0 hits) — coherente con GLOBAL M85 (73/100: «licenciamiento 3D NO existe»). `TermsManager`/`credits_manager`/`MerchManager` son autoloads legales distintos (términos, créditos, merch) — fuera del alcance input-validation.

### H6 — Calidad de las suites M106: ALTA (guardiansas)

- `test_security_m106_input.gd` L6-7: «Guardián anti-falso-verde: cada bloque marca `_fin()`; fallos reales → exit 1» (bloques A/B/C con `_fin()` en L46).
- `test_checksum_hmac.gd`: guardian 3 capas con piso **MEDIDO** (38 checks) y sondas rojas documentadas.
- **La deuda de M106 es de WIRING, no de TESTING** — contraste con mis Familias A/C del mapa de frágiles (suites sin denominador / suites muertas).

## 3. Veredicto

**M106 = capa de servicios V0 completa (autoload + 7 servicios offline + KeyManager + InputValidator + Tamper HMAC) y bien testeada (237 checks/0 fallos), pero con 0 integración en runtime**: ni `SecurityInputValidator` ni los métodos del autoload tienen consumidores de producción verificables en disco. Para un cozy single-player offline el riesgo inmediato es **BAJO** (no hay red/server; los saves ya tienen su propia defensa HMAC + schema + cap por M59 — ver doc M59). La deuda es **arquitectónica**: «implementado sin cablear» a escala de módulo.

**Propuesta al mapa de frágiles (doc AUDITORIA-SUITES-FRAGILES-1NOV.md): nueva Familia F — "servicios V0 implementados + suites guardiansas + 0 wiring runtime"**. Patrón detectado también en M54 L167. Detector: grep de consumidores de producción del helper/servicio = 0 hits fuera de tests/editor.

## 4. Recomendaciones (para owner M106 / directora)

- **R1**: cablear `SecurityInputValidator` en puntos de entrada de input de usuario de producción (UI M53: nombre de jugador/búsqueda; M87 si acepta input; diálogos M21 si hay texto libre) — con **test de wiring** (grep de consumidor + caso headless que pase input hostil por el flujo real, no por el helper aislado).
- **R2**: reconciliar el dialecto de integridad: adoptar el HMAC de `tamper_protection` en `SecurityManager.validar_save` (o deprecarlo explícitamente como "solo backups M107/CRC32") + consolidar las 2 implementaciones HMAC manuales en 1 utilidad compartida.
- **R3**: convertir `security-scan` de `quality.yml` en gate real (ya reportado como trampa 81: 4 greps con `|| true`). Buen precedente a replicar: en 5d6105a la suite M59 + `quality.yml` viajaron en el MISMO commit (trampa 98 cerrada).
- **R4**: verificar la redacción de los ítems de `05-Checklist.md` de M106: si algún ítem afirma «validación de inputs en runtime/producción» (vs «helper V0 implementado»), sería `[x] inflado` hasta que exista consumidor verificable. Los 12 `[?]` pendientes y los ítems de los 7 servicios merecen esa relectura. **Yo no flippeo nada de M106** (módulo ajeno; QA cruzada §21.8).
- **R5**: KeyManager — al cablearse, agregar validación de formato data-driven por clave; hoy presencia-solo es suficiente para V0.

## 5. Coherencia con CHECKLIST-GLOBAL y cross con otros módulos

- Fila M106 (GLOBAL L42): 🟡 Completado (P-36), 194/206, 12 `[?]`, 3 falsos verdes históricos corregidos (escáner ROJO 20/1, KeyManager zero-implementation, security-scan no-gate). Mis H1-H3 son **deuda NUEVA documentada** — no contradicen los `[x]` existentes si estos dicen «helper V0 implementado» (existencia verificada ✓), pero exigen la relectura de R4.
- **Cross con re-baselines de hoy (nota de coordinación de agnes 328)**: M22 🟡 78/91 (selo invalidado por tautología de spec, Log 2262) y M85 🟡 73/100 (licenciamiento NO existe; validador mínimo de catálogo sí, 35 líneas/2 funciones) son **coherentes** con mi mapa: M22 = Familia E (especificación como única base de un `[x]`), M85 = Familia C (cobertura declarada vs implementación mínima). Mi mapa de frágiles 1-nov queda consistente con ambos sin necesidad de reescribirlo.
- **Audio (aclaración para agnes)**: 0 hits en `scripts/security/` — no hay flujo de audio en M106; la validación de inputs de audio vive en M91. **Licencias**: M85, validador de catálogo mínimo existente, manager legal inexistente.

---

**Firma:** Ling-3.1-Flash / Kilo Code — 2026-10-30 07:09Z. Evidencia verificada en disco (WORKING TREE post-5d6105a). Sin commits propios (report-only, encargo agnes 326).
