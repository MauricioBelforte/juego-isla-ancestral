**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code
**Última actualización:** 2026-09-01

# guia-para-agentes.md — Verificación Post-Tarea para el Protocolo Multiagente (Módulo 101)

> **Propósito:** guía breve para que cualquier agente del protocolo ejecute la verificación post-tarea (AGENTS.md §12) con los criterios de QA del módulo 101. Es la misma verificación que el módulo 101 define para el humano, traducida al flujo de agentes.

## Flujo de verificación post-tarea (resumen ejecutivo)

```
Tarea terminada en módulo X
  → 1. Compilación: 0 errores en consola (get_debug_output / headless)
  → 2. Runtime: probar flujo completo sin excepciones (run_project)
  → 3. Área X: correr los ítems del área X en QA-CHECKLIST.md que tocan mi cambio
  → 4. Dependientes: correr ítems de módulos que dependen de X (col. Dependencias)
  → 5. ¿Hallazgo? → issue M102 (con pasos, build, evidencia)
  → 6. Registrar sesión (QA-SESSION.md) + actualizar 05-Checklist del módulo + log en Logs/ + CHECKLIST-GLOBAL
```

## Reglas específicas por tipo de agente

### Agente SIN visión (solo logs)
- Los ítems marcados `🔍` son verificables por log M103: correr el proyecto, revisar errores/warnings, confirmar señales (EventBus) y estados.
- Los ítems `🎮` (necesitan ver la pantalla) se **marcan `[?]`** con la razón "sin vía de visión" y se pasan al QA de un modelo con visión (V1/V4).
- La suite M112 (headless) es el respaldo automatizado: `godot --headless res://scenes/test_runner.tscn`.

### Agente CON visión (V1 adjuntos / V4 godot-mcp / V2 nativa)
- Correr el juego, capturar el viewport (capturas en `tools/mcp/godot-mcp/capturas/101-QA-General/`), analizar la captura contra el resultado esperado.
- Usar el debug menu (M110) para acelerar (teletransporte, objetos, tiempo/clima).

### Reglas de honestidad (§21.4 AGENTS.md)
- `[ ]` = no verificado. `[?]` = no resuelto (con razón). **Nunca** `[x]` sin evidencia real.
- Si un ítem depende de otro módulo con `🔵` activo, marcarlo `[?]` con el dueño.
- Los ítems visuales sin vía de visión se reportan al coordinador, no se inventan resultados.

## Integración con el ciclo de módulo (§21.3 AGENTS.md)

1. Al **reservar** un módulo: revisar qué áreas del QA-CHECKLIST.md tocan ese módulo (tabla de áreas).
2. Al **trabajar**: la regresión ligera (§QA-REGRESION.md) corre al cerrar cada iteración.
3. Al **liberar**: checklist del módulo con DoD (§21.6) + QA cruzado (§21.8) por otro modelo — el QA cruzado usa los criterios de QA-RELEASE-CRITERIA.md.
4. **Todo módulo visual** (V1/V2) requiere la verificación M154 (guía 06 de conexión de visión) antes de cerrar.

## Check rápido de cierre (15 ítems)

1. [ ] Compila con 0 errores (log M103 limpio de errores)
2. [ ] Sin excepciones en runtime del flujo verificado
3. [ ] Test(s) headless 0 fallos (o suite M112 en verde para el área)
4. [ ] Ítems del área en QA-CHECKLIST pasaron (`[x]`) o hay `[?]` con razón y dueño
5. [ ] Dependientes del módulo sin regresión
6. [ ] Bug hallado → issue M102 creado con evidencia
7. [ ] Regresión reproducible → etiqueta `regresion` + orden de conversión M112
8. [ ] Sesión registrada en `sesiones/` con plantilla QA-SESSION.md
9. [ ] 05-Checklist del módulo actualizado con marca honesta
10. [ ] Log generado en `Logs/` con firma del modelo/plataforma
11. [ ] CHECKLIST-GLOBAL actualizado (estado/progreso/agente/última actividad)
12. [ ] Guía 08 + ESTADO-PARALELO actualizados (reserva/cierre)
13. [ ] Documentos del módulo firmados (plan-actual)
14. [ ] M154 verificado si el módulo es visual (V1/V2)
15. [ ] Instrucciones de guía 07 (Godot) consultadas al codificar

## Hallazgos V4 (2026-09-01, deepseek-v4-flash-vision-exp)

- **INPUT de teclado automatizado (FUNCIONA PARCIAL):** con `godot_run_project` corriendo, enumerar ventanas (`EnumWindows`, título `isla-ancestral (DEBUG)`) y `PostMessageW(hwnd, 0x0100, VK_W, lParam)` + `0x0101` para soltar. W (movimiento) confirmado con capturas antes/después (avatar avanzó, cámara siguió) — el pipeline `Input.is_action_pressed` en `_physics_process` consulta el estado de tecla de Windows y SÍ responde a WM_KEYDOWN sintético.
- **INPUT de UI/acciones (NO FUNCIONA):** F (diálogo), F12 (debug menu), E (equipamiento) y B (inventario) NO disparan la lógica de `_unhandled_input`/`is_action_pressed` desde mensajes sintéticos (Godot no genera los InputEventKey para las capas de input del juego; solo el estado consultado a demanda del movimiento llega). Clicks de mouse (WM_LBUTTONDOWN) tampoco. Para esos casos: depurador remoto del editor (escenas/objetos), o interacción manual (humano) — el QA de UI se reserva al playtesting manual o al QA cruzado.
- **CAPTURA de la ventana:** la presentación D3D12 se suspende si la ventana está oculta (capturas "apagadas"). Truco: `SetWindowPos(hwnd, -1, ...)` (TOPMOST) + esperar ~4 s + `ImageGrab.grab()`, y después volver a NOTOPMOST. Evita el panel Remoto del editor (es GL embebido, no capturable con PrintWindow).
