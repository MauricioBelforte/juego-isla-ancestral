# Log 914: M92 Tutorial — iteración 3 (lógica completa sin UI)

**Fecha:** 2026-09-17
**Hora:** 02:43
**Modelo:** glm-5.3-flash
**Plataforma:** Cline

## Resumen

Iteración 3 del M92 (Tutorial): se completó la **lógica del tutorial sin UI** sobre el núcleo
Deepseek (Log 259) y las iteraciones previas de glm-5.3-flash (Log 336 verificado + Log 911
RF20/RF19). Módulo liberado 🟡 en 90/185; lo restante es UI V2 (M53), guiones .tres (Q5),
capítulos didácticos RF11-RF18 (necesitan mecánicas reales M13/M33-M35/M16), Q1/Q2/Q7/Q8,
S10-S12 y R1/R3/R5/R6.

## Cambios realizados

### `game/isla-ancestral/scripts/tutorial/tutorial_manager.gd` (extensión, núcleo respetado)
- **Señales nuevas:** `feedback_capitulo(capitulo_id, datos)` (RF24/P15), `consejo_mostrado`
  (RF6), `pista_expirada(capitulo_id, motivo)` (P2 cozy), `capitulo_pospuesto(capitulo_id,
  motivo)` (T-016/P13).
- **Constantes:** `MAX_PISTAS_VIVAS=2` (T-041), `COOLDOWN_CONSEJO_S=90.0` (T-047),
  `CONTEXTOS_CONSEJO=["carga_escena","caminata_larga","pausa"]` (T-046),
  `FEEDBACK_DURACION_S=2.0` (RF24).
- **Interruptores RF9 independientes (T-042/043/049):** `pistas_contextuales_activas`,
  `prologo_guiado_activo`, `consejos_activos` + setters/getters (probado que apagar uno no
  afecta a los otros, en todos los órdenes).
- **Consejos RF6 (T-044 a T-048):** `registrar_consejo` / `intentar_mostrar_consejo` /
  `marcar_consejo_visto` / `consejo_visto` — una sola vez, cooldown 90 s, contextos
  restringidos, nunca durante diálogos (M21, duck-typing + flag propio) ni cutscenes.
- **Contexto T-016:** `establecer_contexto` / `contexto_actual` / `_contexto_permitido`
  (hora/día/estación/zona); sin datos del proveedor NO bloquea (cozy) y pospone con señal
  (el capítulo nunca se pierde). O(1) (complementa Q4).
- **Pasos/persistencia P4:** `_paso_pendiente` + `paso_pendiente()` — restaurado el guardado,
  el capítulo se retoma desde el paso pendiente; las preferencias RF9 viajan en
  `get_save_data()` (< 1 KB, RN6).
- **Skip RF7/S5:** `skip_capitulo` (sin marcar completado) y `skip_todo`; ocultan pistas
  de inmediato y sin parpadeo; persisten.
- **Re-play RF8/S6:** `iniciar_replay` / `terminar_replay` / `en_replay` con snapshot del
  estado previo — muestra todos los pasos sin revalidación y sin contaminar la partida
  (RN11); cancelación suave del capítulo en curso (P11).
- **Feedback RF24/P15:** en `_completar` el orden es persistir → señales de estado →
  `feedback_capitulo` (datos: modal=false, duracion_s=2.0, sonido="exito" M44,
  texto_clave para `tr()`).
- **Pistas RF4/S8 (lógica):** `registrar_pista` (cap por capítulo, máx. 2 vivas; excedente
  pospuesto P13), `ocultar_pista(motivo)`, `descartar_pistas` (P14 fast-travel, P7 diálogo),
  `pistas_vivas()`; expiración por timer interno (P2, sin castigo, capítulo queda pendiente).
  Reloj interno por `_process` — NUNCA lee el reloj del SO (GUIA-GODOT §9.64).
- **Edge cases:** `notificar_objetivo_destruido` (P5: cuenta como intento RF20 → descarte
  seguro) y `pausar_por_mundo_inactivo` (P6: retomable cuando el mundo vuelve).

### Tests (binario real `Godot_v4.7.2-stable_win64.exe` — anidado en carpeta homónima)
- `test_tutorial_iter3.gd` **NUEVO: 103 checks** — interruptores RF9, diálogo P7, consejos
  RF6/S9, contexto T-016, pasos/persistencia P4, skip S5, re-play S6, P5/P6, feedback
  RF24/P15 (con orden de eventos), P8 (InputMap en vivo con acción de prueba aislada).
- `scripts/run_m92_tests.bat` **NUEVO:** corre las 3 suites del módulo.
- **Resultado: iter3 0 fallos · triggers 0 fallos (71 checks) · núcleo 0 fallos (22) —
  196 checks en verde, EXIT=0 en las 3.**

### Documentación
- `05-Checklist.md`: **90/185** (46 marcas con evidencia en esta iteración: 39 nuevas + 7 de
  deriva documental previa); Reserva actual → 🟢 Liberado (Log 914).
- `01-Requerimientos.md`: referencia explícita a §3.2 "Fuera del alcance" desde §3.1.
- `04-Codigo.md`: Notas del Agente de la iter. 3 (aditivas).
- Tableros sincronizados: CHECKLIST-GLOBAL (fila 92 → 90/185, 🟡 iter. 3), guía 08
  (fila de registro), ESTADO-PARALELO (fila de tabla).

## Numeración
- Reserva propia: `Logs/reservas/914-glm-5.3-flash-M92.txt` (2026-09-15 03:35) → consumida
  aquí. `Logs/ULTIMO_NUMERO.txt` seguía en 915 por reservas paralelas de otros agentes
  (914 era libre).

## Archivos modificados/creados
- `game/isla-ancestral/scripts/tutorial/tutorial_manager.gd` (extensión)
- `game/isla-ancestral/scripts/tutorial/test_tutorial_iter3.gd` (nuevo)
- `scripts/run_m92_tests.bat` (nuevo)
- `DOCUMENTACION/92-Tutorial/plan-actual/05-Checklist.md`
- `DOCUMENTACION/92-Tutorial/plan-actual/04-Codigo.md`
- `DOCUMENTACION/92-Tutorial/plan-actual/01-Requerimientos.md`
- `CHECKLIST-GLOBAL.md` · `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` ·
  `Mensajes entre modelos/ESTADO-PARALELO.md`
- `DOCUMENTACION/TAREAS-POR-MODELO/glm-5.3-flash/92-Tutorial/checklist.md` (57/173)

## Pendientes declarados (honestidad)
- UI de presentación (M53, V2) y confirmación de re-play (M53).
- Guiones .tres (Q5) y capítulos didácticos RF11-RF18 (requieren M13/M33-M35/M16 reales).
- Q1 (pool de nodos UI), Q2/Q7 (auditoría de polling/alocaciones), Q8 (profiler).
- S10 (E2E cultivo), S11 (profiler), S12 (regresión InputMap) — con mecánicas reales.
- R1/R3/R5/R6 (espejo documental) — revisar al cerrar el módulo.
