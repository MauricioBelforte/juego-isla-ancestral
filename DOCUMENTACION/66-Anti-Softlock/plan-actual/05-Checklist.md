# 05 — Checklist — M66: Anti-Softlock (100/100)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Detector central

- [x] Definir la arquitectura del detector central (SoftlockGuard) [M]
- [x] Implementar tick de 60 s reales del detector [S]
- [x] Implementar disparo del detector en transiciones de escena [S]
- [x] Implementar disparo del detector al guardar [S]
- [x] Implementar chequeo por invariantes con orden de prioridad [M]
- [x] Implementar plan de recuperación en cascada [M]
- [x] Implementar registro de eventos de recuperación [S]
- [x] Implementar toast informativo solo si afecta al jugador [M]
- [x] Implementar flag de 3 recuperaciones por instancia en 10 min [S]
- [x] Implementar cahce de invariantes sin raycast en masa [M]
- [x] Documentar detector central en plan-actual [S]

## Invariantes de objetos clave

- [x] Implementar ObjetoClaveInvariant (2+ caminos verificables) [M]
- [x] Implementar validación con NavigationServer3D de 2 caminos [M]
- [x] Implementar justificación narrativa para claves sin caminos [M]
- [x] Implementar registro de claves por misión [S]
- [x] Implementar seguimiento de claves en inventario serializado [M]
- [x] Implementar devolución al cofre si la clave no existe en el mundo [M]
- [x] Implementar marcado "recuperado" tras un solo uso [S]
- [x] Implementar slots del cofre con copia inmutable [M]
- [x] Documentar invariantes de objetos en plan-actual [S]

## Invariantes de NPC

- [x] Implementar NpcInvariant (nodo válido y agenda rehidratable) [M]
- [x] Implementar watchdog anti-atasco reusado de M64 (2 s/6 s) [M]
- [x] Implementar re-path del NPC atascado [M]
- [x] Implementar teleport al hogar del NPC si la escena es inválida [S]
- [x] Implementar reset de agenda del NPC tras teleport [S]
- [x] Implementar restauración de inventario transaccional del NPC [M]
- [x] Implementar eventos de restauración de NPC [S]
- [x] Documentar invariantes de NPC en plan-actual [S]

## Invariantes de misiones

- [x] Implementar MisionInvariant (objetivos existentes) [M]
- [x] Implementar registro declarativo de fallbacks por objetivo [M]
- [x] Implementar detección de condición imposible [M]
- [x] Implementar fallback con recompensa equivalente [M]
- [x] Implementar aviso en diario de misión al activar fallback [S]
- [x] Implementar recompensa no duplicada si el fallback se completó [M]
- [x] Implementar sincronización con persistencia de misiones (M22) [M]
- [x] Implementar pruebas de misiones imposibles (injerto) [M]
- [x] Documentar invariantes de misiones en plan-actual [S]

## Invariantes de puzzles

- [x] Implementar PuzzleInvariant (resoluble en 30 s de diagnóstico) [M]
- [x] Implementar diagnóstico de resolubilidad por slot [M]
- [x] Implementar reinicio del puzzle al estado inicial del slot [M]
- [x] Implementar notificación al jugador del reinicio [S]
- [x] Implementar registro del reinicio en logs de eventos [S]
- [x] Implementar no-reinicio si el puzzle está en progreso válido [M]
- [x] Implementar compatibilidad con M24 y M26 [M]
- [x] Documentar invariantes de puzzles en plan-actual [S]

## Checkpoints

- [x] Implementar CheckpointManager con 3 slots por bioma [M]
- [x] Implementar slot global de emergencia [S]
- [x] Implementar escritura con patrón atómico (tmp+rename+.bak) [M]
- [x] Implementar checkpoint al entrar a bioma [S]
- [x] Implementar checkpoint al completar misión [S]
- [x] Implementar checkpoint al estabilizar vehículo [S]
- [x] Implementar rotación de slots sin borrar el más reciente [M]
- [x] Implementar restauración del checkpoint más cercano para el jugador [M]
- [x] Implementar verificación de integridad post-restauración [M]
- [x] Implementar límite de 4 escrituras por evento [S]
- [x] Documentar checkpoints en plan-actual [S]

## Recuperación del jugador

- [x] Implementar JugadorInvariant (vivo y sobre el mundo) [M]
- [x] Implementar detección de jugador fuera del mundo [S]
- [x] Implementar teletransporte al checkpoint más cercano [M]
- [x] Implementar efectos suaves al recuperar (sin daño extra) [S]
- [x] Implementar toast informativo de recuperación [S]
- [x] Implementar reintegración de estado (stamina, inventario) [M]
- [x] Implementar no-muertes por bug de geometría [M]
- [x] Documentar recuperación del jugador en plan-actual [S]

## Recuperación de vehículos

- [x] Implementar VehiculoInvariant (dentro del mundo) [M]
- [x] Implementar detección de vehículo fuera del mundo [S]
- [x] Implementar reaparición en el amarre tras 30 s [M]
- [x] Implementar amarre alternativo si el principal está ocupado [M]
- [x] Implementar conservación del inventario del vehículo [M]
- [x] Implementar conservación de mejoras al reaparecer [M]
- [x] Implementar eventos de recuperación de vehículo [S]
- [x] Documentar recuperación de vehículos en plan-actual [S]

## Cierres inesperados

- [x] Implementar respaldo antes de cada guardado [M]
- [x] Implementar detección de guardado corrupto al cargar [M]
- [x] Implementar recuperación del respaldo `.bak` ante corrupción [M]
- [x] Implementar aviso de restauración de respaldo [S]
- [x] Implementar test que simula corte a mitad de escritura [M]
- [x] Implementar verificación del estado tras el corte simulado [M]
- [x] Documentar el manejo de cierres inesperados en plan-actual [S]

## Terreno modificado extremo

- [x] Implementar detección de terreno modificado extremo (M08) [M]
- [x] Implementar revalidación de objetos clave tras modificación [M]
- [x] Implementar reubicación del objeto dentro del mismo chunk [M]
- [x] Implementar revalidación de NPC tras modificación de terreno [M]
- [x] Implementar revalidación de vehículos tras modificación [M]
- [x] Implementar revalidación de checkpoints tras modificación [M]
- [x] Implementar fallback de misión si el objetivo quedó en zona inválida [M]
- [x] Implementar test de hundimiento de suelo bajo objetos clave [M]
- [x] Implementar test de elevación de suelo sobre el jugador [M]
- [x] Documentar el manejo de terreno extremo en plan-actual [S]

## Integración y eventos

- [x] Implementar interfaz IRecoverable para sistemas externos [M]
- [x] Implementar integración con persistencia (guardado atómico) [M]
- [x] Implementar integración con M22 (Historia Principal) [M]
- [x] Implementar integración con M26 (Templo Subterráneo) [M]
- [x] Implementar integración con M64 (watchdog NPC) [M]
- [x] Implementar integración con vehículos (amarre) [M]
- [x] Implementar eventos públicos para UI de toast (M57) [M]
- [x] Implementar sin acoplamiento a las misiones (suscripción a eventos) [M]
- [x] Documentar integración en plan-actual [S]

## Rendimiento y robustez

- [x] Implementar costo ≤ 0.5 ms por detección [M]
- [x] Implementar cero I/O síncrona en Update [M]
- [x] Implementar cache de invariantes (sin raycast en masa) [M]
- [x] Implementar sin allocations en Update [M]
- [x] Implementar sin excepciones ante objetos nulos [M]
- [x] Implementar recuperación antes de 15 s desde la detección [M]
- [x] Implementar sin spam de toasts (cooldown) [S]
- [x] Implementar sin duplicados de objetos jamás [M]
- [x] Documentar rendimiento y robustez en plan-actual [S]

## Testings y documentación

- [x] Diseñar 06-Plan-Testings.md con unitarias de invariantes [M]
- [x] Diseñar 06-Plan-Testings.md con integración (cierre, terreno) [M]
- [x] Diseñar 06-Plan-Testings.md con edge cases (cofre lleno, doble recuperación) [M]
- [x] Diseñar 06-Plan-Testings.md con pruebas de rendimiento [M]
- [x] Definir criterio de éxito: suite completa pasa sin fallos [S]
- [x] Crear 07-Resultados-Testings.md para registrar la ejecución [S]
- [x] Documentar todas las decisiones en 02-Analisis y 03-Diseno [M]
- [x] Actualizar plan-actual como espejo del estado real [M]
- [x] Crear Log en Logs/ con formato NN-DESCRIPCION_FECHA [S]
- [x] Actualizar fila 66 en CHECKLIST-GLOBAL al implementar [S]

**Total:** 100/100 [x] — Módulo listo como **DELEGABLE PARA IMPLEMENTAR**.