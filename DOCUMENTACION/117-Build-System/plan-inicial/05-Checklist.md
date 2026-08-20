**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 117: Build System (110 ítems)

## Convención
- `[x]` = completado por documentación. `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo.

## 1. Automatizar builds (1º)

- [x] Definir BuildScript.cs como punto único de builds [C]
- [x] Definir invocación vía Unity CLI (batchmode) [M]
- [x] Definir parámetros: tipo, plataforma, versión [M]
- [x] Definir repetición determinística (un commit → un build) [M]
- [x] Definir registro de log del build por corrida [S]
- [x] Definir integración con CI de M118 [M]
- [x] Definir límite de tiempo de build (dev 30 min, release 60 min) [S]
- [x] Definir reutilización del Editor en build (sin abrir manualmente) [M]

## 2. Definir builds de desarrollo (2º)

- [x] Definir target DEV con símbolos DEBUG [S]
- [x] Definir Debug Menu (M110) activo en DEV [M]
- [x] Definir PDB/símbolos en DEV [S]
- [x] Definir sin telemetría real en DEV [S]
- [x] Definir frecuencia: build dev nocturno [S]
- [x] Definir retención de dev builds: 7 días [S]

## 3. Definir builds de QA (3º)

- [x] Definir target QA con símbolos DEBUG [S]
- [x] Definir telemetría QA activa (M104/M105, datos de prueba) [M]
- [x] Definir PDB/símbolos en QA [S]
- [x] Definir sin debug menu en QA (solo developers flag) [S]
- [x] Definir frecuencia: por milestone (M140/141) [S]
- [x] Definir retención de QA builds: 30 días [S]
- [x] Definir logging extendido en QA [M]

## 4. Definir builds staging (4º)

- [x] Definir target STAGING como réplica de release [M]
- [x] Definir canal RELEASE_CHANNEL activo [S]
- [x] Definir telemetría anónima real en staging [M]
- [x] Definir sin debug menu [S]
- [x] Definir firmado incluido en staging [M]
- [x] Definir validaciones completas en staging [M]
- [x] Definir retención de staging: 30 días [S]

## 5. Definir builds release (5º)

- [x] Definir target RELEASE final [M]
- [x] Definir símbolos release (sin DEBUG) [S]
- [x] Definir telemetría anónima on [S]
- [x] Definir firmado + notarización [M]
- [x] Definir sin editores ni debug menu ni stress framework (M109/M110/M113) [M]
- [x] Definir release único gate verde (M142/M143) [M]
- [x] Definir retención permanente de releases [S]

## 6. Definir número de versión (6º)

- [x] Definir semver `MAJOR.MINOR.PATCH(-pre)+build.n` [M]
- [x] Definir origen del número: tag git + contador CI [M]
- [x] Definir escritura automática en BuildInfo.cs [M]
- [x] Definir coherencia con M142 (RC) y M143 (release) [M]
- [x] Definir exposición runtime de versión/canal (M104) [S]
- [x] Definir verificación de coherencia versión ↔ manifest [S]

## 7. Generar changelog (7º)

- [x] Definir generación desde Conventional Commits [M]
- [x] Definir agrupación: features/fixes/perf/breaking [M]
- [x] Definir changelog por versión (entre tags) [M]
- [x] Definir changelog en artifact y en release (M143) [S]
- [x] Definir regla de commits en PR (M118) [S]

## 8. Ejecutar tests (8º)

- [x] Definir ejecución de tests M112 en todo build [C]
- [x] Definir tests EditMode + PlayMode en gates [M]
- [x] Definir test suite reducido en PR [M]
- [x] Definir suite completa en nightly [M]
- [x] Definir suite en release (obligatoria) [M]
- [x] Definir reporte de tests en artifact [S]

## 9. Ejecutar validadores (9º)

- [x] Definir DataValidator (M109) en QA/staging/release [M]
- [x] Definir gates de stress (M113) rápido en QA [M]
- [x] Definir gates de stress completo pre-release [M]
- [x] Definir validación de referencias de escenas [M]
- [x] Definir reporte de validadores en artifact [S]

## 10. Ejecutar packaging (10º)

- [x] Definir packaging por plataforma (M96) [C]
- [x] Definir ZIP Windows + instalador (M116) [M]
- [x] Definir .app macOS + zip [M]
- [x] Definir estructura de carpetas correcta [M]
- [x] Definir no data duplicada en artifact [S]
- [x] Definir tamaño objetivo del artifact por plataforma [M]
- [x] Definir manifest SHA-256 completo [M]

## 11. Subir artifacts (11º)

- [x] Definir subida automática a storage (GitHub Releases o similar) [M]
- [x] Definir naming del artifact con versión y plataforma [S]
- [x] Definir checksum publicado junto al artifact [S]
- [x] Definir subida solo tras smoke test verde [S]
- [x] Definir registro de URL de cada build en dashboard (M104) [M]

## 12. Guardar builds (12º)

- [x] Definir política de retención por tipo [S]
- [x] Definir rotación automática de dev (7 días) [S]
- [x] Definir repositorio de releases permanente [S]
- [x] Definir backup de builds críticos (M107) [S]
- [x] Definir acceso con permisos por rol (M118) [S]

## 13. Firmar ejecutables (13º)

- [x] Definir firmado Windows con signtool [M]
- [x] Definir firmado macOS con notarytool + staple [M]
- [x] Definir certificados de producción y de prueba [M]
- [x] Definir firmado desde staging (prueba temprana) [M]
- [x] Definir alerta de caducidad de certificados [S]
- [x] Definir verificación de firma en smoke test [S]

## 14. Validar dependencias (14º)

- [x] Definir manifest SHA-256 de todos los archivos del artifact [M]
- [x] Definir verificación de ausencia de dependencias rotas [M]
- [x] Definir validación de versiones de dependencias externas [M]
- [x] Definir bloqueo de release si el manifest falla [S]
- [x] Definir reporte de dependencias por plataforma [S]

## 15. Automatizar smoke test (15º)

- [x] Definir smoke del artifact (no del runner) [C]
- [x] Definir paso: boot a menú principal < 60 s [M]
- [x] Definir paso: nueva partida con semilla fija [M]
- [x] Definir paso: 1 día de juego headless [M]
- [x] Definir paso: guardado + carga (M59) [M]
- [x] Definir paso: salida limpia exit 0 [M]
- [x] Definir fallo bloquea el release [S]
- [x] Definir smoke en QA/staging/release [M]

## 16. Calidad y cierre

- [x] Definir exclusión de M109/M110/M113 del build release [M]
- [x] Definir BuildInfo.cs runtime coherente [S]
- [x] Definir documentación plan-actual actualizada y firmada [S]
- [x] Definir log del módulo en Logs/ [S]
- [x] Definir feed a M118 (CI) y M142/M143 (release) [S]

## 17. Builds por plataforma y despliegue (M96/M116/M118)

- [x] Definir build Windows x64 con instalador (M116) [M]
- [x] Definir build macOS Apple Silicon firmado y notarizado [M]
- [x] Definir build Linux-Proton verificado (sin nativo) [M]
- [x] Definir config de Steam Deck dentro del target PC (M96) [M]
- [x] Definir build de Steam (appid + depot upload) previsto en M143 [M]
- [x] Definir build de EGS (SI GATE) previsto en M143 [M]
- [x] Definir gestión de keystores/certificados centralizada [S]
- [x] Definir perfiles de build por plataforma en Build Script [M]
- [x] Definir tiempo objetivo de build multi-plataforma < 3 h [M]
- [x] Definir fallback sin firmado documentado para dev/QA [S]
- [x] Definir verificación de integridad del artifact descargado (checksum) [S]
- [x] Definir coincidencia version → changelog → manifest en cada release [M]

## Totales

**Total de ítems:** 110
**Ítems resueltos por documentación:** 110 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)