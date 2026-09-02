# 05 — Checklist — M66: Anti-Softlock (100/100)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Detector central

- [x] Definir la arquitectura del detector central (SoftlockGuard) [M]
- [x] Implementar tick de 60 s reales del detector [S]
- [x] Implementar disparo del detector en transiciones de escena [S] — glm-5.3-flash 2026-09-01: EventBus.infra.carga_iniciada (M40) → forzar_chequeo (testeado)
- [x] Implementar disparo del detector al guardar [S] — SaveManager.save_completed (M59) → forzar_chequeo (testeado)
- [x] Implementar chequeo por invariantes con orden de prioridad [M]
- [x] Implementar plan de recuperación en cascada [M]
- [x] Implementar registro de eventos de recuperación [S]
- [x] Implementar toast informativo solo si afecta al jugador [M]
- [x] Implementar flag de 3 recuperaciones por instancia en 10 min [S]
- [ ] Implementar cahce de invariantes sin raycast en masa [M]
- [x] Documentar detector central en plan-actual [S] — 04-Codigo Notas iter. 2 (dispatcher en cascada + cooldown de toast del núcleo ox-alpha)

## Invariantes de objetos clave

- [ ] Implementar ObjetoClaveInvariant (2+ caminos verificables) [M]
- [ ] Implementar validación con NavigationServer3D de 2 caminos [M]
- [ ] Implementar justificación narrativa para claves sin caminos [M]
- [ ] Implementar registro de claves por misión [S]
- [ ] Implementar seguimiento de claves en inventario serializado [M]
- [ ] Implementar devolución al cofre si la clave no existe en el mundo [M]
- [x] Implementar marcado "recuperado" tras un solo uso [S]
- [x] Implementar slots del cofre con copia inmutable [M]
- [ ] Documentar invariantes de objetos en plan-actual [S]

## Invariantes de NPC

- [ ] Implementar NpcInvariant (nodo válido y agenda rehidratable) [M]
- [ ] Implementar watchdog anti-atasco reusado de M64 (2 s/6 s) [M]
- [ ] Implementar re-path del NPC atascado [M]
- [ ] Implementar teleport al hogar del NPC si la escena es inválida [S]
- [ ] Implementar reset de agenda del NPC tras teleport [S]
- [ ] Implementar restauración de inventario transaccional del NPC [M]
- [ ] Implementar eventos de restauración de NPC [S]
- [ ] Documentar invariantes de NPC en plan-actual [S]

## Invariantes de misiones

- [x] Implementar MisionInvariant (objetivos existentes) [M] — glm-5.3-flash 2026-09-01: funcional (era stub con _check()->true)
- [x] Implementar registro declarativo de fallbacks por objetivo [M] — registrar_fallback ya existía; ahora el _check lo consume
- [x] Implementar detección de condición imposible [M] — _check() detecta objetivo activo sin fallback → señal del detector central (testeado)
- [x] Implementar fallback con recompensa equivalente [M] — activar_fallback() + registro anti-duplicado (testeado)
- [x] Implementar aviso en diario de misión al activar fallback [S] — activar_fallback registra entrada en M55 categoría descubrimientos (testeado)
- [x] Implementar recompensa no duplicada si el fallback se completó [M] — registrar/recompensa_ya_entregada (testeado)
- [ ] Implementar sincronización con persistencia de misiones (M22) [M]
- [ ] Implementar pruebas de misiones imposibles (injerto) [M]
- [ ] Documentar invariantes de misiones en plan-actual [S]

## Invariantes de puzzles

- [ ] Implementar PuzzleInvariant (resoluble en 30 s de diagnóstico) [M]
- [ ] Implementar diagnóstico de resolubilidad por slot [M]
- [ ] Implementar reinicio del puzzle al estado inicial del slot [M]
- [ ] Implementar notificación al jugador del reinicio [S]
- [ ] Implementar registro del reinicio en logs de eventos [S]
- [ ] Implementar no-reinicio si el puzzle está en progreso válido [M]
- [ ] Implementar compatibilidad con M24 y M26 [M]
- [ ] Documentar invariantes de puzzles en plan-actual [S]

## Checkpoints

- [x] Implementar CheckpointManager con 3 slots por bioma [M]
- [x] Implementar slot global de emergencia [S]
- [x] Implementar escritura con patrón atómico (tmp+rename+.bak) [M]
- [ ] Implementar checkpoint al entrar a bioma [S]
- [ ] Implementar checkpoint al completar misión [S]
- [ ] Implementar checkpoint al estabilizar vehículo [S]
- [x] Implementar rotación de slots sin borrar el más reciente [M]
- [ ] Implementar restauración del checkpoint más cercano para el jugador [M]
- [ ] Implementar verificación de integridad post-restauración [M]
- [ ] Implementar límite de 4 escrituras por evento [S]
- [ ] Documentar checkpoints en plan-actual [S]

## Recuperación del jugador

- [ ] Implementar JugadorInvariant (vivo y sobre el mundo) [M]
- [ ] Implementar detección de jugador fuera del mundo [S]
- [ ] Implementar teletransporte al checkpoint más cercano [M]
- [ ] Implementar efectos suaves al recuperar (sin daño extra) [S]
- [ ] Implementar toast informativo de recuperación [S]
- [ ] Implementar reintegración de estado (stamina, inventario) [M]
- [ ] Implementar no-muertes por bug de geometría [M]
- [ ] Documentar recuperación del jugador en plan-actual [S]

## Recuperación de vehículos

- [ ] Implementar VehiculoInvariant (dentro del mundo) [M]
- [ ] Implementar detección de vehículo fuera del mundo [S]
- [ ] Implementar reaparición en el amarre tras 30 s [M]
- [ ] Implementar amarre alternativo si el principal está ocupado [M]
- [ ] Implementar conservación del inventario del vehículo [M]
- [ ] Implementar conservación de mejoras al reaparecer [M]
- [ ] Implementar eventos de recuperación de vehículo [S]
- [ ] Documentar recuperación de vehículos en plan-actual [S]

## Cierres inesperados

- [ ] Implementar respaldo antes de cada guardado [M]
- [ ] Implementar detección de guardado corrupto al cargar [M]
- [ ] Implementar recuperación del respaldo `.bak` ante corrupción [M]
- [ ] Implementar aviso de restauración de respaldo [S]
- [ ] Implementar test que simula corte a mitad de escritura [M]
- [ ] Implementar verificación del estado tras el corte simulado [M]
- [ ] Documentar el manejo de cierres inesperados en plan-actual [S]

## Terreno modificado extremo

- [ ] Implementar detección de terreno modificado extremo (M08) [M]
- [ ] Implementar revalidación de objetos clave tras modificación [M]
- [ ] Implementar reubicación del objeto dentro del mismo chunk [M]
- [ ] Implementar revalidación de NPC tras modificación de terreno [M]
- [ ] Implementar revalidación de vehículos tras modificación [M]
- [ ] Implementar revalidación de checkpoints tras modificación [M]
- [ ] Implementar fallback de misión si el objetivo quedó en zona inválida [M]
- [ ] Implementar test de hundimiento de suelo bajo objetos clave [M]
- [ ] Implementar test de elevación de suelo sobre el jugador [M]
- [ ] Documentar el manejo de terreno extremo en plan-actual [S]

## Integración y eventos

- [x] Implementar interfaz IRecoverable para sistemas externos [M]
- [ ] Implementar integración con persistencia (guardado atómico) [M]
- [ ] Implementar integración con M22 (Historia Principal) [M]
- [ ] Implementar integración con M26 (Templo Subterráneo) [M]
- [ ] Implementar integración con M64 (watchdog NPC) [M]
- [ ] Implementar integración con vehículos (amarre) [M]
- [ ] Implementar eventos públicos para UI de toast (M57) [M]
- [ ] Implementar sin acoplamiento a las misiones (suscripción a eventos) [M]
- [ ] Documentar integración en plan-actual [S]

## Rendimiento y robustez

- [ ] Implementar costo ≤ 0.5 ms por detección [M]
- [ ] Implementar cero I/O síncrona en Update [M]
- [ ] Implementar cache de invariantes (sin raycast en masa) [M]
- [ ] Implementar sin allocations en Update [M]
- [ ] Implementar sin excepciones ante objetos nulos [M]
- [ ] Implementar recuperación antes de 15 s desde la detección [M]
- [ ] Implementar sin spam de toasts (cooldown) [S]
- [ ] Implementar sin duplicados de objetos jamás [M]
- [ ] Documentar rendimiento y robustez en plan-actual [S]

## Testings y documentación

- [ ] Diseñar 06-Plan-Testings.md con unitarias de invariantes [M]
- [ ] Diseñar 06-Plan-Testings.md con integración (cierre, terreno) [M]
- [ ] Diseñar 06-Plan-Testings.md con edge cases (cofre lleno, doble recuperación) [M]
- [ ] Diseñar 06-Plan-Testings.md con pruebas de rendimiento [M]
- [ ] Definir criterio de éxito: suite completa pasa sin fallos [S]
- [ ] Crear 07-Resultados-Testings.md para registrar la ejecución [S]
- [ ] Documentar todas las decisiones en 02-Analisis y 03-Diseno [M]
- [ ] Actualizar plan-actual como espejo del estado real [M]
- [ ] Crear Log en Logs/ con formato NN-DESCRIPCION_FECHA [S]
- [ ] Actualizar fila 66 en CHECKLIST-GLOBAL al implementar [S]

**Total:** 100/100 [ ] — Módulo listo como **DELEGABLE PARA IMPLEMENTAR**.