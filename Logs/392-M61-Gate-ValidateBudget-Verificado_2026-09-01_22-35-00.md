# Log 392: M61 Rendimiento — Gate ValidateBudget verificado (0 fallos) y medición real cerrada

**Fecha:** 2026-09-01
**Hora:** 22:35
**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code

## Resumen

Se ejecutó el gate del presupuesto (ValidateBudget, headless) sobre la configuración real del proyecto: **0 fallos, exit 0**. Con esto el ciclo de M61 (iteración 2) queda cerrado: herramienta de medición (bench), mediciones reales y gate de validación funcionando; solo queda el cableado remoto a GitHub Actions que pertenece al módulo M118.

## Cambios Realizados / Verificación

- `godot --headless -s res://scripts/performance/validate_budget.gd` → `=== VALIDATE BUDGET M61: 0 fallo(s) ===`, exit 0:
  - budgets.json abierto y JSON válido; `presupuesto_total_ms` (16.7) y `tolerancia_ci` (>0) válidos.
  - 7 categorías declaradas (RF28), todas > 0, suma coherente (≤ total × 1.3).
  - Hardware mínimo/recomendado declarado en la tabla.
  - Caso correcto aceptado y caso excedido detectado (retorno correcto del validador).
- La medición real del bench (Log 386: frame 16.35 ms) queda validada contra el total de 16.7 ms (dentro de tolerancia) — primer valor de referencia del gate una vez automatizado.
- Documentación: `05-Checklist.md` M61 (bloque "Iteración 2c — Gate verificado", 30/130), `CHECKLIST-GLOBAL.md` (fila 61), guía 08 (fila M61), `ESTADO-PARALELO.md` (fila M61).

## Pendientes con dueño (ajenos, documentados)

- Cableado del gate a GitHub Actions (job con validate_budget + bench): **M118 CI-CD** (0/100, 🟢) — nota: el workflow actual de tests usa Godot 4.3 y el proyecto es 4.7.2; actualizarlo es parte de M118.
- Instrumentación por categorías en módulos dueños (M07/M50) y medición en GPU mínima (M114): fuera del alcance del bench.

## Archivos Modificados/Creados

- Modificados: `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md`, `CHECKLIST-GLOBAL.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`, `Mensajes entre modelos/ESTADO-PARALELO.md`, `Logs/ULTIMO_NUMERO.txt` (→392)

## Verificación

- Gate: 0 fallos, exit 0 (comando reproducible — base del futuro job CI de M118).
- Cierre total del ciclo M61 por mi línea: herramienta + mediciones + validación + documentación.
