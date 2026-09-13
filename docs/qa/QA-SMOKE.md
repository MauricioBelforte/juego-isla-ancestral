# QA-SMOKE.md — Guía de Smoke Test por Build (Módulo 101)

> Smoke test obligatorio en cada build nuevo antes de QA profundo. Duración: < 15 min. Si falla un paso crítico, detener y reportar.

**Build:** [commit] | **Fecha:** [AAAA-MM-DD] | **Tester:** [modelo/plataforma]

## Pasos (7)
1. **Arranque:** El juego inicia sin errores en consola. → [ ]
2. **Menú:** El menú principal responde (si existe M89; si no, ir directo al mundo). → [ ]
3. **Mundo nuevo:** Crear mundo nuevo con semilla 42 → el terreno se genera sin errores. → [ ]
4. **Movimiento/interacción:** Moverse por el mundo, saltar, interactuar con un objeto. → [ ]
5. **Recolectar:** Recolectar 3 items → entran al inventario. → [ ]
6. **Guardar/cargar:** Guardar manualmente, volver al menú, cargar → posición e inventario OK. → [ ]
7. **Debug menu (M110):** Abrir el debug menu sin errores (read-only). → [ ]

## Resultado
- Smoke: **APROBADO / FALLIDO**
- Si falla: documentar el paso, severidad y archivar como issue M102.