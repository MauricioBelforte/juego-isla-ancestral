# PROMPT LISTO PARA PEGAR EN EL CRON DE BEAM (fundador 23oct 08:59)

Tu trabajo: ejecutar TODAS las tareas investigadas de tu backlog de forma continua por bloques, y generar UN reporte consolidado final por mensajes (el único acuse de la jornada). Tu cron está APAGADO — estas tareas te esperan para cuando se re-active la sesión.

## REGLA ÚNICA DE ENTREGA
**UN SOLO reporte consolidado al final de TODAS las tareas** (por mensajes, numerado con head del pool). Sin reportes por micro-block, sin acuses intermedios: tu informe final tiene una sección por cada bloque con el estado numérico (conteo con lstrip antes/después), los hallazgos con línea exacta, y las deudas desbloqueadas con quién debe cerrarlas.

## TU COLA COMPLETA PENDIENTE (en orden de ejecución)

### BLOQUE 1 — Estrategia de venta (mi 260): 5 tablas
1. Benchmark de industria (comparables cozy: Stardew 14.99, A Short Hike 19.99, Unpacking 19.99, Spiritfarer 29.99, Garden Story 19.99, Cozy Grove 14.99) — banda objetivo para Isla Ancestral con conclusion
2. Escenarios del paquete de ediciones con ARPU ponderado (mix 60/30/5/5): base 19.99/24.99/29.99 × Deluxe (+5/+10/+15) x Coleccionista (+20/+35/+45) — el combo que maximiza revenue por visitante
3. DLC y bundles: DLC-1 9.99 vs 14.99, DLC-2 4.99, bundle base+OST 10-15% off — analiza si canibaliza o suma, recomendación numérica
4. Descuentos y ventanas año-1: launch -10% (2 sem), Steam sales -25/-33/-50% — proyección simple de revenue año-1 con la curva indie (pico + decay + sales)
5. Regional pricing: tabla Steam de regiones con purchasing power parity, coherente con 24.99 base

## BLOQUE 2 — Presupuestos II: fórmulas concretas (23 items que montó el director en los 9 03s — tuyos ahora)
Para cada ítem, agregar la **fórmula concreta** (EJ: "umbral = base + 0.15 × nivel"), **valor numérico** (EJ: "nivel 2 = 30"), **unidad** (EJ: "AO", "ms", "MB"), y **dependencia cruzada** (EJ: "coherente con M93 dinero_diario 80"):
- Presupuesto de sensibilidad de umbrales (±15%) — M72
- Presupuesto de scaling de recompensas por tier (200/400/800/1600 AO) — M72
- Presupuesto de casos-límite: logros de coleccionista al 99% — M72
- Presupuesto de peaks de eventos por frame (max 8 ev/s) — M105
- Presupuesto de esquema de versionado (v1/v2 paralelo 30 días) — M105
- Presupuesto de cross-referencing M105-M144 (las 9 métricas mapeadas en valores) — M105
- Presupuesto de retención por capas (diario 30 / semanal 12 / mensual 60) — M107
- Presupuesto de verificación de integridad (hashes CRC32 + SHA256) — M107
- Presupuesto de cadencia hotfix <72h numérico (horas/max por semana) — M119
- Presupuesto de etapas de rollout canary (5% / 25% / 100%) — M119
- Presupuesto de polígonos por bioma (costa/bosque/volcánico/claro, tabla PCS) — M09
- Presupuesto de LOD levels por distancia (3-4 niveles, distancias 5/15/40) — M09
- Presupuesto de texturas MB por bioma (4 biomas × 4 material-pipe) — M09
- Presupuesto de tiempo de creación/regeneración < 30s (con M96/M112 numbers) — M09
- Presupuesto de distribución de checks por módulo (la tabla de 111+ módulos) — M112
- Presupuesto de flakes por semana semáforo (<2 con fix en 1 week) — M112
- Presupuesto de sesiones × tester × perfil revisado cosechas (30 sesiones) — M114
- Presupuesto USD por disciplina (artes/qa/builds sumado) — M114
- Presupuesto de fixes por ronda (max 5/ronda) — M114
- Presupuesto de saveset de fotos (50 fotos × 1MB) revisado — M116
- Presupuesto de matriz de shortcuts por plataforma (desktop/menu/steam, 3 platform × 2) — M116
- Presupuesto de runs free-tier 20 concurrentes y 2000 min/mes — M118
- Presupuesto de pesos de artefactos × retención 7d/90d — M118

## BLOQUE 3 — REVERIFICACIÓN H16 con la línea del fundador
Cuando el fundador fije el precio del Coleccionista (69.99 / 79.99 / otro), verifica las 3 fuentes (ediciones.json, monetizacion.json, 03-Diseno) y flippa el item espejo del 05 con cita. (Si el fundador aún no la da, deja esta tarea pendiente anotada — no la fuerzes.)

## CIERRE
- Cambia esta nota al cierre ("Tu 297 consumido...") y agréguele: "297 entregado, 23 definidas, espera del precio del fundador o próxima pila del CRON E".
- Deja el estado listo (paquete finales en fila, hallazgos escalados) y sin push.

## FUENTES CANÓNICAS DE MÉTODO (si lo necesitas)
- Guía completa: `Mensajes entre modelos/GUIA-NUMERACION-CANALES.md` (estándar, agrupado por centena completa, renumeración, long-path, trampas, comandos)
- Herramienta de agrupado: `python -X utf8 scripts/agrupar_canales.py [canal-opcional]`
- Herramienta de renumeración: `python -X utf8 scripts/renumerar_canal.py "Mensajes entre modelos/<agente>"`

Consumido 297 — FIRMA: GLM-5.3 Flash-Director / Kilo Code (23oct 09:00). **El fundador puede pegar este prompt en el cron de cualquier agente; adaptá el nombre de agente según corresponda.**
