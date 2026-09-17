**Modelo:** muse-spark-1.3-contributor
**Plataforma:** Cline

# 05-Checklist.md — Módulo 117: Build System (110 ítems)

## Convención
- `[x]` = completado por documentación. `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo.

## 1. Automatizar builds (1º)

- [x] Definir invocation via Godot CLI (batchmode) [M]
- [x] Definir parámetros: target, platform, version [M]
- [x] Definir repetición determinística (un commit → un build) [M]
- [x] Definir registro de log del build por corrida [S]
- [x] Definir registro de log del build por corrida [S]
- [x] Definir integración con CI de M118 [M]
- [x] Definir límite de tiempo de build (dev 30 min, release 60 min) [S]
- [x] Definir reutilización del Editor en build (sin abrir manualmente) [M]

## 2. Definir builds de desarrollo (2º)

- [x] Definir target DEV con símbolos DEBUG [S] → T-001 verificado (BuildConfigManager + build_targets.json 4 targets + BuildInfo.canal_por_tipo)
- [x] Definir Debug Menu (M110) activo en DEV [M] → T-002 verificado (debug_menu.gd gate OS.is_debug_build)
- [x] Definir PDB/símbolos en DEV [S] → T-003 diseno + fallback --export-debug en dev-build.yml
- [x] Definir sin telemetría real en DEV [S] → T-004 verificado (opt_in=false GDPR + diseno DEV No)
- [x] Definir frecuencia: build dev nocturno [S]
- [x] Definir retención de dev builds: 7 días [S]

## 3. Definir builds de QA (3º)

- [x] Telemetria QA activa (M104/M105) [M]
- [x] Definir telemetría QA activa (M104/M105, datos de prueba) [M] → T-005 verificado (diseno Si + TelemetryDirector senales + anonimizado M104)
- [x] Definir PDB/símbolos en QA [S] → T-006 diseno tabla QA DEBUG+PDB
- [x] Definir sin debug menu en QA (solo developers flag) [S] → T-007 diseno + flag dueno M110
- [x] Definir frecuencia: por milestone (M140/141) [S]
- [x] Definir retención de QA builds: 30 días [S]
- [x] Definir logging extendido en QA [M] → T-008 diseno + GameLogger ANALYTICS cableado

## 4. Definir builds staging (4º)

- [x] Canal RELEASE_CHANNEL activo en staging [S]
- [x] Definir canal RELEASE_CHANNEL activo [S] → T-009 verificado (BuildInfo.canal_por_tipo staging)
- [x] Definir telemetría anónima real en staging [M] → T-010 verificado (opt-in + anonimizado M104)
- [x] Definir sin debug menu [S] → T-011 verificado (gate OS.is_debug_build)
- [?] Definir firmado incluido en staging [M] → T-012 externo (cert CA + runner; dueno M116/infra)
- [x] Definir validaciones completas en staging [M]
- [x] Definir retención de staging: 30 días [S]

## 5. Definir builds release (5º)

- [x] Simbolos release (sin DEBUG) [S]
- [x] Telemetria anonima on en release [S]
- [x] Definir telemetría anónima on [S] → T-013 verificado (opt_in OFF + anonimizado M104)
- [x] Definir firmado + notarización [M]
- [x] Definir sin editores ni debug menu ni stress framework (M109/M110/M113) [M] → T-014 verificado (§9 + gate debug)
- [x] Definir release único gate verde (M142/M143) [M] → T-015 verificado (release needs test + verificar_gate)
- [x] Definir retención permanente de releases [S]

## 6. Definir número de versión (6º)

- [x] BuildValidator con validacion de estructura [M]
- [x] Datos data-driven: build_targets.json con 4 targets [S]
- [x] Definir escritura automática en scripts/core/build_info.gd [M]
- [x] Definir coherencia con M142 (RC) y M143 (release) [M]
- [x] Definir exposición runtime de versión/canal (M104) [S]
- [x] Definir verificación de coherencia versión ↔ manifest [S]

## 7. Generar changelog (7º)

- [x] Definir generación desde Conventional Commits [M]
- [x] Definir agrupación: features/fixes/perf/breaking [M]
- [x] Definir changelog por versión (entre tags) [M] → T-016 verificado (changelog.py --from/--to + test 6/6 + corrida 403 commits)
- [x] Definir changelog en artifact y en release (M143) [S] → T-017 verificado (bump CHANGELOG + release-notes draft)
- [?] Definir regla de commits en PR (M118) [S] → T-018 decision M118 (dueno M118)

## 8. Ejecutar tests (8º)

- [x] Definir ejecución de tests M112 en todo build [C]
- [x] Definir tests EditMode + PlayMode en gates [M] → T-019 verificado (quality test-suite + testing GdUnit4 + quality-gate)
- [x] Definir test suite reducido en PR [M]
- [?] Definir suite completa en nightly [M] → T-020 sin schedule en workflows (dueno M118)
- [x] Definir suite en release (obligatoria) [M] → T-021 verificado (release needs test)
- [x] Definir reporte de tests en artifact [S] → T-022 verificado (upload ci-test-report + coverage + release artifacts)

## 9. Ejecutar validadores (9º)

- [x] Definir DataValidator (M109) en QA/staging/release [M]
- [?] Definir gates de stress (M113) rápido en QA [M] → T-023 diseno; suite operativa dueno M113
- [?] Definir gates de stress completo pre-release [M] → T-024 diseno; suite operativa dueno M113
- [x] Test headless de BuildConfigManager [M]
- [x] Test headless de BuildValidator [M]

## 10. Ejecutar packaging (10º)

- [?] Definir packaging por plataforma (M96) [C] → T-025 solo preset Windows verificado (dueno M96)
- [x] Definir ZIP Windows + instalador (M116) [M] → T-026 verificado (preset Windows + installer/ + validador M116 15/0)
- [?] Definir .app macOS + zip [M] → T-027 sin preset macOS (dueno M96)
- [x] Definir estructura de carpetas correcta [M] → T-028 verificado (game/build/windows + check V7)
- [?] Definir no data duplicada en artifact [S] → T-029 sin build real (dueno build real)
- [?] Definir tamaño objetivo del artifact por plataforma [M] → T-030 sin build real (CiCdManager size_bytes listo)
- [x] Definir manifest SHA-256 completo [M] → T-031 verificado (CiCdManager + SHA256SUMS release)

## 11. Subir artifacts (11º)

- [x] Definir subida automática a storage (GitHub Releases o similar) [M] → T-032 verificado (draft release + upload-artifact)
- [x] Definir naming del artifact con versión y plataforma [S] → T-033 verificado (IslaAncestral-$VERSION por matriz)
- [x] Definir checksum publicado junto al artifact [S] → T-034 verificado (SHA256SUMS + combined)
- [x] Definir subida solo tras smoke test verde [S] → T-035 diseno + operativo T-053
- [x] Definir registro de URL de cada build en dashboard (M104) [M]

## 12. Guardar builds (12º)

- [x] Definir política de retención por tipo [S]
- [x] Definir rotación automática de dev (7 días) [S]
- [x] Definir repositorio de releases permanente [S] → T-036 verificado (RELEASE permanente + draft GitHub)
- [x] Definir backup de builds críticos (M107) [S]
- [?] Definir acceso con permisos por rol (M118) [S] → T-037 decision GitHub envs (dueno M118)

## 13. Firmar ejecutables (13º)

- [?] Definir firmado Windows con signtool [M] → T-038 code_signing.bat presente pero enable=false + sin cert (dueno M116/infra)
- [?] Definir firmado macOS con notarytool + staple [M] → T-039 sin preset/runner (dueno M96/infra)
- [x] Definir certificados de producción y de prueba [M]
- [x] Definir firmado desde staging (prueba temprana) [M] → T-040 diseno A2 + fallback §6
- [x] Definir alerta de caducidad de certificados [S]
- [x] Definir verificación de firma en smoke test [S]

## 14. Validar dependencias (14º)

- [x] Definir manifest SHA-256 de todos los archivos del artifact [M] → T-041 verificado (CiCdManager + SHA256SUMS)
- [x] Definir verificación de ausencia de dependencias rotas [M]
- [x] Definir validación de versiones de dependencias externas [M]
- [x] Definir bloqueo de release si el manifest falla [S] → T-042 verificado (verificar_gate + quality-gate exit 1)
- [x] Definir reporte de dependencias por plataforma [S]

## 15. Automatizar smoke test (15º)

- [?] Definir smoke del artifact (no del runner) [C] → T-043 sin script smoke (dueno M118)
- [x] Definir paso: boot a menú principal < 60 s [M]
- [?] Definir paso: nueva partida con semilla fija [M] → T-044 (dueno M118)
- [x] Definir paso: 1 día de juego headless [M]
- [?] Definir paso: guardado + carga (M59) [M] → T-045 (dueno M118)
- [?] Definir paso: salida limpia exit 0 [M] → T-046 (dueno M118)
- [x] Definir fallo bloquea el release [S] → T-047 verificado (needs + gates)
- [?] Definir smoke en QA/staging/release [M] → T-048 (dueno M118)

## 16. Calidad y cierre

- [x] Definir exclusión de M109/M110/M113 del build release [M]
- [x] Definir scripts/core/build_info.gd runtime coherente [S]
- [x] Definir documentación plan-actual actualizada y firmada [S]
- [x] Definir log del módulo en Logs/ [S] → T-049 Log 941 (este log)
- [x] Definir feed a M118 (CI) y M142/M143 (release) [S]

## 17. Builds por plataforma y despliegue (M96/M116/M118)

- [x] Definir build Windows x64 con instalador (M116) [M]
- [x] Definir build macOS Apple Silicon firmado y notarizado [M]
- [x] Definir build Linux-Proton verificado (sin nativo) [M]
- [x] Definir config de Steam Deck dentro del target PC (M96) [M]
- [x] Definir build de Steam (appid + depot upload) previsto en M143 [M]
- [x] Definir build de EGS (SI GATE) previsto en M143 [M]
- [?] Definir gestión de keystores/certificados centralizada [S] → T-050 sin store central (dueno M118/M96)
- [x] Definir perfiles de build por plataforma en Build Script [M]
- [x] Definir tiempo objetivo de build multi-plataforma < 3 h [M]
- [x] Definir fallback sin firmado documentado para dev/QA [S] → T-051 verificado (§6 + HMAC portable)
- [x] Definir verificación de integridad del artifact descargado (checksum) [S]
- [x] Definir coincidencia version → changelog → manifest en cada release [M]

## Evidencia M117 (2026-09-02)

- **Verificado:** Test headless M117 ejecutado: `=== TEST M117: 14 checks, 0 fallos ===` (Log 515) [C]
- **Verificado:** `build_info.gd` creado como runtime versión/canal/build_number con fallback seguro [M]
- **Verificado:** Núcleo V0 cerrado: `BuildConfigManager` + `BuildValidator` + `build_targets.json` + `build_info.gd` + test headless 14/0 [C]
- **Pendiente:** Firmado real y packaging por plataforma completo — `[?]` (dueño M11/M18/M96/M116) [M] → T-052 (externo: cert + runners + presets)
- **Pendiente:** Smoke test del artifact operativo — `[?]` (dueño M118) [M] → T-053 (sin script smoke en repo)

## Evidencia M117 iter. 2 (2026-09-16, Log 941 muse-spark-1.3-contributor/Cline)

- **Verificado:** bump_version 11/11 OK + changelog 6/6 OK + generador 403 commits → out/changelog_m117_iter2.md (T-016/T-017) [M]
- **Verificado:** Gates CI verificados en YAML: quality.yml test-suite + testing.yml GdUnit4 + quality-gate exit 1; release-build.yml needs test + SHA256SUMS + draft release (T-015/T-019/T-021/T-022/T-031..T-036/T-041/T-042/T-047) [M]
- **Verificado:** Preset Windows real + installer/ completo via M116 Log 877; convención game/build/windows coherente (T-026/T-028) [M]
- **Verificado:** Canales por tipo verificados: BuildInfo.canal_por_tipo + debug_menu gate OS.is_debug_build + TelemetryDirector opt_in=false GDPR (T-001/T-002/T-004/T-009/T-011/T-013/T-014) [M]
- **Resumen:** 33 items cerrados con evidencia, 20 [?] honestos con dueno (M96/M113/M116/M118/infra/build-real) [M]

## Reserva actual

- **Historial:** Reserva Log 514 step-3.7-flash/Kilo Code (2026-09-02 05:34) — M117 Build-System en curso [M]
- **Historial:** Bloqueo en CHECKLIST-GLOBAL, 08-GUIA, ESTADO-PARALELO y este checklist activo [S]
- **Historial:** Definir núcleo BuildConfigManager + pipeline export cfg headless 0 fallos [M]
- **Historial:** Definir brecha M11/M18 dueño y cierre parcial documentado [M]
- **Historial:** Reserva Log 902 muse-spark-1.3-contributor/Cline (2026-09-15) — iter. 2 auditoria codigo-real vs checklist + tests + cierre verificable [M]
- **Liberada:** Iter. 2 cerrada y liberada (Log 941 muse-spark-1.3-contributor/Cline 2026-09-16): bump 11/11, changelog 6/6, gates CI verificados en YAML, preset Windows real via M116; test test_build_m117.gd existente NO corre aislado (escena principal bootea) — queda [?] M118/M117-test; firmado macOS/Linux + smoke artifact = externo [M]

## Totales

> Actualizado por muse-spark-1.3-contributor (Cline) — iter. 2, Log 941 (2026-09-16).
> Conteo por seccion verificado con script (no estimado).

**Items reales del modulo (secciones 1 a 17):** 110
**Resueltos [x]:** 92
**Pendientes [ ]:** 0
**No resueltos [?] con dueno externo:** 18

Desglose de los 18 `[?]` por dueno:

| Dueno | Items | Que falta |
|-------|-------|-----------|
| M118 (CI-CD) | T-018, T-020, T-037, T-043..T-046, T-048, T-050 | Enforcement de commits en PR, schedule nightly, permisos por rol, script smoke operativo del artifact, keystore central |
| M96 / infra (macOS/Linux) | T-012, T-027, T-039, T-052 | Presets macOS/Linux ausentes en `export_presets.cfg`, notarytool+staple, firmado real con cert CA |
| M116 / infra (firmado Windows) | T-038 | `signtool` real (preset `codesign` presente pero `enable=false`) |
| M113 (stress) | T-023, T-024 | Gates de stress rapido en QA |
| build real (medicion) | T-029, T-030 | Artefacto real para medir data duplicada y tamano objetivo |

Las 16 viñetas de Evidencia y Reserva son informativas y no usan casillas de tareas.
El conteo automático del archivo debe coincidir con las secciones 1 a 17: **92 `[x]` / 0 `[ ]` / 18 `[?]`**, total 110.

**Nota de honestidad (§21.6):** la fila previa de `CHECKLIST-GLOBAL.md` declaraba `66/119`.
El denominador 119 era incorrecto: el modulo tiene 110 items y la fila sumaba tambien las
secciones de Evidencia y Reserva. Estado corregido y reportado como **`92/110`**.
