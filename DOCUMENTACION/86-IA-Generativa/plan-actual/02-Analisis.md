**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 86: IA Generativa

## 1. Contexto del proyecto

"Isla Ancestral" es un desarrollo indie de mundo voxel cozy sobre la isla Aurora, construido en **Godot 4.x + Voxel Tools con GDScript**. El proyecto opera bajo un protocolo multiagente (CHECKLIST-GLOBAL) donde modelos de lenguaje generan código, diseño y documentación. Esto hace que **el propio flujo de producción ya usa IA generativa como herramienta**, y el módulo 86 debe regular ese uso de forma explícita y honesta, no prohibirlo.

## 2. Análisis del dominio: política de Steam/Valve sobre IA generativa

### 2.1 Línea de tiempo de la política (2024+)

| Fecha | Hito | Implicación para el proyecto |
|---|---|---|
| Enero 2024 | Valve publica la política de contenido generado con IA | Formulario obligatorio de divulgación (AI Content Disclosure) antes del lanzamiento; dos categorías: contenido pregenerado y contenido en vivo |
| Enero 2024 | Requisitos iniciales | Para contenido pregenerado: promesa de que no infringe derechos de autor y revisión de contenido; para contenido en vivo: mecanismos de filtrado/moderación y ruta de reporte |
| Abril 2024 | Valve simplifica la política | Se elimina el requisito de filtrado obligatorio para contenido en vivo; solo divulgación en el formulario + promesas de contenido legal |
| Junio 2024 | Nueva encuesta de contenido | Valentine solicita detalle de cómo se usó la IA durante el desarrollo (más preguntas en el formulario de Go Live) |
| 2025+ | Política vigente (aproximada) | Divulgación por categorías: IA usada durante el desarrollo / contenido generado con IA dentro del juego (pregenerado o en vivo) / contenido adulterado en la tienda. Los jugadores pueden reportar contenido ilegal generado con IA |

### 2.2 Qué exige Steam al momento de publicar (estado 2024-2026, aproximado)

1. **Declaración obligatoria** en el proceso de lanzamiento (Steamworks → Go Live → AI Content Disclosure).
2. **Distinción entre**:
   - IA usada como herramienta de desarrollo (no aparece en el juego): suele declararse igualmente;
   - Contenido generado con IA **pregenerado** que aparece en el juego (arte, texto, música, audio);
   - Contenido generado con IA **en vivo** (generado en tiempo de ejecución durante la sesión del jugador).
3. **Promesas de contenido legal:** el desarrollador declara que el contenido no viola derechos de terceros y que revisó el contenido generado.
4. **Publicidad honesta:** las capturas de pantalla y tráilers deben representar el juego real; el contenido promocional generado con IA debe declararse igualmente.
5. **Reporte de jugadores:** los jugadores pueden reportar contenido; Valve revisa y puede tomar medidas.

### 2.3 Impacto para "Isla Ancestral"

- El proyecto **no planea** contenido generado en vivo al momento de redactar este documento: el mundo voxel se genera proceduralmente por algoritmos tradicionales (módulos 08/09/10), lo que **no** cuenta como "contenido generado con IA" ante Steam.
- El contenido con IA sería del tipo **pregenerado** (assets creados fuera del juego y revisados) o IA de **desarrollo** (diseño, código, documentación).
- Esto coloca al proyecto en el escenario **más simple de declarar**: divulgación de herramienta de desarrollo + contenido pregenerado revisado, sin contenido en vivo.
- La declaración debe **coincidir exactamente** con el registro de herramientas real (`AI-TOOLS-REGISTRY.md`).

> **Advertencia permanente:** la política de Steam/Valve sobre IA generativa **cambia con frecuencia** (2024 tuvo al menos 3 revisiones). Todo lo documentado aquí es orientativo; **debe re-verificarse contra la documentación oficial de Steamworks al momento de publicar** (checkbox QA obligatorio).

## 3. Análisis del dominio: copyright del output de modelos de IA

| Riesgo | Descripción | Mitigación para el proyecto |
|---|---|---|
| Ausencia de autoría humana | En EE. UU., la Oficina de Copyright no registra obras sin autoría humana (política reforzada desde 2023; reporte enero 2025: requieren "contribución humana significativa") | No reclamar derechos exclusivos sobre output puro de IA; considerar el output como "material de referencia" salvo que haya transformación humana sustancial |
| Datos de entrenamiento | Los modelos se entrenan con obras protegidas sin licencia; hay litigios activos (NYT v. OpenAI, Stable Diffusion, etc.) | Evitar depender de estilos de artistas vivos reconocibles; preferir herramientas con términos de servicio claros; usar prompts propios originales |
| Términos de servicio de las herramientas | Cada herramienta (Midjourney, Stable Diffusion, ChatGPT, Suno, etc.) define su propia cesión de derechos sobre el output | Registrar licencia de la herramienta en `AI-TOOLS-REGISTRY.md`; elegir herramientas con licencias permisivas para uso comercial |
| Mezcla de contenido | Un asset final puede mezclar IA + trabajo humano; la línea de "autoría" se difumina | Documentar el proceso: qué parte generó la IA y qué revisó/editó el humano |
| Jurisdicción | No hay consenso internacional (UE discute, algunas jurisdicciones no reconocen protección del output) | Tratar el output de IA como "sin derechos reclamables" y no como activo de propiedad intelectual; la PI del proyecto se apoya en el contenido humano y las marcas (ver módulo 78) |
| Estilo artístico del juego | La IA tiende a "promediar" estéticas; el estilo cozy voxel propio se puede diluir | Prohibir IA como definición del estilo final; el estilo lo fijan los módulos de arte con dirección humana |

**Conclusión:** el riesgo no desaparece con la revisión humana, pero se **reduce drásticamente** si el output de IA se usa como apoyo (ideas, prototipos, referencias) y no como base de derechos. La política del módulo está diseñada alrededor de esta conclusión.

## 4. Alternativas consideradas

| Alternativa | Descripción | Veto |
|---|---|---|
| A. Prohibición total | Ninguna IA en producción | Descartada: inviable e hipócrita (el propio protocolo multiagente usa IA; y perdería eficiencia de prototipado) |
| B. Uso libre sin registro | IA permitida sin política ni registro | Descartada: inviable que se actualice la declaración Steam y auditar contenido dudoso |
| C. Política mixta con registro (elegida) | IA permitida como apoyo (prototipado, ideas, moodboards, referencias, borradores) + **prohibida en assets finales publicables sin revisión humana integral** + registro de todas las herramientas + declaración Steam honesta | **Elegida** |
| D. Política mixta sin límite de "final" | IA permitida en assets finales con revisión "liviana" | Descartada: el riesgo de copyright y de coherencia estética no se cubre con revisión liviana; contradice módulo 78 |

## 5. Decisiones clave del módulo

| # | Decisión | Justificación |
|---|---|---|
| D1 | Política mixta: IA solo como apoyo de prototipado/ideas/referencias | Conserva eficiencia sin comprometer derechos ni estilo |
| D2 | Assets finales publicables: prohibido el output directo de IA sin revisión humana integral | Cubre el riesgo de copyright y garantiza coherencia artística |
| D3 | Registro obligatorio de herramientas (`AI-TOOLS-REGISTRY.md`) | Permite auditar, declarar en Steam y dar créditos transparentes (módulo 131) |
| D4 | Revisión humana documentada de todo contenido con IA que entre al juego | Cumple la "promesa de contenido legal" de Steam y la definición de autoría del 78 |
| D5 | Declaración Steam por defecto: "IA usada en desarrollo (herramienta)" + "contenido pregenerado revisado" si aplica; nunca "en vivo" | Escenario realista mínimo y honesto para el proyecto |
| D6 | Documentar que la política de Steam es cambiante y debe re-verificarse al publicar | Evita declaraciones desactualizadas o sanciones |
| D7 | El código generado (GDScript) por agentes de IA se trata como "borrador con revisión obligatoria" | El protocolo multiagente ya exige verificación de compilación y QA (AGENTS §12) |

## 6. Coordinación con el módulo 78 (Legal-PI)

- El 78 define el marco de propiedad intelectual del proyecto (marca, nombre del juego, derechos de contenido humano).
- El 86 define el régimen específico del **contenido generado con IA** dentro de ese marco: el output de IA no se considera "contenido humano" y por lo tanto no suma derechos reclamables de autoría.
- Cualquier conflicto entre la política del 86 y el marco del 78 se resuelve a favor del 78 (dependencia jerárquica).
- El registro de herramientas del 86 alimenta la declaración Steam y los créditos (131) con datos auditables.

## 7. Análisis de riesgos del módulo

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Política de Steam cambia antes del lanzamiento | Alta | Medio | Re-verificación obligatoria marcada en checklist y plantilla de declaración |
| Un colaborador integra output de IA sin registrar | Media | Alto | Flujo de aprobación + revisión de assets en QA (module 12) |
| Contenido de estilo dudoso generado por IA | Media | Medio | Matriz permitido/prohibido + veto de IA en definición de estilo |
| Disputa de copyright sobre un asset revisado | Baja | Alto | Registro de origen del asset; política documentada como defensa de buena fe |
| Herramienta de IA cambia sus términos de servicio | Media | Bajo | Revisión periódica del registro; anotar versión y licencia por uso |