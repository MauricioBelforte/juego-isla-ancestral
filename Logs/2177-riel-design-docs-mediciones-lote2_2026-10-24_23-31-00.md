# Log 2177: Riel design-docs lote 2 — mediciones M72/M105/M107/M119 + 7 cierres 997

**Fecha:** 2026-10-24
**Hora:** 23:31
**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code

## Resumen
Cierre del lote 2 del riel design-docs SIN DATOS (GO agnes msg 258, canal Ling-3.1-Flash). Mediciones produce-first en disco de M72/M105/M107/M119 (grep + lectura directa de runtime/data; Godot NO ejecutado) → 4 secciones "Presupuestos numericos III" en los 03-Diseno.md + 7 cierres de ítems degradados 997 en los 05-Checklist.md + 4 notas de riel. Tabla: hecho=7 cierres + 4 III + 4 notas · skip=0 · fail=0. Anti-colisión verificada (ninguno de los 4 módulos estaba 🔵).

## Cambios Realizados
- **M72 Logros** (03 III ###4-6, inicia L319): umbrales amistad friendship.json 30/70/120/150/260 confirmados en disco (balance_service.gd L32 consumidor) + DRIFT triple vs amistad_config.tres [0,20,40,70,100,140,190,250,320,400,500] inyectada en runtime (friendship_service.gd L143-146; test_amistad_rf48_m20.gd L45 espera la serie .tres). Recompensas por tier NO implementadas (0 hits recompensa/tier/reward en achievement_service.gd 552L; vigentes = hitos M71, progression_manager.gd L20/794-798). Colección 99% NO existe: runtime 100% estricto (coleccionables_manager.gd L201-204; collection_registry.gd L134-141; recompensa exposición idempotente L108-111 + donation_service.gd L57-60). Catálogo 17 logros vs diseño 20-30; 5 logros comparten stat_id "regalos_dados" con semánticas distintas; dias_en_aurora (L252-265) usa viajes_realizados umbral 30. HALLAZGO DE ALCANCE: 05 L383-385 ya [x] con fórmula Beam 312 pero SIN marcador "[?] capa-II placeholder" → 0 cierres aplicables (los 3 [?] de M72 son deuda externa M59/M87/M117-118).
- **M105 Telemetría** (03 III ###7-9, inicia L153): telemetry_director.gd 533L, autoload TelemetryDirector (project.godot L29), 19 EVT L101-121, 6 métricas L124-129, opt-in GDPR default false (user://settings/telemetry.cfg), delega 100% a AnalyticsDirector L342-351, timers 1s polling L282-297; SIN limitador por-frame ni buffer propio → batching real en M104 (batch_interval_min=30.0, analytics_director.gd L36/63 = 30 MIN + flush on exit L68-71) — DRIFT vs diseño flush 30s/100 eventos (03 L122). 0 hits schema_version en scripts/telemetry/+analytics/ (no versiona payload; semver vive en M119 versions.json y logros.json schema_version=2). Cross-ref M144 (144-Despues-Del-Lanzamiento 03 L6-17): 7/9 métricas con fuente M105 medidas — plenas tutorial/dificultad/contenido; insumos onboarding (5 time_to_first + tutorial) y retención (session×2 + duration, agregado M104 L154); economía NO capturada (telemetry_bridge.gd L54-56 purchase_done 0 emisores en producción; única fila quest.prereq_met→track_seal_first_obtained L57-65, emisor story_manager.gd:187; 13 track_* sin llamadores pre-bridge L9-14). Refina flag H21 (onboarding SÍ tiene insumos). DRIFT CI: suites iter8 + test_telemetry_bridge_m105 NO cableadas (quality.yml L487-490 cablea 4/6; pisos CHECKS_MINIMOS L480-486).
- **M107 Backups** (03 III #9-10, inicia L705): backup_manager.gd 407L, autoload BackupManager (project.godot L119), DIR user://backups/ L14, _max_copias default 5 L48-49, verificar_integridad L213-224 formato "checksum\npayload" + Validador.crc32_hex L224, gate restore L254. backup_policy.json: dias_maximos 30, max_copias_por_categoria 5, SIN campo algoritmo (corrección Lote B precisa). backup_categories.json 84L: 7 categorías retencion_dias 365/90/180/365/90/180/180 (L10-65), frecuencias continuo×4/post_release×1/semanal×2, GFS 30/52/60 + permanentes L68-73, algoritmo CRC32 L76, zip nivel 6 L79-83. Dual integridad CONFIRMADO: CRC32 runtime + SHA-256 scripts/backup/verify_backups.ps1 L78 (checksums.txt hex64 L53, mensual/ L70, verify.log L93-95, exit 0/1/2). DRIFTS: _limpiar_existentes_cat hardcodea max_dias=30 (L315, ignora retencion_dias por categoría); limpieza raíz max global L302-312 vs por-cat L314-335; frecuencias no automatizadas en runtime (bajo demanda; ejecutor externo backup_local.ps1); cadencia SHA-256 mensual = MANUAL (0 scheduler; CI no cablea verify — quality.yml L358-362 solo test_backup_m107.gd).
- **M119 Actualizaciones** (03 III ###11-12, inicia L398): update_manager.gd 92L, autoload UpdateManager (project.godot L112), versions.json 3 canales (estable 1.0.0 / beta 1.1.0-beta.1 / dev 1.1.0-dev.3) + politica min_versiones_atras 2; 0 hits Timer/_process/intervalo/cron → 100% pasivo (hotfix<72h/patch 30d/<48h = proceso operativo M144 03 L19-25, no runtime); comparar_versiones L45 ignora pre-release (L56 split('-')[0]; test_updates_m119.gd L52 lo espera). 0 hits canary/rollout/circuit/fail_rate en game/; RollbackManager citado en 03 L365 INEXISTENTE (scripts/updates/ = solo 2 archivos); mecanismo real = promoción entre canales + min_versiones_atras 2. DRIFT CI: test_updates_m119.gd (73L) NO cableado en quality.yml (M72 L523-528 / M105 L487-490 / M107 L358-362 sí lo están).
- 7 cierres inline en 05: M105 L387-389 (×3), M107 L408-409 (×2), M119 L212-213 (×2) — sufijo "✅ COMPLETADO degradado 997 (Ling-3.1-Flash 2026-10-25, riel design-docs agnes msg 258 lote 2)" con medición y drift por ítem.
- 4 notas de riel al final de los 4 × 05-Checklist.md (M72 documenta el hallazgo de 0 placeholders abiertos).
- 12 drifts nuevos (D6-D17) encolados a la directora en informe 259 con evidencia archivo:Línea.

## Archivos Modificados/Creados
- DOCUMENTACION/72-Sistema-De-Logros/plan-actual/03-Diseno.md (+III ###4-6)
- DOCUMENTACION/72-Sistema-De-Logros/plan-actual/05-Checklist.md (+nota riel)
- DOCUMENTACION/105-Telemetria-De-Gameplay/plan-actual/03-Diseno.md (+III ###7-9)
- DOCUMENTACION/105-Telemetria-De-Gameplay/plan-actual/05-Checklist.md (cierres L387-389 + nota)
- DOCUMENTACION/107-Backups/plan-actual/03-Diseno.md (+III #9-10)
- DOCUMENTACION/107-Backups/plan-actual/05-Checklist.md (cierres L408-409 + nota)
- DOCUMENTACION/119-Actualizaciones/plan-actual/03-Diseno.md (+III ###11-12)
- DOCUMENTACION/119-Actualizaciones/plan-actual/05-Checklist.md (cierres L212-213 + nota)
- Backups: Obsoletos/lote2-riel-backup-20261024_232234/ (8 archivos)
- Mensajes entre modelos/Ling-3.1-Flash/259-2026-10-24_23-30-00-de-ling-3-1-flash-a-agnes-3-flash-riel-258-lote2-cerrado.md
- Logs/2177-riel-design-docs-mediciones-lote2_2026-10-24_23-31-00.md (este log)
- Backlog propio: línea ESTADO + ANEXO MEDICIONES RIEL 258

## Numeración
- Mensaje 259 consumido del pool del canal (scripts/proximo_numero.py saneó el 258 de agnes ya usado en el hilo — patrón gemelo 256/256 reportado para saneo de la directora).
- Log 2177 consumido de Logs/NUMEROS_DISPONIBLES.txt (2176 fue consumido por Step-5/M23).
