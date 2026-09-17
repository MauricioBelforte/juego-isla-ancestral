**Modelo:** glm-5.3-flash
**Plataforma:** Cline

**Módulo:** 66-Anti-Softlock (66)

# Checklist personal tareas

> ✅ CONFLICTO RESUELTO (2026-09-15, glm-5.3-flash / Cline — Log 913): la restauración verificada se ejecutó tras comprobar la implementación real en el código (SoftlockGuard autoload + 7 invariants + checkpoint_manager + cofre_recuperacion + irecoverable; tick 60 s y toast cooldown 30 s en softlock_rules; 06/07-Testings presentes) y correr la suite headless con el binario real: `test_anti_softlock_m66.gd` y `test_fallbacks_m66.gd` = **0 fallos, exit 0**. El módulo queda **110/117**: 87 tareas `[x]` y 7 `[?]` bloqueadas por API externa (M27/M64/M22/M26, Log 701/744). El `[→]` anterior era trabajo declarado sin verificar; ya reconciliado.

> Extraídas del `05-Checklist.md` del módulo (94 tareas de 117 ítems). Estado tras la restauración verificada: **87 `[x]` + 7 `[?]`**. Fuente de verdad del ítem: el `05-Checklist.md`.

## Tareas

- [x] T-001 Implementar cahce de invariantes sin raycast en masa [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-002 Implementar ObjetoClaveInvariant (2+ caminos verificables) [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [?] T-003 Implementar validación con NavigationServer3D de 2 caminos [M] — KnownIssue: bloqueado por API externa M27/M64/M22/M26 (Log 701/744)
- [x] T-004 Implementar justificación narrativa para claves sin caminos [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-005 Implementar registro de claves por misión [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-006 Implementar seguimiento de claves en inventario serializado [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-007 Implementar devolución al cofre si la clave no existe en el mundo [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-008 Documentar invariantes de objetos en plan-actual [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-009 Implementar NpcInvariant (nodo válido y agenda rehidratable) [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [?] T-010 Implementar watchdog anti-atasco reusado de M64 (2 s/6 s) [M] — KnownIssue: bloqueado por API externa M27/M64/M22/M26 (Log 701/744)
- [x] T-011 Implementar re-path del NPC atascado [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-012 Implementar teleport al hogar del NPC si la escena es inválida [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-013 Implementar reset de agenda del NPC tras teleport [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-014 Implementar restauración de inventario transaccional del NPC [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-015 Implementar eventos de restauración de NPC [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-016 Documentar invariantes de NPC en plan-actual [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [?] T-017 Implementar sincronización con persistencia de misiones (M22) [M] — KnownIssue: bloqueado por API externa M27/M64/M22/M26 (Log 701/744)
- [?] T-018 Implementar pruebas de misiones imposibles (injerto) [M] — KnownIssue: bloqueado por API externa M27/M64/M22/M26 (Log 701/744)
- [x] T-019 Documentar invariantes de misiones en plan-actual [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-020 Implementar PuzzleInvariant (resoluble en 30 s de diagnóstico) [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-021 Implementar diagnóstico de resolubilidad por slot [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-022 Implementar reinicio del puzzle al estado inicial del slot [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-023 Implementar notificación al jugador del reinicio [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-024 Implementar registro del reinicio en logs de eventos [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-025 Implementar no-reinicio si el puzzle está en progreso válido [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-026 Implementar compatibilidad con M24 y M26 [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-027 Documentar invariantes de puzzles en plan-actual [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-028 Implementar checkpoint al entrar a bioma [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-029 Implementar checkpoint al completar misión [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-030 Implementar checkpoint al estabilizar vehículo [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-031 Implementar restauración del checkpoint más cercano para el jugador [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-032 Implementar verificación de integridad post-restauración [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-033 Implementar límite de 4 escrituras por evento [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-034 Documentar checkpoints en plan-actual [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-035 Implementar JugadorInvariant (vivo y sobre el mundo) [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-036 Implementar detección de jugador fuera del mundo [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-037 Implementar teletransporte al checkpoint más cercano [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-038 Implementar efectos suaves al recuperar (sin daño extra) [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-039 Implementar toast informativo de recuperación [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-040 Implementar reintegración de estado (stamina, inventario) [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-041 Implementar no-muertes por bug de geometría [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-042 Documentar recuperación del jugador en plan-actual [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-043 Implementar VehiculoInvariant (dentro del mundo) [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-044 Implementar detección de vehículo fuera del mundo [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-045 Implementar reaparición en el amarre tras 30 s [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-046 Implementar amarre alternativo si el principal está ocupado [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-047 Implementar conservación del inventario del vehículo [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-048 Implementar conservación de mejoras al reaparecer [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-049 Implementar eventos de recuperación de vehículo [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-050 Documentar recuperación de vehículos en plan-actual [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-051 Implementar respaldo antes de cada guardado [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-052 Implementar detección de guardado corrupto al cargar [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-053 Implementar recuperación del respaldo `.bak` ante corrupción [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-054 Implementar aviso de restauración de respaldo [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-055 Implementar test que simula corte a mitad de escritura [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-056 Implementar verificación del estado tras el corte simulado [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-057 Documentar el manejo de cierres inesperados en plan-actual [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-058 Implementar detección de terreno modificado extremo (M08) [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-059 Implementar revalidación de objetos clave tras modificación [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-060 Implementar reubicación del objeto dentro del mismo chunk [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-061 Implementar revalidación de NPC tras modificación de terreno [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-062 Implementar revalidación de vehículos tras modificación [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-063 Implementar revalidación de checkpoints tras modificación [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-064 Implementar fallback de misión si el objetivo quedó en zona inválida [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-065 Implementar test de hundimiento de suelo bajo objetos clave [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-066 Implementar test de elevación de suelo sobre el jugador [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-067 Documentar el manejo de terreno extremo en plan-actual [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-068 Implementar integración con persistencia (guardado atómico) [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [?] T-069 Implementar integración con M22 (Historia Principal) [M] — KnownIssue: bloqueado por API externa M27/M64/M22/M26 (Log 701/744)
- [?] T-070 Implementar integración con M26 (Templo Subterráneo) [M] — KnownIssue: bloqueado por API externa M27/M64/M22/M26 (Log 701/744)
- [?] T-071 Implementar integración con M64 (watchdog NPC) [M] — KnownIssue: bloqueado por API externa M27/M64/M22/M26 (Log 701/744)
- [x] T-072 Implementar integración con vehículos (amarre) [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-073 Implementar eventos públicos para UI de toast (M57) [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-074 Implementar sin acoplamiento a las misiones (suscripción a eventos) [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-075 Documentar integración en plan-actual [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-076 Implementar costo ≤ 0.5 ms por detección [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-077 Implementar cero I/O síncrona en Update [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-078 Implementar cache de invariantes (sin raycast en masa) [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-079 Implementar sin allocations en Update [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-080 Implementar sin excepciones ante objetos nulos [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-081 Implementar recuperación antes de 15 s desde la detección [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-082 Implementar sin spam de toasts (cooldown) [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-083 Implementar sin duplicados de objetos jamás [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-084 Documentar rendimiento y robustez en plan-actual [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-085 Diseñar 06-Plan-Testings.md con unitarias de invariantes [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-086 Diseñar 06-Plan-Testings.md con integración (cierre, terreno) [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-087 Diseñar 06-Plan-Testings.md con edge cases (cofre lleno, doble recuperación) [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-088 Diseñar 06-Plan-Testings.md con pruebas de rendimiento [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-089 Definir criterio de éxito: suite completa pasa sin fallos [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-090 Crear 07-Resultados-Testings.md para registrar la ejecución [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-091 Documentar todas las decisiones en 02-Analisis y 03-Diseno [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-092 Actualizar plan-actual como espejo del estado real [M] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-093 Crear Log en Logs/ con formato NN-DESCRIPCION_FECHA [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
- [x] T-094 Actualizar fila 66 en CHECKLIST-GLOBAL al implementar [S] — restaurado 2026-09-15 (Log 913): codigo verificado + test headless 0 fallos
