**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 96: Plataformas

## 1. Análisis del dominio
Un juego indie single-player sin multiplayer: la plataforma clave es PC/Steam; las consolas dependen de presupuesto y contratos. El análisis cubre 4 ejes por plataforma:

1. **Viabilidad técnica** (SDK, logros, cloud, controller, certificación).
2. **Coste directo** (devkit, fee, testing, mantenimiento).
3. **Alcance de audiencia** (dónde está el jugador de "Isla Ancestral").
4. **Esfuerzo de mantenimiento** (parches, actualizaciones por plataforma).

## 2. Alternativas consideradas y decisiones

### D1: Estrategia de lanzamiento por tienda
- **A1 (lanzar en todas a la vez)**: máximo alcance pero doble/múltiple costo de QA/certificación y soporte triple el día 0.
- **A2 (lanzamiento en Oleadas: PC/Steam P0 → EGS/GOG P1 → consolas P2 según contrato/Presupuesto → Steam Deck verificado en P0.5)**: concentra recursos en la ventana crítica y reduce riesgo.
- **Decisión:** **A2** — oleadas: P0 = Steam + Steam Deck (verificado); P1 = EGS + GOG (si el coste/beneficio lo avala, decisión en Beta); P2 = consolas (GATE por presupuesto/NDA); P3 = Microsoft Store y otras (solo si hay infraestructura).

### D2: Linux/macOS
- **A1 (nativo en ambos)**: coste de mantenimiento alto.
- **A2 (macOS nativo Apple Silicon con build separada + Linux vía Proton verificado, sin build nativa de Linux)**: mínimo coste con soporte real.
- **Decisión:** **A2** — macOS nativo M1+ (build aparte; Intel solo si la telemetría lo justifica); Linux via Proton verificado (no nativo) documentado en la página de Steam.

### D3: Consolas
- **A1 (comprometer las 3 consolas)**: inviable sin devkits y presupuesto.
- **A2 (GATE por presupuesto con prioridad sugerida Switch → PlayStation → Xbox)**: se decide en fase Beta con contrato; el diseño se mantiene "console-friendly" (cámara, gamepad M57, textos).
- **Decisión:** **A2** — el juego se desarrolla console-ready (Input M57, UI escalada M58, streaming M63) para reducir el coste futuro; la decisión de consola se remite al GATE de presupuesto.

### D4: Cross-save
- **A1 (sin cross-save)**: simple pero molesto para el usuario multi-dispositivo.
- **A2 (cross-save selectivo Steam↔Steam Deck; consolas con cloud de plataforma)**: bajo coste (reutiliza M60; el juego usa el save v3.x portable).
- **Decisión:** **A2** — cross-save activo donde la plataforma lo da gratis (Steam/Deck, y per tier de consola); sin infraestructura propia nueva.

### D5: Cross-play
- **A1 (implementar multiplayer para justificar cross-play)**: contradice el alcance (single-player premium).
- **A2 (documentar "no aplica": sin servidores, sin matchmaking)**: honesto y barato.
- **Decisión:** **A2** — cláusula documentada; si un DLC futuro agrega cooperación local, se reevalúa (M144).

## 3. Riesgos y mitigaciones
| Riesgo | Prob | Impacto | Mitigación |
|--------|------|---------|------------|
| Costes de consola sin presupuesto | Alta | Alta | GATE de presupuesto; diseño console-ready (bajo costo futuro) |
| Certificación rechazada por política | Baja | Alta | Checklist M142 temprano con cada SDK |
| Steam Deck "unsupported" | Media | Media | Verificación temprana (Proton + controller + textos) |
| Mantenimiento multi-plataforma | Media | Media | CI multi-target desde el inicio (M61/M96) |
| Ventana de lanzamiento perdida por QA extra | Media | Media | Oleadas: cada plataforma tiene su cola de QA independiente |

## 4. Plan de ejecución (fases)
| Fase | Contenido |
|------|-----------|
| **F1 Matriz** | 20 puntos × 11 plataformas (tabla con datos) |
| **F2 Prioridades** | P0-P3 con fechas y recursos |
| **F3 Decisiones técnicas** | Linux/macOS/Steam Deck/cross-save/cross-play |
| **F4 Certificación** | Checklist por plataforma (feed M142) |
| **F5 Costes** | Tabla de gastos y GATE de consolas |

## 5. Métricas de éxito
1. Matriz completa con datos verificables (precios de devkit, fees, versiones de SDK).
2. Fechas P0-P3 definidas y coherentes con M143.
3. Steam Deck verificado verde o plan fechado.
4. macOS/Linux con decisión técnica documentada (build/Proton).
5. Cross-save operativo en Steam/Deck (30 ciclos de prueba).
6. 0 "surprises" de certificación en P0 (checklist temprano).
7. GATE de consolas documentado con presupuesto y decisión de fase Beta.

## 6. Notas para integración
- Este módulo alimenta: M149 (preparación de tiendas), M142 (certificación RC), M143 (lanzamiento en oleadas) y M95 (precios por plataforma).
- El Input System debe tratar el gamepad como primer ciudad (M57) desde el día 1 para consolas futuras.
- Los builds de CI multi-target (Windows/Steam Deck/Linux via Proton/macOS) se definen aquí y se ejecutan en M61.