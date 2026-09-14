# Log 829: M31-Ciclo-Dia-Noche Iter3 Auditoría A-J + Test Contrato

**Fecha:** 2026-09-12
**Hora:** 02:40
**Modelo:** GLM-5.3 (flagship de Z.ai, 743B)
**Plataforma:** Kilo Code

## Resumen

Iteración 3 de M31-Ciclo-Dia-Noche: **auditoría doc↔código de las secciones A-J** (gap de marcado tipo M29 — el header del checklist decía "131 completados" pero las secciones estaban mayormente `[ ]` contra el núcleo runtime (iter. 1, Log 302-ref), las curvas data-driven (iter. 2, Log 452-ref) y los ramps M49 (Log 731) ya implementados) + **cierre de 2 brechas reales de testing**: el CONTRATO central del módulo (`EventBus.time.fase_cambio`) nunca se testeaba, y `var _fases_recibidas` era código muerto desde la iter. 1. Resultado: **115 [x] / 0 [ ] / 54 [?] con dueño** (de 16/161). test_ciclo_dia_noche.gd pasa de 12 → **16 checks, 0 fallos**.

## Cambios Realizados

1. **Auditoría A-J (92 ítems marcados con evidencia):** cada `[x]` lleva número de línea de `day_night_cycle.gd` (p. ej. franjas L83-92, tween L142-159, fallback L122-140, rotación arcos L173-194), archivo de data (`day_curve.tres`, `fase_umbral.json` §estrellas/§luces_artificiales), check de test ("piso ambiente nocturno >= 0.15" [OK]) o sección del 03-Diseno. Los ítems que no cumplen quedaron `[?]` honestos con dueño: 9 escénicos V2 (luna/nubes/estrellas/faroles/FogVolume — M45/M18), contenido de otros módulos (M15 flora nocturna, M52, M74, M25/M148, M55, M58, M110, M114, M12), cables de dueños 🔵 activos (M41/M42 de agnes-2.5-flash — respetados, no tocados).
2. **Consumidores F verificados por grep REAL** (no por deseo del diseño): M19 consume hora_cambio propia (villager_manager L127), M36 `candidatas_para(hora,bioma)` (fauna_manager L46), M34 FRANJAS propias (fishing_manager L20), M39 `esta_abierta(dia,hora)` (shop.gd L45), M41 variante `_noche` (music_director L48), M42 `set_fase()` (ambient_director L52). M33 "sin efecto horario" verificado por AUSENCIA (farm/*.gd sin lectura de hora — la ausencia ES la decisión cozy). F.13 "contrato solo por señales": 0 imports de day_night_cycle fuera de tests.
3. **Test del CONTRATO EventBus.time.fase_cambio (brecha real):** el test solo validaba `get_fase()` interno; la señal del contrato (el producto central que M31 entrega a consumidores) nunca se testeaba. Nuevo bloque en `test_ciclo_dia_noche.gd`: instancia el bus real (`get_node_or_null("/root/EventBus")` con fallback `BUS.new()` + add_child para headless), conecta `fase_cambio`, y valida: sin señal en misma franja (23→23), exactamente 1 señal al cambiar (23→5), payload `== FASE_ALBA` correcto, 1 señal (5→7), desconexión limpia. Suite 12 → **16 checks, 0 fallos**.
4. **Código muerto activado:** `_fases_recibidas` (declarada sin uso desde iter. 1) ahora es el receiver del test del contrato.

## Verificación (binario real Godot 4.7.2 headless, 2026-09-12)

- test_ciclo_dia_noche: **16/16** (mejorado, contrato testeado) · test_curvas_luz: 0 fallos · test_ramps_color_m49: 10/0 · test_calendario (M29): 13/0 · test_clima (M32): 0 fallos · test_consumidores_tiempo: 12/0 · test_semilla_iter1 (M29 H120): 25/25 — **7 suites, 0 fallos**.
- Anti-colisión verificada ANTES de bloquear: sin reservas de protocolo activas (828 de WorkBuddy consumido como `828-M68-Iter1`), fila 31 sin 🔵, guía 08 fila estancada en iter. 1 (actualizada), ESTADO-PARALELO sin conflicto.

## ⚠️ Incidente de infraestructura resuelto (documentado para todos los agentes)

Durante la sesión, TODOS los tests empezaron a fallar con `ERROR: Attempt to open script 'res://...' resulted in error 'File not found'` — archivos que existen en disco. Diagnóstico: (1) un `--import` abortado por el usuario + (2) corridas back-to-back de procesos headless degradaron/corrompieron `.godot/uid_cache.bin` (87 KB). El error era INTERMITENTE (aislado funcionaba, en cadena fallaba; con sleeps de 15 s seguía fallando). **Fix aplicado: borrar `.godot/uid_cache.bin` (se regenera solo en la próxima corrida) — NO tocar código ni imported/.** Tras el fix: 7/7 suites verde. Lección: si "file not found" aparece en scripts que existen, primero regenerar uid_cache antes de sospechar del código. Comando: `Remove-Item .godot/uid_cache.bin` (headless corrección automática).

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/world/test_ciclo_dia_noche.gd` (+4 checks del contrato, +receiver, +preload BUS; BOM verificado limpio)
- `DOCUMENTACION/31-Ciclo-Dia-Noche/plan-actual/05-Checklist.md` (auditoría A-J con evidencia + sección L + totales reales 115/0/54; BOM preexistente saneado)
- `DOCUMENTACION/31-Ciclo-Dia-Noche/plan-actual/04-Codigo.md` (Notas del Agente iter. 3; BOM preexistente saneado; CR/form-feed corruptos de la escritura saneados)
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (fila M31 iter. 3)
- `CHECKLIST-GLOBAL.md` (fila 31; BOM preexistente saneado)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (entrada iter. 3)
- `DOCUMENTACION/30-Reloj-En-Tiempo-Real/plan-actual/{05-Checklist,04-Codigo}.md` (BOM preexistente saneado, de paso §28)

## Notas

- Contador del módulo: 16/161 → **115/169** (la auditoría tiende el puente doc↔código; 54 [?] con dueño identificado NO son deuda del core).
- Logs 302/452 referenciados por las iters previas de M31 son de OTROS módulos (colisión histórica de numeración anterior al protocolo v2) — referencias internas del checklist aclaradas en la auditoría.
- Log reservado con protocolo v2 §6.1.a (verificación archivo+reserva+ULTIMO_NUMERO; reserva `Logs/reservas/829-glm-5.3-M31.txt` consumida al escribir este log).
- M153-Objetivo-Final fue evaluado y DESCARTADO como siguiente módulo con honestidad (ver Log 827): sus 10 [?] son telemetría M105 (dueño activo hoy) y verificaciones de fase jugable.
