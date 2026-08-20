**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 79: Legal — Contratos

## 1. Análisis del dominio
El estudio (indie, posible sous-traíl de una sola persona) recibe obras de terceros para el juego. El riesgo legal principal: si no hay cesión de derechos clara, cada colaborador podría reclamar derechos sobre su obra, bloqueando el lanzamiento (M143) o la monetización (M95). La solución es un marco de contratos único con cláusulas transversales + anexos por rol.

## 2. Alternativas consideradas y decisiones

### D1: Modelo de contratos
- **A1 (contrato individual por cada colaboración sin plantilla)**: incoherente, caro y lento.
- **A2 (plantilla única con anexos por rol)**: consistente; los anexos tocan particularidades (música = royalties opcionales, actores = uso de voz, artistas = revisiones).
- **Decisión:** **A2** — plantilla base "Contrato de Contribución a Isla Ancestral" + anexos por rol (artiste/programador/músico/compositor/diseñador/escritor/actor/freelancer). Todo firmado por ambas partes y revisado por abogado.

### D2: Propiedad intelectual (RF3)
- **A1 (cesión total irrevocable)**: el estudio es dueño de todo; simple pero a veces rechazado por creadores de renombre.
- **A2 (cesión al estudio para el juego + licencia de uso con crédito)**: el estudio obtiene todos los derechos comerciales del juego; el colaborador conserva la autoría (ideal para portfolio) y cede el uso dentro del producto.
- **Decisión:** **A2** — el colaborador cede todos los derechos comerciales de su obra **incorporada** al juego; conserva la atribución/portfolio según la cláusula de portfolio (RF8). La PI del juego queda en M78/M127.

### D3: Remuneración (RF4)
- **A1 (solo royalties)**: motivador pero arriesgado si el juego no despega.
- **A2 (pago fijo por entregable, con royalties opcionales en música/escritura)**: previsible y justo; críticos (música, escritura larga) pueden incluir royalty de ventas minoritario.
- **Decisión:** **A2** — pago fijo por entregable definido en cada contrato; opción de royalties minoritarios (≤ X%) para música original y escritores, documentada; nunca se compromete revenue del 100% de M95 sin aprobación.

### D4: Confidencialidad (RF6)
- **A1 (NDA separada)**: doble documento.
- **A2 (cláusula de confidencialidad dentro del contrato + NDA estándar solo para líneas de trabajo sensibles)**: el contrato incluye NDA; se añade NDA separado solo para lore avanzado (M148) y builds tempranos (M140).
- **Decisión:** **A2** — cláusula de confidencialidad por defecto en el contrato; NDA adicional solo para accesos especiales.

### D5: Uso de portfolio (RF8)
- **A1 (prohibir todo)**: daña la carrera del colaborador y desmotiva.
- **A2 (permitir portfolio con restricción: sin spoilers, sin builds jugables, crédito al juego)**: sano para todos.
- **Decisión:** **A2** — permitido mostrar la obra en portfolio/voz/actor con: crédito al juego, sin spoilers (sellos/final/epílogo M148), sin entregar builds.

## 3. Riesgos y mitigaciones
| Riesgo | Prob | Impacto | Mitigación |
|--------|------|---------|------------|
| Colaborador reclama derechos de su obra | Media | Alta | Cesión por escrito en contrato firmado |
| Disputa de remuneración | Media | Media | Remuneración fija clara por entregable |
| Fuga de lore por confidencialidad | Media | Alta | NDA en contrato + NDA separado accesos especiales |
| Obra que viola derechos de terceros | Baja | Alta | Garantía de originalidad en el contrato |
| Desacuerdo en revisiones | Baja | Media | Rondas de revisión acotadas en el contrato |

## 4. Plan de ejecución (fases)
| Fase | Contenido |
|------|-----------|
| **F1 Plantilla base** | Cláusulas transversales (RF9-RF18) |
| **F2 Anexos por rol** | 8 anexos (arte, programación, música, composición, diseño, escritura, voz, freelancer) |
| **F3 Legal** | Revisión de legislación + foro + abogado |
| **F4 Gestión** | Registro de contratos firmados (index en M151) |

## 5. Métricas de éxito
1. Plantilla única adoptada para todas las colaboraciones.
2. 100% de colaboradores con contrato firmado antes de recibir su obra.
3. Cesión de PI documentada por contrato.
4. 0 disputas de propiedad en auditoría (M151).
5. Portfolio permitido sin spoilers verificado en cada contrato.
6. Abogado revisó todos los contratos relevantes (firma en acta).

## 6. Notas para integración
- La PI del juego se consolida en M78; el copyright en M127; los contratos alimentan la auditoría de M151 (index de contratos/licencias).
- Las colaboraciones comunitarias (M100) NO entran en el marco: se compensan solo con créditos/bienes y políticas de comunidad, no con contratos de obra (se documenta la distinción).