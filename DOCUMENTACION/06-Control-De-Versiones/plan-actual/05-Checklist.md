**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 06: Control de Versiones

**Estado:** `[ ]` pendiente · `[ ]` completado · `[?]` no resuelto. Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo.

---

## A. Repositorio y remoto (14)

- [ ] Crear repositorio Git del proyecto [S]
- [ ] Crear `.gitignore` base (Unity/Python/SO/respaldos) [S]
- [ ] Configurar repositorio remoto GitHub [S]
- [ ] Configurar rama principal `main` [S]
- [ ] Fijar `origin/main` como tracking [S]
- [ ] Verificar push exitoso por módulo (26d4bd2→7dbe1b6) [S]
- [ ] Documentar los 21 puntos del plan maestro con estado [S]
- [ ] Documentar que no se usan ramas develop (1 persona) [S]
- [ ] Documentar prohibición de rebase/force-push en main [S]
- [ ] Documentar limpieza de ramas temporales tras merge [S]
- [ ] Documentar política de commits directos + excepciones (features de riesgo) [S]
- [ ] Verificar que el repo clona sin dependencias locales [S]
- [ ] Documentar el flujo de backup (remoto GitHub + zip mensual local) [S]
- [ ] Evaluar protección de rama main en GitHub → dueño: Publicación [S]

## B. Estrategia de ramas (12)

- [ ] Definir `feature/NN-modulo` para módulos grandes [S]
- [ ] Definir `hotfix/descripcion` para fixes urgentes [S]
- [ ] Definir el flujo de merge de hotfix a main [S]
- [ ] Definir el tag de patch tras hotfix [S]
- [ ] Definir los módulos de riesgo que usan PR (voxel, guardado, migraciones, rendimiento) [S]
- [ ] Documentar la auto-revisión pre-commit (git status/diff) [S]
- [ ] Documentar el QA cruzado entre modelos como revisión (AGENTS §21.8) [S]
- [ ] Documentar el uso de merge commits limpios [S]
- [ ] Prohibir commits vacíos [S]
- [ ] Prohibir mensajes que no sean en español [S]
- [ ] Documentar la revisión de convenciones M05 en cada commit de código [S]
- [ ] Documentar la revisión de secrets con git diff [S]

## C. Mensajes de commit (10)

- [ ] Fijar idioma español obligatorio [S]
- [ ] Fijar pasado descriptivo pasivo/impersonal [S]
- [ ] Fijar título descriptivo resumido [S]
- [ ] Fijar cuerpo con viñetas para cambios múltiples [S]
- [ ] Documentar el protocolo de push (AGENTS §4.2): verificar remoto, diff, redactar, commit, push [S]
- [ ] Documentar el manejo de advertencias LF→CRLF (normal en Windows) [S]
- [ ] Documentar el ejemplo de commit correcto en la guía [S]
- [ ] Verificar commits históricos conformes al estándar [S]
- [ ] Documentar la regla de no commitear secretos/keys [S]
- [ ] Documentar que un commit fallido se corrige con commit nuevo (no amend de fallidos) [S]

## D. Revisión de código (10)

- [ ] Definir el proceso de auto-revisión (checklist de 5 pasos) [S]
- [ ] Definir cuándo usar PR (módulos de riesgo) [S]
- [ ] Definir el QA cruzado como revisión externa periódica [S]
- [ ] Documentar la revisión contra convenciones M05 [S]
- [ ] Documentar la revisión de binarios innecesarios [S]
- [ ] Documentar la revisión de migraciones en commits de save [S]
- [ ] Documentar la revisión de logs/ULTIMO_NUMERO en cada módulo [S]
- [ ] Documentar la revisión de CHECKLIST-GLOBAL en commits de módulos [S]
- [ ] Documentar la regla de tags por release [S]
- [ ] Documentar el etiquetado de builds con versión en el nombre [S]

## E. Versionado y changelog (14)

- [ ] Definir esquema semver v0.1.0 → v1.0.0 [S]
- [ ] Definir las etapas: dev/slice/alpha/beta/release [S]
- [ ] Definir versión post-lanzamiento (v1.1.0 contenido, v1.0.1 fixes) [S]
- [ ] Definir el formato del nombre de build [S]
- [ ] Crear `CHANGELOG.md` en la raíz [S]
- [ ] Registrar el historial inicial en CHANGELOG [S]
- [ ] Definir el formato del changelog (Añadido/Cambiado/Corregido) [S]
- [ ] Definir la sección "Incompatible" (breaking) para saves/config [S]
- [ ] Documentar la regla de aviso previo a cambios incompatibles [S]
- [ ] Documentar el versionado independiente del GameState (M59) [S]
- [ ] Documentar el procedimiento de migraciones (documento + changelog + test) [S]
- [ ] Documentar tag v0.1.0 al completar el prototipo M1 [S]
- [ ] Documentar las releases de GitHub con descripción [S]
- [ ] Documentar la sincronización tag ↔ changelog ↔ build [S]

## F. LFS y assets (10)

- [ ] Evaluar Git LFS y documentar decisión (no por ahora) [S]
- [ ] Fijar umbral de evaluación: assets binarios > 100 MB [S]
- [ ] Documentar qué extensiones entrarían en LFS si aplica (.wav/.png grandes) [S]
- [ ] Documentar que `/.godot/` no se versiona [S]
- [ ] Documentar que Builds/ y *.pck no se versionan [S]
- [ ] Documentar que __pycache__ y scripts/backups no se versionan [S]
- [ ] Verificar .gitignore actual contra la lista de excluidos [S]
- [ ] Documentar la regla de no subir archivos de log en Assets/ [S]
- [ ] Documentar la revisión de "archivos generados innecesarios" en cada diff [S]
- [ ] Documentar el procedimiento si un binario entra por error (git rm --cached) [S]

## G. Backups y herramientas internas (10)

- [ ] Documentar GitHub como respaldo principal [S]
- [ ] Definir backup local mensual (zip, 3 rotativos, fuera del repo) [S]
- [ ] Documentar el respaldo pre-cambio grande en Obsoletos/ (AGENTS §5) [S]
- [ ] Documentar scripts/ del protocolo como herramientas versionadas [S]
- [ ] Documentar test_scripts.py como obligatorio antes de usar scripts [S]
- [ ] Documentar scripts/backups como excluido del repo [S]
- [ ] Documentar la restauración desde remoto (clone + checkout) [S]
- [ ] Documentar el flujo de recuperación ante .git corrupto [S]
- [ ] Documentar la verificación periódica git fsck [S]
- [ ] Documentar el respaldo del CHANGELOG y CHECKLIST-GLOBAL en cada release [S]

## H. Integración y edge cases (12)

- [ ] Documentar que M07 usará esta política sin cambios [S]
- [ ] Documentar la actualización del .gitignore para Godot en el hito M1 [S]
- [ ] Documentar edge case: commit de docs + código mezclados (evitar, separar) [S]
- [ ] Documentar edge case: archivos con espacios/acentos en rutas (comillas en PowerShell) [S]
- [ ] Documentar edge case: paths largos Windows (git core.longpaths si aplica) [S]
- [ ] Documentar edge case: merge de plan-actual vs plan-inicial (nunca editar inicial) [S]
- [ ] Documentar edge case: conflicto de ULTIMO_NUMERO entre agentes [S]
- [ ] Documentar edge case: push rechazado por cambios remotos (pull --rebase con cuidado) [S]
- [ ] Verificar trazabilidad de los 21 puntos del plan maestro [S]
- [ ] Actualizar CHECKLIST-GLOBAL con el estado de M06 [S]
- [ ] Actualizar DOCUMENTACION/README.md con el componente 06 [S]
- [ ] Generar log de finalización y actualizar ULTIMO_NUMERO [S]

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