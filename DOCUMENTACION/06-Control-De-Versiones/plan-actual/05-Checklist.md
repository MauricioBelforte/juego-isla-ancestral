**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 06: Control de Versiones

**Estado:** `[ ]` pendiente · `[x]` completado · `[?]` no resuelto. Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo.

---

## A. Repositorio y remoto (14)

- [x] Crear repositorio Git del proyecto [S]
- [x] Crear `.gitignore` base (Unity/Python/SO/respaldos) [S]
- [x] Configurar repositorio remoto GitHub [S]
- [x] Configurar rama principal `main` [S]
- [x] Fijar `origin/main` como tracking [S]
- [x] Verificar push exitoso por módulo (26d4bd2→7dbe1b6) [S]
- [x] Documentar los 21 puntos del plan maestro con estado [S]
- [x] Documentar que no se usan ramas develop (1 persona) [S]
- [x] Documentar prohibición de rebase/force-push en main [S]
- [x] Documentar limpieza de ramas temporales tras merge [S]
- [x] Documentar política de commits directos + excepciones (features de riesgo) [S]
- [x] Verificar que el repo clona sin dependencias locales [S]
- [x] Documentar el flujo de backup (remoto GitHub + zip mensual local) [S]
- [ ] Evaluar protección de rama main en GitHub → dueño: Publicación [S]

## B. Estrategia de ramas (12)

- [x] Definir `feature/NN-modulo` para módulos grandes [S]
- [x] Definir `hotfix/descripcion` para fixes urgentes [S]
- [x] Definir el flujo de merge de hotfix a main [S]
- [x] Definir el tag de patch tras hotfix [S]
- [x] Definir los módulos de riesgo que usan PR (voxel, guardado, migraciones, rendimiento) [S]
- [x] Documentar la auto-revisión pre-commit (git status/diff) [S]
- [x] Documentar el QA cruzado entre modelos como revisión (AGENTS §21.8) [S]
- [x] Documentar el uso de merge commits limpios [S]
- [x] Prohibir commits vacíos [S]
- [x] Prohibir mensajes que no sean en español [S]
- [x] Documentar la revisión de convenciones M05 en cada commit de código [S]
- [x] Documentar la revisión de secrets con git diff [S]

## C. Mensajes de commit (10)

- [x] Fijar idioma español obligatorio [S]
- [x] Fijar pasado descriptivo pasivo/impersonal [S]
- [x] Fijar título descriptivo resumido [S]
- [x] Fijar cuerpo con viñetas para cambios múltiples [S]
- [x] Documentar el protocolo de push (AGENTS §4.2): verificar remoto, diff, redactar, commit, push [S]
- [x] Documentar el manejo de advertencias LF→CRLF (normal en Windows) [S]
- [x] Documentar el ejemplo de commit correcto en la guía [S]
- [x] Verificar commits históricos conformes al estándar [S]
- [x] Documentar la regla de no commitear secretos/keys [S]
- [x] Documentar que un commit fallido se corrige con commit nuevo (no amend de fallidos) [S]

## D. Revisión de código (10)

- [x] Definir el proceso de auto-revisión (checklist de 5 pasos) [S]
- [x] Definir cuándo usar PR (módulos de riesgo) [S]
- [x] Definir el QA cruzado como revisión externa periódica [S]
- [x] Documentar la revisión contra convenciones M05 [S]
- [x] Documentar la revisión de binarios innecesarios [S]
- [x] Documentar la revisión de migraciones en commits de save [S]
- [x] Documentar la revisión de logs/ULTIMO_NUMERO en cada módulo [S]
- [x] Documentar la revisión de CHECKLIST-GLOBAL en commits de módulos [S]
- [x] Documentar la regla de tags por release [S]
- [x] Documentar el etiquetado de builds con versión en el nombre [S]

## E. Versionado y changelog (14)

- [x] Definir esquema semver v0.1.0 → v1.0.0 [S]
- [x] Definir las etapas: dev/slice/alpha/beta/release [S]
- [x] Definir versión post-lanzamiento (v1.1.0 contenido, v1.0.1 fixes) [S]
- [x] Definir el formato del nombre de build [S]
- [x] Crear `CHANGELOG.md` en la raíz [S]
- [x] Registrar el historial inicial en CHANGELOG [S]
- [x] Definir el formato del changelog (Añadido/Cambiado/Corregido) [S]
- [x] Definir la sección "Incompatible" (breaking) para saves/config [S]
- [x] Documentar la regla de aviso previo a cambios incompatibles [S]
- [x] Documentar el versionado independiente del GameState (M59) [S]
- [x] Documentar el procedimiento de migraciones (documento + changelog + test) [S]
- [x] Documentar tag v0.1.0 al completar el prototipo M1 [S]
- [x] Documentar las releases de GitHub con descripción [S]
- [x] Documentar la sincronización tag ↔ changelog ↔ build [S]

## F. LFS y assets (10)

- [x] Evaluar Git LFS y documentar decisión (no por ahora) [S]
- [x] Fijar umbral de evaluación: assets binarios > 100 MB [S]
- [x] Documentar qué extensiones entrarían en LFS si aplica (.wav/.png grandes) [S]
- [x] Documentar que `/.godot/` no se versiona [S]
- [x] Documentar que Builds/ y *.pck no se versionan [S]
- [x] Documentar que __pycache__ y scripts/backups no se versionan [S]
- [x] Verificar .gitignore actual contra la lista de excluidos [S]
- [x] Documentar la regla de no subir archivos de log en Assets/ [S]
- [x] Documentar la revisión de "archivos generados innecesarios" en cada diff [S]
- [x] Documentar el procedimiento si un binario entra por error (git rm --cached) [S]

## G. Backups y herramientas internas (10)

- [x] Documentar GitHub como respaldo principal [S]
- [x] Definir backup local mensual (zip, 3 rotativos, fuera del repo) [S]
- [x] Documentar el respaldo pre-cambio grande en Obsoletos/ (AGENTS §5) [S]
- [x] Documentar scripts/ del protocolo como herramientas versionadas [S]
- [x] Documentar test_scripts.py como obligatorio antes de usar scripts [S]
- [x] Documentar scripts/backups como excluido del repo [S]
- [x] Documentar la restauración desde remoto (clone + checkout) [S]
- [x] Documentar el flujo de recuperación ante .git corrupto [S]
- [x] Documentar la verificación periódica git fsck [S]
- [x] Documentar el respaldo del CHANGELOG y CHECKLIST-GLOBAL en cada release [S]

## H. Integración y edge cases (12)

- [x] Documentar que M07 usará esta política sin cambios [S]
- [x] Documentar la actualización del .gitignore para Godot en el hito M1 [S]
- [x] Documentar edge case: commit de docs + código mezclados (evitar, separar) [S]
- [x] Documentar edge case: archivos con espacios/acentos en rutas (comillas en PowerShell) [S]
- [x] Documentar edge case: paths largos Windows (git core.longpaths si aplica) [S]
- [x] Documentar edge case: merge de plan-actual vs plan-inicial (nunca editar inicial) [S]
- [x] Documentar edge case: conflicto de ULTIMO_NUMERO entre agentes [S]
- [x] Documentar edge case: push rechazado por cambios remotos (pull --rebase con cuidado) [S]
- [x] Verificar trazabilidad de los 21 puntos del plan maestro [S]
- [x] Actualizar CHECKLIST-GLOBAL con el estado de M06 [S]
- [x] Actualizar DOCUMENTACION/README.md con el componente 06 [S]
- [x] Generar log de finalización y actualizar ULTIMO_NUMERO [S]

## I. Mantenimiento y Evolución (8 ítems)

- [ ] Revisar política de ramas cada 6 meses
- [ ] Actualizar .gitignore cuando se agreguen nuevas dependencias
- [ ] Auditar permisos de acceso al repositorio trimestralmente
- [ ] Verificar que CHANGELOG refleja todos los cambios significativos
- [ ] Revisar utilidad de Git LFS cuando el proyecto tenga más assets
- [ ] Documentar nuevas herramientas de Git adoptadas por el equipo
- [ ] Actualizar convenciones de commit si cambian las necesidades del proyecto
- [ ] Revisar política de backups anualmente

---

**Totales:** 92 ítems · Completados: 91 · Pendientes: 1 (protección de rama main en GitHub → dueño: Publicación) · No resueltos: 0.