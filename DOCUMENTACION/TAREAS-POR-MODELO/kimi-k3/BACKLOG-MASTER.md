**Modelo:** kimi-k3 (Moonshot AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-20
**Curado por:** atria-dawn (Kilo Code) — coordinacion Log 1091/1092

# BACKLOG-MASTER — kimi-k3

> **Total: 141 tareas reales** extraidas de los `05-Checklist.md` (no inventadas).
> Fuente de verdad: los `05-Checklist.md` de cada modulo. Esta carpeta es tu espejo de trabajo.
> **Como trabajas:** lee tu backlog, elige la siguiente tarea `[ ]` o `[?]`, ejecutala,
> verifica con binario real, marca `[x]` en los **3 registros** (este backlog,
> `05-Checklist.md` del modulo con marcas **Y** linea `**Totales:**`, fila de
> `CHECKLIST-GLOBAL.md`), y reserva un log por lote.

## Perfil (fortalezas medidas en este repo)

- **Fuerza:** Coder agentic #1 del catalogo (TB 2.1 88.3, MCPMark 94.5), contexto 1M, vision nativa. **Evidencia del repo: 5/5 tareas rc=0** (4 seguridad + middleware rate limiting, 87 checks totales), ~9 min/tarea, cero sobre-cierre, auto-correccion documentada.
- **Debilidades honestas:** Thinking siempre on (usar reasoning_effort low en tareas simples). **NO tomar:** QA cruzado §21.8 (Hy3), orquestacion MCPs (Atria), investigacion web (Atria), arte 3D (Hy4), M110 (bloqueado).

## Modulos asignados

> **Actualizado 2026-10-02 por atria-dawn:** M106 y M122 estan ✅ Completado
> (P-36, ejecutado por otros modelos). Las 141 tareas de abajo son el espejo
> stale de esos modulos — **ignoralas**. Tu modulo activo ahora es M70.

| Modulo | Pendientes | Notas |
|---|---:|---|
| [70-Interacciones](70-Interacciones/checklist.md) | 5 (+38 [?] externos) | **🟡 Liberado (iter. 3)** — gestor cerrado, Log 1185 (2026-10-02) |

### 70-Interacciones (🟡 liberado — iter. 3)

-Codigo real: `game/isla-ancestral/scripts/interacciones/`
  (`interaction_manager.gd`, `interactable_base.gd`, `catalogo_categorias.gd`,
  `categoria_interaccion.gd`, interfaz `IInteractable` v3).
- Suite headless: `res://scripts/interacciones/test_interacciones.gd`
  (**119 checks OK / 0 fallos / 0 SCRIPT ERROR** — binario Godot 4.7.2,
  verificado 2026-10-02 iter 3).
- Plan: `DOCUMENTACION/70-Interacciones/plan-actual/05-Checklist.md`
  (**155 [x] / 5 [ ] / 38 [?]**).
- Dependencias: M11 (player ✅), M13 (tool_controller ✅) — satisfechas.
- Iter 3 (Log 1185): watchdog configurable, cancelacion por distancia RF12,
  cooldown RF16 en evaluacion, atenuado RF22 solo-sin-validos, bloqueo real
  RF10, PAUSABLE RF25 + hook modal M53 (RF14), item_seleccionado M14 en despacho.
- Quedan 5 [ ]: hook FSM M11 (DORMIDO si ocupado), lectura FSM M11 completa,
  flujo persistencia diferida 0.5 s (M59), unificacion tecla E/F (M57),
  escenario cosecha 30 plantas (bench). Los 38 [?] tienen dueno externo
  (M53/M154 render, M44, M87, M57, 11 consumidores, M61, M59).

## Orden de prioridad

1. **M70 Interacciones** — 🟡 liberado (iter. 3). Retomar solo si se asigna
   una iter. 4 (hook FSM M11 o coordinacion con M53 para el render del prompt).

## Tareas (extraidas de los checklists reales)

### 106-Seguridad (57 pendientes)

- [ ] Definir no almacenar claves en código fuente
- [ ] Diseñar archivo .env.local para desarrollo (en .gitignore)
- [ ] Definir entornos separados (dev/staging/prod)
- [ ] Diseñar bases de datos separadas por entorno
- [ ] Definir firewalls (solo puertos necesarios)
- [ ] Definir monitoreo de vulnerabilidades
- [ ] Diseñar monitoreo de logs de acceso
- [ ] Diseñar monitoreo de métricas de seguridad
- [ ] Diseñar alertas por anomalías de seguridad
- [ ] Definir usuarios de base de datos con permisos mínimos necesarios
- [ ] Diseñar checksums de savegame (SHA-256)
- [ ] Definir checksums de datos de economía
- [ ] Definir límites de economía (max gold, max items)
- [ ] Definir CAPTCHA para rate limiting excedido
- [ ] Definir rate limiting por IP
- [ ] Definir rate limiting por usuario
- [ ] Definir rate limiting por endpoint
- [ ] Diseñar bloqueo de IPs sospechosas
- [ ] Diseñar logs almacenados en servidor
- [ ] Diseñar logs monitoreados regularmente
- [ ] Diseñar alertas por anomalías en logs
- [ ] Definir monitoreo de nuevas vulnerabilidades
- [ ] Diseñar signal rate_limit_exceeded()
- [ ] Diseñar método setup_rate_limiting()
- [ ] Diseñar método check_rate_limit()
- [ ] Diseñar variable rate_limit
- [ ] Diseñar variable request_count
- [ ] Diseñar variable rate_limit_timer
- [ ] Diseñar método validate_string(input, min_length, max_length)
- [ ] Diseñar método validate_int(input, min_value, max_value)
- [ ] Diseñar método validate_float(input, min_value, max_value)
- [ ] Diseñar método validate_email(input)
- [ ] Diseñar método sanitize_string(input)
- [ ] Diseñar método validate_checksum(data, expected_checksum)
- [ ] Diseñar método calculate_sha256(data)
- [ ] Diseñar método calculate_checksum(data)
- [ ] Diseñar método calculate_hmac(data)
- [ ] Diseñar método validate_savegame(savegame_data, checksum)
- [ ] Diseñar método validate_savegame_signature(savegame_data, signature)
- [ ] Diseñar método generate_request_id()
- [ ] Diseñar método is_request_processed(request_id)
- [ ] Diseñar método mark_request_processed(request_id)
- [ ] Diseñar método cleanup_old_requests()
- [ ] Diseñar variable processed_requests (Dictionary)
- [ ] Diseñar método validate_economy(player_data)
- [ ] Diseñar método validate_economy_checksum(player_data, checksum)
- [ ] Diseñar variable max_gold
- [ ] Diseñar variable max_items
- [ ] Diseñar método log_access(user_id, action, result)
- [ ] Diseñar método print_audit_log(log_entry)
- [ ] Diseñar método save_audit_logs()
- [ ] Diseñar variable audit_logs (Array)
- [ ] Diseñar propiedad max_gold
- [ ] Diseñar propiedad max_items
- [ ] Diseñar propiedad enable_checksum_validation
- [ ] Diseñar propiedad enable_signature_validation
- [ ] Diseñar propiedad enable_duplication_prevention
- [ ] Diseñar propiedad enable_economy_validation
- [ ] Diseñar propiedad enable_audit_logging
- [ ] Diseñar .env.example (plantilla)
- [ ] Diseñar prueba de rate limiting

### 122-Crash-Reporting (80 pendientes)

- [ ] Capturar memoria
- [ ] Capturar escena
- [ ] Capturar contexto seguro
- [ ] Evaluar Sentry como fallback
- [ ] Documentar ventajas de Sentry
- [ ] Documentar desventajas de Sentry
- [ ] Definir qué datos NO incluir (PII, datos sensibles)
- [ ] Definir qué datos SI incluir (categorías, tipos)
- [ ] Diseñar ejemplo de contexto seguro
- [ ] Diseñar ejemplo de contexto NO seguro
- [ ] Definir lista de unsafe keys (username, ip, email, phone, address, inventory, chat, api_key, token)
- [ ] Diseñar algoritmo de hashing de stack trace
- [ ] Definir niveles de impacto (todos, algunos)
- [ ] Definir prioridades (CRÍTICA, ALTA, MEDIA, BAJA)
- [ ] Diseñar filtros por severidad
- [ ] Diseñar filtros por impacto
- [ ] Diseñar ordenamiento por prioridad
- [ ] Definir paso 3: Corregir bug
- [ ] Definir paso 5: Desplegar patch
- [ ] Diseñar asserts no eliminados (debug mode)
- [ ] Diseñar símbolos de debug para stack traces detallados
- [ ] Diseñar profiling habilitado (M61)
- [ ] Definir nivel de log (CRITICAL)
- [ ] Diseñar contenido de log (stack trace, metadata, contexto)
- [ ] Diseñar guardado de log en archivo
- [ ] Diseñar inclusión de stack trace en issue
- [ ] Diseñar inclusión de metadata en issue
- [ ] Diseñar inclusión de contexto en issue
- [ ] Diseñar panel de "Diagnostics" en Debug Menu
- [ ] Diseñar formato de metadata en Debug Menu
- [ ] Diseñar checkbox en settings (M90)
- [ ] Diseñar cumplimiento GDPR
- [ ] Diseñar datos anonimizados
- [ ] Diseñar guardado local cuando no hay conexión
- [ ] Diseñar envío automático al reconectar
- [ ] Diseñar no envío de datos en tiempo real (batch)
- [ ] Diseñar compresión de datos antes de envío
- [ ] Diseñar mínimo impacto en FPS
- [ ] Diseñar filtros (versión, plataforma, escena)
- [ ] Diseñar check_alerts()
- [ ] Diseñar _send_alert()
- [ ] Diseñar cumplimiento GDPR
- [ ] Diseñar tests manuales
- [ ] Diseñar test de opt-out
- [ ] Diseñar test de offline mode
- [ ] Diseñar tests automáticos
- [ ] Diseñar _collect_metadata()
- [ ] Diseñar _sanitize_context()
- [ ] Diseñar _save_to_cache()
- [ ] Diseñar _has_connection()
- [ ] Diseñar MetadataCollector.gd
- [ ] Diseñar collect_hardware_metadata()
- [ ] Diseñar collect_software_metadata()
- [ ] Diseñar collect_game_context()
- [ ] Diseñar ContextSanitizer.gd
- [ ] Diseñar sanitize()
- [ ] Diseñar _is_unsafe_key()
- [ ] Diseñar lista de unsafe keys
- [ ] Diseñar clear_cache()
- [ ] Diseñar _load_cache()
- [ ] Diseñar _save_cache()
- [ ] Diseñar MAX_CACHE_SIZE = 10
- [ ] Diseñar has_connection()
- [ ] Diseñar api_key
- [ ] Diseñar headers HTTP
- [ ] Diseñar manejo de respuesta HTTP
- [ ] Diseñar nivel CRITICAL
- [ ] Diseñar contenido de log (error, stack trace, metadata, contexto)
- [ ] Diseñar _format_issue_body()
- [ ] Diseñar _create_github_issue()
- [ ] Diseñar uso de GitHub API
- [ ] Diseñar add_diagnostics_panel()
- [ ] Diseñar _format_metadata()
- [ ] Diseñar check_alerts()
- [ ] Diseñar _send_alert()
- [ ] Diseñar formato de alerta
- [ ] Diseñar 06-Plan-Testings.md (APLICA)
- [ ] Diseñar tests de offline mode
- [ ] Integración M103/M102/M110 completa — `[?]` (dueño M103/M102/M110)
- [ ] Metadata avanzada, sanitización, dashboard — `[?]` (dueño M61/M114)


---

## Recordatorios del protocolo (obligatorios)

- **Reserva log:** `python scripts/reservar_log.py --reservar --agente kimi-k3 --modulo <X>`
- **Binario Godot 4.7.2:** `D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`
  `--headless --path game/isla-ancestral --quit --script res://...`
- **Anti-falso-verde (leccion 28):** exit code **Y** 0 SCRIPT ERROR en stderr. Exit 0 con
  SCRIPT ERROR = fallo disfrazado.
- **Sync de los 3 registros** al cerrar cada lote — **incluida la linea `**Totales:**`**
  (drift endemico: M09/M11/M12/M126/M128/M115/M149 lo sufrieron esta semana).
- **Push a git: NEGATIVO** (instruccion del usuario).
- **Codificacion UTF-8 obligatoria** (sin BOM). Si un diff muestra mojibake, corregir antes de seguir.
- **Honestidad:** un `[?]` con dueno vale mas que un `[x]` falso (DoD §21.6). Si una tarea
  te supera, dejala `[?]` con explicacion.
- **No tocar modulos 🔵/🔴** de otros agentes (§21.4).

---

## Estado

**BACKLOG v1 curado por encaje** (primera sesion, alta 2026-09-19).
- [x] Log reservado: **1077** — M106 T-001 economía adulterada (validar_economia) + fix transversal M107 BUG-058/E-22 → **Log creado** `Logs/1077-M106-T001-Economia-Adulterada-Fix-M107_2026-09-19_04-50-00.md`. M106: 1/66 → suite 21/0 verde, 0 SCRIPT ERROR.
- [x] Log reservado: **1080** — M106 T-002 prevenir bots (registrar_accion_bot, timing inhumano data-driven) + test bloque E → **Log creado** `Logs/1080-M106-T002-Prevenir-Bots_2026-09-19_05-10-00.md`. M106: 2/66 → suite 27/0 verde, 0 SCRIPT ERROR.
- [x] Log reservado: **1081** — M106 T-003 registrar accesos importantes (registrar_acceso + volcar_audit_log local) + test bloque F → **Log creado** `Logs/1081-M106-T003-Registrar-Accesos_2026-09-19_05-20-00.md`. M106: 3/66 → suite 35/0 verde, 0 SCRIPT ERROR.
- [x] Log reservado: **1082** — M106 T-004 rate limiting por IP/usuario/endpoint (verificar_limite_tasa ventana deslizante, catálogo limites_tasa) + test bloque G → **Log creado** `Logs/1082-M106-T004-Rate-Limiting_2026-09-19_05-35-00.md`. M106: 4/66 → suite 43/0 verde, 0 SCRIPT ERROR.
- [x] Log reservado: **1086** — M106 T-005 middleware rate limiting (security_rate_limit_middleware.gd + tasa_reintento_s) + test_security_m106_middleware.gd → **Log creado** `Logs/1086-M106-T005-Middleware-RateLimiting_2026-09-19_05-55-00.md`. M106: 5/66 → middleware 19/0, total M106 87 checks verde.
- [x] Log reservado: **1088** — M106 T-006 no almacenar claves en código fuente (security_secret_scanner.gd) + test_security_m106_secrets.gd → **Log creado** `Logs/1088-M106-T006-Secret-Scanner_2026-09-19_06-15-00.md`. M106: 6/66 → secrets 20/0, total M106 107 checks verde.
- [x] Log reservado: **1126** — M106 T-007 .env.local para desarrollo + cobertura .gitignore + test_security_m106_env.gd → **Log creado** `Logs/1126-M106-T007-Env-Local-Gitignore_2026-09-20_04-53-00.md`. M106: 7/66 → env 13/0, total M106 120 checks verde.
- [x] Log reservado: **1132** — M106 T-008 entornos separados dev/staging/prod (security_environments.json + resolver) + test_security_m106_environments.gd → **Log creado** `Logs/1132-M106-T008-Entornos-Separados_2026-09-20_04-58-00.md`. M106: 8/66 → envs 24/0, total M106 144 checks verde.
- [x] Log reservado: **1185** — M70 iter. 3 cierre del gestor (watchdog configurable, cancelacion por distancia RF12, cooldown RF16, atenuado RF22, bloqueo RF10, PAUSABLE RF25 + hook modal M53, item_seleccionado M14) + 7 tests nuevos → **Log creado** `Logs/1185-M70-Iter3-Cierre-Gestor_2026-10-02_23-55-00.md`. M70: 77 → **155/198** (5 [ ] / 38 [?] con dueno) → suite **119 checks OK / 0 fallos / 0 SCRIPT ERROR**. Modulo 🟡 liberado.

## Flujo por tarea

1. Elegir T-### de este backlog (en orden de prioridad).
2. Reservar log: `python scripts/reservar_log.py --reservar --agente kimi-k3 --modulo <ID>`.
3. Leer `plan-actual/` del modulo + codigo real antes de tocar nada.
4. Implementar / documentar / testear (binario real Godot 4.7.2 headless).
5. Verificar: exit code real + 0 SCRIPT ERROR en stderr (anti-falso-verde, leccion 28).
6. Marcar `[x]` en los 3 lugares: este checklist, `05-Checklist.md` del modulo, fila CHECKLIST-GLOBAL.
7. Escribir `## Notas del Agente` en `04-Codigo.md` del modulo al cerrar.
8. Liberar el modulo (nunca dejar 🔵/🔴 huerfano).

## Firmas

**Creado:** atria-dawn-preview / Kilo Code — 2026-09-19 07:30


---

## Guia de comunicacion (Modo Canal) - 2026-10-03

**El detalle va a tu carpeta de mensajes; el chat solo avisa.**

Cuando termines (o abortes) un item, escribis el informe completo en `Mensajes entre modelos/kimi-k3/` (archivo nuevo numerado, con firma y Responde a) y, por el chat, **una sola linea**:

> termine `[item]`, informe en mi carpeta

No repitas el contenido del informe por el chat: ya esta escrito, el director lo lee de tu carpeta. Si abortaste: `aborte [item]: [motivo de una linea]. informe en mi carpeta`. Si tenes una pregunta que bloquea: escribi el archivo con la pregunta y una linea en el chat: `pregunta en mi carpeta: [la pregunta]`.

Guia completa: `Mensajes entre modelos/GUIA-COMUNICACION.md` (lectura obligatoria).
