# Tareas módulo 06 06-Control-De-Versiones

**Estado:** ðŸŸ¢ Disponible

**Items pendientes:** 100

[ ] T-06-001: Crear repositorio Git del proyecto
[ ] T-06-002: Crear `.gitignore` base (Unity/Python/SO/respaldos)
[ ] T-06-003: Configurar repositorio remoto GitHub
[ ] T-06-004: Configurar rama principal `main`
[ ] T-06-005: Fijar `origin/main` como tracking
[ ] T-06-006: Verificar push exitoso por módulo (26d4bd2→7dbe1b6)
[ ] T-06-007: Documentar los 21 puntos del plan maestro con estado
[ ] T-06-008: Documentar que no se usan ramas develop (1 persona)
[ ] T-06-009: Documentar prohibición de rebase/force-push en main
[ ] T-06-010: Documentar limpieza de ramas temporales tras merge
[ ] T-06-011: Documentar política de commits directos + excepciones (features de riesgo)
[ ] T-06-012: Verificar que el repo clona sin dependencias locales
[ ] T-06-013: Documentar el flujo de backup (remoto GitHub + zip mensual local)
[ ] T-06-014: Evaluar protección de rama main en GitHub → dueño: Publicación
[ ] T-06-015: Definir `feature/NN-modulo` para módulos grandes
[ ] T-06-016: Definir `hotfix/descripcion` para fixes urgentes
[ ] T-06-017: Definir el flujo de merge de hotfix a main
[ ] T-06-018: Definir el tag de patch tras hotfix
[ ] T-06-019: Definir los módulos de riesgo que usan PR (voxel, guardado, migraciones, rendimiento)
[ ] T-06-020: Documentar la auto-revisión pre-commit (git status/diff)
[ ] T-06-021: Documentar el QA cruzado entre modelos como revisión (AGENTS §21.8)
[ ] T-06-022: Documentar el uso de merge commits limpios
[ ] T-06-023: Prohibir commits vacíos
[ ] T-06-024: Prohibir mensajes que no sean en español
[ ] T-06-025: Documentar la revisión de convenciones M05 en cada commit de código
[ ] T-06-026: Documentar la revisión de secrets con git diff
[ ] T-06-027: Fijar idioma español obligatorio
[ ] T-06-028: Fijar pasado descriptivo pasivo/impersonal
[ ] T-06-029: Fijar título descriptivo resumido
[ ] T-06-030: Fijar cuerpo con viñetas para cambios múltiples
[ ] T-06-031: Documentar el protocolo de push (AGENTS §4.2): verificar remoto, diff, redactar, commit, push
[ ] T-06-032: Documentar el manejo de advertencias LF→CRLF (normal en Windows)
[ ] T-06-033: Documentar el ejemplo de commit correcto en la guía
[ ] T-06-034: Verificar commits históricos conformes al estándar
[ ] T-06-035: Documentar la regla de no commitear secretos/keys
[ ] T-06-036: Documentar que un commit fallido se corrige con commit nuevo (no amend de fallidos)
[ ] T-06-037: Definir el proceso de auto-revisión (checklist de 5 pasos)
[ ] T-06-038: Definir cuándo usar PR (módulos de riesgo)
[ ] T-06-039: Definir el QA cruzado como revisión externa periódica
[ ] T-06-040: Documentar la revisión contra convenciones M05
[ ] T-06-041: Documentar la revisión de binarios innecesarios
[ ] T-06-042: Documentar la revisión de migraciones en commits de save
[ ] T-06-043: Documentar la revisión de logs/ULTIMO_NUMERO en cada módulo
[ ] T-06-044: Documentar la revisión de CHECKLIST-GLOBAL en commits de módulos
[ ] T-06-045: Documentar la regla de tags por release
[ ] T-06-046: Documentar el etiquetado de builds con versión en el nombre
[ ] T-06-047: Definir esquema semver v0.1.0 → v1.0.0
[ ] T-06-048: Definir las etapas: dev/slice/alpha/beta/release
[ ] T-06-049: Definir versión post-lanzamiento (v1.1.0 contenido, v1.0.1 fixes)
[ ] T-06-050: Definir el formato del nombre de build
[ ] T-06-051: Crear `CHANGELOG.md` en la raíz
[ ] T-06-052: Registrar el historial inicial en CHANGELOG
[ ] T-06-053: Definir el formato del changelog (Añadido/Cambiado/Corregido)
[ ] T-06-054: Definir la sección "Incompatible" (breaking) para saves/config
[ ] T-06-055: Documentar la regla de aviso previo a cambios incompatibles
[ ] T-06-056: Documentar el versionado independiente del GameState (M59)
[ ] T-06-057: Documentar el procedimiento de migraciones (documento + changelog + test)
[ ] T-06-058: Documentar tag v0.1.0 al completar el prototipo M1
[ ] T-06-059: Documentar las releases de GitHub con descripción
[ ] T-06-060: Documentar la sincronización tag ↔ changelog ↔ build
[ ] T-06-061: Evaluar Git LFS y documentar decisión (no por ahora)
[ ] T-06-062: Fijar umbral de evaluación: assets binarios > 100 MB
[ ] T-06-063: Documentar qué extensiones entrarían en LFS si aplica (.wav/.png grandes)
[ ] T-06-064: Documentar que `/.godot/` no se versiona
[ ] T-06-065: Documentar que Builds/ y *.pck no se versionan
[ ] T-06-066: Documentar que __pycache__ y scripts/backups no se versionan
[ ] T-06-067: Verificar .gitignore actual contra la lista de excluidos
[ ] T-06-068: Documentar la regla de no subir archivos de log en Assets/
[ ] T-06-069: Documentar la revisión de "archivos generados innecesarios" en cada diff
[ ] T-06-070: Documentar el procedimiento si un binario entra por error (git rm --cached)
[ ] T-06-071: Documentar GitHub como respaldo principal
[ ] T-06-072: Definir backup local mensual (zip, 3 rotativos, fuera del repo)
[ ] T-06-073: Documentar el respaldo pre-cambio grande en Obsoletos/ (AGENTS §5)
[ ] T-06-074: Documentar scripts/ del protocolo como herramientas versionadas
[ ] T-06-075: Documentar test_scripts.py como obligatorio antes de usar scripts
[ ] T-06-076: Documentar scripts/backups como excluido del repo
[ ] T-06-077: Documentar la restauración desde remoto (clone + checkout)
[ ] T-06-078: Documentar el flujo de recuperación ante .git corrupto
[ ] T-06-079: Documentar la verificación periódica git fsck
[ ] T-06-080: Documentar el respaldo del CHANGELOG y CHECKLIST-GLOBAL en cada release
[ ] T-06-081: Documentar que M07 usará esta política sin cambios
[ ] T-06-082: Documentar la actualización del .gitignore para Godot en el hito M1
[ ] T-06-083: Documentar edge case: commit de docs + código mezclados (evitar, separar)
[ ] T-06-084: Documentar edge case: archivos con espacios/acentos en rutas (comillas en PowerShell)
[ ] T-06-085: Documentar edge case: paths largos Windows (git core.longpaths si aplica)
[ ] T-06-086: Documentar edge case: merge de plan-actual vs plan-inicial (nunca editar inicial)
[ ] T-06-087: Documentar edge case: conflicto de ULTIMO_NUMERO entre agentes
[ ] T-06-088: Documentar edge case: push rechazado por cambios remotos (pull --rebase con cuidado)
[ ] T-06-089: Verificar trazabilidad de los 21 puntos del plan maestro
[ ] T-06-090: Actualizar CHECKLIST-GLOBAL con el estado de M06
[ ] T-06-091: Actualizar DOCUMENTACION/README.md con el componente 06
[ ] T-06-092: Generar log de finalización y actualizar ULTIMO_NUMERO
[ ] T-06-093: Revisar política de ramas cada 6 meses
[ ] T-06-094: Actualizar .gitignore cuando se agreguen nuevas dependencias
[ ] T-06-095: Auditar permisos de acceso al repositorio trimestralmente
[ ] T-06-096: Verificar que CHANGELOG refleja todos los cambios significativos
[ ] T-06-097: Revisar utilidad de Git LFS cuando el proyecto tenga más assets
[ ] T-06-098: Documentar nuevas herramientas de Git adoptadas por el equipo
[ ] T-06-099: Actualizar convenciones de commit si cambian las necesidades del proyecto
[ ] T-06-100: Revisar política de backups anualmente
