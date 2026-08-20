**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 94: Retención sin FOMO

## 1. Análisis del dominio
La retención sana combina 3 mecanismos:

1. **Objetivos temporales voluntarios (diario/semanal/mensual)**: dan razón para volver, pero SIEMPRE sustituibles por otro objetivo igual que no expire (pareja de objetivos rotatorios).
2. **Metas de largo plazo**: colecciones, construcción, relaciones, misterios y postgame — nunca expiran.
3. **Sorpresas y eventos**: motivan explorar; los eventos repetibles no pierden valor si se jugó otra ocasión.

El FOMO típico (streaks, contenido temporal exclusivo, penalizaciones) genera ansiedad y abandono; el proyecto decide explícitamente evitarlo como principio de diseño (M152).

## 2. Alternativas consideradas y decisiones

### D1: Objetivos temporales
- **A1 (objetivos únicos que expiran)**: FOMO disfrazado.
- **A2 (par de objetivos rotatorios por plazo; si no cobrás, se acumula en el diario)**: motivo para volver sin pérdida.
- **Decisión:** **A2** — cada plazo (día/semana/mes) ofrece 2 objetivos simultáneos; al vencerse, las recompensas sin cobrar pasan a "sobremesa" del diario (RF9).

### D2: Calendario de eventos
- **A1 (calendario de tiempo real)**: el ausente pierde festividades.
- **A2 (calendario de día de juego + rotación de variantes)**: el evento se repite cada ciclo con variantes; nunca se pierde (M29/M74).
- **Decisión:** **A2** — el calendario avanza con días jugados (reloj interno M29) y cada festividad tiene 3+ variantes rotatorias.

### D3: Recompensas
- **A1 (recompensas exclusivas de evento)**: molde FOMO.
- **A2 (recompensas de evento = ítems/cosméticos del catálogo general + comodidades)**: nada exclusivo temporal; lo raro va a colecciones de larga duración.
- **Decisión:** **A2** — catálogo único: los ítems de eventos son del inventario general (M16/M73), con descuentos o dropboost, nunca exclusivos por fecha.

### D4: Ausencia
- **A1 (mundo simulado con calendario real)**: castiga al ausente (cultivos muertos, casas rotas).
- **A2 (mundo estático mientras no se juega; el tiempo solo avanza durante sesión)**: sin castigo; los ciclos de día van jugados, no reales (M29/M59).
- **Decisión:** **A2** — el tiempo del mundo avanza solo en sesión; ausentarse no conlleva ninguna pérdida (excepto el propio ritmo natural, comunicado con claridad).

### D5: Postgame
- **A1 (postgame pequeño, agradecimiento y cierre)**: desperdicia inversión narrativa.
- **A2 (postgame con contenido: 5+ h de desafíos, misterio final y modo "isla perfecta")**: retención a largo plazo.
- **Decisión:** **A2** — postgame especificado con 3 bloques (desafíos, misterio final, proyecto isla perfecta).

## 3. Riesgos y mitigaciones
| Riesgo | Prob | Impacto | Mitigación |
|--------|------|---------|------------|
| "Sin FOMO" se siente vacío (pocas razones para volver) | Media | Alta | Objetivos rotatorios + eventos repetibles + sorpresas (M148) |
| Eventos repetidos se vuelven mecánicos | Media | Media | Variantes (3+ por festividad) y recompensas por participación acumulada |
| Diario de sobremesa crece sin límite | Baja | Baja | Límite de 50 pendientes; los excedentes se liquidan en oro al cobrar (sin pérdida de valor) |
| Métricas de retención mal interpretadas | Media | Media | Definir retención sana (días jugados, proyectos activos) vs comandada |

## 4. Plan de ejecución (fases)
| Fase | Contenido |
|------|-----------|
| **F1 Objetivos** | Tablero diario/semanal/mensual con rotación y sobremesa (M55) |
| **F2 Eventos repetibles** | Motor de variantes sobre M74; catálogo único de recompensas |
| **F3 Anti-FOMO** | Auditoría de scan; política de diseño documentada (M152) |
| **F4 Postgame** | Especificación de 3 bloques (desafíos, misterio final, isla perfecta) |
| **F5 Telemetría** | Métricas de "juega sin prisa" (M104): sesiones libres, cobradas pendientes |

## 5. Métricas de éxito
1. 100% de mecánicas sin streak/expiración/penalización (scan anti-FOMO en CI).
2. Test de ausencia simulada de 7 días → 0 pérdida de progreso o recompensas.
3. Eventos repetibles con ≥ 3 variantes cada uno.
4. Postgame ≥ 5 h de contenido nuevo.
5. Retención medida sin "login forzado" (M104): % de jugadores que vuelven por voluntad.
6. Sin quejas FOMO en encuestas de playtest (M114).

## 6. Notas para integración
- El reloj del juego (M29) es la clavija: el mundo solo avanza en sesión (sin castigo por ausencia).
- El diario (M55) aloja el "tablero de objetivos" y la "sobremesa de recompensas".
- Los eventos (M74) se reutilizan con el motor de variantes sin new contenido exclusivo.
- La telemetría (M104) mide retención sana; las métricas de M94 son las que alimentan el informe 72 h del lanzamiento (M143).