**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 79: Legal — Contratos

## 1. Estructura de la plantilla de contrato
```
CONTRATO DE CONTRIBUCIÓN A "ISLA ANCESTRAL"
1. Partes (estudio + colaborador)
2. Objeto / obra específica
3. Propiedad intelectual (cesión al estudio para el juego; autoría conservada)
4. Cesión y licencia (alcance)
5. Remuneración (fija y/o royalties)
6. Entregables y plazos
7. Revisiones (N rondas)
8. Confidencialidad (NDA)
9. Terminación (causas y efectos)
10. Uso de portfolio (permitido con restricciones)
11. Garantías (originalidad, derechos no violados)
12. Responsabilidad (límite)
13. Legislación aplicable y foro
14. Firma
```
- Se redacta en lenguaje claro (resumen) + cláusulas legales.

## 2. Cesión de propiedad intelectual (RF3)
| Tipo de obra | Cesión |
|--------------|--------|
| Arte (2D/3D/texturas) | Cesión comercial al estudio para el juego; autoría en créditos (M131) |
| Música y composiciones | Cesión comercial del master al estudio; royalties opcionales (≤ X%) |
| Programación | Cesión del código al estudio |
| Diseño de niveles/UX | Cesión de los diseños |
| Escritura/lore/diálogos | Cesión comercial de los textos; royalties opcionales (escritores) |
| Voces (actores) | Licencia de uso de la voz en el juego y sus DLC/tráilers |
| Freelancers | Cesión total de la obra puntual |

## 3. Remuneración (RF4)
- **Fija**: pago por entregable definido en el contrato (fecha y monto).
- **Royalties (opcional)**: % minoritario sobre ventas solo para música y escritores, con tope y límite temporal; nunca sobre el 100% de M95; requiere aprobación separada.
- **Créditos**: todo contribuidor aparece en M131 (obligatorio por contrato).

## 4. Entregables y revisiones (RF5/RF7)
- Entregable: formato exacto + cantidad + plaza (fecha).
- Revisiones: N rondas definidas (típicamente 2-3) incluidas en el pago; rondas extra = hora adicional.
- Criterio de aprobación explícito (aceptación por el estudio).

## 5. Confidencialidad (RF6 — M148)
- Cláusula de confidencialidad en el contrato: no divulgar lore, builds, diseño por NDA.
- NDA separado solo para accesos especiales (lore avanzado, builds tempranos M140).
- Excepción estándar: información pública.

## 6. Terminación (RF7)
- Causas: incumplimiento de plazo/calidad, violación de confidencialidad, mutuo acuerdo.
- Efecto: los pagos pendientes por entregables completados se abonan; la cesión de obras ya entregadas permanece.
- Derechos de autor no revierten por terminación (a diferencia de licencia).

## 7. Uso de portfolio (RF8)
- Permitido: mostrar la obra en portfolio, reel, voz, etc.
- Condiciones: crédito al juego "Isla Ancestral"; sin spoilers (sellos, templo final, epílogo M148); sin entregar builds jugables.
- Se incluye como cláusula explícita (no implícita).

## 8. Garantías y responsabilidad (RF9/RF10)
- Garantía del colaborador: obra original, no viola derechos de terceros, no usa IA no declarada (M86) si aplica.
- Responsabilidad: el colaborador indemniza al estudio por violaciones; límite de la obligación del estudio = pagos hechos.
- Legislación: jurisdicción del estudio; foro designado.

## 9. Flujo de contratación
```
1. Necesidad de contribución definida (RF5 entregables)
2. Selección de plantilla + anexo por rol
3. Abogado revisa (RF12) contratos relevantes/firmas
4. Firma digital (ambas partes)
5. Registro en index de contratos (M151)
6. Entrega + revisión + pago (dentro del contrato)
7. Archivo de la obra aceptada en el pipeline (M108)
```

## 10. Distinción con comunidad (M100)
- Las colaboraciones comunitarias (no remuneradas, no contractuales) se rigen por políticas de comunidad y créditos, NO por este marco de contratos.
- Cualquier colaboración que aporte obra comercial al juego SIEMPRE pasa por contrato (para no diluir la PI).

## 11. Qué NO se hace
- No se firma contrato sin lectura del abogado (relevante).
- No se acepta obra con cesión ambigua de PI.
- No se promete royalty sin aprobación de M95.
- No se permite portfolio con spoilers o builds jugables.