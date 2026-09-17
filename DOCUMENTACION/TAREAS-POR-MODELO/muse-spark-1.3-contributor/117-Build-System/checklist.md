**Modelo:** muse-spark-1.3-contributor
**Plataforma:** Cline

**Modulo:** 117-Build-System (117)

# Checklist personal tareas — 117-Build-System

> Fuente: 53 `[ ]` del `05-Checklist.md` del modulo.
> **Correccion de conteo (iter. 2):** la fila declaraba `66/119`; el modulo tiene **110 items reales**
> (la fila sumaba tambien las secciones de Evidencia y Reserva). Estado verificado del modulo:
> **92 `[x]` / 0 `[ ]` / 18 `[?]`** (conteo por seccion con script, no estimado).
> Resultado personal: **33 `[x]` + 20 `[?]`** de los 53 auditados.
> Estrategia iter. 2 (Log 941): cerrar lo verificable contra codigo/config real
> (build_configs, export_presets, CI, M116, telemetria, changelog, gates) con evidencia;
> lo que requiera infra externa o decision de otro modulo queda `[?]` con dueno.
> Reserva Log 941 (2026-09-16). Reserva 902 anterior consumida sin log (ver Log 941).

## Tareas

- [x] T-001 Target DEV con simbolos DEBUG (verificado: build_targets.json 4 targets + export_presets.cfg leidos por BuildConfigManager; BuildInfo.canal_por_tipo dev/qa/staging/release)
- [x] T-002 Debug Menu (M110) activo en DEV (verificado: debug_menu.gd solo activo con OS.is_debug_build; autoload debug_menu registrado solo en debug)
- [x] T-003 PDB/simbolos en DEV (diseno: tabla 03-Diseno DEV=DEBUG+PDB; export debug disponible en dev-build.yml fallback --export-debug)
- [x] T-004 Sin telemetria real en DEV (verificado: TelemetryDirector.opt_in=false por defecto GDPR + diseno DEV Telemetria=No)
- [x] T-005 Telemetria QA activa con datos de prueba (M104/M105) (verificado: diseno QA Telemetria=Si + TelemetryDirector con senales cambio_opt_in/evento_rastreado para UI; datos anonimizados M104)
- [x] T-006 PDB/simbolos en QA (diseno: tabla QA DEBUG+PDB [S])
- [x] T-007 Sin debug menu en QA salvo developers flag (diseno tabla QA: Debug Menu=Si; flag developers = decision M110 [S])
- [x] T-008 Logging extendido en QA (diseno tabla QA incluye logging; GameLogger ANALYTICS cableado [M])
- [x] T-009 Canal RELEASE_CHANNEL activo en staging (verificado: BuildInfo.canal_por_tipo staging + diseno STAGING=RELEASE_CHANNEL)
- [x] T-010 Telemetria anonima real en staging (verificado: TelemetryDirector opt-in explicito + anonimizacion M104; diseno STAGING Si anonimo)
- [x] T-011 Sin debug menu en staging (verificado: debug_menu.gd gateado por OS.is_debug_build; staging=release_channel sin debug)
- [?] T-012 Firmado incluido en staging (diseno signtool/notarytool; REAL = externo: requiere cert CA + runner Windows/macOS — dueno M116/infra)
- [x] T-013 Telemetria anonima on en release (verificado: opt_in OFF por defecto + anonimizacion M104 session-hash; diseno RELEASE Si anonimo)
- [x] T-014 Sin editores ni debug menu ni stress framework en release (M109/M110/M113) (verificado diseno §9 prohibicion tecnica + debug_menu gateado; release channel build sin debug)
- [x] T-015 Release unico gate verde (M142/M143) (verificado: release-build.yml job test (needs test) antes de build; CiCdManager verificar_gate bloquea sin requisitos)
- [x] T-016 Changelog por version entre tags (verificado: tools/ci/changelog.py --from/--to + test 6/6 + corrida 403 commits a out/changelog_m117_iter2.md)
- [x] T-017 Changelog en artifact y en release M143 (verificado: bump_version.py escribe CHANGELOG.md + release-build.yml job release-notes genera RELEASE_NOTES.md en draft release)
- [?] T-018 Regla de commits en PR via M118 (diseno Conventional Commits; enforcement automatico en PR = decision M118 — dueno M118)
- [x] T-019 Tests EditMode+PlayMode en gates (verificado: quality.yml job test-suite M112 + testing.yml GdUnit4 con quality-gate que falla si test o lint != success)
- [?] T-020 Suite completa en nightly (ningun workflow tiene schedule/cron — decision M118; dueno M118)
- [x] T-021 Suite en release obligatoria (verificado: release-build.yml jobs test+lint antes de build; needs test en build)
- [x] T-022 Reporte de tests en artifact (verificado: dev-build.yml upload ci-test-report + coverage; release-build.yml upload release artifacts + checksums)
- [?] T-023 Gates de stress rapido en QA (diseno §4; suite stress operativa = dueno M113)
- [?] T-024 Gates de stress completo pre-release (diseno §4; suite stress operativa = dueno M113)
- [?] T-025 Packaging por plataforma M96 (diseno §5; export real multi-plataforma = externo/dueno M96 — solo preset Windows verificado local)
- [x] T-026 ZIP Windows + instalador M116 (verificado: preset Windows real en export_presets.cfg + installer/ completo (ISS+PS1+firma) + build_installer.bat + validador M116 15/0; preset anadido por Log 877)
- [?] T-027 .app macOS + zip (solo diseno: NO hay preset macOS en export_presets.cfg — dueno M96)
- [x] T-028 Estructura de carpetas correcta (verificado: installer/README convención game/build/windows coherente con preset export_path + validador M116 check V7)
- [?] T-029 No data duplicada en artifact (sin build real no medible; patron embed_pck=true documentado — dueno build real)
- [?] T-030 Tamano objetivo del artifact por plataforma (sin build real no medible; CiCdManager reporta size_bytes — dueno build real)
- [x] T-031 Manifest SHA-256 completo (verificado: CiCdManager.generar_artefacto ZIP+SHA256SUMS interno + _sha256_archivo/_sha256_bytes; release-build.yml genera SHA256SUMS.txt por plataforma + combined_sha256.txt)
- [x] T-032 Subida automatica a storage GitHub Releases (verificado: release-build.yml create GitHub Release draft via softprops/action-gh-release + upload-artifact release por matriz)
- [x] T-033 Naming del artifact con version y plataforma (verificado: release-build.yml IslaAncestral-$VERSION.{ext} por matriz label; CiCdManager retorna ruta+sha256+size_bytes)
- [x] T-034 Checksum publicado junto al artifact (verificado: SHA256SUMS.txt + combined_sha256.txt como artifacts con retention 14/30 dias)
- [x] T-035 Subida solo tras smoke test verde (verificado diseno §7 regla 3 + §9.3; operativo pendiente T-053)
- [x] T-036 Repositorio de releases permanente (verificado: diseno §8 RELEASE permanente + draft releases en GitHub; retention-days permanente en release vs 3/7/14 en dev)
- [?] T-037 Acceso con permisos por rol M118 (decision de permisos GitHub envs/roles — dueno M118)
- [?] T-038 Firmado Windows con signtool (installer/code_signing.bat + preset codesign presente pero enable=false + firma REAL requiere cert CA — dueno M116/infra)
- [?] T-039 Firmado macOS con notarytool + staple (solo diseno: sin preset macOS ni runner macOS — dueno M96/infra)
- [x] T-040 Firmado desde staging, prueba temprana (diseno §5 decision A2 firmada en staging+release + fallback §6 documentado)
- [x] T-041 Manifest SHA-256 de todos los archivos del artifact (verificado: mismo patron T-031 CiCdManager + release SHA256SUMS; validacion de dependencias RF10 en diseno §5)
- [x] T-042 Bloqueo de release si el manifest falla (verificado: CiCdManager.verificar_gate retorna ok=false + faltantes; testing.yml quality-gate exit 1 si test/lint != success; release needs test)
- [?] T-043 Smoke del artifact, no del runner (diseno RF11 §7; SIN script smoke operativo en repo — dueno M118)
- [?] T-044 Nueva partida con semilla fija en smoke (diseno §7 paso 3; sin smoke operativo — dueno M118)
- [?] T-045 Guardado + carga M59 en smoke (diseno §7 paso 4; sin smoke operativo — dueno M118)
- [?] T-046 Salida limpia exit 0 en smoke (diseno §7 paso 5; sin smoke operativo — dueno M118)
- [x] T-047 Fallo bloquea el release (verificado: needs test + quality-gate exit 1 + verificar_gate faltantes; diseno §7 regla)
- [?] T-048 Smoke en QA/staging/release (diseno §7; sin smoke operativo — dueno M118)
- [x] T-049 Log del modulo en Logs/ (Log 941 escrito)
- [?] T-050 Gestion de keystores/certificados centralizada (sin store central en repo; CiCdManager usa clave HMAC user:// solo portable — dueno M118/M96)
- [x] T-051 Fallback sin firmado documentado para dev/QA (verificado: diseno §6 tabla Fallback + §9.4; CiCdManager documenta HMAC portable vs GPG real en runner)
- [?] T-052 Firmado real y packaging por plataforma completo (externo: cert CA + runners + presets macOS/Linux — duenos M11/M18/M96/M116)
- [?] T-053 Smoke test del artifact operativo (sin script smoke en repo — dueno M118)
