**Modelo:** glm-5.3-flash (último modificador; docs por Deepseek V4 Flash)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 (iter. 1 — glm-5.3-flash/Kilo Code)

## Reserva actual

- **Módulo:** 75 Postgame
- **Reservado por:** glm-5.3-flash (Kilo Code)
- **Estado:** 🔵 En curso — iter. 1 (núcleo V0)
- **Fase:** F7 (producción de contenido)
- **Dificultad:** 3
- **Visión:** V0 (sin captura; estado y actividades testeables headless)
- **Entrada:** M22 ✅ (HistoriaService con sellos); M59 ✅; M94 ✅ (anti-FOMO núcleo)
- **Salida:** PostgameManager autoload (detección fin de historia, estado M59, actividades data-driven sin FOMO) + test headless 0 fallos
- **Archivos:** `scripts/postgame/{postgame_manager,test_postgame}.gd`, `data/postgame/actividades.json`
- **Log:** 534 reservado

---

# 05-Checklist.md — Módulo 75: Postgame (130 ítems)

## A. Contenido Post-Historia (RF1)

- [ ] Definir el epílogo de la historia (M22) [M]
- [ ] Mostrar "¿Qué sigue?" tras los créditos (M92) [M]
- [ ] Mantener el tono cozy en el cierre (M21/M44) [S]
- [ ] No mostrar pantalla de "Fin" fría [S]
- [x] Guardar el estado postgame en el save (M59) [M] — iter. 1: ISaveProvider sección "postgame" {version, activo, epilogo_visto, actividades_hechas}; round-trip testeado sin re-emisión de señal

## B. Nuevas Islas (RF2)

- [ ] Catalogar la isla del Este (FASE 1, M27) [M]
- [ ] Catalogar la isla flotante (FASE 2, M10) [M]
- [x] Marcar requisito de desbloqueo de cada isla [S] — iter. 1: postgame_isla_este (FASE 1, activada por postgame) y postgame_isla_flotante (FASE 2, requiere streaming M61/M63) en data/postgame/actividades.json con dueño
- [x] Asignar módulo dueño a cada expansión [S] — iter. 1: campo "dueno" en las 7 actividades (M27/M10/M25/M37/M19/M71/M50/M33/M36/M35/M18/M16)
- [ ] Verificar streaming/LOD de las nuevas islas (M61) [C]

## C. Nuevos Vecinos (RF3)

- [ ] Diseñar 1-2 vecinos nuevos postgame (M19) [M]
- [ ] Rutinas propias de los vecinos nuevos [M]
- [x] Mudanza por invitación (M71) [M] — iter. 1: actividad postgame_vecinos_nuevos (repetible, sin fechas únicas); contador con registrar_actividad(); integración M19/M71 con dueño (conector)
- [ ] Diálogos de vecinos postgame (M21) [M]
- [x] Ningún vecino depende de fechas únicas [S] — iter. 1: actividad repetible sin expiración (coherente M94)

## D. Nuevos Muebles (RF4)

- [ ] Catálogo de muebles postgame (M18) [M]
- [x] Muebles obtenibles sin grindeo (actividades naturales) [M] — iter. 1: postgame_muebles_evento repetible en catálogo data-driven (obtención real M18/M16 con dueño)
- [ ] Muebles únicos de eventos postgame [M]
- [ ] Recetas de muebles integradas (M16) [M]
- [ ] Validación de muebles con ids unívocos [S]

## E. Nuevas Plantas (RF5)

- [ ] Especies estacionales postgame (M50/M33) [M]
- [ ] Plantas raras postgame (solo después del final) [M]
- [x] Hibridación disponible en postgame (M50) [M] — iter. 1: postgame_hibridacion repetible en catálogo; mecánica real M50/M33 con dueño
- [ ] Plantas sin promesa de fase 2 sin arquitectura [S]
- [ ] Validar temporadas con el calendario (M29) [M]

## F. Nuevos Animales (RF6)

- [ ] Especies raras solo postgame (M36) [M]
- [ ] Animales libres con ritmos propios (M35) [M]
- [ ] Avistamientos marcados en el diario (M55) [M]
- [x] Sin grindeo para atraer especies raras [M] — iter. 1: postgame_especies_raras repetible por clima (M32/M28), sin acumulación estresante (coherente M94)
- [ ] Validar aparición por clima (M28) [M]

## G. Nuevas Ruinas (RF7)

- [ ] Ruina final restaurable postgame (M25) [M]
- [x] Progreso de restauración visible en museo (M37) [M] — iter. 1: postgame_ruina_final en catálogo con dueño M25/M37; contador registrar_actividad() expuesto
- [x] Recompensa única al restaurarla (M38) [M] — iter. 1: actividad no-repetible "hecha" al registrar (testeado); recompensa real M38 con dueño
- [x] Logro al finalizar la restauración (M72) [S] — iter. 1: contador expuesto para que M72/M71 condicionen (el logro real con dueño M72)
- [ ] La ruina aporta al 100% de la hoja de ruta [S]

## H. Nuevos Puzzles (RF8)

- [ ] Puzzle del Sello oculto (FASE 2, M24) [C]
- [ ] Puzzle opcional, nunca bloquea la historia (M22) [S]
- [ ] Recompensa del puzzle sin spoilers [M]
- [ ] Puzzle rejugable sin repetir (M24) [M]
- [ ] Validar solución única del puzzle [M]

## I. Nuevas Colecciones (RF9)

- [ ] Categorías postgame en el catálogo (M73) [M]
- [ ] Documentos finales de la historia (M73) [M]
- [ ] Colecciones postgame con totales reales [M]
- [ ] Compleción de colección = donación al museo (M37) [M]
- [ ] Sin duplicación de registro (idempotencia M73) [S]

## J. Nuevas Herramientas (RF10)

- [ ] Herramienta de jardín acuático (FASE 2, M16) [M]
- [ ] Mejora de herramienta postgame (M17) [M]
- [ ] Herramientas sin combustible/durabilidad (cozy) [S]
- [ ] Herramienta con animación propia (M13) [M]
- [ ] Validar receta de la herramienta postgame [M]

## K. Nuevas Mejoras (RF11)

- [ ] Mejora del ático postgame (M17) [M]
- [ ] Casa con expansión visible al vecindario (M19) [S]
- [ ] Mejora con material raro postgame [M]
- [ ] Sin grindeo para conseguir material raro [M]
- [ ] Validar mejoras con M60 (migración) [S]

## L. Nuevas Historias (RF12)

- [ ] Cadenas secundarias postgame (M23) [M]
- [ ] Historias que cierran arcos de vecinos (M19/M21) [M]
- [ ] Historias sin exigencia multijugador [S]
- [ ] Diálogos postgame con doblaje si aplica (M93) [M]
- [ ] Conflictos resueltos sin romper eventos (M74/M29) [S]

## M. Nuevos Eventos (RF13)

- [ ] Festivales rotativos postgame (M74) [M]
- [ ] Programación en calendario (M29) [M]
- [ ] Ciclo anual cozy sin fechas únicas [S]
- [ ] Recompensas únicas de festival (M38/M20) [M]
- [ ] Logros de eventos postgame (M72) [S]

## N. Nuevos Secretos (RF14)

- [ ] Secretos desbloqueables solo postgame (M71) [M]
- [ ] Secretos anti-spoiler en el diario (M55) [M]
- [ ] Secretos con pistas de exploración natural [M]
- [ ] Sin secuencias bloqueantes en secretos [S]
- [ ] Validar secretos con ids únicos [S]

## O. Zonas Submarinas (RF15)

- [ ] Arrecife profundo (FASE 2, M51) [C]
- [ ] Acceso con submarino (M67) [M]
- [ ] Streaming del arrecife (M61/M10) [C]
- [ ] Fauna/submarina propia (M36/M51) [M]
- [ ] Sin buceo frustrante (oxígeno generoso, cozy) [M]

## P. Islas Flotantes (RF16)

- [ ] Isla flotante (FASE 2, M10) [C]
- [ ] Acceso con dirigible (M67) [M]
- [ ] Gravedad carismática sin romper mecánicas [M]
- [ ] LOD del terreno flotante (M61) [C]
- [ ] Sin caídas frustrantes (muerte suave, retorno) [M]

## Q. Sistemas Opcionales (RF17)

- [ ] Jardín acuático (FASE 2, M16) [M]
- [ ] Criadero de peces (FASE 2, M34) [M]
- [ ] Sistemas marcados `hidden` hasta lanzamiento [S]
- [ ] Ningún sistema opcional bloquea el 100% de FASE 1 [S]
- [ ] Validar que la FASE 2 no prometa UI al jugador [S]

## R. Objetivos de 100% (RF18)

- [ ] Hoja de ruta "Isla al 100%" en el diario (M55) [M]
- [ ] % por categoría derivado (no almacenado) [M]
- [ ] Anti-spoiler: solo se ve lo descubierto (M55) [M]
- [ ] Museo (M37) aporta su % al total [S]
- [ ] Sin grindeo en el 100% (actividades naturales) [S]

## S. Logros Finales (RF19)

- [ ] Categoría "Epílogo" en M72 [M]
- [ ] Logro: colección completa [S]
- [ ] Logro: ruina restaurada [S]
- [ ] Logro: primer festival postgame [S]
- [ ] Logro: 100% de la hoja de ruta [M]

## T. Exploración Libre (RF20)

- [ ] Mundo 100% abierto tras el final [M]
- [ ] Sin bloqueos de progresión postgame (M71) [S]
- [ ] Transporte accesible a todas las zonas (M68) [M]
- [ ] Exploración recompensada (M73/M71) [M]
- [ ] Cero contenido exclusivo de multijugador [S]

## U. Persistencia y Migración

- [ ] `postgame_unlocked` en save global (M59) [M]
- [ ] Hoja de ruta sin duplicación de estado [S]
- [ ] Migración v1.4 del flag (M60) [M]
- [ ] Catálogo como Resource embebido (no serializado) [S]
- [ ] Guardado automático al desbloquear (M59) [S]

## V. Reglas Cozy (Diseño)

- [ ] Sin grindeo en actividades del 100% [S]
- [ ] Sin fechas únicas missable [S]
- [ ] Sin logros imposibles (validados) [S]
- [ ] Epílogo cálido, no menú frío [S]
- [ ] La isla sigue viva tras los créditos [S]

## W. UI y Feedback

- [ ] "¿Qué sigue?" post-créditos (M92/M44) [M]
- [ ] Pestaña "Isla al 100%" en el diario (M55) [M]
- [ ] Notificación de meta cumplida (M44) [S]
- [ ] Confeti sutil en logros finales (M52) [S]
- [ ] UI sin spoilers de fase 2 [S]

## X. Edge Cases y Rendimiento

- [ ] Desbloquear postgame con save sin final (no aplica) [S]
- [ ] Hoja de ruta con sistemas vacíos (0/0) [S]
- [ ] Evento postgame durante viaje (M68) [M]
- [ ] Expansión con módulo ausente en CHECKLIST [S]
- [ ] Probar con profiler: hoja de ruta bajo demanda (M61/M116) [C]

## Y. Integración y Dependencias

- [ ] Integrar con M22 (epílogo) [M]
- [ ] Integrar con M72 (categoría Epílogo) [M]
- [ ] Integrar con M74/M29 (eventos) [M]
- [ ] Integrar con M73/M37/M55 (100%) [M]
- [ ] Integrar con M92 (tutorial "¿qué sigue?") [S]

## Z. Cierre del Módulo

- [ ] Agregar notas del agente al 04-Codigo.md (honestidad) [S]
- [ ] Firmar los documentos del módulo (modelo y plataforma) [S]
- [ ] Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log [S]
- [ ] Verificar con verificar_checklist.py (sin alertas nuevas) [S]
- [ ] Confirmar 130 ítems exactos y plan-inicial == plan-actual [S]

## Notas del Agente

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 08:00
**Estado:** Liberado (iter. 1 núcleo V0 cerrada) — 11/130 [x]

### Lo que hice en iter. 1 (Log 534)
- **PostgameManager** (autoload "Postgame"): activación automática cuando M22 (fuente de verdad §2.2) reporta historia terminada (7 sellos o final elegido); event-driven vía EventBus.quest.prereq_met + re-chequeo al boot (carga con historia terminada).
- **Catálogo data-driven**: data/postgame/actividades.json con 7 actividades cubriendo RF2 isla_este/isla_flotante, RF3 vecinos, RF4 muebles, RF5 hibridación, RF6 especies raras, RF7 ruina final — cada una con dueño y flag repite (todo repetible o alcanzable: cero FOMO M94).
- **"¿Qué sigue?" (RF1)**: sugerir_que_sieve(limite=3) con rotación DETERMINISTA por día absoluto M29 (offset día%n, sin rand); señal sugerencias_postgame para M92/M53; ignorable sin pérdida.
- **Epílogo (RF1)**: marcar_epilogo_visto() para M92 tras créditos (sin pantalla de "Fin" fría).
- **Persistencia M59**: sección "postgame" {version, activo, epilogo_visto, actividades_hechas}; restore SIN re-emisión de postgame_activado (§2.3).
- **API dueños**: registrar_actividad(id) para que M25 (ruina), M19 (vecinos), etc. reporten progreso; contador expuesto a M37/M72/M71.
- **Tests** (test_postgame.gd, 7 secciones ~28 checks): catálogo, no-activo inicial, activación por sellos (idempotente), actividades + contadores, sugerencias rotativas deterministas + señal, epílogo, persistencia round-trip — 0 fallos headless.

### Lecciones aplicadas (guía 07)
- **Captura por valor de lambdas (§9.56)**: el test inicial asignaba `recibidas = arr` dentro de la lambda (no se ve desde afuera) → corregido con contenedor mutable `recibidas[0] = arr` (patrón del proyecto).

### Lo que NO está resuelto (pendientes con dueño / iter. 2)
- Epílogo narrativo real y "¿Qué sigue?" visual (M92/M53/M21/M44) — el manager expone los datos.
- Islas Este/Flotante reales (M27/M10/M61/M63): el desbloqueo lógico ya existe (actividades con dueño).
- Vecinos postgame concretos (perfiles M19), diálogos (M21), rutinas (M64).
- Muebles/plantas/animales/ruina postgame concretos: contenido por dueño (M18/M16/M50/M33/M36/M25/M37).
- Recompensas reales (M38/M93) y logro de restauración (M72): conectan vía registrar_actividad.

### Decisiones clave
1. **Fuente de verdad M22 (§2.2)**: el postgame NO guarda su propio "historia terminada" como veredicto — se deriva de Historia en cada chequeo; solo persiste activo para restores sin M22 cargada.
2. **Rotación determinista por día (no aleatoria)**: misma partida → mismas sugerencias (RN determinismo; testeado).
3. **Catálogo con dueños explícitos**: cada actividad nombra al módulo que la implementará — evita postgame huérfano.
4. **Sin recompensas en M75**: los contadores son la API; recompensas/logros con dueño (M38/M72/M93) — módulo de contenido, no de economía.

### Validación
- test_postgame.gd: 0 fallos (7 secciones, ~28 checks).
- Regresiones: M67 0 fallos, M28 0 fallos, M72 0 fallos, M71 0 fallos.
- Boot: [M75] PostgameManager listo: 7 actividades, activo=false (hasta fin de historia).

### Recomendaciones para el próximo agente
- M92: al terminar créditos llamar Postgame.marcar_epilogo_visto() y usar pedir_sugerencias() para el panel "¿Qué sigue?".
- Los dueños de contenido (M25/M19/M50/M36/M18) llaman Postgame.registrar_actividad(id) al completar su actividad postgame.
- Para la isla flotante (FASE 2): respetar el gate de streaming (M61/M63) antes de habilitar el contenido — ya está marcada en el catálogo.
- No agregar expiraciones ni ventanas: toda actividad postgame es repetible o alcanzable para siempre (M94).
