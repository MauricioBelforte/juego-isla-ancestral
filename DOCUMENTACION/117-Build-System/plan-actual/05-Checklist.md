**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 117: Build System (110 ítems)

## Convención
- `[ ]` = completado por documentación. `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo.

## 1. Automatizar builds (1º)

- [ ] Definir BuildScript.cs como punto único de builds [C]
- [ ] Definir invocación vía Unity CLI (batchmode) [M]
- [ ] Definir parámetros: tipo, plataforma, versión [M]
- [ ] Definir repetición determinística (un commit → un build) [M]
- [ ] Definir registro de log del build por corrida [S]
- [ ] Definir integración con CI de M118 [M]
- [ ] Definir límite de tiempo de build (dev 30 min, release 60 min) [S]
- [ ] Definir reutilización del Editor en build (sin abrir manualmente) [M]

## 2. Definir builds de desarrollo (2º)

- [ ] Definir target DEV con símbolos DEBUG [S]
- [ ] Definir Debug Menu (M110) activo en DEV [M]
- [ ] Definir PDB/símbolos en DEV [S]
- [ ] Definir sin telemetría real en DEV [S]
- [ ] Definir frecuencia: build dev nocturno [S]
- [ ] Definir retención de dev builds: 7 días [S]

## 3. Definir builds de QA (3º)

- [ ] Definir target QA con símbolos DEBUG [S]
- [ ] Definir telemetría QA activa (M104/M105, datos de prueba) [M]
- [ ] Definir PDB/símbolos en QA [S]
- [ ] Definir sin debug menu en QA (solo developers flag) [S]
- [ ] Definir frecuencia: por milestone (M140/141) [S]
- [ ] Definir retención de QA builds: 30 días [S]
- [ ] Definir logging extendido en QA [M]

## 4. Definir builds staging (4º)

- [ ] Definir target STAGING como réplica de release [M]
- [ ] Definir canal RELEASE_CHANNEL activo [S]
- [ ] Definir telemetría anónima real en staging [M]
- [ ] Definir sin debug menu [S]
- [ ] Definir firmado incluido en staging [M]
- [ ] Definir validaciones completas en staging [M]
- [ ] Definir retención de staging: 30 días [S]

## 5. Definir builds release (5º)

- [ ] Definir target RELEASE final [M]
- [ ] Definir símbolos release (sin DEBUG) [S]
- [ ] Definir telemetría anónima on [S]
- [ ] Definir firmado + notarización [M]
- [ ] Definir sin editores ni debug menu ni stress framework (M109/M110/M113) [M]
- [ ] Definir release único gate verde (M142/M143) [M]
- [ ] Definir retención permanente de releases [S]

## 6. Definir número de versión (6º)

- [ ] Definir semver `MAJOR.MINOR.PATCH(-pre)+build.n` [M]
- [ ] Definir origen del número: tag git + contador CI [M]
- [ ] Definir escritura automática en BuildInfo.cs [M]
- [ ] Definir coherencia con M142 (RC) y M143 (release) [M]
- [ ] Definir exposición runtime de versión/canal (M104) [S]
- [ ] Definir verificación de coherencia versión ↔ manifest [S]

## 7. Generar changelog (7º)

- [ ] Definir generación desde Conventional Commits [M]
- [ ] Definir agrupación: features/fixes/perf/breaking [M]
- [ ] Definir changelog por versión (entre tags) [M]
- [ ] Definir changelog en artifact y en release (M143) [S]
- [ ] Definir regla de commits en PR (M118) [S]

## 8. Ejecutar tests (8º)

- [ ] Definir ejecución de tests M112 en todo build [C]
- [ ] Definir tests EditMode + PlayMode en gates [M]
- [ ] Definir test suite reducido en PR [M]
- [ ] Definir suite completa en nightly [M]
- [ ] Definir suite en release (obligatoria) [M]
- [ ] Definir reporte de tests en artifact [S]

## 9. Ejecutar validadores (9º)

- [ ] Definir DataValidator (M109) en QA/staging/release [M]
- [ ] Definir gates de stress (M113) rápido en QA [M]
- [ ] Definir gates de stress completo pre-release [M]
- [ ] Definir validación de referencias de escenas [M]
- [ ] Definir reporte de validadores en artifact [S]

## 10. Ejecutar packaging (10º)

- [ ] Definir packaging por plataforma (M96) [C]
- [ ] Definir ZIP Windows + instalador (M116) [M]
- [ ] Definir .app macOS + zip [M]
- [ ] Definir estructura de carpetas correcta [M]
- [ ] Definir no data duplicada en artifact [S]
- [ ] Definir tamaño objetivo del artifact por plataforma [M]
- [ ] Definir manifest SHA-256 completo [M]

## 11. Subir artifacts (11º)

- [ ] Definir subida automática a storage (GitHub Releases o similar) [M]
- [ ] Definir naming del artifact con versión y plataforma [S]
- [ ] Definir checksum publicado junto al artifact [S]
- [ ] Definir subida solo tras smoke test verde [S]
- [ ] Definir registro de URL de cada build en dashboard (M104) [M]

## 12. Guardar builds (12º)

- [ ] Definir política de retención por tipo [S]
- [ ] Definir rotación automática de dev (7 días) [S]
- [ ] Definir repositorio de releases permanente [S]
- [ ] Definir backup de builds críticos (M107) [S]
- [ ] Definir acceso con permisos por rol (M118) [S]

## 13. Firmar ejecutables (13º)

- [ ] Definir firmado Windows con signtool [M]
- [ ] Definir firmado macOS con notarytool + staple [M]
- [ ] Definir certificados de producción y de prueba [M]
- [ ] Definir firmado desde staging (prueba temprana) [M]
- [ ] Definir alerta de caducidad de certificados [S]
- [ ] Definir verificación de firma en smoke test [S]

## 14. Validar dependencias (14º)

- [ ] Definir manifest SHA-256 de todos los archivos del artifact [M]
- [ ] Definir verificación de ausencia de dependencias rotas [M]
- [ ] Definir validación de versiones de dependencias externas [M]
- [ ] Definir bloqueo de release si el manifest falla [S]
- [ ] Definir reporte de dependencias por plataforma [S]

## 15. Automatizar smoke test (15º)

- [ ] Definir smoke del artifact (no del runner) [C]
- [ ] Definir paso: boot a menú principal < 60 s [M]
- [ ] Definir paso: nueva partida con semilla fija [M]
- [ ] Definir paso: 1 día de juego headless [M]
- [ ] Definir paso: guardado + carga (M59) [M]
- [ ] Definir paso: salida limpia exit 0 [M]
- [ ] Definir fallo bloquea el release [S]
- [ ] Definir smoke en QA/staging/release [M]

## 16. Calidad y cierre

- [ ] Definir exclusión de M109/M110/M113 del build release [M]
- [ ] Definir BuildInfo.cs runtime coherente [S]
- [ ] Definir documentación plan-actual actualizada y firmada [S]
- [ ] Definir log del módulo en Logs/ [S]
- [ ] Definir feed a M118 (CI) y M142/M143 (release) [S]

## 17. Builds por plataforma y despliegue (M96/M116/M118)

- [ ] Definir build Windows x64 con instalador (M116) [M]
- [ ] Definir build macOS Apple Silicon firmado y notarizado [M]
- [ ] Definir build Linux-Proton verificado (sin nativo) [M]
- [ ] Definir config de Steam Deck dentro del target PC (M96) [M]
- [ ] Definir build de Steam (appid + depot upload) previsto en M143 [M]
- [ ] Definir build de EGS (SI GATE) previsto en M143 [M]
- [ ] Definir gestión de keystores/certificados centralizada [S]
- [ ] Definir perfiles de build por plataforma en Build Script [M]
- [ ] Definir tiempo objetivo de build multi-plataforma < 3 h [M]
- [ ] Definir fallback sin firmado documentado para dev/QA [S]
- [ ] Definir verificación de integridad del artifact descargado (checksum) [S]
- [ ] Definir coincidencia version → changelog → manifest en cada release [M]

## Totales

**Total de ítems:** 110
**Ítems resueltos por documentación:** 110 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)